// **  JoKir09  22-10-11 07:28:55

/*  Program.....:              CHRIORD1.PRG
    Author......: J.Kirby
    Date........: 01/09/1993   // 16/08/2006
    Funtions....: OrdFrmChr, OrdList, OrderTot, QuotOut, OrdLook, Ordchkndx
                  Ordreindx, Orderfrm, Setprnt
*/

FUNCTION Orderfrm()

    Scroll()

    Setprnt()

    IF mwhere = "P"
        SET DEVICE TO PRINT
        nl  := 120
        npl := 51
    ELSE
        nl  := 1
        npl := 23
    ENDIF                       // mwhere
    SELECT Orders
    SET ORDER TO 2
    SEEK mordnum                             // ORDERS
    morderno := Orders->Codeno
    mdat     := Orders->DATE                   // Easier to get this here
    mdat     := DToC( mdat )
    nweight  := 0
    DO WHILE Orders->( !Eof() )
        IF nl > npl
            IF mwhere = "P"
                SELECT Name
                SEEK mcodeno
                @  0, 12 SAY Trim( Orders->Jobnum ) + " PURCHASE ORDER #  ";
                    + SubStr( Orders->Psno, 7, 2 ) + " " + mordnum
                @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                mcodeno := "OWN99999"             // So Orders can be from Standard Co
                SEEK mcodeno
                @  2, 4 SAY "From :"
                IF Found()
                    @  2, 11 SAY Name->Name
                    @  3, 11 SAY Name->Add1
                    @  4, 11 SAY Name->Add2
                    @  5, 11 SAY Name->Add3
                    @  6, 11 SAY Name->Add4 + " " + Name->Zip
                    @  7, 11 SAY "Phone : " + Name->Phone
                ELSE
                    SELECT Control
                    @  2, 11 SAY Control->U_Name
                    @  3, 11 SAY Control->U_Add1
                    @  4, 11 SAY Control->U_Add2
                    @  5, 11 SAY Control->U_Add3
                    @  6, 11 SAY Control->U_Add4 + " " + Control->U_Zip
                    @  7, 11 SAY "Phone : " + Control->U_Phone
                ENDIF                      // FOUND
                SELECT Name
                SEEK Orders->Codeno
                @  8, 0 SAY Replicate( ".", 70 )
                @ 10, 11 SAY Name->Name
                @ 11, 11 SAY Name->Add1
                @ 11, 48 SAY "PURCHASE ORDER # ";
                    + SubStr( Orders->Psno, 7, 2 ) + " " + mordnum
                @ 12, 11 SAY Name->Add2
                @ 13, 11 SAY Name->Add3
                @ 13, 40 SAY "Date " + mdat
                @ 14, 11 SAY Name->Add4 + " " + Name->Zip
                @ 15, 11 SAY "Phone : " + Name->Phone
                @ 16, 0 SAY Replicate( ".", 70 )
                @ 17, 18 SAY "Description"
                @ 17, 60 SAY "Order Qty"
                @ 18, 0 SAY Replicate( "-", 70 )
                nl := 19
            ELSE
                WAIT
                @  0, 15 SAY "PURCHASE ORDER # " + mordnum
                Scroll()
                nl := 1
            ENDIF              // mwhere
        ENDIF                       // nl>npl
        SELECT Orders
        IF Orders->Partnum != Space( 20 )
            ApRLock( 3 )
            ntotal   := 0
            mpartnum := Orders->Partnum
            Orders->P_flag := .T.
            UNLOCK
            SELECT Part
            SET ORDER TO 1                        // Partnum
            SEEK mpartnum
            SELECT Supl
            SET ORDER TO 1                        // Partnum+Codeno
            mseek := mpartnum + Orders->Codeno
            SEEK mseek
            IF Found()
                IF Supl->SuppId != Space( 16 )
                    @ nl, 0 SAY "." + SubStr( Supl->SuppId, 1, 15 )
                ELSE
                    @ nl, 0 SAY SubStr( mpartnum, 1, 16 )
                ENDIF
            ELSE
                IF SubStr( Part->Partnum, 1, 2 ) != "ZZ"
                    @ nl, 0 SAY SubStr( Part->Partnum, 1, 16 )
                ENDIF
            ENDIF                             // FOUND
            IF Orders->Detail1 != Space( 40 )
                @ nl, 18 SAY SubStr( Orders->Detail1, 1, 36 )
            ELSE
                @ nl, 20 SAY "Supply as detailed below."
            ENDIF
            @ nl, 55 SAY Orders->Partqty PICTURE "99,999.99"
            DO CASE
            CASE Part->Unit == "Mtr       "
                nl++
                @ nl, 20 SAY "Order Length = " + Str( Orders->Length, 6, 2 );
                    + " " + Part->Unit
            CASE Part->Unit == "Sq Mtr    "
                @ nl, 70 SAY "Sheets"
            ENDCASE
            nl++
            SELECT Orders
            IF Orders->Detail2 != Space( 40 )
                @ nl, 10 SAY Orders->Detail2
                nl++
            ENDIF
            IF Orders->Detail3 != Space( 40 )
                @ nl, 10 SAY Orders->Detail3
                nl++
            ENDIF
            IF Orders->Detail4 != Space( 40 )
                @ nl, 10 SAY Orders->Detail4
                nl++
            ENDIF
        ENDIF                   // Orders
        SKIP ALIAS Orders
        IF Orders->Ordnum != mordnum
            EXIT
        ENDIF
    ENDDO                             // Orders EOF
    IF mwhere = "P"
        @  52, 0 SAY Message->Order1
        @  53, 0 SAY Message->Order2
        @  54, 0 SAY Message->Order3
        @  55, 0 SAY Message->Order4
        @  56, 0 SAY Message->Order5
        @  57, 0 SAY Message->Order6
        EJECT
    ELSE
        WAIT
        Scroll()
        nl := 1
        IF nl > 18
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF
    Scroll()
    SET MARGIN TO 0
    SELECT QuotStk
    SET ORDER TO 1

    RETURN NIL

