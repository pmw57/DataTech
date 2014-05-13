   *** JK  08-11-11 14:41:53 

/* 
   Program.....:                  XLF_DEP.PRG
   Authors.....: J.Kirby
   Date........: 11/03/1995
   Functions...: CredAdd, MenuDep, Depadd, Depview
   Static funcs: Credout, DepnoList, Deposit, DepRev
                 Deplist, SbookLst
*/

STATIC FUNCTION Credout( mcodeno )

   SCROLL(  3, 0, 24,80 )
   DISPBOX( 0, 1, 2,79, 2 )    // This is needed for Display Name
   SELECT Credit
   SEEK mcodeno
   mcol     := "F"
   npl      := 20
   nl       := 4
   mcredtot := 0
   DO WHILE Codeno == mcodeno .AND. Credit->( !EOF() )
      IF nl > npl
         IF mcol == "S"
            mcol := "F"
            WAIT
            SCROLL( 4, 0, 24,78 )
         ELSE
            mcol := "S"
         ENDIF
         nl := 4 
      ENDIF
      IF mcol == "F"
         @ nl, 1 SAY Credit->Invdate
         @ nl,12 SAY Credit->Invno
         @ nl,22 SAY Credit->Cashno
         @ nl,27 SAY Credit->Amount PICTURE "$99,999.99"
         @ nl,39 SAY Credit->Stat
      ELSE
         @ nl,40 SAY Credit->Invdate
         @ nl,51 SAY Credit->Invno
         @ nl,61 SAY Credit->Cashno
         @ nl,66 SAY Credit->Amount PICTURE "$99,999.99"
         @ nl,77 SAY Credit->Stat
      ENDIF
      mcredtot += Credit->Amount
      ***       mcashno  := Credit->Cashno
      nl++
      SKIP ALIAS Credit
   ENDDO
   nl++
   @ nl, 5      SAY Name->Name COLOR "RG+"
   @ nl,COL()+2 SAY "Creditor Total ="
   @ nl,COL()+2 SAY mcredtot PICTURE "$999,999.99"
   @ 1, 5      SAY "                                                    "
   @ 1, 5      SAY Name->Name COLOR "RG+"
   @ 1,COL()+2 SAY "Creditor Total ="
   @ 1,COL()+2 SAY mcredtot PICTURE "$999,999.99"
   nl++
   @ nl, 2 SAY "  " 
   WAIT
   IF PressedEsc() 
      RETURN NIL
   ENDIF

   RETURN NIL
   ***---- End of Credout()

   **-------------------------------------------------------------------

