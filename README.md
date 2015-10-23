## Apple Watch Plugin for Apache Cordova [![npm version](https://badge.fury.io/js/cordova-plugin-apple-watch.svg)](http://badge.fury.io/js/cordova-plugin-apple-watch)

**Cordova / PhoneGap Plugin for the Apple Watch (WatchKit) to allow communication between a Cordova app and an Apple WatchKit Extension (and vice versa).**

Simplified overarching diagram for message passing:

<img align="center" src="https://raw.githubusercontent.com/leecrossley/cordova-plugin-apple-watch/master/apple-watch-plugin.png">

You will need to write your own WatchKit Extension and WatchKit app with native code. It is not possible to run a Cordova app directly on the Watch, as there is no support for a WebView and the WatchKit code must reside in the WatchKit Extension. This plugin provides various methods of communication between a Cordova iPhone app and the WatchKit Extension / app.

For more information on developing your WatchKit Extension / app, please see the [WatchKit Programming Guide](https://developer.apple.com/library/prerelease/ios/documentation/General/Conceptual/WatchKitProgrammingGuide/).

### Supported methods of communication:

- **[Message passing](#message-passing)** - in memory and lightweight json object message passing over named queues between a Cordova app and a WatchKit Extension (2-way)
- **[Local notifications](#notifications)** - sending notifications directly from a Cordova app to an Apple Watch
- **[User defaults](#user-defaults)** - persisting user data accessible by both a Cordova app and a WatchKit Extension

*Please note that you cannot force a Cordova app to open from the Apple Watch - this is a limitation set by Apple.*

## Install

#### Latest published version on npm (with Cordova CLI >= 5.0.0)

```
cordova plugin add cordova-plugin-apple-watch
```

#### Latest version from GitHub

```
cordova plugin add https://github.com/leecrossley/cordova-plugin-apple-watch.git
```

You **do not** need to reference any JavaScript, the Cordova plugin architecture will add a `applewatch` object to your root automatically when you build.

## Message passing

Some success and error handlers may be omitted. This is catered for in the interface function argument orders.

### init

Initialises the Apple Watch two way messaging interface. This must be called and the success handler fired before `sendMessage` can be used.

```js
applewatch.init(function successHandler(appGroupId) {}, errorHandler);
```

The `successHandler` is called with one arg `appGroupId` that was used in initialisation. The app bundleId will be used for identification by default, prefixed by "group.".

You can supply your own Application Group Id with the optional `appGroupId` argument, this should be in the format "group.com.company.app":

```js
applewatch.init(successHandler, errorHandler, appGroupId);
```

### sendMessage

Sends a message object to a specific queue (must be called after successful init).

Used to send strings or json objects to the Apple Watch extension. Json objects are automatically stringified.

```js
applewatch.sendMessage(message, queueName, successHandler, errorHandler);
```

### addListener

Adds a listener to handle a message object received on a specific queue (must be called after successful init).

Used to handle strings or json objects received from the Apple Watch extension. Json objects are automatically parsed.

```js
applewatch.addListener(queueName, messageHandler);
```

### removeListener

Removes a listener for a specific queue.

```js
applewatch.removeListener(queueName, successHandler, errorHandler);
```

### purgeQueue

**Use with caution**: removes all messages on a queue.

```js
applewatch.purgeQueue(queueName, successHandler, errorHandler);
```

### purgeAllQueues

**Use with extreme caution**: removes all messages on all queues.

```js
applewatch.purgeAllQueues(successHandler, errorHandler);
```

### Message passing examples

Example to send a message "test" to the "myqueue" queue and get handled, where "com.yourcompany" is the App ID and "group.com.yourcompany" is the [App Group](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html#//apple_ref/doc/uid/TP40012582-CH26-SW61).

#### Initialise message passing (Cordova app, js)

```js
applewatch.init(function (appGroupId) {
    // success, messages may now be sent or listened for
}, function (err) {
    // an error occurred
},
"group.com.yourcompany");
```

#### Send a message (Cordova app, js)

```js
// assumes a previously successful init call (above)

applewatch.sendMessage("test", "myqueue");
```

#### Listen for messages (Cordova app, js)

```js
// assumes a previously successful init call (above)

applewatch.addListener("test", function (message) {
    // handle your message here
});
```

#### Initialise message passing (WatchKit extension, swift)

```swift
// assumes your WatchKit extension references Wormhole.h

let wormhole = MMWormhole(applicationGroupIdentifier: "group.com.yourcompany", optionalDirectory: nil)
```

#### Send a message (WatchKit extension, swift)

```swift
// assumes wormhole is initialised (above)

wormhole.passMessageObject("titleString", identifier: "messageIdentifier")
```

#### Listen for messages (WatchKit extension, swift)

```swift
// assumes wormhole is initialised (above)

wormhole.listenForMessageWithIdentifier("myqueue", listener: { (messageObject) -> Void in
    if let message: AnyObject = messageObject {
        // handle your message here
    }
})
```

More information regarding the MMWormhole component used in message passing can be found [here](https://github.com/mutualmobile/MMWormhole).

## Notifications

### registerNotifications

Requests permission for local notifications if you want to utilise the short-look / long-look notification interface. This must be called and the success handler fired before `sendNotification` will work correctly.

```js
applewatch.registerNotifications(successHandler, errorHandler);
```

- successHandler is called with **true** if the permission was accepted
- errorHandler is called with **false** if the permission was rejected

### sendNotification

Sends a local notification directly to the Apple Watch (should be called after successful registerNotifications).

Used to display the Apple Watch short-look / long-look notification interface, using UILocalNotification. If the user continues to look at the notification, the system transitions quickly from the short-look interface to the long-look interface.

```js
var payload = {
    "title": "Short!",
    "category": "default",
    "body": "Shown in the long-look interface to provide more detail",
    "badge": 1
};

applewatch.sendNotification(successHandler, errorHandler, payload);
```

- *title* - shown in the short-look interface as a brief indication of the intent of the notification
- *category* - defines the notification interface to show and action buttons (if any)
- *body* - shown in the long-look interface to provide more detail
- *badge* - app icon badge number

NB: This notification will also appear on the iPhone if the app is running in a background mode.

## User defaults

### sendUserDefaults

Allows persistence of user default data (single property key/value object) that can be retrieved by the WatchKit extension.

```js
applewatch.sendUserDefaults(successHandler,
    errorHandler, { "myKey": "myValue" }, appGroupId);
```

The app bundleId will be used for identification by default, prefixed by "group." if `appGroupId` is not supplied.

For completeness, here's how you could retrieve the value in your WatchKit extension (swift):

```swift
let userDefaults = NSUserDefaults(suiteName: "group.com.yourcompany")

var myValue: String? {
    userDefaults?.synchronize()
    return userDefaults?.stringForKey("myKey")
}
```

### getUserDefaults

Allows retrieval of user default data.

```js
applewatch.getUserDefaults(successHandler, errorHandler, "myKey", appGroupId);
```

The app bundleId will be used for identification by default, prefixed by "group." if `appGroupId` is not supplied.

## Live demo

See this plugin working in a live app: [sprint.social](http://sprint.social)

## Platforms

iOS 8.2+ only. However, you can include this plugin and set a lower minimum iOS version. For example setting a deployment target of 8.0 will not cause any errors with the plugin. Similarly, there will be no errors if a user is using the Cordova app without a paired watch.

watchOS 1 & 2.

## License

[MIT License](http://ilee.mit-license.org)
