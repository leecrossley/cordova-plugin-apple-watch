//
//  AppleWatch.m
//  Copyright (c) 2015 Lee Crossley - http://ilee.co.uk
//

#import "Cordova/CDV.h"
#import "Cordova/CDVViewController.h"
#import "AppleWatch.h"

static NSString * const AppleWatchNotification = @"AppleWatchNotification";

@interface AppleWatch ()
    @property (nonatomic, strong) NSString *appGroupId;
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
            self.appGroupId = appGroupId;

            [[NSNotificationCenter defaultCenter] addObserver:self
                selector:@selector(receiveMessage:) name:AppleWatchNotification object:nil];

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
    CDVPluginResult* pluginResult = nil;

    NSMutableDictionary *args = [command.arguments objectAtIndex:0];
    NSString *queueName = [args objectForKey:@"queueName"];
    NSData *message = [NSKeyedArchiver archivedDataWithRootObject:[args objectForKey:@"message"]];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) receiveMessage:(NSNotification*)notification;
{

}

- (NSString*) queuePath:(NSString*)queueName
{
    if (identifier == nil || identifier.length == 0) {
        return nil;
    }

    NSString *directoryPath = [self messagePassingDirectoryPath];
    NSString *fileName = [NSString stringWithFormat:@"%@.archive", identifier];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];

    return filePath;
}

@end
