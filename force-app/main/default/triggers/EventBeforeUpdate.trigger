trigger EventBeforeUpdate on Event (before Update) {
  if(PAD.canTrigger('EventBeforeUpdate')){ 

       AP01Event.updateDates(Trigger.new); 
       AP01Event.UpdateProjetAssocie(Trigger.new); 

  }
}