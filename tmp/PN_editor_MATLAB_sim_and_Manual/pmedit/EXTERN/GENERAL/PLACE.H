// Classe CPlace
// © 1992-96 Alain GODON & Frédéric BOUSSEAU

#ifndef __CLASS_PLACE__
#define __CLASS_PLACE__

class CPlace : public CRdP
{
public:
	POINT mPosition;
	CString mMarking;
	CString mTemporisation;
	BOOL mTempoVariable;
	CString mSignal;
	CString mDesc;
	BOOL mBold;
	COLORREF mColor;

protected:
	DECLARE_DYNAMIC (CPlace)
	CPlace () {};

public:
	CPlace (POINT);
	virtual CRect GetDimRect (CDC *);
	virtual BOOL PtInRect (CDC *, CPoint);
	virtual void Draw (CDC *, BOOL=FALSE);
	virtual void DrawSel (CDC *);
	virtual void MoveTo (CPoint);
	virtual void Clone (CRdP **);
#ifndef _PMDLL
	virtual BOOL Modify (void);
#endif
	void Clone (CPlace **);
	void WriteInfo (CDC *, BOOL, UINT, BOOL, BOOL, BOOL, CPoint, CPoint, CPoint, CPoint, BOOL);
	BOOL ChangePosition (POINT);
};
#endif
