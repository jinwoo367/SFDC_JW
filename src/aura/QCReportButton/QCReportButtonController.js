/**
 * Created by JWJANG on 2023-01-27.
 */

({
    fnInit : function(component, event, helper) {
        console.log("recordId : ", component.get("v.recordId"));
        component.set("v.vfPageUrl" , "/apex/QCReportPage?recordId=" + component.get("v.recordId"));
    },

    fnSave : function(component, event, helper) {
        helper.savePdf(component, event);
        $A.get("e.force:closeQuickAction").fire();
        $A.get("e.force:refreshView").fire();
    },

    fnCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
});