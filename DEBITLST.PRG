// **  JK  20-06-11 08:36:06

/*
   Program......:               DEBITLST.PRG
   Authors......: J Kirby
   Date.........: 12/04/1985
   Functions....: ChriConsN, Deblst
   Not used.....: ChriPName
*/

// (c) Copyright 1993 by Kirby Christchurch.

FUNCTION ChriConsN()

    Scroll()
    mok := "Y"
    DO WHILE mok == "Y"
        Scroll()
        @ 10, 10 SAY "Account Year Sales Only"
        mwhere := "S"
        npl := 54

        Printsel( mwhere, npl )                        // _LF_Init

        IF mwhere = "P"
            npl := 56
        ELSE
            npl := 20
        ENDIF
        Scroll()
        SELECT Name
        GOTO TOP
        npn := 1
        nl  := 4
        nrecno := 0
        @  0, 0 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + " " + Str( Year( Date() ), 5 )
        @  0, 21 SAY Trim( Control->U_Name )
        @  0, 60 SAY "Page"
        @  0, 65 SAY npn PICTURE "999"
        @  2, 25 SAY "Acc From"
        @  2, 35 SAY Control->Acc_Date
        @  2, 46 SAY "To"
        @  2, 51 SAY ( Control->Acc_Date ) + 364
        ddate3 := Month( Date() ) -3
        ddate2 := Month( Date() ) -2
        ddate1 := Month( Date() ) -1
        @  4, 24 SAY ddate3
        @  4, 34 SAY ddate2
        @  4, 44 SAY ddate1
        @  4, 58 SAY CMonth( Date() )
        @  4, 66 SAY "Acc Yr Td"
        nl := 5
        ntotqty3 := ntotqty2 := ntotqty1 := ntotqty := nTotal := 0
        ntotcost3 := ntotcost2 := ntotcost1 := ntotcost := ncosttot := 0
        SELECT Name
        DO WHILE Name->( !Eof() )
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                nl := 4
                npn := npn + 1
                @  0, 0 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + " " + Str( Year( Date() ), 5 )
                @  0, 21 SAY Trim( Control->U_Name )
                @  0, 60 SAY "Page"
                @  0, 65 SAY npn PICTURE "999"
                @  2, 25 SAY "Acc From"
                @  2, 35 SAY Control->Acc_Date
                @  2, 46 SAY "To"
                @  2, 51 SAY ( Control->Acc_Date ) + 364
                @  4, 24 SAY ddate3
                @  4, 34 SAY ddate2
                @  4, 44 SAY ddate1
                @  4, 58 SAY CMonth( Date() )
                @  4, 66 SAY "Acc Yr Td"
                nl := 5
            ENDIF
            SELECT Hist
            SET ORDER TO 1
            GOTO TOP
            SEEK Name->Codeno
            nqtytotal := 0
            nqty := nqty1 := nqty2 := nqty3 := 0
            DO WHILE Hist->Codeno = Name->Codeno .AND. Hist->( !Eof() )
                IF SubStr( Hist->Partnum, 1, 4 ) == "FREI"
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                IF Hist->PDate < Control->Acc_Date
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                IF Hist->PDate >= ( ( Control->Acc_Date ) + 364 )
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                ntotal    += Hist->Amount * Hist->Qty
                nqtytotal += Hist->Amount * Hist->Qty
                ncosttot  += Hist->Cost * Hist->Qty
                IF Month( Hist->PDate ) < ( Month( Date() ) -3 )
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                DO CASE
                CASE Month( Hist->PDate ) == ( Month( Date() ) -3 )
                    nqty3     += Hist->Amount * Hist->Qty
                    ntotqty3  += Hist->Amount * Hist->Qty
                    ntotcost3 += Hist->Cost * Hist->Qty
                CASE Month( Hist->PDate ) == ( Month( Date() ) -2 )
                    nqty2     += Hist->Amount * Hist->Qty
                    ntotqty2  += Hist->Amount * Hist->Qty
                    ntotcost2 += Hist->Cost * Hist->Qty
                CASE Month( Hist->PDate ) == ( Month( Date() ) -1 )
                    nqty1     += Hist->Amount * Hist->Qty
                    ntotqty1  += Hist->Amount * Hist->Qty
                    ntotcost1 += Hist->Cost * Hist->Qty
                CASE Month( Hist->PDate ) == ( Month( Date() ) )
                    nqty     += Hist->Amount * Hist->Qty
                    ntotqty  += Hist->Amount * Hist->Qty
                    ntotcost += Hist->Cost * Hist->Qty
                ENDCASE
                SKIP ALIAS Hist
            ENDDO                                 // EOF Hist
            IF nqtyTotal > 0
                @ nl, 0 SAY SubStr( Name->Name, 1, 25 )
                @ nl, 26 SAY nqty3     PICTURE "9999,999"
                @ nl, 36 SAY nqty2     PICTURE "9999,999"
                @ nl, 46 SAY nqty1     PICTURE "9999,999"
                @ nl, 56 SAY nqty      PICTURE "9999,999"
                @ nl, 66 SAY nqtyTotal PICTURE "9999,999.99"
                nl++
            ENDIF
            SELECT Name
            SKIP ALIAS Name
        ENDDO                                    // EOF Name
        nl++
        @ nl, 4 SAY "Total Sell less GST"
        @ nl, 24 SAY ntotqty3 PICTURE "99999,999"
        @ nl, 35 SAY ntotqty2 PICTURE "99999,999"
        @ nl, 46 SAY ntotqty1 PICTURE "99999,999"
        @ nl, 56 SAY ntotqty  PICTURE "99999,999"
        @ nl, 66 SAY nTotal   PICTURE "99999,999"
        nl += 2
        @ nl, 6 SAY "Total Cost"
        @ nl, 24 SAY ntotcost3 PICTURE "99999,999"
        @ nl, 36 SAY ntotcost2 PICTURE "99999,999"
        @ nl, 46 SAY ntotcost1 PICTURE "99999,999"
        @ nl, 56 SAY ntotcost  PICTURE "99999,999"
        @ nl, 66 SAY ncosttot  PICTURE "999999,999"
        nl++
        @ nl, 30 SAY ( ( ntotqty3 - ntotcost3 ) / ntotqty3 ) * 100 PICTURE "9999 %"
        @ nl, 40 SAY ( ( ntotqty2 - ntotcost2 ) / ntotqty2 ) * 100 PICTURE "9999 %"
        @ nl, 50 SAY ( ( ntotqty1 - ntotcost1 ) / ntotqty1 ) * 100 PICTURE "9999 %"
        @ nl, 60 SAY ( ( ntotqty - ntotcost   ) / ntotqty  ) * 100 PICTURE "9999 %"
        @ nl, 72 SAY ( ( ntotal - ncosttot    ) / ntotal   ) * 100 PICTURE "9999 %"
        IF mwhere == "S"
            WAIT
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        mok := ApGetN( Message->Another + "Print out" )
    ENDDO

    RETURN NIL

