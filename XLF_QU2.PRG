// **  JoKir09 25-09-11 10:38:34

/*
   Program.....:                  XLF_QU2.PRG
   Authors.....: J.Kirby
   Date........: 05/10/1995
   Functions...: QuotProf, QuotPAdd, QuotPrice, QuotHead
   Static funcs: QuotIndi, QuotJIT

   THIS IS FOR INVOICE WORK ORDERS
*/

FUNCTION QuotProf()
    local discountAmount
    
    Scroll()
    DispBox( 0, 1, 18, 79, 2 )
    @  1, 20 SAY "Quote Analysis"
    mstmm  := Date() -30
    mendmm := Date()
    @ 10, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
    @ 11, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
    READ
    IF PressedEsc()
        RETURN NIL
    ENDIF
    mok := "Y"
    // ** ApGetY( "Do you want each Part Printed" )
    IF PressedEsc()
        RETURN NIL
    ENDIF
    mwhere   := "S"

    Printsel( mwhere )

    nl := 0
    IF mwhere == "P"
        npl := 55
    ELSE
        Scroll()
        npl := 16
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0, 34 SAY mstmm
    @  0, 47 SAY mendmm
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 0 SAY "Name"
    @  2, 43 SAY "Qty"
    @  2, 52 SAY "Cost"
    @  2, 61 SAY "Amount"
    @  2, 71 SAY "%"
    nl := 4
    ncostitem := mA := nsale := 0
    SELECT Quot
    SET ORDER TO 2
    GOTO TOP
    DO WHILE Quot->( !Eof() )
        IF Quot->DbDate < mstmm
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF Quot->DbDate > mendmm
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF                       // mwhere = P
            @  0, 0 SAY Control->U_Name
            @  0, 34 SAY mstmm
            @  0, 47 SAY mendmm
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  2, 0 SAY "Name"
            @  2, 43 SAY "Qty"
            @  2, 52 SAY "Cost"
            @  2, 61 SAY "Amount"
            @  2, 71 SAY "%"
            nl := 4
        ENDIF                          // nl>npl
        mcodeno := Quot->Codeno
        SELECT Name
        SEEK mcodeno
        @ nl, 0 SAY Name->Name
        nl++
        ntrade := namount := ncost := 0
        SELECT Quot
        // **   GOTO TOP
        // **   SEEK mcodeno
        // **  IF FOUND()
        DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !Eof() )
            IF Quot->DbDate < mstmm
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF Quot->DbDate > mendmm
                SKIP ALIAS Quot
                LOOP
            ENDIF
            SELECT Part
            SEEK Quot->Partnum
            SELECT Quot
            discountAmount := Quot->Amount * ( 1 -Quot->Discount / 100 )
            mA := ( ( discountAmount * 100 ) / 100 ) * Quot->Qty
            ntrade    := Part->Trade * Quot->Qty
            nsale     += mA
            ncostitem += ntrade
            namount   += mA
            ncost     += ntrade
            // **      IF mok = "Y"
            @ nl, 0 SAY Quot->DbDate
            @ nl, 12 SAY SubStr( Part->Partnum, 1, 8 )
            @ nl, 21 SAY SubStr( Part->Desc, 1, 20 )
            @ nl, 42 SAY Quot->Qty PICTURE "9,999.99"
            @ nl, 51 SAY ntrade    PICTURE "99,999.99"
            @ nl, 62 SAY mA        PICTURE "999,999.99"
            @ nl, 73 SAY ( ( mA - ntrade ) / mA ) * 100 PICTURE "9999 %"
            nl++
            // **      ENDIF
            mA := ntrade := 0
            SKIP ALIAS Quot
        ENDDO
        // **  ENDIF                   // Found()
        nl++
        @ nl, 36 SAY "Total"
        @ nl, 50 SAY ncost   PICTURE "9999,999.99"
        @ nl, 61 SAY namount PICTURE "9999,999.99"
        @ nl, 73 SAY ( ( namount - ncost ) / namount ) * 100 PICTURE "9999 %"
        nl++
        namount := ncost := 0
    ENDDO
    @  nl, 48 SAY "---------------------------"
    nl++
    @ nl, 30 SAY "GRAND TOTAL"
    @ nl, 49 SAY ncostitem PICTURE "$9999,999.99"
    @ nl, 61 SAY nsale     PICTURE "9999,999.99"
    nl++
    @ nl, 48 SAY "==========================="
    nl++
    @ nl, 49 SAY ( nsale ) -( ncostitem  )                 PICTURE "$999,999.99"
    @ nl, 59 SAY ( ( nsale - ncostitem ) / nsale ) * 100 PICTURE "9999 %"
    nl += 2
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

    SELECT Quot
    SET ORDER TO 1

    RETURN NIL

// ****** End of QuotProf()

// *---------------------------------------------------------------------*

FUNCTION QuotPAdd( mpartnum )

    IF mpartnum = Space( 20 )
        SELECT Part
        SET ORDER TO 1
        Scroll()
        Partfind( @mpartnum )                // XF_Part
        mpartnum := Part->Partnum
    ENDIF                            // mpartnum
    mpartnum := Part->Partnum
    SELECT Cusnotes
    coderef := Part->Partnum
    SEEK coderef
    IF Found()
        M2MemoFile( coderef )                      // XF_Memo2
      /*
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
      ENDIF                  // mok
      */
    ENDIF            // Found Memo
    SELECT Name
    SEEK Debit->Codeno
    mcodeno := Name->Codeno
    SELECT Part
    SET ORDER TO 1                  // Partnum
    SEEK mpartnum
    IF Found()
        SELECT Quot
        ApFLock( 3 )
        APPEND BLANK
        Quot->Partnum  := mpartnum
        Quot->Dbdate   := Date()
        Quot->Catno    := Part->Catno
        Quot->Cost     := Part->Trade
        Quot->Amount   := Part->Wholesale
        Quot->Ordnum   := Name->Remarks
        Quot->Accepted := "Y"
        Quot->Codeno   := Debit->Codeno
        Quot->Invno    := Debit->Invno
        Quot->ModSeqno := Debit->Codeno + Debit->Invno + LTrim( Str( RecNo(), 4 ) )
        Quot->BranchId := Debit->BranchId
        UNLOCK
        SELECT Quot
        mok    := "N"
        DO WHILE mok = "N"
            QuotPrice( @mpartnum )                         // Below
            mok := ApGetY( Trim( Message->Correct ) )
        ENDDO
    ELSE
        Scroll()
    ENDIF

    RETURN mpartnum

// ***---- End of QuotPAdd()

// *-------------------------------------------------------------------

