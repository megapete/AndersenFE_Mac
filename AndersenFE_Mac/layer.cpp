// Layer.cpp: implementation of the Layer class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "andersenfe.h"
#include "layer.h"



//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

Layer::Layer()
{
	m_NumSpacerBlocks = 0;
	m_Next = NULL;
	m_SegmentHead = NULL;
	m_SegmentTail = NULL;
	m_NumberParGroups = 1;
	m_InnerRadius = 0.0;
}

Layer::~Layer()
{
	DeleteSegmentList();
}


void Layer::SetNext(Layer *wLayer)
{
	m_Next = wLayer;
}

Layer* Layer::GetNext()
{
	return m_Next;
}


int Layer::CountSegments()
{
	int result = 0;

	Segment* nextSegment = m_SegmentHead;

	while (nextSegment != NULL)
	{
		result++;

		nextSegment = nextSegment->m_Next;
	}

	return result;
}

void Layer::DeleteSegmentList(Segment *wSegment)
{
	Segment* nextSeg = wSegment;
	Segment* lastSeg;

	if (nextSeg == NULL)
		nextSeg = m_SegmentHead;

	while (nextSeg != NULL)
	{
		lastSeg = nextSeg;
		nextSeg = nextSeg->m_Next;
		delete lastSeg;
	}

}

Layer::Layer(Layer *wLayer)
{
	m_CurrentDirection = wLayer->m_CurrentDirection;
	m_InnerRadius = wLayer->m_InnerRadius;
	m_Material = wLayer->m_Material;
	m_Number = wLayer->m_Number;
	m_NumberParGroups = wLayer->m_NumberParGroups;
	m_NumSpacerBlocks = wLayer->m_NumSpacerBlocks;
	m_RadialWidth = wLayer->m_RadialWidth;
	m_SpacerBlockWidth = wLayer->m_SpacerBlockWidth;
	m_Terminal = wLayer->m_Terminal;
	m_SegmentTail = NULL; // unused anyway

	Segment* nextOldSegment = wLayer->m_SegmentHead;
	Segment* lastNewSegment = NULL;
	m_SegmentHead = NULL;

	while (nextOldSegment != NULL)
	{
		if (m_SegmentHead == NULL)
		{
			m_SegmentHead = new Segment(*nextOldSegment);
			lastNewSegment = m_SegmentHead;
		}
		else
		{
			lastNewSegment->m_Next = new Segment(*nextOldSegment);
			lastNewSegment = lastNewSegment->m_Next;
		}

		nextOldSegment = nextOldSegment->m_Next;
	}
    
    if (lastNewSegment != NULL)
    {
        lastNewSegment->m_Next = NULL;
    }

}

double Layer::CriticalTiltingStress()
{

	// This function and its variable names are described in
	// "Transformer Design Principles", pp.200-201
	double result;
	double E = 16.0E6;
	double R = m_InnerRadius + m_RadialWidth;
	double h = m_SegmentHead->m_StrandA;
	double t = m_SegmentHead->m_StrandR;
	double C = 9.0E6; // per the same book, and McNutt
	double Nks = (double)m_NumSpacerBlocks;
	double Wks = m_SpacerBlockWidth;
	double Rc;
	double PI = (double)3.141592654;

	if (t < 0.055)
	{
		Rc = (double)(t / 2.0);
	}
	else if (t < 0.071)
	{
		Rc = (double)(0.020);
	}
	else if (h < 0.190)
	{
		Rc = (double)(0.020);
	}
	else
	{
		Rc = (double)(0.031);
	}

	result = (double)(E/12*pow(h/R, 2.0)); // formula 6.26

	double spacerDigging = (double)((C/6.0)*(Nks*Wks/(2*PI*R))*pow((t-2*Rc)/h, 2.0)); // formula 6.29
	
	// set "spacer digging factor" to a maximum of 3000 psi
	if (spacerDigging > 3000.0)
		spacerDigging = 3000.0;

	result += spacerDigging;

	return result;
}

double Layer::CalculateRadialSurfaceArea(int wCondType)
{

	double result = 0.0;
	double PI = (double)3.141592654;
	double Dm = (double)(m_InnerRadius * 2 + m_RadialWidth);

	result = PI*Dm*m_SegmentHead->m_NumStrandsPerLayer*m_SegmentHead->m_StrandR;
	
	return result;
}

void Layer::SetLayerAsParallel(void)
{
	m_NumberParGroups = 2;
}
