-- DOCU for UPS - Utility Per Select

-- UPS_01_Tables         -- Create TS und TB
                         -- CMD_OUTPUT  -- Command Output, e.g. Display
                         -- CMD_PROT    -- Protocol Usage SP for Commands
                         -- PROCPROT    -- Protocol Usage SP for Utility
                         -- UTILPRINT   -- Utility Output, e.g. Reorg
                         
-- UPS_02_PR_DBM_SYSPROC -- Create own instance of SYSPROC-Procedures because of DSNTIJRT
-- UPS_02_PR_CMDPROT     -- Create PR for protocol Command 
-- UPS_02_PR_UTILPROT    -- Create PR for protocol Utility 
-- UPS_03_PR_TERMUTIL    -- Create PR TERMUTIL
--
-- UPS_04_REORG          -- Create PR REORGTS
                         -- Create PR REORGTB
                         -- Create FN for REORGTS
                         -- Create FN for REORGTB
--
-- UPS_04_RUNSTATS       -- Create PR RUNSTATSTS
                         -- Create PR RUNSTATSTB
                         -- Create FN for RUNSTATSTS
                         -- Create FN for RUNSTATSTB
--
-- UPS_04_DISPLAY        -- Create PR DISPLAYTS
                         -- Create PR DISPLAYTB
                         -- Create FN for DISPLAYTS
                         -- Create FN for DISPLAYTB
--
-- UPS_04_COPY           -- Create PR COPYTS
                         -- Create PR COPYTB
                         -- Create FN for COPYTS
                         -- Create FN for COPYTB
--
-- UPS_04_CHECK          -- Create PR CHECKTS
                         -- Create PR CHECKTB
                         -- Create FN for CHECKTS
                         -- Create FN for CHECKTB
--
-- UPS_04_XLOADFROMTO    -- Create PR XLOADFROMTO
                         -- Create FN for XLOADFROMTO
                                               
--
-- UPS_05_IVP            -- IVP uses TB-Functions
                         -- which calls Procedures internally
-- 
-- UPS_08_DROP           -- Drop FN und PR from 03 and 04.
                         
                      
          