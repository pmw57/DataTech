// **   JoKir10 13-10-11 07:20:00

/*
   Program.....:                  XLF_QU6.PRG
   Authors.....: J.Kirby
   Date........: 18/06/2002
   Functions...: JobStatus, JobOutP, JCReqRec, JCStat
                 JCStatLab, JobAllPa
   Static funcs: JobPrintP, JobAutoP
*/

FUNCTION JobStatus()

    Scroll()

    @ 16, 12 SAY "Parts Listing" COLOR "G+"
    mxy     := ApGetN( "Do You Want XY Parts" )
    // ** cpagehd := "STpreqXY"
    minvno := Debit->Invno

    QuotUpDate( minvno )                      // XLF_QU7

    mwhere := "S"

    @ 16, 12 SAY "Listing Parts" COLOR "G+"

    Printsel()

    IF mwhere = "P"
        npl := 56
    ELSE
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
    @  2, 22 SAY "* Start Date *"
    @  2, 37 SAY Debit->StartDate
    @  2, 50 SAY "PARTS REQUIRED JC- " + minvno
    @  4, 0 SAY "Part #"
    @  4, 17 SAY "Description"
    @  4, 36 SAY "Location"
    @  4, 48 SAY "Instock"
    @  4, 56 SAY "Req Qty"
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
            @  2, 22 SAY "* Start Date *"
            @  2, 37 SAY Debit->StartDate
            @  2, 50 SAY "PARTS REQUIRED JC- " + minvno
            @  4, 0 SAY "Part #"
            @  4, 17 SAY "Description"
            @  4, 36 SAY "Location"
            @  4, 48 SAY "Instock"
            @  4, 56 SAY "Req Qty"
            nl := 5
        ENDIF

        SELECT Part
        SEEK Status->Partnum
        SELECT Status
        @ nl, 0 SAY SubStr( Status->Partnum, 1, 16 )
        @ nl, 17 SAY SubStr( Part->Desc, 1, 16 )
        @ nl, 36 SAY SubStr( Part->Locate, 1, 6 )
        @ nl, 43 SAY Status->EquLevel
        IF SubStr( Status->ModCode, 1, 2 ) = "XY"
            @ nl, 46 SAY "xy"
        ELSE
            @ nl, 46 SAY SubStr( Part->Unit, 1, 1 )
        ENDIF    // XY
        IF Part->InStock > 0
            @ nl, 50 SAY Part->InStock PICTURE "9999"
        ENDIF
        @ nl, 55 SAY Status->Required PICTURE "9999.99"
        @ nl, 62 SAY "_______"
        @ nl, 69 SAY Trim( Part->Codeno )
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

    RETURN NIL

// ***------  END JobStatus()

// **-------------------------------------------------------------------------

