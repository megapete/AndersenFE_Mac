// ExcelTextFile.cpp: implementation of the CExcelTextFile class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "AndersenFE.h"
#include "ExcelTextFile.h"
#include "terminal.h"



//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CExcelTextFile::CExcelTextFile()
{

}

CExcelTextFile::~CExcelTextFile()
{

}

CExcelTextFile::CExcelTextFile(CString lpszFileName, uint nOpenFlags) : CStdioFile(lpszFileName, nOpenFlags)
{
    
}


int CExcelTextFile::InputFile(Transformer *wTxfo)
{

	int nextLine = 1;
	CString lineString;

	if (ReadString(lineString) == FALSE)
		return 1001;

	// Read line 1 (6 tabs [file version 1: 7 tabs])
	// #phases, freq, temp rise, fan1, fan2, coredia, winHt [,fileversion];

	int line1_Tabs = CountTabs(lineString);
	
	if ((line1_Tabs != 6) && (line1_Tabs != 7))
		return 1001;

	int nextTab = 0;

	wTxfo->m_NumPhases = ExtractValue(lineString, &nextTab);
	if (wTxfo->m_NumPhases == 3)
		wTxfo->m_NumWoundLimbs = 3;
	else
		wTxfo->m_NumWoundLimbs = 2; // should be fixed for single phase

	wTxfo->m_FirstFanStage = 100;
	wTxfo->m_SecondFanStage = 100;
	wTxfo->m_InnerClearance = 0;
	wTxfo->m_PeakFactor = 1.8f;
	wTxfo->m_SystemGVA = 0;

	wTxfo->m_Frequency = ExtractValue(lineString, &nextTab);
	wTxfo->m_TempRise = ExtractValue(lineString, &nextTab); 
	wTxfo->m_FirstFanStage = ExtractFloatValue(lineString, &nextTab);
	wTxfo->m_SecondFanStage = ExtractFloatValue(lineString, &nextTab);
	wTxfo->m_Core.m_Diameter = ExtractFloatValue(lineString, &nextTab);
	wTxfo->m_Core.m_WindowHeight = ExtractFloatValue(lineString, &nextTab);
	int fileVersion = 0;
	if (line1_Tabs == 7)
		fileVersion = ExtractValue(lineString, &nextTab);
	wTxfo->m_LowerZ = 0;
	nextLine++;


	// Read line 2-5[V1:9] inclusive (3 tabs per line)
	// "winding data": Line volts, MVA, Connection, terminal 

	double rowVolts[9];
	double rowKVA[9];
	char rowConn[9];
	int rowTerm[9];
    int rowCurrentDir[9]; // TODO: Implement current direction
	wTxfo->m_NumTerminals = 0;
	bool doneTerm[9] = {false, false, false, false, false, false, false, false, false};
	bool columnIsValid[9] = {false, false, false, false, false, false, false, false, false};
	int newTermNum[64] = {0};
	// bool atLeastOneDoubleStack = false;

	int lastWdgDataLine = 5;
	if (fileVersion > 0)
		lastWdgDataLine = 9;
    
    int rowTabs = 3;
    if (fileVersion >= 2)
    {
        rowTabs = 4;
        int removeThis = 3;
    }
    // Terminal *test = new Terminal;
	
	while (nextLine <= lastWdgDataLine)
	{
		if (ReadString(lineString) == FALSE)
			return (1000 + nextLine);
		if (CountTabs(lineString) != rowTabs)
			return (1000 + nextLine);

		nextTab = 0;
		rowVolts[nextLine - 2] = ExtractFloatValue(lineString, &nextTab);
		rowKVA[nextLine - 2] = ExtractFloatValue(lineString, &nextTab);
		rowConn[nextLine - 2] = ExtractChar(lineString, &nextTab);

		rowTerm[nextLine - 2] = ExtractValue(lineString, &nextTab);
        
        if (rowTabs == 4)
        {
            rowCurrentDir[nextLine - 2] = ExtractValue(lineString, &nextTab);
        }

		if (rowTerm[nextLine - 2] == 0)
		{
			doneTerm[rowTerm[nextLine - 2]] = true; // ignore the line
		}
		else
		{
			columnIsValid[nextLine - 2] = true;
		}

		// Assume that row 1 is HV nominal, row 2 is LV nominal, any other rows that have
		// the same terminal number as HV or LV is a tapping winding for that terminal

		Terminal* aTerm = NULL;

		if (!doneTerm[rowTerm[nextLine - 2]])
		{
			aTerm = new Terminal;
			wTxfo->AddTerminal(aTerm);
			aTerm->m_KV = rowVolts[nextLine - 2] / 1000;
			aTerm->m_MVA = rowKVA[nextLine - 2] / 1000;
			wTxfo->m_NumTerminals++;
			aTerm->m_Number = wTxfo->m_NumTerminals;

			if (wTxfo->m_NumPhases == 1)
			{
				aTerm->m_Connection = SINGLE;
			}
			else if (rowConn[nextLine - 2] == 'Y')
			{
				aTerm->m_Connection = WYE;
			}
			else if (rowConn[nextLine - 2] == 'D')
			{
				aTerm->m_Connection = DELTA;
			}
			else if (rowConn[nextLine - 2] == 'Z')
			{
				aTerm->m_Connection = ZIGZAGNEUTRAL;
				aTerm->m_KV *= (double)sqrt(3.0); // excel sheet uses linevolts over 3,
												 // andersen requires linevolts over root3
			}

			doneTerm[rowTerm[nextLine - 2]] = true;

			// set rowTerm to Andersen Terminal Number
			newTermNum[rowTerm[nextLine - 2]] = aTerm->m_Number;
			rowTerm[nextLine - 2] = aTerm->m_Number;

		}
		else if (rowConn[nextLine - 2] == 'Z')
		// handle special zigzag case
		{
			aTerm = new Terminal;
			wTxfo->AddTerminal(aTerm);
			aTerm->m_KV = rowVolts[nextLine - 2] / 1000;
			aTerm->m_MVA = rowKVA[nextLine - 2] / 1000;
			aTerm->m_Connection = ZIGZAGLINE;
			aTerm->m_KV *= (double)sqrt(3.0);
			wTxfo->m_NumTerminals++;
			aTerm->m_Number = wTxfo->m_NumTerminals;
			// set rowTerm to Andersen Terminal Number
			newTermNum[rowTerm[nextLine - 2]] = aTerm->m_Number;
			rowTerm[nextLine - 2] = aTerm->m_Number;
		}
		else
		{
			rowTerm[nextLine - 2] = newTermNum[rowTerm[nextLine - 2]];
		}

		nextLine++;
	}

	
	int fOffSet = nextLine;

	// variables for data read in
	CString nLine[50]; // allow a maximum of 50 lines to be read in

	// Read line 6 to EOF  (3[V1:7] tabs per line)
	// Rows (to be converted to terminal numbers)

	int tabsPerLine = 3;
	if (fileVersion > 0)
		tabsPerLine = 7;

	while (ReadString(nLine[nextLine - fOffSet]))
	{
		if (CountTabs(nLine[nextLine - fOffSet]) != tabsPerLine)
			return (1000 + nextLine);
		
		nextLine++;
	}

	// the nLine array now holds line 6 through to the end of the file

	int i = 0;
	Winding* wWdg;
	Winding* wdgHead = NULL;
	// Winding* wdgLast;

	int fileVersionOffset = 0;
	if (fileVersion > 0)
	{
		fileVersionOffset = 4;
	}

	for (i=0; (i<tabsPerLine + 1) && columnIsValid[i]; i++)
	{
		wWdg = new Winding;
		
		if (wdgHead == NULL)
		{
			wdgHead = wWdg;
		}

		wWdg->m_Material = COPPER;
		wWdg->m_NumAxialSections = 1; // default
		wWdg->m_BetweenSections = 0; // default
		
		wWdg->m_Terminal = rowTerm[ExtractValue(nLine[6+fileVersionOffset - fOffSet], i+1) - 1];

		if (wWdg->m_Terminal == 1)
			wWdg->m_CurrentDirection = 1;
		else
			wWdg->m_CurrentDirection = -1;

		wWdg->m_TotalTurns = ExtractFloatValue(nLine[9+fileVersionOffset - fOffSet], i+1);
		wWdg->m_ElectricalHeight = ExtractFloatValue(nLine[10+fileVersionOffset - fOffSet], i+1);
		wWdg->m_NumDisks = ExtractValue(nLine[14+fileVersionOffset - fOffSet], i+1);
		wWdg->m_BetweenDisks = ExtractFloatValue(nLine[15+fileVersionOffset - fOffSet], i+1);
		wWdg->m_SpacerBlockWidth = ExtractFloatValue(nLine[16+fileVersionOffset - fOffSet], i+1);
		wWdg->m_NumSpacerBlocks = ExtractValue(nLine[17+fileVersionOffset - fOffSet], i+1);
		wWdg->m_NumLayers = ExtractValue(nLine[18+fileVersionOffset - fOffSet], i+1);
		wWdg->m_BetweenLayers = ExtractFloatValue(nLine[19+fileVersionOffset - fOffSet], i+1);
		wWdg->m_NumRadialDucts = ExtractValue(nLine[20+fileVersionOffset - fOffSet], i+1);
		wWdg->m_RadialDuctDimn = ExtractFloatValue(nLine[21+fileVersionOffset - fOffSet], i+1);
		wWdg->m_NumRadialSupports = ExtractValue(nLine[22+fileVersionOffset - fOffSet], i+1);

		char aType = ExtractChar(nLine[23+fileVersionOffset - fOffSet], i+1);
		toupper(aType);
		switch (aType) {
		case 'C':
			wWdg->m_CondType = CTC_COND;
			wWdg->m_CondNumStrands = ExtractValue(nLine[30+fileVersionOffset - fOffSet], i+1);
			break;
		case 'S':
			wWdg->m_CondType = SINGLE_COND;
			wWdg->m_CondNumStrands = 1;
			break;
		case 'D':
			wWdg->m_CondType = DOUBLE_COND;
			wWdg->m_CondNumStrands = 2;
			break;
		} // end switch

		wWdg->m_CondNumAxial = ExtractValue(nLine[24+fileVersionOffset - fOffSet], i+1);
		wWdg->m_CondNumRadial = ExtractValue(nLine[25+fileVersionOffset - fOffSet], i+1);
		wWdg->m_CondCover = ExtractFloatValue(nLine[27+fileVersionOffset - fOffSet], i+1);
		wWdg->m_StrandDimnAxial = ExtractFloatValue(nLine[28+fileVersionOffset - fOffSet], i+1);
		wWdg->m_StrandDimnRadial = ExtractFloatValue(nLine[29+fileVersionOffset - fOffSet], i+1);

		/*
		DEFINITION OF WINDING TYPES
		===========================

		HELICAL:
		Axial Sections = 1 (m_NumDisks)
		Radial Sections = 1 (m_NumLayers)
		Axial Spiral Sections = 'Y'

		CROSSOVER:
		Axial Sections > 1
		Radial Sections > 1
		Axial Spiral Sections = 'Y'

		LAYER:
		Axial Sections = 1
		Radial Sections > 1
		Axial Spiral Sections = 'Y'

		DISK:
		Axial Sections > 1
		Radial Sections = 1
		Axial Spiral Sections = 'N'

		SHEET:
		Axial Sections = 1
		Radial Sections = 1
		Axial Spiral Sections = 'N'


		PARALLEL FOR ANY OF THE ABOVE TYPES:
		Double Stack = 'Y'

		*/

		aType = ExtractChar(nLine[11+fileVersionOffset - fOffSet], i+1); // axial spiral sections?
		toupper(aType);

		if (aType == 'Y')
		{
			if ((wWdg->m_NumDisks == 1) && (wWdg->m_NumLayers == 1))
			{
				wWdg->m_NumDisks = (int)wWdg->m_TotalTurns;
				wWdg->m_Type = DISKTYPE;
			}
			else if ((wWdg->m_NumDisks > 1) && (wWdg->m_NumLayers > 1))
				wWdg->m_Type = SECTION_LAYERTYPE;
			else
				wWdg->m_Type = LAYERTYPE;
		}
		else
		{
			if ((wWdg->m_NumDisks > 1) && (wWdg->m_NumLayers == 1))
				wWdg->m_Type = DISKTYPE;
			else
				wWdg->m_Type = SHEETTYPE;
		}

		// take care of in-winding taps
		
		double minTurns, nomTurns;

		minTurns = ExtractFloatValue(nLine[7+fileVersionOffset - fOffSet], i+1);
		nomTurns = ExtractFloatValue(nLine[8+fileVersionOffset - fOffSet], i+1);

		if ((nomTurns != wWdg->m_TotalTurns) || (minTurns != wWdg->m_TotalTurns))
		{
			wWdg->m_TapLocation = CENTER_TAPS;
			wWdg->m_HiTap = wWdg->m_TotalTurns / nomTurns;
			wWdg->m_LoTap = minTurns / nomTurns;
			wWdg->m_NumTapSteps = 4; // may require a new field in the excel program
		}
		else
		{
			wWdg->m_TapLocation = NO_TAPS;
			wWdg->m_HiTap = 1.0;
			wWdg->m_LoTap = 1.0;
		}

		
		wWdg->m_AxialCenterPack = ExtractFloatValue(nLine[31+fileVersionOffset - fOffSet], i+1);
		wWdg->m_AxialDVGap1 = ExtractFloatValue(nLine[32+fileVersionOffset - fOffSet], i+1);
		wWdg->m_AxialDVGap2 = ExtractFloatValue(nLine[33+fileVersionOffset - fOffSet], i+1);

		aType = ExtractChar(nLine[12+fileVersionOffset - fOffSet], i+1); // double stack?
		toupper(aType);

		if (aType == 'Y')
		{
			// atLeastOneDoubleStack = true;

			wWdg->m_NumberParGroups = 2;
			wWdg->m_NumAxialSections = 2;
			wWdg->m_IsDoubleStack = true;

			if (wWdg->m_Type == DISKTYPE)
				wWdg->m_Type = MULTIPLE_DISKTYPE;
			else if (wWdg->m_Type == LAYERTYPE)
				wWdg->m_Type = MULTIPLE_LAYERTYPE;
			else
				wWdg->m_Type = MULTIPLE_SHEETTYPE;
		}


		double bottomEdgePack = ExtractFloatValue(nLine[34+fileVersionOffset - fOffSet], i+1);
		if (bottomEdgePack > wTxfo->m_LowerZ)
			wTxfo->m_LowerZ = bottomEdgePack;

		wWdg->m_InnerRadius = ExtractFloatValue(nLine[35+fileVersionOffset - fOffSet], i+1) / 2;
		wWdg->m_RadialOverBuild = ExtractFloatValue(nLine[36+fileVersionOffset - fOffSet], i+1);

		double dumFloat = ExtractFloatValue(nLine[37+fileVersionOffset - fOffSet], i+1);
		if (dumFloat > wTxfo->m_InnerClearance)
			wTxfo->m_InnerClearance = dumFloat;

		dumFloat = ExtractFloatValue(nLine[38+fileVersionOffset - fOffSet], i+1);
		if (dumFloat > wTxfo->m_PeakFactor)
			wTxfo->m_PeakFactor = dumFloat;

		dumFloat = ExtractFloatValue(nLine[39+fileVersionOffset - fOffSet], i+1);
		if (dumFloat > wTxfo->m_SystemGVA)
			wTxfo->m_SystemGVA = dumFloat;

		wWdg->m_BetweenCables = ExtractFloatValue(nLine[40+fileVersionOffset-fOffSet], i+1);
		

		wTxfo->AddWinding(wWdg);
	}

	if (wdgHead == NULL)
		return WINDING_PTR_ERROR;

	while (wdgHead != NULL)
	{
		// wdgHead->m_IsDoubleStack = atLeastOneDoubleStack;
		wdgHead->SetDefaultZlist();
		wdgHead->CompileLayerList();
		wdgHead = wdgHead->GetNext();
	}



	return NO_TXTFILE_ERROR;
}


