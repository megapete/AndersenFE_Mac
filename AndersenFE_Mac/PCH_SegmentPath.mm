//
//  PCH_SegmentPath.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/4/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "PCH_SegmentPath.h"

#include "segment.h"
#include "layer.h"
#include "winding.h"

@implementation PCH_SegmentPath

#pragma mark -
#pragma mark Creation routines

+ (id)segmentPathWithPath:(NSBezierPath *)wPath andColor:(NSColor *)wColor andData:(NSDictionary *)wData
{
    return [[PCH_SegmentPath alloc] initWithPath:wPath andColor:wColor andData:wData];
}

- (id)initWithPath:(NSBezierPath *)wPath andColor:(NSColor *)wColor andData:(NSDictionary *)wData
{
    if (self = [super init])
    {
        _path = wPath;
        _color = wColor;
        _data = wData;
    }
    
    return self;
}

#pragma mark -
#pragma mark Segment / Layer / Winding wrappers

- (void)setRegulatingWindingWithNumLoops:(double)numLoops withAxialGap:(double)aGap isDoubleAxial:(BOOL)isDblAxial isMultiStart:(BOOL)isMutliStart
{
    Winding *winding = (Winding *)[self.data[SEGDATA_WINDING_KEY] pointerValue];
    
    winding->DefineRegulatingWdg((int)numLoops, aGap, (bool)isDblAxial, (bool)isMutliStart);
}

- (double)betweenSections
{
    Winding *winding = (Winding *)[self.data[SEGDATA_WINDING_KEY] pointerValue];
    
    return winding->m_BetweenSections;
}

- (int)currentDirection
{
    Winding *winding = (Winding *)[self.data[SEGDATA_WINDING_KEY] pointerValue];
    
    return winding->m_CurrentDirection;
}

- (void)toggleActivate
{
    [self activate:![self isActivated]];
}

- (void)activate:(BOOL)makeActive
{
    Winding *winding = (Winding *)[self.data[SEGDATA_WINDING_KEY] pointerValue];
    Segment *segment = (Segment *)[self.data[SEGDATA_SEGMENT_KEY] pointerValue];
    Layer *layer = (Layer *)[self.data[SEGDATA_LAYER_KEY] pointerValue];
    
    if (makeActive)
    {
        segment->m_NumTurnsActive = segment->m_NumTurnsTotal;
    }
    else
    {
        segment->m_NumTurnsActive = 0.0;
    }
}

- (BOOL)isActivated
{
    Segment *segment = (Segment *)[self.data[SEGDATA_SEGMENT_KEY] pointerValue];
    
    return (BOOL)segment->IsActive();
}

#pragma mark -
#pragma mark C++ interface routines

- (void)centerWindingOnWindingOfSegment:(PCH_SegmentPath *)wSegPath
{
    Winding *thisWinding = (Winding *)[self.data[SEGDATA_WINDING_KEY] pointerValue];
    Winding *refWinding = (Winding *)[wSegPath.data[SEGDATA_WINDING_KEY] pointerValue];
    
    double yOffset = refWinding->GetAxialCenter() - thisWinding->GetAxialCenter();
    
    thisWinding->OffsetZ(yOffset);
    
    
}

@end
