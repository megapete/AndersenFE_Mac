// MoveWdgDlog.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "AndersenFE.h"
#include "MoveWdgDlog.h"
#import "PCH_MoveWdgDlog.h"



/////////////////////////////////////////////////////////////////////////////
// CMoveWdgDlog dialog


CMoveWdgDlog::CMoveWdgDlog()
{
	
	m_VertOffset = 0.0f;
	m_HorOffset = 0.0f;
	m_MoveOuterWdgs = TRUE;
	
}


int CMoveWdgDlog::DoModal()
{
    PCH_MoveWdgDlog *newDlog = [[PCH_MoveWdgDlog alloc] init];
    
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
