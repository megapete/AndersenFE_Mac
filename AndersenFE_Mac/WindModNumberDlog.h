#if !defined(AFX_WINDMODNUMBERDLOG_H__372074A6_FEA8_4379_9E5D_DAE9A97B277A__INCLUDED_)
#define AFX_WINDMODNUMBERDLOG_H__372074A6_FEA8_4379_9E5D_DAE9A97B277A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// WindModNumberDlog.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// WindModNumberDlog dialog

class WindModNumberDlog
{
// Construction
public:
	int m_NumWindings;
	// BOOL OnInitDialog();
	WindModNumberDlog();   // standard constructor

    int DoModal();

};



#endif // !defined(AFX_WINDMODNUMBERDLOG_H__372074A6_FEA8_4379_9E5D_DAE9A97B277A__INCLUDED_)
