({
	doInit : function(component, event, helper) {
		var action = component.get("c.getAccount");
        action.setParams({"accountId":component.get("v.recordId")});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var myaccount = response.getReturnValue();
                if(myaccount != null){
                    
                component.set("v.CurrentAccount",myaccount);                
     
        var NomCli = myaccount.NomClient__c;  
        var CTiers = myaccount.Code_Tiers__c; 
        var UrlBase = $A.get("$Label.c.URL_GED_BASE");
 
        if ($A.util.isEmpty(NomCli)){
            NomCli = ""; 
        }           


        if ($A.util.isEmpty(CTiers)){
            CTiers = ""; 
        }
        
            	var url = UrlBase;
                var scope =                   
                    {
                    	"pcd": "DOSCBM",
                    	"refmetierprinc": {
                    		"refmetier": {
                    			"ref": [{
                    				"id": "NUMCLIENT",
                    				"value": CTiers
                    			}]
                    		}
                    	},
                    	"refMetierSup": {
                    		"refmetier": [{
                    			"ref": {
                    				"id": "NOMCLIENT",
                    				"value": NomCli
                    			}
                    		}]
                    	}
                    };
                url = url + encodeURIComponent(JSON.stringify(scope));
            	component.set("v.url",url);

                }
                }
                
        });
        $A.enqueueAction(action);
	},
    handleCancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})