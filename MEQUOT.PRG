// **  JK 27-10-10 20:20:51

/*
   Program.....:                MEQUOT.PRG
   Authors.....: J.Kirby
   Date........:  5/10/1995
   Functions...: MEApplicant, MEuotJSheet, MEartSearch,
               : MEuotPrice, MEuotAdd, MEuotIndi
*/

// (c) Copyright 1993 by Chozen Ltd Christchurch.

FUNCTION MEApplicant()

    aPart_ := anum := {}
    nrecno := 0
    Scroll()
    SELECT QuotInfo
    IF LastRec() != 0
        GOTO TOP
        mcodeno := Space( 8 )
        DO WHILE QuotInfo->( !Eof() )
            IF QuotInfo->Invno != Space( 6 )
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            IF QuotInfo->Codeno = "A"
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            SELECT Name
            SEEK QuotInfo->Codeno
            SELECT QuotInfo
            AAdd( aPart_, Name->Name;
                + " " + QuotInfo->Partnum;
                + " " + QuotInfo->Info;
                + "   " + Str( RecNo(), 6 ) )
            SKIP ALIAS QuotInfo
        ENDDO
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 3 SAY Cat->CatDesc COLOR "G+"
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

        MeuotEdit( mcodeno )

    ENDIF                       // LastRec

    RETURN NIL
// ***---- End of MEApplicant()

// ---------------------------------------------------------------------*

FUNCTION MEuotJSheet()

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
        mcodeno := Name->Codeno
        SEEK mcodeno
        nline := 0
        DO WHILE QuotInfo->Codeno = mcodeno .AND. QuotInfo->( !Eof() )
            IF QuotInfo->Invno != Space( 6 )
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            SELECT Part
            SEEK QuotInfo->Partnum
            SELECT Cat
            SEEK Part->Catno
            @ nl, 0 SAY Cat->CatDesc
            nl++
            SELECT Part
            @ nl, 12 SAY Part->Desc
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
            mpartnum := QuotInfo->Partnum
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
            FOR nline = 1 TO ( 34 -npl )
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

    RETURN mcodeno

// ****** End of MEuotJSheet()

// *---------------------------------------------------------------------*

