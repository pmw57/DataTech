// ** JK 08-11-11 10:45:41

// *** REM  Christine Products Specific
// ** NEW
/*  Program ......:                   CHRIVCFM.PRG
    Authors.......: John Kirby
    Date..........: 15/02/1996
    Functions.....: IvcLook, IvcPrice, IvcFormA, InvHead, InvForm
*/

#include "pcodeaah.CH"

FUNCTION IvcHead()                 // Screen

    IF mwhere == "P"
        nl := 10       // 9 // Top Page prints from
        @ nl, 1 SAY Name->Name                // This is Company Name
        IF Debit->BranchId != Space( 2 )
            SELECT Branch
            mfind := Debit->Codeno + Debit->BranchId
            SEEK mfind
            @ nl, 43 SAY Branch->Name
        ELSE
            @ nl, 43 SAY Name->Name
        ENDIF
        nl++
        @ nl, 1 SAY Name->Add1
        IF Debit->BranchId != Space( 2 )
            @ nl, 43 SAY Branch->Add1
        ELSE
            @ nl, 43 SAY Name->Add1
        ENDIF
        nl++
        @ nl, 1 SAY Name->Add2
        IF Debit->BranchId != Space( 2 )
            @ nl, 43 SAY Branch->Add2
        ELSE
            @ nl, 43 SAY Name->Add2
        ENDIF
        nl++
        @ nl, 1 SAY Name->Add3
        IF Debit->BranchId != Space( 2 )
            @ nl, 43 SAY Branch->Add3
        ELSE
            @ nl, 43 SAY Name->Add3
        ENDIF
        nl++
        @ nl, 1 SAY Trim( Name->Add4 ) + " " + Name->Phone
        IF Debit->BranchId != Space( 2 )
            @ nl, 43 SAY Trim( Branch->Add4 ) + " " + Branch->Phone
        ELSE
            @ nl, 43 SAY Trim( Name->Add4 ) + " " + Name->Phone
        ENDIF
        nl += 2
        @ nl, 6 SAY mordnum         // Invoice->Ordnum
        @ nl, 29 SAY Debit->Codeno
        @ nl, 44 SAY Debit->Dbdate PICTURE "99/99/9999"
        IF Debit->Saleno = "MANU"
            @ nl, 70 SAY Debit->Invno + "M"
        ELSE
            @ nl, 70 SAY Debit->Invno
        ENDIF
    ENDIF

    RETURN nl

// ** End of IvcHead()

// *-------------------------------------------------------------------

FUNCTION InvScreen()

    nl := 0
    @ nl, 3 SAY Name->Name                // This is Company Name
    nl++
    @ nl, 3      SAY Name->Add1
    @ nl, Col() + 4 SAY Name->Add2
    @ nl, Col() + 4 SAY Debit->BranchId
    nl++
    @ nl, 3 SAY Trim( Name->Add4 ) + " " + Name->Phone
    nl++
    @ nl, 0 SAY "-----------------------------------------------------------------------------"
    nl++
    @ nl, 3 SAY Invoice->Ordnum
    @ nl, Col() + 4 SAY Debit->Codeno
    @ nl, Col() + 4 SAY Debit->Dbdate PICTURE "99/99/9999"
    IF Debit->Saleno = "MANU"
        @ nl, Col() + 8 SAY "INVOICE " + Debit->Invno + "M"
    ELSE
        @ nl, Col() + 8 SAY "INVOICE " + Debit->Invno
    ENDIF
    nl++
    @ nl, 0 SAY "-----------------------------------------------------------------------------"
    nl += 2

    RETURN

// ***------------------ End of InvScreen()

// ***-----------------------------------------------------------------------

FUNCTION InvcHead( mordnum )          // Bromley

    nl := 10                               // Top Page prints from
    @ nl, 3 SAY Name->Name                // This is Company Name
    IF Debit->BranchId != Space( 2 )
        SELECT Branch
        mfind := Debit->Codeno + Debit->BranchId
        SEEK mfind
        @ nl, 44 SAY Branch->Name
    ELSE
        @ nl, 44 SAY Name->Name
    ENDIF
    nl++
    @ nl, 3 SAY Name->Add1
    IF Debit->BranchId != Space( 2 )
        @ nl, 44 SAY Branch->Add1
    ELSE
        @ nl, 44 SAY Name->Add1
    ENDIF
    nl++
    @ nl, 3 SAY Name->Add2
    IF Debit->BranchId != Space( 2 )
        @ nl, 44 SAY Branch->Add2
    ELSE
        @ nl, 44 SAY Name->Add2
    ENDIF
    nl++
    @ nl, 3 SAY Name->Add3                    // C,27
