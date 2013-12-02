// Terminal.cpp: implementation of the Terminal class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "AndersenFE.h"
#include "Terminal.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

Terminal::Terminal()
{
	m_EddyPercent = 0.0;
	m_Next = NULL;
}

Terminal::~Terminal()
{

}

Terminal::Terminal(Terminal *wTerm) // copy constructor
{
	m_Connection = wTerm->m_Connection;
	m_KV = wTerm->m_KV;
	m_MVA = wTerm->m_MVA;
	m_Name = wTerm->m_Name;
	m_Number = wTerm->m_Number;
	m_EddyPercent = 0.0;
	m_Next = NULL; // link is NOT copied
}

Terminal* Terminal::GetNext()
{
	return m_Next;
}

void Terminal::SetNext(Terminal *wNext)
{
	m_Next = wNext;
}

void Terminal::GetMVAText(CString &wStr)
{
    wStr = string_format("%.3f",m_MVA);
	// wStr.Format("%.3f",m_MVA);
}

void Terminal::GetKVText(CString &wStr)
{
	// wStr.Format("%.3f",m_KV);
    wStr = string_format("%.3f",m_KV);
}

void Terminal::GetConnectionText(CString &wStr)
{
	switch (m_Connection) {
	case SINGLE:
		wStr = "Single Phase";
		break;
	case WYE:
		wStr = "Wye";
		break;
	case DELTA:
		wStr = "Delta";
		break;
	case AUTOTXFO:
		wStr = "Auto";
		break;
	case ZIGZAGNEUTRAL:
		wStr = "ZigZag (N)";
		break;
	case ZIGZAGLINE:
		wStr = "ZigZag (L)";
		break;
	default:
		wStr = "Undefined";
	}
}

void Terminal::SetEddyPercent(int wTerm, double wEddy)
{
	// 'this' points to the head of a list of terminals

	Terminal* nextTerm = this;

	while (nextTerm != NULL)
	{
		if (nextTerm->m_Number == wTerm)
		{
			nextTerm->m_EddyPercent = wEddy;
			break;
		}
		
		nextTerm = nextTerm->GetNext();
	}
}
