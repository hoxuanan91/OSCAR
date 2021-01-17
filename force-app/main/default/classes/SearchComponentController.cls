/*************************************************************************************
* @description Controller du lightning componant 'Account Locator'
* Class Name - SearchComponentController
*************************************************************************************/
public class SearchComponentController {
    /**
    * @date 23/05/2019
    * @description Recupère une liste d'objets
    * @params objectToSearch : Le nom API de l'objet à récupérer (string)
    * @params fields : Le nom API des champs à récupérer (string)
    * @params filtersArray : array des filtres (SearchComponentObject[])
    * *****/
    
    @AuraEnabled
    public static List<SObject> getObjects(String objectToSearch, String fields, String filtersArray){
        List<SearchComponentObject> SearchComponentObjectList = (List<SearchComponentObject>) JSON.deserialize(filtersArray, List<SearchComponentObject>.class);

        List<SObject> results = new List<SObject>();
        //Première partie de la query
        String query = 'SELECT ' + fields + ' FROM ' + objectToSearch;
        
        //Complétion de la query
        for(Integer i = 0; i < SearchComponentObjectList.size(); i++){
            //Si la valeur du filtre est valide 
            if(SearchComponentObjectList.get(i).value != '' && SearchComponentObjectList.get(i).value != 'Aucune'){
                if(!query.contains('WHERE')){
                    query += ' WHERE ';
                }else{
                    query += ' AND ';
                }
    
                //Query un champ multipicklist
                if(SearchComponentObjectList.get(i).fieldType != 'multipicklist'){
                    query += SearchComponentObjectList.get(i).field + ' LIKE \'%' + SearchComponentObjectList.get(i).value + '%\''  ;
                }else{
                    query += SearchComponentObjectList.get(i).field + ' INCLUDES (\'' + SearchComponentObjectList.get(i).value + '\')'  ;
                }
            }
        }

        //execute
        results = Database.query(query);
        return results;
    }
    
    /**
    * @date 30/01/2019
    * @description Vérifie si les opportunités sont associés à des team members
    * *****/
    @AuraEnabled
    public static List<SearchComponentOptionsWrapper> getPickValues(String objectName, String fieldName, String firstVal) {
        List<SearchComponentOptionsWrapper> options = new List<SearchComponentOptionsWrapper>(); //Nouvelle liste pour toutes les options picklist
        
        if (firstVal != null) { //Si une valeur est donnée 
            options.add(new SearchComponentOptionsWrapper(firstVal, firstVal)); //Ajout de la première option
        }
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.sObjectType sobject_type = schemaMap.get(objectName); // Récupération de l'objet
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //Decription de l'objet
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //Recupèration une map des champs de l'objet
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); //Récupération de la liste des valeurs du champ picklist de l'objet
        
        for (Schema.PicklistEntry a : pick_list_values) { //Pour toutes les valeurs de la liste
            if(a.getValue() != 'unknown' && a.getValue() != 'Other' )         
                options.add(new SearchComponentOptionsWrapper(a.getValue(), a.getLabel())); //Ajout de la valeur et du libellé dans la liste finale
        }
        
        return options; //retourne la liste
    }
}