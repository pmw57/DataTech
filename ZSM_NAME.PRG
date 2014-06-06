// ** JK  04-03-11 12:24:48

/*
   Program.....:                  ZSM_NAME.PRG
   Authors.....: J.Kirby
   Date........: 31/05/1999
   Functions...: MarkName, MarkAll, MarkRept, ConsName
                 WkDebprof
   Static funcs: WkDebFunc, WkDebYear, WkDates, WkDebPrnt
   Not used....: Mu_SName
*/

// (c) Copyright 1999 by Elcom Ltd & John Kirby Christchurch.

FUNCTION MarkName()

    mtotal := ApGetN( "All Sales For Account Year" )
    SELECT Name
    GOTO TOP
    ApFLock( 3 )
    INDEX ON Name->Add4 TO TempName
    UNLOCK
    SET INDEX TO TempName
    cnameadd4 := Space( 20 )
    mtempno := Space( 20 )
    anum := {}
    aPart_ := {}
    nrecno := 0
    DO WHILE Name->( !Eof() )
        IF Name->Add4 = "           "
            SKIP ALIAS Name
            LOOP
        ENDIF
        IF Name->Add4 = mtempno
            SKIP ALIAS Name
            LOOP
        ENDIF
        mtempno := Name->Add4
        AAdd( aPart_, ( Name->Add4;
            + "       " + Str( RecNo(), 6 ) ) )
        SKIP ALIAS Name
    ENDDO
    Scroll()
    DispBox(  0, 1, 24, 26, 2 )
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 1, 3, 23, 24, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ], 6 ) )
        GOTO nrecno
        cnameadd4 := Name->Add4
    ENDIF
    mok := ApGetY( "All Groups ENG, GAR etc " )
    IF mok = "N"
        SELECT Name
        GOTO TOP
        ApFLock( 3 )
        INDEX ON Name->Sale TO TempSale
        SET INDEX TO TempSale
        UNLOCK
        cnameSale := Space( 4 )
        mtempno := Space( 4 )
        anum := {}
        aPart_ := {}
        nrecno := 0
        mcodeno := Space( 8 )
        DO WHILE Name->( !Eof() )
            IF Name->Add4 != cnameAdd4
                SKIP ALIAS Name
                LOOP
            ENDIF
            IF Name->Sale = mtempno
                SKIP ALIAS Name
                LOOP
            ENDIF
            mtempno := Name->Sale
            AAdd( aPart_, ( Name->Sale;
                + "       " + Str( RecNo(), 6 ) ) )
            SKIP ALIAS Name
        ENDDO
        DispBox(  0, 35, 24, 45, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 1, 37, 23, 44, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
            GOTO nrecno
            cnameSale := Name->Sale
        ENDIF
    ENDIF
    dyear := Year( Date() )
    nqtytotal := nTotal := ncosttot := 0

    mwhere := "S"
    npl    := 0
    nl     := 1

    Printsel()                               // _LF_Init

    Scroll()
    SELECT Name
    GOTO TOP
    DO WHILE Name->( !Eof() )
        IF Name->Add4 != cnameAdd4
            SKIP ALIAS Name
            LOOP
        ENDIF
        IF mok = "N"
            IF Name->Add4 != cnameSale
                SKIP ALIAS Name
                LOOP
            ENDIF
        ENDIF
        @ nl, 0 SAY Name->Name
        @ nl, 46 SAY Trim( Name->Called ) + " " + Trim( Name->Famname )
        nl++
        @ nl, 6 SAY Name->Add1
        @ nl, 34 SAY Name->Add2
        nl++
        @ nl, 6 SAY Name->Add3
        @ nl, 34 SAY Name->Add4
        @ nl, 66 SAY Name->Sale
        nl++
        @ nl, 0 SAY "Ph " + Name->Phone
        @ nl, 18 SAY "Mob " + Name->MobPhone
        @ nl, 40 SAY Name->Email
        nl++
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            nl := 0
        ENDIF
        SELECT Rept
        SET ORDER TO 2      // Codeno+Stat
        GOTO TOP
        SEEK Name->Codeno
        DO WHILE Rept->Codeno = Name->Codeno .AND. Rept->( !Eof() )
            IF Rept->Info != "       "
                @ nl, 1 SAY Rept->Info + " " + DToC( Rept->Date )
                nl++
            ENDIF
            IF Rept->Info1 != "       "
                @ nl, 1 SAY Rept->Info1
                nl++
            ENDIF
            IF Rept->Info2 != "       "
                @ nl, 1 SAY Rept->Info2
                nl++
            ENDIF
            IF Rept->Info3 != "       "
                @ nl, 1 SAY Rept->Info3
                nl++
            ENDIF
            IF Rept->Info4 != "       "
                @ nl, 1 SAY Rept->Info4
                nl++
            ENDIF
            IF Rept->Info5 != "       "
                @ nl, 1 SAY Rept->Info5
                nl++
            ENDIF
            SKIP ALIAS Rept
        ENDDO
        SELECT Hist
        GOTO TOP
        nqtytotal := nTotal := 0
        SEEK Name->Codeno
        DO WHILE Hist->Codeno = Name->Codeno .AND. Hist->( !Eof() )
            IF Hist->Stat != "I"
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF mtotal = "Y"
                IF Year( Hist->PDate ) != dyear
                    @ nl, 1 SAY DToC( Hist->PDate ) + " " + Hist->Invno;
                        + " " + Hist->Saleno + " " + Hist->Partnum
                    nl++
                    @ nl, 10 SAY Hist->Est
                    @ nl, 40 SAY Hist->Amount PICTURE "$9,999,999.99"
                    nl++
                ENDIF
            ENDIF
            IF Year( Hist->PDate ) = dyear
                ntotal  += Hist->Amount * Hist->Qty
                @ nl, 1 SAY DToC( Hist->PDate ) + " " + Hist->Invno;
                    + " " + Hist->Saleno + " " + Hist->Partnum
                nl++
                @ nl, 10 SAY Hist->Est
                @ nl, 40 SAY Hist->Amount PICTURE "$9,999,999.99"
                nl++
            ENDIF
            nqtytotal += Hist->Amount * Hist->Qty
            SKIP ALIAS Hist
        ENDDO                                 // EOF Hist
        nl++
        IF nqtyTotal > 0 .OR. ntotal > 0
            // **         @ nl, 4 SAY Name->Sale
            @ nl, 14 SAY "Total Sales"
            @ nl, 26 SAY nqtyTotal PICTURE "9999,999.99"
            @ nl, 42 SAY Dyear
            @ nl, 50 SAY "Year Sales"
            @ nl, 63 SAY nTotal PICTURE "9999,999.99"
            nl++
        ENDIF
        SELECT Name
        SKIP ALIAS Name
    ENDDO
    IF mwhere == "P"
        EndPrint()
        SET MARGIN TO 0
    ELSE
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    SELECT Name
    SET INDEX TO NameInd
    SELECT Rept
    SET ORDER TO 1          // CodeRecno

    RETURN NIL

// **------------ End of MarkName()

// **---------------------------------------------------------------------*

FUNCTION MarkAll()

    mtotal := ApGetN( "Total Sales details" )
    SELECT Name
    GOTO TOP
    ApFLock( 3 )
    INDEX ON Name->Add4 TO TempName
    UNLOCK
    cnameadd4 := Space( 20 )
    mtempno := Space( 20 )
    anum := {}
    aPart_ := {}
    nrecno := 0
    mcodeno := Space( 8 )
    DO WHILE Name->( !Eof() )
        IF Name->Add4 = mtempno
            SKIP ALIAS Name
            LOOP
        ENDIF
        mtempno := Name->Add4
        AAdd( aPart_, ( Name->Add4;
            + "       " + Str( RecNo(), 6 ) ) )
        SKIP ALIAS Name
    ENDDO
    Scroll()
    DispBox(  0, 1, 24, 26, 2 )
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 1, 3, 23, 24, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ], 6 ) )
        GOTO nrecno
        cnameadd4 := Name->Add4
    ENDIF
    mwhere := "S"
    npl    := 0
    nl     := 1

    Printsel()                               // _LF_Init

    Scroll()
    SELECT Name
    GOTO TOP
    SET INDEX TO NameInd
    DO WHILE Name->( !Eof() )
        IF Name->Add4 != cnameAdd4
            SKIP ALIAS Name
            LOOP
        ENDIF
        @ nl, 0 SAY Name->Name
        @ nl, 46 SAY Trim( Name->Called ) + " " + Trim( Name->Famname )
        nl++
        @ nl, 6 SAY Name->Add1
        @ nl, 34 SAY Name->Add2
        nl++
        @ nl, 6 SAY Name->Add3
        @ nl, 34 SAY Name->Add4
        @ nl, 66 SAY Name->Sale
        nl++
        @ nl, 0 SAY "Ph " + Name->Phone
        @ nl, 18 SAY "Mob " + Name->MobPhone
        @ nl, 40 SAY Name->Email
        nl++
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            nl := 0
        ENDIF
        IF mtotal = "Y"
            dyear := Year( Date() )
            ntotqty3 := ntotqty2 := ntotqty1 := ntotqty := nTotal := 0
            ntotcost3 := ntotcost2 := ntotcost1 := ntotcost := ncosttot := 0
            SELECT Hist
            GOTO TOP
            SEEK Name->Codeno
            nqtytotal := nqty := nqty1 := nqty2 := nqty3 := 0
            DO WHILE Hist->Codeno = Name->Codeno .AND. Hist->( !Eof() )
                IF Hist->Stat = " "
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                IF mtotal = "Y"
                    IF Year( Hist->PDate ) != dyear
                        @ nl, 1 SAY Hist->Invno + " " + Hist->Saleno + " " + Hist->Partnum + " " + Hist->Est
                        @ nl, 64 SAY Hist->Amount PICTURE "9999,999.99"
                        nl++
                    ENDIF
                ENDIF
                IF Year( Hist->PDate ) = dyear
                    ntotal  += Hist->Amount * Hist->Qty
                    @ nl, 1 SAY Hist->Invno + " " + Hist->Saleno + " " + Hist->Partnum + " " + Hist->Est
                    @ nl, 66 SAY Hist->Amount PICTURE "9999,999.99"
                    nl++
                ENDIF
                nqtytotal += Hist->Amount * Hist->Qty
                ncosttot  += Hist->Cost * Hist->Qty
                SKIP ALIAS Hist
            ENDDO                                 // EOF Hist
            IF nqtyTotal > 0
                @ nl, 4 SAY Name->Sale
                @ nl, 14 SAY "Total Sales"
                @ nl, 26 SAY nqtyTotal PICTURE "9999,999.99"
                @ nl, 42 SAY Dyear
                @ nl, 50 SAY "Year Sales"
                @ nl, 63 SAY nTotal PICTURE "9999,999.99"
                nl++
            ENDIF
        ENDIF       // mtotal
        SELECT Name
        SKIP ALIAS Name
    ENDDO
    IF mwhere == "P"
        EndPrint()
        SET MARGIN TO 0
    ELSE
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF
    SELECT Name
    SET INDEX TO NameInd

    RETURN NIL

