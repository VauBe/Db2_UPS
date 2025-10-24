
--drop procedure IDUG.RUNSTATSTS;
@DELIMITER %%%;                                        
CREATE OR REPLACE PROCEDURE IDUG.RUNSTATSTS(                                                                          
         IN I_DBNAME CHAR(8) FOR SBCS DATA CCSID EBCDIC,
         IN I_TSNAME CHAR(8) FOR SBCS DATA CCSID EBCDIC
         , OUT RETCODE INTEGER
         , OUT LFDNR   INTEGER                              
        )                                                     
         VERSION V1                                                                     
         QUALIFIER IDUG                                        
         PACKAGE OWNER IDUG 
         DYNAMIC RESULT SETS 1 
        
LANGUAGE SQL
P1: BEGIN     
DECLARE utstmt VARCHAR(32704);
DECLARE iretcode integer;
DECLARE ilfdnr integer;
DECLARE utilid VARCHAR(16);
DECLARE filler integer;

declare c10 cursor with return for select lfdnr, retcode, seqno, text from utilprint 
where lfdnr = ilfdnr order by seqno asc;

SET utstmt =               'RUNSTATS TABLESPACE ' concat strip(I_DBNAME) concat '.' concat strip(I_TSNAME);
set utstmt = utstmt concat ' INDEX ALL UPDATE ALL REPORT YES ';

SET utilid = 'RS' concat strip(I_DBNAME) concat '.' concat strip(I_TSNAME);

call IDUG.DSNUTILU(utilid, 'NO', utstmt, iretcode);
set retcode = iretcode;

call IDUG.CN_UTILPROT(I_DBNAME, I_TSNAME, 'RUNSTATS', IRETCODE, ilfdnr); 
set lfdnr = ilfdnr;

call IDUG.TERMUTIL(utilid, filler);

open c10;
END P1
                            
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.RUNSTATSTS to public;

--drop procedure IDUG.RUNSTATSTB;
@DELIMITER %%%;                                        
CREATE OR REPLACE PROCEDURE IDUG.RUNSTATSTB(                                                                          
         IN I_SCHEMA varchar(128) FOR SBCS DATA CCSID EBCDIC,
         IN I_TBNAME varchar(128) FOR SBCS DATA CCSID EBCDIC
         , OUT RETCODE INTEGER     
         , OUT LFDNR   INTEGER                         
        )                                                     
         VERSION V1                                                                     
         QUALIFIER IDUG                                        
         PACKAGE OWNER IDUG 
         DYNAMIC RESULT SETS 1 
        
LANGUAGE SQL
P1: BEGIN     
DECLARE iretcode integer;
DECLARE ilfdnr integer;
DECLARE l_dbname varchar(24);
DECLARE l_tsname varchar(24);

declare sqlstate char(5) DEFAULT '00000';
declare code char(5) DEFAULT '00000';

declare c10 cursor with return for select lfdnr, retcode, seqno, text from utilprint 
where lfdnr = ilfdnr order by seqno asc;

declare f10 cursor with return for select '-1' as lfdnr, '8' as retcode, '1' as seqno, 'RUNSTATSTB: Table not found' as text from sysibm.sysdummy1;

select dbname, tsname into l_dbname, l_tsname from SYSIBM.SYSTABLES WHERE TYPE = 'T' AND CREATOR = upper(i_schema) and NAME = upper(i_tbname);

set code = sqlstate;
if (code != '00000') then
  set retcode = 8;
  set lfdnr   = '-1';
  open f10; -- Error Message
else
  call IDUG.RUNSTATSTS(l_dbname, l_tsname, iretcode, ilfdnr);
  set lfdnr = ilfdnr;
  set retcode = iretcode;
  open c10; -- Resultset
end if;
END P1
                            
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.RUNSTATSTB to public;

--
--drop function IDUG.RUNSTATSTS;
--drop function IDUG.wf_RUNSTATSTS;
--drop function IDUG.sf_RUNSTATSTS;
@DELIMITER %%%;  
create function IDUG.sf_RUNSTATSTS(DB char(8), TS char(8))
returns char(80)
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.RUNSTATSTS(DB, TS, iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><DB>' concat strip(db) concat '</DB><TS>' concat strip(TS) concat '</TS>';   
END P1
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.sf_RUNSTATSTS to public;

@DELIMITER %%%;  
create function IDUG.wf_RUNSTATSTS(DB char(8), TS char(8))
returns table (
retcode char(2),
lfdnr integer,
db      char(8),
ts      char(8) )
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<DB>') + length('<DB>'), strpos(erg, '</DB>') - strpos(erg, '<DB>') - length('<DB>')) as db
,      substr(erg, strpos(erg, '<TS>') + length('<TS>'), strpos(erg, '</TS>') - strpos(erg, '<TS>') - length('<TS>')) as ts
from  ( 
 select IDUG.sf_RUNSTATSTS(db, ts) as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.wf_RUNSTATSTS to public;

@DELIMITER %%%;
create function IDUG.RUNSTATSTS(DB char(8), TS char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
return
select fkt.retcode, fkt.lfdnr, fkt.db, fkt.ts, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_RUNSTATSTS(DB, TS)) fkt 
inner join IDUG.utilprint utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.RUNSTATSTS to public;

--
--drop function IDUG.RUNSTATSTB;
--drop function IDUG.wf_RUNSTATSTB;
--drop function IDUG.sf_RUNSTATSTB;
@DELIMITER %%%;  
create function IDUG.sf_RUNSTATSTB(ischema varchar(128), itbname varchar(128))
returns char(80)
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.RUNSTATSTB(ischema, itbname, iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><Q>' concat strip(ischema) concat '</Q><TB>' concat strip(itbname) concat '</TB>';   
END P1
%%%                 
@DELIMITER;%%%

GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.SF_RUNSTATSTB to public;    
            
--drop function IDUG.wf_RUNSTATSTB;
@DELIMITER %%%;  
create function IDUG.wf_RUNSTATSTB(ischema varchar(128), itbname varchar(128))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8) )
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<Q>') + length('<Q>'), strpos(erg, '</Q>') - strpos(erg, '<Q>') - length('<Q>')) as schema
,      substr(erg, strpos(erg, '<TB>') + length('<TB>'), strpos(erg, '</TB>') - strpos(erg, '<TB>') - length('<TB>')) as tbname
from  ( 
 select IDUG.sf_RUNSTATSTB(ischema, itbname) as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.WF_RUNSTATSTB to public;

@DELIMITER %%%;  
create function IDUG.RUNSTATSTB(ischema varchar(128), itbname varchar(128))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
return
select fkt.retcode, fkt.lfdnr, fkt.schema, fkt.tbname, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_RUNSTATSTB(ischema, itbname)) fkt 
inner join IDUG.utilprint utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.RUNSTATSTB to public;