FUNCTION JobOutP()

    mselect := ApGetY( "Y = Standard List  N = Module Parts" )
    IF mselect = "Y"
        JobStatus()
        RETURN NIL
    ENDIF
    SELECT QuotStk
    SET ORDER TO 1   // Invno for next seek
    SEEK Debit->Invno
    IF !Found()
        UpDateJC()
        // **   @ 14,10 SAY "--- FILE NOT UPDATED IMPORTANT SELECT NO ---" COLOR "RG+"
    ELSE
        @ 14, 10 SAY Debit->Invno + " Job Card in Orders File" COLOR "RG+"
    ENDIF
    Scroll()
    minvno   := Debit->Invno
    cucodeno := "Y"             // U_Codeno Parts
    mxyonly  := "N"             // ONLY XY       TAKEN OUT FOR NOW
    cpagehd  := "SPmod"
    SELECT Name
    SEEK Debit->Codeno
    @  8, 50      SAY "Today " + Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @ 10, 10      SAY Name->Name + " " + minvno + " Start Date"
    @ 10, Col() + 2 SAY Debit->StartDate COLOR "R+"
    @ 12, 10      SAY "IF Start Date is Greater than Todays Date-1 there will be NO parts"
    mxy     := ApGetN( "Do You Want XY Parts" )
    IF mxy = "Y"
        cpagehd := "SPmodXY"
        mxyonly := ApGetN( "XY Modules Only" )
    ENDIF
    IF mxyonly = "Y"
        cpagehd  := "SPmodXYonly"
    ENDIF
    mmodule := ApGetN( "List By Module" )
    IF mmodule = "N"
        SELECT QuotStk
        ApFLock( 3 )
        REPLACE ALL Codeno WITH "ZMETAL" FOR Codeno = "METAL   "
        UNLOCK
        SET ORDER TO 3             // 3 = Codeno+Partnum
    ENDIF
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
    @  2, 2 SAY Name->Name
    @  2, 35 SAY Debit->StartDate
    @  2, 48 SAY "PARTS Order Module JC- " + minvno
    @  4, 1 SAY "Part #"
    @  4, 17 SAY "Description"
    @  4, 45 SAY "Stock"
    @  4, 52 SAY "Req Qty"
    // **      @  4,62 SAY "Received"
    @  4, 65 SAY "Location"
    nl := 5
    nreq := malloc := 0
    SELECT QuotStk
    GOTO TOP
    cmodcode := cmod := QuotStk->ModCode
    DO WHILE QuotStk->( !Eof() )
        IF QuotStk->Invno != minvno
            SKIP ALIAS QuotStk
            LOOP
        ENDIF
        IF SubStr( QuotStk->Partnum, 1, 2 ) = "ZZ"
            SKIP ALIAS QuotStk
            LOOP
        ENDIF
        IF QuotStk->Required = 0
            SKIP ALIAS QuotStk
            LOOP
        ENDIF
   /*
      IF mxy = "N"
         IF SUBSTR( QuotStk->Partnum, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF                            // mxy
   */
        IF mxy = "N"
            IF SubStr( QuotStk->ModCode, 1, 2 ) = "XY"
                SKIP ALIAS QuotStk
                LOOP
            ENDIF
        ENDIF                            // mxy
        IF mxyonly = "Y"
            IF SubStr( QuotStk->Partnum, 1, 2 ) != "XY"
                SKIP ALIAS QuotStk
                LOOP
            ENDIF
        ENDIF                           // mxyonly
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
            @  0, 65 SAY cpagehd
            @  0, 76 SAY npn PICTURE "99"
            @  2, 2 SAY Name->Name
            @  2, 35 SAY Debit->StartDate
            @  2, 48 SAY "PARTS Order Module JC- " + minvno
            @  4, 1 SAY "Part #"
            @  4, 17 SAY "Description"
            @  4, 45 SAY "Stock"
            @  4, 52 SAY "Req Qty"
            // **      @  4,62 SAY "Received"
            @  4, 65 SAY "Location"
            nl := 5
        ENDIF
        SELECT Part
        SET ORDER TO 1                        // Partnum
        SEEK QuotStk->Partnum
        SEEK QuotStk->Partnum
        mpartnum := QuotStk->Partnum
   /*
   Taken Out
         SELECT Orders
         SET ORDER TO 1                            // Partnum index
         GOTO TOP
         SEEK mpartnum
         mptot := 0
         IF FOUND()
            DO WHILE Orders->Partnum = mpartnum .AND. Orders->( !EOF() )
               mptot += Orders->Partqty-Orders->QtyRec
               SKIP ALIAS Orders
            ENDDO
         ENDIF
   Taken Out
   */
        SELECT QuotStk

        IF mmodule = "N"
            @ nl, 0 SAY SubStr( QuotStk->Partnum, 1, 16 )
            @ nl, 17 SAY SubStr( Part->Desc, 1, 24 )
            @ nl, 43 SAY QuotStk->EquLevel
            IF SubStr( QuotStk->ModCode, 1, 2 ) = "XY"
                @ nl, 45 SAY "x"
            ENDIF    // XY
            IF SubStr( QuotStk->Partnum, 1, 2 ) = "XY"
                @ nl, 45 SAY "xy"
            ELSE
                @ nl, 46 SAY SubStr( Part->Unit, 1, 1 )
            ENDIF    // XY
            nreceived := nrequired := 0
            mpart     := QuotStk->Partnum
            DO WHILE QuotStk->Partnum = mpart .AND. QuotStk->( !Eof() )
                IF QuotStk->Invno != minvno
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF
                IF SubStr( QuotStk->Partnum, 1, 2 ) = "ZZ"
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF
                IF QuotStk->Required = 0
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF
   /*
       IF mxy = "N"
         IF SUBSTR( QuotStk->Partnum, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF                            // mxy
   */
                IF mxy = "N"
                    IF SubStr( QuotStk->ModCode, 1, 2 ) = "XY"
                        SKIP ALIAS QuotStk
                        LOOP
                    ENDIF
                ENDIF                            // mxy
                IF mxyonly = "Y"
                    IF SubStr( QuotStk->Partnum, 1, 2 ) != "XY"
                        SKIP ALIAS QuotStk
                        LOOP
                    ENDIF
                ENDIF                           // mxyonly
                nreceived += QuotStk->Received
                nrequired += QuotStk->Required
                SKIP ALIAS QuotStk
            ENDDO
            // **   IF nreceived < nrequired
            IF Part->Instock > 0
                @ nl, 48 SAY Part->Instock  PICTURE "99999"
            ENDIF
            @ nl, 54 SAY QuotStk->Required PICTURE "9999.99"
            @ nl, 62 SAY "_____________"
            @ nl, 76 SAY SubStr( Part->Codeno, 1, 4 )
            nl++
            // **   ENDIF
            // **     ELSE
            // **       @ nl,69 SAY "___________"
            // **   ENDIF
            LOOP
        ENDIF     // mmodule
        // ************************  Module
        IF mmodule = "Y"
   /*
      IF QuotStk->Modcode = cmod
         @ nl, 6 SAY QuotStk->Modcode+" Qty "+STR( QuotStk->EquQty, 8, 2 )
         nl++
         cmod := "999999999999999"
      ENDIF
   */
            IF cmodcode != QuotStk->Modcode
                @ nl, 6 SAY QuotStk->Modcode + " Qty " + Str( QuotStk->EquQty, 8, 2 )
                nl++
                cmodcode := QuotStk->ModCode
            ENDIF
            @ nl, 0 SAY SubStr( QuotStk->Partnum, 1, 16 )
            @ nl, 17 SAY SubStr( Part->Desc, 1, 24 )
            @ nl, 43 SAY QuotStk->EquLevel
            IF SubStr( QuotStk->ModCode, 1, 2 ) = "XY"
                @ nl, 45 SAY "x"
            ENDIF    // XY
            IF SubStr( QuotStk->Partnum, 1, 2 ) = "XY"
                @ nl, 45 SAY "xy"
            ELSE
                @ nl, 46 SAY SubStr( Part->Unit, 1, 1 )
            ENDIF    // XY
            IF Part->Instock > 0
                @ nl, 48 SAY Part->Instock  PICTURE "99999"
            ENDIF
            @ nl, 54 SAY QuotStk->Required PICTURE "9999.99"
            @ nl, 62 SAY "_________"
            @ nl, 72 SAY Part->Codeno
            nl++
        ENDIF     // mmodule
        SELECT QuotStk
        SKIP ALIAS QuotStk
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
// ***------------ End JobOutP

// ****---------------------------------------------------------------------

