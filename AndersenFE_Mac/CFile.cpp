//
//  CFile.cpp
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#include "CFile.h"

const int CFile::modeCreate =      0b00000001;
const int CFile::modeRead =        0b00000010;
const int CFile::shareDenyWrite =  0b00000100;
const int CFile::modeWrite =       0b00001000;
const int CFile::shareExclusive =  0b00010000;
const int CFile::typeText =        0b00100000;

CFile::CFile()
{
    
}

BOOL CFile::Open(CString fName, uint nOpenFlags, void* pError)
{
    
    return true;
}

void CFile::Close()
{
    
}

void CFile::Remove(CString fName)
{
    
}

void CFile::Rename(CString oldName, CString newName)
{
    
}

uint CFile::Read(void* buffer, uint nCount)
{
    return 0;
}