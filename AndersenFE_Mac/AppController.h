//
//  AppController.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 11/30/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LAST_OPENED_INPUT_FILE_KEY  @"LastInputFile"

@class AndersenFE_View;
@class PCH_AndersenFE_TxfoView;
@class PCH_AndersenFE_TerminalView;
@class AndersenFE_TxfoDataView;
@class AppController;

// Struct definition for the ObjC object
struct AppControllerImpl
{
    AppController __unsafe_unretained *theAppController;
};

@interface AppController : NSObject <NSWindowDelegate, NSUserInterfaceValidations>

- (BOOL)openInputFile:(NSString *)fName;

- (IBAction)setDosboxAppLocation:(id)sender;
- (IBAction)setDosboxCdriveLocation:(id)sender;

// IB connection to main view
@property (strong) IBOutlet AndersenFE_View *theMainView;
@property (weak) IBOutlet PCH_AndersenFE_TxfoView *theTxfoView;
@property (weak) IBOutlet AndersenFE_TxfoDataView *theTxfoData;
@property (weak) IBOutlet PCH_AndersenFE_TerminalView *theTerminalView;

// IB Connections to Terminal View
@property NSArray *terminalData;
@property (weak) IBOutlet NSTextField *term1Data;
@property (weak) IBOutlet NSTextField *term2Data;
@property (weak) IBOutlet NSTextField *term3Data;
@property (weak) IBOutlet NSTextField *term4Data;
@property (weak) IBOutlet NSTextField *term5Data;
@property (weak) IBOutlet NSTextField *term6Data;

// IB Connecttions to Transformer Data Fields
@property (weak) IBOutlet NSTextField *voltsPerTurnField;
@property (weak) IBOutlet NSTextField *ampereTurnsField;
@property (weak) IBOutlet NSTextField *txfoImpedanceField;
@property (weak) IBOutlet NSTextField *stressImpedanceField;
@property (weak) IBOutlet NSTextField *eddyLossField;
@property (weak) IBOutlet NSTextField *radialForcesField;
@property (weak) IBOutlet NSTextField *axialForcesField;
@property (weak) IBOutlet NSTextField *endThrustField;


- (void)handleTxfoChanges;

- (void)setVPNRefToTermNumber:(int)wTerm;

- (void)handleModifyOfTermNumber:(int)wTerm;

- (void)changeFanStageWithDirection:(int)fanStageDirection;
- (int)currentTxfoCoolingStage;

- (void)setMVAToZeroForTerminal:(int)wTerm;
- (void)setMVAToBalanceAmpTurnsForTerminal:(int)wTerm;
- (void)setMVAToNumberForTerminal:(int)wTerm;

- (void)updateAllViews;
- (void)updateTxfoView;
- (void)updateTxfoDataView;
- (void)updateTerminalView;

- (IBAction)openXLDesignFile:(id)sender;

- (BOOL)runAndersenForCurrentTransformerWithError:(NSError **)wError;

- (BOOL)andersenFoldersAreValid;

- (IBAction)saveAndersenFile:(id)sender;
- (BOOL)currentTransformerIsSaveable;
- (void)savecCurrentTxfoAsAndersenFile:(NSString *)wPath;

// Flux line stuff
- (IBAction)handleShowFluxLines:(id)sender;
@property (weak) IBOutlet NSMenuItem *showFluxLinesMenuItem;

@end
