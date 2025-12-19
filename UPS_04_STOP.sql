--drop procedure IDUG.STOPTS;
@DELIMITER %%%;                                        
CREATE OR REPLACE  PROCEDURE IDUG.STOPTS(                                                                          
           IN I_DB CHAR(8) FOR SBCS DATA CCSID EBCDIC
         , IN I_TS CHAR(8) FOR SBCS DATA CCSID EBCDIC
         , OUT RETCODE INTEGER   
         , OUT LFDNR INTEGER                           
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
DECLARE fehler CHAR(1);
--DECLARE utilid VARCHAR(16);

DECLARE o_commands_ex integer;
DECLARE o_ifirc integer;
DECLARE o_ifirr integer;
DECLARE o_ex_bytes integer;
DECLARE o_grp_ifirc integer;
DECLARE o_grp_ex_bytes integer;
DECLARE o_rc integer;
DECLARE o_message varchar(1331);


--declare c10 cursor with return for select seqno, text from sysibm.sysprint order by seqno asc;
declare c10 cursor with return for select lfdnr, retcode, seqno, text from IDUG.adb_cmd_output 
where lfdnr = ilfdnr order by seqno asc;

SET utstmt =               '-STOP DATABASE(' concat strip(I_DB) concat ') SPACENAM(' concat strip(I_TS) concat ') ';

DELETE from SYSIBM.DB2_CMD_OUTPUT;
call IDUG.ADMIN_COMMAND_DB2(utstmt, length(utstmt), ' ','', 
                                 o_commands_ex
                               , o_ifirc
                               , o_ifirr
                               , o_ex_bytes
                               , o_grp_ifirc
                               , o_grp_ex_bytes
                               , o_rc
                               , o_message);
set retcode = o_rc;
call IDUG.CN_CMDPROT(utstmt, o_rc, ilfdnr);
set lfdnr = ilfdnr;
open c10;
END P1
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.STOPTS to public;


--drop procedure IDUG.STOPTB;
@DELIMITER %%%;                                        
CREATE OR REPLACE PROCEDURE IDUG.STOPTB(                                                                          
           IN I_SCHEMA varchar(128) FOR SBCS DATA CCSID EBCDIC
         , IN I_TBNAME varchar(128) FOR SBCS DATA CCSID EBCDIC
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

--declare c10 cursor with return for select seqno, text from sysibm.sysprint order by seqno asc;
declare c10 cursor with return for select lfdnr, retcode, seqno, text from adb_cmd_output 
where lfdnr = ilfdnr order by seqno asc;

declare f10 cursor with return for select '-1' as lfdnr, '8' as retcode, '1' as seqno, 'STOPTB: Tabelle nicht gefunden' as text from sysibm.sysdummy1;

select dbname, tsname into l_dbname, l_tsname from SYSIBM.SYSTABLES WHERE TYPE = 'T' AND CREATOR = upper(i_schema) and NAME = upper(i_tbname);

set code = sqlstate;
if (code != '00000') then
  set retcode = 8;
  set lfdnr   = '-1';
  open f10; -- Fehlermeldung
else
  call IDUG.STOPTS(l_dbname, l_tsname, iretcode, ilfdnr);
  set lfdnr = ilfdnr;
  set retcode = iretcode;
  open c10; -- Resultset
end if;
END P1
                            
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.STOPTB to public;

--

--drop specific function IDUG.STOPTS;
--drop specific function IDUG.wf_STOPTS;
--drop specific function IDUG.SF_STOPTS; --IDUG.sf_STOPTB;
--drop specific function IDUG.SF_STOPTB;

-- hier für 2PARM
@DELIMITER %%%;  
create function IDUG.sf_STOPTS(DB char(8), TS char(8))
returns char(80)
--SPECIFIC SF_STOPTS_2PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.STOPTS(DB, TS, iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><DB>' concat strip(db) concat '</DB><TS>' concat strip(TS) concat '</TS>';   
END P1
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.sf_STOPTS to public;

@DELIMITER %%%;  
create function IDUG.wf_STOPTS(DB char(8), TS char(8))
returns table (
retcode char(2),
--lfdnr   char(2),
lfdnr integer,
db      char(8),
ts      char(8) )
--SPECIFIC WF_STOPTS_2PARM
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
--,      substr(erg, strpos(erg, '<LFDNR>') + length('<LFDNR>'), strpos(erg, '</LFDNR>') - strpos(erg, '<LFDNR>') - length('<LFDNR>')) as lfdnr
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<DB>') + length('<DB>'), strpos(erg, '</DB>') - strpos(erg, '<DB>') - length('<DB>')) as db
,      substr(erg, strpos(erg, '<TS>') + length('<TS>'), strpos(erg, '</TS>') - strpos(erg, '<TS>') - length('<TS>')) as ts
from  ( 
 select IDUG.sf_STOPTS(db, ts) as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
grant execute on function IDUG.wf_STOPTS to public;

@DELIMITER %%%;
create function IDUG.STOPTS(DB char(8), TS char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
--SPECIFIC STOPTS_2PARM
return
select fkt.retcode, fkt.lfdnr, fkt.db, fkt.ts, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_STOPTS(DB, TS)) fkt 
inner join IDUG.tzdb_cmd_output utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON FUNCTION IDUG.STOPTS to public;


--
--drop specific function IDUG.STOPTB;
--drop specific function IDUG.wf_STOPTB;
--drop specific function IDUG.SF_STOPTB; --IDUG.sf_STOPTB;

@DELIMITER %%%;  
create function IDUG.sf_STOPTB(ischema varchar(128), itbname varchar(128))
returns char(80)
--SPECIFIC SF_STOPTB_2PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.STOPTB(ischema, itbname, iretcode, ilfdnr);
--call IDUG.STOPTB(ischema, itbname, opt, iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><Q>' concat strip(ischema) concat '</Q><TB>' concat strip(itbname) concat '</TB>';   
END P1
%%%                 
@DELIMITER;%%%

GRANT EXECUTE ON FUNCTION IDUG.SF_STOPTB to public;    
    

@DELIMITER %%%;  
create function IDUG.wf_STOPTB(ischema varchar(128), itbname varchar(128))
returns table (
retcode char(2),
--lfdnr   char(2),
lfdnr integer,
schema      char(8),
tbname      char(8) )
--specific wf_STOPTB_2parm
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
--,      substr(erg, strpos(erg, '<LFDNR>') + length('<LFDNR>'), strpos(erg, '</LFDNR>') - strpos(erg, '<LFDNR>') - length('<LFDNR>')) as lfdnr
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<Q>') + length('<Q>'), strpos(erg, '</Q>') - strpos(erg, '<Q>') - length('<Q>')) as schema
,      substr(erg, strpos(erg, '<TB>') + length('<TB>'), strpos(erg, '</TB>') - strpos(erg, '<TB>') - length('<TB>')) as tbname
from  ( 
 select IDUG.sf_STOPTB(ischema, itbname) as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON FUNCTION IDUG.WF_STOPTB to public;

@DELIMITER %%%;  
create function IDUG.STOPTB(ischema varchar(128), itbname varchar(128))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
--specific STOPTB_2parm
return
select fkt.retcode, fkt.lfdnr, fkt.schema, fkt.tbname, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_STOPTB(ischema, itbname)) fkt 
inner join IDUG.tzdb_cmd_output utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON FUNCTION IDUG.STOPTB to public;

