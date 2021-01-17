public class AP24_CalculRepereHandlerFront {
   
    public static Set<String> segCommercialPROS=new Set<String>{'11','12','13','14','93'};
    public static Set<String> setBusinessUnits=new Set<String>{'1','2','3','4','5'};
    public static Id idRecordTypeIndividuel = Schema.SObjectType.ObjectifRealise__c.getRecordTypeInfosByDeveloperName().get('Individuel').getRecordTypeId();
    
     /*******************************************************************************************************************
    * @description : permet de calculer les objectifs mensualisés FRONT Obj_ASS_QT1__c,Obj_ASS_QT3__c,Obj_ASS_QT4__c
    * @param : liste des opportunity avec intevenat 422, et liste avec intervenant Derog
    * @return: void
    * @createdBy: RWA
    * @createdDate : 15/12/2019
    **************************************************************************************************************************/
    public static void calculIndicateursFrontOppty( Map<Id,List<Opportunity>> mapOppIntervenantDerog,
                                                   Integer mois,Integer annee){ 
       
        //system.debug('@@ mapOppIntervenantDerog '+mapOppIntervenantDerog.size());

		List<ObjectifRealise__c> objectifExistant=[select id,Collaborateur__c from ObjectifRealise__c
                                                   where Collaborateur__c in :mapOppIntervenantDerog.keyset()
                                                   and Mois__c=:mois
                                                   and annee__c=:annee
                                                  ];
												  
        Map<Id,Id> mapRealiseByCollaborateur=new Map<Id,Id>();
        for(ObjectifRealise__c real : objectifExistant){
            mapRealiseByCollaborateur.put(real.Collaborateur__c,real.Id);
        }
       
        List<ObjectifRealise__c> objectifsToUpsert=new List<ObjectifRealise__c>();
        for(Id intervenantId :mapOppIntervenantDerog.keyset()){          
           List<Opportunity> userDerog=mapOppIntervenantDerog.get(intervenantId);
           ObjectifRealise__c objectifRealise = new ObjectifRealise__c();
           objectifRealise.Id=mapRealiseByCollaborateur.get(intervenantId);
           objectifRealise.recordtypeId=idRecordTypeIndividuel;
           if(userDerog!=null){
               wrapCalculIndicateurOpp indicateursOpp =calculIndicateursOpp(userDerog);  
               objectifRealise.Obj_ASS_QT1__c=indicateursOpp.percentDelaiDerog;
               objectifRealise.Obj_ASS_QT3__c=indicateursOpp.percentContatAvecAssurance;
               objectifRealise.Obj_ASS_QT4__c=indicateursOpp.percentMontantFrais;

           }
           else{
                objectifRealise.Obj_ASS_QT1__c=0;
                objectifRealise.Obj_ASS_QT3__c=0;
                objectifRealise.Obj_ASS_QT4__c=0;
           }
         			
			objectifRealise.Obj_ASS_QT2__c=0;
			objectifRealise.Obj_ASS_QL1__c=0;
            objectifRealise.Obj_ASS_QL2__c=0;
            objectifRealise.Obj_ASSRC_QT1__c=0;
            objectifRealise.Obj_ASSRC_QT2__c=0;
            objectifRealise.Mois__c=mois;
            objectifRealise.annee__c=annee;
            objectifRealise.Collaborateur__c=intervenantId;
			objectifsToUpsert.add(objectifRealise);
           
        }
        
       upsert objectifsToUpsert;
    }
    
    /******************************************************************************************************************************
    * @description : permet de calculer les objectifs mensualisés Obj_ASS_QT2__c,Obj_ASS_QL1__c,Obj_ASS_QL2__c
    * @param : liste des demandes avec ointervenant 423 et 460
    * @return: void
    * @createdBy: RWA
    * @createdDate : 15/12/2019
    *********************************************************************************************/
    public static void calculIndicateursCaseFront(Map<Id,List<Case>> mapOppIntervenant423,
                                              Map<Id,List<Case>> mapOppIntervenant460,
                                              Integer mois,Integer annee){        
        Set<Id> setIntervenants=new Set<Id>();
  
        setIntervenants.addAll(mapOppIntervenant423.keyset());
        setIntervenants.addAll(mapOppIntervenant460.keyset());
                                                  

        List<ObjectifRealise__c> objectifExistant=[select id,Collaborateur__c,Obj_ASS_QT1__c,
													Obj_ASS_QT3__c, Obj_ASS_QT4__c from ObjectifRealise__c
                                                   where Collaborateur__c in :setIntervenants
                                                   and Mois__c=:mois
                                                   and annee__c=:annee
                                                  ];
        Map<Id,Id> mapRealiseByCollaborateur=new Map<Id,Id>();
        for(ObjectifRealise__c real : objectifExistant){
            mapRealiseByCollaborateur.put(real.Collaborateur__c,real.Id);
        }
       
        List<ObjectifRealise__c> objectifsToUpsert=new List<ObjectifRealise__c>();
        for(Id intervenantId :setIntervenants){
          
           List<Case> user423=mapOppIntervenant423.get(intervenantId);
           List<Case> user460=mapOppIntervenant460.get(intervenantId);
           
            
            ObjectifRealise__c objectifRealise = new ObjectifRealise__c();
            objectifRealise.Id=mapRealiseByCollaborateur.get(intervenantId);
            objectifRealise.recordtypeId=idRecordTypeIndividuel;
            
		 if(user423!=null){
               objectifRealise.Obj_ASS_QT2__c=calculPercentDelaiPVFactCrea_423(user423); 
            }
            else{
                objectifRealise.Obj_ASS_QT2__c=0;
            }
            if(user460!=null){
               wrapCalcul460 infos460=calculInfos_460(user460);
               objectifRealise.Obj_ASS_QL1__c=infos460.percNonforcee;
               objectifRealise.Obj_ASS_QL2__c=infos460.percConforme; 
            }
            else{
               objectifRealise.Obj_ASS_QL1__c=0;
               objectifRealise.Obj_ASS_QL2__c=0;
            }
            
            objectifRealise.Mois__c=mois;
            objectifRealise.annee__c=annee;
            objectifRealise.Collaborateur__c=intervenantId;
            
         
            objectifsToUpsert.add(objectifRealise);
           
        }
        
       upsert objectifsToUpsert;
    }

    /* Permet de calculer les indicateurs
     * Obj-ASS-QT1 = Pourcentage du délai de réponse sur les dérogation
     * Obj-ASS-QT3=Pourcentage de contrats avec Assurances
	 * et Obj-ASS-QT4=Pourcentage de contrats avec frais de dossiers */
    
    public static wrapCalculIndicateurOpp calculIndicateursOpp(List<Opportunity> oppties){
        
        /* Obj-ASS-QT1 */
        Decimal percentDelaiDerog=0;
        //Decimal nbDerog=0;
        Decimal nbDerogOK=0;
        
        /*Obj-ASS-QT3*/
        Decimal percentContatAvecAssurance=0;
        Decimal nbContrat=0;
        Decimal nbContratAvecAssurance=0;
        
        /*Obj-ASS-QT4*/
        Decimal percentMontantFrais=0;
        Decimal sommeMontantOppties=0;
        Decimal sommeFraisOppties=0;
        
        Set<String> setSegmentCommercialPROS=new Set<String>{'11','12','13','14','93'};
        for(Opportunity oppty : oppties){
            nbContrat++;
            if(oppty.amount!=null){
                sommeMontantOppties=sommeMontantOppties+oppty.amount;
            }            
            if(oppty.FraisdeDossierCBM__c!=null && setSegmentCommercialPROS.contains(oppty.Account.SegmentationCommerciale__c)){
               sommeFraisOppties=sommeFraisOppties+oppty.FraisdeDossierCBM__c; 
            }
            
            if(oppty.Dossier__r.NbAssurances1501__c>0 && setSegmentCommercialPROS.contains(oppty.Account.SegmentationCommerciale__c)){
                nbContratAvecAssurance++;
            }
             if(oppty.Delai_derogation__c<=9){
                nbDerogOK++;
            }
        }
        percentMontantFrais=AP24_CalculRepereHandler.calculRapport(sommeFraisOppties,sommeMontantOppties,100);
        percentContatAvecAssurance=AP24_CalculRepereHandler.calculRapport(nbContratAvecAssurance,nbContrat,100);
        percentDelaiDerog=AP24_CalculRepereHandler.calculRapport(nbDerogOK,nbContrat,100);
        wrapCalculIndicateurOpp indicateursOpp=new wrapCalculIndicateurOpp(percentMontantFrais,percentContatAvecAssurance,percentDelaiDerog);
        return indicateursOpp; 
    }
    
    
     /*Permet de calculer lindicateur Obj-ASS-QT2=Délais moyen entre PV Facture et Back 423*/
    public static Decimal calculPercentDelaiPVFactCrea_423(List<Case> relatedCases){
        Decimal moyenneDelai=0;
        Decimal nbCaseAvecDelai=0;
        Decimal sommeDelai=0;        
        for(Case demandeMEL :relatedCases){
				nbCaseAvecDelai++;
                sommeDelai=sommeDelai+demandeMEL.Delai_PVFact_Crea__c;
        }
        moyenneDelai=AP24_CalculRepereHandler.calculRapport(sommeDelai,nbCaseAvecDelai,1);
        return moyenneDelai;
    }
    
    /*Permet de calculer les indicateurs  Obj-ASS-QL1 =Pourcentage du nombre de saisies non forcées sur année (au jour le jour pour les demandes MEL)
   et Obj-ASS-QL2=Pourcentage de conformité des dossiers sur déclaratif back*/
    
     public static wrapCalcul460 calculInfos_460(List<Case> relatedCases){
        Decimal nbNonforce=0;
        Decimal nbConforme=0;
        Decimal nbMEL460=0;
        Decimal percNonforcee=0;
        Decimal percConforme=0;
       
        nbMEL460 =relatedCases.size();
        for(Case demandeMEL :relatedCases){
            if(String.isBlank(demandeMEL.ComplexiteForcee__c)){
                nbNonforce++;                
            }
            if(String.isBlank(demandeMEL.StatutNonConformite__c)){
                nbConforme++;                
            }
        }
        percNonforcee=AP24_CalculRepereHandler.calculRapport(nbNonforce,nbMEL460,100);
        percConforme=AP24_CalculRepereHandler.calculRapport(nbConforme,nbMEL460,100);
        wrapCalcul460 infos460=new wrapCalcul460(percNonforcee,percConforme);
        return infos460;
    }
    

    public class wrapCalcul460{
        Decimal percNonforcee;
        Decimal percConforme;
        public wrapCalcul460(Decimal percNonforcee,Decimal percConforme){
          this.percNonforcee=percNonforcee;  
          this.percConforme=percConforme;
        }
    }
     public class wrapCalculIndicateurOpp{
        Decimal percentMontantFrais;
        Decimal percentContatAvecAssurance;
        Decimal percentDelaiDerog;
        public wrapCalculIndicateurOpp(Decimal percentMontantFrais,Decimal percentContatAvecAssurance,Decimal percentDelaiDerog){
          this.percentMontantFrais=percentMontantFrais;  
          this.percentContatAvecAssurance=percentContatAvecAssurance;
          this.percentDelaiDerog=percentDelaiDerog;
        }
    }
    
    public static Map<Id, ObjectifRealise__c> getMapObjectifBycollab(Set<Id> idSet, Integer mois, Integer annee){
        
          
        List<ObjectifRealise__c> listObjectifs=[select id,Collaborateur__c,Obj_ASSRC_QT2__c
                                                    from ObjectifRealise__c
                                                    where Collaborateur__c in :idSet
                                                    and Mois__c=:mois
                                                    and annee__c=:annee
                                                    ];        
        
        Map<Id, ObjectifRealise__c> mapObjectiByColloborateur=new Map<Id, ObjectifRealise__c> ();
        for(ObjectifRealise__c obj :listObjectifs ){
            mapObjectiByColloborateur.put(obj.Collaborateur__c,obj);
        }
        return mapObjectiByColloborateur;
    }
}