// * JK  06-09-11 13:31:00

/*
   Program ......:                   XF_IVCFM.PRG
   Authors.......: John Kirby
   Date..........: 15/02/1996
   Functions.....: IvcFormA, IvcHead, InvForm, IvcLook
                   IvcAddP
   Static funcs..: IvcPrice
*/

// (c) Copyright (c) 1995 Kirby Christchurch.

FUNCTION IvcFormA( mcodeno )

    ntotal := ngtotal := nweight := 0
    minvno := Debit->Invno
    SELECT Invoice
    SET ORDER TO 1
    GOTO TOP
    SEEK minvno
    IF mwhere == "P"
        SET DEVICE TO PRINT
        // **   @  0, 0 SAY CHR( 27 )+CHR( 67 )+CHR( 03 )
        nl := IvcHead()
    ELSE
        nl := 0
        @ nl, 3 SAY Name->Name                // This is Company Name
        nl++
        @ nl, 3      SAY Name->Add1
        @ nl, Col() + 4 SAY Name->Add2
        @ nl, Col() + 4 SAY Debit->BranchId
        nl++
        @ nl, 3      SAY Name->Add4
        @ nl, Col() + 3 SAY Name->Zip
        @ nl, Col() + 4 SAY mcodeno
        @ nl, Col() + 3 SAY Debit->Dbdate PICTURE "99/99/99"
        @ nl, Col() + 3 SAY Debit->Invno PICTURE "999999"
        nl++
        @ nl, 4 SAY "O/N " + Debit->Ordnum
        nl++
        @ nl, 0 SAY "-----------------------------------------------------------------------------"
        nl++
    ENDIF
    DO WHILE Invoice->Invno = minvno .AND. Invoice->( !Eof() )
        IF mwhere = "P" .AND. nl >= 45              // Adjust no of items
            // **      @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
            nl := IvcHead()                 // Below
        ELSEIF Row() = 18
            WAIT
            nl := 4
            Scroll( 4, 0, 24, 80 )
        ENDIF                                // mwhere
        mpartnum := Invoice->Partnum
        IF mpartnum != Space( 20 )
            SELECT Part
            SEEK mpartnum
            IF SubStr( Control->U_Name, 1, 4 ) != "META"
                @ nl, 3 SAY SubStr( Part->Desc, 1, 31 )
                @ nl, 35 SAY SubStr( Part->Unit, 1, 8 )
            ELSE
                @ nl, 3 SAY Part->Desc
            ENDIF
            SELECT Invoice
            @ nl, 44 SAY Invoice->Qty                  PICTURE "9999.99"
            @ nl, 52 SAY Invoice->Amount               PICTURE "999,999.99"
            IF Invoice->Discount > 0
                @ nl, 63 SAY Str( Invoice->Discount, 2 ) + "%"
            ENDIF
            mA := ( Invoice->Amount * ( 1 -Invoice->Discount / 100 ) * 100 ) / 100.00
            @ nl, 67 SAY mA * Invoice->Qty               PICTURE "$999,999.99"
            nl++
            IF Part->Detail != Space( 43 )
                @ nl, 3 SAY Part->Detail
                nl++
            ENDIF
            IF Part->Detail1 != Space( 43 )
                @ nl, 3 SAY Part->Detail1
                nl++
            ENDIF
            IF Part->Detail2 != Space( 43 )
                @ nl, 3 SAY Part->Detail2
                nl++
            ENDIF
            IF Part->Detail3 != Space( 43 )
                @ nl, 3 SAY Part->Detail3
                nl++
            ENDIF
            IF Invoice->Info != Space( 45 )
                @ nl, 3 SAY Invoice->Info
                nl++
            ENDIF
            IF Invoice->Info2 != Space( 45 )
                @ nl, 3 SAY Invoice->Info2
                nl++
            ENDIF
            IF Invoice->Info3 != Space( 45 )
                @ nl, 3 SAY Invoice->Info3
                nl++
            ENDIF
            IF Invoice->Info4 != Space( 45 )
                @ nl, 3 SAY Invoice->Info4
                nl++
            ENDIF
            ngtotal += mA * Invoice->Qty
            ntotal  += Invoice->Amount * Invoice->Qty
        ENDIF
        SELECT Invoice
        SKIP ALIAS Invoice
    ENDDO
    SELECT Invoice
    SET ORDER TO 1

    ngsttot := Round( ngtotal * ( Control->GSTRate / 100 ), 2 )
    mA      := ( ngtotal + ngsttot )
    IF mwhere == "P"
        IF ( ntotal - ngtotal ) > 0
            @ 48, 9 SAY "Total Discount ="
            @ 48, 27 SAY ntotal - ngtotal PICTURE "$99,999.99"
        ENDIF                        // ndisctotal
        @ 49, 2 SAY Control->Con_note1
        IF SubStr( Name->Add5, 1, 1 ) = "N"
            @ 49, 67 SAY ngtotal PICTURE "$999,999.99"
        ENDIF
        @ 50, 2 SAY Control->Con_note2
        IF SubStr( Name->Add5, 1, 1 ) = "N"
            @ 50, 60 SAY "G.S.T"
            @ 50, 67 SAY ngsttot PICTURE "$999,999.99"
        ENDIF
        @ 52, 52 SAY "Total"
        IF SubStr( Debit->Saleno, 1, 2 ) != SubStr( Message->Saleno5, 1, 2 )
            @ 52, 67 SAY mA PICTURE "$999,999.99"
        ELSE
            @ 52, 67 SAY ngtotal PICTURE "$999,999.99"
        ENDIF
        @ 54, 3 SAY Control->Con_note3
        @ 55, 3 SAY Control->Con_note4
        @ 56, 3 SAY Control->Con_note5
        EndPrint()
    ELSE
        @ nl, 48 SAY Debit->Saleno
        ngsttot := Round(  ngtotal * ( Control->GSTRate / 100 ), 2 )
        IF SubStr( Debit->Saleno, 1, 2 ) != SubStr( Message->Saleno5, 1, 2 )
            @ nl, 58 SAY "Incl GST" COLOR "R"
            @ nl, 68 SAY ( Int( ( ngtotal + ngsttot ) * 100 ) / 100 ) PICTURE "$999,999.99"
        ELSE
            @ nl, 54 SAY "Export No GST" COLOR "R"
            @ nl, 68 SAY ngtotal PICTURE "$999,999.99"
        ENDIF
        nl++
   /*
      IF SUBSTR( Name->Add5, 1, 1 ) != "N"
         @ nl,68 SAY ngtotal PICTURE "$99,999.99"
        ELSE
         @ nl,68 SAY ( INT( ( ngtotal+ngsttot )*100 )/100 ) PICTURE "$99,999.99"
      ENDIF
   */
    ENDIF
    SELECT Debit
    ApRLock( 3 )
    IF SubStr( Name->Add5, 1, 1 ) = "N"
        Debit->Amount   := mA
        Debit->InitAmnt := mA
        Debit->Tax      := ngsttot
    ELSE
        Debit->Amount   := ngtotal
        Debit->InitAmnt := ngtotal
    ENDIF
    UNLOCK

    SET MARGIN TO 0

    RETURN NIL

