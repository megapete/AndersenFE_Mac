// WindingDetailDlog.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "AndersenFE.h"
#include "WindingDetailDlog.h"
#import "PCH_WindingDetailDlog.h"

/////////////////////////////////////////////////////////////////////////////
// CWindingDetailDlog dialog


CWindingDetailDlog::CWindingDetailDlog()
{
	
	m_TotTurns = 0.0f;
	m_CircWidth = 0.0f;
	m_HiTap = 0.0f;
	m_LoTap = 0.0f;
	m_SpacerT = 0.0f;
	m_Text_CircW = _T("");
	m_Text_NumDisks = _T("");
	m_Text_SpacerT = _T("");
	m_Text_WdgTitle = _T("");
	m_Text_NumCols = _T("");
	m_NumColumns = 0.0f;
	m_NumSteps = 0;
	m_NumDisks = 0;
	m_HasTaps = 0;
	m_TapGap = 0.0f;
	

	m_IsModify = false;
	m_OldWinding = NULL;
}




/////////////////////////////////////////////////////////////////////////////
// CWindingDetailDlog message handlers

BOOL CWindingDetailDlog::OnInitDialog()
{
	/*

	if (m_WdgType >= 1)
	{
		m_BetDiskBox.ShowWindow(SW_HIDE);
		m_CtlCircW.ShowWindow(SW_HIDE);
		m_CtlSpacerT.ShowWindow(SW_HIDE);

	}
	else if (m_WdgType == 2)
	{
		m_CtlNumDisks.ShowWindow(SW_HIDE);
	}

	if (m_IsModify)
	{
		return OnModifyInitDialog();
	}

	EnableTapBoxes(FALSE);
     
     */

	return true;

}



BOOL CWindingDetailDlog::OnModifyInitDialog()
{
    /*
	m_TotTurns = m_OldWinding->m_TotalTurns;
	m_CircWidth = m_OldWinding->m_SpacerBlockWidth;
	m_HiTap = (m_OldWinding->m_HiTap - 1.0f) * 100.0f;
	m_LoTap = (m_OldWinding->m_LoTap - 1.0f) * 100.0f;
	m_SpacerT = m_OldWinding->m_BetweenDisks;
	m_NumColumns = (double)m_OldWinding->m_NumSpacerBlocks;
	m_NumSteps = m_OldWinding->m_NumTapSteps;
	m_NumDisks = m_OldWinding->m_NumDisks;
	m_TapGap = m_OldWinding->m_ReentrantGap;

	// handle taps in the winding
	m_HasTaps = m_OldWinding->m_TapLocation + 1;
	if (m_HasTaps == 0)
	{
		EnableTapBoxes(FALSE);
		m_HiTap = 0.0f;
		m_LoTap = 0.0f;
		m_NumSteps = 0;
		m_TapGap = 0.0f;
	}
	else if (m_HasTaps == 1)
	{
		EnableTapBoxes();
	}
	else // not yet implemented
	{
		EnableTapBoxes(FALSE);
	}

	*/

	return true;
}

int CWindingDetailDlog::DoModal()
{
    PCH_WindingDetailDlog *newDlog = [[PCH_WindingDetailDlog alloc] init];
    
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
