   *** JK 08-04-11 17:55:36 

/* Program.....: PMPIRDFM
   Authors.....: J Kirby
   Date........: 26/03/1987
   Function....: IR348, IR345, Y2Name, IR348ALL
*/

FUNCTION IR348()  // Show total pay figures for month

   mstmm  := DATE()-14      // Control->LastPaye+6
   mendmm := DATE()        // Control->LastPaye+30
   @ 18, 5      SAY "From Pay Date"   GET mstmm   PICTURE "99/99/9999"
   @ 18,COL()+2 SAY "To Pay End Date" GET mendmm  PICTURE "99/99/9999"
    READ
   IF PressedEsc()
      RETURN NIL
   ENDIF
      *** SELECT Control
      ***     ApRLock( 3 )
      ***    Control->LastPaye := mendmm
      ***    UNLOCK  
       mwhere := "S"

       Printsel( mwhere )

      IF mwhere = "P"
         npl := 56
        ELSE
         npl := 19
      ENDIF
      mcodeno := SPACE( 8 )
      nl := 0
      nTotGrossPay:= nTotPaye:= nTotDedSL:= nTotChild := 0
      nTotkiwi:= nTotKiwiempl:= nTotESCT := 0
      @ nl, 0 SAY Control->U_Name
      @ nl,59 SAY STR( DAY(  DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR( DATE() ),5 )
      nl++
      @ nl,34 SAY "( IR348 )"
      @ nl,45 SAY Control->U_GstNo
      nl+=2
      @ nl, 0 SAY "Gross"
      @ nl,12 SAY "PAYE"
      @ nl,22 SAY "Child Sup"
      @ nl,32 SAY "Std Loan"
      @ nl,42 SAY "KiwiSave"
      @ nl,52 SAY "Empl Kiwi"
      @ nl,62 SAY "ECST"
      @ nl,70 SAY "Empl-ESCT"
      nl++
      @ nl, 0 SAY REPLICATE( "_",79 )
      nl+=2
      SELECT Pmppjnl
      IF LASTREC() != 0
         GOTO TOP
         DO WHILE Pmppjnl->( !EOF() )
            IF Pmppjnl->Pay_Per  > mendmm
               SKIP ALIAS Pmppjnl
               LOOP
            ENDIF
            IF Pmppjnl->Pay_Per  < mstmm
               SKIP ALIAS Pmppjnl
               LOOP
            ENDIF
            IF nl > npl
               IF mwhere = "P"
                  EJECT 
                 ELSE
                  WAIT
                  SCROLL()
               ENDIF
               nl := 0
            ENDIF                // npl
            SELECT Name
            SEEK Pmppjnl->Codeno
            @ nl, 0 SAY SUBSTR( Name->Name, 1,20 )
            @ nl,22 SAY Name->Taxnum           // 10
            @ nl,33 SAY Name->TaxCode
            @ nl,40 SAY "Start"
            @ nl,46 SAY Name->Started
            @ nl,58 SAY Name->EndDate
            @ nl,62 SAY Name->CsCode
            SELECT Pmppjnl
            mcodeno := Pmppjnl->Codeno
            nGrossPay:= nPaye:= nDedSL:= nChildsup:= nNT_Spec1 := 0
            nkiwisave:= nkiwiempl:= nESCT := 0
            DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() )
               IF Pmppjnl->Pay_Per  > mendmm
                  SKIP ALIAS Pmppjnl
                  LOOP
               ENDIF
               IF Pmppjnl->Pay_Per  < mstmm
                  SKIP ALIAS Pmppjnl
                  LOOP
               ENDIF
               nGrossPay  += Pmppjnl->GrossPay
               nPaye      += Pmppjnl->PAYE
               nDedSL     += Pmppjnl->DedSL
               nChildSup  += Pmppjnl->ChildSup
               nNT_Spec1  += Pmppjnl->NT_Spec1
               nkiwisave  += Pmppjnl->Kiwisave  
               nkiwiempl  += Pmppjnl->Kiwiempl  
               SKIP ALIAS Pmppjnl
            ENDDO
            nl++
            @ nl, 0 SAY nGrossPay  PICTURE "99,999.99"
            @ nl,12 SAY nPaye      PICTURE "99,999.99"
            @ nl,22 SAY nChildSup  PICTURE "9,999.99"
            @ nl,32 SAY nDedSL     PICTURE "9,999.99"
            @ nl,42 SAY nkiwisave  PICTURE "9,999.99"
            @ nl,52 SAY nkiwiempl  PICTURE "9999.99"
            nESCT := ( nkiwiEmpl )-( nkiwiEmpl*( 1-Name->Rate/100 ) )
            @ nl,62 SAY nESCT      PICTURE "9999.99"
            @ nl,71 SAY ( nkiwiEmpl-nESCT ) PICTURE "9999.99"
            nl+=2
            nTotGrossPay += nGrossPay
            nTotPaye     += nPaye
            nTotDedSL    += nDedSL
            nTotChild    += nChildSup
            nTotKiwi     += nkiwisave
            nTotKiwiEmpl += nkiwiempl
            nTotESCT     += nESCT
            SELECT Pmppjnl
         ENDDO             // EOF Pmppjnl
      ENDIF                // LastRec
   nl++
   @ nl, 0 SAY REPLICATE( "_",79 )
   nl+=2
   IF mwhere = "S"
      IF nl > 18
         WAIT
         SCROLL()
         nl := 0
      ENDIF 
   ENDIF   
   @ nl, 0 SAY "Gross Pay"
   @ nl,12 SAY "PAYE"
   @ nl,22 SAY "Child"
   @ nl,32 SAY "S/Loan"
   @ nl,42 SAY "KiwiSave"
   @ nl,52 SAY "Empl Cont"
   @ nl,62 SAY "ESCT"
   @ nl,70 SAY "Emp-ESCT" 
   nl+=2
   @ nl, 0 SAY nTotGrossPay PICTURE "999,999.99"
   @ nl,11 SAY nTotPaye     PICTURE "999,999.99"
   @ nl,22 SAY nTotChild    PICTURE "99,999.99"
   @ nl,32 SAY nTotDedSL    PICTURE "99,999.99"
   @ nl,42 SAY nTotKiwi     PICTURE "99,999.99"
   @ nl,52 SAY nTotKiwiEmpl PICTURE "9,999.99"
   @ nl,62 SAY nTotESCT     PICTURE "9999.99"
   @ nl,71 SAY ( nTotKiwiEmpl-nTotESCT ) PICTURE "9999.99"
   nl+=2
   @ nl, 0 SAY "Pay for Period ";
                  +" "+SUBSTR( DTOC( mstmm ),  1 , 2 );
                  +"/"+SUBSTR( DTOC( mstmm ),  4 , 2 );
                  +"/"+SUBSTR( DTOC( mstmm ),  7 , 4 );
               +" To "+SUBSTR( DTOC( mendmm ), 1 , 2 );
                  +"/"+SUBSTR( DTOC( mendmm ), 4 , 2 );
                  +"/"+SUBSTR( DTOC( mendmm ), 7 , 4 )
   @ nl,48 SAY "IRD Total"
   @ nl,58 SAY nTotKiwi+nTotKiwiEmpl+nTotPaye+nTotChild+nTotDedSL PICTURE "$99,999.99"
   nl++
   IF mwhere = "P"
      ***   @ nl, 3 SAY "Signature __________________ Date __________"
      EndPrint()
     ELSE
      INKEY( 0 )
   ENDIF

   RETURN NIL

