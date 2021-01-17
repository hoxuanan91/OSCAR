({
    /**
    * @date 23/05/2019
    * @description Format a results array to a marker array
    * @params results : a results array format [{Phone, Website, BillingStreet, BillingCity, BillingPostalCode, name}]
    * *****/
	formatResultToMarker : function(results) {
        var mapMarkers = [];
        
        for ( var i = 0; i < results.length; i++ ) {
            var aResult = results[i];
            var description = "";

            if(aResult.Phone != undefined)
                description += 'Téléphone : ' + aResult.Phone + '<br />';

            if(aResult.Phone != undefined)
                description += 'Phone : ' + aResult.Phone;
            
            var marker = {
                'location': {
                    'Street': aResult.BillingStreet != undefined ? aResult.BillingStreet : '',
                    'City': aResult.BillingCity != undefined ? aResult.BillingCity : '',
                    'PostalCode': aResult.BillingPostalCode != undefined ? aResult.BillingPostalCode : '',
                },
                'title': aResult.Name,
                'description': description,
                'icon': 'standard:location'
            };
            
            mapMarkers.push( marker );
        }
        
        return mapMarkers;
	},
    
    /**
    * @description Get avalaible picklist values and call a callback
    * @params component : the component (object)
	* @params objectName : the related object name (string)
	* @params fieldName : the related field name (string)
	* @params firstVal : the first value to add to the picklist (firsval)
	* @params callback : the callback (function)
    * *****/
    getPicklistOptions : function(component, objectName, fieldName, firstVal, callback){
        //call apex function
        var action = component.get( "c.getPickValues" );
        action.setParams({
            objectName: objectName,
            fieldName: fieldName,
            firstVal: firstVal
        });
        
        // on response
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //execute callback
                callback(response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
	}
})