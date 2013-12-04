//
//  AppController.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 11/30/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "AppController.h"
#import "mainfrm.h"
#import "andersenfe.h"
#import "PCH_AndersenFE_TxfoView.h"
#include "transformer.h"
#include "winding.h"
#include "ExcelTextFile.h"

@interface AppController()
{
    CMainFrame *_theMainFrame;
    CAndersenFEApp *_theApp;
    
    Transformer *_currentTxfo;
}

@property NSURL *dosBoxPrefsURL;
@property NSURL *dosBoxCDriveURL;

@end

@implementation AppController

#pragma mark -
#pragma mark Creation routines

- (id)init
{
    if (self = [super init])
    {
        AppControllerImpl *selfImpl = new AppControllerImpl;
        selfImpl->theAppController = self;
        
        _theApp = new CAndersenFEApp(selfImpl);
        
        self.dosBoxPrefsURL = nil;
        self.dosBoxCDriveURL = nil;
    }
    
    return self;
}

- (void)awakeFromNib
{
    _theApp->InitInstance();
    
    _theMainFrame = _theApp->m_pMainWnd;
}

#pragma mark -
#pragma mark View updating

- (void)updateAllViews
{
    [self updateTerminalView];
    [self updateTxfoDataView];
    [self updateTxfoView];
}

- (void)updateTxfoView
{
    Winding *nextWinding = _currentTxfo->GetWdgHead();
    
    double minIR = DBL_MAX;
    double maxOR = 0.0;
    
    while (nextWinding != NULL)
    {
        if (nextWinding->m_InnerRadius < minIR)
        {
            minIR = nextWinding->m_InnerRadius;
        }
        
        if ((nextWinding->m_InnerRadius + nextWinding->m_RadialWidth) > maxOR)
        {
            maxOR = nextWinding->m_InnerRadius + nextWinding->m_RadialWidth;
        }
        
        nextWinding = nextWinding->GetNext();
    }
    
    [self.theTxfoView setScaleForWindowHeight:_currentTxfo->m_Core.m_WindowHeight withInnerIR:minIR coreToInnerWdg:_currentTxfo->m_InnerClearance andOuterOR:maxOR tankToOuterWdg:4.0];
}

- (void)updateTxfoDataView
{
    
}

- (void)updateTerminalView
{
    
}

#pragma mark -
#pragma mark Get DosBox info

- (IBAction)setDosBoxPrefsLocation:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setTitle:@"Find DosBox Configuration File"];
    [openPanel setMessage:@"The DosBox Prefs path is usually ~/Library/Preferences/DOSBox 0.74 Preferences"];
    
    NSString *prefsDirPath = @"~/Library/Preferences";
    prefsDirPath = [prefsDirPath stringByExpandingTildeInPath];
    NSURL *prefsDirectory = [NSURL fileURLWithPath:prefsDirPath isDirectory:YES];
    
    [openPanel setDirectoryURL:prefsDirectory];
    
    NSInteger runResult = [openPanel runModal];
    
    if (runResult == NSFileHandlingPanelOKButton)
    {
        self.dosBoxPrefsURL = [openPanel URL];
    }
}

- (IBAction)setDosBoxCLocation:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setTitle:@"Find DosBox C Drive"];
    [openPanel setMessage:@"There is a folder you assigned to be DropBox's C Drive: Find it"];
    
    NSString *cDirPath = @"~/";
    cDirPath = [cDirPath stringByExpandingTildeInPath];
    NSURL *cDirectory = [NSURL fileURLWithPath:cDirPath isDirectory:YES];
    
    [openPanel setDirectoryURL:cDirectory];
    
    NSInteger runResult = [openPanel runModal];
    
    if (runResult == NSFileHandlingPanelOKButton)
    {
        self.dosBoxCDriveURL = [openPanel URL];
    }
}

#pragma mark -
#pragma mark Routine for inputting an Excel-generated design file
- (IBAction)openXLDesignFile:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setTitle:@"Design file"];
    [openPanel setMessage:@"Open the required Excel-design-program-generated file"];
    
    NSString *docDirPath = @"~/Documents";
    docDirPath = [docDirPath stringByExpandingTildeInPath];
    NSURL *docDirectory = [NSURL fileURLWithPath:docDirPath isDirectory:YES];
    
    [openPanel setDirectoryURL:docDirectory];
    
    NSInteger runResult = [openPanel runModal];
    
    if (runResult == NSFileHandlingPanelCancelButton)
    {
        return;
    }
    
    NSString *pathString = [[openPanel URL] path];
    
    CString pathName([pathString cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    
    CExcelTextFile xlFile(pathName, CFile::modeRead);
    
    Transformer *xlTxfo = new Transformer;
    
    xlFile.InputFile(xlTxfo);
    
    _currentTxfo = xlTxfo;

}


@end







