/**
 * Created by JWJANG on 2023-02-21.
 */

public without sharing class ExcelImportController {

    public List<ExcelField> listExcelFields {
        get {
            if (listExcelFields == null) {
                listExcelFields = new List<ExcelField>();
            }
            return listExcelFields;
        }
        set;
    }

    @AuraEnabled
    public String strTemplateName {
        get {
            if (strTemplateName == null) {
                strTemplateName = '';
            }
            return strTemplateName;
        }
        set;
    }

    public ExcelImportController() {
        /*if (listExcelFields == null) {
            listExcelFields = new List<ExcelField>();
        }*/
        strTemplateName = ApexPages.currentPage().getParameters().get('object');
        System.debug('strTemplateName' + strTemplateName);

        List<ExcelMaster__c> listTemplate = new List<ExcelMaster__c>();
        listTemplate = [
                SELECT Id, ObjectAPI__c
                FROM ExcelMaster__c
                WHERE Name = :strTemplateName
        ];

        List<ExcelData__c> listFields = new List<ExcelData__c>([
                SELECT Id, FieldApi__c, Unique_Id__c, SampleData__c
                FROM ExcelData__c
                WHERE ExcelMaster__r.Name = :strTemplateName
                ORDER BY DisplayOrder__c
        ]);

        Map<String, String> mapLabel = new Map<String, String>();
        Map<String, String> mapSample = new Map<String, String>();

        //해당 오브젝트의 필드를 검색하여 같은것이 있으면 map에 담음
        for(ExcelData__c obj : listFields){
            for(Schema.SObjectField field : Schema.getGlobalDescribe().get(listTemplate[0].ObjectAPI__c).getDescribe().fields.getMap().values()) {
                if (field.getDescribe().getName() == obj.FieldApi__c) {
                    mapLabel.put(obj.FieldApi__c, field.getDescribe().getLabel());
                    mapSample.put(obj.FieldApi__c, obj.SampleData__c);
                }
            }
        }

        if(!listFields.isEmpty()){
            ExcelField excel;
            for (ExcelData__c obj : listFields) {
                excel = new ExcelField();
                excel.fAPIName = String.valueOf(obj.FieldApi__c);
                //excel.fLabel = String.valueOf(obj.Field_Label__c);
                excel.fLabel = mapLabel.get(obj.FieldApi__c);
                excel.fType = 'text';
                excel.fSample = mapSample.get(obj.FieldApi__c);
                System.debug(excel);
                listExcelFields.add(excel);
            }
        }
    }
    public class ExcelField {
        @AuraEnabled public String fAPIName { get; set; }
        @AuraEnabled public String fLabel { get; set; }
        @AuraEnabled public String fType { get; set; }
        @AuraEnabled public String fSample { get; set; }
    }

    @AuraEnabled
    public static List<String> getObjects() {
        System.debug('getObjects : ');
        List<ExcelMaster__c> listEM = new List<ExcelMaster__c>([
                SELECT Name, Id
                FROM ExcelMaster__c
                WHERE IsActive__c = TRUE
                ORDER BY CreatedDate
        ]);
        System.debug('listEM : ' + listEM);

        List<String> listTemplateName = new List<String>();
        if(!listEM.isEmpty()){
            for (ExcelMaster__c objEM : listEM) {
                listTemplateName.add(objEM.Name);
            }
        }
        return listTemplateName;
    }

    public class FailedDataWrapper {
        @AuraEnabled public List<Map<String, String>> listMapTypeError { get; set; } //타입에러
        @AuraEnabled public List<SObject> listDmlError { get; set; } //DML에러
        @AuraEnabled public List<String> listDmlErrorMsg { get; set; } //DML에러의 에러 메시지 List
        @AuraEnabled public List<String> listDmlErrorNum { get; set; } //DML에러의 Num
        @AuraEnabled public Map<String, String> mapId { get; set; } //DML 에러중 Id값을 사용자가 입력할 값으로 돌리기 위함
        @AuraEnabled public String resultMsg { get; set; } //결과 메시지 ---> ex) SUCCESS||
        @AuraEnabled public List<String> fields { get; set; } //해당 Object의 필드들
        @AuraEnabled public String stringSuccessCount { get; set; } //성공한 insert record 수


        public FailedDataWrapper(List<Map<String, String>> listMapTypeError, List<SObject> listDmlError, List<String> listDmlErrorMsg, List<String> listDmlErrorNum, Map<String, String> mapId, String resultMsg, List<String> fields, String stringSuccessCount) {
            this.listMapTypeError = listMapTypeError;
            this.listDmlError = listDmlError;
            this.listDmlErrorMsg = listDmlErrorMsg;
            this.listDmlErrorNum = listDmlErrorNum;
            this.mapId = mapId;
            this.resultMsg = resultMsg;
            this.fields = fields;
            this.stringSuccessCount = stringSuccessCount;
        }
    }

    //Temp Object에 저장 -> Trigger에서 Object에 저장
    @AuraEnabled
    public static FailedDataWrapper doSave(String strInput, String strTemplateName) {
        List<FailedDataWrapper> listFailedDataWrapper = new List<FailedDataWrapper>();
        Savepoint sp = Database.setSavepoint();
        String strReturnMessage = 'SUCCESS||';
        List<String> listDMLErrorNum = new List<String>();
        List<Map<String, String>> lmTypeError;
        List<SObject> listDMLError;
        List<String> listDmlErrorMsg;
        List<String> listFields;
        Integer intSuccessCount;
        String strObject = '';
        String strUniqueId = '';

        // key : Field API, Value : Unique Number --> Unique Number 유무를 판단 (Lookup 인지 아닌지를 판단)
        Map<String, String> mapUnique = new Map<String, String>();

        // key : Lookup Field, Value : Map<key : Unique No, Value : Salesforce Id> --> 해당 lookup field의 해당 번호와 맡는 레코드 아이디 값
        Map<String, Map<String, Id>> mapRealId = new Map<String, Map<String, Id>>();
        // key : Lookup Field, Value : Map<key : Salesforce Id, Value : Unique No> --> 에러났을때 사용자가 입력한 값으로 다시 바꿔주기 위함
        Map<String, Map<String, String>> mapRealIdReverse = new Map<String, Map<String, String>>();
        // key : Unique Number, Value : Salesforce Id --> 해당 번호와 맡는 레코드 아이디 값
        Map<String, Id> mapRecordId = new Map<String, Id>();
        // key : Salesforce Id, Value : Unique Number --> 에러났을때 사용자가 입력한 값으로 다시 바꿔주기 위함
        Map<String, String> mapRecordIdReverse = new Map<String, String>();


        List<ExcelMaster__c> listTemplate = new List<ExcelMaster__c>();
        listTemplate = [
                SELECT Id, ObjectAPI__c, UniqueId__c
                FROM ExcelMaster__c
                WHERE Name = :strTemplateName
        ];

        if(!listTemplate.isEmpty()){
            strObject = listTemplate[0].ObjectAPI__c;
            strUniqueId = listTemplate[0].UniqueId__c;
        }

        System.debug('templateName : ' + strTemplateName);
        System.debug('strInput : ' + strInput);

        try {
            Database.UpsertResult[] srList;
            Database.SaveResult[] srExternalList;
            lmTypeError = new List<Map<String, String>>();
            listDMLError = new List<SObject>();
            listFields = new List<String>();
            listDmlErrorMsg = new List<String>();
            Integer errorNum = 1;

            List<Map<String, String>> listMap = (List<Map<String, String>>) JSON.deserialize(strInput, List<Map<String, String>>.class);
            List<SObject> listObj = new List<SObject>();

            //key : Unique Id, Value : Object Api
            Map<String, String> mapObject = new Map<String, String>();

            //Unique Id 정리를 위한 Map
            //key : Object API ex) Contact__c Value : data ex) 후원자번호 Set
            Map<String, Set<String>> mapObjectNos = new Map<String, Set<String>>();
            List<String> listStr;
            Boolean flag = false;
            String strQuery;
            Set<String> setUniqueId = new Set<String>();


            System.debug('listMap Size : ' + listMap.size());
            System.debug('listMap : ' + listMap);

            if(strInput.contains('__r')) {
                System.debug('strInput contains __r');
                flag = true;
                for (Map<String, String> objMap : listMap) {
                    for (String key : objMap.keySet()) {
                        if (key.contains('__r')) {
                            listStr = key.split(':');
                            strQuery = 'SELECT Id, ' + listStr.get(2);
                            strQuery += ' FROM ' + listStr.get(1);
                        }
                    }
                }
            }else{
                //Object와 다른 파일을 넣었을때 토스트를 띄워주기 위함
                List<ExcelData__c> listField = new List<ExcelData__c>();
                listField = [
                        SELECT FieldApi__c, Unique_Id__c
                        FROM ExcelData__c
                        WHERE ExcelMaster__r.Name = :strTemplateName
                        ORDER BY DisplayOrder__c
                ];
                System.debug('listField>>>>' +listField);
                Set<String> setField = new Set<String>();
                if(!listField.isEmpty()){
                    for(ExcelData__c objEd : listField){
                        setField.add(objEd.FieldApi__c);
                        mapUnique.put(objEd.FieldApi__c, objEd.Unique_Id__c);
                    }
                }

                System.debug('setField ::' + setField);
                System.debug('listMap ::' + listMap);


                Set<String> setUniqueNos = new Set<String>();
                for(Map<String, String> objMap : listMap) {
                    for(String key : objMap.keySet()) {
                        System.debug('objMap.keySet() ::' + objMap.keySet());

                        // 2022-09-14 EMPTY 포함한 컬럼은 제외처리 by.이대운
                        if (!key.contains('EMPTY')) {
                            System.debug('woon_1 :: ' + key);
                            if(!setField.contains(key) && key != 'Id') {
                                System.debug('does not have this field in the object ::' + key);
                                lmTypeError.add(objMap);
                                strReturnMessage = 'ERROR||해당 개체에 없는 필드가 존재 합니다. 파일을 확인해주세요';
                                System.debug('return to helper');
                                return new FailedDataWrapper(lmTypeError, null, null, null, null, strReturnMessage, listFields, '0');
                            }
                        }

                        // if(!setField.contains(key) && key != 'Id' && key != '__EMPTY') {
                        //     System.debug('does not have this field in the object ::' + key);
                        //     lmTypeError.add(objMap);
                        //     strReturnMessage = 'ERROR||해당 개체에 없는 필드가 존재 합니다. 파일을 확인해주세요';
                        //     System.debug('return to helper');
                        //     return new FailedDataWrapper(lmTypeError, null, null, null, null, strReturnMessage, listFields, '0');
                        // }
                        //Id일 경우
                        if(key == 'Id' || key == 'ID'){
                            setUniqueId.add(objMap.get(key));
                        }
                        //Lookup일 경우
                        if(mapUnique.get(key) != null){
                            mapObject.put(mapUnique.get(key), key); //key : Unique Id, Value : Object Api
                            if(!mapObjectNos.keySet().contains(key)){
                                setUniqueNos = new Set<String>();
                                setUniqueNos.add(objMap.get(key));
                                mapObjectNos.put(key, setUniqueNos);
                            }
                            else{
                                mapObjectNos.get(key).add(objMap.get(key));
                            }
                        }
                    }
                }
                System.debug('mapObjectNos :' + mapObjectNos);
            }


            //Contact__c, Campaign__c ...와 같은 Lookup 필드들의 실제 Id와 Map 만들기
            if(!mapObjectNos.isEmpty()){
                for(String strLookup : mapObjectNos.keySet()){
                    Set<String> setNos = new Set<String>();
                    String strtemp = '';
                    setNos = mapObjectNos.get(strLookup);
                    System.debug('setNos :' + setNos);
                    String strQueryForLookup = '';
                    if(mapUnique.get(strLookup) == 'Id' || mapUnique.get(strLookup) == 'id' || mapUnique.get(strLookup) == 'ID'){
                        strQueryForLookup += 'SELECT Id ';
                    }
                    else{
                        strQueryForLookup += 'SELECT Id , ' + mapUnique.get(strLookup);
                    }

                    if(strLookup == 'Campaign__c' || strLookup == 'Lead__c' || strLookup == 'Account__c' || strLookup == 'Contact__c' || strLookup == 'Case__c'){
                        strtemp = strLookup.removeEnd('__c');
                    }
                    else if(strLookup == 'Donation__c'){
                        strtemp = 'Donation__x';
                    }
                    else if(strLookup == 'ContactId' || strLookup == 'Recommender__c'){
                        strtemp = 'Contact';
                    }
                    else if(strLookup == 'OwnerId' && strObject == 'Case'){
                        strtemp = 'User';
                    }
                    else{
                        strtemp = strLookup;
                    }
                    strQueryForLookup += ' FROM   '+ strtemp;
                    strQueryForLookup += ' WHERE ' + mapUnique.get(strLookup) + ' IN :setNos';
                    System.debug('strQueryForLookup :' + strQueryForLookup);
                    List<SObject> listResult = Database.query(strQueryForLookup);
                    System.debug('listResult :' + listResult);
                    if(!listResult.isEmpty()){
                        for(SObject objObject : listResult){
                            if(!mapRealId.keySet().contains(strLookup)){
                                //개체 설정
                                mapRealId.put(strLookup, new Map<String, Id>());
                                mapRealId.get(strLookup).put(String.valueOf(objObject.get(mapUnique.get(strLookup))), objObject.Id);
                                mapRealIdReverse.put(strLookup, new Map<String, String>());
                                mapRealIdReverse.get(strLookup).put(objObject.Id, String.valueOf(objObject.get(mapUnique.get(strLookup))));
                            }
                            else{
                                mapRealId.get(strLookup).put(String.valueOf(objObject.get(mapUnique.get(strLookup))), objObject.Id);
                                mapRealIdReverse.get(strLookup).put(objObject.Id, String.valueOf(objObject.get(mapUnique.get(strLookup))));
                            }
                        }
                        System.debug('mapRealId : ' + mapRealId);
                    }
                }
            }

            //Id 전용
            if(!setUniqueId.isEmpty()){
                String strQueryForId = '';
                if(strUniqueId == 'Id' || strUniqueId == 'id' || strUniqueId == 'ID'){
                    strQueryForId += 'SELECT Id';
                }
                else{
                    strQueryForId += 'SELECT Id, ' + strUniqueId;
                }
                strQueryForId += ' FROM ' + strObject;
                strQueryForId += ' WHERE ' + strUniqueId + ' IN :setUniqueId';
                List<SObject> listResultId = Database.query(strQueryForId);

                if(!listResultId.isEmpty()){
                    //해당 Unique key 값과 실제 Id값 정리
                    for(SObject objObject : listResultId){
                        if(strUniqueId == 'Id' || strUniqueId == 'id' || strUniqueId == 'ID'){
                            //사실상 else의 내용과 동일
                            mapRecordId.put(objObject.Id, objObject.Id);
                            mapRecordIdReverse.put(objObject.Id, objObject.Id);
                        }
                        else{
                            mapRecordId.put(String.valueOf(objObject.get(strUniqueId)), objObject.Id);
                            mapRecordIdReverse.put(objObject.Id, String.valueOf(objObject.get(strUniqueId)));
                        }
                    }
                    System.debug('mapRecordId : ' + mapRecordId);
                }
            }


            SObjectType objType = ((SObject) (Type.forName('Schema.' + strObject).newInstance())).getSObjectType();
            DescribeSObjectResult result = objType.getDescribe();

            SObject record = null;

            //Id가 없어서 에러나는 경우는
            Boolean isNoId = false;

            //key : key  Value : Number ex) (Contact__c, 후원자번호) --> 실제 Id로 맵핑 된 후, 다른 key에서 오류났을 경우 다시 바꿔줘야 하기때문에 만든 temp map.
            Map<String, String> mapTemp = new Map<String, String>();
            for(Map<String, String> objMap : listMap) {//데이터 한줄
                mapTemp = new Map<String, String>();
                record = Schema.getGlobalDescribe().get(strObject).newSObject(); //Object를 해당 Object로 설정
                try {
                    for (String key : objMap.keySet()) {//데이터 한줄의 필드
                        if (!listFields.contains(key)) {
                            listFields.add(key);
                        }
                        // 엑셀 데이터 중에서 - 가 들어가 있는 부분들이 있음
                        // if (key == 'seq' || key == '-' || key.indexOf('__EMPTY') > -1) {
                        //     continue;
                        // }
                        // 2022-09-14 EMPTY 포함한 컬럼은 제외처리 by.이대운
                        if (key == 'seq' || key == '-' || key.contains('EMPTY')) {
                            System.debug('woon_2 :: ' + key);
                            continue;
                        }


                        //공백은 update를 하지 않음
                        if (objMap.get(key).trim() == null || objMap.get(key).trim() == '' || objMap.get(key).trim().length() == 0) {
                            continue;
                        }

                        // 타입에 맞게 record에 삽입
                        if (!key.contains('__r')) {
                            //DATE 형식
                            System.debug('Yerin key ::' + key);
                            if (result.fields.getMap().get(key).getDescribe().getType() == Schema.DisplayType.DATE) {
                                if(objMap.get(key).contains('null') || objMap.get(key).contains('Null') || objMap.get(key).contains('NULL')){
                                    record.put(key, null);
                                }
                                else{
                                    record.put(key, Date.valueOf(objMap.get(key).trim()));
                                }
                            }
                            //DATETIME 형식
                            else if (result.fields.getMap().get(key).getDescribe().getType() == Schema.DisplayType.DATETIME) {
                                //Datatime 형식 자체에 공백이 있어서 Trim을 쓰면 안됨
                                //System.debug('DATETIME');
                                if(objMap.get(key).contains('null') || objMap.get(key).contains('Null') || objMap.get(key).contains('NULL')){
                                    record.put(key, null);
                                }
                                else{
                                    if(objMap.get(key).contains('T')){
                                        String strDate = objMap.get(key).trim().split('T')[0];
                                        String strTime = objMap.get(key).trim().split('T')[1].substring(0, 8);
                                        record.put(key, Datetime.valueOf(strDate + ' ' + strTime));
                                    }
                                    else{
                                        record.put(key, Datetime.valueOf(objMap.get(key)));
                                    }
                                }
                            }
                            //CURRENCY 형식
                            else if (result.fields.getMap().get(key).getDescribe().getType() == Schema.DisplayType.CURRENCY
                                    || result.fields.getMap().get(key).getDescribe().getType() == Schema.DisplayType.DOUBLE) {
                                //System.debug('CURRENCY');
                                if(objMap.get(key).contains('null') || objMap.get(key).contains('Null') || objMap.get(key).contains('NULL')){
                                    record.put(key, null);
                                }
                                else{
                                    record.put(key, Double.valueOf(objMap.get(key).trim().replaceAll(',', '')));
                                }

                            }
                            //INTEGER 형식
                            else if (result.fields.getMap().get(key).getDescribe().getType() == Schema.DisplayType.INTEGER) {
                                //System.debug('INTEGER');
                                if(objMap.get(key).contains('null') || objMap.get(key).contains('Null') || objMap.get(key).contains('NULL')){
                                    record.put(key, null);
                                }
                                else{
                                    record.put(key, Integer.valueOf(objMap.get(key).trim().replaceAll(',', '')));
                                }
                            }
                            //PERCENT 형식
                            else if (result.fields.getMap().get(key).getDescribe().getType() == Schema.DisplayType.PERCENT) {
                                //System.debug('percent');
                                if(objMap.get(key).contains('null') || objMap.get(key).contains('Null') || objMap.get(key).contains('NULL')){
                                    record.put(key, null);
                                }
                                else{
                                    record.put(key, Decimal.valueOf(objMap.get(key).trim()));
                                }
                            }
                            //BOOLEAN 형식
                            else if (result.fields.getMap().get(key).getDescribe().getType() == Schema.DisplayType.BOOLEAN) {
                                //System.debug('bool');
                                if(objMap.get(key).contains('null') || objMap.get(key).contains('Null') || objMap.get(key).contains('NULL')){
                                    record.put(key, false);
                                }
                                else{
                                    record.put(key, objMap.get(key).trim() == 'TRUE' ? true : false);
                                }
                            } else {
                                System.debug('text or reference ... ' + key);
                                if(objMap.get(key).contains('null') || objMap.get(key).contains('Null') || objMap.get(key).contains('NULL')){
                                    record.put(key, null);
                                }
                                else if(mapUnique.get(key) != null){ //UniqueId로 해야할경우
                                    //mapRealId가 아예 존재하지 않는다는 말은 제대로 들어간 룩업 필드가 아예 없다는 뜻, 인서트만 존재한다는 의미가 아님
                                    if(mapRealId.keySet().isEmpty()){
                                        objMap.put('Error', '해당 Lookup 필드의 데이터가 존재하는지 확인해주세요.');
                                        objMap.put('ErrorNumber', String.valueOf(errorNum++));
                                        lmTypeError.add(objMap);
                                        isNoId = true;
                                        //System.debug('objMap null : ' + objMap);
                                        break;
                                    }
                                    else if(!mapRealId.get(key).keySet().contains(objMap.get(key))){ //ex) 실제 데이터에 해당 후원자번호를 가진 후원자가 없을경우
                                        objMap.put('Error', '해당 Lookup 필드의 데이터가 존재하는지 확인해주세요.');
                                        objMap.put('ErrorNumber', String.valueOf(errorNum++));
                                        lmTypeError.add(objMap);
                                        isNoId = true;
                                        //System.debug('objMap : ' + objMap);
                                        break;
                                    }
                                    else{
                                        //mapTemp.put(key, objMap.get(key));
                                        record.put(key, mapRealId.get(key).get(objMap.get(key)));
                                    }
                                }
                                else if(key == 'Id' || key == 'ID'){
                                    //mapRecordId 아예 존재하지 않는다는 말은 제대로 들어간 룩업 필드가 아예 없다는 뜻, 인서트만 존재한다는 의미가 아님
                                    if(mapRecordId.keySet().isEmpty()){
                                        objMap.put('Error', '해당 번호(Id)를 가진 데이터가 존재하지 않습니다.');
                                        objMap.put('ErrorNumber', String.valueOf(errorNum++));
                                        lmTypeError.add(objMap);
                                        isNoId = true;
                                        break;
                                    }
                                    else if(!mapRecordId.keySet().contains(objMap.get(key))){//실제 데이터에 해당 Id 를 가진 데이터가 없을 경우
                                        objMap.put('Error', '해당 번호(Id)를 가진 데이터가 존재하지 않습니다.');
                                        objMap.put('ErrorNumber', String.valueOf(errorNum++));
                                        lmTypeError.add(objMap);
                                        isNoId = true;
                                        break;
                                    }
                                    else{
                                        //mapTemp.put(key, objMap.get(key));
                                        record.put(key, mapRecordId.get(objMap.get(key).trim()));
                                    }
                                }
                                else{
                                    record.put(key, objMap.get(key).trim());
                                }
                            }
                        }
                    }
                    if(!objMap.keySet().contains('OwnerId') && strObject == 'Case'){
                        List<Group> listGroup = [
                                SELECT Id
                                FROM Group
                                WHERE DeveloperName = 'CenterQueue'
                        ];
                        if(!listGroup.isEmpty()){
                            record.put('OwnerId', listGroup[0].Id);
                        }
                    }
                } catch (TypeException e) {
                    //형변환 에러 추출
                    if(isNoId == false){
                        objMap.put('Error', '데이터 형식을 확인해주세요.');
                        objMap.put('ErrorNumber', String.valueOf(errorNum++));
                        lmTypeError.add(objMap);
                        System.debug('TypeException : ' + e);
                        System.debug('listFailedDataWrapper : ' + listFailedDataWrapper);
                    }
                    continue;
                }
                System.debug('record3: ' + record);
                if(isNoId == false){
                    listObj.add(record);
                    System.debug('record4: ' + record);
                }
                //True가 된것은 다시 false로 설정하기 위함.
                isNoId = false;
            }

            if (strObject.endsWith('__x')) {
                //특정 Object에 대한 처리
                if (!listObj.isEmpty()) {
                    System.debug('listObj is not empty');
//                  srExternalList = Database.insertAsync(listObj);
                    srExternalList = Database.insertImmediate(listObj);
                }
                else{
                    System.debug('listObj is empty');
                    return new FailedDataWrapper(lmTypeError, listDMLError, listDmlErrorMsg, listDMLErrorNum, mapRecordIdReverse, strReturnMessage, listFields, '0');
                }
            }
            else{
                if (!listObj.isEmpty()) {
                    System.debug('listObj is not empty');
                    srList = Database.upsert(listObj, false);
                }
                else{
                    System.debug('listObj is empty');
                    return new FailedDataWrapper(lmTypeError, listDMLError, listDmlErrorMsg, listDMLErrorNum, mapRecordIdReverse, strReturnMessage, listFields, '0');
                }
            }

            if(!strObject.endsWith('__x')){
                //insert error
                intSuccessCount = 0;
                System.debug('srList : ' + srList);
                for (Integer i = 0; i < srList.size(); i++) {
                    if (srList[i].isSuccess()) {
                        System.debug('Successfully inserted. Id: ' + srList[i].getId());
                        intSuccessCount++;
                    } else {
                        System.debug('Insert Error:: ' + listObj.get(i));
                        //DMLError 처리는 Helper에서...
                        listDMLError.add(listObj.get(i));
                        listDMLErrorNum.add(String.valueOf(errorNum++));
                        //DML insert error 추출 ---> ex) 필수값 안넣기, PickList bad value, ...
                        if(String.valueOf(srList[i].getErrors()).contains('RESTRICTED_PICKLIST')){
                            System.debug('Error:: ' + srList[i].getErrors());
                            listDmlErrorMsg.add('선택목록 값을 확인해주세요.');
                        }
                        else if(String.valueOf(srList[i].getErrors()).contains('REQUIRED_FIELD_MISSING')){
                            System.debug('Error:: ' + srList[i].getErrors());
                            listDmlErrorMsg.add('필수값이 누락되었습니다.');
                        }
                        else if(String.valueOf(srList[i].getErrors()).contains('VALIDATION_EXCEPTION')){
                            List<String> listErrorMsg = String.valueOf(srList[i].getErrors()).split(';');
                            String errorMsg = '';
                            errorMsg = listErrorMsg[1].split('=')[1];
                            System.debug('Error:: ' + errorMsg);
                            listDmlErrorMsg.add(errorMsg);
                        }
                        else{
                            System.debug('Error:: ' + srList[i].getErrors());
                            listDmlErrorMsg.add(String.valueOf(srList[i].getErrors()));
                        }
                    }
                }
            }
            else{
                //insert error
                intSuccessCount = 0;
                System.debug('srExternalList : ' + srExternalList);
                for (Integer i = 0; i < srExternalList.size(); i++) {
                    if (srExternalList[i].isSuccess()) {
                        System.debug('Successfully inserted. Id: ' + srExternalList[i].getId());
                        intSuccessCount++;
                    } else {
                        System.debug('Insert Error:: ' + listObj.get(i));
                        if(String.valueOf(srExternalList[i].getErrors()).contains('ASYNC_OPERATION_LOCATOR')){ //오류로 간주안함
                            System.debug('ASYNC_OPERATION_LOCATOR');
                            intSuccessCount++;
                            break;
                        }
                        else{
                            //DMLError 처리는 Helper에서...
                            listDMLError.add(listObj.get(i));
                            listDMLErrorNum.add(String.valueOf(errorNum++));
                            //DML insert error 추출 ---> ex) 필수값 안넣기, PickList bad value, ...
                            if(String.valueOf(srExternalList[i].getErrors()).contains('RESTRICTED_PICKLIST')){
                                System.debug('Error:: ' + srExternalList[i].getErrors());
                                listDmlErrorMsg.add('선택목록 값을 확인해주세요.');
                            }
                            else if(String.valueOf(srExternalList[i].getErrors()).contains('REQUIRED_FIELD_MISSING')){
                                System.debug('Error:: ' + srExternalList[i].getErrors());
                                listDmlErrorMsg.add('필수값이 누락되었습니다.');
                            }
                            else if(String.valueOf(srExternalList[i].getErrors()).contains('VALIDATION_EXCEPTION')){
                                List<String> listErrorMsg = String.valueOf(srExternalList[i].getErrors()).split(';');
                                String errorMsg = '';
                                errorMsg = listErrorMsg[1].split('=')[1];
                                System.debug('Error:: ' + errorMsg);
                                listDmlErrorMsg.add(errorMsg);
                            }
                            else{
                                System.debug('Error:: ' + srExternalList[i].getErrors());
                                listDmlErrorMsg.add(String.valueOf(srExternalList[i].getErrors()));
                            }
                        }

                    }
                }
            }

            strReturnMessage = 'SUCCESS||' + listObj.size();
            System.debug('strReturnMessage :: ' + strReturnMessage);
        } catch (Exception e) {
            Database.rollback(sp);
            strReturnMessage = 'ERROR||' + e.getMessage() + '/' + e.getLineNumber();
            System.debug('error : ' + strReturnMessage);
            System.debug('error Name: ' + e);
        }


        //lmTypeError id -> number
        for(Map<String, String> objMap : lmTypeError){
            System.debug('objMap : ' + objMap);
            for(String key : objMap.keySet()){
                if(key == 'Id'){
                    System.debug('type Id change');
                    //System.debug('mapRecordIdReverse.get(objMap.get(key)) :' + mapRecordIdReverse.get(objMap.get(key)));
                    if(mapRecordIdReverse.keySet().contains(String.valueOf(objMap.get(key)))){
                        System.debug('type Id change22');
                        objMap.put(key, mapRecordIdReverse.get(objMap.get(key)));
                    }
                }
                if(mapUnique.get(key) != null){
                    System.debug('type look up change : ' + key + ' : ' + mapRealIdReverse.get(key).get(objMap.get(key)));
                    if(mapRealIdReverse.get(key).keySet().contains(objMap.get(key))){
                        objMap.put(key, mapRealIdReverse.get(key).get(objMap.get(key)));
                    }
                }
            }
            System.debug('type Error id to Number : ' +objMap);
        }

        //listDMLError id -> number
        String uniNum = '';
        if(!listDMLError.isEmpty()){
            for(SObject obj : listDMLError){
                //Id가 존재하면, 즉 Update 이라면 원래 유니크 번호값으로 바꿔줌
                System.debug('before dml error id check ');
                /*if(obj.Id != null){
                    System.debug('dml Id change');
                    uniNum = mapRecordIdReverse.get(obj.Id);
                    obj.Id = uniNum;
                }*/

                //Lookup필드 유니크 번호 값으로 바꿔줌
                for(String key : mapRealIdReverse.keySet()){
                    if(mapRealIdReverse.get(key).keySet().contains(String.valueOf(obj.get(key)))){
                        uniNum = mapRealIdReverse.get(key).get(String.valueOf(obj.get(key)));
                        System.debug('dml lookup change :' + String.valueOf(obj.get(key)) + ' to ' + uniNum);
                        obj.put(key, uniNum);
                    }
                }
            }
            System.debug('DML Error id to Number : ' + listDMLError);
        }

        //Return 값
        FailedDataWrapper failedDataWrapper = new FailedDataWrapper(lmTypeError, listDMLError, listDmlErrorMsg, listDMLErrorNum, mapRecordIdReverse, strReturnMessage, listFields, String.valueOf(intSuccessCount));

        System.debug(failedDataWrapper);
        return failedDataWrapper;
    }
}