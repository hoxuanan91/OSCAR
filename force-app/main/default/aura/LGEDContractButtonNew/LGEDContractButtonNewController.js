({
	doInit : function(component, event, helper) {
		helper.getContract(component);
    },openActionWindow : function(component, event, helper) {
        var mycontract = component.get("v.currentContract");

        var NDoss = mycontract.Name;        
        var NomCli = mycontract.NomClient__c;  
        var CodeSoc = $A.get("$Label.c.CODE_SOCIETE_NL");       
        var NEngV4 = mycontract.NEngagementV4__c; 
        var CTiers = mycontract.Account.Code_Tiers__c; 
        var UrlBase = $A.get("$Label.c.URL_GED_BASE");
        
        if (!$A.util.isEmpty(NDoss)){
            NDoss = mycontract.Name.replace("/","-"); 
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
})