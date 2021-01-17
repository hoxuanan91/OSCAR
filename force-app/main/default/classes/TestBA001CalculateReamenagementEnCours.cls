@isTest
public class TestBA001CalculateReamenagementEnCours {
    
    // Lancer le batch le 16 avril 2020
    static String CRON_EXPRESSION = '0 0 0 16 4 ? 2020';
    
    static testmethod void testDemandeQuiNeSeraPasMiseAjour(){
        
        User u = TestFactory.createUser();
        u.UserByPassWorkflows__c = true;
        System.runAs(u){
            
            // Préparation de données
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Contract ctr2 = TestFactory.createContract(acc.Id);
            insert ctr2;
           
            Case c = TestFactory.createCaseWithRT(ctr.Id, 'A prendre en charge',(ID)RTs.get('CBM_Actions_de_Recouvrement'));
            c.ReaC__c = false;
            insert c;
            
            Facture_non_lettree__c f1 = TestFactory.createFacture(c.Id);
            f1.Date_INSERT__c = date.newInstance(2015, 04, 1);
            f1.Date_UPDATE__c = date.newInstance(2015, 04, 5);
            f1.Date_MAJ_ksiop__c =  date.newInstance(2015, 04, 4);
            f1.Date_de_reglement__c =  null;
            f1.N_Dossier__c = ctr2.id;
            insert f1;
            
            System.debug('### Start test');
            Test.startTest();
                String jobId = System.schedule('TestBA001Scheduler',
                    CRON_EXPRESSION,
                    new BA001Scheduler());
                
                System.debug('### Scheduler Job Id : ' + jobId);
            Test.stopTest();
        }
    }
     
    static testmethod void testDemandeQuiSeraMiseAjour(){
        
        User u = TestFactory.createUser();
        System.runAs(u){
            
            // Préparation de données
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Contract ctr2 = TestFactory.createContract(acc.Id);
            insert ctr2;
           
            Case c = TestFactory.createCaseWithRT(ctr.Id, 'A prendre en charge',(ID)RTs.get('CBM_Actions_de_Recouvrement'));
            c.ReaC__c = false;
            insert c;
            
            Case c2 = TestFactory.createCaseWithRT(ctr2.Id, 'A prendre en charge',(ID)RTs.get('CBM_Reamenagement'));
            c.ReaC__c = false;
            insert c2;
            
            Facture_non_lettree__c f1 = TestFactory.createFacture(c.Id);
            f1.Date_INSERT__c = date.newInstance(2015, 04, 1);
            f1.Date_UPDATE__c = date.newInstance(2015, 04, 5);
            f1.Date_MAJ_ksiop__c =  date.newInstance(2015, 04, 4);
            f1.Date_de_reglement__c =  null;
            f1.N_Dossier__c = ctr2.id;
            insert f1;
            
            System.debug('### Start test');
            Test.startTest();
                String jobId = System.schedule('TestBA001Scheduler',
                    CRON_EXPRESSION,
                    new BA001Scheduler());
                
                System.debug('### Scheduler Job Id : ' + jobId);
            Test.stopTest();
        }
    }  
    
    static testmethod void testDemandeQuiSeraMiseAjourBulk(){
        
        User u = TestFactory.createUser();
        u.UserByPassWorkflows__c = true;
        u.UserByPassTriggers__c = 'TR001ManageCase_CalculFacture';
        System.runAs(u){
            
            // Préparation de données
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account acc = TestFactory.createAccount('testAcc');
            insert acc;
        
            Contract ctr = TestFactory.createContract(acc.Id);
            insert ctr;
            
            Contract ctr2 = TestFactory.createContract(acc.Id);
            insert ctr2;
           
            List<Case> c = TestFactory.createCaseWithRTBulk(50, ctr.Id, 'A prendre en charge',(ID)RTs.get('CBM_Actions_de_Recouvrement'), false);
            insert c;
            
            List<Case> c2 = TestFactory.createCaseWithRTBulk(50, ctr2.Id, 'A prendre en charge',(ID)RTs.get('CBM_Reamenagement'), false);
            insert c2;
            
            List<Facture_non_lettree__c> f1 = TestFactory.createFactureBulk(c, ctr2.id);
            insert f1;
            
            System.debug('### Start test');
            Test.startTest();
                String jobId = System.schedule('TestBA001Scheduler',
                    CRON_EXPRESSION,
                    new BA001Scheduler());
                
                System.debug('### Scheduler Job Id : ' + jobId);
            Test.stopTest();
        }
    } 
}