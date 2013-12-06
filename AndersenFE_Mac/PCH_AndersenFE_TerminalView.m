//
//  PCH_AndersenFE_TerminalView.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/2/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "PCH_AndersenFE_TerminalView.h"

@implementation PCH_AndersenFE_TerminalView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.refTerminal = -1;
    }
    return self;
}

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
                [nextRect setLineWidth:2.0 * baseLineWidth];
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

@end
