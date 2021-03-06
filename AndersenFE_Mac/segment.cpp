// Segment.cpp: implementation of the Segment class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "andersenfe.h"
#include "segment.h"



//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

Segment::Segment()
{
	m_Next = NULL;
}

Segment::~Segment()
{

}

Segment* Segment::SplitSegment(int numSegs, double wGap)
{
	Segment* oldNext = m_Next;
	

	double zPerSegment = ((m_MaxZ - m_MinZ) - (numSegs - 1) * wGap) / numSegs;
	
	m_NumTurnsTotal = m_NumTurnsTotal / numSegs;
	m_NumTurnsActive = m_NumTurnsTotal;
	double oldMaxZ = m_MaxZ;

	m_MaxZ = m_MinZ + zPerSegment;

	
	int i;
	Segment* nSegment;
	Segment* lSegment = this;
	double lastZ = m_MaxZ;

	for (i=2; i<=numSegs; i++)
	{
		nSegment = new Segment;
		lSegment->m_Next = nSegment;
		nSegment->m_MinZ = lastZ + wGap;
		if (i == numSegs)
			nSegment->m_MaxZ = oldMaxZ;
		else
			nSegment->m_MaxZ = nSegment->m_MinZ + zPerSegment;
		nSegment->m_Number = m_Number;
		nSegment->m_NumStrandsPerLayer = m_NumStrandsPerLayer;
		nSegment->m_NumStrandsPerTurn = m_NumStrandsPerTurn;
		nSegment->m_NumTurnsActive = m_NumTurnsActive;
		nSegment->m_NumTurnsTotal = m_NumTurnsTotal;
		nSegment->m_StrandA = m_StrandA;
		nSegment->m_StrandR = m_StrandR;

		lSegment = nSegment;
		lastZ = nSegment->m_MaxZ;

	}

	lSegment->m_Next = oldNext;

	return oldNext;
}

void Segment::AdjustGapToNextSegment(double wGap, int type)
// types are: 0=keep center of old gap, 1=push next gap up, -1=push this gap down
{
	if (m_Next == NULL)
		return;

	double oldGap = m_Next->m_MinZ - m_MaxZ;
	// double diffThis, diffNext;

	if (oldGap == wGap)
		return;

    /* This code doesn't do anything ???
	if (type == 0)
	{
		diffThis = -(wGap - oldGap) / 2;
		diffNext = -diffThis;
	}
	else if (type == 1)
	{
		diffThis = 0;
		diffNext = wGap - oldGap;
	}
	else
	{
		diffThis = -(wGap - oldGap);
		diffNext = 0;
	}
     */
}

bool Segment::IsActive()
{
	return (m_NumTurnsActive != 0);
}

int Segment::GetSegmentPosition(Segment *wHead)
{
	if (wHead == this)
		return 1;
	else
		return (1 + GetSegmentPosition(wHead->m_Next));
}

Segment* Segment::SplitSegmentCustom(double percentNewBottom)
// splits this segment into two, the lower of the new sctions having a height (and number of turns) equal to percentNewBottom of the existing (old) segment
{
	if ((percentNewBottom >= 100.0) || (percentNewBottom <= 0.0))
		return m_Next;
    
    double wTurns = m_NumTurnsTotal * (100.0 - percentNewBottom) / 100.0;

	m_NumTurnsTotal = m_NumTurnsTotal - wTurns;
	if (m_NumTurnsActive > 0)
		m_NumTurnsActive = m_NumTurnsTotal;

	double oldMax = m_MaxZ;
    double oldSegmentZ = m_MaxZ - m_MinZ;
	m_MaxZ = m_MinZ + oldSegmentZ * percentNewBottom / 100.0;

	Segment* nSegment = new Segment;
	
	nSegment->m_Next = this->m_Next;
	this->m_Next = nSegment;
	nSegment->m_MinZ = m_MaxZ;
	nSegment->m_MaxZ = oldMax;
	nSegment->m_NumTurnsTotal = wTurns;
	nSegment->m_Number = m_Number;
	nSegment->m_NumStrandsPerLayer = m_NumStrandsPerLayer;
	nSegment->m_NumStrandsPerTurn = m_NumStrandsPerTurn;
	if (m_NumTurnsActive > 0)
		nSegment->m_NumTurnsActive = nSegment->m_NumTurnsTotal;
	else
		nSegment->m_NumTurnsActive = 0;

	nSegment->m_StrandA = m_StrandA;
	nSegment->m_StrandR = m_StrandR;

	return nSegment->m_Next;
}
