// Duct.h: interface for the Duct class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_DUCT_H__25D1BB53_503A_4DB5_94FC_793B83C422BD__INCLUDED_)
#define AFX_DUCT_H__25D1BB53_503A_4DB5_94FC_793B83C422BD__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// duct types

#define RADIAL_DUCT 0
#define AXIAL_DUCT 1

class Duct  
{
public:
	double m_EndDim;
	double m_StartDim;
	int m_Type;
	Duct();
	virtual ~Duct();

private:
	Duct* m_Next;
};

#endif // !defined(AFX_DUCT_H__25D1BB53_503A_4DB5_94FC_793B83C422BD__INCLUDED_)
