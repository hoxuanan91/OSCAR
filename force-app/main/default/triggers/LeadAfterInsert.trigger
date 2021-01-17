trigger LeadAfterInsert on Lead (after insert) {
    if (PAD.canTrigger('LLD_LeadConversion')){
    
        /* MON EXPERT TRIGGER INSERT LEAD - START */
        
        /* MON EXPERT TRIGGER INSERT LEAD - END */
    }
}