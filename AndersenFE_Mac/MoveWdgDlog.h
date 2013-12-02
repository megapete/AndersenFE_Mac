#if !defined(AFX_MOVEWDGDLOG_H__F737DD8F_4093_4666_BA34_1937E1C93894__INCLUDED_)
#define AFX_MOVEWDGDLOG_H__F737DD8F_4093_4666_BA34_1937E1C93894__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// MoveWdgDlog.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CMoveWdgDlog dialog

class CMoveWdgDlog
{
// Construction
public:
	CMoveWdgDlog();   // standard constructor

// Dialog Data
	
	double	m_VertOffset;
	double	m_HorOffset;
	BOOL	m_MoveOuterWdgs;
	
    int DoModal();


};



#endif // !defined(AFX_MOVEWDGDLOG_H__F737DD8F_4093_4666_BA34_1937E1C93894__INCLUDED_)
