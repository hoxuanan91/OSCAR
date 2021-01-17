public with sharing class Ctrl04_VFPTaux  {
    public Map<String ,Double> MapTauxCMS {get;set;}
      public Map<Integer ,Double> MapTauxFixe {get;set;}
     public Map<Integer ,Double> MapTauxVariable {get;set;}
    public Map<String, Integer> listSizeMap {get;set;}
    public List<SelectOption> SemaineConstation  {get;set;}
    public String ListValueSemaineConstation {get;
                                          set {
            									ListValueSemaineConstation = value; 
        									}
                                         }
    public Double Euribor3mois {get;set;}
    
    public String ValueSemaineConstation {get;set;}
    public Ctrl04_VFPTaux(ApexPages.StandardController stdController) {   
   		
        MapTauxCMS  = new Map<String ,Double>(); 
        MapTauxFixe = new Map<Integer ,Double>() ;
        MapTauxVariable= new Map<Integer ,Double>() ;
        
        
        SemaineConstation  = new List<SelectOption>();  
        SemaineConstation = Ctrl01_CalculetteROE.VFPGetSemaineConstatation(); 
        ValueSemaineConstation = ApexPages.currentPage().getParameters().get('ValueSemaineConstation');
        ListValueSemaineConstation = ValueSemaineConstation ;
      
        if(ValueSemaineConstation == null){           
            ValueSemaineConstation = SemaineConstation.get(0).getLabel() + '';
            ApexPages.currentPage().getParameters().put('ValueSemaineConstation',ValueSemaineConstation);   
        }
 		 	MapTauxCMS = Ctrl01_CalculetteROE.VFPGetTauxCMSConstation(ValueSemaineConstation);
            MapTauxFixe= Ctrl01_CalculetteROE.VFPGetTauxFixe(ValueSemaineConstation);
            MapTauxVariable= Ctrl01_CalculetteROE.VFPGetTauxVariable(ValueSemaineConstation);
            Euribor3mois = Ctrl01_CalculetteROE.getTxEuribor(ValueSemaineConstation);       
  			System.debug('MapTauxVariable size' + MapTauxVariable.size() + 'MapTauxFixe size' + MapTauxFixe.size() );
    }
      public PageReference SearchAtSemaineConstation(){ 
       PageReference pageRef = Page.VFP04_Taux; 
       pageRef.getParameters().put('id',ApexPages.currentPage().getParameters().get('id')); 
       pageRef.getParameters().put('ValueSemaineConstation',ListValueSemaineConstation); 
  	    return PageRef.setRedirect(True);
  	    //return null;
    }  
    
     
   
    
}