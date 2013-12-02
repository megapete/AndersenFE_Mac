// ChildView.cpp : implementation of the CChildView class
//

#include "stdafx.h"
#include "AndersenFE.h"
#include "ChildView.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CChildView

CChildView::CChildView()
{
	m_FluxListHead = NULL;
	m_CurrTxfo = NULL;
	m_RBOverTerm = 0;
	m_TermBoxHeight = 0;
	m_ArrowRectHead = NULL;
	m_CoilRectHead = NULL;
	m_SelectWdgFlag = false;

	thinPen[RED_PEN] = new CPen(PS_SOLID, 1, (COLORREF)RED_COLOUR);
	hatchBrush[RED_PEN] = new CBrush(HS_BDIAGONAL, (COLORREF)RED_COLOUR);

	thinPen[GREEN_PEN] = new CPen(PS_SOLID, 1, (COLORREF)GREEN_COLOUR);
	hatchBrush[GREEN_PEN] = new CBrush(HS_BDIAGONAL, (COLORREF)GREEN_COLOUR);

	thinPen[YELLOW_PEN] = new CPen(PS_SOLID, 1, (COLORREF)YELLOW_COLOUR);
	hatchBrush[YELLOW_PEN] = new CBrush(HS_BDIAGONAL, (COLORREF)YELLOW_COLOUR);

	thinPen[BLUE_PEN] = new CPen(PS_SOLID, 1, (COLORREF)BLUE_COLOUR);
	hatchBrush[BLUE_PEN] = new CBrush(HS_BDIAGONAL, (COLORREF)BLUE_COLOUR);

	thinPen[MAGENTA_PEN] = new CPen(PS_SOLID, 1, (COLORREF)MAGENTA_COLOUR);
	hatchBrush[MAGENTA_PEN] = new CBrush(HS_BDIAGONAL, (COLORREF)MAGENTA_COLOUR);

	thinPen[CYAN_PEN] = new CPen(PS_SOLID, 1, (COLORREF)CYAN_COLOUR);
	hatchBrush[CYAN_PEN] = new CBrush(HS_BDIAGONAL, (COLORREF)CYAN_COLOUR);

}

CChildView::~CChildView()
{
	int i;

	for (i=0; i<6; i++)
	{
		delete thinPen[i];
		delete hatchBrush[i];
	}

	if (m_ArrowRectHead != NULL)
	{
		delete m_ArrowRectHead;
		m_ArrowRectHead = NULL;
	}

	if (m_CoilRectHead != NULL)
	{
		delete m_CoilRectHead;
		m_CoilRectHead = NULL;
	}

}


BEGIN_MESSAGE_MAP(CChildView,CWnd )
	//{{AFX_MSG_MAP(CChildView)
	ON_WM_PAINT()
	ON_WM_RBUTTONDOWN()
	ON_WM_LBUTTONDOWN()
	ON_WM_LBUTTONDBLCLK()
	ON_WM_SETCURSOR()
	//}}AFX_MSG_MAP
	// My messages
	ON_MESSAGE(WM_PH_SELECTWDG, OnSelectWdg)
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CChildView message handlers

BOOL CChildView::PreCreateWindow(CREATESTRUCT& cs) 
{
	if (!CWnd::PreCreateWindow(cs))
		return FALSE;

	cs.dwExStyle |= WS_EX_CLIENTEDGE;
	cs.style &= ~WS_BORDER;
	cs.lpszClass = AfxRegisterWndClass(CS_HREDRAW|CS_VREDRAW|CS_DBLCLKS, 
		::LoadCursor(NULL, IDC_ARROW), HBRUSH(COLOR_WINDOW+1), NULL);

	return TRUE;
}

