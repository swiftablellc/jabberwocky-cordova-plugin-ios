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

var JabberwockyHeadTracking = function() {}

JabberwockyHeadTracking._headTrackingEventObservers = [];

JabberwockyHeadTracking._processFunctionList = function(array, param) {
    for (var i = 0; i < array.length; i++)
        array[i](param);
};

/*
 Default HTFeature list for Cordova. Any HTFeature implementation can be loaded, but will need to be prefixed
 by the owning Framework. If it is defined in the cordova app then use the current app name.

 @see https://github.com/swiftablellc/jabberwocky-head-tracking-kit-ios/tree/master/JabberwockyHTKit/Features
 */
JabberwockyHeadTracking.prototype.getDefaultCordovaFeatures = function() {
   return ["JabberwockyHTKit.BannerWarningsFeature",
           "JabberwockyHTKit.CoreEventProxyFeature",
           "JabberwockyHTKit.CursorDrawFeature",
           "JabberwockyHTKit.CursorRecalibrationFeature",
           "JabberwockyHTKit.RemoteSettingsFeature"];
};

JabberwockyHeadTracking.prototype.configure = function(features, onSuccess, onFailure) {
    if (onSuccess == null)
        onSuccess = function() {};
    if (onFailure == null)
        onFailure = function() {};

    cordova.exec(onSuccess, onFailure, "JabberwockyHeadTracking", "configure", [features])
}

JabberwockyHeadTracking.prototype.enable = function(onSuccess, onFailure) {
    if (onSuccess == null)
        onSuccess = function() {};
    if (onFailure == null)
        onFailure = function() {};

    cordova.exec(onSuccess, onFailure, "JabberwockyHeadTracking", "enable", [])
}

JabberwockyHeadTracking.prototype.disable = function(onSuccess) {
    if (onSuccess == null)
        onSuccess = function() {};

    cordova.exec(onSuccess, function() {}, "JabberwockyHeadTracking", "disable", [])
}

JabberwockyHeadTracking.prototype.getSettings = function(onSuccess, onFailure) {
    if (onSuccess == null)
        onSuccess = function() {};
    if (onFailure == null)
        onFailure = function() {};

    cordova.exec(onSuccess, onFailure, "JabberwockyHeadTracking", "getSettings", [])
}

JabberwockyHeadTracking.prototype.changeSetting = function(settingKey, settingValue, onSuccess, onFailure) {
    if (onSuccess == null)
        onSuccess = function() {};
    if (onFailure == null)
        onFailure = function() {};

    cordova.exec(onSuccess, onFailure, "JabberwockyHeadTracking", "changeSetting", [settingKey, settingValue])
}

JabberwockyHeadTracking.prototype.addHeadTrackingEventObserver = function(handleEventCallback) {
    JabberwockyHeadTracking._headTrackingEventObservers.push(handleEventCallback);
    var headTrackingEventCallbackProcessor = function(state) {
        JabberwockyHeadTracking._processFunctionList(JabberwockyHeadTracking._headTrackingEventObservers, state);
    };
    cordova.exec(handleEventCallback, function() {}, "JabberwockyHeadTracking", "addHeadTrackingEventObserver", []);
};

//-------------------------------------------------------------------

if(!window.plugins) {
    window.plugins = {};
}

if (!window.plugins.JabberwockyHeadTracking) {
    window.plugins.JabberwockyHeadTracking = new JabberwockyHeadTracking();
}

if (typeof module != 'undefined' && module.exports) {
    module.exports = JabberwockyHeadTracking;
}
