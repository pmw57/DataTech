   *** JoKir10   12-10-11 11:29:44 

/*
   Program.....:                  XLF_REC.PRG
   Authors.....: J.Kirby
   Date........: 11/03/1995
   Functions...: Mu_Rec, ReceHead
   Static funcs: RecAdd, DebRecLst,  DebRecHd, RecnoList
                 RecView, RecnoView, RecList, RecHead
*/

STATIC FUNCTION RecAdd()

   mcontinue:= mok := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL()
      DISPBOX( 0,52, 2,79, 2 )
      @  1,55 SAY "Select Receipt"
      DISPBOX( 8,10,14,28, 2 )
      nselect := 1
      @ 10,12 PROMPT "Debit  Listing"
      @ 12,12 PROMPT "Select by Name"
      MENU TO nselect
      DO CASE
         CASE PressedEsc()
            RETURN NIL
         CASE nselect == 2
            mcodeno := SPACE( 8 )
            Namerank( @mcodeno )                          // XLF_Name
            IF PressedEsc() 
               RETURN NIL
            ENDIF
            SELECT Name
            mcodeno := Name->Codeno
         CASE nselect == 1
            SCROLL(  0, 0, 24,45 )
            mtemp := SPACE( 8 )
            nrecno   := 0
            aPart_   := {}
            SELECT Debit
            GOTO TOP
            IF LASTREC() != 0
               DO WHILE Debit->( !EOF() )
                   IF Debit->Stat != "I"
                      SKIP ALIAS Debit
                      LOOP
                   ENDIF
                   IF Debit->Codeno = mtemp
                      SKIP ALIAS Debit
                      LOOP
                   ENDIF
                   SELECT Name
                   SEEK Debit->Codeno
                   SELECT Debit
                   mtemp := Debit->Codeno
                   AADD( aPart_,Name->Name+"  "+Debit->BranchId;
                       +"       "+STR( RECNO(),6 ) )
                   SKIP ALIAS Debit
               ENDDO                          // EOF()
               DISPBOX( 0, 1, 24,45, 2 )
               IF !EMPTY( aPart_ )
                  ***         ASORT( aPart_,,,{ | x,y | x < y } )
                  anum   := ACHOICE( 1, 3, 23,41, aPart_,,"AFUNC" )    
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  IF PressedEsc() 
                     RETURN NIL
                  ENDIF
               ENDIF
               GOTO nrecno
               mcodeno := Debit->Codeno
               SELECT Name
               SEEK mcodeno
               SCROLL()
               DISPBOX( 0, 1, 2,79, 2 )
               @  1,10 SAY Name->Name
            ELSE
               mok := "N"
            ENDIF                        // LastRec
            IF mok = "N"
               mcodeno := SPACE( 8 )
                Namerank( @mcodeno )                          // XLF_Name
               IF PressedEsc() 
                  RETURN NIL
               ENDIF
               SELECT Name
               mcodeno := Name->Codeno
            ENDIF
      ENDCASE
      aPart_ := {}
      namnt := 0
      SELECT Debit
      SET ORDER TO 2               // Codeno
      GOTO TOP
      SCROLL(  3, 0, 24,80 )
      nnum := 0
      ***   SEEK mcodeno
      nl := 3
      ***   DO WHILE Debit->Codeno = mcodeno .AND. Debit->( !EOF() )
      DO WHILE Debit->( !EOF() )
         IF Debit->Stat != "I"
            SKIP ALIAS Debit
            LOOP
         ENDIF
         IF Debit->Codeno != mcodeno
            SKIP ALIAS Debit
            LOOP
         ENDIF
         namnt += Debit->Amount
         @ nl, 0 SAY DTOC( Debit->Dbdate )+" "+Debit->Invno+" "+Debit->BranchId;
              +" "+STR( Debit->Amount,10, 2 )+" "+Debit->Saleno;
              +" "+STR( Debit->InitAmnt,10, 2 );
              +" "+STR( namnt,10, 2 )
         nl++
         nnum++
         IF nnum > 18
            @ 12,50 SAY "More than 17 Invoices" COLOR "R+" 
            EXIT
         ENDIF  
         SKIP ALIAS Debit
      ENDDO
      SCROLL(  20, 0, 24,80 )
      DISPBOX( 20, 1, 23,79, 2 )
      @ 14,50      SAY Name->Name
      @ 16,50      SAY "Total"
      @ 16,COL()+2 SAY namnt PICTURE "$999,999.99" 
      crecno:= ccheqno := SPACE( 6 )
      ddate  := DATE()
      nrectot:= nrecamnt := 0
      IF SUBSTR( Name->Bankno, 1, 3 ) != SPACE( 3 )
         crecno := Name->Codeno
      ENDIF
      @ 21,10      SAY "Total Received :" GET nrectot PICTURE "999999.99"
      @ 21,COL()+2 SAY "Rec/Bank No :"    GET crecno  PICTURE "@X"
      @ 22,20      SAY "Date :"           GET ddate   PICTURE "99/99/9999" 
      @ 22,COL()+2 SAY "Cust Cheque No"   GET ccheqno PICTURE "@X"
       READ
      mcodeno  := Name->Codeno
      IF PressedEsc() 
         RETURN NIL
      ENDIF
      SELECT Debit
      SET ORDER TO 1 // Codeno
      SEEK mcodeno
      IF !FOUND()
         SELECT Rec
          ApFLock( 3 )
         APPEND BLANK
         Rec->Codeno   := mcodeno
         Rec->U_Codeno := mcodeno
         Rec->Recdate  := ddate
         Rec->RecAmnt  := nrectot
         Rec->Recno    := crecno
         Rec->U_Codeno := mcodeno
         Rec->Jobno    := ccheqno
         UNLOCK

          ReceHead()                                   // Below

         SELECT Debit
      ENDIF
      DO WHILE Debit->Codeno == mcodeno .AND. Debit->( !EOF() )
         cbranchId := SPACE( 2 )
         IF LASTREC() != 0
            aPart_ := {}
            nrecno := 0
            namnt := 0
            SEEK mcodeno
            DO WHILE Debit->Codeno = mcodeno .AND. Debit->( !EOF() )
               IF Debit->Stat != "I"
                  SKIP ALIAS Debit
                  LOOP
               ENDIF
               IF cbranchId != SPACE( 2 )
                  IF Debit->BranchId != cbranchId
                     SKIP ALIAS Debit
                     LOOP
                  ENDIF
               ENDIF
               namnt += Debit->Amount
               AADD( aPart_,Debit->Invno+"  "+DTOC( Debit->Dbdate );
                  +" "+Debit->BranchId;
                  +" "+STR( Debit->Amount,10, 2 )+"  "+Debit->Saleno;
                  +"  "+Debit->Stat+"  "+STR( Debit->InitAmnt,10, 2 );
                  +"  "+STR( namnt,10, 2 );
                  +"                 "+STR( RECNO(),6 ) )
               SKIP ALIAS Debit
            ENDDO
            SCROLL( 1,50, 1,73 )
            @ 1,50      SAY cbranchId+" Total Debt"
            @ 1,COL()+1 SAY namnt PICTURE "$9999,999.99" 
            IF !EMPTY( aPart_ )
               SCROLL(   3, 0, 24,80 )
               @ 3,25       SAY "Outstanding"
               @ 3,COL()+14 SAY "Received Balance"     COLOR "BG+"
               @ 3,COL()+1  SAY nrectot PICTURE "$999,999.99" COLOR "BG+" 
               DISPBOX(  4, 1, 24,75, 2 )
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum   := ACHOICE(  5, 3, 23,73,aPart_,"","AFUNC")  // AFUNC in XLP_Init
               nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
            ENDIF
            GOTO nrecno
            minvno := Debit->Invno
         ENDIF
         SCROLL(  14, 0, 24,80 )
         DISPBOX( 14, 1, 19,79, 2 )
         @ 15,10      SAY "Received Balance "
         @ 15,COL()+1 SAY nrectot PICTURE "$999,999.99" COLOR "BG+" 
         @ 16,10      SAY "Invoice # " 
         @ 16,COL()+1 SAY Debit->Invno
         @ 16,COL()+2 SAY "Dated"
         @ 16,COL()+2 SAY Debit->Dbdate
         @ 17,18 SAY "Initial Amount"
         @ 17,COL()+1 SAY Debit->InitAmnt
         @ 17,COL()+1 SAY TRIM( Debit->Brand )
         @ 18,10      SAY "Amount"
         @ 18,COL()+2 SAY Debit->Amount PICTURE "$999,999.99" COLOR "G+"
         @ 18,COL()+4 SAY "Sale No"
         @ 18,COL()+2 SAY Debit->Saleno
         mok := ApGetY( TRIM( Message->Correct )+" Invno "+Debit->Invno )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         IF mok == "N"
            LOOP
         ENDIF
         SELECT Rec
          ApFLock( 3 )
         APPEND BLANK
         Rec->Codeno   := Debit->Codeno
         Rec->U_Codeno := Debit->U_Codeno
         Rec->Invno    := Debit->Invno
         Rec->Brand    := Debit->Brand
         Rec->Equip    := Debit->Equip
         Rec->Tech     := Debit->Tech
         Rec->Saleno   := Debit->Saleno
         Rec->CostItem := Debit->CostItem
         Rec->RecAmnt  := Debit->Amount
         Rec->RecDate  := ddate
         Rec->Recno    := crecno
         Rec->Jobno    := ccheqno
         UNLOCK
         nselect := 1
         @ 22,60 SAY "Rec" COLOR "G+"
         @ 22,64 SAY nrectot PICTURE "999,999.99"  COLOR "G+"
         IF nrectot < Rec->RecAmnt
            nselect := 2
         ENDIF
         DISPBOX( 20, 1, 24,79, 2 )
         @ 22, 8      PROMPT "Received in Full"
         @ 22,COL()+2 PROMPT "Partial Received"
         @ 22,COL()+2 PROMPT "Full Details"
         MENU TO nselect
         DO CASE
            CASE PressedEsc()
               LOOP
            CASE nselect == 1
               nrectot -= Rec->RecAmnt
               nl := 8
            CASE nselect == 2
               nrecamnt := nrectot
               ApRLock( 3 )
               @ 21,10      SAY "Debit Amount "     +STR( Rec->RecAmnt )
               @ 21,COL()+2 SAY "Received Balance " +STR( nrectot ) 
               @ 18,33      SAY "Partial Received :" GET nrecamnt PICTURE "999999.99"
                READ
               Rec->RecAmnt := nrecamnt
               UNLOCK
               IF Rec->RecAmnt = nrectot
                  nrectot -= Rec->RecAmnt
               ENDIF
               nl := 8
            CASE nselect == 3
    
               ReceHead()                           // Below

         ENDCASE
         ****      crecno := Rec->Recno
         nl+=2     
         SCROLL( nl, 3, 13,74 ) 
         @ nl,12 SAY "Received"
         @ nl,COL()+4 SAY Rec->RecAmnt
         nl+=2 
         @ nl,12      SAY "Outstanding Amount"
         @ nl,COL()+2 SAY ( Debit->Amount-Rec->RecAmnt ) PICTURE "$99,999.99" COLOR "G+"
         IF ( Debit->Amount-Rec->RecAmnt ) > 0
            mok := ApGetN( "Is This FINAL Receipt" )
         ELSE
            mok := ApGetY( "Is This FINAL Receipt" )
         ENDIF
         IF Debit->Amount > Rec->RecAmnt
            IF mok = "Y"
               mok := ApGetN( "SURE FINAL RECEIPT" )
               IF PressedEsc()
                  RETURN NIL
               ENDIF
            ENDIF
         ENDIF                     // mok
         IF mok == "Y"
            minvno := Debit->Invno
            SELECT Debit
             ApRLock( 3 )
            DELETE
            UNLOCK
            SELECT Invoice
            GOTO TOP
            SEEK minvno
            DO WHILE Invoice->Invno = minvno .AND. Invoice->( !EOF() )
               SELECT PartOper
               GOTO TOP 
               DO WHILE PartOper->( !EOF() )
                  IF PartOper->Codeno != Invoice->Codeno
                     SKIP ALIAS PartOper
                     LOOP
                  ENDIF
                  IF PartOper->Adminno != SPACE( 8 )
                     IF PartOper->Adminno != Debit->Invno
                        SKIP ALIAS PartOper
                        LOOP
                     ENDIF 
                  ENDIF 
                   ApFLock( 3 )
                  DELETE
                  UNLOCK
                  SKIP ALIAS PartOper
              ENDDO                     // PartOper EOF
              SELECT Invoice
                ApFLock( 3 )
               DELETE
               UNLOCK
               SKIP Alias Invoice
            ENDDO
            SELECT Cusnotes
            GOTO TOP
            coderef := minvno
            SEEK coderef
             ApFLock( 3 )
            DO WHILE FOUND()
               DELETE
               SEEK coderef
            ENDDO
            UNLOCK
            SELECT Cusnotes
            GOTO TOP
             ApFLock( 3 )
            DO WHILE Cusnotes->( !EOF() )
               IF SUBSTR( Code_Ref, 9, 6 ) != minvno
                  SKIP ALIAS Cusnotes
                  LOOP
               ENDIF
               DELETE
               SKIP ALIAS Cusnotes 
            ENDDO
            UNLOCK
            SELECT QuotInfo
            GOTO TOP
            DO WHILE QuotInfo->( !EOF() )
               IF QuotInfo->Invno != minvno
                  SKIP ALIAS QuotInfo
                  LOOP
               ENDIF
               ApRLock( 3 )
               DELETE
               UNLOCK
               SKIP Alias QuotInfo
            ENDDO
         ENDIF                     // mok
         SELECT Name
          ApRLock( 3 )
         Name->Overdue -= Rec->RecAmnt
         UNLOCK
         SELECT Debit
          ApRLock( 3 )
         Debit->Amount -= Rec->RecAmnt
         UNLOCK
         SKIP ALIAS Debit
      ENDDO
      COMMIT
      mcontinue :="Y"
   ENDDO                        // mcontinue

   RETURN NIL

   ****------- End of RecAdd

   **-------------------------------------------------------------------

