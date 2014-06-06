// ** JK  27-08-11 14:54:53

/* Program.....:                METQUOT.PRG
   Authors.....: J.Kirby
   Date........: 10/06/2002
   Functions...: GroupEdit, ModPart, MET_QPart, METuotJSheet
                 METuotPrice
   Not used....: JobOutXY, METQMenu, METApplicant
                 METartSrch, METuotAdd, METuotIndi
*/

FUNCTION GroupEdit()

    mok := "Y"
    DO WHILE mok = "Y"
        SELECT Part
        SET ORDER TO 1                       // Catno
        GOTO TOP
        SEEK mpart
        nrecno := 0
        aPart_ := {}
        DO WHILE Part->Partnum = mpart .AND. Part->( !Eof() )
            AAdd( aPart_, Part->PartId;
                + " " + Part->Catno;
                + " " + SubStr( Part->Partnum, 1, 16 );
                + " " + SubStr( Part->Desc, 1, 18 );
                + " " + Str( Part->Trade, 9, 2 );
                + "              " + Str( RecNo(), 6 ) )
            SKIP ALIAS Part
        ENDDO   // Part EOF
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 10 SAY "Select Parts " + mpart  COLOR "BG+"
        @  1, 42 SAY "Product"
        DispBox( 3, 1, 24, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 23, 77, aPart_,, "AFUNC" )
            IF LastKey() = 27
                RETURN NIL
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            mpartId := Part->PartId
            @ Row(), 2 GET mpartId PICTURE "@!"
            READ
            ApRLock( 3 )
            Part->PartId := mpartId
            UNLOCK
        ENDIF
        // **       WAIT
    ENDDO                    // mok

    RETURN NIL

