({
	sendEmail : function(cmp, event, helper) {
        helper.loadEmail(cmp, event, helper);
        try{            
            document.getElementsByName("sfdcSoftphone")[0].contentWindow.postMessage({type:'clickToEmail',email:cmp.get('v.Email'), recordId:cmp.get('v.recordId')},"*");
        }catch(e){
            console.log("error sending event ",e)
        }
       	console.log("afterClick");
	},
    doInit : function(cmp, event, helper) {
		helper.loadEmail(cmp, event, helper);
    }
})