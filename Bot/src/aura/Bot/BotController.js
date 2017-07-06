({
	doInit : function(component, event, helper){
    	var action = component.get("c.userInfo");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){


								component.set("v.userInfo",  response.getReturnValue());
								var information = component.get("v.userInfo");

								var name = information[1];
								var messages = component.get("v.messages");
								messages.push({author: "AltiBot v1", messageText: "Welcome " + name +  ", how can I help you?"});
								component.set("v.messages", messages);

            }
        });
        $A.enqueueAction(action);



    },

	utteranceHandler : function(component, event, helper) {
        if (event.keyCode == 13) {
            var utterance = event.target.value;
						var messages = component.get("v.messages");
            event.target.value = "";
            helper.submit(component, utterance, component.get('v.session'), function(answer) {
                if (answer) {
                    console.log(answer);
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
      }
	},
  postbackButtonClickHandler : function(component, event, helper) {
  	var utterance = event.getSource().get("v.label");
		var messages = component.get("v.messages");
		messages.push({author: "Me", messageText: utterance});
        component.set("v.messages", messages);
        helper.submit(component, utterance, component.get('v.session'), function(answer) {
            if (answer) {
                console.log(answer);
                component.set("v.session", answer.session);
                Array.prototype.push.apply(messages, answer.messages);
                component.set("v.messages", messages);
            }
        });
    },

		loadFile: function(component, event, helper) {
		  var files = component.get("v.files");
		  if (files && files.length > 0) {
		    var file = files[0][0];
				component.set("v.attachment", file);
		    if (!file.type.match(/(image.*)/)) {
		        return alert('Image file not supported');
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
})