// **------------ End of MarkAll()

// **---------------------------------------------------------------------*

FUNCTION MarkRept()

    SELECT Name
    GOTO TOP
    ApFLock( 3 )
    INDEX ON Name->Add4 TO TempName
    UNLOCK
    cnameadd4 := Space( 20 )
    mtempno := Space( 20 )
    anum := {}
    aPart_ := {}
    nrecno := 0
    mcodeno := Space( 8 )
    DO WHILE Name->( !Eof() )
        IF Name->Add4 = mtempno
            SKIP ALIAS Name
            LOOP
        ENDIF
        mtempno := Name->Add4
        AAdd( aPart_, ( Name->Add4;
            + "       " + Str( RecNo(), 6 ) ) )
        SKIP ALIAS Name
    ENDDO
    Scroll()
    DispBox(  0, 1, 24, 26, 2 )
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 1, 3, 23, 24, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ], 6 ) )
        GOTO nrecno
        cnameadd4 := Name->Add4
    ENDIF
    SELECT Name
    GOTO TOP
    ApFLock( 3 )
    INDEX ON Name->Sale TO TempSale
    SET INDEX TO TempSale
    UNLOCK
    cnameSale := Space( 4 )
    mtempno := Space( 4 )
    anum := {}
    aPart_ := {}
    nrecno := 0
    mcodeno := Space( 8 )
    DO WHILE Name->( !Eof() )
        IF Name->Add4 != cnameAdd4
            SKIP ALIAS Name
            LOOP
        ENDIF
        IF Name->Sale = mtempno
            SKIP ALIAS Name
            LOOP
        ENDIF
        mtempno := Name->Sale
        AAdd( aPart_, ( Name->Sale;
            + "       " + Str( RecNo(), 6 ) ) )
        SKIP ALIAS Name
    ENDDO
    DispBox(  0, 30, 24, 40, 2 )
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 1, 32, 23, 38, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ], 6 ) )
        GOTO nrecno
        cnameSale := Name->Sale
    ENDIF
    // ************************
    mwhere := "S"
    npl    := 0
    nl     := 1

    Printsel()                               // _LF_Init

    Scroll()
    SELECT Name
    GOTO TOP
    SET INDEX TO NameInd
    DO WHILE Name->( !Eof() )
        IF Name->Add4 != cnameAdd4 .OR. Name->Sale != cnameSale
            SKIP ALIAS Name
            LOOP
        ENDIF
        @ nl, 0 SAY Name->Name
        @ nl, 46 SAY Trim( Name->Called ) + " " + Trim( Name->Famname )
        nl++
        @ nl, 6 SAY Name->Add1
        @ nl, 34 SAY Name->Add2
        nl++
        @ nl, 6 SAY Name->Add3
        @ nl, 34 SAY Name->Add4
        @ nl, 66 SAY Name->Sale
        nl++
        @ nl, 0 SAY "Ph " + Name->Phone
        @ nl, 18 SAY "Mob " + Name->MobPhone
        @ nl, 40 SAY Name->Email
        nl++
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            nl := 0
        ENDIF
        SELECT Rept
        SET ORDER TO 2
        GOTO TOP
        SEEK Name->Codeno
        DO WHILE Rept->Codeno = Name->Codeno .AND. Rept->( !Eof() )
            @ nl, 1 SAY Rept->DATE PICTURE "99/99/9999"
            @ nl, 12 SAY Rept->Stat + " " + Rept->SuppId + " " + Rept->Info
            nl++
            IF Rept->Info1 != Space( 50 )
                @ nl, 2 SAY Rept->Info1
                nl++
            ENDIF
            IF Rept->Info2 != Space( 50 )
                @ nl, 2 SAY Rept->Info2
                nl++
            ENDIF
            IF Rept->Info3 != Space( 50 )
                @ nl, 2 SAY Rept->Info3
                nl++
            ENDIF
            IF Rept->Info4 != Space( 50 )
                @ nl, 2 SAY Rept->Info4
                nl++
            ENDIF
            IF Rept->Info5 != Space( 50 )
                @ nl, 2 SAY Rept->Info5
                nl++
            ENDIF
            SKIP ALIAS Rept
        ENDDO                                 // EOF Rept
        SELECT Name
        SKIP ALIAS Name
    ENDDO
    IF mwhere == "P"
        EndPrint()
    ELSE
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF
    SELECT Name
    SET INDEX TO NameInd
    SELECT Rept
    SET ORDER TO 1

    RETURN NIL