int CExcelTextFile::CountTabs(CString &wString)
// don't count consecutive tabs at the end of the line
{
	// wString.TrimRight('\t');
    wString = wString.substr(0, wString.find_last_not_of('\t')+1);

	int result = 0;
	unsigned long lastTab = wString.find('\t', 0);


	while (lastTab != std::string::npos)
	{
		result++;
		lastTab = wString.find('\t', lastTab+1);
	}

	return result;

}



int CExcelTextFile::ExtractValue(CString &wStr, int *wPos)
{
	int startPos = *wPos;
	*wPos = (int)(wStr.find('\t', startPos) + 1);
	int endPos = *wPos - 2;

	if (endPos < 0)
		endPos = (int)(wStr.size() - 1);

	CString resString = wStr.substr(startPos, endPos - startPos + 1);

	int result = stoi(resString);

	return result;

}

double CExcelTextFile::ExtractFloatValue(CString &wStr, int *wPos)
{
	int startPos = *wPos;
	*wPos = (int)(wStr.find('\t', startPos) + 1);
	int endPos = *wPos - 2;

	if (endPos < 0)
		endPos = (int)(wStr.size() - 1);

	CString resString = wStr.substr(startPos, endPos - startPos + 1);

	double result = stod(resString);

	return result;

}

char CExcelTextFile::ExtractChar(CString &wStr, int *wPos)
{
	int startPos = *wPos;
	*wPos = (int)(wStr.find('\t', startPos) + 1);

	char result = wStr.at(startPos);

	return result;
}



