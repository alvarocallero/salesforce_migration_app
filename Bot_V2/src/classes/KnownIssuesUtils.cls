public class KnownIssuesUtils {

    public static final String STATUS_NEW = 'New';
    public static final String STATUS_PENDINGAPPROVAL = 'Pending Approval';
    public static final String STATUS_FIXED = 'Fixed';
    public static final String STATUS_DUPLICATED = 'Duplicated';
    public static final String STATUS_INVALID = 'Invalid';

    private static final Map<String, Schema.RecordTypeInfo> KI_RECORDTYPES = Schema.SObjectType.Known_Issue__c.getRecordTypeInfosByName();
    public static final String RTYPE_NAME_DR = 'Dashboard & Report';
    public static final String RTYPE_NAME_DOC = 'Documents';
    public static final String RTYPE_NAME_ET = 'Email Template';
    public static final String RTYPE_NAME_OL = 'Object List';
    public static final String RTYPE_NAME_OTHER = 'Other';
    public static final String RTYPE_NAME_PKG = 'Package';
    public static final String RTYPE_NAME_RD = 'Record Detail';
    public static final String RTYPE_NAME_UNK = 'Unknown';
    public static final String RTYPE_NAME_VFP = 'Visualforce Pages';
    public static final Id RTYPE_ID_DR = KI_RECORDTYPES.get(RTYPE_NAME_DR).getRecordTypeId();
    public static final Id RTYPE_ID_DOC = KI_RECORDTYPES.get(RTYPE_NAME_DOC).getRecordTypeId();
    public static final Id RTYPE_ID_ET = KI_RECORDTYPES.get(RTYPE_NAME_ET).getRecordTypeId();
    public static final Id RTYPE_ID_OL = KI_RECORDTYPES.get(RTYPE_NAME_OL).getRecordTypeId();
    public static final Id RTYPE_ID_OTHER = KI_RECORDTYPES.get(RTYPE_NAME_OTHER).getRecordTypeId();
    public static final Id RTYPE_ID_PKG = KI_RECORDTYPES.get(RTYPE_NAME_PKG).getRecordTypeId();
    public static final Id RTYPE_ID_RD = KI_RECORDTYPES.get(RTYPE_NAME_RD).getRecordTypeId();
    public static final Id RTYPE_ID_UNK = KI_RECORDTYPES.get(RTYPE_NAME_UNK).getRecordTypeId();
    public static final Id RTYPE_ID_VFP = KI_RECORDTYPES.get(RTYPE_NAME_VFP).getRecordTypeId();


    // To be used by the BOT to know the count of Known Issues on a page
    @AuraEnabled
    public static Integer getKnownIssuesCount(Id recordTypeId, String targetName, String targetId) {
        return getKnownIssues(recordTypeId, targetName, targetId).size();
    }

    public static Known_Issue__c createKnownIssue(Id dataMessageId, String currentUrl, ContentVersion contentVersion){

        List<Einstein_Data_Message__c> edm = [SELECT Id, Message__c FROM Einstein_Data_Message__c WHERE Id = :dataMessageId];

        String sObjectTypeName = '';
        Id sObjectId = null;

        if(currentUrl.contains('sObject')){
            String checkId = currentUrl.substringBetween('/sObject/', '/');

            if((checkId.length()==15 || checkId.length()==18) && Pattern.matches('^[a-zA-Z0-9]*$', checkId)){
                sObjectId = checkId;
            }else{
                sObjectTypeName = checkId;
            }

        }

        if(!String.isBlank(sObjectId)){
            sObjectTypeName = sObjectId.getSobjectType().getDescribe().getName();
        }

        Known_Issue__c newKi = new Known_Issue__c();

        if(!String.isBlank(sObjectTypeName)){
            newKi.Record_Detail_Id__c = sObjectId;
            newKi.Object_List_ObjectName__c = sObjectTypeName;

            if(sObjectTypeName == 'Dashboard' || sObjectTypeName == 'Report'){
                newKi.Dashboard_Report_Id__c = sObjectId;
            }
            else if(sObjectTypeName == 'ContentDocument'){
                newKi.Document_Id__c = sObjectId;
            }
            else if(sObjectTypeName == 'EmailTemplate'){
                newKi.Email_Template_Id__c = sObjectId;
            }
        }

        newKi.Message__c = edm.get(0).Message__c;
        newKi.Message_Summary__c = edm.get(0).Message__c;
        newKi.Einstein_Keyword__c = EinsteinUtils.getUndefinedKeywordId();
        newKi.Status__c = 'Pending Approval';
        newKi.Priority__c = 'Normal (3)';
        
        if(contentVersion != null){
            newKi.Content_Document__c = contentVersion.Id;
        }

        insert newKi;

        EinsteinUtils.associateMessageWithIssue(edm.get(0).Id, newKi.Id);

        return newKi;
    }


    // Will return a list of Known Issues that were approved by an admin and match the target's Name or Id
    // Also returns the list of Subscribers. List<Known_Issue_Subscriber__c> subscribers = issue.Known_Issue_Subscribers__r;
    public static List<Known_Issue__c> getKnownIssues(Id recordTypeId, String targetName, String targetId) {

        if (String.isBlank(targetName) && String.isBlank(targetId)) {
            return new List<Known_Issue__c>();
        }

        String soqlQuery = 'SELECT Id,'
                                 + 'Name,'
                                 + 'CreatedById,'
                                 + 'CreatedBy.Name,'
                                 + 'CreatedDate,'
                                 + 'Estimated_Due_Date__c,'
                                 + 'RecordTypeId,'
                                 + 'RecordType.Name,'
                                 + 'Status__c,'
                                 + 'Priority__c,'
                                 + 'Related_Issue__c,'
                                 + 'Einstein_Keyword__c,'
                                 + 'Message__c,'
                                 + 'Message_Summary__c,'
                                 + 'Reason__c,'
                                 + 'Dashboard_Report_Id__c,'
                                 + 'Document_Id__c,'
                                 + 'Email_Template_Id__c,'
                                 + 'Object_List_ObjectName__c,'
                                 + 'Package_Name__c,'
                                 + 'Record_Detail_Id__c,'
                                 + 'Visualforce_Page_Name__c,'
                                 + '(SELECT Id, Known_Issue__c, Subscriber__c, Subscriber__r.Name FROM Known_Issue_Subscribers__r)'
        				 + ' FROM Known_Issue__c'
        				 + ' WHERE ( (Dashboard_Report_Id__c != null AND Dashboard_Report_Id__c = :targetId)'
                                 + ' OR (Document_Id__c != null AND Document_Id__c = :targetId)'
                                 + ' OR (Email_Template_Id__c != null AND Email_Template_Id__c = :targetId)'
                                 + ' OR (Object_List_ObjectName__c != null AND Object_List_ObjectName__c = :targetName)'
                                 + ' OR (Package_Name__c != null AND Package_Name__c = :targetName)'
                                 + ' OR (Record_Detail_Id__c != null AND Record_Detail_Id__c = :targetId)'
                                 + ' OR (Visualforce_Page_Name__c != null AND Visualforce_Page_Name__c = :targetName) )'
        				 + ( String.isNotBlank(recordTypeId) ? ' AND RecordTypeId = :recordTypeId' : '' )
            			 + ' AND Status__c = :STATUS_NEW'
            			 + ' AND Message_Summary__c != null';

        return Database.query(soqlQuery);
    }

    public static Boolean verifyUserIsSubscribed(Id issueId, Id userId) {
        List<Known_Issue_Subscriber__c> subscribers = [ SELECT Id FROM Known_Issue_Subscriber__c
                                                        WHERE Known_Issue__c = :issueId
                                                        AND Subscriber__c = :userId ];
        return !subscribers.isEmpty();
    }

    public static void subscribeUsersToIssue(Id issueId, List<Id> userIds) {
        List<Known_Issue_Subscriber__c> subscribers = new List<Known_Issue_Subscriber__c>();
        for(Id userId: userIds){
            subscribers.add( new Known_Issue_Subscriber__c(Known_Issue__c = issueId,
                                                          	Subscriber__c  = userId));
        }
        if (!subscribers.isEmpty()) {
            insert subscribers;
        }
    }

    public static void removeSubscribers(Id issueId, List<Id> userIds) {
        List<Known_Issue_Subscriber__c> subscribers = [ SELECT Id FROM Known_Issue_Subscriber__c
                                                        WHERE Known_Issue__c = :issueId
                                                        AND Subscriber__c IN :userIds ];
        if (!subscribers.isEmpty()) {
           delete subscribers;
        }
    }


    public static void reparentSubscribersOfDuplicatedIssues(List<Known_Issue__c> issues) {
        Map<Id, Set<Id>> subUserIdsByOriginalIssueId = new Map<Id, Set<Id>>();
        for (Known_Issue__c issue: issues) {
            if (issue.Related_Issue__c != null)
        	subUserIdsByOriginalIssueId.put(issue.Related_Issue__c, new Set<Id>());
        }

        List<Known_Issue_Subscriber__c> subscribers = [ SELECT Id,
                                                       		   Known_Issue__c,
                                                       		   Known_Issue__r.Status__c,
                                                       		   Known_Issue__r.Related_Issue__c,
                                                       		   Subscriber__c
                                                       	FROM Known_Issue_Subscriber__c
                                                      	WHERE ( Known_Issue__c IN :issues
                                                      			AND Known_Issue__r.Related_Issue__c != null
                                                              	AND Known_Issue__r.Status__c = :STATUS_DUPLICATED )
                                                      	OR Known_Issue__c IN :subUserIdsByOriginalIssueId.keySet() ];

		for (Known_Issue_Subscriber__c sub: subscribers) {
            if ( subUserIdsByOriginalIssueId.containsKey(sub.Known_Issue__c) ) {
            	subUserIdsByOriginalIssueId.get(sub.Known_Issue__c).add(sub.Subscriber__c);
            }
        }

        List<Known_Issue_Subscriber__c> subsToUpdate = new List<Known_Issue_Subscriber__c>();
        List<Known_Issue_Subscriber__c> subsToDelete = new List<Known_Issue_Subscriber__c>();
        for (Known_Issue_Subscriber__c sub: subscribers) {
            if ( sub.Known_Issue__r.Status__c == STATUS_DUPLICATED ) {
                Set<Id> usersSubscribedToOriginalIssue = subUserIdsByOriginalIssueId.get(sub.Known_Issue__r.Related_Issue__c);
                if (usersSubscribedToOriginalIssue != null && usersSubscribedToOriginalIssue.contains(sub.Subscriber__c) ) {
                    subsToDelete.add(sub);
                } else {
                    sub.Known_Issue__c = sub.Known_Issue__r.Related_Issue__c;
                    subsToUpdate.add(sub);
                }
            }
        }

        if (!subsToUpdate.isEmpty()) {
            update subsToUpdate;
        }
        if (!subsToDelete.isEmpty()) {
            delete subsToDelete;
        }
    }


    public static void notifyFixedIssuesSubscribers(List<Known_Issue__c> issues, Map<Id,Known_Issue__c> oldIssuesById) {

        Set<Id> fixedIssues = new Set<Id>();
        for (Known_Issue__c issue : issues) {
            if ( issue.Status__c == STATUS_FIXED
                	&& issue.Status__c != oldIssuesById.get(issue.Id).Status__c ) {
                fixedIssues.add(issue.Id);
            }
        }

        if (fixedIssues.isEmpty()) {
            return;
        }

        List<Known_Issue_Subscriber__c> subscribers = [ SELECT Id,
                                                       		   Known_Issue__c,
                                                       		   Known_Issue__r.Name,
                                                       		   Known_Issue__r.Message_Summary__c,
                                                       		   Subscriber__c
                                                       	FROM Known_Issue_Subscriber__c
                                                      	WHERE Known_Issue__c IN :fixedIssues ];

        // prepare Platform Events and Emails
        List<Bot_Notification__e > botNotifications = new List<Bot_Notification__e >();
        List<Messaging.SingleEmailMessage> botNotificationEmails = new List<Messaging.SingleEmailMessage>();

        for (Known_Issue_Subscriber__c sub: subscribers) {

            // create a bot notification per subscriber
            botNotifications.add( GeneralUtils.getNewBotNotification( sub.Known_Issue__c,
																	  sub.Known_Issue__r.Name,
																	  sub.Known_Issue__r.Message_Summary__c,
																	  sub.Subscriber__c ) );
            // create email noification
            botNotificationEmails.add( GeneralUtils.getNewBotNotificationEmail( sub.Known_Issue__c,
																				sub.Known_Issue__r.Name,
																				sub.Known_Issue__r.Message_Summary__c,
																				sub.Subscriber__c ) );
        }

        // publish bot notifications
        List<Database.SaveResult> results = EventBus.publish(botNotifications);

        // send email notifications
        Messaging.sendEmail(botNotificationEmails);

    }


    public static List<Known_Issue__c> setUndefinedKeyword(List<Known_Issue__c> issues) {
        Id undefinedKeywordId = EinsteinUtils.getUndefinedKeywordId();
        for (Known_Issue__c issue: issues) {
            if (issue.Einstein_Keyword__c == null) {
                issue.Einstein_Keyword__c = undefinedKeywordId;
            }
        }
        return issues;
    }

    public static void setDuplicatedOrNewKeyword(List<Known_Issue__c> issuesToUpdate, Map<Id,Known_Issue__c> oldIssuesById){
        for(Known_Issue__c updatedKI: issuesToUpdate){
            if(updatedKI.Status__c == oldIssuesById.get(updatedKI.Id).Status__c && updatedKI.Status__c != null){
                if(updatedKI.Einstein_Keyword__c != null){
                    Einstein_Keyword__c issueKeyword = [Select id, Name
                                                        FROM Einstein_Keyword__c
                                                        WHERE ID = :updatedKI.Einstein_Keyword__c
                                                        Limit 1];
                    if(issueKeyword.Id != EinsteinUtils.getUndefinedKeywordId()){

                            List<Known_Issue__c> duplicatedKnownIssues = [SELECT Id, Einstein_Keyword__r.Name
                                                                          FROM Known_Issue__c
                                                                          WHERE Id != :updatedKI.Id
                                                                          AND Einstein_Keyword__r.Name = :issueKeyword.Name];
                            if(duplicatedKnownIssues.size() > 0){
                                updatedKI.Status__c = STATUS_DUPLICATED;
                            }else{
                                updatedKI.Status__c = STATUS_NEW;
                            }
                    }

                }
            }
        }
    }
}