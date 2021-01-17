@IsTest
private class LTNG02_ForcerLesRejetsTEST {

    @testSetup
    static void initData() {
        Contact ctc = TestFactory.createContact('testFisrtName','testLastName','CBM Groupe Post Réal A', 'CBM Groupe Réalisation A3');
        insert ctc;

        Account acc = TestFactory.createAccount('testAccountName');
        insert acc;

        Account accAutretiers = TestFactory.createAccount('peugeot');
        insert accAutretiers;

        Opportunity opp = TestFactory.createOpty('testOpportName', acc.Id);
        insert opp;

        Contract ctr = TestFactory.createContract(acc.Id, opp.Id);
        insert ctr;

     	String intitule = '';
        
        ControleMetier__c ctm = new ControleMetier__c();
        ctm.Forcage__c = false;
        ctm.IntituleControle__c = 'test controle';
        ctm.TypeDocument__c ='2';
        intitule = intitule + '/' + ctm.IntituleControle__c;
        ctm.Statut__c = '3';
        ctm.Bloquant__c = '1';
        ctm.NatureEnvoi__c ='2';
        ctm.ProjetAssocie__c = opp.id;
        ctm.ProjetAssocieVisuRejet__c = opp.Id;
        ctm.CreatedDate = Date.newInstance(2018,11,06);
        insert ctm;
        
        opp.Docko1__c = ' * Conditions particulières du contrat CBM    ' +' ' + ':' +' ' + intitule;
        opp.NbEnvoisDocaPost1Statut__c = 900001;
        opp.NbEnvoisDocaPost2Statut__c = 900001;
        update opp;
    }
    
    @IsTest
    static void whenEnvoiNatureEnvoiForceHasEnvoiDocapost1() {
        //ARR
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1][0];
        //ACT
        LTNG02_ForcerLesRejets.RecordForm result = LTNG02_ForcerLesRejets.getRejetsEnCours(opp.Id);
        //ASS
        System.assertEquals(1, result.natureDeLenvoiForce.size());
        System.assertEquals('2', result.natureDeLenvoiForce[0].value);
    }
    
    @IsTest
    static void whenEnvoiNatureEnvoiForceHasEnvoiDocapost2() {
        //ARR
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1][0];
        ControleMetier__c ctrlMetier = [SELECT Id, NatureEnvoi__c FROM ControleMetier__c];
        ctrlMetier.NatureEnvoi__c = '3';
        update ctrlMetier;
        //ACT
        LTNG02_ForcerLesRejets.RecordForm result = LTNG02_ForcerLesRejets.getRejetsEnCours(opp.Id);
        //ASS
        System.assertEquals(1, result.natureDeLenvoiForce.size());
        System.assertEquals('3', result.natureDeLenvoiForce[0].value);
    }
    
    @IsTest
    static void whenEnvoiNatureEnvoiForceHasEnvoiDocapost1AndEnvoiDocapost2() {
        //ARR
        String intitule = '';
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1][0];
        ControleMetier__c ctm = new ControleMetier__c();
        ctm.Forcage__c = false;
        ctm.IntituleControle__c = 'test controle';
        ctm.TypeDocument__c ='2';
        intitule = intitule + '/' + ctm.IntituleControle__c;
        ctm.Statut__c = '3';
        ctm.Bloquant__c = '1';
        ctm.NatureEnvoi__c ='3';
        ctm.ProjetAssocie__c = opp.id;
        ctm.ProjetAssocieVisuRejet__c = opp.Id;
        ctm.CreatedDate = Date.newInstance(2018,11,06);
        insert ctm;
        //ACT
        LTNG02_ForcerLesRejets.RecordForm result = LTNG02_ForcerLesRejets.getRejetsEnCours(opp.Id);
        //ASS
        System.assertEquals(2, result.natureDeLenvoiForce.size());
        System.assertEquals('2', result.natureDeLenvoiForce[0].value);
        System.assertEquals('3', result.natureDeLenvoiForce[1].value);
    }
    
    @IsTest
    static void forcerLesRejetsTest() {
        //ARR
        Opportunity opp = [SELECT Id, ForcageControlesMetiers__c, NbEnvoisDocaPost1Statut__c, NbEnvoisDocaPost2Statut__c, RecordType.DeveloperName FROM Opportunity LIMIT 1][0];
        
        LTNG02_ForcerLesRejets.ResultForm result = new LTNG02_ForcerLesRejets.ResultForm('testMotifForcage', '2');
        //ACT
        LTNG02_ForcerLesRejets.forcerLesRejets(opp.Id, JSON.serialize(result));
        //ASS
        System.assert(true, [SELECT Id, ForcageControlesMetiers__c FROM Opportunity LIMIT 1][0].ForcageControlesMetiers__c);
    }
}