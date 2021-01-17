({
	doInit : function(component, event, helper) {
		var action = component.get("c.getCaseCustom");
        action.setParams({"caseId":component.get("v.recordId")});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var caseGot = response.getReturnValue();
                if(caseGot != null){
                    if(caseGot.NEngagementV4__c != null){
                       caseGot.NEngagementV4__c = caseGot.NEngagementV4__c.replace('/','-'); 
                    }
                    if(caseGot.NDuDossierCassiopae__c != null){
                       caseGot.NDuDossierCassiopae__c = caseGot.NDuDossierCassiopae__c.replace('/','-'); 
                    }
                }
                component.set("v.currentcase",caseGot);
            } else {
                console.log('Problem getting case, response state: '+ state);
            }
        });
        $A.enqueueAction(action);
	},
    handleCancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})