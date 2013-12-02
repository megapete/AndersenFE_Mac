//
//  PCH_AndersenFE_TxfoView.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/2/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PCH_AndersenFE_TxfoView : NSView

@property double scale;
@property NSArray *segmentPaths;
@property NSArray *arrowLocationsAndDirections;

- (void)setScaleForWindowHeight:(double)wWindowHt andWdgHt:(double)wHt withInnerID:(double)wID coreToInnerWdg:(double)wCoreClearance andOuterOD:(double)wOD tankToOuterWdg:(double)wTankClearance;

@end
