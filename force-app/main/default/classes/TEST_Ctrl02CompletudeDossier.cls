@isTest 
public class TEST_Ctrl02CompletudeDossier {
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
        RefData.add(new CategorieDocumentAssocie__c(RecordTypeId=mapBDD_RT.get('CDAProjetAssocieCBI'),LABEL__C='Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)',SECTION__C='PROJET DE SIGNATURE',CATEGORIE__C='Acquisition (demande CHQ - AF partenaire - R‚gul frais - VIRT)',TYPEDOPERATION__C='Acquisition',COMPLETUDEFRONT__C=false,CRYPTED__C=false,ARPON__C=false,DEMANDECLIENT__C=false,DEMANDENOTAIRE__C=false,DEMANDECHEFDEFILE__C=false,DEMANDERESEAU__C=false));
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
  } 
      static testMethod  VOID  testStdCtrlVisualforceProjet(){ 
        Projet__c lProjet = [Select id from Projet__c Limit 1 ];
        Test.startTest();
		PageReference pageRef = Page.VFP02_CompletudeDossierProjet;
        Test.setCurrentPage(pageRef);
      	ApexPages.CurrentPage().getparameters().put('id', lProjet.id);
        ApexPages.StandardController sc = new ApexPages.standardController(lProjet);
        Ctrl02_CompletudeDossier CtrlCompletudeDossier = new Ctrl02_CompletudeDossier(sc);
        CtrlCompletudeDossier.TypeDobjet = 'projet';
	    Test.stopTest();
        //Afficher en system debug certaines limites clefs (governor)
	} 
    static testMethod  VOID  testStdCtrlVisualforceProjetPAVefaTravauxConstruction(){ 
        Projet__c lProjet = [Select id from Projet__c Limit 1 ];
        Opportunity lOpportunity = [Select id,Copropriete__c, VEFA__c, NomDuProjet__c from Opportunity where NomDuProjet__c =:lProjet.id  Limit 1 ];
        Test.startTest();
        lOpportunity.Copropriete__c = false;
        lOpportunity.VEFA__c=true;
        update lOpportunity;
		PageReference pageRef = Page.VFP02_CompletudeDossierProjet;
        Test.setCurrentPage(pageRef);
        
      	ApexPages.CurrentPage().getparameters().put('id', lProjet.id);
        ApexPages.StandardController sc = new ApexPages.standardController(lProjet);
        Ctrl02_CompletudeDossier CtrlCompletudeDossier = new Ctrl02_CompletudeDossier(sc);
        CtrlCompletudeDossier.TypeDobjet = 'projet';
      
	    Test.stopTest();
        //Afficher en system debug certaines limites clefs (governor)
	} 
        static testMethod  VOID  testStdCtrlVisualforceProjetPAVefaTravauxConstructionVEfaCopro(){ 
        Projet__c lProjet = [Select id from Projet__c Limit 1 ];
         Opportunity lOpportunity = [Select id,Copropriete__c, VEFA__c, NomDuProjet__c from Opportunity where NomDuProjet__c =:lProjet.id  Limit 1 ];
  
        Test.startTest();
        lOpportunity.Copropriete__c = true;
        lOpportunity.VEFA__c=true;
        update lOpportunity;
		PageReference pageRef = Page.VFP02_CompletudeDossierProjet;
        Test.setCurrentPage(pageRef);
        
      	ApexPages.CurrentPage().getparameters().put('id', lProjet.id);
        ApexPages.StandardController sc = new ApexPages.standardController(lProjet);
        Ctrl02_CompletudeDossier CtrlCompletudeDossier = new Ctrl02_CompletudeDossier(sc);
        CtrlCompletudeDossier.TypeDobjet = 'projet';
        
      
	    Test.stopTest();
        //Afficher en system debug certaines limites clefs (governor)
	} 
    
    
     static testMethod  VOID  testStdCtrlVisualforceProjetSaveCompletude(){ 
        Projet__c lProjet = [Select id from Projet__c Limit 1 ];
        Test.startTest();
        
		PageReference pageRef = Page.VFP02_CompletudeDossierProjet;
        Test.setCurrentPage(pageRef);
        
      	pageRef.getparameters().put('ID', lProjet.id);
         
        ApexPages.StandardController sc = new ApexPages.standardController(lProjet);
        Ctrl02_CompletudeDossier CtrlCompletudeDossier = new Ctrl02_CompletudeDossier(sc);
       	System.assertEquals(lProjet.id,ApexPages.currentPage().getParameters().get('Id'));
		
        CtrlCompletudeDossier.TypeDobjet = 'projet';
    	CtrlCompletudeDossier.ListDocMandatory.put('Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)', true);
    	CtrlCompletudeDossier.SaveCompletude();
        CtrlCompletudeDossier.ListDocMandatory.put('Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)', false);
    	CtrlCompletudeDossier.SaveCompletude();
        CtrlCompletudeDossier.ListDocMandatory.put('Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)', true);
        CtrlCompletudeDossier.ListDemandeClient.put('Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)', true);
    	CtrlCompletudeDossier.SaveCompletude();
         CtrlCompletudeDossier.ListDocMandatory.put('Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)', true);
        CtrlCompletudeDossier.ListDemandeClient.put('Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)', true);
    	CtrlCompletudeDossier.SaveCompletude();
         
        Test.setCurrentPage(pageRef);
	    Test.stopTest();
        //Afficher en system debug certaines limites clefs (governor)
	} 
      static testMethod  VOID  testStdCtrlVisualforceProjetSaveCompletudeBeforeAfter(){ 
        Projet__c lProjet = [Select id from Projet__c Limit 1 ];
        Test.startTest();
        
		PageReference pageRef = Page.VFP02_CompletudeDossierProjet;
        Test.setCurrentPage(pageRef);
        
      	pageRef.getparameters().put('ID', lProjet.id);
         
        ApexPages.StandardController sc = new ApexPages.standardController(lProjet);
        Ctrl02_CompletudeDossier CtrlCompletudeDossier = new Ctrl02_CompletudeDossier(sc);
       	System.assertEquals(lProjet.id,ApexPages.currentPage().getParameters().get('Id'));
		
        CtrlCompletudeDossier.TypeDobjet = 'projet'; 
        CtrlCompletudeDossier.ListDocMandatory.put('Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)', true);
        CtrlCompletudeDossier.ListDemandeClient.put('Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)', true);
    	CtrlCompletudeDossier.SaveCompletude();
    	CtrlCompletudeDossier.ListDemandeClient.put('Autres (demande CHQ - AF partenaire - R‚gul frais - VIRT)', false);
        CtrlCompletudeDossier.SaveCompletude();
         
         
        Test.setCurrentPage(pageRef);
	    Test.stopTest();
        //Afficher en system debug certaines limites clefs (governor)
	} 
   static testMethod  VOID  testStdCtrlVisualforceProjetSansProjetAssocie(){ 
        Projet__c lProjet = [Select id from Projet__c Limit 1 ];
        Projet__c lProjet2 = [Select id from Projet__c where name = 'Test2' Limit 1 ];
        Opportunity lOpportunity = [Select id, NomDuProjet__c from Opportunity where NomDuProjet__c =:lProjet.id  Limit 1 ];
        Test.startTest();
        lOpportunity.NomDuProjet__c = lProjet2.id;
        update  lOpportunity;
		PageReference pageRef = Page.VFP02_CompletudeDossierProjet;
        Test.setCurrentPage(pageRef);
        
      	ApexPages.CurrentPage().getparameters().put('id', lProjet.id);
        ApexPages.StandardController sc = new ApexPages.standardController(lProjet);
        Ctrl02_CompletudeDossier CtrlCompletudeDossier = new Ctrl02_CompletudeDossier(sc);
    	
      
	    Test.stopTest();
        //Afficher en system debug certaines limites clefs (governor)
	} 
    static testMethod  VOID  testStdCtrlVisualforceProjetMultiProjetAssocie(){ 
        Projet__c lProjet = [Select id from Projet__c Limit 1 ]; 
        List<Opportunity> lOpportunity = [Select id, NomDuProjet__c from Opportunity where name  = 'Test Completude Ctrl' Limit 1 ];
        Test.startTest();
        
        if(lOpportunity.size() != 0){
            lOpportunity[0].NomDuProjet__c = lProjet.id;
        	update  lOpportunity;
        }    
        
		PageReference pageRef = Page.VFP02_CompletudeDossierProjet;
        Test.setCurrentPage(pageRef);
        
      	ApexPages.CurrentPage().getparameters().put('id', lProjet.id);
        ApexPages.StandardController sc = new ApexPages.standardController(lProjet);
        Ctrl02_CompletudeDossier CtrlCompletudeDossier = new Ctrl02_CompletudeDossier(sc);
    	
      
	    Test.stopTest();
        //Afficher en system debug certaines limites clefs (governor)
	} 
    
       static testMethod  VOID  testStdCtrlVisualforceBien(){ 
         Bien_CBI__c lBienCBI = [Select id from Bien_CBI__c Limit 1 ];      
        Test.startTest();
        
		PageReference pageRef = Page.VFP02_CompletudeDossierBien;
        Test.setCurrentPage(pageRef);
        
      	ApexPages.CurrentPage().getparameters().put('id', lBienCBI.id);
        ApexPages.StandardController sc = new ApexPages.standardController(lBienCBI);
       
        Ctrl02_CompletudeDossier CtrlCompletudeDossier = new Ctrl02_CompletudeDossier(sc);
    	
      
	    Test.stopTest();
        //Afficher en system debug certaines limites clefs (governor)
	} 
     static testMethod  VOID  testStdCtrlVisualforceBienSaveCompletude(){ 
        Bien_CBI__c lBienCBI = [Select id from Bien_CBI__c Limit 1 ];      
        Test.startTest();
        
		PageReference pageRef = Page.VFP02_CompletudeDossierBien;
        Test.setCurrentPage(pageRef); 
      	pageRef.getparameters().put('id', lBienCBI.id);
        ApexPages.StandardController sc = new ApexPages.standardController(lBienCBI);
       
        Ctrl02_CompletudeDossier CtrlCompletudeDossier = new Ctrl02_CompletudeDossier(sc);
    	CtrlCompletudeDossier.TypeDobjet = 'bien';
    	CtrlCompletudeDossier.ListDocMandatory.put('PV de Réception', true);
    	CtrlCompletudeDossier.SaveCompletude();
        CtrlCompletudeDossier.ListDocMandatory.put('PV de Réception', false);
    	CtrlCompletudeDossier.SaveCompletude();
        CtrlCompletudeDossier.ListDocMandatory.put('PV de Réception', true);
        CtrlCompletudeDossier.ListDemandeClient.put('PV de Réception', true);
    	CtrlCompletudeDossier.SaveCompletude();
        CtrlCompletudeDossier.ListDocMandatory.put('PV de Réception', true); 
    	CtrlCompletudeDossier.ListDemandeClient.put('PV de Réception', false);
        CtrlCompletudeDossier.SaveCompletude();
         
         
        Test.setCurrentPage(pageRef);
         
      
	    Test.stopTest();
        
	    
        //Afficher en system debug certaines limites clefs (governor)
	} 
    static testMethod  VOID  testStdCtrlVisualforceBienSaveCompletudeBeforeAfter(){ 
        Bien_CBI__c lBienCBI = [Select id from Bien_CBI__c Limit 1 ];      
        Test.startTest();
        
		PageReference pageRef = Page.VFP02_CompletudeDossierBien;
        Test.setCurrentPage(pageRef); 
      	pageRef.getparameters().put('id', lBienCBI.id);
        ApexPages.StandardController sc = new ApexPages.standardController(lBienCBI);
       
        Ctrl02_CompletudeDossier CtrlCompletudeDossier = new Ctrl02_CompletudeDossier(sc);
    	CtrlCompletudeDossier.TypeDobjet = 'bien';
    	CtrlCompletudeDossier.ListDocMandatory.put('Polices d\'assurances DO', false);
    	CtrlCompletudeDossier.SaveCompletude();
        CtrlCompletudeDossier.ListDocMandatory.put('Polices d\'assurances DO', true); 
    	CtrlCompletudeDossier.SaveCompletude();
         
        Test.setCurrentPage(pageRef);
         
      
	    Test.stopTest();
        
	    
        //Afficher en system debug certaines limites clefs (governor)
	} 
    
    
}