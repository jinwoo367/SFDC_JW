/**
 * Created by sjhyk on 2023-01-03.
 */

({
    created : function(component, event, helper) {
        helper.created(component, event);
    },

    renderCalendar : function(component, event, helper) {
        var eventsMap = component.get("v.events");
        console.log('eventsMap >>');
        console.log(eventsMap);

        $(document).ready(function() {
            var eventArray = [];

            $.each(eventsMap, function(index, value) {
                var newEvent = {
                    id : value.Id,
                    title : value.title,
                    start : moment(value.startDateTime),
                    end : moment(value.endDateTime),
                    description : value.description,
                    owner : value.owner,
                    visitTime : value.visitTime
                }
                eventArray.push(newEvent);
            });
            console.log(eventArray);

            var calendarButtons = component.get('v.calendarButtons');
            $('#calendar').fullCalendar({
                header: {
                    left: 'today prev,next',
                    center: 'title',
                    right: 'month,agendaWeek,agendaDay,listWeek'
                },
                defaultDate: moment().format("YYYY-MM-DD"),
                navLinks: true, // can click day/week names to navigate views
                editable: false,
                selectable: true,
                displayEventTime: false,
                eventDurationEditable: true,
                eventLimit: true, // allow "more" link when too many events
                weekends: component.get('v.weekends'),
                eventBackgroundColor: component.get('v.eventBackgroundColor'),
                eventBorderColor: component.get('v.eventBorderColor'),
                eventTextColor: component.get('v.eventTextColor'),
                events: eventArray,
                eventClick: function(calEvent, jsEvent, view) {

                    //여기에서 Task 디테일 페이지로 이동함
                    helper.doNavigateRecordPage(component, calEvent);
                    /*
                    //기존 제공 소스 주석처리
                    component.set('v.titleVal', calEvent.title);
                    component.set('v.descriptionVal', calEvent.description);
                    component.set('v.startDateTimeVal', moment(calEvent.start._d).format());
                    component.set('v.endDateTimeVal', moment(calEvent.end._d).format());//이값이 없음
                    component.set('v.idVal', calEvent.id);
                    component.set('v.newOrEdit', 'Edit');
                    */
                    //기존 모달 팝업 --> 주석처리
                    //helper.openModal(component, event);
                },
                eventMouseover: function(calEvent, jsEvent, view) {
                    console.log('mouseover');

                    component.set('v.titleVal', calEvent.title);
                    component.set('v.descriptionVal', calEvent.description);
                    component.set('v.startDateTimeVal', moment(calEvent.start._d).format());
                    //component.set('v.endDateTimeVal', moment(calEvent.end._d).format());//이값이 없음
                    component.set('v.idVal', calEvent.id);
                    component.set('v.newOrEdit', 'Edit');

                    //기존 모달 팝업 --> 주석처리
                    //helper.openModal(component, event);
                },

                eventDrop: function(event, delta, revertFunc) {
                    var evObj = {
                        "Id" : event.id,
                        "title" : event.title,
                        "startDateTime" : moment(event.start._i).add(delta).format(),
                        "endDateTime" : moment(event.end._i).add(delta).format(),
                        "description" : event.description
                    };
                    helper.upsertEvent(component, evObj);
                },
                eventResize: function(event, delta, revertFunc) {
                    var evObj = {
                        "Id" : event.id,
                        "title" : event.title,
                        "startDateTime" : moment(event.start._i).format(),
                        "endDateTime" : moment(event.end._i).add(delta).format(),
                        "description" : event.description
                    };
                    helper.upsertEvent(component, evObj);
                },
                dayClick: function(date, jsEvent, view, resourceObj) {
                    console.log('날짜 클릭 시 >>');
                    console.log('date >>' + date.toISOString());
                    console.log('jsEvent >>' + jsEvent.pageX);
                    console.log('view >>' + view.name);
                    console.log('resourceObj >>' + resourceObj);

                    var userId = $A.get("$SObjectType.CurrentUser.Id");
                    console.log('userId >> ' + userId);

                    var dateList = date.format().toString().split('-');     // YYYY MM DD
                    var startDateTime = new Date(dateList[0], parseInt(dateList[1]) - 1, parseInt(dateList[2]), new Date().getHours() + 1, 0, 0, 0);
                    var endDateTime = new Date(dateList[0], parseInt(dateList[1]) - 1, parseInt(dateList[2]), new Date().getHours() + 2, 0, 0, 0);
                    console.log('startDateTime : ' + startDateTime);
                    console.log('endDateTime : ' + endDateTime);

                    var windowHash = window.location.hash;
                    var windowHash2 = 'https://deau4-dev-ed.lightning.force.com/lightning/n/Demo123';
                    console.log("windowHash > " + windowHash);
                    console.log("windowHash2 > " + windowHash2);
                    var createEvent = $A.get("e.force:createRecord");
                    createEvent.setParams({
                        "entityApiName": "Event",
                        'defaultFieldValues': {
                            'OwnerId' : userId,
                            'StartDateTime' : startDateTime,
                            'EndDateTime' : endDateTime
                        },
                        "navigationLocation": "LOOKUP",
                        "panelOnDestroyCallback": function(event) {
                            //console.log("test");
                            //$A.get("e.force:refreshView").fire();
                            console.log("close");
                            $A.get("e.force:closeQuickAction").fire();
                        }
                    });
                    createEvent.fire();


                    /*if (date._f == "YYYY-MM-DD"){
                        console.log(date._f);
                        component.set('v.startDateTimeVal', moment(date.format()).add(12, 'hours').format());
                        component.set('v.endDateTimeVal', moment(date.format()).add(14, 'hours').format());
                    } else {
                        component.set('v.startDateTimeVal', moment(date.format()).format());
                        component.set('v.endDateTimeVal', moment(date.format()).add(2, 'hours').format());
                    }
                    component.set('v.newOrEdit', 'New');
                    helper.openModal(component, event);*/
                }
            });
        });
    },

    createRecord : function(component, event, helper) {
        var evObj = {
            "title" : component.get('v.titleVal'),
            "startDateTime" : moment(component.get('v.startDateTimeVal')).format(),
            "endDateTime" : moment(component.get('v.endDateTimeVal')).format(),
            "description" : component.get('v.descriptionVal')
        };
        if (component.get('v.idVal')) {
            evObj.id = component.get('v.idVal');
            $('#calendar').fullCalendar( 'removeEvents', component.get('v.idVal') );
        }
        helper.upsertEvent(component, evObj, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var newEvent = {
                    id : response.getReturnValue().Id,
                    title : response.getReturnValue().title,
                    start : moment(response.getReturnValue().startDateTime),
                    end : moment(response.getReturnValue().endDateTime),
                    description : response.getReturnValue().description,
                    owner : response.getReturnValue().owner
                }
                $('#calendar').fullCalendar( 'renderEvent', newEvent );
                helper.closeModal(component, event);
                component.set('v.titleVal','');
                component.set('v.idVal','');
                component.set('v.startDateTimeVal','');
                component.set('v.endDateTimeVal','');
                component.set('v.descriptionVal','');
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
    },
    deleteRecord : function(component, event, helper) {
        helper.deleteEvent(component, event, event.getSource().get("v.value"), function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                $('#calendar').fullCalendar( 'removeEvents', response.getReturnValue());
                helper.closeModal(component, event);
                component.set('v.titleVal','');
                component.set('v.idVal','');
                component.set('v.startDateTimeVal','');
                component.set('v.endDateTimeVal','');
                component.set('v.descriptionVal','');
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
    },
    openModal : function(component, event, helper) {
        helper.openModal(component, event);
    },
    closeModal : function(component, event, helper) {
        helper.closeModal(component, event);
    }
});