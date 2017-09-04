public class KnownIssueDetailController {
    
    public static final String PARAM_ISSUEID = 'id';
    public static final String PARAM_MESSAGEID = 'message';
    
    private Id knownIssueId;
    private Id dataMessageId;
    private Id userId;
    public Boolean userIsSubscribed {get; set;}
    
    public List<Known_Issue__c> relatedIssues {get; set;}
    
    public KnownIssueDetailController(ApexPages.StandardController controller) {
        knownIssueId = controller.getRecord().Id;
        dataMessageId = ApexPages.currentPage().getParameters().get(PARAM_MESSAGEID);
        userId = UserInfo.getUserId();
        userIsSubscribed = KnownIssuesUtils.verifyUserIsSubscribed(knownIssueId, userId);
        relatedIssues = KnownIssuesUtils.retrieveRelatedIssues(knownIssueId);
    }
    
    public PageReference subscribeToIssue() {
        KnownIssuesUtils.subscribeUsersToIssue(knownIssueId, new List<Id>{userId});
        if (dataMessageId != null){
            EinsteinUtils.associateMessageWithIssue(dataMessageId, knownIssueId);
        }
        userIsSubscribed = true;
        return null;
    }
    
    public PageReference unsubscribeToIssue() {
        KnownIssuesUtils.removeSubscribers(knownIssueId, new List<Id>{userId});
        userIsSubscribed = false;
        return null;
    }
    
    // Returns the URL for this page with the given parameters for Salesforce classic or Lightning Experience
    @AuraEnabled
    public static String getPageURL(String issueId, String messageId) {
        
        if (String.isBlank(issueId)) {
            return null;
        }
        
        String pageURL = (KnownIssuesSearchController.getIsLEX() ? '/one/one.app#/alohaRedirect' : '') + Page.KnownIssueDetail.getUrl();
        List<String> params = new List<String>();
        params.add( PARAM_ISSUEID + '=' + issueId );
        if (String.isNotBlank(messageId))
            params.add( PARAM_MESSAGEID + '=' + messageId );
        
        return pageURL + '?' + String.join(params, '&');
    }
    
}