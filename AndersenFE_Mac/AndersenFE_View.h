//
//  AndersenFE_View.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 11/30/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;
@class PCH_AndersenFE_TxfoView;
@class PCH_AndersenFE_TerminalView;
@class AndersenFE_TxfoDataView;

@interface AndersenFE_View : NSView

@property AppController *theAppController;



// CChildView ivars
/*
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
*/

@end
