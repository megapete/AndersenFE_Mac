#if !defined(AFX_RUNNINGMESSAGEDLOG_H__FC2F98BB_6E25_4B75_8B70_5D90C8383702__INCLUDED_)
#define AFX_RUNNINGMESSAGEDLOG_H__FC2F98BB_6E25_4B75_8B70_5D90C8383702__INCLUDED_



/////////////////////////////////////////////////////////////////////////////
// CRunningMessageDlog dialog

class CRunningMessageDlog
{
// Construction
public:
	
	CRunningMessageDlog();   // standard constructor


	CString	m_ShowText;
	
    int DoModal();


};



#endif // !defined(AFX_RUNNINGMESSAGEDLOG_H__FC2F98BB_6E25_4B75_8B70_5D90C8383702__INCLUDED_)
