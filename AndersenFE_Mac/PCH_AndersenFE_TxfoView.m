//
//  PCH_AndersenFE_TxfoView.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/2/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "PCH_AndersenFE_TxfoView.h"

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

#pragma mark -
#pragma mark Drawing routines

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (void)drawArrowAt:(NSPoint)wLoc withColor:(NSColor *)wColor
{
    
}

#pragma mark -
#pragma mark Scale-setting routine

- (void)setScaleForWindowHeight:(double)wWindowHt andWdgHt:(double)wHt withInnerID:(double)wID coreToInnerWdg:(double)wCoreClearance andOuterOD:(double)wOD tankToOuterWdg:(double)wTankClearance
{
    // Create a rectangle size for the transformer to work with
    NSRect transfoRect = NSMakeRect(0, 0, wOD - wID + wCoreClearance + wTankClearance, wWindowHt);
    
    // We don't want to distort the image (we want it to scale), so we'll check the scale required so that that will not happen
    const CGFloat totalInset = 0.0;
    
    CGFloat xScale = transfoRect.size.width / (self.frame.size.width - totalInset);
    CGFloat yScale = transfoRect.size.height / (self.frame.size.height - totalInset);
    
    PCH_AndersenFE_TxfoView *theView = self;
    
    // CGFloat offsetY = 0.0;
    
    if (xScale > yScale)
    {
        theView.scale = xScale;
        transfoRect.size.height = (self.frame.size.height - totalInset) * xScale;
        
        // if the x-dimension dictates the scale, we want the solution space centred vertically, so we adjust the new rectangle accordingly
        
        // CGFloat offsetY = (theMeshRect.size.height - self.associatedMesh.bounds.size.height) / 2.0;
       // theMeshRect = NSOffsetRect(theMeshRect, 0.0, -offsetY);
    }
    else
    {
        theView.scale = yScale;
        // theMeshRect.size.width = (self.view.frame.size.width - totalInset) * yScale;
    }
    
    //theMeshRect = NSInsetRect(theMeshRect, -totalInset * theView.scale / 2.0, -totalInset * theView.scale / 2.0);
    
    [self zoomRect:transfoRect];
}

- (void)zoomRect:(NSRect)newRect
{
    // handle zooms here
    [self setBounds:newRect];
    
    [self setNeedsDisplay:YES];
}

@end
