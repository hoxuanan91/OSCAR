public class AP11NoteComite {

    /**
     * Rapatrie sur la Note Comité tous les biens liés au Projet
     */ 
    public static void recuperListeDeBiens(NoteComite__c[] notes){
        
        // Ids des Notes Comités
        Set<Id> notesIds = new Set<Id>(); 
        // Ids des projets liés aux Notes Comites
        Set<Id> projetsIds = new Set<Id>();
        // Ids des biens à traiter
        Set<Id> biensIds = new Set<Id>();
        
        for(NoteComite__c lNote : notes){
            notesIds.add(lNote.Id);
            projetsIds.add(lNote.Projet__c);
        }
        
        
        List<NoteComiteBien__c> ncBienListe = new List<NoteComiteBien__c>();
        List<NoteComiteBien__c> lListeNcBiens = [SELECT Id, NoteComite__c, BienCBI__c FROM NoteComiteBien__c WHERE NoteComite__c IN :notesIds];
        List<ListeDeBien__c> lListeBiens = [SELECT Id, Biens__c, Biens__r.Name, Projet__c FROM ListeDeBien__c WHERE Projet__c IN :projetsIds];
        
        for(ListeDeBien__c listeBien : lListeBiens){
            biensIds.add(listeBien.Biens__c);
        }
        
        // Liste de toute les dernières phases de bien
        List<PhaseDeBien__c> lListeDerPdb = [SELECT Id, DernierePhaseDeBien__c, NomDuBien__c, Name
                                                    FROM PhaseDeBien__c WHERE DernierePhaseDeBien__c = true
                                            									AND NomDuBien__c IN :biensIds];
        
        
        for(NoteComite__c lNote : notes){
           
                for(ListeDeBien__c lListeBien : lListeBiens){
                    if(lListeBien.Projet__c == lNote.Projet__c ) {
                        if(!verifierNoteComiteBienExiste(lNote.Id,lListeBien.Biens__c,lListeNcBiens,lListeDerPdb)){
                            NoteComiteBien__c lNCBien = new NoteComiteBien__c(NoteComite__c = lNote.Id, BienCBI__c = lListeBien.Biens__c);
                            
                            //On parcoure les phases de bien pour trouver celle associée au Bien
                            for(PhaseDeBien__c lPhase : lListeDerPdb){
                                if(lPhase.NomDuBien__c == lListeBien.Biens__c){
                                    lNCBien.DernierePhaseDeBien__c = lPhase.Id;
                                }
                            }
                            ncBienListe.add(lNCBien);
                            
                            
                        }
                    }
                } 
        }
        
        upsert ncBienListe;
        
    }
    
    /**
     * Récupère un Bien pour le stocker sur la Note Comité en tant que Bien par défaut
     */ 
    public static void recupererBienNoteComite(NoteComite__c[] notes){
        
        List<NoteComiteBien__c> ncBienListe = new List<NoteComiteBien__c>();
        
        // Ids des projets liés aux notes
        Set<Id> projetsIds = new Set<Id>();
        
        for(NoteComite__c lNote : notes){
            projetsIds.add(lNote.Projet__c);
        }
        
        List<ListeDeBien__c> lListeBiens = [SELECT Id, Biens__c, Projet__c, Biens__r.CreatedDate FROM ListeDeBien__c WHERE Projet__c IN :projetsIds ORDER BY Biens__r.CreatedDate ASC];
        
        for(NoteComite__c lNote : notes){
            
            Boolean isBienRecupere = false; //false tant que l'on a pas recuperé le bien par défaut pour la Note en cours
            for(ListeDeBien__c listeBien : lListeBiens){

                if(listeBien.Projet__c == lNote.Projet__c && !isBienRecupere){
                    lNote.BienCBINC__c = listeBien.Biens__c;
                    isBienRecupere = true; 
                }
                
            }
        }
    }
    
    /**
     * Retourne vrai si le lien Note - Bien CBI existe déjà
     */ 
    public static boolean verifierNoteComiteBienExiste(Id aNoteId, Id aBienId, List<NoteComiteBien__c> aNcBien, List<PhaseDeBien__c> aListeDerPdb){
        
        boolean result = false;
        List<NoteComiteBien__c> listToUpdate = new List<NoteComiteBien__c>();
        
        for(NoteComiteBien__c lNoteComite : aNcBien){
            
            if((lNoteComite.BienCBI__c == aBienId) && (lNoteComite.NoteComite__c == aNoteId)){
                result = true;
                //On parcoure les phases de bien pour trouver celle associée au Bien
                for(PhaseDeBien__c lPhase : aListeDerPdb){
                  if(lPhase.NomDuBien__c == aBienId){
                       lNoteComite.DernierePhaseDeBien__c = lPhase.Id;
                       listToUpdate.add(lNoteComite);
                  }
                }
                break;
            }
        }
        update listToUpdate;
        
        return result;
    }
    
    public static void ajoutNoteComiteSurCalculatrice(NoteComite__c[] notesOld, NoteComite__c[] notes){
        
        // Liste à mettre à jour
        List<CalculetteROE__c> calcsToUpdate = new List<CalculetteROE__c>();
        
        // Ids des calculatrices à mettre à jour
        Set<Id> calcIds = new Set<Id>();
        Set<Id> oldCalcIds;
        
        for(NoteComite__c lNote : notes){
            if(lNote.CalculetteROE1__c != null){
                calcIds.add(lNote.CalculetteROE1__c);
            }
            if(lNote.CalculetteROE2__c != null){
                calcIds.add(lNote.CalculetteROE2__c);
            }
        }
        
        // Map des objets à traiter
        Map<Id,CalculetteROE__c> calcMap = new Map<Id,CalculetteROE__c>([select ID, IDNoteComite__c, NomNoteComite__c , NbNoteComite__c  from CalculetteROE__c where ID IN :calcIds]);
		Map<Id, CalculetteROE__c> oldCalcMap;
        Map<Id, NoteComite__c> oldNoteMap;
        
        /// Dans le cas d'une mise à jour seulement, on va vérifier si une des calculettes a été modifiées/
        //Si oui, on va supprimer les données relatives à la Note comité sur l'ancienne calculette
        if(notesOld != null){
            
            oldCalcIds = new Set<Id>();
            oldNoteMap = new Map<Id, NoteComite__c>();
            
            for(NoteComite__c lNote : notesOld){
                oldNoteMap.put(lNote.Id, lNote);
                
            	if(lNote.CalculetteROE1__c != null){
                	oldCalcIds.add(lNote.CalculetteROE1__c);
            	}
            	if(lNote.CalculetteROE2__c != null){
                	oldCalcIds.add(lNote.CalculetteROE2__c);
            	}
        
        	}
            
            oldCalcMap = new Map<Id,CalculetteROE__c>([select ID, IDNoteComite__c, NomNoteComite__c , NbNoteComite__c  from CalculetteROE__c where ID IN :oldCalcIds]);
        }
        
        
        // On commence la boucle sur toutes les NC triggered
        for(NoteComite__c lNote : notes){
            
            CalculetteROE__c calcROE = null;
            NoteComite__c lOldNote = null;
            
            // On récupère l'ancienne NC dans le cadre d'une mise à jour
            if(oldCalcMap != null){
                lOldNote = oldNoteMap.get(lNote.Id);
            }
            
            // Si la Calculette 1 est renseignée, on met à jour ses données
            if(calcMap.containsKey(lNote.CalculetteROE1__c) && (lOldNote == null || isCalculetteChanged(lOldNote, lNote, 1))){
                calcROE = calcMap.get(lNote.CalculetteROE1__c);
				calcROE.IDNoteComite__c = lNote.id;
                calcROE.NomNoteComite__c = lNote.Name;
                calcROE.NbNoteComite__c = 1;    
                
                calcsToUpdate.add(calcROE);
     		}
            
            // Si la Calculette 2 est renseignée, on met à jour ses données
            if(calcMap.containsKey(lNote.CalculetteROE2__c) && (lOldNote == null || isCalculetteChanged(lOldNote, lNote, 2))){
                calcROE = calcMap.get(lNote.CalculetteROE2__c);
				calcROE.IDNoteComite__c = lNote.id;
                calcROE.NomNoteComite__c = lNote.Name;
                calcROE.NbNoteComite__c = 1;    
                
                calcsToUpdate.add(calcROE);
                
            }

            CalculetteROE__c oldCalcROE;
            if(lOldNote != null && isCalculetteChanged(lOldNote, lNote, 1) && oldCalcMap.containsKey(lOldNote.CalculetteROE1__c)){
                 oldCalcROE = oldCalcMap.get(lOldNote.CalculetteROE1__c);
                 oldCalcROE.IDNoteComite__c = null;
                 oldCalcROE.NomNoteComite__c = null;
                 oldCalcROE.NbNoteComite__c = 0; 
                        
                 calcsToUpdate.add(oldCalcROE);
            }
            if(lOldNote != null && isCalculetteChanged(lOldNote, lNote, 2) && oldCalcMap.containsKey(lOldNote.CalculetteROE2__c)){
                 oldCalcROE = oldCalcMap.get(lOldNote.CalculetteROE2__c);
                 oldCalcROE.IDNoteComite__c = null;
                 oldCalcROE.NomNoteComite__c = null;
                 oldCalcROE.NbNoteComite__c = 0; 
                        
                 calcsToUpdate.add(oldCalcROE);
             }
                
            
        }

        update calcsToUpdate;
    }
    
    /**
     * Vérifie si la calculette n° aNumeroCalculette a été changée sur la Note Comité
     * 
     */ 
    private static Boolean isCalculetteChanged(NoteComite__c aNoteOld, NoteComite__c aNoteNew, Integer aNumeroCalculette){
        
        Boolean lResult = false;
        
        if(aNoteOld != null && aNoteNew != null){
            
            if(aNumeroCalculette == 1 && (aNoteOld.CalculetteROE1__c != aNoteNew.CalculetteROE1__c)) {
                
                lResult = true; 
                
            }
            else if(aNumeroCalculette == 2 && (aNoteOld.CalculetteROE2__c != aNoteNew.CalculetteROE2__c)){
                
                lResult = true; 
                
            }
            
        }
        
        return lResult;

        
    }
    
    public static void isPlusDeCinqDossiersSharedWithNoteComite(NoteComite__c[] lNotesComm){
        
        Set<Id> accountIds = new Set<Id>();
        
        integer NbNoteComiteTierEqualtoDossierAccount; 
        integer NbNoteComiteTiersEnRisqueProfileEqualtoDossierAccount; 
        integer NbNoteComiteTeteDeGroupeEqualtoDossierAccount; 
        
        for(NoteComite__c NoteComite : lNotesComm){
            
            if(NoteComite.IDDuTiersClientPreneur__c != null){
                accountIds.add(NoteComite.IDDuTiersClientPreneur__c);
            }
            if(NoteComite.IDDuTiersTiersRisque__c != null){
                accountIds.add(NoteComite.IDDuTiersTiersRisque__c);
            }
            if(NoteComite.IDDuTiersTeteGroupe__c != null){
                accountIds.add(NoteComite.IDDuTiersTeteGroupe__c);
            }                  
        }
        
        // On récupère les contrats liés aux notes comités triggered
        List<Contract> lDossiers = [SELECT Id, AccountId FROM Contract WHERE AccountId IN :accountIds];
        
        for(NoteComite__c NoteComite : lNotesComm){  
            
            NbNoteComiteTierEqualtoDossierAccount = 0;
        	NbNoteComiteTiersEnRisqueProfileEqualtoDossierAccount = 0; 
        	NbNoteComiteTeteDeGroupeEqualtoDossierAccount = 0;
            
            for(Contract Dossier:LDossiers) {
                if(Dossier.AccountId == NoteComite.IDDuTiersClientPreneur__c) {
                    NbNoteComiteTierEqualtoDossierAccount++;
                }else if(Dossier.AccountId == NoteComite.IDDuTiersTiersRisque__c) {
                    NbNoteComiteTiersEnRisqueProfileEqualtoDossierAccount++;
                }else if(Dossier.AccountId == NoteComite.IDDuTiersTeteGroupe__c) {
                    NbNoteComiteTeteDeGroupeEqualtoDossierAccount++;
                }
            }

            if(NbNoteComiteTierEqualtoDossierAccount > 5 || NbNoteComiteTiersEnRisqueProfileEqualtoDossierAccount > 5 || NbNoteComiteTeteDeGroupeEqualtoDossierAccount > 5) {
                NoteComite.PlusDeCinqDossiers__c = true;
            }
            else{
                NoteComite.PlusDeCinqDossiers__c = false;  
            }
        }
    
    }
    
    /**
     * Méthodes permettant de redescendre diverses valeurs d'autres objets sur la Note Comité
     */ 
    public static void rapatrierDonnees(NoteComite__c[] lNotes){
        
        // Ensembles d'Ids
        Set<Id> biensIds = new Set<Id>(); // Ids des Bien CBI par défaut liés aux NC
        Set<Id> projetsIds = new Set<Id>(); // Ids des Projets liés aux NC
        Set<Id> oppIds = new Set<Id>(); // Ids des PASS lés aux NC
        
        for(NoteComite__c lNoteComite : lNotes){           
            biensIds.add(lNoteComite.BienCBINC__c);
            projetsIds.add(lNoteComite.Projet__c);
            oppIds.add(lNoteComite.ProjetAssocie__c);           
        }
        
        // Listes et maps des objets à stocker sur la NC
        List<Locataire__c> locatairesList = [SELECT Id, BienCBI__c, TiersRisqueProfile__c, DureeBail__c, PeriodeFerme__c FROM Locataire__c WHERE TiersRisqueProfile__c = true AND BienCBI__c IN :biensIds];
        Map<Id,Projet__c> projetsMap = new Map<Id,Projet__c>([SELECT Id, LieuDuFinancement__c FROM Projet__c WHERE Id IN :projetsIds]);
        Map<Id,Opportunity> oppsMap = new Map<Id,Opportunity>([SELECT Id, NomDuProjetAssocieParent__c, NomDuProjetAssocieParent__r.Id, RecordType.DeveloperName FROM Opportunity WHERE Id IN :oppIds]);
        
        
        for(NoteComite__c lNoteComite : lNotes){           
            
            // Données du Projet
            if(projetsMap.containsKey(lNoteComite.Projet__c)){
                Projet__c lProj = projetsMap.get(lNoteComite.Projet__c);
                lNoteComite.LieuDuFinancement__c = lProj.LieuDuFinancement__c;
            }
            
            //Données du PASS
            if(oppsMap.containsKey(lNoteComite.ProjetAssocie__c)){
                Opportunity lOpp = oppsMap.get(lNoteComite.ProjetAssocie__c);
                lNoteComite.ProjetAssocieParent__c = lOpp.NomDuProjetAssocieParent__c;
                if(lOpp.NomDuProjetAssocieParent__c != null){
                    lNoteComite.ProjetAssocieParentId__c = lOpp.NomDuProjetAssocieParent__r.Id;
                }               
                if(lOpp.RecordType.DeveloperName == 'CBIWaiver'){
                    lNoteComite.ProjetAssocieWaiver__c = true;
                }
                else{
                    lNoteComite.ProjetAssocieWaiver__c = false;
                }
            }
            
            // Données des locataires
            for(Locataire__c loc : locatairesList){
                if(loc.BienCBI__c == lNoteComite.BienCBINC__c){
                    lNoteComite.DureeBailLoc__c = loc.DureeBail__c;
                    lNoteComite.PeriodeFermeLoc__c = loc.PeriodeFerme__c;
                }
            }
            
        }
    }
    
    /**
     * Met à jour les valeurs des objets reliés à la Note Comité
     */
    public static void mettreAJourDonnees(NoteComite__c[] lNotes){
        
        // On récupères les ids de nos Notes, calculettes et projets associés
        Set<Id> noteIds = new Set<Id>();
        Set<Id> calc1Ids = new Set<Id>();
        Set<Id> calc2Ids = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();

        // Objets à mettre à jour
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        
        for(NoteComite__c lNoteComite : lNotes){
            noteIds.add(lNoteComite.Id);
            calc1Ids.add(lNoteComite.CalculetteROE1__c);
            calc2Ids.add(lNoteComite.CalculetteROE2__c);
            oppIds.add(lNoteComite.ProjetAssocie__c);
            
        }   
       
        // Calculette 1
        Map<Id,CalculetteROE__c> calc1Map = new Map<Id,CalculetteROE__c>([SELECT Id, ROEmoyenApresImpotStandard__c, ROEMApresimpotIRBA__c, MargeCommercialeApresLiquiditeITE__c FROM CalculetteROE__c WHERE Id IN :calc1Ids]);
        
        // Calculette 2
        Map<Id,CalculetteROE__c> calc2Map = new Map<Id,CalculetteROE__c>([SELECT Id, ROEmoyenApresImpotStandard__c, ROEMApresimpotIRBA__c, MargeCommercialeApresLiquiditeITE__c FROM CalculetteROE__c WHERE Id IN :calc2Ids]);
        
        // Projet Associe
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, ROEStandardRSC__c, ROEIRBARSC__c, MargeCommercialeApresLiquiditeITERSC__c FROM Opportunity WHERE Id IN :oppIds]);

        for(NoteComite__c lNoteComite : lNotes){
            
            CalculetteROE__c calcROE1;
            CalculetteROE__c calcROE2;
            Opportunity opp;  
            
            if(lNoteComite.CalculetteROE1__c != null && calc1Map.containsKey(lNoteComite.CalculetteROE1__c)){
                calcROE1 = calc1Map.get(lNoteComite.CalculetteROE1__c);
            }
            
            if(lNoteComite.CalculetteROE2__c != null && calc2Map.containsKey(lNoteComite.CalculetteROE2__c)){
                calcROE2 = calc1Map.get(lNoteComite.CalculetteROE2__c);
            }

			if(lNoteComite.ProjetAssocie__c != null && oppMap.containsKey(lNoteComite.ProjetAssocie__c)){
                opp = oppMap.get(lNoteComite.ProjetAssocie__c);
            }            
            
            if(calcROE2 != null){
                opp.ROEStandardRSC__c = math.min(calcROE1.ROEmoyenApresImpotStandard__c,calcROE2.ROEmoyenApresImpotStandard__c);
                opp.ROEIRBARSC__c = math.min(calcROE1.ROEMApresimpotIRBA__c,calcROE2.ROEMApresimpotIRBA__c);
                opp.MargeCommercialeApresLiquiditeITERSC__c = math.min(calcROE1.MargeCommercialeApresLiquiditeITE__c,calcROE2.MargeCommercialeApresLiquiditeITE__c);
            }
            else{
                opp.ROEStandardRSC__c = calcROE1.ROEmoyenApresImpotStandard__c;
                opp.ROEIRBARSC__c = calcROE1.ROEMApresimpotIRBA__c;
                opp.MargeCommercialeApresLiquiditeITERSC__c = calcROE1.MargeCommercialeApresLiquiditeITE__c;
            }
            
            oppToUpdate.add(opp);
            
        }
        update oppToUpdate;
    }
    
    /**
     * Appelé à la suppression d'une note comité pour supprimer les données relatives à celle ci dans 
     * les autres objets
     */
    public static void nettoyageDesDonnees(NoteComite__c[] notes) {
        
        // objets à mettre à jour
        List<CalculetteROE__c> calculettesToUpdate = new List<CalculetteROE__c>();
		
        // On récupère les ids des notes comites
        Set<Id> notesIds = new Set<Id>();        
        
        for(NoteComite__c lNote : notes){
            notesIds.add(lNote.Id);
        }
                
        // Objets récupérés de la base
        Map<Id, CalculetteROE__c> calculettesMap = new Map<Id, CalculetteROE__c>([SELECT Id, IDPropositionCommerciale__c, NomPropositionCommerciale__c  FROM CalculetteROE__c WHERE IDNoteComite__c IN :notesIds]);
        
        // Calculette ROE à mettre à jour
        for(CalculetteROE__c lCalculette : calculettesMap.values()){
            lCalculette.IDNoteComite__c = null;
            lCalculette.NomNoteComite__c = null;
            lCalculette.NbNoteComite__c = 0;
            calculettesToUpdate.add(lCalculette);
        }
        
        update calculettesToUpdate;
        
        // Suppression des liens NoteComite-Bien
        List<NoteComiteBien__c> listeNcBiensToDelete = [SELECT Id, NoteComite__c, BienCBI__c FROM NoteComiteBien__c WHERE NoteComite__c = null];
        delete listeNcBiensToDelete;
 
    }     
    
}