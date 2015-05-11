//
//  AppController.m
//  AndersenFE_Mac
//
//  Created by Peter Huber on 11/30/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import "AppController.h"
// #import "mainfrm.h"
#import "andersenfe.h"
#import "PCH_AndersenFE_TxfoView.h"
#import "AndersenFE_TxfoDataView.h"
#import "PCH_AndersenFE_TerminalView.h"
#import "PCH_SegmentPath.h"
#import "PCH_OffsetElongationDlog.h"


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

#define DOSBOX_APP_LOCATION_KEY      @"DosBoxAppLoc"
#define DOSBOS_CDRIVE_LOCATION_KEY   @"DosBoxC_Loc"

@interface AppController()
{
    CMainFrame *_theMainFrame;
    CAndersenFEApp *_theApp;
    
    Transformer *_currentTxfo;
}

@property NSURL *dosBoxAppURL;
@property NSURL *dosBoxCDriveURL;

@property NSArray *colorArray;

- (BOOL)transformerIsSaveable:(Transformer *)wTxfo;
- (void)saveTxfo:(Transformer *)wTxfo asAndersenFile:(NSString *)wPath;
- (void)saveTxfo:(Transformer *)wTxfo asAndersenFileURL:(NSURL *)wURL;

- (void)setOutputDataForTransformer:(Transformer *)wTxfo withFileURL:(NSURL *)outputURL;

- (BOOL)runAndersenWithTxfo:(Transformer *)wTxfo withError:(NSError **)wError;

