/*************************************************************************************
* @date 23/05/2019
* @description Class pour les composants de filtres de recherche
* Class Name - SearchComponentObject
*************************************************************************************/
public class SearchComponentObject {
    //Le nom API du champ
    public String field { get; set; }
    //La valeur à chercher
    public String value { get; set; }
    //Un placeholder
    public String placeholder { get; set; }
    //Le type de champ: input, picklist, multipicklist
    public String fieldType { get; set; }
    //La liste des options
    public List<SearchComponentOptionsWrapper> options { get; set; }
}