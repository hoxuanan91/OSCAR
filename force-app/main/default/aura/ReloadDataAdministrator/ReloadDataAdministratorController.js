({
	doInit : function(component, event, helper) {
		helper.loadJobFromServer(component);
	},
    executeJobBulk: function(component, event, helper) {
		helper.reexecuteJob(component);
	},
    search: function(component, event, helper) {
		helper.searchJob(component);
	}
})