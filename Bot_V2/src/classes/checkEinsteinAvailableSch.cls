global class checkEinsteinAvailableSch implements Schedulable {
    
    global void execute(SchedulableContext SC) {       
        checkEinsteinAvailable cEA = new checkEinsteinAvailable();
        System.schedule('Hourly', '0 0 * * * ?', new checkEinsteinAvailableSch() ); 
        database.executeBatch(cEA);
    }
    
    
}