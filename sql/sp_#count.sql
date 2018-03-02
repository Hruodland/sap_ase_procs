/* @(#) sp_#count [objectname pattern] */
/* vim: set ts=2 sw=2 tw=0 et :*/


use sybsystemprocs
go
print 'Installing PROCEDURE: sp_#count'
go

create or replace proc sp_#count
as
/*
#----------------------------------------------------------------------
Author: Roland van Veen
#----------------------------------------------------------------------
Procedure   : sp_#count
Description : Present a simple rowcount, size of table and indexes in current database to get a quick
              understanding on the sizing of a whole database.
Usage       : sp_#count
Parameters  : -
Result      : Resultset showing table name (truncated) ) table data and index pages size.
              Clustered index size is seen as table size. Index pages are for none clustered or text/image indexes.
Errorcodes  : -
Example	    : sp_#count
License     : MIT
Conditions
  Pre       :  -
Dependency  : SAP ASE 16.0 (may work with none or few modifications on older versions)
Tables      : -#indexdata temporary table
Note(s)     :
Date        Revision  What
-------------------------------------------------------------------
2018-03-02  1.0        Created
-------------------------------------------------------------------
*******************************************************************
*/
begin
  set nocount on

  declare @dbid integer
  select  @dbid = db_id()

  select o.id as iid ,sum(data_pages(@dbid,o.id,i.indid)) as idata
  into   #indexdata
  from   sysobjects o
  inner join sysindexes i
  on     o.id=i.id
  where  o.id > 99
  and    o.type = 'U'
  and    i.indid > 1 -- skip table/clustered indexes.
  group by o.id

  select "Table" = left(object_name(id),30)
        ,"Rows" = sum(row_count(@dbid,id))
        ,"Data (Mb)" = str(SUM(data_pages(@dbid,id) * (@@pagesize/1024)), 8,2)
        ,"Idx  (Mb))" = str(SUM(idata  * (@@pagesize/1024)), 8,2)
        ,"Total(Mb))" = str(SUM( (isnull(idata,0) + isnull(data_pages(@dbid,id),0))  * (@@pagesize/1024)), 8,2)
  from   sysobjects
  left outer join #indexdata
  on     sysobjects.id=#indexdata.iid
  where  id > 99
  and    type = 'U'
  group  by id
  order by 1

  return(0)
end
go
if object_id('sp_#count') IS NOT NULL
    begin
    print 'sp_#cout created'
    exec  sp_procxmode 'sp_#count', 'anymode'
    grant execute on sp_#count to public
    end
go
setuser
go
--eof

