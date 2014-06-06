// **  JoKir   30-09-11 22:22:58
// ** Part->ABC

/*
   Program.....:                  XLF_Stat.PRG
   Authors.....: J.Kirby
   Date........: 18/07/2002
   Functions...: METJCut
   Static funcs: Mu_Stat
*/

FUNCTION METJCut( mcodeno )

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"

        mequ := mstock := moper := mABC := "N"
        mequ    := "Y"
        mxy     := "Y"
        mlevel  := 4
        ccount  := 0
        // **   IF mequ = "Y"
        Scroll( 12, 0, 24, 80 )
        DispBox( 12, 1, 17, 79, 2 )
        mlevel := 0
        @ 13, 10 SAY "JC- Details"
        @ 15, 10 SAY "Module Level Required 1, 2, 3, 4" GET mlevel PICTURE "9"
        READ
        cpagehd := "MPjc-" + Str( mlevel, 1, 0 )
        mxy := ApGetN( "Include XY Parts" )
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
        // **   @ nl, 0 SAY Name->Add5
        SELECT Quot
        SET ORDER TO 2
        SEEK mcodeno
        @ nl, 3 SAY Debit->Message
        @ nl, 54 SAY Debit->DbDate
        @ nl, 65 SAY "J/C # " + minvno
        nl += 2
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
            IF Found()
                SELECT Part
                ApFLock( 3 )
                Part->ABC := "M"                   // to find modules
                UNLOCK
            ENDIF
            SELECT Part
            SEEK Quot->Partnum
            // **         @ nl, 2 SAY Part->Desc+"             "+SUBSTR( Quot->Partnum, 1,16 )
            @ nl, 0 SAY Str( Quot->Qty, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                + " " + Part->Desc;
                + " " + SubStr( Quot->Partnum, 1, 16 )
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
            IF mlevel > 0
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
                            + " " + Part->Desc;
                            + " " + SubStr( Part->Partnum, 1, 16 )
                        // **            @ nl, 6 SAY Part->Desc+"       "+SUBSTR( Equ->Partnum, 1,16 )
                        // **            @ nl,70 SAY Equ->PartQty PICTURE "9999.999"
                        // **          IF Equ->Partnum = Message->LabPart
                        // **             nlabpart += nequ1
                        // **          ENDIF
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
                                        @ nl, 6 SAY Str( nequ2, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                                            + " " + Part->Desc;
                                            + " " + SubStr( Part->Partnum, 1, 16 )
                                        // **            @ nl, 8 SAY Part->Desc+"       "+SUBSTR( Equ->Partnum, 1,16 )
                                        // **         IF Equ->Partnum = Message->LabPart
                                        // **            nlabpart += nequ2
                                        // **         ENDIF
                                        // ***            @ nl,70 SAY Equ->PartQty PICTURE "9999.999"
                                        // **            IF mstock = "Y"
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
                                        // **            ENDIF               // mstock
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
   /*
   THIS IS needed at all levels if any good
               SELECT Hist
               SET ORDER TO 2
               GOTO TOP
               SEEK mpartnum
               ccount := 0
               DO WHILE Hist->Partnum = mpartnum .AND. Hist->( !EOF() )
                  ccount += Hist->Qty
                  SKIP ALIAS Hist
               ENDDO   // Hist
               IF ccount > 0
                  @ nl,10 SAY ccount PICTURE "99,999.99"
                  nl++
               ENDIF
   */
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
                                                        + " " + Part->Desc;
                                                        + " " + SubStr( Part->Partnum, 1, 16 )
                                                    // **             @ nl,10 SAY Part->Desc+"       "+SUBSTR( Equ->Partnum, 1,16 )
                                                    // **            @ nl,70 SAY Equ->PartQty PICTURE "999.999"
                                                    // **             IF Equ->Partnum = Message->LabPart
                                                    // **                nlabpart += nequ3
                                                    // **             ENDIF
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
                                                                @ nl, 6 SAY Str( nequ4, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
                                                                    + " " + Part->Desc;
                                                                    + " " + SubStr( Part->Partnum, 1, 16 )
                                                                // **            @ nl,12 SAY Part->Desc+"       "+SUBSTR( Equ->Partnum, 1,16 )
                                                                // **            @ nl,70 SAY Equ->PartQty PICTURE "999.999"
                                                                // **          IF Equ->Partnum = Message->LabPart
                                                                // **             nlabpart += nequ4
                                                                // **          ENDIF
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

        // **************************  LABOUR
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
            nlab1 := nlab2 := nlab3 := nlab4 := 0
            nequ1 := nequ2 := nequ3 := nequ4 := 0
            nquot := Quot->Qty
            nequqty1 := nequqty2 := nequqty3 := nequqty4 := 0
            SELECT Equ
            mmod1 := Trim( Quot->Partnum )
            SEEK mmod1
            nequqty1 := Equ->PartQty
            SELECT Part
            SEEK Quot->Partnum
            mpartnum := Quot->Partnum
            SELECT Equ
            GOTO TOP
            SET EXACT ON
            mmod1 := Trim( Quot->Partnum )
            SEEK mmod1
            IF Found()
                DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
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
                    IF Equ->Partnum = Message->LabPart
                        nlab1    += nequ1
                    ENDIF
                    mpartnum := Equ->Partnum
                    mseek := Equ->ModSeqno + mpartnum
                    SELECT Equ
                    mmod2 := Trim( Equ->Partnum )
                    nrecno2 := RecNo()
                    GOTO TOP
                    SEEK mmod2
                    IF Found()
                        DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
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
                            IF Equ->Partnum = Message->LabPart
                                nlab2    += nequ2
                            ENDIF
                            mpartnum := Equ->Partnum
                            mseek := Equ->ModSeqno + mpartnum
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
                                    IF mxy = "N"
                                        IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                                            SKIP ALIAS Equ
                                            LOOP
                                        ENDIF
                                    ENDIF
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    IF Equ->Partnum = Message->LabPart
                                        nlab3 += nequ3
                                    ENDIF
                                    mpartnum := Equ->Partnum
                                    mseek := Equ->ModSeqno + mpartnum
                                    SEEK mseek
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
                                            IF mxy = "N"
                                                IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                                                    SKIP ALIAS Equ
                                                    LOOP
                                                ENDIF
                                            ENDIF
                                            SELECT Part
                                            SEEK Equ->Partnum
                                            IF Equ->Partnum = Message->LabPart
                                                nlab4    += nequ4
                                            ENDIF
                                            mpartnum := Equ->Partnum
                                            mseek := Equ->ModSeqno + mpartnum
                                            SELECT EquCut
                                            GOTO TOP
                                            SEEK mseek
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
                ENDDO                       // mmod1 EOF()
            ENDIF                          // Found mmod1
            SET EXACT OFF
            SELECT Quot
            SKIP ALIAS Quot
        ENDDO                            // EOF() Quot
        // ***  ENDIF
        IF nlabpart > 0
            @ nl, 5 SAY "JC- " + Message->LabPart + " = "
            @ nl, 32 SAY nlabpart PICTURE "99,999.99"
            nl++
        ENDIF
        nlabTot = nlab1 + nlab2 + nlab3 + nlab4
        IF nlabTot > 0
            nl++
            // **       nlabTot = nlabpart+nlab1+nlab2+nlab3+nlab4
            nlabTot = nlab1 + nlab2 + nlab3 + nlab4
            IF nlab1 > 0
                @ nl, 5 SAY "."
                @ nl, 12 SAY nlab1 PICTURE "9,999.999"
                @ nl, 24 SAY "mod 1 " + Message->LabPart
                nl++
            ENDIF
            IF nlab2 > 0
                @ nl, 5 SAY ".."
                @ nl, 12 SAY nlab2 PICTURE "9,999.999"
                @ nl, 24 SAY "mod 2 " + Message->LabPart
                nl++
            ENDIF
            IF nlab3 > 0
                @ nl, 5 SAY "..."
                @ nl, 12 SAY nlab3 PICTURE "9,999.999"
                @ nl, 24 SAY "mod 3 " + Message->LabPart
                nl++
            ENDIF
            IF nlab4 > 0
                @ nl, 5 SAY "...."
                @ nl, 12 SAY nlab4 PICTURE "9,999.999"
                @ nl, 24 SAY "mod 4 " + Message->LabPart
                nl++
            ENDIF
            nl++
            @ nl, 14 SAY "JC- + Modules Total " + Message->LabPart
            @ nl, 56 SAY nlabPart + nlabTot PICTURE "99,999.999"
            nl++
        ENDIF    // nlabtot
        // ********************************  Actual
        ntotal := nlabour := 0
        SELECT Labour
        SET ORDER TO 2                     // Invno+Partnum+Codeno
        GOTO TOP
        SEEK Debit->Invno
        DO WHILE Labour->Invno = Debit->Invno .AND. Labour->( !Eof() )
            IF Labour->Partnum = Space( 20 )
                nlabour += Labour->Time
            ELSE
                ntotal  += Labour->Time * Labour->Rate
            ENDIF
            SKIP ALIAS Labour
        ENDDO                        // Labour EOF
        IF nlabour > 0
            @  nl, 2 SAY "Time to Date"
            @  nl, 20 SAY nlabour PICTURE "99,999.999"
            // **      @  nl,30 SAY "Labour Rate"
            // **      @  nl,43 SAY ntotal  PICTURE "$999,999.99"
            @  nl, 55 SAY Debit->Invno
            nl++
        ENDIF   // nlabour
        @ nl, 2 SAY "Product " + Debit->Operno
        nl++
        IF mprogress = "Y"
            SELECT Quot
            SET ORDER TO 3        // Invno + Partnum
            SEEK Debit->Invno
            coperno := Debit->Operno
            SELECT Progress
            SEEK coperno
            SELECT Quot
            SET ORDER TO 3        // Invno + Partnum
            SEEK Debit->Invno
            SELECT Progress
            @ nl, 1 SAY Progress->DescProg
            IF Quot->Prog01 = Space( 12 )
                @ nl, 14 SAY "1 __________"
            ELSE
                @ nl, 14 SAY Quot->Prog01
            ENDIF
            SKIP ALIAS Progress
            @ nl, 27 SAY Progress->DescProg
            IF Quot->Prog02 = Space( 12 )
                @ nl, 40 SAY "2 __________"
            ELSE
                @ nl, 40 SAY Quot->Prog02
            ENDIF
            SKIP ALIAS Progress
            @ nl, 53 SAY Progress->DescProg
            IF Quot->Prog03 = Space( 12 )
                @ nl, 66 SAY "3 __________"
            ELSE
                @ nl, 66 SAY Quot->Prog03
            ENDIF
            nl++
            SKIP ALIAS Progress
            @ nl, 1 SAY Progress->DescProg
            IF Quot->Prog04 = Space( 12 )
                @ nl, 14 SAY "4 __________"
            ELSE
                @ nl, 14 SAY Quot->Prog04
            ENDIF
            SKIP ALIAS Progress
            @ nl, 27 SAY Progress->DescProg
            IF Quot->Prog05 = Space( 12 )
                @ nl, 40 SAY "5 __________"
            ELSE
                @ nl, 40 SAY Quot->Prog05
            ENDIF
            SKIP ALIAS Progress
            @ nl, 53 SAY Progress->DescProg
            IF Quot->Prog06 = Space( 12 )
                @ nl, 66 SAY "6 __________"
            ELSE
                @ nl, 66 SAY Quot->Prog06
            ENDIF
            nl++
            SKIP ALIAS Progress
            @ nl, 1 SAY Progress->DescProg
            IF Quot->Prog07 = Space( 12 )
                @ nl, 14 SAY "7 __________"
            ELSE
                @ nl, 14 SAY Quot->Prog07
            ENDIF
            SKIP ALIAS Progress
            @ nl, 27 SAY Progress->DescProg
            IF Quot->Prog08 = Space( 12 )
                @ nl, 40 SAY "8 __________"
            ELSE
                @ nl, 40 SAY Quot->Prog08
            ENDIF
            SKIP ALIAS Progress
            @ nl, 53 SAY Progress->DescProg
            IF Quot->Prog09 = Space( 12 )
                @ nl, 66 SAY "9 __________"
            ELSE
                @ nl, 66 SAY Quot->Prog09
            ENDIF
            nl++
            SKIP ALIAS Progress
            @ nl, 1 SAY Progress->DescProg
            IF Quot->Prog10 = Space( 12 )
                @ nl, 14 SAY "10 _________"
            ELSE
                @ nl, 14 SAY Quot->Prog10
            ENDIF
            SKIP ALIAS Progress
            @ nl, 27 SAY Progress->DescProg
            IF Quot->Prog11 = Space( 12 )
                @ nl, 40 SAY "11 _________"
            ELSE
                @ nl, 40 SAY Quot->Prog11
            ENDIF
            SKIP ALIAS Progress
            @ nl, 53 SAY Progress->DescProg
            IF Quot->Prog12 = Space( 12 )
                @ nl, 66 SAY "12 _________"
            ELSE
                @ nl, 66 SAY Quot->Prog12
            ENDIF
            nl++
            SKIP ALIAS Progress
            @ nl, 1 SAY Progress->DescProg
            IF Quot->Prog13 = Space( 12 )
                @ nl, 14 SAY "13 _________"
            ELSE
                @ nl, 14 SAY Quot->Prog13
            ENDIF
            SKIP ALIAS Progress
            @ nl, 27 SAY Progress->DescProg
            IF Quot->Prog14 = Space( 12 )
                @ nl, 40 SAY "14 _________"
            ELSE
                @ nl, 40 SAY Quot->Prog14
            ENDIF
            SKIP ALIAS Progress
            @ nl, 53 SAY Progress->DescProg
            IF Quot->Prog15 = Space( 12 )
                @ nl, 66 SAY "15 _________"
            ELSE
                @ nl, 66 SAY Quot->Prog15
            ENDIF
            nl++
            SKIP ALIAS Progress
            @ nl, 1 SAY Progress->DescProg
            IF Quot->Prog16 = Space( 12 )
                @ nl, 14 SAY "16 _________"
            ELSE
                @ nl, 14 SAY Quot->Prog16
            ENDIF
            SKIP ALIAS Progress
            @ nl, 27 SAY Progress->DescProg
            IF Quot->Prog17 = Space( 12 )
                @ nl, 40 SAY "17 _________"
            ELSE
                @ nl, 40 SAY Quot->Prog17
            ENDIF
            SKIP ALIAS Progress
            @ nl, 53 SAY Progress->DescProg
            IF Quot->Prog18 = Space( 12 )
                @ nl, 66 SAY "18 _________"
            ELSE
                @ nl, 66 SAY Quot->Prog18
            ENDIF
            nl += 2
        ENDIF        // Progress
        IF mwhere = "P"
            IF nl > 50
                nl := 0
                EJECT
            ENDIF
        ENDIF
        IF mwhere = "P"
            IF Message->Mess13 != Space( 40 )
                @ nl, 26 SAY Message->Mess13
                nl++
            ENDIF
            @ nl, 0 SAY "Qty      MATERIALS                         Price       Date     Hours"
            nl++
            npl := nl
            nline = 1
            FOR nline = 1 TO ( 60 -npl )           // Was 63
                @ nl, 0 SAY "______:___________________________________:__________:_________:___________"
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
        // ***   mcontinue := ApGetN( TRIM( Message->Another )+" Print" )
    ENDDO

    SELECT Quot
    SET ORDER TO 1

    RETURN mcodeno

// ***----- End of MetJCut()

// **----------------------------------------------------------------------

STATIC FUNCTION Mu_Stat( nc, ncl )

    DO WHILE .T.

        cheading := "JC- STATUS MENU"
        nselect  := 0
        nc       := ncl * 2
        Scroll( 3, nc, 21, 78 )
        @  4, nc TO 21, nc + ncl
        Scroll( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  3, nc + 4 TO 5, nc + ( ncl - 4 )
        @  4, nc + ( ncl / 2 ) -( Len( cheading ) / 2 ) SAY cheading
        @  7, nc + 2 PROMPT "1. Job Card Status     "
        @  9, nc + 2 PROMPT "2. Job Cards      Parts"
        @ 11, nc + 2 PROMPT "3. Job Card    IN HOUSE"
        @ 12, nc + 2 PROMPT "4. Job Card     Req-Rec"
        @ 14, nc + 2 PROMPT "5. Job Card       ALL ?"
        @ 16, nc + 2 PROMPT "6. JC Outstanding Print"
        @ 17, nc + 2 PROMPT "7. Parts to Labour     "
        @ 19, nc + 2 PROMPT "8. JC- Req - Labour    "
        @ 20, nc + 2 PROMPT "0. To - Main           "
        nc := ncl
        MENU TO nselect
        DO CASE
        CASE nselect == 9 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            JCStat()                                   // XLF_QU6
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            OrderTot()                                 // XL_Order
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            HouseTot()                                 // XL_Order
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            JCReqRec()                                 // XLF_QU6
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5
            SAVE SCREEN TO holdscrn
            JobAllPa()                                 // XLF_QU6
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            JobOutP()                                  // XLF_QU6
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7
            SAVE SCREEN TO holdscrn
            LabInvP()          // XLF_QU3
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 8
            SAVE SCREEN TO holdscrn
            JCStatLab()                                   // XLF_QU6
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// **** End of Mu_Stat()

// ****--------------- End of File XLF_Stat.PRG
