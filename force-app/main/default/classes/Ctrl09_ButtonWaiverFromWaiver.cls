public class Ctrl09_ButtonWaiverFromWaiver {
    
    public String idOpp{get; set; } 
    public Boolean isWaiversTermines {get; set; }
    public Boolean isAvtInitialDecide {get; set; }
    public Integer nbWaiversDecide {get; set; }
    public String messageErreur {get; set;}
 
    public Ctrl09_ButtonWaiverFromWaiver(ApexPages.StandardController controller){
        
        idOpp =  ApexPages.currentPage().getParameters().get('ID');
        isWaiversTermines = true;
        isAvtInitialDecide = true;
        nbWaiversDecide = 0;
        
        //Waiver en cours de traitement
        Opportunity currentWaiver = [SELECT Id, NomDuProjetAssocieParent__c FROM Opportunity WHERE Id = :idOpp LIMIT 1];
        
        //Projet Associe initial
        Opportunity avenant = [SELECT Id, StageName FROM Opportunity WHERE Id = :currentWaiver.NomDuProjetAssocieParent__c LIMIT 1];
        
        // Waivers associés à l'Avenant
        List<Opportunity> waiverList = [SELECT Id, StageName FROM Opportunity WHERE RecordType.DeveloperName = 'CBIWaiver'
                                                                                AND NomDuProjetAssocieParent__c = :avenant.Id
                                                                                AND Id != :currentWaiver.Id];
        
        // L'avenant doit être au moins en Phase 'Décidé' pour créer un nouveau Waiver
        if(avenant.StageName == 'Pré-Étude' || avenant.StageName == 'Étude' || avenant.StageName == 'Octroi'){
            isAvtInitialDecide = false;
        }
        
        // Tous les Waivers associés doivent être en Phase 'Terminé' ou Décidé et le nombre de Waivers en Décidé ne doit pas être supérieur
        // à 1.
        for(Opportunity waiver : waiverList){
            if(waiver.StageName != 'Terminé' && waiver.StageName != 'Décidé' && waiver.StageName != 'Waiver' && waiver.StageName != 'Notification'){
                isWaiversTermines = false;
            }
            if(waiver.StageName == 'Décidé'){
                nbWaiversDecide++;
            }
        }
 
    }    
    public pagereference addCloneRelatedListToNewWaiver(){
    
     // On prépare le rollback
     System.Savepoint sp = Database.setSavepoint();
        
     try{ 
         
     Opportunity newOpty  = new Opportunity(); 
        
     User currentuser = new User();
     currentuser = [SELECT Id,Name,Email,UserByPassTriggers__c FROM User WHERE Id =: userinfo.getuserId()];
     CurrentUser.UserByPassTriggers__c = 'DetailDuPoolAfterInsert; DetailDuPoolBeforeUpdate; DetailDuPoolBeforeDelete; GarantieAfterUpdate; GarantieAfterDelete;ReseauApporteurAfterDelete; ReseauApporteurAfterInsert;ReseauApporteurAfterUpdate;CalculetteROEBeforeUpdate;BienAfterInsert; CalculetteROEBeforeUpdate; CaseAfterDelete; CaseAfterInsert; CaseAfterUnDelete; CaseAfterUpdate; CaseBeforeDelete; CaseBeforeInsert; CaseBeforeUpdate; ContentDocumentAfterUpdate; ContentDocumentBeforeUpdate; ContentVersionBeforeInsert; ContractAfterUpdate; CreateCommentCase; DetailDuPoolBeforeDelete; DetailDuPoolBeforeInsert; DetailDuPoolBeforeUpdate; DossierAfterDelete; DossierAfterInsert; DossierAfterUpdate; EmailAfterInsert; EmailBeforeDelete; EmailBeforeInsert; EventAfterInsert; EventBeforeInsert; EventBeforeUpdate; FactureAfterDelete; FactureAfterInsert; FactureAfterUnDelete; FactureAfterUpdate; FillNotaireCase; GarantieAfterDelete; GarantieAfterInsert; GarantieAfterUpdate; ListeBienAfterDelete; ListeDeBienAfterInsert; NoteComiteAfterDelete; NoteComiteAfterInsert; NoteComiteAfterUpdate; NoteComiteBeforeInsert; NoteComiteBeforeUpdate; OpportunityAfterInsert; OpportunityAfterUpdate; OpportunityBeforeDelete; OpportunityBeforeUpdate; OpportunitySplitAfterInsert; PhaseBienAfterDelete; PhaseBienAfterInsert; PhaseBienAfterUpdate; PhaseBienBeforeInsert; PoolDeGarantsAfterDelete; PoolDeGarantsAfterInsert; PoolDeGarantsAfterUpdate; ProjetAfterInsert; QuoteAfterDelete; QuoteAfterInsert; QuoteAfterUpdate; ReseauApporteurAfterDelete; ReseauApporteurAfterInsert; ReseauApporteurAfterUpdate; MAJArevoirDemandeAjour; TR001ManageCase; TR001ManageCase_CalculFacture; TR001ManageCase_CalculPhase; TR001ManageCase_DisableDeleteCase; TR001ManageCase_updateSupportUser; TR001ManageCaseSaufImpaye; TR002ManageCase_Attribution; TR002ManageCase_Attribution_Automatique; TR002ManageContract; TR002ManageContract_MAJDateMEL; TR002ManageContract_NomTiers; LLD_LeadConversion';
     update CurrentUser;
     system.debug('@@@@@@@@@@@@@@@@@@@@@CurrentUser.UserByPassTriggers__c '+[SELECT Id, UserByPassTriggers__c FROM User WHERE Id =: userinfo.getUserId()].UserByPassTriggers__c );
     system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@currentuser  '+currentuser);
     // List<SelectOption> options = new List<SelectOption>();
       //     Schema.DescribeFieldResult fieldResult =  User.UserByPassTriggers.getPicklistValues();
         //      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      
      
          //CurrentUser.UserByPassTriggers__c.add();
        //UserByPassTriggers__c
        
         list<PoolDeGarants__c> lPDGToNewOpp = new list<PoolDeGarants__c>();
         list<Garantie__c> lGarantiesToNewOpp = new list<Garantie__c>();  
         list<Detail_du_Pool__c> lDDPToNewOpp = new list<Detail_du_Pool__c>(); 
         list<ReseauApporteur__c> lReseauxApporteurToNewOpp = new list<ReseauApporteur__c>();
         list<OpportunityTeamMember> lOpportunityTeamMember = new list<OpportunityTeamMember>();
         list<OpportunitySplit> lOpportunitySplit = new list<OpportunitySplit>();
      
         Opportunity optyToClone = [SELECT Id, Amount, AccountId ,StageName,CloseDate, Name,AssuranceDerogatoire__c,AvisDirectionCommerciale__c,AvisDirectionEngagement__c,
                                    AvisDuCommercial__c,Commentaires__c,CommentairesComplementaires__c,CommissionCDFPercent__c,CommissionCDFMontant__c,
                                    CommissionSyndicationPercent__c,CommissionSyndicationMontant__c,DateDecisionComiteNatixis__c,DateDecisionComiteNatixisLease__c,
                                    DecisionComiteNatixis__c,DecisionComiteNatixisLease__c,DecisionDuWaiver__c,DureePreloyersTVAMois__c,DureeReelle__c,JustificationProfilage__c,
                                    KYCEffectue__c,MontantAVPR__c,MontantSubvention__c,NiveauDecision__c,ObjetDuFinancement__c,PreloyersDeFinancement__c,PreloyersDeTVAPerc__c,
                                    PreloyersDEngagement__c,ProfilageDeLOperation__c,Taxation__c,TypeDOperation__c,TypePreloyersdEngagement__c,ValeurResiduellePourcentage__c,
                                    ValeurResiduelleMontant__c,ApporteurBPPresent__c,ApporteurCEPresent__c, Avenant__c, DureeAvenant__c, Chantier__c,ChargeDAffaireDuReseauAppPrNom__c,CodeTiersProjet__c,
                                    CommentairesDuProjetAssocie__c,CompletudePoolFinancement__c,Copropriete__c,CPI__c,CRL__c,Date1erContact__c,Date1erRDVClient__c,DateAccordReseau__c,
                                    DateAvisDeLaDirectionCommerciale__c,DateAvisDeLaDirectionDesRisques__c,DateAvisDeLaDirectionEngagement__c,DateAvisDuCommercial__c,DateComiteNatixisFormule__c,
                                    DateDecisionWaiverParent__c,DateDecisionComite__c,DateDecisionDuWaiver__c,DatedecisiondernierWaiverformule__c,DateDeDebutDeFinancement__c,DateDeFinDeFinancement__c,
                                    DatedePassageEnPrecomitOuBuscom__c,DateDerniereNotificationWaiver__c,DateDernierRDVClient__c,DateDeSignature__c,DateDossierCompletPourAvis__c,DateDossierCompletPourDecision__c,
                                    DateDossierCompletpourNotification__c,DateDossierCompletPourNotifWaver__c,DateDossierEngageSaisieKSIOP__c,DateEmissionNotification__c,DateEmissionOkPool__c,DateEntreeEnPhaseJuridique__c,
                                    DateEnvoiNotification__c,DateFinTrimestreAnneeCivile__c,DateLimiteAccordComite__c,DateLimiteAccordReseau__c,DatelimiteNotification__c,DateOptionDeTVA__c,DatePassageEnSansSuite__c,
                                    DatePDCSouhaitee__c,DatePDCValidee__c,DatePreoptionDeTVA__c,DatePrevisionsDeSignature__c,DatePropositionAcceptee__c,DatePropositionEnvoyee__c,DateReceptionDecisionReseau__c,
                                    DateReceptionPartenaire1Pool__c,DateReceptionPartenaire2Pool__c,DateReceptionPartenaire3Pool__c,DateRetourderniereNotifacceptWaiver__c,
                                    DateRetourFaisabiliteDuDossier__c,DateRetourNotificationClient__c,DateTransmissionAuMO__c,DateTransmissionAuServiceJuridique__c,
                                    DateTransmissionAvisDirectionRisques__c,DateDeTransmissionDirectionEngagement__c,DateTransmissionGestion__c,DateTransmissionAvis__c,DateTransmissionWaiverLaDEC__c,
                                    DateValidationDuCialDeLaNotif__c,DateValidationKSIOP__c,DecisionNotificationClient__c,DepotDeGarantie__c,DescriptionSynthetiqueOperationWF__c,Dossier__c,DureeDeFinancementTrismestre__c,
                                    DureeDeValiditAccordComiteMois__c,DureeDeValiditeAccordReseauMois__c,DureeDeValiditeDeLaNotifMois__c,DureDuChantierMois__c,DureeValiditeDeLaPropositionMois__c,Enseigne__c,
                                    EnseignePourRecherche__c,FraisDossierQPNL__c,IDEvent1erContact__c,IDEvent1erRDV__c,IDParent__c,IntervenantsChantiers__c,IntervenantsJuristes__c,IntervenantsNotaires__c,
                                    Jalon__c,LeaseBack__c,LeaseOctroi__c,LieuDuFinancement__c,ListeDocArretee__c,Marche__c,MontantAutres__c,MontantBrutDeLaQPNL__c,MontantDuCBI__c,MontantHTAcquisitionImmeuble__c,
                                    MontantHTConstructionTravaux__c,MontantHTDuTerrain__c,MontantHTFraisAcquisition__c,MontantHTFraisDeCommercialisation__c,MontantLoyerSubvention__c,MontantNetDeLaQPNL__c,
                                    MontantPreloyerEngOuAcompteHT__c,MontantPreloyerEngOuAcompteTTC__c,Motif__c,NBackV3__c,NDuDossierCassiopae__c,NomApporteurPrincipal__c,NombreDeTrimestre__c,
                                    NomCompletCorrespndtDocOffclPS__c,NomCompletCorrespndtDocOffclPrincplF__c,NomCompletCorrespndtDocOffclSecondF__c,NomDuProjet__c,NotationWaiver__c,NouvelleEnseigne__c,NumeroDeProjetAssocie__c,
                                    NumeroDeWaiver__c,NumeroDuProjetAssocieParent__c,PhaseJalonF__c,Phase_Jalon__c,PhaseJalonPrecedent__c,PremierTiragePhaseChantier__c,ProprietaireProjetAssocie__c,RAF_BOA_Projet__c,
                                    RecordTypeDeveloperName__c,RemunerationAvancePreneur__c,SensibiliteReseau__c,SiDateDossierEngageVide__c,SiDateOptionDeTVAVide__c,SiDatePreOptionDeTVAVide__c,
                                    SiDateTransmissionGestionVide__c,SiDateValidationKSIOP__c,SocieteDeGestion__c,SubventionOctroyee__c,TauxTVAApplique__c,TelephoneCommercial__c,TeteDeGroupe__c,
                                    TiersEnRisqueProfile__c,FraisDeDossier__c,TotalDesMontantsDuProjetAssocie__c,TypeSeFinancement__c,TypeDePool__c,VEFA__c,
                                    WaiverEnCours__c,recordtypeid,NomDuProjetAssocieParent__c,NumeroDeRang__c,NomDuWaiverPrecedent__c,
                                    NbWaiversDuProjetAssocie__c,NbWaiversDuProjetAssocieParent__c,NbAvenantsDuProjetAssocie__c,
                                    NbDePoolFinancement__c,NBChefDeFilePoolDeFinancement__c,MontantTotalPoolDeFinancement__c,QuotePartTotalPoolDeFinancement__c,QuotePartNL__c, CommentairesPDCValide__c, CBI_rechargeable__c  FROM Opportunity where id =: idOpp ];         
         
       
         newOpty = optyToClone.clone(false, true);      
         recordtype RT = [SELECT Id,name,developername from recordtype where developername  = 'CBIWaiver'];
         Opportunity optyPAParent = [SELECT Id,name from Opportunity where id=:optyToClone.NomDuProjetAssocieParent__c ];
         System.debug('OPTYTOCLONE' + optyToClone.NbWaiversDuProjetAssocieParent__c);
         if(optyToClone.NbWaiversDuProjetAssocieParent__c + 1 < 10) {
             newOpty.Name = optyPAParent.name  + '_WAI_0' + (optyToClone.NbWaiversDuProjetAssocieParent__c+1); 
         } else {
             newOpty.Name = optyPAParent.name  + '_WAI_' + (optyToClone.NbWaiversDuProjetAssocieParent__c+1);  
         }
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
         newOpty.DecisionDuWaiver__c = Null;
         newOpty.DateDecisionDuWaiver__c = Null;
         newOpty.DateTransmissionWaiverLaDEC__c= Null; 
         newOpty.recordtypeid = RT.id;
         newOpty.StageName = 'Waiver';
         newOpty.Jalon__c = 'Waiver';
         newOpty.Motif__c = Null;
         // Paramètres Avenant
         newOpty.Avenant__c = false;
         newOpty.DureeAvenant__c = null;
         
         insert newOpty;
      
         String optyParent; 
      
         if((newOpty.NomDuProjetAssocieParent__c  != NULL)||(newOpty.NomDuWaiverPrecedent__c != null)){  
                if(newOpty.NomDuWaiverPrecedent__c == NULL) {
                     optyParent = newOpty.NomDuProjetAssocieParent__c  ; 
                }else {
                     optyParent =   newOpty.NomDuWaiverPrecedent__c  ;   
                }
         }
        ////////////////////////////////////////
        //////////Related List Pool de Garants
         PoolDeGarants__c[] existingPoolDeGarants = [   select id,ReseauAppartenancePartenaire__c, CodeTiers__c,CommissionDeRisque__c,
                                                        Inactif__c, Montant__c, NomDuDossier__c, Partenaire__c,
                                                        Projet__c, ProjetAssocie__c, QuotePart__c,RecordTypeid
                                                        from PoolDeGarants__c 
                                                        where ProjetAssocie__c =: optyParent
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
                                        where NomdelaProjetAssocie__c =: optyParent ];
           for (Garantie__c result : ExistinglG) {   
                        Garantie__c PDGClone = new Garantie__c(); 
                        PDGClone = result.clone(false, true);
                        PDGClone.NomdelaProjetAssocie__c = newOpty.id;
                        lGarantiesToNewOpp.add(PDGClone); 
           } 
           insert lGarantiesToNewOpp; 
            ////////////////////////////////////////
           //////////Related List Detail du_Pool
           list<Detail_du_Pool__c> lDDP = [select id,Chef_de_file__c,Partenaire__c,ChefFileCroix__c,
                                                NomDuPartenaire__c,NumAutoPoolDeFinancement__c,
                                                ChefDeFileF__c, CodeTiers__c,CommissionDeRisque__c,FraisDeDossier__c,
                                                FraisDossierQPNL__c,Inactif__c,Montant__c,
                                                Nom_du_Dossier__c,Projet__c,ProjetAssocie__c,QuotePartNL__c,Quote_part__c,
                                                Statut_NL__c,TypeDePool__c, RecordTypeId
                                                from Detail_du_Pool__c where ProjetAssocie__c =:  optyParent ];
      
            for(Detail_du_Pool__c DDP:lDDP){
                    Detail_du_Pool__c DDPClone = new Detail_du_Pool__c();
                    DDPClone = DDP.clone(false, true);
                    DDPClone.ProjetAssocie__c = newOpty.id;
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
        //////////////////////////////////////////////////
        //
        //////////////////////////////////////////////////                
                 list<OpportunitySplit> lOS = [select id, SplitAmount,
                                               SplitNote,Opportunityid,SplitTypeid,SplitPercentage,
                                               SplitOwnerid 
                                               from OpportunitySplit where Opportunityid =: optyParent ];
                 OpportunitySplit CurrentOS = [select id, SplitAmount,
                                               SplitNote,Opportunityid,SplitTypeid,SplitPercentage,
                                               SplitOwnerid 
                                               from OpportunitySplit where Opportunityid =: newOpty.id ];
                 
                for(OpportunitySplit OS:lOS){ 
                    if(OS.SplitOwnerid != CurrentOS.SplitOwnerid) {
                        OpportunitySplit OSClone = new OpportunitySplit();
                        OSClone = OS.clone(false, true);
                        OSClone.Opportunityid =newOpty.id;
                        lOpportunitySplit.add(OSClone); 
                    }
                }
       insert lOpportunitySplit;
       //////////////////////////////////////////////////
       //////////////////////////////////////////////////
       ///////////////// Clone de la Note Comité et des calculatrices associées
      
      
       List<NoteComite__c> noteToCloneList = [SELECT AssistantProprietaireNC__c,Assistant__c,AvancePreneurNC__c,AvancePreneurROE1NC__c,AvancePreneurROE2NC__c,AvancePreneur__c,AvenantNC__c,AvisDirectionCommerciale__c,AvisDirectionEngagement__c,AvisDuCommercialMatriceSWOT__c,AvisDuCommercial__c,AvisSurLaContrePartie__c,AvisSurLImmobilier__c,AvisSurLOperation__c,BanqueNoteuseNC__c,BanqueNoteuseTeteGroupeNC__c,BanqueNoteuseTiersRisqueNC__c,BanqueNoteuse__c,Bien1__c,Bien2__c,Bien3__c,Bien4__c,BienCBINC__c,CAF__c,CALC1BNC__c,CALC1NC__c,CALC2BNC__c,CALC2NC__c,CALC3BNC__c,CALC3NC__c,CALC4BNC__c,CALC4NC__c,CALC5NC__c,CALC6NC__c,CALC7NC__c,CALC8NC__c,CALC12NC__c,CALC14NC__c,CALC15NC__c,CALC16NC__c,CALC17NC__c,CALC18NC__c,CALC19NC__c,CALC20NC__c,CALC21NC__c,CALC22NC__c,CalculetteROE1__c,
                                    CalculetteROE2__c,Cash__c,CBMExplNC__c,CCAExplNC__c,ChargesCBIFutures__c,ChargesCBI__c,ClientPreneurF__c,ClientPreneurNC__c,CodeTiersProjetNC__c,ComiteDeCreditDuPdC__c,CommentairesEquilibreDeOperation__c,CommentairesSurStructuration__c,Commerciale__c,CompareCP_TRP__c,Compare_CP_TRP_TG__c,ComplementairePage1Notif__c,ContexteGeneralDeLOperation__c,CoordonneesTelephoniquesNotif__c,CorresDocOfficielCivilitNotif__c,CoteBanqueDeFranceTeteDeGroupe__c,CoteBanqueDeFranceTierEnRisqueProfile__c,CoutAcquisitionNC__c,CoutConstructionTravauxNC__c,CoutTerrainCBINC__c,CoutTerrainNC__c,CreatedById,CreatedDate,CreditBailleurPage5TitreNotif__c,CreditBailleurPage_5_1_Notif__c,CreditPreneurPage5Notif__c,CreditPreneurPage5_3_Notif__c,DateAvisDeLaDirectionCommerciale__c,DateAvisDeLaDirectionEngagement__c,
                                    DateAvisDirectionRisques__c,DateAvisDuCommercial__c,DateDecisionComiteNatixisLease__c,DateDecisionComiteNatixis__c,DateDeCreationTeteDeGroupe__c,DateDeCreationTiersRisqueProfile__c,DateDeDecision__c,DateDeTransmissionDirectionEngagement__c,DateDossierCompletNC__c,DateDossierCompletPourAvis__c,DateDossierCompletPourDecision__c,DateEmissionNotificationNotif__c,DateEnvoiNotification__c,DateExpiration__c,DateNotationNC__c,DateNotationTeteGroupeNC__c,DateNotationTiersRisqueNC__c,DateNotation__c,DatePDCSouhaitee__c,DatePDCValidee__c,DateProrogationDemandee__c,DateRetourNotificationAcceptee__c,DateTransmissionAvisDirectionRisques__c,Date__c, DecisionComiteNatixisLease__c, DecisionComiteNatixis__c,DecisionNotification__c,DepartementDuBien__c,DepotDeGarantie__c,DepotGarantieROE1NC__c,DepotGarantieROE2NC__c,
                                    DestinataireNotificationNotif__c,DifferentielDeLoyerCAF__c,DifferentielDeLoyer__c,DomiciliationBancairePage9__c,DSCR__c,DureeFinancementROE1NC__c,DureeFinancementROE2NC__c,DureeReelleROE1NC__c,DureeReelleROE2NC__c,Dur_e_en_trimestre__c,EmailGeneriqueDEC__c,EmpruntObligatoireExplNC__c,EncoursExistantsNC__c,EncoursNetNC__c,EtatDeLaNotation__c,EtatNotationNC__c,EtatNotationTeteGroupeNC__c,EtatNotationTiersRisqueNC__c,Faiblesses__c,FondsPropresExplNC__c,Forces__c,FraisDossierNC__c,FraisEtudesNotif__c,Id,IDDuTiersClientPreneur__c,IDDuTiersTeteGroupe__c,IDDuTiersTiersRisque__c,Impot__c,InformationCadastreNotif__c,InfosComplSurDecision__c,InterlocuteurBanque__c,InvExplEmploi1NC__c,InvExplEmploi2NC__c,InvExplEmploi3NC__c,InvExplEmploi4NC__c,InvExplEmploi5NC__c,InvExplEmploi6NC__c,
                                    InvImmoEmploi1NC__c,InvImmoEmploi2NC__c,InvImmoEmploi3NC__c,InvImmoRess1NC__c,InvImmoRess2NC__c,InvImmoRess3NC__c,IsDeleted,JustificationDuPrrofilageRetenu__c,KYCEffectueNC__c,KYCEffectue__c,LeaseBackNC__c,LibelleSurfaceTauxEffort__c,LibelleValeurLocativeAnnuelleNC__c,LieuDuFinancement__c,LogoEnTeteNC__c,LogoPiedPageNC__c,LoyerImmobilierActuel__c,LoyerRecus__c,Menaces__c,MobileProprietaireNC__c,Mobile__c,ModeCalculROE1NC__c,ModeCalculROE2NC__c,MontageInvestisseurOption2__c,MontageInvestisseurOption_1__c,MontageJuridique_1_Notif__c,MontageJuridique_2_Notif__c,MontageJuridique_3_Notif__c,MontageUtilisateur__c,MontantAVPRNL__c,MontantCBINotif__c,MontantCCANC__c,MontantExplEmploi1NC__c,MontantExplEmploi2NC__c,MontantExplEmploi3NC__c,
                                    MontantExplEmploi4NC__c,MontantExplEmploi5NC__c,MontantExplEmploi6NC__c,MontantFinanceROE1NC__c,MontantFinanceROE2NC__c,MontantFinance__c,MontantImmoEmploi1NC__c,MontantImmoEmploi2NC__c,MontantImmoEmploi3NC__c,MontantImmoRess1NC__c,MontantImmoRess2NC__c,MontantImmoRess3NC__c,MontantInvestissementNotVEFA1__c,MontantInvestissementNotVEFA2__c,MontantInvestissementNotVEFA3__c,MotivationsEtDescriptionDuProje__c,Name,NDuDossierEngagementV4NC__c,NiveauDecisionNC__c,NomDuTiersClientPreneur__c,NomProprietaireProjetAssocieNC__c,NomTiersTeteGroupeNC__c,NomTiersTiersRisqueNC__c,NotationNC__c,NotationTeteGroupeNC__c,NotationTiersRisqueNC__c,Notation__c,N_ActeurV4NC__c,ObjetClientPreneurotif__c,ObjetDeInvestissement__c,ObjetInvestissementNC__c,Opportunites__c,PhaseDeBien1__c,PhaseDeBien2__c,PhaseDeBien3__c,
                                    PhaseDeBien4__c,PlanChargeNC__c,PlusCinqDossiersNC__c,PlusDeCinqDossiers__c,PlusValue__c,PreloyersEngagementNC__c,PreloyersFinancementNC__c,PretCTEExplNC__c,PretMLTExplNC__c,PrixDeVente__c,PrixHFParChambreNC__c,PrixHFParCouvertNC__c,PrixHFParLitNC__c,PrixNetParChambreNC__c,PrixNetParCouvertNC__c,PrixNetParLitNC__c,PrixParChambreNC__c,PrixParCouvertNC__c,PrixParLitNC__c,ProfilageDeLOperationNC__c,ProjetAssocie__c,Projet__c,Prorogation__c,ProspectNC__c,RAFTeteGroupeNC__c,RAFTiersRisqueNC__c,RAF_BOA_Projet_NC__c,RaisonSocialeCreditPreneurNC__c,RaisonSocialeTeteGroupeNC__c,RaisonSocialeTiersRisqueNC__c,RecordTypeId,RelationBancaire__c,RemboursementEmpruntsActuels__c,RemboursementNouveauxEmprunts__c,SegmentationNC__c,SegmentationTeteGroupeNC__c,SegmentationTiersRisqueNC__c,Segmentation__c,SiCessionBail__c,Signataire1__c,
                                    Signataire2__c,SIRENClientPreneurNC__c,SIRENTeteGroupeNC__c,SIRENTiersRisqueNC__c,SocieteGestionNotif__c,SoldeRestant__c,SommeLoyerAnnuelLocataire__c,SommeSdVM2Locataire__c,SommeSurfacem2Locataire__c,StatutApprobation__c,SubventionROE1NC__c,SubventionROE2NC__c,Subvention__c,SurfaceTauxEffort__c,SurfaceVacanteLocataireNC__c,SurfaceVacanteSdVLocataireNC__c,SystemModstamp,TaxationNC__c,Taxation__c,TelephoneProprietaireNC__c,Tel__c,TeteDeGroupeF__c,TeteDeGroupeTxt__c,TeteDeGroupe__c,TiersEnRisqueProfileF__c,TiersEnRisqueProfileTxt__c,TiersEnRisqueProfile__c,Tiers__c,TitreROE1NC__c,TitreROE2NC__c,TotalCoutAcquisitionNC__c,TotalCoutConstructionConsAvt__c,TotalCoutConstructionNC__c,TotalLoyerM2SdV__c,TotalLoyerM2__c,TotalPrixRevientNC__c,TypeDeStatutTeteDeGroupe__c,TypeDeStatutTiersEnRisqueProfil__c,TypeNotification__c,TypePreloyersPage1Notif__c,
                                    TypeStatutTeteGroupeNC__c,TypeStatutTiersRisqueNC__c,ValeurLocativeAnnuelleNC__c,ValeurLocativeChiffreAffairesNC__c,ValeurNetteComptable__c,ValeurResiduelleROE1NC__c,ValeurResiduelleROE2NC__c,ValeurResiduelle__c,X1ExposeDeLoperation__c 
                                    FROM NoteComite__c
                                    WHERE ProjetAssocie__c = :idOpp LIMIT 1];
      
      RecordType RTWaiver = [SELECT Id FROM RecordType WHERE DeveloperName = 'CBINoteComiteWaiver'];
      
      if(noteToCloneList.size() != 0){
          
          NoteComite__c noteToClone = noteToCloneList[0];
          
          NoteComite__c newNote  = new NoteComite__c();  
          newNote = noteToClone.clone(false, true); 
          
          newNote.ProjetAssocie__c = newOpty.Id;
          newNote.RecordTypeId = RTWaiver.Id;
       
          // On récupère les calculatrice pour les cloner
          // Caclulatrice 1
          List<CalculetteROE__c> calcROE1List = [SELECT AdresseActifAFinancer__c,AvancePreneur__c,AvenantOuiNon__c,Avenant__c,BaseNotation__c,BesoinsFPMoyenIRBABPCE__c,BesoinsFPMoyenIRBA__c,BesoinsFPmoyenSTD__c,CalculetteROEValidee__c,ChantierOuiNon__c,Chantier__c,CMSNumeroSemaineTCI__c,CommissionApportFlatNC__c,CommissionApportFlatNegatif__c,CommissionApportFlatPerc__c,CommissionApportFlat__c,CommissionDeRisqueActualisBPCENC__c,CommissionDeRisqueActualisBPCEPerc__c,CommissionDeRisqueActualiseeBPCE__c,CommissionNonUtilisationEnSpread__c,CoutDeLiquiditeNC__c,CoutDeLiquidite__c,CoutsDexploitationActualisesIRBANC__c,CoutsDexploitationActualisesIRBAPerc__c,CoutsDexploitationActualisesIRBA__c,CoutsDexploitationActualisesSTDNC__c,CoutsDexploitationActualisesSTDPerc__c,CoutsDexploitationActualises__c,CreatedById,CreatedDate,CRL__c,DateConstatationTaux__c,DateConstationEuribor3MoisSpecifique__c,DateCreation__c,DepotDeGarantie__c,DureeDuChantierMois__c,DureeEnTrimestre__c,DureePreloyersTVA__c,DureeReelle__c,EncoursMoyenOperationDuree__c,
                                                 EncoursMoyen__c,EncoursTotalDuDossier__c,Euribor3MoisNC__c,Euribor3moisSpecifique__c,Euribor3Mois__c,ExpectedLossNC__c,ExpectedLossPerc__c,ExpectedLoss__c,FraisDeDossierPerc__c,FraisDeDossierSansEncoursMoyenNC__c,FraisDeDossierSansEncoursMoyen__c,FraisDeDossier__c,Id,IDNoteComite__c,IDPropositionCommerciale__c,IndiquerNumSemaineTCI__c,IsDeleted,LGD__c,LocatisationROE__c,LoyersDeGestion__c,MargeApresAvancePreneurNC__c,MargeApresAvancePreneur__c,MargeBruteFinanciereActualiseeNC__c,MargeBruteFinanciereActualiseePerc__c,MargeBruteFinanciereActualisee__c,MargeCommApresLiquiditeITENC__c,MargeCommApresLiquiditeTEANC__c,MargeCommercialeApresLiquiditeITE__c,MargeCommercialeApresLiquiditeTEA__c,MargeNetteIRBA__c,MargeNetteStandard__c,ModeDeCalcul__c,MontantAVPRQPNL__c,MontantBrutDeLaQPNL__c, Montant_Brut_de_la_QP_NL__c,MontantduCBI__c,MontantTVA__c,MontantVRQPNLSimulation__c, Montant_VR_QP_NL_Simulation__c,MontantVRQPNL__c,Name,NbNoteComite__c,NbNotesComitesEnvoyees__c,
                                                 NbPropositionsCommercialesEnvoyees__c,NbPropositionsCommerciales__c,NomNoteComite__c,NomPropositionCommerciale__c,NotationNIE1to16__c,NotationNIO1to10__c,NotationTRR__c,NoteComiteAssociee__c,Notice__c,ObjetDeInvestissement__c,OwnerId,PNBAdditionnelNC__c,PNBAdditionnelperc__c,PNBAdditionnel__c,PNBIRBANC__c,PNBIRBAPerc__c,PNBIRBA__c,PNBStandardNC__c,PNBStandardPerc__c,PNBStandard__c,PreloyersEngagementNC__c,PreloyersEngagementPerc__c,PremierTiragePhaseChantier__c,ProbabiliteDeDefautNC__c,ProbabiliteDeDefaut__c,ProgressiviteDesLoyersNC__c,ProgressiviteDesLoyers__c,ProjetAssocie__c,ProjetId__c,ProjetNom__c,PropositionCommercialeAssociee__c,QuotePartFraisDossier__c,QuotePartNL__c,QuotiteContreGarantieNC__c,QuotiteContreGarantie__c,RachatAnticipe__c,RecordTypeId,RemunerationDesFPNNC__c,RemunerationDesFPN__c,RemunrationDesFPNPerc__c,ResultatCourantAvantImpotIRBA__c,ResultatCourantAvantImpotStandard__c,ROEMAimpotIRBA__c,ROEMApresimpotIRBA__c,ROEMoyenApresImpotIRBABPCENC__c,ROEMoyenApresImpotIRBABPCE__c,
                                                 ROEmoyenApresImpotStandardNC__c,ROEmoyenApresImpotStandard__c,ROEMoyenAvantImpotIRBABPCENC__c,ROEMoyenAvantImpotIRBABPCE__c,ROEMoyenAvantImpotStdNC__c,ROEMoyenAvantImpotStd__c,RTCalculetteROE__c,RWAMoyenBPCE__c,RWAMoyenStandard__c,RWAMoyen__c,SemaineConstatationTaux__c,SpreadCMSNC__c,SpreadCMS__c,SpreadIndex365360NC__c,SpreadIndex365360__c,SpreadRemunerationAvancePreneur__c,SpreadRemunerationPreloyersTVA__c,SpreadRemunerationPreloyers__c,Subvention__c,SystemModstamp,TauxCMSSemaineNC__c,TauxCMSSemaineSpecifique__c,TauxCMSSemaine__c,TauxCMS__c,TauxCommissionRisqueSurEncours__c,TauxCommRisqueSurEncoursNC__c,TauxDeRefinancementOperation__c,TauxFixe__c,TauxRefiCEBPNC__c,TauxRefiCEBP__c,TauxRefinancementNLNC__c,TauxRefinancementNL__c,TauxRemunerationAvancePreneur__c,TauxVariable__c,TauxVenteClientITENC__c,TauxVenteClientITE__c,TauxVenteClientNominalNC__c,TauxVenteClientNominal__c,TauxVenteClientTEANC__c,TauxVenteClientTEA__c,Taxation__c,
                                                 TCISemaineTxRefiCEBPTxRefiSpe__c,TeteDeGroupeID__c,TeteDeGroupeNom__c,TiersEnRisqueProfileID__c,TiersEnRisqueProfileNom__c,Tiers__c,TitreCalculetteROE__c,TypeContrepartie__c,TypeDeTaux__c,TypeTauxRefinancement__c,UsageROE__c,ValeurDuBien__c,ValeurResiduelle__c 
                                                 FROM CalculetteROE__c
                                                 WHERE Id = :noteToClone.CalculetteROE1__c];
          
          // Caclulatrice 2
          List<CalculetteROE__c> calcROE2List = [SELECT AdresseActifAFinancer__c,AvancePreneur__c,AvenantOuiNon__c,Avenant__c,BaseNotation__c,BesoinsFPMoyenIRBABPCE__c,BesoinsFPMoyenIRBA__c,BesoinsFPmoyenSTD__c,CalculetteROEValidee__c,ChantierOuiNon__c,Chantier__c,CMSNumeroSemaineTCI__c,CommissionApportFlatNC__c,CommissionApportFlatNegatif__c,CommissionApportFlatPerc__c,CommissionApportFlat__c,CommissionDeRisqueActualisBPCENC__c,CommissionDeRisqueActualisBPCEPerc__c,CommissionDeRisqueActualiseeBPCE__c,CommissionNonUtilisationEnSpread__c,CoutDeLiquiditeNC__c,CoutDeLiquidite__c,CoutsDexploitationActualisesIRBANC__c,CoutsDexploitationActualisesIRBAPerc__c,CoutsDexploitationActualisesIRBA__c,CoutsDexploitationActualisesSTDNC__c,CoutsDexploitationActualisesSTDPerc__c,CoutsDexploitationActualises__c,CreatedById,CreatedDate,CRL__c,DateConstatationTaux__c,DateConstationEuribor3MoisSpecifique__c,DateCreation__c,DepotDeGarantie__c,DureeDuChantierMois__c,DureeEnTrimestre__c,DureePreloyersTVA__c,DureeReelle__c,EncoursMoyenOperationDuree__c,
                                                 EncoursMoyen__c,EncoursTotalDuDossier__c,Euribor3MoisNC__c,Euribor3moisSpecifique__c,Euribor3Mois__c,ExpectedLossNC__c,ExpectedLossPerc__c,ExpectedLoss__c,FraisDeDossierPerc__c,FraisDeDossierSansEncoursMoyenNC__c,FraisDeDossierSansEncoursMoyen__c,FraisDeDossier__c,Id,IDNoteComite__c,IDPropositionCommerciale__c,IndiquerNumSemaineTCI__c,IsDeleted,LGDNC__c,LGD__c,LocatisationROE__c,LoyersDeGestion__c,MargeApresAvancePreneurNC__c,MargeApresAvancePreneur__c,MargeBruteFinanciereActualiseeNC__c,MargeBruteFinanciereActualiseePerc__c,MargeBruteFinanciereActualisee__c,MargeCommApresLiquiditeITENC__c,MargeCommApresLiquiditeTEANC__c,MargeCommercialeApresLiquiditeITE__c,MargeCommercialeApresLiquiditeTEA__c,MargeNetteIRBA__c,MargeNetteStandard__c,ModeDeCalcul__c,MontantAVPRQPNL__c,MontantBrutDeLaQPNL__c, Montant_Brut_de_la_QP_NL__c,MontantduCBI__c,MontantTVA__c,MontantVRQPNLSimulation__c, Montant_VR_QP_NL_Simulation__c,MontantVRQPNL__c,Name,NbNoteComite__c,NbNotesComitesEnvoyees__c,
                                                 NbPropositionsCommercialesEnvoyees__c,NbPropositionsCommerciales__c,NomNoteComite__c,NomPropositionCommerciale__c,NotationNIE1to16__c,NotationNIO1to10__c,NotationTRR__c,NoteComiteAssociee__c,Notice__c,ObjetDeInvestissement__c,OwnerId,PNBAdditionnelNC__c,PNBAdditionnelperc__c,PNBAdditionnel__c,PNBIRBANC__c,PNBIRBAPerc__c,PNBIRBA__c,PNBStandardNC__c,PNBStandardPerc__c,PNBStandard__c,PreloyersEngagementNC__c,PreloyersEngagementPerc__c,PremierTiragePhaseChantier__c,ProbabiliteDeDefautNC__c,ProbabiliteDeDefaut__c,ProgressiviteDesLoyersNC__c,ProgressiviteDesLoyers__c,ProjetAssocie__c,ProjetId__c,ProjetNom__c,PropositionCommercialeAssociee__c,QuotePartFraisDossier__c,QuotePartNL__c,QuotiteContreGarantieNC__c,QuotiteContreGarantie__c,RachatAnticipe__c,RecordTypeId,RemunerationDesFPNNC__c,RemunerationDesFPN__c,RemunrationDesFPNPerc__c,ResultatCourantAvantImpotIRBA__c,ResultatCourantAvantImpotStandard__c,ROEMAimpotIRBA__c,ROEMApresimpotIRBA__c,ROEMoyenApresImpotIRBABPCENC__c,ROEMoyenApresImpotIRBABPCE__c,
                                                 ROEmoyenApresImpotStandardNC__c,ROEmoyenApresImpotStandard__c,ROEMoyenAvantImpotIRBABPCENC__c,ROEMoyenAvantImpotIRBABPCE__c,ROEMoyenAvantImpotStdNC__c,ROEMoyenAvantImpotStd__c,RTCalculetteROE__c,RWAMoyenBPCE__c,RWAMoyenStandard__c,RWAMoyen__c,SemaineConstatationTaux__c,SpreadCMSNC__c,SpreadCMS__c,SpreadIndex365360NC__c,SpreadIndex365360__c,SpreadRemunerationAvancePreneur__c,SpreadRemunerationPreloyersTVA__c,SpreadRemunerationPreloyers__c,Subvention__c,SystemModstamp,TauxCMSSemaineNC__c,TauxCMSSemaineSpecifique__c,TauxCMSSemaine__c,TauxCMS__c,TauxCommissionRisqueSurEncours__c,TauxCommRisqueSurEncoursNC__c,TauxDeRefinancementOperation__c,TauxFixe__c,TauxRefiCEBPNC__c,TauxRefiCEBP__c,TauxRefinancementNLNC__c,TauxRefinancementNL__c,TauxRemunerationAvancePreneur__c,TauxVariable__c,TauxVenteClientITENC__c,TauxVenteClientITE__c,TauxVenteClientNominalNC__c,TauxVenteClientNominal__c,TauxVenteClientTEANC__c,TauxVenteClientTEA__c,Taxation__c,
                                                 TCISemaineTxRefiCEBPTxRefiSpe__c,TeteDeGroupeID__c,TeteDeGroupeNom__c,TiersEnRisqueProfileID__c,TiersEnRisqueProfileNom__c,Tiers__c,TitreCalculetteROE__c,TypeContrepartie__c,TypeDeTaux__c,TypeTauxRefinancement__c,UsageROE__c,ValeurDuBien__c,ValeurResiduelle__c 
                                                 FROM CalculetteROE__c
                                                 WHERE Id = :noteToClone.CalculetteROE2__c];
          
          if(calcROE1List.size() != 0){
              System.debug('ROE1: ');
              CalculetteROE__c calcROE1ToClone = calcROE1List[0];
              CalculetteROE__c newCalcROE1 = new CalculetteROE__c();
              newCalcROE1 = calcROE1ToClone.clone(false, true); 
              newCalcROE1.ProjetAssocie__c = newOpty.Id;
              insert newCalcROE1;
              
              //Rattachement à la Note Comite
              newNote.CalculetteROE1__c = newCalcROE1.Id;
          }
          
          if(calcROE2List.size() != 0){
              System.debug('ROE2: ');
              CalculetteROE__c calcROE2ToClone = calcROE2List[0];
              CalculetteROE__c newCalcROE2 = new CalculetteROE__c();
              newCalcROE2 = calcROE2ToClone.clone(false, true); 
              newCalcROE2.ProjetAssocie__c = newOpty.Id;
              insert newCalcROE2;
              
              //Rattachement à la Note Comite
              newNote.CalculetteROE2__c = newCalcROE2.Id;              
          }

          insert newNote;
      }
       
      CurrentUser.UserByPassTriggers__c = '';
      update CurrentUser;
      
        // System.debug( 'La new Opty id ' + newOpty.id + 'La new Opty ' + newOpty);
         PageReference pageRef = new PageReference('/' + newOpty.id);
         return PageRef.setRedirect(True);
         
         }
        catch(Exception ex){
            Database.rollback(sp); 
            return null;
        }
      
    }
    
    /**
     * Contrôle les règles métiers à respecter pour créer le Waiver
     */
    public PageReference canCreateWaiver(){
        
        PageReference pageRef;
        messageErreur = '';
        
        if(isWaiversTermines && isAvtInitialDecide && nbWaiversDecide < 2){          
            pageRef = addCloneRelatedListToNewWaiver();
        }
        else if(!isWaiversTermines && !isAvtInitialDecide){
            messageErreur = 'Les Waivers liés à l\'Avenant initial ne sont pas tous en Phase \'Terminé\' et l\'Avenant ne doit pas être en Phase \'Pré-Étude\', \'Étude\' ou \'Octroi\'.';
        }
        else if(!isWaiversTermines){
            messageErreur = 'Les Waivers liés à l\'Avenant initial ne sont pas tous en Phase \'Terminé\' ou \'Décidé\'.';          
        }
        else if(!isAvtInitialDecide){
            messageErreur = 'La création d\'un Waiver est impossible : la phase ne doit pas être \'Pré-Étude\', \'Étude\' ou \'Octroi\'.';            
        }
        /*
        else if (nbWaiversDecide > 1){
            messageErreur = 'La création d\'un Waiver est impossible : vous avez plus d\'un Waiver en Phase \'Décidé\'.'; 
        }*/
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, messageErreur));
        return pageRef;

    }
    
    public PageReference Fermer() {
        
      Opportunity currentOpp = [ SELECT ID FROM Opportunity WHERE Id = :idOpp];
     
      PageReference pageRef = new PageReference('/' + currentOpp.Id);  
        
      return pageRef.setRedirect(true);
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
            return canCreateWaiver();
        }
}