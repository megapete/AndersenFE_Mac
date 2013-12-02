// ChildView.h : interface of the CChildView class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_CHILDVIEW_H__A93688BC_9EDE_4B7B_81E5_58E7A4B60DEE__INCLUDED_)
#define AFX_CHILDVIEW_H__A93688BC_9EDE_4B7B_81E5_58E7A4B60DEE__INCLUDED_

#include "Transformer.h"	// Added by ClassView
#include "Winding.h"	// Added by ClassView
#include "Layer.h"	// Added by ClassView
#include "Segment.h"	// Added by ClassView
#include "RectList.h"	// Added by ClassView
#include "FluxLines.h"	// Added by ClassView
#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000


// colors

#define BLACK_COLOUR 0x00
#define RED_COLOUR 0xFF
#define GREEN_COLOUR 0xFF00
#define YELLOW_COLOUR 0xFFFF
#define BLUE_COLOUR 0xFF0000
#define MAGENTA_COLOUR 0xFF00FF
#define CYAN_COLOUR 0xFFFF00
#define WHITE_COLOUR 0xFFFFFF


// pens
#define RED_PEN 0
#define GREEN_PEN 1
#define BLUE_PEN 2
#define MAGENTA_PEN 3
#define CYAN_PEN 4
#define YELLOW_PEN 5





/////////////////////////////////////////////////////////////////////////////
// CChildView window

class CChildView : public CWnd
{
// Construction
public:
	CChildView();

// Attributes
public:

// Operations
public:

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CChildView)
	protected:
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	//}}AFX_VIRTUAL

// Implementation
public:
	CFluxLines* m_FluxListHead;
	CRect m_Impedance2Rect;
	CRect m_AndersenRect;
	CRect m_ImpedanceRect;
	CStatusBar* m_ParentSB;
	Winding* m_WdgToMove;
	Winding* m_LBOverWdg;
	bool m_SelectWdgFlag;
	Layer* m_RBOverLayer;
	void HandleTxfoChanges();
	CBrush* hatchBrush[6];
	CRect m_VperNRect;
	Segment* m_RBOverSegment;
	Winding* m_RBOverWdg;
	CRect m_CoilRect;
	CRectList* m_CoilRectHead;
	CRectList* m_ArrowRectHead;
	CRect m_ArrowRect;
	CPen* thinPen[6];
	void ShowCurrentArrow(int wDir, int xPixelDim, int yPixelDim, CPaintDC* wDC);
	Winding* m_NextWdg;
	int m_RBOverTerm;
	int m_TermBoxHeight;
	CWnd* m_Parent;
	CRect m_CCRect;
	Transformer* m_CurrTxfo;
	CRect m_TerminalRect;
	virtual ~CChildView();

	// Generated message map functions
protected:
	//{{AFX_MSG(CChildView)
	afx_msg void OnPaint();
	afx_msg void OnRButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonDblClk(UINT nFlags, CPoint point);
	afx_msg BOOL OnSetCursor(CWnd* pWnd, UINT nHitTest, UINT message);
	//}}AFX_MSG

	// My messages
	afx_msg LRESULT OnSelectWdg(WPARAM wParam, LPARAM lParam);

	DECLARE_MESSAGE_MAP()
private:
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CHILDVIEW_H__A93688BC_9EDE_4B7B_81E5_58E7A4B60DEE__INCLUDED_)
