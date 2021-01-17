({
	doInit : function(component, event, helper) {
		helper.getCaseCustom(component);
    },openActionWindow2 : function(component, event, helper) {
        var mycase = component.get("v.currentcase");
        var url = mycase.URLGED__c;
        window.open(url);  
    }
})