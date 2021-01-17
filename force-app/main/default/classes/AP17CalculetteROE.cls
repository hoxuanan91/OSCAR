public class AP17CalculetteROE {

  	public static List<CalculetteROE__c> setROE(List<CalculetteROE__c> calculettesNew, List<CalculetteROE__c> calculettesOld) {
       	///////////////////////////////////////////////
		Double CommissionDeRisqueBPouCE						= 0;
		Double TauxCoutExploitation 						= 0;  
		Double ResultLoyerDossier 							= 0;
		Double ResultLoyerAvancePreneur 					= 0;
		Double ResultLoyerPeriodique 						= 0;
		Double ResultLoyerPeriodiqueTotal					= 0;
		Double ResultEncoursDossierTotal					= 0;
		Double ResultMargeActualiseeTotal 					= 0;
		Double ResultatRefinancementEncoursActualiseeTotal 	= 0; 
		Double TxEuribor 									= null; 
		Double TauxIS 										= null;
		Double ScallingFactor 								= null;
		
		List<Double> ResultEncoursDossier 					= new List<Double>();
		List<Double> ResultEncoursAvancePreneur 			= new List<Double>();
		List<Double> ResultAmortissementDossier 			= new List<Double>();
		List<Double> ResultAmortissementAvancePreneur 		= new List<Double>();
		List<Double> ResultInteretDossier 					= new List<Double>();
		List<Double> ResultInteretAvancePreneur 			= new List<Double>();
		List<Double> ResultRefinancementEncours 			= new List<Double>();
		List<Double> ResultRefinancementAmortissement 		= new List<Double>();
		List<Double> ResultRefinancementInteret 			= new List<Double>();
		List<Double> ResultRefinancementLoyer 				= new List<Double>();
		List<Double> ResultRefinancementEncoursActualise 	= new List<Double>();
		List<Double> RefinancementEncoursActualisee 		= new List<Double>();
		List<Double> ResultMargeBrut 						= new List<Double>();
		List<Double> ResultMargeActualisee 					= new List<Double>();
		List<Double> ResultCotation 						= new List<Double>();
               
      
         
		//05/10/2015 Merge des fonctions pour cause de limite SOQL
		/*TauxCoutExploitation = Ctrl01_CalculetteROE.getCoutExploitation();  
		TauxIS = Ctrl01_CalculetteROE.getTauxIS();              
		ScallingFactor = Ctrl01_CalculetteROE.getScalingFactor();  
		*/
		List<Double> CoutExploitationCoutCTTauxISScalingFactor = new List<Double>();
		CoutExploitationCoutCTTauxISScalingFactor = Ctrl01_CalculetteROE.getCoutExploitationCoutCTTauxISScalingFactor();
		
		TauxCoutExploitation 	= CoutExploitationCoutCTTauxISScalingFactor[0];  
		TauxIS 					= CoutExploitationCoutCTTauxISScalingFactor[2];              
		ScallingFactor 			= CoutExploitationCoutCTTauxISScalingFactor[3];
		
		System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
      
		//////////////////////////////////////
		///////////A CHECKER /////////////////
		//////////////////////////////////////
		system.debug('@@ONPASSE ICI 1');
		System.debug('Final number of script statements used so far : ' + Limits.getDmlStatements());
		System.debug('Final heap size: ' + Limits.getHeapSize());      
		System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());      
		System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
      
		Map<Id, CalculetteROE__c> oldsMap = new Map<Id, CalculetteROE__c>();
		CalculetteROE__c[] UpdatedCalculette = new  List<CalculetteROE__c>();
		Map<String, List<BddRoe__c>> bddRoeByCalculetteSemaine = new Map<String, List<BddRoe__c>>();//A
		Map<String, List<BddRoe__c>> moreBddRoeByCalculetteSemaine = new Map<String, List<BddRoe__c>>();//A -> PERTINENCE ???
		for(CalculetteROE__c calcNew : calculettesNew){
			bddRoeByCalculetteSemaine.put(calcNew.SemaineConstatationTaux__c, new List<BddRoe__c>());//A
			moreBddRoeByCalculetteSemaine.put(calcNew.SemaineConstatationTaux__c, new List<BddRoe__c>());//A
			for(CalculetteROE__c calcOld : calculettesOld){
				if(calcNew.Id == calcOld.Id){
					oldsMap.put(calcNew.Id, calcOld);
				}
			}
		}

		System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
		////////////////////////////////////////
		////////////////////////////////////////
		////////////////////////////////////////

		System.debug('CALCULETTE SEMAINES TAUX : ' + bddRoeByCalculetteSemaine.keySet());//A
		System.debug('CALCULETTE ID : ' + moreBddRoeByCalculetteSemaine.keySet());//A

		List<BddRoe__c> bddRoeCoutLiquidite = new List<BddRoe__c>([SELECT TauxVariable__c,
																		Euribor3mois__c,
																		TauxCMS8Ans__c,
																		TauxCMS9Ans__c,
																		TauxCMS10Ans__c,
																		TauxCMS12Ans__c,
																		TauxCMS15Ans__c,
																		IdRefinancement__c,
																		SemaineConstatation__c
																	FROM BddRoe__c
																	WHERE (TauxVariable__c != null OR
																		Euribor3mois__c != null OR
																		TauxCMS8Ans__c != null OR
																		TauxCMS9Ans__c != null OR
																		TauxCMS10Ans__c != null OR
																		TauxCMS12Ans__c != null OR
																		TauxCMS15Ans__c != null) AND
																		SemaineConstatation__c != null AND
																		SemaineConstatation__c IN :bddRoeByCalculetteSemaine.keySet()]);//A

		System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());

		list<BddRoe__c> taux = new List<BddRoe__c>([SELECT A__c,
															AMoins__c,
															Aplus__c,
															AA__c,
															AAMoins__c,
															AAplus__c,
															AAA__c,
															B__c,
															BMoins__c,
															BPlus__c,
															BB__c,
															BBMoins__c,
															BBplus__c,
															BBB__c,
															BBBMoins__c,
															BBBplus__c,
															C__c,
															CC__c,
															CCC__c,
															CCCMoins__c,
															CCCPlus__c,
															DX__c,
															BpNatixisNIO__c,
															CeNatixisNIO__c,
															BpceNatixisNIEComptesSociaux__c,
															RatinRefPD__c,
															LGD__c,
															TypeContrepartie__c,
															Usage__c,
															Localisation__c,
															ValeurTauxAmortissement__c,
															LimiteTauxAmortissement__c
													FROM BddRoe__c
													WHERE RecordType.DeveloperName = 'GrilleTTR' OR
													RecordType.DeveloperName = 'GrillePD' OR
													RecordType.DeveloperName= 'LGD']);

		System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());

		List<BddRoe__c> allBddRoe = new List<BddRoe__c>([SELECT SemaineConstatation__c
														FROM BddRoe__c
														WHERE SemaineConstatation__c != null AND
															SemaineConstatation__c IN :moreBddRoeByCalculetteSemaine.keySet()]);//A-> PERTINENCE ???

		List<AggregateResult> semainesBDD = new List<AggregateResult>([SELECT SemaineConstatation__c 
																		FROM BddRoe__c 
																		WHERE SemaineConstatation__c != null 
																		Group BY SemaineConstatation__c
																		ORDER BY SemaineConstatation__c DESC]);//A

		System.debug('BDDROE COUT LIQUIDITE : ' + bddRoeCoutLiquidite);
		System.debug('BDDROE ALL : ' + allBddRoe);
		System.debug('SEMAINES : ' + semainesBDD);

		System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
      
        for(CalculetteROE__c Calculette : calculettesNew) {
			//CalculetteROE__c Calculette= calcNew ;
			CalculetteROE__c calculetteOld = oldsMap.get(Calculette.Id);
    
                        
            //Pour pallier le clonnage et le changement du temps de refi automatiquement : Ex refi spécifique to Refi  NL
			if(Calculette.TypeTauxRefinancement__c == 'Taux refi NL') {
				Calculette.TauxRefinancementNL__c = null;
			}      
            if(Calculette.ForwardChantier__c == null){
                Calculette.ForwardChantier__c = 0;
			}
			
			for(BddRoe__c bdd : bddRoeCoutLiquidite){//A
				if(bdd.SemaineConstatation__c == Calculette.SemaineConstatationTaux__c){
					if(bddRoeByCalculetteSemaine.get(Calculette.SemaineConstatationTaux__c) != null){
						bddRoeByCalculetteSemaine.get(Calculette.SemaineConstatationTaux__c).add(bdd);
					}
					if(moreBddRoeByCalculetteSemaine.get(Calculette.SemaineConstatationTaux__c) != null){
						moreBddRoeByCalculetteSemaine.get(Calculette.SemaineConstatationTaux__c).add(bdd);
					}
					if(Calculette.TypeDeTaux__c == 'Taux fixe'){
						Double annee = Calculette.DureeEnTrimestre__c / 4;
						if(bdd.IdRefinancement__c == annee){
							Calculette.CoutDeLiquidite_refi__c = bdd.TauxVariable__c + Calculette.ForwardChantier__c;
						}
					}
					else if(Calculette.TypeDeTaux__c == 'Taux variable Euribor 3 mois'){
						Calculette.CoutDeLiquidite_refi__c = bdd.Euribor3mois__c + Calculette.ForwardChantier__c;
					}
					else if(Calculette.TypeDeTaux__c == 'Taux CMS 8 ans'){
						Calculette.CoutDeLiquidite_refi__c = bdd.TauxCMS8Ans__c + Calculette.ForwardChantier__c;
					}
					else if(Calculette.TypeDeTaux__c == 'Taux CMS 9 ans'){
						Calculette.CoutDeLiquidite_refi__c = bdd.TauxCMS9Ans__c + Calculette.ForwardChantier__c;
					}
					else if(Calculette.TypeDeTaux__c == 'Taux CMS 10 ans'){
						Calculette.CoutDeLiquidite_refi__c = bdd.TauxCMS10Ans__c + Calculette.ForwardChantier__c;
					}
					else if(Calculette.TypeDeTaux__c == 'Taux CMS 12 ans'){
						Calculette.CoutDeLiquidite_refi__c = bdd.TauxCMS12Ans__c + Calculette.ForwardChantier__c;
					}
					else if(Calculette.TypeDeTaux__c == 'Taux CMS 15 ans'){
						Calculette.CoutDeLiquidite_refi__c = bdd.TauxCMS15Ans__c + Calculette.ForwardChantier__c;
					}
				}
			}//A

			System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
            
            Double TotalQuotePartPoolDeGarant 	= 0;
			Double OldQuotiteContreGarantie 	= 0;
			
            if(Calculette.RecordType.DeveloperName == 'CBICalculetteROELectureSeule'){  
				OldQuotiteContreGarantie = calculetteOld.QuotiteContreGarantie__c;
				Double NewQuotiteContreGarantie =  Calculette.QuotiteContreGarantie__c;
				Calculette.QuotiteContreGarantie__c = NewQuotiteContreGarantie;    
			}
			
			Calculette.SemaineConstatationTaux__c = Ctrl01_CalculetteROE.VerifIfExistSemaineConstatation(moreBddRoeByCalculetteSemaine.get(Calculette.SemaineConstatationTaux__c), semainesBDD);//A

			System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
			
            Double DureeAnnee 		= 0.000;
            Double EncoursMoyen 	= 0.0001;
            Double TauxVenteEchu  	= 0.0001;
            
			// /!\ peridocite au dynamique
			String ModeCalculROE 					= null;
			Integer Nbperiode 						= 1;
			Boolean Avenant							= false;
            Double Periodicite 						= 4;
            Double PeriodiciteCalculDesCouts 		= 3;
            Double DureeDuChantierMois  			= 0.0001;
            Double VREuro  							= 0.0001;
            Double MontantFinance  					= 0.0001;
            Double TauxRemunerationAP 				= 0.0001;
            Double TauxDeRefi						= 0.0001;
            Double AvancePreneur					= 0.0001;
            Double  TauxVenteClient 				= 0.0001;
            Double TauxRemunerationAvancePreneur 	= 0.0001;
            Double FraisDeDossier					= 0.0001;
            Double PremierTiragePhaseChantier 		= 0.0001;
            Double SpreadRemunerationPreloyersTVA 	= 0.0001;
            Double SpreadRemunerationPreloyers 		= 0.0001;
            Double MontantTVA 						= 0.0001;
            Double PourcentageCommissionEngagement	= 0.0001;
            Double CommissionNonUtilisationEnSpread	= 0.0001;
			Double ValeurDuBien 					= 0.0001; 
            Double EncoursTotalDuDossier 			= 0.0001;
            Double TriTEASansAvance 				= 0.0001;
            Double TriTEAAvecAvance					= 0.0001;
            Double TriITESansAvance 				= 0.0001;
            Double TriITEAvecAvance 				= 0.0001;
			
			//ARRET ICI
            Double CommissionDeRisqueBPCE 				= Calculette.TauxCommissionRisqueSurEncours__c;
			Double PourcentageEnrisqueCom 				= (Calculette.QuotiteContreGarantie__c/100);
			Double ELActuTotal 							= 0;
            Double EncoursMoyenDeOperation 				= 0;
            Double MargeBrutActualiseeTotal 			= 0;
            Double ResultCommissionsDeRisque 			= 0;
			Double CommisionDeRisque 					= 0;
			Double PNBPreLoyers 						= 0;
            Double AutresPNB							= 0;
            Double PNBStandard 							= 0;
            Double ResultatAvantImpotStandard 			= 0;     
            Double ResultatMargeNetStandard 			= 0;
            Double ROEMoyenApresImpotIRBA 				= 0;       
            Double ROEMoyenAvantImpotIRBA 				= 0;
            Double  MargeCommercialApresLiquiditeITE 	= 0;
            Double MargeApresAVPR 						= 0;
            Double PNBIRBA 								= 0;
            Double CoutExploitationActualisesIRBA 		= 0;
            Double ResultatAvantImpotIRBA 				= 0;
            Double MargeNetIRBA 						= 0;
            Double TotalFondsPropresNormatifActualise 	= 0;
			Double BesoinsFPMoyenIRBA 					= 0;
			
			List<Double> EL 										= new List<Double>();
            List<Double> ELActualise 								= new List<Double>();						   
			List<Double> ResultCommissionsDeRisqueBrute 			= new List<Double>();
            List<Double> ResultCommissionsDeRisqueBruteActualisee 	= new List<Double>();
            List<Double> CoutsDexploitationActualises 				= new List<Double>();
            List<Double> ResultatCalculPhaseChantier 				= new List<Double>(); 
            List<Double> ResultPhaseDeDecaissement 					= new List<Double>(); 
            List<Double> ResultMontantNonTire 						= new List<Double>();
            List<Double> ResultPreLoyersNetRefi						= new List<Double>();
            List<Double> ResultPreLoyersNetRefiActualise 			= new List<Double>();
            
            
            List<Double> TauxRemunerationFPandPercBesoinsEnFP = new List<Double>();
            TauxRemunerationFPandPercBesoinsEnFP = Ctrl01_CalculetteROE.getTauxRemunerationFPandPercBesoinsEnFP(Calculette.SemaineConstatationTaux__c);
            Double PerBesoinsFP 		= TauxRemunerationFPandPercBesoinsEnFP[1];
            Double TauxRemunerationFP 	= TauxRemunerationFPandPercBesoinsEnFP[0]; 
			
			System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());

            ///Onglet chantier
            Double ResultValeurDuBien 	= 0;
            Double ValeurResiduelle 	= 0;  
            Double TauxRefiPeriodique 	= 0;
			Double TauxDeRefiDossier 	= 0;
			
			List<Double> ResultInteretsPourRisqueOperationel 	= new List<Double>();
            List<Double> ResultInteretsPourDureeRestantaCourir 	= new List<Double>();
            List<Integer> ResultDureeRestantaCourir				= new List<Integer>();
            List<Double> ResultPartRembourseSurInvestissement	= new List<Double>();
            List<Double> ResultLGDActualise						= new List<Double>();
            List<Double> ResultRemunerationTVA 					= new List<Double>();
          
                 //////////////////////////Onglet Calcul RWA //////////////////////////////////////////
			List<Double> ResultPonderationParMontantsLoyersEtCommissions 	= new List<Double>();
			List<Double> ResultEncoursBrutVR 								= new List<Double>();
			List<Double> ResultProtection  									= new List<Double>();
			List<Double> ResultEADApresGarantieIRBA 						= new List<Double>();
			List<Double> ResultEADApresGarantieSTD 							= new List<Double>();
			List<Double> ResultFPDM 										= new List<Double>();
			List<Double> ResultRW 											= new List<Double>(); 
			List<Double> ResultK 											= new List<Double>();
			List<Double> ResultRWALoyer 									= new List<Double>();
			List<Double> ResultRWARVR 										= new List<Double>();
			List<Double> ResultRWACreditPeriodique 							= new List<Double>();
			List<Double> ResultRWACreditPeriodiqueActualise 				= new List<Double>();
			List<Double> ResultinteretsCalculRisqueOperationnels 			= new List<Double>();
			List<Double> ResultRWARisqueOperation 							= new List<Double>();
			List<Double> ResultRWARisqueOperationActualise 					= new List<Double>();
			List<Double> ResultRWAAvecRisqueOperationnelActualise 			= new List<Double>();
			List<Double> ResultM 											= new List<Double>();
			List<Double> ResultCommissionDeNonUtilisation 					= new List<Double>();
			List<Double> ResultCommissionEngagement 						= new List<Double>();
			List<Double> FondsPropresNormatifActualise 						= new List<Double>();                        
			List<Double> RemunerationFPN									= new List<Double>();
			List<Double> ValeurDuBienDiv2VR 								= new List<Double>();
			List<Double> Partie50VRStd 										= new List<Double>();
			List<Double> Partie100pVRStd 									= new List<Double>();
			List<Double> RWAStdPart1 										= new List<Double>();
			List<Double> RWAStdPart2 										= new List<Double>();
			List<Double> BesoinsFPMoyenStd 									= new List<Double>();

			Double PD     											= 0; 
			Double LGD    											= 0;
			Double ResultR   										= 0; 
			Double ResultB   										= 0;
			Double ResultTotalRWAAvecRisqueOperationnelActualise 	= 0;
			Double ResultRWAMoyenIRBA  								= 0;
			Double TotalRemunerationFPN 							= 0;
			Double TotalRWAStdPart2 								= 0;
			Double RWAMoyenStd  									= 0;
			Double TotalBesoinsFPMoyenStd   						= 0;
			Double BesoinsFPMoyenStdAnnee 							= 0;
			Double ROEMoyenAvantImpotStd 							= 0;
			Double ROEMoyenApresImpotStd 							= 0;
			Double DureePreloyersTVA 								= 0;
			Double TauxVenteClientTEA 								= 0;
            
                    
            if(Calculette.ModeDeCalcul__c != null){
                ModeCalculROE = Calculette.ModeDeCalcul__c;
            } 
            
            if(Calculette.AvancePreneur__c != null){
                AvancePreneur = (Double)Calculette.MontantAVPRQPNL__c;
                
                if(Calculette.RecordType.DeveloperName == 'CBICalculetteROELectureSeule') { 
                    if(Calculette.QuotePartNL__c != null){
                    AvancePreneur = (Double)(Calculette.AvancePreneur__c * Calculette.QuotePartNL__c ) / 100;          
					} 
					else{
                        AvancePreneur = Calculette.AvancePreneur__c;
                    }
                } 
            }
            if(Calculette.Avenant__c != null  ){
                Avenant = Calculette.Avenant__c;
            }
            if(Calculette.Montant_Brut_de_la_QP_NL__c != null &&  Calculette.Montant_Brut_de_la_QP_NL__c != 0){
               MontantFinance = (Double)Calculette.Montant_Brut_de_la_QP_NL__c;  
            }
            if(Calculette.DureeEnTrimestre__c != null){
                Nbperiode = (Integer)Calculette.DureeEnTrimestre__c;
            }            
            if(Calculette.FraisDeDossier__c != null){
                FraisDeDossier = (Double)Calculette.FraisDeDossier__c;// Dans calculette saisie par commercial 
            }
            if(Calculette.DureeDuChantierMois__c != null){
                DureeDuChantierMois = (Double)Calculette.DureeDuChantierMois__c; 
            }
            if(Calculette.PremierTiragePhaseChantier__c != null){
                PremierTiragePhaseChantier = (Double)Calculette.PremierTiragePhaseChantier__c;  
            }
            if(Calculette.ValeurResiduelle__c != null){
                VREuro = (Double)Calculette.Montant_VR_QP_NL_Simulation__c;
                if(Calculette.RecordType.DeveloperName == 'CBICalculetteROELectureSeule') {
                    VREuro = (Double)Calculette.MontantVRQPNL__c;    
                } 
            }
            if(Calculette.PremierTiragePhaseChantier__c != null){
                PremierTiragePhaseChantier = (Double)Calculette.PremierTiragePhaseChantier__c;  
            }
            if(Calculette.SpreadRemunerationPreloyersTVA__c != null){
                SpreadRemunerationPreloyersTVA = (Double)Calculette.SpreadRemunerationPreloyersTVA__c;
            }
            if(Calculette.SpreadRemunerationPreloyers__c != null){
                SpreadRemunerationPreloyers =  (Double)Calculette.SpreadRemunerationPreloyers__c;
            }
            if(Calculette.MontantTVA__c != null){
                MontantTVA = (Double)Calculette.MontantTVA__c;
            }
            if(Calculette.PreloyersEngagementPerc__c != null){
                PourcentageCommissionEngagement = (Double)Calculette.PreloyersEngagementPerc__c;
                if(DureeDuChantierMois < 1) {
                    PourcentageCommissionEngagement = 0; 
                }   
            }
            if(Calculette.CommissionNonUtilisationEnSpread__c != null){
                CommissionNonUtilisationEnSpread =  (Double)Calculette.CommissionNonUtilisationEnSpread__c;
            }
            if(Calculette.ValeurDuBien__c != null){
                ValeurDuBien =  (Double)Calculette.ValeurDuBien__c;
            }
            if(Calculette.EncoursTotalDuDossier__c != null){
            	EncoursTotalDuDossier =  (Double)Calculette.EncoursTotalDuDossier__c;
            }
            if(Calculette.DureePreloyersTVA__c != null){
                DureePreloyersTVA = (Double)decimal.valueOf(Calculette.DureePreloyersTVA__c);
            } 
            if((MontantTVA != null) && (SpreadRemunerationPreloyersTVA != null) && (DureePreloyersTVA != null) && (ModeCalculROE != null) &&
				(MontantFinance != null) && (Nbperiode != null ) && (AvancePreneur != null) && (Calculette.TauxRemunerationAvancePreneur__c != null) &&
				(Nbperiode != null) && (FraisDeDossier != null) && (Periodicite != null) &&
				(Calculette.TypeContrepartie__c != null) && (Calculette.BaseNotation__c != null) &&
				(Ctrl01_CalculetteROE.checkAbilitationRCalcul(Calculette.TypeDeTaux__c, (Double)Calculette.SpreadIndex365360__c, (Double)Calculette.SpreadCMS__c, (Double)Calculette.TauxVenteClientNominal__c) != false)){
					
				System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
				/////////////////////////////////////////////////////
				/////////////////// Taux Euribor ////////////////////
				/////////////////////////////////////////////////////
				if(Calculette.TypeDeTaux__c == 'Taux variable Euribor 3 mois'){
					TxEuribor = Ctrl01_CalculetteROE.getTxEuribor(bddRoeByCalculetteSemaine.get(Calculette.SemaineConstatationTaux__c)); 
					Calculette.Euribor3mois__c = TxEuribor;  
					TauxVenteClient = (TxEuribor + (Double)Calculette.SpreadIndex365360__c) * 365 / 360; 

					if(TauxVenteClient != null) {
						TauxVenteEchu = (TauxVenteClient / 100) / Periodicite;
					}
					TauxRemunerationAvancePreneur = (TxEuribor + Calculette.TauxRemunerationAvancePreneur__c) * 365 / 360;   
					Double DureeAnnee2 = (Double)(Nbperiode / 4); 
					Integer dureeAnneeRounded = (Integer)DureeAnnee2.round();
					
					TauxDeRefi = Ctrl01_CalculetteROE.getTauxRefi(TxEuribor, Calculette.TypeDeTaux__c, dureeAnneeRounded, bddRoeByCalculetteSemaine.get(Calculette.SemaineConstatationTaux__c)); 
					System.debug('@CedRefi > ' + TauxDeRefi);
					Calculette.CoutDeLiquidite__c = TauxDeRefi;
					System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
				}
				else if((Calculette.TypeDeTaux__c == 'Taux CMS 8 ans') || (Calculette.TypeDeTaux__c == 'Taux CMS 12 ans') || (Calculette.TypeDeTaux__c == 'Taux CMS 9 ans') || (Calculette.TypeDeTaux__c == 'Taux CMS 10 ans') || (Calculette.TypeDeTaux__c == 'Taux CMS 15 ans')){
					TxEuribor = Ctrl01_CalculetteROE.getTxEuribor(bddRoeByCalculetteSemaine.get(Calculette.SemaineConstatationTaux__c)); 
					
					Calculette.TauxCMSSemaine__c = Ctrl01_CalculetteROE.getTauxCMSSemaine(Calculette.TypeDeTaux__c, bddRoeByCalculetteSemaine.get(Calculette.SemaineConstatationTaux__c));
					
					if((Calculette.SpreadCMS__c != null) && (Calculette.TauxCMSSemaine__c != null)){
						TauxVenteClient = (Double)Calculette.SpreadCMS__c + (Double)Calculette.TauxCMSSemaine__c;
						TauxRemunerationAvancePreneur = Calculette.TauxRemunerationAvancePreneur__c + (Double)Calculette.TauxCMSSemaine__c;
					}
					if(TauxVenteClient != null) {
						TauxVenteEchu = (TauxVenteClient / 100) / Periodicite;
					}
					///Le processus   Cout liquidé CMS  se comporte comme celui Euribor, pour des soucis de temps On met en parramètre le Taux variable Euribor 3 mois
					Double DureeAnnee2 			= (Double)(Nbperiode / 4); 
					Integer dureeAnneeRounded 	= (Integer)DureeAnnee2.round();

					TauxDeRefi = Ctrl01_CalculetteROE.getTauxRefi(TxEuribor, 'Taux variable Euribor 3 mois', dureeAnneeRounded, bddRoeByCalculetteSemaine.get(Calculette.SemaineConstatationTaux__c)); 
					System.debug('@CedRefi > '+ TauxDeRefi + ' ' + TxEuribor + ' ' + dureeAnneeRounded);
					Calculette.CoutDeLiquidite__c = TauxDeRefi;
					System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
				}
				else{
					TxEuribor = Ctrl01_CalculetteROE.getTxEuribor(bddRoeByCalculetteSemaine.get(Calculette.SemaineConstatationTaux__c));    
					TauxVenteClient = (Double)Calculette.TauxVenteClientNominal__c;
					TauxVenteEchu = (TauxVenteClient / 100) / Periodicite;
					TauxRemunerationAvancePreneur = Calculette.TauxRemunerationAvancePreneur__c; 
					Calculette.CoutDeLiquidite__c = null;
					System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
				}
				///////////////////////////////////////////////////////////////////
				/////////////////// Taux Variable /////////////////////////////////
				///////////////////////////////////////////////////////////////////
				if ((Calculette.TauxRefinancementNL__c == null) || 
					(calculetteOld.TauxRefinancementNL__c != Calculette.TauxRefinancementNL__c) || 
					(calculetteOld.DureeEnTrimestre__c != Calculette.DureeEnTrimestre__c) || 
					(Calculette.TypeDeTaux__c != calculetteOld.TypeDeTaux__c) || 
					(Calculette.SemaineConstatationTaux__c != calculetteOld.SemaineConstatationTaux__c)){
					
					DureeAnnee = (Double)Nbperiode / 4; 
					System.debug(LoggingLevel.INFO, '@jaucent3 ' + MontantFinance + ' ' + VREuro + ' ' + MontantFinance);
					if((MontantFinance != 0) && (VREuro / MontantFinance) >= 0.10  ) {
						DureeAnnee = DureeAnnee + 1 ; 
					} 
                    ///Defect Nombre année n'existe pas dans la grille de refinancement :
                    Double DureeAnnee2 = (Double)DureeAnnee; 
                    DureeAnnee = (Integer)DureeAnnee2.round();
                        
                   	TauxDeRefi = 0;     
                   	TauxDeRefi = Ctrl01_CalculetteROE.getTauxRefi(TxEuribor, Calculette.TypeDeTaux__c,  DureeAnnee, bddRoeByCalculetteSemaine.get(Calculette.SemaineConstatationTaux__c)); 
					Calculette.TauxRefinancementNL__c = TauxDeRefi;
					System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
                }
                else{
                    TauxDeRefi = Calculette.TauxRefinancementNL__c; 
                }
                Calculette.TauxDeRefinancementOperation__c = TauxDeRefi;   
                TauxRefiPeriodique = ((TauxDeRefi / Periodicite) / 100) ;   
                            
                ///////////////////////////////////Taux de Refi Spécifique pour Taux FIXE  & CMS///////////////////////            
				if((Calculette.TCISemaineTxRefiCEBPTxRefiSpe__c != null) && 
					((Calculette.TypeTauxRefinancement__c == 'Taux refi spécifique') || 
					(Calculette.TypeTauxRefinancement__c == 'Taux refi spécifique - CE/BP')) && 
					(Calculette.TypeDeTaux__c == 'Taux fixe')){
					
					TauxRefiPeriodique = ((Calculette.TCISemaineTxRefiCEBPTxRefiSpe__c / Periodicite) / 100);
					TauxDeRefi = Calculette.TCISemaineTxRefiCEBPTxRefiSpe__c / 100; 
					Calculette.TauxDeRefinancementOperation__c = TauxDeRefi * 100;
				}
				else if((Calculette.TCISemaineTxRefiCEBPTxRefiSpe__c != null) && 
					((Calculette.TypeTauxRefinancement__c == 'Taux refi spécifique') || 
					(Calculette.TypeTauxRefinancement__c == 'Taux refi spécifique - CE/BP')) && 
					((Calculette.TypeDeTaux__c == 'Taux CMS 8 ans') || 
					(Calculette.TypeDeTaux__c == 'Taux CMS 9 ans') || 
					(Calculette.TypeDeTaux__c == 'Taux CMS 10 ans') || 
					(Calculette.TypeDeTaux__c == 'Taux CMS 12 ans') || 
					(Calculette.TypeDeTaux__c == 'Taux CMS 15 ans'))){
					if((Calculette.SpreadCMS__c != null) && (Calculette.TauxCMSSemaineSpecifique__c != null) && (Calculette.TCISemaineTxRefiCEBPTxRefiSpe__c != null)){
						TauxVenteClient = (Calculette.TauxCMSSemaineSpecifique__c + (Double)Calculette.SpreadCMS__c  ); 
						TauxVenteEchu = ( TauxVenteClient / 100 ) / Periodicite;
						TauxDeRefi = Calculette.TCISemaineTxRefiCEBPTxRefiSpe__c ;
						TauxRefiPeriodique =   ((TauxDeRefi/Periodicite)/100)  ;
						TauxRemunerationAvancePreneur = (Calculette.TauxCMSSemaineSpecifique__c  + Calculette.TauxRemunerationAvancePreneur__c) ; 
						Calculette.TauxRefinancementNL__c = ( Calculette.TCISemaineTxRefiCEBPTxRefiSpe__c + TxEuribor );
						Calculette.TauxCMSSemaine__c = Calculette.TauxCMSSemaineSpecifique__c;
						Calculette.TauxDeRefinancementOperation__c  = TauxDeRefi;
					}
				}
				else{
                    TauxRefiPeriodique = (TauxDeRefi/ Periodicite) /100 ;  
                }
				TauxDeRefiDossier = TauxDeRefi ;
				if((Calculette.TypeDeTaux__c == 'Taux variable Euribor 3 mois') && 
					(Calculette.Euribor3moisSpecifique__c != null) && 
					((Calculette.TypeTauxRefinancement__c == 'Taux refi spécifique') || 
					(Calculette.TypeTauxRefinancement__c == 'Taux refi spécifique - CE/BP')) && 
					(Calculette.CoutDeLiquidite__c != null)){
					
					TauxDeRefi = 0;    
					TxEuribor = Calculette.Euribor3moisSpecifique__c; 
					Calculette.Euribor3mois__c = TxEuribor;
					TauxVenteClient = ((Calculette.Euribor3moisSpecifique__c + (Double)Calculette.SpreadIndex365360__c ) * 365 / 360) ; 
					TauxVenteEchu = (TauxVenteClient / 100) / Periodicite;
					
					Calculette.CoutDeLiquidite__c = Calculette.TCISemaineTxRefiCEBPTxRefiSpe__c; 
					Calculette.TauxRefinancementNL__c = (Calculette.CoutDeLiquidite__c + Calculette.Euribor3moisSpecifique__c) * 365 / 360;
					TauxDeRefi = ((Calculette.TCISemaineTxRefiCEBPTxRefiSpe__c + Calculette.Euribor3moisSpecifique__c) * 365 / 360); 
					TauxRefiPeriodique = ((TauxDeRefi) / 100 / Periodicite);  
					TauxDeRefiDossier = TauxDeRefi; 
					TauxRemunerationAvancePreneur = ((TxEuribor + Calculette.TauxRemunerationAvancePreneur__c) * 365 / 360); 
					//Modification 12/10/2015 
					//Modif Nico 03/03/16
					//Calculette.TauxDeRefinancementOperation__c  = Calculette.TCISemaineTxRefiCEBPTxRefiSpe__c  ;
					Calculette.TauxDeRefinancementOperation__c = TauxDeRefi;
					System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
				} 

                /////////////////////////////////// Next /////////////////////////////////// 
				// /!\    TauxRemunerationAP = ((TauxRemunerationAvancePreneur ) / Periodicite)
				TauxRemunerationAP = ((TauxRemunerationAvancePreneur ) / Periodicite) / 100;     
				Double TauxVenteActuariel = Math.pow(TauxVenteEchu + 1, Periodicite) - 1;
				Double TauxRefiActuariel = Math.pow((TauxDeRefi / Periodicite) + 1, Periodicite) - 1;  
				Double dureeDecaissement = (DureeDuChantierMois * 0.08333333333333333333333333333333) * 4;  
				if(MontantFinance == 0){
					ValeurResiduelle = VREuro;
				}
				else{
					ValeurResiduelle = VREuro / MontantFinance;
				} 
                ///////////////////////Onglet Marge Actualisé + PNB    ////////////////////////////////////////////////
      
                ResultRemunerationTVA.add(Ctrl01_CalculetteROE.setRemunerationTVA(MontantTVA, TxEuribor, SpreadRemunerationPreloyersTVA, DureePreloyersTVA));
                ResultLoyerDossier 					= Ctrl01_CalculetteROE.setResultLoyerDossier(ModeCalculROE, MontantFinance, TauxVenteEchu, Nbperiode, VREuro); 
                ResultLoyerAvancePreneur 			= Ctrl01_CalculetteROE.setLoyerAvancePreneur(ModeCalculROE, TauxRemunerationAP, AvancePreneur, Nbperiode);
				ResultLoyerPeriodique 				= Ctrl01_CalculetteROE.setLoyerPeriodique(ModeCalculROE, ResultLoyerDossier, ResultLoyerAvancePreneur, Nbperiode);
				ResultLoyerPeriodiqueTotal 			= Ctrl01_CalculetteROE.setLoyerPeriodiqueTotal(ModeCalculROE, ResultLoyerPeriodique, Nbperiode); 
				ResultEncoursDossier 				= Ctrl01_CalculetteROE.setEncoursDossier(ModeCalculROE, MontantFinance, ResultLoyerDossier, TauxVenteEchu, Nbperiode);
				ResultEncoursDossierTotal			= Ctrl01_CalculetteROE.setEncoursDossierTotal(ResultEncoursDossier, Nbperiode);
				ResultEncoursAvancePreneur 			= Ctrl01_CalculetteROE.setEncoursAvancePreneur(ModeCalculROE, AvancePreneur, ResultLoyerAvancePreneur, TauxRemunerationAP, Nbperiode);
				ResultAmortissementDossier 			= Ctrl01_CalculetteROE.setAmourtissementDossier(ModeCalculROE, MontantFinance, ResultEncoursDossier, Nbperiode);
				ResultAmortissementAvancePreneur 	= Ctrl01_CalculetteROE.setAmourtissementAvancePreneur(ModeCalculROE, AvancePreneur, ResultEncoursAvancePreneur, Nbperiode);
				ResultInteretDossier 				= Ctrl01_CalculetteROE.setInteretDossier(ModeCalculROE,ResultLoyerDossier, ResultAmortissementDossier, Nbperiode);
				ResultInteretAvancePreneur 			= Ctrl01_CalculetteROE.setInteretAvancePreneur(ModeCalculROE, ResultLoyerAvancePreneur, ResultAmortissementAvancePreneur, Nbperiode);
				ResultRefinancementEncours 			= Ctrl01_CalculetteROE.setRefinancementEncours(ModeCalculROE, ResultEncoursDossier, ResultEncoursAvancePreneur, Nbperiode);
				RefinancementEncoursActualisee 		= Ctrl01_CalculetteROE.setRefinancementEncoursActualise(ModeCalculROE, ResultRefinancementEncours, TauxRefiPeriodique, Nbperiode);
				System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
                if(Calculette.TypeDeTaux__c == 'Taux variable Euribor 3 mois'){
                    EncoursMoyen = Ctrl01_CalculetteROE.setEncoursMoyen(ResultRefinancementEncours, Nbperiode);
                }
                else{
                    EncoursMoyen = Ctrl01_CalculetteROE.setEncoursMoyen(ResultRefinancementEncours, Nbperiode);
                }
           
				ResultRefinancementAmortissement 			= Ctrl01_CalculetteROE.setRefinancementAmortissement(ModeCalculROE, ResultAmortissementDossier, ResultAmortissementAvancePreneur, Nbperiode, VREuro);
				ResultRefinancementInteret 					= Ctrl01_CalculetteROE.setRefinancementInteret(ModeCalculROE, ResultRefinancementEncours, TauxRefiPeriodique, Nbperiode, AvancePreneur, MontantFinance);
				ResultRefinancementLoyer 					= Ctrl01_CalculetteROE.setRefinancementLoyer(ModeCalculROE, ResultRefinancementAmortissement, ResultRefinancementInteret, Nbperiode);
				EncoursMoyenDeOperation 					= Ctrl01_CalculetteROE.setEncoursMoyenDeOperation(ModeCalculROE, ResultRefinancementEncours, TauxRefiPeriodique, Nbperiode);
				ResultMargeBrut 							= Ctrl01_CalculetteROE.setMargeBrut(ModeCalculROE, ResultRefinancementLoyer, ResultLoyerDossier, ResultLoyerAvancePreneur, Nbperiode, VREuro);
				ResultMargeActualisee 						= Ctrl01_CalculetteROE.setMargeBrutActualisee(ModeCalculROE, ResultMargeBrut, TauxRefiPeriodique, DureeDuChantierMois, ResultLoyerAvancePreneur, Nbperiode);       
				MargeBrutActualiseeTotal 					= Ctrl01_CalculetteROE.setMargeBrutActualiseeTotal(ModeCalculROE, ResultMargeActualisee, Nbperiode);
				ResultCommissionsDeRisqueBrute 				= Ctrl01_CalculetteROE.setCommissionsDeRisqueBrute(ModeCalculROE,CommissionDeRisqueBPCE, PeriodiciteCalculDesCouts, Nbperiode, MontantFinance, AvancePreneur, ResultEncoursDossier, ResultEncoursAvancePreneur);
				ResultCommissionsDeRisqueBruteActualisee 	= Ctrl01_CalculetteROE.setResultCommissionsDeRisqueBruteActualisee(ModeCalculROE, ResultCommissionsDeRisqueBrute, Periodicite, Nbperiode, TauxRefiPeriodique, DureeDuChantierMois);
				ResultCommissionsDeRisque 					= Ctrl01_CalculetteROE.setResultCommissionsDeRisque(ModeCalculROE, ResultCommissionsDeRisqueBruteActualisee, Periodicite, Nbperiode, TauxRefiPeriodique, DureeDuChantierMois);
				CommisionDeRisque 							= ResultCommissionsDeRisque * PourcentageEnrisqueCom;
				ResultatCalculPhaseChantier 				= Ctrl01_CalculetteROE.setCalculPhaseChantier(MontantFinance, AvancePreneur, ResultEncoursDossier, ResultRefinancementEncours, dureeDecaissement);
				ResultPhaseDeDecaissement 					= Ctrl01_CalculetteROE.setPhaseDeDecaissement(MontantFinance, AvancePreneur, PremierTiragePhaseChantier, dureeDecaissement);  
				ResultMontantNonTire 						= Ctrl01_CalculetteROE.setMontantNonTire(ResultatCalculPhaseChantier, ResultPhaseDeDecaissement, dureeDecaissement);  
				ResultPreLoyersNetRefi 						= Ctrl01_CalculetteROE.setPreLoyersNetRefi(ResultPhaseDeDecaissement, dureeDecaissement, SpreadRemunerationPreloyers, (Double)CoutExploitationCoutCTTauxISScalingFactor[1]); 
				ResultPreLoyersNetRefiActualise  			= Ctrl01_CalculetteROE.setPreLoyersNetRefiActualise(dureeDecaissement, ResultPreLoyersNetRefi, TauxRefiPeriodique); 
				PNBPreLoyers 								= Ctrl01_CalculetteROE.setPNBPreLoyers(dureeDecaissement, ResultPreLoyersNetRefi, TauxRefiPeriodique);
				System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
				//Actualisation de la marge brut avec l'ajout du pnb
				MargeBrutActualiseeTotal 					= Ctrl01_CalculetteROE.setMargeBrutActualiseeTotalPlusPnBPreloyer(ModeCalculROE, MargeBrutActualiseeTotal, PNBPreLoyers);
				CoutsDexploitationActualises  				= Ctrl01_CalculetteROE.setCoutExploitation(TauxCoutExploitation, MargeBrutActualiseeTotal);     
				
				System.debug('@Cedici2');     
				
				AutresPNB = Ctrl01_CalculetteROE.setAutresPNB(DureeDuChantierMois, SpreadRemunerationPreloyersTVA, TxEuribor, MontantTVA, PourcentageCommissionEngagement, CommissionNonUtilisationEnSpread, TauxRefiPeriodique, ResultMontantNonTire, ResultatCalculPhaseChantier, ResultRemunerationTVA[0]);
				
				System.debug('AutresPNB > ' + AutresPNB + ' SpreadRemunerationPreloyersTVA ' + SpreadRemunerationPreloyersTVA + ' TxEuribor ' + TxEuribor + ' MontantTVA ' + MontantTVA);
				System.debug('PourcentageCommissionEngagement > ' + PourcentageCommissionEngagement + ' CommissionNonUtilisationEnSpread ' + CommissionNonUtilisationEnSpread + ' TauxRefiPeriodique ' + TauxRefiPeriodique + ' ResultMontantNonTire ' + ResultMontantNonTire);
				System.debug('ResultatCalculPhaseChantier > ' + ResultatCalculPhaseChantier + ' ResultRemunerationTVA[0] ' + ResultRemunerationTVA[0]);
				System.debug('DureeDuChantierMois> ' + DureeDuChantierMois);
				
				PNBStandard = Ctrl01_CalculetteROE.setPNBStandard(MargeBrutActualiseeTotal, FraisDeDossier, CommisionDeRisque, (Double)Calculette.CommissionApportFlat__c, AutresPNB);
				
				ResultatAvantImpotStandard 	= Ctrl01_CalculetteROE.setResultatAvantImpotStandard(MargeBrutActualiseeTotal, FraisDeDossier, CommisionDeRisque, (Double)Calculette.CommissionApportFlat__c, AutresPNB, CoutsDexploitationActualises[0]);   
				ResultatMargeNetStandard 	= Ctrl01_CalculetteROE.setResultatMargeNetStandard(ResultatAvantImpotStandard, TauxIS);
                                                              
                ///////////////////////// Onglet Chantier   ////////////////////////////////////
				ResultValeurDuBien 						= Ctrl01_CalculetteROE.setValeurDuBien(Avenant, MontantFinance, ValeurDuBien, EncoursTotalDuDossier);
				ResultInteretsPourRisqueOperationel 	= Ctrl01_CalculetteROE.setInteretsPourRisqueOperationel(ModeCalculROE, Nbperiode, dureeDecaissement, (Double)Calculette.CommissionApportFlat__c, ResultMargeActualisee, ResultCommissionsDeRisqueBruteActualisee);
                ResultInteretsPourDureeRestantaCourir 	= Ctrl01_CalculetteROE.setInteretsPourDureeRestantaCourir( ModeCalculROE, Nbperiode, ResultPreLoyersNetRefi, DureeDuChantierMois, ResultLoyerDossier, ResultLoyerAvancePreneur, ResultCommissionsDeRisqueBruteActualisee);
				ResultDureeRestantaCourir 				= Ctrl01_CalculetteROE.setDureeRestantaCourir(ModeCalculROE, Nbperiode, DureeDuChantierMois);
				ResultPartRembourseSurInvestissement 	= Ctrl01_CalculetteROE.PartRembourseSurInvestissement(DureeDuChantierMois, ResultatCalculPhaseChantier, MontantFinance);

				System.debug('@CediciLGDActualise : ' + Calculette.UsageROE__c + ' ' + Calculette.LocatisationROE__c + ' ' + Calculette.TypeContrepartie__c + ' ' + AvancePreneur + ' ' + MontantFinance + ' ' + ResultPartRembourseSurInvestissement); 
				
				ResultLGDActualise 						= Ctrl01_CalculetteROE.LGDActualise(Calculette.UsageROE__c, Calculette.LocatisationROE__c, Calculette.TypeContrepartie__c, AvancePreneur, MontantFinance, ResultPartRembourseSurInvestissement);    
				System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
               	//////////////////////////Onglet Calcul RWA //////////////////////////////////////////        
				list<Double> ResultEADApresGarantieIRBABPCE = ResultEncoursBrutVR; 
				
			   	ResultPonderationParMontantsLoyersEtCommissions = Ctrl01_CalculetteROE.setPonderationParMontantsLoyersEtCommissions(ModeCalculROE, Nbperiode, DureeDuChantierMois, ResultDureeRestantaCourir, ResultInteretsPourDureeRestantaCourir);
				ResultEncoursBrutVR 							= Ctrl01_CalculetteROE.setEncoursBrutVR(ModeCalculROE, Nbperiode, DureeDuChantierMois, ResultatCalculPhaseChantier, VREuro); 
				ResultProtection 								= Ctrl01_CalculetteROE.setProtection(ModeCalculROE, Nbperiode, DureeDuChantierMois, ResultatCalculPhaseChantier, PourcentageEnrisqueCom);    
				ResultEADApresGarantieIRBA 						= Ctrl01_CalculetteROE.setEADApresGarantieIRBA(ModeCalculROE, Nbperiode, DureeDuChantierMois, ResultEncoursBrutVR, ResultProtection);
				ResultEADApresGarantieSTD 						= Ctrl01_CalculetteROE.setEADApresGarantieSTD(ModeCalculROE, Nbperiode, DureeDuChantierMois, ResultEncoursBrutVR, ResultProtection);
				PD 												= Ctrl01_CalculetteROE.setPD(Calculette.NotationNIO1to10__c, Calculette.NotationNIE1to16__c, Calculette.NotationTRR__c, Calculette.TypeContrepartie__c, Calculette.BaseNotation__c, taux);
				LGD 											= Ctrl01_CalculetteROE.setLGD(Calculette.LocatisationROE__c, Calculette.TypeContrepartie__c, Calculette.UsageROE__c, AvancePreneur, MontantFinance, Calculette.BaseNotation__c, taux);////ARRET ICI
				ResultM 										= Ctrl01_CalculetteROE.setM(ResultPonderationParMontantsLoyersEtCommissions, Nbperiode, DureeDuChantierMois);
				ResultR 										= Ctrl01_CalculetteROE.setR(PD);  // STOP AUREL//
				ResultB 										= Ctrl01_CalculetteROE.setB(PD);
				ResultFPDM 										= Ctrl01_CalculetteROE.setFPDM(PD, ResultB, ResultR, ResultM, (Double)Nbperiode, DureeDuChantierMois);   
				ResultRW 										= Ctrl01_CalculetteROE.setRW(ResultLGDActualise, ResultFPDM, Nbperiode, DureeDuChantierMois, ScallingFactor); 
				ResultK 										= Ctrl01_CalculetteROE.setK(ResultLGDActualise, ResultFPDM, Nbperiode, DureeDuChantierMois, ScallingFactor);
				ResultRWALoyer 									= Ctrl01_CalculetteROE.setRWALoyer(ResultRW, ResultEADApresGarantieIRBA, Nbperiode, DureeDuChantierMois); 
				ResultRWARVR 									= Ctrl01_CalculetteROE.setRWARVR(ResultDureeRestantaCourir, VREuro, Nbperiode, DureeDuChantierMois);
				ResultRWACreditPeriodique 						= Ctrl01_CalculetteROE.setRWACreditPeriodique(ResultRWARVR, ResultRWALoyer, ResultEncoursBrutVR, Nbperiode, DureeDuChantierMois, 4, 'direct', PourcentageEnrisqueCom);
				ResultRWACreditPeriodiqueActualise 				= Ctrl01_CalculetteROE.setRWACreditPeriodiqueActualise(ResultRWACreditPeriodique, Nbperiode, DureeDuChantierMois, TauxRefiPeriodique);
				ResultCommissionEngagement 						= Ctrl01_CalculetteROE.setCommissionEngagement(dureeDecaissement, ResultatCalculPhaseChantier, PourcentageCommissionEngagement);
				ResultCommissionDeNonUtilisation 				= Ctrl01_CalculetteROE.setCommissionDeNonUtilisation(dureeDecaissement, ResultMontantNonTire, CommissionNonUtilisationEnSpread);
				ResultinteretsCalculRisqueOperationnels 		= Ctrl01_CalculetteROE.setInteretCalculRisqueOperationnels (Nbperiode, DureeDuChantierMois, ResultPreLoyersNetRefi, ResultRemunerationTVA, ResultCommissionDeNonUtilisation , ResultCommissionEngagement, ResultInteretsPourRisqueOperationel);
				System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
				//Periodicite 
            //PeriodiciteCalculDesCouts    
                ResultRWARisqueOperation = Ctrl01_CalculetteROE.setRWARisqueOperationnel(ResultMargeActualisee, ResultCommissionsDeRisqueBruteActualisee, ResultinteretsCalculRisqueOperationnels, (Double)Calculette.CommissionApportFlat__c  , Nbperiode, DureeDuChantierMois, 4 );
                ResultRWARisqueOperationActualise = Ctrl01_CalculetteROE.setRWARisqueOperationActualise ( ResultRWARisqueOperation,  TauxRefiPeriodique,   Nbperiode,    DureeDuChantierMois );
                ResultRWAAvecRisqueOperationnelActualise =  Ctrl01_CalculetteROE.setRWAAvecRisqueOperationnelActualise( ResultRWACreditPeriodiqueActualise,ResultRWARisqueOperationActualise,  Nbperiode,  DureeDuChantierMois );
                ResultTotalRWAAvecRisqueOperationnelActualise = Ctrl01_CalculetteROE.setTotalRWAAvecRisqueOperationnelActualise(ResultRWAAvecRisqueOperationnelActualise,  Nbperiode,  DureeDuChantierMois );
                ResultRWAMoyenIRBA  = Ctrl01_CalculetteROE.setTotalRWAMoyenIRBA(ResultTotalRWAAvecRisqueOperationnelActualise,  Nbperiode,  DureeDuChantierMois );     
              if((Calculette.NotationNIE1to16__c == NULL)&&(Calculette.NotationNIO1to10__c != NULL)) { 
                    ResultCotation =  Ctrl01_CalculetteROE.setCotationNIE( Ctrl01_CalculetteROE.setCotationNIO( Integer.valueOf(Calculette.NotationNIO1to10__c)  ));
                }  else if((Calculette.NotationNIE1to16__c != NULL)&&(Calculette.NotationNIO1to10__c == NULL)){
                    ResultCotation =  Ctrl01_CalculetteROE.setCotationNIE( Integer.valueOf(Calculette.NotationNIE1to16__c)  );
                } else {
                    ResultCotation =  Ctrl01_CalculetteROE.setCotationNIE( Integer.valueOf(16)  );
                }
            
            
                List<Double> PDpuisPDSP2 = new  List<Double>();
                PDpuisPDSP2 =  Ctrl01_CalculetteROE.setPDSP( Periodicite, Calculette.TypeContrepartie__c,  ResultCotation,  PD, (Double) Nbperiode,  DureeDuChantierMois) ;
          System.debug('EAD ' + ResultEADApresGarantieIRBA.size() + 'LGD' + ResultLGDActualise.size() + 'PDpuisPDSP2 ' + PDpuisPDSP2.size());
               EL =  Ctrl01_CalculetteROE.setEL(ResultEADApresGarantieIRBA ,  ResultLGDActualise,  PDpuisPDSP2 , (Double) Nbperiode,  DureeDuChantierMois );     
               ELActualise =  Ctrl01_CalculetteROE.setELActualise( EL,    Nbperiode,   DureeDuChantierMois,   TauxRefiPeriodique  );
               ELActuTotal = Ctrl01_CalculetteROE.setELTotal(  ELActualise,    Nbperiode,   DureeDuChantierMois   );
               
              
                 
               FondsPropresNormatifActualise  = Ctrl01_CalculetteROE.setFondsPropresNormatifActualise( ResultRWAAvecRisqueOperationnelActualise, PerBesoinsFP,   Nbperiode, DureeDuChantierMois  );
               TotalFondsPropresNormatifActualise = Ctrl01_CalculetteROE.setTotalFondsPropresNormatifActualise ( FondsPropresNormatifActualise, EncoursMoyen,   Calculette.BaseNotation__c ) ;
               RemunerationFPN = Ctrl01_CalculetteROE.setRemunerationFPN( ResultRWAAvecRisqueOperationnelActualise, PerBesoinsFP, TauxRemunerationFP , (Integer)Nbperiode  , DureeDuChantierMois  );
               System.debug('@CedRemunerationFPN ' + RemunerationFPN);
               TotalRemunerationFPN = Ctrl01_CalculetteROE.setRemunerationFPN( RemunerationFPN,    Nbperiode,   DureeDuChantierMois   );
               System.debug('@CedTotalRemunerationFPN ' + TotalRemunerationFPN);
               CoutExploitationActualisesIRBA =  Ctrl01_CalculetteROE.CoutExploitationActualisesIRBA( TotalRemunerationFPN, MargeBrutActualiseeTotal, TauxCoutExploitation   ) ;
               System.debug('@CedCoutExploitationActualisesIRBA ' + CoutExploitationActualisesIRBA);
               PNBIRBA =  Ctrl01_CalculetteROE.setPNBIRBA(   MargeBrutActualiseeTotal,   FraisDeDossier, CommisionDeRisque, (Double)Calculette.CommissionApportFlat__c ,  AutresPNB, TotalRemunerationFPN );
               ResultatAvantImpotIRBA = Ctrl01_CalculetteROE.setResultatAvantImpotIRBA(  MargeBrutActualiseeTotal,   FraisDeDossier, CommisionDeRisque, (Double)Calculette.CommissionApportFlat__c ,  AutresPNB ,CoutExploitationActualisesIRBA,  ELActuTotal , TotalRemunerationFPN);
               MargeNetIRBA = Ctrl01_CalculetteROE.setResultatMargeNetStandard(   ResultatAvantImpotIRBA,  TauxIS );
               BesoinsFPMoyenIRBA = Ctrl01_CalculetteROE.setBesoinsFPMoyenIRBA (TotalFondsPropresNormatifActualise,  (integer)Nbperiode,  Periodicite, Calculette.BaseNotation__c) ;
              
               
               ROEMoyenAvantImpotIRBA =  Ctrl01_CalculetteROE.setROEMoyenAvantImpotIRBA(ResultatAvantImpotIRBA, (Double)Nbperiode, BesoinsFPMoyenIRBA, Periodicite);
               ROEMoyenApresImpotIRBA =  Ctrl01_CalculetteROE.setROEMoyenApresImpotIRBA(MargeNetIRBA, (Double)Nbperiode, BesoinsFPMoyenIRBA, Periodicite);
                 
               /// RWA STD 
             
             
                 
               ValeurDuBienDiv2VR  = Ctrl01_CalculetteROE.setValeurDuBienDiv2VR  (ModeCalculROE,  (Double)Nbperiode,   DureeDuChantierMois,  VREuro,  ResultValeurDuBien );
               Partie50VRStd = Ctrl01_CalculetteROE.setPartie50VRStd ( ModeCalculROE,  (Double)Nbperiode,  DureeDuChantierMois, ResultEncoursBrutVR, ValeurDuBienDiv2VR );
               Partie100pVRStd =   Ctrl01_CalculetteROE.setPartie100pVRStd (ModeCalculROE, Nbperiode,  DureeDuChantierMois,ResultEncoursBrutVR,ValeurDuBienDiv2VR );
               RWAStdPart1 = Ctrl01_CalculetteROE.setRWAStdPart1 ( ModeCalculROE, (Double)Nbperiode,   DureeDuChantierMois, Partie50VRStd, Partie100pVRStd, ResultRWARVR,   Periodicite,  PourcentageEnrisqueCom );
               RWAStdPart2 = Ctrl01_CalculetteROE.setRWAStdPart2 ( ModeCalculROE, Nbperiode,   DureeDuChantierMois, RWAStdPart1, ResultEADApresGarantieSTD, ValeurResiduelle, TauxRefiPeriodique, Periodicite, '') ;
               TotalRWAStdPart2 = Ctrl01_CalculetteROE.setTotalRWAStdPart2 ( RWAStdPart2) ;
               RWAMoyenStd  = Ctrl01_CalculetteROE.setRWAMoyenStd (TotalRWAStdPart2,  Nbperiode,   Periodicite );
               BesoinsFPMoyenStd =   Ctrl01_CalculetteROE.setBesoinsFPMoyenStd( RWAStdPart2,  Nbperiode,   DureeDuChantierMois, PerBesoinsFP );
               
               TotalBesoinsFPMoyenStd  =   Ctrl01_CalculetteROE.setTotalBesoinsFPMoyenStd (BesoinsFPMoyenStd);
               BesoinsFPMoyenStdAnnee =  Ctrl01_CalculetteROE.setBesoinsFPMoyenStdAnnee( TotalBesoinsFPMoyenStd,  Nbperiode,   Periodicite );
 
               ROEMoyenAvantImpotStd =  Ctrl01_CalculetteROE.setROEMoyenAvantImpotIRBA(ResultatAvantImpotStandard, (Double)Nbperiode, BesoinsFPMoyenStdAnnee, Periodicite);
               ROEMoyenApresImpotStd =  Ctrl01_CalculetteROE.setROEMoyenApresImpotIRBA(ResultatMargeNetStandard, (Double)Nbperiode, BesoinsFPMoyenStdAnnee, Periodicite);
                 
               //ROE BPCE
              
             list<Double> ResultRWALoyerBPCE =  Ctrl01_CalculetteROE.setRWALoyer(   ResultRW,   ResultEADApresGarantieIRBABPCE,   Nbperiode,    DureeDuChantierMois); 
             list<Double> ResultRWACreditPeriodiqueBPCE = Ctrl01_CalculetteROE.setRWACreditPeriodique( ResultRWARVR,  ResultRWALoyerBPCE, ResultEncoursBrutVR,   Nbperiode,    DureeDuChantierMois,   4,    'direct' , PourcentageEnrisqueCom);
             list<Double> ResultRWACreditPeriodiqueActualiseBPCE  = Ctrl01_CalculetteROE.setRWACreditPeriodiqueActualise(  ResultRWACreditPeriodiqueBPCE,   Nbperiode,    DureeDuChantierMois,   TauxRefiPeriodique );
             list<Double> ResultRWAAvecRisqueOperationnelActualiseBPCE =  Ctrl01_CalculetteROE.setRWAAvecRisqueOperationnelActualise( ResultRWACreditPeriodiqueActualiseBPCE,ResultRWARisqueOperationActualise,  Nbperiode,  DureeDuChantierMois );
             Double  ResultTotalRWAAvecRisqueOperationnelActualiseBPCE = Ctrl01_CalculetteROE.setTotalRWAAvecRisqueOperationnelActualise(ResultRWAAvecRisqueOperationnelActualiseBPCE,  Nbperiode,  DureeDuChantierMois );
             Double  ResultRWAMoyenIRBABPCE  = Ctrl01_CalculetteROE.setTotalRWAMoyenIRBA(ResultTotalRWAAvecRisqueOperationnelActualiseBPCE,  Nbperiode,  DureeDuChantierMois );     
     
             list<Double> ELBPCE =  Ctrl01_CalculetteROE.setEL(ResultEADApresGarantieIRBABPCE ,  ResultLGDActualise,  PDpuisPDSP2 , (Double) Nbperiode,  DureeDuChantierMois );
             list<Double>    ELActualiseBPCE = Ctrl01_CalculetteROE.setELActualise( ELBPCE,    Nbperiode,   DureeDuChantierMois,   TauxRefiPeriodique  );
             Double     ELActuTotalBPCE = -1 * Ctrl01_CalculetteROE.setELTotal(  ELActualiseBPCE,    Nbperiode,   DureeDuChantierMois   );
             list<Double>   FondsPropresNormatifActualiseBPCE  = Ctrl01_CalculetteROE.setFondsPropresNormatifActualise( ResultRWAAvecRisqueOperationnelActualiseBPCE, PerBesoinsFP,   Nbperiode, DureeDuChantierMois  );    
             Double TotalFondsPropresNormatifActualiseBPCE = Ctrl01_CalculetteROE.setTotalFondsPropresNormatifActualise ( FondsPropresNormatifActualiseBPCE, EncoursMoyen,   Calculette.BaseNotation__c ) ; 
             list<Double>  RemunerationFPNBPCE = Ctrl01_CalculetteROE.setRemunerationFPN( ResultRWAAvecRisqueOperationnelActualiseBPCE, PerBesoinsFP, TauxRemunerationFP , (Integer)Nbperiode  , DureeDuChantierMois  );
           
            

            
            //Actualisation Frai de dossier BPCE
            //FraisDeDossier
            if( Calculette.QuotiteContreGarantie__c >= 30 ) {
                FraisDeDossier *= 2;
            }

            //CoutDeLiquiditeNL Calcul
            if(Calculette.TypeTauxRefinancement__c == 'Taux refi NL'){
                      Double  DureeAnnee2 = (Double)(Nbperiode / 4); 
                      Integer  dureeAnneeRounded =   (Integer)DureeAnnee2.round();
                      Calculette.CoutDeLiquiditePCOM__c = Ctrl01_CalculetteROE.getCoutLiquiditePCOM(dureeAnneeRounded, Calculette.SemaineConstatationTaux__c);
                    }
                    else{
                      Calculette.CoutDeLiquiditePCOM__c = TauxDeRefi;
                    }
                
            
            
            Double TotalRemunerationFPNBPCE = Ctrl01_CalculetteROE.setRemunerationFPN( RemunerationFPNBPCE,    Nbperiode,   DureeDuChantierMois   );
             //Double TotalRemunerationFPNBPCE = TotalRemunerationFPN;
             Double   CoutExploitationActualisesIRBABPCE =  Ctrl01_CalculetteROE.CoutExploitationActualisesIRBA( TotalRemunerationFPNBPCE, MargeBrutActualiseeTotal, TauxCoutExploitation   ) ;
             Double     PNBIRBABPCE =  Ctrl01_CalculetteROE.setPNBIRBA(   MargeBrutActualiseeTotal,   FraisDeDossier, CommisionDeRisque, (Double)Calculette.CommissionApportFlat__c ,  AutresPNB, TotalRemunerationFPNBPCE );
             Double ResultatAvantImpotIRBABPCE = Ctrl01_CalculetteROE.setResultatAvantImpotIRBA(  MargeBrutActualiseeTotal,   FraisDeDossier, CommisionDeRisque, (Double)Calculette.CommissionApportFlat__c ,  AutresPNB ,CoutExploitationActualisesIRBABPCE,  ELActuTotalBPCE , TotalRemunerationFPNBPCE);
             Double  MargeNetIRBABPCE = Ctrl01_CalculetteROE.setResultatMargeNetStandard(   ResultatAvantImpotIRBABPCE,  TauxIS );
             Double BesoinsFPMoyenIRBABPCE = Ctrl01_CalculetteROE.setBesoinsFPMoyenIRBA (TotalFondsPropresNormatifActualiseBPCE,  (integer)Nbperiode,  Periodicite, Calculette.BaseNotation__c) ;
             Double ROEMoyenAvantImpotIRBABPCE = Ctrl01_CalculetteROE.setROEMoyenAvantImposBPCE((Double)Nbperiode,  DureeDuChantierMois,  MargeBrutActualiseeTotal, FraisDeDossier, CoutExploitationActualisesIRBA, AutresPNB ,  BesoinsFPMoyenIRBABPCE, TotalRemunerationFPNBPCE, ELActuTotalBPCE ) ;
             Double ROEMoyenApresImpotIRBABPCE =  Ctrl01_CalculetteROE.setROEMoyenApresImpotIRBA((Double)Nbperiode,MargeBrutActualiseeTotal,FraisDeDossier, CoutExploitationActualisesIRBA, TotalRemunerationFPNBPCE,AutresPNB, MargeNetIRBABPCE, TauxIS , BesoinsFPMoyenIRBABPCE, ELActuTotalBPCE);                 

           
           /////////////////////////// MAJ des données ////////////////////////////////////////   
            
              if(Calculette.TypeDeTaux__c == 'Taux fixe') {
                 Calculette.TauxVenteClientTEA__c =  Ctrl01_CalculetteROE.setValueTauxVenteClientTEA(ModeCalculROE,TauxVenteClient ,  Calculette.TypeDeTaux__c,  TxEuribor, 0, Calculette.ForwardChantier__c );
                 if(ModeCalculROE == 'TEA') {
                  Calculette.TauxVenteClientITE__c =  Ctrl01_CalculetteROE.setValueTauxVenteClientITEWithTRI( MontantFinance, Nbperiode, ResultLoyerDossier,  Calculette.TypeDeTaux__c, Periodicite,  (Double)(0.001), VREuro, Calculette.ForwardChantier__c) ;  
                  Calculette.MargeCommercialeApresLiquiditeTEA__c =  Ctrl01_CalculetteROE.setMargeTEA(ModeCalculROE, TauxVenteClient, TauxDeRefi  *100 ) ;
                 Calculette.MargeCommercialeApresLiquiditeITE__c = Ctrl01_CalculetteROE.setMargeITEWithTRI(MontantFinance, Nbperiode,  ResultLoyerDossier, Calculette.TypeDeTaux__c, Periodicite, (Double)(0.001), VREuro, TauxDeRefi  * 100) ;
                 Calculette.MargeApresAvancePreneur__c = NULL;
                        if(Calculette.AvancePreneur__c != 0 ){
                            Calculette.MargeApresAvancePreneur__c = Ctrl01_CalculetteROE.setMargeApresAvanceWithTRI(MontantFinance,  Nbperiode,   ResultLoyerDossier,  Calculette.TypeDeTaux__c, Periodicite, (Double)(0.001),  VREuro, TauxDeRefi  * 100 ,  AvancePreneur ,  ResultLoyerAvancePreneur);
                        }
                     
                 } 
                  else {
                   Calculette.TauxVenteClientITE__c =  Ctrl01_CalculetteROE.setValueTauxVenteClientITE( ModeCalculROE, TauxVenteClient, Calculette.TypeDeTaux__c, TxEuribor, 0, Calculette.ForwardChantier__c );
                    Calculette.MargeCommercialeApresLiquiditeTEA__c = null;
                    Calculette.MargeCommercialeApresLiquiditeITE__c = Ctrl01_CalculetteROE.setMargeITE(  ModeCalculROE,   TauxDeRefi ,   TauxVenteClient);
                    Calculette.MargeApresAvancePreneur__c =Ctrl01_CalculetteROE.setMargeITEAvanceWithTRI( MontantFinance,  Nbperiode,   ResultLoyerDossier,   Calculette.TypeDeTaux__c,  Periodicite,  (Double)(0.001),  VREuro,  TauxDeRefi,  AvancePreneur, TauxRemunerationAP); 
                  }
               }
               else if(Calculette.TypeDeTaux__c == 'Taux variable Euribor 3 mois') { 
                    Calculette.TauxVenteClientTEA__c   = Ctrl01_CalculetteROE.setValueTauxVenteClientTEA(ModeCalculROE, (Double)Calculette.SpreadIndex365360__c,  Calculette.TypeDeTaux__c,  TxEuribor, 0, Calculette.ForwardChantier__c );
                    if(ModeCalculROE == 'TEA') {
                       Calculette.TauxVenteClientITE__c =  Ctrl01_CalculetteROE.setValueTauxVenteClientITEWithTRI( MontantFinance, Nbperiode, ResultLoyerDossier,  Calculette.TypeDeTaux__c, Periodicite,  (Double)(0.001), VREuro, Calculette.ForwardChantier__c) ;  
                        Calculette.MargeCommercialeApresLiquiditeTEA__c =  Ctrl01_CalculetteROE.setMargeTEA(ModeCalculROE, TauxVenteClient, TauxDeRefiDossier ) ;
                        Calculette.MargeCommercialeApresLiquiditeITE__c = Ctrl01_CalculetteROE.setMargeITEWithTRI(MontantFinance, Nbperiode,  ResultLoyerDossier, Calculette.TypeDeTaux__c, Periodicite, (Double)(0.001), VREuro, TauxDeRefiDossier) ; 
                        Calculette.MargeApresAvancePreneur__c = NULL;
                        if(Calculette.AvancePreneur__c != 0 ){
                            Calculette.MargeApresAvancePreneur__c = Ctrl01_CalculetteROE.setMargeApresAvanceWithTRI(MontantFinance,  Nbperiode,   ResultLoyerDossier,  Calculette.TypeDeTaux__c, Periodicite, (Double)(0.001),  VREuro, TauxDeRefiDossier,  AvancePreneur ,  ResultLoyerAvancePreneur);    
                         } 
                    } 
                     else {
                        Calculette.TauxVenteClientITE__c =  Ctrl01_CalculetteROE.setValueTauxVenteClientITE( ModeCalculROE, (Double)Calculette.SpreadIndex365360__c, Calculette.TypeDeTaux__c, TxEuribor, 0, Calculette.ForwardChantier__c );
                        Calculette.MargeCommercialeApresLiquiditeTEA__c =  null;
                        Calculette.MargeCommercialeApresLiquiditeITE__c = Ctrl01_CalculetteROE.setMargeITE(  ModeCalculROE,   TauxDeRefi ,   TauxVenteClient);
                        Calculette.MargeApresAvancePreneur__c =Ctrl01_CalculetteROE.setMargeITEAvanceWithTRI( MontantFinance,  Nbperiode,   ResultLoyerDossier,   Calculette.TypeDeTaux__c,  Periodicite,  (Double)(0.001),  VREuro,  TauxDeRefi,  AvancePreneur, TauxRemunerationAP); 
                     }
               }
               else if((Calculette.TypeDeTaux__c == 'Taux CMS 8 ans')||(Calculette.TypeDeTaux__c == 'Taux CMS 9 ans')||(Calculette.TypeDeTaux__c == 'Taux CMS 10 ans')||(Calculette.TypeDeTaux__c == 'Taux CMS 12 ans')||(Calculette.TypeDeTaux__c == 'Taux CMS 15 ans') )    {
                    Calculette.TauxVenteClientTEA__c  = Ctrl01_CalculetteROE.setValueTauxVenteClientTEA(ModeCalculROE, (Double)Calculette.SpreadCMS__c  ,  Calculette.TypeDeTaux__c,  TxEuribor, (Double)Calculette.TauxCMSSemaine__c, Calculette.ForwardChantier__c  );
                    if(ModeCalculROE == 'TEA') {
                       Calculette.TauxVenteClientITE__c =  Ctrl01_CalculetteROE.setValueTauxVenteClientITEWithTRI( MontantFinance, Nbperiode, ResultLoyerDossier,  Calculette.TypeDeTaux__c, Periodicite,  (Double)(0.001), VREuro, Calculette.ForwardChantier__c) ;  
                        Calculette.MargeCommercialeApresLiquiditeTEA__c =  Ctrl01_CalculetteROE.setMargeTEA(ModeCalculROE, TauxVenteClient, TauxDeRefi ) ;
                        Calculette.MargeCommercialeApresLiquiditeITE__c = Ctrl01_CalculetteROE.setMargeITEWithTRI(MontantFinance, Nbperiode,  ResultLoyerDossier, Calculette.TypeDeTaux__c, Periodicite, (Double)(0.001), VREuro, TauxDeRefi) ;
                        
                     Calculette.MargeApresAvancePreneur__c = NULL;
                        if(Calculette.AvancePreneur__c != 0 ){
                            Calculette.MargeApresAvancePreneur__c = Ctrl01_CalculetteROE.setMargeApresAvanceWithTRI(MontantFinance,  Nbperiode,   ResultLoyerDossier,  Calculette.TypeDeTaux__c, Periodicite, (Double)(0.001),  VREuro, TauxDeRefi,  AvancePreneur ,  ResultLoyerAvancePreneur);
                        }
                    
                    } 
                     else {
                        Calculette.TauxVenteClientITE__c =  Ctrl01_CalculetteROE.setValueTauxVenteClientITE( ModeCalculROE,  (Double)Calculette.SpreadCMS__c , Calculette.TypeDeTaux__c, TxEuribor,  (Double)Calculette.TauxCMSSemaine__c, Calculette.ForwardChantier__c );
                        Calculette.MargeCommercialeApresLiquiditeTEA__c =  null;
                        Calculette.MargeCommercialeApresLiquiditeITE__c = Ctrl01_CalculetteROE.setMargeITE(  ModeCalculROE,   TauxDeRefi ,   TauxVenteClient);
                        Calculette.MargeApresAvancePreneur__c =Ctrl01_CalculetteROE.setMargeITEAvanceWithTRI( MontantFinance,  Nbperiode,   ResultLoyerDossier,   Calculette.TypeDeTaux__c,  Periodicite,  (Double)(0.001),  VREuro,  TauxDeRefi,  AvancePreneur, TauxRemunerationAP); 
                     }
               }
             
                Calculette.CoutsDexploitationActualisesIRBA__c = CoutExploitationActualisesIRBA;
                Calculette.PNBIRBA__c = PNBIRBA;
                Calculette.RWAMoyen__c = ResultRWAMoyenIRBA;
                Calculette.ExpectedLoss__c = ELActuTotal;
                Calculette.RemunerationDesFPN__c = TotalRemunerationFPN;
                Calculette.ResultatCourantAvantImpotIRBA__c = ResultatAvantImpotIRBA;
                Calculette.MargeNetteIRBA__c = MargeNetIRBA;
                Calculette.BesoinsFPMoyenIRBA__c = BesoinsFPMoyenIRBA;
                Calculette.ROEMAimpotIRBA__c = ROEMoyenAvantImpotIRBA;
                Calculette.ROEMApresimpotIRBA__c = ROEMoyenApresImpotIRBA;
                Calculette.RWAMoyenStandard__c = RWAMoyenStd;
                Calculette.BesoinsFPmoyenSTD__c = BesoinsFPMoyenStdAnnee;
                Calculette.ROEMoyenAvantImpotStd__c = ROEMoyenAvantImpotStd;
                 Calculette.ROEmoyenApresImpotStandard__c =  ROEMoyenApresImpotStd;
 
                if(Calculette.CommissionApportFlat__c != null) {
                    Calculette.CommissionApportFlatNegatif__c =  (Calculette.CommissionApportFlat__c * -1);
               }
               else { 
                   Calculette.CommissionApportFlatNegatif__c =0;
               }
               Calculette.TauxRefinancementNL__c =   Calculette.TauxRefinancementNL__c;
               Calculette.EncoursMoyenOperationDuree__c =  EncoursMoyenDeOperation;
               Calculette.MargeBruteFinanciereActualisee__c =  MargeBrutActualiseeTotal;
      
               Calculette.CommissionDeRisqueActualiseeBPCE__c = CommisionDeRisque;
               Calculette.CoutsDexploitationActualises__c = CoutsDexploitationActualises[0]; 
               Calculette.PNBAdditionnel__c = AutresPNB;
               Calculette.PNBStandard__c = PNBStandard;
               Calculette.ResultatCourantAvantImpotStandard__c = ResultatAvantImpotStandard;
               Calculette.MargeNetteStandard__c = ResultatMargeNetStandard;  
               Calculette.ProbabiliteDeDefaut__c = PD;
               Calculette.LGD__c =     LGD;     
               Calculette.Euribor3Mois__c = TxEuribor;
               //Calculette.MontantAVPRNL__c = AvancePreneur;
               Calculette.QuotiteContreGarantie__c  = Calculette.QuotiteContreGarantie__c ;
               Calculette.CoutDeLiquidite__c  = Calculette.CoutDeLiquidite__c;
               Calculette.CoutDeLiquiditePCOM__c = Calculette.CoutDeLiquiditePCOM__c;
               Calculette.EncoursMoyen__c = EncoursMoyen;
              
               Calculette.TauxDeRefinancementOperation__c = Calculette.TauxDeRefinancementOperation__c;

                Calculette.RWAMoyenBPCE__c = ResultRWAMoyenIRBABPCE;
               
               Calculette.BesoinsFPMoyenIRBABPCE__c = BesoinsFPMoyenIRBABPCE;
               Calculette.ROEMoyenAvantImpotIRBABPCE__c = ROEMoyenAvantImpotIRBABPCE;
               Calculette.ROEMoyenApresImpotIRBABPCE__c = ROEMoyenApresImpotIRBABPCE;
            
                System.debug('EAD ' + ResultEADApresGarantieIRBA.size() + 'LGD' + ResultLGDActualise.size() + 'PDpuisPDSP ' + PDpuisPDSP2.size());       
                if( Calculette.BaseNotation__c == 'Retails - Direct') {
                    Calculette.CoutsDexploitationActualisesIRBA__c = 0;
                     Calculette.PNBIRBA__c = 0; 
                    Calculette.ExpectedLoss__c = 0;
                      Calculette.ResultatCourantAvantImpotIRBA__c = 0;
                        Calculette.MargeNetteIRBA__c = 0;
                    Calculette.BesoinsFPMoyenIRBA__c = 0;
                    Calculette.ROEMAimpotIRBA__c = 0;
                    Calculette.ROEMApresimpotIRBA__c = 0; 
                    Calculette.RWAMoyenBPCE__c = 0;
                      Calculette.BesoinsFPMoyenIRBABPCE__c = 0;
                   Calculette.ROEMoyenAvantImpotIRBABPCE__c = 0;
                   Calculette.ROEMoyenApresImpotIRBABPCE__c = 0;
                    Calculette.RemunerationDesFPN__c = 0;
                     Calculette.RWAMoyen__c = 0; 
                    Calculette.NotationTRR__c = NULL;
                    Calculette.NotationNIO1to10__c= NULL;
                    Calculette.NotationNIE1to16__c= NULL; 
                
                     }
                // System.debug( 'ResultLoyerDossier ' + ResultLoyerDossier );
               }
              ///End IF Avec big Conditions       
              else {
                      Calculette.TauxVenteClientTEA__c =  0;
                   Calculette.TauxVenteClientITE__c =  0;  
                   Calculette.MargeCommercialeApresLiquiditeTEA__c = 0;
                   Calculette.MargeCommercialeApresLiquiditeITE__c = 0 ;
                   Calculette.MargeApresAvancePreneur__c = 0;
                  Calculette.CoutsDexploitationActualisesIRBA__c = 0;
                    Calculette.PNBIRBA__c = 0;
                    Calculette.RWAMoyen__c = 0;
                    Calculette.ExpectedLoss__c = 0;
                    Calculette.RemunerationDesFPN__c = 0;
                    Calculette.ResultatCourantAvantImpotIRBA__c = 0;
                    Calculette.MargeNetteIRBA__c = 0;
                    Calculette.BesoinsFPMoyenIRBA__c = 0;
                    Calculette.ROEMAimpotIRBA__c = 0;
                    Calculette.ROEMApresimpotIRBA__c = 0;
                    Calculette.RWAMoyenStandard__c = 0;
                    Calculette.BesoinsFPmoyenSTD__c = 0;
                    Calculette.ROEMoyenAvantImpotStd__c = 0;
                     Calculette.ROEmoyenApresImpotStandard__c =  0;
                   Calculette.EncoursMoyenOperationDuree__c =  0;
                   Calculette.MargeBruteFinanciereActualisee__c =  0;
                  // Calculette.MargeBruteFinanciereActualiseePerc__c = (MargeBrutActualiseeTotal/DureeAnnee/EncoursMoyen);
                   Calculette.CommissionDeRisqueActualiseeBPCE__c = 0;
                   Calculette.CoutsDexploitationActualises__c = 0; 
                   Calculette.PNBAdditionnel__c = 0;
                   Calculette.PNBStandard__c = 0;
                   Calculette.ResultatCourantAvantImpotStandard__c = 0;
                   Calculette.MargeNetteStandard__c = 0;  
                   Calculette.ProbabiliteDeDefaut__c = 0;
                   Calculette.LGD__c =     0;     
             
                   Calculette.CoutDeLiquidite__c  = 0;
               }     
            
       ///end for 
       UpdatedCalculette.add(Calculette);
     }
       return UpdatedCalculette; 
  }          
}