// **------------ End of ChriConsN()

// **--------------------------------------------------------------------------

FUNCTION ChriPName()

    Scroll()
    DispBox( 0, 1, 2, 79, 2 )
    @  1, 10 SAY "Display is 4 Years To Date"
    dendmm   := Year( Date() )
    IF PressedEsc()
        RETURN NIL
    ENDIF
    dstmm    := dendmm - 3
    mpartnum := Space( 20 )
    aPart_ := {}
    nrecno := 0
    SELECT Hist
    SET ORDER TO 2                      // Partnum
    @  4, 1 SAY "Records In File"
    @  5, 1 SAY LastRec()
    @  7, 1 SAY dstmm
    @  8, 6 SAY dendmm
    @ 12, 0 SAY "Please Wait THIS TAKES TIME"
    GOTO TOP
    DO WHILE Hist->( !Eof() )
        IF Hist->Qty <= 0
            SKIP ALIAS Hist
            LOOP
        ENDIF
        IF SubStr( Hist->Partnum, 1, 4 ) = "FREI"
            SKIP ALIAS Hist
            LOOP
        ENDIF
        IF Year( Hist->PDate ) < dstmm
            SKIP ALIAS Hist
            LOOP
        ENDIF
        IF Year( Hist->PDate ) > dendmm
            SKIP ALIAS Hist
            LOOP
        ENDIF
        IF Hist->Partnum != mpartnum
            SELECT Part
            SEEK Hist->Partnum
            SELECT Hist
            AAdd( aPart_, Hist->Partnum;
                + " " + Part->Desc;
                + "        " + Str( RecNo(), 6  ) )
            mpartnum := Hist->Partnum
        ENDIF
        SKIP ALIAS Hist
    ENDDO
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        Scroll()
        manother := "Y"
        DO WHILE manother = "Y"
            Scroll()
            DispBox( 0, 1, 24, 65, 2 )
            anum  := AChoice( 1, 2, 23, 64, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            SELECT Hist
            SET ORDER TO 2                  // Partnum
            GOTO nrecno
            mpartnum := Hist->Partnum
            SELECT Part
            SET ORDER TO 1
            SEEK mpartnum
            SEEK Hist->Partnum
            mcontinue := "Y"
            DO WHILE mcontinue == "Y"
                mcodeno := Space( 8 )
                aPartN_ := {}
                nrecnoN := 0
                SELECT Hist
                GOTO TOP
                SEEK mpartnum
                IF Found()
                    DO WHILE Hist->Partnum == mpartnum .AND. Hist->( !Eof() )
                        IF Hist->Qty <= 0
                            SKIP ALIAS Hist
                            LOOP
                        ENDIF
                        IF SubStr( Hist->Partnum, 1, 4 ) = "FREI"
                            SKIP ALIAS Hist
                            LOOP
                        ENDIF
                        IF Hist->Partnum != mpartnum
                            SKIP ALIAS Hist
                            LOOP
                        ENDIF
                        IF Year( Hist->PDate ) < dstmm
                            SKIP ALIAS Hist
                            LOOP
                        ENDIF
                        IF Year( Hist->PDate ) > dendmm
                            SKIP ALIAS Hist
                            LOOP
                        ENDIF
                        IF Hist->Codeno != mcodeno
                            SELECT Name
                            SEEK Hist->Codeno
                            SELECT Hist
                            AAdd( aPartN_, Hist->Codeno;
                                + " " + Name->Name;
                                + "        " + Str( RecNo(), 6  ) )
                            mcodeno := Hist->Codeno
                        ENDIF
                        SKIP ALIAS Hist
                    ENDDO
                    IF !Empty( aPartN_ )
                        Scroll()
                        DispBox( 0, 1, 24, 45, 2 )
                        ASort( aPart_,,, {| x, y | x < y } )
                        DispBox(  8, 46, 20, 79, 2 )
                        @  9, 48 SAY mpartnum
                        @ 10, 48 SAY SubStr( Part->Desc, 1, 30 )
                        anumN := AChoice( 1, 2, 23, 44, aPartN_,, "AFUNC" )
                        IF PressedEsc()
                            mcontinue := "N"
                            EXIT
                        ENDIF
                        nrecnoN := Val( Right( aPartN_[ anumN ],6 ) )
                        GOTO nrecnoN
                        mcodeno := Hist->Codeno
                    ENDIF
                ENDIF                 // Found
                DispBox(  8, 46, 20, 79, 2 )
                @  9, 48 SAY mpartnum
                @ 10, 48 SAY SubStr( Part->Desc, 1, 30 )
                @ 12, 48 SAY "Now Select NAME"
                @ 14, 48 SAY "Name" GET mcodeno PICTURE "@K!"
                @ 16, 48 SAY "Blank for All Names"
                READ
                ntotal := ntotqty := 0
                nmonth1 := nmonth2 := nmonth3 := nmonth4 := nmonth5 := nmonth6 := 0
                nmonth7 := nmonth8 := nmonth9 := nmonth10 := nmonth11 := nmonth12 := 0
                n1total := n1totqty := 0
                n1month1 := n1month2 := n1month3 := n1month4 := n1month5 := n1month6 := 0
                n1month7 := n1month8 := n1month9 := n1month10 := n1month11 := n1month12 := 0
                n2total := n2totqty := 0
                n2month1 := n2month2 := n2month3 := n2month4 := n2month5 := n2month6 := 0
                n2month7 := n2month8 := n2month9 := n2month10 := n2month11 := n2month12 := 0
                n3total := n3totqty := 0
                n3month1 := n3month2 := n3month3 := n3month4 := n3month5 := n3month6 := 0
                n3month7 := n3month8 := n3month9 := n3month10 := n3month11 := n3month12 := 0

                SELECT Hist
                // **    SET ORDER TO 2              // Partnum
                GOTO TOP
                IF LastRec() != 0
                    SEEK mpartnum
                    IF Found()
                        DO WHILE Hist->Partnum == mpartnum .AND. Hist->( !Eof() )
                            IF Hist->Qty <= 0
                                SKIP ALIAS Hist
                                LOOP
                            ENDIF
                            IF SubStr( Hist->Partnum, 1, 4 ) = "FREI"
                                SKIP ALIAS Hist
                                LOOP
                            ENDIF
                            IF mcodeno != Space( 8 )
                                IF Hist->Codeno != mcodeno
                                    SKIP ALIAS Hist
                                    LOOP
                                ENDIF
                            ENDIF
                            IF Year( Hist->PDate ) < dstmm
                                SKIP ALIAS Hist
                                LOOP
                            ENDIF
                            IF Year( Hist->PDate ) > dendmm
                                SKIP ALIAS Hist
                                LOOP
                            ENDIF
                            IF Year( Hist->Pdate ) = dendmm
                                DO CASE
                                CASE Month( Hist->Pdate ) = 1
                                    nmonth1 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 2
                                    nmonth2 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 3
                                    nmonth3 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 4
                                    nmonth4 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 5
                                    nmonth5 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 6
                                    nmonth6 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 7
                                    nmonth7 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 8
                                    nmonth8 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 9
                                    nmonth9 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 10
                                    nmonth10 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 11
                                    nmonth11 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 12
                                    nmonth12 += Hist->Qty
                                ENDCASE
                                ntotal  += Hist->Amount * Hist->Qty
                                ntotqty += Hist->Qty
                            ENDIF                    // YEAR
                            IF Year( Hist->Pdate ) = ( dendmm - 1 )
                                DO CASE
                                CASE Month( Hist->Pdate ) = 1
                                    n1month1 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 2
                                    n1month2 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 3
                                    n1month3 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 4
                                    n1month4 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 5
                                    n1month5 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 6
                                    n1month6 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 7
                                    n1month7 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 8
                                    n1month8 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 9
                                    n1month9 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 10
                                    n1month10 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 11
                                    n1month11 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 12
                                    n1month12 += Hist->Qty
                                ENDCASE
                                n1total  += Hist->Amount * Hist->Qty
                                n1totqty += Hist->Qty
                            ENDIF                    // YEAR
                            IF Year( Hist->Pdate ) = ( dendmm - 2 )
                                DO CASE
                                CASE Month( Hist->Pdate ) = 1
                                    n2month1 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 2
                                    n2month2 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 3
                                    n2month3 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 4
                                    n2month4 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 5
                                    n2month5 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 6
                                    n2month6 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 7
                                    n2month7 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 8
                                    n2month8 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 9
                                    n2month9 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 10
                                    n2month10 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 11
                                    n2month11 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 12
                                    n2month12 += Hist->Qty
                                ENDCASE
                                n2total  += Hist->Amount * Hist->Qty
                                n2totqty += Hist->Qty
                            ENDIF                    // YEAR
                            IF Year( Hist->Pdate ) = ( dendmm - 3 )
                                DO CASE
                                CASE Month( Hist->Pdate ) = 1
                                    n3month1 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 2
                                    n3month2 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 3
                                    n3month3 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 4
                                    n3month4 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 5
                                    n3month5 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 6
                                    n3month6 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 7
                                    n3month7 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 8
                                    n3month8 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 9
                                    n3month9 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 10
                                    n3month10 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 11
                                    n3month11 += Hist->Qty
                                CASE Month( Hist->Pdate ) = 12
                                    n3month12 += Hist->Qty
                                ENDCASE
                                n3total  += Hist->Amount * Hist->Qty
                                n3totqty += Hist->Qty
                            ENDIF                    // YEAR
                            SELECT Hist
                            SKIP ALIAS Hist
                        ENDDO                             // EOF
                        Scroll(  0, 0, 24, 80 )
                        DispBox( 1, 1, 12, 38, 2 )
                        // **         SELECT Part
                        // **         SET ORDER TO 1
                        // **         SEEK mpartnum
                        @  1, 74      SAY dendmm          PICTURE "9999"
                        @  2, 3      SAY Part->Partnum
                        @  3, 3      SAY SubStr( Part->Desc, 1, 32 )
                        @  4, 3      SAY Part->Trade     PICTURE "$99,999.99"
                        @  4, Col() + 2 SAY "Sell"
                        @  4, Col() + 2 SAY Part->Wholesale PICTURE "$99,999.99"
                        @  6, 3      SAY dstmm           PICTURE "9999"
                        @  6, Col() + 2 SAY dendmm          PICTURE "9999"
                        @  6, Col() + 2 SAY mcodeno
                        SELECT Name
                        SEEK mcodeno
                        @  8, 3      SAY Name->Name
                        @ 10, 3      SAY ( n3totqty + n2totqty + n1totqty + ntotqty ) PICTURE "999,999.99"
                        @ 10, Col() + 1 SAY ( n3total + n2total + n1total + ntotal )     PICTURE "$999,999.99"
                        SELECT Months
                        GOTO 12
                        @  2, 40 SAY Months->Brief
                        @  2, 74 SAY nmonth1 PICTURE "9,999"
                        GOTO 11
                        @  3, 40 SAY Months->Brief
                        @  3, 74 SAY nmonth2 PICTURE "9,999"
                        GOTO 10
                        @  4, 40 SAY Months->Brief
                        @  4, 74 SAY nmonth3 PICTURE "9,999"
                        GOTO  9
                        @  5, 40 SAY Months->Brief
                        @  5, 74 SAY nmonth4 PICTURE "9,999"
                        GOTO  8
                        @  6, 40 SAY Months->Brief
                        @  6, 74 SAY nmonth5 PICTURE "9,999"
                        GOTO  7
                        @  7, 40 SAY Months->Brief
                        @  7, 74 SAY nmonth6 PICTURE "9,999"
                        GOTO  6
                        @  8, 40 SAY Months->Brief
                        @  8, 74 SAY nmonth7 PICTURE "9,999"
                        GOTO  5
                        @  9, 40 SAY Months->Brief
                        @  9, 74 SAY nmonth8 PICTURE "9,999"
                        GOTO  4
                        @ 10, 40 SAY Months->Brief
                        @ 10, 74 SAY nmonth9 PICTURE "9,999"
                        GOTO  3
                        @ 11, 40 SAY Months->Brief
                        @ 11, 74 SAY nmonth10 PICTURE "9,999"
                        GOTO  2
                        @ 12, 40 SAY Months->Brief
                        @ 12, 74 SAY nmonth11 PICTURE "9,999"
                        GOTO  1
                        @ 13, 40 SAY Months->Brief
                        @ 13, 74 SAY nmonth12 PICTURE "9,999"
                        @ 22, 73 SAY dendmm
                        @ 23, 71 SAY ntotqty PICTURE "99,999.99"
                        @ 24, 70 SAY ntotal  PICTURE "$99,999.99"

                        @  1, 64 SAY dendmm - 1 PICTURE "9999"
                        @  2, 64 SAY n1month1 PICTURE "9,999"
                        @  3, 64 SAY n1month2 PICTURE "9,999"
                        @  4, 64 SAY n1month3 PICTURE "9,999"
                        @  5, 64 SAY n1month4 PICTURE "9,999"
                        @  6, 64 SAY n1month5 PICTURE "9,999"
                        @  7, 64 SAY n1month6 PICTURE "9,999"
                        @  8, 64 SAY n1month7 PICTURE "9,999"
                        @  9, 64 SAY n1month8 PICTURE "9,999"
                        @ 10, 64 SAY n1month9 PICTURE "9,999"
                        @ 11, 64 SAY n1month10 PICTURE "9,999"
                        @ 12, 64 SAY n1month11 PICTURE "9,999"
                        @ 13, 64 SAY n1month12 PICTURE "9,999"
                        @ 22, 58 SAY dendmm - 1
                        @ 23, 59 SAY n1totqty PICTURE "999,999.99"
                        @ 24, 58 SAY n1total  PICTURE "$999,999.99"

                        @  1, 56 SAY dendmm - 2 PICTURE "9999"
                        @  2, 56 SAY n2month1 PICTURE "9,999"
                        @  3, 56 SAY n2month2 PICTURE "9,999"
                        @  4, 56 SAY n2month3 PICTURE "9,999"
                        @  5, 56 SAY n2month4 PICTURE "9,999"
                        @  6, 56 SAY n2month5 PICTURE "9,999"
                        @  7, 56 SAY n2month6 PICTURE "9,999"
                        @  8, 56 SAY n2month7 PICTURE "9,999"
                        @  9, 56 SAY n2month8 PICTURE "9,999"
                        @ 10, 56 SAY n2month9 PICTURE "9,999"
                        @ 11, 56 SAY n2month10 PICTURE "9,999"
                        @ 12, 56 SAY n2month11 PICTURE "9,999"
                        @ 13, 56 SAY n2month12 PICTURE "9,999"
                        @ 22, 46 SAY dendmm - 2
                        @ 23, 47 SAY n2totqty PICTURE "999,999.99"
                        @ 24, 46 SAY n2total  PICTURE "$999,999.99"

                        @  1, 49 SAY dendmm - 3  PICTURE "9999"
                        @  2, 49 SAY n3month1  PICTURE "9,999"
                        @  3, 49 SAY n3month2  PICTURE "9,999"
                        @  4, 49 SAY n3month3  PICTURE "9,999"
                        @  5, 49 SAY n3month4  PICTURE "9,999"
                        @  6, 49 SAY n3month5  PICTURE "9,999"
                        @  7, 49 SAY n3month6  PICTURE "9,999"
                        @  8, 49 SAY n3month7  PICTURE "9,999"
                        @  9, 49 SAY n3month8  PICTURE "9,999"
                        @ 10, 49 SAY n3month9  PICTURE "9,999"
                        @ 11, 49 SAY n3month10 PICTURE "9,999"
                        @ 12, 49 SAY n3month11 PICTURE "9,999"
                        @ 13, 49 SAY n3month12 PICTURE "9,999"
                        @ 22, 38 SAY dendmm - 3  PICTURE "9999"
                        @ 23, 18 SAY ( n3totqty + n2totqty + n1totqty + ntotqty ) PICTURE "999,999.99"
                        @ 23, 35 SAY n3totqty  PICTURE "999,999.99"
                        @ 24, 17 SAY ( n3total + n2total + n1total + ntotal ) PICTURE "$999,999.99"
                        @ 24, 34 SAY n3total   PICTURE "$999,999.99"
                    ELSE
                        Scroll( 3, 0, 24, 80 )
                        @ 10, 10 SAY "No History"
                        Inkey( 0 )
                    ENDIF
                ENDIF                    // LastRec Not 0
                @ 21, 1 SAY "Esc = New Part"
                @ 22, 1 SAY "Any Key"
                @ 23, 1 SAY "= Name"
                @ 24, 1 SAY " "
                Inkey( 0 )
                IF PressedEsc()
                    mcontinue := "N"
                ELSE
                    mcontinue := "Y"
                ENDIF
                // ** ApGetY( TRIM( Message->Another )+" Name" )
            ENDDO
            manother := "Y"
            // *** ApGetN( TRIM( Message->Another )+" Part" )
        ENDDO
    ENDIF

    RETURN NIL
// ***---- End of ChrisPName

// **---------------------------------------------------------------------*

FUNCTION Deblst()

    SELECT Debit
    GOTO TOP
    ApFLock( 3 )
    INDEX ON DToS( Debit->Startdate ) + Debit->Invno TO TempInd1
    SET INDEX TO TempInd1
    UNLOCK

    mcodeno := mcodeind := Space( 8 )
    mamount := mamntind := 0
    mselect := "J"
    Scroll()
    DispBox( 0, 14, 2, 58, 2 )
    @  1, 23 SAY "LIST Jobs by Start Date"
    mwhere := "S"
    npl    := 65

    Printsel( mwhere )                                     // _LP_Init

    @  0, 0 SAY Control->U_Name
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    nl := 2
    GOTO TOP
    DO WHILE Debit->( !Eof() )
        IF Debit->Stat != mselect
            SKIP ALIAS Debit
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
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            nl := 2
        ENDIF
        mcodeno := Debit->Codeno
        SELECT Name
        SEEK mcodeno
        @ nl, 2 SAY Name->Name
        SELECT Debit
        mamount  += Debit->Amount
        mamntind += Debit->Amount
        @ nl, 34 SAY Debit->Est            // 35
        nl++
        @ nl, 4 SAY Debit->Invno
        @ nl, 12 SAY Debit->DBdate
        @ nl, 26 SAY Debit->StartDate
        @ nl, 50 SAY Debit->DueDate
        nl++
        SKIP ALIAS Debit
    ENDDO
    IF mwhere = "P"
        EndPrint()
    ELSE
        WAIT
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF
    SELECT Debit
    SET INDEX TO DebInd

    RETURN NIL

// **------ End of File Deblst

// **********---------------------  END OF FILE DEBITLST.PRG
