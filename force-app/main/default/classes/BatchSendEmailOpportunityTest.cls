@isTest
public class BatchSendEmailOpportunityTest {
    
    static testMethod void TestBatch() {
        Account acc = new Account(Name = 'test');
        insert acc;
        Contract ct = new Contract(Name = 'test', accountId = acc.id);
        insert ct;
        Opportunity obj = new Opportunity(OwnerId = '0050J0000098EgiQAE',dossier__c = ct.Id, accountId = acc.id, Name='test', StageName = 'Octroi', CloseDate = System.today());
        insert obj;
        obj.OwnerId = '0050J0000098EgiQAE';
        update obj;
        Test.startTest();
        
        Database.executeBatch(new BatchSendEmailOpportunity(), 1);
        Database.executeBatch(new BatchSendEmailOpportunityATLIV(), 1);
        Database.executeBatch(new BatchSendEmailOpportunityDERO(), 1);
        
        Test.stopTest();
    }
    @isTest(seeAllData=true)
    static void TestRepriseBatch() {
        BatchOpportunityRepriseEmailEnvoye bt = new BatchOpportunityRepriseEmailEnvoye();
        Test.startTest();
        bt.setEmailStatus(new Opportunity(), 'MEL');
        Database.executeBatch(bt);
        Test.stopTest();
    }
    @isTest
    static void TestKOBatch() {
        Account acc = new Account(Name = 'test');
        insert acc;
        Contract ct = new Contract(Name = 'test', accountId = acc.id);
        insert ct;
        Opportunity obj = new Opportunity(OwnerId = '0050J0000098EgiQAE',dossier__c = ct.Id, accountId = acc.id, Name='test', StageName = 'Octroi', CloseDate = System.today());
        insert obj;
        insert new ControleMetier__c(Forcage__c = false, Archive__c = false, TypeDocument__c = '2', recordtypeId = '0120J000000VFjxQAG',
                                     ProjetAssocie__c = obj.Id, Statut__c = '3' , Bloquant__c = '1',IntituleControle__c = 'xxx', IntituleControleEmail__c = 'Date de signature non renseignée');
        insert new ControleMetier__c(Forcage__c = false, Archive__c = false, TypeDocument__c = '3', recordtypeId = '0120J000000VFjxQAG',
                                     ProjetAssocie__c = obj.Id, Statut__c = '3' , Bloquant__c = '1',IntituleControle__c = 'xxx', IntituleControleEmail__c = 'Date de signature non renseignée');
        insert new ControleMetier__c(Forcage__c = false, Archive__c = false, TypeDocument__c = '4', recordtypeId = '0120J000000VFjxQAG',
                                     ProjetAssocie__c = obj.Id, Statut__c = '3' , Bloquant__c = '1',IntituleControle__c = 'xxx', IntituleControleEmail__c = 'Date de signature non renseignée');
        insert new ControleMetier__c(Forcage__c = false, Archive__c = false, TypeDocument__c = '5', recordtypeId = '0120J000000VFjxQAG',
                                     ProjetAssocie__c = obj.Id, Statut__c = '3' , Bloquant__c = '1',IntituleControle__c = 'xxx', IntituleControleEmail__c = 'Date de signature non renseignée');
        insert new ControleMetier__c(Forcage__c = false, Archive__c = false, TypeDocument__c = '6', recordtypeId = '0120J000000VFjxQAG',
                                     ProjetAssocie__c = obj.Id, Statut__c = '3' , Bloquant__c = '1',IntituleControle__c = 'xxx', IntituleControleEmail__c = 'Date de signature non renseignée');
        insert new ControleMetier__c(Forcage__c = false, Archive__c = false, TypeDocument__c = '8', recordtypeId = '0120J000000VFjxQAG',
                                     ProjetAssocie__c = obj.Id, Statut__c = '3' , Bloquant__c = '1',IntituleControle__c = 'xxx', IntituleControleEmail__c = 'Date de signature non renseignée');
        insert new ControleMetier__c(Forcage__c = false, Archive__c = false, TypeDocument__c = '9', recordtypeId = '0120J000000VFjxQAG',
                                     ProjetAssocie__c = obj.Id, Statut__c = '3' , Bloquant__c = '1',IntituleControle__c = 'xxx', IntituleControleEmail__c = 'Date de signature non renseignée');
        insert new ControleMetier__c(Forcage__c = false, Archive__c = false, TypeDocument__c = '10', recordtypeId = '0120J000000VFjxQAG',
                                     ProjetAssocie__c = obj.Id, Statut__c = '3' , Bloquant__c = '1',IntituleControle__c = 'xxx', IntituleControleEmail__c = 'Date de signature non renseignée');
        insert new ControleMetier__c(Forcage__c = false, Archive__c = false, TypeDocument__c = '11', recordtypeId = '0120J000000VFjxQAG',
                                     ProjetAssocie__c = obj.Id, Statut__c = '3' , Bloquant__c = '1',IntituleControle__c = 'xxx', IntituleControleEmail__c = 'Date de signature non renseignée');
        
        Test.startTest();
        
        Database.executeBatch(new BatchSendEmailOpportunityKO('KO1'),1);
        Database.executeBatch(new BatchSendEmailOpportunityKO('KO2'),1);
        EmailKOBodyController clr = new EmailKOBodyController();
        clr.oppId = obj.Id;
        clr.emailMode = 'KO1';
        Test.stopTest();
    }
    
    @isTest
    static void TestShedeleBatch() {
        
        String sch = '0 30  * 1/1 * ? *';
        
        System.schedule('mel', sch, new SchedeleSendEmailOpportunityMEL());
        System.schedule('dero', sch, new SchedeleSendEmailOpportunityDero());
        System.schedule('ko', sch, new SchedeleSendEmailOpportunityKO());
        System.schedule('atliv', sch, new SchedeleSendEmailOpportunityATLIV());

    }
}