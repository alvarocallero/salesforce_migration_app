public class EinsteinUtils {
	
    public static final String KEYWORD_UNDEFINED = 'UNDEFINED';
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
    
	
    // MANAGE KEYWORDS AND MESSAGES
    
    public static Id getUndefinedKeywordId() {
        
        if (KEYWORD_ID_UNDEFINED == null){
            List<Einstein_Keyword__c> keywords = [ SELECT Id
                                                  FROM Einstein_Keyword__c
                                                  WHERE Name = :KEYWORD_UNDEFINED
                                                  LIMIT 1 ];
            if (keywords.isEmpty()){
                keywords.add(new Einstein_Keyword__c( Name = KEYWORD_UNDEFINED,
                                                      Uploaded_to_Einstein__c = false ));
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
                                                                     Uploaded_to_Einstein__c = false );
        
        insert msg;
        return msg.Id;
    }
    
    
    public static void associateMessageWithIssue(Id messageId, Id knownIssueId) {
        
        List<Einstein_Keyword__c> keywords = [ SELECT Id
                                               FROM Einstein_Keyword__c
                                               WHERE Id IN (SELECT Einstein_Keyword__c FROM Known_Issue__c WHERE Id = :knownIssueId ) ];
        
        List<Einstein_Data_Message__c> messages = [ SELECT Id,
                                                   		   Einstein_Keyword__c
                                                   	FROM Einstein_Data_Message__c
                                                    WHERE Id = :messageId ];
        if (!keywords.isEmpty() && !messages.isEmpty()) {
            messages[0].Einstein_Keyword__c = keywords[0].Id;
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
                                              		  Uploaded_to_Einstein__c,
                                              		  (SELECT Id,
                                                   			  Name,
                                                   		 	  Message__c,
                                                   		 	  Uploaded_to_Einstein__c
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
            
            if (keyword.Uploaded_to_Einstein__c != true) {
                keyword.Uploaded_to_Einstein__c = true;
                keywordsToUpdate.add(keyword);
            }
            
            gen.writeStartArray();
            
            // write each Message into JSON if it was never uploaded
            for (Einstein_Data_Message__c message: keyword.Einstein_Data_Messages__r) {
                if (message.Uploaded_to_Einstein__c != true) {
                	message.Uploaded_to_Einstein__c = true;
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
            	// ClassFromEmiliano.upload(jsonString); * TODO: replace this line... method should throw exception with message if it fails *
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
}