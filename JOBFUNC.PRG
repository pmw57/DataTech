// **  JK  20-06-11 08:33:10

/*
   Program.....:                  JOBFUNC.PRG
   Author......: J.Kirby
   Date........: 02/08/1988
   Functions...: LabPrint, LabXYParts, LabPList, LabPComp
                 QuotStkXY
   Not used....: LabJCParts
*/

FUNCTION Labprint()

    SELECT Labour
    GOTO TOP
    SET ORDER TO 2    // Invno+Partnum+Codeno
    minvno := Debit->Invno
    Scroll()
    @  8, 10 SAY Debit->Codeno + " " + Debit->invno
    mwhere := "S"

    PrintSel( mwhere )

    IF mwhere == "P"
        npl := 56
    ELSE
        npl := 17
    ENDIF
    nl := 0
    npn := 1
    @  nl, 0 SAY Trim( Control->U_Name )
    @  nl, 52 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  nl, 76 SAY npn PICTURE "99"
    nl++
    ntimetotal := nTotParts := nPartTot := 0
    mcodeno := Debit->Codeno
    SELECT Name
    SEEK Debit->Codeno
    IF Found()
        @ nl, 3 SAY Name->Name
    ENDIF
    @ nl, 36 SAY Debit->Est
    @ nl, 72 SAY Debit->Invno
    nl++
    SELECT Labour
    GOTO TOP
    SEEK minvno
    DO WHILE Labour->Invno = minvno .AND. Labour->( !Eof() )
        IF Labour->Partnum = Space( 20 )
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF SubStr( Labour->Codeno, 5, 1 ) != " "
            SKIP ALIAS Labour
            LOOP
        ENDIF
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
                @ nl, 36 SAY Debit->Est
                @ nl, 68 SAY Debit->Invno
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
    @ nl, 36 SAY "Total Parts ="
    @ nl, 50 SAY nTotParts PICTURE "$9999,999.99"
    nl++
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

            // **              IF Labour->Message != " "
            // **                 nl++
            // **                 @ nl, 1 SAY Labour->Message
            // **              ENDIF
            // **              IF Labour->Fault != " "
            // **                 nl++
            // **                 @ nl, 1 SAY Labour->Fault
            // **              ENDIF
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
                @ nl, 36 SAY Debit->Est
                @ nl, 68 SAY Debit->Invno
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
        SELECT Labour
        SKIP ALIAS Labour
    ENDDO                     // Labour  EOF
    IF nsubtotal > 0
        @ nl, 35 SAY mcodeno + " Time"
        @ nl, 50 SAY nsubtotal PICTURE "99,999.99"
        nl++
        @ nl, 50 SAY "--------------"
        nl++
    ENDIF
    SELECT Labour
    SET ORDER TO 1               // Codeno
    nl++
    @ nl, 10 SAY "Total Time ="
    @ nl, 25 SAY ntimetotal PICTURE "999,999.99"
    @ nl, 36 SAY "Total Parts ="
    @ nl, 50 SAY nTotParts PICTURE "$9999,999.99"
    nl++
    IF mwhere = "S"
        IF nl > 18
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ELSE
        EndPrint()
    ENDIF

    RETURN NIL
// **---------- End of Labprint

// ***------------------------------------------------------------------------

