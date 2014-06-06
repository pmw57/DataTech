// ** JK  24-09-11 07:39:40

// *** REM  Invoice Files Christine Common
// ** Used by MetalCraft

/*  Program.....:                  ZF_INV.PRG
    Authors.....: J.Kirby
    Date........: 13/06/1993
    Functions...: IvcEdit, IvcHist, InvList()
                  InvLsthd(), InvPrint()
*/

FUNCTION IvcEdit( minvno )

    aPart_ := {}
    nrecno    := 0
    nivcTotal := 0
    nQtyorg := nAmountorg := nDiscountorg := 0
    mpartnum := Space( 20 )
    SELECT Invoice
    GOTO TOP
    SEEK minvno
    DO WHILE Invoice->Invno == minvno .AND. Invoice->( !Eof() )
        mpartnum := Invoice->Partnum
        SELECT Part
        SEEK mpartnum
        SELECT Invoice
        ApRLock( 3 )
        mA := ( ( Invoice->Amount * ( 1 -Invoice->Discount / 100 ) * 100 ) / 100 )
        // **                        *Invoice->Qty
        UNLOCK
        AAdd( aPart_, SubStr( Invoice->Partnum, 1, 9 ) + " " + Str( Invoice->Qty, 8, 2 );
            + " " + SubStr( Part->Desc, 1, 25 );
            + " " + Str( Invoice->Amount, 10, 2 ) + "  " + Str( Invoice->Discount, 5, 2 );
            + "% " + Str( mA, 10, 2 ) + "      " + Str( RecNo(), 6 ) )
        nivcTotal := ( nivcTotal + ( ( Invoice->Amount * ( 1 -Invoice->Discount / 100 ) * 100 );
            / 100 ) * Invoice->Qty )
        SKIP ALIAS Invoice
    ENDDO
    Scroll()
    DispBox( 0, 1,  2, 79, 2 )
    @  1, 10 SAY Name->Name
    DispBox( 3, 1, 24, 79, 2 )
    IF !Empty( aPart_ )
        anum := AChoice( 4, 3, 23, 77, aPart_,, "AFUNC" )
        IF LastKey() == 27
            RETURN
        ENDIF
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        SELECT Invoice
        GOTO nrecno
        ApRLock( 3 )
        mpartnum     := Invoice->Partnum
        nQtyorg      := Invoice->Qty
        nAmountorg   := Invoice->Amount
        nDiscountorg := Invoice->Discount
        UNLOCK
        SELECT Part
        SEEK mpartnum
    ENDIF
    Scroll(  3, 0, 24, 80 )
    DispBox( 3, 1, 24, 79, 2 )
    nl := 4
    @  nl, 4 SAY Trim( Invoice->Partnum )
    @  nl, Col() + 2 SAY Trim( Part->Desc ) COLOR "BG+"
    @  nl, Col() + 2 SAY Invoice->Invno
    @  nl, Col() + 2 SAY Invoice->Qty PICTURE "99,999.99"
    nl += 2
    mmodcode := Trim( Part->Partnum )
    ntotAmnt := ntotSell := 0
    SELECT Equ
    SEEK mmodcode
    IF Found()
        DO WHILE Trim( Equ->Modcode ) == mmodcode .AND. Equ->( !Eof() )
            SELECT Part
            ncost := nsell := 0
            SEEK Equ->Partnum
            IF Found()
                ncost    := Part->Trade * Equ->PartQty
                nsell    := Part->Wholesale * Equ->PartQty
                ntotAmnt += ncost
                ntotSell += nsell
            ENDIF
            SELECT Equ
            SKIP ALIAS Equ
        ENDDO
        @ nl, 6      SAY mmodcode + " Cost"
        @ nl, Col() + 1 SAY ntotAmnt PICTURE "999,999.99"
        @ nl, Col() + 2 SAY "Equ ="
        @ nl, Col() + 1 SAY ntotSell PICTURE "999,999.99"
        nl += 2
    ENDIF
    SELECT Part
    SEEK mpartnum
    SELECT Invoice
    ApRLock( 3 )
    nQty := Invoice->Qty
    @ nl, 10      SAY "  Qty :" GET Invoice->Qty      PICTURE "9999.99"
    @ nl, Col() + 3 SAY "0 To Delete"
    nl += 2
    @ nl, 6 SAY "Price :" GET Invoice->Amount   PICTURE "999999.99"
    @ nl, Col() + 2          GET Invoice->Discount PICTURE "99.99"
    @ nl, Col() + 2          GET Invoice->PDate    PICTURE "99/99/9999"
    @ nl, Col() + 2          GET Invoice->Ordnum
    minfo   := Invoice->Info
    minfo2  := Invoice->Info2
    minfo3  := Invoice->Info3
    minfo4  := Invoice->Info4
    nl++
    @ nl, 8 SAY "Specific This Invoice Notes" COLOR "G+"
    nl++
    @ nl, 17                GET minfo
    nl++
    @ nl, 17                GET minfo2
    nl++
    @ nl, 17                GET minfo3
    nl++
    @ nl, 17                GET minfo4
    READ
    IF Invoice->Qty > 0
        Invoice->Cost := Part->Trade
    ENDIF
    Invoice->Info      := minfo
    Invoice->Info2     := minfo2
    Invoice->Info3     := minfo3
    Invoice->Info4     := minfo4
    UNLOCK
    SELECT  Hist
    SET ORDER TO 1                               // Codeno+Partnum+Invno+PDate
    mfind := Invoice->Codeno + Invoice->Partnum + Invoice->Invno
    SEEK mfind
    IF Found()
        ApRLock( 3 )
        Hist->Codeno    := Invoice->Codeno
        Hist->Partnum   := Invoice->Partnum
        Hist->Invno     := Invoice->Invno
        Hist->Qty       := Invoice->Qty
        Hist->Amount    := Invoice->Amount
        Hist->Discount  := Invoice->Discount
        Hist->Stat      := Invoice->Stat
        Hist->Wholesale := Invoice->Wholesale
        Hist->Cost      := Invoice->Cost
        Hist->PDate     := Invoice->PDate
        Hist->BranchId  := Invoice->BranchId
        Hist->Saleno    := Invoice->Saleno
        Hist->U_Codeno  := Invoice->U_Codeno
        UNLOCK
    ENDIF                  // Found
    IF Invoice->Qty = 0
        SELECT Part
        ApRLock( 3 )
        // **      Part->Instock += nQty
        Part->Utd     -= nQty
        UNLOCK
        SELECT Invoice
        ApRLock( 3 )
        DELETE
        UNLOCK
        SELECT Hist
        SET ORDER TO 1                               // Codeno+Partnum+Invno
        mfind := Invoice->Codeno + Invoice->Partnum + Invoice->Invno
        SEEK mfind
        IF Found()
            ApRLock( 3 )
            DELETE
            UNLOCK
        ENDIF                              // Found 0
        RETURN NIL
    ENDIF                                 // Invoice->Qty = 0
    UNLOCK
    SELECT Part
    ApRLock( 3 )
    // **   Part->Instock -= Invoice->Qty-nQty
    Part->Utd     -= Invoice->Qty - nQty
    UNLOCK
    nl += 2
    @ nl, 16 SAY "Original " + Str( nQtyorg ) + " " + Str( nAmountorg );
        + " " + Str( nDiscountorg ) + " " + mcodeno
    nl++
    @ nl, 16 SAY "Hist Qty " + Str( Hist->Qty ) + " Hist Price " + Str( Hist->Amount )
    nl++
    @ nl, 16 SAY "Hist Discount " + Str( Hist->Discount );
        + " Hist Codeno " + Hist->Codeno
    SELECT Part
    ApRLock( 3 )
    nl++
    @ nl, 6 SAY "Desc" GET Part->Desc
