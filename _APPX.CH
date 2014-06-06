**** JK 03-10-11 11:12:11 

/*  Program ......:                 APPX.CH

    Authors.......: Thomas Leylan,  C Parry, John Kirby
    Date..........: 24/12/1994
    Functions.....: 
*/

#define _ON    .T.
#define _OFF   .F.

/* define colors */

#define CS_MAIN   1                     // Blue

#define CS_MUNS   2                     // Green
#define CS_MKEY   3                     // Cyan
#define CS_MSEL   4                     // Red
#define CS_MDIM   5                     // Magenta

#define CS_DBOX   6                     // Brown

#define CS_BUNS   7                     // White
#define CS_BKEY   8                     // Gray
#define CS_BSEL   9                     // Bright Blue
#define CS_BDIM   10                    // Bright Green

#define PAUSE( nSec )    TONE( 1, ( nSec ) * 18 )

#define ApTran( uData, cPict ) ;
   IF( EMPTY( uData ), "", TRANS( uData, cPict ) )


********----------------  END OF FILE _APPX.CH