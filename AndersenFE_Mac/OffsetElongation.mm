// OffsetElongation.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "andersenfe.h"
#include "OffsetElongation.h"
#import "PCH_OffsetElongationDlog.h"



/////////////////////////////////////////////////////////////////////////////
// COffsetElongation dialog


COffsetElongation::COffsetElongation()
{
	
	m_Operation = 0;
	m_ForceValue = 0.25f;
	m_ProofStress = 18000.0f;
	m_MaxEndThrust = 110000.0f;
	m_FindMaxValue = 1;
	m_ImpUseCalc = 0;
	m_ImpUseThis = 0.0;
	
}


int COffsetElongation::DoModal()
{
    PCH_OffsetElongationDlog *newDlog = [[PCH_OffsetElongationDlog alloc] init];
    
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

