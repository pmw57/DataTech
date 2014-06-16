// ** JoKir 09-12-11 15:35:45

/*  Program ........:                  XF_UTIL2.PRG
    Authors.........: John Kirby
    Date............: 07/10/2013
    Functions.......: YearSale, Ordarr, OrdByOld, StockCat, ModCat
    Static Functions:
*/

FUNCTION YearSale()

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

    mwhere := "S"
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        Scroll()
        @  1, 10 SAY "Display is 4 Years To Date Sales by Saleno"
        dendmm   := Year( Date() )
        @  6, 10 SAY "Enter 2013 for 2013-2010, 2009 for 2009-2008 Records" COLOR "RG+"
        @  8, 10 SAY Message->Todate GET dendmm PICTURE "9999"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        dstmm    := dendmm - 3
        @  4, 1 SAY "Records In File"
        @  5, 1 SAY LastRec()
        @  7, 1 SAY dstmm
        @  8, 6 SAY dendmm
        @ 12, 2 SAY "Please Wait for Selection Display takes time"
        /*
        ApFLock( 3 )
        INDEX ON Hist->Saleno TO TempI03
        SET INDEX TO TempI03
        UNLOCK
        csaleno := SPACE( 4 )
        IF Hist->Saleno = csaleno
        csaleno = Hist->Saleno
        SKIP ALIAS Hist
        LOOP
        ENDIF
        */
        SELECT Hist
        GOTO TOP
        DO WHILE Hist->( !Eof() )
            IF SubStr( Hist->Invno, 5, 2 ) = "  "
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
                    nmonth1 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 2
                    nmonth2 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 3
                    nmonth3 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 4
                    nmonth4 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 5
                    nmonth5 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 6
                    nmonth6 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 7
                    nmonth7 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 8
                    nmonth8 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 9
                    nmonth9 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 10
                    nmonth10 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 11
                    nmonth11 += Hist->Qty
                CASE Month( Hist->Pdate ) = 12
                    nmonth12 += Hist->Qty * Hist->Amount
                ENDCASE
                ntotal  += Hist->Amount * Hist->Qty
                ntotqty += Hist->Qty
            ENDIF                    // YEAR
            IF Year( Hist->Pdate ) = ( dendmm - 1 )
                DO CASE
                CASE Month( Hist->Pdate ) = 1
                    n1month1 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 2
                    n1month2 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 3
                    n1month3 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 4
                    n1month4 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 5
                    n1month5 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 6
                    n1month6 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 7
                    n1month7 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 8
                    n1month8 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 9
                    n1month9 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 10
                    n1month10 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 11
                    n1month11 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 12
                    n1month12 += Hist->Qty * Hist->Amount
                ENDCASE
                n1total  += Hist->Amount * Hist->Qty
                n1totqty += Hist->Qty
            ENDIF                    // YEAR
            IF Year( Hist->Pdate ) = ( dendmm - 2 )
                DO CASE
                CASE Month( Hist->Pdate ) = 1
                    n2month1 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 2
                    n2month2 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 3
                    n2month3 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 4
                    n2month4 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 5
                    n2month5 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 6
                    n2month6 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 7
                    n2month7 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 8
                    n2month8 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 9
                    n2month9 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 10
                    n2month10 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 11
                    n2month11 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 12
                    n2month12 += Hist->Qty * Hist->Amount
                ENDCASE
                n2total  += Hist->Amount * Hist->Qty
                n2totqty += Hist->Qty
            ENDIF                    // YEAR
            IF Year( Hist->Pdate ) = ( dendmm - 3 )
                DO CASE
                CASE Month( Hist->Pdate ) = 1
                    n3month1 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 2
                    n3month2 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 3
                    n3month3 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 4
                    n3month4 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 5
                    n3month5 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 6
                    n3month6 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 7
                    n3month7 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 8
                    n3month8 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 9
                    n3month9 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 10
                    n3month10 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 11
                    n3month11 += Hist->Qty * Hist->Amount
                CASE Month( Hist->Pdate ) = 12
                    n3month12 += Hist->Qty * Hist->Amount
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
        @ nl, 4  SAY "Sales"
        nl += 2
        @  nl, 15 SAY dendmm - 3 PICTURE "9999"
        @  nl, 30 SAY dendmm - 2 PICTURE "9999"
        @  nl, 50 SAY dendmm - 1 PICTURE "9999"
        @  nl, 65 SAY dendmm   PICTURE "9999"
        SELECT Months
        GOTO 12
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 15 SAY n3month1 PICTURE "$9,999,999"
        @  nl, 30 SAY n2month1 PICTURE "$9,999,999"
        @  nl, 50 SAY n1month1 PICTURE "$9,999,999"
        @  nl, 65 SAY nmonth1  PICTURE "$9,999,999"
        GOTO 11
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 15 SAY n3month2 PICTURE "$9,999,999"
        @  nl, 30 SAY n2month2 PICTURE "$9,999,999"
        @  nl, 50 SAY n1month2 PICTURE "$9,999,999"
        @  nl, 65 SAY nmonth2  PICTURE "$9,999,999"
        GOTO 10
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 15 SAY n3month3 PICTURE "$9,999,999"
        @  nl, 30 SAY n2month3 PICTURE "$9,999,999"
        @  nl, 50 SAY n1month3 PICTURE "$9,999,999"
        @  nl, 65 SAY nmonth3  PICTURE "$9,999,999"
        GOTO  9
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 15 SAY n3month4 PICTURE "$9,999,999"
        @  nl, 30 SAY n2month4 PICTURE "$9,999,999"
        @  nl, 50 SAY n1month4 PICTURE "$9,999,999"
        @  nl, 65 SAY nmonth4  PICTURE "$9,999,999"
        GOTO  8
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 15 SAY n3month5 PICTURE "$9,999,999"
        @  nl, 30 SAY n2month5 PICTURE "$9,999,999"
        @  nl, 50 SAY n1month5 PICTURE "$9,999,999"
        @  nl, 65 SAY nmonth5  PICTURE "$9,999,999"
        GOTO  7
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 15 SAY n3month6 PICTURE "$9,999,999"
        @  nl, 30 SAY n2month6 PICTURE "$9,999,999"
        @  nl, 50 SAY n1month6 PICTURE "$9,999,999"
        @  nl, 65 SAY nmonth6  PICTURE "$9,999,999"
        GOTO  6
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 15 SAY n3month7 PICTURE "$9,999,999"
        @  nl, 30 SAY n2month7 PICTURE "$9,999,999"
        @  nl, 50 SAY n1month7 PICTURE "$9,999,999"
        @  nl, 65 SAY nmonth7  PICTURE "$9,999,999"
        GOTO  5
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 15 SAY n3month8 PICTURE "$9,999,999"
        @  nl, 30 SAY n2month8 PICTURE "$9,999,999"
        @  nl, 50 SAY n1month8 PICTURE "$9,999,999"
        @  nl, 65 SAY nmonth8  PICTURE "$9,999,999"
        GOTO  4
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 15 SAY n3month9 PICTURE "$9,999,999"
        @  nl, 30 SAY n2month9 PICTURE "$9,999,999"
        @  nl, 50 SAY n1month9 PICTURE "$9,999,999"
        @  nl, 65 SAY nmonth9  PICTURE "$9,999,999"
        GOTO  3
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 15 SAY n3month10 PICTURE "$9,999,999"
        @  nl, 30 SAY n2month10 PICTURE "$9,999,999"
        @  nl, 50 SAY n1month10 PICTURE "$9,999,999"
        @  nl, 65 SAY nmonth10  PICTURE "$9,999,999"
        GOTO  2
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 15 SAY n3month11 PICTURE "$9,999,999"
        @  nl, 30 SAY n2month11 PICTURE "$9,999,999"
        @  nl, 50 SAY n1month11 PICTURE "$9,999,999"
        @  nl, 65 SAY nmonth11  PICTURE "$9,999,999"
        GOTO  1
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl, 15 SAY n3month12 PICTURE "$9,999,999"
        @  nl, 30 SAY n2month12 PICTURE "$9,999,999"
        @  nl, 50 SAY n1month12 PICTURE "$9,999,999"
        @  nl, 65 SAY nmonth12  PICTURE "$9,999,999"
        nl += 2

        @  nl, 5 SAY dendmm - 3 PICTURE "9999"
        @  nl, 30 SAY dendmm - 2 PICTURE "9999"
        @  nl, 50 SAY dendmm - 1 PICTURE "9999"
        @  nl, 65 SAY dendmm   PICTURE "9999"
        nl++
        @  nl, 5 SAY n3totqty PICTURE "99,999,999"
        @  nl, 30 SAY n2totqty PICTURE "99,999,999"
        @  nl, 50 SAY n1totqty PICTURE "99,999,999"
        @  nl, 65 SAY ntotqty  PICTURE "99,999,999"
        nl++
        @  nl, 5 SAY n3total  PICTURE "$9,999,999"
        @  nl, 30 SAY n2total  PICTURE "$9,999,999"
        @  nl, 50 SAY n1total  PICTURE "$9,999,999"
        @  nl, 65 SAY ntotal   PICTURE "$9,999,999"
        nl += 2
        @  nl, 5 SAY "Totals"
        @  nl, 10 SAY ( n3totqty + n2totqty + n1totqty + ntotqty ) PICTURE "9,999,999"
        @  nl, 25 SAY ( n3total + n2total + n1total + ntotal )     PICTURE "$99,999,999"
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

