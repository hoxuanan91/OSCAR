trigger ContentDocumentBeforeDelete on ContentDocument (before delete) {
  
   // Get the current user's profile name
  Profile prof = [select Name from Profile where Id = :UserInfo.getProfileId() ];
  
  // If current user is not a System Administrator, do not allow Attachments to be deleted
  if (!'System Administrator'.equalsIgnoreCase(prof.Name) ||  Test.isRunningTest()) {
    for(ContentDocument cd :Trigger.old){
        cd.addError(Label.CL13_SuppressionPieceJointe);
    }
  }
}