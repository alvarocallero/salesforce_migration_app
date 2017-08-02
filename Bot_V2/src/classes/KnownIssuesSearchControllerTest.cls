@IsTest
public class KnownIssuesSearchControllerTest {
	
    static testmethod void testController() {
        
        String targetId = 'a01f400000AAAAA123';
        String targetName = 'nameABC';
        Known_Issue__c issue = KnownIssuesUtilsTest.getNewKnownIssue('message', 'summary', KnownIssuesUtils.STATUS_NEW, targetName, targetId );
        issue.recordTypeId = KnownIssuesUtils.RTYPE_ID_VFP;
        insert issue;
        
        PageReference pageRef = Page.KnownIssuesSearch;
        Test.setCurrentPage(pageRef);
      	
        ApexPages.currentPage().getParameters().put(KnownIssuesSearchController.PARAM_TARGETID, targetId);
        ApexPages.currentPage().getParameters().put(KnownIssuesSearchController.PARAM_TARGETNAME, targetName);
        ApexPages.currentPage().getParameters().put(KnownIssuesSearchController.PARAM_RECORDTYPE, KnownIssuesUtils.RTYPE_ID_VFP);
        
        Test.startTest();
        
        KnownIssuesSearchController controller = new KnownIssuesSearchController();
        
       	Boolean issuesFound = controller.getIssuesFound();
        
        controller.subscribeToIssue();
        controller.issueToSubscribe = issue.Id;
        controller.subscribeToIssue();
        
        Known_Issue__c issueAux = [ SELECT Id, (SELECT Id, Subscriber__c FROM Known_Issue_Subscribers__r)
                                  	FROM Known_Issue__c
                                  	WHERE Id = :issue.Id ];
        KnownIssuesSearchController.IssueRow newIssueRow = new KnownIssuesSearchController.IssueRow(issueAux);
        
        Test.stopTest();
        
        System.assert(issuesFound, 'No issues were found by the page.');
        
        List<Known_Issue__c> issuesList = KnownIssuesUtils.getKnownIssues(KnownIssuesUtils.RTYPE_ID_VFP, targetName, targetId );
        System.assert(!issuesList.isEmpty() && !issuesList[0].Known_Issue_Subscribers__r.isEmpty(), 'No subscribers found for this issue.');
        System.assertEquals(UserInfo.getUserId(), issuesList[0].Known_Issue_Subscribers__r[0].Subscriber__c, 'Active user should be subscribed to the issue.');
        
        System.assert(newIssueRow.subscribed, 'IssueRow subscribed field should be true.');
    }
    
    
    static testmethod void testGetPageURL() {
        
        String targetId = 'a01f400000AAAAA123';
        String targetName = 'nameABC';
        String recordTypeId = KnownIssuesUtils.RTYPE_ID_VFP;
        
        Test.startTest();
        
        String invalidParams = KnownIssuesSearchController.getPageURL(recordTypeId, null, null);
        String fullPageURL = KnownIssuesSearchController.getPageURL(recordTypeId, targetName, targetId);
        String noRecordTypePageURL = KnownIssuesSearchController.getPageURL(null, targetName, targetId);
        
        Test.stopTest();
        
        System.assertEquals(null, invalidParams);
        System.assert(!String.isBlank(fullPageURL));
        System.assert(!String.isBlank(noRecordTypePageURL));
        System.assert(fullPageURL.length() > noRecordTypePageURL.length());
        
    }
    
}