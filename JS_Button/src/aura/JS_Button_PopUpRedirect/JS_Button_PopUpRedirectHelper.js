({
    execute : function(component, event, helper) {
        var gapOf = {};

        
        // YOUR CUSTOM LOGIC GOES HERE:
        gapOf.Opportunity_PopUpRedirect = function(component, event, helper){

            
            var url = "";
            var nameOfOpp = component.get('v.loadedRecord').Name;
            var recordId = component.get('v.loadedRecord').Id;
            $A.createComponent(
                "ui:outputText", {
                    'value': "This is the name of the Opportunity: " + nameOfOpp
                }, 
                function(newCmp){ 

                    if (component.isValid()) { 
                        
                        var body = component.get("v.body"); 
                        body.push(newCmp); 
                        component.set("v.body", body); 
                    }
                }
                
            ); 
            if (nameOfOpp){
                url = 'https://www.google.com.uy/search?q=' + nameOfOpp  
            } 
            component.set("v.urlToRedirect", url);
            
            
        }
            
            
            
            //DO NOT MODIFY THIS SECTION  ============================
            //This code executes the logic defined above
            var logicId = component.get("v.id");
            if(gapOf[logicId]){
                return gapOf[logicId](component, event, helper);
            }else {
                console.log('==== TBD JS_Button - CustomUrl id= '+component.get('v.id'));
            }
            //========================================================
        }
    }
})