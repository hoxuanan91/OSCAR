({
	doInit : function(component, event, helper) {
		helper.getAccountCustom(component);
    },openActionWindow : function(component, event, helper) {
        var url = $A.get("$Label.c.URL_GED_BASE");
        var refs = component.get("v.customRefs");
        if (typeof refs.RefMetierPrincipale__c !== 'undefined'){url = url.concat(helper.constructRef(component,$A.get("$Label.c.URL_GED_REFPRINC"),refs.RefMetierPrincipale__c));}
        if (typeof refs.RefOscar__c !== 'undefined'){url = url.concat(helper.constructRef(component,$A.get("$Label.c.URL_GED_REFOSCAR"),refs.RefOscar__c));}
        if (typeof refs.RefMetierSup__c !== 'undefined'){url = url.concat(helper.constructRef(component,$A.get("$Label.c.URL_GED_REFSUP"),refs.RefMetierSup__c));}
        url= url.concat('%7D');
        window.open(url);  
    }
})