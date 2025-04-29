// © 1996 Alain GODON

#include <afxwin.h>

#include "..\general\pmdoc.h"
#include "..\general\pmapi.h"
#include "..\general\cmatrice.h"

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
char NomDLL [MAXSTR];
char AppName [MAXSTR];
int Affiche=1;

// Réseau
CpEditDoc *pDoc;
CObArray *TabPlace, *TabTrans, *TabArc;

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
	
	char Buf [MAXSTR];
	LoadString (hinst, IDS_NAMEDLL, (LPSTR)NomDLL, MAXSTR);
	LoadString (hinst, IDS_APPNAME, (LPSTR)Buf, MAXSTR);
	sprintf (AppName, Buf, NomDLL);
	
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

	if (hwMain==NULL)
	{
		hwMain = CreateWindow (AppName, AppName, 
			WS_OVERLAPPEDWINDOW,
			0, 0, 400, 280, HWND_DESKTOP, LoadMenu (hinstLib, MAKEINTRESOURCE (IDR_MENU)), hinstLib, NULL);
		hMenu = GetMenu (hwMain);
	}

	CheckMenuItem (hMenu, ID_NB_PINVAR, Affiche==1 ? MF_CHECKED:MF_UNCHECKED);
	CheckMenuItem (hMenu, ID_NB_TINVAR, Affiche==2 ? MF_CHECKED:MF_UNCHECKED);
	CheckMenuItem (hMenu, ID_PINVAR, Affiche==3 ? MF_CHECKED:MF_UNCHECKED);
	CheckMenuItem (hMenu, ID_TINVAR, Affiche==4 ? MF_CHECKED:MF_UNCHECKED);

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
				case ID_NB_PINVAR:
					Affiche = 1;
					CheckMenuItem (hMenu, ID_NB_PINVAR, Affiche==1 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_PINVAR, Affiche==2 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_NB_TINVAR, Affiche==3 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_TINVAR, Affiche==4 ? MF_CHECKED:MF_UNCHECKED);
					InvalidateRect (hwMain, NULL, TRUE);
					break;
				case ID_PINVAR:
					Affiche = 2;
					CheckMenuItem (hMenu, ID_NB_PINVAR, Affiche==1 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_PINVAR, Affiche==2 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_NB_TINVAR, Affiche==3 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_TINVAR, Affiche==4 ? MF_CHECKED:MF_UNCHECKED);
					InvalidateRect (hwMain, NULL, TRUE);
					break;
				case ID_NB_TINVAR:
					Affiche = 3;
					CheckMenuItem (hMenu, ID_NB_PINVAR, Affiche==1 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_PINVAR, Affiche==2 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_NB_TINVAR, Affiche==3 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_TINVAR, Affiche==4 ? MF_CHECKED:MF_UNCHECKED);
					InvalidateRect (hwMain, NULL, TRUE);
					break;
				case ID_TINVAR:
					Affiche = 4;
					CheckMenuItem (hMenu, ID_NB_PINVAR, Affiche==1 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_PINVAR, Affiche==2 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_NB_TINVAR, Affiche==3 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_TINVAR, Affiche==4 ? MF_CHECKED:MF_UNCHECKED);
					InvalidateRect (hwMain, NULL, TRUE);
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
	char Buf [MAXSTR];
	void FAR * Ptr;
	
	hDC = BeginPaint (hWnd, &ps);

	HINSTANCE hDLL=LoadDLL (NomDLL);
	
	switch (Affiche)
	{
		case 1:		// Nb de P
			{
				Ptr = CallDLL (hDLL, pDoc, 1);
				sprintf (Buf, "Nombre de P Invariants : %d", (int)(* (int *)Ptr));
				TextOut (hDC, 10, 10, Buf, strlen (Buf));
				delete Ptr;
			}
			break;
		case 2:		// Les P
			{
				int i,j;
				int NbP = (int)(* (int *)CallDLL (hDLL, pDoc, 1));
				CMatrice *M = (CMatrice *)(CallDLL (hDLL, pDoc, 2));
						
				for (i=0 ; i<M->GetNumRows () ; i++)
					for (j=0 ; j<M->GetNumColumns () ; j++)
					{
						sprintf (Buf, "%d", (int)M->GetAt (i,j));
						TextOut (hDC, 10+20*j, 10+i*30, Buf, strlen (Buf));
					}
				delete M;
			}
			break;
		case 3:		// Nb de T
			{              
				Ptr = CallDLL (hDLL, pDoc, 3);
				sprintf (Buf, "Nombre de T Invariants : %d", (int)(* (int *)Ptr));
				TextOut (hDC, 10, 10, Buf, strlen (Buf));
				delete Ptr;
			}
			break;
		case 4:		// Les T
			{
				int i,j;
				int NbT = (int)(* (int *)CallDLL (hDLL, pDoc, 3));
				CMatrice *M = (CMatrice *)(CallDLL (hDLL, pDoc, 4));
						
				for (i=0 ; i<M->GetNumRows () ; i++)
					for (j=0 ; j<M->GetNumColumns () ; j++)
					{
						sprintf (Buf, "%d", (int)M->GetAt (i,j));
						TextOut (hDC, 10+20*j, 10+i*30, Buf, strlen (Buf));
					}
				delete M;
			}
			break;
	}
	FreeDLL (hDLL);
	
	EndPaint (hWnd, &ps);
}
                    
