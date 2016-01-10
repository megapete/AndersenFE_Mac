//
//  PCH_OffsetElongationDlog.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "PCH_OffsetElongationDlog.h"

@interface PCH_OffsetElongationDlog ()

@end

@implementation PCH_OffsetElongationDlog

- (id)init
{
    self = [super initWithWindowNibName:@"PCH_OffsetElongationDlog"];
    if (self) {
        // Initialization code here.
        self.offsetElongation = 0;
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

- (IBAction)handleElongOffsetButtonGroup:(id)sender
{
    NSButton *buttonPushed = sender;
    
    if (buttonPushed == self.offsetRadioButton)
    {
        self.offsetElongation = 1;
    }
    else if (buttonPushed == self.elongationRadioButton)
    {
        self.offsetElongation = 2;
    }
    else
    {
        self.offsetElongation = 0;
    }
}

@end
