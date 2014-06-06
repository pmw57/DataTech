// **  JoKir10    03-10-11 13:51:54

/*
   Program.....:                  XLF_QU1.PRG
   Authors.....: J.Kirby
   Date........: 06/01/2002
   Functions...: QChriParts, FacDisp, LabCutCopy, LabCutDate
                 LabCutPrint, LabCutOper, IvcLabour
   Static funcs: ChangeFac
   Not used....: IvcLabPart
*/

FUNCTION QChriParts()

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
    INDEX ON QuotOrd->Partnum TO TempInd9
    SET INDEX TO TempInd9
    UNLOCK
    GOTO TOP
    DO WHILE QuotOrd->( !Eof() )
        IF Quot->Dbdate > mdate
            SKIP ALIAS QuotOrd
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
        mpartnum := QuotOrd->Partnum
        SELECT QuotOrd
        DO WHILE QuotOrd->Partnum = mpartnum .AND. QuotOrd->( !Eof() )
            IF QuotOrd->Dbdate > mdate
                SKIP ALIAS QuotOrd
                LOOP
            ENDIF
            mtotal += QuotOrd->Qty
            SKIP ALIAS QuotOrd
        ENDDO
        IF mtotal > 0
            SELECT Part
            SET ORDER TO 1                   // Partnum
            SEEK mpartnum
            @ nl, 0 SAY mtotal PICTURE "99,999"
            @ nl, 7 SAY SubStr( Part->Partnum, 1, 14 )
            @ nl, 23 SAY SubStr( Part->Desc, 1, 34 )
            @ nl, 58 SAY Part->PartId
            nl += 1
        ENDIF           // 0
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
    SELECT QuotOrd
    SET INDEX TO QuotOrd

    RETURN NIL

// *** End of QChriParts()

// *-------------------------------------------------------------------

STATIC FUNCTION ChangeFac()

    IF SubStr( Control->U_Name, 1, 5 ) != "CHRIS"
        Scroll(  4, 0, 24, 80 )
        DispBox(  4, 1, 24, 79, 2 )
        @ 10, 10 SAY "BEWARE THIS IS THE Product File Change in Christine"
        @ 12, 10 SAY "ONLY TILL UP-Dated   NO GOOD"
        @ 14, 10 SAY "BEWARE"
        @ 16, 10 SAY "     "
        WAIT
    ENDIF
    Scroll(  4, 0, 24, 80 )
    DispBox(  4, 1, 24, 79, 2 )
    nl :=  5
    SELECT Name
    SEEK QuotOrd->Codeno
    SELECT Part
    SEEK Quot->Partnum
    @ nl, 4      SAY Name->Name COLOR "BG+"
    @ nl, Col() + 2 SAY "Branch " + QuotOrd->BranchId
    @ nl, Col() + 2 SAY SubStr( QuotOrd->Partnum, 1, 16 )  COLOR "RG+"
    @ nl, Col() + 1 SAY Trim( Part->Unit )
    nl += 2
    SELECT QuotOrd
    @ nl, 3      SAY "Price"
    @ nl, Col() + 1 SAY QuotOrd->Amount   PICTURE "9999,999.99"
    @ nl, Col() + 2 SAY "Disc"
    @ nl, Col() + 1 SAY QuotOrd->Discount PICTURE "9,999.99"
    @ nl, Col() + 3 SAY "Qty"
    @ nl, Col() + 1 SAY QuotOrd->Qty      PICTURE "9,999.99"
    @ nl, Col() + 4 SAY QuotOrd->Faxno    COLOR "RG+"
    nl += 2
    nqty      := QuotOrd->Qty
    ngoodsent := QuotOrd->GoodSent
    cordnum   := QuotOrd->Ordnum
    ddbdate   := QuotOrd->DbDate
    dduedate  := QuotOrd->DueDate
    csentby   := QuotOrd->Sentby
    cdocno    := QuotOrd->Docno
    cfaxno    := QuotOrd->Faxno
    cinfo     := QuotOrd->Info
    cinfo2    := QuotOrd->Info2
    cinfo3    := QuotOrd->Info3
    cinfo4    := QuotOrd->Info4
    @ nl, 8      SAY "Quantity"     GET nqty      PICTURE "99999.99"
    nl += 2
    @ nl, 4      SAY "Supplied Qty" GET ngoodSent PICTURE "99999.99"
    nl++
    @ nl, 4      SAY "How Sent" GET csentby PICTURE "@X"
    @ nl, Col() + 1 SAY "Docket #" GET cdocno  PICTURE "@X"
    nl++
    @ nl, 45      SAY "Ordered Date"
    @ nl, Col() + 1 SAY QuotOrd->DbDate PICTURE "99/99/9999" COLOR "RG+"
    nl++
    @ nl, 4      SAY "O/N "     GET cordnum PICTURE "@X"
    @ nl, Col() + 2 SAY "Date"     GET ddbDate PICTURE "99/99/9999"
    @ nl, Col() + 2 SAY "Due Date" GET ddueDate PICTURE "99/99/9999"
    READ
    Scroll( 1, 68, 23, 78 )
    DispBox( 1, 68, 24, 79, 2 )
    mchoice := Val( Str( Month( dduedate ) ) ) + 3
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
        RETURN NIL
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
    nl += 2
    @ nl, 8 SAY "Reference" GET cfaxno PICTURE "@!"
    nl += 2
    @ nl, 8 GET cinfo   PICTURE "@X"
    nl++
    @ nl, 8 GET cinfo2  PICTURE "@X"
    nl++
    @ nl, 8 GET cinfo3  PICTURE "@X"
    nl++
    @ nl, 8 GET cinfo4  PICTURE "@X"
    READ
    ApRLock( 3 )
    QuotOrd->Qty      := nqty
    QuotOrd->GoodSent := ngoodsent
    QuotOrd->Ordnum   := cordnum
    QuotOrd->DbDate   := ddbdate
    QuotOrd->DueDate  := dduedate
    QuotOrd->Sentby   := csentby
    QuotOrd->Docno    := cdocno
    QuotOrd->Faxno    := cfaxno
    QuotOrd->Info     := cinfo
    QuotOrd->Info2    := cinfo2
    QuotOrd->Info3    := cinfo3
    QuotOrd->Info4    := cinfo4
    QuotOrd->Accepted := "Y"
    UNLOCK

    RETURN NIL
// ***------- End ChangeFac

// *-------------------------------------------------------------------