FUNCTION CredAdd()

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"

      SCROLL()
      ***     mcodeno := SPACE( 8 )
      SELECT Credit
      mtempcode := "A       "
      GOTO TOP
      SEEK mtempcode
      IF !FOUND()
          ApFLock( 3 )
         APPEND BLANK
         Credit->Codeno := "A      " 
         UNLOCK
      ENDIF 

       DISPBOX( 0, 1, 2,79, 2 )
       mcodeno := SPACE( 8 )
       nrecno  := 0
       ntotal  := 0
       aPart_  := {}
       SELECT Credit
       GOTO TOP
       IF LASTREC() != 0
         DO WHILE Credit->( !EOF() )
            SELECT Name
            SEEK Credit->Codeno
            SELECT Credit
            ntotal += Credit->Amount
            AADD( aPart_,Name->Name;
               +" "+STR( Credit->Amount )+"  "+DTOC( Credit->InvDate );
               +" "+Invno+"  "+Credit->Cashno+" "+Credit->Stat;
               +"     "+STR( RECNO(),6 ) )
            SKIP ALIAS Credit
         ENDDO                          // EOF()
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            @  1,10 SAY "Creditors View"
            @  1,50 SAY ntotal PICTURE "$9,999,999.99" COLOR "G+"
            anum   := ACHOICE( 4, 3, 23,78, aPart_,,"AFUNC" )      // Cant Sort
            IF PressedEsc() 
               RETURN NIL
            ENDIF
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         ENDIF             // Empty
         GOTO nrecno
         SELECT Credit
         mcodeno := Credit->Codeno
      ENDIF                        // LastRec()
      ***   ENDCASE
      ***   mok := "Y"
      ***   DO WHILE mok == "Y"
      IF mcodeno = "A       "
          Namerank()                              //  XLF_Name
          mcodeno := Name->Codeno         

      ENDIF  // mcodeno = A
      SELECT Name
      SEEK mcodeno
      mcashno := Name->Cashno
      IF PressedEsc()
         RETURN NIL
      ENDIF
      mok      := "Y"
      DO WHILE mok == "Y"

          Credout( mcodeno )      
         IF PressedEsc() 
            RETURN NIL
         ENDIF
         mamount := 0
         SELECT Credit
          ApFLock( 3 )
         APPEND BLANK
         Credit->Codeno  := mcodeno
         Credit->Invdate := DATE()
         Credit->DueDate := DATE()+30
         Credit->Stat    := "N"
         UNLOCK
         mcorrect := "N"
         DO WHILE mcorrect == "N"
            SCROLL(  2, 0, 24,80 )
            DISPBOX( 2, 1, 20,79, 2 )
            SELECT Credit
             ApRLock( 3 )
            @  4,11      SAY "Invoice"     GET Credit->Invno   PICTURE "@K"
            @  4,COL()+2 SAY "Dated"       GET Credit->Invdate PICTURE "99/99/9999"
            @  4,COL()+2 SAY "Due Date"    GET Credit->Duedate PICTURE "99/99/9999"
            @  6,10      SAY "AutoPay A/N" GET Credit->Stat;
                                  VALID( Credit->Stat $ "AN" ) PICTURE "@!"
            @  6,COL()+2 SAY "Cash Book :" GET mcashno         PICTURE "@!"
             READ
            IF Credit->Stat = "A"
               Credit->Cheqno := "AP "+SUBSTR( Credit->Codeno,1,4 ) 
            ENDIF
            UNLOCK
            IF LASTKEY() = 27
               RETURN NIL
            ENDIF
            SELECT Cashbook
            SEEK mcashno
            IF !FOUND()

               Cblook( @mcashno )                   // XLF_Acc.PRG

            ENDIF
            SELECT Credit
            @  8,10 SAY "Cash Book # "+Cashbook->Cashno+" "+Cashbook->Cbname;
                         +" GST % "+STR( Cashbook->GstAmnt )
            @ 10,10 SAY "Amount :" GET mamount PICTURE "99999.99"
             READ
             ApRLock( 3 )
            IF CashBook->GstAmnt > 0
               Credit->Tax := mamount-( mamount/((CashBook->GstAmnt/100)+1) )
             ELSE
               Credit->Tax := 0
               @ 12,52 SAY mamount-( mamount/((CashBook->GstAmnt/100)+1) ) PICTURE "99999.99"
             ENDIF
            @ 10,38 SAY "G.S.T Amount :" GET Credit->Tax PICTURE "99999.99"
             READ
            mcorrect := ApGetY( Message->Correct )
            IF PressedEsc()
               RETURN NIL
            ENDIF
         ENDDO
         IF mcorrect = "Y"
            Credit->Initamnt := mamount
            Credit->Cashno   := mcashno
            Credit->Amount   := mamount
            UNLOCK
            SELECT Name
             ApRLock( 3 )
            Name->Cashno := Credit->Cashno
            UNLOCK
            SELECT CredProf
             ApFLock( 3 )
            APPEND BLANK
            CredProf->Codeno   := Credit->Codeno
            CredProf->Invdate  := Credit->InvDate
            CredProf->DueDate  := Credit->DueDate
            CredProf->Stat     := Credit->Stat
            CredProf->Initamnt := Credit->Initamnt
            CredProf->Cashno   := Credit->Cashno
            CredProf->Amount   := Credit->Amount
            CredProf->Tax      := Credit->Tax
            CredProf->Invno    := Credit->Invno
            UNLOCK
            @ 12,11      SAY "Credit Profile entered"   COLOR "G+"
            @ 14,11      SAY "Invoice "+CredProf->Invno COLOR "G+"
            @ 14,COL()+2 SAY "Dated"
            @ 14,COL()+2 SAY CredProf->Invdate PICTURE "99/99/9999"
            @ 14,COL()+2 SAY "Due Date"
            @ 14,COL()+2 SAY CredProf->Duedate PICTURE "99/99/9999"
            @ 16,11      SAY "AutoPay "+CredProf->Stat 
            @ 16,COL()+2 SAY "Cash Book "+CredProf->Cashno 
            @ 18,11      SAY "Amount"
            @ 18,COL()+2 SAY CredProf->Amount PICTURE "$99999.99"
            @ 18,COL()+4 SAY "G.S.T Amount"
            @ 18,COL()+2 SAY CredProf->Tax PICTURE "$99999.99"
            SELECT Credit
         ENDIF                             // mcorrect
         nselect := 1
         DISPBOX( 22, 1, 24,79, 2 )
         @ 23, 6      PROMPT "More Credit This Name"
         @ 23,COL()+2 PROMPT "Another Name  Credit "
         MENU TO nselect
         DO CASE
            CASE PressedEsc()
               RETURN NIL
            CASE nselect == 1
               mok := "Y"
               LOOP
            CASE nselect == 2
              EXIT 
         ENDCASE
      ENDDO                                 // mok
      mcontinue := "Y"
   ENDDO                                   // mcontinue

   RETURN NIL
   ****----  End of CredAdd()

   **---------------------------------------------------------------------*

