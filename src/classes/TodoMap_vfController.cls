/**
 * Created by JWJANG on 2023-01-03.
 */

public with sharing class TodoMap_vfController {
    public String mapCenterStr { get; set; }
    public Map<String, Decimal> mapCenter { get; set; }

    public String mapMarkersStr { get; set; }
    public List<Map<String, Object>> mapMarkers { get; set; }

    public String searchDate { get; set;}
    public String searchCondition { get; set;}
    public String searchUser { get; set;}

    public TodoMap_vfController() {
        // Center (DaeuNextier)
        Map<String, Decimal> mapCenter = new Map<String, Decimal>();
        mapCenter.put('lat', 37.549505);
        mapCenter.put('lng', 127.050386);
        this.mapCenter = mapCenter;
        this.mapCenterStr = JSON.serialize(mapCenter);

        this.searchDate = String.format('{0}-{1}-{2}', new List<Object> {
                Date.today().year(),
                Date.today().month() < 10 ? '0' + String.valueOf(Date.today().month()) : String.valueOf(Date.today().month()),
                Date.today().day() < 10 ? '0' + String.valueOf(Date.today().day()) : String.valueOf(Date.today().day())
        });
        this.searchCondition = 'All';

        User objUser = [SELECT  Id, Name
        FROM    User
        WHERE   Id = :UserInfo.getUserId()];
        this.searchUser = objUser.Id;

        // mapMarkers
        getInitData();
    }

    public void getInitData() {
        System.debug('[TodoMap_vfController getInitData] Start !!');

        System.debug('searchDate : ' + searchDate);
        System.debug('searchCondition : ' + searchCondition);
        System.debug('searchUser : ' + searchUser);

        // mapMarkers
        List<Map<String, Object>> mapMarkers = new List<Map<String, Object>>();
        Integer labelCnt = 0;

        // mapMarkers - Task
        if('All'.equals(searchCondition) || 'Task'.equals(searchCondition)) {
            List<Task> listTask = [ SELECT Id, Subject, Description, ActivityDate, VisitLocation__Latitude__s, VisitLocation__Longitude__s
            FROM Task
            WHERE ActivityDate = :Date.valueOf(searchDate)
            AND OwnerId = :searchUser
            ORDER BY ActivityDate, VisitTime__c];

            for(Task obj : listTask) {
                Map<String, Object> mapMarker = new Map<String, Object>();
                mapMarker.put('lat', obj.VisitLocation__Latitude__s);
                mapMarker.put('lng', obj.VisitLocation__Longitude__s);
                mapMarker.put('title', obj.Subject);
                mapMarker.put('icon', 'standard:task');
                mapMarker.put('Url', String.format('{0}/lightning/r/Task/{1}/view', new List<Object> { Url.getSalesforceBaseUrl().toExternalForm(), obj.Id}));
                mapMarker.put('dueDate', obj.ActivityDate);
                mapMarker.put('objId', obj.Id);
                mapMarker.put('label', String.valueOf(++labelCnt));
                mapMarker.put('Subject', obj.Subject);
                mapMarker.put('objectName', 'Task');
                mapMarkers.add(mapMarker);
            }
        }

        // mapMarkers - Event
        if('All'.equals(searchCondition) || 'Event'.equals(searchCondition)) {
            List<Event> listEvent = [   SELECT Id, Subject, Description, ActivityDate, VisitLocation__Latitude__s, VisitLocation__Longitude__s
            FROM Event
            WHERE ActivityDate = :Date.valueOf(searchDate)
            AND OwnerId = :searchUser
            ORDER BY ActivityDate, VisitTime__c];

            for(Event obj : listEvent) {
                Map<String, Object> mapMarker = new Map<String, Object>();
                mapMarker.put('lat', obj.VisitLocation__Latitude__s);
                mapMarker.put('lng', obj.VisitLocation__Longitude__s);
                mapMarker.put('title', obj.Subject);
                mapMarker.put('icon', 'standard:event');
                mapMarker.put('Url', String.format('{0}/lightning/r/Event/{1}/view', new List<Object> { Url.getSalesforceBaseUrl().toExternalForm(), obj.Id}));
                mapMarker.put('dueDate', obj.ActivityDate);
                mapMarker.put('objId', obj.Id);
                mapMarker.put('label', String.valueOf(++labelCnt));
                mapMarker.put('Subject', obj.Subject);
                mapMarker.put('objectName', 'Event');
                mapMarkers.add(mapMarker);
            }
        }

        // TODO - List 정렬 ( ActivityDate )
        this.mapMarkers = mapMarkers;
        this.mapMarkersStr = JSON.serialize(mapMarkers);
        System.debug('[TodoMap_vfController getInitData] mapMarkers : ' + mapMarkers.size());

        System.debug('[TodoMap_vfController getInitData] End !!');
    }
}