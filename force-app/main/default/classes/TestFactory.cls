@isTest
public class TestFactory {

    //Contact
    public static Contact createContact(String fname, String lname, String groupePostReal, String groupeReal) {
        Contact cont = new Contact();
        cont.FirstName = fname;
        cont.LastName = lname;
        cont.Groupe_Post_Real__c = groupePostReal;
        cont.Groupe_Real__c = groupeReal;
        
        return cont;
    }
    
    //OpportunityContactRole
    public static OpportunityContactRole createOpportunityContactRole(Id ctcId, Id oppId) {
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = ctcId;
        ocr.OpportunityId = oppId;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        
        return ocr;
    }
    
    //Contact
    public static Contact createContact(String fname, String lname, String email) {
        Contact cont = new Contact();
        cont.FirstName = fname;
        cont.LastName = lname;
        cont.email = email;
        
        return cont;
    }
    
    //Account
    public static Account createAccount(String name) {
        Account acc = new Account();
        acc.Email__c = 'test@test.com';
        acc.Name = name;
        
        return acc;
    }
    
    //Opportunity
    public static Opportunity createOpty(String name) {
        Opportunity Opty = new Opportunity();
        Opty.Name = name;
        
        return Opty;
    }

    //Opportunity
    public static Opportunity createOppWithRecordType(String name, String recordTypeId, String stageName, String accountId) {
        Opportunity opp = new Opportunity();
        opp.Name = name;
        opp.RecordTypeId = recordTypeId;
        opp.CloseDate = System.today().addDays(10);
        opp.StageName = stageName;
        opp.AccountId = accountId;
        
        return opp;
    }

    //Opportunity
    public static Opportunity createOpty(String name, Id accountId) {
        Opportunity opp = new Opportunity();

        opp.Name = name;
        opp.ReseauApporteur1__c = accountId;
        opp.Montant1erLoyer__c = 1234;
        opp.StageName = 'AT_LIV';
        opp.CloseDate = Date.today().addDays(5);

        return opp;
    }

    //Contrat_ProjetAssocie__c
    public static Contrat_ProjetAssocie__c createContratPAS(String oppId, String contractId){
        Contrat_ProjetAssocie__c cPas = new Contrat_ProjetAssocie__c();

        cPas.ProjetAssocie__c = oppId;
        cPas.Contrat__c = contractId;

        return cPas;

    }
    
    //Projet__c
    public static Projet__c createProjet(String name) {
        Projet__c Projet = new Projet__c();
        Projet.Name = name;
        
        return Projet;
    }    
    
    //Reference_GED__mdt
    public static Reference_GED__mdt createRefGED() {
        Reference_GED__mdt RefGED = new Reference_GED__mdt();
        
        return RefGED;
    }

    //EmailTemplate
    public static EmailTemplate createEmailTemplate(String devName){
        EmailTemplate eT = new EmailTemplate();

        eT.isActive = true;
        eT.Name = 'name';
        eT.DeveloperName = devName;
        eT.TemplateType = 'text';
        eT.Subject = 'Test';
        eT.FolderId = UserInfo.getUserId();

        return eT;
    }
    
    //MonExpertDependantValues__c
    public static MonExpertDependantValues__c createMonExpertDependatCS(){
        MonExpertDependantValues__c medv = new MonExpertDependantValues__c();
        
        medv.Name = 'Propostion - Retour client';
        medv.OpportunityEnAttente__c = 'Retour client';
        medv.OpportunityStage__c = 'Proposition';
        
        return medv;
    }
    
    //Contract
    public static Contract createContract(Id accountId, String type){
        Contract ctr = new Contract();
        ctr.RecordTypeId = UTL_Utils.getRecordTypeID(String.valueOf(Contract.getSObjectType()), 'CBIDossier');
        ctr.AccountId = accountId;
        ctr.Name      = '000001/00';
        ctr.SocieteDeGestion__c = 'Test Société';
        ctr.Nom_du_dossier__c = 'Test Dossier';
        ctr.COVID_19_Hotel_Restaurant__c = true;
        ctr.COVID19__c = 'O';
        ctr.Type_de_pool__c = type;
        ctr.DateFin__c = System.today();

        return ctr;
    }

