//
//  CStdioFile.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 12/1/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#ifndef __AndersenFE_Mac__CStdioFile__
#define __AndersenFE_Mac__CStdioFile__

#include "CFile.h"

class CStdioFile : public CFile
{
public:
    
    CStdioFile();
    CStdioFile(CString fName, int flags);
    
    BOOL ReadString(CString& wLine);
    void WriteString(CString& wLine);
};

#endif /* defined(__AndersenFE_Mac__CStdioFile__) */
