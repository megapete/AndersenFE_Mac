// AddTermDlog.cpp : implementation file
//

#include "stdafx.h"
#import <Foundation/Foundation.h>
#include "AndersenFE.h"
#include "AddTermDlog.h"
#import "PCH_AddTermDlog.h"




/////////////////////////////////////////////////////////////////////////////
// AddTermDlog dialog


AddTermDlog::AddTermDlog()

{
	
	m_Connection = 1;
	m_MVA = 18.0f;
	m_Voltage = 138.0f;
	m_Name = _T("HV");
	m_BoxTitle = _T("Add a terminal");
	
}



AddTermDlog::AddTermDlog(bool isModify, Terminal* wTerm)

{
	m_IsModify = isModify;

	if (m_IsModify)
	{
		m_BoxTitle = _T("Modify a terminal");
		m_Connection = wTerm->m_Connection;
		m_MVA = wTerm->m_MVA;
		m_Name = wTerm->m_Name;
		m_Voltage = wTerm->m_KV;
	}
}

int AddTermDlog::DoModal()
{
    PCH_AddTermDlog *newDlog = [[PCH_AddTermDlog alloc] init];
    
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


