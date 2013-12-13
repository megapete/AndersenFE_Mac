// Transformer.cpp: implementation of the Transformer class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "AndersenFE.h"
#include "Transformer.h"
#include "AndersenFolder.h"
#include <string>
#include "CStdioFile.h"


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

Transformer::Transformer()
{
	m_NumTerminals = 0;
	m_TermHead = NULL;
	m_WdgHead = NULL;
	m_LayerHead = NULL;
	m_VoltsPerTurn = 0.0;
	m_VperNTerminal = 0;
	m_IsValid = false;
	m_OffElongValue = 0.0;
	m_OffsetElongation = 0;
    m_CurrentCoolingStage = COOLING_STAGE_ONAN;

	InitializeTxfo();
}

Transformer::~Transformer()
{
	InitializeTxfo();
}

void Transformer::AddTerminal(Terminal *wTerm)
{
	if (m_TermHead == NULL)
	{
		m_TermHead = wTerm;
		return;
	}

	Terminal* dumPtr = m_TermHead;

	while (dumPtr->GetNext() != NULL)
		dumPtr = dumPtr->GetNext();

	dumPtr->SetNext(wTerm);

	return;

}

double Transformer::CoolingPerUnit(int wStage)
{
    if (wStage == COOLING_STAGE_ONAN)
    {
        return 1.0;
    }
    else if (wStage == COOLING_STAGE_ONAF)
    {
        return m_FirstFanStage / 100.0;
    }
    else if (wStage == COOLING_STAGE_ONAFF)
    {
        return m_SecondFanStage / 100.0;
    }
    
    return 0.0;
    
}

void Transformer::AddWinding(Winding *wWdg)
{
	// if this is the first winding, make it m_WdgHead and return
	if (m_WdgHead == NULL)
	{
		m_WdgHead = wWdg;
		return;
	}

	// Insert the winding into the correct order based on its inner radius

	Winding* beforePtr = NULL;
	Winding* currentPtr = m_WdgHead;

	while (currentPtr != NULL)
	{
		if (wWdg->m_InnerRadius < currentPtr->m_InnerRadius)
		{
			if (beforePtr == NULL) // need new head
			{
				wWdg->SetNext(m_WdgHead);
				m_WdgHead = wWdg;
			}
			else
			{
				wWdg->SetNext(currentPtr);
				beforePtr->SetNext(wWdg);
			}

			break;
		}

		beforePtr = currentPtr;
		currentPtr = currentPtr->GetNext();
	}

	// check if we exhausted the list and if so, append wWdg

	if (currentPtr == NULL)
		beforePtr->SetNext(wWdg);

}


Terminal* Transformer::GetTermHead()
{
	return m_TermHead;
}


void Transformer::InitializeTxfo()
{
	Layer* lNext;
	while (m_LayerHead != NULL)
	{
		lNext = m_LayerHead;
		m_LayerHead = m_LayerHead->GetNext();
		delete lNext;
	}

	Terminal* tNext;
	while (m_TermHead != NULL)
	{
		tNext = m_TermHead;
		m_TermHead = m_TermHead->GetNext();
		delete tNext;
	}

	Winding* wNext;
	while (m_WdgHead != NULL)
	{
		wNext = m_WdgHead;
		m_WdgHead = m_WdgHead->GetNext();
		delete wNext;
	}

	m_NumTerminals = 0;
	m_VoltsPerTurn = 0;
	m_VperNTerminal = 0;
	m_Impedance[0] = 0.0;
	m_Impedance[1] = 0.0;
	m_Impedance[2] = 0.0;
	m_TopEndThrust = 0.0;
	m_BottomEndThrust = 0.0;
	m_MaxAxialStress = 0.0;
	m_MaxCombinedStress = 0.0;
	m_MaxCompStress = 0.0;
	m_MaxHoopStress = 0.0;
	m_MinRadSupports = 0.0;
	m_IsValid = false;
	m_AndersenOutputIsValid = false;
	m_OffElongValue = 0.0;
	m_OffsetElongation = 0;
	m_puImpedance = 0.0;
    m_CurrentCoolingStage = COOLING_STAGE_ONAN;

	m_Prev = NULL;
	m_Next = NULL;

}

