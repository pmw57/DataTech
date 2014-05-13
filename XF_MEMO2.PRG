***  JoKir10 04-10-11 06:08:49 
*** PAWILK10 03-10-13 23:28:05
***        - Update Dispmemo function to allow it to display at different locations
***        - Update MemoDisp to display "press any key" at a better location

***        - add default.ch for smartly and concisely defining
***          default parameters for a function.
***  Source: http://www.ghservices.com/gregh/clipper/trix0005.htm
***          Supported types are: array, block, code block, codeblock,
***          character, string, date, logical, memo, number, numeric
***
***   Usage: DEFAULT NUMERIC nTop TO 0
***          The above results in the following equivalent code:
***          IF .NOT. (VALTYPE( nTop ) == 'N' )
***             nTop := 0
***          ENDIF

/* Program.....: XF_MEMO2.PRG 
   This is the LIBRARY of Functions for Memo using a simple database file
   instead of .DBT file for text;  overcomes problem of .DBT file bloat
   and will also re-cycle surplus records.
   Author......: L.C.Parry, J.Kirby
   Date........: 17/05/87 - Modified 2nd July 1996
   Called by...: Resident, Faults
   Functions...: M2MemoFile, MemoFile, MemoDispm GetDets
                 FormP
   Static funcs: Dispmemo, Dispdets, Amendet, Writedets
   Not used....: Form
*/

#include "Default.ch"        // Custom commands.

FUNCTION M2MemoFile( coderef )
   // coderef is code ref of master file record

   LOCAL cdetail
   SELECT Cusnotes
   **** SET EXACT ON        // was OFF
   SEEK coderef
   IF !FOUND()
      SCROLL(  16, 3, 18,78 )
      DISPBOX( 16,10, 18,70, 2 )
      @ 17,16 SAY "No Memo exists for this record ..."
      mok := ApGetN( "Add New Memo" )
      IF mok == "Y"
         SCROLL( 17, 5, 17,73 )
         ApFLock( 3 )
         APPEND BLANK
         Cusnotes->Code_Ref := ( coderef )+"00"   // ( STR( ndetnum,2 ) )
         UNLOCK
      ELSE
         RETURN NIL
      ENDIF

   ENDIF

   cdetail := Getdets( coderef )

   Dispdets( coderef,cdetail )

   mok := ApGetN( TRIM( Message->Delete )+" Memo" )
   IF mok == "Y"
      SELECT Cusnotes
      SEEK coderef
      ApFLock( 3 )
      DO WHILE FOUND()
         DELETE
         SEEK coderef
      ENDDO
      UNLOCK
   ENDIF

   ***  SET EXACT OFF

   RETURN NIL
   **  End of M2Memofile()

   **------------------------------------------------------------------------

FUNCTION MemoFile( coderef )
   // coderef is code ref of master file record

   LOCAL cdetail
   SELECT Cusnotes
   SEEK coderef
   IF !FOUND()
      SCROLL(  16, 3, 18,76 )
      DISPBOX( 16,10, 18,70, 2 )
      @ 17,16 SAY "No Memo exists for this record ..."
      mok := ApGetN( "Add New Memo" )
      IF mok == "Y"
         SCROLL( 17, 5, 17,73 )
          ApFLock( 3 )
         APPEND BLANK
         Cusnotes->Code_Ref := ( coderef )+"00"   // ( STR( ndetnum,2 ) )
         UNLOCK
       ELSE
        RETURN NIL
      ENDIF
   ENDIF
   cdetail := Getdets( coderef )
   Dispdets( coderef,cdetail )
   RETURN NIL
   **  End of Memofile()

   ****---------------------------------------------------------------------------

FUNCTION MemoDisp( coderef )

   LOCAL cdetail, cMsg

   SELECT Cusnotes
   SEEK coderef
   IF !FOUND()
      RETURN NIL
   ENDIF

   cdetail := Getdets( coderef )

   Dispmemo( coderef,cdetail )

   cMsg := "Press any key to continue ..."
   @ 22, CENTRE( cMsg ) SAY cMsg
   INKEY(0) 

   RETURN NIL
   **  End of MemoDisp()

   **--------------------------------------------------------------------

