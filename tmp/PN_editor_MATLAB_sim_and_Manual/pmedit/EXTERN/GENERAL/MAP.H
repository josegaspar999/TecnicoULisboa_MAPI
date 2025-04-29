// Classe CMap
// © 1995 Alain GODON & Frédéric BOUSSEAU

#ifndef __CLASS_MAP__
#define __CLASS_MAP__

class CMap : public CObject
{
public:
	CString mSrc;
	CString mExpr;
public:
	CMap (CString s);
	void ClearAllExpr ();
	void ClearLastExpr ();
	void AddToExpr (CString s);
	int NbMots (void);
	CString Mot (int n);
};
#endif
