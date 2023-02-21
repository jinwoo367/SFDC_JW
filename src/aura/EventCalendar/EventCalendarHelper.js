/**
 * Created by sjhyk on 2023-01-03.
 */

({
    upsertEvent : function(component, evObj, callback) {
        var action = component.get("c.upsertEvents");
 
        action.setParams({
            "sEventObj": JSON.stringify(evObj),
            "sObjectName" : component.get("v.sObjectName"),
            "titleField" : component.get("v.titleField"),
            "startDateTimeField" : component.get("v.startDateTimeField"),
            "endDateTimeField" : component.get("v.endDateTimeField"),
            "descriptionField" : component.get("v.descriptionField"),
            "userField" : component.get("v.userField")
        });

        if (callback) {
            action.setCallback(this, callback);
        }

        $A.enqueueAction(action);
    },
    deleteEvent : function(component, event, eventId, callback){
        var action = component.get("c.deleteEvent");

        action.setParams({
            "eventId": eventId,
            "sObjectName" : component.get("v.sObjectName"),
            "titleField" : component.get("v.titleField"),
            "startDateTimeField" : component.get("v.startDateTimeField"),
            "endDateTimeField" : component.get("v.endDateTimeField"),
            "descriptionField" : component.get("v.descriptionField"),
            "userField" : component.get("v.userField")
        });

        if (callback) {
            action.setCallback(this, callback);
        }

        $A.enqueueAction(action);
    },
    openModal : function(component, event) {
        console.log('jys ========> helper +  openModal ');
        var modal = component.find('modal');
        component.set('v.isShowModal', true);
        //기존 패키지 제공소스 주석처리
        $A.util.addClass(modal, 'slds-fade-in-open');
        var backdrop = component.find('backdrop');
        $A.util.addClass(backdrop, 'slds-backdrop--open');

    },
    closeModal : function(component, event) {
        var modal = component.find('modal');
        component.set('v.isShowModal', false);
        //기존소스 주석처리
        //$A.util.removeClass(modal, 'slds-fade-in-open');
        //var backdrop = component.find('backdrop');
        //$A.util.removeClass(backdrop, 'slds-backdrop--open');
    },
    //Task 레코드 페이지로 이동
    doNavigateRecordPage :function(component, calEvent) {
        var strRecordId  = calEvent['id'];
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": strRecordId,
              "slideDevName": "detail"
            });
            navEvt.fire();

    }
});