/*
   IF Name->Phone != SPACE(15)
      @ nl,24 SAY Name->Phone                // Business Phone
    ELSE
      @ nl,24 SAY Name->Ephone               // Home Phone
   ENDIF
*/
    IF Debit->BranchId != Space( 2 )
        @ nl, 44 SAY Branch->Add3
    ELSE
        @ nl, 44 SAY Name->Add3
    ENDIF
    nl++
    @ nl, 3 SAY Trim( Name->Add4 ) + " " + Name->Phone
    IF Debit->BranchId != Space( 2 )
        @ nl, 44 SAY Trim( Branch->Add4 ) + " " + Branch->Phone
    ELSE
        @ nl, 44 SAY Trim( Name->Add4 ) + " " + Name->Phone
    ENDIF
/*
   nl++
   IF Name->bPhone != SPACE(15)
      @ nl,22 SAY Name->bPhone                // Fax Phone
   ENDIF
*/
    nl += 5
    @ nl, 3 SAY Invoice->Ordnum         // Invoice->Ordnum
    @ nl, 25 SAY Debit->Codeno
    @ nl, 42 SAY Debit->Dbdate PICTURE "99/99/9999"
    IF Debit->Saleno = "MANU"
        @ nl, 64 SAY Debit->Invno + "M"
    ELSE
        @ nl, 64 SAY Debit->Invno
    ENDIF
    nl += 6

    RETURN

// ***------------------------- End InvcHead()

// **** -----------------------------------------------------------

