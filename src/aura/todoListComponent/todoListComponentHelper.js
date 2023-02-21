/**
 * Created by JWJANG on 2023-01-03.
 */

({
    getInitData : function(component) {
        component.set("v.showSpinner", true);

        var action = component.get("c.getInitData");
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log("returnValue >> ");
                console.log(returnValue);

                component.set("v.loginUserId", returnValue.userId);
                component.set("v.loginUserName", returnValue.userName);
                component.set("v.vfHostUrl", returnValue.hostUrl);

                this.searchList(component);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });

        component.set("v.showSpinner", false);
        $A.enqueueAction(action);
    },
    searchList : function(component) {
        component.set("v.showSpinner", true);

        var action = component.get("c.searchList");
        action.setParams({
            searchDate:      component.get("v.searchDate"),
            searchCondition: component.get("v.searchCondition"),
            searchUser:      component.get("v.loginUserId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(returnValue);

                var markers = returnValue.mapMarkers;

                console.log("조회된 리스트 개수 >> " + markers.length);
                if(markers.length == 0) {
                    this.showToast("error", "조회된 리스트가 없습니다.");
                    component.set("v.isSearch", false);
                } else {
                    this.showToast("success", "성공적으로 " + markers.length + "건의 데이터가 조회되었습니다.");
                    component.set("v.isSearch", true);
                }
                component.set("v.searchMarkerList", markers);

                console.log("조회된 리스트 > ");
                console.log(component.get("v.searchMarkerList"));

                // Marker 적용
                var param = {
                    type:            'searchList',
                    searchDate:      component.get("v.searchDate"),
                    searchCondition: component.get("v.searchCondition"),
                    searchUser:      component.get("v.loginUserId")
                };
                var message = JSON.stringify(param);
                var vfOrigin = "*";
                var vfWindow = component.find("vfFrame").getElement().contentWindow;
                vfWindow.postMessage(message, vfOrigin);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });
        component.set("v.showSpinner", false);
        $A.enqueueAction(action);
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    }
});