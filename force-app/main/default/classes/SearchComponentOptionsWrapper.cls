/*************************************************************************************
* @description
* Class Name - SearchComponentOptionsWrapper
* Function - Classe pour les composants d'options de recherche
*************************************************************************************/
public class SearchComponentOptionsWrapper {
    //la valeur
    @AuraEnabled
    public String value { get; set; }
    
    //le libellé
    @AuraEnabled
    public String label { get; set; }
    
    //Constructeur
    public SearchComponentOptionsWrapper() {
        this.label = '';
        this.value = '';
    }
    
    //Constructeur
    public SearchComponentOptionsWrapper(String lab, String val) {
        this.label = lab;
        this.value = val;
    }
}