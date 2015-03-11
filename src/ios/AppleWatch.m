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

    self.wormhole = [[MMWormhole alloc] initWithApplicationGroupIdentifier:appGroupId optionalDirectory:nil];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:appGroupId];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) sendMessage:(CDVInvokedUrlCommand*)command;
{
    NSMutableDictionary *args = [command.arguments objectAtIndex:0];

    NSString *queueName = [args objectForKey:@"queueName"];
    NSString *message = [args objectForKey:@"message"];

    [self.wormhole passMessageObject:message identifier:queueName];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void) addListener:(CDVInvokedUrlCommand*)command;
{
    NSMutableDictionary *args = [command.arguments objectAtIndex:0];
    NSString *queueName = [args objectForKey:@"queueName"];

    [self.wormhole listenForMessageWithIdentifier:queueName listener:^(id message) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
        [pluginResult setKeepCallbackAsBool:YES];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) removeListener:(CDVInvokedUrlCommand*)command;
{
    NSMutableDictionary *args = [command.arguments objectAtIndex:0];
    NSString *queueName = [args objectForKey:@"queueName"];

    [self.wormhole stopListeningForMessageWithIdentifier:queueName];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

@end
