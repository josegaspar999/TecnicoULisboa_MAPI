// © 1996 Nathalie DANGOUMAU

#include <afxwin.h>

#include "..\general\pmdoc.h"
#include "..\general\pmapi.h"
#include "..\general\cmatrice.h"
#include "resource.h"

// Fonctions
extern "C" LONG FAR PASCAL __export MainWndProc (HWND, UINT, WPARAM, LPARAM);
BOOL InitFirstInstance (HINSTANCE hinst);
void Dessine (HWND);

BOOL Recuperer_MatriceWplus (void);
BOOL Recuperer_MatriceWmoins (void);
void Creation_MatriceTemporisation(void);   // Construction de D
int TemporisationT (UINT);           		// Recuperation des temporisations des transitions
int TemporisationP (UINT);           		// Recupération des temporisations des places
void Creation_Constante (void);				// Construction de D*W+ ou D*W-
void Creation_MatriceMarquage (void);		// Construction de M
int Marquage (UINT);            			// Recuperation du marquage
BOOL Recuperer_MATRICET(void);				// Recuperation des T_Invariants           
BOOL Recuperer_MATRICEP(void);				// Recuperation des P_Invariants          
BOOL Calcul_Temps_Cycle (void);				// Calcul du temps de cycle

// Definitions
#define MAXSTR 80
                                
                                
// Variables globales
HINSTANCE hinstLib=NULL;
HWND hwMain=NULL;
HMENU hMenu;
char AppName [MAXSTR];
double Temps_Cycle=0;						// Resultat final 
int nK=0;  									// Nombre de T_Invariant
int Choix_RDP=0;				            // 0= P_Temporise  1= T_Temporise    
BOOL resMatP;								// test de récupération de W+
BOOL resMatM;                               // test de récupération de W-

//appels
void FAR *RETOUR;
CMatrice *MATRICEWP =NULL;		// W+ = matrice d'incidence arriere 
CMatrice *MATRICEWM =NULL;		// W- = matrice d'incidence avant 
CMatrice *MATRICETEMP_T =NULL;	// Matrice(nb_lignes,1) pour decomposition des T_invariants
CMatrice *RESULTAT =NULL;		// Résultat= D*W+ ou D*W+
CMatrice *MATRICET = NULL;		// X = matrice des T_Invariants 
CMatrice *MATRICEP = NULL;		// Y = matrice des P_Invariants
CMatrice *MATRICETEMP_P = NULL;	// Matrice(1,nb_colonnes) pour decomposition des P_invariants
CMatrice *MATRICETEMPO = NULL; 	// D = matrice des temporisations
CMatrice *MATRICEMARQUE = NULL;	// M = matrice du marquage 	
CMatrice *NUM=NULL;             // Numerateur du temps de cycle
CMatrice *DENUM=NULL;			// Denominateur du temps de cycle
CMatrice *NUM1=NULL;            // Numerateur temporaire
CMatrice *DENUM1=NULL;			// Denominateur temporaire
CMatrice *TAB_Temps_Cycle;      // Sauvegarde des valeurs
 
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

    BOOL OK = Calcul_Temps_Cycle ();
  
    if (cmde == 0)
    {   
    	if (OK)
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
			
			CheckMenuItem (hMenu, ID_P_TEMPORISE, Choix_RDP==0 ? MF_CHECKED:MF_UNCHECKED);
			CheckMenuItem (hMenu, ID_T_TEMPORISE, Choix_RDP==1 ? MF_CHECKED:MF_UNCHECKED);
        
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
			MessageBox (hwMain, "Can't load INVARIAN.DLL or MATRICE.DLL", AppName, MB_OK);
			
		}
			
		delete MATRICEWP; 
		delete MATRICEWM;
		delete MATRICEP;
		delete MATRICET;
		delete MATRICETEMPO;
		delete MATRICEMARQUE;
		delete RESULTAT;
		delete NUM;
		delete DENUM;
		delete TAB_Temps_Cycle;
		
	}
	
	else
	{		delete MATRICEWP;
			delete MATRICEWM;
			delete MATRICEP;
			delete MATRICET; 
			delete MATRICETEMPO;
			delete MATRICEMARQUE;
			delete RESULTAT;
			delete NUM;
			delete DENUM;   
			delete TAB_Temps_Cycle;
		
	 }
	return NULL;
	
}   


extern "C" void FAR PASCAL __export PMFunctionCopyright (char *Copyright)
{
	sprintf (Copyright, "V 1.0 US - © 1996 Nathalie DANGOUMAU");
}

