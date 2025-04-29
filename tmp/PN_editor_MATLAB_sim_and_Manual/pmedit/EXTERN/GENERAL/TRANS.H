// Classe CTrans
// © 1992-96 Alain GODON & Frédéric BOUSSEAU

#ifndef __CLASS_TRANS_
#define __CLASS_TRANS__

class CTrans : public CRdP
{
public:
	POINT mPosition;
	CString mTemporisation;
	BOOL mTempoVariable;
	CString mPriority;
	BOOL mPrioVariable;
	CString mSignal;
	CString mColSens;
	CString mDesc;
	BOOL mBold;
	COLORREF mColor;

protected:
	DECLARE_DYNAMIC (CTrans)
	CTrans () {};

public:
	CTrans (POINT);
	virtual CRect GetDimRect (CDC *);
	virtual BOOL PtInRect (CDC *, CPoint);
	virtual void Draw (CDC *, BOOL=FALSE);
	virtual void DrawSel (CDC *);
	virtual void MoveTo (CPoint);
	virtual void Clone (CRdP **);
#ifndef _PMDLL
	virtual BOOL Modify (void);
#endif
	void Clone (CTrans **);
	void WriteInfo (CDC *, BOOL, UINT, BOOL, BOOL, BOOL, CPoint, CPoint, CPoint, CPoint);
	BOOL ChangePosition (POINT);
};
#endif
