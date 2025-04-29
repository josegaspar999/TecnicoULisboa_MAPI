// Exemple de superviseur
// (C) 1995 Alain GODON

#include <iostream.h>
#include <conio.h>
#include <dos.h>

const int TRUE=1;
const int FALSE=0;
// D‚finition pour COM2
const int TXRX=0x2F8;	// 0x3F8 pour COM1
const int LSR=0x2FD;		// 0X3FD pour COM1


#define CMD_REQ 10
#define ACK_REQ 10
#define CMD_CHG 11
#define ACK_CHG 11
#define CMD_END 12
#define ACK_END 12

char ISCAR (void)
{
	return (inportb (LSR) & 1 == 1 ? TRUE : FALSE);
}

void WRITE (char c)
{
	outportb (TXRX, c);
}

void READ (char &c)
{
	while (ISCAR () == FALSE);
	c = inportb (TXRX);
}

void READINT (int &n)
{
	char c;
	READ (c);	// Poids faible
	n = c;
	WRITE (c);	// Accus‚ de r‚ception
	READ (c);	// Poids fort
	n += c*255;
	// Pas d'accus‚ de r‚ception !!
}

void WRITEINT (int n)
{
	char c;
	c = n%255;
	WRITE (c);	// Poids faible
	READ (c);	// Accus‚ de r‚ception
	c = n/255;
	WRITE (c);	// Poids fort
	READ (c);	// Accus‚ de r‚ception
}

void main (void)
{
	int NbPieces;
	char Machine;
	char Car;
	int Num;

	clrscr ();
	cout << "Exemple de superviseur\n";
	cout << "Entrez le nombre de piŠces : ";
	cin >> NbPieces;
	cout << "Entrez la machine (G ou D) : ";
	cin >> Machine;
	cout << "\nAppuyer sur une touche pour usiner " << NbPieces << " piŠces sur la machine " << Machine << "\n";
	getch ();

	// Envoie l'ordre de demande
	WRITE (CMD_REQ);
	READ (Car);	// On devrait tester que (Car==ACK_REQ)

	// On fixe le marquage des deux machines
	WRITE ('G');
	READINT (Num);	// Marquage actuel
	WRITE (CMD_CHG);
	READ (Car);	// On devrait tester que (Car==ACK_CHG)
	WRITEINT (Machine=='G' ? 1 : 0);

	WRITE ('D');
	READINT (Num);	// Marquage actuel
	WRITE (CMD_CHG);
	READ (Car);	// On devrait tester que (Car==ACK_CHG)
	WRITEINT (Machine=='D' ? 1 : 0);

	// On fixe le nombre de piŠces
	WRITE ('S');
	READINT (Num);	// Marquage actuel
	WRITE (CMD_CHG);
	READ (Car);	// On devrait tester que (Car==ACK_CHG)
	WRITEINT (NbPieces);

	// C'est fini
	WRITE (CMD_END);
	READ (Car);	// On devrait tester que (Car==ACK_END)

	cout << "Appuyer sur une touche pour quitter\n";

	while (!kbhit ())
	{
		if (ISCAR () == TRUE)
		{
			READ (Car);
			cout << Car;
		}
	}
	getch ();
}
