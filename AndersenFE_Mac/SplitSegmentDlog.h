#if !defined(AFX_SPLITSEGMENTDLOG_H__90595215_F6AC_47BE_902B_E7E9DB32EC5D__INCLUDED_)
#define AFX_SPLITSEGMENTDLOG_H__90595215_F6AC_47BE_902B_E7E9DB32EC5D__INCLUDED_


//

/////////////////////////////////////////////////////////////////////////////
// CSplitSegmentDlog dialog

class CSplitSegmentDlog
{
// Construction
public:
	CSplitSegmentDlog();   // standard constructor


	double	m_BetweenSegs;
	int		m_NumSegs;
	
    int DoModal();


};



#endif // !defined(AFX_SPLITSEGMENTDLOG_H__90595215_F6AC_47BE_902B_E7E9DB32EC5D__INCLUDED_)
