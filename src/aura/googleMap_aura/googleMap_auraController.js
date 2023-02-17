/**
 * Created by JWJANG on 2022-12-27.
 */

({
    fnInit : function(component, event, helper) {
        helper.fnInit(component);
    },

    addMarker : function(component, event, helper) {
        helper.addMarker(component);
    },

    openModal : function(component, event, helper) {
        console.log('openModal');
        console.log(component.get('v.openModalFlag'));
        component.set('v.openModalFlag', true);
    },

    closeModal : function(component, event, helper) {
        console.log('closeModal');
        component.set('v.openModalFlag', false);
    },

    handleMarkerSelect: function (component, event, helper) {
        console.log(event);

        var markerId = event.getParam("selectedMarkerValue");
        var mapMarkers = component.get('v.mapMarkers');
        var targetMarker = {};

        mapMarkers.forEach(marker => {
            if(marker.value == markerId) {
                targetMarker = marker;
                return false;
            }
        });

        console.log(targetMarker);

        // center 변경
        component.set('v.mapCenter', targetMarker);
    },

    taskClick: function (component, event, helper) {
        console.log(component.find('mapEle'));
        var markerId = event.currentTarget.dataset.markerId;
        var mapMarkers = component.get('v.mapMarkers');
        var targetMarker = {};

        mapMarkers.forEach(marker => {
            if(marker.value == markerId) {
                targetMarker = marker;
                return false;
            }
        });

        // center 변경
        component.set('v.mapCenter', targetMarker);
    },

    goAccount: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({ "url": "/lightning/o/Account/list" });
        urlEvent.fire();
    }
});