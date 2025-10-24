
--drop procedure IDUG.TERMUTIL;

@DELIMITER %%%;                                        
CREATE OR REPLACE  PROCEDURE IDUG.TERMUTIL(                                                                          
         IN I_UTILID CHAR(16) FOR SBCS DATA CCSID EBCDIC
         , OUT RETCODE INTEGER                              
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

SET utstmt =               '-TERM UTILITY(' concat strip(I_UTILID) concat ')';

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

open c10; -- Result Set
END P1
                            
 %%%                 
@DELIMITER;%%%
grant execute on procedure IDUG.TERMUTIL to public;
