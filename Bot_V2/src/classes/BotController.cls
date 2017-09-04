public with sharing class BotController {

    class HandlerMapping {

        public String handlerClassName;
        public Pattern utterancePattern;

        public HandlerMapping(String handlerClassName, String patternStr) {
            this.handlerClassName = handlerClassName;
            this.utterancePattern = Pattern.compile(patternStr);
        }

    }

    @AuraEnabled
    public static List<String> userInfo(){
        Id userId = UserInfo.getUserId();
        List<String> infoList = new List<String>();
        User returnUser = [SELECT Name, SmallPhotoUrl FROM User WHERE Id = :userId];
        infoList.add(returnUser.SmallPhotoUrl);
        String name = returnUser.Name.split(' ')[0];
        infoList.add(name);
        infoList.add('Hi ' + name + ', I\'m Leah! My job is to help you address any problems you might have with Lightning Experience.' +
                     ' Just send feedback starting with the word <strong>\"Error\"</strong> and I\'ll try to find your problem. ' + '<br/>' + 'I may provide some helpful information if you start your sentence with the word '+
                     '<strong>\"Train\"</strong>.');
        infoList.add('So, how can I help you today?');
        infoList.add(userId);
        return infoList;
    }

    static List<HandlerMapping> handlerMappings;

    static {
        List<Bot_Command__c> commands = [SELECT Apex_Class__c, Pattern__c FROM Bot_Command__c WHERE Active__c = True ORDER BY Name];
        System.debug('COMMANDS--> '+commands);
        List<HandlerMapping> mappings = new List<HandlerMapping>();
        for (Bot_Command__c command : commands) {
            mappings.add(new HandlerMapping(command.Apex_class__c, command.Pattern__c));
        }
        handlerMappings = mappings;
    }

    @AuraEnabled
    public static BotResponse upload(String fileName, String content) {
        try {
            ContentVersion v = new ContentVersion();
            v.versionData = EncodingUtil.base64Decode(content);
            v.title = fileName;
            v.pathOnClient = fileName;
            insert v;
            ContentDocument doc = [SELECT Id FROM ContentDocument where LatestPublishedVersionId = :v.Id];
            List<BotRecord> records = new List<BotRecord>();
            List<BotField> fields = new List<BotField>();
            fields.add(new BotField('Id', v.Id, '#/sObject/ContentDocument/' + doc.Id));
            fields.add(new BotField('Name', v.title));
            records.add(new BotRecord(fields));
            return new BotResponse(new BotMessage('', 'Your file was uploaded successfully', records));
        } catch (Exception e) {
            return new BotResponse(new BotMessage('', 'An error occured while uploading the file'));
        }
    }
    
    @AuraEnabled
    public static BotResponse addNewKnownIssue(String dataMessageId, String currentUrl, String content, String fileName){
        ContentVersion contentVersion = null;
            
        if(!String.isEmpty(content) && !String.isEmpty(fileName)){
                contentVersion = uploadFile(fileName, content);
        }
        
        Known_Issue__c newKnownIssue = KnownIssuesUtils.createKnownIssue(dataMessageId, currentUrl, contentVersion);
        
        List<BotItem> botItemsList = new List<BotItem>();
        String pageUrl = KnownIssueDetailController.getPageURL(newKnownIssue.Id, dataMessageId);
        BotItem botItem = new BotItem(newKnownIssue.Message_Summary__c, pageUrl);
        botItemsList.add(botItem);
        List<BotMessageButton> buttons = new List<BotMessageButton>();
                    BotMessageButton btnSubscribe = new BotMessageButton('Subscribe', 'subscribe');
                    buttons.add(btnSubscribe);
        
        return new BotResponse(new BotMessage('', 'Sorry, I could not find what you were looking for. I created a new Issue with'+ 
                                              ' the feedback you provided. You can subscribe to receive notifications once we fix this problem.', 
                                              botItemsList, buttons), dataMessageId, newKnownIssue.Id);
    }
    
    @AuraEnabled
    public static BotResponse subscribeUserToIssue(Id knownIssueId, Id userId){
        try{
            List<Id> users = new List<Id>();
            users.add(userId);
            KnownIssuesUtils.subscribeUsersToIssue(knownIssueId, users);
            return new BotResponse(new BotMessage('', 'Done! You will receive a notification once this issue is fixed. Thanks for your help!'));
            
        } catch (Exception e) {
            System.debug(e);
            return new BotResponse(new BotMessage('', 'Oops, something went wrong...I could not subscribe you to this issue...'));
        }
    }

    @AuraEnabled
    public static BotResponse submit(String utterance, Map<String, String> session, String currentUrl,
                                     String currentUser, String responseText) {
		
        try {
            
            utterance = utterance.toLowerCase();
            
            if(EinsteinUtils.getEinsteinEnabled() == true){
            	if(utterance.substringBefore(' ') == 'error'){
            		utterance=utterance.removeStart('error');
            		
    				Map<String, String> params = new Map<String, String>();
    				params.put('modelId', EinsteinUtils.getEinsteinModelId());
    				params.put('document', utterance);
    				params.put('numResults', '5');
                    String result = '';
                    if(!Test.isRunningTest()){
                        result = LanguageController.predict(params);
                    }else{
                        result='{"probabilities": [{"label": "ekwName1","probability": 0.9904295},{"label": "ekwName2","probability": 0.009345241},{"label": "ekwName3","probability": 0.00022528473}]}';
                    }
                    
                    
    				
    				Map<String, Object> jsonResult = (Map<String, Object>)JSON.deserializeUntyped(result);
    				
    				List<Known_Issue__c> knownIssuesFound = new List<Known_Issue__c>();
    				
    				List<Object> predictions = (List<Object>)jsonResult.get('probabilities');
    				
    				if(predictions != null){
    					for(Object pred : predictions){
    						try{
    						Map<String, Object> objects = (Map<String, Object>) pred;
    						
                            String einstainKeyWord = (String) objects.get('label');
                            
                            List<Einstein_Keyword__c> lstEinsteinKeyword = [SELECT Id FROM Einstein_Keyword__c WHERE Name = :einstainKeyWord LIMIT 1];
                            
    						List<Known_Issue__c> ki = [SELECT Id, Message__c, Message_Summary__c FROM Known_Issue__c WHERE Einstein_Keyword__c = :lstEinsteinKeyword.get(0).Id];
    						
    						knownIssuesFound.add(ki.get(0));
    						
    						 
    						}catch(Exception e){
    							System.debug(e.getCause());
                                System.debug(e.getLineNumber());
    						}
    						
    					}
    					
    					
    					try{
                    	List<BotItem> botItemsList = new List<BotItem>();
                    	
                    	for(Known_Issue__c ki : knownIssuesFound){
                        	String pageUrl = KnownIssueDetailController.getPageURL(ki.Id, '');
                        	BotItem botItem = new BotItem(ki.Message_Summary__c, pageUrl);
                        	botItemsList.add(botItem);
                    	}
                    	
                    	List<BotMessageButton> buttons = new List<BotMessageButton>();
                    	BotMessageButton btnHelpful = new BotMessageButton('This is helpful!', 'helpful');
                    	BotMessageButton btnUseless = new BotMessageButton('I was not looking for this', 'useless');
                    	buttons.add(btnHelpful);
                    	buttons.add(btnUseless);
                    	
                        return new BotResponse(new BotMessage('', 'I talked to Einstein and I found this...', botItemsList, buttons), null, null);
    					}catch(Exception e){
    						System.debug('ERROR SHOW LINE--> ' +e.getLineNumber());
    					}
    				
                    }else{
                    	return new BotResponse(new BotMessage('', 'Sorry, I have not found anything related to your problem...'));
                    }
            		
            	}	 
                
                return new BotResponse(new BotMessage('', 'Sorry, I have not found anything related to your problem...'));
            }
            else{
            	if(utterance.substringBefore(' ') == 'error'){
                //Einstein Not Enabled
                utterance = utterance.removeStart('error');
                Id dataMessageId = EinsteinUtils.createMessage(null, utterance);
                Set<Known_Issue__c> knownIssuesFound = findKnownIssuesByUtterance(utterance);

                if(knownIssuesFound.size()>0){
                    List<BotItem> botItemsList = new List<BotItem>();
                    for(Known_Issue__c ki : knownIssuesFound){
                        String pageUrl = KnownIssueDetailController.getPageURL(ki.Id, dataMessageId);
                        BotItem botItem = new BotItem(ki.Message_Summary__c, pageUrl);
                        botItemsList.add(botItem);
                    }
                    List<BotMessageButton> buttons = new List<BotMessageButton>();
                    BotMessageButton btnHelpful = new BotMessageButton('This is helpful!', 'helpful');
                    BotMessageButton btnUseless = new BotMessageButton('I was not looking for this', 'useless');
                    buttons.add(btnHelpful);
                    buttons.add(btnUseless);
                    return new BotResponse(new BotMessage('', 'This is what I found...', botItemsList, buttons), dataMessageId, null);
                }else{
                    return addNewKnownIssue(dataMessageId, currentUrl, '', '');
                    //return new BotResponse(new BotMessage('', 'Sorry, I have not found anything related to your problem...'));
                }

            }else if(utterance.substringBefore(' ') == 'train'){
                
               utterance = utterance.removeStart('train');
               
               String searchCriteria = 'https://developer.salesforce.com/search?q=' + utterance;
              
               List<BotItem> botItemsList = new List<BotItem>();
               
               BotItem botItem = new BotItem(utterance, searchCriteria);
               botItemsList.add(botItem);
               
               List<BotMessageButton> buttons = new List<BotMessageButton>();
                    BotMessageButton btnHelpful = new BotMessageButton('This is helpful!', 'trainHelpful');
                    BotMessageButton btnUseless = new BotMessageButton('I was not looking for this', 'trainUseless');
                    buttons.add(btnHelpful);
                    buttons.add(btnUseless);
               
               return new BotResponse(new BotMessage('', 'Click on the link to see what I found for you', botItemsList, buttons), null, null);
               
            }else{
             		for (HandlerMapping mapping : BotController.handlerMappings) {
                		Matcher utteranceMatcher = mapping.utterancePattern.matcher(utterance);
                		if (utteranceMatcher.matches()) {
                    		Type t = Type.forName('', mapping.handlerClassName);
                    		BotHandler h = (BotHandler)t.newInstance();
                    		List<String> params = new List<String>();
                    		for (Integer i=1; i<=utteranceMatcher.groupCount(); i=i+1) {
                        		params.add(utteranceMatcher.group(i).trim());
                    		}
                    		return h.handle(utterance, params, session);
                		}
            		}
            
            return new BotResponse(new BotMessage('Bot', 'I don\'t know how to answer that'));   
            	}
            }//end else einstein enabled
            

        } catch (Exception e) {
            System.debug(e);
            return new BotResponse(new BotMessage('', 'Oops, something went wrong...I could not read your feedback. Please try again.'));
        }

    }

    public static Set<Known_Issue__c> findKnownIssuesByUtterance (String errorMessageFromUser){

        Map<Integer, List<Known_Issue__c>> completeRankingOfMatchings = new Map<Integer,List<Known_Issue__c>>();

        List<Known_Issue__c> foundIssues = new List<Known_Issue__c>();

        List<Integer> orderedList = new List<Integer>();//holds the distance result numbers

        foundIssues = [SELECT Id, Message__c, Message_Summary__c FROM Known_Issue__c WHERE Status__c = 'New'];//see limit
        for(Known_Issue__c ki : foundIssues){
            Integer distance;
            if(!String.isEmpty(ki.Message_Summary__c)){
                distance = ki.Message_Summary__c.getLevenshteinDistance(errorMessageFromUser);
            }

            if(completeRankingOfMatchings.containsKey(distance)){
                List<Known_Issue__c> kiList = completeRankingOfMatchings.get(distance);
                kiList.add(ki);
                completeRankingOfMatchings.put(distance, kiList);
            }else{
                completeRankingOfMatchings.put(distance, new List<Known_Issue__c> {ki});
            }


            orderedList.add(distance);
        }

        Set<Known_Issue__c> topFiveMatchingIssues = new Set<Known_Issue__c>();

        orderedList.sort();
        Integer check = 0;
        for(Integer i : orderedList){

            if(check < 5){
                for(Known_Issue__c ki : completeRankingOfMatchings.get(i)){
                     topFiveMatchingIssues.add(ki);
                }
            }else{
                break;
            }
            check ++;
        }

        return topFiveMatchingIssues;
    }

    public static ContentVersion uploadFile(String fileName, String content){
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.versionData = EncodingUtil.base64Decode(content);
        contentVersion.title = fileName;
        contentVersion.pathOnClient = fileName;
        insert contentVersion;
        return contentVersion;
    }

    @AuraEnabled
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }

}