FUNCTION Ordarr()

    Scroll()

    aPart_   := {}
    // ** mcodeno  := SPACE( 8 )
    mpartnum := Space( 20 )
    SELECT Orders
    SET ORDER TO 2                                  // Ordnum Index
    GOTO TOP
    mordnum := Space( 4 )
    DO WHILE Orders->( !Eof() )
        IF Orders->Ordnum == mordnum
            SKIP ALIAS Orders
            LOOP
        ENDIF
        mordnum := Orders->Ordnum
        IF Orders->Codeno == "A       "          // not required now
            SKIP ALIAS Orders
            LOOP
        ENDIF
        SELECT Name
        SEEK Orders->Codeno
        SELECT Orders
        AAdd( aPart_, Orders->Ordnum + "  " + Name->Name + "  " + DToC( Orders->Date ) )
        DO WHILE Orders->Ordnum == mordnum .AND. Orders->( !Eof() )
            SKIP ALIAS Orders
        ENDDO
    ENDDO
    DispBox( 0, 1,  2, 79, 2 )
    @  1, 6 SAY Name->Name
    @  1, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    DispBox( 3, 1, 24, 79, 2 )
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 4, 7, 23, 73, aPart_,, "AFUNC" )
        IF LastKey() == 27
            RETURN Space( 16 )
        ENDIF
        mpartdes := aPart_[ anum ]
        mordnum  := SubStr( mpartdes, 1, 4 )
    ENDIF
    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        nrecno := 0
        aPart_ := {}
        SELECT Orders
        SEEK mordnum
        DO WHILE Orders->Ordnum == mordnum .AND. Orders->( !Eof() )
            mpartnum := Orders->Partnum
            SELECT Part
            SEEK mpartnum
            SELECT Orders
            IF Orders->Partin = Orders->PartQty
                SKIP ALIAS Orders
                LOOP
            ENDIF
            AAdd( aPart_, SubStr( Partnum, 1,14 );
                + " " + SubStr( Orders->Detail1, 1, 33 );
                + " " + Str( Orders->QtyRec, 7 );
                + " " + Str( Orders->PartQty, 7 );
                + " " + DToC( Orders->ReqDate );
                + "          " + Str( RecNo(), 6 ) )
            SKIP ALIAS Orders
        ENDDO
        Scroll()
        DispBox( 0, 1,  2, 79, 2 )
        @  1, 6 SAY Name->Name + " O/N # " + mordnum
        @  1, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        Scroll(  2, 0, 24, 80 )
        DispBox( 2, 1, 24, 79, 2 )
        @ 3, 52 SAY "Received   Outs"
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
            IF LastKey() == 27
                RETURN
            ENDIF
            mpartdes := aPart_[ anum ]
            nrecno   := Val( Right( mpartdes,6 ) )
            GOTO nrecno
            mpartnum := Orders->Partnum
        ENDIF
        IF nrecno == 0
            RETURN
        ENDIF                // nrecno
        SELECT Part
        SEEK mpartnum
        Scroll(  3, 0, 24, 80 )
        DispBox( 3, 1, 23, 79, 2 )
        mreceived := 0
        mcorrect  := "N"
        DO WHILE mcorrect = "N"
            SELECT Part
            mdesc      := Part->Desc
            ntrade     := Part->Trade
            nwholesale := Part->Wholesale
            @  4, 15 SAY Part->Partnum COLOR "GB+"
            @  4, 55 SAY "Instock"
            @  4, Col() + 1 SAY Part->Instock PICTURE "99,999.99" COLOR "GR+"
            @  6, 10 SAY "Description" GET mdesc      PICTURE "@X"
            READ
            ApRLock( 3 )
            Part->Desc := mdesc
            UNLOCK
            IF LastKey() == 27
                RETURN
            ENDIF
            SELECT Supl
            LOCATE FOR Supl->Partnum == mpartnum .AND. Supl->Codeno == Name->Codeno
            IF !Found()
                ApFLock( 3 )
                APPEND BLANK
                Supl->Partnum := Part->Partnum
                Supl->SuppId  := Part->Partnum
                // **        Supl->Cost    := Part->Trade
                Supl->Codeno  := Name->Codeno
                Supl->Date    := Date()
                UNLOCK
            ENDIF
            msuppid   := Supl->SuppId
            ncost     := Supl->Cost
            nlastcost := Supl->LastCost
            @  8, 10      SAY "Outstanding"
            IF Orders->Length > 0
                @  8, Col() + 1 SAY "Length"
                @  8, Col() + 1 SAY Orders->Length PICTURE "999"
            ENDIF
            @  8, Col() + 1 SAY "Qty"
            @  8, Col() + 1 SAY Orders->Partqty          PICTURE "99999.99"
            @  8, Col() + 2 SAY "Received Qty" GET mreceived PICTURE "99999.99"
            @ 10, 10      SAY "Cost Price"   GET ncost  PICTURE "99999.99"
            // **      @ 10,COL()+2 SAY   "Sell :"    GET nwholesale PICTURE "99999.99"
            READ
            @ 12, 10      SAY "Suppliers Partnum" GET msuppid PICTURE "@K!"
            // **         @  9,10 SAY "Economic Order Qty :" GET Supl->Qty    PICTURE "99999.99"
            @ 14, 10      SAY "Suppliers Cost"  GET ncost   PICTURE "99999.99"
            @ 16, 14      SAY "Last Price"
            @ 16, Col() + 2 SAY nlastcost PICTURE "$99,999.99"
            @ 18, 10      SAY "CP Price "
            @ 18, Col() + 2 SAY Part->Trade PICTURE "$999,999.99"
            @ 18, Col() + 2 SAY "Change Price" GET ntrade PICTURE "999999.99"
            READ
            // **         @ 15,17 SAY "Information :" GET Supl->Info   PICTURE "@KX"
            // **         @ 17,24 SAY "Date :"        GET Supl->Date   PICTURE "99/99/99"
            // **          READ
            ApRLock( 3 )
            Supl->SuppId   := msuppid
            Supl->Cost     := ncost
            Supl->LastCost := ncost  // new Cost
            UNLOCK
            mcorrect := ApGetY( "Is the above correct" )
            IF LastKey() == 27
                RETURN NIL
            ENDIF
        ENDDO

        SELECT Orders
        ApRLock( 3 )
        Orders->Qtyrec  += mreceived
        Orders->Partqty -= mreceived
        IF Orders->Partqty <= 0
            DELETE
        ENDIF
        UNLOCK
        IF Part->Length > 0
            mreceived := mreceived * Orders->Length
        ENDIF
        SELECT Part
        ApRLock( 3 )
        Part->Trade   := ntrade
        Part->Instock += mreceived
        UNLOCK
        @ 18, 60      SAY "Instock"
        @ 18, Col() + 1 SAY Part->Instock PICTURE "99,999.99" COLOR "GR+"
        IF LastKey() == 27
            RETURN NIL
        ENDIF

        mcontinue := ApGetN( "Another Part Arrived" )
    ENDDO                                            // mcontinue

    RETURN NIL

