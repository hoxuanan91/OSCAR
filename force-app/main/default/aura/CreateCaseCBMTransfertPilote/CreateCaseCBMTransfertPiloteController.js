({
    onConfirm : function(cmp, event, helper) {
        var recordForm = cmp.get('v.recordForm');

        if ($A.util.isEmpty(recordForm.transfert.value) || $A.util.isEmpty(recordForm.typeTransfert.value) ||
            $A.util.isEmpty(recordForm.receptionEnDelegation)) {

            cmp.set('v.errorMessage', 'Les champs suivants doivent être remplis:<br/>' +
                     				   '• Date réception en délégation<br/>' +
                                       '• Transfert<br/>' +
                                       '• Type Transfert<br/>');
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
    },
     itemsChange: function(cmp, evt) {
        component.set('v.currentZoneRecommandation', 'test');
    }
})