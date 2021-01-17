public with sharing class FileUploadController {
    public Lead lead{get;set;}
    public Attachment attachment1{get;set;}
    
    public FileUploadController(ApexPages.StandardController controller) {
        this.lead = (Lead)controller.getrecord();
        attachment1 = new Attachment();
    }
    
    
    public PageReference upload() {
        Savepoint sp = Database.setSavepoint();
        lead.LeadSource='Réseau';
        try{
            insert(lead);
            if (attachment1.Name!=null){
                attachment1.ParentId = lead.Id; // the record the file is attached to
                insert attachment1;
            }
        }
        
        catch (DMLException e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Votre formulaire n\'a pas pu être envoyé. Veuillez réessayer'));
            //return null;
        } finally {
            attachment1 = new Attachment(); 
        }
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Votre formulaire a bien été envoyé à la VAD'));
        return null;
    }
        
}