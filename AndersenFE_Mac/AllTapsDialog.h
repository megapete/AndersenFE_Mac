#if !defined(AFX_ALLTAPSDIALOG_H__69B8FE6C_5025_4058_8EFD_12B320E1EC93__INCLUDED_)
#define AFX_ALLTAPSDIALOG_H__69B8FE6C_5025_4058_8EFD_12B320E1EC93__INCLUDED_



/////////////////////////////////////////////////////////////////////////////
// CAllTapsDialog dialog

class CAllTapsDialog
{
// Construction
public:
	CAllTapsDialog();   // standard constructor

// Dialog Data
	
	BOOL	m_OffLoad;
	BOOL	m_OnLoad;
	int		m_GapLocation;
	CString	m_Description;
	
    int DoModal();

};



#endif // !defined(AFX_ALLTAPSDIALOG_H__69B8FE6C_5025_4058_8EFD_12B320E1EC93__INCLUDED_)
