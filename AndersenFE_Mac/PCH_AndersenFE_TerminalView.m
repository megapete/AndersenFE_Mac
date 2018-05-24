//
//  PCH_AndersenFE_TerminalView.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/2/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "PCH_AndersenFE_TerminalView.h"
#import "AppController.h"

@interface PCH_AndersenFE_TerminalView()

@property int rbClickInTerminal;

- (void)handleSetVPN_RefTerm:(id)sender;
- (void)modifyTerminalData:(id)sender;
- (void)raiseMVAToNextStage:(id)sender;
- (void)lowerMVAToPrevStage:(id)sender;
- (void)setMVAToZero:(id)sender;
- (void)setMVAToBalanceNI:(id)sender;
- (void)runAndersenProgram:(id)sender;


@end

#pragma mark -
#pragma mark Creation routines

@implementation PCH_AndersenFE_TerminalView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.refTerminal = -1;
        self.rbClickInTerminal = -1;
    }
    return self;
}

#pragma mark -
#pragma mark Drawing update routine

- (void)drawRect:(NSRect)dirtyRect
{
    const CGFloat baseLineWidth = 1.5;
    
	if (self.dataViews)
    {
        [NSGraphicsContext saveGraphicsState];
        
        int i = 0;
        
        for (NSTextField *nextField in self.dataViews)
        {
            NSBezierPath *nextRect = [NSBezierPath bezierPathWithRect:nextField.frame];
            
            if (i == self.refTerminal)
            {
                [nextRect setLineWidth:3.0 * baseLineWidth];
            }
            else
            {
                [nextRect setLineWidth:baseLineWidth];
            }
            
            NSColor *bColor = self.borderColors[i];
            [bColor set];
            
            [nextRect stroke];
            
            i++;
        }
        
        [NSGraphicsContext restoreGraphicsState];
    }
}


#pragma mark -
#pragma mark Mouse event responders

- (void)rightMouseDown:(NSEvent *)theEvent
{
    NSPoint whereClicked = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    int i;
    
    for (i=0; i<self.dataViews.count; i++)
    {
        NSTextField *nextTerm = self.dataViews[i];
        
        if (NSPointInRect(whereClicked, nextTerm.frame))
        {
            break;
        }
    }
    
    if (i < self.dataViews.count)
    {
        NSLog(@"Right click in Terminal: %d", i);
        self.refTerminal = i;
        
        // we only show a menu if the right click was in a valid terminal square
        // Old AndersenFE Terminal contextual menu items:
        // Run Andersen...
        // Add Winding...
        // Modify Terminal...
        // Change MVA to ONAF
        // Set VPN Reference
        // Calculate MVA
        
        NSMenu *termMenu = [[NSMenu alloc] initWithTitle:@"Terminals"];
        [termMenu addItemWithTitle:@"Run Andersen Program..." action:@selector(runAndersenProgram:) keyEquivalent:@""];
        [termMenu addItem:[NSMenuItem separatorItem]];
        [termMenu addItemWithTitle:@"Modify Terminal Data..." action:@selector(modifyTerminalData:) keyEquivalent:@""];
        [termMenu addItem:[NSMenuItem separatorItem]];
        [termMenu addItemWithTitle:@"Set VPN Reference" action:@selector(handleSetVPN_RefTerm:) keyEquivalent:@""];
        [termMenu addItem:[NSMenuItem separatorItem]];
        [termMenu addItemWithTitle:@"Lower MVA to previous fan stage" action:@selector(lowerMVAToPrevStage:) keyEquivalent:@""];
        [termMenu addItemWithTitle:@"Raise MVA to next fan stage" action:@selector(raiseMVAToNextStage:) keyEquivalent:@""];
        [termMenu addItem:[NSMenuItem separatorItem]];
        [termMenu addItemWithTitle:@"Set MVA to zero" action:@selector(setMVAToZero:) keyEquivalent:@""];
        [termMenu addItemWithTitle:@"Set MVA to balance amp-turns" action:@selector(setMVAToBalanceNI:) keyEquivalent:@""];
        [termMenu addItemWithTitle:@"Set MVA to ..." action:@selector(setMVAToNumber:) keyEquivalent:@""];
        
        [NSMenu popUpContextMenu:termMenu withEvent:theEvent forView:self];
    }
    else
    {
        [super rightMouseDown:theEvent];
    }
}

#pragma mark -
#pragma mark Contextual menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if ([menuItem action] == @selector(runAndersenProgram:))
    {
        return [self.theAppController andersenFoldersAreValid] && [self.theAppController currentTransformerIsSaveable];
    }
    
    if ([menuItem action] == @selector(lowerMVAToPrevStage:))
    {
        return !([self.theAppController currentTxfoCoolingStage] == 0);
    }
    
    if ([menuItem action] == @selector(raiseMVAToNextStage:))
    {
        return !([self.theAppController currentTxfoCoolingStage] == 2);
    }
    
    return YES;
}

#pragma mark -
#pragma mark Contextual menu handlers

- (void)modifyTerminalData:(id)sender
{
    [self.theAppController handleModifyOfTermNumber:self.refTerminal];
}

- (void)setMVAToBalanceNI:(id)sender
{
    [self.theAppController setMVAToBalanceAmpTurnsForTerminal:self.refTerminal];
}

- (void)setMVAToZero:(id)sender
{
    [self.theAppController setMVAToZeroForTerminal:self.refTerminal];
}

- (void)setMVAToNumber:(id)sender
{
    [self.theAppController setMVAToNumberForTerminal:self.refTerminal];
}

- (void)runAndersenProgram:(id)sender
{
    NSError *wError;
    
    [self.theAppController runAndersenForCurrentTransformerWithError:&wError];
}

- (void)lowerMVAToPrevStage:(id)sender
{
    [self.theAppController changeFanStageWithDirection:-1];
}

- (void)raiseMVAToNextStage:(id)sender
{
    [self.theAppController changeFanStageWithDirection:+1];
}

- (void)handleSetVPN_RefTerm:(id)sender
{
    NSLog(@"Setting VPN terminal");
    [self.theAppController setVPNRefToTermNumber:self.refTerminal];
}

@end
