({
	submit : function(component, utterance, session, callback) {
        var action = component.get("c.submit");
		var currentUrl = decodeURIComponent(window.location.href);
        console.log("Current Url ->---->",currentUrl);
        action.setParams({
      		"utterance": utterance,
            "session": session,
            "currentUrl": currentUrl
    	});
        var sentHistory = component.get("v.sentHistory");
        
		sentHistory.push(utterance);
        component.set("v.lastHistoryIndex", sentHistory.length - 1);
        
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
    	$A.enqueueAction(action);
	},
    
	upload: function(component, file, base64Data, callback) {
        var action = component.get("c.upload"); 
        action.setParams({
            fileName: file.name,
            content: base64Data
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
	            callback(a.getReturnValue());
            } else if (state === 'ERROR') {
	            var errors = a.getError();
                console.log(errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else if (state === "INCOMPLETE") {
				console.log("Incomplete");
            }

        });
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