// **------------ End of MarkRept()

// **---------------------------------------------------------------------*

FUNCTION ConsName()

    // ** @ 10,10 SAY "Please Wait for Index File  Thank You"
    // ** @ 12,10 SAY "Working Hard   "
    dyear := Year( Date() )
    SELECT Debprof
    SET ORDER TO 1              // Codeno
    // ** INDEX ON Debprof->Codeno+DTOC( Debprof->DbDate ) TO TempInd
    // ** SET INDEX TO TempInd
    mok := "Y"
    DO WHILE mok == "Y"
        mcodeno := Space( 8 )
        // **   SELECT Name
        mselect := ApGetN( " Select one name" )
        IF mselect = "Y"
            // ***********************
            SELECT DebProf
            SET ORDER TO 1                   // Codeno
            GOTO TOP
            Scroll()
            @ 10, 10 SAY "Please Wait Working Hard"
            aPart_ := {}
            nrecno := mA := ngtotal := nggtotal := 0
            mcodeno := Space( 8 )
            DO WHILE DebProf->( !Eof() )
                IF DebProf->Codeno = mcodeno
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF Year( Debprof->DbDate ) != dyear
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                SELECT Name
                SEEK DebProf->Codeno
                IF Found()
                    SELECT DebProf
                    AAdd( aPart_, Name->Name + "      " + Str( RecNo(),6 )  )
                ENDIF
                mcodeno := DebProf->Codeno
                SKIP ALIAS DebProf
            ENDDO
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                Scroll()
                DispBox( 0, 5, 24, 45, 2 )
                anum := AChoice( 1, 10, 23, 40, aPart_,, "AFUNC" )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                mcodeno := DebProf->Codeno
            ENDIF
            SELECT Name
            SEEK mcodeno
            // **       NameRank( mcodeno )
            // **      IF LASTKEY() = 27
            // **         RETURN NIL
            // **      ENDIF
            // **      mcodeno := Name->Codeno
        ENDIF                                // mselect
        Scroll()
        mchoice := 1
   /*
       @  8,33 SAY "Select Year"
       @ 12,30 PROMPT YEAR( DATE() )-0
       @ 13,30 PROMPT YEAR( DATE() )-1
       @ 14,30 PROMPT YEAR( DATE() )-2
       @ 15,30 PROMPT YEAR( DATE() )-3
       @ 16,30 PROMPT YEAR( DATE() )-4
       MENU TO mchoice
       DO CASE
          CASE mchoice == 1
               dyear := YEAR( DATE() )
          CASE mchoice == 2
               dyear := YEAR( DATE() )-1
          CASE mchoice == 3
               dyear := YEAR( DATE() )-2
          CASE mchoice == 4
               dyear := YEAR( DATE() )-3
          CASE mchoice == 5
               dyear := YEAR( DATE() )-4
       ENDCASE
   */
        mwhere := "S"
        // **   SCROLL()
        npl := 56

        Printsel( mwhere, npl )                        // _LF_Init

        @  0, 0 SAY Trim( Control->U_Name )
        @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + " " + Str( Year( Date() ), 5 )
        nl := 2
        ntotal := nqtytotal := ncosttot := nqty := nqty1 := nqty2 := nqty3 := 0
        nqty4 :=  nqty5 := nqty6 := nqty7 := nqty8 := nqty9 := 0
        nqty10 := nqty11 := nqty12 := nqty13 := nrecno := 0

        ntotally := nqtytotally := ncosttotly := nqtyly := nqty1ly := nqty2ly := nqty3ly := 0
        nqty4ly :=  nqty5ly := nqty6ly := nqty7ly := nqty8ly := nqty9ly := 0
        nqty10ly := nqty11ly := nqty12ly := nqty13ly := nrecno := 0
        nqty1ly2 := nqty2ly2 := nqty3ly2 := 0
        nqty1ny := nqty2ny := nqty3ny := 0
        SELECT Debprof
        GOTO TOP
        IF mselect = "Y"
            SEEK Name->Codeno
        ENDIF
        // **     DO WHILE Debprof->Codeno = Name->Codeno .AND. Debprof->( !EOF() )
        DO WHILE Debprof->( !Eof() )
            IF mselect = "Y"
                IF Debprof->Codeno <> mcodeno
                    SKIP ALIAS Debprof
                    LOOP
                ENDIF
            ENDIF
            IF Year( Debprof->DbDate ) = dyear + 1     // 2002
                DO CASE
                CASE Month( Debprof->DbDate ) = 3
                    nqty3ny  += Debprof->Amount
                    ncosttot  += Debprof->Amount
                    nqtytotal += Debprof->Amount
                    ntotal    += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 2
                    nqty2ny  += Debprof->Amount
                    ncosttot  += Debprof->Amount
                    nqtytotal += Debprof->Amount
                    ntotal    += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 1
                    nqty1ny  += Debprof->Amount
                    ncosttot  += Debprof->Amount
                    nqtytotal += Debprof->Amount
                    ntotal    += Debprof->Amount
                ENDCASE
                SKIP ALIAS Debprof
                LOOP
            ENDIF                  // YEAR +1

            // ****************
            IF Year( Debprof->DbDate ) = dyear - 2
                DO CASE
                CASE Month( Debprof->DbDate ) = 3
                    nqty3ly2  += Debprof->Amount
                    ncosttotly  += Debprof->Amount
                    nqtytotally += Debprof->Amount
                    ntotally    += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 2
                    nqty2ly2  += Debprof->Amount
                    ncosttotly  += Debprof->Amount
                    nqtytotally += Debprof->Amount
                    ntotally    += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 1
                    nqty1ly2  += Debprof->Amount
                    ncosttotly  += Debprof->Amount
                    nqtytotally += Debprof->Amount
                    ntotally    += Debprof->Amount
                ENDCASE
                SKIP ALIAS Debprof
                LOOP
            ENDIF                  // YEAR - 2

            // ******************
            IF Year( Debprof->DbDate ) = dyear - 1
                DO CASE
                CASE Month( Debprof->DbDate ) = 12          // Dec
                    nqty12ly += Debprof->Amount
                    ncosttotly  += Debprof->Amount
                    nqtytotally += Debprof->Amount
                    ntotally    += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 11          // Nov
                    nqty11ly += Debprof->Amount
                    ncosttotly  += Debprof->Amount
                    nqtytotally += Debprof->Amount
                    ntotally    += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 10
                    nqty10ly += Debprof->Amount
                    ncosttotly  += Debprof->Amount
                    nqtytotally += Debprof->Amount
                    ntotally    += Debprof->Amount
                CASE Month( Debprof->DbDate ) =  9
                    nqty9ly  += Debprof->Amount
                    ncosttotly  += Debprof->Amount
                    nqtytotally += Debprof->Amount
                    ntotally    += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 8
                    nqty8ly  += Debprof->Amount
                    ncosttotly  += Debprof->Amount
                    nqtytotally += Debprof->Amount
                    ntotally    += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 7
                    nqty7ly  += Debprof->Amount
                    ncosttotly  += Debprof->Amount
                    nqtytotally += Debprof->Amount
                    ntotally    += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 6
                    nqty6ly  += Debprof->Amount
                    ncosttotly  += Debprof->Amount
                    nqtytotally += Debprof->Amount
                    ntotally    += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 5
                    nqty5ly  += Debprof->Amount
                    ncosttotly  += Debprof->Amount
                    nqtytotally += Debprof->Amount
                    ntotally    += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 4
                    nqty4ly  += Debprof->Amount
                    ncosttotly  += Debprof->Amount
                    nqtytotally += Debprof->Amount
                    ntotally    += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 3
                    nqty3ly  += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 2
                    nqty2ly  += Debprof->Amount
                CASE Month( Debprof->DbDate ) = 1
                    nqty1ly  += Debprof->Amount
                CASE Month( Debprof->DbDate ) = ( Month( Date() ) )
                    nqtyly   += Debprof->Amount
                    // **               OTHERWISE
                    // **                  nqty13ly += Debprof->Amount
                ENDCASE
                SKIP ALIAS Debprof
                LOOP
            ENDIF                  // YEAR - 1
            IF Year( Debprof->DbDate ) != dyear
                SKIP ALIAS Debprof
                LOOP
            ENDIF
            DO CASE
            CASE Month( Debprof->DbDate ) = 12
                nqty12 += Debprof->Amount
                ncosttot  += Debprof->Amount
                nqtytotal += Debprof->Amount
                ntotal    += Debprof->Amount
            CASE Month( Debprof->DbDate ) = 11
                nqty11 += Debprof->Amount
                ncosttot  += Debprof->Amount
                nqtytotal += Debprof->Amount
                ntotal    += Debprof->Amount
            CASE Month( Debprof->DbDate ) = 10
                nqty10 += Debprof->Amount
                ncosttot  += Debprof->Amount
                nqtytotal += Debprof->Amount
                ntotal    += Debprof->Amount
            CASE Month( Debprof->DbDate ) =  9
                nqty9  += Debprof->Amount
                ncosttot  += Debprof->Amount
                nqtytotal += Debprof->Amount
                ntotal    += Debprof->Amount
            CASE Month( Debprof->DbDate ) = 8
                nqty8  += Debprof->Amount
                ncosttot  += Debprof->Amount
                nqtytotal += Debprof->Amount
                ntotal    += Debprof->Amount
            CASE Month( Debprof->DbDate ) = 7
                nqty7  += Debprof->Amount
                ncosttot  += Debprof->Amount
                nqtytotal += Debprof->Amount
                ntotal    += Debprof->Amount
            CASE Month( Debprof->DbDate ) = 6
                nqty6  += Debprof->Amount
                ncosttot  += Debprof->Amount
                nqtytotal += Debprof->Amount
                ntotal    += Debprof->Amount
            CASE Month( Debprof->DbDate ) = 5
                nqty5  += Debprof->Amount
                ncosttot  += Debprof->Amount
                nqtytotal += Debprof->Amount
                ntotal    += Debprof->Amount
            CASE Month( Debprof->DbDate ) = 4
                nqty4  += Debprof->Amount
                ncosttot  += Debprof->Amount
                nqtytotal += Debprof->Amount
                ntotal    += Debprof->Amount
            CASE Month( Debprof->DbDate ) = 3
                nqty3  += Debprof->Amount
                nqtytotally += Debprof->Amount
                ntotal    += Debprof->Amount
            CASE Month( Debprof->DbDate ) = 2
                nqty2  += Debprof->Amount
                nqtytotally += Debprof->Amount
                ntotal    += Debprof->Amount
            CASE Month( Debprof->DbDate ) = 1
                nqty1  += Debprof->Amount
                nqtytotally += Debprof->Amount
                ntotal    += Debprof->Amount
            CASE Month( Debprof->DbDate ) = ( Month( Date() ) )
                nqty   += Debprof->Amount
            ENDCASE
            SKIP ALIAS Debprof
        ENDDO                  // EOF Debprof

        // **         @ nl, 0 SAY CMONTH( DATE() )
        // **         @ nl,12 SAY nqty      PICTURE "999,999.99"
        IF mselect = "Y"
            @ nl, 0 SAY Name->Name + " " + Name->Sale + " " + Str( dyear ) + " " + Str( dyear - 1 )
        ELSE
            @ nl, 20 SAY LTrim( Str( dyear ) )
            @ nl, 36 SAY "Amounts Include GST"
            // **** +"             "+LTRIM( STR( dyear-1 ) )
        ENDIF
        nl += 2
        SELECT Months
        GOTO 13
        // ** 24-( MONTH( DATE() )+1 ) // NO GOOD YET  TRY
        nrecno := RecNo()
        GOTO nrecno - 4
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty4     PICTURE "999,999.99"
        @ nl, 32 SAY nqty4ly   PICTURE "999,999.99"
        nl++
        GOTO nrecno - 5
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty5     PICTURE "999,999.99"
        @ nl, 32 SAY nqty5ly   PICTURE "999,999.99"
        nl++
        GOTO nrecno - 6
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty6     PICTURE "999,999.99"
        @ nl, 32 SAY nqty6ly   PICTURE "999,999.99"
        nl++
        GOTO nrecno - 7
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty7     PICTURE "999,999.99"
        @ nl, 32 SAY nqty7ly   PICTURE "999,999.99"
        nl++
        GOTO nrecno - 8
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty8     PICTURE "999,999.99"
        @ nl, 32 SAY nqty8ly   PICTURE "999,999.99"
        nl++
        GOTO nrecno - 9
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty9     PICTURE "999,999.99"
        @ nl, 32 SAY nqty9ly   PICTURE "999,999.99"
        nl++
        GOTO nrecno - 10
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty10    PICTURE "999,999.99"
        @ nl, 32 SAY nqty10ly  PICTURE "999,999.99"
        nl++
        GOTO nrecno - 11
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty11    PICTURE "999,999.99"
        @ nl, 32 SAY nqty11ly  PICTURE "999,999.99"
        nl++
        GOTO nrecno - 12
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty12    PICTURE "999,999.99"
        @ nl, 32 SAY nqty12ly  PICTURE "999,999.99"
        nl++
   /*
            @ nl, 0 SAY "Balance "
            @ nl,14 SAY nqty13    PICTURE "999,999.99"
            @ nl,28 SAY nqty13ly  PICTURE "999,999.99"
            nl++
   */
        GOTO nrecno - 1
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty1ny    PICTURE "999,999.99"
        @ nl, 32 SAY nqty1      PICTURE "999,999.99"
        nl++
        GOTO nrecno - 2
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty2ny    PICTURE "999,999.99"
        @ nl, 32 SAY nqty2      PICTURE "999,999.99"
        nl++
        GOTO nrecno - 3
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty3ny    PICTURE "999,999.99"
        @ nl, 32 SAY nqty3      PICTURE "999,999.99"
        nl++
        @ nl, 16 SAY "------------"
        @ nl, 30 SAY "------------"
        nl++
        @ nl, 0 SAY "Total+GST"
        @ nl, 15 SAY nqtyTotal   PICTURE "$9,999,999.99"
        @ nl, 29 SAY nqtyTotally PICTURE "$9,999,999.99"
        // **        @ nl,35 SAY "Total Cost"
        // **        @ nl,46 SAY ncosttot  PICTURE "$9,999,999.99"
        // **        @ nl,61 SAY ( ( ntotal-ncosttot  )/ntotal )*100 PICTURE "9999 %"
        // **        nl+=2
        IF mwhere == "S"
            // **     WAIT
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print out" )
    ENDDO

    RETURN NIL