FUNCTION LabXYParts()

    nTotParts := nrequired := notJC := 0
    SELECT Part
    SET ORDER TO 1           // Partnum
    SELECT Status
    SET ORDER TO 3           // ModCode+Partnum
    GOTO TOP
    Scroll( 17, 0, 19, 80 )
    DispBox( 17, 1, 19, 89, 2 )
    @ 18, 5 SAY "This gives listing of Labour File Parts" COLOR "BG+"
    mallparts := mxy := "N"
    mtotal  := ApGetY( "Do You Want All Orders/Issued" )
    mlocate := ApGetY( "Location of Parts" )
    IF mtotal = "Y"
        @ 18, 5 SAY "All Module Parts - Ordered Parts        " COLOR "BG+"
        mallparts := ApGetY( "Do You Want ALL Module Parts" )
        mxy       := ApGetY( "Do You Want XY Parts" )
    ENDIF
    mwhere := "S"

    PrintSel( mwhere )
    IF mwhere == "P"
        npl := 56
    ELSE
        npl := 22
    ENDIF
    npn := 1
    @  0, 0 SAY Control->U_Name
    @  0, 40 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  0, 62 SAY minvno
    @  0, 75 SAY npn PICTURE "99"
    nl  := 2
    ntimetotal := nPartTot := nTimeRate := 0
    SELECT Labour
    SET ORDER TO 1            // Codeno+Date+Partnum
    GOTO TOP
    DO WHILE Labour->( !Eof() )
        IF Labour->Invno != minvno
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Partnum != Space( 20 )
            nPartTot += Labour->Time * Labour->Rate
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF                       // mwhere = P
            npn++
            @  0, 0 SAY Control->U_Name
            @  0, 40 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  0, 62 SAY minvno
            @  0, 75 SAY npn PICTURE "99"
            nl := 2
        ENDIF                           // nl>npl
        mcode      := Labour->Codeno
        nCodeTot   := 0
        SELECT Labour
        DO WHILE Labour->Codeno = mcode .AND. Labour->( !Eof() )
            IF Labour->Invno != minvno
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Partnum != Space( 20 )
                nPartTot += Labour->Time * Labour->Rate
                SKIP ALIAS Labour
                LOOP
            ENDIF
            nCodeTot   += Labour->Time
            nTimeTotal += Labour->Time
            nTimeRate  += Labour->Time * Labour->Rate
            SKIP ALIAS Labour
        ENDDO                // mcode
        SELECT Name
        SEEK mcode
        @ nl, 38 SAY Name->Name
        SELECT Labour
        @ nl, 69 SAY ncodeTot PICTURE "99,999.99"
        nl++
    ENDDO                // EOF Labour
    IF nTimeTotal > 0
        @ nl, 67 SAY "-----------"
        nl++
        SELECT Part
        SEEK Message->LabPart
        @ nl, 2 SAY Trim( Message->LabPart )
        @ nl, 16 SAY Part->Trade            PICTURE "$99.99"
        @ nl, 25 SAY nTimeTotal * Part->Trade PICTURE "$99,999.99"
        @ nl, 50 SAY minvno + " Total Time"
        @ nl, 69 SAY nTimeTotal             PICTURE "99,999.99"
        nTimeTotal := nTimeTotal * Part->Trade
        nl++
        @ nl, 67 SAY "==========="
        nl++
    ENDIF
    // ***********************************
    nGrandTot := nlabpart := ntrade := 0
    SELECT Quot
    SET ORDER TO 3       // Invno
    SEEK minvno
    DO WHILE Quot->Invno = minvno .AND. Quot->( !Eof() )
        nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
        nequ1 := nequ2 := nequ3 := nequ4 := 0
        nquot := Quot->Qty
        mmod1 := Trim( Quot->Partnum )
        SELECT Part
        SEEK Quot->Partnum
        IF Quot->Partnum = Message->LabPart
            nlabpart := Quot->Qty
            ntrade   += nquot * Part->Trade
        ELSE
            nGrandTot += Quot->Qty * Part->Trade
        ENDIF
        SELECT Equ
        GOTO TOP
        SET EXACT ON
        SEEK mmod1
        IF Found()
            DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
                // **           IF mxy = "N"
                IF SubStr( Equ->ModCode, 1, 2 ) = "XY"
                    SKIP ALIAS Equ
                    LOOP
                ENDIF
                IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                    SKIP ALIAS Equ
                    LOOP
                ENDIF
                // **           ENDIF                  // mxy
                nequ1 := Equ->PartQty * nquot
                SELECT Part
                SEEK Equ->Partnum
                SELECT Equ
                IF Equ->Partnum = Message->LabPart
                    nlabpart += nequ1
                    ntrade   += nequ1 * Part->Trade
                ENDIF
                SELECT Equ
                mmod2 := Trim( Equ->Partnum )
                nrecno2 := RecNo()
                GOTO TOP
                SEEK mmod2
                IF Found()
                    DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                        // **           IF mxy = "N"
                        IF SubStr( Equ->ModCode, 1, 2 ) = "XY"
                            SKIP ALIAS Equ
                            LOOP
                        ENDIF
                        IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                            SKIP ALIAS Equ
                            LOOP
                        ENDIF
                        // **           ENDIF                  // mxy
                        nequ2 := Equ->PartQty * nequ1
                        SELECT Part
                        SEEK Equ->Partnum
                        SELECT Equ
                        IF Equ->Partnum = Message->LabPart
                            nlabpart += nequ2
                            ntrade   += nequ2 * Part->Trade
                        ENDIF
                        SELECT Equ
                        mmod3 := Trim( Equ->Partnum )
                        nrecno3 := RecNo()
                        GOTO TOP
                        SEEK mmod3
                        IF Found()
                            DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                // **           IF mxy = "N"
                                IF SubStr( Equ->ModCode, 1, 2 ) = "XY"
                                    SKIP ALIAS Equ
                                    LOOP
                                ENDIF
                                IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                                    SKIP ALIAS Equ
                                    LOOP
                                ENDIF
                                // **           ENDIF                  // mxy
                                nequ3 := Equ->PartQty * nequ2
                                SELECT Part
                                SEEK Equ->Partnum
                                SELECT Equ
                                IF Equ->Partnum = Message->LabPart
                                    nlabpart += nequ3
                                    ntrade   += nequ3 * Part->Trade
                                ENDIF
                                SELECT Equ
                                mmod4   := Trim( Equ->Partnum )
                                nrecno4 := RecNo()
                                GOTO TOP
                                SEEK mmod4
                                IF Found()
                                    DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                        // **           IF mxy = "N"
                                        IF SubStr( Equ->ModCode, 1, 2 ) = "XY"
                                            SKIP ALIAS Equ
                                            LOOP
                                        ENDIF
                                        IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                                            SKIP ALIAS Equ
                                            LOOP
                                        ENDIF
                                        // **           ENDIF                  // mxy
                                        nequ4 := Equ->PartQty * nequ3
                                        SELECT Part
                                        SEEK Equ->Partnum
                                        SELECT Equ
                                        IF Equ->Partnum = Message->LabPart
                                            nlabpart += nequ4
                                            ntrade   += nequ4 * Part->Trade
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
    // **   nl++
    @ nl, 0 SAY "JC-" + minvno + " Time"
    @ nl, 16 SAY nlabpart             PICTURE "99,999.99"
    @ nl, 25 SAY "Lab Cost"
    @ nl, 35 SAY ntrade               PICTURE "$999,999.99"
    @ nl, 47 SAY "Total Cost P+T"
    @ nl, 63 SAY nGrandTot            PICTURE "$999,999.99"
    // **   @ nl,69 SAY nGrandTot+ntrade     PICTURE "$999,999.99"
    nl++
    // *********************************************
    IF nPartTot + nTimeTotal > 0
        nl++
        @ nl, 0 SAY "Ordered Parts Cost"
        @ nl, 20 SAY nPartTot            PICTURE "$999,999.99"
        @ nl, 32 SAY "Time"
        @ nl, 37 SAY nTimeTotal          PICTURE "$99,999.99"
        @ nl, 50 SAY "Ordered Parts+Time"
        @ nl, 69 SAY nPartTot + nTimeTotal PICTURE "$999,999.99"
        nl++
    ENDIF                       // Part+Time
    nTotParts := nrequired := notJC := 0
    SELECT Part
    SET ORDER TO 1                   // Partnum
    SELECT Status
    SET ORDER TO 3              // ModCode+Partnum
    GOTO TOP
    SELECT Name
    SEEK Debit->Codeno
    nl++
    @ nl, 3 SAY Name->Name
    @ nl, 36 SAY Debit->Est
    @ nl, 68 SAY Debit->Invno
    minvno := Debit->Invno
    nl++
    @ nl, 0 SAY "Module"
    @ nl, 69 SAY "JC- "
    IF mtotal = "Y"
        SELECT Status
        mmodcode := Space( 16 )
        mpart := Status->Partnum
        DO WHILE Status->( !Eof() )
            IF mxy = "N"
                IF SubStr( Status->ModCode, 1, 2 ) = "XY"
                    SKIP ALIAS Status
                    LOOP
                ENDIF
                IF SubStr( Status->Partnum, 1, 2 ) = "XY"
                    SKIP ALIAS Status
                    LOOP
                ENDIF
            ENDIF                  // mxy
            IF mallparts = "N"
                IF Status->Received = 0
                    SKIP ALIAS Status
                    LOOP
                ENDIF
            ENDIF              // mallparts
            nl++
            mpartnum := Trim( Status->Partnum )
            SELECT Part
            SEEK mpartnum
            IF Status->ModCode != mmodcode
                @ nl, 0 SAY Status->ModCode
                nl++
                mmodcode := Status->ModCode
            ENDIF
            @ nl, 2 SAY SubStr( Status->Partnum, 1, 16 )
            @ nl, 19 SAY SubStr( Part->Desc, 1, 36 )
            IF Status->Received > 0
                @ nl, 56 SAY Status->Received PICTURE "9,999.99"
            ENDIF
            nTotParts += Status->Received * Part->Trade
            nrequired += Status->Required * Part->Trade
            @ nl, 65 SAY Status->Required PICTURE "9,999.99"
            @ nl, 74 SAY SubStr( Part->Unit, 1, 6 )
            IF mlocate = "Y"
                IF Part->Locate != Space( 16 )
                    IF SubStr( Part->Locate, 1, 2 ) != "NA"
                        nl++
                        @ nl, 4 SAY Part->Locate + " " + Part->LocDesc
                        @ nl, 50 SAY Part->Instock PICTURE "99,999.99"
                        @ nl, 62 SAY Part->Codeno
                    ENDIF
                ENDIF
            ENDIF  // mlocate
            SELECT Status
            IF nl > npl
                IF mwhere = "P"
                    EJECT
                    nl := 0
                    npn++
                    @  nl, 0 SAY Trim( Control->U_Name )
                    @  nl, 52 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  nl, 76 SAY npn PICTURE "999"
                    nl++
                    @ nl, 3 SAY Name->Name
                    @ nl, 36 SAY Debit->Est
                    @ nl, 68 SAY Debit->Invno
                    nl++
                    @ nl, 0 SAY "Module"
                    @ nl, 69 SAY "JC- "
                ELSE
                    WAIT
                    Scroll()
                    nl := 0
                    @ nl, 3 SAY Name->Name
                    @ nl, 36 SAY Debit->Est
                    @ nl, 68 SAY Debit->Invno
                    nl++
                    @ nl, 0 SAY "Module"
                    @ nl, 69 SAY "JC- "
                ENDIF
            ENDIF
            SKIP ALIAS Status
        ENDDO                     // Status  EOF
    ENDIF                          // mtotal
    nl += 2
    @ nl, 12 SAY "Parts Qty Different to JC- Parts"
    nl++
    SELECT Status
    GOTO TOP
    DO WHILE Status->( !Eof() )
        IF Status->Received == 0
            SKIP ALIAS Status
            LOOP
        ENDIF
        IF SubStr( Status->ModCode, 1, 2 ) = "XY"
            SKIP ALIAS Status
            LOOP
        ENDIF
        IF SubStr( Status->Partnum, 1, 2 ) = "XY"
            SKIP ALIAS Status
            LOOP
        ENDIF
        IF Status->Received < Status->Required
            SKIP ALIAS Status
            LOOP
        ENDIF
        IF Status->Received = Status->Required
            SKIP ALIAS Status
            LOOP
        ENDIF
        IF ( Status->Received - Status->Required ) * Part->Trade < 5
            SKIP ALIAS Status
            LOOP
        ENDIF
        mpartnum := Trim( Status->Partnum )
        SELECT Part
        SET ORDER TO 1                   // Partnum
        SEEK mpartnum
        @ nl, 0 SAY Status->ModCode
        @ nl, 17 SAY SubStr( Status->Partnum, 1, 16 )
        IF Status->Received > Status->Required
            notJC += ( Status->Received - Status->Required ) * Part->Trade
            @ nl, 34 SAY SubStr( Part->Desc, 1, 15 )
            @ nl, 50 SAY ( Status->Received - Status->Required ) * Part->Trade;
                PICTURE "$9999.99"
        ELSE
            @ nl, 34 SAY SubStr( Part->Desc, 1, 23 )
        ENDIF
        @ nl, 58 SAY Status->Received PICTURE "9999.99"
        @ nl, 67 SAY Status->Required PICTURE "9999.99"
        @ nl, 75 SAY SubStr( Part->Unit, 1, 5 )
        nl++
        SELECT Status
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
                @ nl, 3 SAY Name->Name
                @ nl, 36 SAY Debit->Est
                @ nl, 68 SAY Debit->Invno
                nl++
                @ nl, 50 SAY "Ordered"
                @ nl, 69 SAY "JC- "
                nl++
            ELSE
                WAIT
                Scroll()
                nl := 0
                @ nl, 3 SAY Name->Name
                @ nl, 36 SAY Debit->Est
                @ nl, 68 SAY Debit->Invno
                nl++
                @ nl, 0 SAY "Module"
                @ nl, 69 SAY "JC- "
            ENDIF
        ENDIF
        SKIP ALIAS Status
    ENDDO                     // Status  EOF
    nl++
    @ nl, 5 SAY "NOTE - ZZ Check JC-Mod - Parts NOT IN Job Card"
    nl++
    @ nl, 5 SAY "Difference > $5.00 Parts Above JC Qty ="
    @ nl, 50 SAY notJC PICTURE "$999,999.99"
    nl += 2
    SELECT Quot
    SET ORDER TO 3                // Invno+Partnum
    GOTO TOP
    SEEK Debit->Invno
    @ nl, 5 SAY "JC-   Sell"
    @ nl, 25 SAY Quot->Amount PICTURE "$9,999,999.99"
    @ nl, 45 SAY Quot->Cost   PICTURE "$9,999,999.99"
    nl++
    @ nl, 5 SAY "Debit Sell"
    @ nl, 25 SAY Debit->InitAmnt  PICTURE "$9,999,999.99"
    @ nl, 45 SAY Debit->CostItem  PICTURE "$9,999,999.99"
    nl += 2
    @ nl, 5 SAY "Check the Following COST prices With Above"
    nl++
    @ nl, 0 SAY "JC- " + minvno + " Time"
    @ nl, 15 SAY nlabpart             PICTURE "99,999.99"
    @ nl, 25 SAY "Lab Cost"
    @ nl, 35 SAY ntrade               PICTURE "$999,999.99"
    @ nl, 47 SAY "Total Cost"
    @ nl, 59 SAY nGrandTot            PICTURE "$999,999.99"
    nl += 2
    @ nl, 5 SAY "Costs+Difference Costs"
    @ nl, 30 SAY nGrandTot + notJc PICTURE "$999,999.99"
    nl++
    IF mwhere = "S"
        IF nl > 18
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ELSE
        EndPrint()
    ENDIF
    SELECT Quot
    SET ORDER TO 1

    RETURN NIL
