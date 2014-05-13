**  JK  08-09-11 15:26:06 

/* 
   Program......:                  RECNAME.PRG
   Authors......: J Kirby
   Date.........: 25/07/1992
   Function.....: NameRec
   Static funcs.: Recnamehd
*/

FUNCTION NameRec()

   mcodeno := SPACE( 8 )
   mselect := "I"
   SCROLL()
   @  5,10 SAY "All Receipts or Individual Name Only  A/I ";
           GET mselect PICTURE "@!" VALID(mselect $ "IA")
    READ
   IF mselect == "I"

      Namerank()                            // XLF_Name

      IF PressedEsc()
         RETURN NIL
      ENDIF
      mcodeno := Name->Codeno
      SCROLL( 4, 0,24,80 )
   ENDIF
   mstmm  := DATE()-90
   mendmm := DATE()
   @  17,10 SAY Message->Frdate GET mstmm  PICTURE "99/99/9999"
   @  18,10 SAY Message->Todate GET mendmm PICTURE "99/99/9999"
    READ
   IF PressedEsc()
      RETURN NIL
   ENDIF
   mamount:= mnametot := 0
   nl     := 2
   mwhere := "S"
   npl    := 54

   Printsel()                              // _LP_Init

   Recnamehd()                             // Below

   mfirst  := "Y"
   SELECT Rec
   GOTO TOP
   IF mselect = "I"
      SEEK Name->Codeno
   ENDIF
   DO WHILE Rec->( !EOF() )
      IF Rec->RecDate < mstmm          // Includes the Date From
         SKIP ALIAS Rec
         LOOP
      ENDIF
      IF Rec->RecDate > mendmm         // Includes the Date Up to
         SKIP ALIAS Rec
         LOOP
      ENDIF
      IF mselect = "I"
         IF Rec->Codeno != mcodeno
            SKIP ALIAS Rec
            LOOP
         ENDIF
      ENDIF
      IF nl > npl
         IF mwhere = "P"
           EJECT
         ELSE
            WAIT
            SCROLL()
         ENDIF

          Recnamehd()                                     // Below

      ENDIF
      IF mfirst = "Y"
         IF SUBSTR( Recno,1, 1 ) = "Z"
            @ nl,52 SAY "-------------"
            nl++
            @ nl,35 SAY "Receipts ="
            @ nl,52 SAY mnametot PICTURE "$9,999,999.99"
            nl+=2
            mnametot := 0
            mfirst   := "N"
         ENDIF
      ENDIF
       ApFLock( 3 )
      mamount  += Rec->Recamnt
      mnametot += Rec->Recamnt
      UNLOCK
      @ nl, 0 SAY Rec->Recno
      @ nl, 8 SAY Rec->Recdate
      @ nl,20 SAY Rec->Invno
      SELECT Name
      SEEK Rec->Codeno
      @ nl,29 SAY SUBSTR( Name->Name,1,19 )
      SELECT Rec
      @ nl,51 SAY Rec->Recamnt PICTURE "9999,999.99"
      @ nl,64 SAY Rec->Saleno
      IF Rec->Jobno != Rec->Recno
         @ nl,70 SAY Rec->Jobno 
      ENDIF
      nl++
      SKIP ALIAS Rec
   ENDDO
   IF mfirst = "N"
      @ nl,49 SAY "-------------"
      nl++
      @ nl,30 SAY "Repayments ="
      @ nl,49 SAY mnametot PICTURE "$9,999,999.99"
      nl+=2
   ELSE
      @ nl,49 SAY "-------------"
      nl++
      @ nl,30 SAY "Receipts Total ="
      @ nl,49 SAY mnametot PICTURE "$9,999,999.99"
   ENDIF
   nl++
   IF mwhere = "P"
      EndPrint()
   ELSE
      WAIT
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF

   RETURN NIL

   **** End of File Recname.PRG

   **-------------------------------------------------------------------

FUNCTION Recnamehd()

   @  0, 0 SAY Control->U_Name+" Receipts"
   @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
   @  2, 0 SAY "Rec No"
   @  2, 9 SAY "Date"
   @  2,20 SAY "Inv"
   @  2,30 SAY "Name"
   @  2,55 SAY "Amount"
   @  2,64 SAY "Sale"
   nl := 4

   RETURN NIL
   ****------ End of Recnamehd()

   *****--------------------   END OF FILE RECNAME.PRG

