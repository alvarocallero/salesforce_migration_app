@isTest
public class BotTest {

    static testMethod void testHello() {
        BotHandler handler = new HandlerHello();
        BotResponse response = handler.handle('', null, null);
        System.assert(response.messages[0].messageText == 'Hi there!');
    }
    
    static testMethod void testGoodbye() {
        BotHandler handler = new HandlerGoodbye();
        BotResponse response = handler.handle('', null, null);
        System.assert(response.messages[0].messageText == 'Goodbye! See you later!');
    }
    
    static testMethod void testThanks() {
        BotHandler handler = new HandlerThanks();
        BotResponse response = handler.handle('', null, null);
        System.assert(response.messages[0].messageText == 'You are welcome! I am happy to help!');
    }

	static testMethod void testHelp() {
		
        BotHandler handler = new HandlerHelp();
        BotResponse response = handler.handle('', null, null);
        System.assert(!String.isEmpty(response.messages[0].messageText));
    }

    static testMethod void testUpload(){
        BotResponse response = BotController.upload('fileName', 'content');
        System.assert(response.messages[0].messageText == 'Your file was uploaded successfully');
    }
    
     static testMethod void testUserInfo(){
        List<String> userInfoList = BotController.userInfo();
        
        System.assert(userInfoList.size()>0);
    }
    
    static testMethod void testAddNewKnownIssue(){
        Einstein_Keyword__c ekw = new Einstein_Keyword__c();
        ekw.Name = 'ekwName';
        ekw.Einstein_Upload_Status__c = 'Uploaded';
        
        insert ekw;
        
        Id dataMessageId = EinsteinUtils.createMessage(ekw.Id, 'example message');
        
        BotResponse br = null;
        br = BotController.addNewKnownIssue(dataMessageId, 'currentUrl', 'content', 'fileName');
        
        System.assert(br!=null);      
        
    }
    
    static testMethod void testSubscribeUserToIssue(){
        Einstein_Keyword__c ekw = new Einstein_Keyword__c();
        ekw.Name = 'ekwName';
        ekw.Einstein_Upload_Status__c = 'Uploaded';
        
        insert ekw;
        
        Id dataMessageId = EinsteinUtils.createMessage(ekw.Id, 'example message');
        
        Known_Issue__c ki = null; 
        
        ContentVersion contentVersion = BotController.uploadFile('fileName', 'content');
        
        ki = KnownIssuesUtils.createKnownIssue(dataMessageId, 'currentUrl', contentVersion);
        
        BotResponse br = null; 
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='exampleEmailUser@toolkit.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='exampleUserxx@toolkit.com');
        
        insert u;
        br = BotController.subscribeUserToIssue(ki.Id, u.Id);
        
        System.assert(br!=null);
    }
    
    static testMethod void testSubmit(){
        
        for(Integer i = 0 ; i < 5; i++){
            Einstein_Keyword__c ekw = new Einstein_Keyword__c();
        	ekw.Name = 'ekwName' + i;
        	ekw.Einstein_Upload_Status__c = 'Uploaded';
        
       		insert ekw;
        
        	Id dataMessageId = EinsteinUtils.createMessage(ekw.Id, 'example message' + i);
        
        	Known_Issue__c ki = null; 
        
        	ContentVersion contentVersion = BotController.uploadFile('fileName'+i, 'content'+i);
            
        	ki = KnownIssuesUtils.createKnownIssue(dataMessageId, 'currentUrl'+i, contentVersion);
            
            ki.Einstein_Keyword__c = ekw.Id;
            
            upsert ki;
        }
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='exampleEmailUser@toolkit.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='exampleUserxx@toolkit.com');
        
        insert u;
        
        Map<String, String> session = new Map<String, String>();
        BotResponse br = null;
        
        br = BotController.submit('error example message1', session, 'currentUrl', u.Id, '');
        
        System.assert(br!=null);
       
        BotResponse abr = null;
        
        abr = BotController.submit('train example message1', session, 'currentUrl', u.Id, '');
        
        System.assert(abr!=null);
        
        EinsteinUtils.setEinsteinEnabled(true);
        
        BotResponse brEinEna = null;
        
        brEinEna = BotController.submit('error example message1', session, 'currentUrl', u.Id, '');
      
        System.assert(brEinEna != null);
                
       
    }
    
