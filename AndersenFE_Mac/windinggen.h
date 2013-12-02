#if !defined(AFX_WINDINGGEN_H__85324C69_BC2C_403F_850F_5FACB352A64B__INCLUDED_)
#define AFX_WINDINGGEN_H__85324C69_BC2C_403F_850F_5FACB352A64B__INCLUDED_

#include "Winding.h"	// Added by ClassView

// WindingGen dialog

class WindingGen
{
// Construction

public:
	Winding* m_OldWinding;
	BOOL InitModifyDialog();
	bool m_IsModify;
	void EnableSectionBoxes(BOOL wState = TRUE);
	int m_NumTermsDefined;

	WindingGen();

// Dialog Data
	
	double	m_CtlBetweenSections;
	double	m_CtlNumSections;
	int	m_CtlTerm1;
	CString	m_CtlNumStrandText;
	int	m_CtlNumStrands;
	int		m_Terminal;
	int		m_Material;
	double	m_InnerDiameter;
	double	m_RadOverbuild;
	double	m_ElHeight;
	int		m_NumSections;
	int		m_CurrDirection;
	int		m_NumDucts;
	double	m_DuctDim;
	int		m_NoCondAxial;
	int		m_NoCondRadial;
	int		m_NoStrands;
	double	m_StrandAxialDImn;
	double	m_StrandRadialDimn;
	int		m_CondType;
	double	m_CondCover;
	double	m_BetSections;
	int		m_Type;
    
    int DoModal();
	
};



#endif // !defined(AFX_WINDINGGEN_H__85324C69_BC2C_403F_850F_5FACB352A64B__INCLUDED_)
