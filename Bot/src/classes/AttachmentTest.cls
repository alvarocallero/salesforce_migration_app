@IsTest
public class AttachmentTest {
	
    @IsTest
    public static void testGetAttachmentDetails(){
        BotResponse response = BotController.submitWithAttachment('Message', null, 'url', 'fileName.png', 'content');
        
        UserBotMessage__c message = [Select Id, ContentDocumentId__c, Message__c From UserBotMessage__c Limit 1];
        String messageId = message.id;
        AttachmentController.AttachmentDetails details = AttachmentController.attachmentDetails(messageId);
        
        System.assert(details != null);
        System.assert(details.contentDocumentId != '');
        
    }
    
    @IsTest
    public static void testGetAttachmentDetailsIncorrectId(){
        BotResponse response = BotController.submitWithAttachment('Message', null, 'url', 'fileName.png', 'content');
        
        UserBotMessage__c message = [Select Id, ContentDocumentId__c, Message__c From UserBotMessage__c Limit 1];
        ContentVersion ctv = [Select id from ContentVersion Limit 1];
        
        String messageId = ctv.Id;
        AttachmentController.AttachmentDetails details = AttachmentController.attachmentDetails(messageId);
        
        System.assert(details == null);
    }
}