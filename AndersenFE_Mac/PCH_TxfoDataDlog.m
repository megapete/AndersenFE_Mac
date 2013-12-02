//
//  PCH_TxfoDataDlog.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "PCH_TxfoDataDlog.h"

@interface PCH_TxfoDataDlog ()

@end

@implementation PCH_TxfoDataDlog

- (id)init
{
    if (self = [super initWithWindowNibName:@"PCH_TxfoDataDlog"])
    {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)okayButtonPressed:(id)sender
{
    [NSApp stopModal];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [NSApp abortModal];
}

@end
