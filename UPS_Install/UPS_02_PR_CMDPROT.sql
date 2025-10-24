-- Procedures for protocolling Command

-- CA_CMDPROT_INS    -- Autonomous PR Insert into cmd_prot; protocol call
-- CA_CMDPRINT_INS   -- Autonomous PR Insert into cmd_output
-- CN_CMDPROT        -- Reads sysibm.db2_cmd_output and copies to own table cmd_output
                          -- Calls both CA-Procedures
                          -- Gets called in CMD-PRs (e.g. DISPLAY, TERM UTIL)
                           


--drop procedure IDUG.CA_CMDPROT_INS;
@DELIMITER %%%;                                        
CREATE OR REPLACE 
PROCEDURE IDUG.CA_CMDPROT_INS(                                                                          
         IN I_CMD   VARCHAR(128)  FOR SBCS DATA CCSID EBCDIC,
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
insert into IDUG.cmd_prot (cmd, retcode)
values (i_cmd, i_retcode));
set o_lfdnr = ilfdnr; -- o_lfdnr is returned
END P1
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.CA_CMDPROT_INS to public;

--drop procedure IDUG.CA_CMDPRINT_INS;
@DELIMITER %%%;                                        
CREATE OR REPLACE 
PROCEDURE IDUG.CA_CMDPRINT_INS(                                                                          
         IN I_LFDNR  INTEGER,
         IN I_SEQNO  INTEGER,
         IN I_TEXT   CHAR(80)
        )                                                     
         VERSION V1                                                                     
         QUALIFIER IDUG                                        
         PACKAGE OWNER IDUG 
         DYNAMIC RESULT SETS 0
         AUTONOMOUS         -- MUST use dynamic result set 0 (otherwise SQLCODE -628)                       
P1: BEGIN     
insert into IDUG.cmd_output(lfdnr, seqno, text) 
values (i_lfdnr, i_seqno, i_text);
END P1
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.CA_CMDPRINT_INS to public;


--drop procedure IDUG.CN_CMDPROT;
@DELIMITER %%%;                                        
CREATE OR REPLACE 
PROCEDURE IDUG.CN_CMDPROT(                                                                          
         IN I_CMD   VARCHAR(128)  FOR SBCS DATA CCSID EBCDIC,
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
declare itext  char(80);
declare sqlstate char(5) DEFAULT '00000';
declare code char(5) DEFAULT '00000';

declare c1 cursor for select rownum, text from sysibm.db2_cmd_output order by rownum asc; -- Internal Cursor

call IDUG.CA_CMDPROT_INS(I_CMD, I_RETCODE, ilfdnr);
set o_lfdnr = ilfdnr; -- o_lfdnr is returned


open c1;
fetch from c1 into iseqno, itext;
set code = sqlstate;

while(code = '00000') do
  call IDUG.CA_CMDPRINT_INS(ilfdnr, iseqno, itext);
  
  fetch from c1 into iseqno, itext;
  set code = sqlstate;
  
end while;
close c1;


END P1
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.CN_CMDPROT to public;