STATIC FUNCTION Dispmemo( coderef, cdetail, nTop, nLeft, nHeight, nWidth )

   LOCAL nBottom, nRight, cMsg

   DEFAULT NUMERIC nTop TO 5
   DEFAULT NUMERIC nLeft TO 10
   DEFAULT NUMERIC nHeight TO 15
   DEFAULT NUMERIC nWidth TO 62

   nBottom := nTop + nHeight
   nRight := nLeft + nWidth
   cMsg := " Memo "

   SCROLL(  nTop, nLeft, nBottom, nRight )
   DISPBOX( nTop, nLeft, nBottom, nRight, 2 ) 
   @ nTop, nLeft + 4 SAY cMsg + ":  " COLOR "BG+"
   @ nBottom, CENTRE( cMsg ) SAY cMsg COLOR "R+"

   MEMOEDIT( cdetail, nTop + 1, nLeft + 2, nBottom - 1, nRight - 5, .F.,.F. )  // Clipper Routine

   RETURN NIL
   **  End of Function  --  DispMemo()

   **-------------------------------------------------------------------

FUNCTION GetDets( coderef )

   cdetail:= ""
   DO WHILE Cusnotes->Code_Ref = coderef
     cDetail += Cusnotes->Details     // Accumulate text from multiple records
     SKIP ALIAS Cusnotes              // Look at next record
   ENDDO

   RETURN TRIM( cdetail )

   **  End of Function  --  GetDets()

   **-------------------------------------------------------------------

STATIC FUNCTION Dispdets( coderef, cdetail )

   SCROLL(  13, 5, 23,76 )
   DISPBOX( 13,10, 23,70, 2 )
   @ 13,14 SAY " Memo.: " COLOR "BG+"
   SET CURSOR OFF     // Hides cursor from display
   MEMOEDIT( cdetail, 14,12, 22,65, .F.,.F. )
   // Show Memos inside box
   SET CURSOR ON

   IF !EMPTY(cdetail)
      mok := ApGetN( "Any Changes to Memo " )
      IF mok == "N"
         RETURN NIL
      ENDIF
   ENDIF
   Amendet( coderef,cdetail )

   RETURN NIL
   **  End of Function  --  Dispdets()

   **-------------------------------------------------------------------

STATIC FUNCTION Amendet( coderef,cdetail )

   LOCAL lreadwrite := .T.
   LOCAL cmsg       := "Add Details - Save with F10 Key"
   LOCAL crlf       :=" "+CHR( 141 )+CHR( 10 )

     /* Space/soft carriage return/line feed - needed for later removal
      STRTRAN function removes soft carriage return/line feed
      by replacing chr(141) + chr(10) with chr(20)
     */
   SCROLL ( 13, 5, 23,76 )
   DISPBOX( 13,10, 22,70,2 )
   @ 13,14 SAY " Memo : " COLOR "R+"
   ***   DISPBOX(  3, 1, 24,79,2 )
   CentreSay( 23, cmsg, c_hicolor )
   cdetail := MEMOEDIT( cdetail,14,12, 21,65, lreadwrite, "MFunc" )
   cdetail := STRTRAN( cdetail,crlf,CHR( 32 ),, )
   cdetail := TRIM( cdetail )    // Remove trailing blanks from new details

   Writedets( coderef,cdetail ) // Writes to Cusnotes

   RETURN NIL
   **  End of Function  --  Amendet()

   **-----------------------------------------------------------------