FUNCTION QuotPrice( mpartnum )

    SELECT Quot
    SET ORDER TO 3                 // Invno+Partnum
    SEEK Debit->Invno + mpartnum
    // **   SET ORDER TO 2                  // Codeno+BranchId+Partnum
    // **   SEEK Debit->Codeno+Debit->BranchId+mpartnum          // Find Part
    SET ORDER TO 1                 // Codeno
    Scroll()
    DispBox( 0, 1, 24, 79, 2 )
    @  1, 4      SAY Name->Name + " " + Name->Add1 + " " + Debit->BranchId
    @  3, 4      SAY Trim( Part->Partnum ) + "  " + Trim( Part->Desc )
    @  3, Col() + 2 SAY Debit->Invno COLOR "BG+"
    mpartnum := Part->Partnum
    SELECT Hist
    SEEK Name->Codeno + Part->Partnum
    nl := 4
    DO WHILE Hist->Codeno = Name->Codeno .AND. Hist->( !Eof() )
        IF Hist->PDate < Date() -365
            SKIP ALIAS Hist
            LOOP
        ENDIF
        // **      IF cbranchId != SPACE( 2 )
        // **         IF Hist->BranchId != cbranchId
        // **            SKIP ALIAS Hist
        // **            LOOP
        // **         ENDIF
        // **      ENDIF
        IF Hist->Partnum = Part->Partnum
            IF nl >= 8
                nl := 4
            ENDIF
            @ nl, 4      SAY "Last Qty"
            @ nl, Col() + 1 SAY Hist->Qty  PICTURE "99,999.99"
            @ nl, Col() + 2 SAY "Price"
            @ nl, Col() + 1 SAY Hist->Amount / ( 1 -Hist->Discount / 100 ) PICTURE "999,999.99"
            @ nl, Col() + 2 SAY "Disc"
            @ nl, Col() + 1 SAY Hist->Discount  PICTURE "999.99"
            @ nl, Col() + 2 SAY Hist->PDate
            nl++
        ENDIF
        SKIP ALIAS Hist
    ENDDO                    // Hist
    nl := 9
   /*
    DO CASE
       CASE SUBSTR( Part->Partnum, 1, 3 ) = "JC-"
         SELECT PART
          ApRLock( 3 )
         @ nl, 9 SAY "Desc" GET Part->Desc
          READ
         UNLOCK
         nl+=2
       CASE SUBSTR( Part->Partnum, 1, 3 ) = "QU-"
         SELECT PART
          ApRLock( 3 )
         IF Part->Desc = SPACE( 40 )
            Part->Desc := "As Per Quote "+Debit->WS+"                "
         ENDIF              // Part->Desc
         @ nl,16 SAY "Desc" GET Part->Desc
          READ
         UNLOCK
         nl+=2
   ENDCASE                  // Selected
   */
    nTimeTotal := nRateTotal := 0
    SELECT PartOper
    GOTO TOP
    SEEK mpartnum
    IF Found()
        DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !Eof() )
            nTimeTotal += PartOper->Time
            nRateTotal += PartOper->Rate * PartOper->Time
            SKIP ALIAS PartOper
        ENDDO                     // PartOper EOF
        IF nTimeTotal > 0
            @  nl, 4      SAY "Operation Time"
            @  nl, Col() + 1 SAY ntimetotal PICTURE "99,999.99" COLOR "BG+"
            @  nl, Col() + 1 SAY "Oper Costs"
            @  nl, Col() + 1 SAY nRateTotal PICTURE "99,999.99" COLOR "BG+"
            nl++
        ENDIF                    // nTimeTotal
    ENDIF                        // Found
    SELECT Equ
    mmodcode := SubStr( mpartnum, 1, 16 )  // This is if 20 Part #
    SET EXACT ON
    ntottrade := ntotwhol := 0
    ntottrade1 := ntotwhol1 := 0
    nrecno2 := nrecno3 := nrecno4 := 0
    nqty1 := nqty2 := nqty3 := nqty4 := 0
    nequ1 := nequ2 := nequ3 := nequ4 := 0
    mmod4 := mmod3 := mmod2 := Space( 16 )
    npl := 0
    GOTO TOP
    SEEK mmodcode                // Original Part
    IF Found()
        DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
            IF npl > 23
                Inkey( 1 )
                npl := 0
            ENDIF
            @ npl, 71 SAY SubStr( Equ->Partnum, 1, 9 ) COLOR "BG+"
            npl++
            SELECT Part
            SEEK Equ->Partnum
            SELECT Equ
            mmod2 := SubStr( Equ->Partnum, 1, 16 )
            nqty1 := Equ->Partqty
            nrecno2 := RecNo()
            GOTO TOP
            SEEK mmod2
            ntottrade1 += ( Part->Trade * nqty1 )
            ntotwhol1  += ( Part->Wholesale * nqty1 )
            IF !Found()
                ntottrade += ( Part->Trade * nqty1 )
                ntotwhol  += ( Part->Wholesale * nqty1 )
            ENDIF
            IF Found()
                DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                    SELECT Part
                    SEEK Equ->Partnum
                    SELECT Equ
                    mmod3   := SubStr( Equ->Partnum, 1, 16 )
                    nrecno3 := RecNo()
                    nqty2 := Equ->PartQty
                    nequ2 := ( nqty1 * nqty2 )
                    GOTO TOP
                    SEEK mmod3
                    IF !Found()
                        ntottrade += ( Part->Trade * nequ2 )
                        ntotwhol  += ( Part->Wholesale * nequ2 )
                    ENDIF
                    IF Found()
                        DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                            SELECT Part
                            SEEK Equ->Partnum
                            SELECT Equ
                            mmod4 := SubStr( Equ->Partnum, 1, 16 )
                            nrecno4 := RecNo()
                            nqty3 := Equ->PartQty
                            nequ3 := nqty1 * nqty2 * nqty3
                            GOTO TOP
                            SEEK mmod4
                            IF !Found()
                                ntottrade += ( Part->Trade * nequ3 )
                                ntotwhol  += ( Part->Wholesale * nequ3 )
                            ENDIF
                            IF Found()
                                DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                    nqty4 := Equ->PartQty
                                    nequ4 := nqty1 * nqty2 * nqty3 * nqty4
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    SELECT Equ
                                    ntottrade += ( Part->Trade * nequ4 )
                                    ntotwhol  += ( Part->Wholesale * nequ4 )
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
    SELECT Part
    SET ORDER TO 1
    SEEK mpartnum                    // find original Part
    Scroll(   3, 0, 24, 80 )
    DispBox(  3, 1, 24, 79, 2 )
    nl := 4
    IF ntottrade1 > 0
        @ nl, 27      SAY "Kit Cost"                       COLOR "R+"
        @ nl, Col() + 1 SAY ntottrade1 PICTURE "999,999.99"  COLOR "R+"
        @ nl, Col() + 2 SAY "Parts"                          COLOR "G+"
        @ nl, Col() + 1 SAY ntotTrade  PICTURE "999,999.99"  COLOR "BG+"
        nl++
    ENDIF
    @ nl, 4 SAY Part->Partnum + " " + Part->Desc + " " + Debit->Invno COLOR "G+"
    nl++
    @ nl, 4      SAY "Part Cost"
    @ nl, Col() + 1 SAY Part->Trade     PICTURE "999,999.99"
    @ nl, Col() + 2 SAY "Sell"
    @ nl, Col() + 1 SAY Part->Wholesale PICTURE "999,999.99"
    @ nl, Col() + 1 SAY Part->Unit
    nl += 2
    SELECT EquCut
    SEEK Quot->ModSeqNo
    DO WHILE EquCut->ModSeqno = Quot->ModSeqno .AND. EquCut->( !Eof() )
        IF EquCut->Partnum != mpartnum
            SKIP ALIAS EquCut
            LOOP
        ENDIF
        IF nl > 20
            Inkey( 0 )
            nl := 5
            Scroll(  nl, 2, 24, 78 )
        ENDIF
        @ nl, 3      SAY EquCut->ModRef
        @ nl, Col() + 1 SAY "Qty"
        @ nl, Col() + 1 SAY EquCut->Qty    PICTURE "999"
        @ nl, Col() + 1 SAY EquCut->Length PICTURE "999.999"
        IF EquCut->Width != 0
            @ nl, Col() + 1 SAY EquCut->Width  PICTURE "999.999" COLOR "G+"
            @ nl, Col() + 1 SAY "Sq Mtrs"
        ENDIF
        nl++
        SKIP ALIAS EquCut
    ENDDO
    cLength := cWidth := "N"
    nselect := 1
    DO CASE
    CASE Part->Unit = "Each      "
        nselect := 1
    CASE Part->Unit = "Mtr       "
        nselect := 3
    CASE Part->Unit = "Sq Mtr    "
        nselect := 4
    CASE Part->Unit = "Cu Mtr    "
        nselect := 5
    ENDCASE
    DispBox( 22, 1, 24, 79, 2 )
    @ 23, 6      PROMPT "Each"
    @ 23, Col() + 2 PROMPT "Each Use"
    @ 23, Col() + 2 PROMPT "Cut Lengths"
    @ 23, Col() + 2 PROMPT "Sq Mtr Area"
    @ 23, Col() + 2 PROMPT "Cu Mtr"
    MENU TO nselect
    DO CASE
    CASE PressedEsc()
        RETURN NIL
    CASE nselect = 1                         // Each
        SELECT Quot
        IF Quot->Qty == 0
            ApRLock( 3 )
            Quot->Qty := 1
            UNLOCK
        ENDIF
        nQty := Quot->Qty
    CASE nselect = 3                         // Cut Length Qty
        cLength := "Y"
    CASE nselect = 2                         // Each Use
        nQty := 0
        SELECT Quot
        ApRLock( 3 )
        Quot->Qty := 0
        IF Quot->ModSeqno = Space( 20 )
            Quot->ModSeqno := Debit->Codeno + Debit->Invno + LTrim( Str( RecNo(), 4 ) )
        ENDIF
        UNLOCK

        mok := "Y"
        DO WHILE mok = "Y"
            aPart_ := {}
            nrecno   := 0
            SELECT EquCut
            mseek := Quot->ModSeqno + Quot->Partnum
            SEEK mseek
            IF !Found()
                mok := "N"
            ELSE
                DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                    IF EquCut->Qty = 0
                        ApRLock( 3 )
                        DELETE
                        UNLOCK
                        SKIP ALIAS EquCut
                        LOOP
                    ENDIF
                    Scroll( 18, 3, 20, 78 )
                    @ 19, 10 SAY EquCut->ModRef + " " + Str( EquCut->Qty, 6 )
                    AAdd( aPart_, EquCut->ModRef;
                        + " " + Str( EquCut->Qty, 6 );
                        + "              " + Str( RecNo(), 6 ) )
                    SKIP ALIAS EquCut
                ENDDO                        // Labour EOF
                Scroll(   6, 0, 24, 80 )
                DispBox(  3, 1, 24, 79, 2 )
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice(  6, 10, 23, 64, aPart_,, "AFUNC" )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ], 6 ) )
                    SELECT EquCut
                    GOTO nrecno
                    mmodref := EquCut->ModRef
                    nqty    := EquCut->Qty
                    Scroll(  14, 0, 24, 80 )
                    DispBox( 14, 1, 24, 79, 2 )
                    nl := 15
                    @ nl, 4 SAY Trim( mpartnum ) + " " + Trim( Part->Desc ) + " " + Trim( Part->Unit )
                    nl++
                    @ nl, 4                     GET mmodRef
                    @ nl, Col() + 1 SAY "Qty"      GET nqty    PICTURE "999"
                    READ
                    ApRLock( 3 )
                    EquCut->ModRef := mmodref
                    EquCut->Qty    := nqty
                    UNLOCK
                ENDIF                         // Empty
                mok := ApGetY( "Another Module Cut" )
            ENDIF                 // Found
        ENDDO                                           // mok
    CASE nselect = 4                         // Sq Mtr
        cLength := cWidth := "Y"
    CASE nselect = 5                           // Cu Mtr
        nQty := nWidth := nThick := nTotQty := 0
        Scroll(   3, 0, 24, 80 )
        DispBox(  3, 1, 24, 79, 2 )
        nl := 6
        @ nl, 10     SAY "Size mm" GET nWidth  PICTURE "9999"
        @ nl, Col() + 1 SAY "X"      GET nThick  PICTURE "9999"
        @ nl, Col() + 2 SAY "Qty"    GET nTotQty PICTURE "99999.999"
        READ
        SELECT Part
        ApRLock( 3 )
        Part->Width := nWidth
        Part->Thick := nThick
        UNLOCK
        nQty := ( ( Part->Width * Part->Thick ) / 1000000 ) * nTotQty
        nl += 2
        @ nl, 10      SAY "Cubic Mtr"
        @ nl, Col() + 2 SAY nQty  PICTURE "99,999.999"
        SELECT Quot
        ApRLock( 3 )
        Quot->Qty := nQty
        UNLOCK
    ENDCASE
    // *********** cLength
    IF cLength = "Y"
        nQty := 0
        SELECT Quot
        ApRLock( 3 )
        Quot->Qty := 0
        IF Quot->ModSeqno = Space( 20 )
            Quot->ModSeqno := Debit->Codeno + Debit->Invno + LTrim( Str( RecNo(), 4 ) )
        ENDIF
        UNLOCK

        mok := "Y"
        DO WHILE mok = "Y"
            aPart_ := {}
            nrecno   := 0
            SELECT EquCut
            mseek := Quot->ModSeqno + Quot->Partnum
            SEEK mseek
            IF !Found()
                mok := "N"
            ELSE
                DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                    IF EquCut->Qty = 0
                        ApRLock( 3 )
                        DELETE
                        UNLOCK
                        SKIP ALIAS EquCut
                        LOOP
                    ENDIF
                    IF cWidth = "Y"
                        IF EquCut->Width = 0
                            Scroll( 18, 3, 20, 78 )
                            @ 19, 10 SAY SubStr( EquCut->ModRef, 1, 30 );
                                + " " + Str( EquCut->Qty, 6 );
                                + " " + Str( EquCut->Length, 8, 3 );
                                + " " + Str( EquCut->Width, 8, 3 ) COLOR "BG+"
                            mdelete := ApGetN( "Delete This - Not a Sq Mtr Qty" )
                            IF mdelete = "Y"
                                ApRLock( 3 )
                                DELETE
                                UNLOCK
                                SKIP ALIAS EquCut
                                LOOP
                            ENDIF
                        ENDIF              // mwidth = 0
                    ENDIF                 // cWidth = Y
                    AAdd( aPart_, EquCut->ModRef;
                        + " " + Str( EquCut->Qty, 6 );
                        + " " + Str( EquCut->Length, 8, 3 );
                        + " " + Str( EquCut->Width, 8, 3 );
                        + "              " + Str( RecNo(), 6 ) )
                    SKIP ALIAS EquCut
                ENDDO                        // Labour EOF
                Scroll(   6, 0, 24, 80 )
                DispBox(  3, 1, 24, 79, 2 )
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice(  6, 10, 23, 64, aPart_,, "AFUNC" )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ], 6 ) )
                    SELECT EquCut
                    GOTO nrecno
                    mmodref := EquCut->ModRef
                    nqty    := EquCut->Qty
                    nlength := EquCut->Length
                    nwidth  := EquCut->Width
                    Scroll(  14, 0, 24, 80 )
                    DispBox( 14, 1, 24, 79, 2 )
                    nl := 15
                    @ nl, 4 SAY Trim( mpartnum ) + " " + Trim( Part->Desc ) + " " + Trim( Part->Unit )
                    nl++
                    @ nl, 4                     GET mmodRef
                    nl++
                    @ nl, 12     SAY "Qty"      GET nqty    PICTURE "999"
                    @ nl, Col() + 1 SAY "Length"   GET nlength PICTURE "999.999"
                    IF cWidth = "Y"
                        @ nl, Col() + 1 SAY "Width" GET nwidth PICTURE "999.999"
                        @ nl, Col() + 2 SAY "Sq Mtr"
                    ENDIF
                    READ
                    ApRLock( 3 )
                    EquCut->ModRef := mmodref
                    EquCut->Qty    := nqty
                    EquCut->Length := nlength
                    EquCut->Width  := nwidth
                    UNLOCK
                ENDIF                         // Empty
                mok := ApGetY( "Another Module Cut" )
            ENDIF                 // Found
        ENDDO                                           // mok
        // ***  TESTING THIS ?????????????????????????

        nQty := 0
        SELECT Quot
        ApRLock( 3 )
        Quot->Qty := 0
        UNLOCK
        SELECT EquCut
        GOTO TOP
        SEEK mseek
        IF Found()
            nl := 6
            Scroll(  nl, 2, 24, 78 )
            DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                IF nl > 20
                    Inkey( 0 )
                    nl := 6
                    Scroll( nl, 2, 23, 78 )
                ENDIF
                @ nl, 4      SAY EquCut->ModRef
                @ nl, Col() + 1 SAY "Qty"
                @ nl, Col() + 1 SAY EquCut->Qty    PICTURE "999"
                @ nl, Col() + 1 SAY EquCut->Length PICTURE "999.999"
                IF EquCut->Width != 0
                    @ nl, Col() + 1 SAY EquCut->Width  PICTURE "999.999"
                    @ nl, Col() + 2 SAY "Sq Mtr"
                ENDIF
                nl++
                IF cWidth = "Y"
                    nQty += ( EquCut->Length * EquCut->Width ) * EquCut->Qty
                ELSE
                    nQty += EquCut->Length * EquCut->Qty
                ENDIF
                SKIP ALIAS EquCut
            ENDDO                        // Labour EOF
            SELECT Quot
            ApRLock( 3 )
            Quot->Qty := nQty
            UNLOCK
        ENDIF                              // Found
        nQty := nQtyEqu := nWidth := nLength := 0
        nl := 14
        Scroll(  nl, 0, 24, 80 )
        DispBox(  3, 1, 24, 79, 2 )
        nl++
        @ nl, 4      SAY Trim( Part->Partnum ) + " " + Trim( Part->Desc )
        @ nl, Col() + 1 SAY Quot->Qty PICTURE "9999.999" COLOR "G+"
        @ nl, Col() + 1 SAY Part->Unit
        nl++
        @ nl, 10 SAY "Add Lengths and Qty    Length = 0  Qty = 0 to Exit"
        nl++
        nTotal := 1
        DO WHILE nTotal != 0
            IF nl > 22
                Inkey( 2 )
                nl := 16
                Scroll( nl, 2, 23, 78 )
            ENDIF
            nl++
            @ nl, 4      SAY "Qty"      GET nQtyEqu PICTURE "9999"
            @ nl, Col() + 1 SAY "Length"   GET nLength PICTURE "9999.999"
            IF cWidth = "Y"
                @ nl, Col() + 1 SAY "Width" GET nWidth  PICTURE "9999.999"
                @ nl, Col() + 2 SAY "Sq Mtr"
            ENDIF
            READ
            IF PressedEsc()
                RETURN NIL
            ENDIF
            nTotal := nQtyEqu                  // Needed to get out of loop
            IF cWidth = "Y"
                nQty += ( nLength * nWidth ) * nQtyEqu
            ELSE
                nQty += nLength * nQtyEqu
            ENDIF
            @  5, 62      SAY "Total"
            @  5, Col() + 1 SAY nQty + Quot->Qty PICTURE "9,999.999" COLOR "G+"
            IF nQtyEqu > 0
                SELECT EquCut
                ApFLock( 3 )
                APPEND BLANK
                EquCut->Qty      := nQtyEqu
                EquCut->Length   := nLength
                EquCut->Width    := nWidth
                EquCut->ModSeqno := Quot->ModSeqNo
                EquCut->Date     := Date()
                EquCut->Partnum  := Part->Partnum
                UNLOCK
                mmodref := EquCut->ModRef
                nl++
                @ nl, 20 GET mmodref
                READ
                ApFLock( 3 )
                EquCut->ModRef := mmodref
                UNLOCK
            ENDIF
            nQtyEqu := nWidth := nLength := 0
        ENDDO                         // nTotal
        SELECT Quot
        ApRLock( 3 )
        Quot->Qty += nQty
        UNLOCK
    ENDIF                               // cLength
    IF nl >= 10
        nl := 10
    ENDIF
    SELECT Quot
    ApRLock( 3 )
    Quot->Cost := Part->Trade
    IF Quot->Amount = 0
        IF Name->Margin = 0              // Adds % for Name->Margin
            Quot->Amount := Part->Wholesale
        ELSE
            Quot->Amount := ( ( Part->Wholesale * ( 1 + Name->Margin / 100 ) * 100 ) / 100 )
        ENDIF
    ENDIF
    UNLOCK
    Scroll( nl, 2, 23, 78 )
    DispBox( 0, 1, 24, 79, 2 )
    nl++
    nqty      := Quot->Qty
    namount   := Quot->Amount
    ndiscount := Quot->Discount
    @ nl, 4      SAY "Quantity"   GET nqty
    @ nl, Col() + 1 SAY "Sell"       GET namount
    @ nl, Col() + 1 SAY Trim( Part->Unit )
    @ nl, Col() + 1 SAY "Disc"       GET ndiscount
    READ
    @ nl, 64 SAY ( ( nqty * namount ) * ( 1 -ndiscount / 100 ) * 100 ) / 100.00;
        PICTURE "$999,999.99"
    nl += 2
    mordnum   := Quot->Ordnum
    dbdate    := Quot->Dbdate
    minvno    := Quot->Invno
    mbranchid := Quot->BranchId
    minfo     := Quot->Info
    minfo2    := Quot->Info2
    minfo3    := Quot->Info3
    minfo4    := Quot->Info4
    minfo5    := Quot->Info5
    minfo6    := Quot->Info6
    minfo7    := Quot->Info7
    minfo8    := Quot->Info8
    minfo9    := Quot->Info9
    @ nl, 4      SAY "Client O/N" GET mordnum   PICTURE "@!"
    @ nl, Col() + 1 SAY "Dated"      GET dbdate    PICTURE "99/99/9999"
    @ nl, Col() + 1 SAY "Invno " + Quot->Invno
    @ nl, Col() + 1 SAY "Branch"     GET mbranchId PICTURE "@!"
    nl += 2
    @ nl, 7      SAY "Memo  "     GET minfo
    IF Name->Margin > 0
        @ nl, Col() + 2 SAY Name->MARGIN            PICTURE "999.99" COLOR "G+"
    ENDIF
    nl++
    @ nl, 14 GET minfo2
    nl++
    @ nl, 14 GET minfo3
    nl++
    @ nl, 14 GET minfo4
    nl++
    @ nl, 4 SAY "Not on Invoice"  GET minfo5
    nl++
    @ nl, 19 GET minfo6
    nl++
    @ nl, 19 GET minfo7
    nl++
    @ nl, 19 GET minfo8
    nl++
    @ nl, 19 GET minfo9
    READ
    SELECT Quot
    ApRLock( 3 )
    Quot->Qty      := nqty
    Quot->Amount   := namount
    Quot->Discount := ndiscount
    Quot->Dbdate   := dbdate
    Quot->Ordnum   := mordnum
    Quot->Info     := minfo
    Quot->Info2    := minfo2
    Quot->Info3    := minfo3
    Quot->Info4    := minfo4
    Quot->Info5    := minfo5
    Quot->Info6    := minfo6
    Quot->Info7    := minfo7
    Quot->Info8    := minfo8
    Quot->Info9    := minfo9
    UNLOCK
    cfaxno  := Quot->Faxno
    dDbdate := Quot->DbDate
    SELECT Debit
    ApRLock( 3 )
    Debit->BranchId := Quot->BranchId
    Debit->Ordnum   := Quot->Ordnum
    UNLOCK
    SELECT Name
    ApRLock( 3 )
    Name->Remarks := Quot->Ordnum
    UNLOCK
    // **   SCROLL( 11, 0, 24,80 )
    // **   DISPBOX( 3, 1, 24,79, 2 )
    SELECT Part
    SET ORDER TO 1                      // Partnum
    SEEK mpartnum
    mpartnum := Part->Partnum

    RETURN mpartnum

