// ** JoKir11  05-11-11 16:55:21

/*  Program ......:                 QLSTPART.PRG
    Authors.......: John Kirby
    Date..........: 24/12/1994
    Functions.....: ChriFacDis, FactoryAdd, FactoryPAdd, FactoryPrice,
                  : FactoryEdit, QPuotDesc, QPuotList, QPuotParts
*/

FUNCTION ChriFacDis()                 // called by ChriMenu ChriFac

    nselect := 1
    Scroll()
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        nqty := 0
        SELECT Quot
        GOTO TOP
        IF LastRec() = 0
            @ 7, 53 SAY "NO Work Orders"
            Inkey( 2 )
            RETURN NIL
        ENDIF
        // ***   @ 10,10 SAY "Work Orders Listings" COLOR "BG+"
        SET ORDER TO 1
        Scroll( 22, 0, 24, 80 )
        DispBox( 22, 1, 24, 79, 2 )
        @ 23, 8      PROMPT "URGENT"
        @ 23, Col() + 2 PROMPT "Due Date"
        @ 23, Col() + 2 PROMPT "List by Name"
        @ 23, Col() + 2 PROMPT "Partnum List"
        @ 23, Col() + 2 PROMPT "Order Date"
        @ 23, Col() + 2 PROMPT "Print"
        // ***   @ 23,COL()+2 PROMPT "CLEAN UP"
        MENU TO nselect
        DO CASE
        CASE LastKey() = 27
            RETURN
        CASE nselect == 1                  // Urgent
            nselect := 1
            Scroll()
            nchoice := 1
            Scroll( 1, 68, 23, 78 )
            DispBox( 1, 68, 24, 79, 2 )
            // **         mchoice := VAL( STR( MONTH( dduedate ) ) )+3
            @  5, 70 PROMPT "URGENT  "
            @  6, 70 PROMPT "SPECIAL "
            @  7, 70 PROMPT "PRIORITY"
            @ 10, 70 PROMPT "JANUARY "
            @ 11, 70 PROMPT "FEBRUARY"
            @ 12, 70 PROMPT "MARCH   "
            @ 13, 70 PROMPT "APRIL   "
            @ 14, 70 PROMPT "MAY     "
            @ 15, 70 PROMPT "JUNE    "
            @ 16, 70 PROMPT "JULY    "
            @ 17, 70 PROMPT "AUGUST  "
            @ 18, 70 PROMPT "SEPT    "
            @ 19, 70 PROMPT "OCTOBER "
            @ 20, 70 PROMPT "NOVEMBER"
            @ 21, 70 PROMPT "DECEMBER"
            MENU TO mchoice
            DO CASE
            CASE LastKey() = 27
                RETURN
            CASE mchoice == 1
                cfaxno := "  URGENT"
            CASE mchoice == 2
                cfaxno := " SPECIAL"
            CASE mchoice == 3
                cfaxno := "   PRIOR"
            CASE mchoice == 4
                cfaxno := "JANUARY "
            CASE mchoice == 5
                cfaxno := "FEBUARY "
            CASE mchoice == 6
                cfaxno := "MARCH   "
            CASE mchoice == 7
                cfaxno := "APRIL   "
            CASE mchoice == 8
                cfaxno := "MAY     "
            CASE mchoice == 9
                cfaxno := "JUNE    "
            CASE mchoice == 10
                cfaxno := "JULY    "
            CASE mchoice == 11
                cfaxno := "AUGUST  "
            CASE mchoice == 12
                cfaxno := "SEPT    "
            CASE mchoice == 13
                cfaxno := "OCTOBER "
            CASE mchoice == 14
                cfaxno := "NOVEMBER"
            CASE mchoice == 15
                cfaxno := "DECEMBER"
            ENDCASE
            aPart_ := {}
            anum   := {}
            nrecno := 0
            GOTO TOP
            DO WHILE Quot->( !Eof() )
                IF Quot->Codeno = "A       "
                    SKIP ALIAS Quot
                    LOOP
                ENDIF
                IF Quot->Faxno != cfaxno
                    SKIP ALIAS Quot
                    LOOP
                ENDIF
                nqty++
                ddate := Str( Year( Quot->Duedate ) );
                    + Str( Month( Quot->DueDate ) );
                    + Str( Day( Quot->DueDate ) );
                    + " " + Quot->Faxno
                AAdd( aPart_, ddate;
                    + " " + SubStr( Quot->Info, 1, 13 );
                    + " " + Quot->Codeno + " " + Quot->BranchId;
                    + " " + Str( Quot->OrgQty, 6, 0 );
                    + " " + Str( Quot->Qty, 6, 0 );
                    + " " + Str( Quot->Goodsent, 6, 0 );
                    + " " + SubStr( Quot->Partnum, 1, 8 );
                    + "                " + Str( RecNo(), 6 ) )
                SKIP ALIAS Quot
            ENDDO
            Scroll()
            DispBox( 0, 1, 24, 79, 2 )
            IF !Empty( aPart_ )
                @  0, 2       SAY "  Records  "
                @  0, Col() + 1  SAY nqty PICTURE "9999" COLOR "RG+"
                @  0, 48       SAY " Ordered O/S Qty  Inv " COLOR "RG+"
                ASort( aPart_,,, {| x, y | x < y } )                // < = Top > = End
                anum := AChoice( 1, 2, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                IF LastKey() = 27
                    RETURN
                ENDIF
            ENDIF     // Empty
            IF nqty = 0
                Scroll()
                DispBox( 5, 1, 14, 79, 2 )
                @ 10, 10 SAY "No Records this selection"
                @ 12, 10 SAY ""
                WAIT
                LOOP
            ENDIF             // nrecno

        CASE nselect == 2                     // Due Date
            nselect := 2
            Scroll()
            aPart_ := {}
            anum   := {}
            nrecno := 0
            GOTO TOP
            DO WHILE Quot->( !Eof() )
                IF Quot->Codeno = "A       "
                    SKIP ALIAS Quot
                    LOOP
                ENDIF
                ddate := Str( Year( Quot->Duedate ) ) + Str( Month( Quot->DueDate ) );
                    + Str( Day( Quot->DueDate ) ) + " " + Quot->Faxno
                AAdd( aPart_, ddate;
                    + " " + Quot->Codeno + " " + Quot->BranchId;
                    + " " + Str( Quot->OrgQty, 6, 0 );
                    + " " + Str( Quot->Qty, 6, 0 );
                    + " " + Str( Quot->Goodsent, 6, 0 );
                    + " " + SubStr( Quot->Partnum, 1, 8 );
                    + " " + SubStr( Quot->Ordnum, 1, 16 );
                    + "                " + Str( RecNo(), 6 ) )
                SKIP ALIAS Quot
            ENDDO
            DispBox( 0, 1, 24, 79, 2 )
            @  0, 3 SAY " Due Date " COLOR "RG+"
            @  0, 35 SAY " Ordered O/S Qty  Inv " COLOR "RG+"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )                // < = Top > = End
                anum := AChoice( 1, 2, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                IF LastKey() = 27
                    RETURN
                ENDIF
            ENDIF     // Empty

        CASE nselect == 3                      // Name
            nselect := 3
            Scroll()
            aPart_ := {}
            anum   := {}
            nrecno := 0
            GOTO TOP
            DO WHILE Quot->( !Eof() )
                IF Quot->Codeno = "A       "
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
            @  0, 3 SAY " Name List " COLOR "RG+"
            @  0, 14 SAY " Ordered O/S Qty  Inv " COLOR "RG+"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 1, 2, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                IF LastKey() = 27
                    RETURN
                ENDIF
            ENDIF     // Empty

        CASE nselect == 4                       // Part
            nselect := 4
            Scroll()
            aPart_ := {}
            anum   := {}
            nrecno := 0
            GOTO TOP
            DO WHILE Quot->( !Eof() )
                IF Quot->Codeno = "A       "
                    SKIP ALIAS Quot
                    LOOP
                ENDIF
                ddate := Str( Year( Quot->Duedate ) );
                    + Str( Month( Quot->DueDate ) );
                    + Str( Day( Quot->DueDate ) );
                    + " " + Quot->Faxno
                AAdd( aPart_, SubStr( Quot->Partnum, 1, 8 );
                    + " " + Str( Quot->OrgQty, 6, 0 );
                    + " " + Str( Quot->Qty, 6, 0 );
                    + " " + Str( Quot->Goodsent, 6, 0 );
                    + " " + Quot->Codeno + " " + Quot->BranchId;
                    + " " + ddate;
                    + " " + SubStr( Quot->Ordnum, 1, 16 );
                    + "                " + Str( RecNo(), 6 ) )
                SKIP ALIAS Quot
            ENDDO
            DispBox( 0, 1, 24, 79, 2 )
            @  0, 3 SAY " PartNum " COLOR "RG+"
            @  0, 13 SAY " Order O/S Qty  Inv " COLOR "RG+"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )                // < = Top > = End
                anum := AChoice( 1, 2, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                IF LastKey() = 27
                    RETURN
                ENDIF
            ENDIF     // Empty

        CASE nselect == 5                   // Order Date
            nselect := 5
            Scroll()
            aPart_ := {}
            anum   := {}
            nrecno := 0
            GOTO TOP
            DO WHILE Quot->( !Eof() )
                IF Quot->Codeno = "A       "
                    SKIP ALIAS Quot
                    LOOP
                ENDIF
                ddate := Str( Year( Quot->Duedate ) );
                    + Str( Month( Quot->DueDate ) );
                    + Str( Day( Quot->DueDate ) );
                    + " " + Quot->Faxno
                dTest := Str( Year( Quot->DbDate ) );
                    + Str( Month( Quot->DbDate ) );
                    + Str( Day( Quot->DbDate ) )
                AAdd( aPart_, dTest;
                    + " " + ddate;
                    + " " + Quot->Codeno;
                    + " " + Quot->BranchId;
                    + " " + Str( Quot->OrgQty, 6, 0 );
                    + " " + Str( Quot->Qty, 6, 0 );
                    + " " + Str( Quot->Goodsent, 6, 0 );
                    + " " + SubStr( Quot->Partnum, 1, 8 );
                    + " " + SubStr( Quot->Ordnum, 1, 16 );
                    + "               " + Str( RecNo(), 6 ) )
                SKIP ALIAS Quot
            ENDDO
            DispBox( 0, 1, 24, 79, 2 )
            @  0, 3 SAY " Order Date " COLOR "RG+"
            @  0, 47 SAY " Ordered O/S Qty Inv " COLOR "RG+"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 1, 2, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                IF LastKey() = 27
                    RETURN
                ENDIF
            ENDIF     // Empty

        CASE nselect == 6
            nselect := 6
            QuotFaxno()                 // ChriQPrn
            LOOP
        ENDCASE

        QuotChange()                        // QuoHouse
        LOOP
    ENDDO                      // mcontinue

    RETURN

// ***---- End of ChriFacDis()

// **-------------------------------------------------------------------

FUNCTION QuotFaxno()

    Scroll()
    mchoice := 0
    npn     := 1
    mcodeno := Space( 8 )
    cfaxno  := "AA      "
    mbranchId := Space( 2 )
    ctotpart :=  cpart := "N"
    SELECT Quot
    SET ORDER TO 1
    ddateSt := mdate := Date()
    ddate   := Date() + 2
    @  6, 10 SAY "Blank for All Groups" GET cfaxno PICTURE "@!"
    READ
    IF cfaxno != Space( 8 )
        mchoice := Val( Str( Month( Date() ) ) ) + 3
        @  8, 10 SAY "Listing Orders  Select Group"
        Scroll( 1, 68, 23, 78 )
        DispBox( 1, 68, 24, 79, 2 )
        @  5, 70 PROMPT "URGENT  "
        @  6, 70 PROMPT "SPECIAL "
        @  7, 70 PROMPT "PRIORITY"
        @ 10, 70 PROMPT "JANUARY "
        @ 11, 70 PROMPT "FEBRUARY"
        @ 12, 70 PROMPT "MARCH   "
        @ 13, 70 PROMPT "APRIL   "
        @ 14, 70 PROMPT "MAY     "
        @ 15, 70 PROMPT "JUNE    "
        @ 16, 70 PROMPT "JULY    "
        @ 17, 70 PROMPT "AUGUST  "
        @ 18, 70 PROMPT "SEPT    "
        @ 19, 70 PROMPT "OCTOBER "
        @ 20, 70 PROMPT "NOVEMBER"
        @ 21, 70 PROMPT "DECEMBER"
        MENU TO mchoice
        DO CASE
        CASE LastKey() = 27
            RETURN
        CASE mchoice == 1
            cfaxno := "  URGENT"
        CASE mchoice == 2
            cfaxno := " SPECIAL"
        CASE mchoice == 3
            cfaxno := "   PRIOR"
        CASE mchoice == 4
            cfaxno := "JANUARY "
        CASE mchoice == 5
            cfaxno := "FEBUARY "
        CASE mchoice == 6
            cfaxno := "MARCH   "
        CASE mchoice == 7
            cfaxno := "APRIL   "
        CASE mchoice == 8
            cfaxno := "MAY     "
        CASE mchoice == 9
            cfaxno := "JUNE    "
        CASE mchoice == 10
            cfaxno := "JULY    "
        CASE mchoice == 11
            cfaxno := "AUGUST  "
        CASE mchoice == 12
            cfaxno := "SEPT    "
        CASE mchoice == 13
            cfaxno := "OCTOBER "
        CASE mchoice == 14
            cfaxno := "NOVEMBER"
        CASE mchoice == 15
            cfaxno := "DECEMBER"
        ENDCASE
    ENDIF                 // Empty
    IF mchoice >= 4
        cpart    := ApGetN( "Do You Want by Part" )
        ctotpart := ApGetN( "Total Parts List" )
        IF cpart = "Y"
            INDEX ON Quot->Partnum TO TempInd9
            SET INDEX TO TempInd9
        ENDIF
        @ 10, 10      SAY "This is the Date Due NOT the Order Date" COLOR "RG+"
        @ 12, 10      SAY ddateSt                                   COLOR "RG+"
        @ 12, Col() + 2 SAY "Due From Date   " GET ddateSt PICTURE "99/99/9999"
        @ 14, 10      SAY ddate                                     COLOR "RG+"
        @ 14, Col() + 2 SAY "Due Up to Date  " GET ddate   PICTURE "99/99/9999"
        READ
/*
   IF ctotpart = "Y"
      @ 16,10      SAY mdate                   COLOR "RG+"
      @ 16,COL()+2 SAY "Parts Up to Date" GET mdate PICTURE "99/99/9999"
   ENDIF
    READ
*/
        IF LastKey() == 27
            RETURN NIL
        ENDIF
    ENDIF                     // mchoice >= 4

    mwhere := "S"

    Printsel( mwhere )

    IF mwhere == "P"
        npl := 56
        @  0, 0
        SET DEVICE TO PRINT
    ELSE
        Scroll()
        npl := 20
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0, 62 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  0, 76 SAY npn PICTURE "999"
    @  1, 20 SAY cfaxno
    @  1, 32 SAY "Due Date From " + DToC( ddatest ) + " To " + DToC( ddate )
    npn++
    nl := 3
    GOTO TOP
    DO WHILE Quot->( !Eof() )
        IF cfaxno != Space( 8 )
            IF Quot->Faxno != cfaxno
                SKIP ALIAS Quot
                LOOP
            ENDIF
        ENDIF
        IF mchoice >= 4
            IF Quot->Duedate > ddate
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF Quot->Duedate < ddateSt
                SKIP ALIAS Quot
                LOOP
            ENDIF
        ENDIF              // mchoice
        IF nl > npl
            IF mwhere == "P"
                EJECT
                @  0, 0 SAY Control->U_Name
                @  0, 62 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                @  0, 76 SAY npn PICTURE "999"
                @  1, 20 SAY cfaxno
                @  1, 32 SAY "Due Date From " + DToC( ddatest ) + " To " + DToC( ddate )
                npn++
            ELSE
                WAIT
                Scroll( 3, 0, 24, 80 )
            ENDIF
            nl := 3
        ENDIF
        mpartnum := Quot->Partnum
        IF mpartnum != Space( 20 )
            SELECT Part
            SEEK mpartnum
            @ nl, 0 SAY Quot->DbDate
            @ nl, 11 SAY Quot->Codeno
            @ nl, 20 SAY Quot->BranchId
            @ nl, 23 SAY Quot->Qty      PICTURE "99,999"
            @ nl, 30 SAY SubStr( Quot->Partnum, 1, 9 )
            @ nl, 40 SAY SubStr( Part->Desc, 1, 28 )
            @ nl, 70 SAY Quot->Faxno                      // 8 Char
            nl++
            IF Quot->Info  != Space( 45 )
                @ nl, 28 SAY Quot->Info
                nl++
            ENDIF
            IF Quot->Info2 != Space( 45 )
                @ nl, 28 SAY Quot->Info2
                nl++
            ENDIF
            IF Quot->Info3 != Space( 45 )
                @ nl, 28 SAY Quot->Info3
                nl++
            ENDIF
            IF Quot->Info4 != Space( 45 )
                @ nl, 28 SAY Quot->Info4
                nl++
            ENDIF
            IF Quot->Info5 != Space( 45 )
                @ nl, 28 SAY Quot->Info5
                nl++
            ENDIF
            IF Quot->Info6 != Space( 45 )
                @ nl, 28 SAY Quot->Info6
                nl++
            ENDIF
            IF Quot->Info7 != Space( 45 )
                @ nl, 28 SAY Quot->Info7
                nl++
            ENDIF
            IF Quot->Info8 != Space( 45 )
                @ nl, 28 SAY Quot->Info8
                nl++
            ENDIF
            IF Quot->Info9 != Space( 45 )
                @ nl, 28 SAY Quot->Info9
                nl++
            ENDIF
            SELECT Quot
        ENDIF                        // mpartnum
        SKIP ALIAS Quot
    ENDDO                           // EOF()
    nl++
    IF ctotpart = "Y"
        SELECT Quot
        IF cpart = "N"
            INDEX ON Quot->Partnum TO TempInd9
            SET INDEX TO TempInd9
        ENDIF
        GOTO TOP
        npn := npos := nrow := 1
        IF mwhere == "P"
            EJECT
            @  0, 0 SAY Control->U_Name    // 35
            @  0, 37 SAY "ALL Orders To"
            @  0, 52 SAY mdate
            @  0, 64 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  0, 76 SAY npn PICTURE "999"
            npn++
            nl := 2
        ENDIF                  // mwhere = "P"
        DO WHILE Quot->( !Eof() )
            IF Quot->Dbdate > mdate
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF nl > npl
                nl := 2
                IF mwhere == "P"
                    EJECT
                    @  0, 0 SAY Control->U_Name    // 35
                    @  0, 37 SAY "ALL Orders To"
                    @  0, 52 SAY mdate
                    @  0, 64 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  0, 76 SAY npn PICTURE "999"
                    npn++
                ELSE
                    WAIT
                    Scroll()
                ENDIF                  // mwhere = "P"
            ENDIF                    // nl > npl
            mtotal := 0
            mpartnum := Quot->Partnum
            SELECT Quot
            DO WHILE Quot->Partnum = mpartnum .AND. Quot->( !Eof() )
                IF Quot->Dbdate > mdate
                    SKIP ALIAS Quot
                    LOOP
                ENDIF
                mtotal += Quot->Qty
                SKIP ALIAS Quot
            ENDDO
            @  nl, npos SAY " " + Str( mtotal, 6 ) + " " + SubStr( mpartnum, 1, 10 )
            npos := npos + 20
            nrow++
            IF nrow = 5
                nl++
                nrow := npos := 1
            ENDIF
        ENDDO
    ENDIF                    // cpart
    nl++
    IF mwhere = "P"
        @ nl, 0 SAY " "
        EndPrint()
    ELSE
        IF nl > 18
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF
    SELECT Quot
    SET INDEX TO QuotInd

    RETURN NIL

// *** End of QuotFaxno()

// *-------------------------------------------------------------------

FUNCTION FactoryPrice( mpartnum )

    SELECT Quot
/*
   IF Quot->Qty == 0
       ApRLock( 3 )
      Quot->Qty := 1
      UNLOCK
   ENDIF
*/
    Scroll()
    DispBox( 0, 1, 4, 79, 2 )
    DispBox( 5, 1, 24, 79, 2 )
    @  1, 3 SAY Name->Name + " " + Name->Add1 + " " + cbranchId
    @  3, 3 SAY Trim( Part->Partnum ) + " " + Trim( Part->Desc ) + " " + Trim( Part->Unit )
    SELECT Name
    csent   := Space( 9 )
    csentby := Space( 14 )
    cinit   := Space( 3 )
    cdocno  := Space ( 16 )
    cchange := "N"
    @  6, 6 SAY Name->Desc3 COLOR "BG+"
    ApFLock( 3 )
    IF Name->Desc3 != Space( 50 )
        cchange := ApGetN( "CHANGE Sent Details" )
    ENDIF   // cchange
    IF cchange = "Y"
        Name->Desc3 := Space( 50 )
    ENDIF
    UNLOCK
    IF Name->Desc3 = Space( 50 )
        Scroll( 1, 68, 23, 78 )
        DispBox( 1, 68, 24, 79, 2 )
        @  5, 70 SAY "Sent By" COLOR "BG+"
        nsel := 1
        @  7, 70 PROMPT "Blank    "
        @  8, 70 PROMPT "Owens    "
        @  9, 70 PROMPT "TNL      "
        @ 10, 70 PROMPT "NZCourier"
        @ 11, 70 PROMPT "FastWays "
        @ 12, 70 PROMPT "Grant    "
        @ 13, 70 PROMPT "Mike     "
        @ 14, 70 PROMPT "Picked Up"
        @ 15, 70 PROMPT "TransWest"
        @ 16, 70 PROMPT "WhiteLine"
        @ 17, 70 PROMPT "OwnCourie"
        @ 18, 70 PROMPT "M.Stream "
        @ 19, 70 PROMPT "Grundy   "
        MENU TO nsel
        DO CASE
        CASE LastKey() == 27
            RETURN
        CASE nsel == 1
            csent := Space( 9 )
        CASE nsel == 2
            csent := "Owens    "
        CASE nsel == 3
            csent := "TNL      "
        CASE nsel == 4
            csent := "NZCourier"
        CASE nsel == 5
            csent := "FastWays"
        CASE nsel == 6
            csent := "Grant    "
        CASE nsel == 7
            csent := "Mike     "
        CASE nsel == 8
            csent := "Picked Up"
        CASE nsel == 9
            csent := "TransWest"
        CASE nsel == 10
            csent := "WhiteLine"
        CASE nsel == 11
            csent := "OwnCourie"
        CASE nsel == 12
            csent := "M.Stream "
        CASE nsel == 13
            csent := "Grundy   "
        ENDCASE
        // ***    ENDIF             /// csent
        @  9, 20 SAY csent + " Docket #" GET csentby PICTURE "@!"
        @ 11, 20 SAY "Initials"        GET cinit   PICTURE "@!"
        @ 11, 40 SAY "Despatch #"      GET cdocno  PICTURE "@!"
        READ
        ApFLock( 3 )
        Name->Desc3 := csent + " " + csentby + " " + cinit + " " + cdocno  // 9+1+19+1+20
        UNLOCK
    ENDIF
    Scroll(  5, 0, 24, 80 )
    DispBox( 5, 1, 24, 79, 2 )
    nl := 6
    SELECT Quot
    nQty      := Quot->Qty
    nGoodSent := Quot->GoodSent
    csentby   := SubStr( Name->Desc3, 1, 24 )
    cdocno    := SubStr( Name->Desc3, 26, 20 )
    cordnum   := Quot->OrdNum
    ddbate    := Quot->DbDate
    cfaxno    := Quot->Faxno
    cinfo8    := Quot->Info8
    cinfo9    := Quot->Info9
    nl += 2
    @ nl, 10      SAY  Trim( Part->Unit ) + " Qty" GET nQty PICTURE "999999.99"
    nl += 2
    @ nl, 10      SAY "Qty Sent" GET nGoodSent PICTURE "999999.99"
    nl += 2
    @ nl, 10      SAY "How Sent"   GET cSentby
    @ nl, Col() + 1 SAY "Docket #"   GET cDocno
    nl += 2
    @ nl, 10      SAY "O/N"        GET cordnum   PICTURE "@!"
    @ nl, Col() + 1 SAY "Date"       GET dDbdate   PICTURE "99/99/9999"
    @ nl, Col() + 1 SAY "Ref"        GET cFaxno    PICTURE "@X"
    nl += 2
    @ nl, 10 SAY "Notes"    GET cInfo8
    nl++
    @ nl, 10 SAY "     "    GET cInfo9
    READ
    ApRLock( 3 )
    Quot->Qty      := nQty
    Quot->GoodSent := nGoodSent
    Quot->SentBy   := csentby
    Quot->Docno    := cdocno
    Quot->OrdNum   := cordnum
    Quot->DbDate   := dbdate
    Quot->Faxno    := cfaxno
    Quot->Info8    := cinfo8
    Quot->Info9    := cinfo9
    Quot->BranchId := cbranchId
    Quot->Catno    := Part->Catno
    Quot->Amount   := Part->Wholesale
    Quot->Cost     := Part->Trade
    IF Quot->Qty = 0
        DELETE
    ENDIF
    UNLOCK

    RETURN mpartnum

// ***------- End FactoryPrice

// *-------------------------------------------------------------------

FUNCTION FactoryPAdd( mpartnum )

    quotcodeno := Name->Codeno
    IF mpartnum = Space( 20 )
        SELECT Part
        SET ORDER TO 1
        Scroll()
        Partfind( @mpartnum )                // XlF_Part
        mpartnum := Part->Partnum
        IF LastKey() == 27
            RETURN( mcodeno )
        ENDIF
    ENDIF                            // mpartnum
    SELECT Name
    SEEK quotcodeno
    mcodeno := Name->Codeno
    SELECT Part
    SET ORDER TO 1                  // Partnum
    SEEK mpartnum
    IF Found()
        SELECT Quot
        ApFLock( 3 )
        APPEND BLANK
        Quot->Partnum  := mpartnum
        Quot->Codeno   := Name->Codeno
        Quot->Catno    := Part->Catno
        Quot->Amount   := Part->Wholesale
        Quot->Cost     := Part->Trade
        Quot->BranchId := cbranchId
        Quot->Dbdate   := Date()
        // **      Quot->Ordnum   := Name->Remarks
        // **      Quot->Faxno    := Name->Refer
        UNLOCK
        SELECT Control
        ApRLock( 3 )
        Control->LastQuot := Control->LastQuot + 1
        UNLOCK
        SELECT Quot
        mok := "N"
        DO WHILE mok = "N"
            FactoryPrice( @mpartnum )                         // Above
            mok := ApGetY( Trim( Message->Correct ) )
        ENDDO
    ELSE
        Scroll()
    ENDIF

    RETURN( mpartnum )

// ***---- End of FactoryPAdd()

// *-------------------------------------------------------------------

FUNCTION FactoryAdd()

    dDbDate   := Date()
    mcodeno   := Space ( 8 )
    mpartnum  := Space( 20 )
    cfaxno    := Str( Control->LastQuot, 8, 0 )

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"

        Namerank( @mcodeno )                            // ZSF_Name

        IF LastKey() == 27
            RETURN NIL
        ENDIF
        mcodeno := Name->Codeno
        cbranchId := Space( 2 )
        SELECT Branch
        SEEK mcodeno
        IF Found()

            BranchFind( @mcodeno )             // ZSF_Name
            cbranchId := Branch->BranchId

            mok := ApGetY( "Do you Want Branch" )
            IF mok = "N"
                cbranchId := Space( 2 )
            ENDIF
        ENDIF
        manother := "Y"
        DO WHILE manother = "Y"
            mok := "Y"
            DO WHILE mok = "Y"
                Scroll( 3, 0, 24, 80 )
                SELECT Quot
                SEEK mcodeno
                IF Found()

                    aPart_ := {}
                    SELECT Quot
                    SET ORDER TO 1
                    GOTO TOP
                    IF LastRec() != 0
                        SEEK mcodeno
                        DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !Eof() )
                            IF Quot->DbDate != Date()
                                SKIP ALIAS Quot
                                LOOP
                            ENDIF
                            // **      IF Quot->Invno != SPACE( 6 )
                            // **         IF Quot->Invno != "9    "
                            // **             SKIP ALIAS Quot
                            // **             LOOP
                            // **         ENDIF
                            // **      ENDIF
                            IF cbranchId != Space( 2 )
                                IF Quot->BranchId != cbranchId
                                    SKIP ALIAS Quot
                                    LOOP
                                ENDIF
                            ENDIF
                            mpartnum := Quot->Partnum
                            SELECT Part
                            SEEK mpartnum
                            SELECT Quot
                            AAdd( aPart_, SubStr( Part->Partnum,1, 8 );
                                + " " + SubStr( Part->Desc, 1, 25 );
                                + " " + Str( Quot->OrgQty, 5 );
                                + " " + Str( Quot->Qty, 5 );
                                + " " + Str( Quot->GoodSent, 5 );
                                + " " + SubStr( Quot->Ordnum, 1, 5 );
                                + " " + DToC( DbDate );
                                + " " + Quot->BranchId;
                                + "             " + Str( RecNo(), 6 ) )
                            SKIP ALIAS Quot
                        ENDDO
                        Scroll()
                        DispBox( 0, 1, 2, 79, 2 )
                        @  1, 4      SAY Trim( Name->Name )
                        @  1, Col() + 2 SAY Trim( Name->Called )
                        @  1, Col() + 1 SAY Trim( Name->Famname )
                        @  1, Col() + 2 SAY cbranchId                       COLOR "G+"
                        DispBox( 3, 1, 23, 79, 2 )
                        IF !Empty( aPart_ )
                            @  3, 42 SAY " Ordered O/S Qty  Supp Qty"
                            ASort( aPart_,,, {| x, y | x < y } )
                            // **      @  3,00 SAY " "
                            // ***      AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " ),QQOUT(A),Breakpoint() } )
                            anum := AChoice( 4, 3, 22, 78, aPart_,, "AFUNC" )
                            IF LastKey() == 27
                                RETURN( mcodeno )
                            ENDIF
                            nrecno := Val( Right( aPart_[ anum ],6 ) )
                            SELECT Quot
                            GOTO nrecno
                            mcodeno    := Quot->Codeno
                            mpartnum   := Quot->Partnum
                            cfaxno     := Quot->Faxno
                            dDbdate    := Quot->DbDate
                            quotcodeno := Quot->Codeno
                        ENDIF
                    ENDIF
                ENDIF
                Scroll(  22, 0, 24, 80 )
                DispBox( 22, 1, 24, 79, 2 )
                minvno  := Space( 6 )
                nselect := 1
                @ 23, 10      PROMPT "Add Part"
                @ 23, Col() + 3 PROMPT "Edit Part"
                @ 23, Col() + 3 PROMPT "Exit"
                MENU TO nselect

                DO CASE
                CASE LastKey() == 27
                    RETURN
                CASE nselect == 1
                    quotcodeno := Space( 8 )
                    mpartnum := Space( 20 )
                    FactoryPAdd( @mpartnum )                 // Below
                    LOOP
                CASE nselect == 2
                    FactoryEdit( @mcodeno )                  // Below
                    LOOP
                CASE nselect == 3
                    RETURN
                ENDCASE
            ENDDO                               // End of more Parts
        ENDDO
        mcontinue := "N"
    ENDDO                                   // mcontinue

    RETURN NIL