FUNCTION ModPart()

    manother := "Y"
    DO WHILE manother == "Y"

        mpartnum := Space( 20 )
        SELECT Part
        SET ORDER TO 1                       // Partnum
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 8 SAY "Part #" GET mpartnum PICTURE "@!"
        READ
      /*
      DO CASE
         CASE SUBSTR( mpartnum, 1, 2 ) = "JC"
             mpartnum := "J     "
         CASE SUBSTR( mpartnum, 1, 2 ) = "QU"
             mpartnum := "Q     "
      ENDCASE
      */
        IF PressedEsc()
            RETURN NIL
        ENDIF
        aPart_ := {}
        nrecno := 0
        SELECT Part
        SET EXACT OFF
        SET ORDER TO 1
        SEEK mpartnum
        mpart  := Trim( mpartnum )
        FOR x = 1 TO Len( mpart )
            SEEK SubStr( mpart, 1, x )      // Tracer
        NEXT
        IF !Found()
            @ 1, 40 SAY "Try Again " + mpartnum + "  not Found" COLOR "R+"
            Inkey( 2 )
            LOOP
        ENDIF
        IF Found()
            DO WHILE Part->Partnum = mpart .AND. Part->( !Eof() )
                mpartnum := Part->Partnum
                mmodcode := SubStr( mpartnum, 1, 16 )  // This is if 20 Part #
                ntottrade := ntotwhol := 0
                ntottrade1 := ntotwhol1 := 0
                IF Part->BoughtOut = "N"
                    SELECT Equ
                    SET EXACT ON
                    nrecno2 := nrecno3 := nrecno4 := 0
                    nequ1 := nequ2 := nequ3 := nequ4 := 0
                    mmod4 := mmod3 := mmod2 := Space( 16 )
                    npl := 0
                    GOTO TOP
                    SEEK mmodcode
                    IF Found()
                        DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
                            SELECT Part
                            SET ORDER TO 1
                            SEEK Equ->Partnum
                            ntottrade1 += ( Part->Trade * Equ->PartQty )
                            ntotwhol1  += ( Part->Wholesale * Equ->PartQty )
                            SELECT Equ
                            mmod2 := SubStr( Equ->Partnum, 1, 16 )
                            nequ1 := Equ->Partqty
                            nrecno2 := RecNo()
                            GOTO TOP
                            SEEK mmod2
                            IF !Found()
                                ntottrade += ( Part->Trade * nequ1 )
                                ntotwhol  += ( Part->Wholesale * nequ1 )
                            ENDIF
                            IF Found()
                                DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                                    SELECT Part
                                    SET ORDER TO 1
                                    SEEK Equ->Partnum
                                    SELECT Equ
                                    mmod3   := SubStr( Equ->Partnum, 1, 16 )
                                    nrecno3 := RecNo()
                                    nequ2 := Equ->PartQty * nequ1
                                    GOTO TOP
                                    SEEK mmod3
                                    IF !Found()
                                        ntottrade += ( Part->Trade * nequ2 )
                                        ntotwhol  += ( Part->Wholesale * nequ2 )
                                    ENDIF
                                    IF Found()
                                        DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                            SELECT Part
                                            SET ORDER TO 1
                                            SEEK Equ->Partnum
                                            SELECT Equ
                                            mmod4 := SubStr( Equ->Partnum, 1, 16 )
                                            nrecno4 := RecNo()
                                            nequ3 := Equ->PartQty * nequ2
                                            GOTO TOP
                                            SEEK mmod4
                                            IF !Found()
                                                ntottrade += ( Part->Trade * nequ3 )
                                                ntotwhol  += ( Part->Wholesale * nequ3 )
                                            ENDIF
                                            IF Found()
                                                DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                                    nequ4 := Equ->PartQty * nequ3
                                                    SELECT Part
                                                    SET ORDER TO 1
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
                ENDIF                     // Boughtout
                SELECT Part
                SET ORDER TO 1                     // Partnum
                SEEK mmodcode    // Used to be partnum
                ApRLock( 3 )
                Part->RetIndiv := ntottrade
                UNLOCK
                SET ORDER TO 2                     // Catno
                SKIP ALIAS Part
            ENDDO             // End of Part File
        ENDIF
        mok := "Y"
        DO WHILE mok = "Y"
            SELECT Part
            SET ORDER TO 1                       // Catno
            GOTO TOP
            SEEK mpart
            nrecno := 0
            aPart_ := {}
            cmark  := "   "
            DO WHILE Part->Partnum = mpart .AND. Part->( !Eof() )
                IF Part->RetIndiv > ( Part->Trade + 10 )
                    cmark := " * "
                ENDIF
                AAdd( aPart_, SubStr( Part->Partnum, 1,16 );
                    + " " + SubStr( Part->Desc, 1, 18 );
                    + " " + Str( Part->RetIndiv, 9, 2 );
                    + " " + Str( Part->Trade, 9, 2 );
                    + cmark + Str( Part->Markup, 7, 2 );
                    + " " + Str( Part->Wholesale, 9, 2 );
                    + "           " + Str( RecNo(), 6 ) )
                cmark := "   "
                SKIP ALIAS Part
            ENDDO   // Part EOF
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @  1, 10 SAY "Select Parts " + mpart  COLOR "BG+"
            @  1, 42 SAY "Module     Cost   Markup    Sell"
            DispBox( 3, 1, 24, 79, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 4, 3, 23, 77, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
            ENDIF
            mdesc    := Part->Desc
            ntrade   := Part->Trade
            nmarkup  := Part->Markup
            mpartnum := Part->Partnum
            Scroll( 10, 2, 23, 78 )
            nl := 11
            @ nl, 8      SAY Part->Desc COLOR "BG+"
            @ nl, Col() + 4 SAY Part->DATE COLOR "BG+"
            nl++
            @ nl, 6      SAY "Module      Cost  Markup     Sell"
            @ nl, Col() + 2 SAY SubStr( Part->Partnum, 1, 16 ) COLOR "RG+"
            @ nl, Col() + 2 SAY Part->Catno                   COLOR "RG+"
            nl++
            @ nl, 3 SAY Str( Part->RetIndiv, 9, 2 );
                + " " + Str( Part->Trade, 9, 2 );
                + " " + Str( Part->Markup, 7, 2 );
                + " " + Str( Part->Wholesale, 9, 2 ) COLOR "BG+"
            IF Part->RetIndiv > ( Part->Trade + 10 )
                @ nl, Col() + 6 SAY "Check Cost Price" COLOR "RG+"
            ENDIF
            // ***         ENDDO                  // Part
            // **      ENDIF                    // Found
            nl++
            nselect := 1
            DispBox( 20, 1, 24, 79, 2 )
            @ 20, 10      SAY " --- Part --- " + mpartnum
            @ 21, 6      PROMPT "1. Price"
            @ 21, Col() + 2 PROMPT "2. Change Catalogue"
            @ 21, Col() + 2 PROMPT "3. Another Part"
            @ 21, Col() + 2 PROMPT "4. Delete Part"
            @ 23, 6      PROMPT "5. By Catalogue"
            @ 23, Col() + 2 PROMPT "6. Part Details"
            @ 23, Col() + 2 PROMPT "7. Edit Group"
            @ 23, Col() + 2 PROMPT "EXIT"
            MENU TO nselect
            DO CASE
            CASE nselect == 8 .OR. PressedEsc()
                RETURN NIL
            CASE nselect == 7
                GroupEdit()                    // Above
                LOOP
            CASE nselect == 1
                ntradeDate := 0
                nl++
                @ nl, 19      GET mdesc
                nl++
                @ nl, 6      SAY Part->RetIndiv COLOR "RG+"
                @ nl, Col() + 2 SAY Trim( Part->Unit ) + " Cost " GET ntrade PICTURE "999999.99"
                @ nl, Col() + 2 SAY "Mkup %"                    GET nmarkup PICTURE "9999.99"
                READ
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                ApRLock( 3 )
                IF Part->Trade != ntradeDate
                    Part->Date := Date()
                ENDIF                       // Part->Trade
                Part->Trade  := ntrade
                Part->Markup := nmarkup
                nsell := ( Part->Trade * ( 1 + ( Part->Markup / 100 ) ) )
                Part->Wholesale := ( Part->Trade * ( 1 + ( Part->Markup / 100 ) ) )
                UNLOCK
                nwholesale := Part->Wholesale
                nl += 2
                @ nl, 6      SAY Trim( Part->Unit ) + " Sell exl GST";
                    GET nwholesale PICTURE "999999.99"
                READ
                DO CASE
                CASE Part->Boughtout = "Y"
                    nselect := 1
                OTHERWISE
                    nselect := 2
                ENDCASE
                @ nl, 38      PROMPT "Part Bought Out"
                @ nl, Col() + 2 PROMPT "Own Manufacture"
                MENU TO nselect
                ApRLock( 3 )
                DO CASE
                CASE nselect == 1
                    Part->Boughtout := "Y"
                CASE nselect == 2
                    Part->Boughtout := "N"
                ENDCASE
                Part->Wholesale := nwholesale
                Part->Markup := ( ( Part->Wholesale - Part->Trade ) / Part->Trade ) * 100
                Part->Desc    := mdesc
                UNLOCK
            CASE nselect == 2
                SELECT Cat
                GO TOP
                nrecno := 0
                aPart_ := {}
                DO WHILE Cat->( !Eof() )
                    AAdd( aPart_, FieldGet( 1 ) + "     " + FieldGet( 2 ) )
                    SKIP ALIAS Cat
                ENDDO
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    tempscr := SaveScreen( 0, 0, 24, 80 )
                    Scroll()
                    DispBox( 0, 1, 22, 79, 2 )
                    @  1, 3      SAY Part->Desc    COLOR "BG+"
                    @  1, Col() + 2 SAY SubStr( Part->Partnum, 1, 16 ) COLOR "BG+"
                    @  1, Col() + 2 SAY Part->Catno   COLOR "BG+"
                    @  3, 6      SAY "SELECT NEW Catalogue" COLOR "R+"
                    nAnum := AChoice( 4, 5, 21, 72, aCatcode_,, "AFUNC" )  // Select Cat
                    cnewcatno := SubStr( aCatcode_[ nAnum ], 1, 12 )
                    SELECT Part
                    ApRLock( 3 )
                    Part->Catno := cnewcatno
                    UNLOCK
                    Scroll( 8, 0, 24, 80 )
                    DispBox( 10, 1, 18, 79, 2 )
                    @  12, 3      SAY Part->Desc    COLOR "BG+"
                    @  12, Col() + 2 SAY SubStr( Part->Partnum, 1, 16 ) COLOR "BG+"
                    @  12, Col() + 2 SAY Part->Catno   COLOR "RG+"
                    Inkey( 3 )
                    RestScreen( 0, 0, 24, 80, tempscr )
                ENDIF
                LOOP

            CASE nselect == 3
                EXIT

            CASE nselect == 4
                PartDelete()              // CWP2
                LOOP
            CASE nselect == 5
                CatList()              // XF2PPART
                LOOP
            CASE nselect == 6
                PartDets( @mpartnum )              // CWPP2
                LOOP

            ENDCASE
        ENDDO                    // mok

    ENDDO                    // manother

    RETURN NIL
// ***------------  ModPart

// **----------------------------------------------------------

FUNCTION MET_QPart( nc, ncl )

    DO WHILE .T.

        nselect := 0
        nc      := ncl
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 2, 5, nc + ( ncl - 2 ) )
        DispBox( 3, nc + 2, 5, nc + ( ncl - 2 ) )
        SELECT Debit
        GOTO TOP
        nl := nll := nlll := 4
        npl := npll := 20
        ccodeno := Space( 14 )
        @  3, 54 SAY "Completed Jobs" COLOR "RG+"
        DO WHILE Debit->( !Eof() )
            IF Debit->Stat = "I"
                SKIP ALIAS Debit
                LOOP
            ENDIF
            IF SubStr( Debit->Equip, 1, 1 ) != "Y"
                SKIP ALIAS Debit
                LOOP
            ENDIF
            IF Debit->Codeno + Debit->Invno = ccodeno
                SKIP ALIAS Debit
                LOOP
            ENDIF
            DO CASE
            CASE nl <= npl
                @ nl, 52   SAY Debit->Codeno + " " + Debit->Invno
                nl++
            CASE nll <= npll
                @ nll, 67  SAY Debit->Codeno + " " + Debit->Invno
                nll++
            OTHERWISE
                @ nlll, 65 SAY Debit->Codeno + " " + Debit->Invno
                nlll++
            ENDCASE
            ccodeno := Debit->Codeno + Debit->Invno
            SKIP ALIAS Debit
        ENDDO                          // EOF()
        // **   SELECT Quotstk
        // **   COUNT TO nrecno
        // **   @  7,53      SAY "JC-File" COLOR "B+"
        // **   @  7,COL()+2 SAY nrecno    PICTURE "99999"
        cheading := "JOB CARD MENU"
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( cheading ) ) / 2 );
            SAY RTrim( cheading )
        @  7, nc + 2 PROMPT "1. JOB CARDS SEARCH    "
        @  8, nc + 2 PROMPT "2.  ..       Add/Edit  "
        @  9, nc + 2 PROMPT "3. JOB CARDS Menu      "
        @ 11, nc + 2 PROMPT "4. LABOUR  By    Name  "
        @ 13, nc + 2 PROMPT "5. JC-  By Start Date  "
        @ 15, nc + 2 PROMPT "6. JC-Parts Req/Rec/Ord"
        @ 17, nc + 2 PROMPT "7. OPERATION/DRAWING   "
        @ 18, nc + 2 PROMPT "8. Clean up Operations "
        @ 19, nc + 2 PROMPT "9. Job Menu System     "
        @ 20, nc + 2 PROMPT Menu->CH_Main + "   "
        nc := ncl
        MENU TO nselect
        DO CASE
        CASE nselect == 10 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 1                             // Search
            SAVE SCREEN TO Invscrn
            // **           IF SUBSTR( Control->U_Name,1, 4 ) = "META"
            QuotSearch()                             // XLF_Quot
            // **             ELSE
            // **              LessonSearch()
            // **           ENDIF
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 2                             // Add  Edit
            SAVE SCREEN TO Invscrn
            mcodeno := Space( 8 )
            Namerank( @mcodeno )                      // ZSF_Name
            IF PressedEsc()
                RETURN NIL
            ENDIF
            mcodeno := Name->Codeno
            cbranchId := Space( 2 )
            SELECT Branch
            SEEK mcodeno
            IF Found()
                Scroll()
                DispBox( 0, 1, 2, 79, 2 )
                @  1, 4 SAY Name->Name
                BranchFind( @mcodeno )                // ZSF_Name
                cbranchId := Branch->BranchId
                mok := ApGetY( "Do you Want Branch" )
                IF mok = "N"
                    cbranchId := Space( 2 )
                ENDIF
            ENDIF
            Quotadd( mcodeno, cbranchId )               // Below
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 3            // Job Cards
            SAVE SCREEN TO Invscrn
            @  9, nc + 2 SAY "3. JOB CARDS Menu      " COLOR "GB+"
            Mu_Quot( nc, ncl )                     // XLF_Quot
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 4             // By Name
            SAVE SCREEN TO Invscrn
            SELECT Control
            ApRLock( 3 )
            Control->LastRoll := Date() -1
            UNLOCK
            IF SubStr( Control->U_Name, 1, 4 ) = "META"
                LabourWo()                   // XLF_QU5
            ELSE
                LabourShan()                 // XLF_QU10
            ENDIF
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 5
            SAVE SCREEN TO Invscrn
            QuotStart()             // XF_QList
            RESTORE SCREEN FROM Invscrn
            LOOP
        CASE nselect == 6
            SAVE SCREEN TO Invscrn
            JCReqRec()              // XLF_QU6
            RESTORE SCREEN FROM Invscrn
            LOOP
        CASE nselect == 7             // By Total
            SAVE SCREEN TO Invscrn
            @ 17, nc + 2 SAY "7. OPERATION/DRAWING   " COLOR "GB+"
            Mu_Oper( nc, ncl )        // XLF_Equ2
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 8                             //
            SAVE SCREEN TO Invscrn
            OperDelete()                        // XLF_Ser.PRG
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 9                             //
            SAVE SCREEN TO Invscrn
            JobAnalyA()   // XLF_MenuA.prg
            RESTORE SCREEN FROM Invscrn
         /*
         CASE nselect == 9
            SAVE SCREEN TO Invscrn
              JobLabour()                           // JobDem
            RESTORE SCREEN FROM Invscrn
         */
        ENDCASE
    ENDDO

    RETURN NIL

