#import <Cordova/CDV.h>
@import MobileVLCKit;

@interface VLCPlayer : CDVPlugin <VLCMediaPlayerDelegate>
@property (nonatomic, strong) VLCMediaPlayer *player;
@property (nonatomic, strong) CDVInvokedUrlCommand *eventCmd;
@end

@implementation VLCPlayer

- (void)init:(CDVInvokedUrlCommand*)cmd {
  if (!self.player) {
    self.player = [[VLCMediaPlayer alloc] init];
    self.player.delegate = self;
  }
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:cmd.callbackId];
}

- (void)play:(CDVInvokedUrlCommand*)cmd {
  if (!self.player) { [self init:cmd]; }
  NSString *url = [cmd.arguments objectAtIndex:0];
  NSDictionary *opts = cmd.arguments.count > 1 ? [cmd.arguments objectAtIndex:1] : @{};
  VLCMedia *media = [VLCMedia mediaWithURL:[NSURL URLWithString:url]];

  NSNumber *cache = opts[@"networkCachingMs"];
  if (cache) {
    media.options = @[[NSString stringWithFormat:@":network-caching=%@", cache]];
  }

  self.player.media = media;
  [self.player play];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:cmd.callbackId];
}

- (void)pause:(CDVInvokedUrlCommand*)cmd {
  [self.player pause];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:cmd.callbackId];
}

- (void)stop:(CDVInvokedUrlCommand*)cmd {
  [self.player stop];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:cmd.callbackId];
}

- (void)seek:(CDVInvokedUrlCommand*)cmd {
  long long ms = [[cmd.arguments objectAtIndex:0] longLongValue];
  self.player.time = [VLCTime timeWithNumber:@(ms)];
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:cmd.callbackId];
}

- (void)setVolume:(CDVInvokedUrlCommand*)cmd {
  int vol = [[cmd.arguments objectAtIndex:0] intValue];
  self.player.audio.volume = vol;
  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:cmd.callbackId];
}

- (void)setEventHandler:(CDVInvokedUrlCommand*)cmd {
  self.eventCmd = cmd;
  CDVPluginResult *pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
  [pr setKeepCallbackAsBool:YES];
  [self.commandDelegate sendPluginResult:pr callbackId:cmd.callbackId];
}

#pragma mark - VLCMediaPlayerDelegate

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
  if (!self.eventCmd) return;
  NSString *evt = @"";
  switch (self.player.state) {
    case VLCMediaPlayerStatePlaying: evt = @"playing"; break;
    case VLCMediaPlayerStatePaused:  evt = @"paused";  break;
    case VLCMediaPlayerStateStopped: evt = @"ended";   break;
    case VLCMediaPlayerStateEnded:   evt = @"ended";   break;
    case VLCMediaPlayerStateError:   evt = @"error";   break;
    default: return;
  }
  NSDictionary *payload = @{@"event": evt};
  CDVPluginResult *pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
  [pr setKeepCallbackAsBool:YES];
  [self.commandDelegate sendPluginResult:pr callbackId:self.eventCmd.callbackId];
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
  if (!self.eventCmd) return;
  NSDictionary *payload = @{@"event": @"time", @"time": self.player.time.number};
  CDVPluginResult *pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
  [pr setKeepCallbackAsBool:YES];
  [self.commandDelegate sendPluginResult:pr callbackId:self.eventCmd.callbackId];
}

@end
