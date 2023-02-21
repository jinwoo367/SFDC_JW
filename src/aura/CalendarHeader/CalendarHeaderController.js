/**
 * Created by JWJANG on 2023-01-04.
 */

({
    goMap : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({ "url": "/lightning/n/TodoMap" });
        urlEvent.fire();
    }
});