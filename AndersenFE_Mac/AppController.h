//
//  AppController.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 11/30/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface AppController : NSObject

// IB connection to main view
@property (strong) IBOutlet AndersenFE_View *theMainView;
@property (weak) IBOutlet PCH_AndersenFE_TxfoView *theTxfoView;
@property (weak) IBOutlet AndersenFE_TxfoDataView *theTxfoData;
@property (weak) IBOutlet PCH_AndersenFE_TerminalView *theTerminalView;

@property NSArray *terminalData;
@property (weak) IBOutlet NSTextField *term1Data;
@property (weak) IBOutlet NSTextField *term2Data;
@property (weak) IBOutlet NSTextField *term3Data;
@property (weak) IBOutlet NSTextField *term4Data;
@property (weak) IBOutlet NSTextField *term5Data;
@property (weak) IBOutlet NSTextField *term6Data;


- (void)updateAllViews;
- (void)updateTxfoView;
- (void)updateTxfoDataView;
- (void)updateTerminalView;

- (IBAction)setDosBoxPrefsLocation:(id)sender;
- (IBAction)setDosBoxCLocation:(id)sender;

- (IBAction)openXLDesignFile:(id)sender;

@end
