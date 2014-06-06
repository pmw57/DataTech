// ** JK 02-04-11 17:41:07

/*
   Program.....:            XLF_DEB2.PRG
   Author......: J Kirby
   Date........: 05/05/2007
   Functions...: DebitProf
   Static funcs: CostsAll
*/

// (c) Copyright 1993 by Kirby Christchurch.

STATIC FUNCTION CostsAll()

    SELECT Cashbook
    GOTO TOP
    mstat := Space( 2 )
    DO WHILE Cashbook->( !Eof() )
        IF SubStr( Cashbook->Cashno, 3, 2 ) != "AA"
            SKIP ALIAS CashBook
            LOOP
        ENDIF
        IF SubStr( Cashbook->Cashno, 3, 2 ) = "  "
            SKIP ALIAS CashBook
            LOOP
        ENDIF
        IF mwhere = "S"
            nl  := 20
            npl := 18
        ENDIF
        mstat     := SubStr( CashBook->Cashno, 1, 2 )
        mcashbook := SubStr( CashBook->CBName, 5, 20 )
        IF nl > npl
            IF mwhere = "S"
                WAIT
                Scroll()
                nl := 2
            ELSE
                EJECT
                nl := 0
            ENDIF
        ENDIF
        ntotal0 := nqty0 := nqty01 := nqty02 := nqty03 := 0
        nqty04 :=  nqty05 := nqty06 := nqty07 := nqty08 := nqty09 := 0
        nqty010 := nqty011 := nqty012 := 0
        ntotal1 := nqty1 := nqty11 := nqty12 := nqty13 := 0
        nqty14 :=  nqty15 := nqty16 := nqty17 := nqty18 := nqty19 := 0
        nqty110 := nqty111 := nqty112 := 0
        ntotal2 := nqty2 := nqty21 := nqty22 := nqty23 := 0
        nqty24 :=  nqty25 := nqty26 := nqty27 := nqty28 := nqty29 := 0
        nqty210 := nqty211 := nqty212 := 0

        ntotal3 := nqty3 := nqty31 := nqty32 := nqty33 := 0
        nqty34 :=  nqty35 := nqty36 := nqty37 := nqty38 := nqty39 := 0
        nqty310 := nqty311 := nqty312 := 0

        ntotal4 := nqty4 := nqty41 := nqty42 := nqty43 := 0
        nqty44 :=  nqty45 := nqty46 := nqty47 := nqty48 := nqty49 := 0
        nqty410 := nqty411 := nqty412 := 0
        nrecno := RecNo()
        SELECT Pay
        GOTO TOP
        DO WHILE Pay->( !Eof() )
            IF SubStr( Pay->Cashno, 1, 2 ) != mstat
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF Pay->Amount = 0
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF Year( Pay->Cheqdate ) = dyear    //
                ntotal0 += Pay->Amount - Pay->GSTAmnt
                DO CASE
                CASE Month( Pay->Cheqdate ) = 12
                    nqty012 += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 11
                    nqty011 += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 10
                    nqty010 += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 9
                    nqty09  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 8
                    nqty08  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 7
                    nqty07  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 6
                    nqty06  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 5
                    nqty05  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 4
                    nqty04  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 3
                    nqty03  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 2
                    nqty02  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 1
                    nqty01  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = ( Month( Date() ) )
                    nqty0   += Pay->Amount - Pay->GSTAmnt
                ENDCASE
            ENDIF
            IF Year( Pay->Cheqdate ) = dyear - 1    //
                ntotal1 += Pay->Amount - Pay->GSTAmnt
                DO CASE
                CASE Month( Pay->Cheqdate ) = 12
                    nqty112 += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 11
                    nqty111 += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 10
                    nqty110 += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 9
                    nqty19  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 8
                    nqty18  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 7
                    nqty17  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 6
                    nqty16  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 5
                    nqty15  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 4
                    nqty14  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 3
                    nqty13  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 2
                    nqty12  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 1
                    nqty11  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = ( Month( Date() ) )
                    nqty1   += Pay->Amount - Pay->GSTAmnt
                ENDCASE
            ENDIF
            IF Year( Pay->Cheqdate ) = dyear - 2    //
                ntotal2 += Pay->Amount - Pay->GSTAmnt
                DO CASE
                CASE Month( Pay->Cheqdate ) = 12
                    nqty212 += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 11
                    nqty211 += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 10
                    nqty210 += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 9
                    nqty29  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 8
                    nqty28  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 7
                    nqty27  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 6
                    nqty26  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 5
                    nqty25  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 4
                    nqty24  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 3
                    nqty23  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 2
                    nqty22  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 1
                    nqty21  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = ( Month( Date() ) )
                    nqty2   += Pay->Amount - Pay->GSTAmnt
                ENDCASE
            ENDIF
            IF Year( Pay->Cheqdate ) = dyear - 3    //
                ntotal3 += Pay->Amount - Pay->GSTAmnt
                DO CASE
                CASE Month( Pay->Cheqdate ) = 12
                    nqty312 += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 11
                    nqty311 += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 10
                    nqty310 += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 9
                    nqty39  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 8
                    nqty38  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 7
                    nqty37  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 6
                    nqty36  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 5
                    nqty35  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 4
                    nqty34  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 3
                    nqty33  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 2
                    nqty32  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = 1
                    nqty31  += Pay->Amount - Pay->GSTAmnt
                CASE Month( Pay->Cheqdate ) = ( Month( Date() ) )
                    nqty3   += Pay->Amount - Pay->GSTAmnt
                ENDCASE
            ENDIF
            SKIP ALIAS Pay
        ENDDO
        IF nqty012 + nqty112 + nqty212 + nqty312 > 1
            @ nl, 0 SAY mcashbook
            @ nl, 23 SAY LTrim( Str( dyear ) )
            @ nl, 37 SAY LTrim( Str( dyear - 1 ) )
            @ nl, 53 SAY LTrim( Str( dyear - 2 ) )
            @ nl, 70 SAY LTrim( Str( dyear - 3 ) )
            nl++
            SELECT Months
            GOTO 12
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty01 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty11 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty21 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty31 PICTURE "9,999,999.99"
            nl++
            GOTO 11               // Feb
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty02 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty12 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty22 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty32 PICTURE "9,999,999.99"
            nl++
            GOTO 10             // March
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty03 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty13 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty23 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty33 PICTURE "9,999,999.99"
            nl++
            GOTO 9             // April
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty04 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty14 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty24 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty34 PICTURE "9,999,999.99"
            nl++
            GOTO 8             // May
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty05 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty15 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty25 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty35 PICTURE "9,999,999.99"
            nl++
            GOTO 7             // June
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty06 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty16 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty26 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty36 PICTURE "9,999,999.99"
            nl++
            GOTO 6             // July
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty07 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty17 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty27 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty37 PICTURE "9,999,999.99"
            nl++
            GOTO 5             // Aug
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty08 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty18 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty28 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty38 PICTURE "9,999,999.99"
            nl++
            GOTO 4             // Sept
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty09 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty19 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty29 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty39 PICTURE "9,999,999.99"
            nl++
            GOTO 3             // Oct
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty010 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty110 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty210 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty310 PICTURE "9,999,999.99"
            nl++
            GOTO 2             // Nov
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty011 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty111 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty211 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty311 PICTURE "9,999,999.99"
            nl++
            GOTO 1             // Dec
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty012 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty112 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty212 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty312 PICTURE "9,999,999.99"
            nl++
            @ nl, 17 SAY "-------------"
            @ nl, 31 SAY "-------------"
            @ nl, 47 SAY "-------------"
            @ nl, 64 SAY "-------------"
            nl++
            @ nl, 0 SAY "Year Total - GST"
            @ nl, 16 SAY nTotal0 PICTURE "$99,999,999.99"
            @ nl, 31 SAY nTotal1 PICTURE "$99,999,999.99"
            @ nl, 47 SAY nTotal2 PICTURE "$99,999,999.99"
            @ nl, 64 SAY nTotal3 PICTURE "$99,999,999.99"
            nl += 2
        ENDIF                       // Totals > 1
        SELECT CashBook
        SKIP ALIAS CashBook
    ENDDO

    RETURN NIL
