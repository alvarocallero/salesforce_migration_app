({
    doInit : function(component, event, helper){
        helper.loadRecord(component, event, helper);
    },
    doneRendering : function(component, event, helper){
        var componentReady = component.get("v.ready");
        if((componentReady=== true)){    
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
    }
    
})