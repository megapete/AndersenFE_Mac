//
//  PCH_SegmentPath.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/4/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCH_SegmentPath : NSObject

@property NSBezierPath *path;
@property NSColor *color;

+ (id)segmentPathWithPath:(NSBezierPath *)wPath andColor:(NSColor *)wColor;
- (id)initWithPath:(NSBezierPath *)wPath andColor:(NSColor *)wColor;

@end
