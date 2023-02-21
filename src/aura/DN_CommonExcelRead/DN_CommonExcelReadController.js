({
    fnInit : function(component, event, helper) {
        console.log('init');
    },

    fnExcelUpload : function(component, event, helper) {
        component.set("v.toggleSpinner", true);
        console.log('file name: ' + component.get("v.FileList")[0].name);
        var file = component.get("v.FileList")[0];
        component.set("v.FileName", component.get("v.FileList")[0].name);
        //var readSheetIndex = component.get("v.readSheetIndex");
        var strSelectTargetObject = component.get("v.strObject");
        if(strSelectTargetObject.length < 0) {
            helper.showToast("Error", "Object를 선택하세요.");
        }
        else{
            try{
                var reader = new FileReader();
                reader.onload = function(response) {
                    var binary = "";
                    var bytes = new Uint8Array(response.target.result);
                    var length = bytes.byteLength;
                    console.log('length >>> ' + length);

                    for (var i = 0; i < length; i++) {
                        binary += String.fromCharCode(bytes[i]);
                    }
                    var workbook = XLSX.read(binary, {type: "binary", cellDates:true, dateNF:'yyyy-mm-dd'});
                    var sheet_name_list = workbook.SheetNames;
                    console.log('sheet name list :: ' + sheet_name_list);
                    //console.log('readSheetIndex :: ' + readSheetIndex);
                    console.log(workbook.Sheets[sheet_name_list[0]]);

                    // Get Data
                    component.set("v.readData", XLSX.utils.sheet_to_json(workbook.Sheets[sheet_name_list[0]], {header : '1', raw:false}));

                    // ReadDataRow 가 Default(1) 보다 클 경우 해당 Row 만 파싱하도록 조치
                    var readData = component.get("v.readData");
                    console.log('readData :: ' + readData);
                    var readDataRow = component.get("v.readDataRow");
                    console.log('readDataRow :: ' + readDataRow);
                    var excelData = [];
                    for(var dataIndex in readData) {
                        console.log('dataIndex :: ' + dataIndex);
                        if(dataIndex >= readDataRow) {
                            console.log('readData..idx > ' + dataIndex);
                            console.log(readData[dataIndex]);
                            excelData.push(readData[dataIndex]);
                        }
                    }
                    helper.showToast("Success", excelData.length + "개의 데이터가 입력되었습니다. 저장을 원하시면 저장버튼을 눌러주세요");
                    component.set("v.excelData", excelData);
                    component.set("v.toggleSpinner", false);
                    component.set("v.intDMLSuccessCount", 0);
                    component.set("v.intThreadNowCount", 0);
                };
                reader.readAsArrayBuffer(file);

            }catch(e){ 
                console.log(e);
            }
        }
    }
});