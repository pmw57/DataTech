**** JK  03-10-11 11:11:26 

/*  Program ......:                   _APBTN.CH

    Authors.......: Thomas Leylan,  C Parry, John Kirby
    Date..........: 24/12/1994
    Functions.....:
*/

/* define button structure */

#define BN_ITEMS  1
#define BN_FRAME  2
#define BN_KSET   3
#define BN_CLRN   4
#define BN_CLRK   5
#define BN_MODE   6
#define BN_POSI   7
#define BN_PREV   8
#define BN_NEXT   9

#define BN_ROW    1
#define BN_COL    2
#define BN_NAME   3
#define BN_SPOT   4
#define BN_IMAGE  5

/* define button modes */

#define BN_DIM    0
#define BN_NORM   1

/* define button characters */

#define BN_CHARS  ( CHR(218) + CHR(196) + CHR(191) + CHR(179) + ;
                    CHR(217) + CHR(196) + CHR(192) + CHR(179) + ;
                    CHR(32) )

********--------------------  END OF FILE _APBTN.CH