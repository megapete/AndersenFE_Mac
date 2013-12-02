// RegWdgDlog.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "AndersenFE.h"
#include "RegWdgDlog.h"
#import "PCH_RegWdgDlog.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CRegWdgDlog dialog


CRegWdgDlog::CRegWdgDlog()
{
	
	m_IsDoubleAxial = TRUE;
	m_AxialGap = 0.0f;
	m_NumLoops = 8;
	m_IsMultiStart = FALSE;
	
}

int CRegWdgDlog::DoModal()
{
    PCH_RegWdgDlog *newDlog = [[PCH_RegWdgDlog alloc] init];
    
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

