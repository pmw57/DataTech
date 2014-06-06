// **  JoKir10  22-10-11 07:18:32

/* Program.....:              CHRIORD2.PRG
   Author......: J.Kirby
   Date........: 01/09/1993
   Calls.......: Mu_Ord, OrdEdit, OrdStat,
                 OrdScrn, OrdAddP, StockTake
*/

FUNCTION OrdAddP( mpartnum )

    SELECT Part
    SET ORDER TO 1                     // Partnum
    SEEK mpartnum
    nlength := nMtrQty := 0
    ntotal := 0
    Scroll( 0, 0, 22, 80 )
    DispBox( 0, 1, 2, 79, 2 )
    IF mcodeno = Space( 8 )
        mcodeno := Part->Codeno
        @  1, 5 SAY mcodeno + " Order # " + mordnum
        SELECT Name
        SEEK mcodeno
    ELSE
        mcodeno := Name->Codeno                       // Needed Here
        @  1, 5 SAY Name->Name + " Order # " + mordnum
    ENDIF
    @  1, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    IF SubStr( mpartnum, 1, 2 ) != "ZZ"
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
                IF nll > 21
                    Inkey( 1 )
                    Scroll( 15, 4, 21, 44 )
                    nll := 15
                ENDIF
                @ nll, 5      SAY Orders->Ordnum
                @ nll, Col() + 1 SAY Orders->Partqty PICTURE "9,999.999" COLOR "G+"
                @ nll, Col() + 1 SAY Orders->QtyRec  PICTURE "9,999.999"
                // ** no space for this @ nll,COL()+1 SAY Orders->Length  PICTURE "999.99"
                @ nll, Col() + 1 SAY Orders->Date
                nll++
                nTotal += Orders->PartQty
                SKIP ALIAS Orders
            ENDDO
            @ 23, 3      SAY Trim( mpartnum )
            @ 23, Col() + 1 SAY nTotal PICTURE "99,999.99" COLOR "G+"
        ENDIF                            // Found
        DispBox( 3, 1, 24, 79, 2 )
        nl := 4
        @ nl, 3      SAY Trim( Part->Unit ) + " " + Trim( Part->Partnum );
            + " " + Trim( Part->Desc ) COLOR "BG+"
        @ nl, Col() + 2 SAY Part->Codeno
        nl++
        ncost := 0
        SELECT Supl
        SET ORDER TO 1                       // Partnum
        SEEK mpartnum
        IF Found()
            nls := 6
            DO WHILE Supl->Partnum == mpartnum .AND. Supl->( !Eof() )
                IF nls >= 13
                    nls :=  6
                    Inkey( 0 )
                    Scroll(  6, 40, 13, 78 )
                ENDIF
                @ nls, 40      SAY Supl->Codeno                 COLOR "G+"
                @ nls, Col() + 1 SAY Supl->Cost PICTURE "9999.99" COLOR "G+"
                @ nls, Col() + 1 SAY DToC( Supl->Date )
                IF Part->Unit = "Mtr      "
                    @ nls, Col() + 1 SAY Supl->Cost * Part->Length PICTURE "9999.99"
                ENDIF
                nls++
                ncost := Supl->Cost
                SKIP ALIAS Supl
            ENDDO                             // Supl
        ENDIF                                // Found()
        SELECT Part
        nselect := 1
        DO CASE
        CASE Part->Unit = "Each      "
            nselect := 1
        CASE Part->Unit = "Mtr       "
            nselect := 2
        CASE Part->Unit = "Sq Mtr    "
            nselect := 3
        ENDCASE
        @ nl, 6      PROMPT "Each  "
        @ nl, Col() + 2 PROMPT "Mtr   "
        @ nl, Col() + 2 PROMPT "Sq Mtr"
        MENU TO nselect
        ApRLock( 3 )
        DO CASE
        CASE nselect == 1
            Part->Unit := "Each"
        CASE nselect == 2
            Part->Unit := "Mtr"
        CASE nselect == 3
            Part->Unit := "Sq Mtr"
        ENDCASE
        UNLOCK
        Scroll(  6, 40, 13, 78 )
        @ nl, 36      SAY "Cost " + Trim( Part->Unit )
        @ nl, Col() + 1 SAY Part->Trade   PICTURE "$999,999.99"
        nl++
        mqty   := ntotal
        mtotal := 0
        DO CASE
        CASE Part->Unit = "Each "
            @ nl, 8 SAY Trim( Part->Unit ) + " Order Qty =";
                GET mqty PICTURE "99999.99"
            READ
            IF LastKey() == 27
                RETURN
            ENDIF
            mtotal := Part->Trade * mqty
        CASE Part->Unit = "Mtr     "
            Plength := Part->Length
            @ nl, 6      SAY "Part Length =" GET Plength PICTURE "9999.999"
            nlength := Part->Length
            @ nl, Col() + 2 SAY "This Order Length =" GET nlength PICTURE "9999.999"
            READ
            nl++
            mQty := mQty / nLength
            @ nl, 6      SAY "Qty Lengths ="  GET mqty PICTURE "99999.99"
            @ nl, Col() + 1 SAY ntotal        PICTURE "Mtrs 9999.99" COLOR "RG+"
            @ nl, Col() + 1 SAY mQty          PICTURE "Lengths 9999.99"
            READ
            @ nl, 60      SAY "Mtrs"
            @ nl, Col() + 1 SAY ( nlength * mqty ) PICTURE "99999.999"
            mtotal := ( Part->Trade * nlength ) * mqty

        CASE Part->Unit = "Sq Mtr "
            nlength := Part->Length
            ncost   := Part->Trade
            nwidth  := Part->Width / 1000
            nsqmtr  := nlength * nwidth
            // **              nvol   := Part->Instock/( nwidth*Part->Length )
            @  nl, 4      SAY "Length in Mtr" GET nlength PICTURE "9999.999"
            @  nl, Col() + 2 SAY "Width in Mtr"  GET nwidth  PICTURE "9999.999"
            nl++
            nvol := ntotal / ( nwidth * nlength )
            @ nl, 4      SAY "Sheets Order"  GET nvol      PICTURE "999999.99"
            @ nl, Col() + 1 SAY ntotal / ( nwidth * nlength );
                PICTURE "99,999.99" COLOR "G+"
            @ nl, Col() + 1 SAY Part->Width / 1000 PICTURE "9,999.999"
            @ nl, Col() + 1 SAY Part->Length     PICTURE "9,999.999"
            READ
            IF LastKey() == 27
                RETURN NIL
            ENDIF
            mQty    := nvol
            nMtrQty := ( nwidth * nlength ) * nvol
            @ nl, 61      SAY "Sq Mtrs"
            @ nl, Col() + 1 SAY nMtrqty PICTURE "99,999.99"
            mtotal := (  Part->Trade * ( nwidth * nlength ) ) * nvol
        ENDCASE
        mqtytotal += mqty
        nl++
        IF mqty > 0
            mdetail1 := Part->Desc
            mdetail2 := Space( 40 )
            mdetail3 := Space( 40 )
            mdetail4 := Space( 40 )
            cjsno := Space( 6 )
            cinit := Space( 2 )
            cinfo := Space( 7 )
            dreqdate := Date() + 10
            IF ncost = 0
                ncost := Part->Trade
            ENDIF
            @ nl, 10      SAY "Price of Part" GET ncost PICTURE "99999.99"
            @ nl, Col() + 2 SAY "Zero if Price Not Wanted" COLOR "BG+"
            nl++
            @ nl, 4      GET mdetail1
            @ nl, Col() + 1 SAY "Specific this Order"
            nl++
            @ nl, 4      GET mdetail2
            @ nl, Col() + 6 SAY Part->Codeno
            nl++
            @ nl, 4      GET mdetail3
            @ nl, Col() + 2 SAY "Cost*Qty" COLOR "RG+"
            @ nl, Col() + 1 SAY ncost * mQty PICTURE "999,999.99" COLOR "RG+"
            nl++
            @ nl, 4      GET mdetail4
            @ nl, Col() + 1 SAY "Init" GET cinit        PICTURE "@K!"
            @ nl, Col() + 1 SAY "Req Date" GET dreqDate PICTURE "99/99/9999"
            nl++
            READ
            SELECT Orders
            ApFLock( 3 )
            APPEND BLANK
            Orders->Partnum := Part->Partnum
            Orders->Amount  := ncost
            Orders->Date    := Date()
            Orders->Ordnum  := mordnum
            Orders->Partqty := mqty
            Orders->Length  := nlength
            Orders->Codeno  := Name->Codeno
            Orders->Stat    := "O"
            Orders->ReqDate := dreqdate
            Orders->Jobnum  := cinit
            Orders->Detail1 := mdetail1
            Orders->Detail2 := mdetail2
            Orders->Detail3 := mdetail3
            Orders->Detail4 := mdetail4
            UNLOCK
            IF LastKey() == 27
                RETURN NIL
            ENDIF
        ENDIF                    // > 0
        DO CASE
        CASE Part->Unit = "Mtr     "
            mQty := mQty * nlength
        CASE Part->Unit = "Sq Mtr  "
            mQty := nMtrQty
        ENDCASE
    ENDIF

    RETURN

