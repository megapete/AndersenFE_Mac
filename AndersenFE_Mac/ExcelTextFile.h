// ExcelTextFile.h: interface for the CExcelTextFile class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_EXCELTEXTFILE_H__D8A95F9D_7C41_4403_BB96_A78C8EF5182C__INCLUDED_)
#define AFX_EXCELTEXTFILE_H__D8A95F9D_7C41_4403_BB96_A78C8EF5182C__INCLUDED_

#include "Transformer.h"	// Added by ClassView
#include "Winding.h"	// Added by ClassView
#include "CStdioFile.h"

// Return codes

#define NO_TXTFILE_ERROR 0
#define LINE_TXTFILE_ERROR_0	1000
// #define LINE_TXTFILE_ERROR_0	1001
// UP TO
// #define LINE_TXTFILE_ERROR_999 1999
#define WINDING_PTR_ERROR		2000


class CExcelTextFile : public CStdioFile  
{
public:
	char ExtractChar(CString &wStr, int index);
	double ExtractFloatValue(CString &wStr, int index);
	int ExtractValue(CString &wStr, int index);
	Winding* m_Windings[4];
	char ExtractChar(CString &wStr, int *wPos);
	double ExtractFloatValue(CString &wStr, int *wPos);
	int ExtractValue(CString& wStr, int* wPos);
	int CountTabs(CString &wString);
	int InputFile(Transformer *wTxfo);
	CExcelTextFile(CString lpszFileName, uint nOpenFlags );
	CExcelTextFile();
	virtual ~CExcelTextFile();

};

#endif // !defined(AFX_EXCELTEXTFILE_H__D8A95F9D_7C41_4403_BB96_A78C8EF5182C__INCLUDED_)
