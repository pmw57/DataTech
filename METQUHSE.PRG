// ** JK  26-03-10 14:27:50

/*
   Program.....:                METQUHSE.PRG
   Authors.....: J.Kirby
   Date........: 02/08/2001
   Functions...: METuoLook, METuotSrch, METuotEdit, METuotPAdd
   Not used....: InfoAdd

   INVOICE SYSTEM
*/

// (c) Copyright 1993 by Chozen Ltd Christchurch.

FUNCTION InfoAdd()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll( 3, 0, 24, 80 )
        // **        SELECT QuotInfo
        // **        SEEK Debit->Codeno
        // **        IF FOUND()
        aPart_ := {}
        SELECT QuotInfo
        GOTO TOP
        IF LastRec() != 0
            SEEK Debit->Codeno
            DO WHILE QuotInfo->Codeno = Debit->Codeno .AND. QuotInfo->( !Eof() )
                IF QuotInfo->Invno != Debit->Invno
                    SKIP ALIAS QuotInfo
                    LOOP
                ENDIF
                AAdd( aPart_, QuotInfo->Invno;
                    + " " + Debit->Est;
                    + " " + DToC( QuotInfo->DbDate );
                    + " " + QuotInfo->Info;
                    + "      " + Str( RecNo(), 6 ) )
                SKIP ALIAS QuotInfo
            ENDDO
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            SELECT Name
            SEEK Debit->Codeno
            @  1, 4      SAY Trim( Name->Name )
            @  1, Col() + 2 SAY Trim( Name->Called )
            @  1, Col() + 1 SAY Trim( Name->Famname )
            DispBox( 3, 1, 22, 79, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 4, 3, 21, 78, aPart_,, "AFUNC" )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                SELECT QuotInfo
                GOTO nrecno
                Scroll(  10, 0, 24, 80 )
                DispBox( 10, 1, 22, 79, 2 )
                @ 12, 4      SAY Part->Partnum
                @ 12, Col() + 2 SAY Part->Desc  COLOR "BG+"
                @ 14, 4      SAY QuotInfo->Info
                @ 15, 4      SAY QuotInfo->Info2
                @ 16, 4      SAY QuotInfo->Info3
                @ 17, 4      SAY QuotInfo->Info4
                @ 18, 4      SAY QuotInfo->Info5
                @ 19, 4      SAY QuotInfo->Info6
            ENDIF   // Empty
        ENDIF      // LastRec
        // ** ENDIF      // Found
        DispBox( 22, 1, 24, 79, 2 )
        nselect := 1
        @ 23, 4      PROMPT "Add Information"
        @ 23, Col() + 2 PROMPT "Edit Inform"
        @ 23, Col() + 2 PROMPT "Delete"
        @ 23, Col() + 2 PROMPT "Another"
        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nselect == 1
            SELECT QuotInfo
            ApFLock( 3 )
            APPEND BLANK
            QuotInfo->Codeno   := Debit->Codeno
            QuotInfo->Dbdate   := Date()
            QuotInfo->Duedate  := Date() + 20
            QuotInfo->Faxno    := Debit->Invno + Name->Codeno + LTrim( Str( LastRec(), 4 ) )
            QuotInfo->Invno    := Debit->Invno
            UNLOCK
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
            SELECT Cusnotes
            coderef := QuotInfo->Faxno
            SEEK coderef
            M2MemoFile( coderef )                      // XF_Memo2
            mok := ApGetN( Trim( Message->Delete ) + " Memo" )
            IF mok == "Y"
                SELECT Cusnotes
                SEEK coderef
                ApFLock( 3 )
                DO WHILE Found()
                    DELETE
                    SEEK coderef
                ENDDO
                UNLOCK
            ENDIF                  // mok
            LOOP

        CASE nselect == 2    // Edit
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            SELECT Name
            SEEK Debit->Codeno
            @  1, 4      SAY Trim( Name->Name )
            @  1, Col() + 2 SAY Trim( Name->Called )
            @  1, Col() + 1 SAY Trim( Name->Famname )
            DispBox( 3, 1, 24, 79, 2 )
            nl := 4
            @ nl, 3 SAY Debit->Invno + " " + Debit->Est + "  " + Debit->Codeno COLOR "BG+"
            nl++
            SELECT QuotInfo
            ApRLock( 3 )
            @ nl, 4 SAY "Blank Line 1 Deletes Information"
            nl++
            @ nl, 4      SAY "Memo        " GET QuotInfo->Info
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
            SELECT Cusnotes
            coderef := QuotInfo->Faxno
            SEEK coderef
            M2MemoFile( coderef )                      // XF_Memo2
            mok := ApGetN( Trim( Message->Delete ) + " Memo" )
            IF mok == "Y"
                SELECT Cusnotes
                SEEK coderef
                ApFLock( 3 )
                DO WHILE Found()
                    DELETE
                    SEEK coderef
                ENDDO
                UNLOCK
            ENDIF                  // mok
            SELECT QuotInfo
            ApFLock( 3 )
            IF SubStr( QuotInfo->Info, 1, 6 ) = Space( 6 )
                DELETE
            ENDIF
            UNLOCK
            LOOP
        CASE nselect == 3
            mok := ApGetN( Trim( Message->Delete ) + " All JC Information" )
            IF mok == "Y"
                SELECT Cusnotes
                GOTO TOP
                ApFLock( 3 )
                DO WHILE Cusnotes->( !Eof() )
                    IF SubStr( Code_Ref, 9, 6 ) != minvno
                        SKIP ALIAS Cusnotes
                        LOOP
                    ENDIF
                    DELETE
                    SKIP ALIAS Cusnotes
                ENDDO
                UNLOCK
                SELECT QuotInfo
                GOTO TOP
                DO WHILE QuotInfo->( !Eof() )
                    IF QuotInfo->Invno != Debit->Invno
                        SKIP ALIAS QuotInfo
                        LOOP
                    ENDIF
                    ApRLock( 3 )
                    DELETE
                    UNLOCK
                    SKIP ALIAS QuotInfo
                ENDDO
            ENDIF                            // mok
            mcontinue := "Y"
            LOOP
        CASE nselect == 4                     // Qty Desc
            LOOP
        ENDCASE
        mcontinue := "N"
    ENDDO                                   // mcontinue

    RETURN NIL
