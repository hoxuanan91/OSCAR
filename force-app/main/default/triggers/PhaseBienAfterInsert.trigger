trigger PhaseBienAfterInsert on PhaseDeBien__c (after insert) {
/* 
------------------------------------------------------------
-- - Name          : PhaseBienAfterInsert
-- - Author        : Cap Gemini
-- - Description   : Trigger Phase Bien After Insert
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 22-OCT-2015  NBL   1.0      Initial version
*/
 system.Debug('>>> START PhaseBienAfterInsert <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('PhaseBienAfterInsert')){
        
        AP12PhaseBien.rapatrierDonneesSurBien(Trigger.new);
        
    }

    system.Debug('>>> END PhaseBienAfterInsert <<<');
}