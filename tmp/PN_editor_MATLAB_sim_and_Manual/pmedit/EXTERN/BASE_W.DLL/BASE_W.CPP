// © 1996 Alain GODON

#include <afxwin.h>

#include "..\general\pmdoc.h"
#include "resource.h"

// Fonctions
extern "C" LONG FAR PASCAL __export MainWndProc (HWND, UINT, WPARAM, LPARAM);
BOOL InitFirstInstance (HINSTANCE hinst);
void Dessine (HWND);

// Definitions
#define MAXSTR 80

// Variables globales
HINSTANCE hinstLib=NULL;
HWND hwMain=NULL;
HMENU hMenu;
char AppName [MAXSTR];
// Réseau
CpEditDoc *pDoc;
CObArray *TabPlace, *TabTrans, *TabArc, *TabTexte, *TabMapE, *TabMapS;

int CALLBACK LibMain (HINSTANCE hinst, WORD wDataSeg, WORD cbHeapSize, LPSTR lpszCmdLine)
{
	if (hinstLib==NULL)
		if (!InitFirstInstance (hinst))
			return 0;
	return 1;
}

int CALLBACK WEP (int bSystemExit)
{
	return 1;
}

BOOL InitFirstInstance (HINSTANCE hinst)
{
	WNDCLASS MainWndClass;
	
	LoadString (hinst, IDS_APPNAME, (LPSTR)AppName, MAXSTR);
	// Infos de la classe fenêtre
	MainWndClass.lpszClassName = AppName;
	MainWndClass.hInstance = hinst;
	MainWndClass.lpfnWndProc = MainWndProc;
	MainWndClass.style = CS_HREDRAW | CS_VREDRAW | CS_GLOBALCLASS;
	MainWndClass.lpszMenuName = (LPSTR) NULL;
	MainWndClass.hCursor = LoadCursor (NULL, IDC_ARROW);
	MainWndClass.hIcon = LoadIcon (hinst, MAKEINTRESOURCE (IDI_MAIN));;
	MainWndClass.hbrBackground = (HBRUSH) GetStockObject (WHITE_BRUSH);
	MainWndClass.cbClsExtra = 0;
	MainWndClass.cbWndExtra = 0;
	hinstLib = (RegisterClass (&MainWndClass)) ? hinst : NULL;
	return (hinstLib!=NULL);
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

	if (hwMain==NULL)
	{
		hwMain = CreateWindow (AppName, AppName, 
			WS_OVERLAPPEDWINDOW,
			0, 0, 400, 280, HWND_DESKTOP, LoadMenu (hinstLib, MAKEINTRESOURCE (IDR_MENU)), hinstLib, NULL);
		hMenu = GetMenu (hwMain);
	}

	ShowWindow (hwMain, SW_SHOWNORMAL);
	BringWindowToTop (hwMain);
	InvalidateRect (hwMain, NULL, TRUE);

	// Boucle de messages
	MSG msg;
	while (GetMessage (&msg, NULL, 0, 0))
	{
		TranslateMessage (&msg);
		DispatchMessage (&msg);
	}
	return NULL;
}

extern "C" void FAR PASCAL __export PMFunctionCopyright (char *Copyright)
{
	sprintf (Copyright, "V 1.0 US - © 1996 Alain GODON");
}

extern "C" LONG FAR PASCAL __export MainWndProc (HWND hwnd, UINT msg, WPARAM wP, LPARAM lP)
{
	switch (msg)
	{
		case WM_DESTROY:
			PostQuitMessage (0);
			break;
			
		case WM_COMMAND:
			// Actions du menu
			switch (wP)
			{
				case ID_REDESSINE:
					pDoc->UpdateAllViews (NULL);
					break;
				case ID_QUITTER:
					PostMessage (hwMain, WM_SYSCOMMAND, SC_CLOSE, 0);
					break;
			}
			break;
		
		case WM_PAINT:
			Dessine (hwnd);
			break;
			
		default :
			return (DefWindowProc (hwnd, msg, wP, lP));
			break;
	}
	return 0L;
}

void Dessine (HWND hWnd)
{
	PAINTSTRUCT ps;
	HDC hDC;
	
	hDC = BeginPaint (hWnd, &ps);
	TextOut (hDC, 20, 20, "Essai...", 8);
	EndPaint (hWnd, &ps);
}
                    
