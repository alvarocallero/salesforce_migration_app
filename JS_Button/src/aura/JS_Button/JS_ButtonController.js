({
	handleReady: function(component, event, helper){
			if (component.get('v.ready')){
				var gapType = component.get('v.GapType');
				helper.execute(gapType, component, event, helper);

				component.set('v.initialized', true);
			}
	},
	handleReadyDeprecated: function(component, event, helper){
		if (component.get('v.ready')){
			console.log('====== recordId = ', component.get('v.recordId'));
			console.log('====== loadedRecord = ', component.get('v.loadedRecord'));

			if (component.get('v.GapType') == 'CustomUrl'){
				if (component.get('v.id') == 'default'){

	/* THIS IS THE DEFAULT EXAMPLE SOLUTION FOR THIS TYPE OF GAP, DO NOT REMOVE!
	/* ADD THE NEEDED CODE FOR THE DEFINED ID
	*/
					var urlEvent;
	/*
	 * This example redirect to a static url
	*/
					urlEvent = $A.get("e.force:navigateToURL");
				    urlEvent.setParams({
				      "url": 'https://www.google.com'
				    });
				    urlEvent.fire();
	/*
	 * This example navigates a user to the opportunity page, /006/o, using a relative URL.
	 */
					urlEvent = $A.get("e.force:navigateToURL");
				    urlEvent.setParams({
				      "url": "/006/o"
				    });
				    urlEvent.fire();

	/*
	* This example opens an external website when the link is clicked.
	*/

				    var address = 'the address';

				    urlEvent = $A.get("e.force:navigateToURL");
				    urlEvent.setParams({
				      "url": 'https://www.google.com/maps/place/' + address
				    });
				    urlEvent.fire();


				}else if (component.get('v.id') == 'Opportunity_CustomUrl'){
					var urlEvent = $A.get("e.force:navigateToURL");
				    urlEvent.setParams({
				      "url": 'https://www.google.com'
				    });
				    urlEvent.fire();
				}else{
					console.log('==== TBD JS_Button - CustomUrl id= '+component.get('v.id'));
				}
			}else if (component.get('v.GapType') == 'ConditionalRedirect'){
			}else{
				console.log('==== TBD JS_Button - GapType = '+component.get('v.GapType'));
			}

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
