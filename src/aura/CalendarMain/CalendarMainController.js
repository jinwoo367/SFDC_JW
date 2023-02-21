/**
 * Created by sjhyk on 2023-01-04.
 */

({
    fnInit : function(component, event, helper){
        component.set("v.showSpinner", true);

        let listOpportunityStage = [
                               { label: '기회식별', value: '기회식별' },
                               { label: '기회검증', value: '기회검증' },
                               { label: '가치제안	', value: '가치제안' },
                               { label: '본제안', value: '본제안' },
                               { label: '계약협상', value: '계약협상' }];
        component.set("v.listOpportunityStage", listOpportunityStage);

        let listObjOptions = [
                            { label: 'Opportunity', value: 'Opportunity'},
                            { label: 'Account', value: 'Account' }
        ];
        component.set("v.rbOptions", listObjOptions);

        let listAccountIndustry = [
                            { label: 'Apparel', value: 'Apparel' },
                            { label: 'Banking', value: 'Banking' },
                            { label: 'Biotechnology', value: 'Biotechnology' },
                            { label: 'Chemicals', value: 'Chemicals' },
                            { label: 'Communications', value: 'Communications' },
                            { label: 'Construction', value: 'Construction' },
                            { label: 'Consulting', value: 'Consulting' },
                            { label: 'Education', value: 'Education' },
                            { label: 'Electronics', value: 'Electronics' },
                            { label: 'Energy', value: 'Energy' },
                            { label: 'Engineering', value: 'Engineering' },
                            { label: 'Entertainment', value: 'Entertainment' },
                            { label: 'Environmental', value: 'Environmental' },
                            { label: 'Finance', value: 'Finance' },
                            { label: 'Food & Beverage', value: 'Food & Beverage' },
                            { label: 'Government', value: 'Government' },
                            { label: 'Healthcare', value: 'Healthcare' },
                            { label: 'Hospitality', value: 'Hospitality' },
                            { label: 'Insurance', value: 'Insurance' },
                            { label: 'Machinery', value: 'Machinery' },
                            { label: 'Manufacturing', value: 'Manufacturing' },
                            { label: 'Media', value: 'Media' },
                            { label: 'Not For Profit', value: 'Not For Profit' },
                            { label: 'Retail', value: 'Retail' },
                            { label: 'Shipping', value: 'Shipping' },
                            { label: 'Technology', value: 'Technology' },
                            { label: 'Telecommunications', value: 'Telecommunications' },
                            { label: 'Transportation', value: 'Transportation' },
                            { label: 'Utilities', value: 'Utilities' }

        ];
        component.set("v.listAccountIndustry", listAccountIndustry);

        helper.getInitData(component);

    },
    fnSelectCategory : function(component, event, helper){
        console.log("stage 변경 시작");
        var selectedStage = component.find("Category").get("v.value");
        console.log("selectStage >> " + selectedStage);
        component.set("v.SelectedStage", selectedStage);
        component.set("v.isSearch", false);
    },
    fnSearch : function(component, event, helper){
        console.log("조회 시작 : fnSearch >>");
        var OpportunityUser = component.get("v.OpportunityUser");
        var OpportunityUserId = component.get("v.OpportunityUserId");
        var selectedId = component.get("v.selectedId");
        var selectedObj = component.get("v.rbSelectedValue");
        console.log(OpportunityUserId + " v " + OpportunityUser + " v " + selectedId + " v " + selectedObj);

        if(!OpportunityUser) {
            helper.showToast("error", "영업 담당자를 선택해주세요.");
            return;
        }

        if(selectedObj == 'Opportunity') {
            var selectedStage = component.get("v.SelectedStage");
            helper.doSearchOpportunities(component, selectedStage, OpportunityUserId, selectedId);
        } else if(selectedObj == 'Account') {
            var selectedIndustry = component.get("v.SelectedIndustry");
            helper.doSearchAccounts(component, selectedIndustry, OpportunityUserId, selectedId);
        }
        component.set("v.isSearch", true);
    },

    navigateToRecord: function (component, event, helper) {
        var recordId = event.target.closest("[data-id]").dataset.id;
        console.log("recordId >>" + recordId );
        window.open('/' +recordId);
        /*var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": recordId,
          "slideDevName": "related"
        });
        navEvt.fire();*/
    },

    fnCreateEvent : function(component, event, helper) {
        console.log("event 생성 ");

        var recordId = event.target.closest("[data-id]").dataset.id;
        console.log("opp id > " + recordId);

        var lat = event.target.closest("[data-id]").dataset.lat;
        var lng = event.target.closest("[data-id]").dataset.lng;
        console.log("lat id > " + lat);
        console.log("lng id > " + lng);

        var windowHash = window.location.hash;
        var windowHash2 = 'https://deau4-dev-ed.lightning.force.com/lightning/n/Demo123';
        console.log("windowHash > " + windowHash);
        console.log("windowHash2 > " + windowHash2);
        var createEvent = $A.get("e.force:createRecord");
        createEvent.setParams({
            "entityApiName": "Event",
            'defaultFieldValues': {
                'WhatId' : recordId,
                'VisitLocation__Latitude__s' : lat,
                'VisitLocation__Longitude__s' : lng
            },
            "navigationLocation": "LOOKUP",
            "panelOnDestroyCallback": function(event) {
                console.log("close");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        createEvent.fire();

        /*var createRecordEvent = $A.get('e.force:createRecord');
        if ( createRecordEvent ) {
            //map the new fields here
            createRecordEvent.setParams({
                'entityApiName': 'Event',
                'defaultFieldValues': {
                    'WhatId' : recordId,

                },
            });
            createRecordEvent.fire();
        }*/
    },

    fnSelectObj : function(component, event, helper) {
        component.set('v.rbSelectedValue', event.getParam('value'));
        console.log('xxxxxxx : ' + component.get('v.rbSelectedValue'));
        component.set("v.isSearch", false);
    },

    fnSelectIndustry : function(component, event, helper){
        console.log("Industry 변경 시작");
        var selectedIndustry = component.find("Industry").get("v.value");
        console.log("selectIndustry >> " + selectedIndustry);
        component.set("v.SelectedIndustry", selectedIndustry);
        component.set("v.isSearch", false);
    },

});