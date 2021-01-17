public class Ctrl06_FinancementImmobilier {

    public NoteComite__c noteComite { get; set;}
    public PageReference pageRef { get; set; }
    
    public Ctrl06_FinancementImmobilier(ApexPages.StandardController controller) {
        
        noteComite = [SELECT Id, InvImmoEmploi1NC__c, InvImmoEmploi2NC__c, InvImmoEmploi3NC__c, MontantImmoEmploi1NC__c, MontantImmoEmploi2NC__c, MontantImmoEmploi3NC__c, MontantImmoRess1NC__c, MontantImmoRess2NC__c, MontantImmoRess3NC__c,
                        InvImmoRess1NC__c, InvImmoRess2NC__c, InvImmoRess3NC__c, CoutTerrainNC__c, CoutTerrainCBINC__c, CALC12NC__c, CoutAcquisitionNC__c, CoutConstructionTravauxNC__c, AvancePreneurNC__c,
                        MontantCCANC__c, CALC14NC__c, CALC15NC__c, CALC16NC__c, InvExplEmploi1NC__c, InvExplEmploi2NC__c, InvExplEmploi3NC__c,
                      	InvExplEmploi4NC__c, InvExplEmploi5NC__c, InvExplEmploi6NC__c, MontantExplEmploi1NC__c, MontantExplEmploi2NC__c, MontantExplEmploi3NC__c,
                        MontantExplEmploi4NC__c, MontantExplEmploi5NC__c, MontantExplEmploi6NC__c, FondsPropresExplNC__c, CCAExplNC__c, CBMExplNC__c, PretMLTExplNC__c,
                        PretCTEExplNC__c, EmpruntObligatoireExplNC__c, CALC17NC__c, CALC18NC__c, CALC19NC__c, CALC20NC__c, CALC21NC__c, CALC22NC__c
                        FROM NoteComite__c WHERE Id =:ApexPages.currentPage().getParameters().get('ID') LIMIT 1];
        pageRef = ApexPages.currentPage();
    }
    
    public Ctrl06_FinancementImmobilier() {
        
    }
    public PageReference save(){
		
        update noteComite;
		pageRef.setRedirect(true);          
		return pageRef;
		return null;
    }
}