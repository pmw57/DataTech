*** JoKir02   25-02-11 05:43:46 

***          Afunc needed 
*** PAWILK10 03-10-13 23:20:20
***          Fix Mfunc so memoedit doesn't endlessly loop, and
***          apply some static variables to make the code easier to understand


/*  Program.....:                 _LF_INIT.PRG
    Authors.....:  John Kirby
    Date........:  26/12/1994
    Functions...:  Afunc, MFunc, Printest, Initenv,
                   Chkcode, Reindx, Lastused.
                   Contdbf(),  Start 
*/

#include "Default.ch"        // Custom commands.

FUNCTION Princhk()

LOCAL npcount, prnscrn  // This must come first !

IF ISPRINTER()                 // Check to see if we need to go on first
  RETURN .T.
ENDIF

/*
mwhere := "P"
*** npcount := 0
*** mtrue   := "Y"
*** prnscrn := SAVESCREEN( 4,10,14,70 )

COMMIT            // clears memory buffer
SET CONFIRM OFF   // Overcomes need for double keypress when using GETYN

DO WHILE !isprinter()
***  SETCOLOR(c_hicolor)
  IF npcount == 0           // Only need box @ start
    SCROLL( 2,10, 14,70 )
    @ 2,10 to 14,70 double
***   ELSE
***    SCROLL( 2,11, 13,69 )   // Clear box for subsequent messages
  ENDIF
  ? CHR(7)
  ** SETCOLOR(c_hicolor)
  IF npcount == 0
    @  4,27 SAY "PRINTING npcount = 0   mwhere "+mwhere
    @ 12,25 SAY "PRESS ANY KEY TO CONTINUE ..."
***   ELSEIF npcount > 2
***    ? CHR(7)
***    @  4,21 SAY "Should be Printing npcount >2    "+mwhere
***   ELSE
***    @  4,21 SAY "Should be Printing count Two mwhere "+mwhere
  ENDIF
***  npcount++
  IF mtrue == "Y" .OR. LASTKEY() == 27
****    SETCOLOR(c_stdcolor)
    RESTSCREEN(4,10,14,70,prnscrn)
    SET CONFIRM ON
    RETURN .F.
   ELSE
    INKEY(1)
    @ 12,25 SAY "PRESS ANY KEY TO CONTINUE ... mwhere ="+mwhere
    INKEY( 1)
  ENDIF
ENDDO

   SET CONFIRM ON
***   SETCOLOR(c_stdcolor)
***   RESTSCREEN(4,10,14,70,prnscrn)

RETURN .T.             // Don't terminate (mtrue = "N")

*/
*****  End of Princhk()

***-------------------------------------------------------------------------

FUNCTION Afunc( amode, apos, ascr )

  * Mode of ACHOICE; Array element; Screen element number

  whatkey := LASTKEY()

  IF whatkey == 27
     RETURN(1)
  ENDIF

  IF amode == 2                         // The end of the list
     KEYBOARD CHR(31)                  // = Ctrl Page Up
     RETURN(2)
    ELSEIF amode == 1                   // Cursor past top of list
     KEYBOARD CHR(30)                  // = Ctrl Page Down
     RETURN(2)
    ELSEIF amode == 3                   // Keystroke exception
     DO CASE
        CASE whatkey == 4               // End Right Arrow
           KEYBOARD CHR(30)
           RETURN(1)
        CASE whatkey == 19               // End Left Arrow
           KEYBOARD CHR(30)
           RETURN(1)
        CASE whatkey == 6               // End key
           KEYBOARD CHR(30)
           RETURN(2)
        CASE whatkey == 1               // Home key
           KEYBOARD CHR(31)
           RETURN(2)
        CASE whatkey == 13              // Enter key
           RETURN(1)
        CASE whatkey == -1              // F2
           RETURN(1)
        CASE whatkey == -2              // F3
           RETURN(1)
        CASE whatkey == -3              // F4
           RETURN(1)
        OTHERWISE
           RETURN(2)
     ENDCASE
    ELSE
     RETURN(2)
  ENDIF

