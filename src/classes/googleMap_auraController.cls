/**
 * Created by JWJANG on 2022-12-27.
 */

public with sharing class googleMap_auraController {

    @AuraEnabled
    public static Map<String, Object> getInitData() {
        System.debug('[googleMap_auraController fnInit] Start !!');

        Map<String, Object> mapResult = new Map<String, Object>();

        // Center
        Map<String, Map<String, String>> mapCenter = new Map<String, Map<String, String>>();
        Map<String, String> location = new Map<String, String>();
        location.put('Latitude', '37.549505');
        location.put('Longitude', '127.050386');
        mapCenter.put('location', location);
        mapResult.put('mapCenter', mapCenter);

        // Options
        Map<String, Boolean> mapOptions = new Map<String, Boolean>();
        mapOptions.put('disableDefaultUI', false);  // when true disables Map|Satellite, +|- zoom buttons
        mapOptions.put('draggable', true);          // when false prevents panning by dragging on the map
        mapResult.put('mapOptions', mapOptions);

        // SELECT TASK
        List<Task> listTask = [SELECT Id, Subject, Description FROM Task LIMIT 10];

        // mapMarkers
        List<Map<String, Object>> mapMarkers = new List<Map<String, Object>>();
        for(Task obj : listTask) {
            Map<String, Object> mapMarker = new Map<String, Object>();
            Map<String, String> location2 = new Map<String, String>();
            location2.put('Latitude', '37.54' + Integer.valueOf(Math.random() * 9999));
            location2.put('Longitude', '127.04' + Integer.valueOf(Math.random() * 9999));

            mapMarker.put('location', location2);
            mapMarker.put('title', 'The Landmark Building');
            mapMarker.put('description', 'Historic <b>11-story</b> building completed in <i>1916</i>');
            mapMarker.put('value', obj.Id);
            mapMarker.put('icon', 'standard:account');
            mapMarker.put('Subject', obj.Subject);
            mapMarker.put('Description', obj.Description);
            mapMarkers.add(mapMarker);
        }
        mapResult.put('mapMarkers', mapMarkers);

        System.debug('[googleMap_auraController fnInit] End !!');
        return mapResult;
    }

    @AuraEnabled
    public static Map<String, Object> addMarkerByObj() {
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