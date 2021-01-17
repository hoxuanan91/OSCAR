public class AP21_SearchPicklist {
    
    public static List<ListValue> getTypeMaterielFromCase(){
        List<ListValue> typeMateriel = new List<ListValue>();
        
        for(Schema.PicklistEntry opt : Case.TypeDeMateriel__c.getDescribe().getPicklistValues()){
            typeMateriel.add(new ListValue(opt));
        }
        
        return typeMateriel;
    }
	
    public static List<ListValue> getNiveauDeReclamationFromCase(){
        List<ListValue> niveauDeReclamation = new List<ListValue>();

        for(Schema.PicklistEntry opt : Case.NiveauDeReclamation__c.getDescribe().getPicklistValues()){
			niveauDeReclamation.add(new ListValue(opt));
        }

        return niveauDeReclamation;
    }

    public static List<ListValue> getMotifReglementaireFromCase(){
        List<ListValue> motifReglementaire = new List<ListValue>();

        for(Schema.PicklistEntry opt : Case.MotifReglementaire__c.getDescribe().getPicklistValues()){
			motifReglementaire.add(new ListValue(opt));
        }

        return motifReglementaire;
    }

    public static List<ListValue> getMotifQualiteFromCase(){
        List<ListValue> motifQualite = new List<ListValue>();

        for(Schema.PicklistEntry opt : Case.MotifQualite__c.getDescribe().getPicklistValues()){
			motifQualite.add(new ListValue(opt));
        }

        return motifQualite;
    }

    public static List<ListValue> getCanalFromCase(){
        List<ListValue> canal = new List<ListValue>();

        for(Schema.PicklistEntry opt : Case.Canal__c.getDescribe().getPicklistValues()){
			canal.add(new ListValue(opt));
        }

        return canal;
    }

    public static List<ListValue> getOccasionNeufFromCase(){
        List<ListValue> occasionNeuf = new List<ListValue>();

        for(Schema.PicklistEntry opt : Case.OccasionNeuf__c.getDescribe().getPicklistValues()){
            occasionNeuf.add(new ListValue(opt));
        }

        return occasionNeuf;
    }

    public static List<ListValue> getTypeVehiculeFromCase(){
        List<ListValue> typeVehicule = new List<ListValue>();

        for(Schema.PicklistEntry opt : Case.TypeVehicule__c.getDescribe().getPicklistValues()){
            typeVehicule.add(new ListValue(opt));
        }

        return typeVehicule;
    }

    public static List<ListValue> getNiveauUrgenceValoFromCase(){
        List<ListValue> niveauUrgence = new List<ListValue>();

        for(Schema.PicklistEntry opt : Case.NiveauUrgence__c.getDescribe().getPicklistValues()){ 
            niveauUrgence.add(new ListValue(opt));
        }

        return niveauUrgence;
    }

    public static List<ListValue> getSinistreMaterielFromCase(){
        List<ListValue> sinitreMateriel = new List<ListValue>();

        for(Schema.PicklistEntry opt : Case.SinMateriel__c.getDescribe().getPicklistValues()){
            sinitreMateriel.add(new ListValue(opt));
        }

        return sinitreMateriel;
    }

    public static List<ListValue> getTransfertFromCase(){
        List<ListValue> transfert = new List<ListValue>();

        for(Schema.PicklistEntry opt : Case.Transfert__c.getDescribe().getPicklistValues()){
            transfert.add(new ListValue(opt));
        }

        return transfert;
    }
    
     public static List<ListValue> getTypeTransfertFromCase(){
        List<ListValue> typeTransfert = new List<ListValue>();

        for(Schema.PicklistEntry opt : Case.Type_Transfert__c.getDescribe().getPicklistValues()){
            typeTransfert.add(new ListValue(opt));
        }

        return typeTransfert;
    }
    
    public static ListValue getCurrentBusinessUnitFromCase(String businessUnitValue){
        ListValue businessUnit = new ListValue(null, null);

        for(Schema.PicklistEntry opt : Case.BusinessUnit__c.getDescribe().getPicklistValues()){
            if (opt.getValue() == businessUnitValue) {
                businessUnit = new ListValue(opt.getValue(), opt.getLabel());
            }
        }

        return businessUnit;
    }
    
    
    
    public class ListValue {
		@AuraEnabled public String value;
		@AuraEnabled public String label;
				
		public ListValue(String value, String label){
			this.value = value;
			this.label = label;
		}
		
		public ListValue(Schema.PicklistEntry opt){
			this(opt.getValue(), opt.getLabel());	
		}
	}
}