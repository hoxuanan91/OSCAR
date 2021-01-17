@isTest
public class HDL03_ContratProjetAssocieHandler_TEST {

    private static testMethod void updateContract(){

        Account a = TestFactory.createAccount('Test');
        insert a;

        Opportunity opp = TestFactory.createOppWithRecordType('Test', UTL_Utils.getRecordTypeID(String.valueOf(Opportunity.getSObjectType()), 'LLD_Commande'), 'Cotation', a.Id);
        opp.Typologie_de_commande__c = 'Renouvellement';
        insert opp;

        Contract con = TestFactory.createContractWithRecordType(a.Id, opp.Id, UTL_Utils.getRecordTypeID(String.valueOf(Contract.getSObjectType()), 'LLD_Contrat'));
        insert con;

        Contract con2 = TestFactory.createContractWithRecordType(a.Id, opp.Id, UTL_Utils.getRecordTypeID(String.valueOf(Contract.getSObjectType()), 'LLD_Contrat'));
        insert con2;

        Contrat_ProjetAssocie__c cPas = TestFactory.createContratPAS(opp.Id, con.Id);
        insert cPas;

        Test.startTest();

        System.assertEquals('En cours de renouvellement', [SELECT Id, Statut_renouvellement__c FROM Contract WHERE Id = :con.Id].Statut_renouvellement__c);
        
        cPas.Contrat__c = con2.Id;

        update cPas;

        System.assertEquals(null, [SELECT Id, Statut_renouvellement__c FROM Contract WHERE Id = :con.Id].Statut_renouvellement__c);
        System.assertEquals('En cours de renouvellement', [SELECT Id, Statut_renouvellement__c FROM Contract WHERE Id = :con2.Id].Statut_renouvellement__c);

        delete cPas;

        System.assertEquals(null, [SELECT Id, Statut_renouvellement__c FROM Contract WHERE Id = :con2.Id].Statut_renouvellement__c);

        Test.stopTest();

    }
    
}