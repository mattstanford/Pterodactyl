# Pterodactyl
Library for ease of sending Push Notifications for XCUITests

As of Xcode 11.4, push notifications in the simulator are now available. Unfortunately, the way you do it does not lend itself well to automated tests, especially XCUITests. But have no fear, the Pterodactyl library aims to solve that!

Simply add the Pterodacyl library to your UI Test target, and you have an easy-to-use method of sending push notifications in your UI tests!

## How it works

Xcode 11.4 added the ability to send push notifications to your simulator. There are two ways you can do this:

1. Create an APNS payload JSON file, and manually drag it into the running simulator
2. Create an APNS payload JSON file, and run a command from the terminal supplying your JSON file as an argument.

Apple unfortunately did not leave us an API to use this new functionality within XCUITest. Pterodactyl works around this limitation by starting up a local macOS server on your computer and runs the applicable `xcrun` command when it receives an appropriate network request. The library you add to your app streamlines all messy stuff like creating an appropriate JSON file and sending the right network request to the local server.

## Usage

First intialize a `Pterodactyl` instance with an instance of your XCUIApplication:

```
let app = XCUIApplication()
let pterodactyl = Pterodactyl(targetApp: app)
```

You can send a push notification to your app with a custom message like so:

```swift
pterodactyl.triggerSimulatorNotification(withMessage: "here's a simple message")
```

If your APNS notifications are more complex, you can also specify custom keys that will be part of the `apns` payload:

```swift
pterodactyl.triggerSimulatorNotification(withMessage: "here's a more complicated message", additionalKeys: ["badge": 42, "myWeirdCustomKey": "foobar"])
```

The example above will send an APNS payload to the app that is the equivalent to the following:

```
{
    "aps": { 
        "alert": "here's a more complicated message",
        "badge": 42,
        "myWeirdCustomKey": "foobar""
    }
}
```

And if you want FULL control over the payload (i.e. you want to supply a key that's outside the `aps` payload, you can trigger the notification by specifying the payload as Dictionary:

```swift
pterodactyl.triggerSimulatorNotification(withFullPayload: ["aps": ["alert": "here's a message with the full payload supplied", "badge": 1, "sound": "default"], "someOtherKey": "some other key defined outside the aps payload"])
```

This sends a payload that's equivalent to the following:

```
{
    "aps": { 
        "alert": "here's a message with the full payload supplied",
        "badge": 42,
        "myWeirdCustomKey": "foobar""
    },
    "someOtherKey": "some other key defined outside the aps payload"
}
```


## Example

Here's a sample UI test that utilizes the Pterodactyl app for testing a very simple push notification use case:

```swift
import XCTest
import PterodactylLib

class MyUITestExample: XCTestCase {

    func testSimulatorPush() {
        var app = XCUIApplication()
        
        let pterodactyl = Pterodactyl(targetApp: app)
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
```
