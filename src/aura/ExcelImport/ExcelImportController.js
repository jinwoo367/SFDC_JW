/**
 * Created by yr.lee on 2021-10-21.
 */

({
    init: function (cmp, event, helper) {
        helper.getData(cmp);
    },

    fnCheck : function(component, event, helper){
        console.log("선택");
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRows", selectedRows);
    },

    fnChange : function(component, event, helper){
        var options = component.get("v.options");
        var itemValue = event.getSource().get("v.value");
        console.log('itemValue ::' + itemValue);
        component.set("v.strSelectTargetObject", itemValue);
        component.set("v.strTemplateName", itemValue);
        component.set("v.data", []);
    },

    fnSave : function(component, event, helper){
        if (component.find("select").get("v.value") == '-') {
            helper.showToast("Error", "Object를 선택하세요.");
        }
        else if(component.get("v.data").length == 0){
            helper.showToast("Error", "데이터를 입력하세요.");
        }
        else{
            component.set("v.flagSaveStart", true);
            helper.fnThread(component, helper);
        }
    },

    fnExport : function(component, event, helper){
        if (component.find("select").get("v.value") == '-') {
            helper.showToast("Error", "Object를 선택하세요.");
        }
        else {
            helper.saveExcel(component, event, helper);
        }
    },

    handleSave : function(cmp, event, helper) {
        console.log('handleSave');
        cmp.set("v.toggleSpinner", true);
        helper.fnSaveAgain(cmp, event, helper);
        /*var action = cmp.get("c.doSave");
        action.setParams(
            {"listObject" : draftValues},
            {"strObject" : component.get("v.strTemplateName")}
        );
        action.setCallback(this, function(response) {
           var state = response.getState();
           var strRetrun = response.getReturnValue();
           *//*var dismissActionPanel = $A.get("e.force:closeQuickAction");
           dismissActionPanel.fire();*//*
           $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);*/
    }
});