// **------------ End of ConsName()

// **---------------------------------------------------------------------*

FUNCTION Mu_SName( nc, ncl )

    DO WHILE .T.

        nselect  := 0
        nc       := ncl * 2
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( Menu->CH_L2Nahd ) ) / 2 );
            SAY RTrim( Menu->CH_L2Nahd )
        @  7, nc + 2 PROMPT "1. "
        @  9, nc + 2 PROMPT "2. "
        @ 11, nc + 2 PROMPT "3. "
        @ 13, nc + 2 PROMPT "4. "
        @ 15, nc + 2 PROMPT "5. "
        @ 16, nc + 2 PROMPT "6. "
        @ 18, nc + 2 PROMPT "7. "
        @ 20, nc + 2 PROMPT Menu->CH_Main + "   "
        nc := ncl

        MENU TO nselect
        DO CASE
        CASE nselect == 8 .OR. PressedEsc()
            EXIT
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            // **      Consname()                            // Below
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            // ***          InvList()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            mcodeno := Space( 8 )
            // ***          HistName( mcodeno )
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
        ENDCASE

    ENDDO

    RETURN NIL

// ****  End of Mu_SName

// **---------------------------------------------------------------------*

FUNCTION WkDebprof()

    Scroll()
    DispBox( 0, 5, 22, 75, 2 )
    @  1, 7 SAY "Select Up to Five Saleno for Analysis ( Can be old ones as well )"
    SELECT Salebook
    GOTO TOP
    nl := 3
    DO WHILE SaleBook->( !Eof() )
        @  nl, 34 SAY SaleBook->Saleno + "  " + SaleBook->SBName
        nl++
        SKIP ALIAS SaleBook
    ENDDO
    SELECT MESSAGE
    ApRLock( 3 )
    @  3, 10 SAY "Saleno 1" GET Message->Saleno1 PICTURE "@!"
    @  4, 10 SAY "Saleno 2" GET Message->Saleno2 PICTURE "@!"
    @  5, 10 SAY "Saleno 3" GET Message->Saleno3 PICTURE "@!"
    @  6, 10 SAY "Saleno 4" GET Message->Saleno4 PICTURE "@!"
    @  7, 10 SAY "Saleno 5" GET Message->Saleno5 PICTURE "@!"
    READ
    UNLOCK
    SELECT WkDeb
    GOTO TOP
    ApFlock( 3 )
    DO WHILE WkDeb->( !Eof() )
        WkDeb->Sale1   := 0
        WkDeb->Sale2   := 0
        WkDeb->Sale3   := 0
        WkDeb->Sale4   := 0
        WkDeb->Sale5   := 0
        WkDeb->Prof1   := 0
        WkDeb->Prof2   := 0
        WkDeb->Prof3   := 0
        WkDeb->Prof4   := 0
        WkDeb->Prof5   := 0
        WkDeb->LYSale1 := 0
        WkDeb->LYSale2 := 0
        WkDeb->LYSale3 := 0
        WkDeb->LYSale4 := 0
        WkDeb->LYSale5 := 0
        WkDeb->LYProf1 := 0
        WkDeb->LYProf2 := 0
        WkDeb->LYProf3 := 0
        WkDeb->LYProf4 := 0
        WkDeb->LYProf5 := 0
        SKIP ALIAS WkDeb
    ENDDO
    UNLOCK

    WkDates()                           // Below

    SELECT DebProf
    GOTO TOP
    ApFLock( 3 )
    INDEX ON DbDate TO TempI04
    SET INDEX TO TempI04
    UNLOCK
    GOTO TOP
    SELECT DebProf
    DO WHILE DebProf->( !Eof() )
        SELECT WkEnds
        IF Year( DebProf->DbDate ) = Year( Date() )
            GOTO 1            // This Year
        ELSE
            GOTO 2            // Last Year
        ENDIF
        SELECT DebProf
        DO CASE

        CASE DebProf->DbDate < WkEnds->Wk1
            SELECT WkDeb
            GOTO 1
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()             // This Year
            ELSE
                WkDebFunc()             // Last Year
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk2
            SELECT WkDeb
            GOTO 2
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()             // This Year
            ELSE
                WkDebFunc()             // Last Year
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk3
            SELECT WkDeb
            GOTO 3
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk4
            SELECT WkDeb
            GOTO 4
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk5
            SELECT WkDeb
            GOTO 5
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk6
            SELECT WkDeb
            GOTO 6
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk7
            SELECT WkDeb
            GOTO 7
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk8
            SELECT WkDeb
            GOTO 8
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk9
            SELECT WkDeb
            GOTO 9
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk10
            SELECT WkDeb
            GOTO 10
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk11
            SELECT WkDeb
            GOTO 11
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk12
            SELECT WkDeb
            GOTO 12
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk13
            SELECT WkDeb
            GOTO 13
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk14
            SELECT WkDeb
            GOTO 14
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk15
            SELECT WkDeb
            GOTO 15
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk16
            SELECT WkDeb
            GOTO 16
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk17
            SELECT WkDeb
            GOTO 17
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk18
            SELECT WkDeb
            GOTO 18
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk19
            SELECT WkDeb
            GOTO 19
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk20
            SELECT WkDeb
            GOTO 20
            WkDebFunc()
        CASE DebProf->DbDate < WkEnds->Wk21
            SELECT WkDeb
            GOTO 21
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk22
            SELECT WkDeb
            GOTO 22
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk23
            SELECT WkDeb
            GOTO 23
            WkDebFunc()
        CASE DebProf->DbDate < WkEnds->Wk24
            SELECT WkDeb
            GOTO 24
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk25
            SELECT WkDeb
            GOTO 25
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk26
            SELECT WkDeb
            GOTO 26
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk27
            SELECT WkDeb
            GOTO 27
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk28
            SELECT WkDeb
            GOTO 29
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk30
            SELECT WkDeb
            GOTO 30
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk31
            SELECT WkDeb
            GOTO 31
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk32
            SELECT WkDeb
            GOTO 32
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk33
            SELECT WkDeb
            GOTO 33
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk34
            SELECT WkDeb
            GOTO 34
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk35
            SELECT WkDeb
            GOTO 35
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk36
            SELECT WkDeb
            GOTO 36
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk37
            SELECT WkDeb
            GOTO 37
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk38
            SELECT WkDeb
            GOTO 38
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk39
            SELECT WkDeb
            GOTO 39
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk40
            SELECT WkDeb
            GOTO 40
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk41
            SELECT WkDeb
            GOTO 41
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk42
            SELECT WkDeb
            GOTO 42
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk43
            SELECT WkDeb
            GOTO 43
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk44
            SELECT WkDeb
            GOTO 44
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk45
            SELECT WkDeb
            GOTO 45
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk46
            SELECT WkDeb
            GOTO 46
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk47
            SELECT WkDeb
            GOTO 47
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk48
            SELECT WkDeb
            GOTO 48
            WkDebFunc()
        CASE DebProf->DbDate < WkEnds->Wk49
            SELECT WkDeb
            GOTO 49
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk50
            SELECT WkDeb
            GOTO 50
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk51
            SELECT WkDeb
            GOTO 51
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk52
            SELECT WkDeb
            GOTO 52
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        CASE DebProf->DbDate < WkEnds->Wk53
            SELECT WkDeb
            GOTO 53
            IF Year( DebProf->DbDate ) = Year( Date() )
                WkDebYear()
            ELSE
                WkDebFunc()
            ENDIF
        ENDCASE
        SELECT DebProf
        SKIP ALIAS DebProf
    ENDDO                       // DebProf EOF

    WkDebPrnt()

    SELECT DebProf
    SET INDEX TO DebProfI

    RETURN NIL
