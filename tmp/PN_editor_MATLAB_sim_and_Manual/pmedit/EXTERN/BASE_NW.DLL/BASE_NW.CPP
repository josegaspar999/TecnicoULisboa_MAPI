#include <afxwin.h>
#include <string.h>
#include "resource.h"

#include "..\general\pmdoc.h"

// Variables globales
HINSTANCE hInst;
CpEditDoc *pDoc;
CObArray *TabPlace, *TabTrans, *TabArc, *TabTexte, *TabMapE, *TabMapS;

int CALLBACK LibMain (HINSTANCE hinst, WORD wDataSeg, WORD cbHeapSize, LPSTR lpszCmdLine)
{
	hInst = hinst;
	return 1;
}

int CALLBACK WEP (int bSystemExit)
{
	return 1;
}

extern "C" void FAR * FAR PASCAL __export PMFunction (CpEditDoc *pDoc, int cmde)
{
	::pDoc = pDoc;
	TabPlace = &(pDoc->mTabPlace);
	TabTrans = &(pDoc->mTabTrans);
	TabArc = &(pDoc->mTabArc);
	TabTexte = &(pDoc->mTabTexte);
	TabMapE = &(pDoc->mMapE);
	TabMapS = &(pDoc->mMapS);
	
	// Code ici...
	// Par exemple, on redessine tout :
	pDoc->UpdateAllViews (NULL);
	
	return NULL;
}

extern "C" void FAR PASCAL __export PMFunctionCopyright (char *Copyright)
{
	sprintf (Copyright, "V 1.0 US - © 1996 Alain GODON");
}
