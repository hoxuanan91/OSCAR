trigger AttachmentSaver on Attachment (before insert) {
    // Get the current user's profile name
    Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
    
    // If current user is not a System Administrator, do not allow Attachments to be deleted
   if ('Utilisateur standard'.equalsIgnoreCase(prof.Name)) {
       for (Attachment a : Trigger.new) {
            a.addError('Actuellement il est impossible de joindre des fichiers. Cette fonctionnalité sera de nouveau disponible Lundi matin 8h30.');
        }}
        else{   //  Pour Rien
          for (Attachment a : Trigger.new) { 
          Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];       
             }}
}