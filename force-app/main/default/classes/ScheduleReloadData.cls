global class ScheduleReloadData implements Schedulable,Database.AllowsCallouts {
    
	global void execute(SchedulableContext SC) {
       System.enqueueJob(new ScheduleReloadExecute());

    }
    
}