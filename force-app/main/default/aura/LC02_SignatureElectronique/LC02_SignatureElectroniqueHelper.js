({
	doInit : function(cmp){
		var action = cmp.get('c.doInit_APEX');
        
        action.setParams({oppId : cmp.get('v.recordId')});
        
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('toto');
                cmp.set('v.oppWrapper', response.getReturnValue());
            }
            console.log(cmp.get('v.oppWrapper'));
        });
        $A.enqueueAction(action);
    },
    
    goNext : function(cmp){
        if(cmp.get('v.oppWrapper.signataire.email') == '' ||
        cmp.get('v.oppWrapper.signataire.phoneNumber') == '' ||
        cmp.get('v.oppWrapper.signataire.email') == '' ||
        cmp.get('v.oppWrapper.signataire.lastName') == '' ||
        cmp.get('v.oppWrapper.signataire.typeDocument') == 'aucun'){
            
            $A.get('e.force:showToast').setParams({title : 'Attention', 
                                                    type : 'warning',
                                                    message : 'Veuillez remplir tous les champs avant de continuer'}).fire();
        }
        else{
            cmp.set('v.isSignataireFilled', true);
            var stepOne = cmp.find("stepOne");
            $A.util.toggleClass(stepOne, 'slds-hide');
            console.log('@@ true');
        }
    },

    fillSignerFields : function(cmp){
        if(cmp.get('v.selectedValueSignataire') == 'aucun'){
            cmp.set('v.oppWrapper.signataire.email', '');
            cmp.set('v.oppWrapper.signataire.phoneNumber', '');
            cmp.set('v.oppWrapper.signataire.firstName', '');
            cmp.set('v.oppWrapper.signataire.lastName', '');
            cmp.set('v.oppWrapper.signataire.typeDocument', 'aucun');
        }
        else{
            var allSignataires = cmp.get('v.oppWrapper.infosSignataires');
            
            allSignataires.forEach(function(item, index, array){
                if(item.Id == cmp.get('v.selectedValueSignataire')){
                    cmp.set('v.oppWrapper.signataire.email', item.Email__c);
                    cmp.set('v.oppWrapper.signataire.phoneNumber', item.Telephone__c);
                    cmp.set('v.oppWrapper.signataire.firstName', item.Prenom__c);
                    cmp.set('v.oppWrapper.signataire.lastName', item.Nom__c);
                    cmp.set('v.oppWrapper.signataire.typeDocument', item.Type_de_document__c);
                    console.log(cmp.get('v.selecselectedValueSignatairetedValue'));
                    console.log(item);
                }
            });
        }
    },

    checkAlreadyExist : function(cmp){
        var allSignataires = cmp.get('v.oppWrapper.infosSignataires');
        var emailAlreadyExist = false;

        allSignataires.forEach(function(item, index, array){
            if(item.Email__c == cmp.get('v.oppWrapper.signataire.email')){
                emailAlreadyExist = true;
                console.log(cmp.get('v.oppWrapper.signataire.email'));
                console.log(item.Email__c);
            }
        });

        if(emailAlreadyExist){
            cmp.set('v.checkAlreadyExist', true);
            var stepTwo = cmp.find("stepTwo");
            $A.util.toggleClass(stepTwo, 'slds-hide');
            console.log('@@ true');
        }
        else{
            console.log('On envoie')
            this.sendESignatureRequest(cmp, true)
        }
    },

    sendESignatureRequest : function(cmp, create){ 
        cmp.set('v.isDisabled', true);
        cmp.set('v.isOpen', false);
        cmp.set('v.isLoading', true);

        console.log(create);
        var action = cmp.get('c.requestESignature');
        console.log(JSON.stringify(cmp.get('v.oppWrapper')));
        
        action.setParams({
            "recordId" : cmp.get('v.recordId'),
            "dosIdExt": cmp.get('v.oppWrapper.dosIdExt'),
            "numEngagementV4": cmp.get('v.oppWrapper.numEngagementV4'),
            "oppWrapperJSON" :  JSON.stringify(cmp.get('v.oppWrapper')),
            "hasToBeCreated" : create
        });
        
        action.setCallback(this, function(response){
            var state = response.getState(); // get the response state
            if(state === "SUCCESS") {
                
                console.log(response.getReturnValue().responseBody);
                
                if(response.getReturnValue().statusCode === 200 || 
                   response.getReturnValue().statusCode === 201 || 
                   response.getReturnValue().statusCode === 206 || 
                   response.getReturnValue().statusCode === 409){
                    $A.get('e.force:refreshView').fire();
                    $A.get('e.force:showToast').setParams({title : 'Succès', 
                                                           type : 'success',
                                                           duration : 8000,
                                                           message : 'La demande de signature a bien été envoyée.'}).fire();
                    cmp.set('v.oppWrapper.buttonDisabled', true);
                }
                else if(response.getReturnValue().statusCode === 504){
                    $A.get('e.force:showToast').setParams({title : 'Avertissement', 
                                                           type : 'warning',
                                                           duration : 8000,
                                                           message : 'Un incident est survenu, veuillez relancer la signature électronique. Si le problème persiste contactez votre administrateur en lui donnant le message suivant : ' + response.getReturnValue().statusCode}).fire();
                }
                    else if(response.getReturnValue().statusCode === 404){
                        $A.get('e.force:showToast').setParams({title : 'Erreur', 
                                                               type : 'error',
                                                               duration : 8000,
                                                               message : 'Aucun document à signer, ce document est à éditer depuis Front V4.'}).fire();
                    }
                        else{
                            $A.get('e.force:showToast').setParams({title : 'Erreur', 
                                                                   type : 'error',
                                                                   duration : 8000,
                                                                   message : 'Une erreur est survenue : ' + response.getReturnValue().statusCode + '. Si ce problème vous est inconnu, veuillez contacter votre administrateur.'}).fire();
                        }
            }
            cmp.set('v.isLoading', false);
            cmp.set('v.isDisabled', false);
        });
        $A.enqueueAction(action);
    },
    
    rewriteSubquery : function(array) {
        if (array && !array.hasOwnProperty('records')) {
            var tempArray = array;
            array = {
                totalSize: tempArray.length,
                done: true,
                records: tempArray
            }
        }
        return array;
	}
})