// ***------- End QuotPrice

// *-------------------------------------------------------------------

STATIC FUNCTION QuotIndi( mcodeno, minvno )

    mABC := "N"
    cequ       := ApGetY( "Do You Want Module Parts" )
    IF cequ = "Y"
        mABC := "Y"
        // **  ApGetY( "Y = Selected Modules (C) Details ONLY" )
    ENDIF
    // ** cprice     := ApGetY( "Do You Want Prices" )
    cprice := "Y"
    // ** cboughtout := ApGetN( "Bought Out and No Stock ONLY" )
    cboughtout := "N"
    nl := 4

    PrintSel()

    IF mwhere = "P"
        @  0, 0
        SET PRINTER TO
        SET DEVICE TO PRINT
        npl := 65
    ELSE
        Scroll()
        npl := 22
    ENDIF
    mfirst := "Y"
    SELECT Quot
    SET ORDER TO 2
    ntotal := ngtotal := nweight := nequcost := nequsell := 0
    npartcost := nlabpart := 0
    ncnt := 0
    mordnum := Space( 16 )
    nl := 0
    @ nl, 1 SAY Control->U_Name
    @ nl, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    // **   nl++
    // **   @ nl, 1 SAY Control->U_Add1+" "+Control->U_Add2
    // **   nl++
    // **   @ nl, 1 SAY Control->U_Add3+" "+Control->U_Add4
    nl += 2
    @ nl, 1 SAY Name->Name                // This is Company Name
    @ nl, 46 SAY Quot->Dbdate PICTURE "99/99/9999"
    @ nl, 58 SAY "Job Card"
    @ nl, 70 SAY Debit->Invno
    nl++
    IF Name->Add1 != Space( 27 )
        @ nl, 1 SAY Name->Add1
        nl++
    ENDIF
    IF Name->Add2 != Space( 27 )
        @ nl, 1 SAY Name->Add2
        nl++
    ENDIF
    IF Name->Add3 != Space( 27 )
        @ nl, 1 SAY Name->Add3
        nl++
    ENDIF
    @ nl, 1 SAY Name->Add4
    @ nl, 28 SAY "Bus " + Name->Phone                // Bus Phone
    @ nl, 47 SAY "Fax " + Name->Bphone               // Bus Phone
    @ nl, 64 SAY "Hm " + Name->Ephone
    nl += 2
    @ nl, 15 SAY Debit->Est
    nl++
    @ nl, 3 SAY Debit->Fault
    nl++
    @ nl, 3 SAY Debit->Message
    nl += 2
    GOTO TOP
    SEEK mcodeno
    DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !Eof() )
        nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
        nqty1 := nqty2 := nqty3 := nqty4 := 0
        nequ1 := nequ2 := nequ3 := nequ4 := 0
        nequtrade1 := 0
        nequtrade2 := nequtrade3 := neqtrade4 := 0
        // **   NO GOOD FOR Equ Costs
        nquot := Quot->Qty
   /*
      IF cbranchId != SPACE( 2 )
         IF Quot->BranchId != cbranchId
            SKIP ALIAS Quot
            LOOP
         ENDIF
      ENDIF                    // cbranchId
   */
        IF minvno != Space( 6 )
            IF Quot->Invno != minvno
                SKIP ALIAS Quot
                LOOP
            ENDIF
        ENDIF
        IF mwhere = "P" .AND. nl >= 55              // Adjust no of items
            nl := 0
            @ nl, 1 SAY Name->Name                // This is Company Name
            @ nl, 46 SAY Quot->Dbdate PICTURE "99/99/9999"
            @ nl, 58 SAY "Job Card"
            @ nl, 70 SAY Quot->Invno
            nl++
        ELSEIF Row() >= 22
            WAIT
            nl := 0
            Scroll()
            @ nl, 1 SAY Name->Name                // This is Company Name
            @ nl, 46 SAY Quot->Dbdate PICTURE "99/99/9999"
            @ nl, 58 SAY "Job Card"
            @ nl, 70 SAY Quot->Invno
            nl++
        ENDIF                                // mwhere
        mpartnum := Quot->Partnum
        IF mpartnum != Space( 20 )
            SELECT Part
            SET ORDER TO 1                    // Partnum
            SEEK mpartnum
            @ nl, 1 SAY Part->Partnum        // Can reduce Part Number
            @ nl, 21 SAY Part->Desc           // Can reduce Desc
            nl++
            npartcost += Part->Trade * Quot->Qty
            IF Part->Detail != Space( 40 )
                @ nl, 9 SAY Part->Detail
                nl++
            ENDIF
            IF Quot->Info  != Space( 45 )
                @ nl, 10 SAY Quot->Info
                nl++
            ENDIF
            IF Quot->Info2 != Space( 45 )
                @ nl, 10 SAY Quot->Info2
                nl++
            ENDIF
            IF Quot->Info3 != Space( 45 )
                @ nl, 10 SAY Quot->Info3
                nl++
            ENDIF
            IF Quot->Info4 != Space( 45 )
                @ nl, 10 SAY Quot->Info4
                nl++
            ENDIF
            IF Quot->Info5 != Space( 45 )
                @ nl, 10 SAY Quot->Info5
                nl++
            ENDIF
            IF Quot->Info6 != Space( 45 )
                @ nl, 10 SAY Quot->Info6
                nl++
            ENDIF
            IF Quot->Info7 != Space( 45 )
                @ nl, 10 SAY Quot->Info7
                nl++
            ENDIF
            IF Quot->Info8 != Space( 45 )
                @ nl, 10 SAY Quot->Info8
                nl++
            ENDIF
            IF Quot->Info9 != Space( 45 )
                @ nl, 10 SAY Quot->Info9
                nl++
            ENDIF
            SELECT Quot
            @ nl, 4 SAY "Qty"
            @ nl, 8 SAY Quot->Qty        PICTURE "99,999.99"
            mA := ( Quot->Amount * ( 1 -Quot->Discount / 100 ) * 100 ) / 100.00
            IF Quot->Partnum = Message->LabPart
                nlabpart += Quot->Qty
            ENDIF
            IF cprice = "Y"
                @ nl, 18 SAY "Cost"
                @ nl, 23 SAY Part->Trade   PICTURE "$999,999.99"
                @ nl, 36 SAY "Sell Each"
                @ nl, 46 SAY Quot->Amount  PICTURE "$999,999.99"
                IF Quot->Discount > 0
                    @ nl, 59 SAY Str( Quot->Discount, 2 ) + " %"
                ENDIF
                @ nl, 67 SAY mA * Quot->Qty  PICTURE "$999,999.99"
            ENDIF                           // cprice with Prices
            nl++
            ngtotal += mA * Quot->Qty
            ntotal  += Quot->Amount * Quot->Qty
        ENDIF
        IF cequ = "Y"                             // Module Parts Required
            mmodcode := Trim( Quot->Partnum )
            SELECT Equ
            SET EXACT ON
            GOTO TOP
            mmod1   := Trim( mpartnum )
            SEEK mmod1
            IF Found()
                DO WHILE  Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
                    nqty1 := Equ->PartQty
                    nequ1 := nqty1 * nquot
                    IF mwhere = "S"
                        IF nl > 22
                            WAIT
                            Scroll()
                            nl := 0
                        ENDIF
                    ENDIF
                    nl++
                    SELECT Part
                    SEEK Equ->Partnum
                    nequtrade1 += nqty1 * Part->Trade
                    @ nl, 0 SAY "."
                    @ nl, 2 SAY Str( nequ1, 9, 3 ) + " " + Trim( Equ->Partnum );
                        + " " + Trim( Part->Desc )
                    @ nl, 68 SAY Part->Trade PICTURE "$999,999.99"
                    IF Equ->Partnum = Message->LabPart
                        nlabpart += nequ1
                    ENDIF
                    IF mABC = "Y"
                        IF Equ->ABC = "C"
                            SKIP ALIAS Equ
                            LOOP
                        ENDIF
                    ENDIF
                    nl++
                    IF cboughtout = "Y"
                        IF Part->Boughtout = "Y"
                            IF cprice = "Y"
                                IF Part->Instock < nequ1
                                    @ nl, 14 SAY "Instock" + Str( Part->Instock, 8, 2 )
                                    @ nl, 30 SAY "Cost " + Trim( Part->Unit ) + Str( Part->Trade, 8, 2 )
                                    nequcost += nequ1 * Part->Trade
                                    @ nl, 50 SAY "Qty*Cost" + Str( nequ1 * Part->Trade, 9, 2 )
                                    // **                        @ nl,67 SAY nqty1 PICTURE "9999.999"
                                    nl++
                                ENDIF
                            ENDIF
                        ENDIF                               // cprice
                    ELSE
                        IF Part->Instock > 0
                            @ nl, 14 SAY "Instock" + Str( Part->Instock, 8, 2 )
                        ENDIF
                        @ nl, 30 SAY "Cost " + Trim( Part->Unit ) + Str( Part->Trade, 8, 2 )
                        nequcost += nequ1 * Part->Trade
                        @ nl, 50 SAY "Qty*Cost" + Str( nequ1 * Part->Trade, 9, 2 )
                        @ nl, 67 SAY nqty1 PICTURE "9999.999"
                        IF Part->Boughtout = "Y"
                            IF Part->Instock < nequ1
                                @ nl, 75 SAY SubStr( Part->Codeno, 1, 5 )
                            ENDIF
                        ENDIF
                        nl++
                    ENDIF                                  // Boughtout
                    SELECT Equ
                    mmod2   := Trim( Equ->Partnum )
                    nrecno2 := RecNo()
                    GOTO TOP
                    SEEK mmod2
                    IF Found()
                        nequtrade2 := 0
                        DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                            nqty2 := Equ->PartQty
                            nequ2 := ( nqty1 * nqty2 ) * nquot
                            IF mwhere = "S"
                                IF nl > 22
                                    WAIT
                                    Scroll()
                                    nl := 0
                                ENDIF
                            ENDIF
                            SELECT Part
                            SEEK Equ->Partnum
                            nequtrade2 += nqty2 * Part->Trade
                            @ nl, 0 SAY ".."
                            @ nl, 4 SAY Str( nequ2, 9, 3 ) + " " + Trim( Equ->Partnum );
                                + "  " + Trim( Part->Desc )
                            IF Equ->Partnum = Message->LabPart
                                nlabpart += nequ2
                            ENDIF
                            IF Part->Boughtout = "Y"
                                IF Part->Instock < nequ2
                                    @ nl, 72 SAY Part->Codeno
                                ENDIF
                            ENDIF
                            nl++
                            IF cboughtout = "Y"
                                IF Part->Boughtout = "Y"
                                    IF cprice = "Y"
                                        IF Part->Instock < nequ2
                                            @ nl, 14 SAY "Instock" + Str( Part->Instock, 8, 2 )
                                            @ nl, 30 SAY "Cost " + Trim( Part->Unit ) + Str( Part->Trade, 8, 2 )
                                            nequcost += nequ2 * Part->Trade
                                            @ nl, 50 SAY "Qty*Cost" + Str( nequ2 * Part->Trade, 9, 2 )
                                            // **                        @ nl,67 SAY nqty2 PICTURE "9999.999"
                                            nl++
                                        ENDIF
                                    ENDIF
                                ENDIF                               // cprice
                            ELSE
                                IF Part->Instock > 0
                                    @ nl, 14 SAY "Instock" + Str( Part->Instock, 8, 2 )
                                ENDIF
                                @ nl, 30 SAY "Cost " + Trim( Part->Unit ) + Str( Part->Trade, 8, 2 )
                                nequcost += nequ2 * Part->Trade
                                @ nl, 50 SAY "Qty*Cost" + Str( nequ2 * Part->Trade, 9, 2 )
                                // **               @ nl,67 SAY nqty2 PICTURE "9999.999"
                                nl++
                            ENDIF                                  // Boughtout
                            SELECT Equ
                            mmod3   := Trim( Equ->Partnum )
                            nrecno3 := RecNo()
                            GOTO TOP
                            SEEK mmod3
                            IF Found()
                                nequtrade3 := 0
                                DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                    IF mwhere = "S"
                                        IF nl > 22
                                            WAIT
                                            Scroll()
                                            nl := 0
                                        ENDIF
                                    ENDIF
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    nqty3 := Equ->PartQty
                                    nequ3 := nqty1 * nqty2 * nqty3 * nquot
                                    nequtrade3 += nqty3 * Part->Trade
                                    @ nl, 0 SAY "..."
                                    @ nl, 5 SAY Str( nequ3, 8, 3 ) + " " + Trim( Equ->Partnum );
                                        + "  " + Trim( Part->Desc )
                                    IF Equ->Partnum = Message->LabPart
                                        nlabpart += nequ3
                                    ENDIF
                                    IF Part->Boughtout = "Y"
                                        IF Part->Instock < nequ3
                                            @ nl, 72 SAY Part->Codeno
                                        ENDIF
                                    ENDIF
                                    nl++
                                    IF cboughtout = "Y"
                                        IF Part->Boughtout = "Y"
                                            IF cprice = "Y"
                                                IF Part->Instock < nequ3
                                                    @ nl, 14 SAY "Instock" + Str( Part->Instock, 8, 2 )
                                                    @ nl, 30 SAY "Cost " + Trim( Part->Unit ) + Str( Part->Trade, 8, 2 )
                                                    nequcost += nequ3 * Part->Trade
                                                    @ nl, 50 SAY "Qty*Cost" + Str( nequ3 * Part->Trade, 9, 2 )
                                                    // **                        @ nl,67 SAY nqty3 PICTURE "9999.999"
                                                    nl++
                                                ENDIF
                                            ENDIF
                                        ENDIF                               // cprice
                                    ELSE
                                        IF Part->Instock > 0
                                            @ nl, 14 SAY "Instock" + Str( Part->Instock, 8, 2 )
                                        ENDIF
                                        @ nl, 30 SAY "Cost " + Trim( Part->Unit ) + Str( Part->Trade, 8, 2 )
                                        nequcost += nequ3 * Part->Trade
                                        @ nl, 50 SAY "Qty*Cost" + Str( nequ3 * Part->Trade, 9, 2 )
                                        // **               @ nl,67 SAY nqty3 PICTURE "9999.999"
                                        nl++
                                    ENDIF                                  // Boughtout
                                    SELECT Equ
                                    mmod4   := Trim( Equ->Partnum )
                                    nrecno4 := RecNo()
                                    GOTO TOP
                                    SEEK mmod4
                                    IF Found()
                                        nequtrade4 := 0
                                        DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                            nqty4 := Equ->PartQty
                                            nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
                                            IF mwhere = "S"
                                                IF nl > 22
                                                    WAIT
                                                    Scroll()
                                                    nl := 0
                                                ENDIF
                                            ENDIF
                                            SELECT Part
                                            SEEK Equ->Partnum
                                            nequtrade4 += nqty4 * Part->Trade
                                            @ nl, 0 SAY "...."
                                            @ nl, 6 SAY Str( nequ4, 9, 3 ) + " " + Trim( Equ->Partnum );
                                                + "  " + Trim( Part->Desc )
                                            IF Equ->Partnum = Message->LabPart
                                                nlabpart += nequ4
                                            ENDIF
                                            IF Part->Boughtout = "Y"
                                                IF Part->Instock < nequ4
                                                    @ nl, 71 SAY Part->Codeno
                                                ENDIF
                                            ENDIF
                                            nl++
                                            IF cboughtout = "Y"
                                                IF Part->Boughtout = "Y"
                                                    IF cprice = "Y"
                                                        IF Part->Instock < nequ4
                                                            @ nl, 14 SAY "Instock" + Str( Part->Instock, 8, 2 )
                                                            @ nl, 30 SAY "Cost " + Trim( Part->Unit ) + Str( Part->Trade, 8, 2 )
                                                            nequcost += nequ4 * Part->Trade
                                                            @ nl, 50 SAY "Qty*Cost" + Str( nequ4 * Part->Trade, 9, 2 )
                                                            // **                        @ nl,67 SAY nqty4 PICTURE "9999.999"
                                                            nl++
                                                        ENDIF
                                                    ENDIF
                                                ENDIF                               // cprice
                                            ELSE
                                                IF Part->Instock > 0
                                                    @ nl, 14 SAY "Instock" + Str( Part->Instock, 8, 2 )
                                                ENDIF
                                                @ nl, 30 SAY "Cost " + Trim( Part->Unit ) + Str( Part->Trade, 8, 2 )
                                                nequcost += nequ4 * Part->Trade
                                                @ nl, 50 SAY "Qty*Cost" + Str( nequ4 * Part->Trade, 9, 2 )
                                                // **               @ nl,67 SAY nqty4 PICTURE "9999.999"
                                                nl++
                                            ENDIF                                  // Boughtout
                                            UNLOCK
                                            SELECT Equ
                                            SKIP ALIAS Equ
                                        ENDDO                       // mmod4
                                        // **         nl++
   /*
             @ nl, 1 SAY ".... ____________"
             @ nl,20 SAY "Cost of Module"
             @ nl,35 SAY nequtrade4 PICTURE "$999,999.99"
             @ nl,50 SAY "____________"
             nl++
   */
                                    ENDIF                           // Found mmod4
                                    SELECT Equ
                                    GOTO nrecno4
                                    SKIP ALIAS Equ
                                ENDDO                       // mmod3
                                // **         nl++
   /*
             @ nl, 1 SAY "... ____________"
             @ nl,20 SAY "Cost of Module"
             @ nl,35 SAY nequtrade3 PICTURE "$999,999.99"
             @ nl,50 SAY "____________"
             nl++
   */
                            ENDIF                          // FOUND  mmod3
                            SELECT Equ
                            GOTO nrecno3
                            SKIP ALIAS Equ
                        ENDDO                       // mmod2
                        // **        nl++
   /*
             @ nl, 1 SAY ".. ____________"
             @ nl,20 SAY "Cost of Module"
             @ nl,35 SAY nequtrade2 PICTURE "$999,999.99"
             @ nl,50 SAY "____________"
             nl++
   */
                    ENDIF                          // FOUND  mmod2
                    SELECT Equ
                    GOTO nrecno2
                    SKIP ALIAS Equ
                ENDDO                       // mmod1
                nl += 2
                @ nl, 3 SAY "All Modules Cost"
                @ nl, 22 SAY nequtrade1 PICTURE "$9999,999.99"
            ENDIF                          // FOUND()  mmod1
            SET EXACT OFF
        ENDIF                              // mequ
        nl++
        SELECT Quot
        SKIP ALIAS Quot
    ENDDO                                // EOF Quot
   /*
      nl++
      @ nl,52 SAY "Parts Costs"
      @ nl,67 SAY ngtotal PICTURE "$999,999.99"
      nl++
   TAKEN OUT
     IF cprice = "Y"
       IF ( ntotal-ngtotal ) > 0
          @ nl, 9 SAY "Parts Discount ="
          @ nl,27 SAY ntotal-ngtotal PICTURE "$99,999.99"
          nl++
       ENDIF                        // ndisctotal
        nl++
        @ nl,23 SAY "Parts Cost "+STR( nequcost,9,2 )
        @ nl,58 SAY "Parts Sell "+STR( ngtotal,9, 2 )
     ENDIF
      nl++
   */

    ncost := 0
    ntime := 0
    SELECT Labour
    GOTO TOP
    DO WHILE Labour->( !Eof() )
        IF Labour->Invno != Debit->Invno
            SKIP ALIAS Labour
            LOOP
        ENDIF
   /*
         IF Labour->Labno != Debit->Codeno          // This is the Invoice Code
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF mwhere = "S" .AND. nl >= 22
            WAIT
            nl := 0
            SCROLL()
         ENDIF
         IF mwhere = "P" .AND. nl >= 55              // Adjust no of items
            EJECT
            nl := 0
         ENDIF                                // mwhere
   */
        IF Labour->Partnum = Space( 20 )
            ntime += Labour->Time
        ELSE
            ncost += Labour->Time * Labour->Rate
        ENDIF
        // **      @ nl, 0 SAY Labour->Codeno+" "+Labour->Desc;
        // **           +" "+STR( Labour->Time, 5, 2 )+" "+STR( Labour->Rate, 6, 2 )
        SKIP ALIAS Labour
    ENDDO
    nl++
    IF nTime + ncost > 0
        @ nl, 3 SAY "Time"
        @ nl, 9 SAY nTime PICTURE "99,999.99"
        @ nl, 20 SAY "Parts"
        @ nl, 27 SAY ncost PICTURE "$999,999.99"
        nl++
    ENDIF
    IF nlabpart > 0
        @ nl, 3 SAY Message->Labpart + " ="
        @ nl, 26 SAY nlabpart PICTURE "999,999.99"
        nl++
    ENDIF
    // **   ngtotal += ncost
    IF mwhere == "P"
        IF cprice = "Y"
            IF ( ntotal - ngtotal ) > 0
                @ nl, 9 SAY "Total Discount ="
                @ nl, 27 SAY ntotal - ngtotal PICTURE "$99,999.99"
                nl++
            ENDIF                        // ndisctotal
            @ nl, 69 SAY ngtotal PICTURE "99,999.99"
            nl++
            // **    @ nl, 0 SAY "O/S Cost "+STR( nequcost,9, 2 )
            // **             +"  Total Kit Sell "+STR( nequsell,9, 2 )
            // **    @ 42, 0 SAY Control->Con_note3
            ngsttot := Round(  ngtotal * ( Control->GSTRate / 100 ), 2 )
            IF SubStr( Name->Add5, 1, 7 ) != "AUSTRAL"
                mA := ( ngtotal + ngsttot )
                @ nl, 69 SAY ngsttot PICTURE "99,999.99"
                nl++
            ELSE
                mA := ngtotal
            ENDIF
            @ nl, 69 SAY mA PICTURE "99,999.99"
            nl++
        ENDIF                                 // cprice
        // **   @ 63, 0 SAY TRIM( Debit->Est )+"   "+Debit->Fault
        EndPrint()
    ELSE
   /*
      IF nl >= 22
         WAIT
         nl := 0
         SCROLL()
      ENDIF                                // mwhere
      IF cprice = "Y"
         ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
         IF SUBSTR( Name->Add5,1,7 ) != "AUSTRAL"
            @ nl,68 SAY ( INT( ( ngtotal+ngsttot )*100 )/100 ) PICTURE "$99,999.99"
          ELSE
            @ nl,68 SAY ngtotal PICTURE "$99,999.99"
         ENDIF
      ENDIF                            // cprice
      nl++
   */
        // **   @ nl, 0 SAY Debit->Est
        // **   nl++
        // **   @ nl, 0 SAY Debit->Fault
        // **   nl++
        // **   @ nl, 0 SAY Debit->Message
        // **   nl+=2
        // **   @ nl,44 SAY nweight PICTURE "9,999.99"
        // **   @ nl,53 SAY "kg"
        IF nl > 18
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    SELECT Quot
    SET ORDER TO 1

    SET MARGIN TO 0

    RETURN NIL

