@isTest
public class KnownIssuesUtilsTest {

    static testmethod void testGetKnownIssues() {
        
        List<Known_Issue__c> issues = new List<Known_Issue__c>();
        String targetId = 'a01f400000AAAAA123';
        String targetName = 'nameABC';
        for(Integer i=0; i<10; i++){
        	issues.add( getNewKnownIssue('message', 'summary', KnownIssuesUtils.STATUS_NEW, targetName, targetId ) );
        }
        issues[0].recordTypeId = KnownIssuesUtils.RTYPE_ID_VFP;
        insert issues;
        
        Test.startTest();
        
        List<Known_Issue__c> emptyList = KnownIssuesUtils.getKnownIssues(null, null, null);
        
        List<Known_Issue__c> fullList = KnownIssuesUtils.getKnownIssues(null, targetName, targetId );
        Integer fullListSize = KnownIssuesUtils.getKnownIssuesCount(null, targetName, targetId);
        
        List<Known_Issue__c> recordTypeFilteredList = KnownIssuesUtils.getKnownIssues(KnownIssuesUtils.RTYPE_ID_VFP, targetName, targetId);
        Integer recordTypeFilteredListSize = KnownIssuesUtils.getKnownIssuesCount(KnownIssuesUtils.RTYPE_ID_VFP, targetName, targetId);
        
        Test.stopTest();
        
        System.assertEquals(0, emptyList.size(), 'emptyList search should return 0 issues.');
        System.assertEquals(10, fullList.size(), 'fullList search should return 10 issues.');
        System.assertEquals(fullList.size(), fullListSize, 'fullList and fullListSize mismatch.');
        System.assertEquals(1, recordTypeFilteredList.size(), 'recordTypeFilteredList search should return 1 issue.');
        System.assertEquals(recordTypeFilteredList.size(), recordTypeFilteredListSize, 'recordTypeFilteredListSize and recordTypeFilteredListSize mismatch.');
        
    }
	
    
    static testmethod void testSubscribeUsersToIssue() {
        
        String targetId = 'a01f400000AAAAA123';
        String targetName = 'nameABC';
        Known_Issue__c issue = getNewKnownIssue('message', 'summary', KnownIssuesUtils.STATUS_NEW, targetName, targetId );
        insert issue;
        
        Test.startTest();
        
        KnownIssuesUtils.subscribeUsersToIssue(issue.Id, new List<Id>{UserInfo.getUserId()} );
        
        Test.stopTest();
        
        List<Known_Issue__c> issuesList = KnownIssuesUtils.getKnownIssues(null, targetName, targetId );
        System.assert(!issuesList.isEmpty() && !issuesList[0].Known_Issue_Subscribers__r.isEmpty(), 'No subscribers found for this issue.');
        System.assertEquals(UserInfo.getUserId(), issuesList[0].Known_Issue_Subscribers__r[0].Subscriber__c, 'Active user should be subscribed to the issue.');
        
    } 
    
    
    static testmethod void testReparentSubscribersOfDuplicatedIssues() {
        
        String targetId = 'a01f400000AAAAA123';
        String targetName = 'nameABC';
        Known_Issue__c issue = getNewKnownIssue('message', 'summary', KnownIssuesUtils.STATUS_NEW, targetName, targetId );
        insert issue;
        List<User> users = new List<User>{ getNewStandardUser('usra'),
            							   getNewStandardUser('usrb'),
            							   getNewStandardUser('usrc') };
        insert users;
        
        KnownIssuesUtils.subscribeUsersToIssue( issue.Id, new List<Id>{users[0].Id} );
        
        Known_Issue__c duplicateIssue = getNewKnownIssue('message2', 'summary2', KnownIssuesUtils.STATUS_NEW, targetName, targetId );
        insert duplicateIssue;
        
        KnownIssuesUtils.subscribeUsersToIssue( duplicateIssue.Id, new List<Id>{ users[0].Id,
            																	 users[1].Id,
            																	 users[2].Id } );
        
        Test.startTest();
        
        duplicateIssue.Status__c = KnownIssuesUtils.STATUS_DUPLICATED;
        duplicateIssue.Related_Issue__c = issue.Id;
        update duplicateIssue;
        
        Test.stopTest();
        
        List<Known_Issue_Subscriber__c> originalIssueSubscribers = [ SELECT Id FROM Known_Issue_Subscriber__c WHERE Known_Issue__c = :issue.Id ];
        System.assertEquals(3, originalIssueSubscribers.size(), 'Subscribers from the duplicated issue should be subscribed to the original one.');
        
        List<Known_Issue_Subscriber__c> duplicatedIssueSubscribers = [ SELECT Id FROM Known_Issue_Subscriber__c WHERE Known_Issue__c = :duplicateIssue.Id ];
        System.assertEquals(0, duplicatedIssueSubscribers.size(), 'The duplicate issue should have no subscribers.');
        
    }
    
    
    static testmethod void testNotifyFixedIssuesSubscribers() {
        
        String targetId = 'a01f400000AAAAA123';
        String targetName = 'nameABC';
        Known_Issue__c issue = getNewKnownIssue('message', 'summary', KnownIssuesUtils.STATUS_NEW, targetName, targetId );
        insert issue;
        List<User> users = new List<User>{ getNewStandardUser('usra'),
            							   getNewStandardUser('usrb'),
            							   getNewStandardUser('usrc') };
        insert users;
        
        KnownIssuesUtils.subscribeUsersToIssue( issue.Id, new List<Id>{ users[0].Id,
            															users[1].Id,
            															users[2].Id } );
        Test.startTest();
        
        issue.Status__c = KnownIssuesUtils.STATUS_FIXED;
        update issue;
        
        Test.stopTest();
    }
    
    
    // TEST DATA
    
    public static Known_Issue__c getNewKnownIssue(String message, String summary, String status, String targetName, String targetId ) {
        return new Known_Issue__c( Message__c = message,
                                   Message_Summary__c = summary,
                                   Status__c = KnownIssuesUtils.STATUS_NEW,
                                   Dashboard_Report_Id__c = targetId,
                                   Document_Id__c = targetId,
                                   Email_Template_Id__c = targetId,
                                   Object_List_ObjectName__c = targetName,
                                   Package_Name__c = targetName,
                                   Record_Detail_Id__c = targetId,
                                   Visualforce_Page_Name__c = targetName );
    }
    
    public static User getNewStandardUser(String alias){
        Id profileId = [ SELECT Id FROM Profile WHERE Name = 'Standard User' ].Id;
        return getNewUser(alias, profileId);
    }
    
    public static User getNewUser(String alias, Id profileId) {
    	User u = new User( Alias = alias,
                           Email = alias + '@testorg.com',
            			   EmailEncodingKey = 'UTF-8',
                           LastName = alias,
                           LanguageLocaleKey = 'en_US',
            			   LocaleSidKey = 'en_US',
                           ProfileId = profileId, 
            			   TimeZoneSidKey = 'America/Los_Angeles',
                           UserName = alias + '@testorg.com' );
        return u;
    }
    
}