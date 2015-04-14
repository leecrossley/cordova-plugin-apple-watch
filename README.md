## Apple Watch Plugin for Apache Cordova

**Cordova / PhoneGap Plugin for the Apple Watch (WatchKit) to allow in memory and lightweight json object message passing over named queues from a Cordova app to Apple Watch (and vice versa).**

Simplified overarching diagram:

<img align="center" src="https://raw.githubusercontent.com/leecrossley/cordova-plugin-apple-watch/master/apple-watch-plugin.png">

You will need to write your own WatchKit Extension and WatchKit App with native code. It will not be possible to run a Cordova app directly on the Watch, as there is no support for a WebView and your WatchKit code must reside in the WatchKit Extension. This plugin provides a message passing interface between your Cordova iPhone app and the WatchKit Extension / App.

## Install

```
cordova plugin add https://github.com/leecrossley/cordova-plugin-apple-watch.git
```

You **do not** need to reference any JavaScript, the Cordova plugin architecture will add a `applewatch` object to your root automatically when you build.

## Message passing

Generally speaking, some success and error handlers may be omitted. This is catered for in the interface function argument orders.

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

## Notifications

### registerNotifications

Requests permission for local notifications if you want to utilise the short-look / long-look notification interface. This must be called and the success handler fired before `sendNotification` will work correctly.

```js
applewatch.registerNotifications(successHandler, errorHandler);
```

- successHandler is called with **true** if the permission was accepted
- errorHandler is called with **false** if the permission was rejected

### sendNotification

Sends a local notification directly to the apple watch (should be called after successful registerNotifications).

Used to display the apple watch short-look / long-look notification interface, using UILocalNotification. If the user continues to look at the notification, the system transitions quickly from the short-look interface to the long-look interface.

```js
var payload = {
    "title": "Short!",
    "body": "Shown in the long-look interface to provide more detail",
    "badge": 1
};

applewatch.sendNotification(successHandler, errorHandler, payload);
```

- *title* - shown in the short-look interface as a brief indication of the intent of the notification
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

## Basic message passing example

Basic example to send a message "test" to the "myqueue" queue and get handled.

This example is iPhone -> iPhone.

```
applewatch.init(function (appGroupId) {
    alert(appGroupId);

    applewatch.addListener("myqueue", function(message) {
        alert("Message received: " + message);
    });

    applewatch.sendMessage("test", "myqueue");
});
```

## Platforms

iOS 8.2+ only.

## License

[MIT License](http://ilee.mit-license.org)
