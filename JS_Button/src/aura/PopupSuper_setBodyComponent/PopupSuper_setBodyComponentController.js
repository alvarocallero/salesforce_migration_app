({
	setBodyComponent: function (component, event) {
		var nameOfOpp = component.get('v.loadedRecord').Name;
		var recordId = component.get('v.loadedRecord').Id;
		$A.createComponent(
			"ui:outputText", {
				'value': "This is the name of the Opportunity: " + nameOfOpp + "; And the Id is: " + recordId
			},
			function (newCmp) {
				//Add the field list to the body array 
				if (component.isValid()) {

					var body = component.get("v.body");
					body.push(newCmp);
					component.set("v.body", body);
				}
			}

		);
	}
})