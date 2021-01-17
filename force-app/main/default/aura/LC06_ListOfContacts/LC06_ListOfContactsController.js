({
    doInit : function(cmp, event, helper){
        helper.doInit(cmp);
    },

    displayFullList : function(cmp, event, helper){
        cmp.set('v.displayFullList', cmp.get('v.displayFullList') ? false : true);
    }
})