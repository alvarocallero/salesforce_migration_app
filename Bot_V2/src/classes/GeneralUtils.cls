public class GeneralUtils {
	
    public static final EmailTemplate EMAILTEMPLATE_BOTNOTIFICATION = [ SELECT Body, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Bot_Notification' ];
    public static Bot_Settings__c BOT_SETTINGS;
    
    private static final String BOT_SETTINGS_DEFAULTNAME = 'Default';
	
    // Use this if you need BOT_SETTINGS in a controller to avoid creating it or it will give this error: DML currently not allowed
    public static Boolean botSettingsExist() {
        return BOT_SETTINGS != null || getBotSettingsRecord() != null;
    }
    
    private static Bot_Settings__c getBotSettingsRecord() {
        return Bot_Settings__c.getValues(BOT_SETTINGS_DEFAULTNAME);
    }
    
    public static Bot_Settings__c getBotSettings() {
        if (BOT_SETTINGS == null) {
            BOT_SETTINGS = getBotSettingsRecord();
            if (BOT_SETTINGS == null) {
                BOT_SETTINGS = new Bot_Settings__c( Name = BOT_SETTINGS_DEFAULTNAME,
                                                    Einstein_Enabled__c = false,
                                                    Einstein_Token__c = '' );
                insert BOT_SETTINGS;
            }
        }
        return BOT_SETTINGS;
    }
    
    public static Bot_Notification__e getNewBotNotification(Id issueId, String issueName, String issueSummary, String issueSubscriberId) {
        return new Bot_Notification__e( Known_Issue_Id__c = issueId,
                                        Known_Issue_Name__c  = issueName,
                                        Known_Issue_Summary__c = issueSummary,
                                        Known_Issue_Subscriber__c = issueSubscriberId );
    }
    
    
    public static Messaging.SingleEmailMessage getNewBotNotificationEmail(Id issueId, String issueName, String issueSummary, String issueSubscriberId) {
        return getNewEmailMesage( new String[]{issueSubscriberId},
								  String.format( EMAILTEMPLATE_BOTNOTIFICATION.Subject, new String[]{issueName} ),
								  String.format( EMAILTEMPLATE_BOTNOTIFICATION.Body, new String[]{issueName, issueSummary} ),
								  String.format( EMAILTEMPLATE_BOTNOTIFICATION.HtmlValue, new String[]{issueName, issueSummary} ) );
    }
    
    
    public static Messaging.SingleEmailMessage getNewEmailMesage(String[] toAddresses, String subject, String plainTextBody,  String htmlBody) {
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		
        message.toAddresses = toAddresses;
        message.subject = subject;
        if (String.isNotBlank(plainTextBody)) {
            message.setPlainTextBody(plainTextBody);
        }
        if (String.isNotBlank(htmlBody)) {
            message.setHtmlBody(htmlBody);
        }
		
        return message;
        
    }
    
}