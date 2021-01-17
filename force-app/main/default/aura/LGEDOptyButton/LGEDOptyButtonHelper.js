({
    getOptyCustom : function(component){
     var action = component.get("c.getOptyCustom");
     var self = this;
        action.setParams({opportunityId:component.get("v.recordId")}); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.currentopty",response.getReturnValue());
                self.getCustomRefs(component);
            } else {
                console.log('Problem getting opportunity, response state: '+ state);
            }
        });
        $A.enqueueAction(action);   
    },
    getCustomRefs : function(component){
     var rec2 = component.get("v.currentopty");
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
        var myopty = component.get("v.currentopty");
        var url = '';
        if(ref === "NTiers") {
            url = $A.get("$Label.c.URL_GED_NTIERS_RefSup");
            if (typeof myopty.CodeTiers__c !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",myopty.CodeTiers__c));
            }else{
                return base.replace("XXX",url.replace("XXX",''));
            }
        }else if(ref === "CodeSoc_NDoss" && myopty.NDuDossierCassiopae__c != ""){
            url = $A.get("$Label.c.URL_GED_SOCNDOSS");
            if (typeof myopty.NDuDossierCassiopae__c !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",myopty.NDuDossierCassiopae__c.replace("/","-")).replace("YYY",$A.get("$Label.c.CODE_SOCIETE_NL")));
            }else{
                return base.replace("XXX",url.replace("XXX",'').replace("YYY",''));
            }       
        }else if(ref === "NEngV4"){
            url = $A.get("$Label.c.URL_GED_NENGV4");
            //console.log('NV4 '+myopty.NEngagementV4__c);
            if (typeof myopty.NEngagementV4__c !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",myopty.NEngagementV4__c));
            }else{
                return base.replace("XXX",url.replace("XXX",''));
            }
        }else if(ref === "NDemandeOscar"){
            if (typeof myopty.CaseNumber !== 'undefined'){
            	return base.replace("XXX",myopty.CaseNumber); 
            }else{
                return base.replace("XXX",'%22%22'); 
            }
        }
     	return base.replace("XXX",'%22%22'); 
    }
})