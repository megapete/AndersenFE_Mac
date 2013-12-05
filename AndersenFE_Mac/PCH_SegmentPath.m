//
//  PCH_SegmentPath.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/4/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "PCH_SegmentPath.h"

@implementation PCH_SegmentPath

#pragma mark -
#pragma mark Creation routines

+ (id)segmentPathWithPath:(NSBezierPath *)wPath andColor:(NSColor *)wColor
{
    return [[PCH_SegmentPath alloc] initWithPath:wPath andColor:wColor];
}

- (id)initWithPath:(NSBezierPath *)wPath andColor:(NSColor *)wColor
{
    if (self = [super init])
    {
        _path = wPath;
        _color = wColor;
    }
    
    return self;
}

@end
