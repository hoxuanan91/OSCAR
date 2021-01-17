trigger GarantieAfterInsert on Garantie__c (after insert) {
/* 
------------------------------------------------------------
-- - Name          : GarantieAfterInsert
-- - Author        : Cap Gemini
-- - Description   : Trigger Garantie After Insert
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 16-JUN-2015  NBL   1.0      Initial version: fixer le flag dépôt de garantie sur le projet associé
*/
  system.Debug('>>> START GarantieAfterInsert <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('GarantieAfterInsert')){
        
        AP02Garantie.updateOpportunity(Trigger.new);
        
        }
    
    
    system.Debug('>>> END GarantieAfterInsert <<<');
}