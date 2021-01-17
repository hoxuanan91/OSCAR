({
    loadJobFromServer : function(component) {
        var action = component.get("c.getAllBulkJob");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                component.set('v.jobList',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    searchJob : function(component) {
        var action = component.get("c.searchAllBulkJob");
        action.setParams({ objectName : component.get("v.objectName"), operation : component.get("v.operation"), currentDate : component.get("v.currentDate") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                component.set('v.jobList',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    reexecuteJob : function(component) {
        var action = component.get("c.setReexecuteJob");
        var jobList = component.get("v.jobList");
        debugger;
        action.setParams({ jobList : jobList });
        that = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                that.loadJobFromServer(component);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "La re-plannification est enregistrée !!!",
                    mode: 'dismissible',
                    type: 'success'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})