({
    execute: function (component, event, helper) {
        var gapType = component.get("v.gapType");
        switch (gapType) {
            case "CustomUrl":
            case "ConditionalRedirect":
                component.set("v.ready", true);
                helper.superSetRedirectUrl(component, event, helper);
                helper.superFireRedirect(component, event, helper);
                break;
            case "CreateRecord":
                component.set("v.ready", true);
                helper.openCreateRecordModal(component, event, helper);
                break;
            case "EditRecord":
                component.set("v.ready", true);
                helper.openEditRecordModal(component, event, helper);
                break;
            case "Popup":
                helper.superLoadBodyComponent(component, event, helper);
                break;
            case "PopupRedirect":
                helper.superLoadBodyComponent(component, event, helper);
                helper.superSetRedirectUrl(component, event, helper);
                break;
            default:
                break;
        }
    },
    openCreateRecordModal : function(component, event, helper){
        component.set("v.createRecordModalLoaded", true);
        
        var subComponent = component.getConcreteComponent();
        if(subComponent.changeDefaultValues){
            subComponent.changeDefaultValues(component, event);
        }
        
        var newRecordApiName = component.get("v.newRecordApiName");
        var defaultValues = component.get("v.defaultValues");
        
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": newRecordApiName,
            "defaultFieldValues": defaultValues
        }).fire();
    },
    openEditRecordModal : function(component, event, helper){
        component.set("v.createRecordModalLoaded", true);
        
        var subComponent = component.getConcreteComponent();
        if(subComponent.setIdOfRecordToUpdate){
            subComponent.setIdOfRecordToUpdate(component, event);
        }
        
        var idOfRecordToUpdate = component.get("v.idOfRecordToUpdate");
        
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": idOfRecordToUpdate
        }).fire();
    },
    superSetRedirectUrl : function(component, event, helper){
        var subComponent = component.getConcreteComponent();
        if(subComponent.setRedirectUrl){
            subComponent.setRedirectUrl(component, event);
        }
    },
    superFireRedirect : function(component, event, helper){
        var url = component.get("v.redirectURL");
        if(!$A.util.isEmpty(url)){
            var eventRedirect = $A.get("e.force:navigateToURL");
            eventRedirect.setParams({
                "url": url
            }).fire();   
        }
    },
    superLoadBodyComponent : function(component, event, helper){
        var subComponent = component.getConcreteComponent();
        if(subComponent.setBodyComponent){
            subComponent.setBodyComponent(component, event);
            component.set("v.body", subComponent.get("v.body"));
        }
    }
    
})