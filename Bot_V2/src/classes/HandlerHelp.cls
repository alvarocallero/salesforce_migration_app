public with sharing class HandlerHelp implements BotHandler {
    
     public BotResponse handle(String utterance, String[] params, Map<String, String> session) {
        return new BotResponse(new BotMessage('', 'Need help? Remember to start your feedback with the word <strong>\"Error\"</strong> and I\'ll try to find your problem. ' + '<br/>' + 'I may provide some helpful information if you start your sentence with the word '+
                     '<strong>\"Train\"</strong>.'));
    }
    
}