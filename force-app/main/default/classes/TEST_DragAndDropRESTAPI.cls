@isTest 
public class TEST_DragAndDropRESTAPI {
 @testSetup static void MethodPrepare() {
        Opportunity lOpportunity;
        Opportunity lOpportunity2;
      	Account lTiers;
        Bien_CBI__c lBienCBI;
        ListeDeBien__c LListeDeBien;
        RecordType lRecordTypeOpp   = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIProjetAssocie' and SobjectType = 'Opportunity'];
        RecordType lRecordTypeTiers = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Tiers'  and SobjectType = 'Account'] ;
        RecordType lRecordTypeBienCBI = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIBienCBI'];
        RecordType lRecordTypelisteDeBienCBI = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CBIListeDeBien'];
      
        Map<String,Id>mapBDD_RT=new Map<String,Id>();
        for(RecordType RT:[Select Id,DeveloperName from RecordType where SObjectType='CategorieDocumentAssocie__c']){
            mapBDD_RT.put(RT.DeveloperName,RT.Id);
        }
        
        CategorieDocumentAssocie__c[] RefData=  new List<CategorieDocumentAssocie__c>();
		RefData.add(new CategorieDocumentAssocie__c(RecordTypeId=mapBDD_RT.get('CDAProjetAssocieCBI'),LABEL__C='Statuts mis jour et certifiés conformes du preneur',SECTION__C='CLIENT',CATEGORIE__C='KYC',TYPEDOPERATION__C='Acquisition',COMPLETUDEFRONT__C=true,CRYPTED__C=false,ARPON__C=false,DEMANDECLIENT__C=false,DEMANDENOTAIRE__C=false,DEMANDECHEFDEFILE__C=false,DEMANDERESEAU__C=false));
        RefData.add(new CategorieDocumentAssocie__c(RecordTypeId=mapBDD_RT.get('CDAProjetAssocieCBI'),LABEL__C='Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)',SECTION__C='PROJET DE SIGNATURE',CATEGORIE__C='Acquisition (demande CHQ - AF partenaire - R‚gul frais - VIRT)',TYPEDOPERATION__C='Acquisition',COMPLETUDEFRONT__C=true,CRYPTED__C=false,ARPON__C=false,DEMANDECLIENT__C=false,DEMANDENOTAIRE__C=false,DEMANDECHEFDEFILE__C=false,DEMANDERESEAU__C=false));
        RefData.add(new CategorieDocumentAssocie__c(RecordTypeId=mapBDD_RT.get('CDAProjetAssocieCBI'),LABEL__C='VEFA - Garantie bancaire d\'achèvement sous forme de cautionnement (si possible)',SECTION__C='JURIDIQUE',CATEGORIE__C='Droits des Sociétés (Identité‚ Clients - Garants)',TYPEDOPERATION__C='VEFA',COMPLETUDEFRONT__C=false,CRYPTED__C=false,ARPON__C=false,DEMANDECLIENT__C=false,DEMANDENOTAIRE__C=false,DEMANDECHEFDEFILE__C=false,DEMANDERESEAU__C=false));
        RefData.add(new CategorieDocumentAssocie__c(RecordTypeId=mapBDD_RT.get('CDABienCBI'),LABEL__C='Polices d\'assurances DO',SECTION__C='ASSURANCES',CATEGORIE__C='DO-CNR-TRC',TYPEDOPERATION__C='VEFA',COMPLETUDEFRONT__C=true,CRYPTED__C=false,ARPON__C=false,DEMANDECLIENT__C=false,DEMANDENOTAIRE__C=false,DEMANDECHEFDEFILE__C=false,DEMANDERESEAU__C=false));
        RefData.add(new CategorieDocumentAssocie__c(RecordTypeId=mapBDD_RT.get('CDABienCBI'),LABEL__C='PV de Réception',SECTION__C='CHANTIER',CATEGORIE__C='PiŠces chantier ant‚rieur - PV de R‚ception',TYPEDOPERATION__C='Acquisition',COMPLETUDEFRONT__C=false,CRYPTED__C=false,ARPON__C=false,DEMANDECLIENT__C=false,DEMANDENOTAIRE__C=false,DEMANDECHEFDEFILE__C=false,DEMANDERESEAU__C=false));
        RefData.add(new CategorieDocumentAssocie__c(RecordTypeId=mapBDD_RT.get('CDABienCBI'),LABEL__C='Diagnostics techniques (énergètique / gaz / électricité)',SECTION__C='TECHNIQUE',CATEGORIE__C='Diagnostics - Expertises - BASIAS - BASOL - ERNMT - DPE',TYPEDOPERATION__C='Acquisition et Travaux',COMPLETUDEFRONT__C=true,CRYPTED__C=false,ARPON__C=false,DEMANDECLIENT__C=false,DEMANDENOTAIRE__C=false,DEMANDECHEFDEFILE__C=false,DEMANDERESEAU__C=false));
        insert RefData;
      
        lTiers = new Account(Name = 'Test', RecordTypeId = lRecordTypeTiers.Id);
        insert lTiers;      
        
        Projet__c lProjet = new Projet__c(Name = 'Test', NomDuTiers__c = lTiers.Id);
        insert lProjet;
        
       Projet__c lProjet2 = new Projet__c(Name = 'Test2', NomDuTiers__c = lTiers.Id);
        insert lProjet2;
      
        lOpportunity = new Opportunity(
            Name = 'Test Garantie Triggers',
            RecordTypeId = lRecordTypeOpp.Id,
            NomDuProjet__c = lProjet.Id,
            AccountId = lTiers.Id, 
            TypeDOperation__c = 'Acquisition et Travaux',
            StageName = 'Pré-Etude',
            Jalon__c='Nouveau Projet',
            Amount =  3950000,
            PreloyersDEngagement__c =  0.10,
            PreloyersDeTVAPerc__c = 1.5,
            PreloyersDeFinancement__c = 1.5,
            CloseDate = Date.newInstance(2018,06,22),
            FraisDeDossier__c = 7975,
            QuotePartNL__c = 100,
            Chantier__c = true,
            DureDuChantierMois__c = 36,
           Copropriete__c = true,
           VEFA__c = false 
        );
		insert lOpportunity;  
        
       lOpportunity2 = new Opportunity(
            Name = 'Test Completude Ctrl',
            RecordTypeId = lRecordTypeOpp.Id,
            NomDuProjet__c = lProjet2.Id,
            AccountId = lTiers.Id,
            TypeDOperation__c = 'Construction',
            StageName = 'Pré-Etude',
            Jalon__c='Nouveau Projet',
            Amount =  3950000,
            PreloyersDEngagement__c =  0.10,
            PreloyersDeTVAPerc__c = 1.5,
            PreloyersDeFinancement__c = 1.5,
            CloseDate = Date.newInstance(2018,06,22),
            FraisDeDossier__c = 7975,
            QuotePartNL__c = 100,
            Chantier__c = true,
            DureDuChantierMois__c = 36
        );
		insert lOpportunity2;  
      
      
        lBienCBI = new Bien_CBI__c(Name = 'BienCBICompletudeDossier', RecordTypeId = lRecordTypeBienCBI.Id);
      	insert lBienCBI;
      
        LListeDeBien = new ListeDeBien__c(Biens__c = lBienCBI.id,Projet__c = lProjet.id ,  RecordTypeId = lRecordTypelisteDeBienCBI.Id);
        insert LListeDeBien; 
     
       ContentWorkSpace  CWList = [SELECT Id, Name From ContentWorkspace WHERE Name = 'Dossier Electronique'] ;
     
  }   
   static testMethod  VOID  testCalloutProjet() {
         Projet__c lProjet = [Select id from Projet__c Limit 1 ];
         DocumentAssocie__c   CheckIfNewDocExist ;
         CheckIfNewDocExist = [   SELECT ID
                                  from DocumentAssocie__c
                                  where Projet__c =: lProjet.id
                                  And TypeDuDocument__c =: 'Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)'
                                  and CompletudeEntete__c = true
                              ]; 
       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
	
        RestRequest req = new RestRequest(); 
  		RestResponse res = new RestResponse();
 
    

        String JsonMsg=JSON.serialize('"Name" : "Marketing Brochure Q1","Type" : "pdf","Keywords" : "marketing,sales,update","ContentDocumentId" : "069D00000000so2","ReasonForChange" : "Marketing materials updated","PathOnClient" : "Q1 Sales Brochure.pdf"');
       
        req.requestURI = '/services/apexrest/DragAndDrop/v1' ;
        req.addParameter('FileName', 'test');
        req.addParameter('cType', 'PROJET DE SIGNATURE');
        req.addParameter('parId', lProjet.id);
 		req.addParameter('repertoire', 'Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)');
        req.addParameter('TypeObjet', 'Projet');
     
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
       
        DragAndDropRESTAPI.attachDoc();
         Test.stopTest();
    }
     static testMethod  VOID  testCalloutBien() {
          Bien_CBI__c lBienCBI = [Select id from Bien_CBI__c Limit 1 ];    
         DocumentAssocie__c   CheckIfNewDocExist ;
         CheckIfNewDocExist = [   SELECT ID
                                  from DocumentAssocie__c
                                  where BienCBI__c =: lBienCBI.id
                                  And TypeDuDocument__c = 'Diagnostics techniques (énergètique / gaz / électricité)'
                                  and CompletudeEntete__c = true
                              ]; 
 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
	
        RestRequest req = new RestRequest(); 
  		RestResponse res = new RestResponse();
 
    

        String JsonMsg=JSON.serialize('"Name" : "Marketing Brochure Q1","Type" : "pdf","Keywords" : "marketing,sales,update","ContentDocumentId" : "069D00000000so2","ReasonForChange" : "Marketing materials updated","PathOnClient" : "Q1 Sales Brochure.pdf"');
       
        req.requestURI = '/services/apexrest/DragAndDrop/v1' ;
        req.addParameter('FileName', 'test');
        req.addParameter('cType', 'Diagnostics - Expertises - BASIAS - BASOL - ERNMT - DPE');
        req.addParameter('parId', lBienCBI.id);
 		req.addParameter('repertoire', 'Diagnostics techniques (énergètique / gaz / électricité)');
        req.addParameter('TypeObjet', 'Bien');
     
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
       
        DragAndDropRESTAPI.attachDoc();
         Test.stopTest();
    }
}