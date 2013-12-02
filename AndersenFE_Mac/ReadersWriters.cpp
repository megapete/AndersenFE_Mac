// ReadersWriters.cpp: implementation of the CReadersWriters class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "andersenfe.h"
#include "ReadersWriters.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CReadersWriters::CReadersWriters()
{
	m_RWLock = new CSemaphore;
	m_ReaderLock = new CSemaphore;
	m_NumReaders = 0;
	m_NumWriters = 0;
}

CReadersWriters::~CReadersWriters()
{
	delete m_RWLock;
	delete m_ReaderLock;
}

void CReadersWriters::Lock(bool isReader)
{
	if (isReader)
	{
		m_ReaderLock->Lock();

			if (m_NumReaders == 0)
			{
//				CWinThread* wThread = AfxGetThread();
//				long tId = (long)wThread->m_nThreadID;
//				TRACE("About to ReadLock: %s from %ld\n", m_Name, tId);
				BOOL tst = m_RWLock->Lock();
//				if (!tst)
//					int k = 0;

//				TRACE("ReadLock succeeded: %s\n", m_Name);
			}

			m_NumReaders++;

		m_ReaderLock->Unlock();
	}
	else
	{
//		CWinThread* wThread = AfxGetThread();
//		long tId = (long)wThread->m_nThreadID;
//		TRACE("About to WriteLock: %s from %ld\n", m_Name, tId);
		BOOL tst = m_RWLock->Lock();
//		if (!tst)
//			int k = 0;
		m_NumWriters++;
//		TRACE("WriteLock succeeded: %s, numwriters=%d\n", m_Name, m_NumWriters);
	}
}

void CReadersWriters::Unlock()
{
	
	if (m_NumReaders > 0)
	{
		m_ReaderLock->Lock();

			m_NumReaders--;
		
			if (m_NumReaders == 0)
			{
//				CWinThread* wThread = AfxGetThread();
//				long tId = wThread->m_nThreadID;
//				TRACE("About to Reader UnLock: %s from %ld\n", m_Name, tId);
				m_RWLock->Unlock();
//				TRACE("Reader UnLock Succeeded: %s\n", m_Name);
			}

		m_ReaderLock->Unlock();
	}
	else
	{
		if (m_NumWriters > 0)
		{
			m_NumWriters--;
//			CWinThread* wThread = AfxGetThread();
//			long tId = wThread->m_nThreadID;
//			TRACE("About to Writer UnLock: %s from %ld\n", m_Name, tId);
			m_RWLock->Unlock();
//			TRACE("Writer UnLock Succeeded: %s\n", m_Name);
		}
	}

}

