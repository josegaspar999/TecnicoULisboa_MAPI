// © 1995 Frédéric BOUSSEAU & Stéphane MARTEAU

#include <afxwin.h>

#include "..\general\pmdoc.h"
#include "resource.h"

// Fonctions              
extern "C" LONG FAR PASCAL __export MainWndProc (HWND, UINT, WPARAM, LPARAM);
extern "C" LONG FAR PASCAL __export About (HWND, UINT, WPARAM, LPARAM);
void UpdateScreen (void);
BOOL InitFirstInstance (HINSTANCE hinst);
void Dessine (HWND);
void InitTemporisations();
UINT CalculTemporisation(UINT);
void MiseAJourTemporisations(void);
void AjouterMarques(LONG, UINT);
void EnleverMarques(LONG, UINT);
void DecrementerTemporisations(void);
BOOL TransitionValidee (UINT);
void Evolution (void);

// Definitions
#define MAXSTR 80

// Variables globales
HINSTANCE hinstLib=NULL;
HWND hwMain=NULL;
HMENU hMenu;
char AppName [MAXSTR];

UINT Compteur;
LONG *TabPm;
LONG *TabMarquage;
LONG **MarquesTemporisees;
LONG *Temporisations;
UINT *TabTi;
UINT nP=0, nT=0, nA=0;       
BOOL EXECUTION=FALSE;

CString mTemporisation;


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
	// Nettoyer et quitter
	KillTimer(hwMain,1);
	
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
			WS_BORDER | WS_CAPTION | WS_MINIMIZEBOX | WS_SYSMENU,
			0, 0, 310, 40, HWND_DESKTOP, LoadMenu (hinstLib, MAKEINTRESOURCE (IDR_MENU)), hinstLib, NULL);
		hMenu = GetMenu (hwMain);
		SetTimer(hwMain,1,10,NULL);
		Compteur=0;
	}

	nP = TabPlace->GetUpperBound () +1;
	nT = TabTrans->GetUpperBound () +1;
	nA = TabArc->GetUpperBound () +1;

	TabPm = new LONG [nP];
	TabMarquage = new LONG [nP];
	TabTi = new UINT [nT];
	Temporisations = new LONG [nP];
	MarquesTemporisees = new LONG * [nP];
    InitTemporisations();
                                        
	ShowWindow (hwMain, SW_SHOWNORMAL);
	BringWindowToTop (hwMain);
	InvalidateRect (hwMain, NULL, TRUE);
	UpdateScreen ();
	
	// Boucle de messages
	MSG msg;
	while (GetMessage (&msg, NULL, 0, 0))
	{
		TranslateMessage (&msg);
		DispatchMessage (&msg);
	}                            
	
	// Sortie de la boucle : fin du programme
	delete [] TabPm;
	delete [] TabMarquage;
	delete [] TabTi;     
	delete [] Temporisations;              
	for (int i=0;i<(int)nP; i++)
		delete [] MarquesTemporisees[i];
	delete [] MarquesTemporisees;
	
	return NULL;
}

extern "C" void FAR PASCAL __export PMFunctionCopyright (char *Copyright)
{
	sprintf (Copyright, "V 1.0 US - © 1995 Frédéric BOUSSEAU & Stéphane MARTEAU");
}


void UpdateScreen (void)
{
	// Menus
	EnableMenuItem (hMenu, ID_EXECUTE, EXECUTION?MF_GRAYED:MF_ENABLED);
	EnableMenuItem (hMenu, ID_STOP, EXECUTION?MF_ENABLED:MF_GRAYED);
	DrawMenuBar (hwMain);
	//
	char Texte [MAXSTR];
	char Buf [2*MAXSTR];
	LoadString (hinstLib, EXECUTION?IDS_RUNNING:IDS_ATTENTE, (LPSTR)Texte, MAXSTR);
	sprintf (Buf, "%s %s", AppName, Texte);
	SetWindowText (hwMain, Buf);
}
                                 
                                 
                                 
