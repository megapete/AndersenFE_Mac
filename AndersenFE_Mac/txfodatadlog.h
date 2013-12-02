#if !defined(AFX_TXFODATADLOG_H__7CE9C53A_713A_4497_A837_EFBEB92F3F62__INCLUDED_)
#define AFX_TXFODATADLOG_H__7CE9C53A_713A_4497_A837_EFBEB92F3F62__INCLUDED_

#include <string>

/////////////////////////////////////////////////////////////////////////////
// TxfoDataDlog dialog

struct txfoDataDlogImpl;

class TxfoDataDlog
{
    txfoDataDlogImpl *dlogImpl;
    
// Construction
public:
	TxfoDataDlog();   // standard constructor

// Dialog Data
	int		m_singlephase;
	double	m_frequency;
	int		m_limbs;
	double	m_clearance;
	double	m_winheight;
	double	m_coredia;
	double	m_sysGVA;
	double	m_peakfactor;
    std::string	m_Description;
	double	m_LowerBoundary;
	

    int DoModal();

};



#endif // !defined(AFX_TXFODATADLOG_H__7CE9C53A_713A_4497_A837_EFBEB92F3F62__INCLUDED_)
