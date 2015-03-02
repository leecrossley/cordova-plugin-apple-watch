
var exec = require("cordova/exec");

var AppleWatch = function () {
    this.name = "AppleWatch";
};

AppleWatch.prototype.sendMessage = function (onSuccess, onError) {
    exec(onSuccess, onError, "AppleWatch", "sendMessage", []);
};

module.exports = new AppleWatch();
