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
{
    // int _mode;
}

@property PCH_SegmentPath *segmentSelected;

- (void)moveWinding:(id)sender;
- (void)centerWinding:(id)sender;
- (void)splitSegmentEqual:(id)sender;
- (void)splitSegmentCustom:(id)sender;
- (void)createParallelLayer:(id)sender;
- (void)activate:(id)sender;
- (void)deactivate:(id)sender;
- (void)regWinding:(id)sender;

- (void)drawArrowAt:(CGFloat)wXLoc withDirection:(int)wDirection;

@end

#pragma mark -
#pragma mark Creation routines

@implementation PCH_AndersenFE_TxfoView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _mode = txfoViewNormalMode;
        self.segmentSelected = nil;
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
    
    NSMutableSet *arrowSet = [NSMutableSet set];
    
    // Drawing code here.
    if (self.segmentPaths)
    {
        for (PCH_SegmentPath *nextPath in self.segmentPaths)
        {
            [nextPath.color set];
            [[nextPath path] setLineWidth:self.scale];
            [[nextPath path] stroke];
            
            if (![nextPath isActivated])
            {
                [[nextPath.color colorWithAlphaComponent:0.25] set];
                [[nextPath path] fill];
            }
            
            [nextPath.color set];
            
            NSRect segRect = [nextPath.data[SEGDATA_RECTANGLE_KEY] rectValue];
            double rectCenterX = segRect.origin.x + segRect.size.width / 2.0;
            NSNumber *rectCenterXnumber = [NSNumber numberWithDouble:rectCenterX];
            
            if (![arrowSet containsObject:rectCenterXnumber])
            {
                [self drawArrowAt:rectCenterX withDirection:[nextPath currentDirection]];
            }
            
            [arrowSet addObject:rectCenterXnumber];
        }
    }
    
}

- (void)drawArrowAt:(CGFloat)wXLoc withDirection:(int)wDirection
// wXLoc should hold the x-dimension of the point (in transformer window coordinates) of the arrow
{
    if (wDirection < 0)
    {
        wDirection = -1;
    }
    else if (wDirection > 0)
    {
        wDirection = 1;
    }
    
    const int arrowHeight = 15; // points (or pixels?)
    const int arrowHeadW = 3;
    const int arrowHeadH = 5;
    const int arrowBottom = 10;
    
    
    NSBezierPath *newArrow = [NSBezierPath bezierPath];
    
    [newArrow moveToPoint:NSMakePoint(wXLoc, arrowBottom * self.scale)];
    [newArrow lineToPoint:NSMakePoint(wXLoc, (arrowBottom + arrowHeight) * self.scale)];
    
    if (wDirection < 0)
    {
        [newArrow moveToPoint:NSMakePoint(wXLoc, arrowBottom * self.scale)];
    }
    
    NSPoint arrowHeadPoint = [newArrow currentPoint]; // in transformer window coordinates
    
    [newArrow lineToPoint:NSMakePoint(wXLoc - arrowHeadW * self.scale, arrowHeadPoint.y - wDirection * arrowHeadH * self.scale)];
    [newArrow moveToPoint:arrowHeadPoint];
    [newArrow lineToPoint:NSMakePoint(wXLoc + arrowHeadW * self.scale, arrowHeadPoint.y - wDirection * arrowHeadH * self.scale)];
    
    [newArrow setLineWidth:self.scale];
    [newArrow stroke];
    
}

#pragma mark -
#pragma mark View mode changing


- (void)setMode:(int)mode
{
    _mode = mode;
    
    [self.window invalidateCursorRectsForView:self];
}

#pragma mark -
#pragma mark Mouse event responders

- (void)mouseDown:(NSEvent *)theEvent
{
    if (self.mode == txfoViewNormalMode)
    {
        [super mouseDown:theEvent];
    }
    
    // we're in "winding selection" mode
    NSPoint whereClicked = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    int i;
    
    for (i=0; i<self.segmentPaths.count; i++)
    {
        PCH_SegmentPath *nextSegment = self.segmentPaths[i];
        NSValue *nextRectValue = nextSegment.data[SEGDATA_RECTANGLE_KEY];
        NSRect segmentRect = [nextRectValue rectValue];
        
        if (NSPointInRect(whereClicked, segmentRect))
        {
            if (nextSegment == self.segmentSelected)
            {
                [self setMode:txfoViewNormalMode];
                return;
            }
            
            break;
        }
    }
    
    if (i < self.segmentPaths.count)
    {
        // center (axially) the winding in self.segmentSelected on self.segmentPaths[i]
        PCH_SegmentPath *refSegment = self.segmentPaths[i];
        
        [self.segmentSelected centerWindingOnWindingOfSegment:refSegment];
        
        [self.theAppController updateTxfoView];
    }
    
    [self setMode:txfoViewNormalMode];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    [self setMode:txfoViewNormalMode];
    
    NSPoint whereClicked = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    int i;
    self.segmentSelected = nil;
    
    for (i=0; i<self.segmentPaths.count; i++)
    {
        PCH_SegmentPath *nextSegment = self.segmentPaths[i];
        NSValue *nextRectValue = nextSegment.data[SEGDATA_RECTANGLE_KEY];
        NSRect segmentRect = [nextRectValue rectValue];
        
        if (NSPointInRect(whereClicked, segmentRect))
        {
            self.segmentSelected = nextSegment;
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
#pragma mark The correct way to handle cursor-changing stuff

- (void)resetCursorRects
{
    if (self.mode == txfoViewSelectWdgMode)
    {
        for (PCH_SegmentPath *nextSegment in self.segmentPaths)
        {
            if (nextSegment != self.segmentSelected)
            {
                NSValue *nextRectValue = nextSegment.data[SEGDATA_RECTANGLE_KEY];
                NSRect segmentRect = [nextRectValue rectValue];
                [self addCursorRect:segmentRect cursor:[NSCursor pointingHandCursor]];
            }
        }
    }
}

#pragma mark -
#pragma mark Contextual menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if ([menuItem action] == @selector(unhandledEvent:))
    {
        return NO;
    }
    
    if ([self.segmentSelected isActivated])
    {
        if ([menuItem action] == @selector(activate:))
        {
            return NO;
        }
    }
    else
    {
        if ([menuItem action] == @selector(deactivate:))
        {
            return NO;
        }
    }
    
    return YES;
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
    // this is both the simplest and the most complicated of the handlers in that it doesn't just call up a dialog box, but instead changes the cursor, as well as the "mode" of the view
    
    [self setMode:txfoViewSelectWdgMode];
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
    [self.segmentSelected activate:YES];
    [self.theAppController updateTxfoView];
}

- (void)deactivate:(id)sender
{
    [self.segmentSelected activate:NO];
    [self.theAppController updateTxfoView];
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
