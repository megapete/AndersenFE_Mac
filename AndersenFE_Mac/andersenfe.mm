// AndersenFE.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "AndersenFE.h"
//#include "AndersenFolder.h"
#include "AppController.h"

// #include "MainFrm.h"



/////////////////////////////////////////////////////////////////////////////
// CAndersenFEApp



/////////////////////////////////////////////////////////////////////////////
// CAndersenFEApp construction

CAndersenFEApp::CAndersenFEApp(AppControllerImpl *tCtrl)
{
	theController = tCtrl;
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CAndersenFEApp object

// CAndersenFEApp theApp;

/////////////////////////////////////////////////////////////////////////////
// CAndersenFEApp initialization

BOOL CAndersenFEApp::InitInstance()
{
	// CMainFrame* pFrame = new CMainFrame(theController);
	// m_pMainWnd = pFrame;

    /* Probably won't need this
	m_StartSaveOutput = new CEvent(false, true);
	m_StartSaveOutput->ResetEvent();
     */

	// m_UseFld12Output = new CReadersWriters;
	m_AndersenRunning = false;

	// This stuff will be taken care of by Mac system
    /*
	m_RecentFiles = new CRecentFileList(0, "Recent Files", "Filename%d", MAX_RECENT_FILES);
	m_RecentFiles->ReadList();
     */
    
    // theOneAndOnlyApp = this;
    
	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// CAndersenFEApp message handlers





/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About




void CAndersenFEApp::CleanUpPointers()
{
	
}
