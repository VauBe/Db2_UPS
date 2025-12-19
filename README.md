# IBM Db2 Utility on Table Level Per Select and REST-Service
## What's new
2025.12.19 Procedures and Functions for STARTTB, STARTTS, STOPTB, STOPTS added (`/UPS_Install/UPS_04_START.SQL`, `/UPS_Install/UPS_04_STOP.SQL`)

## What and Why
While Applications and Developers think of Tables, Db2 z/OS and its Utilities use Tablespaces. At the latest when Developers issue an ALTER TABLE, the corresponding TABLESPACE should be REORGED.

To use a Db2 Utility you could either Call Stored Procedure SYSPROC.DSNUTILU provided by IBM or submit a batch job. Both require deeper knowledge in Db2 and z/OS, JCL etc. and beyond that CALL PROCEDURE is not supported in every client (like DSNTEP2, SPUFI).



We create Db2 SQL Stored Procedure as a wrapper to call **DSNUTILU** on **Db2 z/OS Tables**. This wrapper Stored Procedure we make available via **Db2 REST-Service** and we also create **functions** to include that wrapper in `SQL SELECT` in any SQL Client.

So you'll be able to use any SQL Client to e.g. **REORG TABLE** like

`ALTER TABLE schema.tablename ADD COLUMN XY INT; COMMIT;`

`SELECT * FROM TABLE(REORGTB('schema', 'tablename'));`

**Calling a Stored Procedure** - in our example Utilities - **becomes part of DDL / DML.** 

*Think of -DIS THREAD or -CANCEL using SQL and WHERE via ADMIN_COMMAND_DB2; use filtered Information from File using ADMIN_DS_BROWSE etc.*

Functions and endpoints on Tablespace Level are provided as well, of course.

`SELECT * FROM TABLE(REORGTS('databasename', 'tablespacename'));`

REST-Clients will POST to Db2 API Endpoint `https://db2-ip:db2-port/services/IDUGSVC/REORGTB` respective `../services/IDUGSVC/REORGTS`

Following "Utilities" are implemented  
* CHECK
* COPY
* DISPLAY
* QUIESCE
* REORG
* RUNSTATS
* START
* STOP

Each Utility is available on Table (TB) and Tablespace (TS) Level via SQL Function and REST-Endpoint.

Additionally **Crossload Utility** is available as function **XLOADFROMTO(sourcetable, targettable)**

## Installation
`/UPS_Install` DDL to create Tables, Procedures and Functions incl. IVP and DROP  
`/UPS_Install/RESTSVC` Python sample to create, use and drop REST-Services

## Sample Clients
Sample clients to use REST-Service are provided in `/clients`  
* **HTML** including small Python Flask App
* **Ansible**  .yml
* **Python** .py
* **Jupyter Notebook** .ipynb (also Python)
* **Powershell** .ps1
* **EXCEL** .xlsm
* **ZOWE** .txt (Call procedure and execute sql; no REST)

## General Information
### Stored Procedure
https://www.ibm.com/docs/en/db2-for-zos/13.0.0?topic=programs-creating-stored-procedures
* IN Parameter
* OUT Parameter
* INOUT Parameter
* You can call a SP in a Db2 Application Program, i.e. `CALL MYPROC(in1, in2, out1);`
* Result Set(s); 0-32767
* SP has a body
    * Declare Variables
    * Declare Cursor
    * Logic, SET Variable, execute SQL, Call Procedures
    * OPEN Cursors for Result Set
* SPs can be nested: SP1 can call SP2 and SP3 etc.
* When `autonomous` it has its **own transaction**
    * Can `COMMIT` although calling transaction issues `ROLLBACK`
    * “Fun fact”: Autonomous SP does not have any access to TEMP TABLEs of Calling Transaction!
* Application needs to `ASSOCIATE RESULT SET LOCATORS` and `ALLOCATE CURSOR FOR RESULT SET`
* **You CANNOT CALL a SP in Select / DML**
* Easily integrated in Db2 REST-Service
    * Create Service: `"sqlStmt": "call MYPROC(:IN1, :IN2, :OUT1)"`
