({
	loadEmail : function(cmp, event, helper) {
        var action = cmp.get("c.loadEmail");
        
        action.setParams({ fieldName : cmp.get('v.emailField'), recordId : cmp.get('v.recordId'), objectName : cmp.get('v.ObjectName')});

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				cmp.set('v.Email', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})