// **------ End of MET_QPart

// *---------------------------------------------------------------------*

FUNCTION JobOutXY()

    SELECT QuotStk
    SET ORDER TO 2   // Partnum
    Scroll()
    cpagehd  := "SPmodXY"
    npn := 1
    mwhere := "S"

    Printsel()

    IF mwhere = "P"
        npl := 56
    ELSE
        npl := 22
    ENDIF
    @  0, 2 SAY Control->U_Name
    @  0, 40 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  0, 65 SAY cpagehd
    @  0, 76 SAY npn PICTURE "99"
    @  2, 1 SAY "Part #"
    @  2, 17 SAY "Description"
    @  2, 45 SAY "Required-Received O/S"
    nl := 3
    nreq := malloc := 0
    SELECT QuotStk
    GOTO TOP
    DO WHILE QuotStk->( !Eof() )
        IF SubStr( QuotStk->Partnum, 1, 2 ) != "XY"
            SKIP ALIAS QuotStk
            LOOP
        ENDIF
        IF QuotStk->Required = 0
            SKIP ALIAS QuotStk
            LOOP
        ENDIF
        IF QuotStk->Received >= QuotStk->Required
            SKIP ALIAS QuotStk
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere = "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            @  0, 2 SAY Control->U_Name
            @  0, 40 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  0, 65 SAY cpagehd
            @  0, 76 SAY npn PICTURE "99"
            @  2, 1 SAY "Part #"
            @  2, 17 SAY "Description"
            @  2, 45 SAY "Required-Received O/S"
            nl := 3
        ENDIF         // nl > npl
        SELECT Part
        SEEK QuotStk->Partnum
        SELECT QuotStk
        @ nl, 0 SAY SubStr( QuotStk->Partnum, 1, 16 )
        @ nl, 17 SAY SubStr( Part->Desc, 1, 36 )
        nrequired := 0
        mpart     := QuotStk->Partnum
        DO WHILE QuotStk->Partnum = mpart .AND. QuotStk->( !Eof() )
            IF QuotStk->Required = 0
                SKIP ALIAS QuotStk
                LOOP
            ENDIF
            IF QuotStk->Received >= QuotStk->Required
                SKIP ALIAS QuotStk
                LOOP
            ENDIF
            IF SubStr( QuotStk->Partnum, 1, 2 ) != "XY"
                SKIP ALIAS QuotStk
                LOOP
            ENDIF
            nrequired += QuotStk->Required - QuotStk->Received
            SKIP ALIAS QuotStk
        ENDDO                 // QuotStk
        @ nl, 55 SAY nrequired PICTURE "999,999.99"
        @ nl, 66 SAY SubStr( Part->Unit, 1, 5 )
        @ nl, 72 SAY Part->Codeno
        nl++
    ENDDO                               // QuotStk
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
    SELECT QuotStk
    SET ORDER TO 1              // Invno

    RETURN NIL
