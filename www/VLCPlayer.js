"use strict";
function VLCPlayer() {
}

VLCPlayer.prototype.init = function(options) {
  options = options || {};
  cordova.exec(options.successCallback || null, options.errorCallback || null,
               "VLCPlayer", "init", [options]);
};

VLCPlayer.prototype.play = function (url, options) {
  options = options || {};
  cordova.exec(options.successCallback || null, options.errorCallback || null,
               "VLCPlayer", "play", [url, options]);
};

VLCPlayer.prototype.pause = function(options) {
  options = options || {};
  cordova.exec(options.successCallback || null, options.errorCallback || null,
               "VLCPlayer", "pause", [options]);
};

VLCPlayer.prototype.resume = function(options) {
  options = options || {};
  cordova.exec(options.successCallback || null, options.errorCallback || null,
               "VLCPlayer", "resume", [options]);
};

VLCPlayer.prototype.seek = function(mseconds, options) {
  options = options || {};
  cordova.exec(options.successCallback || null, options.errorCallback || null,
               "VLCPlayer", "seek", [mseconds, options]);
};

VLCPlayer.prototype.position = function() {
  options = {};
  cordova.exec(options.successCallback || null, options.errorCallback || null,
               "VLCPlayer", "position", [options]);
};

VLCPlayer.prototype.stop = function() {
  options = {};
  cordova.exec(options.successCallback || null, options.errorCallback || null,
               "VLCPlayer", "stop", [options]);
};

VLCPlayer.install = function () {
	if (!window.plugins) {
		window.plugins = {};
	}
	window.plugins.vlcPlayer = new VLCPlayer();
	return window.plugins.vlcPlayer;
};
