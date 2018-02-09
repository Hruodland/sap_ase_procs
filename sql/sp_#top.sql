/* vim: set ts=2 sw=4 tw=0 et :**/
/* @(#) sp_#top display who is doing what in short for ansi terminals only.
*/

use sybsystemprocs
go

print    'Installing PROCEDURE sp_#top'
setuser  'dbo'
go

create or replace  procedure sp_#top 
  @showplan char(1)='N' -- 'Y' To display queryplan.
as 
begin 
/* 
Purpose:  Top or prstat like SQL tool for vt220/vt100 terminal session. 
          Displays: top # processes (cpu based), 
          query text of first query, (if sybase_ts_role)
          query plan of first query. (optional)
          THIS IS NOT A NORMAL SP: For interactive usage on ansi terminals only! 
Parameters:
          showplan: If 'Y' : procedure shows queryplan but output is not that compact!
Usage  :  Use isql -w132 to avoid column wrapping! 
          Normal invocation: 
          exec sp_#top 
          go 

          Invocation: for sqltext trace: (needs sybase_ts_role). 
          dbcc traceon(3604) 
          exec sp_#top 
          go 

          For queryplan:
          exec sp_#top 'Y'
          go
NOTES:
License:  MIT
Author :  Roland van Veen
History: 
----------------------------------------------------------- 
2018-01-23  Refactored code for ASE 16.
*/ 

set nocount on 
set flushmessage on 
dbcc traceon(3604)
declare @clear char(6),       -- Clear screen on a terminal 
        @rev   char(4),       -- Reverse video 
        @norm  char(4),       -- Normal video 
        @proc  int, @ret int,  -- Return codes 
        @fname varchar(30),   -- Full name login 
        @pname char(16),      -- Program name 
        @hname char(10)       -- Hostname 
--Special terminal escape codes. 
select @clear = char(27)+"[H" + char(27) + "[J" 
select @rev= char(27) + "[7m" 
select @norm= char(27) +"[0m]" 
-- The MAIN display loop, runs forever until user hits CTRL+C/ 
while 1=1 
begin 
    print @clear 
    set rowcount 10
    select spid,status,substring(db_name(dbid),1,20) db, 
           blocked,suser_name(suid) login,suid, physical_io,cpu, cmd, 
           hostname, program_name 
    into #proca 
    from master..sysprocesses 
    --where 
        --spid <> @@spid and 
        --suid <> 0 and 
        --cmd <> 'AWAITING COMMAND' 
    order by cpu desc 
    select @ret = @@rowcount 
    set rowcount 0 
    if (@ret =0) 
    begin 
        -- When there is nothing, continue with next loop cycle. 
        waitfor delay "00:00:01" 
        drop table #proca 
        continue 
    end 
    select  "                         >>>>>>>      __>" + @rev + "SQL_TOP SAP ASE" +@norm + "<__     <<<<<<<<" 
    select 
        spid,status, db, 
        blocked,login,physical_io,cpu, cmd 
    from #proca 
    -- Get top process. 
    select @proc = spid from #proca 
    where cpu = ( 
           select max(cpu) from #proca 
           ) 
    /*
    set rowcount 1 
    select @proc = spid from #proca 
    set rowcount 0 
    */
    select @fname = ( 
        select fullname  from master.. syslogins where suid = 
            (select suid from #proca where spid = @proc)) 
    select @hname =  hostname 
    from   #proca 
    where  spid = @proc 
    select @pname =  program_name 
    from   #proca 
    where  spid = @proc 
    -- Show query text, requires dbcc traceon(3604) set by caller.) 
    if (proc_role("sybase_ts_role") = 1  ) 
        begin 
        select @fname Login_Name,@pname Process_Name, @hname Host_Name 
        --waitfor delay "00:00:05" 
        --PAGE
        --select @clear 
        dbcc sqltext(@proc) 
        end 
    if ( @showplan='Y' and  @proc is not null) 
    begin 
      waitfor delay "00:00:12" 
      -- PAGE 
      select @clear 
      --More info about the statement.
      select id, tran_name, stmtnum, linenum
      from master..sysprocesses
      where spid = @proc
      --QueryPlan
      exec  @ret = sp_showplan @proc,null,null,null 
    end 
    drop table #proca 
    waitfor delay "00:00:10" 
    end 
    dbcc traceoff(3604)
end
go
if object_id('sp_#top') IS NOT NULL
    begin
    print 'sp_#top created'
    exec  sp_procxmode 'sp_#top', 'anymode'
    grant execute on    sp_#top to public
    end
go
setuser
go


--eof
