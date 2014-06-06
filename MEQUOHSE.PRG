// ** JK  27-10-10 20:19:53

/*
   Program.....:                MEQUOHSE.PRG
   Authors.....: J.Kirby
   Date........: 02/08/2001
   Functions...: MEuoLook, MEuotSearch, MEuotEdit, MEuotPAdd

   THIS IS THE PART NUMBER SYSTEM
*/

// (c) Copyright 1993 by Kirby Christchurch.

FUNCTION MEuoLook()

    aPart_ := {}
    SELECT QuotInfo
    GOTO TOP
    IF LastRec() != 0
        SEEK mcodeno
        DO WHILE QuotInfo->Codeno = mcodeno .AND. QuotInfo->( !Eof() )
            IF QuotInfo->Invno != Space( 6 )
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            mpartnum := QuotInfo->Partnum
            SELECT Part
            SEEK mpartnum
            SELECT QuotInfo
            AAdd( aPart_, Part->Desc;
                + " " + DToC( QuotInfo->DbDate );
                + " " + QuotInfo->Info;
                + "      " + Str( RecNo(), 6 ) )
            SKIP ALIAS QuotInfo
        ENDDO
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 4      SAY Trim( Name->Name )
        @  1, Col() + 2 SAY Trim( Name->Called )
        @  1, Col() + 1 SAY Trim( Name->Famname )
        DispBox( 3, 1, 23, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            // **      @  3,00 SAY " "
            // ***      AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " ),QQOUT(A),Breakpoint() } )
            anum := AChoice( 4, 3, 22, 78, aPart_,, "AFUNC" )
            IF PressedEsc()
                RETURN mcodeno
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            SELECT QuotInfo
            GOTO nrecno
            mcodeno    := QuotInfo->Codeno
            mpartnum   := QuotInfo->Partnum
            dDbdate    := QuotInfo->DbDate
            Quotcodeno := QuotInfo->Codeno
        ENDIF
    ENDIF

    RETURN NIL
// ***---- End of MEuoLook()

// *-------------------------------------------------------------------

FUNCTION MEuotSearch()

    mcodeno := Space( 8 )
    SELECT QuotInfo
    mtempcode := "A       "
    GOTO TOP
    SEEK mtempcode
    IF !Found()
        ApRLock( 3 )
        APPEND BLANK
        QuotInfo->Codeno := "A      "
        QuotInfo->Invno  := "9     "
        UNLOCK
    ENDIF
    aPart_ := anum := {}
    nrecno := 0
    maccepted := "N"
    Scroll()
    DispBox( 0, 45, 3, 75, 2 )
    @  1, 47 SAY "Select Name"
    SELECT QuotInfo
    IF LastRec() = 0
        @ 7, 53 SAY "NO Name Information"
        Inkey( 2 )
        RETURN NIL
    ENDIF
    IF LastRec() != 0
        GOTO TOP
        mtempno := Space( 8 )
        DO WHILE QuotInfo->( !Eof() )
            IF SubStr( QuotInfo->Invno, 2, 2 ) != Space( 2 ) // Allow for 9
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            IF QuotInfo->Codeno = mtempno
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            SELECT Name
            SEEK QuotInfo->Codeno
            SELECT QuotInfo
            mtempno := QuotInfo->Codeno
            AAdd( aPart_, Name->Name;
                + "  " + Name->Sale;
                + "      " + Str( RecNo(), 6 ) )
            SKIP ALIAS QuotInfo
        ENDDO
        DispBox( 0, 1, 24, 42, 2 )
        @ 22, 45 SAY Trim( Message->Select )
        @ 24, 45 SAY Trim( Message->Esc )
        @ 12, 47 SAY "F2 To View ALL Info"     COLOR "GB+"
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 1, 3, 23, 40, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF LastKey() == -1
                aPart_ := anum := {}
                nrecno := 0
                SELECT QuotInfo
                GOTO TOP
                DO WHILE QuotInfo->( !Eof() )
                    IF QuotInfo->Partnum = Space( 20 )
                        SKIP ALIAS QuotInfo
                        LOOP
                    ENDIF
                    SELECT Name
                    SEEK QuotInfo->Codeno
                    SELECT Part
                    SET ORDER TO 1                    // Partnum
                    SEEK QuotInfo->Partnum
                    SELECT QuotInfo
                    AAdd( aPart_, SubStr( QuotInfo->Partnum, 1,16 );
                        + " " + SubStr( Part->Desc, 1, 25 );
                        + " " + QuotInfo->Info;
                        + "      " + Str( RecNo(), 6 ) )
                    SKIP ALIAS QuotInfo
                ENDDO
                Scroll()
                DispBox( 0, 1, 24, 79, 2 )
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice( 1, 3, 23, 78, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    // **          MEuotAdd()                    // MEQuot
                    // **          MEuotSearch()                 // MEQuot
                ENDIF
            ENDIF
        ENDIF
        GOTO nrecno
        IF QuotInfo->Codeno = "A       "
            MEuotAdd()                      // MEQuot
            MEuotSearch()                   // MEQuot
        ENDIF                 // Codeno = A
        mcodeno    := QuotInfo->Codeno
        dDbdate    := QuotInfo->DbDate
        Quotcodeno := QuotInfo->Codeno
        SELECT Name
        SEEK mcodeno
        SELECT QuotInfo
        MEuotEdit( mcodeno )               // MEQuoHse
    ENDIF
    IF mcodeno != Space( 8 )
        MEuotSearch()                       // MEQuoHse
    ENDIF

    RETURN NIL
// ***---- End of MEuotSearch()

// *-------------------------------------------------------------------

FUNCTION MEuotEdit()

    QuotCodeno := Name->Codeno
    mpartnum := Space( 20 )
    mcontinue = "Y"
    DO WHILE mcontinue = "Y"
        aPart_ := {}
        nrecno := 0
        SELECT QuotInfo
        GOTO TOP
        mcodeno := Name->Codeno
        SEEK mcodeno
        DO WHILE QuotInfo->Codeno = mcodeno .AND. QuotInfo->( !Eof() )
            IF QuotInfo->Invno != Space( 6 )
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            SELECT Part
            SEEK QuotInfo->Partnum
            SELECT QuotInfo
            AAdd( aPart_, SubStr( QuotInfo->Partnum, 1,16 );
                + " " + SubStr( Part->Desc, 1, 25 );
                + " " + QuotInfo->Info;
                + "      " + Str( RecNo(), 6 ) )
            SKIP ALIAS QuotInfo
        ENDDO
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 4      SAY Trim( Name->Name )
        @  1, Col() + 2 SAY Trim( Name->Called )
        @  1, Col() + 1 SAY Trim( Name->Famname )
        DispBox( 3, 1, 24, 79, 2 )
        Quotcodeno := Space( 8 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
            IF PressedEsc()
                RETURN mcodeno
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            SELECT QuotInfo
            GOTO nrecno
            mpartnum   := QuotInfo->Partnum
            dDbdate    := QuotInfo->DbDate
            Quotcodeno := QuotInfo->Codeno
            SELECT Part
            SEEK mpartnum
        ENDIF
        Scroll(   3, 0, 24, 80 )
        DispBox(  3, 1, 21, 79, 2 )
        @  4, 4      SAY Trim( QuotInfo->Partnum )
        @  4, Col() + 2 SAY Part->Desc  COLOR "BG+"
        @  6, 4      SAY QuotInfo->Info
        @  7, 4      SAY QuotInfo->Info2
        @  8, 4      SAY QuotInfo->Info3
        @  9, 4      SAY QuotInfo->Info4
        @ 10, 4      SAY QuotInfo->Info5
        @ 11, 4      SAY QuotInfo->Info6
        coderef := QuotInfo->Faxno
        MemoDisp( coderef )        // XF-Memo2
        nselect := 1
        DispBox(  22, 1, 24, 79, 2 )
        @ 23, 4      PROMPT "Edit"
        @ 23, Col() + 2 PROMPT "Add Info"
        @ 23, Col() + 2 PROMPT "Info Form"
        @ 23, Col() + 2 PROMPT "Print"
        @ 23, Col() + 2 PROMPT "Delete Info"
        @ 23, Col() + 2 PROMPT "Part Edit"
        @ 23, Col() + 2 PROMPT "Exit"
        MENU TO nselect
        DO CASE
        CASE nselect == 7 .OR. PressedEsc()
            RETURN mcodeno
        CASE nselect == 1
            MEuotPrice( @mpartnum )         // MEQuoHse
            MEuotEdit( @mcodeno )           // MEQuoHse
            LOOP
        CASE nselect == 2
            dDbdate := Date()
            mpartnum := Space( 20 )
            MEuotPAdd( mpartnum )          // MEQuoHse
            LOOP
        CASE nselect == 3
            tempscrn := SaveScreen( 0, 0, 24, 80 )
            MEuotJSheet( mcodeno )               // Above
            RestScreen(  0, 0, 24, 80, tempscrn )
            mcontinue := "Y"
            LOOP
        CASE nselect == 4
            tempscrn := SaveScreen( 0, 0, 24, 80 )
            MEuotindi( @mcodeno )
            RestScreen(  0, 0, 24, 80, tempscrn )
            mcontinue := "Y"
            LOOP
        CASE nselect == 5
            mok := ApGetN( Trim( Message->Delete ) + " Information" )
            IF mok == "Y"
                SELECT CusNotes
                ApFLock( 3 )
                DELETE ALL FOR SubStr( Code_Ref, 1, 20 );
                    = QuotInfo->Codeno + Trim( QuotInfo->Partnum )
                UNLOCK
                SELECT QuotInfo
                ApFLock( 3 )
                DELETE ALL FOR QuotInfo->Partnum = mpartnum
                UNLOCK
            ENDIF                            // mok
            mcontinue := "Y"
            LOOP
        CASE nselect == 6
            tempscrn := SaveScreen( 0, 0, 24, 80 )
            mpartnum := Part->Partnum
            Quotcodeno := Name->Codeno
            MEProfQty()                        // MEParDet
            SELECT Name
            SEEK Quotcodeno
            mcodeno := Name->Codeno
            RestScreen(  0, 0, 24, 80, tempscrn )
            mcontinue := "Y"
            LOOP
        ENDCASE
        mcontinue = "N"
    ENDDO                       // mcontinue

    RETURN mpartnum

// **-----End of MEuotEdit()

// *-------------------------------------------------------------------

FUNCTION MEuotPAdd( mpartnum )

    Quotcodeno := Name->Codeno
    IF mpartnum = Space( 20 )
        SELECT Part
        SET ORDER TO 1
        Scroll()
        Partfind( @mpartnum )                // XlF_Part
        mpartnum := Part->Partnum
    ENDIF                            // mpartnum
    SELECT Name
    SEEK Quotcodeno
    mcodeno := Name->Codeno
    SELECT Part
    SET ORDER TO 1                  // Partnum
    SEEK mpartnum
    // **   IF FOUND()
    SELECT QuotInfo
    ApFLock( 3 )
    APPEND BLANK
    QuotInfo->Partnum  := mpartnum
    QuotInfo->Catno    := Part->Catno
    QuotInfo->Codeno   := Name->Codeno
    QuotInfo->Dbdate   := Date()
    QuotInfo->Duedate  := Date()
    QuotInfo->Faxno    := SubStr( mpartnum, 1, 8 ) + Name->Codeno + LTrim( Str( LastRec(),4 ) )
    UNLOCK
    MEuotPrice( @mpartnum )                         // MEQuot
    // **    ELSE
    // **      SCROLL()
    // **   ENDIF

    RETURN mpartnum

// ***---- End of MEuotPAdd()

// ****------------------- END OF File MEQuoHse.PRG
