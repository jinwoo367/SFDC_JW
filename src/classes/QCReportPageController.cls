/**
 * Created by JWJANG on 2023-01-27.
 */

public with sharing class QCReportPageController {
    public String recordId { get; set; }

    public QCReportPageController() {
        recordId = ApexPages.currentPage().getParameters().get('recordId');

        /*
        qcReport = [
                SELECT Id, Name, CountryQ__c, CompanyClinic__c, MODELQ__c, SNQ__c, IssueDate__c, IssueSympton__c, CauseRequest__c, ManufacturingDate__c
                FROM QCReport__c
                WHERE Id =: recordId
        ];
        */
    }
}