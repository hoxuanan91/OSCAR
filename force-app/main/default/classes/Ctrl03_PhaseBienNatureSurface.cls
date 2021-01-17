public with sharing class Ctrl03_PhaseBienNatureSurface{

    public PhaseDeBien__c phaseDeBien { get; set; }
    public PageReference pageRef { get; set; }
    
    public Ctrl03_PhaseBienNatureSurface(ApexPages.StandardController controller) {
        phaseDeBien = [ SELECT ID, NS0SurfaceExistants__c, NS0SurfaceConsAvnt__c, NatureSurface1__c, NS1SurfaceExistants__c, NS1SdVExistants__c, NS1SurfaceConsAvnt__c, NS1SdVConsAvnt__c, 
                       				NatureSurface2__c, NS2SurfaceExistants__c, NS2SdVExistants__c, NS2SurfaceConsAvnt__c, NS2SdVConsAvnt__c,
                       				NatureSurface3__c, NS3SurfaceExistants__c, NS3SdVExistants__c, NS3SurfaceConsAvnt__c, NS3SdVConsAvnt__c,
                       				NatureSurface4__c, NS4SurfaceExistants__c, NS4SdVExistants__c, NS4SurfaceConsAvnt__c, NS4SdVConsAvnt__c,
                       				NatureSurface5__c, NS5SurfaceExistants__c, NS5SdVExistants__c, NS5SurfaceConsAvnt__c, NS5SdVConsAvnt__c,
                       				NatureSurface6__c, NS6SurfaceExistants__c, NS6SdVExistants__c, NS6SurfaceConsAvnt__c, NS6SdVConsAvnt__c,
                       				NatureSurface7__c, NS7SurfaceExistants__c, NS7SdVExistants__c, NS7SurfaceConsAvnt__c, NS7SdVConsAvnt__c,
                       				NatureSurface8__c, NS8SurfaceExistants__c, NS8SdVExistants__c, NS8SurfaceConsAvnt__c, NS8SdVConsAvnt__c,
                       				NatureSurface9__c, NS9SurfaceExistants__c, NS9SdVExistants__c, NS9SurfaceConsAvnt__c, NS9SdVConsAvnt__c,
                       				NatureSurface10__c, NS10SurfaceExistants__c, NS10SdVExistants__c, NS10SurfaceConsAvnt__c, NS10SdVConsAvnt__c,
                       				NatureSurface11__c, NS11SurfaceExistants__c, NS11SdVExistants__c, NS11SurfaceConsAvnt__c, NS11SdVConsAvnt__c,   
                       				NatureSurface12__c, NS12SurfaceExistants__c, NS12SdVExistants__c, NS12SurfaceConsAvnt__c, NS12SdVConsAvnt__c,
                       				NatureSurface13__c, NS13SurfaceExistants__c, NS13SdVExistants__c, NS13SurfaceConsAvnt__c, NS13SdVConsAvnt__c,
                       				NatureSurface14__c, NS14SurfaceExistants__c, NS14SdVExistants__c, NS14SurfaceConsAvnt__c, NS14SdVConsAvnt__c,
                       				NatureSurface15__c, NS15SurfaceExistants__c, NS15SdVExistants__c, NS15SurfaceConsAvnt__c, NS15SdVConsAvnt__c,
                       				TotalNS1__c, TotalNS2__c, TotalNS3__c, TotalNS4__c, TotalNS5__c, TotalNS0__c,TotalNS6__c, TotalNS7__c, TotalNS8__c, TotalNS9__c, TotalNS10__c, TotalNS11__c,TotalNS12__c, TotalNS13__c,TotalNS14__c, TotalNS15__c,
                       				TotalSdVNS1__c, TotalSdVNS2__c, TotalSdVNS3__c, TotalSdVNS4__c, TotalSdVNS5__c,TotalSdVNS6__c, TotalSdVNS7__c, TotalSdVNS8__c, TotalSdVNS9__c, TotalSdVNS10__c,TotalSdVNS11__c, TotalSdVNS12__c, TotalSdVNS13__c, TotalSdVNS14__c, TotalSdVNS15__c, TypeDeSurface1__c, TypeDeSurface2__c, TypeDeSurface3__c,
                       				SurfaceDemolition__c, SurfaceSdVDemolition__c, SurfaceDemolitionCol2__c, SurfaceSdVDemolitionCol2__c, TotalSurfaceDemolition__c, TotalSurfaceSdVDemolition__c, TotalDISurfaceExistants__c, TotalDISdVExistants__c, TotalDISurface__c, TotalDISdV__c,
                       				TotalHDSurfaceExistants__c, TotalHDSdVExistants__c, TotalHDSurfaceConsAvnt__c, TotalHDSdVConsAvnt__c, TotalSurfaceHD__c, TotalSurfaceSdVHD__c,
                       				Colonne1__c, Colonne2__c, RecordType.DeveloperName, Type__c, TotalDISurfaceConstruction__c, TotalDISdVConstruction__c
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