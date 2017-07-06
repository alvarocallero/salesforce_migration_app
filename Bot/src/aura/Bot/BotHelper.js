({
    submit : function(component, utterance, session, callback) {
        var action = component.get("c.submit");
        var currentUrl = decodeURIComponent(window.location.href);

        var messages = component.get("v.messages");
        var fileName = component.get("v.fileName");
        var attachmentURL = component.get("v.attachmentURL");
        var attachmentContent = component.get("v.attachmentContent");

        if(!$A.util.isEmpty(attachmentContent)){
          action = component.get("c.submitWithAttachment");
          messages.push({author: "Me", messageText: utterance, imageURL: attachmentURL});
          action.setParams({
                  "utterance": utterance,
                  "session": session,
                  "currentUrl": currentUrl,
                  "content" : attachmentContent,
                  "fileName" : fileName
          });
        }else{
          action.setParams({
              "utterance": utterance,
              "session": session,
              "currentUrl": currentUrl
          });
          messages.push({author: "Me", messageText: utterance});
        }

        component.set("v.fileName", "");
        component.set("v.attachmentURL", "");
        component.set("v.attachmentContent", "");
        component.set("v.messages", messages);

        var sentHistory = component.get("v.sentHistory");
        sentHistory.push(utterance);
        component.set("v.lastHistoryIndex", sentHistory.length - 1);

        //This function is not using the callback specified in the controller
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                callback(a.getReturnValue());
            } else if (state === "INCOMPLETE") {

            } else if (state === "ERROR") {
                var errors = a.getError();
                console.log(errors);
            }
      	});

        //action.setCallback(this, callback);
        $A.enqueueAction(action);
    },
    loadPreviousMessage: function(component){
        var sentHistory = component.get("v.sentHistory");
        var lastHistoryIndex = component.get("v.lastHistoryIndex");
        if(component.get("v.inputMessageValue") == ""){
            lastHistoryIndex = 0;
        }
        if(lastHistoryIndex < sentHistory.length && lastHistoryIndex >= 0){
            var messageToLoad = sentHistory[lastHistoryIndex];
            component.set("v.lastHistoryIndex", lastHistoryIndex-1);
            component.set("v.inputMessageValue", messageToLoad);
        }
    },
    loadNextMessage: function(component){
        var sentHistory = component.get("v.sentHistory");
        var lastHistoryIndex = component.get("v.lastHistoryIndex");
        if(lastHistoryIndex < sentHistory.length){
            var messageToLoad = sentHistory[lastHistoryIndex];
            component.set("v.lastHistoryIndex", lastHistoryIndex+1);
            component.set("v.inputMessageValue", messageToLoad);
        }
    }

})
