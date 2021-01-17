trigger NoteComiteAfterInsert on NoteComite__c (after insert) {
/* 
------------------------------------------------------------
-- - Name          : NoteComiteAfterInsert
-- - Author        : Cap Gemini
-- - Description   : Trigger Note Comite After Insert
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- O3-SEPT-2015  NBL   1.0      Initial version
*/
 system.Debug('>>> START NoteComiteAfterInsert <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('NoteComiteAfterInsert')){
        
        	AP11NoteComite.recuperListeDeBiens(Trigger.new);
        	AP11NoteComite.ajoutNoteComiteSurCalculatrice(null, Trigger.new);
            AP11NoteComite.mettreAJourDonnees(Trigger.new);
        }
    
    
    system.Debug('>>> END ReseauApporteurAfterInsert <<<');
}