extern "C" LONG FAR PASCAL __export MainWndProc (HWND hwnd, UINT msg, WPARAM wP, LPARAM lP)
{
	switch (msg)
	{
		case WM_DESTROY:
		PostQuitMessage (0);
			break;
			
		case WM_COMMAND:
			// Actions sur le menu			
			switch (wP)
			{   
 				case ID_P_TEMPORISE:   
					Choix_RDP=0;
					CheckMenuItem (hMenu, ID_P_TEMPORISE, Choix_RDP==0 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_T_TEMPORISE, Choix_RDP==1 ? MF_CHECKED:MF_UNCHECKED);
					Calcul_Temps_Cycle ();
					InvalidateRect (hwMain, NULL, TRUE);
					break;
					
				case ID_T_TEMPORISE:
                    Choix_RDP=1;
					CheckMenuItem (hMenu, ID_P_TEMPORISE, Choix_RDP==0 ? MF_CHECKED:MF_UNCHECKED);
					CheckMenuItem (hMenu, ID_T_TEMPORISE, Choix_RDP==1 ? MF_CHECKED:MF_UNCHECKED);
					Calcul_Temps_Cycle ();
					InvalidateRect (hwMain, NULL, TRUE);
					break;
					
				case ID_APROPOS:
					char Buf[1024];
					sprintf (Buf,"Minimum cycle time calculus.\n\n© 1996 Nathalie Dangoumau (LISA)");
					MessageBox (hwnd, Buf, "About...", MB_OK);
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

// Récuperation de W+ à partir de matrice.dll
BOOL Recuperer_MatriceWplus (void)
{
    HINSTANCE hDLL;
	MATRICEWP = new CMatrice;
	
	{
		CMatrice *MWP;
		if ((hDLL = LoadDLL ("MATRICE.DLL"))==NULL) 
		return FALSE ;
		
		if ((MWP = (CMatrice *) CallDLL (hDLL, pDoc, 2)) == NULL)
		{
		
			FreeDLL (hDLL);            
			return FALSE;
		}
		
		*MATRICEWP = *MWP;
		delete MWP;
	    FreeDLL (hDLL);
	}
		
	return TRUE;
}

// Récuperation de W- à partir de matrice.dll
BOOL Recuperer_MatriceWmoins (void)
{
    HINSTANCE hDLL;
	MATRICEWM = new CMatrice;
	
	{
		CMatrice *MWM;
		if ((hDLL = LoadDLL ("MATRICE.DLL"))==NULL) 
		return FALSE ;
		
		if ((MWM = (CMatrice *) CallDLL (hDLL, pDoc, 3)) == NULL)
		{
		
			FreeDLL (hDLL);            
			return FALSE;
		}
		
		*MATRICEWM = *MWM;
		delete MWM;
	    FreeDLL (hDLL);
	}
		
	return TRUE;
}


// Récupération des temporisations dans les places
int TemporisationP(UINT i)
{
	CPlace *pPlace;
	
		pPlace = (CPlace *)TabPlace->GetAt (i);
    	return atoi ((const char *)pPlace->mTemporisation);

}
 
// Récupération des temporisations dans les transitions
int TemporisationT (UINT i)
{
	CTrans *pTrans;
	
		pTrans = (CTrans *)TabTrans->GetAt (i);
		return atoi ((const char *)pTrans->mTemporisation);
		
}

// Construction de la matrice D = Temporisation   
void Creation_MatriceTemporisation (void)
{   
    if (Choix_RDP==0)
	{
	    MATRICETEMPO = new CMatrice (TabPlace->GetSize (), TabPlace->GetSize ());
	
		for (int i=0 ; i<TabPlace->GetSize () ; i++)
		{
			for (int j=0 ; j<TabPlace->GetSize (); j++)
			{    
		    	if (i==j)
		    	{
		    		MATRICETEMPO->SetAt (i,j,TemporisationP(i));
		    	}
				else
				{
					MATRICETEMPO->SetAt (i,j,0);
				}
			} 
		}
		
	}		                                         
	else
	{   
		MATRICETEMPO = new CMatrice (TabTrans->GetSize (), TabTrans->GetSize ());
	
		for (int i=0 ; i<TabTrans->GetSize () ; i++)
		{
			for (int j=0 ; j<TabTrans->GetSize (); j++)
		    {	
		    	if (i==j)
		    	{
			    	MATRICETEMPO->SetAt (i,j,TemporisationT(i));
			    }
			    else
			    {
			    	MATRICETEMPO->SetAt (i,j,0);
			    }
			}
		}			
			
	} 


}   

// Récupération du marquage
int Marquage (UINT i)
{
	CPlace *pPlace;
	
		pPlace = (CPlace *)TabPlace->GetAt (i);
    	return atoi ((const char *)pPlace->mMarking);
		
}
 
 
// Construction de la matrice M = Marquage    
void Creation_MatriceMarquage (void)
{   
    
	MATRICEMARQUE = new CMatrice (TabPlace->GetSize (),1);
	
	for (int i=0 ; i<TabPlace->GetSize () ; i++)
		for (int j=0 ; j<1; j++)
		{
			MATRICEMARQUE->SetAt (i,j,Marquage(i));
			
		}  
}   


// Récupération des T_Invariants
BOOL Recuperer_MATRICET(void)
{
    HINSTANCE hDLL;
	MATRICET = new CMatrice;
	
	{
		CMatrice *MT;
		if ((hDLL = LoadDLL ("INVARIAN.DLL"))==NULL) 
		return FALSE ;
		
		if ((MT = (CMatrice *) CallDLL (hDLL, pDoc, 4)) == NULL)
		{
		
			FreeDLL (hDLL);            
			return FALSE;
		}
		
		*MATRICET = *MT;
		delete MT;
	    FreeDLL (hDLL);
	}
	MATRICET->Transpose ();
	
	
 
	
	return TRUE;
}

// Récupération des P_Invariants    
BOOL Recuperer_MATRICEP(void)
{   
	HINSTANCE hDLL;	
	MATRICEP = new CMatrice;	
	
	{
		CMatrice *MP;
		if ((hDLL = LoadDLL ("INVARIAN.DLL"))==NULL) 
		return FALSE ;
		if ((MP = (CMatrice *) CallDLL (hDLL, pDoc, 2)) == NULL)
		{
			FreeDLL (hDLL);            
			return FALSE;
		}
		*MATRICEP = *MP;
		delete MP;
	    FreeDLL (hDLL);
	}
	
	return TRUE;
}	  

// Création du terme constant DW 
void Creation_Constante (void)
{   
	
	resMatP = Recuperer_MatriceWplus();
	resMatM = Recuperer_MatriceWmoins();
    Creation_MatriceTemporisation();

    // D*W+
	if (Choix_RDP==0)
	{  
		RESULTAT = new CMatrice (MATRICETEMPO->GetNumRows (), MATRICEWP->GetNumColumns () );
		(*RESULTAT) = (*MATRICETEMPO) * (*MATRICEWP)  ;
	}
	// W-*D
	else
	{
		RESULTAT = new CMatrice (MATRICEWM->GetNumRows (), MATRICETEMPO->GetNumColumns () );
		(*RESULTAT) =(*MATRICEWM) * (*MATRICETEMPO) ; 
		
	}

}                   

// Calcul du temps de cycle minimum
BOOL Calcul_Temps_Cycle (void)
{                    
	Creation_MatriceMarquage ();
	Creation_Constante();
	
	BOOL resT=Recuperer_MATRICET(); 
	BOOL resP=Recuperer_MATRICEP();
	
	nK = MATRICET->GetNumColumns();	//Nombre de T_Invariants
	
	DENUM = new CMatrice (1,1);
    DENUM->SetAt (0,0,0);
	NUM = new CMatrice (1,1);
	NUM->SetAt (0,0,0);
	TAB_Temps_Cycle= new CMatrice(3,nK);
	
	// Initialisation
	for (int i= 0;i<3;i++)
	{
		for(int j=0;j<MATRICET->GetNumRows();j++)
		{
			TAB_Temps_Cycle->SetAt(i,j,0);
		}
	}
	
		if(resP&&resT&&resMatP&&resMatM)	// si récupération des T et P Invariants et de W+ et W- 
		{
			// Pour chaque T_Invariant
			MATRICETEMP_T = new CMatrice(MATRICET->GetNumRows(),1);
			
			for (int k=0;k<MATRICET->GetNumColumns();k++)
			{
			
				for(int l=0; l< MATRICET->GetNumRows();l++)
				{
					MATRICETEMP_T->SetAt (l,0,MATRICET->GetAt (l,k));
				}
				
	            Temps_Cycle=0;
				// Pour chaque P_Invariant
				for (int i=0 ;i<MATRICEP->GetNumRows ();i++)
				{   
				    
				    double total1 =0;
				    
					MATRICETEMP_P= new CMatrice (1,MATRICEP->GetNumColumns ()) ;
	            	for (int j=0;j<MATRICEP->GetNumColumns();j++)
					{
						MATRICETEMP_P->SetAt (0,j, MATRICEP->GetAt (i, j)); 
					}
		    		DENUM1= new CMatrice (1,1);
					NUM1 = new CMatrice (1,1);
			
					*NUM1 = (*MATRICETEMP_P) * (*RESULTAT) * (*MATRICETEMP_T);
					*DENUM1 =(*MATRICETEMP_P) * (*MATRICEMARQUE);
			    	// Calcul du temps de cycle
			    	total1 =(NUM1->GetAt(0,0))/(DENUM1->GetAt(0,0)); 
		    		if (total1>Temps_Cycle)
		    		{
			    		Temps_Cycle=total1;
			    		*NUM=*NUM1;
						*DENUM=*DENUM1;		    		
					}   
		            delete DENUM1;
					delete NUM1;
					delete MATRICETEMP_P;	
					
				}
		   		int test_int;
		   		test_int= (int)Temps_Cycle;	
     	   		if(test_int==Temps_Cycle )
     	   		{
	     	   	TAB_Temps_Cycle->SetAt(0,k,1);               	// ligne 0= 1-> un int
    	       	TAB_Temps_Cycle->SetAt(1,k,Temps_Cycle); 		// ligne 1 temps de cycle
    	       	}
           		else
	            {
    	       	TAB_Temps_Cycle->SetAt(0,k,0);               	// ligne 0= 0->pas un int
        	   	TAB_Temps_Cycle->SetAt(1,k,NUM->GetAt(0,0)); 	// ligne 1 val du num
           	   	TAB_Temps_Cycle->SetAt(2,k,DENUM->GetAt(0,0));	// ligne 2 val du denum
	           	}
    	
           	} 
        
			delete MATRICETEMP_T;
			return TRUE;
		}
		else
		{
			return FALSE;
		}
}	 


void Dessine (HWND hWnd)
{   
	        
	        
	PAINTSTRUCT ps;
	HDC  hDC;
	
	hDC = BeginPaint (hWnd, &ps);

	char chaine[255];    
    char Txt[255];
    char Buf [255]; 
	double res=0;	                  
	
	MATRICET->Transpose();
		
	for (int i= 0;i<MATRICETEMPO->GetNumColumns();i++)
	{
		for(int j=0;j<MATRICETEMPO->GetNumRows();j++)
		{
			
			res = res+MATRICETEMPO->GetAt(i,j);
		}
	}
	if (res==0)
	{
		sprintf(Buf,"It is not a timed Petri net.");
	    TextOut (hDC, 10, 10, Buf, strlen (Buf));
	}
	else
	{ if(nK>1)
		{
	    	
			
			for (int i=0;i<nK;i++)
			{   
			     
			    
		 		if (TAB_Temps_Cycle->GetAt(0,i)==1)   
		        {
	    	    	sprintf(Txt,"T_invariant : ");
	    	    	TextOut(hDC,10,10+30*2*i,Txt, strlen (Txt));
	    	    	sprintf(Buf,"Minimum cycle time:",(int)TAB_Temps_Cycle->GetAt(1,i));
	    			TextOut (hDC, 10, 30+30*2*i, Buf, strlen (Buf));
	    			
	    			// affichage du T_invariant
	    			for (int l=0; l<MATRICET->GetNumColumns();l++)
	    			{
	    				sprintf (chaine,"%d",(int)MATRICET->GetAt(i,l));
	    				TextOut (hDC,100+l*30,10+30*2*i,chaine, strlen (chaine));
	    			}
	    			
	    		}
	    		else
	    		{
					sprintf(Txt,"T_invariant : ");
	    	    	TextOut(hDC,10,10+30*2*i,Txt, strlen (Txt));	    		
	        		sprintf(Buf,"Minimum cycle time : %d/%d",(int)TAB_Temps_Cycle->GetAt(1,i),(int)TAB_Temps_Cycle->GetAt(2,i));
	        		TextOut (hDC, 10, 30+30*2*i, Buf, strlen (Buf));
	        		
	        		// affichage du T_invariant
	    			for (int l=0; l<MATRICET->GetNumColumns();l++)
	    			{
	    				sprintf (chaine,"%d",(int)MATRICET->GetAt(i,l));
	    				TextOut (hDC,100+l*30,10+30*2*i,chaine, strlen (chaine));
	    			}
				}
			}
		}	
				        	         
		else
		{   
			if (TAB_Temps_Cycle->GetAt(0,0)==1)   
		        {
	    	    	sprintf(Buf,"Minimum cycle time : %d",(int)TAB_Temps_Cycle->GetAt(1,0));
	    			TextOut (hDC, 10, 10, Buf, strlen (Buf));
	    		}
	    		else
	    		{
	    		
	        		sprintf(Buf,"Minimum cycle time : %d/%d",(int)TAB_Temps_Cycle->GetAt(1,0),(int)TAB_Temps_Cycle->GetAt(2,0));
	        		TextOut (hDC, 10, 10, Buf, strlen (Buf));
				}		
		}        
		
	} 
    EndPaint (hWnd, &ps);                
}

		