void CChildView::OnPaint() 
{
	CPaintDC dc(this); // device context for painting

	if (m_ArrowRectHead != NULL)
	{
		delete m_ArrowRectHead;
		m_ArrowRectHead = NULL;
	}

	if (m_CoilRectHead != NULL)
	{
		delete m_CoilRectHead;
		m_CoilRectHead = NULL;
	}
	
	// TODO: Add your message handler code here
	// Do not call CWnd::OnPaint() for painting messages

	CFont tnrFont;
	tnrFont.CreatePointFont(90,_T("Times New Roman"));
	LOGFONT childLogFont;
	tnrFont.GetLogFont(&childLogFont);
	childLogFont.lfWeight = FW_BOLD;
	CFont bldTNR;
	bldTNR.CreateFontIndirect(&childLogFont);

	CFont *oldFont = dc.SelectObject(&bldTNR);


	// Show terminal data on the right side of the screen
	this->GetClientRect(&m_TerminalRect);
	m_TerminalRect.left = m_TerminalRect.right - 150;
	m_VperNRect = m_TerminalRect;
	

	CBrush *oldBrush = (CBrush*)dc.SelectStockObject(WHITE_BRUSH);

	CPen* thickBlackPen = new CPen(PS_SOLID, 2, (COLORREF)BLACK_COLOUR);


	dc.SelectObject(thickBlackPen);

	dc.Rectangle(m_TerminalRect);
	int yOffset = m_TerminalRect.Height() / 8;
	m_TermBoxHeight = yOffset;
	m_VperNRect.bottom = yOffset;
	m_VperNRect.OffsetRect(-m_TerminalRect.Width() - 50, 0);
	m_VperNRect.right += 51;

	CRect txtRect = m_TerminalRect + CPoint(0,3);
	
	int i, yPoint = yOffset;

	CString dumText, termName, termMVA, termVolts, termConn;
	txtRect.bottom = yOffset;

	Terminal* nextTerm = NULL;
		
	nextTerm = m_CurrTxfo->GetTermHead(); 

	for (i=0; i<8; i++)
	{
		if (nextTerm != NULL)
		{
			termName = nextTerm->m_Name;
			nextTerm->GetMVAText(termMVA);
			termMVA += " MVA";
			nextTerm->GetKVText(termVolts);
			termVolts += " kV - ";
			nextTerm->GetConnectionText(termConn);

		}
		else
		{
			termName = "";
			termMVA = "";
			termVolts = "";
			termConn = "";
		}

		dumText.Format("Terminal %d\n%s\n%s\n%s%s", i+1, termName, termMVA, termVolts,
			termConn);

		CRect dumRect = txtRect;
		dumRect.bottom = dumRect.top + 20;

		dc.DrawText(dumText, dumRect, DT_CALCRECT);
		dc.DrawText(dumText, txtRect, DT_CENTER);
		dc.MoveTo(m_TerminalRect.left, yPoint);

		if (i != 7)
			dc.LineTo(m_TerminalRect.right, yPoint);


		int lineY = (txtRect.Height() - dumRect.Height()) / 2;
		if (nextTerm != NULL)
		{
			dc.SelectObject(thinPen[i]);
			dc.MoveTo(m_TerminalRect.left + 20, yPoint - lineY);
			dc.LineTo(m_TerminalRect.right - 20, yPoint - lineY);
			dc.SelectObject(thickBlackPen);
		}

		yPoint += yOffset;
		txtRect.OffsetRect(0,yOffset);

		

		if (nextTerm != NULL)
			nextTerm = nextTerm->GetNext();
	}

	// Show the Volts per turn and transformer amp-turns and impedance


	dumText.Format("Volts per Turn\nRef. Terminal: %d\n%.3f V/N\n\nTotal Amp-Turns\n(Must be zero)\n%.1f",
		m_CurrTxfo->m_VperNTerminal,
		m_CurrTxfo->CalcVoltsPerTurn(),
		m_CurrTxfo->AmpTurns()
		);

	txtRect = m_VperNRect;
	m_VperNRect.bottom = m_VperNRect.top + dc.DrawText(dumText, txtRect, DT_CALCRECT) + 6;
	dc.SelectObject(thickBlackPen);
	dc.Rectangle(m_VperNRect);
	dc.MoveTo(m_VperNRect.left, m_VperNRect.bottom / 2);
	dc.LineTo(m_VperNRect.right-1, m_VperNRect.bottom / 2);

	
	txtRect = m_VperNRect + CPoint(0,3);
	dc.DrawText(dumText, txtRect, DT_CENTER);


	bool txfoOk = (m_CurrTxfo->VerifyTransformer() == NO_TXFO_ERROR);
	// Show the transformer impedance

	m_ImpedanceRect = m_VperNRect;
	m_ImpedanceRect.OffsetRect(CPoint(0, m_VperNRect.Height()-1));
	double imped[3] = {0.0, 0.0, 0.0};
	double* impPtr;
	
	if (txfoOk)
	{
		impPtr = m_CurrTxfo->GetTransformerImpedance();
		imped[0] = *impPtr++;
		imped[1] = *impPtr++;
		imped[2] = *impPtr;
		
	}
	dumText.Format("Transformer Impedance\n%.2f%% @ %.3f MVA", imped[0], imped[1]);
	m_ImpedanceRect.bottom = m_ImpedanceRect.top + dc.DrawText(dumText, txtRect, DT_CALCRECT) + 6;
	dc.Rectangle(m_ImpedanceRect);
	txtRect = m_ImpedanceRect + CPoint(0,3);
	dc.DrawText(dumText, txtRect, DT_CENTER);

	// show the impedance used to run the andersen program
	
	m_Impedance2Rect = m_ImpedanceRect;
	m_Impedance2Rect.OffsetRect(CPoint(0, m_ImpedanceRect.Height()-1));

	dumText.Format("Stress Calculation Impedance\n%.2f%% @ %.3f MVA", imped[2], imped[1]);
	m_Impedance2Rect.bottom = m_Impedance2Rect.top + dc.DrawText(dumText, txtRect, DT_CALCRECT) + 6;
	dc.Rectangle(m_Impedance2Rect);
	txtRect = m_Impedance2Rect + CPoint(0,3);
	dc.DrawText(dumText, txtRect, DT_CENTER);

	if (!txfoOk)
	{
		CBrush badBrush(HS_BDIAGONAL, BLACK_COLOUR);
		CBrush* lastBrush = (CBrush*)dc.SelectObject(&badBrush);
		int oldMode = dc.SetBkMode(TRANSPARENT);
		dc.Rectangle(m_VperNRect);
		dc.SetBkMode(oldMode);
		dc.SelectObject(lastBrush);
	}

	m_AndersenRect = m_ImpedanceRect;

	// show the eddy losses
	CRect strayRect = m_Impedance2Rect;
	strayRect.OffsetRect(0, m_Impedance2Rect.Height()-1);
	double eddys[6] = {0.0};
	dumText.Format("Winding Eddy Losses");
	if (txfoOk)
	{
		Terminal* nTerm = m_CurrTxfo->GetTermHead();
		CString dumText2 = "";

		while (nTerm != NULL)
		{
			dumText2.Format("\nTerminal %d: %.1f%%", nTerm->m_Number, nTerm->m_EddyPercent);
			dumText += dumText2;
			nTerm = nTerm->GetNext();
		}
	}
	strayRect.bottom = strayRect.top + dc.DrawText(dumText, txtRect, DT_CALCRECT) + 6;
	dc.Rectangle(strayRect);
	txtRect = strayRect + CPoint(0,3);
	dc.DrawText(dumText, txtRect, DT_CENTER);

	CRect stressRect = strayRect;

	// show the radial stresses
	stressRect.OffsetRect(0, strayRect.Height()-1);
	double hoop = 0.0, comp = 0.0, 
		spBars = 0.0;
	if (txfoOk)
	{
		hoop = m_CurrTxfo->m_MaxHoopStress;
		comp = m_CurrTxfo->m_MaxCompStress; 
		spBars = m_CurrTxfo->m_MinRadSupports;
	}
	dumText.Format("Radial Forces\nMax. Hoop: %.1f\nMax. Comp: %.1f\nMin. Rad. Supports: %.1f", hoop, comp, spBars);
	stressRect.bottom = stressRect.top + dc.DrawText(dumText, txtRect, DT_CALCRECT) + 6;
	dc.Rectangle(stressRect);
	txtRect = stressRect + CPoint(0,3);
	dc.DrawText(dumText, txtRect, DT_CENTER);

	// show the axial stresses
	stressRect.OffsetRect(0, stressRect.Height()-1);
	double axStress = 0.0, combStress = 0.0;
	if (txfoOk)
	{
		axStress = m_CurrTxfo->m_MaxAxialStress;
		combStress = m_CurrTxfo->m_MaxCombinedStress;
	}
	dumText.Format("Axial Forces\nIn Spacer Blocks: %.1f\nCombined: %.1f", axStress, combStress);
	stressRect.bottom = stressRect.top + dc.DrawText(dumText, txtRect, DT_CALCRECT) + 6;
	dc.Rectangle(stressRect);
	txtRect = stressRect + CPoint(0,3);
	dc.DrawText(dumText, txtRect, DT_CENTER);

	
	// Show the end-thrust

	CRect endThrustRect = stressRect;
	endThrustRect.OffsetRect(0, stressRect.Height()-1);
	double topET = 0.0, bottomET = 0.0;
	if (txfoOk)
	{
		topET = m_CurrTxfo->m_TopEndThrust;
		bottomET = m_CurrTxfo->m_BottomEndThrust;
	}
	dumText.Format("End Thrust\nTop: %.1f lbs\nBottom: %.1f lbs", topET, bottomET);
	endThrustRect.bottom = endThrustRect.top + dc.DrawText(dumText, txtRect, DT_CALCRECT) + 6;
	dc.Rectangle(endThrustRect);
	txtRect = endThrustRect + CPoint(0,3);
	dc.DrawText(dumText, txtRect, DT_CENTER);

	m_AndersenRect.bottom = endThrustRect.bottom;

	if (!m_CurrTxfo->m_AndersenOutputIsValid)
	{
		CBrush badBrush(HS_BDIAGONAL, BLACK_COLOUR);
		CBrush* lastBrush = (CBrush*)dc.SelectObject(&badBrush);
		int oldMode = dc.SetBkMode(TRANSPARENT);
		dc.Rectangle(m_AndersenRect);
		dc.SetBkMode(oldMode);
		dc.SelectObject(lastBrush);
	}

	// Show the core on the left side of the screen
	
	GetClientRect(&m_CCRect);
	m_CCRect.right = m_VperNRect.left;

	CRect CoreRect = m_CCRect;
	CoreRect.DeflateRect(20,20);

	CPen* stdBlackPen = new CPen(PS_SOLID, 1, (COLORREF)BLACK_COLOUR);
	dc.SelectObject(stdBlackPen);

	m_ArrowRect = CoreRect;
	m_ArrowRect.top = m_ArrowRect.bottom - 25;
	m_ArrowRect.right = m_ArrowRect.left;

	dc.MoveTo(CoreRect.TopLeft());
	dc.LineTo(CoreRect.right, CoreRect.top);
	dc.MoveTo(CoreRect.TopLeft());
	dc.LineTo(CoreRect.left, CoreRect.bottom);
	dc.LineTo(CoreRect.BottomRight());
	
	CPoint tmpPt(CoreRect.right, CoreRect.top);
	CPoint tmpPt2 = tmpPt;

	while (tmpPt.x > CoreRect.left)
	{
		tmpPt2.Offset(-10,-10);

		dc.MoveTo(tmpPt);
		dc.LineTo(tmpPt2);

		tmpPt -= CPoint(20, 0);
		tmpPt2 = tmpPt;
	}

	tmpPt = CoreRect.TopLeft();
	tmpPt.Offset(0, 10);
	tmpPt2 = tmpPt;

	while (tmpPt.y < CoreRect.bottom)
	{
		tmpPt2.Offset(-10,-10);

		dc.MoveTo(tmpPt);
		dc.LineTo(tmpPt2);

		tmpPt += CPoint(0, 20);
		tmpPt2 = tmpPt;
	}

	tmpPt = CoreRect.BottomRight();
	tmpPt2 = tmpPt;

	while (tmpPt.x > CoreRect.left)
	{
		tmpPt2.Offset(10,10);

		dc.MoveTo(tmpPt);
		dc.LineTo(tmpPt2);

		tmpPt -= CPoint(20, 0);
		tmpPt2 = tmpPt;
	}

	// Done showing the core

	// Show the flux lines
	CFluxLines* nextHead = m_FluxListHead;

	if (nextHead != NULL)
	{
		CFluxLines* nextNode;
		// Calculate the scale for the flux lines
		double fluxScale = CoreRect.Height() / nextHead->Y();

		nextHead = nextHead->NextHead();

		while (nextHead != NULL)
		{
			nextNode = nextHead;
			CPoint lastPoint((int)(nextNode->X() * fluxScale), 
							 CoreRect.bottom - (int)(nextNode->Y() * fluxScale));
			lastPoint.Offset(CoreRect.left, 0);
			CPoint nextPoint;

			while (nextNode != NULL)
			{
				nextPoint = CPoint((int)(nextNode->X() * fluxScale), 
								   CoreRect.bottom - (int)(nextNode->Y() * fluxScale));
				nextPoint.Offset(CoreRect.left, 0);
				dc.MoveTo(lastPoint);
				dc.LineTo(nextPoint);

				lastPoint = nextPoint;

				nextNode = nextNode->Next();
			}

			nextHead = nextHead->NextHead();
		}
	}

	// Calculate the scale to use (in pixels/inch)

	double dwgScale = CoreRect.Height() / m_CurrTxfo->m_Core.m_WindowHeight;

	m_NextWdg = m_CurrTxfo->GetWdgHead();
	Layer* nextLayer;
	Segment* nextSegment;
	CRect segRect;

	CRectList* newCoilRect = NULL;

	while (m_NextWdg != NULL)
	{
		double wdgZeroOffset = m_CurrTxfo->m_LowerZ; 

		// variables for arrows
		double firstIR, lastIR, lastRB;

		nextLayer = m_NextWdg->m_LayerHead;

		firstIR = nextLayer->m_InnerRadius;

		dc.SelectObject(thinPen[m_NextWdg->m_Terminal - 1]);

		while (nextLayer != NULL)
		{
			lastIR = nextLayer->m_InnerRadius;
			lastRB = nextLayer->m_RadialWidth;

			segRect.left = 
				(int)((nextLayer->m_InnerRadius - 
				(m_CurrTxfo->m_Core.m_Diameter / 2)) *
				(dwgScale)) +
				CoreRect.left;

			segRect.right = 
				(int)(((nextLayer->m_InnerRadius - 
				(m_CurrTxfo->m_Core.m_Diameter / 2)) +
				(nextLayer->m_RadialWidth)) * 
				(dwgScale)) +
				CoreRect.left;

			if (segRect.Width() < 5)
				segRect.right = segRect.left + 5;

			nextSegment = nextLayer->m_SegmentHead;

			while (nextSegment != NULL)
			{
				// show the segment

				int yBottom, yTop;

				yBottom = (int)((wdgZeroOffset + nextSegment->m_MinZ) * dwgScale);
				yTop = (int)((wdgZeroOffset + nextSegment->m_MaxZ) * dwgScale);

				segRect.bottom = CoreRect.bottom - yBottom;
				segRect.top = CoreRect.bottom - yTop;

				dc.MoveTo(segRect.left, segRect.top);
				dc.LineTo(segRect.left, segRect.bottom);
				dc.LineTo(segRect.right, segRect.bottom);
				dc.LineTo(segRect.right, segRect.top);
				dc.LineTo(segRect.left, segRect.top);

				// hatch the rectangle if the segment is not active

				if (!nextSegment->IsActive())
				{
					CRect sRect = segRect;
					sRect.DeflateRect(1,1,0,0);

					if (segRect.Height() < 10)
					{
						LOGBRUSH tBrush;
						hatchBrush[m_NextWdg->m_Terminal - 1]->GetLogBrush(&tBrush);
						CBrush tmpBrush(tBrush.lbColor);
						dc.FillRect(sRect, &tmpBrush);
					}
					else
					{
						dc.FillRect(sRect, hatchBrush[m_NextWdg->m_Terminal - 1]);
					}

				}


				// update the arrow rect
				m_ArrowRect.right = segRect.right;

				// save the coil rect
				if (m_CoilRectHead == NULL)
				{
					m_CoilRect = segRect;

					m_CoilRectHead = new CRectList(segRect, 
												   nextLayer, 
												   nextSegment, 
												   m_NextWdg);
					newCoilRect = m_CoilRectHead;
				}
				else
				{
					m_CoilRect.right = segRect.right;

					if (segRect.top < m_CoilRect.top)
						m_CoilRect.top = segRect.top;

					newCoilRect->SetNext(new CRectList(segRect, 
													   nextLayer, 
													   nextSegment, 
													   m_NextWdg));

					newCoilRect = newCoilRect->GetNext();
				}
				

				nextSegment = nextSegment->m_Next;				
			}

			nextLayer = nextLayer->GetNext();
		}

		// show the current direction arrow

		ShowCurrentArrow(
			m_NextWdg->m_CurrentDirection,
			(int)(((firstIR + lastIR + lastRB) / 2 - (m_CurrTxfo->m_Core.m_Diameter / 2)) *
				(dwgScale)) +
				CoreRect.left,
			CoreRect.bottom - 7,
			&dc);

		// add the rectangle to the list;
		CRectList* newList = new CRectList;

		if (m_ArrowRectHead == NULL)
		{
			m_ArrowRectHead = newList;
		}
		else
		{
			m_ArrowRectHead->AddRectList(newList);
		}

		int rectCtr = (int)(((firstIR + lastIR + lastRB) / 2 - (m_CurrTxfo->m_Core.m_Diameter / 2)) *
				(dwgScale)) +
				CoreRect.left;

		newList->left = rectCtr - 5;
		newList->right = rectCtr + 5;
		newList->bottom = CoreRect.bottom - 5;
		newList->top = newList->bottom - 17;


		m_NextWdg = m_NextWdg->GetNext();
	}



	dc.SelectObject(oldBrush);
	dc.SelectObject(oldFont);

	delete thickBlackPen;
	delete stdBlackPen;

}