// **** End WkDebprof

// *-------------------------------------------------------------------

STATIC FUNCTION WkDebFunc()                    // Last Year

    namount := DebProf->Amount
    // ****GST     -( DebProf->Amount/9 )
    // ****  nProfGST := DebProf->CostItem*( ( Control->GSTRate/100 )+1 )
    SELECT WkDeb
    ApRLock( 3 )
    DO CASE
    CASE DebProf->Saleno = Message->Saleno1
        WkDeb->LySale1 += namount
        WkDeb->LyProf1 += ( namount - DebProf->CostItem )
    CASE DebProf->Saleno = Message->Saleno2
        WkDeb->LySale2 += namount
        WkDeb->LyProf2 += ( namount - DebProf->CostItem )
    CASE DebProf->Saleno = Message->Saleno3
        WkDeb->LySale3 += namount
        WkDeb->LyProf3 += ( namount - DebProf->CostItem )
    CASE DebProf->Saleno = Message->Saleno4
        WkDeb->LySale4 += namount
        WkDeb->LyProf4 += ( namount - DebProf->CostItem )
    CASE DebProf->Saleno = Message->Saleno5
        WkDeb->LySale5 += namount
        WkDeb->LyProf5 += ( namount - DebProf->CostItem )
    ENDCASE                                // Saleno
    UNLOCK

    RETURN NIL