STATIC FUNCTION Writedets( coderef,cdetail )

   LOCAL ndetnum:=0
   LOCAL nendrec,ncodelen
   SELECT Cusnotes
   ***  SET EXACT OFF
   SEEK coderef
   ncodelen:=LEN(Code_Ref)  // This variable copes with different lengths
   DO WHILE LEN( TRIM( cdetail ) ) >0  // i.e. until all written to file
      IF LEN( TRIM( cdetail ) ) <= 50
         // cdetail is decremented by 50 char's for each record in set
         IF Cusnotes->Code_ref = coderef  // We have found a record to replace
            // N.B. Can't use '==' here which means exact match
            ApRLock( 3 )
            Cusnotes->Code_ref := coderef+STR( ndetnum,2 )
            Cusnotes->Details  := cdetail
            nendrec := RECNO()   // Require this for record blanking if req'd
            UNLOCK
            /* If we blank a record, record pointer is now at BOF() ! and
               therefore this (disabled) DO WHILE will only blank one record !
               DO WHILE Cusnotes->Code_ref == coderef
                  ApRLock( 3 )
                 Cusnotes->Code_ref := SPACE(ncodelen)
                 Cusnotes->Details  := SPACE(50)
                 UNLOCK
               ENDDO
            */
            DO WHILE .T.
               GO nendrec         // This is last record (or only one) in set
               SKIP               // Go to next record (in index, of course)
               IF Cusnotes->Code_ref = coderef
                  ApRLock( 3 )
                  Cusnotes->Code_ref := SPACE( ncodelen )
                  Cusnotes->Details  := SPACE( 50 )
                  UNLOCK
               ELSE              // No more to blank out
                  EXIT
               ENDIF
            ENDDO
         ELSE                  // No existing record
            GO TOP               // Check for blank record
            IF EMPTY( Cusnotes->Code_ref )
               ApRLock( 3 )
               Cusnotes->Code_ref := coderef+STR( ndetnum,2 )
               Cusnotes->Details  := cdetail
               UNLOCK
            ELSE                // New or expanded Details
              ApFLock( 3 )
              APPEND BLANK
              Cusnotes->Code_ref := coderef+STR( ndetnum,2 )
              Cusnotes->Details  := cdetail
              UNLOCK
            ENDIF
         ENDIF       // End of write if Details <= 50 long
         cdetail := ""           // All Details written to file
         // Will force exit from main DO WHILE loop - (LEN( cdetail ) <= 50)
      ELSE                // LEN(TRIM( cdetail) ) > 50
         IF Cusnotes->Code_ref = coderef  // There is an existing record
            ApRLock( 3 )
            Cusnotes->Code_ref := coderef+STR( ndetnum,2 )
            Cusnotes->Details  := cdetail
            UNLOCK
         ELSE
            GO TOP               // Check for blank record
            IF EMPTY( Cusnotes->Code_ref )
               ApRLock( 3 )
               Cusnotes->Code_ref := coderef+STR( ndetnum,2 )
               Cusnotes->Details  := cdetail
               UNLOCK
            ELSE
               ApFLock( 3 )
               APPEND BLANK
               Cusnotes->Code_ref := coderef+STR( ndetnum,2 )
               Cusnotes->Details  := SUBSTR( cdetail,1,50 )
               UNLOCK
            ENDIF
         ENDIF
         SKIP
         cdetail := SUBSTR( cdetail,51,LEN( cdetail )-50 )
         ndetnum++
      ENDIF
   ENDDO

   RETURN NIL
   **  End of Function  --  WriteDets()

   **-------------------------------------------------------------------

FUNCTION Form( cString,nWide,nAnchor )   // Copied from Straley p701

   // This is the print function
   // cString  - string to columnise
   // nWide    - width of text
   // nAnchor  - Beginning position of text column(s)

   LOCAL cPadding:= SPACE( nAnchor )
   LOCAL nCounter
   LOCAL nHowmany:= MLCOUNT( cString, nWide, .T. )

   FOR nCounter:= 1 TO nHowmany

      DEVPOS( ROW()+1,nanchor )  // This is mine - Offsets print on new line
      QQOUT(MEMOLINE( cString, nWide, nCounter, , .T. ) )  //+CHR(13)+CHR(10) )

   NEXT

   RETURN NIL
   **  End of Function  --  Form()

   **----------------------------------------------------------------------

FUNCTION FormP( cString,nWide,nAnchor )   // Copied from Straley p701
   // This is the print function
   // cString  - string to columnise
   // nWide    - width of text
   // nAnchor  - Beginning position of text column(s)

   LOCAL nCounter
   LOCAL nHowmany:= MLCOUNT( cString, nWide, .T. )

   FOR nCounter := 1 TO nHowmany

      @ nl, 4 SAY MEMOLINE( cString, nWide, nCounter, , .T. )
      IF mwhere = "S"
         IF nl > 22
            WAIT
            SCROLL()
            nl := 0
         ENDIF
      ENDIF
      nl++
   NEXT

   RETURN NIL
   **  End of Function  --  FormP()

   **-------------------------- End of XF_Memo2.PRG
