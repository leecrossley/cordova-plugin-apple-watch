
var exec = require("cordova/exec");

var AppleWatch = function () {
    this.name = "AppleWatch";
};

AppleWatch.prototype.init = function (onSuccess, onError, appGroupId) {
    exec(onSuccess, onError, "AppleWatch", "init", [{
        "appGroupId": appGroupId
    }]);
};

AppleWatch.prototype.registerNotifications = function (onSuccess, onError) {
    exec(onSuccess, onError, "AppleWatch", "registerNotifications", []);
};

AppleWatch.prototype.sendMessage = function (message, queueName, onSuccess, onError) {
    if (typeof(message) === "object") {
        message = JSON.stringify(message);
    }

    exec(onSuccess, onError, "AppleWatch", "sendMessage", [{
        "queueName": queueName,
        "message": message
    }]);
};

AppleWatch.prototype.sendNotification = function (onSuccess, onError, payload) {
    exec(onSuccess, onError, "AppleWatch", "sendNotification", [payload]);
};

AppleWatch.prototype.sendUserDefaults = function (onSuccess, onError, obj, appGroupId) {
    var key = Object.keys(obj)[0];
    var payload = {
        "key": key,
        "value": obj[key],
        "appGroupId": appGroupId
    };
    exec(onSuccess, onError, "AppleWatch", "sendUserDefaults", [payload]);
};

AppleWatch.prototype.getUserDefaults = function (onSuccess, onError, key, appGroupId) {
    var payload = {
        "key": key,
        "appGroupId": appGroupId
    };
    exec(onSuccess, onError, "AppleWatch", "getUserDefaults", [payload]);
};

AppleWatch.prototype.addListener = function (queueName, onMessage) {
    var wrappedOnMessage = function (message) {
        try { message = JSON.parse(message); } catch (e) {}
        onMessage(message);
    };

    exec(wrappedOnMessage, null, "AppleWatch", "addListener", [{
        "queueName": queueName
    }]);
};

AppleWatch.prototype.removeListener = function (queueName, onSuccess, onError) {
    exec(onSuccess, onError, "AppleWatch", "removeListener", [{
        "queueName": queueName
    }]);
};

AppleWatch.prototype.purgeQueue = function (queueName, onSuccess, onError) {
    exec(onSuccess, onError, "AppleWatch", "purgeQueue", [{
        "queueName": queueName
    }]);
};

AppleWatch.prototype.purgeAllQueues = function (onSuccess, onError) {
    exec(onSuccess, onError, "AppleWatch", "purgeAllQueues", []);
};

module.exports = new AppleWatch();
