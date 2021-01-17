({
	doInit : function(component, event, helper) {
		var action = component.get("c.getProjet");
        action.setParams({"projetId":component.get("v.recordId")});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var myproject = response.getReturnValue();
                if(myproject != null){
                    
                component.set("v.projet",myproject);                
     
        var NomCli = myproject.NomClient__c;      
        var NEngV4 = myproject.NEnveloppe__c; 
        var CTiers = myproject.CodeTiers2__c; 
        var UrlBase = $A.get("$Label.c.URL_GED_BASE");
 
        if ($A.util.isEmpty(NomCli)){
            NomCli = ""; 
        }           

        if ($A.util.isEmpty(NEngV4)){
            NEngV4 = ""; 
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
                    				"id": "NUMENGAGEMENT",
                    				"value": NEngV4
                    			}]
                    		}
                    	},
                    	"refMetierSup": {
                    		"refmetier": [{
                    			"ref": {
                    				"id": "NUMCLIENT",
                    				"value": CTiers
                    			}
                    		},{
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