// ** JK 22-03-11 19:02:14

/*
   Program.....:                 XF_PLIST.PRG

   Author......: J.Kirby
   Date........: 24/06/85
   Functions...: LocDesc, CatLoc, LocStk, LocPart, AllOrders
                 PartLoc, Mu_PartList, PartRUtd
   Static funcs: PaDescLoc, PartSect, SuppList, PartTrade
                 PartList, CatGroup
*/

FUNCTION LocDesc()

    mok := "Y"
    DO WHILE mok == "Y"
        Scroll()
        nl := 0
        nqty := 0
        mselect := "XX  "  // SPACE( 4 )
        DispBox(  0, 1, 20, 79, 2 )
        @  2, 10 SAY "Listing of Part Location Description"
        @  6, 8 SAY "Location :" GET mselect PICTURE "@!"
        @  6, Col() + 2 SAY "Blank for Look up XX for All"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        IF mselect = "XX  "
            mwhere := "S"
            npl    := 54

            Printsel()                                  // _LF_Init

            IF mwhere == "P"
                npl := 56
            ELSE
                Scroll()
                npl := 22
            ENDIF
            SELECT Part
            SET ORDER TO 4                   // Locate
            GOTO TOP
            @  0, 8 SAY Control->U_Name
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  3, 10 SAY "Location"
            @  3, 28 SAY "Description"
            nl := 4
            nqty := 0
            clocate := Space( 16 )
            DO WHILE Part->( !Eof() )
                IF Part->Locate = Space( 16 )
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF Part->Locate = clocate
                    nqty += 1
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF nl > npl
                    IF mwhere == "P"
                        EJECT
                        @  0, 8 SAY Control->U_Name
                        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                        @  3, 10 SAY "Location"
                        @  3, 28 SAY "Description"
                        nl := 4
                    ELSE
                        WAIT
                        nl := 0
                        Scroll()
                    ENDIF
                ENDIF
                @ nl, 0 SAY nqty + 1 PICTURE "999,999"  // important here
                nqty := 0
                nl++
                @ nl, 10 SAY Part->Locate
                @ nl, 28 SAY Part->LocDesc
                @ nl, 60 SAY "________"
                clocate := Part->Locate
                SKIP ALIAS Part
            ENDDO
            nl++
            IF mwhere != "P"
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ELSE
                EndPrint()
                SET MARGIN TO 0
            ENDIF
            RETURN NIL
        ENDIF     // XX
        IF mselect = Space( 4 )
            SAVE SCREEN TO tempscr
            SELECT Part
            SET ORDER TO 4                // Locate
            GOTO TOP
            Scroll()
            aPart_ := {}
            nrecno  := 0
            clocate := Space( 16 )
            nqty := 0
            DO WHILE Part->( !Eof() )
                IF Part->Locate = clocate
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF Part->Locate = Space( 16 )
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                AAdd( aPart_, Part->Locate;
                    + " " + Part->LocDesc;
                    + "           " + Str( RecNo(), 6 ) )
                clocate := Part->Locate
                SKIP ALIAS Part
            ENDDO
            DispBox(  0, 0, 24, 52, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice(  1, 3, 23, 50, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                clocate  := Part->Locate
                cLocdesc := Part->Locdesc
                mselect := SubStr( clocate, 1, 4 )
            ENDIF
            RESTORE SCREEN FROM tempscr
        ENDIF                          // mselect
        Scroll()
        IF PressedEsc()
            RETURN NIL
        ENDIF
        DispBox(  1, 0, 24, 79, 2 )
        @ 1, 2 SAY " -- WAIT TAKES TIME -- "
        SELECT Part
        SET ORDER TO 4                // Locate
        GOTO TOP
        aPart_ := {}
        nrecno := 0
        clocate := Space( 16 )
        DO WHILE Part->( !Eof() )
            IF Part->Locate = Space( 16 )
                SKIP ALIAS Part
                LOOP
            ENDIF
            IF Part->Locate = clocate
                SKIP ALIAS Part
                LOOP
            ENDIF
            mgroup := "  "
            IF mselect != "    "
                DO CASE
                CASE SubStr( mselect, 2, 3 ) = "   "
                    IF SubStr( Part->Locate, 1, 1 ) != SubStr( mselect, 1, 1 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE SubStr( mselect, 3, 2 ) = "  "
                    IF SubStr( Part->Locate, 1, 2 ) != SubStr( mselect, 1, 2 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE SubStr( mselect, 4, 1 ) = " "
                    IF SubStr( Part->Locate, 1, 3 ) != SubStr( mselect, 1, 3 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE mselect != "    "
                    IF SubStr( Part->Locate, 1, 4 ) != SubStr( mselect, 1, 4 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                ENDCASE

            ENDIF    // mselect = Space 4
            AAdd( aPart_, Part->Locate;
                + " " + Part->LocDesc;
                + "   " + "-------";
                + "   " + "-------";
                + "                " + Str( RecNo(), 6 ) )
            clocate := Part->Locate
            mgroup = SubStr( Part->Locate, 4, 1 )
            SKIP ALIAS Part
        ENDDO

        Scroll()
        DispBox(  1, 0, 24, 79, 2 )
        @ 1, 2 SAY " -- WAIT TAKES TIME -- "
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice(  2, 3, 23, 78, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
        ENDIF
        IF PressedEsc()
            RETURN NIL
        ENDIF

        mwhere := "S"
        npl    := 54

        Printsel()                                  // _LF_Init

        IF mwhere == "P"
            npl := 56
        ELSE
            Scroll()
            npl := 22
        ENDIF
        SELECT Part
        SET ORDER TO 4                   // Locate
        GOTO TOP
        @  0, 8 SAY Control->U_Name
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @  3, 10 SAY "Location"
        @  3, 28 SAY "Description"
        nl := 4
        nQty  := 0
        clocate := Space( 16 )
        DO WHILE Part->( !Eof() )
            IF Part->Locate = Space( 16 )
                SKIP ALIAS Part
                LOOP
            ENDIF
            IF Part->Locate = clocate
                nqty += 1
                SKIP ALIAS Part
                LOOP
            ENDIF
            IF mselect != "    "
                DO CASE
                CASE SubStr( mselect, 2, 3 ) = "   "
                    IF SubStr( Part->Locate, 1, 1 ) != SubStr( mselect, 1, 1 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE SubStr( mselect, 3, 2 ) = "  "
                    IF SubStr( Part->Locate, 1, 2 ) != SubStr( mselect, 1, 2 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE SubStr( mselect, 4, 1 ) = " "
                    IF SubStr( Part->Locate, 1, 3 ) != SubStr( mselect, 1, 3 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE mselect != "    "
                    IF SubStr( Part->Locate, 1, 4 ) != SubStr( mselect, 1, 4 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                ENDCASE

            ENDIF // mselect
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                    @  0, 8 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  3, 10 SAY "Location"
                    @  3, 28 SAY "Description"
                    nl := 4
                ELSE
                    WAIT
                    nl := 0
                    Scroll()
                ENDIF
            ENDIF
            @ nl, 0 SAY nqty + 1 PICTURE "999,999"  // important here
            nqty := 0
            nl++
            @ nl, 10 SAY Part->Locate
            @ nl, 28 SAY Part->LocDesc
            @ nl, 60 SAY "________"
            clocate := Part->Locate
            SKIP ALIAS Part
        ENDDO
        nl++
        IF mwhere != "P"
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
            SET MARGIN TO 0
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO
    SELECT Part
    SET ORDER TO 1

    RETURN NIL

// **** End of File LocDesc()

// ***-------------------------------------------------------------

FUNCTION CatLoc()

    nl  := 0
    mok := "Y"
    DO WHILE mok == "Y"
        ccatno := Space( 12 )
        CatArray()               // Creates array of Catalogue
        SELECT Part
        SET ORDER TO 2                            // Catno + Desc
        SEEK ccatno
        clocate  := Space( 16 )
        clocdesc := Space( 28 )
        SELECT Part
        SET ORDER TO 2                // Catno
        GOTO TOP
        aPart_ := {}
        nrecno  := 0
        SEEK ccatno
        DO WHILE Part->Catno = ccatno .AND. Part->( !Eof() )
            // **             IF Part->Catno != ccatno
            // **                SKIP ALIAS Part
            // **                LOOP
            // **             ENDIF
            IF Part->Locate = clocate
                SKIP ALIAS Part
                LOOP
            ENDIF
            IF Part->Locate = Space( 16 )
                SKIP ALIAS Part
                LOOP
            ENDIF
            AAdd( aPart_, Part->Locate;
                + " " + Part->LocDesc;
                + "           " + Str( RecNo(), 6 ) )
            clocate := Part->Locate
            SKIP ALIAS Part
        ENDDO
        Scroll()
        DispBox(  0, 0, 24, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice(  2, 3, 23, 77, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            clocate  := Part->Locate
            cLocdesc := Part->Locdesc
        ENDIF
        SELECT Part
        Scroll()
        DispBox(  0, 0, 3, 79, 2 )
        @  1, 10 SAY clocate + " " + clocdesc + "  " + "Location"
        aPart_ := {}
        nrecno   := 0
        mpartnum := Space( 16 )
        IF LastRec() != 0
            SET ORDER TO 4      // Location
            GOTO TOP
            SEEK clocate
            DO WHILE Part->Locate = clocate .AND. Part->( !Eof() )
                // **                IF Part->LocDesc = "    "
                // **                   SKIP ALIAS Part
                // **                   LOOP
                // **                ENDIF
                IF Part->Catno != ccatno
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                AAdd( aPart_, Part->Partnum;
                    + " " + Part->Desc;
                    + " " + Part->Locate;
                    + "             " + Str( RecNo(), 6 ) )
                SKIP ALIAS Part
            ENDDO
            DispBox( 3, 0, 24, 79, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 4, 2, 23, 78, aPart_,, "AFUNC" )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                mpartnum := Part->Partnum
            ENDIF                // ! Empty
        ENDIF                           // Found
        SELECT Part
        SET ORDER TO 1                         // Partnum + Desc
        SEEK mpartnum
        mpartnum := Part->Partnum
        IF Found()
            PartDets( @mpartnum )
            LOOP
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
        IF PressedEsc()
            RETURN NIL
        ENDIF
    ENDDO
    SELECT Part
    SET ORDER TO 1

    RETURN mpartnum

// **** End of File CatLoc()

// ***-------------------------------------------------------------

FUNCTION LocStk()

    SELECT Part
    SET ORDER TO 4            // Location + Partnum
    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        DispBox(  0, 1, 14, 79, 2 )
        clocate := Space( 16 )
        mselect := Space( 4 )
        ngreater := 99999.99
        nQty := 0
        @  2, 10 SAY "Listing of Part Location Update"
        @  6, 8 SAY "Instock > " GET nQty PICTURE "9999"
        @  6, Col() + 4 SAY "Skip if greater than" GET ngreater PICTURE "99999.99"
        @  8, 8 SAY "Location :" GET mselect PICTURE "@!"
        @  8, Col() + 2 SAY "Blank for Select"
        READ
        IF mselect != Space( 4 )
            LocSpace()
        ENDIF
        IF PressedEsc()
            RETURN NIL
        ENDIF
        IF mselect = Space( 4 )
            SAVE SCREEN TO tempscr
            SELECT Part
            SET ORDER TO 4                // Locate
            GOTO TOP
            Scroll()
            aPart_ := {}
            nrecno  := 0
            clocate := Space( 16 )
            DO WHILE Part->( !Eof() )
                IF Part->Locate = clocate
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF Part->Locate = Space( 16 )
                    SKIP ALIAS Part
                    LOOP
                ENDIF
            /*
            IF Part->Instock < nqty
               SKIP ALIAS Part
               LOOP
            ENDIF
            */
                AAdd( aPart_, Part->Locate;
                    + " " + Part->LocDesc;
                    + "           " + Str( RecNo(), 6 ) )
                clocate := Part->Locate
                SKIP ALIAS Part
            ENDDO
            DispBox(  0, 0, 24, 52, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice(  1, 3, 23, 50, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                clocate  := Part->Locate
                cLocdesc := Part->Locdesc
                mselect := SubStr( clocate, 1, 4 )
            ENDIF
            RESTORE SCREEN FROM tempscr
        ENDIF                          // Found()
        IF PressedEsc()
            RETURN NIL
        ENDIF
        mok := "Y"
        DO WHILE mok = "Y"
            SELECT Part
            SET ORDER TO 4            // Location + Partnum
            GOTO TOP
            nrecno := 0
            aPart_ := {}
            SEEK SubStr( mselect, 1, 1 )
            DO WHILE SubStr( Part->Locate, 1, 1 ) = SubStr( mselect, 1, 1 );
                    .AND. Part->( !Eof() )
                IF Part->Locate = Space( 16 )
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF Part->Instock < nqty
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF Part->Instock >= ngreater
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                AAdd( aPart_, SubStr( Part->Locate, 1,11 );
                    + " " + SubStr( Part->Partnum, 1, 14 );
                    + " " + SubStr( Part->Desc, 1, 19 );
                    + " " + SubStr( Part->Unit, 1, 6 );
                    + " " + Str( Part->Instock, 9, 3 );
                    + "             " + Str( RecNo(), 6 ) )
                SKIP ALIAS Part
            ENDDO   // Part EOF
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @ 1, 2 SAY " -- WAIT TAKES TIME -- " + mselect + " "
            @ 1, 58 SAY "Instock     Edit"
            DispBox( 3, 1, 23, 79, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 4, 3, 22, 78, aPart_,, "AFUNC" )
                IF LastKey() = 27
                    EXIT
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                clocate := Part->Locate
                GOTO nrecno
            ENDIF
            IF nrecno = 0
                RETURN NIL
            ENDIF
            ninstock := Part->Instock
            medit := "N"
            @ Row(), 66 GET ninstock   PICTURE "99999.999"
            @ Row(), 76 GET medit VALID( medit $ "NY" ) PICTURE "!"
            READ
            SELECT Part
            ApRLock( 3 )
            Part->Instock := ninstock
            UNLOCK
            nminstk   := Part->MinStk
            nmaxstk   := Part->MaxStk
            mdesc     := Part->Desc
            mweight   := Part->Weight
            msuplcode := Part->Codeno
            mpartnum  := Part->Partnum

            // EDIT File
            IF medit = "Y"
                Scroll( 6, 2, 23, 78 )
                clocate  := Part->Locate
                clocDesc := Part->Locdesc
                mlookup  := Part->Locate
                @  8, 8 SAY Part->Catno + "   " + Part->PartId COLOR "RG+"
                @ 10, 8 SAY Part->Locate + "  " + Part->LocDesc COLOR "RG+"
                @ 12, 8 SAY "Location :" GET mlookup PICTURE "@!"
                @ 12, Col() + 2 SAY "Blank for Look up"
                READ
                IF mlookup = Space( 4 )
                    SAVE SCREEN TO tempscr
                    SELECT Part
                    SET ORDER TO 4                // Locate
                    GOTO TOP
                    Scroll()
                    aPart_ := {}
                    nrecno  := 0
                    clocate := Space( 16 )
                    DO WHILE Part->( !Eof() )
                        IF Part->Locate = clocate
                            SKIP ALIAS Part
                            LOOP
                        ENDIF
                        IF Part->Locate = Space( 16 )
                            SKIP ALIAS Part
                            LOOP
                        ENDIF
                        IF Part->Instock < nqty
                            SKIP ALIAS Part
                            LOOP
                        ENDIF
                        AAdd( aPart_, Part->Locate;
                            + " " + Part->LocDesc;
                            + "           " + Str( RecNo(), 6 ) )
                        clocate := Part->Locate
                        SKIP ALIAS Part
                    ENDDO
                    DispBox(  1, 1, 24, 58, 2 )
                    IF !Empty( aPart_ )
                        ASort( aPart_,,, {| x, y | x < y } )
                        anum := AChoice(  2, 3, 23, 56, aPart_,, "AFUNC" )
                        nrecno := Val( Right( aPart_[ anum ],6 ) )
                        GOTO nrecno
                    ENDIF
                    RESTORE SCREEN FROM tempscr
                ENDIF                          // Found()
                clocate  := Part->Locate
                cLocdesc := Part->Locdesc
                Scroll( 11, 4, 20, 76 )
                SELECT Part
                SET ORDER TO 1                 // Partnum
                SEEK mpartnum
                ApRLock( 3 )
                Part->Locate   := clocate
                Part->LocDesc  := clocDesc
                @  12, 8      SAY "Location" GET Part->LOCATE   PICTURE "@!"
                @  12, Col() + 2 SAY "Desc"     GET Part->Locdesc  PICTURE "@X"
                READ
                UNLOCK
                @ 14, 8      GET mdesc
                @ 16, 8      SAY "Minimum"  GET nminstk   PICTURE "99999.99"
                @ 16, Col() + 2 SAY "Optimum"  GET nmaxstk   PICTURE "99999.99"
                @ 16, Col() + 2 SAY "Weight"   GET mweight   PICTURE "9999.99"
                @ 18, 8      SAY "Suppl Codeno " GET msuplcode PICTURE "@K!"
                READ
                SELECT Name
                SEEK msuplcode
                DO WHILE !Found()

                    SAVE SCREEN TO Partscrn
                    Namerank( @mcodeno )                       // XlF_Name
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    SELECT Name
                    SEEK mcodeno
                    RESTORE SCREEN FROM Partscrn
                ENDDO
                SELECT Part
                ApRLock( 3 )
                // **          Part->Instock := ninstock
                Part->MinStk  := nminstk
                Part->MaxStk  := nmaxstk
                Part->Desc    := mdesc
                Part->Weight  := mweight
                Part->Codeno  := Name->Codeno
                UNLOCK
                @ 18, 45 SAY Part->Codeno COLOR "BG+"
                nselect := 1
                DO CASE
                CASE Part->Unit = "Each      "
                    nselect := 1
                CASE Part->Unit = "Mtr       "
                    nselect := 2
                CASE Part->Unit = "Sq Mtr    "
                    nselect := 3
                CASE Part->Unit = "Cu Mtr    "
                    nselect := 4
                ENDCASE
                @ 16, 67 PROMPT "Each  "
                @ 17, 67 PROMPT "Mtr   "
                @ 18, 67 PROMPT "Sq Mtr"
                @ 19, 67 PROMPT "Cu Mtr"
                MENU TO nselect
                ApRLock( 3 )
                DO CASE
                CASE nselect == 1
                    Part->Unit := "Each"
                CASE nselect == 2
                    Part->Unit := "Mtr"
                CASE nselect == 3
                    Part->Unit := "Sq Mtr"
                CASE nselect == 4
                    Part->Unit := "Cu Mtr"
                ENDCASE
                UNLOCK
                DO CASE
                CASE Part->Boughtout = "Y"
                    nselect := 1
                OTHERWISE
                    nselect := 2
                ENDCASE
                @ 19, 20      PROMPT "Part Bought Out"
                @ 19, Col() + 2 PROMPT "Own Manufacture"
                MENU TO nselect
                ApFLock( 3 )
                DO CASE
                CASE nselect == 1
                    Part->Boughtout := "Y"
                CASE nselect == 2
                    Part->Boughtout := "N"
                ENDCASE
                UNLOCK
                nl := 21
                SELECT Part
                ApRLock( 3 )
                IF Part->Markup == 0
                    Part->Markup := Cat->Markup
                ENDIF
                UNLOCK
                ntrade  := Part->Trade
                nmarkup := Part->Markup
                @ nl, 6 SAY Trim( Part->Unit ) + " Cost   " GET ntrade PICTURE "999999.99"
                IF SubStr( Control->U_Name, 1, 5 ) != "CHRIS"
                    @ nl, Col() + 2 SAY "Mkup %"              GET nmarkup PICTURE "9999.99"
                ELSE
                    @ nl, Col() + 2 SAY "Mkup %"
                    @ nl, Col() + 2 SAY nmarkup PICTURE "9999.99"
                ENDIF
                READ
                ApRLock( 3 )
                Part->Trade  := ntrade
                Part->Markup := nmarkup
                nsell := ( Part->Trade * ( 1 + ( Part->Markup / 100 ) ) )
                IF SubStr( Control->U_Name, 1, 5 ) != "CHRIS"
                    Part->Wholesale := ( Part->Trade * ( 1 + ( Part->Markup / 100 ) ) )
                ENDIF
                IF Part->Margin == 0
                    Part->Margin := Part->Markup
                ENDIF
                UNLOCK
                nwholesale := Part->Wholesale
                ntradeDate := Part->Trade
                nl += 2
                @ nl, 6      SAY Trim( Part->Unit ) + " Sell exl GST";
                    GET nwholesale PICTURE "999999.99"
                READ
                ApRLock( 3 )
                Part->Wholesale := nwholesale
                Part->Markup := ( ( Part->Wholesale - Part->Trade ) / Part->Trade ) * 100
                IF Part->Trade != ntradeDate
                    Part->Date := Date()
                ENDIF
                UNLOCK
                mdetails = "N"
                @ nl, 48 SAY "Go to Part Details" GET mdetails PICTURE "!"
                READ
                IF mdetails = "Y"
                    PartDets( mpartnum )
                    LOOP
                ENDIF
                IF PressedEsc()
                    RETURN NIL
                ENDIF
            ENDIF   // medit
            LOOP
        ENDDO   // mok
    ENDDO                    // mcontinue
    COMMIT
    SELECT Part
    SET ORDER TO 1                  // Partnum

    RETURN NIL

// ***  End of LocStk()

// **---------------------------------------------------------------------*

FUNCTION LocPart()

    nl  := 0
    mok := "Y"
    DO WHILE mok == "Y"
        Scroll()
        mselect := Space( 4 )
        DispBox(  0, 1, 14, 79, 2 )
        nQty := 0
        @  2, 10 SAY "Listing of Part by Location"
        @  6, 8 SAY "Instock > " GET nQty PICTURE "999.99"
        @  8, 8 SAY "Location :" GET mselect PICTURE "@!"
        @  8, Col() + 2 SAY "Blank for Look up"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        IF mselect = Space( 4 )
            SAVE SCREEN TO tempscr
            SELECT Part
            SET ORDER TO 4                // Locate
            GOTO TOP
            Scroll()
            aPart_ := {}
            nrecno  := 0
            clocate := Space( 16 )
            DO WHILE Part->( !Eof() )
                IF Part->Locate = clocate
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF Part->Locate = Space( 16 )
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF Part->Instock < nqty
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                AAdd( aPart_, Part->Locate;
                    + " " + Part->LocDesc + " " + Str( Part->Instock, 8, 2 );
                    + "           " + Str( RecNo(), 6 ) )
                clocate := Part->Locate
                SKIP ALIAS Part
            ENDDO
            DispBox(  0, 0, 24, 52, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice(  1, 3, 23, 50, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                clocate  := Part->Locate
                cLocdesc := Part->Locdesc
                mselect := SubStr( clocate, 1, 4 )
            ENDIF
            RESTORE SCREEN FROM tempscr
        ENDIF                          // Found()
        Scroll()
        DispBox(  1, 0, 24, 79, 2 )
        @ 1, 2 SAY " -- WAIT TAKES TIME -- "
        IF mselect != "    "
            SELECT Part
            SET ORDER TO 4                // Locate
            GOTO TOP
            aPart_ := {}
            nrecno  := 0
            clocate := Space( 16 )
            DO WHILE Part->( !Eof() )
                IF Part->Locate = Space( 16 )
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF Part->Instock < nqty
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF Part->LocDesc = Space( 16 )
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                DO CASE
                CASE SubStr( mselect, 2, 3 ) = "   "
                    IF SubStr( Part->Locate, 1, 1 ) != SubStr( mselect, 1, 1 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE SubStr( mselect, 3, 2 ) = "  "
                    IF SubStr( Part->Locate, 1, 2 ) != SubStr( mselect, 1, 2 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE SubStr( mselect, 4, 1 ) = " "
                    IF SubStr( Part->Locate, 1, 3 ) != SubStr( mselect, 1, 3 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE mselect != "    "
                    IF SubStr( Part->Locate, 1, 4 ) != SubStr( mselect, 1, 4 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                ENDCASE
                AAdd( aPart_, SubStr( Part->Locate, 1,11 );
                    + " " + SubStr( Part->Partnum, 1, 15 );
                    + " " + SubStr( Part->Desc, 1, 20 );
                    + " " + SubStr( Part->LocDesc, 1, 14 );
                    + " " + Str( Part->InStock, 8, 2 );
                    + "              " + Str( RecNo(), 6 ) )
                SKIP ALIAS Part
            ENDDO
            Scroll()
            DispBox(  1, 0, 24, 79, 2 )
            @ 1, 2 SAY " -- WAIT TAKES TIME -- "
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice(  2, 3, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
            ENDIF
        ENDIF       // mselect
        IF PressedEsc()
            RETURN NIL
        ENDIF

        mwhere := "S"
        npl    := 54

        Printsel()                                  // _LF_Init

        IF mwhere == "P"
            // **   SET MARGIN TO 1
            npl := 56
        ELSE
            Scroll()
            npl := 22
        ENDIF
        SELECT Part
        SET ORDER TO 4                   // Locate
        GOTO TOP
        @  0, 2 SAY Control->U_Name
        @  0, 40 SAY mselect
        @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @  3, 0 SAY "Location"
        @  3, 18 SAY "Part #"
        @  3, 62 SAY "Stock"
        nl := 4
        // ** nqty := 0
        ntotal := ncattotal := 0
        DO WHILE Part->( !Eof() )
            IF mselect != "    "
                DO CASE
                CASE SubStr( mselect, 2, 3 ) = "   "
                    IF SubStr( Part->Locate, 1, 1 ) != SubStr( mselect, 1, 1 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE SubStr( mselect, 3, 2 ) = "  "
                    IF SubStr( Part->Locate, 1, 2 ) != SubStr( mselect, 1, 2 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE SubStr( mselect, 4, 1 ) = " "
                    IF SubStr( Part->Locate, 1, 3 ) != SubStr( mselect, 1, 3 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE mselect != "    "
                    IF SubStr( Part->Locate, 1, 4 ) != SubStr( mselect, 1, 4 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                ENDCASE
                IF Part->Instock < nqty
                    SKIP ALIAS Part
                    LOOP
                ENDIF
   /*
                DO WHILE Part->Locate = clocate
                   nqty += 1
                   SKIP ALIAS Part
                   LOOP
                ENDDO
   */
                IF Part->Locate = Space( 16 )
                    SKIP ALIAS Part
                    LOOP
                ENDIF
            ENDIF // mselect

            IF nl > npl
                IF mwhere == "P"
                    EJECT
                    @  0, 2 SAY Control->U_Name
                    @  0, 40 SAY mselect
                    @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  3, 0 SAY "Location"
                    @  3, 18 SAY "Part #"
                    @  3, 62 SAY "Stock"
                    nl := 4
                ELSE
                    WAIT
                    nl := 0
                    Scroll()
                ENDIF
            ENDIF
            @ nl, 0 SAY Part->Locate
            @ nl, 18 SAY SubStr( Part->Partnum, 1, 16 )
            @ nl, 36 SAY SubStr( Part->Desc, 1, 25 )
            @ nl, 62 SAY Part->Instock  PICTURE "9,999.99"
            @ nl, 71 SAY "_______"
            ntotal += Part->Instock * Part->Trade
            nl++
            SKIP ALIAS Part
        ENDDO
        nl++
        @ nl, 28 SAY "Locate Qty*Trade Total"
        @ nl, 53 SAY ntotal PICTURE "$9,999,999.99"
        nl++
        IF mwhere != "P"
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
            SET MARGIN TO 0
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO
    SET ORDER TO 1

    RETURN NIL

// **** End of File LocPart()

// ***-------------------------------------------------------------

STATIC FUNCTION PaDescLoc()     //

    nl  := 0
    mok := "Y"
    DO WHILE mok == "Y"
        mcorrect := "Y"
        ntotal := ncattotal := 0
        mallCat := "N"
        IF PressedEsc()
            RETURN NIL
        ENDIF

        mwhere := "S"
        npl    := 56
        Scroll()

        Printsel()                                  // _LF_Init

        IF mwhere == "P"
            npl := 56
        ELSE
            Scroll()
            npl := 22
        ENDIF
        SELECT Part
        SET ORDER TO 2                   // Catno+Locate
        GOTO TOP
        @  0, 8 SAY Control->U_Name
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @  3, 0 SAY "Part #"
        @  3, 17 SAY "Description"
        @  3, 41 SAY "Locate"
        @  3, 54 SAY "Catno"
        @  3, 60 SAY "Min Stk"
        @  3, 69 SAY "In Stock"
        nl := 4
        DO WHILE Part->( !Eof() )
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                ELSE
                    WAIT
                    nl := 0
                    Scroll()
                ENDIF
                @  0, 8 SAY Control->U_Name
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                @  3, 0 SAY "Part #"
                @  3, 17 SAY "Description"
                @  3, 41 SAY "Locate"
                @  3, 54 SAY "Catno"
                @  3, 60 SAY "Min Stk"
                @  3, 69 SAY "In Stock"
                nl := 4
            ENDIF
            IF Part->Instock > 0
                @ nl, 0 SAY SubStr( Part->Partnum, 1, 16 )
                @ nl, 17 SAY SubStr( Part->Desc, 1, 23 )
                @ nl, 41 SAY SubStr( Part->Locate, 1, 12 )
                @ nl, 54 SAY SubStr( Part->Catno, 1, 4 )
                @ nl, 60 SAY Part->MinStk PICTURE "9999.99"
                @ nl, 67 SAY Part->Instock PICTURE "9999.99"
                @ nl, 74 SAY "_____"
                nl++
                ncattotal += Part->Instock * Part->Trade
            ENDIF
            SELECT Part
            SKIP ALIAS Part
        ENDDO
        nl++
        @ nl, 30 SAY ncattotal PICTURE "$9,999,999.99"
        nl++
        IF mwhere != "P"
            IF nl > 18
                nl++
                WAIT
            ENDIF
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO      // mok
    SELECT Part
    SET ORDER TO 1                   // Partnum

    RETURN NIL

// **** End of File PaDescLoc

// ---------------------------------------------------------------------*

STATIC FUNCTION PartSect()

    nl  := 0
    mok := "Y"
    DO WHILE mok == "Y"
        mcorrect := "Y"
        ntotal := ncattotal := 0
        mallCat := ApGetY( "Do You Want All Catalog" )
        IF mallCat  == "Y"
            IF PressedEsc()
                RETURN NIL
            ENDIF

            mwhere := "S"
            npl    := 56
            Scroll()

            Printsel()                                  // _LF_Init

            IF mwhere == "P"
                npl := 56
            ELSE
                Scroll()
                npl := 22
            ENDIF
            SELECT Part
            SET ORDER TO 4                   // Locate
            GOTO TOP
            @  0, 8 SAY Control->U_Name
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  3, 0 SAY "Locate"
            @  3, 17 SAY "Part #"
            @  3, 34 SAY "Description"
            @  3, 56 SAY "Catno"
            @  3, 61 SAY "Min Stk"
            @  3, 69 SAY "In Stock"
            nl := 4
            DO WHILE Part->( !Eof() )
                IF nl > npl
                    IF mwhere == "P"
                        EJECT
                    ELSE
                        WAIT
                        nl := 0
                        Scroll()
                    ENDIF
                    @  0, 8 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  3, 0 SAY "Locate"
                    @  3, 17 SAY "Part #"
                    @  3, 34 SAY "Description"
                    @  3, 56 SAY "Catno"
                    @  3, 61 SAY "Min Stk"
                    @  3, 69 SAY "In Stock"
                    nl := 4
                ENDIF
                IF Part->Instock > 0
                    @ nl, 0 SAY Part->Locate
                    @ nl, 17 SAY SubStr( Part->Partnum, 1, 16 )
                    @ nl, 34 SAY SubStr( Part->Desc, 1, 21 )
                    @ nl, 56 SAY SubStr( Part->Catno, 1, 4 )
                    @ nl, 61 SAY Part->MinStk PICTURE "9999.99"
                    @ nl, 69 SAY Part->Instock PICTURE "9999.99"
                    @ nl, 76 SAY "_____"
                    nl++
                    ncattotal += Part->Instock * Part->Trade
                ENDIF
                SELECT Part
                SKIP ALIAS Part
            ENDDO
            nl++
            @ nl, 30 SAY ncattotal PICTURE "$9,999,999.99"
            nl++

        ELSE

            nl  := 0
            SELECT Part
            SET ORDER TO 2                   // Catno
            GOTO TOP
            CatArray()
            ccatno    := Cat->Catno      // SPACE(4)
            mcatdesc  := Cat->CatDesc
            mmajorind := Cat->Catno
            IF PressedEsc()
                RETURN NIL
            ENDIF
            minstock := ApGetY( "Do You Want Instock ONLY" )
            mwhere := "S"
            npl    := 56
            Scroll()

            Printsel()                                  // _LF_Init

            IF mwhere == "P"
                npl := 56
            ELSE
                Scroll()
                npl := 22
            ENDIF
            @  0, 8 SAY Control->U_Name
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  1, 5 SAY mcatdesc
            @  3, 0 SAY "Part #"
            @  3, 17 SAY "Description"
            @  3, 48 SAY "Locate"
            @  3, 66 SAY "In Stock"
            nl := 4
            SELECT Part
            SEEK ccatno
            DO WHILE Part->Catno = ccatno .AND. Part->( !Eof() )
                IF nl > npl
                    IF mwhere == "P"
                        EJECT
                    ELSE
                        WAIT
                        nl := 0
                        Scroll()
                    ENDIF
                    @  0, 8 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  1, 5 SAY mcatdesc
                    @  3, 0 SAY "Part #"
                    @  3, 17 SAY "Description"
                    @  3, 48 SAY "Locate"
                    @  3, 66 SAY "In Stock"
                    nl := 4
                ENDIF
                IF minstock = "N"
                    @ nl, 0 SAY SubStr( Part->Partnum, 1, 16 )
                    @ nl, 17 SAY SubStr( Part->Desc, 1, 30 )
                    @ nl, 48 SAY Part->Locate
                    @ nl, 65 SAY Part->Instock PICTURE "99999.99"
                    @ nl, 74 SAY "_____"
                    nl++
                ELSE
                    IF Part->Instock > 0
                        @ nl, 0 SAY SubStr( Part->Partnum, 1, 16 )
                        @ nl, 17 SAY SubStr( Part->Desc, 1, 30 )
                        @ nl, 48 SAY Part->Locate
                        @ nl, 65 SAY Part->Instock PICTURE "99999.99"
                        @ nl, 74 SAY "_____"
                        nl++
                    ENDIF
                ENDIF
                ncattotal += Part->Instock * Part->Trade
                SELECT Part
                SKIP ALIAS Part
            ENDDO
            nl++
            @ nl, 30 SAY ncattotal PICTURE "$9,999,999.99"

        ENDIF // mallCat
        IF mwhere != "P"
            IF nl > 18
                nl++
                WAIT
            ENDIF
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO
    mcatlist := ApGetY( "Do You Want Catalog Amounts" )
    IF mcatlist = "Y"
        npl    := 54
        Scroll()
        mwhere := "S"

        Printsel()                                  // _LF_Init

        IF mwhere == "P"
            SET MARGIN TO 1
            npl := 56
        ELSE
            Scroll()
            npl := 22
        ENDIF
        ntotal := 0

        @  0, 8 SAY Control->U_Name
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl := 2
        SELECT Cat
        GOTO TOP
        DO WHILE Cat->( !Eof() )
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                    @  0, 8 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    nl := 2
                ELSE
                    WAIT
                    nl := 0
                    Scroll()
                ENDIF
            ENDIF
            ccatno := Cat->Catno
            nstockCost := 0
            SELECT Part
            SET ORDER TO 2
            SEEK ccatno
            DO WHILE Part->Catno == ccatno .AND. Part->( !Eof() )
                nStockCost += Part->Instock * Part->Trade
                SKIP ALIAS Part
            ENDDO
            SELECT Cat
            @ nl, 0 SAY Cat->Catno
            @ nl, 14 SAY Cat->CatDesc
            IF nstockcost > 0
                @ nl, 64 SAY nstockCost PICTURE "$9,999,999.99"
            ENDIF
            ntotal += nstockcost
            nl++
            SKIP ALIAS Cat
        ENDDO
        nl++
        nl++
        @ nl, 10 SAY "Instock * Trade"
        @ nl, 45 SAY ntotal PICTURE "$9,999,999.99"
        IF mwhere != "P"
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
    ENDIF   // mcatlist
    SELECT Part
    SET ORDER TO 1                   // Partnum

    RETURN NIL

// **** End of File PartSect

// ***---------------------------------------------------------------------*

FUNCTION AllOrders()

    nl  := 0
    mok := "Y"
    DO WHILE mok == "Y"
        mwhere := "S"
        npl    := 54
        Scroll()

        Printsel()                                  // _LF_Init

        IF mwhere == "P"
            SET MARGIN TO 1
            npl := 56
        ELSE
            Scroll()
            npl := 22
        ENDIF
        SELECT Orders
        GOTO TOP
        @  0, 8 SAY Control->U_Name
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @  3, 0 SAY "Part #"
        @  3, 46 SAY "Order #"
        @  3, 52 SAY "Date"
        @  3, 63 SAY "Ordered"
        @  3, 72 SAY "Outstand"
        nl := 4
        ntotal := ncattotal := 0
        DO WHILE Orders->( !Eof() )
            IF Orders->PartQty = Orders->Qtyrec
                SKIP ALIAS Orders
                LOOP
            ENDIF
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                    @  0, 8 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  3, 0 SAY "Part #"
                    @  3, 46 SAY "Order #"
                    @  3, 52 SAY "Date"
                    @  3, 63 SAY "Ordered"
                    @  3, 72 SAY "Outstand"
                    nl := 4
                ELSE
                    WAIT
                    nl := 0
                    Scroll()
                ENDIF
            ENDIF
            @ nl, 0 SAY SubStr( Orders->Partnum, 1, 16 )
            SELECT Part
            SEEK Orders->Partnum
            @ nl, 18 SAY SubStr( Part->Desc, 1, 24 )
            SELECT Orders
            @ nl, 45 SAY Orders->Ordnum
            @ nl, 51 SAY DToC( Orders->Date )           PICTURE "99/99/9999"
            @ nl, 62 SAY Orders->Qtyrec                 PICTURE "9,999.99"
            @ nl, 71 SAY Orders->Qtyrec - Orders->PartQty PICTURE "99,999.99"
            nl++
            SKIP ALIAS Orders
        ENDDO
        nl++
        // **   @ nl,45 SAY "Total"
        // **   @ nl,52 SAY ntotal PICTURE "9,999,999.99"
        // **   nl++
        IF mwhere != "P"
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
            SET MARGIN TO 0
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO

    RETURN NIL

// **** End of File AllOrders()

// ***-------------------------------------------------------------

FUNCTION PartLoc()

    nl  := 0
    mok := "Y"
    DO WHILE mok == "Y"
        CatArray()
        ccatno := Cat->Catno      // SPACE(4)
        mcatdesc  := Cat->CatDesc
        mmajorind := Cat->Catno
        mfind  := Space( 4 )
        Scroll()
        mboughtout := "N"
        // *** ApGetY( "Bought Out Only" )

        mwhere := "S"
        npl    := 54
        Scroll()

        Printsel()                                  // _LF_Init

        IF mwhere == "P"
            SET MARGIN TO 1
            npl := 56
        ELSE
            Scroll()
            npl := 22
        ENDIF
        @  0, 8 SAY Control->U_Name
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @  1, 5 SAY mcatdesc
        @  3, 0 SAY "Location"
        @  3, 42 SAY "Part #"
        @  3, 60 SAY "Stock"
        @  3, 70 SAY "Cost"
        nl := 4
        ntotal := ncattotal := 0
        SELECT Part
        SET ORDER TO 2                   // Catno+Locate
        GOTO TOP
        SEEK ccatno
        DO WHILE Part->Catno = ccatno .AND. Part->( !Eof() )
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                    @  0, 8 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  1, 5 SAY mcatdesc
                    @  3, 0 SAY "Location"
                    @  3, 42 SAY "Part #"
                    @  3, 60 SAY "Stock"
                    @  3, 70 SAY "Cost"
                    nl := 4
                ELSE
                    WAIT
                    nl := 0
                    Scroll()
                ENDIF
            ENDIF
            @ nl, 0 SAY Part->Locate
            @ nl, 17 SAY SubStr( Part->LocDesc, 1, 23 )
            @ nl, 42 SAY SubStr( Part->Partnum, 1, 16 )
            @ nl, 60 SAY Part->Instock  PICTURE "99,999.99"
            @ nl, 70 SAY Part->Trade    PICTURE "99,999.99"
            ntotal += Part->Instock * Part->Trade
            nl++
            SKIP ALIAS Part
        ENDDO
        nl++
        @ nl, 45 SAY "Total"
        @ nl, 52 SAY ntotal PICTURE "9,999,999.99"
        nl++
        IF mwhere != "P"
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
            SET MARGIN TO 0
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO
    SET ORDER TO 1

    RETURN NIL

// **** End of File PartLoc()

// ***-------------------------------------------------------------

FUNCTION Mu_PartList()

    LOCAL cheading, nselect

    DO WHILE .T.

        nselect  := 0
        nc       := ncl * 2
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( Menu2->CH_PLstHd ) ) / 2 );
            SAY RTrim( Menu2->CH_PLstHd )
        @  7, nc + 2 PROMPT "1. Location           "
        @  9, nc + 2 PROMPT "2. Partno+Desc _______"
        @ 11, nc + 2 PROMPT "3. Loc+#+Desc+Qty ____"
        @ 12, nc + 2 PROMPT "4. Desc+Unit+Qty+Cost "
        @ 13, nc + 2 PROMPT "5. Catalogue Qty Price"
        @ 14, nc + 2 PROMPT "6. Catalogue+Group    "
        @ 15, nc + 2 PROMPT "7. Supplier List      "
        @ 17, nc + 2 PROMPT "8. Catalogue+Location "
        @ 18, nc + 2 PROMPT "9. #+Desc+Loc+Qty ____"
        @ 20, nc + 2 PROMPT Menu->CH_Main + "   "
        nc := ncl
        MENU TO nselect
        DO CASE
        CASE nselect == 10 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 1
            SAVE SCREEN TO Invscrn
            LocPart()                      // Above
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 2
            SAVE SCREEN TO Invscrn
            PartList()                      // Below
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 3
            SAVE SCREEN TO Invscrn
            PartSect()                    // Below
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 4
            SAVE SCREEN TO Invscrn
            PartTrade()                    // Below
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 5
            SAVE SCREEN TO Invscrn
            CatPrice()                    // Below
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 6
            SAVE SCREEN TO Invscrn
            CatGroup()
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 7
            SAVE SCREEN TO Invscrn
            SuppList()
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 8
            SAVE SCREEN TO Invscrn
            PartLoc()                      // Above
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 9
            SAVE SCREEN TO Invscrn
            PaDescLoc()                    // Above
            RESTORE SCREEN FROM Invscrn
        ENDCASE
    ENDDO

    RETURN NIL

// **** End of Mu-PartList()

// ---------------------------------------------------------------------*

STATIC FUNCTION SuppList()

    mcodeno := Space( 8 )
    NameRank( mcodeno )
    mcodeno := Name->Codeno
    SELECT Part
    INDEX ON Part->Codeno + Part->Partnum TO PartCode
    SET INDEX TO PartCode
    GOTO TOP
    SEEK mcodeno
    Scroll()
    DispBox( 0, 1, 2, 79, 2 )
    @  1, 10 SAY Trim( Name->Name ) + " Suppliers Part ID "
    aPart_ := {}
    nrecno   := 0
    mpartnum := msuplId := Space( 20 )
    IF LastRec() != 0
        DO WHILE Part->Codeno = mcodeno .AND. Part->( !Eof() )
            SELECT Supl
            SET ORDER TO 1       // Partnum
            SEEK Part->Partnum
            IF Found()
                IF Supl->Codeno = mcodeno
                    msuplId := Supl->SuppId
                ENDIF
            ENDIF
            SELECT Part
            AAdd( aPart_, Part->Partnum;
                + " " + Part->Desc + " " + msuplId;
                + "                  " + Str( RecNo(), 6 ) )
            SKIP ALIAS Part
            msuplId := Space( 20 )
        ENDDO                    // Part
        DispBox( 3, 1, 24, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
         /*
         IF PressedEsc()
            SELECT Part
            SET INDEX TO PartInd
            SEEK mpartnum
            mpartnum := Part->Partnum
            RETURN mpartnum
         ENDIF
         */
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            mpartnum := Part->Partnum
        ENDIF                        // !Empty
    ENDIF                           // LastRec
    mwhere := "S"
    npl    := 54
    Scroll()

    Printsel()                                  // _LF_Init

    IF mwhere == "P"
        SET MARGIN TO 0
        npl := 56
    ELSE
        Scroll()
        npl := 22
    ENDIF
    SELECT Part
    // ***   SET ORDER TO 2                   // Catno
    GOTO TOP
    SEEK mcodeno
    @  0, 8 SAY Control->U_Name
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 0 SAY "Part #"
    @  2, 20 SAY "Description"
    @  2, 60 SAY "Stock"
    @  2, 70 SAY "Cost"
    nl := 3
    ntotal := ncattotal := 0
    DO WHILE Part->Codeno = mcodeno .AND. Part->( !Eof() )
        SELECT Supl
        SET ORDER TO 1       // Partnum
        SEEK Part->Partnum
        IF Found()
            IF Supl->Codeno = mcodeno
                msuplId := Supl->SuppId
            ENDIF
        ENDIF
        IF nl > npl
            IF mwhere == "P"
                EJECT
                @  0, 8 SAY Control->U_Name
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                @  2, 0 SAY "Part #"
                @  2, 20 SAY "Description"
                @  2, 60 SAY "Stock"
                @  2, 70 SAY "Cost"
                nl := 3
            ELSE
                WAIT
                nl := 0
                Scroll()
            ENDIF
        ENDIF
        @ nl, 0 SAY SubStr( Part->Partnum, 1, 16 )
        @ nl, 18 SAY Part->Desc
        // **     @ nl,41 SAY Part->Unit
        @ nl, 60 SAY Part->Instock  PICTURE "99,999.99"
        @ nl, 70 SAY Part->Trade    PICTURE "999,999.99"
        ntotal += Part->Instock * Part->Trade
        nl++
        SKIP ALIAS Part
    ENDDO
    nl++
    @ nl, 30 SAY "Stock*Cost Total"
    @ nl, 52 SAY ntotal PICTURE "$9,999,999.99"
    nl++
    IF mwhere != "P"
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ELSE
        EndPrint()
        SET MARGIN TO 0
    ENDIF
    // **   mok := ApGetN( TRIM( Message->Another )+" Print" )
    SELECT Part
    SET INDEX TO PartInd
    SET ORDER TO 1

    RETURN NIL

// **** End of File SuppList()

// ***---------------------------------------------------------------------*

FUNCTION CatPrice()

    mok := "Y"
    DO WHILE mok == "Y"
        mprint := ApGetY( "Only Catalogues above $0.00"  )
        ccatno := Space( 12 )
        mwhere := "S"
        npl    := 54
        Scroll()

        Printsel()                                  // _LF_Init

        IF mwhere == "P"
            SET MARGIN TO 1
            npl := 56
        ELSE
            Scroll()
            npl := 22
        ENDIF
        @  0, 8 SAY Control->U_Name
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl := 2
        SELECT Part
        SET ORDER TO 2                   // Catno
        GOTO TOP
        ntotal := ncattotal := 0
        ccatno := Part->Catno
        DO WHILE Part->( !Eof() )
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                    @  0, 8 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    nl := 2
                ELSE
                    WAIT
                    nl := 0
                    Scroll()
                ENDIF
            ENDIF
            IF Part->Catno != ccatno
                SELECT Cat
                SEEK ccatno
                // **         IF !FOUND()
                // **            @ nl,14 SAY "No Catalogue"
                // **            nl++
                // **          ELSE
                IF mprint = "N"
                    @ nl, 0 SAY Cat->Catno
                    @ nl, 14 SAY Cat->CatDesc
                    @ nl, 65 SAY ncattotal PICTURE "9,999,999.99"
                    nl++
                ELSE
                    IF ncattotal > 0
                        @ nl, 0 SAY Cat->Catno
                        @ nl, 14 SAY Cat->CatDesc
                        @ nl, 65 SAY ncattotal PICTURE "9,999,999.99"
                        nl++
                    ENDIF
                ENDIF
                // **         ENDIF
                ccatno := Part->Catno
                ncattotal := 0
                SELECT Part
            ENDIF
            ncattotal += Part->Instock * Part->Trade
            ntotal    += Part->Instock * Part->Trade
            SKIP ALIAS Part
        ENDDO
        nl++
        @ nl, 55 SAY "Total"
        @ nl, 65 SAY ntotal PICTURE "9,999,999.99"
        nl++
        IF mwhere != "P"
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO
    SET ORDER TO 1

    RETURN NIL

// **** End of File CatPrice()

// ---------------------------------------------------------------------*

STATIC FUNCTION PartTrade()

    nl  := 0
    mok := "Y"
    DO WHILE mok == "Y"
        CatArray()
        ccatno := Cat->Catno      // SPACE(4)
        mcatdesc  := Cat->CatDesc
        mmajorind := Cat->Catno
        mfind  := Space( 4 )
        Scroll()
        mboughtout := "N"
        // *** ApGetY( "Bought Out Only" )

        mwhere := "S"
        npl    := 54
        Scroll()

        Printsel()                                  // _LF_Init

        IF mwhere == "P"
            SET MARGIN TO 1
            npl := 56
        ELSE
            Scroll()
            npl := 22
        ENDIF
        SELECT Part
        SET ORDER TO 2                   // Catno
        GOTO TOP
        @  0, 8 SAY Control->U_Name
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @  1, 5 SAY mcatdesc
        // ** @  3, 0 SAY "Part #"
        @  3, 0 SAY "Description"
        @  3, 52 SAY "Stock"
        @  3, 63 SAY "Cost"
        nl := 4
        ntotal := ncattotal := 0
        SEEK ccatno
        DO WHILE Part->Catno = ccatno .AND. Part->( !Eof() )
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                    @  0, 8 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  1, 5 SAY mcatdesc
                    // ** @  3, 0 SAY "Part #"
                    @  3, 0 SAY "Description"
                    @  3, 52 SAY "Stock"
                    @  3, 63 SAY "Cost"
                    nl := 4
                ELSE
                    WAIT
                    nl := 0
                    Scroll()
                ENDIF
            ENDIF
            // **      @ nl, 0 SAY SUBSTR( Part->Partnum,1, 8 )
            @ nl, 0 SAY Part->Desc
            @ nl, 41 SAY Part->Unit
            @ nl, 52 SAY Part->Instock  PICTURE "99,999.99"
            @ nl, 63 SAY Part->Trade    PICTURE "99,999.99"
            @ nl, 72 SAY "_______"
            // **      @ nl,72 SAY Part->Retindiv PICTURE "999.999"
            ntotal += Part->Instock * Part->Trade
            nl++
            SKIP ALIAS Part
        ENDDO
        nl++
        @ nl, 45 SAY "Total"
        @ nl, 52 SAY ntotal PICTURE "9,999,999.99"
        nl++
        IF mwhere != "P"
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
            SET MARGIN TO 0
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO
    SET ORDER TO 1

    RETURN NIL

// **** End of File PartTrade()

// ---------------------------------------------------------------------*

STATIC FUNCTION PartList()

    nl  := 0
    mok := "Y"
    DO WHILE mok == "Y"
        CatArray()
        ccatno := Cat->Catno      // SPACE(4)
        mcatdesc  := Cat->CatDesc
        mmajorind := Cat->Catno
        mfind  := Space( 4 )
        Scroll()
        mboughtout := "N"
        // *** ApGetY( "Bought Out Only" )

        mwhere := "S"
        npl    := 54
        Scroll()

        Printsel()                                  // _LF_Init

        IF mwhere == "P"
            SET MARGIN TO 1
            npl := 56
        ELSE
            Scroll()
            npl := 22
        ENDIF
        SELECT Part
        SET ORDER TO 2                   // Catno
        GOTO TOP

        @  0, 8 SAY Control->U_Name
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @  1, 5 SAY mcatdesc
        @  3, 0 SAY "Part #"
        @  3, 20 SAY "Description"
        nl := 4
        ntotal := ncattotal := 0
        SEEK ccatno
        DO WHILE Part->Catno = ccatno .AND. Part->( !Eof() )
            mcodeno := Part->Codeno
            IF mboughtout = "Y"
                IF Part->Boughtout != "Y"
                    SKIP ALIAS Part
                    LOOP
                ENDIF
            ENDIF
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                    @  0, 8 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  1, 5 SAY mcatdesc
                    @  3, 0 SAY "Part #"
                    @  3, 20 SAY "Description"
                    nl := 4
                ELSE
                    WAIT
                    nl := 0
                    Scroll()
                ENDIF
            ENDIF
            @ nl, 0 SAY Part->Partnum
            @ nl, 20 SAY Part->Desc
            @ nl, 61 SAY "_________"
            @ nl, 70 SAY Part->Unit
            nl++
            SKIP ALIAS Part
        ENDDO
        IF mwhere != "P"
            IF nl > 18
                nl++
                WAIT
            ENDIF
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
            SET MARGIN TO 0
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO
    SELECT Part
    SET ORDER TO 1                 // Partnum

    RETURN NIL

// **** End of File PartList

// ---------------------------------------------------------------------*

STATIC FUNCTION CatGroup()

    nl  := 0
    mok := "Y"
    DO WHILE mok == "Y"
        mwhere := "S"
        Scroll()
        SELECT Part
        ApFLock( 3 )
        INDEX ON Part->Catno + Part->PartId TO TempIPL
        SET INDEX TO TempIPL
        UNLOCK

        Printsel()                                  // _LF_Init

        IF mwhere == "P"
            npl := 56
        ELSE
            Scroll()
            npl := 22
        ENDIF
        SELECT Part
        GOTO TOP
        @  0, 8 SAY Control->U_Name
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @  2, 0 SAY "Catalogue"
        @  2, 16 SAY "Group"
        nl := 3
        cCatGroup := Part->Catno + Part->PartId
        DO WHILE Part->( !Eof() )
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                    @  0, 8 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  2, 0 SAY "Catalogue"
                    @  2, 16 SAY "Group"
                    nl := 3
                ELSE
                    WAIT
                    nl := 0
                    Scroll()
                ENDIF
            ENDIF
            IF Part->Catno + Part->PartId = cCatGroup
                SKIP ALIAS Part
                LOOP
            ENDIF
            @ nl, 0 SAY Part->Catno
            @ nl, 15 SAY Part->PartId
            SELECT Cat
            SEEK Part->Catno
            IF Found()
                @ nl, 30 SAY Cat->CatDesc
            ENDIF
            SELECT Part
            cCatGroup := Part->Catno + Part->PartId
            nl++
            SKIP ALIAS Part
        ENDDO
        IF mwhere != "P"
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO
    SELECT Part
    SET INDEX TO PartInd

    RETURN NIL

// **** End of File CatGroup()

// *-------------------------------------------------------------------

FUNCTION PartRUtd()

    Scroll()
    @ 16, 20 SAY Str( Day( Control->LastRoll ), 3 ) + " " + CMonth( Control->LastRoll );
        + Str( Year( Control->LastRoll ), 5 )
    mok := "N"
    // *** ApGetN( "Do you want to Zero the Rec/Utd to Date" )
    IF mok = "Y"
        mok := ApGetN( "Are You sure you understand" )
    ENDIF
    IF mok = "Y"
        @ 12, 10 SAY "Please Wait BIG JOB"
        SELECT Control
        ApRLock( 3 )
        Control->LastRoll := Date()
        UNLOCK
        SELECT Part
        ApFLock( 3 )
        REPLACE ALL Part->RecQty  WITH 0
        REPLACE ALL Part->Utd     WITH 0
        UNLOCK
        @ 12, 5 SAY Space( 40 )
        RETURN NIL
    ENDIF                                   // mok
    npl    := 56
    mwhere := "S"

    Printsel( mwhere )

    IF mwhere == "P"
        SET MARGIN TO 0
        npl := 56
    ELSE
        Scroll()
        npl := 22
    ENDIF
    ntotal := 0
    @  0, 0 SAY Control->U_Name
    @  0, 40 SAY "Since Date"
    @  0, 51 SAY Control->LastRoll
    @  0, 65 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 0 SAY "Part #"
    @  2, 18 SAY "Description"
    @  2, 46 SAY "Received      Used\Date   Instock"
    nl := 4
    SELECT Part
    SET ORDER TO 1                          // Partnum WAS NO 3 PartId + Desc
    GOTO TOP
    DO WHILE Part->( !Eof() )
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            @  0, 0 SAY Control->U_Name
            @  0, 40 SAY "Since Date"
            @  0, 51 SAY Control->LastRoll
            @  0, 65 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  2, 0 SAY "Part #"
            @  2, 18 SAY "Description"
            @  2, 46 SAY "Received      Used\Date  Instock"
            nl := 4
        ENDIF
        IF Part->Utd > 0         // WAS Part->RecQty
            @ nl, 0 SAY SubStr( Part->Partnum, 1, 11 )
            @ nl, 12 SAY SubStr( Part->Desc, 1, 30 )
            @ nl, 43 SAY Part->RecQty  PICTURE "9999,999.99"
            @ nl, 55 SAY Part->Utd     PICTURE "9999,999.99"
            @ nl, 67 SAY Part->Instock PICTURE "9999,999.99"
            DO CASE
            CASE SubStr( Part->Partnum, 3, 1 ) = "-"
                ntotal := ntotal
            CASE SubStr( Part->Partnum, 5, 1 ) = "-"
                ntotal := ntotal
            CASE SubStr( Part->Partnum, 7, 1 ) = "-"
                ntotal := ntotal
            OTHERWISE
                ntotal += Part->Utd * Part->Trade
            ENDCASE
        ELSE
            SKIP ALIAS Part
            LOOP
        ENDIF
        nl++
        SKIP ALIAS Part
    ENDDO                                  // EOF()
    nl += 2
    // ** @ nl,34 SAY "Non Module Costs"
    @ nl, 53 SAY ntotal PICTURE "$9,999,999.99"
    IF mwhere == "P"
        EndPrint()
    ELSE
        IF nl > 20
            nl++
            Inkey( 0 )
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
        Scroll()
    ENDIF

    RETURN NIL                              // End of Function PartRUtd

// **-----End PartRUtd()

// ******-----------  END OF FILE XF_PLIST.PRG
