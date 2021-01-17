public class Ctrl09_ButtonAvenantFromDossier {
    public String idOpp{get; set; } 
    public String idDossier{get; set; } 
    public Contract Dossier {get; set; } 
  
    public Ctrl09_ButtonAvenantFromDossier(ApexPages.StandardController controller){
        idDossier =  ApexPages.currentPage().getParameters().get('ID');
        //ALM10291 - Ajout Client preneur Dossier / Autre tiers client preneur
        Dossier = [Select id, ProjetAssocie__c, Accountid, BienCBI__c, SocieteDeGestion__c, Nom_Client_preneur__c,Nom_Client_preneur__r.NomTeteDeGroupe__c, Name from Contract where id =: idDossier];
        if(Dossier.ProjetAssocie__c != NULL){
            idOpp = Dossier.ProjetAssocie__c;
        }else {
             idOpp = NULL;
        }
        
    }    
    public pagereference addCloneRelatedListToNewAvenant(){
     
     
     // On prépare le rollback
     System.Savepoint sp = Database.setSavepoint();
        
     //try{  
        
     Opportunity newOpty  = new Opportunity(); 
        
     User currentuser=new User();
     currentuser=[Select Id,Name,Email,UserByPassTriggers__c from User where Id=:userinfo.getuserId()];
     CurrentUser.UserByPassTriggers__c = 'OpportunityAfterInsert; DetailDuPoolBeforeUpdate; DetailDuPoolBeforeDelete; GarantieAfterUpdate; GarantieAfterDelete;ReseauApporteurAfterDelete; ReseauApporteurAfterInsert;ReseauApporteurAfterUpdate';
     update CurrentUser;

          recordtype RT = [SELECT Id,name,developername from recordtype where developername  = 'CBIAvenant'];
        if(idOpp != NULL ){
             list<PoolDeGarants__c> lPDGToNewOpp = new list<PoolDeGarants__c>();
             list<Garantie__c> lGarantiesToNewOpp = new list<Garantie__c>();  
             list<Detail_du_Pool__c> lDDPToNewOpp = new list<Detail_du_Pool__c>(); 
             list<ReseauApporteur__c> lReseauxApporteurToNewOpp = new list<ReseauApporteur__c>();
             list<OpportunityTeamMember> lOpportunityTeamMember = new list<OpportunityTeamMember>();
             list<OpportunitySplit> lOpportunitySplit = new list<OpportunitySplit>();
             list<OpportunityContactRole> lOpportunityContactRole = new list<OpportunityContactRole>();
          
            
             Opportunity optyToClone = [SELECT Id, Amount, StageName,CloseDate, Name,AssuranceDerogatoire__c,
                                    Commentaires__c,CommentairesComplementaires__c,CommissionCDFPercent__c,CommissionCDFMontant__c,
                                    CommissionSyndicationPercent__c,CommissionSyndicationMontant__c,
                                    DecisionDuWaiver__c,DureePreloyersTVAMois__c,JustificationProfilage__c,
                                    KYCEffectue__c,MontantAVPR__c,MontantSubvention__c,NEngagementV4__c,ObjetDuFinancement__c,PreloyersDeFinancement__c,PreloyersDeTVAPerc__c,
                                    PreloyersDEngagement__c,ProfilageDeLOperation__c,Taxation__c,TypeDOperation__c,TypePreloyersdEngagement__c,ValeurResiduellePourcentage__c,
                                    ValeurResiduelleMontant__c,ApporteurBPPresent__c,ApporteurCEPresent__c,Avenant__c,Chantier__c,ChargeDAffaireDuReseauAppPrNom__c,CodeTiersProjet__c,
                                    CommentairesDuProjetAssocie__c,CompletudePoolFinancement__c,Copropriete__c,
                                     DateComiteNatixisFormule__c,
                                    DateDecisionWaiverParent__c,DateDecisionComite__c,DateDecisionDuWaiver__c,DatedecisiondernierWaiverformule__c,
                                    DateDerniereNotificationWaiver__c,
                                    DateDossierCompletPourNotifWaver__c,
                                    DateEnvoiNotification__c,                                    
                                    DateRetourderniereNotifacceptWaiver__c,
                                    DateTransmissionAuServiceJuridique__c,
                                    DateTransmissionAvis__c,DateTransmissionWaiverLaDEC__c,
                                    DepotDeGarantie__c,DescriptionSynthetiqueOperationWF__c,Dossier__c,
                                    DureeDeValiditAccordComiteMois__c,DureeDeValiditeAccordReseauMois__c,DureeDeValiditeDeLaNotifMois__c,DureDuChantierMois__c,DureeValiditeDeLaPropositionMois__c,Enseigne__c,
                                    EnseignePourRecherche__c,FraisDossierQPNL__c,IDEvent1erContact__c,IDEvent1erRDV__c,IDParent__c,IntervenantsChantiers__c,IntervenantsJuristes__c,IntervenantsNotaires__c,
                                    Jalon__c,LeaseBack__c,LeaseOctroi__c,LieuDuFinancement__c,ListeDocArretee__c,Marche__c,MontantAutres__c,MontantBrutDeLaQPNL__c,MontantDuCBI__c,MontantHTAcquisitionImmeuble__c,
                                    MontantHTConstructionTravaux__c,MontantHTDuTerrain__c,MontantHTFraisAcquisition__c,MontantHTFraisDeCommercialisation__c,MontantNetDeLaQPNL__c,
                                    NBackV3__c,NDuDossierCassiopae__c,NomApporteurPrincipal__c,
                                    NomCompletCorrespndtDocOffclPS__c,NomCompletCorrespndtDocOffclPrincplF__c,NomCompletCorrespndtDocOffclSecondF__c,NomDuProjet__c,NotationWaiver__c,NouvelleEnseigne__c,NumeroDeProjetAssocie__c,
                                    NumeroDeWaiver__c,NumeroDuProjetAssocieParent__c,PhaseJalonF__c,Phase_Jalon__c,PhaseJalonPrecedent__c,PremierTiragePhaseChantier__c,ProprietaireProjetAssocie__c,RAF_BOA_Projet__c,
                                    RecordTypeDeveloperName__c,RemunerationAvancePreneur__c,SensibiliteReseau__c,
                                    SocieteDeGestion__c,TelephoneCommercial__c,TeteDeGroupe__c,
                                    TiersEnRisqueProfile__c,NomDuProjetAssocieParent__c,NumeroDeRang__c,NbAvenantsDuProjetAssocie__c,
                                    NbWaiversDuProjetAssocie__c,NbWaiversDuProjetAssocieParent__c,recordtypeid,FraisDeDossier__c,TotalDesMontantsDuProjetAssocie__c,TypeSeFinancement__c,TypeDePool__c,VEFA__c,
                                    WaiverEnCours__c,Accountid, CommentairesPDCValide__c  FROM Opportunity where id =: idOpp ];          
             
             newOpty = optyToClone.clone(false, true);      
           
            // Opportunity optyPAParent = [SELECT Id,name from Opportunity where id=:optyToClone.NomDuProjetAssocieParent__c ];
           
        // newOpty.Name = optyToClone.Name  + '_WAI_';
            if(optyToClone.NbAvenantsDuProjetAssocie__c == NULL){
                optyToClone.NbAvenantsDuProjetAssocie__c=0;
            }
                System.debug('*Nb Waivers de ce Projet Associé ' + optyToClone.NbAvenantsDuProjetAssocie__c); 
               if(optyToClone.NbAvenantsDuProjetAssocie__c+1 < 10) {
                     newOpty.Name = optyToClone.name  + '_AVN_0' + (optyToClone.NbAvenantsDuProjetAssocie__c+1); 
                 } else {
                     newOpty.Name = optyToClone.name  + '_AVN_' + (optyToClone.NbAvenantsDuProjetAssocie__c+1);  
                 }
           // Projet__c ProjetExistant = [ ];
                
             Account DossierName = [select id, name, NomTeteDeGroupe__c from Account where id=:Dossier.Accountid ];
             //ALM10291 - Nul besoin de requêter le client prenneur
             // On récupère le CLient Preneur 
             //Autre_Tiers__c ClientPreneur = [select id, name, Nom_du_Tiers__c, Nom_du_Tiers__r.NomTeteDeGroupe__c from Autre_Tiers__c where Numero_du_dossier__c=:Dossier.id and Role__c = 'Client preneur' LIMIT 1];
             // On récupère la tête de groupe si elle existe
             List<Autre_Tiers__c> TiersEnRisque = [select id, name, Nom_du_Tiers__c from Autre_Tiers__c where Numero_du_dossier__c=:Dossier.id and Role__c = 'Tiers en risque profilé' LIMIT 1];
            
             newOpty.NumeroDeProjetAssocie__c='Numérotation Auto';
             date myDate = date.today();
             date newDate = myDate.addYears(2);
             newDate = newDate.addDays(1); 
             newOpty.CloseDate = newDate;
             newOpty.IDParent__c = optyToClone.Id;  
             newOpty.NomDuProjetAssocieParent__c = optyToClone.NomDuProjetAssocieParent__c; 
             newOpty.NomDuWaiverPrecedent__c= optyToClone.Id; 
             newOpty.NomDuProjetAssociePrecedent__c = optyToClone.Id;
             newOpty.NumeroDeRang__c = 0;
             newOpty.NbAvenantsDuProjetAssocie__c= 0;
             newOpty.NbWaiversDuProjetAssocie__c = 0;  
             /*newOpty.DecisionWaiver__c = Null;*/
             newOpty.DateTransmissionWaiverLaDEC__c= Null; 
             newOpty.recordtypeid = RT.id;
             newOpty.StageName = 'Pré-Étude';
             newOpty.Jalon__c = 'Nouveau Projet';
             newOpty.Avenant__c = true;
             newOpty.DureeAvenant__c = 'Durée résiduelle CBIO';
             newOpty.TypeDOperation__c = null;
             newOpty.ContractId = Dossier.Id;
             newOpty.NDuDossierCassiopae__c = Dossier.Name;
            
             // Tiers
             newOpty.Accountid = Dossier.Nom_Client_preneur__c;
             if(TiersEnRisque.size() != 0){
                newOpty.TiersEnRisqueProfile__c =  TiersEnRisque[0].Nom_du_Tiers__c;
             }             
             newOpty.TeteDeGroupe__c = Dossier.Nom_Client_preneur__r.NomTeteDeGroupe__c;
                     
             insert newOpty;
          
             String optyParent; 
             optyParent = optyToClone.Id;
             
            ////////////////////////////////////////
            //////////Related List Pool de Garants
             PoolDeGarants__c[] existingPoolDeGarants = [   select id,ReseauAppartenancePartenaire__c, CodeTiers__c,CommissionDeRisque__c,
                                                            Inactif__c, /*JRMontant_del__c, */Partenaire__c,
                                                            Projet__c, ProjetAssocie__c, QuotePart__c,RecordTypeid
                                                            from PoolDeGarants__c 
                                                            where NomDuDossier__c =: idDossier
                                                        ];
             for (PoolDeGarants__c poolDeGarantToClone : existingPoolDeGarants) {   
                       PoolDeGarants__c PDGClone = new PoolDeGarants__c(); 
                       PDGClone = poolDeGarantToClone.clone(false, true);
                       PDGClone.ProjetAssocie__c = newOpty.id;
                       
                       lPDGToNewOpp.add(PDGClone); 
             }
            
             insert lPDGToNewOpp;
              ////////////////////////////////////////
              //////////Related List Garantie
             list<Garantie__c> ExistinglG = [select id, RecordTypeid,ComplementInformationGarantie__c,
                                            Montant__c,TiersCautionSiExistant__c,TiersCautionSiInconnu__c,
                                            Type__c,Description_PCOM__c,Acteur__c,CodeTiers__c,
                                            DateDeDebut__c, DateDeFin__c, Dossier__c, Etape__c,Inactif__c,
                                            NbAnneesContrat__c,NbAnneesLoyer__c,NomdelaProjetAssocie__c,
                                            NumeroRang__c,PhaseCompositionTexte__c,SiCautionPrecisez__c,
                                            TiersCaution__c
                                            from Garantie__c
                                            where Dossier__c =: idDossier ];
               for (Garantie__c result : ExistinglG) {   
                            Garantie__c PDGClone = new Garantie__c(); 
                            PDGClone = result.clone(false, true);
                            PDGClone.NomdelaProjetAssocie__c = newOpty.id;
                            PDGClone.Dossier__c = NULL;
                            lGarantiesToNewOpp.add(PDGClone); 
               } 
               insert lGarantiesToNewOpp; 
                ////////////////////////////////////////
               //////////Related List Detail du_Pool
               list<Detail_du_Pool__c> lDDP = [select id,name, Chef_de_file__c,Partenaire__c,ChefFileCroix__c,
                                                    /* JR MontantCalcule__c,*/NomDuPartenaire__c,NumAutoPoolDeFinancement__c,
                                                    ChefDeFileF__c, CodeTiers__c,CommissionDeRisque__c,FraisDeDossier__c,
                                                    FraisDossierQPNL__c,Inactif__c,/* JR Montant__c, */
                                                    Nom_du_Dossier__c,Projet__c,ProjetAssocie__c,QuotePartNL__c,Quote_part__c,
                                                    Statut_NL__c,TypeDePool__c
                                                    from Detail_du_Pool__c where Nom_du_Dossier__c =:  idDossier ];
            
                RecordType recordTypePoolCBI = [SELECT Id FROM RecordType WHERE DeveloperName = 'CBIDetailDuPoolFinancement' LIMIT 1];
            
                for(Detail_du_Pool__c DDP:lDDP){
                        Detail_du_Pool__c DDPClone = new Detail_du_Pool__c();                       
                        DDPClone = DDP.clone(false, true);
                        DDPClone.RecordTypeId = recordTypePoolCBI.Id;
                        DDPClone.ProjetAssocie__c = newOpty.id;
                        DDPClone.Partenaire__c = NULL;
                        //DDPClone.Nom_du_Dossier__c = label.ID_Dossier_Pool_Financement_Natixis_Lease;
                        system.debug('DDPClone.Partenaire__c ' + DDPClone.Partenaire__c);
                        lDDPToNewOpp.add(DDPClone);
                 }
                 insert lDDPToNewOpp;
             ////////////////////////////////////////
            //////////////////////////////////////////
                    list<ReseauApporteur__c> lReseauxApporteur = [select id, RecordTypeid,Account_ID__c,
                                             Account_Name__c,ApporteurPrincipal__c,  BanqueCaisseParent__c,
                                             ChargeDAffaire__c,  DateEntreeEnRelation__c,MatriculeReseau__c,
                                             NomDuProjetF__c, NomDuProjetAssocie__c,NomDuProjetAssocieF__c,
                                             NomDuTiersF__c,NomDuTiers__c,Reseau__c,ReseauF__c,ReseauDAppartenance__c,
                                             TypeDeReseau__c                
                                            from ReseauApporteur__c where NomDuProjetAssocie__c =: optyParent ];
                    
                    for(ReseauApporteur__c RA:lReseauxApporteur){
                        ReseauApporteur__c RAClone = new ReseauApporteur__c();
                        RAClone = RA.clone(false, true);
                        RAClone.NomDuProjetAssocie__c = newOpty.id;
                        lReseauxApporteurToNewOpp.add(RAClone);
                    } 
           insert lReseauxApporteurToNewOpp;
            ////////////////////////////////////////////////
            //
            //////////////////////////////////////////////////
                     list<OpportunityTeamMember> lOTM = [select id, CreatedByid,
                                                   LastModifiedByid,Opportunityid,OpportunityAccessLevel,
                                                   TeamMemberRole, Userid 
                                                   from OpportunityTeamMember where Opportunityid =: optyParent ];
                    
                    for(OpportunityTeamMember OTM:lOTM){
                        OpportunityTeamMember OTMClone = new OpportunityTeamMember();
                        OTMClone = OTM.clone(false, true);
                        OTMClone.Opportunityid = newOpty.id;
                        lOpportunityTeamMember.add(OTMClone);
                    } 
            insert lOpportunityTeamMember;

             List<OpportunityContactRole> OpportunityContactRoles =  [SELECT id , contactid
                                                      FROM OpportunityContactRole
                                                      WHERE OpportunityId = :optyParent];
                    
                    for(OpportunityContactRole OCR:OpportunityContactRoles){
                        OpportunityContactRole OCRClone = new OpportunityContactRole();
                        OCRClone = OCR.clone(false, true);
                        OCRClone.Opportunityid = newOpty.id;
                        lOpportunityContactRole.add(OCRClone);
                    } 
           insert lOpportunityContactRole;
            
        } else {
            
            Projet__c NewProjet = new Projet__c();
            id DossierAccountID = Dossier.Accountid;
            Account DossierName = [select id, name, NomTeteDeGroupe__c from Account where id=:DossierAccountID ];
            // On récupère le CLient Preneur 
             //Autre_Tiers__c ClientPreneur = [select id, name, Nom_du_Tiers__c, Nom_du_Tiers__r.NomTeteDeGroupe__c from Autre_Tiers__c where Numero_du_dossier__c=:Dossier.id and Role__c = 'Client preneur' LIMIT 1];
             // On récupère la tête de groupe si elle existe
             List<Autre_Tiers__c> TiersEnRisque = [select id, name, Nom_du_Tiers__c from Autre_Tiers__c where Numero_du_dossier__c=:Dossier.id and Role__c = 'Tiers en risque profilé' LIMIT 1];
            
            NewProjet.name =  DossierName.Name;
            
            // Tiers
             NewProjet.NomDuTiers__c = Dossier.Nom_Client_preneur__c;
             if(TiersEnRisque.size() != 0){
                NewProjet.Tiers_EnRisqueProfile__c =  TiersEnRisque[0].Nom_du_Tiers__c;
             }             
             NewProjet.TeteDeGroupe__c = Dossier.Nom_Client_preneur__r.NomTeteDeGroupe__c;
            NewProjet.RecordTypeId = UTL_Utils.getRecordTypeID(String.valueOf(Projet__c.getSObjectType()), 'CBIProjet');
 
            NewProjet.SocieteDeGestion__c = Dossier.SocieteDeGestion__c;
            insert NewProjet;
            
             list<Garantie__c> lGarantiesToNewOpp = new list<Garantie__c>();  
             list<Detail_du_Pool__c> lDDPToNewOpp = new list<Detail_du_Pool__c>(); 
             list<PoolDeGarants__c> lPDGToNewOpp = new list<PoolDeGarants__c>();          
            
             newOpty.name =  'Nom Automatique' ;
             newOpty.NumeroDeProjetAssocie__c='Numérotation Auto';
             date myDate = date.today();
             date newDate = myDate.addYears(2);
             newDate = newDate.addDays(1); 
             newOpty.CloseDate = newDate;    
             newOpty.NumeroDeRang__c = 0;
             newOpty.NbAvenantsDuProjetAssocie__c= 0;
             newOpty.NbWaiversDuProjetAssocie__c = 0;  
             /*newOpty.DecisionWaiver__c = Null;*/
             newOpty.DateTransmissionWaiverLaDEC__c= Null; 
             newOpty.recordtypeid = RT.id;
             newOpty.TypeDOperation__c = 'Acquisition';
             newOpty.StageName = 'Pré-Étude';
             newOpty.Jalon__c = 'Nouveau Projet';
             newOpty.NomDuProjet__c = NewProjet.id;
             newOpty.Avenant__c = true;
             newOpty.DureeAvenant__c = 'Durée résiduelle CBIO';
             newOpty.ContractId = Dossier.Id;
             newOpty.NDuDossierCassiopae__c = Dossier.Name;
            
            
             // Tiers
             newOpty.Accountid = Dossier.Nom_Client_preneur__c;
             if(TiersEnRisque.size() != 0){
                newOpty.TiersEnRisqueProfile__c =  TiersEnRisque[0].Nom_du_Tiers__c;
             }             
             newOpty.TeteDeGroupe__c = Dossier.Nom_Client_preneur__r.NomTeteDeGroupe__c;
            
            
             insert newOpty;
            
              ////////////////////////////////////////
            //////////Related List Pool de Garants
             PoolDeGarants__c[] existingPoolDeGarants = [   select id,ReseauAppartenancePartenaire__c, CodeTiers__c,CommissionDeRisque__c,
                                                            Inactif__c, Montant__c, Partenaire__c,
                                                            Projet__c, ProjetAssocie__c, QuotePart__c,RecordTypeid
                                                            from PoolDeGarants__c 
                                                            where NomDuDossier__c =: idDossier
                                                        ];
             for (PoolDeGarants__c poolDeGarantToClone : existingPoolDeGarants) {   
                       PoolDeGarants__c PDGClone = new PoolDeGarants__c(); 
                       PDGClone = poolDeGarantToClone.clone(false, true);
                       PDGClone.ProjetAssocie__c = newOpty.id;
                       lPDGToNewOpp.add(PDGClone); 
             }
            
             insert lPDGToNewOpp;
              ////////////////////////////////////////
              //////////Related List Garantie
             list<Garantie__c> ExistinglG = [select id, RecordTypeid,ComplementInformationGarantie__c,
                                            Montant__c,TiersCautionSiExistant__c,TiersCautionSiInconnu__c,
                                            Type__c,Description_PCOM__c,Acteur__c,CodeTiers__c,
                                            DateDeDebut__c, DateDeFin__c, Dossier__c, Etape__c,Inactif__c,
                                            NbAnneesContrat__c,NbAnneesLoyer__c,NomdelaProjetAssocie__c,
                                            NumeroRang__c,PhaseCompositionTexte__c,SiCautionPrecisez__c,
                                            TiersCaution__c
                                            from Garantie__c
                                            where Dossier__c =: idDossier ];
               for (Garantie__c result : ExistinglG) {   
                            Garantie__c PDGClone = new Garantie__c(); 
                            PDGClone = result.clone(false, true);
                            PDGClone.NomdelaProjetAssocie__c = newOpty.id;
                            PDGClone.Dossier__c = NULL;
                            lGarantiesToNewOpp.add(PDGClone); 
               } 
               insert lGarantiesToNewOpp; 
                ////////////////////////////////////////
               //////////Related List Detail du_Pool
               list<Detail_du_Pool__c> lDDP = [select id,name,Chef_de_file__c,Partenaire__c,ChefFileCroix__c,
                                                    NomDuPartenaire__c,NumAutoPoolDeFinancement__c,
                                                    ChefDeFileF__c, CodeTiers__c,CommissionDeRisque__c,FraisDeDossier__c,
                                                    FraisDossierQPNL__c,Inactif__c,Montant__c,
                                                    Nom_du_Dossier__c,Projet__c,ProjetAssocie__c,QuotePartNL__c,Quote_part__c,
                                                    Statut_NL__c,TypeDePool__c
                                                    from Detail_du_Pool__c where Nom_du_Dossier__c =:  idDossier ];
            
                RecordType recordTypePoolCBI = [SELECT Id FROM RecordType WHERE DeveloperName = 'CBIDetailDuPoolFinancement' LIMIT 1];
      
                for(Detail_du_Pool__c DDP:lDDP){
                        Detail_du_Pool__c DDPClone = new Detail_du_Pool__c();                    
                        DDPClone = DDP.clone(false, true);
                        DDPClone.RecordTypeId = recordTypePoolCBI.Id;
                        DDPClone.ProjetAssocie__c = newOpty.id;
                        DDPClone.Partenaire__c = NULL;
                        //DDPClone.Nom_du_Dossier__c = label.ID_Dossier_Pool_Financement_Natixis_Lease;
                        lDDPToNewOpp.add(DDPClone);
                 }
                 insert lDDPToNewOpp;
            ////////////////////////////////////////
               //////////Liste de Bien
            if( Dossier.BienCBI__c != NULL ) {
                  ListeDeBien__c LDB = new ListeDeBien__c();
                             
                LDB.Description__c= NULL;  
                LDB.IDPoolDeBien__c = NULL;
                LDB.Projet__c = NewProjet.id;
                LDB.Type__c = NULL; 
                LDB.Biens__c=Dossier.BienCBI__c;
                  insert LDB;
            }
             
            
              
            
        }
 
      CurrentUser.UserByPassTriggers__c = '';
      update CurrentUser;
      System.debug('fin try méthode');
        // System.debug( 'La new Opty id ' + newOpty.id + 'La new Opty ' + newOpty);
         PageReference pageRef = new PageReference('/' + newOpty.id);
          
         return PageRef.setRedirect(True);
         
     /*}
     catch(Exception ex){
         System.debug('fin méthode');
      Database.rollback(sp); 
        return null;
  }*/
         
      
    }
    
    public void isAlreadyAskingBySameUserInDay(){
        displayPopup = true;  
    }
    
    public boolean displayPopup {get; set;}     
    
        public PageReference closePopup() {        
            displayPopup = false;  
            return new PageReference('/'+ApexPages.currentPage().getParameters().get('ID'));
        }     
        public PageReference validePopup() {        
            displayPopup = false; 
            return addCloneRelatedListToNewAvenant();
        }
}