({
    onConfirm : function(cmp, event, helper) {
        var recordForm = cmp.get('v.recordForm');

        if ($A.util.isEmpty(recordForm.niveauDeReclamation.value) || $A.util.isEmpty(recordForm.motifReglementaire.value) ||
            $A.util.isEmpty(recordForm.motifQualite.value) || $A.util.isEmpty(recordForm.canal.value) ||
            $A.util.isEmpty(recordForm.dateReceptionDemande)) {

            cmp.set('v.errorMessage', 'Les champs suivants doivent être remplis:<br/>' +
                                       '• niveau de réclamation<br/>' +
                                       '• motif réglementaire<br/>' +
                                       '• motif qualité<br/>' +
                                       '• canal<br/>' +
                                       '• date de réception de la demande');
           return false;
        }
        cmp.set('v.errorMessage', '');

        var cmpEvent = cmp.getEvent("createCase");

        cmpEvent.setParams({
            "recordForm" : cmp.get('v.recordForm'),
            "recordTypeDeveloperName" : cmp.get('v.recordTypeDeveloperName')});
        cmpEvent.fire();
    },

    onClose : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})