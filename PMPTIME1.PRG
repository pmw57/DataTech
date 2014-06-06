// ** JoKir10 29-03-10 09:12:48

/*
   Program.....: PMPTIME1.PRG  --  Entry of time & calculations, PAYE, etc.
   Function....: WeekLabour, HistLab, LabPay, NameHol
                 WeekTime, Dispay
*/

FUNCTION WeekLabour()

    SELECT Months
    GOTO TOP
    mstmm  := Date() -30
    mendmm := Date()
    @ 10, 30 SAY Message->Frdate GET mstmm  PICTURE "99/99/9999"
    @ 11, 30 SAY Message->Todate GET mendmm PICTURE "99/99/9999"
    READ
    IF PressedEsc()
        RETURN NIL
    ENDIF
    mwhere := "S"

    Printsel( mwhere )

    IF mwhere = "P"
        npl := 56
    ELSE
        npl := 20
        Scroll()
    ENDIF
    @  0, 0 SAY SubStr( Control->U_Name, 1, 35 )
    @  0, 34 SAY "Time for period " + DToC( mstmm ) + " to " + DToC( mendmm )
    // **    PmpHd()                                        //ABOVE
    @  2, 31 SAY "Avail Hours    Jobs Hrs                Gross Pay"
    nl := 3
    nTotHours := ntothrs := ntotGross := ntotPaye := ntotNett := 0
    nHours := netpay := ntotpay := nTotTH := nHrsTH := ngross := 0
    ntime := nTotTime := 0
    nkiwisave := nkiwiempl := 0
    SELECT Name
    SELECT PMPPjnl
    SET RELATION TO Codeno INTO Name
    GOTO TOP
    DO WHILE Pmppjnl->( !Eof() )
        IF Pmppjnl->Pay_Per < mstmm
            SKIP ALIAS Pmppjnl
            LOOP
        ENDIF
        IF Pmppjnl->Pay_Per > mendmm
            SKIP ALIAS Pmppjnl
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere = "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            nl := 0
        ENDIF                // npl
        mcodeno := Pmppjnl->Codeno
        netPay := ngross := nhours := 0
        @ nl, 1 SAY Name->Name
        SEEK mcodeno
        DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !Eof() )
            IF Pmppjnl->Pay_Per < mstmm
                SKIP ALIAS Pmppjnl
                LOOP
            ENDIF
            IF Pmppjnl->Pay_Per > mendmm
                SKIP ALIAS Pmppjnl
                LOOP
            ENDIF
            ngross += Pmppjnl->GrossPay
            netpay += Pmppjnl->GrossPay - Pmppjnl->Paye
            netpay -= Pmppjnl->GrossPay - Pmppjnl->KiwiSave
            netpay -= PMPPjnl->DedSL
            netpay -= PMPPjnl->ChildSup
            netpay += Pmppjnl->NT_Spec1
            netpay += PMPPjnl->NTH_Allce
            netpay += PMPPjnl->N_T_Allce
            netpay -= Pmppjnl->Spec_Pay
            netpay -= Pmppjnl->Spec_Pay1
            netpay -= Pmppjnl->Spec_Pay2
            nHours += Pmppjnl->Hours + Pmppjnl->HrsTH
            nkiwisave += Pmppjnl->Kiwisave
            nkiwiempl += Pmppjnl->Kiwiempl
            SKIP ALIAS Pmppjnl
        ENDDO                   // EOF()
        ntime := 0
        SELECT Labour
        GOTO TOP
        SEEK mcodeno
        DO WHILE Labour->Codeno = mcodeno .AND. Labour->( !Eof() )
            IF Labour->Date < mstmm
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Date > mendmm
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Partnum != Space( 20 )
                SKIP ALIAS Labour
                LOOP
            ENDIF
            ntime += Labour->Time
            SKIP ALIAS Labour
        ENDDO                   // EOF()
        @ nl, 32 SAY nHours PICTURE "999,999.99"
        @ nl, 43 SAY ntime  PICTURE "999,999.99"
        @ nl, 67 SAY nGross PICTURE "999,999.99"
        // **   @ nl,67 SAY netpay PICTURE "999,999.99"
        nl++
        SELECT Pmppjnl
        nTotTime  += nTime
        ntotGross += nGross
        ntotNett  += netPay
        nTotHours += nHours
        SKIP ALIAS Pmppjnl
    ENDDO                   // EOF()
    @ nl, 0 SAY Replicate( "-", 76 )
    nl++
    @ nl, 32 SAY nTotHours  PICTURE "999,999.99"
    @ nl, 43 SAY nTotTime   PICTURE "999,999.99"
    @ nl, 66 SAY nTotGross  PICTURE "$999,999.99"
    // ** @ nl,66 SAY nTotNett   PICTURE "$999,999.99"
    nl += 2
    @ nl, 4 SAY "For period " + DToC( mstmm ) + " to " + DToC( mendmm )
    nl += 2
    @ nl, 4 SAY "Labour Rate"
    @ nl, 16 SAY nTotGross PICTURE "9999,999.99"
    @ nl, 27 SAY "/"
    @ nl, 28 SAY nTotHours PICTURE "999,999.99"
    @ nl, 40 SAY nTotGross / nTotHours PICTURE "99,999.99"
    nl += 2
    @ nl, 4 SAY "Job Rate"
    @ nl, 16 SAY nTotGross PICTURE "9999,999.99"
    @ nl, 27 SAY "/"
    @ nl, 28 SAY nTotTime PICTURE "9999,999.99"
    @ nl, 40 SAY nTotGross / nTotTime PICTURE "99,999.99"
    nl += 2
    SELECT Part
    SET ORDER TO 1
    SEEK Message->LabPart
    @ nl, 1 SAY Message->LabPart
    @ nl, 12 SAY Part->Trade     PICTURE "9,999.99"
    @ nl, 21 SAY Part->Wholesale PICTURE "9,999.99"
    nl++
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

    SELECT PMPPjnl
    SET RELATION TO

    RETURN NIL

// **-----  End Program  WeekLabour

// **--------------------------------------------------------------------------

