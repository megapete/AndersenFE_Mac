//
//  PCH_AddTermDlog.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PCH_AddTermDlog : NSWindowController

@property int termNum;
@property double kv;
@property double mva;
@property int connection;

- (instancetype)initAsModifyTermNumber:(int)termNum;

- (IBAction)okayButtonPushed:(id)sender;
- (IBAction)cancelButtonPushed:(id)sender;

@end
