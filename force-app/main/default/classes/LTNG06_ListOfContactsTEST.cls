@isTest
public class LTNG06_ListOfContactsTEST {

    private static testMethod void LTNG06_ListOfContactsTEST() {
        Account a = TestFactory.createAccount('Test');
        insert a;
        
        Case c = TestFactory.createCaseWithAccount(a.Id, 'Prise en charge');
        insert c;
        
        Contact cont = TestFactory.createContact('Test', 'Test', 'test@test.com');
        cont.Correspondant_recouvrement__c = true;
        cont.AccountId = a.Id;
        insert cont;
        
        Test.startTest();
        LTNG06_ListOfContacts.DataWrapper dW = LTNG06_ListOfContacts.doInit_APEX(c.Id);
        System.assertEquals(dW.contsWPlimited.size(), 1);
		
		List<Contact> contactsToInsert = new List<Contact>();        
        Contact cont2 = TestFactory.createContact('Test', 'Test', 'test@test.com');
        cont2.Correspondant_recouvrement__c = true;
        cont2.AccountId = a.Id;
        contactsToInsert.add(cont2);
        
        Contact cont3 = TestFactory.createContact('Test', 'Test', 'test@test.com');
        cont3.Correspondant_recouvrement__c = true;
        cont3.AccountId = a.Id;
        contactsToInsert.add(cont3);
        
        Contact cont4 = TestFactory.createContact('Test', 'Test', 'test@test.com');
        cont4.Correspondant_recouvrement__c = true;
        cont4.AccountId = a.Id;
        contactsToInsert.add(cont4);
        
        insert contactsToInsert;
        
		LTNG06_ListOfContacts.DataWrapper dW2 = LTNG06_ListOfContacts.doInit_APEX(c.Id);
        System.assertEquals(dW2.contsWPlimited.size(), 3);
        System.assertEquals(dW2.contsWPunlimited.size(), 4);
        
        Test.stopTest();
           
    }
}