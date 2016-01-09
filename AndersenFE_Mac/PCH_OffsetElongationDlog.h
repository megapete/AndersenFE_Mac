//
//  PCH_OffsetElongationDlog.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PCH_OffsetElongationDlog : NSWindowController
- (IBAction)okayButtonPushed:(id)sender;
- (IBAction)cancelButtonPushed:(id)sender;

@property (strong) IBOutlet NSTextField *fixedImpedance;
@property (strong) IBOutlet NSMatrix *impedanceSelector;
@property (weak) IBOutlet NSTextField *elongationField;

@property (weak) IBOutlet NSTextField *offsetField;

- (IBAction)handleElongOffsetButtonGroup:(id)sender;

@end