extern "C" LONG FAR PASCAL __export MainWndProc (HWND hwnd, UINT msg, WPARAM wP, LPARAM lP)
{                                   
	DLGPROC dlgprc;
	switch (msg)
	{
		     
		case WM_DESTROY:
			PostQuitMessage (0);
			break;
			
		case WM_COMMAND:
			// Actions du menu
			switch (wP)
			{
				case ID_EXECUTE:
					EXECUTION = TRUE;
					UpdateScreen ();
					break;
				case ID_STOP:
					EXECUTION = FALSE;
					UpdateScreen ();
					break;                                               
				case ID_ABOUT:                    
					dlgprc = (DLGPROC)MakeProcInstance((FARPROC)About,hinstLib);
				    DialogBox (hinstLib,MAKEINTRESOURCE (IDD_ABOUT),hwnd, dlgprc);
				    FreeProcInstance ((FARPROC)dlgprc);
					break;
				case ID_QUITTER:
					EXECUTION = FALSE;
					UpdateScreen ();
					PostMessage (hwMain, WM_SYSCOMMAND, SC_CLOSE, 0);
					break;                                               
			}
			break;                                    
			
		case WM_PAINT:
			Dessine (hwnd);
			break;
		
		case WM_TIMER:
			if (EXECUTION)
			{
				Evolution();
				Compteur ++;
				if (Compteur == 10) 
				{
					DecrementerTemporisations ();
					Compteur = 0;
				}
			}
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
	
	EndPaint (hWnd, &ps);
}               


void Evolution ()
{
	CPlace *pPlace;
	//CTrans *pTrans;
	CArc *pArc;
	UINT i, iT, iP;
	
	if ( (nP==0) || (nT==0) || (nA==0) ) return;
			
		
	// Initialiser les tableaux
	for (i=0 ; i < nP ; i++)
	{
		pPlace = (CPlace *)TabPlace->GetAt (i);
		TabPm [i]=0;
		TabMarquage [i]=FALSE;
	}	
	for (i=0 ; i < nT ; i++)
		TabTi [i] = i;
	
	// Trier les transitions par priorité
	{
		CTrans *pTrans1;
		CTrans *pTrans2;
		BOOL FinTri=FALSE;
		UINT vide;
			
		while (!FinTri)
		{
			FinTri=TRUE;
			for (i=0 ; i < nT-1 ; i++)
			{
				pTrans1 = (CTrans*)TabTrans->GetAt (TabTi [i]);
				pTrans2 = (CTrans*)TabTrans->GetAt (TabTi [i+1]);
				if (pTrans1->mPriority > pTrans2->mPriority)
				{
					vide=TabTi [i];
					TabTi [i]=TabTi [i+1];
					TabTi [i+1] = vide;
					FinTri=FALSE;
				}
			}
		}
	}
	
	// Evolution
	for (iT=0 ; iT < nT ; iT++)
	{
		if (TransitionValidee (TabTi [iT]))
		{
			// Décrémentation des places amont
			for (i=0 ; i < nA ; i++)
			{
				pArc = (CArc *)TabArc->GetAt (i);
				if ((pArc->mP2T == TRUE) && (pArc->mDest == TabTi [iT]))
				{
					pPlace = (CPlace *)TabPlace->GetAt (pArc->mSource);
					long unsigned int Dummy = atol ((const char *)pPlace->mMarking);
					Dummy -= atol ((const char *)pArc->mValue);
					char Buf [80];
					sprintf (Buf, "%lu", Dummy);
					pPlace->mMarking = Buf;
					TabMarquage [pArc->mSource] = TRUE;
					EnleverMarques(pArc->mSource,(UINT)atol ((const char *)pArc->mValue));
				}
			}
			// Incrémentation des places aval virtuelles
			for (i=0 ; i < nA ; i++)
			{
				pArc = (CArc *)TabArc->GetAt (i);
				if ((pArc->mP2T == FALSE) && (pArc->mSource == TabTi [iT]))
				{
					long unsigned int Dummy = atol ((const char *)pArc->mValue);
					TabPm [pArc->mDest] += Dummy;            
	
				}
			}
		}
	}                                                                                           
	
	// Recopie du marquage virtuel
	for (iP=0 ; iP < nP ; iP++)
	{
		if (TabPm [iP]>0 || TabMarquage [iP])
		{
			pPlace = (CPlace *)TabPlace->GetAt (iP);
			long unsigned int Dummy = atol ((const char *)pPlace->mMarking);
			Dummy += TabPm [iP];
			char Buf [80];
			sprintf (Buf, "%lu", Dummy);
			pPlace->mMarking = Buf;
			AjouterMarques(iP,(UINT)TabPm[iP]);
			pDoc->UpdateAllViews (NULL, 0, pPlace);
			
		}
	}                         
	
	MiseAJourTemporisations();	                                                    
}



BOOL TransitionValidee (UINT indice)
{
	CArc *pArc;            
	int j;  
	UINT MarquesDisponibles;
	
	for (int i=0 ; i < TabArc->GetUpperBound ()+1 ; i++)
	{
		pArc = (CArc *)TabArc->GetAt (i);
		if ((pArc->mP2T) && (pArc->mDest == indice))
		{
			CPlace *pPlace = (CPlace *)TabPlace->GetAt (pArc->mSource);
			long unsigned int Dummy1 = atol ((const char *)pArc->mValue);
			
			
			MarquesDisponibles=0;
			for(j=1;j<=MarquesTemporisees[pArc->mSource][0];j++)
				if(MarquesTemporisees[pArc->mSource][j]==0) MarquesDisponibles++;
			if (MarquesDisponibles < Dummy1) return FALSE;
			
		}
	}
	return TRUE;
}                   



void InitTemporisations(void)
{
	CPlace *pPlace;
	UINT i;
	long j;                       
	long NbMarques;                                              
	UINT Tempo;
	
        
	for(i=0;i<nP;i++)
	{
 		pPlace = (CPlace *)TabPlace->GetAt (i);
 		
		if(pPlace->mTempoVariable) Temporisations[i] = CalculTemporisation(i);
 		else Temporisations[i] = atol((const char *)pPlace->mTemporisation);
	}
	
	for(i=0;i<nP;i++)
	{
 		pPlace = (CPlace *)TabPlace->GetAt (i);
 		NbMarques = atol((const char *)pPlace->mMarking);
		MarquesTemporisees[i] = new long [1+NbMarques];
		MarquesTemporisees[i][0] = NbMarques;
		
		if(pPlace->mTempoVariable) Tempo = CalculTemporisation(i);
		
		for(j=1;j<=NbMarques; j++)
			if(!pPlace->mTempoVariable)
				MarquesTemporisees[i][j] = atol((const char *)pPlace->mTemporisation);
			else                        
				MarquesTemporisees[i][j] = Tempo;
    }       
}



void DecrementerTemporisations (void)
{                         
	
	UINT i;
	long j;
	for (i=0;i<nP;i++)
		for (j=1;j<=MarquesTemporisees[i][0];j++)
			if(MarquesTemporisees[i][j]>0) MarquesTemporisees[i][j]--;
                      
}
                    
    
                                
void AjouterMarques(LONG indice, UINT NbMarques)
{                                              
	UINT i;
	long *inter;                                       
	UINT NbMarquesAvant;  
	
	NbMarquesAvant = (UINT)MarquesTemporisees[indice][0];
	
	inter = new long [NbMarquesAvant+1];	
	
	memcpy(inter,MarquesTemporisees[indice],(NbMarquesAvant+1)*sizeof(long));
	
	delete [] MarquesTemporisees[indice];
	MarquesTemporisees[indice] = new long [NbMarquesAvant+NbMarques+1];
	
	memcpy(MarquesTemporisees[indice],inter,(NbMarquesAvant+1)*sizeof(long));	
	
	MarquesTemporisees[indice][0] = NbMarquesAvant+NbMarques;
	for(i=NbMarquesAvant+1;i<NbMarques+NbMarquesAvant+1;i++)
		MarquesTemporisees[indice][i] = Temporisations[indice];
		
	delete [] inter;
}                             


void EnleverMarques(LONG indice, UINT NbMarques)
{	
	UINT i;
	int j=1;
	long *inter;                                       
	UINT NbMarquesAvant;
	UINT NbMarquesPrises=0;
	
	NbMarquesAvant = (UINT)MarquesTemporisees[indice][0];
	inter = new long [NbMarquesAvant+1];	   
	memcpy(inter,MarquesTemporisees[indice],(NbMarquesAvant+1)*sizeof(long));
	
	delete [] MarquesTemporisees[indice];
	
	MarquesTemporisees[indice] = new long [NbMarquesAvant-NbMarques+1];
	
	MarquesTemporisees[indice][0] = NbMarquesAvant-NbMarques;
	
	for(i=0;i<NbMarquesAvant;i++)
		if((inter[i+1]==0) && (NbMarquesPrises<NbMarques))
			NbMarquesPrises++;
		else MarquesTemporisees[indice][j++]=inter[i+1];
			
    delete [] inter;
}                               


UINT CalculTemporisation(UINT indice)
{
	// Ax+b;P1 ...PN;Seuil                 
	CString IndicePlace;
	CString Equation;
	CString Places;
	CString Seuil;
	char Buf[100];	
	int A,b;
	int Palier;
	int NbMarques=0;
	int Pos1=0,Pos2=0;
	int compteur=0;
	int i;
	
	CPlace *pPlace;
	pPlace = (CPlace *)TabPlace->GetAt (indice);
	
	mTemporisation = pPlace->mTemporisation;
	
	mTemporisation.MakeLower();
	
	for(i=0;i<mTemporisation.GetLength();i++)
	{
		if(mTemporisation[i]==';') 
		{
			compteur++;
			if(compteur==1) Pos1=i;
			else if(compteur==2) Pos2=i;
		}
	}
		
	if((compteur==1) || ((compteur==2)&&(Pos2-Pos1-1)>=2))
	{	
		Equation = mTemporisation.Left(Pos1);  
				     
		// 3 arguments dans la temporisation variable
		if((compteur == 2)&&(mTemporisation.GetLength()>=6))
		{
			Seuil = mTemporisation.Right(mTemporisation.GetLength() - Pos2-1);
			Places = mTemporisation.Mid(Pos1+1,Pos2-Pos1-1);
		}
		// 2 arguments dans la temporisation variable
		else if((compteur == 1)&&(mTemporisation.GetLength()>=4))		
		{
			Seuil = '0';
			Places = mTemporisation.Right(mTemporisation.GetLength()-Pos1-1);
		}
		else
		{
			sprintf(Buf,"Les paramètres de la temporisation variable de la place %d sont incorrects",indice+1);
			MessageBox(NULL,Buf,"Erreur",MB_OK);
			return 0;
        }
		
		// Recherche de A et b
		Pos1 = Equation.Find('x');
		if(Pos1==-1)
		{            
			sprintf(Buf,"Les paramètres de la temporisation variable de la place %d sont incorrects",indice+1);
			MessageBox(NULL,Buf,"Erreur",MB_OK);
			return 0;
		}
		if(Pos1 == 0)  A=1;
		else A = atoi(Equation.Left(Pos1));
		b = atoi(Equation.Right(Equation.GetLength()-Pos1-1));
		
		// Recherche du seuil
		Palier = atoi(Seuil);
		
		// Recherche des indices des places dont la temporisation dépend
		Pos1 = -1;
		Pos2 = -1;
		
		for(i=0;i<Places.GetLength();i++)                             
		{
			if(Places[i] == 'p')
				if(Pos1 == -1) 
					Pos1 = i;
				else Pos2 = i;
				
			if((Pos1 != -1)&&(Pos2 != -1))
			{               
				IndicePlace = Places.Mid(Pos1+1,Pos2-Pos1-1);
			    if((atoi(IndicePlace)<=0)||(atoi(IndicePlace)>TabPlace->GetSize()))
			    {
			    	sprintf(Buf,"Les paramètres de la temporisation variable de la place %d sont incorrects",indice+1);
					MessageBox(NULL,Buf,"Erreur",MB_OK);
					return 0;
			    }   
			    else
			    {
					pPlace = (CPlace *)TabPlace->GetAt(atoi(IndicePlace)-1);
					NbMarques += atoi(pPlace->mMarking);
					Pos1 = Pos2;
					Pos2 = -1;
				}	
			}       
		}
		if((Pos1 == -1)&&(Pos2 == -1))
			{               
		    	sprintf(Buf,"Les paramètres de la temporisation variable de la place %d sont incorrects",indice+1);
				MessageBox(NULL,Buf,"Erreur",MB_OK);
				return 0;
		    }   
		IndicePlace = Places.Right(Places.GetLength()-Pos1-1);
		if((atoi(IndicePlace)<=0)||(atoi(IndicePlace)>TabPlace->GetSize()))
			    {
			    	sprintf(Buf,"Les paramètres de la temporisation variable de la place %d sont incorrects",indice+1);
					MessageBox(NULL,Buf,"Erreur",MB_OK);
					return 0;
			    }   
			    else
			    {
					pPlace = (CPlace *)TabPlace->GetAt (atoi(IndicePlace) - 1);
					NbMarques += atoi(pPlace->mMarking);
		        }
		return max(A*NbMarques+b,Palier);
	}
	else
	{                                       
		sprintf(Buf,"Le nombre de paramètres de la temporisation variable de la place %d est incorrect",indice+1);
		MessageBox(NULL,Buf,"Erreur",MB_OK);
		return 0;
	}
}





void MiseAJourTemporisations(void)
{
	CPlace *pPlace;
		
	for(int i=0;i<(int)nP;i++)
	{	pPlace = (CPlace *)TabPlace->GetAt(i);
		if(pPlace->mTempoVariable)
			Temporisations[i] = CalculTemporisation(i);
	}
}
                             
                             
                             
extern "C" LONG FAR PASCAL __export About (HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message)
    {
        case WM_INITDIALOG:
        	{
        		// Centrer la fenêtre
        		RECT ecr, fen;
        		WORD w, h,wecr, hecr;
        		GetWindowRect (GetDesktopWindow (), &ecr);
        		GetWindowRect (hDlg, &fen);
        		w = fen.right - fen.left; h = fen.bottom - fen.top;
        		wecr = ecr.right - ecr.left; hecr = ecr.bottom - ecr.top;
        		MoveWindow (hDlg, (wecr-w)/2, (hecr-h)/2, w, h, FALSE);
        	}
        	break;
        case WM_COMMAND:               /* message: received a command */
            if (wParam == IDOK)         /* "OK" box selected?          */
            {
                EndDialog (hDlg, TRUE); /* Exits the dialog box        */
                return (TRUE);
            }
            break;
    }
    return (FALSE);               /* Didn't process a message    */
}                                                    
