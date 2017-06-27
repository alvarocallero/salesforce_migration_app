({
	doInit : function(component, event, helper) {
		//controller function to get the list of sobject
		helper.loadComponent(component, event);
        var objectId = component.get("v.recordId");
        var newAction = component.get("c.returnAllRelationships");
        newAction.setParams({"parentObjectId":objectId});
        newAction.setCallback(this, function(r){
           var newState = r.getState();
            if(component.isValid() && newState === "SUCCESS"){
                component.set("v.listOfChildRelationhips", r.getReturnValue());
            }
        });
        $A.enqueueAction(newAction);

	},

	navigateToObjectPage : function (component, event, helper){
        var sObjectId = event.currentTarget.id;

        var navEvt = $A.get("e.force:navigateToSObject");
    	navEvt.setParams({
      		"recordId": sObjectId,
      		"slideDevName": "detail"
    	});
    	navEvt.fire();
    },

    changeRelationship : function (component, event, helper){
    	var selectValue = component.find("selectedRelation").get("v.value");
        console.info(selectValue);
        component.set("v.childObjectName", selectValue);
        helper.loadComponent(component, event);
    }
})
