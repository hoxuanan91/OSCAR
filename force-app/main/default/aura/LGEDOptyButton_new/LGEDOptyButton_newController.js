({
	doInit : function(component, event, helper) {
		helper.getOptyCustom(component);
    },openActionWindow : function(component, event, helper) {
        var myopty = component.get("v.currentopty");

        var NDoss = myopty.NDuDossierCassiopae__c;        
        var NomCli = myopty.NomClient__c;  
        var CodeSoc = $A.get("$Label.c.CODE_SOCIETE_NL");       
        var NEngV4 = myopty.NEngagementV4__c; 
        var CTiers = myopty.CodeTiers__c; 
        var UrlBase = $A.get("$Label.c.URL_GED_BASE");
        
        if (!$A.util.isEmpty(NDoss)){
            NDoss = myopty.NDuDossierCassiopae__c.replace("/","-"); 
        } else {
            NDoss = "";
        }  
 
        if ($A.util.isEmpty(NomCli)){
            NomCli = ""; 
        }           

        if ($A.util.isEmpty(NEngV4)){
            NEngV4 = ""; 
        } 

        if ($A.util.isEmpty(CTiers)){
            CTiers = ""; 
        }
        
        // Condition 1  :  NDuDossierCassiopae est rempli
        if (!$A.util.isEmpty(NDoss)){         
            	var url = UrlBase;
                var scope =                   
                    {
                    	"pcd": "DOSCBM",
                    	"refmetierprinc": {
                    		"refmetier": {
                    			"ref": [{
                    				"id": "NDOSSIER",
                    				"value": NDoss
                    			}, {
                    				"id": "NSOCIETE",
                    				"value": CodeSoc
                    			}]
                    		}
                    	},
                    	"refMetierSup": {
                    		"refmetier": [{
                    			"ref": {
                    				"id": "NUMENGAGEMENT",
                    				"value": NEngV4
                    			}
                    		}, {
                    			"ref": {
                    				"id": "NUMCLIENT",
                    				"value": CTiers
                    			}
                    		}, {
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
        // Condition 2  :  NDuDossierCassiopae est vide
        else {
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
                    		}, {
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
    }
})