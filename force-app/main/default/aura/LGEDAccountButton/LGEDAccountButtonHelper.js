({
    getAccountCustom : function(component){
     var action = component.get("c.getAccount");
     var self = this;
        action.setParams({accountId:component.get("v.recordId")}); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.currentAccount",response.getReturnValue());
                self.getCustomRefs(component);
            } else {
                console.log('Problem getting account, response state: '+ state);
            }
        });
        $A.enqueueAction(action);   
    },
    getCustomRefs : function(component){
     var rec2 = component.get("v.currentAccount");
     var action = component.get("c.getCustomRefs");
     console.log('recordtype '+rec2.RecordType.DeveloperName);
     action.setParams({recordType:rec2.RecordType.DeveloperName}); 
     action.setCallback(this, function(response){
     var state = response.getState();
     	if(component.isValid() && state == "SUCCESS"){
            var ref = response.getReturnValue();
        	component.set("v.customRefs",ref);
            //console.log('Ref values '+ref.RefMetierPrincipale__c+' '+ref.RefOscar__c+' '+ref.RefMetierSup__c);
            component.find("GEDbutton").set("v.disabled", false); 
        } else {
            console.log('Problem getting ged references, response state: '+ state);
        }
     });
     $A.enqueueAction(action);   
    },
    constructRef : function(component, base, ref){
        var myacc = component.get("v.currentAccount");
        var url = '';
        if(ref === "NTiers") {
            url = $A.get("$Label.c.URL_GED_NTIERS");
            if (typeof myacc.Code_Tiers__c !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",myacc.Code_Tiers__c));
            }else{
                return base.replace("XXX",url.replace("XXX",''));
            }/*
        }else if(ref === "CodeSoc_NDoss"){
            url = $A.get("$Label.c.URL_GED_SOCNDOSS");
            if (typeof myacc.NDuDossierCassiopae__c !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",myacc.NDuDossierCassiopae__c.replace("/","-")).replace("YYY",$A.get("$Label.c.CODE_SOCIETE_NL")));
            }else{
                return base.replace("XXX",url.replace("XXX",'').replace("YYY",''));
            }       
        }else if(ref === "NEngV4"){
            url = $A.get("$Label.c.URL_GED_NENGV4");
            //console.log('NV4 '+myacc.NEngagementV4__c);
            if (typeof myacc.NEngagementV4__c !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",myacc.NEngagementV4__c));
            }else{
                return base.replace("XXX",url.replace("XXX",''));
            }
        }else if(ref === "NDemandeOscar"){
            if (typeof myacc.CaseNumber !== 'undefined'){
            	return base.replace("XXX",myacc.CaseNumber); 
            }else{
                return base.replace("XXX",'%22%22'); 
            }*/
        }
     	return base.replace("XXX",'%22%22'); 
    }
})