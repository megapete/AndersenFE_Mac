//
//  CFile.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#ifndef __AndersenFE_Mac__CFile__
#define __AndersenFE_Mac__CFile__

#include <iostream>
#include "stdafx.h"

#define NO_ERROR    0

struct NSFileImpl;

class CFile
{
    
private:
    
    NSFileImpl *fileImpl;
    
public:
    
    static const int modeCreate;
    static const int modeRead;
    static const int modeWrite;
    static const int shareDenyWrite;
    static const int shareExclusive;
    static const int typeText;
    
    CFile();
    CFile(CString fName, uint nOpenFlags);
    virtual ~CFile();
    
    int openFlags;
    
    BOOL Open(CString fName, uint nOpenFlags, void* pError = NULL);
    void Close();
    
    uint Read(void* buffer, uint nCount);
    
    static void Remove(CString fName);
    static void Rename(CString oldName, CString newName);
};

#endif /* defined(__AndersenFE_Mac__CFile__) */
