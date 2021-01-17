({
    afterRender : function(cmp, helper)
    {
        this.superAfterRender();

        document.getElementById('rt-lineHeight').style.lineHeight = '2.6';
    }
})