// Layer.h: interface for the Layer class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_LAYER_H__AEE4819C_C0F8_4575_875A_BFB8C3947668__INCLUDED_)
#define AFX_LAYER_H__AEE4819C_C0F8_4575_875A_BFB8C3947668__INCLUDED_

#include "Segment.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// Andersen Material Constants
#define COPPER 1
#define ALUMINUM 2

// Conductor Types
#define SINGLE_COND 0
#define DOUBLE_COND 1
#define CTC_COND	2


class Layer  
{
public:
	void SetLayerAsParallel(void);
	double CalculateRadialSurfaceArea(int wCondType = SINGLE_COND);
	double CriticalTiltingStress();
	Layer(Layer* wLayer);
	void DeleteSegmentList(Segment* wSegment = NULL);
	int CountSegments();
	Layer* GetNext();
	void SetNext(Layer* wLayer);
	Segment* m_SegmentTail;
	Segment* m_SegmentHead;
	double m_SpacerBlockWidth;
	int m_NumSpacerBlocks;
	int m_Material;
	int m_CurrentDirection;
	int m_NumberParGroups;
	int m_Terminal;
	double m_RadialWidth;
	double m_InnerRadius;
	int m_Number;
	Layer();
	virtual ~Layer();

private:
	Layer* m_Next;
	
};

#endif // !defined(AFX_LAYER_H__AEE4819C_C0F8_4575_875A_BFB8C3947668__INCLUDED_)
