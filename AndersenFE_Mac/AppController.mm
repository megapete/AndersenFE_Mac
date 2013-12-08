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
#import "PCH_AndersenFE_TerminalView.h"
#import "PCH_SegmentPath.h"

#include "stdafx.h"
#include "transformer.h"
#include "terminal.h"
#include "winding.h"
#include "layer.h"
#include "segment.h"
#include "ExcelTextFile.h"

// Keys into the dictionaries in the rectArray property
#define RECTARRAY_RECTANGLE_KEY     @"Rectangle"
#define RECTARRAY_WINDING_KEY       @"Winding"
#define RECTARRAY_SEGMENT_KEY       @"Segment"
#define RECTARRAY_LAYER_KEY         @"Layer"

@interface AppController()
{
    CMainFrame *_theMainFrame;
    CAndersenFEApp *_theApp;
    
    Transformer *_currentTxfo;
}

@property NSURL *dosBoxPrefsURL;
@property NSURL *dosBoxCDriveURL;

@property NSArray *colorArray;

- (void)handleTxfoChanges;

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
        
        self.colorArray = [NSArray arrayWithObjects:[NSColor redColor], [NSColor greenColor], [NSColor orangeColor], [NSColor blueColor], [NSColor purpleColor], nil];
    }
    
    return self;
}

- (void)awakeFromNib
{
    _theApp->InitInstance();
    
    _theMainFrame = _theApp->m_pMainWnd;
    
    self.theTerminalView.theAppController = self;
    self.theTxfoView.theAppController = self;
    
    self.terminalData = [NSArray arrayWithObjects:self.term1Data, self.term2Data, self.term3Data, self.term4Data, self.term5Data, self.term6Data, nil];
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
    NSMutableArray *segments = [NSMutableArray array];
    
    Winding *nextWinding = _currentTxfo->GetWdgHead();
    
    double minIR = DBL_MAX;
    double maxOR = 0.0;
    
    while (nextWinding != NULL)
    {
        Layer *nextLayer = nextWinding->m_LayerHead;
        
        while (nextLayer != NULL)
        {
            Segment *nextSegment = nextLayer->m_SegmentHead;
            
            while (nextSegment != NULL)
            {
                NSRect segRect = NSMakeRect(nextLayer->m_InnerRadius - (_currentTxfo->m_Core.m_Diameter / 2.0),
                                            _currentTxfo->m_LowerZ + nextSegment->m_MinZ,
                                            nextLayer->m_RadialWidth,
                                            nextSegment->m_MaxZ - nextSegment->m_MinZ);
                
                if (segRect.origin.x < minIR)
                {
                    minIR = segRect.origin.x;
                }
                
                if (segRect.origin.x + segRect.size.width > maxOR)
                {
                    maxOR = segRect.origin.x + segRect.size.width;
                }
                
                
                NSDictionary *nextDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithPointer:nextSegment], SEGDATA_SEGMENT_KEY, [NSValue valueWithPointer:nextLayer], SEGDATA_LAYER_KEY, [NSValue valueWithPointer:nextWinding], SEGDATA_WINDING_KEY, [NSValue valueWithRect:segRect], SEGDATA_RECTANGLE_KEY, nil];
                
                [segments addObject:[PCH_SegmentPath segmentPathWithPath:[NSBezierPath bezierPathWithRect:segRect] andColor:self.colorArray[nextWinding->m_Terminal - 1] andData:nextDictionary]];
                
                nextSegment = nextSegment->m_Next;
            }
            
            nextLayer = nextLayer->GetNext();
        }
        
        nextWinding = nextWinding->GetNext();
    }
    
    if (segments.count > 0)
    {
        self.theTxfoView.segmentPaths = [NSArray arrayWithArray:segments];
    }
    
    [self.theTxfoView setScaleForWindowHeight:_currentTxfo->m_Core.m_WindowHeight withInnerIR:minIR coreToInnerWdg:_currentTxfo->m_InnerClearance andOuterOR:maxOR tankToOuterWdg:4.0];
    
    [self.theTxfoView setNeedsDisplay:YES];
}

- (void)updateTxfoDataView
{
    
}

