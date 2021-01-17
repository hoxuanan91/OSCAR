trigger GarantieAfterDelete on Garantie__c (after delete) {
/* 
------------------------------------------------------------
-- - Name          : GarantieAfterDelete
-- - Author        : Cap Gemini
-- - Description   : Trigger Garantie After Delete
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 16-JUN-2015  NBL   1.0      Initial version: fixer le flag dépôt de garantie sur le projet associé
*/
  system.Debug('>>> START GarantieAfterDelete <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('GarantieAfterDelete')){
        
         AP02Garantie.updateOpportunity(Trigger.old);
        
    }
    system.Debug('>>> END GarantieAfterDelete <<<');
}