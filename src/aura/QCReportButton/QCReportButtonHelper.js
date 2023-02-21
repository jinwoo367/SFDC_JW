/**
 * Created by JWJANG on 2023-01-30.
 */

({
    savePdf : function(component, event) {
        var action = component.get("c.savePdf");
        var targetRecordId = component.get("v.recordId");
        action.setParams({
            recordId : targetRecordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);

            if(state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                console.log("returnVal : ", returnVal);

                var result = returnVal.result;
                console.log("result : ", result);

                if(result == "SUCCESS") {
                    var navService = component.find("navService");
                    var pageReference = {
                        type: 'standard__recordPage',
                        attributes: {
                            objectApiName: 'QCReport__c',
                            actionName: 'view',
                            recordId: targetRecordId
                        }
                    };

                    // 페이지 이동 후, 토스트 메시지 노출
                    navService.generateUrl(pageReference).then($A.getCallback(function(url) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title"     : 'Success!',
                            "type"      : 'Success',
                            "message"   : "성공적으로 저장하였습니다."
                        });
                        toastEvent.fire();

                        }), $A.getCallback(function(error) { console.log(error); }
                    ));
                    navService.navigate(pageReference, true);
                } else {
                    this.showToast("error", "저장 실패하였습니다.");
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                }
                else {
                    this.showToast("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    showToast : function(thisType, thisMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
              key : "info_alt"
            , type : thisType
            , message : thisMessage
        });
        toastEvent.fire();
    }
});