// ***----- End of Factoryadd()

// *---------------------------------------------------------------------*

FUNCTION FactoryEdit( mcodeno )

    mpartnum := Space( 20 )
    mcontinue = "Y"
    DO WHILE mcontinue = "Y"
        aPart_ := {}
        nrecno := ntotal := 0
        nweight := 0
        SELECT Quot
        GOTO TOP
        SEEK mcodeno
        DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !Eof() )
            IF Quot->Invno != Space( 6 )
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF Quot->BranchId != cbranchId
                SKIP ALIAS Quot
                LOOP
            ENDIF
            SELECT Part
            SEEK Quot->Partnum
            nweight := nweight + ( Quot->GoodSent * Part->Weight )
            SELECT Quot
            ntotal += Quot->Qty * Quot->Amount
            AAdd( aPart_, SubStr( Quot->Partnum, 1, 8 );
                + " " + SubStr( Part->Desc, 1, 24 );
                + "  " + Str( Quot->OrgQty, 5 );
                + "  " + Str( Quot->Qty, 5 );
                + " " + Str( Quot->GoodSent, 5 );
                + " " + SubStr( Quot->Ordnum, 1, 8 );
                + " " + DToC( Quot->DbDate );
                + " " + Quot->BranchId;
                + "               " + Str( RecNo(), 6 ) )
            SKIP ALIAS Quot
        ENDDO
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 4      SAY Trim( Name->Name )
        @  1, Col() + 2 SAY Trim( Name->Called )
        @  1, Col() + 1 SAY Trim( Name->Famname )
        @  1, Col() + 2 SAY cbranchId                  COLOR "G+"
        @  1, Col() + 2 SAY "Weight"                   COLOR "G+"
        @  1, Col() + 2 SAY nweight PICTURE "9,999.99" COLOR "G+"
        @  1, Col() + 2 SAY "kg"                       COLOR "G+"
        DispBox( 3, 1, 23, 79, 2 )
        @  23, 60    SAY "Weight"                   COLOR "G+"
        @  23, Col() + 2 SAY nweight PICTURE "9,999.99" COLOR "G+"
        @  23, Col() + 2 SAY "kg  "                     COLOR "G+"
        @  3, 44 SAY " Order O/S Qty Supp Qty "
        cfaxno     := Space( 8 )
        quotcodeno := Space( 8 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 22, 78, aPart_,, "AFUNC" )
            IF LastKey() == 27
                RETURN( mcodeno )
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            SELECT Quot
            GOTO nrecno
            mpartnum   := Quot->Partnum
            cfaxno     := Quot->Faxno
            dDbdate    := Quot->DbDate
            quotcodeno := Quot->Codeno
            SELECT Part
            SEEK mpartnum
        ENDIF
        Scroll(  15, 0, 24, 80 )
        DispBox( 15, 1, 24, 79, 2 )
        FactoryPrice( @mpartnum )
        FactoryEdit( @mcodeno )
        mcontinue = "N"

    ENDDO                       // mcontinue

    RETURN( mpartnum )

