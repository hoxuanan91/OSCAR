({
    getContractCustom : function(component){
     var action = component.get("c.getContract");
     var self = this;
        action.setParams({contractId:component.get("v.recordId")}); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                component.set("v.currentContract",response.getReturnValue());
                self.getCustomRefs(component);
            } else {
                console.log('Problem getting contract, response state: '+ state);
            }
        });
        $A.enqueueAction(action);   
    },
    getCustomRefs : function(component){
     var rec2 = component.get("v.currentContract");
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
        var mycontract = component.get("v.currentContract");
        var url = '';
        if(ref === "NTiers") {
            url = $A.get("$Label.c.URL_GED_NTIERS_RefSup");
            if (typeof mycontract.Account.Code_Tiers__c !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",mycontract.Account.Code_Tiers__c));
            }else{
                return base.replace("XXX",url.replace("XXX",''));
            }
        }else if(ref === "CodeSoc_NDoss"){
            url = $A.get("$Label.c.URL_GED_SOCNDOSS");
            if (typeof mycontract.Name !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",mycontract.Name.replace("/","-")).replace("YYY",$A.get("$Label.c.CODE_SOCIETE_NL")));
            }else{
                return base.replace("XXX",url.replace("XXX",'').replace("YYY",''));
            }       
        }else if(ref === "NEngV4"){
            url = $A.get("$Label.c.URL_GED_NENGV4");
            //console.log('NV4 '+mycontract.NEngagementV4__c);
            if (typeof mycontract.Id !== 'undefined'){
            	return base.replace("XXX",url.replace("XXX",mycontract.Id));
            }else{
                return base.replace("XXX",url.replace("XXX",''));
            }
        }
     	return base.replace("XXX",'%22%22'); 
    }
})