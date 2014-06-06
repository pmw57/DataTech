// ** JoKir12 10-12-11 17:24:06
// ** PWilk10 15-12-14 18:19:20 - Update EquAnal to use a more flexible
// **                             technique to search for modules, and
// **                             also removes the 4 level limit too.

/*  Program ......:                  XF_UTIL1.PRG
    Authors.......: John Kirby
    Date..........: 29/09/2013
    Functions.....: YearCat, YearPart, EquAnal, CheckPage, PartStock, PartABC, CostProf, FindEqu
    Static funcs..: AnalFindNext, AnalShowMod, AnalAfterMod, AnalShowDetails, AnalShowPart, AnalShowQty
*/

FUNCTION YearCat()

    nl := 0
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

    ccatno := Space( 12 )
    mwhere := "S"
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        ccatno := Space( 12 )
        Catarray( ccatno )
        ccatno := Cat->Catno
        DispBox( 0, 1, 2, 79, 2 )
        Scroll()
        @  1, 10 SAY "Display is 4 Years To Date " + ccatno
        dendmm   := Year( Date() )
        @  6, 10 SAY "Enter 2013 for 2013-2010, 2009 for 2009-2008 Records" COLOR "RG+"
        @  8, 10 SAY Message->Todate GET dendmm PICTURE "9999"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        dstmm    := dendmm - 3
        mpartnum := Space( 20 )
        aPart_ := {}
        nrecno := 0
        SELECT Part
        SET ORDER TO 1        // Partnum
        SELECT Hist
        SET ORDER TO 2        // Partnum
        @  4, 1 SAY "Records In File"
        @  5, 1 SAY LastRec()
        @  7, 1 SAY dstmm
        @  8, 6 SAY dendmm
        @ 12, 2 SAY "Please Wait for Selection Display takes time"
        IF PressedEsc()
            RETURN NIL
        ENDIF
        SELECT Hist
        SET ORDER TO 2      // Partnum
        GOTO TOP
        DO WHILE Hist->( !Eof() )
            SELECT Part
            SEEK Hist->partnum
            IF Part->Catno != ccatno
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF Hist->Qty = 0
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
        ENDDO                             // EOF Hist
        mwhere := "S"
        Printsel( mwhere )
        nl := 3
        npl := 22
        IF mwhere == "P"
            npl := 56
            @  0, 0
            SET DEVICE TO PRINT
        ELSE
            Scroll()
        ENDIF
        @  0, 0 SAY Control->U_Name
        @  0, 46 SAY Time()
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @ nl, 4  SAY ccatno
        @ nl, 20  SAY Cat->CatDesc
        nl += 2
        @  nl, 40 SAY dendmm - 3 PICTURE "9999"
        @  nl, 50 SAY dendmm - 2 PICTURE "9999"
        @  nl, 60 SAY dendmm - 1 PICTURE "9999"
        @  nl, 70 SAY dendmm   PICTURE "9999"
        SELECT Months
        GOTO 12
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 38 SAY n3month1 PICTURE "9,999"
        @  nl, 48 SAY n2month1 PICTURE "9,999"
        @  nl, 58 SAY n1month1 PICTURE "9,999"
        @  nl, 68 SAY nmonth1  PICTURE "9,999"
        GOTO 11
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 38 SAY n3month2  PICTURE "9,999"
        @  nl, 48 SAY n2month2 PICTURE "9,999"
        @  nl, 58 SAY n1month2 PICTURE "9,999"
        @  nl, 68 SAY nmonth2 PICTURE "9,999"
        GOTO 10
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 38 SAY n3month3  PICTURE "9,999"
        @  nl, 48 SAY n2month3 PICTURE "9,999"
        @  nl, 58 SAY n1month3 PICTURE "9,999"
        @  nl, 68 SAY nmonth3 PICTURE "9,999"
        GOTO  9
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 38 SAY n3month4  PICTURE "9,999"
        @  nl, 48 SAY n2month4 PICTURE "9,999"
        @  nl, 58 SAY n1month4 PICTURE "9,999"
        @  nl, 68 SAY nmonth4 PICTURE "9,999"
        GOTO  8
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 38 SAY n3month5  PICTURE "9,999"
        @  nl, 48 SAY n2month5 PICTURE "9,999"
        @  nl, 58 SAY n1month5 PICTURE "9,999"
        @  nl, 68 SAY nmonth5 PICTURE "9,999"
        GOTO  7
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 38 SAY n3month6  PICTURE "9,999"
        @  nl, 48 SAY n2month6 PICTURE "9,999"
        @  nl, 58 SAY n1month6 PICTURE "9,999"
        @  nl, 68 SAY nmonth6 PICTURE "9,999"
        GOTO  6
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 38 SAY n3month7  PICTURE "9,999"
        @  nl, 48 SAY n2month7 PICTURE "9,999"
        @  nl, 58 SAY n1month7 PICTURE "9,999"
        @  nl, 68 SAY nmonth7 PICTURE "9,999"
        GOTO  5
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 38 SAY n3month8 PICTURE "9,999"
        @  nl, 48 SAY n2month8 PICTURE "9,999"
        @  nl, 58 SAY n1month8 PICTURE "9,999"
        @  nl, 68 SAY nmonth8  PICTURE "9,999"
        GOTO  4
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 38 SAY n3month9 PICTURE "9,999"
        @  nl, 48 SAY n2month9 PICTURE "9,999"
        @  nl, 58 SAY n1month9 PICTURE "9,999"
        @  nl, 68 SAY nmonth9  PICTURE "9,999"
        GOTO  3
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 38 SAY n3month10 PICTURE "9,999"
        @  nl, 48 SAY n2month10 PICTURE "9,999"
        @  nl, 58 SAY n1month10 PICTURE "9,999"
        @  nl, 68 SAY nmonth10 PICTURE "9,999"
        GOTO  2
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 38 SAY n3month11 PICTURE "9,999"
        @  nl, 48 SAY n2month11 PICTURE "9,999"
        @  nl, 58 SAY n1month11 PICTURE "9,999"
        @  nl, 68 SAY nmonth11 PICTURE "9,999"
        GOTO  1
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 38 SAY n3month12 PICTURE "9,999"
        @  nl, 48 SAY n2month12 PICTURE "9,999"
        @  nl, 58 SAY n1month12 PICTURE "9,999"
        @  nl, 68 SAY nmonth12  PICTURE "9,999"
        nl += 2

        @  nl, 5 SAY dendmm - 3 PICTURE "9999"
        @  nl, 20 SAY dendmm - 2 PICTURE "9999"
        @  nl, 35 SAY dendmm - 1 PICTURE "9999"
        @  nl, 50 SAY dendmm   PICTURE "9999"
        nl++
        @  nl, 5 SAY n3totqty PICTURE "999,999"
        @  nl, 20 SAY n2totqty PICTURE "999,999"
        @  nl, 35 SAY n1totqty PICTURE "999,999"
        @  nl, 50 SAY ntotqty  PICTURE "999,999"
        nl++
        @  nl, 5 SAY n3total  PICTURE "$999,999.99"
        @  nl, 20 SAY n2total  PICTURE "$999,999.99"
        @  nl, 35 SAY n1total  PICTURE "$999,999.99"
        @  nl, 50 SAY ntotal   PICTURE "$999,999.99"
        nl += 2
        @  nl, 5 SAY "Totals"
        @  nl, 10 SAY ( n3totqty + n2totqty + n1totqty + ntotqty ) PICTURE "9,999,999"
        @  nl, 25 SAY ( n3total + n2total + n1total + ntotal )     PICTURE "$9,999,999.99"
        nl++
        IF mwhere = "P"
            @ nl, 0 SAY " "
            EndPrint()
        ELSE
            WAIT
        ENDIF
        mcontinue := "N"
    ENDDO                   // mcontinue

    RETURN NIL

