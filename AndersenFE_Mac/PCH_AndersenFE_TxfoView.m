//
//  PCH_AndersenFE_TxfoView.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/2/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "PCH_AndersenFE_TxfoView.h"
#import "PCH_SegmentPath.h"
#import "AppController.h"

@interface PCH_AndersenFE_TxfoView ()

- (void)drawArrowAt:(NSPoint)wLoc withColor:(NSColor *)wColor;

@end

#pragma mark -
#pragma mark Creation routines

@implementation PCH_AndersenFE_TxfoView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib
{
    self.segmentPaths = nil;
    self.arrowLocationsAndDirections = nil;
}

#pragma mark -
#pragma mark Drawing routines

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] set];
    [[NSBezierPath bezierPathWithRect:self.bounds] fill];
    
    // Drawing code here.
    if (self.segmentPaths)
    {
        for (PCH_SegmentPath *nextPath in self.segmentPaths)
        {
            [nextPath.color set];
            [[nextPath path] setLineWidth:self.scale];
            [[nextPath path] stroke];
        }
    }
    
}

- (void)drawArrowAt:(NSPoint)wLoc withColor:(NSColor *)wColor
// wLoc should hold the point (in transformer window coordinates) of the arrow
{
    const int arrowHeight = 15; // points (or pixels?)
    const int arrowHeadW = 3;
    const int arrowHeadH = 5;
    
    [NSGraphicsContext saveGraphicsState];
    
    [wColor set];
    [NSBezierPath setDefaultLineWidth:self.scale];
    
    NSBezierPath *newArrow = [NSBezierPath bezierPath];
    [newArrow moveToPoint:wLoc];
    [newArrow lineToPoint:NSMakePoint(wLoc.x, wLoc.y - arrowHeight * self.scale)];
    [newArrow moveToPoint:wLoc];
    [newArrow lineToPoint:NSMakePoint(wLoc.x - arrowHeadW * self.scale, wLoc.y - arrowHeadH * self.scale)];
    [newArrow moveToPoint:wLoc];
    [newArrow lineToPoint:NSMakePoint(wLoc.x + arrowHeadW * self.scale, wLoc.y - arrowHeadH * self.scale)];
    [newArrow stroke];
    
    [NSGraphicsContext restoreGraphicsState];
}

#pragma mark -
#pragma mark Scale-setting routine

- (void)setScaleForWindowHeight:(double)wWindowHt withInnerIR:(double)wIR coreToInnerWdg:(double)wCoreClearance andOuterOR:(double)wOR tankToOuterWdg:(double)wTankClearance
{
    // Create a rectangle size for the transformer to work with
    NSRect transfoRect = NSMakeRect(0, 0, wOR - wIR + wCoreClearance + wTankClearance, wWindowHt);
    
    // We don't want to distort the image (we want it to scale), so we'll check the scale required so that that will not happen
    
    
    CGFloat xScale = transfoRect.size.width / self.frame.size.width;
    CGFloat yScale = transfoRect.size.height / self.frame.size.height;
    
    // CGFloat offsetY = 0.0;
    
    if (xScale > yScale)
    {
        self.scale = xScale;
        transfoRect.size.height = self.frame.size.height * xScale;
    }
    else
    {
        self.scale = yScale;
        transfoRect.size.width = self.frame.size.width * yScale;
    }
    
    [self zoomRect:transfoRect];
}

- (void)zoomRect:(NSRect)newRect
{
    // handle zooms here
    [self setBounds:newRect];
    
    [self setNeedsDisplay:YES];
}

@end