void CChildView::OnRButtonDown(UINT nFlags, CPoint point) 
{
	// TODO: Add your message handler code here and/or call default

	CMenu theMenu;
	CMenu* pPopup;
	CPoint menuPoint(point);
	ClientToScreen(&menuPoint);

	m_SelectWdgFlag = false;
	m_ParentSB->SetWindowText(_T("Ready"));
	
	
	int yTermLimit = m_CurrTxfo->m_NumTerminals * m_TermBoxHeight;
	m_RBOverTerm = 0;
		
	if ((point.x > m_TerminalRect.left) &&
		(point.y <= yTermLimit))
	{
		m_RBOverTerm = (int)(point.y / m_TermBoxHeight) + 1;

		theMenu.LoadMenu(IDR_MENU_TERMINAL);
		pPopup = theMenu.GetSubMenu(0);

		pPopup->TrackPopupMenu(TPM_LEFTALIGN, 
			menuPoint.x, menuPoint.y, 
			AfxGetMainWnd());

	}
	else if (m_CoilRect.PtInRect(point))
	{
		CRectList* wCoil = m_CoilRectHead->FindPtInRect(point);

		if (wCoil != NULL)
		{
			m_RBOverWdg = wCoil->m_Winding;
			m_RBOverSegment = wCoil->m_Segment;
			m_RBOverLayer = wCoil->m_Layer;

			theMenu.LoadMenu(IDR_MENU_WIND);
			pPopup = theMenu.GetSubMenu(0);

			pPopup->TrackPopupMenu(TPM_LEFTALIGN, 
				menuPoint.x, menuPoint.y, 
				AfxGetMainWnd());

		}
	}


	
	CWnd::OnRButtonDown(nFlags, point);
}


