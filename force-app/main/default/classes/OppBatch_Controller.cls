public class OppBatch_Controller {
    
    public class jsonOpp{
        public String accountName;
        public String accountId;
        public String name;
        public String comNumber;
        public String aveNumber;
        public String vehNumber;
        public String numCommandes;
        public String numAve;
        public String comType;
        public String aveType;
        public String recType;
        public String recordId;
        public String conPCD;
        public String conPCR;
        public String conPP;
        public String conPC;
        public String conPFC;
        public String statMarge;
        public String nombreFleet;
        public String typologieFleet;
    }
    
    public class oppList{
        @testVisible
        public List<jsonOpp> opp;
    }

    public class mPickList {
        public List<mPickListValues> options;
    }

    public class mPickListValues {
        public Integer Id;
        public String Name;
    }
    
    @AuraEnabled
    public static List<Account> getAccounts(String accId){
        List<Account> childrenAccounts = new List<Account>([
            SELECT Name FROM Account WHERE ParentId = :accId
        ]);
        if(childrenAccounts.size() > 0) {
            return childrenAccounts;
        }
        return null;
    }

    @AuraEnabled
    public static String getMultiPicklistValues(String field) {
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Opportunity');
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get(field).getDescribe();
        List<Schema.PicklistEntry> picklistEntries = objFieldInfo.getPicklistValues();

        OppBatch_Controller.mPickList picklistValues = new OppBatch_Controller.mPickList();
        picklistValues.options = new List<OppBatch_Controller.mPickListValues>();
        Integer i = 0;
        
        for(Schema.PicklistEntry ple: picklistEntries) {
            OppBatch_Controller.mPickListValues plValue = new OppBatch_Controller.mPickListValues();
            
            plValue.Name = ple.getValue();
            plValue.Id = i++;

            picklistValues.options.add(plValue);
        }

        return JSON.serialize(picklistValues.options);
    }
    
    @AuraEnabled
    public static void createOpportunities(String JsonOpps, String recordType){
        DateTime newDate = System.Now().addYears(3);
        List<jsonOpp> opportunities = new List<jsonOpp>();
        List<Opportunity> newOpportunities = new List<Opportunity>();

        opportunities = (List<jsonOpp>)JSON.deserialize(JsonOpps, List<jsonOpp>.class);
    
        for(jsonOpp opp : opportunities) {
            Id recordTypeOpp;
            Opportunity newOpp = new Opportunity();
            
            if(opp.recType == 'avenant'){
                newOpp.StageName = 'Proposition envoyée';
                newOpp.NumAvenantSequana__c = opp.aveNumber;
                newOpp.Type_avenant__c = opp.aveType;
                newOpp.Num_Comm_multi_vh__c = opp.numAve;
                newOpp.Nombre_vh__c = Decimal.valueOf(opp.vehNumber);
                recordTypeOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LLD_Avenant').getRecordTypeId();
                newOpp.Statut_retour_marge__c = getInsertableValues(opp.statMarge);
            } 
            else if(opp.recType == 'commande') {
                newOpp.StageName = 'Cotation';
                newOpp.NumCommandeSequana__c = opp.comNumber;
                newOpp.Typologie_de_commande__c = opp.comType;
                newOpp.Num_Comm_multi_vh__c = opp.numCommandes;
                newOpp.Nombre_vh__c = Decimal.valueOf(opp.vehNumber);
                recordTypeOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LLD_Commande').getRecordTypeId();
                newOpp.Controle_pieces_client_COM__c = getInsertableValues(opp.conPCD);
                newOpp.Controle_des_pieces_client_reseau_COM__c = getInsertableValues(opp.conPCR);
                newOpp.Controle_pieces_prestations_COM__c = getInsertableValues(opp.conPP);
                newOpp.Controle_pieces_commande_COM__c = getInsertableValues(opp.conPC);
            }
            else if(opp.recType == 'fleet') {
                newOpp.StageName = 'Proposition';
                newOpp.NumCommandeSequana__c = opp.comNumber;
                newOpp.Num_Comm_multi_vh__c = opp.numCommandes;
                newOpp.TypologieFleet__c = opp.typologieFleet;
                newOpp.NombreFleet__c = Decimal.valueOf(opp.nombreFleet);
                recordTypeOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LLD_Fleet').getRecordTypeId();
                newOpp.Controle_pieces_prestations_COM__c = getInsertableValues(opp.conPP);
                newOpp.ControlePiecesFleetMO__c = getInsertableValues(opp.conPFC);
            }

            newOpp.RecordTypeId = recordTypeOpp;
            newOpp.Name = opp.Name;
            newOpp.CloseDate = newDate.date();
            newOpp.AccountId = opp.accountId;
            
            // Validation rules
            if(opp.recType == 'commande' && Decimal.valueOf(opp.vehNumber) > 1 && (opp.numCommandes == '' || opp.numCommandes == null)) {
                throw new AuraHandledException('Votre projet associé contient plusieurs véhicules, merci de renseigner les numéros de commandes si multi véhicules.');
            }

            newOpportunities.add(newOpp);
        }

        Database.insert(newOpportunities);
    }

    public static String getInsertableValues(String field) {
        String values = '';
        List<mPickListValues> plValues = new List<mPickListValues>();
        
        plValues = (List<mPickListValues>)JSON.deserialize(field, List<mPickListValues>.class);

        for(mPickListValues plVal : plValues) {
            values += plVal.Name + ';';
        }

        return values.removeEndIgnoreCase(';');
    }
}