**  End Function  IR348

   ***------------------------------------------------------

FUNCTION IR345() 

   nl := 0
   SCROLL()
   mstmm  := DATE()-14
   mendmm := DATE()
   @  6, 3      SAY "From Pay Date"   GET mstmm   PICTURE "99/99/9999"
   @  6,COL()+2 SAY "To Pay End Date" GET mendmm  PICTURE "99/99/9999"
    READ

      mwhere := "S"

       Printsel( mwhere )

      IF mwhere = "P"
         npl := 56
        ELSE
         nlp := 21
      ENDIF
   mcodeno  := SPACE( 8 )
   nTotGross := nTotKiwi := nTotKiwiEmpl:= nTotcomp := 0
   nemplytax:= ncompfund:= nGrossGrand := 0
   nChildsup:= nPaye:= nDedSL:= nDedcs := 0
   nkiwisave:= nGrossPay:= nkiwiempl:= nESCTTot:= nTotEsct := 0
   ndays  := ( ( mendmm-mstmm )+1 ) 
   nweeks := ( ( mendmm-mstmm )+1 )/7
      nmaxetc := nweeks*20
      mcodeno := SPACE( 8 )
      nl := 0
      @ nl, 0 SAY Control->U_Name
      @ nl,59 SAY STR( DAY(  DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR( DATE() ),5 )
      nl+=2  
      @ nl, 0 SAY "Name"
      @ nl,21 SAY "Gross"
      @ nl,33 SAY "KiwiSave"
      @ nl,46 SAY "EmpKiwi"
      @ nl,62 SAY "ESCT"
      @ nl,69 SAY "Emp-ESCT"
      nl++
      SELECT Pmppjnl
      IF LASTREC() != 0
         GOTO TOP
         DO WHILE Pmppjnl->( !EOF() )
            IF Pmppjnl->Pay_Per  < mstmm
               SKIP ALIAS Pmppjnl
               LOOP
            ENDIF
            IF Pmppjnl->Pay_Per  > mendmm
               SKIP ALIAS Pmppjnl
               LOOP
            ENDIF
            SELECT Name
            SEEK Pmppjnl->Codeno
            SELECT Pmppjnl
            mcodeno := Pmppjnl->Codeno
            nkiwisave:= nkiwiempl:= nESCT:= nEsctTot := 0
            nGrossPay := 0
            DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() )
               IF Pmppjnl->Pay_Per  < mstmm
                  SKIP ALIAS Pmppjnl
                  LOOP
               ENDIF
               IF Pmppjnl->Pay_Per  > mendmm
                  SKIP ALIAS Pmppjnl
                  LOOP
               ENDIF
                  nkiwisave += Pmppjnl->Kiwisave
                  nkiwiempl += Pmppjnl->KiwiEmpl
                  nGrossPay += Pmppjnl->GrossPay
                  nGrossGrand += Pmppjnl->GrossPay
                  nPaye     += Pmppjnl->Paye
                  nDedSL    += Pmppjnl->DedSL
                  nChildSup += Pmppjnl->ChildSup
                  nESCT     += (Pmppjnl->KiwiEmpl )-( Pmppjnl->KiwiEmpl*( 1-Name->Rate/100 ) )
                  nESCTTot  := nESCT  
               SKIP ALIAS Pmppjnl
            ENDDO
            IF nkiwisave > 0
               @ nl, 0 SAY SUBSTR( Name->Name, 1,19 )
               @ nl,20 SAY nGrossPay           PICTURE "99,999.99"
               @ nl,31 SAY Name->KiwiSave      PICTURE "99%"
               @ nl,34 SAY nKiwisave           PICTURE "9,999.99"
               @ nl,43 SAY Name->KiwiEmpl      PICTURE "99%"
               @ nl,47 SAY nkiwiempl           PICTURE "999.99"
               @ nl,54 SAY Name->Rate          PICTURE "99.99%"
               @ nl,61 SAY nESCT               PICTURE "9999.99"
               @ nl,69 SAY ( nkiwiempl-nesct ) PICTURE "9999.99"
               nTotGross    += nGrossPay
               nTotKiwi     += nkiwisave
               nTotKiwiEmpl += nkiwiempl
               nTotEsct     += nEsct
               nl++
            ENDIF
      ***         SKIP ALIAS Pmppjnl
         ENDDO             // EOF Pmppjnl
      ENDIF                // LastRec
   nl++
   @ nl,34 SAY nTotKiwi     PICTURE "9,999.99"
   @ nl,45 SAY nTotKiwiEmpl PICTURE "9,999.99"
   @ nl,61 SAY nTotESCT     PICTURE "9999.99"
   @ nl,71 SAY ntotKiwiEmpl-nTotESCT PICTURE "9999.99"
   nl++
   nl++
   @ nl, 1 SAY "Days"
   @ nl, 7 SAY ndays  PICTURE "999"
   @ nl,12 SAY "No of Weeks" 
   @ nl,25 SAY nweeks PICTURE "999.99"
   nl++
   @ nl, 0 SAY REPLICATE( "_",79 )
   nl++
   IF nl > npl
      IF mwhere = "S"
         WAIT
         SCROLL()
      ENDIF
      nl := 0
   ENDIF                // npl
   nl++
   @  nl, 0 SAY "EMPLOYER deductions"
   @  nl,24 SAY "IR345"
   nl++
   @  nl,35 SAY "            IRD number   1 " +Control->U_GSTNo
   nl++
   @  nl,35 SAY "            Period ended 2"
   @  nl,63 SAY mendmm
   nl++
   nl++
   @ nl, 0 SAY "Gross Pay"
   @ nl,12 SAY nGrossGrand PICTURE "$999,999.99"
   @ nl,35 SAY "PAYE                     3"
   @ nl,63 SAY nPaye      PICTURE "$999,999.99"
   nl++
   @ nl,29 SAY "incl.tax on schedular payments"
   nl++
   @  nl,35 SAY "Child support deductions 4"
   @  nl,63 SAY nChildSup PICTURE "$999,999.99"
   nl++
   @  nl,35 SAY "Student loan  deductions 5"
   @  nl,63 SAY nDedSL    PICTURE "$999,999.99"
   nl++
   @ nl,35 SAY "KiwiSaver deductions     6"
   @ nl,63 SAY nTotKiwi      PICTURE "$999,999.99"
   nl++
   @ nl,10 SAY "EmpKiwi - ESCT"
   @ nl,35 SAY "KiwiSaver employer       7"
   @ nl,63 SAY ( nTotkiwiempl-nTotESCT ) PICTURE "$999,999.99"
   nl++
   @ nl,38 SAY "contributions"
   nl++
   @ nl,35 SAY "ESCT deductions          8"
   @ nl,63 SAY nTotESCT      PICTURE "$999,999.99"
   nl++
   nl++
   @ nl,35 SAY "Add Boxes 3,4,5,6,7,8    9"
   nbox9 := nPaye+nChildSup+nDedSL+nTotkiwi+nTotkiwiempl
      *** beware of this +nTotESCT
   @ nl,63 SAY nbox9 PICTURE "$999,999.99"
   nl++
   nl++
   @ nl, 2 SAY "Period";
                     +" "+SUBSTR( DTOC( mstmm ),  1 , 2 );
                     +"/"+SUBSTR( DTOC( mstmm ),  4 , 2 );
                     +"/"+SUBSTR( DTOC( mstmm ),  7 , 4 );
                     +" To "+SUBSTR( DTOC( mendmm ), 1 , 2 );
                     +"/"+SUBSTR( DTOC( mendmm ), 4 , 2 );
                     +"/"+SUBSTR( DTOC( mendmm ), 7 , 4 )
   nl++
   @ nl, 0 SAY "  "
   IF mwhere = "P"
      EndPrint()
     ELSE
      INKEY( 0 )
   ENDIF

   RETURN NIL

