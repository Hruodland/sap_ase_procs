# sap_ase_procs
SAP (Sybase) ASE  A Collection of database admin &amp; development  procedures, queries and snippets.

**Status:** Work in progress.



---


|   Name         |  Type         | Descrption       |
| :------------- |:------------  | :-----------------|
| sp_#quickref   | StoredProc    | Generate quick reference in ascii or HTML format from sybsyntax|
| sp_#select     | StoredProc    | Generate a select statement list for a table |
| sp_#ls         | StoredProc    | List database object names by pattern or type|
| sp_#ps         | StoredProc    | Display processes not my spid or system |





### Additional notes:

#### sp_#quickref

  > Execute this as dbo for database sybsyntax (The database has to be installed but can be dropped one you generated the documents.)

#### sp_#select
  > Generates select columns in alphabetic order.(limit to 255 characters).

```sql
--Example:
use pubs2
go
sp_#select authors
go
--Result:
select                                                                                                                                                                                                                                                          
   address                                                                                                                                                                                                                                                       
  ,au_fname                                                                                                                                                                                                                                                      
  ,au_id                                                                                                                                                                                                                                                         
  ,au_lname                                                                                                                                                                                                                                                      
  ,city                                                                                                                                                                                                                                                          
  ,country                                                                                                                                                                                                                                                       
  ,phone                                                                                                                                                                                                                                                         
  ,postalcode                                                                                                                                                                                                                                                    
  ,state                                                                                                                                                                                                                                                         
from authors   

```
---
