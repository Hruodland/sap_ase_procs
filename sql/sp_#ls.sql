/* @(#) sp_#ls [objectname pattern] */
/* vim: set ts=2 sw=2 tw=0 et :*/

use sybsystemprocs
go

print 'Installing PROCEDURE: sp_#ls'
go

create or replace  proc sp_#ls(
    @objname varchar(255) = '%'
    )
as
begin
/*
#----------------------------------------------------------------------
Author: Roland van Veen
#----------------------------------------------------------------------
Procedure   : sp_#ls
Description : Present lists of objects (by selected type)) in current database
Usage       : sp_#ls  <object_name>
Parameters  : @objname: Pattern or name of objects or one one the type indicators:
              ('D','P','TR','U','V','S','R')
			  D DEFAULT
			  P Procedure
			  TR TRIGGER
			  U Usertabe
			  V VIEW
			  S Systemtable
			  R Rule
Result      : Resultset with the object names.
Errorcodes  : -
Example	    : sp_#ls U
License     : MIT
Conditions
  Pre       :  -
Dependency  : SAP ASE 16.0 (may work with none or few modifications on older versions)
Tables      : -
Note(s)     :
Date        Revision  What
-------------------------------------------------------------------
2018-01-21  1.0       Reformatted code, change objname param to 255 but truncates output
-------------------------------------------------------------------
*******************************************************************
*/
if @objname in ('D','P','TR','U','V','S','R')
begin
    select Object_name   = convert(varchar(30),substring(name,1,30))
           ,Type         = type
           ,Owner        = convert(char(15),user_name(uid))
           ,Created_date = convert(char(20),crdate)
    from   sysobjects
    where  type = @objname
    order  by name
end

else
begin
  if @objname = 'SP'
  begin
      print '-------------SYSTEM-------------'
      select Object_name   = convert(varchar(30),substring(name,1,30))
            ,Type         = type
            ,Owner        = convert(char(15),user_name(uid))
            ,Created_date = convert(char(20),crdate)
      from   sybsystemprocs..sysobjects
      where  type = 'P'
      order  by name
  end
  else 
  begin
    select Object_name   = convert(varchar(30),substring(name,1,30))
          ,Type          = type
          ,Owner         = convert(char(15),user_name(uid))
          ,Created_date  = convert(char(20),crdate)
    from   sysobjects
    where  name like '%' + @objname + '%'
    union all
    select Object_name   = convert(varchar(30),substring(name,1,30))
          ,Type          = type
          ,Owner         = convert(char(15),user_name(uid))
          ,Created_date  = convert(char(20),crdate)
    from   sybsystemprocs..sysobjects
    where  name like '%' + @objname + '%'
    order  by  1
  end
end

return(0)

end
go
if object_id('sp_#ls') IS NOT NULL
    begin
    print 'sp_#ls created'
    exec  sp_procxmode 'sp_#ls', 'anymode'
    grant execute on    sp_#ls to public
    end
go
setuser
go
--eof

