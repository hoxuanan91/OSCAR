({
   openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
   },
 
   handleAssignment: function(component, event, helper) {
      var currentCase = component.get("v.simpleRecord");       
      var action = component.get('c.updateCase'); 
      
        action.setParams({
            "recordId" : component.get('v.recordId'),
            "businessUnit": component.get('v.simpleRecord.Dossier1__r.BusinessUnit__c'),
            "dateEnvoieEnGestion": component.get('v.simpleRecord.Datedenvoiengestion__c'),
            "status": component.get('v.simpleRecord.Status')
            
            
        });
       action.setCallback(this, function(response){
            var state = response.getState(); // get the response state
            if(state == "SUCCESS") {
                component.set("v.result", response.getReturnValue());
                component.set("v.isOpen", false);
                $A.get('e.force:refreshView').fire();
               
            }
        });
        $A.enqueueAction(action);
      
   }
})