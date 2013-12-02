// WindingGen.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "AndersenFE.h"
#include "WindingGen.h"
#import "PCH_WindingGenDlog.h"

/////////////////////////////////////////////////////////////////////////////
// WindingGen dialog


WindingGen::WindingGen()
{
 	
 	m_Terminal = 0;
 	m_Material = 0;
 	m_InnerDiameter = 0.0f;
 	m_RadOverbuild = 1.05f;
	m_ElHeight = 0.0f;
	m_NumSections = 1;
	m_CurrDirection = 0;
	m_NumDucts = 0;
	m_DuctDim = 0.0f;
	m_NoCondAxial = 1;
	m_NoCondRadial = 1;
	m_NoStrands = 0;
	m_StrandAxialDImn = 0.0f;
	m_StrandRadialDimn = 0.0f;
	m_CondType = 0;
	m_CondCover = 0.0f;
	m_BetSections = 0.0f;
	m_Type = 0;
	

	m_IsModify = false;
	m_OldWinding = NULL;
}



BOOL WindingGen::InitModifyDialog()
// This function may be totally overridden in ObjC section - we shall see
{
	m_Terminal = m_OldWinding->m_Terminal - 1;
 	m_Material = m_OldWinding->m_Material - 1;
 	m_InnerDiameter = m_OldWinding->m_LayerHead->m_InnerRadius * 2.0f;
 	m_RadOverbuild = m_OldWinding->m_RadialOverBuild;
	m_ElHeight = m_OldWinding->m_ElectricalHeight;
	m_NumSections = m_OldWinding->m_NumAxialSections;
	m_NumDucts = m_OldWinding->m_NumRadialDucts;
	m_DuctDim = m_OldWinding->m_RadialDuctDimn;
	m_NoCondAxial = m_OldWinding->m_CondNumAxial;
	m_NoCondRadial = m_OldWinding->m_CondNumRadial;
	m_StrandAxialDImn = m_OldWinding->m_StrandDimnAxial;
	m_StrandRadialDimn = m_OldWinding->m_StrandDimnRadial;
	m_CondType = m_OldWinding->m_CondType;
	m_CondCover = m_OldWinding->m_CondCover;
	m_BetSections = m_OldWinding->m_BetweenSections;
	m_Type = m_OldWinding->m_Type;

	// handle the current direction
	m_CurrDirection = m_OldWinding->m_LayerHead->m_CurrentDirection - 1;
	if (m_CurrDirection < 0)
		m_CurrDirection = 1;

/*
	// handle number of strands
	if (m_OldWinding->m_CondNumStrands == 1)
	{
		OnRadioSingle();
		
	}
	else if (m_OldWinding->m_CondNumStrands == 2)
	{
		OnRadioDouble();
	}
	else
	{
		OnRadioCtc();
	}
	m_NoStrands = m_OldWinding->m_CondNumStrands;


	// handle the section boxes
	if (m_Type > SHEETTYPE)
		EnableSectionBoxes();
	else
		EnableSectionBoxes(FALSE);
*/
	

	return true;
}


int WindingGen::DoModal()
{
    PCH_WindingGenDlog *newDlog = [[PCH_WindingGenDlog alloc] init];
    
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
