({

    onCometdLoaded : function(component, event, helper) {
  		var cometd = new org.cometd.CometD();
  		component.set('v.cometd', cometd);
  		if (component.get('v.sessionId') != null)
    		helper.connectCometd(component);
		},

    doInit : function(component, event, helper){
        var action = component.get("c.userInfo");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                var information = response.getReturnValue();
                component.set("v.userInfo", information);

                var messages = component.get("v.messages");
                messages.push({author: "Leah", messageText: information[2]});
                messages.push({author: "Leah", messageText: information[3]});
                component.set("v.messages", messages);

            }
        });

        $A.enqueueAction(action);

        component.set('v.cometdSubscriptions', []);

  		// Disconnect CometD when leaving page
  		window.addEventListener('unload', function(event) {
    		helper.disconnectCometd(component);
  		});

  		// Retrieve session id
  		var action2 = component.get('c.getSessionId');
  		action2.setCallback(this, function(response) {
    		if (component.isValid() && response.getState() === 'SUCCESS') {
      			component.set('v.sessionId', response.getReturnValue());
      			if (component.get('v.cometd') != null)
        			helper.connectCometd(component);
    		}
    		else
      			console.error(response);
  		});
  		$A.enqueueAction(action2);

    },


    handleClickSubmit : function (component, event, helper){
       var inputMessage = component.get("v.inputMessageValue");
       component.set("v.inputMessageValue", "");
       var messages = component.get("v.messages");
       helper.submit(component, inputMessage, component.get('v.session'), function(answer) {
                if (answer) {
                    component.set("v.session", answer.session);
                    Array.prototype.push.apply(messages, answer.messages);
                    component.set("v.messages", messages);

                }
            });
    },

    utteranceHandler : function(component, event, helper) {
        if (event.keyCode === 13) {
            var spinnerDiv = component.find("spinnerDiv");
            $A.util.removeClass(spinnerDiv, "slds-hidden");
            var utterance = event.target.value;
            var messages = component.get("v.messages");
            event.target.value = "";
            component.set("v.placeholderText", "Leah is processing your input...");
            window.setTimeout(
    			$A.getCallback(function() {
        			component.set("v.placeholderText", "Leah is typing...");
    			}), 2000
			);
             helper.submit(component, utterance, component.get('v.session'), function(answer) {
                		if (answer) {

                            $A.util.addClass(spinnerDiv, "slds-hidden");

                            component.set("v.placeholderText", "Provide feedback...");
                    		component.set("v.dataMessageId", answer.dataMessageId);
                    		component.set("v.session", answer.session);
                    		Array.prototype.push.apply(messages, answer.messages);
                            component.set("v.CurrentKnownIssueId", answer.knownIssueId);
                    		component.set("v.messages", messages);
                            component.set("v.fileName", "");
        					component.set("v.attachmentURL", "");
        					component.set("v.attachmentContent", "");
        					component.set("v.files", null);
                		}
             });
        }

    },

    postbackButtonClickHandler : function(component, event, helper) {
        var utterance = event.getSource().get("v.name");
        var btn = event.getSource();
        btn.set("v.disabled", true);
        var messages = component.get("v.messages");
        var spinnerDiv = component.find("spinnerDiv");
        $A.util.removeClass(spinnerDiv, "slds-hidden");

        switch(utterance){
            case 'helpful':
                component.set("v.placeholderText", "Leah is typing...");
                window.setTimeout(
    				$A.getCallback(function() {
        				component.set("v.placeholderText", "Provide feedback...");
                        $A.util.addClass(spinnerDiv, "slds-hidden");
                        messages.push({author: "Leah", messageText: 'Glad you found what you were looking for!'});
        				component.set("v.messages", messages);
    				}), 1500
				);

                component.set("v.fileName", "");
        		component.set("v.attachmentURL", "");
        		component.set("v.attachmentContent", "");
        		component.set("v.files", null);

                break;

            case 'useless':
            var dataMessageId = component.get("v.dataMessageId");
            component.set("v.placeholderText", "Leah is creating a new Issue...");

            helper.createNewIssue(component, dataMessageId, function(answer){
                if(answer){
                    component.set("v.placeholderText", "Provide feedback...");
                    component.set("v.CurrentKnownIssueId", answer.knownIssueId);
                    $A.util.addClass(spinnerDiv, "slds-hidden");
                    Array.prototype.push.apply(messages, answer.messages);
                    component.set("v.messages", messages);
                }
            });
                break;

            case 'trainHelpful':

                component.set("v.placeholderText", "Leah is typing...");
                window.setTimeout(
    				$A.getCallback(function() {
        				component.set("v.placeholderText", "Provide feedback...");
                        $A.util.addClass(spinnerDiv, "slds-hidden");
                        messages.push({author: "Leah", messageText: 'Glad you found what you were looking for!'});
        				component.set("v.messages", messages);
    				}), 1500
				);

                break;

            case 'trainUseless':
                var dataMessageId = component.get("v.dataMessageId");
            	component.set("v.placeholderText", "Leah is creating a new Issue...");

            	helper.createNewIssue(component, dataMessageId, function(answer){
                if(answer){
                    component.set("v.placeholderText", "Provide feedback...");
                    component.set("v.CurrentKnownIssueId", answer.knownIssueId);
                    $A.util.addClass(spinnerDiv, "slds-hidden");
                    Array.prototype.push.apply(messages, answer.messages);
                    component.set("v.messages", messages);
                }
            });
                break;


            default:
            component.set("v.placeholderText", "Leah is working on your subscription...");
            var currentKnownIssueId = component.get("v.CurrentKnownIssueId");
                helper.subscribeUserToIssue(component, currentKnownIssueId, function(answer){
                    if(answer){
                        component.set("v.placeholderText", "Provide feedback...");
                        $A.util.addClass(spinnerDiv, "slds-hidden");
						Array.prototype.push.apply(messages, answer.messages);
                    	component.set("v.messages", messages);
                    }
                });
                break;
        }


    },

    keyDownHandler : function(component, event, helper){
        var keyUpCode = 38;
        var keyDownCode = 40;
        var keyPressed = event.keyCode;
        switch(keyPressed){
            case keyUpCode:
                helper.loadPreviousMessage(component);
                break;
            case keyDownCode:
                helper.loadNextMessage(component);
                break;
            default:
                break;
        }
    },


    detachFile : function(component, event, helper){
      component.set("v.booleanFlag", false);

      component.set("v.files", [])
      component.set("v.attachmentURL", "");
      component.set("v.attachmentContent", null);
      component.set("v.fileName", "");
      component.set("v.booleanFlag", true);
    },

    loadFile: function(component, event, helper) {
        var files = event.getSource().get("v.files");

        if (files && files.length > 0) {
            var file = files[0][0];
            if(file){
                if (!file.type.match(/(image.*)/)) {
                    return;
                }
                var reader = new FileReader();
                reader.onloadend = function() {
                    var dataURL = reader.result;
                    var content = dataURL.match(/,(.*)$/)[1];
                    component.set("v.fileName", file.name);
                    component.set("v.attachmentURL", dataURL);
                    component.set("v.attachmentContent", content);
                };
                reader.readAsDataURL(file);
            }
        }
    }
})
