trigger DossierAfterUpdate on Contract (after update) {
/* 
------------------------------------------------------------
-- - Name          : DossierAfterUpdate
-- - Author        : Cap Gemini
-- - Description   : Trigger Dossier After Update
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 16-JUIL-2015  NBL   1.0      Initial version
*/
  system.Debug('>>> START DossierAfterUpdate <<< run by ' + UserInfo.getName());

    if(PAD.canTrigger('DossierAfterUpdate')){

      List<Contract> contractsCBM = new List<Contract>();

      for(Contract c : [SELECT Id, 
                              Name, 
                              Commissionnaire__c, 
                              (SELECT Id, 
                                      Dossier1__c, 
                                      Commissionnaire__c 
                              FROM Demandes__r
                              WHERE IsClosed = false)
                        FROM Contract 
                        WHERE Id IN: Trigger.newMap.keySet()
                        AND RecordType.DeveloperName = 'CBMDossier']){
        contractsCBM.add(c);
      }

      if(!contractsCBM.isEmpty()){
        AP07Dossier.mettreAJourDonnees(contractsCBM);
      }
    }

  system.Debug('>>> END DossierAfterUpdate <<<');
}