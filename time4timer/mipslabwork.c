/* mipslabwork.c

   This file written 2015 by F Lundevall
   Updated 2017-04-21 by F Lundevall

   This file should be changed by YOU! So you must
   add comment(s) here with your name(s) and date(s):

   This file modified 2017-04-31 by Ture Teknolog 

   For copyright and licensing, see file COPYING */

#include <stdint.h>   /* Declarations of uint_32 and the like */
#include <pic32mx.h>  /* Declarations of system-specific addresses etc */
#include "mipslab.h"  /* Declatations for these labs */

int mytime = 0x5957;

int timeoutcount = 0;

int prime =1234567;

char textstring[] = "text, more text, and even more text!";

/* Interrupt Service Routine */
void user_isr( void )
{
  return;
}

/* Lab-specific initialization goes here */
void labinit( void )
{
  //volatile ska användas assignment 1 c)
  volatile int *trise = (volatile int *) 0xbf886100;

  // assignment 1 e)
  TRISD = TRISD & 0x0fe0; // so that only bits 11 through 5 are set as inputs. trisd if 1 input if 0 output
  // 3 knappar och 4 siwtches vilket ger 7 bitar vilket ger 11 through 5
  //port representerar ifall något ska läsas eller skrivas.
  
  /* Initialisering av timer 2 */
  T2CON = 0x0; // 0 to stop the clock.
  
  T2CONSET = 0x70;

  TMR2 = 0; // to reset the clock
  
  PR2 = ((80000000 / 256) / 10); //divide by 10 because we want 100ms delay
  T2CONSET = 0x8000; // The timer can then be started by setting the ON bit to a ’1’. The ON bit is bit 15 in T2CON, and can be set to ’1’.

  
  return;
}

/* This function is called repetitively from the main program */
void labwork( void )
{
  
  // assignment 1 d)
  volatile int *porte = (volatile int *) 0xbf886110;

	(*porte) += 0x1;

  int buttons = getbtns();
  int switches = getsw();
  /*
  Om en knapp trycks läser den från sw4 till sw1 och ändrar siffran. 
  Om BTN4 trycks ska den ändra första minutsiffran
  Om BTN3 trycks ska den ändra andra minutsiffran
  Om BTN2 trycks ska den ändra första sekundsiffran
  */
  /*
  0x4 //första knappen 100 --> 4 (BTN4)
  0x2 //andra knappen 010 --> 2 (BTN3)
  0x1 //tredje knappen 001 --> 1 (BTN2)
  */

  if(buttons & 4){ //BTN4 (100)
    //getsw() --> få värdet från switcharna
    // byt ut första minutsiffran från värdet som vi får från getsw()
    mytime = mytime & 0x0fff; // so that we then can shift the new value to the same position (0x0957)
    mytime = (switches << 12) | mytime; //skiftar 12 steg åt vänster för att få den nya "siffran" på den dedikerade msb platsen för knappen.

  }

  if(buttons & 2){ // BTN3 (010)
    mytime = mytime & 0xf0ff;
    mytime = (switches << 8) | mytime;
  }

  if(buttons & 1){
    mytime = mytime & 0xff0f;
    mytime = (switches << 4) | mytime;
  }

  if(IFS(0)& 0x100){
     
      timeoutcount++;
      //Reset all the flags
      IFSCLR(0) = 0x100;

  }

  if(timeoutcount==10){
    // delay( 1000 );
    time2string( textstring, mytime );
    display_string( 3, textstring );
    display_update();
    tick( &mytime );
    display_image(96, icon);

    //reset timeoutcounter
    timeoutcount = 0;

  }

}