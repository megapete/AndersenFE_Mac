//
//  AppDelegate.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 11/30/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet AppController *theAppController;

@end