/*
   nl++
   @ nl, 11           GET Part->Detail
   nl++
   @ nl, 11           GET Part->Detail1
   nl++
   @ nl, 11           GET Part->Detail2
   nl++
   @ nl, 11           GET Part->Detail3
*/
    READ
    UNLOCK
    COMMIT

    RETURN

// **-----End of IvcEdit()

// *-------------------------------------------------------------------

FUNCTION IvcHist()

    Scroll()
    @  8, 10 SAY "Please Wait Indexing File"
    SELECT Hist
    GOTO TOP
    ApFLock( 3 )
    INDEX ON Hist->Invno + Hist->Partnum TO TempI05
    SET INDEX TO TempI05
    UNLOCK
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        aPart_ := {}
        mA := ngtotal := nggtotal := 0
        Scroll( 3, 0, 24, 80 )
        minvno := Space( 6 )
        @ 10, 10 SAY "Which Invoice :" GET minvno
        @ 10, 36 SAY "Esc to Exit"
        READ
        IF LastKey() == 27
            RETURN NIL
        ENDIF
        SELECT Hist
        GOTO TOP
        SEEK minvno
        IF Found()
            DO WHILE Hist->Invno == minvno .AND. Hist->( !Eof() )
                IF Hist->Invno = Space( 6 )
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                SELECT Part
                SEEK Hist->Partnum
                SELECT Name
                SEEK Hist->Codeno
                mcodeno := Hist->Codeno
                SELECT Hist
                ddate := Hist->Pdate
                mA    := Hist->Amount
                IF Hist->Discount > 0
                    mA := ( mA * ( 1 -( Hist->Discount / 100 ) ) * 100 ) / 100.00
                ENDIF                          // Discount
                mA := mA * Hist->Qty
                ngtotal += mA
                AAdd( aPart_, SubStr( Part->Desc,1,22 );
                    + " " + Str( Hist->Qty, 7 );
                    + " " + Str( Hist->Amount, 10, 2 );
                    + "  " + Str( Hist->Discount, 5, 2 );
                    + " " + Str( Hist->Cost, 9, 2 );
                    + "  " + Str( mA, 10, 2 )  )
                SELECT Hist
                SKIP ALIAS Hist
            ENDDO
        ENDIF                       // LastRec != 0
        Scroll()
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            DispBox( 0, 1, 2, 79, 2 )
            @  1, 7 SAY mcodeno + "  " + Name->Name
            @  1, 45 SAY "Invoice " + minvno
            @  1, 64 SAY ddate
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 1, 22, 79, 2 )
            @  3, 00 SAY " "
            AEval( aPart_, {|A| QOUT( " " + Chr( 186 ) + "  " ), QQOut( A ), Breakpoint() } )
        ELSE
            @ 10, 10 SAY "Not Found - Try Again - Esc to Exit"
        ENDIF
        @ 23, 10 SAY Message->AnyKey
        @ 23, 40 SAY "Amount incl GST"
        SELECT Control
        ApRLock( 3 )
        nggtotal := ngtotal * ( ( Control->GSTRate / 100 ) + 1 )
        UNLOCK
        @ 23, 60 SAY nggtotal PICTURE "$999,999.99"
        Inkey( 0 )
        mcontinue := "Y"
    ENDDO

    SELECT Hist
    SET INDEX TO HistInd

    RETURN