    static testMethod void testSubmitConversation(){
        Bot_Command__c bCommand = new Bot_Command__c();
        bCommand.Active__c = true; 
        bCommand.Apex_Class__c = 'HandlerHello';
        bCommand.Name ='hello handler';
        bCommand.Pattern__c = '^(hey|hi|hello|hello there|hi there|hey there|hey!|hi!|hello!|hello there!|hi there!|hey there!)';
        bCommand.Sample_Utterance__c = 'hello';
        
        insert bCommand;
        
        
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        	User u = new User(Alias = 'standt', Email='exampleEmailUser@toolkit.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='exampleUserxx@toolkit.com');
        
        insert u;
        
        Map<String, String> session = new Map<String, String>();
        
        BotResponse brStandardConversation = null;
        
        brStandardConversation = BotController.submit('hello', session, 'currentUrl', u.Id, '');
        
        System.assert(brStandardConversation!= null);
    }
    
    static testMethod void testGetUserInfo(){
        
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        	User u = new User(Alias = 'standt', Email='exampleEmailUser@toolkit.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='exampleUserxx@toolkit.com');
        
        insert u;
        
        String sessionId = '';
        
        System.runAs(u){
            sessionId = BotController.getSessionId();
            System.assert(!String.isEmpty(sessionId));
        }
    }
    
    static testMethod void testBotItemName(){
        BotItem bt = new BotItem('BotitemName');
        System.assert(bt.name == 'BotitemName');
    }
    
    static testMethod void testBotMessage(){
        
        List<BotItem> lstBt = new List<BotItem>();
        BotItem bt = new BotItem('BotItem');
        lstBt.add(bt);
        BotMessage bm = new BotMessage('test', 'test2', lstBt);
        List<BotMessageButton> bmb = new List<BotMessageButton>();
        bmb.add(new BotMessageButton('label', 'value'));
        BotMessage bm2 = new BotMessage('test1', 'test2', bmb);
        BotMessage bm3 = new BotMessage('test1', 'test2', 'test3');
        BotMessage bmessage = new BotMessage();
        System.assert(bm3.imageURL == 'test3');
    }
    
    static testMethod void testBotResponse(){
        BotResponse br = new BotResponse();
        
        List<BotItem> lstBt = new List<BotItem>();
        BotItem bt = new BotItem('BotItem');
        lstBt.add(bt);
        BotMessage bm = new BotMessage('test', 'test2', lstBt);
        List<BotMessage> lstBm = new List<BotMessage>();
        lstBm.add(bm);
        
        BotResponse br2 = new BotResponse(lstBm);
        Map<String, String> session = new Map<String, String>();
        BotResponse br3 = new BotResponse(lstBm, session);
        
        BotResponse br4 = new BotResponse(bm);
        
        
        
        Einstein_Keyword__c ekw = new Einstein_Keyword__c();
        ekw.Name = 'ekwName';
        ekw.Einstein_Upload_Status__c = 'Uploaded';
        
        insert ekw;
        
        Id dataMessageId = EinsteinUtils.createMessage(ekw.Id, 'example message');
        Known_Issue__c ki = null;
        ContentVersion contentVersion = BotController.uploadFile('fileName', 'content');
            
        	ki = KnownIssuesUtils.createKnownIssue(dataMessageId, 'currentUrl', contentVersion);
            
            ki.Einstein_Keyword__c = ekw.Id;
            
            upsert ki;        
        BotResponse br5 = new BotResponse(bm,dataMessageId, ki.Id);
        
        List<Known_Issue__c> lstKi = new List<Known_Issue__c>();
        lstKi.add(ki);
        
        BotResponse br6 = new BotResponse(bm, lstKi);
        
        BotResponse br7 = new BotResponse(bm, session);
        
        System.assert(br6.knownIssues.size() > 0);
        
    }
    
}