FUNCTION JCReqRec()                // Outstanding

    minvno := Space( 6 )
    SELECT Debit
    SET ORDER TO 2                 // Invno
    SEEK mInvno
    SET ORDER TO 1
    IF Found()
        minvno := Debit->Invno
    ENDIF
    IF !Found() .OR. minvno = Space( 6 )
        Scroll()
        mcodeno := Space( 8 )
        nrecno   := 0
        aPart_   := {}
        SELECT Debit
        GOTO TOP
        IF LastRec() != 0
            DO WHILE Debit->( !Eof() )
                IF Debit->Codeno = mcodeno
                    SKIP ALIAS Debit
                    LOOP
                ENDIF
                IF Debit->Stat != "J"
                    SKIP ALIAS Debit
                    LOOP
                ENDIF
                SELECT Name
                SEEK Debit->Codeno
                SELECT Debit
                mcodeno := Debit->Codeno
                AAdd( aPart_, Name->Name + "  " + Debit->BranchId;
                    + "         " + Str( RecNo(), 6 ) )
                SKIP ALIAS Debit
            ENDDO                          // EOF()
            SELECT Debit
            GOTO TOP
            DispBox( 0, 1, 23, 40, 2 )
            @ 24, 3 SAY "F2 To View ALL Job Cards" COLOR "GB+"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice( 1, 3, 22, 38, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                GOTO nrecno
                mcodeno := Debit->Codeno
                SELECT Name
                SEEK mcodeno
            ENDIF
            IF LastKey() == -1
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
                            + " " + Debit->Equip;
                            + " " + Debit->Codeno;
                            + " " + Debit->BranchId;
                            + " " + DToC( Debit->Dbdate );
                            + " " + Str( Debit->Amount, 10, 2 ) + " " + Debit->Saleno;
                            + " " + Debit->Est + "                        " + Str( RecNo(), 6 ) )
                        SKIP ALIAS Debit
                    ENDDO
                    IF !Empty( aPart_ )
                        Scroll()
                        DispBox(  0, 1, 24, 79, 2 )
                        ASort( aPart_,,, {| x, y | x < y } )
                        anum   := AChoice(  1, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
                        nrecno := Val( Right( aPart_[ anum ], 6 ) )
                        GOTO nrecno
                        minvno := Debit->Invno
                        mcodeno := Debit->Codeno
                        SELECT Name
                        SEEK mcodeno
                    ENDIF                     // Empty
                ENDIF                        // LastRec
            ENDIF                         // F1
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @  1, 10 SAY Name->Name
        ENDIF                        // LastRec
        SELECT Debit
        GOTO TOP
        IF LastRec() != 0
            aPart_ := {}
            nrecno := 0
            DO WHILE Debit->( !Eof() )
                IF Debit->Stat != "J"
                    SKIP ALIAS Debit
                    LOOP
                ENDIF
                IF Debit->Codeno != mcodeno
                    SKIP ALIAS Debit
                    LOOP
                ENDIF
                AAdd( aPart_, Debit->Invno + " " + Debit->Stat;
                    + " " + Debit->Codeno;
                    + " " + DToC( Debit->Dbdate );
                    + " " + Str( Debit->Amount, 9, 2 ) + " " + Debit->Saleno;
                    + " " + Debit->Est + "                        " + Str( RecNo(), 6 ) )
                SKIP ALIAS Debit
            ENDDO
            IF !Empty( aPart_ )
                Scroll(   3, 0, 24, 80 )
                DispBox(  3, 1, 24, 79, 2 )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice(  4, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ], 6 ) )
                GOTO nrecno
                minvno := Debit->Invno
                cDesc  := Debit->Est
            ENDIF                     // Empty
        ENDIF                        // LastRec
    ENDIF                   // Invno SPACE()
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        mpartnum := Space( 20 )
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 10 SAY Name->Name + "   " + minvno
        SELECT QuotStk
        SET ORDER TO 1    // Invno                          // 2  Partnum
        GOTO TOP
        aPart_ := {}
        nrecno := 0
        SEEK minvno
        SEEK Debit->Invno
        IF !Found()
            @ 18, 10 SAY "--- THIS INVOICE NOT IN ORDERS FILE ---" COLOR "RG+"
            WAIT
            RETURN NIL
        ENDIF
        DO WHILE QuotStk->Invno = minvno .AND. QuotStk->( !Eof() )
            IF SubStr( QuotStk->Partnum, 1, 2 ) = "ZZ"
                SKIP ALIAS QuotStk
                LOOP
            ENDIF
            SELECT Part
            SET ORDER TO 1                        // Partnum
            SEEK QuotStk->Partnum
            mpartnum := QuotStk->Partnum
            SELECT Orders
            SET ORDER TO 1                            // Partnum index
            GOTO TOP
            SEEK mpartnum
            mptot := 0
            IF Found()
                DO WHILE Orders->Partnum = mpartnum .AND. Orders->( !Eof() )
                    mptot += Orders->Partqty - Orders->QtyRec
                    SKIP ALIAS Orders
                ENDDO
            ENDIF
            SELECT QuotStk
            AAdd( aPart_, SubStr( QuotStk->Partnum, 1,16 );
                + " " + Str( Part->Instock, 9, 3 );
                + " " + Str( QuotStk->Required, 9, 3 );
                + " " + Str( QuotStk->Received, 9, 3 );
                + " " + Str( ( QuotStk->Required - QuotStk->Received ), 9, 3 );
                + " " + Str( mptot, 10, 3 );
                + " " + Part->Codeno;
                + "               " + Str( RecNo(), 6 ) )
            SKIP ALIAS QuotStk
        ENDDO                        // QuotStk EOF
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            DispBox( 3, 0, 24, 79, 2 )
            @  3, 19 SAY "  Instock  Required   Received    Out/S  Ordered "
            anum := AChoice(  4, 1, 23, 78, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
            GOTO nrecno
            mpartnum := QuotStk->Partnum
        ENDIF                        // Empty
        IF LastKey() = 27
            RETURN NIL
        ENDIF
        SELECT Part
        SET ORDER TO 1                           // Partnum
        SEEK mpartnum
        Scroll(  11, 2, 23, 78 )
        DispBox( 11, 3, 19, 77, 2 )
        nl := 11
        @ nl, 23    SAY " Required Less Allocated" COLOR "G+"
        @ nl, Col() SAY QuotStk->Required - QuotStk->Received PICTURE "99,999.999 " COLOR "G+"
        nl++
        @ nl, 6      SAY Trim( Part->Partnum )
        @ nl, Col() + 2 SAY Trim( Part->Desc )
        nl++
        ninstock  := Part->Instock
        nreceived := QuotStk->Received
        @ nl, 6      SAY "Instock ="
        @ nl, Col() + 1 GET ninstock    PICTURE "99999.999"
        @ nl, Col() + 1 SAY "Required"
        @ nl, Col() + 1 SAY QuotStk->Required PICTURE "99999.999"
        @ nl, Col() + 1 SAY "Received"
        @ nl, Col() + 1 GET nreceived PICTURE "99999.999"
        READ
        IF LastKey() = 27
            RETURN NIL
        ENDIF
        ApRlock( 3 )
        Part->Instock := ninstock
        UNLOCK
        SELECT QuotStk
        ApRlock( 3 )
        QuotStk->Received := nreceived
        UNLOCK
        nl += 2
        @ nl, 10 SAY "Module"
        @ nl, 28 SAY "Outstand"
        @ nl, 40 SAY "Allocated"
        nl += 2
        malloc := QuotStk->Required - QuotStk->Received
        @ nl, 10 SAY QuotStk->Modcode
        @ nl, 25 SAY QuotStk->Required - QuotStk->Received PICTURE "9,999.999"
        @ nl, 37 GET malloc PICTURE "99999.999"
        READ
        IF LastKey() = 27
            RETURN NIL
        ENDIF
        DO WHILE ( QuotStk->Required - QuotStk->Received < malloc ) .OR. ;
                ( malloc > Part->Instock )
            IF malloc > Part->InStock
                @ nl, 50 SAY "Not that many in Stock" COLOR "BG+"
                mcancell := ApGetY( "Try Again ?" )
                IF mcancell = "N"
                    JCReqRec()                 // Above
                ENDIF
                @ nl, 37 GET malloc PICTURE "99999.999"
                READ
                IF LastKey() = 27
                    RETURN NIL
                ENDIF
            ELSE
                @ nl, 50 SAY "Too many Allocatted"
                Inkey()

                JCReqRec()                 // Above

            ENDIF                    // malloc
        ENDDO
        mcont := ApGetY( Trim( Message->Correct ) + " Allocated" )
        IF mcont = "Y"
            SELECT QuotStk
            ApRlock( 3 )
            QuotStk->Received += malloc
            UNLOCK
            SELECT Part
            ApRlock( 3 )
            Part->Instock -= malloc
            UNLOCK
            IF malloc > 0
                SELECT Labour
                ApFLock( 3 )
                APPEND BLANK
                Labour->Partnum := QuotStk->Partnum
                Labour->Invno   := QuotStk->Invno
                Labour->Time    := malloc
                Labour->Rate    := Part->Trade
                Labour->Desc    := Part->Desc
                Labour->Date    := Date()
                Labour->Codeno  := "  STOCK"
                UNLOCK
            ENDIF                // malloc
        ENDIF                   // mcontinue
        mcontinue := "Y"
    ENDDO                       // mcontinue

    RETURN NIL
// ***----- END JCReqRec()

// ***--------------------------------------------------------------------------

FUNCTION JCStat()                // Outstanding

    Scroll()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        // **      mcorrect := "N"
        // **      DO WHILE mcorrect == "N"
        Scroll(  10, 0, 24, 80 )
        DispBox( 10, 1, 22, 79, 2 )
        @ 14, 10      SAY "Invno"    GET mInvno  PICTURE "@!"
        @ 14, Col() + 2 SAY "Blank to View JC- Work Orders  J Only"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        SELECT Debit
        SET ORDER TO 2                 // Invno
        SEEK mInvno
        SET ORDER TO 1
        IF Found()
            minvno := Debit->Invno
            cDesc  := Debit->Est
        ENDIF
        IF !Found() .OR. minvno = Space( 6 )
            SELECT Debit
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
                        + " " + Str( Debit->Amount, 9, 2 ) + " " + Debit->Saleno;
                        + " " + Debit->Est + "                        " + Str( RecNo(), 6 ) )
                    SKIP ALIAS Debit
                ENDDO
                IF !Empty( aPart_ )
                    Scroll(   3, 0, 24, 80 )
                    DispBox(  3, 1, 24, 79, 2 )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum   := AChoice(  4, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ], 6 ) )
                    GOTO nrecno
                    minvno := Debit->Invno
                    cDesc  := Debit->Est
                ENDIF                     // Empty
            ENDIF                        // LastRec
        ENDIF                   // Invno SPACE()

        SELECT QuotStk
        SET ORDER TO 1                    // Invno
        GOTO TOP
        aPart_ := anum := {}
        nrecno := 0
        minvno := Space( 6 )
        DO WHILE QuotStk->( !Eof() )
            IF QuotStk->Required <= 0
                SKIP ALIAS QuotStk
                LOOP
            ENDIF
            IF QuotStk->Invno != minvno
                SKIP ALIAS QuotStk
                LOOP
            ENDIF
            SELECT Part
            SEEK QuotStk->Partnum
            SELECT QuotStk
            IF Part->Boughtout != "Y"
                SKIP ALIAS QuotStk
                LOOP
            ENDIF
            IF SubStr( QuotStk->Partnum, 1, 1 ) = "Z"
                SKIP ALIAS QuotStk
                LOOP
            ENDIF
            SELECT Debit
            SET ORDER TO 2                             // Invno
            SEEK QuotStk->Invno
            SELECT Name
            SEEK Debit->Codeno
            SELECT QuotStk
            AAdd( aPart_, QuotStk->Invno;
                + "  " + Debit->Codeno;
                + "  " + Debit->Est;
                + "   " + Name->Name;
                + "         " + Str( RecNo(), 6 ) )
            minvno := QuotStk->Invno
            SKIP ALIAS QuotStk
        ENDDO                        // QuotStk EOF
        SELECT Debit
        SET ORDER TO 1                               // Codeno
        SELECT QuotStk
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            DispBox( 0, 0, 24, 79, 2 )
            @ 0, 4 SAY " Job Card # "
            anum := AChoice(  1, 3, 23, 78, aPart_,, "AFUNC" )
            IF LastKey() = 27
                RETURN NIL
            ENDIF
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
            GOTO nrecno
            minvno := QuotStk->Invno
        ENDIF                        // Empty
        manother := "Y"
        DO WHILE manother = "Y"
            mpartnum := Space( 20 )
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @  1, 3 SAY "Job Card # " + minvno COLOR "BG+"
            @  1, 24 SAY "Required   Allocated       Out/S      Instock"
            SELECT QuotStk
            SET ORDER TO 1                             // Invno
            GOTO TOP
            SEEK minvno
            aPart_ := anum := {}
            nrecno := 0
            DO WHILE QuotStk->Invno = minvno .AND. QuotStk->( !Eof() )
                IF SubStr( QuotStk->Partnum, 1, 1 ) = "Z"
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF
                // **      IF QuotStk->Received >= QuotStk->Required
                // **         SKIP ALIAS QuotStk
                // **         LOOP
                // **      ENDIF
                SELECT Part
                SET ORDER TO 1                        // Partnum
                SEEK QuotStk->Partnum
                SELECT QuotStk
                IF Part->BoughtOut = "N"
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF
                AAdd( aPart_, SubStr( QuotStk->Partnum, 1,16 );
                    + " " + Str( QuotStk->Required, 12, 3 );
                    + " " + Str( QuotStk->Received, 12, 3 );
                    + " " + Str( ( QuotStk->Required - QuotStk->Received ), 12, 3 );
                    + " " + Str( Part->Instock, 12, 3 );
                    + " " + QuotStk->ModCode;
                    + "            " + Str( RecNo(), 6 ) )
                SKIP ALIAS QuotStk
            ENDDO                        // QuotStk EOF
            // ****                   +" "+Part->Codeno;
            SELECT QuotStk
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                DispBox( 3, 0, 24, 79, 2 )
                anum := AChoice(  4, 2, 23, 78, aPart_,, "AFUNC" )
                IF LastKey() = 27
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ], 6 ) )
                GOTO nrecno
                mpartnum := QuotStk->Partnum
            ENDIF                        // Empty

            Scroll(  17, 0, 24, 80 )
            DispBox( 17, 0, 24, 79, 2 )
            @ 17, 5      SAY " - Allocate Parts to JC- " COLOR "G+"
            @ 17, 50      SAY " - Allocate Parts to JC- " COLOR "G+"
            @ 19, 3      SAY QuotStk->Partnum COLOR "G+"
            @ 19, Col() + 2 SAY QuotStk->Required - QuotStk->Received PICTURE "9,999.999" COLOR "G+"
            @ 19, Col() + 2 SAY "Required Less Allocated" COLOR "BG+"
            @ 19, Col() + 1 SAY QuotStk->ModCode
            nselect := 1
            DispBox( 21, 0, 24, 79, 2 )
            @ 22, 5      PROMPT "Allocate Part"
            @ 22, Col() + 2 PROMPT "Another Part"
            @ 22, Col() + 2 PROMPT "Print List"
            @ 22, Col() + 2 PROMPT "Auto Allocated"
            // **    @ 22,COL()+2 PROMPT "Delete Records"
            @ 22, Col() + 2 PROMPT "Another Job"
            MENU TO nselect
            DO CASE
            CASE PressedEsc()
                RETURN NIL
            CASE nselect == 1
                Scroll(  12, 0, 24, 80 )
                DispBox( 12, 0, 24, 79, 2 )
                nl := 12
                @ nl, 3      SAY QuotStk->Partnum COLOR "G+"
                @ nl, Col() + 2 SAY QuotStk->Required - QuotStk->Received PICTURE "9,999.999" COLOR "G+"
                @ nl, Col() + 2 SAY "Required Less Allocated" COLOR "BG+"
                @ nl, Col() + 1 SAY QuotStk->ModCode
                nl += 2
                SELECT Part
                SET ORDER TO 1                           // Partnum
                SEEK QuotStk->Partnum
                IF !Found()
                    @ nl, 30 SAY "No Part In Parts File !!!!!!!"
                ENDIF
                @ nl, 6      SAY Trim( Part->Partnum )
                @ nl, Col() + 2 SAY Trim( Part->Desc ) COLOR "G+"
                nl++
                ninstock := Part->Instock
                @ nl, 6      SAY "Instock ="
                @ nl, Col() + 1 GET ninstock         PICTURE "99999.999"
                @ nl, Col() + 1 SAY "Required"
                @ nl, Col() + 1 SAY QuotStk->Required PICTURE "9999.999"
                @ nl, Col() + 1 SAY "Allocated"
                @ nl, Col() + 1 SAY QuotStk->Received PICTURE "9999.999"
                READ
                nl += 2
                ApRlock( 3 )
                Part->Instock := instock
                UNLOCK
                IF LastKey() = 27
                    RETURN NIL
                ENDIF
                SELECT QuotStk
                @ nl, 10 SAY "Module"
                @ nl, 28 SAY "Outstand"
                @ nl, 40 SAY "Allocated"
                nl += 2
                malloc := QuotStk->Required - QuotStk->Received
                @ nl, 10 SAY QuotStk->Modcode
                @ nl, 25 SAY QuotStk->Required - QuotStk->Received PICTURE "9,999.999"
                @ nl, 37 GET malloc PICTURE "99999.999"
                READ
                IF LastKey() = 27
                    RETURN NIL
                ENDIF
                DO WHILE ( QuotStk->Required - QuotStk->Received < malloc ) .OR. ;
                        ( malloc > Part->Instock )
                    IF malloc > Part->InStock
                        @ nl, 50 SAY "Not that many in Stock" COLOR "BG+"
                        mcancell := ApGetY( "Try Again ?" )
                        IF mcancell = "N"
                            LOOP
                            // *** JCStat()                 // Above
                        ENDIF
                        @ nl, 37 GET malloc PICTURE "99999.999"
                        READ
                        IF LastKey() = 27
                            RETURN NIL
                        ENDIF
                    ELSE
                        @ nl, 50 SAY "Too many Allocatted"
                        Inkey()
                        EXIT
                        // ***           JCStat()                 // Above
                    ENDIF                    // malloc
                ENDDO
                mcontinue := ApGetY( Trim( Message->Correct ) + " Allocated" )
                IF mcontinue = "Y"
                    SELECT QuotStk
                    ApRlock( 3 )
                    QuotStk->Received += malloc
                    UNLOCK
                    SELECT Part
                    ApRlock( 3 )
                    Part->Instock -= malloc
                    UNLOCK
                    IF malloc > 0
                        SELECT Labour
                        ApFLock( 3 )
                        APPEND BLANK
                        Labour->Partnum := QuotStk->Partnum
                        Labour->Invno   := QuotStk->Invno
                        Labour->Time    := QuotStk->Required
                        Labour->Rate    := Part->Trade
                        Labour->Desc    := Part->Desc
                        Labour->Date    := Date()
                        Labour->Codeno  := "  STOCK"
                        UNLOCK
                    ENDIF                        // Alloc
                ENDIF
                SELECT QuotStk
                Scroll( nl, 50, nl, 76 )
                DispBox(  3, 0, 24, 79, 2 )
                nreceived := QuotStk->Received
                @ nl, 50 SAY "Check Allocated" GET nreceived PICTURE "9999.999"
                READ
                ApRlock( 3 )
                QuotStk->Received := nreceived
                UNLOCK
                manother := "Y"
            CASE nselect == 2
                manother := "Y"
            CASE nselect == 3
                JobPrintP( minvno )               // Above
                manother := "Y"
            CASE nselect == 4
                JobAutoP( minvno )               // Above
                manother := "Y"
            CASE nselect == 5
                manother := "N"
                LOOP
            ENDCASE
        ENDDO                // manother
        mcontinue := "Y"
    ENDDO                       // mcontinue

    RETURN NIL