// ***------  END JobOutXY()

// ****---------------------------------------------------------------------

FUNCTION METQMenu( nc, ncl )

    DO WHILE .T.
        nselect := 0
        nc      := ncl * 2
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 2, 5, nc + ( ncl - 2 ) )
        DispBox( 3, nc + 2, 5, nc + ( ncl - 2 ) )
        cheading := "JOB CARD INFO"
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( cheading ) ) / 2 );
            SAY RTrim( cheading )
        @  7, nc + 2 PROMPT "1. JC-   Info   Search"
        @ 10, nc + 2 PROMPT "2. Name  Part   Search"
        @ 11, nc + 2 PROMPT "3.  ..   Part Add/Edit"
        @ 12, nc + 2 PROMPT "4.       Part  by Name"
        @ 13, nc + 2 PROMPT "5.       Part  Listing"
        @ 20, nc + 2 PROMPT Menu->CH_Main
        nc := ncl
        MENU TO nselect
        DO CASE
        CASE nselect = 6 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 1
            SAVE SCREEN TO Invscrn
            METuotSrch()                             // MetQuHse
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 2
            SAVE SCREEN TO Invscrn
            MEuotSearch()                             //
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 3
            SAVE SCREEN TO Invscrn
            MEuotadd()                                // Below
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 4
            SAVE SCREEN TO Invscrn
            MEartSearch()
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 5
            SAVE SCREEN TO Invscrn
            MEApplicant()
            RESTORE SCREEN FROM Invscrn
        ENDCASE
    ENDDO

    RETURN NIL