// **---------- End of LabXYParts()

// ****-------------------------------------------------------------------------

FUNCTION LabPList( mmodcode )

    IF mmodcode = Space( 16 )
        RETURN NIL
    ENDIF
    mmod := Part->Partnum
    nTotParts := nrequired := notJC := 0
    SELECT Part
    SET ORDER TO 1           // Partnum
    SELECT Status
    SET ORDER TO 3           // ModCode+Partnum
    GOTO TOP
    Scroll( 17, 0, 19, 80 )
    DispBox( 17, 1, 19, 89, 2 )
    @ 18, 5 SAY "This gives listing of Labour File Parts" COLOR "BG+"
    mallparts := mxy := "N"
    mtotal := ApGetY( "Do You Want All Orders/Issued" )
    IF mtotal = "Y"
        @ 18, 5 SAY "All Module Parts - Ordered Parts        " COLOR "BG+"
        mallparts := ApGetY( "Do You Want ALL Module Parts" )
        mxy       := ApGetY( "Do You Want XY Parts" )
    ENDIF
    mwhere := "S"

    PrintSel( mwhere )
    IF mwhere == "P"
        npl := 56
    ELSE
        npl := 22
    ENDIF
    nl := nn := 0
    npn := 1
    @  0, 0 SAY Control->U_Name
    @  0, 40 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  0, 65 SAY minvno
    @  0, 75 SAY npn PICTURE "99"
    nl  := 2
    ntimetotal := nPartTot := nTimeRate := 0
    SELECT Labour
    SET ORDER TO 1                  // Codeno+Date+Partnum
    GOTO TOP
    DO WHILE Labour->( !Eof() )
        IF Labour->Invno != minvno
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Partnum != Space( 20 )
            nPartTot += Labour->Time * Labour->Rate
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF                       // mwhere = P
            npn++
            @  0, 0 SAY Control->U_Name
            @  0, 40 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  0, 65 SAY minvno
            @  0, 75 SAY npn PICTURE "99"
            nl := 2
        ENDIF                           // nl>npl
        mcode      := Labour->Codeno
        nCodeTot   := 0
        SELECT Labour
        DO WHILE Labour->Codeno = mcode .AND. Labour->( !Eof() )
            IF Labour->Invno != minvno
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Partnum != Space( 20 )
                nPartTot += Labour->Time * Labour->Rate
                SKIP ALIAS Labour
                LOOP
            ENDIF
            nCodeTot   += Labour->Time
            nTimeTotal += Labour->Time
            nTimeRate  += Labour->Time * Labour->Rate
            SKIP ALIAS Labour
        ENDDO                // mcode
        // **      @ nl, 0 SAY mcode
        SELECT Name
        SEEK mcode
        @ nl, 38 SAY Name->Name
        SELECT Labour
        @ nl, 69 SAY ncodeTot PICTURE "99,999.99"
        nl++
    ENDDO                // EOF Labour
    IF nTimeTotal > 0
        @ nl, 67 SAY "-----------"
        nl++
        SELECT Part
        SEEK Message->LabPart
        @ nl, 0 SAY Trim( Message->LabPart )
        @ nl, 14 SAY Part->Trade PICTURE "$99.99"
        @ nl, 22 SAY nTimeTotal * Part->Trade  PICTURE "$99,999.99"
        @ nl, 50 SAY minvno + " Total Time"
        @ nl, 69 SAY nTimeTotal  PICTURE "99,999.99"
        nTimeTotal := ( nTimeTotal * Part->Trade )
        nl++
        @ nl, 67 SAY "==========="
        nl++
    ENDIF
    IF nPartTot + nTimeTotal > 0
        @ nl, 0 SAY "Ordered Parts Cost"
        @ nl, 20 SAY nPartTot            PICTURE "$999,999.99"
        @ nl, 33 SAY "Ordered Parts+Lab"
        @ nl, 53 SAY nPartTot + nTimeTotal PICTURE "$999,999.99"
        nl++
    ENDIF                       // Part+Time
    nQuotQty := nQuotCost := nQuotAmount := nQCostTot := nQuotTotal := 0
    SELECT Part
    SEEK mmodcode
    nl++
    @ nl, 2 SAY SubStr( Part->Partnum, 1, 16 ) + "  " + Part->Desc + " Ordered   JC-"
    nl++
    IF mtotal = "Y"
        SELECT Status
        mmodcode := Space( 16 )
        mpart := Status->Partnum
        DO WHILE Status->( !Eof() )
            IF mxy = "N"
                IF SubStr( Status->ModCode, 1, 2 ) = "XY"
                    SKIP ALIAS Status
                    LOOP
                ENDIF
                IF SubStr( Status->Partnum, 1, 2 ) = "XY"
                    SKIP ALIAS Status
                    LOOP
                ENDIF
            ENDIF                  // mxy
            IF mallparts = "N"
                IF Status->Received = 0
                    SKIP ALIAS Status
                    LOOP
                ENDIF
            ENDIF             // mallparts
            nl++
            mpartnum := Trim( Status->Partnum )
            SELECT Part
            SEEK mpartnum
            IF Status->ModCode != mmodcode
                @ nl, 0 SAY Status->ModCode
                mmodcode := Status->ModCode
            ENDIF
            @ nl, 17 SAY SubStr( Status->Partnum, 1, 16 )
            @ nl, 34 SAY SubStr( Part->Desc, 1, 20 )
            IF Status->Received > 0
                @ nl, 56 SAY Status->Received PICTURE "9,999.99"
            ENDIF
            nTotParts += Status->Received * Part->Trade
            nrequired += Status->Required * Part->Trade
            @ nl, 65 SAY Status->Required PICTURE "9,999.99"
            @ nl, 74 SAY SubStr( Part->Unit, 1, 6 )
            SELECT Status
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
                    @ nl, 3 SAY Part->Desc + "        " + Part->Partnum
                    nl++
                    @ nl, 55 SAY "Ordered"
                    @ nl, 67 SAY "JC- "
                ELSE
                    WAIT
                    Scroll()
                    nl := 0
                    @ nl, 55 SAY "Ordered"
                    @ nl, 67 SAY "JC- "
                ENDIF
            ENDIF
            SKIP ALIAS Status
        ENDDO                     // Status  EOF
        nl++
    ENDIF                          // mtotal
    nl += 2
    @ nl, 5 SAY "Parts Qty Different to JC- Parts"
    nl++
    SELECT Status
    GOTO TOP
    DO WHILE Status->( !Eof() )
        IF Status->Received == 0
            SKIP ALIAS Status
            LOOP
        ENDIF
        IF Status->Received = Status->Required
            SKIP ALIAS Status
            LOOP
        ENDIF
        IF ( Status->Received - Status->Required ) * Part->Trade < 5
            SKIP ALIAS Status
            LOOP
        ENDIF
        mpartnum := Trim( Status->Partnum )
        SELECT Part
        SET ORDER TO 1                   // Partnum
        SEEK mpartnum
        @ nl, 0 SAY Status->ModCode
        @ nl, 17 SAY SubStr( Status->Partnum, 1, 16 )
        IF Status->Received > Status->Required
            notJC += ( Status->Received - Status->Required ) * Part->Trade
            @ nl, 34 SAY SubStr( Part->Desc, 1, 15 )
            @ nl, 50 SAY ( Status->Received - Status->Required ) * Part->Trade;
                PICTURE "$9999.99"
        ELSE
            @ nl, 34 SAY SubStr( Part->Desc, 1, 23 )
        ENDIF
        @ nl, 58 SAY Status->Received PICTURE "9999.99"
        @ nl, 67 SAY Status->Required PICTURE "9999.99"
        @ nl, 75 SAY SubStr( Part->Unit, 1, 5 )
        nl++
        SELECT Status
        IF nl > npl
            IF mwhere = "P"
                EJECT
                nl := 0
                np++
                @  nl, 0 SAY Trim( Control->U_Name )
                @  nl, 52 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                @  nl, 76 SAY np PICTURE "999"
                nl++
                @ nl, 3 SAY Name->Name
                @ nl, 36 SAY Debit->Est
                @ nl, 68 SAY Debit->Invno
                nl++
                @ nl, 55 SAY "Ordered"
                @ nl, 69 SAY "JC- "
            ELSE
                WAIT
                Scroll()
                nl := 0
                @ nl, 3 SAY Name->Name
                @ nl, 36 SAY Debit->Est
                @ nl, 68 SAY Debit->Invno
                nl++
                @ nl, 55 SAY "Ordered"
                @ nl, 69 SAY "JC- "
            ENDIF
        ENDIF
        SKIP ALIAS Status
    ENDDO                     // Status  EOF
    nl++
    @ nl, 5 SAY "NOTE - ZZ Check JC-Mod - Parts NOT IN Job Card"
    nl++
    @ nl, 5 SAY "Difference > $5.00 Parts Above JC Qty ="
    @ nl, 50 SAY notJC PICTURE "$999,999.99"
    nl += 2
   /*
   NO GOOD DOUBLES UP JC-
   @ nl, 5 SAY "Labour"
   @ nl,12 SAY ntimetotal           PICTURE "$999,999.99"
   @ nl,25 SAY "Required"
   @ nl,35 SAY nrequired            PICTURE "$999,999.99"
   @ nl,50 SAY "Total Cost"
   @ nl,61 SAY nrequired+ntimetotal PICTURE "$999,999.99"
   nl+=2
   */
    IF mwhere = "S"
        IF nl > 18
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ELSE
        EndPrint()
    ENDIF
    SELECT Status
    SET ORDER TO 1
    SELECT Part
    SET ORDER TO 1           // Partnum
    SEEK mmod

    RETURN NIL