FUNCTION FacDisp()                 // called by ChriMenu ChriFac

    nselect := 1
    Scroll()
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        SELECT QuotOrd
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
        MENU TO nselect
        DO CASE
        CASE LastKey() = 27
            RETURN NIL
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
                RETURN NIL
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
            nqty   := 0
            GOTO TOP
            DO WHILE QuotOrdOrd->( !Eof() )
                IF QuotOrd->Codeno = "A       "
                    SKIP ALIAS QuotOrd
                    LOOP
                ENDIF
                IF QuotOrd->Faxno != cfaxno
                    SKIP ALIAS QuotOrd
                    LOOP
                ENDIF
                nqty++
                ddate := Str( Year( QuotOrd->Duedate ) );
                    + Str( Month( QuotOrd->DueDate ) );
                    + Str( Day( QuotOrd->DueDate ) );
                    + " " + QuotOrd->Faxno
                AAdd( aPart_, ddate;
                    + " " + SubStr( QuotOrd->Info, 1, 20 );
                    + " " + QuotOrd->Codeno + " " + QuotOrd->BranchId;
                    + " " + SubStr( QuotOrd->Partnum, 1, 8 );
                    + " " + Str( QuotOrd->Qty, 6, 0 );
                    + " " + Str( QuotOrd->Goodsent, 6, 0 );
                    + "                " + Str( RecNo(), 6 ) )
                SKIP ALIAS QuotOrd
            ENDDO
            Scroll()
            DispBox( 0, 1, 24, 79, 2 )
            IF !Empty( aPart_ )
                @ 0, 10      SAY "  Records  "
                @ 0, Col() + 1 SAY nqty PICTURE "9999" COLOR "RG+"
                ASort( aPart_,,, {| x, y | x < y } )                // < = Top > = End
                anum := AChoice( 1, 2, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                IF LastKey() = 27
                    RETURN NIL
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

        CASE nselect == 2
            nselect := 2
            aPart_ := {}
            anum   := {}
            nrecno := 0
            GOTO TOP
            DO WHILE QuotOrd->( !Eof() )
                IF QuotOrd->Codeno = "A       "
                    SKIP ALIAS QuotOrd
                    LOOP
                ENDIF
                ddate := Str( Year( QuotOrd->Duedate ) ) + Str( Month( QuotOrd->DueDate ) );
                    + Str( Day( QuotOrd->DueDate ) ) + " " + QuotOrd->Faxno
                AAdd( aPart_, ddate;
                    + " " + SubStr( QuotOrd->Info, 1, 20 );
                    + " " + QuotOrd->Codeno + " " + QuotOrd->BranchId;
                    + " " + SubStr( QuotOrd->Partnum, 1, 8 );
                    + " " + Str( QuotOrd->Qty, 6, 0 );
                    + " " + Str( QuotOrd->Goodsent, 6, 0 );
                    + "                " + Str( RecNo(), 6 ) )
                SKIP ALIAS QuotOrd
            ENDDO
            DispBox( 0, 1, 24, 79, 2 )
            @  0, 3 SAY " Due Date " COLOR "RG+"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )                // < = Top > = End
                anum := AChoice( 1, 2, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                IF LastKey() = 27
                    RETURN NIL
                ENDIF
            ENDIF     // Empty

        CASE nselect == 3
            nselect := 3
            aPart_ := {}
            anum   := {}
            nrecno := 0
            GOTO TOP
            DO WHILE QuotOrd->( !Eof() )
                IF QuotOrd->Codeno = "A       "
                    SKIP ALIAS QuotOrd
                    LOOP
                ENDIF
                ddate := Str( Year( QuotOrd->Duedate ) );
                    + Str( Month( QuotOrd->DueDate ) );
                    + Str( Day( QuotOrd->DueDate ) );
                    + " " + QuotOrd->Faxno
                AAdd( aPart_, QuotOrd->Codeno;
                    + " " + QuotOrd->BranchId;
                    + " " + SubStr( QuotOrd->Partnum, 1, 8 );
                    + " " + Str( QuotOrd->Qty, 6, 0 );
                    + " " + Str( QuotOrd->Goodsent, 6, 0 );
                    + " " + SubStr( QuotOrd->Info, 1, 20 );
                    + " " + ddate;
                    + "               " + Str( RecNo(), 6 ) )
                SKIP ALIAS QuotOrd
            ENDDO
            DispBox( 0, 1, 24, 79, 2 )
            @  0, 3 SAY " Name List " COLOR "RG+"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 1, 2, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                IF LastKey() = 27
                    RETURN NIL
                ENDIF
            ENDIF     // Empty


        CASE nselect == 4
            nselect := 4
            aPart_ := {}
            anum   := {}
            nrecno := 0
            GOTO TOP
            DO WHILE QuotOrd->( !Eof() )
                IF QuotOrd->Codeno = "A       "
                    SKIP ALIAS QuotOrd
                    LOOP
                ENDIF
                ddate := Str( Year( QuotOrd->Duedate ) );
                    + Str( Month( QuotOrd->DueDate ) );
                    + Str( Day( QuotOrd->DueDate ) );
                    + " " + QuotOrd->Faxno
                AAdd( aPart_, SubStr( QuotOrd->Partnum, 1, 8 );
                    + " " + Str( QuotOrd->Qty, 6, 0 );
                    + " " + Str( QuotOrd->Goodsent, 6, 0 );
                    + " " + QuotOrd->Codeno + " " + QuotOrd->BranchId;
                    + " " + ddate;
                    + " " + SubStr( QuotOrd->Info, 1, 20 );
                    + "                " + Str( RecNo(), 6 ) )
                SKIP ALIAS QuotOrd
            ENDDO
            DispBox( 0, 1, 24, 79, 2 )
            @  0, 3 SAY " PartNum " COLOR "RG+"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )                // < = Top > = End
                anum := AChoice( 1, 2, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                IF LastKey() = 27
                    RETURN NIL
                ENDIF
            ENDIF     // Empty

        CASE nselect == 5
            nselect := 5
            aPart_ := {}
            anum   := {}
            nrecno := 0
            GOTO TOP
            DO WHILE QuotOrd->( !Eof() )
                IF QuotOrd->Codeno = "A       "
                    SKIP ALIAS QuotOrd
                    LOOP
                ENDIF
                ddate := Str( Year( QuotOrd->Duedate ) );
                    + Str( Month( QuotOrd->DueDate ) );
                    + Str( Day( QuotOrd->DueDate ) );
                    + " " + QuotOrd->Faxno
                dTest := Str( Year( QuotOrd->DbDate ) );
                    + Str( Month( QuotOrd->DbDate ) );
                    + Str( Day( QuotOrd->DbDate ) )
                AAdd( aPart_, dTest;
                    + " " + ddate;
                    + " " + QuotOrd->Codeno;
                    + " " + QuotOrd->BranchId;
                    + " " + SubStr( QuotOrd->Partnum, 1, 8 );
                    + " " + Str( QuotOrd->Qty, 6, 0 );
                    + " " + Str( QuotOrd->Goodsent, 6, 0 );
                    + " " + SubStr( QuotOrd->Info, 1, 10 );
                    + "               " + Str( RecNo(), 6 ) )
                SKIP ALIAS QuotOrd
            ENDDO
            DispBox( 0, 1, 24, 79, 2 )
            @  0, 3 SAY " Order Date " COLOR "RG+"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 1, 2, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                IF LastKey() = 27
                    RETURN NIL
                ENDIF
            ENDIF     // Empty
        ENDCASE

        ChangeFac()                        // Above
        LOOP

    ENDDO                      // mcontinue

    RETURN NIL
// ***---- End of FacDis()

// *-------------------------------------------------------------------

FUNCTION LabCutCopy()

    Scroll( 4, 3, 23, 54 )
    mpartnum := Part->Partnum
    // **   minvno := Debit->Invno
    aPart_ := {}
    anum   := {}
    nrecno := 0
    SELECT Labour
    GOTO TOP
    mfind := Space( 20 )
    DO WHILE Labour->( !Eof() )
        IF Labour->Partnum != mfind
            SKIP ALIAS Labour
            LOOP
        ENDIF
        // **      IF Labour->Weekno = Debit->Invno
        // **         SKIP ALIAS Labour
        // **         LOOP
        // **      ENDIF
        SELECT Labour
        AAdd( aPart_, Labour->Desc;
            + " " + Str( Labour->Time );
            + " " + Labour->Invno;
            + "                   " + Str( RecNo(), 6 ) )
        SKIP ALIAS Labour
    ENDDO                       // EOF()
    IF !Empty( aPart_ )
        Scroll( 0, 0, 3, 55 )
        DispBox( 0, 1, 3, 55, 2 )
        @ 1, 2 SAY Part->Invno COLOR "BG+"
        Scroll( 3, 0, 24, 56 )
        DispBox( 3, 1, 24, 56, 2 )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice(  4, 3, 23, 54, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ], 6 ) )
        GOTO nrecno
        IF PressedEsc()
            RETURN NIL
        ENDIF
    ENDIF
    manother := "Y"
    DO WHILE manother = "Y"
        Scroll( 0, 0, 2, 55 )
        DispBox( 0, 1, 3, 55, 2 )
        @ 1, 3 SAY Part->Partnum COLOR "BG+"
        @ 2, 3 SAY Labour->Desc COLOR "RG+"
        DispBox( 3, 1, 24, 55, 2 )
        aPart_ := {}
        anum   := {}
        SELECT LabCut
        GOTO TOP
        DO WHILE LabCut->( !Eof() )
            // **     IF LabCut->Operno != minvno
            // **        SKIP ALIAS LabCut
            // **        LOOP
            // **     ENDIF
            AAdd( aPart_, LabCut->Order;
                + " " + SubStr( LabCut->Desc, 1, 17 ) )
            SKIP ALIAS LabCut
        ENDDO                       // EOF()
        IF !Empty( aPart_ )
            Scroll( 0, 56, 24, 80 )
            DispBox( 0, 56, 24, 79, 2 )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice(  1, 58, 23, 78, aPart_,, "AFUNC" )
            IF PressedEsc()
                RETURN NIL
            ENDIF
        ENDIF
        maccept := ApGetY( "Copy Operation" )
        IF PressedEsc()
            RETURN NIL
        ENDIF
        IF maccept = "Y"
            // **     SELECT Labour
            // **       ApRLock( 3 )
            // **       Labour->Weekno := Debit->Invno
            // **      UNLOCK
            cDesc    := Labour->Desc
            ntime    := Labour->Time
            @ 1, 2                     GET cDesc PICTURE "@X"
            @ 2, 2      SAY "                                      "
            @ 2, 2      SAY Part->Partnum COLOR "BG+"
            @ 2, Col() + 2 SAY "Time hrs" GET ntime PICTURE "9999.99"
            READ
            SELECT LabCut
            ApFLock( 3 )
            APPEND BLANK
            LabCut->Partnum := Part->Partnum
            LabCut->Desc    := cDesc
            LabCut->Order   := "ZZ"
            LabCut->Time    := ntime
            LabCut->Date    := Date()
            LabCut->Operno  := Part->Catno
            UNLOCK
        ENDIF          // maccept
        IF PressedEsc()
            RETURN NIL
        ENDIF
        LabCutCopy()
    ENDDO               // manother

    RETURN mpartnum