// ***** End of WkDebFunc()

// *-------------------------------------------------------------------

STATIC FUNCTION WkDebYear()

    ApRLock( 3 )

    namount := DebProf->Amount
    // **   GST                     -( DebProf->Amount/9 )
    SELECT WkDeb
    // ***   nProfGST := DebProf->CostItem*( ( Control->GSTRate/100 )+1 )
    DO CASE
    CASE DebProf->Saleno = Message->Saleno1
        WkDeb->Sale1 += namount
        WkDeb->Prof1 += ( namount - DebProf->CostItem )
    CASE DebProf->Saleno = Message->Saleno2
        WkDeb->Sale2 += namount
        WkDeb->Prof2 += ( namount - DebProf->CostItem )
    CASE DebProf->Saleno = Message->Saleno3
        WkDeb->Sale3 += namount
        WkDeb->Prof3 += ( namount - DebProf->CostItem )
    CASE DebProf->Saleno = Message->Saleno4
        WkDeb->Sale4 += namount
        WkDeb->Prof4 += ( namount - DebProf->CostItem )
    CASE DebProf->Saleno = Message->Saleno5
        WkDeb->Sale5 += namount
        WkDeb->Prof5 += ( namount - DebProf->CostItem )
    ENDCASE                                // Saleno
    UNLOCK

    RETURN NIL
