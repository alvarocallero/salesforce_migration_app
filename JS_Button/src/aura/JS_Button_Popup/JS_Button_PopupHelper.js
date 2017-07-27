({
    execute : function(component, event, helper) {
        var gap = {};
        
        // YOUR CUSTOM LOGIC GOES HERE:
        

            gap.Opportunity_ConditionalPopUp = function(component, event, helper){
                var nameOfOpp = component.get('v.loadedRecord').Name;
                var recordId = component.get('v.loadedRecord').Id;
                $A.createComponent(
                    "ui:outputText", {
                        'value': "This is the name of the Opportunity: " + nameOfOpp +"; And the Id is: "+ recordId
                    }, 
                    function(newCmp){ 
                        //Add the field list to the body array 
                        if (component.isValid()) { 
                            
                            var body = component.get("v.body"); 
                            body.push(newCmp); 
                            component.set("v.body", body); 
                        }
                    }
                    
                );        
            }
        
        
        
        
        //DO NOT MODIFY THIS SECTION  ============================
        //This code executes the logic defined above
        var logicId = component.get("v.id");
        if(gap[logicId]){
            return gap[logicId](component, event, helper);
        }else {
            console.log('==== TBD JS_Button - CustomUrl id= '+component.get('v.id'));
        }
        //========================================================
    }
})