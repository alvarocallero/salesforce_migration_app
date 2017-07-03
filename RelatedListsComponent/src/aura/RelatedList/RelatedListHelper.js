({
	loadList : function(component, event, helper) {
		var action = component.get("c.listOfRelatedObjects");

        var objectId = component.get("v.recordId");
        var relationshipName = component.get("v.childObjectName");
        var numberOfSObjects = component.get("v.Quantity");
        var actualPageNumber = component.get("v.ActualPageNumber");
        action.setParams({  "parentObjectId":objectId,
                            "childObjectName": relationshipName,
                            "numberOfSObjects": numberOfSObjects,
                          	"actualPage":actualPageNumber
        });

        action.setCallback(this, function(response){
        	var state = response.getState();
            if(component.isValid() && state === "SUCCESS"){
                var wrapper = response.getReturnValue();
                component.set("v.pluralSObjectName", wrapper.relatedPluralName);
                component.set("v.listOfObjects", wrapper.relatedSObjects);
								var sObjectItem = component.get("v.listOfObjects")[0];
								if(!$A.util.isUndefinedOrNull(sObjectItem)){
									if($A.util.isUndefinedOrNull(sObjectItem.Name)){
										component.set("v.hasNameField", false);
									}

								}
								console.info('SOBJECT ---> ' + sObjectItem);
                var sObjectCount = wrapper.numberOfSObjects;
                var sObjectLimit = component.get("v.Quantity");
                if(sObjectLimit > 0){
 					var pageCount = Math.ceil(sObjectCount/sObjectLimit);
                    component.set("v.PageCount", pageCount);
                }
            }else{
                console.log('Error retrieving related objects: ', response.getError());
            }
        });
        $A.enqueueAction(action);
	}
})
