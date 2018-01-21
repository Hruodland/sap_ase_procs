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
              U is for UserTables for example
Result      : Resultset with the object names.
Errorcodes  : -
License     : MIT
Conditions
  Pre       :  -
Dependency  : SAP ASE 16.0 (may work with none or few modifications on older versions)
Tables      : -
Note(s)     :
Date        Revision  What
-------------------------------------------------------------------
2018-01-21  1.0       Reformatted code, change objname to 255
-------------------------------------------------------------------
*******************************************************************
*/
if @objname in ('D','P','TR','U','V','S','R')
begin
    select Object_name   = name
           ,Type         = type
           ,Owner        = convert(char(15),user_name(uid))
           ,Created_date = convert(char(20),crdate)
    from   sysobjects
    where  type = @objname
    order  by name
end

/* do a simple ls */
else if exists (select * from sysobjects where name like '%'+@objname+'%')
    select Object_name   = name
          ,Type          = type
          ,Owner         = convert(char(15),user_name(uid))
          ,Created_date  = convert(char(20),crdate)
    from   sysobjects
    where  name like '%' + @objname + '%'
    order  by name

else print "No Object Found"


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
--eof

