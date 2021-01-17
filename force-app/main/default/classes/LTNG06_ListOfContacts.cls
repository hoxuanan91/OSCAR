public class LTNG06_ListOfContacts {

    @AuraEnabled
    public static DataWrapper doInit_APEX(String caseId){
        Id accId = [SELECT Id, AccountId FROM Case WHERE Id =: caseId].AccountId;

        Account acc = [SELECT Id, (SELECT Id, Name, Email, Correspondant_recouvrement__c, Phone, MobilePhone FROM Contacts WHERE Correspondant_recouvrement__c = true) FROM Account WHERE Id =:accId];

        System.debug(acc.Contacts);

        return new DataWrapper(acc.Contacts);

    }

    public class DataWrapper{
        @AuraEnabled public List<ContactWrapper> contsWPlimited;
        @AuraEnabled public List<ContactWrapper> contsWPunlimited;
        @AuraEnabled public Boolean moreThan3;
        
        public DataWrapper(List<Contact> conts){
            this.contsWPlimited = new List<ContactWrapper>();
            this.contsWPunlimited = new List<ContactWrapper>();


            if(conts.size() <= 3){
                for(Contact c : conts){
                    this.contsWPlimited.add(new ContactWrapper(c));
                }
                this.moreThan3 = false;
            }
            else{
                Integer i = 1;
                for(Contact c : conts){
                    if(i <= 3){
                        this.contsWPlimited.add(new ContactWrapper(c));
                        this.contsWPunlimited.add(new ContactWrapper(c));
                    }
                    else{
                        this.contsWPunlimited.add(new ContactWrapper(c));
                    }
                    i++;
                    System.debug(i);
                }
                this.moreThan3 = true;
            }
            
        }
    }

    public class ContactWrapper{
        @AuraEnabled public Contact cont;

        public ContactWrapper(Contact cont){
            this.cont = cont;
        }
    }

}