STATIC FUNCTION DebRecLst()

   nl       := 1
   mname    := SPACE(30)
   mcodeno  := mcodeind:= SPACE(8)
   mdbdate  := DATE()
   mamount  := mamntind:= mrectot:= mrecind:= 0
   mwhere   := "S"
   mselect  := "A"
   * @  6, 5 SAY "All Invoices or Outstanding Only ? A/O "
   * @  6,45 GET mselect PICTURE "@!"

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @  1,20 SAY "LIST ALL DEBITS and RECEIPTS"
      mmonth := "M"
      @  6,12 SAY "All Invoices or Month only A/M :" GET mmonth PICTURE "!"
       READ
      dmm := SUBSTR( DTOS( DATE()),5,2 )
      dyy := SUBSTR( DTOS( DATE()),1,4 )
      IF mmonth = "M"
         @  8,20      SAY "Select Month :" GET dmm PICTURE "99"
         @  8,COL()+3 SAY "Year :"         GET dyy PICTURE "9999"
          READ
         IF PressedEsc()
            RETURN NIL
         ENDIF
      ENDIF                   // mmonth
      dyymm  := dyy+dmm
      mcont := ApGetN( Message->Another+"Individual Name" )
      IF mcont = "Y"  

          NameRank()                               // XLF_Name.PRG

         IF PressedEsc()
            RETURN NIL
         ENDIF
         mcode := Name->Codeno
         SCROLL()
      ENDIF                                   / mok = "Y"
      msaleno := SPACE(4)
      @ 10,10 SAY Message->Blank GET msaleno PICTURE "@K!"
       READ
      IF msaleno != SPACE(4)
         SELECT Salebook
         SEEK msaleno
         IF !FOUND()

             Sblook( @msaleno )                      // XLP_Acc.PRG

         ENDIF
         msaleno := Salebook->Saleno
         @ 10,10 SAY "Sale Book # "+SaleBook->Saleno+"  "+Salebook->Sbname
      ENDIF

      Printsel( mwhere )

      nl := 0
      IF mwhere == "P"
         npl := 54
       ELSE
         SCROLL()
         npl := 21
      ENDIF

       nl := DebRecHd( nl )                          // Below

      SELECT DebProf
      SET ORDER TO 2                      // Invno
      GOTO TOP
      mcodeind := DebProf->Codeno
      DO WHILE DebProf->( !EOF() )
         IF mmonth = "M"
            IF SUBSTR( DTOS( DebProf->DBDate ),1, 6 ) != dyymm
               SKIP ALIAS DebProf
               LOOP
            ENDIF
         ENDIF                     // mmonth
         IF mcont = "Y"
            IF DebProf->Codeno != mcode
               SKIP ALIAS DebProf
               LOOP
            ENDIF
         ENDIF                                // mok
         IF msaleno != SPACE(4)
            IF DebProf->Saleno != msaleno
               SKIP ALIAS DebProf
               LOOP
            ENDIF
         ENDIF
         IF DebProf->Amount == 0
            SKIP ALIAS DebProf
            LOOP
         ENDIF
         IF mselect == "O"
            IF Amount == 0
               SKIP ALIAS DebProf
               LOOP
            ENDIF
         ENDIF
         IF nl > npl
            IF mwhere == "P"
               EJECT
              ELSE
               WAIT
               SCROLL()
            ENDIF                       // mwhere = P
            nl := DebRecHd( nl )               // Below  
         ENDIF                          // nl>npl
         mcodeno := DebProf->Codeno
         minvno  := DebProf->Invno
         SELECT Name
         SEEK mcodeno
         SELECT Rec
         mrecamnt := 0
         SEEK mcodeno
         DO WHILE Rec->Codeno = mcodeno .AND. Rec->( !EOF() )
            IF Rec->Invno = minvno
                mrecamnt += Rec->Recamnt
            ENDIF
            SKIP ALIAS Rec
         ENDDO
         mrectot  += mrecamnt
         mrecind  += mrecamnt
         SELECT DebProf
         mamount  += DebProf->Amount
         mamntind += DebProf->Amount
         IF Amount > 0
            @ nl, 0 SAY DebProf->Invno
            @ nl,10 SAY DebProf->Dbdate
            @ nl,22 SAY SUBSTR( Name->Name, 1,22 ) 
            @ nl,49 SAY DebProf->Amount PICTURE "9,999,999.99"
            @ nl,61 SAY mrecamnt PICTURE "9,999,999.99"
            DO CASE
               CASE mrecamnt == DebProf->Amount
                  @ nl,76 SAY DebProf->Saleno 
               CASE mrecamnt < DebProf->Amount
                  @ nl,76 SAY "--"+SUBSTR( DebProf->Saleno, 2, 2 )
               CASE mrecamnt > DebProf->Amount
                  @ nl,76 SAY "++"+SUBSTR( DebProf->Saleno, 2, 2 )
               OTHERWISE 
                  @ nl,76 SAY "??"+SUBSTR( DebProf->Saleno, 2, 2 ) 
            ENDCASE
            nl++
         ENDIF
         SKIP ALIAS DebProf
      ENDDO
      @  nl,47 SAY "------------------------"
      nl++
      @  nl,34 SAY "GRAND TOTALS"
      @  nl,47 SAY mamount PICTURE "$99,999,999.99"
      @  nl,59 SAY mrectot PICTURE "$99,999,999.99"
      nl++
      @  nl,47 SAY "========================"
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
      mcontinue := ApGetN( Message->Another )

   ENDDO                               // mcontinue

   SELECT DebProf
   SET ORDER TO 1                      // 

   RETURN NIL

   ******* End of DebRecLst

   **---------------------------------------------------------------------*