FUNCTION MenuDep( nc, ncl )

   DO WHILE .T.

      nselect  := 0
      nc       := ncl*2
      SCROLL( 3,nc, 21,78 )
      DISPBOX( 4,nc, 21,nc+ncl )
      SCROLL(  3,nc+4, 5,nc+( ncl-4 ) )
      DISPBOX( 3,nc+4, 5,nc+( ncl-4 ) )
      @  4,nc+( ncl/2 )-( LEN( RTRIM( Menu->CH_Dephd ) )/2 );
                         SAY RTRIM( Menu->CH_Dephd )
      @  7,nc+2 PROMPT Menu->CH_Dep1
      @  9,nc+2 PROMPT Menu->CH_Dep2
      @ 10,nc+2 PROMPT Menu->CH_Dep3
      @ 12,nc+2 PROMPT Menu->CH_Dep4
      @ 13,nc+2 PROMPT "5. Deposit/Receipts   "
      @ 15,nc+2 PROMPT "6. Wage Input         "
      @ 16,nc+2 PROMPT "7. Paye Return TaxEdit"
      @ 18,nc+2 PROMPT "8. JC/Salary   History"
      @ 19,nc+2 PROMPT "9. Staff Indiv   Analy"
      @ 20,nc+2 PROMPT Menu->CH_Main
      nc := ncl
      MENU TO nselect

      DO CASE
         CASE nselect == 10 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 1
            SAVE SCREEN TO holdscrn
            Depadd()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
            Depview()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
            Deplist()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
            SbookLst()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
            DepnoList()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO Invscrn
            MetTime()                             // PmpTime.PRG
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 7
            SAVE SCREEN TO Invscrn
            MetPaye()
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 8
            SAVE SCREEN TO Invscrn
            HistLab()                             // PmpTime1 
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 9
            SAVE SCREEN TO Invscrn
            StaffJCSal()                         // PmpTime2 
            RESTORE SCREEN FROM Invscrn
      ENDCASE
   ENDDO

   RETURN NIL

   ***** End of MenuDep()

   **---------------------------------------------------------------------*

STATIC FUNCTION DepnoList()

   SCROLL()
   SELECT Rec
   GOTO TOP 
   SET ORDER TO 2
   SELECT Deposit
   GOTO TOP 
   SET ORDER TO 3
   SCROLL()
   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      SELECT Deposit
      SCROLL()
      cheading := "List Deposits and Receipts"
      DISPBOX( 0, 1, 2,79, 2 )
      @  1,40-( LEN( cheading )/2 ) SAY cheading
      DISPBOX( 3, 1, 19,79, 2 )
      mdetail := "Y"                     // Required By Heading
      mselect := "M"
      @  6,12 SAY "All Deposits or Month only A/M :" GET mselect PICTURE "!"
       READ
      dmm := SUBSTR( DTOS( DATE()),5,2 )
      dyy := SUBSTR( DTOS( DATE()),1,4 )
      IF mselect = "M"
         @ 10,20 SAY "Select Month :" GET dmm PICTURE "99"
         @ 10,COL()+3 SAY "Year :" GET dyy PICTURE "9999"
          READ
         IF PressedEsc()
            SELECT Rec
            SET INDEX TO RecInd
            SELECT Deposit
            SET INDEX TO DepInd
            RETURN NIL
         ENDIF
      ENDIF
      dyymm  := dyy+dmm
      mwhere := "S"
      npl    := 56
      Printsel()                                      //  _LF_Init

      SCROLL()
      @  0, 0 SAY TRIM( Control->U_Name )+" Deposit/Receipts" 
      @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
      nl := 2
      SELECT Deposit
      GOTO TOP
      crecno := SPACE( 6 )
      mamount:= nrecno := 0
      DO WHILE Deposit->( !EOF() )
         IF mselect = "M"
            IF SUBSTR( DTOS( Deposit->Depdate ),1, 6 ) != dyymm
               SKIP ALIAS Deposit
               LOOP
            ENDIF
         ENDIF                     // mselect
         IF nl > npl
            IF mwhere == "P"
               EJECT
               @  0, 0 SAY TRIM( Control->U_Name )+" Deposit/Receipts" 
               @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                          +STR( YEAR(DATE() ),5 )
            ELSE
               WAIT
               SCROLL()
            ENDIF
            nl := 2
         ENDIF
         IF Deposit->Depref != crecno
            IF crecno != SPACE( 6 )
               @ nl,68 SAY nrecno          PICTURE "999,999.99" 
               SELECT Rec
               SET EXACT OFF
               GOTO TOP
               SEEK TRIM( crecno )
               ndeprec := 0
               DO WHILE TRIM( Rec->Recno ) = TRIM( crecno ) .AND. Rec->( !EOF() )
                  IF mselect = "M"
                     IF SUBSTR( DTOS( Rec->Recdate ),1, 6 ) != dyymm
                        SKIP ALIAS Rec
                        LOOP
                     ENDIF
                  ENDIF                     // mselect
                  SELECT Name
                  SEEK Rec->Codeno
                  SELECT Rec
                  nl++
                  @ nl, 3 SAY SUBSTR( Name->Name,1,17 )
                  @ nl,22 SAY Rec->Saleno
                  @ nl,27 SAY Rec->RecDate 
                  @ nl,38 SAY Rec->Invno
                  @ nl,46 SAY Rec->Jobno 
                  @ nl,53 SAY Rec->RecAmnt PICTURE "999,999.99"
                  ndeprec += Rec->RecAmnt
                  SKIP ALIAS Rec
               ENDDO
               IF ndeprec > 0
                  @ nl,63 SAY ndeprec PICTURE "999,999.99" 
               ENDIF                   // Receipt Found
            ENDIF                      // SPACE
            nrecno := 0 
            SELECT Deposit
            crecno := Deposit->Depref
         ENDIF                                // Recno  
         nl++
         @ nl, 0 SAY Deposit->Depref
         @ nl,14 SAY Deposit->Depdate
         @ nl,25 SAY Deposit->Saleno 
         @ nl,30 SAY Deposit->Amount PICTURE "999,999.99"
         IF Deposit->Depref != SPACE( 6 )
            nrecno += Deposit->Amount
         ENDIF
         mamount += Deposit->Amount
         SKIP ALIAS Deposit
      ENDDO
      @ nl,68 SAY nrecno          PICTURE "999,999.99" 
      SELECT Rec
      SEEK TRIM( crecno )
      ndeprec := 0
      DO WHILE TRIM( Rec->Recno ) = TRIM( crecno ) .AND. Rec->( !EOF() )
         IF mselect = "M"
            IF SUBSTR( DTOS( Rec->Recdate ),1, 6 ) != dyymm
               SKIP ALIAS Rec
               LOOP
            ENDIF
         ENDIF                     // mselect
         SELECT Name
         SEEK Rec->Codeno
         SELECT Rec
         nl++
         @ nl, 3 SAY SUBSTR( Name->Name,1,18 )
         @ nl,22 SAY Rec->Saleno
         @ nl,27 SAY Rec->RecDate 
         @ nl,38 SAY Rec->Invno
         @ nl,46 SAY Rec->Jobno 
         @ nl,53 SAY Rec->RecAmnt PICTURE "999,999.99"
         ndeprec += Rec->RecAmnt
         SKIP ALIAS Rec
      ENDDO
      IF ndeprec > 0
         @ nl,63 SAY ndeprec PICTURE "999,999.99" 
      ENDIF                   // Receipt Found
      nl++
      @  nl,68 SAY "------------"
      nl++
      @ nl,48 SAY "Grand Total ="
      @ nl,66 SAY mamount PICTURE "$9999,999.99"
      nl++
      IF mwhere == "P"
         EndPrint()
      ELSE
         WAIT
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
      ENDIF
      mcontinue := ApGetN( Message->Another )

   ENDDO                               // mcontinue
   SELECT Rec
   SET ORDER TO 1
   SELECT Deposit
   SET ORDER TO 1

   RETURN NIL

   ******------------ End of file Depnolist

   ***---------------------------------------------------------------------*

