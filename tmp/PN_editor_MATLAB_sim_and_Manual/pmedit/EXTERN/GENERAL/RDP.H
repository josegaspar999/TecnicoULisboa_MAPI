// Classe CRdP
// © 1992-96 Alain GODON & Frédéric BOUSSEAU

#ifndef __CLASS_RDP__
#define __CLASS_RDP__

class CRdP : public CObject
{
protected:
	DECLARE_DYNAMIC (CRdP)
	CRdP () {};

public:
	// Fonctions virtuelles pures
	virtual CRect GetDimRect (CDC *) = 0;
	virtual BOOL PtInRect (CDC *, CPoint) = 0;
	virtual void Draw (CDC *, BOOL=FALSE) = 0;
	virtual void DrawSel (CDC *) = 0;
	virtual void MoveTo (CPoint) = 0;
	virtual void Clone (CRdP **) {};
#ifndef _PMDLL
	virtual BOOL Modify (void) = 0;
#endif
};

#endif
