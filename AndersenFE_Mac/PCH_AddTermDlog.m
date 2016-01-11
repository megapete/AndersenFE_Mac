//
//  PCH_AddTermDlog.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "PCH_AddTermDlog.h"

@interface PCH_AddTermDlog ()

@property BOOL isModify;

@end

@implementation PCH_AddTermDlog

- (id)init
{
    self = [super initWithWindowNibName:@"PCH_AddTermDlog"];
    if (self) {
        // Initialization code here.
        self.isModify = NO;
    }
    return self;
}

- (instancetype)initAsModifyTermNumber:(int)termNum
{
    if (self = [self init])
    {
        self.isModify = YES;
        self.termNum = termNum;
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
