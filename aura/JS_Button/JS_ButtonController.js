({
	
	doInit : function(component, event, helper) {
		
		if (component.get('v.GapType') == 'CustomUrl'){
			if (component.get('v.id') == 'default'){
/* THIS IS THE DEFAULT EXAMPLE SOLUTION FOR THIS TYPE OF GAP, DO NOT REMOVE!
/* ADD THE NEEDED CODE FOR THE DEFINED ID
*/
				var urlEvent;
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

/*
* This is to close the action
*/
			    component.getEvent('closeActionEvent').fire();
			    
			}else if (component.get('v.id') == 'Opportunity_CustomUrl'){
				var urlEvent = $A.get("e.force:navigateToURL");
			    urlEvent.setParams({
			      "url": 'https://www.google.com'
			    });
			    urlEvent.fire();
			}else{
				console.log('==== TBD JS_Button - CustomUrl id= '+component.get('v.id'));
			}
		}else{
			console.log('==== TBD JS_Button - GapType = '+component.get('v.GapType'));
		}
		
		component.set('v.initialized', true);
	},
	doneRendering: function(component, event, helper){
		if (component.get('v.initialized') === true){
			component.getEvent('closeActionEvent').fire();
		}
	}
})