// ***----- End of InfoAdd()

// **--------------------------------------------------------------------------

FUNCTION METuoLook()

    aPart_ := {}
    SELECT QuotInfo
    GOTO TOP
    IF LastRec() != 0
        DO WHILE QuotInfo->( !Eof() )
            IF QuotInfo->Invno = Space( 6 )
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            SELECT Debit
            SET ORDER TO 2                  // Invno
            SEEK QuotInfo->Invno
            SET ORDER TO 1                  // Codeno
            SELECT QuotInfo
            AAdd( aPart_, QuotInfo->Invno;
                + " " + QuotInfo->Info;
                + "  " + Debit->Est;
                + " " + DToC( QuotInfo->DbDate );
                + "      " + Str( RecNo(), 6 ) )
            SKIP ALIAS QuotInfo
        ENDDO
        Scroll()
        DispBox( 0, 1, 24, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            // **      @  3,00 SAY " "
            // ***      AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " ),QQOUT(A),Breakpoint() } )
            anum := AChoice( 1, 3, 23, 78, aPart_,, "AFUNC" )
            IF PressedEsc()
                RETURN mcodeno
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            SELECT QuotInfo
            GOTO nrecno
        ENDIF
    ENDIF

    RETURN NIL
// ***---- End of METuoLook()

// *-------------------------------------------------------------------

FUNCTION METuotSrch()

    aPart_ := anum := {}
    nrecno := 0
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
                + "  " + QuotInfo->Info;
                + "  " + QuotInfo->Codeno;
                + "            " + Str( RecNo(), 6 ) )
            SKIP ALIAS QuotInfo
        ENDDO
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 3 SAY "All JC- Information List"
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

        METuotEdit()               // METQuHse

    ENDIF

    RETURN NIL
// ***---- End of METuotSrch()

// *-------------------------------------------------------------------

