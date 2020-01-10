// Segment.h: interface for the Segment class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_SEGMENT_H__1CF56917_6322_41CD_9ABC_B6302F8E68C8__INCLUDED_)
#define AFX_SEGMENT_H__1CF56917_6322_41CD_9ABC_B6302F8E68C8__INCLUDED_

#include <math.h>

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// values for m_IsTappingSegment
#define NOT_TAP_SEGMENT		0
#define POS_TAP_SEGMENT		1
#define NEG_TAP_SEGMENT		-1

class Segment  
{
public:
	Segment* SplitSegmentCustom(double percentNewBottom);
	int GetSegmentPosition(Segment* wHead);
	double m_MaxAccumAxiallyLbs;
	bool IsActive();
	void AdjustGapToNextSegment(double wGap, int type = 0);
	Segment* SplitSegment(int numSegs, double wGap = 0);
	int m_IsTappingSegment;
	int m_Number;
	double m_StrandA;
	double m_StrandR;
	int m_NumStrandsPerLayer;
	int m_NumStrandsPerTurn;
	double m_NumTurnsActive;
	double m_NumTurnsTotal;
	double m_MaxZ;
	double m_MinZ;
	Segment();
	virtual ~Segment();
	Segment* m_Next;

private:
};

#endif // !defined(AFX_SEGMENT_H__1CF56917_6322_41CD_9ABC_B6302F8E68C8__INCLUDED_)
