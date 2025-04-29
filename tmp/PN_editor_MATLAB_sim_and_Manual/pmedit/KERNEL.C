/* Noyau Atelier PETRI Maker */
/* DerniŠre modification le 21 mars 1995 */
/* (C) 1994-1995 Alain GODON */

#include "include\io51.h"
#include "c\pmio.h"
#include "c\inout.h"

#define INIT_TH 0xD8
#define INIT_TL 0xF0
#define Stop_Cpt TMOD|=0x04;
#define Cont_Cpt TMOD&=0xFB;

#define TAILLE_PILE 10
#define ROMC ((unsigned char *) 0x10300)
#define ROM ((int *) 0x10300)
#define RAM ((int *) 0x11000)
#define SEP (int)-1
#define SEPFIN (int)-2

void Download (void);
void Execute (void);
void Superviseur (int pos);
void Actualise_marquage (void);
void Calcule_Sorties (int *pos);
char Calcule_Entree (int *pos);
char Places_Amont (int pos);
void Franchissement (int pos);
void Decremente_tempos (void);

int NbP; /* Nombre de places */
int NbT; /* Nombre de transitions */

#define CMD_DOWN 0
#define CMD_EXEC 1
#define CMD_STOP 2
#define ACK_R2SIZE 3
#define ACK_STOPPED 4
#define ACK_ENDDATA 5
/* Supervision */
#define CMD_REQ 10
#define ACK_REQ 10
#define CMD_CHG 11
#define ACK_CHG 11
#define CMD_END 12
#define ACK_END 12

void main (void)
{
   char Cmd;

   /* Remise … z‚ro des sorties */
   SORTIEL=0;
   SORTIEH=0;
   /* Initialisation de la communication s‚rie */
   init_serie ();
   /* Message d'initialisation */
   EcritChaine ("RDP 1.10\r\n");
   /* Boucle d'attente de commande */
   while (1)
   {
      LitCar (&Cmd);
      switch (Cmd)
      {
         case CMD_DOWN: Download ();
                        break;
         case CMD_EXEC: Execute ();
                        break;
         case CMD_STOP: EcritCar (ACK_STOPPED);
                        break;
      }
   }
} 

void Download (void)
{
   unsigned char car;
   unsigned int taille;
   int i;

   EcritCar (ACK_R2SIZE);
   LitCar (&car); taille=car*255;
   EcritCar (car);
   LitCar (&car); taille+=car;
   EcritCar (car);
   for (i=0 ; i<taille ; i++)
   {
      LitCar (&ROMC[i]);
      EcritCar (ROMC[i]);
   }
   LitCar (&car);
   EcritCar (ACK_ENDDATA);
}

void Execute (void)
{
   int i;
   int Position;
   char CarSerie;
   char Sortie_Boucle=0;

   NbP = ROM [0];
   NbT = ROM [1];
   
   /* Recopie du marquage initial en RAM */
   for (i=0 ; i<NbP ; i++)
      RAM [i] = ROM [i+2];

   /* Il n'y a pas encore de places temporis‚es */
   RAM [2*NbP] = SEP;

   TMOD=0x21;
   TH0=INIT_TH;
   TL0=INIT_TL;
   TCON.4=1;
   IE.1=1;
   IE.7=1;

   /************************************************************************/
   /************************** DEBUT DE LA BOUCLE **************************/
   /************************************************************************/
   while (Sortie_Boucle==0)
   {
      /* Initialisation … 0 du marquage calcul‚ */
      for (i=NbP ; i<2*NbP ; i++)
         RAM [i] = 0;
      
      Position = 2*NbP+2;
      Calcule_Sorties (&Position);
      ecrit_sorties ();
      lit_entrees ();

      for (i=0 ; i<NbT ; i++)
      {
         if (Calcule_Entree (&Position))
            if (Places_Amont (Position))
               Franchissement (Position);
         Position += 2*ROM [Position]+1;
         Position += 2*ROM [Position]+1;
      }
      /* Position pointe sur le d‚but de la structure superviseur */

      Actualise_marquage ();

      /* Envoie des messages !x */
      for (i=0 ; i<ROM [Position] ; i++)
      {
         if (ROMC [2*(1+Position+2*i)+1]=='!')
            if (RAM [ROM [1+Position+2*i+1]]>0)
               EcritCar (ROMC [2*(1+Position+2*i)]);
      }

      /* Est-ce qu'on re‡oit des messages ? */
      if (IsCar())
      {
         LitCar (&CarSerie);
         switch (CarSerie)
         {
            case CMD_STOP: EcritCar (ACK_STOPPED);
                           Sortie_Boucle = 1;
                           break;
            case CMD_REQ:  EcritCar (ACK_REQ);
                           Superviseur (Position);
                           break;
         }
      }
   }
   /* Sortie de la boucle */
   /* Inhibe l'interruption externe */
   IE.1 = 0;
   IE.7 = 0;
}

void Superviseur (int pos)
{
   int i;
   int ind;
   char Car=0;
   char c;

   while (Car != CMD_END)
   {
      LitCar (&Car);
      switch (Car)
      {
         case CMD_END:
            EcritCar (ACK_END);
            break;
         case CMD_CHG:
            EcritCar (ACK_CHG);
            LitCar (&c);
            EcritCar (c);
            RAM [ind] = c;
            LitCar (&c);
            EcritCar (c);
            RAM [ind] += 255*c;
            break;
         default:
            for (i=0 ; i<ROM [pos] ; i++)
               if (ROMC [2*(1+pos+2*i)]==Car)
               {
                  ind = ROM [1+pos+2*i+1];
                  break;
               }
            c = RAM [ind] % 255;
            EcritCar (c);
            LitCar (&c);
            c = RAM [ind] / 255;
            EcritCar (c);
            break;
      }
   }
}

