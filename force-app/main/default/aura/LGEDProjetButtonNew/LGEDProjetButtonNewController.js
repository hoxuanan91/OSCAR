({
	doInit : function(component, event, helper) {
		helper.getProjet(component);
    },openActionWindow : function(component, event, helper) {
        var myproject = component.get("v.currentProjet");

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
            	
                window.open(url);
    }
})