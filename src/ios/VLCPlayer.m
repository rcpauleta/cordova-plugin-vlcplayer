#import <Cordova/CDV.h>

@interface VLCPlayer : CDVPlugin
@end

@implementation VLCPlayer

- (void)init:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

- (void)play:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

@end
