// ** JK  06-07-11 20:48:24

/*
   Program.....:                 XF_PART.PRG
   Author......: J.Kirby
   Date........: 31/10/1996
   Functions...: CatArray, PartUsed, Partfind, Partchange
                 PartView, Suppliers
   Static funcs: PartRank, CatFind, PartGet, ProfSupply
*/

// (c) Copyright (c) 1995 Kirby Christchurch.

FUNCTION CatArray()

    Scroll()
    DispBox( 0, 0, 23, 79, 2 )
    SELECT Cat
    GO TOP
    ccatno := Space( 12 )
    nrecno := 0
    aPart_ := {}
    mselect := "    "
    @ 6, 6 SAY "Catalogue: Exact First 4 Letters Blank for all" GET mselect PICTURE "@!X"
    READ
    @ 6, 10 SAY "                                                      "
    DO WHILE Cat->( !Eof() )
        IF mselect != "    "
            DO CASE
            CASE SubStr( mselect, 2, 3 ) = "   "
                IF SubStr( Cat->Catno, 1, 1 ) != SubStr( mselect, 1, 1 )
                    SKIP ALIAS Cat
                    LOOP
                ENDIF
            CASE SubStr( mselect, 3, 2 ) = "  "
                IF SubStr( Cat->Catno, 1, 2 ) != SubStr( mselect, 1, 2 )
                    SKIP ALIAS Cat
                    LOOP
                ENDIF
            CASE SubStr( mselect, 4, 1 ) = " "
                IF SubStr( Cat->Catno, 1, 3 ) != SubStr( mselect, 1, 3 )
                    SKIP ALIAS Cat
                    LOOP
                ENDIF
            CASE mselect != "    "
                IF SubStr( Cat->Catno, 1, 4 ) != SubStr( mselect, 1, 4 )
                    SKIP ALIAS Cat
                    LOOP
                ENDIF
            ENDCASE
        ENDIF    // mselect
        AAdd( aPart_, Cat->Catno + "     " + Cat->CatDesc;
            + "                  " + Str( RecNo(), 6 ) )
        SKIP ALIAS Cat
    ENDDO
    @ 24, 20 SAY "--- F2 For Headings ---" COLOR "RG+"
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 1, 2, 22, 78, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        GOTO nrecno
        ccatno := Cat->Catno
        IF LastKey() == -1
            SELECT Cat
            GO TOP
            ccatno := Space( 12 )
            nrecno := 0
            aPart_ := {}
            DO WHILE Cat->( !Eof() )
                IF SubStr( Cat->Catno, 4, 2 ) != "AA"
                    SKIP ALIAS Cat
                    LOOP
                ENDIF
                AAdd( aPart_, Cat->CatDesc + " " + Cat->Catno + "                 " + Str( RecNo(),6 ) )
                SKIP ALIAS Cat
            ENDDO
            IF !Empty( aPart_ )
                Scroll()
                DispBox( 0, 0, 23, 79, 2 )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 1, 3, 22, 77, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                ccatno := Cat->Catno
            ENDIF
            nrecno := 0
            aPart_ := {}
            DO WHILE Cat->( !Eof() )
                IF SubStr( Cat->Catno, 1, 2 ) != SubStr( ccatno, 1, 2 )
                    SKIP ALIAS Cat
                    LOOP
                ENDIF
                AAdd( aPart_, Cat->CatDesc + "  " + Cat->CatNo;
                    + "               " + Str( RecNo(), 6 ) )
                SKIP ALIAS Cat
            ENDDO
            IF !Empty( aPart_ )
                Scroll()
                DispBox( 0, 0, 23, 79, 2 )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 1, 3, 22, 77, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                ccatno := Cat->Catno
            ENDIF
        ENDIF                       // F2
    ENDIF

    RETURN ccatno

// * End of CatArray()

// *-------------------------------------------------------------------

FUNCTION PartUsed( mpartnum )

    aPart_ := {}
    SELECT Equ
    GOTO TOP
    DO WHILE Equ->( !Eof() )
        IF Equ->Partnum != mpartnum
            SKIP ALIAS Equ
            LOOP
        ENDIF
        SELECT EquDesc
        SET ORDER TO 1
        SEEK Equ->ModCode
        SELECT Equ
        AAdd( aPart_, Equ->Modcode;
            + " " + EquDesc->Desc;
            + "  " + Str( Equ->PartQty, 12, 3 ) )
        SKIP ALIAS Equ
    ENDDO                            // EOF Equ
    ASort( aPart_,,, {| x, y | x < y } )
    Scroll(  3, 0, 24, 80 )
    DispBox( 3, 1, 24, 79, 2 )
    @  3, 4 SAY " Part Used in The Following Modules " COLOR "G+"
    @ 23, 20 SAY "Any Key To Continue" COLOR "G+"
    IF !Empty( aPart_ )
        @  3, 0 SAY " "
        AEval( aPart_, {|A| QOUT( " " + Chr( 186 ) + "  " );
            , QQOut( A ), BreakTot() } )

        // ***      anum := ACHOICE( 4, 5, 22,76,aPart_,,"AFUNC" )
    ENDIF
    WAIT
    Scroll()

    Printsel()                                  // _LF_Init

    IF mwhere == "P"
        SET MARGIN TO 1
        npl := 56
    ELSE
        Scroll()
        npl := 22
    ENDIF
    SELECT Equ
    GOTO TOP
    @  0, 8 SAY Control->U_Name
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 8 SAY Part->Desc
    nl := 4
    SELECT EquDesc
    SET ORDER TO 1
    SEEK Equ->ModCode
    SELECT Equ
    DO WHILE Equ->( !Eof() )
        IF Equ->Partnum != mpartnum
            SKIP ALIAS Equ
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere == "P"
                EJECT
                @  0, 8 SAY Control->U_Name
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                @  2, 8 SAY Part->Desc
                nl := 4
            ELSE
                WAIT
                nl := 0
                Scroll()
            ENDIF
        ENDIF
        @ nl, 0 SAY Equ->Modcode
        SELECT EquDesc
        SEEK Equ->Modcode
        @ nl, 18 SAY EquDesc->Desc
        SELECT Equ
        @ nl, 60 SAY Str( Equ->PartQty, 12, 3 )
        nl++
        SKIP ALIAS Equ
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
    SELECT Part

    RETURN mpartnum

// *** End of PartUsed()

// *---------------------------------------------------------------------*

