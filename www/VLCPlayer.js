"use strict";

var exec = require("cordova/exec");

function VLCPlayer() {}

// opts object is optional in all methods

VLCPlayer.prototype.init = function (opts, success, error) {
  exec(success || null, error || null, "VLCPlayer", "init", [opts || {}]);
};

VLCPlayer.prototype.play = function (url, opts, success, error) {
  exec(success || null, error || null, "VLCPlayer", "play", [url, opts || {}]);
};

VLCPlayer.prototype.pause = function (opts, success, error) {
  exec(success || null, error || null, "VLCPlayer", "pause", [opts || {}]);
};

VLCPlayer.prototype.resume = function (opts, success, error) {
  exec(success || null, error || null, "VLCPlayer", "resume", [opts || {}]);
};

VLCPlayer.prototype.seek = function (mseconds, opts, success, error) {
  exec(success || null, error || null, "VLCPlayer", "seek", [mseconds, opts || {}]);
};

// Returns { time: <ms>, length: <ms> } to success callback
VLCPlayer.prototype.position = function (success, error) {
  exec(success || null, error || null, "VLCPlayer", "position", [{}]);
};

VLCPlayer.prototype.stop = function (success, error) {
  exec(success || null, error || null, "VLCPlayer", "stop", [{}]);
};

// Export a singleton; plugin.xml will clobber it to cordova.plugins.vlcplayer
module.exports = new VLCPlayer();
