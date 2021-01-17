({
	doInit : function(cmp, event, helper) {
		helper.getRejetsEnCours(cmp, event, helper);
	},
    
    save : function(cmp, event, helper) {
        var recordForm = cmp.get('v.recordForm');
        var natureEnvoiForceValue = cmp.get('v.resultForm.natureEnvoiForce');
        
        /*
         * Vérification du formulaire
         */
        var motifForcage = cmp.find("motifForcage").get("v.validity");
        var natureEnvoiForce = cmp.find("natureEnvoiForce").get("v.validity");
        var motifForcageMessageInvalid = cmp.find("natureEnvoiForce");
        var natureEnvoiForceMessageInvalid = cmp.find("motifForcage");
        
        if (!motifForcage.valid || !natureEnvoiForce.valid) {
            motifForcageMessageInvalid.showHelpMessageIfInvalid();
            natureEnvoiForceMessageInvalid.showHelpMessageIfInvalid();
            return ;
        } else if (recordForm.opp.DateStatut423PVFactRecuesVerif__c == null && recordForm.opp.DateEnvoi2Docapost__c != null && recordForm.opp.DateRetour2DocapostOK__c == null &&
                  	natureEnvoiForceValue == '3' && !recordForm.ForcageControlesMetiers__c) {
            cmp.find('notifLib').showNotice({
                    'variant': 'error',
                    'header': 'Erreur',
                    'message': 'Impossible de forcer l\'envoi docapost 2 si la décision 423 n\'est pas remontée dans OSCAR.',
                    closeCallback: function() {}
            });
            return ;
        }
        var resultForm = cmp.get('v.resultForm');
        
        helper.save(cmp, event, helper);
    },
    
    closeModal : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})