public class EinsteinUtils {
	
    public static final String KEYWORD_UNDEFINED = 'UNDEFINED';
    public static final String KEYWORD_UNKNOWN = 'UNKNOWN';
    private static Id KEYWORD_ID_UNDEFINED;
    
    
    // MANAGE CUSTOM SETTING VALUES RELATED TO EINSTEIN
    
    public static Boolean getEinsteinEnabled() {
        return GeneralUtils.getBotSettings().Einstein_Enabled__c;
    }
    
    public static void setEinsteinEnabled(Boolean enabled) {
        GeneralUtils.getBotSettings().Einstein_Enabled__c = enabled == true;
        update GeneralUtils.BOT_SETTINGS;
    }
    
    public static String getEinsteinToken() {
        return GeneralUtils.getBotSettings().Einstein_Token__c;
    }
    
    public static void setEinsteinToken(String token) {
        GeneralUtils.getBotSettings().Einstein_Token__c = token;
        update GeneralUtils.BOT_SETTINGS;
    }
    
    public static Decimal getEinsteinDatasetId() {
        return GeneralUtils.getBotSettings().Einstein_DatasetId__c;
    }
    
    public static void setEinsteinDatasetId(Decimal datasetId) {
        GeneralUtils.getBotSettings().Einstein_DatasetId__c = datasetId;
        update GeneralUtils.BOT_SETTINGS;
    }

    public static String getEinsteinModelId() {
        return GeneralUtils.getBotSettings().Einstein_ModelId__c;
    }
    
    public static void setEinsteinModelId(String modelId) {
        GeneralUtils.getBotSettings().Einstein_ModelId__c = modelId;
        update GeneralUtils.BOT_SETTINGS;
    }
    // MANAGE KEYWORDS AND MESSAGES
    
