var map;
var marker;
var geocoder = new google.maps.Geocoder();
var address = "{!Account.BillingStreet}, " + "{!Account.BillingCity}, " + "{!Account.BillingPostalCode}, " + "{!Account.BillingCountry}";
var infowindow = new google.maps.InfoWindow({
    content: "<b>{!Account.Name}</b><br>{!Account.BillingStreet}<br>{!Account.BillingCity}, {!Account.BillingPostalCode}<br>{!Account.BillingCountry}"
});

$(document).ready(function() {
    initMap();
    /*
    geocoder.geocode( { address: address}, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK && results.length) {
            if (status != google.maps.GeocoderStatus.ZERO_RESULTS) {

                //create map
                map = new google.maps.Map(document.getElementById("map"), myOptions);

                //center map
                map.setCenter(results[0].geometry.location);

                //create marker
                marker = new google.maps.Marker({
                    position: results[0].geometry.location,
                    map: map,
                    title: "{!Account.Name}"
                });

                //add listeners
                google.maps.event.addListener(marker, 'click', function() {
                    infowindow.open(map,marker);
                });
                google.maps.event.addListener(infowindow, 'closeclick', function() {
                    map.setCenter(marker.getPosition());
                });
            }
        } else {
            $('#map').css({'height' : '15px'});
            $('#map').html("Oops! {!Account.Name}'s billing address could not be found, please make sure the address is correct.");
            resizeIframe();
        }
    });
    */
});

function initMap() {
    console.log("initMap");

    var myOptions = {
        zoom: 15,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        mapTypeControl: false,
        center : {lat : 37.549505, lng : 127.050386}
    }

    //create map
    map = new google.maps.Map(document.getElementById("map"), myOptions);
}

function resizeIframe() {
    var me = window.name;
    if (me) {
        var iframes = parent.document.getElementsByName(me);
        if (iframes && iframes.length == 1) {
            height = document.body.offsetHeight;
            iframes[0].style.height = height + "px";
        }
    }
}

function drawMarker() {
    labelCnt += 1;
    locationMarker = new google.maps.Marker({
        position: {lat : 37.549505, lng : 127.050386},
        map: map,
        draggable: true,
        label: labelCnt.toString()
    });
}