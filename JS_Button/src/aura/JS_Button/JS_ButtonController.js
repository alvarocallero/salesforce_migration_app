({
	handleReady: function(component, event, helper){
			if (component.get('v.ready')){
				var gapType = component.get('v.GapType');
				helper.execute(gapType, component, event, helper);

				component.set('v.initialized', true);
			}
	},
	doInit : function(component, event, helper) {
		if (component.get('v.needsData') && !$A.util.isUndefinedOrNull(component.get('v.recordError'))){
			//recordData doesnt work with the current object, so we need to get the data from a controller
			var action = component.get("c.getObject");
			  action.setParams({
					recordId: component.get('v.recordId'),
					objectName: component.get('v.ObjectName'),
					fieldList: component.get('v.fieldList')
			  });
		      action.setCallback(this,function(response){
		            if (response.getState() === "SUCCESS"){
		            	component.set('v.loadedRecord',  response.getReturnValue());
		            	component.set('v.ready', true);
		            }
		      });
		      $A.enqueueAction(action);
		}else{
			component.set('v.loadedRecord',  component.get('v.simpleRecord'));
			component.set('v.ready', true);
		}

	},
	doneRendering: function(component, event, helper){
		if (component.get('v.initialized') === true){

			component.getEvent('closeActionEvent').fire();
		}
	}
})
