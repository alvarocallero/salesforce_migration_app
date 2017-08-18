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
                     ' Just send feedback starting with the word <strong>\"Error\"</strong> and I\'ll try to find out what\'s going on. ' + '<br/>' + 'I may provide some helpful information and tips if you start your sentence with the word '+
                     '<strong>\"Help\"</strong>.');
        infoList.add('So, how can I help you today?');
        infoList.add(userId);
        return infoList;
    }

    static List<HandlerMapping> handlerMappings;

    static {
        List<Bot_Command__c> commands = [SELECT apex_class__c, pattern__c FROM Bot_Command__c WHERE Active__c = True ORDER BY Name];
        System.debug(commands);
        List<HandlerMapping> mappings = new List<HandlerMapping>();
        for (Bot_Command__c command : commands) {
            mappings.add(new HandlerMapping(command.apex_class__c, command.pattern__c));
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
    public static BotResponse addNewKnownIssue(String dataMessageId, String currentUrl){
        
        Known_Issue__c newKnownIssue = KnownIssuesUtils.createKnownIssue(dataMessageId, currentUrl);
        
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
    public static BotResponse submit(String utterance, Map<String, String> session, String currentUrl, String currentUser) {
		//see flow for first time, when there are not any known issues
        try {

            utterance.toLowerCase();
            if(utterance.substringBefore(' ') == 'error'){
                //Einstein Not Enabled
                if(EinsteinUtils.getEinsteinEnabled() == false){
                    
                }
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
                    return addNewKnownIssue(dataMessageId, currentUrl);
                    //return new BotResponse(new BotMessage('', 'Sorry, I have not found anything related to your problem...'));
                }

            }
            else{
                //logUserMessage(utterance, currentUrl, null);
                return new BotResponse(new BotMessage('', 'Please, start your feedback with the word \"<strong>Error</strong>\". For example: \"<strong>Error</strong> update button not working.\"'));
            }

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

    @AuraEnabled
    public static BotResponse submitWithAttachment(String utterance, Map<String, String> session, String currentUrl, String fileName, String content) {

        try {
            ContentVersion contentVersion = uploadFile(fileName, content);
            logUserMessage(utterance, currentUrl, contentVersion);
            return new BotResponse(new BotMessage('', 'Your feedback was sent to the administrator. Thank you!'));
            if (session != null) {
                String nextCommand = session.get('nextCommand');
                if (nextCommand != null) {
                    Type t = Type.forName('', nextCommand);
                    BotHandler h = (BotHandler)t.newInstance();
                    return h.handle(utterance, null, session);
                }
            }
            return new BotResponse(new BotMessage('', 'Your feedback was sent to the administrator. Thank you!'));
        } catch (Exception e) {
            System.debug(e);
            return new BotResponse(new BotMessage('', 'Oops, something went wrong invoking that command'));
        }

    }

    private static void logUserMessage(String utterance, String currentUrl, ContentVersion ctv){
        User currentUser = [Select Id from User where Id=:userinfo.getuserId()];

        UserBotMessage__c ubm = new UserBotMessage__c();
        ubm.Message__c = utterance;
        ubm.SentFrom__c = currentUrl;
        ubm.Submitter__c = currentUser.id;

        if(ctv!=null){
            ContentDocument doc = [SELECT Id FROM ContentDocument where LatestPublishedVersionId = :ctv.Id];
            ubm.ContentDocumentId__c = doc.Id;
        }
        insert ubm;
    }

    private static ContentVersion uploadFile(String fileName, String content){
        System.debug('File content: ' + content);
        System.debug('File Name: ' + fileName);
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.versionData = EncodingUtil.base64Decode(content);
        contentVersion.title = fileName;
        contentVersion.pathOnClient = fileName;
        insert contentVersion;
        return contentVersion;
    }

    @AuraEnabled
    public static BotResponse submit(String utterance, Map<String, String> session, String word) {

        try {

            if (session != null) {
                String nextCommand = session.get('nextCommand');
                if (nextCommand != null) {
                    Type t = Type.forName('', nextCommand);
                    BotHandler h = (BotHandler)t.newInstance();
                    return h.handle(utterance, null, session);
                }
            }

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

            return new BotResponse(new BotMessage('', 'I don\'t know how to answer that'));

        } catch (Exception e) {
            System.debug(e);
            return new BotResponse(new BotMessage('', 'Oops, something went wrong invoking that command'));
        }

    }

    @AuraEnabled
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }


}