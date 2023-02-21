public with sharing class AnyEventCalCtrl {
    @AuraEnabled
    public static List<EventObj> getEvents(String sObjectName, String recordTypeId, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String userField, Boolean filterByUserField){
        System.debug('sObjectName: ' + sObjectName);
        System.debug('titleField: ' + titleField);
        System.debug('recordTypeId: ' + recordTypeId);
        System.debug('startDateTimeField: ' + startDateTimeField);
        System.debug('endDateTimeField: ' + endDateTimeField);
        System.debug('userField: ' + userField);

        String q = 'SELECT Id,' +
                String.valueOf(titleField) + ',' +
                String.valueOf(startDateTimeField) + ',' +
                String.valueOf(endDateTimeField) + ',' +
                String.valueOf(descriptionField) + ',' +
                String.valueOf(userField) + ', VisitTime__c FROM ' +
                String.valueOf(sObjectName) +
                ' WHERE ' + String.valueOf(userField) + ' = \'' + UserInfo.getUserId() + '\'' +
                (recordTypeId != '' ? ' AND RecordTypeId = \'' + recordTypeId + '\'' : '');
        if (!filterByUserField) {
            q = 'SELECT Id,' +
                    String.valueOf(titleField) + ',' +
                    String.valueOf(startDateTimeField) + ',' +
                    String.valueOf(endDateTimeField) + ',' +
                    String.valueOf(descriptionField) + ',' +
                    String.valueOf(userField) + ', VisitTime__c FROM ' +
                    String.valueOf(sObjectName) +
                    (recordTypeId != '' ? ' WHERE RecordTypeId = \'' + recordTypeId + '\'' : '');
        }
        System.debug('query: ' + q);
        List<SObject> sObjectList = Database.query(q);

        List<EventObj> eventRecords = new List<EventObj>();
        if(isAccessible(sObjectName)) {
            DateTime startDate;

            for (sObject obj : sObjectList) {
                startDate = DateTime.valueOf(obj.get(startDateTimeField));
                String description = '';
                try {
                    description = descriptionField.contains('.') ? (obj.getSObject(descriptionField.split('\\.')[0])).get(descriptionField.split('\\.')[1]).toString()
                            : obj.get(descriptionField).toString();
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }

                EventObj newEv = new EventObj(obj.Id,
                        String.valueOf(String.format('{0} {1} {2}', new List<Object>{
                                startDate.format('h a'), description, obj.get(titleField)
                        })),
                        Datetime.valueOf(obj.get(startDateTimeField)),
                        Datetime.valueOf(obj.get(endDateTimeField)),
                        String.valueOf(description),
                        String.valueOf(obj.get(userField)),
                        String.valueOf(obj.get('VisitTime__c'))
                );
                eventRecords.add(newEv);
            }
        }
        return eventRecords;
    }

    @AuraEnabled
    public static EventObj upsertEvents(String sEventObj, String sObjectName, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String userField){
        EventObj upsertingEvent = (EventObj)JSON.deserialize(sEventObj, EventObj.class);
        sObject newRecord = Schema.getGlobalDescribe().get(sObjectName).newSObject();

        if (upsertingEvent.Id != null && isAccessible(sObjectName,'Id')) {
            newRecord.put('Id',upsertingEvent.Id);
        }
        if (isAccessible(sObjectName,titleField)) {
            newRecord.put(titleField, upsertingEvent.title);
        }
        if (isAccessible(sObjectName,startDateTimeField)) {
            newRecord.put(startDateTimeField, upsertingEvent.startDateTime);
        }
        if (isAccessible(sObjectName,endDateTimeField)) {
            newRecord.put(endDateTimeField, upsertingEvent.endDateTime);
        }
        if (isAccessible(sObjectName,descriptionField)) {
            newRecord.put(descriptionField, upsertingEvent.description);
        }
        System.debug('[AnyEventCalCtrl] titleField : ' + upsertingEvent.title);

        try {
            upsert newRecord;
            EventObj newEv = new EventObj(newRecord.Id,
                    String.valueOf(newRecord.get(titleField)),
                    Datetime.valueOf(newRecord.get(startDateTimeField)),
                    Datetime.valueOf(newRecord.get(endDateTimeField)),
                    String.valueOf(newRecord.get(descriptionField)),
                    String.valueOf(newRecord.get(userField)),
                    String.valueOf(newRecord.get('VisitTime__c'))
            );
            return newEv;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    public class EventObj {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String startDateTime {get;set;}
        @AuraEnabled
        public String endDateTime {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String owner {get;set;}
        @AuraEnabled
        public String visitTime {get;set;}

        public EventObj(String i, String t, Datetime s, Datetime e, String d, String o, String v){
            this.Id = i;
            this.title = t;
            this.startDateTime = String.valueOf(s).replace(' ', 'T');
            this.endDateTime = String.valueOf(e).replace(' ', 'T');
            this.description = d;
            this.owner = o;
            this.visitTime = v;
        }
    }

    public static Boolean isAccessible(String sObjectType, String fieldName){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        return fieldDescribe.isAccessible();
    }
    public static Boolean isAccessible(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isAccessible();
    }
    public static Boolean isCreateable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isCreateable();
    }
    public static Boolean isDeletable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isDeletable();
    }
}