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
#import "AndersenFE_TxfoDataView.h"
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
    if (_currentTxfo == NULL)
    {
        return;
    }
    
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
    if ((_currentTxfo != NULL) && (_currentTxfo->m_IsValid))
    {
        int verifyResult = _currentTxfo->VerifyTransformer();
        
        if (_currentTxfo->m_VperNTerminal == 0)
        {
            [self.voltsPerTurnField setStringValue:[NSString stringWithFormat:@"Volts per Turn\nRef. Terminal: UNASSIGNED\n0.000 V/N"]];
        }
        else
        {
            [self.voltsPerTurnField setStringValue:[NSString stringWithFormat:@"Volts per Turn\nRef. Terminal: %d\n%.3f V/N", _currentTxfo->m_VperNTerminal, _currentTxfo->CalcVoltsPerTurn()]];
        }
        
        [self.voltsPerTurnField invalidateIntrinsicContentSize];
        
        if (verifyResult != AMPTURNS_ERROR)
        {
            [self.ampereTurnsField setStringValue:[NSString stringWithFormat:@"Total Amp-Turns\n%.1f",_currentTxfo->AmpTurns()]];
        }
        else
        {
            [self.ampereTurnsField setStringValue:[NSString stringWithFormat:@"Total Amp-Turns\n-ERROR-"]];
        }
        
    }
    else
    {
        [self.voltsPerTurnField setStringValue:@""];
        [self.ampereTurnsField setStringValue:@""];
    }
    
    [self.theTxfoData setNeedsDisplay:YES];
}

- (void)updateTerminalView
{
    Terminal *nextTerm = NULL;
    
    if (_currentTxfo != NULL)
    {
        nextTerm = _currentTxfo->GetTermHead();
    }
    
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
        [self updateAllViews];
    }
    
    
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
#pragma mark Routines for saving Andersen files

- (IBAction)saveAndersenFile:(id)sender
{
    if (![self currentTransformerIsSaveable])
    {
        NSLog(@"The current transformer is not properly defined!");
        return;
    }
    
    // Show the save dialog
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    [savePanel setTitle:@"Andersen file"];
    [savePanel setMessage:@"Save the Andersen input file"];
    
    // For now use the Documents folder as the default location.
    NSString *docDirPath = @"~/Documents";
    docDirPath = [docDirPath stringByExpandingTildeInPath];
    NSURL *docDirectory = [NSURL fileURLWithPath:docDirPath isDirectory:YES];
    
    [savePanel setDirectoryURL:docDirectory];
    
    NSInteger runResult = [savePanel runModal];
    
    NSString *pathString = [[savePanel URL] path];
    
    [savePanel orderOut:nil];
    
    if (runResult == NSFileHandlingPanelCancelButton)
    {
        return;
    }
    
    [self savecCurrentTxfoAsAndersenFile:pathString];
}

