/**
 * Created by yr.lee on 2021-10-21.
 */

({
    //템플릿명 설정
    getData : function(component) {
        console.log('getData');
        component.set("v.dataTableYn", false);
        component.set("v.data", []);
        var action = component.get("c.getObjects");

        let strSelectTargetObject = component.get("v.strSelectTargetObject");
        if(strSelectTargetObject.length > 0){
            action.setParams({
                strObj: strSelectTargetObject
            })
        }

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log('SUCCESS');
                var result = response.getReturnValue();
                var options = [];
                console.log('result :' + result);
                for(var i = 0; i < result.length; i++){
                    options[i] = result[i];
                }
                component.set('v.options', options);
            }
        });
        $A.enqueueAction(action);
    },

    //양식다운로드
    saveExcel : function(component, event, helper){
        var objName = component.find("select").get("v.value");
        var urlEvent = $A.get("e.force:navigateToURL");
        console.log(objName);
        urlEvent.setParams({
             "url": "/apex/ExcelPage?object=" + objName,
             "isredirect": "true"
        });

        urlEvent.fire();
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key : "info_alt"
            , type : type
            , message : message
        });
        evt.fire();
    },


    //업로드
    fnThread : function(component, helper) {
        var data = component.get("v.data");
        var intThreadMaxCount = component.get("v.intThreadMaxCount");
        var intThreadNowCount = component.get("v.intThreadNowCount");
        var intProcessCount = component.get("v.intProcessCount");
        var intDMLSuccessCount = component.get("v.intDMLSuccessCount");
        var intStartIndex = intDMLSuccessCount > 0 ? intDMLSuccessCount : 0;
        var intEndIndex = intStartIndex + intProcessCount;

        console.log("intDMLSuccessCount : " + intDMLSuccessCount);
        console.log("intStartIndex : " + intStartIndex);
        console.log("intEndIndex : " + intEndIndex);

        //intThreadMaxCount : 10    intThreadNowCount : 0    intDMLSuccessCount : 0   intProcessCount: 50
        if(intThreadMaxCount > intThreadNowCount && data.length >= intDMLSuccessCount) {
            console.log("thread end");
            /*var self = this;*/
            var targetData = data.slice(intStartIndex, intEndIndex);
            helper.saveApl(component, targetData, intEndIndex, helper);// saveApl 호출
            intThreadNowCount++;
            component.set("v.intThreadNowCount", intThreadNowCount);
            intDMLSuccessCount += component.get("v.intProcessCount");
            component.set("v.intDMLSuccessCount", intDMLSuccessCount);

            var intProgressBarValue = component.get("v.intProgressBarValue");
            component.set("v.intProgressBarValue", intStartIndex / data.length * 100);

            window.setTimeout(
                $A.getCallback(function() {
                    self.fnThread(component);
                }), 1000
            );
        }
        /*console.log('listFailed :: ' + listFailed);*/
    },

    saveApl : function(component, listData, intEndIndex, helper){
        console.log("saveApl Call");

        var action = component.get("c.doSave");
        action.setParams({
            "strInput" : JSON.stringify(listData),
            "strTemplateName" : component.get("v.strTemplateName")
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            var listFailed = [];
            if(component.get("v.FailedData") == null || component.get("v.FailedData") == []){
                listFailed = [];
            }
            else{
                listFailed = component.get("v.FailedData");
            }

            var listDmlErrorParse = [];

            var returnValue = response.getReturnValue();

            if(returnValue.resultMsg.startsWith("SUCCESS")) {
                var data = component.get("v.data");
                var intDMLSuccessCount = component.get("v.intDMLSuccessCount");
                var intThreadNowCount = component.get("v.intThreadNowCount");

                /*var intProgressBarValue = component.get("v.intProgressBarValue");
                component.set("v.intProgressBarValue", intDMLSuccessCount + (returnValue.resultMsg.split("||")[1] / data.length * 100));*/

                if(listData.length != 0){
                    //Failed Data 표시용 DataTable의 필드 설정
                    var columns = [];
                    for(var i = 0; i < returnValue.fields.length; i++){
                        columns.push({
                            fieldName: returnValue.fields[i],
                            label: returnValue.fields[i],
                            editable: true
                        });
                    }
                    columns.push({
                        fieldName: 'Error',
                        label: 'Error'
                    });

                    component.set("v.columns", columns);
                }


                //Failed Data 표시용 데이터 설정
                for(var i = 0; i < returnValue.listMapTypeError.length; i++){
                    listFailed.push(returnValue.listMapTypeError[i]);
                }

                listDmlErrorParse = JSON.parse(JSON.stringify(returnValue.listDmlError));
                for(var i = 0; i < returnValue.listDmlError.length; i++){
                    //Error 번호와 Error Msg 추가
                    listDmlErrorParse[i].Id = returnValue.mapId[listDmlErrorParse[i].Id];
                    listDmlErrorParse[i].Error = returnValue.listDmlErrorMsg[i];
                    listDmlErrorParse[i].ErrorNumber = returnValue.listDmlErrorNum[i];

                    listFailed.push(listDmlErrorParse[i]);
                }

                if(listFailed.length == 0){
                    component.set("v.flagSaveButton", true);
                }
                else{
                    component.set("v.flagSaveButton", false);
                }
                console.log('listFailed length :: ' + listFailed.length);
                component.set("v.FailedData", listFailed);


                if(data.length < intDMLSuccessCount) {
                    component.set("v.flagSaveStart", false);
                    component.set("v.dataTableYn", false);
                    console.log("call end");
                    component.set("v.isFinish", true);
                    var successCount = data.length - component.get("v.FailedData").length;
                    this.showToast("SUCCESS", "처리가 완료되었습니다. 성공 : " + successCount + "건, 실패 : " + component.get("v.FailedData").length + "건");
                }
                else{
                    console.log("50건 추가 호출");
                    /*var intProgressBarValue = component.get("v.intProgressBarValue");
                    component.set("v.intProgressBarValue", intProgressBarValue + (returnValue.split("||")[1] / data.length * 100));*/
                    intThreadNowCount--;
                    component.set("v.intThreadNowCount", intThreadNowCount);
                    this.fnThread(component, helper);
                }
            }
            else{
                console.log('Error!');
                this.showToast("ERROR", returnValue.resultMsg.split("||")[1]);

                //파일이 해당 개체에 맞지 않을 시
                if(returnValue.resultMsg.split("||")[1].startsWith("해")){
                    console.log('Differnt Object');
                    component.set("v.isDiffObject", true);
                    component.set("v.flagSaveStart", false);
                    component.set("v.isFinish", true);
                    component.set("v.data", []);
                    $A.get('e.force:refreshView').fire();
                }
            }
        });
        $A.enqueueAction(action);
    },

    fnSaveAgain : function(component, event, helper){
        var draftValues = [];
        var failedValues = [];
        var tempDraftValues = [];
        var draftValuesKeys = [];
        var tempFailedValues = [];
        var failedValuesKeys = [];

        //draftValues에는 '수정된' 필드만 담겨있으므로, failedValues랑 조합 해야함
        draftValues = JSON.stringify(event.getParam('draftValues'));
        failedValues = JSON.stringify(component.get("v.FailedData"));

        draftValues = JSON.parse(draftValues);
        failedValues = JSON.parse(failedValues);

        //failedValue에 DraftValue로 넣어주는 작업
        for(var i = 0; i < draftValues.length; i++){
            for(var j = 0; j < failedValues.length; j++){
                if(failedValues[j]["ErrorNumber"] == draftValues[i]["ErrorNumber"]){
                    Object.assign(failedValues[j], draftValues[i]);
                    console.log('failedValues[j] :' + JSON.stringify(failedValues[j]));
                    continue;
                }
            }
        }

        //데이터아닌 부분은 빼야함  ->  Error, Error Number
        for(var i = 0; i < failedValues.length; i++){
            delete failedValues[i].ErrorNumber;
            delete failedValues[i].Error;
        }

        console.log('failedValues final: ' + JSON.stringify(failedValues));

        var action = component.get("c.doSave");
        action.setParams({
            "strInput" : JSON.stringify(failedValues),
            "strTemplateName" : component.get("v.strTemplateName")
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            var listFailed = [];
            var listDmlErrorParse = [];

            var returnValue = response.getReturnValue();

            if(returnValue.resultMsg.startsWith("SUCCESS")) {
                component.set("v.flagSaveStart", false);
                component.set("v.dataTableYn", false);
                console.log('listFailed :: ' + listFailed);
                component.set("v.isFinish", true);

                //Failed Data 표시용 DataTable의 필드 설정
                var columns = [];
                columns.push({
                    fieldName: 'ErrorNumber',
                    label: 'Error Number'
                });

                for(var i = 0; i < returnValue.fields.length; i++){
                    columns.push({
                        fieldName: returnValue.fields[i],
                        label: returnValue.fields[i],
                        editable: true
                    });
                }
                //Error는 마지막에 넣되, editable은 false.
                columns.push({
                    fieldName: 'Error',
                    label: 'Error'
                });
                console.log('columns :: ' + JSON.stringify(columns));
                component.set("v.columns", columns);

                console.log('returnValue.listMapTypeError :: ' + JSON.stringify(returnValue.listMapTypeError));

                //Failed Data 표시용 데이터 설정
                for(var i = 0; i < returnValue.listMapTypeError.length; i++){
                    listFailed.push(returnValue.listMapTypeError[i]);
                }
                console.log('listFailed after type error :: ' + listFailed);

                listDmlErrorParse = JSON.parse(JSON.stringify(returnValue.listDmlError));
                console.log('listDmlErrorParse : ' + JSON.stringify(listDmlErrorParse));
                for(var i = 0; i < returnValue.listDmlError.length; i++){
                    //Error 번호와 Error Msg 추가, Id는 원래값으로 변경
                    listDmlErrorParse[i].Id = returnValue.mapId[listDmlErrorParse[i].Id];
                    listDmlErrorParse[i].Error = returnValue.listDmlErrorMsg[i];
                    listDmlErrorParse[i].ErrorNumber = returnValue.listDmlErrorNum[i];

                    listFailed.push(listDmlErrorParse[i]);
                    console.log('listDmlErrorParse[i] : ' + JSON.stringify(listDmlErrorParse[i]));
                }
                if(listFailed.length == 0){
                    component.set("v.flagSaveButton", true);
                }
                else{
                    component.set("v.flagSaveButton", false);
                }
                console.log('listFailed :: ' + JSON.stringify(listFailed));
                console.log('returnValue.listDmlError :: ' + returnValue.listDmlError);
                console.log('returnValue.listMapTypeError :: ' + returnValue.listMapTypeError);
                component.set("v.FailedData", listFailed);
                /*component.set("v.flagSaveButton", false);*/
                var successCount = failedValues.length - component.get("v.FailedData").length;
                component.set("v.toggleSpinner", false);
                this.showToast("SUCCESS", "처리가 완료되었습니다. 성공 : " + successCount + "건, 실패 : " + component.get("v.FailedData").length + "건");
            }
            else{
                console.log('Error!');
                this.showToast("ERROR", returnValue.resultMsg.split("||")[1]);

                //파일이 해당 개체에 맞지 않을 시
                if(returnValue.resultMsg.split("||")[1].startsWith("해")){
                    console.log('Differnt Object');
                    component.set("v.isDiffObject", true);
                    component.set("v.flagSaveStart", false);
                    component.set("v.isFinish", true);
                    component.set("v.data", []);
                    $A.get('e.force:refreshView').fire();
                }
            }
        });
        $A.enqueueAction(action);
    }

});