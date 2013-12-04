// AllTapsDialog.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "andersenfe.h"
#include "AllTapsDialog.h"
#import "PCH_AllTapsDlog.h"



/////////////////////////////////////////////////////////////////////////////
// CAllTapsDialog dialog


CAllTapsDialog::CAllTapsDialog()
{
	
	m_OffLoad = FALSE;
	m_OnLoad = FALSE;
	m_GapLocation = 0;
	m_Description = _T("");
	
}


int CAllTapsDialog::DoModal()
{
    PCH_AllTapsDlog *newDlog = [[PCH_AllTapsDlog alloc] init];
    
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