// ***----- END JCStat()

// ***--------------------------------------------------------------------------

FUNCTION JCStatLab()                // Outstanding

    Scroll()

    // *** QuotUpDate()                      // XLF_QU7

    // ** mcontinue := "Y"
    // ** DO WHILE mcontinue = "Y"
    Scroll()
    aPart_ := anum := {}
    nrecno := 0
    minvno := Space( 6 )
    SELECT Debit
    SET ORDER TO 2                             // Invno
    GOTO TOP
    DO WHILE Debit->( !Eof() )
        IF Debit->Stat != "J"
            SKIP ALIAS Debit
            LOOP
        ENDIF
        IF SubStr( Debit->Invno, 1, 4 ) = "    "
            SKIP ALIAS Debit
            LOOP
        ENDIF
        SELECT Name
        SEEK Debit->Codeno
        SELECT Debit
        AAdd( aPart_, Debit->Invno;
            + "  " + Debit->Codeno;
            + "  " + Debit->Est;
            + "   " + Name->Name;
            + "       " + Str( RecNo(), 6 ) )
        SKIP ALIAS Debit
    ENDDO                        // Debit EOF
    SELECT Debit
    SET ORDER TO 1                               // Codeno
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        DispBox( 0, 1, 24, 79, 2 )
        @ 0, 4 SAY " Job Card # "
        anum := AChoice(  1, 3, 23, 78, aPart_,, "AFUNC" )
        IF LastKey() = 27
            RETURN NIL
        ENDIF
        nrecno := Val( Right( aPart_[ anum ], 6 ) )
        GOTO nrecno
        minvno := Debit->Invno
    ENDIF                        // Empty
    SELECT Quot
    SET ORDER TO 3                  // Invno+Partnum
    SEEK minvno
    mpartnum := Quot->Partnum

    mwhere := "S"

    Printsel()

    IF mwhere = "P"
        npl := 56
    ELSE
        npl := 22
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    nl := 1
    SELECT Quot
    GOTO TOP
    SET ORDER TO 3                  // Invno+Partnum
    SEEK minvno
    mtemppart := Quot->Partnum
    DO WHILE Quot->Invno = minvno .AND. Quot->( !Eof() )
        nl += 2
        @ nl, 2 SAY Quot->Invno + "  " + Quot->Partnum
        nl++
        IF Quot->Partnum != mtemppart
            mtemppart := Quot->Partnum
        ENDIF
        nlabpart := 0
        nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
        nqty1 := nqty2 := nqty3 := nqty4 := 0
        nEquCost := 0
        SELECT Equ
        GOTO TOP
        SET EXACT ON
        mmod1 := SubStr( Quot->Partnum, 1, 16 )
        SEEK mmod1
        IF Found()
            DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        Inkey( 0 )
                        Scroll()
                    ENDIF
                    nl := 0
                ENDIF
                SELECT Part
                SEEK Equ->Partnum
                nqty1 := Equ->PartQty
                @ nl, 0 SAY "."
                @ nl, 5 SAY SubStr( Equ->Partnum, 1, 16 );
                    + " " + SubStr( Part->Desc, 1, 35 )
                @ nl, 58 SAY Equ->PartQty PICTURE "9999.999"
                nEquCost += Equ->PartQty * Part->Trade
                nl++
                mmod2 := Trim( Equ->Partnum )
                SELECT Labour
                SET ORDER TO 2                   // Invno+Partnum
                SEEK minvno + Equ->Partnum
                ntime := 0
                DO WHILE Labour->Invno + Labour->Partnum = minvno + Equ->Partnum;
                        .AND. Labour->( !Eof() )
                    nTime += Labour->Time
                    @ nl, 0 SAY Labour->Invno
                    @ nl, 8 SAY Labour->Codeno
                    @ nl, 18 SAY SubStr( Labour->Partnum, 1, 16 )
                    @ nl, 46 SAY Labour->Time PICTURE "9999.999"
                    @ nl, 55 SAY ntime PICTURE "9999.999"
                    @ nl, 64 SAY nQty1 PICTURE "9999.999"
                    IF nTime > nQty1
                        @ nl, 73 SAY "*"
                    ENDIF
                    nl++
                    SKIP ALIAS Labour
                ENDDO                            // Labour

                SELECT Equ
                nrecno2 := RecNo()
                GOTO TOP
                SEEK mmod2
                IF Found()
                    DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                        nqty2 := Equ->PartQty
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
                        SELECT Part
                        SEEK Equ->Partnum
                        @ nl, 0 SAY ".."
                        @ nl, 5 SAY SubStr( Equ->Partnum, 1, 16 );
                            + " " + SubStr( Part->Desc, 1, 35 )
                        @ nl, 58 SAY Equ->PartQty PICTURE "9999.999"
                        nl++
                        SELECT Equ
                        mmod3 := Trim( Equ->Partnum )
                        nrecno3 := RecNo()
                        SELECT Labour
                        SET ORDER TO 2                   // Invno+Partnum
                        SEEK minvno + Equ->Partnum
                        ntime := 0
                        DO WHILE Labour->Invno + Labour->Partnum = minvno + Equ->Partnum;
                                .AND. Labour->( !Eof() )
                            nTime += Labour->Time
                            @ nl, 0 SAY Labour->Invno
                            @ nl, 8 SAY Labour->Codeno
                            @ nl, 18 SAY SubStr( Labour->Partnum, 1, 16 )
                            @ nl, 46 SAY Labour->Time PICTURE "9999.999"
                            @ nl, 55 SAY ntime        PICTURE "9999.999"
                            @ nl, 64 SAY nQty2        PICTURE "9999.999"
                            IF nTime > nQty2
                                @ nl, 73 SAY "*"
                            ENDIF
                            nl++
                            SKIP ALIAS Labour
                        ENDDO                            // Labour
                        SELECT Equ
                        GOTO TOP
                        SEEK mmod3
                        IF Found()
                            DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                nqty3 := Equ->PartQty
                                nequ3 := ( nqty1 * nqty2 * nqty3 )
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
                                SELECT Part
                                SEEK Equ->Partnum
                                @ nl, 0 SAY "..."
                                @ nl, 5 SAY SubStr( Equ->Partnum, 1, 16 );
                                    + " " + SubStr( Part->Desc, 1, 35 )
                                @ nl, 58 SAY Equ->PartQty PICTURE "9999.999"
                                nl++
                                SELECT Equ
                                mmod4   := Trim( Equ->Partnum )
                                nrecno4 := RecNo()
                                SELECT Labour
                                SET ORDER TO 2                   // Invno+Partnum
                                SEEK minvno + Equ->Partnum
                                ntime := 0
                                DO WHILE Labour->Invno + Labour->Partnum = minvno + Equ->Partnum;
                                        .AND. Labour->( !Eof() )
                                    nTime += Labour->Time
                                    @ nl, 0 SAY Labour->Invno
                                    @ nl, 8 SAY Labour->Codeno
                                    @ nl, 18 SAY SubStr( Labour->Partnum, 1, 16 )
                                    @ nl, 46 SAY Labour->Time PICTURE "9999.999"
                                    @ nl, 55 SAY ntime        PICTURE "9999.999"
                                    @ nl, 64 SAY nQty3        PICTURE "9999.999"
                                    IF nTime > nQty3
                                        @ nl, 73 SAY "*"
                                    ENDIF
                                    nl++
                                    SKIP ALIAS Labour
                                ENDDO                            // Labour
                                SELECT Equ
                                GOTO TOP
                                SEEK mmod4
                                IF Found()
                                    DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                        nqty4 := Equ->PartQty
                                        nequ4 := nqty1 * nqty2 * nqty3 * nqty4
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
                                        SELECT Part
                                        SEEK Equ->Partnum
                                        @ nl, 0 SAY "...."
                                        @ nl, 5 SAY SubStr( Equ->Partnum, 1, 16 );
                                            + " " + SubStr( Part->Desc, 1, 35 )
                                        @ nl, 58 SAY Equ->PartQty PICTURE "9999.999"
                                        nl++
                                        SELECT Labour
                                        SET ORDER TO 2                   // Invno+Partnum
                                        SEEK minvno + Equ->Partnum
                                        ntime := 0
                                        DO WHILE Labour->Invno + Labour->Partnum = minvno + Equ->Partnum;
                                                .AND. Labour->( !Eof() )
                                            nTime += Labour->Time
                                            @ nl, 0 SAY Labour->Invno
                                            @ nl, 8 SAY Labour->Codeno
                                            @ nl, 18 SAY SubStr( Labour->Partnum, 1, 16 )
                                            @ nl, 46 SAY Labour->Time PICTURE "9999.999"
                                            @ nl, 55 SAY ntime        PICTURE "9999.999"
                                            @ nl, 64 SAY nQty4        PICTURE "9999.999"
                                            IF nTime > nQty4
                                                @ nl, 73 SAY "*"
                                            ENDIF
                                            nl++
                                            SKIP ALIAS Labour
                                        ENDDO                            // Labour
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
            nl++
            @ nl, 0 SAY "Module Cost"
            @ nl, 14 SAY nEquCost PICTURE "$999,999.99"
            nl++
        ENDIF                          // Found mmod1
        SET EXACT OFF
        SELECT Quot
        SKIP ALIAS Quot
    ENDDO
    SELECT Quot
    SET ORDER TO 1

    IF mwhere = "S"
        WAIT
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ELSE
        EndPrint()
    ENDIF

    RETURN NIL
