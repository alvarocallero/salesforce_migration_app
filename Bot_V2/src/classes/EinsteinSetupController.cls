public class EinsteinSetupController {
	
    public static Boolean einsteinEnabled {get; set;}
    private static Map<Id, Einstein_Keyword__c> keywordsById;
    
    public String toastSuccessMessage {get; set;}
    public String toastErrorMessage {get; set;}
    public List<Einstein_Keyword__c> keywordsMissingMessages {get; set;}
    public List<Einstein_Data_Message__c> messagesToUpload {get; set;}
    
    public EinsteinSetupController() {
        
        if (GeneralUtils.botSettingsExist()) {
			einsteinEnabled = EinsteinUtils.getEinsteinEnabled();
        } else {
            einsteinEnabled = false;
        }
        
        keywordsMissingMessages = new List<Einstein_Keyword__c>();
        messagesToUpload = new List<Einstein_Data_Message__c>();
        
        // get Keyword records without messages
        keywordsById = new Map<Id, Einstein_Keyword__c>([ SELECT Id,
                                                             	 Name,
                                                             	 Einstein_Upload_Status__c,
                                                             	 Einstein_Data_Messages_Count__c
                                                          FROM Einstein_Keyword__c
                                                          WHERE Einstein_Data_Messages_Count__c = 0
                                                          AND Name != :EinsteinUtils.KEYWORD_UNDEFINED]);
        
        // get Message records of keywords that have less than 5 messages or that were not uploaded
        List<Einstein_Data_Message__c> messages = [ SELECT Id,
                                                   		   Name,
                                                   		   Message__c,
                                                   		   Einstein_Upload_Status__c,
                                                  		   Einstein_Keyword__r.Id,
                                                   		   Einstein_Keyword__r.Name,
                                                   		   Einstein_Keyword__r.Einstein_Upload_Status__c,
                                                   		   Einstein_Keyword__r.Einstein_Data_Messages_Count__c
                                                  	FROM Einstein_Data_Message__c
                                                  	WHERE (Einstein_Upload_Status__c = 'Not Uploaded'
                                                  			OR Einstein_Keyword__r.Einstein_Upload_Status__c = 'Not Uploaded'
                                                  			OR Einstein_Keyword__r.Einstein_Data_Messages_Count__c < 5)
                                                  	AND Einstein_Keyword__r.Name != :EinsteinUtils.KEYWORD_UNDEFINED ];
        
        // map Messages by Keyword
        for (Einstein_Data_Message__c message: messages) {
            if (!keywordsById.containsKey(message.Einstein_Keyword__r.Id)) {
                keywordsById.put(message.Einstein_Keyword__r.Id, message.Einstein_Keyword__r);
            }
        }
        
        // list Keywords with missing Messages for section 1 of the page
        for (Einstein_Keyword__c keyword: keywordsById.values()) {
            if (keyword.Einstein_Data_Messages_Count__c < 5) {
                keywordsMissingMessages.add(keyword);
            }
        }
        keywordsMissingMessages.sort();
		
		Map<Id, Einstein_Keyword__c> mapAux = new Map<Id, Einstein_Keyword__c>(keywordsMissingMessages);
        for (Einstein_Data_Message__c message: messages) {
            if (!mapAux.containsKey(message.Einstein_Keyword__r.Id) && message.Einstein_Upload_Status__c == 'Not Uploaded') {
                messagesToUpload.add(message);
            }
        }
        
    }
    
    public PageReference enableEinstein() {
        resetToastMessages();
        
        // Validate there are at least 3 Keywords with at least 5 messages
        AggregateResult result = [ SELECT count(Id) keywordsCount FROM Einstein_Keyword__c WHERE Einstein_Data_Messages_Count__c >= 5 ][0];
        if (((Integer) result.get('keywordsCount')) < 3) {
            toastErrorMessage = 'Einstein needs at least 3 Keywords that have at least 5 Messages each.';
        
        // Enable einstein
        } else {
            EinsteinUtils.setEinsteinEnabled(true);
            einsteinEnabled = true;
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
        
        // Validate no missing messages in Keywords section
        if (!keywordsMissingMessages.isEmpty()) {
            toastErrorMessage = 'Please verify there are no Keywords missing messages.';
            
        } else if(messagesToUpload.isEmpty()) {
        	toastErrorMessage = 'There are no messages to upload at the moment.';
        } else {
			Set<Id> keywordsToUpload = new Set<Id>();
            for (Einstein_Data_Message__c message: messagesToUpload) {
                keywordsToUpload.add(message.Einstein_Keyword__r.Id);
            }
            String response = EinsteinUtils.uploadMessagesToEinstein(keywordsToUpload);
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