//
//  PCH_MoveWdgDlog.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "PCH_MoveWdgDlog.h"

@interface PCH_MoveWdgDlog ()

@end

@implementation PCH_MoveWdgDlog

- (id)init
{
    self = [super initWithWindowNibName:@"PCH_MoveWdgDlog"];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)okayButtonPushed:(id)sender
{
    [NSApp stopModal];
}

- (IBAction)cancelButtonPushed:(id)sender
{
    [NSApp abortModal];
}


@end
