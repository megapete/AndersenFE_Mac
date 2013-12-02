#pragma once


// CChangeSegmentDlog dialog

class CChangeSegmentDlog
{
	

public:
	CChangeSegmentDlog();   // standard constructor
	virtual ~CChangeSegmentDlog();



public:
	double m_StrandsPerTurn;
	double m_StrandsRadially;
	double m_StrandR;
	double m_StrandA;
    
    int DoModal();
};