void CChildView::ShowCurrentArrow(int wDir, int xPixelDim, int yPixelDim, CPaintDC* wDC)
// It's up to the calling routine to set the pen color in the DC before 
// calling this function. yPixelDim holds the bottommost point of the arrow.
{

#define ARROW_HEIGHT 15

	wDC->MoveTo(xPixelDim, yPixelDim);
	wDC->LineTo(xPixelDim, yPixelDim - ARROW_HEIGHT);

	int yHead;

	if (wDir > 0)
		yHead = yPixelDim - ARROW_HEIGHT;
	else
		yHead = yPixelDim;

	wDC->MoveTo(xPixelDim, yHead);
	wDC->LineTo(xPixelDim - 3, yHead + 5 * wDir);
	wDC->MoveTo(xPixelDim, yHead);
	wDC->LineTo(xPixelDim + 3, yHead + 5 * wDir);


}

void CChildView::OnLButtonDown(UINT nFlags, CPoint point) 
{
	// TODO: Add your message handler code here and/or call default

	if (m_SelectWdgFlag)
	{
		if (m_CoilRect.PtInRect(point))
		{
			CRectList* wCoil = m_CoilRectHead->FindPtInRect(point);

			if (wCoil != NULL)
			{
				m_LBOverWdg = wCoil->m_Winding;

				double offset = (m_LBOverWdg->GetAxialCenter() - 
					m_WdgToMove->GetAxialCenter());
				
				if (offset != 0.0)
				{
					m_WdgToMove->OffsetZ(offset);
					HandleTxfoChanges();
				}
				InvalidateRect(m_CCRect);
				m_SelectWdgFlag = false;
				m_ParentSB->SetWindowText(_T("Ready"));
			}
		}
	}
	else if (m_ArrowRect.PtInRect(point))
	{
		CRectList* nextRect = m_ArrowRectHead;
		m_NextWdg = m_CurrTxfo->GetWdgHead();

		while (nextRect != NULL)
		{
			if (nextRect->PtInRect(point))
			{
				m_NextWdg->ReverseCurrent();
				InvalidateRect(m_ArrowRect);
				HandleTxfoChanges();
				break;
			}

			nextRect = nextRect->GetNext();
			m_NextWdg = m_NextWdg->GetNext();
		}
	}

	
	CWnd ::OnLButtonDown(nFlags, point);
}



