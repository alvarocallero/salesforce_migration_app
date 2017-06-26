({
	doInit : function(component, event, helper) {
		//controller function to get the list of sobject
		var action = component.get("c.listOfRelatedObjects");
        
        var objectId = component.get("v.recordId");
        var relationshipName = component.get("v.childObjectName");
        var numberOfSObjects = component.get("v.Quantity");
        
        action.setParams({  "parentObjectId":objectId, 
                            "childObjectName": relationshipName,
                            "numberOfSObjects": numberOfSObjects
        });
        
        action.setCallback(this, function(response){
           var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                var wrapper = response.getReturnValue();
                component.set("v.pluralSObjectName", wrapper.relatedPluralName);
                component.set("v.listOfObjects", wrapper.relatedSObjects);
            }else{
                console.log('Error -->', response);
            }
        });
        
        $A.enqueueAction(action);
        
	},
	navigateToObjectPage : function (component, event, helper){
        var sObjectId = event.currentTarget.id;
        
        var navEvt = $A.get("e.force:navigateToSObject");
    	navEvt.setParams({
      		"recordId": sObjectId,
      		"slideDevName": "detail"
    	});
    	navEvt.fire();
    }
})