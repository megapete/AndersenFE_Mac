// MainFrm.cpp : implementation of the CMainFrame class
//

#include "stdafx.h"
#include "AndersenFE.h"


#include "MainFrm.h"
#include "AppController.h"



/////////////////////////////////////////////////////////////////////////////
// CMainFrame



/////////////////////////////////////////////////////////////////////////////
// CMainFrame construction/destruction

CMainFrame::CMainFrame(AppControllerImpl *tCtrl)
{
	// TODO: add member initialization code here
    
    theController = tCtrl;

	m_TxfoUndoList = NULL;
	m_NumUndoTxfos = 0;

	m_FluxLines = NULL;

	InitializeTxfo();

	// m_wndView.m_CurrTxfo = &m_CurrentTxfo;
	// m_wndView.m_Parent = this;

	// m_tApp = (CAndersenFEApp*)AfxGetApp();

	/*  take care of all the Andersen folder stuff in ObjC
    CString tmpName = m_tApp->GetProfileString("","Andersen Path");

	m_AndersenFolder.WriteAndersenFolderName(&tmpName);
	m_CurrentTxfo.m_DefaultFolder = &m_AndersenFolder;
     */
}

CMainFrame::~CMainFrame()
{
		
}



void CMainFrame::OnFileNewtransformer(TxfoDataDlog newDlog)
{
	
	// TxfoDataDlog newDlog;

	if (newDlog.DoModal() == IDOK)
	{
		m_CurrTxfoIsValid = true;
		m_CurrentTxfo.m_IsValid = true;
		m_CurrentTxfo.m_Frequency = (int)newDlog.m_frequency;
		m_CurrentTxfo.m_InnerClearance = newDlog.m_clearance;
		m_CurrentTxfo.m_NumWoundLimbs = newDlog.m_limbs;
		m_CurrentTxfo.m_PeakFactor = newDlog.m_peakfactor;
		m_CurrentTxfo.m_SystemGVA = newDlog.m_sysGVA;
		m_CurrentTxfo.m_Core.m_Diameter = newDlog.m_coredia;
		m_CurrentTxfo.m_Core.m_WindowHeight = newDlog.m_winheight;
		m_CurrentTxfo.m_Description = newDlog.m_Description;
		m_CurrentTxfo.m_LowerZ = newDlog.m_LowerBoundary;

		if ((newDlog.m_singlephase = 0)) // first button (0) in group is "single phase"
			m_CurrentTxfo.m_NumPhases = 1;
		else
			m_CurrentTxfo.m_NumPhases = 3;

		// SetWindowText(newDlog.m_Description);

	}	
}



void CMainFrame::OnOptionsTerminals() // Add Terminals
{
	// TODO: Add your command handler code here

	AddTermDlog newDlog;

	if (newDlog.DoModal() == IDOK)
	{
		Terminal* aTerm = new Terminal;
		Terminal* bTerm = NULL;

		m_CurrentTxfo.AddTerminal(aTerm);

		aTerm->m_KV = newDlog.m_Voltage;
		aTerm->m_MVA = newDlog.m_MVA;
		aTerm->m_Name = newDlog.m_Name;

		m_CurrentTxfo.m_NumTerminals++;
		aTerm->m_Number = m_CurrentTxfo.m_NumTerminals;

		switch(newDlog.m_Connection) {
		case 0:
			aTerm->m_Connection = SINGLE;
			break;
		case 1:
			aTerm->m_Connection = WYE;
			break;
		case 2:
			aTerm->m_Connection = DELTA;
			break;
		case 3:
			aTerm->m_Connection = AUTOTXFO;
			break;
		case 4: // zigzag, create another terminal
			aTerm->m_Connection = ZIGZAGNEUTRAL;
			aTerm->m_KV /= (double)sqrt(3.0); // required for Andersen

			bTerm = new Terminal(aTerm);
			bTerm->m_Connection = ZIGZAGLINE;
			m_CurrentTxfo.m_NumTerminals++;
			bTerm->m_Number = m_CurrentTxfo.m_NumTerminals;
			aTerm->SetNext(bTerm);
			break;

		default:
			aTerm->m_Connection = UNDEFINED_CONNECTION;

		}

		// m_wndView.HandleTxfoChanges();

	} // end if (newDlog.DoModal() == IDOK)
}

void CMainFrame::OnOptionsWindings() 
{
	// TODO: Add your command handler code here

	AddWinding();
}

void CMainFrame::InitializeTxfo()
{
	m_CurrTxfoIsValid = false;
	DeleteFluxData();

	m_CurrentTxfo.InitializeTxfo();

}




