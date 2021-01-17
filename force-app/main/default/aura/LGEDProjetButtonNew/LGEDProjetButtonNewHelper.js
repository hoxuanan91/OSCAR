({
    getProjet : function(component){
     var action = component.get("c.getProjet");
     var self = this;
        action.setParams({projetId:component.get("v.recordId")}); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.currentProjet",response.getReturnValue());
                self.getCustomRefs(component);
            } else {
                console.log('Problem getting Projet, response state: '+ state);
            }
        });
        $A.enqueueAction(action);   
    },
    getCustomRefs : function(component){
     var rec2 = component.get("v.currentProjet");
     var action = component.get("c.getCustomRefs");
     console.log('recordtype '+rec2.RecordType.DeveloperName);
     action.setParams({recordType:rec2.RecordType.DeveloperName}); 
     action.setCallback(this, function(response){
     var state = response.getState();
     	if(component.isValid() && state == "SUCCESS"){
            var ref = response.getReturnValue();
        	component.set("v.customRefs",ref);
            //console.log('Ref values '+ref.RefMetierPrincipale__c+' '+ref.RefOscar__c+' '+ref.RefMetierSup__c);
            component.find("GEDbutton").set("v.disabled", false); 
        } else {
            console.log('Problem getting ged references, response state: '+ state);
        }
     });
     $A.enqueueAction(action);   
    }
})