- (void)updateTerminalView
{
    Terminal *nextTerm = _currentTxfo->GetTermHead();
    
    int i = 0;
    
    NSMutableArray *termColors = [NSMutableArray array];
    NSMutableArray *termFields = [NSMutableArray array];
    
    while (nextTerm != NULL)
    {
        NSTextField *txtField = self.terminalData[i];
        
        CString termConn;
        nextTerm->GetConnectionText(termConn);
        
        [txtField setStringValue:[NSString stringWithFormat:@"Terminal %d\n%.3f MVA\n%.3f kV\n%s", i+1, nextTerm->m_MVA, nextTerm->m_KV, termConn.c_str()]];
        
        [termColors addObject:self.colorArray[i]];
        [termFields addObject:txtField];
        
        i++;
        nextTerm = nextTerm->GetNext();
    }
    
    if (termFields.count > 0)
    {
        self.theTerminalView.borderColors = [NSArray arrayWithArray:termColors];
        self.theTerminalView.dataViews = [NSArray arrayWithArray:termFields];
    }
    else
    {
        self.theTerminalView.borderColors = nil;
        self.theTerminalView.dataViews = nil;
    }
    
    [self.theTerminalView setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Setting transformer characteristics

- (void)handleTxfoChanges
{
    if (_currentTxfo != NULL)
    {
        _currentTxfo->CalcVoltsPerTurn();
        _currentTxfo->FixTerminalVoltages();
        _currentTxfo->m_AndersenOutputIsValid = NO;
    }
    
    [self updateAllViews];
}

- (void)setVPNRefToTermNumber:(int)wTerm
{
    if (_currentTxfo != NULL)
    {
        _currentTxfo->m_VperNTerminal = wTerm + 1;
        
        [self handleTxfoChanges];
    }
}

#pragma mark -
#pragma mark Window delegate methods

- (void)windowDidResize:(NSNotification *)notification
{
    // for now we only really care if the main window is resized, but we'll check it anyway to make future desige changes easier
    if ([notification object] == [NSApp mainWindow])
    {
        [self updateAllViews];
    }
    
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
#pragma mark Routine for inputting an Excel-generated design file & Recent files

- (IBAction)openXLDesignFile:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setTitle:@"Design file"];
    [openPanel setMessage:@"Open the required Excel-design-program-generated file"];
    
    // set the user's Documents directory as the default
    NSString *docDirPath = @"~/Documents";
    docDirPath = [docDirPath stringByExpandingTildeInPath];
    NSURL *docDirectory = [NSURL fileURLWithPath:docDirPath isDirectory:YES];
    
    // if there was a successful opening of a some file, try setting the default directory to the same as that file's directory
    if (NSURL *lastFile = [[NSUserDefaults standardUserDefaults] URLForKey:LAST_OPENED_INPUT_FILE_KEY])
    {
        NSMutableArray *pComps = [NSMutableArray arrayWithArray:[lastFile pathComponents]];
        [pComps removeLastObject];
        
        docDirectory = [NSURL fileURLWithPathComponents:pComps];
    }
    
    [openPanel setDirectoryURL:docDirectory];
    
    NSInteger runResult = [openPanel runModal];
    
    NSString *pathString = [[openPanel URL] path];
    
    [openPanel orderOut:nil];
    
    if (runResult == NSFileHandlingPanelCancelButton)
    {
        return;
    }
    
    [self openInputFile:pathString];
}


- (BOOL)openInputFile:(NSString *)fName
{
    CString pathName([fName cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    
    CExcelTextFile xlFile(pathName, CFile::modeRead);
    
    Transformer *xlTxfo = new Transformer;
    
    int inputResult = xlFile.InputFile(xlTxfo);
    
    if (inputResult != NO_TXTFILE_ERROR)
    {
        [NSAlert alertWithMessageText:@"Bad Input File!" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Can't opem input file: Error code #%d", inputResult];
        
        delete xlTxfo;
        
        return NO;
    }
    
    NSURL *docURL = [NSURL fileURLWithPath:fName];
    
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:docURL];
    
    [[NSUserDefaults standardUserDefaults] setURL:docURL forKey:LAST_OPENED_INPUT_FILE_KEY];
    
    _currentTxfo = xlTxfo;
    
    [self updateAllViews];
    
    return YES;
}


@end