// **------ End of METQPart

// **---------------------------------------------------------------------*

FUNCTION METApplicant()

    minvno  := Space( 6 )
    mcodeno := Space( 8 )
    aPart_ := anum := {}
    nrecno := 0
    Scroll()
    SELECT QuotInfo
    IF LastRec() != 0
        GOTO TOP
        DO WHILE QuotInfo->( !Eof() )
            IF QuotInfo->Invno = Space( 6 )
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            IF QuotInfo->Codeno = "A"
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            AAdd( aPart_, QuotInfo->Invno;
                + " " + QuotInfo->Codeno;
                + " " + QuotInfo->Info;
                + "   " + Str( RecNo(), 6 ) )
            SKIP ALIAS QuotInfo
        ENDDO
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 3 SAY "JC- Information List"
        DispBox( 3, 1, 24, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            SELECT QuotInfo
            GOTO nrecno
        ENDIF
        mcodeno  := QuotInfo->Codeno

        MeTuotEdit( mcodeno )               // MetQuHse

    ENDIF                       // LastRec

    RETURN NIL
// ***---- End of METApplicant()

// ---------------------------------------------------------------------*

FUNCTION METuotJSheet()

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        moper  := "N"
        mallparts := "Y"
        mwhere := "S"
        npl    := 0
        nrecno := 0
        nl     := 0

        Printsel()                               // _LF_Init

        @ nl, 0 SAY Control->U_Name
        @ nl, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl += 2
        SELECT Name
        SEEK QuotInfo->Codeno
        @ nl, 0 SAY Name->Name
        nl++
        @ nl, 0 SAY Name->Add1
        nl++
        IF Name->Add3 != "     "
            @ nl, 0 SAY Name->Add2
            nl++
        ENDIF
        IF Name->Add3 != "     "
            @ nl, 0 SAY Name->Add3
            nl++
        ENDIF
        @ nl, 0 SAY Trim( Name->Add4 ) + "       Ph " + Name->Phone;
            + "  " + Name->Mobphone
        nl += 2
        @ nl, 4 SAY Debit->Invno
        @ nl, 14 SAY Debit->DBDate
        @ nl, 40 SAY "Due Date"
        @ nl, 50 SAY Debit->DueDate
        nl++
        @ nl, 12 SAY Debit->Est
        nl++
        IF SubStr( Debit->Note1, 1, 3 ) != Space( 3 )
            @ nl, 12 SAY Debit->Note1
            nl++
        ENDIF
        IF SubStr( Debit->Note2, 1, 3 ) != Space( 3 )
            @ nl, 12 SAY Debit->Note2
            nl++
        ENDIF
        IF SubStr( Debit->Note3, 1, 3 ) != Space( 3 )
            @ nl, 12 SAY Debit->Note3
            nl++
        ENDIF
        mcodeno := Name->Codeno
        SELECT QuotInfo
        GOTO TOP
        SEEK mcodeno
        nline := 0
        DO WHILE QuotInfo->Codeno = mcodeno .AND. QuotInfo->( !Eof() )
            IF QuotInfo->Invno != Debit->Invno
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            IF SubStr( QuotInfo->Info, 1, 3 ) != Space( 3 )
                @ nl, 12 SAY QuotInfo->Info
                nl++
            ENDIF
            IF SubStr( QuotInfo->Info2, 1, 3 ) != Space( 3 )
                @ nl, 12 SAY QuotInfo->Info2
                nl++
            ENDIF
            IF SubStr( QuotInfo->Info3, 1, 3 ) != Space( 3 )
                @ nl, 12 SAY QuotInfo->Info3
                nl++
            ENDIF
            IF SubStr( QuotInfo->Info4, 1, 3 ) != Space( 3 )
                @ nl, 12 SAY QuotInfo->Info4
                nl++
            ENDIF
            IF SubStr( QuotInfo->Info5, 1, 3 ) != Space( 3 )
                @ nl, 12 SAY QuotInfo->Info5
                nl++
            ENDIF
            IF SubStr( QuotInfo->Info6, 1, 3 ) != Space( 3 )
                @ nl, 12 SAY QuotInfo->Info6
                nl++
            ENDIF
            SELECT Cusnotes
            cdetail := ""
            coderef := QuotInfo->Faxno
            SEEK coderef
            IF Found()
                nl++
                @ nl, 0 SAY ""
                Getdets( coderef )                           // XF_Memo2
                FormP( cdetail, 60, 10 )                       // XF_Memo2
            ENDIF                          // Found()
            SELECT QuotInfo
            SKIP ALIAS QuotInfo
        ENDDO                            // EOF() QuotInfo
        nl++
        IF mwhere = "P"
            IF nl > 40
                nl := 1
                EJECT
            ENDIF
        ENDIF
        IF mwhere = "P"
            nl++
            npl := nl
            nline = 1
            FOR nline = 1 TO ( 36 -npl )
                @ nl, 0 SAY "__________________________________________________________________________"
                nl += 2
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

    RETURN NIL
// ****** End of METuotJSheet()

// *---------------------------------------------------------------------*

FUNCTION METartSrch()

    aPart_ := anum := {}
    nrecno := 0
    Scroll()
    SELECT QuotInfo
    IF LastRec() != 0
        GOTO TOP
        mpartnum := Space( 20 )
        DO WHILE QuotInfo->( !Eof() )
            IF QuotInfo->Invno = Space( 6 )
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            IF QuotInfo->Invno != minvno
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            SELECT Debit
            SET ORDER TO 2                    // Invno
            SEEK QuotInfo->Invno
            SET ORDER TO 1                    // Codeno
            SELECT QuotInfo
            AAdd( aPart_, QuotInfo->Invno + " " + Debit->Est;
                + "           " + Str( RecNo(), 6 ) )
            minvno := QuotInfo->Invno
            SKIP ALIAS QuotInfo
        ENDDO
        DispBox( 0, 1, 24, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 1, 3, 23, 78, aPart_,, "AFUNC" )
            IF PressedEsc()
                SELECT QuotInfo
                SET INDEX TO QuInfo
                RETURN NIL
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
        ENDIF
        minvno := QuotInfo->Invno
        aPart_ := {}
        nrecno := 0
        cInvno := Space( 10 )
        SELECT QuotInfo
        SEEK minvno
        DO WHILE QuotInfo->( !Eof() )
            IF QuotInfo->Invno = Space( 6 )
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            IF QuotInfo->Invno != minvno
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            SELECT Debit
            SET ORDER TO 2                        // Invno
            SEEK minvno
            SET ORDER TO 1                        // Codeno
            SELECT QuotInfo
            AAdd( aPart_, QuotInfo->Invno;
                + " " + QuotInfo->Info;
                + " " + Debit->Est;
                + "        " + Str( RecNo(), 6 ) )
            SKIP ALIAS QuotInfo
        ENDDO
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 3      SAY minvno     COLOR "G+"
        @  1, Col() + 1 SAY Debit->Est COLOR "G+"
        DispBox( 3, 1, 24, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
            IF PressedEsc()
                RETURN NIL
            ENDIF
        ENDIF
    ENDIF                       // LastRec

    METartSrch()                 // Above

    RETURN NIL
// ***---- End of METartSrch()

// *---------------------------------------------------------------------*

FUNCTION METuotPrice()

    SELECT Name
    SEEK Debit->Codeno
    Scroll()
    DispBox( 0, 1, 2, 79, 2 )
    @  1, 3 SAY Name->Name COLOR "BG+"
    DispBox( 3, 1, 24, 79, 2 )
    nl := 4
    @ nl, 3 SAY Debit->Invno + " " + Debit->Est + "  " + Debit->Codeno COLOR "BG+"
    nl++
    SELECT QuotInfo
    ApRLock( 3 )
    @ nl, 4 SAY "Memo        " GET QuotInfo->Info
    nl++
    @ nl, 17 GET QuotInfo->Info2
    nl++
    @ nl, 17 GET QuotInfo->Info3
    nl++
    @ nl, 17 GET QuotInfo->Info4
    nl++
    @ nl, 17 GET QuotInfo->Info5
    nl++
    @ nl, 17 GET QuotInfo->Info6
    nl += 2
    READ
    UNLOCK
    SELECT Debit
    ApRLock( 3 )
    @ nl, 10 SAY Debit->Invno   GET Debit->Est
    nl++
    READ
    UNLOCK
    SELECT Cusnotes
    coderef := QuotInfo->Faxno
    SEEK coderef
    // **   IF FOUND()

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
    // **   ENDIF            // Found Memo

    RETURN minvno

// ***------- End METQuotPrice

// *-------------------------------------------------------------------

FUNCTION METuotAdd()

    dDbDate   := Date()
    mcodeno   := Space ( 8 )
    mpartnum  := Space( 20 )
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"

        SELECT Debit
        // ** SET ORDER TO 1                      // Codeno
        GOTO TOP
        IF LastRec() != 0
            aPart_ := {}
            nrecno := 0
            DO WHILE Debit->( !Eof() )
                IF Debit->Stat != "J"
                    SKIP ALIAS Debit
                    LOOP
                ENDIF
                AAdd( aPart_, Debit->Invno + " " + Debit->Stat;
                    + " " + Debit->Codeno;
                    + " " + DToC( Debit->Dbdate );
                    + " " + Debit->Est;
                    + " " + Debit->Note1;
                    + "          " + Str( RecNo(), 6 ) )
                SKIP ALIAS Debit
            ENDDO
            IF !Empty( aPart_ )
                Scroll()
                DispBox(  0, 1, 24, 79, 2 )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice(  1, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ], 6 ) )
                GOTO nrecno
                minvno  := Debit->Invno
                mcodeno := Debit->Codeno
            ENDIF                     // Empty
        ENDIF                        // LastRec
        manother := "Y"
        DO WHILE manother = "Y"
            mok := "Y"
            DO WHILE mok = "Y"
                Scroll( 3, 0, 24, 80 )
                // **        IF FOUND()
                // **           METuoLook()                 // METQuHse.PRG
                // **        ENDIF
                Scroll(  12, 0, 24, 80 )
                DispBox( 12, 1, 24, 79, 2 )
                @ 13, 4      SAY Trim( QuotInfo->Partnum )
                @ 13, Col() + 2 SAY Part->Desc  COLOR "BG+"
                @ 15, 4      SAY QuotInfo->Info
                @ 16, 4      SAY QuotInfo->Info2
                @ 17, 4      SAY QuotInfo->Info3
                @ 18, 4      SAY QuotInfo->Info4
                @ 19, 4      SAY QuotInfo->Info5
                @ 20, 4      SAY QuotInfo->Info6
                DispBox( 22, 1, 24, 79, 2 )
                nselect := 1
                @ 23, 4      PROMPT "Add Job Card"
                @ 23, Col() + 3 PROMPT "Edit Info"
                @ 23, Col() + 3 PROMPT "Job Card"
                @ 23, Col() + 3 PROMPT "Another"
                MENU TO nselect
                DO CASE
                CASE PressedEsc()
                    RETURN NIL
                CASE nselect == 1
                    Quotcodeno := Space( 8 )
                    mpartnum := Space( 20 )
                    METuotPAdd( @mpartnum )                      // MEQuoHse
                    LOOP
                CASE nselect == 2
                    METuotEdit( @mcodeno )                       // MEQuoHse
                    LOOP
                CASE nselect == 3
                    mcodeno := Name->Codeno
                    METuotJSheet( @mcodeno )                      // Below
                    LOOP
                CASE nselect == 4                     // Qty Desc
                    LOOP
                ENDCASE
            ENDDO                               // End of more Parts
        ENDDO
        mcontinue := "N"
    ENDDO                                   // mcontinue

    RETURN NIL

