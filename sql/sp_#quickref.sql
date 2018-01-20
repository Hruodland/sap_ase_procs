/* vim: set ts=2 sw=4 tw=0 et :*/
-- @(#) sp_#quickref  @format , @module
use sybsyntax
go

setuser "dbo"
go

print 'Installing PROCEDURE: sp_#quickref'
go


create or replace proc sp_#quickref
 (
    @format char(1)     = 'A',  --A or H
    @module varchar(20) = '%'
 )
as
/*
#----------------------------------------------------------------------
Author: Roland van Veen
#----------------------------------------------------------------------
Procedure   : sp_#quickref
Description : Generates text or  HTML output from the sybsyntax database
Usage       : sp_#quickref <module name> , [output format]
              where module name exists in sybsyntax table and output format
              is A for ascii or H for HTML.
Parameters  : 1 @format : output type:  A or H
              2 @module : module pattern  string
Result      : Ascii or HTML printed resultset
Errorcodes  : Returns 1: Invalid parameter value(s)
License     : MIT   
Conditions
  Pre       : Database sybsyntax should exist including content for sybsyntax table.
Dependency  : SAP ASE 16.0 (may work with none or few modifications on older versions)
Tables      : sybsyntax..sybsyntax
Note(s)     :
    Example isql batch file named quickref.sql  to generate help files:

    --isql -U<login> -S<server> -i quickref.sql  -b -n
    use sybsyntax
    go
    exec sp_#quickref  'H' ,'Transact-SQL'
    go > help_TSQL.html
    exec sp_#quickref  'H' ,'System Procedure'
    go > help_SP.html
    exec sp_#quickref  'H' ,'UNIX Utility'
    go > help_UTIL.html
    exec sp_#quickref  'H' ,'Windows NT Utility'
    go > help_WINUTIL.html
    exec sp_#quickref  'H' ,'dbcc Procedure'
    go > help_DBCC.html
    exec sp_#quickref  'H' ,'ESP'
    go > help_ESP.html
    exec sp_#quickref  'H' , '%'
    go > help_ALL.html
    go


Date        Revision  What
-------------------------------------------------------------------
2018-01-18  1.1       Changes for ASE 16, push first version into gist.
-------------------------------------------------------------------
*******************************************************************
*/

declare @msg varchar(255)
set nocount on
set flushmessage on

if db_id("sybsyntax") is null
begin
    print "Database sybsyntax should be installed!"
    return (1)
end

if  ( @module is null )
begin
    select distinct module
    from sybsyntax
    order by module
    print "USAGE:  sp_Squickref @Format, [@Module]"
    return (1)
end

IF @format = 'A'
begin
    select
          case
            when linenum = 1 then char(10) + commandname
          else syntax
    end
    from sybsyntax
    where module like @module
    order by commandname, linenum
end

if @format = 'H'
begin
    print '<html>'
    print '<head>'
    print '<title> SAP ASE QUICK REFERENCE. </title>'
    print '</head>'
    print '<body>'
    print '<H1>ASE Quick reference </H1>'
    print '<H3>%1!</H3>', @@version
    print '<div style="text-align:center"><H3>Module: %1!</H3></div>', @module
    print '<hr SIZE=3 WIDTH="100%%"><br>'
    print '<a NAME="home"> </a>'

    select distinct '<br>' + ' <a HREF="#' + rtrim(commandname) + '">' +
    rtrim(commandname) + '</a>'
    from sybsyntax
    where module like @module
    order by commandname

    select '<br><hr SIZE=3 WIDTH="100%%"><br>'

    select case
            when linenum = 1 and len(commandname) >1
            then '<p>' + '<a NAME= "' +
                rtrim(commandname) + '"> </a>'  +
                '<b>'+  commandname  + '</b>' +
                '<a HREF=#home> H</a>'
            else '<br>'+ syntax
    end
    from sybsyntax
    where module like @module
    order by commandname, linenum

    select '<p><i>Created by sp_#quickref/<i></p></body>'
    select '</html>'
end
go
exec sp_procxmode sp_#quickref, "unchained"
go
/*************************************************************
 *  Grant permissions for the stored procedure
 *************************************************************/
grant execute on sp_#quickref to public
go

setuser
go
--eof
