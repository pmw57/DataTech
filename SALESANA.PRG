   *** JK  29-01-10 16:20:05 

/* 
   Program......:        SALESANA.PRG
   Authors......: J Kirby
   Date.........: 12/04/1985
   Function.....: CatSupp, SaleAnal
   Static funcs.: RecanHd
*/

// (c) Copyright 1993 by Kirby Christchurch.

FUNCTION CatSupp( ccatno )

   SCROLL()
   SELECT Part
   GOTO TOP
   SET ORDER TO 2
   SEEK ccatno
   nl := 1
   npl := 25
   @ nl, 3 SAY Cat->Catno+"  "+Cat->Catdesc
   nl+=2
   @ nl, 2 SAY "Part #"
   @ nl,18 SAY "Description"
   @ nl,60 SAY "Supplier" 
   nl++
   DO WHILE Part->Catno == ccatno .AND. Part->( !EOF() )
      IF nl > npl
         WAIT
         SCROLL()
         nl := 1
         @ nl, 3 SAY Cat->Catno+"  "+Cat->Catdesc
         nl+=2
         @ nl, 2 SAY "Part #"
         @ nl,18 SAY "Description"
         @ nl,60 SAY "Supplier" 
         nl++
      ENDIF
      @ nl, 2 SAY SUBSTR( Part->Partnum, 1,16 )
      @ nl,20 SAY Part->Desc
      @ nl,60 SAY Part->Codeno
      nl++
      SELECT Part 
      SKIP ALIAS Part
   ENDDO                      // Part  Catno       
   mcodeno := SPACE( 8 )
    Namerank( @mcodeno )                          // XLF_Name
   IF PressedEsc() 
      RETURN NIL
   ENDIF
   SELECT Name
   mcodeno := Name->Codeno
   SCROLL()
   @  3, 3 SAY Cat->Catno+"  "+Cat->Catdesc
   @  5,10 SAY "BEWARE THIS CHANGES ALL PARTS IN THIS CATALOGUE"
   @  6,10 SAY "TO THE SELECTED SUPPLIER"
   @ 10,10 SAY Name->Codeno+"  "+Name->Name 
   mcorrect := ApGetY( "New Supplier Correct" )
   IF mcorrect = "Y"
      SCROLL()
      SELECT Part
      GOTO TOP
      SET ORDER TO 2
      SEEK ccatno
      nl := 0
      npl := 25
      ApFLock( 3 )
      DO WHILE Part->Catno == ccatno .AND. Part->( !EOF() )
         msuplcode := Part->Codeno
         REPLACE Part->Codeno WITH mcodeno
         IF nl > npl
            WAIT
            SCROLL()
            nl := 0
         ENDIF
         @ nl, 2 SAY SUBSTR( Part->Partnum, 1,16 )
         @ nl,20 SAY Part->Desc
         @ nl,60 SAY msuplcode 
         @ nl,70 SAY Part->Codeno
         nl++
         SKIP ALIAS Part
      ENDDO                      // Part  Catno       
      UNLOCK
   ENDIF           // mcorrect
   WAIT
   RETURN NIL

   ***--- End of CatSupp

   **-------------------------------------------------------------------

