-- DROP Functions and Procedures for Utility per Select
-- Order relevant because of dependencies

-- RUNSTATS
drop function IDUG.runstatstb;
drop function IDUG.wf_runstatstb;
drop function IDUG.sf_runstatstb;
--
drop function IDUG.runstatsts;
drop function IDUG.wf_runstatsts;
drop function IDUG.sf_runstatsts;
--
drop procedure IDUG.runstatsTB;
drop procedure IDUG.RUNSTATSts;


-- REORG
drop function IDUG.reorgtb;
drop function IDUG.wf_reorgtb;
drop function IDUG.sf_reorgtb;
--
drop function IDUG.reorgts;
drop function IDUG.wf_reorgts;
drop function IDUG.sf_reorgts;
--
drop procedure IDUG.REORGTB;
drop procedure IDUG.REORGts;


-- DISPLAY
drop specific function IDUG.displaytb_3parm;
drop specific function IDUG.displaytb_2parm;
drop specific function IDUG.wf_displaytb_3parm;
drop specific function IDUG.wf_displaytb_2parm;
drop specific function IDUG.SF_DISPLAYTB_3PARM;
drop specific function IDUG.SF_DISPLAYTB_2PARM;

--
drop specific function IDUG.displayts_3parm;
drop specific function IDUG.displayts_2parm;
drop specific function IDUG.wf_displayts_3parm;
drop specific function IDUG.wf_displayts_2parm;
drop specific function IDUG.SF_DISPLAYts_3PARM;
drop specific function IDUG.SF_DISPLAYts_2PARM;

--
drop procedure IDUG.DISPLAYTB;
drop procedure IDUG.DISPLAYts;


-- COPY
DROP SPECIFIC FUNCTION IDUG.COPYTB_2PARM RESTRICT ;      
DROP SPECIFIC FUNCTION IDUG.COPYTB_3PARM RESTRICT ;      
DROP SPECIFIC FUNCTION IDUG.COPYts_2PARM RESTRICT ;    
DROP SPECIFIC FUNCTION IDUG.COPYts_3PARM RESTRICT ;    
DROP SPECIFIC FUNCTION IDUG.WF_COPYts_2PARM RESTRICT ; 
DROP SPECIFIC FUNCTION IDUG.WF_COPYts_3PARM RESTRICT ; 
DROP SPECIFIC FUNCTION IDUG.WF_COPYTB_2PARM RESTRICT ;   
DROP SPECIFIC FUNCTION IDUG.WF_COPYTB_3PARM RESTRICT ;   
DROP SPECIFIC FUNCTION IDUG.SF_COPYts_2PARM RESTRICT ; 
DROP SPECIFIC FUNCTION IDUG.SF_COPYts_3PARM RESTRICT ; 
DROP SPECIFIC FUNCTION IDUG.SF_COPYTB_2PARM RESTRICT ;   
DROP SPECIFIC FUNCTION IDUG.SF_COPYTB_3PARM RESTRICT ;   
--
drop procedure IDUG.COPYTB;
drop procedure IDUG.COPYts;


-- CHECK
drop function IDUG.checktb;
drop function IDUG.wf_checktb;
drop function IDUG.sf_checktb;
--
drop function IDUG.checkts;
drop function IDUG.wf_checkts;
drop function IDUG.sf_checkts;
--
drop procedure IDUG.CHECKTB;
drop procedure IDUG.CHECKts;

-- XLOADFROMTO
drop specific function IDUG.XLOADFROMTO;
drop specific function IDUG.wf_XLOADFROMTO;
drop specific function IDUG.sf_XLOADFROMTO;
--
drop procedure IDUG.XLOADFROMTO;



-- TERM UTIL
-- wg. call SYSPROC.ADMIN_COMMAND_DB2
drop procedure IDUG.TERMUTIL;

