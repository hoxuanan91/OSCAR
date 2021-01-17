trigger ContentDocumentAfterUpdate on ContentDocument (after update) {
    if(PAD.canTrigger('ContentDocumentAfterUpdate')) {
        AP08ContentDocument.UpdateDocumentAssocieContentDocument(trigger.newMap);
    }
     
}