FUNCTION Partfind( mpartnum, mcodeno )

    DO WHILE .T.
        mpartnum := Space( 20 )
        SELECT Part
        SET ORDER TO 1                       // Partnum
        IF Part->( LastRec() ) == 0
            PartAdd( @mpartnum )
            mpartnum := Part->Partnum
        ENDIF                    // Empty Parts File
        Scroll(  0, 0, 2, 80 )
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 5 SAY "Enter Part Number" GET mpartnum PICTURE "@!"
        @  1, 48 SAY "Blank for more Options"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        IF SubStr( mpartnum, 1, 1 ) != Space( 1 )   // Input to Partnum
            PartRank( @mpartnum )           // Above
            SELECT Part
            SET ORDER TO 1                   // Partnum
            SEEK mpartnum
            IF !Found()
                @ 1, 4 SAY "PART NOT FOUND TRY Again" COLOR "G+"
                Inkey( 0 )
                LOOP
            ENDIF
            IF PressedEsc()
                RETURN NIL
            ENDIF
            RETURN mpartnum
        ENDIF                           // Partnum = Char

        // Set Up for Blank Partnum
        IF mpartnum == Space( 20 )   // Blank Partnum
            Scroll(  0, 0, 3, 80 )
            DispBox( 0, 0, 3, 79, 2 )
            nselect  := 1
            @ 1, 5      PROMPT "1. Catalogue"
            @ 1, Col() + 2 PROMPT "2. Location"
            @ 1, Col() + 2 PROMPT "3. Add New  "
            @ 1, Col() + 2 PROMPT "4. Cat+Group"
            @ 1, Col() + 2 PROMPT "5. Group"
            @ 1, Col() + 2 PROMPT "6. Suppl"
            @ 2, 5      PROMPT "7. Location Group"
            @ 2, Col() + 2 PROMPT "8. Cat+Location"
            @ 3, 60 SAY " DT31 "
            MENU TO nselect
            DO CASE
            CASE PressedEsc()
                RETURN mpartnum
            CASE nselect == 8                  // Catalogue Location
                CatLoc()                  // XF_PList
                RETURN mpartnum
            CASE nselect == 7                  // Location Group
                LocPart()                // XF_PList
                RETURN mpartnum
            CASE nselect == 2     // Location
                clocate  := Space( 16 )
                clocdesc := Space( 28 )
                SELECT Part
                SET ORDER TO 4                // Locate
                GOTO TOP
                aPart_ := {}
                nrecno  := 0
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
                DispBox(  4, 0, 24, 52, 2 )
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice(  5, 3, 23, 50, aPart_,, "AFUNC" )
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
                    GOTO TOP
                    SEEK clocate
                    DO WHILE Part->Locate = clocate .AND. Part->( !Eof() )
                        IF Part->LocDesc = "    "
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
                SET ORDER TO 1
                SEEK mpartnum
                mpartnum := Part->Partnum

                RETURN mpartnum

            CASE nselect == 1                  // Catalogue
                mpartnum = "CCC" + Space( 17 )
            CASE nselect == 5                  // Group
                mpartnum = "ZZZ" + Space( 17 )
            CASE nselect == 6                  // Supplier
                NameRank( mcodeno )
                mcodeno := Name->Codeno
                SELECT Part
                INDEX ON Part->Codeno + Part->Partnum TO PartCode
                SET INDEX TO PartCode
                GOTO TOP
                SEEK mcodeno
                Scroll()
                DispBox( 0, 0, 2, 79, 2 )
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
                    DispBox( 3, 0, 24, 79, 2 )
                    IF !Empty( aPart_ )
                        ASort( aPart_,,, {| x, y | x < y } )
                        anum := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
                        IF PressedEsc()
                            SELECT Part
                            SET INDEX TO PartInd
                            // **            SET ORDER TO 1              // Partnum
                            SEEK mpartnum
                            mpartnum := Part->Partnum
                            RETURN mpartnum
                        ENDIF
                        nrecno := Val( Right( aPart_[ anum ],6 ) )
                        GOTO nrecno
                        mpartnum := Part->Partnum
                    ENDIF                        // !Empty
                ENDIF                           // LastRec
                SELECT Part
                SET INDEX TO PartInd
                // ***            SET ORDER TO 1              // Partnum
                GOTO TOP
                SEEK mpartnum
                mpartnum := Part->Partnum
                RETURN mpartnum

            CASE nselect == 3                  // Add New Part
                mpartnum = "XXX" + Space( 17 )
            ENDCASE
        ENDIF                        // Partnum = SPACE 20
        DO CASE
        CASE  SubStr( mpartnum, 1, 3 ) = "CCC"     // Find by Catalogue
            ccatno := Space( 12 )
            CatArray()               // Creates array of Catalogue
            SELECT Part
            SET ORDER TO 2                            // Catno + Desc
            SEEK ccatno
            IF Found()
                mpartnum := PartGet( @ccatno )        // Below

                SET ORDER TO 1                         // Partnum + Desc
                SEEK mpartnum
                IF Found()
                    mpartnum := Part->Partnum
                ELSE
                    Scroll()
                    WAIT " PART NOT FOUND IN PARTLIST "
                ENDIF
            ELSE
                Scroll()
                @  9, 10 SAY "NO PARTS THIS CATALOGUE SELECTION"
                mok := ApGetN( "Yes to Add - No to Search" )
                IF PressedEsc()
                    SELECT Part
                    SET ORDER TO 1
                    RETURN NIL
                ENDIF
                IF mok == "Y"

                    PartAdd( @mpartnum )                    // Below

                    DO CASE
                    CASE SubStr( Part->Partnum, 1, 3 ) = "JC-"
                        RETURN mpartnum
                    CASE SubStr( Part->Partnum, 1, 3 ) = "QU-"
                        RETURN mpartnum
                    CASE SubStr( Part->Partnum, 1, 3 ) = "TEM"
                        RETURN mpartnum
                    CASE SubStr( Part->Partnum, 1, 3 ) = "ZZT"
                        RETURN mpartnum
                    CASE SubStr( Part->Partnum, 1, 3 ) = "TT-"
                        RETURN mpartnum
                    ENDCASE
                    SELECT Part
                    SET ORDER TO 1                         // Partnum + Desc
                    SEEK mpartnum
                    mpartnum := Part->Partnum

                    PartDets( @mpartnum )

                ELSE
                    mpartnum := Space( 16 )        // This initiates CatLook, etc.
                    LOOP
                ENDIF                  // mok
            ENDIF                     // Found
            SELECT Part
            SET ORDER TO 1                        // Partnum
            SEEK mpartnum
            IF !Found()
                Scroll( 14, 6, 24, 74 )
                @ 16, 10 SAY "--- This part not in file ---"
                mok := ApGetN( "Yes Add Part / No = Search" )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                IF mok == "Y"
                    Partadd( @mpartnum )         // Below
                    DO CASE
                    CASE SubStr( Part->Partnum, 1, 3 ) = "JC-"
                        RETURN mpartnum
                    CASE SubStr( Part->Partnum, 1, 3 ) = "QU-"
                        RETURN mpartnum
                    CASE SubStr( Part->Partnum, 1, 3 ) = "TEM"
                        RETURN mpartnum
                    CASE SubStr( Part->Partnum, 1, 3 ) = "ZZT"
                        RETURN mpartnum
                    CASE SubStr( Part->Partnum, 1, 3 ) = "TT-"
                        RETURN mpartnum
                    ENDCASE
                    mpartnum := Part->Partnum
                    PartDets( mpartnum )
                ELSE
                    LOOP
                ENDIF        // mok
            ELSE
                RETURN mpartnum
            ENDIF                     // Found

        CASE SubStr( mpartnum, 1, 3 ) == "ZZZ"            // Group
            SELECT Part
            SET ORDER TO 3                // PartId+Partnum
            Scroll()
            DispBox(  0, 0, 2, 79, 2 )
            @  1, 10 SAY "Find By Part ID"
            aPart_ := {}
            nrecno   := 0
            mpartnum := Space( 16 )
            cpartId  := Space( 16 )
            Scroll()
            IF LastRec() != 0
                GOTO TOP
                DO WHILE Part->( !Eof() )
                    DO WHILE Part->PartId = cpartId
                        SKIP ALIAS Part
                        LOOP
                    ENDDO
                    AAdd( aPart_, Part->PartId + "       " + Str( RecNo(),6 ) )
                    // ***  SKIP ALIAS EquDesc
                    cpartId := Part->PartId
                ENDDO
                DispBox( 0, 0, 23, 26, 2 )
                IF !Empty( aPart_ )
                    anum := AChoice( 2,  7, 22, 24, aPart_,, "AFUNC" )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                ENDIF                // ! Empty
            ENDIF                           // Found
            mpartnum := Part->PartId + Space( 4 )

            CatFind( @mpartnum )

            SELECT Part
            SET ORDER TO 1
            SEEK mpartnum
            mpartnum := Part->Partnum

            RETURN mpartnum


        CASE SubStr( mpartnum, 1, 3 ) == "XXX"   // Add Part
            PartAdd( @mpartnum )                 // Below
            mpartnum := Part->Partnum
            DO CASE
            CASE SubStr( Part->Partnum, 1, 3 ) = "JC-"
                RETURN mpartnum
            CASE SubStr( Part->Partnum, 1, 3 ) = "QU-"
                RETURN mpartnum
            CASE SubStr( Part->Partnum, 1, 3 ) = "TEM"
                RETURN mpartnum
            CASE SubStr( Part->Partnum, 1, 3 ) = "ZZT"
                RETURN mpartnum
            CASE SubStr( Part->Partnum, 1, 3 ) = "TT-"
                RETURN mpartnum
            ENDCASE
            SELECT Part
            SET ORDER TO 1
            SEEK mpartnum

            PartDets( @mpartnum )                // CWP2

            RETURN mpartnum

        CASE  mpartnum = Space( 16 )     // Find by Catalogue
            ccatno := Space( 12 )
            CatArray()               // Creates array of Catalogue
            SELECT Part
            SET ORDER TO 2                   // Catno + Desc
            aPart_ := {}
            nrecno   := 0
            mpartnum := Space( 16 )
            cpartId  := Space( 16 )
            Scroll()
            IF LastRec() != 0
                SEEK ccatno
                DO WHILE Part->Catno = ccatno .AND. Part->( !Eof() )
                    DO WHILE Part->PartId = cpartId
                        SKIP ALIAS Part
                        LOOP
                    ENDDO
                    AAdd( aPart_, Part->PartId + "   " + Str( RecNo(),6 ) )
                    // **         SKIP ALIAS Part
                    cpartId := Part->PartId
                ENDDO
                DispBox( 0, 0, 23, 26, 2 )
                IF !Empty( aPart_ )
                    anum := AChoice( 2,  7, 22, 24, aPart_,, "AFUNC" )
                    IF PressedEsc()
                        RETURN mpartnum
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                ENDIF
            ENDIF
            cpartId := Part->PartId

            // ***  FUNCTION CatFind( mpartnum )

            aPart_ := {}
            nrecno := 0
            SELECT Part
            SET ORDER TO 3                  // PartId+Desc
            IF LastRec() != 0
                SEEK cpartId
                IF Found()
                    DO WHILE Part->PartId = cpartId .AND. Part->( !Eof() )
                        IF Message->Mess09 = Space( 12 )
                            AAdd( aPart_, ( Part->Desc;
                                + " " + Str( Wholesale, 8, 2 ) + " " + Str( Part->Instock, 8, 0 );
                                + "  " + SubStr( Part->Partnum, 1, 8 );
                                + "   " + Str( RecNo(), 6 ) ) )
                        ELSE
                            AAdd( aPart_, ( SubStr( Part->Partnum, 1,13 );
                                + "  " + SubStr( Part->Desc, 1, 29 );
                                + " " + Str( Part->Instock, 8, 2 ) + " " + Str( Wholesale, 12, 2 );
                                + " " + Part->ABC + " " + Part->Unit + "         " + Str( RecNo(), 6 ) ) )
                        ENDIF
                        SKIP ALIAS Part
                    ENDDO
                    // **      IF Message->Mess09 = SPACE( 12 )
                    ASort( aPart_,,, {| x, y | x < y } )
                    // **      ENDIF
                ENDIF                        // FOUND()
                Scroll()
                DispBox( 0, 0, 23, 79, 2 )
                @ 24, 5 SAY Message->Select
                @ 24, 50 SAY Message->Esc
                IF !Empty( aPart_ )
                    anum := AChoice( 2, 2, 22, 78, aPart_,, "AFUNC" )
                    IF LastKey() == -1

                        PartAdd( mpartnum )                  // Below
                        mpartnum := Part->Partnum
                        DO CASE
                        CASE SubStr( Part->Partnum, 1, 3 ) = "JC-"
                            RETURN mpartnum
                        CASE SubStr( Part->Partnum, 1, 3 ) = "QU-"
                            RETURN mpartnum
                        CASE SubStr( Part->Partnum, 1, 3 ) = "TEM"
                            RETURN mpartnum
                        CASE SubStr( Part->Partnum, 1, 3 ) = "ZZT"
                            RETURN mpartnum
                        CASE SubStr( Part->Partnum, 1, 3 ) = "TT-"
                            RETURN mpartnum
                        ENDCASE
                        SELECT Part
                        SET ORDER TO 1
                        SEEK mpartnum
                        mpartnum := Part->Partnum

                        PartDets( @mpartnum )

                    ENDIF                     // LastKey
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                    mpartnum := Part->Partnum
                ENDIF                            // !Empty
                Scroll(  1, 0, 1, 80 )
                DispBox( 0, 0, 2, 79, 2 )
                @  1, 8 SAY Trim( mpartnum ) + " " + SubStr( Part->Desc, 1, 30 );
                    + " " + Str( Part->Instock, 9, 0 )  // COLOR c_hicolor
            ENDIF           // LastRec

            SELECT Part
            SET ORDER TO 1
            SEEK mpartnum
            mpartnum := Part->Partnum

            RETURN mpartnum
            // *******

        CASE SubStr( mpartnum, 1, 1 ) == "?"      // All Parts
            IF RecNo() > 2000
                @ 19, 10      SAY "Too Many Parts in File "
                @ 19, Col() + 2 SAY RecNo() PICTURE "99,999"
                @ 21, 10      SAY "  "
                WAIT
                LOOP
            ENDIF

            aPart_ := {}

            Scroll(  3, 0, 24, 80 )
            IF Part->( LastRec() ) != 0
                GO TOP
                DO WHILE Part->( !Eof() )
                    IF Message->Mess09 = Space( 12 )
                        AAdd( aPart_, Part->Desc;
                            + " " + Str( Wholesale, 8, 2 ) + " " + Str( Part->Instock, 8, 0 );
                            + "  " + SubStr( Part->Partnum, 1, 10 );
                            + "   " + Str( RecNo(), 6 ) )
                    ELSE
                        AAdd( aPart_, ( SubStr( Part->Partnum, 1,13 );
                            + "  " + SubStr( Part->Desc, 1, 29 );
                            + " " + Str( Part->Instock, 8, 2 ) + " " + Str( Wholesale, 12, 2 );
                            + " " + Part->ABC + " " + Part->Unit + "      " + Str( RecNo(), 6 ) ) )
                    ENDIF
                    SKIP ALIAS Part
                ENDDO
                Scroll(  3, 0, 24, 80 )
                DispBox( 3, 0, 24, 79, 2 )
                IF !Empty( aPart_ )
                    anum := AChoice( 4, 2, 23, 78, aPart_,, "AFUNC" )
                    IF LastKey() == -1
                        PartAdd( mpartnum )
                        SELECT Part
                        SEEK mpartnum
                        ApRLock( 3 )
                        mpartnum := Part->Partnum
                        UNLOCK
                        PartDets( @mpartnum )
                    ENDIF
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                    mpartnum := Part->Partnum
                ENDIF
                Scroll(  0, 0, 2, 80 )
                DispBox( 0, 0, 2, 79, 2 )
                @  1, 4 SAY Trim( mpartnum ) + " " + SubStr( Part->Desc, 1, 25 );
                    + " " + Str( Part->Instock, 9, 0 )
            ENDIF
            RETURN mpartnum

            IF !Found()

                CatFind( @mpartnum )     // Finds By PartID Above

                SELECT Part
                SET ORDER TO 1                             // Partnum + Desc
                SEEK mpartnum
                IF Found()
                    mpartnum := Part->Partnum
                ENDIF
                RETURN mpartnum
            ENDIF
        ENDCASE
        mtrue := .F.
    ENDDO                   // mtrue

    RETURN mpartnum