// **-----------------  End Of  LabCutCopy

// **--------------------------------------------------------------------------

FUNCTION LabCutDate()

    Scroll()
    ndays  := 60
    nprice := 5
    @ 10, 10 SAY "You Can Print the Module Parts List to level 4"
    @ 12, 10 SAY "How Many days for Part Date Back" GET ndays PICTURE "9999"
    @ 14, 10 SAY "   Only show Parts above $" GET nprice PICTURE "999999.99"
    READ
    mwhere := "S"

    PrintSel( mwhere )

    IF mwhere == "P"
        npl := 56
    ELSE
        npl := 20
    ENDIF
    nl := 3
    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        // **   mcodeno := Debit->Codeno
        // **   minvno  := Debit->Invno
        SELECT Part
        SET ORDER TO 1                    // Codeno
        SEEK mpartnum
        @  0, 2 SAY Part->Partnum
        // **   @  0,22 SAY Name->Name
        @  1, 1 SAY Part->Desc
        @  1, 64 SAY ndays PICTURE "9999"
        @  1, 70 SAY nprice PICTURE "$9,999.99"
        DO WHILE Part->Partnum = mpartnum .AND. Part->( !Eof() )
            IF Part->Partnum != mpartnum
                SKIP ALIAS Part
                LOOP
            ENDIF
            IF SubStr( Part->Partnum, 1, 2 ) = "ZZ"
                SKIP ALIAS Part
                LOOP
            ENDIF
            // **     SELECT Part
            // **     SET ORDER TO 1               // Partnum
            // **     SEEK Quot->Partnum
            nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
            nqty1 := nqty2 := nqty3 := nqty4 := 0
            nequ1 := nequ2 := nequ3 := nequ4 := 0
            nquot := Quot->Qty
            mmod1 := Trim( Part->Partnum )
            IF Part->Date < Date() -ndays .AND. Part->Trade >= nprice
                @ nl, 2 SAY Str( nquot, 9, 2 );
                    + " " + Part->Desc;
                    + "  " + Str( Part->Trade, 12, 2 );
                    + "  " + DToC( Part->Date )
                nl++
            ENDIF
            SELECT Equ
            GOTO TOP
            // **      SET EXACT ON
            SEEK mmod1
            IF Found()
                DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
                    IF SubStr( Equ->Modcode, 1, 2 ) = "ZZ"
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                    IF nl > npl
                        IF mwhere = "P"
                            EJECT
                            nl := 0
                            @ nl, 0 SAY Control->U_Name
                            @ nl, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                                + Str( Year( Date() ), 5 )
                            nl += 2
                        ELSE
                            WAIT
                            Scroll()
                            nl := 0
                        ENDIF
                    ENDIF
                    nqty1 := nquot * Equ->PartQty
                    SELECT Part
                    SEEK Equ->Partnum
                    SELECT Equ
                    IF Part->Date < Date() -ndays .AND. Part->Trade >= nprice
                        IF SubStr( Part->Partnum, 1, 2 ) != "ZZ"

                            @ nl, 0 SAY SubStr( Equ->Modcode, 1, 7 );
                                + " " + SubStr( Part->Partnum, 1, 15 );
                                + " " + SubStr( Part->Desc, 1, 24 );
                                + " " + Str( Equ->Partqty, 8, 2 );
                                + " " + Str( Part->Trade, 10, 2 );
                                + " " + DToC( Part->Date )
                            nl++
                        ENDIF
                    ENDIF
                    SELECT Equ
                    mmod2 := Trim( Equ->Partnum )
                    nrecno2 := RecNo()
                    GOTO TOP
                    SEEK mmod2
                    IF Found()
                        // **         AADD( aPart_," " )
                        DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                            IF nl > npl
                                IF mwhere = "P"
                                    EJECT
                                    nl := 0
                                    @ nl, 0 SAY Control->U_Name
                                    @ nl, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                                        + Str( Year( Date() ), 5 )
                                    nl += 2
                                ELSE
                                    WAIT
                                    Scroll()
                                    nl := 0
                                ENDIF
                            ENDIF
                            nqty2 := Equ->PartQty
                            nequ2 := ( nqty1 * nqty2 ) * nquot
                            SELECT Part
                            SEEK Equ->Partnum
                            SELECT Equ
                            IF Part->Date < Date() -ndays .AND. Part->Trade >= nprice
                                IF SubStr( Part->Partnum, 1, 2 ) != "ZZ"
                                    @ nl, 0 SAY SubStr( Equ->Modcode, 1, 7 );
                                        + " " + SubStr( Part->Partnum, 1, 15 );
                                        + " " + SubStr( Part->Desc, 1, 24 );
                                        + " " + Str( Equ->Partqty, 8, 2 );
                                        + " " + Str( Part->Trade, 10, 2 );
                                        + " " + DToC( Part->Date )
                                    nl++
                                ENDIF
                            ENDIF
                            SELECT Equ
                            mmod3 := Trim( Equ->Partnum )
                            nrecno3 := RecNo()
                            GOTO TOP
                            SEEK mmod3
                            IF Found()
                                // **         AADD( aPart_," " )
                                DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                    IF nl > npl
                                        IF mwhere = "P"
                                            EJECT
                                            nl := 0
                                            @ nl, 0 SAY Control->U_Name
                                            @ nl, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                                                + Str( Year( Date() ), 5 )
                                            nl += 2
                                        ELSE
                                            WAIT
                                            Scroll()
                                            nl := 0
                                        ENDIF
                                    ENDIF
                                    nqty3 := Equ->PartQty
                                    nequ3 := nqty1 * nqty2 * nqty3 * nquot
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    SELECT Equ
                                    IF Part->Date < Date() -ndays .AND. Part->Trade >= nprice
                                        IF SubStr( Part->Partnum, 1, 2 ) != "ZZ"
                                            @ nl, 0 SAY SubStr( Equ->Modcode, 1, 7 );
                                                + " " + SubStr( Part->Partnum, 1, 15 );
                                                + " " + SubStr( Part->Desc, 1, 24 );
                                                + " " + Str( Equ->Partqty, 8, 2 );
                                                + " " + Str( Part->Trade, 10, 2 );
                                                + " " + DToC( Part->Date )
                                            nl++
                                        ENDIF
                                    ENDIF
                                    SELECT Equ
                                    mmod4   := Trim( Equ->Partnum )
                                    nrecno4 := RecNo()
                                    GOTO TOP
                                    SEEK mmod4
                                    IF Found()
                                        DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                            IF nl > npl
                                                IF mwhere = "P"
                                                    EJECT
                                                    nl := 0
                                                    @ nl, 0 SAY Control->U_Name
                                                    @ nl, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                                                        + Str( Year( Date() ), 5 )
                                                    nl += 2
                                                ELSE
                                                    WAIT
                                                    Scroll()
                                                    nl := 0
                                                ENDIF
                                            ENDIF
                                            nqty4 := Equ->PartQty
                                            nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
                                            SELECT Part
                                            SEEK Equ->Partnum
                                            SELECT Equ
                                            IF Part->Date < Date() -ndays .AND. Part->Trade >= nprice
                                                IF SubStr( Part->Partnum, 1, 2 ) != "ZZ"
                                                    @ nl, 0 SAY SubStr( Equ->Modcode, 1, 7 );
                                                        + " " + SubStr( Part->Partnum, 1, 15 );
                                                        + " " + SubStr( Part->Desc, 1, 24 );
                                                        + " " + Str( Equ->Partqty, 8, 2 );
                                                        + " " + Str( Part->Trade, 10, 2 );
                                                        + " " + DToC( Part->Date )
                                                    nl++
                                                ENDIF
                                            ENDIF
                                            SELECT Equ
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
                        ENDDO                       // mmod2 EOF()
                    ENDIF                         // Found mmod2
                    SELECT Equ
                    GOTO nrecno2
                    SKIP ALIAS Equ
                ENDDO                       // mmod1 EOF()
            ENDIF                          // Found mmod1
            SET EXACT OFF
            SELECT Part
            SKIP ALIAS Part
        ENDDO                            // EOF() Part
        mcontinue := "N"
    ENDDO
    IF mwhere = "S"
        Inkey()
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ELSE
        EndPrint()
    ENDIF

    SELECT Part
    SEEK mpartnum

    // **-----------------  End Of  LabCutDate

    // ***-------------------------------------------------------------------------

