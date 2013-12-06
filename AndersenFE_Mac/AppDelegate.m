//
//  AppDelegate.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 11/30/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "AppDelegate.h"
#include "AppController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    return [self.theAppController openInputFile:filename];
}

@end