// ***  End of Partfind()

// *-------------------------------------------------------------------

FUNCTION Partchange( mpartnum )

    // **  Taken out temp    PartUsed( mpartnum )                    // Below
   /*
   aPart_ :={}
   SELECT Equ
   GOTO TOP
   DO WHILE Equ->( !EOF() )
      IF Equ->Partnum != mpartnum
         SKIP ALIAS Equ
         LOOP
      ENDIF
      SELECT EquDesc
      SET ORDER TO 1
      SEEK Equ->ModCode
      SELECT Equ
      AADD( aPart_,Equ->Modcode;
              +" "+EquDesc->Desc;
              +"  "+STR( Equ->PartQty,12, 3 ) )
         SKIP ALIAS Equ
   ENDDO                            // EOF Equ
      ASORT(aPart_,,,{ | x,y | x < y })
      SCROLL(  3, 0, 24,80 )
      DISPBOX( 3, 1, 24,79, 2 )
      @  3, 4 SAY " Part Used in The Following Modules " COLOR "G+"
      @ 23,20 SAY "Any Key To Continue" COLOR "G+"
      IF !EMPTY( aPart_ )
            @  3, 0 SAY " "
            AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " );
                             ,QQOUT( A ),BreakTot() } )
      ****      anum := ACHOICE( 4, 5, 22,76,aPart_,,"AFUNC" )
      ENDIF
      WAIT
   */

    mok := "Y"
    DO WHILE mok == "Y"
        nl := 4
        Scroll(  11, 0, 24, 80 )
        DispBox( 11, 0, 23, 79, 2 )
        cnewpart := SubStr( mpartnum, 1, 16 )
        @ 12, 10 SAY "TRUST THAT YOU MADE A BACK UP FIRST"
        @ 14, 20 SAY mpartnum
        @ 16, 10 SAY "Change Partnum" GET cnewpart PICTURE "!!!!!!!!!!!!!!!!"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        SELECT Part
        SET ORDER TO 1
        SEEK cnewpart
        IF Found()
            @ 16, 50 SAY "Already Used Try again"
            LOOP
        ENDIF
        mcorrect := ApGetY( Message->Correct )
        IF mcorrect == "Y"
            Scroll(  11, 0, 24, 80 )
            DispBox( 11, 0, 24, 79, 2 )
            @  12, 10 SAY "Changing Part Number Please Wait"
            SELECT Equ
            // **         SET EXACT ON
            GOTO TOP
            nparts := 0
            ncount := ncnt := 1
            mmodcode := SubStr( mpartnum, 1, 16 )
            SEEK mmodcode
            IF Found()
                DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
                    nparts++
                    SKIP ALIAS Equ
                ENDDO
                @ 13, 30      SAY nparts PICTURE "999" COLOR "G+"
                @ 13, Col() + 2 SAY "Parts In Module"
                SEEK mmodcode
            ENDIF
            DO WHILE Found()
                @ 15, 6      SAY Equ->ModCode + " " + Str( ncount ) + "  " + mpartnum
                @ 15, Col() + 1 SAY "Parts Left"
                @ 15, Col() + 1 SAY nparts PICTURE "999" COLOR "G+"
                nparts--
                IF Equ->ModSeqno != Space ( 22 )
                    mrecno := SubStr( Equ->ModSeqno, 17, 6 )
                ELSE
                    mrecno := Str( RecNo(), 6 )
                ENDIF
                mseek  := Equ->ModSeqno
                ApRLock( 3 )
                Equ->ModCode  := cnewpart
                Equ->ModSeqno := cnewpart + mrecno
                UNLOCK
                @ 16, 6 SAY Equ->ModSeqno
                ncount++
                SELECT EquCut
                GOTO TOP
                SEEK mSeek
                DO WHILE Found()
                    @ 18, 6 SAY EquCut->ModSeqno + "  " + Str( ncnt ) + "  " + mpartnum
                    mrecno := SubStr( EquCut->ModSeqno, 17, 6 )
                    ApRLock( 3 )
                    EquCut->ModSeqno := SubStr( cnewpart, 1, 16 ) + mrecno
                    EquCut->ModTemp  := SubStr( cnewpart, 1, 16 ) + mrecno
                    UNLOCK
                    @ 19, 6 SAY EquCut->ModSeqno
                    ncnt++
                    SEEK mSeek
                ENDDO
                SELECT Equ
                SEEK mmodcode
                // **             @ 21, 6 SAY "If Above not good ALT C to get out"
                // **             @ 23, 6 SAY "Module File may be DAMAGED  CHECK"
                Inkey( 0.4 )
            ENDDO
            Scroll( 20, 5, 23, 78 )
            // **       SET EXACT OFF
            SELECT Part
            SET ORDER TO 1                     // mpartnum
            GOTO TOP
            SEEK mpartnum
            ApRLock( 3 )
            Part->Partnum := cnewpart
            UNLOCK
            SELECT PartSer
            SET ORDER TO 1
            GOTO TOP
            ApFLock( 3 )
            SEEK mpartnum
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            DO WHILE Found()
                PartSer->Partnum := cnewpart
                ncount++
                @ 22, 10      SAY "Part Serial #  "
                @ 22, Col() + 1 SAY ncount PICTURE "999.99"
                Inkey( 0.8 )
                SEEK mpartnum
            ENDDO
            UNLOCK
            // *******************
            SELECT Fault
            SET ORDER TO 1
            GOTO TOP
            ApFLock( 3 )
            SEEK mpartnum
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            DO WHILE Found()
                Fault->Partnum := cnewpart
                ncount++
                @ 22, 10      SAY "Fault"
                @ 22, Col() + 2 SAY ncount PICTURE "999.99"
                Inkey( 0.8 )
                SEEK mpartnum
            ENDDO
            UNLOCK
            SELECT Prof
            GOTO TOP
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            ApFLock( 3 )
            LOCATE ALL FOR Partnum = mpartnum
            DO WHILE Found()
                Prof->Partnum := cnewpart
                ncount++
                @ 22, 10      SAY "Profile Part  "
                @ 22, Col() + 2 SAY ncount PICTURE "999.99"
                Inkey( 0.8 )
                CONTINUE
            ENDDO
            UNLOCK
            // ******************
            SELECT Invoice
            GOTO TOP
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            ApFLock( 3 )
            LOCATE ALL FOR Partnum = mpartnum
            DO WHILE Found()
                Invoice->Partnum := cnewpart
                ncount++
                @ 22, 10      SAY "Invoice Part  "
                @ 22, Col() + 1 SAY ncount PICTURE "999.99"
                Inkey( 0.8 )
                CONTINUE
            ENDDO
            UNLOCK
            SELECT Hist
            SET ORDER TO 2
            GOTO TOP
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            ApFLock( 3 )
            SEEK mpartnum
            DO WHILE Found()
                Hist->Partnum := cnewpart
                ncount++
                @ 22, 10      SAY "History Part "
                @ 22, Col() + 1 SAY ncount PICTURE "999.99"
                Inkey( 0.8 )
                SEEK mpartnum
            ENDDO
            UNLOCK
            SELECT Prof
            GOTO TOP
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            ApFLock( 3 )
            LOCATE ALL FOR Partnum = mpartnum
            DO WHILE Found()
                Prof->Partnum := cnewpart
                ncount++
                @ 22, 10      SAY "Prof Part "
                @ 22, Col() + 1 SAY ncount PICTURE "999.99"
                Inkey( 0.8 )
                CONTINUE
            ENDDO
            UNLOCK
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            SELECT Supl
            GOTO TOP
            SET ORDER TO 1
            ApFLock( 3 )
            SEEK mpartnum
            DO WHILE Found()
                Supl->Partnum := cnewpart
                ncount++
                @ 22, 10      SAY "Supplier Part "
                @ 22, Col() + 1 SAY ncount PICTURE "999.99"
                Inkey( 0.8 )
                SEEK mpartnum
            ENDDO
            UNLOCK
            SELECT Quot
            GOTO TOP
            ApFLock( 3 )
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            LOCATE ALL FOR Partnum = mpartnum
            DO WHILE Found()
                Quot->Partnum := cnewpart
                ncount++
                @ 22, 10      SAY "Quot Part   "
                @ 22, Col() + 1 SAY ncount PICTURE "999.99"
                Inkey( 0.8 )
                CONTINUE
            ENDDO
            UNLOCK
            SELECT QuotInfo
            GOTO TOP
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            ApFLock( 3 )
            LOCATE ALL FOR Partnum = mpartnum
            DO WHILE Found()
                QuotInfo->Partnum := cnewpart
                ncount++
                @ 22, 10      SAY "Quot Info   "
                @ 22, Col() + 1 SAY ncount PICTURE "999.99"
                Inkey( 0.8 )
                CONTINUE
            ENDDO
            UNLOCK
            SELECT Labour
            GOTO TOP
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            ApFLock( 3 )
            DO WHILE Labour->( !Eof() )
                IF Labour->Partnum = mpartnum
                    Labour->Partnum := cnewPart
                    ncount++
                    @ 22, 10      SAY "Labour Part  "
                    @ 22, Col() + 1 SAY ncount PICTURE "999.99"
                    Inkey( 0.8 )
                ENDIF
                SKIP ALIAS Labour
            ENDDO
            UNLOCK
         /* Taken Out
         SELECT QuotStk
         ncount := 0
          ApFLock( 3 )
         LOCATE ALL FOR Partnum = mpartnum
         DO WHILE FOUND()
            QuotStk->Partnum := cnewpart
             @ 23, 6 SAY "QuotStk Part "+STR( ncount ) PICTURE "999.99"
             ncount++
             INKEY( 1 )
            CONTINUE
         ENDDO
         GOTO TOP
         LOCATE ALL FOR ModCode = TRIM( mpartnum )
         DO WHILE FOUND()
            QuotStk->ModCode := TRIM( cnewpart )
            CONTINUE
         ENDDO
         UNLOCK
         SELECT System
         GOTO TOP
          ApFLock( 3 )
         LOCATE ALL FOR ModCode = TRIM( mpartnum )
         DO WHILE FOUND()
            System->ModCode := TRIM( cnewpart )
            CONTINUE
         ENDDO
         UNLOCK
         */
            SELECT Orders
            SET ORDER TO 1         // Partnum
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            GOTO TOP
            SEEK mpartnum
            ApFLock( 3 )
            DO WHILE Found()
                Orders->Partnum := cnewpart
                ncount++
                @ 22, 10      SAY "Orders Part  "
                @ 22, Col() + 1 SAY ncount PICTURE "999.99"
                Inkey( 0.8 )
                SEEK mpartnum
            ENDDO
            UNLOCK
            SELECT PartOper
            GOTO TOP
            SEEK mpartnum
            ApFLock( 3 )
            DO WHILE Found()
                PartOper->Partnum := cnewpart
                SEEK mpartnum
            ENDDO
            UNLOCK
            ncount := 0
            @ 22, 6 SAY Space( 50 )
            SELECT EquCut
            ApFLock( 3 )
            GOTO TOP
            LOCATE ALL FOR Partnum = Trim( mpartnum )
            DO WHILE Found()
                EquCut->Partnum := Trim( cnewpart )
                ncount++
                @ 22, 10      SAY "Equ Cut Part  "
                @ 22, Col() + 1 SAY ncount PICTURE "999.99"
                @ 22, Col() + 2 SAY EquCut->ModSeqNo COLOR "G+"
                Inkey( 0.8 )
                CONTINUE
            ENDDO
            UNLOCK
            ncount := 0
            @ 22, 6 SAY Space( 50 )
            SELECT CusNotes
            ApFLock( 3 )
            SEEK mpartnum
            cnewpart := cnewpart + "    "            // In case 16
            DO WHILE Found()
                ncode := SubStr( Cusnotes->Code_Ref, 21, 2 )
                Cusnotes->Code_Ref := SubStr( cnewpart, 1, 20 ) + ncode
                ncount++
                @ 22, 10      SAY "Memo Part-  "
                @ 22, Col() + 1 SAY ncount PICTURE "999.99"
                Inkey( 0.8 )
                SEEK mpartnum
            ENDDO
            SELECT EquDesc
            GOTO TOP
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            SEEK Trim( mpartnum )
            IF Found()
                ApRLock( 3 )
                EquDesc->ModCode := Trim( cnewpart )
                ncount++
                @ 22, 10      SAY "Equ Desc Part  "
                @ 22, Col() + 1 SAY ncount PICTURE "999"
                @ 22, Col() + 2 SAY EquDesc->ModCode COLOR "G+"
                Inkey( 0.8 )
                UNLOCK
            ENDIF
            SELECT QuotStk
            SET ORDER TO 2
            GOTO TOP
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            SEEK Trim( mpartnum )
            IF Found()
                ApRLock( 3 )
                QuotStk->Partnum := Trim( cnewpart )
                ncount++
                @ 22, 10      SAY "QuotStk Part  "
                @ 22, Col() + 1 SAY ncount PICTURE "999"
                @ 22, Col() + 2 SAY QuotStk->Partnum COLOR "G+"
                QuotStk->ModPart := QuotStk->Modcode + QuotStk->Partnum
                Inkey( 0.8 )
                UNLOCK
            ENDIF
            SELECT LabCut
            GOTO TOP
            ncount := 0
            @ 22, 6 SAY Space( 30 )
            SEEK Trim( mpartnum )
            DO WHILE Found()
                ApRLock( 3 )
                LabCut->Partnum := Trim( cnewpart )
                ncount++
                @ 22, 10      SAY "Lab Cut"
                @ 22, Col() + 1 SAY ncount PICTURE "999"
                @ 22, Col() + 2 SAY LabCut->Partnum COLOR "G+"
                LabCut->Partnum := cnewpart
                UNLOCK
                Inkey( 0.8 )
                SEEK mpartnum
            ENDDO
            SELECT QuotStk
            ApFLock( 3 )
            GOTO TOP
            LOCATE ALL FOR ModCode = Trim( mpartnum )
            DO WHILE Found()
                QuotStk->ModCode := Trim( cnewpart )
                ncount++
                @ 22, 10      SAY "QuotStk Module"
                @ 22, Col() + 1 SAY ncount PICTURE "999.99"
                @ 22, Col() + 2 SAY QuotStk->Modcode COLOR "G+"
                QuotStk->ModPart := QuotStk->Modcode + QuotStk->Partnum
                Inkey( 0.8 )
                CONTINUE
            ENDDO
            UNLOCK
            SELECT Equ
            GOTO TOP
            ncount := 0
            @  3, 58 SAY "Changed Module" COLOR "G+"
            ApFLock( 3 )
            LOCATE ALL FOR Partnum = Trim( mpartnum )
            DO WHILE Found()
                Equ->Partnum := Trim( cnewpart )
                ncount++
                @ 22, 10      SAY "Equ Part  "
                @ 22, Col() + 1 SAY ncount PICTURE "999"
                @ 22, Col() + 2 SAY Equ->ModCode COLOR "G+"
                @ nl, 58      SAY Equ->ModCode COLOR "G+"
                @ nl, Col()   SAY ncount PICTURE "999"
                nl++
                // ***            INKEY( 0.8 )
                CONTINUE
            ENDDO
            UNLOCK
            @ 23, 10 SAY "Any Key to Continue"
            Inkey( 0 )
        ENDIF             // mcorrect
        // *****  Must also have DBF Use       DBFReIndx()// PRG
        mok := "N"
    ENDDO                // mok
    mpartnum := Part->Partnum

    RETURN mpartnum

