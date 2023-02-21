/**
 * Created by JWJANG on 2023-01-30.
 */

public with sharing class QCReportButtonController {

    @AuraEnabled
    public static Map<String, String> savePdf(Id recordId) {
        generatePDF(recordId);

        Map<String, String> resultMap = new Map<String, String>();
        resultMap.put('result', 'SUCCESS');
        System.debug(resultMap);

        return resultMap;
    }

    @Future(Callout=true)
    public static void generatePDF(Id recordId) {
        PageReference pdfPage = new PageReference('/apex/QCReportPage?recordId=' + recordId);
        Blob pdfPageData = pdfPage.getContentAsPDF();
        System.debug(pdfPage.getUrl());
        System.debug(pdfPageData);

        /*
        QCReport__c qcReport = [
                SELECT Id, Name, CountryQ__c, CompanyClinic__c, MODELQ__c, SNQ__c, IssueDate__c, IssueSympton__c, CauseRequest__c, ManufacturingDate__c
                FROM QCReport__c
                WHERE Id =: recordId
        ];
        */

        ContentVersion objContentVersion = new ContentVersion();
        // objContentVersion.Title = qcReport.Name;
        objContentVersion.Title = 'Title';
        objContentVersion.VersionData = pdfPageData;
        // objContentVersion.PathOnClient = qcReport.Name + '.pdf';
        objContentVersion.PathOnClient = 'Title.pdf';
        objContentVersion.FirstPublishLocationId = recordId;

        Database.SaveResult InsertResult = Database.insert(objContentVersion);

        if(InsertResult.isSuccess()) {
            System.debug('Success :: Insert PDF!');

            ContentVersion objContent = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :objContentVersion.Id];
            List<ContentDocumentLink> listCdl = new List<ContentDocumentLink>([
                    SELECT Id, ShareType, Visibility
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :recordId
                    AND ContentDocumentId = :objContent.ContentDocumentId
            ]);

            if (!listCdl.isEmpty()) {
                ContentDocumentLink cdl = listCdl.get(0);
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
                update cdl;
            } else {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = recordId;
                cdl.ContentDocumentId = objContent.ContentDocumentId;
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
                insert cdl;
            }
        }
    }
}