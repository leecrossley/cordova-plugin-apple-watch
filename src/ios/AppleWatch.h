//
//  AppleWatch.h
//  Copyright (c) 2015 Lee Crossley - http://ilee.co.uk
//

#import "Foundation/Foundation.h"
#import "Cordova/CDV.h"

@interface AppleWatch : CDVPlugin

- (void) init:(CDVInvokedUrlCommand*)command;
- (void) sendMessage:(CDVInvokedUrlCommand*)command;
- (void) addListener:(CDVInvokedUrlCommand*)command;
- (void) removeListener:(CDVInvokedUrlCommand*)command;

@end