    public static Id getUndefinedKeywordId() {
        
        if (KEYWORD_ID_UNDEFINED == null){
            List<Einstein_Keyword__c> keywords = [ SELECT Id
                                                  FROM Einstein_Keyword__c
                                                  WHERE Name = :KEYWORD_UNDEFINED
                                                  LIMIT 1 ];
            if (keywords.isEmpty()){
                keywords.add(new Einstein_Keyword__c( Name = KEYWORD_UNDEFINED,
                                                      Einstein_Upload_Status__c = 'Not Uploaded' ));
                insert keywords;
            }
            KEYWORD_ID_UNDEFINED = keywords[0].Id;
        }
        return KEYWORD_ID_UNDEFINED;
    }
    
    
    // Creates new message and returns the Id.
    // If keywordId is null then it will be associated to an UNDEFINED keyword.
    public static Id createMessage(Id keywordId, String message) {
		        
        String keywordIdFinal = keywordId != null ? keywordId : getUndefinedKeywordId();
        Einstein_Data_Message__c msg = new Einstein_Data_Message__c( Einstein_Keyword__c = keywordIdFinal,
                                                                     Message__c = message,
                                                                     Einstein_Upload_Status__c = 'Not Uploaded' ); //CHANGE TO NOT UPLOADED
        
        insert msg;
        return msg.Id;
    }
    
    
    public static void associateMessageWithIssue(Id messageId, Id knownIssueId) {
        //update this method
        /*List<Einstein_Keyword__c> keywords = [ SELECT Id
                                               FROM Einstein_Keyword__c
                                               WHERE Id IN (SELECT Einstein_Keyword__c FROM Known_Issue__c WHERE Id = :knownIssueId ) ];
        */
        List<Einstein_Data_Message__c> messages = [ SELECT Id,
                                                    Einstein_Keyword__c,
                                                 	Known_Issue__c
                                                   	FROM Einstein_Data_Message__c
                                                    WHERE Id = :messageId ];
        if (!messages.isEmpty()) {
            //messages[0].Einstein_Keyword__c = keywords[0].Id;
            messages[0].Known_Issue__c = knownIssueId;
            update messages[0];
        }
    }
    
    
    // Returns null if successfull or String if fails
    // JSON format:
    /*
     { "intents": { "keyword1": [ "message1","message2","message3","message4","message5"],
					"keyword2": [ "message1","message2","message3","message4","message5"], 
					"keywordN": [ "message1","message2","message3","message4","message5"] }
      }
	*/
    public static String uploadMessagesToEinstein(Set<Id> keywordIds) {
        
        // get all Keyword and Message records
        List<Einstein_Keyword__c> keywords = [ SELECT Id,
                                              		  Name,
                                              		  Einstein_Upload_Status__c,
                                              		  (SELECT Id,
                                                   			  Name,
                                                   		 	  Message__c,
                                                   		 	  Einstein_Upload_Status__c
                                                       FROM Einstein_Data_Messages__r)
                                               FROM Einstein_Keyword__c
                                               WHERE Id IN :keywordIds ];
        
        // initialize lists to store records to update
        List<Einstein_Keyword__c> keywordsToUpdate = new List<Einstein_Keyword__c>();
        List<Einstein_Data_Message__c> messagesToUpdate = new List<Einstein_Data_Message__c>();
        
        // initialize JSON
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
		gen.writeFieldName('intents');
        gen.writeStartObject();
        
        // write each Keyword into the JSON and add it to update list if needed
        for (Einstein_Keyword__c keyword: keywords) {
            
            gen.writeFieldName(keyword.Name);
            
            if (keyword.Einstein_Upload_Status__c != 'Uploaded') {
                keyword.Einstein_Upload_Status__c = 'Uploaded';
                keywordsToUpdate.add(keyword);
            }
            
            gen.writeStartArray();
            
            // write each Message into JSON if it was never uploaded
            for (Einstein_Data_Message__c message: keyword.Einstein_Data_Messages__r) {
                if (message.Einstein_Upload_Status__c != 'Uploaded') {
                	message.Einstein_Upload_Status__c = 'Uploaded';
                	messagesToUpdate.add(message);
                    gen.writeString(message.Message__c);

            	}
            }
            gen.writeEndArray();
            
        }
        gen.writeEndObject();
        gen.writeEndObject();
        gen.close();
        
        String jsonString = gen.getAsString();
        
        try{
            // Upload JSON
            if (!Test.isRunningTest()) {
                Decimal datasetId = getEinsteinDatasetId();
                if(datasetId == null){
                    Map<String, String> params = new Map<String, String>();
                    params.put('name', 'EinsteinDataset.json');
                    String result = LanguageController.createDataset(params, Blob.valueof(jsonString));
                }            	
        	}
            
            // Update uploaded records
            if (!keywordsToUpdate.isEmpty()) {
                update keywordsToUpdate;
            }
            if (!messagesToUpdate.isEmpty()) {
                update messagesToUpdate;
            }
            
        } catch (Exception e){
            return e.getMessage();
        }
        
        return null;
    }
    
    /********************************************************************************************************************************
    * @description Set keywords and messages uploadedToEinstein's field to false. 
    * This is necessary because if an upload fails the dataset remains unavailable and you have to delete it and create another one.
	* @return void
    * @example EinsteinUtils.resetEinstein();
    */
    public static void resetEinstein() {
        String status = 'Not Uploaded';
        List<Einstein_Keyword__c> keywords = [ SELECT Id, Uploaded_to_Einstein__c
                                              FROM Einstein_Keyword__c ];
        List<Einstein_Data_Message__c> messages = [ SELECT Id, Uploaded_to_Einstein__c
                                                   	FROM Einstein_Data_Message__c];
        if(!keywords.isEmpty()){
            for (Einstein_Keyword__c keyword: keywords) {
            	keyword.Einstein_Upload_Status__c = status;
        	}
            update keywords;
        }
        if(!messages.isEmpty()){
            for (Einstein_Data_Message__c message: messages) {
                message.Einstein_Upload_Status__c = status;
            }
            update messages;
        }      
        setEinsteinEnabled(false);
    }    
}