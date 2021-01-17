@isTest
public class Ctrl11_FormulaireClientGarant_TEST {
    private static testMethod void controllerTest() {
        Account a = TestFactory.createAccount('Test');
        a.Report_de_loyers__c = '5';
        insert a;

        PageReference myVFpage = Page.VFP11_FormulaireClientGarant;
        Test.setCurrentPage(myVFpage);

        Apexpages.currentPage().getParameters().put('id', a.Id);
        Apexpages.currentPage().getParameters().put('type', 'Client');

        Apexpages.StandardController sc = new Apexpages.StandardController(a);
        Ctrl11_FormulaireClientGarant myCtrl = new Ctrl11_FormulaireClientGarant(sc);

        myCtrl.soussigne = 'Test';
        myCtrl.qualiteDe = 'Test';

        myCtrl.sendForm();

        Test.startTest();

        List<Information_Report__c> infos = new List<Information_Report__c>();

        infos = [SELECT Id FROM Information_Report__c WHERE TiersRepresente__c = :a.id];

        System.assertEquals(1, infos.size());

        Test.stopTest();

    }
}