FUNCTION IvcFormA4( mcodeno )        // BROMLEY

    ntotal := ngtotal := ngsttot := nweight := 0
    SELECT Invoice
    GOTO TOP
    SET ORDER TO 2
    nl := 4
    minvno := Debit->Invno
    SEEK minvno
    mordnum := Invoice->Ordnum
    IF mwhere == "P"
        SET DEVICE TO PRINT
        InvcHead()                              // Above
    ELSE
        InvScreen()
    ENDIF
    DO WHILE Invoice->Invno = minvno .AND. Invoice->( !Eof() )
        IF mwhere = "S" .AND. nl >= 18
            WAIT
            Scroll()
            InvScreen()
        ENDIF
        mpartnum := Invoice->Partnum
        IF SubStr( Invoice->Ordnum, 1, 4 ) != "ZZZZ"
            IF Invoice->Ordnum != Space( 16 )
                IF Invoice->Ordnum != mordnum
                    @ nl, 11 SAY "O/N " + Invoice->Ordnum
                    nl++
                    mordnum := Invoice->Ordnum
                ENDIF                             // Ordnum Changed
            ENDIF                                // Ordnum SPACE(16)
        ENDIF                                   // != ZZ
        IF mpartnum != Space( 20 )
            SELECT Part
            SEEK mpartnum
            IF Part->PartId != "AAAA"
                @ nl, 3 SAY SubStr( Part->Partnum, 1, 9 )        // Reduced Part Number
            ENDIF
            SELECT Part
            @ nl, 13 SAY SubStr( Part->Desc, 1, 33 )        // Can reduce Desc
            SELECT Invoice
            @ nl, 47 SAY Invoice->Qty                  PICTURE "9999"
            @ nl, 51 SAY Invoice->Amount               PICTURE "99,999.99"
            IF Invoice->Discount > 0
                @ nl, 61 SAY Str( Invoice->Discount, 2 ) + "%"
            ENDIF
            mA := ( Invoice->Amount * ( 1 -Invoice->Discount / 100 ) * 100 ) / 100.00
            @ nl, 65 SAY mA * Invoice->Qty               PICTURE "99,999.99"
            nl++
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
            ngtotal := ngtotal            + ( mA * Invoice->Qty )
            ntotal  := ntotal + ( Invoice->Amount * Invoice->Qty )
            nweight := nweight + ( Invoice->Qty * Part->Weight )
        ENDIF
        SELECT Invoice
        SKIP ALIAS Invoice
    ENDDO
    SELECT Invoice
    SET ORDER TO 1
    IF mwhere == "P"
        nl := 54
        IF ( ntotal - ngtotal ) > 0
            @ nl, 9 SAY "Total Discount ="
            @ nl, 27 SAY ntotal - ngtotal PICTURE "$99,999.99"
        ENDIF                        // ndisctotal
        nl++
        @ nl, 4 SAY Control->Con_note1
        nl++
        @ nl, 4 SAY Control->Con_note2
        @ nl, 55 SAY "Sub Total"
        @ nl, 66 SAY ngtotal PICTURE "99,999.99"
        nl++
        @ nl, 4 SAY Debit->Note1
        nl++
        @ nl, 4 SAY Debit->Note2
        IF SubStr( Debit->Saleno, 1, 2 ) != SubStr( Message->Saleno5, 1, 2 )
            ngsttot := Round(  ngtotal * ( Control->GSTRate / 100 ), 2 )
            mA := ( ngtotal + ngsttot )
            @ nl, 55 SAY "G.S.T."
            @ nl, 66 SAY ngsttot PICTURE "99,999.99"
        ELSE
            mA := ngtotal
        ENDIF
        nl++
        @ nl, 4 SAY Debit->Note3
        nl++
        @ nl, 55 SAY "Total"
        @ nl, 66 SAY mA PICTURE "99,999.99"
        // ***     IvcBottom()
        SELECT Debit
        ApRLock( 3 )
        Debit->Amount   := mA
        Debit->InitAmnt := mA
        Debit->Tax      := ngsttot
        Debit->Freight  := nweight
        UNLOCK
        // **   @  0, 0 SAY P_RESET
        SET DEVICE TO SCREEN
    ELSE
        nl := 22
        @ nl, 20      SAY "Weight" COLOR "RG"
        @ nl, Col() + 1 SAY nweight PICTURE "9,999.99"
        @ nl, Col() + 1 SAY "kg"
        @ nl, 48 SAY Debit->Saleno
        nl++
        ngsttot := Round(  ngtotal * ( Control->GSTRate / 100 ), 2 )
        IF ( ntotal - ngtotal ) > 0
            @ nl, 9 SAY "Total Discount ="
            @ nl, 27 SAY ntotal - ngtotal PICTURE "$99,999.99"
        ENDIF                        // ndisctotal
        IF SubStr( Debit->Saleno, 1, 2 ) != SubStr( Message->Saleno5, 1, 2 )
            @ nl, 58 SAY "Incl GST" COLOR "R"
            @ nl, 68 SAY ( Int( ( ngtotal + ngsttot ) * 100 ) / 100 ) PICTURE "$999,999.99"
        ELSE
            @ nl, 54 SAY "Export No GST" COLOR "R"
            @ nl, 68 SAY ngtotal PICTURE "$999,999.99"
        ENDIF
        SELECT Debit
        ApRLock( 3 )
        Debit->Freight  := nweight
        UNLOCK
        WAIT
    ENDIF
    SET MARGIN TO 0
    IF mwhere == "P"
        Scroll()
        @ 17, 10 SAY "YOU HAVE SELECTED PRINTER FOR THIS INVOICE" COLOR "RG+"
        @ 18, 10 SAY "YOU CAN PRINT AGIAN IF YOU WISH"            COLOR "RG+"
        Inkey( 2 )
        Scroll()
        mwhere = "S"
        IvcFormA4()
    ENDIF

    RETURN NIL

// ** End of IvcFormA4()

// *-------------------------------------------------------------------

