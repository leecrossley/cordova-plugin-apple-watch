//
//  AppleWatch.m
//  Copyright (c) 2015 Lee Crossley - http://ilee.co.uk
//

#import "Cordova/CDV.h"
#import "Cordova/CDVViewController.h"
#import "AppleWatch.h"
#import "MMWormhole.h"

@interface AppleWatch ()
    @property (nonatomic, strong) MMWormhole* wormhole;
@end

@implementation AppleWatch

- (void) init:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = nil;

    NSMutableDictionary *args = [command.arguments objectAtIndex:0];
    NSString *appGroupId = [args objectForKey:@"appGroupId"];

    if ([appGroupId length] == 0)
    {
        appGroupId = [NSString stringWithFormat:@"group.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
    }

    if ([appGroupId length] != 0)
    {
        if ([[NSFileManager defaultManager] respondsToSelector:@selector(containerURLForSecurityApplicationGroupIdentifier:)])
        {
            wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:appGroupId];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                messageAsString:@"Feature not available on this device, only iOS 7+ is supported"];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
            messageAsString:@"Please specify `appGroupId`, unable to determine bundle identifier"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) sendMessage:(CDVInvokedUrlCommand*)command;
{
    NSMutableDictionary *args = [command.arguments objectAtIndex:0];
    
    NSString *queueName = [args objectForKey:@"queueName"];
    NSString *message = [args objectForKey:@"message"];

    [wormhole passMessageObject:message identifier:queueName];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void) receiveMessage:(NSNotification*)notification;
{

}

@end
