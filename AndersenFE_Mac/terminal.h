// Terminal.h: interface for the Terminal class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_TERMINAL_H__3407169D_DF16_45D8_9D1F_ED1965B069AF__INCLUDED_)
#define AFX_TERMINAL_H__3407169D_DF16_45D8_9D1F_ED1965B069AF__INCLUDED_

#include "stdafx.h"
#include <string>

// Andersen connection constants

#define WYE 1
#define SINGLE 0
#define DELTA 2
#define AUTOTXFO 3
#define ZIGZAGNEUTRAL 5
#define ZIGZAGLINE 6
#define POLYGONNEUTRAL 7
#define POLYGONLINE 8
#define EXTDELTANEUTRAL 9
#define EXTDELTALINE 10

#define UNDEFINED_CONNECTION -1

class Terminal  
{
public:
	void SetEddyPercent(int wTerm, double wEddy);
	double m_EddyPercent;
	void GetConnectionText(CString& wStr);
	void GetKVText(CString &wStr);
	void GetMVAText(CString& wStr);
	void SetNext(Terminal* wNext);
	Terminal* GetNext();
	Terminal(Terminal* wTerm);
    CString m_Name;
	double m_KV;
	double m_MVA;
	int m_Connection;
	int m_Number;
	Terminal();
	virtual ~Terminal();

private:
	Terminal* m_Next;
};

#endif // !defined(AFX_TERMINAL_H__3407169D_DF16_45D8_9D1F_ED1965B069AF__INCLUDED_)
