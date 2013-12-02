// TxfoDataDlog.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "AndersenFE.h"
#include "TxfoDataDlog.h"
#import "PCH_TxfoDataDlog.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// TxfoDataDlog dialog


TxfoDataDlog::TxfoDataDlog()
{
	
}

int TxfoDataDlog::DoModal()
{
    PCH_TxfoDataDlog *newDlog = [[PCH_TxfoDataDlog alloc] init];
    
    NSInteger result = [NSApp runModalForWindow:newDlog.window];
    int funcResult = IDCANCEL;
    
    if (result == NSRunStoppedResponse)
    {
        // user pressed okay, handle it
        
        // there is probably a better way to do this...
        m_Description = "";
        m_Description.append([[newDlog.description stringValue] cStringUsingEncoding:NSUnicodeStringEncoding]);
        
        funcResult = IDOK;
    }
    else // probably cancel
    {
        
        funcResult = IDCANCEL;
    }
    
    [newDlog.window close];
    
    return funcResult;
}



