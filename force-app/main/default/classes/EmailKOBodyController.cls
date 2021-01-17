public class EmailKOBodyController {

    public String oppId {get;set{
        oppId = value;
        init();
        
    }}
    public String emailMode {get;set{
        emailMode = value;
        
        
    }}
    private boolean dataIsloaded = false;
    public String TypeDocument2 {get;set;}
    public String TypeDocument3 {get;set;}
    public String TypeDocument4 {get;set;}
    public String TypeDocument5 {get;set;}
    public String TypeDocument6 {get;set;}

    public String TypeDocument8 {get;set;}
    public String TypeDocument9 {get;set;}
    public String TypeDocument10 {get;set;}
    public String TypeDocument11 {get;set;}
    
    
    private void init() {
        List<ControleMetier__c> documentList = [SELECT TypeDocument__c, IntituleControleEmail__c, CodeControle__c, IntituleControle__c
                                                from  ControleMetier__c where  Forcage__c = false and Archive__c = false 
                                             and RecordType.DeveloperName = 'CBMControleMetier' and ProjetAssocie__c != null and Statut__c = '3' 
                                                and (IntituleControleEmail__c != null or IntituleControle__c != null)
                                             and Bloquant__c = '1' and ProjetAssocie__c =:oppId]; 
        TypeDocument2 = TypeDocument3 = TypeDocument4= TypeDocument5 = TypeDocument6 = TypeDocument8 = TypeDocument9 = TypeDocument10 = TypeDocument11 = '';
        for(ControleMetier__c item : documentList) {
            String resultLabel = (item.IntituleControleEmail__c != null ? item.IntituleControleEmail__c : item.IntituleControle__c);
            if (item.TypeDocument__c == '2' && !TypeDocument2.contains(resultLabel)) {
                TypeDocument2 += ' / ' + resultLabel;
            }
            
            if (item.TypeDocument__c == '3' && !TypeDocument3.contains(resultLabel)) {
                TypeDocument3 += ' / ' + resultLabel;
            }
            
            if (item.TypeDocument__c == '4' && !TypeDocument4.contains(resultLabel)) {
                TypeDocument4 += ' / '+ resultLabel;
            }
            
            if (item.TypeDocument__c == '5' && !TypeDocument5.contains(resultLabel)) {
                TypeDocument5 += ' / ' + resultLabel;
            }
            
            if (item.TypeDocument__c == '6' && !TypeDocument6.contains(resultLabel)) {
                TypeDocument6 += ' / ' + resultLabel;
            }
            
            if (item.TypeDocument__c == '8' && !TypeDocument8.contains(resultLabel)) {
                TypeDocument8 += '/' + resultLabel;
            }
            
            if (item.TypeDocument__c == '9' && !TypeDocument9.contains(resultLabel)) {
                TypeDocument9 += '/' + resultLabel;
            }
            
            if (item.TypeDocument__c == '10' && !TypeDocument10.contains(resultLabel)) {
                TypeDocument10 += '/' + resultLabel;
            }
            
            if (item.TypeDocument__c == '11' && !TypeDocument11.contains(resultLabel)) {
                TypeDocument11 += '/' + resultLabel;
            }
            

        }
    }

}