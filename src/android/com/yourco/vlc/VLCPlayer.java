package com.yourco.vlc;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

import android.view.WindowManager;
import android.net.Uri;

import org.videolan.libvlc.*;
import org.videolan.libvlc.util.VLCVideoLayout;

public class VLCPlayer extends CordovaPlugin {
  private LibVLC libVLC;
  private MediaPlayer mediaPlayer;
  private VLCVideoLayout videoLayout; // optional if you render inline; for fullscreen audio-only, you can omit

  private CallbackContext eventCallback;

  @Override
  public boolean execute(String action, JSONArray args, final CallbackContext cb) throws JSONException {
    switch (action) {
      case "init":
        init(cb); return true;
      case "play":
        play(args.getString(0), args.optJSONObject(1), cb); return true;
      case "pause":
        if (mediaPlayer != null) mediaPlayer.pause();
        cb.success(); return true;
      case "stop":
        if (mediaPlayer != null) mediaPlayer.stop();
        cb.success(); return true;
      case "seek":
        if (mediaPlayer != null) mediaPlayer.setTime(args.getLong(0));
        cb.success(); return true;
      case "setVolume":
        if (mediaPlayer != null) mediaPlayer.setVolume(args.getInt(0));
        cb.success(); return true;
      case "snapshot":
        if (mediaPlayer != null) {
          // Save to app cache; return path
          String path = cordova.getContext().getCacheDir() + "/vlc_snap.png";
          mediaPlayer.takeSnapshot(0, path, 0, 0);
          cb.success(path);
        } else cb.error("not-initialized");
        return true;
      case "dispose":
        dispose();
        cb.success(); return true;
      case "setEventHandler":
        eventCallback = cb;
        // Keep callback open for streaming events
        PluginResult pr = new PluginResult(PluginResult.Status.NO_RESULT);
        pr.setKeepCallback(true);
        cb.sendPluginResult(pr);
        return true;
    }
    return false;
  }

  private void init(final CallbackContext cb) {
    if (libVLC == null) {
      java.util.ArrayList<String> opts = new java.util.ArrayList<>();
      opts.add("--no-drop-late-frames");
      opts.add("--no-skip-frames");
      // add any network/rtsp options you need
      libVLC = new LibVLC(cordova.getContext(), opts);
      mediaPlayer = new MediaPlayer(libVLC);
      mediaPlayer.setEventListener(this::onPlayerEvent);
    }
    cb.success();
  }

  private void play(String url, JSONObject options, final CallbackContext cb) {
    if (libVLC == null) { cb.error("not-initialized"); return; }

    // Layout (optional for inline). For fullscreen, you can use a TextureView in an Activity.
    if (videoLayout == null) {
      videoLayout = new VLCVideoLayout(cordova.getActivity());
      cordova.getActivity().runOnUiThread(() -> {
        cordova.getActivity().getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
      });
    }

    Media media = new Media(libVLC, Uri.parse(url));

    if (options != null) {
      if (options.optBoolean("hwDecoding", true)) { /* default */ }
      if (options.has("networkCachingMs")) {
        media.addOption(":network-caching=" + options.optInt("networkCachingMs"));
      }
      if (options.optBoolean("aceStream", false)) {
        media.addOption(":file-caching=1000");
      }
      // add more media options as needed (e.g., :rtsp-tcp)
    }

    mediaPlayer.setMedia(media);
    // If you want inline video: mediaPlayer.attachViews(videoLayout, null, false, false);
    mediaPlayer.play();
    cb.success();
  }

  private void onPlayerEvent(MediaPlayer.Event event) {
    if (eventCallback == null) return;
    try {
      JSONObject payload = new JSONObject();
      switch (event.type) {
        case MediaPlayer.Event.Playing: payload.put("event", "playing"); break;
        case MediaPlayer.Event.Paused:  payload.put("event", "paused");  break;
        case MediaPlayer.Event.Stopped: payload.put("event", "ended");   break;
        case MediaPlayer.Event.EndReached: payload.put("event","ended"); break;
        case MediaPlayer.Event.TimeChanged:
          payload.put("event","time"); payload.put("time", mediaPlayer.getTime()); break;
        case MediaPlayer.Event.EncounteredError:
          payload.put("event","error"); break;
        default: return;
      }
      PluginResult pr = new PluginResult(PluginResult.Status.OK, payload);
      pr.setKeepCallback(true);
      eventCallback.sendPluginResult(pr);
    } catch (Exception ignore) {}
  }

  private void dispose() {
    if (mediaPlayer != null) {
      mediaPlayer.stop();
      mediaPlayer.detachViews();
      mediaPlayer.release();
      mediaPlayer = null;
    }
    if (libVLC != null) {
      libVLC.release();
      libVLC = null;
    }
  }

  @Override
  public void onReset() {
    dispose();
  }
}
