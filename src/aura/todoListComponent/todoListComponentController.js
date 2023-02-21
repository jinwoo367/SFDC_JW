/**
 * Created by JWJANG on 2023-01-03.
 */

({
    fnInit : function(component, event, helper) {
        // Default 날짜 설정
        var today = new Date();
        var year = today.getFullYear();
        var month = (today.getMonth() + 1) < 10 ? "0" + (today.getMonth() + 1) : (today.getMonth() + 1).toString();
        var day = today.getDate() < 10 ? "0" + (today.getDate()) : (today.getDate()).toString();

        var todayStr = year + "-" + month + "-" + day;
        component.set("v.searchDate", todayStr);
        console.log('fnInit : \'' + todayStr + '\'');

        helper.getInitData(component);
    },

    fnSearch : function(component, event, helper) {
        console.log("fnSearch");

        helper.searchList(component);
    },

    changeCondition : function(component, event, helper) {
        var selectedStage = component.find("selCondition").get("v.value");
        component.set("v.searchCondition", selectedStage);
    },

    clickMarker : function(component, event, helper) {
        var recId = event.target.closest("[data-id]").dataset.id;
        console.log("click Marker record ID : " + recId);

        // Marker 적용
        var param = {
            type:   "clickMarker",
            recordId:  recId
        };
        var message = JSON.stringify(param);
        var vfOrigin = "*";
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(message, vfOrigin);
    },

    goCalander : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({ "url": "/lightning/n/Calendar" });
        urlEvent.fire();
    }
});