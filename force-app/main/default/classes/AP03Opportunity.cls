public class AP03Opportunity {
    
    /**On met à jours le champs nombre de projet associé stocké dans le projet */
    public static void UpdateProjetNbPa(Opportunity[] Opportunities){
        
        // Projets à updater
        List<Projet__c> projlistToUpdate = new List<Projet__c>();
        List<Opportunity> optyListToUpdate = new List<Opportunity>();
        
        // Ids des objets à traiter
        Set<Id> projetsIds = new Set<Id>();
        Set<Id> oppParentIds = new Set<Id>();
        
        for (Opportunity opty : Opportunities){
            projetsIds.add(opty.NomDuProjet__c);
            oppParentIds.add(opty.NomDuProjetAssocieParent__c);
        }
        
        // Projets liés aux opps inserées
        Map<Id, Projet__c> projetsMap = new Map<Id, Projet__c>([SELECT ID, NbProjetsAssocies__c, NbAvenants__c  
                                                                FROM Projet__c 
                                                                WHERE ID IN :projetsIds]);
        
        //Eventuelles opps parents liés aux opps inserées
        Map<Id, Opportunity> oppsParentMap = new Map<Id, Opportunity>([SELECT ID,Name, NbWaiversDuProjetAssocie__c, NbAvenantsDuProjetAssocie__c, StageName,Jalon__c,NomDuProjet__c 
                                                                 FROM Opportunity  
                                                                 WHERE id IN :oppParentIds]);
        
              
        // On récupère les ids des RT de l'objet Opportunity
        Map<String,Id> rtMap = DAL.getRecordType('Opportunity');
        
        for (Opportunity opty : Opportunities){
            System.debug(opty.RecordTypeId);
            //Mise à jour du nombre de projets associés sur un projet
            list<Projet__c> projlist = new list<Projet__c>();
            if(opty.RecordTypeId == rtMap.get('CBIProjetAssocie')) {
                System.debug('CBIProjetAssocie');
                Projet__c  proj = projetsMap.get(opty.NomDuProjet__c);
                if(proj.NbProjetsAssocies__c != null){
                    proj.NbProjetsAssocies__c=  proj.NbProjetsAssocies__c + 1  ; 
                }
                else{
                    proj.NbProjetsAssocies__c= 1;
                }
                projlistToUpdate.add(proj);
            } 
            else if(opty.RecordTypeId == rtMap.get('CBIAvenant')) {
                System.debug('CBIAvenant');
                Opportunity oppParent = oppsParentMap.get(opty.NomDuProjetAssocieParent__c);
                // Si il y a un Projet Associé parent, on met à jour le compteur d'Avenant sur le Projet Associé parent
                if(oppParent != null){
                    if(oppParent.NbAvenantsDuProjetAssocie__c != null){
                        System.debug('CBIAvenant 1');
                        oppParent.NbAvenantsDuProjetAssocie__c = oppParent.NbAvenantsDuProjetAssocie__c + 1;
                    }
                    else{
                        System.debug('CBIAvenant 2');
                        oppParent.NbAvenantsDuProjetAssocie__c = 1;
                    }
                    optyListToUpdate.add(oppParent);
                }
                // Si il n'y a pas de Projet Associé parent, on met à jour le compteur d'Avenant sur le Projet
                else{
                    Projet__c  proj = projetsMap.get(opty.NomDuProjet__c);
                    if(proj.NbAvenants__c != null){
                        proj.NbAvenants__c++; 
                    }
                    else{
                        proj.NbAvenants__c= 1;
                    }
                    projlistToUpdate.add(proj);
                }
            }
            else if (opty.RecordTypeId == rtMap.get('CBIWaiver')) {
                System.debug('CBIWaiver');
                System.debug(opty.RecordTypeId);
                Opportunity oppParent = oppsParentMap.get(opty.NomDuProjetAssocieParent__c);
                if(oppParent != null && oppParent.NbWaiversDuProjetAssocie__c != null){
                    System.debug('CBIWaiver 1');
                    oppParent.NbWaiversDuProjetAssocie__c = oppParent.NbWaiversDuProjetAssocie__c + 1;
                }
                else{
                    System.debug('CBIWaiver 1');
                    oppParent.NbWaiversDuProjetAssocie__c = 1;
                }
                optyListToUpdate.add(oppParent); 
            }
        }
        
        update projlistToUpdate;
        update optyListToUpdate; 
    }

    /**
     *  Insère le premier Detail de Pool (BPCE Lease) à la création de l'opportunité
     * 
     */
    public static void insertPremierPoolFinancement(Opportunity[] oppsList){              
        // On récupère le tiers 'BPCE Lease'
        List<Account> lTiers = new List<Account>();
        
        if(Test.isRunningTest()){
            lTiers.add(new Account(Name='BPCE LEASE'));
            insert lTiers;
        } else {
            lTiers = [SELECT Id, Name FROM Account WHERE Name = :Label.BPCELease LIMIT 1];
        }
        
        // Dossier par défaut
        String lCodeDossier = Label.Numero_Dossier_Pool_Financement_Natixis_Lease;
        List<Contract> lContrat = [SELECT Id, ContractNumber FROM Contract WHERE Nom_du_dossier__c ='Dossier Pool Financement' AND Account.Name='Tiers Dossier Pool Financement' LIMIT 1];
        List<Detail_du_Pool__c> lDetailPoolList = new List<Detail_du_Pool__c>();
        //Record Type Detail du Pool CBI
        RecordType typeCBI = [SELECT Id FROM RecordType WHERE DeveloperName = 'CBIDetailDuPoolFinancement' LIMIT 1];
        system.debug('@@@@@@@@@@@@ lTiers: ' + lTiers);
        system.debug('@@@@@@@@@@@@ lContrat: ' + lContrat);
        if(lTiers.size() != 0 && lContrat.size() != 0){
            for (Opportunity opty : oppsList) {
                
                //On ne crée le pool que si il s'agit d'un nouveau PASS
                if(opty.NomDuProjetAssocieParent__c == NULL) {
                    // Création du detail de pool
                    Detail_du_Pool__c lDetailDePool = new Detail_du_Pool__c(Partenaire__c = lTiers[0].Id, ProjetAssocie__c = opty.Id, Nom_du_Dossier__c = lContrat[0].Id, Chef_de_file__c = true, Quote_part__c = 100, TypeDePool__c = '', RecordTypeId = typeCBI.Id);                  	  
                    lDetailPoolList.add(lDetailDePool);
                }
            } 
            
        }
        //insertion
        insert lDetailPoolList;     
    } 
        
    public static void setPhasejalonToProjetAssocieFromWaiver(Opportunity[] Opportunities){
       
        // Projets à updater
        List<Opportunity> optyListToUpdate = new List<Opportunity>();
        
        // Ids des objets à traiter
        Set<Id> oppParentIds = new Set<Id>();
        Set<Id> oppWaiverIds = new Set<Id>();
        
        for (Opportunity opty : Opportunities){
            
            oppParentIds.add(opty.NomDuProjetAssocieParent__c);
            oppWaiverIds.add(opty.NomDuWaiverPrecedent__c);
            
        }
        
        Map<Id, Opportunity> oppsParentOrWaiverMap = new Map<Id, Opportunity>([SELECT Id, Name, StageName, Jalon__c, NomDuProjet__c 
                                                                                FROM Opportunity  
                                                                                WHERE (Id IN :oppParentIds 
                                                                                    OR Id IN :oppWaiverIds)
                                                                                    AND StageName != 'Terminé']);

        system.debug('@@HELLO');
         for(Opportunity opty : Opportunities) {
            if(opty.NomDuWaiverPrecedent__c == NULL) {
                System.debug('test 0');
                Opportunity oppParent = oppsParentOrWaiverMap.get(opty.NomDuProjetAssocieParent__c);
                System.debug('test 1');                                  
                oppParent.StageName = 'Waiver' ;
                oppParent.Jalon__c = 'Waiver' ;
                oppParent.WaiverEnCours__c = false ;
                optyListToUpdate.add(oppParent);
            }
             else{
                Opportunity oppsWaiver = oppsParentOrWaiverMap.get(opty.NomDuWaiverPrecedent__c);
                System.debug('test 2');
                oppsWaiver.StageName = 'Waiver' ;
                oppsWaiver.Jalon__c = 'Waiver' ;
                oppsWaiver.WaiverEnCours__c = false ;
                optyListToUpdate.add(oppsWaiver); 
             }
        } 
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
        update optyListToUpdate;
    }

    /**
     *  FO - DEN
     *  Passage des demandes(=CBMOctroiCreditDEN) au status=Refusée
     *  Rapatrier MotifdecisionDEN__c
    */
    public static List<Case> handleCaseCBMOctroiCreditDEN(Opportunity oldOpp, Opportunity newOpp, List<Case> casesList) {
         List<Case> result = new List<Case>();

         Boolean canUpdateMotifDecisionDEN = false;
         Boolean canAddCase = false;

         if (oldOpp.MotifdecisionDEN__c != newOpp.MotifdecisionDEN__c) {
             canUpdateMotifDecisionDEN = true;
         }

         for (Case c : casesList) {
             canAddCase = false;

             if (canUpdateMotifDecisionDEN) {
                 c.MotifDecisionDEN__c = newOpp.MotifdecisionDEN__c;
                 canAddCase = true;
             } if (newOpp.DateDecisionNatixisLease36xDate__c != null && c.Status != 'Refusée') {
                 c.Status = 'Refusée';
                 canAddCase = true;
             }

             if (canAddCase) {
                 result.add(c);
             }
         }

         return result;
    }

    /**
     *  Annuler les demandes d'octroi DEN si PAS 'sans-suite'
    */
     public static List<Case> cancelCasesIfPASEqualSansSuite(Opportunity oldOpp, Opportunity newOpp, List<Case> casesList) {
         List<Case> result = new List<Case>();
        
         if (oldOpp.StageName != newOpp.StageName && newOpp.StageName == 'S_SUIT') {
             for (Case c : casesList) {
                 c.Status = 'Annulée';

                 result.add(c);
             }
         }

         return result;
     }

    /**
     *  Annuler les demandes d'octroi DEN si PAS 'sans-suite'
    */
    public static List<Case> cancelCasesIfPASEqualSansSuite(Opportunity newOpp, List<Case> casesList) {
        List<Case> result = new List<Case>();

        if (newOpp.StageName == 'S_SUIT') {
            for (Case c : casesList) {
                c.Status = 'Annulée';

                result.add(c);
            }
        }

        return result;
    }
    
    public static void createOpportunityComment(List<Opportunity> oppsList) {
        List<Commentaires__c> commentsList = new List<Commentaires__c>();
        
        for (Opportunity opp : oppsList) {
            if (String.isNotBlank(opp.Comm_eventuels__c)) {
                Commentaires__c newCommentaire = new Commentaires__c(Name=UserInfo.getName(), ProjetAssocie__c=opp.Id, Commentaire__c=opp.Comm_eventuels__c); 
                commentsList.add(newCommentaire);

                opp.Comm_eventuels__c = null;
            }
        }
        if (commentsList.size() > 0) {
            update oppsList;
            insert commentsList;
        }
    }

    /** 
     * @author Aurélien Clerc
     * @date 18/03/2020
     * @param : Set<Id> contractsId
     * @Description : Update contract if opp is validate
     * @return
     */
    public static void updateContracts(Set<Id> contractsId){
        List<Contract> contractsToUpdate = new List<Contract>();

        for(Contract con : [SELECT Id, Statut_renouvellement__c FROM Contract WHERE Id IN :contractsId AND Statut_renouvellement__c != 'Renouvelé']){
            con.Statut_renouvellement__c = 'Renouvelé';
            contractsToUpdate.add(con);
        }

        if(!contractsToUpdate.isEmpty()){
            update contractsToUpdate;
        }
    }

    /** 
     * @author Aurélien Clerc
     * @date 30/09/2020
     * @param : Map<Id, String> etatDocumentSEByOppId
     * @Description : Upsert DocumentSE__c
     * @return
     */

    /*public static void upsertDocumentSE(Map<Id, String> etatDocumentSEByOppId){
        System.debug('Is Ok');
        List<DocumentSE__c> documentsSEToUpsert = new List<DocumentSE__c>();
        Map<Id, List<DocumentSE__c>> documentsSEByOppId = new Map<Id, List<DocumentSE__c>>();
        Map<Decimal, SignatureElectroniqueCorrespondances__c> sEcByNumRef = new Map<Decimal, SignatureElectroniqueCorrespondances__c>();
        List<SignatureElectroniqueCorrespondances__c> correspondancesSE = [SELECT Id,
                                                                                Name,
                                                                                EtatDocument__c,
                                                                                NumeroReference__c,
                                                                                TypeDocument__c,
                                                                                MaJdateDemande__c,
                                                                                MaJdateSignature__c
                                                                            FROM SignatureElectroniqueCorrespondances__c];
        
        System.debug(correspondancesSE);
        for(SignatureElectroniqueCorrespondances__c sEc : correspondancesSE){
            sEcByNumRef.put(sEc.NumeroReference__c, sEc);
        }
        System.debug(sEcByNumRef);
        for(DocumentSE__c dSE : [SELECT Id, 
                                        DateDemande__c, 
                                        DateSignature__c, 
                                        Opportunity__c, 
                                        Signataire__c, 
                                        EtatDocument__c, 
                                        RecordType.DeveloperName
                                FROM DocumentSE__c
                                WHERE Opportunity__c IN :etatDocumentSEByOppId.keySet()]){
            if(documentsSEByOppId.get(dSE.Opportunity__c) != null){
                System.debug('Is Ok 2');
                documentsSEByOppId.get(dSE.Opportunity__c).add(dSE);
            }
            else{
                documentsSEByOppId.put(dSE.Opportunity__c, new List<DocumentSE__c>());
                System.debug('Is Ok 3');
                documentsSEByOppId.get(dSE.Opportunity__c).add(dSE);
            }
        }

        System.debug(documentsSEByOppId);
       
            for(Id oppId : etatDocumentSEByOppId.keySet()){
                System.debug('Is Ok 4');
                Decimal oppRef = Decimal.valueOf(etatDocumentSEByOppId.get(oppId).left(4));
                Boolean needToBeCreated = true;
                if(sEcByNumRef.keySet().contains(oppRef)){
                    System.debug('Is Ok 5');
                    if(!documentsSEByOppId.isEmpty()){
                        System.debug('Doc SE existant');
                        for(DocumentSE__c dSE : documentsSEByOppId.get(oppId)){
                            if(dSE.RecordType.DeveloperName == sEcByNumRef.get(oppRef).TypeDocument__c){
                                System.debug('Is Ok 6');
                                documentsSEToUpsert.add(new DocumentSE__c(Id                = dSE.Id,
                                                                        EtatDocument__c     = sEcByNumRef.get(oppRef).EtatDocument__c,
                                                                        DateDemande__c      = sEcByNumRef.get(oppRef).MaJdateDemande__c ? System.today() : dSE.DateDemande__c,
                                                                        DateSignature__c    = sEcByNumRef.get(oppRef).MaJdateSignature__c ? System.today() : dSE.DateSignature__c));
                                
                                needToBeCreated = false;
        
                                break;
                            }
                        }
                    }
                    if(needToBeCreated){
                        System.debug('Is Ok 7');
                        documentsSEToUpsert.add(new DocumentSE__c(EtatDocument__c   = sEcByNumRef.get(oppRef).EtatDocument__c,
                                                                DateDemande__c      = sEcByNumRef.get(oppRef).MaJdateDemande__c ? System.today() : null,
                                                                DateSignature__c    = sEcByNumRef.get(oppRef).MaJdateSignature__c ? System.today() : null,
                                                                Opportunity__c      = oppId,
                                                                RecordTypeId        = UTL_Utils.getRecordTypeID(String.valueOf(DocumentSE__c.getSObjectType()), sEcByNumRef.get(oppRef).TypeDocument__c)));
                    }
                }
            }
        
        

        if(!documentsSEToUpsert.isEmpty()){
            upsert documentsSEToUpsert;
        }
    }*/
}