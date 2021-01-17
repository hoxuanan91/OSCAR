@istest
public class LTNG02_TransfertDemandeControllerTEST {

    	static testMethod void testgetCaseCustom() {
        
        User u = TestFactory.createUser();
            System.runAs(u){
            
                Map<String,Id> RTs = DAL.getRecordType('Case');
                
                Account acc = TestFactory.createAccount('testAcc');
                insert acc;
            
                Contract ctr = TestFactory.createContract(acc.Id);
                ctr.BusinessUnit__c = '3';
                insert ctr;
                
                List<Case> Demandes = new List<Case>();
                
                Case c1 = TestFactory.createCase(ctr.Id, 'A prendre en charge');
                c1.N_du_Dossier__c= 'ABCD50';
                c1.NEngagementV4__c= 'ABCD50';
                c1.recordTypeId = (ID)RTs.get('CBM_Transfert_Pilote_DCR3');
                Insert c1;
                
                Test.startTest();
                
                LTNG02_TransfertDemandeController.updateCase(c1.Id, '3',null,'test');
                Case updatedCase = [select id, Datedenvoiengestion__c, ownerId from case where id= :c1.Id];
                system.assertNotEquals(updatedCase, null);
                system.assertEquals(updatedCase.Datedenvoiengestion__c, system.today());
                Test.stopTest();

        }
      }
}