Winding* Transformer::GetWdgHead()
{
	return m_WdgHead;
}

bool Transformer::TerminalsHaveWindings()
{
	bool terminal[6] = {true,true,true,true,true,true};

	int i;

	for (i=0; i<6; i++)
	{
		if (i < m_NumTerminals)
			terminal[i] = false;
	}

	Winding* nextWdg = m_WdgHead;

	while (nextWdg != NULL)
	{
		terminal[nextWdg->m_Terminal - 1] = true;
		nextWdg = nextWdg->GetNext();
	}


	for (i=0; i<6; i++)
	{
		if (!terminal[i])
			return false;
	}

	return true;
}

int Transformer::CountLayers()
{
	int result = 0;
	Winding* nextWdg = m_WdgHead;
	Layer *nextLayer;

	while (nextWdg != NULL)
	{
		nextLayer = nextWdg->m_LayerHead;

		while (nextLayer != NULL)
		{
			result++;
			nextLayer = nextLayer->GetNext();
		}
		nextWdg = nextWdg->GetNext();
	}

	return result;
}



double Transformer::GetEffectiveAmps(int wTerm)
{
	int i;
	Terminal* nextTerm = m_TermHead;
	double result = 0;

	for (i=1; i<wTerm; i++)
	{
		nextTerm = nextTerm->GetNext();
	}

	double aKVA = nextTerm->m_MVA * 1000;
	double voltsPerLeg = nextTerm->m_KV;

	if (nextTerm->m_Connection != SINGLE)
	{
		aKVA /= 3;

		if (nextTerm->m_Connection != DELTA)
			voltsPerLeg /= (double)sqrt((double)3.0);
	}

	result = aKVA / voltsPerLeg;

	if ((nextTerm->m_Connection == AUTOTXFO) && (wTerm == 2))
		result -= GetEffectiveAmps(1);

	if ((nextTerm->m_Connection == ZIGZAGNEUTRAL) ||
		(nextTerm->m_Connection == ZIGZAGLINE))
	{
		result *= (double)(sqrt((double)3.0) / (double)2.0);
	}

	return result;
}

int Transformer::NumWindings()
{
	int result = 0;

	Winding* nextWdg = m_WdgHead;

	while (nextWdg != NULL)
	{
		result++;
		nextWdg = nextWdg->GetNext();
	}

	return result;
}

void Transformer::RemoveWinding(Winding *wWdg, bool wDelete)
{
	Winding* nextWdg = m_WdgHead;
	Winding* lastWdg = NULL;

	while (nextWdg != NULL)
	{
		if (nextWdg == wWdg)
		{
			if (lastWdg == NULL)
			{
				m_WdgHead = nextWdg->GetNext();
			}
			else
			{
				lastWdg->SetNext(nextWdg->GetNext());
			}

			break;
		}

		lastWdg = nextWdg;
		nextWdg = nextWdg->GetNext();
	}

	if ((wDelete) && (wWdg != NULL))
		delete wWdg;


}

Winding* Transformer::NumberToPointer(int wWdg)
{
	Winding* nextWdg = m_WdgHead;

	int count;

	for (count = 1; count < wWdg; count++)
	{
		nextWdg = nextWdg->GetNext();
	}

	return nextWdg;
}

double Transformer::CalcVoltsPerTurn()
{
	m_VoltsPerTurn = 0.0;

	if (m_VperNTerminal == 0)
		return 0;

	double result = 0;

	double numActiveTurns = GetActiveTurns(m_VperNTerminal);
	if (numActiveTurns == 0)
		return 0;

	Terminal* wTerminal = m_TermHead;

	while (wTerminal->m_Number != m_VperNTerminal)
	{
		wTerminal = wTerminal->GetNext();
	}

	double VoltsPerLeg = wTerminal->m_KV * 1000;

	switch (wTerminal->m_Connection) {
	case WYE:
	case AUTOTXFO:
		VoltsPerLeg /= (double)sqrt((double)3.0);
		break;
	case ZIGZAGLINE:
	case ZIGZAGNEUTRAL:
		VoltsPerLeg /= (double)sqrt((double)3.0);
	} // end switch


	result = (double)fabs(VoltsPerLeg / numActiveTurns);

	m_VoltsPerTurn = result;

	return result;

}

