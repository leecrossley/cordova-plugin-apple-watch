
var exec = require("cordova/exec");

var AppleWatch = function () {
    this.name = "AppleWatch";
};

AppleWatch.prototype.init = function (onSuccess, onError, groupId) {
    exec(onSuccess, onError, "AppleWatch", "sendMessage", [{
        "groupId": groupId
    }]);
};

AppleWatch.prototype.sendMessage = function (onSuccess, onError, queueName, message) {
    queueName = message || "default";
    message = message || "";

    if (typeof(message) !== "object") {
        message = JSON.stringify(message);
    }

    exec(onSuccess, onError, "AppleWatch", "sendMessage", [{
        "queueName": queueName,
        "message": message
    }]);
};

AppleWatch.prototype.handleMessage = function (onMessageReceived, queueName) {
    exec(onMessageReceived, null, "AppleWatch", "handleMessage", [{
        "queueName": queueName
    }]);
};

module.exports = new AppleWatch();