// ***---- End of IvcHist()

// *-------------------------------------------------------------------

FUNCTION InvList()

    Scroll()
    @ 10, 10 SAY "Please Wait Indexing File"
    SELECT Hist
    // ***   SET ORDER TO 1               // Test  No GOOD ???????
    GOTO TOP
    ApFLock( 3 )
    INDEX ON Hist->Codeno + Hist->Invno + Hist->Partnum TO TempI06
    SET INDEX TO TempI06
    UNLOCK

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"

        mcodeno := Space( 8 )
        Scroll()

        NameRank( mcodeno )

        IF LastKey() == 27
            RETURN NIL
        ENDIF
        mcodeno := Name->Codeno
        mwhere  := "S"

        Printsel( mwhere )

        IF mwhere == "P"
            npl := 56
            @  0, 0
            SET DEVICE TO PRINT
        ELSE
            Scroll()
            npl := 20
        ENDIF
        SELECT Hist
        SEEK mcodeno
        IF !Found()
            @ 10, 10 SAY "No Invoices for this Name"
        ENDIF
        InvLsthd()                           // Below
        nl := 3
        mA := ngtotal := nggtotal := 0
        minvno  := Space( 6 )
        DO WHILE Hist->Codeno = mcodeno .AND. Hist->( !Eof() )
            IF nl > npl
                IF mwhere = "P"
                    EJECT
                    InvLsthd()
                ELSE
                    WAIT
                    Scroll( 2, 0, 22, 80 )
                ENDIF
                nl := 3
            ENDIF
            IF minvno = Space( 6 )
                @ nl, 10 SAY Hist->Invno
                @ nl, 20 SAY Hist->PDate
                @ nl, 35 SAY Hist->Saleno
                @ nl, 55 SAY Hist->Codeno
                @ nl, 65 SAY Hist->U_Codeno
                nl++
                minvno := Hist->Invno
            ENDIF
            mpartnum := Hist->Partnum
            SELECT CusNotes
            cdetail := ""
            coderef := Part->Partnum
            SEEK coderef
            IF Found()
                Getdets( coderef )                           // XF_Memo2
                FormP( cdetail, 60, 10 )                       // XF_Memo2
            ENDIF
            SELECT Part
            SEEK mpartnum
            @ nl, 0 SAY SubStr( Part->Partnum, 1, 10 )
            @ nl, 18 SAY SubStr( Part->Desc, 1,25 )
            SELECT Hist
            @ nl, 44 SAY Hist->Qty      PICTURE "9999"
            @ nl, 49 SAY Hist->Amount   PICTURE "999,999.99"
            @ nl, 60 SAY Hist->Discount PICTURE "999.99"
            mA    := Hist->Amount
            IF Hist->Discount > 0
                mA := ( mA * ( 1 -( Hist->Discount / 100 ) ) * 100 ) / 100.00
            ENDIF                          // Discount
            mA      := mA * Hist->Qty
            ngtotal += mA
            @ nl, 67 SAY mA PICTURE "99,999.99"
            nl++
            SKIP ALIAS Hist
            IF Hist->Invno != minvno
                IF ngtotal > 0
                    @ nl, 40 SAY "Amount inc GST"
                    SELECT Control
                    ApRLock( 3 )
                    nggtotal := ngtotal * ( ( Control->GSTRate / 100 ) + 1 )
                    UNLOCK
                    SELECT Hist
                    @ nl, 62 SAY nggtotal PICTURE "$999,999.99"
                    nl++
                ENDIF
                ngtotal := nggtotal := 0
                minvno := Hist->Invno
                IF Hist->Codeno = mcodeno
                    @ nl, 10 SAY Hist->Invno
                    @ nl, 20 SAY Hist->PDate
                    @ nl, 35 SAY Hist->Saleno
                    @ nl, 55 SAY Hist->Codeno
                    @ nl, 65 SAY Hist->U_Codeno
                    nl++
                ENDIF
            ENDIF
        ENDDO
        IF mwhere = "P"
            @ nl, 0 SAY " "
            EndPrint()
        ELSE
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ENDIF
        mcontinue := ApGetN( Message->Another )
    ENDDO
    SELECT Hist
    SET INDEX TO HistInd

    RETURN NIL

