//
//  CStdioFile.cpp
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#include "CStdioFile.h"
#import <Foundation/Foundation.h>

struct NSFileImpl
{
    NSFileHandle *fileHandle;
};

CStdioFile::CStdioFile()
: CFile()
{
    openFlags |= CFile::typeText;
}

CStdioFile::CStdioFile(CString fName, int flags)
: CFile(fName, flags)
{
    openFlags |= CFile::typeText;
}

BOOL CStdioFile::ReadString(CString& wLine)
{
    // overwrite anything that may already be in wLine
    wLine = "";
    
    if (!fileImpl->fileHandle)
    {
        NSLog(@"File handle is invalid!");
        return false;
    }
    
    // priming read
    NSData *nextChar = [fileImpl->fileHandle readDataOfLength:1];
    while ([nextChar length] > 0)
    {
        char theChar = *(char *)[nextChar bytes];
        
        // take care of CR/LF nonsense
        if ((theChar == '\r') || (theChar == '\n'))
        {
            // save the old file pointer
            unsigned long long filePointer = [fileImpl->fileHandle offsetInFile];
            
            // read (peek at) the next character
            nextChar = [fileImpl->fileHandle readDataOfLength:1];
            
            if ([nextChar length] == 0) // end of file, just return
            {
                return true;
            }
            
            theChar = *(char *)[nextChar bytes];
            if ((theChar == '\r') || (theChar == '\n'))
            {
                return true;
            }
            
            // next character wasn't either CR or LF, so reset the file pointer and return
            [fileImpl->fileHandle seekToFileOffset:filePointer];
            
            return true;
        }
        
        wLine += theChar;
        
        nextChar = [fileImpl->fileHandle readDataOfLength:1];
    }
    
    return true;
}

void CStdioFile::WriteString(CString& wLine)
{
    if (!fileImpl->fileHandle)
    {
        NSLog(@"File handle is invalid!");
        return;
    }
    
    NSString *lineString = [NSString stringWithCString:wLine.c_str() encoding:[NSString defaultCStringEncoding]];
    NSMutableData *lineStringData = [NSMutableData dataWithData:[lineString dataUsingEncoding:[NSString defaultCStringEncoding]]];
    
    char crlf[2] = {'\r', '\n'};
    [lineStringData appendBytes:crlf length:2];
    
    [fileImpl->fileHandle writeData:lineStringData];
    
}