    //Contract
    public static Contract createContract(Id accountId, Id oppId){
        Contract ctr = new Contract();

        ctr.AccountId = accountId;
        ctr.ProjetAssocie__c = oppId;
        ctr.BusinessUnit__c = '5';   // 5 - BU GC

        return ctr;
    }

    //Contract
    public static Contract createContractWithRecordType(Id accountId, Id oppId, String recordTypeId){
        Contract ctr = new Contract();

        ctr.AccountId = accountId;
        ctr.ProjetAssocie__c = oppId;
        ctr.BusinessUnit__c = '5';   // 5 - BU GC
        ctr.RecordTypeId = recordTypeId;   // 5 - BU GC

        return ctr;
    }
    
    //Contract
    public static Contract createContract(String accountId,Contact contact){    
        Contract ctr = new Contract();

        ctr.AccountId = accountId;
        ctr.Intervenant_commercial__c = contact.Id;
        ctr.BusinessUnit__c = '5';   // 5 - BU GC
        
        return ctr;
    }
    
    //Contract
    public static Contract createContract(String accountId){    
        Contract ctr = new Contract();

        ctr.AccountId = accountId;
        ctr.BusinessUnit__c = '5';   // 5 - BU GC
        
        return ctr;
    }

    //Autre_Tiers__c
    public static Autre_Tiers__c createAutreTiers(Id accountId, Id contractId, String name) {
        Autre_Tiers__c autreTiers = new Autre_Tiers__c();

        autreTiers.Numero_du_dossier__c = contractId;
        autreTiers.Nom_du_Tiers__c = accountId;
        autreTiers.Role__c = 'Fournisseur';
        autreTiers.Name = name;

        return autreTiers;
    }

    //Bien__c
    public static Bien__c createBien(Id contractId, String name, String immatriculation) {
        Bien__c bien = new Bien__c();

        bien.Dossier__c = contractId;
        bien.Name = name;
        bien.Immatriculation__c = immatriculation;

        return bien;
    }
    
    //Case
    public static Case createCase(String contractId, String status){    
        Case c = new Case();

        c.status = status;
        c.Dossier1__c = contractId;
        c.Information_sur_le_dossier__c = 'test';
        c.Information_sur_tiers_concerne__c = 'test'; 
        c.Delegation_Regionale__c = 'test'; 
        c.Service_concerne__c = 'test';
        
        return c;
    }
    
    //Case
    public static Case createCaseWithAccount(String accId, String status){    
        Case c = new Case();

        c.status = status;
        c.AccountId = accId;
        c.Information_sur_le_dossier__c = 'test';
        c.Information_sur_tiers_concerne__c = 'test'; 
        c.Delegation_Regionale__c = 'test'; 
        c.Service_concerne__c = 'test';
        
        return c;
    }
    
    //Case
    public static Case createCaseWithRT(String contractId, String status, String RT){
        Case c = new Case();
        c.status = status;
        c.Dossier1__c = contractId;
        c.Information_sur_le_dossier__c = 'test';
        c.Information_sur_tiers_concerne__c = 'test'; 
        c.Delegation_Regionale__c = 'test'; 
        c.Service_concerne__c = 'test';
        c.recordTypeId = RT;
        return c;
    }

	//List<Case>   
    public static List<Case> createCaseWithRTBulk(Integer i, String contractId, String status, String recordType, boolean reac){    

        List<Case> cases = new List<Case>();
        
        for(Integer j = 1; j <= i ; j++){
            Case c = new Case();
            c.status = status;
            c.Dossier1__c = contractId;
            c.Information_sur_le_dossier__c = 'test' + i;
            c.Information_sur_tiers_concerne__c = 'test' + i; 
            c.Delegation_Regionale__c = 'test' + i; 
            c.Service_concerne__c = 'test' + i;
            c.recordTypeId = recordType;
            c.ReaC__c = reac;
            cases.add(c);
        }
        
        System.debug(cases);
        
        return cases;
    }
    
