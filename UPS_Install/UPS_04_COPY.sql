
-- Change Default HLQ in DSN: UE2
-- Change Schema: IDUG


--drop procedure IDUG.COPYTS;
@DELIMITER %%%;                                        
CREATE OR REPLACE  PROCEDURE IDUG.COPYTS(                                                                          
           IN I_DBNAME CHAR(8) FOR SBCS DATA CCSID EBCDIC
         , IN I_TSNAME CHAR(8) FOR SBCS DATA CCSID EBCDIC
         , IN I_HLQ    CHAR(8) FOR SBCS DATA CCSID EBCDIC
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
DECLARE hlq char(8);
DECLARE hk char(3);
DECLARE dsn char(80);

declare c10 cursor with return for select lfdnr, retcode, seqno, text from utilprint 
where lfdnr = ilfdnr order by seqno asc;

-- when using DSN with e.g. (3) like substr(part) whole DSN must be quoted
-- Syntax with quotes sucks, so it's fix once
-- change 'X' on demand
set dsn = '''X.&SS..&DB..&TS..P&PA(3)..J&JDAY..T&TI.''';

-- When I_HLQ is set, use it as HLQ ;-)
CASE STRIP(UPPER(I_HLQ))
 WHEN ''
  THEN set dsn = replace(dsn, 'X', 'UE2') ; -- HLQ Default
 WHEN ' ' 
  THEN set dsn = replace(dsn, 'X', 'UE2') ; -- HLQ Default
 ELSE 
       set dsn = replace(dsn, 'X', trim(UPPER(i_hlq)));
END CASE;


set utstmt = ' TEMPLATE TCOPY DSN ' concat dsn concat ' DISP(NEW,CATLG,CATLG) DATACLAS(STMVOL)';

set utstmt = utstmt concat ' LISTDEF COPLIST INCLUDE TABLESPACE ' concat strip(I_DBNAME) concat '.' concat strip(I_TSNAME) concat ' PARTLEVEL';
set utstmt = utstmt concat ' LISTDEF MODLIST INCLUDE TABLESPACE ' concat strip(I_DBNAME) concat '.' concat strip(I_TSNAME);

SET utstmt = utstmt concat ' COPY LIST COPLIST '  ;
set utstmt = utstmt concat ' COPYDDN TCOPY ';
set utstmt = utstmt concat ' SHRLEVEL CHANGE ';

set utstmt = utstmt concat ' MODIFY RECOVERY LIST COPLIST DELETE AGE(50) DELETEDS '; -- Modify PARTLEVEL
set utstmt = utstmt concat ' MODIFY RECOVERY LIST MODLIST DELETE AGE(50) DELETEDS '; -- Modify PART 0


SET utilid = 'CP' concat strip(I_DBNAME) concat '.' concat strip(I_TSNAME);

call IDUG.DSNUTILU(utilid, 'NO', utstmt, iretcode);
set retcode = iretcode;

call IDUG.CN_UTILPROT(I_DBNAME, I_TSNAME, 'COPY', IRETCODE, ilfdnr); 
set lfdnr = ilfdnr;

call IDUG.TERMUTIL(utilid, filler);

open c10;
END P1
                            
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.COPYTS to public;