double Transformer::GetActiveTurns(int wTerm)
{
	double result = 0;

	Winding* nWinding = m_WdgHead;
	Layer* nLayer;
	Segment* nSegment;

	while (nWinding != NULL)
	{
		nLayer = nWinding->m_LayerHead;

		while (nLayer != NULL)
		{
			if (nLayer->m_Terminal == wTerm)
			{
				nSegment = nLayer->m_SegmentHead;

				while (nSegment != NULL)
				{
					result += (nLayer->m_CurrentDirection * 
						nSegment->m_NumTurnsActive / 
						nLayer->m_NumberParGroups);

					nSegment = nSegment->m_Next;
				}

				
			}

			nLayer = nLayer->GetNext();
		}

		nWinding = nWinding->GetNext();
	}

	return (double)(result);
}

void Transformer::FixTerminalVoltages()
{
	if (m_VoltsPerTurn == 0)
		return;

	Terminal* nTerm = m_TermHead;

	while (nTerm != NULL)
	{
		if (nTerm->m_Number != m_VperNTerminal)
		{
			nTerm->m_KV = (double)fabs(m_VoltsPerTurn * GetActiveTurns(nTerm->m_Number) / 1000);

			if ((nTerm->m_Connection == WYE) || (nTerm->m_Connection == AUTOTXFO) ||
				(nTerm->m_Connection == ZIGZAGNEUTRAL) || (nTerm->m_Connection == ZIGZAGLINE))
			{
				nTerm->m_KV *= (double)sqrt((double)3.0);
			}

			if ((nTerm->m_Connection == AUTOTXFO) && (nTerm->m_Number == 1))
			{
				nTerm->m_KV += GetTerminalVoltage(2);
			}

			if (nTerm->m_KV == 0.0)
			{
				nTerm->m_KV = 0.001f;
			}
		}

		nTerm = nTerm->GetNext();
	}
}

double Transformer::AmpTurns(int wTerm)
{
	double result = 0.0;

	if (wTerm != 0)
	{
		return GetEffectiveAmps(wTerm) * GetActiveTurns(wTerm);
	}

	Terminal* aTerm = m_TermHead;

	while (aTerm != NULL)
	{
		result += GetEffectiveAmps(aTerm->m_Number) * GetActiveTurns(aTerm->m_Number);   
		aTerm = aTerm->GetNext();
	} 

	if (fabs(result) < 10.0)
		result = 0.0;

	return result;
}

double* Transformer::GetTransformerImpedance(bool wUpdate)
{
	// TRACE("Entered GetTransformerImpedance() with wUpdate = %d\n", wUpdate);

	if (!wUpdate)
		return m_Impedance;

	if (m_VoltsPerTurn == 0.0)
	{
		m_Impedance[0] = 0.0;
		m_Impedance[1] = 0.0;
		m_Impedance[2] = 0.0;
	}
	else if (AmpTurns() != 0.0)
	{
		m_Impedance[0] = 0.0;
		m_Impedance[1] = 0.0;
		m_Impedance[2] = 0.0;
	}
	
	GetOutputData();

	// TRACE("Leaving GetTransformerImpedance() with m_Impedance = %.1f\n", m_Impedance);

	return m_Impedance;
}

