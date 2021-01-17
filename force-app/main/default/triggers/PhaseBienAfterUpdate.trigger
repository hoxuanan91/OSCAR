trigger PhaseBienAfterUpdate on PhaseDeBien__c (after update) {
/* 
------------------------------------------------------------
-- - Name          : PhaseBienAfterUpdate
-- - Author        : Cap Gemini
-- - Description   : Trigger Phase Bien After Update
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 22-OCT-2015  NBL   1.0      Initial version
*/
 system.Debug('>>> START PhaseBienAfterUpdate <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('PhaseBienAfterUpdate')){
        
        AP12PhaseBien.rapatrierDonneesSurBien(Trigger.new);
        
    }

    system.Debug('>>> END PhaseBienAfterUpdate <<<');
}