// **----------------End OrdAddP

// *-------------------------------------------------------------------

FUNCTION StockTake()

    mQty    := 0
    nlength := 0
    ncsarea := 0
    ndiscount := ncost := namount := nlinm := nrate := nvol := nlen := 0
    Scroll()
    manother = "Y"
    DO WHILE manother = "Y"
        mpartnum := Space( 20 )

        PartFind( mpartnum )

        mpartnum := Part->Partnum
        Scroll( 3, 0, 24, 80 )
        DispBox( 3, 1, 24, 79, 2 )
        nl := 4
        @  nl, 5 SAY Part->Unit + " " + Part->Desc + " " + Trim( Part->Partnum ) COLOR "BG+"
        nl += 2
        SELECT Part
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
        ApRLock( 3 )
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
        @  nl, 39      SAY "Stock"
        @  nl, Col() + 1 SAY Part->Instock PICTURE "99,999.99"
        @  nl, Col() + 2 SAY "Cost"
        @  nl, Col() + 1 SAY Part->Trade  PICTURE "$99,999.99"
        @  nl, Col() + 1 SAY Part->Length PICTURE "999.99"
        nl += 2
        DO CASE
        CASE Part->Unit = "Sq Mtr    "
            SELECT Part
            nvol      := Part->Instock / ( nwidth * Part->Length )
            ncost     := Part->Trade * ( nwidth * Part->Length )
            nlength   := Part->Length
            nwidth    := Part->Width / 1000
            ndiscount := 0
            @  nl, 6      SAY "Width in Mtr"  GET nwidth
            @  nl, Col() + 2 SAY "Length in Mtr" GET nlength
            nl += 2
            @  nl, 6      SAY "Sheets in Stock"  GET nvol      PICTURE "999999.99"
            READ
            mQty  := ( Part->Length * nwidth ) * nvol
            @ nl, 42 SAY "Sq Mtrs " + Str( mQty, 8, 2 )
            IF LastKey() == 27
                RETURN
            ENDIF
            ApRLock( 3 )
            Part->Width  := nwidth * 1000   // Convert to mm
            Part->Length := nlength
            UNLOCK

        CASE Part->Unit = "Cu Mtr    "
            nl++
            @  nl, 6      SAY "Volume Cu/M"   GET nvol   PICTURE "999.999"
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
            @  nl, 6      SAY "Per Mtr+10% " + Str( ncost, 6, 3 ) COLOR "G+"
            @  nl, Col() + 1 SAY "Mtrs " + Str( nlen, 5 ) COLOR "G+"
            @  nl, Col() + 1 SAY "Length"   GET mQty      PICTURE "999999.99"
            READ
            IF LastKey() == 27
                RETURN
            ENDIF

        CASE Part->Unit = "Mtr       "                 // Linear Mtr
            SELECT Part
            nlength := Part->Length
            mQty    := Part->Instock / Part->Length
            @ nl, 6      SAY "Length Each"  GET nlength
            @ nl, Col() + 2 SAY "Qty Lengths"  GET mQty      PICTURE "999999.99"
            READ
            mQty := Part->Length * mQty
            nl++
            @ nl, 6      SAY "    Mtr Qty"  GET mQty      PICTURE "999999.99"
            READ
            ApRLock( 3 )
            Part->Length := nlength
            UNLOCK
            IF LastKey() == 27
                RETURN
            ENDIF

        CASE Part->Unit = "Each      "
            mQty := Part->Instock
            @  nl, 6      SAY "Qty"      GET mQty      PICTURE "999999.99"
            READ
            IF LastKey() == 27
                RETURN
            ENDIF

        OTHERWISE
            mQty := Part->Instock
            nl += 2
            @  nl, 6 SAY "Qty" GET mQty      PICTURE "999999.99"
            READ
            IF LastKey() == 27
                RETURN
            ENDIF
        ENDCASE
        Scroll( nl + 1, 2, 23, 78 )
        DispBox( 3, 1, 24, 79, 2 )
        SELECT Part
        nselect := 1
        DO CASE
        CASE Part->Boughtout = "Y"
            nselect := 1
        CASE Part->Boughtout = "N"
            nselect := 2
        ENDCASE
        nl += 2
        @ nl, 6      PROMPT "Part Bought Out"
        @ nl, Col() + 2 PROMPT "Own Manufacture"
        MENU TO nselect
        ApRLock( 3 )
        DO CASE
        CASE nselect == 1
            Part->Boughtout := "Y"
        CASE nselect == 2
            Part->Boughtout := "N"
        ENDCASE
        Part->Instock := mQty
        UNLOCK
        manother := "Y"
        IF LastKey() == 27
            RETURN NIL
        ENDIF
    ENDDO                                              // manother

    RETURN

