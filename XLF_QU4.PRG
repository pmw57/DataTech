// ** JOKIR 19/09/2013
// ** PAWILK09
/*
   Program ......:                   XLF_QU4.PRG
   Authors.......: John Kirby
   Date..........: 15/03/2002
   Functions.....: QuotJTrade, JSOperLst
   Not used......: QuotJChri
*/

FUNCTION QuotJTrade()

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"

        mequ := mstock := moper := mABC := "N"
        mequ    := "Y"
        mxy     := "N"
        mlevel  := 4
        // **   IF mequ = "Y"
        Scroll( 14, 0, 24, 80 )
        DispBox( 14, 1, 17, 79, 2 )
        mlevel := 4
        @ 15, 10 SAY "Module Level Required 2, 3, 4" GET mlevel PICTURE "9"
        READ
        cpagehd := "MPjc-" + Str( mlevel, 1, 0 )
        mxy     := "N"
        // *** ApGetN( "Include XY Parts" )
        IF mxy = "Y"
            cpagehd := "MPjc-XY" + Str( mlevel, 1, 0 )
            @ 16, 10 SAY "XY Parts Included"
        ENDIF
        // **   ENDIF
        mprogress := "Y"
        moper := "N"
        minfo := "Y"
        mABC := "N"
        mwhere := "S"
        npl    := 67
        nl     := 0

        Printsel()                               // _LF_Init

        nQty := nlength := 0
        minvno := Debit->Invno
        @ nl, 2 SAY Control->U_Name
        @ nl, 45 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        // **   @ nl,67 SAY cpagehd
        nl += 2
        SELECT Name
        SEEK Debit->Codeno
        @ nl, 0 SAY Name->Name + "  " + Debit->Est + " JC- " + minvno
        nl++
        IF Debit->BranchId != Space( 2 )
            SELECT Branch
            mfind := Debit->Codeno + Debit->BranchId
            SEEK mfind
            @ nl, 45 SAY Branch->Name
        ENDIF
        nl++
        @ nl, 2 SAY Name->Add1
        IF Debit->BranchId != Space( 2 )
            @ nl, 45 SAY Branch->Add1
        ENDIF
        nl++
        @ nl, 2 SAY Name->Add2
        IF Debit->BranchId != Space( 2 )
            @ nl, 45 SAY Branch->Add2
        ENDIF
        nl++
        @ nl, 2 SAY Name->Add3
        IF Debit->BranchId != Space( 2 )
            @ nl, 45 SAY Branch->Add3
        ENDIF
        nl++
        @ nl, 2 SAY Name->Add4
        IF Name->Phone != Space( 15 )
            @ nl, 24 SAY Name->Phone                // Business Phone
        ELSE
            @ nl, 24 SAY Name->Ephone               // Home Phone
        ENDIF
        IF Debit->BranchId != Space( 2 )
            @ nl, 45 SAY Branch->Add4
            @ nl, 64 SAY Branch->Phone             // Business Phone
        ENDIF
        nl++
        @ nl, 3 SAY Debit->Fault
        nl++
        minvno := Debit->Invno
        ntimetotal := ntotparts := 0
        SELECT Labour
        GOTO TOP
        SEEK minvno
        DO WHILE Labour->Invno = minvno .AND. Labour->( !Eof() )
            IF Labour->Partnum = Space( 20 )
                SKIP ALIAS Labour
                LOOP
            ENDIF
            // **           IF SUBSTR( Labour->Codeno, 5, 1 ) != " "
            // **              SKIP ALIAS Labour
            // **              LOOP
            // **           ENDIF
            IF SubStr( Labour->Codeno, 4, 1 ) = " "
                SKIP ALIAS Labour
                LOOP
            ENDIF
            mpartnum := Labour->Partnum
            SELECT Part
            SEEK mpartnum
            SELECT Labour
            mdesc    := SubStr( Labour->Desc, 1, 21 )
            nrate    := Labour->Rate
            nPartTot := 0
            DO WHILE Labour->Partnum = mpartnum .AND. Labour->( !Eof() )
                nTotParts += Labour->Rate * Labour->Time
                nPartTot  += Labour->Time
                SELECT Labour
                SKIP ALIAS Labour
            ENDDO
            @ nl, 0 SAY Part->Codeno    // Labour->Codeno  // Order #
            @ nl, 15 SAY SubStr( mpartnum, 1, 16 )
            @ nl, 32 SAY nPartTot  PICTURE "99,999.99"
            @ nl, 42 SAY nrate     PICTURE "999,999.99"
            @ nl, 53 SAY mdesc
            // **              @ nl,72 SAY SUBSTR( Labour->Jobnum, 1, 8 )   //Order Name
            IF SubStr( Labour->Codeno, 5, 1 ) = " "
                @ nl, 76 SAY SubStr( Labour->Codeno, 1, 4 )   // Order #
            ENDIF
            nl++
            IF nl > npl
                IF mwhere = "P"
                    EJECT
                    nl := 0
                    npn++
                    @  nl, 0 SAY Trim( Control->U_Name )
                    @  nl, 52 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  nl, 76 SAY npn PICTURE "99"
                    nl++
                    SELECT Name
                    SEEK Debit->Codeno
                    IF Found()
                        @ nl, 3 SAY Name->Name
                    ENDIF
                    @ nl, 36 SAY Trim( Debit->Est )
                    @ nl, 71 SAY Debit->Invno
                    nl++
                ELSE
                    WAIT
                    Scroll()
                    nl := 0
                    SELECT Name
                    SEEK Debit->Codeno
                    @ nl, 3 SAY Name->Name
                    @ nl, 36 SAY Debit->Est
                    @ nl, 68 SAY Debit->Invno
                    nl++
                ENDIF
            ENDIF
            // **           SELECT Labour
            // **           SKIP ALIAS Labour
        ENDDO                     // Labour  EOF
        IF nTotParts > 0
            @ nl, 36 SAY "Total Parts ="
            @ nl, 50 SAY nTotParts PICTURE "$9999,999.99"
            nl++
        ENDIF
        GOTO TOP
        SEEK minvno
        nsubtotal := 0
        DO WHILE Labour->Invno = minvno .AND. Labour->( !Eof() )
            IF Labour->Partnum != Space( 20 )
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Codeno != mcodeno
                IF nsubtotal > 0
                    @ nl, 35 SAY mcodeno + " Time"
                    @ nl, 50 SAY nsubtotal PICTURE "99,999.99"
                    @ nl, 60 SAY "--------------"
                    nl++
                ENDIF
                nsubtotal := 0
                mcodeno := Labour->Codeno
                SELECT Name
                SEEK Labour->Codeno
                @ nl, 14 SAY Name->Name
                nl++
            ENDIF
            SELECT Labour
            IF Labour->Partnum = Space( 20 )
                // **              @ nl, 0 SAY Labour->Labno
                @ nl, 1 SAY Labour->Desc
                @ nl, 57 SAY Labour->Time PICTURE "9,999.99"
                @ nl, 68 SAY Labour->Date
                nsubtotal  += Labour->Time
                nTimetotal += Labour->Time
            ENDIF
            SKIP ALIAS Labour
        ENDDO
        nl++

        mcodeno := Debit->Codeno
        minvno  := Debit->Invno
        SELECT Quot
        SET ORDER TO 2
        SEEK mcodeno
        @ nl, 10 SAY "Start Date"
        @ nl, 23 SAY DToC( Debit->StartDate )
        @ nl, 34 SAY "Due Date"
        @ nl, 44 SAY DToC( Debit->DueDate )
        @ nl, 58 SAY "O/N # " + Debit->Ordnum
        nlabpart := 0
        nl += 2
        DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !Eof() )
            IF Quot->Invno != minvno
                SKIP ALIAS Quot
                LOOP
            ENDIF
            nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
            nqty1 := nqty2 := nqty3 := nqty4 := 0
            nequ1 := nequ2 := nequ3 := nequ4 := 0
            nquot := Quot->Qty
            nequqty1 := nequqty2 := nequqty3 := nequqty4 := 0
            SELECT Equ
            mmod1 := Trim( Quot->Partnum )
            SEEK mmod1
            nequqty1 := Equ->PartQty
            SELECT Part
            SEEK Quot->Partnum
            @ nl, 0 SAY Str( Quot->Qty, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                + " " + SubStr( Part->Desc, 1, 30 );
                + " " + SubStr( Quot->Partnum, 1, 14 )
            @ nl, 67 SAY Part->Trade PICTURE "9999.99"
            nl++
            IF Quot->Partnum = Message->LabPart
                nlabpart += Quot->Qty
            ENDIF
            IF Part->Detail != Space( 43 )
                @ nl, 12 SAY Part->Detail
                nl++
            ENDIF
            IF Part->Detail1 != Space( 43 )
                @ nl, 12 SAY Part->Detail1
                nl++
            ENDIF
            IF Part->Detail2 != Space( 43 )
                @ nl, 12 SAY Part->Detail2
                nl++
            ENDIF
            IF Part->Detail3 != Space( 43 )
                @ nl, 12 SAY Part->Detail3
                nl++
            ENDIF
            mpartnum := Quot->Partnum
            SELECT EquCut
            SEEK Quot->ModSeqno
            DO WHILE EquCut->ModSeqno = Quot->Modseqno .AND. EquCut->( !Eof() )
                IF mwhere = "S"
                    IF nl > 22
                        Inkey( 0 )
                        Scroll()
                        nl := 0
                    ENDIF
                ENDIF
                @ nl, 7 SAY Str( EquCut->Qty, 8 ) + " x ";
                    + EquCut->ModRef;
                    + Str( EquCut->Length, 8, 3  )
                IF EquCut->Width > 0
                    @ nl, 65 SAY "x" + Str( EquCut->Width, 8, 3  )
                ENDIF
                nl++
                SKIP ALIAS EquCut
            ENDDO
            IF Quot->Info != Space( 45 )
                @ nl, 12 SAY Quot->Info
                nl++
            ENDIF
            IF Quot->Info2 != Space( 45 )
                @ nl, 12 SAY Quot->Info2
                nl++
            ENDIF
            IF Quot->Info3 != Space( 45 )
                @ nl, 12 SAY Quot->Info3
                nl++
            ENDIF
            IF Quot->Info4 != Space( 45 )
                @ nl, 12 SAY Quot->Info4
                nl++
            ENDIF
            IF Quot->Info5 != Space( 45 )
                @ nl, 12 SAY Quot->Info5
                nl++
            ENDIF
            IF Quot->Info6 != Space( 45 )
                @ nl, 12 SAY Quot->Info6
                nl++
            ENDIF
            IF Quot->Info7 != Space( 45 )
                @ nl, 12 SAY Quot->Info7
                nl++
            ENDIF
            IF Quot->Info8 != Space( 45 )
                @ nl, 12 SAY Quot->Info8
                nl++
            ENDIF
            IF Quot->Info9 != Space( 45 )
                @ nl, 12 SAY Quot->Info9
                nl++
            ENDIF
            IF mlevel >= 1
                SELECT Equ
                GOTO TOP
                SET EXACT ON
                mmod1 := Trim( Quot->Partnum )
                SEEK mmod1
                IF Found()
                    DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
                        IF nl > npl
                            IF mwhere = "P"
                                EJECT
                                nl := 0
                            ENDIF
                        ENDIF
                        IF mwhere = "S"
                            IF nl > 22
                                Inkey( 0 )
                                Scroll()
                                nl := 0
                            ENDIF
                        ENDIF
                        IF mxy = "N"
                            IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                                SKIP ALIAS Equ
                                LOOP
                            ENDIF
                        ENDIF
                        SELECT Part
                        SEEK Equ->Partnum
                        nqty1 := nequqty1 := Equ->PartQty
                        nequ1 := nqty1 * nquot
                        @ nl, 0 SAY "."
                        @ nl, 3 SAY Str( nequ1, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                            + " " + SubStr( Part->Desc, 1, 30 );
                            + " " + SubStr( Equ->Partnum, 1, 14 )
                        @ nl, 67 SAY Part->Trade PICTURE "9999.99"
                        IF Equ->Partnum = Message->LabPart
                            nlabpart += nequ1
                        ENDIF
                        nl++
                        IF Part->Detail != Space( 43 )
                            @ nl, 12 SAY Part->Detail
                            nl++
                        ENDIF
                        IF Part->Detail1 != Space( 43 )
                            @ nl, 12 SAY Part->Detail1
                            nl++
                        ENDIF
                        IF Part->Detail2 != Space( 43 )
                            @ nl, 12 SAY Part->Detail2
                            nl++
                        ENDIF
                        IF Part->Detail3 != Space( 43 )
                            @ nl, 12 SAY Part->Detail3
                            nl++
                        ENDIF
                        mpartnum := Equ->Partnum
                        mseek := Equ->ModSeqno + mpartnum
                        SELECT EquCut
                        GOTO TOP
                        SEEK mseek
                        DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                            @ nl, 7 SAY Str( nquot * EquCut->Qty, 4 );
                                + " x " + EquCut->ModRef;
                                + Str( EquCut->Length, 8, 3  )
                            IF EquCut->Width > 0
                                @ nl, 65 SAY "x" + Str( EquCut->Width, 8, 3  )
                            ENDIF
                            nl++
                            SKIP ALIAS EquCut
                        ENDDO
                        SELECT Equ
                        mmod2 := Trim( Equ->Partnum )
                        nrecno2 := RecNo()
                        IF mequ = "Y"
                            GOTO TOP
                            SEEK mmod2
                            IF Found()
                                IF mlevel >= 2
                                    DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                                        IF nl > npl
                                            IF mwhere = "P"
                                                EJECT
                                                nl := 0
                                            ENDIF
                                        ENDIF
                                        IF mwhere = "S"
                                            IF nl > 22
                                                Inkey( 0 )
                                                Scroll()
                                                nl := 0
                                            ENDIF
                                        ENDIF
                                        IF mxy = "N"
                                            IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                                                SKIP ALIAS Equ
                                                LOOP
                                            ENDIF
                                        ENDIF
                                        nqty2 := Equ->PartQty
                                        nequ2 := ( nqty1 * nqty2 ) * nquot
                                        nequqty2 := Equ->Partqty * nequqty1
                                        SELECT Part
                                        SEEK Equ->Partnum
                                        @ nl, 0 SAY ".."
                                        @ nl, 5 SAY Str( nequ2, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                                            + " " + SubStr( Part->Desc, 1, 30 );
                                            + " " + SubStr( Equ->Partnum, 1, 14 )
                                        @ nl, 67 SAY Part->Trade PICTURE "9999.99"
                                        IF Equ->Partnum = Message->LabPart
                                            nlabpart += nequ2
                                        ENDIF
                                        // ***            @ nl,70 SAY Equ->PartQty PICTURE "9999.999"
                                        IF mstock = "Y"
                                            IF Part->Instock > ( nequ2 * Equ->PartQty )
                                                IF SubStr( Equ->Partnum, 3, 1 ) = "-"
                                                    nl++
                                                    @ nl, 20 SAY "Part in Stock"
                                                    @ nl, 34 SAY Part->Instock PICTURE "99,999.999"
                                                    nl++
                                                    SKIP ALIAS Equ
                                                    LOOP
                                                ENDIF
                                            ENDIF
                                        ENDIF               // mstock
                                        nl++
                                        IF Part->Detail != Space( 43 )
                                            @ nl, 16 SAY Part->Detail
                                            nl++
                                        ENDIF
                                        IF Part->Detail1 != Space( 43 )
                                            @ nl, 16 SAY Part->Detail1
                                            nl++
                                        ENDIF
                                        IF Part->Detail2 != Space( 43 )
                                            @ nl, 16 SAY Part->Detail2
                                            nl++
                                        ENDIF
                                        IF Part->Detail3 != Space( 43 )
                                            @ nl, 16 SAY Part->Detail3
                                            nl++
                                        ENDIF
                                        mpartnum := Equ->Partnum
                                        mseek := Equ->ModSeqno + mpartnum
                                        SELECT EquCut
                                        GOTO TOP
                                        SEEK mseek
                                        DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                                            @ nl, 7 SAY Str( nquot * ( nequqty1 * EquCut->Qty ), 4 );
                                                + " x " + EquCut->ModRef;
                                                + Str( EquCut->Length, 8, 3  )
                                            IF EquCut->Width > 0
                                                @ nl, 65 SAY "x" + Str( EquCut->Width, 8, 3  )
                                            ENDIF
                                            nl++
                                            SKIP ALIAS EquCut
                                        ENDDO
                                        IF mlevel >= 3
                                            SELECT Equ
                                            mmod3 := Trim( Equ->Partnum )
                                            nrecno3 := RecNo()
                                            GOTO TOP
                                            SEEK mmod3
                                            IF Found()
                                                DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                                    nqty3 := Equ->PartQty
                                                    nequqty3 := Equ->PartQty * nequqty2
                                                    nequ3 := nqty1 * nqty2 * nqty3 * nquot
                                                    IF nl > npl
                                                        IF mwhere = "P"
                                                            EJECT
                                                            nl := 0
                                                        ENDIF
                                                    ENDIF
                                                    IF mwhere = "S"
                                                        IF nl > 22
                                                            Inkey( 0 )
                                                            Scroll()
                                                            nl := 0
                                                        ENDIF
                                                    ENDIF
                                                    IF mxy = "N"
                                                        IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                                                            SKIP ALIAS Equ
                                                            LOOP
                                                        ENDIF
                                                    ENDIF
                                                    SELECT Part
                                                    SEEK Equ->Partnum
                                                    @ nl, 0 SAY "..."
                                                    @ nl, 6 SAY Str( nequ3, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                                                        + " " + SubStr( Part->Desc, 1, 30 );
                                                        + " " + SubStr( Equ->Partnum, 1, 14 )
                                                    @ nl, 67 SAY Part->Trade PICTURE "9999.99"
                                                    IF Equ->Partnum = Message->LabPart
                                                        nlabpart += nequ3
                                                    ENDIF
                                                    nl++
                                                    IF Part->Detail != Space( 43 )
                                                        @ nl, 16 SAY Part->Detail
                                                        nl++
                                                    ENDIF
                                                    IF Part->Detail1 != Space( 43 )
                                                        @ nl, 16 SAY Part->Detail1
                                                        nl++
                                                    ENDIF
                                                    IF Part->Detail2 != Space( 43 )
                                                        @ nl, 16 SAY Part->Detail2
                                                        nl++
                                                    ENDIF
                                                    IF Part->Detail3 != Space( 43 )
                                                        @ nl, 16 SAY Part->Detail3
                                                        nl++
                                                    ENDIF
                                                    mpartnum := Equ->Partnum
                                                    mseek := Equ->ModSeqno + mpartnum
                                                    SELECT EquCut
                                                    GOTO TOP
                                                    SEEK mseek
                                                    DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                                                        @ nl, 7 SAY Str( nquot * ( nequqty2 * EquCut->Qty ), 4 );
                                                            + " x " + EquCut->ModRef;
                                                            + Str( EquCut->Length, 8, 3  )
                                                        IF EquCut->Width > 0
                                                            @ nl, 65 SAY "x" + Str( EquCut->Width, 8, 3  )
                                                        ENDIF
                                                        // ***         @ nl,70 SAY EquCut->Qty PICTURE "9999.99"
                                                        nl++
                                                        SKIP ALIAS EquCut
                                                    ENDDO
                                                    IF mlevel = 4
                                                        SELECT Equ
                                                        mmod4   := Trim( Equ->Partnum )
                                                        nrecno4 := RecNo()
                                                        GOTO TOP
                                                        SEEK mmod4
                                                        IF Found()
                                                            DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                                                nqty4 := Equ->PartQty
                                                                nequqty4 := nequqty3 * Equ->PartQty
                                                                nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
                                                                IF nl > npl
                                                                    IF mwhere = "P"
                                                                        EJECT
                                                                        nl := 0
                                                                    ENDIF
                                                                ENDIF
                                                                IF mwhere = "S"
                                                                    IF nl > 22
                                                                        Inkey( 0 )
                                                                        Scroll()
                                                                        nl := 0
                                                                    ENDIF
                                                                ENDIF
                                                                IF mxy = "N"
                                                                    IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                                                                        SKIP ALIAS Equ
                                                                        LOOP
                                                                    ENDIF
                                                                ENDIF
                                                                SELECT Part
                                                                SEEK Equ->Partnum
                                                                @ nl, 0 SAY "...."
                                                                @ nl, 7 SAY Str( nequ4, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                                                                    + " " + SubStr( Part->Desc, 1, 30 );
                                                                    + " " + SubStr( Equ->Partnum, 1, 14 )
                                                                @ nl, 67 SAY Part->Trade PICTURE "9999.99"
                                                                IF Equ->Partnum = Message->LabPart
                                                                    nlabpart += nequ4
                                                                ENDIF
                                                                IF mstock = "Y"
                                                                    IF Part->Instock > nequ4
                                                                        IF SubStr( Equ->Partnum, 3, 1 ) = "-"
                                                                            nl++
                                                                            @ nl, 20 SAY "Part in Stock"
                                                                            @ nl, 34 SAY Part->Instock PICTURE "99,999.999"
                                                                            nl++
                                                                            SKIP ALIAS Equ
                                                                            LOOP
                                                                        ENDIF
                                                                    ENDIF
                                                                ENDIF               // mstock
                                                                nl++
                                                                IF Part->Detail != Space( 43 )
                                                                    @ nl, 16 SAY Part->Detail
                                                                    nl++
                                                                ENDIF
                                                                IF Part->Detail1 != Space( 43 )
                                                                    @ nl, 16 SAY Part->Detail1
                                                                    nl++
                                                                ENDIF
                                                                IF Part->Detail2 != Space( 43 )
                                                                    @ nl, 16 SAY Part->Detail2
                                                                    nl++
                                                                ENDIF
                                                                IF Part->Detail3 != Space( 43 )
                                                                    @ nl, 16 SAY Part->Detail3
                                                                    nl++
                                                                ENDIF
                                                                mpartnum := Equ->Partnum
                                                                mseek := Equ->ModSeqno + mpartnum
                                                                SELECT EquCut
                                                                GOTO TOP
                                                                SEEK mseek
                                                                DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                                                                    @ nl, 7 SAY Str( nquot * ( nequqty3 * EquCut->Qty ), 4 );
                                                                        + " x " + EquCut->ModRef;
                                                                        + Str( EquCut->Length, 8, 3  )
                                                                    IF EquCut->Width > 0
                                                                        @ nl, 65 SAY "x" + Str( EquCut->Width, 8, 3  )
                                                                    ENDIF
                                                                    nl++
                                                                    SKIP ALIAS EquCut
                                                                ENDDO                                     // EquCut
                                                                SELECT Equ
                                                                SKIP ALIAS Equ
                                                            ENDDO                       // mmod4
                                                        ENDIF
                                                    ENDIF                                   // mlevel = 4
                                                    SELECT Equ
                                                    GOTO nrecno4
                                                    SKIP ALIAS Equ
                                                ENDDO                       // mmod3
                                            ENDIF                          // FOUND()  mmod3
                                        ENDIF                                 // mlevel = 3
                                        SELECT Equ
                                        GOTO nrecno3
                                        SKIP ALIAS Equ
                                    ENDDO                       // mmod2 EOF()
                                    nl++
                                ENDIF                         // Found mmod2
                            ENDIF
                        ENDIF                   // mequ Only first
                        SELECT Equ
                        GOTO nrecno2
                        SKIP ALIAS Equ
                    ENDDO                       // mmod1 EOF()
                ENDIF                          // Found mmod1
            ENDIF                                   // mlevel = 1
            SET EXACT OFF
            nl++
            SELECT Quot
            SKIP ALIAS Quot
        ENDDO                            // EOF() Quot
        IF nlabpart > 0
            @ nl, 5 SAY Message->LabPart + " = "
            @ nl, 28 SAY nlabpart PICTURE "99,999.99"
            nl++
        ENDIF
        @ nl, 5 SAY Debit->Operno
        nl++
        IF mwhere = "P"
            IF nl > 50
                nl := 0
                EJECT
            ENDIF
        ENDIF
      /*
      IF mwhere = "P"
         IF Message->Mess13 != SPACE( 40 )
            @ nl,26 SAY Message->Mess13
            nl++
         ENDIF
         @ nl, 0 SAY "Qty      MATERIALS                         Price       Date     Hours"
         nl++
         npl := nl
         nline = 1
         FOR nline = 1 TO ( 60-npl )           // Was 63
            @ nl, 0 SAY "______:___________________________________:__________:_________:___________"
            nl+=2
            IF nl >60
               EXIT
           ENDIF
           npl++
         NEXT
      ENDIF
      */
        IF mwhere = "S"
            Inkey( 0 )
            Scroll()
            nl := 0
        ENDIF
        nl++
        IF mwhere == "P"
            EndPrint()
        ELSE
            WAIT
        ENDIF
        Scroll( 18, 0, 24, 80 )
        mcontinue := "N"
        // ***   mcontinue := ApGetN( TRIM( Message->Another )+" Print" )
    ENDDO

    SELECT Quot
    SET ORDER TO 1

    RETURN mcodeno

// ***----- End of QuotJTrade()

// **---------------------------------------------------------------------

FUNCTION JSOperLst( mpartnum )

    ntimetotal := 0
    SELECT PartOper
    GOTO TOP
    SEEK mpartnum
    IF Found()
        DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !Eof() )
            IF nl > npl
                IF mwhere = "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                nl := 0
            ENDIF
            IF PartOper->Desc != Space( 40 )
                @ nl, 14 SAY PartOper->Desc
                // **              @ nl,42 SAY "Time"
                @ nl, 55 SAY PartOper->Time PICTURE "9999.99"
                // **              @ nl,55 SAY "Rate"
                // **              @ nl,60 SAY PartOper->Rate PICTURE "9999.99"
                ntimetotal += PartOper->Time
                @ nl, 70 SAY PartOper->Order
                nl++
                IF PartOper->Desc1 != Space( 40 )
                    @ nl, 14 SAY PartOper->Desc1
                    nl++
                ENDIF
                IF PartOper->Desc2 != Space( 40 )
                    @ nl, 14 SAY PartOper->Desc2
                    nl++
                ENDIF
            ENDIF
            IF PartOper->Operno != Space( 8 )
                SELECT Operate
                SET ORDER TO 1                   // Operno
                SEEK PartOper->Operno
                @ nl, 14 SAY Operate->Desc
                @ nl, 55 SAY Operate->Time PICTURE "9,999.99"
                // **              @ nl,55 SAY "Rate"
                // **              @ nl,60 SAY Operate->Rate PICTURE "9999.99"
                ntimetotal += PartOper->Time
                @ nl, 70 SAY PartOper->Order
                nl++
            ENDIF     // Partoper ! SPACE
            IF PartOper->Adminno != Space( 8 )
                SELECT Admin
                SEEK PartOper->Adminno
                @ nl, 14 SAY Admin->Desc
                nl++
            ENDIF
            IF PartOper->Drawno != Space( 8 )
                SELECT Drawing
                SEEK PartOper->Drawno
                @ nl, 14 SAY PartOper->Drawno
                @ nl, 23 SAY Drawing->Desc
                @ nl, 64 SAY Drawing->DrawLoc
                nl++
            ENDIF
            SELECT PartOper
            SKIP ALIAS PartOper
        ENDDO                     // PartOper EOF
        IF nTimeTotal > 0
            nl += 2
            @ nl, 8 SAY "Hrs Total"
            @ nl, 23 SAY nTimeTotal           PICTURE "99,999.99"
            nl++
        ENDIF
    ENDIF                   // Found

    RETURN NIL
// ***-------- End JSOperLst

// *-------------------------------------------------------------------

FUNCTION QuotJCHRI( mcodeno )

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        mequ := mstock := moper := mABC := "N"
        mequ := ApGetN( "Do You Want Module Parts" )
        moper := "N"
        // **  ApGetN( "Do You Want OPERATIONS" )
        IF mequ = "Y"
            mABC := ApGetN( "Y = Selected Modules Details ONLY" )
        ENDIF
        mwhere := "S"
        npl    :=  67
        nl     := 0

        Printsel()                               // _LF_Init

        nQty := nlength := 0
        minvno := Debit->Invno
        @ nl, 1 SAY Control->U_Name
        @ nl, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl += 2
        SELECT Name
        @ nl, 0 SAY Name->Name + "    " + Debit->Est + "  Job Card"
        nl++
        @ nl, 0 SAY Debit->Fault
        nl++
        SELECT Quot
        SET ORDER TO 2
        SEEK mcodeno
        @ nl, 0 SAY Debit->Message
        @ nl, 62 SAY "J/C # " + minvno
        // **   nl+=2
        // **   @ nl,34 SAY "Due Date"
        // **   @ nl,44 SAY DTOC( Debit->DueDate )
        nl += 2
        @ nl, 0 SAY "Name  ______________________________"
        nlabpart := 0
        nl += 2
        DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !Eof() )
            nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
            nqty1 := nqty2 := nqty3 := nqty4 := 0
            nequ1 := nequ2 := nequ3 := nequ4 := 0
            nquot := Quot->Qty
            IF Quot->Invno != minvno
                SKIP ALIAS Quot
                LOOP
            ENDIF
            SELECT Equ
            mmod1 := Trim( Quot->Partnum )
            SEEK mmod1
            IF Found()
                SELECT Part
                ApFLock( 3 )
                Part->ABC := "M"                   // to find modules
                UNLOCK
            ENDIF
            SELECT Part
            SEEK Quot->Partnum
            @ nl, 0 SAY Str( Quot->Qty, 9, 0 ) + " " + Trim( Quot->Partnum );
                + " " + Trim( Part->Desc ) + " " + Part->ABC
            nl++
            IF Quot->Partnum = Message->LabPart
                nlabpart += Quot->Qty
            ENDIF
            IF Part->Detail != Space( 43 )
                @ nl, 12 SAY Part->Detail
                nl++
            ENDIF
            IF Part->Detail1 != Space( 43 )
                @ nl, 12 SAY Part->Detail1
                nl++
            ENDIF
            IF Part->Detail2 != Space( 43 )
                @ nl, 12 SAY Part->Detail2
                nl++
            ENDIF
            IF Part->Detail3 != Space( 43 )
                @ nl, 12 SAY Part->Detail3
                nl++
            ENDIF
            mpartnum := Quot->Partnum
            IF moper = "Y"
                JSOperLst( mpartnum )
            ENDIF
            IF Part->PartMat != Space( 20 )
                IF Part->Cutno > 0
                    @ nl, 4 SAY "Cut"
                    @ nl, 8 SAY Part->Cutno PICTURE "9999"
                ENDIF
                nlength := Quot->Qty * Part->Length
                SELECT Part
                SEEK Part->PartMat
                @ nl, 14 SAY Trim( Part->Desc ) + "  " + Trim( Part->Partnum )
                nl++
            ENDIF
            IF Quot->Info != Space( 45 )
                @ nl, 12 SAY Quot->Info
                nl++
            ENDIF
            IF Quot->Info2 != Space( 45 )
                @ nl, 12 SAY Quot->Info2
                nl++
            ENDIF
            IF Quot->Info3 != Space( 45 )
                @ nl, 12 SAY Quot->Info3
                nl++
            ENDIF
            IF Quot->Info4 != Space( 45 )
                @ nl, 12 SAY Quot->Info4
                nl++
            ENDIF
            IF Quot->Info5 != Space( 45 )
                @ nl, 12 SAY Quot->Info5
                nl++
            ENDIF
            IF Quot->Info6 != Space( 45 )
                @ nl, 12 SAY Quot->Info6
                nl++
            ENDIF
            IF Quot->Info7 != Space( 45 )
                @ nl, 12 SAY Quot->Info7
                nl++
            ENDIF
            IF Quot->Info8 != Space( 45 )
                @ nl, 12 SAY Quot->Info8
                nl++
            ENDIF
            IF Quot->Info9 != Space( 45 )
                @ nl, 12 SAY Quot->Info9
                nl++
            ENDIF
            nl++
            IF mequ = "Y"
                SELECT Equ
                GOTO TOP
                SET EXACT ON
                mmod1 := Trim( Quot->Partnum )
                SEEK mmod1
                IF Found()
                    DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
                        IF nl > npl
                            IF mwhere = "P"
                                EJECT
                                nl := 0
                            ENDIF
                        ENDIF
                        IF mwhere = "S"
                            IF nl > 26
                                Inkey( 0 )
                                Scroll()
                                nl := 0
                            ENDIF
                        ENDIF
                        SELECT Part
                        SEEK Equ->Partnum
                        nqty1 := Equ->PartQty
                        nequ1 := nqty1 * nquot
                        @ nl, 0 SAY "."
                        @ nl, 2 SAY Str( nequ1, 8, 0 ) + " " + Trim( Equ->Partnum );
                            + " " + Trim( Part->Desc )
                        @ nl, 70 SAY Equ->PartQty PICTURE "9999"
                        IF Equ->Partnum = Message->LabPart
                            nlabpart += nequ1
                        ENDIF
                        IF mstock = "Y"
                            IF Part->Instock > nequ1
                                nl++
                                @ nl, 20 SAY "Part in Stock"
                                @ nl, 34 SAY Part->Instock PICTURE "99,999"
                                nl++
                                SKIP ALIAS Equ
                                LOOP
                            ENDIF
                        ENDIF           // mstock
                        nl++
                        IF Part->Detail != Space( 43 )
                            @ nl, 12 SAY Part->Detail
                            nl++
                        ENDIF
                        IF Part->Detail1 != Space( 43 )
                            @ nl, 12 SAY Part->Detail1
                            nl++
                        ENDIF
                        IF Part->Detail2 != Space( 43 )
                            @ nl, 12 SAY Part->Detail2
                            nl++
                        ENDIF
                        IF Part->Detail3 != Space( 43 )
                            @ nl, 12 SAY Part->Detail3
                            nl++
                        ENDIF

                        mpartnum := Equ->Partnum
                        IF moper = "Y"
                            JSOperLst( mpartnum )
                        ENDIF
                        IF Part->PartMat != Space( 20 )
                            IF Part->Cutno > 0
                                @ nl, 4 SAY "Cut"
                                @ nl, 8 SAY Part->Cutno PICTURE "9999"
                            ENDIF
                            nlength := nequ1 * Part->Length
                            SELECT Part
                            SEEK Part->PartMat
                            @ nl, 14 SAY Trim( Part->Desc ) + "  " + Trim( Part->Partnum )
                            nl++
                        ENDIF
                        SELECT Equ
                        IF mABC = "Y"
                            IF Equ->ABC = "C"
                                SKIP ALIAS Equ
                                LOOP
                            ENDIF
                        ENDIF
                        mmod2 := Trim( Equ->Partnum )
                        nrecno2 := RecNo()
                        GOTO TOP
                        SEEK mmod2
                        IF Found()
                            DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                                nqty2 := Equ->PartQty
                                nequ2 := ( nqty1 * nqty2 ) * nquot
                                IF nl > npl
                                    IF mwhere = "P"
                                        EJECT
                                        nl := 0
                                    ENDIF
                                ENDIF
                                IF mwhere = "S"
                                    IF nl > 26
                                        Inkey( 0 )
                                        Scroll()
                                        nl := 0
                                    ENDIF
                                ENDIF
                                SELECT Part
                                SEEK Equ->Partnum
                                @ nl, 0 SAY ".."
                                @ nl, 6 SAY Str( nequ2, 8, 0 ) + " " + Trim( Equ->Partnum );
                                    + " " + Trim( Part->Desc )
                                IF Equ->Partnum = Message->LabPart
                                    nlabpart += nequ2
                                ENDIF
                                @ nl, 70 SAY Equ->PartQty PICTURE "9,999"
                                IF mstock = "Y"
                                    IF Part->Instock > ( nequ2 * Equ->PartQty )
                                        IF SubStr( Equ->Partnum, 3, 1 ) = "-"
                                            nl++
                                            @ nl, 20 SAY "Part in Stock"
                                            @ nl, 34 SAY Part->Instock PICTURE "99,999"
                                            nl++
                                            SKIP ALIAS Equ
                                            LOOP
                                        ENDIF
                                    ENDIF
                                ENDIF               // mstock
                                nl++
                                IF Part->Detail != Space( 43 )
                                    @ nl, 16 SAY Part->Detail
                                    nl++
                                ENDIF
                                IF Part->Detail1 != Space( 43 )
                                    @ nl, 16 SAY Part->Detail1
                                    nl++
                                ENDIF
                                IF Part->Detail2 != Space( 43 )
                                    @ nl, 16 SAY Part->Detail2
                                    nl++
                                ENDIF
                                IF Part->Detail3 != Space( 43 )
                                    @ nl, 16 SAY Part->Detail3
                                    nl++
                                ENDIF

                                mpartnum := Equ->Partnum
                                IF moper = "Y"
                                    JSOperLst( mpartnum )
                                ENDIF
                                IF Part->PartMat != Space( 20 )
                                    IF Part->Cutno > 0
                                        @ nl, 4 SAY "Cut"
                                        @ nl, 8 SAY Part->Cutno PICTURE "9999"
                                    ENDIF
                                    nlength := nequ2 * Part->Length
                                    SELECT Part
                                    SEEK Part->PartMat
                                    @ nl, 18 SAY Trim( Part->Desc ) + " " + Trim( Part->Partnum )
                                    nl++
                                ENDIF
                                SELECT Equ
                                mmod3 := Trim( Equ->Partnum )
                                nrecno3 := RecNo()
                                GOTO TOP
                                SEEK mmod3
                                IF Found()
                                    DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                        nqty3 := Equ->PartQty
                                        nequ3 := nqty1 * nqty2 * nqty3 * nquot
                                        IF nl > npl
                                            IF mwhere = "P"
                                                EJECT
                                                nl := 0
                                            ENDIF
                                        ENDIF
                                        IF mwhere = "S"
                                            IF nl > 26
                                                Inkey( 0 )
                                                Scroll()
                                                nl := 0
                                            ENDIF
                                        ENDIF
                                        SELECT Part
                                        SEEK Equ->Partnum
                                        @ nl, 0 SAY "..."
                                        @ nl, 6 SAY Str( nequ3, 8, 0 ) + " " + Trim( Equ->Partnum );
                                            + " " + Trim( Part->Desc )
                                        @ nl, 70 SAY Equ->PartQty PICTURE "9999"
                                        IF Equ->Partnum = Message->LabPart
                                            nlabpart += nequ3
                                        ENDIF
                                        nl++
                                        IF Part->Detail != Space( 43 )
                                            @ nl, 16 SAY Part->Detail
                                            nl++
                                        ENDIF
                                        IF Part->Detail1 != Space( 43 )
                                            @ nl, 16 SAY Part->Detail1
                                            nl++
                                        ENDIF
                                        IF Part->Detail2 != Space( 43 )
                                            @ nl, 16 SAY Part->Detail2
                                            nl++
                                        ENDIF
                                        IF Part->Detail3 != Space( 43 )
                                            @ nl, 16 SAY Part->Detail3
                                            nl++
                                        ENDIF
                                        mpartnum := Equ->Partnum
                                        IF moper = "Y"
                                            JSOperLst( mpartnum )
                                        ENDIF
                                        IF Part->PartMat != Space( 20 )
                                            IF Part->Cutno > 0
                                                @ nl, 4 SAY "Cut"
                                                @ nl, 8 SAY Part->Cutno PICTURE "9999"
                                            ENDIF
                                            nlength := nequ3 * Part->Length
                                            SELECT Part
                                            SEEK Part->PartMat
                                            @ nl, 18 SAY Trim( Part->Desc ) + "  " + Trim( Part->Partnum )
                                            nl++
                                        ENDIF
                                        SELECT Equ
                                        mmod4   := Trim( Equ->Partnum )
                                        nrecno4 := RecNo()
                                        GOTO TOP
                                        SEEK mmod4
                                        IF Found()
                                            DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                                nqty4 := Equ->PartQty
                                                nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
                                                IF nl > npl
                                                    IF mwhere = "P"
                                                        EJECT
                                                        nl := 0
                                                    ENDIF
                                                ENDIF
                                                IF mwhere = "S"
                                                    IF nl > 26
                                                        Inkey( 0 )
                                                        Scroll()
                                                        nl := 0
                                                    ENDIF
                                                ENDIF
                                                SELECT Part
                                                SEEK Equ->Partnum
                                                @ nl, 0 SAY "...."
                                                @ nl, 6 SAY Str( nequ4, 8, 0 ) + " " + Trim( Equ->Partnum );
                                                    + " " + Trim( Part->Desc )
                                                @ nl, 70 SAY Equ->PartQty PICTURE "9999"
                                                IF Equ->Partnum = Message->LabPart
                                                    nlabpart += nequ4
                                                ENDIF
                                                IF mstock = "Y"
                                                    IF Part->Instock > nequ4
                                                        IF SubStr( Equ->Partnum, 3, 1 ) = "-"
                                                            nl++
                                                            @ nl, 20 SAY "Part in Stock"
                                                            @ nl, 34 SAY Part->Instock PICTURE "99,999.999"
                                                            nl++
                                                            SKIP ALIAS Equ
                                                            LOOP
                                                        ENDIF
                                                    ENDIF
                                                ENDIF               // mstock
                                                nl++
                                                IF Part->Detail != Space( 43 )
                                                    @ nl, 16 SAY Part->Detail
                                                    nl++
                                                ENDIF
                                                IF Part->Detail1 != Space( 43 )
                                                    @ nl, 16 SAY Part->Detail1
                                                    nl++
                                                ENDIF
                                                IF Part->Detail2 != Space( 43 )
                                                    @ nl, 16 SAY Part->Detail2
                                                    nl++
                                                ENDIF
                                                IF Part->Detail3 != Space( 43 )
                                                    @ nl, 16 SAY Part->Detail3
                                                    nl++
                                                ENDIF
                                                mpartnum := Equ->Partnum
                                                IF moper = "Y"
                                                    JSOperLst( mpartnum )
                                                ENDIF
                                                IF Part->PartMat != Space( 20 )
                                                    IF Part->Cutno > 0
                                                        @ nl, 4 SAY "Cut"
                                                        @ nl, 8 SAY Part->Cutno PICTURE "9999"
                                                    ENDIF
                                                    nlength := nequ4 * Part->Length
                                                    SELECT Part
                                                    SEEK Part->PartMat
                                                    @ nl, 18 SAY Trim( Part->Desc ) + " " + Trim( Part->Partnum )
                                                    nl++
                                                ENDIF
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
                            nl++
                        ENDIF                         // Found mmod2
                        SELECT Equ
                        GOTO nrecno2
                        SKIP ALIAS Equ
                    ENDDO                       // mmod1 EOF()
                ENDIF                          // Found mmod1
                SET EXACT OFF
            ENDIF                            // mequ Selected   Modules
            SELECT Quot
            SKIP ALIAS Quot
        ENDDO                            // EOF() Quot
        IF nlabpart > 0
            @ nl, 5 SAY Message->LabPart + " = "
            @ nl, 28 SAY nlabpart PICTURE "9,999,999.99"
            nl++
        ENDIF
        nl++
        IF mwhere = "P"
            IF nl > 36
                nl := 0
                EJECT
            ENDIF
        ENDIF
        IF mwhere = "P"
            IF Message->Mess13 != Space( 40 )
                @ nl, 26 SAY Message->Mess13
                nl++
            ENDIF
            @ nl, 0 SAY "DATE         HOURS "
            nl++
            npl := nl
            nline = 1
            FOR nline = 1 TO ( 60 -npl )           // Was 63
                @ nl, 0 SAY "___________: __________:____________________________________________"
                nl += 2
                IF nl > 60
                    EXIT
                ENDIF
                npl++
            NEXT
        ENDIF
        IF mwhere = "S"
            Inkey( 0 )
            Scroll()
            nl := 0
        ENDIF
        nl++
        IF mwhere == "P"
            EndPrint()
        ELSE
            WAIT
        ENDIF
        Scroll( 18, 0, 24, 80 )
        mcontinue := "N"
    ENDDO

    SELECT Quot
    SET ORDER TO 1

    RETURN mcodeno

// ****** End of QuotJChri()

// **--------------------- End of XLF_QU4.PRG
