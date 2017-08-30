public with sharing class HandlerThanks implements BotHandler{
	public BotResponse handle(String utterance, String[] params, Map<String, String> session) {
        return new BotResponse(new BotMessage('', 'You are welcome! I am happy to help!'));
    }
}