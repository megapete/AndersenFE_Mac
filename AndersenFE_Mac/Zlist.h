// Zlist.h: interface for the CZlist class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_ZLIST_H__BFC93C26_8D30_4581_98D4_AEFE608321C9__INCLUDED_)
#define AFX_ZLIST_H__BFC93C26_8D30_4581_98D4_AEFE608321C9__INCLUDED_

#include "Segment.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class CZlist  
{
public:
	double GetTotalZ();
	CZlist(CZlist* wList);
	int m_TapSection;
	void OffsetZList(double wOffset);
	CZlist* GetTail();
	void AppendZList(CZlist* wHead);
	CZlist* CopyZList(CZlist* wHead);
	double GetTotalTurns();
	double GetMaxZ();
	double m_Turns;
	CZlist(double zMin, double zMax, double turns, int tapSection = NOT_TAP_SEGMENT);
	CZlist* m_Next;
	double m_Zmax;
	double m_Zmin;
	CZlist();
	virtual ~CZlist();

};

#endif // !defined(AFX_ZLIST_H__BFC93C26_8D30_4581_98D4_AEFE608321C9__INCLUDED_)
