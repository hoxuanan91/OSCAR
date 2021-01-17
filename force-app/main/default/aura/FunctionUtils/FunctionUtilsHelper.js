({
    //-------------------------------------------------------------------------------------------------------------------------------------
	//
    //-------------------------------------------------------------------------------------------------------------------------------------
    callServer : function( component, action, methodParams, fnCallbackSucessfull, fnCallbackError, showLoading ){
	
        var _this = this;
        
        var action = component.get("c." + action);
        if( methodParams != null ){
            action.setParams(methodParams);
        }
        
        if( typeof showLoading == "undefined" ){
            showLoading = true;
        }
        
        //show spinner
        if( showLoading ){
            this.startLoading(component);
        }
        
        
        action.setCallback(this,function(response){
			
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("success callback ok");
                //hide spinner
                if( showLoading ){
                	_this.endLoading(component);
                }
                
                var jsonResponse =  JSON.parse(JSON.stringify(response.getReturnValue()))
                fnCallbackSucessfull.call(_this,jsonResponse);
            }
            else if (state === "ERROR"){
            	
            	var messageError = "";
                var errors = response.getError();
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                    	messageError = errors[0].message;
                    } else if( errors[0] && errors[0].pageErrors && errors[0].pageErrors[0]){
                        errors[0].pageErrors.forEach(function (error) {
                            messageError += error.message + '\n';
                        });
                    } else if (errors[0].fieldErrors) {
                        for (var fieldName in errors[0].fieldErrors) {
                            errors[0].fieldErrors[fieldName].forEach( function (errorList){
                                messageError += fieldName + " : " + errorList.message + '\n';
                            });
                        }
                    }
                } else {
                    messageError = "Unknown error";
                }
                
                //Warning
                _this.showMessageError(messageError);
                _this.endLoading(component);
                
                //Callback error
                if(typeof fnCallbackError != "undefined" && fnCallbackError != null){
                    fnCallbackError.call(_this, messageError);
                }
            }
            
            else {
                console.log("Failed with state: " + state);
            }
        })
        
        $A.enqueueAction(action); 
        
    },
    
    
    startLoading : function(component){ 
        component.set("v.showSpinner", true);
    },
    
    endLoading : function(component){ 
        component.set("v.showSpinner", false);
    },
    
    confirm : function(component, message, successCallback){
        
        $A.createComponent(
            "c:ConfirmModal",
            {
                "message": message,
                "confirmMethod" : successCallback
            },
            function(cmpContent, status){
                
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(cmpContent);
                    component.set("v.body", body);
                }
            }
        ); 
        
    }, 
    
    showMessageError : function(messageError){
        
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent==null){
            toastEvent = $A.get("e.c:showToast");
        } 
        
        if(toastEvent!=null){
            toastEvent.setParams({ "title": "erreur", "message": messageError, "type" : "error", "mode" : "pester"});
            toastEvent.fire();   
        } else {
         	alert(messageError);   
        }
    }, 
    
    showMessageSuccess : function( messageSuccess ){
        
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent==null){
            toastEvent = $A.get("e.c:showToast");
        }
        
        if(toastEvent!=null){
            toastEvent.setParams({ "title": "Success", "message": messageSuccess, "type" : "success", "mode" : "sticky"});
            toastEvent.fire();   
        } else {
         	alert(messageSuccess);   
        }
    }, 
    
    showMessageInfo : function( messageInfo ){
        
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent==null){
            toastEvent = $A.get("e.c:showToast");
        }
        
        if(toastEvent!=null){
            toastEvent.setParams({ "title": "Information", "message": messageInfo, "type" : "info", "mode" : "sticky"});
            toastEvent.fire();   
        } else {
         	alert(messageSuccess);   
        }
    },  
    
    navigateToObject : function( objectId ){
        
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": objectId,
            "slideDevName": "detail"
        });
        sObjectEvent.fire(); 
    },
    
    uppercaseFirstChar : function( input ){
        
        if( $A.util.isEmpty(input)){
            return '';
        }
        return input.charAt(0).toUpperCase() + input.slice(1);
    }  
})