FUNCTION METuotEdit()

    minvno := QuotInfo->Invno
    SELECT Name
    SEEK QuotInfo->Codeno
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        aPart_ := {}
        nrecno := 0
        SELECT QuotInfo
        GOTO TOP
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
            SEEK QuotInfo->Invno
            SET ORDER TO 1                        // Codeno
            SELECT QuotInfo
            AAdd( aPart_, Debit->Invno;
                + " " + QuotInfo->Info;
                + " " + Debit->Est;
                + "       " + Str( RecNo(), 6 ) )
            SKIP ALIAS QuotInfo
        ENDDO
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 10 SAY Name->Name
        DispBox( 3, 1, 24, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 2, 23, 78, aPart_,, "AFUNC" )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            SELECT QuotInfo
            GOTO nrecno
            SELECT Debit
            SET ORDER TO 2                        // Invno
            SEEK QuotInfo->Invno
            SET ORDER TO 1
        ENDIF
        Scroll(   3, 0, 24, 80 )
        DispBox(  3, 1, 24, 79, 2 )
        @  4, 4      SAY QuotInfo->Invno
        @  4, Col() + 2 SAY Debit->Est + "  " + QuotInfo->Codeno   COLOR "BG+"
        @  6, 4      SAY QuotInfo->Info
        @  7, 4      SAY QuotInfo->Info2
        @  8, 4      SAY QuotInfo->Info3
        @  9, 4      SAY QuotInfo->Info4
        @ 10, 4      SAY QuotInfo->Info5
        @ 11, 4      SAY QuotInfo->Info6
        coderef := QuotInfo->Faxno
        MemoDisp( coderef )   // XF-Memo2
        nselect := 1
        DispBox( 22, 1, 24, 79, 2 )
        @ 23, 4      PROMPT "Edit"
        @ 23, Col() + 2 PROMPT "Add Info"
        @ 23, Col() + 2 PROMPT "Info Form"
        @ 23, Col() + 2 PROMPT "Delete Info"

        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nselect == 1
            METuotPrice()                    // METQuot
            METuotEdit()                     // METQuHse
            LOOP
        CASE nselect == 2
            METuotPAdd()                    // METQuHse
            LOOP
        CASE nselect == 3
            tempscrn := SaveScreen( 0, 0, 24, 80 )
            METuotJSheet()                     // MetQuot
            RestScreen(  0, 0, 24, 80, tempscrn )
            mcontinue := "Y"
            LOOP
        CASE nselect == 4
            mok := ApGetN( Trim( Message->Delete ) + " This INFO" )
            IF mok == "Y"
                SELECT Cusnotes
                GOTO TOP
                ApFLock( 3 )
                DO WHILE Cusnotes->( !Eof() )
                    IF SubStr( Code_Ref, 9, 6 ) != minvno
                        SKIP ALIAS Cusnotes
                        LOOP
                    ENDIF
                    DELETE
                    SKIP ALIAS Cusnotes
                ENDDO
                UNLOCK
                SELECT QuotInfo
                GOTO TOP
                DO WHILE QuotInfo->( !Eof() )
                    IF QuotInfo->Invno != minvno
                        SKIP ALIAS QuotInfo
                        LOOP
                    ENDIF
                    ApRLock( 3 )
                    DELETE
                    UNLOCK
                    SKIP ALIAS QuotInfo
                ENDDO
            ENDIF                            // mok
            mcontinue := "Y"
            LOOP
        ENDCASE
        mcontinue = "N"
    ENDDO                       // mcontinue

    RETURN NIL
// **-----End of METuotEdit()

// *-------------------------------------------------------------------

FUNCTION METuotPAdd()

    minvno := Space( 6 )
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
            AAdd( aPart_, Debit->Invno;
                + " " + Debit->Stat;
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
            anum := AChoice(  1, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
            IF PressedEsc()
                RETURN NIL
            ENDIF
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
            GOTO nrecno
        ENDIF                     // Empty
    ENDIF                        // LastRec
    SELECT QuotInfo
    ApFLock( 3 )
    APPEND BLANK
    QuotInfo->Codeno   := Debit->Codeno
    QuotInfo->Dbdate   := Date()
    QuotInfo->Duedate  := Date() + 20
    QuotInfo->Faxno    := Debit->Invno + Name->Codeno + LTrim( Str( LastRec(), 4 ) )
    QuotInfo->Invno    := Debit->Invno
    UNLOCK
    METuotPrice()                         // METQuot

    RETURN NIL
// ***---- End of METuotPAdd()

// ****------------------- END OF File METQuHse.PRG
