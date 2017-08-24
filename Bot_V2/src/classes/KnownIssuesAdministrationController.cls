public class KnownIssuesAdministrationController {
    private Map<String, String> KEYWORDS = new Map<String, String>{'All' => 'All', 'UNDEFINED' => EinsteinUtils.KEYWORD_UNDEFINED};
    private String ALL_KNOWN_ISSUES = 'All';

    private List<SelectOption> keywordSelectOptions = new List<SelectOption>();
	private List<SelectOption> statusSelectOptions = new List<SelectOption>();

    public String selectedKeyword {get; set;}
    public String selectedStatus {get; set;}

    public List<Known_Issue__c> filteredKnownIssues {get; set;}

    public KnownIssuesAdministrationController(){
        loadKeywordSelectOptions();
        loadStatusSelectOptions();
		selectedKeyword = ALL_KNOWN_ISSUES;
		selectedStatus = KnownIssuesUtils.STATUS_PENDINGAPPROVAL;
        filterKnownIssues();
    }

    public List<SelectOption> getKeywordSelectOptions() {
        return keywordSelectOptions;
    }

    public List<SelectOption> getStatusSelectOptions() {
        return statusSelectOptions;
    }

    public void reloadKnowIssues(){
        filterKnownIssues();
    }

    private void loadKeywordSelectOptions(){
        for(String keyword : KEYWORDS.keySet()){
            keywordSelectOptions.add(new SelectOption(keyword, KEYWORDS.get(keyword)));
        }
    }

    private void loadStatusSelectOptions(){
        Schema.DescribeFieldResult knownIssueDescribe = Known_Issue__c.Status__c.getDescribe();

        List<Schema.PicklistEntry> ple = knownIssueDescribe.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            statusSelectOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }
    }

    private void filterKnownIssues(){
        filteredKnownIssues = new List<Known_Issue__c>();
        String queryString = 'SELECT Id, Status__c, Message_Summary__c, Einstein_Keyword__r.Name From Known_Issue__c ';
        queryString += 'WHERE Status__c = \'' + selectedStatus + '\' ';
        if(selectedKeyword != ALL_KNOWN_ISSUES){
            queryString += 'and Einstein_Keyword__r.Name = \'' + selectedKeyword + '\' ';
        }
        queryString += 'Limit 1000';
        try{
			filteredKnownIssues = Database.query(queryString);
        }catch(Exception e){
            System.debug('Error: ' + e);
        }
    }

}