STATIC FUNCTION DebRecHd( nl )

   @  0, 0 SAY "Debit - Receipt List" 
   @  0,22 SAY Control->U_Name
   @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
   @  2, 0 SAY "Inv #"
   @  2,10 SAY "Dated"
   @  2,22 SAY "Name"
   @  2,56 SAY "Amount"
   @  2,65 SAY "Received"
   @  2,76 SAY "Sale"
   nl := 4

   RETURN nl

   **---------------------------------------------------------------------*

FUNCTION Mu_Rec( nc, ncl )

   DO WHILE .T.

      nselect  := 0
      nc       := ncl*2
      SCROLL(  3,nc, 21,78 )
      DISPBOX( 4,nc, 21,nc+ncl )
      SCROLL(  3,nc+4, 5,nc+(ncl-4) )
      DISPBOX( 3,nc+4, 5,nc+(ncl-4) )
      @  4,nc+( ncl/2 )-( LEN( RTRIM( Menu2->CH_RecHd ) )/2 );
                           SAY RTRIM( Menu2->CH_RecHd )
      @  7,nc+2 PROMPT "1. Receipt       Add"
      @  9,nc+2 PROMPT "2.   ..         Edit"
      @ 11,nc+2 PROMPT "3.   ..         List"
      @ 13,nc+2 PROMPT "4.   ..     Analysis"
      @ 15,nc+2 PROMPT "5. Receipt By Bank #"
      @ 16,nc+2 PROMPT "6. Receipt By Name  "
      @ 17,nc+2 PROMPT "7. Receipt By RecNo "
      @ 19,nc+2 PROMPT "8. All Debit-Receipt"
      @ 20,nc+2 PROMPT Menu->CH_Main
      nc := ncl
      MENU TO nselect
      DO CASE
         CASE nselect == 9 .OR. PressedEsc()
            COMMIT
            EXIT
         CASE nselect == 1
            SAVE SCREEN TO holdscrn
             RecAdd()                          // Below
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
             Recview()                         // Below
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
              Reclist()                         // Below
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
             SaleAnal()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
             Recnoview()                         // Below
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
              NameRec()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
              RecnoList()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
              DebRecLst()                      // Below
            RESTORE SCREEN FROM holdscrn
      ENDCASE
   ENDDO

   RETURN NIL

   ***** End of Mu_Rec()

   **---------------------------------------------------------------------*

