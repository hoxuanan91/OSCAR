({
	doInit : function(component, event, helper) {
		helper.getCaseCustom(component);
    },openActionWindow2 : function(component, event, helper) {
        var mycase = component.get("v.currentcase");
        
        var NDoss = mycase.N_du_Dossier__c;        
        var NomCli = mycase.NomClient__c;  
        var CodeSoc = $A.get("$Label.c.CODE_SOCIETE_NL");       
        var NEngV4 = mycase.NEngagementV4__c; 
        var CTiers = mycase.CodeTiers__c; 
        var NDemande = mycase.CaseNumber; 
        var RT = mycase.RecordType.DeveloperName;         
        var UrlBase = $A.get("$Label.c.URL_GED_BASE");
        
        if (!$A.util.isEmpty(NDoss)){
            NDoss = mycase.N_du_Dossier__c.replace("/","-"); 
        } else {
            NDoss = "";
        }  

        if ($A.util.isEmpty(NEngV4)){
            NEngV4 = "" 
        }            

        if ($A.util.isEmpty(CTiers)){
            CTiers = "" 
        }          

        if ($A.util.isEmpty(NomCli)){
            NomCli = "" 
        }         
        
        // Condition 1  :  Pour toutes les Demandes CBM hors Action de recouvrement, Octroi de Crédit DEN, DRI et Waiver
        if (RT.includes("CBM") && RT !== "CBM_Actions_de_Recouvrement" && RT !== "CBMOctroiCreditDEN" && RT !== "CBMOctroiCreditDRI" && RT !== "CBMWaiver"){         
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
                    	"refoscar": {
                    		"ref": {
                    			"id": "NUMDEMANDECRM",
                    			"value": NDemande
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
            	
                window.open(url)
         }
        // Condition 2  :  Pour les Demandes CBM Action de recouvrement
        else if (RT == "CBM_Actions_de_Recouvrement"){         
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
                    	"refoscar": {
                    		"ref": {
                    			"id": "NUMDEMANDECRM",
                    			"value": NDemande
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
            	
                window.open(url)   
        }
        // Condition 3 : Pour les Demandes d'Octroi DEN, DRI et les Waiver
        else if (RT == "CBMOctroiCreditDEN" || RT == "CBMOctroiCreditDRI" || RT == "CBMWaiver"){
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
                    			"ref": [{
                    				"id": "NDOSSIER",
                    				"value": NDoss
                    			}, {
                    				"id": "NSOCIETE",
                    				"value": CodeSoc
                    			}]
                    		}, {
                    			"ref": {
                    				"id": "NOMCLIENT",
                    				"value": NomCli
                    			}
                    		}]
                    	}
                    };
                url = url + encodeURIComponent(JSON.stringify(scope));
            	
                window.open(url)              
        }        
    }
})