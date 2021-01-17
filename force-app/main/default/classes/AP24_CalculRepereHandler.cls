public class AP24_CalculRepereHandler {

    
    /*public static Date startDate=Date.newInstance(system.today().addDays(-100).year(), 1, 1);
    public static Integer moisEnCours=system.today().addDays(-1).month();
    public static Integer anneeEnCours=system.today().addDays(-1).year();*/
    public static Id idRecordTypeCollectif = Schema.SObjectType.ObjectifRealise__c.getRecordTypeInfosByDeveloperName().get('Collectif').getRecordTypeId();        
    public static Id idRecordTypeIndividuel = Schema.SObjectType.ObjectifRealise__c.getRecordTypeInfosByDeveloperName().get('Individuel').getRecordTypeId();
     
    public static void calculIndicateurMEL(List<Case> casesMEL,Integer moisEnCours,Integer anneeEnCours,Date startDate){
        system.debug('@@ casesMEL '+casesMEL.size());    
        /*Etape 1 calcul des indicateurs collectifs*/
        WrapObjectifMEL objCollectif= new WrapObjectifMEL(casesMEL,true,startDate);
        Id objectifCollectifID=null;
        ObjectifRealise__c objectifCollectif=new ObjectifRealise__c();        
        objectifCollectif.recordTypeId=idRecordTypeCollectif;
        objectifCollectif.Obj_COLL_MEL1__c=objCollectif.percDelaiMiseEnLoyerOK;
        objectifCollectif.Annee__c=anneeEnCours;
        objectifCollectif.Mois__c=moisEnCours;
        try{
            insert objectifCollectif;
            objectifCollectifID=objectifCollectif.Id;
        }
        catch(Exception e){
            system.debug('@@ probleme lors de l\'insertion de lobjectif collectif');
        }
        /*etape 2  calcul des indicateurs MEL par user*/
        Map<Id,List<Case>> mapCaseByOwner=new Map<Id,List<Case>>();
        for(Case c :casesMEL){
            system.debug('@@ c.owner.type '+c.owner.type);
            system.debug('@@ c.owner.name '+c.owner.name);
            //'User'.equalsIgnoreCase(c.owner.type) || 
            if(string.valueOf(c.OwnerId).startsWith('005')){
                 If(mapCaseByOwner.containsKey(c.OwnerId)){
                    mapCaseByOwner.get(c.OwnerId).add(c);               
                    }
                    else{
                        mapCaseByOwner.put(c.OwnerId,new List<Case>{c});
                    }
            }                      
        }
        List<ObjectifRealise__c> objectifIndividuels=new List<ObjectifRealise__c>();
        for(Id idUser :mapCaseByOwner.keyset()){
            WrapObjectifMEL objIndiv= new WrapObjectifMEL(mapCaseByOwner.get(idUser),false,startDate);
            ObjectifRealise__c obj =new ObjectifRealise__c();
            obj.recordTypeId=idRecordTypeIndividuel;
            obj.Annee__c=anneeEnCours;
            obj.Mois__c=moisEnCours;
            obj.Collaborateur__c=idUser;
            obj.ObjectifcollectifRealise__c=objectifCollectifID;
            obj.Obj_MEL_QT1__c=objIndiv.nbMoyenDeMEL;
            obj.Obj_MEL_QL1__c=objIndiv.percMELPriseEnChargeOuRelanceOK;
            obj.Obj_MEL_QL2__c=objIndiv.percRejet;
            objectifIndividuels.add(obj);
            system.debug('@@ objIndiv '+objIndiv);
        }
		
        insert objectifIndividuels;
    }
    
    public static void calculIndicateurSAV(List<Case> casesSAV,Integer moisEnCours,Integer anneeEnCours,Date startDate){
        Id idRecordTypeCollectif = Schema.SObjectType.ObjectifRealise__c.getRecordTypeInfosByDeveloperName().get('Collectif').getRecordTypeId();        
        Id idRecordTypeIndividuel = Schema.SObjectType.ObjectifRealise__c.getRecordTypeInfosByDeveloperName().get('Individuel').getRecordTypeId();
        
        List<ObjectifRealise__c> ObjectifsExistants=[select id ,Collaborateur__c,recordTypeId
                                          from ObjectifRealise__c 
                                          where recordTypeId in (:idRecordTypeCollectif, :idRecordTypeIndividuel)
                                          and Annee__c=:anneeEnCours
                                          and Mois__c=:moisEnCours];
        Id objCollectifId=null;
        Map<Id,Id> MapRealiseByUser=new Map<Id,Id>();
        for(ObjectifRealise__c realise : ObjectifsExistants){
            if(realise.recordTypeId==idRecordTypeCollectif){
                objCollectifId=realise.Id;
            }
            else{
                MapRealiseByUser.put(realise.Collaborateur__c, realise.Id);
            }
        }
        
        /*Etape 1 calcul des indicateurs collectifs*/
        WrapObjectifSAV objCollectifWrap= new WrapObjectifSAV(casesSAV);       
        ObjectifRealise__c objectifCollectif=new ObjectifRealise__c();    
        objectifCollectif.Id=objCollectifId;
       objectifCollectif.Obj_COLL_SAV1__c=objCollectifWrap.percSAVCTDelaiOK;
        objectifCollectif.Obj_COLL_SAV2__c=objCollectifWrap.percSAVMTDelaiOK;
        objectifCollectif.Obj_COLL_SAV3__c=objCollectifWrap.percSAVLTDelaiOK;
        objectifCollectif.recordTypeId=idRecordTypeCollectif;
        objectifCollectif.Annee__c=anneeEnCours;
        objectifCollectif.Mois__c=moisEnCours;
        try{
            update objectifCollectif;
            
        }
        catch(Exception e){
            system.debug('@@ probleme lors de l\'update de lobjectif collectif');
        }
        /*etape 2  calcul des indicateurs SAV par user*/
        Map<Id,List<Case>> mapCaseByOwner=new Map<Id,List<Case>>();
        for(Case c :casesSAV){
            //'User'.equalsIgnoreCase(c.owner.type)
            if(string.valueOf(c.OwnerId).startsWith('005')){
                 If(mapCaseByOwner.containsKey(c.OwnerId)){
                    mapCaseByOwner.get(c.OwnerId).add(c);               
                    }
                    else{
                        mapCaseByOwner.put(c.OwnerId,new List<Case>{c});
                    }
            }                      
        }
        List<ObjectifRealise__c> objectifIndividuels=new List<ObjectifRealise__c>();
        for(Id idUser :mapCaseByOwner.keyset()){
            Id existant=MapRealiseByUser.get(idUser);
            WrapObjectifSAV objIndiv= new WrapObjectifSAV(mapCaseByOwner.get(idUser));
            ObjectifRealise__c obj =new ObjectifRealise__c();
            obj.Id=existant;
            obj.recordTypeId=idRecordTypeIndividuel;
            obj.Annee__c=anneeEnCours;
            obj.Mois__c=moisEnCours;
            obj.Collaborateur__c=idUser;
            obj.ObjectifcollectifRealise__c=objCollectifId;
            obj.Obj_SAV_QL1__c=objIndiv.percSAVCTDelaiOK;
            obj.Obj_SAV_QL2__c=objIndiv.percSAVMTDelaiOK;
            obj.Obj_SAV_QL3__c=objIndiv.percSAVLTDelaiOK;
            obj.Obj_SAV_QT1__c=objIndiv.nbSAVCT;
            obj.Obj_SAV_QT2__c=objIndiv.nbSAVMT;
            obj.Obj_SAV_QT3__c=objIndiv.nbSAVLT;
            objectifIndividuels.add(obj);
        }
        
        upsert objectifIndividuels;
        
    }

    
    
    public class WrapObjectifMEL{
        /* indicateur collectif Obj_COLL_MEL1__c*/
        public Decimal percDelaiMiseEnLoyerOK {get; set;}
        /* indicateur individuel Obj_MEL_QT1__c */
        public Decimal nbMoyenDeMEL {get; set;}
        /* indicateur individuel Obj_MEL_QL2__c : nb de rejet MEL*/
		public Decimal percRejet {get; set;}  
        /* indicateur individuel Obj_MEL_QL1__c : relance ou prise en charge avec motif et date a revoir rempli */
        public Decimal percMELPriseEnChargeOuRelanceOK {get; set;} 
       
        public WrapObjectifMEL(List<Case> casesMEL,Boolean iscollectif,Date startDate){
        /*Unite SRC CBM  	1 - CBM SRC 1
                            2 - CBM SRC 2 & 4
                            3 - CBM SRC 3
                            4 - CBM SRC GC
                            5 - CBM SRC Service
                            15 - CBM SRC EXT
                            17 - CBM SSRC*/
            
        Set<String> setUnite=new Set<String>{'1','2','3','4','5','15','17'};
        Decimal nbMEL=0;
        Decimal nbDelaiMiseEnLoyerOK=0;
        Decimal nbApprobation=0;
        Decimal nbRejet=0;
        Decimal nbMELPriseEnChargeOuRelance=0;
        Decimal nbMELPriseEnChargeOuRelanceOK=0;
        Set<Date> datesTravailles= new Set<Date>();
        for(Case c :casesMEL){
            system.debug('@@ cUniteSRC__c ' +c.UniteSRC__c);
             system.debug('@@ cDate_de_traitement_de_la_MEL__c ' +c.Date_de_traitement_de_la_MEL__c);
            system.debug('@@ startDate ' +startDate);
                if(setUnite.contains(c.UniteSRC__c) && c.Date_de_traitement_de_la_MEL__c>=startDate){
                    system.debug('@@ je rentre ici');
                  /* Demande de mise en place qui ont été mis en loyer*/
                  nbMEL++;  
                  datesTravailles.add(c.Date_de_traitement_de_la_MEL__c);
                  if(c.DelaiMiseLoyer__c<=5 && !c.Dossier1__r.Prefinancement_en_cours_ou_termine__c){
                      nbDelaiMiseEnLoyerOK++;     
                   }
                   
                    system.debug('@@ c.ComplexiteFinale__c '+c.ComplexiteFinale__c); 
                    system.debug('@@ c.ComplexiteFinale__c '+c.StatutApprobation__c);  
                   /* Date MEL sur l'année,different de guepard,Approuvé  ou rejeté  ou (en cours et rejet historique) */
                    if(!isCollectif && !'0 - Guépard'.equalsIgnoreCase(c.ComplexiteFinale__c) && (c.StatutApprobation__c=='2'  || c.StatutApprobation__c=='3' 
                      || (c.StatutApprobation__c=='1' && c.Rejet_historique__c )) ){
                          
                            nbApprobation++;
                              if(c.Rejet_historique__c ){
                               

                                 nbRejet++;
                        	}
                   	}
                    
            	}
                  /* % de demandes de MEL prises en charge ou en relance avec une date à revoir et un motif à revoir renseigner */
                    if(!isCollectif && ('Prise en charge'.equalsIgnoreCase(c.status) || 'Relance'.equalsIgnoreCase(c.status))){
                       // system.debug('prise en charge ou relance');
                        nbMELPriseEnChargeOuRelance++;
                        If(!String.isBlank(c.Motif_a_revoir__c) && c.Date_revoir__c!=null && !c.isClosed){
                          //  system.debug('Motif_a_revoir__c ');
                            nbMELPriseEnChargeOuRelanceOK++;
                        }
                    }
                   
                      
            }
           
            this.percDelaiMiseEnLoyerOK=calculRapport(nbDelaiMiseEnLoyerOK,nbMEL,100); 
            if(!iscollectif){
               
               Decimal nbTravailles=datesTravailles.size();
                 system.debug('@@ nbTravailles '+nbTravailles);
                 system.debug('@@ nbMEL '+nbMEL);
               this.nbMoyenDeMEL=calculRapport(nbMEL,nbTravailles,1); 
               this.percRejet=calculRapport((nbApprobation-nbRejet),nbApprobation,100); 
               this.percMELPriseEnChargeOuRelanceOK=calculRapport(nbMELPriseEnChargeOuRelanceOK,nbMELPriseEnChargeOuRelance,100);
                
            }
            system.debug('@@ nbMoyenDeMEL '+nbMoyenDeMEL);
        }
    }
    
    public static Decimal calculRapport(Decimal part, Decimal total,Integer base){
        Decimal pourcentage=0;
        if(total>0){           
            pourcentage=(part/total)*base;
        }
        //system.debug('@@ pourcentage '+pourcentage);
        return pourcentage;
    }
    
    
     public class WrapObjectifSAV{
        /* indicateur collectif Obj_COLL_SAV1__c ou individuel Obj_SAV_QL1__c */
        public Decimal percSAVCTDelaiOK {get; set;}
        /* indicateur collectif Obj_COLL_SAV2__c ou individuel Obj_SAV_QL2__c */
        public Decimal percSAVMTDelaiOK {get; set;}
        /* indicateur collectif Obj_COLL_SAV3__c ou individuel Obj_SAV_QL3__c */
		public Decimal percSAVLTDelaiOK {get; set;}  
        /* indicateur individuel Obj_SAV_QT1__c : nb CT */
        public Decimal nbSAVCT {get; set;} 
        /* indicateur individuel Obj_SAV_QT2__c : nb MT */
        public Decimal nbSAVMT {get; set;} 
        /* indicateur individuel Obj_SAV_QT3__c : nb LT */
        public Decimal nbSAVLT {get; set;} 
        
       
        public WrapObjectifSAV(List<Case> casesSAV){
            Integer nbLTSAV=0;
            Integer nbLTSAVDelaiOK=0;
            Integer nbMTSAV=0;
            Integer nbMTSAVDelaiOK=0;
            Integer nbCTSAV=0;
            Integer nbCTSAVDelaiOK=0;
            for(Case c :casesSAV){                
            	//if(c.Complexite_SAV__c!=null   && c.isClosed   && setUnite.contains(c.UniteSRC__c)  && c.ClosedDate>=startDate){
                      if('Type 3: LT'.equalsIgnoreCase(c.Complexite_SAV__c)){
                         // listLTSAV.add(c.Delai_PEC_Terminee__c);
                          nbLTSAV++;
                          if(c.Delai_PEC_Terminee__c<=55){
                            nbLTSAVDelaiOK++;
                          }
                      }
                      else if('Type 2: MT'.equalsIgnoreCase(c.Complexite_SAV__c)){
                          //listMTSAV.add(c.Delai_PEC_Terminee__c);
                          nbMTSAV++;
                          if(c.Delai_PEC_Terminee__c<=10){
                            nbMTSAVDelaiOK++;
                          }
                      }
                      else if('Type 1: CT'.equalsIgnoreCase(c.Complexite_SAV__c)){
                          // listCTSAV.add(c.Delai_PEC_Terminee__c);
                          nbCTSAV++;
                          if(c.Delai_PEC_Terminee__c<=4){
                            nbCTSAVDelaiOK++;
                          }
                      }
                         
             //}
            }
         
            this.nbSAVLT =nbLTSAV;
            this.nbSAVMT =nbMTSAV;
            this.nbSAVCT =nbCTSAV;
            this.percSAVLTDelaiOK=calculRapport(nbLTSAVDelaiOK,nbLTSAV,100);
            this.percSAVMTDelaiOK=calculRapport(nbMTSAVDelaiOK,nbMTSAV,100);
            this.percSAVCTDelaiOK=calculRapport(nbCTSAVDelaiOK,nbCTSAV,100);
        }
     }
}