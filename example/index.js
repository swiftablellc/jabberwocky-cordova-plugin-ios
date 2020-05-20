/*
Copyright 2020 Swiftable, LLC. <contact@swiftable.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
        this.receivedEvent('deviceready');

        var jabberwocky = window.plugins.JabberwockyHeadTracking

        jabberwocky.addHeadTrackingEventObserver(function(state) {
            // This is a lot of events...
            //if (state.type == 'HTCursorEvent') console.log(state);
        })

        jabberwocky.addHeadTrackingEventObserver(function(state) {
            if (state.type == 'HTBlinkEvent') console.log(state);
        });

        jabberwocky.addHeadTrackingEventObserver(function(state) {
            // 0: Face Lost - Fired once when Face is lost
            if (state.type == 'HTWarningEvent' && state.event.active && state.event.warning == 0)
                console.log("Face Lost!");
            // 1: Face Too Close - Continuously Fired Warning Event
            if (state.type == 'HTWarningEvent' && state.event.active && state.event.warning == 1)
                console.log("Face Too Close!");
            // 2: Face Too Far - Continuously Fired Warning Event
            if (state.type == 'HTWarningEvent' && state.event.active && state.event.warning == 2)
                console.log("Face Too Far!");
            // 3: Cursor On Edge Too Long
            if (state.type == 'HTWarningEvent' && state.event.active && state.event.warning == 3)
                console.log("Cursor On Edge Too Long!");
        });

        jabberwocky.configure(jabberwocky.getDefaultCordovaFeatures(), function() {
            jabberwocky.enable(function() {
                jabberwocky.getSettings(function(state) {
                    console.log(state);
                });
                jabberwocky.changeSetting("headMovementCorrection", "High", function(state) {
                    console.log(state);
                });
            });
        });
    },

    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

app.initialize();
