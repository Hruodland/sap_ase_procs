# sap_ase_procs
SAP (Sybase) ASE  A Collection of database admin &amp; development  procedures, queries and snippets.

Last tested on ASE 16.0, may work in older versions.


**License**: MIT

---


**Tools**

|   Name         |  Type         | Description       |
| :------------- |:------------  | :-----------------|
| sp_#count      | StoredProc    | Quick overview of table and index sizing. |
| sp_#ls         | StoredProc    | List database object names by pattern or type|
| sp_#ps         | StoredProc    | Display processes not my spid or system |
| sp_#top        | StoredProc    | Display top 10 processes by cpu; for ansi terminals |
| sp_#quickref   | StoredProc    | Generate quick reference in ascii or HTML format from sybsyntax|
| sp_#select     | StoredProc    | Generate a select statement list for a table |


**Templates**

|   Name         |  Type         | Description       |
| :------------- |:------------  | :-----------------|
| sp_thresholdaction| StoredProc | Example for free space threshold procedure.|

**Scripts**

|   Name         |  Type         | Description       |
| :------------- |:------------  | :-----------------|
| sqlmarker.awk  | awk script    | Add markers to sql batches.|


## Shapes
Added a shape collection for LibreDraw for drawing server/database/replication diagrams.
(Shapes are taken from already existing sources).

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


### sp_thresholdaction
Example of a free space threshold procedure of medium complexity.
It dumps log (sometimes database)  to an emergency location for last chance thresholds, otherwise prints messages to the log.
You need to change the dump location in the code (and or or create a symbolic link on linux for the emergency dump directory).

### sp_#count

As a DBA  I like  to get  an quick but not 100% accurate overview of which tables are small and which are huge related to storage space and number of rows.


Example:

|Table                         |Rows                                     |Data (Mb)|Idx  (Mb))|Total(Mb))
|------------------------------|-----------------------------------------|---------|----------|----------
|au_pix                        |                                        6|  254.00 |  252.00  |  506.00  
|authors                       |                                       23|    6.00 |    2.00  |    8.00  
|blurbs                        |                                        6|   16.00 |   14.00  |   30.00  
|discounts                     |                                        4|    2.00 |NULL      |    2.00  
|footab                        |                                        0|    2.00 |NULL      |    2.00  
|publishers                    |                                        3|    4.00 |NULL      |    4.00  
|roysched                      |                                       87|    6.00 |    2.00  |    8.00  
|sales                         |                                       30|    4.00 |NULL      |    4.00  
|salesdetail                   |                                      116|   18.00 |   12.00  |   30.00  
|stores                        |                                        7|    2.00 |NULL      |    2.00  
|titleauthor                   |                                       25|    8.00 |    4.00  |   12.00  
|titles                        |                                       18|    8.00 |    2.00  |   10.00  


### sqlmarker.awk
Can be used for T-SQL , but any other SQL dialect in batches as well with few changes.

---