FUNCTION Depadd()

   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
   cheading  := "Add New Deposit"
   @  1,40 -( LEN(cheading)/2 ) SAY cheading
   SELECT Deposit
   GOTO LASTREC()
   mdepref := Deposit->DepRef
   mdepdate  := DATE()
   msaleno   := Control->Saleno
   mcontinue := "Y"
   DO WHILE mcontinue == "Y"

       DepRev()                           // Below Shows last 8 entries

      SELECT Deposit
       ApFLock( 3 ) 
      APPEND BLANK
      Deposit->DepDate := mdepdate
      Deposit->Saleno  := msaleno
      Deposit->Depref  := mdepref
      UNLOCK   
      mok := "N"
      DO WHILE mok == "N"

          Deposit( msaleno )                            // Below

         mdepdate := Deposit->DepDate
         mdepref  := Deposit->DepRef
         msaleno  := Deposit->Saleno
         SCROLL( 13, 0, 28,80 )
         mok := ApGetY( Message->Correct )
         IF PressedEsc()
            SELECT Deposit
             ApRLock( 3 )
            DELETE
            UNLOCK
            RETURN NIL
         ENDIF
      ENDDO
      mcontinue := ApGetY( Message->Another+"Deposit" )
      IF LASTKEY() = 27
         RETURN NIL
      ENDIF
   ENDDO

   RETURN NIL

   *** End of file DepAdd()

   ***---------------------------------------------------------------------*

