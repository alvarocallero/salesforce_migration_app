({
    changeDefaultValues : function(component, event){
    	//You can use component.get("v.loadedRecord"); to get values from the record layout the button is in
        //Use component.set("v.defaultValues", { "field":"value"}); to specify the default fields
        var opportunity = component.get("v.loadedRecord");
        component.set("v.defaultValues", { "Subject":"Value from helper. Probability: "+ opportunity.Probability});
    }
})