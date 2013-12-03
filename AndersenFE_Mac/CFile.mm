//
//  CFile.cpp
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#include "CFile.h"
#include <fcntl.h>
#import <Foundation/Foundation.h>

struct NSFileImpl
{
    NSFileHandle *fileHandle;
};

const int CFile::modeCreate =      0b00000001;
const int CFile::modeRead =        0b00000010;
const int CFile::shareDenyWrite =  0b00000100;
const int CFile::modeWrite =       0b00001000;
const int CFile::shareExclusive =  0b00010000;
const int CFile::typeText =        0b00100000;

CFile::CFile()
{
    fileImpl->fileHandle = nil;
}

CFile::CFile(CString fName, uint nOpenFlags)
{
    fileImpl->fileHandle = nil;
    
    this->Open(fName, nOpenFlags);
}

CFile::~CFile()
{
    fileImpl->fileHandle = nil;
}

BOOL CFile::Open(CString fName, uint nOpenFlags, void* pError)
{
    NSString *pathName = [NSString stringWithCString:fName.c_str() encoding:[NSString defaultCStringEncoding]];
    if ([pathName characterAtIndex:0] == '~')
    {
        pathName = [pathName stringByExpandingTildeInPath];
    }
    
    if (nOpenFlags & CFile::modeCreate)
    {
        // if the file already exists, delete it, otherwise create a new file
        NSFileManager *defMgr = [NSFileManager defaultManager];
        
        if ([defMgr fileExistsAtPath:pathName])
        {
            NSError *error;
            [defMgr removeItemAtPath:pathName error:&error];
        }
        
        // create a new, empty file
        int newDesc = open([pathName cStringUsingEncoding:[NSString defaultCStringEncoding]], O_CREAT);
        if (newDesc < 0)
        {
            NSLog(@"Error creating new file");
            return false;
        }
        
        if (close(newDesc) < 0)
        {
            NSLog(@"Error closing file after creation");
            return false;
        }
    }
    
    if ((nOpenFlags & CFile::modeRead) && (nOpenFlags & CFile::modeWrite))
    {
        fileImpl->fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:pathName];
    }
    else if (nOpenFlags & CFile::modeRead)
    {
        fileImpl->fileHandle = [NSFileHandle fileHandleForReadingAtPath:pathName];
    }
    else if (nOpenFlags & CFile::modeWrite)
    {
        fileImpl->fileHandle = [NSFileHandle fileHandleForWritingAtPath:pathName];
    }
    else
    {
        NSLog(@"File must be opened for reading and/or writing!");
        return false;
    }
    
    this->openFlags = nOpenFlags;
    
    return true;
}

void CFile::Close()
{
    fileImpl->fileHandle = nil;
}

void CFile::Remove(CString fName)
{
    NSString *pathName = [NSString stringWithCString:fName.c_str() encoding:[NSString defaultCStringEncoding]];
    if ([pathName characterAtIndex:0] == '~')
    {
        pathName = [pathName stringByExpandingTildeInPath];
    }
    
    // if the file already exists, delete it, otherwise create a new file
    NSFileManager *defMgr = [NSFileManager defaultManager];
    
    if ([defMgr fileExistsAtPath:pathName])
    {
        NSError *error;
        [defMgr removeItemAtPath:pathName error:&error];
    }
}

void CFile::Rename(CString oldName, CString newName)
{
    NSString *oldPathName = [NSString stringWithCString:oldName.c_str() encoding:[NSString defaultCStringEncoding]];
    if ([oldPathName characterAtIndex:0] == '~')
    {
        oldPathName = [oldPathName stringByExpandingTildeInPath];
    }
    
    NSString *newPathName = [NSString stringWithCString:newName.c_str() encoding:[NSString defaultCStringEncoding]];
    if ([newPathName characterAtIndex:0] == '~')
    {
        newPathName = [newPathName stringByExpandingTildeInPath];
    }
}

uint CFile::Read(void* buffer, uint nCount)
{
    return 0;
}