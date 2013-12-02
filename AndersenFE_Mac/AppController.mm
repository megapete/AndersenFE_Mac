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

@interface AppController()
{
    CMainFrame *theMainFrame;
    CAndersenFEApp *theApp;
}

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
        
        theApp = new CAndersenFEApp(selfImpl);
    }
    
    return self;
}

- (void)awakeFromNib
{
    theApp->InitInstance();
    
    theMainFrame = theApp->m_pMainWnd;
}

@end