void CMainFrame::AddWinding(Winding* oldWinding, int wTerm)
{
	WindingGen newDlog1;

	if (wTerm == 0)
		newDlog1.m_NumTermsDefined = m_CurrentTxfo.m_NumTerminals;
	else
		newDlog1.m_NumTermsDefined = -wTerm;

	if (oldWinding != NULL)
	{
		newDlog1.m_IsModify = true;
		newDlog1.m_OldWinding = oldWinding;
	}

	if (newDlog1.DoModal() == IDOK)
	{
		CWindingDetailDlog newDlog2;

		if (oldWinding != NULL)
		{
			newDlog2.m_IsModify = true;
			newDlog2.m_OldWinding = oldWinding;
		}

		int wdgType = newDlog1.m_Type % 3;
		newDlog2.m_WdgType = wdgType;
		
		switch (wdgType) {
		case 0: // disk
			newDlog2.m_Text_CircW = _T("Circumferential Width:");
			newDlog2.m_Text_NumCols = _T("Number of Axial Columns:");
			newDlog2.m_Text_NumDisks = _T("Number of Disks:");
			newDlog2.m_Text_SpacerT = _T("Spacer Thickness:");
			newDlog2.m_Text_WdgTitle = _T("=== Disk Winding ===");
			break;
		case 1: // layer
			newDlog2.m_Text_NumDisks = _T("Number of Layers:");
			newDlog2.m_Text_NumCols = _T("Between Layers:");
			newDlog2.m_Text_WdgTitle = _T("=== Layer Winding ===");
			break;
		case 2: // sheet
			newDlog2.m_Text_NumCols = _T("Between Turns:");
			newDlog2.m_Text_WdgTitle = _T("=== Sheet Winding ===");
			break;

		}

		if (newDlog2.DoModal() == IDOK)
		{
			// save all the data

			Winding* newWdg = new Winding;
			
			// newWdg->m_BetweenSections is calculated
			newWdg->m_BetweenDisks = newDlog2.m_SpacerT;
			newWdg->m_SpacerBlockWidth = newDlog2.m_CircWidth;
			newWdg->m_CondNumAxial = newDlog1.m_NoCondAxial;
			newWdg->m_CondNumRadial = newDlog1.m_NoCondRadial;
			newWdg->m_CondType = newDlog1.m_CondType;

			switch (newDlog1.m_CondType) {
			case SINGLE_COND:
				newWdg->m_CondNumStrands = 1;
				break;
			case DOUBLE_COND:
				newWdg->m_CondNumStrands = 2;
				break;
			case CTC_COND:
				newWdg->m_CondNumStrands = newDlog1.m_NoStrands;
				break;
			}

			newWdg->m_CondType = newDlog1.m_CondType;
			newWdg->m_CurrentDirection = (int)pow((double)-1,(double)newDlog1.m_CurrDirection);
			newWdg->m_ElectricalHeight = newDlog1.m_ElHeight;
			newWdg->m_InnerRadius = newDlog1.m_InnerDiameter / 2;
			newWdg->m_Material = newDlog1.m_Material + 1;
			newWdg->m_StrandDimnAxial = newDlog1.m_StrandAxialDImn;
			newWdg->m_StrandDimnRadial = newDlog1.m_StrandRadialDimn;
			newWdg->m_Terminal = newDlog1.m_Terminal + 1;
			newWdg->m_Type = newDlog1.m_Type;
			newWdg->m_RadialOverBuild = newDlog1.m_RadOverbuild;
			newWdg->m_BetweenSections = newDlog1.m_BetSections;
			
			switch (newDlog1.m_Type) {
			case DISKTYPE:
				newWdg->m_NumAxialSections = 1;
				newWdg->m_NumSpacerBlocks = (int)newDlog2.m_NumColumns;
				break;
			case MULTIPLE_DISKTYPE:
				newDlog2.m_TotTurns *= newDlog1.m_NumSections;
				newWdg->m_NumberParGroups = newDlog1.m_NumSections;
			case SECTION_DISKTYPE:
				newWdg->m_NumAxialSections = newDlog1.m_NumSections;
				newWdg->m_NumSpacerBlocks = (int)newDlog2.m_NumColumns;
				break;
			case LAYERTYPE:
				newWdg->m_NumAxialSections = 1;
				newWdg->m_BetweenLayers = newDlog2.m_NumColumns;
				break;
			case MULTIPLE_LAYERTYPE:
				newDlog2.m_TotTurns *= newDlog1.m_NumSections;
			case SECTION_LAYERTYPE:
				newWdg->m_NumAxialSections = newDlog1.m_NumSections;
				newWdg->m_BetweenLayers = newDlog2.m_NumColumns;
				break;
			case SHEETTYPE:
				newWdg->m_NumAxialSections = 1;
				newWdg->m_BetweenLayers = newDlog2.m_NumColumns;
				break;
			case MULTIPLE_SHEETTYPE:
				newWdg->m_NumAxialSections = newDlog1.m_NumSections;
				newWdg->m_StrandDimnAxial /= newWdg->m_NumAxialSections;
				newDlog2.m_TotTurns *= newDlog1.m_NumSections;
			case SECTION_SHEETTYPE:
				newWdg->m_NumAxialSections = newDlog1.m_NumSections;
				newWdg->m_BetweenLayers = newDlog2.m_NumColumns;
				break;
			}

			newWdg->m_TotalTurns = newDlog2.m_TotTurns;
			newWdg->m_CondCover = newDlog1.m_CondCover;
			newWdg->m_NumDisks = newDlog2.m_NumDisks;
			newWdg->m_NumLayers = newDlog2.m_NumDisks;
			newWdg->m_NumRadialDucts = newDlog1.m_NumDucts;
			if (newDlog1.m_NumDucts == 0)
				newDlog1.m_DuctDim = 0;
			newWdg->m_RadialDuctDimn = newDlog1.m_DuctDim;

			newWdg->m_TapLocation = newDlog2.m_HasTaps - 1;

			if (newWdg->m_TapLocation >= 0)
			{
				newWdg->m_LoTap = 1.0f - newDlog2.m_LoTap / 100;
				newWdg->m_HiTap = 1.0f + newDlog2.m_HiTap / 100;
				newWdg->m_NumTapSteps = newDlog2.m_NumSteps;
				newWdg->m_ReentrantGap = newDlog2.m_TapGap;
			}

			newWdg->SetDefaultZlist();

			if (oldWinding != NULL)
				m_CurrentTxfo.RemoveWinding(oldWinding, true);

			m_CurrentTxfo.AddWinding(newWdg);
			newWdg->CompileLayerList();

			// m_wndView.HandleTxfoChanges();
		}
	}

}


void CMainFrame::OnAddWinding() 
{
	// TODO: Add your command handler code here

	// AddWinding(NULL, m_wndView.m_RBOverTerm);
	
}

void CMainFrame::OnFileSaveandersenfile() 
{
	// TODO: Add your command handler code here

		/*
	CFileDialog( 
		BOOL bOpenFileDialog, 
		LPCTSTR lpszDefExt = NULL, 
		LPCTSTR lpszFileName = NULL, 
		DWORD dwFlags = OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, 
		LPCTSTR lpszFilter = NULL, 
		CWnd* pParentWnd = NULL );
	*/

    /*
	if (!CurrTxfoIsSaveable())
	{
		MessageBox("The transformer is not properly defined", "Error");
		return;
	}

	CFileDialog newDlog(false, "inp", NULL,
		OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT,
		"Andersen Input Files (*.inp)|*.inp|Text Files (*.txt)|*.txt||");


	if (newDlog.DoModal() == IDOK)
		SaveAndersenFile(newDlog.GetPathName());
	*/
}

bool CMainFrame::CurrTxfoIsSaveable()
{
	ValidError = NO_VALID_ERROR;

	if (!m_CurrTxfoIsValid)
	{
		ValidError = TXFO_NOT_VALID_ERROR;
		return false;
	}

	if (m_CurrentTxfo.m_NumTerminals == 0)
	{
		ValidError = TERMS_UNDEFINED_ERROR;
		return false;
	}

	if (!m_CurrentTxfo.TerminalsHaveWindings())
	{
		ValidError = WDG_MISSING_ERROR;
		return false;
	}

	ValidError = VerifyTransformer();

	return true;
}

