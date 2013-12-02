// AndersenFolder.h: interface for the CAndersenFolder class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ANDERSENFOLDER_H__14391C2E_5DC5_4427_8579_F21A2ACEA197__INCLUDED_)
#define AFX_ANDERSENFOLDER_H__14391C2E_5DC5_4427_8579_F21A2ACEA197__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// #include "afxmt.h"
#include "Transformer.h"	// Added by ClassView

class CAndersenFolder  
{
public:
	bool SaveInp1File(Transformer* wTxfo);
	bool AndersenFolderNameIsValid(CString* wString = NULL);
	void ReleaseAndersenFolderName();
	void UseAndersenFolderName();
	void WriteAndersenFolderName(CString *wString);
	void ReadAndersenFolderName(CString* wString);
	CAndersenFolder();
	virtual ~CAndersenFolder();

private:
	bool VerifyPath(CString* wString = NULL);
	int m_ReaderCount;
	// CCriticalSection* m_WriteControl;
	// CCriticalSection* m_ReadControl;
	bool m_isValid;
	CString m_pathName;
};

#endif // !defined(AFX_ANDERSENFOLDER_H__14391C2E_5DC5_4427_8579_F21A2ACEA197__INCLUDED_)
