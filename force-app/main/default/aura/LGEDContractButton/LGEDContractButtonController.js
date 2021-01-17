({
	doInit : function(component, event, helper) {
		helper.getContractCustom(component);
    },openActionWindow : function(component, event, helper) {
        var mycontract = component.get("v.currentContract");
        var url = mycontract.URLGED__c;
        window.open(url);  
    }
})