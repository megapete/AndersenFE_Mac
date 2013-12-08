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

- (void)moveWinding:(id)sender;
- (void)centerWinding:(id)sender;
- (void)splitSegmentEqual:(id)sender;
- (void)splitSegmentCustom:(id)sender;
- (void)createParallelLayer:(id)sender;
- (void)activate:(id)sender;
- (void)deactivate:(id)sender;
- (void)regWinding:(id)sender;

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
#pragma mark Mouse event responders

- (void)rightMouseDown:(NSEvent *)theEvent
{
    NSPoint whereClicked = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    int i;
    
    for (i=0; i<self.segmentPaths.count; i++)
    {
        NSBezierPath *nextSegment = self.segmentPaths[i];
        
        if ([nextSegment containsPoint:whereClicked])
        {
            break;
        }
    }
    
    if (i < self.segmentPaths.count)
    {
        self.lastRBLocation = whereClicked;
        
        // Modify Winding...
        // Move winding...
        // Center winding...
        // ------
        // Split segment equally
        // Split segment custom
        // Change segment data...
        // -------
        // Create parallel layer
        // -------
        // Activate / Deactivate
        // -------
        // Regulating winding...
        
        NSMenu *wdgMenu = [[NSMenu alloc] initWithTitle:@"Windings"];
        [wdgMenu addItemWithTitle:@"Modify Winding..." action:@selector(unhandledEvent:) keyEquivalent:@""];
        [[wdgMenu itemAtIndex:0] setEnabled:NO];
        [wdgMenu addItemWithTitle:@"Move Winding..." action:@selector(moveWinding:) keyEquivalent:@""];
        [wdgMenu addItemWithTitle:@"Center winding..." action:@selector(centerWinding:) keyEquivalent:@""];
        [wdgMenu addItem:[NSMenuItem separatorItem]];
        [wdgMenu addItemWithTitle:@"Split segment equally..." action:@selector(splitSegmentEqual:) keyEquivalent:@""];
        [wdgMenu addItemWithTitle:@"Split segment custom..." action:@selector(splitSegmentCustom:) keyEquivalent:@""];
        [wdgMenu addItemWithTitle:@"Change segment data..." action:@selector(unhandledEvent:) keyEquivalent:@""];
        [wdgMenu addItem:[NSMenuItem separatorItem]];
        [wdgMenu addItemWithTitle:@"Create parallel layer..." action:@selector(createParallelLayer:) keyEquivalent:@""];
        [wdgMenu addItem:[NSMenuItem separatorItem]];
        [wdgMenu addItemWithTitle:@"Activate" action:@selector(activate:) keyEquivalent:@""];
        [wdgMenu addItemWithTitle:@"Deactivate" action:@selector(deactivate:) keyEquivalent:@""];
        [wdgMenu addItem:[NSMenuItem separatorItem]];
        [wdgMenu addItemWithTitle:@"Regulating winding..." action:@selector(regWinding:) keyEquivalent:@""];
        
        [NSMenu popUpContextMenu:wdgMenu withEvent:theEvent forView:self];
    }
    else
    {
        [super rightMouseDown:theEvent];
    }
}

#pragma mark -
#pragma mark Contextual menu handlers

- (void)unhandledEvent:(id)sender
{
    NSLog(@"Unimplemented menu");
}

- (void)moveWinding:(id)sender
{
    
}

- (void)centerWinding:(id)sender
{
    
}

- (void)splitSegmentEqual:(id)sender
{
    
}

- (void)splitSegmentCustom:(id)sender
{
    
}

- (void)createParallelLayer:(id)sender
{
    
}

- (void)activate:(id)sender
{
    
}

- (void)deactivate:(id)sender
{
    
}

- (void)regWinding:(id)sender
{
    
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
