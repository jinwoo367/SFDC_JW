/**
 * Created by JWJANG on 2023-02-21.
 */

public with sharing class CPRDExcelUploadController {
    @AuraEnabled
    public static String doSave(String excelData){
        String result = 'success^||^데이터 생성 성공';
        try {
            System.debug(excelData);
            // List<F2FRD__c> listTarget = (List<F2FRD__c>) JSON.deserializeStrict(excelData, List<F2FRD__c>.class);

            // Id DRTVRecordTypeId = Schema.SObjectType.F2FRD__c.getRecordTypeInfosByDeveloperName().get('DRTV').getRecordTypeId();
            // for(F2FRD__c obj : listTarget){
            //     obj.RecordTypeId = DRTVRecordTypeId;
            // }
            // System.debug(listTarget);
            // if(!listTarget.isEmpty()){
            //     insert listTarget;
            // }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '[ERROR][Line: ' + e.getLineNumber() + '] StackTraceString: ' + e.getStackTraceString() + ' / Message: ' + e.getMessage() + ' / Cause: ' + e.getCause());
            result = 'error^||^[ERROR][Line: ' + e.getLineNumber() + '] StackTraceString: ' + e.getStackTraceString() + ' / Message: ' + e.getMessage() + ' / Cause: ' + e.getCause();
        }
        return result;
    }
}