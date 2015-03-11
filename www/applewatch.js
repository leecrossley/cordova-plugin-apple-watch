
var exec = require("cordova/exec");

var AppleWatch = function () {
    this.name = "AppleWatch";
};

AppleWatch.prototype.init = function (onSuccess, onError, appGroupId) {
    exec(onSuccess, onError, "AppleWatch", "init", [{
        "appGroupId": appGroupId
    }]);
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
