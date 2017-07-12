({
	execute : function(gapType, component, event, helper) {
		var gapOf = {};

		// YOUR CUSTOM LOGIC GOES HERE:


		gapOf.CustomUrl =  {
			default : function(component, event, helper){
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
			},
			Opportunity_CustomUrl : function(component, event, helper){
				console.log("Custom Url Excecuted");
				var urlEvent = $A.get("e.force:navigateToURL");
					urlEvent.setParams({
						"url": 'https://www.google.com/changed'
					});
					urlEvent.fire();
			}

		};

		gapOf.ConditionalRedirect = {
			default : function(component, event, helper){
				/* THIS IS THE DEFAULT EXAMPLE SOLUTION FOR THIS TYPE OF GAP, DO NOT REMOVE!
						        /* ADD THE NEEDED CODE FOR THE DEFINED ID
						        */
						        var urlEvent;
						        /*
						         * This example redirect to a static url
						        */
						        urlEvent = $A.get("e.force:navigateToURL");
										var url = '';
										if (component.get('v.loadedRecord').Probability > 50){
						            url = 'https://www.google.com.uy/search?q=win' + component.get('v.loadedRecord').Id;
						        }else{
						            url = 'https://www.google.com.uy/search?q=probability' + component.get('v.loadedRecord').Probability;
						        }
						         urlEvent.setParams({
						             "url": url
						         });
						         urlEvent.fire();
			},
			Opportunity_ConditionalRedirect : function(component, event, helper){
						        var urlEvent;
						        urlEvent = $A.get("e.force:navigateToURL");
										var url = '';
										var probability = component.get('v.loadedRecord').Probability;
										var recordId = component.get('v.loadedRecord').Id;
						        if (probability > 50){
						            url = 'https://www.google.com.uy/search?q=win' + recordId;
						        }else{
						            url = 'https://www.google.com.uy/search?q=probability' + probability;
						        }
						         urlEvent.setParams({
						             "url": url
						         });
						         urlEvent.fire();
			}
		};

		//DO NOT MODIFY THIS SECTION  ============================
		//This code executes the logic defined above
		var logicId = component.get("v.id");
		if(gapOf[gapType] && gapOf[gapType][logicId]){
				return gapOf[gapType][logicId](component, event, helper);
		}else {
			console.log('==== TBD JS_Button - CustomUrl id= '+component.get('v.id'));
		}
		//========================================================
	}
})
