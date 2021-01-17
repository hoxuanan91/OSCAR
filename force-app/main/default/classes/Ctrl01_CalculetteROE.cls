public with sharing class Ctrl01_CalculetteROE {
  public CalculetteROE__c currentCalc {get;set;} 
   
 public Ctrl01_CalculetteROE(ApexPages.StandardController stdController) {  

       currentCalc = [ SELECT ID, EncoursMoyenOperationDuree__c, MargeBruteFinanciereActualisee__c, CommissionApportFlatNegatif__c,
                                                     CoutsDexploitationActualises__c, PNBAdditionnel__c,ProjetAssocie__c, FraisDeDossier__c, CommissionDeRisqueActualiseeBPCE__c,
                     CoutsDexploitationActualisesIRBA__c,FraisDeDossierPerc__c, PNBStandard__c, ResultatCourantAvantImpotStandard__c, ResultatCourantAvantImpotIRBA__c,  MargeNetteStandard__c,
                     ProbabiliteDeDefaut__c,CommissionDeRisqueActualisBPCEPerc__c, CommissionApportFlatPerc__c, MargeBruteFinanciereActualiseePerc__c,
                     CoutsDexploitationActualisesIRBAPerc__c, CoutsDexploitationActualisesSTDPerc__c, PNBIRBAPerc__c,PNBIRBA__c , PNBStandardPerc__c, ExpectedLossPerc__c, LGD__c,
                     RWAMoyen__c, ExpectedLoss__c, RemunerationDesFPN__c, MargeNetteIRBA__c, ROEMAimpotIRBA__c, BesoinsFPMoyenIRBA__c, ROEMApresimpotIRBA__c, RWAMoyenStandard__c,BesoinsFPmoyenSTD__c,
                     ROEMoyenAvantImpotStd__c, ROEmoyenApresImpotStandard__c, PNBAdditionnelperc__c, RemunrationDesFPNPerc__c, BesoinsFPMoyenIRBABPCE__c, RWAMoyenBPCE__c, ROEMoyenApresImpotIRBABPCE__c, ROEMoyenAvantImpotIRBABPCE__c
      FROM CalculetteROE__c
      WHERE CalculetteROE__c.ID =:ApexPages.currentPage().getParameters().get('ID')];
     

     
 }
  public Ctrl01_CalculetteROE(){
 
  }
      //Modif ICD2384114 : prend dernière ligne modifiée
      public static  List<Double> getCoutExploitationCoutCTTauxISScalingFactor() {
          List<Double> CoutExploitationCoutCTTauxISScalingFactor = new List<Double>();
             Double Marge = 0 ;
             Double Charges = 0;
             Double CoutExploitation = 0;
          
          for(BddRoe__c ItemReqCurrentBddRoe: [ Select Coutexploitation__c,CoutRefinancementCT__c,Taux_IS__c,ScalingFactor__c,MargeBancaire__c, Charges__c
                                               FROM BddRoe__c
                                               where Coutexploitation__c != null
                                               and CoutRefinancementCT__c != null
                                               and Taux_IS__c!= null
                                               and ScalingFactor__c != null
                                               ORDER BY CreatedDate DESC
                                               LIMIT 1
                                             ]){ 
           Marge =  ItemReqCurrentBddRoe.MargeBancaire__c  ;
           Charges =  ItemReqCurrentBddRoe.Charges__c  ; 
           CoutExploitation = Charges/Marge;        
                                                 
           CoutExploitationCoutCTTauxISScalingFactor.add(CoutExploitation*100);
           CoutExploitationCoutCTTauxISScalingFactor.add(ItemReqCurrentBddRoe.CoutRefinancementCT__c); 
           CoutExploitationCoutCTTauxISScalingFactor.add(ItemReqCurrentBddRoe.Taux_IS__c);
           CoutExploitationCoutCTTauxISScalingFactor.add(ItemReqCurrentBddRoe.ScalingFactor__c);
                } 
        return   CoutExploitationCoutCTTauxISScalingFactor;   
          
	  }
	  
     public static list<Double> setCoutExploitation(Double TauxCoutExploitation, Double ResultMargeActualiseeTotal){ 
		list<Double> CalcCoutExploitation = new List<Double>();
		Double Marge = 0;
		Double Charges = 0;
		Double CoutExploitation = 0;
				
		CalcCoutExploitation.add(-ResultMargeActualiseeTotal * (TauxCoutExploitation / 100));
		CalcCoutExploitation.add(-ResultMargeActualiseeTotal * (TauxCoutExploitation / 100));
			
		return CalcCoutExploitation;
	}

    
    public static Double getTxEuribor(List<BddRoe__c> bdds) {
        Double TxEuribor = 0;
      
        for(BddRoe__c ItemReqCurrentBddRoe : bdds){
			if(ItemReqCurrentBddRoe.Euribor3mois__c != null){
				TxEuribor = ItemReqCurrentBddRoe.Euribor3mois__c;
			}
		}
		
        return TxEuribor;
	}
	
    public static Double getTauxRefi(Double TxEuribor, String TypeDeTaux, Double DureeAnnee, List<BddRoe__c> bdds) {
		System.debug(LoggingLevel.INFO,'@jaucent > ' + TxEuribor + ' ' + TypeDeTaux);
		System.debug(LoggingLevel.INFO,'@jaucent2 > ' + DureeAnnee + ' ' + bdds);

		Double TauxDeRefi = 1;
		
        if(TypeDeTaux == 'Taux variable Euribor 3 mois'){
			for(BddRoe__c ItemReqCurrentBddRoe : bdds){
				if(ItemReqCurrentBddRoe.IdRefinancement__c == DureeAnnee && ItemReqCurrentBddRoe.TauxVariable__c != null){
					TauxDeRefi= (TxEuribor + ItemReqCurrentBddRoe.TauxVariable__c ) * 365/360;  
				}
			}
		}
        else{
            for(BddRoe__c ItemReqCurrentBddRoe : bdds){
				if(ItemReqCurrentBddRoe.IdRefinancement__c == DureeAnnee && ItemReqCurrentBddRoe.TauxFixe__c != null){
					TauxDeRefi = ItemReqCurrentBddRoe.TauxFixe__c;  
				}
            }
        }
        return TauxDeRefi;
    }

    public static Double getCoutLiquiditePCOM(Double dureeAnnee, String semaineConstatationTaux){
        try{
          BddRoe__c itemReqCurrentBddRoe = [ Select TauxVariable__c 
                                                      FROM BddRoe__c 
                                                      Where TauxVariable__c != null 
                                                      and IdRefinancement__c =: dureeAnnee
                                                      and SemaineConstatation__c =:semaineConstatationTaux
                                                      ];

        return itemReqCurrentBddRoe.TauxVariable__c;
      }catch(Exception ex){
        System.debug('getCoutLiquiditePCOM error > '+ex);
        return null;
      }

    }
   
    public static double getTauxCMSSemaine(String TypeDeTaux, List<BddRoe__c> bdds) {
        Double TauxDeRefi = 0; 
		for(BddRoe__c ItemReqCurrentBddRoe : bdds){
			if(ItemReqCurrentBddRoe.TauxCMS12Ans__c != null && ItemReqCurrentBddRoe.TauxCMS15Ans__c != null && ItemReqCurrentBddRoe.TauxCMS8Ans__c != null && ItemReqCurrentBddRoe.TauxCMS9Ans__c != null){
				if(TypeDeTaux == 'Taux CMS 8 ans'){ 
					TauxDeRefi = ItemReqCurrentBddRoe.TauxCMS8Ans__c;  
					break;
				}
				else if( TypeDeTaux == 'Taux CMS 9 ans'){ 
					TauxDeRefi = ItemReqCurrentBddRoe.TauxCMS9Ans__c;  
					break;
				}
				else if( TypeDeTaux == 'Taux CMS 10 ans'){ 
					TauxDeRefi = ItemReqCurrentBddRoe.TauxCMS10Ans__c;  
					break;
				}
				else if( TypeDeTaux == 'Taux CMS 12 ans'){ 
					TauxDeRefi = ItemReqCurrentBddRoe.TauxCMS12Ans__c;  
					break;
				}
				else if( TypeDeTaux == 'Taux CMS 15 ans'){ 
					TauxDeRefi = ItemReqCurrentBddRoe.TauxCMS15Ans__c;  
					break;
				}
			}
		} 
        return TauxDeRefi;                           
    } 

     public static List<Double> getTauxRemunerationFPandPercBesoinsEnFP( String SemaineConstatationTaux ) { 
      Double PercBesoinsEnFP = 0;
      Double TauxRemunerationFP = 0;
      List<Double> TauxRemunerationFPandPercBesoinsEnFP = new List<Double>();
        
      for(BddRoe__c ItemReqCurrentBddRoe: [ Select TauxRemunerationFP__c,PourcentageBesoinsFP__c
                                        FROM BddRoe__c 
                                        Where TauxRemunerationFP__c != null 
                                        and  PourcentageBesoinsFP__c != null 
                                        and SemaineConstatation__c =: SemaineConstatationTaux
                                     ]){
           TauxRemunerationFP =   ItemReqCurrentBddRoe.TauxRemunerationFP__c  ;  
           PercBesoinsEnFP =   ItemReqCurrentBddRoe.PourcentageBesoinsFP__c  ;  
       }   
       TauxRemunerationFPandPercBesoinsEnFP.add(TauxRemunerationFP/100) ;
       TauxRemunerationFPandPercBesoinsEnFP.add(PercBesoinsEnFP/100) ;  
       return TauxRemunerationFPandPercBesoinsEnFP;
         
     }
////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// 05/10/2015 ... Valeur Dynamique dépendant des valeurs de la calculatrice
 /*   public static Double getPourcentageRisqueRWA( String SemaineConstatationTaux ) { 
        Double PourcentageRisqueRWA = 0;
         
         for(BddRoe__c ItemReqCurrentBddRoe: [ Select PourcentageRisqueRWA__c 
                                        FROM BddRoe__c 
                                        Where PourcentageRisqueRWA__c != null 
                                        and SemaineConstatation__c =: SemaineConstatationTaux
                                        //:!\ Tous les combiens de temps changé ?
                                     ]){
                 PourcentageRisqueRWA =   ItemReqCurrentBddRoe.PourcentageRisqueRWA__c  ;
         } 
         if(PourcentageRisqueRWA > 0  ) {
                   PourcentageRisqueRWA =  (PourcentageRisqueRWA/100);
         }
         return PourcentageRisqueRWA; 
    }*/
////////////////////////////////////////////////////////////////////////////////    
    
     public static Boolean checkAbilitationRCalcul(String TypeDeTaux, Double SpreadIndex365360, Double SpreadCMS, Double TauxVenteClientNominal) {
        Boolean right = false;
		if((TypeDeTaux == 'Taux variable Euribor 3 mois' && SpreadIndex365360 != null) ||
			((TypeDeTaux == 'Taux CMS 8 ans' || TypeDeTaux == 'Taux CMS 12 ans' || TypeDeTaux == 'Taux CMS 9 ans' || TypeDeTaux == 'Taux CMS 10 ans' || TypeDeTaux == 'Taux CMS 15 ans') && SpreadCMS != null) ||
			(TypeDeTaux == 'Taux fixe' && TauxVenteClientNominal != null)){
            right = true;
        }
         
        return right;
    }

    public static Double setValueTauxVenteClientTEA(String ModeCalculROE, Double TauxVenteClientNominalSpreadCMSSpreadEuribor, String TypeDeTaux, Double TxEuribor, Double TxCMS, Decimal ForwardChantier ) {
        Double TauxVenteClientTEA = null;
        if(ModeCalculROE == 'TEA') {  
            if(TypeDeTaux == 'Taux fixe') {
               TauxVenteClientTEA = TauxVenteClientNominalSpreadCMSSpreadEuribor + ForwardChantier  ;
            }
            else if(TypeDeTaux == 'Taux variable Euribor 3 mois') { 
                 TauxVenteClientTEA = (TauxVenteClientNominalSpreadCMSSpreadEuribor  + TxEuribor) *365/360 + ForwardChantier;
            }
            else if((TypeDeTaux == 'Taux CMS 8 ans')||(TypeDeTaux == 'Taux CMS 9 ans')||(TypeDeTaux == 'Taux CMS 10 ans')||(TypeDeTaux == 'Taux CMS 12 ans')||(TypeDeTaux == 'Taux CMS 15 ans') )    {
                TauxVenteClientTEA = TxCMS + TauxVenteClientNominalSpreadCMSSpreadEuribor + ForwardChantier  ;
            }        
         }  
       
        return TauxVenteClientTEA ;
    }
    
   
    public static Double setValueTauxVenteClientITE(String ModeCalculROE, Double TauxVenteClientNominalSpreadCMSSpreadEuribor, String TypeDeTaux, Double TxEuribor, Double TxCMS, Decimal ForwardChantier ) {
        Double TauxVenteClientITE = 0;
        if(ModeCalculROE == 'ITE') { 
           
            if(TypeDeTaux == 'Taux fixe') {
               TauxVenteClientITE = TauxVenteClientNominalSpreadCMSSpreadEuribor + ForwardChantier ;
            }
            else if(TypeDeTaux == 'Taux variable Euribor 3 mois') {  
                 TauxVenteClientITE = (TauxVenteClientNominalSpreadCMSSpreadEuribor  + TxEuribor) *365/360 + ForwardChantier ;
            }
            else if( (TypeDeTaux == 'Taux CMS 8 ans')||(TypeDeTaux == 'Taux CMS 9 ans')||(TypeDeTaux == 'Taux CMS 10 ans')||(TypeDeTaux == 'Taux CMS 12 ans')||(TypeDeTaux == 'Taux CMS 15 ans') )    {
                TauxVenteClientITE = TxCMS + TauxVenteClientNominalSpreadCMSSpreadEuribor + ForwardChantier;
            } 
         }
     
        return TauxVenteClientITE ;
    }
    
  public static Double setValueTauxVenteClientITEWithTRI(Double MontantFinance, Integer nbperiode,  Double ResultLoyerDossier, String TypeDeTaux, Double Periodicite, Double TauxToGuess, Double VR, Decimal ForwardChantier) { 
        List<Double> CashFlow = new List<Double>();
    System.debug('@1');
        Double   TriTEASansAvance = 0;       
        System.debug('@MontantFinance '+MontantFinance+' ResultLoyerDossier '+ResultLoyerDossier+' VR '+VR+' Periodicite '+Periodicite);
        for(integer i=0; i <= nbperiode; i++) {
            if(i == 0) {
              CashFlow.add(-MontantFinance + ResultLoyerDossier);        
            }
            else if(i == nbperiode) {
                CashFlow.add(VR);    
            }
            else {
              CashFlow.add(ResultLoyerDossier);   
            }
              
        }
      //12/10/2015 Taux To Guess changé à 0.00001
      // Prise en compte du Forward chantier
        TriTEASansAvance = (Ctrl01_CalculetteROE.TRI2( CashFlow , (Double)(0.00001)) * Periodicite) + ForwardChantier;
        
        return TriTEASansAvance;
    }
public static Double setMargeTEA(String ModeCalculROE, Double TauxVenteClient, Double tauxRefi ) {  
        Double MargeTEA = 0;
        System.debug('@Ced - setMargeTEA >'+ TauxVenteClient);
        System.debug('@Ced - tauxRefi >'+ tauxRefi);
        if(ModeCalculROE == 'TEA') { 
           
            if((tauxRefi > 100)) {
             tauxRefi=  tauxRefi/100;
            }
            if((TauxVenteClient*100 > 0)&&(TauxVenteClient*100 < 1)) {
             TauxVenteClient= TauxVenteClient*100;
            }
         MargeTEA = (TauxVenteClient - tauxRefi); 
        } 
        return MargeTEA; 
    }
public static Double setMargeITE(String ModeCalculROE, Double TauxRefi, Double TauxVenteClient) {  
        Double MargeITE = 0; 
        if(ModeCalculROE == 'ITE') { 
             MargeITE = (TauxVenteClient -TauxRefi) ;
             //Modif Nico 03/03/16
             System.debug('@Ced - setMargeITE > '+MargeITE);
             System.debug('@Ced - TauxDeRefi > '+tauxRefi);
             if((tauxRefi > 100)) {
             MargeITE=    (TauxVenteClient - (tauxRefi/100));
             }else if((tauxRefi < 1)) {
              Double margeTmp = TauxVenteClient -(TauxRefi*100);
                if(margeTmp > 0)
                MargeITE = margeTmp;
             }
             System.debug('@Ced - MargeITE2 > '+MargeITE);
        } 
        return MargeITE; 
    }    
    public static Double setMargeITEWithTRI(Double MontantFinance, Integer nbperiode,  Double ResultLoyerDossier, String TypeDeTaux, Double Periodicite, Double TauxToGuess, Double VR, Double TauxDeRefi) {  
        Double MargeITE = 0;
        List<Double> CashFlow = new List<Double>();
        for(integer i=0; i <= nbperiode; i++) {
            if(i == 0) {
              CashFlow.add(-MontantFinance + ResultLoyerDossier);        
            }
            else if(i == nbperiode) {
                CashFlow.add(VR);    
            }
            else {
              CashFlow.add(ResultLoyerDossier);   
            } 
        }
      System.debug('4');
            MargeITE = (Ctrl01_CalculetteROE.TRI2( CashFlow , TauxToGuess) * Periodicite) - TauxDeRefi  ; 
         // Modif Nico 03/03/16 
         System.debug('@Ced2 - setMargeITEWithTRI > '+MargeITE);
         System.debug('@Ced2 - TauxDeRefi > '+TauxDeRefi);   
         if(TauxDeRefi > 100) {
                MargeITE = (Ctrl01_CalculetteROE.TRI2( CashFlow , TauxToGuess) * Periodicite) - (TauxDeRefi/100) ;
         }else if(TauxDeRefi < 1) {
                Double margeTmp = (Ctrl01_CalculetteROE.TRI2( CashFlow , TauxToGuess) * Periodicite) - (TauxDeRefi*100);
                if(margeTmp > 0)
                MargeITE = margeTmp;
             }
         System.debug('@Ced2 - MargeITE2 > '+MargeITE);
       
        return MargeITE; 
    }   
    public static Double setMargeApresAvanceWithTRI(Double MontantFinance, Integer nbperiode,  Double ResultLoyerDossier, String TypeDeTaux, Double Periodicite, Double TauxToGuess, Double VR, Double TauxDeRefi, Double AvancePreneur, Double LoyerAvancePreneur) {  
        Double MargeApresAvance = 0;
        List<Double> CashFlow = new List<Double>();
        
        for(integer i=0; i <= nbperiode; i++) {
            if(i == 0) {
              CashFlow.add(-MontantFinance + ResultLoyerDossier + AvancePreneur  - LoyerAvancePreneur );        
            }
            else if(i == nbperiode) {
                CashFlow.add(VR);    
            }
            else {
              CashFlow.add(ResultLoyerDossier - LoyerAvancePreneur);   
            } 
        }
    System.debug('3');
        MargeApresAvance = (Ctrl01_CalculetteROE.TRI2( CashFlow , TauxToGuess) * Periodicite) - TauxDeRefi  ; 
        //Modif Nico 03/03/16
         if(TauxDeRefi > 100) {
                MargeApresAvance = (Ctrl01_CalculetteROE.TRI2( CashFlow , TauxToGuess) * Periodicite) -  (TauxDeRefi/100) ;
         }
        
        return MargeApresAvance; 
    }  
     public static Double setMargeITEAvanceWithTRI(Double MontantFinance, Integer nbperiode,  Double ResultLoyerDossier, String TypeDeTaux, Double Periodicite, Double TauxToGuess, Double VR, Double TauxDeRefi, Double AvancePreneur, Double TauxRemunerationAP) {  
        Double MargeITE = 0;
        List<Double> CashFlow = new List<Double>();
        Double  ResultLoyerDossierTEA = 0;
         ResultLoyerDossierTEA = setLoyerAvancePreneur('TEA', TauxRemunerationAP, AvancePreneur, Nbperiode);
         
        for(integer i=0; i <= nbperiode; i++) {
            if(i == 0) {
              CashFlow.add(-MontantFinance + AvancePreneur);        
            }
            else if(i == nbperiode) {
                CashFlow.add(ResultLoyerDossier +  VR  -  ResultLoyerDossierTEA);    
            }
            else {
                 CashFlow.add(ResultLoyerDossier  - ResultLoyerDossierTEA );   
            } 
        }
     System.debug('2');
     MargeITE = (Ctrl01_CalculetteROE.TRI2( CashFlow , TauxToGuess)  * Periodicite) - TauxDeRefi   ; 
       // Modif Nico 03/03/16
       
       if(TauxDeRefi > 100) {
                MargeITE = (Ctrl01_CalculetteROE.TRI2( CashFlow , TauxToGuess) * Periodicite) -  (TauxDeRefi/100) ;
       }else if(TauxDeRefi < 1) {
                Double margeTmp = (Ctrl01_CalculetteROE.TRI2( CashFlow , TauxToGuess) * Periodicite) -  (TauxDeRefi*100) ;
                if(margeTmp > 0)
                MargeITE = margeTmp;
         }

        return MargeITE; 
    }   
    

     public static  Double TRI2(  List<Double> cashFlows, Double EXCEL_EPSILON ) {
    
    final integer MAX_ITER = 75;
    system.debug('@Ced3 '+cashFlows+' EXCEL_EPSILON '+EXCEL_EPSILON);
    double x = 0.1;
    integer iter = 0;
    Integer CashFlowSize=cashFlows.size();
    while (iter++ < MAX_ITER) { 
        final double x1 = 1.0 + x;
        double fx = 0.0;
        double dfx = 0.0;
        for (integer i = 0; i < CashFlowSize; i++) {
            
            final double v = cashFlows[ i ];
            final double x1_i = Math.pow( x1, i );
        
            fx += v / x1_i;
            dfx += -i * v / (x1_i * x1);
        }//for

        final double new_x = x - fx / dfx;
        final double epsilon = Math.abs( new_x - x );
        
        if (epsilon <= EXCEL_EPSILON) {
            if (x == 0.0 && Math.abs( new_x ) <= EXCEL_EPSILON) {
             return 0.0; // OpenOffice calc does this
            } else {
                return new_x*100;
            }
        }
        x = new_x;
    }//While
    
    return x; 
}
    
  public static Double pmt(Double r, Double n, Double p, Double f, Boolean t){
        Double retval = 0;
        if(r == 0){
            retval = - 1 * (f + p) / n;
		} 
		else{
            Double r1 = r + 1;
            retval = ( f + p * Math.pow(r1, n)) * r / ((t ? r1 : 1) * (1 - Math.pow(r1, n)));
        }
        return retval;
    }
 
   public static double fv(double r, integer nper, double c, double pv, integer type) { 
       double result = 0;
       double test = (r + pv * Math.pow(1 + r, nper));
       system.debug(' r ' + test);
       if( r != 0){
           result = (-(c * (Math.pow(1 + r, nper) - 1) / r + pv * Math.pow(1 + r, nper)));
       } else {
             result = (-(    pv * Math.pow(1 + r, nper)));
       }
            return result;
    }  
    
    
	public static Double setEncoursMoyenDeOperation(String ModeCalculROE, List<Double> ResultRefinancementEncours, Double TauxRefiPeriodique, Integer Nbperiode){  
		return setRefinancementEncoursActualiseTotal(setRefinancementEncoursActualise(ModeCalculROE, ResultRefinancementEncours, TauxRefiPeriodique, Nbperiode), Nbperiode); 
	}

	public static Double setResultLoyerDossier(String ModeCalculROE, Double MontantFinance, Double TauxVenteEchu, Integer Nbperiode, Double VREuro){
		Double ResultLoyerDossier = 0;
		Double tauxAct = math.pow(1 + TauxVenteEchu, - Nbperiode);
		if(TauxVenteEchu > 0){
			ResultLoyerDossier = TauxVenteEchu * ((MontantFinance / ( 1 - (math.pow((1 + TauxVenteEchu), - Nbperiode)))) - (VREuro / (math.pow((1 + TauxVenteEchu), Nbperiode ) - 1)));
		}
		return ResultLoyerDossier;
	}
		
	public static Double setLoyerAvancePreneur(String ModeCalculROE, Double TauxRemunerationAP, Double AvancePreneur, Integer Nbperiode){ 
		Double LoyerAvancePreneur = 0;
		
		LoyerAvancePreneur = Ctrl01_CalculetteROE.pmt(TauxRemunerationAP, (Double)Nbperiode, (Double)-AvancePreneur, 0, false);
		return LoyerAvancePreneur;
	}

	public static Double setLoyerPeriodique(String ModeCalculROE, Double ResultLoyerDossier,Double ResultLoyerAvancePreneur, Integer Nbperiode){
		return (ResultLoyerDossier - ResultLoyerAvancePreneur);
	}
    
	public static Double setLoyerPeriodiqueTotal(String ModeCalculROE, Double ResultLoyerPeriodique, Integer Nbperiode){
		return (ResultLoyerPeriodique * Nbperiode);
	} 

	public static List<Double> setEncoursDossier(String ModeCalculROE, Double MontantFinance, Double ResultLoyerDossier, Double TauxVenteEchu, Integer Nbperiode) {
		List<Double> EncoursDossier = new List<Double>();
		for(Integer i = 0; i < Nbperiode; i++){
			if(i < 1){ 
				EncoursDossier.add(MontantFinance - (ResultLoyerDossier - (MontantFinance * TauxVenteEchu)));
			}
			else{ 
				EncoursDossier.add(EncoursDossier.get(i - 1) - (ResultLoyerDossier - (EncoursDossier.get(i - 1) * TauxVenteEchu)));
			}
			System.debug('---- EncoursDossier : ' + EncoursDossier[i] ) ;
		}
		return EncoursDossier; 
	}

   	public static Double setEncoursDossierTotal(List<Double> EncoursDossier, Integer Nbperiode){
        Double EncoursDossierTotal = 0;
		for(Integer i = 0; i < Nbperiode; i++){
			EncoursDossierTotal = EncoursDossierTotal + EncoursDossier.get(i);
		}
        EncoursDossierTotal = (EncoursDossierTotal / Nbperiode);
        return EncoursDossierTotal; 
    }
    
	public static List<Double> setEncoursAvancePreneur(String ModeCalculROE, Double AvancePreneur, Double ResultLoyerAvancePreneur, Double TauxRemunerationAP, Integer Nbperiode) {
		List<Double> EncoursAvancePreneur = new List<Double>();
		List<Double> LoyerAvancePreneur = new List<Double>();
		for(Integer i = 0; i < Nbperiode; i++) {     
			LoyerAvancePreneur.add(ResultLoyerAvancePreneur);
			EncoursAvancePreneur.add(Ctrl01_CalculetteROE.fv(TauxRemunerationAP, i + 1, LoyerAvancePreneur[i], -AvancePreneur, 0));
		}

		return EncoursAvancePreneur;
	}

	public static List<Double> setAmourtissementDossier(String ModeCalculROE, Double MontantFinance, List<Double> ResultEncoursDossier, Integer Nbperiode) {
		List<Double> AmortissementDossier = new List<Double>();
		for(Integer i = 0; i < Nbperiode; i++){
			if(i == 0) { 
				AmortissementDossier.add(MontantFinance - ResultEncoursDossier.get(i));
			}
			else { 
				AmortissementDossier.add(ResultEncoursDossier.get(i - 1) - ResultEncoursDossier.get(i));
			}
		}
		return AmortissementDossier;
	}


	public static List<Double> setAmourtissementAvancePreneur(String ModeCalculROE, Double AvancePreneur, List<Double> ResultEncoursAvancePreneur, Integer Nbperiode){ 
		List<Double> AmortissementAvancePreneur = new List<Double>();
		for(Integer i = 0; i < Nbperiode; i++) {
			if(i == 0){ 
				AmortissementAvancePreneur.add(AvancePreneur - ResultEncoursAvancePreneur.get(i));
			}
			else{ 
				AmortissementAvancePreneur.add(ResultEncoursAvancePreneur.get(i - 1) - ResultEncoursAvancePreneur.get(i));
			}
		}
		return AmortissementAvancePreneur;
	}

	public static List<Double> setInteretDossier(String ModeCalculROE, Double LoyerDossier, List<Double> AmortissementDossier, Integer Nbperiode){
		List<Double> InteretDossier = new List<Double>();
		for(Integer i = 0; i < Nbperiode; i++){ 
			InteretDossier.add(LoyerDossier - AmortissementDossier.get(i));
		}
		return InteretDossier;
	}

	public static List<Double> setInteretAvancePreneur(String ModeCalculROE, Double LoyerAvancePreneur, List<Double> AmortissementAvancePreneur, Integer Nbperiode){
		List<Double> InteretAvancePreneur = new List<Double>();
		for(Integer i = 0; i < Nbperiode; i++) {  
			InteretAvancePreneur.add(LoyerAvancePreneur - AmortissementAvancePreneur.get(i));
		}
		return InteretAvancePreneur;
	}

	public static List<Double> setRefinancementEncours(String ModeCalculROE, List<Double> EncoursDossier, List<Double> EncoursAvancePreneur, Integer Nbperiode){
		List<Double> RefinancementEncours = new List<Double>();
		if(ModeCalculROE == 'TEA'){ 
			for(Integer i = 0; i < Nbperiode + 1; i++){
				if(i == Nbperiode){
					RefinancementEncours.add(0);
				}
				else {
					RefinancementEncours.add(EncoursDossier.get(i) - EncoursAvancePreneur.get(i));
				}
			} 
		} 
		else if(ModeCalculROE == 'ITE'){ 
			for(Integer i = 0; i < Nbperiode; i++){ 
				RefinancementEncours.add(EncoursDossier.get(i) - EncoursAvancePreneur.get(i));
			}
		}
		return RefinancementEncours;
	}
    
	public static List<Double> setRefinancementAmortissement(String ModeCalculROE, List<Double> AmortissementDossier, List<Double> AmortissementAvancePreneur, Integer Nbperiode, Double VR){
		List<Double> RefinancementAmortissement = new List<Double>();
		if(ModeCalculROE == 'TEA'){
			for(Integer i = 0; i < Nbperiode + 1; i++){
				if(i == Nbperiode){
					RefinancementAmortissement.add(0);
				} else { 
					RefinancementAmortissement.add(AmortissementDossier.get(i) - AmortissementAvancePreneur.get(i));
				}
			} 
		} 
		else if(ModeCalculROE == 'ITE'){ 
			for(Integer i = 0; i < Nbperiode; i++){
				if(i == Nbperiode -1) { 
					RefinancementAmortissement.add(AmortissementDossier.get(i) - AmortissementAvancePreneur.get(i) + VR);
				} else { 
					RefinancementAmortissement.add(AmortissementDossier.get(i) - AmortissementAvancePreneur.get(i));
				} 
			}
		}
		return RefinancementAmortissement;        
	}

	public static List<Double> setRefinancementInteret(String ModeCalculROE, List<Double> RefinancementEncours, Double TauxRefiPeriodique, Integer Nbperiode, Double AvancePreneur, Double MontantFinance){
		List<Double> RefinancementInteret = new List<Double>();
		if(ModeCalculROE == 'TEA'){ 
			for(Integer i = 0; i < Nbperiode + 1; i++){
				if(i == 0){
					RefinancementInteret.add(0);
				} else { 
					RefinancementInteret.add( RefinancementEncours.get(i - 1)* TauxRefiPeriodique );
				}
			}
		}
		else if(ModeCalculROE == 'ITE'){ 
			for(Integer i = 0; i < Nbperiode; i++){
				if(i ==0){
					RefinancementInteret.add((MontantFinance - AvancePreneur ) * TauxRefiPeriodique);
				} else { 
					RefinancementInteret.add(RefinancementEncours.get(i - 1) * TauxRefiPeriodique);
				}
			} 
		}
		return RefinancementInteret;
	}
	
	public static List<Double> setRefinancementLoyer(String ModeCalculROE, List<Double> RefinancementAmortissement, List<Double> RefinancementInteret, Integer Nbperiode){
		List<Double> RefinancementLoyer = new List<Double>();
		if(ModeCalculROE == 'TEA'){ 
			for(Integer i = 0; i < Nbperiode + 1; i++){
				if(i == 0){
					RefinancementLoyer.add(RefinancementAmortissement.get(i));
				} else {   
					RefinancementLoyer.add(RefinancementAmortissement.get(i) + RefinancementInteret.get(i));
				}
			}
		} else if(ModeCalculROE == 'ITE'){ 
			for(Integer i = 0; i < Nbperiode; i++){  
				RefinancementLoyer.add(RefinancementAmortissement.get(i) + RefinancementInteret.get(i));
			}
		}

		return RefinancementLoyer;
	} 
 
	public static List<Double> setMargeBrut(String ModeCalculROE, List<Double> RefinancementLoyer, Double LoyerDossier, Double LoyerAvancePreneur, Integer Nbperiode, Double VR){
		List<Double> MargeBrut = new List<Double>();
		if(ModeCalculROE == 'TEA'){ 
			for(Integer i = 0; i < Nbperiode + 1; i++){
				if(i == Nbperiode){ 
					MargeBrut.add(- RefinancementLoyer.get(i));
				} else {
					MargeBrut.add((LoyerDossier - LoyerAvancePreneur) - RefinancementLoyer.get(i));
				}
			}
		} else if(ModeCalculROE == 'ITE'){ 
			for(Integer i = 0; i < Nbperiode; i++){
				if(i == Nbperiode - 1){ 
					MargeBrut.add(((LoyerDossier - LoyerAvancePreneur) - RefinancementLoyer.get(i)) + VR);
				} else { 
					MargeBrut.add((LoyerDossier - LoyerAvancePreneur) - RefinancementLoyer.get(i));
				}
			}
		}
		return MargeBrut;
	}	
    
	public static List<Double> setMargeBrutActualisee(String ModeCalculROE, List<Double> MargeBrut, Double TauxRefiPeriodique, Double DureeDuChantierMois, Double LoyerAvancePreneur, Integer Nbperiode){
		List<Double> MargeActualisee = new List<Double>();
		Double MargeActualiseeTotal = 0;
	
		if(ModeCalculROE == 'TEA'){ 
			// /!\ PERIODE .....
			Double xPer = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; // Durée phase chantier
			for(Integer i = 0; i < Nbperiode + 1; i++){ 
				MargeActualisee.add(MargeBrut.get(i) * Math.pow((1 + TauxRefiPeriodique), (Double)-xPer));
				MargeActualiseeTotal = MargeActualiseeTotal + (MargeBrut.get(i) * Math.pow((1 + TauxRefiPeriodique), (Double)-xPer));
				xPer ++;
			}
		} else if(ModeCalculROE == 'ITE'){
			// /!\ PERIODE .....
			Double xPer = 1 + (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; // Durée phase chantier
			for(Integer i = 0; i < Nbperiode; i++){
				MargeActualisee.add(MargeBrut.get(i) * Math.pow((1 +TauxRefiPeriodique), ((Double)-xPer)));
				MargeActualiseeTotal = MargeActualiseeTotal + (MargeBrut.get(i) * Math.pow((1 + TauxRefiPeriodique), ((Double)-xPer)));
				xPer ++;
			}
		}
		return MargeActualisee;       
	}
	
	public static Double setMargeBrutActualiseeTotal(String ModeCalculROE, List<Double> MargeActualisee, Integer Nbperiode){
		Double MargeActualiseeTotal = 0;
		if(ModeCalculROE == 'TEA'){    
			for(Integer i = 0; i < Nbperiode +1; i++){
				MargeActualiseeTotal = MargeActualiseeTotal + MargeActualisee.get(i);
			}
		} else if(ModeCalculROE == 'ITE'){
			for(Integer i = 0; i < Nbperiode; i++){
				MargeActualiseeTotal = MargeActualiseeTotal + MargeActualisee.get(i);
			}
		}
		return MargeActualiseeTotal;  
	}

	public static Double setMargeBrutActualiseeTotalPlusPnBPreloyer(String ModeCalculROE, Double MargeActualiseeTotal, Double PnbPreloyerTotal){
		return (MargeActualiseeTotal + PnbPreloyerTotal);
	}      

	public static List<Double> setRefinancementEncoursActualise(String ModeCalculROE, List<Double> RefinancementEncours, Double TauxRefiPeriodique, Integer Nbperiode) {
		List<Double> RefinancementEncoursActualisee = new List<Double>();
		for(Integer i = 0; i < Nbperiode; i++){
			RefinancementEncoursActualisee.add(RefinancementEncours.get(i) * math.pow((1 + TauxRefiPeriodique), -(i + 1))); 
		}
		return RefinancementEncoursActualisee;
	}
     
public  static  Double  setRefinancementEncoursActualiseTotal(  List<Double>  RefinancementEncoursActualisee,   integer Nbperiode  ) {
      Double RefinancementEncoursActualiseeTotal = 0 ;
      for(Integer i = 0; i < Nbperiode  ; i++) {
         RefinancementEncoursActualiseeTotal = RefinancementEncoursActualiseeTotal + RefinancementEncoursActualisee.get(i) ; 
      }
      return (RefinancementEncoursActualiseeTotal/ Nbperiode);
}
    
	public static Double setEncoursMoyen(List<Double> RefinancementEncours, Integer Nbperiode){
		Double EncoursMoyen = 0;
		for(Integer i = 0; i < Nbperiode  ; i++){
			EncoursMoyen = EncoursMoyen + RefinancementEncours.get(i); 
		}
		return (EncoursMoyen / Nbperiode);
	}
	
    
	public static List<Double> setCommissionsDeRisqueBrute(String ModeCalculROE, Double CommissionDeRisqueBPCE, Double Periodicite, Integer Nbperiode, Double MontantFinance, Double AvancePreneur, List<Double> ResultEncoursDossier, List<Double> ResultEncoursAvancePreneur){
		List<Double> CommissionsDeRisqueBrute = new List<Double>();
		if(ModeCalculROE == 'TEA'){ 
			for(Integer i = 0; i < Nbperiode + 1; i++){
				if(i == 0 ){ 
					CommissionsDeRisqueBrute.add(0);
				} else { 
					CommissionsDeRisqueBrute.add(((ResultEncoursDossier.get(i - 1) - ResultEncoursAvancePreneur.get(i - 1)) * (CommissionDeRisqueBPCE / 100) * Periodicite) / 12);
				}
			}
		} else if(ModeCalculROE == 'ITE'){ 
			for(Integer i = 0; i < Nbperiode + 1; i++){
				if(i == 0){ 
					CommissionsDeRisqueBrute.add(((MontantFinance - AvancePreneur) * (CommissionDeRisqueBPCE / 100) * Periodicite) / 12); 
				} else { 
					CommissionsDeRisqueBrute.add(((ResultEncoursDossier.get(i - 1) - ResultEncoursAvancePreneur.get(i - 1)) * (CommissionDeRisqueBPCE / 100) * Periodicite) / 12); 
				}
			}
		}
		return CommissionsDeRisqueBrute;
	}
  
 
	public static List<Double> setResultCommissionsDeRisqueBruteActualisee(String ModeCalculROE, List<Double> ResultCommissionsDeRisqueBrute, Double Periodicite, Integer Nbperiode, Double TauxRefiPeriodique, Double DureeDuChantierMois){
		List<Double> CommissionsDeRisqueBruteActualisee = new List<Double>();  
		if(ModeCalculROE == 'TEA'){
			for(Integer i = 0; i < Nbperiode +1; i++){
				if(i == 0){ 
					CommissionsDeRisqueBruteActualisee.add(ResultCommissionsDeRisqueBrute.get(i) * math.pow((1 + TauxRefiPeriodique), 0));
				} else { 
					CommissionsDeRisqueBruteActualisee.add(ResultCommissionsDeRisqueBrute.get(i) * math.pow((1 + TauxRefiPeriodique), -i)); 
				}
			}
		} else if(ModeCalculROE == 'ITE'){
			Double xPer = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4 + 1;
			for(Integer i = 0; i < Nbperiode + 1; i++){
			//!\ 10 Car décalage phase chantier à 10  
				if(i == 0){
					CommissionsDeRisqueBruteActualisee.add(ResultCommissionsDeRisqueBrute.get(i) * math.pow((1 + TauxRefiPeriodique), -xPer)); 
				} else {
					CommissionsDeRisqueBruteActualisee.add(ResultCommissionsDeRisqueBrute.get(i) * math.pow((1 + TauxRefiPeriodique), -i -xPer));       
				}
			}
		}  
		return CommissionsDeRisqueBruteActualisee;
	}
    
	public static Double setResultCommissionsDeRisque(String ModeCalculROE, List<Double> ResultCommissionsDeRisqueBrute, Double Periodicite, Integer Nbperiode, Double TauxRefiPeriodique, Double DureeDuChantierMois){
		List<Double> CommissionsDeRisqueBruteActualisee = new List<Double>();
		List<Double> CommissionsDeRisque = new List<Double>();
		Double ResultCommissionsDeRisque = 0;
		
		if(ModeCalculROE == 'TEA'){
			for(Integer i = 0; i < Nbperiode +1; i++){
				if(i > 0){
					ResultCommissionsDeRisque = ResultCommissionsDeRisque - ResultCommissionsDeRisqueBrute.get(i);
				}
			} 
		} else if(ModeCalculROE == 'ITE'){
			Double xPer = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4 + 1;
			for(Integer i = 0; i < ResultCommissionsDeRisqueBrute.size(); i++){
				ResultCommissionsDeRisque = ResultCommissionsDeRisque - ResultCommissionsDeRisqueBrute.get(i);
			}
		} 
		return ResultCommissionsDeRisque;
	}
    
	public static List<Double> setCalculPhaseChantier(Double MontantFinance, Double AvancePreneur, List<Double> ResultEncoursDossier, List<Double> ResultRefinancementEncours, Double dureeDecaissement){    
		List<Double> CalculPhaseChantier = new List<Double>(); 
		for(Integer i = 0; i < dureeDecaissement; i++){
			CalculPhaseChantier.add(MontantFinance - AvancePreneur); 
		} 
		for(integer i = 0; i < ResultEncoursDossier.size(); i ++){
			CalculPhaseChantier.add(ResultRefinancementEncours.get(i)); 
		}
		return CalculPhaseChantier;
	}

	public static List<Double> setPhaseDeDecaissement(Double MontantFinance, Double AvancePreneur, Double PremierTiragePhaseChantier, Double dureeDecaissement){
		List<Double> PhaseDeDecaissement = new List<Double>();
		for(Integer i = 0; i < dureeDecaissement; i++){ 
			if(i == 0){ 
				PhaseDeDecaissement.add(PremierTiragePhaseChantier - AvancePreneur);
			} else { 
				PhaseDeDecaissement.add(PhaseDeDecaissement.get(i - 1) + ((MontantFinance - PremierTiragePhaseChantier) / (dureeDecaissement - 1)));
			}
		}
		return PhaseDeDecaissement;
	}


	public static List<Double> setMontantNonTire(List<Double> CalculPhaseChantier, List<Double> PhaseDeDecaissement, Double dureeDecaissement){
		List<Double> MontantNonTire = new List<Double>();
		for(Integer i = 0; i < dureeDecaissement; i++){ 
			MontantNonTire.add(CalculPhaseChantier.get(i) - PhaseDeDecaissement.get(i));
		}
		return MontantNonTire; 
	}
    
	public static List<Double> setPreLoyersNetRefi(List<Double> PhaseDeDecaissement, Double dureeDecaissement, Double SpreadRemunerationPreloyers, Double coutCT){ 
		List<Double> PreLoyersNetRefi = new List<Double>();
			
		for(Integer i = 0; i < dureeDecaissement; i++){
			PreLoyersNetRefi.add(PhaseDeDecaissement.get(i) * ((((SpreadRemunerationPreloyers - coutCT) / 100) * 90) / 360)); 
		}
		return PreLoyersNetRefi; 
	}

	public static List<Double> setPreLoyersNetRefiActualise(Double dureeDecaissement, List<Double> PreLoyersNetRefi, Double TauxRefiPeriodique){
		List<Double> PreLoyersNetRefiActualise = new List<Double>(); 
		for(Integer i = 0; i < dureeDecaissement; i++){ 
			PreLoyersNetRefiActualise.add(PreLoyersNetRefi.get(i) * (math.pow((1 + TauxRefiPeriodique), -1 * (i + 1)))); 
		}
		return PreLoyersNetRefiActualise;
	}

	public static Double setPNBPreLoyers(Double dureeDecaissement, List<Double> PreLoyersNetRefi, Double TauxRefiPeriodique){
		Double PNBPreLoyers = 0; 
		for(Integer i = 0; i < PreLoyersNetRefi.size(); i++){
			PNBPreLoyers = PNBPreLoyers + (PreLoyersNetRefi.get(i) * (math.pow((1 + TauxRefiPeriodique), -1*(i + 1))));
		}
		return PNBPreLoyers;
	}

    public static double setRemunerationTVA(Double MontantTVA, Double TauxEuribor,Double SpreadRemuTVA, Double DureeTVA ) {  
        System.debug('MontantTVA > ' + MontantTVA + ' DureeTVA ' + DureeTVA + ' TauxEuribor/100 ' + TauxEuribor / 100 + ' SpreadRemuTVA/100 ' + SpreadRemuTVA / 100); 
        return (MontantTVA * 30 / 360 * DureeTVA * ( TauxEuribor / 100 + SpreadRemuTVA / 100 )) - (MontantTVA * 30 / 360 * TauxEuribor / 100);
    }
    
	public static Double setAutresPNB(Double DureeDuChantierMois, Double SpreadRemuTVA, Double TauxEuribor, Double MontantTVA, Double PourcentageCommissionEngagement, Double CommissionNonUtilisationSpreadEuribor, Double TauxRefiPeriodique, List<Double> ResultMontantNonTire, List<Double> ResultatCalculPhaseChantier, Double RemunerationTVA){
		System.debug('MontantTVA ' + MontantTVA + ' TauxEuribor ' + TauxEuribor + ' SpreadRemuTVA ' + SpreadRemuTVA);
		Double dureeDecaissement = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4;
		System.debug('dureeDecaissement > '+ dureeDecaissement);       
		return setAutrePNBTotal(dureeDecaissement, setListeAutrePNBTotal(dureeDecaissement, setCommissionDeNonUtilisation(dureeDecaissement, ResultMontantNonTire, CommissionNonUtilisationSpreadEuribor), setCommissionEngagement(dureeDecaissement, ResultatCalculPhaseChantier, PourcentageCommissionEngagement), RemunerationTVA, TauxRefiPeriodique));
	}
    
	public static List<Double> setCommissionDeNonUtilisation(Double dureeDecaissement, List<Double> ResultMontantNonTire, Double CommissionNonUtilisationSpreadEuribor){ 
		List<Double> CommissionDeNonUtilisation = new List<Double>();
		for(Integer i = 0; i < dureeDecaissement ; i++){
			CommissionDeNonUtilisation.add(ResultMontantNonTire.get(i) * ((((CommissionNonUtilisationSpreadEuribor) / 100) * 90) / 360));
		}
		return CommissionDeNonUtilisation;
	}
    
	public static List<Double> setCommissionEngagement(Double dureeDecaissement, List<Double> ResultatCalculPhaseChantier, Double PourcentageCommissionEngagement){    
		List<Double> CommissionEngagement  = new List<Double>();
		for(Integer i = 0; i < dureeDecaissement; i++){
			CommissionEngagement.add(ResultatCalculPhaseChantier.get(i) * (PourcentageCommissionEngagement / 100));
		}
		return CommissionEngagement;
	}

	public static List<Double> setListeAutrePNBTotal(Double dureeDecaissement, List<Double> ResultCommissionDeNonUtilisation, List<Double> ResultCommissionEngagement, Double RemunerationTVA, Double TauxRefiPeriodique){   
		system.debug('RemunerationTVA ' + RemunerationTVA);
		List<Double> ListeAutrePNBTotal = new List<Double>();
		if(dureeDecaissement > 0) {
			for(Integer i = 0; i < dureeDecaissement; i++){
				if(i == 0){
					ListeAutrePNBTotal.add((ResultCommissionDeNonUtilisation.get(i) + ResultCommissionEngagement.get(i) + RemunerationTVA) * math.pow((1 + TauxRefiPeriodique), -(i + 1)));
					System.debug('@i' + i + ' ' + ListeAutrePNBTotal.get(i));
					System.debug('base : ' + (ResultCommissionDeNonUtilisation.get(i) + ResultCommissionEngagement.get(i) + RemunerationTVA ) + ' / ' + ResultCommissionDeNonUtilisation.get(i) + ' / ' + ResultCommissionEngagement.get(i)+' / '+RemunerationTVA);
				}
				else {
					ListeAutrePNBTotal.add((ResultCommissionDeNonUtilisation.get(i) + ResultCommissionEngagement.get(i)) * math.pow((1 + TauxRefiPeriodique), -(i + 1)));
					System.debug('@i' + i + ' ' + ListeAutrePNBTotal.get(i));
				} 
			}
		} else {
			ListeAutrePNBTotal.add((RemunerationTVA ) * math.pow((1 + TauxRefiPeriodique), -(1)));
		}
		return ListeAutrePNBTotal;
	}
	
	public static Double setAutrePNBTotal( Double dureeDecaissement, List<Double> ListeAutrePNBTotal){   
		System.debug('dureeDecaissement ' + dureeDecaissement + 'ListeAutrePNBTotal size ' + ListeAutrePNBTotal.size());
		Double AutrePNBTotal = 0;
		if(dureeDecaissement > 1){
			for(Integer i = 0; i < dureeDecaissement; i++){
				AutrePNBTotal = AutrePNBTotal + ListeAutrePNBTotal.get(i);
			}
		} else { 
			System.debug('ListeAutrePNBTotal.get(0) ' + ListeAutrePNBTotal.get(0));
			AutrePNBTotal = AutrePNBTotal + ListeAutrePNBTotal.get(0); 
		} 
		return AutrePNBTotal;   
	}

	public static Double setPNBStandard(Double ResultMargeActualiseeTotal, Double FraisDeDossier, Double ResultCommissionsDeRisque, Double CommissionApportFlat, Double ResultAutrePNBTotal){
		return (ResultMargeActualiseeTotal + FraisDeDossier + ResultCommissionsDeRisque - CommissionApportFlat + ResultAutrePNBTotal);                             
	}

	public static Double setResultatAvantImpotStandard(Double ResultMargeActualiseeTotal, Double FraisDeDossier, Double ResultCommissionsDeRisque, Double CommissionApportFlat, Double ResultAutrePNBTotal, Double ResultCoutExploitationStandard){
		return ResultMargeActualiseeTotal + FraisDeDossier + ResultCommissionsDeRisque - CommissionApportFlat + ResultAutrePNBTotal + ResultCoutExploitationStandard;                            
	}

	public static Double setResultatMargeNetStandard(Double ResultatAvantImpotStandard, Double TauxIS){
		Double ResultatMargeNetStandard = 0;
		if((ResultatAvantImpotStandard < 0) || ResultatAvantImpotStandard == null){
			ResultatMargeNetStandard = 0;
		}
		else{ 
			ResultatMargeNetStandard = ResultatAvantImpotStandard * ( 1 - TauxIS / 100);                            
		}
		return ResultatMargeNetStandard;
	}    
    
	public static Double setPD(String CotationNIO, String CotationNIE, String NotationTRR, String TypeContrepartie, String BaseNotation, List<BddRoe__c> taux){
		Double Notation = 0;

		Map<String, Double> MapNotationTTR = new Map<String, Double>();
		List<String> NotationTTRName = new List<String>();
		List<Double> TTR = new List<Double>();

		NotationTTRName.add('A');
		NotationTTRName.add('A-'); 
		NotationTTRName.add('A+'); 
		NotationTTRName.add('AA'); 
		NotationTTRName.add('AA-'); 
		NotationTTRName.add('AA+'); 
		NotationTTRName.add('AAA'); 
		NotationTTRName.add('B'); 
		NotationTTRName.add('B-'); 
		NotationTTRName.add('B+'); 
		NotationTTRName.add('BB'); 
		NotationTTRName.add('BB-'); 
		NotationTTRName.add('BB+'); 
		NotationTTRName.add('BBB'); 
		NotationTTRName.add('BBB-'); 
		NotationTTRName.add('BBB+'); 
		NotationTTRName.add('C'); 
		NotationTTRName.add('CC'); 
		NotationTTRName.add('CCC'); 
		NotationTTRName.add('CCC-'); 
		NotationTTRName.add('CCC+');
		NotationTTRName.add('DX');

		for(BddRoe__c bdd : taux){
			if(TypeContrepartie == 'Corporate'){
				if(BaseNotation == 'NIE NEW 2012 - BPCE' || BaseNotation == 'NIE NEW 2012 - NATIXIS'){
					Double NotationNIE = Integer.valueOf(CotationNIE);
					if(bdd.RecordType.DeveloperName == 'GrillePD' && bdd.RatinRefPD__c == NotationNIE){
						Notation = bdd.BpceNatixisNIEComptesSociaux__c;
					}
				} else if(BaseNotation == 'TRR'){
					if(bdd.RecordType.DeveloperName == 'GrilleTTR'){
						TTR.add(bdd.A__c);
						TTR.add(bdd.AMoins__c);
						TTR.add(bdd.Aplus__c);
						TTR.add(bdd.AA__c);
						TTR.add(bdd.AAMoins__c);
						TTR.add(bdd.AAplus__c);
						TTR.add(bdd.AAA__c);
						TTR.add(bdd.B__c);
						TTR.add(bdd.BMoins__c);
						TTR.add(bdd.BPlus__c);
						TTR.add(bdd.BB__c);
						TTR.add(bdd.BBMoins__c);
						TTR.add(bdd.BBplus__c);
						TTR.add(bdd.BBB__c);
						TTR.add(bdd.BBBMoins__c);
						TTR.add(bdd.BBBplus__c);
						TTR.add(bdd.C__c);
						TTR.add(bdd.CC__c);
						TTR.add(bdd.CCC__c);
						TTR.add(bdd.CCCMoins__c);
						TTR.add(bdd.CCCPlus__c);
						TTR.add(bdd.DX__c);

						for(Integer i = 0; i < NotationTTRName.size() ; i++) { 
							MapNotationTTR.put(NotationTTRName.get(i), TTR.get(i));
						}  
						Notation = MapNotationTTR.get(NotationTRR);
					}
				}
			} else if(TypeContrepartie == 'Retail - Professionnels'){
				if(BaseNotation == 'NIO Professionnels CE'){
					Double NotationNIO = Integer.valueOf(CotationNIO);
					if(bdd.RecordType.DeveloperName == 'GrillePD' && bdd.RatinRefPD__c == NotationNIO){
						Notation = bdd.CeNatixisNIO__c;
					}
				} else if(BaseNotation == 'NIO Professionnels BP'){
					Double NotationNIO = Integer.valueOf(CotationNIO);
					if(bdd.RecordType.DeveloperName == 'GrillePD' && bdd.RatinRefPD__c == NotationNIO){
						Notation = bdd.BpNatixisNIO__c ;
					}
				} else if(BaseNotation == 'Retails - Direct'){ 
					Notation = 0;
				} 
			}
		}
		return Notation;
	} 
    
  public static Double  setValeurDuBien (Boolean IsAvenant,Double MontantFinance,Double ValeurDuBien,Double EncoursTotalDuDossier  ) {
    Double ResultatValeurDuBien =  ValeurDuBien ; 
    if(IsAvenant == true) {
      ResultatValeurDuBien = (MontantFinance * ValeurDuBien)/EncoursTotalDuDossier;
    }
    return ResultatValeurDuBien; 
  }

    public static Double setLGD(String Localisation, String TypeContrepartie, String Usage, Double AvancePreneur, Double MontantFinance, String BaseNotation, List<BddRoe__c> bdds) {
        Double VerificationPourcAmortBien = 0;
        Double LGD = 0;
        Double ValeurTauxAmortissement = 0;
        List<BddRoe__c> ReqLGD = new List<BddRoe__c>();
        List<BddRoe__c> ReqValeurTauxAmortissement = new List<BddRoe__c>();
        
		VerificationPourcAmortBien = AvancePreneur / MontantFinance;

		for(BddRoe__c bdd : bdds){
			if(TypeContrepartie == bdd.TypeContrepartie__c && Usage == bdd.Usage__c && bdd.RecordType.DeveloperName == 'LGD'){
				if(bdd.LGD__c !=  null ){
					LGD = bdd.LGD__c;  
				}
				else if(Localisation == bdd.Localisation__c){
					if(bdd.ValeurTauxAmortissement__c != null){
						ValeurTauxAmortissement = bdd.ValeurTauxAmortissement__c;
					}
					if(VerificationPourcAmortBien >= (ValeurTauxAmortissement / 100)){
						if(bdd.LimiteTauxAmortissement__c == '>' && bdd.ValeurTauxAmortissement__c == ValeurTauxAmortissement){
							if(bdd.LGD__c !=  null ){
								LGD = bdd.LGD__c;  
							}
						}
					}
					else{
						if(bdd.LimiteTauxAmortissement__c == '<' && bdd.ValeurTauxAmortissement__c == ValeurTauxAmortissement){
							if(bdd.LGD__c !=  null ){
								LGD = bdd.LGD__c;  
							}
						}
					}
				}
			}  
		}  
        return LGD;
    }
    //09/10/2015
   public static List<Double>   setInteretsPourRisqueOperationel(String ModeCalculROE,Double Nbperiode, Double DureeChantier,  Double CommissionApportFlat, List<Double> ResultMargeActualisee, List<Double>ResultCommissionsDeRisqueBruteActualisee ) {
    List<Double>InteretsPourRisqueOperationel  = new List<Double>(); 
    Double Duree = DureeChantier +    Nbperiode;
     if( ModeCalculROE == 'TEA' ) {          
       for(Integer i = 0; i < (Duree +1)   ; i++) {
              if(i == 0) {  
                 if((ResultMargeActualisee.get(i) - ResultCommissionsDeRisqueBruteActualisee.get(i) - CommissionApportFlat) < 0) {
                      InteretsPourRisqueOperationel.add(0);
                 }else {
                      InteretsPourRisqueOperationel.add(ResultMargeActualisee.get(i) - ResultCommissionsDeRisqueBruteActualisee.get(i) - CommissionApportFlat);
                 }
              } else {
                  if((i > (ResultMargeActualisee.size() - 1))||(i > (ResultCommissionsDeRisqueBruteActualisee.size() - 1 ))){
                                 InteretsPourRisqueOperationel.add(0);
                  }else  if((ResultMargeActualisee.get(i) - ResultCommissionsDeRisqueBruteActualisee.get(i)) < 0) {
                           InteretsPourRisqueOperationel.add(0);
                   } else {
                          InteretsPourRisqueOperationel.add(ResultMargeActualisee.get(i) - ResultCommissionsDeRisqueBruteActualisee.get(i));
                   }
             }//if
          }//for
     } else if(ModeCalculROE == 'ITE') {
            for(Integer i = 0; i < Nbperiode   ; i++) {
              if(i == 0) { 
                  //System.debug('ResultMargeActualisee.get(i) ' + ResultMargeActualisee.get(i) + 'ResultCommissionsDeRisqueBruteActualisee.get(i) ' + ResultCommissionsDeRisqueBruteActualisee.get(i)   +  'CommissionApportFlat ' + CommissionApportFlat);
                  if( (ResultMargeActualisee.get(i) - ResultCommissionsDeRisqueBruteActualisee.get(i) - CommissionApportFlat) < 0) {
                       InteretsPourRisqueOperationel.add(0);
                  } else {
                      InteretsPourRisqueOperationel.add(ResultMargeActualisee.get(i) - ResultCommissionsDeRisqueBruteActualisee.get(i) - CommissionApportFlat);
                  }
              } else { 
                  // System.debug('ResultMargeActualisee.get(i) ' + ResultMargeActualisee.get(i) + 'ResultCommissionsDeRisqueBruteActualisee.get(i) ' + ResultCommissionsDeRisqueBruteActualisee.get(i)  );
                   if((i > (ResultMargeActualisee.size() - 1))||(i > (ResultCommissionsDeRisqueBruteActualisee.size() - 1 ))){
                                 InteretsPourRisqueOperationel.add(0);
                  }else if(( ResultMargeActualisee.get(i) - ResultCommissionsDeRisqueBruteActualisee.get(i)) < 0) {
                       InteretsPourRisqueOperationel.add(0);
                  } else {
                      InteretsPourRisqueOperationel.add( ResultMargeActualisee.get(i) - ResultCommissionsDeRisqueBruteActualisee.get(i));
                  }
              }//if
          }//for
     }//if
     return InteretsPourRisqueOperationel;
   }
    
    public static List<Double>  setInteretsPourDureeRestantaCourir(String ModeCalculROE,Double Nbperiode,   List<Double> ResultPreLoyersNetRefi, Double DureeDuChantierMois, Double ResultLoyerDossier, Double ResultLoyersAvancePreneur, List<Double> ResultCommissionsDeRisqueBruteActualisee ) {
      List<Double>InteretsPourDureeRestantaCourir  = new List<Double>(); 
      integer NbPeriodeApresChantier = 0; // Permet de récuperer quand le numéro du dernier i de la boucle//
      if(DureeDuChantierMois > 0) {
           if( ModeCalculROE == 'TEA' ) {
                Double DureeDuChantierTrimestre = DureeDuChantierMois / 3; 
                for(Integer i=0; i < DureeDuChantierTrimestre ; i++ ) {
                     InteretsPourDureeRestantaCourir.add( ResultPreLoyersNetRefi.get(i) );
                     NbPeriodeApresChantier++;
                } 
                double forstart = NbPeriodeApresChantier - DureeDuChantierTrimestre;
                // System.debug('forstart ' + forstart); 
                        for(Integer i=(Integer)forstart ; i < Nbperiode + 1  ; i++ ) {
                            if( i == Nbperiode ) {
                                InteretsPourDureeRestantaCourir.add( ResultCommissionsDeRisqueBruteActualisee.get(i) );   
                            }
                            else {
                                InteretsPourDureeRestantaCourir.add( ResultLoyerDossier - ResultLoyersAvancePreneur  + ResultCommissionsDeRisqueBruteActualisee.get(i) );
                            } 
                        }//for
            }else if(ModeCalculROE == 'ITE') {
                Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
                for(Integer i=0; i < DureeDuChantierTrimestre ; i++ ) {
                     InteretsPourDureeRestantaCourir.add( ResultPreLoyersNetRefi.get(i) );
                     NbPeriodeApresChantier++;
                }
                double forstart = NbPeriodeApresChantier - DureeDuChantierTrimestre;
                //System.debug('forstart ' + forstart);              
                for(Integer i=(Integer)forstart ; i < Nbperiode + 1 ; i++ ) {
                    if(i ==  Nbperiode - 1) {
                         InteretsPourDureeRestantaCourir.add( ResultLoyerDossier - ResultLoyersAvancePreneur  + ResultCommissionsDeRisqueBruteActualisee.get(i) ); 
                    }else if(i ==  Nbperiode ) { 
                         InteretsPourDureeRestantaCourir.add(  ResultCommissionsDeRisqueBruteActualisee.get(i   ) );
                    }else {
                         InteretsPourDureeRestantaCourir.add( ResultLoyerDossier - ResultLoyersAvancePreneur  + ResultCommissionsDeRisqueBruteActualisee.get(i) );
                    }   
                }//for
            }//if
           // ResultInteretsPourDureeRestantaCourir = InteretsPourDureeRestantaCourir;
        } else {
            for(Integer i=0 ; i < (Nbperiode + 1)  ; i++ ) { 
               if(i < Nbperiode ) {
                    InteretsPourDureeRestantaCourir.add(    (ResultLoyerDossier - ResultLoyersAvancePreneur) +  ResultCommissionsDeRisqueBruteActualisee.get(i)  );
               }else if(i == (Nbperiode)) {
                    InteretsPourDureeRestantaCourir.add(  ResultCommissionsDeRisqueBruteActualisee.get(i)  );
               }
           }//for
        }//if
        return InteretsPourDureeRestantaCourir;
    }

    public static   List<Integer>  setDureeRestantaCourir(String ModeCalculROE,Double Nbperiode,  Double DureeDuChantierMois ) {
         Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
         Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode );
         List<Integer>DureeRestantaCourir  = new List<Integer>(); 
       //  System.debug('DureeDuChantierTrimestre ' + DureeDuChantierTrimestre);  
        for(Integer i = 0 ; i < DureeTotalAvecChantier + 1  ; i++  )  { 
            if(i == 0) {  
                Decimal DureeTotalTrimestre = DureeTotalAvecChantier/4; 
                DureeRestantaCourir.add( (Integer)DureeTotalTrimestre.round(System.RoundingMode.UP) ) ;
            } else {
                if((DureeTotalAvecChantier - i)/4 < 0) {
                    DureeRestantaCourir.add( 0 ) ;
                } else {
                  //  ARRONDI.SUP(((nbre_de_période_tot_chantier-D4)/'Calculs Marge actualisée'!$B$7);0)
                   Decimal temp = (DureeTotalAvecChantier - i)/4 ;
                   DureeRestantaCourir.add( (Integer)temp.round(System.RoundingMode.UP) ) ;
                }
            }//if
        }//for
        return DureeRestantaCourir;
    }

    
    public static List<Double> setPonderationParMontantsLoyersEtCommissions(String ModeCalculROE,Double Nbperiode,  Double DureeDuChantierMois, List<Integer>DureeRestantaCourir, List<Double>InteretsPourDureeRestantaCourir ) {
        List<Double>PonderationParMontantsLoyersEtCommissions =  new List<Double>(); 
         Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
         Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode );
        
     //   System.debug('##DureeTotalAvecChantier :  ' + DureeTotalAvecChantier  + ' Nbperiode ' + Nbperiode + 'DureeRestantaCourir Size ' + DureeRestantaCourir.size()  +  'InteretsPourDureeRestantaCourir ' + InteretsPourDureeRestantaCourir.size())  ;
       /* if( DureeTotalAvecChantier == Nbperiode ){
            for(Integer i = 0 ; i < Nbperiode + 1  ; i++  )  {
                 Double temp = 0;
                 Double temp2 = 0;
                 for(Integer z = i ; z < Nbperiode + 1 ; z++) {
                     temp = temp + (  1 * DureeRestantaCourir.get(z) ) ;
                     temp2 = 1 + temp2;
                 }
                 Decimal temp3 = temp / temp2;
                                
                 if(i == 0) {
                      PonderationParMontantsLoyersEtCommissions.add(temp3.round(System.RoundingMode.UP) );
                 }
                 else {
                      PonderationParMontantsLoyersEtCommissions.add(temp3  );
                 } 
             }            
        }
        else { */
            for(Integer i = 0 ; i < DureeTotalAvecChantier + 1  ; i++  )  {
                 Double temp = 0;
                 Double temp2 = 0;
                 Double IPDRC=0;
                 for(Integer z = i ; z < DureeTotalAvecChantier + 1  ; z++) {
                    IPDRC=InteretsPourDureeRestantaCourir.get(z);
                     temp +=  ( IPDRC * DureeRestantaCourir.get(z) ) ;
                     temp2 += IPDRC;
                 }
                Decimal temp3= 0;
                if (  InteretsPourDureeRestantaCourir.get(i) != 0 ) {
                    if(temp2 != 0) {
                      temp3  = temp / temp2;
                    }else {
                         temp3  = temp ;
                    }
                }
                if(i == 0) {
                      PonderationParMontantsLoyersEtCommissions.add(temp3.round(System.RoundingMode.UP) );
                }else {
                      PonderationParMontantsLoyersEtCommissions.add(temp3  );
                } 
             }//for
       //}
       return   PonderationParMontantsLoyersEtCommissions; 
        
    }

  
    public static  List<Double> setEncoursBrutVR (String ModeCalculROE,Double Nbperiode,  Double DureeDuChantierMois, List<Double>ResultatCalculPhaseChantier, Double VR) {
        List<Double>EncoursBrutVR =  new List<Double>(); 
        Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
        Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode );
        for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
             EncoursBrutVR.add(ResultatCalculPhaseChantier.get(i) - VR );
         } 
        return EncoursBrutVR;
    }
    
    
    public static  List<Double>  setProtection (String ModeCalculROE,Double Nbperiode,  Double DureeDuChantierMois, List<Double>ResultatCalculPhaseChantier, double PourcentageRisqueBPCE ) {
        List<Double>Protection =  new List<Double>();
        Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
        Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode );
        for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
             Protection.add(-ResultatCalculPhaseChantier.get(i) * PourcentageRisqueBPCE );
         } 
       return  Protection;
    }
  public static  List<Double> setEADApresGarantieIRBA(String ModeCalculROE,Double Nbperiode,  Double DureeDuChantierMois, List<Double>ResultEncoursBrutVR, List<Double> ResultProtection ) {
        List<Double>EADApresGarantieIRBA = new List<Double>(); 
         Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
         Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
         for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
         //Defect EL corriection
         /*    if( ResultEncoursBrutVR.get(i) < 0) {
                 EADApresGarantieIRBA.add( ResultProtection.get(i) ); 
             } else {
                EADApresGarantieIRBA.add( ResultEncoursBrutVR.get(i) + ResultProtection.get(i) );     
             } */
             if( (ResultEncoursBrutVR.get(i) + ResultProtection.get(i)) < 0) {
                 EADApresGarantieIRBA.add( 0 ); 
             } else {
                EADApresGarantieIRBA.add( ResultEncoursBrutVR.get(i) + ResultProtection.get(i) );     
             }
             
         } 
         return EADApresGarantieIRBA;
    
     }
    
     public static   List<Double> setEADApresGarantieSTD(String ModeCalculROE,Double Nbperiode,  Double DureeDuChantierMois, List<Double>ResultEncoursBrutVR, List<Double> ResultProtection ) {
      
        List<Double>EADApresGarantieSTD =  new List<Double>();
         Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
         Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
         for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  {  
             if( (ResultEncoursBrutVR.get(i) + ResultProtection.get(i)) < 0 ) {
                 EADApresGarantieSTD.add( 0 );
             }  else {
                 EADApresGarantieSTD.add( ResultEncoursBrutVR.get(i) + ResultProtection.get(i) );
             }
         }  
         return EADApresGarantieSTD;
     } 
    
  public static   List<Double> setM(List<Double> ResultPonderationParMontantsLoyersEtCommissions, Double Nbperiode,  Double DureeDuChantierMois) {
         Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
         Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
         List<Double> M =  new  list<Double>() ;
        
        for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
            if(ResultPonderationParMontantsLoyersEtCommissions.get(i) > 5) {
                M.add(5);
            } else if((ResultPonderationParMontantsLoyersEtCommissions.get(i) > 1)&&(ResultPonderationParMontantsLoyersEtCommissions.get(i) < 5)) {
                M.add(ResultPonderationParMontantsLoyersEtCommissions.get(i));
            }  else {
                M.add(1);
            }
         }//for 
      return M ;
    }   
    public static  double setR( Double ResultNotation ) {  
        return (0.12*((1-Math.exp(-50*(ResultNotation/100) )))) + 0.24*(1-(1-Math.exp(-50*(ResultNotation/100)))/(1-Math.exp(-50)));
    }
      public static  double setB( Double ResultNotation ) {
     Double B = 0; 
        if(ResultNotation > 0) { 
            double a = 0.11852-0.05478*Math.log((ResultNotation/100));
            B = Math.pow( a,2);
        } else {
            B= 0;
        }
       
    return B;
    }
    
    public static List<Double> setFPDM( Double ResultNotation, Double ResultB, Double ResultR, List<Double> ResultM, Double Nbperiode,  Double DureeDuChantierMois ) {
      Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
      Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
       List<Double> FPDM =  new  list<Double>() ;
            double pow = 0.5;
            double varDec= 0.999;
        for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  {  
            FPDM.add( (( LoiNormal( Math.pow(1-ResultR,(Double)(-0.5)) * NormaleStdInverse((ResultNotation/100)) + ( Math.pow( ResultR/(1-ResultR),pow) ) * NormaleStdInverse(varDec) ) -(ResultNotation/100) )  ) * ((1+(ResultM.get(i)-2.5)*ResultB)/(1-1.5*ResultB))  );
        }
      return FPDM;
    }
  public static double LoiNormal(double z) {
       double f;
       double u;
       double s;
       double t;
       double s1;
       double res;
 
       u = z * z;
       if (u > 55.5) {
           if (z > 0) {
               res = 1;
           }
           else {
               res = 0;
           }
       }
 
       else {
          s = 0;
          t = 1;
          f = 3;
          do {
             s1 = s;
             s = s + t;
             t = t * u / f;
             f = f + 2;
          }while (s != s1);
           double para = 0.5;
          res = z * s / Math.pow((8 * Math.atan(1) * Math.exp(u)) , para) + 0.5;
       }
       return res;
    }
    public static double NormaleStdInverse(double fProb)   { 
           Double cdEPSILON    = 0.0000001;
           Integer ciMaxIter    = 50;
           Double dMax =0;
           Double dMin=0; 
           Double dCalcZ=0; 
           Integer i =0; 
           Boolean bSign = false; 
         
           Double gcUMax   = 55.5;
           Double gcInvNCRMax   = 99;
           Double NormaleStdInverse = 0;
        
        If(  fProb <= 0 ) {
              NormaleStdInverse = -gcInvNCRMax ;
        } 
        else if( fProb >= 1) {
             NormaleStdInverse = gcInvNCRMax ;
        }
        else { 
           dMin = -Math.sqrt(gcUMax);
            If( fProb > 0.5) {
                  fProb = 1 - fProb;
                 bSign = True;
            }   
        
            While ((Math.Abs(dMax - dMin) >= cdEPSILON)&&(i < ciMaxIter )) {
                dCalcZ = (dMax + dMin) * 0.5;
                    
                If (LoiNormal(dCalcZ) < fProb) {
                    dMin = dCalcZ;
                }
                else {
                      dMax = dCalcZ;
                }  
                 i = i + 1;                   
            }  
           if(bSign == true){
                NormaleStdInverse = -dCalcZ;
            }
            else {
                 NormaleStdInverse =  dCalcZ ;
            }
             
       } 
        return NormaleStdInverse;
    }
   
        public static list<Double>  PartRembourseSurInvestissement(Double DureeDuChantierMois, list<Double> ResultatCalculPhaseChantier, Double MontantFinance  ) { 
          list<Double>   PartRembourseSurInvestissement = new  list<Double>();
           for(Integer i=0; i < ResultatCalculPhaseChantier.size() ; i++ ) {
                PartRembourseSurInvestissement.add( ( 1- (ResultatCalculPhaseChantier.get(i) / MontantFinance)));
          }
        return  PartRembourseSurInvestissement; 
    }
    // Calculette.UsageROE__c,  Calculette.LocatisationROE__c,   Calculette.TypeContrepartie__c,  AvancePreneur,  MontantFinance,  ResultPartRembourseSurInvestissement
    // 06/10/2015 Limite SOQL ValeurTauxAmortissement__c 
  /*  public static List<Double>   LGDActualise( String Usage, String Localisation,  String TypeContrepartie, Double AvancePreneur, Double MontantFinance, List<Double> ResultPartRembourseSurInvestissement ) {  
      List<BddRoe__c> ReqValeurTauxAmortissement = new List<BddRoe__c>();
       List<Double> LGDActualise = new List<Double>(); 
     
      Double  VerificationPourcAmortBien = AvancePreneur / MontantFinance;
      Double ValeurTauxAmortissement = 0;
      Boolean IsSup = false;

      for(BddRoe__c ItemReqCurrentBddRoe: [ Select  ValeurTauxAmortissement__c, LGD__c  FROM BddRoe__c WHERE RecordType.DeveloperName= 'LGD'  AND Localisation__c =: Localisation AND TypeContrepartie__c =:  TypeContrepartie AND Usage__c =: Usage  AND ValeurTauxAmortissement__c  !=  null ]){
         if(ItemReqCurrentBddRoe.ValeurTauxAmortissement__c !=  null ){
                 ValeurTauxAmortissement = ItemReqCurrentBddRoe.ValeurTauxAmortissement__c;  
         } 
      }  
      for (Integer i =0 ; i < ResultPartRembourseSurInvestissement.size(); i++) {
          if( ResultPartRembourseSurInvestissement.get(i) < (ValeurTauxAmortissement/100) )  {
              IsSup = false;
            
          }
          else if ( ResultPartRembourseSurInvestissement.get(i) >= (ValeurTauxAmortissement/100) ) {
              IsSup = true;
          }
          LGDActualise.add(setLGDFromExistingRate(Localisation, TypeContrepartie, Usage, ValeurTauxAmortissement, IsSup  ) ); 
      }
      
      return LGDActualise;
  }*/
    public static List<Double>   LGDActualise( String Usage, String Localisation,  String TypeContrepartie, Double AvancePreneur, Double MontantFinance, List<Double> ResultPartRembourseSurInvestissement ) {  
      List<BddRoe__c> ReqValeurTauxAmortissement = new List<BddRoe__c>();
       List<Double> LGDActualise = new List<Double>(); 
     
      Double  VerificationPourcAmortBien = AvancePreneur / MontantFinance;
      Double ValeurTauxAmortissement = 0;
      Boolean IsSup = false; 
        
      Map<String, Double> MapLimiteTauxAmortissementLGD = new Map<String, Double>();
  
      for(BddRoe__c ItemReqCurrentBddRoe: [ Select  ValeurTauxAmortissement__c, LGD__c,LimiteTauxAmortissement__c  
                                           FROM BddRoe__c 
                                           WHERE RecordType.DeveloperName= 'LGD'  
                                           AND Localisation__c =: Localisation 
                                           AND TypeContrepartie__c =:  TypeContrepartie 
                                           AND Usage__c =: Usage  
                                           AND ValeurTauxAmortissement__c  !=  null ]){
         if(ItemReqCurrentBddRoe.ValeurTauxAmortissement__c !=  null ){
                 ValeurTauxAmortissement = ItemReqCurrentBddRoe.ValeurTauxAmortissement__c; 
                 MapLimiteTauxAmortissementLGD.put(ItemReqCurrentBddRoe.LimiteTauxAmortissement__c, ItemReqCurrentBddRoe.LGD__c); 
         } 
      }  
      for (Integer i =0 ; i < ResultPartRembourseSurInvestissement.size(); i++) {
          if( ResultPartRembourseSurInvestissement.get(i) < (ValeurTauxAmortissement/100) )  {
              //IsSup = false;
             LGDActualise.add(MapLimiteTauxAmortissementLGD.get('<'));
          }
          else if ( ResultPartRembourseSurInvestissement.get(i) >= (ValeurTauxAmortissement/100) ) {
              LGDActualise.add(MapLimiteTauxAmortissementLGD.get('>'));
          }
         // LGDActualise.add(setLGDFromExistingRate(Localisation, TypeContrepartie, Usage, ValeurTauxAmortissement, IsSup  ) ); 
      }
      
      return LGDActualise;
  }
 
 /*   
 //Zed - 23/3/17 - Mise en commentaire de cette méthode qui ne semble plus être utilisée
  public static Double setLGDFromExistingRate(String Localisation, String TypeContrepartie, String Usage, Double ValeurTauxAmortissement, Boolean IsSup  ) {
        Double VerificationPourcAmortBien=0;
        Double LGD = 0;
    
        List<BddRoe__c> ReqLGD = new List<BddRoe__c>();
       
        
        if(IsSup )  {
           ReqLGD = [ Select  LGD__c 
             FROM BddRoe__c 
             WHERE RecordType.DeveloperName= 'LGD'
             AND LimiteTauxAmortissement__c = '>'
             AND Localisation__c =: Localisation
             AND TypeContrepartie__c =:  TypeContrepartie
             AND Usage__c =: Usage
             AND ValeurTauxAmortissement__c =: ValeurTauxAmortissement
            ] ;
        }
        else {
            ReqLGD = [ Select  LGD__c 
             FROM BddRoe__c 
             WHERE RecordType.DeveloperName= 'LGD'
             AND LimiteTauxAmortissement__c = '<'
             AND Localisation__c =: Localisation
             AND TypeContrepartie__c =:  TypeContrepartie
             AND Usage__c =: Usage
             AND ValeurTauxAmortissement__c =: ValeurTauxAmortissement
            ] ;
        }
        
        for(BddRoe__c ItemReqCurrentBddRoe: ReqLGD){
              if(ItemReqCurrentBddRoe.LGD__c !=  null ){
                LGD = ItemReqCurrentBddRoe.LGD__c;  
                } 
        }         
        return LGD;
    }*/
    
    public static List<Double>  setRW( List<Double> ResultLGDActualise, List<Double> ResultFPDM, Double Nbperiode,  Double DureeDuChantierMois , Double ScallingFactor) {
         Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
         Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
         List<Double> RW =  new  list<Double>() ;
         for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  {  
            RW.add( (12.5 * (ResultLGDActualise.get(i)  / 100) * ResultFPDM.get(i) * ScallingFactor) );
           System.debug('@Cedd1 ResultLGDActualise ' + ResultLGDActualise.get(i)/100 + '  ResultFPDM.get(i)  ' +  ResultFPDM.get(i)  + ' ScallingFactor '+ ScallingFactor);
        }
      return RW;
  } 
  public static List<Double> setK( List<Double> ResultLGDActualise, List<Double> ResultFPDM, Double Nbperiode,  Double DureeDuChantierMois , Double ScallingFactor) {
         Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
         Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
         List<Double> K =  new  list<Double>() ;
         for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  {  
            K.add( (ScallingFactor *   (ResultLGDActualise.get(i)/100) * ResultFPDM.get(i)) );
        }
    return K;
  
  } 
