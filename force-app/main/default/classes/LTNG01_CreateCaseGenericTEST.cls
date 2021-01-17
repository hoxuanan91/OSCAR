@IsTest
private class LTNG01_CreateCaseGenericTEST {
    @testSetup
    static void initData() {
        Contact ctc = TestFactory.createContact('testFisrtName','testLastName','CBM Groupe Post Réal A', 'CBM Groupe Réalisation A3');
        insert ctc;
		
        Account acc = TestFactory.createAccount('testAccountName');
        acc.Apporteur__c =null;
        insert acc;

        Account accAutretiers = TestFactory.createAccount('peugeot');
        insert accAutretiers;

        Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
        insert opp;

        Contract ctr = TestFactory.createContract(acc.Id, opp.Id);
        insert ctr;

        Autre_Tiers__c autreTiers = TestFactory.createAutreTiers(accAutretiers.Id, ctr.Id, '001');
        insert autreTiers;

        Bien__c bien = TestFactory.createBien(ctr.Id, 'GRUE LIEBHERR TORENKRAAN TYPE 280', 'TEST-7357-TT');
        insert bien;
    }

    static Contract getContract() {
        return [SELECT Id FROM Contract LIMIT 1];
    }

    static Opportunity getOpportunity() {
        return [SELECT Id FROM Opportunity LIMIT 1];
    }

    @IsTest
    static void whenClickOnButtonCreationDemandeFromContract() {
        //ARR
        Contract ctr = getContract();
        //ACT
        LTNG01_CreateCaseGeneric.RecordFormWrapper recordForm = LTNG01_CreateCaseGeneric.initRecordForm(ctr.Id, 'Contract');
        //ASS
        System.assertNotEquals(null, recordForm);
    }

    @IsTest
    static void whenClickOnButtonCreationDemandeFromOpportunity() {
        //ARR
        Opportunity opp = getOpportunity();

        //ACT
        LTNG01_CreateCaseGeneric.RecordFormWrapper recordForm = LTNG01_CreateCaseGeneric.initRecordForm(opp.Id, 'Opportunity');

        //ASS
        System.assertNotEquals(null, recordForm);
    }
    
    @IsTest
    static void whenSaveDemandeTransfertFromContract() {
        //ARR
        Contract ctr = getContract();
        
        //ACT
        LTNG01_CreateCaseGeneric.RecordFormWrapper recordForm = LTNG01_CreateCaseGeneric.initRecordForm(ctr.Id, 'Contract');
        LTNG01_CreateCaseGeneric.saveCaseGeneric(JSON.serialize(recordForm), 'CBM_Transfert'); 
        
        //ASS
        System.assertEquals(1, [SELECT Id FROM Case WHERE ProjetAssocie__c =: recordForm.oppId].size());
    }
    
      @IsTest
    static void whenSaveDemandeTransfertPilotFromContract() {
        //ARR
        Contract ctr = getContract();
        
        //ACT
        LTNG01_CreateCaseGeneric.RecordFormWrapper recordForm = LTNG01_CreateCaseGeneric.initRecordForm(ctr.Id, 'Contract');
        recordForm.typeTransfert.value='Nouveau locataire';
        LTNG01_CreateCaseGeneric.saveCaseGeneric(JSON.serialize(recordForm), 'CBM_Transfert_Pilote_DCR3'); 
        
        //ASS
        System.assertEquals(1, [SELECT Id FROM Case WHERE ProjetAssocie__c =: recordForm.oppId].size());
    }

    @IsTest
    static void whenSaveDemandeValorisationFromContract() {
        //ARR
        Contract ctr = getContract();

        //ACT
        LTNG01_CreateCaseGeneric.RecordFormWrapper recordForm = LTNG01_CreateCaseGeneric.initRecordForm(ctr.Id, 'Contract');
        LTNG01_CreateCaseGeneric.saveCaseGeneric(JSON.serialize(recordForm), 'CBM_Valorisation');

        //ASS
        System.assertEquals(1, [SELECT Id FROM Case WHERE ProjetAssocie__c =: recordForm.oppId].size());
    }

    @IsTest
    static void whenSaveDemandeValorisationFromOpportunityWithContract() {
        //ARR
        Opportunity opp = getOpportunity();

        //ACT
        LTNG01_CreateCaseGeneric.RecordFormWrapper recordForm = LTNG01_CreateCaseGeneric.initRecordForm(opp.Id, 'Opportunity');
        LTNG01_CreateCaseGeneric.saveCaseGeneric(JSON.serialize(recordForm), 'CBM_Valorisation');

        //ASS
        System.assertEquals(1, [SELECT Id FROM Case WHERE ProjetAssocie__c =: recordForm.oppId].size());
    }
    
    @IsTest
    static void whenSaveDemandeValorisationFromOpportunityWithoutContract() {
        //ARR
        Opportunity opp = getOpportunity();
        Contract ctr = getContract();
        
        ctr.ProjetAssocie__c = null;
        update ctr;
        
        //ACT
        LTNG01_CreateCaseGeneric.RecordFormWrapper recordForm = LTNG01_CreateCaseGeneric.initRecordForm(opp.Id, 'Opportunity');
        LTNG01_CreateCaseGeneric.saveCaseGeneric(JSON.serialize(recordForm), 'CBM_Valorisation');

        //ASS
        System.assertEquals(1, [SELECT Id FROM Case WHERE ProjetAssocie__c =: recordForm.oppId].size());
    }
}