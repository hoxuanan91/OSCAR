/*************************************************************************************
* @date 22/05/2019
* @description  Classe de test pour la classe LLD_FileUploadController
* Nom de la classe - LLD_FileUploadController_Test
*************************************************************************************/
@isTest
public class LLD_FileUploadController_Test {
    /**
    * Variables du test
    * *****/
    static Lead aLead;
    static LLD_FileUploadController testFileUploadController;
    
    /**
    * @date  22/05/2019
    * @description Création des données utilisées dans la classe de test
    * *****/
    static void initTestData(){
        aLead = new Lead();
        aLead.Etablissement__c = 'BP MED';
        aLead.Prenom_conseiller__c = 'Test';
        aLead.Agence__c = 'agenceTest';
        aLead.Nom_conseiller__c = 'test';
        aLead.Tel_conseiller__c = '4384984702';
        aLead.Email_conseiller__c = 'test@gmail.com';
        aLead.Company = 'testcompany';
        aLead.SIRET__c = 'mocksiret';
        aLead.LastName = 'clientname';
        aLead.Email = 'clientemail@gmail.com';
        aLead.MobilePhone = '4384984703';
        aLead.Note_Bale_II__c = 'Oui';
        aLead.Dirigeant_anciennete__c = 'Oui';
        aLead.Cotation_BdF__c = 'Oui';
        aLead.Bilan_12_mois__c = 'Oui';
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aLead);
        testFileUploadController = new LLD_FileUploadController(sc);            
    }
    
    /**
    * @date 22/05/2019
    * @description Test de la fonction getBase64
    * *****/
    public static testMethod void testGetBase64(){
        initTestData();
        
        testFileUploadController.setbase64('test base 64');        
        
        system.assertEquals('test base 64', testFileUploadController.getBase64());
    }
    
    /**
    * @date 22/05/2019
    * @description Test de la fonction saveFile avec aucun document
    * @expected : Redirection vers la page de succès et le lead est bien dans Salesforce
    * *****/
    public static testMethod void testUploadOkNoFile() {
        initTestData();
        
        /** Aucun document **/
        testFileUploadController.setbase64(' ');
        testFileUploadController.fileName = ' ';
        
        PageReference testSaveFile = testFileUploadController.saveFile();
        
        /** Vérification que le lead est bien ajouté **/
        Lead leadFromDB = [SELECT Etablissement__c, Prenom_conseiller__c, Agence__c, Nom_conseiller__c, Tel_conseiller__c, LeadSource,
                           Email_conseiller__c, Company, SIRET__c, LastName, Email, MobilePhone, Note_Bale_II__c, Dirigeant_anciennete__c, Cotation_BdF__c
                          FROM Lead WHERE Company =: aLead.Company];
        
        system.assertEquals('Réseau', leadFromDB.LeadSource);
        system.assertEquals(aLead.Etablissement__c, leadFromDB.Etablissement__c);
        system.assertEquals(aLead.Prenom_conseiller__c, leadFromDB.Prenom_conseiller__c);
        system.assertEquals(aLead.Agence__c, leadFromDB.Agence__c);
        system.assertEquals(aLead.Nom_conseiller__c, leadFromDB.Nom_conseiller__c);
        system.assertEquals(aLead.Tel_conseiller__c, leadFromDB.Tel_conseiller__c);
        system.assertEquals(aLead.Email_conseiller__c, leadFromDB.Email_conseiller__c);
        system.assertEquals(aLead.Company, leadFromDB.Company);
        system.assertEquals(aLead.SIRET__c, leadFromDB.SIRET__c);
        system.assertEquals(aLead.LastName, leadFromDB.LastName);
        system.assertEquals(aLead.Email, leadFromDB.Email);
        system.assertEquals(aLead.MobilePhone, leadFromDB.MobilePhone);
        system.assertEquals(aLead.Note_Bale_II__c, leadFromDB.Note_Bale_II__c);
        system.assertEquals(aLead.Dirigeant_anciennete__c, leadFromDB.Dirigeant_anciennete__c);
        system.assertEquals(aLead.Cotation_BdF__c, leadFromDB.Cotation_BdF__c);
        
        /** Redirection vers page de succès **/
        system.assertEquals('/apex/LL_NetworkForm_Success', testSaveFile.getUrl());
    }
    
    /**
    * @date 22/05/2019
    * @description Test de la fonction saveFile avec aucun document & une erreur sur l'upload du lead
    * @expected : Retourne null et aucun lead ajouté
    * *****/
    public static testMethod void testUploadKoNoFile() {
        initTestData();
        
        aLead.Etablissement__c = 'ERROR';
        
        /** Aucun document **/
        testFileUploadController.setbase64(' ');
        testFileUploadController.fileName = ' ';
        
        PageReference testSaveFile = testFileUploadController.saveFile();
        
        /** Vérification qu'aucun lead n'a été ajouté **/
        List<Lead> leadFromDB = [SELECT Etablissement__c, Prenom_conseiller__c, Agence__c, Nom_conseiller__c, Tel_conseiller__c, LeadSource,
                           Email_conseiller__c, Company, SIRET__c, LastName, Email, MobilePhone, Note_Bale_II__c, Dirigeant_anciennete__c, Cotation_BdF__c
                          FROM Lead WHERE Company =: aLead.Company];
        
        system.assertEquals(0, leadFromDB.size());
        
        /** Vérification qu'il n'y a pas de redirection **/
        system.assertEquals(null, testSaveFile);
    }

    /**
    * @date 22/05/2019
    * @description Test de la fonction saveFile avec deux documents
    * @expected : Redirection vers la page de succès et les documents sont uploadés
    * *****/    
    public static testMethod void TestUploadOkTwoFile() {
        initTestData();
        
        /** Document 1 **/
        testFileUploadController.setbase64(EncodingUtil.Base64Encode(Blob.valueOf('test body 1')));
        testFileUploadController.fileName = 'test1.pdf';
        testFileUploadController.fileCurrentNumber = 0;
        testFileUploadController.fileTotalNumber = 2;
        
        PageReference testSaveFile = testFileUploadController.saveFile();
        
        /** Vérification que le lead est bien ajouté **/
        Lead leadFromDB = [SELECT Id, Etablissement__c, Prenom_conseiller__c, Agence__c, Nom_conseiller__c, Tel_conseiller__c, LeadSource,
                           Email_conseiller__c, Company, SIRET__c, LastName, Email, MobilePhone, Note_Bale_II__c, Dirigeant_anciennete__c, Cotation_BdF__c
                          FROM Lead WHERE Company =: aLead.Company];
        
        system.assertEquals('Réseau', leadFromDB.LeadSource);
        system.assertEquals(aLead.Etablissement__c, leadFromDB.Etablissement__c);
        system.assertEquals(aLead.Prenom_conseiller__c, leadFromDB.Prenom_conseiller__c);
        system.assertEquals(aLead.Agence__c, leadFromDB.Agence__c);
        system.assertEquals(aLead.Nom_conseiller__c, leadFromDB.Nom_conseiller__c);
        system.assertEquals(aLead.Tel_conseiller__c, leadFromDB.Tel_conseiller__c);
        system.assertEquals(aLead.Email_conseiller__c, leadFromDB.Email_conseiller__c);
        system.assertEquals(aLead.Company, leadFromDB.Company);
        system.assertEquals(aLead.SIRET__c, leadFromDB.SIRET__c);
        system.assertEquals(aLead.LastName, leadFromDB.LastName);
        system.assertEquals(aLead.Email, leadFromDB.Email);
        system.assertEquals(aLead.MobilePhone, leadFromDB.MobilePhone);
        system.assertEquals(aLead.Note_Bale_II__c, leadFromDB.Note_Bale_II__c);
        system.assertEquals(aLead.Dirigeant_anciennete__c, leadFromDB.Dirigeant_anciennete__c);
        system.assertEquals(aLead.Cotation_BdF__c, leadFromDB.Cotation_BdF__c);
        
        /** Pas de redirection pour le document **/
        system.assertEquals(null, testSaveFile);
        
        /** Vérification que le content document est ajouté **/
        ContentVersion contentVersionFromDB = [SELECT Id, Title, PathOnClient, VersionData, IsMajorVersion FROM ContentVersion WHERE Title = 'test1.pdf'];
        system.assertEquals('test1.pdf', contentVersionFromDB.Title);
        system.assertEquals('test1.pdf', contentVersionFromDB.PathOnClient);
        system.assertEquals('test body 1', contentVersionFromDB.VersionData.toString());
        system.assertEquals(true, contentVersionFromDB.IsMajorVersion);
        
        /** Vérification que le document est bien lié au lead **/
        ContentDocumentLink cdlFromDB = [Select LinkedEntityId, ContentDocumentId, shareType FROM ContentDocumentLink WHERE LinkedEntityId =: leadFromDB.Id];
        system.assertEquals(leadFromDB.Id, cdlFromDB.LinkedEntityId);
        system.assertEquals('V', cdlFromDB.shareType);
        
        delete cdlFromDB;
        
        /** Document 2 **/
        testFileUploadController.setbase64(EncodingUtil.Base64Encode(Blob.valueOf('test body 2')));
        testFileUploadController.fileName = 'test2.pdf';
        testFileUploadController.fileCurrentNumber = 1;
        testFileUploadController.fileTotalNumber = 2;
        
        testSaveFile = testFileUploadController.saveFile();
        
        /** Vérification que le lead n'est pas modifié **/
        leadFromDB = [SELECT Id, Etablissement__c, Prenom_conseiller__c, Agence__c, Nom_conseiller__c, Tel_conseiller__c, LeadSource,
                           Email_conseiller__c, Company, SIRET__c, LastName, Email, MobilePhone, Note_Bale_II__c, Dirigeant_anciennete__c, Cotation_BdF__c
                          FROM Lead WHERE Company =: aLead.Company];
        
        system.assertEquals('Réseau', leadFromDB.LeadSource);
        system.assertEquals(aLead.Etablissement__c, leadFromDB.Etablissement__c);
        system.assertEquals(aLead.Prenom_conseiller__c, leadFromDB.Prenom_conseiller__c);
        system.assertEquals(aLead.Agence__c, leadFromDB.Agence__c);
        system.assertEquals(aLead.Nom_conseiller__c, leadFromDB.Nom_conseiller__c);
        system.assertEquals(aLead.Tel_conseiller__c, leadFromDB.Tel_conseiller__c);
        system.assertEquals(aLead.Email_conseiller__c, leadFromDB.Email_conseiller__c);
        system.assertEquals(aLead.Company, leadFromDB.Company);
        system.assertEquals(aLead.SIRET__c, leadFromDB.SIRET__c);
        system.assertEquals(aLead.LastName, leadFromDB.LastName);
        system.assertEquals(aLead.Email, leadFromDB.Email);
        system.assertEquals(aLead.MobilePhone, leadFromDB.MobilePhone);
        system.assertEquals(aLead.Note_Bale_II__c, leadFromDB.Note_Bale_II__c);
        system.assertEquals(aLead.Dirigeant_anciennete__c, leadFromDB.Dirigeant_anciennete__c);
        system.assertEquals(aLead.Cotation_BdF__c, leadFromDB.Cotation_BdF__c);
        
        /** Vérification qu'il n'a pas de redirection **/
        system.assertEquals(null, testSaveFile);
        
        /** Vérification que le content document est uploadé **/
        contentVersionFromDB = [SELECT Id, Title, PathOnClient, VersionData, IsMajorVersion FROM ContentVersion WHERE Title = 'test2.pdf'];
        system.assertEquals('test2.pdf', contentVersionFromDB.Title);
        system.assertEquals('test2.pdf', contentVersionFromDB.PathOnClient);
        system.assertEquals('test body 2', contentVersionFromDB.VersionData.toString());
        system.assertEquals(true, contentVersionFromDB.IsMajorVersion);
        
        /** Vérification que le document est bien lié au lead **/
        cdlFromDB = [Select LinkedEntityId, ContentDocumentId, shareType FROM ContentDocumentLink WHERE LinkedEntityId =: leadFromDB.Id];
        system.assertEquals(leadFromDB.Id, cdlFromDB.LinkedEntityId);
        system.assertEquals('V', cdlFromDB.shareType);
        
        /** Aucun document, UI validation **/
        testFileUploadController.setbase64(' ');
        testFileUploadController.fileName = ' ';
        testFileUploadController.fileCurrentNumber = 2;
        testFileUploadController.fileTotalNumber = 2;
        
        testSaveFile = testFileUploadController.saveFile();
        
        leadFromDB = [SELECT Id, Etablissement__c, Prenom_conseiller__c, Agence__c, Nom_conseiller__c, Tel_conseiller__c, LeadSource,
                           Email_conseiller__c, Company, SIRET__c, LastName, Email, MobilePhone, Note_Bale_II__c, Dirigeant_anciennete__c, Cotation_BdF__c
                          FROM Lead WHERE Company =: aLead.Company];

        /** Vérification que le lead n'est pas modifié **/        
        system.assertEquals('Réseau', leadFromDB.LeadSource);
        system.assertEquals(aLead.Etablissement__c, leadFromDB.Etablissement__c);
        system.assertEquals(aLead.Prenom_conseiller__c, leadFromDB.Prenom_conseiller__c);
        system.assertEquals(aLead.Agence__c, leadFromDB.Agence__c);
        system.assertEquals(aLead.Nom_conseiller__c, leadFromDB.Nom_conseiller__c);
        system.assertEquals(aLead.Tel_conseiller__c, leadFromDB.Tel_conseiller__c);
        system.assertEquals(aLead.Email_conseiller__c, leadFromDB.Email_conseiller__c);
        system.assertEquals(aLead.Company, leadFromDB.Company);
        system.assertEquals(aLead.SIRET__c, leadFromDB.SIRET__c);
        system.assertEquals(aLead.LastName, leadFromDB.LastName);
        system.assertEquals(aLead.Email, leadFromDB.Email);
        system.assertEquals(aLead.MobilePhone, leadFromDB.MobilePhone);
        system.assertEquals(aLead.Note_Bale_II__c, leadFromDB.Note_Bale_II__c);
        system.assertEquals(aLead.Dirigeant_anciennete__c, leadFromDB.Dirigeant_anciennete__c);
        system.assertEquals(aLead.Cotation_BdF__c, leadFromDB.Cotation_BdF__c);
        
        /** Vérification de la redirection de succès **/
        system.assertEquals('/apex/LL_NetworkForm_Success', testSaveFile.getUrl());
    }
    
    /**
    * @date 22/05/2019
    * @description Test de la fonction saveFile avec 2 documents & une erreur sur l'upload du lead
    * @expected : Pas de redirection, lead et documents non uploadés
    * *****/    
    public static testMethod void testUploadKoTwoFile() {
        initTestData();
        
        aLead.Etablissement__c = 'ERROR';
        
        /** Document 1 **/
        testFileUploadController.setbase64(EncodingUtil.Base64Encode(Blob.valueOf('test body 1')));
        testFileUploadController.fileName = 'test1.pdf';
        testFileUploadController.fileCurrentNumber = 0;
        testFileUploadController.fileTotalNumber = 2;
        
        PageReference testSaveFile = testFileUploadController.saveFile();
        
        /** Vérification que le lead n'est pas ajouté **/
        List<Lead> leadFromDB = [SELECT Id, Etablissement__c, Prenom_conseiller__c, Agence__c, Nom_conseiller__c, Tel_conseiller__c, LeadSource,
                           Email_conseiller__c, Company, SIRET__c, LastName, Email, MobilePhone, Note_Bale_II__c, Dirigeant_anciennete__c, Cotation_BdF__c
                           FROM Lead WHERE Company =: aLead.Company];
        
        system.assertEquals(0, leadFromDB.size());
        
        system.assertEquals(null, testSaveFile);
        
        /** Vérification que le content document n'est pas ajouté**/
        List<ContentVersion> contentVersionFromDB = [SELECT Id, Title, PathOnClient, VersionData, IsMajorVersion FROM ContentVersion WHERE Title = 'test1.pdf'];
        system.assertEquals(0, contentVersionFromDB.size());

        /** Document 2 **/        
        testFileUploadController.setbase64(EncodingUtil.Base64Encode(Blob.valueOf('test body 2')));
        testFileUploadController.fileName = 'test2.pdf';
        testFileUploadController.fileCurrentNumber = 1;
        testFileUploadController.fileTotalNumber = 2;
        
        testSaveFile = testFileUploadController.saveFile();
        
        /** Vérification que le lead n'est pas ajouté **/
        leadFromDB = [SELECT Id, Etablissement__c, Prenom_conseiller__c, Agence__c, Nom_conseiller__c, Tel_conseiller__c, LeadSource,
                      Email_conseiller__c, Company, SIRET__c, LastName, Email, MobilePhone, Note_Bale_II__c, Dirigeant_anciennete__c, Cotation_BdF__c
                      FROM Lead WHERE Company =: aLead.Company];
        
        system.assertEquals(0, leadFromDB.size());
        
        system.assertEquals(null, testSaveFile);
        
        /**  Vérification que le content document n'est pas ajouté **/
        contentVersionFromDB = [SELECT Id, Title, PathOnClient, VersionData, IsMajorVersion FROM ContentVersion WHERE Title = 'test1.pdf'];
        system.assertEquals(0, contentVersionFromDB.size());
        
        /** Aucun document, UI validation **/
        testFileUploadController.setbase64(' ');
        testFileUploadController.fileName = ' ';
        testFileUploadController.fileCurrentNumber = 2;
        testFileUploadController.fileTotalNumber = 2;
        
        testSaveFile = testFileUploadController.saveFile();
        
        /** Vérification que le lead n'est pas ajouté **/
        leadFromDB = [SELECT Id, Etablissement__c, Prenom_conseiller__c, Agence__c, Nom_conseiller__c, Tel_conseiller__c, LeadSource,
                      Email_conseiller__c, Company, SIRET__c, LastName, Email, MobilePhone, Note_Bale_II__c, Dirigeant_anciennete__c, Cotation_BdF__c
                      FROM Lead WHERE Company =: aLead.Company];
        
        system.assertEquals(0, leadFromDB.size());
        
        /** Vérification que le content document n'est pas ajouté **/
        contentVersionFromDB = [SELECT Id, Title, PathOnClient, VersionData, IsMajorVersion FROM ContentVersion WHERE Title = 'test1.pdf'];
        system.assertEquals(0, contentVersionFromDB.size());
        
        /** Vérification qu'il n'y a pas de redirection **/
        system.assertEquals(null, testSaveFile);
    }
}