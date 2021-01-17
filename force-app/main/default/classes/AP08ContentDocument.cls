public class AP08ContentDocument {
    public static void UpdateDocumentAssocieContentDocument(Map<Id,ContentDocument> Cd){
        //Mise à jour de l'objet custom lié au document Content
     DocumentAssocie__c[] DocumentAssocie = [SELECT id, NomDuFichierCharge__c, LienDuDocument__c
                                FROM DocumentAssocie__c 
                                where LienDuDocument__c in:cd.keySet() ];
        for(DocumentAssocie__c d:DocumentAssocie){
            d.NomDuFichierCharge__c = cd.get(d.LienDuDocument__c).Title;
        }
        system.debug('keyset' + cd);
        system.debug('DocumentAssocie' + DocumentAssocie);
        update DocumentAssocie;

 }
}