// **---------- End of LabPList()

// ****-------------------------------------------------------------------------

FUNCTION LabPComp( mmodcode )

    nreceived := 0
    nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
    nequ1 := nequ2 := nequ3 := nequ4 := 0
    nquot :=  1                         // Quot->Qty
    mmod1 := mmodcode
    Scroll( 19, 0, 24, 80 )
    DispBox( 19, 1, 24, 79, 2 )
    minvno := "20" + SubStr( mmodcode, 4, 4 )
    @ 21, 5 SAY mmodcode COLOR "R+"
    @ 21, 25 SAY "Correct Invoice #" GET minvno PICTURE "XXXXXX"
    READ
    @ 23, 20 SAY "Please Wait Big File"
    SELECT Labour
    SET ORDER TO 2        // Invno+Partnum
    GOTO TOP
    SEEK minvno
    IF !Found()
        @ 23, 10 SAY "NO SUCH Invoice in File  BYE BYE"
        WAIT
        Partlabour()                  // CWP2
    ENDIF
    SELECT Status
    GOTO TOP
    ApFLock( 3 )
    DO WHILE Status->( !Eof() )
        DELETE
        SKIP ALIAS Status
    ENDDO
    UNLOCK
    SET ORDER TO 3                 // ModCode+Partnum
    SELECT Equ
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
            IF Equ->Partnum = Message->LabPart          // Met = ZZFABRIC
                SKIP ALIAS Equ
                LOOP
            ENDIF
            IF SubStr( Equ->Partnum, 1, 1 ) = "Z"
                SKIP ALIAS Equ
                LOOP
            ENDIF
            nequ1 := Equ->PartQty * nquot
            SELECT Status
            SET ORDER TO 3                     // Modcode+Partnum
            GOTO TOP
            cmodpart := Equ->Modcode + Equ->Partnum
            SEEK cmodpart
            ApFLock( 3 )
            APPEND BLANK
            Status->Invno    := minvno
            Status->Modcode  := Equ->Modcode
            Status->Partnum  := Equ->Partnum
            Status->Qty      := nequ1
            Status->ModPart  := cmodpart
            Status->Equlevel := "1"
            Status->Required := nequ1      // Status->Qty
            Status->EquQty   := nquot
            UNLOCK
            SELECT Equ
            // **      SET EXACT ON
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
                    IF Equ->Partnum = Message->LabPart          // Met = ZZFABRIC
                        SKIP ALIAS Equ
                        LOOP
                    ENDIF
                    IF SubStr( Equ->Partnum, 1, 1 ) = "Z"
                        SKIP ALIAS Equ
                        LOOP
                    ENDIF
                    nequ2 := Equ->PartQty * nequ1
                    SELECT Status
                    SET ORDER TO 3               // Modcode+Partnum
                    GOTO TOP
                    cmodpart := Equ->Modcode + Equ->Partnum
                    SEEK cmodpart
                    ApFLock( 3 )
                    APPEND BLANK
                    Status->Invno    := minvno
                    Status->Modcode  := Equ->Modcode
                    Status->Partnum  := Equ->Partnum
                    Status->ModPart  := cmodpart
                    Status->Qty      := nequ2
                    Status->Equlevel := "2"
                    Status->Required := nequ2      // Status->Qty
                    Status->EquQty   := nequ1
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
                            IF Equ->Partnum = Message->LabPart          // Met = ZZFABRIC
                                SKIP ALIAS Equ
                                LOOP
                            ENDIF
                            IF SubStr( Equ->Partnum, 1, 1 ) = "Z"
                                SKIP ALIAS Equ
                                LOOP
                            ENDIF
                            nequ3 := Equ->PartQty * nequ2
                            SELECT Status
                            GOTO TOP
                            cmodpart := Equ->Modcode + Equ->Partnum
                            SEEK cmodpart
                            ApFLock( 3 )
                            APPEND BLANK
                            Status->Invno    := minvno
                            Status->Modcode  := Equ->Modcode
                            Status->Partnum  := Equ->Partnum
                            Status->Qty      := nequ3
                            Status->ModPart  := cmodpart
                            Status->Equlevel := "3"
                            Status->Required := nequ3             // Status->Qty
                            Status->EquQty   := nequ2             // must be 2
                            UNLOCK
                            SELECT Equ
                            mmod4   := Trim( Equ->Partnum )
                            nrecno4 := RecNo()
                            GOTO TOP
                            SEEK mmod4
                            IF Found()
                                DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                    IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                        SKIP ALIAS Equ
                                        LOOP
                                    ENDIF
                                    IF Equ->Partnum = Message->LabPart          // Met = ZZFABRIC
                                        SKIP ALIAS Equ
                                        LOOP
                                    ENDIF
                                    IF SubStr( Equ->Partnum, 1, 1 ) = "Z"
                                        SKIP ALIAS Equ
                                        LOOP
                                    ENDIF
                                    nequ4 := Equ->PartQty * nequ3
                                    SELECT Status
                                    GOTO TOP
                                    cmodpart := Equ->Modcode + Equ->Partnum
                                    SEEK cmodpart
                                    ApFLock( 3 )
                                    APPEND BLANK
                                    Status->Invno    := minvno
                                    Status->Modcode  := Equ->Modcode
                                    Status->Partnum  := Equ->Partnum
                                    Status->ModPart  := cmodpart
                                    Status->Qty      := nequ4
                                    Status->Equlevel := "4"
                                    Status->Required := nequ4           // Status->Qty
                                    Status->EquQty   := nequ3             // must be 3
                                    UNLOCK
                                    SELECT Equ
                                    SKIP ALIAS Equ
                                ENDDO                     // mmod4
                            ENDIF                        // Found  mmod4
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
    // ************       Changing Part File
    SELECT Labour
    SET ORDER TO 2                    // Invno+Partnum+Fault    // ModCode
    SELECT Status
    SET ORDER TO 1                    // Invno+Partnum
    GOTO TOP
    DO WHILE Status->( !Eof() )
        SELECT Labour
        GOTO TOP
        nreceived := 0
        mseek := minvno + Status->Partnum + Status->ModCode
        SEEK mseek
        DO WHILE Labour->Invno + Labour->Partnum + Labour->Fault;
                = mseek .AND. Labour->( !Eof() )
            IF Labour->Time = 0
                SKIP ALIAS Labour
                LOOP
            ENDIF
            nreceived += Labour->Time
            SKIP ALIAS Labour
        ENDDO                          // Found in Labour File
        SELECT Status
        IF nreceived > 0
            ApRlock( 3 )
            Status->Ordnum   := "*"
            Status->Received := nreceived
            UNLOCK
        ENDIF
        SKIP ALIAS Status
    ENDDO                               // EOF Quotstk
    // ***                Parts    Not in Status File
    SELECT Labour
    GOTO TOP
    SEEK minvno
    DO WHILE Labour->Invno = minvno .AND. Labour->( !Eof() )
        IF Labour->Time = 0
            SKIP ALIAS Labour
            LOOP
        ENDIF
        SELECT Status
        SET ORDER TO 1                  // Invno+Partnum
        mseek := minvno + Labour->Partnum
        SEEK mseek
        IF !Found()
            ApRlock( 3 )
            APPEND BLANK
            Status->Invno    := Labour->Invno
            Status->Modcode  := "ZZ Check JC-Mod"
            Status->Partnum  := Labour->Partnum
            Status->Ordnum   := SubStr( Labour->Codeno, 1, 4 )
            Status->Received := Labour->Time
            UNLOCK
        ENDIF
        SELECT Labour
        SKIP ALIAS Labour
    ENDDO                            // Found in Labour File

    RETURN NIL
