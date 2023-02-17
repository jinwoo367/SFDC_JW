/**
 * Created by JWJANG on 2023-02-17.
 */

@IsTest
public with sharing class SObjectUtil_Test {
    @IsTest
    static void SObjectUtil_Test() {
        SObjectUtil.getAllPickListValueMap('Account');
        SObjectUtil.getAllPickListValueMap('Account2');
        SObjectUtil.getAllPickListValueMap('Account', 'AccountSource');
        SObjectUtil.getAllPickListValueMap('Account2', 'AccountSource');
        SObjectUtil.getAllPickListValueList('Account');
        SObjectUtil.getAllPickListValueList('Account2');
        SObjectUtil.getAllPickListValueList('Account', 'AccountSource');
        SObjectUtil.getAllPickListValueList('Account2', 'AccountSource');
    }
}