**  End Function  IR345

   ***---------------------------------------------------------------------------

FUNCTION Y2Name( mcodeno )

   SCROLL( 4, 3,20,78 )
   @ 4,59 SAY "Pay     Hours" 
   dyy := SUBSTR( DTOS( DATE() ), 1, 4 )
   dmm := SUBSTR( DTOS( DATE() ), 5, 2 )
   nl := 5
   ntotPay:= nGrTotPay:= nTotHrs:= nGrTotHrs := 0
   SELECT Pmppjnl
   SEEK mcodeno
   IF LASTREC() != 0
      DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() )
         IF YEAR( Pmppjnl->Pay_Per ) != YEAR( DATE() )   // < Control->Acc_Date
            SKIP ALIAS Pmppjnl
            LOOP
         ENDIF
         dmm     := SUBSTR( DTOS( Pmppjnl->Pay_Per ), 5, 2 )
         dmonth  := CMONTH( Pmppjnl->Pay_Per )
         dYear   := YEAR( Pmppjnl->Pay_Per )
         nTotPay:= nTotHrs := 0
         DO WHILE SUBSTR( DTOS(Pmppjnl->Pay_Per ), 5, 2 ) = dmm;
                  .AND. Pmppjnl->( !EOF() )
              IF YEAR( Pmppjnl->Pay_Per ) != YEAR( DATE() )   // < Control->Acc_Date
                 SKIP ALIAS Pmppjnl
                 LOOP
              ENDIF
            nTotHrs += Pmppjnl->TotHrs
            nTotPay += Pmppjnl->GrossPay
            SKIP ALIAS Pmppjnl
         ENDDO 
         @ nl,32     SAY dyear
         @ nl,40 SAY dmonth
         @ nl,52 SAY nTotPay PICTURE "$999,999.99"
         @ nl,63 SAY nTotHrs PICTURE "99,999.99"   
         nl++
         nGrTotPay += nTotPay
         nGrTotHrs += nTotHrs
      ENDDO             // EOF Pmppjnl
   ENDIF                // LastRec
   nl++
   @ nl,40 SAY "Totals:"
   @ nl,52 SAY nGrTotPay PICTURE "$999,999.99"
   @ nl,63 SAY nGrTotHrs PICTURE "99,999.99"
   nl++
   @ nl,40 SAY "8% Totals"
   @ nl,52 SAY nGrTotPay-( nGrTotPay*( 1-8/100 )*100 )/100 PICTURE "$999,999.99"
   @ nl,63 SAY nGrTotHrs-( nGrTotHrs*( 1-8/100 )*100 )/100 PICTURE "99,999.99"
   INKEY( 0 )

   nl:= ntotpay:= ntotpaye:= ntotdedsl:= ntotChildSup := 0
   ntothrs:= ntotHol:= nTotSick:= nTotBer := 0  
   nTax_Spec1:= nNT_Spec1 := 0
   SELECT Pmppjnl
   mstmm  := DATE()-30
   mendmm := DATE()
   @ 15, 5 SAY Message->Frdate
   @ 16,15 GET mstmm  PICTURE "99/99/9999"
   @ 17, 5 SAY Message->Todate
   @ 18,15 GET mendmm PICTURE "99/99/9999"
    READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      dmm := SUBSTR( DTOS( DATE() ), 5, 2 )  // This cancells the selection ???
      dyy := SUBSTR( DTOS( DATE() ), 1, 4 )
      mwhere := "S"

       Printsel( mwhere )

      IF mwhere = "P"
         npl := 65
        ELSE
         npl := 22
      ENDIF
      nl := 1
      @ nl, 3 SAY "Monthly Pay Totals -   "+dyy+" Year to Date"
      nl+=2
      @ nl, 3 SAY Name->Name
      ***    @ nl,3 SAY REPLICATE(CHR(196),33)
      nl+=2
   *....v....1....v....2....v....3....v....4....v....5....v....6....v....7....v..
   *   Jan      1234567.89    1234567.89    1234567.89    1234567.89    1234567.89
   @ nl,11 SAY "Month     Total Pay    PAYE Total    S/Loan Dedn   C/Supp Dedn"
      nl++
      nChildSup:= nGrTotPay:= nTotPay := nPaye:= nDedSL:= nDedcs:= nDeb3 := 0
      nkiwisave:= nkiwiempl := 0
      SELECT Pmppjnl
      GOTO TOP
      IF LASTREC() != 0
         SEEK mcodeno 
         DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() )
      ***         IF Pmppjnl->Pay_Per < Control->Acc_Date
         IF Pmppjnl->Pay_Per < mstmm
            SKIP ALIAS Pmppjnl
            LOOP
         ENDIF
         IF Pmppjnl->Pay_Per > mendmm
            SKIP ALIAS Pmppjnl
            LOOP
         ENDIF
            IF SUBSTR( DTOS( Pmppjnl->Pay_Per ), 1, 4 ) != dyy
               SKIP ALIAS Pmppjnl
               LOOP
            ENDIF
            dmm    := SUBSTR( DTOS( Pmppjnl->Pay_Per ), 5, 2 )
            dmonth  := CMONTH( Pmppjnl->Pay_Per )
            dYear   := YEAR( Pmppjnl->Pay_Per )
            nTotPay:= nPaye:= nDedSL:= nDedcs:= nDeb3 := 0
            nTotKiwi:= nTotKiwiempl := 0
            DO WHILE SUBSTR( DTOS(Pmppjnl->Pay_Per ), 5, 2 ) = dmm;
                     .AND. Pmppjnl->( !EOF())

      **** This will stop early yy being viewed ???

               IF SUBSTR( DTOS(PMPPJNL->Pay_Per ), 1, 4 ) != dyy 
                  SKIP ALIAS Pmppjnl
                  LOOP
               ENDIF
               nTotHrs    += Pmppjnl->TotHrs
               nTotHol    += Pmppjnl->HolHours
               nTotSick   += Pmppjnl->SickHrs
               nTotPay    += Pmppjnl->GrossPay
               nTotBer    += Pmppjnl->BerHrs
               nPaye      += Pmppjnl->Paye
               nDedSL     += Pmppjnl->DedSL
               nChildSup  += Pmppjnl->ChildSup
               nTax_Spec1 += Pmppjnl->Tax_Spec1
               nNT_Spec1  += Pmppjnl->NT_Spec1
               nkiwisave  += Pmppjnl->Kiwisave
               nkiwiempl  += Pmppjnl->Kiwiempl
               SKIP ALIAS Pmppjnl
            ENDDO
            @ nl, 0 SAY dYear 
            @ nl, 8 SAY dMonth
            @ nl,20 SAY nTotPay   PICTURE "999,999.99"
            @ nl,32 SAY nTotPay   PICTURE "999,999.99"
            @ nl,43 SAY nPaye     PICTURE "999,999.99"
            @ nl,54 SAY nDedSL    PICTURE "999,999.99"
            @ nl,65 SAY nChildSup PICTURE "999,999.99"
            nl++
            nGrTotPay    += nTotpay
            nTotPaye     += nPaye
            nTotDedSL    += nDedSL
            nTotChildSup += nChildSup
            nTotKiwi     += nkiwisave
            nTotKiwiempl += nkiwiempl
         ENDDO             // EOF Pmppjnl
      ENDIF                // LastRec
   @ nl,11 SAY REPLICATE( "-",68 )
   nl++
   @ nl, 0 SAY "Totals:"
   @ nl,10 SAY nGrTotPay    PICTURE "999,999.99"
   @ nl,21 SAY nTotkiwi     PICTURE "999,999.99"
   @ nl,34 SAY nTotPaye     PICTURE "999,999.99"
   @ nl,48 SAY nTotDedsl    PICTURE "999,999.99"
   @ nl,62 SAY nTotChildSup PICTURE "999,999.99"
   nl++
   @ nl,20 SAY nTax_Spec1   PICTURE "$999,999.99"
   @ nl,34 SAY nNT_Spec1    PICTURE "$999,999.99"
   nl+=2
   @ nl, 3 SAY "Total Hrs                  Holiday   Sick      Bereavement"
   nl++
   @ nl,20 SAY "Avail Hrs"
   @ nl,30 SAY  Name->HolAvail  PICTURE "999.99"
   @ nl,40 SAY  Name->SickAvail PICTURE "999.99"
   @ nl,50 SAY  Name->BerAvail  PICTURE "999.99"
   nl++
   @ nl, 1 SAY  nTotHrs  PICTURE "9,999.99"
   @ nl,30 SAY  nTotHol  PICTURE "999.99"
   @ nl,40 SAY  nTotSick PICTURE "999.99"
   @ nl,50 SAY  nTotBer  PICTURE "999.99"
   nl++
   @ nl,20 SAY "Remain"
   @ nl,30 SAY  Name->HolAvail-nTotHol   PICTURE "999.99"
   @ nl,40 SAY  Name->SickAvail-nTotSick PICTURE "999.99"
   @ nl,50 SAY  Name->BerAvail-nTotBer   PICTURE "999.99"
   nl++
   IF mwhere = "P"
      EndPrint()
     ELSE
      INKEY(0)
   ENDIF

   RETURN NIL

