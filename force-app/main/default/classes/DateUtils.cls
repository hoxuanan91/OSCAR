public class DateUtils {
    
   public static final BusinessHours bh = [SELECT Id,MondayEndTime, MondayStartTime 
                                       FROM BusinessHours 
                                       where name=:Label.CL08_PlageHoraireRepere];
    /********************************************************************************
    * @description : calcul le prochain jour ouvré. Exclue les weeke end et jour ferie
    * @param : Date/heure de debut
    * @return: Prochaon jour ouvré type Datetime
    * @createdBy: RWA
    * @createdDate : 31/01/2020
    **********************************************************************************/
    public static Datetime addBusinessDays(Datetime pointer, Integer days)
    {
        pointer = BusinessHours.nextStartDate(bh.Id, pointer);
        // make sure you're starting at a Datetime within BusinessHours

        for (Integer elapsed = 0; elapsed < days; elapsed++)
        {
            pointer = pointer.addDays(1);
            if (!BusinessHours.isWithin(bh.Id, pointer))
                pointer = BusinessHours.nextStartDate(bh.Id, pointer);
        }
        return pointer;
    }
    
    /********************************************************************************
    * @description : calcul le prochain jour ouvré. Exclue les weeke end et jour ferie
    * @param : Date/heure de debut
    * @return: Prochaon jour ouvré type Datetime
    * @createdBy: RWA
    * @createdDate : 31/01/2020
    **********************************************************************************/
 /*   public static Datetime getNextBusinessDays(Datetime startDate){
        Datetime nextBusinessDay=startDate.addDays(1);
        Boolean isWithin= BusinessHours.isWithin(bh.id,nextBusinessDay);
        while(!isWithin){
            nextBusinessDay=nextBusinessDay.addDays(1);
            isWithin= BusinessHours.isWithin(bh.id,nextBusinessDay);
        }
        
        system.debug('@@ startDate ' +startDate);
        system.debug('@@ nextBusinessDay ' +nextBusinessDay);
        system.debug('@@ isWithin ' +isWithin);
        return nextBusinessDay;
    }
    */
    /********************************************************************************
    * @description : calcul nombre d'heure entre deux dates en tenant compte des 
    * heures d'ouverture 9H et 18H.Exclue les week end et jour ferie
    * @param : Date/heure de debut
    * @return: Prochain jour ouvré type Datetime
    * @createdBy: RWA
    * @createdDate : 31/01/2020
    **********************************************************************************/
   public static Decimal getHoursBetweenWorkingDays(Datetime startDate,Datetime endDate){
        system.debug('@@getHoursBetweenWorkingDays ');
        system.debug('@@startDate '+startDate);
        system.debug('@@endDate '+endDate);
       
        Decimal result=0;
        if(startDate==null || endDate==null){
            return null;
        }
        if(startDate>endDate){
            return result;
        }
        Decimal nbHoursDebut=BusinessHours.diff(bh.id,startDate,endDate);
        system.debug('@@ diff en ms ' +nbHoursDebut);
        result =nbHoursDebut/(1000*60*60);
        system.debug('@@ diff en heure ' +result);
        return result;
    }    
    
}