FUNCTION IvcFormA( mcodeno )    // CPL Screen

    ntotal := ngtotal := ngsttot := nweight := 0
    SELECT Invoice
    GOTO TOP
    SET ORDER TO 2
    minvno := Debit->Invno
    SEEK minvno
    mordnum := Invoice->Ordnum
    nl := 20
    IF mwhere = "P"
        SET DEVICE TO PRINT
        @  0, 0 SAY P_PL51
        nl := IvcHead()
        nl := 20
    ELSE                                    // To Screen
        nl := 0
        @ nl, 3 SAY Name->Name                // This is Company Name
        nl++
        @ nl, 3      SAY Name->Add1
        @ nl, Col() + 4 SAY Name->Add2
        @ nl, Col() + 4 SAY Debit->BranchId
        nl++
        @ nl, 3 SAY Trim( Name->Add4 ) + " " + Name->Phone
        nl++
        @ nl, 0 SAY "-----------------------------------------------------------------------------"
        nl++
        @ nl, 3      SAY mordnum
        @ nl, Col() + 4 SAY Debit->Codeno
        @ nl, Col() + 4 SAY Debit->Dbdate PICTURE "99/99/9999"
        IF Debit->Saleno = "MANU"
            @ nl, Col() + 8 SAY "INVOICE " + Debit->Invno + "M"
        ELSE
            @ nl, Col() + 8 SAY "INVOICE " + Debit->Invno
        ENDIF
        nl++
        @ nl, 0 SAY "-----------------------------------------------------------------------------"
        nl += 2
    ENDIF
    DO WHILE Invoice->Invno = minvno .AND. Invoice->( !Eof() )
        IF mwhere = "S" .AND. nl >= 18
            WAIT
            Scroll()
            nl := 0
        ENDIF
        IF mwhere = "P" .AND. nl >= 36              // Adjust no of items
            // ***      @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
            SET DEVICE TO SCREEN
            @ 12, 10 SAY " "
            @ 14, 10 SAY "ALIGN PAPER to TOP OF PAGE"
            @ 16, 10 SAY " WAIT FOR PRINTER TO STOP"
            Inkey( 0 )
            SET DEVICE TO PRINT
            @  0, 0 SAY P_PL51
            nl := IvcHead()                 // Below
            nl := 20
        ENDIF                                // mwhere
        mpartnum := Invoice->Partnum
        IF SubStr( Invoice->Ordnum, 1, 4 ) != "ZZZZ"
            IF Invoice->Ordnum != Space( 16 )
                IF Invoice->Ordnum != mordnum
                    @ nl, 11 SAY "O/N " + Invoice->Ordnum
                    nl++
                    mordnum := Invoice->Ordnum
                ENDIF                             // Ordnum Changed
            ENDIF                                // Ordnum SPACE(16)
        ENDIF                                   // != ZZ
        IF mpartnum != Space( 20 )
            SELECT Part
            SEEK mpartnum
            IF Part->PartId != "AAAA"
                @ nl, 0 SAY SubStr( Part->Partnum, 1, 11 )        // Reduced Part Number
            ENDIF
            SELECT Part
            @ nl, 12 SAY SubStr( Part->Desc, 1, 35 )        // Can reduce Desc
            SELECT Invoice
            @ nl, 48 SAY Invoice->Qty                  PICTURE "9999"
            @ nl, 53 SAY Invoice->Amount               PICTURE "99,999.99"
            IF Invoice->Discount > 0
                @ nl, 63 SAY Str( Invoice->Discount, 3 ) + " %"
            ENDIF
            mA := ( Invoice->Amount * ( 1 -Invoice->Discount / 100 ) * 100 ) / 100.00
            @ nl, 69 SAY mA * Invoice->Qty               PICTURE "99,999.99"
            nl++
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
            ngtotal := ngtotal            + ( mA * Invoice->Qty )
            ntotal  := ntotal + ( Invoice->Amount * Invoice->Qty )
            nweight := nweight + ( Invoice->Qty * Part->Weight )
        ENDIF
        SELECT Invoice
        SKIP ALIAS Invoice
    ENDDO
    SELECT Invoice
    SET ORDER TO 1
    IF mwhere == "P"
        nl := 38
        IF ( ntotal - ngtotal ) > 0
            @ nl, 9 SAY "Total Discount ="
            @ nl, 27 SAY ntotal - ngtotal PICTURE "$99,999.99"
        ENDIF                        // ndisctotal
        nl += 2
        @ nl, 0 SAY Control->Con_note1
        nl++
        @ nl, 0 SAY Control->Con_note2
        @ nl, 69 SAY ngtotal PICTURE "99,999.99"
        nl++
        @ nl, 0 SAY Debit->Note1
        nl++
        @ nl, 0 SAY Debit->Note2
        IF SubStr( Debit->Saleno, 1, 2 ) != SubStr( Message->Saleno5, 1, 2 )
            ngsttot := Round(  ngtotal * ( Control->GSTRate / 100 ), 2 )
            mA := ( ngtotal + ngsttot )
            @ nl, 69 SAY ngsttot PICTURE "99,999.99"
        ELSE
            mA := ngtotal
        ENDIF
        nl++
        @ nl, 0 SAY Debit->Note3
        nl += 4
        @ nl, 69 SAY mA PICTURE "99,999.99"
        SELECT Debit
        ApRLock( 3 )
        Debit->Amount   := mA
        Debit->InitAmnt := mA
        Debit->Tax      := ngsttot
        Debit->Freight  := nweight
        UNLOCK
        @  0, 0 SAY P_RESET
        SET DEVICE TO SCREEN
    ELSE
        nl := 22
        @ nl, 20      SAY "Weight" COLOR "RG"
        @ nl, Col() + 1 SAY nweight PICTURE "9,999.99"
        @ nl, Col() + 1 SAY "kg"
        @ nl, 48 SAY Debit->Saleno
        nl++
        ngsttot := Round(  ngtotal * ( Control->GSTRate / 100 ), 2 )
        IF ( ntotal - ngtotal ) > 0
            @ nl, 9 SAY "Total Discount ="
            @ nl, 27 SAY ntotal - ngtotal PICTURE "$99,999.99"
        ENDIF                        // ndisctotal
        IF SubStr( Debit->Saleno, 1, 2 ) != SubStr( Message->Saleno5, 1, 2 )
            @ nl, 58 SAY "Incl GST" COLOR "R"
            @ nl, 68 SAY ( Int( ( ngtotal + ngsttot ) * 100 ) / 100 ) PICTURE "$999,999.99"
        ELSE
            @ nl, 54 SAY "Export No GST" COLOR "R"
            @ nl, 68 SAY ngtotal PICTURE "$99,999.99"
        ENDIF
        SELECT Debit
        ApRLock( 3 )
        Debit->Freight  := nweight
        UNLOCK
        WAIT
    ENDIF
    SET MARGIN TO 0
    IF mwhere == "P"
        Scroll()
        @ 17, 10 SAY "YOU HAVE SELECTED PRINTER FOR THIS INVOICE" COLOR "RG+"
        @ 18, 10 SAY "YOU CAN PRINT AGIAN IF YOU WISH"            COLOR "RG+"
        Inkey( 2 )
        mwhere = "S"
        IvcFormA()

    ENDIF

    RETURN NIL

