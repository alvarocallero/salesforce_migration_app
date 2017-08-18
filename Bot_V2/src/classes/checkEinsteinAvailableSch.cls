global class checkEinsteinAvailableSch implements Schedulable {
    
    global void execute(SchedulableContext SC) {       
        checkEinsteinAvailable cEA = new checkEinsteinAvailable();
        database.executeBatch(cEA);
    }
    
    
}