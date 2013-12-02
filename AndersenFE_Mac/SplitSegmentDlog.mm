// SplitSegmentDlog.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "AndersenFE.h"
#include "SplitSegmentDlog.h"
#import "PCH_SplitSegmentDlog.h"


/////////////////////////////////////////////////////////////////////////////
// CSplitSegmentDlog dialog


CSplitSegmentDlog::CSplitSegmentDlog()

{
	
	m_BetweenSegs = 0.0f;
	m_NumSegs = 0;
	
}



int CSplitSegmentDlog::DoModal()
{
    PCH_SplitSegmentDlog *newDlog = [[PCH_SplitSegmentDlog alloc] init];
    
    NSInteger result = [NSApp runModalForWindow:newDlog.window];
    int funcResult = IDCANCEL;
    
    if (result == NSRunStoppedResponse)
    {
        // user pressed okay, handle it
        
        funcResult = IDOK;
    }
    else // probably cancel
    {
        
        funcResult = IDCANCEL;
    }
    
    [newDlog.window close];
    
    return funcResult;
}