public static List<Double> setRWALoyer( List<Double> ResultRW, List<Double> ResultEADApresGarantieIRBA, Double Nbperiode,  Double DureeDuChantierMois) {
         Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
         Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
         List<Double> RWALoyer =  new  list<Double>() ;
         for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
             if(ResultEADApresGarantieIRBA.get(i)  < 0) {
                 RWALoyer.add( 0 );
             }  else { 
                 RWALoyer.add( (ResultEADApresGarantieIRBA.get(i) * ResultRW.get(i) ) );  
             } 
        }
     return RWALoyer; 
  }
 
    
    public static List<Double> setRWARVR( List<Double> ResultDureeRestantaCourir,  Double ValeurResiduelle, Double Nbperiode,  Double DureeDuChantierMois ) {
       Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
       Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
       
        List<Double> RWARVR =  new  list<Double>() ;
        for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  {  
             if(ResultDureeRestantaCourir.get(i)  == 0) {
                 RWARVR.add( 0 );
             }  else { 
                //!\ RWARVR.add( (ValeurResiduelle * 10000000 * ( 1 / ResultDureeRestantaCourir.get(i) )) );     
                 RWARVR.add( (ValeurResiduelle  * ( 1 / ResultDureeRestantaCourir.get(i) )) );     
             } 
        } 
      return RWARVR;
   }
    public static List<Double>  setRWACreditPeriodique( List<Double> ResultRWARVR,List<Double> ResultRWALoyer, List<Double>ResultEncoursBrutVR, Double Nbperiode,  Double DureeDuChantierMois, Double Periodicite, String RepGarant,  Double PourcentageEnrisqueCom) {
            Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
           Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode );  
            List<Double> RWACreditPeriodique =  new  list<Double>() ;
            for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
                 if( RepGarant!= 'direct') {
               //    RWACreditPeriodique.add( (ResultRWARVR.get(i) * 0.75 * (1 - (ResultEncoursBrutVR.get(i) / 100) ))/Periodicite);
                
                 RWACreditPeriodique.add( (ResultRWARVR.get(i) * 0.75 * (1 - (PourcentageEnrisqueCom / 100) ))/Periodicite);
                   
                 } else {
                    // RWACreditPeriodique.add( (ResultRWARVR.get(i) * 0.75 * (100 -PourcentageEnrisqueCom  ))/Periodicite);
                    RWACreditPeriodique.add((ResultRWARVR.get(i) + ResultRWALoyer.get(i) )/Periodicite);
                 }
            } 
         return RWACreditPeriodique;
     }      
    
  public  static List<Double> setRWACreditPeriodiqueActualise( List<Double> ResultRWACreditPeriodique, Double Nbperiode,  Double DureeDuChantierMois, Double TauxRefiPeriodique ) {
        Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
       Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
       
        List<Double> RWACreditPeriodiqueActualise =  new  list<Double>() ;
        for(Integer i = 0 ; i < ResultRWACreditPeriodique.size()   ; i++  )  {   
        //    System.debug('RWACreditPeriodiqueActualise : ' + res);
            RWACreditPeriodiqueActualise.add ( (ResultRWACreditPeriodique.get(i)*Math.pow((1+TauxRefiPeriodique), -(i+1))) );
        } 
     return  RWACreditPeriodiqueActualise;
 }
   
    
    public  static List<Double> setInteretCalculRisqueOperationnels ( Double Nbperiode,  Double DureeDuChantierMois , List<Double>  PreLoyersNetRefi , List<Double>  RemunerationTVA, List<Double> CommissionDeNonUtilisation, List<Double>  CommissionEngagement, List<Double> InteretsPourRisqueOperationel) {
         List<Double> InteretCalculRisqueOperationnels  =  new  list<Double>() ;
         Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
         Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
         if(DureeDuChantierMois > 0 ) {  
             for(Integer i = 0 ; i < DureeDuChantierTrimestre   ; i++  )  { 
                 if(i <=  (DureeDuChantierMois/3) ) { 
                     Double Total = 0;
                      if(i < 1) {
                         Total +=  RemunerationTVA[0];
                     }
                     if(PreLoyersNetRefi.size() >= i ) {
                         Total +=  PreLoyersNetRefi[i];
                     }
                     if(CommissionDeNonUtilisation.size() >= i ) {
                         Total +=  CommissionDeNonUtilisation[i];
                     }
                     if(CommissionEngagement.size() >= i ) {
                         Total += CommissionEngagement[i];
                     } 
                     InteretCalculRisqueOperationnels.add ( Total  );
                 }    
             }//for
             for(Integer i = 0 ; i < Nbperiode   ; i++  )  { 
                        InteretCalculRisqueOperationnels.add ( InteretsPourRisqueOperationel[i]  ); 
             }
        }//if
        return  InteretCalculRisqueOperationnels ;
    }
   
    //12-12-2015
  public  static List<Double> setRWARisqueOperationnel( List<Double> MargeActualisee, List<Double> CommissionsDeRisqueActualisees, List<Double> ResultinteretsCalculRisqueOperationnels, Double CommissionApportFlat, Double Nbperiode,  Double DureeDuChantierMois , Double periodicite) {
        Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
       Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
       
        List<Double> RWARisqueOperationnel  =  new  list<Double>() ;
        Double DureeDecaissement = 0;
      if(DureeDuChantierMois > 0 ) {
          DureeDecaissement = ResultinteretsCalculRisqueOperationnels.size();
      } else {
          DureeDecaissement = CommissionsDeRisqueActualisees.size()  ;
      } 
      
        for(Integer i = 0 ; i < DureeDecaissement   ; i++  )  { 
            if(DureeDuChantierMois > 0) {
                RWARisqueOperationnel.add (  (0.15 * 12.5 * ResultinteretsCalculRisqueOperationnels[i] ) / periodicite   );    
            }else {
                 
             if( i == 0) {
                    RWARisqueOperationnel.add ( (0.15 * 12.5 * ( ( MargeActualisee[i] - CommissionApportFlat - CommissionsDeRisqueActualisees[i]    ) / periodicite) ));       
              }else {
                  if(i < MargeActualisee.size() ){
                        RWARisqueOperationnel.add ( (0.15 * 12.5 * ( ( MargeActualisee[i]  - CommissionsDeRisqueActualisees[i]    ) / periodicite) ));       
                  } else {
                        RWARisqueOperationnel.add ( (0.15 * 12.5 * ( (  - CommissionsDeRisqueActualisees[i]    ) / periodicite) ));       
                  }
                  
               } 
            }//if
        } //for
     return  RWARisqueOperationnel;
 }