// **-----End of FactoryEdit()

// *-------------------------------------------------------------------

FUNCTION QPuotParts()

    Scroll()
    DispBox( 6, 1, 16, 79, 2 )
    msum := 0
    mdate := Date()
    @ 10, 15 SAY "Listing Quotations"
    @ 14, 15 SAY "Up to Date " GET mdate PICTURE "99/99/99"
    READ

    Printsel( mwhere )

    IF mwhere == "P"
        npl := 56
        @  0, 0
        SET DEVICE TO PRINT
    ELSE
        Scroll()
        npl := 20
    ENDIF
    @ 0, 0 SAY Control->U_Name   // 35
    @ 0, 38 SAY "To Date"
    @ 0, 47 SAY mdate
    @ 0, 58 SAY Str( Day(  Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    nl := 2
    SELECT Quot
    ApFLock( 3 )
    INDEX ON Quot->Partnum TO TempInd9
    SET INDEX TO TempInd9
    UNLOCK
    GOTO TOP
    DO WHILE Quot->( !Eof() )
        IF Quot->Dbdate > mdate
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF nl > npl
            nl := 2
            IF mwhere == "P"
                EJECT
                @ 0, 0 SAY Control->U_Name   // 35
                @ 0, 38 SAY "To Date"
                @ 0, 47 SAY mdate
                @ 0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
            ELSE
                WAIT
                Scroll( 3, 0, 24, 80 )
            ENDIF                  // mwhere = "P"
        ENDIF                    // nl > npl
        mtotal := nbuy := 0
        mpartnum := Quot->Partnum
        SELECT Quot
        DO WHILE Quot->Partnum = mpartnum .AND. Quot->( !Eof() )
            IF Quot->Dbdate > mdate
                SKIP ALIAS Quot
                LOOP
            ENDIF
            mtotal += Quot->Qty
            SKIP ALIAS Quot
        ENDDO
        SELECT Part
        SET ORDER TO 1                   // Partnum
        SEEK mpartnum
        @ nl, 0 SAY mtotal PICTURE "99,999"
        @ nl, 7 SAY SubStr( Part->Partnum, 1, 12 )
        @ nl, 20 SAY Part->PartId
        @ nl, 37 SAY Part->Desc
        nl += 1
    ENDDO
    IF mwhere = "P"
        @ nl, 0 SAY " "
        EndPrint()
        SET MARGIN TO 0
    ELSE
        IF nl > 23
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF
    SELECT Quot
    SET INDEX TO QuotInd

    RETURN NIL

// *** End of QPuotParts()

// *-------------------------------------------------------------------

FUNCTION QPuotList()

    Scroll()
    @ 10, 15 SAY "Listing Work Orders"
    mcodeno   := Space( 8 )
    cbranchid := Space( 2 )
    mok := "N"
    mdateok := "N"
    // **   mdateok := ApGetN( "Y = Total Inv & Part W/O" )
    mselect   := ApGetN( "Individual Name Only" )
    // **   mDueDate  := ApGetN( "W/O Overdue Only" )
    IF LastKey() == 27
        RETURN NIL
    ENDIF
    IF mselect == "Y"
        aPart_ := anum := {}
        nrecno := 0
        maccepted := "N"
        Scroll()
        DispBox( 0, 50, 3, 79, 2 )
        @  1, 52 SAY "Select Name - Branch"
        @  2, 52 SAY "Branch Specific"
        SELECT Quot
        IF LastRec() != 0
            GOTO TOP
            mtempno := Space( 10 )
            DO WHILE Quot->( !Eof() )
                IF mdateok = "N"
                    IF Quot->Invno != Space( 6 )
                        SKIP ALIAS Quot
                        LOOP
                    ENDIF
                ENDIF
                IF Quot->Codeno + Quot->BranchId = mtempno
                    SKIP ALIAS Quot
                    LOOP
                ENDIF
                SELECT Name
                SEEK Quot->Codeno
                SELECT Quot
                mtempno := Quot->Codeno + Quot->BranchId
                AAdd( aPart_, Name->Name + "  " + Quot->BranchId;
                    + " " + Quot->Invno + "     " + Str( RecNo(), 6 ) )
                SKIP ALIAS Quot
            ENDDO
            DispBox( 0, 1, 24, 47, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 1, 3, 23, 46, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                IF LastKey() == 27
                    RETURN NIL
                ENDIF
            ENDIF
            GOTO nrecno
            mcodeno   := Quot->Codeno
            cbranchId := Quot->BranchId
        ENDIF                        // Lastrec
    ENDIF                           // mselect
    Scroll()
    ddateSt := Date() -300
    ddate   := Date()
    @ 10, 10      SAY "This is Customer Order Date" COLOR "RG+"
    @ 12, 10      SAY ddateSt                                   COLOR "RG+"
    @ 12, Col() + 2 SAY "From Date   " GET ddateSt PICTURE "99/99/9999"
    @ 14, 10      SAY ddate                                     COLOR "RG+"
    @ 14, Col() + 2 SAY "Up to Date  " GET ddate   PICTURE "99/99/9999"
    READ
    mwhere := "S"

    Printsel( mwhere )

    IF mwhere == "P"
        npl := 56
        @  0, 0
        SET DEVICE TO PRINT
    ELSE
        Scroll()
        npl := 20
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0, 46 SAY Time()
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    nl := 2

    mgtotal := 0
    SELECT Quot
    GOTO TOP
    IF mcodeno = Space( 8 )
        mcodeno   := Quot->Codeno
        cbranchId := Quot->BranchId
    ENDIF
    SELECT Name
    SEEK mcodeno
    @ nl, 0 SAY Name->Name
    SELECT Branch
    GOTO TOP
    SEEK Quot->Codeno + Quot->BranchId
    IF Found()
        IF Branch->Contact != Space( 30 )
            @ nl, 32 SAY Branch->Contact
            @ nl, 74 SAY Branch->BranchId
        ELSE
            @ nl, 32 SAY Branch->Name
            @ nl, 74 SAY Branch->BranchId
        ENDIF
    ENDIF
    nl++
    DO WHILE Quot->( !Eof() )
        IF mdateok = "N"
            IF Quot->Invno != Space( 6 )
                SKIP ALIAS Quot
                LOOP
            ENDIF
        ENDIF
        IF mselect == "Y"                         // Individual Name
            IF Quot->Codeno != mcodeno
                SKIP ALIAS Quot
                LOOP
            ENDIF                                  // Branch Loop
            IF Quot->BranchId != cbranchId
                SKIP ALIAS Quot
                LOOP
            ENDIF                                  // Branch Loop
        ENDIF                                     // mselect == "Y"
        IF Quot->DbDate < ddateSt
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF Quot->Dbdate > ddate
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF nl > npl
            nl := 3
            IF mwhere == "P"
                EJECT
                @ 1, 46 SAY Time()
                @ 1, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
            ELSE
                WAIT
                Scroll( 2, 0, 24, 80 )
            ENDIF
        ENDIF
        IF Quot->Codeno = mcodeno
            IF Quot->BranchId != cbranchId
                nl++
                @ nl, 0 SAY Name->Name
                SELECT Branch
                GOTO TOP
                SEEK Quot->Codeno + Quot->BranchId
                IF Found()
                    IF Branch->Contact != Space( 30 )
                        @ nl, 32 SAY Branch->Contact
                        @ nl, 74 SAY Branch->BranchId
                    ELSE
                        @ nl, 32 SAY Branch->Name
                        @ nl, 74 SAY Branch->BranchId
                    ENDIF
                ENDIF
                SELECT Quot
                cbranchId := Quot->BranchId
                nl++
            ENDIF                         // BranchId
        ENDIF
        IF Quot->Codeno != mcodeno // New Codeno
            mcodeno   := Quot->Codeno
            cbranchId := Quot->BranchId
            SELECT Name
            SEEK Quot->Codeno
            nl++
            @ nl, 0 SAY Name->Name
            SELECT Branch
            GOTO TOP
            SEEK Quot->Codeno + Quot->BranchId
            IF Found()
                IF Branch->Contact != Space( 30 )
                    @ nl, 32 SAY Branch->Contact
                    @ nl, 74 SAY Branch->BranchId
                ELSE
                    @ nl, 32 SAY Branch->Name
                    @ nl, 74 SAY Branch->BranchId
                ENDIF
                SELECT Quot
                cbranchId := Quot->BranchId
            ENDIF                         // BranchId
            nl++
        ENDIF
        SELECT Quot
        mpartnum := Quot->Partnum
        IF mpartnum != Space( 20 )
            SELECT Part
            SEEK mpartnum
            @ nl, 0 SAY Quot->DbDate
            @ nl, 10 SAY Quot->Qty      PICTURE "99,999"
            IF Quot->GoodSent > 0
                @ nl, 17 SAY Quot->GoodSent PICTURE "99,999"
            ENDIF
            @ nl, 25 SAY SubStr( Quot->Partnum, 1, 8 )
            @ nl, 35 SAY SubStr( Quot->Ordnum, 1, 10 )
            // **       @ nl,41 SAY Quot->Faxno
            @ nl, 47 SAY SubStr( Part->Desc, 1, 27 )
            @ nl, 76 SAY Quot->BranchId
            nl++
            IF Quot->Info  != Space( 45 )
                @ nl, 16 SAY Quot->Info
                nl++
            ENDIF
            IF Quot->Info2 != Space( 45 )
                @ nl, 16 SAY Quot->Info2
                nl++
            ENDIF
            IF Quot->Info3 != Space( 45 )
                @ nl, 16 SAY Quot->Info3
                nl++
            ENDIF
            IF Quot->Info4 != Space( 45 )
                @ nl, 16 SAY Quot->Info4
                nl++
            ENDIF
            IF Quot->Info5 != Space( 45 )
                @ nl, 16 SAY Quot->Info5
                nl++
            ENDIF
            IF Quot->Info6 != Space( 45 )
                @ nl, 16 SAY Quot->Info6
                nl++
            ENDIF
            IF Quot->Info7 != Space( 45 )
                @ nl, 16 SAY Quot->Info7
                nl++
            ENDIF
            IF Quot->Info8 != Space( 45 )
                @ nl, 16 SAY Quot->Info8
                nl++
            ENDIF
            IF Quot->Info9 != Space( 45 )
                @ nl, 16 SAY Quot->Info9
                nl++
            ENDIF
            SELECT Quot
            mgtotal += Quot->Amount * Quot->Qty
        ENDIF                        // mpartnum
        SKIP ALIAS Quot
    ENDDO                           // EOF()
    nl += 2
    // ** @ nl,10 SAY "Total"
    // ** @ nl,16 SAY mgtotal PICTURE "$9,999,999.99"
    IF mwhere = "P"
        @ nl, 0 SAY " "
        EndPrint()
    ELSE
        IF nl > 18
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN NIL

// *** End of QPuotlist()

// *-------------------------------------------------------------------

FUNCTION QPuotDesc()

    Scroll()
    @ 10, 15 SAY "Listing Production Parts in Work Orders by Desc"
    mwhere := ApGetN( "Do You Want Printer" )
    IF mwhere = "Y"
        SET PRINTER ON
        ? Control->U_Name + "  " + Time() + " " + Str( Day(  Date() ), 3 );
            + " " + CMonth( Date() ) + Str( Year( Date() ), 5 )
        ? "Desc                                     Part#     Required    Instock"
        ?
        ?? Chr( 27 ) + "C" + Chr( 66 )
        SET PRINTER OFF
    ELSE
        Scroll()
        @  0, 0 SAY Control->U_Name + "  " + Time() + " " + Str( Day( Date() ), 3 );
            + " " + CMonth( Date() ) + Str( Year( Date() ), 5 )
        @  1, 2 SAY "Desc                                   Part#     Required    Instock"
        @  2, 0 SAY "  "
    ENDIF
    aPart_ := {}
    SELECT Quot
    GOTO TOP
    ApFLock( 3 )
    INDEX ON Quot->Partnum TO TempInd9
    SET INDEX TO TempInd9
    UNLOCK
    GOTO TOP
    namount := 0
    DO WHILE Quot->( !Eof() )
/*
      IF Quot->Invno != SPACE( 6 )    // Part W/O No Invno
         SKIP ALIAS Quot
         LOOP
      ENDIF
*/
        mpartnum := Quot->Partnum
        ntotal := 0
        DO WHILE Quot->Partnum = mpartnum .AND. Quot->( !Eof() )
            ntotal  += Quot->Qty
            namount += ( Quot->Qty * Quot->Amount )
            SKIP ALIAS Quot
        ENDDO
        SELECT Part
        SEEK mpartnum
        cdesc := Part->Desc   // Must use this method for Array
        // otherwise Sort no good
        AAdd( aPart_, cdesc + " " + SubStr( mpartnum,1,12 ) + " " + Str( ntotal,8,2 );
            + "   " + Str( Part->Instock, 8 ) )
        SELECT Quot
    ENDDO
    ASort( aPart_,,, {| x, y | x < y } )
    IF mwhere = "Y"
        SET PRINTER ON
        AEval( aPart_, {|A| QOUT( A ), Breakprint() } )     // XF_Util
        ? " "
        ? "Total Amount = $" + Str( namount )
        EJECT
        SET PRINTER OFF
    ELSE
        AEval( aPart_, {|A| QOUT( A ), BreakTot() } )     // XF_Util
    ENDIF
    IF mwhere = "N"
        @ 21, 20 SAY "Total Amount ="
        @ 21, 35 SAY namount PICTURE "$9,999,999.99"
        WAIT
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF
    SELECT Quot
    SET INDEX TO QuotInd

    RETURN NIL

// *** End of QPuotDesc()

// **-------------------------- End Of QLSTPART.PRG
