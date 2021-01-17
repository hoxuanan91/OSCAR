@isTest
(SeeAllData=true) 
private class PostChatterTest{

    public static Case getCase() {
        return [SELECT Id, Status, RecordTypeDeveloperName__c, CreatedBy.Profile.Name, CreatedById, ProjetAssocie__r.Owner.Profile.Name FROM Case LIMIT 1];
    }

    static testMethod void myTest() {
        Test.startTest();

        //System.assertEquals(Post_Chatter.PostChatterOpty('test Contrat','test','toto','8000J00000Anaaz'),null);
        Post_Chatter.PostChatterOpty('8000J00000Fnsc0');
        
	    Test.StopTest();
      }

    static testMethod void postChatterWhenCaseEqualTermine() {
        //ARR
        Case oldCase = [SELECT Id, Status, RecordTypeDeveloperName__c, CreatedBy.Profile.Name,
                        CreatedById, ProjetAssocie__r.Owner.Profile.Name
                        FROM Case WHERE CreatedBy.Profile.Name ='NX_Délégué Régional / Assistante CBM'
                        			AND Status = 'Terminée' AND RecordTypeDeveloperName__c='CBM_Valorisation' LIMIT 1];
        oldCase.EtatDeLaValorisation__c = '1';
        oldCase.AvisServiceValorisation__c = 'test avis service';

        //ACT
        Test.startTest();
        AP18Demande.postChatterWhenCaseEqualTermine(oldCase, oldCase);
        Test.stopTest();
    }
}