public static List<Double> setRWARisqueOperationActualise (List<Double> ResultRWARisqueOperation, Double TxRefiPeriodique, Double Nbperiode,  Double DureeDuChantierMois ) {
            Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
            Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
       
        List<Double> RWARisqueOperationActualise  =  new  list<Double>() ;
        for(Integer i = 0 ; i < ResultRWARisqueOperation.size()   ; i++  )  {  
           RWARisqueOperationActualise.add ( ResultRWARisqueOperation[i] * Math.pow((1+TxRefiPeriodique), (i+1)*-1 ))  ;
        }
       
        return RWARisqueOperationActualise;
}
    
    
public static List<Double> setRWAAvecRisqueOperationnelActualise (List<Double> ResultRWACreditPeriodiqueActualise, List<Double>  ResultRWARisqueOperationActualise, Double Nbperiode,  Double DureeDuChantierMois ) {
       Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
       Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
       
        List<Double> RWAAvecRisqueOperationnelActualise  =  new  list<Double>() ;
        for(Integer i = 0 ; i < ResultRWARisqueOperationActualise.size()    ; i++  )  { 
            if(ResultRWACreditPeriodiqueActualise.size() > i ) {
                RWAAvecRisqueOperationnelActualise.add ( ResultRWACreditPeriodiqueActualise[i] + ResultRWARisqueOperationActualise[i] )  ;
            }else {
                RWAAvecRisqueOperationnelActualise.add ( ResultRWARisqueOperationActualise[i] )  ;
            }
           
        }
       
        return RWAAvecRisqueOperationnelActualise;
}
public static Double setTotalRWAAvecRisqueOperationnelActualise(List<Double> RWAAvecRisqueOperationnelActualise, Double Nbperiode,  Double DureeDuChantierMois ) {
       Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
       Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
       
       Double ResultTotalRWAAvecRisqueOperationnelActualise  = 0 ;
        for(Integer i = 0 ; i < RWAAvecRisqueOperationnelActualise.size()   ; i++  )  {
           ResultTotalRWAAvecRisqueOperationnelActualise += RWAAvecRisqueOperationnelActualise[i] ;
        }
       
        return ResultTotalRWAAvecRisqueOperationnelActualise;
}
public static Double setTotalRWAMoyenIRBA(Double ResultTotalRWAAvecRisqueOperationnelActualise, Double Nbperiode,  Double DureeDuChantierMois ) {
      Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
       Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
    
    Double RWAMoyenIRBA;
     
         if(( DureeTotalAvecChantier == Nbperiode)&&(DureeDuChantierTrimestre > 0)) {
            RWAMoyenIRBA = ResultTotalRWAAvecRisqueOperationnelActualise / DureeDuChantierTrimestre;
         }else {
              RWAMoyenIRBA = ResultTotalRWAAvecRisqueOperationnelActualise / (DureeTotalAvecChantier/4);
         } 
        return RWAMoyenIRBA;
}
public static  List<Double>  setEL(List<Double> EAD, List<Double> LGD,  List<Double> PDpuisPDSP, Double  Nbperiode, Double DureeDuChantierMois ) {     
    Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
      Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
    
    List<Double> EL = new  List<Double>();
      
     for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
         //Defect EL
         if(EAD.get(i) < 0){
           EL.add(0);  
         }else {
             EL.add( (EAD.get(i) *(  LGD.get(i)/100 ) * PDpuisPDSP.get(i))/4   );
         }
           
        }
        
    return EL;
}
public static  List<Double>  setELActualise(List<Double> EL, Double  Nbperiode, Double DureeDuChantierMois, Double TauxRefiPeriodique  ) {     
    Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
      Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
    
    List<Double> ELActu = new  List<Double>();
      
     for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  {  
           ELActu.add( EL.get(i) *  Math.pow((1+TauxRefiPeriodique), -(i+1)) );
        }
        
    return ELActu;
}    
public static  Double   setELTotal(List<Double> ELActu, Double  Nbperiode, Double DureeDuChantierMois   ) {     
      Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
      Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
    
    Double ELActuTotal = 0;
      
     for(Integer i = 0 ; i < ELActu.size()   ; i++  )  {  
          ELActuTotal += ELActu[i] ;
         // System.debug(' EL TOTAL ' +  ELActuTotal  );    
        }
        
    return (-1*ELActuTotal);
}        
    
    public static   List<Double>     setFondsPropresNormatifActualise (List<Double> RWAAvecRisqueOperationnelActualise, Double PerBesoinsFP,  Double  Nbperiode, Double DureeDuChantierMois  ) {
       List<Double>   FondsPropresNormatifActualise = new  List<Double>();
       Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
       Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
        
         for(Integer i = 0 ; i < RWAAvecRisqueOperationnelActualise.size()   ; i++  )  {  
           FondsPropresNormatifActualise.add( RWAAvecRisqueOperationnelActualise.get(i) * PerBesoinsFP );
        }
        
        return FondsPropresNormatifActualise;
    }
    public static   Double   setTotalFondsPropresNormatifActualise (  List<Double> FondsPropresNormatifActualise, Double EncoursMoyen,  String RepGarant ) {
        Double TotalFondsPropresNormatifActualise=0;
        
        if(RepGarant == 'Direct' ) {
            TotalFondsPropresNormatifActualise = 0.07 * 0.75 * EncoursMoyen * (0.1 - 0) ;
        } else {
            for(integer i=0; i < FondsPropresNormatifActualise.size() ; i++) {
                TotalFondsPropresNormatifActualise += FondsPropresNormatifActualise[i];
            }
        } 
        return TotalFondsPropresNormatifActualise;
    }
    
    
    
     public static   List<Double>   setRemunerationFPN (List<Double> RWAAvecRisqueOperationnelActualise, Double PerBesoinsFP, Double TauxRefiFP, Double  Nbperiode, Double DureeDuChantierMois  ) {
     List<Double>   RemunerationFPN = new  List<Double>();
       Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
       Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
        for(Integer i = 0 ; i < RWAAvecRisqueOperationnelActualise.size()   ; i++  )  {  
           RemunerationFPN.add( RWAAvecRisqueOperationnelActualise.get(i) * PerBesoinsFP * TauxRefiFP );
        }
        
        return RemunerationFPN;
     
     }
 public static  Double   setRemunerationFPN(List<Double> RemunerationFPN, Double  Nbperiode, Double DureeDuChantierMois   ) {     
      Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
      Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode ); 
    
    Double TotalRemunerationFPN = 0;
      
     for(Integer i = 0 ; i < RemunerationFPN.size()   ; i++  )  {  
          TotalRemunerationFPN += RemunerationFPN[i] ;
        }
        
    return ( TotalRemunerationFPN);
}  
 public static  Double   CoutExploitationActualisesIRBA(Double RemunerationFPN, Double  MargeFinanciereBrutActualisee, Double CoutExploitation   ) { 
    return ( ( (-1*MargeFinanciereBrutActualisee)  + (-1* RemunerationFPN) ) * (CoutExploitation / 100) ) ;
}  
public static Double setPNBIRBA(  Double ResultMargeActualiseeTotal, Double FraisDeDossier,  Double ResultCommissionsDeRisque, Double CommissionApportFlat,  Double ResultAutrePNBTotal, Double RemunerationFPN ) {
     return ( ResultMargeActualiseeTotal + FraisDeDossier + ResultCommissionsDeRisque - CommissionApportFlat +  ResultAutrePNBTotal + RemunerationFPN ) ;                           
}  
public static Double  setResultatAvantImpotIRBA(  Double ResultMargeActualiseeTotal, Double FraisDeDossier, Double ResultCommissionsDeRisque, Double CommissionApportFlat,  Double ResultAutrePNBTotal, Double ResultCoutExploitationIRBA, Double EL, Double TotalRemunerationFPN ) {
        return ResultMargeActualiseeTotal + FraisDeDossier + ResultCommissionsDeRisque - CommissionApportFlat +  ResultAutrePNBTotal  + ResultCoutExploitationIRBA +  EL + TotalRemunerationFPN;                            
   }    
    
    public static Double  setBesoinsFPMoyenIRBA (Double TotalFondsPropresNormatifActualise, Double Nbperiode, Double Periodicite, String RepGarant) {
        Double BesoinsFPMoyenIRBA =0;
        Double DureeAnnee = Nbperiode / Periodicite;
         if(RepGarant == 'Direct') {
                BesoinsFPMoyenIRBA = 0;
         } else { 
            BesoinsFPMoyenIRBA = (TotalFondsPropresNormatifActualise / DureeAnnee);
         } 
        return     BesoinsFPMoyenIRBA;
    }
  
