var exec = require('cordova/exec');
var PLUGIN = 'VLCPlayer';

exports.init = function (cb) {
  exec(cb, cb, PLUGIN, 'init', []);
};

exports.play = function (url, options, cb) {
  exec(cb, cb, PLUGIN, 'play', [url, options || {}]);
};

exports.pause = function (cb) {
  exec(cb, cb, PLUGIN, 'pause', []);
};

exports.stop = function (cb) {
  exec(cb, cb, PLUGIN, 'stop', []);
};

exports.seek = function (ms, cb) {
  exec(cb, cb, PLUGIN, 'seek', [ms]);
};

exports.setVolume = function (vol, cb) {
  exec(cb, cb, PLUGIN, 'setVolume', [vol]); // 0..100
};

exports.snapshot = function (cb) {
  exec(cb, cb, PLUGIN, 'snapshot', []);
};

exports.dispose = function (cb) {
  exec(cb, cb, PLUGIN, 'dispose', []);
};

// event stream
exports.setEventHandler = function (cb) {
  exec(cb, cb, PLUGIN, 'setEventHandler', []);
};
