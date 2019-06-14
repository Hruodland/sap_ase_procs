/* @(#) sp_thresholdaction : sp_thresholdaction template */
/* vim: set ts=2 sw=2 tw=0 et :*/

use sybsystemprocs
go

print 'Installing PROCEDURE: sp_thresholdaction'
go

create or replace  proc sp_thresholdaction(
   @dbname      varchar(30)
  ,@segmentname varchar(30)
  ,@space_left  int
  ,@status      int
  )
as
begin
/*
#----------------------------------------------------------------------
Author: Roland van Veen
#----------------------------------------------------------------------
Procedure   : sp_thresholdaction
Description : Free space threshold procedure example/template.
Usage       : This threshold procedure supports data and log thresholds.
Parameters  :
             @dbname: Name of the database
             @segmentname Name of the segment
             @space_left space left in pages
             @status 1=Last chance threshold 0 = user threshold
Result      : prints messages, dumps database (when log cannot be dumped) or
              transaction log when needed to an emergency location.
Errorcodes  : -
License     : MIT
Conditions
  Pre       :  -
Dependency  : SAP ASE 16.0 (may work with  few modifications on older versions)
Tables      : -
Note(s)     :
      1.Notice the Hardcoded emergency dump location.
        An administrative table could be unavailable and don't put user tables in system databases.
      2.There are many ways to implement thresholds, this only dumps when the last threshold is reached.
        Logs only, no dumps, for user thresholds.
        Dumps databases when log is not on a separate device.

Date        Revision  What
-------------------------------------------------------------------
2018-02-20  1.0       Created
2019-06-12  1.1       Reformatting code
-------------------------------------------------------------------
*******************************************************************
*/

set nocount on

declare @CurrentDate datetime
declare @after_size  int
declare @before_size int
declare @cdm         varchar(100)
declare @dbid        int
declare @dumpdev     varchar(256)
declare @error       int
declare @freespace   int
declare @islogsegment char(1)
declare @logondata   int
declare @tpages      bigint
declare @sleft       varchar(10)

select @dbid = db_id(@dbname)
select @tpages = lct_admin("reserve",@dbid, 0)
Select @CurrentDate = getdate() , @islogsegment= 'N'
select @freespace = @space_left * @@pagesize / 1024
select @logondata = 0, @sleft = convert(varchar(10), @space_left)


--Change this to your path, or get it from a user table.
set @dumpdev='/home/sybase/dumps/emergency/'+@dbname+ convert(varchar(20),@CurrentDate,2) + @segmentname+  '.dmp'


--Tests Log and data segment is on same device?
if exists ( select 1
            from   master..sysdatabases
            where  ((status & 8)/8) = 1
            and name= @dbname)
begin
   select @logondata=1
end

print "Notice      : sp_thresholdaction execution started."
print "Database    : %1!", @dbname
print "Segment     : %1!", @segmentname
print "Space Left  : %1!", @sleft
print "Status      : %1!", @status
print "@@thresh_hysteresis : %1!  Last threshold is at %2! page ", @@thresh_hysteresis , @tpages

if exists ( select 1
            from   master..syssegments
            where  name = @segmentname
            and    segment = 2 )
begin
    set    @islogsegment = 'Y'
    set    @cdm= "exec " + rtrim(@dbname)+  ".dbo.sp_spaceused '" + @dbname + ".dbo.syslogs'"
    execute(@cdm)
    select lct_admin("logsegment_freepages", @dbid ) as logsegment_freepages
    ,      lct_admin("reserved_for_rollbacks", @dbid) as reserved_for_rollbacks

    select loginfo(@dbid, 'database_has_active_transaction') as has_act_tran
    ,      loginfo(@dbid, 'oldest_active_transaction_pct') as Act_log_portion_pct
    ,      loginfo(@dbid, 'oldest_active_transaction_spid') as OA_tran_spid
    ,      loginfo(@dbid, 'can_free_using_dump_tran') as dump_tran_free_pct
    ,      loginfo(@dbid, 'is_stp_blocking_dump') as is_stp_blocking
    ,      loginfo(@dbid, 'stp_span_pct') as stp_span_pct
end

if  ( @status=1 )
begin
  print 'Last Chance threshold!'
  print "Error : ### Segment '%1!' in database '%2!' has reached last chance threshold.", @segmentname, @dbname

  print "Space Free  : %1! [Mb] %2![pages].", @freespace , @space_left
  print 'Use select lct_admin("abort", <spid>) for the oldest transaction (table syslogshold) if needed.'

  print '      : ### Top 3 old active transactions'
  select top 3
    convert(numeric(3,0), loginfo(db_id(), 'xactspanbyspid', t.spid)) as xactspan
  , convert(char(4), t.spid) as SPID
  , convert(char(20), t.starttime) as STARTtime
  , convert(char(4), p.suid) as suid
  , convert(char(15), p.program_name) as progname
  , convert(char(15), p.cmd) as COMMAND
  , convert(char(16), p.hostname) as hostname
  , convert(char(16), p.hostprocess) as hostprocess
  from        master..systransactions t
  inner join  master..sysprocesses p
  on       t.spid = p.spid
  order by xactspan desc

  print '      : ### Top 3 old sysloghold rows.'
  select top 3 P.hostname
  , P.hostprocess
  , P.program_name
  , H.name
  , H.starttime
  from master..sysprocesses P
  inner join master..syslogshold H
  on  P.spid = H.spid
  order by H.starttime

  set @before_size = reserved_pages(db_id(), object_id("syslogs"))

  print ' '

  if @logondata=1
    begin
      print 'Dump database to emergency location.!'
      dump database @dbname to @dumpdev
      select @error = @@error
      if @error != 0
      begin
        print "LOG DUMP ERROR: %1!", @error
      end
      print 'Dump log with truncate only.'
      dump tran @dbname with truncate_only
      select @error = @@error
      if @error != 0
      begin
        print "LOG DUMP ERROR: %1!", @error
      end
    end
  else
    begin
      if @islogsegment='Y'
      begin
        print 'Dump transactionlog!'
        dump tran @dbname to @dumpdev
        select @error = @@error
        if @error != 0
        begin
          print "LOG DUMP ERROR: %1!", @error
        end
        print "Info   : The '%1!' transaction log  was dumped", @dbname
		print "      : ### Automatic transaction dump made, please adjust segment if needed !"
        set @after_size = reserved_pages(db_id(), object_id("syslogs"))
        print "LOG DUMP PAGES: Before: %1!, After %2!", @before_size, @after_size
      end
      else
      begin
        print "Error       : ### Data segment '%1!' in database '%2!' has reached LAST threshold", @segmentname, @dbname
        print "Space Free  : %1! [Mb] %2![pages]", @freespace , @space_left
      end
    end
end

else --@status=0
  begin
        print "Warning : ### Segment '%1!' in database '%2!' has reached a threshold", @segmentname, @dbname
        print "Space Free  : %1! [Mb] %2![pages]", @freespace , @space_left
  end

set nocount off
return(0)

end
go
if object_id('sp_thresholdaction') IS NOT NULL
    begin
    print 'sp_thresholdaction created'
    exec  sp_procxmode 'sp_thresholdaction', 'anymode'
    grant execute on    sp_thresholdaction to public
    -- >> Add grant execute to your dbo(s) here! <<
    end
go
--eof
