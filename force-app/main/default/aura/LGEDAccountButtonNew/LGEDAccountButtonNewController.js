({
	doInit : function(component, event, helper) {
		helper.getAccount(component);
    },openActionWindow : function(component, event, helper) {
        var myaccount = component.get("v.currentAccount");
       
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
            	
                window.open(url);
          
    }
})