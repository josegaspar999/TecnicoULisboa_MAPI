#include <afxwin.h>
#include <string.h>
#include "resource.h"

#include "..\general\pmdoc.h"

// Fonctions privées
BOOL TransitionValidee (UINT);
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
	UINT *TabPm, *TabPM;
	UINT *TabTi;
	UINT nP=0, nT=0, nA=0;
	UINT i, iT, iP;
	BOOL OkFr;
	
	nP = TabPlace->GetUpperBound () +1;
	nT = TabTrans->GetUpperBound () +1;
	nA = TabArc->GetUpperBound () +1;

	if ( (nP==0) || (nT==0) || (nA==0) ) return;
		
	TabPm = new UINT [nP];
	TabPM = new UINT [nP];
	TabTi = new UINT [nT];
	
	// Initialiser les tableaux
	for (i=0 ; i < nP ; i++)
	{
		TabPm [i]=0;
		TabPM [i]=FALSE;
	}	
	for (i=0 ; i < nT ; i++)
		TabTi [i] = i;

	// Trier les transitions par priorité
	// 0 : la plus faible
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
		if (TransitionValidee (TabTi [iT]))
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
					if ((pArc->mP2T == TRUE) && (pArc->mDest == TabTi [iT]) && (!pArc->mInhib))
					{
						pPlace = (CPlace *)TabPlace->GetAt (pArc->mSource);
						long unsigned int Dummy = atol ((const char *)pPlace->mMarking);
						Dummy -= atol ((const char *)pArc->mValue);
						char Buf [80];
						sprintf (Buf, "%lu", Dummy);
						pPlace->mMarking = Buf;
						TabPM [pArc->mSource] = TRUE;
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
	}                                                                                           

	// Recopie du marquage virtuel
	for (iP=0 ; iP < nP ; iP++)
	{
		if (TabPm [iP]>0 || TabPM [iP])
		{
			pPlace = (CPlace *)TabPlace->GetAt (iP);
			long unsigned int Dummy = atol ((const char *)pPlace->mMarking);
			Dummy += TabPm [iP];
			char Buf [80];
			sprintf (Buf, "%lu", Dummy);
			pPlace->mMarking = Buf;
			pDoc->UpdateAllViews (NULL, 0, pPlace);
		}
	}                                                           

	// Nettoyer et quitter
	delete [] TabPm;
	delete [] TabPM;
	delete [] TabTi;
}

BOOL TransitionValidee (UINT indice)
{
	CArc *pArc;
	
	for (int i=0 ; i < TabArc->GetUpperBound ()+1 ; i++)
	{
		pArc = (CArc *)TabArc->GetAt (i);
		if ((pArc->mP2T) && (pArc->mDest == indice))
		{
			CPlace *pPlace = (CPlace *)TabPlace->GetAt (pArc->mSource);
			long unsigned int Dummy1 = atol ((const char *)pPlace->mMarking);
			long unsigned int Dummy2 = atol ((const char *)pArc->mValue);
			if (!pArc->mInhib)
			{
				if (Dummy1 <  Dummy2) return FALSE;
			}
			else
			{
				if (Dummy1 > 0) return FALSE;
			}
		}
	}
	return TRUE;
}
