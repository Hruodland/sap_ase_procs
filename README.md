# sap_ase_procs
SAP (Sybase) ASE  A Collection of database admin &amp; development  procedures, queries and snippets.

Last tested on ASE 16.0, may work in older versions.


**License**: MIT



---


|   Name         |  Type         | Descrption       |
| :------------- |:------------  | :-----------------|
| sp_#quickref   | StoredProc    | Generate quick reference in ascii or HTML format from sybsyntax|
| sp_#select     | StoredProc    | Generate a select statement list for a table |
| sp_#ls         | StoredProc    | List database object names by pattern or type|
| sp_#ps         | StoredProc    | Display processes not my spid or system |
| sp_#top        | StoredProc    | Display top 10 processes by cpu; for ansi terminals |



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


### sp_#top
>Emulates Linux 'top'command by cpu usage , run it only in a terminal on linux (isql or sqsh) Kill wth CTRL+C.
>Displays optionally plan for first process.


### sp_#ls

List objects by type, sp_#ls U lists User tables for example;
Use type SP to refer to system prcoedures.


### sp_#ps

Alternative for sp_who, lists blocks as well.


---
