@isTest
public class BatchEnvoiEmailAccordClientTest {  
    
    private static testMethod void BatchEnvoiEmailAccordClientTest() {
        
        User currentUser = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];

        System.runAs(currentUser){

            Account a = TestFactory.createAccount('Test');
            insert a;

            Account b = TestFactory.createAccount('Test');
            insert b;

            Contact c = TestFactory.createContact('Test', 'Test', 'test@test.com');
            c.AccountId = a.Id;
            c.RecordTypeId = UTL_Utils.getRecordTypeID(String.valueOf(Contact.getSObjectType()), 'Contact_oscar');
            insert c;

            Contract con = TestFactory.createContract(a.Id, 'Chef de file');
            con.Covid_cbi_ref_envoi1__c = con.Name;
            insert con;

            Contract con2 = TestFactory.createContract(b.Id, 'Non');
            con2.Name = '000002/00';
            con2.Covid_cbi_ref_envoi1__c = con2.Name;
            insert con2;

            Test.startTest();
        
            Database.executeBatch(new BatchEnvoiEmailAccordClient('PROJET_DE_LETTRE_N2_TM_CDF_duree_courte_envoi_telematique','SeulCourt1','Toto'));
            Database.executeBatch(new BatchEnvoiEmailAccordClient('PROJET_DE_LETTRE_N2_TM_seul_duree_courte_envoi_telematique','SeulCourt1','tota'));
            
            Test.stopTest();
        }
    }

}