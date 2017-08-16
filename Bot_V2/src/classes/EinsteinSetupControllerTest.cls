@isTest
public class EinsteinSetupControllerTest {
	
    static testmethod void testControllerErrors() {
        
        List<Einstein_Keyword__c> keywords = new List<Einstein_Keyword__c>();
        for(Integer i=0; i<2; i++) {
            keywords.add( new Einstein_Keyword__c( Name = 'TEST KEYWORD ' + String.valueOf(i+1),
                                                   Uploaded_to_Einstein__c = false,
                                                   Einstein_Upload_Status__c = EinsteinUtils.UPLOAD_STATUS_NOT_UPLOADED
                                                 ) 
                        );
        }
        insert keywords;
        
        List<Einstein_Data_Message__c> messages = new List<Einstein_Data_Message__c>();
        for (Einstein_Keyword__c keyword: keywords) {
            for(Integer i=0; i<2; i++) {
        		messages.add( new Einstein_Data_Message__c( Einstein_Keyword__c = keyword.Id,
                                                 			Message__c = 'TEST MESSAGE ' + String.valueOf(i+1),
                                                 			Uploaded_to_Einstein__c = false,
                                                   			Einstein_Upload_Status__c = EinsteinUtils.UPLOAD_STATUS_NOT_UPLOADED ) );
            }
        }
        insert messages;
        
        PageReference pageRef = Page.EinsteinSetup;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        
        EinsteinSetupController controller = new EinsteinSetupController();
        
        controller.enableEinstein();
        Boolean enableEinsteinError = controller.toastErrorMessage != null;
        
        controller.uploadMessages();
		Boolean uploadMessagesError = controller.toastErrorMessage != null;
        
        Test.stopTest();
        
        System.assertEquals(true, enableEinsteinError, 'enableEinstein() should have failed');
        System.assertEquals(true, uploadMessagesError, 'uploadMessages() should have failed');
    }
    
    
    static testmethod void testControllerSuccess() {
        
        List<Einstein_Keyword__c> keywords = new List<Einstein_Keyword__c>();
        for(Integer i=0; i<3; i++) {
            keywords.add( new Einstein_Keyword__c( Name = 'TEST KEYWORD ' + String.valueOf(i+1),
                                                   Uploaded_to_Einstein__c = false ) );
        }
        insert keywords;
        
        List<Einstein_Data_Message__c> messages = new List<Einstein_Data_Message__c>();
        for (Einstein_Keyword__c keyword: keywords) {
            for(Integer i=0; i<5; i++) {
        		messages.add( new Einstein_Data_Message__c( Einstein_Keyword__c = keyword.Id,
                                                 			Message__c = 'TEST MESSAGE ' + String.valueOf(i+1),
                                                 			Uploaded_to_Einstein__c = false ) );
            }
        }
        insert messages;
        
        PageReference pageRef = Page.EinsteinSetup;
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        
        EinsteinSetupController controller = new EinsteinSetupController();
        
        controller.enableEinstein();
        Boolean enableEinsteinNoError = controller.toastErrorMessage == null;
        
        controller.disableEinstein();
        Boolean disableEinsteinNoError = controller.toastErrorMessage == null;
        
        controller.uploadMessages();
        Boolean uploadMessagesNoError = controller.toastErrorMessage == null;
        Boolean uploadMessagesSuccess = controller.toastSuccessMessage != null;
        
        Test.stopTest();
        
        System.assertEquals(true, enableEinsteinNoError, 'enableEinstein() should not have failed');
        System.assertEquals(true, disableEinsteinNoError, 'disableEinstein() should not have failed');
        System.assertEquals(true, uploadMessagesNoError, 'uploadMessages() should not have failed');
        System.assertEquals(true, uploadMessagesSuccess, 'uploadMessages() should have returned success message');
        
    }

}