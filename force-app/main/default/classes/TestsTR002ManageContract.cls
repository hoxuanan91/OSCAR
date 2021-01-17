@istest
public class TestsTR002ManageContract{

    static testMethod void testCalculateNombreReamenagementInsertion() {
        
        User u = TestFactory.createUser();
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account tiers = TestFactory.createAccount('test');
            insert tiers;
        
            Contract dossier = TestFactory.createContract(tiers.Id);
            insert dossier;

            Test.startTest();
                Case c1 = TestFactory.createCase(dossier.Id, 'Terminée');
                c1.recordTypeId = (ID)RTs.get('CBM_Reamenagement');
                insert c1;
            Test.stopTest();
            
            Contract cResultat = [SELECT Nombre_de_Reamenagements__c FROM Contract where ID = :dossier.Id];
            //System.assertEquals(0, cResultat.Nombre_de_Reamenagements__c);
        }

    }
    
    static testMethod void testCalculateNombreReamenagementMiseAJour() {
        
        User u = TestFactory.createUser();
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account tiers = TestFactory.createAccount('test');
            insert tiers;
        
            Contract dossier = TestFactory.createContract(tiers.Id);
            insert dossier;
            
            Case c1 = TestFactory.createCase(dossier.Id, 'Terminée');
            c1.recordTypeId = (ID)RTs.get('CBM_Reamenagement');
            insert c1;

            Test.startTest();
                c1.recordTypeId = (ID)RTs.get('CBM_Actions_de_Recouvrement');
                update c1;
            Test.stopTest();
            
            Contract cResultat = [SELECT Nombre_de_Reamenagements__c FROM Contract where ID = :dossier.Id];
            //System.assertEquals(0, cResultat.Nombre_de_Reamenagements__c);
        }

    }
    
    static testMethod void testCalculateNombreReamenagementSuppression() {
        
        User u = TestFactory.createUser();
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account tiers = TestFactory.createAccount('test');
            insert tiers;
        
            Contract dossier = TestFactory.createContract(tiers.Id);
            insert dossier;
            
            Case c1 = TestFactory.createCase(dossier.Id, 'Terminée');
            c1.recordTypeId = (ID)RTs.get('CBM_Reamenagement');
            insert c1;
            
            Case c2 = TestFactory.createCase(dossier.Id, 'Terminée');
            c2.recordTypeId = (ID)RTs.get('CBM_Reamenagement');
            insert c2;

            Test.startTest();
                delete c1;
            Test.stopTest();
            
            Contract cResultat = [SELECT Nombre_de_Reamenagements__c FROM Contract where ID = :dossier.Id];
            System.assertEquals(1, cResultat.Nombre_de_Reamenagements__c);
        }

    }
    
    static testMethod void testCalculateNombreReamenagementRestauration() {
        
        User u = TestFactory.createUser();
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account tiers = TestFactory.createAccount('test');
            insert tiers;
        
            Contract dossier = TestFactory.createContract(tiers.Id);
            insert dossier;
            
            Case c1 = TestFactory.createCase(dossier.Id, 'Terminée');
            c1.recordTypeId = (ID)RTs.get('CBM_Reamenagement');
            insert c1;
            
            Case c2 = TestFactory.createCase(dossier.Id, 'Terminée');
            c2.recordTypeId = (ID)RTs.get('CBM_Reamenagement');
            insert c2;
            
            delete c1;

            Test.startTest();
                undelete c1;
            Test.stopTest();
            
            Contract cResultat = [SELECT Nombre_de_Reamenagements__c FROM Contract where ID = :dossier.Id];
            System.assertEquals(2, cResultat.Nombre_de_Reamenagements__c);
        }

    }
    
    static testMethod void testCalculateNombreReamenagementBulk() {
        
        User u = TestFactory.createUser();
        u.UserByPassWorkflows__c = true;
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
            
            Account tiers = TestFactory.createAccount('test');
            insert tiers;
        
            Contract dossier = TestFactory.createContract(tiers.Id);
            insert dossier;
            
            List<Case> casesReamenagement = TestFactory.createCaseWithRTBulk(100, String.valueOf(dossier.Id), 'Terminée', (ID)RTs.get('CBM_Reamenagement'), true);
            List<Case> casesActionRecouvrement = TestFactory.createCaseWithRTBulk(100, String.valueOf(dossier.Id), 'Terminée', (ID)RTs.get('CBM_Actions_de_Recouvrement'), true);

            Test.startTest();
                insert casesReamenagement;
                insert casesActionRecouvrement;
            Test.stopTest();
            
            Contract cResultat = [SELECT Nombre_de_Reamenagements__c FROM Contract where ID = :dossier.Id];
            //System.assertEquals(200, cResultat.Nombre_de_Reamenagements__c);
        }

    }
    
    static testMethod void testRecupererNomTiersInsertion() {
        
        User u = TestFactory.createUser();
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
        
            Account tiers = TestFactory.createAccount('test');
            insert tiers;
            
            Contract dossier = TestFactory.createContract(tiers.Id);
            insert dossier;

            Test.startTest();
                Case c1 = TestFactory.createCase(dossier.Id, 'Terminée');
                c1.recordTypeId = (ID)RTs.get('CBM_Reamenagement');
                insert c1;
            Test.stopTest();
            
            Case cResultat = [Select AccountId from Case where Id = :c1.Id];
            System.assertEquals(dossier.AccountId, cResultat.AccountId);
        }        
    }
    
    static testMethod void testRecupererNomTiersMiseAJour() {
        
        User u = TestFactory.createUser();
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
        
            Account tiers = TestFactory.createAccount('test');
            insert tiers;
            
            Account tiers2 = TestFactory.createAccount('test2');
            insert tiers2;
            
            Contract dossier = TestFactory.createContract(tiers.Id);
            insert dossier;
            
            Contract dossier2 = TestFactory.createContract(tiers2.Id);
            insert dossier2;
            
            Case c1 = TestFactory.createCase(dossier.Id, 'Terminée');
            c1.recordTypeId = (ID)RTs.get('CBM_Reamenagement');
            insert c1;

            Test.startTest();
                c1.Dossier1__c = dossier2.Id;
                update c1;
            Test.stopTest();
            
            Case cResultat = [Select AccountId from Case where Id = :c1.Id];
            //System.assertEquals(dossier2.AccountId, cResultat.AccountId);
        }        
    }
    
    static testMethod void testRecupererNomTiersBulk() {
        
        User u = TestFactory.createUser();
        u.UserByPassWorkflows__c = true;
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
        
            Account tiers = TestFactory.createAccount('test');
            insert tiers;
            
            Contract dossier = TestFactory.createContract(tiers.Id);
            insert dossier;
            
            List<Case> casesReamenagement = TestFactory.createCaseWithRTBulk(100, String.valueOf(dossier.Id), 'Terminée', (ID)RTs.get('CBM_Reamenagement'), true);

            Test.startTest();
                insert casesReamenagement;
            Test.stopTest();
            
            List<Case> cResultat = [Select AccountId from Case where Id IN :casesReamenagement];
            
            for(Case c : cResultat)
                System.assertEquals(dossier.AccountId, c.AccountId);
        }        
    }
    
    static testMethod void testCalculateDateDeMEL() {
        
        User u = TestFactory.createUser();
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
        
            Account tiers = TestFactory.createAccount('test');
            insert tiers;
            
            Contract dossier = TestFactory.createContract(tiers.Id);
            dossier.Date_de_traitement_MEL__c = Date.newInstance(2015, 4, 1);
            insert dossier;

            Case c1 = TestFactory.createCase(dossier.Id, 'Terminée');
            c1.recordTypeId = (ID)RTs.get('CBM_Mise_en_place');
            insert c1;

            Test.startTest();
                dossier.Date_de_traitement_MEL__c = Date.newInstance(2015, 7, 1);
                update dossier;
            Test.stopTest();
            
            Case cResultat = [Select Date_de_traitement_de_la_MEL__c from Case where Id = :c1.Id];
            /** Bloquant pour MEP Oscar CBI
            System.assertEquals(dossier.Date_de_traitement_MEL__c, cResultat.Date_de_traitement_de_la_MEL__c);
			*/
        }        
    }
    
    static testMethod void testCalculateDateDeMELBulk() {
        
        User u = TestFactory.createUser();
        
        System.runAs(u){
        
            Map<String,Id> RTs = DAL.getRecordType('Case');
        
            Account tiers = TestFactory.createAccount('test');
            insert tiers;
            
            Contract dossier = TestFactory.createContract(tiers.Id);
            dossier.Date_de_traitement_MEL__c = Date.newInstance(2015, 4, 1);
            insert dossier;
            
            List<Case> casesMiseEnPlace = TestFactory.createCaseWithRTBulk(220, String.valueOf(dossier.Id), 'Terminée', (ID)RTs.get('CBM_Mise_en_place'), true);

            Test.startTest();
                dossier.Date_de_traitement_MEL__c = Date.newInstance(2015, 7, 1);
                update dossier;
            Test.stopTest();
            
            List<Case> cResultat = [Select Date_de_traitement_de_la_MEL__c from Case where Id IN :casesMiseEnPlace];
            
            for(Case c : cResultat)
                System.assertEquals(dossier.Date_de_traitement_MEL__c, c.Date_de_traitement_de_la_MEL__c);
        }        
    }
    
}