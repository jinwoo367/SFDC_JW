/**
 * Created by JWJANG on 2022-12-27.
 */

({
    fnInit : function(component) {
        var action = component.get("c.getInitData");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(returnValue);

                component.set('v.mapCenter', returnValue.mapCenter);
                component.set('v.mapOptions', returnValue.mapOptions);
                component.set('v.mapMarkers', returnValue.mapMarkers);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }

                component.set("v.bSpinner", false);
            }
        });

        $A.enqueueAction(action);
    },

    addMarker : function(component) {
        var action = component.get("c.addMarkerByObj");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(returnValue);

                var oldMapMarkers = component.get("v.mapMarkers");
                var newMapMarkers = returnValue.mapMarkers;

                newMapMarkers.forEach(marker => {
                    console.log(marker);
                    oldMapMarkers.push(marker);
                });

                component.set("v.mapMarkers", oldMapMarkers);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }

                component.set("v.bSpinner", false);
            }
        });

        $A.enqueueAction(action);
    }
});