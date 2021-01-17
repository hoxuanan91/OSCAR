@isTest
public class Ctrl12_FormulaireCovidCBI_TEST {
    private static testMethod void Ctrl12_FormulaireCovidCBI_TEST() {

        User currentUser = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];

        System.runAs(currentUser){
            Account a = TestFactory.createAccount('Test');
            insert a;

            Contract c = TestFactory.createContract(a.Id, 'Non');
            insert c;

            EmailTemplate eT = TestFactory.createEmailTemplate('test');
            insert eT;

            PageReference myVFpage = Page.VFP12_FormulaireCovidCBI;
            Test.setCurrentPage(myVFpage);

            Apexpages.currentPage().getParameters().put('id', a.Id);
            Apexpages.currentPage().getParameters().put('type', 'Non');
            Apexpages.currentPage().getParameters().put('duree', 'COURT');
            Apexpages.currentPage().getParameters().put('templateId', eT.Id);

            Apexpages.StandardController sc = new Apexpages.StandardController(a);
            Ctrl12_FormulaireCovidCBI myCtrl = new Ctrl12_FormulaireCovidCBI(sc);

            myCtrl.soussigne = 'Test';
            myCtrl.qualiteDe = 'Test';

            Apexpages.currentPage().getParameters().put('contractName', 'arChoice' + c.Name);
            Apexpages.currentPage().getParameters().put('choice', 'Accord');

            myCtrl.onChangeAPEX();

            Apexpages.currentPage().getParameters().put('contractName', 'optionChoice' + c.Name);
            Apexpages.currentPage().getParameters().put('choice', 'Paiement au dernier loyer');

            myCtrl.onChangeAPEX();

            myCtrl.sendForm();

            Test.startTest();

            Contract ctr = [SELECT Id, Date_de_reponse_tiers__c FROM Contract WHERE Id =: c.id];

            System.assertEquals(ctr.Date_de_reponse_tiers__c, System.today());

            Test.stopTest();
        }
    }
}