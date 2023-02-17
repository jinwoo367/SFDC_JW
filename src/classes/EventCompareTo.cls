/**
 * Created by JWJANG on 2023-01-09.
 */

global class EventCompareTo implements Comparable {
    public Map<String, Object> marker;
    public Date duoDate;
    public DateTime visitTime;


    // Constructor
    public EventCompareTo(Map<String, Object> mapMarker) {
        System.debug(mapMarker);
        System.debug(mapMarker.get('dueDate').toString());

        this.marker = mapMarker;
        this.duoDate = mapMarker.get('dueDate') == null ? null : Date.valueOf(mapMarker.get('dueDate').toString());
        this.visitTime = mapMarker.get('visitTime') == null ? null : DateTime.valueOf(mapMarker.get('visitTime').toString());
    }

    // Implement the compareTo() method
    global Integer compareTo(Object compareTo) {
        EventCompareTo compareToEmp = (EventCompareTo)compareTo;

        // Due Date
        if (duoDate == compareToEmp.duoDate) {
            if (visitTime.getTime() == compareToEmp.visitTime.getTime()) return 0;
            else if (visitTime.getTime() > compareToEmp.visitTime.getTime()) return 1;
            else return -1;
        }
        else if (this.duoDate > compareToEmp.duoDate) return 1;
        else return -1;
    }
}