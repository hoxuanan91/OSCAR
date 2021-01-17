/*************************************************************************************
* @date 22/05/2019
* @description Classe de test pour le trigger LLD_LeadConversion
* Nom de la classe - LLD_TestLeadConversion
*************************************************************************************/

@isTest
private class LLD_TestLeadConversion {

    /*Test avec un conseiller existant*/
    @isTest static void TestleadConseillerExistant() {
        
        /*Récupération de l'ID des record types utilisés dans le test*/
        Id BanqueRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CBI - Réseau Banque Caisse').getRecordTypeId();
        Id ConseillerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CBI - Réseau').getRecordTypeId();
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead LLD').getRecordTypeId();

        /*Création d'un enregistrement établissement */
    	Account banque = new Account(Name='BP Alsace Lorraine Champagne', RecordTypeId=BanqueRecordTypeId);
    	insert banque;
        
        /*Création d'un enregistrement conseiller client*/
    	Contact conseiller = new Contact(Email='paul.simon@bp.com', LastName='Simon', MobilePhone='0123456789', RecordTypeId=ConseillerRecordTypeId);
        conseiller.AccountId = banque.Id;
    	insert conseiller;                
        
        /*Création d'un lead*/
    	Lead lead = new Lead(Company='Test', FirstName='John', LastName='Smith', Email_conseiller__c='paul.simon@bp.com', Nom_conseiller__c='Simon',Etablissement__c='BP Alsace Lorraine Champagne', RecordTypeId=LeadRecordTypeId);
        insert lead;

		test.StartTest();
        
        /*Conversion du lead*/
        Database.LeadConvert lc = new Database.LeadConvert();
        
        lc.setLeadId(lead.id);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel, ApiName FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.ApiName);
        lc.setDoNotCreateOpportunity(true); /*Pour le test il n'est pas nécessaire de créer un projet associé*/
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
             
        lead= [SELECT ConvertedAccountId, Id,isConverted FROM Lead Where Id = :lead.Id];
        /*Sélection du tiers créé lors de la conversion du lead*/
        List<Account> account = [SELECT Id, Conseiller_client__c, Apporteur__c,RecordTypeId FROM Account WHERE Id=:lead.ConvertedAccountId]; 
   
        /*Vérification du lien entre le tiers et l'enregistrement Etablissement + Conseiller*/
        System.assertEquals(account[0].Conseiller_client__c,conseiller.Id);  
        System.assertEquals(account[0].Apporteur__c,banque.Id);
	    
        test.stopTest();
         
    }
    
    /*Test avec la création d'un nouveau conseiller*/
     @isTest static void TestleadConseillerNonExistant() {
         
         /*Récupération de l'ID des record types utilisés dans le test */
         Id BanqueRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CBI - Réseau Banque Caisse').getRecordTypeId();
         Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead LLD').getRecordTypeId();

         /*Création d'un enregistrement établissement*/
         Account banque = new Account(Name='B P Alésace Lorr-ainèe Ch&a_mpè-agç n e', RecordTypeId=BanqueRecordTypeId);
    	 insert banque;
         
         /*Création du lead*/
         Lead lead = new Lead(Company='Test', FirstName='John', LastName='Smith', Email_conseiller__c='paul.simon@bp.com', Nom_conseiller__c='Simon',Etablissement__c='BP Alsace Lorraine Champagne', RecordTypeId=LeadRecordTypeId);
         insert lead;
         
         test.StartTest();
        
        /*Conversion du lead*/
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.id);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel, ApiName FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.ApiName);
        lc.setDoNotCreateOpportunity(true);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
         
        lead= [SELECT ConvertedAccountId, Id,isConverted FROM Lead Where Id = :lead.Id];

        /*Sélection du tiers créé lors de la conversion du lead*/
        List<Account> account = [SELECT Id, Conseiller_client__c, Apporteur__c,RecordTypeId FROM Account WHERE Id=:lead.ConvertedAccountId]; 
        Id conseillerId = account[0].Conseiller_client__c;
        /*Séléction du conseiller créé lors de la conversion*/
        List<Contact> conseiller = [SELECT FirstName, LastName, Email FROM Contact WHERE Id=:conseillerId]; 
   
         /*Vérification que le nouveau conseiller a bien récupéré les données du lead*/
        System.assertEquals(conseiller[0].Email,'paul.simon@bp.com');  
         
     }
    
      
    /*Test transfert Simulation */
     @isTest static void TestTransfertSimulation() {
         
         /*Récupération de l'ID des record types utilisés dans le test */
         Id BanqueRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CBI - Réseau Banque Caisse').getRecordTypeId();
         Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead LLD').getRecordTypeId();

         /*Création d'un enregistrement établissement*/
         Account banque = new Account(Name='B P Alésace Lorr-ainèe Ch&a_mpè-agç n e', RecordTypeId=BanqueRecordTypeId);
    	 insert banque;
         
         /*Création du lead*/
         Lead lead = new Lead(Company='Test', FirstName='John', LastName='Smith', Email_conseiller__c='paul.simon@bp.com', Nom_conseiller__c='Simon',Etablissement__c='BP Alsace Lorraine Champagne', RecordTypeId=LeadRecordTypeId);
         insert lead;
         
         simulation__c simulationLLD=new simulation__c();
         simulationLLD.Lead__c=lead.Id;
         simulationLLD.Retenue__c=true;
         simulationLLD.URL_de_la_simulation__c='www.google.com';
         insert simulationLLD;
         
         test.StartTest();
        
        /*Conversion du lead*/
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.id);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel, ApiName FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.ApiName);
       
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
         
        lead= [SELECT ConvertedAccountId, Id,isConverted FROM Lead Where Id = :lead.Id];

        /*Sélection du tiers créé lors de la conversion du lead*/
        List<Account> account = [SELECT Id, Conseiller_client__c, Apporteur__c,RecordTypeId FROM Account WHERE Id=:lead.ConvertedAccountId]; 
       
        List<simulation__c> simulations=[select id, Lead__c, Tiers__c ,Retenue__c,URL_de_la_simulation__c
                                   from simulation__c limit 1];
         
   
         /*Vérification que le nouveau conseiller a bien récupéré les données du lead*/
        System.assertNotEquals(simulations[0].Tiers__c,null);  
         
     }
    
}