public static Double  setROEMoyenAvantImpotIRBA(  Double MargeNetteIRBA, Double Nbperiode, Double BesoinFPMoyen, Double Periodicite) {
    Double  ROEMoyenAvantImportIRBA = 0;
    Double DureeAnnee = Nbperiode / Periodicite;
    if(MargeNetteIRBA < 10 ) {
        ROEMoyenAvantImportIRBA = 0;
    } else if(BesoinFPMoyen == 0){
        ROEMoyenAvantImportIRBA =0 ;
    } else {
        ROEMoyenAvantImportIRBA = (  MargeNetteIRBA/ DureeAnnee  / BesoinFPMoyen  );
    }
        
    return  (ROEMoyenAvantImportIRBA*100);                          
   }      
    
public static Double  setROEMoyenApresImpotIRBA(  Double ResultatAvantImpotIRBA, Double Nbperiode, Double BesoinFPMoyen, Double Periodicite) {
    Double  ROEMoyenApresImpotIRBA = 0;
    Double DureeAnnee = Nbperiode / Periodicite;
    if(ResultatAvantImpotIRBA < 10 ) {
        ROEMoyenApresImpotIRBA = 0;
    } else if(BesoinFPMoyen == 0){
         ROEMoyenApresImpotIRBA = 0;
    } else {
         ROEMoyenApresImpotIRBA = (  ResultatAvantImpotIRBA/ DureeAnnee  / BesoinFPMoyen  );
    }
    return  (ROEMoyenApresImpotIRBA*100);                           
   }    
    
    