void Transformer::GetOutputData(CString* wFileName)
{
	CString fName, nLine, wFindString, dumString;
	// CAndersenFEApp* tApp = (CAndersenFEApp*)AfxGetApp();
	
	if (wFileName == NULL)
	{
		m_DefaultFolder->ReadAndersenFolderName(&fName);
		fName += "FLD12\\OUTPUT";

		// tApp->m_UseFld12Output->Lock();
	}
	else
    {
		fName = *wFileName;
    }

	
		CStdioFile fFile(fName, CFile::modeRead);
		int wPos;

		CString wFindString1 = "MAX. ACCUM. AXIALLY,";

		Winding* nextWdg = GetWdgHead();
		Layer* nextLayer;
		Segment* nextSeg;

		while (nextWdg != NULL)
		{
			nextLayer = nextWdg->m_LayerHead;
			while (nextLayer != NULL)
			{
				nextSeg = nextLayer->m_SegmentHead;
				while (nextSeg != NULL)
				{
					while (fFile.ReadString(nLine))
					{
						if ((wPos = nLine.find(wFindString1) != std::string::npos))
						{
							nextSeg->m_MaxAccumAxiallyLbs = stod(nLine.substr(nLine.size()-12, 12));
							break;
						}
					}

					nextSeg = nextSeg->m_Next;
				}

				nextLayer = nextLayer->GetNext();
			}

			nextWdg = nextWdg->GetNext();
		}


		

		wFindString = "CRITICAL STRESSES ETC.";
		while (fFile.ReadString(nLine))
		{
			if ((wPos = nLine.find(wFindString) != std::string::npos))
			{
				// read two lines
				fFile.ReadString(nLine); // discard this line
				fFile.ReadString(nLine);
				dumString = nLine.substr(21,13);
				m_MaxHoopStress = stod(dumString);

				fFile.ReadString(nLine);
				dumString = nLine.substr(25,9);
				m_MaxCompStress = stod(dumString);

				fFile.ReadString(nLine);
				dumString = nLine.substr(28,5);
				m_MinRadSupports = stod(dumString);

				fFile.ReadString(nLine); // discard this line
				fFile.ReadString(nLine);
				dumString = nLine.substr(44,8);
				m_MaxAxialStress = stod(dumString);

				fFile.ReadString(nLine); // discard this line
				fFile.ReadString(nLine);
				dumString = nLine.substr(34,9);
				m_MaxCombinedStress = stod(dumString);

				break;
			}
		}

		// impedance MVA is next
		wFindString = "BASED ON MAGNETIC ENERGY";
		while (fFile.ReadString(nLine))
		{
			if ((wPos = nLine.find(wFindString) != std::string::npos))
			{
				dumString = nLine.substr(nLine.size()-8, 8);
				m_Impedance[1] = stod(dumString);

				break;
			}
		}

		// impedance is next
		wFindString = "IMPEDANCE";
		while (fFile.ReadString(nLine))
		{
			if ((wPos = nLine.find(wFindString) != std::string::npos))
			{
				// nLine.TrimLeft();
                size_t startPos = nLine.find_first_not_of("\t ");
                nLine = nLine.substr(startPos, std::string::npos);
                
				wPos += wFindString.size();
                
				// dumString = nLine.Right(nLine.GetLength() - wPos);
                size_t rLen = nLine.size() - wPos;
                dumString = nLine.substr(wPos, rLen);
                
				m_Impedance[0] = stod(dumString) * 100;
				m_Impedance[2] = m_Impedance[0];
				break;
			}

		}

		// impedance used for calculation of forces
		wFindString = "PU IMPEDANCE USED IN CALCULATIONS OF FORCES AND STRESSES";
		while (fFile.ReadString(nLine))
		{
			if ((wPos = nLine.find(wFindString) != std::string::npos))
			{
				// nLine.TrimLeft();
                size_t startPos = nLine.find_first_not_of("\t ");
                nLine = nLine.substr(startPos, std::string::npos);
                
				wPos += wFindString.size();
                
				// dumString = nLine.Right(nLine.GetLength() - wPos);
                size_t rLen = nLine.size() - wPos;
                dumString = nLine.substr(wPos, rLen);
				m_Impedance[2] = stod(dumString) * 100;
				break;
			}

		}

		// find the eddy loss percentages for each terminal

		int i;

		wFindString = "TERMINAL NUMBER";

		for (i=1; i<=m_NumTerminals; i++)
		{
			while (fFile.ReadString(nLine))
			{
				if ((wPos = nLine.find(wFindString) != std::string::npos))
				{
					fFile.ReadString(nLine); // discard this line
					fFile.ReadString(nLine); // discard this line
					fFile.ReadString(nLine);
					
					// dumString = nLine.Right(7);
                    dumString = nLine.substr(nLine.size()-7, 7);
                    
					m_TermHead->SetEddyPercent(i, stod(dumString) * 100);
					break;
				}

			}

		}

		// end thrusts are last in the file

		wFindString = ", UPPER SUPPORT";
		while (fFile.ReadString(nLine))
		{
			if ((wPos = nLine.find(wFindString) != std::string::npos))
			{
				// dumString = nLine.Right(10);
                dumString = nLine.substr(nLine.size()-10, 10);
				m_TopEndThrust = stod(dumString);

				// next line is guaranteed to have Lower support
				fFile.ReadString(nLine);
				// dumString = nLine.Right(10);
                dumString = nLine.substr(nLine.size()-10, 10);
                
				m_BottomEndThrust = stod(dumString);
			}
		}
	
}