RETURN( 2 )

*** End of Function Afunc

**-------------------------------------------------------------------

FUNCTION Mfunc( nmode, nrow, ncol )  // Function for MEMOEDIT
                                     // Ex Straley pp 696-7
                                     // Now streamlined !

   LOCAL nRetValue := 0

   STATIC pINS := 22, pLEFT_ARROW := 19, pRIGHT_ARROW := 4, pF10 := -9

   IF nmode==1 .OR. nmode==2

      DO CASE
         CASE LASTKEY() == pINS      // INSERT key
            READINSERT( !READINSERT() ) // Toggle Insert/Overwrite
            KEYBOARD CHR(pRIGHT_ARROW) + CHR(pLEFT_ARROW)
            SETCURSOR( IF( READINSERT(), 3, 1 ) ) // Change cursor form
            nRetValue := 32

         CASE LASTKEY() == pF10     // F-10 key = ALT-W
            SETCURSOR( 1 )          // Reset Cursor non Flashing
            READINSERT( .F. )    
            nRetValue := 23         // (Finish editing & save)
      ENDCASE

   ENDIF

   RETURN nRetValue

**  End of Function  --  MFUNC  **

**-------------------------------------------------------------------

FUNCTION PrintselY()

      mwhere := ApGetY( "Do you Want Printer" )
      IF mwhere == "Y"

         Princhk()                            // Below
         @  0, 0
         SET PRINTER TO
         SET DEVICE TO PRINT
         npl    := 55
         mwhere := "P"
        ELSE
         SCROLL()
         npl    := 18
         mwhere := "S"
      ENDIF 

RETURN( mwhere, npl )

***** End of PrintselY()

**-------------------------------------------------------------------

/*
            SCROLL()
            @ 1,10 SAY " "
            WAIT "-------   Demonstration ONLY no Printing ------- "
            SCROLL()
*/


**-------------------------------------------------------------------

FUNCTION Disclaimer()

LOCAL cmessage

SELECT Control
cmessage := Message->Copy_Rt1
cmessage += Message->Copy_Rt2

IF ALERT( cmessage, { "CONTINUE", "QUIT" } ) == 2
   QUIT
ENDIF

RETURN .T.

***---- End of Disclaimer()

**-------------------------------------------------------------------

FUNCTION Initenv()                          // Set working environment

  PUBLIC c_stdcolor, c_hicolor, c_fcolor, mcodeno, mpartnum, minvno, mwhere,;
         npl, nl, mnote, mmodcode, aCatcode_, mcashno, msaleno, mjobnum,;
         cedit, quotcodeno, cbranchid, coperno

  IF ISCOLOR()
     M->c_stdcolor:= "W+/B, GR+/R, B"
     M->c_hicolor := "GR+/R, , "
     M->c_fcolor  := "*W+/B"
    ELSE
     M->c_stdcolor:= "W,I"
     M->c_hicolor := "I"
     M->c_fcolor  := "*W+"
  ENDIF
SETCOLOR(M->c_stdcolor)

  IF ISCOLOR()
     c_stdcolor  := "W+/B, GR+/R, B"        // This is Standard all Blue

