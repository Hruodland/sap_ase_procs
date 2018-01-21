/* vim: set ts=2 sw=4 tw=0 et :*/
/* @(#) sp_#ps display who is doing what in short by cpu-usage
*/

use sybsystemprocs
go

print 'Installing PROCEDURE: sp_#ps'
go


create or replace  procedure  sp_#ps
as
/*
#----------------------------------------------------------------------
Author: Roland van Veen
#----------------------------------------------------------------------
Procedure   : sp_#ps
Description : Display who is doing what in short formatted list
              only for active user-processes and not myself.
              Just another sp_who alternative.
Usage       : sp_#ps
Result      : Resultset with the process information.
Errorcodes  : -
License     : MIT
Conditions
  Pre       : Install as sa or other master db user having read accces to the used tables.
Dependency  : SAP ASE 16.0 (may work with none or few modifications on older versions)
Tables      : -
Note(s)     :
Date        Revision  What
-------------------------------------------------------------------
2018-01-21  1.0       Reformatted code, put on github.
-------------------------------------------------------------------
*******************************************************************
*/
begin
    declare
    @errno    int

    set nocount off
    set flushmessage on

    select  @errno = 0

    print ' '
    print 'Active -processes not me or system:'
    print '_______________________________________________________________________________________________________________________________________'
    print ' '

    select
          Login = substring(name,1,20)
        , Name = fullname
        , Host = hostname
        , Application = substring (program_name,1,20)
        , "Database" = substring(db_name(dbid),1,20)
        , "Transaction" = substring(tran_name,1,20)
        , Command = cmd
        , OSprocess = kpid
        , CPU = cpu
        , IO = physical_io
    from
        master..sysprocesses 
        inner join master..syslogins
        on master..syslogins.suid = master..sysprocesses.suid
    where rtrim(cmd) not in
            ( "MIRROR HANDLER"
            , "NETWORK HANDLER"
            , "CHECKPOINT SLEEP"
            , "AUDIT PROCESS"
            , "HOUSEKEEPER"
            , "DEADLOCK TUNE")
    and   cmd not like "%LAZY%"
    and   spid != @@SPID
    order by Login

    select @errno = @@error
    set nocount on
    set flushmessage off

    return(@errno)
end
go

if object_id('sp_#ps') IS NOT NULL
    begin
    print 'sp_#ps created'
    exec  sp_procxmode 'sp_#ps', 'anymode'
    grant execute on    sp_#ps to public
    end
go
setuser
go


--eof