// ** End of IvcFormA()

// *-------------------------------------------------------------------

FUNCTION IvcHead()

    IF mwhere == "P"
        nl := 11
        @ nl, 61 SAY minvno
        nl++                                  // Top Page prints from
        @ nl, 3 SAY Name->Name                // This is Company Name
        nl++
        @ nl, 3 SAY Name->Add1
        @ nl, 61 SAY Debit->Dbdate PICTURE "99/99/9999"
        nl++
        @ nl, 3 SAY Name->Add2
        nl++
        @ nl, 3 SAY Name->Add3
        @ nl, 61 SAY Debit->Ordnum
        nl++
        @ nl, 3 SAY Name->Add4 + " " + Name->Zip
        nl++
        @ nl, 3 SAY Name->Add5
      /*
      IF Name->Phone != SPACE(15)
         @ nl,31 SAY Name->Phone                // Business Phone
       ELSE
         @ nl,31 SAY Name->Ephone               // Home Phone
      ENDIF
      */
        nl++
        @ nl, 70 SAY Debit->Codeno
        nl += 2
        DO CASE
        CASE Debit->Paytype = "CA"
            @ nl, 3 SAY "Cash"
        CASE Debit->Paytype = "CH"
            @ nl, 3 SAY "Cheque"
        CASE Debit->Paytype = "7D"
            @ nl, 3 SAY "7 Day Account"
        CASE Debit->Paytype = "MO"
            @ nl, 3 SAY "Monthly Account"
        CASE Debit->Paytype = "CT"
            @ nl, 3 SAY "CT" + Trim( Name->Charge );
                + " " + Name->Payref
        CASE Debit->Paytype = "DC"
            @ nl, 3 SAY "Direct Credit"
        ENDCASE
        @ nl, 22 SAY Debit->Fault
        nl += 4
    ENDIF

    RETURN nl

