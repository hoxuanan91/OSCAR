public class Ctrl03_PhaseBienPrixRevient {

    public PhaseDeBien__c phaseDeBien { get; set; }
    public PageReference pageRef { get; set; }
    
    public Ctrl03_PhaseBienPrixRevient(ApexPages.StandardController controller) {
        phaseDeBien = [ SELECT ID, Name, MontantTerrainExistants__c, MontantTerrainConsAvt__c, TotalPrixFoncier__c, MontantAutresExistants__c, MontantAutresConsAvt__c, TotalMontantAutre__c,
                                    TotalCoutFoncierExistants__c, TotalCoutFoncierConsAvt__c, TotalCoutFoncier__c, FraisDemolition__c, MontantAcquisitionExistants__c, MontantAcquisitionConsAvt__c, TotalMontantAcquisition__c, FraisAcquisitionExistants__c,
                       				FraisAcquisitionConsAvt__c, TotalFraisAcquisition__c, TotalCoutAcquisitionExistants__c, TotalCoutAcquisitionConsAvt__c, TotalCoutAcquisition__c,
                       				CoutVRDConsAvt__c, CoutTravauxConsAvt__c, CoutHonorairesConsAvt__c, CoutAssurancesConsAvt__c, CoutDiversImprevusConsAvt__c, CoutLibreConsAvt__c, CoutAutresConsAvt__c, TotalCoutConstructionConsAvt__c,
                       				Colonne1__c, Colonne2__c, NomCoutLibre__c, EncoursNetDuBien__c, TotalConsAvt__c, TotalEncoursEntBien__c, FraisDemolitionCol1__c, VRDCol1__c, TravauxCol1__c, HonorairesCol1__c, AssurancesCol1__c, DiversImprevusCol1__c,
                       				CoutLibre1__c, AutresCol1__c, TotalCoutConstructionCol1__c, TotalExistants__c, Total__c,
                       				TotalFraisDemolition__c, SubventionCol1__c, SubventionCol2__c, SubventionTotal__c,
                       				AvancePreneurCol1__c, AvancePreneurCol2__c, AvancePreneurTotal__c,
                       				TotalVRD__c, TotalTravaux__c, TotalHonoraires__c, TotalAssurances__c,
                       				TotalDiversImprevus__c, TotalCoutLibre__c, TotalAutres__c, TotalCoutConstruction__c
      					 FROM PhaseDeBien__c
      					 WHERE PhaseDeBien__c.ID =:ApexPages.currentPage().getParameters().get('ID')]; 
        pageRef = ApexPages.currentPage();
        
    }  
    
    public PageReference save(){

        update phaseDeBien;
		pageRef.setRedirect(true);          
		return pageRef;

    }
    
   
}