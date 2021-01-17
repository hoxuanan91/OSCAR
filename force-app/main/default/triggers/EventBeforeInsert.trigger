trigger EventBeforeInsert on Event (Before insert) {    
  if(PAD.canTrigger('EventBeforeInsert')){ 
      AP01Event.UpdateProjetAssocie(Trigger.new); 
  }
}