// **** End IvcHead

// ***------------------------------------------------------------------------

STATIC FUNCTION IvcPrice( mcont )

    SELECT Part
    mpartnum := Part->Partnum
    nrecno   := RecNo()
    mA   := 0
    nQty := 1
    mok  := "N"
    DO WHILE mok = "N"
        Scroll()
        DispBox( 0, 1, 24, 79, 2 )
        @  1, 4      SAY Trim( Name->Name ) + " " + Trim( Name->Add1 );
            + " " + cbranchId + " " + Debit->Invno          COLOR "BG+"
        @  2, 4      SAY Name->Add5                                    COLOR "BG+"
        @  4, 4      SAY Trim( Part->Partnum ) + "  " + Trim( Part->Desc ) COLOR "RG+"
        @  4, Col() + 2 SAY Part->Wholesale PICTURE "$9999,999.99"        COLOR "RG+"
        nl := 6
        hamount := hdiscount := hqty := 0
        hpdate := Date()
        mmodcode := Trim( Part->Partnum )
        equnl := ntottrade := nTotRate := nTotTime := ntotsell := 0
        SELECT Equ
        SEEK mmodcode
        IF Found()
            DO WHILE Trim( Equ->Modcode ) == mmodcode .AND. Equ->( !Eof() )
                IF equnl > 24
                    Inkey( 1 )
                    equnl := 0
                ENDIF
                @ equnl, 72 SAY SubStr( Equ->Partnum, 1, 8 ) COLOR "G+"
                equnl++
                SELECT Part
                ncost := nsell := 0
                SEEK Equ->Partnum
                IF Found()
                    nsell     := Part->Wholesale * Equ->PartQty
                    ntotsell  += nsell
                    ncost     := Part->Trade * Equ->PartQty
                    ntottrade += ncost
                ENDIF
                SELECT Equ
                SKIP ALIAS Equ
            ENDDO
        ENDIF
        @ nl, 4      SAY mmodcode + " Modules Cost"
        @ nl, Col() + 2 SAY ntottrade PICTURE "$9999,999.99"
        @ nl, Col() + 2 SAY "Sell"
        @ nl, Col() + 1 SAY ntotsell  PICTURE "$9999,999.99"
        nl++
        SELECT Part
        SET ORDER TO 1
        SEEK mpartnum                 // GOTO nrecno
        mpartnum   := Part->Partnum
        mdesc      := Part->Desc
        nl++
        IF SubStr( Part->Partnum, 3, 1 ) = "-"
            nl++
            @ nl, 6 SAY "Desc" GET mdesc PICTURE "@X"
        ENDIF
        READ
        ApRLock( 3 )
        Part->Desc := mdesc
        UNLOCK
        nl += 2
        IF Name->Margin = 0
            mA := Part->Wholesale
        ELSE
            mA := ( ( Part->Wholesale * ( 1 + Name->Margin / 100 ) * 100 ) / 100 )
        ENDIF
        ndiscount := Name->Discount
        ntrade    := Part->Trade
        cpartId   := Part->PartId
        IF mcont = "Y"                       // Use Part from Quot
            nQty      := Quot->Qty
            mA        := Quot->Amount
            ndiscount := Quot->Discount
            ntrade    := Quot->Cost
        ENDIF
        @ nl, 2      SAY "Invoice Qty" GET nQty      PICTURE "99999.99"
        @ nl, Col() + 2 SAY "Price"       GET mA        PICTURE "999999.99"
        @ nl, Col() + 2                   GET ndiscount PICTURE "99.99"
        @ nl, Col() + 2 SAY "Cost"        GET ntrade    PICTURE "999999.99"
        @ nl, Col() + 2 SAY Trim( Part->Unit )
        READ
        IF mA < Part->Wholesale
            nl++
            @ nl, 10 SAY "Sell is Less than Part Sell ??" COLOR "G+"
        ENDIF
        IF nQty <= 0
            RETURN NIL
        ENDIF
        mordnum := Space( 16 )
        SELECT Invoice
        mfind := minvno + mpartnum
        SEEK mfind
        mblank := "N"
        IF mA != Part->Wholesale
            mblank := "Y"
        ENDIF
        IF !Found() .OR. mA = 0
            mblank := "Y"
        ENDIF
        IF Invoice->Discount != ndiscount
            mblank := "Y"
        ENDIF
        IF SubStr( Part->PartId, 1, 6 ) = "LABOUR"
            mblank := "Y"
        ENDIF
        IF mblank = "Y"
            ApFLock( 3 )
            APPEND BLANK
            Invoice->Stat := "I"
            UNLOCK
        ENDIF
        SELECT Invoice
        ApRLock( 3 )
        IF mcont = "Y"
            Invoice->Ordnum := Quot->Ordnum
            Invoice->Info   := Quot->Info
            Invoice->Info2  := Quot->Info2
            Invoice->Info3  := Quot->Info3
            Invoice->Info4  := Quot->Info4
        ENDIF                                // mcont
        IF Invoice->Ordnum == Space( 16 )
            Invoice->Ordnum := Name->Remarks
        ENDIF                                // Ordnum Blank
        IF Part->PartId = "AAAA"
            Invoice->Ordnum := "ZZZZZZZZZZZZZZZZ"
            nl++
            @ nl, 10 SAY "The ZZZZZZ puts the Freight etc at the bottom don't change"
        ENDIF                                // PartId = AAAA
        nl += 2
        UNLOCK
        mordnum := Invoice->Ordnum
        minfo   := Invoice->Info
        minfo2  := Invoice->Info2
        minfo3  := Invoice->Info3
        minfo4  := Invoice->Info4
        @ nl, 11      SAY "Ordnum" GET mordnum PICTURE "@K!"
        @ nl, Col() + 3 SAY Debit->Invno COLOR "BG+"
        nl += 2
        @ nl, 8 SAY "Inv Info" GET minfo
        nl++
        @ nl, 17                GET minfo2
        nl++
        @ nl, 17                GET minfo3
        nl++
        @ nl, 17                GET minfo4
        READ
        ApRLock( 3 )
        Invoice->Ordnum    := mordnum
        Invoice->Info      := minfo
        Invoice->Info2     := minfo2
        Invoice->Info3     := minfo3
        Invoice->Info4     := minfo4
        Invoice->Invno     := minvno
        Invoice->Amount    := mA
        Invoice->Qty       += nQty                   // Adds
        Invoice->Discount  := ndiscount
        Invoice->Partnum   := Part->Partnum
        Invoice->PartId    := Part->PartId
        Invoice->Wholesale := Part->Wholesale
        IF Invoice->Qty > 0
            Invoice->Cost   := ntrade                 // From Quot or Part
        ENDIF
        Invoice->Codeno    := Name->Codeno
        Invoice->Pdate     := Date()
        UNLOCK
        SELECT Name
        ApRLock( 3 )
        Name->Remarks := Invoice->Ordnum
        UNLOCK
        SELECT  Hist
   /*
      SET ORDER TO 1
      SEEK Invoice->Codeno+Invoice->Partnum+Invoice->Invno
      IF !FOUND()
          ApFLock( 3 )
         APPEND BLANK
         UNLOCK
      ENDIF
      IF FOUND()
         IF Hist->Amount != Invoice->Amount
             ApFLock( 3 )
            APPEND BLANK
            UNLOCK
         ENDIF
         IF Hist->Discount != Invoice->Discount
             ApFLock( 3 )
            APPEND BLANK
            UNLOCK
         ENDIF
      ENDIF                      // Found
          ApRLock( 3 )
   */
        ApFLock( 3 )
        APPEND BLANK
        Hist->Amount    := Invoice->Amount
        Hist->Codeno    := Invoice->Codeno
        Hist->Partnum   := Invoice->Partnum
        Hist->Discount  := Invoice->Discount
        Hist->Qty       := Invoice->Qty
        Hist->Stat      := Invoice->Stat
        Hist->Invno     := Invoice->Invno
        Hist->PDate     := Invoice->PDate
        Hist->Wholesale := Invoice->Wholesale
        Hist->Cost      := Invoice->Cost
        Hist->BranchId  := Debit->BranchId
        Hist->Saleno    := Debit->Saleno
        Hist->U_Codeno  := Debit->U_Codeno
        Hist->Est       := Debit->Est
        UNLOCK
        // **   COMMIT
        mok := "Y"
    ENDDO                               // mok

    RETURN mpartnum