// ** End of QuotIndi()

// *-------------------------------------------------------------------

FUNCTION QuotHead( nl )

    nl := 0
    @ nl, 1 SAY Control->U_Name
    @ nl, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    nl++
    @ nl, 1 SAY Control->U_Add1 + " " + Control->U_Add2
    nl++
    @ nl, 1 SAY Control->U_Add3 + " " + Control->U_Add4
    nl += 2
    @ nl, 1 SAY Name->Name                // This is Company Name
    IF Quot->BranchId != Space( 2 )
        SELECT Branch
        mfind := Quot->Codeno + Quot->BranchId
        SEEK mfind
        @ nl, 43 SAY Branch->Name
    ENDIF
    nl++
    @ nl, 1 SAY Name->Add1
    IF Quot->BranchId != Space( 2 )
        @ nl, 43 SAY Branch->Add1
    ENDIF
    nl++
    @ nl, 1 SAY Name->Add2
    IF Quot->BranchId != Space( 2 )
        @ nl, 43 SAY Branch->Add2
    ENDIF
    nl++
    @ nl, 1 SAY Name->Add3
    IF Quot->BranchId != Space( 2 )
        @ nl, 43 SAY Branch->Add3
    ENDIF
    nl++
    @ nl, 1 SAY Name->Add4
    IF Name->Phone != Space( 15 )
        @ nl, 22 SAY Name->Phone                // Business Phone
    ELSE
        @ nl, 22 SAY Name->Ephone               // Home Phone
    ENDIF
    IF Quot->BranchId != Space( 2 )
        @ nl, 43 SAY Branch->Add4
        @ nl, 64 SAY Branch->Phone             // Business Phone
    ENDIF
    nl++
    IF Quot->Invno != Space( 6 )
        @ nl, 5 SAY Trim( Debit->Message )        // 50 Char
        nl++
        @ nl, 46 SAY Quot->Dbdate PICTURE "99/99/9999"
        @ nl, 58 SAY "WORK ORDER"
        @ nl, 70 SAY Quot->Invno
    ELSE
        nl++
        @ nl, 34 SAY Quot->Dbdate PICTURE "99/99/9999"
        @ nl, 46 SAY "In HOUSE JOB"
        @ nl, 60 SAY Quot->Faxno
    ENDIF                            // Quot->Invno
    nl += 2

    RETURN nl

