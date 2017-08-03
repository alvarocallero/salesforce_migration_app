({
    doInit: function (component, event, helper) {
        if (component.get('v.needsData')) {
            //First try to use fore:recordData to load the record
            if ($A.util.isUndefinedOrNull(component.get('v.recordError'))) {
                component.set('v.loadedRecord', component.get('v.simpleRecord'));
                helper.execute(component, event, helper);
            } else {
                //If force:recordData does not work, we retrieve the object from the controller
                var action = component.get("c.getObject");
                action.setParams({
                    recordId: component.get('v.recordId'),
                    objectName: component.get('v.sObjectName'),
                    fieldList: component.get('v.fieldList')
                });
                action.setCallback(this, function (response) {
                    if (response.getState() === "SUCCESS") {
                        component.set('v.loadedRecord', response.getReturnValue());
                        helper.execute(component, event, helper);
                    }else{
                        //Handle error
                        console.log(response);
                        component.set('v.ready', true);
                    }
                });
                $A.enqueueAction(action);
            }
        } else {
            helper.execute(component, event, helper);
        }
    },
    doneRendering: function (component, event, helper) {
        var componentReady = component.get("v.ready");
        if ((componentReady === true)) {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
    },
    handleCancel : function(component, event, helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    handleRedirect : function(component, event, helper){
        helper.superFireRedirect(component, event, helper);
    }

})