// Classe CText
// © 1992-96 Alain GODON & Frédéric BOUSSEAU

#ifndef __CLASS_TEXT__
#define __CLASS_TEXT__

class CText : public CRdP
{ 
public:
	POINT mPosition;
	CString mText;
	CString mFont;
	UINT mHeight;
	BOOL mStrikeOut;
	BOOL mUnderline;
	BOOL mItalic;
	BOOL mBold;
	COLORREF mColor;

protected:
	DECLARE_DYNAMIC (CText)
	CText () {};

public:
	CText (POINT, CString text="PM Editeur", CString font="Arial", UINT height=16, BOOL strikeout=FALSE, BOOL underline=FALSE, BOOL italic=FALSE, BOOL bold=FALSE, COLORREF color=0);
	virtual CRect GetDimRect (CDC *);
	virtual BOOL PtInRect (CDC *, CPoint);
	virtual void Draw (CDC *, BOOL=FALSE);
	virtual void DrawSel (CDC *);
	virtual void MoveTo (CPoint);
	virtual void Clone (CRdP **);
#ifndef _PMDLL
	virtual BOOL Modify (void);
#endif
	void Clone (CText **);
	BOOL ChangePosition (POINT);
	void Extent (CDC *, UINT *, UINT *);
};     
#endif