// ** End of Partchange()

// *-------------------------------------------------------------------

STATIC FUNCTION PartRank( mpartnum )

    aPart_ := {}
    nrecno := 0
    SELECT Part
    SET EXACT OFF
    SET ORDER TO 1
    SEEK mpartnum
    IF Found()
        mpartnum := Part->Partnum
        RETURN mpartnum                     // Found Partnum
    ENDIF
    mpart  := Trim( mpartnum )
    FOR x = 1 TO Len( mpart )
        SEEK SubStr( mpart, 1, x )      // Tracer
    NEXT
    IF !Found()
        CatFind( @mpartnum )
    ENDIF
    IF Found()
        DO WHILE Part->Partnum = mpart .AND. Part->( !Eof() )
            IF Message->Mess09 = Space( 12 )
                AAdd( aPart_, SubStr( Part->Desc, 1,33 );
                    + " " + Str( Wholesale, 12, 2 ) + " " + Str( Part->Instock, 8, 0 );
                    + "  " + SubStr( Part->Partnum, 1, 11 );
                    + " " + Part->ABC + " " + Part->Unit + "     " + Str( RecNo(), 6 ) )
            ELSE
                AAdd( aPart_, ( SubStr( Part->Partnum, 1,14 );
                    + "  " + SubStr( Part->Desc, 1, 29 );
                    + " " + Str( Part->Instock, 10, 2 ) + " " + Str( Wholesale, 12, 2 );
                    + " " + Part->ABC + " " + SubStr( Part->Unit, 1, 8 );
                    + "      " + Str( RecNo(), 6 ) ) )
            ENDIF                       // Mess09
            SKIP ALIAS Part
        ENDDO                  // Part
        Scroll(  3, 0, 24, 80 )
        DispBox( 3, 1, 24, 79, 2 )
        IF Empty( aPart_ )
            CatFind( mpartnum )
        ELSE
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 2, 23, 78, aPart_,, "AFUNC" )
            IF LastKey() == -1

                PartAdd( @mpartnum )

                mpartnum := Part->Partnum
                SEEK mpartnum
                PartDets( @mpartnum )
                IF PressedEsc()
                    RETURN Space( 20 )
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                mpartnum := Part->Partnum
            ENDIF
            IF PressedEsc()
                RETURN NIL
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            mpartnum := Part->Partnum
            Scroll(  0, 0, 2, 80 )
            DispBox( 0, 1, 2, 79, 2 )
            @  1, 3 SAY Trim( mpartnum ) + " " + SubStr( Part->Desc, 1, 30 );
                + " " + Str( Part->Instock, 9, 0 ) + " " + Part->ABC
            RETURN mpartnum
        ENDIF                      // !Empty
    ENDIF                        // FOUND() by Input SUBSTR Part

    RETURN mpartnum

