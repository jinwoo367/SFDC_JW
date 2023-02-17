/**
 * Created by JWJANG on 2022-12-27.
 */

import { LightningElement, api, wire, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import JQuery from '@salesforce/resourceUrl/JQuery';

export default class googleMap extends LightningElement {
    librariesLoaded = false;

    // Modal Popup Flag
    openModalFlag = false;

    @track mapMarkers;
    @track mapOptions;
    @track mapCenter;

    mapCenter = { location: { Latitude: '37.549505', Longitude: '127.050386' } };
    mapOptions = {
        'disableDefaultUI': false, // when true disables Map|Satellite, +|- zoom buttons
        'draggable': true // when false prevents panning by dragging on the map
    };
    mapMarkers = [
        {
            location: { Latitude: '37.549505', Longitude: '127.050386' },
            title: 'The Landmark Building',
            description: 'Historic <b>11-story</b> building completed in <i>1916</i>',
            value: 'location001',
            icon: 'standard:account'
        }
    ];

    renderedCallback() {
        if (this.librariesLoaded) return;
        this.librariesLoaded = true;

        Promise.all([
            loadScript(this, JQuery + '/jquery-3.6.3.min.js')])
            .then(() => {
                console.log("success");
            })
            .catch(error => {
                console.log("error while loading script");
            });
    }

    doTest(event) {
        console.log('do Test');
        mapMarker = {
            location: { Latitude: '37.549000', Longitude: '127.049169' },
            title: 'The Landmark Building',
            description: 'Historic <b>11-story</b> building completed in <i>1916</i>',
            value: 'location001',
            icon: 'standard:account'
        };
        this.mapMarkers.push(mapMarker);
        console.log(this.mapMarkers);
    }

    openModal(event) {
        this.openModalFlag = true;
    }

    closeModal(event) {
        this.openModalFlag = false;
    }
}