@isTest
public class checkEinsteinAvailableTEST {
    
    @testSetup 
    static void methodName() {
        
        
        
        List<Einstein_Keyword__c> keywords = new List<Einstein_Keyword__c>();
        List<Known_Issue__c> knownIssues = new List<Known_Issue__c>();        
        List<Einstein_Data_Message__c> messages = new List<Einstein_Data_Message__c>();
        
        for(Integer i=0; i<3; i++) {
            Einstein_Keyword__c keyword = new Einstein_Keyword__c(
                Name = 'TEST KEYWORD ' + String.valueOf(i+1),
                Einstein_Upload_Status__c = EinsteinUtils.UPLOAD_STATUS_NOT_UPLOADED
            );
            keywords.add(keyword);
        }      
        insert keywords;
        
        for (Einstein_Keyword__c keyword: keywords) {
            // Create Known Issue
            knownIssues.add(new Known_Issue__c(
                Einstein_Keyword__c = keyword.Id,
                Status__c = EinsteinUtils.KNOWN_ISSUE_NEW,
                Message__c = 'Problem with ' + keyword.Name
            ));            
            for(Integer i=0; i<5; i++) {
                messages.add(new Einstein_Data_Message__c(
                    Einstein_Keyword__c = keyword.Id,
                    Message__c = 'TEST MESSAGE ' + String.valueOf(i+1),
                    Einstein_Upload_Status__c = EinsteinUtils.UPLOAD_STATUS_NOT_UPLOADED
                ));
            }
        }
        insert knownIssues;
        insert messages;
        
        
        set<ID> ids = new set<ID>();
        for(Einstein_Keyword__c i: keywords){
            
            ids.add(i.Id);
        }
       // EinsteinUtils.uploadMessagesToEinstein(ids);
       // EinsteinUtils.setEinsteinDatasetId(1009954);
       // EinsteinUtils.setEinsteinModelId('IKAJAIQPM5IG7E5CDI6WMKK6NI');
        
    }
    
    static testmethod void testEinsteinAvailable(){
        boolean before = EinsteinUtils.getEinsteinEnabled();    
        Test.startTest();
        checkEinsteinAvailable cEA = new checkEinsteinAvailable();
        Database.executeBatch(cEA);     
        Test.stopTest();
        boolean after = EinsteinUtils.getEinsteinEnabled();
        system.assertEquals(after, before);
    }
    
}