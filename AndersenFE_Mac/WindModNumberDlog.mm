// WindModNumberDlog.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "AndersenFE.h"
#include "WindModNumberDlog.h"
#import "PCH_WindModNumberDlog.h"



/////////////////////////////////////////////////////////////////////////////
// WindModNumberDlog dialog


WindModNumberDlog::WindModNumberDlog()
{
	

	
}


int WindModNumberDlog::DoModal()
{
    PCH_WindModNumberDlog *newDlog = [[PCH_WindModNumberDlog alloc] init];
    
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

