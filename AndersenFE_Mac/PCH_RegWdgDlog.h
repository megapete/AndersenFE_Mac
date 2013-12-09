//
//  PCH_RegWdgDlog.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PCH_RegWdgDlog : NSWindowController

@property (weak) IBOutlet NSButton *doubleAxialStack;
@property (weak) IBOutlet NSButton *multistartTappingWdg;

@property (weak) IBOutlet NSTextField *distanceBewteenStacks;
@property (weak) IBOutlet NSTextField *numberOfLoops;



- (IBAction)okayButtonPushed:(id)sender;
- (IBAction)cancelButtonPushed:(id)sender;

@end
