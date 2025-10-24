-- Copies SYSPROC-Procedures
-- During Db2-Maintanance / Job DSNTIJRT; SYSPROC.DSNUTILU DROP und CREATE
-- Problem when dependencies exit
-- We use own "Instance".
-- CREATE OR REPLACE possible as long parameters do not change
--
-- Change for your WLM Environment <WLM_GENERAL> and <WLM_UTILS>


CREATE OR REPLACE PROCEDURE IDUG.ADMIN_COMMAND_DB2                   
   (                                                     
    IN DB2_CMD VARCHAR(32704) FOR SBCS DATA CCSID EBCDIC,
    IN LEN_CMD INTEGER,                                  
    IN PARSE_TYPE VARCHAR(3) FOR SBCS DATA CCSID EBCDIC, 
    IN DB2_MEMBER VARCHAR(8) FOR SBCS DATA CCSID EBCDIC, 
    OUT CMD_EXEC INTEGER,                                
    OUT IFCA_RET INTEGER,                                
    OUT IFCA_RES INTEGER,                                
    OUT XS_BYTES INTEGER,                                
    OUT IFCA_GRES INTEGER,                               
    OUT GXS_BYTES INTEGER,                               
    OUT RETURN_CODE INTEGER,                             
    OUT MSG VARCHAR(1331) FOR SBCS DATA CCSID EBCDIC     
   )                                                     
    EXTERNAL NAME 'DSNADMCD'                             
    PARAMETER STYLE GENERAL WITH NULLS                   
    FENCED                                               
    NO DBINFO                                            
    DYNAMIC RESULT SETS 2                                
    PARAMETER CCSID EBCDIC                               
    LANGUAGE C                                           
    NOT DETERMINISTIC                                    
    MODIFIES SQL DATA                                    
    COLLID DSNADM                                        
    WLM ENVIRONMENT <WLM_GENERAL>                      
    ASUTIME NO LIMIT                                     
    STAY RESIDENT NO                                     
    PROGRAM TYPE MAIN                                    
    SECURITY DB2                                         
    INHERIT SPECIAL REGISTERS                            
    RUN OPTIONS 'TRAP(OFF),STACK(,,ANY,)'                
    COMMIT ON RETURN NO                                  
    CALLED ON NULL INPUT                                 
    STOP AFTER SYSTEM DEFAULT FAILURES                   
;                        
GRANT EXECUTE ON PROCEDURE IDUG.ADMIN_COMMAND_DB2 to public; 
    

CREATE OR REPLACE PROCEDURE IDUG.DSNUTILU                                   
   (                                                            
    IN UTILITY_ID VARCHAR(16) FOR MIXED DATA CCSID UNICODE,     
    IN RESTART VARCHAR(8) FOR MIXED DATA CCSID UNICODE,         
    IN UTSTMT VARCHAR(32704) FOR MIXED DATA CCSID UNICODE,      
    OUT RETCODE INTEGER                                         
   )                                                            
    EXTERNAL NAME 'DSNUTILU'                                    
    PARAMETER STYLE GENERAL                                     
    FENCED                                                      
    NO DBINFO                                                   
    DYNAMIC RESULT SETS 1                                       
    PARAMETER CCSID UNICODE                                     
    LANGUAGE ASSEMBLE                                           
    NOT DETERMINISTIC                                           
    MODIFIES SQL DATA                                           
    COLLID DSNUTILU                                             
    WLM ENVIRONMENT <WLM_UTILS>                               
    ASUTIME NO LIMIT                                            
    STAY RESIDENT NO                                            
    PROGRAM TYPE MAIN                                           
    SECURITY USER                                               
    INHERIT SPECIAL REGISTERS                                   
    RUN OPTIONS 'TRAP(OFF)'                                     
    COMMIT ON RETURN NO                                         
    CALLED ON NULL INPUT                                        
    STOP AFTER SYSTEM DEFAULT FAILURES                          
;     
GRANT EXECUTE ON PROCEDURE IDUG.DSNUTILU to public;                                                          