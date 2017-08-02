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
}