// ***--------------------------- LabPComp()

// **----------------------------------------------------------------------

FUNCTION QuotStkXY()

    SELECT Status
    GOTO TOP
    ApFLock( 3 )
    DO WHILE Status->( !Eof() )
        DELETE
        SKIP ALIAS Status
    ENDDO
    UNLOCK
    SET ORDER TO 1                 // Invno+Partnum
    SELECT Quot
    SET ORDER TO 3                // Invno+Partnum
    GOTO TOP
    nreceived := 0
    minvno := Debit->Invno
    SEEK Debit->Invno
    DO WHILE Quot->Invno = minvno .AND. Quot->( !Eof() )
        IF Quot->Partnum = Message->LabPart    // MetalCraft = ZZFABRIC
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF Quot->Qty <= 0
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
        nequ1 := nequ2 := nequ3 := nequ4 := 0
        nquot := Quot->Qty
        mmod1 := Trim( Quot->Partnum )
        SELECT Equ
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
                IF Equ->Partnum = Message->LabPart          // Met = ZZFABRIC
                    SKIP ALIAS Equ
                    LOOP
                ENDIF
                IF SubStr( Equ->Partnum, 1, 1 ) = "Z"
                    SKIP ALIAS Equ
                    LOOP
                ENDIF
                nequ1 := Equ->PartQty * nquot
                SELECT Status
                SET ORDER TO 1                     // Invno+Modcode+Partnum
                GOTO TOP
                cmodpart := Equ->Modcode + Equ->Partnum
                SEEK Quot->Invno + cmodpart
                IF Found()
                    @ 18, 4 SAY Equ->Modcode + " " + Equ->Partnum + " " + Quot->Invno
                ENDIF
                ApFLock( 3 )
                APPEND BLANK
                Status->Invno    := Quot->Invno
                Status->Modcode  := Equ->Modcode
                Status->Partnum  := Equ->Partnum
                Status->Qty      := nequ1
                Status->ModPart  := cmodpart
                Status->Equlevel := "1"
                Status->Required := nequ1     // Status->Qty
                Status->EquQty   := nquot
                UNLOCK
                SELECT Equ
                // **      SET EXACT ON
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
                        IF Equ->Partnum = Message->LabPart          // Met = ZZFABRIC
                            SKIP ALIAS Equ
                            LOOP
                        ENDIF
                        IF SubStr( Equ->Partnum, 1, 1 ) = "Z"
                            SKIP ALIAS Equ
                            LOOP
                        ENDIF
                        nequ2 := Equ->PartQty * nequ1
                        SELECT Status
                        // **            SET EXACT OFF
                        SET ORDER TO 1               // Invno
                        GOTO TOP
                        cmodpart := Equ->Modcode + Equ->Partnum
                        SEEK Quot->Invno + cmodpart
                        IF Found()
                            @ 19, 4 SAY Equ->Modcode + " " + Equ->Partnum + " " + Quot->Invno
                        ENDIF
                        ApFLock( 3 )
                        APPEND BLANK
                        Status->Invno    := Quot->Invno
                        Status->Modcode  := Equ->Modcode
                        Status->Partnum  := Equ->Partnum
                        Status->ModPart  := cmodpart
                        Status->Qty      := nequ2
                        Status->Equlevel := "2"
                        Status->Required := nequ2     // Status->Qty
                        Status->EquQty   := nequ1
                        UNLOCK
                        SELECT Equ
                        // **      SET EXACT ON
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
                                IF Equ->Partnum = Message->LabPart          // Met = ZZFABRIC
                                    SKIP ALIAS Equ
                                    LOOP
                                ENDIF
                                IF SubStr( Equ->Partnum, 1, 1 ) = "Z"
                                    SKIP ALIAS Equ
                                    LOOP
                                ENDIF
                                nequ3 := Equ->PartQty * nequ2
                                SELECT Status
                                GOTO TOP
                                cmodpart := Equ->Modcode + Equ->Partnum
                                SEEK Quot->Invno + cmodpart
                                IF Found()
                                    @ 20, 4 SAY Equ->Modcode + " " + Equ->Partnum + " " + Quot->Invno
                                ENDIF
                                ApFLock( 3 )
                                APPEND BLANK
                                Status->Invno    := Quot->Invno
                                Status->Modcode  := Equ->Modcode
                                Status->Partnum  := Equ->Partnum
                                Status->Qty      := nequ3
                                Status->ModPart  := cmodpart
                                Status->Equlevel := "3"
                                Status->Required := nequ3             // Status->Qty
                                Status->EquQty   := nequ2             // must be 2
                                UNLOCK
                                SELECT Equ
                                mmod4   := Trim( Equ->Partnum )
                                nrecno4 := RecNo()
                                GOTO TOP
                                SEEK mmod4
                                IF Found()
                                    DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                        IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                            SKIP ALIAS Equ
                                            LOOP
                                        ENDIF
                                        IF Equ->Partnum = Message->LabPart          // Met = ZZFABRIC
                                            SKIP ALIAS Equ
                                            LOOP
                                        ENDIF
                                        IF SubStr( Equ->Partnum, 1, 1 ) = "Z"
                                            SKIP ALIAS Equ
                                            LOOP
                                        ENDIF
                                        nequ4 := Equ->PartQty * nequ3
                                        SELECT Status
                                        GOTO TOP
                                        cmodpart := Equ->Modcode + Equ->Partnum
                                        SEEK Quot->Invno + cmodpart
                                        IF Found()
                                            @ 21, 4 SAY Equ->Modcode + " " + Equ->Partnum + " " + Quot->Invno
                                        ENDIF
                                        ApFLock( 3 )
                                        APPEND BLANK
                                        Status->Invno    := Quot->Invno
                                        Status->Modcode  := Equ->Modcode
                                        Status->Partnum  := Equ->Partnum
                                        Status->ModPart  := cmodpart
                                        Status->Qty      := nequ4
                                        Status->Equlevel := "4"
                                        Status->Required := nequ4             // Status->Qty
                                        Status->EquQty   := nequ3             // must be 3
                                        UNLOCK
                                        SELECT Equ
                                        SKIP ALIAS Equ
                                    ENDDO                     // mmod4
                                ENDIF                        // Found  mmod4
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
        SELECT Quot
        SKIP ALIAS Quot
    ENDDO                                // EOF Quot
    SELECT Quot
    SET ORDER TO 1
    // ************       Changing Part File
    // **   @ 24, 5 SAY "PLEASE WAIT" COLOR "RG+"
    SELECT Labour
    SET ORDER TO 2        // Invno+Partnum+Fault  // ModCode
    SELECT Status
    SET ORDER TO 1                    // Invno+Partnum
    GOTO TOP
    DO WHILE Status->( !Eof() )
        SELECT Labour
        GOTO TOP
        nreceived := 0
        mseek := Status->Invno + Status->Partnum + Status->ModCode
        SEEK mseek
        DO WHILE Labour->Invno + Labour->Partnum + Labour->Fault;
                = mseek .AND. Labour->( !Eof() )
            IF Labour->Time = 0
                SKIP ALIAS Labour
                LOOP
            ENDIF
            nreceived += Labour->Time
            SKIP ALIAS Labour
        ENDDO                          // Found in Labour File
        SELECT Status
        IF nreceived > 0
            ApRlock( 3 )
            Status->Ordnum   := "*"
            Status->Received := nreceived
            UNLOCK
        ENDIF
        SKIP ALIAS Status
    ENDDO                               // EOF Quotstk

    SELECT Labour
    GOTO TOP
    SEEK minvno
    DO WHILE Labour->Invno = minvno .AND. Labour->( !Eof() )
        IF Labour->Time = 0
            SKIP ALIAS Labour
            LOOP
        ENDIF
        SELECT Status
        mseek := minvno + Labour->Partnum
        SEEK mseek
        IF !Found()
            SELECT Status
            ApFlock( 3 )
            APPEND BLANK
            Status->Invno    := Labour->Invno
            Status->Modcode  := "ZZ Check JC-Mod"
            Status->Partnum  := Labour->Partnum
            Status->Ordnum   := SubStr( Labour->Codeno, 1, 4 )
            Status->Received := Labour->Time
            UNLOCK
        ENDIF
        SELECT Labour
        SKIP ALIAS Labour
    ENDDO                            // Found in Labour File
    SELECT Quot
    SET ORDER TO 1
    SELECT Labour
    SET ORDER TO 1

    RETURN NIL
