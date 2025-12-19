--drop procedure IDUG.STARTTS;
@DELIMITER %%%;                                        
CREATE OR REPLACE  PROCEDURE IDUG.STARTTS(                                                                          
           IN I_DB CHAR(8) FOR SBCS DATA CCSID EBCDIC
         , IN I_TS CHAR(8) FOR SBCS DATA CCSID EBCDIC
         , IN I_OPT CHAR(8) FOR SBCS DATA CCSID EBCDIC
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

-- Fehlermeldung
declare f10 cursor with return for select '-1' as lfdnr, '8' as retcode, '1' as seqno, 'STARTTS: OPT nicht gefunden' as text from sysibm.sysdummy1;
SET fehler = '0'; -- erstmal alles gut, kein Fehler

SET utstmt =               '-START DATABASE(' concat strip(I_DB) concat ') SPACENAM(' concat strip(I_TS) concat ') ';

CASE STRIP(UPPER(I_OPT))
 WHEN ''
  THEN SET utstmt = utstmt;
 WHEN ' ' 
  THEN SET utstmt = utstmt;
 WHEN 'RO'
  THEN SET utstmt = utstmt concat 'ACCESS(RO)';
 WHEN 'RW'
  THEN SET utstmt = utstmt concat 'ACCESS(RW)';
 WHEN 'UT'
  THEN SET utstmt = utstmt concat 'ACCESS(UT)';
 WHEN 'FORCE'
  THEN SET utstmt = utstmt concat 'ACCESS(FORCE)';
 ELSE SET fehler = '1' ;
END CASE;
  
--SET utstmt = utstmt concat ' LIMIT( 500 )';

if fehler = '0' then
  DELETE from SYSIBM.DB2_CMD_OUTPUT;
  --call SYSPROC.DSNUTILU(utilid, 'NO', utstmt, iretcode);
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
else
  set retcode = 8;
  set lfdnr = -1;
  open f10; -- Fehlermeldung
end if;
END P1
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.STARTTS to public;


--drop procedure IDUG.STARTTB;
@DELIMITER %%%;                                        
CREATE OR REPLACE PROCEDURE IDUG.STARTTB(                                                                          
           IN I_SCHEMA varchar(128) FOR SBCS DATA CCSID EBCDIC
         , IN I_TBNAME varchar(128) FOR SBCS DATA CCSID EBCDIC
         , IN I_OPT CHAR(8) FOR SBCS DATA CCSID EBCDIC
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

declare f10 cursor with return for select '-1' as lfdnr, '8' as retcode, '1' as seqno, 'STARTTB: Tabelle nicht gefunden' as text from sysibm.sysdummy1;

select dbname, tsname into l_dbname, l_tsname from SYSIBM.SYSTABLES WHERE TYPE = 'T' AND CREATOR = upper(i_schema) and NAME = upper(i_tbname);

set code = sqlstate;
if (code != '00000') then
  set retcode = 8;
  set lfdnr   = '-1';
  open f10; -- Fehlermeldung
else
  call IDUG.STARTTS(l_dbname, l_tsname, i_opt, iretcode, ilfdnr);
  set lfdnr = ilfdnr;
  set retcode = iretcode;
  open c10; -- Resultset
end if;
END P1
                            
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.STARTTB to public;

--

--drop specific function IDUG.STARTTS_3parm;
--drop specific function IDUG.STARTTS_2parm;
--drop specific function IDUG.wf_STARTTS_3parm;
--drop specific function IDUG.wf_STARTTS_2parm;
--drop specific function IDUG.SF_STARTTS_3PARM; --IDUG.sf_STARTTB;
--drop specific function IDUG.SF_STARTTS_2PARM;
--drop specific function IDUG.SF_STARTTS;
@DELIMITER %%%;  
create function IDUG.sf_STARTTS(DB char(8), TS char(8), OPT char(8))
returns char(80)
SPECIFIC SF_STARTTS_3PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.STARTTS(DB, TS, OPT, iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><DB>' concat strip(db) concat '</DB><TS>' concat strip(TS) concat '</TS>';   
END P1
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.sf_STARTTS_3PARM to public;

@DELIMITER %%%;  
create function IDUG.wf_STARTTS(DB char(8), TS char(8), OPT char(8))
returns table (
retcode char(2),
--lfdnr   char(2),
lfdnr integer,
db      char(8),
ts      char(8) )
SPECIFIC WF_STARTTS_3PARM
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
--,      substr(erg, strpos(erg, '<LFDNR>') + length('<LFDNR>'), strpos(erg, '</LFDNR>') - strpos(erg, '<LFDNR>') - length('<LFDNR>')) as lfdnr
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<DB>') + length('<DB>'), strpos(erg, '</DB>') - strpos(erg, '<DB>') - length('<DB>')) as db
,      substr(erg, strpos(erg, '<TS>') + length('<TS>'), strpos(erg, '</TS>') - strpos(erg, '<TS>') - length('<TS>')) as ts
from  ( 
 select IDUG.sf_STARTTS(db, ts, opt) as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.wf_STARTTS_3PARM to public;

@DELIMITER %%%;
create function IDUG.STARTTS(DB char(8), TS char(8), OPT char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
SPECIFIC STARTTS_3PARM
return
select fkt.retcode, fkt.lfdnr, fkt.db, fkt.ts, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_STARTTS(DB, TS, OPT)) fkt 
inner join IDUG.tzdb_cmd_output utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.STARTTS_3PARM to public;


-- hier für 2PARM
@DELIMITER %%%;  
create function IDUG.sf_STARTTS(DB char(8), TS char(8))
returns char(80)
SPECIFIC SF_STARTTS_2PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.STARTTS(DB, TS, '', iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><DB>' concat strip(db) concat '</DB><TS>' concat strip(TS) concat '</TS>';   
END P1
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.sf_STARTTS_2PARM to public;

@DELIMITER %%%;  
create function IDUG.wf_STARTTS(DB char(8), TS char(8))
returns table (
retcode char(2),
--lfdnr   char(2),
lfdnr integer,
db      char(8),
ts      char(8) )
SPECIFIC WF_STARTTS_2PARM
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
--,      substr(erg, strpos(erg, '<LFDNR>') + length('<LFDNR>'), strpos(erg, '</LFDNR>') - strpos(erg, '<LFDNR>') - length('<LFDNR>')) as lfdnr
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<DB>') + length('<DB>'), strpos(erg, '</DB>') - strpos(erg, '<DB>') - length('<DB>')) as db
,      substr(erg, strpos(erg, '<TS>') + length('<TS>'), strpos(erg, '</TS>') - strpos(erg, '<TS>') - length('<TS>')) as ts
from  ( 
 select IDUG.sf_STARTTS(db, ts, '') as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.wf_STARTTS_2PARM to public;

@DELIMITER %%%;
create function IDUG.STARTTS(DB char(8), TS char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
SPECIFIC STARTTS_2PARM
return
select fkt.retcode, fkt.lfdnr, fkt.db, fkt.ts, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_STARTTS(DB, TS, '')) fkt 
inner join IDUG.tzdb_cmd_output utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.STARTTS_2PARM to public;


--
--drop specific function IDUG.STARTTB_3parm;
--drop specific function IDUG.STARTTB_2parm;
--drop specific function IDUG.wf_STARTTB_3parm;
--drop specific function IDUG.wf_STARTTB_2parm;
--drop specific function IDUG.SF_STARTTB_3PARM; --IDUG.sf_STARTTB;
--drop specific function IDUG.SF_STARTTB_2PARM;
--drop specific function IDUG.SF_STARTTB;
@DELIMITER %%%;  
create function IDUG.sf_STARTTB(ischema varchar(128), itbname varchar(128) , opt char(8))
returns char(80)
SPECIFIC SF_STARTTB_3PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
--call IDUG.STARTTB(ischema, itbname, '', iretcode, ilfdnr);
call IDUG.STARTTB(ischema, itbname, opt, iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><Q>' concat strip(ischema) concat '</Q><TB>' concat strip(itbname) concat '</TB>';   
END P1
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.SF_STARTTB_3PARM to public;

@DELIMITER %%%;  
create function IDUG.sf_STARTTB(ischema varchar(128), itbname varchar(128))
returns char(80)
SPECIFIC SF_STARTTB_2PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.STARTTB(ischema, itbname, '', iretcode, ilfdnr);
--call IDUG.STARTTB(ischema, itbname, opt, iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><Q>' concat strip(ischema) concat '</Q><TB>' concat strip(itbname) concat '</TB>';   
END P1
%%%                 
@DELIMITER;%%%

GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.SF_STARTTB_2PARM to public;    
    
--drop function IDUG.wf_STARTTB;
@DELIMITER %%%;  
create function IDUG.wf_STARTTB(ischema varchar(128), itbname varchar(128), opt char(8))
returns table (
retcode char(2),
--lfdnr   char(2),
lfdnr integer,
schema      char(8),
tbname      char(8) )
specific wf_STARTTB_3parm
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
--,      substr(erg, strpos(erg, '<LFDNR>') + length('<LFDNR>'), strpos(erg, '</LFDNR>') - strpos(erg, '<LFDNR>') - length('<LFDNR>')) as lfdnr
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<Q>') + length('<Q>'), strpos(erg, '</Q>') - strpos(erg, '<Q>') - length('<Q>')) as schema
,      substr(erg, strpos(erg, '<TB>') + length('<TB>'), strpos(erg, '</TB>') - strpos(erg, '<TB>') - length('<TB>')) as tbname
from  ( 
 select IDUG.sf_STARTTB(ischema, itbname, opt) as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.WF_STARTTB_3parm to public;

@DELIMITER %%%;  
create function IDUG.wf_STARTTB(ischema varchar(128), itbname varchar(128))
returns table (
retcode char(2),
--lfdnr   char(2),
lfdnr integer,
schema      char(8),
tbname      char(8) )
specific wf_STARTTB_2parm
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
--,      substr(erg, strpos(erg, '<LFDNR>') + length('<LFDNR>'), strpos(erg, '</LFDNR>') - strpos(erg, '<LFDNR>') - length('<LFDNR>')) as lfdnr
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<Q>') + length('<Q>'), strpos(erg, '</Q>') - strpos(erg, '<Q>') - length('<Q>')) as schema
,      substr(erg, strpos(erg, '<TB>') + length('<TB>'), strpos(erg, '</TB>') - strpos(erg, '<TB>') - length('<TB>')) as tbname
from  ( 
 select IDUG.sf_STARTTB(ischema, itbname, '') as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.WF_STARTTB_2parm to public;

@DELIMITER %%%;  
create function IDUG.STARTTB(ischema varchar(128), itbname varchar(128), opt char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
specific STARTTB_3parm
return
select fkt.retcode, fkt.lfdnr, fkt.schema, fkt.tbname, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_STARTTB(ischema, itbname, opt)) fkt 
inner join IDUG.tzdb_cmd_output utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.STARTTB_3parm to public;

@DELIMITER %%%;  
create function IDUG.STARTTB(ischema varchar(128), itbname varchar(128))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
specific STARTTB_2parm
return
select fkt.retcode, fkt.lfdnr, fkt.schema, fkt.tbname, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_STARTTB(ischema, itbname, '')) fkt 
inner join IDUG.tzdb_cmd_output utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.STARTTB_2parm to public;

