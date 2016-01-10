//
//  stdafx.h
//  AndersenFE_Mac
//
//  Created by Peter Huber on 11/30/2013.
//  Copyright (c) 2013 Peter Huber. All rights reserved.
//

#ifndef AndersenFE_Mac_stdafx_h
#define AndersenFE_Mac_stdafx_h

#include <stdlib.h>
#include <iostream>
#include <math.h>
#include <sys/time.h>
#include <unistd.h>
#include <signal.h>
#include <string>

typedef long DWORD;
typedef signed char BOOL;
typedef std::string CString;

#define FALSE   0
#define TRUE    1

#define IDCANCEL    0
#define IDOK        1

/*
#define max(x,y) ((x) > (y) ? (x) : (y))
#define min(x,y) ((x) < (y) ? (x) : (y))
*/

/*
void *theOneAndOnlyApp = NULL;

inline void* AfxGetApp()
{
    return theOneAndOnlyApp;
}
 */

inline std::string string_format(const std::string fmt_str, ...) {
    long final_n;
    unsigned long n = fmt_str.size() * 2; /* reserve 2 times as much as the length of the fmt_str */
    std::string str;
    std::unique_ptr<char[]> formatted;
    va_list ap;
    while(1) {
        formatted.reset(new char[n]); /* wrap the plain char array into the unique_ptr */
        strcpy(&formatted[0], fmt_str.c_str());
        va_start(ap, fmt_str);
        final_n = vsnprintf(&formatted[0], n, fmt_str.c_str(), ap);
        va_end(ap);
        if (final_n < 0 || final_n >= n)
            n += (final_n - n + 1);
        else
            break;
    }
    return std::string(formatted.get());
}

inline void TRACE(const char *wMessage)
{
    std::cerr << wMessage << std::endl;
}

inline const char* _T(const char *wString)
{
    return wString;
}

inline void ASSERT(BOOL wCond)
{
    
#ifdef DEBUG
    
    if (!wCond)
    {
        TRACE("An ASSERT has occurred. DANGER, Will Robinson!");
        kill(getpid(), SIGINT);
    }
    
#endif
    
}


#endif
