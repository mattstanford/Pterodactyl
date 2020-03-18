//
//  PterodactylExampleUITests.swift
//  PterodactylExampleUITests
//
//  Created by Matt Stanford on 3/17/20.
//  Copyright © 2020 Matt Stanford. All rights reserved.
//

import XCTest

class PterodactylExampleUITests: XCTestCase {

    var app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        app.launch()
    }
    
    func testSimulatorPush() {
        
        waitForElementToAppear(object: app.staticTexts["Pterodactyl Example"])
        
        //Tap the home button
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        sleep(1)

        //Trigger a push notification
        triggerSimulatorNotification(withPayload: .pushType1)
        
        //Tap the notification when it appears
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let springBoardNotification = springboard.otherElements["NotificationShortLookView"]
        waitForElementToAppear(object: springBoardNotification)
        springBoardNotification.tap()

        waitForElementToAppear(object: app.staticTexts["Pterodactyl Example"])
    }
    
    private func triggerSimulatorNotification(withPayload payload: PushNotificationPayload) {
        let endpoint = "http://localhost:8081/simulatorPush"
        
        guard let endpointUrl = URL(string: endpoint) else {
            return
        }
        
        //Make JSON to send to send to server
        var json = [String:Any]()
        json["simulatorId"] = "booted"
        json["appBundleId"] = "com.mattstanford.PterodactylExample"
        json["pushPayload"] = payload.payloadAsDict
        
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return
        }
        
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    
    func waitForElementToAppear(object: Any) {
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: object, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    enum PushNotificationPayload: String {
        case pushType1 = "This is one type of push notification"
        case pushType2 = "This is another type of push notification"
        
        var apnsPayload: String {
            return "{\"aps\":{\"alert\":\"" + self.rawValue + "\", \"badge\":1}}"
        }
        
        var payloadAsDict: [String: Any] {
            return ["aps": ["alert": self.rawValue, "badge": 1, "sound": "default"]]
        }
    }
}
