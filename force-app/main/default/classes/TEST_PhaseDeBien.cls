@isTest
public class TEST_PhaseDeBien {
    
    @testSetup 
    static void makeData(){
        
        Test.startTest();
        
        Bien_CBI__c lBienCBI;
        
        lBienCBI = new Bien_CBI__c(Name = 'Test Bien', UsageROE__c = 'Entrepôts');
        insert lBienCBI;
        
        // Phase de Bien existante
        PhaseDeBien__c lPhaseDeBienInitiale = new PhaseDeBien__c(NomDuBien__c = lBienCBI.Id, NatureSurface1__c = 'Nature 1', NS0SurfaceExistants__c = 100, NS0SurfaceConsAvnt__c = 100,
                                                         NS1SurfaceExistants__c = 200, NS1SurfaceConsAvnt__c = 200);
        insert lPhaseDeBienInitiale;
        
        Test.stopTest();
        
    }
    
    static testmethod void testCreerAvenant(){
        
        Bien_CBI__c lBienCBI = [SELECT Id FROM Bien_CBI__c WHERE Name = 'Test Bien' AND UsageROE__c = 'Entrepôts'];
        PhaseDeBien__c lPhaseDeBienInitiale = [SELECT Id, NatureSurface1__c FROM PhaseDeBien__c WHERE NomDuBien__c = :lBienCBI.Id AND NatureSurface1__c = 'Nature 1'];
        
        Test.startTest();
        PhaseDeBien__c lPhaseDeBien2 = new PhaseDeBien__c(NomDuBien__c = lBienCBI.Id);
        insert lPhaseDeBien2;
        
        PhaseDeBien__c lPhaseDeBien3 = new PhaseDeBien__c(NomDuBien__c = lBienCBI.Id);
        insert lPhaseDeBien3;
        
        
        // On récupère le Bien pour vérifier la der phase de Bien
        Bien_CBI__c lBienCBIAfterInsert = [SELECT Id, IDDernierePhaseDeBien__c FROM Bien_CBI__c WHERE Name = 'Test Bien' AND UsageROE__c = 'Entrepôts'];
        PhaseDeBien__c lPhaseDeBien3AfterInsert = [SELECT Id, Name FROM PhaseDeBien__c WHERE Id = :lPhaseDeBien3.Id];
        system.assertEquals(lPhaseDeBien3AfterInsert.Name, lBienCBIAfterInsert.IDDernierePhaseDeBien__c);
        
        update lPhaseDeBien3;
        
        delete lPhaseDeBien3;
        
        // On récupère la phase de bien créée
        PhaseDeBien__c lPhaseRecup = [SELECT Id, NatureSurface1__c, NS0SurfaceExistants__c, NS1SurfaceExistants__c FROM PhaseDeBien__c WHERE Id = :lPhaseDeBien2.Id];
        
        System.assertEquals(lPhaseDeBienInitiale.NatureSurface1__c, lPhaseRecup.NatureSurface1__c);

        
        Test.stopTest();
        
        
    }
}