// ***** End of WkDebYear()

// *-------------------------------------------------------------------

STATIC FUNCTION WkDates()

    Scroll(  18, 0, 24, 80 )
    DispBox( 18, 5, 24, 75, 2 )
    @ 20, 33 SAY "Select Start Dates"
    SELECT WKEnds
    GOTO 1
    ApFLock( 3 )
    @ 21, 10 SAY "THIS Year First Week Date" GET WkEnds->WK1 PICTURE "99/99/9999"
    READ
    GOTO 2
    @ 22, 10 SAY "LAST Year First Week Date" GET WkEnds->WK1 PICTURE "99/99/9999"
    READ
    UNLOCK
    ApFLock( 3 )
    GOTO 1
    DO WHILE Wkends->( !Eof() )
        ddate := Wkends->WK1 + 7
        Wkends->WK2 := ddate
        ddate := ddate + 7
        Wkends->WK3 := ddate
        ddate := ddate + 7
        Wkends->WK4 := ddate
        ddate := ddate + 7
        Wkends->WK5 := ddate
        ddate := ddate + 7
        Wkends->WK6 := ddate
        ddate := ddate + 7
        Wkends->WK7 := ddate
        ddate := ddate + 7
        Wkends->WK8 := ddate
        ddate := ddate + 7
        Wkends->WK9 := ddate
        ddate := ddate + 7
        Wkends->WK10 := ddate
        ddate := ddate + 7
        Wkends->WK11 := ddate
        ddate := ddate + 7
        Wkends->WK12 := ddate
        ddate := ddate + 7
        Wkends->WK13 := ddate
        ddate := ddate + 7
        Wkends->WK14 := ddate
        ddate := ddate + 7
        Wkends->WK15 := ddate
        ddate := ddate + 7
        Wkends->WK16 := ddate
        ddate := ddate + 7
        Wkends->WK17 := ddate
        ddate := ddate + 7
        Wkends->WK18 := ddate
        ddate := ddate + 7
        Wkends->WK19 := ddate
        ddate := ddate + 7
        Wkends->WK20 := ddate
        ddate := ddate + 7
        Wkends->WK21 := ddate
        ddate := ddate + 7
        Wkends->WK22 := ddate
        ddate := ddate + 7
        Wkends->WK23 := ddate
        ddate := ddate + 7
        Wkends->WK24 := ddate
        ddate := ddate + 7
        Wkends->WK25 := ddate
        ddate := ddate + 7
        Wkends->WK26 := ddate
        ddate := ddate + 7
        Wkends->WK27 := ddate
        ddate := ddate + 7
        Wkends->WK28 := ddate
        ddate := ddate + 7
        Wkends->WK29 := ddate
        ddate := ddate + 7
        Wkends->WK30 := ddate
        ddate := ddate + 7
        Wkends->WK31 := ddate
        ddate := ddate + 7
        Wkends->WK32 := ddate
        ddate := ddate + 7
        Wkends->WK33 := ddate
        ddate := ddate + 7
        Wkends->WK34 := ddate
        ddate := ddate + 7
        Wkends->WK35 := ddate
        ddate := ddate + 7
        Wkends->WK36 := ddate
        ddate := ddate + 7
        Wkends->WK37 := ddate
        ddate := ddate + 7
        Wkends->WK38 := ddate
        ddate := ddate + 7
        Wkends->WK39 := ddate
        ddate := ddate + 7
        Wkends->WK40 := ddate
        ddate := ddate + 7
        Wkends->WK41 := ddate
        ddate := ddate + 7
        Wkends->WK42 := ddate
        ddate := ddate + 7
        Wkends->WK43 := ddate
        ddate := ddate + 7
        Wkends->WK44 := ddate
        ddate := ddate + 7
        Wkends->WK45 := ddate
        ddate := ddate + 7
        Wkends->WK46 := ddate
        ddate := ddate + 7
        Wkends->WK47 := ddate
        ddate := ddate + 7
        Wkends->WK48 := ddate
        ddate := ddate + 7
        Wkends->WK49 := ddate
        ddate := ddate + 7
        Wkends->WK50 := ddate
        ddate := ddate + 7
        Wkends->WK51 := ddate
        ddate := ddate + 7
        Wkends->WK52 := ddate
        ddate := ddate + 7
        Wkends->WK53 := ddate
        ddate := ddate + 7
        SKIP ALIAS Wkends
    ENDDO
    UNLOCK
    GOTO 1
    @ 21, 50 SAY WkEnds->WK52
    @ 21, 61 SAY WkEnds->WK53
    GOTO 2
    @ 22, 50 SAY WkEnds->WK52
    @ 21, 61 SAY WkEnds->WK53

    @ 14, 10 SAY "Please Wait"
    @ 15, 10 SAY "Working Very Hard"
    @ 16, 10 SAY "Please WAIT"

    RETURN NIL
// *** End WkDates()

// *-------------------------------------------------------------------

