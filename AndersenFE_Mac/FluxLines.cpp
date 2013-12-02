// FluxLines.cpp: implementation of the CFluxLines class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "andersenfe.h"
#include "FluxLines.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CFluxLines::CFluxLines()
{
	m_Next = NULL;
	m_Prev = NULL;
	m_NextHead = NULL;
	m_X = 0.0;
	m_Y = 0.0;
}

CFluxLines::~CFluxLines()
{
	delete m_Next;
}

CFluxLines* CFluxLines::Next()
{
	return m_Next;
}

CFluxLines* CFluxLines::Prev()
{
	return m_Prev;
}


double CFluxLines::X()
{
	return m_X;
}

double CFluxLines::Y()
{
	return m_Y;

}

void CFluxLines::SetNext(CFluxLines *wPoint)
{
	m_Next = wPoint;

	if (wPoint != NULL)
		wPoint->SetPrev(this);

}

void CFluxLines::SetPrev(CFluxLines *wPoint)
{
	m_Prev = wPoint;
}

void CFluxLines::SetPoint(double x, double y)
{
	m_X = x;
	m_Y = y;
}

CFluxLines::CFluxLines(double x, double y, CFluxLines *wPrev)
{
	m_Next = NULL;
	m_Prev = wPrev;
	m_X = x;
	m_Y = y;
}



void CFluxLines::Remove(bool removeAll)
{
	if (removeAll)
	{
		m_Prev->SetNext(NULL);
	}
	else
	{
		m_Prev->SetNext(m_Next);
	}
}



void CFluxLines::Insert(CFluxLines *wPrev, bool atTail)
{
	ASSERT(wPrev != NULL);

	if (atTail == true)
	{
		CFluxLines* nNode = wPrev;
		while (nNode->Next() != NULL)
		{
			nNode = nNode->Next();
		}

		nNode->SetNext(this);
		m_Next = NULL;
	}
	else
	{
		SetNext(wPrev->Next());
		wPrev->SetNext(this);
	}
}

void CFluxLines::AddHead(CFluxLines *wHead)
{
	m_NextHead = wHead;
}

CFluxLines* CFluxLines::NextHead()
{
	return m_NextHead;
}

void CFluxLines::SetX(double x)
{
	m_X = x;
}

void CFluxLines::SetY(double y)
{
	m_Y = y;
}
