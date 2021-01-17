trigger CaseBeforeDelete on Case (before delete) {
    if(PAD.scriptIsStarted('CaseBeforeDelete')) {
        return;
    }
System.debug('#### : CaseBeforeDelete');
    if(PAD.canTrigger('TR001ManageCase_DisableDeleteCase')) 
    {
        //Determination du profil de l'utilisateur connecté
        String IdProfile = userinfo.getProfileId().substring(0,15);
        
        //Empêcher la suppression si l'utilisateur connecté n'a pas le byPass
            for(Case c : Trigger.old)
                c.addError(Label.disableDeleteErrorMessage);

    }
}