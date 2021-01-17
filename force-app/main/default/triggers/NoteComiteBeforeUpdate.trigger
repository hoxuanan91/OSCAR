trigger NoteComiteBeforeUpdate on NoteComite__c (before Update) {
     
    if(PAD.canTrigger('NoteComiteBeforeUpdate')){
        
        AP11NoteComite.recupererBienNoteComite(Trigger.new);
        AP11NoteComite.isPlusDeCinqDossiersSharedWithNoteComite(Trigger.new);
        AP11NoteComite.rapatrierDonnees(Trigger.new);
     }
    
}