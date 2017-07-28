({
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
            var utterance = event.target.value;
            var messages = component.get("v.messages");
            event.target.value = "";
            helper.submit(component, utterance, component.get('v.session'), function(answer) {
                if (answer) {
                    component.set("v.session", answer.session);
                    Array.prototype.push.apply(messages, answer.messages);
                    component.set("v.messages", messages);
                }
            });
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

    postbackButtonClickHandler : function(component, event, helper) {
        var utterance = event.getSource().get("v.label");
        var messages = component.get("v.messages");
        messages.push({author: "Me", messageText: utterance});
        component.set("v.messages", messages);
        helper.submit(component, utterance, component.get('v.session'), function(answer) {
            if (answer) {
                component.set("v.session", answer.session);
                Array.prototype.push.apply(messages, answer.messages);
                component.set("v.messages", messages);
            }
        });
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