FUNCTION LabCutPrint()

    mwhere := "S"

    PrintSel( mwhere )

    IF mwhere == "P"
        npl := 56
    ELSE
        npl := 16
    ENDIF
    nl := 0
    nTotTime := 0
    @ nl, 0 SAY Control->U_Name
    @ nl, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    nl += 2
    @ nl, 1 SAY Part->Partnum
    @ nl, 21 SAY Part->Desc
    // **        @ nl,52 SAY "Time"
    nl += 2
    ntimetotal := ntime := 0
    SELECT LabCut
    GOTO TOP
    DO WHILE LabCut->( !Eof() )
        IF LabCut->Partnum != mpartnum
            SKIP ALIAS LabCut
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere = "P"
                EJECT
                nl := 0
                @ nl, 0 SAY Control->U_Name
                @ nl, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                nl += 2
                @ nl, 1 SAY Part->Partnum
                @ nl, 21 SAY Part->Desc
                // **       @ nl,52 SAY "Time"
                nl += 2
            ELSE
                WAIT
                Scroll()
                nl := 0
            ENDIF
        ENDIF
        @ nl, 1 SAY LabCut->Order
        @ nl, 5 SAY LabCut->Desc
        IF LabCut->Time > 0
            @ nl, 48 SAY LabCut->Time PICTURE "99,999.99"
        ENDIF
        @ nl, 59 SAY LabCut->Operno
        IF LabCut->Priority != Debit->Invno
            @ nl, 68 SAY LabCut->Priority
        ENDIF
        ntotTime += LabCut->Time
        nl++
        SKIP ALIAS LabCut
    ENDDO                        // LabCut EOF
    @ nl, 46 SAY "-----------"
    nl++
    @ nl, 35 SAY "Total Time"
    @ nl, 48 SAY ntotTime PICTURE "99,999.99"
    @ nl, 58 SAY "Hours"
    // **       @ nl,58 SAY "Time/60"
    // **       @ nl,66 SAY ntotTime/60 PICTURE "9,999.99"
    nl += 2
    // ***      mmodcode := SUBSTR( mpartnum, 1,16 )
    IF mwhere = "S"
        Inkey()
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ELSE
        EndPrint()
    ENDIF

    RETURN NIL

// **-----------------  End Of  LabCutPrint

// ***-------------------------------------------------------------------------

