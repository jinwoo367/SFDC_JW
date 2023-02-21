public with sharing class LookupFieldController {
    @AuraEnabled
    public static List<SObject> GetRecentRecords(String ObjectName, List<String> ReturnFields, Integer MaxResults) {

        List<Id> recentIds = new List<Id>();
        for(RecentlyViewed recent : [SELECT Id FROM RecentlyViewed WHERE Type = :ObjectName ORDER BY LastViewedDate DESC LIMIT :MaxResults]) {
            recentIds.add(recent.Id);
        }

        String sQuery = 'SELECT Id, ';

        if (ReturnFields != null && ReturnFields.size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';
        }

        sQuery += ' FROM ' + ObjectName + ' WHERE Id IN :recentIds';

        List<SObject> searchResult = Database.query(sQuery);

        return searchResult;
    }

    @AuraEnabled
    public static List<SObject> SearchRecords(String ObjectName, List<String> ReturnFields, List<String> QueryFields, String SearchText, String SortColumn, String SortOrder, Integer MaxResults, String Filter) {

        //always put a limit on the results
        if (MaxResults == null || MaxResults == 0) {
            MaxResults = 5;
        }

        SearchText = '%' + SearchText + '%';

        List <SObject > returnList = new List < SObject > ();

        String sQuery =  'SELECT Id, ';

        if (ReturnFields != null && ReturnFields.size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';
        }

        sQuery += ' FROM ' + ObjectName + ' WHERE ';

        if (QueryFields == null || QueryFields.isEmpty()) {
            sQuery += ' Name LIKE :SearchText ';
        } else {
            String likeField = '';
            for(String field : QueryFields) {
                likeField += ' OR ' + field + ' LIKE :SearchText ';
            }
            sQuery += ' (' + likeField.removeStart(' OR ') + ') ';
        }

        if (Filter != null) {
            sQuery += ' AND (' + Filter + ')';
        }

        if(String.isNotBlank(SortColumn) && String.isNotBlank(SortOrder)) {
            sQuery += ' ORDER BY ' + SortColumn + ' ' + SortOrder;
        }

        sQuery += ' LIMIT ' + MaxResults;

        System.debug(sQuery);

        List <SObject> searchResult = Database.query(sQuery);

        return searchResult;
    }

    @AuraEnabled
    public static List<SObject> GetRecord(String ObjectName, List<String> ReturnFields, String Id) {
        String sQuery = 'SELECT Id, ';

        if (ReturnFields != null && ReturnFields.size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';
        }

        sQuery += ' FROM ' + ObjectName + ' WHERE Id = :Id';

        List<SObject> searchResult = Database.query(sQuery);

        return searchResult;
    }

    @AuraEnabled
    public static String findObjectIcon(String ObjectName) {
        // String u;
        // List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        // List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult describeTabSetResult : Schema.describeTabs()) {
            for(Schema.DescribeTabResult describeTabResult : describeTabSetResult.getTabs()) {
                if(describeTabResult.getSobjectName() == ObjectName) {
                    if( describeTabResult.isCustom() == true ) {
                        for (Schema.DescribeIconResult describeIcon : describeTabResult.getIcons()) {
                            if (describeIcon.getContentType() == 'image/svg+xml'){
                                return 'custom:' + describeIcon.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                            }
                        }
                    } else {
                        return 'standard:' + ObjectName.toLowerCase();
                    }
                }
            }
        }

        return 'standard:default';
    }

    @AuraEnabled
    public static ObjectDetails getObjectDetails(String ObjectName) {

        ObjectDetails details = new ObjectDetails();

        Schema.DescribeSObjectResult describeSObjectsResult = Schema.describeSObjects(new List<String>{ObjectName})[0];

        details.label = describeSObjectsResult.getLabel();
        details.pluralLabel = describeSObjectsResult.getLabelPlural();

        details.iconName = findObjectIcon(ObjectName);

        return details;
    }

    public class ObjectDetails {
        @AuraEnabled
        public String iconName;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String pluralLabel;
    }
}