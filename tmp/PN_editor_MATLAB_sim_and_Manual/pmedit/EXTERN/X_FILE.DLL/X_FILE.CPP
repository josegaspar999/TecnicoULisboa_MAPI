#include <afxwin.h>
#include <string.h>
#include "resource.h"

#include "..\general\pmdoc.h"

// Fonctions privées
BOOL TransitionValidee (UINT, UINT *);
void Evolution (void);

// Variables globales
HINSTANCE hInst;
CpEditDoc *pDoc;
CObArray *TabPlace, *TabTrans, *TabArc;

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
	
	Evolution ();
	return NULL;
}

extern "C" void FAR PASCAL __export PMFunctionCopyright (char *Copyright)
{
	sprintf (Copyright, "V 1.0 US - © 1996 Alain GODON");
}

void Evolution ()
{
	CPlace *pPlace;
	CTrans *pTrans;
	CArc *pArc;
	CString *TabPm;
	UINT *TabPM;
	UINT *TabTi;
	UINT nP=0, nT=0, nA=0;
	UINT i, iT, iP;
	BOOL OkFr;
	
	nP = TabPlace->GetUpperBound () +1;
	nT = TabTrans->GetUpperBound () +1;
	nA = TabArc->GetUpperBound () +1;

	if ( (nP==0) || (nT==0) || (nA==0) ) return;
		
	TabPm = new CString [nP];
	TabPM = new UINT [nP];
	TabTi = new UINT [nT];
	
	// Initialiser les tableaux
	for (i=0 ; i < nP ; i++)
	{
		TabPm [i]="";
		TabPM [i]=FALSE;
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
				if (atoi ((const char *)pTrans1->mPriority) < atoi ((const char *)pTrans2->mPriority))
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
		if (TransitionValidee (TabTi [iT], TabPM))
		{
			OkFr=TRUE;
			// Signal ?
			{
				pTrans = (CTrans *)TabTrans->GetAt (TabTi [iT]);
				CString ns = pTrans->mSignal;
				if (ns != "")
				{
					char Buf [255];
					char Buf2 [80];

					LoadString (hInst, ID_ASK_SIGNAL, Buf2, 80);
					sprintf (Buf, Buf2, (const char *)ns);
					if (AfxMessageBox (Buf, MB_YESNO | MB_ICONQUESTION) == IDNO) OkFr = FALSE;
				}
			}
			if (OkFr)
			{
				// Décrémentation des places amont
				for (i=0 ; i < nA ; i++)
				{
					pArc = (CArc *)TabArc->GetAt (i);
					if ((pArc->mP2T == TRUE) && (pArc->mDest == TabTi [iT]))
					{
						pPlace = (CPlace *)TabPlace->GetAt (pArc->mSource);
						CString Dummy = (pPlace->mMarking).Right ((pPlace->mMarking).GetLength () - (pArc->mValue).GetLength ());
						pPlace->mMarking = Dummy;
						TabPM [pArc->mSource] = TRUE;
					}
				}
				// Incrémentation des places aval virtuelles
				for (i=0 ; i < nA ; i++)
				{
					pArc = (CArc *)TabArc->GetAt (i);
					if ((pArc->mP2T == FALSE) && (pArc->mSource == TabTi [iT]))
					{
						TabPm [pArc->mDest] += pArc->mValue;
					}
				}
			}
		}
	}                                                                                           

	// Recopie du marquage virtuel
	for (iP=0 ; iP < nP ; iP++)
	{
		if (TabPm [iP] != "" || TabPM [iP])
		{
			pPlace = (CPlace *)TabPlace->GetAt (iP);
			pPlace->mMarking += TabPm [iP];
			pDoc->UpdateAllViews (NULL, 0, pPlace);
		}
	}                                                           

	// Nettoyer et quitter
	delete [] TabPm;
	delete [] TabPM;
	delete [] TabTi;
}

BOOL TransitionValidee (UINT indice, UINT *Tab)
{
	CArc *pArc;
	
	for (int i=0 ; i < TabArc->GetUpperBound ()+1 ; i++)
	{
		pArc = (CArc *)TabArc->GetAt (i);
		if ((pArc->mP2T) && (pArc->mDest == indice))
		{
			CPlace *pPlace = (CPlace *)TabPlace->GetAt (pArc->mSource);
			if (Tab[pArc->mSource]) return FALSE;
			if ( (pPlace->mMarking).GetLength () < (pArc->mValue).GetLength () ) return FALSE;
			if ( (pPlace->mMarking).Left ((pArc->mValue).GetLength ()) != pArc->mValue) return FALSE;
		}
	}
	return TRUE;
}