FUNCTION HistLab()

    Scroll()
    nl  := 2
    npl := 19
    mcodeno := Space( 8 )
    // ** mName := ApGetN( "Specific Name Only" )
   /*
   IF mName = "Y"

       Namerank( @mcodeno )                          // XLF_Name
      IF PressedEsc()
         RETURN NIL
      ENDIF
      SELECT Name
      mcodeno := Name->Codeno
   ENDIF
   */
   /*
   mDelete := ApGetN( "Delete Non Modules" )
   IF mdelete = "Y"
      mDelete := ApGetN( "Are You Sure" )
   ENDIF
   IF mDelete = "Y"
      ***   DISPBOX(  12,60,16,79, 2 )
      ***   @ 14,62 SAY "Please Wait"
      SELECT Hist
      SET ORDER TO 2
      GOTO TOP
      DO WHILE Hist->( !EOF() )
         IF nl > npl
            WAIT
            nl := 2
            SCROLL()
         ENDIF
         mpartnum := Hist->Partnum
         SELECT Equ
         mmodcode := SUBSTR( mpartnum, 1,16 )  // This is if 20 Part #
         SET EXACT ON
         GOTO TOP
         SEEK mmodcode                // Original Part
         IF !FOUND()
            SELECT Part
            SEEK mpartnum
            @ nl, 5 SAY Part->Partnum+" "+Part->Desc
            SELECT Hist
            mok := ApGetN( "Delete this Part" )
            IF mok = "Y"
                ApFLock( 3 )
               DO WHILE Hist->Partnum = mpartnum .AND. Hist->( !EOF() )
                  DELETE
                  SKIP ALIAS Hist
               ENDDO
               UNLOCK
               @ nl,70 SAY "Deleted"
             ELSE
               DO WHILE Hist->Partnum = mpartnum .AND. Hist->( !EOF() )
                  SKIP ALIAS Hist
               ENDDO
            ENDIF
            nl++
         ENDIF
         SELECT Hist
         SKIP ALIAS Hist
      ENDDO
   ENDIF
   */
    Scroll()
    DispBox( 0, 1, 18, 79, 2 )
    @  1, 20 SAY "History Analysis"
    mstmm  := Date() -30
    mendmm := Date()
    @ 10, 5 SAY Message->Frdate GET mstmm  PICTURE "99/99/9999"
    @ 11, 5 SAY Message->Todate GET mendmm PICTURE "99/99/9999"
    READ
    IF PressedEsc()
        RETURN NIL
    ENDIF
    mwhere   := "S"

    Printsel( mwhere )

    nl := 0
    IF mwhere == "P"
        npl := 56
    ELSE
        Scroll()
        npl := 23
    ENDIF
    @  0, 0 SAY SubStr( Control->U_Name, 1, 28 )
    @  0, 29 SAY mstmm
    @  0, 41 SAY mendmm
    @  0, 52 SAY mcodeno
    @  0, 63 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    nl := 2
    @ nl, 23 SAY "Qty          Cost        Sell      Result  Lab Hr TimeInd"
    nl++
    ntimetotal := 0
    // **   SELECT EquDesc
    // **   SET ORDER TO 2                   // EquId
    SELECT Hist
    SET ORDER TO 2
    GOTO TOP
    nEquIdTot := nQty := nCost := nCostTot := nAmount := nAmountTot := 0
    nLabPartTot := nProdTot := 0
    nGrpCost := nGrpSell := 0
    cEquId := Space( 12 )
    mpartnum := Hist->Partnum
    DO WHILE Hist->( !Eof() )
        IF Hist->PDate < mstmm
            SKIP ALIAS Hist
            LOOP
        ENDIF
        IF Hist->PDate > mendmm
            SKIP ALIAS Hist
            LOOP
        ENDIF
        mpartnum := Hist->Partnum
        SELECT Equ
        mmodcode := SubStr( mpartnum, 1, 16 )  // This is if 20 Part #
        SET EXACT ON
        GOTO TOP
        SEEK mmodcode                // Original Part
        IF !Found()
            SKIP ALIAS Hist
            LOOP
        ENDIF
        SELECT EquDesc
        SEEK Equ->ModCode
        IF EquDesc->EquId != cEquId
            IF nEquIdTot > 0
                @ nl, 0 SAY cEquId
                @ nl, 19 SAY "Total"
                @ nl, 25 SAY nEquIdTot         PICTURE "999,999"
                @ nl, 33 SAY nGrpCost          PICTURE "$999,999.99"
                @ nl, 46 SAY nGrpSell          PICTURE "$999,999.99"
                @ nl, 58 SAY nGrpSell - nGrpCost PICTURE "$999,999.99"
                nl++
                @ nl, 0 SAY Replicate( "_", 76 )
                nl++
            ENDIF
            // **         @ nl, 0 SAY EquDesc->EquId
            cEquId := EquDesc->EquId
            nEquIdTot := nGrpCost := nGrpSell := 0
        ENDIF
        SELECT Hist
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            @  0, 0 SAY SubStr( Control->U_Name, 1, 28 )
            @  0, 29 SAY mstmm
            @  0, 41 SAY mendmm
            @  0, 52 SAY mcodeno
            @  0, 63 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            nl := 2
            @ nl, 24 SAY "Qty          Cost        Sell      Result  Lab Hr  TimeInd"
            nl++
        ENDIF                       // nl>npl
        nQty := nCost := nAmount := 0
        DO WHILE Hist->Partnum = mpartnum .AND. Hist->( !Eof() )
            IF Hist->PDate < mstmm
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF Hist->PDate > mendmm
                SKIP ALIAS Hist
                LOOP
            ENDIF
            nQty    += Hist->Qty
            nCost   += Hist->Cost * Hist->Qty
            nAmount += Hist->Amount * Hist->Qty
            SKIP ALIAS Hist
        ENDDO
        SELECT Equ
        mmodcode := SubStr( mpartnum, 1, 16 )  // This is if 20 Part #
        nlabpart := 0
        nrecno2 := nrecno3 := nrecno4 := 0
        nequ1 := nequ2 := nequ3 := nequ4 := 0
        mmod4 := mmod3 := mmod2 := Space( 16 )
        GOTO TOP
        SEEK mmodcode                // Original Part
        IF Found()
            DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
                SELECT Part
                SEEK Equ->Partnum
                SELECT Equ
                mmod2 := SubStr( Equ->Partnum, 1, 16 )
                nequ1 := Equ->Partqty
                nrecno2 := RecNo()
                IF Equ->Partnum = Message->LabPart
                    nlabpart += nequ1
                ENDIF
                GOTO TOP
                SEEK mmod2
                IF Found()
                    DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                        SELECT Part
                        SEEK Equ->Partnum
                        SELECT Equ
                        mmod3   := SubStr( Equ->Partnum, 1, 16 )
                        nrecno3 := RecNo()
                        nequ2 := Equ->PartQty * nequ1
                        IF Equ->Partnum = Message->LabPart
                            nlabpart += nequ2
                        ENDIF
                        GOTO TOP
                        SEEK mmod3
                        IF Found()
                            DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                SELECT Part
                                SEEK Equ->Partnum
                                SELECT Equ
                                mmod4 := SubStr( Equ->Partnum, 1, 16 )
                                nrecno4 := RecNo()
                                nequ3 := Equ->PartQty * nequ2
                                IF Equ->Partnum = Message->LabPart
                                    nlabpart += nequ3
                                ENDIF
                                GOTO TOP
                                SEEK mmod4
                                IF Found()
                                    DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                        nequ4 := Equ->PartQty * nequ3
                                        IF Equ->Partnum = Message->LabPart
                                            nlabpart += nequ4
                                        ENDIF
                                        SELECT Part
                                        SEEK Equ->Partnum
                                        SELECT Equ
                                        SKIP ALIAS Equ
                                    ENDDO                       // mmod4
                                ENDIF
                                SELECT Equ
                                GOTO nrecno4
                                SKIP ALIAS Equ
                            ENDDO                       // mmod3
                        ENDIF                          // FOUND()  mmod3
                        SELECT Equ
                        GOTO nrecno3
                        SKIP ALIAS Equ
                    ENDDO                       // mmod2 EOF()
                ENDIF                         // Found mmod2
                SELECT Equ
                GOTO nrecno2
                SKIP ALIAS Equ
            ENDDO                       // mmodcode EOF()
        ENDIF                          // Found mmodcode
        SET EXACT OFF
        nCostTot    += nCost
        nGrpCost    += nCost
        nAmountTot  += nAmount
        nGrpSell    += nAmount
        nLabpartTot += ( nQty * nlabpart )
        nEquIdTot   += nQty
        nProdTot    += nQty
        @ nl, 13 SAY SubStr( mpartnum, 1, 10 )
        @ nl, 24 SAY nQty          PICTURE "99,999"
        @ nl, 31 SAY nCost         PICTURE "999,999.99"
        @ nl, 43 SAY nAmount       PICTURE "999,999.99"
        @ nl, 54 SAY nAmount - nCost PICTURE "999,999.99"
        IF nlabpart > 0
            IF SubStr( Control->U_Name, 1, 4 ) = "CHRI"
                @ nl, 65 SAY nQty * ( nlabpart / 60 ) PICTURE "999.99"
                @ nl, 72 SAY nQty * nLabpart        PICTURE "9999.99"
            ELSE
                @ nl, 69 SAY nQty * nlabpart        PICTURE "9,999.99"
            ENDIF
        ENDIF                   // nlabpart > 0
        nl++
    ENDDO                // EOF Hist
    SELECT Hist
    SET ORDER TO 1
    @ nl, 0 SAY cEquId
    @ nl, 13 SAY "Total"
    @ nl, 25 SAY nEquIdTot         PICTURE "999,999"
    @ nl, 33 SAY nGrpCost          PICTURE "$999,999.99"
    @ nl, 46 SAY nGrpSell          PICTURE "$999,999.99"
    @ nl, 58 SAY nGrpSell - nGrpCost PICTURE "$999,999.99"
    nl++
    @ nl, 0 SAY Replicate( "-", 76 )
    nl++
    @ nl, 2 SAY "Total Cost            Sell           Result        Product      Labour"
    nl++
    @ nl, 2 SAY nCostTot            PICTURE "$999,999.99"
    @ nl, 22 SAY nAmountTot          PICTURE "$999,999.99"
    @ nl, 38 SAY nAmountTot - nCostTot PICTURE "$999,999.99"
    @ nl, 50 SAY nProdTot            PICTURE "999,999.99"
    IF SubStr( Control->U_Name, 1, 4 ) = "CHRI"
        @ nl, 63 SAY nLabPartTot / 60   PICTURE "99,999.99"
    ELSE
        @ nl, 63 SAY nLabPartTot      PICTURE "99,999.99"
    ENDIF
    nl++
    @ nl, 0 SAY Replicate( "=", 76 )
    nl++
    @ nl, 1 SAY "Labour Time"
    @ nl, 67 SAY "Hrs Total"
    nl++
    cLabno := Space( 8 )
    mInvno := Space( 6 )
    cDesc  := Space( 40 )
    nGrandTot := 0
    SELECT Labour
    GOTO TOP
    ApFLock( 3 )
    INDEX ON Invno TO LabInv
    SET INDEX TO LabInv
    UNLOCK
    GOTO TOP
    DO WHILE Labour->( !Eof() )
        IF Labour->Invno = Space( 6 )
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Partnum != Space( 20 )
            SKIP ALIAS Labour
            LOOP
        ENDIF
        nTime := nTimeTot := 0
        cLabno   := Labour->Labno
        cDesc    := Labour->Desc
        mInvno   := Labour->Invno
        DO WHILE Labour->Invno = mInvno .AND. Labour->( !Eof() )
            IF Labour->Partnum != Space( 20 )
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Partnum = Space( 20 )
                nTime  += Labour->Time
            ENDIF
            IF Labour->Date < mstmm
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Date > mendmm
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Time = 0
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Invno = Space( 6 )
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                @  0, 0 SAY Control->U_Name
                @  0, 34 SAY mstmm
                @  0, 47 SAY mendmm
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                nl := 2
            ENDIF                       // nl>npl
            IF Labour->Partnum = Space( 20 )
                nTimeTot  += Labour->Time
                nGrandtot += Labour->Time
            ENDIF
            SKIP ALIAS Labour
        ENDDO                                     // Date
        IF nTimeTot > 0
            @ nl, 0 SAY cLabno
            @ nl, 9 SAY cDesc
            @ nl, 50 SAY mInvno
            @ nl, 57 SAY nTimeTot PICTURE "99,999.99"
            @ nl, 67 SAY nTime    PICTURE "99,999.99"
            nl++
        ENDIF
    ENDDO
    IF nGrandTot > 0
        @ nl, 56 SAY "----------"
        nl++
        @ nl, 45 SAY "Total Time"
        @ nl, 57 SAY nGrandtot PICTURE "99,999.99"
        nl += 2
    ENDIF
    // ******************
    cLabno := Space( 8 )
    mInvno := Space( 6 )
    cDesc  := Space( 40 )
    nGrandTot := 0
    SELECT Labour
    GOTO TOP
    DO WHILE Labour->( !Eof() )
        IF Labour->Invno = Space( 6 )
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Partnum = Space( 20 )
            SKIP ALIAS Labour
            LOOP
        ENDIF
        nTime := nTimeTot := 0
        cLabno   := Labour->Labno
        mInvno   := Labour->Invno
        DO WHILE Labour->Invno = mInvno .AND. Labour->( !Eof() )
            IF Labour->Partnum = Space( 20 )
                SKIP ALIAS Labour
                LOOP
            ENDIF
            nTime  += Labour->Time * Labour->Rate
            IF Labour->Date < mstmm
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Date > mendmm
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Time = 0
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Invno = Space( 6 )
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                @  0, 0 SAY Control->U_Name
                @  0, 34 SAY mstmm
                @  0, 47 SAY mendmm
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                nl := 2
            ENDIF                       // nl>npl
            nTimeTot  += Labour->Time * Labour->Rate
            nGrandtot += Labour->Time * Labour->Rate
            SKIP ALIAS Labour
        ENDDO                                     // Date
        IF nTimeTot > 0
            @ nl, 0 SAY cLabno
            @ nl, 42 SAY mInvno
            @ nl, 52 SAY nTimeTot PICTURE "9,999,999.99"
            @ nl, 65 SAY nTime    PICTURE "9,999,999.99"
            nl++
        ENDIF
    ENDDO
    IF nGrandTot > 0
        @ nl, 55 SAY "------------"
        nl++
        @ nl, 40 SAY "Total Parts"
        @ nl, 55 SAY nGrandtot PICTURE "$999,999.99"
        nl += 2
    ENDIF
    SELECT Labour
    SET INDEX TO LabInd
    GOTO TOP
    nTimeRate := nTimeTotal := 0
    DO WHILE Labour->( !Eof() )
        IF Labour->Partnum != Space( 20 )
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Codeno = Space( 8 )
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Date < mstmm
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Date > mendmm
            SKIP ALIAS Labour
            LOOP
        ENDIF
        mcode := Labour->Codeno
        nCodeTot := 0
        DO WHILE Labour->Codeno = mcode .AND. Labour->( !Eof() )
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                @  0, 0 SAY Control->U_Name
                @  0, 34 SAY mstmm
                @  0, 47 SAY mendmm
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                nl := 2
            ENDIF                       // nl>npl
            IF Labour->Partnum != Space( 20 )
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Date < mstmm
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Date > mendmm
                SKIP ALIAS Labour
                LOOP
            ENDIF
            nCodeTot   += Labour->Time
            nTimeTotal += Labour->Time
            SKIP ALIAS Labour
        ENDDO                // mcode
        @ nl, 0 SAY mcode
        SELECT Name
        SEEK mcode
        @ nl, 11 SAY Name->Name
        SELECT Labour
        @ nl, 52 SAY ncodeTot PICTURE "999,999.99"
        nl++
    ENDDO                // EOF Labour
    @ nl, 51 SAY "-----------"
    nl++
    @ nl, 38 SAY "Total Time"
    @ nl, 52 SAY nTimeTotal    PICTURE "999,999.99"
    nl++
    @ nl, 51 SAY "==========="
    IF nl > npl
        IF mwhere == "P"
            EJECT
        ELSE
            WAIT
            Scroll()
        ENDIF
        @  0, 0 SAY Control->U_Name
        @  0, 34 SAY mstmm
        @  0, 47 SAY mendmm
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl := 2
    ENDIF                       // nl>npl
    nl += 2
    @ nl, 13 SAY "Std Hrs    TH Hrs   Total  P/H  Tot      P/L   Ann Holiday"
    nl++
    SELECT Pmppjnl
    GOTO TOP
    nHours := nHrsTH := nTotHrs := 0
    nHolHours := nSickTotal := nSickHrs := nBerHrs := nPubHrs := 0
    nHoursTotal := nHrsTHTotal := nTotHrsTotal := 0
    nSickTTot := nSickHrsTot := nBerHrsTot := nPubHrsTot := nHolHoursTot := 0
    DO WHILE Pmppjnl->( !Eof() )
        IF Pmppjnl->Pay_Per < mstmm
            SKIP ALIAS Pmppjnl
            LOOP
        ENDIF
        IF Pmppjnl->Pay_Per > mendmm
            SKIP ALIAS Pmppjnl
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            @  0, 0 SAY Control->U_Name
            @  0, 34 SAY mstmm
            @  0, 47 SAY mendmm
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            nl := 2
        ENDIF                       // nl>npl
        nHours := nHrsTH := nTotHrs := 0
        nHolHours := nSickTotal := nSickHrs := nBerHrs := nPubHrs := 0
        mcodeno := Pmppjnl->Codeno
        DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !Eof() )
            IF Pmppjnl->Pay_Per < mstmm
                SKIP ALIAS Pmppjnl
                LOOP
            ENDIF
            IF Pmppjnl->Pay_Per > mendmm
                SKIP ALIAS Pmppjnl
                LOOP
            ENDIF
            nHours     += Pmppjnl->Hours
            nHrsTH     += Pmppjnl->HrsTH
            nTotHrs    += Pmppjnl->Hours + ( Pmppjnl->HrsTH )
            nHolHours  += Pmppjnl->HolHours
            nSickTotal += Pmppjnl->SickTotal
            nSickHrs   += Pmppjnl->SickHrs
            nBerHrs    += Pmppjnl->BerHrs
            nPubHrs    += Pmppjnl->PubHrs
            SKIP ALIAS Pmppjnl
        ENDDO
        @ nl, 0 SAY mcodeno
        @ nl, 12 SAY nHours     PICTURE "9,999.99"
        @ nl, 22 SAY nHrsTH     PICTURE "9,999.99"
        @ nl, 30 SAY nTotHrs    PICTURE "9,999.99"
        @ nl, 40 SAY nSickTotal PICTURE "9,999.99"
        @ nl, 50 SAY nSickHrs   PICTURE "9,999.99"
        @ nl, 60 SAY nHolHours  PICTURE "9,999.99"
   /*
   SORT OUT LATER
         IF SUBSTR( Control->U_Name, 1, 4 ) = "CHRI"
            @ nl,69 SAY ( ( nLabPartTot/60 )/nTotHrs )*100 PICTURE "9999.99 %"
          ELSE
            @ nl,69 SAY ( nGrandTot/nTotHrs )*100 PICTURE "9999.99 %"
         ENDIF
   */
        nl++
        nHoursTotal  += nHours
        nHrsTHTotal  += nHrsTH
        nTotHrsTotal += nTotHrs
        nHolHoursTot += nHolHours
        nSickTTot    += nSickTotal
        nSickHrsTot  += nSickHrs
        nBerHrsTot   += nBerHrs
        nPubHrsTot   += nPubHrs
    ENDDO                // EOF Pmppjnl
    @ nl, 0 SAY Replicate( "-", 76 )
    nl++
    @ nl, 3 SAY "Std Hours    Hrs TH1/2    Total Hrs "
    nl++
    @ nl, 3 SAY nHoursTotal  PICTURE "99,999.99"
    @ nl, 16 SAY nHrsTHTotal  PICTURE "99,999.99"
    @ nl, 28 SAY nTotHrsTotal PICTURE "99,999.99"

   /*
   SORT OUT LATER
   IF SUBSTR( Control->U_Name, 1, 4 ) = "CHRI"
     @ nl,69 SAY ( ( nTotHrsTotal/nLabPartTot/60 )/nTotHrs )*100 PICTURE "9999.99 %"
    ELSE
     @ nl,69 SAY ( nGrandTot/nLabPartTot )*100 PICTURE "9999.99 %"
      **** nTotHrsTotal
   ENDIF

   */
    nl += 2
    @ nl, 4 SAY "Ann Hol   P/H   Total   S/L     Bereave   In Lieu"
    nl++
    @ nl, 3 SAY nHolHoursTot PICTURE "99,999.99"
    @ nl, 12 SAY nSickTTot    PICTURE "99,999.99"
    @ nl, 22 SAY nSickHrsTot  PICTURE "99,999.99"
    @ nl, 32 SAY nBerHrsTot   PICTURE "99,999.99"
    @ nl, 42 SAY nPubHrsTot   PICTURE "99,999.99"
    nl += 2
    @ nl, 10 SAY Message->LabQty PICTURE "99,999.99"
    @ nl, 20 SAY "Not Completed Job Cards Labour " + Message->LabPart
    nl += 2
    IF nl > npl
        IF mwhere == "P"
            EJECT
        ELSE
            WAIT
            Scroll()
        ENDIF
        @  0, 0 SAY Control->U_Name
        @  0, 34 SAY mstmm
        @  0, 47 SAY mendmm
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl := 2
    ENDIF                       // nl>npl
    namount := 0
    SELECT Pay
    GOTO TOP
    ApFLock( 3 )
    INDEX ON Cashno TO TempI02
    SET INDEX TO TempI02
    UNLOCK
    SELECT Cashbook
    GOTO TOP
    DO WHILE Cashbook->( !Eof() )
        IF CashBook->Stat != "M"
            SKIP ALIAS CashBook
            LOOP
        ENDIF
        mcashno := Cashbook->Cashno
        SELECT Pay
        GOTO TOP
        SEEK mcashno
        DO WHILE Pay->Cashno == mcashno .AND. Pay->( !Eof() )
            // **         namount := Pay->Amount
            IF Pay->Cheqdate < mstmm
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF Pay->Cheqdate > mendmm
                SKIP ALIAS Pay
                LOOP
            ENDIF
            namount += Pay->Amount
            SKIP ALIAS Pay
        ENDDO                        // End of Pay
        SELECT Cashbook
        SKIP ALIAS Cashbook
    ENDDO                               // CashBook
    @ nl, 0 SAY "Material Cheques for Period"
    @ nl, 30 SAY namount PICTURE "$999,999.99"
    nl++
    SELECT Pay
    SET INDEX TO PayInd
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

    RETURN NIL
