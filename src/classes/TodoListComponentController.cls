/**
 * Created by JWJANG on 2023-01-03.
 */

public with sharing class TodoListComponentController {

    @AuraEnabled
    public static Map<String, String> getInitData() {
        System.debug('[TodoListComponentController getInitData] Start !!');

        Map<String, String> mapResult = new Map<String, String>();
        User objUser = [SELECT  Id, Name
        FROM    User
        WHERE   Id = :UserInfo.getUserId()];

        mapResult.put('userId', objUser.Id);
        mapResult.put('userName', objUser.Name);
        mapResult.put('vfHostUrl', Url.getSalesforceBaseUrl().toExternalForm());

        System.debug('[TodoListComponentController getInitData] End !!');
        return mapResult;
    }

    @AuraEnabled
    public static Map<String, Object> searchList(String searchDate, String searchCondition, String searchUser) {
        System.debug('[TodoListComponentController searchList] Start !!');

        Map<String, Object> mapResult = new Map<String, Object>();

        try {
            // mapMarkers
            List<Map<String, Object>> mapMarkers = new List<Map<String, Object>>();
            Integer labelCnt = 0;

            // mapMarkers - Task
            if('All'.equals(searchCondition) || 'Task'.equals(searchCondition)) {
                List<Task> listTask = [ SELECT Id, Subject, Description, ActivityDate, VisitTime__c, VisitLocation__Latitude__s, VisitLocation__Longitude__s, WhoId
                FROM Task
                WHERE ActivityDate = :Date.valueOf(searchDate)
                AND OwnerId = :searchUser
                ORDER BY ActivityDate, VisitTime__c];

                Set<String> setContactId = new Set<String>();
                for(Task objTask : listTask) {
                    setContactId.add(objTask.WhoId);
                }
                Map<String, Contact> mapContact = new Map<String, Contact>();
                for(Contact objContact : [SELECT Id, Name, Phone, Email, Title, Account.Name FROM Contact WHERE Id IN :setContactId]) {
                    mapContact.put(objContact.Id, objContact);
                }

                for(Task obj : listTask) {
                    Map<String, Object> mapMarker = new Map<String, Object>();
                    mapMarker.put('lat', obj.VisitLocation__Latitude__s);
                    mapMarker.put('lng', obj.VisitLocation__Longitude__s);
                    mapMarker.put('title', obj.Subject);
                    mapMarker.put('icon', 'standard:task');
                    mapMarker.put('Url', String.format('{0}/lightning/r/Task/{1}/view', new List<Object> { Url.getSalesforceBaseUrl().toExternalForm(), obj.Id}));
                    mapMarker.put('dueDate', obj.ActivityDate);
                    if(obj.VisitTime__c != null) { mapMarker.put('visitTime', obj.VisitTime__c.format('yyyy-MM-dd HH:mm:ss')); }
                    mapMarker.put('objId', obj.Id);
                    mapMarker.put('label', String.valueOf(++labelCnt));
                    mapMarker.put('Subject', obj.Subject);
                    mapMarker.put('objectName', 'Task');
                    if(mapContact.get(obj.WhoId) != null) {
                        Contact objContact = mapContact.get(obj.WhoId);
                        mapMarker.put('contactName', String.format('{0}/{1} {2}', new List<Object> { objContact.Account.Name, objContact.Name, objContact.Title }));
                        mapMarker.put('contactUrl', String.format('{0}/lightning/r/Contact/{1}/view', new List<Object> { Url.getSalesforceBaseUrl().toExternalForm(), obj.WhoId}));
                    }
                    mapMarkers.add(mapMarker);
                }
            }

            // mapMarkers - Event
            if('All'.equals(searchCondition) || 'Event'.equals(searchCondition)) {
                List<Event> listEvent = [   SELECT Id, Subject, Description, ActivityDate, VisitTime__c, VisitLocation__Latitude__s, VisitLocation__Longitude__s, WhoId
                FROM Event
                WHERE ActivityDate = :Date.valueOf(searchDate)
                AND OwnerId = :searchUser
                ORDER BY ActivityDate];

                Set<String> setContactId = new Set<String>();
                for(Event objEvent : listEvent) {
                    setContactId.add(objEvent.WhoId);
                }
                Map<String, Contact> mapContact = new Map<String, Contact>();
                for(Contact objContact : [SELECT Id, Name, Phone, Email, Title, Account.Name FROM Contact WHERE Id IN :setContactId]) {
                    mapContact.put(objContact.Id, objContact);
                }

                for(Event obj : listEvent) {
                    Map<String, Object> mapMarker = new Map<String, Object>();
                    mapMarker.put('lat', obj.VisitLocation__Latitude__s);
                    mapMarker.put('lng', obj.VisitLocation__Longitude__s);
                    mapMarker.put('title', obj.Subject);
                    mapMarker.put('icon', 'standard:event');
                    mapMarker.put('Url', String.format('{0}/lightning/r/Event/{1}/view', new List<Object> { Url.getSalesforceBaseUrl().toExternalForm(), obj.Id}));
                    mapMarker.put('dueDate', obj.ActivityDate);
                    if(obj.VisitTime__c != null) { mapMarker.put('visitTime', obj.VisitTime__c.format('yyyy-MM-dd HH:mm:ss')); }
                    mapMarker.put('objId', obj.Id);
                    mapMarker.put('label', String.valueOf(++labelCnt));
                    mapMarker.put('Subject', obj.Subject);
                    mapMarker.put('objectName', 'Event');
                    if(mapContact.get(obj.WhoId) != null) {
                        Contact objContact = mapContact.get(obj.WhoId);
                        mapMarker.put('contactName', String.format('{0}/{1} {2}', new List<Object> { objContact.Account.Name, objContact.Name, objContact.Title }));
                        mapMarker.put('contactUrl', String.format('{0}/lightning/r/Contact/{1}/view', new List<Object> { Url.getSalesforceBaseUrl().toExternalForm(), obj.WhoId}));
                    }
                    mapMarkers.add(mapMarker);
                }
            }

            // TODO - List 정렬 ( ActivityDate )
            mapResult.put('mapMarkers', mapMarkers);
        } catch (Exception e) {
            System.debug(e.getMessage() + ' Line : ' + e.getLineNumber());
        }

        System.debug('[TodoListComponentController searchList] End !!');
        return mapResult;
    }
}