// ***  End of PartRank()

// *-------------------------------------------------------------------

FUNCTION PartView()

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        nrecno := 0
        Scroll()
        mcodeno  := Space( 8 )
        mpartnum := Space( 16 )

        Partfind( @mpartnum, mcodeno )                        // Below

        IF PressedEsc()
            RETURN NIL
        ENDIF
        SELECT Part
        SET ORDER TO 1
        SEEK mpartnum
        mpartnum := Part->Partnum

        PartDets( @mpartnum )                         // CWP2

        IF PressedEsc()
            RETURN NIL
        ENDIF

        mcontinue := "N"
    ENDDO

    mpartnum := Space( 20 )

    RETURN NIL

// *** End of Partview

// *-------------------------------------------------------------------

STATIC FUNCTION CatFind( mpartnum )

    aPart_ := {}
    mpart  := Trim( mpartnum )
    nrecno := 0
    mok    := "N"
    IF LastRec() == 0

        Partadd( @mpartnum )         // Below

        mpartnum := Part->Partnum
        RETURN mpartnum
    ENDIF
    SELECT Part
    SET ORDER TO 3                  // PartId+Desc
    SET EXACT OFF
    IF LastRec() != 0
        FOR x = 1 TO Len( mpart )
            SEEK SubStr( mpart, 1, x )      // Tracer
        NEXT
        SEEK mpart
        IF Found()
            DO WHILE Part->PartId = mpart .AND. Part->( !Eof() )
                IF Message->Mess09 = Space( 12 )
                    AAdd( aPart_, ( Part->Desc;
                        + " " + Str( Part->Instock, 8, 2 ) + " " + Str( Wholesale, 8, 2 );
                        + "  " + SubStr( Part->Partnum, 1, 10 );
                        + "   " + Str( RecNo(), 6 ) ) )
                ELSE
                    AAdd( aPart_, ( SubStr( Part->Partnum, 1,12 );
                        + "  " + SubStr( Part->Desc, 1, 29 );
                        + " " + Str( Part->Instock, 8, 2 ) + " " + Str( Wholesale, 12, 2 );
                        + " " + Part->ABC + " " + Part->Unit + "      " + Str( RecNo(), 6 ) ) )
                ENDIF
                SKIP ALIAS Part
            ENDDO
            // **      IF Message->Mess09 = SPACE( 12 )
            ASort( aPart_,,, {| x, y | x < y } )
            // **      ENDIF
        ENDIF                        // FOUND()
        Scroll(  3, 0, 24, 80 )
        DispBox( 3, 1, 24, 79, 2 )
        IF !Empty( aPart_ )
            anum := AChoice( 4, 3, 23, 76, aPart_,, "AFUNC" )
            IF LastKey() == -1

                PartAdd( mpartnum )                  // Below
                mpartnum := Part->Partnum
                DO CASE
                CASE SubStr( Part->Partnum, 1, 3 ) = "JC-"
                    RETURN mpartnum
                CASE SubStr( Part->Partnum, 1, 3 ) = "QU-"
                    RETURN mpartnum
                CASE SubStr( Part->Partnum, 1, 3 ) = "TEM"
                    RETURN mpartnum
                CASE SubStr( Part->Partnum, 1, 3 ) = "ZZT"
                    RETURN mpartnum
                CASE SubStr( Part->Partnum, 1, 3 ) = "TT-"
                    RETURN mpartnum
                ENDCASE
                SELECT Part
                SET ORDER TO 1
                SEEK mpartnum
                mpartnum := Part->Partnum

                PartDets( @mpartnum )    // CWP2

            ENDIF
            IF PressedEsc()
                RETURN NIL
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            mpartnum := Part->Partnum
        ENDIF
        Scroll(  1, 6, 1, 74 )
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 4 SAY Trim( mpartnum ) + " " + SubStr( Part->Desc, 1, 30 );
            + " " + Str( Part->Instock, 9, 0 ) + "  " + Part->ABC  // COLOR c_hicolor
    ENDIF

    RETURN mpartnum

