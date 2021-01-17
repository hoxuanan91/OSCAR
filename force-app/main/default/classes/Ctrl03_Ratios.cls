public class Ctrl03_Ratios {

    public PhaseDeBien__c phaseDeBien { get; set; }
    
    public Ctrl03_Ratios(ApexPages.StandardController controller){
        
        phaseDeBien = [ SELECT ID, TypeDeSurface1__c, CALC37NC__c, CALC38NC__c, CALC39NC__c, CALC40NC__c,
                         CALC37BISNC__c, CALC38BISNC__c, CALC39BISNC__c, CALC40BISNC__c,
                         CALC37TERNC__c, CALC38TERNC__c, CALC39TERNC__c, CALC40TERNC__c, Type__c,
                         CALC37SdVNC__c, CALC38SdVNC__c, CALC39SdVNC__c, CALC40SdVNC__c,
                         CALC37BISSdVNC__c, CALC38BISSdVNC__c, CALC39BISSdVNC__c, CALC40BISSdVNC__c,
                         CALC37TERSdVNC__c, CALC38TERSdVNC__c, CALC39TERSdVNC__c, CALC40TERSdVNC__c, Colonne1__c, Colonne2__c
      					 FROM PhaseDeBien__c
      					 WHERE PhaseDeBien__c.ID =:ApexPages.currentPage().getParameters().get('ID')]; 
    }
}