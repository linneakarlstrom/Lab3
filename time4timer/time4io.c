#include <stdint.h>   /* Declarations of uint_32 and the like */
#include <pic32mx.h>  /* Declarations of system-specific addresses etc */
#include "mipslab.h"  /* Declatations for these labs */

/*
The switches SW4 through SW1 are connected 
to bits 11 through 8 of Port D. Which means that 
if I want to just have the least significant 4 bits i need
to bitwiste shift right 8 steps. */

// assignment 1 f)
int getsw(void){ //returnerar värdet av swticharna

    return (PORTD>>8) & 0xf; // 0xf = 1111 vilket motsvarar de fyra switcharna
}

/*
The switches SW4 through SW1 are connected 
to bits 7 through 5 of Port D. Which means that 
if I want to just have the least significant 3 bits i need
to bitwiste shift right 5 steps. */

// assignment 1 g)

int getbtns(void){ // returnerar värdet av knapparna. 
    // vi vill tre bitar vilket --> 000 (av) 111(på). 111 = 0x7. de motsvarar knapparna
    int btn = (PORTD>>5)  & 0x7; //skiftar 5 steg till höger
   // btn = (btn<<1); // shift to the left 1 step to make room for the last button.
    
   // btn = (PORTF >>1) & 0x1; // shift to the right 1 step (to the lsb) and mask with 1.

    
    return btn;
}