--drop procedure IDUG.COPYTB;
@DELIMITER %%%;                                        
CREATE OR REPLACE PROCEDURE IDUG.COPYTB(                                                                          
           IN I_SCHEMA varchar(128) FOR SBCS DATA CCSID EBCDIC
         , IN I_TBNAME varchar(128) FOR SBCS DATA CCSID EBCDIC
         , IN I_HLQ CHAR(8)  FOR SBCS DATA CCSID EBCDIC
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

declare f10 cursor with return for select '-1' as lfdnr, '8' as retcode, '1' as seqno, 'COPYTB: Table not found' as text from sysibm.sysdummy1;

select dbname, tsname into l_dbname, l_tsname from SYSIBM.SYSTABLES WHERE TYPE = 'T' AND CREATOR = upper(i_schema) and NAME = upper(i_tbname);

set code = sqlstate;
if (code != '00000') then
  set retcode = 8;
  set lfdnr   = '-1';
  open f10; -- Error Message
else
  call IDUG.COPYTS(l_dbname, l_tsname, i_hlq, iretcode, ilfdnr);
  set lfdnr = ilfdnr;
  set retcode = iretcode;
  open c10; -- Resultset
end if;
END P1
                            
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.COPYTB to public;

--
--drop function IDUG.COPYTS_3parm;
--drop function IDUG.COPYTS_2parm;
--drop function IDUG.wf_COPYTS_3parm;
--drop function IDUG.wf_COPYTS_2parm;
--drop function IDUG.sf_COPYTS_3parm;
--drop function IDUG.sf_COPYTS_2parm;
@DELIMITER %%%;  
create function IDUG.sf_COPYTS(DB char(8), TS char(8), HLQ char(8))
returns char(80)
SPECIFIC SF_COPYTS_3PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.COPYTS(DB, TS, HLQ, iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><DB>' concat strip(db) concat '</DB><TS>' concat strip(TS) concat '</TS>';   
END P1
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.sf_COPYTS_3parm to public;


@DELIMITER %%%;  
create function IDUG.sf_COPYTS(DB char(8), TS char(8))
returns char(80)
SPECIFIC SF_COPYTS_2PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.COPYTS(DB, TS, '', iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><DB>' concat strip(db) concat '</DB><TS>' concat strip(TS) concat '</TS>';   
END P1
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.sf_COPYTS_2parm to public;

@DELIMITER %%%;  
create function IDUG.wf_COPYTS(DB char(8), TS char(8), HLQ char(8))
returns table (
retcode char(2),
lfdnr integer,
db      char(8),
ts      char(8) )
specific wf_COPYTS_3parm
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<DB>') + length('<DB>'), strpos(erg, '</DB>') - strpos(erg, '<DB>') - length('<DB>')) as db
,      substr(erg, strpos(erg, '<TS>') + length('<TS>'), strpos(erg, '</TS>') - strpos(erg, '<TS>') - length('<TS>')) as ts
from  ( 
 select IDUG.sf_COPYTS(db, ts, HLQ) as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.wf_COPYTS_3parm to public;

@DELIMITER %%%;  
create function IDUG.wf_COPYTS(DB char(8), TS char(8))
returns table (
retcode char(2),
lfdnr integer,
db      char(8),
ts      char(8) )
specific wf_COPYTS_2parm
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<DB>') + length('<DB>'), strpos(erg, '</DB>') - strpos(erg, '<DB>') - length('<DB>')) as db
,      substr(erg, strpos(erg, '<TS>') + length('<TS>'), strpos(erg, '</TS>') - strpos(erg, '<TS>') - length('<TS>')) as ts
from  ( 
 select IDUG.sf_COPYTS(db, ts, '') as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.wf_COPYTS_2parm to public;

@DELIMITER %%%;
create function IDUG.COPYTS(DB char(8), TS char(8), HLQ char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
specific COPYTS_3parm
return
select fkt.retcode, fkt.lfdnr, fkt.db, fkt.ts, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_COPYTS(DB, TS, HLQ)) fkt 
inner join IDUG.utilprint utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.COPYTS_3parm to public;

@DELIMITER %%%;
create function IDUG.COPYTS(DB char(8), TS char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
specific COPYTS_2parm
return
select fkt.retcode, fkt.lfdnr, fkt.db, fkt.ts, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_COPYTS(DB, TS, '')) fkt 
inner join IDUG.utilprint utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.COPYTS_2parm to public;

--
--drop specific function IDUG.copytb_3parm;
--drop specific function IDUG.copytb_2parm;
--drop specific function IDUG.wf_copytb_3parm;
--drop specific function IDUG.wf_copytb_2parm;
--drop specific function IDUG.SF_copyTB_3PARM; --IDUG.sf_copytb;
--drop specific function IDUG.SF_copyTB_2PARM;
--drop specific function IDUG.SF_copyTB;
@DELIMITER %%%;  
create function IDUG.sf_copytb(ischema varchar(128), itbname varchar(128) , hlq char(8))
returns char(80)
SPECIFIC SF_copyTB_3PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.copytb(ischema, itbname, hlq, iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><Q>' concat strip(ischema) concat '</Q><TB>' concat strip(itbname) concat '</TB>';   
END P1
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.SF_copyTB_3PARM to public;

@DELIMITER %%%;  
create function IDUG.sf_copytb(ischema varchar(128), itbname varchar(128))
returns char(80)
SPECIFIC SF_copyTB_2PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.copytb(ischema, itbname, '', iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><Q>' concat strip(ischema) concat '</Q><TB>' concat strip(itbname) concat '</TB>';   
END P1
%%%                 
@DELIMITER;%%%

GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.SF_copyTB_2PARM to public;    
            

--drop function IDUG.wf_copytb;
@DELIMITER %%%;  
create function IDUG.wf_copytb(ischema varchar(128), itbname varchar(128), hlq char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8) )
specific wf_copytb_3parm
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<Q>') + length('<Q>'), strpos(erg, '</Q>') - strpos(erg, '<Q>') - length('<Q>')) as schema
,      substr(erg, strpos(erg, '<TB>') + length('<TB>'), strpos(erg, '</TB>') - strpos(erg, '<TB>') - length('<TB>')) as tbname
from  ( 
 select IDUG.sf_copytb(ischema, itbname, hlq) as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.WF_copyTB_3parm to public;

@DELIMITER %%%;  
create function IDUG.wf_copytb(ischema varchar(128), itbname varchar(128))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8) )
specific wf_copytb_2parm
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<Q>') + length('<Q>'), strpos(erg, '</Q>') - strpos(erg, '<Q>') - length('<Q>')) as schema
,      substr(erg, strpos(erg, '<TB>') + length('<TB>'), strpos(erg, '</TB>') - strpos(erg, '<TB>') - length('<TB>')) as tbname
from  ( 
 select IDUG.sf_copytb(ischema, itbname, '') as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.WF_copyTB_2parm to public;

@DELIMITER %%%;  
create function IDUG.copytb(ischema varchar(128), itbname varchar(128), hlq char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
specific copytb_3parm
return
select fkt.retcode, fkt.lfdnr, fkt.schema, fkt.tbname, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_copytb(ischema, itbname, hlq)) fkt 
inner join IDUG.utilprint utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.copyTB_3parm to public;

@DELIMITER %%%;  
create function IDUG.copytb(ischema varchar(128), itbname varchar(128))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
specific copytb_2parm
return
select fkt.retcode, fkt.lfdnr, fkt.schema, fkt.tbname, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_copytb(ischema, itbname, '')) fkt 
inner join IDUG.utilprint utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.copyTB_2parm to public;