void Transformer::ClearPointers()
{
	m_LayerHead = NULL;
	m_TermHead = NULL;
	m_WdgHead = NULL;
}



int Transformer::VerifyTransformer()
{
	if (!m_IsValid)
		return TXFO_UNDEFINED_ERROR;

	// set the V/N and fix all the terminals
	CalcVoltsPerTurn();
	FixTerminalVoltages();


	// Check that amp-turns are zero (actually, make sure they're less than 10)

	if (fabs(AmpTurns()) > 10.0)
		return AMPTURNS_ERROR;

	// Check that diameters don't interfere with each other

	double lastDiameter = m_Core.m_Diameter;

	Winding* nextWinding = GetWdgHead();

	int count = 0;

	CString txt;


	while (nextWinding != NULL)
	{
		
		if (((nextWinding->m_LayerHead->m_InnerRadius) * 2) < lastDiameter)
		{
			return WDG1_TOOSMALL_ERROR + count;
		}

		lastDiameter = nextWinding->GetOuterDiameter();
		count++;
		// txt.Format("IR before call: %.3f", nextWinding->m_LayerHead->m_InnerRadius);
        txt = string_format("IR before call: %.3f", nextWinding->m_LayerHead->m_InnerRadius);
        
		//MessageBox(txt);
		nextWinding = nextWinding->GetNext();
		if (nextWinding != NULL)
		{
			// txt.Format("IR after call: %.3f", nextWinding->m_LayerHead->m_InnerRadius);
            txt = string_format("IR after call: %.3f", nextWinding->m_LayerHead->m_InnerRadius);
			//MessageBox(txt);
		}
	}

	// Done checking diameters
 

	return NO_TXFO_ERROR;
}

bool Transformer::HasRegWinding()
{

	Winding* nextWdg = m_WdgHead;

	while (nextWdg != NULL)
	{
		if (nextWdg->m_IsRegWdg)
		{
			return true;
		}

		nextWdg = nextWdg->GetNext();
	}

	return false;
}