public static  List<Double>    setValeurDuBienDiv2VR  (String ModeCalculROE,Double Nbperiode,  Double DureeDuChantierMois, Double VR,  Double ResultValeurDuBien ) {
        List<Double>    ValeurDuBienDiv2VR  =  new List<Double>(); 
        Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
        Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode );
        for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
         ValeurDuBienDiv2VR.add((ResultValeurDuBien / 2)- VR) ;
        } 
        return ValeurDuBienDiv2VR; 
}
    
public static  List<Double> setPartie50VRStd (String ModeCalculROE,Double Nbperiode,  Double DureeDuChantierMois, List<Double>ResultEncoursBrutVR, List<Double>ValeurDuBienDiv2VR ) {
        List<Double>Partie50VRStd =  new List<Double>(); 
        Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
        Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode );
        for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
            if(ValeurDuBienDiv2VR[i] > ResultEncoursBrutVR[i] ) {
                Partie50VRStd.add( ResultEncoursBrutVR[i]  * 0.5 );   
            } else if (ValeurDuBienDiv2VR[i] < ResultEncoursBrutVR[i] ) {
               Partie50VRStd.add( ValeurDuBienDiv2VR[i]  * 0.5 );   
            } //if
         } //for
        return Partie50VRStd;
}
public static  List<Double> setPartie100pVRStd (String ModeCalculROE,Double Nbperiode,  Double DureeDuChantierMois, List<Double>ResultEncoursBrutVR, List<Double>ValeurDuBienDiv2VR ) {
        List<Double>Partie100pVRStd =  new List<Double>(); 
        Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
        Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode );
        for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
            if(ValeurDuBienDiv2VR[i] > ResultEncoursBrutVR[i] ) {
                Partie100pVRStd.add( 0 );   
            } else if (ValeurDuBienDiv2VR[i] < ResultEncoursBrutVR[i] ) {
               Partie100pVRStd.add( ResultEncoursBrutVR[i] - ValeurDuBienDiv2VR[i]);   
            } //if
         } //for
        return Partie100pVRStd;
}    