void CMainFrame::SaveAndersenFile(CString& wFilePath, Transformer* wTxfo)
{

		CStdioFile newFile(
			wFilePath, 
			CFile::modeCreate |
			CFile::modeWrite |
			CFile::shareExclusive |
			CFile::typeText);

		if (wTxfo == NULL)
			wTxfo = &m_CurrentTxfo;
		
		// Line 1
		CString nLine = wTxfo->m_Description;
		nLine += "\n";
		newFile.WriteString(nLine);

		// take care of Andersen bug
		double zOffset = 0.0;
		if (wTxfo->m_LowerZ > 4.5)
			zOffset = wTxfo->m_LowerZ - 4.5;

		// Line 2
		nLine = string_format("%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.3f%-10.3f%-10.3f\n",
			2, // always in inches
			wTxfo->m_NumPhases, 
			wTxfo->m_Frequency,
			wTxfo->m_NumWoundLimbs,
			1, // always full height
			-wTxfo->m_LowerZ + zOffset,
			wTxfo->m_Core.m_WindowHeight - wTxfo->m_LowerZ + zOffset,
			wTxfo->m_Core.m_Diameter
			);
		newFile.WriteString(nLine);

		// Line 3
		nLine = string_format("%-10.3f%-10.1d%-10.3f%-10.3f%-10.3f%-10.1d%-10.1d\n",
			wTxfo->m_InnerClearance,
			0, // AL/CU shield
			wTxfo->m_SystemGVA,
			wTxfo->m_puImpedance, // Optional Per Unit Impedance
			wTxfo->m_PeakFactor,
			wTxfo->m_NumTerminals,
			wTxfo->CountLayers()
			);
		newFile.WriteString(nLine);

		// Line 4
		nLine = string_format("%-10.1d%-10.3f%-10.3f%-10.3f%-10.3f%-10.1d%-10.1d\n",
			wTxfo->m_OffsetElongation, // displacement/elongation
			wTxfo->m_OffElongValue, // amount
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


}

void CMainFrame::OnAndersenAndersendirectory() 
{
	// TODO: Add your command handler code here

	/*
		CFileDialog( 
			BOOL bOpenFileDialog, 
			LPCTSTR lpszDefExt = NULL, 
			LPCTSTR lpszFileName = NULL, 
			DWORD dwFlags = OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, 
			LPCTSTR lpszFilter = NULL, 
			CWnd* pParentWnd = NULL );
	*/

    /*
	CFileDialog newDlog(TRUE);

	if (newDlog.DoModal() == IDOK)
	{
		// user chose a file in FLD12, back up one level for the path name
		CString pathName = newDlog.GetPathName();
		CString fileName = newDlog.GetFileName();

		pathName.Delete(pathName.GetLength() - fileName.GetLength() - 1, 
			fileName.GetLength() + 1);

		int pos = pathName.ReverseFind('\\');

		pathName.Delete(pos + 1, pathName.GetLength() - pos - 1); // keep the '\'
		
		bool testPath = m_AndersenFolder.AndersenFolderNameIsValid(&pathName);

		if (testPath == false)
		{
			MessageBox("This is not a valid Andersen program directory",
				"ERROR - ANDERSEN NOT PRESENT");
		}
		else
		{
			CWinApp* pApp = AfxGetApp();

			pApp->WriteProfileString("", "Andersen Path", pathName);

			m_AndersenFolder.WriteAndersenFolderName(&pathName);

		}

	}
	*/
}


int CMainFrame::VerifyTransformer(Transformer *wTxfo)
{
	if (wTxfo == NULL)
	{
		wTxfo = &m_CurrentTxfo;
	}

	return wTxfo->VerifyTransformer();
}

void CMainFrame::OnAndersenRunandersenprogram() 
{
	// TODO: Add your command handler code here

	COffsetElongation dlog1;

	if (dlog1.DoModal())
	{
		m_CurrentTxfo.m_OffsetElongation = dlog1.m_Operation;

		if (dlog1.m_Operation == 0)
			m_CurrentTxfo.m_OffElongValue = 0.0;
		else if (dlog1.m_FindMaxValue == 1)
			m_CurrentTxfo.m_OffElongValue = dlog1.m_ForceValue;
		else
			m_CurrentTxfo.m_OffElongValue = 0.0;

		if (dlog1.m_ImpUseCalc == 0)
		{
			m_CurrentTxfo.m_puImpedance = 0.0;
			m_CurrentTxfo.m_Impedance[2] = m_CurrentTxfo.m_Impedance[0];
		}
		else
		{
			m_CurrentTxfo.m_puImpedance = dlog1.m_ImpUseThis / 100.0;
			m_CurrentTxfo.m_Impedance[2] = m_CurrentTxfo.m_puImpedance * 100.0;
		}

	}
	
	int chkTxfo = VerifyTransformer(); // nominal tap

	if (chkTxfo == NO_TXFO_ERROR)
	{
		// create a dummy file in the FLD12 directory

		CString longFileName;

		m_AndersenFolder.ReadAndersenFolderName(&longFileName);
			
		longFileName += "FLD12\\INP1.FIL";

		SaveAndersenFile(longFileName);

        /*
		int fRes = MessageBox("Do you wish to save the output file from the Andersen program?",
			"Save Andersen File", MB_YESNO);

		CString fOutName;

		if (fRes == IDYES)
		{
			CFileDialog newDlog(false, "out", NULL,
				OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT,
				"Andersen Output Files (*.out)|*.out||");

			if (newDlog.DoModal() == IDOK)
				fOutName = newDlog.GetPathName();
			else
				fRes = IDNO;
			
		}

		// m_tApp->m_StartInp1to2->SetEvent();

		// m_CurrentTxfo.GetOutputData();

		DoSerialAndersen();

		m_AndersenFolder.ReadAndersenFolderName(&longFileName);
		longFileName += "FLD12\\OUTPUT";
		AddTiltingDataToFile(longFileName);

		if (fRes == IDYES)
		{			
			SaveFld12OutputAs(fOutName);
		}

		*/

	}
	else 
	{
		HandleVerificationError(chkTxfo);
	}

}

void CMainFrame::HandleVerificationError(int wErr)
{
	CString ErrString;
	CString ErrCaption;

	if (wErr == NO_TXFO_ERROR)
	{
		ErrString = "No error has occurred (interesting, huh?)";
		ErrCaption = "Situation Normal";
	}
	else if (wErr == AMPTURNS_ERROR)
	{
		ErrString = "The ampere-turns of this transformer are incorrect";
		ErrCaption = "Ampere-turns ERROR";
	}
	else if ((wErr > TERM1_TURNS_ERROR) && (wErr <= TERM6_TURNS_ERROR)) 
	{
		ErrString = string_format("The Volts-per-Turn of Terminal %d do not match Terminal 1",
			wErr - TERM1_TURNS_ERROR + 2);
		ErrCaption = "Volts-per-Turn ERROR";
	}
	else if (wErr == WDG1_TOOSMALL_ERROR)
	{
		ErrString = "The inner diameter of winding 1 is smaller than the core diameter";
		ErrCaption = "Winding diameter ERROR";
	}
	else if ((wErr >= WDG2_TOOSMALL_ERROR) && (wErr <= WDG10_TOOSMALL_ERROR)) 
	{
		ErrString = string_format("The inner diameter of winding %d is smaller than the outer diameter of winding %d",
			wErr - WDG1_TOOSMALL_ERROR + 2, wErr - WDG1_TOOSMALL_ERROR + 1);
		ErrCaption = "Winding diameter ERROR";
	}

	// MessageBox(ErrString, ErrCaption);
}

void CMainFrame::OnOptionsModifywindings() 
{
	// TODO: Add your command handler code here

	HandleModifyWindings();
	
}

void CMainFrame::HandleModifyWindings(int wWinding, int dum2)
{
	WindModNumberDlog newDlog;

	newDlog.m_NumWindings = m_CurrentTxfo.NumWindings();
	// newDlog.m_wWinding = wWinding;

	if (newDlog.DoModal() == IDOK)
	{
		AddWinding(m_CurrentTxfo.NumberToPointer(wWinding + 1));
	}
}




void CMainFrame::OnWdgMovewinding() 
{
	// TODO: Add your command handler code here

	CMoveWdgDlog newDlog;

	if (newDlog.DoModal() == IDOK)
	{
        /*
		m_wndView.m_RBOverWdg->OffsetZ(newDlog.m_VertOffset);
		m_wndView.m_RBOverWdg->OffsetX(newDlog.m_HorOffset, newDlog.m_MoveOuterWdgs);

		m_wndView.HandleTxfoChanges();
         */
	}
	
}

void CMainFrame::OnWdgRegulatingwinding() 
{
	// TODO: Add your command handler code here

	CRegWdgDlog newDlog;
	
	// newDlog.m_AxialGap = m_wndView.m_RBOverWdg->m_BetweenSections;

	if (newDlog.DoModal() == IDOK)
	{
        /*
		m_wndView.m_RBOverWdg->DefineRegulatingWdg(
			newDlog.m_NumLoops, 
			newDlog.m_AxialGap,
			newDlog.m_IsDoubleAxial,
			newDlog.m_IsMultiStart);

		m_wndView.HandleTxfoChanges();
         */
	}
	
}

void CMainFrame::OnWdgSplitsegment() 
{
	// TODO: Add your command handler code here

	CSplitSegmentDlog newDlog;

	if (newDlog.DoModal() == IDOK)
	{
        /*
		m_wndView.m_RBOverSegment->SplitSegment(newDlog.m_NumSegs, newDlog.m_BetweenSegs);

		m_wndView.HandleTxfoChanges();
         */
	}
	
}

void CMainFrame::OnSetvnreference() 
{
	// TODO: Add your command handler code here

    /*
	m_CurrentTxfo.m_VperNTerminal = m_wndView.m_RBOverTerm;
	m_wndView.HandleTxfoChanges();
     */
	
}

void CMainFrame::OnWdgActivate() 
{
	// TODO: Add your command handler code here

    /*
	m_wndView.m_RBOverSegment->m_NumTurnsActive = m_wndView.m_RBOverSegment->m_NumTurnsTotal;

	Segment* mateSeg = NULL;

	if (m_wndView.m_RBOverWdg->m_IsDoubleStack)
	{
		mateSeg = m_wndView.m_RBOverWdg->GetMateSegment(m_wndView.m_RBOverLayer, m_wndView.m_RBOverSegment);

		if (mateSeg != NULL)
			mateSeg->m_NumTurnsActive = mateSeg->m_NumTurnsTotal;
	}
		else if (m_wndView.m_RBOverWdg->m_IsMultiStart)
	{
		int i;
		int count = 0;

		Segment* nSegment = m_wndView.m_RBOverSegment;
		i = nSegment->GetSegmentPosition(m_wndView.m_RBOverLayer->m_SegmentHead);

		i %= m_wndView.m_RBOverWdg->m_NumLoops;
		if (i == 0)
			i = m_wndView.m_RBOverWdg->m_NumLoops;

		nSegment = m_wndView.m_RBOverLayer->m_SegmentHead;
		for (count = 1; count <= m_wndView.m_RBOverWdg->m_TotalTurns &&
					    nSegment != NULL; count++)
		{
			if (count == i)
			{
				nSegment->m_NumTurnsActive = nSegment->m_NumTurnsTotal;
				i += m_wndView.m_RBOverWdg->m_NumLoops;
			}

			nSegment = nSegment->m_Next;
		}
	}


	m_wndView.HandleTxfoChanges();	
     */
}

void CMainFrame::OnWdgDeactivate() 
{
	// TODO: Add your command handler code here

    /*
	m_wndView.m_RBOverSegment->m_NumTurnsActive = 0;

	Segment* mateSeg = NULL;

	if (m_wndView.m_RBOverWdg->m_IsDoubleStack)
	{
		mateSeg = m_wndView.m_RBOverWdg->GetMateSegment(m_wndView.m_RBOverLayer, m_wndView.m_RBOverSegment);

		if (mateSeg != NULL)
			mateSeg->m_NumTurnsActive = 0;
	}
	else if (m_wndView.m_RBOverWdg->m_IsMultiStart)
	{
		int i;
		int count = 0;

		Segment* nSegment = m_wndView.m_RBOverSegment;
		i = nSegment->GetSegmentPosition(m_wndView.m_RBOverLayer->m_SegmentHead);

		i %= m_wndView.m_RBOverWdg->m_NumLoops;
		if (i == 0)
			i = m_wndView.m_RBOverWdg->m_NumLoops;

		nSegment = m_wndView.m_RBOverLayer->m_SegmentHead;
		for (count = 1; count <= m_wndView.m_RBOverWdg->m_TotalTurns &&
					    nSegment != NULL; count++)
		{
			if (count == i)
			{
				nSegment->m_NumTurnsActive = 0;
				i += m_wndView.m_RBOverWdg->m_NumLoops;
			}

			nSegment = nSegment->m_Next;
		}
	}

	m_wndView.HandleTxfoChanges();

     */
}



void CMainFrame::HandleTxfoChange()
{
    /*
	m_wndView.HandleTxfoChanges();
     */

}

void CMainFrame::OnFileOpenfile() 
{
	// TODO: Add your command handler code here


	/*
		CFileDialog( 
		BOOL bOpenFileDialog, 
		LPCTSTR lpszDefExt = NULL, 
		LPCTSTR lpszFileName = NULL, 
		DWORD dwFlags = OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, 
		LPCTSTR lpszFilter = NULL, 
		CWnd* pParentWnd = NULL );
	*/

    /*
     
	CFileDialog newDlog1(true, "txt", NULL,
		OFN_HIDEREADONLY,
		"Text Files (*.txt)|*.txt|Andersen Input Files (*.inp)|*.inp||");

	if (newDlog1.DoModal() == IDOK)
	{
		if (newDlog1.GetFileExt() == "inp")
		{
			MessageBox("Not yet able to input Andersen input files", "WHOA!");
			return;
		}
		else // must be a '.txt' file
		{
			if (!ReadTextFile(newDlog1.GetPathName()))
			{
				MessageBox("That is not a valid file to use for this program", "Hey!");
				return;
			}

			m_tApp->m_RecentFiles->Add(newDlog1.GetPathName());

			SetWindowText(newDlog1.GetPathName());

			m_wndView.HandleTxfoChanges();
		}
	}
	
     */
}

bool CMainFrame::ReadTextFile(CString wPath)
{
	CExcelTextFile theFile(wPath, CFile::modeRead | CFile::typeText);

	Transformer *newTxfo = new Transformer;

	int readResult = theFile.InputFile(newTxfo);

	if (readResult != NO_ERROR)
	{
		// error, eventually decode the error code - for now just return false
		delete newTxfo;
		return false;
	}

	m_CurrentTxfo.InitializeTxfo();

	// save newTxfo into m_CurrTxfo

	m_CurrentTxfo = *newTxfo;
	m_CurrTxfoIsValid = true;
	m_CurrentTxfo.m_IsValid = true;
	m_CurrentTxfo.m_DefaultFolder = &m_AndersenFolder;

	newTxfo->ClearPointers();
	delete newTxfo;

	return true;
}





void CMainFrame::OnModifyterminal() 
{
	// TODO: Add your command handler code here

	// Terminal *aTerm = m_CurrentTxfo.GetTermHead();
/*
	while (aTerm->m_Number != m_wndView.m_RBOverTerm)
		aTerm = aTerm->GetNext();

	AddTermDlog newDlog(true, aTerm);

	if (newDlog.DoModal() == IDOK)
	{
		aTerm->m_Connection = newDlog.m_Connection;
		aTerm->m_KV = newDlog.m_Voltage;
		aTerm->m_MVA = newDlog.m_MVA;
		aTerm->m_Name = newDlog.m_Name;
	}

	m_wndView.HandleTxfoChanges();	
 */
}

void CMainFrame::OnWdgCenterwinding() 
{
	// TODO: Add your command handler code here
/*
	m_wndStatusBar.SetWindowText(_T("Select the winding to center on ..."));

	m_wndView.m_WdgToMove = m_wndView.m_RBOverWdg;
//	m_wndView.m_SelectWdgFlag = true;


	m_wndView.PostMessage(WM_PH_SELECTWDG);
 */
}





void CMainFrame::OnClose() 
{
	// TODO: Add your message handler code here and/or call default

	InitializeTxfo();

	m_tApp->CleanUpPointers();

	// CFrameWnd::OnClose();
}

double CMainFrame::GetTransformerImpedance(bool wUpdate)
{
	if (!m_CurrTxfoIsValid)
		return 0.0;
	
	return *(m_CurrentTxfo.GetTransformerImpedance(wUpdate));
}


uint SaveOutputAs(void* pathName)
{
	// CAndersenFEApp* wApp = (CAndersenFEApp*)AfxGetApp();
	// CSingleLock wLock((CSyncObject*)wApp->m_StartSaveOutput, true);

	TRACE("Starting SaveOutputAs\n");
	CString inName;
	CString outName;
    CString *pName = (CString *)pathName;

	int brk = (int)pName->find('|');
    
	outName = pName->substr(brk+1, pName->size() - brk - 1);
    
	inName = pName->substr(0,brk);

	// wApp->m_UseFld12Output->Lock();

	CStdioFile inFile(inName, CFile::modeRead | CFile::typeText);
	CStdioFile outFile(outName, CFile::modeCreate | CFile::modeWrite | CFile::typeText);

	CString wLine;

	while (inFile.ReadString(wLine))
	{
		wLine += '\n';
		outFile.WriteString(wLine);
	}

	// get rid of the pointer that was created for the parameter
	
	delete pName;

	// wApp->m_UseFld12Output->Unlock();

	TRACE("Done SaveOutputAs\n");

	// wApp->m_StartSaveOutput->ResetEvent();
	
	return 0;
}

void CMainFrame::OnDestroy() 
{
	InitializeTxfo();

	m_tApp->CleanUpPointers();

	// CFrameWnd::OnDestroy();
	

	// TODO: Add your message handler code here
	
}



void CMainFrame::DoSerialAndersen(bool useCurrentTxfo)
{
/*
	m_tApp->m_AndersenRunning = true;
	SetCursor(m_tApp->LoadStandardCursor(IDC_WAIT));
	
	CString sFile, sDirectory;
	m_AndersenFolder.ReadAndersenFolderName(&sFile);
	sFile += "FLD12\\";
	sDirectory = sFile;
	sFile += "RUN_AFE.BAT";

	m_tApp->m_UseFld12Output->WriteLock();

	SHELLEXECUTEINFO ShExecInfo = {0};
	ShExecInfo.cbSize = sizeof(SHELLEXECUTEINFO);
	ShExecInfo.fMask = SEE_MASK_NOCLOSEPROCESS;
	ShExecInfo.hwnd = this->m_hWnd;
	ShExecInfo.lpVerb = "open";
	ShExecInfo.lpFile = sFile;		
	ShExecInfo.lpParameters = "";	
	ShExecInfo.lpDirectory = sDirectory;
	ShExecInfo.nShow = SW_SHOW;
	ShExecInfo.hInstApp = NULL;	
	BOOL tst = ShellExecuteEx(&ShExecInfo);
	int instCode = (int)ShExecInfo.hInstApp;
	HANDLE tstHdle = ShExecInfo.hProcess;
	if (tst == 0)
	{
		DWORD err = GetLastError();
		TRACE("Error was %d\n", err);
		return;
	}
	DWORD res = WaitForSingleObject(ShExecInfo.hProcess, 25000);

	m_tApp->m_UseFld12Output->Unlock();
	m_tApp->m_AndersenRunning = false;

	if (res != WAIT_OBJECT_0)
	{
		// must have timed out

		MessageBox("Could not run the Andersen programs!!");
		return;
	}

	if (useCurrentTxfo)
	{
		OnUpdateAndersenFields((WPARAM)0, (LPARAM)0);
		m_CurrentTxfo.m_AndersenOutputIsValid = true;
	}
 */
	
}

void CMainFrame::OnRunandersenprogram() 
{
	// TODO: Add your command handler code here

	OnAndersenRunandersenprogram();
	
}



void CMainFrame::OnChangetoonaf() 
{
	// TODO: Add your command handler code here

	Terminal* nextTerm = m_CurrentTxfo.GetTermHead();
	double wFactor = m_CurrentTxfo.m_SecondFanStage / 100;

	while (nextTerm != NULL)
	{
		nextTerm->m_MVA *= wFactor;
		nextTerm = nextTerm->GetNext();
	}

	// m_wndView.HandleTxfoChanges();
}

void CMainFrame::OnAndersenRunandersenalltaps() 
{
	// TODO: Add your command handler code here

	CAllTapsDialog newDlog;

	if (newDlog.DoModal() == IDOK)
	{

		CString fOutName, defName, oldWndName;

		//GetWindowText(defName);
		oldWndName = defName;

        
		//defName = defName.Left(defName.GetLength() - 4);
        defName = defName.substr(0, defName.size() - 4);
        
		int wPos = (int)defName.find_last_not_of('\\');
		// defName = defName.Right(defName.GetLength() - wPos - 1);
        defName = defName.substr(wPos, defName.length() - wPos);
		
/*
		CFileDialog* newDlog2 = new CFileDialog(false, "out", defName,
			OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT,
			"Andersen Output Files (*.out)|*.out||", this);

		newDlog2->m_ofn.lpstrTitle = "Save multiple files as ...";

		if (newDlog2->DoModal() == IDOK)
			fOutName = newDlog2->GetPathName();
		else
			return;

		delete newDlog2;
		
		m_wndView.UpdateWindow(); // to get rid of the CFileDialog
*/
		CRunningMessageDlog newDlog3;
		// newDlog3.m_ShowText = "Offload =, Onload =";
		// newDlog3.ShowWindow(SW_SHOW);

		//fOutName = fOutName.Left(fOutName.GetLength() - 4);
        fOutName = fOutName.substr(0, fOutName.size() - 4);

		if (fOutName[fOutName.size() - 1] != '_')
			fOutName += "_";

		Transformer* tmpTxfo = new Transformer(m_CurrentTxfo);

		int numOffLoadTaps;
		if (newDlog.m_OffLoad)
		{
			// find offload tapping winding
			Winding* nWdg = tmpTxfo->GetWdgHead();
			while (nWdg != NULL)
			{
				if (nWdg->m_NumTapSteps != 0)
					break;

				nWdg = nWdg->GetNext();
			}

			if (nWdg == NULL)
				numOffLoadTaps = 1;
			else
				numOffLoadTaps = nWdg->m_NumTapSteps + 1;
		}
		else
		{
			numOffLoadTaps = 1;
		}

		int i;
		int numOnLoadTaps = 1;
		for (i=0; i<numOffLoadTaps; i++)
		{
			Winding* regWdg = NULL;

			if (newDlog.m_OnLoad) // regulating winding
			{
				regWdg = tmpTxfo->GetWdgHead();
				while (regWdg != NULL)
				{
					if (regWdg->m_IsRegWdg)
						break;

					regWdg = regWdg->GetNext();
				}

				
				if (regWdg != NULL)
				{
					// set the turns to maximum
					regWdg->SetMaximumEffectiveTurns(tmpTxfo->GetWdgHead());
					numOnLoadTaps = regWdg->CountRegWdgTapPositions();
				}	
			}

			CString longFileName1, longFileName2;

			m_AndersenFolder.ReadAndersenFolderName(&longFileName1);	
			longFileName1 += "FLD12\\INP1.FIL";

			m_AndersenFolder.ReadAndersenFolderName(&longFileName2);
			longFileName2 += "FLD12\\OUTPUT";

			int j;
			for (j=0; j<numOnLoadTaps; j++)
			{
				// create a dummy file in the FLD12 directory

				if (j == int(numOnLoadTaps / 2 + 1))
				{
					regWdg->ReverseCurrent();
				}

				VerifyTransformer(tmpTxfo);

				CString dumText;
				
				// tmpTxfo->m_Description =  string_format("%s Offload=%d, Onload=%d",newDlog.m_Description, i+1, j+1);

				SaveAndersenFile(longFileName1, tmpTxfo);

				// dumText.Format("%sOffLoad%d_OnLoad%d.out",fOutName, i+1, j+1);
				// SetWindowText(dumText);

				DoSerialAndersen(false);

				// dumText.Format("%sOffLoad%d_OnLoad%d.out",fOutName, i+1, j+1);

				// m_tApp->m_UseFld12Output->Lock();

				CStdioFile* inFile = NULL;
				CStdioFile* outFile = NULL;

				
					inFile = new CStdioFile(longFileName2, 
						CFile::modeRead | CFile::typeText);
				

				
					outFile = new CStdioFile(dumText, 
						CFile::modeCreate | CFile::modeWrite | CFile::typeText);
				

				CString wLine;

				while (inFile->ReadString(wLine))
				{
					wLine += '\n';
					outFile->WriteString(wLine);
				}

				// may need to put next two lines into a try-catch block
				delete inFile;
				delete outFile;

				// m_tApp->m_UseFld12Output->Unlock();

				AddTiltingDataToFile(dumText, tmpTxfo);

				regWdg->ReduceRegWdgOneStep(j+1);

			}
		}
		
		delete tmpTxfo;

		// SetWindowText(oldWndName);
	}
}




void CMainFrame::AddTiltingDataToFile(CString &wFileName, Transformer *wTxfo)
{

	if (wTxfo == NULL)
	{
		wTxfo = &m_CurrentTxfo;
		// m_tApp->m_UseFld12Output->Lock(false);
	}



	CString tmpFileName = wFileName + "_TMP";
	CStdioFile* inFile;
	CStdioFile* outFile;
	CString nLine, wFindString1, wFindString2;
	int wPos;
	double critLoad = 0.0;
	Layer* tmpLayer;
	bool doneSegments = false;

		inFile = new CStdioFile(wFileName, CFile::modeRead | CFile::typeText);
		outFile = new CStdioFile(tmpFileName, CFile::modeCreate | 
			CFile::modeWrite | CFile::typeText);

		wFindString1 = "BENDING+TENS./COMPR.";
		wFindString2 = "CRITICAL STRESSES";
		int numFound = 0;
		doneSegments = false;
		while (inFile->ReadString(nLine))
		{
			nLine += '\n';
			outFile->WriteString(nLine);
			if (nLine.find(wFindString2) != std::string::npos)
				doneSegments = true;
			if ((wPos = nLine.find(wFindString1) != std::string::npos) && (!doneSegments))
			{
				critLoad = 0.0;
				numFound++;
				tmpLayer = wTxfo->GetLayerFromSegmentNumber(numFound);
				if (tmpLayer != NULL)
				{
					critLoad = tmpLayer->CalculateRadialSurfaceArea() * tmpLayer->CriticalTiltingStress();

				}
				nLine =  string_format("CRITICAL AXIAL LOAD %10.1f\n", critLoad);
				outFile->WriteString(nLine);
			}
		}

		delete inFile;
		delete outFile;

		CFile::Remove(wFileName);
		CFile::Rename(tmpFileName, wFileName);

		// m_tApp->m_UseFld12Output->Unlock();
	
}

void CMainFrame::SaveFld12OutputAs(CString &wFileName)
{
	CString inName;
	m_AndersenFolder.ReadAndersenFolderName(&inName);
	inName += "FLD12\\OUTPUT";

	CStdioFile* inFile;
	CStdioFile* outFile;

	
		// m_tApp->m_UseFld12Output->Lock();

		inFile = new CStdioFile(inName, CFile::modeRead | CFile::typeText);
		outFile = new CStdioFile(wFileName, CFile::modeCreate | 
			CFile::modeWrite | CFile::typeText);

		CString wLine;
		while (inFile->ReadString(wLine))
		{
			wLine += '\n';
			outFile->WriteString(wLine);
		}

		delete inFile;
		delete outFile;

		// m_tApp->m_UseFld12Output->Unlock();
	

}



void CMainFrame::OnMRUFile1()
{
	OpenMRUFile(0);
}

void CMainFrame::OnMRUFile2()
{
	OpenMRUFile(1);
}

void CMainFrame::OnMRUFile3()
{
	OpenMRUFile(2);
}

void CMainFrame::OnMRUFile4()
{
	OpenMRUFile(3);
}

void CMainFrame::OnMRUFile5()
{
	OpenMRUFile(4);
}

void CMainFrame::OnMRUFile6()
{
	OpenMRUFile(5);
}

void CMainFrame::OnMRUFile7()
{
	OpenMRUFile(6);
}

void CMainFrame::OnMRUFile8()
{
	OpenMRUFile(7);
}

void CMainFrame::OpenMRUFile(int nIndex)
{
    /*
	CString pathName = (*(m_tApp->m_RecentFiles))[nIndex];

	if (!ReadTextFile(pathName))
	{
		MessageBox("Cannot open the file!");
		m_tApp->m_RecentFiles->Remove(nIndex);
	}
	else
	// put the name back in the list to force it to the top
	{
		m_tApp->m_RecentFiles->Add(pathName);

		SetWindowText(pathName);

		m_wndView.HandleTxfoChanges();
	}
     */
}



void CMainFrame::OnEditUndo() 
{
	// TODO: Add your command handler code here

	// consider putting in a Redo command someday, in which case don't actually delete the
	// head of the list as we are doing now

	Transformer* newTxfo = m_TxfoUndoList->GetNext();
	m_TxfoUndoList->ClearPointers();
	delete m_TxfoUndoList;
	
	m_TxfoUndoList = newTxfo->GetNext();
	if (m_TxfoUndoList != NULL)
		m_TxfoUndoList->SetPrev(NULL);
	m_NumUndoTxfos -= 2;

	m_CurrentTxfo.InitializeTxfo();

	// save newTxfo into m_CurrTxfo

	m_CurrentTxfo = *newTxfo;
	m_CurrTxfoIsValid = true;
	m_CurrentTxfo.m_IsValid = true;
	m_CurrentTxfo.m_DefaultFolder = &m_AndersenFolder;

	// since the call to HandleTxfoChange() will put the current txfo back on top
	// of the list, get rid of it
	newTxfo->ClearPointers();
	delete newTxfo;

	HandleTxfoChange();
	
}

void CMainFrame::OnCalculatemva() 
{
	// TODO: Add your command handler code here

	int wTerm = 0; // = m_wndView.m_RBOverTerm;
	int i;
	double ampTurns = 0.0;

	for (i=1; i<=m_CurrentTxfo.m_NumTerminals; i++)
	{
		if (i != wTerm)
			ampTurns += m_CurrentTxfo.AmpTurns(i);
	}

	double wTurns = m_CurrentTxfo.GetActiveTurns(wTerm);
	double ampsRequired = ampTurns / wTurns;

	Terminal *aTerm = m_CurrentTxfo.GetTermHead();

    /*
	while (aTerm->m_Number != m_wndView.m_RBOverTerm)
		aTerm = aTerm->GetNext();
*/
	aTerm->m_MVA = -(sqrt((double)(m_CurrentTxfo.m_NumPhases) * aTerm->m_KV * ampsRequired / 1000.0));
	

	HandleTxfoChange();
	
}

void CMainFrame::OnAndersenShowfluxlines() 
{
	// TODO: Add your command handler code here

	if (m_ShowFluxLines)
	{
		DeleteFluxData();
		// m_wndView.m_FluxListHead = NULL;
		// m_wndView.InvalidateRect(m_wndView.m_CCRect);
		return;
	}

	// open the file that we are going to read in
	CStdioFile theFile;
	CString filName;
	m_AndersenFolder.ReadAndersenFolderName(&filName);
	filName += _T("GRAPHICS\\BAS.FIL");

	bool openError = theFile.Open(filName, CFile::modeRead | CFile::typeText);

	if (openError == false)
	{
		// MessageBox("Couldn't open Graphics\bas.fil");
		return;
	}
		
	CString inString;
	theFile.ReadString(inString); // discard the first blank line
	
	ExtractNextNumber(theFile, inString); // N
	ExtractNextNumber(theFile, inString); // ITIC
	ExtractNextNumber(theFile, inString); // LNVER
	int LNVER = stoi(inString);
	ExtractNextNumber(theFile, inString); // LNHOR
	int LNHOR = stoi(inString);
	ExtractNextNumber(theFile, inString); // SCALE
	ExtractNextNumber(theFile, inString); // PERCV
	ExtractNextNumber(theFile, inString); // XMAX
	double xMax = stod(inString);
	ExtractNextNumber(theFile, inString); // YMAX
	double yMax = stod(inString);

	DeleteFluxData();
	// topmost node is a single-element list holding the max dimensions for scaling
	m_FluxLines = new CFluxLines(xMax, yMax);
	CFluxLines* lastHead = m_FluxLines;

	// discard ticmark data
	int i;
	for (i=0; i<LNVER+LNHOR; i++)
		ExtractNextNumber(theFile, inString);

	int IPNTS;
	int ICOL;

	// primimg read
	ExtractNextNumber(theFile, inString); // IPNTS
	IPNTS = stoi(inString);
	ExtractNextNumber(theFile, inString); // ICOL
	ICOL = stoi(inString);

	while (IPNTS != 0)
	{
		// only ICOL = 4 interests us
		if (ICOL == 4)
		{
			lastHead->AddHead(new CFluxLines);
			CFluxLines* lastNode = lastHead->NextHead();
			lastHead = lastNode;

			for (i=0; i<IPNTS; i++)
			// the first IPNTS values are X values
			{
				ExtractNextNumber(theFile, inString); // x-values
				lastNode->SetX(stof(inString));
				if (i != IPNTS - 1)
				{
					lastNode->SetNext(new CFluxLines);
				}

				lastNode = lastNode->Next();
			}

			lastNode = lastHead;
			for (i=0; i<IPNTS; i++)
			// the last IPNTS values are Y values
			{
				ExtractNextNumber(theFile, inString); // y-values
				lastNode->SetY(stof(inString));
				lastNode = lastNode->Next();
			}
		}
		else
		// throw away everything else
		{
			for (i=0; i<IPNTS*2; i++)
				ExtractNextNumber(theFile, inString);
		}

		ExtractNextNumber(theFile, inString); // IPNTS
		IPNTS = stoi(inString);
		ExtractNextNumber(theFile, inString); // ICOL
		ICOL = stoi(inString);
	}
	
	// m_wndView.m_FluxListHead = m_FluxLines;
	// m_wndView.InvalidateRect(m_wndView.m_CCRect);
	m_ShowFluxLines = true;
}



void CMainFrame::ExtractNextNumber(CStdioFile &wFile, CString &wString)
{
	wString = "";

	char a = ' ';
	uint readResult;

	while ((a != '.') && ((a < '0') || (a > '9')))
	{
		readResult = wFile.Read(&a, 1);
		if (readResult < 1)
		{
			// MessageBox("Reached EOF when reading BAS.FIL (top loop)");
			return;
		}
	}

	while ((a == '.') || ((a >= '0') && (a <= '9')))
	{
		wString += a;

		readResult = wFile.Read(&a, 1);
		if (readResult < 1)
		{
			// MessageBox("Reached EOF when reading BAS.FIL (bottom loop)");
			return;
		}
	}

}

void CMainFrame::DeleteFluxData()
{
	m_ShowFluxLines = false;

	if (m_FluxLines == NULL)
		return;

	CFluxLines* nextHead = m_FluxLines->NextHead();

	while (m_FluxLines != NULL)
	{
		delete m_FluxLines;
		m_FluxLines = nextHead;

		if (m_FluxLines != NULL)
			nextHead = m_FluxLines->NextHead();
	}

	m_FluxLines = NULL;

}

void CMainFrame::OnWdgCreateparallellayer()
{
	// TODO: Add your command handler code here

	/*
	if (newDlog.DoModal() == IDOK)
	{
	m_wndView.m_RBOverWdg->OffsetZ(newDlog.m_VertOffset);
	m_wndView.m_RBOverWdg->OffsetX(newDlog.m_HorOffset, newDlog.m_MoveOuterWdgs);

	m_wndView.HandleTxfoChanges();
	}
	*/
/*
	if (MessageBox(_T("This operation will cause the selected layer to be split into two parallel-connected winding sections. Are you sure you want to continue?"), 
		_T("Create parallel layer"), 
		MB_OKCANCEL) == IDOK)
	{
		m_wndView.m_RBOverLayer->SetLayerAsParallel();
		m_wndView.HandleTxfoChanges();
	}
 */
}

void CMainFrame::OnWdgSplitSegCustom()
{
	// TODO: Add your command handler code here
	
	CSplitCustomDlog newDlog; 

	if (newDlog.DoModal() == IDOK)
	{
		// m_wndView.m_RBOverSegment->SplitSegmentCustom(newDlog.m_Z, newDlog.m_Gap, newDlog.m_NumTurns);

		// m_wndView.HandleTxfoChanges();
	}
	
}

void CMainFrame::OnWdgChangesegmentdata()
{
	// TODO: Add your command handler code here

	CChangeSegmentDlog dlog;
	Segment* aSegment = NULL; // = m_wndView.m_RBOverSegment;

	dlog.m_StrandsPerTurn = aSegment->m_NumStrandsPerTurn;
	dlog.m_StrandsRadially = aSegment->m_NumStrandsPerLayer;
	dlog.m_StrandA = aSegment->m_StrandA;
	dlog.m_StrandR = aSegment->m_StrandR;

	if (dlog.DoModal() == IDOK)
	{
		aSegment->m_NumStrandsPerTurn = dlog.m_StrandsPerTurn;
		aSegment->m_NumStrandsPerLayer = dlog.m_StrandsRadially;
		aSegment->m_StrandA = dlog.m_StrandA;
		aSegment->m_StrandR = dlog.m_StrandR;

		// m_wndView.HandleTxfoChanges();
	}
}