// ***----- End of METuotadd()

// *-------------------------------------------------------------------

FUNCTION METuotIndi()

    PrintSel()

    IF mwhere = "P"
        @  0, 0
        SET DEVICE TO PRINT
        npl := 65
    ELSE
        Scroll()
        npl := 22
    ENDIF
    nl := 4
    @ nl, 0 SAY Control->U_Name
    @ nl, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    nl += 2
    SELECT Name
    mcodeno := Debit->Codeno
    SEEK mcodeno
    @ nl, 0 SAY Name->Name
    nl++
    @ nl, 0 SAY Name->Add1
    nl++
    IF Name->Add3 != "     "
        @ nl, 0 SAY Name->Add2
        nl++
    ENDIF
    IF Name->Add3 != "     "
        @ nl, 0 SAY Name->Add3
        nl++
    ENDIF
    @ nl, 0 SAY Trim( Name->Add4 ) + "       Ph " + Name->Phone;
        + "  " + Name->Mobphone
    nl += 2
    SELECT QuotInfo
    GOTO TOP
    DO WHILE QuotInfo->Codeno = mcodeno .AND. QuotInfo->( !Eof() )
        IF QuotInfo->Invno != Debit->Invno
            SKIP ALIAS QuotInfo
            LOOP
        ENDIF
        IF mwhere = "P" .AND. nl >= 55              // Adjust no of items
            @  0, 0 SAY Chr( 27 ) + Chr( 67 ) + Chr( 03 )
            SET DEVICE TO SCREEN
            @ 12, 10 SAY " "
            @ 14, 10 SAY "ALIGN PAPER to TOP OF PAGE"
            @ 16, 10 SAY " WAIT FOR PRINTER TO STOP"
            WAIT
            SET DEVICE TO PRINT
        ELSEIF Row() = 18
            WAIT
            nl := 0
            Scroll()
        ENDIF                                // mwhere
        nl++
        SELECT Name
        @ nl, 10 SAY Name->Name
        SELECT Debit
        @ nl, 12 SAY Debit->Est
        @ nl, 64 SAY Debit->Codeno
        nl++
        IF SubStr( Debit->Note1, 1, 3 ) != Space( 3 )
            @ nl, 12 SAY Debit->Note1
            nl++
        ENDIF
        IF SubStr( Debit->Note2, 1, 3 ) != Space( 3 )
            @ nl, 12 SAY Debit->Note2
            nl++
        ENDIF
        IF SubStr( Debit->Note3, 1, 3 ) != Space( 3 )
            @ nl, 12 SAY Debit->Note3
            nl++
        ENDIF
        @ nl, 6 SAY QuotInfo->Invno
        @ nl, 16 SAY QuotInfo->DBDate
        @ nl, 26 SAY QuotInfo->DueDate
        @ nl, 38 SAY QuotInfo->Codeno
        nl++
        IF SubStr( QuotInfo->Info, 1, 3 ) != Space( 3 )
            @ nl, 10 SAY QuotInfo->Info
            nl++
        ENDIF
        IF SubStr( QuotInfo->Info2, 1, 3 ) != Space( 3 )
            @ nl, 10 SAY QuotInfo->Info2
            nl++
        ENDIF
        IF SubStr( QuotInfo->Info3, 1, 3 ) != Space( 3 )
            @ nl, 10 SAY QuotInfo->Info3
            nl++
        ENDIF
        IF SubStr( QuotInfo->Info4, 1, 3 ) != Space( 3 )
            @ nl, 10 SAY QuotInfo->Info4
            nl++
        ENDIF
        IF SubStr( QuotInfo->Info5, 1, 3 ) != Space( 3 )
            @ nl, 10 SAY QuotInfo->Info5
            nl++
        ENDIF
        IF SubStr( QuotInfo->Info6, 1, 3 ) != Space( 3 )
            @ nl, 10 SAY QuotInfo->Info6
            nl++
        ENDIF
        nl++
        SELECT Cusnotes
        cdetail := ""
        coderef := QuotInfo->Faxno
        SEEK coderef
        IF Found()
            GetDets( coderef )                            // XF_Memo2
            FormP( cdetail, 60, 10 )                        // XF_Memo2
        ENDIF
        nl++
        SELECT QuotInfo
        SKIP ALIAS QuotInfo
    ENDDO                                // EOF QuotInfo
    IF mwhere == "P"
        EndPrint()
    ELSE
        IF nl > 20
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF
    SELECT Name
    SEEK mcodeno

    RETURN NIL

// ** End of METuotIndi()

// ********----------  END OF FILE METQuot.PRG
