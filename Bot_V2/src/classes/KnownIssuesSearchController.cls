public class KnownIssuesSearchController {
    
    public static final String PARAM_TARGETID = 'id';
    public static final String PARAM_TARGETNAME = 'name';
    public static final String PARAM_RECORDTYPE = 'type';
    
    private String targetId;
    private String targetName;
    private Id recordTypeId;
    private List<Known_Issue__c> issues;
    
    public List<IssueRow> issueRows {get; set;}
    public Id issueToSubscribe {get; set;}
    
    public KnownIssuesSearchController() {
    
        targetId =  ApexPages.currentPage().getParameters().get(PARAM_TARGETID);
        targetName = ApexPages.currentPage().getParameters().get(PARAM_TARGETNAME);
        recordTypeId = ApexPages.currentPage().getParameters().get(PARAM_RECORDTYPE);
        issues = KnownIssuesUtils.getKnownIssues(recordTypeId, targetName, targetId);
        
        issueRows = new List<IssueRow>();
        for (Known_Issue__c issue : issues) {
            issueRows.add( new IssueRow(issue) );
        }
        
    }
    
    public Boolean getIssuesFound() {
        return issues != null && issues.size() > 0;
    }
    
    public void subscribeToIssue() {
        
        if(issueToSubscribe == null)
            return;
        
        KnownIssuesUtils.subscribeUsersToIssue(issueToSubscribe, new List<Id>{UserInfo.getUserId()});
        for (IssueRow row: issueRows) {
            if(row.issue.Id == issueToSubscribe){
                row.subscribed = true;
            }
        }
        
        issueToSubscribe = null;
    }
    
    
    public class IssueRow {
        public Known_Issue__c issue {get; set;}
        public Boolean subscribed {get; set;}
        
        public IssueRow(Known_Issue__c issue){
            this.issue = issue;
            subscribed = false;
            for( Known_Issue_Subscriber__c sub : issue.Known_Issue_Subscribers__r ) {
                if (sub.Subscriber__c == UserInfo.getUserId() ) {
                    subscribed = true;
                }
            }
        }
    }
    
    public static Boolean getIsLEX() {
        return UserInfo.getUiThemeDisplayed().startsWith('Theme4');
    }
    
    
    // Returns the URL for this page with the given parameters for Salesforce classic or Lightning Experience
    // Null values are accepted but at least targetName or targetId must have a valid value.
    // For recordTypeId see KnownIssuesUtils.class.
    @AuraEnabled
    public static String getPageURL(String recordTypeId, String targetName, String targetId) {
        
        if (String.isBlank(targetName) && String.isBlank(targetId)) {
            return null;
        }
        
        String pageURL = (getIsLEX() ? '/one/one.app#/alohaRedirect' : '') + Page.KnownIssuesSearch.getUrl();
        List<String> params = new List<String>();
        if (String.isNotBlank(recordTypeId))
            params.add( PARAM_RECORDTYPE + '=' + recordTypeId );
        if (String.isNotBlank(targetName))
            params.add( PARAM_TARGETNAME + '=' + targetName );
        if (String.isNotBlank(targetId))
            params.add( PARAM_TARGETID + '=' + targetId );
        
        return pageURL + '?' + String.join(params, '&');
    }
    
}