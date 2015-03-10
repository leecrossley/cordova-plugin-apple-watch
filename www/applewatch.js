
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
    queueName = queueName || "default";
    message = message || "";

    if (typeof(message) !== "object") {
        message = JSON.stringify(message);
    }

    exec(onSuccess, onError, "AppleWatch", "sendMessage", [{
        "queueName": queueName,
        "message": message
    }]);
};

AppleWatch.prototype.handleMessage = function (onMessage, queueName) {
    queueName = queueName || "default";

    exec(onMessage, null, "AppleWatch", "handleMessage", [{
        "queueName": queueName
    }]);
};

module.exports = new AppleWatch();