FUNCTION LabCutOper()

    Scroll()
    DispBox( 0, 1, 2, 79, 2 )
    @  1, 8 SAY mpartnum + "  Viewing Part Operation"
    aPart_ := {}
    nrecno   := 0
    SELECT PartOper
    GOTO TOP
    DO WHILE PartOper->( !Eof() )
        IF PartOper->Operno != Debit->Operno
            SKIP ALIAS PartOper
            LOOP
        ENDIF
        AAdd( aPart_, PartOper->Order;
            + " " + PartOper->Desc;
            + " " + Str( PartOper->Time, 8, 2 );
            + "  " + PartOper->Operno;
            + "  " + PartOper->Adminno;
            + "             " + Str( RecNo(), 6 ) )
        SKIP ALIAS PartOper
    ENDDO                        // PartOper EOF
    ntime := 0
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        Scroll(  3, 0, 24, 80 )
        DispBox( 3, 1, 24, 79, 2 )
        // **       @ 3, 6 SAY " F2 To Add "
        anum := AChoice(  4, 3, 23, 78, aPart_,, "AFUNC" )
        // **        IF LASTKEY() == -1
        // **           JobOperate()                           // Below
        // **        ENDIF
        IF PressedEsc()
            RETURN NIL
        ENDIF
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        GOTO nrecno
        Scroll( 19, 0, 24, 80 )
        DispBox( 19, 1, 24, 79, 2 )
        nl := 20
        SELECT Operate
        cdesc    := PartOper->Desc
        coperno  := PartOper->Operno
        corder   := PartOper->Order
        ntime    := PartOper->Time
        @ nl, 10      SAY "Process Desc" GET cdesc   PICTURE "@X"
        nl += 2
        @ nl, 10      SAY "Ref"          GET coperno PICTURE "@!"
        @ nl, Col() + 2 SAY "Order"        GET corder  PICTURE "@!"
        @ nl, Col() + 2 SAY "Time"         GET ntime   PICTURE "9999.99"
        @ nl, Col() + 1 SAY "in Hours"
        READ
    ENDIF                        // Empty
    SELECT LabCut
    ApFlock( 3 )
    APPEND BLANK
    LabCut->Operno   := PartOper->Operno
    LabCut->Time     := ntime
    LabCut->Rate     := PartOper->Rate
    LabCut->Desc     := cdesc
    LabCut->Order    := corder
    LabCut->Partnum  := mpartnum
    LabCut->Date     := Date()
    LabCut->Priority := Debit->Invno
    READ
    UNLOCK

    RETURN mpartnum

// **-----------------  End Of  LabCutOper

// ***-------------------------------------------------------------------------