- (void)getDefaultDosboxLocations;
- (BOOL)setDefaultDosboxApplicationLocation:(NSURL *)appDirURL;
- (BOOL)setDefaultDosboxCdriveLocation:(NSURL *)cLocation;

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
        
        [self getDefaultDosboxLocations];
        
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
        
        if (_currentTxfo->m_AndersenOutputIsValid)
        {
            [self.txfoImpedanceField setStringValue:[NSString stringWithFormat:@"Transformer Impedance\n%.2f%% @ %.3f MVA", _currentTxfo->m_Impedance[0], _currentTxfo->m_Impedance[1]]];
            
            [self.stressImpedanceField setStringValue:[NSString stringWithFormat:@"Stress Calc. Impedance\n%.2f%% @ %.3f MVA", _currentTxfo->m_Impedance[2], _currentTxfo->m_Impedance[1]]];
            
            NSMutableString *eddyLossString = [NSMutableString stringWithString:@"Eddy Losses"];
            Terminal *nextTerm = _currentTxfo->GetTermHead();
            while (nextTerm != NULL)
            {
                [eddyLossString appendFormat:@"\nTerminal: %d: %.1f%%", nextTerm->m_Number, nextTerm->m_EddyPercent];
                
                nextTerm = nextTerm->GetNext();
            }
            
            [self.eddyLossField setStringValue:eddyLossString];
            
            [self.radialForcesField setStringValue:[NSString stringWithFormat:@"Radial Forces\nMax. Hoop: %.1f psi\nMax. Comp: %.1f psi\nMin. Rad. Supports: %.1f", _currentTxfo->m_MaxHoopStress, _currentTxfo->m_MaxCompStress, _currentTxfo->m_MinRadSupports]];
            
            [self.axialForcesField setStringValue:[NSString stringWithFormat:@"Axial Forces\nIn Spacer Blocks: %.1f psi\nCombined: %.1f psi", _currentTxfo->m_MaxAxialStress, _currentTxfo->m_MaxCombinedStress]];
            
            [self.endThrustField setStringValue:[NSString stringWithFormat:@"End Thrust\nTop: %.1f lbs\nBottom: %.1f lbs", _currentTxfo->m_TopEndThrust, _currentTxfo->m_BottomEndThrust]];
            
        }
        else
        {
            [self.txfoImpedanceField setStringValue:[NSString stringWithFormat:@"Transformer Impedance\n%.2f%% @ %.3f MVA", 0.0, 0.0]];
            
            [self.stressImpedanceField setStringValue:[NSString stringWithFormat:@"Stress Calc. Impedance\n%.2f%% @ %.3f MVA", 0.0, 0.0]];
            
            [self.eddyLossField setStringValue:@"Eddy Losses"];
            
            [self.radialForcesField setStringValue:@"Radial Forces"];
            
            [self.axialForcesField setStringValue:@"Axial Forces"];
            
            [self.endThrustField setStringValue:@"End Thrust"];
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
#pragma mark Setting/Getting transformer characteristics

- (void)setMVAToZeroForTerminal:(int)wTerm
{
    Terminal* nextTerm = _currentTxfo->GetTermHead();
    
    while (nextTerm != NULL)
    {
        if (nextTerm->m_Number == (wTerm + 1))
        {
            nextTerm->m_MVA = 0.0;
            break;
        }
        
        nextTerm = nextTerm->GetNext();
    }
    
    if (nextTerm != NULL)
    {
        [self handleTxfoChanges];
    }
}


- (void)setMVAToBalanceAmpTurnsForTerminal:(int)wTerm
{
    // first we need to set the amp-turns to zero for this terminal
    Terminal* targetTerm = _currentTxfo->GetTermHead();
    while (targetTerm != NULL)
    {
        if (targetTerm->m_Number == (wTerm + 1))
        {
            targetTerm->m_MVA = 0.0;
            break;
        }
        
        targetTerm = targetTerm->GetNext();
    }
    
    if (targetTerm == NULL)
    {
        NSLog(@"Undefined terminal number");
        return;
    }
    
    double ampTurns = _currentTxfo->AmpTurns();
    if (fabs(ampTurns) <= 10)
    {
        return;
    }
    
    
    
    Winding *nextWinding = _currentTxfo->GetWdgHead();
    double cumTurns = 0.0;
    while (nextWinding != NULL)
    {
        if (nextWinding->m_Terminal == wTerm + 1)
        {
            cumTurns += nextWinding->GetActiveTurns() * nextWinding->m_CurrentDirection;
        }
        
        nextWinding = nextWinding->GetNext();
    }
    
    if (cumTurns == 0.0)
    {
        return;
    }
    
    double termAmpsRequired = -(ampTurns / cumTurns);
    
    double mvPerLeg = cumTurns * _currentTxfo->m_VoltsPerTurn / 1.0E6;
    
	if (targetTerm->m_Connection != SINGLE)
	{
		if (targetTerm->m_Connection != DELTA)
			mvPerLeg /= sqrt(3.0);
	}
    
    targetTerm->m_MVA = mvPerLeg * termAmpsRequired * (targetTerm->m_Connection == SINGLE ? 1.0 : 3.0);
    
    [self handleTxfoChanges];
    
}

- (int)currentTxfoCoolingStage
{
    return _currentTxfo->m_CurrentCoolingStage;
}

- (void)changeFanStageWithDirection:(int)fanStageDirection
{
    // clamp fanStageDirection to -1,0,1
    fanStageDirection = MAX(fanStageDirection, -1);
    fanStageDirection = MIN(fanStageDirection, 1);
    
    int newCoolingStage = _currentTxfo->m_CurrentCoolingStage + fanStageDirection;
    
    newCoolingStage = MAX(newCoolingStage, COOLING_STAGE_ONAN);
    newCoolingStage = MIN(newCoolingStage, COOLING_STAGE_ONAFF);
    
    if (newCoolingStage != _currentTxfo->m_CurrentCoolingStage)
    {
        double newMVAMultiplier = (_currentTxfo->CoolingPerUnit(newCoolingStage)) / (_currentTxfo->CoolingPerUnit(_currentTxfo->m_CurrentCoolingStage));
        
        _currentTxfo->m_CurrentCoolingStage = newCoolingStage;
        
        Terminal* nextTerm = _currentTxfo->GetTermHead();
        
        while (nextTerm != NULL)
        {
            nextTerm->m_MVA *= newMVAMultiplier;
            nextTerm = nextTerm->GetNext();
        }
        
        [self handleTxfoChanges];
    }
}

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
    
    // Use the last-opened input file directory as the default location (if none, use Documents).
    NSString *docDirPath = @"~/Documents";
    docDirPath = [docDirPath stringByExpandingTildeInPath];
    NSURL *docDirectory = [NSURL fileURLWithPath:docDirPath isDirectory:YES];
    
    if (NSURL *lastInputFile = [[NSUserDefaults standardUserDefaults] URLForKey:LAST_OPENED_INPUT_FILE_KEY])
    {
        NSMutableArray *pComps = [NSMutableArray arrayWithArray:[lastInputFile pathComponents]];
        [pComps removeLastObject];
        
        docDirectory = [NSURL fileURLWithPathComponents:pComps];
    }
    
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
    [self saveTxfo:NULL asAndersenFile:wPath];
}