// ***------- End IvcPrice

// ****---------------------------------------------------------------

FUNCTION InvForm( mcodeno )

    Scroll()

    SELECT Control                         // Suppliers Name etc
    Scroll()
    DispBox( 0, 1, 19, 79, 2 )
    @  1, 4 SAY Name->Name + " " + Name->Add1 + " " + cbranchId + " " + Debit->Invno
    SELECT Debit
    mfault := Debit->Fault
    @  4, 5 SAY "----  TOP of Invoice"
    @  6, 5 GET mfault PICTURE "@X"
    @ 18, 5 SAY "Notes always Printed  Blank them if you don't Want"
    READ
    ApRLock( 3 )
    Debit->Fault := mfault
    UNLOCK
    SELECT Control
    mcon_note1 := Control->Con_Note1
    mcon_note2 := Control->Con_Note2
    mcon_note3 := Control->Con_Note3
    mcon_note4 := Control->Con_Note4
    mcon_note5 := Control->Con_Note5
    @  8, 5 SAY "----  Notes for Bottom of Invoice"
    @  9, 5 GET mcon_note1 PICTURE "@X"
    @ 10, 5 GET mcon_note2 PICTURE "@X"
    @ 12, 5 SAY "---------------------------------"
    @ 14, 5 GET mcon_note3 PICTURE "@X"
    @ 15, 5 GET mcon_note4 PICTURE "@X"
    @ 16, 5 GET mcon_note5 PICTURE "@X"
    READ
    ApRLock( 3 )
    Control->Con_Note1 := mcon_note1
    Control->Con_Note2 := mcon_note2
    Control->Con_Note3 := mcon_note3
    Control->Con_Note4 := mcon_note4
    Control->Con_Note5 := mcon_note5
    UNLOCK
    mok := "Y"
    IF SubStr( Control->U_Name, 1, 4 ) != "META"
        mok := ApGetY( "Standard Print Invoice" )
    ENDIF
    IF mok = "N"
        Scroll()
        SELECT Cusnotes
        coderef := minvno
        SEEK coderef
        // **           IF FOUND()

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
        // **           ENDIF            // Found Memo
        Scroll( 2, 2, 12, 78 )
        nl := 4
        SELECT Debit
        mdeladd1 := Debit->Deladd1
        mdeladd2 := Debit->Deladd2
        IF Debit->DelAdd3 = "   "
            mdelAdd3 := "Christchurch"
        ENDIF
        mdeladd3 := Debit->Deladd3
        mnote1   := Debit->Note1
        mnote2   := Debit->Note2
        mnote3   := Debit->Note3
        @ nl, 8 SAY "Delivery Address" GET mdeladd1
        nl++
        @ nl, 25 GET mdeladd2
        nl++
        @ nl, 25 GET mdeladd3 PICTURE "@KX"
        nl++
        @ nl, 5 SAY "Specific to this Invoice"
        nl++
        @ nl, 5 GET mnote1 PICTURE "@X"
        nl++
        @ nl, 5 GET mnote2 PICTURE "@X"
        nl++
        @ nl, 5 GET mnote3 PICTURE "@X"
        READ
        ApRLock ( 3 )
        Debit->Deladd1 := mdeladd1
        Debit->Deladd2 := mdeladd2
        Debit->Deladd3 := mdeladd3
        Debit->Note1   := mnote1
        Debit->Note2   := mnote2
        Debit->Note3   := mnote3
        UNLOCK
        Scroll()
    ENDIF
    mwhere := "S"
    npl    := 54

    Printsel( mwhere )                    // _LF_Init
   /*
   IF mwhere == "P"
      SET DEVICE TO PRINT
      @  0, 0 SAY Control->Con_Note11
   ENDIF
   */
    IF mwhere == "P"
        npl := 54
    ELSE
        npl := 18
    ENDIF
    msecond := "Y"
    IF mok = "Y"
        nl := 0
        IvcFormA( mcodeno )                  // Above XF_IvcFm
        IF msecond = "Y"
            nl := 0
            IvcFormA( mcodeno )
        ENDIF
    ELSE
        ChIvcFormA( mcodeno )                // ChoIvcFm
    ENDIF

    RETURN NIL