STATIC FUNCTION WkDebPrnt()

    mwhere := "S"
    npl := 54

    Printsel( mwhere, npl )                        // _LF_Init

    IF mwhere = "P"
        npl := 54
    ELSE
        npl := 17
    ENDIF
    @  0, 0 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + " " + Str( Year( Date() ), 5 )
    @  0, 25 SAY Trim( Control->U_Name )
    @  2, 0 SAY "Amounts Less GST"
    @  2, 24 SAY Message->Saleno1 + "      " + Message->Saleno2 + "      ";
        + Message->Saleno3 + "      " + Message->Saleno4 + "      ";
        + Message->Saleno5 + "      " + "Total"
    nl := 3
    ntotsale := ntotsale1 := ntotsale2 := ntotsale3 := ntotsale4 := ntotsale5 := 0
    ntotProf := ntotProf1 := ntotProf2 := ntotProf3 := ntotProf4 := ntotProf5 := 0
    ntotlysale := ntotlysale1 := ntotlysale2 := 0
    ntotlysale3 := ntotlysale4 := ntotlysale5 := 0
    ntotlyprof := ntotlyprof1 := ntotlyprof2 := 0
    ntotlyprof3 := ntotlyprof4 := ntotlyprof5 := 0
    SELECT WkDeb
    GOTO TOP
    DO WHILE WkDeb->( !Eof() )
        IF nl > npl
            IF mwhere = "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            @  0, 0 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + " " + Str( Year( Date() ), 5 )
            @  0, 25 SAY Trim( Control->U_Name )
            @  2, 0 SAY "Amounts Less GST"
            @  2, 24 SAY Message->Saleno1 + "      " + Message->Saleno2 + "      ";
                + Message->Saleno3 + "      " + Message->Saleno4 + "      ";
                + Message->Saleno5 + "      " + "Total"
            nl := 3
        ENDIF              // nl
        IF WkDeb->Sale1 + WkDeb->Sale2 + WkDeb->Sale3 + WkDeb->Sale4 + WkDeb->Sale5 > 0
            // / First Record is Start Date so no Entry
            @  nl, 0 SAY Str( ( RecNo() -1 ), 2 )       // No 2 is First
            @  nl, 6 SAY "This Year"
            @  nl, 20 SAY WkDeb->Sale1 PICTURE "9999,999"
            ntotsale1 += WkDeb->Sale1
            @  nl, 32 SAY WkDeb->Sale2 PICTURE "9999,999"
            ntotsale2 += WkDeb->Sale2
            @  nl, 42 SAY WkDeb->Sale3 PICTURE "9999,999"
            ntotsale3 += WkDeb->Sale3
            @  nl, 52 SAY WkDeb->Sale4 PICTURE "9999,999"
            ntotsale4 += WkDeb->Sale4
            @  nl, 62 SAY WkDeb->Sale5 PICTURE "9999,999"
            ntotsale5 += WkDeb->Sale5
            nsale := WkDeb->Sale1 + WkDeb->Sale2 + WkDeb->Sale3;
                + WkDeb->Sale4 + WkDeb->Sale5
            @  nl, 71 SAY nSale PICTURE "9999,999"
            ntotsale += nSale
            nl++
            @  nl, 6 SAY "Last Year"
            @  nl, 20 SAY WkDeb->LySale1 PICTURE "9999,999"
            ntotlysale1 += WkDeb->LySale1
            @  nl, 32 SAY WkDeb->LySale2 PICTURE "9999,999"
            ntotlysale2 += WkDeb->LySale2
            @  nl, 42 SAY WkDeb->LySale3 PICTURE "9999,999"
            ntotlysale3 += WkDeb->LySale3
            @  nl, 52 SAY WkDeb->LySale4 PICTURE "9999,999"
            ntotlysale4 += WkDeb->LySale4
            @  nl, 62 SAY WkDeb->LySale5 PICTURE "9999,999"
            ntotlysale5 += WkDeb->LySale5
            nLySale := WkDeb->LySale1 + WkDeb->LySale2 + WkDeb->LySale3;
                + WkDeb->LySale4 + WkDeb->LySale5
            @  nl, 71 SAY nLySale PICTURE "9999,999"
            ntotlysale += nLySale
            nl++
            @  nl, 6 SAY "Diff"
            IF WkDeb->Sale1 > 0 .AND. WkDeb->LySale1 > 0
                @  nl, 20 SAY WkDeb->Sale1 - WkDeb->LySale1 PICTURE "9999,999"
            ENDIF
            IF WkDeb->Sale2 > 0 .AND. WkDeb->LySale2 > 0
                @  nl, 32 SAY WkDeb->Sale2 - WkDeb->LySale2 PICTURE "9999,999"
            ENDIF
            IF WkDeb->Sale3 > 0 .AND. WkDeb->LySale3 > 0
                @  nl, 42 SAY WkDeb->Sale3 - WkDeb->LySale3 PICTURE "9999,999"
            ENDIF
            IF WkDeb->Sale4 > 0 .AND. WkDeb->LySale4 > 0
                @  nl, 52 SAY WkDeb->Sale4 - WkDeb->LySale4 PICTURE "9999,999"
            ENDIF
            IF WkDeb->Sale5 > 0 .AND. WkDeb->LySale5 > 0
                @  nl, 62 SAY WkDeb->Sale5 - WkDeb->LySale5 PICTURE "9999,999"
            ENDIF
            IF nsale > 0 .AND. nlysale > 0
                @  nl, 71 SAY nsale - nLySale PICTURE "9999,999"
            ENDIF
            nl++
            @  nl, 6 SAY "Week Profit"
            @  nl, 20 SAY WkDeb->Prof1 PICTURE "9999,999"
            ntotprof1 += WkDeb->Prof1
            @  nl, 32 SAY WkDeb->Prof2 PICTURE "9999,999"
            ntotprof2 += WkDeb->Prof2
            @  nl, 42 SAY WkDeb->Prof3 PICTURE "9999,999"
            ntotprof3 += WkDeb->Prof3
            @  nl, 52 SAY WkDeb->Prof4 PICTURE "9999,999"
            ntotprof4 += WkDeb->Prof4
            @  nl, 62 SAY WkDeb->Prof5 PICTURE "9999,999"
            ntotprof5 += WkDeb->Prof5
            nprof := WkDeb->Prof1 + WkDeb->Prof2 + WkDeb->Prof3;
                + WkDeb->Prof4 + WkDeb->Prof5
            @  nl, 71 SAY nprof PICTURE "9999,999"
            ntotprof += nprof
            nl += 2
        ENDIF                            // WkDeb->Sale1 = 0
        SKIP ALIAS WkDeb
    ENDDO                       // Eof WkDeb
    nl++
    @  nl, 0 SAY "Tot   This Year"
    @  nl, 20 SAY ntotSale1 PICTURE "9999,999"
    @  nl, 32 SAY ntotSale2 PICTURE "9999,999"
    @  nl, 42 SAY ntotSale3 PICTURE "9999,999"
    @  nl, 52 SAY ntotSale4 PICTURE "9999,999"
    @  nl, 62 SAY ntotSale5 PICTURE "9999,999"
    @  nl, 71 SAY ntotsale PICTURE "9999,999"
    nl++
    @  nl, 0 SAY "Tot   Last Year"
    @  nl, 20 SAY ntotLySale1 PICTURE "9999,999"
    @  nl, 32 SAY ntotLySale2 PICTURE "9999,999"
    @  nl, 42 SAY ntotLySale3 PICTURE "9999,999"
    @  nl, 52 SAY ntotLySale4 PICTURE "9999,999"
    @  nl, 62 SAY ntotLySale5 PICTURE "9999,999"
    @  nl, 71 SAY ntotLySale PICTURE "9999,999"
    nl++
    @  nl, 0 SAY "Tot   Diff"
    @  nl, 20 SAY ntotSale1 - ntotlysale1 PICTURE "9999,999"
    @  nl, 32 SAY ntotSale2 - ntotlysale2 PICTURE "9999,999"
    @  nl, 42 SAY ntotSale3 - ntotlysale3 PICTURE "9999,999"
    @  nl, 52 SAY ntotSale4 - ntotlysale4 PICTURE "9999,999"
    @  nl, 62 SAY ntotSale5 - ntotlysale5 PICTURE "9999,999"
    @  nl, 71 SAY ntotsale - ntotlysale   PICTURE "9999,999"
    nl++
    IF mwhere == "S"
        nl += 2
        Inkey( 0 )
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ELSE
        EndPrint()
    ENDIF

    RETURN NIL
// *** End WkDebPrnt()

// *** ----------- END OF FILE    ZSM_NAME.PRG