- (void)saveTxfo:(Transformer *)wTxfo asAndersenFileURL:(NSURL *)wURL
{
    [self saveTxfo:wTxfo asAndersenFile:[wURL path]];
}

- (void)saveTxfo:(Transformer *)wTxfo asAndersenFile:(NSString *)wPath
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
    
    if (wTxfo == NULL)
    {
        wTxfo = _currentTxfo;
    }
    
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
    return [self transformerIsSaveable:_currentTxfo];
}

- (BOOL)transformerIsSaveable:(Transformer *)wTxfo
{
    
	if (!wTxfo->m_IsValid)
	{
		NSLog(@"Transformer is not valid");
		return NO;
	}
    
	if (wTxfo->m_NumTerminals == 0)
	{
		NSLog(@"Terminals are not defined!");
		return NO;
	}
    
	if (!wTxfo->TerminalsHaveWindings())
	{
		NSLog(@"The transformer has no windings defined for it!");
		return NO;
	}
    
	if (wTxfo->VerifyTransformer() != NO_TXFO_ERROR)
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
    
    // if there was a successful opening of a file, try setting the default directory to the same as that file's directory
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


#pragma mark -
#pragma mark DOSBox menu handlers & other associated stuff

- (BOOL)runAndersenForCurrentTransformerWithError:(NSError *__autoreleasing *)wError
{
    return [self runAndersenWithTxfo:NULL withError:wError];
}

- (BOOL)runAndersenWithTxfo:(Transformer *)wTxfo withError:(NSError *__autoreleasing *)wError
{
    if (wTxfo == NULL)
    {
        wTxfo = _currentTxfo;
    }
    
    if (![self transformerIsSaveable:wTxfo])
    {
        NSLog(@"Transformer is not saveable (should be checked in calling routine)");
        return NO;
    }
    
    // remove the files that will be created by Andersen
    NSFileManager *defMgr = [NSFileManager defaultManager];
    NSURL *fld12URL = [self.dosBoxCDriveURL URLByAppendingPathComponent:@"FLD12"];
    // NSURL *fld8URL = [self.dosBoxCDriveURL URLByAppendingPathComponent:@"FLD8"];
    NSURL *graphicsURL = [self.dosBoxCDriveURL URLByAppendingPathComponent:@"graphics"];
    
    if (![defMgr removeItemAtURL:[fld12URL URLByAppendingPathComponent:@"OUTPUT"] error:wError])
    {
        if (!([*wError code] == NSFileNoSuchFileError))
        {
            return NO;
        }
    }
    
    if (![defMgr removeItemAtURL:[fld12URL URLByAppendingPathComponent:@"INP1.FIL"] error:wError])
    {
        if (!([*wError code] == NSFileNoSuchFileError))
        {
            return NO;
        }
    }
    
    if (![defMgr removeItemAtURL:[fld12URL URLByAppendingPathComponent:@"INP2.FIL"] error:wError])
    {
        if (!([*wError code] == NSFileNoSuchFileError))
        {
            return NO;
        }
    }
    
    if (![defMgr removeItemAtURL:[fld12URL URLByAppendingPathComponent:@"SEGMENT.FIL"] error:wError])
    {
        if (!([*wError code] == NSFileNoSuchFileError))
        {
            return NO;
        }
    }
    
    if (![defMgr removeItemAtURL:[graphicsURL URLByAppendingPathComponent:@"FOR.FIL"] error:wError])
    {
        if (!([*wError code] == NSFileNoSuchFileError))
        {
            return NO;
        }
    }
    
    if (![defMgr removeItemAtURL:[graphicsURL URLByAppendingPathComponent:@"BAS.FIL"] error:wError])
    {
        if (!([*wError code] == NSFileNoSuchFileError))
        {
            return NO;
        }
    }
    
    // Bring up the OffsetElongation dialog
    
    [self saveTxfo:wTxfo asAndersenFileURL:[fld12URL URLByAppendingPathComponent:@"INP1.FIL"]];
    
    NSTask *andersenTask = [[NSTask alloc] init];
    
    NSURL *launchURL = [self.dosBoxAppURL URLByAppendingPathComponent:@"DOSBox.app/Contents/MacOS/DOSBox"];
    NSURL *batchFileURL = [self.dosBoxCDriveURL URLByAppendingPathComponent:@"RUN_PH.bat"];
    
    if (![defMgr fileExistsAtPath:[batchFileURL path]])
    {
        NSLog(@"Missing RUN_PH.bat file in C:");
        return NO;
    }
    
    [andersenTask setLaunchPath:[launchURL path]];
    
    [andersenTask setArguments:[NSArray arrayWithObjects:[batchFileURL path], @"-exit", nil]];
    
    NSPipe *errPipe = [[NSPipe alloc] init];
    [andersenTask setStandardError:errPipe];
    
    @try
    {
        [andersenTask launch];
        [andersenTask waitUntilExit];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception when trying to launch clang: %@", [exception reason]);
        return NO;
    }
    
    NSURL *outputURL = [fld12URL URLByAppendingPathComponent:@"OUTPUT"];
    
    if (![defMgr fileExistsAtPath:[outputURL path]])
    {
        NSLog(@"Andersen program failed to create OUTPUT file");
        return NO;
    }
    
    wTxfo->m_AndersenOutputIsValid = YES;
    
    [self setOutputDataForTransformer:wTxfo withFileURL:outputURL];
    
    // If we get here, we have run Andersen successfully (or, more accurately, we have an OUTPUT file in FLD12), so give the user the option to save the file as something else
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    
    [savePanel setTitle:@"Andersen OUTPUT file"];
    [savePanel setMessage:@"Save the Andersen output file (press Cancel if unneeded)"];
    
    // Use the last-opened input file directory as the default location (if none, use Documents).
    NSString *docDirPath = @"~/Documents";
    docDirPath = [docDirPath stringByExpandingTildeInPath];
    NSURL *docDirectory = [NSURL fileURLWithPath:docDirPath isDirectory:YES];
    
    if (NSURL *lastInputFile = [[NSUserDefaults standardUserDefaults] URLForKey:LAST_OPENED_INPUT_FILE_KEY])
    {
        NSMutableArray *pComps = [NSMutableArray arrayWithArray:[lastInputFile pathComponents]];
        [pComps removeLastObject];
        
        docDirectory = [NSURL fileURLWithPathComponents:pComps];
    }
    
    [savePanel setDirectoryURL:docDirectory];
    
    NSInteger runResult = [savePanel runModal];
    
    [savePanel orderOut:nil];
    
    if (runResult == NSFileHandlingPanelOKButton)
    {
        NSError *saveError;
        
        if (![defMgr copyItemAtURL:outputURL toURL:[savePanel URL] error:&saveError])
        {
            NSLog(@"Error  while copying OUTPUT file: %@", [saveError localizedDescription]);
            
            return NO;
        }
    }
    
    [self updateTxfoDataView];
    
    return NO;
}

- (void)setOutputDataForTransformer:(Transformer *)wTxfo withFileURL:(NSURL *)outputURL
{
    NSError *theError;
    
    NSString *theFile = [NSString stringWithContentsOfURL:outputURL encoding:NSUTF8StringEncoding error:&theError];
    
    if (!theFile)
    {
        NSLog(@"Could not read OUTPUT file: %@", [theError localizedDescription]);
        return;
    }
    
    NSArray *fileLines = [theFile componentsSeparatedByString:@"\n"];
    
    // For now, this routine follows the logic of the old MFC program which only used the "per segment" data to extract the "MAX. ACCUM. AXIALLY" data for use in figuring out tilting forces - after that only the critical stresses (ie: maximumums of all the segments) are extracted and presented. This should probably be changed to show the "per winding" max stresses or something.
    
    NSString *wFindString1 = @"MAX. ACCUM. AXIALLY,";
    
    Winding* nextWdg = wTxfo->GetWdgHead();
    Layer* nextLayer;
    Segment* nextSeg;
    
    int nLine = 0;
    
    NSCharacterSet *crlf = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
    
    while (nextWdg != NULL)
    {
        nextLayer = nextWdg->m_LayerHead;
        while (nextLayer != NULL)
        {
            nextSeg = nextLayer->m_SegmentHead;
            while (nextSeg != NULL)
            {
                while (nLine < fileLines.count)
                {
                    NSString *nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
                    
                    nLine++;
                    
                    if ([nextString rangeOfString:wFindString1].location != NSNotFound)
                    {
                        // nextSeg->m_MaxAccumAxiallyLbs = (double)atof(nLine.Right(12));
                        // CString::Right(x) := -[NSString substringWithRange:NSMakeRange(NSString.length - x, x)
                        NSRange infoRange = NSMakeRange(nextString.length - 12, 12);
                        nextSeg->m_MaxAccumAxiallyLbs = [[nextString substringWithRange:infoRange] doubleValue];
                        break;
                    }
                }
                
                nextSeg = nextSeg->m_Next;
            }
            
            nextLayer = nextLayer->GetNext();
        }
        
        nextWdg = nextWdg->GetNext();
    }
    
    wFindString1 = @"CRITICAL STRESSES ETC.";
    while (nLine < fileLines.count)
    {
        NSString *nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
        nLine++;
        
        if ([nextString rangeOfString:wFindString1].location != NSNotFound)
        {
            // bump past next line
            nLine++;
            nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
            NSRange infoRange = NSMakeRange(21, 13);
            wTxfo->m_MaxHoopStress = [[nextString substringWithRange:infoRange] doubleValue];
            
            nLine++;
            nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
            infoRange = NSMakeRange(25, 9);
            wTxfo->m_MaxCompStress = [[nextString substringWithRange:infoRange] doubleValue];
            
            nLine++;
            nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
            infoRange = NSMakeRange(28, 5);
            wTxfo->m_MinRadSupports = [[nextString substringWithRange:infoRange] doubleValue];
            
            nLine += 2;
            nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
            infoRange = NSMakeRange(44, 8);
            wTxfo->m_MaxAxialStress = [[nextString substringWithRange:infoRange] doubleValue];
            
            nLine += 2;
            nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
            infoRange = NSMakeRange(34, 9);
            wTxfo->m_MaxCombinedStress = [[nextString substringWithRange:infoRange] doubleValue];
            nLine++;
            
            break;
        }
    }
    
    wFindString1 = @"BASED ON MAGNETIC ENERGY";
    while (nLine < fileLines.count)
    {
        NSString *nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
        nLine++;
        
        if ([nextString rangeOfString:wFindString1].location != NSNotFound)
        {
            NSRange infoRange = NSMakeRange(nextString.length - 8, 8);
            wTxfo->m_Impedance[1] = [[nextString substringWithRange:infoRange] doubleValue];
            break;
        }
    }
    
    wFindString1 = @"IMPEDANCE";
    while (nLine < fileLines.count)
    {
        NSString *nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
        nLine++;
        
        if ([nextString rangeOfString:wFindString1].location != NSNotFound)
        {
            nextString = [nextString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t "]];
            
            // CString::Right(x) := -[NSString substringWithRange:NSMakeRange(NSString.length - x, x)
            // x = nextString.length - wFindString1.length
            NSRange infoRange = NSMakeRange(wFindString1.length, nextString.length - wFindString1.length);
            wTxfo->m_Impedance[0] = [[nextString substringWithRange:infoRange] doubleValue] * 100.0;
            wTxfo->m_Impedance[2] = wTxfo->m_Impedance[0];
            break;
        }
    }
    
    wFindString1 = @"PU IMPEDANCE USED IN CALCULATIONS OF FORCES AND STRESSES";
    while (nLine < fileLines.count)
    {
        NSString *nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
        nLine++;
        
        if ([nextString rangeOfString:wFindString1].location != NSNotFound)
        {
            nextString = [nextString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t "]];
            
            // CString::Right(x) := -[NSString substringWithRange:NSMakeRange(NSString.length - x, x)
            // x = nextString.length - wFindString1.length
            NSRange infoRange = NSMakeRange(wFindString1.length, nextString.length - wFindString1.length);
            wTxfo->m_Impedance[2] = [[nextString substringWithRange:infoRange] doubleValue] * 100.0;
            break;
        }
    }
    
    wFindString1 = @"TERMINAL NUMBER";
    
    for (int i=1; i<=wTxfo->m_NumTerminals; i++)
    {
        while (nLine < fileLines.count)
        {
            NSString *nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
            nLine++;
            
            if ([nextString rangeOfString:wFindString1].location != NSNotFound)
            {
                nLine += 2;
                NSString *nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
                nLine++;
                
                NSRange infoRange = NSMakeRange(nextString.length - 7, 7);
                wTxfo->GetTermHead()->SetEddyPercent(i, [[nextString substringWithRange:infoRange] doubleValue] * 100.0);
                break;
            }
        }
    }
    
    wFindString1 = @", UPPER SUPPORT";
    while (nLine < fileLines.count)
    {
        NSString *nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
        nLine++;
        
        if ([nextString rangeOfString:wFindString1].location != NSNotFound)
        {
            NSRange infoRange = NSMakeRange(nextString.length - 10, 10);
            wTxfo->m_TopEndThrust = [[nextString substringWithRange:infoRange] doubleValue];
            
            NSString *nextString = [fileLines[nLine] stringByTrimmingCharactersInSet:crlf];
            wTxfo->m_BottomEndThrust = [[nextString substringWithRange:infoRange] doubleValue];
            nLine++;

            break;
        }
    }
}

- (BOOL)andersenFoldersAreValid
{
    return (self.dosBoxAppURL && self.dosBoxCDriveURL);
}

- (void)getDefaultDosboxLocations
{
    NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
    NSFileManager *defMgr = [NSFileManager defaultManager];
    
    self.dosBoxAppURL = [usrDef URLForKey:DOSBOX_APP_LOCATION_KEY];
    
    // make sure that the location has an object called "DOSBox.app"
    if (self.dosBoxAppURL)
    {
        NSURL *appURL = [self.dosBoxAppURL URLByAppendingPathComponent:@"DOSBox.app"];
        
        if (![defMgr fileExistsAtPath:[appURL path]])
        {
            self.dosBoxAppURL = nil;
            
            [usrDef removeObjectForKey:DOSBOX_APP_LOCATION_KEY];
        }
    }
    
    self.dosBoxCDriveURL = [usrDef URLForKey:DOSBOS_CDRIVE_LOCATION_KEY];
    
    // make sure that the location has an object called "FLD12"
    if (self.dosBoxCDriveURL)
    {
        NSURL *cURL = [self.dosBoxCDriveURL URLByAppendingPathComponent:@"FLD12"];
        
        if (![defMgr fileExistsAtPath:[cURL path]])
        {
            self.dosBoxCDriveURL = nil;
            
            [usrDef removeObjectForKey:DOSBOS_CDRIVE_LOCATION_KEY];
        }
    }
}

- (BOOL)setDefaultDosboxApplicationLocation:(NSURL *)appDirURL
{
    NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
    NSFileManager *defMgr = [NSFileManager defaultManager];
    
    // make sure that the location has an object called "DOSBox.app"
    if (appDirURL)
    {
        NSURL *appURL = [appDirURL URLByAppendingPathComponent:@"DOSBox.app"];
        
        if ([defMgr fileExistsAtPath:[appURL path]])
        {
            self.dosBoxAppURL = appDirURL;
            
            [usrDef setURL:appDirURL forKey:DOSBOX_APP_LOCATION_KEY];
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)setDefaultDosboxCdriveLocation:(NSURL *)cLocation
{
    NSUserDefaults *usrDef = [NSUserDefaults standardUserDefaults];
    NSFileManager *defMgr = [NSFileManager defaultManager];
    
    // make sure that the location has an object called "DOSBox.app"
    if (cLocation)
    {
        NSURL *fld12URL = [cLocation URLByAppendingPathComponent:@"FLD12"];
        
        if ([defMgr fileExistsAtPath:[fld12URL path]])
        {
            self.dosBoxCDriveURL = cLocation;
            
            [usrDef setURL:cLocation forKey:DOSBOS_CDRIVE_LOCATION_KEY];
            
            return YES;
        }
    }
    
    return NO;
}

- (IBAction)setDosboxAppLocation:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setTitle:@"Find DosBox App File Directory"];
    [openPanel setMessage:@"The DosBox App is usually in /Applications"];
    
    NSURL *appDirectory = self.dosBoxAppURL;
    
    if (!appDirectory)
    {
        NSString *appDirPath = @"/Applications";
        appDirectory = [NSURL fileURLWithPath:appDirPath isDirectory:YES];
    }
    
    [openPanel setDirectoryURL:appDirectory];
    
    NSInteger runResult = [openPanel runModal];
    
    if (runResult == NSFileHandlingPanelOKButton)
    {
        if (![self setDefaultDosboxApplicationLocation:[openPanel URL]])
        {
            NSAlert *badDirectoryAlert = [[NSAlert alloc] init];
            
            [badDirectoryAlert setInformativeText:@"The directory that you specifed does NOT contain the DOSBox application!"];
            [badDirectoryAlert setMessageText:@"Bad directory!"];
            [badDirectoryAlert addButtonWithTitle:@"Ok"];
            
            [badDirectoryAlert runModal]; // we don't care about the result
        }
    }
}

- (IBAction)setDosboxCdriveLocation:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setTitle:@"Set DosBox C Drive"];
    [openPanel setMessage:@"Select the folder that contains the FLD12 and FLD8 directories"];
    
    NSURL *cDirectory = self.dosBoxCDriveURL;
    
    if (!cDirectory)
    {
        NSString *cDirPath = @"~/Documents";
        cDirPath = [cDirPath stringByExpandingTildeInPath];
        cDirectory = [NSURL fileURLWithPath:cDirPath isDirectory:YES];
    }
    
    [openPanel setDirectoryURL:cDirectory];
    
    NSInteger runResult = [openPanel runModal];
    
    if (runResult == NSFileHandlingPanelOKButton)
    {
        if (![self setDefaultDosboxCdriveLocation:[openPanel URL]])
        {
            NSAlert *badDirectoryAlert = [[NSAlert alloc] init];
            
            [badDirectoryAlert setInformativeText:@"The directory that you specifed does NOT contain FLD12!"];
            [badDirectoryAlert setMessageText:@"Bad directory!"];
            [badDirectoryAlert addButtonWithTitle:@"Ok"];
            
            [badDirectoryAlert runModal]; // we don't care about the result
        }
    }
}


@end







