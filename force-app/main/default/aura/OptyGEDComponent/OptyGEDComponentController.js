({
	doInit : function(component, event, helper) {
		var action = component.get("c.getOptyCustom");
        action.setParams({"opportunityId":component.get("v.recordId")});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var optyGot = response.getReturnValue();
                if(optyGot != null){
                    if(optyGot.NEngagementV4__c != null){
                       optyGot.NEngagementV4__c = optyGot.NEngagementV4__c.replace('/','-'); 
                    }
                    if(optyGot.NDuDossierCassiopae__c != null){
                       optyGot.NDuDossierCassiopae__c = optyGot.NDuDossierCassiopae__c.replace('/','-'); 
                    }
                }
                component.set("v.opty",optyGot);
            } else {
                console.log('Problem getting opty, response state: '+ state);
            }
        });
        $A.enqueueAction(action);
	},
    handleCancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})