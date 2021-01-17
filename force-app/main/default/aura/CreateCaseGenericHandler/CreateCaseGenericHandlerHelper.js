({
    initRecordForm : function(cmp, event, helper) {
        const $F = cmp.find("FunctionUtils");
        cmp.set('v.showSpinner', true);
        var that = this;
        
        $F.callServer(
            cmp,
            'initRecordForm',
            { 'recordId': cmp.get('v.recordId'),
             'sObjectName': cmp.get('v.sObjectName')},

            //success callback
            function(recordForm){
                var baseRecordForm = cmp.get('v._baseRecordForm');
                var sObjectName = cmp.get('v.sObjectName');
                recordForm = Object.assign({}, baseRecordForm, recordForm);
                var recordTypeAccessByCaseRecordType = recordForm.recordTypeAccessByCaseRecordType;
                var options = cmp.get('v.options');
                var newOptions = [];
                
                // Permettre d'afficher seulement une partie des recordtypes en fonction de la static CASE_ACCESS_FROM_OPPORTUNITY_BY_RECORDTYPE
                if (sObjectName == 'Opportunity') {
                    var caseAccessFromOpportunityByCaseRecordType = recordForm.caseAccessFromOpportunityByCaseRecordType;

                   for (var i=0; i < options.length;i++) {
                        if (caseAccessFromOpportunityByCaseRecordType[options[i].value] == true && recordTypeAccessByCaseRecordType[options[i].value] == true) {
                            newOptions.push(options[i]);
                        }
                   }
                   cmp.set('v.options', newOptions);
                }                
                else {
                    for (var i=0; i < options.length;i++) {
                       if (recordTypeAccessByCaseRecordType[options[i].value] == true) {
                            newOptions.push(options[i]);
                        }
                   }
                   cmp.set('v.options', newOptions);
                }				
                
                cmp.set('v.componentLightningByCaseRecordType', recordForm.componentLightningByCaseRecordType);
                cmp.set('v.recordForm', recordForm);
                cmp.set('v.showSpinner', false);
            },
            // error callback
            function(error){
                cmp.set('v.showSpinner', false);
                
                cmp.find('notifLib').showNotice({
                    'variant': 'error',
                    'header': 'Erreur',
                    'message': error,
                    closeCallback: function() {
                        that.closeModal(cmp);
                    }
                });
            },
            false
        );
    },

    createCase : function(cmp, event, helper) {console.log('COUCOU');
        const $F = cmp.find("FunctionUtils");
        cmp.set('v.showSpinner', true);

        var recordForm = event.getParam("recordForm");
        var recordTypeDeveloperName = event.getParam("recordTypeDeveloperName");


        $F.callServer(
            cmp,
            'saveCaseGeneric',
            { 'recordFormJSON': JSON.stringify(recordForm),
               'recordTypeDeveloperName': recordTypeDeveloperName},

            //success callback
            function(newCaseId){
                cmp.set('v.showSpinner', false);

                cmp.find('notifLib').showNotice({
                    'variant': 'info',
                    'header': 'Réussi',
                    'message': 'La demande a été créé.',
                    closeCallback: function() {
                        $A.get("e.force:closeQuickAction").fire();
                        $F.navigateToObject(newCaseId);
                    }
                });
            },
            // error callback
            function(error){
                cmp.set('v.showSpinner', false);

                cmp.find('notifLib').showNotice({
                    'variant': 'error',
                    'header': 'Erreur',
                    'message': error,
                    closeCallback: function() {}
                });
            },
            false
        );
    },

    closeModal : function(cmp) {
         $A.get("e.force:closeQuickAction").fire();
    }
})