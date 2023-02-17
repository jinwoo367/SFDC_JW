/**
* Test Class                    : SObjectUtil_Test.cls
* Description                   : Util Class
* Modification Log
* ===============================================================
* Ver       Date            Author          Modification
* ===============================================================
* 1.0       2023.02.17      Jinwoo Jang     Create
*/
public with sharing class SObjectUtil {

    /**
     * @param sObjectName
     * @description SObject 내에 있는 모든 필드 정보를 가져온다.
     *
     * @return  Map<String, Map<String, Object>>
     * @example SObjectUtil.getFields('Account'); =>
     * ({label=Account ID, name=Id, type=ID}, {label=Deleted, name=IsDeleted, type=BOOLEAN}, ...)
     */
    public static Map<String, Map<String, Object>> getFields(String sObjectName) {
        System.debug(String.format('SObjectUtil.getFields({0})', new List<Object> { sObjectName }));

        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sObjectName);
        if(sObj == null) {
            System.debug(String.format('SObjectUtil.getFields({0}) :: The queried SObject does not exist.', new List<Object> { sObjectName }));
            return null;
        }
        System.debug(sObj.getDescribe().fields.getMap());

        Map<String, Map<String, Object>> mapFields = new Map<String, Map<String, Object>>();
        for(SObjectField field : sObj.getDescribe().fields.getMap().values()) {
            DescribeFieldResult f = field.getDescribe();
            mapFields.put(f.getName(), new Map<String, Object> {
                    'label' => f.getLabel(),
                    'name' => f.getName(),
                    'type' => f.getType(),
                    'values' => f.getPicklistValues()
            });
        }
        System.debug(String.format('SObjectUtil.getFields({0}) :: {1}', new List<Object> { sObjectName, mapFields }));

        return mapFields;
    }

    /**
     * @param sObjectName
     * @description SObject 내에 있는 모든 필드 중 타입이 "PickList"인 정보를 가져온다.
     *
     * @return Map<String, List<Map<String, String>>>
     * @example SObjectUtil.getAllPickListValueMap('Account'); =>
     * {AccountSource=({label=Web, value=Web}, {label=Phone Inquiry, value=Phone Inquiry}, ...), ...}
     */
    public static Map<String, List<Map<String, String>>> getAllPickListValueMap(String sObjectName) {
        System.debug(String.format('SObjectUtil.getAllPickListValueMap({0})', new List<Object> { sObjectName }));

        Map<String, List<Map<String, String>>> mapValues = new Map<String, List<Map<String, String>>>();
        Map<String, Map<String, Object>> mapFields = getFields(sObjectName);
        if(mapFields == null) {
            return null;
        }

        for(Map<String, Object> field : mapFields.values()) {
            if('PICKLIST'.equals(String.valueOf(field.get('type')))) {
                mapValues.put(String.valueOf(field.get('name')), getValueMap((List<PicklistEntry>) field.get('values')));
            }
        }
        System.debug(String.format('SObjectUtil.getAllPickListValueMap({0}) :: {1}', new List<Object> { sObjectName, mapValues }));

        return mapValues;
    }

    /**
     * @param sObjectName
     * @param fieldName
     * @description SObject 내의 하나의 필드의 "PickList" 정보를 가져온다.
     *
     * @return List<Map<String, String>>
     * @example SObjectUtil.getAllPickListValueMap('Account', 'AccountSource'); =>
     * ({label=Web, value=Web}, {label=Phone Inquiry, value=Phone Inquiry}, {label=Partner Referral, value=Partner Referral}, ...)
     */
    public static List<Map<String, String>> getAllPickListValueMap(String sObjectName, String fieldName) {
        System.debug(String.format('SObjectUtil.getAllPickListValueMap({0} - {1})', new List<Object> { sObjectName, fieldName }));

        Map<String, Map<String, Object>> mapFields = getFields(sObjectName);
        if(mapFields == null) {
            return null;
        }

        List<Map<String, String>> mapValues = getValueMap((List<PicklistEntry>) mapFields.get(fieldName).get('values'));
        System.debug(String.format('SObjectUtil.getAllPickListValueMap({0} - {1}) :: {2}', new List<Object> { sObjectName, fieldName, mapValues }));

        return mapValues;
    }

    /**
     * @param sObjectName
     * @description SObject 내에 있는 모든 필드 중 타입이 "PickList"인 정보를 가져온다.
     *
     * @return Map<String, List<String>>
     * @example SObjectUtil.getAllPickListValueList('Account'); =>
     * {AccountSource=(Web, Phone Inquiry, Partner Referral, ...), ...}
     */
    public static Map<String, List<String>> getAllPickListValueList(String sObjectName) {
        System.debug(String.format('SObjectUtil.getAllPickListValueMap({0})', new List<Object> { sObjectName }));

        Map<String, List<String>> listValues = new Map<String, List<String>>();
        Map<String, Map<String, Object>> mapFields = getFields(sObjectName);
        if(mapFields == null) {
            return null;
        }

        for(Map<String, Object> field : mapFields.values()) {
            if('PICKLIST'.equals(String.valueOf(field.get('type')))) {
                listValues.put(String.valueOf(field.get('name')), getValueList((List<PicklistEntry>) field.get('values')));
            }
        }
        System.debug(String.format('SObjectUtil.getAllPickListValueMap({0}) :: {1}', new List<Object> { sObjectName, listValues }));

        return listValues;
    }

    /**
     * @param sObjectName
     * @param fieldName
     * @description SObject 내의 하나의 필드의 "PickList" 정보를 가져온다.
     *
     * @return List<String>
     * @example SObjectUtil.getAllPickListValueList('Account', 'AccountSource'); =>
     * (Web, Phone Inquiry, Partner Referral, Purchased List, Other)
     */
    public static List<String> getAllPickListValueList(String sObjectName, String fieldName) {
        System.debug(String.format('SObjectUtil.getAllPickListValueList({0} - {1})', new List<Object> { sObjectName, fieldName }));

        Map<String, Map<String, Object>> mapFields = getFields(sObjectName);
        if(mapFields == null) {
            return null;
        }

        List<String> listValues = getValueList((List<PicklistEntry>) mapFields.get(fieldName).get('values'));
        System.debug(String.format('SObjectUtil.getAllPickListValueList({0} - {1}) :: {2}', new List<Object> { sObjectName, fieldName, listValues }));

        return listValues;
    }

    private static List<Map<String, String>> getValueMap(List<PicklistEntry> values) {
        List<Map<String, String>> resultList = new List<Map<String, String>>();
        for(PicklistEntry entry : values) {
            resultList.add(new Map<String, String> {
                    'label' => entry.getLabel(),
                    'value' => entry.getValue()
            });
        }

        return resultList;
    }

    private static List<String> getValueList(List<PicklistEntry> values) {
        List<String> resultList = new List<String>();
        for(PicklistEntry entry : values) {
            resultList.add(entry.getValue());
        }

        return resultList;
    }
}