// **--------End Ordarr()

// **----------------------------------------------------------------

FUNCTION OrdbyOld()

    cjsno := "      "
    mptot := msum := nQty := 0
    mpartnum   := Space( 20 )
    mcodeno    := Space( 8 )
    mgrecsheet := "N"
    mcontinue  := "Y"
    DO WHILE mcontinue == "Y"

        SELECT Orders
        SET ORDER TO 3                           // Codeno
        SEEK "A       "
        IF !Found()
            ApFLock( 3 )
            APPEND BLANK
            Orders->Codeno := "A       "
            UNLOCK
        ENDIF
        Scroll()
        @ 23, 50 SAY "F2 To View ALL Orders" COLOR "BG+"
        mcodeno := Space( 8 )
        nrecno   := 0
        anum     := {}
        aPart_   := {}
        nll      := 19
        SELECT Orders
        SET ORDER TO 3                           // Codeno+Ordnum
        GOTO TOP
        IF LastRec() != 0
            DO WHILE Orders->( !Eof() )
                IF SubStr( Orders->Codeno, 1, 2 ) != "A "
                    IF Orders->PartIn >= Orders->PartQty
                        SKIP ALIAS Orders
                        LOOP
                    ENDIF
                    IF Orders->QtyRec >= Orders->PartQty
                        SKIP ALIAS Orders
                        LOOP
                    ENDIF
                ENDIF
                IF Orders->Codeno = mcodeno
                    SKIP ALIAS Orders
                    LOOP
                ENDIF
                SELECT Name
                SEEK Orders->Codeno
                IF !Found()
                    @  18, 60      SAY "No Name in File" COLOR "BG+"
                    @ nll, 60      SAY Orders->Codeno    COLOR "BG+"
                    @ nll, Col() + 1 SAY Orders->Ordnum    COLOR "BG+"
                    nll++
                    mcodeno := Orders->Codeno
                    SKIP ALIAS Orders
                    LOOP
                ENDIF
                SELECT Orders
                mcodeno := Name->Codeno
                AAdd( aPart_, Name->Name;
                    + "       " + Str( RecNo(), 6 ) )
                SKIP ALIAS Orders
            ENDDO                          // EOF()
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                Scroll(   0, 0, 24, 40 )
                DispBox(  0, 1, 24, 40, 2 )
                anum   := AChoice( 1, 3, 23, 39, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                mcodeno := Orders->Codeno
                SELECT Name
                SEEK mcodeno
                IF LastKey() == -1
                    SELECT Orders
                    SET ORDER TO 3                   // Codeno+Ordnum
                    nrecno := 0
                    aPart_ := {}
                    anum   := {}
                    DO WHILE Orders->( !Eof() )
                        SELECT Part
                        SET ORDER TO 1
                        SEEK Orders->Partnum
                        cdesc := SubStr( Orders->Detail1, 1, 26 )
                        SELECT Orders
                        IF cdesc = Space( 30 )
                            cdesc := SubStr( Part->Desc, 1, 26 )
                        ENDIF
                        IF cdesc = Space( 30 )
                            cdesc := SubStr( Orders->Detail2, 1, 26 )
                        ENDIF
                        IF Orders->Partin = Orders->PartQty
                            SKIP ALIAS Orders
                            LOOP
                        ENDIF
                        AAdd( aPart_, Orders->Ordnum;
                            + " " + Orders->Codeno;
                            + " " + DToC( Orders->Date );
                            + " " + cdesc;
                            + " " + Str( Orders->PartQty, 8, 2 );
                            + " " + Str( Orders->PartIn, 6 );
                            + "         " + Str( RecNo(), 6 ) )
                        SKIP ALIAS Orders
                    ENDDO                  // Orders
                    IF !Empty( aPart_ )
                        Scroll()
                        DispBox(  0, 1, 24, 79, 2 )
                        @ 0, 55 SAY "  Order     IN  "
                        ASort( aPart_,,, {| x, y | x < y } )
                        anum := AChoice(  1, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
                        nrecno := Val( Right( aPart_[ anum ], 6 ) )
                        GOTO nrecno
                        IF LastKey() = 27
                            RETURN NIL
                        ENDIF
                        mcodeno := Orders->Codeno
                        SELECT Name
                        SEEK mcodeno
                    ENDIF                        // Empty
                ENDIF
                IF LastKey() == 27
                    RETURN NIL
                ENDIF
            ENDIF
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @  1, 10 SAY Name->Name
            mcodeno := Name->Codeno
        ENDIF                        // LastRec
        IF mcodeno = "A       "
            SELECT Name
            mcodeno := Space( 8 )
            Namerank()                                     // ZFS_Name
            IF LastKey() == 27
                RETURN
            ENDIF
            SELECT Name
            mcodeno := Name->Codeno
        ENDIF
        IF mcodeno = Space( 8 )
            SELECT Name
            mcodeno := Space( 8 )
            Namerank()                                     // ZFS_Name
            IF LastKey() == 27
                RETURN
            ENDIF
            SELECT Name
            mcodeno := Name->Codeno
        ENDIF
        mordnum := Space( 4 )

        OrdLook( mcodeno )                      // XL_Orders

        Scroll(  21, 0, 24, 80 )
        DispBox( 21, 1, 24, 79, 2 )
        @ 22, 10      SAY "Order #" GET mordnum PICTURE "@KX"
        @ 22, Col() + 2 SAY "Blank for New Order   Esc To Quit"
        @ 22, Col() + 2 SAY Control->LastOrd
        READ
        IF LastKey() == 27
            LOOP
        ENDIF

        IF mordnum = Space( 4 )
            SELECT Control
            ApRLock( 3 )
            Control->LastOrd := Control->LastOrd + 1
            COMMIT
            UNLOCK
            mordnum := LTrim( Str( Control->LastOrd ) )
        ENDIF
        SELECT Orders
        mqty := 0
        mqdate   := SubStr( DToC( Date() ), 1, 2 )
        mtotal := mgtotal := mggtotal := mqtytotal := 0
        manother := "Y"
        DO WHILE manother = "Y"
            OrdScrn( mordnum )
            Scroll(  20, 0, 24, 80 )
            DispBox( 20, 1, 24, 79, 2 )
            nselect := 1
            @ 20, 58 SAY " - Orders Menu - " COLOR "G+"
            @ 21, 4      PROMPT "Add Part"
            @ 21, Col() + 2 PROMPT "No More Parts"
            @ 21, Col() + 2 PROMPT "Edit Above"
            @ 21, Col() + 2 PROMPT "Delete Order"
            @ 21, Col() + 4 SAY "ORDER # " + mordnum COLOR "BG+"
            MENU TO nselect
            DO CASE
            CASE LastKey() == 27
                mcontinue := "N"
                MenuB3()     // XLF_MenuB.prg
                RETURN NIL

            CASE nselect == 1                            // Add Part
                mcodeno := Name->Codeno
                mpartnum := Space( 16 )
                SELECT Part
                IF mPartnum = Space( 16 )
                    Partfind( @mpartnum )              // XF_Part
                    mpartnum := Part->Partnum
                ENDIF
                SELECT Name
                SEEK mcodeno          // quotcodeno
                mcodeno := Name->Codeno
                SELECT Part
                SET ORDER TO 1                      // Partnum
                SEEK mpartnum
                mpartnum := Part->Partnum
                IF !Found()
                    LOOP
                ENDIF
                Scroll( 12, 0, 24, 80 )
                coderef  := mpartnum
                MemoDisp( coderef )   // XF-Memo2
                Scroll( 12, 0, 24, 80 )
                SELECT Part
                SEEK mpartnum

                OrdAddP( mpartnum )                // CHRIORD2

                LOOP
            CASE nselect == 2
                nl++
                mamount := mgtotal
                mtrue   := "Y"
                IF mtrue == "Y"
                    mtrue := "N"
                    Scroll( 12, 0, 24, 80 )
                    DO WHILE mtrue == "N"
                        DispBox( 12, 5, 20, 75, 2 )
                        SELECT MESSAGE
                        morder1 := "Please Deliver To:-                                         "
                        morder2 := Message->Order2
                        morder3 := Message->Order3
                        morder4 := Message->Order4
                        morder5 := Message->Order5
                        morder6 := Message->Order6
                        @ 14, 10 GET morder1
                        @ 15, 10 GET morder2
                        @ 16, 10 GET morder3
                        @ 17, 10 GET morder4
                        @ 18, 10 GET morder5
                        @ 19, 10 GET morder6
                        READ
                        ApRLock( 3 )
                        Message->Order1 := morder1
                        Message->Order2 := morder2
                        Message->Order3 := morder3
                        Message->Order4 := morder4
                        Message->Order5 := morder5
                        Message->Order6 := morder6
                        UNLOCK
                        IF LastKey() == 27
                            RETURN NIL
                        ENDIF
                        mtrue := "Y"
                        // **         mtrue := ApGetY( Message->Correct )
                    ENDDO
                ENDIF
                mtrue := "Y"
                DO WHILE mtrue == "Y"
                    mgrecsheet := "N"
                    npl    := 54
                    mwhere := "S"

                    Printsel()                                  // SPECIFIC *.INIT

                    SELECT Orders
                    IF mwhere = "P"
                        OrderFrm( mordnum )                     // XL_Order.PRG
                        // **       OrdFrmChr( mordnum )                    // XL_Order.PRG
                    ELSE
                        Ordscrn( mordnum )                      // Above
                    ENDIF

                    EndPrint()
                    mtrue := "N"
                    // *** ApGetN( "Another Display/Print :" )
                ENDDO                    // mtrue
                LOOP
            CASE nselect == 3
                OrdEdit( @mordnum )
                LOOP
            CASE nselect == 6                        // Parts Required
                mok := "Y"
                DO WHILE mok == "Y"
                    SELECT QuotStk
                    SET ORDER TO 2                   // Partnum
                    GOTO TOP
                    nrecno := msumall := 0
                    aPart_ := {}
                    anum   := {}
                    IF LastRec() != 0
                        DO WHILE QuotStk->( !Eof() )
                            IF SubStr( Part->Partnum, 1, 2 ) = "ZZ"
                                SKIP ALIAS QuotStk
                                LOOP
                            ENDIF
                            SELECT Part
                            SEEK QuotStk->Partnum
                            mpartnum := Part->Partnum
                            SELECT QuotStk
                            IF Part->Boughtout != "Y"
                                SKIP ALIAS QuotStk
                                LOOP
                            ENDIF
                            SELECT Orders
                            SET ORDER TO 1                            // Partnum index
                            SEEK QuotStk->Partnum
                            mptot := nQty := 0
                            IF Found()
                                DO WHILE Orders->Partnum = QuotStk->Partnum .AND. Orders->( !Eof() )
                                    mptot += Orders->Partqty
                                    SKIP ALIAS Orders
                                ENDDO
                            ENDIF
                            SELECT QuotStk
                            mInvno   := QuotStk->Invno
                            DO WHILE QuotStk->Partnum = mpartnum .AND. QuotStk->( !Eof() )
                                nQty += QuotStk->Required - QuotStk->Received
                                SKIP ALIAS QuotStk
                            ENDDO
                            SELECT Part
                            ApRLock( 3 )
                            Part->ReqQty := nQty
                            Part->Invno  := mInvno
                            UNLOCK
                            AAdd( aPart_, Part->Codeno + " " + SubStr( Part->Desc, 1,25 );
                                + " " + SubStr( Part->Partnum, 1, 16 );
                                + " " + Str( Part->ReqQty, 7 );
                                + " " + Str( Part->Instock, 7 );
                                + " " + Str( mptot, 7 );
                                + "      " + Str( RecNo(), 6 ) )
                            SELECT QuotStk
                        ENDDO                      // Part EOF
                        IF !Empty( aPart_ )
                            Scroll()
                            DispBox(  0, 1, 2, 79, 2 )
                            @  1, 10 SAY "All Parts JC- Required"
                            Scroll(   3, 0, 24, 80 )
                            DispBox(  3, 1, 23, 79, 2 )
                            @ 4, 4 SAY "Codeno  Description                    Part     Required Instock Ordered"
                            ASort( aPart_,,, {| x, y | x < y } )
                            anum := AChoice(  5, 3, 22, 77, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
                            IF LastKey() == 27
                                EXIT
                            ENDIF
                            nrecno := Val( Right( aPart_[ anum ], 6 ) )
                            SELECT Part
                            GOTO nrecno
                            mpartnum := Part->Partnum
                            SELECT QuotStk
                            SEEK mpartnum
                            Scroll(  21, 3, 24, 78 )
                            DispBox( 21, 1, 24, 79, 2 )
                            @ 22, 4      SAY Trim( Part->Partnum ) + " Required = "
                            @ 22, Col() + 1 SAY Part->ReqQty  PICTURE "9,999.99"
                            @ 22, Col() + 2 SAY Part->Codeno
                            @ 22, Col() + 2 SAY Part->Unit
                            @ 22, Col() + 2 SAY Part->Invno COLOR "G+"
                            SELECT Part
                            DO CASE
                            CASE Part->Unit == "Mtr       "
                                @ 23, 8      SAY "Lengths ="
                                @ 23, Col() + 1 SAY Part->ReqQty / Part->Length PICTURE "9,999.99" COLOR "G+"
                                @ 23, Col() + 2 SAY Part->Length
                            CASE Part->Unit == "Sq Mtr    "
                                @ 23, 8      SAY "Sheets ="
                                @ 23, Col() + 1 SAY Part->ReqQty / ( Part->Width * Part->Length );
                                    PICTURE "9,999.99" COLOR "G+"
                                @ 23, Col() + 2 SAY Part->Width
                                @ 23, Col() + 2 SAY Part->Length
                            ENDCASE
                        ELSE
                            @ 22, 20 SAY " ---- No Parts Required ----"
                        ENDIF                       // !EMPTY
                    ENDIF                         // LastRec

                    OrdAddP( @mpartnum )
                    mok := ApGetY( Message->Another )
                    IF mok = "Y"
                        LOOP
                    ENDIF
                ENDDO                       // mok
                mok := "Y"
                LOOP
            CASE nselect == 4                        // Delete Order
                Scroll()
                @ 12, 10 SAY "This will delete this Order in Total are you Sure"
                mdelete := ApGetN( "Are You Sure :" )
                IF mdelete == "Y"
                    SELECT Orders
                    ApFLock( 3 )
                    DELETE ALL FOR Orders->Ordnum = mordnum
                    UNLOCK
                    RETURN NIL
                ENDIF
                // **          LOOP
            CASE nselect == 6
                OrdList()
            CASE nselect == 7                        // Lists Etc
                OrderTot()
            CASE nselect == 8                        // UpDate Data
                JobAllPa()                            // XLF_QU6
            ENDCASE
            manother = "Y"
        ENDDO
        mcontinue := "Y"
    ENDDO

    RETURN NIL

// ***------- End OrdbyOld()

// ***-----------------------------------------------------------------------

FUNCTION ModCat()

    manother := "Y"
    DO WHILE manother = "Y"

        ccatno := Space( 12 )
        Catarray( ccatno )
        cabc := "A"
        Scroll()
        ntrade := 0
        cblank := "XXXX"
        @ 14, 20 SAY "Parts Trade greater than" GET ntrade PICTURE "999999"
        @ 16, 20 SAY "Blank for ALL" GET cblank PICTURE "!!!!"
        @ 18, 20 SAY "Beware if big File not Practical View Only"
        READ
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
                    IF Part->Catno != ccatno
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                ENDIF
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
            @ 1, Col() + 1 SAY ntrade PICTURE "$99,999.99"  COLOR "BG+"
            @ 1, 24 SAY cat->catdesc  COLOR "BG+"
            @ 2, 3 SAY "A=High, B=Med, C=Contr, D=, E=, F=, M=Modules,Z=, ' '=All"
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
    Scroll()
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
    @  3, 2 SAY "Partnum   Description  Suppl"
    @  3, 45 SAY "ABC"
    @  3, 51 SAY "MinStk"
    @  3, 60 SAY "Instock    Used"
    nl := 5
    SELECT Part
    GOTO TOP
    DO WHILE Part->( !Eof() )
        // **          IF Part->Catno != ccatno
        // **             SKIP ALIAS Part
        // **             LOOP
        // **          ENDIF
        // **     NO TRADE    Not used here
        IF Part->Trade <= ntrade
            SKIP ALIAS Part
            LOOP
        ENDIF
        IF Part->ABC != cabc
            SKIP ALIAS Part
            LOOP
        ENDIF                // ABC
        IF nl > npl
            nl := 5
            IF mwhere == "P"
                EJECT
                @  0, 0 SAY Control->U_Name
                @  0, 46 SAY Time()
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                @  3, 2 SAY "Partnum   Description  SUppl"
                @  3, 41 SAY "ABC"
                @  3, 46 SAY "MinStk"
                @  3, 56 SAY "Instock    Used"
            ELSE
                WAIT
                Scroll()
                @  3, 2 SAY "Partnum   Description  Suppl"
                @  3, 41 SAY "ABC"
                @  3, 46 SAY "MinStk"
                @  3, 56 SAY "Instock    Used"
            ENDIF
        ENDIF
        @ nl, 1 SAY SUBST( Part->Partnum, 1, 12 ) + " " + SubStr( Part->Desc, 1, 20 )
        @ nl, 35 SAY Part->Codeno
        @ nl, 45 SAY Part->ABC PICTURE "!"
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

    RETURN NIL

// **----- End of ModCat

// **------------------------------------------------------

FUNCTION StockCat()

    manother := "Y"
    DO WHILE manother = "Y"

        ccatno := Space( 12 )
        Catarray( ccatno )
        Scroll()
        mcontinue := "Y"
        DO WHILE mcontinue = "Y"
            nrecno  := 0
            Scroll()
            SELECT Part
            GOTO TOP
            aPart_ := {}
            anum   := {}
            DO WHILE Part->( !Eof() )
                IF Part->Catno != ccatno
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                AAdd( aPart_, SubStr( Part->Partnum, 1, 12 );
                    + " " + SubStr( Part->Desc, 1, 28 );
                    + " " + Str( Part->Instock, 9 );
                    + " " + Str( Part->MinStk, 9 );
                    + " " + Str( Part->Trade, 9, 2 );
                    + " " + Part->ABC;
                    + " " + Part->Boughtout;
                    + "       " + Str( RecNo(), 6 ) )
                SKIP ALIAS Part
            ENDDO                                 // Part EOF
            DispBox( 0, 1, 2, 79, 2 )
            @ 1, 24 SAY cat->catdesc  COLOR "BG+"
            @ 1, 60 SAY "A=ABC B=Bought/Man"
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 1, 23, 79, 2 )
            @  4, 2 SAY "Partnum    Description"
            @  4, 47 SAY "InStock"
            @  4, 56 SAY "Minstock"
            @  4, 68 SAY "Trade"
            @  4, 75 SAY "A B"
            @ 24, 4 SAY"Esc to Exit" COLOR "RG+"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice( 5, 2, 22, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
            ENDIF
            SELECT Part
            GOTO nrecno
            ApRLock( 3 )
            @ Row(), 47 GET Part->Instock   PICTURE "999999"
            @ Row(), 56 GET Part->Minstk    PICTURE "999999"
            @ Row(), 64 GET Part->Trade     PICTURE "999999.99"
            @ Row(), 74 GET Part->ABC       PICTURE "!"
            @ Row(), 76 GET Part->Boughtout PICTURE "!"
            READ
            UNLOCK
            IF LastKey() = 27
                EXIT
            ENDIF
            LOOP
        ENDDO       // mcontinue

        manother := ApGetN( Trim( Message->Another ) + " Listing" )
    ENDDO                       // manother
    Scroll()
    SELECT Part

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
    @  3, 2 SAY "Partnum   Description"
    @  3, 45 SAY "ABC"
    @  3, 51 SAY "MinStk"
    @  3, 60 SAY "Instock    Used"
    nl := 5
    SELECT Part
    GOTO TOP
    DO WHILE Part->( !Eof() )
        IF Part->Catno != ccatno
            SKIP ALIAS Part
            LOOP
        ENDIF
        IF nl > npl
            nl := 5
            IF mwhere == "P"
                EJECT
                @  0, 0 SAY Control->U_Name
                @  0, 46 SAY Time()
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                @  3, 2 SAY "Partnum   Description"
                @  3, 41 SAY "ABC"
                @  3, 46 SAY "MinStk"
                @  3, 56 SAY "Instock    Used"
            ELSE
                WAIT
                Scroll()
                @  3, 2 SAY "Partnum   Description"
                @  3, 41 SAY "ABC"
                @  3, 46 SAY "MinStk"
                @  3, 56 SAY "Instock    Used"
            ENDIF
        ENDIF
        @ nl, 1 SAY SUBST( Part->Partnum, 1, 12 ) + "" + SubStr( Part->Desc, 1, 30 )
        @ nl, 45 SAY Part->ABC PICTURE "!"
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

// **-----------------End StockCat

// ****---------------------- END OF XF_UTIL2.PRG
