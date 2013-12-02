// AndersenFE.h : main header file for the ANDERSENFE application
//

#if !defined(AFX_ANDERSENFE_H__F7BBC35B_EC27_458E_9FE4_FBDC74773889__INCLUDED_)
#define AFX_ANDERSENFE_H__F7BBC35B_EC27_458E_9FE4_FBDC74773889__INCLUDED_





#define WM_PH_SELECTWDG				(WM_APP + 1)
#define WM_PH_UPDATEANDERSENFIELDS	(WM_APP + 2)
#define WM_PH_TXFOVALID				(WM_APP + 3)
#define WM_PH_ADDTXFOTOLIST			(WM_APP + 4)

// Verification errors

#define NO_TXFO_ERROR			0
#define AMPTURNS_ERROR			1
#define TXFO_UNDEFINED_ERROR	2

#define TERM1_TURNS_ERROR		10
#define TERM2_TURNS_ERROR		11
#define TERM3_TURNS_ERROR		12
#define TERM4_TURNS_ERROR		13
#define TERM5_TURNS_ERROR		14
#define TERM6_TURNS_ERROR		15

#define WDG1_TOOSMALL_ERROR		20
#define WDG2_TOOSMALL_ERROR		21
#define WDG3_TOOSMALL_ERROR		22
#define WDG4_TOOSMALL_ERROR		23
#define WDG5_TOOSMALL_ERROR		24
#define WDG6_TOOSMALL_ERROR		25
#define WDG7_TOOSMALL_ERROR		26
#define WDG8_TOOSMALL_ERROR		27
#define WDG9_TOOSMALL_ERROR		28
#define WDG10_TOOSMALL_ERROR	29


// Maximum number of recent files to display
#define MAX_RECENT_FILES	8

// Forward declaration of ObjC-Implementation struct (definition in .mm file)
struct AppControllerImpl;
class CMainFrame;

/////////////////////////////////////////////////////////////////////////////
// CAndersenFEApp:
// See AndersenFE.cpp for the implementation of this class
//

class CAndersenFEApp
{
public:
    
	CAndersenFEApp(AppControllerImpl *tCtrl);
    
public:
	virtual BOOL InitInstance();
	
    
public:
	
	void CleanUpPointers();
	bool m_AndersenRunning;
	// CReadersWriters* m_UseFld12Output;
	
    
    // Stuff that needs to be added ince we haven't actually created CWinApp
    CMainFrame* m_pMainWnd;
    
    
    AppControllerImpl *theController;
	
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.





#endif // !defined(AFX_ANDERSENFE_H__F7BBC35B_EC27_458E_9FE4_FBDC74773889__INCLUDED_)


