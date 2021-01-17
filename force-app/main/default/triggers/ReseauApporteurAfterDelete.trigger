trigger ReseauApporteurAfterDelete on ReseauApporteur__c (after delete) {
/* 
------------------------------------------------------------
-- - Name          : ReseauApporteurAfterDelete
-- - Author        : Cap Gemini
-- - Description   : Trigger Reseau Apporteur After Delete
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- O1-JUIL-2015  NBL   1.0      Initial version
*/
  system.Debug('>>> START ReseauApporteurAfterDelete <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('ReseauApporteurAfterDelete')){
        
            AP06ReseauApporteur.recupererReseauApporteur(Trigger.old);
            AP06ReseauApporteur.pastEmailChargeAffaireToOpportunity(Trigger.old);
       		AP06ReseauApporteur.decocherReseauApporteur(Trigger.old); 
        	AP06ReseauApporteur.deleteRaReportingCBI(Trigger.old); 
        }
    
    
    system.Debug('>>> END ReseauApporteurAfterDelete <<<');
}