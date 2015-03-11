## Apple Watch Plugin for Apache Cordova

**Cordova / PhoneGap Plugin for the Apple Watch (WatchKit) to allow in memory and lightweight json object message passing over defined or default queues from a Cordova app to Apple Watch (and vice versa).**

## Install

```
cordova plugin add https://github.com/leecrossley/cordova-plugin-apple-watch.git
```

You **do not** need to reference any JavaScript, the Cordova plugin architecture will add a `applewatch` object to your root automatically when you build.

## Usage

Generally speaking, some success and error handlers may be omitted. This is catered for in the interface function argument orders.

### init

Initialises the Apple Watch interface, this must be called and the success handler fired before messages can be sent.

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
applewatch.addListener(messageHandler, queueName);
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

## Example

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
