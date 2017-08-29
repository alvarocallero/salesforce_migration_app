public with sharing class HandlerGoodbye implements BotHandler {
	public BotResponse handle(String utterance, String[] params, Map<String, String> session) {
        return new BotResponse(new BotMessage('', 'Goodbye! See you later!'));
    }
}