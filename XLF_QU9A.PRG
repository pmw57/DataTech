// ** JK 09-07-11 15:59:44

/*
   Program.....:                  XLF_QU9A.PRG
   Author......: J.Kirby
   Date........: 24/11/2009
   Functions...: LabEdit, POEdit
   Not used....: JCNOXY
*/

FUNCTION JCNOXY( mcodeno )

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"


        METJCut( mcodeno )          // Metal Only ???

        IF mwhere = "S"
            WAIT
            Scroll()
        ENDIF
        mok := "N"
        minvno := Debit->Invno
        mselect := cbuyonly := "N"
        mequ := "Y"
        cbuyonly := "Y"
        mstock := moper := mABC := "N"
        mequ    := "Y"
        mxy     := "N"
        mlevel  := 4
        mdetail := "N"
        // **   @ 12,10 SAY "Module Level Required 2, 3, 4" GET mlevel PICTURE "9"
        // **    READ
        cpagehd := "PCuts" + Str( mlevel, 1 )
        // **   mxy     := ApGetN( "Include XY Parts" )
        mdetail := "N"
        // ** ApGetN( "Length Details Required" )
        minfo := "Y"
        // **   mwhere := "S"
        npl    := 54
        nl     := 0
        @ 12, 10 SAY "THIS IS IF PRINTING OF CUTS Parts etc"
        @ 14, 10 SAY "WASTES PAPER IF NO CUTS BEWARE"

        Printsel()                               // _LF_Init

        IF mwhere == "P"
            npl := 54
            @  0, 0
            EJECT
            // **      SET DEVICE TO PRINT
        ELSE
            Scroll()
            npl := 22
        ENDIF
        @ 0, 0 SAY Control->U_Name
        @ 0, 45 SAY Str( Day(  Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @ 0, 67 SAY cpagehd
        nl := 2
        nQty := nlength := 0
        SELECT Name
        SEEK Debit->Codeno
        @ nl, 5 SAY Name->Name + "  " + Debit->Est + "   " + minvno
        nl += 2
        @  nl, 10 SAY "IMPORTANT  Cut List  TO LEVEL 4  ONLY " + minvno
        nl += 2
        @ nl, 10 SAY "Start Date"
        @ nl, 23 SAY DToC( Debit->StartDate )
        @ nl, 34 SAY "Due Date"
        @ nl, 44 SAY DToC( Debit->DueDate )
        @ nl, 58 SAY "O/N # " + Debit->Ordnum
        nl += 2
        SELECT Quot
        SET ORDER TO 2
        SEEK mcodeno
        DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !Eof() )
            IF Quot->Invno != minvno
                SKIP ALIAS Quot
                LOOP
            ENDIF
            nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
            nqty1 := nqty2 := nqty3 := nqty4 := 0
            nequ1 := nequ2 := nequ3 := nequ4 := 0
            nequqty1 := nequqty2 := nequqty3 := nequqty4 := 0
            nquot := Quot->Qty
            SELECT Equ
            mmod1 := Trim( Quot->Partnum )
            SEEK mmod1
            SELECT Part
            SEEK Quot->Partnum
            mpartnum := Quot->Partnum
            SELECT EquCut
            SEEK Quot->ModSeqno
            IF Part->Unit != "Each      "
                @ nl, 0 SAY Str( Quot->Qty, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                    + " " + Part->Desc;
                    + "  " + SubStr( Quot->Partnum, 1, 16 )
                nl += 2
                DO WHILE EquCut->ModSeqno = Quot->Modseqno .AND. EquCut->( !Eof() )
                    IF mwhere = "S"
                        IF nl > 22
                            Inkey( 0 )
                            Scroll()
                            nl := 0
                        ENDIF
                    ENDIF
                    IF EquCut->Width > 0
                        @ nl, 1 SAY Str( nquot * EquCut->Qty, 8 ) + " x ";
                            + EquCut->ModRef;
                            + Str( EquCut->Length, 8, 3  )
                        @ nl, 66 SAY "x" + Str( EquCut->Width, 8, 3  )
                    ELSE
                        @ nl, 17 SAY Str( nquot * EquCut->Qty, 8 ) + " x ";
                            + EquCut->ModRef;
                            + Str( EquCut->Length, 8, 3  )
                    ENDIF
                    nl++
                    SKIP ALIAS EquCut
                ENDDO
            ENDIF           // Each
            IF mlevel >= 1
                SELECT Equ
                GOTO TOP
                SET EXACT ON
                mmod1 := Trim( Quot->Partnum )
                SEEK mmod1
                IF Found()
                    DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
                        nrecno1 := RecNo()
                        IF nl > npl
                            IF mwhere = "P"
                                EJECT
                                nl := 2
                            ENDIF
                            @  0, 0 SAY Control->U_Name
                            @  0, 45 SAY Str( Day(  Date() ), 3 ) + " " + CMonth( Date() );
                                + Str( Year( Date() ), 5 )
                            @  0, 67 SAY cpagehd
                        ENDIF
                        IF mwhere = "S"
                            IF nl > 22
                                Inkey( 0 )
                                Scroll()
                                nl := 0
                            ENDIF
                        ENDIF
                        IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                            SKIP ALIAS Equ
                            LOOP
                        ENDIF
                        SELECT Part
                        SEEK Equ->Partnum
                        nqty1 := nequqty1 := Equ->PartQty
                        nequ1 := nqty1 * nquot
                        mpartnum := Equ->Partnum
                        mseek := Equ->ModSeqno + mpartnum
                        IF Part->Unit != "Each      "
                            SELECT EquCut
                            GOTO TOP
                            SEEK mseek
                            IF Found()
                                @ nl, 0 SAY Equ->ABC + "."
                                @ nl, 3 SAY Str( nequ1, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                                    + " " + SubStr( Part->Desc, 1, 22 );
                                    + " " + SubStr( Equ->Partnum, 1, 16 );
                                    + " " + SubStr( Equ->Modcode, 1, 20 )
                                nl++
                                IF mdetail = "Y"
                                    // **            @ nl, 5 SAY SUBSTR( Part->Unit, 1, 6 )
                                    @ nl, 13 SAY "Length Mtr" + Str( Part->Length, 8, 3  )
                                    @ nl, 32 SAY "Width mm " + Str( Part->Width, 8, 3 )
                                    @ nl, 50 SAY "Thick mm " + Str( Part->Thick, 8, 3 )
                                    @ nl, 69 SAY Part->Codeno
                                    nl++
                                ENDIF                        // mdetail = Y
                            ENDIF
                            nCutSum := 0
                            DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                                DO CASE
                                CASE Part->Unit = "Mtr       "
                                    nTotQty := Quot->Qty * EquCut->Qty
                                    @ nl, 2 SAY nTotQty PICTURE "9,999"
                                    @ nl, 8 SAY EquCut->ModRef + " " + Str( EquCut->Length, 8, 3 ) + " Mtr"
                                    nCut := Int( Part->Length / EquCut->Length )
                                    nCutTot := nTotQty / nCut
                                    IF nCutTot > Int( nCutTot )
                                        nCutTot := nCutTot
                                    ELSE
                                        nCutTot := nCutTot
                                    ENDIF
                                    IF mdetail = "Y"
                                        // **                 @ nl,54 SAY nCutTot PICTURE "999.999 Lths"
                                        @ nl, 67 SAY ( Part->Length / EquCut->Length ) PICTURE "999 Per/Ln"
                                        // **              @ nl,74 SAY ( Part->Length/EquCut->Length )/nTotQty PICTURE "99"
                                        // **              @ nl,62 SAY ( Part->Length-EquCut->Length ) PICTURE "99.999"
                                        // **              @ nl,70 SAY ( Part->Length/EquCut->Length )*/( nTotQty*EquCut->Length ) PICTURE "999.999"
                                    ELSE
                                        @ nl, 70 SAY nTotQty * EquCut->Length PICTURE "9,999.999"
                                    ENDIF                    // mdetail
                                    nCutSum += nCutTot
                                    nl++
                                CASE Part->Unit = "Sq Mtr    "
                                    ntotqty := Quot->Qty * EquCut->Qty
                                    @ nl, 4 SAY Str( ntotqty, 1, 5 );
                                        + " x " + EquCut->ModRef;
                                        + " " + Str( EquCut->Length, 6, 3 ) + " Mtr";
                                        + " " + Str( ( EquCut->Width ), 6, 3 ) + " Mtr"
                                    @ nl, 72 SAY ( EquCut->Length * EquCut->Width ) PICTURE "999.999"
                                    // ***                @ nl, 4 SAY "Each Qty"+STR( EquCut->Qty, 4 )+" "+EquCut->ModRef;
                                    nl++
                                ENDCASE
                                IF mdetail = "Y"
                                    IF nCutSum > 0
                                        DO CASE
                                        CASE nCutSum > Int( nCutTot )
                                            nCutSum := nCutSum + 1
                                        CASE nCutTot < 1
                                            nCutSum := nCutSum + 1
                                        ENDCASE
                                        // **         @ nl,56 SAY INT( nCutSum ) PICTURE "Total Lengths =9,999"
                                    ENDIF
                                ENDIF                    // mdetail
                                SKIP ALIAS EquCut
                            ENDDO
                            nl++
                        ENDIF
                        SELECT Equ
                        mmod2 := Trim( Equ->Partnum )
                        // **  IF mequ = "Y"
                        GOTO TOP
                        SEEK mmod2
                        IF Found()
                            IF mlevel >= 2
                                DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                                    nrecno2 := RecNo()
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
                                        IF Equ->ABC = "x"
                                            SKIP ALIAS Equ
                                            LOOP
                                        ENDIF
                                    ENDIF
                                    IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                        SKIP ALIAS Equ
                                        LOOP
                                    ENDIF
                                    nqty2 := Equ->PartQty
                                    nequqty2 := nequqty1 * Equ->PartQty
                                    nequ2 := ( nqty1 * nqty2 ) * nquot
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    mpartnum := Equ->Partnum
                                    mseek := Equ->ModSeqno + mpartnum
                                    IF Part->Unit != "Each      "
                                        SELECT EquCut
                                        GOTO TOP
                                        SEEK mseek
                                        IF Found()
                                            @ nl, 0 SAY Equ->ABC + ".."
                                            @ nl, 4 SAY Str( nequ2, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                                                + " " + SubStr( Part->Desc, 1, 22 );
                                                + " " + SubStr( Equ->Partnum, 1, 16 );
                                                + " " + SubStr( Equ->Modcode, 1, 20 )
                                            nl++
                                            IF mdetail = "Y"
                                                // **            @ nl, 5 SAY SUBSTR( Part->Unit, 1, 6 )
                                                @ nl, 13 SAY "Length Mtr" + Str( Part->Length, 8, 3  )
                                                @ nl, 32 SAY "Width mm " + Str( Part->Width, 8, 3 )
                                                @ nl, 50 SAY "Thick mm " + Str( Part->Thick, 8, 3 )
                                                @ nl, 69 SAY Part->Codeno
                                                nl++
                                            ENDIF                        // mdetail = Y
                                        ENDIF
                                        nCutSum := 0
                                        DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                                            DO CASE
                                            CASE Part->Unit = "Mtr       "
                                                nTotQty := Quot->Qty * EquCut->Qty
                                                @ nl, 4 SAY nequqty1 * EquCut->Qty PICTURE "9,999"
                                                @ nl, 10 SAY "x " + EquCut->ModRef + " " + Str( EquCut->Length, 8, 3 ) + " Mtr"
                                                nCut := Int( Part->Length / EquCut->Length )
                                                nCutTot := nTotQty / nCut
                                                IF nCutTot > Int( nCutTot )
                                                    nCutTot := nCutTot
                                                ELSE
                                                    nCutTot := nCutTot
                                                ENDIF
                                                IF mdetail = "Y"
                                                    IF nCutTot > 0
                                                        // **                @ nl,53 SAY nCutTot PICTURE "999.999 Lths"
                                                        @ nl, 69 SAY ( Part->Length / EquCut->Length ) PICTURE "999 Per/Ln"
                                                    ELSE
                                                        @ nl, 70 SAY nTotQty * EquCut->Length PICTURE "9,999.999"
                                                    ENDIF
                                                    nCutSum += nCutTot
                                                ENDIF
                                                nl++
                                            CASE Part->Unit = "Sq Mtr    "
                                                nTotQty := Quot->Qty * EquCut->Qty
                                                @ nl, 4 SAY nequqty1 * EquCut->Qty PICTURE "9,999"
                                                @ nl, 10 SAY SubStr( EquCut->ModRef, 1, 34 );
                                                    + " " + Str( EquCut->Length, 6, 3 ) + " Mtr";
                                                    + " " + Str( ( EquCut->Width ), 6, 3 ) + " Mtr"
                                                @ nl, 70 SAY ( EquCut->Length * EquCut->Width ) PICTURE "999.999"
                                                nl++
                                            ENDCASE
                                            IF nCutSum > 0
                                                DO CASE
                                                CASE nCutSum > Int( nCutTot )
                                                    nCutSum := nCutSum + 1
                                                CASE nCutTot < 1
                                                    nCutSum := nCutSum + 1
                                                ENDCASE
                                            ENDIF
                                            SKIP ALIAS EquCut
                                        ENDDO
                                        IF mdetail = "Y"
                                            IF nCutSum > 0
                                                // **         @ nl,54 SAY INT( nCutSum ) PICTURE "Total Lengths =9,999"
                                                // **         nl++
                                            ENDIF
                                        ENDIF
                                    ENDIF                  // Each
                                    IF mlevel >= 3
                                        SELECT Equ
                                        mmod3 := Trim( Equ->Partnum )
                                        nrecno3 := RecNo()
                                        // **      nequPartQty := Equ->PartQty
                                        GOTO TOP
                                        SEEK mmod3
                                        IF Found()
                                            DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                                nrecno3 := RecNo()
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
                                                    IF Equ->ABC = "x"
                                                        SKIP ALIAS Equ
                                                        LOOP
                                                    ENDIF
                                                ENDIF
                                                IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                                    SKIP ALIAS Equ
                                                    LOOP
                                                ENDIF
                                                nqty3 := Equ->PartQty
                                                nequqty3 := nequqty2 * Equ->PartQty
                                                nequ3 := nqty1 * nqty2 * nqty3 * nquot
                                                SELECT Part
                                                SEEK Equ->Partnum
                                                mpartnum := Equ->Partnum
                                                mseek := Equ->ModSeqno + mpartnum
                                                IF Part->Unit != "Each      "
                                                    SELECT EquCut
                                                    GOTO TOP
                                                    SEEK mseek
                                                    IF Found()
                                                        @ nl, 0 SAY Equ->ABC + "..."
                                                        @ nl, 5 SAY Str( nequ3, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                                                            + " " + SubStr( Part->Desc, 1, 22 );
                                                            + " " + SubStr( Equ->Partnum, 1, 16 );
                                                            + " " + SubStr( Equ->Modcode, 1, 20 )
                                                        nl++
                                                        IF mdetail = "Y"
                                                            // **            @ nl, 5 SAY SUBSTR( Part->Unit, 1, 6 )
                                                            @ nl, 13 SAY "Length Mtr" + Str( Part->Length, 8, 3  )
                                                            @ nl, 32 SAY "Width mm " + Str( Part->Width, 8, 3 )
                                                            @ nl, 50 SAY "Thick mm " + Str( Part->Thick, 8, 3 )
                                                            @ nl, 69 SAY Part->Codeno
                                                            nl++
                                                        ENDIF                        // mdetail = Y
                                                    ENDIF
                                                    nCutSum := 0
                                                    DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                                                        DO CASE
                                                        CASE Part->Unit = "Mtr       "
                                                            nTotQty := Quot->Qty * EquCut->Qty
                                                            @ nl, 4 SAY nquot * ( nequqty2 * EquCut->Qty ) PICTURE "9,999"
                                                            @ nl, 10 SAY "x " + EquCut->ModRef + " " + Str( EquCut->Length, 8, 3 ) + " Mtr"
                                                            nCut := Int( Part->Length / EquCut->Length )
                                                            nCutTot := nTotQty / nCut
                                                            IF nCutTot > Int( nCutTot )
                                                                nCutTot := nCutTot
                                                            ELSE
                                                                nCutTot := nCutTot
                                                            ENDIF
                                                            IF mdetail = "Y"
                                                                IF nCutTot > 0
                                                                    // **                  @ nl,53 SAY nCutTot PICTURE "999.999 Lths"
                                                                    @ nl, 69 SAY ( Part->Length / EquCut->Length ) PICTURE "999 Per/Ln"
                                                                ELSE
                                                                    @ nl, 70 SAY nTotQty * EquCut->Length PICTURE "9,999.999"
                                                                ENDIF
                                                                nCutSum += nCutTot
                                                            ENDIF
                                                            nl++
                                                        CASE Part->Unit = "Sq Mtr    "
                                                            nTotQty := Quot->Qty * EquCut->Qty
                                                            @ nl, 4 SAY nquot * ( nequqty2 * EquCut->Qty ) PICTURE "9,999"
                                                            @ nl, 10 SAY EquCut->ModRef;
                                                                + " " + Str( EquCut->Length, 6, 3 ) + " Mtr";
                                                                + " " + Str( ( EquCut->Width ), 6, 3 ) + " Mtr"
                                                            @ nl, 70 SAY ( EquCut->Length * EquCut->Width ) PICTURE "999.999"
                                                            nl++
                                                        ENDCASE
                                                        IF nCutSum > 0
                                                            DO CASE
                                                            CASE nCutSum > Int( nCutTot )
                                                                nCutSum := nCutSum + 1
                                                            CASE nCutTot < 1
                                                                nCutSum := nCutSum + 1
                                                            ENDCASE
                                                        ENDIF
                                                        SKIP ALIAS EquCut
                                                    ENDDO
                                                    IF mdetail = "Y"
                                                        IF nCutSum > 0
                                                            // **        @ nl,54 SAY INT( nCutSum ) PICTURE "Total Lengths =9,999"
                                                            // **        nl++
                                                        ENDIF
                                                    ENDIF
                                                    mpartnum := Equ->Partnum
                                                ENDIF             // Each
                                                IF mlevel = 4
                                                    SELECT Equ
                                                    mmod4   := Trim( Equ->Partnum )
                                                    // **         nequPartQty := Equ->PartQty
                                                    GOTO TOP
                                                    SEEK mmod4
                                                    IF Found()
                                                        DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                                            nrecno4 := RecNo()
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
                                                                IF Equ->ABC = "x"
                                                                    SKIP ALIAS Equ
                                                                    LOOP
                                                                ENDIF
                                                            ENDIF
                                                            IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                                                SKIP ALIAS Equ
                                                                LOOP
                                                            ENDIF
                                                            nqty4 := Equ->PartQty
                                                            nequqty4 := nequqty3 * Equ->PartQty
                                                            nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
                                                            SELECT Part
                                                            SEEK Equ->Partnum
                                                            mpartnum := Equ->Partnum
                                                            mseek := Equ->ModSeqno + mpartnum
                                                            IF Part->Unit != "Each      "
                                                                SELECT EquCut
                                                                GOTO TOP
                                                                SEEK mseek
                                                                IF Found()
                                                                    @ nl, 0 SAY Equ->ABC + "...."
                                                                    @ nl, 6 SAY Str( nequ4, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                                                                        + " " + SubStr( Part->Desc, 1, 22 );
                                                                        + " " + SubStr( Equ->Partnum, 1, 16 );
                                                                        + " " + SubStr( Equ->Modcode, 1, 20 )
                                                                    nl++
                                                                    IF mdetail = "Y"
                                                                        // **            @ nl, 5 SAY SUBSTR( Part->Unit, 1, 6 )
                                                                        @ nl, 13 SAY "Length Mtr" + Str( Part->Length, 8, 3  )
                                                                        @ nl, 32 SAY "Width mm " + Str( Part->Width, 8, 3 )
                                                                        @ nl, 50 SAY "Thick mm " + Str( Part->Thick, 8, 3 )
                                                                        @ nl, 69 SAY Part->Codeno
                                                                        nl++
                                                                    ENDIF                        // mdetail = Y
                                                                ENDIF
                                                                nCutSum := 0
                                                                DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                                                                    DO CASE
                                                                    CASE Part->Unit = "Mtr       "
                                                                        nTotQty := Quot->Qty * EquCut->Qty
                                                                        @ nl, 4 SAY nquot * ( nequqty3 * EquCut->Qty ) PICTURE "9,999"
                                                                        @ nl, 10 SAY "x " + EquCut->ModRef + " " + Str( EquCut->Length, 8, 3 ) + " Mtr"
                                                                        nCut := Int( Part->Length / EquCut->Length )
                                                                        nCutTot := nTotQty / nCut
                                                                        IF nCutTot > Int( nCutTot )
                                                                            nCutTot := nCutTot
                                                                        ELSE
                                                                            nCutTot := nCutTot
                                                                        ENDIF
                                                                        IF mdetail = "Y"
                                                                            IF nCutTot > 0
                                                                                // **                  @ nl,63 SAY nCutTot PICTURE "999.999 Lths"
                                                                                @ nl, 69 SAY ( Part->Length / EquCut->Length ) PICTURE "999 Per/Ln"
                                                                            ELSE
                                                                                @ nl, 70 SAY nTotQty * EquCut->Length PICTURE "9,999.999"
                                                                            ENDIF
                                                                            nCutSum += nCutTot
                                                                        ENDIF                      // mdetail
                                                                        nl++
                                                                    CASE Part->Unit = "Sq Mtr    "
                                                                        nTotQty := Quot->Qty * EquCut->Qty
                                                                        @ nl, 4 SAY nquot * ( nequqty3 * EquCut->Qty ) PICTURE "9,999"
                                                                        @ nl, 10 SAY "x " + EquCut->ModRef;
                                                                            + " " + Str( EquCut->Length, 6, 3 ) + " Mtr";
                                                                            + " " + Str( ( EquCut->Width ), 6, 3 ) + " Mtr"
                                                                        @ nl, 70 SAY ( EquCut->Length * EquCut->Width ) PICTURE "999.999"
                                                                        nl++
                                                                    ENDCASE
                                                                    IF nCutSum > 0
                                                                        DO CASE
                                                                        CASE nCutSum > Int( nCutTot )
                                                                            nCutSum := nCutSum + 1
                                                                        CASE nCutTot < 1
                                                                            nCutSum := nCutSum + 1
                                                                        ENDCASE
                                                                    ENDIF
                                                                    SKIP ALIAS EquCut
                                                                ENDDO
                                                                IF mdetail = "Y"
                                                                    IF nCutSum > 0
                                                                        // **            @ nl,54 SAY INT( nCutSum ) PICTURE "Total Lengths =9,999"
                                                                        // **            nl++
                                                                    ENDIF
                                                                ENDIF                               // mdetail
                                                            ENDIF        // Each
                                                            mpartnum := Equ->Partnum
                                                            SELECT Equ
                                                            SKIP ALIAS Equ
                                                        ENDDO                       // mmod4
                                                    ENDIF
                                                ENDIF                                   // mlevel = 4
                                                SELECT Equ
                                                GOTO nrecno3
                                                SKIP ALIAS Equ
                                            ENDDO                       // mmod3
                                        ENDIF                          // FOUND()  mmod3
                                    ENDIF                                 // mlevel = 3
                                    SELECT Equ
                                    GOTO nrecno2
                                    SKIP ALIAS Equ
                                ENDDO                       // mmod2 EOF()
                                // **         nl++
                            ENDIF                         // Found mmod2
                        ENDIF
                        SELECT Equ
                        GOTO nrecno1
                        SKIP ALIAS Equ
                    ENDDO                       // mmod1 EOF()
                ENDIF                          // Found mmod1
            ENDIF                                   // mlevel = 1
            SET EXACT OFF
            // **      nl++
            SELECT Quot
            SKIP ALIAS Quot
        ENDDO                            // EOF() Quot
        nl++
        SELECT Quot
        SET ORDER TO 1
        IF mwhere = "P"
            @ nl, 0 SAY " "
            EJECT
        ELSE
            IF nl > 18
                WAIT
            ENDIF
        ENDIF

        // ** cpagehd := "STpreqXY"
        minvno := Debit->Invno
        mxy := "N"

        // ** QuotUpDate( minvno )                      // XLF_QU7

        Scroll( 15, 4, 23, 78 )
        mlevel := 4
        // **   mxy := "N"
        // **   mxy := ApGetN( "Do You Want XY Parts" )
        SELECT Status
        SET ORDER TO 1                // Invno+Partnum
        GOTO TOP
        DO WHILE Status->( !Eof() )
            ApFLock( 3 )
            DELETE
            UNLOCK
            SKIP ALIAS Status
        ENDDO                          // Status
        // **   @  8,10 SAY Debit->Codeno+"  "+Debit->Invno COLOR "BG+"
        SELECT Quot
        SET ORDER TO 3                   // Invno+Partnum
        SEEK Debit->Invno
        DO WHILE Quot->Invno = Debit->Invno .AND. Quot->( !Eof() )
            IF Quot->Qty <= 0
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF Quot->Partnum = Message->LabPart          // Met = ZZFABRIC
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF SubStr( Quot->Partnum, 1, 1 ) = "Z"
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF SubStr( Quot->Invno, 1, 1 ) = " "
                SKIP ALIAS Quot
                LOOP
            ENDIF
            nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
            nqty1 := nqty2 := nqty3 := nqty4 := 0
            nequ1 := nequ2 := nequ3 := nequ4 := 0
            nquot := Quot->Qty
            mmod1 := Trim( Quot->Partnum )
            SELECT Equ
            // ***      SET EXACT ON
            GOTO TOP
            nrecno1 := RecNo()
            SEEK mmod1
            IF Found()
                nrecno1 := RecNo()
                DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
                    IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                        SKIP ALIAS Equ
                        LOOP
                    ENDIF
                    nqty1 := Equ->PartQty
                    nequ1 := nqty1 * nquot
                    SELECT Status
                    SET ORDER TO 1               // Invno
                    GOTO TOP
                    SEEK Debit->Invno + Equ->Partnum  // +Equ->Modcode
                    ApFLock( 3 )
                    IF !Found()
                        APPEND BLANK
                        Status->Partnum  := Equ->Partnum
                        Status->Invno    := Debit->Invno
                    ENDIF
                    Status->Required := nequ1
                    Status->Equlevel := "1"
                    IF Status->Modcode = Space( 16 )
                        Status->Modcode := Equ->Modcode
                    ENDIF
                    UNLOCK
                    SELECT Equ
                    mmod2   := Trim( Equ->Partnum )
                    nrecno2 := RecNo()
                    GOTO TOP
                    SEEK mmod2
                    IF Found()
                        DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                            IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                SKIP ALIAS Equ
                                LOOP
                            ENDIF
                            nqty2 := Equ->PartQty
                            nequ2 := ( nqty1 * nqty2 ) * nquot
                            SELECT Status
                            SET ORDER TO 1               // Invno
                            GOTO TOP
                            SEEK Debit->Invno + Equ->Partnum // +Equ->Modcode
                            ApFLock( 3 )
                            IF !Found()
                                APPEND BLANK
                                Status->Partnum  := Equ->Partnum
                                Status->Invno    := Debit->Invno
                            ENDIF
                            Status->Required += nequ2
                            Status->Equlevel := "2"
                            IF Status->Modcode = Space( 16 )
                                Status->Modcode  := Equ->Modcode
                            ENDIF
                            UNLOCK
                            SELECT Equ
                            mmod3   := Trim( Equ->Partnum )
                            nrecno3 := RecNo()
                            GOTO TOP
                            SEEK mmod3
                            IF Found()
                                DO WHILE  Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                    IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                        SKIP ALIAS Equ
                                        LOOP
                                    ENDIF
                                    nqty3 := Equ->PartQty
                                    nequ3 := nqty1 * nqty2 * nqty3 * nquot
                                    SELECT Status
                                    SET ORDER TO 1               // Invno
                                    GOTO TOP
                                    SEEK Debit->Invno + Equ->Partnum   // +Equ->Modcode
                                    ApFLock( 3 )
                                    IF !Found()
                                        APPEND BLANK
                                        Status->Partnum  := Equ->Partnum
                                        Status->Invno    := Debit->Invno
                                    ENDIF
                                    Status->Required += nequ3
                                    Status->Equlevel := "3"
                                    IF Status->Modcode = Space( 16 )
                                        Status->Modcode  := Equ->Modcode
                                    ENDIF
                                    UNLOCK
                                    SELECT Equ
                                    mmod4   := Trim( Equ->Partnum )
                                    nrecno4 := RecNo()
                                    nqty4   := 0
                                    GOTO TOP
                                    SEEK mmod4
                                    IF Found()
                                        DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                            IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                                SKIP ALIAS Equ
                                                LOOP
                                            ENDIF
                                            nqty4 := Equ->PartQty
                                            nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
                                            SELECT Status
                                            SET ORDER TO 1               // Invno
                                            GOTO TOP
                                            SEEK Debit->Invno + Equ->Partnum  // +Equ->Modcode
                                            ApFLock( 3 )
                                            IF !Found()
                                                APPEND BLANK
                                                Status->Partnum  := Equ->Partnum
                                                Status->Invno    := Debit->Invno
                                            ENDIF
                                            Status->Required += nequ4
                                            Status->Equlevel := "4"
                                            IF Status->Modcode = Space( 16 )
                                                Status->Modcode  := Equ->Modcode
                                            ENDIF
                                            UNLOCK
                                            SELECT Equ
                                            SKIP ALIAS Equ
                                        ENDDO                       // mmod4
                                    ENDIF                         // Found
                                    SELECT Equ
                                    GOTO nrecno4
                                    SKIP ALIAS Equ
                                ENDDO                       // mmod3
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
            // **     SET EXACT OFF
            SELECT Quot
            SKIP ALIAS Quot
        ENDDO                                // EOF Quot

        SELECT Part
        SET ORDER TO 1                    // Partnum
        SELECT Status
        SET ORDER TO 1                    // Codeno
        GOTO TOP
        DO WHILE Status->( !Eof() )
            SELECT Part
            SEEK Status->Partnum
            SELECT Status
            ApFLock( 3 )
            IF Part->Codeno = Control->U_Codeno
                Status->Codeno := "Z" + Control->U_Codeno
            ELSE
                IF SubStr( Part->Partnum, 1, 2 ) = "XY"
                    Status->Codeno := "Y" + Part->Codeno
                ELSE
                    Status->Codeno := Part->Codeno
                ENDIF
            ENDIF
            Status->Qty := Part->Instock
            UNLOCK
            SKIP ALIAS Status
        ENDDO                               // Status EOF
        SELECT Quot
        SET ORDER TO 1

        // ** mwhere := "S"

        // ** @ 17,12 SAY "This Parts Listing" COLOR "G+"

        // **  Printsel()

        IF mwhere = "S"
            // **  npl := 56
            // ** ELSE
            Scroll()
            npl := 22
        ENDIF
        npn := 1
        @  0, 2 SAY Control->U_Name
        @  0, 40 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        // *** @  0,66 SAY cpagehd
        @  0, 74 SAY npn PICTURE "99"
        @  2, 2 SAY minvno
        @  2, 12 SAY Debit->Codeno
        @  2, 22 SAY "** Start Date **"
        @  2, 40 SAY Debit->StartDate
        @  2, 55 SAY "PARTS REQUIRED JC- " + minvno
        @  4, 0 SAY "Part #"
        @  4, 18 SAY "Description"
        @  4, 30 SAY "NO XY Parts"
        @  4, 46 SAY "Instock"
        @  4, 57 SAY "Req Qty"
        nl := 5
        nreq := malloc := 0
        SELECT Status
        SET ORDER TO 2              // Codeno
        GOTO TOP
        // ** SEEK minvno
        DO WHILE Status->( !Eof() )
            IF Status->Invno != minvno
                SKIP ALIAS Status
                LOOP
            ENDIF
            IF SubStr( Status->Partnum, 1, 2 ) = "ZZ"
                SKIP ALIAS Status
                LOOP
            ENDIF
            IF Status->Required = 0
                SKIP ALIAS Status
                LOOP
            ENDIF
            IF mxy = "N"
                IF SubStr( Status->ModCode, 1, 2 ) = "XY"
                    SKIP ALIAS Status
                    LOOP
                ENDIF
            ENDIF            // mxy
            IF nl > npl
                IF mwhere = "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                npn++
                @  0, 2 SAY Control->U_Name
                @  0, 40 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                // ***      @  0,66 SAY cpagehd
                @  0, 74 SAY npn PICTURE "99"
                @  2, 2 SAY minvno
                @  2, 12 SAY Debit->Codeno
                @  2, 22 SAY "** Start Date **"
                @  2, 40 SAY Debit->StartDate
                @  2, 55 SAY "PARTS REQUIRED JC- " + minvno
                @  4, 0 SAY "Part #"
                @  4, 18 SAY "Description"
                @  4, 30 SAY "NO XY Parts"
                @  4, 46 SAY "Instock"
                @  4, 57 SAY "Req Qty"
                nl := 5
            ENDIF
            SELECT Part
            SEEK Status->Partnum
            SELECT Status
            @ nl, 0 SAY SubStr( Status->Partnum, 1, 16 )
            @ nl, 17 SAY SubStr( Part->Desc, 1, 24 )
            @ nl, 43 SAY Status->EquLevel
            IF SubStr( Status->ModCode, 1, 2 ) = "XY"
                @ nl, 45 SAY "xy"
            ELSE
                @ nl, 47 SAY SubStr( Part->Unit, 1, 1 )
            ENDIF    // XY
            IF Part->InStock > 0
                @ nl, 49 SAY Part->InStock PICTURE "9999"
            ENDIF
            @ nl, 54 SAY Status->Required PICTURE "9999.99"
            @ nl, 61 SAY "_______"
            @ nl, 70 SAY Part->Codeno
            nl++
            SELECT Status
            SKIP ALIAS Status
        ENDDO                               // Status
        nl++
        IF mwhere = "S"
            WAIT
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        mcontinue := "N"
    ENDDO                     // mcontinue

    RETURN NIL


// ***----- End of JCNOXY()

// **---------------------------------------------------------------------------

FUNCTION LabEdit()

    Scroll()
    DispBox( 15, 0, 24, 79, 2 )
    @ 24, 60 SAY " DT411 "
    mstmm  := Date() -2
    mendmm := Date()
    @ 16, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
    @ 17, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
    READ
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"

        mdelete := "Y"
        DO WHILE mdelete = "Y"
            SELECT demand
            aPart_ := {}
            nrecno := 0
            GOTO TOP
            // **    IF FOUND()
            IF LastRec() != 0
                DO WHILE demand->( !Eof() )
                    IF demand->StartDate < mstmm
                        SKIP ALIAS demand
                        LOOP
                    ENDIF
                    IF demand->StartDate > mendmm
                        SKIP ALIAS demand
                        LOOP
                    ENDIF
                    AAdd( aPart_, demand->Operno;
                        + " " + demand->Labno;
                        + " " + demand->Desc;
                        + "                 " + Str( RecNo(), 6 ) )
                    SKIP ALIAS demand
                ENDDO                        // demand EOF
            ENDIF      // 0
            IF !Empty( aPart_ )
                Scroll()
                DispBox( 0, 1, 24, 79, 2 )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 2, 3, 23, 77, aPart_,, "AFUNC" )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
            ENDIF                        // Empty
            Scroll(  8, 0, 24, 80 )
            DispBox( 8, 2, 24, 79, 2 )
            @ 10, 8 SAY "Task     " + Demand->Operno
            @ 12, 8 SAY "Category " + Demand->Labno
            @ 13, 8 SAY "Desc     " + Demand->Desc
            @ 14, 8 SAY "         " + Demand->Desc1
            @ 15, 8 SAY "         " + Demand->Desc2
            @ 16, 8 SAY "         " + Demand->Desc3
            @ 17, 8 SAY "         " + Demand->Desc4
            @ 18, 8 SAY "Section  " + Demand->Jobnum
            @ 18, 8 SAY demand->StartDate
            mdelete := ApGetN( Trim( Message->Delete ) + " demand" )
            IF PressedEsc()
                RETURN           // RETURN NIL
            ENDIF
            IF mdelete == "Y"
                coderef := Demand->Labno + Str( RecNo(), 4 )
                SELECT Cusnotes
                SEEK coderef
                DO WHILE CusNotes->Code_ref = Coderef .AND. Cusnotes->( !Eof() )
                    @ 22, 10 SAY Cusnotes->Code_ref COLOR "RG+"
                    Inkey( 1 )
                    ApFlock( 3 )
                    DELETE
                    UNLOCK
                    SKIP ALIAS CusNotes
                ENDDO                          // Found()
                SELECT Demand
                ApFlock( 3 )
                DELETE
                UNLOCK
            ENDIF
            manother := ApGetN( Trim( Message->Delete ) + " Another"  )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF manother = "N"
                mdelete := "N"
            ENDIF
        ENDDO    // mdelete

        mcorrect := "N"
        DO WHILE mcorrect == "N"
            SELECT demand
            aPart_ := {}
            nrecno := 0
            GOTO TOP
            IF LastRec() != 0
                DO WHILE demand->( !Eof() )
                    IF demand->StartDate < mstmm
                        SKIP ALIAS demand
                        LOOP
                    ENDIF
                    IF demand->StartDate > mendmm
                        SKIP ALIAS demand
                        LOOP
                    ENDIF
                    AAdd( aPart_, demand->Operno;
                        + " " + demand->Labno;
                        + " " + demand->Desc;
                        + "                 " + Str( RecNo(), 6 ) )
                    SKIP ALIAS demand
                ENDDO                        // demand EOF
            ENDIF      // 0
            IF !Empty( aPart_ )
                Scroll()
                DispBox( 0, 1, 24, 79, 2 )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 2, 3, 23, 77, aPart_,, "AFUNC" )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
            ENDIF                        // Empty
            SELECT demand
            Scroll(   8, 0, 24, 80 )
            DispBox(  8, 1, 24, 79, 2 )
            @ 24, 60 SAY " DT411 "
            coperno  := Demand->Operno
            clabno   := Demand->Labno
            mdesc    := Demand->Desc
            mdesc1   := Demand->Desc1
            mdesc2   := Demand->Desc2
            mdesc3   := Demand->Desc3
            mdesc4   := Demand->Desc4
            cjobnum  := Demand->Jobnum     // machine
            @ 10, 8 SAY "Task    " GET coperno  PICTURE "@!"
            @ 12, 8 SAY "Category" GET clabno   PICTURE "@!"
            @ 14, 8 SAY "Desc    " GET mdesc    PICTURE "@X"
            @ 15, 8 SAY "        " GET mdesc1   PICTURE "@X"
            @ 16, 8 SAY "        " GET mdesc2   PICTURE "@X"
            @ 17, 8 SAY "        " GET mdesc3   PICTURE "@X"
            @ 18, 8 SAY "        " GET mdesc4   PICTURE "@X"
            @ 19, 8 SAY "Section " GET cjobnum  PICTURE "@X"
            READ
            ApRLock( 3 )
            Demand->Operno := coperno
            Demand->Labno  := clabno
            Demand->Desc   := mdesc
            Demand->Desc1  := mdesc1
            Demand->Desc2  := mdesc2
            Demand->Desc3  := mdesc3
            Demand->Desc4  := mdesc4
            Demand->Jobnum := cjobnum
            UNLOCK
            mcorrect := ApGetY( Message->Correct )
            IF PressedEsc()
                EXIT
            ENDIF
        ENDDO                                            // mcorrect
        mdelete := ApGetN( Trim( Message->Delete ) + " demand" )
        IF PressedEsc()
            RETURN           // RETURN NIL
        ENDIF
        IF mdelete == "Y"
            coderef := Demand->Labno + Str( RecNo(), 4 )
            SELECT Cusnotes
            SEEK coderef
            DO WHILE CusNotes->Code_ref = Coderef .AND. Cusnotes->( !Eof() )
                @ 22, 10 SAY Cusnotes->Code_ref COLOR "RG+"
                ApFlock( 3 )
                DELETE
                UNLOCK
                SKIP ALIAS CusNotes
            ENDDO                          // Found()
            SELECT demand
            ApRLock( 3 )
            DELETE
            UNLOCK
        ENDIF
        // ***      ENDIF                // Found
        mcontinue := "Y"
        IF PressedEsc()
            RETURN NIL
        ENDIF
    ENDDO                      // mcontinue

    RETURN NIL
// ****-----------End of LabEdit()

// ****------------------------------------------------------------------------

FUNCTION POEdit()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        SELECT Prof
        SET ORDER TO 1                  // operno
        GOTO TOP
        crate  := "N"
        canother := "N"
        nrecno := 0
        aPart_ := {}
        DO WHILE Prof->( !Eof() )
            AAdd( aPart_, Prof->Operno;
                + " " + Prof->Adminno;
                + " " + Prof->Desc;
                + " " + crate;
                + " " + canother;
                + "                       " + Str( RecNo(), 6 ) )
            SKIP ALIAS Prof
        ENDDO                       // Operate EOF
        Scroll()
        DispBox( 0, 0, 2, 79, 2 )
        @  1, 4      SAY "Part Operations"
        @  1, 30 SAY "Esc to Exit" COLOR "G+"
        @  1, 62 SAY "Delete     Add" COLOR "RG+"
        DispBox( 3, 0, 24, 79, 2 )
        @ 24, 60 SAY " DT411 "
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 23, 77, aPart_,, "AFUNC" )
            IF LastKey() = 27
                EXIT
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
        ENDIF
        coperno  := Prof->Operno
        clabno := Prof->Adminno
        cdesc    := Prof->Desc
        @ Row(), 1 GET coperno  PICTURE "@!"
        @ Row(), 13 GET clabno PICTURE "@!"
        @ Row(), 26 GET cdesc    PICTURE "@X"
        @ Row(), 68 GET crate VALID( crate $ "NY " ) PICTURE "@!"
        @ Row(), 76 GET canother VALID( canother $ "NY " ) PICTURE "@!"
        READ
        ApRLock( 3 )
        Prof->Operno  := coperno
        Prof->Adminno := clabno
        Prof->Desc    := cdesc
        IF crate = "Y"
            coderef := Prof->Operno + Str( RecNo(), 4 )
            SELECT Cusnotes
            SEEK coderef
            DO WHILE CusNotes->Code_ref = Coderef .AND. Cusnotes->( !Eof() )
                @ 22, 10 SAY Cusnotes->Code_ref COLOR "RG+"
                Inkey( 1 )
                ApFlock( 3 )
                DELETE
                UNLOCK
                SKIP ALIAS CusNotes
            ENDDO                          // Found()
            SELECT Prof
            ApFlock( 3 )
            DELETE
            UNLOCK
        ENDIF
        IF LastKey() = 27
            RETURN NIL
        ENDIF
        IF canother = "Y"
            mpart := Space( 16 )
            aPart_ := {}
            nrecno  := 0
            Scroll()
            DispBox( 0, 1, 24, 79, 2 )
            @ 24, 60 SAY " DT411 "
            SELECT Prof
            SET ORDER TO 1                    // Operno
            GOTO TOP
            SEEK coperno
            DO WHILE Prof->Operno = coperno .AND. Prof->( !Eof() )
                AAdd( aPart_, Prof->Operno;
                    + " " + Prof->Adminno;
                    + " " + Prof->Desc;
                    + "                     " + Str( RecNo(), 6 ) )
                SKIP ALIAS Prof
            ENDDO                        // Prof EOF
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice(  1, 2, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                mpart := SubStr( Prof->Partnum, 1, 16 )
            ENDIF                        // Empty
            coperno  := Space( 12 )
            cdesc    := Space( 40 )
            cdesc1   := Space( 40 )
            cdesc2   := Space( 40 )
            cdesc3   := Space( 40 )
            cdesc4   := Space( 40 )
            clabno := Space( 12 )
            cpart    := Space( 12 )
            DO WHILE coperno = "        "
                Scroll()
                DispBox( 0, 1, 24, 79, 2 )
                @ 24, 60 SAY " DT411 "
                nl := 4
                @ nl, 10 SAY "Task       " GET coperno PICTURE "@!"
                nl++
                @ nl, 10 SAY "Category   " GET clabno PICTURE "@!"
                nl++
                @ nl, 10 SAY "Description" GET cdesc  PICTURE "@X"
                nl++
                @ nl, 10 SAY "           " GET cdesc1 PICTURE "@X"
                nl++
                @ nl, 10 SAY "           " GET cdesc2 PICTURE "@X"
                nl++
                @ nl, 10 SAY "           " GET cdesc3 PICTURE "@X"
                nl++
                @ nl, 10 SAY "           " GET cdesc4  PICTURE "@X"
                nl++
                @ nl, 10 SAY "Section    " GET cpart PICTURE "@!"
                READ
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                SELECT Prof
                ApFlock( 3 )
                APPEND BLANK
                Prof->Date    := Date()
                Prof->Operno  := coperno
                Prof->Partnum := mpart
                Prof->Adminno := clabno
                Prof->Desc    := cdesc
                Prof->Desc1   := cdesc1
                Prof->Desc2   := cdesc2
                Prof->Desc3   := cdesc3
                Prof->Desc4   := cdesc4
                UNLOCK
            ENDDO         // coperno
            LOOP
            IF LastKey() = 27
                RETURN NIL
            ENDIF
        ENDIF       // canother
    ENDDO                                        // mcontinue

    RETURN NIL
// ***---- End of POEdit()

// ****---------- END OF FILE XLF_QU9A.PRG