// **** End QuotHead

// *-------------------------------------------------------------------

STATIC FUNCTION QuotJIT()

    Scroll()
    DispBox( 0, 4, 18, 75, 2 )
    @  8, 20 SAY "Just In Time Analysis"
    // ** mstmm  := DATE()-30
    // ** mendmm := DATE()
    // ** @ 10, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
    // ** @ 11, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
    cabc := "A"
    njitday := 21
    nselect := 2
    @ 10, 20 PROMPT "1. One   Week   7 Days"
    @ 11, 20 PROMPT "2. Two   Weeks 14 Days"
    @ 12, 20 PROMPT "3. Three Weeks 21 Days"
    @ 13, 20 PROMPT "4. Four  Weeks 28 Days"
    @ 14, 20 PROMPT "5. Five  Weeks 35 Days"
    MENU TO nselect
    DO CASE
    CASE nselect == 1
        njITDay := 7
    CASE nselect == 2
        njITDay := 14
    CASE nselect == 3
        njITDay := 21
    CASE nselect == 4
        njITDay := 28
    CASE nselect == 5
        njITDay := 35
    ENDCASE
    nselect := 1
    @ 10, 50 PROMPT "1. All ABC      "
    @ 11, 50 PROMPT "2. Standard     "
    @ 12, 50 PROMPT "3. Med  Priority"
    @ 13, 50 PROMPT "4. High Priority"
    MENU TO nselect
    DO CASE
    CASE nselect == 1
        cABC := " "
    CASE nselect == 2
        cABC := "C"
    CASE nselect == 3
        cABC := "B"
    CASE nselect == 4
        cABC := "A"
    ENDCASE
    mwhere := "S"

    PrintSel( mwhere )

    IF mwhere == "P"
        npl := 56
    ELSE
        npl := 20
    ENDIF
    nl := 0
    @ nl, 10 SAY Control->U_Name
    nl++
    ntimeoper := ntimeadmin := 0
    SELECT Quot
    INDEX ON Partnum TO QuotParI
    SET INDEX TO QuotParI
    GOTO TOP
    DO WHILE Quot->( !Eof() )
        IF ( Quot->DBDate + Quot->Jitday ) > Date()
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF cabc != " "
            IF Quot->ABC != cabc
                SKIP ALIAS Quot
                LOOP
            ENDIF
        ENDIF
        mpartnum := Quot->Partnum
        nquotpart := 0
        DO WHILE Quot->Partnum = mpartnum .AND. Quot->( !Eof() )
            nquotpart += Quot->Qty
            SKIP ALIAS Quot
        ENDDO                         // EOF mpartnum
        IF nl > npl
            IF mwhere = "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            nl := 0
            @ nl, 10 SAY Control->U_Name
            nl++
        ENDIF
        @ nl, 10 SAY mpartnum + "  " + Str( nquotpart )
        nl++
        ntimetotal := ntime := 0
        SELECT PartOper
        GOTO TOP
        SEEK mpartnum
        DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !Eof() )
            IF PartOper->Operno = Space( 8 )
                SKIP ALIAS PartOper
                LOOP
            ENDIF
            // **         @ nl, 0 SAY PartOper->Operno
            // **         nl++
            SELECT Operate
            SET ORDER TO 1                   // Operno
            SEEK PartOper->Operno
            @ nl, 0 SAY Operate->Desc
            @ nl, 41 SAY "Time"
            @ nl, 45 SAY Operate->Time PICTURE "999.99"
            @ nl, 53 SAY "Rate"
            @ nl, 57 SAY Operate->Rate PICTURE "999.99"
            ntimetotal += ( Operate->Time * Operate->Rate ) * nquotPart
            ntime      += Operate->Time * nquotPart
            ntimeoper  += Operate->Time * nquotPart
            @ nl, 65 SAY "Total"
            @ nl, 70 SAY ( Operate->Time * Operate->Rate ) * nquotPart PICTURE "9,999.99"
            @ nl, 79 SAY PartOper->ABC
            // **         @ nl,64 SAY Operate->Priority
            // **         @ nl,66 SAY "Set Up"
            // **         @ nl,73 SAY Operate->Setup PICTURE "999.99"
            // **         @ nl,67 SAY Operate->Date
            nl++
            IF nl > npl
                IF mwhere = "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                nl := 2
                // **                  @ nl,10 SAY TRIM( Name->Name )+" "+Job->Jobnum+" "+DTOC( Job->Date )
                // **                  nl++
                // **                  @ nl,10 SAY "Desc "+Job->Desc
            ENDIF
            SELECT PartOper
            SKIP ALIAS PartOper
        ENDDO                     // PartOper EOF
        IF ntime > 0
            @ nl, 0 SAY "Time * Qty ="
            @ nl, 14 SAY ntime       PICTURE "99,999.99"
            @ nl, 30 SAY "Time * Rate * Qty ="
            @ nl, 50 SAY ntimetotal  PICTURE "$99,999.99"
            nl += 2
        ENDIF                                // ntime > 0
        ntimetotal := ntime := 0
        SELECT PartOper
        GOTO TOP
        SEEK mpartnum
        DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !Eof() )
            IF PartOper->Adminno = Space( 8 )
                SKIP ALIAS PartOper
                LOOP
            ENDIF
            // **           @ nl, 0 SAY PartOper->Desc
            // **           @ nl,31 SAY "Start "+DTOC( PartOper->StartDate )
            // **           @ nl,50 SAY "Due "+DTOC( PartOper->DueDate )
            @ nl, 0 SAY PartOper->Adminno
            // **           nl++
            SELECT Admin
            // **           SET ORDER TO 2                   // Adminno
            SEEK PartOper->Adminno
            @ nl, 0 SAY Admin->Desc
            @ nl, 41 SAY "Time"
            @ nl, 45 SAY Admin->Time PICTURE "9999.99"
            @ nl, 53 SAY "Rate"
            @ nl, 58 SAY Admin->Rate PICTURE "999.99"
            ntimetotal += ( Admin->Time * Admin->Rate ) * nquotPart
            ntime      += Admin->Time * nquotPart
            ntimeadmin += Admin->Time * nquotPart
            @ nl, 66 SAY "Total"
            @ nl, 71 SAY ( Admin->Time * Admin->Rate ) * nquotPart PICTURE "99,999.99"
            nl++
            IF nl > npl
                IF mwhere = "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                nl := 0
            ENDIF
            SELECT PartOper
            SKIP ALIAS PartOper
        ENDDO                     // PartOper EOF
        IF ntime > 0
            @ nl, 0 SAY "Time * Qty ="
            @ nl, 14 SAY ntime       PICTURE "99,999.99"
            @ nl, 30 SAY "Time * Rate * Qty ="
            @ nl, 50 SAY ntimetotal  PICTURE "$99,999.99"
            nl += 2
        ENDIF                        // ntime > 0
        ntimetotal := 0
        SELECT PartOper
        GOTO TOP
        SEEK mpartnum
        DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !Eof() )
            IF PartOper->Drawno = Space( 8 )
                SKIP ALIAS PartOper
                LOOP
            ENDIF
            @ nl, 0 SAY PartOper->Drawno
            SELECT Drawing
            SEEK PartOper->Drawno
            @ nl, 10 SAY Drawing->Desc
            nl++
            IF nl > npl
                IF mwhere = "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                nl := 0
            ENDIF
            SELECT PartOper
            SKIP ALIAS PartOper
        ENDDO                     // PartOper EOF
        // ***      nl++
        SELECT Quot
        // **      SKIP ALIAS Quot
    ENDDO                        // Quot EOF
    IF nl > 18
        IF mwhere = "S"
            WAIT
            Scroll()
            nl := 12
        ENDIF
    ENDIF
    nl++
    @ nl, 0 SAY "Total Operation Time * Qty ="
    @ nl, 30 SAY ntimeoper PICTURE "99,999.99"
    @ nl, 40 SAY "Total Admin Time * Qty ="
    @ nl, 65 SAY ntimeadmin PICTURE "99,999.99"
    IF mwhere = "S"
        nl += 2
        WAIT
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ELSE
        EndPrint()
    ENDIF
    SELECT Quot
    SET INDEX TO QuotInd

    mcontinue := ApGetN( "Do You want Labour Print" )
    IF mcontinue == "Y"
        LabPrint()                    // LabDem
    ENDIF

    RETURN NIL
// **** End of QuotJIT

// ********----------  END OF FILE XLF_QU2.PRG
