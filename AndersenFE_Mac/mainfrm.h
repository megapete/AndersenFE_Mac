// MainFrm.h : interface of the CMainFrame class
//
/////////////////////////////////////////////////////////////////////////////

#if !defined(AFX_MAINFRM_H__D931075B_C1B7_40A1_9EB8_5F21AA6573D9__INCLUDED_)
#define AFX_MAINFRM_H__D931075B_C1B7_40A1_9EB8_5F21AA6573D9__INCLUDED_

#include "ExcelTextFile.h"	// Added by ClassView
// #include "ChildView.h"
#include "TxfoDataDlog.h"
#include "AddTermDlog.h"
#include "Terminal.h"
#include "WindingGen.h"
#include "WindingDetailDlog.h"
#include "Transformer.h"	// Added by ClassView
#include "WindModNumberDlog.h"
#include "MoveWdgDlog.h"	// Added by ClassView
#include "RegWdgDlog.h"	// Added by ClassView
#include "SplitSegmentDlog.h"	// Added by ClassView
#include "AndersenFolder.h"	// Added by ClassView
#include "AndersenFE.h"	// Added by ClassView
#include "AllTapsDialog.h"	// Added by ClassView
#include "OffsetElongation.h"	// Added by ClassView
#include "RunningMessageDlog.h"	// Added by ClassView
#include "FluxLines.h"	// Added by ClassView
#include "splitcustomdlog.h"
#include "ChangeSegmentDlog.h"

// defines to get rid of compiler warnings for Windows stuff
#define afx_msg

// Validity errors
#define NO_VALID_ERROR			0
#define TXFO_NOT_VALID_ERROR	1
#define WDG_MISSING_ERROR		2
#define TERMS_UNDEFINED_ERROR	3


// Maximum number of undo-able steps
#define MAX_UNDOTXFOS	10


// Forward declaration of ObjC-Implementation struct (definition in .mm file)
struct AppControllerImpl;

class CMainFrame
{
    // Place to hold a reference to the app controller
	AppControllerImpl *theController;
    
public:
	CMainFrame(AppControllerImpl *tCtrl);
    

// Implementation
public:
	bool m_ShowFluxLines;
	void DeleteFluxData();
	CFluxLines* m_FluxLines;
	int m_NumUndoTxfos;
	Transformer* m_TxfoUndoList;
	void OpenMRUFile(int nIndex);
	void OnMRUFile1();
	void OnMRUFile2();
	void OnMRUFile3();
	void OnMRUFile4();
	void OnMRUFile5();
	void OnMRUFile6();
	void OnMRUFile7();
	void OnMRUFile8();
	
	void SaveFld12OutputAs(CString& wFileName);
	void AddTiltingDataToFile(CString& wFileName, Transformer* wTxfo = NULL);
	void DoSerialAndersen(bool useCurrentTxfo = true);
	double GetTransformerImpedance(bool wUpdate = false);
	CAndersenFolder m_AndersenFolder;
	
	bool ReadTextFile(CString wPath);
	void HandleTxfoChange();
	void HandleModifyWindings(int wWinding = 0, int dum2 = 0);
	void HandleVerificationError(int wErr);
	int VerifyTransformer(Transformer *wTxfo = NULL);
	void SaveAndersenFile(CString& wFilePath, Transformer* wTxfo = NULL);
	int ValidError;
	bool CurrTxfoIsSaveable();
	void AddWinding(Winding* oldWinding = NULL, int wTerm = 0);
	void InitializeTxfo();
	bool m_CurrTxfoIsValid;
	Transformer m_CurrentTxfo;
	virtual ~CMainFrame();


protected:  // control bar embedded members
	// CChildView    m_wndView;

// Generated message map functions
protected:
	//{{AFX_MSG(CMainFrame)

	afx_msg void OnFileNewtransformer(TxfoDataDlog newDlog);
	afx_msg void OnOptionsTerminals();
	afx_msg void OnOptionsWindings();
	
	afx_msg void OnAddWinding();
	afx_msg void OnFileSaveandersenfile();
	afx_msg void OnAndersenAndersendirectory();
	
	afx_msg void OnAndersenRunandersenprogram();
	afx_msg void OnOptionsModifywindings();
	
	afx_msg void OnWdgMovewinding();
	afx_msg void OnWdgRegulatingwinding();
	afx_msg void OnWdgSplitsegment();
	afx_msg void OnSetvnreference();
	afx_msg void OnWdgActivate();
	afx_msg void OnWdgDeactivate();
	
	afx_msg void OnFileOpenfile();
	afx_msg void OnModifyterminal();
	afx_msg void OnWdgCenterwinding();
	afx_msg void OnClose();
	afx_msg void OnDestroy();
	afx_msg void OnRunandersenprogram();
	
	afx_msg void OnChangetoonaf();
	afx_msg void OnAndersenRunandersenalltaps();
	
	afx_msg void OnEditUndo();
	afx_msg void OnCalculatemva();
	afx_msg void OnAndersenShowfluxlines();
	
	//}}AFX_MSG

	// my messages

	

	
private:
	void ExtractNextNumber(CStdioFile& wFile, CString& wString);
	CAndersenFEApp* m_tApp;
	afx_msg void OnWdgCreateparallellayer();
	afx_msg void OnWdgSplitSegCustom();
	CSplitCustomDlog tst;
	afx_msg void OnWdgChangesegmentdata();
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MAINFRM_H__D931075B_C1B7_40A1_9EB8_5F21AA6573D9__INCLUDED_)