FUNCTION IvcLabPart()

    mcodeno := Name->Codeno
    cname   := Space( 40 )
    aPart_ := {}
    nrecno := 0
    ntotal := nlabour := 0
    SELECT Labour
    SET ORDER TO 2                     // Invno+Partnum+Codeno
    GOTO TOP
    SEEK Debit->Invno
    DO WHILE Labour->Invno = Debit->Invno .AND. Labour->( !Eof() )
      /*
      IF Labour->Partnum = SPACE( 20 )
         SKIP ALIAS Labour
         LOOP
      ENDIF
      IF SUBSTR( Labour->Codeno, 5, 1 ) != " "
         SKIP ALIAS Labour
         LOOP
      ENDIF
      IF SUBSTR( Labour->Codeno, 4, 1 ) = " "
         SKIP ALIAS Labour
         LOOP
      ENDIF
      */
        nlabour += Labour->Time
        ntotal  += Labour->Time * Labour->Rate
        AAdd( aPart_, Labour->Codeno;
            + " " + SubStr( Labour->Desc, 1, 30 );
            + " " + Str( Labour->Time, 8, 2 );
            + " " + Str( Labour->Rate, 9, 2 );
            + "                             " + Str( RecNo(), 6 ) )
        SKIP ALIAS Labour
    ENDDO                        // Labour EOF
    // **                      +" "+SUBSTR( Labour->Partnum, 1,16 );
    IF !Empty( aPart_ )
        Scroll()
        DispBox( 0, 1, 3, 79, 2 )
        @  1, 4      SAY Name->Name + "  " + Name->Codeno
        @  2, 14      SAY "Time"
        @  2, Col() + 1 SAY nlabour PICTURE "99,999.99"   COLOR "BG+"
        @  2, Col() + 1 SAY "Labour Rate"
        @  2, Col() + 1 SAY ntotal  PICTURE "$999,999.99" COLOR "BG+"
        @  2, Col() + 2 SAY Debit->Invno  COLOR "BG+"
        @  2, Col() + 2 SAY Debit->DbDate COLOR "BG+"
        DispBox( 4, 0, 24, 79, 2 )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice(  5, 3, 23, 78, aPart_,, "AFUNC" )
        IF PressedEsc()
            RETURN NIL
        ENDIF
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        GOTO nrecno
    ENDIF                        // not Empty
    IF Empty( aPart_ )
        Scroll(  14, 0, 18, 80 )
        DispBox( 14, 0, 18, 79, 2 )
        @ 18, 10 SAY "No Labour or Parts for " + Debit->Invno
    ENDIF                        // Empty
    manother = "Y"
    DO WHILE manother = "Y"
        Scroll(  19, 0, 24, 80 )
        DispBox( 19, 0, 24, 79, 2 )
        @ 24, 60 SAY " DT118 "
        nselect := 1
        @ 19, 10 SAY " --- Labour/Parts --- "
        @ 19, 56 SAY " -- Labour/Parts -- "

        @ 21, 4      PROMPT "1. Labour Add"
        @ 21, Col() + 2 PROMPT "2. Add Part"
        @ 21, Col() + 2 PROMPT "3. Edit Labour"
        @ 21, Col() + 2 PROMPT "4. Print JC"

        @ 23, 4      PROMPT "5. Lab/Parts List"
        @ 23, Col() + 2 PROMPT "6. By Part Desc"
        @ 23, Col() + 2 PROMPT "7. Delete"
        @ 23, Col() + 2 PROMPT "Return"
        // ** @ 23,COL()+2 PROMPT "Information"
        MENU TO nselect
        DO CASE
        CASE nselect == 8
            RETURN NIL
        CASE PressedEsc()
            SELECT Name
            SEEK mcodeno
            mcodeno := Name->Codeno
            RETURN mcodeno
        CASE nselect == 1                // ADD NEW
            // **         IF SUBSTR( Control->U_Name,1, 4 ) = "META"
            LabourWo()                   // XLF_QU5
            // **           ELSE
            // **            LabourShan()                 // XLF_QU10
            // **         ENDIF
            LOOP
        CASE nselect == 2                // ADD NEW PART
            mpartnum := Space( 20 )

            PartFind( mpartnum )

            mpartnum := Part->Partnum
            mcorrect := "N"
            DO WHILE mcorrect == "N"
                SELECT Labour
                ApRLock( 3 )
                APPEND BLANK
                Labour->Codeno  := "  MANUAL"
                Labour->Date    := Date()
                Labour->Invno   := Debit->Invno
                Labour->Rate    := Part->Trade
                Labour->Desc    := Part->Desc
                Labour->Partnum := Part->Partnum
                UNLOCK
                mpartnum := Labour->Partnum
                mdesc    := Labour->Desc
                mmessage := Labour->Message
                mfault   := Labour->Fault
                ntime    := Labour->Time
                nrate    := Labour->Rate
                minvno   := Labour->Invno
                ddate    := Labour->Date
                Scroll(  10, 0, 24, 80 )
                DispBox( 10, 1, 21, 79, 2 )
                @ 12, 10      SAY "Partnum"  GET mpartnum PICTURE "@K!"
                @ 14, 10      SAY "Desc"     GET mdesc    PICTURE "@KX"
                @ 15, 10                     GET mmessage PICTURE "@KX"
                @ 16, 10                     GET mfault   PICTURE "@KX"
                @ 18, 10      SAY "Qty "     GET ntime    PICTURE "9999.99"
                @ 18, Col() + 2 SAY "Cost"     GET nrate    PICTURE "99999.99"
                @ 19, 10      SAY "JC-"      GET minvno   PICTURE "@!"
                @ 19, Col() + 2 SAY "Date"     GET ddate    PICTURE "99/99/9999"
                READ
                ApRLock( 3 )
                Labour->Partnum := mpartnum
                Labour->Desc    := mdesc
                Labour->Message := mmessage
                Labour->Fault   := mfault
                Labour->Time    := ntime
                Labour->Rate    := nrate
                Labour->Invno   := minvno
                Labour->Date    := ddate
                UNLOCK
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                mcorrect := "Y"
            ENDDO                                            // mcorrect
            manother := "Y"
            IvcLabour()

        CASE nselect == 3                    // Edit Labour
            mcorrect := "N"
            DO WHILE mcorrect == "N"
                SELECT Labour
                mdesc    := Labour->Desc
                mmessage := Labour->Message
                mfault   := Labour->Fault
                ntime    := Labour->Time
                nrate    := Labour->Rate
                minvno   := Labour->Invno
                ddate    := Labour->Date
                mlabno   := Labour->Labno
                mcodeno  := Labour->Codeno
                mpartnum := Labour->Partnum
                Scroll(  10, 0, 24, 80 )
                DispBox( 10, 1, 19, 79, 2 )
                @ 12, 8      SAY "Desc"      GET mdesc    PICTURE "@X"
                @ 13, 13                      GET mmessage PICTURE "@X"
                @ 14, 13                      GET mfault   PICTURE "@X"
                @ 16, 6      SAY "Time"      GET ntime    PICTURE "9999.99"
                @ 16, Col() + 2 SAY "Cost"      GET nrate    PICTURE "99999.99"
                @ 16, Col() + 2 SAY "JC-"       GET minvno   PICTURE "@!"
                @ 16, Col() + 2 SAY "Date"      GET ddate    PICTURE "99/99/9999"
                @ 18, 6      SAY "Inv Code"  GET mlabno   PICTURE "@!"
                @ 18, Col() + 1 SAY "Staff/Ord" GET mcodeno  PICTURE "@!"
                @ 18, Col() + 2 SAY "Part"      GET mpartnum PICTURE "@!"
                READ
                ApRLock( 3 )
                Labour->Desc    := mdesc
                Labour->Message := mmessage
                Labour->Fault   := mfault
                Labour->Time    := ntime
                Labour->Rate    := nrate
                Labour->Invno   := minvno
                Labour->Date    := ddate
                Labour->Labno   := mlabno
                Labour->Codeno  := mcodeno
                Labour->Partnum := mpartnum
                UNLOCK
                mdelete := ApGetN( Trim( Message->Delete ) + " Labour" )
                IF PressedEsc()
                    EXIT           // RETURN NIL
                ENDIF
                IF mdelete == "Y"
                    SELECT Labour
                    ApRLock( 3 )
                    DELETE
                    UNLOCK
                ENDIF                // mdelete
                mcorrect := ApGetY( Message->Correct )
            ENDDO                                            // mcorrect
            manother := "Y"
            IvcLabour()

        CASE nselect == 4
            LabPrint()                    // JobFunc
            SELECT Name
            SEEK Debit->Codeno
            mcodeno := Name->Codeno
            manother := "Y"
            IvcLabour()

        CASE nselect == 5                  // Parts Only List

            QuotStkXY()                     // JobFunc
            LabXYParts()                    // JobFunc

            SELECT Name
            SEEK Debit->Codeno
            mcodeno := Name->Codeno
            manother := "Y"
            IvcLabour()

        CASE nselect == 6                // By Parts List
            aPart_ := {}
            nrecno := 0
            ntotal := nlabour := 0
            SELECT Labour
            SET ORDER TO 2                     // Invno+Partnum+Codeno
            GOTO TOP
            SEEK Debit->Invno
            DO WHILE Labour->Invno = Debit->Invno .AND. Labour->( !Eof() )
                // **            IF Labour->Partnum = SPACE( 20 )
                // **               nlabour += Labour->Time
                // **              ELSE
                ntotal  += Labour->Time * Labour->Rate
                // **            ENDIF
   /*
               IF Labour->Partnum = SPACE( 20 )
                  SKIP ALIAS Labour
                  LOOP
               ENDIF
   */
                AAdd( aPart_, Labour->Desc;
                    + " " + Labour->Codeno;
                    + " " + Str( Labour->Time, 8, 2 );
                    + " " + Str( Labour->Rate, 9, 2 );
                    + " " + SubStr( Labour->Partnum, 1, 16 );
                    + "          " + Str( RecNo(), 6 ) )
                SKIP ALIAS Labour
            ENDDO                        // Labour EOF
            IF !Empty( aPart_ )
                Scroll()
                DispBox( 0, 1, 3, 79, 2 )
                @  1, 4      SAY Name->Name + "  " + Debit->Codeno
                @  2, 14      SAY "Time"
                @  2, Col() + 1 SAY nlabour PICTURE "99,999.99"   COLOR "BG+"
                @  2, Col() + 1 SAY "Parts"
                @  2, Col() + 1 SAY ntotal  PICTURE "$999,999.99" COLOR "BG+"
                @  2, Col() + 2 SAY Debit->Invno  COLOR "BG+"
                @  2, Col() + 2 SAY Debit->DbDate COLOR "BG+"
                DispBox( 4, 1, 24, 79, 2 )
                // **      ASORT(aPart_,,,{ | x,y | x < y })
                anum := AChoice(  5, 3, 23, 78, aPart_,, "AFUNC" )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
            ENDIF                        // Empty
            SELECT Labour
            SET ORDER TO 1
            manother := "Y"
            LOOP

        CASE nselect = 7                 // Delete
            Scroll(  10, 0, 24, 80 )
            DispBox( 11, 1, 19, 79, 2 )
            @ 12, 6      SAY "Desc  " + Labour->Desc
            @ 12, Col() + 1 SAY "Part " + Labour->Partnum
            @ 13, 12     SAY Labour->Message
            @ 14, 6      SAY "Time " + Str( Labour->Time )
            @ 16, 6      SAY "Invno " + Labour->Invno
            @ 16, Col() + 2 SAY "Date " + DToC( Labour->Date )
            @ 18, 6      SAY "Inv Code " + Labour->Labno
            @ 18, Col() + 2 SAY "Staff " + Labour->Codeno
            READ
            mdelete := ApGetN( Trim( Message->Delete ) + " Labour" )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mdelete == "Y"
                minvno := Labour->Invno
                SELECT Labour
                ApRLock( 3 )
                DELETE
                UNLOCK
            ENDIF
            manother := "Y"
            IvcLabour()
        ENDCASE
        manother := "Y"
        // **  ApGetY( Message->Another )
    ENDDO               // Another

    SELECT Labour
    SET ORDER TO 1

    SELECT Name
    SEEK mcodeno
    mcodeno := Name->Codeno

    RETURN mcodeno

