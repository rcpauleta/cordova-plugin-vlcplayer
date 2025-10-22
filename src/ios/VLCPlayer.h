#import <Cordova/CDV.h>
#import <MobileVLCKit/MobileVLCKit.h>

@interface VLCPlayer : CDVPlugin <VLCMediaPlayerDelegate>

- (void)init:(CDVInvokedUrlCommand*)command;
- (void)play:(CDVInvokedUrlCommand*)command;
- (void)pause:(CDVInvokedUrlCommand*)command;
- (void)resume:(CDVInvokedUrlCommand*)command;
- (void)seek:(CDVInvokedUrlCommand*)command;
- (void)position:(CDVInvokedUrlCommand*)command;
- (void)stop:(CDVInvokedUrlCommand*)command;

@end
