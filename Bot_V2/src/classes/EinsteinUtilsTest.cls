@isTest
public class EinsteinUtilsTest {
	
    static testmethod void testEinsteinEnabled() {
        
        Test.startTest();
        
        Boolean einsteinDisabled = EinsteinUtils.getEinsteinEnabled();
        EinsteinUtils.setEinsteinEnabled(true);
        Boolean einsteinEnabled = EinsteinUtils.getEinsteinEnabled();
        
        Test.stopTest();
        
        System.assertEquals(false, einsteinDisabled, 'Einstein should start disabled');
        System.assertEquals(true, einsteinEnabled, 'Einstein should have been enabled');
    }    
    
    static testmethod void testCreateMessage() {
        
        Einstein_Keyword__c keywordTest = new Einstein_Keyword__c(Name = 'TEST');
        insert keywordTest;
        
        Test.startTest();
        
        Id messageUndefinedId = EinsteinUtils.createMessage(null, 'TESTABC');
        Id messageDefinedId = EinsteinUtils.createMessage(keywordTest.Id, 'TEST123');
        Id undefinedKeywordId = EinsteinUtils.getUndefinedKeywordId();
        
        Test.stopTest();
		
        List<Einstein_Data_Message__c> messages = [ SELECT Id, Einstein_Keyword__c FROM Einstein_Data_Message__c WHERE Id = :messageUndefinedId OR Id = :messageDefinedId ORDER BY CreatedDate ];
        System.assertEquals(2, messages.size(), 'Two messages should have been created');
        System.assertEquals(undefinedKeywordId, messages[0].Einstein_Keyword__c, 'Message should be assigned to undefined keyword');
        System.assertEquals(keywordTest.Id, messages[1].Einstein_Keyword__c, 'Message should be assigned to test keyword');
    }
    
        
}