// ***----- END JCStatLab()

// ***--------------------------------------------------------------------------

STATIC FUNCTION JobPrintP( minvno )

    mwhere := "S"

    Printsel()

    IF mwhere = "P"
        npl := 56
    ELSE
        npl := 22
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  1, 3 SAY minvno
    @  1, 20 SAY "PARTS ALLOCATED FROM STOCK"
    @  2, 0 SAY "Part #"
    @  2, 12 SAY "Description"
    @  2, 42 SAY "Required"
    @  2, 52 SAY "Allocated"
    @  2, 62 SAY "Out/St"
    @  2, 71 SAY "In Stock"
    nl := 4
    nreq := malloc := 0
    SELECT Status
    SET ORDER TO 1              // Invno
    GOTO TOP
    SEEK minvno
    DO WHILE Status->Invno = minvno .AND. Status->( !Eof() )
        IF SubStr( Status->Partnum, 1, 2 ) = "ZZ"
            SKIP ALIAS Status
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere = "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            @  0, 0 SAY Control->U_Name
            @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  1, 3 SAY minvno
            @  1, 20 SAY "PARTS ALLOCATED FROM STOCK"
            @  2, 0 SAY "Part #"
            @  2, 12 SAY "Description"
            @  2, 42 SAY "Required"
            @  2, 52 SAY "Allocated"
            @  2, 62 SAY "Out/St"
            @  2, 71 SAY "In Stock"
            nl := 4
        ENDIF
        SELECT Part
        SEEK Status->Partnum
        SELECT Status
        @ nl, 0 SAY SubStr( Status->Partnum, 1, 10 )
        @ nl, 12 SAY SubStr( Part->Desc, 1, 28 )
        @ nl, 42 SAY Status->Required PICTURE "9999.999"
        @ nl, 52 SAY Status->Received PICTURE "9999.999"
        IF Status->Received < Status->Required
            @ nl, 61 SAY Status->Required - Status->Received PICTURE "9999.999"
        ENDIF
        @ nl, 70 SAY Part->Instock PICTURE "9999.999"
        // **   @ nl,70 SAY SUBSTR( Status->Modcode, 1, 9 )
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

    RETURN NIL