// ***--------------------------- QuotStkXY()

// **----------------------------------------------------------------------

FUNCTION LabJCParts()

    SELECT Labour
    GOTO TOP
    ApFLock( 3 )
    INDEX ON Labour->Partnum TO TempInd9
    SET INDEX TO TempInd9
    UNLOCK
    GOTO TOP
    mwhere := "S"

    PrintSel( mwhere )

    IF mwhere == "P"
        npl := 56
    ELSE
        npl := 22
    ENDIF
    nl := nn := 0
    npn := 1
    @  nl, 0 SAY Trim( Control->U_Name )
    @  nl, 52 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  nl, 76 SAY npn PICTURE "999"
    nl++
    nTotParts := 0
    SELECT Name
    SEEK Debit->Codeno
    @ nl, 3 SAY Name->Name
    @ nl, 36 SAY Debit->Est
    @ nl, 68 SAY Debit->Invno
    minvno := Debit->Invno
    nl++
    @ nl, 67 SAY "JC- "
    SELECT Labour
    DO WHILE Labour->( !Eof() )
        IF Labour->Partnum = Space( 20 )
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Invno != minvno
            SKIP ALIAS Labour
            LOOP
        ENDIF
        nl++
        @ nl, 0 SAY SubStr( Labour->Partnum, 1, 16 )
        nTotParts += Labour->Rate * Labour->Time
        mpartnum := Trim( Labour->Partnum )
        SELECT Part
        SET ORDER TO 1                   // Partnum
        SEEK mpartnum
        SELECT QuotStk
        SET ORDER TO 2                   // Partnum
        SEEK mpartnum
        IF !Found()
            @ nl, 34 SAY SubStr( Part->Desc, 1, 20 )
            @ nl, 56 SAY Labour->Time PICTURE "9,999.99"
            @ nl, 73 SAY SubStr( Part->Unit, 1, 6 )
        ENDIF
        nn := nl
        DO WHILE QuotStk->Partnum = mpartnum .AND. QuotStk->( !Eof() )
            IF QuotStk->Invno != minvno
                SKIP ALIAS QuotStk
                LOOP
            ENDIF
            @ nn, 17 SAY QuotStk->ModCode
            @ nn, 34 SAY SubStr( Part->Desc, 1, 20 )
            IF nn = nl
                @ nn, 56 SAY Labour->Time PICTURE "9,999.99"
            ENDIF
            @ nn, 64 SAY QuotStk->Required PICTURE "9,999.99"
            @ nn, 73 SAY SubStr( Part->Unit, 1, 6 )
            nn++
            nl := nn - 1
            SKIP ALIAS QuotStk
        ENDDO
        SELECT Labour
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
                @ nl, 3 SAY Name->Name
                @ nl, 36 SAY Debit->Est
                @ nl, 68 SAY Debit->Invno
                nl++
                @ nl, 67 SAY "JC- "

            ELSE
                WAIT
                Scroll()
                nl := 0
                @ nl, 3 SAY Name->Name
                @ nl, 36 SAY Debit->Est
                @ nl, 68 SAY Debit->Invno
                nl++
                @ nl, 67 SAY "JC- "
            ENDIF
        ENDIF
        SKIP ALIAS Labour
    ENDDO                     // Labour  EOF
    SELECT Labour
    SET ORDER TO 1               // Codeno
    SELECT QuotStk
    SET ORDER TO 1               // Invno
    nl += 2
    @ nl, 34 SAY "Ordered Parts ="
    @ nl, 50 SAY nTotParts PICTURE "$999,999.99"
    nl++
    IF mwhere = "S"
        IF nl > 18
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ELSE
        EndPrint()
    ENDIF

    RETURN NIL
// **---------- End of LabJCParts()

// **------------------ END OF FILE JOBFUNC.PRG
