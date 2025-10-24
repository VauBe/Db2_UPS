--drop procedure IDUG.CA_UTILPROT_INS;
@DELIMITER %%%;                                        
CREATE OR REPLACE 
PROCEDURE IDUG.CA_UTILPROT_INS(                                                                          
         IN I_DBNAME   CHAR(8)  FOR SBCS DATA CCSID EBCDIC,
         IN I_TSNAME   CHAR(8)  FOR SBCS DATA CCSID EBCDIC,
         IN I_PROCNAME CHAR(20) FOR SBCS DATA CCSID EBCDIC,
         IN I_RETCODE    INTEGER
         , OUT O_LFDNR   INTEGER                          
        )                                                     
         VERSION V1                                                                     
         QUALIFIER IDUG                                        
         PACKAGE OWNER IDUG 
         DYNAMIC RESULT SETS 0
         AUTONOMOUS         -- MUST use dynamic result set 0 (otherwise SQLCODE -628)                      
P1: BEGIN     
DECLARE ilfdnr integer;
select lfdnr into ilfdnr from final table(
insert into IDUG.procprot (dbname, tsname, procname, retcode)
values (i_dbname, i_tsname, i_procname, i_retcode));
set o_lfdnr = ilfdnr; -- o_lfdnr ist R�ckgabe
END P1
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.CA_UTILPROT_INS to public;

--drop procedure IDUG.CA_UTILPRINT_INS;
@DELIMITER %%%;                                        
CREATE OR REPLACE 
PROCEDURE IDUG.CA_UTILPRINT_INS(                                                                          
         IN I_LFDNR  INTEGER,
         IN I_SEQNO  INTEGER,
         IN I_TEXT   VARCHAR(254)
        )                                                     
         VERSION V1                                                                     
         QUALIFIER IDUG                                        
         PACKAGE OWNER IDUG 
         DYNAMIC RESULT SETS 0
         AUTONOMOUS         -- MUST use dynamic result set 0 (otherwise SQLCODE -628)                       
P1: BEGIN     
insert into IDUG.utilprint(lfdnr, seqno, text) 
values (i_lfdnr, i_seqno, i_text);
END P1
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.CA_UTILPRINT_INS to public;


--drop procedure IDUG.CN_UTILPROT;
@DELIMITER %%%;                                        
CREATE OR REPLACE 
PROCEDURE IDUG.CN_UTILPROT(                                                                          
         IN I_DBNAME   CHAR(8)  FOR SBCS DATA CCSID EBCDIC,
         IN I_TSNAME   CHAR(8)  FOR SBCS DATA CCSID EBCDIC,
         IN I_PROCNAME CHAR(20) FOR SBCS DATA CCSID EBCDIC,
         IN I_RETCODE    INTEGER
         , OUT O_LFDNR   INTEGER                          
        )                                                     
         VERSION V1                                                                     
         QUALIFIER IDUG                                        
         PACKAGE OWNER IDUG 
         DYNAMIC RESULT SETS 0
P1: BEGIN     
DECLARE ilfdnr integer;
declare iseqno integer;
declare itext varchar(254);
declare sqlstate char(5) DEFAULT '00000';
declare code char(5) DEFAULT '00000';
declare c1 cursor for select seqno, text from sysibm.sysprint order by seqno asc; -- Internal Cursor

call IDUG.CA_UTILPROT_INS(I_DBNAME, I_TSNAME, I_PROCNAME, I_RETCODE, ilfdnr);
set o_lfdnr = ilfdnr; -- o_lfdnr is returned

-- Copy rows from sysibm.sysprint to IDUG.utilprint via auton. SP issuing Insert
open c1;
fetch from c1 into iseqno, itext;
set code = sqlstate;
while(code = '00000') do
  call IDUG.CA_UTILPRINT_INS(ilfdnr, iseqno, itext);
  fetch from c1 into iseqno, itext;
  set code = sqlstate;
  --insert into IDUG.utilprint(lfdnr, seqno, text) select ilfdnr, seqno, text from sysibm.sysprint;
end while;
close c1;


END P1
 %%%                 
@DELIMITER;%%%

grant execute on procedure IDUG.CN_UTILPROT to public;