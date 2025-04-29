// Classes CPt et CArc
// © 1992-96 Alain GODON & Frédéric BOUSSEAU

#ifndef __CLASS_ARC__
#define __CLASS_ARC__

class CPt : public CObject
{
public:
	int x;
	int y;
public:
	CPt (int, int);
};

class CArc : public CRdP
{ 
public:
	CObArray mPoints;
	BOOL mP2T;
	UINT mSource;
	UINT mDest;
	CString mValue;
	BOOL mInhib;
	CString mTemporisation;
	BOOL mTempoVariable;
	BOOL mBold;
	COLORREF mColor;

protected:
	DECLARE_DYNAMIC (CArc)
	CArc () {};

public:
	CArc (CObArray *, BOOL, UINT, UINT);
	virtual CRect GetDimRect (CDC *);
	virtual BOOL PtInRect (CDC *, CPoint);
	virtual void Draw (CDC *, BOOL=FALSE);
	virtual void DrawSel (CDC *);
	virtual void MoveTo (CPoint);
	virtual void Clone (CRdP **);
#ifndef _PMDLL
	virtual BOOL Modify (void);
#endif
	void Clone (CArc **);
	void WriteInfo (CDC *, BOOL);
	BOOL Exist (BOOL, UINT, UINT);
	void ChangePath (CObArray *);
	void SetPosSource (CPoint);
	void SetPosDest (CPoint);

private:
	POINT PointSurObjet (BOOL Cercle, long xc, long yc, long x, long y, UINT taille);
	POINT PointSurEllipse (long xc, long yc, long x, long y, double rayonx, double rayony);
	void Perpendiculaire (POINT p1, POINT p2, POINT *pa, POINT *pb, int taille);
	BOOL Parallele (int x1, int y1, int x2, int y2, int inflat, POINT p);
};     
#endif