void Actualise_marquage (void)
{
   int i,j,k;

   for (i=0 ; i<NbP ; i++)
   {
      /* Incrementation du marquage courant */
      RAM [i] += RAM [NbP+i];
                  
      /* MAJ des temporisations eventuelles */
      if ( (RAM [NbP+i] > 0) && (ROM [NbP+2+i] > 0) )
      {
         /* Ajout dans la file des tempos */
         j=0;
         Stop_Cpt
         while (RAM [2*NbP+j] != SEP) j++;
         for (k=0 ; k<RAM [NbP+i] ; k++)
         {
            RAM [2*NbP+j+2*k] = i;
            RAM [2*NbP+j+2*k+1] = ROM [NbP+2+i];
         }
         RAM [2*NbP+j+2*k]=SEP;
         Cont_Cpt
      }
   }
}

char Places_Amont (int pos)
{
   int NbAmont;
   int IndP, Poids;
   int NbMB;   /* Nombre de marques "occup‚es" par une tempo. */
   int i,j;

   NbAmont = ROM [pos++];
   for (i=0 ; i<NbAmont ; i++)
   {
      IndP = ROM [pos++];
      Poids = ROM [pos++];
      /* Comptage du nombre de marques indisponibles */
      NbMB = 0;
      j=0;
      Stop_Cpt
      while (RAM [2*NbP+j] != SEP)
      {
         if ( (IndP == RAM [2*NbP+j]) && (RAM [2*NbP+j+1] > 0) )
            NbMB++;
         j += 2;
      }
      Cont_Cpt
      if ((RAM [IndP] - NbMB) < Poids)
         return 0;
   }
   return 1;
}

void Franchissement (int pos)
{
   int NbAmont;
   int NbAval;
   int i;

   NbAmont = ROM [pos++];
   /* Oter les marques des places en amont */
   for (i=0 ; i<NbAmont ; i++)
   {
      RAM [ROM [pos]] -= ROM [pos+1];
      pos += 2;
   }

   NbAval = ROM [pos++];
   /* Incrementer les places en aval */
   for (i=0 ; i<NbAval ; i++)
   {
      RAM [NbP+ROM [pos]] += ROM [pos+1];
      pos += 2;
   }
}

void Calcule_Sorties (int *pos)
{
   int p;
   int IndS;   /* Indice sortie */
   int PILE [TAILLE_PILE];
   int k;
   
   p = *pos;

   while (ROM [p] != SEPFIN)
   {
      IndS = ROM [p++];
      PILE [0] = (RAM [ROM [p++]] > 0);
      while (ROM [p] != SEP)
      {
         switch (ROM [p])
         {
            case 254 : PILE[0] = (PILE[0] && PILE[1]);
                       for (k=1 ; k<TAILLE_PILE-1 ; k++) PILE[k]=PILE[k+1];
                       break;
            case 253 : PILE[0] = (PILE[0] || PILE[1]);
                       for (k=1 ; k<TAILLE_PILE-1 ; k++) PILE[k]=PILE[k+1];
                       break;
            case 252 : PILE[0] = !PILE[0];
                       break;
            default  : for (k=TAILLE_PILE-1 ; k>=1 ; k--) PILE[k]=PILE[k-1];
                       PILE[0]=(RAM [ROM [p]] > 0);
                       break;
         }
         p++;
      }
      p++;
      if (!PILE[0])
         reset_sortie (IndS);
      else
         set_sortie (IndS);
   }
   *pos = p+1;
}

char Calcule_Entree (int *pos)
{
   int p;
   int IndE;   /* Indice entr‚e */
   int PILE [TAILLE_PILE];
   int k;
   char result;

   p = *pos;

   if (ROM [p] != SEP)
   {
      IndE = ROM [p++];
      PILE [0] = is_entree ((unsigned char)IndE);
      while (ROM [p] != SEP)
      {
         switch (ROM [p])
         {
            case 254 : PILE[0]=(PILE[0] && PILE[1]);
                       for (k=1 ; k<TAILLE_PILE-1 ; k++) PILE[k]=PILE[k+1];
                       break;
            case 253 : PILE[0]=(PILE[0] || PILE[1]);
                       for (k=1 ; k<TAILLE_PILE-1 ; k++) PILE[k]=PILE[k+1];
                       break;
            case 252 : PILE[0]=!PILE[0];
                       break;
            case 251 : PILE[0]=(PILE[0] && (!is_old_entree ((unsigned char)IndE)));
                       break;
            default  : for (k=TAILLE_PILE-1 ; k>=1 ; k--) PILE[k]=PILE[k-1];
                       IndE = ROM [p];
                       PILE [0] = is_entree ((unsigned char)IndE);
                       break;
         }
         p++;
      }
      result = PILE [0];
   }
   else
      result = 1;

   *pos = p+1;
   return result;
}

void Decremente_tempos (void)
{
   int N;
   int i,j;

   N=2*NbP;
   i=0;
   while (RAM [N+i] != SEP)
      if (RAM [N+i+1] > 0)
      { 
         RAM [N+i+1]--;
         i+=2;
      }
      else
      {
         /* Compactage de la base */
         j=0;
         while (RAM [N+j+i] != SEP)
         {
            RAM [N+i+j] = RAM [N+i+j+2];
            RAM [N+i+j+1] = RAM[N+i+j+3];
            j+=2;
         }
      }
}

interrupt [0x0B] void T0_int (void)      /* Timer 0 Overflow */
{
   TH0=INIT_TH;
   TL0=INIT_TL;
   Decremente_tempos ();
}
