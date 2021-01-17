({
	doInit : function(component, event, helper) {
		helper.getOptyCustom(component);
    },openActionWindow : function(component, event, helper) {
        var myopty = component.get("v.currentopty");
        var url = myopty.URLGED__c;
        /*
        var refs = component.get("v.customRefs");        
		if(refs.RefMetierPrincipale__c === "CodeSoc_NDoss") {
            if (myopty.NDuDossierCassiopae__c){
            	url = url.concat(helper.constructRef(component,$A.get("$Label.c.URL_GED_REFPRINC"),refs.RefMetierPrincipale__c));
            }else{
                url = url.concat(helper.constructRef(component,$A.get("$Label.c.URL_GED_REFPRINC"),refs.RefMetierSup__c));
            }}     
        if (typeof refs.RefOscar__c !== 'undefined'){url = url.concat(helper.constructRef(component,$A.get("$Label.c.URL_GED_REFOSCAR"),refs.RefOscar__c));}
        if (typeof refs.RefMetierSup__c !== 'undefined'){url = url.concat(helper.constructRef(component,$A.get("$Label.c.URL_GED_REFSUP"),refs.RefMetierSup__c));}
        
        
        url= myopty.URL_GED__c;
        */
        window.open(url);  
    }
})