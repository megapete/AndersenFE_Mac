// Winding.h: interface for the Winding class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_WINDING_H__13E8C2C3_733A_43A4_810B_0564BC73D54B__INCLUDED_)
#define AFX_WINDING_H__13E8C2C3_733A_43A4_810B_0564BC73D54B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Layer.h"
#include "Duct.h"
#include <math.h>
#include <FLOAT.H>
// #include <afxtempl.h>
#include "Zlist.h"	// Added by ClassView


// Megatran winding types

#define DISKTYPE 0
#define LAYERTYPE 1
#define SHEETTYPE 2
#define SECTION_LAYERTYPE 4
#define SECTION_DISKTYPE 3
#define SECTION_SHEETTYPE 5
#define MULTIPLE_DISKTYPE 6
#define MULTIPLE_LAYERTYPE 7
#define MULTIPLE_SHEETTYPE 8


// Tapping locations

#define NO_TAPS -1
#define CENTER_TAPS 0
#define BOTTOM_TAPS 1
#define TOP_TAPS 2
#define DISTRIBUTED_TAPS 3




class Winding : public Layer  
{
public:
	int CountTapsOnLayer(double startTurn, double finTurn, double loTapTurn, double hiTapTurn, double turnsPerTap);
	double GetLowTapTurn(double totalTapTurns);
	bool IsLayerWdgWithTaps();
	int GetTapLayer();
	double m_BetweenCables;
	double GetOverallAxialConductorDimn();
	int m_NumLoops;
	bool m_IsMultiStart;
	void ReduceRegWdgOneStep(int currPos, bool isDouble = true, bool buckGapInside = true);
	int CountRegWdgTapPositions();
	double GetActiveTurns();
	void SetCurrentDirection(int wDir);
	void SetMaximumEffectiveTurns(Winding* wdgHead);
	Winding(Winding* oldWdg);
	void OffsetX(double wOffset, bool otherWdgs);
	double GetAxialCenter();
	Segment* GetMateSegment(Layer*wLayer, Segment*wSegment);
	double GetAxialHeight();
	bool m_IsDoubleStack;
	double m_AxialDVGap2;
	double m_AxialDVGap1;
	double m_AxialCenterPack;
	int m_NumRadialSupports;
	void SplitWdgAxially(int numSegs, double wGap=0);
	void DefineRegulatingWdg(int wNumLoops, double wAxialGap, bool wIsDouble, bool wIsMultiStart);
	void OffsetZ(double wOffset);
	bool m_IsRegWdg;
	double GetOuterDiameter();
	void ReverseCurrent();
	CZlist* SetTapSection(double copperHt, double zOffset = 0);
	double m_ReentrantGap;
	int m_TapLocation;
	int m_NumTapSteps;
	double m_HiTap;
	double m_LoTap;
	double m_ActiveTurns;
	CZlist* SetDefaultZlist();
	CZlist* m_Zlist;
	Layer* CompileLayerList();
	void DeleteLayerList(Layer* wHead = NULL);
	double m_RadialDuctDimn;
	int m_NumRadialDucts;
	int m_NumLayers;
	int m_RadialTurns;
	double m_RadialTurnDimn;
	void CalculateRadialTurnDimn();
	Layer* m_LayerHead;
	double m_CondCover;
	double m_TotalTurns;
	double m_BetweenDisks;
	int m_NumAxialSections;
	double m_RadialOverBuild;
	int m_NumDisks;
	double m_StrandDimnRadial;
	double m_StrandDimnAxial;
	int m_CondNumStrands;
	int m_CondNumAxial;
	int m_CondNumRadial;
	int m_CondType;
	void SetNext(Winding* wWdg);
	Winding* GetNext();
	double m_ElectricalHeight;
	CString m_Name;
	double m_BetweenLayers;
	double m_BetweenSections;
	int m_Type;
	Winding();
	virtual ~Winding();

private:
	Winding* m_Next;
};

#endif // !defined(AFX_WINDING_H__13E8C2C3_733A_43A4_810B_0564BC73D54B__INCLUDED_)
