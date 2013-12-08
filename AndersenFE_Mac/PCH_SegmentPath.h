//
//  PCH_SegmentPath.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/4/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Foundation/Foundation.h>

// Keys into the dictionaries in the segmentData dictionary
#define SEGDATA_RECTANGLE_KEY     @"Rectangle"
#define SEGDATA_WINDING_KEY       @"Winding"
#define SEGDATA_SEGMENT_KEY       @"Segment"
#define SEGDATA_LAYER_KEY         @"Layer"

@interface PCH_SegmentPath : NSObject

@property NSBezierPath *path;
@property NSColor *color;
@property NSDictionary *data;

+ (id)segmentPathWithPath:(NSBezierPath *)wPath andColor:(NSColor *)wColor andData:(NSDictionary *)wData;
- (id)initWithPath:(NSBezierPath *)wPath andColor:(NSColor *)wColor andData:(NSDictionary *)wData;

@end
