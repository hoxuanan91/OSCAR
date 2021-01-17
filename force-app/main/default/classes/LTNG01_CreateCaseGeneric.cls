public with sharing class LTNG01_CreateCaseGeneric {

    @AuraEnabled public static RecordFormWrapper initRecordForm(Id recordId, String sObjectName) {
        RecordFormWrapper result = null;

        if (sObjectName == 'Contract') {
            result = new RecordFormWrapper([
                    SELECT Id,
                            BusinessUnit__c,
                            NomClient__c,
                            AccountId,
                			DureeMois__c,
                            ProjetAssocie__c,
                            ProjetAssocie__r.ReseauApporteur1RCBI__c,
                            ProjetAssocie__r.ReseauApporteur1__r.Name,
                            ProjetAssocie__r.Montant1erLoyer__c,
                            ProjetAssocie__r.Amount,
                			ProjetAssocie__r.TypeDeMateriel__c,
                			ProjetAssocie__r.VR__c,
                			ProjetAssocie__r.NEngagementV4__c,
                    (SELECT Id, Nom_du_Tiers__c, Nom_du_Tiers__r.Name FROM Autres_acteurs__r WHERE Role__c = 'Fournisseur'),
                    (SELECT Id, Name, Immatriculation__c FROM Biens__r)
                    FROM Contract WHERE Id =: recordId]);
        } else if (sObjectName == 'Opportunity') {
            Contract[] tmpContract = [
                    SELECT Id,
                            BusinessUnit__c,
                            NomClient__c,
                            AccountId,
                			DureeMois__c,
                            ProjetAssocie__c,
                            ProjetAssocie__r.ReseauApporteur1RCBI__c,
                            ProjetAssocie__r.ReseauApporteur1__r.Name,
                            ProjetAssocie__r.Montant1erLoyer__c,
                            ProjetAssocie__r.Amount,
                			ProjetAssocie__r.TypeDeMateriel__c,
                			ProjetAssocie__r.VR__c,
                			ProjetAssocie__r.NEngagementV4__c,
                    (SELECT Id, Nom_du_Tiers__c, Nom_du_Tiers__r.Name FROM Autres_acteurs__r WHERE Role__c = 'Fournisseur'),
                    (SELECT Id, Name, Immatriculation__c FROM Biens__r)
                    FROM Contract WHERE ProjetAssocie__c =: recordId];
            if (tmpContract.size() > 0) {
                result = new RecordFormWrapper(tmpContract[0]);
            } else {
                Opportunity[] tmpOpportunity = [
                    	SELECT Id,
                    			BusinessUnit__c,
                    			AccountId,
                    			NomClient__c,
                    			ReseauApporteur1RCBI__c,
                    			ReseauApporteur1__r.Name,
                    			Montant1erLoyer__c,
                    			Amount,
                    			TypeDeMateriel__c,
                    			VR__c,
                    			DureeDeFinancementMois__c,
                    			NEngagementV4__c,
                    	(SELECT Id, NomDuTiers__c, NomDuTiers__r.Name FROM Fournisseurs_ProjetAssoci__r)
                    	FROM Opportunity WHERE Id =: recordId];
                
                result = new RecordFormWrapper(tmpOpportunity[0]);
            }
        }

        System.debug(result);
        return result;
    }

    @AuraEnabled public static Id saveCaseGeneric(String recordFormJSON, String recordTypeDeveloperName) {
        System.debug('@@recordFormJSON '+recordFormJSON);
        System.debug('@@ recordTypeDeveloperName ' +recordTypeDeveloperName);
        RecordFormWrapper recordForm = (RecordFormWrapper) JSON.deserialize(recordFormJSON, RecordFormWrapper.class);
        System.debug('@@ recordForm ' +recordFormJSON);
        System.debug('@@ recordForm.typeTransfert.value ' +recordForm.typeTransfert.value);
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
        // Remove dans le champs les balises:  <br/> ET  &nbsp;
       
        String caseOrigin;
       if('CBM_Transfert_Pilote_DCR3'.equalsIgnoreCase(recordTypeDeveloperName)){
            caseOrigin='Délégation';          
        }
      
        String informationFront = recordForm.caseZonesRecommandationsByCaseRecordType.get(recordTypeDeveloperName); 
        informationFront = informationFront.replace('<br />', '\n');
        informationFront = informationFront.replace('&nbsp;', '');

        Case newCase = new Case(
                // FOR ALL
                RecordTypeId = recordTypeId,
                Status = 'A prendre en charge',
                Dossier1__c = recordForm.contractId,
                AccountId = recordForm.accountId,
                CommentaireFront__c = recordForm.commentaire,
                ProjetAssocie__c = recordForm.oppId,
                InformationFront__c = informationFront,
            	NEngagementV4__c = recordForm.nEngagementV4,
            	BusinessUnit__c = recordForm.bu.value,
                // CBM - Transfert & CBM - Relocation
                Accord_demande_la_deleg_banque__c = recordForm.accordDemandeDelegBanque,
                AccDemDEC__c = recordForm.accordDemandeDEC,
                // CBM - Transfert                
                Origin=caseOrigin!=null?caseOrigin:null,          
                // 
                Transfert__c = recordForm.transfert.value,
            	Type_Transfert__c = recordForm.typeTransfert.value,
                Date_reception_en_delegation__c = recordForm.receptionEnDelegation,
                AccdDemABPI__c = recordForm.accordDemandeBPICoBailleur,
                // CBM - Relocation
                PropEnvoyCli__c = recordForm.propositionEnvoyeeClient,
                AccptClient__c = recordForm.acceptationClient,
                // CBM - Sinistre Matériel
                SinMateriel__c = recordForm.sinistreMateriel.value,
                // CBM - Réclamation
                NiveauDeReclamation__c = recordForm.niveauDeReclamation.value,
                DateRecepDde__c = recordForm.dateReceptionDemande,
                MotifReglementaire__c = recordForm.motifReglementaire.value,
                MotifQualite__c = recordForm.motifQualite.value,
                Canal__c = recordForm.canal.value,
                // CBM - SAV
                DuplicataCertifVentes__c = recordForm.duplicataCertificatDeVente,
                Duplicata__c = recordForm.duplicata,
                Autre_SAV__c = recordForm.autreSav,
                MandatImmat__c = recordForm.mandatImmatriculation,
                ChangAdresse__c = recordForm.changementAdresse,
                DetailDuplic__c = recordForm.detailDuDuplicata,
                DetailSAV__c = recordForm.detailSav,
                Attestation__c = recordForm.attestation,
                // CBM - Valorisation
                TypeDeMateriel__c = recordForm.typeDeMateriel,
                MarqueFabricant__c = recordForm.marqueFabricant,
                Fournisseur__c = recordForm.fournisseur,
                NumImmat__c = recordForm.immatriculation,
                PremiereMiseEnCirculation__c = recordForm.premiereMiseEnCirculation,
                DescriptifDuMateriel__c = recordForm.descriptifDuMateriel,
                EquipementsEtAccessoires__c = recordForm.equipementsEtAccessoires,
                KilometrageOuNbDHeures__c = recordForm.kilometrageOuNbHeures,
                PrixHT__c = recordForm.prixHT,
                DureeEnMois__c = recordForm.dureeEnMois,
                PremierLoyer__c = recordForm.premierLoyer,
                NiveauUrgence__c = recordForm.niveauUrgence.value,
                TypeVehicule__c = recordForm.typeVehicule.value,
                OccasionNeuf__c = recordForm.occasionNeuf.value,
				VR__c = recordForm.vr
        );

        insert newCase;

        return newCase.Id;
    }


    public class RecordFormWrapper {
        //TMP Avant mise en service => TODELETE
        @AuraEnabled public String								currentProfileName = [select id, Name from Profile WHERE Id =: UserInfo.getProfileId()][0].Name;
        
        @AuraEnabled public String					            caseRecordType;
        @AuraEnabled public Id								    contractId;
        @AuraEnabled public Id								    oppId;
        @AuraEnabled public Id								    accountId;
        @AuraEnabled public String								nEngagementV4;
        // CBM - Valorisation
        @AuraEnabled public String								typeDeMateriel;
        @AuraEnabled public AP21_SearchPicklist.ListValue		bu;
        @AuraEnabled public String      						reseauApporteur;
        @AuraEnabled public String								nomClient;
        @AuraEnabled public String								marqueFabricant;
        @AuraEnabled public String      					    fournisseur;
        @AuraEnabled public String								immatriculation;
        @AuraEnabled public String								premiereMiseEnCirculation;
        @AuraEnabled public String								descriptifDuMateriel;
        @AuraEnabled public String								equipementsEtAccessoires;
        @AuraEnabled public String								kilometrageOuNbHeures;
        @AuraEnabled public Decimal								prixHT;
        @AuraEnabled public Integer								dureeEnMois;
        @AuraEnabled public Decimal								premierLoyer;
        @AuraEnabled public PicklistWrapper						niveauUrgence;
        @AuraEnabled public PicklistWrapper						occasionNeuf;
        @AuraEnabled public PicklistWrapper						typeVehicule;
        @AuraEnabled public Decimal								vr;
        // CBM - Transfert && CBM - Relocation
        @AuraEnabled public Date								accordDemandeDelegBanque;
        @AuraEnabled public Date								accordDemandeDEC;
        @AuraEnabled public Date								receptionEnDelegation;
		@AuraEnabled public PicklistWrapper						typeTransfert;
        // CBM - Transfert
        @AuraEnabled public PicklistWrapper						transfert;
        @AuraEnabled public Date								accordDemandeBPICoBailleur;
        // CBM - Relocation
        @AuraEnabled public Date                                propositionEnvoyeeClient;
        @AuraEnabled public Date                                acceptationClient;
        // CBM - Réclamation
        @AuraEnabled public PicklistWrapper						niveauDeReclamation;
        @AuraEnabled public Date						        dateReceptionDemande;
        @AuraEnabled public PicklistWrapper						motifReglementaire;
        @AuraEnabled public PicklistWrapper						motifQualite;
        @AuraEnabled public PicklistWrapper						canal;
        // CBM - SAV
        @AuraEnabled public Boolean								duplicataCertificatDeVente=false;
        @AuraEnabled public Boolean								duplicata=false;
        @AuraEnabled public Boolean								autreSav=false;
        @AuraEnabled public Boolean								mandatImmatriculation=false;
        @AuraEnabled public Boolean								changementAdresse=false;
        @AuraEnabled public String								detailDuDuplicata;
        @AuraEnabled public String								detailSav;
        @AuraEnabled public Boolean								attestation=false;
        // CBM - Sinistre Matériel
        @AuraEnabled public PicklistWrapper                     sinistreMateriel;
        //Generic (For all)
        @AuraEnabled public String								commentaire;
        @AuraEnabled public Map<String, String>					componentLightningByCaseRecordType;
        @AuraEnabled public Map<String, String>					caseZonesRecommandationsByCaseRecordType;
        @AuraEnabled public Map<String, Boolean>				caseAccessFromOpportunityByCaseRecordType;
        @AuraEnabled public Map<String, Boolean>				recordTypeAccessByCaseRecordType = new Map<String, Boolean>();
        @AuraEnabled public String                              valorisationPopup;

        public RecordFormWrapper(Contract ctr) {

            this.contractId = ctr.Id;
            this.oppId = ctr.ProjetAssocie__c;
            this.accountId = ctr.AccountId;
            this.nEngagementV4 = ctr.ProjetAssocie__r.NEngagementV4__c;

            //CBM - Valorisation
            this.bu = AP21_SearchPicklist.getCurrentBusinessUnitFromCase(ctr.BusinessUnit__c);
            this.nomClient = ctr.NomClient__c;
            this.reseauApporteur = ctr.ProjetAssocie__r.ReseauApporteur1RCBI__c;
            this.vr = ctr.ProjetAssocie__r.VR__c;
            this.dureeEnMois = ctr.DureeMois__c != null ? Integer.valueof(ctr.DureeMois__c) : null;
            this.prixHT = ctr.ProjetAssocie__r.Amount;
            if (ctr.ProjetAssocie__r.Montant1erLoyer__c != null && ctr.ProjetAssocie__r.Amount != null) {
                this.premierLoyer = (ctr.ProjetAssocie__r.Montant1erLoyer__c  / ctr.ProjetAssocie__r.Amount * 100).setScale(2);
            } else {
                this.premierLoyer = null;
            }
            // On get l'info seulement s'il y a qu'une valeur
            if (ctr.Autres_acteurs__r.size() == 1) {
                this.fournisseur = ctr.Autres_acteurs__r[0].Nom_du_Tiers__r.Name;
            }
            // Get Type de matériel du PAS
            if (ctr.ProjetAssocie__r.TypeDeMateriel__c != null) {
                this.typeDeMateriel = ctr.ProjetAssocie__r.TypeDeMateriel__c;
            }
            // On get l'info seulement s'il y a qu'une valeur
            if (ctr.Biens__r.size() == 1) {
                this.immatriculation = ctr.Biens__r[0].Immatriculation__c;
                this.descriptifDuMateriel = ctr.Biens__r[0].Name;
            }

            //Picklist
            this.niveauDeReclamation = new PicklistWrapper(AP21_SearchPicklist.getNiveauDeReclamationFromCase());
            this.motifReglementaire = new PicklistWrapper(AP21_SearchPicklist.getMotifReglementaireFromCase());
            this.motifQualite = new PicklistWrapper(AP21_SearchPicklist.getMotifQualiteFromCase());
            this.canal = new PicklistWrapper(AP21_SearchPicklist.getCanalFromCase());
            this.occasionNeuf = new PicklistWrapper(AP21_SearchPicklist.getOccasionNeufFromCase());
            this.typeVehicule = new PicklistWrapper(AP21_SearchPicklist.getTypeVehiculeFromCase());
            this.niveauUrgence = new PicklistWrapper(AP21_SearchPicklist.getNiveauUrgenceValoFromCase());
            this.sinistreMateriel = new PicklistWrapper(AP21_SearchPicklist.getSinistreMaterielFromCase());
            this.transfert = new PicklistWrapper(AP21_SearchPicklist.getTransfertFromCase());
			this.typeTransfert = new PicklistWrapper(AP21_SearchPicklist.getTypeTransfertFromCase());
            
            //Static Variable
            this.componentLightningByCaseRecordType = AP00_StaticVariable.CASE_COMPONENT_NAME_BY_RECORDTYPE;
            this.caseZonesRecommandationsByCaseRecordType = AP00_StaticVariable.CASE_ZONE_RECOMMANDATION_BY_RECORDTYPE;
            this.caseAccessFromOpportunityByCaseRecordType = AP00_StaticVariable.CASE_ACCESS_FROM_OPPORTUNITY_BY_RECORDTYPE;
            this.valorisationPopup = AP00_StaticVariable.VALORISATION_POPUP;
            
            // Droits user sur les recordTypes Cases
            // Pour la création de demande, tiens compte des droits users
            for (RecordTypeInfo rtInfo: Case.SObjectType.getDescribe().getRecordTypeInfos()) {
                if (rtInfo.isAvailable()) {
                    this.recordTypeAccessByCaseRecordType.put(rtInfo.getDeveloperName(), true);
                } else {
                    this.recordTypeAccessByCaseRecordType.put(rtInfo.getDeveloperName(), false);
                }
            }
        }
        
        public RecordFormWrapper(Opportunity opp) {
            this.oppId = opp.Id;
            this.accountId = opp.AccountId;
			this.nEngagementV4 = opp.NEngagementV4__c;
            
            //CBM - Valorisation
            this.bu = AP21_SearchPicklist.getCurrentBusinessUnitFromCase(opp.BusinessUnit__c);
            this.nomClient = opp.NomClient__c;
            this.reseauApporteur = opp.ReseauApporteur1RCBI__c;
            this.vr = opp.VR__c;
            this.prixHT = opp.Amount;
            this.dureeEnMois = opp.DureeDeFinancementMois__c != null ? Integer.valueof(opp.DureeDeFinancementMois__c) : null;
            if (opp.Montant1erLoyer__c != null && opp.Amount != null) {
                this.premierLoyer = (opp.Montant1erLoyer__c  / opp.Amount * 100).setScale(2);
            } else {
                this.premierLoyer = null;
            }
            // On get l'info seulement s'il y a qu'une valeur
            if (opp.Fournisseurs_ProjetAssoci__r.size() == 1) {
                this.fournisseur = opp.Fournisseurs_ProjetAssoci__r[0].NomDuTiers__r.Name;
            }
            // Get Type de matériel du PAS
            if (opp.TypeDeMateriel__c != null) {
                this.typeDeMateriel = opp.TypeDeMateriel__c;
            }

            //Picklist
            this.niveauDeReclamation = new PicklistWrapper(AP21_SearchPicklist.getNiveauDeReclamationFromCase());
            this.motifReglementaire = new PicklistWrapper(AP21_SearchPicklist.getMotifReglementaireFromCase());
            this.motifQualite = new PicklistWrapper(AP21_SearchPicklist.getMotifQualiteFromCase());
            this.canal = new PicklistWrapper(AP21_SearchPicklist.getCanalFromCase());
            this.occasionNeuf = new PicklistWrapper(AP21_SearchPicklist.getOccasionNeufFromCase());
            this.typeVehicule = new PicklistWrapper(AP21_SearchPicklist.getTypeVehiculeFromCase());
            this.niveauUrgence = new PicklistWrapper(AP21_SearchPicklist.getNiveauUrgenceValoFromCase());
            this.sinistreMateriel = new PicklistWrapper(AP21_SearchPicklist.getSinistreMaterielFromCase());
            this.transfert = new PicklistWrapper(AP21_SearchPicklist.getTransfertFromCase());
			this.typeTransfert = new PicklistWrapper(AP21_SearchPicklist.getTypeTransfertFromCase());
            
            //Static Variable
            this.componentLightningByCaseRecordType = AP00_StaticVariable.CASE_COMPONENT_NAME_BY_RECORDTYPE;
            this.caseZonesRecommandationsByCaseRecordType = AP00_StaticVariable.CASE_ZONE_RECOMMANDATION_BY_RECORDTYPE;
            this.caseAccessFromOpportunityByCaseRecordType = AP00_StaticVariable.CASE_ACCESS_FROM_OPPORTUNITY_BY_RECORDTYPE;
            this.valorisationPopup = AP00_StaticVariable.VALORISATION_POPUP;
            
            // Droits user sur les recordTypes Cases
            // Pour la création de demande, tiens compte des droits users
            for (RecordTypeInfo rtInfo: Case.SObjectType.getDescribe().getRecordTypeInfos()) {
                if (rtInfo.isAvailable()) {
                    this.recordTypeAccessByCaseRecordType.put(rtInfo.getDeveloperName(), true);
                } else {
                    this.recordTypeAccessByCaseRecordType.put(rtInfo.getDeveloperName(), false);
                }
            }
        }

    }

    public class LookupWrapper {
        @AuraEnabled public Id      Id;
        @AuraEnabled public String  Name;

        public LookupWrapper(Id id, String name) {
            this.Id = id;
            this.Name = name;
        }
    }

    public class PicklistWrapper {
        @AuraEnabled public List<AP21_SearchPicklist.ListValue> picklistValues;
        @AuraEnabled public String value;

        public PicklistWrapper(List<AP21_SearchPicklist.ListValue> picklistValues) {
            this.picklistValues = picklistValues;
        }
    }
}