({   
    showMessageInfo : function(component, event, helper){
        
        var params = event.getParam("arguments");
        if(params){
            helper.showMessageInfo(params.message);
        }
    },
    
    showMessageSuccess : function(component, event, helper){
        
        var params = event.getParam("arguments");
        if(params){
            helper.showMessageSuccess(params.message);
        }
    },

    showMessageError : function(component, event, helper){

        var params = event.getParam("arguments");
        if(params){
            helper.showMessageError(params.message);
        }
    },
    
    startLoading : function(component, event, helper){
        helper.startLoading(component);
    },
    
    endLoading : function(component, event, helper){
        helper.endLoading(component);
    },  
    
	callServer : function(component, event, helper) {
        
        var params = event.getParam("arguments");
		helper.callServer( 
            			  params.component, 
                          params.methodName, 
                          params.params, 
                          params.successCallback, 
                          params.errorCallback, 
                          params.showLoading );
    },
    
    confirm : function(component, event, helper){
        
        var params = event.getParam("arguments");
        if(params){
            helper.confirm(component, params.message, params.successCallback);
        }
    },
    
    navigateToObject : function(component, event, helper){
        
        var params = event.getParam("arguments");
        if(params){
            helper.navigateToObject(params.objectId);
        }
    }       
})