//
//  PCH_AndersenFE_TxfoView.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/2/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;

@interface PCH_AndersenFE_TxfoView : NSView

@property double scale;
@property NSArray *segmentPaths;
@property NSArray *arrowLocationsAndDirections;
@property AppController *theAppController;

@property NSPoint lastRBLocation;

- (void)setScaleForWindowHeight:(double)wWindowHt withInnerIR:(double)wIR coreToInnerWdg:(double)wCoreClearance andOuterOR:(double)wOR tankToOuterWdg:(double)wTankClearance;

@end
