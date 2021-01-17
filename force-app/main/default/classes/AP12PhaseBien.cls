public class AP12PhaseBien {

    /**
     * A la création d'un Avenant, complète les données avec celles de la phase de bien précédente
     */ 
    public static void creerAvenant(PhaseDeBien__c[] aListePdb){
        
        // On récupère toutes les phases de biens flagguées "Dernière phase créée"
        List<PhaseDeBien__c> lListeDerPdb = [SELECT Id, DernierePhaseDeBien__c, NomDuBien__c,
                                                    NatureSurface1__c, NatureSurface2__c, NatureSurface3__c, NatureSurface4__c, NatureSurface5__c,
                                                    NatureSurface6__c, NatureSurface7__c, NatureSurface8__c, NatureSurface9__c, NatureSurface10__c,
                                                    NatureSurface11__c, NatureSurface12__c, NatureSurface13__c, NatureSurface14__c, NatureSurface15__c,
                                                    TotalSdVNS1__c, TotalSdVNS2__c, TotalSdVNS3__c, TotalSdVNS4__c, TotalSdVNS5__c, TotalSdVNS6__c,
                                                    TotalSdVNS7__c, TotalSdVNS8__c, TotalSdVNS9__c, TotalSdVNS10__c, TotalSdVNS11__c, TotalSdVNS12__c,
                                                    TotalSdVNS13__c, TotalSdVNS14__c, TotalSdVNS15__c, TypeDeSurface1__c,
                                                    TotalNS0__c, TotalNS1__c, TotalNS2__c, TotalNS3__c, TotalNS4__c, TotalNS5__c,
                                                    TotalNS6__c, TotalNS7__c, TotalNS8__c, TotalNS9__c, TotalNS10__c, TotalNS11__c,
                                                    TotalNS12__c, TotalNS13__c, TotalNS14__c, TotalNS15__c, TotalSurfaceDemolition__c, TotalSurfaceSdVDemolition__c,
                                                    TotalFraisDemolition__c, TotalVRD__c, TotalTravaux__c, TotalHonoraires__c, TotalAssurances__c, TotalDiversImprevus__c, TotalCoutLibre__c, TotalAutres__c,
                                                    MontantTerrainExistants__c, MontantTerrainConsAvt__c, TotalPrixFoncier__c, MontantAutresExistants__c, MontantAutresConsAvt__c, TotalMontantAutre__c, 
                                                    MontantAcquisitionExistants__c, MontantAcquisitionConsAvt__c, TotalMontantAcquisition__c, FraisAcquisitionExistants__c, FraisAcquisitionConsAvt__c, TotalFraisAcquisition__c,
                                                    AvancePreneurCol1__c, AvancePreneurCol2__c, AvancePreneurTotal__c, SubventionCol1__c, SubventionCol2__c, SubventionTotal__c
                                                    FROM PhaseDeBien__c WHERE DernierePhaseDeBien__c = true];
        
        
        for(PhaseDeBien__c lPdb : aListePdb){
            for(PhaseDeBien__c lDerPdb : lListeDerPdb){
                // Si on trouve la dernière phase de Bien créée
                if(lPdb.NomDuBien__c == lDerPdb.NomDuBien__c){
                    // On recopie les valeurs pour l'existant
                    completerNewPdb(lPdb, lDerPdb);
                }
            }
        }
    }
    
    /**
     * Complète la phase de bien créée avec la pdb précédente
     */
    private static void completerNewPdb(PhaseDeBien__c aPdbACompleter, PhaseDeBien__c aDerPdb){
        
            // Nature Surface
            aPdbACompleter.TypeDeSurface1__c = aDerPdb.TypeDeSurface1__c;
            aPdbACompleter.NatureSurface1__c = aDerPdb.NatureSurface1__c;  
            aPdbACompleter.NatureSurface2__c = aDerPdb.NatureSurface2__c;
            aPdbACompleter.NatureSurface3__c = aDerPdb.NatureSurface3__c;
            aPdbACompleter.NatureSurface4__c = aDerPdb.NatureSurface4__c;
            aPdbACompleter.NatureSurface5__c = aDerPdb.NatureSurface5__c;
            aPdbACompleter.NatureSurface6__c = aDerPdb.NatureSurface6__c;
            aPdbACompleter.NatureSurface7__c = aDerPdb.NatureSurface7__c;
            aPdbACompleter.NatureSurface8__c = aDerPdb.NatureSurface8__c;
            aPdbACompleter.NatureSurface9__c = aDerPdb.NatureSurface9__c;
            aPdbACompleter.NatureSurface10__c = aDerPdb.NatureSurface10__c;
            aPdbACompleter.NatureSurface11__c = aDerPdb.NatureSurface11__c;
            aPdbACompleter.NatureSurface12__c = aDerPdb.NatureSurface12__c;
            aPdbACompleter.NatureSurface13__c = aDerPdb.NatureSurface13__c;
            aPdbACompleter.NatureSurface14__c = aDerPdb.NatureSurface14__c;
            aPdbACompleter.NatureSurface15__c = aDerPdb.NatureSurface15__c;     
        
            // Existant Surface
            aPdbACompleter.NS0SurfaceExistants__c = aDerPdb.TotalNS0__c;
            aPdbACompleter.NS1SurfaceExistants__c = aDerPdb.TotalNS1__c;
            aPdbACompleter.NS2SurfaceExistants__c = aDerPdb.TotalNS2__c;
            aPdbACompleter.NS3SurfaceExistants__c = aDerPdb.TotalNS3__c;
            aPdbACompleter.NS4SurfaceExistants__c = aDerPdb.TotalNS4__c;
            aPdbACompleter.NS5SurfaceExistants__c = aDerPdb.TotalNS5__c;
            aPdbACompleter.NS6SurfaceExistants__c = aDerPdb.TotalNS6__c;
            aPdbACompleter.NS7SurfaceExistants__c = aDerPdb.TotalNS7__c;
            aPdbACompleter.NS8SurfaceExistants__c = aDerPdb.TotalNS8__c;
            aPdbACompleter.NS9SurfaceExistants__c = aDerPdb.TotalNS9__c;
            aPdbACompleter.NS10SurfaceExistants__c = aDerPdb.TotalNS10__c;
            aPdbACompleter.NS11SurfaceExistants__c = aDerPdb.TotalNS11__c;
            aPdbACompleter.NS12SurfaceExistants__c = aDerPdb.TotalNS12__c;
            aPdbACompleter.NS13SurfaceExistants__c = aDerPdb.TotalNS13__c;
            aPdbACompleter.NS14SurfaceExistants__c = aDerPdb.TotalNS14__c;
            aPdbACompleter.NS15SurfaceExistants__c = aDerPdb.TotalNS15__c;
        
        
            // Avance Preneur et subvention
            aPdbACompleter.AvancePreneurCol1__c = aDerPdb.AvancePreneurTotal__c;
            aPdbACompleter.SubventionCol1__c = aDerPdb.SubventionTotal__c;
        
            // Existant Sdv
            aPdbACompleter.NS1SdVExistants__c = aDerPdb.TotalSdVNS1__c;
            aPdbACompleter.NS2SdVExistants__c = aDerPdb.TotalSdVNS2__c;
            aPdbACompleter.NS3SdVExistants__c = aDerPdb.TotalSdVNS3__c;
            aPdbACompleter.NS4SdVExistants__c = aDerPdb.TotalSdVNS4__c;
            aPdbACompleter.NS5SdVExistants__c = aDerPdb.TotalSdVNS5__c;
            aPdbACompleter.NS6SdVExistants__c = aDerPdb.TotalSdVNS6__c;
            aPdbACompleter.NS7SdVExistants__c = aDerPdb.TotalSdVNS7__c;
            aPdbACompleter.NS8SdVExistants__c = aDerPdb.TotalSdVNS8__c;
            aPdbACompleter.NS9SdVExistants__c = aDerPdb.TotalSdVNS9__c;
            aPdbACompleter.NS10SdVExistants__c = aDerPdb.TotalSdVNS10__c;
            aPdbACompleter.NS11SdVExistants__c = aDerPdb.TotalSdVNS11__c;
            aPdbACompleter.NS12SdVExistants__c = aDerPdb.TotalSdVNS12__c;
            aPdbACompleter.NS13SdVExistants__c = aDerPdb.TotalSdVNS13__c;
            aPdbACompleter.NS14SdVExistants__c = aDerPdb.TotalSdVNS14__c;
            aPdbACompleter.NS15SdVExistants__c = aDerPdb.TotalSdVNS15__c;

            // Surface de démolition
            aPdbACompleter.SurfaceDemolition__c = aDerPdb.TotalSurfaceDemolition__c;
            aPdbACompleter.SurfaceSdVDemolition__c = aDerPdb.TotalSurfaceSdVDemolition__c;
            
            // Foncier / Acquisition
            aPdbACompleter.MontantTerrainExistants__c  = aDerPdb.TotalPrixFoncier__c;
            aPdbACompleter.MontantAutresExistants__c  = aDerPdb.TotalMontantAutre__c;
            aPdbACompleter.MontantAcquisitionExistants__c  = aDerPdb.TotalMontantAcquisition__c;
            aPdbACompleter.FraisAcquisitionExistants__c  = aDerPdb.TotalFraisAcquisition__c;
            
            // Prix de revient
            aPdbACompleter.FraisDemolitionCol1__c = aDerPdb.TotalFraisDemolition__c;
            aPdbACompleter.VRDCol1__c = aDerPdb.TotalVRD__c;
            aPdbACompleter.TravauxCol1__c = aDerPdb.TotalTravaux__c;
            aPdbACompleter.HonorairesCol1__c = aDerPdb.TotalHonoraires__c;
            aPdbACompleter.AssurancesCol1__c = aDerPdb.TotalAssurances__c;
            aPdbACompleter.DiversImprevusCol1__c = aDerPdb.TotalDiversImprevus__c;
            aPdbACompleter.CoutLibre1__c = aDerPdb.TotalCoutLibre__c;
            aPdbACompleter.AutresCol1__c = aDerPdb.TotalAutres__c;
            
    }
    
    /**
     * Rapartrie les données de la dernière phase de bien sur le BienCBI
     */
    public static void rapatrierDonneesSurBien(PhaseDeBien__c[] aListePdb){
        
        // Bien_CBI 's à mettre à jour
        List<Bien_CBI__c> biensToUpdate = new List<Bien_CBI__c>();
        Set<String> names = new Set<String>();
        for(PhaseDeBien__c lPdb : aListePdb){
            names.add(lPdb.Name);
        }
        
        // On récupère le bien à mettre à jour
        List<Bien_CBI__c> lBiens = [SELECT Id, InformationCadastrePdB__c, TotalMontantAcquisitionPdB__c, IDDernierePhaseDeBien__c, TotalConsAvt__c FROM BIEN_CBI__c WHERE IDDernierePhaseDeBien__c IN :names];
        
        for(PhaseDeBien__c lPhase : aListePdb){
           for(Bien_CBI__c lBien : lBiens){
               if(lBien.IDDernierePhaseDeBien__c == lPhase.Name && lPhase.DernierePhaseDeBien__c == true){

                    lBien.InformationCadastrePdB__c = lPhase.Information_Cadastre__c;
                    lBien.TotalMontantAcquisitionPdB__c = lPhase.TotalMontantAcquisition__c;
                    lBien.TotalConsAvt__c = lPhase.TotalConsAvt__c;
                    lBien.TotalEncoursNetDuBien__c = lPhase.TotalEncoursEntBien__c;
                    biensToUpdate.add(lBien);
               }
                
            }
            
        }
        update biensToUpdate;
        
    }
    
        
    /**
     * A la suppression de la dernière Phase de Bien, met à jour la nouvelle dernière PdB pour réactiver les workflows
     */
    public static void majDernierePhase(PhaseDeBien__c[] aListePdb){
        
        // objets à mettre à jour
        Map<Id, PhaseDeBien__c> lPhases = new Map<Id, PhaseDeBien__c>();
        Map<Id, Bien_CBI__c> biensToUpdate = new Map<Id, Bien_CBI__c>();
        
        // Ids des biens 
        Set<Id> biensIds = new Set<Id>();
        
        for(PhaseDeBien__c lPhase : aListePdb){
            biensIds.add(lPhase.NomDuBien__c);
        }
        
        List<PhaseDeBien__c> phases = [SELECT Id, Name, DernierePhaseDeBien__c, CreatedDate, Commentaires__c, NomDuBien__c, NomDuBien__r.IDDernierePhaseDeBien__c FROM PhaseDeBien__c WHERE NomDuBien__c IN :biensIds ORDER BY CreatedDate DESC LIMIT 1];
        Map<Id, Bien_CBI__c> biensMap = new Map<Id, Bien_CBI__c>([SELECT Id, IDDernierePhaseDeBien__c FROM Bien_CBI__c WHERE Id IN :biensIds]);
        
        for(PhaseDeBien__c lPhase : aListePdb){
            
            Boolean isDernierePhaseTrouvee = false;
            
            for(PhaseDeBien__c phase : phases){
            
                if(phase.NomDuBien__c == lPhase.NomDuBien__c && !isDernierePhaseTrouvee){
                    
                    Bien_CBI__c lBien = biensMap.get(phase.NomDuBien__c);

                    if(lBien != null){
                        lBien.IDDernierePhaseDeBien__c = phase.Name;
                        biensToUpdate.put(lBien.Id, lBien);
                    }
                    // On met à jour un champ pour déclencher les workflows  
                    phase.Commentaires__c = phase.Commentaires__c;
                    lPhases.put(phase.Id, phase);
                    
                    isDernierePhaseTrouvee = true;
                }
            }
        }
        
        update biensToUpdate.values();
        update lPhases.values();
  
    }

}