void CChildView::HandleTxfoChanges()
{
	m_CurrTxfo->CalcVoltsPerTurn();
	m_CurrTxfo->FixTerminalVoltages();

	AfxGetMainWnd()->PostMessage(WM_PH_TXFOVALID, true);
	m_CurrTxfo->m_AndersenOutputIsValid = false;
	AfxGetMainWnd()->PostMessage(WM_PH_ADDTXFOTOLIST, (WPARAM)new Transformer(*m_CurrTxfo));

	CRect iRect;
	GetClientRect(iRect);
	InvalidateRect(iRect);

}

void CChildView::OnLButtonDblClk(UINT nFlags, CPoint point) 
{
	// TODO: Add your message handler code here and/or call default

	// check for double-clicks in segments to activate/deactivate them

	if (m_CoilRect.PtInRect(point))
	{
		CRectList* wCoil = m_CoilRectHead->FindPtInRect(point);

		if (wCoil != NULL)
		{
			m_RBOverWdg = wCoil->m_Winding;
			m_RBOverSegment = wCoil->m_Segment;
			m_RBOverLayer = wCoil->m_Layer;

			Segment* mateSeg = NULL;
			if (m_RBOverWdg->m_IsDoubleStack)
			{
				mateSeg = m_RBOverWdg->GetMateSegment(wCoil->m_Layer, wCoil->m_Segment);
			}

			if (m_RBOverSegment->m_NumTurnsActive == 0)
			{
				m_RBOverSegment->m_NumTurnsActive = m_RBOverSegment->m_NumTurnsTotal;

				if (mateSeg != NULL)
					mateSeg->m_NumTurnsActive = mateSeg->m_NumTurnsTotal;

				if (m_RBOverWdg->m_IsMultiStart)
				{
					int i;
					int count = 0;

					Segment* nSegment = m_RBOverSegment;
					i = nSegment->GetSegmentPosition(m_RBOverLayer->m_SegmentHead);

					i %= m_RBOverWdg->m_NumLoops;
					if (i == 0)
						i = m_RBOverWdg->m_NumLoops;

					nSegment = m_RBOverLayer->m_SegmentHead;
					for (count = 1; count <= m_RBOverWdg->m_TotalTurns &&
									nSegment != NULL; count++)
					{
						if (count == i)
						{
							nSegment->m_NumTurnsActive = nSegment->m_NumTurnsTotal;
							i += m_RBOverWdg->m_NumLoops;
						}

						nSegment = nSegment->m_Next;
					}
				}
			}
			else
			{
				m_RBOverSegment->m_NumTurnsActive = 0;

				if (mateSeg != NULL)
					mateSeg->m_NumTurnsActive = 0;

				if (m_RBOverWdg->m_IsMultiStart)
				{
					int i;
					int count = 0;

					Segment* nSegment = m_RBOverSegment;
					i = nSegment->GetSegmentPosition(m_RBOverLayer->m_SegmentHead);

					i %= m_RBOverWdg->m_NumLoops;
					if (i == 0)
						i = m_RBOverWdg->m_NumLoops;

					nSegment = m_RBOverLayer->m_SegmentHead;
					for (count = 1; count <= m_RBOverWdg->m_TotalTurns &&
									nSegment != NULL; count++)
					{
						if (count == i)
						{
							nSegment->m_NumTurnsActive = 0;
							i += m_RBOverWdg->m_NumLoops;
						}

						nSegment = nSegment->m_Next;
					}
				}

			}

			HandleTxfoChanges();

		}
	}
	
	CWnd ::OnLButtonDblClk(nFlags, point);
}

LRESULT CChildView::OnSelectWdg(WPARAM wParam, LPARAM lParam)
{
	m_SelectWdgFlag = true;
	
	return (LRESULT)0;
}

BOOL CChildView::OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message) 
{
	// TODO: Add your message handler code here and/or call default

	CAndersenFEApp* tApp = (CAndersenFEApp*)AfxGetApp();
	
	if (m_SelectWdgFlag && (nHitTest == HTCLIENT))
	{
		SetCursor(tApp->LoadStandardCursor(IDC_CROSS));
		return 0;

	}
	else if (tApp->m_AndersenRunning && (nHitTest == HTCLIENT))
	{
		SetCursor(tApp->LoadStandardCursor(IDC_WAIT));
		return 0;
	}
	else
		return CWnd ::OnSetCursor(pWnd, nHitTest, message);
}
