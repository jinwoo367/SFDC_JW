/**
 * Created by sjhyk on 2023-01-04.
 */


({
    getInitData : function(component) { 
        console.log("getInitData Start >>");

        var action = component.get("c.getInitData");
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log("returnValue >> " + JSON.stringify(returnValue));
                component.set("v.OpportunityUserId", returnValue.Id);
                component.set("v.OpportunityUser", returnValue.Name);

                //this.showToast("success", "성공적으로 조회되었습니다..");
                //$A.get("e.force:refreshView").fire();
                //$A.get("e.force:closeQuickAction").fire();
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }

            component.set("v.showSpinner", false);
        });

        $A.enqueueAction(action);
    },
    doSearchOpportunities : function(component, selectedStage, OpportunityUserId, selectedId) {
        component.set("v.showSpinner", true);
        console.log("EVENT 조회 시작, doSearchOpportunities >>");

        var action = component.get("c.doSearchOpportunities");
        action.setParams({
            selectedStage : selectedStage,
            OpportunityUserId : OpportunityUserId,
            selectedId : selectedId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(returnValue);

                console.log("조회된 리스트 개수 >>" + returnValue.length);
                if(returnValue.length == 0) {
                    this.showToast("error", "조회된 리스트가 없습니다.");
                    component.set("v.isSearch" , false);
                } else {
                    this.showToast("success", "성공적으로 " + returnValue.length + "건의 데이터가 조회되었습니다.");
                    component.set("v.isSearch" , true);
                    component.set("v.SearchOppList" , returnValue);
                    console.log("조회된 리스트 >" + component.get("v.SearchOppList"));

                }

                //$A.get("e.force:refreshView").fire();
                //$A.get("e.force:closeQuickAction").fire();
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }

            component.set("v.showSpinner", false);
        });

        $A.enqueueAction(action);
    },
    doSearchAccounts : function(component, selectedIndustry, OpportunityUserId, selectedId) {
        component.set("v.showSpinner", true);
        console.log("EVENT 조회 시작, doSearchAccounts >>");

        if(selectedId != null) {
            var action = component.get("c.doSearchAccountOppti");
        } else {
            var action = component.get("c.doSearchAccounts");
        }
        action.setParams({
            selectedIndustry : selectedIndustry,
            OpportunityUserId : OpportunityUserId,
            selectedId : selectedId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(returnValue);

                console.log("조회된 리스트 개수 >>" + returnValue.length);
                if(returnValue.length == 0) {
                    this.showToast("error", "조회된 리스트가 없습니다.");
                    component.set("v.isSearch" , false);
                } else {
                    this.showToast("success", "성공적으로 " + returnValue.length + "건의 데이터가 조회되었습니다.");
                    component.set("v.isSearch" , true);
                    component.set("v.SearchAccountList" , returnValue);
                    console.log("조회된 리스트 >" + component.get("v.SearchAccountList"));
                }

                //$A.get("e.force:refreshView").fire();
                //$A.get("e.force:closeQuickAction").fire();
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }

            component.set("v.showSpinner", false);
        });

        $A.enqueueAction(action);
    },
    test : function(component, event, recordId) {
        console.log("start test > " + recordId);

    },
    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });
        evt.fire();
    },
});