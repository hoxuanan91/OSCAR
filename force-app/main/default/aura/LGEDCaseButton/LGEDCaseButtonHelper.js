({
    getCaseCustom : function(component){
     var action = component.get("c.getCaseCustom");
     var self = this;
        action.setParams({caseId:component.get("v.recordId")}); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.currentcase",response.getReturnValue());
                self.getCustomRefs(component);
            } else {
                console.log('Problem getting case, response state: '+ state);
            }
        });
        $A.enqueueAction(action);   
    },
    getCustomRefs : function(component){
     var rec2 = component.get("v.currentcase");
     var action = component.get("c.getCustomRefs");
     //console.log('recordtype '+rec2.RecordType.DeveloperName);
     action.setParams({recordType:rec2.RecordType.DeveloperName}); 
     action.setCallback(this, function(response){
     var state = response.getState();
     	if(component.isValid() && state == "SUCCESS"){
            var ref = response.getReturnValue();
        	component.set("v.customRefs",ref);
            component.find("GEDbutton").set("v.disabled", false); 
            //console.log('Ref values '+ref.RefMetierPrincipale__c+' '+ref.RefOscar__c+' '+ref.RefMetierSup__c);
            
        } else {
            console.log('Problem getting ged references, response state: '+ state);
        }
     });
     $A.enqueueAction(action);   
    },
    constructRef : function(component, base, ref){
        var mycase = component.get("v.currentcase");
        var url = '';
        if(ref === "NTiers" && mycase.RecordTypeId == "01220000000Av3tAAC") {
            url = $A.get("$Label.c.URL_GED_NTIERS");
            if (typeof mycase.CodeTiers__c !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",mycase.CodeTiers__c));
            }else{
                return base.replace("XXX",url.replace("XXX",''));
            }
        }else if(ref === "NTiers" && mycase.RecordTypeId != "01220000000Av3tAAC") {
            url = $A.get("$Label.c.URL_GED_NTIERS_RefSup");
            if (typeof mycase.CodeTiers__c !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",mycase.CodeTiers__c));
            }else{
                return base.replace("XXX",url.replace("XXX",''));
            }
        }else if(ref === "CodeSoc_NDoss"){
            url = $A.get("$Label.c.URL_GED_SOCNDOSS");
            if (typeof mycase.N_du_Dossier__c !== 'undefined' && typeof mycase.CodeSocieteGestion__c !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",mycase.N_du_Dossier__c.replace("/","-")).replace("YYY",mycase.CodeSocieteGestion__c));
            }else{
                return base.replace("XXX",url.replace("XXX",'').replace("YYY",''));
            }       
        }else if(ref === "NEngV4"){
            url = $A.get("$Label.c.URL_GED_NENGV4");
            console.log('NV4 '+mycase.NEngagementV4__c);
            if (typeof mycase.NEngagementV4__c !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",mycase.NEngagementV4__c));
            }else{
                return base.replace("XXX",url.replace("XXX",''));
            }
        }else if(ref === "NDemandeOscar"){
            if (typeof mycase.CaseNumber !== 'undefined'){
            	return base.replace("XXX",mycase.CaseNumber); 
            }else{
                return base.replace("XXX",'%22%22'); 
            }
        }
     	return base.replace("XXX",'%22%22'); 
    }
})