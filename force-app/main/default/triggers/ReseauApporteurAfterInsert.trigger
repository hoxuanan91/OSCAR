trigger ReseauApporteurAfterInsert on ReseauApporteur__c (after insert) {
/* 
------------------------------------------------------------
-- - Name          : ReseauApporteurAfterInsert
-- - Author        : Cap Gemini
-- - Description   : Trigger Reseau Apporteur After Insert
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- O1-JUIL-2015  NBL   1.0      Initial version
*/
  system.Debug('>>> START ReseauApporteurAfterInsert <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('ReseauApporteurAfterInsert')){
        
            AP06ReseauApporteur.recupererReseauApporteur(Trigger.new);
            AP06ReseauApporteur.pastEmailChargeAffaireToOpportunity(Trigger.new);
        	AP06ReseauApporteur.cocherReseauApporteur(Trigger.new);
       		AP06ReseauApporteur.insertRaReportingCBI(Trigger.new);
        }
    
    
    system.Debug('>>> END ReseauApporteurAfterInsert <<<');
}