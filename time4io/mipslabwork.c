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
  trisd = trisd & 0x0fe0 // so that only bits 11 through 5 are set as inputs. trisd if 1 input if 0 output
  // 3 knappar och 4 siwtches vilket ger 7 bitar vilket ger 11 through 5
  //port representerar ifall något ska läsas eller skrivas.

  return;
}

/* This function is called repetitively from the main program */
void labwork( void )
{
  /*
  Om en knapp trycks läser den från sw4 till sw1 och ändrar siffran. 
  Om BTN4 trycks ska den ändra första minutsiffran
  Om BTN3 trycks ska den ändra andra minutsiffran
  Om BTN2 trycks ska den ändra första sekundsiffran
  */
/*
 0x4 //första knappen 100 --> 4
 0x2 //andra knappen 010 --> 2
 0x1 //tredje knappen 001 --> 1
*/

  // assignment 1 d)
  volatile int *porte = (volatile int *) 0xbf886110;

	(*porte) += 0x1;

  delay( 1000 );
  time2string( textstring, mytime );
  display_string( 3, textstring );
  display_update();
  tick( &mytime );
  display_image(96, icon);

}