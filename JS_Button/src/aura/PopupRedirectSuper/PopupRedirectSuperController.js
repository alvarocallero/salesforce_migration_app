({
	setBodyComponent: function (component, event) {
		var url = "https://login.salesforce.com";
		$A.createComponent(
			"ui:outputText", {
				'value': "You will be redirected to " + url
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
		//You can use setRedirectUrl instead of setting the url here
		component.set("v.redirectURL", url);
	}
})