#if !defined(AFX_REGWDGDLOG_H__77C190CA_9026_4D09_8031_1342E000F40A__INCLUDED_)
#define AFX_REGWDGDLOG_H__77C190CA_9026_4D09_8031_1342E000F40A__INCLUDED_



/////////////////////////////////////////////////////////////////////////////
// CRegWdgDlog dialog

class CRegWdgDlog
{
// Construction
public:
	CRegWdgDlog();   // standard constructor


	double	m_CtlEditAxialGap;
	double	m_CtlAxialGapText;
	BOOL	m_IsDoubleAxial;
	double	m_AxialGap;
	int		m_NumLoops;
	BOOL	m_IsMultiStart;
	
    int DoModal();


};



#endif // !defined(AFX_REGWDGDLOG_H__77C190CA_9026_4D09_8031_1342E000F40A__INCLUDED_)