// ** End of CostsAll()

// *---------------------------------------------------------------------*

FUNCTION DebitProf()

    mok := "Y"
    DO WHILE mok == "Y"

        Scroll()
        mtotal := "N"
        @  5, 10 SAY "Sales Listing"
        DispBox( 7, 1, 12, 79, 2 )
        mstmm  := Date() -30
        mendmm := Date()
        @  8, 10 SAY Message->Frdate GET mstmm  PICTURE "99/99/9999"
        @ 10, 10 SAY Message->Todate GET mendmm PICTURE "99/99/9999"
        READ
        @ 14, 10 SAY "Updating GST Please wait " + SubStr( Message->Saleno5, 1, 2 )
        SELECT DebProf
        GOTO TOP
        nl := 1
        DO WHILE DebProf->( !Eof() )
            IF SubStr( DebProf->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                ApRLock( 3 )
                DebProf->GSTAmnt := 0
                UNLOCK
                SKIP ALIAS DebProf
                LOOP
            ENDIF
            ApRLock( 3 )
            DebProf->GSTAmnt := DebProf->Amount - ( DebProf->Amount / ( ( Control->GSTRate / 100 ) + 1 ) )
            UNLOCK
            SKIP ALIAS DebProf
        ENDDO
        @ 16, 10 SAY "OK Done the GST on Credits " + SubStr( Message->Saleno5, 1, 2 )
        @ 18, 10 SAY "Select Invoice Details ONLY if dates are close"
        mcodeno   := Space( 8 )
        mcashbook := Space( 20 )
        minvoice  := ApGetN( "Invoice Details" )
        mselect   := ApGetN( " Select one Name" )
        mdirect   := ApGetN( "Select Costs Analysis" )
        mstat     := "  "
        IF mdirect = "Y"
            mtotal := ApGetN( "All Costs Analysis" )
            IF mtotal = "Y"
                mdirect := "N"              // So no display below
            ENDIF              // mtotal
            IF mtotal = "N"
                SELECT Cashbook
                GOTO TOP
                aPart_ := {}
                DO WHILE Cashbook->( !Eof() )
                    IF SubStr( Cashbook->Cashno, 3, 2 ) != "AA"
                        SKIP ALIAS CashBook
                        LOOP
                    ENDIF
                    AAdd( aPart_, Cashbook->Cashno;
                        + " " + CashBook->CBName;
                        + "        " + Str( RecNo(), 6 ) )
                    SKIP ALIAS CashBook
                ENDDO
                IF !Empty( aPart_ )
                    Scroll(  0, 45, 24, 80 )
                    DispBox( 0, 45, 24, 79, 2 )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice( 1, 47, 23, 77, aPart_,, "AFUNC" )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                    mstat     := SubStr( CashBook->Cashno, 1, 2 )
                    mcashbook := SubStr( CashBook->CBName, 5, 20 )
                ENDIF
            ENDIF               // mtotal
        ENDIF                 // mdirect
        IF mselect = "Y"

            SELECT Name

            NameRank( mcodeno )

            IF LastKey() = 27
                RETURN NIL
            ENDIF
            mcodeno := Name->Codeno
        ENDIF
        Scroll()

        mwhere := "P"

        Printsel( mwhere )                                     // _LP_Init
        IF mwhere = "P"
            npl := 62     // was 65
        ELSE
            npl := 20
        ENDIF

        DebProfhd()                           // Below

        SELECT DebProf
        GOTO TOP
        ApFLock( 3 )
        INDEX ON Saleno TO TempDbPr
        SET INDEX TO TempDbPr
        UNLOCK
        GOTO TOP
        namnttot := ncosttot := nGSTAmnt := 0
        csaleno := Space( 4 )
        DO WHILE DebProf->( !Eof() )
            IF nl > npl
                nl++
                @ nl, 4 SAY "Report Continued on Next Page"
                IF mwhere == "P"
                    EJECT

                    DebProfhd()                             // Below

                ELSE
                    Inkey()
                    Scroll()
                    nl := 2
                ENDIF
            ENDIF
            csaleno := DebProf->Saleno
            namount := nCostItem := 0
            DO WHILE DebProf->Saleno = csaleno .AND. DebProf->( !Eof() )
                IF mselect = "Y"
                    IF Debprof->Codeno <> mcodeno
                        SKIP ALIAS Debprof
                        LOOP
                    ENDIF
                ENDIF
                IF DebProf->Amount = 0
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF DebProf->DbDate < mstmm          // Includes the Date From
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF DebProf->DbDate > mendmm         // Includes the Date Up to
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                // **         namount   += DebProf->Amount-( DebProf->Amount/9 ) // LESS GST
                nGSTAmnt += DebProf->Amount
                IF SubStr( Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    namount += DebProf->Amount
                ELSE
                    namount += DebProf->Amount - DebProf->GSTAmnt // LESS GST
                ENDIF
                ncostItem += DebProf->CostItem
                SKIP ALIAS DebProf
            ENDDO                                 // Saleno
            namnttot += namount
            ncosttot += ncostItem
            @ nl, 10 SAY csaleno
            @ nl, 20 SAY namount           PICTURE "9,999,999.99"
            @ nl, 35 SAY ncostItem         PICTURE "9,999,999.99"
            @ nl, 50 SAY namount - ncostItem PICTURE "9,999,999.99"
            @ nl, 65 SAY ( ( ( namount - ncostItem ) / namount ) * 100 ) PICTURE "9999%"
            nl++
            // ***      SKIP ALIAS DebProf
        ENDDO                        // DebProf EOF()
        @ nl, 20 SAY "------------"
        @ nl, 35 SAY "------------"
        @ nl, 50 SAY "------------"
        nl++
        // **   @ nl, 0 SAY "Incl GST"
        // **   @ nl,10 SAY nGSTAmnt PICTURE "9,999,999"
        @ nl, 20 SAY namnttot          PICTURE "9,999,999.99"
        @ nl, 35 SAY ncosttot          PICTURE "9,999,999.99"
        @ nl, 50 SAY namnttot - ncosttot PICTURE "9,999,999.99"
        @ nl, 64 SAY ( ( ( namnttot - ncosttot ) / namnttot ) * 100 ) PICTURE "9999 %"
        nl++
        IF mwhere = "S"
            nl := 2
            WAIT
            Scroll()
        ENDIF
        IF minvoice = "Y"
            // **   @ nl, 0 SAY Name->Name // no good for all
            // **   nl++
            @  nl, 0 SAY "Date       Invoice  Name      Amount+GST      GST"
            @  nl, 52 SAY "Amount-GST    Cost-GST"
            nl += 2
            SELECT DebProf
            SET ORDER TO 2                   // Invno
            GOTO TOP
            namount := ncostitem := nAmntGst := 0
            DO WHILE DebProf->( !Eof() )
                IF mselect = "Y"
                    IF Debprof->Codeno <> mcodeno
                        SKIP ALIAS Debprof
                        LOOP
                    ENDIF
                ENDIF
                IF DebProf->Amount = 0
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF DebProf->DbDate < mstmm          // Includes the Date From
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF DebProf->DbDate > mendmm         // Includes the Date Up to
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF nl > npl
                    IF mwhere = "S"
                        WAIT
                        Scroll()
                    ELSE
                        EJECT
                    ENDIF
                    nl := 0
                    @  nl, 0 SAY "Date       Invoice  Name      Amount+GST      GST"
                    @  nl, 52 SAY "Amount-GST    Cost-GST"
                    nl += 2
                ENDIF

                @ nl, 0 SAY DebProf->Dbdate
                @ nl, 11 SAY DebProf->Invno
                @ nl, 18 SAY DebProf->Codeno
                SELECT DebProf
                @ nl, 28 SAY DebProf->Amount                  PICTURE "9999,999.99"
                @ nl, 40 SAY DebProf->GSTAmnt                 PICTURE "9999,999.99"
                @ nl, 51 SAY DebProf->Amount - DebProf->GSTAmnt PICTURE "9999,999.99"
                namount  += DebProf->Amount - DebProf->GSTAmnt
                nAmntGst += DebProf->Amount
                IF DebProf->CostItem > DebProf->Amount
                    ApRLock( 3 )
                    DebProf->CostItem := DebProf->Amount - DebProf->GSTAmnt
                    UNLOCK
                ENDIF
                @ nl, 61 SAY DebProf->CostItem PICTURE "9999,999.99"
                ncostitem += DebProf->CostItem
                @ nl, 74 SAY DebProf->Saleno
                nl++
                SELECT DebProf
                SKIP ALIAS DebProf
            ENDDO
            @ nl, 28 SAY Replicate( "-", 12 )
            @ nl, 50 SAY Replicate( "-", 29 )
            nl++
            @ nl, 28 SAY nAmntGst  PICTURE  "9999,999.99"
            @ nl, 50 SAY namount   PICTURE  "9999,999.99"
            @ nl, 61 SAY ncostItem PICTURE  "9999,999.99"
            @ nl, 73 SAY ( ( namount - ncostitem ) / namount ) * 100 PICTURE  "9999 %"
            nl += 2
            IF mwhere = "S"
                nl := 2
                WAIT
                Scroll()
            ENDIF
        ENDIF            // minvoice
        // **************************************
        SELECT Debprof
        SET ORDER TO 1              // Codeno
        mchoice := 1
        dyear := Year( Date() )
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
        // **   IF mselect = "Y"
        // **      SEEK Name->Codeno
        // **   ENDIF
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
                    nqty3ny  += DebProf->Amount - DebProf->GSTAmnt
                    ncosttot  += DebProf->Amount
                    nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                    ntotal    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 2
                    nqty2ny  += DebProf->Amount - DebProf->GSTAmnt
                    ncosttot  += DebProf->Amount
                    nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                    ntotal    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 1
                    nqty1ny  += DebProf->Amount - DebProf->GSTAmnt
                    ncosttot  += DebProf->Amount
                    nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                    ntotal    += DebProf->Amount - DebProf->GSTAmnt
                ENDCASE
                SKIP ALIAS Debprof
                LOOP
            ENDIF                  // YEAR +1
            // ****************
            IF Year( Debprof->DbDate ) = dyear - 2
                DO CASE
                CASE Month( Debprof->DbDate ) = 3
                    nqty3ly2  += DebProf->Amount - DebProf->GSTAmnt
                    ncosttotly  += DebProf->Amount
                    nqtytotally += DebProf->Amount - DebProf->GSTAmnt
                    ntotally    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 2
                    nqty2ly2  += DebProf->Amount - DebProf->GSTAmnt
                    ncosttotly  += DebProf->Amount
                    nqtytotally += DebProf->Amount - DebProf->GSTAmnt
                    ntotally    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 1
                    nqty1ly2  += DebProf->Amount - DebProf->GSTAmnt
                    ncosttotly  += DebProf->Amount
                    nqtytotally += DebProf->Amount - DebProf->GSTAmnt
                    ntotally    += DebProf->Amount - DebProf->GSTAmnt
                ENDCASE
                SKIP ALIAS Debprof
                LOOP
            ENDIF                  // YEAR - 2

            // ******************
            IF Year( Debprof->DbDate ) = dyear - 1
                DO CASE
                CASE Month( Debprof->DbDate ) = 12          // Dec
                    nqty12ly += DebProf->Amount - DebProf->GSTAmnt
                    ncosttotly  += DebProf->Amount
                    nqtytotally += DebProf->Amount - DebProf->GSTAmnt
                    ntotally    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 11          // Nov
                    nqty11ly += DebProf->Amount - DebProf->GSTAmnt
                    ncosttotly  += DebProf->Amount
                    nqtytotally += DebProf->Amount - DebProf->GSTAmnt
                    ntotally    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 10
                    nqty10ly += DebProf->Amount - DebProf->GSTAmnt
                    ncosttotly  += DebProf->Amount
                    nqtytotally += DebProf->Amount - DebProf->GSTAmnt
                    ntotally    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) =  9
                    nqty9ly  += DebProf->Amount - DebProf->GSTAmnt
                    ncosttotly  += DebProf->Amount
                    nqtytotally += DebProf->Amount - DebProf->GSTAmnt
                    ntotally    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 8
                    nqty8ly  += DebProf->Amount - DebProf->GSTAmnt
                    ncosttotly  += DebProf->Amount
                    nqtytotally += DebProf->Amount - DebProf->GSTAmnt
                    ntotally    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 7
                    nqty7ly  += DebProf->Amount - DebProf->GSTAmnt
                    ncosttotly  += DebProf->Amount
                    nqtytotally += DebProf->Amount - DebProf->GSTAmnt
                    ntotally    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 6
                    nqty6ly  += DebProf->Amount - DebProf->GSTAmnt
                    ncosttotly  += DebProf->Amount
                    nqtytotally += DebProf->Amount - DebProf->GSTAmnt
                    ntotally    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 5
                    nqty5ly  += DebProf->Amount - DebProf->GSTAmnt
                    ncosttotly  += DebProf->Amount
                    nqtytotally += DebProf->Amount - DebProf->GSTAmnt
                    ntotally    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 4
                    nqty4ly  += DebProf->Amount - DebProf->GSTAmnt
                    ncosttotly  += DebProf->Amount
                    nqtytotally += DebProf->Amount - DebProf->GSTAmnt
                    ntotally    += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 3
                    nqty3ly  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 2
                    nqty2ly  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 1
                    nqty1ly  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = ( Month( Date() ) )
                    nqtyly   += DebProf->Amount - DebProf->GSTAmnt
                    // **               OTHERWISE
                    // **                  nqty13ly += DebProf->Amount-DebProf->GSTAmnt
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
                nqty12 += DebProf->Amount - DebProf->GSTAmnt
                ncosttot  += DebProf->Amount
                nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                ntotal    += DebProf->Amount - DebProf->GSTAmnt
            CASE Month( Debprof->DbDate ) = 11
                nqty11 += DebProf->Amount - DebProf->GSTAmnt
                ncosttot  += DebProf->Amount
                nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                ntotal    += DebProf->Amount - DebProf->GSTAmnt
            CASE Month( Debprof->DbDate ) = 10
                nqty10 += DebProf->Amount - DebProf->GSTAmnt
                ncosttot  += DebProf->Amount
                nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                ntotal    += DebProf->Amount - DebProf->GSTAmnt
            CASE Month( Debprof->DbDate ) =  9
                nqty9  += DebProf->Amount - DebProf->GSTAmnt
                ncosttot  += DebProf->Amount
                nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                ntotal    += DebProf->Amount - DebProf->GSTAmnt
            CASE Month( Debprof->DbDate ) = 8
                nqty8  += DebProf->Amount - DebProf->GSTAmnt
                ncosttot  += DebProf->Amount
                nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                ntotal    += DebProf->Amount - DebProf->GSTAmnt
            CASE Month( Debprof->DbDate ) = 7
                nqty7  += DebProf->Amount - DebProf->GSTAmnt
                ncosttot  += DebProf->Amount
                nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                ntotal    += DebProf->Amount - DebProf->GSTAmnt
            CASE Month( Debprof->DbDate ) = 6
                nqty6  += DebProf->Amount - DebProf->GSTAmnt
                ncosttot  += DebProf->Amount
                nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                ntotal    += DebProf->Amount - DebProf->GSTAmnt
            CASE Month( Debprof->DbDate ) = 5
                nqty5  += DebProf->Amount - DebProf->GSTAmnt
                ncosttot  += DebProf->Amount
                nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                ntotal    += DebProf->Amount - DebProf->GSTAmnt
            CASE Month( Debprof->DbDate ) = 4
                nqty4  += DebProf->Amount - DebProf->GSTAmnt
                ncosttot  += DebProf->Amount
                nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                ntotal    += DebProf->Amount - DebProf->GSTAmnt
            CASE Month( Debprof->DbDate ) = 3
                nqty3  += DebProf->Amount - DebProf->GSTAmnt
                nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                ntotal    += DebProf->Amount - DebProf->GSTAmnt
            CASE Month( Debprof->DbDate ) = 2
                nqty2  += DebProf->Amount - DebProf->GSTAmnt
                nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                ntotal    += DebProf->Amount - DebProf->GSTAmnt
            CASE Month( Debprof->DbDate ) = 1
                nqty1  += DebProf->Amount - DebProf->GSTAmnt
                nqtytotal += DebProf->Amount - DebProf->GSTAmnt
                ntotal    += DebProf->Amount - DebProf->GSTAmnt
            CASE Month( Debprof->DbDate ) = ( Month( Date() ) )
                nqty   += DebProf->Amount - DebProf->GSTAmnt
            ENDCASE
            SKIP ALIAS Debprof
        ENDDO                  // EOF Debprof

        IF mselect = "Y"
            @ nl, 0 SAY Name->Name
            nl++
        ENDIF
        @ nl, 0 SAY "Accnt Yr Sales NO GST"
        @ nl, 24 SAY LTrim( Str( dyear ) )
        @ nl, 38 SAY LTrim( Str( dyear - 1 ) )
        nl++
        SELECT Months
        GOTO 13
        nqtyTotal   := 0
        nqtyTotally := 0
        nrecno := RecNo()
        GOTO nrecno - 4
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty4     PICTURE "9,999,999.99"
        @ nl, 32 SAY nqty4ly   PICTURE "9,999,999.99"
        nqtyTotal   += nqty4
        nqtyTotally += nqty4ly
        nl++
        GOTO nrecno - 5
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty5     PICTURE "9,999,999.99"
        @ nl, 32 SAY nqty5ly   PICTURE "9,999,999.99"
        nqtyTotal   += nqty5
        nqtyTotally += nqty5ly
        nl++
        GOTO nrecno - 6
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty6     PICTURE "9,999,999.99"
        @ nl, 32 SAY nqty6ly   PICTURE "9,999,999.99"
        nqtyTotal   += nqty6
        nqtyTotally += nqty6ly
        nl++
        GOTO nrecno - 7
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty7     PICTURE "9,999,999.99"
        @ nl, 32 SAY nqty7ly   PICTURE "9,999,999.99"
        nqtyTotal   += nqty7
        nqtyTotally += nqty7ly
        nl++
        GOTO nrecno - 8
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty8     PICTURE "9,999,999.99"
        @ nl, 32 SAY nqty8ly   PICTURE "9,999,999.99"
        nqtyTotal   += nqty8
        nqtyTotally += nqty8ly
        nl++
        GOTO nrecno - 9
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty9     PICTURE "9,999,999.99"
        @ nl, 32 SAY nqty9ly   PICTURE "9,999,999.99"
        nqtyTotal   += nqty9
        nqtyTotally += nqty9ly
        nl++
        GOTO nrecno - 10
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty10    PICTURE "9,999,999.99"
        @ nl, 32 SAY nqty10ly  PICTURE "9,999,999.99"
        nqtyTotal   += nqty10
        nqtyTotally += nqty10ly
        nl++
        GOTO nrecno - 11
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty11    PICTURE "9,999,999.99"
        @ nl, 32 SAY nqty11ly  PICTURE "9,999,999.99"
        nqtyTotal   += nqty11
        nqtyTotally += nqty11ly
        nl++
        GOTO nrecno - 12
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty12    PICTURE "9,999,999.99"
        @ nl, 32 SAY nqty12ly  PICTURE "9,999,999.99"
        nqtyTotal   += nqty12
        nqtyTotally += nqty12ly
        nl++
        GOTO nrecno - 1
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty1ny    PICTURE "9,999,999.99"
        @ nl, 32 SAY nqty1      PICTURE "9,999,999.99"
        nqtyTotal   += nqty1ny
        nqtyTotally += nqty1
        nl++
        GOTO nrecno - 2
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty2ny    PICTURE "9,999,999.99"
        @ nl, 32 SAY nqty2      PICTURE "9,999,999.99"
        nqtyTotal   += nqty2ny
        nqtyTotally += nqty2
        nl++
        GOTO nrecno - 3
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 18 SAY nqty3ny    PICTURE "9,999,999.99"
        @ nl, 32 SAY nqty3      PICTURE "9,999,999.99"
        nqtyTotal   += nqty3ny
        nqtyTotally += nqty3
        nl++
        @ nl, 16 SAY "------------"
        @ nl, 30 SAY "------------"
        nl++
        @ nl, 0 SAY "Total - GST"
        @ nl, 14 SAY nqtyTotal   PICTURE "$99,999,999.99"
        @ nl, 29 SAY nqtyTotally PICTURE "$99,999,999.99"
        nl += 2
        @ nl, 0 SAY " "
        // **********************
        ntotal0 := nqty0 := nqty01 := nqty02 := nqty03 := 0
        nqty04 :=  nqty05 := nqty06 := nqty07 := nqty08 := nqty09 := 0
        nqty010 := nqty011 := nqty012 := 0

        ntotal1 := nqty1 := nqty11 := nqty12 := nqty13 := 0
        nqty14 :=  nqty15 := nqty16 := nqty17 := nqty18 := nqty19 := 0
        nqty110 := nqty111 := nqty112 := 0

        ntotal2 := nqty2 := nqty21 := nqty22 := nqty23 := 0
        nqty24 :=  nqty25 := nqty26 := nqty27 := nqty28 := nqty29 := 0
        nqty210 := nqty211 := nqty212 := 0

        ntotal3 := nqty3 := nqty31 := nqty32 := nqty33 := 0
        nqty34 :=  nqty35 := nqty36 := nqty37 := nqty38 := nqty39 := 0
        nqty310 := nqty311 := nqty312 := 0

        ntotal4 := nqty4 := nqty41 := nqty42 := nqty43 := 0
        nqty44 :=  nqty45 := nqty46 := nqty47 := nqty48 := nqty49 := 0
        nqty410 := nqty411 := nqty412 := 0
        nrecno := RecNo()
        SELECT DebProf
        GOTO TOP
        DO WHILE Debprof->( !Eof() )
            IF Year( Debprof->DbDate ) = dyear    //
                ntotal0 += DebProf->Amount - DebProf->GSTAmnt
                DO CASE
                CASE Month( Debprof->DbDate ) = 12
                    nqty012 += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 11
                    nqty011 += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 10
                    nqty010 += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 9
                    nqty09  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 8
                    nqty08  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 7
                    nqty07  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 6
                    nqty06  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 5
                    nqty05  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 4
                    nqty04  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 3
                    nqty03  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 2
                    nqty02  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 1
                    nqty01  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = ( Month( Date() ) )
                    nqty0   += DebProf->Amount - DebProf->GSTAmnt
                ENDCASE
            ENDIF
            IF Year( Debprof->DbDate ) = dyear - 1    //
                ntotal1 += DebProf->Amount - DebProf->GSTAmnt
                DO CASE
                CASE Month( Debprof->DbDate ) = 12
                    nqty112 += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 11
                    nqty111 += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 10
                    nqty110 += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 9
                    nqty19  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 8
                    nqty18  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 7
                    nqty17  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 6
                    nqty16  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 5
                    nqty15  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 4
                    nqty14  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 3
                    nqty13  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 2
                    nqty12  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 1
                    nqty11  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = ( Month( Date() ) )
                    nqty1   += DebProf->Amount - DebProf->GSTAmnt
                ENDCASE
            ENDIF
            IF Year( Debprof->DbDate ) = dyear - 2    //
                ntotal2 += DebProf->Amount - DebProf->GSTAmnt
                DO CASE
                CASE Month( Debprof->DbDate ) = 12
                    nqty212 += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 11
                    nqty211 += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 10
                    nqty210 += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 9
                    nqty29  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 8
                    nqty28  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 7
                    nqty27  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 6
                    nqty26  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 5
                    nqty25  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 4
                    nqty24  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 3
                    nqty23  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 2
                    nqty22  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 1
                    nqty21  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = ( Month( Date() ) )
                    nqty2   += DebProf->Amount - DebProf->GSTAmnt
                ENDCASE
            ENDIF
            IF Year( Debprof->DbDate ) = dyear - 3    //
                ntotal3 += DebProf->Amount - DebProf->GSTAmnt
                DO CASE
                CASE Month( Debprof->DbDate ) = 12
                    nqty312 += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 11
                    nqty311 += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 10
                    nqty310 += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 9
                    nqty39  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 8
                    nqty38  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 7
                    nqty37  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 6
                    nqty36  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 5
                    nqty35  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 4
                    nqty34  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 3
                    nqty33  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 2
                    nqty32  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = 1
                    nqty31  += DebProf->Amount - DebProf->GSTAmnt
                CASE Month( Debprof->DbDate ) = ( Month( Date() ) )
                    nqty3   += DebProf->Amount - DebProf->GSTAmnt
                ENDCASE
            ENDIF
            SKIP ALIAS Debprof
        ENDDO
        IF mwhere == "S"
            WAIT
            Scroll()
            nl := 2
        ENDIF
        @ nl, 0 SAY "Year Sales NO GST"
        @ nl, 23 SAY LTrim( Str( dyear ) )
        @ nl, 37 SAY LTrim( Str( dyear - 1 ) )
        @ nl, 53 SAY LTrim( Str( dyear - 2 ) )
        @ nl, 70 SAY LTrim( Str( dyear - 3 ) )
        nl++
        SELECT Months
        GOTO 12
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 20 SAY nqty01 PICTURE "9,999,999.99"
        @ nl, 34 SAY nqty11 PICTURE "9,999,999.99"
        @ nl, 50 SAY nqty21 PICTURE "9,999,999.99"
        @ nl, 67 SAY nqty31 PICTURE "9,999,999.99"
        nl++
        GOTO 11               // Feb
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 20 SAY nqty02 PICTURE "9,999,999.99"
        @ nl, 34 SAY nqty12 PICTURE "9,999,999.99"
        @ nl, 50 SAY nqty22 PICTURE "9,999,999.99"
        @ nl, 67 SAY nqty32 PICTURE "9,999,999.99"
        nl++
        GOTO 10             // March
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 20 SAY nqty03 PICTURE "9,999,999.99"
        @ nl, 34 SAY nqty13 PICTURE "9,999,999.99"
        @ nl, 50 SAY nqty23 PICTURE "9,999,999.99"
        @ nl, 67 SAY nqty33 PICTURE "9,999,999.99"
        nl++
        GOTO 9             // April
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 20 SAY nqty04 PICTURE "9,999,999.99"
        @ nl, 34 SAY nqty14 PICTURE "9,999,999.99"
        @ nl, 50 SAY nqty24 PICTURE "9,999,999.99"
        @ nl, 67 SAY nqty34 PICTURE "9,999,999.99"
        nl++
        GOTO 8             // May
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 20 SAY nqty05 PICTURE "9,999,999.99"
        @ nl, 34 SAY nqty15 PICTURE "9,999,999.99"
        @ nl, 50 SAY nqty25 PICTURE "9,999,999.99"
        @ nl, 67 SAY nqty35 PICTURE "9,999,999.99"
        nl++
        GOTO 7             // June
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 20 SAY nqty06 PICTURE "9,999,999.99"
        @ nl, 34 SAY nqty16 PICTURE "9,999,999.99"
        @ nl, 50 SAY nqty26 PICTURE "9,999,999.99"
        @ nl, 67 SAY nqty36 PICTURE "9,999,999.99"
        nl++
        GOTO 6             // July
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 20 SAY nqty07 PICTURE "9,999,999.99"
        @ nl, 34 SAY nqty17 PICTURE "9,999,999.99"
        @ nl, 50 SAY nqty27 PICTURE "9,999,999.99"
        @ nl, 67 SAY nqty37 PICTURE "9,999,999.99"
        nl++
        GOTO 5             // Aug
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 20 SAY nqty08 PICTURE "9,999,999.99"
        @ nl, 34 SAY nqty18 PICTURE "9,999,999.99"
        @ nl, 50 SAY nqty28 PICTURE "9,999,999.99"
        @ nl, 67 SAY nqty38 PICTURE "9,999,999.99"
        nl++
        GOTO 4             // Sept
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 20 SAY nqty09 PICTURE "9,999,999.99"
        @ nl, 34 SAY nqty19 PICTURE "9,999,999.99"
        @ nl, 50 SAY nqty29 PICTURE "9,999,999.99"
        @ nl, 67 SAY nqty39 PICTURE "9,999,999.99"
        nl++
        GOTO 3             // Oct
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 20 SAY nqty010 PICTURE "9,999,999.99"
        @ nl, 34 SAY nqty110 PICTURE "9,999,999.99"
        @ nl, 50 SAY nqty210 PICTURE "9,999,999.99"
        @ nl, 67 SAY nqty310 PICTURE "9,999,999.99"
        nl++
        GOTO 2             // Nov
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 20 SAY nqty011 PICTURE "9,999,999.99"
        @ nl, 34 SAY nqty111 PICTURE "9,999,999.99"
        @ nl, 50 SAY nqty211 PICTURE "9,999,999.99"
        @ nl, 67 SAY nqty311 PICTURE "9,999,999.99"
        nl++
        GOTO 1             // Dec
        @ nl, 0 SAY Months->Name + " " + Months->Dateno
        @ nl, 20 SAY nqty012 PICTURE "9,999,999.99"
        @ nl, 34 SAY nqty112 PICTURE "9,999,999.99"
        @ nl, 50 SAY nqty212 PICTURE "9,999,999.99"
        @ nl, 67 SAY nqty312 PICTURE "9,999,999.99"
        nl++
        @ nl, 17 SAY "-------------"
        @ nl, 31 SAY "-------------"
        @ nl, 47 SAY "-------------"
        @ nl, 64 SAY "-------------"
        nl++
        @ nl, 0 SAY "Year Total - GST"
        @ nl, 16 SAY nTotal0 PICTURE "$99,999,999.99"
        @ nl, 31 SAY nTotal1 PICTURE "$99,999,999.99"
        @ nl, 47 SAY nTotal2 PICTURE "$99,999,999.99"
        @ nl, 64 SAY nTotal3 PICTURE "$99,999,999.99"
        nl++
        // **********************************************************************
        IF mdirect = "Y"
            ntotal0 := nqty0 := nqty01 := nqty02 := nqty03 := 0
            nqty04 :=  nqty05 := nqty06 := nqty07 := nqty08 := nqty09 := 0
            nqty010 := nqty011 := nqty012 := 0

            ntotal1 := nqty1 := nqty11 := nqty12 := nqty13 := 0
            nqty14 :=  nqty15 := nqty16 := nqty17 := nqty18 := nqty19 := 0
            nqty110 := nqty111 := nqty112 := 0

            ntotal2 := nqty2 := nqty21 := nqty22 := nqty23 := 0
            nqty24 :=  nqty25 := nqty26 := nqty27 := nqty28 := nqty29 := 0
            nqty210 := nqty211 := nqty212 := 0

            ntotal3 := nqty3 := nqty31 := nqty32 := nqty33 := 0
            nqty34 :=  nqty35 := nqty36 := nqty37 := nqty38 := nqty39 := 0
            nqty310 := nqty311 := nqty312 := 0

            ntotal4 := nqty4 := nqty41 := nqty42 := nqty43 := 0
            nqty44 :=  nqty45 := nqty46 := nqty47 := nqty48 := nqty49 := 0
            nqty410 := nqty411 := nqty412 := 0
            nrecno := RecNo()
            SELECT Pay
            GOTO TOP
            DO WHILE Pay->( !Eof() )
                IF SubStr( Pay->Cashno, 1, 2 ) != mstat
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF Pay->Amount = 0
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF Year( Pay->Cheqdate ) = dyear    //
                    ntotal0 += Pay->Amount - Pay->GSTAmnt
                    DO CASE
                    CASE Month( Pay->Cheqdate ) = 12
                        nqty012 += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 11
                        nqty011 += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 10
                        nqty010 += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 9
                        nqty09  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 8
                        nqty08  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 7
                        nqty07  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 6
                        nqty06  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 5
                        nqty05  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 4
                        nqty04  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 3
                        nqty03  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 2
                        nqty02  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 1
                        nqty01  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = ( Month( Date() ) )
                        nqty0   += Pay->Amount - Pay->GSTAmnt
                    ENDCASE
                ENDIF
                IF Year( Pay->Cheqdate ) = dyear - 1    //
                    ntotal1 += Pay->Amount - Pay->GSTAmnt
                    DO CASE
                    CASE Month( Pay->Cheqdate ) = 12
                        nqty112 += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 11
                        nqty111 += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 10
                        nqty110 += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 9
                        nqty19  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 8
                        nqty18  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 7
                        nqty17  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 6
                        nqty16  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 5
                        nqty15  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 4
                        nqty14  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 3
                        nqty13  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 2
                        nqty12  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 1
                        nqty11  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = ( Month( Date() ) )
                        nqty1   += Pay->Amount - Pay->GSTAmnt
                    ENDCASE
                ENDIF
                IF Year( Pay->Cheqdate ) = dyear - 2    //
                    ntotal2 += Pay->Amount - Pay->GSTAmnt
                    DO CASE
                    CASE Month( Pay->Cheqdate ) = 12
                        nqty212 += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 11
                        nqty211 += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 10
                        nqty210 += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 9
                        nqty29  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 8
                        nqty28  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 7
                        nqty27  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 6
                        nqty26  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 5
                        nqty25  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 4
                        nqty24  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 3
                        nqty23  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 2
                        nqty22  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 1
                        nqty21  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = ( Month( Date() ) )
                        nqty2   += Pay->Amount - Pay->GSTAmnt
                    ENDCASE
                ENDIF
                IF Year( Pay->Cheqdate ) = dyear - 3    //
                    ntotal3 += Pay->Amount - Pay->GSTAmnt
                    DO CASE
                    CASE Month( Pay->Cheqdate ) = 12
                        nqty312 += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 11
                        nqty311 += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 10
                        nqty310 += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 9
                        nqty39  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 8
                        nqty38  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 7
                        nqty37  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 6
                        nqty36  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 5
                        nqty35  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 4
                        nqty34  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 3
                        nqty33  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 2
                        nqty32  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = 1
                        nqty31  += Pay->Amount - Pay->GSTAmnt
                    CASE Month( Pay->Cheqdate ) = ( Month( Date() ) )
                        nqty3   += Pay->Amount - Pay->GSTAmnt
                    ENDCASE
                ENDIF
                SKIP ALIAS Pay
            ENDDO
            IF mwhere == "S"
                WAIT
                Scroll()
                nl := 2
            ENDIF
            @ nl, 0 SAY mcashbook
            @ nl, 23 SAY LTrim( Str( dyear ) )
            @ nl, 37 SAY LTrim( Str( dyear - 1 ) )
            @ nl, 53 SAY LTrim( Str( dyear - 2 ) )
            @ nl, 70 SAY LTrim( Str( dyear - 3 ) )
            nl++
            SELECT Months
            GOTO 12
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty01 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty11 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty21 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty31 PICTURE "9,999,999.99"
            nl++
            GOTO 11               // Feb
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty02 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty12 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty22 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty32 PICTURE "9,999,999.99"
            nl++
            GOTO 10             // March
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty03 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty13 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty23 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty33 PICTURE "9,999,999.99"
            nl++
            GOTO 9             // April
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty04 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty14 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty24 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty34 PICTURE "9,999,999.99"
            nl++
            GOTO 8             // May
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty05 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty15 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty25 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty35 PICTURE "9,999,999.99"
            nl++
            GOTO 7             // June
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty06 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty16 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty26 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty36 PICTURE "9,999,999.99"
            nl++
            GOTO 6             // July
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty07 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty17 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty27 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty37 PICTURE "9,999,999.99"
            nl++
            GOTO 5             // Aug
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty08 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty18 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty28 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty38 PICTURE "9,999,999.99"
            nl++
            GOTO 4             // Sept
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty09 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty19 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty29 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty39 PICTURE "9,999,999.99"
            nl++
            GOTO 3             // Oct
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty010 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty110 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty210 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty310 PICTURE "9,999,999.99"
            nl++
            GOTO 2             // Nov
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty011 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty111 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty211 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty311 PICTURE "9,999,999.99"
            nl++
            GOTO 1             // Dec
            @ nl, 0 SAY Months->Name + " " + Months->Dateno
            @ nl, 20 SAY nqty012 PICTURE "9,999,999.99"
            @ nl, 34 SAY nqty112 PICTURE "9,999,999.99"
            @ nl, 50 SAY nqty212 PICTURE "9,999,999.99"
            @ nl, 67 SAY nqty312 PICTURE "9,999,999.99"
            nl++
            @ nl, 17 SAY "-------------"
            @ nl, 31 SAY "-------------"
            @ nl, 47 SAY "-------------"
            @ nl, 64 SAY "-------------"
            nl++
            @ nl, 0 SAY "Year Total - GST"
            @ nl, 16 SAY nTotal0 PICTURE "$99,999,999.99"
            @ nl, 31 SAY nTotal1 PICTURE "$99,999,999.99"
            @ nl, 47 SAY nTotal2 PICTURE "$99,999,999.99"
            @ nl, 64 SAY nTotal3 PICTURE "$99,999,999.99"
            nl += 2
        ENDIF      // Direct Costs
        IF mtotal = "Y"
            CostsAll()              // Above
        ENDIF     // mtotal
        IF mwhere == "P"
            EndPrint()
        ELSE
            WAIT
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Report" )
    ENDDO                           // mok
    SELECT DebProf
    SET INDEX TO DebProfI

    RETURN NIL

// ** End of DebitProf()

// *****------------ END OF FILE XLF_DEB2.PRG
