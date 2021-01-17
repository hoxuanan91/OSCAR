@istest public class TestQuickCaseController{

    static testMethod void testgetCaseCustom() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            List<Case> Demandes = new List<Case>();
            
            Case c1 = TestFactory.createCase(ctr.Id, 'A prendre en charge');
            c1.N_du_Dossier__c= 'ABCD50';
            c1.NEngagementV4__c= 'ABCD50';
            c1.recordTypeId = (ID)RTs.get('CBM_Appel_de_fonds_recouvrer');
            Insert c1;
            
            Test.startTest();
            
            
            Case c2 = QuickCaseController.getCaseCustom(C1.Id);
            
            Test.stopTest();

        }
    }
    
    static testMethod void getOptyCustom() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;

            Projet__c Projet = TestFactory.createProjet('TEST');
            Projet.NomDuTiers__c = acc.Id;
            insert Projet;
            
            List<Opportunity> Opportunities = new List<Opportunity>();
            
            Opportunity o1 = TestFactory.createOpty('TEST');
            o1.NEngagementV4__c= 'ABCD50';
            o1.StageName= 'ABCD50';    
            o1.CloseDate= Date.newInstance(1960, 2, 17); 
            o1.NomDuProjet__c=Projet.Id ;
            Insert o1;
            
            Test.startTest();
            
            
            Opportunity o2 = QuickCaseController.getOptyCustom(o1.Id);
            
            Test.stopTest();

        }
    }
    
    static testMethod void getProjet() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            List<Projet__c> Projets = new List<Projet__c>();
            
            Projet__c p1 = TestFactory.createProjet('TEST');
            p1.NumIdentificationProjet__c= 'ABCD50';
            p1.NomDuTiers__c= acc.Id;
            Insert p1;
            
            Test.startTest();
            
            
            Projet__c p2 = QuickCaseController.getProjet(p1.Id);
            
            Test.stopTest();

        }
    }
    
    static testMethod void getContract() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            List<Contract> Contracts = new List<Contract>();
            
            Contract c1 = TestFactory.createContract(acc.Id);
            Insert c1;
            
            Test.startTest();
            

            Contract c2 = QuickCaseController.getContract(c1.Id);
            
            Test.stopTest();

        }
    }    

    static testMethod void getAccount() {
        
        User u = TestFactory.createUser();
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            List<Contract> Contracts = new List<Contract>();
            
            Account a1 = TestFactory.createAccount('TEST');
            Insert a1;
            
            Test.startTest();
            

            Account a2 = QuickCaseController.getAccount(a1.Id);
            
            Test.stopTest();

        }
    }     
    
}