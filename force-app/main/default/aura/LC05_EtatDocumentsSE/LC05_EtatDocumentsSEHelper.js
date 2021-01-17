({
    doInit : function(cmp){
        var action = cmp.get('c.doInit_APEX');

        action.setParams({oppId : cmp.get('v.recordId')});

        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                cmp.set('v.dataWrapper', response.getReturnValue());
            }
            console.log(cmp.get('v.dataWrapper'));
        });
        $A.enqueueAction(action);
    }
})