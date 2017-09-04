({
	doInit : function(component, event, helper) {
        var action = component.get("c.attachmentDetails");
        action.setParams({
            "knownIssueId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                component.set("v.attachmentDetails",  response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    }
	}
})