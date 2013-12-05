// Transformer.h: interface for the Transformer class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_TRANSFORMER_H__3D490720_74FE_40BE_AB60_FB26CCA6A547__INCLUDED_)
#define AFX_TRANSFORMER_H__3D490720_74FE_40BE_AB60_FB26CCA6A547__INCLUDED_

#include "Terminal.h"	// Added by ClassView
#include "Core.h"	// Added by ClassView
#include "Winding.h"	// Added by ClassView
#include "Layer.h"	// Added by ClassView



class CAndersenFolder; // required forward declaration

class Transformer  
{
public:
	double GetTerminalVoltage(int wTerm);
	double m_puImpedance;
	Transformer* GetPrev();
	Transformer* GetNext();
	void SetPrev(Transformer* wTxfo);
	void SetNext(Transformer* wTxfo);
	double m_OffElongValue;
	int m_OffsetElongation;
	Layer* GetLayerFromSegmentNumber(int wSegNum);
	Transformer(Transformer& oldTxfo);
	bool HasRegWinding();
	bool m_AndersenOutputIsValid;
	int VerifyTransformer();
	double m_MaxCombinedStress;
	double m_MaxAxialStress;
	double m_MinRadSupports;
	double m_MaxCompStress;
	double m_MaxHoopStress;
	double m_BottomEndThrust;
	double m_TopEndThrust;
	void ClearPointers();
	void GetOutputData(CString* wFileName = NULL);
	CAndersenFolder* m_DefaultFolder;
	bool m_IsValid;
	double m_Impedance[3];
	double* GetTransformerImpedance(bool wUpdate = false);
	double m_SecondFanStage;
	double m_FirstFanStage;
	int m_TempRise;
	double AmpTurns(int wTerm = 0);
	void FixTerminalVoltages();
	double GetActiveTurns(int wTerm);
	int m_VperNTerminal;
	double m_VoltsPerTurn;
	double CalcVoltsPerTurn();
	Winding* NumberToPointer(int wWdg);
	void RemoveWinding(Winding* wWdg, bool wDelete = false);
	int NumWindings();
	double GetEffectiveAmps(int wTerm);
	int CountLayers();
	double m_LowerZ;
	CString m_Description;
	bool TerminalsHaveWindings();
	Winding* GetWdgHead();
	void InitializeTxfo();
	Terminal* GetTermHead();
	void AddWinding(Winding* wWdg);
	void AddTerminal(Terminal* wTerm);
	CCore m_Core;
	int m_NumTerminals;
	double m_PeakFactor;
	double m_SystemGVA;
	double m_InnerClearance;
	int m_NumWoundLimbs;
	int m_Frequency;
	int m_NumPhases;
	Transformer();
	virtual ~Transformer();

private:
	Transformer* m_Prev;
	Transformer* m_Next;
	Layer* m_LayerHead;
	Winding* m_WdgHead;
	Terminal* m_TermHead;


};

#endif // !defined(AFX_TRANSFORMER_H__3D490720_74FE_40BE_AB60_FB26CCA6A547__INCLUDED_)
