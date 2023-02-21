public with sharing class ManagedCalenderMainController {

    @AuraEnabled
    public static Map<String, String> getInitData() {

        User objUser = [SELECT  Id, Name
        FROM    User
        WHERE   Id = :UserInfo.getUserId()];

        System.debug('user name > ' + objUser.Name);
        Map<String, String> mapReturnValue = new Map<String, String> ();
        mapReturnValue.put('Id', objUser.Id);
        mapReturnValue.put('Name', objUser.Name);
        return mapReturnValue;
    }

    @AuraEnabled
    public static List<WrapperOpportunities> doSearchOpportunities(String selectedStage, String OpportunityUserId, String selectedId) {
        System.debug('doSearchOpportunities Start >>');
        System.debug('selectedStage >> ' + selectedStage);
        System.debug('OpportunityUserId >> ' + OpportunityUserId);
        System.debug('selectedId >> ' + selectedId);

        List<WrapperOpportunities> ReturnOpportunities = new List<WrapperOpportunities>();
        List<Opportunity> listOpportunities = new List<Opportunity>();

        String strQuery = '';
        strQuery += '   SELECT      Id, AccountId, Name, Amount, Description, Account.Name, StageName, contact__c, contact__r.Name, user__c, Account.BillingLatitude, Account.BillingLongitude';
        strQuery += '   FROM        Opportunity';
        strQuery += '   WHERE       user__c = \'' + OpportunityUserId + '\'';
        if(selectedId != null) {
            strQuery += '   AND       AccountId =: selectedId';
        }
        if(selectedStage != null && selectedStage != '' && selectedStage != 'null') {
            strQuery += '   AND       StageName = : selectedStage ';
        }
        strQuery += '   ORDER BY    createdDate DESC';
        strQuery += '   LIMIT       6';

        listOpportunities = Database.query(strQuery);

        Map<Id, OpportunityLineItem> mapOppItems = new Map<Id, OpportunityLineItem>();
        for(OpportunityLineItem objItem : [SELECT OpportunityId, Product2.Name FROM OpportunityLineItem]) {
            mapOppItems.put(objItem.OpportunityId, objItem);
        }

        System.debug('listOpportunities >>> ' + listOpportunities);

        WrapperOpportunities listOpp;
        for(Opportunity obj : listOpportunities) {
            listOpp = new WrapperOpportunities();
            listOpp.OppId = obj.Id;
            listOpp.AccountId = obj.AccountId;
            listOpp.Name = obj.Name;
            listOpp.Amount = obj.Amount;
            listOpp.Description = obj.Description;
            listOpp.AccountName = obj.Account.Name;
            listOpp.url = '/' + obj.Id;
            listOpp.contactUrl = '/' + obj.contact__c;
            listOpp.ContactName = obj.contact__r.Name;
            listOpp.StageName = obj.StageName;
            listOpp.lat = obj.Account.BillingLatitude;
            listOpp.lng = obj.Account.BillingLongitude;
            if(mapOppItems.get(obj.Id) != null) listOpp.OppItem = mapOppItems.get(obj.Id).Product2.Name;
            ReturnOpportunities.add(listOpp);
        }

        System.debug('ReturnOpportunities size>> ' + ReturnOpportunities.size());

        return ReturnOpportunities;
    }

    @AuraEnabled
    public static List<WrapperAccounts> doSearchAccounts(String selectedIndustry, String OpportunityUserId, String selectedId) {
        System.debug('doSearchOpportunities Start >>');
        System.debug('selectedIndustry >> ' + selectedIndustry);
        System.debug('OpportunityUserId >> ' + OpportunityUserId);

        String strQuery = '';
        strQuery += '   SELECT      Id, Key_Man__c, Name, WebSite, Industry, Key_Man__r.Name, Phone, user__c, BillingLatitude, BillingLongitude';
        strQuery += '   FROM        Account ';
        strQuery += '   WHERE       user__c = \'' + OpportunityUserId + '\'';
        if(selectedIndustry != null && selectedIndustry != '' && selectedIndustry != 'null') {
            strQuery += '   AND       Industry = : selectedIndustry ';
        }
        strQuery += '   ORDER BY    createdDate DESC ';
        strQuery += '   LIMIT       6';

        System.debug('strQuery >>>' + strQuery);
        List<Account> listAccounts = Database.query(strQuery);

        System.debug('Account >>> ' + listAccounts);

        List<WrapperAccounts> ReturnOpportunities = new List<WrapperAccounts>();
        WrapperAccounts listWrapper;
        for(Account obj : listAccounts) {
            listWrapper = new WrapperAccounts();
            listWrapper.AccountId = obj.Id;
            listWrapper.Name = obj.Name;
            listWrapper.WebSite = obj.WebSite;
            listWrapper.Industry = obj.Industry;
            listWrapper.Phone = obj.Phone;
            listWrapper.url = '/' + obj.Id;
            listWrapper.lat = obj.BillingLatitude;
            listWrapper.lng = obj.BillingLongitude;
            ReturnOpportunities.add(listWrapper);
        }

        System.debug('ReturnOpportunities size>> ' + ReturnOpportunities.size());

        return ReturnOpportunities;
    }

    @AuraEnabled
    public static List<WrapperAccounts> doSearchAccountOppti(String selectedIndustry, String OpportunityUserId, String selectedId) {
        System.debug('doSearchOpportunities Start >>');
        System.debug('selectedIndustry >> ' + selectedIndustry);
        System.debug('OpportunityUserId >> ' + OpportunityUserId);
        System.debug('selectedId >> ' + selectedId);
        String selectedId2 = selectedId;

        String strQuery = '';
        strQuery += '   SELECT      Account.Id, Account.Key_Man__c, Account.Name, Account.WebSite, Account.Industry, Account.Key_Man__r.Name, Account.Phone, Account.user__c, Account.BillingLatitude, Account.BillingLongitude';
        strQuery += '   FROM        Opportunity ';
        strQuery += '   WHERE       Account.user__c = \'' + OpportunityUserId + '\'';
        if(selectedId != null) {
            strQuery += '   AND       Id =: selectedId';
        }
        if(selectedIndustry != null && selectedIndustry != '' && selectedIndustry != 'null') {
            strQuery += '   AND       Account.Industry = : selectedIndustry ';
        }
        strQuery += '   ORDER BY    createdDate DESC ';
        strQuery += '   LIMIT       6';

        System.debug('strQuery >>>' + strQuery);
        List<Opportunity> listAccounts = Database.query(strQuery);

        System.debug('Account >>> ' + listAccounts);

        List<WrapperAccounts> ReturnOpportunities = new List<WrapperAccounts>();
        WrapperAccounts listWrapper;
        for(Opportunity obj : listAccounts) {
            listWrapper = new WrapperAccounts();
            listWrapper.AccountId = obj.Account.Id;
            listWrapper.Name = obj.Account.Name;
            listWrapper.WebSite = obj.Account.WebSite;
            listWrapper.Industry = obj.Account.Industry;
            listWrapper.Phone = obj.Account.Phone;
            listWrapper.url = '/' + obj.Account.Id;
            listWrapper.lat = obj.Account.BillingLatitude;
            listWrapper.lng = obj.Account.BillingLongitude;
            ReturnOpportunities.add(listWrapper);
        }

        System.debug('ReturnOpportunities size>> ' + ReturnOpportunities.size());

        return ReturnOpportunities;
    }

    public class WrapperOpportunities {
        @AuraEnabled public String OppId;
        @AuraEnabled public String AccountId;
        @AuraEnabled public String AccountName;
        @AuraEnabled public String Name;
        @AuraEnabled public Decimal Amount;
        @AuraEnabled public String Description;
        @AuraEnabled public String url;
        @AuraEnabled public String contactUrl;
        @AuraEnabled public String ContactName;
        @AuraEnabled public String StageName;
        @AuraEnabled public String OppItem;
        @AuraEnabled public Decimal lat;
        @AuraEnabled public Decimal lng;
    }

    public class WrapperAccounts {
        @AuraEnabled public String AccountId;
        @AuraEnabled public String Name;
        @AuraEnabled public String WebSite;
        @AuraEnabled public String Industry;
        @AuraEnabled public String Phone;
        @AuraEnabled public String url;
        @AuraEnabled public Decimal lat;
        @AuraEnabled public Decimal lng;
    }
}