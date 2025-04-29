// © 1995-96 Alain GODON & Frédéric BOUSSEAU

#ifndef __MATRICE__
#define __MATRICE__

class CMatrice
{
protected:
	double *MAT;
	int nb_lignes;
	int nb_colonnes;
public:
	CMatrice (int=0, int=0);
	~CMatrice ();
	inline int GetNumRows (void) {return nb_lignes;};
	inline int GetNumColumns (void) {return nb_colonnes;};
	void SetSize (int,int);
	void GetSize (int&,int&);
	void SetAt (int, int, double);
	double GetAt (int, int);
	void RemoveRows (int,int=1);
	void AddRows (int);
	void RemoveColumns (int,int=1);
	void AddColumns (int);
	void Identity (void);
	void ConcatRight (CMatrice *);
	void ConcatBottom (CMatrice *);
	void Transpose (void);

	void operator= (CMatrice);
	CMatrice operator+(CMatrice M);
	CMatrice operator-(CMatrice M);                                                             
	CMatrice operator*(CMatrice M);                                                             
};

#endif