// **------- StockTake()

// ***-------------------------------------------------------------------

FUNCTION Mu_Ord()

    // ** DO XL_Order
    // *** ORDCHKNDX()

    DO WHILE .T.
        SELECT Name
        ApFLock( 3 )
        Name->Status := "Y"
        UNLOCK
        nselect  := 0
        nc       := ncl * 2
        Scroll( 3, nc, 21, 78 )
        @  4, nc TO 21, nc + ncl
        Scroll( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  3, nc + 4 TO 5, nc + ( ncl - 4 )
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( Menu2->CH_OrdHd ) ) / 2 );
            SAY RTrim( Menu2->CH_OrdHd )
        @  6, nc + 4 SAY "Next O/N # " + Str( ( Control->LastOrd + 1 ), 4 )
        @  7, nc + 2 PROMPT Menu2->CH_Ord1
        @  9, nc + 2 PROMPT Menu2->CH_Ord2
        @ 11, nc + 2 PROMPT Menu2->CH_Ord3
        @ 13, nc + 2 PROMPT Menu2->CH_Ord4
        @ 15, nc + 2 PROMPT "5. Stock Take  Entry "
        @ 17, nc + 2 PROMPT "6. Part ABC Menu"
        @ 20, nc + 2 PROMPT Menu->CH_Main
        MENU TO nselect

        DO CASE
        CASE nselect == 7 .OR. LastKey() == 27
            RETURN NIL
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            MenuB3()                  // XLF_MenuB
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            Ordarr()                          // Below
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            Ordlist()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            Mu_Prof( nc, ncl )
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5
            SAVE SCREEN TO holdscrn
            StockTake()                         // XLF_Ord Above
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            MenuB3()     // XLF_MenuB
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// ***----- End of Mu_Ord

