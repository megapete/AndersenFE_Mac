// SplitCustomDlog.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "AndersenFE.h"
#include "SplitCustomDlog.h"
#import "PCH_SplitCustomDlog.h"

// CSplitCustomDlog dialog



CSplitCustomDlog::CSplitCustomDlog()
{

}

CSplitCustomDlog::~CSplitCustomDlog()
{
}

int CSplitCustomDlog::DoModal()
{
    PCH_SplitCustomDlog *newDlog = [[PCH_SplitCustomDlog alloc] init];
    
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