STATIC FUNCTION RecnoList()

   SCROLL()
   SELECT Rec
   SET ORDER TO 2
   GOTO TOP 
   SELECT Deposit
   SET ORDER TO 3
   GOTO TOP 
   SCROLL()
   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL()
      cheading := "List Receipts By Recno "
      DISPBOX( 0, 1, 2,79, 2 )
      @  1,40-( LEN( cheading )/2 ) SAY cheading
      DISPBOX( 3, 1, 19,79, 2 )
      mdetail := "Y"                     // Required By Heading
      mselect := "M"
      @  6,12 SAY "All Receipts or Month only A/M :" GET mselect PICTURE "!"
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
       nl := 0
       IF mwhere == "P"
         npl := 54
       ELSE
         SCROLL()
         npl := 21
       ENDIF

       nl := Rechead( nl )                                       // Below

      SELECT Rec
      GOTO TOP
      crecno := SPACE( 6 )
      mamount:= nrecno := 0
      DO WHILE Rec->( !EOF() )
         IF mselect = "M"
            IF SUBSTR( DTOS( Rec->Recdate ),1, 6 ) != dyymm
               SKIP ALIAS Rec
               LOOP
            ENDIF
         ENDIF                     // mselect
         IF nl > npl
            IF mwhere == "P"
                EJECT
              ELSE
                WAIT
                SCROLL()
            ENDIF
            nl := Rechead( nl )                              // Below
         ENDIF
         SELECT Name
         SEEK Rec->Codeno
         SELECT Rec
         IF Rec->Recno != crecno
            IF crecno != SPACE( 6 )
               @ nl,68 SAY nrecno          PICTURE "999,999.99" 
               SELECT Deposit
               SET EXACT OFF
               GOTO TOP
               SEEK crecno
               ndeprec := 0
               DO WHILE Deposit->DepRef = crecno .AND. Deposit->( !EOF() )
                  IF mselect = "M"
                     IF SUBSTR( DTOS( Deposit->Depdate ),1, 6 ) != dyymm
                        SKIP ALIAS Deposit
                        LOOP
                      ENDIF
                  ENDIF                     // mselect
                  nl++
                  @ nl, 0 SAY Deposit->Amount PICTURE "999,999.99"
                  @ nl,13 SAY Deposit->Saleno
                  ndeprec += Deposit->Amount
                  SKIP ALIAS Deposit
               ENDDO
               IF ndeprec > 0
                  @ nl,20 SAY "Deposited"
                  @ nl,32 SAY DTOC( Deposit->DepDate )
                  @ nl,68 SAY ndeprec PICTURE "999,999.99" 
               ENDIF                   // Deposit Found
            ENDIF                      // SPACE
            nrecno := 0 
            SELECT Rec
            crecno := Rec->Recno
         ENDIF                                // Recno  
         nl++
         @ nl, 0 SAY Rec->Recno
         @ nl, 8 SAY Rec->Recdate
         @ nl,19 SAY Rec->Invno
         @ nl,27 SAY SUBSTR( Name->Name,1,20 )
         @ nl,49 SAY Rec->Jobno
         @ nl,55 SAY Rec->Recamnt PICTURE "9,999,999.99"
         IF Rec->Recno != SPACE( 6 )
            nrecno  += Rec->Recamnt
         ENDIF
         mamount += Rec->Recamnt
         SKIP ALIAS Rec
      ENDDO
      @ nl,68 SAY nrecno          PICTURE "9,999,999.99" 
      SELECT Deposit
      SEEK crecno
      IF FOUND()
         nl++
         @ nl, 5 SAY "Deposited"
         @ nl,20 SAY DTOC( Deposit->DepDate )
         @ nl,66 SAY Deposit->Amount PICTURE "9,999,999.99" 
      ENDIF
      nl++
      @  nl,54 SAY "-------------"
      nl++
      @ nl,38 SAY "Grand Total ="
      @ nl,54 SAY mamount PICTURE "$9,999,999.99"
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

   ******---------------- End of file Recnolist

   ***---------------------------------------------------------------------*