    //List<Facture_non_lettree__c>
    public static List<Facture_non_lettree__c> createFactureBulk(List<Case> cases, String contractId){
        
        List<Facture_non_lettree__c> factures = new List<Facture_non_lettree__c>();
        
        for(Case c : cases){
           Facture_non_lettree__c f1 = new Facture_non_lettree__c();
           f1.Demande_rattachee__c = c.Id;
           f1.Date_INSERT__c = date.newInstance(2015, 04, 1);
           f1.Date_UPDATE__c = date.newInstance(2015, 04, 5);
           f1.Date_MAJ_ksiop__c =  date.newInstance(2015, 04, 4);
           f1.Date_de_reglement__c =  null;
           f1.N_Dossier__c = contractId;
        
           factures.add(f1);
        }
        
        return factures;
    }
    
	//Facture_non_lettree__c
    public static Facture_non_lettree__c createFacture(String caseId){
        Facture_non_lettree__c f1 = new Facture_non_lettree__c();
        f1.Demande_rattachee__c = caseId;
        
        return f1;
    }
    
    //User
    public static User createUser(){
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'admin', email='admin@bpce.fr',
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                        localesidkey='fr', profileid = p.Id,
                        timezonesidkey='GMT', username='admin_test@bpce.fr',
                        UserByPassValidationRules__c = true,
                        UserByPassProcess__c = true,
                        UserByPassTriggers__c = 'TR001ManageCase_DisableDeleteCase',
                        city='Paris');
                        
