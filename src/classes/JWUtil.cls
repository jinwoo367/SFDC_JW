/**
* Test Class                    : JWUtil.cls
* Description                   : Util Class
* Modification Log
* ===============================================================
* Ver       Date            Author          Modification
* ===============================================================
* 1.0       2023.02.17      Jinwoo Jang     Create
*/
public with sharing class JWUtil {

    /**
     * @PARAM sObjectName (SObject Name)
     * @DESCRIPTION SObject 내에 있는 모든 필드 정보를 가져온다.
     */
    public static void getFields(String sObjectName) {
        System.debug(String.format('JWUtil.getFields({0})', new List<Object> { sObjectName }));

        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sObjectName);
        System.debug(String.format());

        Schema.SObjectType sObj = GlobalDescribeMap
        if(sObj == null) {
            System.debug(null);
            return;
        }

        System.debug(sObj.getDescribe().fields.getMap());

        for(SObjectField field : sObj.getDescribe().fields.getMap().values()) {
            System.debug(String.format('{0}, {1}, {2}, {3}', new List<Object> {
                    field.getDescribe().getLabel(),
                    field.getDescribe().getName(),
                    field.getDescribe().getType(),
                    field.getDescribe().getPicklistValues()
            }));
        }
    }

    public static void log(String sObjectName, Object obj) {

    }
}