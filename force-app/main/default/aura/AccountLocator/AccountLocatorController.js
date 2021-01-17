({
    /**
    * @date 23/05/2019
    * @description Initialise le component
    * *****/
	onInit : function(component, event, helper) {
        var datatableCols = new Array();

        //Récupère les valeurs de la picklist et fixe le champ filtre : Perim_liv_Sans_Frais_Conces__c
        helper.getPicklistOptions(component, 'Account', 'Perim_liv_Sans_Frais_Conces__c', 'Aucune', function(result){
            var searchComponentObjectArray = component.get('v.filtersArray');
            
            if(searchComponentObjectArray == ""){
                searchComponentObjectArray = new Array();
            }
            
            searchComponentObjectArray.push({'field': 'Perim_liv_Sans_Frais_Conces__c', 'value' : '', 'placeholder': 'Département livraison', 'fieldType': 'multipicklist','options': result});
            component.set('v.filtersArray', searchComponentObjectArray);
        });
        
        //Récupère les valeurs de la picklist et fixe le champ filtre : Marque_Concess__c
        helper.getPicklistOptions(component, 'Account', 'Marque_Concess__c', 'Aucune', function(result){
            var searchComponentObjectArray = component.get('v.filtersArray');
            
            if(searchComponentObjectArray == ""){
                searchComponentObjectArray = new Array();
            }
            
            searchComponentObjectArray.push({'field': 'Marque_Concess__c', 'value' : '', 'placeholder': 'Marque', 'fieldType': 'picklist', 'options': result});
            component.set('v.filtersArray', searchComponentObjectArray);
        });
 
        //Les colonnes du tableas
        datatableCols.push({'label': 'Nom', 'fieldName': 'Name', 'type': 'text'});    
        datatableCols.push({'label': 'Ville', 'fieldName': 'BillingCity', 'type': 'text'});       
        datatableCols.push({'label': 'Marque', 'fieldName': 'Marque_Concess__c', 'type': 'text'});       
        datatableCols.push({'label': 'Téléphone', 'fieldName': 'Phone', 'type': 'phone'});  
        datatableCols.push({'label': 'Email', 'fieldName': 'Email__c', 'type': 'email'});
        datatableCols.push({'label': 'Partenaire', 'fieldName': 'Concessionnaire_Part__c', 'type': 'boolean'});  
        datatableCols.push({'label': 'Action', 'type': 'button', 'typeAttributes': {'label': 'Détails', 'name': 'view_details'}});  
        
        //Set les données
        component.set('v.object', 'Account');
        component.set('v.datatableTitle', 'Concessionnaires');
        component.set('v.datatableIconName', 'standard:account');
        component.set('v.fieldsToSearch', 'Id, Name, BillingCity, BillingPostalCode, BillingStreet, Marque_Concess__c, Phone, Email__c, Concessionnaire_Part__c, Perim_liv_Sans_Frais_Conces__c');
        component.set('v.datatableCols', datatableCols);
	},
    
    /**
    * @date 23/05/2019
    * @description Evenement lors d'un changement des resultats de la recherche
    * *****/
    handleResultChange : function (component, event, helper) {
        var markers = helper.formatResultToMarker(component.get("v.results"));

        component.set('v.mapMarkers', markers);
    }
})