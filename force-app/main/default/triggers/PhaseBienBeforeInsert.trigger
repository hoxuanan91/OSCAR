trigger PhaseBienBeforeInsert on PhaseDeBien__c (before insert) {
/* 
------------------------------------------------------------
-- - Name          : PhaseBienBeforeInsert
-- - Author        : Cap Gemini
-- - Description   : Trigger Phase Bien Before Insert
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- O4-SEPT-2015  NBL   1.0      Initial version
*/
 system.Debug('>>> START PhaseBienBeforeInsert <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('PhaseBienBeforeInsert')){
        
        AP12PhaseBien.creerAvenant(Trigger.new);
        
    }

    system.Debug('>>> END PhaseBienBeforeInsert <<<');
}