public static  List<Double> setRWAStdPart1 (String ModeCalculROE,Double Nbperiode,  Double DureeDuChantierMois, List<Double>Partie50VRStd, List<Double>Partie100pVRStd, List<Double>RWAVR, Double Periodicite, Double PercDeRisque ) {
        List<Double>RWAStdPart1 =  new List<Double>(); 
        Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
        Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode );
        for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
          RWAStdPart1.add( ( ( (Partie50VRStd[i] + Partie100pVRStd[i])*(1 - PercDeRisque))/Periodicite)+RWAVR[i] );
        } 
    
 return RWAStdPart1;
}
public static  List<Double> setRWAStdPart2 (String ModeCalculROE,Double Nbperiode,  Double DureeDuChantierMois, List<Double>RWAStdPart1, List<Double>ResultEADApresGarantieSTD, Double VR, Double TauxDeRefiSpecifique, Double Periodicite, String RepGarant ) {
    List<Double>RWAStdPart2  =  new List<Double>(); 
        Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
        Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode );
        for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
            if(RepGarant == 'Direct' ) { 
                RWAStdPart2.add( ( ( (ResultEADApresGarantieSTD[i]+VR)*0.75)/Periodicite)*Math.pow((1+TauxDeRefiSpecifique), -(i+1))   );
            } else { 
              RWAStdPart2.add( (RWAStdPart1[i])*Math.pow((1+TauxDeRefiSpecifique), -(i+1)) );
            }         
        }//for 
    
 return RWAStdPart2 ;
}    
    public static   Double  setTotalRWAStdPart2 (List<Double> RWAStdPart2) {
        Double TotalRWAStdPart2  =  0; 
            for(Integer i = 0 ; i < RWAStdPart2.size()   ; i++  )  { 
                TotalRWAStdPart2 += RWAStdPart2.get(i);
            }
        return TotalRWAStdPart2;
    }
      public static   Double  setRWAMoyenStd (Double TotalRWAStdPart2, Double Nbperiode,  Double Periodicite ) { 
        return (TotalRWAStdPart2 / (Nbperiode/Periodicite)) ;
    }
    
     public static   List<Double>   setBesoinsFPMoyenStd(List<Double> RWAStdPart2, Double Nbperiode,  Double DureeDuChantierMois, Double PercBesoinsFP ) {
          List<Double>BesoinsFPMoyenStd  =  new List<Double>(); 
           Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
        Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode );
          for(Integer i = 0 ; i < DureeTotalAvecChantier   ; i++  )  { 
            BesoinsFPMoyenStd.add(RWAStdPart2[i] * PercBesoinsFP) ; 
           } 
         return BesoinsFPMoyenStd;
     }
   
    public static   Double  setTotalBesoinsFPMoyenStd (List<Double> BesoinsFPMoyenStd) {
        Double TotalBesoinsFPMoyenStd  =  0; 
            for(Integer i = 0 ; i < BesoinsFPMoyenStd.size()   ; i++  )  { 
                TotalBesoinsFPMoyenStd += BesoinsFPMoyenStd.get(i);
            }
        return TotalBesoinsFPMoyenStd;
    }
    public static   Double  setBesoinsFPMoyenStdAnnee(Double TotalBesoinsFPMoyenStd, Double Nbperiode,  Double Periodicite  ) { 
        return  (TotalBesoinsFPMoyenStd /(Nbperiode/Periodicite)) ;
    }
    
   public static   List<Double>  setCotationNIE( Integer NbCotation) {
       List<Double>Cotation  =  new List<Double>();  
       
       for(BddRoe__c ItemReqCurrentBddRoe: [ Select Annee__c, Cotation1__c , Cotation2__c , Cotation3__c, Cotation4__c ,
                                            Cotation5__c, Cotation6__c ,Cotation7__c , Cotation8__c, Cotation9__c,
                                            Cotation10__c, Cotation11__c, Cotation12__c, Cotation13__c, Cotation14__c, 
                                            Cotation15__c, Cotation16__c
                                            FROM BddRoe__c 
                                            Where RecordType.DeveloperName = 'GrilleCotation' 
                                           // and SemaineConstatation__c =: SemaineConstatationTaux
                                            Order by Annee__c asc
                                         
                                     ]){
                                         if(NbCotation == 1 ){
                                               Cotation.add(  ItemReqCurrentBddRoe.Cotation1__c ) ;  
                                         }
                                         else if(NbCotation == 2  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation2__c ) ;  
                                         }
                                         else if(NbCotation == 3  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation3__c ) ;  
                                         }
                                           else if(NbCotation == 4  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation4__c ) ;  
                                         }
                                           else if(NbCotation == 5  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation5__c ) ;  
                                         }
                                           else if(NbCotation == 6  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation6__c ) ;  
                                         }
                                           else if(NbCotation == 7  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation7__c ) ;  
                                         }
                                           else if(NbCotation == 8  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation8__c ) ;  
                                         }
                                           else if(NbCotation == 9 ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation9__c ) ;  
                                         }
                                           else if(NbCotation == 10  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation10__c ) ;  
                                         }
                                           else if(NbCotation == 11 ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation11__c ) ;  
                                         }
                                           else if(NbCotation == 12  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation12__c ) ;  
                                         }
                                           else if(NbCotation == 13  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation13__c ) ;  
                                         }
                                           else if(NbCotation == 14  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation14__c ) ;  
                                         }
                                           else if(NbCotation == 15  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation15__c ) ;  
                                         }
                                           else if(NbCotation == 16  ) {
                                              Cotation.add(  ItemReqCurrentBddRoe.Cotation16__c ) ;  
                                         }  
         }  
        return Cotation;
    }
    public static  Integer  setCotationNIO( Integer NbCotation) {
        BddRoe__c ItemReqCurrentBddRoe=[Select RatinRefPD__c,TranscoSPRetail__c 
                                                        FROM BddRoe__c 
                                                        Where RecordType.DeveloperName = 'GrillePD'
                                                        and RatinRefPD__c =: NbCotation LIMIT 1];
        
        return (integer)ItemReqCurrentBddRoe.TranscoSPRetail__c;
            
    }
     public static   List<Double>  setPDSP( Double Periodicite, String TypeDeContrepartie,  List<Double>Cotation, Double PD, Double Nbperiode,  Double DureeDuChantierMois ) {
               Double DureeDuChantierTrimestre = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4; 
        Double DureeTotalAvecChantier = (DureeDuChantierTrimestre + Nbperiode );
         
       List<Double>PDSP  =  new List<Double>();
       //  if(TypeDeContrepartie == 'Corporate' )   {
             if(Periodicite == 12)   {
                 for(integer i = 0; i < 80; i ++) {
                     PDSP.add(PD/100);
                 }//for
             }//if
             else if(Periodicite == 4) {

                 integer boucle = 4; 
              do {
                  
                  if(boucle <= 4) {
                     PDSP.add(PD/100); 
                        PDSP.add(PD/100);
                        PDSP.add(PD/100);
                        PDSP.add(PD/100);
                      
                  }
                 if (boucle > 79){
                      PDSP.add(0);
                      PDSP.add(0);
                      PDSP.add(0);
                      PDSP.add(0);
                 }
                 else if(boucle > (Cotation.size() * 4) ){
                       PDSP.add(Cotation[Cotation.size() - 1]);
                      PDSP.add(Cotation[Cotation.size() - 1]);
                      PDSP.add(Cotation[Cotation.size() - 1]);
                      PDSP.add(Cotation[Cotation.size() - 1]); 
                  }
                else{ 
                         PDSP.add(Cotation[(boucle/4)-1]);
                         PDSP.add(Cotation[(boucle/4)-1]);
                         PDSP.add(Cotation[(boucle/4)-1]);
                         PDSP.add(Cotation[(boucle/4)-1]);  
                     }  
      
                  
               boucle = boucle + 4;
             } while (boucle < (DureeTotalAvecChantier+ 4));
                 //while (boucle < 80);
                 //while (boucle < (DureeTotalAvecChantier+ 4));
             }//else if
       //  }//if
         
        return PDSP;
     }
     public static List<SelectOption> VFPGetSemaineConstatation()    { 
              List<SelectOption>SemaineConstation  =  new List<SelectOption>();  
            
              List<AggregateResult>  ItemReqCurrentBddRoe = [ SELECT SemaineConstatation__c 
                                                    FROM BddRoe__c 
                                                    where SemaineConstatation__c != NULL 
                                                    Group BY SemaineConstatation__c
                                                    ORDER BY SemaineConstatation__c DESC];
                                          
             List<String> semainesTriees = trierListeSemaineConstatation(ItemReqCurrentBddRoe);
                                                
             for( String semaine : semainesTriees){
                           SemaineConstation.add(new SelectOption('' +semaine, ''+ semaine ) );     
            } 
         
            return SemaineConstation;
        
    }

    public static List<String> trierListeSemaineConstatation(List<AggregateResult> semaines){
        
        Map<Integer, List<String>> tempList = new Map<Integer, List<String>>();
        List<String> retList = new List<String>();
        Integer maxIndex = 0;
        Integer currentYear = maxIndex;
          
        for(AggregateResult aggr : semaines){
            if(aggr.get('SemaineConstatation__c') != null){
                String yearToAdd = String.valueOf(aggr.get('SemaineConstatation__c')).substring(3,7);
                String weekToAdd = String.valueOf(aggr.get('SemaineConstatation__c')).substring(0,2);
                currentYear = Integer.valueOf(yearToAdd);
                if(maxIndex<currentYear)
                  maxIndex = currentYear;
                if(tempList.get(currentYear) == null){
                  tempList.put(currentYear,new List<String>());
                }
                tempList.get(currentYear).add(weekToAdd + '-' + yearToAdd);
            }
            
        }

          while(tempList.size() > 0){
            if(tempList.get(maxIndex) != null){
              retList.addAll(tempList.get(maxIndex));
              tempList.remove(maxIndex);
            }
            maxIndex --;
          }

        return retList;
        
    }
    
    public static Map<String ,Double> VFPGetTauxCMSConstation(String SemaineConstation)    {
          Map<String ,Double> Taux = new  Map<String,Double>() ;
          for(BddRoe__c ItemReqCurrentBddRoe: [ Select  TauxCMS12Ans__c, TauxCMS10Ans__c,  TauxCMS15Ans__c,  TauxCMS8Ans__c, TauxCMS9Ans__c
                                             FROM BddRoe__c 
                                             Where TauxCMS12Ans__c != null 
                                             and TauxCMS10Ans__c != null 
                                             and TauxCMS15Ans__c != null 
                                             and TauxCMS8Ans__c != null 
                                             and TauxCMS9Ans__c != null  
                                          //   and  Euribor3mois__c != null 
                                            and SemaineConstatation__c =: SemaineConstation
                                      ]){
                             //  Taux.put('Taux Euribor', ItemReqCurrentBddRoe.Euribor3mois__c );   
                               Taux.put('Taux CMS 8 ans', ItemReqCurrentBddRoe.TauxCMS8Ans__c );  
                               Taux.put('Taux CMS 9 ans', ItemReqCurrentBddRoe.TauxCMS9Ans__c );  
                               Taux.put('Taux CMS 10 ans', ItemReqCurrentBddRoe.TauxCMS10Ans__c );  
                               Taux.put('Taux CMS 12 ans', ItemReqCurrentBddRoe.TauxCMS12Ans__c );  
                               Taux.put('Taux CMS 15 ans', ItemReqCurrentBddRoe.TauxCMS15Ans__c );
         } 
          return Taux;
    }
    public static Map<Integer ,Double> VFPGetTauxFixe(String SemaineConstation)    {
          Map<Integer ,Double> Taux = new  Map<Integer,Double>() ;
          for(BddRoe__c ItemReqCurrentBddRoe: [ Select  TauxFixe__c,   IdRefinancement__c 
                                             FROM BddRoe__c 
                                             Where TauxFixe__c != null 
                                             and IdRefinancement__c != null   
                                            and SemaineConstatation__c =: SemaineConstation
                                      ]){ 
                               Taux.put((Integer)ItemReqCurrentBddRoe.IdRefinancement__c, ItemReqCurrentBddRoe.TauxFixe__c ); 
         } 
          return Taux;
    }
    public static Map<Integer ,Double> VFPGetTauxVariable(String SemaineConstation)    {
          Map<Integer ,Double> Taux = new  Map<Integer,Double>() ;
          for(BddRoe__c ItemReqCurrentBddRoe: [ Select  TauxVariable__c,  IdRefinancement__c 
                                             FROM BddRoe__c 
                                             Where  TauxVariable__c != null 
                                             and IdRefinancement__c != null   
                                             and SemaineConstatation__c =: SemaineConstation
                                      ]){ 
                               Taux.put((Integer)ItemReqCurrentBddRoe.IdRefinancement__c, ItemReqCurrentBddRoe.TauxVariable__c ); 
         } 
          return Taux;
    }

