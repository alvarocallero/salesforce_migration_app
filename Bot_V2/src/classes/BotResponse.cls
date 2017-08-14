public class BotResponse {

    @AuraEnabled public List<BotMessage> messages { get; set; }
    @AuraEnabled public Map<String, String> session { get; set; }
    @AuraEnabled public List<Known_Issue__c> knownIssues {get; set;}
    @AuraEnabled public Id dataMessageId {get; set; }
    @AuraEnabled public Id knownIssueId {get; set;}
    
    
    public BotResponse() {
    }

    public BotResponse(BotMessage[] messages) {
        this.messages = messages;
    }

    public BotResponse(List<BotMessage> messages, Map<String, String> session) {
        this.messages = messages;
        this.session = session;
    }

    /**
     * Convenience constructor to create a response with a single message
     */
    public BotResponse(BotMessage message) {
        this.messages = new BotMessage[]{message};
    }
    
    public BotResponse(BotMessage message, Id dataMessageId, Id knownIssueId) {
        this.messages = new BotMessage[]{message};
        this.dataMessageId = dataMessageId; 
        this.knownIssueId = knownIssueId;
    }
    
    public BotResponse(BotMessage message, List<Known_Issue__c> knownIssues) {
        this.messages = new BotMessage[]{message};
        this.knownIssues = knownIssues;
    }

    /**
     * Convenience constructor to create a response with a single message
     */
    public BotResponse(BotMessage message, Map<String, String> session) {
        this.messages = new BotMessage[]{message};
        this.session = session;
    }
    
}