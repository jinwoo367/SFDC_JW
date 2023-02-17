/**
 * Created by JWJANG on 2023-01-02.
 */

public with sharing class GoogleMap_vfController {

    public String str { get;set; }
    public Map<String, Map<String, String>> mapCenter { get; set; }
    public Map<String, Boolean> mapOptions { get; set; }
    public List<Map<String, Object>> mapMarkers { get; set; }

    public GoogleMap_vfController() {
        getInitData();
    }

    public void getInitData() {
        System.debug('[googleMap_auraController fnInit] Start !!');

        Map<String, Object> mapResult = new Map<String, Object>();

        // Center
        Map<String, Map<String, String>> mapCenter = new Map<String, Map<String, String>>();
        Map<String, String> location = new Map<String, String>();
        location.put('Latitude', '37.549505');
        location.put('Longitude', '127.050386');
        mapCenter.put('location', location);
        this.mapCenter = mapCenter;

        // Options
        Map<String, Boolean> mapOptions = new Map<String, Boolean>();
        mapOptions.put('disableDefaultUI', false);  // when true disables Map|Satellite, +|- zoom buttons
        mapOptions.put('draggable', true);          // when false prevents panning by dragging on the map
        this.mapOptions = mapOptions;

        // mapMarkers
        List<Map<String, Object>> mapMarkers = new List<Map<String, Object>>();

        // mapMarkers - Task
        List<Task> listTask = [SELECT Id, Subject, Description FROM Task WHERE ActivityDate = TODAY];
        for(Task obj : listTask) {
            Map<String, Object> mapMarker = new Map<String, Object>();
            mapMarker.put('location', getLocation());
            mapMarker.put('title', obj.Subject);
            mapMarker.put('description', String.format('{0}', new List<Object>{ obj.Description == null ? '' : obj.Description }));
            mapMarker.put('icon', 'standard:task');
            mapMarker.put('value', obj.Id);
            mapMarker.put('label', '1');
            mapMarker.put('Subject', obj.Subject);
            mapMarker.put('Description', obj.Description == null ? '' : obj.Description);
            mapMarker.put('objectName', 'Task');
            mapMarkers.add(mapMarker);
        }

        // mapMarkers - Event
        List<Event> listEvent = [SELECT Id, Subject, Description FROM Event WHERE ActivityDate = TODAY];
        for(Event obj : listEvent) {
            Map<String, Object> mapMarker = new Map<String, Object>();
            mapMarker.put('location', getLocation());
            mapMarker.put('title', obj.Subject);
            mapMarker.put('description', String.format('{0}', new List<Object>{ obj.Description == null ? '' : obj.Description }));
            mapMarker.put('icon', 'standard:event');
            mapMarker.put('value', obj.Id);
            mapMarker.put('label', '1');
            mapMarker.put('Subject', obj.Subject);
            mapMarker.put('Description', obj.Description == null ? '' : obj.Description);
            mapMarker.put('objectName', 'Event');
            mapMarkers.add(mapMarker);
        }
        this.mapMarkers = mapMarkers;

        System.debug('[googleMap_auraController fnInit] End !!');
    }

    private Map<String, String> getLocation() {
        Map<String, String> location = new Map<String, String>();
        location.put('Latitude', '37.54' + Integer.valueOf(Math.random() * 9999));
        location.put('Longitude', '127.04' + Integer.valueOf(Math.random() * 9999));

        return location;
    }

    public Map<String, Object> addMarkerByObj() {
        System.debug('[googleMap_auraController addMarkerByObj] Start !!');

        Map<String, Object> mapResult = new Map<String, Object>();

        Map<String, String> location = new Map<String, String>();
        location.put('Latitude', '37.54' + Integer.valueOf(Math.random() * 9999));
        location.put('Longitude', '127.04' + Integer.valueOf(Math.random() * 9999));

        // new Task
        Task objTask = new Task();
        insert objTask;

        // mapMarkers
        List<Map<String, Object>> mapMarkers = new List<Map<String, Object>>();
        Map<String, Object> mapMarker = new Map<String, Object>();
        mapMarker.put('location', location);
        mapMarker.put('title', 'The Landmark Building');
        mapMarker.put('description', 'Historic <b>11-story</b> building completed in <i>1916</i>');
        mapMarker.put('icon', 'standard:account');
        mapMarker.put('value', objTask.Id);
        mapMarker.put('Subject', 'Worldwide Corporate Headquarters');
        mapMarker.put('Description', 'The Landmark @ One Market, San Francisco, CA');
        mapMarkers.add(mapMarker);
        mapResult.put('mapMarkers', mapMarkers);

        System.debug('[googleMap_auraController addMarkerByObj] End !!');
        return mapResult;
    }
}