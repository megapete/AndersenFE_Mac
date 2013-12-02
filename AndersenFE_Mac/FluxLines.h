// FluxLines.h: interface for the CFluxLines class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_FLUXLINES_H__CE6BC741_A4D8_4D70_9225_ED7A23DA6BC1__INCLUDED_)
#define AFX_FLUXLINES_H__CE6BC741_A4D8_4D70_9225_ED7A23DA6BC1__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class CFluxLines  
{
public:
	void SetY(double y);
	void SetX(double x);
	CFluxLines* NextHead();
	void AddHead(CFluxLines* wHead);
	void Insert(CFluxLines* wPrev, bool atTail = false);
	void Remove(bool removeAll = false);
	CFluxLines(double x, double y, CFluxLines* wPrev = NULL);
	void SetPoint(double x, double y);
	void SetNext(CFluxLines* wPoint);
	double Y();
	double X();
	CFluxLines* Prev();
	CFluxLines* Next();
	
	CFluxLines();
	virtual ~CFluxLines();

private:
	void SetPrev(CFluxLines* wPoint);
	double m_Y;
	double m_X;
	CFluxLines* m_NextHead;
	CFluxLines* m_Next;
	CFluxLines* m_Prev;

};

#endif // !defined(AFX_FLUXLINES_H__CE6BC741_A4D8_4D70_9225_ED7A23DA6BC1__INCLUDED_)
