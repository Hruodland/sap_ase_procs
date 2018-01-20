/* vim: set ts=2 sw=4 tw=0 et :*/
-- @(#) sp_#select <tablename>: generate select statement with all columns
use sybsystemprocs
go
setuser "dbo"
go

print 'Installing PROCEDURE: sp_#select'
go


create or replace  procedure sp_#select ( 
    @tabel char(30) 
)  
as 
/* 
#----------------------------------------------------------------------
Author: Roland van Veen
#----------------------------------------------------------------------
Procedure   : sp_#select
Description : Generates a select list for a table in alphabetic order.
Usage       : sp_#select <table_name>
Parameters  : 1 @tabel  : Name of the table.
Result      : Resultset with a Select command representation.
Errorcodes  : Returns 1: Invalid parameter value(s)
License     : MIT   
Conditions
  Pre       : You must be in the database where the table exists.
Dependency  : SAP ASE 16.0 (may work with none or few modifications on older versions)
Tables      : #msg: Temporary work table
Note(s)     : Formats select with leading. 
Date        Revision  What
-------------------------------------------------------------------
2018-01-18  1.0       Created from older snippets, fixed extra comma issue.
-------------------------------------------------------------------
*******************************************************************
*/ 
 
declare 
    @m char(30),  
    @msg varchar(255),  
    @newmsg varchar(255),  
    @crlf char(1), 
    @rowc int,
    @tab char(1)  

set nocount on 
 
if (object_id (@tabel) is null)  
begin 
    print 'Table is undefined.' 
    return 
end 

select @msg = '' , @crlf = char(10), @tab = char(9)  , @rowc=0

create table #msg
( line varchar(255)
)

select @m = min(name)  
from syscolumns 
where syscolumns.id = object_id(@tabel) 

 
--Build  list of column names with ,
while (@m is not null) 
begin 
    select @newmsg = rtrim(name) 
    from  syscolumns 
    where syscolumns.id = object_id(@tabel) 
    and   syscolumns.name = @m 

    if @rowc > 0 
    begin
      select @newmsg=','+ @newmsg
    end
    else
    begin
      select @newmsg=' '+ @newmsg
    end
 
    insert into #msg values (@newmsg)
    select @m = min(name)  , @rowc = @rowc +1
    from  syscolumns 
    where syscolumns.id = object_id(@tabel) 
    and   syscolumns.name > @m 
end 

--Present Resultset
select 'select' cmd
union all 
select '  '+line  cmd   
from   #msg
union all 
select 'from ' + @tabel cmd

 
set nocount off 
go

exec sp_procxmode sp_#select, "unchained"
go
grant all on sp_#select to public
go

--eof

