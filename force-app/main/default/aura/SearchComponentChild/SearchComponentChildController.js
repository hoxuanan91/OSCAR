({
    /**
    * @date 23/05/2019
    * @description Event on filter value change
    * *****/
    onSearchTermChange: function( component, event, helper ) {
        setTimeout($A.getCallback(function() {component.set( "v.search", true )}), 500 );
    }
})