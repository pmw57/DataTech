*** JoKir 09-12-11 15:35:45 

/*  Program ........:                  XF_UTIL2.PRG
    Authors.........: John Kirby
    Date............: 07/10/2013
    Functions.......: YearSale, Ordarr, OrdByOld, StockCat, ModCat
    Static Functions:  
*/

FUNCTION YearSale()

    nl := 0
    ntotal:= ntotqty := 0
    nmonth1:= nmonth2:= nmonth3:= nmonth4:= nmonth5:= nmonth6 := 0
    nmonth7:= nmonth8:= nmonth9:= nmonth10:= nmonth11:= nmonth12 := 0
    n1total:= n1totqty := 0
    n1month1:= n1month2:= n1month3:= n1month4:= n1month5:= n1month6 := 0
    n1month7:= n1month8:= n1month9:= n1month10:= n1month11:= n1month12 := 0
    n2total:= n2totqty := 0
    n2month1:= n2month2:= n2month3:= n2month4:= n2month5:= n2month6 := 0
    n2month7:= n2month8:= n2month9:= n2month10:= n2month11:= n2month12 := 0
    n3total:= n3totqty := 0
    n3month1:= n3month2:= n3month3:= n3month4:= n3month5:= n3month6 := 0
    n3month7:= n3month8:= n3month9:= n3month10:= n3month11:= n3month12 := 0

    mwhere := "S"
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        SCROLL()
        DISPBOX( 0, 1, 2,79, 2 )
        SCROLL()
        @  1,10 SAY "Display is 4 Years To Date Sales by Saleno"
        dendmm   := YEAR( DATE() )
        @  6,10 SAY "Enter 2013 for 2013-2010, 2009 for 2009-2008 Records" COLOR "RG+"
        @  8,10 SAY Message->Todate GET dendmm PICTURE "9999"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        dstmm    := dendmm-3
        @  4, 1 SAY "Records In File"
        @  5, 1 SAY LASTREC()
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
        DO WHILE Hist->( !EOF() )
            IF SUBSTR( Hist->Invno, 5, 2 ) = "  "
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF Hist->Qty = 0
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF SUBSTR( Hist->Partnum, 1, 4 ) = "FREI"
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF YEAR( Hist->PDate ) < dstmm
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF YEAR( Hist->PDate ) > dendmm
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF YEAR( Hist->Pdate ) = dendmm
                DO CASE
                    CASE MONTH( Hist->Pdate ) = 1
                        nmonth1 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 2
                        nmonth2 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 3
                        nmonth3 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 4
                        nmonth4 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 5
                        nmonth5 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 6
                        nmonth6 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 7
                        nmonth7 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 8
                        nmonth8 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 9
                        nmonth9 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 10
                        nmonth10 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 11
                        nmonth11 += Hist->Qty
                    CASE MONTH( Hist->Pdate ) = 12
                        nmonth12 += Hist->Qty*Hist->Amount
                ENDCASE
                ntotal  += Hist->Amount*Hist->Qty
                ntotqty += Hist->Qty
            ENDIF                    // YEAR
            IF YEAR( Hist->Pdate ) = ( dendmm-1 )
                DO CASE
                    CASE MONTH( Hist->Pdate ) = 1
                        n1month1 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 2
                        n1month2 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 3
                        n1month3 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 4
                        n1month4 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 5
                        n1month5 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 6
                        n1month6 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 7
                        n1month7 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 8
                        n1month8 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 9
                        n1month9 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 10
                        n1month10 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 11
                        n1month11 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 12
                        n1month12 += Hist->Qty*Hist->Amount
                ENDCASE
                n1total  += Hist->Amount*Hist->Qty
                n1totqty += Hist->Qty
            ENDIF                    // YEAR
            IF YEAR( Hist->Pdate ) = ( dendmm-2 )
                DO CASE
                    CASE MONTH( Hist->Pdate ) = 1
                        n2month1 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 2
                        n2month2 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 3
                        n2month3 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 4
                        n2month4 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 5
                        n2month5 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 6
                        n2month6 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 7
                        n2month7 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 8
                        n2month8 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 9
                        n2month9 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 10
                        n2month10 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 11
                        n2month11 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 12
                        n2month12 += Hist->Qty*Hist->Amount
                ENDCASE
                n2total  += Hist->Amount*Hist->Qty
                n2totqty += Hist->Qty
            ENDIF                    // YEAR
            IF YEAR( Hist->Pdate ) = ( dendmm-3 )
                DO CASE
                    CASE MONTH( Hist->Pdate ) = 1
                        n3month1 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 2
                        n3month2 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 3
                        n3month3 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 4
                        n3month4 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 5
                        n3month5 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 6
                        n3month6 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 7
                        n3month7 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 8
                        n3month8 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 9
                        n3month9 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 10
                        n3month10 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 11
                        n3month11 += Hist->Qty*Hist->Amount
                    CASE MONTH( Hist->Pdate ) = 12
                        n3month12 += Hist->Qty*Hist->Amount
                ENDCASE
                n3total  += Hist->Amount*Hist->Qty
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
            SCROLL()
        ENDIF
        @  0, 0 SAY Control->U_Name
        @  0,46 SAY TIME()
        @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
            +STR( YEAR(DATE() ),5 )
        @ nl, 4  SAY "Sales"
        nl+= 2 
        @  nl,15 SAY dendmm-3 PICTURE "9999"
        @  nl,30 SAY dendmm-2 PICTURE "9999"
        @  nl,50 SAY dendmm-1 PICTURE "9999"
        @  nl,65 SAY dendmm   PICTURE "9999"
        SELECT Months
        GOTO 12
        nl++ 
        @  nl, 2 SAY Months->Brief
        @  nl,15 SAY n3month1 PICTURE "$9,999,999"   
        @  nl,30 SAY n2month1 PICTURE "$9,999,999"   
        @  nl,50 SAY n1month1 PICTURE "$9,999,999"   
        @  nl,65 SAY nmonth1  PICTURE "$9,999,999"
        GOTO 11
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl,15 SAY n3month2 PICTURE "$9,999,999"  
        @  nl,30 SAY n2month2 PICTURE "$9,999,999"  
        @  nl,50 SAY n1month2 PICTURE "$9,999,999"  
        @  nl,65 SAY nmonth2  PICTURE "$9,999,999"
        GOTO 10
        nl++
        @  nl,2 SAY Months->Brief
        @  nl,15 SAY n3month3 PICTURE "$9,999,999"  
        @  nl,30 SAY n2month3 PICTURE "$9,999,999"  
        @  nl,50 SAY n1month3 PICTURE "$9,999,999"  
        @  nl,65 SAY nmonth3  PICTURE "$9,999,999"
        GOTO  9
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl,15 SAY n3month4 PICTURE "$9,999,999"  
        @  nl,30 SAY n2month4 PICTURE "$9,999,999"  
        @  nl,50 SAY n1month4 PICTURE "$9,999,999"  
        @  nl,65 SAY nmonth4  PICTURE "$9,999,999" 
        GOTO  8
        nl++ 
        @  nl, 2 SAY Months->Brief
        @  nl,15 SAY n3month5 PICTURE "$9,999,999"  
        @  nl,30 SAY n2month5 PICTURE "$9,999,999"  
        @  nl,50 SAY n1month5 PICTURE "$9,999,999"  
        @  nl,65 SAY nmonth5  PICTURE "$9,999,999" 
        GOTO  7
        nl++  
        @  nl, 2 SAY Months->Brief
        @  nl,15 SAY n3month6 PICTURE "$9,999,999"  
        @  nl,30 SAY n2month6 PICTURE "$9,999,999"  
        @  nl,50 SAY n1month6 PICTURE "$9,999,999"  
        @  nl,65 SAY nmonth6  PICTURE "$9,999,999" 
        GOTO  6
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl,15 SAY n3month7 PICTURE "$9,999,999"  
        @  nl,30 SAY n2month7 PICTURE "$9,999,999"  
        @  nl,50 SAY n1month7 PICTURE "$9,999,999"  
        @  nl,65 SAY nmonth7  PICTURE "$9,999,999" 
        GOTO  5
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl,15 SAY n3month8 PICTURE "$9,999,999"  
        @  nl,30 SAY n2month8 PICTURE "$9,999,999"  
        @  nl,50 SAY n1month8 PICTURE "$9,999,999"  
        @  nl,65 SAY nmonth8  PICTURE "$9,999,999" 
        GOTO  4
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl,15 SAY n3month9 PICTURE "$9,999,999"  
        @  nl,30 SAY n2month9 PICTURE "$9,999,999"  
        @  nl,50 SAY n1month9 PICTURE "$9,999,999"  
        @  nl,65 SAY nmonth9  PICTURE "$9,999,999" 
        GOTO  3
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl,15 SAY n3month10 PICTURE "$9,999,999" 
        @  nl,30 SAY n2month10 PICTURE "$9,999,999" 
        @  nl,50 SAY n1month10 PICTURE "$9,999,999" 
        @  nl,65 SAY nmonth10  PICTURE "$9,999,999" 
        GOTO  2
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl,15 SAY n3month11 PICTURE "$9,999,999" 
        @  nl,30 SAY n2month11 PICTURE "$9,999,999" 
        @  nl,50 SAY n1month11 PICTURE "$9,999,999" 
        @  nl,65 SAY nmonth11  PICTURE "$9,999,999" 
        GOTO  1
        nl++
        @  nl, 2 SAY Months->Brief
        @  nl,15 SAY n3month12 PICTURE "$9,999,999" 
        @  nl,30 SAY n2month12 PICTURE "$9,999,999" 
        @  nl,50 SAY n1month12 PICTURE "$9,999,999" 
        @  nl,65 SAY nmonth12  PICTURE "$9,999,999" 
        nl+=2 

        @  nl, 5 SAY dendmm-3 PICTURE "9999"
        @  nl,30 SAY dendmm-2 PICTURE "9999"
        @  nl,50 SAY dendmm-1 PICTURE "9999"
        @  nl,65 SAY dendmm   PICTURE "9999"
        nl++
        @  nl, 5 SAY n3totqty PICTURE "99,999,999"
        @  nl,30 SAY n2totqty PICTURE "99,999,999"
        @  nl,50 SAY n1totqty PICTURE "99,999,999"
        @  nl,65 SAY ntotqty  PICTURE "99,999,999"
        nl++
        @  nl, 5 SAY n3total  PICTURE "$9,999,999" 
        @  nl,30 SAY n2total  PICTURE "$9,999,999" 
        @  nl,50 SAY n1total  PICTURE "$9,999,999" 
        @  nl,65 SAY ntotal   PICTURE "$9,999,999"
        nl+=2
        @  nl, 5 SAY "Totals"  
        @  nl,10 SAY ( n3totqty+n2totqty+n1totqty+ntotqty ) PICTURE "9,999,999"
        @  nl,25 SAY ( n3total+n2total+n1total+ntotal )     PICTURE "$99,999,999"
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

    ****---- End of YearCat

    ***-----------------------------------------------------------------

    FUNCTION Ordarr()

    SCROLL()

    aPart_   :={}
    *** mcodeno  := SPACE( 8 )
    mpartnum := SPACE( 20 )
    SELECT Orders
    SET ORDER TO 2                                  // Ordnum Index
    GOTO TOP
    mordnum := SPACE( 4 )
    DO WHILE Orders->( !EOF() )
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
        AADD( aPart_,Orders->Ordnum+"  "+Name->Name+"  "+DTOC( Orders->Date ) )
        DO WHILE Orders->Ordnum == mordnum .AND. Orders->( !EOF() )
            SKIP ALIAS Orders
        ENDDO
    ENDDO
    DISPBOX( 0, 1,  2,79, 2 )
    @  1, 6 SAY Name->Name
    @  1,58 SAY STR( DAY( DATE() ),3 )+" "+CMONTH( DATE() );
        +STR( YEAR( DATE() ),5 )
    DISPBOX( 3, 1, 24,79, 2 )
    IF !EMPTY( aPart_ )
        ASORT( aPart_,,,{ | x,y | x < y } )
        anum := ACHOICE( 4, 7, 23,73,aPart_,,"AFUNC" )
        IF LASTKEY() == 27
            RETURN SPACE(16)
        ENDIF
        mpartdes := aPart_[anum]
        mordnum  := SUBSTR( mpartdes, 1, 4 )
    ENDIF
    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        nrecno := 0 
        aPart_ :={}
        SELECT Orders
        SEEK mordnum
        DO WHILE Orders->Ordnum == mordnum .AND. Orders->( !EOF() )
            mpartnum := Orders->Partnum
            SELECT Part
            SEEK mpartnum
            SELECT Orders
            IF Orders->Partin = Orders->PartQty
                SKIP ALIAS Orders
                LOOP
            ENDIF 
            AADD( aPart_,SUBSTR( Partnum, 1,14 );
                +" "+SUBSTR( Orders->Detail1, 1,33 );
                +" "+STR( Orders->QtyRec, 7 ); 
                +" "+STR( Orders->PartQty, 7 );
                +" "+DTOC( Orders->ReqDate );
                +"          "+STR( RECNO(),6 ) )
            SKIP ALIAS Orders
        ENDDO
        SCROLL()
        DISPBOX( 0, 1,  2,79, 2 )
        @  1, 6 SAY Name->Name+" O/N # "+mordnum 
        @  1,58 SAY STR( DAY( DATE() ),3 )+" "+CMONTH( DATE() );
            +STR( YEAR( DATE() ),5 )
        SCROLL(  2, 0, 24,80 )
        DISPBOX( 2, 1, 24,79, 2 )
        @ 3,52 SAY "Received   Outs"
        IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE( 4, 3, 23,78,aPart_,,"AFUNC" )
            IF LASTKEY() == 27
                RETURN
            ENDIF
            mpartdes := aPart_[anum]
            nrecno   := VAL( RIGHT( mpartdes,6 ) )
            GOTO nrecno
            mpartnum := Orders->Partnum
        ENDIF
        IF nrecno == 0
            RETURN
        ENDIF                // nrecno
        SELECT Part
        SEEK mpartnum
        SCROLL(  3, 0, 24,80 )
        DISPBOX( 3, 1, 23,79, 2 )
        mreceived := 0
        mcorrect  := "N"
        DO WHILE mcorrect = "N"
            SELECT Part
            mdesc      := Part->Desc
            ntrade     := Part->Trade
            nwholesale := Part->Wholesale
            @  4,15 SAY Part->Partnum COLOR "GB+"
            @  4,55 SAY "Instock"
            @  4,COL()+1 SAY Part->Instock PICTURE "99,999.99" COLOR "GR+"  
            @  6,10 SAY "Description" GET mdesc      PICTURE "@X"
            READ
            ApRLock( 3 )
            Part->Desc := mdesc
            UNLOCK
            IF LASTKEY() == 27
                RETURN
            ENDIF
            SELECT Supl
            LOCATE FOR Supl->Partnum == mpartnum .AND. Supl->Codeno == Name->Codeno
            IF !FOUND()
                ApFLock( 3 )
                APPEND BLANK
                Supl->Partnum := Part->Partnum
                Supl->SuppId  := Part->Partnum
                ***        Supl->Cost    := Part->Trade
                Supl->Codeno  := Name->Codeno
                Supl->Date    := DATE()
                UNLOCK
            ENDIF
            msuppid   := Supl->SuppId
            ncost     := Supl->Cost
            nlastcost := Supl->LastCost
            @  8,10      SAY "Outstanding"
            IF Orders->Length > 0
                @  8,COL()+1 SAY "Length"
                @  8,COL()+1 SAY Orders->Length PICTURE "999"
            ENDIF
            @  8,COL()+1 SAY "Qty"
            @  8,COL()+1 SAY Orders->Partqty          PICTURE "99999.99"
            @  8,COL()+2 SAY "Received Qty" GET mreceived PICTURE "99999.99"
            @ 10,10      SAY "Cost Price"   GET ncost  PICTURE "99999.99"
            ***      @ 10,COL()+2 SAY   "Sell :"    GET nwholesale PICTURE "99999.99"
            READ
            @ 12,10      SAY "Suppliers Partnum" GET msuppid PICTURE "@K!"
            ***         @  9,10 SAY "Economic Order Qty :" GET Supl->Qty    PICTURE "99999.99"
            @ 14,10      SAY "Suppliers Cost"  GET ncost   PICTURE "99999.99"
            @ 16,14      SAY "Last Price"
            @ 16,COL()+2 SAY nlastcost PICTURE "$99,999.99"
            @ 18,10      SAY "CP Price "
            @ 18,COL()+2 SAY Part->Trade PICTURE "$999,999.99"
            @ 18,COL()+2 SAY "Change Price" GET ntrade PICTURE "999999.99"
            READ
            ***         @ 15,17 SAY "Information :" GET Supl->Info   PICTURE "@KX"
            ***         @ 17,24 SAY "Date :"        GET Supl->Date   PICTURE "99/99/99"
            ***          READ
            ApRLock( 3 )
            Supl->SuppId   := msuppid
            Supl->Cost     := ncost
            Supl->LastCost := ncost  // new Cost
            UNLOCK
            mcorrect := ApGetY( "Is the above correct" )
            IF LASTKEY() == 27 
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
            mreceived := mreceived*Orders->Length
        ENDIF
        SELECT Part
        ApRLock( 3 )
        Part->Trade   := ntrade
        Part->Instock += mreceived
        UNLOCK
        @ 18,60      SAY "Instock"
        @ 18,COL()+1 SAY Part->Instock PICTURE "99,999.99" COLOR "GR+"  
        IF LASTKEY() == 27 
            RETURN NIL
        ENDIF

        mcontinue := ApGetN( "Another Part Arrived" )
    ENDDO                                            // mcontinue

    RETURN NIL

