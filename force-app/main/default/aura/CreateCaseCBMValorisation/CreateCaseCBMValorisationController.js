({
    onConfirmMessage : function (cmp, event, helper) {
        cmp.set('v.confirmMessage', true);
    },
    
    onConfirm : function(cmp, event, helper) {
        var recordForm = cmp.get('v.recordForm');

        /*
         * Vérification du formulaire
         */
        var isPrixHTValid = cmp.find("prixHT").get("v.validity");
        var isDureeEnMoisValid = cmp.find("dureeEnMois").get("v.validity");
        var isVRValid = cmp.find("vr").get("v.validity");
        
        if (!isPrixHTValid.valid || !isDureeEnMoisValid.valid || !isVRValid.valid) {
            return ;
        }
        
        if (recordForm.occasionNeuf.value == '2') {
            if (!confirm('Vous avez choisi matériel « NEUF », confirmez vous la création de la demande de Valorisation ?')) {
                return ;
            }
        }

        /*
         * Validation du formulaire
         */
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