//
//  PCH_TxfoDataDlog.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PCH_TxfoDataDlog;

struct txfoDataDlogImpl
{
    PCH_TxfoDataDlog __unsafe_unretained *dataDlogImpl;
};

@interface PCH_TxfoDataDlog : NSWindowController

@property (strong) IBOutlet NSTextField *description;

- (IBAction)okayButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end