**  End Function  --  Y2NAME

   ***------------------------------------------------------------------------

FUNCTION IR348ALL()  // Show total pay figures for month

   mstmm  := DATE()-14    // Control->LastPaye+6
   mendmm := DATE()       // Control->LastPaye+30
   @ 18, 5      SAY "From Pay Date"   GET mstmm   PICTURE "99/99/9999"
   @ 18,COL()+2 SAY "To Pay End Date" GET mendmm  PICTURE "99/99/9999"
    READ
   IF PressedEsc()
      RETURN NIL
   ENDIF
      *** SELECT Control
      ***     ApRLock( 3 )
      ***    Control->LastPaye := mendmm
      ***    UNLOCK  
       mwhere := "S"

       Printsel( mwhere )

      IF mwhere = "P"
         npl := 61
        ELSE
         npl := 19
      ENDIF
      mcodeno := SPACE( 8 )
      nl := 0
      nTotGrossPay:= nTotPaye:= nTotDedSL:= nTotChild := 0
      nTotKiwi:= nTotKiwiEmpl := 0
      nSpecTot:= nSpecTot1:= nSpecTot2 := 0
      @ nl, 0 SAY Control->U_Name
      @ nl,59 SAY STR( DAY(  DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR( DATE() ),5 )
      nl++
      @ nl,20 SAY "All Deductions"
      @ nl,45 SAY Control->U_GstNo
      nl+=2
      @ nl, 0 SAY "Name"
      @ nl,14 SAY "Tax"
      @ nl,26 SAY "Gross"
      @ nl,36 SAY "Paye"
      @ nl,46 SAY "Child"
      @ nl,55 SAY "Student"
      @ nl,61 SAY "KiwiSave"
      @ nl,70 SAY "Empl Kiwi"
      nl++
      @ nl, 0 SAY "IRD Number"
      @ nl,14 SAY "Code"
      @ nl,26 SAY "Earnings"
      @ nl,36 SAY "Tax"
      @ nl,46 SAY "Support"
      @ nl,55 SAY "Loan"
      nl++
      @ nl, 0 SAY REPLICATE( "_",79 )
      nl+=2
      SELECT Pmppjnl
      IF LASTREC() != 0
         GOTO TOP
         DO WHILE Pmppjnl->( !EOF() )
            IF Pmppjnl->Pay_Per  > mendmm
               SKIP ALIAS Pmppjnl
               LOOP
            ENDIF
            IF Pmppjnl->Pay_Per  < mstmm
               SKIP ALIAS Pmppjnl
               LOOP
            ENDIF
            IF nl > npl
               IF mwhere = "P"
                  EJECT 
                 ELSE
                  WAIT
                  SCROLL()
               ENDIF
               nl := 0
            ENDIF                // npl
            SELECT Name
            SEEK Pmppjnl->Codeno
            @ nl, 0 SAY SUBSTR( Name->Name, 1,20 )
            @ nl,62 SAY Name->CsCode
            SELECT Pmppjnl
            mcodeno := Pmppjnl->Codeno
            nGrossPay:= nPaye:= nDedSL:= nChildsup:= nNT_Spec1 := 0
            nSpec_Pay:= nSPec_Pay1:= nSpec_Pay2 := 0
            nkiwisave:= nkiwiempl := 0
            DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() )
               IF Pmppjnl->Pay_Per  > mendmm
                  SKIP ALIAS Pmppjnl
                  LOOP
               ENDIF
               IF Pmppjnl->Pay_Per  < mstmm
                  SKIP ALIAS Pmppjnl
                  LOOP
               ENDIF
               nGrossPay  += Pmppjnl->GrossPay
               nPaye      += Pmppjnl->PAYE
               nDedSL     += Pmppjnl->DedSL
               nChildSup  += Pmppjnl->ChildSup
               nNT_Spec1  += Pmppjnl->NT_Spec1
               nSpec_Pay  += Pmppjnl->Spec_Pay
               nSpec_Pay1 += Pmppjnl->Spec_Pay1
               nSpec_Pay2 += Pmppjnl->Spec_Pay2
               nkiwisave  += Pmppjnl->Kiwisave
               nkiwiempl  += Pmppjnl->KiwiEmpl
               SKIP ALIAS Pmppjnl
            ENDDO
            nl++
            @ nl, 0 SAY Name->Taxnum           // 10
            @ nl,12 SAY Name->TaxCode
            @ nl,26 SAY nGrossPay  PICTURE "$99,999.99"
            @ nl,37 SAY nPaye      PICTURE "$99,999.99"
            @ nl,47 SAY nChildSup  PICTURE "$99,999.99"
            @ nl,59 SAY nDedSL     PICTURE "$99,999.99"
            @ nl,70 SAY nkiwisave  PICTURE "$99,999.99"
            nl++
            IF nSpec_Pay+nSpec_Pay1+nSpec_Pay2 > 0
               @ nl, 2 SAY Name->SpecDesc
               @ nl,18 SAY nSpec_Pay  PICTURE "$9,999.99"
               @ nl,29 SAY Name->SpecDesc1
               @ nl,45 SAY nSpec_Pay1 PICTURE "$9,999.99"
               @ nl,56 SAY Name->SpecDesc2
               @ nl,71 SAY nSpec_Pay2 PICTURE "$9,999.99"
               nl++
            ENDIF 
            nTotGrossPay += nGrossPay
            nTotKiwi     += nkiwisave
            nTotKiwiEmpl += nkiwiempl
            nTotPaye     += nPaye
            nTotDedSL    += nDedSL
            nTotChild    += nChildSup
            nSpecTot     += nSpec_Pay
            nSpecTot1    += nSpec_Pay1
            nSpecTot2    += nSpec_Pay2
            SELECT Pmppjnl
         ENDDO             // EOF Pmppjnl
      ENDIF                // LastRec
   nl++
   @ nl, 0 SAY REPLICATE( "_",79 )
   nl+=2
   IF mwhere = "S"
      IF nl > 18
         WAIT
         SCROLL()
         nl := 0
      ENDIF 
   ENDIF   
   @ nl, 0 SAY "Total Pay    Total PAYE       Total Child   Total S/Loan  Kiwi"
   nl++
   @ nl, 0 SAY nTotGrossPay PICTURE "$99,999.99"
   @ nl,10 SAY nTotPaye     PICTURE "$99,999.99"
   @ nl,21 SAY nTotChild    PICTURE "$99,999.99"
   @ nl,38 SAY nTotDedSL    PICTURE "$99,999.99"
   @ nl,50 SAY nTotKiwi     PICTURE "$99,999.99"
   @ nl,61 SAY nTotKiwiEmpl PICTURE "$99,999.99"
   nl++
   @ nl, 5 SAY "Deductions Totals"
   nl++
   @ nl, 5 SAY nSpecTot  PICTURE "$99,999.99"
   @ nl,21 SAY nSpecTot1 PICTURE "$99,999.99"
   @ nl,38 SAY nSpecTot2 PICTURE "$99,999.99"
   nl+=2
   @ nl, 0 SAY "Pay for Period ";
                  +" "+SUBSTR( DTOC( mstmm ),  1 , 2 );
                  +"/"+SUBSTR( DTOC( mstmm ),  4 , 2 );
                  +"/"+SUBSTR( DTOC( mstmm ),  7 , 4 );
               +" To "+SUBSTR( DTOC( mendmm ), 1 , 2 );
                  +"/"+SUBSTR( DTOC( mendmm ), 4 , 2 );
                  +"/"+SUBSTR( DTOC( mendmm ), 7 , 4 )
   nl++
   IF mwhere = "P"
      EndPrint()
     ELSE
      INKEY( 0 )
   ENDIF

   RETURN NIL

**  End Function  IR348ALL

   ***---------------  END OF PMPIRDFM.PRG
