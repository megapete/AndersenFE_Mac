// AndersenFolder.cpp: implementation of the CAndersenFolder class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "andersenfe.h"
#include "AndersenFolder.h"
#include <string>
#include "CFile.h"
#include "CStdioFile.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CAndersenFolder::CAndersenFolder()
{
	m_ReaderCount = 0;
}

CAndersenFolder::~CAndersenFolder()
{
	

	
}

void CAndersenFolder::ReadAndersenFolderName(CString *wString)
{
	UseAndersenFolderName();

	*wString = m_pathName;

	ReleaseAndersenFolderName();

}


void CAndersenFolder::WriteAndersenFolderName(CString *wString)
{
	

	m_pathName = *wString;

	m_isValid = VerifyPath();

	
}

bool CAndersenFolder::VerifyPath(CString *wString)
{
	bool result;
	CStdioFile newFile;
	CString tmpName;

	if (wString == NULL)
		tmpName = m_pathName;
	else
		tmpName = *wString;

	if (tmpName.size() == 0) // filename wasn't defined yet
		return false;

	// Check for both the FLD12 and FLD8 directories

	int test1 = newFile.Open(
		tmpName + "FLD12\\RUN.BAT",
		CFile::modeRead |
		CFile::shareDenyWrite);

	newFile.Close();

	int test2 = newFile.Open(
		tmpName + "FLD8\\RUN.BAT",
		CFile::modeRead |
		CFile::shareDenyWrite);
	
	result = (test1 && test2);

	return result;

}

void CAndersenFolder::UseAndersenFolderName()
{
	
		m_ReaderCount++;
		

}

void CAndersenFolder::ReleaseAndersenFolderName()
{
	
		m_ReaderCount--;
		

}

bool CAndersenFolder::AndersenFolderNameIsValid(CString *wString)
{
	if (wString != NULL)
	{
        
		if ((wString->size() > 3) ||
			(wString->at(0) < 'A') ||
			(wString->at(0) > 'Z'))
		{
        
			// AfxGetMainWnd()->MessageBox("Andersen directory must be a root directory");
			return false;
		}
		return VerifyPath(wString);
	}

	return m_isValid;
}

bool CAndersenFolder::SaveInp1File(Transformer *wTxfo)
{
	if ((!wTxfo->m_IsValid) || (!VerifyPath()))
		return false;
		
	CString wFilePath = m_pathName;
	wFilePath += "FLD12\\INP1.FIL";

		CStdioFile newFile(
			wFilePath, 
			CFile::modeCreate |
			CFile::modeWrite |
			CFile::shareExclusive |
			CFile::typeText);

		// Line 1
		CString nLine = wTxfo->m_Description;
		nLine += "\n";
		newFile.WriteString(nLine);

		// Line 2
        nLine = string_format(
            "%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.3f%-10.3f%-10.3f\n",
			2, // always in inches
			wTxfo->m_NumPhases, 
			wTxfo->m_Frequency,
			wTxfo->m_NumWoundLimbs,
			1, // always full height
			-wTxfo->m_LowerZ,
			wTxfo->m_Core.m_WindowHeight - wTxfo->m_LowerZ,
			wTxfo->m_Core.m_Diameter
			);
		newFile.WriteString(nLine);

		// Line 3
		nLine = string_format("%-10.3f%-10.1d%-10.3f%-10.3f%-10.3f%-10.1d%-10.1d\n",
			wTxfo->m_InnerClearance,
			0, // AL/CU shield
			wTxfo->m_SystemGVA,
			0.0, // Optional Per Unit Impedance
			wTxfo->m_PeakFactor,
			wTxfo->m_NumTerminals,
			wTxfo->CountLayers()
			);
		newFile.WriteString(nLine);

		// Line 4
		nLine = string_format("%-10.1d%-10.3f%-10.3f%-10.3f%-10.3f%-10.1d%-10.1d\n",
			0, // displacement/elongation
			0.0, // amount
			0.0, // loss factor - tank
			0.0, // loss factor - leg
			0.0, // loss factor - yoke
			1, // scale of flux plot
			25 // number of flux lines
			);
		newFile.WriteString(nLine);

		// Terminal data
		Terminal* nextTerm = wTxfo->GetTermHead();
		while (nextTerm != NULL)
		{
			nLine = string_format("%-10.1d%-10.1d%-10.3f%-10.3f\n",
				nextTerm->m_Number,
				nextTerm->m_Connection,
				nextTerm->m_MVA,
				nextTerm->m_KV
				);
			newFile.WriteString(nLine);

			nextTerm = nextTerm->GetNext();
		}


		// Layer Data

		Winding* nextWinding = wTxfo->GetWdgHead();
		int layerNum = 0;
		int runningSegmentNum = 0;

		while (nextWinding != NULL)
		{
			Layer* nextLayer = nextWinding->m_LayerHead;
			

			while (nextLayer != NULL)
			{
				layerNum++;
				runningSegmentNum += nextLayer->CountSegments();

				nLine = string_format("%-10.1d%-10.1d%-10.3f%-10.3f\n",
					layerNum,
					runningSegmentNum,
					nextLayer->m_InnerRadius,
					nextLayer->m_RadialWidth
					);
				newFile.WriteString(nLine);


				nLine = string_format("%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.3f\n",
					nextLayer->m_Terminal, // Terminal Number
					nextLayer->m_NumberParGroups,
					nextLayer->m_CurrentDirection,
					nextLayer->m_Material,
					nextLayer->m_NumSpacerBlocks,
					nextLayer->m_SpacerBlockWidth
					);
				newFile.WriteString(nLine);

				nextLayer = nextLayer->GetNext();

			} // end while (nextLayer != NULL)

			nextWinding = nextWinding->GetNext();

		} // end while (nextWinding != NULL) [layer]


		// Segment Data

		nextWinding = wTxfo->GetWdgHead();
		runningSegmentNum = 0;

		while (nextWinding != NULL)
		{
			Layer* nextLayer = nextWinding->m_LayerHead;
			Segment* nextSegment;

			while (nextLayer != NULL)
			{
				nextSegment = nextLayer->m_SegmentHead;

				while (nextSegment != NULL)
				{
					runningSegmentNum++;

					nLine = string_format("%-10.1d%-10.3f%-10.3f%-10.3f%-10.3f\n",
						runningSegmentNum,
						nextSegment->m_MinZ,
						nextSegment->m_MaxZ,
						nextSegment->m_NumTurnsTotal,
						nextSegment->m_NumTurnsActive
						);
					newFile.WriteString(nLine);

					nLine = string_format("%-10.1d%-10.1d%-10.3f%-10.3f\n",
						nextSegment->m_NumStrandsPerTurn,
						nextSegment->m_NumStrandsPerLayer,
						nextSegment->m_StrandR,
						nextSegment->m_StrandA
						);
					newFile.WriteString(nLine);


					nextSegment = nextSegment->m_Next;

				} // end while (nextSegment != NULL)

				nextLayer = nextLayer->GetNext();

			} // end while (nextLayer != NULL)

			nextWinding = nextWinding->GetNext();

		} // end while (nextWinding != NULL) [segment]



	return true;
}
