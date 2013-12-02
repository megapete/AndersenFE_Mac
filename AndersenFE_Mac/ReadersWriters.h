// ReadersWriters.h: interface for the CReadersWriters class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_READERSWRITERS_H__C22884AE_D2E2_4C50_9815_DC612EE34AD0__INCLUDED_)
#define AFX_READERSWRITERS_H__C22884AE_D2E2_4C50_9815_DC612EE34AD0__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <afxmt.h>


class CReadersWriters  
{
public:
	CString m_Name;
	int m_NumWriters;
	void WriteLock() {Lock(false);}
	void Unlock();
	void Lock(bool isReader = true);
	CReadersWriters();
	virtual ~CReadersWriters();

protected:
	CSemaphore* m_ReaderLock;
	CSemaphore* m_RWLock;
	int m_NumReaders;
};

#endif // !defined(AFX_READERSWRITERS_H__C22884AE_D2E2_4C50_9815_DC612EE34AD0__INCLUDED_)
