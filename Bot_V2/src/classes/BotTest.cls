@isTest
public class BotTest {

    /*static testMethod void testBotController() {
		Bot_Command__c bc = new Bot_Command__c(Sample_Utterance__c='help lightning', apex_class__c='HandlerHelpTopic', pattern__c='help (.*)');
        insert bc;
          //BotHandler handler = new HandlerAddTwoNumbers();
        BotResponse responseSession = handler.handle('', null, null);
        Map<String, String> session = responseSession.session;
        BotResponse response = BotController.submit('help lightning', session, 'currentUrl');

        System.assert(response.messages[0].items.size() > 0);
    }*/

    static testMethod void testHello() {
        BotHandler handler = new HandlerHello();
        BotResponse response = handler.handle('', null, null);
        System.assert(response.messages[0].messageText == 'Hi there!');
    }


	static testMethod void testHelp() {
		Bot_Command__c bc = new Bot_Command__c(Sample_Utterance__c='Hello', apex_class__c='HelloHandler', pattern__c='Hello');
        insert bc;
        BotHandler handler = new HandlerHelp();
        BotResponse response = handler.handle('', null, null);
        System.assert(response.messages[0].items.size() == 1);
    }


    static testMethod void testUploadFile(){
        BotResponse response = BotController.submitWithAttachment('Message', null, 'url', 'fileName', 'content');
        System.assert(response.messages[0].messageText == 'Your feedback was sent to the administrator. Thank you!');
    }


    static testMethod void testUpload(){
        BotResponse response = BotController.upload('fileName', 'content');
        System.assert(response.messages[0].messageText == 'Your file was uploaded successfully');
    }

}
