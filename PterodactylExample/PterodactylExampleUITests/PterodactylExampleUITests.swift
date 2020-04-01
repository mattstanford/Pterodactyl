//
//  PterodactylExampleUITests.swift
//  PterodactylExampleUITests
//
//  Created by Matt Stanford on 3/17/20.
//  Copyright © 2020 Matt Stanford. All rights reserved.
//

import XCTest
import PterodactylLib

class PterodactylExampleUITests: XCTestCase {

    let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        app.launch()
    }
    
    func testSimulatorPush() {
        
        let pterodactyl = Pterodactyl(targetAppBundleId: "com.mattstanford.PterodactylExample")
        waitForElementToAppear(object: app.staticTexts["Pterodactyl Example"])
        
        //Tap the home button
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        sleep(1)

        //Trigger a push notification
        pterodactyl.triggerSimulatorNotification(withMessage: "here's a simple message")
        
        //Tap the notification when it appears
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let springBoardNotification = springboard.otherElements["NotificationShortLookView"]
        waitForElementToAppear(object: springBoardNotification)
        springBoardNotification.tap()

        waitForElementToAppear(object: app.staticTexts["Pterodactyl Example"])
    }
    
    func waitForElementToAppear(object: Any) {
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: object, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
}