FUNCTION Depview()

   cheading  := "View  Existing  Deposits"
   mcontinue := mok := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL()
      DISPBOX(  0, 1, 2,79, 2 )
      @  1,40-( LEN(cheading)/2 ) SAY cheading
      dmm := SUBSTR( DTOS( DATE()),5,2 )
      @ 12,20 SAY "Select Month :" GET dmm PICTURE "99"
      dyy := SUBSTR( DTOS( DATE()),1,4 )
      @ 12,COL()+4 SAY "Year :" GET dyy PICTURE "9999"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      SCROLL( 3, 0, 24,80 )
      ntotal:= nrecno :=  0
      dyymm := dyy+dmm
      aPart_ := {}
      SELECT Deposit
      SET ORDER TO 1
      IF LASTREC() != 0
         GOTO TOP
         DO WHILE  Deposit->( !EOF() )
            IF SUBSTR( DTOS( Deposit->Depdate ),1,6 ) != dyymm
               SKIP ALIAS Deposit
               LOOP
            ENDIF
            ntotal += Deposit->Amount
            AADD( aPart_,(DTOC( Deposit->DepDate );
                         +"  "+Deposit->DepRef+"  "+STR( Deposit->Amount );
                         +"  "+Deposit->Saleno+"  "+STR( Deposit->GstAmnt );
                         +"     "+STR( RECNO() ) ) )
            SKIP ALIAS Deposit
         ENDDO
         @  1, 56 SAY ntotal PICTURE "$999,999.99" COLOR "G+"
         DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            anum   := ACHOICE( 4,10,23,63, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
          ELSE
            @ 14,20 SAY "--- No Deposits This Month ---"
            INKEY( 2 )
            LOOP
         ENDIF
         GOTO nrecno
      ENDIF
      SCROLL(  3, 0, 24,80 )
      DISPBOX( 3, 1, 9,79, 2 )
      nl := 4
      SELECT Deposit
      @  nl,10      SAY "Deposit Date "+DTOC( Deposit->Depdate )
      @  nl,COL()+4 SAY "Reference "+Deposit->Depref
      nl+=2
      @ nl,15 SAY "Salebook :"+Deposit->Saleno
      nl+=2
      @ nl,16 SAY "Amount :"+STR( Deposit->Amount )
      @ nl,40 SAY "G.S.T. :"+STR( Deposit->Gstamnt )
       cstring := TRIM( Message->Delete )
       mok := ApCheck( cstring )                        // AppX.PRG
       IF PressedEsc()
          RETURN NIL
       ENDIF
      ***    IF mok == "Y"
      ***       cstring := TRIM( Message->Suredel )
      ***       mok := ApCheck( cstring )                     // AppX.PRG
      ***       IF PressedEsc()
      ***          RETURN NIL
      ***       ENDIF
      ***    ENDIF
       IF mok == "Y"
          SELECT Deposit
           ApRLock( 3 )
          DELETE
          UNLOCK
          LOOP  
       ENDIF
       msaleno := Deposit->Saleno 

        Deposit( msaleno )                    // Below

       mcontinue := ApGetN( TRIM( Message->Another )+" Deposit " )
       IF PressedEsc()
          RETURN NIL
       ENDIF
   ENDDO

   RETURN NIL

   ***---- End of DepView()

   **---------------------------------------------------------------------*

STATIC FUNCTION Deposit( msaleno )

   SCROLL(  3, 0,11,80 )
   DISPBOX( 3, 1,11,79, 2 )
   nl  := 4
   nsl := 11
   SELECT Deposit
   SET ORDER TO 1
    ApRLock( 3 )
   @ nl, 3      SAY "Deposit Date" GET Deposit->Depdate PICTURE "99/99/9999"
   @ nl,COL()+2 SAY "Reference"    GET Deposit->Depref  PICTURE "@x"
   ***   @ nl,COL()+1 SAY "Direct Credit Use Codeno" 
    READ
   UNLOCK 
   IF PressedEsc()
      RETURN NIL
   ENDIF
     IF Deposit->Depref != SPACE( 6 )
            nsl := 12
            SELECT Rec
            SET ORDER TO 2          // Recno
            SET EXACT OFF
            GOTO TOP
            SEEK SUBSTR( Deposit->Depref, 1, 6 )
            ndeprec := 0
            nt      := 0
            DO WHILE Rec->( !EOF() )
               IF Rec->RecDate < DATE()-30
                  SKIP ALIAS Rec
                  LOOP
               ENDIF 
               IF Rec->Saleno != msaleno
                  SKIP ALIAS Rec
                  LOOP
               ENDIF 
               IF Rec->Recno != SUBSTR( Deposit->Depref, 1, 6 )
                  EXIT
               ENDIF
               IF nsl > 23
                  nt++
                  IF nt > 4
                     EXIT
                  ENDIF
                  WAIT
                  SCROLL( 11, 0, 24,80 )
                  nsl := 11
               ENDIF
               SELECT Name
               SEEK Rec->Codeno
               SELECT Rec
               @ nsl, 0 SAY SUBSTR( Name->Name,1,20 )
               @ nsl,22 SAY Rec->Saleno
               @ nsl,27 SAY Rec->RecDate 
               @ nsl,38 SAY Rec->Invno
               @ nsl,46 SAY Rec->Recno
               @ nsl,53 SAY Rec->RecAmnt PICTURE "999,999.99"
               @ nsl,64 SAY Rec->Jobno
               nsl++
               ndeprec += Rec->RecAmnt
               SKIP ALIAS Rec
            ENDDO
            IF nt < 5
               IF ndeprec > 0
                  @ nsl,65 SAY ndeprec PICTURE "999,999.99" COLOR "BG+" 
               ENDIF                   // Receipt Found
            ENDIF
         SELECT Deposit
         nsl++
         SELECT Rec
         SET ORDER TO 1
      ENDIF                                // Depref  
      SELECT Deposit
   nl+=2
   IF Deposit->Saleno == SPACE(4)
      SCROLL( 15, 0, 24,80 )

       SbLook( @msaleno )                  // XLF_ACC

     ELSE
      SELECT Deposit
       ApRLock( 3 )   
      @ nl,10 SAY "     Salebook :  " GET Deposit->Saleno PICTURE "@K!"
       READ
      msaleno := Deposit->Saleno
      UNLOCK
      SELECT SaleBook
      SEEK msaleno
      IF !FOUND()
         SCROLL( 15, 0, 24,80 )
         SbLook( @msaleno )                // XLF_Acc
      ENDIF
   ENDIF
   @ nl,10 SAY "Sale Book #  "+SaleBook->Saleno+"  "+Salebook->Sbname
   IF SaleBook->GstAmnt > 0
      @ nl,COL()+2 SAY "GST"
      @ nl,COL()+2 SAY SaleBook->GstAmnt
   ENDIF
   nl+=2
   SELECT Deposit
    ApRLock( 3 ) 
   @  nl,16 SAY "Amount" GET Deposit->Amount PICTURE "9999999.99"
    READ
   IF PressedEsc()
      UNLOCK
      RETURN NIL
   ENDIF
   DO WHILE Deposit->Amount = 0
       @  nl,10 SAY "Enter Amount" GET Deposit->Amount PICTURE "9999999.99"
        READ
       IF PressedEsc()
          UNLOCK
          RETURN NIL
       ENDIF
   ENDDO                                    // Deposit
   IF SaleBook->GstAmnt > 0
      Deposit->Gstamnt := Deposit->Amount-( Deposit->Amount/((SaleBook->GSTAmnt/100)+1) )
     ELSE
      Deposit->Gstamnt := 0
   ENDIF
   @ nl,40 SAY "Check G.S.T. " GET Deposit->Gstamnt PICTURE "999999.99"
   IF SaleBook->GstAmnt = 0
      nl++
      @ nl, 3 SAY SPACE( 70 )
      @ nl,20 SAY Deposit->Amount-( Deposit->Amount/((Control->GstRate/100)+1) );
                  PICTURE "$99,999.99"
      @ nl,33 SAY " No Gst this entry"
   ENDIF
    READ
   IF PressedEsc()
      UNLOCK
      RETURN NIL
   ENDIF
   Deposit->Saleno := SaleBook->Saleno
   UNLOCK
   RETURN NIL
   ***------ End of Deposit()

   **---------------------------------------------------------------------*

STATIC FUNCTION DepRev()

   SCROLL(  12, 0, 24,80 )
   cheading := " --- Latest Deposits --- "
   @ 12,40 -( LEN(cheading)/2 ) SAY cheading
   nl := 13
   SELECT Deposit
   SET ORDER TO 1
   IF LASTREC() > 8
      GOTO LASTREC()-8
     ELSE
      GOTO TOP
   ENDIF
   DO WHILE Deposit->( !EOF() )
      @ nl, 8 SAY Deposit->Depdate
      @ nl,20 SAY Deposit->Saleno
      @ nl,26 SAY Deposit->Depref
      @ nl,44 SAY Deposit->Amount  PICTURE "$9,999,999.99"
      @ nl,61 SAY Deposit->GstAmnt PICTURE "$999,999.99"
      nl++
      SKIP ALIAS Deposit
   ENDDO                        // Deposit EOF()
   *** SET ORDER TO 1

   RETURN NIL

   *****---- End of DepRev()

   **-------------------------------------------------------------------

STATIC FUNCTION Deplist()

   mok := "Y"
   nfbtax:= nbnkopen:= ncalc:= ncredit:= 0
   SCROLL()
   mstmm:= mendmm:= SUBSTR(DTOS(DATE()),5,2)
   mstyy:= mendyy:= SUBSTR(DTOS(DATE()),1,4)
   msaleno := SPACE(4)
   DISPBOX( 0, 1, 2,79, 2 )
   @  1,40-( LEN(Control->U_Name)/2 ) SAY Control->U_Name
   DISPBOX( 4, 1, 12,79, 2 )
   @  6,10 SAY "     Period From Month "  GET mstmm   PICTURE "99"
   @  6,COL()+2 SAY "Year "           GET mstyy   PICTURE "9999"
   @  8,10 SAY "              To Month "  GET mendmm  PICTURE "99"
   @  8,COL()+2 SAY "Year "           GET mendyy  PICTURE "9999"
   mpertax := 0
   @ 10,10 SAY "Blank for all Sales Codes :" GET msaleno PICTURE "@K!"
    READ
   IF msaleno != SPACE(4) 
      SELECT SaleBook
      SEEK msaleno
      IF !FOUND()
         SCROLL( 13, 0, 24,80 )

            SbLook( @msaleno )                // XLF_Acc

      ENDIF                                   // Found()
   ENDIF                                      // msaleno  
   
   mwhere := "S"

   Printsel( mwhere )

      IF mwhere == "S"
         npl    := 22
         SCROLL()
       ELSE
         npl    := 56
         @ 0, 0
         SET DEVICE TO PRINT
      ENDIF
      nl    := 1
      mst   := mstyy+mstmm
      mend  := mendyy+mendmm
      mgstot:= mgutot:= mgsttot:= mggsttot:= 0
      @ nl, 0 SAY "DEPOSIT LIST   "+Control->U_Name
      nl+=2
      @ nl, 0 SAY "DATE               SALES          GST            OTHERS   SA  REFERENCE"
      nl+=2
      SELECT Deposit
      SET ORDER TO 1
      GOTO TOP
      DO WHILE Deposit->( !EOF() ) 
         IF SUBSTR( DTOS(Deposit->Depdate),1,6 ) < mst
            SKIP ALIAS Deposit
            LOOP
         ENDIF 
         IF SUBSTR( DTOS(Deposit->Depdate),1,6 ) > mend 
            EXIT
         ENDIF
         IF msaleno != SPACE(4)
            IF Deposit->Saleno != msaleno
               SKIP ALIAS Deposit
               LOOP
            ENDIF
         ENDIF                                      // msaleno  
         IF nl > npl
            nl := 2
            IF mwhere == "P"
               EJECT
             ELSE
              WAIT
              SCROLL()
            ENDIF
            @ nl, 0 SAY "DEPOSIT LIST   "+Control->U_Name
            nl+=2
            @ nl, 0 SAY "DATE               SALES          GST            OTHERS   SA  REFERENCE"
            nl+=2
         ENDIF
         @ nl, 0 SAY Deposit->Depdate
         IF Deposit->GstAmnt > 0
            @ nl,14 SAY Deposit->Amount  PICTURE "9,999,999.99"
            @ nl,30 SAY Deposit->Gstamnt PICTURE "9,999,999.99"
            mgstot  += Deposit->Amount
            mgsttot += Deposit->Gstamnt
          ELSE
            @ nl,44 SAY Deposit->Amount PICTURE "9,999,999.99"
            mgutot += Deposit->Amount
         ENDIF
         @ nl,60 SAY Deposit->Saleno
         @ nl,66 SAY Deposit->Depref
         nl++
         SKIP ALIAS Deposit
    ENDDO                                   // Deposit EOF()
    mdeptot := mgstot+mgutot
    IF mwhere = "S"
       IF nl > 23
          WAIT
          SCROLL()
          nl := 10
       ENDIF
    ENDIF
    nl++
    @ nl, 0 SAY "SALES INCL GST"
    @ nl,17 SAY mgstot  PICTURE "9,999,999.99"
    @ nl,32 SAY mgsttot PICTURE "9,999,999.99"
    @ nl,50 SAY mgutot  PICTURE "9,999,999.99"
    nl+=2
    @ nl, 0 SAY "SALES EXCL G.S.T"
    @ nl,17 SAY mgstot-mgsttot PICTURE "9,999,999.99"
    @ nl,32 SAY "TOTAL DEPOSITS"
    @ nl,50 SAY mgstot+mgutot PICTURE "9,999,999.99"
    nl+=2
    IF mwhere = "S"
       WAIT
       mok := "N"
       DO WHILE mok = "N"
          mok := ApReadN()
       ENDDO
       SCROLL()
      ELSE
       EndPrint()
    ENDIF

   RETURN NIL

   **** End Deplist()

   **-------------------------------------------------------------------

   STATIC FUNCTION SbookLst()

   SELECT Deposit
   SET ORDER TO 2

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      nmonth := 0
      mmamntmnth:= mmamount:= mmamntlyr:= mtotmnth:= mtotamnt:= mtotlyr:= 0
      nmonthtot:= mmm:= myy:= mvalyy:= mvalmm:= 0
      SCROLL()
      DISPBOX( 3, 1, 12,79, 2 )
      @  4, 5 SAY "Please Provide Month & Year"
      msys := SUBSTR( DTOC( DATE() ),4,7 )
      @  6, 5 SAY "Month & Year MM/YYYY" GET msys PICTURE "99/9999"
       READ
      mmm    := SUBSTR( msys,1,2 )
      myy    := SUBSTR( msys,4,4 )
      mvalmm := VAL( mmm )
      mvalyy := VAL( myy )
      msameyr := "F"
      IF mvalmm < 4
         msameyr := "S"
      ENDIF
      mwhere := "S"
      npl    := 54

       Printsel( mwhere, npl )
     
      IF mwhere = "P"
         npl := 54
        ELSE
         npl := 18
      ENDIF
   *   @  1, 0 SAY CHR(27)+CHR(33)+CHR(14)+CHR(27)+CHR(71)+"Deposits To Month =  "+msys+CHR(20)+CHR(27)+CHR(99)+CHR(49)
   *   @  1,105 SAY CHR(27)+CHR(33)+mdate
       @  1, 0 SAY "DEPOSITS  "+Control->U_Name+"   "+msys
       @  1,56 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
   * EPSOM
   *   @  1, 0 SAY CHR(27)+CHR(120)+CHR(49)+CHR(14)+"Deposits To Month =  "+msys+CHR(20)
   *   @  1,61 SAY mdate
      @  3, 0 SAY "SALE"
      @  3, 6 SAY "NAME"
      @  3,42 SAY "MONTH"
      @  3,58 SAY "YEAR"
      @  3,69 SAY "LAST YEAR"
   *   @  3,69 SAY "LAST YEAR"+CHR(27)+CHR(34)
   *   @  3,69 SAY "LAST YEAR"+CHR(27)+CHR(120)+CHR(48)
      nl := 5
      nsum:= namount:= nsubyy:= nsublyr:= 0
      SELECT SaleBook
      GOTO TOP
      DO WHILE Salebook->( !EOF() )
         IF SUBSTR( SaleBook->Saleno,3,2  ) == "AA"
            IF nsum != 0
               @ nl,33 SAY "-------------"
               @ nl,50 SAY "-------------"
               @ nl,63 SAY "-------------"
               nl++
               @ nl,25 SAY "Total :"
               @ nl,33 SAY namount  PICTURE "$9,999,999.99"
               @ nl,50 SAY nsubyy   PICTURE "9,999,999.99"
               @ nl,63 SAY nsublyr  PICTURE "9,999,999.99"
               nl++
            ENDIF
            @ nl,10 SAY SaleBook->Sbname
            nl++
            SKIP ALIAS SaleBook
            nsum:= namount:= nsubyy:= nsublyr:= 0
            LOOP
         ENDIF 
         nmonth := 0
         IF nl > npl
           IF mwhere = "P"
             EJECT
            ELSE
             WAIT
             SCROLL()
          ENDIF
   *   @  1, 0 SAY CHR(27)+CHR(33)+CHR(14)+CHR(27)+CHR(71)+"Deposits To Month =  "+msys+CHR(20)+CHR(27)+CHR(99)+CHR(49)
   *   @  1,105 SAY CHR(27)+CHR(33)+mdate
      @  1, 0 SAY "DEPOSITS  "+Control->U_Name+"  "+msys
      @  1,56 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
   * EPSOM
   *   @  1, 0 SAY CHR(27)+CHR(120)+CHR(49)+CHR(14)+"Deposits To Month =  "+msys+CHR(20)
   *   @  1,61 SAY mdate
      @  3, 0 SAY "SALE"
      @  3, 6 SAY "NAME"
      @  3,42 SAY "MONTH"
      @  3,58 SAY "YEAR"
      @  3,69 SAY "LAST YEAR"
   *   @  3,69 SAY "LAST YEAR"+CHR(27)+CHR(34)
   *   @  3,69 SAY "LAST YEAR"+CHR(27)+CHR(120)+CHR(48)
           nl := 5
         ENDIF
         @ nl, 0 SAY SaleBook->Saleno
         @ nl, 6 SAY SaleBook->Sbname
         msaleno := SaleBook->Saleno
         SELECT Deposit
         STORE "  " TO mmnth
         SEEK msaleno
         DO WHILE Deposit->Saleno == msaleno .AND. Deposit->( !EOF() )
            mamntmnth:= mamount:= mamntlyr:= mmonth:= 0
            mrecyy  := SUBSTR( DTOC( Depdate ),7,4 )
            mvrecyy := VAL(mrecyy)
            mrecmm  := SUBSTR( DTOC( Depdate ),4,2 )
            mvrecmm := VAL( mrecmm )
         DO CASE
               CASE mvrecyy = mvalyy
               DO CASE
                   CASE mvrecmm = mvalmm
                   STORE Gstamnt TO mamntmnth
                    STORE Deposit->Amount TO mmonth
                    namount := namount+Deposit->Amount
                   CASE mvrecmm < 4
                    IF msameyr = "S"
                       IF mvrecmm < mvalmm
                         STORE Gstamnt TO mamntmnth
                         STORE Amount TO mamount
                       ENDIF
                      ELSE
                       STORE Amount TO mamntlyr
                    ENDIF
                   CASE mvrecmm > 3
                       IF mvrecmm < mvalmm
                          STORE Gstamnt TO mamntmnth
                           STORE Amount TO mamount
                        ENDIF
                     ENDCASE
                 CASE mvrecyy = ( mvalyy - 1 )
                   DO CASE
                      CASE mvrecmm > 3
                        IF msameyr = "S"
                           STORE Gstamnt TO mamntmnth
                           STORE Amount TO mamount
                         ELSE
                           STORE Amount TO mamntlyr
                        ENDIF
                     CASE mvrecmm < 4
                        IF msameyr = "S"
                           STORE Amount TO mamntlyr
                        ENDIF
                 ENDCASE
                   CASE mvrecyy = ( mvalyy - 2 )
                       IF msameyr = "S"
                          IF mvrecmm > 3
                             STORE Amount TO mamntlyr
                          ENDIF
                       ENDIF
                    ENDCASE
                    nmonth     += mmonth
                    mmamount   += mmonth
                    mmamntmnth += mmamntmnth
                    mmamount   += mamount
                    mmamntlyr  += mamntlyr
                    SKIP ALIAS Deposit
                 ENDDO
         @ nl,35 SAY nmonth    PICTURE "9,999,999.99"
      ***      @ nl,37 SAY mmamntmnth PICTURE "9999999.99"
         @ nl,50 SAY mmamount  PICTURE "9,999,999.99"
         @ nl,63 SAY mmamntlyr PICTURE "9,999,999.99"
         nl++
         nmonthtot += nmonth
         nsubyy    += mmamount
         nsublyr   += mmamntlyr
         nsum := namount+nsubyy+nsublyr
         mtotmnth += mmamntmnth
         mtotamnt += mmamount
         mtotlyr  += mmamntlyr
         STORE 0 TO mmamntmnth, mmamount, mmamntlyr
         SELECT Salebook
         SKIP ALIAS Salebook
      ENDDO
       IF mwhere = "S"
          IF nl > 23
             WAIT
             SCROLL()
             nl := 10
          ENDIF
       ENDIF
   *   @ nl,36 SAY CHR(27)+CHR(33)+"-----------    -----------     -----------"
      IF nsum != 0
         @ nl,35 SAY "------------"
         @ nl,50 SAY "------------"
         @ nl,63 SAY "------------"
         nl++
         @ nl,25 SAY "Total :"
         @ nl,34 SAY namount  PICTURE "$9,999,999.99"
         @ nl,50 SAY nsubyy   PICTURE  "9,999,999.99"
         @ nl,63 SAY nsublyr  PICTURE  "9,999,999.99"
         nl+=2
      ENDIF
      ***   @ nl,37 SAY mtotmnth PICTURE "999,999.99"
      @ nl,19 SAY "Grand Totals"
      @ nl,34 SAY nmonthtot   PICTURE "$9,999,999.99"
      @ nl,50 SAY mtotamnt    PICTURE  "9,999,999.99"
      @ nl,63 SAY mtotlyr     PICTURE  "9,999,999.99"
      nl++
   *   @ nl,36 SAY "===========    ===========     ==========="+CHR(27)+CHR(34)
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
      SCROLL()
       mcontinue = "N"
   ENDDO
   SELECT Deposit
   SET ORDER TO 1

   RETURN NIL

   ***---- End SBookLst()

   *********--------------  END OF FILE XLF_DEP.PRG

