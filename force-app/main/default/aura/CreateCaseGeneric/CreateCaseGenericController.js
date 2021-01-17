({
    onConfirm : function(cmp, event, helper) {
        var cmpEvent = cmp.getEvent('createCase');

        cmpEvent.setParams({
            "recordForm" : cmp.get('v.recordForm'),
            "recordTypeDeveloperName" : cmp.get('v.recordTypeDeveloperName')});
        cmpEvent.fire();
    },

    onClose : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})