// ***------  END JobPrintP()

// ****---------------------------------------------------------------------

STATIC FUNCTION JobAutoP( minvno )

    mwhere := "S"

    Printsel()

    IF mwhere = "P"
        npl := 56
    ELSE
        npl := 22
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  1, 3 SAY minvno
    @  1, 20 SAY "PARTS AUTOMATICALY ALLOCATED FROM STOCK"
    @  2, 0 SAY "Part #"
    @  2, 12 SAY "Description"
    @  2, 46 SAY "Out/St"
    @  2, 57 SAY "Instock"
    @  2, 71 SAY "Issued"
    // **@  2,71 SAY "Module"
    nl := 4
    nreq := malloc := 0
    SELECT Status
    SET ORDER TO 1              // Invno
    GOTO TOP
    SEEK minvno
    DO WHILE Status->Invno = minvno .AND. Status->( !Eof() )
        nreq := Status->Required - Status->Received
        IF Status->Required - Status->Received = 0
            SKIP ALIAS Status
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere = "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            @  0, 0 SAY Control->U_Name
            @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  1, 3 SAY minvno
            @  1, 20 SAY "PARTS AUTOMATICALY ALLOCATED FROM STOCK"
            @  2, 0 SAY "Part #"
            @  2, 12 SAY "Description"
            @  2, 46 SAY "Outstanding"
            @  2, 57 SAY "Instock"
            @  2, 71 SAY "Issued"
            // **            @  2,71 SAY "Module"
            nl := 4
        ENDIF
        SELECT Part
        SEEK Status->Partnum
        IF Part->Instock > 0
            @ nl, 0 SAY SubStr( Status->Partnum, 1, 10 )
            @ nl, 12 SAY SubStr( Part->Desc, 1, 30 )
            @ nl, 43 SAY Status->Required - Status->Received PICTURE "9,999.999"
            @ nl, 55 SAY Part->Instock PICTURE "9,999.999"
            SELECT Status
            IF Part->Instock > nreq
                malloc := nreq
            ELSE
                malloc := Part->Instock
            ENDIF
            ApRlock( 3 )
            Status->Received += malloc
            UNLOCK
            SELECT Part
            ApRlock( 3 )
            Part->Instock -= malloc
            UNLOCK
            IF malloc > 0
                SELECT Labour
                SET ORDER TO 2                 // Invno+Partnum
                GOTO TOP
                SEEK minvno + Status->Partnum
                IF !Found()
                    ApFLock( 3 )
                    APPEND BLANK
                    Labour->Partnum := Status->Partnum
                    Labour->Invno   := Status->Invno
                    Labour->Time    := malloc
                    Labour->Rate    := Part->Trade
                    Labour->Desc    := Part->Desc
                    Labour->Date    := Date()
                    Labour->Codeno  := "  STOCK"
                    UNLOCK
                ENDIF                  // !Found
            ENDIF
            @ nl, 68 SAY malloc PICTURE "9,999.999"
            // **      @ nl,70 SAY SUBSTR( Status->Modcode, 1, 9 )
            nl++
        ENDIF                // Part Instock
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
    SELECT Labour
    SET ORDER TO 1
    SELECT Debit
    SET ORDER TO 1

    RETURN NIL