// ***---- End of YearCat

// **-----------------------------------------------------------------

FUNCTION YearPart()

    mwhere := "S"

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"

        Scroll()
        cblank := "XXXX"
        @ 12, 10 SAY "Blank for ALL Parts" GET cblank PICTURE "!!!!"
        READ
        IF cblank != "    "
            ccatno := Space( 12 )
            Catarray( ccatno )
            ccatno := Cat->Catno
        ENDIF
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 10 SAY "Display is 4 Years To Date " + ccatno
        dendmm   := Year( Date() )
        @  6, 10 SAY "Enter 2013 for 2013-2010, 2009 for 2009-2008 Records" COLOR "RG+"
        @  8, 10 SAY Message->Todate GET dendmm PICTURE "9999"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        dstmm    := dendmm - 3
        mpartnum := Space( 20 )
        aPart_ := {}
        nrecno := 0
        SELECT Hist
        SET ORDER TO 2        // Partnum
        @  4, 1 SAY "Records In File"
        @  5, 1 SAY LastRec()
        @  7, 1 SAY dstmm
        @  8, 6 SAY dendmm
        @ 12, 2 SAY "Please Wait for Selection Display takes time"
        // **    @ 14, 2 SAY "Some History Catalogues have NO Parts Hangs up"
        ncount  := 1
        ncount1 := 1
        GOTO TOP
        IF LastRec() != 0
            DO WHILE Hist->( !Eof() )
                IF Hist->Qty = 0
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
                ncount++
                // **            @ 1,55 SAY ncount PICTURE "99,999"
                // **            INKEY()
                IF ncount <= 0
                    @ 10, 30 SAY "No Parts in Catalogue"
                    WAIT
                    RETURN NIL
                ENDIF
                IF Hist->Partnum = mpartnum
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                IF cblank != "   "
                    SELECT Part
                    SEEK Hist->Partnum
                    SELECT Hist
                    IF Part->Catno != ccatno
                        SKIP ALIAS Hist
                        LOOP
                    ENDIF
                ENDIF
                @ 1, 65 SAY ncount1 PICTURE "99,999"
                IF Hist->Partnum != mpartnum
                    AAdd( aPart_, Hist->Partnum + "        " + Str( RecNo(),6  ) )
                    mpartnum := Hist->Partnum
                ENDIF
                ncount1++
                IF ncount1 < 2
                    @ 18, 30 SAY "No Part History this Catalogue" COLOR "RG+"
                    WAIT
                    RETURN NIL
                ENDIF
                SELECT Hist
                SKIP ALIAS Hist
            ENDDO
            ASort( aPart_,,, {| x, y | x < y } )
        ENDIF     // LastRec()
        Scroll( 2, 0, 24, 78 )
        DispBox( 2, 1, 24, 20, 2 )
        IF !Empty( apart_ )
            anum := AChoice( 3, 2, 23, 18, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
        ENDIF
        IF PressedEsc()
            RETURN NIL
        ENDIF
        @ 24, 2 SAY " "
        WAIT
        SELECT Hist
        GOTO nrecno
        mpartnum := Hist->Partnum
        SELECT Part
        SET ORDER TO 1
        SEEK mpartnum
        // **      SEEK Hist->Partnum
        nl := 0
        mcodeno := Space( 8 )
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
        // *** ENDIF     // LastRec()
        SELECT Hist
        SET ORDER TO 2
        GOTO TOP
        IF LastRec() != 0
            SEEK mpartnum
            IF Found()
                DO WHILE Hist->Partnum == mpartnum .AND. Hist->( !Eof() )
                    IF Hist->Qty = 0
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
/*
               IF Hist->Codeno != mcodeno
                  @ nl,23 SAY Hist->Codeno
                  nl++
                  mcodeno := Hist->Codeno
               ENDIF
*/
                    SELECT Hist
                    SKIP ALIAS Hist
                ENDDO                             // EOF

                mwhere := "S"
                Printsel( mwhere )
                nl := 3
                npl := 22
                IF mwhere == "P"
                    npl := 56
                    @  0, 0
                    SET DEVICE TO PRINT
                ELSE
                    Scroll()
                ENDIF
                @  0, 0 SAY Control->U_Name
                @  0, 46 SAY Time()
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                @ nl, 5  SAY mpartnum
                @ nl, 26      SAY SubStr( Part->Desc, 1, 32 )
                nl += 2
                @  nl, 40 SAY dendmm - 3 PICTURE "9999"
                @  nl, 50 SAY dendmm - 2 PICTURE "9999"
                @  nl, 60 SAY dendmm - 1 PICTURE "9999"
                @  nl, 70 SAY dendmm   PICTURE "9999"
                SELECT Months
                GOTO 12
                nl++
                @  nl, 2 SAY Months->Brief
                @  nl, 38 SAY n3month1 PICTURE "9,999"
                @  nl, 48 SAY n2month1 PICTURE "9,999"
                @  nl, 58 SAY n1month1 PICTURE "9,999"
                @  nl, 68 SAY nmonth1  PICTURE "9,999"
                GOTO 11
                nl++
                @  nl, 2 SAY Months->Brief
                @  nl, 38 SAY n3month2 PICTURE "9,999"
                @  nl, 48 SAY n2month2 PICTURE "9,999"
                @  nl, 58 SAY n1month2 PICTURE "9,999"
                @  nl, 68 SAY nmonth2  PICTURE "9,999"
                GOTO 10
                nl++
                @  nl, 2 SAY Months->Brief
                @  nl, 38 SAY n3month3 PICTURE "9,999"
                @  nl, 48 SAY n2month3 PICTURE "9,999"
                @  nl, 58 SAY n1month3 PICTURE "9,999"
                @  nl, 68 SAY nmonth3  PICTURE "9,999"
                GOTO  9
                nl++
                @  nl, 2 SAY Months->Brief
                @  nl, 38 SAY n3month4 PICTURE "9,999"
                @  nl, 48 SAY n2month4 PICTURE "9,999"
                @  nl, 58 SAY n1month4 PICTURE "9,999"
                @  nl, 68 SAY nmonth4  PICTURE "9,999"
                GOTO  8
                nl++
                @  nl, 2 SAY Months->Brief
                @  nl, 38 SAY n3month5 PICTURE "9,999"
                @  nl, 48 SAY n2month5 PICTURE "9,999"
                @  nl, 58 SAY n1month5 PICTURE "9,999"
                @  nl, 68 SAY nmonth5  PICTURE "9,999"
                GOTO  7
                nl++
                @  nl, 2 SAY Months->Brief
                @  nl, 38 SAY n3month6 PICTURE "9,999"
                @  nl, 48 SAY n2month6 PICTURE "9,999"
                @  nl, 58 SAY n1month6 PICTURE "9,999"
                @  nl, 68 SAY nmonth6  PICTURE "9,999"
                GOTO  6
                nl++
                @  nl, 2 SAY Months->Brief
                @  nl, 38 SAY n3month7 PICTURE "9,999"
                @  nl, 48 SAY n2month7 PICTURE "9,999"
                @  nl, 58 SAY n1month7 PICTURE "9,999"
                @  nl, 68 SAY nmonth7  PICTURE "9,999"
                GOTO  5
                nl++
                @  nl, 2 SAY Months->Brief
                @  nl, 38 SAY n3month8 PICTURE "9,999"
                @  nl, 48 SAY n2month8 PICTURE "9,999"
                @  nl, 58 SAY n1month8 PICTURE "9,999"
                @  nl, 68 SAY nmonth8  PICTURE "9,999"
                GOTO  4
                nl++
                @  nl, 2 SAY Months->Brief
                @  nl, 38 SAY n3month9 PICTURE "9,999"
                @  nl, 48 SAY n2month9 PICTURE "9,999"
                @  nl, 58 SAY n1month9 PICTURE "9,999"
                @  nl, 68 SAY nmonth9  PICTURE "9,999"
                GOTO  3
                nl++
                @  nl, 2 SAY Months->Brief
                @  nl, 38 SAY n3month10 PICTURE "9,999"
                @  nl, 48 SAY n2month10 PICTURE "9,999"
                @  nl, 58 SAY n1month10 PICTURE "9,999"
                @  nl, 68 SAY nmonth10  PICTURE "9,999"
                GOTO  2
                nl++
                @  nl, 2 SAY Months->Brief
                @  nl, 38 SAY n3month11 PICTURE "9,999"
                @  nl, 48 SAY n2month11 PICTURE "9,999"
                @  nl, 58 SAY n1month11 PICTURE "9,999"
                @  nl, 68 SAY nmonth11  PICTURE "9,999"
                GOTO  1
                nl++
                @  nl, 2 SAY Months->Brief
                @  nl, 38 SAY n3month12 PICTURE "9,999"
                @  nl, 48 SAY n2month12 PICTURE "9,999"
                @  nl, 58 SAY n1month12 PICTURE "9,999"
                @  nl, 68 SAY nmonth12  PICTURE "9,999"
                nl += 2
                @  nl, 5 SAY dendmm - 3 PICTURE "9999"
                @  nl, 20 SAY dendmm - 2 PICTURE "9999"
                @  nl, 35 SAY dendmm - 1 PICTURE "9999"
                @  nl, 50 SAY dendmm   PICTURE "9999"
                nl++
                @  nl, 5 SAY n3totqty PICTURE "999,999"
                @  nl, 20 SAY n2totqty PICTURE "999,999"
                @  nl, 35 SAY n1totqty PICTURE "999,999"
                @  nl, 50 SAY ntotqty  PICTURE "999,999"
                nl++
                @  nl, 5 SAY n3total  PICTURE "$999,999.99"
                @  nl, 20 SAY n2total  PICTURE "$999,999.99"
                @  nl, 35 SAY n1total  PICTURE "$999,999.99"
                @  nl, 50 SAY ntotal   PICTURE "$999,999.99"
                nl += 2
                @  nl, 5 SAY "Totals"
                @  nl, 10 SAY ( n3totqty + n2totqty + n1totqty + ntotqty ) PICTURE "9,999,999"
                @  nl, 25 SAY ( n3total + n2total + n1total + ntotal )     PICTURE "$9,999,999.99"
                nl++
            ENDIF
        ENDIF                    // LastRec Not 0
        mcontinue := "N"
    ENDDO
    IF mwhere = "P"
        @ nl, 0 SAY " "
        EndPrint()
    ELSE
        WAIT
    ENDIF

    RETURN NIL

// ***---- End of YearPart

// **-----------------------------------------------------------------

FUNCTION EquAnal()

    Scroll()
    DispBox( 0, 1, 24, 79, 2 )
    mpartnum := Space( 20 )
    @ 10, 10 SAY "Select Module for Analysis"
    PartFind( mpartnum )
    mpartnum := Part->Partnum

    mwhere := "S"
    Printsel( mwhere )
    nl := 5
    npl := 22
    IF mwhere == "P"
        npl := 56
        @  0, 0
        SET DEVICE TO PRINT
    ELSE
        Scroll()
    ENDIF

    @  0, 0 SAY Control->U_Name
    @  0, 46 SAY Time()
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  3, 2 SAY "Description           Partnum"
    @  3, 60 SAY "Instock"

    mlevel := 4
    nl := 5

    @ nl, 0 SAY Part->Desc;
        + " " + Str( Part->Instock, 9 );
        + " " + Part->ABC;
        + " " + SubStr( Part->Unit, 1, 6 );
        + " " + SubStr( Part->Partnum, 1, 16 )
    nl++
    IF Part->Detail != "      "
        @  nl, 20 SAY Part->Detail
        nl++
    ENDIF
    nl++

    SELECT Equ
    SEEK Trim( Part->Partnum )

    SET EXACT ON
    AnalFindNext( Equ->PartQty, 1 )
    SET EXACT OFF
    nl++

    IF mwhere = "P"
        @ nl, 0 SAY "Qty      MATERIALS                         Price       Date     Hours"
        nl++
        npl := nl
        nline = 1
        FOR nline = 1 TO ( 60 -npl )           // Was 63
            @ nl, 0 SAY "______:___________________________________:__________:_________:___________"
            nl += 2
            IF nl > 60
                EXIT
            ENDIF
            npl++
        NEXT
        @ nl, 0 SAY " "
        EndPrint()
    ELSE
        IF nl > 5
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN NIL


// ***------- End EquAnal

FUNCTION CheckPage()

    IF mwhere = "P" .AND. nl > npl
        EJECT
        nl := 0
    ENDIF
    IF mwhere = "S" .AND. nl > 22
        Inkey( 0 )
        Scroll()
        nl := 0
    ENDIF

    RETURN NIL

STATIC FUNCTION AnalFindNext( nequqty, level )

    LOCAL mmod := 0
    LOCAL nrecno := 0

    IF mlevel >= level
        mmod := Trim( Part->Partnum )
        SELECT Equ
        nrecno := RecNo()
        GOTO TOP
        SEEK mmod
        IF Found()
            AnalShowMod( mmod, nequqty, level )
        ENDIF
    ENDIF // mequ Only first
    SELECT Equ
    GOTO nrecno

    RETURN NIL

STATIC FUNCTION AnalShowMod( mmod, nequqty, level )

    DO WHILE Equ->Modcode = mmod .AND. Equ->( !Eof() )
        CheckPage()
        SELECT Part
        SEEK Equ->Partnum
        AnalShowDetails( level, Equ->PartQty * nequqty )
        AnalFindNext( Equ->PartQty * nequqty, level + 1 )
        SKIP ALIAS Equ
    ENDDO
    AnalAfterShow( level )

    RETURN NIL

STATIC FUNCTION AnalShowDetails( level, nequqty )

    IF level == 1
        AnalShowPart( 1 )
    ELSE
        AnalShowQty( level, nequqty )
    ENDIF

    RETURN NIL

STATIC FUNCTION AnalShowPart( level )

    @ nl, 0 SAY Replicate( ".", level )
    @ nl, 3 SAY SubStr( Part->Desc, 1, 29 );
        + " " + Str( Part->Instock, 9 );
        + " " + Part->ABC;
        + " " + SubStr( Part->Unit, 1, 6 );
        + " " + SubStr( Part->Partnum, 1, 16 )
    nl++
    IF Part->Detail != "      "
        @  nl, 20 SAY Part->Detail
        nl++
    ENDIF

    RETURN NIL

STATIC FUNCTION AnalShowQty( level, qty )

    @ nl, 0 SAY Replicate( ".", level )
    @ nl, 6 SAY SubStr( Part->Partnum, 1, 16 );
        + " " + Str( qty, 8, 2 ) + " " + SubStr( Part->Unit, 1, 6 );
        + " " + SubStr( Part->Desc, 1, 29 );
        + " " + Str( Part->Instock, 6 ) + " " + Part->ABC
    nl++

    RETURN NIL

STATIC FUNCTION AnalAfterShow( level )

    IF level == 2
        nl++
    ENDIF

    RETURN NIL

// ***-----------------------------------------------------------------------

FUNCTION FindEqu()

    SET EXACT ON

    Scroll()
    mcodeno := Quot->Codeno
    aPart_ := {}
    anum   := {}
    nrecno := 0
    SELECT Quot
    GOTO TOP
    DO WHILE Quot->( !Eof() )
        IF Quot->Codeno = "A       "
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF Quot->Codeno != mcodeno
            SKIP ALIAS Quot
            LOOP
        ENDIF
        ddate := Str( Year( Quot->Duedate ) );
            + Str( Month( Quot->DueDate ) );
            + Str( Day( Quot->DueDate ) );
            + " " + Quot->Faxno
        AAdd( aPart_, Quot->Codeno;
            + " " + Quot->BranchId;
            + " " + Str( Quot->OrgQty, 6, 0 );
            + " " + Str( Quot->Qty, 6, 0 );
            + " " + Str( Quot->Goodsent, 6, 0 );
            + " " + SubStr( Quot->Partnum, 1, 8 );
            + " " + SubStr( Quot->Ordnum, 1, 16 );
            + " " + ddate;
            + "               " + Str( RecNo(), 6 ) )
        SKIP ALIAS Quot
    ENDDO
    DispBox( 0, 1, 24, 79, 2 )
    @  1, 3 SAY " Name List " COLOR "RG+"
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 3, 2, 23, 78, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        GOTO nrecno
        IF LastKey() = 27
            RETURN
        ENDIF
    ENDIF     // Empty
    SELECT NAME
    SEEK Quot->Codeno

    mwhere := "S"
    Printsel( mwhere )
    nl := 5
    npl := 22
    IF mwhere == "P"
        npl := 56
        @  0, 0
        SET DEVICE TO PRINT
    ELSE
        Scroll()
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0, 46 SAY Time()
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 20SAY Name->Name
    @  3, 2 SAY "Partnum   Description  Suppl"
    @  3, 70 SAY "Instock"
    nl := 5
    mpartnum := Quot->Partnum
    mstock := "Y"
    mlevel := 4
    SELECT Quot
    DO WHILE Quot->( !Eof() )
        IF Quot->Partnum != mpartnum
            SKIP ALIAS Quot
            LOOP
        ENDIF

        SELECT Equ
        SEEK Quot->Partnum
        mpartnum := Equ->Partnum

        SELECT Part
        SEEK Quot->Partnum
        @ nl, 0 SAY SubStr( Quot->Partnum, 1, 16 );
            + " " + Str( Quot->Qty, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
            + " " + Part->Desc + " " + Part->ABC
        nl += 2

        EquFindNext( Quot->Qty, 1 )
        nl++

        SELECT Quot
        SKIP ALIAS Quot
    ENDDO                            // EOF() Quot

    IF mwhere = "P"
        IF Message->Mess13 != Space( 40 )
            @ nl, 26 SAY Message->Mess13
            nl++
        ENDIF
        @ nl, 0 SAY "Qty      MATERIALS                         Price       Date     Hours"
        nl++
        npl := nl
        nline = 1
        FOR nline = 1 TO ( 60 -npl )           // Was 63
            @ nl, 0 SAY "______:___________________________________:__________:_________:___________"
            nl += 2
            IF nl > 60
                EXIT
            ENDIF
            npl++
        NEXT

        @ nl, 0 SAY " "
        EndPrint()
    ELSE
        IF nl > 5
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    SET EXACT OFF

    RETURN NIL

// ***------- End FindEqu

STATIC FUNCTION EquFindNext( nequ, level )

    LOCAL nrecno := 0

    IF mlevel >= level
        SELECT Equ
        mmod := EquGetPartnum( level )
        nrecno := RecNo()
        GOTO TOP
        SEEK mmod
        IF Found()
            EquShowMod( mmod, nequ, level )
        ENDIF
    ENDIF
    SELECT Equ
    GOTO nrecno

    RETURN NIL

STATIC FUNCTION EquGetPartnum( level )

    IF level == 1
        RETURN Trim( Quot->Partnum )
    ELSE
        RETURN Trim( Equ->Partnum )
    ENDIF

    RETURN NIL

STATIC FUNCTION EquShowMod( mmod, nequ, level )

    DO WHILE Equ->Modcode = mmod .AND. Equ->( !Eof() )
        CheckPage()
        SELECT Part
        SEEK Equ->Partnum
        EquShowPart( level, Equ->PartQty * nequ )
        EquFindNext( Equ->PartQty * nequ, level + 1 )
        SKIP ALIAS Equ
    ENDDO
    EquAfterShow( level )

    RETURN NIL

FUNCTION EquShowPart( level, nequ )

    @ nl, 0 SAY Replicate( ".", level )
    @ nl, 6 SAY SubStr( Equ->Partnum, 1, 16 );
        + " " + Str( nequ, 8, 2 ) + " " + SubStr( Part->Unit, 1, 6 );
        + " " + SubStr( Part->Desc, 1, 18 );
        + " " + Part->Codeno;
        + " " + Str( Part->Instock, 6 ) + " " + Part->ABC
    nl++

    RETURN NIL

STATIC FUNCTION EquAfterShow( level )

    IF level == 2
        nl++
    ENDIF

    RETURN NIL

// ***-----------------------------------------------------------------------

FUNCTION Partabc()

    manother := "Y"
    DO WHILE manother = "Y"

        Scroll()
        cboughtout := ApGetY( "Y = Bought Out Only N = Own Manufacture" )
        ntrade := 0
        cblank := "XXXX"
        @  3, 20 SAY "Parts Trade greater than" GET ntrade PICTURE "999999"
        @  5, 20 SAY "Blank for ALL" GET cblank PICTURE "!!!!"
        @  6, 20 SAY "Beware if big File Not Practical for View only"
        READ
        IF cblank != "    "
            SELECT Part
            cabc := "A"
            nselect := 1
            @  8, 30 PROMPT "1. A - High Priority  "
            @  9, 30 PROMPT "2. B - Med  Priority  "
            @ 10, 30 PROMPT "3. C - Low  Priority  "
            @ 11, 30 PROMPT "4. D -                "
            @ 12, 30 PROMPT "5. E - Own Manufacture"
            @ 13, 30 PROMPT "6. F - Materials Steel"
            @ 14, 30 PROMPT "7. M - Modules        "
            @ 15, 30 PROMPT "8. Z - Contractors    "
            @ 16, 30 PROMPT "9. ALL selected  Some DBF too Big for this BEWARE"
            MENU TO nselect
            DO CASE
            CASE nselect == 1
                cabc := "A"
            CASE nselect == 2
                cabc := "B"
            CASE nselect == 3
                cabc := "C"
            CASE nselect == 4
                cabc := "D"
            CASE nselect == 5
                cabc := "E"
            CASE nselect == 6
                cabc := "F"
            CASE nselect == 7
                cabc := "M"
            CASE nselect == 8
                cabc := "Z"
            CASE nselect == 9
                cabc := " "
            ENDCASE
        ENDIF           // Cblank
        mcontinue := "Y"
        DO WHILE mcontinue = "Y"
            nrecno  := 0
            Scroll()
            SELECT Part
            GOTO TOP
            aPart_ := {}
            anum   := {}
            DO WHILE Part->( !Eof() )
                IF cblank != "    "
                    IF cboughtout = "Y"
                        IF Part->Boughtout != "Y"
                            SKIP ALIAS Part
                            LOOP
                        ENDIF
                    ENDIF                // cboughtout
                    IF cboughtout = "N"
                        IF Part->Boughtout != "N"
                            SKIP ALIAS Part
                            LOOP
                        ENDIF
                    ENDIF                // cboughtout
                    IF Part->ABC != cabc
                        SKIP ALIAS Part
                        LOOP
                    ENDIF                // ABC
                ENDIF   // Blank

                IF Part->Trade <= ntrade
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                AAdd( aPart_, SubStr( Part->Partnum, 1, 12 );
                    + " " + SubStr( Part->Desc, 1, 28 );
                    + " " + Part->ABC;
                    + " " + Part->Boughtout;
                    + " " + Str( Part->MinStk, 9 );
                    + " " + Str( Part->Instock, 9 );
                    + " " + Str( Part->Utd, 9 );
                    + "       " + Str( RecNo(), 6 ) )
                SKIP ALIAS Part
            ENDDO                                 // Part EOF
            DispBox( 0, 1, 4, 79, 2 )
            @ 1, 3      SAY "Trade >" COLOR "BG+"
            @ 1, Col() + 1 SAY ntrade PICTURE "$99,999.99"  COLOR "RG+"
            IF cboughtout = "Y"
                @  1, 30 SAY "Bought Out Only" COLOR "BG+"
            ELSE
                @  1, 30 SAY "Own Manufacture Only" COLOR "BG+"
            ENDIF                // cboughtout
            @ 2, 3      SAY "A=High, B=Med, C=Contr, D=, E=, F=, M=Modules,Z=, ' '=All"
            @ 3, 3      SAY "B/M Y=Bought N=Own Manufacture"
            @ 3, Col() + 3 SAY "WAIT takes Time" COLOR "RG+"
            Scroll(  5, 0, 24, 80 )
            DispBox( 5, 1, 23, 79, 2 )
            @  6, 2 SAY "Partnum    Description"
            @  6, 43 SAY "ABC B/M"
            @  6, 52 SAY "MinStk"
            @  6, 61 SAY "Instock     Used"
            @ 24, 4 SAY"Esc to Exit" COLOR "RG+"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice( 7, 2, 22, 76, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
            ENDIF
            SELECT Part
            GOTO nrecno
            ApRLock( 3 )
            @ Row(), 44 GET Part->ABC PICTURE "!"
            @ Row(), 46 GET Part->Boughtout PICTURE "!"
            @ Row(), 51 GET Part->MinStk  PICTURE "999999"
            @ Row(), 61 GET Part->Instock PICTURE "999999"
            READ
            UNLOCK
            IF LastKey() = 27
                EXIT
            ENDIF
            LOOP
        ENDDO       // mcontinue

        manother := ApGetN( Trim( Message->Another ) + " Listing" )
    ENDDO                       // manother

    mwhere := "S"
    Printsel( mwhere )
    nl := 5
    npl := 22
    IF mwhere == "P"
        npl := 56
        @  0, 0
        SET DEVICE TO PRINT
    ELSE
        Scroll()
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0, 46 SAY Time()
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  3, 2 SAY "Partnum   Description   Supl"
    @  3, 45 SAY "ABC"
    @  3, 51 SAY "MinStk"
    @  3, 60 SAY "Instock    Used"
    nl := 5
    SELECT Part
    GOTO TOP
    DO WHILE Part->( !Eof() )
        IF cboughtout = "Y"
            IF Part->Boughtout != "Y"
                SKIP ALIAS Part
                LOOP
            ENDIF
        ENDIF                // cboughtout
        IF cboughtout = "N"
            IF Part->Boughtout != "N"
                SKIP ALIAS Part
                LOOP
            ENDIF
        ENDIF                // cboughtout
        IF Part->Trade <= ntrade
            SKIP ALIAS Part
            LOOP
        ENDIF

        // **          IF Part->ABC != cabc
        // **             SKIP ALIAS Part
        // **             LOOP
        // **          ENDIF                // ABC
        IF nl > npl
            nl := 5
            IF mwhere == "P"
                EJECT
                @  0, 0 SAY Control->U_Name
                @  0, 46 SAY Time()
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                @  3, 2 SAY "Partnum   Description   Supl"
                @  3, 41 SAY "ABC"
                @  3, 46 SAY "MinStk"
                @  3, 56 SAY "Instock    Used"
            ELSE
                WAIT
                Scroll()
                @  3, 2 SAY "Partnum   Description   Supl"
                @  3, 41 SAY "ABC"
                @  3, 46 SAY "MinStk"
                @  3, 56 SAY "Instock    Used"
            ENDIF
        ENDIF
        @ nl, 1 SAY SUBST( Part->Partnum, 1, 12 ) + " " + SubStr( Part->Desc, 1, 20 )
        @ nl, 35 SAY Part->Codeno
        @ nl, 45 SAY Part->ABC     PICTURE "!"
        @ nl, 46 SAY Part->MinStk  PICTURE "99,999.99"
        @ nl, 56 SAY Part->Instock PICTURE "99,999.99"
        @ nl, 66 SAY Part->Utd     PICTURE "999,999.99"
        nl++
        SKIP ALIAS Part
    ENDDO                                 // Part EOF

    IF mwhere = "P"
        @ nl, 0 SAY " "
        EndPrint()
    ELSE
        IF nl > 5
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF
    // **      manother := ApGetN( TRIM( Message->Another )+" Listing" )
    // **   ENDDO                       // manother

    RETURN NIL

// *** ----------  End of PartStock()

// ****---------------------- END OF XF_UTIL1.PRG