// ***----- End of IvcLabour()

// ***--------------------------------------------------------------------------

FUNCTION IvcLabour()

    mcodeno := Name->Codeno
    cname   := Space( 40 )
    aPart_ := {}
    nrecno := 0
    ntotal := nlabour := 0
    SELECT Labour
    SET ORDER TO 2                     // Invno+Partnum+Codeno
    GOTO TOP
    SEEK Debit->Invno
    DO WHILE Labour->Invno = Debit->Invno .AND. Labour->( !Eof() )
        IF Labour->Partnum = Space( 20 )
            nlabour += Labour->Time
        ELSE
            ntotal  += Labour->Time * Labour->Rate
        ENDIF
        AAdd( aPart_, Labour->Codeno;
            + " " + SubStr( Labour->Partnum, 1, 16 );
            + " " + SubStr( Labour->Desc, 1, 30 );
            + " " + Str( Labour->Time, 8, 2 );
            + " " + Str( Labour->Rate, 9, 2 );
            + "        " + Str( RecNo(), 6 ) )
        SKIP ALIAS Labour
    ENDDO                        // Labour EOF
    IF !Empty( aPart_ )
        Scroll()
        DispBox( 0, 0, 3, 79, 2 )
        @  1, 4      SAY Name->Name + "  " + Name->Codeno
        @  2, 14      SAY "Time"
        @  2, Col() + 1 SAY nlabour PICTURE "99,999.99"   COLOR "BG+"
        @  2, Col() + 1 SAY "Labour Rate"
        @  2, Col() + 1 SAY ntotal  PICTURE "$999,999.99" COLOR "BG+"
        @  2, Col() + 2 SAY Debit->Invno  COLOR "BG+"
        @  2, Col() + 2 SAY Debit->DbDate COLOR "BG+"
        DispBox( 4, 1, 24, 79, 2 )
        // **     ASORT(aPart_,,,{ | x,y | x < y })
        anum := AChoice(  5, 3, 23, 78, aPart_,, "AFUNC" )
        IF PressedEsc()
            RETURN NIL
        ENDIF
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        GOTO nrecno
    ENDIF                        // Not Empty
    IF Empty( aPart_ )
        Scroll()
        DispBox( 14, 0, 21, 79, 2 )
        @ 16, 10 SAY "No Labour or Parts for " + Debit->Invno
    ENDIF                        // Empty
    manother = "Y"
    DO WHILE manother = "Y"
        Scroll(  19, 0, 24, 80 )
        DispBox( 19, 0, 24, 79, 2 )
        nselect := 1
        @ 19, 10 SAY " -- Labour/Parts -- "
        @ 19, 56 SAY " -- Labour/Parts -- "

        @ 21, 4      PROMPT "1. Labour Add"
        @ 21, Col() + 2 PROMPT "2. Add Part"
        @ 21, Col() + 2 PROMPT "3. Edit Labour"
        @ 21, Col() + 2 PROMPT "4. Print JC"

        @ 23, 4      PROMPT "5. Lab/Parts List"
        @ 23, Col() + 2 PROMPT "6. By Part Desc"
        @ 23, Col() + 2 PROMPT "7. Delete"
        @ 23, Col() + 2 PROMPT "Return"
        MENU TO nselect
        DO CASE
        CASE nselect == 8
            RETURN NIL
            // **     JCMenu()               // XLF_QU7

        CASE PressedEsc()
            // **      SELECT Name
            // **      SEEK mcodeno
            // **      mcodeno := Name->Codeno
            // **       RETURN mcodeno
            RETURN NIL
        CASE nselect == 1                // ADD NEW
            LabourWo()                   // XLF_Qu5.Prg
            LOOP
        CASE nselect == 2                // ADD NEW PART
            mpartnum := Space( 20 )

            PartFind( mpartnum )

            mpartnum := Part->Partnum
            mcorrect := "N"
            DO WHILE mcorrect == "N"
                SELECT Labour
                ApRLock( 3 )
                APPEND BLANK
                Labour->Codeno  := "  MANUAL"
                Labour->Date    := Date()
                Labour->Invno   := Debit->Invno
                Labour->Rate    := Part->Trade
                Labour->Desc    := Part->Desc
                Labour->Partnum := Part->Partnum
                UNLOCK
                mpartnum := Labour->Partnum
                mdesc    := Labour->Desc
                mmessage := Labour->Message
                mfault   := Labour->Fault
                ntime    := Labour->Time
                nrate    := Labour->Rate
                minvno   := Labour->Invno
                ddate    := Labour->Date
                Scroll(  10, 0, 24, 80 )
                DispBox( 10, 1, 21, 79, 2 )
                @ 12, 10      SAY "Partnum"  GET mpartnum PICTURE "@K!"
                @ 14, 10      SAY "Desc"     GET mdesc    PICTURE "@KX"
                @ 15, 10                     GET mmessage PICTURE "@KX"
                @ 16, 10                     GET mfault   PICTURE "@KX"
                @ 18, 10      SAY "Qty "     GET ntime    PICTURE "9999.99"
                @ 18, Col() + 2 SAY "Cost"     GET nrate    PICTURE "99999.99"
                @ 19, 10      SAY "JC-"      GET minvno   PICTURE "@!"
                @ 19, Col() + 2 SAY "Date"     GET ddate    PICTURE "99/99/9999"
                READ
                ApRLock( 3 )
                Labour->Partnum := mpartnum
                Labour->Desc    := mdesc
                Labour->Message := mmessage
                Labour->Fault   := mfault
                Labour->Time    := ntime
                Labour->Rate    := nrate
                Labour->Invno   := minvno
                Labour->Date    := ddate
                UNLOCK
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                mcorrect := "Y"
            ENDDO                                            // mcorrect
            manother := "Y"
            IvcLabour()

        CASE nselect == 3                    // Edit Labour
            mcorrect := "N"
            DO WHILE mcorrect == "N"
                SELECT Labour
                mdesc    := Labour->Desc
                mmessage := Labour->Message
                mfault   := Labour->Fault
                ntime    := Labour->Time
                nrate    := Labour->Rate
                minvno   := Labour->Invno
                ddate    := Labour->Date
                mlabno   := Labour->Labno
                mcodeno  := Labour->Codeno
                mpartnum := Labour->Partnum
                Scroll(  10, 0, 24, 80 )
                DispBox( 10, 1, 19, 79, 2 )
                @ 12, 8      SAY "Desc"      GET mdesc    PICTURE "@X"
                @ 13, 13                      GET mmessage PICTURE "@X"
                @ 14, 13                      GET mfault   PICTURE "@X"
                @ 16, 6      SAY "Time"      GET ntime    PICTURE "9999.99"
                @ 16, Col() + 2 SAY "Cost"      GET nrate    PICTURE "99999.99"
                @ 16, Col() + 2 SAY "JC-"       GET minvno   PICTURE "@!"
                @ 16, Col() + 2 SAY "Date"      GET ddate    PICTURE "99/99/9999"
                @ 18, 6      SAY "Inv Code"  GET mlabno   PICTURE "@!"
                @ 18, Col() + 1 SAY "Staff/Ord" GET mcodeno  PICTURE "@!"
                @ 18, Col() + 2 SAY "Part"      GET mpartnum PICTURE "@!"
                READ
                ApRLock( 3 )
                Labour->Desc    := mdesc
                Labour->Message := mmessage
                Labour->Fault   := mfault
                Labour->Time    := ntime
                Labour->Rate    := nrate
                Labour->Invno   := minvno
                Labour->Date    := ddate
                Labour->Labno   := mlabno
                Labour->Codeno  := mcodeno
                Labour->Partnum := mpartnum
                UNLOCK
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                mdelete := ApGetN( Trim( Message->Delete ) + " Labour" )
                IF PressedEsc()
                    RETURN   // EXIT
                ENDIF
                IF mdelete == "Y"
                    SELECT Labour
                    ApRLock( 3 )
                    DELETE
                    UNLOCK
                ENDIF                // mdelete
                mcorrect := ApGetY( Message->Correct )
            ENDDO                                            // mcorrect
            manother := "Y"
            IvcLabour()

        CASE nselect == 4
            LabPrint()                    // JobFunc
            SELECT Name
            SEEK Debit->Codeno
            mcodeno := Name->Codeno
            manother := "Y"
            IvcLabour()

        CASE nselect == 5                  // Parts Only List

            QuotStkXY()                     // JobFunc
            LabXYParts()                    // JobFunc

            SELECT Name
            SEEK Debit->Codeno
            mcodeno := Name->Codeno
            manother := "Y"
            IvcLabour()

        CASE nselect == 6                // By Parts List
            aPart_ := {}
            nrecno := 0
            ntotal := nlabour := 0
            SELECT Labour
            SET ORDER TO 2                     // Invno+Partnum+Codeno
            GOTO TOP
            SEEK Debit->Invno
            DO WHILE Labour->Invno = Debit->Invno .AND. Labour->( !Eof() )
                IF Labour->Partnum = Space( 20 )
                    nlabour += Labour->Time
                ELSE
                    ntotal  += Labour->Time * Labour->Rate
                ENDIF
                IF Labour->Partnum = Space( 20 )
                    SKIP ALIAS Labour
                    LOOP
                ENDIF
                AAdd( aPart_, Labour->Desc;
                    + " " + Labour->Codeno;
                    + " " + Str( Labour->Time, 8, 2 );
                    + " " + Str( Labour->Rate, 9, 2 );
                    + " " + SubStr( Labour->Partnum, 1, 16 );
                    + "          " + Str( RecNo(), 6 ) )
                SKIP ALIAS Labour
            ENDDO                        // Labour EOF
            IF !Empty( aPart_ )
                Scroll()
                DispBox( 0, 1, 3, 79, 2 )
                @  1, 4      SAY Name->Name + "  " + Debit->Codeno
                @  2, 14      SAY "Time"
                @  2, Col() + 1 SAY nlabour PICTURE "99,999.99"   COLOR "BG+"
                @  2, Col() + 1 SAY "Parts"
                @  2, Col() + 1 SAY ntotal  PICTURE "$999,999.99" COLOR "BG+"
                @  2, Col() + 2 SAY Debit->Invno  COLOR "BG+"
                @  2, Col() + 2 SAY Debit->DbDate COLOR "BG+"
                DispBox( 4, 1, 24, 79, 2 )
                // **      ASORT(aPart_,,,{ | x,y | x < y })
                anum := AChoice(  5, 3, 23, 78, aPart_,, "AFUNC" )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
            ENDIF                        // Empty
            SELECT Labour
            SET ORDER TO 1
            manother := "Y"
            LOOP

        CASE nselect = 7                 // Delete
            Scroll(  10, 0, 24, 80 )
            DispBox( 11, 1, 19, 79, 2 )
            @ 12, 6      SAY "Desc  " + Labour->Desc
            @ 12, Col() + 1 SAY "Part " + Labour->Partnum
            @ 13, 12     SAY Labour->Message
            @ 14, 6      SAY "Time " + Str( Labour->Time )
            @ 16, 6      SAY "Invno " + Labour->Invno
            @ 16, Col() + 2 SAY "Date " + DToC( Labour->Date )
            @ 18, 6      SAY "Inv Code " + Labour->Labno
            @ 18, Col() + 2 SAY "Staff " + Labour->Codeno
            READ
            mdelete := ApGetN( Trim( Message->Delete ) + " Labour" )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mdelete == "Y"
                minvno := Labour->Invno
                SELECT Labour
                ApRLock( 3 )
                DELETE
                UNLOCK
            ENDIF
            manother := "Y"
            IvcLabour()
        ENDCASE
        manother := "Y"
        // **  ApGetY( Message->Another )
    ENDDO               // Another

    SELECT Labour
    SET ORDER TO 1

    SELECT Name
    SEEK mcodeno
    mcodeno := Name->Codeno

    RETURN mcodeno