// ** End of InvForm()

// *-------------------------------------------------------------------

FUNCTION IvcLook( minvno )

    aPart_ := {}
    nivcTotal := 0
    SELECT Invoice
    SET ORDER TO 2                              // Invno+PartId+Partnum
    SEEK minvno
    Scroll()
    IF !Found()
        @ 12, 12 SAY "No Invoice in File for This Debit"
        Inkey( 2 )
    ENDIF
    ncnt := 0
    // ** IF LASTREC() != 0
    DO WHILE Invoice->Invno == minvno .AND. Invoice->( !Eof() )
        SELECT Part
        SEEK Invoice->Partnum
        SELECT Invoice
        mA := ( ( Invoice->Amount * ( 1 -Invoice->Discount / 100 ) * 100 ) / 100 );
            // Invoice->Qty
        ncnt++
        AAdd( aPart_, SubStr( Part->Desc, 1,34 ) + " " + Str( Invoice->Qty, 8, 2 );
            + " " + Str( Invoice->Amount, 10, 2 ) + " " + Str( Invoice->Discount );
            + "%" + Str( mA, 10, 2 ) )
        // **         STR( Recno(),6 )
        nivcTotal := ( nivcTotal + ( ( Invoice->Amount * ( 1 -Invoice->Discount / 100 );
            // 100 )/100 )*Invoice->Qty )
        SKIP ALIAS Invoice
    ENDDO
    SET ORDER TO 1                  // Invno+Partnum
    // ** ENDIF                       // LastRec != 0
    DispBox( 0, 1, 2, 79, 2 )
    @  1, 3      SAY Trim( Name->Name )
    @  1, Col() + 1 SAY Debit->DbDate
    @  1, Col() + 1 SAY "Invoice " + minvno + " Less GST"
    @  1, Col() + 1 SAY nivcTotal PICTURE "$999,999.99" COLOR "G+"
    Scroll(  3, 0, 24, 80 )
    DispBox( 3, 1, 24, 79, 2 )
    IF ncnt > 16
        IF !Empty( aPart_ )
            anum := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
        ENDIF
    ELSE
        IF !Empty( aPart_ )
            @  3, 00 SAY " "
            AEval( aPart_, {|A| QOUT( " " + Chr( 186 ) + "  " ), QQOut( A ), Breakpoint() } )
        ENDIF
    ENDIF                       // ncnt > 16
    SELECT Labour
    GOTO TOP
    nlabour := nlabrate := 0
    DO WHILE Labour->( !Eof() )
        IF Labour->Invno != minvno
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Partnum = Space( 20 )
            nLabour  += Labour->Time
        ELSE
            nLabrate += Labour->Time * Labour->Rate
        ENDIF
        SKIP ALIAS Labour
    ENDDO                        // Labour EOF
    IF nLabRate + nLabour > 0
        Scroll( 20, 2, 22, 78 )
        @ 21, 5      SAY minvno + " Time"
        @ 21, Col() + 1 SAY nLabour         PICTURE "9,999.99"     COLOR "BG+"
        @ 21, Col() + 1 SAY "Parts"
        @ 21, Col() + 1 SAY nLabrate        PICTURE "$999,999.99"  COLOR "BG+"
        @ 21, Col() + 2 SAY "Ivc+GST"
        @ 21, Col() + 1 SAY nivcTotal * ( ( Control->GSTRate / 100 ) + 1 );
            PICTURE "$999,999.99" COLOR "G+"
    ENDIF

    RETURN nivcTotal

// ***---- End of IvcLook()

// *-------------------------------------------------------------------

FUNCTION IvcAddP( mpartnum )

    Scroll( 3, 0, 24, 80 )
    mcont  := "N"
    nrecno := 0

    IF mpartnum = Space( 20 )
        SELECT Quot
        GOTO TOP
        SEEK mcodeno + cbranchId
        IF Found()
            aPart_ := {}
            IF LastRec() != 0
                DO WHILE Quot->Codeno == mcodeno .AND. Quot->( !Eof() )
                    IF Quot->BranchId != cbranchId
                        SKIP ALIAS Quot
                        LOOP
                    ENDIF
                    IF SubStr( Quot->Partnum, 1, 2 ) = "XX"
                        SKIP ALIAS Quot
                        LOOP
                    ENDIF
                    IF Quot->DbDate = Date()            // TESTing This Back Order
                        IF Quot->ABC = "B"
                            SKIP ALIAS Quot
                            LOOP
                        ENDIF
                    ENDIF
                    SELECT Part
                    SEEK Quot->Partnum
                    SELECT Quot
                    AAdd( aPart_, SubStr( Quot->Partnum, 1, 8 );
                        + " " + Str( Quot->Qty, 6, 2 );
                        + " " + SubStr( Part->Desc, 1, 20 );
                        + " " + SubStr( Quot->Ordnum, 1, 8 );
                        + " " + Str( Quot->Amount, 10, 2 ) + " " + Quot->Invno;
                        + " " + DToC( Quot->DbDate );
                        + "      " + Str( RecNo(), 6 ) )
                    SKIP ALIAS Quot
                ENDDO                          // Quot EOF()
                IF !Empty( aPart_ )
                    DispBox( 3, 1, 23, 79, 2 )
                    @  4, 15 SAY "PARTS in the Work Order File  " + Debit->Invno
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice( 6, 3, 22, 78, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                    SELECT Part
                    SEEK Quot->Partnum
                    mpartnum := Part->Partnum
                    Scroll(  12, 0, 24, 80 )
                    DispBox( 12, 1, 19, 79, 2 )
                    @ 14, 5 SAY Name->Name + " " + Name->Add1 + " " + cbranchId
                    @ 16, 4 SAY Trim( Part->Partnum );
                        + " " + Str( Quot->Qty, 10, 2 );
                        + " " + Trim( Part->Desc ) + " " + Trim( Part->Unit ) COLOR "G+"
                    @ 18, 5      SAY Trim( Quot->Ordnum )
                    @ 18, Col() + 4 SAY Quot->Invno + "  Amount " + Str( Quot->Amount, 10, 2 ) COLOR"G+"
                    mcont := ApGetY( "Use Part from Job Card File" )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                ENDIF                     // not Empty
            ENDIF                        // LASTREC()
        ENDIF                           // FOUND()
        IF mcont = "N"
            nrecno := 0
            SELECT Part
            quotcodeno := Name->Codeno
            Partfind( @mpartnum )                // XlF_Part

            IF PressedEsc()
                RETURN mpartnum
            ENDIF
            SELECT Name
            SEEK quotcodeno
            mcodeno  := Name->Codeno
            mpartnum := Part->Partnum
            SELECT Part
            SET ORDER TO 1
            SEEK mpartnum
            DO WHILE !Found()
                quotcodeno := Name->Codeno

                PartFind( @mpartnum )              // XLF_Part
                SELECT Name
                SEEK quotcodeno
                mcodeno  := Name->Codeno
                mpartnum := Part->Partnum
                SELECT Part
                SET ORDER TO 1
                SEEK mpartnum
                IF PressedEsc()
                    RETURN mpartnum
                ENDIF
            ENDDO                                  // Found
            mpartnum := Part->Partnum
        ENDIF                           // mcont = Y

    ELSE
        SELECT Part
        mpartnum := Part->Partnum
    ENDIF                           // mpartnum = SPACE( 20 )

    IvcPrice( mcont )                            // Below

    IF mcont = "Y"
        SELECT Quot
        ApRLock( 3 )
        Quot->Qty := ( Quot->Qty - Invoice->Qty )
        UNLOCK
        IF Quot->Qty <= 0
            SELECT EquCut
            SEEK Quot->ModSeqNo
            ApFLock( 3 )
            DO WHILE EquCut->ModSeqNo = Quot->ModSeqno .AND. EquCut->( !Eof() )
                DELETE
                SKIP ALIAS EquCut
            ENDDO
            UNLOCK
        ENDIF                         // Quot <= 0
        SELECT Quot
        ApFLock( 3 )
        DELETE ALL FOR Quot->Qty <= 0
        IF Debit->Stat = "I"
            DELETE ALL FOR SubStr( Quot->Partnum, 1, 2 ) = "XX"
        ENDIF
        UNLOCK
    ENDIF
    mpartnum := Part->Partnum
    mmodcode := SubStr( mpartnum, 1, 16 )
    nrecno2 := nrecno3 := nrecno4 := 0
    nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
    nqty1 := nqty2 := nqty3 := nqty4 := 0
    nequ1 := nequ2 := nequ3 := nequ4 := 0
    mmod2 := mmod3 := mmod4 := Space( 16 )
    ntotamnt := 0
    nquot := Invoice->Qty
    SELECT Equ
    SET EXACT ON
    GOTO TOP
    mmod1 := Trim( mpartnum )
    SEEK mmod1
    IF Found()
        DO WHILE  Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
            nqty1 := Equ->PartQty
            nequ1 := nqty1 * nquot
            SELECT Part
            SEEK Equ->Partnum
            ntotAmnt := ntotAmnt + ( Part->Wholesale * nequ1 )
            SELECT Equ
            mmod2   := SubStr( Equ->Partnum, 1, 16 )
            nrecno2 := RecNo()
            GOTO TOP
            SEEK mmod2
            IF Found()
                DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                    nqty2 := Equ->PartQty
                    nequ2 := ( nqty1 * nqty2 ) * nquot
                    SELECT Part
                    SEEK Equ->Partnum
                    ntotAmnt := ntotAmnt + ( Part->Wholesale * nequ2 )
                    SELECT Equ
                    mmod3   := SubStr( Equ->Partnum, 1, 16 )
                    nrecno3 := RecNo()
                    GOTO TOP
                    SEEK mmod3
                    SELECT Equ
                    IF Found()
                        DO WHILE  Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                            nqty3 := Equ->PartQty
                            nequ3 := nqty1 * nqty2 * nqty3 * nquot
                            SELECT Part
                            SEEK Equ->Partnum
                            ntotAmnt += ( Part->Wholesale * nequ3 )
                            SELECT Equ
                            mmod4   := SubStr( Equ->Partnum, 1, 16 )
                            nrecno4 := RecNo()
                            GOTO TOP
                            SEEK mmod4
                            IF Found()
                                DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                    nqty4 := Equ->PartQty
                                    nequ4 := Equ->PartQty * nqty3 * nqty1 * nqty2 * nquot
                                    ntotAmnt += ( Part->Wholesale * nequ4 )
                                    SELECT Equ
                                    SKIP ALIAS Equ
                                ENDDO                    // mmod4
                            ENDIF                       // FOUND mmod4
                            SELECT Equ
                            GOTO nrecno4
                            SKIP ALIAS Equ
                        ENDDO                       // mmod4
                    ENDIF                          // FOUND()  mmod3
                    SELECT Equ
                    GOTO nrecno3
                    SKIP ALIAS Equ
                ENDDO                       // mmod2
            ENDIF                          // FOUND()  mmod2
            SELECT Equ
            GOTO nrecno2
            SKIP ALIAS Equ
        ENDDO                       // mmod1
    ENDIF                          // FOUND()  mmod1
    SET EXACT OFF

    RETURN mpartnum

// ***---- End of IvcAddP()

// **----------------------- End of XF_IvcFm.PRG
