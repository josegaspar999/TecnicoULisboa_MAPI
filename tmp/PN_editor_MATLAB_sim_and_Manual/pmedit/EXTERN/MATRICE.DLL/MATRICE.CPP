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
void Creation_Matrice (void);

// Définition des constantes
#define MAXSTR 80      

// Variables globales
HINSTANCE hinstLib=NULL;
HWND hwMain=NULL;
HMENU hMenu;
char AppName [MAXSTR];
int Matrice=2;
CMatrice *MATRICE;
CMatrice *MATRICEWm;
CMatrice *MATRICEWp;

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

	Creation_Matrice ();

	if (cmde == 0)
	{
		if (hwMain==NULL)
		{
			hwMain = CreateWindow (AppName, AppName, 
				WS_OVERLAPPEDWINDOW,
				0, 0, 400, 280, HWND_DESKTOP, LoadMenu (hinstLib, MAKEINTRESOURCE (IDR_MENU)), hinstLib, NULL);
			hMenu = GetMenu (hwMain);
		}
		CheckMenuItem (hMenu, ID_W_PLUS, Matrice==0 ? MF_CHECKED:MF_UNCHECKED);
		CheckMenuItem (hMenu, ID_W_MOINS, Matrice==1 ? MF_CHECKED:MF_UNCHECKED);
		CheckMenuItem (hMenu, ID_W, Matrice==2 ? MF_CHECKED:MF_UNCHECKED);
	
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
		delete MATRICE;
		delete MATRICEWp;
		delete MATRICEWm;
	}
	else
	{
		if (cmde == 1)
		{
			delete MATRICEWp;
			delete MATRICEWm;
			return MATRICE;
		}
		else
		{
			if (cmde == 2)
			{
				delete MATRICE;
				delete MATRICEWm;
				return MATRICEWp;
			}
			else
			{//  cmde == 3
				delete MATRICE;
				delete MATRICEWp;
				return MATRICEWm;
			}
		}
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
				case ID_W_MOINS:
					Matrice=1;
					CheckMenuItem (hMenu, ID_W_PLUS, Matrice==0 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_W_MOINS, Matrice==1 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_W, Matrice==2 ? MF_CHECKED:MF_UNCHECKED);
					InvalidateRect (hwMain, NULL, TRUE);
					break;
				case ID_W_PLUS:
					Matrice=0;
					CheckMenuItem (hMenu, ID_W_PLUS, Matrice==0 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_W_MOINS, Matrice==1 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_W, Matrice==2 ? MF_CHECKED:MF_UNCHECKED);
					InvalidateRect (hwMain, NULL, TRUE);
					break;
				case ID_W:
					Matrice=2;
					CheckMenuItem (hMenu, ID_W_PLUS, Matrice==0 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_W_MOINS, Matrice==1 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_W, Matrice==2 ? MF_CHECKED:MF_UNCHECKED);
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

int Poids1 (UINT place, UINT trans)
{
	for (int i=0 ; i < TabArc->GetSize () ; i++)
	{
		CArc *pArc = (CArc *) TabArc->GetAt (i);
		if ( (pArc->mP2T) && (pArc->mSource==place) && (pArc->mDest==trans) )
			return atoi ((const char *)pArc->mValue);
	}
	return 0;
}

int Poids2 (UINT trans, UINT place)
{
	for (int i=0 ; i < TabArc->GetSize () ; i++)
	{
		CArc *pArc = (CArc *) TabArc->GetAt (i);
		if ( (!pArc->mP2T) && (pArc->mSource==trans) && (pArc->mDest==place) )
			return atoi ((const char *)pArc->mValue);
	}
	return 0;
}

void Creation_Matrice (void)
{
	MATRICE = new CMatrice (TabPlace->GetSize (), TabTrans->GetSize ());
	MATRICEWp = new CMatrice (TabPlace->GetSize (), TabTrans->GetSize ());
	MATRICEWm = new CMatrice (TabPlace->GetSize (), TabTrans->GetSize ());

	for (int i=0 ; i<TabPlace->GetSize () ; i++)
		for (int j=0 ; j<TabTrans->GetSize () ; j++)
		{
			MATRICEWp->SetAt (i, j, Poids2 ((UINT)j, (UINT)i));
			MATRICEWm->SetAt (i, j, Poids1 ((UINT)i, (UINT)j));
		}
	*MATRICE = (*MATRICEWp) - (*MATRICEWm);
}

void Dessine (HWND hWnd)
{
	PAINTSTRUCT ps;
	HDC hDC;
	
	hDC = BeginPaint (hWnd, &ps);

	char Buf [80];
	int i,j;
	
	switch (Matrice)
	{
	 	case 0:	// W+
	 	{
 			SetTextAlign (hDC, TA_RIGHT);
 			for (i=0 ; i<MATRICEWp->GetNumColumns () ; i++)
 			{
	 			sprintf (Buf, "T%d", i+1);
	 			TextOut (hDC, 60+i*30, 6, Buf, strlen (Buf));
	 		}
	 		for (i=0 ; i<MATRICEWp->GetNumRows () ; i++)
	 		{
	 			sprintf (Buf, "P%d", i+1);
	 			SetTextAlign (hDC, TA_LEFT);
	 			TextOut (hDC, 10, 30+i*20, Buf, strlen (Buf));
	 			for (j=0 ; j<MATRICEWp->GetNumColumns () ; j++)
	 			{
	 				// Affichage de la valeur
	 				sprintf (Buf, "%d", (int)MATRICEWp->GetAt (i,j));
					SetTextAlign (hDC, TA_RIGHT);
	 				TextOut (hDC, 60+j*30, 30+i*20, Buf, strlen (Buf));
	 			}
	 		}
	 	}
	 	break;

	 	case 1:	// W-
	 	{
 			SetTextAlign (hDC, TA_RIGHT);
 			for (i=0 ; i<MATRICEWm->GetNumColumns () ; i++)
 			{
	 			sprintf (Buf, "T%d", i+1);
	 			TextOut (hDC, 60+i*30, 6, Buf, strlen (Buf));
	 		}
	 		for (i=0 ; i<MATRICEWm->GetNumRows () ; i++)
	 		{
	 			sprintf (Buf, "P%d", i+1);
	 			SetTextAlign (hDC, TA_LEFT);
	 			TextOut (hDC, 10, 30+i*20, Buf, strlen (Buf));
	 			for (j=0 ; j<MATRICEWm->GetNumColumns () ; j++)
	 			{
	 				// Affichage de la valeur
	 				sprintf (Buf, "%d", (int)MATRICEWm->GetAt (i,j));
					SetTextAlign (hDC, TA_RIGHT);
	 				TextOut (hDC, 60+j*30, 30+i*20, Buf, strlen (Buf));
	 			}
	 		}
	 	}
	 	break;

	 	case 2:	// W
	 	{
 			SetTextAlign (hDC, TA_RIGHT);
 			for (i=0 ; i<MATRICE->GetNumColumns () ; i++)
 			{
	 			sprintf (Buf, "T%d", i+1);
	 			TextOut (hDC, 60+i*30, 6, Buf, strlen (Buf));
	 		}
	 		for (i=0 ; i<MATRICE->GetNumRows () ; i++)
	 		{
	 			sprintf (Buf, "P%d", i+1);
	 			SetTextAlign (hDC, TA_LEFT);
	 			TextOut (hDC, 10, 30+i*20, Buf, strlen (Buf));
	 			for (j=0 ; j<MATRICE->GetNumColumns () ; j++)
	 			{
	 				// Affichage de la valeur
	 				sprintf (Buf, "%d", (int)MATRICE->GetAt (i,j));
					SetTextAlign (hDC, TA_RIGHT);
	 				TextOut (hDC, 60+j*30, 30+i*20, Buf, strlen (Buf));
	 			}
	 		}
	 	}
	 	break;
	}

	EndPaint (hWnd, &ps);
}
                    
