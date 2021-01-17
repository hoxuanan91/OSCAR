trigger EventAfterInsert on Event (After insert) {
  if(PAD.canTrigger('EventAfterInsert')){ 
      
      AP01Event.updateDates(Trigger.new);
      
  }
}