({
    /**
    * @date 23/05/2019
    * @description Event on markers change
    * *****/
    handleMarkersChange : function(component, event, helper) {
        let container = component.find('map-container');
        
        //create a new map to override the old one because of a refreshing bug of the aura map component
        $A.createComponent(
            'lightning:map',
            {
                mapMarkers: component.get("v.markers"),
                style: 'height:500px'
            },
            (newComponent) => {
                container.set('v.body', [newComponent]);
            }
        );
	}
})