// ***----- End of IvcLabour()

// ***--------------------------------------------------------------------------

FUNCTION LabWOPrint( mcodeno )

    Scroll()
    DispBox( 0, 1, 18, 79, 2 )
    @  1, 20 SAY "Labour Analysis"
    @  1, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    mstmm  := Date()
    mendmm := Date() + 1
    @ 10, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
    @ 11, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
    READ
    IF PressedEsc()
        RETURN NIL
    ENDIF
    mwhere   := "S"

    Printsel( mwhere )

    nl := 0
    IF mwhere == "P"
        npl := 55
    ELSE
        Scroll()
        npl := 22
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0, 34 SAY mstmm
    @  0, 47 SAY mendmm
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    // ** @  2, 0 SAY Name->Name
    nl := 4
    ntimetotal := 0
    SELECT Labour
    GOTO TOP
    DO WHILE Labour->( !Eof() )
        IF Labour->Partnum != Space( 20 )
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Invno != Debit->Invno
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Date < mstmm
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Date > mendmm
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            @  0, 0 SAY Control->U_Name
            @  0, 34 SAY mstmm
            @  0, 47 SAY mendmm
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            nl := 4
        ENDIF                       // nl>npl
        @ nl, 0 SAY Labour->Date
        @ nl, 11 SAY Labour->Codeno
        @ nl, 20 SAY Labour->Desc
        @ nl, 61 SAY Labour->Invno
        @ nl, 68 SAY Labour->Time PICTURE "99,999.99"
        nl++
        IF Labour->Message != Space( 50 )
            @ nl, 15 SAY Labour->Message
            nl++
        ENDIF
        IF Labour->Fault != Space( 50 )
            @ nl, 15 SAY Labour->Fault
            nl++
        ENDIF
        ntimetotal += Labour->Time
        SKIP ALIAS Labour
    ENDDO                // EOF Labour
    @ nl, 67 SAY "----------"
    nl++
    @ nl, 48 SAY "Total Time"
    @ nl, 68 SAY ntimetotal PICTURE "99,999.99"
    nl++
    @ nl, 67 SAY "=========="
    nl++
    IF mwhere = "P"
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

    RETURN mcodeno

// ****** End of LabWOPrint()

// ********----------  END OF FILE XLF_QU1.PRG
