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

- (void)setScaleForWdgHt:(double)wHt andOD:(double)wOD;

@end
