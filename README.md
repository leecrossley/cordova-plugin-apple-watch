## Apple Watch Plugin for Apache Cordova

**Not ready for production use, work in progress**

If you're interested in this plugin, please [contact me](http://ilee.co.uk/contact-me/).

## Install

```
cordova plugin add https://github.com/leecrossley/cordova-plugin-apple-watch.git
```

You **do not** need to reference any JavaScript, the Cordova plugin architecture will add a `applewatch` object to your root automatically when you build.

## Usage

### init

Initialises the Apple Watch interface, this must be called and the success handler fired before messages can be sent.

```js
applewatch.init(successHandler, errorHandler);
```

The apps bundleId will be used for identification by default, or you can supply your own Application Group Id with the optional `groupId` argument:


```js
applewatch.init(successHandler, errorHandler, groupId);
```

### sendMessage

Sends a message object to a specific queue (must be called after successful init).

Used to send strings or json objects to the Apple Watch extension.

```js
applewatch.sendMessage(successHandler, errorHandler, queueName, message);
```

### handleMessage

Handles a message object received on a specific queue (must be called after successful init).

Used to handle strings or json objects received from the Apple Watch extension.

```js
applewatch.sendMessage(onMessageReceived, queueName);
```

## Platforms

iOS 7+ only.

## License

[MIT License](http://ilee.mit-license.org)
