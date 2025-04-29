#define SORTIEL (*(char *) 0x1C000)
#define SORTIEH (*(char *) 0x1C001)
#define ENTREEL (*(char *) 0x1C000)
#define ENTREEH (*(char *) 0x1C001)

/*****************************************/
/********** Fonctions du module **********/
/*****************************************/
void ecrit_sorties (void);
#define set_sortie(n) _Sortie|=1<<n
#define reset_sortie(n) _Sortie&=~(1<<n)

unsigned int _Sortie=0;
unsigned int _Entree=0;
unsigned int _Old_Entree=0;

void lit_entrees (void)
{
   _Old_Entree=_Entree;
   _Entree=((unsigned int)(ENTREEH<<8)|ENTREEL);
}

char is_entree (unsigned char n)
{
   return (_Entree>>n)&0x01;
}

char is_old_entree (unsigned char n)
{
   return (_Old_Entree>>n)&0x01;
}

void ecrit_sorties (void)
{
  SORTIEL = (unsigned char) _Sortie;
  SORTIEH = (unsigned char) (_Sortie >> 8);
}