FUNCTION ReceHead()

   mcorrect := "N"
   DO WHILE mcorrect == "N"
      SCROLL(  3, 0, 24,80)
      DISPBOX( 3, 1, 19,79, 2 )
      nl := 5
      SELECT Name
      SEEK Rec->Codeno   
      @ nl,10 SAY Name->Codeno+"   "+Name->Name COLOR "BG+" 
      nl+=2
      @ nl,10 SAY "Receipt Balance "+STR( nrectot )
      nl+=2
      SELECT Rec
       ApRLock( 3 )
      @ nl,10      SAY "Invoice "    GET Rec->Invno   PICTURE "@X"
      @ nl,COL()+1 SAY "Rec/Bank No" GET Rec->Recno   PICTURE "@X"
      @ nl,COL()+2 SAY "Date"        GET Rec->RecDate PICTURE "99/99/9999"
      nl+=2
      @ nl,10      SAY "Received"    GET Rec->RecAmnt PICTURE "999999.99"
      @ nl,COL()+1 SAY "Cheque No"   GET Rec->Jobno   PICTURE "@X"
      @ nl,COL()+2 SAY Rec->U_Codeno
      nl+=2
      @ nl,10      SAY "Sale #"      GET Rec->Saleno  PICTURE "@K!"
       READ
      UNLOCK
      IF PressedEsc()
         RETURN NIL
      ENDIF
      DO WHILE Rec->RecAmnt == 0
          ApRLock( 3 )
         @ nl, 9 SAY "Received"      GET Rec->RecAmnt  PICTURE "99999.99"
          READ
         UNLOCK
         IF PressedEsc()
             ApRLock( 3 )
            SELECT Rec
            DELETE
            UNLOCK
            RETURN NIL
         ENDIF
      ENDDO
      nrectot -= Rec->RecAmnt
      nrecno  := Rec->Recno
      ccheqno := Rec->Jobno
      msaleno := Rec->Saleno
      SELECT SaleBook
      SEEK msaleno
      IF !FOUND()

         Sblook( @msaleno )                      // XlF_Acc.PRG

      ENDIF
      SELECT Rec
       ApRLock( 3 )
      Rec->Saleno := SaleBook->Saleno
      UNLOCK
      @ nl,10 SAY "Sale #  "+SaleBook->Saleno+"  "+Salebook->Sbname
      mcorrect := ApGetY( Message->Correct )
      IF PressedEsc()
         RETURN NIL
      ENDIF
   ENDDO

   RETURN NIL

   ****** End of ReceHead()

   **---------------------------------------------------------------------*

