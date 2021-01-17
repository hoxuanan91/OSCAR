trigger NoteComiteAfterUpdate on NoteComite__c (after update) {
/* 
------------------------------------------------------------
-- - Name          : NoteComiteAfterUpdate
-- - Author        : Cap Gemini
-- - Description   : Trigger Note Comite After Update
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- O4-SEPT-2015  NBL   1.0      Initial version
*/
 system.Debug('>>> START NoteComiteAfterUpdate <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('NoteComiteAfterUpdate')){
        
        	AP11NoteComite.recuperListeDeBiens(Trigger.new);
            AP11NoteComite.mettreAJourDonnees(Trigger.new);
            AP11NoteComite.ajoutNoteComiteSurCalculatrice(Trigger.old, Trigger.new);
        	//AP11NoteComite.isPlusDeCinqDossiersSharedWithNoteComite(Trigger.new);
        }
    
    
    system.Debug('>>> END ReseauApporteurAfterInsert <<<');
}