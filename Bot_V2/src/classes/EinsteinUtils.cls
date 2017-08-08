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
    
    
}