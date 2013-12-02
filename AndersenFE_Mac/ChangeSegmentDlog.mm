// ChangeSegmentDlog.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "AndersenFE.h"
#include "ChangeSegmentDlog.h"
#import "PCH_ChangeSegmentDlog.h"

// CChangeSegmentDlog dialog



CChangeSegmentDlog::CChangeSegmentDlog()

{

}

CChangeSegmentDlog::~CChangeSegmentDlog()
{
}



int CChangeSegmentDlog::DoModal()
{
    PCH_ChangeSegmentDlog *newDlog = [[PCH_ChangeSegmentDlog alloc] init];
    
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

