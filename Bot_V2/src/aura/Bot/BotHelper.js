({
    submit : function(component, utterance, session, callback) {
        var action = component.get("c.submit");
        var currentUrl = decodeURIComponent(window.location.href);
        var attachmentURL = component.get("v.attachmentURL");

        var messages = component.get("v.messages");
          action.setParams({
              "utterance": utterance,
              "session": session,
              "currentUrl": currentUrl
          });
          messages.push({author: "Me", messageText: utterance, imageURL: attachmentURL});
        

        /*component.set("v.fileName", "");
        component.set("v.attachmentURL", "");
        component.set("v.attachmentContent", "");
        component.set("v.files", null);*/
      
        component.set("v.messages", messages);

        var sentHistory = component.get("v.sentHistory");
        sentHistory.push(utterance);
        component.set("v.lastHistoryIndex", sentHistory.length - 1);

        //This function is not using the callback specified in the controller
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                window.setTimeout(
    			$A.getCallback(function() {
                    callback(a.getReturnValue());
        			component.set("v.placeholderText", "Provide feedback...");
    			}), 2500
			);
                
            } else if (state === "INCOMPLETE") {

            } else if (state === "ERROR") {
                var errors = a.getError();
            }
      	});

        //action.setCallback(this, callback);
        $A.enqueueAction(action);
    },
    
    createNewIssue : function (component, dataMessageId, callback){
    	var action = component.get("c.addNewKnownIssue");
        var url = decodeURIComponent(window.location.href);
        
        var fileName = component.get("v.fileName");
        var attachmentURL = component.get("v.attachmentURL");
        var attachmentContent = component.get("v.attachmentContent");
        
        action.setParams({
            "dataMessageId" : dataMessageId,
            "currentUrl" : url,
            "content" : attachmentContent,
            "fileName" : fileName
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") { 
                window.setTimeout(
    			$A.getCallback(function() {
                    callback(a.getReturnValue());
    			}), 2500
			);
            } else if (state === "INCOMPLETE") {

            } else if (state === "ERROR") {
                var errors = a.getError();
            }
      	});
        
        component.set("v.fileName", "");
        component.set("v.attachmentURL", "");
        component.set("v.attachmentContent", "");
        component.set("v.files", null);

        //action.setCallback(this, callback);
        $A.enqueueAction(action);
        
    },
    
    subscribeUserToIssue : function(component, CurrentKnownIssueId, callback){
      
        var action = component.get("c.subscribeUserToIssue");
        
        action.setParams({
            "knownIssueId" : CurrentKnownIssueId,
            "userId" : component.get("v.userInfo")[4],
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                window.setTimeout(
    			$A.getCallback(function() {
                    callback(a.getReturnValue());
    			}), 2500
			);
            } else if (state === "INCOMPLETE") {

            } else if (state === "ERROR") {
                var errors = a.getError();
            }
      	});
        
        $A.enqueueAction(action);
    },
    
    loadPreviousMessage: function(component){
        var sentHistory = component.get("v.sentHistory");
        var lastHistoryIndex = component.get("v.lastHistoryIndex");
        if(component.get("v.inputMessageValue") === ""){
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
    },
    
  connectCometd : function(component) {
    var helper = this;

    // Configure CometD
    var cometdUrl = window.location.protocol+'//'+window.location.hostname+'/cometd/40.0/';
    var cometd = component.get('v.cometd');
    cometd.configure({
      url: cometdUrl,
      requestHeaders: { Authorization: 'OAuth '+ component.get('v.sessionId')},
      appendMessageTypeToURL : false
    });
      
    cometd.websocketEnabled = false;

    // Establish CometD connection
    console.log('Connecting to CometD: '+ cometdUrl);
    cometd.handshake(function(handshakeReply) {
      if (handshakeReply.successful) {
        console.log('Connected to CometD.');
        // Subscribe to platform event
        var newSubscription = cometd.subscribe('/event/Bot_Notification__e',
          function(platformEvent) {
            console.log('Platform event received: ' + JSON.stringify(platformEvent)); 
              if(component.get('v.userInfo')[4] === platformEvent.data.payload.Known_Issue_Subscriber__c){
                  helper.onReceiveNotification(component, platformEvent);
              }
          }
        );
        // Save subscription for later
        var subscriptions = component.get('v.cometdSubscriptions');
        subscriptions.push(newSubscription);
        component.set('v.cometdSubscriptions', subscriptions);
      }
      else
        console.error('Failed to connected to CometD.');
    });
      },

  disconnectCometd : function(component) {
    var cometd = component.get('v.cometd');

    // Unsuscribe all CometD subscriptions
    cometd.batch(function() {
      var subscriptions = component.get('v.cometdSubscriptions');
      subscriptions.forEach(function (subscription) {
        cometd.unsubscribe(subscription);
      });
    });
    component.set('v.cometdSubscriptions', []);

    // Disconnect CometD
    cometd.disconnect();
    console.log('CometD disconnected.');
  },

  onReceiveNotification : function(component, platformEvent) {
    var helper = this;
    if (!component.get('v.isMuted'))
      helper.displayToast(component, 'success', platformEvent);
  },

  displayToast : function(component, type, platformEvent) {
    
    var messages = component.get("v.messages");
    messages.push({author: "Leah", messageText: "Good news! The Issue " + platformEvent.data.payload.Known_Issue_Name__c + " has been fixed!"});
    component.set("v.messages", messages);
    var toastEvent = $A.get('e.force:showToast');
    toastEvent.setParams({
        "mode":"sticky",
      	"type" : type,
        "title": "Notification alert! Issue: " + "\"" + platformEvent.data.payload.Known_Issue_Name__c + "\"" + " FIXED!",
        "message" : "SUMMARY: " + platformEvent.data.payload.Known_Issue_Summary__c
        
    });
    toastEvent.fire();
  }

    
    
    
    

})