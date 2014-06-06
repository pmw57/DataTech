// ** JoKir10   22-10-11 13:45:42

/*
    Program ......:                 XF_QLIST.PRG
    Authors.......: John Kirby
    Date..........: 24/12/1994
    Functions.....: QuotStart, QSelectPC, QuotListPC, QuotOrdCP
                    QuotParts, QuotDesc, QuotList
    Static funcs..: Progress
*/

FUNCTION QuotStart()

    manother := "Y"
    DO WHILE manother == "Y"
        Scroll()
        DispBox( 4, 1, 18, 79, 2 )
        dStartDate  := Date() -100
        dEndDate    := Date() + 100
        dDueDate    := Date() -100
        dDueEndDate := Date() + 100
        nselect := 1
        @  5, 10 SAY "Listing All Job Cards or by Start Date - Due Date"
        @  7, 10 PROMPT "1. All Job Cards"
        @  8, 10 PROMPT "2. By Start Date"
        @  9, 10 PROMPT "3. By Due   Date"
        @ 10, 10 PROMPT "4. Production JC"

        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nselect == 1
            dStartDate  := Date() -400
            dEndDate    := Date() + 400
            dDueDate    := Date() -400
            dDueEndDate := Date() + 400
        CASE nselect == 2
            @ 12, 10 SAY "Listing Job Cards by Start Date" COLOR "R+"
            dStartDate := Date() -10
            @ 14, 15 SAY "Start Date From" GET dStartDate PICTURE "99/99/9999"
            dEndDate   := Date() + 10
            @ 15, 23 SAY "To Date"         GET dEndDate   PICTURE "99/99/9999"
            READ
        CASE nselect == 3
            @ 12, 10 SAY "Listing Job Cards by Due Date" COLOR "R+"
            dDueDate := Date() -10
            @ 14, 15 SAY "Start Date From" GET dDueDate    PICTURE "99/99/9999"
            dDueEndDate := Date() + 10
            @ 15, 23 SAY "To Date"         GET dDueEndDate PICTURE "99/99/9999"
            READ
        CASE nselect == 4
            @ 12, 10 SAY "Listing Job Cards by Production" COLOR "R+"
            // **       dDueDate := DATE()-10
            // **       @ 14,15 SAY "Start Date From" GET dDueDate    PICTURE "99/99/9999"
            // **       dDueEndDate := DATE()+10
            // **       @ 15,23 SAY "To Date"         GET dDueEndDate PICTURE "99/99/9999"
            // **        READ
            Progress()
            LOOP
        ENDCASE
        mprogress := ApGetN( "Do You Want Progress Listing" )
        madmin    := "N"
        // ** ApGetN( "Do You Want Admin Listing" )
        cbranchid := Space( 2 )
        mok := "N"
        mdateok  := "N"
        mselect  := "N"
        mDueDate := "N"
        mwhere   := "S"
        npn      := 1

        Printsel( mwhere )

        IF mwhere == "P"
            npl := 56
            @  0, 0
            SET DEVICE TO PRINT
        ELSE
            Scroll()
            npl := 23
        ENDIF
        @  0, 0 SAY Control->U_Name
        @  0, 46 SAY Time()
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @  0, 74 SAY npn PICTURE "999"
        npn++
        @  2, 42 SAY "Start Date"
        @  2, 54 SAY "Due Date    Labour  JC-"
        nl := 3
        mgtotal := nlabtotal := ntottime := 0
        SELECT Quot
        SET ORDER TO 1               // Codeno
        GOTO TOP
        mcodeno := Space( 8 )
        IF Quot->Codeno = "A "
            SKIP ALIAS Quot
            SELECT Name
            SEEK Quot->Codeno
            @ nl, 1 SAY Name->Name
            nl++
            mcodeno := Quot->Codeno
        ENDIF
        DO WHILE Quot->( !Eof() )
            SELECT Debit
            SET ORDER TO 2                      // Invno
            SEEK Quot->Invno
            SELECT Quot
            IF Debit->StartDate < dStartDate
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF Debit->StartDate > dEndDate
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF Debit->DueDate < dDueDate
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF Debit->DueDate > dDueEndDate
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF nl > npl
                nl := 3
                IF mwhere == "P"
                    EJECT
                    @  0, 0 SAY Control->U_Name
                    @  0, 46 SAY Time()
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  0, 74 SAY npn PICTURE "999"
                    npn++
                    @  2, 42 SAY "Start Date"
                    @  2, 54 SAY "Due Date    Labour  JC-"
                ELSE
                    WAIT
                    Scroll()
                ENDIF
            ENDIF
            SELECT Quot
            IF Quot->Codeno != mcodeno          // New Codeno
                SELECT Name
                SEEK Quot->Codeno
                nl++
                @ nl, 1 SAY Name->Name
                nl++
                mcodeno := Quot->Codeno
            ENDIF                   // mcodeno
            SELECT Quot
            mpartnum := Quot->Partnum
            IF mpartnum != Space( 20 )
                SELECT Part
                SET ORDER TO 1                       // Partnum
                SEEK mpartnum
                SELECT Debit
                SET ORDER TO 2                      // Invno
                SEEK Quot->Invno
                SET ORDER TO 1
                SELECT Quot
                nLabQty := 0
                nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
                nqty1 := nqty2 := nqty3 := nqty4 := 0
                nequ1 := nequ2 := nequ3 := nequ4 := 0
                nquot := Quot->Qty
                mmod1 := Trim( Quot->Partnum )
                // ***** /*
                SELECT Equ
                SET EXACT ON
                GOTO TOP
                nrecno1 := RecNo()
                SEEK mmod1
                IF Found()
                    nrecno1 := RecNo()
                    DO WHILE  Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
                        nqty1 := Equ->PartQty
                        nequ1 := nqty1 * nquot
                        IF Equ->Partnum = Message->LabPart
                            nLabQty += nequ1
                        ENDIF
                        IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                            SKIP ALIAS Equ
                            LOOP
                        ENDIF
                        mmod2   := Trim( Equ->Partnum )
                        nrecno2 := RecNo()
                        GOTO TOP
                        SEEK mmod2
                        IF Found()
                            DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                                nqty2 := Equ->PartQty
                                nequ2 := ( nqty1 * nqty2 ) * nquot
                                IF Equ->Partnum = Message->LabPart
                                    nLabQty += nequ2
                                ENDIF
                                IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                    SKIP ALIAS Equ
                                    LOOP
                                ENDIF
                                mmod3   := Trim( Equ->Partnum )
                                nrecno3 := RecNo()
                                GOTO TOP
                                SEEK mmod3
                                IF Found()
                                    DO WHILE  Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                        nqty3 := Equ->PartQty
                                        nequ3 := nqty1 * nqty2 * nqty3 * nquot
                                        IF Equ->Partnum = Message->LabPart
                                            nLabQty += nequ3
                                        ENDIF
                                        IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                            SKIP ALIAS Equ
                                            LOOP
                                        ENDIF
                                        mmod4   := Trim( Equ->Partnum )
                                        nrecno4 := RecNo()
                                        nqty4   := 0
                                        GOTO TOP
                                        SEEK mmod4
                                        IF Found()
                                            DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                                nqty4 := Equ->PartQty
                                                nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
                                                IF Equ->Partnum = Message->LabPart
                                                    nLabQty += nequ4
                                                ENDIF
                                                IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                                    SKIP ALIAS Equ
                                                    LOOP
                                                ENDIF
                                                SKIP ALIAS Equ
                                            ENDDO                       // mmod4
                                        ENDIF
                                        SELECT Equ
                                        GOTO nrecno4
                                        SKIP ALIAS Equ
                                    ENDDO                       // mmod3
                                ENDIF                          // FOUND()  mmod3
                                SELECT Equ
                                GOTO nrecno3
                                SKIP ALIAS Equ
                            ENDDO                       // mmod2
                        ENDIF                          // FOUND()  mmod2
                        SELECT Equ
                        GOTO nrecno2
                        SKIP ALIAS Equ
                    ENDDO                       // mmod1
                ENDIF                          // FOUND()  mmod1
                SET EXACT OFF
                // ** */
                nLabTotal += nLabQty
                @ nl, 0 SAY Quot->Qty PICTURE "99999.99"
                @ nl, 9 SAY SubStr( Part->Desc, 1, 30 )
                @ nl, 41 SAY Debit->StartDate
                @ nl, 52 SAY Debit->DueDate
                @ nl, 63 SAY nLabQty PICTURE "99999.99"
                @ nl, 72 SAY Quot->Invno
                IF Debit->StartDate < Date()
                    @ nl, 79 SAY "*"
                ENDIF
                nl++
                IF Debit->Fault != "         "
                    @ nl, 10 SAY Debit->Fault
                    nl++
                ENDIF
                ntime := 0
                SELECT Labour
                SET ORDER TO 2        // Invno+Partnum
                SEEK Debit->Invno
                IF Found()
                    DO WHILE Labour->Invno = Debit->Invno .AND. Labour->( !Eof() )
                        IF Labour->Partnum != Space( 20 )
                            SKIP ALIAS Labour
                            LOOP
                        ENDIF
                        ntime    += Labour->Time
                        ntottime += Labour->Time
                        SKIP ALIAS Labour
                    ENDDO
                ENDIF             // Found Invno
                @ nl, 0 SAY Debit->Invno
                @ nl, 10 SAY Debit->Operno
                // **       @ nl,25 SAY Debit->Saleno
                @ nl, 49 SAY "Time to Date"
                IF ntime > nlabQty
                    @ nl, 62 SAY "#"
                ENDIF
                @ nl, 63 SAY ntime PICTURE "99999.99"
                nl++
                IF Quot->Info != "            "
                    @ nl, 04 SAY Quot->Info
                    nl++
                ENDIF
                IF Quot->Info2 != "            "
                    @ nl, 04 SAY Quot->Info2
                    nl++
                ENDIF
                IF Quot->Info3 != "            "
                    @ nl, 04 SAY Quot->Info3
                    nl++
                ENDIF
                IF Quot->Info4 != "            "
                    @ nl, 04 SAY Quot->Info4
                    nl++
                ENDIF
            /*
            IF madmin = "Y"
               SELECT Admin
               SEEK Debit->Operno
               DO WHILE Admin->Adminno = Debit->Operno .AND. Admin->( !EOF() )
                  @ nl,16 SAY Admin->Desc+"  _________________"
                  nl++
                  SKIP ALIAS Admin
               ENDDO
            ENDIF            // Admin
            */
                IF nl > npl
                    nl := 2
                    IF mwhere == "P"
                        EJECT
                        @ 0, 0 SAY Control->U_Name
                        @ 0, 48 SAY Time()
                        @ 0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                        nl++
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF                      // mwhere
                ENDIF                        // npl
                IF mprogress = "Y"
                    // **************************************************
                    coperno := Debit->Operno
                    // **            SELECT Quot
                    // **            SET ORDER TO 3        // Invno + Partnum
                    // **            SEEK Debit->Invno
                    SELECT Progress
                    GOTO TOP
                    SEEK coperno
                    @ nl, 1 SAY Progress->DescProg
                    IF Quot->Prog01 = Space( 12 )
                        @ nl, 14 SAY "____________"
                    ELSE
                        @ nl, 14 SAY Quot->Prog01
                    ENDIF
                    SKIP ALIAS Progress
                    @ nl, 27 SAY Progress->DescProg
                    IF Quot->Prog02 = Space( 12 )
                        @ nl, 40 SAY "____________"
                    ELSE
                        @ nl, 40 SAY Quot->Prog02
                    ENDIF
                    SKIP ALIAS Progress
                    @ nl, 53 SAY Progress->DescProg
                    IF Quot->Prog03 = Space( 12 )
                        @ nl, 66 SAY "____________"
                    ELSE
                        @ nl, 66 SAY Quot->Prog03
                    ENDIF
                    nl++
                    SKIP ALIAS Progress
                    @ nl, 1 SAY Progress->DescProg
                    IF Quot->Prog04 = Space( 12 )
                        @ nl, 14 SAY "____________"
                    ELSE
                        @ nl, 14 SAY Quot->Prog04
                    ENDIF
                    SKIP ALIAS Progress
                    @ nl, 27 SAY Progress->DescProg
                    IF Quot->Prog05 = Space( 12 )
                        @ nl, 40 SAY "____________"
                    ELSE
                        @ nl, 40 SAY Quot->Prog05
                    ENDIF
                    SKIP ALIAS Progress
                    @ nl, 53 SAY Progress->DescProg
                    IF Quot->Prog06 = Space( 12 )
                        @ nl, 66 SAY "____________"
                    ELSE
                        @ nl, 66 SAY Quot->Prog06
                    ENDIF
                    nl++
                    SKIP ALIAS Progress
                    @ nl, 1 SAY Progress->Desc
                    IF Quot->Prog07 = Space( 12 )
                        @ nl, 14 SAY "____________"
                    ELSE
                        @ nl, 14 SAY Quot->Prog07
                    ENDIF
                    SKIP ALIAS Progress
                    @ nl, 27 SAY Progress->DescProg
                    IF Quot->Prog08 = Space( 12 )
                        @ nl, 40 SAY "____________"
                    ELSE
                        @ nl, 40 SAY Quot->Prog08
                    ENDIF
                    SKIP ALIAS Progress
                    @ nl, 53 SAY Progress->DescProg
                    IF Quot->Prog09 = Space( 12 )
                        @ nl, 66 SAY "____________"
                    ELSE
                        @ nl, 66 SAY Quot->Prog09
                    ENDIF
                    nl++
                    SKIP ALIAS Progress
                    @ nl, 1 SAY Progress->DescProg
                    IF Quot->Prog10 = Space( 12 )
                        @ nl, 14 SAY "____________"
                    ELSE
                        @ nl, 14 SAY Quot->Prog10
                    ENDIF
                    SKIP ALIAS Progress
                    @ nl, 27 SAY Progress->DescProg
                    IF Quot->Prog11 = Space( 12 )
                        @ nl, 40 SAY "____________"
                    ELSE
                        @ nl, 40 SAY Quot->Prog11
                    ENDIF
                    SKIP ALIAS Progress
                    @ nl, 53 SAY Progress->DescProg
                    IF Quot->Prog12 = Space( 12 )
                        @ nl, 66 SAY "____________"
                    ELSE
                        @ nl, 66 SAY Quot->Prog12
                    ENDIF
                    nl++
                    SKIP ALIAS Progress
                    @ nl, 1 SAY Progress->DescProg
                    IF Quot->Prog13 = Space( 12 )
                        @ nl, 14 SAY "____________"
                    ELSE
                        @ nl, 14 SAY Quot->Prog13
                    ENDIF
                    SKIP ALIAS Progress
                    @ nl, 27 SAY Progress->DescProg
                    IF Quot->Prog14 = Space( 12 )
                        @ nl, 40 SAY "____________"
                    ELSE
                        @ nl, 40 SAY Quot->Prog14
                    ENDIF
                    SKIP ALIAS Progress
                    @ nl, 53 SAY Progress->DescProg
                    IF Quot->Prog15 = Space( 12 )
                        @ nl, 66 SAY "____________"
                    ELSE
                        @ nl, 66 SAY Quot->Prog15
                    ENDIF
                    nl++
                    SKIP ALIAS Progress
                    @ nl, 1 SAY Progress->DescProg
                    IF Quot->Prog16 = Space( 12 )
                        @ nl, 14 SAY "____________"
                    ELSE
                        @ nl, 14 SAY Quot->Prog16
                    ENDIF
                    SKIP ALIAS Progress
                    @ nl, 27 SAY Progress->DescProg
                    IF Quot->Prog17 = Space( 12 )
                        @ nl, 40 SAY "____________"
                    ELSE
                        @ nl, 40 SAY Quot->Prog17
                    ENDIF
                    SKIP ALIAS Progress
                    @ nl, 53 SAY Progress->DescProg
                    IF Quot->Prog18 = Space( 12 )
                        @ nl, 66 SAY "____________"
                    ELSE
                        @ nl, 66 SAY Quot->Prog18
                    ENDIF
                    nl++
                ENDIF                         // Progress
                // **************************************************
                mgtotal += Quot->Amount * Quot->Qty
            ENDIF                        // mpartnum
            SELECT Quot
            SKIP ALIAS Quot
            // ***   mcodeno := Quot->Codeno
        ENDDO                           // EOF()
        nl += 2
        IF nl > npl
            nl := 2
            IF mwhere == "P"
                EJECT
                @ 0, 0 SAY Control->U_Name
                @ 0, 48 SAY Time()
                @ 0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                @  0, 74 SAY npn PICTURE "999"
                npn++
                nl++
            ELSE
                WAIT
                Scroll()
            ENDIF                      // mwhere
        ENDIF                        // npl
        mgtotal := mgtotal - ( mgtotal / 9 )
        @ nl, 6 SAY "No GST Total"
        @ nl, 20 SAY mgtotal PICTURE "$9,999,999.99"
        @ nl, 47 SAY "Total Labour"
        @ nl, 61 SAY nLabTotal PICTURE "999,999.99"
        nl++
        @ nl, 41 SAY "JC- Labour to Date"
        @ nl, 61 SAY ntottime PICTURE "999,999.99"
        nl++
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
        manother := ApGetN( Trim( Message->Another ) + " Listing" )
    ENDDO                       // manother
    SELECT Labour
    SET ORDER TO 1

    RETURN NIL

