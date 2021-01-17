trigger NoteComiteAfterDelete on NoteComite__c (after delete) {
/* 
------------------------------------------------------------
-- - Name          : NoteComiteAfterDelete
-- - Author        : Cap Gemini
-- - Description   : Trigger Note Comite After Delete
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- O1-NOV-2015  NBL   1.0      Initial version
*/
 system.Debug('>>> START NoteComiteAfterDelete <<< run by ' + UserInfo.getName());

    if(PAD.canTrigger('NoteComiteAfterDelete')){
        
    	AP11NoteComite.nettoyageDesDonnees(Trigger.old);
        
     }
    
    system.Debug('>>> END NoteComiteAfterDelete <<<');
}