// *** End of Invlist()

// *---------------------------------------------------------------------*

FUNCTION InvLsthd()

    @  0, 0 SAY Name->Name
    @  1, 10 SAY "Invoicing Details"
    @  1, 45 SAY "Qty"
    @  1, 52 SAY "Amnt"
    @  1, 60 SAY "Discount"
    @  1, 73 SAY "Total"

    RETURN

// *-------------------------------------------------------------------

FUNCTION InvPrint()

    mcontinue := mok := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        mcodeno := Space( 8 )
        nrecno  := 0
        aPart_  := {}
        SELECT Debit
        SET ORDER TO 1    // Codeno+BranchId
        GOTO TOP
        IF LastRec() != 0
            DO WHILE Debit->( !Eof() )
                IF Debit->Codeno + Debit->BranchId = mcodeno
                    SKIP ALIAS Debit
                    LOOP
                ENDIF
                SELECT Name
                SEEK Debit->Codeno
                SELECT Debit
                mcodeno := Debit->Codeno + Debit->BranchId
                AAdd( aPart_, Name->Name + "   " + Debit->BranchId;
                    + "             " + Str( RecNo(), 6 ) )
                SKIP ALIAS Debit
            ENDDO                          // EOF()
            DispBox( 0, 1, 23, 41, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice( 1, 3, 22, 40, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ], 6 ) )
                IF LastKey() == 27
                    RETURN NIL
                ENDIF
                IF LastKey() == -1
                    mcodeno := Space( 8 )
                    Namerank( @mcodeno )                // XLF_Name
                    IF LastKey() == 27
                        RETURN NIL
                    ENDIF
                    SELECT Name
                    mcodeno := Name->Codeno
                    cbranchId := Space( 2 )
                    SELECT Branch
                    SEEK mcodeno
                    IF Found()
                        BranchFind( @mcodeno )             // ZSF_Name
                        cbranchId := Branch->BranchId
                        mok := ApGetY( "Do you Want Branch" )
                        IF mok = "N"
                            cbranchId := Space( 2 )
                        ENDIF
                    ENDIF
                ELSE
                    GOTO nrecno
                    mcodeno   := Debit->Codeno
                    cbranchid := Debit->BranchId
                    SELECT Name
                    SEEK mcodeno
                ENDIF
            ENDIF
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @  1, 10 SAY Name->Name
        ENDIF                        // LastRec
        minvno  := Space( 6 )

        // **    Namerank()

        IF LastKey() == 27
            RETURN NIL
        ENDIF
        mrectot := 0
        mrecdet := Space( 30 )
        SELECT Name
        ApRLock( 3 )
        mcodeno := Name->Codeno
        UNLOCK
        // **   @  2,30
        // **   @  2,42 SAY Name->Name
        // **      @  2,42 SAY TRIM(Name->Title)+" "+TRIM(Name->Called)+" "+Name->Famname
        Scroll( 2, 0, 24, 80 )
        SELECT Debit
        SEEK mcodeno
        IF !Found()
            @  6, 10 SAY "No Invoice for This Customer"
            WAIT
            RETURN NIL
        ENDIF
        @  2, 5 SAY "Invoice     Printed"
        npl := 21
        nl  := 4
        DO WHILE Debit->( !Eof() )
            IF Codeno == mcodeno
                IF nl > npl
                    WAIT
                    Scroll( 4, 0, 24, 80 )
                    nl := 4
                ENDIF
                @ nl, 5 SAY Debit->Invno
                minvno := Debit->Invno
                @ nl, 18 SAY Debit->Printed
                @ nl, 24 SAY Debit->Dbdate
                nl++
            ENDIF
            SKIP ALIAS Debit
        ENDDO
        // **      @ 17, 5 SAY "IF Printed = N no invoice exists in Invoice File"
        @ 22, 5 SAY "Which Invoice to be Printed"
        @ 22, 34 GET minvno PICTURE "@KX"
        READ
        minv := minvno
        SELECT Debit
        SET ORDER TO 2
        SEEK minvno
        SET ORDER TO 1
        ApRLock( 3 )
        REPLACE Printed WITH "P"
        UNLOCK
        // **        mselno := "JN"
        // **       NoteAdd()                           // XLF_Note
        // **        mnote := SPACE(60)

        Invform( mcodeno )                    // Specific XF_IvcFM, CalInv

        mcontinue := ApGetN( Message->Another + " Print" )
    ENDDO

    RETURN NIL

// *** End of Invprint

// ********----------  END OF FILE ZF_INV.PRG