FUNCTION MEartSearch()

    aPart_ := anum := {}
    nrecno := 0
    Scroll()
    SELECT QuotInfo
    IF LastRec() != 0
        INDEX ON Partnum TO QPartInd
        SET INDEX TO QPartInd
        GOTO TOP
        mpartnum := Space( 20 )
        DO WHILE QuotInfo->( !Eof() )
            IF QuotInfo->Invno != Space( 6 )
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            IF QuotInfo->Partnum = mpartnum
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            SELECT Part
            SEEK QuotInfo->Partnum
            SELECT QuotInfo
            AAdd( aPart_, QuotInfo->Codeno;
                + " " + SubStr( Part->Desc, 1, 25 );
                + " " + QuotInfo->Info;
                + "           " + Str( RecNo(), 6 ) )
            mpartnum := QuotInfo->Partnum
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
        mpartnum  := QuotInfo->Partnum
        aPart_ := {}
        nrecno := 0
        cInvno := Space( 10 )
        SELECT QuotInfo
        SEEK mpartnum
        DO WHILE QuotInfo->Partnum = mpartnum .AND. QuotInfo->( !Eof() )
            IF QuotInfo->Invno != Space( 6 )
                SKIP ALIAS QuotInfo
                LOOP
            ENDIF
            SELECT Name
            SEEK QuotInfo->Codeno
            SELECT Part
            SEEK mpartnum
            SELECT QuotInfo
            AAdd( aPart_, Name->Name;
                + " " + QuotInfo->Info;
                + "        " + Str( RecNo(), 6 ) )
            SKIP ALIAS QuotInfo
        ENDDO
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 3      SAY Trim( Part->Partnum )     COLOR "G+"
        @  1, Col() + 1 SAY Trim( Part->Desc )        COLOR "G+"
        DispBox( 3, 1, 24, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
            IF PressedEsc()
                SELECT QuotInfo
                SET INDEX TO QuInfo
                RETURN NIL
            ENDIF
        ENDIF
    ENDIF                       // LastRec

    MEartSearch()                 // Above

    SELECT QuotInfo
    SET INDEX TO QuInfo

    RETURN NIL
// ***---- End of MEartSearch()

// *---------------------------------------------------------------------*

FUNCTION MEuotPrice( mpartnum )

    Scroll()
    DispBox( 0, 1, 2, 79, 2 )
    @  1, 3 SAY Name->Name COLOR "BG+"
    SELECT Part
    SET ORDER TO 1
    SEEK mpartnum
    DispBox( 3, 1, 24, 79, 2 )
    nl := 4
    @ nl, 3 SAY Trim( Part->Partnum ) + " " + Trim( Part->Desc );
        + "  " + Trim( Part->Unit )
    SELECT QuotInfo
    ApRLock( 3 )
    nl++
    // **   @ nl, 4       SAY "Date        " GET QuotInfo->Dbdate  PICTURE "99/99/9999"
    // **   @ nl, COL()+3 SAY "Expire Date"  GET QuotInfo->Duedate PICTURE "99/99/9999"
    // **   nl++
    @ nl, 4 SAY "Memo        " GET QuotInfo->Info
    nl++
    @ nl, 4 SAY "            " GET QuotInfo->Info2
    nl++
    @ nl, 4 SAY "            " GET QuotInfo->Info3
    nl++
    @ nl, 4 SAY "            " GET QuotInfo->Info4
    nl++
    @ nl, 4 SAY "            " GET QuotInfo->Info5
    nl++
    @ nl, 4 SAY "            " GET QuotInfo->Info6
    READ
    UNLOCK
    SELECT Cusnotes
    coderef := QuotInfo->Faxno
    SEEK coderef
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

    RETURN mpartnum

// ***------- End MEQuotPrice

// *-------------------------------------------------------------------

FUNCTION MEuotAdd()

    dDbDate   := Date()
    mcodeno   := Space ( 8 )
    mpartnum  := Space( 20 )
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"

        Namerank( @mcodeno )                            // ZSF_Name

        IF PressedEsc()
            RETURN NIL
        ENDIF
        mcodeno := Name->Codeno
        manother := "Y"
        DO WHILE manother = "Y"
            mok := "Y"
            DO WHILE mok = "Y"
                Scroll( 3, 0, 24, 80 )
                SELECT QuotInfo
                SEEK mcodeno
                IF Found()
                    MEuoLook()                 // MEQuoHse.PRG
                ENDIF
                Scroll(  12, 0, 24, 80 )
                DispBox( 12, 1, 20, 79, 2 )
                @ 13, 4      SAY Trim( QuotInfo->Partnum )
                @ 13, Col() + 2 SAY Part->Desc  COLOR "BG+"
                @ 14, 4      SAY QuotInfo->Info
                @ 15, 4      SAY QuotInfo->Info2
                @ 16, 4      SAY QuotInfo->Info3
                @ 17, 4      SAY QuotInfo->Info4
                @ 18, 4      SAY QuotInfo->Info5
                @ 19, 4      SAY QuotInfo->Info6
                DispBox( 21, 1, 24, 79, 2 )
                nselect := 1
                @ 23, 4      PROMPT "Add Part"
                @ 23, Col() + 3 PROMPT "Edit Info"
                @ 23, Col() + 3 PROMPT "Job Card"
                @ 23, Col() + 3 PROMPT "Edit Part"
                @ 23, Col() + 3 PROMPT "Another"
                MENU TO nselect
                DO CASE
                CASE PressedEsc()
                    RETURN NIL
                CASE nselect == 1
                    Quotcodeno := Space( 8 )
                    mpartnum := Space( 20 )
                    MEuotPAdd( @mpartnum )                      // MEQuoHse
                    LOOP
                CASE nselect == 2
                    MEuotEdit( @mcodeno )                       // MEQuoHse
                    LOOP
                CASE nselect == 3
                    mcodeno := Name->Codeno
                    MEuotJSheet( @mcodeno )                      // Below
                    LOOP
                CASE nselect == 4                     // Qty Desc
                    tempscrn := SaveScreen( 0, 0, 24, 80 )
                    mpartnum := Part->Partnum
                    cedit := "N"                            // N = Total Stock
                    MEProfQty( cedit )                        // XLF_Prof
                    RestScreen(  0, 0, 24, 80, tempscrn )
                    LOOP
                CASE nselect == 5                     // Qty Desc
                    LOOP
                ENDCASE
            ENDDO                               // End of more Parts
        ENDDO
        mcontinue := "N"
    ENDDO                                   // mcontinue

    RETURN NIL

// ***----- End of MEuotadd()

// *-------------------------------------------------------------------

FUNCTION MEuotIndi( mcodeno )

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
    ncnt := 0
    GOTO TOP
    SEEK mcodeno
    DO WHILE QuotInfo->Codeno = mcodeno .AND. QuotInfo->( !Eof() )
        IF QuotInfo->Invno != Space( 6 )
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
        mpartnum := QuotInfo->Partnum
        IF mpartnum != Space( 20 )
            SELECT Part
            SET ORDER TO 1                    // Partnum
            SEEK mpartnum
            SELECT Cusnotes
            cdetail := ""
            coderef := QuotInfo->Faxno
            SEEK coderef
            IF Found()
                GetDets( coderef )                            // XF_Memo2
                FormP( cdetail, 60, 10 )                        // XF_Memo2
            ENDIF
            SELECT Part
            @ nl, 0 SAY Part->Partnum        // Reduced Part Number
            @ nl, 18 SAY Part->Desc          // Can reduce Desc
            nl++
            IF Part->Detail != Space( 40 )
                @ nl, 9 SAY Part->Detail
                nl++
            ENDIF
            @ nl, 10 SAY QuotInfo->DBDate
            @ nl, 22 SAY QuotInfo->DueDate
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

    RETURN NIL

// ** End of MEuotIndi()

// ********----------  END OF FILE MEQuot.PRG