// *-------------------------------------------------------------------

FUNCTION OrdEdit( mordnum )

    aPart_ := {}
    nrecno    := 0
    SELECT Orders
    SET ORDER TO 2                          // Ordnum
    GOTO TOP
    SEEK mordnum
    DO WHILE Orders->Ordnum = mordnum .AND. Orders->( !Eof() )
        SELECT Part
        SEEK Orders->Partnum
        SELECT Orders
        IF Orders->Detail1 = "    "
            mdesc := SubStr( Part->Desc, 1, 34 )
        ELSE
            mdesc := SubStr( Orders->Detail1, 1, 34 )
        ENDIF
        AAdd( aPart_, SubStr( Orders->Partnum, 1,16 );
            + " " + mdesc;
            + " " + Str( Orders->PartQty, 8, 2 );
            + " " + Str( Orders->Amount, 8, 2 );
            + " " + Trim( Part->Unit );
            + "               " + Str( RecNo(), 6 ) )
        SKIP ALIAS Orders
    ENDDO
    Scroll()
    DispBox( 0, 1,  2, 79, 2 )
    @  1, 5      SAY Name->Name
    @  1, Col() + 2 SAY "O/N " + mordnum COLOR "BG+"
    @  1, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    DispBox( 3, 1, 24, 79, 2 )
    IF !Empty( aPart_ )
        anum := AChoice( 4, 3, 22, 78, aPart_,, "AFUNC" )
        IF LastKey() == 27
            RETURN
        ENDIF
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        SELECT Orders
        GOTO nrecno
        mpartnum := Orders->Partnum
        SELECT Part
        SEEK mpartnum
    ENDIF
    @  1, 68 SAY DToC( Orders->Date )
    Scroll(   3, 0, 24, 80 )
    DispBox(  3, 1, 24, 79, 2 )
    nl := 4
    @ nl, 3      SAY Trim( Part->Unit ) + " " + Trim( Orders->Partnum )
    @ nl, Col() + 3 SAY Trim( Part->Desc ) COLOR "BG+"
    nl++
    IF Part->Unit == "Mtr       "
        @ nl, 18      SAY "Ord Length"
        @ nl, Col() + 1 SAY Orders->Length  PICTURE "9999.999"
    ENDIF
    @ nl, 40      SAY "Qty"
    @ nl, Col() + 1 SAY Orders->PartQty PICTURE "99,999.99"
    nl += 2
    SELECT Part
    nselect := 1
    DO CASE
    CASE Part->Unit = "Each      "
        nselect := 1
    CASE Part->Unit = "Mtr       "
        nselect := 2
    CASE Part->Unit = "Sq Mtr    "
        nselect := 3
    ENDCASE
    @ nl, 8      PROMPT "Each  "
    @ nl, Col() + 2 PROMPT "Mtr   "
    @ nl, Col() + 2 PROMPT "Sq Mtr"
    MENU TO nselect
    ApFLock( 3 )
    DO CASE
    CASE nselect == 1
        Part->Unit := "Each"
    CASE nselect == 2
        Part->Unit := "Mtr"
    CASE nselect == 3
        Part->Unit := "Sq Mtr"
    ENDCASE
    UNLOCK
    @ nl, 32      SAY "Cost =" + Trim( Part->Unit )
    @ nl, Col() + 1 SAY Part->Trade   PICTURE "$999,999.99"
    @ nl, Col() + 2 SAY "Stock ="
    @ nl, Col() + 1 SAY Part->Instock PICTURE "99,999.999"
    nl++
    mqty := mtotal := 0
    DO CASE
    CASE Part->Unit = "Each "
        nl++
        @ nl, 20 SAY "0 To Delete this Order Qty"
        nl += 2
        SELECT Orders
        npartqty := Orders->PartQty
        @ nl, 10 SAY Trim( Part->Unit ) + " Order Qty =";
            GET npartQty PICTURE "99999.99"
        READ
        ApRLock( 3 )
        Orders->PartQty := npartqty
        UNLOCK
        mQty := Orders->PartQty
        mtotal := Part->Trade * Orders->PartQty
    CASE Part->Unit = "Mtr     "
        SELECT Part
        nlength := Part->Length
        @ nl, 10      SAY "Part Length =" GET nlength PICTURE "9999.999"
        READ
        ApRLock( 3 )
        Part->Length := nlength
        UNLOCK
        SELECT Orders
        nlength  := Orders->Length
        npartqty := Orders->PartQty
        @ nl, 36 SAY "This Order Length =" GET nlength PICTURE "9999.999"
        nl += 2
        @ nl, 20 SAY "0 To Delete this Qty Lengths"
        nl += 2
        @ nl, 10 SAY "Qty Lengths ="       GET npartqty PICTURE "99999.99"
        READ
        ApRLock( 3 )
        Orders->Length  := nlength
        Orders->PartQty := npartqty
        UNLOCK
        @ nl, 35      SAY "In Mtrs ="
        @ nl, Col() + 1 SAY ( Orders->Length * Orders->PartQty ) PICTURE "99999.99" COLOR "G+"
        mtotal := ( Part->Trade * Orders->Length ) * Orders->Partqty
    CASE Part->Unit = "Sq Mtr "
        SELECT Part
        ncost   := Part->Trade
        nwidth  := Part->Width / 1000
        nlength := Part->Length
        @  nl, 8      SAY "Length in Mtr" GET nlength PICTURE "9999.999"
        @  nl, Col() + 2 SAY "Width in Mtr"  GET nwidth  PICTURE "9999.999"
        READ
        ApRLock( 3 )
        Part->length := nlength
        Part->Width  := nwidth * 1000   // Convert to mm
        UNLOCK
        SELECT Orders
        nl += 2
        npartqty := Orders->PartQty
        @ nl, 20 SAY "0 To Delete this Sheets Order"
        nl += 2
        @  nl, 8      SAY "Sheets Order"  GET npartqty PICTURE "999999.99"
        READ
        ApRLock( 3 )
        Orders->PartQty := npartqty
        UNLOCK
        nMtrQty  := ( nwidth * Part->Length ) * Orders->PartQty
        @ nl, 35      SAY "Sq Mtrs"
        @ nl, Col() + 1 SAY nMtrQty PICTURE "99999.99" COLOR "G+"
        mtotal := (  Part->Trade * ( nwidth * Part->Length ) ) * Orders->PartQty
    ENDCASE
    IF Orders->PartQty == 0
        SELECT Orders
        ApRLock( 3 )
        DELETE
        UNLOCK
        RETURN
    ENDIF
    SELECT Part
    mqtytotal += mQty
    @ nl, 54      SAY "Cost ="
    @ nl, Col() + 1 SAY mtotal PICTURE "$999,999.99"
    IF LastKey() == 27
        RETURN
    ENDIF
    nl += 2
    mdesc := Part->Desc
    @ nl, 9 SAY "Desc" GET mdesc
    nl++
    READ
    ApRLock( 3 )
    Part->Desc := mdesc
    UNLOCK
    SELECT Orders
    mdetail1 := Orders->Detail1
    mdetail2 := Orders->Detail2
    mdetail3 := Orders->Detail3
    mdetail4 := Orders->Detail4
    mpsno    := Orders->Psno
    dreqdate := Orders->ReqDate
    namount  := Orders->Amount
    nqtyrec  := Orders->QtyRec
    npartin  := Orders->PartIn
    @ nl, 20 SAY "Specific this Order Description"
    nl++
    @ nl, 5 SAY "Info"
    @ nl, 10 GET mdetail1
    nl++
    @ nl, 10 GET mdetail2
    nl++
    @ nl, 10 GET mdetail3
    nl++
    @ nl, 10 GET mdetail4
    nl += 2
    @ nl, 10      SAY "Estimated Cost =" GET namount PICTURE "99999.99"
    nl++
    @ nl, 10      SAY "Ref"      GET mpsno
    @ nl, Col() + 1 SAY "Dated"    GET dreqdate PICTURE "99/99/9999"
    nl++
    @ nl, 10      SAY "Recieved" GET nqtyrec
    // **           @ nl,COL()+2 SAY "IN"       GET npartin
    IF Orders->Length > 0
        @ nl, Col() + 1 SAY "Ord Length"
        @ nl, Col() + 1 SAY Orders->Length PICTURE "999.99"
    ENDIF
    READ
    ApRLock( 3 )
    Orders->Detail1 := mdetail1
    Orders->Detail2 := mdetail2
    Orders->Detail3 := mdetail3
    Orders->Detail4 := mdetail4
    Orders->Psno    := mpsno
    Orders->ReqDate := dreqdate
    Orders->Amount  := namount
    Orders->QtyRec  := nqtyrec
    Orders->PartIn  := npartin
    UNLOCK
    COMMIT

    RETURN