// ***----- End of CatFind()

// *-------------------------------------------------------------------

STATIC FUNCTION PartGet( ccatno )

    aPart_ := {}
    nrecno := 0
    IF LastRec() != 0
        DO WHILE Part->Catno == ccatno
            IF Message->Mess09 = Space( 12 )
                AAdd( aPart_, Part->Desc;
                    + " " + Str( Wholesale, 9, 2 ) + " " + Str( Part->Instock, 9, 0 );
                    + " " + Part->Partnum + "    " + Str( RecNo(), 6 ) )
            ELSE
                AAdd( aPart_, ( SubStr( Part->Partnum, 1,12 );
                    + "  " + SubStr( Part->Desc, 1, 29 );
                    + " " + Str( Part->Instock, 8, 2 ) + " " + Str( Wholesale, 12, 2 );
                    + " " + Part->ABC + " " + Part->Unit + "        " + Str( RecNo(), 6 ) ) )
            ENDIF
            SKIP ALIAS Part
        ENDDO
        ASort( aPart_,,, {| x, y | x < y } )
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 6 SAY Trim( ccatno ) + "  " + Cat->CatDesc     // COLOR c_hicolor
        DispBox( 3, 0, 24, 79, 2 )
        IF !Empty( aPart_ )
            anum := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
            IF LastKey() == -1

                PartAdd( @mpartnum )

                mpartnum := Part->Partnum
                SEEK mpartnum
                PartDets( @mpartnum )
            ENDIF
            IF PressedEsc()
                RETURN Space( 20 )
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            mpartnum := Part->Partnum
        ENDIF
    ENDIF

    RETURN mpartnum

