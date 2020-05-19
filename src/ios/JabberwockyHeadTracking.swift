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

import Foundation

import AVFoundation
import JabberwockyHTKit


@objc(JabberwockyHeadTracking)
public class JabberwockyHeadTracking : CDVPlugin {

    static let CALLBACK_ID_KEY = "cordovaCallbackId"

    var headTrackingEventObserverCallbackIds: [String]!

    public override func pluginInitialize() {
        headTrackingEventObserverCallbackIds = []
    }

    // MARK: Cordova Exposed Methods
    @objc func configure(_ command: CDVInvokedUrlCommand) {
        // During configuration, we request access to
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if (granted) {
                // The observer for HTEventNotifications should always be active
                // regardless of whether Head Tracking is enabled or disabled because
                // settings changes can enable or disable Head Tracking.
                if self.observationInfo == nil {
                    NotificationCenter.default.addObserver(self,
                        selector: #selector(self.onHTEventNotification(_:)),
                        name: .htEventNotification, object: nil)
                }
                var htFeatures: [HTFeature.Type] = []
                if let featureClassNames = command.arguments[0] as? [String] {
                    for featureClassName in featureClassNames {
                        if let featureClass = NSClassFromString(featureClassName) as? HTFeature.Type {
                            htFeatures.append(featureClass)
                        }
                    }
                    DispatchQueue.main.async {
                        HeadTracking.configure(withFeatures: htFeatures)
                        self.successCallback(callbackId: command.callbackId, data: [:])
                    }
                }
            } else {
                NSLog("Jabberwocky Head Tracking requires camera access.")
                self.failureCallback(callbackId: command.callbackId, data: [:])
            }
        }
    }

    @objc func enable(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            HeadTracking.shared.enable(completion: {
                if $0 {
                    self.successCallback(callbackId: command.callbackId, data: [:])
                } else {
                    self.failureCallback(callbackId: command.callbackId, data: [:])
                }
            })
        }
    }

    @objc func disable(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            HeadTracking.shared.disable()
            self.successCallback(callbackId: command.callbackId, data: [:])
        }
    }

    @objc func getSettings(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            let requestContext: HTRequestContext = [
                JabberwockyHeadTracking.CALLBACK_ID_KEY: command.callbackId,
                "requestType": "GetSettingsRequest"
            ]
            NotificationCenter.default.post(
                name: .htOnSettingsRequestNotification, object: nil,
                userInfo: [NSNotification.htRequestContextKey: requestContext])
        }
    }

    @objc func changeSetting(_ command: CDVInvokedUrlCommand) {

        guard let settingsKey = command.arguments[0] as? String else { return }
        let settingsValue = command.arguments[1]

        DispatchQueue.main.async {
            let requestContext: HTRequestContext = [
                JabberwockyHeadTracking.CALLBACK_ID_KEY: command.callbackId,
                "requestType": "UpdateSettingsRequest",
                "requestBody": [
                    "settingsKey": settingsKey,
                    "settingsValue": settingsValue
                ]
            ]
            NotificationCenter.default.post(
                name: .htOnSettingsRequestNotification, object: nil,
                userInfo: [NSNotification.htRequestContextKey: requestContext])
        }
    }

    @objc func addHeadTrackingEventObserver(_ command: CDVInvokedUrlCommand) {
        headTrackingEventObserverCallbackIds.append(command.callbackId)
    }

    // MARK: Internal
    @objc private func onHTEventNotification(_ notification: NSNotification) {
        guard let eventContext = notification.userInfo?[NSNotification.htEventContextKey] as? HTEventContext else { return }
        guard let eventType = eventContext["eventType"] as? String else { return }
        guard let eventBody = eventContext["eventBody"] as? [String: Any] else { return }
        guard let eventError = eventContext["eventError"] as? Bool else {return }

        // RemoteSettingsFeature
        if eventType == "HTRemoteResponseEvent" {
            guard let remoteRequest = eventBody["remoteRequest"] as? [String: Any] else { return }
            guard let remoteResponse = eventBody["remoteResponse"] as? [String: Any] else { return }
            guard let callbackId = remoteRequest[JabberwockyHeadTracking.CALLBACK_ID_KEY] as? String else { return }
            handleRemoteResponseEvent(callbackId: callbackId, response: remoteResponse, isError: eventError)
        // CoreEventProxyFeature
        } else if ["HTBlinkEvent", "HTCursorEvent", "HTWarningEvent"].contains(eventType) && !eventError {
            handleHeadTrackingEvent(type: eventType, body: eventBody)
        }

    }

    private func handleRemoteResponseEvent(callbackId: String, response: [String: Any], isError: Bool) {
        var data: [String: Any] = [:]
        if isError {
            self.failureCallback(callbackId: callbackId, data: data)
        } else {
            if let responseBody = response["responseBody"] as? [String: Any] {
                data = responseBody
            }
            self.successCallback(callbackId: callbackId, data: data)
        }
    }

    private func handleHeadTrackingEvent(type: String, body: [String: Any]) {
        for callbackId in headTrackingEventObserverCallbackIds {
            let data: [String: Any] = ["type": type, "event": body]
            self.successCallback(callbackId: callbackId, data: data)
        }
    }

    private func successCallback(callbackId: String, data: [String: Any]) {
        if let commandResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: data) {
            commandResult.keepCallback = true
            self.commandDelegate.send(commandResult, callbackId: callbackId)
        }
    }

    private func failureCallback(callbackId: String, data: [String: Any]) {
        if let commandResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR, messageAs: data) {
            commandResult.keepCallback = true
            self.commandDelegate.send(commandResult, callbackId: callbackId)
        }
    }
}