* Creates Package TYPE='N' (Native SQL routine package)


### REST Service - Db2 as a REST-Server
https://www.ibm.com/docs/en/db2-for-zos/13.0.0?topic=db2-rest-services
* Create Service
    * Each Service can embed a single `CALL, DELETE, INSERT, SELECT, TRUNCATE, UPDATE or WITH SQL` Statement
    * Call SP: everthing is possible
        * Call REXX
        * Call Cobol
        * Native SQL
    * Creates a Package and entry in user-defined `SYSIBM.DSNSERVICE` Catalog table
    * POST to url /DB2ServiceManager
* Use Service
    * HTTP(S) POST to call new Service
    * GET unfortunately only shows Service Information; that's not HTTP-Standard
    * Endpoint and Variable Names CaseSensitive
* Possible Clients
    * Ansible using builtin.uri
    * curl (https://curl.se)
    * MS Excel Visual Basic
    * HTML
    * Python
    * Powershell
    * ServiceNow
        * We've created a REST-Service to deliver data from View
        * SN cannot access Db2
        * No further client needed
    * Db2 as a Client using function db2xml.httppostclob
        * in our case maybe questionable (db2 client to call db2 service...)
        * maybe interesting instead of Remote Db2 (DRDA)

### DSNUTILU
https://www.ibm.com/docs/en/db2-for-zos/13.0.0?topic=db2-dsnutilu
* DSNUTILU SP to run Db2 utilities from **Db2 application program**.
    * DSNUTILS SP **deprecated**
    * DSNUTILV SP like DSNUTILU, supports Statements larger than 32KB up to 2 GB
* Returncode is stored in OUT Parameter `retcode` integer
* Declares and opens a cursor to select from SYSPRINT
    * Application needs to `ASSOCIATE RESULT SET LOCATORS` and `ALLOCATE CURSOR FOR RESULT SET`


### Functions
* Scalar Function 
https://www.ibm.com/docs/en/db2-for-zos/13.0.0?topic=statements-create-function-inlined-sql-scalar
    * can return a single value each time it is invoked
    * can have a body like procedure with `BEGIN` and `END`
    * Creates Package TYPE='F'; e.g. IDUG.SF_REORGTB.V1
    

* SQL Table Function
https://www.ibm.com/docs/en/db2-for-zos/13.0.0?topic=statements-create-function-sql-table
    * Returns a set of rows
    * Can return more than one value / column; it returns a table
    * Body limited to `RETURN statement`
    * `RETURN CALL Procedure` seams to look nice, but it doesn't work
    * No Package; in contrast to Scalar Function (and Procedures)




### Ingredients - Parts of the solution
- Copy of DSNUTILU (because of DROP in DSNTIJRT)
- SP as Wrapper for DSNUTILU (e.g. SP REORGTS) for Tablespace
- SP takes Table and calls Wrapper
- REST Services for Tablespace SP and Table SP
- Table to store Call-Protocol (one entry each)
- Table to store Utility-Sysout
- Autonomous SP to store protocol
- Autonomous SP to store Utility-Sysout / Joblog
- Scalar Function to call SP in SQL returning Protocol-Info
- Table Function to Select Values from Scalar Function as Table
- Table Function to Select from Table Function JOIN Utility-Sysout-Table



### Problem
- User has Data in Db2 z/OS and has zero knowledge about Tablespaces and Utilities
    - User unable to navigate and edit in TSO / ISPF / Tools
    - User unable to submit JCL and use SDSF
- User might think about E2E-Responsibilty but has limited z-skills and tools
- We want to automate more DDL in development, generate and use SQL also for remote clients; no JCL directly available in TOAD, DB Visualizer, Db2 CLI etc.
- Datawarehouse (DWH) Workload with massive Inserts, Delete, Updates require "ad hoc" Reorgs during Process for better performance
