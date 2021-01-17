public class AP27_RepereQuery {
    
    public static Id idRecordTypeIndividuel = Schema.SObjectType.ObjectifRealise__c.getRecordTypeInfosByDeveloperName().get('Individuel').getRecordTypeId();
     
    /*On ne fait pas la requete complete de tous les opportunity sur le start du batch car risque d'atteindre le heap size*/
    /*On ne fait pas la requete complete de tous les opportunity sur le execute car on risque d'atteindre les 50 000 rows*/
    /*On fait une requete par type de populations*/
    
    /* Recupere que les données necessaires au calcul des indicateurs 423. 
	Lorsque le batch est lancé en Decembre il prend tous les records concernés depuis le 01 janvier
	Pour eviter d'atteindre les limites on split les requetes par populations */
    public static Map<Id,List<Case>> getCase423MapByIntervenant(Date startDate,Date endDate,List<String> CBMFrontRecordTypes){
        Map<Id,List<Case>> mapCasebyIntervenant423=new Map<Id,List<Case>>();
        List<Case> listCase=[Select id,Delai_PVFact_Crea__c,
                             ProjetAssocie__r.Intervenant_decision_423__c,ProjetAssocie__r.Intervenant_decision_460__c
                             from Case 
                             where recordtype.developerName='CBM_Mise_en_place'
                             and status!='Annulée'
                             and ProjetAssocie__r.recordType.developerName in :CBMFrontRecordTypes
                             and ProjetAssocie__r.StageName != 'S_SUIT'
                             and ProjetAssocie__r.Intervenant_decision_423__c!=null
                             and CreatedDate >=:startDate and CreatedDate <=:endDate
                             and Delai_PVFact_Crea__c!=null
                            ];
        for(Case c :listCase){
            Id intervenant=c.ProjetAssocie__r.Intervenant_decision_423__c;
            if(mapCasebyIntervenant423.containsKey(intervenant)){
                mapCasebyIntervenant423.get(intervenant).add(c);  
            }
            else{
                mapCasebyIntervenant423.put(intervenant, new List<Case>{c});
            } 
        }
 
        return mapCasebyIntervenant423;
    }
    
    
    /* Recupere que les données necessaires au calcul des indicateurs 460. 
	Lorsque le batch est lancé en Decembre il prend tous les records concernés depuis le 01 janvier
	Pour eviter d'atteindre les limites on split les requetes par populations */
    public static Map<Id,List<Case>> getCase460MapByIntervenant(Date startDate,Date endDate,List<String> CBMFrontRecordTypes){
        Map<Id,List<Case>> mapCasebyIntervenant460=new Map<Id,List<Case>>();
        List<Case> listCase=[Select id,StatutNonConformite__c,ComplexiteForcee__c ,ProjetAssocie__r.Intervenant_decision_460__c
                             from Case 
                             where recordtype.developerName='CBM_Mise_en_place'
                             and status!='Annulée'
                             and ProjetAssocie__r.recordType.developerName in :CBMFrontRecordTypes
                             and ProjetAssocie__r.StageName != 'S_SUIT'
                             and ProjetAssocie__r.Intervenant_decision_460__c!=null
                             and Date_de_traitement_de_la_MEL__c >=:startDate and Date_de_traitement_de_la_MEL__c <=:endDate
                            ];
        for(Case c :listCase){
            Id intervenant=c.ProjetAssocie__r.Intervenant_decision_460__c;
            if(mapCasebyIntervenant460.containsKey(intervenant)){
                mapCasebyIntervenant460.get(intervenant).add(c);  
            }
            else{
                mapCasebyIntervenant460.put(intervenant, new List<Case>{c});
            } 
        }
        //system.debug('@@ mapCasebyIntervenant460 '+mapCasebyIntervenant460);
        return mapCasebyIntervenant460;
    }
    
  
    
   /* Recupere que les données necessaires au calcul des indicateurs Derog. 
	Lorsque le batch est lancé en Decembre il prend tous les records concernés depuis le 01 janvier
	Pour eviter d'atteindre les limites on split les requetes par populations */ 
    public static Map<Id,List<Opportunity>> getOpptyDerogMapByIntervenant(Date startDate,Date endDate,List<String> CBMFrontRecordTypes){
       
        Map<Id,List<Opportunity>> mapOpptybyIntervenantDerog=new Map<Id,List<Opportunity>>();
        List<Opportunity> listOppty = [select id, Intervenant_traitement_Derogation__c,Delai_derogation__c,Account.SegmentationCommerciale__c,
                                       Amount,Intervenant_decision_422__c ,FraisdeDossierCBM__c, Dossier__r.NbAssurances1501__c
                                       from  Opportunity 
                                       where DateFinDerogationV4__c >=:startDate and DateFinDerogationV4__c <=:endDate 
                                       and Intervenant_traitement_Derogation__c!=null
                                       and DateV4_850_Dero_Materiel_Occasion__c =null
                                       and recordType.developerName in :CBMFrontRecordTypes
                                       and Delai_derogation__c!=null
                                       and StageName != 'S_SUIT' ];
        
        for(Opportunity oppty  :listOppty){
            if(mapOpptybyIntervenantDerog.containsKey(oppty.Intervenant_traitement_Derogation__c)){
                mapOpptybyIntervenantDerog.get(oppty.Intervenant_traitement_Derogation__c).add(oppty);
            }
            else{
                mapOpptybyIntervenantDerog.put(oppty.Intervenant_traitement_Derogation__c, new List<Opportunity>{oppty});
            }
        }
        return mapOpptybyIntervenantDerog;
    }
    
    /* calcul des indicateurs Obj-ASSRC-QT1=Pourcentage de dossiers créés Front Lease / Nombre total de dossiers
	*/
    public static void getDossierFrontLease(Date startDate,Date endDate,List<String> CBMFrontRecordTypes){
        
        Set<String> setSegmentCommercialPROS=new Set<String>{'11','12','13','14','93'};
        List<Opportunity> listOppties=[select id, owner.CodeDelegationRegionale__c,OrigineDuDossier__c,	Dossier__c,
                                       Dossier__r.MontantDuFinancementQPNL__c,Account.SegmentationCommerciale__c
                                       from  Opportunity 
                                       where DateMiseEnLoyerCassiopaeBack__c >=:startDate and DateMiseEnLoyerCassiopaeBack__c <=:endDate 
                                       and owner.CodeDelegationRegionale__c!=null
                                       and recordType.developerName in :CBMFrontRecordTypes
                                       and StageName != 'S_SUIT'
                                       and BusinessUnit__c!='6' ];
     
       Map<String,List<Opportunity>> mapOpptyByCD=new Map<String,List<Opportunity>>();
       Map<String,List<Opportunity>> mapOpptyByCDFrontLease=new Map<String,List<Opportunity>>();
       Map<String,Decimal> mapMontantFiancemenQPNL=new Map<String,Decimal>();
       List<String> codesDelegations= new List<String>();
        
       /*Recuperer la liste des projets associés par code deleguation*/
       for(Opportunity oppty :listOppties){
           codesDelegations.add('%'+oppty.owner.CodeDelegationRegionale__c+'%');
           /*Section pourcentage de l'atteinte de Production en k€ de la délégation régionale*/
           if(oppty.Dossier__c!=null && oppty.Dossier__r.MontantDuFinancementQPNL__c!=null){
               Decimal montant=mapMontantFiancemenQPNL.get(oppty.owner.CodeDelegationRegionale__c);
               if(montant!=null){
                   Decimal nvxMontant=montant+oppty.Dossier__r.MontantDuFinancementQPNL__c;
                  mapMontantFiancemenQPNL.put(oppty.owner.CodeDelegationRegionale__c,nvxMontant);
               }else{
                   mapMontantFiancemenQPNL.put(oppty.owner.CodeDelegationRegionale__c,oppty.Dossier__r.MontantDuFinancementQPNL__c);
               }
               
           }
           
           
           /*section Pourcentage de dossiers créés Front Lease */
           if(setSegmentCommercialPROS.contains(oppty.Account.SegmentationCommerciale__c)){
              
               if(mapOpptyByCD.containsKey(oppty.owner.CodeDelegationRegionale__c)){
                   mapOpptyByCD.get(oppty.owner.CodeDelegationRegionale__c).add(oppty);
               }
               else{
                   mapOpptyByCD.put(oppty.owner.CodeDelegationRegionale__c,new List<Opportunity>{oppty});
               }
               if('2'.equals(oppty.OrigineDuDossier__c)){
                      if(mapOpptyByCDFrontLease.containsKey(oppty.owner.CodeDelegationRegionale__c)){
                        mapOpptyByCDFrontLease.get(oppty.owner.CodeDelegationRegionale__c).add(oppty);
                   }
                   else{
                       mapOpptyByCDFrontLease.put(oppty.owner.CodeDelegationRegionale__c,new List<Opportunity>{oppty});
                   }
               } 
           }
          
        }
      /* system.debug('@@ listOppties '+listOppties.size());
       system.debug('@@ mapOpptyByCD '+mapOpptyByCD.size());
       system.debug('@@ mapOpptyByCDFrontLease '+mapOpptyByCDFrontLease.size());
       system.debug('@@ mapMontantFiancemenQPNL '+mapMontantFiancemenQPNL.size());*/
        
        /* Recuperer la liste des agents dont les codes gerés sont le perimetre des projets précédemment selectionnés*/
        List<User> users=[Select id,CodesDelegationsRegionalesGeres__c 
                          from User where CodesDelegationsRegionalesGeres__c like :codesDelegations];
        
        //system.debug('@@ liste users concernes ' +users);
        Map<Id,Decimal> mapPercDossPROSFrontLease=new Map<Id,Decimal>();
        Map<Id,Decimal> mapMontantFinancementUser=new Map<Id,Decimal>();
        
        /* Pour chaque utilisateur et pour chacun de ses codes gérés, on va chercher la liste des projets associés
        On cherche a voir pour un user tous les projets associés dans la liste de ses codes gérés*/
        
        for(User frontUser : users){
            List<String> codeDRGeres=frontUser.CodesDelegationsRegionalesGeres__c.split(';', -2);
            List<Opportunity> OpptiesTotal=new List<Opportunity>();
            List<Opportunity> OpptiesFrontLease=new List<Opportunity>();
            Decimal sommeTotalMontantfinancement=0;
            for(String codeDR :codeDRGeres){
                if(mapMontantFiancemenQPNL.get(codeDR)!=null){
                    sommeTotalMontantfinancement=sommeTotalMontantfinancement+mapMontantFiancemenQPNL.get(codeDR);
                }
                if(mapOpptyByCD.get(codeDR)!=null){
                   OpptiesTotal.addAll(mapOpptyByCD.get(codeDR)); 
                }
                if(mapOpptyByCDFrontLease.get(codeDR)!=null){
                   OpptiesFrontLease.addAll(mapOpptyByCDFrontLease.get(codeDR)); 
                }
                
            }
            Decimal percDossierPROSFrontLease=AP24_CalculRepereHandler.calculRapport(OpptiesFrontLease.size(),OpptiesTotal.size(),100);
            mapPercDossPROSFrontLease.put(frontUser.Id,percDossierPROSFrontLease);
            mapMontantFinancementUser.put(frontUser.Id,sommeTotalMontantfinancement);
            
        }
   
        Map<Id,ObjectifRealise__c> mapObjByUser=AP24_CalculRepereHandlerFront.getMapObjectifBycollab(mapPercDossPROSFrontLease.keyset(), 
                                                                                                     endDate.month(), 
                                                                                                     endDate.year());
            
     
        List<ObjectifRealise__c> objectifRealiseToUpsert=new List<ObjectifRealise__c>();
        
        for(Id userId :mapPercDossPROSFrontLease.keyset()){
            Id existingObjectifRealiseId=mapObjByUser.get(userId)!=null?mapObjByUser.get(userId).id:null;
            Decimal indicateurFrontLease=mapPercDossPROSFrontLease.get(userId);
            Decimal indicateurMontantQPNL=mapMontantFinancementUser.get(userId);
            
    
            ObjectifRealise__c objectifToUpsert=new ObjectifRealise__c(Id=existingObjectifRealiseId,
                                                                       Obj_ASSRC_QT1__c=indicateurFrontLease,
                                                                       Obj_COLL_Ass1__c=indicateurMontantQPNL,
                                                                       Mois__c=endDate.month(),
                                                                       annee__c=endDate.year() ,
                                                                       recordTypeId=idRecordTypeIndividuel
                                                                      );
            objectifRealiseToUpsert.add(objectifToUpsert);
        }
        //system.debug('@@ objectifRealiseToUpsert '+objectifRealiseToUpsert.size());
        Upsert objectifRealiseToUpsert;
    
    }
    
    public static void getMElValideurs(Date startDate,Date endDate){
        //Map<String,List<Case>> mapCasebyValideur=new Map<string,List<Case>>();
        Map<String,Integer> mapNbCasebyValideur=new Map<String,Integer>();
        Map<String,Integer> mapNbCaseDelaiOKbyValideur=new Map<String,Integer>();
        List<Case> listCase=[Select id,DecideurFinal__c,Delai_approbation_respecte__c
                             from Case 
                             where recordtype.developerName='CBM_Mise_en_place'
                             and status!='Annulée'
                             and DecideurFinal__c!=null
                             and StatutApprobation__c='2'
                             and ComplexiteFinale__c!='0 - Guépard'
                             and Date_de_traitement_de_la_MEL__c >=:startDate and Date_de_traitement_de_la_MEL__c <=:endDate
                             ];
     
        // system.debug('@@ listCase '+listCase.size());
            
            
        for(Case c:listCase){
            String valideur=c.DecideurFinal__c;
            if(mapNbCasebyValideur.containsKey(valideur) && mapNbCasebyValideur.get(valideur)!=null){
                Integer nbCase=mapNbCasebyValideur.get(valideur)+1;
                mapNbCasebyValideur.put(valideur,nbCase);
            }else{
                mapNbCasebyValideur.put(valideur,1);
            }
            if(c.Delai_approbation_respecte__c){
                if(mapNbCaseDelaiOKbyValideur.containsKey(valideur) && mapNbCaseDelaiOKbyValideur.get(valideur)!=null){
                    Integer nbCase=mapNbCaseDelaiOKbyValideur.get(valideur)+1;
                    mapNbCaseDelaiOKbyValideur.put(valideur,nbCase);
                }else{
                    mapNbCaseDelaiOKbyValideur.put(valideur,1);
                }
            }
        }  
        
        List<User> valideursList=[select id , name
                                  from user 
                                  where name in :mapNbCasebyValideur.keyset()];
        Map<Id,Decimal> mapTauxApproByValideur=new Map<Id,Decimal>();
        for(user valideur :valideursList){
            Integer nbCaseTotal=mapNbCasebyValideur.get(valideur.name);
            Integer nbCaseDelaiOk=mapNbCaseDelaiOKbyValideur.get(valideur.name);
            Decimal tauxAppro=0;
            if(nbCaseTotal!=null && nbCaseDelaiOk!=null){
               tauxAppro=AP24_CalculRepereHandler.calculRapport(nbCaseDelaiOk,nbCaseTotal,100);  
            }
          //  system.debug('@@ tauxAppro '+tauxAppro);
            mapTauxApproByValideur.put(valideur.Id, tauxAppro);
        } 
        
        //system.debug('@@ mapTauxApproByValideur '+mapTauxApproByValideur.size());
        Map<Id,ObjectifRealise__c> mapObjByUser=AP24_CalculRepereHandlerFront.getMapObjectifBycollab(mapTauxApproByValideur.keyset(), 
                                                                                                     endDate.month(), 
                                                                                                     endDate.year());
    
    //upsert des objectifs
    List<ObjectifRealise__c> listeORToUpdert=new List<ObjectifRealise__c>();
       for(Id userId : mapTauxApproByValideur.keyset()){
           ObjectifRealise__c existingOR=mapObjByUser.get(userId);
           Decimal tauxValidationMEL=mapTauxApproByValideur.get(userId);
           ObjectifRealise__c ORToUpset=new ObjectifRealise__c();
           ORToUpset.Id=existingOR!=null?existingOR.Id:null;
           ORToUpset.Obj_V_MEL_QT3__c=tauxValidationMEL;
           ORToUpset.Mois__c=endDate.month();
           ORToUpset.annee__c=endDate.year() ;
           ORToUpset.recordTypeId=idRecordTypeIndividuel;
           listeORToUpdert.add(ORToUpset);           
       }
        upsert listeORToUpdert;
    }
    
 
}