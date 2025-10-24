
-- drop specific function IDUG.XLOADFROMTO;
-- drop specific function IDUG.wf_XLOADFROMTO;
-- drop specific function IDUG.sf_XLOADFROMTO;
-- drop procedure IDUG.XLOADFROMTO;
@DELIMITER %%%;                                        
CREATE OR REPLACE PROCEDURE IDUG.XLOADFROMTO(                                                                          
         IN I_FROM CHAR(60) FOR SBCS DATA CCSID EBCDIC,
         IN I_TO   CHAR(60) FOR SBCS DATA CCSID EBCDIC
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

DECLARE l_dbname varchar(24);
DECLARE l_tsname varchar(24);
DECLARE ziel_tb CHAR(40);
DECLARE ziel_hlq CHAR(8);

declare c10 cursor with return for select lfdnr, retcode, seqno, text from utilprint 
where lfdnr = ilfdnr order by seqno asc;

set ziel_hlq = substr(I_TO, 1, locate('.', I_TO) - 1);
set ziel_tb  = substr(I_TO, locate('.', I_TO) + 1);
select dbname, tsname into l_dbname, l_tsname from SYSIBM.SYSTABLES WHERE TYPE = 'T' AND CREATOR = upper(ziel_hlq) and NAME = upper(ziel_tb);

set utstmt =               'TEMPLATE TSORTOUT DSN UE2.&SS..&DB..&SN..P&PART..S&TI. DISP(MOD,DELETE,CATLG) SPACE(10,10) CYL ';
set utstmt = utstmt concat 'TEMPLATE TSYSUT1  DSN UE2.&SS..&DB..&SN..P&PART..U&TI. DISP(MOD,DELETE,CATLG) SPACE(10,10) CYL ';

set utstmt = utstmt concat ' EXEC SQL ';
set utstmt = utstmt concat ' DECLARE C1 CURSOR FOR SELECT * FROM ';
set utstmt = utstmt concat strip(I_FROM) ;
set utstmt = utstmt concat ' ENDEXEC ';
set utstmt = utstmt concat ' LOAD DATA INCURSOR C1 RESUME NO REPLACE LOG NO ';
set utstmt = utstmt concat ' WORKDDN(TSYSUT1,TSORTOUT) ';
set utstmt = utstmt concat ' SORTNUM 8 SORTDEVT SYSDA ';
set utstmt = utstmt concat ' INTO TABLE ' concat strip(I_TO);

SET utilid = 'XL' concat l_tsname;

call IDUG.DSNUTILU(utilid, 'NO', utstmt, iretcode);

set retcode = iretcode;
call IDUG.CN_UTILPROT(L_DBNAME, L_TSNAME, 'XLOAD', IRETCODE, ilfdnr); 
set lfdnr = ilfdnr;

open c10; -- result set
END P1
                            
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.XLOADFROMTO to public;

@DELIMITER %%%;  
create function IDUG.sf_XLOADFROMTO(I_FROM char(60), I_TO char(60))
returns char(80)
MODIFIES SQL DATA
P1: BEGIN
declare iretcode integer;
declare ilfdnr   integer;
call IDUG.XLOADFROMTO(I_FROM, I_TO, iretcode, ilfdnr);
return '<RC>'concat iretcode concat '</RC><NR>' concat ilfdnr concat '</NR><OFROM>' concat substr(I_FROM, 1, 8) concat '</OFROM><OTO>' concat substr(I_TO, 1, 8) concat '</OTO>';   
END P1
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.sf_XLOADFROMTO to public;

@DELIMITER %%%;  
create function IDUG.wf_XLOADFROMTO(I_FROM char(60), I_TO char(60))
returns table (
retcode char(2),
lfdnr integer,
O_FROM      char(8),
O_TO      char(8) )
return 
select substr(erg, 5                                         , strpos(erg,'</RC>')     - strpos(erg, '<RC>')    - length('<RC>'))    as RC
,      cast(substr(erg, strpos(erg, '<NR>') + length('<NR>'), strpos(erg, '</NR>') - strpos(erg, '<NR>') - length('<NR>')) as integer) as lfdnr
,      substr(erg, strpos(erg, '<OFROM>') + length('<OFROM>'), strpos(erg, '</OFROM>') - strpos(erg, '<OFROM>') - length('<OFROM>')) as O_FROM
,      substr(erg, strpos(erg, '<OTO>') + length('<OTO>'), strpos(erg, '</OTO>') - strpos(erg, '<OTO>') - length('<OTO>')) as O_TO
from  ( 
 select IDUG.sf_XLOADFROMTO(I_FROM, I_TO) as erg from sysibm.sysdummy1) as t
%%%                 
@DELIMITER;%%%
grant execute on specific function IDUG.wf_XLOADFROMTO to public;

@DELIMITER %%%;
create function IDUG.XLOADFROMTO(I_FROM char(60), I_TO char(60))
returns table (
retcode char(2),
lfdnr integer,
O_FROM      char(8),
O_TO      char(8),
seqno integer,
text varchar(254),
row_change_sys timestamp )
return
select fkt.retcode, fkt.lfdnr, fkt.O_FROM, fkt.O_TO, utp.seqno, utp.text, utp.row_change_sys
from table (IDUG.wf_xloadfromto(I_FROM, I_TO)) fkt 
inner join IDUG.utilprint utp
on fkt.lfdnr = utp.lfdnr
%%%                 
@DELIMITER;%%%
GRANT EXECUTE ON SPECIFIC FUNCTION IDUG.XLOADFROMTO to public;
