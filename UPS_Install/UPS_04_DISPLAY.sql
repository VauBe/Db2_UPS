--drop procedure IDUG.DISPLAYTS;
@DELIMITER %%%;                                        
CREATE OR REPLACE  PROCEDURE IDUG.DISPLAYTS(                                                                          
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

DECLARE o_commands_ex integer;
DECLARE o_ifirc integer;
DECLARE o_ifirr integer;
DECLARE o_ex_bytes integer;
DECLARE o_grp_ifirc integer;
DECLARE o_grp_ex_bytes integer;
DECLARE o_rc integer;
DECLARE o_message varchar(1331);



declare c10 cursor with return for select lfdnr, retcode, seqno, text from IDUG.cmd_output 
where lfdnr = ilfdnr order by seqno asc;

-- Error Message
declare f10 cursor with return for select '-1' as lfdnr, '8' as retcode, '1' as seqno, 'DISPLAYTS: OPT not found' as text from sysibm.sysdummy1;
SET fehler = '0'; -- init error

SET utstmt =               '-DISPLAY DATABASE(' concat strip(I_DB) concat ') SPACENAM(' concat strip(I_TS) concat ') ';

CASE STRIP(UPPER(I_OPT))
 WHEN ''
  THEN SET utstmt = utstmt;
 WHEN ' ' 
  THEN SET utstmt = utstmt;
 WHEN 'USE'
  THEN SET utstmt = utstmt concat I_OPT;
 WHEN 'CLAIMERS'
  THEN SET utstmt = utstmt concat I_OPT;
 WHEN 'LOCKS'
  THEN SET utstmt = utstmt concat I_OPT;
 WHEN 'ADV'
  THEN SET utstmt = utstmt concat 'ADVISORY ( ) ';
 WHEN 'ADVISORY'
  THEN SET utstmt = utstmt concat 'ADVISORY ( ) ';
 WHEN 'RES'
  THEN SET utstmt = utstmt concat 'RESTRICT ( ) ';
 WHEN 'RESTRICT'
  THEN SET utstmt = utstmt concat 'RESTRICT ( ) ';
 WHEN 'ADVRES'
  THEN SET utstmt = utstmt concat 'RESTRICT ADVISORY ';
 WHEN 'RESADV'
  THEN SET utstmt = utstmt concat 'RESTRICT ADVISORY ';
 ELSE SET fehler = '1' ;
END CASE;
  
SET utstmt = utstmt concat ' LIMIT( 500 )';

if fehler = '0' then
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
  open c10; -- result set
else
  set retcode = 8;
  set lfdnr = -1;
  open f10; -- Error Message
end if;
END P1
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.DISPLAYTS to public;


--drop procedure IDUG.DISPLAYTB;
@DELIMITER %%%;                                        
CREATE OR REPLACE PROCEDURE IDUG.DISPLAYTB(                                                                          
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

declare c10 cursor with return for select lfdnr, retcode, seqno, text from cmd_output 
where lfdnr = ilfdnr order by seqno asc;

declare f10 cursor with return for select '-1' as lfdnr, '8' as retcode, '1' as seqno, 'DISPLAYTB: Table not found' as text from sysibm.sysdummy1;

select dbname, tsname into l_dbname, l_tsname from SYSIBM.SYSTABLES WHERE TYPE = 'T' AND CREATOR = upper(i_schema) and NAME = upper(i_tbname);

set code = sqlstate;
if (code != '00000') then
  set retcode = 8;
  set lfdnr   = '-1';
  open f10; -- Error Message
else
  call IDUG.DISPLAYTS(l_dbname, l_tsname, i_opt, iretcode, ilfdnr);
  set lfdnr = ilfdnr;
  set retcode = iretcode;
  open c10; -- Resultset
end if;
END P1
                            
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.DISPLAYTB to public;

--

--drop specific function IDUG.DISPLAYTS_3parm;
--drop specific function IDUG.DISPLAYTS_2parm;
--drop specific function IDUG.wf_DISPLAYTS_3parm;
--drop specific function IDUG.wf_DISPLAYTS_2parm;
--drop specific function IDUG.SF_DISPLAYTS_3PARM; --IDUG.sf_displaytb;
--drop specific function IDUG.SF_DISPLAYTS_2PARM;
--drop specific function IDUG.SF_DISPLAYTS;
@DELIMITER %%%;  
create function IDUG.sf_DISPLAYTS(DB char(8), TS char(8), OPT char(8))
returns char(80)
SPECIFIC SF_DISPLAYTS_3PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.DISPLAYTS(DB, TS, OPT, iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><DB>' concat strip(db) concat '</DB><TS>' concat strip(TS) concat '</TS>';   
END P1
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.sf_DISPLAYTS_3PARM to public;

@DELIMITER %%%;  
create function IDUG.wf_DISPLAYTS(DB char(8), TS char(8), OPT char(8))
returns table (
retcode char(2),
lfdnr integer,
db      char(8),
ts      char(8) )
SPECIFIC WF_DISPLAYTS_3PARM
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<DB>') + length('<DB>'), strpos(erg, '</DB>') - strpos(erg, '<DB>') - length('<DB>')) as db
,      substr(erg, strpos(erg, '<TS>') + length('<TS>'), strpos(erg, '</TS>') - strpos(erg, '<TS>') - length('<TS>')) as ts
from  ( 
 select IDUG.sf_DISPLAYTS(db, ts, opt) as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.wf_DISPLAYTS_3PARM to public;

@DELIMITER %%%;
create function IDUG.DISPLAYTS(DB char(8), TS char(8), OPT char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
SPECIFIC DISPLAYTS_3PARM
return
select fkt.retcode, fkt.lfdnr, fkt.db, fkt.ts, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_DISPLAYTS(DB, TS, OPT)) fkt 
inner join IDUG.cmd_output utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.DISPLAYTS_3PARM to public;


-- 2PARM
@DELIMITER %%%;  
create function IDUG.sf_DISPLAYTS(DB char(8), TS char(8))
returns char(80)
SPECIFIC SF_DISPLAYTS_2PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.DISPLAYTS(DB, TS, '', iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><DB>' concat strip(db) concat '</DB><TS>' concat strip(TS) concat '</TS>';   
END P1
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.sf_DISPLAYTS_2PARM to public;

@DELIMITER %%%;  
create function IDUG.wf_DISPLAYTS(DB char(8), TS char(8))
returns table (
retcode char(2),
lfdnr integer,
db      char(8),
ts      char(8) )
SPECIFIC WF_DISPLAYTS_2PARM
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<DB>') + length('<DB>'), strpos(erg, '</DB>') - strpos(erg, '<DB>') - length('<DB>')) as db
,      substr(erg, strpos(erg, '<TS>') + length('<TS>'), strpos(erg, '</TS>') - strpos(erg, '<TS>') - length('<TS>')) as ts
from  ( 
 select IDUG.sf_DISPLAYTS(db, ts, '') as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.wf_DISPLAYTS_2PARM to public;

@DELIMITER %%%;
create function IDUG.DISPLAYTS(DB char(8), TS char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
SPECIFIC DISPLAYTS_2PARM
return
select fkt.retcode, fkt.lfdnr, fkt.db, fkt.ts, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_DISPLAYTS(DB, TS, '')) fkt 
inner join IDUG.cmd_output utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.DISPLAYTS_2PARM to public;


--
--drop specific function IDUG.displaytb_3parm;
--drop specific function IDUG.displaytb_2parm;
--drop specific function IDUG.wf_displaytb_3parm;
--drop specific function IDUG.wf_displaytb_2parm;
--drop specific function IDUG.SF_DISPLAYTB_3PARM; --IDUG.sf_displaytb;
--drop specific function IDUG.SF_DISPLAYTB_2PARM;
--drop specific function IDUG.SF_DISPLAYTB;
@DELIMITER %%%;  
create function IDUG.sf_displaytb(ischema varchar(128), itbname varchar(128) , opt char(8))
returns char(80)
SPECIFIC SF_DISPLAYTB_3PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;

call IDUG.displaytb(ischema, itbname, opt, iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><Q>' concat strip(ischema) concat '</Q><TB>' concat strip(itbname) concat '</TB>';   
END P1
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.SF_displayTB_3PARM to public;

@DELIMITER %%%;  
create function IDUG.sf_displaytb(ischema varchar(128), itbname varchar(128))
returns char(80)
SPECIFIC SF_DISPLAYTB_2PARM
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.displaytb(ischema, itbname, '', iretcode, ilfdnr);

return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><Q>' concat strip(ischema) concat '</Q><TB>' concat strip(itbname) concat '</TB>';   
END P1
%%%                 
@DELIMITER;%%%

GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.SF_displayTB_2PARM to public;    
    
--drop function IDUG.wf_displaytb;
@DELIMITER %%%;  
create function IDUG.wf_displaytb(ischema varchar(128), itbname varchar(128), opt char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8) )
specific wf_displaytb_3parm
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<Q>') + length('<Q>'), strpos(erg, '</Q>') - strpos(erg, '<Q>') - length('<Q>')) as schema
,      substr(erg, strpos(erg, '<TB>') + length('<TB>'), strpos(erg, '</TB>') - strpos(erg, '<TB>') - length('<TB>')) as tbname
from  ( 
 select IDUG.sf_displaytb(ischema, itbname, opt) as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.WF_displayTB_3parm to public;

@DELIMITER %%%;  
create function IDUG.wf_displaytb(ischema varchar(128), itbname varchar(128))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8) )
specific wf_displaytb_2parm
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<Q>') + length('<Q>'), strpos(erg, '</Q>') - strpos(erg, '<Q>') - length('<Q>')) as schema
,      substr(erg, strpos(erg, '<TB>') + length('<TB>'), strpos(erg, '</TB>') - strpos(erg, '<TB>') - length('<TB>')) as tbname
from  ( 
 select IDUG.sf_displaytb(ischema, itbname, '') as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.WF_displayTB_2parm to public;

@DELIMITER %%%;  
create function IDUG.displaytb(ischema varchar(128), itbname varchar(128), opt char(8))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
specific displaytb_3parm
return
select fkt.retcode, fkt.lfdnr, fkt.schema, fkt.tbname, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_displaytb(ischema, itbname, opt)) fkt 
inner join IDUG.cmd_output utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.displayTB_3parm to public;

@DELIMITER %%%;  
create function IDUG.displaytb(ischema varchar(128), itbname varchar(128))
returns table (
retcode char(2),
lfdnr integer,
schema      char(8),
tbname      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
specific displaytb_2parm
return
select fkt.retcode, fkt.lfdnr, fkt.schema, fkt.tbname, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_displaytb(ischema, itbname, '')) fkt 
inner join IDUG.cmd_output utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.displayTB_2parm to public;

