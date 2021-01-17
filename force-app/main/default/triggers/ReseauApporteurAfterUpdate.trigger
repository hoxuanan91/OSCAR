trigger ReseauApporteurAfterUpdate on ReseauApporteur__c (after update) {
/* 
------------------------------------------------------------
-- - Name          : ReseauApporteurAfterUpdate
-- - Author        : Cap Gemini
-- - Description   : Trigger Reseau Apporteur After Update
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- O1-JUIL-2015  NBL   1.0      Initial version
*/
  system.Debug('>>> START ReseauApporteurAfterUpdate <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('ReseauApporteurAfterUpdate')){
        
            AP06ReseauApporteur.recupererReseauApporteur(Trigger.new);
            AP06ReseauApporteur.pastEmailChargeAffaireToOpportunity(Trigger.new);
        	AP06ReseauApporteur.cocherReseauApporteur(Trigger.new);
        	AP06ReseauApporteur.updateRaReportingCBI(Trigger.new);
        }
    
    
    system.Debug('>>> END ReseauApporteurAfterUpdate <<<');
}