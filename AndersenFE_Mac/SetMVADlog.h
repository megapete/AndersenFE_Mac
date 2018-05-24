//
//  SetMVADlog.h
//  AndersenFE_Mac
//
//  Created by PeterCoolAssHuber on 2018-05-23.
//  Copyright © 2018 Peter Huber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SetMVADlog : NSWindowController

@property (strong) IBOutlet NSTextField *mva;

- (IBAction)okayButtonPressed:(id)sender;

- (IBAction)cancelButtonPressed:(id)sender;

@end