// **----------- End OrderFrm()

// *-------------------------------------------------------------------

FUNCTION OrdList()

    cjsno := "      "
    mptot := msum := nQty := 0
    mpartnum := Space( 20 )
    mcontinue := "Y"
    DO WHILE mcontinue == "Y"

        SELECT Orders
        SET ORDER TO 3                           // Codeno
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
                IF SubStr( Orders->Codeno, 1, 2 ) = "A "
                    SKIP ALIAS Orders
                    LOOP
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
                nrecno := Val( Right( aPart_[ anum ], 6 ) )
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
                        cdesc := SubStr( Orders->Detail1, 1, 20 )
                        SELECT Orders
                        IF cdesc = Space( 30 )
                            cdesc := SubStr( Part->Desc, 1, 20 )
                        ENDIF
                        IF cdesc = Space( 30 )
                            cdesc := SubStr( Orders->Detail2, 1, 2 )
                        ENDIF
                        AAdd( aPart_, Orders->Ordnum;
                            + " " + Orders->Codeno;
                            + " " + DToC( Orders->Date );
                            + " " + SubStr( Part->Partnum, 1, 8 );
                            + " " + cdesc;
                            + " " + Str( Orders->PartQty, 8, 2 );
                            + " " + Str( Orders->Amount, 8, 2 );
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
        mordnum := Space( 4 )
        SELECT Orders
        SET ORDER TO 3                   // Codeno+Ordnum
        SEEK Name->Codeno
        IF Found()
            cdesc  := Space( 30 )
            cunit  := Space( 10 )
            nrecno := 0
            aPart_ := {}
            DO WHILE Orders->Codeno == Name->Codeno .AND. Orders->( !Eof() )
                SELECT Part
                SET ORDER TO 1
                SEEK Orders->Partnum
                cdesc := SubStr( Orders->Detail1, 1, 20 )
                SELECT Orders
                IF cdesc = Space( 20 )
                    cdesc := SubStr( Part->Desc, 1, 20 )
                ENDIF
                IF cdesc = Space( 30 )
                    cdesc := SubStr( Orders->Detail2, 1, 20 )
                ENDIF
                DO CASE
                CASE Orders->Length > 0
                    cunit := "Lengths   "
                CASE Part->Unit = "Sq Mtrs   "
                    cunit := "Sheets    "
                OTHERWISE
                    cunit := Part->Unit
                ENDCASE
                AAdd( aPart_, Orders->Ordnum;
                    + " " + SubStr( Part->Partnum, 1, 8 );
                    + " " + cdesc;
                    + " " + DToC( Orders->Date );
                    + " " + Str( Orders->PartQty, 8, 2 );
                    + " " + Str( Orders->Amount, 8, 2 );
                    + " " + Trim( cunit );
                    + "        " + Str( RecNo(), 6 ) )
                SKIP ALIAS Orders
            ENDDO                  // Orders
            IF !Empty( aPart_ )
                @ 1, 5 SAY Name->Name
                Scroll(   3, 0, 24, 80 )
                DispBox(  3, 1, 24, 79, 2 )
                @  3, 3 SAY " - Parts On Order -" COLOR "G+"
                @  3, 50 SAY " -- Ordered Qty  Received -- "
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice(  4, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
                nrecno := Val( Right( aPart_[ anum ], 6 ) )
            ENDIF
            GOTO nrecno
            mordnum := Orders->Ordnum
            SET ORDER TO 1               // Partnum
        ENDIF                                // FOUND()
        Scroll(  21, 0, 24, 80 )
        DispBox( 21, 1, 24, 79, 2 )
        @ 22, 10      SAY "Order #" GET mordnum PICTURE "@KX"
        READ
        IF LastKey() == 27
            LOOP
            // **      RETURN NIL
        ENDIF

        Printsel( nl )

        @  1, 9 SAY "Outstanding Orders"
        @  1, 68 SAY Date()
        @  2, 56 SAY "Received"
        @  2, 70 SAY "Out"
        nl := 3
        ntotal  := 0
        SELECT Orders
        SET ORDER TO 2          // Ordnum
        GOTO TOP
        SEEK mordnum
        SELECT Name
        SEEK Orders->Codeno
        @ nl, 2 SAY Name->Name + " O/N # " + mordnum
        nl++
        SELECT Orders
        DO WHILE Orders->Ordnum = mordnum .AND. Orders->( !Eof() )
            IF Orders->Codeno == "A       "
                SKIP ALIAS Orders
                LOOP
            ENDIF
            IF Orders->Codeno != mcodeno
                SKIP ALIAS Orders
                LOOP
            ENDIF
            IF nl > npl
                IF mwhere = "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                @  1, 9 SAY "Outstanding Orders"
                @  1, 68 SAY Date()
                @  2, 56 SAY "Received"
                @  2, 70 SAY "Out"
                nl := 3
            ENDIF
            @ nl, 0 SAY SubStr( Orders->Partnum, 1, 16 )
            SELECT Supl
            SET ORDER TO 1                        // Partnum+Codeno
            SEEK Orders->Partnum + Orders->Codeno
            IF Found()
                IF Trim( Supl->SuppId ) != Trim( Orders->Partnum )
                    @ nl, 20 SAY Supl->SuppId
                ENDIF
            ENDIF
            @ nl, 45 SAY Part->Unit
            @ nl, 54 SAY Orders->PartIn PICTURE "999,999.99"
            @ nl, 64 SAY ( Orders->PartQty - Orders->PartIn ) PICTURE "999,999.99"
            SELECT Part
            SET ORDER TO 1                        // Partnum
            SEEK Orders->Partnum
            ntotal += ( Part->Trade * Orders->PartQty )
            SELECT Orders
            nl++
            IF Orders->Psno != Space( 20 )
                @ nl, 2 SAY Orders->Psno
            ENDIF
            IF Orders->Detail1 != Space( 40 )
                @ nl, 22 SAY Orders->Detail1
            ENDIF
            IF Orders->Detail2 != Space( 40 )
                nl++
                @ nl, 22 SAY Orders->Detail2
            ENDIF
            IF Orders->Detail3 != Space( 40 )
                nl++
                @ nl, 22 SAY Orders->Detail3
            ENDIF
            nl++
            SKIP ALIAS Orders
        ENDDO                           // EOF()
        nl++
        @ nl, 25 SAY "Order Cost ="
        @ nl, 40 SAY ntotal PICTURE "$999,999.99"
        IF mwhere = "P"
            EndPrint()
        ELSE
            WAIT
        ENDIF
        mcontinue := ApGetN( Trim( Message->Another ) + " Order" )
    ENDDO

    RETURN NIL

// **--- End OrdList()

// ***---------------------------------------------------------------------------

FUNCTION HouseTot()

    mpTot := 0
    manother := "Y"
    DO WHILE manother == "Y"
        SELECT QuotStk
        SET ORDER TO 2
        GOTO TOP
        nrecno := 0
        aPart_ := {}
        IF LastRec() != 0
            DO WHILE QuotStk->( !Eof() )
                IF QuotStk->Required <= 0
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF
                SELECT Part
                SEEK QuotStk->Partnum
                SELECT QuotStk
                IF Part->Boughtout != "N"
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF
                mpartnum := Part->Partnum
                minvno := QuotStk->Invno
                SELECT QuotStk
                SET ORDER TO 2
                nQty := 0
                SEEK mpartnum
                DO WHILE QuotStk->Partnum = mpartnum .AND. QuotStk->( !Eof() )
                    nQty += QuotStk->Required - QuotStk->Received
                    SKIP ALIAS QuotStk
                ENDDO
                SELECT Part
                ApRLock( 3 )
                Part->QuotQty := nQty
                UNLOCK
                AAdd( aPart_, SubStr( Part->Desc, 1, 34 );
                    + " " + SubStr( Part->Partnum, 1, 16 );
                    + " " + Str( Part->QuotQty, 9, 2 );
                    + " " + Str( Part->Instock, 9, 2 );
                    + "     " + Str( RecNo(), 6 ) )
                SELECT QuotStk
            ENDDO                  // QuotStk
        ENDIF
        IF !Empty( aPart_ )
            Scroll()
            DispBox(  0, 1, 2, 79, 2 )
            @  1, 10 SAY "IN HOUSE All Job Cards"
            @  3, 3 SAY "Description                         Part                Required  Instock"
            Scroll(   4, 0, 24, 80 )
            DispBox(  4, 1, 24, 79, 2 )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice(  5, 3, 23, 77, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
            SELECT Part
            GOTO nrecno
            mpartnum := Part->Partnum
            Scroll(  18, 0, 24, 80 )
            DispBox( 18, 1, 21, 79, 2 )
            @ 19, 3 SAY Trim( Part->Partnum ) + " " + Trim( Part->Desc );
                + " " + Str( Part->QuotQty, 10, 2 ) + " " + Part->Codeno
            mcodeno := Part->Codeno
            SELECT Name
            SEEK mcodeno
            DO WHILE !Found()
                SAVE SCREEN TO holdscrn
                Namerank( @mcodeno )                       // XlF_Name
                IF LastKey() == 27
                    RETURN
                ENDIF
                SELECT Name
                SEEK mcodeno
                RESTORE SCREEN FROM holdscrn
                SELECT Part
                ApFLock( 3 )
                Part->Codeno := Name->Codeno
                UNLOCK
            ENDDO
        ENDIF                      // !EMPTY
        DispBox( 22, 1, 24, 79, 2 )
        nselect := 1
        @ 23, 10      PROMPT "Edit Part"
        @ 23, Col() + 3 PROMPT "Another Part"
        @ 23, Col() + 3 PROMPT "Print List"
        @ 23, Col() + 3 PROMPT "Exit"
        MENU TO nselect
        DO CASE
        CASE nselect = 4 .OR. LastKey() == 27
            SELECT Quot
            SET INDEX TO QuotInd
            RETURN NIL
        CASE nselect == 2
            manother = "Y"
            LOOP
        CASE nselect == 1
            ScrnOrd  := SaveScreen( 0, 0, 24, 80 )
            mpartnum := Part->Partnum
            Scroll( 3, 0, 24, 80 )
            DispBox( 3, 1, 24, 79, 2 )
            SELECT Part
            SET ORDER TO 1
            SEEK mpartnum
            mQty    := 0
            nlength := 0
            ncsarea := 0
            nlinm := nvol := nlen := 0
            @  1, 5 SAY Part->Desc + " " + Trim( Part->Partnum ) + " " + Part->Unit COLOR "BG+"
            nl := 4
            @  nl, 5      SAY "In Stock"
            @  nl, Col() + 1 SAY Part->Instock PICTURE "99,999.99" COLOR "G+"
            @  nl, Col() + 1 SAY "Length Mtr"
            @  nl, Col() + 1 SAY Part->Length  PICTURE "999.999"
            @  nl, Col() + 1 SAY "Width mm"
            @  nl, Col() + 1 SAY Part->Width   PICTURE "999.999"
            @  nl, Col() + 2 SAY Part->Unit
            nl += 2
            SELECT Part
            ApRLock( 3 )
            nselect := 1
            DO CASE
            CASE Part->Unit = "Each      "
                nselect := 1
            CASE Part->Unit = "Mtr       "
                nselect := 2
            CASE Part->Unit = "Sq Mtr    "
                nselect := 3
            CASE Part->Unit = "Cu Mtr    "
                nselect := 4
            ENDCASE
            @ nl, 5      PROMPT "Each  "
            @ nl, Col() + 2 PROMPT "Mtr   "
            @ nl, Col() + 2 PROMPT "Sq Mtr"
            @ nl, Col() + 2 PROMPT "Cu Mtr"
            MENU TO nselect
            DO CASE
            CASE nselect == 1
                Part->Unit := "Each"
            CASE nselect == 2
                Part->Unit := "Mtr"
            CASE nselect == 3
                Part->Unit := "Sq Mtr"
            CASE nselect == 4
                Part->Unit := "Cu Mtr"
            ENDCASE
            UNLOCK
            nl += 2
            DO CASE
            CASE Part->Unit = "Sq Mtr    "
                nwidth    := Part->Width / 1000
                SELECT Part
                ApRLock( 3 )
                nvol  := Part->Instock / ( nwidth * Part->Length )
                ncost := Part->Trade * ( nwidth * Part->Length )
                ndiscount := 0
                @  nl, 6      SAY "Width in Mtr"  GET nwidth
                @  nl, Col() + 2 SAY "Length in Mtr" GET Part->Length
                nl += 2
                @  nl, 6      SAY "Sheets in Stock"  GET nvol      PICTURE "999999.99"
                READ
                mQty  := ( Part->Length * nwidth ) * nvol
                @ nl, 42 SAY "Sq Mtrs " + Str( mQty, 8, 2 )
                IF LastKey() == 27
                    UNLOCK
                    RETURN
                ENDIF
                Part->Width := nwidth * 1000   // Convert to mm
                UNLOCK

            CASE Part->Unit = "Cu Mtr    "
                nl++
                @  nl, 5      SAY "Volume Cu/M"   GET nvol   PICTURE "999.999"
                @  nl, Col() + 2 SAY "Rate per Cu/M" GET nrate  PICTURE "999.99"
                READ
                IF LastKey() == 27
                    RETURN
                ENDIF
                // * Calculate cross-section area in square metres
                ncsarea := ( Part->Width * Part->Thick ) / 1000000
                // * Calculate linear metres
                nlen := nvol / ncsarea
                // * Calculate cost per linear metre.
                // * Must allow for variable volume here  (Try various volumes for
                // *   same width & thickness - cost should be constant)
                ncost = ( nrate / nlen ) * nvol
                // * Wastage Factor 10%
                // * Show total linear & cost
                ncost := ncost * 1.1
                ncsarea := ( Part->Width * Part->Thick ) // cross sectional area in sq mm
                ncsarea := ncsarea / 1000000             // cross sectional area in sq metres
                // * ( Could combine above two lines into one calculation )
                mQty := nvol / ncsarea         // length in metres
                nl += 2
                @  nl, 5      SAY "Per Mtr+10% " + Str( ncost, 6, 3 ) COLOR "G+"
                @  nl, Col() + 1 SAY "Mtrs " + Str( nlen, 5 ) COLOR "G+"
                @  nl, Col() + 1 SAY "Length"   GET mQty      PICTURE "999999.99"
                READ
                IF LastKey() == 27
                    RETURN
                ENDIF

            CASE Part->Unit = "Mtr       "                 // Linear Mtr
                SELECT Part
                ApRLock( 3 )
                mQty := Part->Instock / Part->Length
                @ nl, 5      SAY "Length Each Mtr"  GET Part->Length PICTURE "9999.999"
                @ nl, Col() + 2 SAY "Qty of Lengths"   GET mQty         PICTURE "99999.99"
                READ
                UNLOCK
                mQty := Part->Length * mQty
                nl += 2
                @ nl, 5      SAY "Mtr Qty"
                @ nl, Col() + 2 SAY mQty PICTURE "99,999.99" COLOR "G+"
                IF LastKey() == 27
                    RETURN
                ENDIF

            CASE Part->Unit = "Each      "
                mQty := Part->Instock
                @  nl, 5 SAY "In Stock Qty" GET mQty PICTURE "999999.99"
                READ
                IF LastKey() == 27
                    RETURN
                ENDIF

            OTHERWISE
                mQty := Part->Instock
                @  nl, 5 SAY "In Stock Qty" GET mQty PICTURE "999999.99"
                READ
                IF LastKey() == 27
                    RETURN
                ENDIF
            ENDCASE
            SELECT Part
            ApRLock( 3 )
            nselect := 1
            DO CASE
            CASE Part->Boughtout = "Y"
                nselect := 1
            CASE Part->Boughtout = "N"
                nselect := 2
            ENDCASE
            nl += 2
            @ nl, 5      PROMPT "Part Bought Out"
            @ nl, Col() + 2 PROMPT "Own Manufacture"
            MENU TO nselect
            DO CASE
            CASE nselect == 1
                Part->Boughtout := "Y"
            CASE nselect == 2
                Part->Boughtout := "N"
            ENDCASE
            Part->Instock := mQty
            UNLOCK
            RestScreen(  0, 0, 24, 80, ScrnOrd )
            manother = "Y"
            LOOP
        CASE nselect == 3
            Printsel()

            IF mwhere = "S"
                npl := 22
            ELSE
                npl := 62
            ENDIF
            mpTot := mSum := 0
            @  0, 0 SAY Control->U_Name + " Parts For ALL Job Cards"
            @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  2, 0 SAY "Partnum             Desc"
            @  2, 50 SAY "Out/QT    In Stock   From"
            nl := 4
            IF mwhere = "P"
                EndPrint()
            ELSE
                WAIT
            ENDIF
            manother = "Y"
            LOOP
        ENDCASE
        manother := "N"
    ENDDO                       // manother
    SELECT Quot
    SET INDEX TO QuotInd

    RETURN

// ***--------- End HouseTot()

// *-------------------------------------------------------------------

FUNCTION OrderTot()

    mpTot := 0
    manother := "Y"
    DO WHILE manother == "Y"
        SELECT QuotStk
        SET ORDER TO 2
        GOTO TOP
        nrecno := 0
        aPart_ := {}
        IF LastRec() != 0
            DO WHILE QuotStk->( !Eof() )
                IF QuotStk->Required = 0
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF
                IF SubStr( QuotStk->Partnum, 1, 2 ) = "ZZ"
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF
                SELECT Part
                SEEK QuotStk->Partnum
                SELECT QuotStk
                IF Part->Boughtout != "Y"
                    SKIP ALIAS QuotStk
                    LOOP
                ENDIF
                mpartnum := Part->Partnum
                SELECT Orders
                SET ORDER TO 1                            // Partnum index
                GOTO TOP
                SEEK mpartnum
                mptot := mQty := 0
                IF Found()
                    DO WHILE Orders->Partnum = mpartnum .AND. Orders->( !Eof() )
                        mptot += Orders->Partqty - Orders->QtyRec
                        SKIP ALIAS Orders
                    ENDDO
                ENDIF
                minvno := QuotStk->Invno
                SELECT QuotStk
                SET ORDER TO 2
                nQty := 0
                SEEK mpartnum
                DO WHILE QuotStk->Partnum = mpartnum .AND. QuotStk->( !Eof() )
                    nQty += QuotStk->Required - QuotStk->Received
                    SKIP ALIAS QuotStk
                ENDDO
                SELECT Part
                ApRLock( 3 )
                Part->ReqQty := nQty
                Part->Invno  := minvno
                UNLOCK
                AAdd( aPart_, SubStr( Part->Desc, 1, 28 );
                    + " " + SubStr( Part->Partnum, 1, 16 );
                    + " " + Str( Part->ReqQty, 9, 2 );
                    + " " + Str( Part->Instock, 9, 2 );
                    + " " + Str( mptot, 9, 2 );
                    + "     " + Str( RecNo(), 6 ) )
                SELECT QuotStk
            ENDDO                  // QuotStk
        ENDIF
        IF !Empty( aPart_ )
            Scroll()
            DispBox(  0, 1, 2, 79, 2 )
            @  1, 10 SAY "Parts Bought Out All Job Cards"
            Scroll(   3, 0, 24, 80 )
            DispBox(  3, 1, 24, 79, 2 )
            @  3, 3 SAY " Description                                    Out/QT     Instock  Ordered "
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice(  4, 3, 23, 77, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
            SELECT Part
            GOTO nrecno
            mpartnum := Part->Partnum
            Scroll(  18, 0, 24, 80 )
            DispBox( 18, 1, 21, 79, 2 )
            @ 19, 3 SAY Trim( Part->Partnum ) + " " + Trim( Part->Desc );
                + " " + Str( Part->ReqQty, 10, 2 ) + " " + Part->Codeno
            mcodeno := Part->Codeno
            SELECT Name
            SEEK mcodeno
            DO WHILE !Found()
                SAVE SCREEN TO holdscrn
                Namerank( @mcodeno )                       // XlF_Name
                IF LastKey() == 27
                    RETURN
                ENDIF
                SELECT Name
                SEEK mcodeno
                RESTORE SCREEN FROM holdscrn
                SELECT Part
                ApFLock( 3 )
                Part->Codeno := Name->Codeno
                UNLOCK
            ENDDO
        ENDIF                      // !EMPTY
        DispBox( 22, 1, 24, 79, 2 )
        nselect := 1
        @ 23, 10      PROMPT "Edit Part"
        @ 23, Col() + 3 PROMPT "Another Part"
        @ 23, Col() + 3 PROMPT "Print List"
        @ 23, Col() + 3 PROMPT "Add Order"
        @ 23, Col() + 3 PROMPT "Exit"
        MENU TO nselect
        DO CASE
        CASE nselect = 5 .OR. LastKey() == 27
            SELECT Quot
            SET INDEX TO QuotInd
            RETURN NIL
        CASE nselect == 2
            manother = "Y"
            LOOP
        CASE nselect == 3
            OrderPrnt()                      // Below
            manother = "Y"
            LOOP
        CASE nselect == 1
            ScrnOrd  := SaveScreen( 0, 0, 24, 80 )
            mpartnum := Part->Partnum
            Scroll( 3, 0, 24, 80 )
            DispBox( 3, 1, 24, 79, 2 )
            SELECT Orders
            SET ORDER TO 1                        // Partnum
            GOTO TOP
            SEEK mpartnum
            nTotal := 0
            IF Found()
                nll := 15
                DispBox( 14, 3, 22, 45, 2 )
                @ 14, 20 SAY " - Orders - " COLOR "BG+"
                DO WHILE Orders->Partnum = mpartnum .AND. Orders->( !Eof() )
                    @ nll, 5      SAY Orders->Ordnum
                    @ nll, Col() + 1 SAY Orders->Partqty PICTURE "9,999.999" COLOR "G+"
                    @ nll, Col() + 1 SAY Orders->QtyRec  PICTURE "9,999.999"
                    IF Orders->Length > 0
                        @ nll, Col() + 1 SAY "Length"
                        @ nll, Col() + 1 SAY Orders->Length  PICTURE "999.99"
                    ENDIF
                    nll++
                    nTotal += Orders->PartQty
                    SKIP ALIAS Orders
                ENDDO
                @ 23, 5      SAY Trim( mpartnum ) + " Ordered"
                @ 23, Col() + 1 SAY nTotal PICTURE "9,999.99" COLOR "G+"
            ENDIF                            // Found
            SELECT Part
            SET ORDER TO 1
            SEEK mpartnum
            mQty    := 0
            nlength := 0
            ncsarea := 0
            ndiscount := ncost := namount := nlinm := nrate := nvol := nlen := 0
            @  1, 5 SAY Part->Desc + " " + Trim( Part->Partnum ) + " " + Part->Unit COLOR "BG+"
            nl := 4
            @  nl, 5      SAY "In Stock"
            @  nl, Col() + 1 SAY Part->Instock PICTURE "99,999.99" COLOR "G+"
            @  nl, Col() + 1 SAY "Length Mtr"
            @  nl, Col() + 1 SAY Part->Length  PICTURE "999.999"
            @  nl, Col() + 1 SAY "Width mm"
            @  nl, Col() + 1 SAY Part->Width   PICTURE "999.999"
            @  nl, Col() + 2 SAY Part->Unit
            nl += 2
            SELECT Part
            ApRLock( 3 )
            nselect := 1
            DO CASE
            CASE Part->Unit = "Each      "
                nselect := 1
            CASE Part->Unit = "Mtr       "
                nselect := 2
            CASE Part->Unit = "Sq Mtr    "
                nselect := 3
            CASE Part->Unit = "Cu Mtr    "
                nselect := 4
            ENDCASE
            @ nl, 5      PROMPT "Each  "
            @ nl, Col() + 2 PROMPT "Mtr   "
            @ nl, Col() + 2 PROMPT "Sq Mtr"
            @ nl, Col() + 2 PROMPT "Cu Mtr"
            MENU TO nselect
            DO CASE
            CASE nselect == 1
                Part->Unit := "Each"
            CASE nselect == 2
                Part->Unit := "Mtr"
            CASE nselect == 3
                Part->Unit := "Sq Mtr"
            CASE nselect == 4
                Part->Unit := "Cu Mtr"
            ENDCASE
            UNLOCK
            nl += 2
            DO CASE
            CASE Part->Unit = "Sq Mtr    "
                nwidth    := Part->Width / 1000
                SELECT Part
                ApRLock( 3 )
                nvol  := Part->Instock / ( nwidth * Part->Length )
                ncost := Part->Trade * ( nwidth * Part->Length )
                ndiscount := 0
                @  nl, 6      SAY "Width in Mtr"  GET nwidth
                @  nl, Col() + 2 SAY "Length in Mtr" GET Part->Length
                nl += 2
                @  nl, 6      SAY "Sheets in Stock"  GET nvol      PICTURE "999999.99"
                READ
                mQty  := ( Part->Length * nwidth ) * nvol
                @ nl, 42 SAY "Sq Mtrs " + Str( mQty, 8, 2 )
                IF LastKey() == 27
                    UNLOCK
                    RETURN
                ENDIF
                Part->Width := nwidth * 1000   // Convert to mm
                UNLOCK

            CASE Part->Unit = "Cu Mtr    "
                nl++
                @  nl, 5      SAY "Volume Cu/M"   GET nvol   PICTURE "999.999"
                @  nl, Col() + 2 SAY "Rate per Cu/M" GET nrate  PICTURE "999.99"
                READ
                IF LastKey() == 27
                    RETURN
                ENDIF
                // * Calculate cross-section area in square metres
                ncsarea := ( Part->Width * Part->Thick ) / 1000000
                // * Calculate linear metres
                nlen := nvol / ncsarea
                // * Calculate cost per linear metre.
                // * Must allow for variable volume here  (Try various volumes for
                // *   same width & thickness - cost should be constant)
                ncost = ( nrate / nlen ) * nvol
                // * Wastage Factor 10%
                // * Show total linear & cost
                ncost := ncost * 1.1
                ncsarea := ( Part->Width * Part->Thick ) // cross sectional area in sq mm
                ncsarea := ncsarea / 1000000             // cross sectional area in sq metres
                // * ( Could combine above two lines into one calculation )
                mQty := nvol / ncsarea         // length in metres
                nl += 2
                @  nl, 5      SAY "Per Mtr+10% " + Str( ncost, 6, 3 ) COLOR "G+"
                @  nl, Col() + 1 SAY "Mtrs " + Str( nlen, 5 ) COLOR "G+"
                @  nl, Col() + 1 SAY "Length"   GET mQty      PICTURE "999999.99"
                READ
                IF LastKey() == 27
                    RETURN
                ENDIF

            CASE Part->Unit = "Mtr       "                 // Linear Mtr
                SELECT Part
                ApRLock( 3 )
                mQty := Part->Instock / Part->Length
                @ nl, 5      SAY "Length Each Mtr"  GET Part->Length PICTURE "9999.999"
                @ nl, Col() + 2 SAY "Qty of Lengths"   GET mQty         PICTURE "99999.99"
                READ
                UNLOCK
                mQty := Part->Length * mQty
                nl += 2
                @ nl, 5      SAY "Mtr Qty"
                @ nl, Col() + 2 SAY mQty PICTURE "99,999.99" COLOR "G+"
                IF LastKey() == 27
                    RETURN
                ENDIF

            CASE Part->Unit = "Each      "
                mQty := Part->Instock
                @  nl, 5 SAY "In Stock Qty" GET mQty PICTURE "999999.99"
                READ
                IF LastKey() == 27
                    RETURN
                ENDIF

            OTHERWISE
                mQty := Part->Instock
                @  nl, 5 SAY "In Stock Qty" GET mQty PICTURE "999999.99"
                READ
                IF LastKey() == 27
                    RETURN
                ENDIF
            ENDCASE
            SELECT Part
            ApRLock( 3 )
            nselect := 1
            DO CASE
            CASE Part->Boughtout = "Y"
                nselect := 1
            CASE Part->Boughtout = "N"
                nselect := 2
            ENDCASE
            nl += 2
            @ nl, 5      PROMPT "Part Bought Out"
            @ nl, Col() + 2 PROMPT "Own Manufacture"
            MENU TO nselect
            DO CASE
            CASE nselect == 1
                Part->Boughtout := "Y"
            CASE nselect == 2
                Part->Boughtout := "N"
            ENDCASE
            Part->Instock := mQty
            UNLOCK
            RestScreen(  0, 0, 24, 80, ScrnOrd )
            manother = "Y"
            LOOP
        CASE nselect = 4
            MenuB3()         // XLF_MenuB
            // **           OrdAdd( mcodeno )
            manother = "Y"
            LOOP
        ENDCASE
        manother := "N"
    ENDDO                       // manother
    SELECT Quot
    SET INDEX TO QuotInd

    RETURN

// ***--------- End OrderTot()

// *-------------------------------------------------------------------

FUNCTION OrderPrnt()

    Printsel()

    IF mwhere = "S"
        npl := 22
    ELSE
        npl := 62
    ENDIF
    mpTot := mSum := 0
    @  0, 0 SAY Control->U_Name + " Parts For ALL Job Cards"
    @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 0 SAY "Partnum             Desc"
    @  2, 44 SAY "Out/St   Ordered In Stock   From"
    nl := 4
    IF mwhere = "P"
        EndPrint()
    ELSE
        WAIT
    ENDIF

    RETURN

// ***--------- End OrderPrnt()

// *-------------------------------------------------------------------

FUNCTION OrdfrmChr()

    Scroll()

    // **  M_Exit  := " "
    // **  MPCOUNT := 0

    // **  @ 13,0 CLEAR
    // **  RELEASE MPCOUNT

    // **  Setprnt()

    SET DEVICE TO PRINT
    // **  SET MARGIN TO 3
    npl := 56
    // **  @  0, 0 SAY mpreset

    SELECT Orders
    SET ORDER TO 2
    SEEK mordnum                             // ORDERS
    mcodeno := Orders->Codeno
    mdat    := Orders->DATE                   // Easier to get this here
    mdat    := DToC( mdat )
    dReqDate := Orders->ReqDate
    SELECT Name
    SEEK Orders->Codeno
    nl := 14
    @ nl, 11 SAY Name->Name
    nl++
    @ nl, 11 SAY Name->Add1
    @ nl, 48 SAY "PURCHASE ORDER # ";
        + SubStr( Orders->Psno, 11, 2 ) + " " + mordnum
    nl++
    @ nl, 11 SAY Name->Add2
    nl++
    @ nl, 11 SAY Name->Add3
    @ nl, 40 SAY "Date " + mdat
    nl++
    @ nl, 11 SAY Name->Add4
    nl++
    @ nl, 11 SAY "Phone : " + Name->Phone
    @ nl, 37 SAY "Fax : "   + Name->Bphone
    nl++
    @ nl, 0 SAY Replicate( ".", 69 )
    nl++
    // **      @ 17, 0 SAY "Suppliers ID"
    @ nl, 26 SAY "Description"
    @ nl, 60 SAY "Order Qty"
    // **      @ 17,64 SAY "Price"
    nl++
    @ nl, 0 SAY Replicate( "-", 69 )
    nl += 2
    DO WHILE Orders->( !Eof() )
        SELECT Orders
        IF Orders->Partnum != Space( 20 )
            ApRLock( 3 )
            ntotal   := 0
            mpartnum := Orders->Partnum
            Orders->P_flag := .T.
            UNLOCK
            SELECT Part
            SET ORDER TO 1                        // Partnum
            SEEK mpartnum
            SELECT Supl
            SET ORDER TO 1                        // Partnum+Codeno
            mseek := mpartnum + Orders->Codeno
            SEEK mseek
            IF Found()
                @ nl, 0 SAY "." + SubStr( Supl->SuppId, 1, 14 )
                @ nl, 16 SAY SubStr( Part->Partnum, 1, 9 )
            ELSE
                IF SubStr( Part->Partnum, 1, 2 ) != "ZZ"
                    @ nl, 0 SAY Part->Partnum
                ENDIF
            ENDIF
            IF Part->Desc != Space( 40 )
                @ nl, 26 SAY SubStr( Part->Desc, 1, 34 )
            ELSE
                @ nl, 26 SAY "Supply as detailed below."
            ENDIF
            @ nl, 61 SAY Orders->Partqty PICTURE "99,999"
            DO CASE
            CASE Part->Unit == "Mtr       "
                // **            @ nl,64 SAY "@"+STR( Orders->Length, 6, 2 )+" "+TRIM( Part->Unit )
                nl++
                @ nl, 20 SAY "Order Length = " + Str( Orders->Length, 6, 2 ) + " " + Part->Unit
                // **         CASE Part->Unit == "Sq Mtr    "
                // **            @ nl,64 SAY "Sheets"
            ENDCASE
            nl++
            SELECT Orders
            IF Orders->Detail2 != Space( 40 )
                @ nl, 16 SAY Orders->Detail2
                nl++
            ENDIF
            IF Orders->Detail3 != Space( 40 )
                @ nl, 16 SAY Orders->Detail3
                nl++
            ENDIF
            IF Orders->Detail4 != Space( 40 )
                @ nl, 16 SAY Orders->Detail4
                nl++
            ENDIF
        ENDIF                   // Orders
        SKIP ALIAS Orders
        IF Orders->Ordnum != mordnum
            EXIT
        ENDIF
    ENDDO
    @  51, 0 SAY "Please Supply On " + DToC( dReqDate )
    @  52, 0 SAY Message->Order1
    @  53, 0 SAY Message->Order2
    @  54, 0 SAY Message->Order3
    @  55, 0 SAY Message->Order4
    @  56, 0 SAY Message->Order5
    @  57, 0 SAY Message->Order6
    // **  @   0, 0 SAY mpreset                 // `@ 0,0' forces page throw
    EndPrint()
    Scroll()
    // ** SET MARGIN TO 0

    RETURN NIL

// **----------- End OrdFrmChr()

// *-------------------------------------------------------------------

FUNCTION OrdLook( mcodeno )

    SELECT Orders
    SET ORDER TO 3                   // Codeno+Ordnum
    SEEK Name->Codeno
    IF Found()
        cdesc  := Space( 30 )
        cunit  := Space( 10 )
        nrecno := 0
        aPart_ := {}
        DO WHILE Orders->Codeno == Name->Codeno .AND. Orders->( !Eof() )
            IF Orders->PartIn >= Orders->PartQty
                SKIP ALIAS Orders
                LOOP
            ENDIF
            IF Orders->QtyRec >= Orders->PartQty
                SKIP ALIAS Orders
                LOOP
            ENDIF
            SELECT Part
            SET ORDER TO 1
            SEEK Orders->Partnum
            cdesc := SubStr( Orders->Detail1, 1, 38 )
            SELECT Orders
            IF cdesc = Space( 30 )
                cdesc := SubStr( Part->Desc, 1, 38 )
            ENDIF
            IF cdesc = Space( 30 )
                cdesc := SubStr( Orders->Detail2, 1, 38 )
            ENDIF
            DO CASE
            CASE Orders->Length > 0
                cunit := "Lengths   "
            CASE Part->Unit = "Sq Mtrs   "
                cunit := "Sheets    "
            OTHERWISE
                cunit := Part->Unit
            ENDCASE
            AAdd( aPart_, cdesc;
                + " " + Orders->Ordnum;
                + " " + DToC( Orders->Date );
                + " " + Str( Orders->PartQty, 8, 2 );
                + " " + Str( Orders->PartIn, 6 );
                + " " + Trim( cunit );
                + "       " + Str( RecNo(), 6 ) )
            SKIP ALIAS Orders
        ENDDO                  // Orders
        IF !Empty( aPart_ )
            @ 1, 5 SAY Name->Name
            Scroll(   3, 0, 24, 80 )
            DispBox(  3, 1, 24, 79, 2 )
            @  3, 3 SAY " - Parts On Order -" COLOR "G+"
            @  3, 50 SAY " -- Ordered Qty  Received -- "
            ASort( aPart_,,, {| x, y | x < y } )
            anum   := AChoice(  4, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
        ENDIF
        GOTO nrecno
        mordnum := Orders->Ordnum
        SET ORDER TO 1               // Partnum
    ENDIF                                // FOUND()

    RETURN( mordnum )

// **------- End of OrdLook()

// *-------------------------------------------------------------------


FUNCTION Setprnt()                      // Set `Public' Printer codes

    // ***** NOT USED NOW
    PUBLIC MPRESET, MPL51, MPL66, MPEXP1, MPEXPX, MPCOND, MPCONDX, MPELITE
    PUBLIC MPPICA, MPSUB, MPSUBX

    STORE Chr( 27 ) + Chr( 64 ) TO MPRESET          // Reset to standard
    STORE Chr( 27 ) + "C" + Chr( 51 ) TO MPL51      // Page length 51 lines
    STORE Chr( 27 ) + "C" + Chr( 66 ) TO MPL66      // Page length 66 lines
    STORE Chr( 14 ) TO MPEXP1                     // Double width chrs (1 line)
    STORE Chr( 20 ) TO MPEXPX                     // -- cancel --
    STORE Chr( 15 ) TO MPCOND                     // Condensed print
    STORE Chr( 18 ) TO MPCONDX                    // -- cancel --
    STORE Chr( 27 ) + "M" TO MPELITE              // Elite pitch
    STORE Chr( 27 ) + "P" TO MPPICA               // Pica pitch
    STORE Chr( 27 ) + "S" + Chr( 1 ) TO MPSUB       // Subscript
    STORE Chr( 27 ) + "T" TO MPSUBX               // - cancel -

    // *  End Function  --  SETPRNT

    // ******------------   END OF FILE CHRIORD1.PRG
