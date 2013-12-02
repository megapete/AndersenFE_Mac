#if !defined(AFX_WINDINGDETAILDLOG_H__87F32ABC_A7D0_43C0_AC64_F9DB3868DEB2__INCLUDED_)
#define AFX_WINDINGDETAILDLOG_H__87F32ABC_A7D0_43C0_AC64_F9DB3868DEB2__INCLUDED_

#include "Winding.h"	// Added by ClassView

//

/////////////////////////////////////////////////////////////////////////////
// CWindingDetailDlog dialog

class CWindingDetailDlog
{
// Construction
public:
	BOOL OnModifyInitDialog();
	Winding* m_OldWinding;
	bool m_IsModify;
	// void EnableTapBoxes(BOOL wState = TRUE);
	int m_WdgType;
	BOOL OnInitDialog( );
	CWindingDetailDlog();   // standard constructor

// Dialog Data
	
	double	m_CtlTapGap;
	double	m_CtlNumSteps;
	double	m_CtlLoTap;
	double	m_CtlHiTap;
	double	m_CtlNumDisks;
	double	m_CtlCircW;
	double	m_CtlSpacerT;
	// CButton	m_BetDiskBox;
	double	m_TotTurns;
	double	m_CircWidth;
	double	m_HiTap;
	double	m_LoTap;
	double	m_SpacerT;
	CString	m_Text_CircW;
	CString	m_Text_NumDisks;
	CString	m_Text_SpacerT;
	CString	m_Text_WdgTitle;
	CString	m_Text_NumCols;
	double	m_NumColumns;
	int		m_NumSteps;
	int		m_NumDisks;
	int		m_HasTaps;
	double	m_TapGap;
    
    int DoModal();
	
};



#endif // !defined(AFX_WINDINGDETAILDLOG_H__87F32ABC_A7D0_43C0_AC64_F9DB3868DEB2__INCLUDED_)
