@IsTest
public class KnownIssueDetailControllerTest {
    
    static testmethod void testController() {
        
        String targetId = 'a01f400000AAAAA123';
        String targetName = 'nameABC';
        
        Einstein_Keyword__c keyword = new Einstein_Keyword__c( Name = 'TEST KEYWORD' );
        insert keyword;
        
        Known_Issue__c issue = KnownIssuesUtilsTest.getNewKnownIssue('message', 'summary', KnownIssuesUtils.STATUS_NEW, targetName, targetId );
        issue.recordTypeId = KnownIssuesUtils.RTYPE_ID_VFP;
        issue.Einstein_Keyword__c = keyword.Id;
        insert issue;
        
        Id messageId = EinsteinUtils.createMessage(null, 'TEST MESSAGE');
        
        PageReference pageRef = Page.KnownIssueDetail;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(KnownIssueDetailController.PARAM_ISSUEID, issue.Id);
        ApexPages.currentPage().getParameters().put(KnownIssueDetailController.PARAM_MESSAGEID, messageId);
        
        Test.startTest();
        
        KnownIssueDetailController controller = new KnownIssueDetailController(new ApexPages.StandardController(issue));
        
        controller.subscribeToIssue();
        Boolean userSubscribed = controller.userIsSubscribed == true;
        
        controller.unsubscribeToIssue();
       	Boolean userUnsubscribed = controller.userIsSubscribed == false;
        
        Test.stopTest();
        
        
        System.assert(userSubscribed, 'User should have been subscribed');
        System.assert(userUnsubscribed, 'User should have been unsubscribed');
        
        List<Einstein_Data_Message__c> messages = [ SELECT Id, Einstein_Keyword__c FROM Einstein_Data_Message__c WHERE Id = :messageId ];
        System.assertEquals(keyword.Id, messages[0].Einstein_Keyword__c, 'Message should be associated to keyword');
    }
    
    
    static testmethod void testGetPageURL() {
        
        String issueId = 'a01f400000AAAAA123';
        String messageId = 'a01f400000AAAAA456';
        
        Test.startTest();
        
        String invalidParams = KnownIssueDetailController.getPageURL(null, messageId);
        String onlyIssueURL = KnownIssueDetailController.getPageURL(issueId, null);
        String fullPageURL = KnownIssueDetailController.getPageURL(issueId, messageId);
        
        Test.stopTest();
        
        System.assertEquals(null, invalidParams);
        System.assert(!String.isBlank(onlyIssueURL));
        System.assert(!String.isBlank(fullPageURL));
        System.assert(fullPageURL.length() > onlyIssueURL.length());
        
    }
    
}