({
	execute : function(gapType, component, event, helper) {
		var gapOf = {};

		// YOUR CUSTOM LOGIC GOES HERE:
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
						        if (component.get('v.loadedRecord').Percentage > 50){
						            url = ;
						        }else{
						            url = ;
						        }
						         urlEvent.setParams({
						             "url": url
						         });
						         urlEvent.fire();
			}
		};

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
						"url": 'https://www.google.com'
					});
					urlEvent.fire();
			}

		};

		gapOf.PrepopulateCreation = {
			default : function(component, event, helper){
				var contactId = component.get("v.recordID");
				var action = component.get("c.getContactDetails");
				action.setParams({"contactId":contactId});
				action.setCallback(this, function(data){
					var state = data.getState();

					component.set("v.contact", data.getReturnValue());
					var vContact = component.get("v.contact");
					var createRecordEvent = $A.get("e.force:createRecord");

					createRecordEvent.setParams({
						"entityApiName" : "Opportunity",
						"defaultFieldValues":{
							"CloseDate":threemonth,
							"AccountId":vContact.AccountId
						}
					})
				});
			}


		};

		gapOf.PrepopulateUpdate = {

		};

		//DO NOT MODIFY THIS SECTION  ============================
		//This code executes the logic defined above
		var logicId = component.get("v.id");
		if(gapOf[gapType][logicId]){
				return gapOf[gapType][logicId](component, event, helper);
		}else {
			console.log('==== TBD JS_Button - CustomUrl id= '+component.get('v.id'));
		}
		//========================================================
	}
})
