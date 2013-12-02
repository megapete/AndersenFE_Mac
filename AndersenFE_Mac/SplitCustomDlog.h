#pragma once


// CSplitCustomDlog dialog

class CSplitCustomDlog
{
	

public:
	CSplitCustomDlog();   // standard constructor
	virtual ~CSplitCustomDlog();


public:
	double m_NumTurns;
public:
	double m_Z;
public:
	double m_Gap;
    
    int DoModal();
};
