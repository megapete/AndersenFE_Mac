// RunningMessageDlog.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "andersenfe.h"
#include "RunningMessageDlog.h"
#import "PCH_RunningMessageDlog.h"



/////////////////////////////////////////////////////////////////////////////
// CRunningMessageDlog dialog


CRunningMessageDlog::CRunningMessageDlog()
{
	m_ShowText = _T("");
}


int CRunningMessageDlog::DoModal()
{
    PCH_RunningMessageDlog *newDlog = [[PCH_RunningMessageDlog alloc] init];
    
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

