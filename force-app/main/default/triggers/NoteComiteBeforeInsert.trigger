trigger NoteComiteBeforeInsert on NoteComite__c (before insert) {
/* 
------------------------------------------------------------
-- - Name          : NoteComiteBeforeInsert
-- - Author        : Cap Gemini
-- - Description   : Trigger Note Comite Before Insert
-- 
-- Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  -----------------------------
-- O4-SEPT-2015  NBL   1.0      Initial version
*/
 system.Debug('>>> START NoteComiteBeforeInsert <<< run by ' + UserInfo.getName());
    
    if(PAD.canTrigger('NoteComiteBeforeInsert')){
        
        	AP11NoteComite.recupererBienNoteComite(Trigger.new);
        	//maj à jour de la calculatrice pour y stocker l'id + le nom + incrémentation du nombre de proposition.
        	AP11NoteComite.rapatrierDonnees(Trigger.new);
        
        }
    
    
    system.Debug('>>> END NoteComiteBeforeInsert <<<');
}