/*

*** TESTING COLORS
***     c_stdcolorA := "N+/W,N+/BG,B/W,B/BG+,B/W,B/BG+,R/W,B/R"  // From Tbdemo

***     c_stdcolorB := "N/W,N/BG,B/W,B/BG,B/W,B/BG,R/W,B/R"      // From Tbdemo
***     c_stdcolorE := "W+/B"        // This is Standard all Blue
****  Light Blue  POOR
     c_stdcolor := ( "+W/*N,N/W,,,+W/*N",;
                    "W/*N","R/*N","W/B","W/*N",;
                    "W/*B,+W/B,,,W/*B",; 
                    "W/*B","+R/*B","W/B","W/*B" ) 
****   Black and White 
     c_stdcolor := ( "W/N,N/W,,,+W/N",;
                    "W/N","W/N","N/W","W/N",;
                    "N/W,+W/N,,,N/W",; 
                    "N/W","+W/W","W/N","N/W" ) 
****   GREAN
     c_stdcolor :=  ( "W/B,B/W,,,+W/B",;
                    "+W/B","+R/B","+W/BG","W/B",;
                    "+W/BG,+W/B,,,+W/BG",; 
                    "+W/BG","+R/BG","W/B","W/BG" ) 
*/

     c_hicolor  := "GR+/R, , "
     c_fcolor   := "*W+/B"
    ELSE
     c_stdcolor := "W,I"
     c_hicolor  :="I"
     c_fcolor := "*W+"
  ENDIF

  SETCOLOR( c_stdcolor )

***  SET EPOCH TO 1990  // YEAR( DATE() )
  SET CENTURY ON
  SET DEVICE TO SCREEN
  SET TALK OFF
  SET BELL OFF
  SET SCOREBOARD OFF
  SET ESCAPE ON
  SET EXACT OFF
  SET CONFIRM ON
  SET DATE BRITISH
  SET DELIMITERS ON
  SET DELIMITERS TO "[]"
  SET DELETE ON
  SETCURSOR( 1 )                    // 3 = Big
  **  SET PATH TO          ????????

RETURN NIL

******** End of Initenv()

**-------------------------------------------------------------------
/*
TAKEN OUT

****** Reindx( mfils, mreindx )

    LOCAL afils := {}
    afils :=  DIRECTORY( mfils )
    ASORT( afils,,,{|aFile1,aFile2| aFile1[1] < aFile2[1]} ) // Sorts array

    dbdate := afils[1,F_DATE]
    dbtime := afils[1,F_TIME]
    FOR x = 2 TO LEN( afils )
       IF dbdate > afils[x,F_DATE]
          mreindx := .T.
         ELSEIF( dbdate == afils[x,F_DATE] ) .AND.;
               ( SUBSTR(dbtime,1,5 ) > SUBSTR( afils[x,F_TIME],1,5) )
          mreindx := .T.
       ENDIF
       IF mreindx == .T.
          @  4, 5 TO  6,65
          @  5,10 SAY "Indexing Files within MREINDX "+mfils
          RETURN( mreindx )
       ENDIF
    NEXT

RETURN( mreindx )

*****----- End of Reindx()
Taken Out
*/

**-------------------------------------------------------------------

FUNCTION Lastused( nl )                         // Display `last-used' date

   PRIVATE mdate, mdayn, mdayc, myrn, myrc

   mdate := CDOW( Control->Lastdate )+","
   mdayn := DAY(  Control->Lastdate )
   mdayc := STR( mdayn )
   mdate := mdate+LTRIM( mdayc )+" "
   mdate := mdate+CMONTH( Control->Lastdate )+","
   myrn  := YEAR( Control->Lastdate )
   myrc  := STR( myrn )

***   SCROLL( nl, 2, nl,78 ) 
   @ 21,32 SAY "Last Used "+mdate+LTRIM(myrc);
                +" "+Control->LastTime COLOR "RG+"

RETURN NIL

***------ End Lastused()

**------------------------------------------------------------------------

FUNCTION CENTRESAY( nrow, msg, nLeftPadding )  // 'SAY's message on specified line, centred

   DEFAULT NUMERIC nLEFTPadding TO 0

   @ nrow, nLeftPadding + INT( ( MAXCOL() - LEN(msg) ) /2 ) SAY msg

   RETURN NIL

**  End of Function  --  CENTRESAY  **

***--------------------------------------------------------------------------

FUNCTION Centre( msg )    // Centralises message no leading/trailing blanks

RETURN INT( ( MAXCOL() - LEN( msg ) ) /2 )

**  End of --  Centre()

**------------------------------------------------------------------------

******--------------------  END OF FILE _LF_INIT.PRG
