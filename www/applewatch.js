
var exec = require("cordova/exec");

module.exports = {
    init:function (onSuccess, onError, appGroupId) {
        exec(onSuccess, onError, "AppleWatch", "init", [{"appGroupId": appGroupId}])
    },
    registerNotifications:function (onSuccess, onError) {
        exec(onSuccess, onError, "AppleWatch", "registerNotifications", []);
    },
    sendMessage:function (message, queueName, onSuccess, onError) {
        if (typeof(message) === "object") {
            message = JSON.stringify(message);
        }
        exec(onSuccess, onError, "AppleWatch", "sendMessage", [{"queueName": queueName, "message": message }]);
    },
    sendNotification:function (onSuccess, onError, payload) {
        exec(onSuccess, onError, "AppleWatch", "sendNotification", [payload]);
    },
    sendUserDefaults:function (onSuccess, onError, obj, appGroupId) {
        var key = Object.keys(obj)[0];
        var payload = {
            "key": key,
            "value": obj[key],
            "appGroupId": appGroupId
        };
        exec(onSuccess, onError, "AppleWatch", "sendUserDefaults", [payload]);
    },
    getUserDefaults:function (onSuccess, onError, key, appGroupId) {
        var payload = {
            "key": key,
            "appGroupId": appGroupId
        };
        exec(onSuccess, onError, "AppleWatch", "getUserDefaults", [payload]);
    },
    addListener:function (queueName, onMessage) {
        var wrappedOnMessage = function (message) {
            try {
                message = JSON.parse(message);
            }
            catch (e) {
                // TODO:
            }
            onMessage(message);
        };
        exec(wrappedOnMessage, null, "AppleWatch", "addListener", [{"queueName": queueName }]);
    },
    removeListener:function (queueName, onSuccess, onError) {
        exec(onSuccess, onError, "AppleWatch", "removeListener", [{"queueName": queueName}]);
    },
    purgeQueue:function (queueName, onSuccess, onError) {
        exec(onSuccess, onError, "AppleWatch", "purgeQueue", [{"queueName": queueName}]);
    },
    purgeAllQueues:function (onSuccess, onError) {
        exec(onSuccess, onError, "AppleWatch", "purgeAllQueues", []);
    }
};
