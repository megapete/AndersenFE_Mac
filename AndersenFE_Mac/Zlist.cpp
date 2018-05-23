// Zlist.cpp: implementation of the CZlist class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "andersenfe.h"
#include "Zlist.h"



//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CZlist::CZlist()
{
	m_Zmin = 0;
	m_Zmax = 0;
	m_Turns = 0;
	m_Next = NULL;
}

CZlist::~CZlist()
{
	if (m_Next != NULL)
		delete m_Next;
}

CZlist::CZlist(double zMin, double zMax, double turns, int tapSection)
{
	m_Zmin = zMin;
	m_Zmax = zMax;
	m_Turns = turns;
	m_TapSection = tapSection;
	m_Next = NULL;
}

double CZlist::GetTotalTurns()
{
 	CZlist* nextPtr = this;
 	double result = 0;
 
 	while (nextPtr != NULL)
	{
 		result += nextPtr->m_Turns;
		nextPtr = nextPtr->m_Next;
	}
 
	return result;
}

double CZlist::GetMaxZ()
{
	CZlist* nextPtr = this;
 	double result = 0;

	while (nextPtr != NULL)
	{
 		if (nextPtr->m_Next == NULL) // last pointer
			result = nextPtr->m_Zmax;

		nextPtr = nextPtr->m_Next;
	}

	return result;
}

CZlist* CZlist::CopyZList(CZlist *wHead)
{
	CZlist* nextPtr = wHead;
	CZlist* lastPtr = NULL;
	CZlist* result = NULL;

	while (nextPtr != NULL)
	{
		if (lastPtr == NULL)
		{
			result = new CZlist(nextPtr->m_Zmin, nextPtr->m_Zmax, nextPtr->m_Turns);
			lastPtr = result;
		}
		else
		{
			lastPtr->m_Next = new CZlist(nextPtr->m_Zmin, nextPtr->m_Zmax, nextPtr->m_Turns);
		}

		nextPtr = nextPtr->m_Next;
	}

	return result;
}

void CZlist::AppendZList(CZlist* wHead)
{
	m_Next = wHead;
}

CZlist* CZlist::GetTail()
{
	CZlist* result = this;

	if (result != NULL)
		while (result->m_Next != NULL)
			result = result->m_Next;

	return result;
}

void CZlist::OffsetZList(double wOffset)
{
	CZlist* nextPtr = this;

	while (nextPtr != NULL)
	{
		nextPtr->m_Zmin += wOffset;
		nextPtr->m_Zmax += wOffset;

		nextPtr = nextPtr->m_Next;
	}
}

CZlist::CZlist(CZlist *wList)
{
	m_TapSection = wList->m_TapSection;
	m_Turns = wList->m_Turns;
	m_Zmax = wList->m_Zmax;
	m_Zmin = wList->m_Zmin;
	m_Next = NULL;

	if (wList->m_Next != NULL)
	{
		m_Next = new CZlist(wList->m_Next);
	}

}

double CZlist::GetTotalZ()
{
	double result = 0.0;

	result = GetMaxZ() - m_Zmin;

	return result;
}
