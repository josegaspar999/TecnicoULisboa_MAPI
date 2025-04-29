void init_serie(void)
{
 /* 8 bits donn‚es       1 arrˆt         pas de parit‚ */
 PCON = 0x80;   /* Ctrl de puissance */
 TMOD = 0x22;   /* Mode de fonct. du cpt/timer 1 */
 TH1 = 256-9;   /* Vitesse = (16Mhz / 12) / (16 * 9) = 9259.25 bps */ 
 TCON.6 = 1;    /* Timer 1 ENABLE */
 SCON = 0x52;   /* Crtl du port s‚rie */
}

char IsCar (void)
{
   return (RI);
}

void LitCar (char *Car)
{
   while (!IsCar());
   *Car=SBUF;
   RI=0;
}

void EcritCar (char Car)
{
   int i;

   while (!TI);
   TI=0;
   SBUF=Car;
}

void EcritChaine (char *Chaine)
{
   while (*Chaine!=0)
   {
      while (!TI);
      TI=0;
      SBUF=*Chaine;
      Chaine++;
   }
}

