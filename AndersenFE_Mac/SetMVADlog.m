//
//  SetMVADlog.m
//  AndersenFE_Mac
//
//  Created by PeterCoolAssHuber on 2018-05-23.
//  Copyright © 2018 Peter Huber. All rights reserved.
//

#import "SetMVADlog.h"

@interface SetMVADlog ()

@end

@implementation SetMVADlog

- (id)init
{
    self = [super initWithWindowNibName:@"SetMVADlog"];
    if (self) {
        // Initialization code here.
        
    }
    return self;
}

- (void)windowDidLoad {
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
