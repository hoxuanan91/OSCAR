({    
    /**
    * @date 23/05/2019
    * @description Event navigate to record
    * *****/
    navigateToRecord: function( component, event, helper ) {
        var row = event.getParam( 'row' );
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": row.Id,
            "slideDevName": "related"
        });
        navEvt.fire();
    }
})