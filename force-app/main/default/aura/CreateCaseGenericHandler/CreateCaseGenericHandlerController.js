({
    doInit : function(cmp, event, helper) {
        helper.initRecordForm(cmp, event, helper);
    },

    nextStep : function(cmp, event, helper) {
        var recordTypeDeveloperName = cmp.get('v.recordTypeDeveloperName');
        var recordForm = cmp.get('v.recordForm');
        var componentName = recordForm.componentLightningByCaseRecordType[recordTypeDeveloperName];
        var currentZoneRecommandation = recordForm.caseZonesRecommandationsByCaseRecordType[recordTypeDeveloperName];
        var options = cmp.get('v.options');

        options.forEach(function (item) {
            if (item.value == recordTypeDeveloperName) {
                cmp.set('v.currentLabelCase', item.label);
            }
        })
        cmp.set('v.currentZoneRecommandation', currentZoneRecommandation);
        cmp.set('v.componentName', componentName);
    },

    createCase : function (cmp, event, helper) {
        helper.createCase(cmp, event, helper);
    },
    
    closeModal : function(cmp, event, helper) {
         helper.closeModal(cmp);
    },
})