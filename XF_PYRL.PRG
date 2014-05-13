   *** JK  14-11-10 14:29:21 

/* 
   Program.....:                  XF_PYRL.PRG
   Author......: J Kirby
   Date........: 23/08/1997
   Functions.. : PyrlProf
   Static funcs: PyrlProfH
*/

// (c) Copyright 1993 by Chozen Ltd Christchurch.

FUNCTION PyrlProf()

   LOCAL msaleno := SPACE( 4 )   
   LOCAL mwhere  := "S"
   LOCAL dfrdate  := DATE()-30
   LOCAL mok
   LOCAL dPdate:= dtodate  := DATE()
   LOCAL nl:= npl := 0
   LOCAL namounttot:= ncosttot:= namount:= ncost:= 0

   SCROLL()
   DISPBOX( 3, 1, 9,79, 2 )
   @  4,10 SAY "Select Sale Number :" GET msaleno PICTURE "@K!"
    READ
   SELECT SaleBook
   SEEK msaleno
   IF !FOUND()
       SbLook( @msaleno )                // XLF_Acc
      msaleno := SaleBook->Saleno 
   ENDIF
   @  6,10 SAY RTRIM( Message->Frdate ) GET dfrdate PICTURE "99/99/9999"
   @  8,10 SAY RTRIM( Message->Todate ) GET dtodate PICTURE "99/99/9999"
    READ
   IF PressedEsc()
      RETURN NIL
   ENDIF
   mwhere   := "S"

   Printsel( mwhere )

   IF mwhere == "P"
      SET MARGIN TO 0
   ELSE
      SCROLL()
      npl := 18
   ENDIF

   nl := PyrlProfH( dfrdate, dtodate )              // Below

   SELECT Hist
   GOTO TOP
    ApFLock( 3 )
   INDEX ON Invno TO TempInd8
   SET INDEX TO TempInd8
   UNLOCK
   GOTO TOP
   DO WHILE Hist->( !EOF() )
      IF Hist->PDate < dfrdate
         SKIP ALIAS Hist
         LOOP
      ENDIF
      IF Hist->PDate > dtodate
         SKIP ALIAS Hist
         LOOP
      ENDIF
      IF Hist->Saleno != msaleno
         SKIP ALIAS Hist
         LOOP
      ENDIF
      IF nl > npl
         IF mwhere == "P"
             EJECT
           ELSE
             WAIT
             SCROLL()
         ENDIF                       // mwhere = P

         nl := PyrlProfH( dfrdate, dtodate )                 // Below

      ENDIF                          // nl>npl
      namount:= ncost := 0
      SELECT Name
      SEEK Hist->Codeno
      SELECT Hist
      minvno := Hist->Invno
      DO WHILE Hist->Invno = minvno .AND. Hist->( !EOF() )
         ApRLock( 3 )
         namount    += Hist->Amount
         ncost      += Hist->Cost
         namounttot += Hist->Amount
         ncosttot   += Hist->Cost
         dPdate     := Hist->PDate
         UNLOCK
         SKIP ALIAS Hist
      ENDDO
      @ nl, 0 SAY minvno
      @ nl,10 SAY dPdate
      @ nl,22 SAY Name->Name
      @ nl,52 SAY namount PICTURE "99,999.99"
      @ nl,64 SAY ncost   PICTURE "99,999.99"
      @ nl,74 SAY ( ( namount-ncost )/namount )*100 PICTURE "9999 %"
      minvno := SPACE( 6 )
      nl++
      SKIP ALIAS Hist
   ENDDO
   @ nl,48 SAY REPLICATE( "-",28 )
   nl++
   @ nl,38 SAY "TOTALS"
   @ nl,48 SAY namounttot PICTURE "$9,999,999.99"
   @ nl,60 SAY ncosttot   PICTURE "$9,999,999.99"
   nl++
   @ nl,48 SAY REPLICATE( "=",28 )
   nl++
   @ nl,34 SAY namounttot-ncosttot                        PICTURE "$9,999,999.99" 
   @ nl,54 SAY ( ( namounttot-ncosttot )/namounttot )*100 PICTURE "9999 %" 
   nl+=2
   IF mwhere = "P"
      EndPrint()
      SET MARGIN TO 0
   ELSE
      WAIT
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF
   SELECT Hist
   SET INDEX TO HistInd

   RETURN NIL

   ******* End of PyrlProf()

**---------------------------------------------------------------------*

FUNCTION PyrlProfH( dfrdate, dtodate )

   @  0, 0 SAY Control->U_Name
   @  0,34 SAY dfrdate 
   @  0,47 SAY dtodate 
   @  0,62 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
   @  2, 0 SAY "Inv #"
   @  2,10 SAY "Date"
   @  2,22 SAY "Name"
   @  2,54 SAY "Amount"
   @  2,65 SAY "Cost"
   nl := 4

   RETURN nl

   ***--- End PyrlProf()

   **********------------------ END OF FILE XF_PYRL.PRG