FUNCTION SaleAnal()

   SELECT Rec
   GOTO TOP
    ApFLock( 3 )
   INDEX ON Saleno TO TempInd4
   SET INDEX TO TempInd4
   UNLOCK
   mcontinue:= mok:= "Y"
   DO WHILE mcontinue == "Y"
      mmamntmnth:= mmamount:= mmamntlyr := 0
      mtotmnth:= mtotamnt:= mtotlyr := 0
      mmm:= myy:= mvalyy:= mvalmm := 0
      SCROLL()
      @  0, 5 TO 2,75
      @  1,20 SAY "List Receipts by Salesbook"
      @  3, 5 TO  7,75
      @  4,10 SAY "Please Provide Month & Year"
      msys := SUBSTR(DTOC(DATE()),4,7)
      @  6,10 SAY "Month & Year MM/YYYY" GET msys PICTURE "99/9999"
       READ
      mwhere := "S"

       Printsel( mwhere )

      mmm     := SUBSTR( msys,1,2 )
      myy     := SUBSTR( msys,4,4 )
      mvalmm  := VAL(mmm)
      mvalyy  := VAL(myy)
      msameyr := "F"
      IF mvalmm < 4
         msameyr := "S"
      ENDIF
      IF mwhere = "P"
         @  0, 0
         SET DEVICE TO PRINT
         npl := 56
       ELSE
         npl := 18
         nl  := 25
      ENDIF
      SCROLL()

       Recanhd()                               // Below

      SELECT SaleBook
      GOTO TOP
      DO WHILE SaleBook->( !EOF() )
         IF nl > npl
            IF mwhere = "P"
               EJECT
             ELSE
               WAIT
               SCROLL()
            ENDIF

             Recanhd()                         // Below

         ENDIF
         @ nl, 0 SAY Salebook->Saleno
         @ nl, 6 SAY Salebook->Sbname
         msaleno :=  Salebook->Saleno
         SELECT Rec
         SEEK msaleno
         DO WHILE Rec->Saleno == msaleno .AND. Rec->( !EOF() )
            mamntmnth:= mamount:= mamntlyr:= mmonth := 0
            mrecyy  := SUBSTR( DTOC(Recdate),7,4 )
            mvrecyy := VAL(mrecyy)
            mrecmm  := SUBSTR(DTOC(Rec->Recdate),4,2)
            mvrecmm := VAL(mrecmm)
            DO CASE
               CASE mvrecyy == mvalyy
                  DO CASE
                     CASE mvrecmm == mvalmm
                        STORE Rec->Recamnt TO mamntmnth, mmonth
                     CASE mvrecmm < 4
                        IF msameyr = "S"
                           IF mvrecmm < mvalmm
                              mamount := Rec->Recamnt
                           ENDIF
                         ELSE
                           mamntlyr := Rec->Recamnt
                        ENDIF
                     CASE mvrecmm > 3
                        IF mvrecmm < mvalmm
                           mamount := Rec->Recamnt
                        ENDIF
                  ENDCASE
               CASE mvrecyy = (mvalyy - 1)
                  DO CASE
                     CASE mvrecmm > 3
                        IF msameyr = "S"
                           IF mvrecmm < mvalmm
                              mamount := Rec->Recamnt
                           ENDIF
                         ELSE
                           mamntlyr := Rec->Recamnt
                        ENDIF
                     CASE mvrecmm < 4
                        IF msameyr = "S"
                           mamntlyr := Rec->Recamnt
                        ENDIF
                     ENDCASE
               CASE mvrecyy = (mvalyy - 2)
                     IF msameyr = "S"
                        IF mvrecmm > 4
                           mamntlyr := Rec->Recamnt
                        ENDIF
                     ENDIF
            ENDCASE
            mmamount   := mmamount+mmonth  
            mmamntmnth := mmamntmnth+mamntmnth
            mmamount   := mmamount+mamount
            mmamntlyr  := mmamntlyr+mamntlyr
            SKIP ALIAS Rec
         ENDDO
         @ nl,37 SAY mmamntmnth PICTURE "9,999,999.99"
         @ nl,52 SAY mmamount   PICTURE "9,999,999.99"
         @ nl,68 SAY mmamntlyr  PICTURE "9,999,999.99"
         nl++
         mtotmnth := mtotmnth+mmamntmnth
         mtotamnt := mtotamnt+mmamount
         mtotlyr  := mtotlyr+mmamntlyr
         mmamntmnth:= mmamount:= mmamntlyr := 0
         SELECT Salebook
         SKIP ALIAS SaleBook
      ENDDO
      @ nl,36 SAY "--------------------------------------------"
      nl++
      @ nl,37 SAY mtotmnth PICTURE "9,999,999.99"
      @ nl,52 SAY mtotamnt PICTURE "9,999,999.99"
      @ nl,68 SAY mtotlyr  PICTURE "9,999,999.99"
      nl++
      @ nl,36 SAY "============================================"
      IF mwhere = "P"
         EndPrint()
        ELSE
         IF nl > 18
            WAIT
         ENDIF
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
      ENDIF
      mcontinue := ApGetN( "Another Months Listing" )
   ENDDO
   SELECT Rec
   SET INDEX TO RecInd

   RETURN NIL

   ***--- End of Saleanal

   **-------------------------------------------------------------------

STATIC FUNCTION RecanHd()

   @  1, 0 SAY "Receipts "+TRIM( Control->U_Name )+" Month "+msys
   @  1,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  3, 0 SAY "Sale"
   @  3, 6 SAY "Name"
   @  3,42 SAY "Month"
   @  3,50 SAY "Year To Date"
   @  3,69 SAY "Last Year"
   nl := 5

   RETURN NIL
   ***--- End Recanhd()

   *****------------------- END OF FILE SALESANA.PRG
