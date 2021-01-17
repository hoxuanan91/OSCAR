({
	doInit : function(component, event, helper) {
		var action = component.get("c.getProjet");
        action.setParams({"projetId":component.get("v.recordId")});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var projetGot = response.getReturnValue();
                if(projetGot != null){
                    if(projetGot.NEngagementV4__c != null){
                       projetGot.NEngagementV4__c = projetGot.NEngagementV4__c.replace('/','-'); 
                    }
                    if(projetGot.NDuDossierCassiopae__c != null){
                       projetGot.NDuDossierCassiopae__c = projetGot.NDuDossierCassiopae__c.replace('/','-'); 
                    }
                }
                component.set("v.projet",projetGot);
            } else {
                console.log('Problem getting projet, response state: '+ state);
            }
        });
        $A.enqueueAction(action);
	},
    handleCancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})