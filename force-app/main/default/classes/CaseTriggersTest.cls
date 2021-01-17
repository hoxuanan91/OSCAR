@isTest
public class CaseTriggersTest {
        
    public static testMethod void CaseUpdateTriggers(){
        
        //________________________________Data prep_________________________________
        Account acc = TestFactory.createAccount('Test Acc');
        insert acc;
        Opportunity opp = TestFactory.createOppWithRecordType('Test Opp', UTL_Utils.getRecordTypeID(String.valueOf(Opportunity.getSObjectType()), 'CBMEnDelegation'), 'Étude', acc.Id);
        insert opp;
        Contract ctr =TestFactory.createContract(acc.id);
        insert ctr;
        Case c = TestFactory.createCaseWithAccount(acc.Id, 'Décidée');
        c.ProjetAssocie__c = opp.Id;
        c.RecordTypeId = UTL_Utils.getRecordTypeID(String.valueOf(Case.getSObjectType()), 'CBM_Reamenagement');
        insert c;
        //______________________________________________________________________________
        
        Test.startTest();
        //Case 1
        c.Status = 'Terminée';
        c.Dossier1__c = ctr.Id;
        update c;
        Map<Id, Case> casesByIds = new Map<Id, Case>();
        casesByIds.put(c.Id, c);
        AP18Demande.postChatterWhenCaseEqualTermine(casesByIds);
        //Case 2
        c.Status = 'Annulée';
        c.Dossier1__c = ctr.Id;
        update c;
        
        
        Test.stopTest();
        
    }
    
    public static testMethod void CaseInsertTriggers(){
        
       	//________________________________Data prep_________________________________
        Account acc = TestFactory.createAccount('Test Acc');
        insert acc;
        Opportunity opp = TestFactory.createOppWithRecordType('Test Opp', UTL_Utils.getRecordTypeID(String.valueOf(Opportunity.getSObjectType()), 'CBMEnDelegation'), 'Étude', acc.Id);
        insert opp;
        Contract ctr =TestFactory.createContract(acc.id);
        insert ctr;
        Case c = TestFactory.createCaseWithAccount(acc.Id, 'Décidée');
        c.ProjetAssocie__c = opp.Id;
        c.RecordTypeId = UTL_Utils.getRecordTypeID(String.valueOf(Case.getSObjectType()), 'CBM_Reamenagement');
        c.Dossier1__c = ctr.Id;
        Case c1 = TestFactory.createCaseWithAccount(acc.Id, 'Décidée');        
        c1.ProjetAssocie__c = opp.Id;
        c1.RecordTypeId = UTL_Utils.getRecordTypeID(String.valueOf(Case.getSObjectType()), 'CBM_Actions_de_Recouvrement');
        c1.Dossier1__c = ctr.Id;
        //______________________________________________________________________________
        
        Test.startTest();
        insert c1;
        insert c;
        Test.stopTest();
        
    }
    
    public static testMethod void CaseDeleteTriggers(){
        
       	//________________________________Data prep_________________________________
        Account acc = TestFactory.createAccount('Test Acc');
        insert acc;
        Opportunity opp = TestFactory.createOppWithRecordType('Test Opp', UTL_Utils.getRecordTypeID(String.valueOf(Opportunity.getSObjectType()), 'CBMEnDelegation'), 'Étude', acc.Id);
        insert opp;
        Contract ctr =TestFactory.createContract(acc.id);
        insert ctr;
        Case c = TestFactory.createCaseWithAccount(acc.Id, 'Terminée');
        c.ProjetAssocie__c = opp.Id;
        c.RecordTypeId = UTL_Utils.getRecordTypeID(String.valueOf(Case.getSObjectType()), 'CBM_Reamenagement');
        c.Dossier1__c = ctr.Id;
        insert c;
        c.Status= 'Terminée';
        Update c;
        system.debug(' Case status before delete:'+c.Status);
        //______________________________________________________________________________
        
        Test.startTest();
        Delete c;
        Undelete c;
        Test.stopTest();
        
    }
    
}