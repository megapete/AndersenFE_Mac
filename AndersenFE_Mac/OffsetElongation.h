#if !defined(AFX_OFFSETELONGATION_H__407687FE_0C2A_42DE_A786_1B6F7A55DDCB__INCLUDED_)
#define AFX_OFFSETELONGATION_H__407687FE_0C2A_42DE_A786_1B6F7A55DDCB__INCLUDED_


//

/////////////////////////////////////////////////////////////////////////////
// COffsetElongation dialog

class COffsetElongation
{
// Construction
public:
	COffsetElongation();   // standard constructor

// Dialog Data
	
	double	m_ImpUseEditField;
	double	m_ImpUseCalcRadioButton;
	double	m_UseValueEditField;
	BOOL	m_UseThisRadioButton;
	BOOL	m_FindValueRadioButton;
	int		m_Operation;
	double	m_ForceValue;
	double	m_ProofStress;
	double	m_MaxEndThrust;
	int		m_FindMaxValue;
	int		m_ImpUseCalc;
	double	m_ImpUseThis;
	

    int DoModal();

};



#endif // !defined(AFX_OFFSETELONGATION_H__407687FE_0C2A_42DE_A786_1B6F7A55DDCB__INCLUDED_)
