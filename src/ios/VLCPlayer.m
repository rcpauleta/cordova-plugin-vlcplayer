#import "VLCPlayer.h"

@interface VLCPlayer ()
@property (nonatomic, strong) VLCMediaPlayer *player;
@property (nonatomic, strong) UIViewController *containerVC;
@property (nonatomic, strong) UIView *videoView;
@end

@implementation VLCPlayer

- (void)init:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.containerVC = [UIViewController new];
        self.containerVC.view.backgroundColor = UIColor.blackColor;

        self.videoView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.containerVC.view addSubview:self.videoView];

        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
    });
}

- (void)play:(CDVInvokedUrlCommand*)command {
    NSString *urlStr = ([command.arguments count] > 0 ? command.arguments[0] : nil);
    if (urlStr.length == 0) {
        [self sendError:@"Invalid URL" cb:command.callbackId]; return;
    }
    NSDictionary *opts = ([command.arguments count] > 1 ? command.arguments[1] : @{});
    NSNumber *nc = opts[@"networkCaching"] ?: @(1000);

    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.containerVC) {
            [self init:command]; // prepares container
        }
        if (self.containerVC.presentingViewController == nil && self.viewController) {
            [self.viewController presentViewController:self.containerVC animated:YES completion:nil];
        }

        // Build VLC player
        NSArray<NSString*> *args = @[[NSString stringWithFormat:@"--network-caching=%@", nc]];
        self.player = [[VLCMediaPlayer alloc] initWithOptions:args];
        self.player.delegate = self;
        self.player.drawable = self.videoView;

        NSURL *url = [NSURL URLWithString:urlStr];
        self.player.media = [VLCMedia mediaWithURL:url];

        [self.player play];

        CDVPluginResult *ok = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:ok callbackId:command.callbackId];
    });
}

- (void)pause:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player pause];
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                    callbackId:command.callbackId];
    });
}

- (void)resume:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player play];
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                    callbackId:command.callbackId];
    });
}

- (void)seek:(CDVInvokedUrlCommand*)command {
    NSNumber *ms = ([command.arguments count] ? command.arguments[0] : @(0));
    dispatch_async(dispatch_get_main_queue(), ^{
        VLCTime *length = self.player.media.length;
        if (length.intValue > 0) {
            float pos = ms.doubleValue / length.doubleValue; // 0..1
            self.player.position = pos;
        }
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                    callbackId:command.callbackId];
    });
}

- (void)position:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        int timeMs = self.player.time.intValue ?: 0;
        int lenMs  = self.player.media.length.intValue ?: 0;
        NSDictionary *payload = @{ @"time": @(timeMs), @"length": @(lenMs) };
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
    });
}

- (void)stop:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player stop];
        self.player = nil;
        [self.containerVC dismissViewControllerAnimated:YES completion:nil];
        self.containerVC = nil;
        self.videoView = nil;
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK]
                                    callbackId:command.callbackId];
    });
}

- (void)sendError:(NSString*)msg cb:(NSString*)cb {
    CDVPluginResult *err = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:msg];
    [self.commandDelegate sendPluginResult:err callbackId:cb];
}

@end
