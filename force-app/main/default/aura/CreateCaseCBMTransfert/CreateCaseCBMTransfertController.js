({
    onConfirm : function(cmp, event, helper) {
        var recordForm = cmp.get('v.recordForm');

        if ($A.util.isEmpty(recordForm.transfert.value) || $A.util.isEmpty(recordForm.accordDemandeDelegBanque) ||
            $A.util.isEmpty(recordForm.accordDemandeDEC) || $A.util.isEmpty(recordForm.accordDemandeBPICoBailleur)) {

            cmp.set('v.errorMessage', 'Les champs suivants doivent être remplis:<br/>' +
                                       '• transfert<br/>' +
                                       '• Accord demandé à la deleg/banque<br/>' +
                                       '• Accord demandé à la DEC<br/>' +
                                       '• Accord demandé à BPI/Co-bailleurs');
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