int CExcelTextFile::ExtractValue(CString &wStr, int index)
// instead of using the actual character position like the other version of ExtractValue
// (which is called by this function), this  function uses an index into the 'column' 
// that interests us. The index base is 1.
{
	int wPos = 0;

	if (index > 1)
	{
		int wIndex;

		for (wIndex = 1; wIndex < index; wIndex++)
		{
			wPos = (int)(wStr.find('\t', wPos) + 1);
		}
	}

	return ExtractValue(wStr, &wPos);
}

double CExcelTextFile::ExtractFloatValue(CString &wStr, int index)
// instead of using the actual character position like the other version of ExtractFloatValue
// (which is called by this function), this  function uses an index into the 'column' 
// that interests us. The index base is 1.

{
	int wPos = 0;

	if (index > 1)
	{
		int wIndex;

		for (wIndex = 1; wIndex < index; wIndex++)
		{
			wPos = (int)(wStr.find('\t', wPos) + 1);
		}
	}

	return ExtractFloatValue(wStr, &wPos);

}

char CExcelTextFile::ExtractChar(CString &wStr, int index)
// instead of using the actual character position like the other version of ExtractChar
// (which is called by this function), this  function uses an index into the 'column' 
// that interests us. The index base is 1.
{
	int wPos = 0;

	if (index > 1)
	{
		int wIndex;

		for (wIndex = 1; wIndex < index; wIndex++)
		{
			wPos = (int)(wStr.find('\t', wPos) + 1);
		}
	}

	return ExtractChar(wStr, &wPos);
}
