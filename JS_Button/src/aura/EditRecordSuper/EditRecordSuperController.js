({
    setIdOfRecordToUpdate : function(component, event){
    	//You can use component.get("v.loadedRecord"); to get values from the record layout the button is in
        //Use component.set("v.idOfRecordToUpdate", someId); to specify the id of the record to edit
        var opportunity = component.get("v.loadedRecord");
        component.set("v.idOfRecordToUpdate", opportunity.Id);
    }
})