        return u;
    }
    
    @future
    public static void createFutureUser(String fName, String lName){
        Profile p = [select id, name from profile where name='System Administrator'];
        system.debug('@@TOTO: ' + p.Name);
        system.debug('@@TOTO: ' + p.id);
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(firstname = fName,
                              lastName = lName,
                              email = uniqueName + '@test' + orgId + '.bpce.fr',
                              Username = uniqueName + '@test' + orgId + '.bpce.fr',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = p.Id,
                              UserByPassValidationRules__c = true,
                              UserByPassProcess__c = true,
                              UserByPassTriggers__c = 'TR001ManageCase_DisableDeleteCase',
                              UniteSRC__c='2');
        insert tuser;
        
        UserRole ur1 = new UserRole(Name = 'Finance Approver', DeveloperName='CBMSSRC');
        insert ur1;
    }
    @future
    public static void testonsensemble(Id uroleId) {
        User usr = [SELECT Id FROM User LIMIT 1][0];
        usr.UserRoleId = uroleId;
        update usr;
    }
    

    public static User createUserWithProfile(Integer i , String profilFr, String profilEng){
        Profile p = [select id from profile where name= :profilFr OR name = :profilEng]; 
        User u = new User(alias = 'admin', email='admin' + i + '@bpce.fr',
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                        localesidkey='fr', profileid = p.Id,
                        timezonesidkey='GMT', username='admin_test' + i + '@oscar_bpce.fr',
                        UserByPassValidationRules__c = true,
                        UserByPassProcess__c = true,
                          city='Paris');
        
        if('System Administrator'.equals(profilEng))
            u.UserByPassTriggers__c = 'TR001ManageCase_DisableDeleteCase';
        
        return u;
    }
    
    public static User createUser(String groupeAppartenance, Boolean active){
        //comm
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'testAff', email='testAffectation@bpce.fr',
                        emailencodingkey='UTF-8', lastname='testAffectation', languagelocalekey='fr',
                        localesidkey='fr', profileid = p.Id,
                        timezonesidkey='GMT', username='testAffectation@oscar_bpce.fr',
                           city='Paris',
                        UniteSRC__c='5',   // 5 - CBM SRC Service 
                        UserByPassValidationRules__c = true, 
                        UserByPassProcess__c = true,
                        Groupe_d_appartenance__c = groupeAppartenance, isActive = active);
                        
        return u;
    } 

    // Capgemini - Radoica Jankovic - 12/03/2018
    public static User createUserByPassProcess(){
        Profile p = [select id from profile where name='System Administrator']; 
        User u = new User(alias = 'admin', email='admin@bpce.fr',
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                        localesidkey='fr', profileid = p.Id,
                        timezonesidkey='GMT', username='admin_test@oscar_bpce.fr',
                        UserByPassValidationRules__c = true, 
                        UserByPassProcess__c = true,
                        UserByPassTriggers__c = 'TR001ManageCase_DisableDeleteCase',
                        city='Paris');
                        
        return u;
    }



    
    public static List<Group> createQueues(){
        
        List<Group> queues = new List<Group>();
        queues.add(new Group(DeveloperName='CBM_Service_Post_Realisation', Name='Post_Realisation'));
        queues.add(new Group(DeveloperName='CBM_Service_Realisation', Name='Realisation'));
        
        // Cap Gemini - JR - 05/12/17 - La File d'Attente CBM Service Recouvrement (CBM_Service_Recouvrement) a été renomée en Service Recouvrement (Service_Recouvrement)
        queues.add(new Group(DeveloperName='Service_Recouvrement', Name='Recouvrement'));
        
        queues.add(new Group(DeveloperName='CBM_Service_Transverse', Name='Transverse'));
        queues.add(new Group(DeveloperName='Direction_Gestion_CBM', Name='Gestion_CBM'));
        queues.add(new Group(DeveloperName='CBM_Groupe_Post_Real_A', Name='A'));
        queues.add(new Group(DeveloperName='CBM_Groupe_Post_Real_B', Name='B'));
        queues.add(new Group(DeveloperName='CBM_Groupe_Post_Real_C', Name='C'));
        queues.add(new Group(DeveloperName='CBM_Groupe_Realisation_A3', Name='A3'));
        queues.add(new Group(DeveloperName='CBM_Groupe_Realisation_A4', Name='A4'));
        queues.add(new Group(DeveloperName='CBM_Groupe_Realisation_A5', Name='A5'));
        queues.add(new Group(DeveloperName='CBM_Groupe_Realisation_C6', Name='C6'));
        queues.add(new Group(DeveloperName='CBM_Groupe_Realisation_C7', Name='C7'));
        
        return queues;
    }
    
    public static Lead createLeadLLD(String name) {
        Id recordTypeId = [SELECT Id FROM Recordtype WHERE DeveloperName LIKE '%lld%' AND SObjectType = 'Lead' LIMIT 1][0].Id;
        
        Lead ld = new Lead(
            Company = name,
        	Etablissement__c = 'BP MED',
        	RecordTypeId = recordTypeId);
        
        return ld;
    }
    
    public static UserRole createUserRole() {
        UserRole ur = new UserRole(name='CBM SRC Test');
        
        return ur;
    }
    
    public static Vehicule__c createVehicule(String dosId, String accId){
        Vehicule__c v = new Vehicule__c();
        
        v.Name = 'Test véhicule';
        v.Dossier__c = dosId;
        v.Tiers__c = accId;
        
        return v;
    }
    
    public static Facture_non_lettree__c createFactureNL(String caseId){
        Facture_non_lettree__c fml = new Facture_non_lettree__c();
        
        fml.Name = 'Test';
        fml.Demande_rattachee__c = caseId;
               
        return fml;
    }
    
    public static Contrat_facture__c createContratFacture(String contId, String caseId, String vId){
        Contrat_facture__c cF = new Contrat_facture__c();
        
        cF.Contrat__c = contId;
        cF.Demande__c = caseId;
        cF.Vehicule__c = vId;
        
        return cF;
    }
}