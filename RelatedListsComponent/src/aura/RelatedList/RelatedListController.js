({
	doInit : function(component, event, helper) {
		helper.loadList(component, event, helper);
        
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
        helper.loadList(component, event, helper);
    },
    onNextPage : function (component, event, helper){
       	var actualPage = component.get("v.ActualPageNumber");
        var pageCount = component.get("v.PageCount");
        if(actualPage + 1 < pageCount){
            component.set("v.ActualPageNumber", actualPage + 1);
        	helper.loadList(component, event, helper);
        }
    },
    onPreviousPage : function(component, event, helper){
		var actualPage = component.get("v.ActualPageNumber");
        if(actualPage > 0){
            component.set("v.ActualPageNumber", actualPage - 1);
        	helper.loadList(component, event, helper);
        }
    }
})
