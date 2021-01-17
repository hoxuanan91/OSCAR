({
    /**
    * @date 23/05/2019
    * @description Evenement lors de changement dans la recherche
    * *****/
    handleSearchChange : function (component, event, helper) {
        var search = component.get("v.search");
        
        if(search == true){
            //get results objects
			var action = component.get( "c.getObjects" );
            action.setParams({
                objectToSearch: component.get("v.object"),
                fields: component.get("v.fields"),
                filtersArray: JSON.stringify(component.get("v.filtersArray"))
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set( "v.results", response.getReturnValue());
                    component.set( "v.search", false );
                }
                console.log(response.getError());
            });
            
            $A.enqueueAction(action);
        }
    }
})