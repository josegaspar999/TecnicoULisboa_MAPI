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

BOOL Creation_Invariants (void);
void Ajouter (CMatrice *, int ,int, int, int);
void Eliminer (CMatrice *, int);
void CalculP_T (CMatrice *, int, int);

// Définition des constantes
#define MAXSTR 80      

// Variables globales
HINSTANCE hinstLib=NULL;
HWND hwMain=NULL;
HMENU hMenu;
char AppName [MAXSTR];
int Invariant=1;

// Appels
void FAR *RETOUR;
int * NbP_Invar;
int * NbT_Invar;
CMatrice *MATRICEP=NULL;
CMatrice *MATRICET=NULL;

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


	BOOL res = Creation_Invariants ();
	if (cmde == 0)
	{
		if (res)
		{
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
		
			CheckMenuItem (hMenu, ID_T_INVARIANT, Invariant==0 ? MF_CHECKED:MF_UNCHECKED);
			CheckMenuItem (hMenu, ID_P_INVARIANT, Invariant==1 ? MF_CHECKED:MF_UNCHECKED);
		
			// Boucle de messages
			MSG msg;
			while (GetMessage (&msg, NULL, 0, 0))
			{
				TranslateMessage (&msg);
				DispatchMessage (&msg);
			}
		}
		else
		{
			MessageBox (hwMain, "Can't load 'MATRICE.DLL'", AppName, MB_OK);
		}
		
		delete MATRICEP;
		delete MATRICET;
		delete NbP_Invar;
		delete NbT_Invar;
	}
	else
	{
		if (res)
		{
			switch (cmde)
			{
				case 1:		// Nombre de P-Invariants
					delete MATRICEP;
					delete MATRICET;
					delete NbT_Invar;
					RETOUR = NbP_Invar;
					break;
				case 2:		// Les P-Invariants
					delete MATRICET;
					delete NbP_Invar;
					delete NbT_Invar;
					RETOUR = MATRICEP;
					break;
				case 3:		// Nombre de T-Invariants
					delete MATRICEP;
					delete MATRICET;
					delete NbP_Invar;
					RETOUR = NbT_Invar;
					break;
				case 4:		// Les T-Invariants
					delete MATRICEP;
					delete NbP_Invar;
					delete NbT_Invar;
					RETOUR = MATRICET;
					break;
			}
		}
		else
		{
			delete MATRICEP;
			delete MATRICET;
			delete NbP_Invar;
			delete NbT_Invar;
			RETOUR = NULL;
		}
	}
	return RETOUR;
}

