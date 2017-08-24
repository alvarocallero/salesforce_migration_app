({
	doInit : function(component, event, helper) {
		helper.loadList(component, event, helper);
        
        var objectId = component.get("v.recordId");
        var newAction = component.get("c.returnAllRelationships");
        newAction.setParams({"parentObjectId":objectId});
        newAction.setCallback(this, function(r){
           var newState = r.getState();
            if(component.isValid() && newState === "SUCCESS"){
                
                var childRelationshipsMap = r.getReturnValue();
                var opt = new Array();
				
                opt.push({text:"", label: "Change Relationship..."});
                for(var key in childRelationshipsMap) {
                    opt.push({label: childRelationshipsMap[key],
                                                     value: key});
                }

                if(component.find("selectedRelation")){
                    component.find("selectedRelation").set("v.options", opt);
                }
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
    },
    handleMouseEnter : function(component, event, helper) {
        var popover = component.find("popover");
		$A.util.removeClass(popover,'slds-hide');
        var targetRecordId = event.target.id;
        component.set("v.popoverTargetRecordId", targetRecordId);
        window.setTimeout(
            $A.getCallback(function() { 
        		
                popover.getElement().style.left = event.clientX -20 + "px";
                popover.getElement().style.top = document.body.scrollTop + event.clientY -300 +"px"
                
            }), 1000
        );
    },
    handleMouseOut : function(component, event, helper) {
        var popover = component.find("popover");
        
        component.set("v.recordIdToPreview", );
        $A.util.addClass(popover,'slds-hide');
    }
})