- (void)savecCurrentTxfoAsAndersenFile:(NSString *)wPath
{
    NSFileManager *defMgr = [NSFileManager defaultManager];
    
    if ([defMgr fileExistsAtPath:wPath])
    {
        NSError *error;
        BOOL removeExisting = [defMgr removeItemAtPath:wPath error:&error];
        
        if (!removeExisting)
        {
            NSLog(@"Could not delete existing file!");
            return;
        }
    }
    
    BOOL createFile = [defMgr createFileAtPath:wPath contents:[NSData data] attributes:nil];
    if (!createFile)
    {
        NSLog(@"Could not create file!");
        return;
    }
    
    Transformer *wTxfo = _currentTxfo;
    
    // Line 1
    // CString nLine = wTxfo->m_Description;
    NSMutableString *nextLine = [NSMutableString stringWithCString:wTxfo->m_Description.c_str() encoding:[NSString defaultCStringEncoding]];
    [nextLine appendString:@"\r\n"];
    
    NSMutableString *newFileString = [NSMutableString string];
    
    [newFileString appendString:nextLine];
    
    // take care of Andersen bug
    double zOffset = 0.0;
    if (wTxfo->m_LowerZ > 4.5)
        zOffset = wTxfo->m_LowerZ - 4.5;
    
    // Line 2
    /*
    nLine.Format("%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.3f%-10.3f%-10.3f\n",
                 2, // always in inches
                 wTxfo->m_NumPhases,
                 wTxfo->m_Frequency,
                 wTxfo->m_NumWoundLimbs,
                 1, // always full height
                 -wTxfo->m_LowerZ + zOffset,
                 wTxfo->m_Core.m_WindowHeight - wTxfo->m_LowerZ + zOffset,
                 wTxfo->m_Core.m_Diameter
                 );
    */
    
    nextLine = [NSMutableString stringWithFormat:@"%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.3f%-10.3f%-10.3f\r\n",
                2,
                wTxfo->m_NumPhases,
                wTxfo->m_Frequency,
                wTxfo->m_NumWoundLimbs,
                1,
                -wTxfo->m_LowerZ + zOffset,
                wTxfo->m_Core.m_WindowHeight - wTxfo->m_LowerZ + zOffset,
                wTxfo->m_Core.m_Diameter
                ];
    
    [newFileString appendString:nextLine];
    
    // Line 3
    nextLine = [NSMutableString stringWithFormat:@"%-10.3f%-10.1d%-10.3f%-10.3f%-10.3f%-10.1d%-10.1d\r\n",
                wTxfo->m_InnerClearance,
                0, // AL/CU shield
                wTxfo->m_SystemGVA,
                wTxfo->m_puImpedance, // Optional Per Unit Impedance
                wTxfo->m_PeakFactor,
                wTxfo->m_NumTerminals,
                wTxfo->CountLayers()
                ];
    [newFileString appendString:nextLine];
    
    // Line 4
    nextLine = [NSMutableString stringWithFormat:@"%-10.1d%-10.3f%-10.3f%-10.3f%-10.3f%-10.1d%-10.1d\r\n",
                wTxfo->m_OffsetElongation, // displacement/elongation
                wTxfo->m_OffElongValue, // amount
                0.0, // loss factor - tank
                0.0, // loss factor - leg
                0.0, // loss factor - yoke
                1, // scale of flux plot
                25 // number of flux lines
                ];
    [newFileString appendString:nextLine];
    
    // Terminal data
    Terminal* nextTerm = wTxfo->GetTermHead();
    while (nextTerm != NULL)
    {
        nextLine = [NSMutableString stringWithFormat:@"%-10.1d%-10.1d%-10.3f%-10.3f\r\n",
                    nextTerm->m_Number,
                    nextTerm->m_Connection,
                    nextTerm->m_MVA,
                    nextTerm->m_KV
                    ];
        [newFileString appendString:nextLine];
        
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
            
            nextLine = [NSMutableString stringWithFormat:@"%-10.1d%-10.1d%-10.3f%-10.3f\r\n",
                         layerNum,
                         runningSegmentNum,
                         nextLayer->m_InnerRadius,
                         nextLayer->m_RadialWidth
                         ];
            [newFileString appendString:nextLine];
            
            
            nextLine = [NSMutableString stringWithFormat:@"%-10.1d%-10.1d%-10.1d%-10.1d%-10.1d%-10.3f\r\n",
                         nextLayer->m_Terminal, // Terminal Number
                         nextLayer->m_NumberParGroups,
                         nextLayer->m_CurrentDirection,
                         nextLayer->m_Material,
                         nextLayer->m_NumSpacerBlocks,
                         nextLayer->m_SpacerBlockWidth
                         ];
            [newFileString appendString:nextLine];
            
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
                
                nextLine = [NSMutableString stringWithFormat:@"%-10.1d%-10.3f%-10.3f%-10.3f%-10.3f\r\n",
                             runningSegmentNum,
                             nextSegment->m_MinZ,
                             nextSegment->m_MaxZ,
                             nextSegment->m_NumTurnsTotal,
                             nextSegment->m_NumTurnsActive
                             ];
                [newFileString appendString:nextLine];
                
                nextLine = [NSMutableString stringWithFormat:@"%-10.1d%-10.1d%-10.3f%-10.3f\r\n",
                             nextSegment->m_NumStrandsPerTurn,
                             nextSegment->m_NumStrandsPerLayer,
                             nextSegment->m_StrandR,
                             nextSegment->m_StrandA
                             ];
                [newFileString appendString:nextLine];
                
                
                nextSegment = nextSegment->m_Next;
                
            } // end while (nextSegment != NULL)
            
            nextLayer = nextLayer->GetNext();
            
        } // end while (nextLayer != NULL)
        
        nextWinding = nextWinding->GetNext();
        
    } // end while (nextWinding != NULL) [segment]
    
    NSError *writeError;
    
    BOOL fileWrite = [newFileString writeToFile:wPath atomically:NO encoding:NSUTF8StringEncoding error:&writeError];
    
    if (!fileWrite)
    {
        NSLog(@"Error writing file!");
    }

}

- (BOOL)currentTransformerIsSaveable
{
    
	if (!_currentTxfo->m_IsValid)
	{
		NSLog(@"Transformer is not valid");
		return NO;
	}
    
	if (_currentTxfo->m_NumTerminals == 0)
	{
		NSLog(@"Terminals are not defined!");
		return NO;
	}
    
	if (!_currentTxfo->TerminalsHaveWindings())
	{
		NSLog(@"The transformer has no windings defined for it!");
		return NO;
	}
    
	if (_currentTxfo->VerifyTransformer() != NO_TXFO_ERROR)
    {
        NSLog(@"Error in transformer definition!");
        return NO;
    }
    
	return YES;
}

#pragma mark -
#pragma mark Routines for inputting an Excel-generated design file & Recent files

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
        NSAlert *errAlert = [NSAlert alertWithMessageText:@"Bad Input File!" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Can't open input file: Error code #%d", inputResult];
        
        [errAlert runModal]; // we don't care about the result of the runModal call
        
        delete xlTxfo;
        
        return NO;
    }
    
    NSURL *docURL = [NSURL fileURLWithPath:fName];
    
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:docURL];
    
    [[NSUserDefaults standardUserDefaults] setURL:docURL forKey:LAST_OPENED_INPUT_FILE_KEY];
    
    _currentTxfo = xlTxfo;
    _currentTxfo->m_IsValid = YES;
    
    [self updateAllViews];
    
    return YES;
}


@end