//////////////////////////////////////////// 
///Piste pour envoyer ça par un bouton : 06/10/2015 Limite SOQL
////////////////////////////////////////////
/*public  static Double TotalQuotePartPoolDeGarant(CalculetteROE__c currentCalc) {
    Double TotalQuotePartPoolDeGarant = 0;
    Opportunity PA = [ Select id, TotalQuotePartPoolDeGarant__c from Opportunity where id =:   currentCalc.ProjetAssocie__c  ]; 
    return  PA.TotalQuotePartPoolDeGarant__c;
 } 
public  static Double QuotePartNL(CalculetteROE__c currentCalc) { 
    Opportunity PA = [ Select id, QuotePartNL__c from Opportunity where id =:   currentCalc.ProjetAssocie__c  ]; 
    return  PA.QuotePartNL__c;
 }*/ 
/////////////////////////////////////////////
/////////////////////////////////////////////
public  static String VerifIfExistSemaineConstatation(List<BddRoe__c> bddRoes, List<AggregateResult> semainesBDD){//A
	String newSemaine = '';

    if(bddRoes.size() == 0){
        List<String> semainesTriees = trierListeSemaineConstatation(semainesBDD);
        newSemaine = semainesTriees[0];
	}   
  
    return newSemaine;
 } 
    
    
    public  static Double setROEMoyenAvantImposBPCE(   Double Nbperiode,  Double DureeDuChantierMois,  Double MargeBruteFinanciereActualisee, Double FraisDeDossier, Double CoutsExploitationActualises, Double PNBAdditionnel, Double BesoinFondsPropreMoyenBPCE, Double TotalRemunerationFPNBPCE,Double ELActuTotalBPCE  ) {
        Double Duree = ( Nbperiode  / 4 );
        Double result = 0;
        
        if((BesoinFondsPropreMoyenBPCE == 0)||(Duree==0)) {
            result = 0;
        }else {
            result = ((MargeBruteFinanciereActualisee + FraisDeDossier + CoutsExploitationActualises + PNBAdditionnel + TotalRemunerationFPNBPCE - ELActuTotalBPCE ) / Duree /  BesoinFondsPropreMoyenBPCE) * 100 ;
        }
        
        return result;
    }     
    
    
    public  static Double setROEMoyenApresImpotIRBA( Double Nbperiode,Double MargeBrutActualiseeTotal,Double FraisDeDossier,Double CoutExploitationActualisesIRBA, Double TotalRemunerationFPNBPCE, Double AutresPNB,Double MargeNetIRBABPCE,Double TauxIS ,Double BesoinsFPMoyenIRBABPCE, Double ELActuTotalBPCE) {
        Double Duree = ( Nbperiode  / 4 );    
       double Result = 0;
         if((BesoinsFPMoyenIRBABPCE == 0)||(Duree==0)) {
            Result = 0;
        }else {
            Result = (((MargeBrutActualiseeTotal + FraisDeDossier + CoutExploitationActualisesIRBA + AutresPNB + TotalRemunerationFPNBPCE- ELActuTotalBPCE)*( 1 - TauxIS/100)) / Duree /  BesoinsFPMoyenIRBABPCE) * 100 ;
        }
        
       
        if(MargeNetIRBABPCE < 10 )         {
           Result = 0 ;
        }
       
     return Result ;

    }

}