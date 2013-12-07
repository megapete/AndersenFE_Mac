//
//  PCH_AndersenFE_TerminalView.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/2/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;

@interface PCH_AndersenFE_TerminalView : NSView

@property AppController *theAppController;

@property NSArray *dataViews;
@property int refTerminal;
@property NSArray *borderColors;

@end