Transformer::Transformer(Transformer& oldTxfo)
{
	m_NumTerminals = 0;
	m_TermHead = NULL;
	m_WdgHead = NULL;
	m_LayerHead = NULL;
	m_VoltsPerTurn = 0.0;
	m_VperNTerminal = 0;
	m_IsValid = false;
	m_OffElongValue = 0.0;
	m_OffsetElongation = 0;

	InitializeTxfo();

	m_Core = CCore(oldTxfo.m_Core);
	m_DefaultFolder = oldTxfo.m_DefaultFolder;
	m_Description = oldTxfo.m_Description;
	m_FirstFanStage = oldTxfo.m_FirstFanStage;
	m_Frequency = oldTxfo.m_Frequency;
	m_InnerClearance = oldTxfo.m_InnerClearance;
	m_IsValid = oldTxfo.m_IsValid;
	m_LowerZ = oldTxfo.m_LowerZ;
	m_NumPhases = oldTxfo.m_NumPhases;
	m_NumTerminals = oldTxfo.m_NumTerminals;
	m_NumWoundLimbs = oldTxfo.m_NumWoundLimbs;
	m_PeakFactor = oldTxfo.m_PeakFactor;
	m_SecondFanStage = oldTxfo.m_SecondFanStage;
	m_SystemGVA = oldTxfo.m_SystemGVA;
	m_TempRise = oldTxfo.m_TempRise;
	m_VoltsPerTurn = oldTxfo.m_VoltsPerTurn;
	m_VperNTerminal = oldTxfo.m_VperNTerminal;
	m_OffElongValue = oldTxfo.m_OffElongValue;
	m_OffsetElongation = oldTxfo.m_OffsetElongation;

	m_Next = NULL;
	m_Prev = NULL;

	// copy terminals
	Terminal* nextOldTerm = oldTxfo.m_TermHead;
	Terminal* lastNewTerm = NULL;
	m_TermHead = NULL;
    
	while (nextOldTerm != NULL)
	{
		if (m_TermHead == NULL)
		{
			m_TermHead = new Terminal(nextOldTerm);
			lastNewTerm = m_TermHead;
		}
		else
		{
			lastNewTerm->SetNext(new Terminal(nextOldTerm));
			lastNewTerm = lastNewTerm->GetNext();
		}

		nextOldTerm = nextOldTerm->GetNext();
	}
    
    if (lastNewTerm != NULL)
    {
        lastNewTerm->SetNext(NULL);
    }
	
	// copy layers
	Layer* nextOldLayer = oldTxfo.m_LayerHead;
	Layer* lastNewLayer = NULL;
	m_LayerHead = NULL;
	while (nextOldLayer != NULL)
	{
		if (m_LayerHead == NULL)
		{
			m_LayerHead = new Layer(nextOldLayer);
			lastNewLayer = m_LayerHead;
		}
		else
		{
			lastNewLayer->SetNext(new Layer(nextOldLayer));
			lastNewLayer = lastNewLayer->GetNext();
		}

		nextOldLayer = nextOldLayer->GetNext();
	}
	if (lastNewLayer != NULL)
		lastNewLayer->SetNext(NULL);


	// copy windings
	Winding* nextOldWinding = oldTxfo.m_WdgHead;
	Winding* lastNewWinding = NULL;
	m_WdgHead = NULL;
	while (nextOldWinding != NULL)
	{
		if (m_WdgHead == NULL)
		{
			m_WdgHead = new Winding(nextOldWinding);
			lastNewWinding = m_WdgHead;
		}
		else
		{
			lastNewWinding->SetNext(new Winding(nextOldWinding));
			lastNewWinding = lastNewWinding->GetNext();
		}

		nextOldWinding = nextOldWinding->GetNext();
	}
	
	if (lastNewWinding != NULL)
		lastNewWinding->SetNext(NULL);

}

Layer* Transformer::GetLayerFromSegmentNumber(int wSegNum)
{
	Winding* nextWdg = NULL;
	Layer* nextLayer;
	Segment* nextSegment;
	int counter = 0;

	for (nextWdg = m_WdgHead; nextWdg != NULL; nextWdg = nextWdg->GetNext())
	{
		for (nextLayer = nextWdg->m_LayerHead; nextLayer != NULL; nextLayer = nextLayer->GetNext())
		{
			for (nextSegment = nextLayer->m_SegmentHead; nextSegment != NULL; nextSegment = nextSegment->m_Next)
			{
				counter++;

				if (counter == wSegNum)
					return nextLayer;
			}
		}
	}

	return NULL;
}

void Transformer::SetNext(Transformer *wTxfo)
{
	m_Next = wTxfo;
}

void Transformer::SetPrev(Transformer *wTxfo)
{
	m_Prev = wTxfo;
}

Transformer* Transformer::GetNext()
{
	return m_Next;
}

Transformer* Transformer::GetPrev()
{
	return m_Prev;
}

double Transformer::GetTerminalVoltage(int wTerm)
{
	Terminal* nTerm = m_TermHead;

	while (nTerm != NULL)
	{
		if (nTerm->m_Number == wTerm)
			break;

		nTerm = nTerm->GetNext();
	}

	if (nTerm == NULL)
	{
		return 0.0;
	}
	
	return nTerm->m_KV;
	
}
