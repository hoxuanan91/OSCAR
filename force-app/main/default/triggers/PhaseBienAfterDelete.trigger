trigger PhaseBienAfterDelete on PhaseDeBien__c (after delete) {
/* 
------------------------------------------------------------
-- - Name          : PhaseBienAfterDelete
-- - Author        : Cap Gemini
-- - Description   : Trigger Phase Bien After Delete
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- O9-OCT-2015  NBL   1.0      Initial version
*/
 system.Debug('>>> START PhaseBienAfterDelete <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('PhaseBienAfterDelete')){
        
        AP12PhaseBien.majDernierePhase(Trigger.old);
       
    }

    system.Debug('>>> END PhaseBienAfterDelete <<<');
}