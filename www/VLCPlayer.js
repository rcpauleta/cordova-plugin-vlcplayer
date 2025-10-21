var exec = require('cordova/exec');

exports.init = function (opts, ok, err) {
  exec(ok, err, 'VLCPlayer', 'init', [opts || {}]);
};

exports.play = function (url, opts, ok, err) {
  exec(ok, err, 'VLCPlayer', 'play', [url, opts || {}]);
};

exports.pause = function (ok, err) {
  exec(ok, err, 'VLCPlayer', 'pause', []);
};

exports.resume = function (ok, err) {
  exec(ok, err, 'VLCPlayer', 'resume', []);
};

exports.seek = function (ms, ok, err) {
  exec(ok, err, 'VLCPlayer', 'seek', [ms]); // seek to absolute ms
};

exports.position = function (ok, err) {
  exec(ok, err, 'VLCPlayer', 'position', []);
};

exports.stop = function (ok, err) {
  exec(ok, err, 'VLCPlayer', 'stop', []);
};