***--------End Ordarr()

***----------------------------------------------------------------

FUNCTION OrdbyOld()

    cjsno := "      "
    mptot:= msum:= nQty := 0
    mpartnum   := SPACE( 20 )
    mcodeno    := SPACE( 8 )
    mgrecsheet := "N"
    mcontinue  := "Y"
    DO WHILE mcontinue == "Y"

        SELECT Orders
        SET ORDER TO 3                           // Codeno
        SEEK "A       "
        IF !FOUND()
            ApFLock( 3 )
            APPEND BLANK
            Orders->Codeno := "A       "
            UNLOCK
        ENDIF
        SCROLL()
        @ 23,50 SAY "F2 To View ALL Orders" COLOR "BG+"
        mcodeno := SPACE( 8 )
        nrecno   := 0
        anum     := {}
        aPart_   := {}
        nll      := 19
        SELECT Orders
        SET ORDER TO 3                           // Codeno+Ordnum
        GOTO TOP
        IF LASTREC() != 0
            DO WHILE Orders->( !EOF() )
                IF SUBSTR( Orders->Codeno, 1, 2 ) != "A "
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
                IF !FOUND()
                    @  18,60      SAY "No Name in File" COLOR "BG+"
                    @ nll,60      SAY Orders->Codeno    COLOR "BG+"
                    @ nll,COL()+1 SAY Orders->Ordnum    COLOR "BG+"
                    nll++
                    mcodeno := Orders->Codeno
                    SKIP ALIAS Orders
                    LOOP
                ENDIF
                SELECT Orders
                mcodeno := Name->Codeno
                AADD( aPart_,Name->Name;
                    +"       "+STR( RECNO(),6 ) )
                SKIP ALIAS Orders
            ENDDO                          // EOF()
            IF !EMPTY( aPart_ )
                ASORT( aPart_,,,{ | x,y | x < y } )
                SCROLL(   0, 0, 24,40 )
                DISPBOX(  0, 1, 24,40, 2 )
                anum   := ACHOICE( 1, 3, 23,39, aPart_,,"AFUNC" )    
                nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                GOTO nrecno
                mcodeno := Orders->Codeno
                SELECT Name
                SEEK mcodeno
                IF LASTKEY() == -1
                    SELECT Orders
                    SET ORDER TO 3                   // Codeno+Ordnum
                    nrecno := 0
                    aPart_ := {}
                    anum   := {}
                    DO WHILE Orders->( !EOF() )
                        SELECT Part
                        SET ORDER TO 1
                        SEEK Orders->Partnum
                        cdesc := SUBSTR( Orders->Detail1, 1,26 )
                        SELECT Orders
                        IF cdesc = SPACE( 30 )
                           cdesc := SUBSTR( Part->Desc, 1,26 ) 
                        ENDIF 
                        IF cdesc = SPACE( 30 )
                           cdesc := SUBSTR( Orders->Detail2, 1,26 )
                        ENDIF 
                        IF Orders->Partin = Orders->PartQty
                           SKIP ALIAS Orders
                           LOOP
                        ENDIF 
                        AADD( aPart_,Orders->Ordnum;
                            +" "+Orders->Codeno;
                            +" "+DTOC( Orders->Date );
                            +" "+cdesc;
                            +" "+STR( Orders->PartQty, 8, 2 );
                            +" "+STR( Orders->PartIn, 6 );
                            +"         "+STR( RECNO(),6 ) )
                        SKIP ALIAS Orders
                    ENDDO                  // Orders
                    IF !EMPTY( aPart_ )
                       SCROLL()
                       DISPBOX(  0, 1, 24,79, 2 )
                       @ 0,55 SAY "  Order     IN  "
                       ASORT( aPart_,,,{ | x,y | x < y } )
                       anum := ACHOICE(  1, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
                       nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
                       GOTO nrecno
                       IF LASTKEY() = 27 
                          RETURN NIL
                       ENDIF
                       mcodeno := Orders->Codeno
                       SELECT Name
                       SEEK mcodeno
                    ENDIF                        // Empty
                ENDIF
                IF LASTKEY() == 27 
                   RETURN NIL
                ENDIF
            ENDIF
            SCROLL()
            DISPBOX( 0, 1, 2,79, 2 )
            @  1,10 SAY Name->Name
            mcodeno := Name->Codeno
        ENDIF                        // LastRec
        IF mcodeno = "A       "
            SELECT Name
            mcodeno := SPACE( 8 )
            Namerank()                                     // ZFS_Name
            IF LASTKEY() == 27
                RETURN
            ENDIF
            SELECT Name
            mcodeno := Name->Codeno
        ENDIF
        IF mcodeno = SPACE( 8 )
            SELECT Name
            mcodeno := SPACE( 8 )
            Namerank()                                     // ZFS_Name
            IF LASTKEY() == 27
               RETURN
            ENDIF
            SELECT Name
            mcodeno := Name->Codeno
        ENDIF
        mordnum := SPACE( 4 )

        OrdLook( mcodeno )                      // XL_Orders

        SCROLL(  21, 0, 24,80 )
        DISPBOX( 21, 1, 24,79, 2 )
        @ 22,10      SAY "Order #" GET mordnum PICTURE "@KX"
        @ 22,COL()+2 SAY "Blank for New Order   Esc To Quit"
        @ 22,COL()+2 SAY Control->LastOrd 
        READ
        IF LASTKEY() == 27
           LOOP
        ENDIF
     
        IF mordnum = SPACE( 4 )
            SELECT Control
            ApRLock( 3 )
            Control->LastOrd := Control->LastOrd+1
            COMMIT
            UNLOCK
            mordnum := LTRIM( STR( Control->LastOrd ) )
        ENDIF
        SELECT Orders
        mqty := 0
        mqdate   := SUBSTR( DTOC( DATE() ), 1, 2 )
        mtotal:= mgtotal:= mggtotal:= mqtytotal:= 0
        manother := "Y"
        DO WHILE manother = "Y"
            OrdScrn( mordnum )                       
            SCROLL(  20, 0, 24,80 )
            DISPBOX( 20, 1, 24,79, 2 )
            nselect := 1
            @ 20,58 SAY " - Orders Menu - " COLOR "G+"
            @ 21, 4      PROMPT "Add Part"
            @ 21,COL()+2 PROMPT "No More Parts"
            @ 21,COL()+2 PROMPT "Edit Above"
            @ 21,COL()+2 PROMPT "Delete Order"  
            @ 21,COL()+4 SAY "ORDER # "+mordnum COLOR "BG+"
            MENU TO nselect
            DO CASE
            CASE LASTKEY() == 27
                mcontinue := "N"
                MenuB3()     // XLF_MenuB.prg 
                RETURN NIL
     
            CASE nselect == 1                            // Add Part
                mcodeno := Name->Codeno
                mpartnum := SPACE( 16 )
                SELECT Part
                IF mPartnum = SPACE( 16 ) 
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
                IF !FOUND()
                    LOOP
                ENDIF 
                SCROLL( 12, 0, 24,80 )
                coderef  := mpartnum
                MemoDisp( coderef )   // XF-Memo2
                SCROLL( 12, 0, 24,80 )
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
                    SCROLL( 12, 0, 24,80 )
                    DO WHILE mtrue == "N"
                        DISPBOX( 12, 5, 20,75, 2 )
                        SELECT Message
                        morder1 := "Please Deliver To:-                                         "
                        morder2 := Message->Order2
                        morder3 := Message->Order3
                        morder4 := Message->Order4
                        morder5 := Message->Order5
                        morder6 := Message->Order6
                        @ 14,10 GET morder1
                        @ 15,10 GET morder2
                        @ 16,10 GET morder3
                        @ 17,10 GET morder4
                        @ 18,10 GET morder5
                        @ 19,10 GET morder6
                        READ
                        ApRLock( 3 )
                        Message->Order1 := morder1
                        Message->Order2 := morder2
                        Message->Order3 := morder3
                        Message->Order4 := morder4
                        Message->Order5 := morder5
                        Message->Order6 := morder6
                        UNLOCK
                        IF LASTKEY() == 27 
                            RETURN NIL
                        ENDIF
                        mtrue := "Y"
                        ***         mtrue := ApGetY( Message->Correct )
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
                        ***       OrdFrmChr( mordnum )                    // XL_Order.PRG
                    ELSE
                        Ordscrn( mordnum )                      // Above
                    ENDIF

                    mtrue := "N"
                    **** ApGetN( "Another Display/Print :" )
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
                    nrecno:= msumall := 0
                    aPart_ := {}
                    anum   := {}
                    IF LASTREC() != 0
                        DO WHILE QuotStk->( !EOF() )
                            IF SUBSTR( Part->Partnum, 1, 2 ) = "ZZ"
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
                            mptot:= nQty := 0
                            IF FOUND()
                                DO WHILE Orders->Partnum = QuotStk->Partnum .AND. Orders->( !EOF() )
                                    mptot += Orders->Partqty
                                    SKIP ALIAS Orders
                                ENDDO
                            ENDIF
                            SELECT QuotStk
                            mInvno   := QuotStk->Invno
                            DO WHILE QuotStk->Partnum = mpartnum .AND. QuotStk->( !EOF() )
                                nQty += QuotStk->Required-QuotStk->Received
                                SKIP ALIAS QuotStk
                            ENDDO
                            SELECT Part
                            ApRLock( 3 )
                            Part->ReqQty := nQty
                            Part->Invno  := mInvno
                            UNLOCK           
                            AADD( aPart_,Part->Codeno+" "+SUBSTR( Part->Desc, 1,25 );
                                +" "+SUBSTR( Part->Partnum, 1,16 );
                                +" "+STR( Part->ReqQty, 7 );
                                +" "+STR( Part->Instock, 7 );
                                +" "+STR( mptot, 7 );
                                +"      "+STR( RECNO(),6 ) )
                            SELECT QuotStk
                        ENDDO                      // Part EOF
                        IF !EMPTY( aPart_ )
                            SCROLL()
                            DISPBOX(  0, 1, 2,79, 2 )
                            @  1,10 SAY "All Parts JC- Required"
                            SCROLL(   3, 0, 24,80 )
                            DISPBOX(  3, 1, 23,79, 2 )
                            @ 4, 4 SAY "Codeno  Description                    Part     Required Instock Ordered"
                            ASORT( aPart_,,,{ | x,y | x < y } )
                            anum := ACHOICE(  5, 3, 22,77,aPart_,"","AFUNC")  // AFUNC in XLP_Init
                            IF LASTKEY() == 27
                                EXIT
                            ENDIF
                            nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
                            SELECT Part
                            GOTO nrecno
                            mpartnum := Part->Partnum
                            SELECT QuotStk
                            SEEK mpartnum
                            SCROLL(  21, 3, 24,78 )
                            DISPBOX( 21, 1, 24,79, 2 )
                            @ 22, 4      SAY TRIM( Part->Partnum )+" Required = "
                            @ 22,COL()+1 SAY Part->ReqQty  PICTURE "9,999.99"
                            @ 22,COL()+2 SAY Part->Codeno
                            @ 22,COL()+2 SAY Part->Unit
                            @ 22,COL()+2 SAY Part->Invno COLOR "G+"
                            SELECT Part
                            DO CASE
                                CASE Part->Unit == "Mtr       "
                                    @ 23, 8      SAY "Lengths =" 
                                    @ 23,COL()+1 SAY Part->ReqQty/Part->Length PICTURE "9,999.99" COLOR "G+"
                                    @ 23,COL()+2 SAY Part->Length
                                CASE Part->Unit == "Sq Mtr    "
                                    @ 23, 8      SAY "Sheets =" 
                                    @ 23,COL()+1 SAY Part->ReqQty/( Part->Width*Part->Length );
                                    PICTURE "9,999.99" COLOR "G+"
                                    @ 23,COL()+2 SAY Part->Width
                                    @ 23,COL()+2 SAY Part->Length
                            ENDCASE
                        ELSE
                            @ 22,20 SAY " ---- No Parts Required ----"
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
                SCROLL()
                @ 12, 10 SAY "This will delete this Order in Total are you Sure"
                mdelete := ApGetN( "Are You Sure :" )
                IF mdelete == "Y"
                    SELECT Orders
                    ApFLock( 3 ) 
                    DELETE ALL FOR Orders->Ordnum = mordnum 
                    UNLOCK
                    RETURN NIL
                ENDIF
                ***          LOOP
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

****------- End OrdbyOld()

****-----------------------------------------------------------------------

FUNCTION ModCat()

    manother := "Y"
    DO WHILE manother = "Y"

        ccatno := SPACE( 12 )
        Catarray( ccatno ) 
        cabc := "A"
        SCROLL()
        ntrade := 0
        cblank := "XXXX"
        @ 14,20 SAY "Parts Trade greater than" GET ntrade PICTURE "999999"
        @ 16,20 SAY "Blank for ALL" GET cblank PICTURE "!!!!"
        @ 18,20 SAY "Beware if big File not Practical View Only"
        READ
        mcontinue := "Y"
        DO WHILE mcontinue = "Y"
            nrecno  := 0
            SCROLL()
            SELECT Part
            GOTO TOP
            aPart_ := {}
            anum   := {} 
            DO WHILE Part->( !EOF() )
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
                AADD( aPart_,SUBSTR( Part->Partnum, 1, 12 );
                    +" "+SUBSTR(Part->Desc, 1, 28 );
                    +" "+Part->ABC;
                    +" "+Part->Boughtout;
                    +" "+STR( Part->MinStk,9 );
                    +" "+STR( Part->Instock,9 );
                    +" "+STR( Part->Utd,9 );
                    +"       "+STR( RECNO(),6 ) )
                SKIP ALIAS Part
            ENDDO                                 // Part EOF
            DISPBOX( 0, 1, 4,79, 2 )
            @ 1, 3      SAY "Trade >" COLOR "BG+"
            @ 1,COL()+1 SAY ntrade PICTURE "$99,999.99"  COLOR "BG+"
            @ 1,24 SAY cat->catdesc  COLOR "BG+"
            @ 2, 3 SAY "A=High, B=Med, C=Contr, D=, E=, F=, M=Modules,Z=, ' '=All"
            @ 3, 3      SAY "B/M Y=Bought N=Own Manufacture" 
            @ 3,COL()+3 SAY "WAIT takes Time" COLOR "RG+" 
            SCROLL(  5, 0, 24,80 ) 
            DISPBOX( 5, 1, 23,79, 2 )
            @  6, 2 SAY "Partnum    Description"
            @  6,43 SAY "ABC B/M"
            @  6,52 SAY "MinStk"
            @  6,61 SAY "Instock     Used"
            @ 24, 4 SAY"Esc to Exit" COLOR "RG+"
            IF !EMPTY( aPart_ )
                ASORT( aPart_,,,{ | x,y | x < y } )
                anum   := ACHOICE( 7, 2, 22,76, aPart_,,"AFUNC" )
                nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            ENDIF
            SELECT Part
            GOTO nrecno
            ApRLock( 3 )
            @ ROW(),44 GET Part->ABC PICTURE "!"
            @ ROW(),46 GET Part->Boughtout PICTURE "!"
            @ ROW(),51 GET Part->MinStk  PICTURE "999999"
            @ ROW(),61 GET Part->Instock PICTURE "999999"
            READ   
            UNLOCK
            IF LASTKEY() = 27
                EXIT
            ENDIF
            LOOP
        ENDDO       // mcontinue
 
        manother := ApGetN( TRIM( Message->Another )+" Listing" )
    ENDDO                       // manother
    SCROLL()
    SELECT Part
    cabc := "A"
    nselect := 1
    @  8,30 PROMPT "1. A - High Priority  "
    @  9,30 PROMPT "2. B - Med  Priority  "
    @ 10,30 PROMPT "3. C - Low  Priority  "
    @ 11,30 PROMPT "4. D -                "
    @ 12,30 PROMPT "5. E - Own Manufacture"
    @ 13,30 PROMPT "6. F - Materials Steel"
    @ 14,30 PROMPT "7. M - Modules        "
    @ 15,30 PROMPT "8. Z - Contractors    "
    @ 16,30 PROMPT "9. ALL selected  Some DBF too Big for this BEWARE"   
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
        SCROLL()
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0,46 SAY TIME()
    @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
        +STR( YEAR(DATE() ),5 )
    @  3, 2 SAY "Partnum   Description  Suppl"
    @  3,45 SAY "ABC"
    @  3,51 SAY "MinStk"
    @  3,60 SAY "Instock    Used"
    nl := 5        
    SELECT Part
    GOTO TOP
    DO WHILE Part->( !EOF() )
        ***          IF Part->Catno != ccatno
        ***             SKIP ALIAS Part
        ***             LOOP 
        ***          ENDIF
        ***     NO TRADE    Not used here
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
                @  0,46 SAY TIME()
                @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                        +STR( YEAR(DATE() ),5 )
                @  3, 2 SAY "Partnum   Description  SUppl"
                @  3,41 SAY "ABC"
                @  3,46 SAY "MinStk"
                @  3,56 SAY "Instock    Used"
            ELSE
                WAIT
                SCROLL()
                @  3, 2 SAY "Partnum   Description  Suppl"
                @  3,41 SAY "ABC"
                @  3,46 SAY "MinStk"
                @  3,56 SAY "Instock    Used"
            ENDIF
        ENDIF
        @ nl, 1 SAY SUBST( Part->Partnum, 1, 12 )+" "+SUBSTR( Part->Desc, 1,20 )
        @ nl,35 SAY Part->Codeno  
        @ nl,45 SAY Part->ABC PICTURE "!"
        @ nl,46 SAY Part->MinStk  PICTURE "99,999.99"
        @ nl,56 SAY Part->Instock PICTURE "99,999.99"
        @ nl,66 SAY Part->Utd     PICTURE "999,999.99"
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

***----- End of ModCat

***------------------------------------------------------

Function StockCat()

    manother := "Y"
    DO WHILE manother = "Y"

        ccatno := SPACE( 12 )
        Catarray( ccatno ) 
        SCROLL()
        mcontinue := "Y"
        DO WHILE mcontinue = "Y"
            nrecno  := 0
            SCROLL()
            SELECT Part
            GOTO TOP
            aPart_ := {}
            anum   := {} 
            DO WHILE Part->( !EOF() )
                IF Part->Catno != ccatno
                    SKIP ALIAS Part
                    LOOP 
                ENDIF
                AADD( aPart_,SUBSTR( Part->Partnum, 1, 12 );
                    +" "+SUBSTR(Part->Desc, 1, 28 );
                    +" "+STR( Part->Instock,9 );
                    +" "+STR( Part->MinStk,9 );
                    +" "+STR( Part->Trade,9,2 );
                    +" "+Part->ABC;
                    +" "+Part->Boughtout;
                    +"       "+STR( RECNO(),6 ) )
                SKIP ALIAS Part
            ENDDO                                 // Part EOF
            DISPBOX( 0, 1, 2,79, 2 )
            @ 1,24 SAY cat->catdesc  COLOR "BG+"
            @ 1,60 SAY "A=ABC B=Bought/Man"
            SCROLL(  3, 0, 24,80 ) 
            DISPBOX( 3, 1, 23,79, 2 )
            @  4, 2 SAY "Partnum    Description"
            @  4,47 SAY "InStock"
            @  4,56 SAY "Minstock"
            @  4,68 SAY "Trade"
            @  4,75 SAY "A B"
            @ 24, 4 SAY"Esc to Exit" COLOR "RG+"
            IF !EMPTY( aPart_ )
                ASORT( aPart_,,,{ | x,y | x < y } )
                anum   := ACHOICE( 5, 2, 22,78, aPart_,,"AFUNC" )
                nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            ENDIF
            SELECT Part
            GOTO nrecno
            ApRLock( 3 )
            @ ROW(),47 GET Part->Instock   PICTURE "999999"
            @ ROW(),56 GET Part->Minstk    PICTURE "999999"
            @ ROW(),64 GET Part->Trade     PICTURE "999999.99"
            @ ROW(),74 GET Part->ABC       PICTURE "!"
            @ ROW(),76 GET Part->Boughtout PICTURE "!"
            READ   
            UNLOCK
            IF LASTKEY() = 27
                EXIT
            ENDIF
            LOOP
        ENDDO       // mcontinue
     
        manother := ApGetN( TRIM( Message->Another )+" Listing" )
    ENDDO                       // manother
    SCROLL()
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
        SCROLL()
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0,46 SAY TIME()
    @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
        +STR( YEAR(DATE() ),5 )
    @  3, 2 SAY "Partnum   Description"
    @  3,45 SAY "ABC"
    @  3,51 SAY "MinStk"
    @  3,60 SAY "Instock    Used"
    nl := 5        
    SELECT Part
    GOTO TOP
    DO WHILE Part->( !EOF() )
        IF Part->Catno != ccatno
            SKIP ALIAS Part
            LOOP 
        ENDIF
        IF nl > npl
            nl := 5
            IF mwhere == "P"
                EJECT
                @  0, 0 SAY Control->U_Name
                @  0,46 SAY TIME()
                @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
                @  3, 2 SAY "Partnum   Description"
                @  3,41 SAY "ABC"
                @  3,46 SAY "MinStk"
                @  3,56 SAY "Instock    Used"
            ELSE
                WAIT
                SCROLL()
                @  3, 2 SAY "Partnum   Description"
                @  3,41 SAY "ABC"
                @  3,46 SAY "MinStk"
                @  3,56 SAY "Instock    Used"
            ENDIF
        ENDIF
        @ nl, 1 SAY SUBST( Part->Partnum, 1, 12 )+""+SUBSTR( Part->Desc, 1,30 )
        @ nl,45 SAY Part->ABC PICTURE "!"
        @ nl,46 SAY Part->MinStk  PICTURE "99,999.99"
        @ nl,56 SAY Part->Instock PICTURE "99,999.99"
        @ nl,66 SAY Part->Utd     PICTURE "999,999.99"
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
    ***      manother := ApGetN( TRIM( Message->Another )+" Listing" )
    ***   ENDDO                       // manother

    RETURN NIL

 ***-----------------End StockCat

*****---------------------- END OF XF_UTIL2.PRG