// ** End of IvcFormA()

// *-------------------------------------------------------------------

FUNCTION IvcLook( minvno )
    local discountAmount
    
    aPart_ := {}
    nqtyorg := nivcTotal := 0
    SELECT Invoice
    SET ORDER TO 2                              // Invno+PartId+Partnum
    SEEK minvno
    ncnt := 0
    // ** IF LASTREC() != 0
    DO WHILE Invoice->Invno == minvno .AND. Invoice->( !Eof() )
        SELECT Part
        SEEK Invoice->Partnum
        SELECT Invoice
        ApRLock( 3 )
        discountAmount := Invoice->Amount * ( 1 - Invoice->Discount / 100 )
        mA := ( ( discountAmount * 100 ) / 100 ) * Invoice->Qty
        UNLOCK
        ncnt++
        AAdd( aPart_, SubStr( Invoice->Partnum, 1,10 ) + " ";
            + SubStr( Part->Desc, 1,28 ) + " ";
            + Str( Invoice->Qty,8 ) + " ";
            + Str( Invoice->Amount, 8, 2 ) + " ";
            + Str( Invoice->Discount, 6, 2 ) + "%" + Str( mA, 9, 2 ) )
        discountAmount := Invoice->Amount * ( 1 -Invoice->Discount / 100 )
        nivcTotal := nivcTotal + ( ( discountAmount * 100 ) / 100 ) * Invoice->Qty
        SKIP ALIAS Invoice
    ENDDO
    SET ORDER TO 1                  // Invno+Partnum
    // ** ENDIF                       // LastRec != 0
    Scroll()
    DispBox( 0, 1, 2, 79, 2 )
    @  1, 7 SAY Name->Name
    @  1, 32 SAY "Invoice " + minvno + " less GST"
    @  1, Col() + 1 SAY nivcTotal PICTURE "$999,999.99"
    Scroll(  3, 0, 24, 80 )
    DispBox( 3, 1, 24, 79, 2 )
    IF ncnt > 16
        RETURN( minvno )
        IF !Empty( aPart_ )
            anum := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
        ENDIF
    ELSE
        IF !Empty( aPart_ )
            @  3, 00 SAY " "
            AEval( aPart_, {|A| QOUT( " " + Chr( 186 ) + "  " ), QQOut( A ), Breakpoint() } )
        ENDIF
    ENDIF                       // ncnt > 16

    RETURN( minvno )

// ***---- End of IvcLook()

// *-------------------------------------------------------------------

FUNCTION InvForm( mcodeno )

    Scroll()
    mamount := mqty := mA := mtotal := mgtotal := mtaxtot := 0
    mgtaxtot := mdisctot := mlabtot := mgtot := 0
    @  4, 5      SAY"Weight"
    @  4, Col() + 1 SAY Debit->Freight PICTURE "9,999.99"
    @  4, Col() + 2 SAY "kg"
    mwhere := "S"
    npl    := 54

    Printsel( mwhere )                    // _LF_Init

    IvcFormA( mcodeno )                  // Above

    RETURN

// ** End of InvForm()

// **----------------------- End of CHRIVCFM.PRG
