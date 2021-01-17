({
	getRejetsEnCours : function(cmp, event, helper) {
        const $F = cmp.find("FunctionUtils");
        cmp.set('v.showSpinner', true);

        var recordForm = event.getParam("recordForm");
        var recordTypeDeveloperName = event.getParam("recordTypeDeveloperName");


        $F.callServer(
            cmp,
            'getRejetsEnCours',
            { 'opportunityId': cmp.get('v.recordId')},

            //success callback
            function(recordForm){
                cmp.set('v.showSpinner', false);
                
                cmp.set('v.columns', [
                                        {label: 'Nature de l\'envoi', fieldName: 'natureDeLenvoi', type: 'text', initialWidth: 135},
                                        {label: 'Type de contrôle', fieldName: 'typeDeControle', type: 'text'},
                                        {label: 'Type de document', fieldName: 'typeDeDocument', type: 'text', initialWidth: 120},
                    {label: 'Intitulé du contrôle', fieldName: 'intituleDuControle', type: 'text', initialWidth: 200}]);
                
                if (recordForm.ctrlMetierWrapperList.length == 0) {
                    cmp.set('v.data', null);
                } else {
                 	cmp.set('v.data', recordForm.ctrlMetierWrapperList);
                }
                cmp.set('v.recordForm', recordForm);
                cmp.set('v.options', recordForm.natureDeLenvoiForce);
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
    
    save : function(cmp, event, helper) {
        const $F = cmp.find("FunctionUtils");
        cmp.set('v.showSpinner', true);

        var resultForm = cmp.get('v.resultForm');

        $F.callServer(
            cmp,
            'forcerLesRejets',
            {'opportunityId': cmp.get('v.recordId'),
             'resultFormJSON': JSON.stringify(resultForm)},

            //success callback
            function(success){
                cmp.set('v.showSpinner', false);
                
                cmp.find('notifLib').showNotice({
                    'variant': 'info',
                    'header': 'Réussi',
                    'message': 'Forçage effectué',
                    closeCallback: function() {
                        $A.get("e.force:closeQuickAction").fire();
                         $A.get('e.force:refreshView').fire();
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
    }
})