STATIC FUNCTION RecView()

   cheading  := "View Existing Receipts"
   mcontinue:= mdelete:= mok := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL()
      DISPBOX(  0, 1,  2,79, 2 )
      DISPBOX( 10, 1, 14,79, 2 )
      @  1,40 -( LEN(cheading)/2 ) SAY cheading
      dmm := SUBSTR( DTOS( DATE()),5,2 )
      @ 12,20 SAY "Select Month :" GET dmm PICTURE "99"
      dyy := SUBSTR( DTOS( DATE()),1,4 )
      @ 12,COL()+4 SAY "Year :" GET dyy PICTURE "9999"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      dyymm  := dyy+dmm
      nrectot:= nrecno := 0
      aPart_ := {}
      SELECT Rec
      IF LASTREC() != 0
         GOTO TOP
         DO WHILE Rec->( !EOF() )
            IF SUBSTR( DTOS( Rec->Recdate ),1,6 ) != dyymm
               SKIP ALIAS Rec
               LOOP
            ENDIF
            SELECT Name
            SEEK Rec->Codeno
            SELECT Rec
            csale := Rec->Invno+" "+Rec->Saleno+" "+Rec->Recno
            AADD( aPart_,csale+"  "+DTOC( RecDate )+" "+SUBSTR( Name->Name,1,28 );
                 +" "+STR( Recamnt,8, 2 )+" "+Rec->Jobno;
                 +"         "+STR( RECNO(),6 ) ) 
            SKIP ALIAS Rec
         ENDDO
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            ASORT(aPart_,,,{ | x,y | x < y })
            anum   := ACHOICE( 4, 3,23,78, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
          ELSE
            @ 14,20 SAY "-- No Receipts This Month --"
            WAIT
            LOOP
         ENDIF
      ENDIF
      SCROLL( 3, 0, 24,80 )
      GOTO nrecno
      drecdate := Rec->RecDate

        ReceHead()                                     // above

       cstring := TRIM( Message->Delete )
       mok := ApCheck( cstring )                        // AppX.PRG
       IF PressedEsc()
          RETURN NIL
       ENDIF
       IF mok == "Y"
          cstring := TRIM( Message->SureDel )
          mok := ApCheck( cstring )                     // AppX.PRG
          IF PressedEsc()
             RETURN NIL
          ENDIF
       ENDIF
       IF mok == "Y"
          mdelete := "D"
          SELECT Rec
           ApRLock( 3 )
          DELETE
          UNLOCK
       ENDIF
       mcontinue := ApGetN( TRIM( Message->Another )+" Receipt" )
       IF PressedEsc()
          RETURN NIL
       ENDIF
   ENDDO

   RETURN NIL

   *** End of Recview()

   **---------------------------------------------------------------------*

STATIC FUNCTION RecnoView()

   cheading  := "View Bank Deposit Numbers"
   mcontinue:= mdelete:= mok := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL()
      DISPBOX(  0, 1,  2,79, 2 )
      DISPBOX( 10, 1, 14,79, 2 )
      @  1,40 -( LEN(cheading)/2 ) SAY cheading
      dmm := SUBSTR( DTOS( DATE()),5,2 )
      @ 12,20 SAY "Select Month :" GET dmm PICTURE "99"
      dyy := SUBSTR( DTOS( DATE()),1,4 )
      @ 12,COL()+4 SAY "Year :" GET dyy PICTURE "9999"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      dyymm  := dyy+dmm
      nrectot:= nrecno := 0
      aPart_ := {}
      SELECT Rec
      IF LASTREC() != 0
         GOTO TOP
         DO WHILE Rec->( !EOF() )
            IF SUBSTR( DTOS( Rec->Recdate ),1,6 ) != dyymm
               SKIP ALIAS Rec
               LOOP
            ENDIF
            SELECT Name
            SEEK Rec->Codeno
            SELECT Rec
            AADD( aPart_,Rec->Recno+" "+Rec->Invno;
                 +" "+(DTOC( RecDate );
                 +" "+SUBSTR( Name->Name,1,30 );
                 +" "+STR( Recamnt,8, 2 )+" "+Rec->Jobno;
                 +" "+Saleno+"         "+STR( RECNO(),6 ) ) )
            SKIP ALIAS Rec
         ENDDO
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            ASORT(aPart_,,,{ | x,y | x < y })
            anum   := ACHOICE( 4, 3, 23,78, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
          ELSE
            @ 14,20 SAY "-- No Receipts This Month --"
            WAIT
            LOOP
         ENDIF
      ENDIF
      SCROLL( 3, 0, 24,80 )
      GOTO nrecno
       drecdate := Rec->RecDate

        ReceHead()                                     // above

       cstring := TRIM( Message->Delete )
       mok := ApCheck( cstring )                        // AppX.PRG
       IF PressedEsc()
          RETURN NIL
       ENDIF
       IF mok == "Y"
          cstring := TRIM( Message->SureDel )
          mok := ApCheck( cstring )                     // AppX.PRG
          IF PressedEsc()
             RETURN NIL
          ENDIF
       ENDIF
       IF mok == "Y"
          mdelete := "D"
          SELECT Rec
           ApRLock( 3 )
          DELETE
          UNLOCK
       ENDIF
       mcontinue := ApGetN( TRIM( Message->Another )+" Receipt" )
       IF PressedEsc()
          RETURN NIL
       ENDIF
   ENDDO

   RETURN NIL

   *** End of Recnoview()

   **---------------------------------------------------------------------*

STATIC FUNCTION RecList()

   SCROLL()
   cheading := "List Receipts"
   DISPBOX( 0, 1, 2,79, 2 )
   @  1,40-( LEN( cheading )/2 ) SAY cheading
   SCROLL(  3, 0, 24,80 )
   DISPBOX( 3, 1, 19,79, 2 )
   mmonth   := SPACE( 4 )
   mname    := SPACE( 30 )
   mrecdate := SPACE( 8 )
   minvno   := SPACE( 6 )
   mcodeno  := SPACE( 8 )
   mno:= mnotot:= mamount:= msaleamnt:= 0
   mselect := "M"

   @  4,12 SAY "All Receipts or Month/Days only A/M :" GET mselect PICTURE "!"
    READ
   dmonth := MONTH( DATE() )
   dyear  := YEAR( DATE() )
   mname  := SPACE( 30 )
   mstmm  := DATE()-30
   mendmm := DATE()
   IF mselect = "M"
      @  6,10 SAY Message->Frdate GET mstmm  PICTURE "99/99/9999"
      @  7,10 SAY Message->Todate GET mendmm PICTURE "99/99/9999"
       READ
      ***   @  6,22 SAY "Which Month to List :" GET dmonth PICTURE "99"
      ***   @  7,31 SAY "Which Year :"          GET dyear  PICTURE "9999"
      ***    READ
   ENDIF
   mdetail = "Y"
   @   8,25 SAY "List All Details :"       GET mdetail PICTURE "!"
    READ
        mchoice := 0
        @ 10,24 PROMPT "Invoice No       List"
        @ 11,24 PROMPT "Receipt/BankSlip List"
        @ 12,24 PROMPT "Saleno           List"
        @ 13,24 PROMPT "Name Codeno      List"
        @ 14,24 PROMPT "Technician       List"
        @ 15,24 PROMPT "Equipment        List"
        @ 16,24 PROMPT "Map #            List"
        MENU TO mchoice
        DO CASE
           CASE mchoice == 1
              SELECT Rec
              GOTO TOP
               ApFLock( 3 ) 
              INDEX ON Invno TO TempI09
              SET INDEX TO TempI09
              UNLOCK
           CASE mchoice == 2
              SELECT Rec
              GOTO TOP 
               ApFLock( 3 )
              INDEX ON Recno TO TempI09
              SET INDEX TO TempI09
              UNLOCK
           CASE mchoice == 3
              SELECT Rec
              GOTO TOP
               ApFLock( 3 )
              INDEX ON Saleno+Invno TO TempI09
              SET INDEX TO TempI09
              UNLOCK
           CASE mchoice == 4
              SELECT Rec
              SET INDEX TO RecInd
              NameRank( @mcodeno )
           CASE mchoice == 5
              SELECT Rec
              GOTO TOP
               ApFLock( 3 )
              INDEX ON Tech+Invno TO TempI09
              SET INDEX TO TempI09
              UNLOCK
           CASE mchoice == 6
              SELECT Rec
              GOTO TOP
               ApFLock( 3 ) 
              INDEX ON Equip+Invno TO TempI09
              SET INDEX TO TempI09
              UNLOCK
           CASE mchoice == 7
              SELECT Rec
              GOTO TOP 
                ApFLock( 3 )
              INDEX ON Map+Invno TO TempI09
              SET INDEX TO TempI09
              UNLOCK
        ENDCASE

      mwhere := "S"
      npl    := 56

        Printsel()                                      //  _LF_Init

      SCROLL()

     nl := Rechead( nl )                                       // Below

   SELECT Rec
   GOTO TOP
   DO CASE
      CASE mchoice == 1
          msaleno  := Rec->Invno
      CASE mchoice == 2
          msaleno  := Rec->Recno
      CASE mchoice == 3
          msaleno  := Rec->Saleno
      CASE mchoice == 5
          msaleno  := Rec->Tech
      CASE mchoice == 6
          msaleno  := Rec->Equip
      CASE mchoice == 7
          msaleno  := Rec->Map
   ENDCASE
   DO WHILE Rec->( !EOF() )
      IF SUBSTR( Rec->Recno,1, 1 ) = "Z"
         SKIP ALIAS Rec
         LOOP
      ENDIF
      IF mselect = "M"
            IF Rec->RecDate < mstmm          // Includes the Date From
               SKIP ALIAS Rec
               LOOP
            ENDIF
            IF Rec->RecDate > mendmm         // Includes the Date Up to
               SKIP ALIAS Rec
               LOOP
            ENDIF
      ***      IF MONTH( Rec->Recdate ) != dmonth .AND. YEAR( Rec->Recdate ) != dyear
      ***         SKIP ALIAS Rec
      ***         LOOP
      ***      ENDIF
      ENDIF
      DO CASE
          CASE mchoice = 2
     IF Rec->Recno != msaleno
   **    IF msaleamnt != 0
   **       nl = nl + 1
   **       @ nl,30 SAY "Rec/BS  "+msaleno
   **       @ nl,45 SAY msaleamnt PICTURE "99,999.99"
   **     ENDIF
   **     nl := nl + 2
        msaleamnt := 0
        msaleno   := Rec->Recno
     ENDIF
         CASE mchoice = 3
    IF Rec->Saleno != msaleno
       IF msaleamnt != 0
          nl++
          @ nl,30 SAY "Saleno "+msaleno
          @ nl,45 SAY msaleamnt PICTURE "9,999,999.99"
       ENDIF
       nl+=2
       msaleamnt := 0
       msaleno   := Rec->Saleno
    ENDIF
         CASE mchoice == 5
      ***         IF Rec->Tech == SPACE(2)
      ***            SKIP ALIAS Rec
      ***            LOOP
      ***         ENDIF
    IF Rec->Tech != msaleno
       IF msaleamnt != 0
          nl++
          @ nl,10 SAY "No of Jobs ="
          @ nl,22 SAY mno PICTURE "9,999"
          @ nl,30 SAY "Tech  "+msaleno
          @ nl,45 SAY msaleamnt PICTURE "9,999,999.99"
       ENDIF
       IF mdetail == "Y"
          nl+=2
         ELSE
          nl++
       ENDIF
       mnotot    := mnotot+mno
       mno       := 0
       msaleamnt := 0
       msaleno   := Rec->Tech
    ENDIF
         CASE mchoice == 6
            IF Rec->Equip = SPACE(2)
               SKIP ALIAS Rec
               LOOP
    ENDIF
    IF Rec->Equip != msaleno
       IF msaleamnt != 0
          nl++
          @ nl,10 SAY "No of Jobs ="
          @ nl,22 SAY mno PICTURE "9,999"
          @ nl,30 SAY "Equip  "+msaleno
          @ nl,45 SAY msaleamnt PICTURE "9,999,999.99"
       ENDIF
       IF mdetail = "Y"
          nl+=2
         ELSE
          nl++
       ENDIF
       mnotot := mnotot+mno
       mno    := 0
       msaleamnt := 0
       msaleno := Equip
    ENDIF
         CASE mchoice == 7
      ***         IF Map = SPACE(2)
      ***            SKIP ALIAS Rec
      ***            LOOP
      ***         ENDIF
    IF Map != msaleno
       IF msaleamnt != 0
          nl++
          @ nl,10 SAY "No of Jobs ="
          @ nl,22 SAY mno PICTURE "9,999"
          @ nl,30 SAY "Map # "+msaleno
          @ nl,45 SAY msaleamnt PICTURE "$9,999,999.99"
       ENDIF
       IF mdetail = "Y"
          nl+=2
         ELSE
          nl++
       ENDIF
       mnotot    := mnotot+mno
       mno       := 0
       msaleamnt := 0
       msaleno   := Rec->Map
    ENDIF
      ENDCASE
      IF nl > npl
         IF mwhere == "P"
    EJECT
          ELSE
    WAIT
    SCROLL()
         ENDIF

         nl := Rechead( nl )                              // Below

      ENDIF
      IF mselect == "A"
         SELECT Name
         SEEK Rec->Codeno
         IF FOUND()
             mname := Name->Name
      *****         mname = TRIM(Title)+" "+TRIM(Called)+" "+TRIM(Famname)
         ENDIF
         SELECT Rec
         mamount   += Rec->Recamnt
         msaleamnt += Rec->Recamnt
         IF mdetail = "Y"
            @ nl, 0 SAY Rec->Recno
            @ nl, 8 SAY Rec->Recdate
            @ nl,20 SAY Rec->Invno
            @ nl,30 SAY mname
            @ nl,57 SAY Rec->Recamnt PICTURE "9,999,999.99"
            nl++
        ENDIF
        mno++
       ELSE
      ***      IF MONTH( Rec->Recdate ) = dmonth .AND. YEAR( Rec->Recdate ) = dyear
            SELECT Name
            SEEK Rec->Codeno
            IF FOUND()
               mname := Name->Name 
            ENDIF
    SELECT Rec
    mamount   += Rec->Recamnt
    msaleamnt += Rec->Recamnt
    IF mdetail = "Y"
       @ nl, 0 SAY Rec->Recno
       @ nl, 8 SAY Rec->Recdate
       @ nl,20 SAY Rec->Invno
       @ nl,30 SAY mname
       @ nl,56 SAY Rec->Recamnt PICTURE "9,999,999.99"
               nl++
             ENDIF
         mno := mno+1
         ENDIF
      ***   ENDIF
      SKIP ALIAS Rec
   ENDDO
   mnotot := mnotot+mno
   DO CASE
        CASE mchoice == 2
      ***      IF msaleamnt != 0
      *** nl = nl + 1
      *** @ nl,30 SAY "Rec/BS  "+msaleno
      *** @ nl,45 SAY msaleamnt PICTURE "99,999.99"
      ***      ENDIF
      CASE mchoice == 3
         IF msaleamnt != 0
    nl++
    @ nl,30 SAY "Saleno  "+msaleno
    @ nl,45 SAY msaleamnt PICTURE "9,999,999.99"
         ENDIF
      CASE mchoice == 5
         IF msaleamnt != 0
    nl++
    @ nl,10 SAY "No of Jobs ="
    @ nl,22 SAY mno PICTURE "9,999"
    @ nl,30 SAY "Tech  "+msaleno
    @ nl,45 SAY msaleamnt PICTURE "9,999,999.99"
         ENDIF
      CASE mchoice == 6
         IF msaleamnt != 0
    nl++
    @ nl,10 SAY "No of Jobs ="
    @ nl,22 SAY mno PICTURE "9,999"
    @ nl,30 SAY "Equip  "+msaleno
    @ nl,45 SAY msaleamnt PICTURE "9,999,999.99"
         ENDIF
        CASE mchoice == 7
         IF msaleamnt != 0
            nl++
    @ nl,10 SAY "No of Jobs ="
    @ nl,22 SAY mno PICTURE "9,999"
    @ nl,30 SAY "Week # # "+msaleno
    @ nl,45 SAY msaleamnt PICTURE "9,999,999.99"
         ENDIF
   ENDCASE
   nl := nl+1
   @  nl,52 SAY "--------------"
   nl := nl+1
   IF mnotot > 0
      @ nl,10 SAY "Grand Total ="
      @ nl,22 SAY mnotot PICTURE "9,999"
   ENDIF
   @  nl,52 SAY mamount PICTURE "$9,999,999.99"
   nl := nl+1
   @  nl,52 SAY "=============="
   IF mwhere == "P"
      EndPrint()
      SET MARGIN TO 0
     ELSE
      WAIT
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF

   RETURN NIL

   ****------- End of file Reclist

   **-------------------------------------------------------------------

STATIC FUNCTION Rechead( nl )

   @  0, 0 SAY Control->U_Name+" Receipt List"
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
   IF mdetail == "Y"
      @  2, 0 SAY "Rec No"
      @  2, 8 SAY "Date"
      @  2,20 SAY "Inv"
      @  2,30 SAY "Name"
      @  2,59 SAY "Amount"
      * @  2,68 SAY "Sale"
      nl := 4
     ELSE
      nl := 2
   ENDIF

   RETURN nl

   *********--------------  END OF FILE XLF_REC.PRG