// ***------  END JobAutoP()

// ****---------------------------------------------------------------------

FUNCTION JobAllPa()                // Manual Issue

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        mpartnum := Space( 20 )
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 6 SAY "Job Card #"
        @  1, 20 SAY "ONLY Outstanding Displayed "
        @  1, 58 SAY "Outstanding  Instock"
        SELECT Status
        SET ORDER TO 2                             // Partnum
        GOTO TOP
        aPart_ := {}
        nrecno := 0
        DO WHILE Status->( !Eof() )
            IF Status->Required - Status->Received <= 0
                SKIP ALIAS Status
                LOOP
            ENDIF
            IF SubStr( Status->Partnum, 1, 2 ) = "ZZ"
                SKIP ALIAS Status
                LOOP
            ENDIF
            SELECT Part
            SEEK Status->Partnum
            SELECT Status
            AAdd( aPart_, Status->Invno + " " + Status->Modcode;
                + " " + SubStr( Status->Partnum, 1, 16 );
                + " " + SubStr( Part->Desc, 1, 16 );
                + " " + Str( ( Status->Required - Status->Received ), 9, 3 );
                + " " + Str( Part->Instock, 9, 3 );
                + "      " + Str( RecNo(), 6 ) )
            SKIP ALIAS Status
        ENDDO                        // Status EOF
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            DispBox( 3, 0, 24, 79, 2 )
            anum := AChoice(  4, 1, 23, 78, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
            GOTO nrecno
            mpartnum := Status->Partnum
        ENDIF                        // Empty
        SELECT Part
        SET ORDER TO 1                           // Partnum
        SEEK mpartnum
        Scroll(  11, 2, 23, 78 )
        DispBox( 11, 3, 19, 77, 2 )
        nl := 11
        @ nl, 23    SAY " Required Less Allocated" COLOR "G+"
        @ nl, Col() SAY Status->Required - Status->Received PICTURE "99,999.999 " COLOR "G+"
        nl++
        @ nl, 6      SAY Trim( Part->Partnum )
        @ nl, Col() + 2 SAY Trim( Part->Desc )
        nl++
        ninstock := Part->Instock
        @ nl, 6      SAY "Instock ="
        @ nl, Col() + 1 GET ninstock         PICTURE "99999.999"
        @ nl, Col() + 1 SAY "Required"
        @ nl, Col() + 1 SAY Status->Required PICTURE "9999.999"
        @ nl, Col() + 1 SAY "Allocated"
        @ nl, Col() + 1 SAY Status->Received PICTURE "9999.999"
        READ
        ApRlock( 3 )
        Part->Instock := ninstock
        UNLOCK
        nl += 2
        @ nl, 10 SAY "Module"
        @ nl, 28 SAY "Outstand"
        @ nl, 40 SAY "Allocated"
        nl += 2
        malloc := Status->Required - Status->Received
        @ nl, 10 SAY Status->Modcode
        @ nl, 25 SAY Status->Required - Status->Received PICTURE "9,999.999"
        @ nl, 37 GET malloc PICTURE "99999.999"
        READ
        IF LastKey() = 27
            RETURN NIL
        ENDIF
        DO WHILE ( Status->Required - Status->Received < malloc ) .OR. ;
                ( malloc > Part->Instock )
            IF malloc > Part->InStock
                @ nl, 50 SAY "Not that many in Stock" COLOR "BG+"
                mcancell := ApGetY( "Try Again ?" )
                IF mcancell = "N"
                    JobAllPa()                 // Above
                ENDIF
                @ nl, 37 GET malloc PICTURE "99999.999"
                READ
                IF LastKey() = 27
                    RETURN NIL
                ENDIF
            ELSE
                @ nl, 50 SAY "Too many Allocatted"
                Inkey()
                JobAllPa()                 // Above
            ENDIF                    // malloc
        ENDDO
        mcontinue := ApGetY( Trim( Message->Correct ) + " Allocatted" )
        IF mcontinue = "Y"
            SELECT Status
            ApRlock( 3 )
            Status->Received += malloc
            UNLOCK
            SELECT Part
            ApRlock( 3 )
            Part->Instock -= malloc
            UNLOCK
            IF malloc > 0
                SELECT Debit
                SET ORDER TO 2             // Invno
                SEEK Status->Invno
                SELECT Labour
                SET ORDER TO 2
                GOTO TOP
                SEEK Status->Invno + Debit->Codeno + Status->Partnum
                IF !Found()
                    ApFLock( 3 )
                    APPEND BLANK
                    Labour->Partnum := Status->Partnum
                    Labour->Invno   := Status->Invno
                    Labour->Time    := Status->Required
                    Labour->Rate    := Part->Trade
                    Labour->Desc    := Part->Desc
                    Labour->Date    := Date()
                    Labour->Codeno  := "  STOCK"
                    UNLOCK
                ENDIF
                SET ORDER TO 1
                SELECT Debit
                SET ORDER TO 1
            ENDIF
        ENDIF
        mcontinue := "Y"
    ENDDO                       // mcontinue

    RETURN NIL
// ***----- END JobAllPa()

// ********----------  END OF FILE XLF_QU6.PRG
