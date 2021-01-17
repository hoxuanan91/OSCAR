({
    doInit : function(cmp, event, helper){
        helper.doInit(cmp);
    },
    
    openModal: function(cmp, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        cmp.set('v.isOpen', true);
    },
    
    closeModal: function(cmp, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        cmp.set('v.isOpen', false);
    },

    goNext: function(cmp, event, helper) {
        helper.goNext(cmp);
    },

    checkAlreadyExist : function(cmp, event, helper){
        helper.checkAlreadyExist(cmp);
    },

    fillSignerFields : function(cmp, event, helper){
        helper.fillSignerFields(cmp);
    },

    updateSigner : function(cmp, event, helper){
        helper.sendESignatureRequest(cmp, false);
    },

    createSigner : function(cmp, event, helper){
        helper.sendESignatureRequest(cmp, true);
    }
})