// *** End of PartGet()

// *-------------------------------------------------------------------

FUNCTION Suppliers( mpartnum )

    tempscr := SaveScreen(  0, 0, 24, 80 )
    mcodeno := Space( 8 )
    SELECT Supl
    SET ORDER TO 1                       // Codeno Index
    aPart_ := {}
    IF LastRec() != 0
        GO TOP
        SEEK mpartnum
        DO WHILE Supl->Partnum = mpartnum .AND. Supl->( !Eof() )
            SELECT Name
            SEEK Supl->Codeno
            SELECT Supl
            AAdd( aPart_, ( Name->Name + "  " + Str( Supl->Cost );
                + " " + DToC( Supl->Date ) + "    " + Str( RecNo(), 6 ) ) )
            SKIP ALIAS Supl
        ENDDO                         // Supl Partnum
        ASort( aPart_,,, {| x, y | x < y } )
        Scroll(  3, 0, 24, 80 )
        DispBox( 3, 1, 24, 79, 2 )
        IF !Empty( aPart_ )
            // **         @  3, 0 SAY " "
            // **         AEVAL( aPart_,{ |A|QOUT( "   "+CHR( 186 )+"  " );
            // **                          ,QQOUT(A),BreakTot() } )
            // **         INKEY( 1 )
            anum := AChoice( 4, 10, 23, 66, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            mcodeno := Supl->Codeno
            SELECT Name
            SEEK mcodeno
        ENDIF                             // !EMPTY
    ENDIF                                    // LastRec()
    mok := "Y"
    DO WHILE mok = "Y"
        Scroll()
        DispBox( 0, 1,  2, 79, 2 )
        @  1, 10 SAY mpartnum + " " + Part->Desc
        DispBox( 3, 1, 19, 79, 2 )
        SELECT Supl
        SET ORDER TO 1              // Partnum+Codeno
        SEEK mpartnum + mcodeno
        IF Found()
            @  5, 7 SAY mcodeno + "  " + Name->Name
            @  7, 23 SAY "Cost : "
            @  7, 32 SAY Supl->Cost PICTURE "99999.99"
            @  7, 46 SAY "Part Cost : "
            @  7, 58 SAY Part->Trade
            @  9, 18 SAY "Last Price"
            @  9, 33 SAY Supl->LastCost
            @ 11, 11 SAY "Suppliers Partnum    " + Supl->SuppId
            @ 13, 17 SAY "Information "
            @ 13, 33 SAY Supl->Info
            @ 15, 18 SAY "Pref Supl"
            @ 15, 33 SAY Part->Codeno
            @ 17, 22 SAY "Date"
            @ 17, 33 SAY Supl->Date
            // **       @ 17,COL()+2 SAY "Lead Time "+STR( Supl->LeadTime )
        ENDIF                        // Found
        Scroll(  20, 0, 24, 80 )
        DispBox( 20, 1, 24, 79, 2 )
        nsel := 1
        @ 22, 3      PROMPT "Detail"
        @ 22, Col() + 2 PROMPT "Add New"
        @ 22, Col() + 2 PROMPT "Supply Hist"
        @ 22, Col() + 2 PROMPT "Use Hist"
        @ 22, Col() + 2 PROMPT "Operations"
        @ 22, Col() + 2 PROMPT "Where Used"
        @ 22, Col() + 2 PROMPT "Delete Supl"
        @ 24, 60 SAY " DT3?  "
        MENU TO nsel
        DO CASE
        CASE PressedEsc()
            RETURN mpartnum
        CASE nsel = 1                                       // Details
            ApRLock( 3 )
            mcost := Supl->Cost
            @  7, 32 GET Supl->Cost   PICTURE "99999.99"
            Supl->LastCost := Supl->Cost
            Supl->Date := Date()
            @ 11, 32      GET Supl->SuppId PICTURE "@K!"
            @ 13, 32      GET Supl->Info   PICTURE "@KX"
            @ 17, 33      SAY Supl->Date
            @ 17, Col() + 2 GET Supl->Codeno
            READ
            UNLOCK
            SELECT Part
            mcodeno := Part->Codeno
            @ 15, 32 GET mcodeno PICTURE "@!"
            READ
            ApRLock( 3 )
            Part->Codeno := mcodeno
            UNLOCK
            LOOP
        CASE nsel == 2                         // Add New
            tempscreen := SaveScreen(  0, 0, 24, 80 )
            NameRank( @mcodeno )
            mcodeno := Name->Codeno
            RestScreen( 0, 0, 24, 80, tempscreen )
            mcorrect := "N"
            DO WHILE mcorrect == "N"
                SELECT Supl
                LOCATE FOR Supl->Partnum == mpartnum .AND. Supl->Codeno == mcodeno
                IF !Found()
                    SELECT Supl
                    ApRLock( 3 )
                    APPEND BLANK
                    Supl->Partnum := Part->Partnum
                    Supl->SuppId  := Part->Partnum
                    Supl->Codeno  := mcodeno
                    Supl->Cost    := Part->Trade
                    UNLOCK
                ENDIF
                SELECT Supl
                ApRLock( 3 )
                Supl->Date := Date()
                @  5, 7 SAY Name->Codeno + "  " + Name->Name
                @  7, 23 SAY "Cost : "          GET Supl->Cost PICTURE "99999.99"
                @  7, 46 SAY "Part Cost : "
                @  7, 58 SAY Part->Trade
                @  9, 18 SAY "Last Price"
                @  9, 32 SAY Supl->LastCost
                @ 11, 11 SAY "Suppliers Partnum" GET Supl->SuppId PICTURE "@K!"
                @ 13, 17 SAY "Information"       GET Supl->Info   PICTURE "@KX"
                // **              @ 13,32 SAY Supl->Info
                // **              @ 15,18 SAY "Pref Supl"
                @ 15, 32 SAY Part->Codeno
                @ 17, 22 SAY "Date : "
                @ 17, 33 SAY Supl->Date
                // **              @ 17,COL()+2 SAY "Lead Time"   GET Supl->LeadTime PICTURE "999.99"
                READ
                Supl->LastCost := Supl->Cost
                UNLOCK
                SELECT Part
                mcodeno := Part->Codeno
                @ 15, 32 GET mcodeno PICTURE "@!"
                READ
                ApRLock( 3 )
                Part->Codeno := mcodeno
                UNLOCK
                mcorrect := "Y"
            ENDDO                                              // mcorrect
            mok = "N"

        CASE nsel = 3                                   // Supply
            ProfSupply( mcodeno, mpartnum )
        CASE nsel = 4                                   // Equip
            SAVE SCREEN TO Tempscrn
            HistPart( mpartnum )                  // XF_Hist
            RESTORE SCREEN FROM Tempscrn
        CASE nsel = 5
            PartOper2( mpartnum )                // XF2PPART
        CASE nsel = 6
            PartUsed( mpartnum )
            Inkey( 0 )
        CASE nsel = 7                                   // Delete
            mok := ApGetN( Trim( Message->Delete ) + " This Supplier " )
            IF mok == "Y"
                SELECT Supl
                ApRLock( 3 )
                DELETE
                UNLOCK
            ENDIF                            // mok
            mok := "N"
        ENDCASE                                        // Supplier End Case
    ENDDO                                      // mok

    RestScreen( 0, 0, 24, 80, tempscr )

    RETURN mpartnum

// **----- End Suppliers

// *---------------------------------------------------------------------*

STATIC FUNCTION ProfSupply( mcodeno, mpartnum )

    nl  := 4
    npl := 20
    Scroll(  3, 0, 24, 80 )
    DispBox( 3, 1, 24, 79, 2 )
    @ nl, 6 SAY "Codeno       Qty        Cost  Discount      Amount   Date      Ordnum"
    nl += 2
    navercost := ncnt := 0
    SELECT ProfNat
    SET ORDER TO 2                          // Partnum Index
    GOTO TOP
    SEEK mpartnum
    DO WHILE ProfNat->Partnum = mpartnum .AND. ProfNat->( !Eof() )
        IF nl > npl
            nl++
            @ nl, 10 SAY "Any Key to Return"
            Inkey( 0 )
            nl := 4
            Scroll(  4, 6, 23, 74 )
        ENDIF
        @ nl, 6      SAY ProfNat->Codeno
        @ nl, Col() + 2 SAY ProfNat->Qty      PICTURE "99,999"
        @ nl, Col() + 2 SAY ProfNat->Cost     PICTURE "9999,999.99"
        @ nl, Col() + 2 SAY ProfNat->Discount PICTURE "9999.99"
        @ nl, Col() + 2 SAY ProfNat->Amount   PICTURE "9999,999.99"
        @ nl, Col() + 2 SAY ProfNat->Pdate
        @ nl, Col() + 2 SAY ProfNat->Ordnum
        // **   @ nl,COL()+2 SAY ProfNat->QRate
        ncnt++
        navercost += ProfNat->Cost
        // **   @ nl,COL()+3 SAY SUBSTR( ProfNat->Partnum, 1,10 )
        nl++
        SKIP ALIAS ProfNat
    ENDDO                        // ProNat EOF()
    nl += 2
    @ nl, 8 SAY "Not Incl Discount Average Cost ="
    @ nl, 44 SAY navercost / ncnt PICTURE "$999,999.99"
    nl += 2
    SELECT ProfNat
    SET ORDER TO 1
    SELECT Part
    ntrade     := Part->Trade
    nwholesale := Part->Wholesale
    @ nl, 20 SAY "Cost =" GET ntrade     PICTURE "999999.99"
    @ nl, 40 SAY "Sell =" GET nwholesale PICTURE "999999.99"
    READ
    ApRLock( 3 )
    Part->Trade     := ntrade
    Part->Wholesale := nwholesale
    UNLOCK

    RETURN mpartnum

// ****----- End ProfSupply

// ******---------------  END OF FILE XF_PART.PRG
