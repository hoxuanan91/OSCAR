trigger DossierAfterDelete on Contract (after delete) {
/*
------------------------------------------------------------
-- - Name          : DossierAfterDelete
-- - Author        : Cap Gemini
-- - Description   : Trigger Dossier After Delete
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- 16-JUIL-2015  NBL   1.0      Initial version
*/
  system.Debug('>>> START DossierAfterDelete <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('DossierAfterDelete')){
        
      AP07Dossier.nettoyageDesDonnees(Trigger.old);
        
    }

    system.Debug('>>> END DossierAfterDelete <<<');
}