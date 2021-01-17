trigger GarantieAfterUpdate on Garantie__c (after update) {
/* 
------------------------------------------------------------
-- - Name          : GarantieAfterUpdate
-- - Author        : Cap Gemini
-- - Description   : Trigger Garantie After Update
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 16-JUN-2015  NBL   1.0      Initial version: fixer le flag dépôt de garantie sur le projet associé
*/ 
  system.Debug('>>> START GarantieAfterUpdate <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('GarantieAfterUpdate')){
        
        AP02Garantie.updateOpportunity(Trigger.new);
        
    }
    system.Debug('>>> END GarantieAfterUpdate <<<');
}