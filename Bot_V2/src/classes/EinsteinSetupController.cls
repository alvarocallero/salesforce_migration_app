public class EinsteinSetupController {
	
    public static Boolean einsteinEnabled {get; set;}
    private static Map<Id, Einstein_Keyword__c> keywordsById;
    
    public String toastSuccessMessage {get; set;}
    public String toastErrorMessage {get; set;}
    public List<Einstein_Keyword__c> keywordsMissingMessages {get; set;}
    public List<Einstein_Keyword__c> keywordsToUpload {get; set;}
    public List<Einstein_Keyword__c> keywordsWithError {get; set;}
    
    public EinsteinSetupController() {
        
        if (GeneralUtils.botSettingsExist()) {
			einsteinEnabled = EinsteinUtils.getEinsteinEnabled();
        } else {
            einsteinEnabled = false;
        }
        keywordsMissingMessages = new List<Einstein_Keyword__c>();
        keywordsToUpload = new List<Einstein_Keyword__c>();
        keywordsWithError = new List<Einstein_Keyword__c>();        
        //New Known Issues
        List<Known_Issue__c> newKnownIssues = [
            SELECT Einstein_Keyword__r.Id,
            	Einstein_Keyword__r.Name,
            	Einstein_Keyword__r.Einstein_Upload_Status__c,
            	Einstein_Keyword__r.Einstein_Data_Messages_Count__c
            FROM Known_Issue__c
            WHERE Status__c !=: EinsteinUtils.KNOWN_ISSUE_PENDING_APPROVAL AND
            Status__c !=: EinsteinUtils.KNOWN_ISSUE_INVALID
        ];
        System.debug(newKnownIssues);
        for(Known_Issue__c knownIssue: newKnownIssues){
            System.debug(knownIssue.Einstein_Keyword__r);
            if(knownIssue.Einstein_Keyword__r.Einstein_Upload_Status__c == EinsteinUtils.UPLOAD_STATUS_NOT_UPLOADED){  
                if(knownIssue.Einstein_Keyword__r.Einstein_Data_Messages_Count__c < 5){
                    keywordsMissingMessages.add(knownIssue.Einstein_Keyword__r);
                } else {
                    keywordsToUpload.add(knownIssue.Einstein_Keyword__r);
                }            
            } else if (knownIssue.Einstein_Keyword__r.Einstein_Upload_Status__c == EinsteinUtils.UPLOAD_STATUS_ERROR){
                keywordsWithError.add(knownIssue.Einstein_Keyword__r);
            }            
        }             
    }
    
    public PageReference enableEinstein() {
        resetToastMessages();
        if (keywordsToUpload.size() < 3) {
            toastErrorMessage = 'Einstein needs at least 3 Keywords that have at least 5 Messages each.';
        }
        return null;
    }
    
    public PageReference disableEinstein() {
        resetToastMessages();
        
        EinsteinUtils.setEinsteinEnabled(false);
        einsteinEnabled = false;
        return null;
    }
    
    public PageReference uploadMessages() {
        resetToastMessages();            
       	if(keywordsToUpload.isEmpty()) {
        	toastErrorMessage = 'There are no keywords to upload at the moment.';
        } else if (keywordsToUpload.size() < 3) {
            toastErrorMessage = 'You have to upload at least 3 keywords with 5 Messages for each one.';
        } else {
			Set<Id> setKeywordsToUpload = new Set<Id>();
            for (Einstein_Keyword__c keyword: keywordsToUpload) {
                setKeywordsToUpload.add(keyword.Id);
            }
            String response = EinsteinUtils.uploadMessagesToEinstein(setKeywordsToUpload);
            if (response != null) {
                toastErrorMessage = response;
                
            } else {
                toastSuccessMessage = 'Einstein training complete.';
            }            
        }        
        // Value is lost on rerender for some reason
        einsteinEnabled = EinsteinUtils.getEinsteinEnabled();		
     	return null;
    }
    
    private void resetToastMessages() {
        toastErrorMessage = null;
        toastSuccessMessage = null;
    }
    
}