// *** End of QuotStart()

// ***------------------------------------------------------------------------

FUNCTION QSelectPC()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"

        mcodeno := Space( 8 )
        SELECT QuotOrd
        mtempcode := "A       "
        GOTO TOP
        SEEK mtempcode
        IF !Found()
            ApFLock( 3 )
            APPEND BLANK
            QuotOrd->Codeno := "A      "
            QuotOrd->Invno  := "9     "
            UNLOCK
        ENDIF
        aPart_ := anum := {}
        nrecno := ntotal := 0
        maccepted := "N"
        Scroll()
        DispBox( 0, 45, 4, 75, 2 )
        @  1, 47 SAY "Select Name - Branch"
        @  2, 47 SAY "Branch Specific"
        IF LastRec() = 0
            @ 7, 53 SAY "NO Work Orders"
            Inkey( 2 )
            RETURN NIL
        ENDIF
        SELECT QuotOrd
        IF LastRec() != 0
            GOTO TOP
            mtempno := Space( 10 )
            DO WHILE QuotOrd->( !Eof() )
                ntotal += ( Quot->Amount * Quot->Qty )
                IF QuotOrd->Codeno + QuotOrd->BranchId = mtempno
                    SKIP ALIAS QuotOrd
                    LOOP
                ENDIF
                SELECT Name
                SEEK QuotOrd->Codeno
                SELECT QuotOrd
                mtempno := QuotOrd->Codeno + QuotOrd->BranchId
                AAdd( aPart_, Name->Name + "  " + QuotOrd->BranchId;
                    + "            " + Str( RecNo(), 6 ) )
                SKIP ALIAS QuotOrd
            ENDDO
            DispBox( 0, 1, 24, 42, 2 )
            @ 24, 45 SAY Trim( Message->Select )
            @ 12, 47 SAY "F2 To View ALL Orders" COLOR "GB+"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 1, 3, 23, 40, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                mcodeno := QuotOrd->Codeno
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                IF LastKey() == -1
                    SELECT QuotOrd
                    GOTO TOP
                    IF LastRec() != 0
                        aPart_ := {}
                        DO WHILE QuotOrd->( !Eof() )
                            AAdd( aPart_, SubStr( QuotOrd->Partnum, 1,12 );
                                + " " + QuotOrd->Codeno;
                                + " " + DToC( QuotOrd->Dbdate );
                                + " " + Str( QuotOrd->OrgQty, 7, 0 );
                                + " " + Str( QuotOrd->Qty, 7, 0 );
                                + " " + Str( QuotOrd->GoodSent, 7, 0 );
                                + " " + Str( QuotOrd->Amount, 8, 2 );
                                + " " + QuotOrd->Faxno;
                                + "           " + Str( RecNo(), 6 ) )
                            SKIP ALIAS QuotOrd
                        ENDDO
                        IF !Empty( aPart_ )
                            Scroll()
                            DispBox(  0, 1, 24, 79, 2 )
                            @  0, 32 SAY " Order  Out  Inv "
                            ASort( aPart_,,, {| x, y | x < y } )
                            anum   := AChoice(  1, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
                            nrecno := Val( Right( aPart_[ anum ], 6 ) )
                            GOTO nrecno
                            mcodeno := QuotOrd->Codeno
                        ENDIF                     // Empty
                    ENDIF                        // LastRec
                ENDIF                 // LastKey = -1
            ENDIF
        ENDIF           // Last Rec
        Scroll()
        @  6, 15 SAY "Listing Work Orders"

        mwhere := "S"

        Printsel( mwhere )                    // _LF_Init

        IF mwhere = "P"
            npl := 54
        ELSE
            npl := 22
        ENDIF
        nl := 2
        mok := "N"
        SELECT Name
        SEEK mcodeno
        @  nl, 1 SAY Name->Name
        @  nl, 46 SAY Time()
        @  nl, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl++
        nl++
        mgtotal := 0
        SELECT QuotOrd
        GOTO TOP
        SEEK mcodeno
        DO WHILE QuotOrd->Codeno = mcodeno .AND. QuotOrd->( !Eof() )
            IF nl > npl
                IF mwhere = "S"
                    Inkey( 0 )
                    Scroll()
                ELSE
                    EJECT
                ENDIF
                nl := 2
                @  nl, 1 SAY Name->Name
                @  nl, 46 SAY Time()
                @  nl, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                nl++
                nl++
            ENDIF
            mpartnum := QuotOrd->Partnum
            SELECT Part
            SEEK mpartnum
            SELECT QuotOrd
            @ nl, 0 SAY QuotOrd->DbDate
            @ nl, 10 SAY QuotOrd->Qty PICTURE "99999.99"
            @ nl, 19 SAY SubStr( Part->Desc, 1, 36 )
            @ nl, 57 SAY Part->ABC
            @ nl, 59 SAY SubStr( QuotOrd->Ordnum, 1, 10 )
            IF QuotOrd->Invno != Space( 6 )
                @ nl, 70 SAY QuotOrd->Invno
                @ nl, 78 SAY QuotOrd->BranchId
            ELSE
                @ nl, 70 SAY QuotOrd->Faxno
            ENDIF
            nl++
            IF QuotOrd->Info  != Space( 45 )
                @ nl, 16 SAY QuotOrd->Info
                nl++
            ENDIF
            IF QuotOrd->Info2 != Space( 45 )
                @ nl, 16 SAY QuotOrd->Info2
                nl++
            ENDIF
            IF QuotOrd->Info3 != Space( 45 )
                @ nl, 16 SAY QuotOrd->Info3
                nl++
            ENDIF
            IF QuotOrd->Info4 != Space( 45 )
                @ nl, 16 SAY QuotOrd->Info4
                nl++
            ENDIF
            IF QuotOrd->Info5 != Space( 45 )
                @ nl, 16 SAY QuotOrd->Info5
                nl++
            ENDIF
            IF QuotOrd->Info6 != Space( 45 )
                @ nl, 16 SAY QuotOrd->Info6
                nl++
            ENDIF
            IF QuotOrd->Info7 != Space( 45 )
                @ nl, 16 SAY QuotOrd->Info7
                nl++
            ENDIF
            IF QuotOrd->Info8 != Space( 45 )
                @ nl, 16 SAY QuotOrd->Info8
                nl++
            ENDIF
            IF QuotOrd->Info9 != Space( 45 )
                @ nl, 16 SAY QuotOrd->Info9
                nl++
            ENDIF
            SELECT QuotOrd
            SKIP ALIAS QuotOrd
        ENDDO                           // EOF()
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
        mcontinue := ApGetN( Trim( Message->Another ) + " List " )

    ENDDO                    // mcontinue

    RETURN NIL
// ***---- End of QSelectPC()

// ---------------------------------------------------------------------*

FUNCTION QuotListPC()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"

        Scroll()
        @  6, 15 SAY "Listing Work Orders"

        mwhere := "S"

        Printsel( mwhere )                    // _LF_Init

        IF mwhere = "P"
            npl := 54
        ELSE
            npl := 22
        ENDIF
        nl := 4
        mcodeno   := Space( 8 )
        cbranchid := Space( 2 )
        mok := "N"
        @  0, 46 SAY Time()
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl := 2
        SELECT QuotOrd
        GOTO TOP
        mcodeno := QuotOrd->Codeno
        SELECT Name
        SEEK mcodeno
        @ nl, 1 SAY Name->Name
        nl++
        mgtotal := 0
        SELECT QuotOrd
        DO WHILE QuotOrd->( !Eof() )
            IF nl > npl
                IF mwhere = "S"
                    Inkey( 0 )
                    Scroll()
                ELSE
                    EJECT
                ENDIF
                @  0, 46 SAY Time()
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                nl := 2
            ENDIF
            IF QuotOrd->Codeno != mcodeno          // New Codeno
                SELECT Name
                SEEK QuotOrd->Codeno
                mcodeno := QuotOrd->Codeno
                nl++
                @ nl, 1 SAY Name->Name
                nl++
            ENDIF
            SELECT QuotOrd
            mpartnum := QuotOrd->Partnum
            SELECT Part
            SEEK mpartnum
            SELECT QuotOrd
            @ nl, 0 SAY QuotOrd->DbDate
            @ nl, 10 SAY QuotOrd->Qty PICTURE "99999.99"
            @ nl, 19 SAY SubStr( Part->Desc, 1, 36 )
            @ nl, 57 SAY Part->ABC
            @ nl, 59 SAY SubStr( QuotOrd->Ordnum, 1, 10 )
            IF QuotOrd->Invno != Space( 6 )
                @ nl, 70 SAY QuotOrd->Invno
                @ nl, 78 SAY QuotOrd->BranchId
                // **           ELSE
                // **             @ nl,70 SAY QuotOrd->Faxno
            ENDIF
            nl++
/*
Temp Taken out
          IF QuotOrd->Info  != SPACE( 45 )
             @ nl,16 SAY QuotOrd->Info
             nl++
          ENDIF
          IF QuotOrd->Info2 != SPACE( 45 )
             @ nl,16 SAY QuotOrd->Info2
             nl++
          ENDIF
          IF QuotOrd->Info3 != SPACE( 45 )
             @ nl,16 SAY QuotOrd->Info3
             nl++
          ENDIF
          IF QuotOrd->Info4 != SPACE( 45 )
             @ nl,16 SAY QuotOrd->Info4
             nl++
          ENDIF
          IF QuotOrd->Info5 != SPACE( 45 )
             @ nl,16 SAY QuotOrd->Info5
             nl++
          ENDIF
          IF QuotOrd->Info6 != SPACE( 45 )
             @ nl,16 SAY QuotOrd->Info6
             nl++
          ENDIF
          IF QuotOrd->Info7 != SPACE( 45 )
             @ nl,16 SAY QuotOrd->Info7
             nl++
          ENDIF
          IF QuotOrd->Info8 != SPACE( 45 )
             @ nl,16 SAY QuotOrd->Info8
             nl++
          ENDIF
          IF QuotOrd->Info9 != SPACE( 45 )
             @ nl,16 SAY QuotOrd->Info9
             nl++
          ENDIF
*/
            SELECT QuotOrd
            SKIP ALIAS QuotOrd
        ENDDO                           // EOF()
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
        mcontinue := ApGetN( Trim( Message->Another ) + " List " )

    ENDDO                    // mcontinue

    RETURN NIL
// *** End of QuotlistPC()

// ****----------------------------------------------------------------

FUNCTION QuotOrdCP()

    Scroll()
    dstmm    := Date() -30
    dendmm   := Date()
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        DispBox( 6, 1, 12, 79, 2 )
        @  8, 10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
        @ 10, 10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        mmemo := "N"
        mpartnum := Space( 20 )

        mwhere := "S"

        Printsel( mwhere )                    // _LF_Init

        IF mwhere = "P"
            npl := 54
        ELSE
            npl := 22
        ENDIF
        nl := 4
        Scroll()
        @  0, 1 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @  0, 18 SAY "From " + DToC( dstmm )
        @  0, 34 SAY "To "   + DToC( dendmm )
        @  0, 56 SAY "Ordered"
        nl := 2
        aPart_ := {}
        SELECT QuotOrd
        SET ORDER TO 1
        GOTO TOP
        IF LastRec() != 0
            DO WHILE QuotOrd->( !Eof() )
                IF QuotOrd->DBDate < dstmm
                    SKIP ALIAS QuotOrd
                    LOOP
                ENDIF
                IF QuotOrd->DBDate > dendmm
                    SKIP ALIAS QuotOrd
                    LOOP
                ENDIF
                mpartnum := QuotOrd->Partnum
                SELECT Part
                SEEK mpartnum
                ApRLock( 3 )
                mdesc := SubStr( Part->Desc, 1, 25 )
                UNLOCK
                SELECT QuotOrd
                IF nl > npl
                    IF mwhere = "S"
                        Inkey( 0 )
                        Scroll()
                    ELSE
                        EJECT
                    ENDIF
                    @  0, 1 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  0, 18 SAY "From " + DToC( dstmm )
                    @  0, 34 SAY "To "   + DToC( dendmm )
                    @  0, 56 SAY "Ordered"
                    nl := 2
                ENDIF                      // nl
                SELECT QuotOrd
                @ nl, 0 SAY QuotOrd->Codeno
                @ nl, 10 SAY SubStr( QuotOrd->Partnum, 1, 10 )
                @ nl, 21 SAY mdesc
                @ nl, 48 SAY SubStr( QuotOrd->Ordnum, 1, 10 )
                @ nl, 58 SAY QuotOrd->Qty      PICTURE "9999.99"
                @ nl, 69 SAY QuotOrd->DBDate
                nl++
                SKIP ALIAS QuotOrd
            ENDDO                             // EOF
            nl += 2
        ENDIF                    // LastRec Not 0
        IF mwhere == "S"
            Inkey( 0 )
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
            SET MARGIN TO 0
        ENDIF
        mcontinue := ApGetN( Trim( Message->Another ) + " List " )
    ENDDO

    RETURN NIL
// ***---- End of QuotOrdCp()

// ---------------------------------------------------------------------*

FUNCTION Progress()

    cbranchid := Space( 2 )
    mok := "N"
    mdateok  := "N"
    mselect  := "N"
    mDueDate := "N"
    mwhere := "S"

    Printsel( mwhere )

    IF mwhere == "P"
        npl := 56
        @  0, 0
        SET DEVICE TO PRINT
    ELSE
        Scroll()
        npl := 21
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0, 46 SAY Time()
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 42 SAY "Start Date"
    @  2, 54 SAY "Due Date    Labour  JC-"
    nl := 3
    mgtotal := nlabtotal := 0
    SELECT Quot
    SET ORDER TO 1                        // Codeno
    GOTO TOP
    mcodeno := Space( 8 )
    IF Quot->Codeno = "A "
        SKIP ALIAS Quot
        // **      SELECT Name
        // **      SEEK Quot->Codeno
        // **      @ nl, 1 SAY Name->Name
        // **      nl++
        mcodeno := Quot->Codeno
    ENDIF
    DO WHILE Quot->( !Eof() )
        IF Quot->Prog01 + Quot->Prog02 + Quot->Prog03;
                + Quot->Prog04 + Quot->Prog05 + Quot->Prog06;
                + Quot->Prog07 + Quot->Prog08 + Quot->Prog09;
                + Quot->Prog10 + Quot->Prog11 + Quot->Prog12;
                + Quot->Prog13 + Quot->Prog14 + Quot->Prog15;
                + Quot->Prog16 + Quot->Prog17 + Quot->Prog18 = "      "
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF Quot->Prog18 != Space( 12 )
            SKIP ALIAS Quot
            LOOP
        ENDIF
        SELECT Debit
        SET ORDER TO 2                      // Invno
        SEEK Quot->Invno
        SELECT Quot
        IF nl > npl
            nl := 3
            IF mwhere == "P"
                EJECT
                @  0, 0 SAY Control->U_Name
                @  0, 46 SAY Time()
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                @  2, 42 SAY "Start Date"
                @  2, 54 SAY "Due Date    Labour  JC-"
            ELSE
                WAIT
                Scroll()
            ENDIF
        ENDIF
        SELECT Quot
        IF Quot->Codeno != mcodeno          // New Codeno
            SELECT Name
            SEEK Quot->Codeno
            nl++
            @ nl, 1 SAY Name->Name
            nl++
            mcodeno := Quot->Codeno
        ENDIF                   // mcodeno
        SELECT Quot
        mpartnum := Quot->Partnum
        IF mpartnum != Space( 20 )
            SELECT Part
            SET ORDER TO 1                       // Partnum
            SEEK mpartnum
            SELECT Debit
            SET ORDER TO 2                      // Invno
            SEEK Quot->Invno
            SET ORDER TO 1
            SELECT Quot
            nLabQty := 0
            nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
            nqty1 := nqty2 := nqty3 := nqty4 := 0
            nequ1 := nequ2 := nequ3 := nequ4 := 0
            nquot := Quot->Qty
            mmod1 := Trim( Quot->Partnum )
            SELECT Equ
            // **      SET EXACT ON
            GOTO TOP
            nrecno1 := RecNo()
            SEEK mmod1
            IF Found()
                nrecno1 := RecNo()
                DO WHILE  Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
                    nqty1 := Equ->PartQty
                    nequ1 := nqty1 * nquot
                    IF Equ->Partnum = Message->LabPart
                        nLabQty += nequ1
                    ENDIF
                    IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                        SKIP ALIAS Equ
                        LOOP
                    ENDIF
                    mmod2   := Trim( Equ->Partnum )
                    nrecno2 := RecNo()
                    GOTO TOP
                    SEEK mmod2
                    IF Found()
                        DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                            nqty2 := Equ->PartQty
                            nequ2 := ( nqty1 * nqty2 ) * nquot
                            IF Equ->Partnum = Message->LabPart
                                nLabQty += nequ2
                            ENDIF
                            IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                SKIP ALIAS Equ
                                LOOP
                            ENDIF
                            mmod3   := Trim( Equ->Partnum )
                            nrecno3 := RecNo()
                            GOTO TOP
                            SEEK mmod3
                            IF Found()
                                DO WHILE  Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                    nqty3 := Equ->PartQty
                                    nequ3 := nqty1 * nqty2 * nqty3 * nquot
                                    IF Equ->Partnum = Message->LabPart
                                        nLabQty += nequ3
                                    ENDIF
                                    IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                        SKIP ALIAS Equ
                                        LOOP
                                    ENDIF
                                    mmod4   := Trim( Equ->Partnum )
                                    nrecno4 := RecNo()
                                    nqty4   := 0
                                    GOTO TOP
                                    SEEK mmod4
                                    IF Found()
                                        DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                            nqty4 := Equ->PartQty
                                            nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
                                            IF Equ->Partnum = Message->LabPart
                                                nLabQty += nequ4
                                            ENDIF
                                            IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                                SKIP ALIAS Equ
                                                LOOP
                                            ENDIF
                                            SKIP ALIAS Equ
                                        ENDDO                       // mmod4
                                    ENDIF
                                    SELECT Equ
                                    GOTO nrecno4
                                    SKIP ALIAS Equ
                                ENDDO                       // mmod3
                            ENDIF                          // FOUND()  mmod3
                            SELECT Equ
                            GOTO nrecno3
                            SKIP ALIAS Equ
                        ENDDO                       // mmod2
                    ENDIF                          // FOUND()  mmod2
                    SELECT Equ
                    GOTO nrecno2
                    SKIP ALIAS Equ
                ENDDO                       // mmod1
            ENDIF                          // FOUND()  mmod1
            // **       SET EXACT OFF
            @ nl, 0 SAY Quot->Qty PICTURE "99999.99"
            @ nl, 9 SAY SubStr( Part->Desc, 1, 30 )
            @ nl, 41 SAY Debit->StartDate
            @ nl, 52 SAY Debit->DueDate
            @ nl, 63 SAY nLabQty PICTURE "9999.99"
            nLabTotal += nLabQty
            @ nl, 72 SAY Quot->Invno
            IF Debit->StartDate < Date()
                @ nl, 79 SAY "*"
            ENDIF
            nl++
            IF Debit->Fault != "         "
                @ nl, 10 SAY Debit->Fault
                nl++
            ENDIF
            @ nl, 6 SAY Debit->Operno
            SELECT Admin
            SEEK Debit->Operno
            DO WHILE Admin->Adminno = Debit->Operno .AND. Admin->( !Eof() )
                @ nl, 16 SAY Admin->Desc + "  _________________"
                nl++
                SKIP ALIAS Admin
            ENDDO
            coperno := Debit->Operno
            // **             SELECT Quot
            // **             SET ORDER TO 3        // Invno + Partnum
            // **             SEEK Debit->Invno
            SELECT Progress
            GOTO TOP
            SEEK coperno
            @ nl, 1 SAY Progress->DescProg
            IF Quot->Prog01 = Space( 12 )
                @ nl, 14 SAY "____________"
            ELSE
                @ nl, 14 SAY Quot->Prog01
            ENDIF
            SKIP ALIAS Progress
            @ nl, 27 SAY Progress->DescProg
            IF Quot->Prog02 = Space( 12 )
                @ nl, 40 SAY "____________"
            ELSE
                @ nl, 40 SAY Quot->Prog02
            ENDIF
            SKIP ALIAS Progress
            @ nl, 53 SAY Progress->DescProg
            IF Quot->Prog03 = Space( 12 )
                @ nl, 66 SAY "____________"
            ELSE
                @ nl, 66 SAY Quot->Prog03
            ENDIF
            nl++
            SKIP ALIAS Progress
            @ nl, 1 SAY Progress->DescProg
            IF Quot->Prog04 = Space( 12 )
                @ nl, 14 SAY "____________"
            ELSE
                @ nl, 14 SAY Quot->Prog04
            ENDIF
            SKIP ALIAS Progress
            @ nl, 27 SAY Progress->DescProg
            IF Quot->Prog05 = Space( 12 )
                @ nl, 40 SAY "____________"
            ELSE
                @ nl, 40 SAY Quot->Prog05
            ENDIF
            SKIP ALIAS Progress
            @ nl, 53 SAY Progress->DescProg
            IF Quot->Prog06 = Space( 12 )
                @ nl, 66 SAY "____________"
            ELSE
                @ nl, 66 SAY Quot->Prog06
            ENDIF
            nl++
            SKIP ALIAS Progress
            @ nl, 1 SAY Progress->DescProg
            IF Quot->Prog07 = Space( 12 )
                @ nl, 14 SAY "____________"
            ELSE
                @ nl, 14 SAY Quot->Prog07
            ENDIF
            SKIP ALIAS Progress
            @ nl, 27 SAY Progress->DescProg
            IF Quot->Prog08 = Space( 12 )
                @ nl, 40 SAY "____________"
            ELSE
                @ nl, 40 SAY Quot->Prog08
            ENDIF
            SKIP ALIAS Progress
            @ nl, 53 SAY Progress->DescProg
            IF Quot->Prog09 = Space( 12 )
                @ nl, 66 SAY "____________"
            ELSE
                @ nl, 66 SAY Quot->Prog09
            ENDIF
            nl++
            SKIP ALIAS Progress
            @ nl, 1 SAY Progress->DescProg
            IF Quot->Prog10 = Space( 12 )
                @ nl, 14 SAY "____________"
            ELSE
                @ nl, 14 SAY Quot->Prog10
            ENDIF
            SKIP ALIAS Progress
            @ nl, 27 SAY Progress->DescProg
            IF Quot->Prog11 = Space( 12 )
                @ nl, 40 SAY "____________"
            ELSE
                @ nl, 40 SAY Quot->Prog11
            ENDIF
            SKIP ALIAS Progress
            @ nl, 53 SAY Progress->DescProg
            IF Quot->Prog12 = Space( 12 )
                @ nl, 66 SAY "____________"
            ELSE
                @ nl, 66 SAY Quot->Prog12
            ENDIF
            nl++
            SKIP ALIAS Progress
            @ nl, 1 SAY Progress->DescProg
            IF Quot->Prog13 = Space( 12 )
                @ nl, 14 SAY "____________"
            ELSE
                @ nl, 14 SAY Quot->Prog13
            ENDIF
            SKIP ALIAS Progress
            @ nl, 27 SAY Progress->DescProg
            IF Quot->Prog14 = Space( 12 )
                @ nl, 40 SAY "____________"
            ELSE
                @ nl, 40 SAY Quot->Prog14
            ENDIF
            SKIP ALIAS Progress
            @ nl, 53 SAY Progress->DescProg
            IF Quot->Prog15 = Space( 12 )
                @ nl, 66 SAY "____________"
            ELSE
                @ nl, 66 SAY Quot->Prog15
            ENDIF
            nl++
            SKIP ALIAS Progress
            @ nl, 1 SAY Progress->DescProg
            IF Quot->Prog16 = Space( 12 )
                @ nl, 14 SAY "____________"
            ELSE
                @ nl, 14 SAY Quot->Prog16
            ENDIF
            SKIP ALIAS Progress
            @ nl, 27 SAY Progress->DescProg
            IF Quot->Prog17 = Space( 12 )
                @ nl, 40 SAY "____________"
            ELSE
                @ nl, 40 SAY Quot->Prog17
            ENDIF
            SKIP ALIAS Progress
            @ nl, 53 SAY Progress->DescProg
            IF Quot->Prog18 = Space( 12 )
                @ nl, 66 SAY "____________"
            ELSE
                @ nl, 66 SAY Quot->Prog18
            ENDIF
            nl++
            mgtotal += Quot->Amount * Quot->Qty
        ENDIF                        // mpartnum
        SELECT Quot
        SKIP ALIAS Quot
        // ***   mcodeno := Quot->Codeno
    ENDDO                           // EOF()
    nl++
    mgtotal := mgtotal - ( mgtotal / 9 )
    // ** @ nl, 6 SAY "No GST Total"
    // ** @ nl,20 SAY mgtotal PICTURE "$9,999,999.99"
    // ** @ nl,47 SAY "Total Labour"
    // ** @ nl,61 SAY nLabTotal PICTURE "999,999.99"
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

    // ***-------------- End Progress

    // ***---------------------------------------------------------

FUNCTION QuotParts()

    Scroll()
    DispBox( 4, 1, 14, 79, 2 )
    @  5, 10 SAY "Listing Parts in Quotations"
    mok := "N"
    manother := "Y"
    DO WHILE manother = "Y"

        QuotFind()                   // XLF_QU7

        minvno := Debit->Invno

        mselect := cbuyonly := "N"
        mequ := "Y"
        mCut := ApGetN( "Y = Material Cutting Only" )
        // ** ApGetY( "Do You want Purchase Parts" )
        // **   IF mequ == "Y"
        // **      mselect := ApGetN( "Y = Parts NOT in Stock ONLY" )
        cbuyonly := "Y"
        // ** ApGetY( "Y = Parts BOUGHT Out ONLY"   )
        // **   ENDIF

        Printsel( mwhere )

        IF mwhere == "P"
            npl := 54
            @  0, 0
            SET DEVICE TO PRINT
        ELSE
            Scroll()
            npl := 22
        ENDIF
        @ 0, 0 SAY Control->U_Name
        @ 0, 48 SAY Time()
        @ 0, 58 SAY Str( Day(  Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl := 2
        IF minvno != Space( 6 )
            @ nl, 2 SAY Debit->Invno + " " + Debit->Codeno + " " + Debit->Est
            nl += 2
        ENDIF                    // minvno
        mcodeno := Debit->Codeno
        SELECT Quot
        GOTO TOP
        DO WHILE Quot->( !Eof() )
            IF Quot->Invno != minvno
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF SubStr( Quot->Invno, 1, 1 ) = " " // Blank Invoice in Quot
                SKIP ALIAS Quot
                LOOP
            ENDIF
            IF Quot->Qty = 0
                SKIP ALIAS Quot
                LOOP
            ENDIF
            SELECT Part
            SET ORDER TO 1                   // Partnum
            SEEK Quot->Partnum
            SELECT Quot
            @ nl, 0 SAY Quot->Qty PICTURE "99,999.999"
            @ nl, 12 SAY SubStr( Part->Desc, 1, 37 );
                + "  " + SubStr( Part->Partnum, 1, 16 )
            nl++
            msum := 0

            IF nl > npl
                nl := 2
                IF mwhere == "P"
                    EJECT
                    @ 0, 0 SAY Control->U_Name
                    @ 0, 48 SAY Time()
                    @ 0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    nl++
                ELSE
                    WAIT
                    Scroll( 2, 0, 24, 80 )
                ENDIF                      // mwhere
            ENDIF                        // npl
            mtotal := nbuy := 0
            mpartnum := Quot->Partnum
            SELECT Part
            SET ORDER TO 1                   // Partnum
            nl++
            // ** IF mCut = "N"
            @ nl, 0 SAY "Parts Required by Module"
            // **   @ nl,48 SAY TIME()
            // **   @ nl,58 SAY STR( DAY( DATE() ),3 )+" "+CMONTH( DATE() );
            // **              +STR( YEAR( DATE() ),5 )
            nl++
            msum := nbuy := ninstock := 0
            SELECT QuotStk
            GOTO TOP
            DO WHILE QuotStk->( !Eof() )
                IF nl > npl
                    IF mwhere == "P"
                        EJECT
                        @ 0, 0 SAY Control->U_Name
                        @ 0, 50 SAY Time()
                        @ 0, 62 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                    ELSE
                        WAIT
                        Scroll( 3, 0, 24, 80 )
                    ENDIF
                    nl := 3
                ENDIF
                IF QuotStk->Required <= 0
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF                              // Part instock
                IF QuotStk->Invno != minvno
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF                              // Part instock
                SELECT Part
                SET ORDER TO 1
                SEEK QuotStk->Partnum
                SELECT QuotStk
      /*
      IF mselect == "Y"
         IF Part->Instock > Part->QuotQty
            SKIP ALIAS Part
            LOOP
         ENDIF                              // Part instock
      ENDIF                                 // mselect
      IF cbuyonly == "Y"
         IF Part->Boughtout != "Y"
            SKIP ALIAS Part
            LOOP
         ENDIF                              // Part BoughtOut
      ENDIF                                 // cbuyonly
      */
                nQty := 0
                mpartnum := Part->Partnum
                // **      SEEK mpartnum
                DO WHILE QuotStk->Partnum = mpartnum .AND. QuotStk->( !Eof() )
                    IF QuotStk->Required <= 0
                        SKIP ALIAS QuotStk
                        LOOP
                    ENDIF                              // Part instock
                    IF QuotStk->Invno != minvno
                        SKIP ALIAS QuotStk
                        LOOP
                    ENDIF                              // Part instock
                    nQty += QuotStk->Required
                    // ** -QuotStk->Received
                    SKIP ALIAS QuotStk
                ENDDO                              // QuotStk
                // **     SELECT Part
                // **      ApRLock( 3 )
                // **     Part->ReqQty := nQty
                // **     UNLOCK
                IF nQty = 0
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF
                nl++
                @ nl, 0 SAY nQty PICTURE "99999.999"
                @ nl, 10 SAY SubStr( Part->Unit, 1, 6 )
                @ nl, 17 SAY SubStr( Part->Desc, 1, 34 )
                @ nl, 52 SAY SubStr( mpartnum, 1, 16 )
                @ nl, 70 SAY Part->Codeno
                SELECT QuotStk
            ENDDO                                     // EOF QuotStk
            SELECT Quot
            SKIP ALIAS Quot
        ENDDO
        // ** ENDIF                       // mCut
        IF mwhere = "P"
            @ nl, 0 SAY " "
            EndPrint()
            SET MARGIN TO 0
        ELSE
            IF nl > 18
                WAIT
            ENDIF
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ENDIF
        // **      manother := "N"
        // ** ENDDO                       // manother


        IF mcut = "Y"
            QuotCut( @mcodeno )                  // XLF_QU3
        ENDIF
        IF mok == "Y"
            SELECT Control
            ApRlock( 3 )
            Control->EntLev1 := Space( 6 )
            UNLOCK
        ENDIF
        manother := "N"
        // ** ApGetN( Message->another )

    ENDDO                           // manother

    RETURN NIL

// *** End of QuotParts()

// **----------------------------------------------------------------------------

FUNCTION QuotDesc()

    Scroll()
    @ 10, 15 SAY "Listing Production Parts in Work Orders by Desc"
    mwhere := ApGetN( "Do You Want Printer" )
    IF mwhere = "Y"
        SET PRINTER ON
        ? Control->U_Name + "  " + Time() + " " + Str( Day(  Date() ), 3 );
            + " " + CMonth( Date() ) + Str( Year( Date() ), 5 )
        ?
        ? "Desc                                     Part#       Required    Instock"
        ?
        ?? Chr( 27 ) + "C" + Chr( 66 )
        SET PRINTER OFF
    ELSE
        Scroll()
        @  0, 0 SAY Control->U_Name + "  " + Time() + " " + Str( Day( Date() ), 3 );
            + " " + CMonth( Date() ) + Str( Year( Date() ), 5 )
        @  1, 2 SAY "Desc                                     Part#     Required     Instock"
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
        IF SubStr( Quot->Invno, 1, 1 ) = " "
            SKIP ALIAS Quot
            LOOP
        ENDIF
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
    ENDDO                       // Quot
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
        Scroll( 20, 0, 24, 80 )
        WAIT
        // **   @ 23,20      SAY "Total Amount ="
        // **   @ 23,COL()+2 SAY namount PICTURE "$9,999,999.99"
        // **   WAIT
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF
    SELECT Quot
    SET INDEX TO QuotInd

    RETURN NIL

// *** End of QuotDesc()

// *-------------------------------------------------------------------

FUNCTION QuotList()

    manother := "Y"
    DO WHILE manother == "Y"
        Scroll()
        @  6, 15 SAY "Listing Work Orders"
        mcodeno   := Space( 8 )
        cbranchid := Space( 2 )
        mok := "N"
        mdateok := "N"
        // **   mdateok   := ApGetN( "Y = Total Work-Orders" )
        mselect   := ApGetN( "Individual Name Only" )
        mDueDate  := ApGetN( "J/C Overdue Only" )
        IF mDueDate == "Y"
            nduedate := 30
            @  8, 10 SAY "Over Due by # Days" GET nduedate PICTURE "999"
            READ
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
                    IF mdateok != "Y"
                        IF SubStr( Quot->Invno, 1, 1 ) = " "
                            SKIP ALIAS Quot
                            LOOP
                        ENDIF
                    ENDIF
                    // **      IF Quot->Codeno+Quot->BranchId = mtempno
                    // **         SKIP ALIAS Quot
                    // **         LOOP
                    // **      ENDIF
                    SELECT Name
                    SEEK Quot->Codeno
                    SELECT Quot
                    mtempno := Quot->Codeno + Quot->BranchId
                    AAdd( aPart_, Name->Name + "  " + Quot->BranchId;
                        + " " + Quot->Invno + "        " + Str( RecNo(), 6 ) )
                    SKIP ALIAS Quot
                ENDDO                        // Quot
                DispBox( 0, 1, 23, 47, 2 )
                @ 24, 5 SAY Message->Select
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice( 1, 3, 22, 46, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                ENDIF
                GOTO nrecno
                mcodeno   := Quot->Codeno
                cbranchId := Quot->BranchId
            ENDIF                        // Lastrec
        ENDIF                           // mselect
        SELECT Quot
        GOTO TOP
        mwhere := "S"

        Printsel( mwhere )

        IF mwhere == "P"
            npl := 56
            @  0, 0
            SET DEVICE TO PRINT
        ELSE
            Scroll()
            npl := 23
        ENDIF
        @  0, 0 SAY Control->U_Name
        @  0, 46 SAY Time()
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl := 2
        SELECT Name
        SEEK mcodeno
        @ nl, 1 SAY Name->Name
        nl++
        mgtotal := 0
        SELECT Quot
        GOTO TOP
        DO WHILE Quot->( !Eof() )
            IF mDueDate == "Y"
                IF Quot->DBDate >= Date() -nduedate
                    SKIP ALIAS Quot
                    LOOP
                ENDIF
            ENDIF
            IF mdateok != "Y"
                IF SubStr( Quot->Invno, 1, 1 ) = " "
                    SKIP ALIAS Quot
                    LOOP
                ENDIF
            ENDIF
            IF mselect == "Y"                         // Individual Name
                IF Quot->Codeno != mcodeno
                    SKIP ALIAS Quot
                    LOOP
                ENDIF                                  // Branch Loop
            ENDIF                                     // mselect == "Y"
         /*
         IF cbranchId != SPACE( 2 )
            IF Quot->BranchId != cbranchId
               SKIP ALIAS Quot
               LOOP
            ENDIF                               // cbranchid Loop
         ENDIF                                  // cbranchId
         IF mselect == "Y"                         // Individual Name
            IF Quot->Accepted != "Y"
               SKIP ALIAS Quot
               LOOP
            ENDIF                                  // Accepted Loop
         ENDIF
         */
            // mselect == "Y"
            IF nl > npl
                nl := 2
                IF mwhere == "P"
                    EJECT
                    @ 1, 46 SAY Time()
                    @ 1, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                ELSE
                    WAIT
                    Scroll()
                ENDIF
            ENDIF
            IF Quot->Codeno != mcodeno          // New Codeno
                cbranchId := "99"
                IF mselect == "N"                              // more Names
                    SELECT Name
                    SEEK Quot->Codeno
                    mcodeno := Quot->Codeno
                ENDIF
                nl++
                @ nl, 1 SAY Name->Name
                IF Quot->BranchId != cbranchId
                    SELECT Branch
                    SEEK Quot->Codeno + Quot->BranchId
                    IF Branch->Contact != Space( 30 )
                        @ nl, 32 SAY Branch->Contact
                        @ nl, 74 SAY Branch->BranchId
                    ELSE
                        @ nl, 32 SAY Branch->Name
                        @ nl, 74 SAY Branch->BranchId
                    ENDIF
                    nl++
                    SELECT Quot
                    cbranchId := Quot->BranchId
                ENDIF                         // BranchId
            ENDIF
            SELECT Quot
            mpartnum := Quot->Partnum
            IF mpartnum != Space( 20 )
                SELECT Part
                SET ORDER TO 1                       // Partnum
                SEEK mpartnum
                SELECT Equ
                SET EXACT ON
                mmod1 := Trim( Quot->Partnum )
                SEEK mmod1
                IF Found()
                    SELECT Part
                    ApFLock( 3 )
                    Part->ABC := "M"                   // to find modules
                    UNLOCK
                ENDIF
                @ nl, 0 SAY Quot->DbDate
                @ nl, 10 SAY Quot->Qty PICTURE "99999.99"
                @ nl, 19 SAY SubStr( Part->Desc, 1, 36 )
                @ nl, 57 SAY Part->ABC
                @ nl, 59 SAY SubStr( Quot->Ordnum, 1, 10 )
                IF Quot->Invno != Space( 6 )
                    @ nl, 70 SAY Quot->Invno
                    @ nl, 78 SAY Quot->BranchId
                ELSE
                    @ nl, 70 SAY Quot->Faxno
                ENDIF
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
        @ nl, 10 SAY "Total"
        @ nl, 16 SAY mgtotal PICTURE "$9,999,999.99"
        @ nl, 30 SAY "Total Labour " + Message->LabPart
        @ nl, 64 SAY Message->LabQty PICTURE "999,999.99"
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
        manother := ApGetN( Trim( Message->Another ) + " Listing" )
    ENDDO                           // manother
    SET EXACT OFF

    RETURN NIL

// *** End of Quotlist()

// **-------------------------- End Of XF_QLIST.PRG