extern "C" void FAR PASCAL __export PMFunctionCopyright (char *Copyright)
{
	sprintf (Copyright, "V 1.0 US - © 1995 Alain GODON");
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
				case ID_T_INVARIANT:
					Invariant=0;
					CheckMenuItem (hMenu, ID_T_INVARIANT, Invariant==0 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_P_INVARIANT, Invariant==1 ? MF_CHECKED:MF_UNCHECKED);
					InvalidateRect (hwMain, NULL, TRUE);
					break;
				case ID_P_INVARIANT:
					Invariant=1;
					CheckMenuItem (hMenu, ID_T_INVARIANT, Invariant==0 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_P_INVARIANT, Invariant==1 ? MF_CHECKED:MF_UNCHECKED);
					InvalidateRect (hwMain, NULL, TRUE);
					break;
				case ID_APROPOS:
					{
						char Buf[1024];
						sprintf (Buf,"Recherche des P et T Invariants selon\nl'algorithme de H. Alla (Grenoble).\n\n© 1995 Alain GODON & Frédéric BOUSSEAU");
						MessageBox (hwnd, Buf, "A propos...", MB_OK);
					}
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

BOOL Creation_Invariants (void)
{
	HINSTANCE hDLL;
	MATRICEP = new CMatrice ();
	MATRICET = new CMatrice ();
	NbP_Invar = new int;
	NbT_Invar = new int;

	// Récupération de la matrice d'incidence
	{
		CMatrice *M;
		if ((hDLL = LoadDLL ("MATRICE.DLL"))==NULL) return FALSE;
		if ((M = (CMatrice *) CallDLL (hDLL, pDoc, 1)) == NULL)
		{
			FreeDLL (hDLL);
			return FALSE;
		}
		*MATRICEP = *M;
		*MATRICET = *M;
		FreeDLL (hDLL);
	}

	int nP = MATRICEP->GetNumRows ();
	int nT = MATRICEP->GetNumColumns ();

	MATRICET->Transpose ();
	
	CMatrice IDENT_P (nP, nP);
	CMatrice IDENT_T (nT, nT);
	
	IDENT_P.Identity ();
	IDENT_T.Identity ();
	
	MATRICEP->ConcatRight (&IDENT_P);	
	MATRICET->ConcatRight (&IDENT_T);	
		
	CalculP_T (MATRICEP, nP, nT);
	CalculP_T (MATRICET, nT, nP);

	*NbP_Invar = MATRICEP->GetNumRows ();
	*NbT_Invar = MATRICET->GetNumRows ();

	// Remise en forme des matrices
	MATRICEP->RemoveColumns (0, nT);
	MATRICET->RemoveColumns (0, nP);
	return TRUE;
}

void Dessine (HWND hWnd)
{
	PAINTSTRUCT ps;
	HDC hDC;
	
	hDC = BeginPaint (hWnd, &ps);

	int nP = *NbP_Invar;
	int nPbis = TabPlace->GetUpperBound ()+1;
	int nT = *NbT_Invar;
	int nTbis = TabTrans->GetUpperBound ()+1;

	char Buf [MAXSTR];
	int i, j;
	
	switch (Invariant)
	{
		case 0:	// T_INVARIANT
		{
			if (nT>0)	
			{
				SetTextAlign (hDC, TA_RIGHT);
				for (i=0 ; i<MATRICET->GetNumColumns () ; i++)
				{
					sprintf (Buf, "T%d", i+1);
					TextOut (hDC, 60+i*30, 6, Buf, strlen (Buf));
				}
			
				for (i=0 ; i<MATRICET->GetNumRows () ; i++)
				{
					sprintf (Buf, "S%d=", i+1);
					SetTextAlign (hDC, TA_LEFT);
					TextOut (hDC, 10, 30+i*20, Buf, strlen (Buf));
						 			
					for (j=0 ; j<MATRICET->GetNumColumns () ; j++)
					{
						// Affichage de la valeur
						sprintf (Buf, "%d", (int)MATRICET->GetAt (i, j));
						SetTextAlign (hDC, TA_RIGHT);
						TextOut (hDC, 60+j*30, 30+i*20, Buf, strlen (Buf));	
					}
				}
			}
			else
			{
				LoadString (hinstLib, IDS_NO_TINVAR, Buf, MAXSTR);
				TextOut (hDC,20,20,Buf, strlen (Buf));
			}
		}
		break;
		
	 	case 1:	// P_INVARIANT
		{
			if (nP>0)
			{
				SetTextAlign (hDC, TA_RIGHT);
				for (i=0 ; i<nPbis ; i++)
				{
					sprintf (Buf, "P%d", i+1);
					TextOut (hDC, 60+i*30, 6, Buf, strlen (Buf));
				}
				for (i=0 ; i<MATRICEP->GetNumRows () ; i++)
				{
					sprintf (Buf, "Pt%d=", i+1);
					SetTextAlign (hDC, TA_LEFT);
					TextOut (hDC, 10, 30+i*20, Buf, strlen (Buf));
						 			
					for (j=0 ; j<MATRICEP->GetNumColumns () ; j++)
					{
						// Affichage de la valeur
						sprintf (Buf, "%d", (int)MATRICEP->GetAt (i, j));
						SetTextAlign (hDC, TA_RIGHT);
						TextOut (hDC, 60+j*30, 30+i*20, Buf, strlen (Buf));
					}
				}
			}
			else
			{
				LoadString (hinstLib, IDS_NO_PINVAR, Buf, MAXSTR);
				TextOut (hDC,20,20,Buf, strlen (Buf));
			}
				
	 	}
	 	break;
	}
	
	EndPaint (hWnd, &ps);
}

void CalculP_T (CMatrice *MAT, int nb_lig, int nb_col)
{ 
	for (int c=0 ; c<nb_col ; c++)
	{
		for (int l1=0 ; l1<nb_lig ; l1++)
		{
			long elt1 = (long) MAT->GetAt (l1,c);
			if (elt1 != 0)
				for (int l2=l1+1 ; l2<nb_lig ; l2++)
				{
					long elt2 = (long) MAT->GetAt (l2, c);
					if (elt2 != 0)
						if (elt1*elt2 < 0)
							Ajouter (MAT, l1, l2, c, nb_col+nb_lig);
				}
		}

		Eliminer (MAT, c);
		
		if (MAT->GetNumRows () == 0) return;
	}
}

void Ajouter (CMatrice *MAT, int ligne_pivot, int lignes, int indice_colonne, int nbtrans)
{
	MAT->AddRows (1);
	for (int i=0 ; i<nbtrans ; i++)
	{

		int v1 = (int) abs((int)MAT->GetAt (lignes, indice_colonne)) * (int)MAT->GetAt (ligne_pivot, i);
		int v2 = (int) abs((int)MAT->GetAt (ligne_pivot, indice_colonne)) * (int)MAT->GetAt(lignes, i);

		MAT->SetAt (MAT->GetNumRows ()-1,i, v1+v2);
	}
}

void Eliminer (CMatrice *MAT, int colonne)
{          
	BOOL Arret = FALSE;
	
	while (!Arret)
	{
		Arret = TRUE;
		for (int i = 0 ; i < MAT->GetNumRows () ; i++)
		{
			if (MAT->GetAt (i, colonne) != 0)
			{
				MAT->RemoveRows (i);
				Arret = FALSE;
				break;
			}
		}
	}
}
		                                          
