({
    loadRecord : function (component, event, helper){
        if (component.get('v.needsData') && !$A.util.isUndefinedOrNull(component.get('v.recordError'))){
        //TODO: Try to make it work with forceData    
        //if (component.get('v.needData')){
            //recordData doesnt work with the current object, so we need to get the data from a controller
            var action = component.get("c.getObject");
            action.setParams({
                recordId: component.get('v.recordId'),
                objectName: component.get('v.sObjectName'),
                fieldList: component.get('v.fieldList')
            });
            action.setCallback(this,function(response){
                if (response.getState() === "SUCCESS"){
                    component.set('v.loadedRecord',  response.getReturnValue());
                    helper.openCreateRecordModal(component, event, helper);    
                }
            });
            $A.enqueueAction(action);
        }else{
            component.set('v.loadedRecord',  component.get('v.simpleRecord'));
            helper.openCreateRecordModal(component, event, helper);
        }
        component.set('v.ready', true);
    },
    openCreateRecordModal : function(component, event, helper){
        component.set("v.createRecordModalLoaded", true);
        
        var subComponent = component.getConcreteComponent();
        if(subComponent.setRecordToEditId){
            subComponent.setRecordToEditId(component, event);
        }
        
        var recordToEditId = component.get("v.recordToEditId");
        
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordToEditId
        }).fire();
    }
})