// **-----End of OrdEdit()

// *-------------------------------------------------------------------

FUNCTION OrdScrn( mordnum )

    Scroll()
    mtotal := mordtot := 0
    @  1, 1 SAY Trim( Name->Name )
    SELECT Orders
    SET ORDER TO 2                                 // Ordnum Index
    SEEK mordnum
    @  1, 50 SAY "O/N " + mordnum
    @  1, 62 SAY DToC( Orders->Date )
    @  2, 0 SAY "Part Number"
    @  2, 25 SAY "Description"
    @  2, 51 SAY "Order Qty"
    @  2, 66 SAY "Amount"
    @  3, 0 SAY Replicate( "-", 80 )
    nl := 4
    DO WHILE Orders->Ordnum = mordnum .AND. Orders->( !Eof() )
        SELECT Orders
        mpartnum := Orders->Partnum
        IF nl > 20
            nl := 4
            ?
            WAIT
            Scroll( nl, 0, 24, 80 )
        ENDIF
        IF Partnum != Space( 20 )
            @ nl, 0 SAY SubStr( Orders->Partnum, 1, 12 )
            SELECT Part
            SEEK mpartnum
            IF Part->Desc != Space( 40 )
                @ nl, 15 SAY SubStr( Part->Desc, 1, 35 )        // Revert to Part file
            ELSE
                @ nl, 18 SAY "Supply as detailed below."
            ENDIF
            DO CASE
            CASE Part->Unit = "Each "
                mtotal := Part->Trade * Orders->Partqty
            CASE Part->Unit = "Mtr  "
                mtotal := ( Part->Trade * Orders->Length ) * Orders->Partqty
            CASE Part->Unit = "Sq Mtr "
                mtotal := ( ( Part->Trade / ( Part->Width / 1000 );
                    // Part->Length ) )*Orders->Partqty
            ENDCASE
            SELECT Orders
            cunit := Space( 10 )
            DO CASE
            CASE Orders->Length > 0
                cunit := "Lengths   "
            CASE Part->Unit = "Sq Mtr "
                cunit := "Sheets    "
            OTHERWISE
                cunit := Part->Unit
            ENDCASE
            @ nl, 51 SAY Orders->PartQty PICTURE "99,999.99"
            @ nl, 62 SAY Orders->Amount  PICTURE "99,999.99"
            mordtot += mtotal
            @ nl, 72 SAY cunit
            SELECT Supl
            SET ORDER TO 1                        // Partnum+Codeno
            SEEK Orders->Partnum + Orders->Codeno
            IF Found()
                IF Supl->SuppId != Space( 16 )
                    IF Supl->SuppId != SubStr( Part->Partnum, 1, 16 )
                        nl++
                        @ nl, 20 SAY Supl->SuppId
                        @ nl, 50 SAY Supl->Cost
                    ENDIF
                ENDIF            // SPACE( 16 )
            ENDIF               // Found
            nl++
            IF Part->Unit == "Mtr  "
                @ nl, 22 SAY "Order Length Mtrs " + Str( Orders->Length, 6, 2 )
                nl++
            ENDIF
            IF Orders->Detail1 != Part->Desc
                @ nl, 15 SAY Orders->Detail1
                nl++
            ENDIF
            IF Orders->Detail2 != Space( 40 )
                @ nl, 15 SAY Orders->Detail2
                nl++
            ENDIF
            IF Orders->Detail3 != Space( 40 )
                @ nl, 15 SAY Orders->Detail3
                nl++
            ENDIF
            IF Orders->Detail4 != Space( 40 )
                @ nl, 15 SAY Orders->Detail4
                nl++
            ENDIF
        ENDIF                           // Partnum
        SKIP ALIAS Orders
    ENDDO
    nl++
    @ nl, 8      SAY "Trade Total Order Value"
    @ nl, Col() + 2 SAY mordtot PICTURE "$999,999.99" COLOR "BG+"
    WAIT

    RETURN

// *** End of OrdScrn()

// ******-----------------   END OF CHRIORD2.PRG
