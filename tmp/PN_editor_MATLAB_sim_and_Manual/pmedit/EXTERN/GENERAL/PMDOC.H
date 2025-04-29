// Classe CpEditDoc
// © 1992-96 Alain GODON & Frédéric BOUSSEAU

#include "rdp.h"
#include "place.h"
#include "trans.h"
#include "arc.h"
#include "text.h"
#include "map.h"

class CpEditDoc : public CDocument
{
public:
	CObArray mTabPlace;
	CObArray mTabTrans;
	CObArray mTabArc;
	CObArray mTabTexte;
	CObArray mMapE;
	CObArray mMapS;
/*
protected:
	DECLARE_DYNCREATE(CpEditDoc)
	CpEditDoc () {};
*/
public:
	// RdP
	void AddRdP (CRdP *);
	void RemoveRdP (CRdP *, BOOL=TRUE);
	// Places
	void AddPlace (CPlace *);
	void RemovePlace (int, BOOL=TRUE);
	void RemovePlace (CPlace *, BOOL=TRUE);
	CPlace *GetPlace (int);
	int GetNbPlaces (void);
	// Transitions
	void AddTrans (CTrans *);
	void RemoveTrans (int, BOOL=TRUE);
	void RemoveTrans (CTrans *, BOOL=TRUE);
	CTrans *GetTrans (int);
	int GetNbTrans (void);           
	// Arcs
	void AddArc (CArc *);
	void RemoveArc (int, BOOL=TRUE);
	void RemoveArc (CArc *, BOOL=TRUE);
	CArc *GetArc (int);
	int GetNbArcs (void);  
	// Texte
	void AddTexte (CText *);
	void RemoveTexte (int, BOOL=TRUE);
	void RemoveTexte (CText *, BOOL=TRUE);
	CText *GetTexte (int);
	int GetNbTextes (void);
	// Mapping
	CMap *GetMapE (int);
	int GetNbMapE (void);
	CMap *GetMapS (int);
	int GetNbMapS (void);
};
