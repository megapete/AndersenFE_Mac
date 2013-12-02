#if !defined(AFX_ADDTERMDLOG_H__342A22B5_8F3E_43B9_887E_E57EE74427F0__INCLUDED_)
#define AFX_ADDTERMDLOG_H__342A22B5_8F3E_43B9_887E_E57EE74427F0__INCLUDED_

#include "Terminal.h"	// Added by ClassView

//

/////////////////////////////////////////////////////////////////////////////
// AddTermDlog dialog

class AddTermDlog
{
// Construction
public:
	AddTermDlog(bool isModify, Terminal* wTerm);
	AddTermDlog();   // standard constructor

	int		m_Connection;
	double	m_MVA;
	double	m_Voltage;
	CString	m_Name;
	CString	m_BoxTitle;
    
    int DoModal();
	
private:
	bool m_IsModify;
};



#endif // !defined(AFX_ADDTERMDLOG_H__342A22B5_8F3E_43B9_887E_E57EE74427F0__INCLUDED_)