// **---------- End of HistLab

// **----------------------------------------------------------------------------

FUNCTION CURRPAY()  // Show total pay figures for month

    dmm := SubStr( DToS( Date() ), 5, 2 )
    dyy := SubStr( DToS( Date() ), 1, 4 )
    @  6, 34      SAY "Select Month" GET dmm PICTURE "99"
    @  6, Col() + 2 SAY "Year"         GET dyy PICTURE "9999"
    READ
    IF PressedEsc()
        RETURN NIL
    ENDIF
    dyymm  := dyy + dmm
    mwhere := "S"

    Printsel( mwhere )

    IF mwhere = "P"
        npl := 60
    ELSE
        Scroll()
        npl := 22
    ENDIF
    @  0, 0 SAY Control->U_Name                 // 35
    @  0, 37 SAY "Monthly Report"
    @  0, 60 SAY Str( Day(  Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 3 SAY "Pay for period"
    @  2, 20 SAY dmm
    @  2, 24 SAY dyy
    nl := 4
    mcodeno := Space( 8 )
    ntotPay := nPaye := nDedSL := nChildSup := 0
    nDayTH := nDay := nhrs := 0
    nhrs := npay := ntax := ndedsl := nHolHours := nSickHrs := nProdBon := 0
    nSpec_Pay := nSpec_Pay2 := nSpec_Pay3 := nHrsTH := 0
    nTax_Spec1 := nNT_Spec1 := 0
    nkiwisave := nkiwiempl := 0
    SELECT Pmppjnl
    IF LastRec() != 0
        GOTO TOP
        DO WHILE Pmppjnl->( !Eof() )
            IF SubStr( DToS( Pmppjnl->Pay_Per ), 1, 6 ) != dyymm
                SKIP ALIAS Pmppjnl
                LOOP
            ENDIF
            IF nl > npl
                IF mwhere = "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                nl := 0
            ENDIF                // npl
            IF Pmppjnl->Codeno != mcodeno
                IF mcodeno != Space( 8 )
                    @ nl, 0 SAY Replicate( "-", 72 )
                    nl++
                ENDIF                                  // Space( 8 )
                mcodeno := Pmppjnl->Codeno
            ENDIF                                     // mcodeno
            @ nl, 0 SAY PmppJnl->Codeno
            @ nl, 10 SAY DToC( Pmppjnl->Pay_Per )
            @ nl, 22 SAY Pmppjnl->GrossPay PICTURE "$99,999.99"
            @ nl, 34 SAY Pmppjnl->Kiwisave PICTURE "$9,999.99"

            @ nl, 45 SAY Pmppjnl->Paye     PICTURE "$9,999.99"
            IF Dedsl > 0
                @ nl, 56 SAY Pmppjnl->Dedsl  PICTURE "$999.99"
            ENDIF
            nl++
            IF Pmppjnl->ProdBon > 0
                @ nl, 5 SAY "Bonus"
                @ nl, 13 SAY Pmppjnl->ProdBon
            ENDIF
            IF Pmppjnl->ChildSup > 0
                @ nl, 22 SAY "Child"
                @ nl, 30 SAY Pmppjnl->ChildSup
            ENDIF
            IF Pmppjnl->Spec_Pay > 0 .OR. Pmppjnl->Spec_Pay1 > 0;
                    .OR. Pmppjnl->Spec_Pay2 > 0
                nl++
                @ nl, 0 SAY Name->SpecDesc
                @ nl, 16 SAY Pmppjnl->Spec_Pay  PICTURE "$9,999.99"
                @ nl, 27 SAY Name->SpecDesc1
                @ nl, 43 SAY Pmppjnl->Spec_Pay1 PICTURE "$9,999.99"
                nl++
                @ nl, 0 SAY Name->SpecDesc2
                @ nl, 16 SAY Pmppjnl->Spec_Pay2 PICTURE "$9,999.99"
            ENDIF
            IF Pmppjnl->Tax_Spec1 > 0
                nl++
                @ nl, 0 SAY Name->TaxDesc1
                @ nl, 16 SAY Pmppjnl->Tax_Spec1  PICTURE "$9,999.99"
            ENDIF
            IF Pmppjnl->Spec_Pay3 > 0
                nl++
                @ nl, 0 SAY Name->SpecDesc3
                @ nl, 16 SAY Pmppjnl->Spec_pay3 PICTURE "$9,999.99"
            ENDIF
            IF Pmppjnl->NT_Spec1 > 0
                nl++
                @ nl, 0 SAY Name->NTDesc1
                @ nl, 16 SAY Pmppjnl->NT_Spec1  PICTURE "$9,999.99"
            ENDIF
            nl++
            nDay := Pmppjnl->Day1 + Pmppjnl->Day2 + Pmppjnl->Day3 + Pmppjnl->Day4;
                + Pmppjnl->Day5 + Pmppjnl->Day6 + Pmppjnl->Day7
            @ nl, 6 SAY "Hrs Std   " + Str( Pmppjnl->Day1 );
                + "  " + Str( Pmppjnl->Day2 );
                + "  " + Str( Pmppjnl->Day3 );
                + "  " + Str( Pmppjnl->Day4 );
                + "  " + Str( Pmppjnl->Day5 );
                + "  " + Str( Pmppjnl->Day6 );
                + "  " + Str( Pmppjnl->Day7 )
            @ nl, 64 SAY nDay PICTURE "999.99"
            nl++
            nDayTH := Pmppjnl->Day1TH + Pmppjnl->Day2TH + Pmppjnl->Day3TH + Pmppjnl->Day4TH;
                + Pmppjnl->Day5TH + Pmppjnl->Day6TH + Pmppjnl->Day7TH
            IF nDayTH > 0
                @ nl, 10 SAY "T+1/2 " + Str( Pmppjnl->Day1TH );
                    + "  " + Str( Pmppjnl->Day2TH );
                    + "  " + Str( Pmppjnl->Day3TH );
                    + "  " + Str( Pmppjnl->Day4TH );
                    + "  " + Str( Pmppjnl->Day5TH );
                    + "  " + Str( Pmppjnl->Day6TH );
                    + "  " + Str( Pmppjnl->Day7TH )
                @ nl, 64 SAY nDayTH     PICTURE "999.99"
                @ nl, 72 SAY nDayTH * 1.5 PICTURE "999.99"
                nl++
            ENDIF
            IF Pmppjnl->HolHours > 0
                @ nl, 1 SAY Pmppjnl->HolRate PICTURE "$99.99"
                @ nl, 10 SAY "Hols  " + Str( Pmppjnl->Day1Hol );
                    + "  " + Str( Pmppjnl->Day2Hol );
                    + "  " + Str( Pmppjnl->Day3Hol );
                    + "  " + Str( Pmppjnl->Day4Hol );
                    + "  " + Str( Pmppjnl->Day5Hol );
                    + "  " + Str( Pmppjnl->Day6Hol );
                    + "  " + Str( Pmppjnl->Day7Hol )
                @ nl, 64 SAY Pmppjnl->HolHours PICTURE "999.99"
                nl++
            ENDIF
            IF Pmppjnl->SickTotal > 0
                @ nl, 10 SAY "      " + Str( Pmppjnl->Day1Sick ) + Pmppjnl->Day1S_B;
                    + " " + Str( Pmppjnl->Day2Sick ) + Pmppjnl->Day2S_B;
                    + " " + Str( Pmppjnl->Day3Sick ) + Pmppjnl->Day3S_B;
                    + " " + Str( Pmppjnl->Day4Sick ) + Pmppjnl->Day4S_B;
                    + " " + Str( Pmppjnl->Day5Sick ) + Pmppjnl->Day5S_B;
                    + " " + Str( Pmppjnl->Day6Sick ) + Pmppjnl->Day6S_B;
                    + " " + Str( Pmppjnl->Day7Sick ) + Pmppjnl->Day7S_B
                @ nl, 64 SAY Pmppjnl->SickTotal PICTURE "999.99"
                nl++
            ENDIF
            nhrs       += Pmppjnl->Hours
            npay       += Pmppjnl->GrossPay
            nkiwisave  += Pmppjnl->Kiwisave
            nkiwiempl  += Pmppjnl->KiwiEmpl
            ntax       += Pmppjnl->Paye
            nDedSL     += Pmppjnl->Dedsl
            nHolHours  += Pmppjnl->HolHours
            nSickHrs   += Pmppjnl->SickHrs
            nTax_Spec1 += Pmppjnl->Tax_Spec1
            nNT_Spec1  += Pmppjnl->NT_Spec1
            nProdBon   += Pmppjnl->ProdBon
            nSpec_Pay  += Pmppjnl->Spec_Pay
            nSpec_Pay2 += Pmppjnl->Spec_Pay2
            nSpec_Pay3 += Pmppjnl->Spec_Pay3
            nHrsTH     += Pmppjnl->HrsTH
            nTotPay    += Pmppjnl->GrossPay
            nPaye      += Pmppjnl->Paye
            nChildSup  += Pmppjnl->ChildSup
            SKIP ALIAS Pmppjnl
        ENDDO               // EOF Pmppjnl
        nl++
        @ nl, 0 SAY Replicate( "-", 72 )
        nl++
        IF mwhere = "S"
            IF nl > 16
                WAIT
                Scroll()
                nl := 0
            ENDIF
        ENDIF
        @ nl, 3 SAY "Std Hours"
        @ nl, 17 SAY nhrs PICTURE "9,999.99"
        @ nl, 30 SAY "Pay"
        @ nl, 34 SAY npay PICTURE "$99,999.99"
        @ nl, 46 SAY "Tax"
        @ nl, 50 SAY ntax PICTURE "$99,999.99"
        IF nHrsTH > 0
            nl++
            @ nl, 3 SAY "Time+1/2"
            @ nl, 17 SAY nHrsTH      PICTURE "9,999.99"
            @ nl, 27 SAY "Total Hrs"
            @ nl, 37 SAY nHrs + nHrsTH PICTURE "9,999.99"
        ENDIF
        IF ndedsl > 0
            nl++
            @ nl, 3 SAY "Total Student Loan"
            @ nl, 23 SAY ndedsl PICTURE "$9,999.99"
        ENDIF
        nl++
        IF nHolHours > 0
            @ nl, 3 SAY "Hol Hrs"
            @ nl, 11 SAY nHolHours PICTURE "9,999.99"
        ENDIF
        IF nSickHrs > 0
            @ nl, 22 SAY "Sick Hrs"
            @ nl, 32 SAY nSickHrs PICTURE "9,999.99"
        ENDIF
        IF nProdBon > 0
            @ nl, 43   SAY "Prod Bonus"
            @ nl, 54 SAY nProdBon PICTURE "$9,999.99"
        ENDIF
        IF nTax_Spec1 > 0
            nl++
            @ nl, 3 SAY "Taxable Spec"
            @ nl, 18 SAY nTax_Spec1 PICTURE "$9,999.99"
        ENDIF
        IF nSpec_Pay3 > 0
            nl++
            @ nl, 3 SAY "Taxable"
            @ nl, 18 SAY nSpec_Pay3 PICTURE "$9,999.99"
        ENDIF
        IF nNT_Spec1 > 0
            nl++
            @ nl, 3 SAY "Non Tax Spec"
            @ nl, 18 SAY nNT_Spec1 PICTURE "$9,999.99"
        ENDIF

    ENDIF                   // not 0
    nl++
    @ nl, 5 SAY "Total Pay  Kiwisave  Total PAYE      Total S/Loan      Total C/Supp"
    nl++
    @ nl, 5 SAY nTotpay   PICTURE "99,999.99"
    @ nl, 21 SAY nkiwisave PICTURE "99,999.99"
    @ nl, 38 SAY nPaye     PICTURE "99,999.99"
    @ nl, 55 SAY nDedSL    PICTURE "99,999.99"
    @ nl, 65 SAY nChildSup PICTURE "99,999.99"
    nl++
    IF mwhere = "P"
        EndPrint()
    ELSE
        Inkey( 0 )
    ENDIF

    RETURN NIL

// *  End Function  --  CURRPAY  **

// **---------------------------------------------------------------------------

FUNCTION Y2DPAY()

    nl := nGrTotPay := nTotPay := ntotpaye := ntotdedsl := ntotChildSup := 0
    ntothrs := ntotHol := nTotSick := 0
    SELECT Pmppjnl
    ApFLock( 3 )
    INDEX ON Pay_Per TO PmpIndx
    UNLOCK
    SET INDEX TO PmpIndx
    mstmm  := Date() -30
    mendmm := Date()
    @  8, 45 SAY Trim( Message->Frdate )
    @  9, 55 GET mstmm  PICTURE "99/99/9999"
    @ 10, 45 SAY Trim( Message->Todate )
    @ 11, 55 GET mendmm PICTURE "99/99/9999"
    READ
    dyy := SubStr( DToS( Date() ), 1, 4 )
    IF PressedEsc()
        SET INDEX TO Pmppjnl
        RETURN NIL
    ENDIF
    dmm := SubStr( DToS( Date() ), 5, 2 )
    mwhere := "S"

    Printsel( mwhere )

    IF mwhere = "P"
        npl := 65
    ELSE
        npl := 22
    ENDIF
    nl := 1
    @ nl, 3 SAY "Monthly Pay Totals -  " + DToC( mstmm ) + " To " + DToC( mendmm )
    nl++
    // **    @ nl,3 SAY REPLICATE(CHR(196),33)
    nl++
    // ....v....1....v....2....v....3....v....4....v....5....v....6....v....7....v..
    // Jan      1234567.89    1234567.89    1234567.89    1234567.89    1234567.89
    @ nl, 3 SAY "Month     Total Pay    PAYE Total    S/Loan Dedn   C/Supp Dedn"
    // ** @ nl,68 SAY "Other Dedn"
    nl++
    // **   @ nl,3 SAY REPLICATE( Chr( 196 ),76 )
    nl++
    ntotPay := nPaye := nDedSL := nChildSup := 0
    nNT_Spec1 := nTax_Spec1 := nSpec_Pay3 := 0
    SELECT Pmppjnl
    GOTO TOP
    IF LastRec() != 0
        DO WHILE Pmppjnl->( !Eof() )
            IF Pmppjnl->Pay_Per < mstmm
                SKIP ALIAS Pmppjnl
                LOOP
            ENDIF
            IF Pmppjnl->Pay_Per > mendmm
                SKIP ALIAS Pmppjnl
                LOOP
            ENDIF
            IF SubStr( DToS( Pmppjnl->Pay_Per ), 1, 4 ) != dyy
                SKIP ALIAS Pmppjnl
                LOOP
            ENDIF
            dmm     := SubStr( DToS( Pmppjnl->Pay_Per ), 5, 2 )
            dmonth  := CMonth( Pmppjnl->Pay_Per )
            ntotPay := nPaye := nDedSL := nDedcs := nDeb3 := 0
            DO WHILE SubStr( DToS( Pmppjnl->Pay_Per ), 5, 2 ) = dmm;
                    .AND. Pmppjnl->( !Eof() )
                IF SubStr( DToS( PMPPJNL->Pay_Per ), 1, 4 ) != dyy
                    SKIP ALIAS Pmppjnl
                    LOOP
                ENDIF
                nTotHrs    += Pmppjnl->TotHrs
                nTotHol    += Pmppjnl->HolHours
                nTotSick   += Pmppjnl->SickHrs
                nTotPay    += Pmppjnl->GrossPay
                nPaye      += Pmppjnl->Paye
                nDedSL     += Pmppjnl->DedSL
                nChildSup  += Pmppjnl->ChildSup
                nTax_Spec1 += Pmppjnl->Tax_Spec1
                nSpec_Pay3 += Pmppjnl->Spec_Pay3
                nNT_Spec1  += Pmppjnl->NT_Spec1
                SKIP ALIAS Pmppjnl
            ENDDO
            @ nl, 3 SAY dmonth
            @ nl, 12 SAY nTotPay   PICTURE "999,999.99"
            @ nl, 26 SAY nPaye     PICTURE "999,999.99"
            @ nl, 40 SAY nDedSL    PICTURE "999,999.99"
            @ nl, 54 SAY nChildSup PICTURE "999,999.99"
            nl++
            nGrTotPay    += nTotPay
            nTotPaye     += nPaye
            nTotDedSL    += nDedSL
            nTotChildSup += nChildSup
        ENDDO             // EOF Pmppjnl
    ENDIF                // LastRec
    // *** @ nl,11 SAY REPLICATE( CHR( 196 ),68 )
    nl++
    @ nl, 3 SAY "Totals:"
    @ nl, 12 SAY nGrTotPay    PICTURE "999,999.99"
    @ nl, 26 SAY nTotPaye     PICTURE "999,999.99"
    @ nl, 40 SAY nTotDedsl    PICTURE "999,999.99"
    @ nl, 54 SAY nTotChildSup PICTURE "999,999.99"
    nl++
    @ nl, 12 SAY nNT_Spec1    PICTURE "$99,999.99"
    @ nl, 26 SAY nTax_Spec1   PICTURE "$99,999.99"
    @ nl, 37 SAY nSpec_Pay3   PICTURE "$99,999.99"
    nl += 2
    @ nl, 3 SAY "Total Hrs" + Str( nTotHrs ) + " Holiday " + Str( nTotHol );
        + " Sick " + Str( nTotSick )
    nl++
    IF mwhere = "P"
        EndPrint()
    ELSE
        Inkey( 0 )
    ENDIF
    SET INDEX TO Pmppjnl

    RETURN NIL

// *  End Function  --  Y2DPAY

// **------------------------------------------------------------------------

FUNCTION PmpHd()

    @  2, 17 SAY Day( mstmm ) -6 PICTURE "99"
    @  2, 23 SAY Day( mstmm ) -5 PICTURE "99"
    @  2, 29 SAY Day( mstmm ) -4 PICTURE "99"
    @  2, 35 SAY Day( mstmm ) -3 PICTURE "99"
    @  2, 41 SAY Day( mstmm ) -2 PICTURE "99"
    @  2, 47 SAY Day( mstmm ) -1 PICTURE "99"
    @  2, 53 SAY Day( mstmm )   PICTURE "99"
    @  3, 17 SAY SubStr( Months->Day1, 1, 3 ) + "   " + ;
        SubStr( Months->Day2, 1, 3 ) + "   " + ;
        SubStr( Months->Day3, 1, 3 ) + "   " + ;
        SubStr( Months->Day4, 1, 3 ) + "   " + ;
        SubStr( Months->Day5, 1, 3 ) + "   " + ;
        SubStr( Months->Day6, 1, 3 ) + "   " + ;
        SubStr( Months->Day7, 1, 3 )

    RETURN NIL
// **------ EOF PmpHd()

// ***--------------------------------------------------------------------------

FUNCTION NameHol( mcodeno )   // Display Holiday to date

    SELECT Months
    GOTO TOP
    mstmm  := Date() -6
    mendmm := Date()
    Scroll( 16, 2, 19, 78 )
    @ 17, 3      SAY "From Date" GET mstmm   PICTURE "99/99/9999"
    @ 17, Col() + 2 SAY "To Date"   GET mendmm  PICTURE "99/99/9999"
    READ
    IF PressedEsc()
        RETURN NIL
    ENDIF
    mwhere := "S"

    Printsel( mwhere )

    IF mwhere = "P"
        npl := 63
    ELSE
        npl := 22
    ENDIF
    @  0, 4 SAY Control->U_Name
    @  0, 59 SAY Str( Day(  Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 0 SAY SubStr( Name->Name, 1, 30 )
    @  2, 36 SAY "Pay for period ";
        + " " + SubStr( DToC( mstmm ),  1, 2 );
        + "/" + SubStr( DToC( mstmm ),  4, 2 );
        + "/" + SubStr( DToC( mstmm ),  7, 4 );
        + " To " + SubStr( DToC( mendmm ), 1, 2 );
        + "/" + SubStr( DToC( mendmm ), 4, 2 );
        + "/" + SubStr( DToC( mendmm ), 7, 4 )

    @  4, 17 SAY SubStr( Months->Day1, 1, 3 ) + "    " + ;
        SubStr( Months->Day2, 1, 3 ) + "    " + ;
        SubStr( Months->Day3, 1, 3 ) + "    " + ;
        SubStr( Months->Day4, 1, 3 ) + "    " + ;
        SubStr( Months->Day5, 1, 3 ) + "    " + ;
        SubStr( Months->Day6, 1, 3 ) + "    " + ;
        SubStr( Months->Day7, 1, 3 )
    nl := 5
    nHolTot := nSickTot := nDayHol := nDaySick := 0
    SELECT PMPPJNL
    GOTO TOP
    SEEK mcodeno
    DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !Eof() )
        IF Pmppjnl->Pay_Per < mstmm
            SKIP ALIAS Pmppjnl
            LOOP
        ENDIF
        IF Pmppjnl->Pay_Per > mendmm
            SKIP ALIAS Pmppjnl
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere = "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            nl := 0
        ENDIF                // npl
        nDayHol := nDaySick := 0
        nDayHol :=  Pmppjnl->Day1Hol + Pmppjnl->Day2Hol + Pmppjnl->Day3Hol + Pmppjnl->Day4Hol;
            + Pmppjnl->Day5Hol + Pmppjnl->Day6Hol + Pmppjnl->Day7Hol
        nDaySick := Pmppjnl->Day1Sick + Pmppjnl->Day2Sick + Pmppjnl->Day3Sick;
            + Pmppjnl->Day4Sick;
            + Pmppjnl->Day5Sick + Pmppjnl->Day6Sick + Pmppjnl->Day7Sick
        IF nDayHol > 0 .OR. nDaySick > 0
            @ nl, ncol SAY Pmppjnl->Pay_Per
            nl++
        ENDIF
        IF nDayHol > 0
            nHolTot += nDayHol
            @ nl, 1 SAY Pmppjnl->HolRate PICTURE "$99.99"
            @ nl, 10 SAY "Hol   " + Str( Pmppjnl->Day1Hol );
                + "  " + Str( Pmppjnl->Day2Hol );
                + "  " + Str( Pmppjnl->Day3Hol );
                + "  " + Str( Pmppjnl->Day4Hol );
                + "  " + Str( Pmppjnl->Day5Hol );
                + "  " + Str( Pmppjnl->Day6Hol );
                + "  " + Str( Pmppjnl->Day7Hol )
            @ nl, 65 SAY nDayHol PICTURE "99.99"
            nl++
        ENDIF
        IF nDaySick > 0
            nSickTot += nDaySick
            @ nl, 10 SAY "      " + Str( Pmppjnl->Day1Sick ) + Pmppjnl->Day1S_B;
                + " " + Str( Pmppjnl->Day2Sick ) + Pmppjnl->Day2S_B;
                + " " + Str( Pmppjnl->Day3Sick ) + Pmppjnl->Day3S_B;
                + " " + Str( Pmppjnl->Day4Sick ) + Pmppjnl->Day4S_B;
                + " " + Str( Pmppjnl->Day5Sick ) + Pmppjnl->Day5S_B;
                + " " + Str( Pmppjnl->Day6Sick ) + Pmppjnl->Day6S_B;
                + " " + Str( Pmppjnl->Day7Sick ) + Pmppjnl->Day7S_B
            @ nl, 65 SAY nDaySick PICTURE "99.99"
            nl++
        ENDIF
        SKIP ALIAS Pmppjnl
    ENDDO               // EOF Pmppjnl
    nl++
    @ nl, 0 SAY Replicate( "_", 79 )
    nl += 2
    @ nl, 10 SAY "Total Holidays      Total Sick"
    nl++
    @ nl, 14 SAY nHolTot  PICTURE "999.99"
    @ nl, 30 SAY nSickTot PICTURE "999.99"
    nl++
    IF mwhere = "S"
        IF nl > 16
            WAIT
            Scroll()
            nl := 0
        ENDIF
    ENDIF
    nl++
    IF mwhere = "P"
        EndPrint()
        Scroll()
    ELSE
        WAIT
        Scroll()
    ENDIF

    RETURN mcodeno

// *---  End Function NameHol

// **---------------------------------------------------------------------------

FUNCTION WeekTime()

    nHours := netpay := ntotpay := nTotTH := nHrsTH := 0
    mstmm := Date()
    SELECT Months
    GOTO TOP
    @ 10, 34 SAY "Period Ending Day " + Months->Day7
    @ 11, 53 GET mstmm   PICTURE "99/99/9999"
    READ
    IF PressedEsc()
        RETURN NIL
    ENDIF
    mwhere := "S"

    Printsel( mwhere )

    IF mwhere = "P"
        npl := 56
    ELSE
        npl := 20
        Scroll()
    ENDIF
    @  0, 0 SAY SubStr( Control->U_Name, 1, 35 )
    @  0, 34 SAY "Pay for period To ";
        + " " + SubStr( DToC( mstmm ),  1, 2 );
        + "/" + SubStr( DToC( mstmm ),  4, 2 );
        + "/" + SubStr( DToC( mstmm ),  7, 4 )
    PmpHd()                                        // ABOVE
    nl := 5
    nTotHours := ntothrs := ntotGross := ntotPaye := ntotNett := netPay := 0
    SELECT Name
    SELECT PMPPjnl
    SET RELATION TO Codeno INTO Name
    GO TOP
    DO WHILE Pmppjnl->( !Eof() )
        IF Pmppjnl->Pay_Per < mstmm
            SKIP ALIAS Pmppjnl
            LOOP
        ENDIF
        IF Pmppjnl->Pay_Per > mstmm + 6
            SKIP ALIAS Pmppjnl
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere = "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            nl := 0
        ENDIF                // npl
        mcodeno := Pmppjnl->Codeno
        @ nl, 6 SAY Name->Name
        // **   @ nl,61 SAY Pmppjnl->Pay_Per
        // **   nl++
   /*
   Taken Out
      IF Pmppjnl->HolRate > 0
         @ nl, 2 SAY "Holiday"
         @ nl,12 SAY Pmppjnl->HolRate  PICTURE "$99.99"
         @ nl,19 SAY Pmppjnl->HolHours PICTURE "999.99"
      ENDIF
      @ nl,26 SAY PMPPjnl->TotHrs   PICTURE "999.99"
      @ nl,34 SAY "Hrs @"
      @ nl,40 SAY Pmppjnl->Payrate  PICTURE "$999.99"
   Taken Out
   */
        @ nl, 57 SAY "Gross"
        @ nl, 64 SAY Pmppjnl->GrossPay PICTURE "$9,999.99"
        IF Pmppjnl->ProdBon > 0
            nl++
            @ nl, 4 SAY "Gross Incl"
            @ nl, 16 SAY "Bonus"
            @ nl, 22 SAY Pmppjnl->ProdBon  PICTURE "$9,999.99"
        ENDIF
        IF Pmppjnl->Tax_Spec1 > 0
            nl++
            @ nl, 4 SAY "Gross Incl"
            @ nl, 16 SAY Name->TaxDesc1
            @ nl, 32 SAY Pmppjnl->Tax_Spec1  PICTURE "$9,999.99"
        ENDIF
        IF Pmppjnl->Spec_Pay3 > 0                    // Taxable Now
            nl++
            @ nl, 34 SAY Name->SpecDesc3
            @ nl, 51 SAY Pmppjnl->Spec_Pay3 PICTURE "$9,999.99"
        ENDIF
        nl++
        @ nl, 8 SAY Name->Refno
        @ nl, 57 SAY "Paye"
        @ nl, 64 SAY PMPPjnl->Paye     PICTURE "$9,999.99"
        netpay := Pmppjnl->GrossPay - Pmppjnl->Paye
        // **   @ nl,64 SAY netpay            PICTURE "$9,999.99"
        IF PMPPjnl->DedSL > 0
            nl++
            @ nl, 34 SAY "S/Loan"
            @ nl, 51 SAY PMPPjnl->Dedsl PICTURE "$9,999.99"
            netpay -= PMPPjnl->DedSL
            @ nl, 64 SAY netpay         PICTURE "$9,999.99"
        ENDIF
        IF Pmppjnl->ChildSup > 0
            nl++
            @ nl, 34 SAY "Child"
            @ nl, 51 SAY Pmppjnl->ChildSup PICTURE "$9,999.99"
            netpay -= PMPPjnl->ChildSup
            @ nl, 64 SAY netpay            PICTURE "$9,999.99"
        ENDIF
        IF Pmppjnl->NT_Spec1 > 0
            nl++
            @ nl, 34 SAY Name->NTDesc1
            @ nl, 51 SAY Pmppjnl->NT_Spec1  PICTURE "$9,999.99"
            netpay += Pmppjnl->NT_Spec1
            @ nl, 64 SAY netpay             PICTURE "$9,999.99"
        ENDIF
        IF PMPPjnl->NTH_Allce > 0
            nl++
            @ nl, 34 SAY "Hr Non Tax Allce"
            @ nl, 51 SAY PMPPjnl->NTH_Allce PICTURE "$9,999.99"
            netpay += PMPPjnl->NTH_Allce
            @ nl, 64 SAY netpay             PICTURE "$9,999.99"
        ENDIF
        IF PMPPjnl->N_T_Allce > 0
            nl++
            @ nl, 34 SAY "Non Tax Allce"
            @ nl, 51 SAY PMPPjnl->N_T_Allce PICTURE "$9,999.99"
            netpay += PMPPjnl->N_T_Allce
            @ nl, 64 SAY netpay             PICTURE "$9,999.99"
        ENDIF
        IF Pmppjnl->Spec_Pay > 0
            nl++
            @ nl, 34 SAY Name->SpecDesc
            @ nl, 51 SAY Pmppjnl->Spec_Pay  PICTURE "$9,999.99"
            netpay -= Pmppjnl->Spec_Pay
            @ nl, 64 SAY netpay             PICTURE "$9,999.99"
        ENDIF
        IF Pmppjnl->Spec_Pay1 > 0
            nl++
            @ nl, 34 SAY Name->SpecDesc1
            @ nl, 51 SAY Pmppjnl->Spec_Pay1  PICTURE "$9,999.99"
            netpay -= Pmppjnl->Spec_Pay1
            @ nl, 64 SAY netpay             PICTURE "$9,999.99"
        ENDIF
        IF Pmppjnl->Spec_Pay2 > 0
            nl++
            @ nl, 34 SAY Name->SpecDesc2
            @ nl, 51 SAY Pmppjnl->Spec_Pay2 PICTURE "$9,999.99"
            netpay -= Pmppjnl->Spec_Pay2
            @ nl, 64 SAY netpay             PICTURE "$9,999.99"
        ENDIF
        IF PMPPjnl->KiwiSave > 0
            nl++
            @ nl, 34 SAY "KiwiSave"
            @ nl, 51 SAY PMPPjnl->KiwiSave PICTURE "$9,999.99"
            netpay -= PMPPjnl->KiwiSave
            @ nl, 64 SAY netpay            PICTURE "$9,999.99"
        ENDIF
        IF PMPPjnl->KiwiEmpl > 0
            nl++
            @ nl, 34 SAY "Kiwi Empl"
            @ nl, 51 SAY PMPPjnl->KiwiEmpl PICTURE "$9,999.99"
            // **      netpay -= PMPPjnl->KiwiSave
            // **      @ nl,64 SAY netpay            PICTURE "$9,999.99"
        ENDIF
        nl++                                                    // line 10/24/38/52
        @ nl, 57 SAY "Nett"
        @ nl, 64 SAY netpay PICTURE "$9,999.99"
        nl++
   /*
      @ nl,17 SAY PMPPjnl->Payrate PICTURE "99.99"
      IF lspallce
         @ nl,32 SAY "+ Sickness Allce 2%"
      ENDIF
      @ nl,53 SAY PMPPJNL->( Basepay+S_P_Allce ) PICTURE "9999.99"
      nl++                                                     // line 7/21/35/49
      IF PMPPjnl->Dedsl >0
         @ nl,17 SAY "S/Loan $"
         @ nl,25 SAY PMPPjnl->Dedsl PICTURE "999.99"
         @ nl,31 SAY " + "
      ENDIF
      @ nl,60 SAY "Gross"
      @ nl,70 SAY PMPPjnl->GrossPay PICTURE "9999.99"
      ***   @ nl,70 SAY PMPPjnl->Basepay PICTURE "9999.99"
      nl++
      @ nl, 2 SAY Name->Refno
      @ nl,60 SAY "Paye"
      @ nl,70 SAY PMPPjnl->Paye    PICTURE "9999.99"
      nl++
      ***   netpay := PMPPjnl->( ( Basepay+S_P_Allce )-( Paye+Dedsl ) )
      @ nl,28 SAY "Not Including Allow/Deductions etc Total"
      @ nl,70 SAY Pmppjnl->GrossPay-Pmppjnl->Paye PICTURE "9999.99"
      nl++
   */
        nTotHours += Pmppjnl->Hours
        nHrsTH    += Pmppjnl->HrsTH
        ntotGross += Pmppjnl->GrossPay
        ntotPaye  += Pmppjnl->Paye
        ntotNett  += NetPay
        // **   nl++
        @ nl, 9 SAY "Std Hrs" + Str( Pmppjnl->Day1 );
            + "  " + Str( Pmppjnl->Day2 );
            + "  " + Str( Pmppjnl->Day3 );
            + "  " + Str( Pmppjnl->Day4 );
            + "  " + Str( Pmppjnl->Day5 );
            + "  " + Str( Pmppjnl->Day6 );
            + "  " + Str( Pmppjnl->Day7 )
        @ nl, 64 SAY Pmppjnl->Hours PICTURE "999.99"
        IF Pmppjnl->HrsTH > 0
            nl++
            @ nl, 10 SAY "Hrs TH" + Str( Pmppjnl->Day1TH );
                + "  " + Str( Pmppjnl->Day2TH );
                + "  " + Str( Pmppjnl->Day3TH );
                + "  " + Str( Pmppjnl->Day4TH );
                + "  " + Str( Pmppjnl->Day5TH );
                + "  " + Str( Pmppjnl->Day6TH );
                + "  " + Str( Pmppjnl->Day7TH )
            @ nl, 64 SAY Pmppjnl->HrsTH PICTURE "999.99"
        ENDIF                    // nHrsTH > 0
        IF Pmppjnl->HolHours > 0
            nl++
            @ nl, 1 SAY Pmppjnl->HolRate PICTURE "$99.99"
            @ nl, 10 SAY "Hol   " + Str( Pmppjnl->Day1Hol );
                + "  " + Str( Pmppjnl->Day2Hol );
                + "  " + Str( Pmppjnl->Day3Hol );
                + "  " + Str( Pmppjnl->Day4Hol );
                + "  " + Str( Pmppjnl->Day5Hol );
                + "  " + Str( Pmppjnl->Day6Hol );
                + "  " + Str( Pmppjnl->Day7Hol )
            @ nl, 64 SAY Pmppjnl->HolHours PICTURE "999.99"
        ENDIF
        IF Pmppjnl->SickTotal > 0
            nl++
            @ nl, 10 SAY "      " + Str( Pmppjnl->Day1Sick ) + Pmppjnl->Day1S_B;
                + " " + Str( Pmppjnl->Day2Sick ) + Pmppjnl->Day2S_B;
                + " " + Str( Pmppjnl->Day3Sick ) + Pmppjnl->Day3S_B;
                + " " + Str( Pmppjnl->Day4Sick ) + Pmppjnl->Day4S_B;
                + " " + Str( Pmppjnl->Day5Sick ) + Pmppjnl->Day5S_B;
                + " " + Str( Pmppjnl->Day6Sick ) + Pmppjnl->Day6S_B;
                + " " + Str( Pmppjnl->Day7Sick ) + Pmppjnl->Day7S_B
            @ nl, 64 SAY Pmppjnl->SickTotal PICTURE "999.99"
        ENDIF
        nl++
        @ nl, 3 SAY Replicate( "-", 68 )
        nl++
        SKIP ALIAS Pmppjnl
    ENDDO                   // EOF()
    nl++
    @ nl, 0 SAY "Std Hrs"
    @ nl, 11 SAY nTotHours  PICTURE "9,999.99"
    @ nl, 20 SAY "Gross"
    @ nl, 27 SAY nTotGross  PICTURE "$99,999.99"
    @ nl, 40 SAY "Paye"
    @ nl, 45 SAY nTotPaye   PICTURE "$99,999.99"
    @ nl, 57 SAY "Total"
    @ nl, 63 SAY nTotNett   PICTURE "$99,999.99"
    nl++
    IF nHrsTH > 0
        @ nl, 0 SAY "Hrs+1/2"
        @ nl, 11 SAY nHrsTH PICTURE "9999.99"
        @ nl, 20 SAY "Total Hrs"
        @ nl, 30 SAY nTotHours + ( nHrsTH / 1.5 ) PICTURE "9999.99"
    ENDIF
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

    SELECT PMPPjnl
    SET RELATION TO

    RETURN NIL

// **-----  End Program  --  METSLIP  **

// **--------------------------------------------------------------------------

FUNCTION DISPPAY( mcodeno )   // Display pay to date

    LOCAL nhrs := npay := ntax := ndedsl := 0
    LOCAL chdg := "Date           Gross       Paye     S/L"
    LOCAL nHolHours := nSickHours := nProdBon := nChildSup := nSpec_Pay := 0
    LOCAL nKiwiSave := nkiwiempl := 0
    LOCAL nSpec_Pay1 := nSpec_Pay2 := nSpec_Pay3 := nHrsTH := 0

    SELECT Months
    GOTO TOP
    mstmm  := Date() -7
    mendmm := Date()
    @ 19, 3      SAY "From Date" GET mstmm   PICTURE "99/99/9999"
    @ 19, Col() + 2 SAY "To Date"   GET mendmm  PICTURE "99/99/9999"
    READ
    IF PressedEsc()
        RETURN NIL
    ENDIF
    mwhere := "S"

    Printsel( mwhere )

    IF mwhere = "P"
        npl := 63
    ELSE
        npl := 22
    ENDIF
    ncol := 3
    @  0, 0 SAY Control->U_Name                 // 35
    @  0, 37 SAY "Staff Pay/Day Report"
    @  0, 60 SAY Str( Day(  Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 0 SAY SubStr( Name->Name, 1, 30 )
    @  2, 34 SAY "Pay for period ";
        + " " + SubStr( DToC( mstmm ),  1, 2 );
        + "/" + SubStr( DToC( mstmm ),  4, 2 );
        + "/" + SubStr( DToC( mstmm ),  7, 4 );
        + " To " + SubStr( DToC( mendmm ), 1, 2 );
        + "/" + SubStr( DToC( mendmm ), 4, 2 );
        + "/" + SubStr( DToC( mendmm ), 7, 4 )
    @  4, 17 SAY SubStr( Months->Day1, 1, 3 ) + "    " + ;
        SubStr( Months->Day2, 1, 3 ) + "    " + ;
        SubStr( Months->Day3, 1, 3 ) + "    " + ;
        SubStr( Months->Day4, 1, 3 ) + "    " + ;
        SubStr( Months->Day5, 1, 3 ) + "    " + ;
        SubStr( Months->Day6, 1, 3 ) + "    " + ;
        SubStr( Months->Day7, 1, 3 )
    nl := 5
    nDayTH := nDay := 0
    nTax_Spec1 := nNT_Spec1 := 0
    SELECT PMPPJNL
    GOTO TOP
    SEEK mcodeno
    DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !Eof() )
        IF Pmppjnl->Pay_Per < mstmm
            SKIP ALIAS Pmppjnl
            LOOP
        ENDIF
        IF Pmppjnl->Pay_Per > mendmm
            SKIP ALIAS Pmppjnl
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere = "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            nl := 0
        ENDIF                // npl
        // **  @ nl,ncol SAY SUBSTR( DTOC( Pay_Per ), 1, 5 )
        @ nl, ncol SAY chdg
        nl++
        @ nl, ncol    SAY DToC( Pmppjnl->Pay_Per )
        @ nl, ncol + 14 SAY Pmppjnl->GrossPay PICTURE "$9,999.99"
        // **  @ nl,ncol+14 SAY ( Pmppjnl->Basepay+Pmppjnl->S_P_Allce ) PICTURE "$9,999.99"
        @ nl, ncol + 26 SAY Pmppjnl->Paye    PICTURE "$999.99"
        IF Dedsl > 0
            @ nl, ncol + 31 SAY Pmppjnl->Dedsl PICTURE "$999.99"
        ENDIF
        nl++
        IF Pmppjnl->ProdBon > 0
            @ nl, 5 SAY "Bonus"
            @ nl, 13 SAY Pmppjnl->ProdBon
        ENDIF
        IF Pmppjnl->ChildSup > 0
            @ nl, 22 SAY "Child"
            @ nl, 30 SAY Pmppjnl->ChildSup
        ENDIF
        IF nSpec_Pay > 0 .OR. nSpec_Pay2 > 0 .OR. nSpec_Pay3 > 0
            nl++
            @ nl, 0 SAY Name->SpecDesc
            @ nl, 16 SAY nSpec_Pay  PICTURE "$9,999.99"
            @ nl, 27 SAY Name->SpecDesc2
            @ nl, 43 SAY nSpec_Pay2 PICTURE "$9,999.99"
            @ nl, 54 SAY Name->SpecDesc3
            @ nl, 70 SAY nSpec_Pay3 PICTURE "$9,999.99"
        ENDIF
        nl++
        nDay := Pmppjnl->Day1 + Pmppjnl->Day2 + Pmppjnl->Day3 + Pmppjnl->Day4;
            + Pmppjnl->Day5 + Pmppjnl->Day6 + Pmppjnl->Day7
        @ nl, 6 SAY "Hrs Std   " + Str( Pmppjnl->Day1 );
            + "  " + Str( Pmppjnl->Day2 );
            + "  " + Str( Pmppjnl->Day3 );
            + "  " + Str( Pmppjnl->Day4 );
            + "  " + Str( Pmppjnl->Day5 );
            + "  " + Str( Pmppjnl->Day6 );
            + "  " + Str( Pmppjnl->Day7 )
        @ nl, 64 SAY nDay PICTURE "999.99"
        nl++
        nDayTH := Pmppjnl->Day1TH + Pmppjnl->Day2TH + Pmppjnl->Day3TH + Pmppjnl->Day4TH;
            + Pmppjnl->Day5TH + Pmppjnl->Day6TH + Pmppjnl->Day7TH
        IF nDayTH > 0
            @ nl, 10 SAY "T+1/2 " + Str( Pmppjnl->Day1TH );
                + "  " + Str( Pmppjnl->Day2TH );
                + "  " + Str( Pmppjnl->Day3TH );
                + "  " + Str( Pmppjnl->Day4TH );
                + "  " + Str( Pmppjnl->Day5TH );
                + "  " + Str( Pmppjnl->Day6TH );
                + "  " + Str( Pmppjnl->Day7TH )
            @ nl, 64 SAY nDayTH     PICTURE "999.99"
            @ nl, 72 SAY nDayTH * 1.5 PICTURE "999.99"
            nl++
        ENDIF
        IF Pmppjnl->HolHours > 0
            @ nl, 1 SAY Pmppjnl->HolRate PICTURE "$99.99"
            @ nl, 10 SAY "Hols  " + Str( Pmppjnl->Day1Hol );
                + "  " + Str( Pmppjnl->Day2Hol );
                + "  " + Str( Pmppjnl->Day3Hol );
                + "  " + Str( Pmppjnl->Day4Hol );
                + "  " + Str( Pmppjnl->Day5Hol );
                + "  " + Str( Pmppjnl->Day6Hol );
                + "  " + Str( Pmppjnl->Day7Hol )
            @ nl, 64 SAY Pmppjnl->HolHours PICTURE "999.99"
            nl++
        ENDIF
        IF Pmppjnl->SickTotal > 0
            @ nl, 10 SAY "      " + Str( Pmppjnl->Day1Sick ) + Pmppjnl->Day1S_B;
                + " " + Str( Pmppjnl->Day2Sick ) + Pmppjnl->Day2S_B;
                + " " + Str( Pmppjnl->Day3Sick ) + Pmppjnl->Day3S_B;
                + " " + Str( Pmppjnl->Day4Sick ) + Pmppjnl->Day4S_B;
                + " " + Str( Pmppjnl->Day5Sick ) + Pmppjnl->Day5S_B;
                + " " + Str( Pmppjnl->Day6Sick ) + Pmppjnl->Day6S_B;
                + " " + Str( Pmppjnl->Day7Sick ) + Pmppjnl->Day7S_B
            @ nl, 64 SAY Pmppjnl->SickTotal PICTURE "999.99"
            nl++
        ENDIF
        @ nl, 0 SAY "----------------------------------------------------------------"
        nl++
        nhrs       += Pmppjnl->Hours
        npay       += Pmppjnl->GrossPay
        // **  npay       += Pmppjnl->Basepay+Pmppjnl->S_P_Allce
        ntax       += Pmppjnl->Paye
        ndedsl     += Pmppjnl->Dedsl
        nHolHours  += Pmppjnl->HolHours
        nSickHrs   += Pmppjnl->SickHrs
        nProdBon   += Pmppjnl->ProdBon
        nSpec_Pay  += Pmppjnl->Spec_Pay
        nSpec_Pay1 += Pmppjnl->Spec_Pay1
        nSpec_Pay2 += Pmppjnl->Spec_Pay2
        nSpec_Pay3 += Pmppjnl->Spec_Pay3
        nHrsTH     += Pmppjnl->HrsTH
        nTax_Spec1 += Pmppjnl->Tax_Spec1
        nNT_Spec1  += Pmppjnl->NT_Spec1
        nKiwiSave  += Pmppjnl->KiwiSave
        nKiwiEmpl  += Pmppjnl->KiwiEmpl
        SKIP ALIAS Pmppjnl
    ENDDO               // EOF Pmppjnl
    IF mwhere = "S"
        IF nl > 16
            WAIT
            Scroll()
            nl := 0
        ENDIF
    ENDIF
    nl++
    @ nl, 2 SAY "Std Hours"
    @ nl, 14 SAY nhrs PICTURE "9,999.99"
    @ nl, 26 SAY "Gross"
    @ nl, 33 SAY npay PICTURE "$99,999.99"
    @ nl, 46 SAY "Paye"
    @ nl, 52 SAY ntax PICTURE "$99,999.99"
    IF nHrsTH > 0
        nl++
        @ nl, 2 SAY "Time+1/2"
        @ nl, 17 SAY nHrsTH      PICTURE "9,999.99"
        @ nl, 27 SAY "Total Hrs"
        @ nl, 37 SAY nHrs + nHrsTH PICTURE "9,999.99"
    ENDIF
    IF ndedsl > 0
        nl++
        @ nl, 3 SAY "Total Student Loan"
        @ nl, 23 SAY ndedsl PICTURE "$9,999.99"
    ENDIF
    nl++
    IF nHolHours > 0
        @ nl, 3 SAY "Hol Hrs"
        @ nl, 11 SAY nHolHours PICTURE "9,999.99"
    ENDIF
    IF nSickHrs > 0
        @ nl, 22 SAY "Sick Hrs"
        @ nl, 32 SAY nSickHrs PICTURE "9,999.99"
    ENDIF
    IF nProdBon > 0
        @ nl, 43   SAY "Prod Bonus"
        @ nl, 54 SAY nProdBon PICTURE "$9,999.99"
    ENDIF
    IF nTax_Spec1 > 0
        nl++
        @ nl, 3 SAY "Tax Spec"
        @ nl, 14 SAY nTax_Spec1 PICTURE "$9,999.99"
    ENDIF
    IF nSpec_Pay3 > 0
        nl++
        @ nl, 3 SAY "Taxable"
        @ nl, 14 SAY nSpec_Pay3 PICTURE "$9,999.99"
    ENDIF
    IF nNT_Spec1 > 0
        nl++
        @ nl, 3 SAY "Non Tax Spec"
        @ nl, 16 SAY nNT_Spec1 PICTURE "$9,999.99"
    ENDIF
    IF nkiwisave > 0
        nl++
        @ nl, 3 SAY "Kiwi Save"
        @ nl, 16 SAY nkiwisave PICTURE "$9,999.99"
    ENDIF
    IF nkiwiempl > 0
        nl++
        @ nl, 3 SAY "Kiwi Empl"
        @ nl, 16 SAY nkiwisave PICTURE "$9,999.99"
    ENDIF
    nl++
    @ nl, 3 SAY Name->Desc
    nl++
    @ nl, 3 SAY Name->Desc1
    nl++
    @ nl, 3 SAY Name->Desc2
    nl++
    @ nl, 3 SAY Name->Desc3
    nl++
    IF mwhere = "P"
        EndPrint()
        Scroll()
    ELSE
        WAIT
        Scroll()
    ENDIF

    RETURN mcodeno

// *---  End Function DISPPAY

// **---------------  END OF PMPTIME1.PRG
