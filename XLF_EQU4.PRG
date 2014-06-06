// ** JKir02 NotePad++

// ** Made K for Cut Lengths

/*
   Program.....:                  XLF_EQU4.PRG
   Authors.....: J.Kirby
   Date........: 22/10/1995
   Functions...: EquCopy, EquPartAdd, EquCutEach, EquLook
                 EquCutList, EquCut
*/

FUNCTION EquCopy( mpartnum )

    SELECT Part
    SEEK mpartnum
    ncount := 0
    mmod := Space( 16 )
    Scroll()
    DispBox( 0, 1, 2, 79, 2 )
    SELECT Part
    @ 1, 10 SAY Part->Partnum + " " + Part->Desc
    mpartnum := Part->Partnum
    mfind := SubStr( mpartnum, 1, 16 )      // Need this here
    DispBox( 3, 1, 24, 79 )
    @ 3, 20 SAY "  --- SELECT Module to Copy --- "
    mselect := "    "
    @ 6, 10 SAY "Select Exact First 4 Letters Blank for all" GET mselect PICTURE "@!X"
    READ
    aPart_ := {}
    anum   := {}
    nrecno := 0
    @ 6, 10 SAY "                                                 "
    SELECT EquDesc
    GOTO TOP
    DO WHILE EquDesc->( !Eof() )
        IF mselect != "    "
            DO CASE
            CASE SubStr( mselect, 2, 3 ) = "   "
                IF SubStr( EquDesc->Modcode, 1, 1 ) != SubStr( mselect, 1, 1 )
                    SKIP ALIAS EquDesc
                    LOOP
                ENDIF
            CASE SubStr( mselect, 3, 2 ) = "  "
                IF SubStr( EquDesc->Modcode, 1, 2 ) != SubStr( mselect, 1, 2 )
                    SKIP ALIAS EquDesc
                    LOOP
                ENDIF
            CASE SubStr( mselect, 4, 1 ) = " "
                IF SubStr( EquDesc->Modcode, 1, 3 ) != SubStr( mselect, 1, 3 )
                    SKIP ALIAS EquDesc
                    LOOP
                ENDIF
            CASE mselect != "    "
                IF SubStr( EquDesc->Modcode, 1, 4 ) != SubStr( mselect, 1, 4 )
                    SKIP ALIAS EquDesc
                    LOOP
                ENDIF
            ENDCASE
        ENDIF
        AAdd( aPart_, EquDesc->ModCode;
            + " " + EquDesc->Desc;
            + " " + EquDesc->EquId;
            + "          " + Str( RecNo(), 6 ) )
        SKIP ALIAS EquDesc
    ENDDO                       // EOF()
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice(  4, 3, 23, 78, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ], 6 ) )
        GOTO nrecno
        mmod := EquDesc->Modcode
    ENDIF
    SELECT Equ
    GOTO TOP
    ApFLock( 3 )
    REPLACE ALL Equ->EquPart WITH " "
    UNLOCK
    ccopyall := ApGetN( "Copy All the Parts " + mmod )
    IF ccopyall = "Y"
        Scroll(  3, 1, 24, 80 )
        DispBox( 3, 1, 24, 79, 2 )
        nl := 4
        SELECT Equ
        GOTO TOP
        SEEK mmod
        IF Found()
            ccopycuts := "Y"
            // ** ApGetN( "Part Cuts Copy "+mmod )
            DO WHILE Equ->Modcode = mmod .AND. Equ->( !Eof() )
                IF Equ->EquPart = "Y"
                    SKIP ALIAS Equ
                    LOOP
                ENDIF
                SELECT Equ
                ApRLock( 3 )
                Equ->EquPart := "Y"
                UNLOCK
                mpart     := Equ->Partnum
                nQty      := Equ->PartQty
                mEquSeqno := Equ->ModSeqno
                ApFLock( 3 )
                APPEND BLANK
                Equ->Modcode  := SubStr( mpartnum, 1, 16 )
                Equ->Partnum  := mpart
                Equ->PartQty  := nQty
                Equ->ModSeqno := SubStr( mpartnum, 1, 16 ) + Str( RecNo(), 6 )
                Equ->ModTemp  := SubStr( mpartnum, 1, 16 ) + Str( RecNo(), 6 )
                Equ->EquPart  := "Y"
                UNLOCK
                @ nl, 3 SAY mpartnum + " " + mmod + " " + mpart
                nl++
                IF nl > 22
                    WAIT    // INKEY( 2 )
                    Scroll(  3, 1, 24, 80 )
                    DispBox( 3, 1, 24, 79, 2 )
                    nl := 4
                ENDIF
                cn := 0
                cModSeqno := Equ->ModSeqno
                IF ccopycuts = "Y"
                    SELECT EquCut
                    GOTO TOP
                    SEEK mEquSeqno
                    IF Found()
                        ncount := 0
                        // **         DO WHILE EquCut->Partnum = mpart .AND. EquCut->( !EOF() )
                        DO WHILE EquCut->Modseqno = mEquSeqno .AND. EquCut->( !Eof() )
                            ncount++
                            IF ncount > 200
                                @ 22, 10 SAY "MORE THAN 200 CUTS Will retreat"
                                WAIT
                                ncount := 0
                                RETURN mpartnum
                            ENDIF                    // ncount
                            nRecno  := RecNo()
                            mLength := EquCut->Length
                            mWidth  := EquCut->Width
                            mQty    := EquCut->Qty
                            mModRef := EquCut->ModRef
                            SELECT EquCut
                            ApFLock( 3 )
                            // **            EquCut->Modseqno := Equ->Modseqno
                            APPEND BLANK
                            EquCut->Modseqno := cModSeqno
                            EquCut->ModTemp  := cModSeqno
                            EquCut->Partnum  := mpart
                            EquCut->Length   := mlength
                            EquCut->Width    := mwidth
                            EquCut->Qty      := mQty
                            EquCut->ModRef   := mModRef
                            EquCut->Date     := Date()
                            UNLOCK
                            GOTO nRecno
                            cn++
                            @ nl, 66      SAY "Copied Cuts"
                            @ nl, Col() + 1 SAY cn PICTURE "999"
                            SKIP ALIAS EquCut
                        ENDDO
                    ENDIF            // ccopycuts
                ENDIF
                SELECT Equ
                SEEK mmod
            ENDDO

        ENDIF       // Found
        Inkey( 2 )

    ELSE                          // ccopyall
        mok := "Y"
        DO WHILE mok = "Y"
            aPart_ := {}
            anum   := {}
            nrecno := 0
            SELECT Equ
            SEEK mmod
            DO WHILE Equ->Modcode = mmod .AND. Equ->( !Eof() )
                Scroll( 4, 3, 18, 68 )
                IF Equ->EquPart = "Y"
                    SKIP ALIAS Equ
                    LOOP
                ENDIF
                SELECT Part
                SEEK Equ->Partnum
                SELECT Equ
                AAdd( aPart_, Equ->ModCode;
                    + " " + SubStr( Equ->Partnum, 1, 16 );
                    + " " + Part->Desc;
                    + "       " + Str( RecNo(), 6 ) )
                SKIP ALIAS Equ
            ENDDO                       // EOF() Equ
            cn := 0
            IF !Empty( aPart_ )
                Scroll(  3, 1, 24, 80 )
                DispBox( 3, 1, 19, 69, 2 )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice(  4, 3, 18, 68, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                ApRLock( 3 )
                Equ->EquPart := "Y"
                UNLOCK
                mpart := Equ->Partnum
                nQty  := Equ->PartQty
                mEquSeqno := Equ->ModSeqno
                maccept := ApGetY( "Copy Part" )
                IF maccept = "Y"
                    ccopycuts := "Y"
                    // ** ApGetN( "Part Cuts Copy "+mmod )  // no good Qty is part of cuts
                    SELECT Equ
                    ApFLock( 3 )
                    APPEND BLANK
                    Equ->Modcode  := SubStr( mpartnum, 1, 16 )
                    Equ->Partnum  := mpart
                    Equ->PartQty  := nQty
                    Equ->ModSeqno := SubStr( mpartnum, 1, 16 ) + LTrim( Str( RecNo(), 6 ) )
                    Equ->EquPart  := "Y"
                    UNLOCK
                    cModSeqno := SubStr( mpartnum, 1, 16 ) + LTrim( Str( RecNo(), 6 ) )
                    IF ccopycuts = "Y"
                        SELECT EquCut
                        GOTO TOP
                        SEEK mEquSeqno
                        nl := 10
                        IF Found()
                            Scroll(  nl, 0, 24, 80 )
                            DispBox( nl, 1, 19, 79, 2 )
                            nl++
                            @ nl, 3      SAY  mEquSeqno        // mpart+"    "+mpartnum
                            @ nl, Col() + 2 SAY "Copying Cut List"
                            nl++
                            ncount := 0
                            // **        DO WHILE EquCut->Partnum = mmpart .AND. EquCut->( !EOF() )
                            DO WHILE EquCut->Modseqno = mEquSeqno .AND. EquCut->( !Eof() )
                                ncount++
                                IF ncount > 200
                                    @ 22, 10 SAY "MORE THAN 200 CUTS Will retreat"
                                    WAIT
                                    ncount := 0
                                    RETURN mpartnum
                                ENDIF                    // ncount
                                @ nl, 3      SAY "Qty"
                                @ nl, Col() + 1 SAY EquCut->Qty
                                @ nl, Col() + 1 SAY EquCut->ModRef
                                @ nl, Col() + 1 SAY "Length"
                                @ nl, Col() + 1 SAY EquCut->Length
                                @ nl, Col() + 1 SAY "Width"
                                @ nl, Col() + 1 SAY EquCut->Width
                                nRecno  := RecNo()
                                mLength := EquCut->Length
                                mWidth  := EquCut->Width
                                mQty    := EquCut->Qty
                                mModRef := EquCut->ModRef
                                SELECT EquCut
                                ApFLock( 3 )
                                APPEND BLANK
                                EquCut->Modseqno := cModSeqno
                                EquCut->ModTemp  := cModSeqno
                                EquCut->Partnum  := mpart
                                EquCut->Length   := mlength
                                EquCut->Width    := mwidth
                                EquCut->Qty      := mQty
                                EquCut->ModRef   := mModRef
                                EquCut->Date     := Date()
                                UNLOCK
                                cn++
                                @ nl, Col() + 1 SAY cn PICTURE "99"
                                GOTO nRecno
                                Inkey( 1 )
                                nl++
                                SKIP ALIAS EquCut
                            ENDDO
                        ENDIF         // ccopycuts
                    ENDIF                                       // Found
                    npl := 3
                    mfind := SubStr( mpartnum, 1, 16 )
                    SELECT Equ
                    SEEK mfind
                    DO WHILE Equ->Modcode = mfind .AND. Equ->( !Eof() )
                        IF npl > 23
                            Inkey( 1 )
                            npl := 3
                        ENDIF
                        @ npl, 71 SAY SubStr( Equ->Partnum, 1, 9 ) COLOR "BG+"
                        npl++
                        SKIP ALIAS Equ
                    ENDDO
                    SEEK mmod
                ENDIF             // ! EMPTY
            ENDIF
            mok := ApGetY( "Another Part Required" )
        ENDDO

    ENDIF        // ccopyall

    SELECT Equ
    GOTO TOP
    ApFLock( 3 )
    REPLACE ALL Equ->EquPart WITH " "
    UNLOCK

    SELECT EquDesc
    SEEK mfind
    mmodcode := EquDesc->Modcode
    SELECT Part
    SEEK mpartnum
    mpartnum := Part->Partnum

    RETURN mpartnum

// **-----------------  End Of   EquCopy

// ***--------------------------------------------------------------------------

FUNCTION EquPartAdd( mmodcode )

    mpartnum := Space( 20 )
    SELECT Part
    SET ORDER TO 1                // Partnum

    PartFind( @mpartnum )

    IF PressedEsc()
        RETURN NIL
    ENDIF
    SELECT Part
    SET ORDER TO 1
    GOTO TOP
    SEEK mpartnum
    IF !Found()
        @ 1, 3 SAY "    PART NOT FOUND TRY AGAIN   " COLOR "G+"
        Inkey( 0 )
        RETURN NIL
    ENDIF
    mpartnum := Part->Partnum
    Scroll(   3, 0, 24, 80 )
    DispBox(  3, 1, 19, 79, 2 )
    IF mmodcode = Space( 16 )
        mmodcode := Part->Partnum
    ENDIF
    SELECT EquDesc
    SET ORDER TO 1          // ModCode
    SEEK mmodcode
    IF Found()
        SELECT Equ
        mseek := EquDesc->Modcode + Part->Partnum
        SEEK mseek
        ApFLock( 3 )
        IF !Found() .OR. SubStr( Part->Partnum, 1, 2 ) = "ZZ"
            APPEND BLANK
        ENDIF
        Equ->ModCode  := EquDesc->Modcode
        Equ->Catno    := Part->Catno
        Equ->Partnum  := Part->Partnum
        Equ->ModSeqno := EquDesc->Modcode + Str( RecNo(), 6 )
        IF SubStr( Equ->ModCode, 1, 2 ) = "XY"
            Equ->ABC := "x"
        ENDIF
        UNLOCK
        mmodcode := Equ->Modcode
        aPart_ := {}
        nrecno := 0
        nTotal := nlabour := 0
    ENDIF
    nl := 4
    mmodref := "Cut Length                              "
    mcorrect := "N"
    SELECT Equ
    DO WHILE mcorrect == "N"

        cLength := cWidth := "N"

        DispBox( 22, 1, 24, 79, 2 )

        nselect := 1
        DO CASE
        CASE Part->Unit = "Each      "
            nselect := 1
        CASE Part->Unit = "Mtr       "
            nselect := 3
        CASE Part->Unit = "Sq Mtr    "
            nselect := 4
        CASE Part->Unit = "Cu Mtr    "
            nselect := 5
        ENDCASE
        @ 23, 6      PROMPT "1. Each"
        @ 23, Col() + 2 PROMPT "2. Each Use"
        @ 23, Col() + 2 PROMPT "3. Cut Lengths"
        @ 23, Col() + 2 PROMPT "4. Sq Mtr Area"
        @ 23, Col() + 2 PROMPT "5. Cu Mtr"
        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nselect = 1                         // Each
            cLength := "N"
        CASE nselect = 2                         // Each Use
            mok := "Y"
            DO WHILE mok = "Y"
                SELECT Equ
                ApRLock( 3 )
                Equ->PartQty := 0
                UNLOCK
                aPart_ := {}
                nrecno   := 0
                SELECT EquCut
                mseek := Equ->ModSeqno + Equ->Partnum
                SEEK mseek
                IF !Found()
                    mok := "N"
                ELSE
                    nQty := 0
                    SELECT EquCut
                    DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                        IF EquCut->Qty = 0
                            ApRLock( 3 )
                            DELETE
                            UNLOCK
                            SKIP ALIAS EquCut
                            LOOP
                        ENDIF
                        Scroll( 18, 3, 20, 78 )
                        @ 19, 10 SAY EquCut->ModRef;
                            + " " + Str( EquCut->Qty, 7, 2 ) COLOR "BG+"
                        AAdd( aPart_, EquCut->ModRef;
                            + " " + Str( EquCut->Qty, 7, 2 );
                            + "                 " + Str( RecNo(), 6 ) )
                        SKIP ALIAS EquCut
                    ENDDO                        // Labour EOF
                    Scroll(   6, 0, 24, 80 )
                    DispBox(  3, 1, 24, 79, 2 )
                    IF !Empty( aPart_ )
                        // Sort Taken Out
                        ASort( aPart_,,, {| x, y | x < y } )
                        anum := AChoice(  7, 6, 23, 64, aPart_,, "AFUNC" )
                        IF PressedEsc()
                            RETURN NIL
                        ENDIF
                        nrecno := Val( Right( aPart_[ anum ],6 ) )
                        GOTO nrecno
                    ENDIF                         // Empty
                    mok := ApGetN( "Yes to Edit  No to Add Cuts" )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    IF mok = "Y"
                        Scroll(  16, 0, 24, 80 )
                        DispBox( 16, 1, 24, 79, 2 )
                        nl := 17
                        @ nl, 6 SAY "This is the Module Edit"
                        nl++
                        SELECT EquCut
                        mmodref := EquCut->ModRef
                        nqty    := EquCut->Qty
                        @ nl, 4      GET mmodref
                        @ nl, Col() + 2 SAY "Qty" GET nqty PICTURE "9999.99"
                        READ
                        ApRLock( 3 )
                        EquCut->ModRef := mmodref
                        EquCut->Qty    := nqty
                        UNLOCK
                    ENDIF
                ENDIF                 // Found
            ENDDO                                           // mok
            nQty := nQtyEqu := nWidth := nLength := 0
            SELECT EquCut
            GOTO TOP
            SEEK mseek
            IF Found()
                nl := 4
                Scroll(  nl, 2, 24, 78 )
                DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                    IF nl > 13
                        WAIT
                        nl := 4
                        Scroll( nl, 2, 23, 78 )
                    ENDIF
                    @ nl, 4      SAY EquCut->ModRef
                    @ nl, Col() + 1 SAY "Qty"
                    @ nl, Col() + 1 SAY EquCut->Qty    PICTURE "9999.99"
                    nQty += EquCut->Qty
                    nl++
                    SKIP ALIAS EquCut
                ENDDO                        // EquCut EOF
                SELECT Equ
                ApRLock( 3 )
                Equ->PartQty := nQty
                UNLOCK
            ENDIF                              // Found
            nl :=  7
            Scroll(  nl, 0, 24, 80 )
            DispBox(  3, 1, 24, 79, 2 )
            nl++
            @ nl, 4      SAY Trim( Part->Partnum ) + " " + Trim( Part->Desc )
            @ nl, Col() + 2 SAY nQty PICTURE "9999.999" COLOR "G+" // Equ->PartQty
            @ nl, Col() + 2 SAY Part->Unit
            nl++
            @ nl, 10 SAY "Add Qty  Qty = 0 to Exit"
            nl++
            nTotal := 1
            DO WHILE nTotal != 0
                IF nl > 22
                    Inkey( 2 )
                    nl :=  6
                    Scroll( nl, 2, 23, 78 )
                ENDIF
                nl++
                mmodref := "Each Use                               "
                cadd := call := "N"
                IF Note->Select3 = "Y"
                    @ nl, 5      SAY "0 = Skip  Qty" GET nQtyEqu PICTURE "9999.99"
                    READ
                    IF nQtyEqu != 0
                        cadd := call := "Y"
                        @ nl, 32      SAY "Y for List" GET cadd PICTURE "!"
                        @ nl, Col() + 2 SAY "Y = All"    GET call PICTURE "!"
                        READ
                    ENDIF
                    @ nl, 4 SAY "                                            "
                ENDIF                              // Note Select3
                IF cadd = "Y"
                    SAVE SCREEN TO Tempscrn
                    aPart_ := {}
                    nrecno := 0
                    SELECT Progress
                    GOTO TOP
                    DO WHILE Progress->( !Eof() )
                        IF Progress->Desc = "         "
                            SKIP ALIAS Progress
                            LOOP
                        ENDIF
                        IF call != "Y"
                            IF SubStr( coperno, 3, 5 ) != "     "
                                IF Progress->Operno != coperno
                                    SKIP ALIAS Progress
                                    LOOP
                                ENDIF
                            ENDIF
                        ENDIF
                        AAdd( aPart_, ( Progress->Operno + "   " + Progress->Desc;
                            + "                      " + Str( RecNo(), 6 ) ) )
                        SKIP ALIAS Progress
                    ENDDO
                    Scroll()
                    IF !Empty( aPart_ )
                        DispBox(  0, 0, 24, 60, 2 )
                        ASort( aPart_,,, {| x, y | x < y } )
                        anum := AChoice( 1, 3, 23, 58, aPart_,, "AFUNC" )
                        nrecno := Val( Right( aPart_[ anum ],6 ) )
                        GOTO nrecno
                        IF PressedEsc()
                            RETURN NIL
                        ENDIF
                        mdesc := Progress->Desc
                        Scroll( 15, 0, 24, 80 )
                        DispBox( 15, 0, 24, 79, 2 )
                        @ 17, 4 SAY "                                            "
                        @ 17, 5 SAY Progress->Desc + "  " + Equ->ModCode + " " + coperno COLOR "RG+"
                        @ 19, 5 GET mdesc PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                        READ
                        IF PressedEsc()
                            RETURN NIL
                        ENDIF
                        myes := "N"
                        @ 19, 50 SAY "Is this New" GET myes PICTURE "@!"
                        READ
                        IF myes = "Y"
                            myes := "N"
                            @ 19, 50 SAY "   Sure New" COLOR "RG+"
                            @ 19, Col() + 1 GET myes VALID( myes $ "NY" ) PICTURE "@!"
                            @ 22, 10 SAY "Do you want to Add to List ARE YOU SURE" COLOR "RG+"
                            READ
                        ENDIF
                        SELECT Progress
                        ApFLock( 3 )
                        IF myes = "Y"
                            APPEND BLANK
                            Progress->Operno  := coperno
                        ENDIF
                        Progress->Date    := Date()
                        Progress->Desc    := mdesc
                        UNLOCK
                        mmodref := mdesc
                        RESTORE SCREEN FROM Tempscrn
                    ENDIF
                ENDIF    // !Empty

                @ nl, 2 SAY "                        "
                @ nl, 3      GET mmodref PICTURE "@KX"
                @ nl, Col() + 2 SAY "Qty" GET nQtyEqu PICTURE "9999.99"
                READ
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                IF Empty( aPart_ )
                    SELECT Progress
                    ApFLock( 3 )
                    APPEND BLANK
                    Progress->Operno := coperno
                    Progress->Date   := Date()
                    Progress->Desc   := "Cut List NEW Change next time"
                    UNLOCK
                ENDIF
                nTotal := nQtyEqu                  // Needed to get out of loop
                IF nQtyEqu > 0
                    SELECT EquCut
                    ApFLock( 3 )
                    APPEND BLANK
                    EquCut->ModRef   := mmodref
                    EquCut->Qty      := nQtyEqu
                    EquCut->ModSeqno := Equ->ModSeqNo
                    EquCut->Date     := Date()
                    EquCut->Partnum  := Part->Partnum
                    UNLOCK
                    SELECT Equ
                    ApRLock( 3 )
                    Equ->PartQty += nQtyEqu
                    UNLOCK
                    nQtyEqu := 0
                ENDIF
                @  4, 62      SAY "Total"
                @  4, Col() + 1 SAY Equ->PartQty PICTURE "99,999.999" COLOR "G+"
            ENDDO                         // nTotal
            // *************
        CASE nselect = 3                         // Cut Length Qty
            cLength := "Y"
        CASE nselect = 4                         // Sq Mtr
            cLength := cWidth := "Y"
        CASE nselect = 5                           // Cu Mtr
            nQty := nWidth := nThick := nTotQty := 0
            Scroll(   5, 0, 24, 80 )
            DispBox(  3, 1, 24, 79, 2 )
            nl := 6
            @ nl, 10      SAY "Size mm" GET nWidth  PICTURE "9999"
            @ nl, Col() + 1 SAY "X"      GET nThick  PICTURE "9999"
            @ nl, Col() + 2 SAY "Qty"    GET nTotQty PICTURE "9999.999"
            READ
            SELECT Part
            ApRLock( 3 )
            Part->Width := nWidth
            Part->Thick := nThick
            UNLOCK
            nQty := ( ( Part->Width * Part->Thick ) / 1000000 ) * nTotQty
            nl += 2
            @ nl, 10      SAY "Cubic Mtr"
            @ nl, Col() + 2 SAY nQty  PICTURE "99,999.999"
            SELECT Equ
            ApRLock( 3 )
            Equ->PartQty := nQty
            UNLOCK
        ENDCASE
        IF clength = "Y"
            nQty := nQtyEqu := nWidth := nLength := 0
            Scroll(   3, 0, 24, 80 )
            DispBox(  3, 1, 24, 79, 2 )
            nl := 4
            @ nl, 4      SAY Trim( Part->Partnum ) + " " + Trim( Part->Desc )
            @ nl, Col() + 2 SAY Equ->PartQty PICTURE "9999.999" COLOR "G+"
            @ nl, Col() + 2 SAY Part->Unit
            nl++
            @ nl, 6 SAY "Add Lengths and Qty    Length = 0  Qty = 0 to Exit" COLOR "RG+"
            nl++
            nTotal := 1
            DO WHILE nTotal != 0
                IF nl > 20
                    Inkey( 2 )
                    nl :=  6
                    Scroll( nl, 2, 23, 78 )
                ENDIF
                ntrade     := Part->Trade
                nwholesale := Part->Wholesale
                nl++
                @ nl, 3      SAY "Qty"          GET nQtyEqu PICTURE "9999.99"
                @ nl, Col() + 1 SAY "Mtr Length"   GET nLength PICTURE "999.999"
                IF cWidth = "Y"
                    @ nl, Col() + 1 SAY "Mtr Width" GET nWidth  PICTURE "999.999"
                ENDIF
                READ
                cadd := call := "N"
                IF Note->Select3 = "Y"
                    cadd := call := "Y"
                    @ nl, 52      SAY "Y = List" GET cadd PICTURE "!"
                    @ nl, Col() + 2 SAY "Y = All"  GET call PICTURE "!"
                    READ
                ENDIF                 // Note Select3
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nTotal := nQtyEqu                  // Needed to get out of loop
                mmodref := "Cut Length                              "
                IF cWidth = "Y"
                    nQty += ( nLength * nWidth ) * nQtyEqu
                ELSE
                    nQty += nLength * nQtyEqu
                ENDIF
                @  nl, 62      SAY "Total"
                @  nl, Col() + 1 SAY nQty + Equ->PartQty PICTURE "99,999.999" COLOR "G+"
                nl++
                IF nQtyEqu > 0
                    IF cadd = "Y"
                        SAVE SCREEN TO Tempscrn
                        aPart_ := {}
                        nrecno := 0
                        SELECT Progress
                        GOTO TOP
                        DO WHILE Progress->( !Eof() )
                            IF Progress->Desc = "         "
                                SKIP ALIAS Progress
                                LOOP
                            ENDIF
                            IF call != "Y"
                                IF SubStr( coperno, 3, 5 ) != "     "
                                    IF Progress->Operno != coperno
                                        SKIP ALIAS Progress
                                        LOOP
                                    ENDIF
                                ENDIF
                            ENDIF
                            AAdd( aPart_, ( Progress->Operno + "   " + Progress->Desc;
                                + "                      " + Str( RecNo(), 6 ) ) )
                            SKIP ALIAS Progress
                        ENDDO
                        Scroll()
                        IF !Empty( aPart_ )
                            DispBox(  0, 0, 24, 60, 2 )
                            ASort( aPart_,,, {| x, y | x < y } )
                            anum := AChoice( 1, 3, 23, 58, aPart_,, "AFUNC" )
                            nrecno := Val( Right( aPart_[ anum ],6 ) )
                            GOTO nrecno
                            IF PressedEsc()
                                RETURN NIL
                            ENDIF
                            mdesc := Progress->Desc
                            Scroll( 15, 0, 24, 80 )
                            DispBox( 15, 0, 24, 79, 2 )
                            @ 17, 4 SAY "                                            "
                            @ 17, 5 SAY Progress->Desc + "  " + Equ->ModCode + " " + coperno COLOR "RG+"
                            @ 19, 5 GET mdesc PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                            READ
                            IF PressedEsc()
                                RETURN NIL
                            ENDIF
                            myes := "N"
                            @ 19, 50 SAY "Is this New" GET myes PICTURE "@!"
                            READ
                            IF myes = "Y"
                                myes := "N"
                                @ 19, 50 SAY "   Sure New" COLOR "RG+"
                                @ 19, Col() + 1 GET myes VALID( myes $ "NY" ) PICTURE "@!"
                                @ 22, 10 SAY "Do you want to Add to List ARE YOU SURE" COLOR "RG+"
                                READ
                            ENDIF
                            SELECT Progress
                            ApFLock( 3 )
                            IF myes = "Y"
                                APPEND BLANK
                                Progress->Operno  := coperno
                            ENDIF
                            Progress->Date    := Date()
                            Progress->Desc    := mdesc
                            UNLOCK
                            mmodref := mdesc
                            RESTORE SCREEN FROM Tempscrn
                            // **** THIS       ENDIF
                        ENDIF    // !Empty
                    ENDIF
                    SELECT EquCut
                    @ nl, 2 SAY "                                   "
                    @ nl, 20 GET mmodref PICTURE "@KX"     // Changed for Bryn
                    READ
                    ApFLock( 3 )
                    APPEND BLANK
                    EquCut->ModRef   := mmodref
                    EquCut->Qty      := nQtyEqu
                    EquCut->Length   := nLength
                    EquCut->Width    := nWidth
                    EquCut->ModSeqno := Equ->ModSeqNo
                    EquCut->Date     := Date()
                    EquCut->Partnum  := Part->Partnum
                    UNLOCK
                ENDIF
                SELECT Equ
                ApRLock( 3 )
                Equ->PartQty += nQty
                UNLOCK
                nQty := nQtyEqu := nWidth := nLength := 0
            ENDDO                         // nTotal

        ENDIF                               // cLength

        // **     nl := 4
        nTotTime := nTotRate := 0

        Scroll( 11, 0, 24, 80 )
        DispBox( 3, 1, 24, 79, 2 )
        SELECT Equ
        npartqty   := Equ->Partqty
        // **   nl := 12
        @ nl, 6      SAY "Number of parts" GET npartqty PICTURE "99999.999"
        @ nl, Col() + 3 SAY "0 = remove part - Esc = Quit"
        nl += 2
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        ApRLock( 3 )
        Equ->Partqty := npartqty
        UNLOCK
        mcorrect := "Y"
        // ** ApGetY( Message->Correct )
        IF Equ->Partqty == 0
            SELECT EquCut
            ApFLock( 3 )
            DELETE ALL FOR EquCut->Partnum = Equ->Partnum;
                .AND. SubStr( EquCut->ModSeqno, 1, 16 ) = Equ->Modcode
            UNLOCK
            SELECT Equ
            ApRLock( 3 )
            DELETE
            UNLOCK
            mcorrect := "N"
            RETURN NIL
        ENDIF
    ENDDO
    mpartnum := Equ->ModCode

    RETURN NIL
// ***---- End of EquPartAdd()

// **---------------------------------------------------------------------*

FUNCTION EquCutEach()

    Scroll(  18, 0, 24, 80 )
    DispBox( 18, 1, 24, 79, 2 )
    mlevel := 2
    @ 22, 10 SAY "Module Level Required  2, 3, 4" GET mlevel PICTURE "9"
    READ
    nl := 0
    mwhere := "S"
    npl    := 60

    Printsel( mwhere, npl )

    IF mwhere = "P"
        npl := 60
    ELSE
        npl := 16
    ENDIF
    SELECT EquDesc
    SET ORDER TO 1          // ModCode
    SEEK mmodcode
    npn := 1
    @  nl, 0 SAY Control->U_Name
    @  nl, 45 SAY "Each Parts"
    @  nl, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  nl, 76 SAY npn PICTURE "99"
    nl += 2
    @  nl, 0 SAY Equdesc->Modcode + "  " + Equdesc->Desc;
        + " " + EquDesc->Operno
    nl++
    ntotal := ntradetot := nselltot := 0
    nlabpart := npartqty := 0
    aPart_ := {}
    anum   := {}
    nequtrade1 := nequtrade2 := nequtrade3 := nequtrade4 := 0
    nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
    nqty1 := nqty2 := nqty3 := nqty4 := 0
    nequ1 := nequ2 := nequ3 := nequ4 := 0
    SELECT Equ
    SET EXACT ON
    GOTO TOP
    SEEK mmodcode
    IF Found()
        DO WHILE  Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
            nqty1 := Equ->PartQty
            nequ1 := nqty1
            IF nl > npl
                IF mwhere = "S"
                    WAIT
                    Scroll()
                    nl := 0
                ELSE
                    npn++
                    EJECT
                    nl := 0
                    @  nl, 0 SAY Control->U_Name
                    @  nl, 45 SAY "Each Parts"
                    @  nl, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  nl, 76 SAY npn PICTURE "99"
                    nl += 2
                    @  nl, 0 SAY Equdesc->Modcode + "  " + Equdesc->Desc;
                        + " " + EquDesc->Operno
                    nl++
                ENDIF
            ENDIF       // npl
            SELECT Part
            SEEK Equ->Partnum
            IF Part->Unit != "Each "
                SELECT Equ
                SKIP ALIAS Equ
                LOOP
            ENDIF
            nequtrade1 += nqty1 * Part->Trade
            @ nl, 0 SAY Str( nequ1, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                + " " + Part->Desc
            IF Equ->Partnum = Message->LabPart
                nlabpart += nequ1
            ENDIF
            nl++
            SELECT EquCut
            GOTO TOP
            SEEK Equ->ModSeqno
            DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                IF EquCut->Partnum != Equ->Partnum
                    SKIP ALIAS EquCut
                    LOOP
                ENDIF
                IF mwhere = "S"
                    IF nl > 20
                        Inkey( 0 )
                        nl := 3
                        Scroll(  nl, 1, 24, 80 )
                    ENDIF
                ENDIF
                @ nl, 11 SAY EquCut->ModRef
                @ nl, 52 SAY "Qty"
                @ nl, 56 SAY EquCut->Qty    PICTURE "9,999"
                nl++
                SKIP ALIAS EquCut
            ENDDO
            SELECT Equ
            mmod2   := Trim( Equ->Partnum )
            nrecno2 := RecNo()
            GOTO TOP
            SEEK mmod2
            IF !Found()
                ntradeTot += nequ1 * Part->Trade
            ENDIF
            IF Found()
                nequtrade2 := 0
                DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                    nqty2 := Equ->PartQty
                    nequ2 := nqty1 * nqty2
                    SELECT Part
                    SEEK Equ->Partnum
                    IF Part->Unit != "Each "
                        SELECT Equ
                        SKIP ALIAS Equ
                        LOOP
                    ENDIF
                    nequtrade2 += nqty2 * Part->Trade
                    IF Equ->Partnum = Message->LabPart
                        nlabpart += nequ2
                    ENDIF
                    IF mlevel >= 2
                        IF mwhere = "S"
                            IF nl > 22
                                Inkey( 0 )
                                nl := 3
                                Scroll(  nl, 1, 24, 80 )
                            ENDIF
                        ENDIF
                        @ nl, 0 SAY Str( nequ2, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                            + " " + Part->Desc
                        nl++
                    ENDIF     // mlevel > 2
                    IF mlevel >= 2
                        SELECT EquCut
                        GOTO TOP
                        SEEK Equ->ModSeqno
                        DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                            IF EquCut->Partnum != Equ->Partnum
                                SKIP ALIAS EquCut
                                LOOP
                            ENDIF
                            IF mwhere = "S"
                                IF nl > npl
                                    Inkey( 0 )
                                    nl := 3
                                    Scroll(  nl, 1, 24, 80 )
                                ENDIF
                            ENDIF
                            @ nl, 11 SAY EquCut->ModRef
                            @ nl, 52 SAY "Qty"
                            @ nl, 56 SAY EquCut->Qty    PICTURE "9,999.99"
                            nl++
                            SKIP ALIAS EquCut
                        ENDDO
                    ENDIF                       // mlevel
                    SELECT Equ
                    mmod3   := Trim( Equ->Partnum )
                    nrecno3 := RecNo()
                    GOTO TOP
                    SEEK mmod3
                    IF !Found()
                        ntradeTot += nequ2 * Part->Trade
                    ENDIF
                    IF Found()
                        nequtrade3 := 0
                        DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                            SELECT Part
                            SEEK Equ->Partnum
                            IF Part->Unit != "Each "
                                SELECT Equ
                                SKIP ALIAS Equ
                                LOOP
                            ENDIF
                            nqty3 := Equ->PartQty
                            nequ3 := nqty1 * nqty2 * nqty3
                            nequtrade3 += nqty3 * Part->Trade
                            IF mlevel >= 3
                                IF mwhere = "S"
                                    IF nl > npl
                                        Inkey( 0 )
                                        nl := 3
                                        Scroll(  nl, 1, 24, 80 )
                                    ENDIF
                                ENDIF
                                @ nl, 0 SAY Str( nequ3, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                                    + " " + Part->Desc
                                nl++
                            ENDIF
                            IF Equ->Partnum = Message->LabPart
                                nlabpart += nequ3
                            ENDIF
                            SELECT Equ
                            mmod4   := Trim( Equ->Partnum )
                            nrecno4 := RecNo()
                            GOTO TOP
                            SEEK mmod4
                            IF !Found()
                                ntradeTot += nequ3 * Part->Trade
                            ENDIF
                            IF Found()
                                nequtrade4 := 0
                                DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                    nqty4 := Equ->PartQty
                                    nequ4 := ( nqty4 * nqty3 ) * nqty1 * nqty2
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    IF Part->Unit != "Each "
                                        SELECT Equ
                                        SKIP ALIAS Equ
                                        LOOP
                                    ENDIF
                                    nequtrade4 += nqty4 * Part->Trade
                                    ntradeTot  += nequ4 * Part->Trade
                                    IF Equ->Partnum = Message->LabPart
                                        nlabpart += nequ4
                                    ENDIF
                                    IF mlevel >= 4
                                        IF mwhere = "S"
                                            IF nl > npl
                                                Inkey( 0 )
                                                nl := 3
                                                Scroll(  nl, 1, 24, 80 )
                                            ENDIF
                                        ENDIF
                                        @ nl, 0 SAY Str( nequ4, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                                            + " " + Part->Desc
                                        nl++
                                    ENDIF           // mlevel >= 4
                                    IF mlevel >= 4
                                        SELECT EquCut
                                        GOTO TOP
                                        SEEK Equ->ModSeqno
                                        DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                                            IF EquCut->Partnum != Equ->Partnum
                                                SKIP ALIAS EquCut
                                                LOOP
                                            ENDIF
                                            IF mwhere = "S"
                                                IF nl > npl
                                                    Inkey( 0 )
                                                    nl := 3
                                                    Scroll(  nl, 1, 24, 80 )
                                                ENDIF
                                            ENDIF
                                            @ nl, 11 SAY EquCut->ModRef
                                            @ nl, 52 SAY "Qty"
                                            @ nl, 56 SAY EquCut->Qty    PICTURE "9,999.99"
                                            nl++
                                            SKIP ALIAS EquCut
                                        ENDDO
                                    ENDIF            // mlevel
                                    IF Equ->Partnum = Message->LabPart
                                        nlabpart += nequ4
                                    ENDIF
                                    SELECT Equ
                                    SKIP ALIAS Equ
                                ENDDO                       // mmod4
                            ENDIF                           // Found mmod4
                            // **      ENDIF                             // mlevel 4
                            SELECT Equ
                            GOTO nrecno4
                            SKIP ALIAS Equ
                        ENDDO                       // mmod3
                    ENDIF                          // FOUND  mmod3
                    // **    ENDIF                             // mlevel 3
                    SELECT Equ
                    GOTO nrecno3
                    SKIP ALIAS Equ
                ENDDO                       // mmod2
            ENDIF                          // FOUND  mmod2
            // **   ENDIF                             // mlevel 2
            SELECT Equ
            GOTO nrecno2
            SKIP ALIAS Equ
        ENDDO                       // mmod1
    ENDIF                          // FOUND()  mmod1
    SET EXACT OFF
    IF mwhere = "P"
        @ nl, 0 SAY " "
        EndPrint()
        SET MARGIN TO 0
    ELSE
        IF nl > npl
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN mmodcode

// ***---- End of EquCutEach()

// **---------------------------------------------------------------------*

FUNCTION EquLook( mmodcode )

    mmodcode := EquDesc->ModCode

    aPart_ := {}
    anum   := {}
    nrecno := 0
    SELECT Equ
    GOTO TOP
    SEEK mmodcode
    DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
        SELECT Part
        SEEK Equ->Partnum
        mcut := "   "
        SELECT EquCut
        SEEK Equ->ModSeqno + Equ->Partnum
        IF Found()
            IF Part->Unit = "Each"
                mcut := "Use"
            ELSE
                mcut := "Cut"
            ENDIF
        ENDIF
        SELECT Equ
        AAdd( aPart_, SubStr( Part->Partnum, 1, 9 );
            + " " + SubStr( Part->Desc, 1, 21 );
            + " " + Str( Equ->PartQty, 9, 3 );
            + " " + Str( Part->Trade, 10, 2 );
            + " " + Str( ( Part->Trade * Equ->PartQty ), 10, 2 );
            + " " + Trim( Part->Unit );
            + " " + Part->ABC;
            + " " + mcut;
            + "         " + Str( RecNo(), 6 ) )
        SKIP ALIAS Equ
    ENDDO                       // EOF()
    SELECT Equ
    SET EXACT ON
    ntottrade := ntotwhol := 0
    ntottrade1 := ntotwhol1 := 0
    nrecno2 := nrecno3 := nrecno4 := 0
    nqty1 := nqty2 := nqty3 := nqty4 := 0
    nequ1 := nequ2 := nequ3 := nequ4 := 0
    mmod2 := mmod3 := mmod4 := Space( 16 )
    GOTO TOP
    SEEK mmodcode                // Original Part
    IF Found()
        DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
            SELECT Part
            SEEK Equ->Partnum
            SELECT Equ
            mmod2   := SubStr( Equ->Partnum, 1, 16 )
            nqty1   := Equ->Partqty
            nrecno2 := RecNo()
            GOTO TOP
            SEEK mmod2
            ntottrade1 += ( Part->Trade * nqty1 )
            ntotwhol1  += ( Part->Wholesale * nqty1 )
            IF !Found()
                ntottrade += ( Part->Trade * nqty1 )
                ntotwhol  += ( Part->Wholesale * nqty1 )
            ENDIF
            IF Found()
                DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                    SELECT Part
                    SEEK Equ->Partnum
                    SELECT Equ
                    mmod3   := SubStr( Equ->Partnum, 1, 16 )
                    nrecno3 := RecNo()
                    nqty2   := Equ->PartQty
                    nequ2   := ( nqty1 * nqty2 )
                    GOTO TOP
                    SEEK mmod3
                    IF !Found()
                        ntottrade += ( Part->Trade * nequ2 )
                        ntotwhol  += ( Part->Wholesale * nequ2 )
                    ENDIF
                    IF Found()
                        DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                            SELECT Part
                            SEEK Equ->Partnum
                            SELECT Equ
                            mmod4   := SubStr( Equ->Partnum, 1, 16 )
                            nrecno4 := RecNo()
                            nqty3   := Equ->PartQty
                            nequ3   := nqty1 * nqty2 * nqty3
                            GOTO TOP
                            SEEK mmod4
                            IF !Found()
                                ntottrade += ( Part->Trade * nequ3 )
                                ntotwhol  += ( Part->Wholesale * nequ3 )
                            ENDIF
                            IF Found()
                                DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                    nqty4 := Equ->PartQty
                                    nequ4 := nqty1 * nqty2 * nqty3 * nqty4
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    SELECT Equ
                                    ntottrade += ( Part->Trade * nequ4 )
                                    ntotwhol  += ( Part->Wholesale * nequ4 )
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
        ENDDO                       // mmodcode EOF()
    ENDIF                          // Found mmodcode
    SET EXACT OFF
    SELECT Equ
    GOTO TOP
    SEEK mmodcode
    Scroll()
    DispBox( 0, 1,  2, 79, 2 )
    @  1, 4 SAY Trim( EquDesc->Modcode ) + "  " + Trim( EquDesc->Desc );
        + " " + Trim( EquDesc->EquId ) + " " + EquDesc->Operno COLOR "G+"
    SELECT Equ
    DispBox( 3, 1, 24, 79, 2 )
    IF !Empty( aPart_ )
        @ 4, 3      SAY "Kit"
        @ 4, Col() + 1 SAY ntottrade1 PICTURE "$999,999.99" COLOR "BG+"
        @ 4, Col() + 2 SAY "Parts"
        @ 4, Col() + 1 SAY ntottrade  PICTURE "$999,999.99" COLOR "BG+"
        @ 4, 45      SAY "Qty    Cost   Qty*Cost"
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 5, 3, 23, 78, aPart_,, "AFUNC" )
        IF PressedEsc()
            RETURN NIL
        ENDIF
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        GOTO nrecno
        mpartnum := Equ->Partnum
        Scroll(   8, 1, 19, 80 )
        DispBox(  8, 1, 19, 79, 2 )
        nl := 10
        SELECT Part
        SET ORDER TO 1
        SEEK mpartnum
        @ nl, 3      SAY Trim( mpartnum ) + " " + Trim( Part->Desc ) + " Qty"COLOR "G+"
        @ nl, Col() + 1 SAY Equ->PartQty PICTURE "9999.999" COLOR "BG+"
        @ nl, Col() + 2 SAY Trim( Part->Unit )              COLOR "BG+"
        @ nl, Col() + 1 SAY EquDesc->Operno                 COLOR "RG+"
        nl++
        mpart := Space ( 20 )
        mseek := Equ->ModSeqno + Equ->Partnum
        SELECT EquCut
        GOTO TOP
        SEEK mseek
        IF Found()
            DO WHILE EquCut->ModSeqNo + EquCut->Partnum = mSeek .AND. EquCut->( !Eof() )
                IF nl >= 21
                    @ nl, 60 SAY "There are More Cuts"
                    RETURN NIL
                ENDIF
                @ nl, 6      SAY SubStr( EquCut->ModRef, 1, 30 )
                @ nl, Col() + 1 SAY "Qty"
                @ nl, Col() + 1 SAY EquCut->Qty    PICTURE "99999.99"
                @ nl, Col() + 1 SAY EquCut->Length PICTURE "999.999"
                IF EquCut->Width != 0
                    @ nl, Col() + 1 SAY EquCut->Width  PICTURE "999.999"
                ENDIF
                nl++
                SKIP ALIAS EquCut
            ENDDO
        ENDIF               // Found
    ENDIF
    IF PressedEsc()
        RETURN         // TEST // SPACE( 16 )      // ModCode = 16
    ENDIF

    RETURN NIL
// ***---- End of EquLook()

// ***-----------------------------------------------------------------------

FUNCTION EquCutList()

    mprice := ApGetY( "Do you Want Prices" )
    mused  := "N"
    // **      mused  := ApGetN( "Do you Want Where Used" )
    Scroll(  16, 0, 24, 80 )
    DispBox( 16, 1, 24, 79, 2 )
    ncostadd := 0
    IF mprice = "Y"
        @ 18, 10 SAY "Add % on Cost Price" GET ncostadd PICTURE "9999.999"
        READ
        ncostadd := ncostadd / 100
    ENDIF
    mlevel := 1
    @ 22, 10 SAY "Module Level Required  1, 2, 3, 4" GET mlevel PICTURE "9"
    READ
    nl := 0
    mwhere := "S"
    npl    := 60

    Printsel( mwhere, npl )

    IF mwhere = "P"
        npl := 60
    ELSE
        npl := 16
    ENDIF
    SELECT EquDesc
    SET ORDER TO 1          // ModCode
    SEEK mmodcode
    npn := 1
    @  nl, 0 SAY Control->U_Name
    @  nl, 50 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  nl, 76 SAY npn PICTURE "99"
    nl += 2
    @  nl, 0 SAY Equdesc->Modcode + "  " + Equdesc->Desc;
        + " " + EquDesc->Operno
    nl++
    nl++
    ntotal := ntradetot := nselltot := 0
    nlabpart := npartqty := 0
    aPart_ := {}
    anum   := {}
    nequtrade1 := nequtrade2 := nequtrade3 := nequtrade4 := 0
    nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
    nqty1 := nqty2 := nqty3 := nqty4 := 0
    nequ1 := nequ2 := nequ3 := nequ4 := 0
    SELECT Equ
    SET EXACT ON
    GOTO TOP
    SEEK mmodcode
    IF Found()
        DO WHILE  Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
            nqty1 := Equ->PartQty
            nequ1 := nqty1
            IF nl > npl
                IF mwhere = "S"
                    WAIT
                    Scroll()
                    nl := 0
                ELSE
                    npn++
                    EJECT
                    nl := 0
                    @  nl, 0 SAY Control->U_Name
                    @  nl, 50 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  nl, 76 SAY npn PICTURE "99"
                    nl += 2
                    @  nl, 0 SAY Equdesc->Modcode + "  " + Equdesc->Desc;
                        + " " + EquDesc->Operno
                    nl++
                ENDIF
            ENDIF       // npl
            SELECT Part
            SEEK Equ->Partnum
            nequtrade1 += nqty1 * Part->Trade
            @ nl, 0 SAY Str( nequ1, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                + " " + SubStr( Part->Desc, 1, 30 );
                + " " + SubStr( Part->Unit, 1, 2 );
                + " ."
            IF mprice = "Y"
                @ nl, 62 SAY ( nequ1 * Part->Trade ) + ( ( nequ1 * Part->Trade ) * ncostadd );
                    PICTURE "999,999.99"
                ntotal := ntotal + ( nequ1 * Part->Trade ) + ( ( nequ1 * Part->Trade ) * ncostadd )
            ENDIF
            ddate := DToC( Part->Date )
            @ nl, 73 SAY SubStr( ddate, 4, 3 ) + SubStr( ddate, 9, 2 )
            IF Part->Date <= Date() -60
                IF Part->Boughtout = "Y"
                    IF Part->Trade >= 3
                        @ nl, 79 SAY "*"
                    ENDIF
                ENDIF
            ENDIF

            IF Equ->Partnum = Message->LabPart
                nlabpart += nequ1
            ENDIF
            nl++
            SELECT EquCut
            GOTO TOP
            SEEK Equ->ModSeqno
            DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                IF EquCut->Partnum != Equ->Partnum
                    SKIP ALIAS EquCut
                    LOOP
                ENDIF
                IF mwhere = "S"
                    IF nl > 18
                        Inkey( 0 )
                        nl := 3
                        Scroll(  nl, 1, 24, 80 )
                    ENDIF
                ENDIF
                @ nl, 5 SAY SubStr( EquCut->ModRef, 1, 30 )
                @ nl, 36 SAY "Qty"
                @ nl, 40 SAY EquCut->Qty    PICTURE "9,999.999"
                @ nl, 50 SAY EquCut->Length PICTURE "9,999.999"
                IF EquCut->Width != 0
                    @ nl, 60 SAY EquCut->Width  PICTURE "9,999.999"
                ENDIF
                nl++
                SKIP ALIAS EquCut
            ENDDO
            // **    IF mlevel > 1
            SELECT Equ
            mmod2   := Trim( Equ->Partnum )
            nrecno2 := RecNo()
            GOTO TOP
            SEEK mmod2
            IF !Found()
                ntradeTot += nequ1 * Part->Trade
            ENDIF
            IF Found()
                nequtrade2 := 0
                DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                    nqty2 := Equ->PartQty
                    nequ2 := nqty1 * nqty2
                    SELECT Part
                    SEEK Equ->Partnum
                    nequtrade2 += nqty2 * Part->Trade
                    IF Equ->Partnum = Message->LabPart
                        nlabpart += nequ2
                    ENDIF
                    IF mlevel >= 2
                        IF mwhere = "S"
                            IF nl > 22
                                Inkey( 0 )
                                nl := 3
                                Scroll(  nl, 1, 24, 80 )
                            ENDIF
                        ENDIF
                        @ nl, 0 SAY Str( nequ2, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                            + " " + SubStr( Part->Desc, 1, 31 );
                            + " " + SubStr( Part->Unit, 1, 2 );
                            + " .."
                        ddate := DToC( Part->Date )
                        @ nl, 73 SAY SubStr( ddate, 4, 3 ) + SubStr( ddate, 9, 2 )
                        IF Part->Date <= Date() -60
                            IF Part->Boughtout = "Y"
                                IF Part->Trade >= 3
                                    @ nl, 79 SAY "*"
                                ENDIF
                            ENDIF
                        ENDIF
                  /*
                  IF mprice = "Y"
                     @ nl,66 SAY ( nequ2*Part->Trade )+(( nequ2*Part->Trade )*ncostadd);
                         PICTURE "!999,999.99"
                     ***            ntotal := ntotal+( nequ2*Part->Trade )+(( nequ2*Part->Trade )*ncostadd)
                  ENDIF
                  */
                        nl++
                    ENDIF     // mlevel > 2
                    IF mlevel >= 3
                        SELECT EquCut
                        GOTO TOP
                        SEEK Equ->ModSeqno
                        DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                            IF EquCut->Partnum != Equ->Partnum
                                SKIP ALIAS EquCut
                                LOOP
                            ENDIF
                            IF mwhere = "S"
                                IF nl > npl
                                    Inkey( 0 )
                                    nl := 3
                                    Scroll(  nl, 1, 24, 80 )
                                ENDIF
                            ENDIF
                            @ nl, 5 SAY SubStr( EquCut->ModRef, 1, 30 )
                            @ nl, 36 SAY "Qty"
                            @ nl, 40 SAY EquCut->Qty    PICTURE "9,999.99"
                            @ nl, 48 SAY EquCut->Length PICTURE "9,999.999"
                            IF EquCut->Width != 0
                                @ nl, 58 SAY EquCut->Width  PICTURE "9,999.999"
                            ENDIF
                            nl++
                            SKIP ALIAS EquCut
                        ENDDO
                    ENDIF                       // mlevel
                    SELECT Equ
                    mmod3   := Trim( Equ->Partnum )
                    nrecno3 := RecNo()
                    GOTO TOP
                    SEEK mmod3
                    IF !Found()
                        ntradeTot += nequ2 * Part->Trade
                    ENDIF
                    IF Found()
                        nequtrade3 := 0
                        DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                            SELECT Part
                            SEEK Equ->Partnum
                            nqty3 := Equ->PartQty
                            nequ3 := nqty1 * nqty2 * nqty3
                            nequtrade3 += nqty3 * Part->Trade
                            IF mlevel >= 3
                                IF mwhere = "S"
                                    IF nl > npl
                                        Inkey( 0 )
                                        nl := 3
                                        Scroll(  nl, 1, 24, 80 )
                                    ENDIF
                                ENDIF
                                @ nl, 0 SAY Str( nequ3, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                                    + " " + SubStr( Part->Desc, 1, 30 );
                                    + " " + SubStr( Part->Unit, 1, 2 );
                                    + " ..."
                                ddate := DToC( Part->Date )
                                @ nl, 73 SAY SubStr( ddate, 4, 3 ) + SubStr( ddate, 9, 2 )
                                IF Part->Date <= Date() -60
                                    IF Part->Boughtout = "Y"
                                        IF Part->Trade >= 3
                                            @ nl, 79 SAY "*"
                                        ENDIF
                                    ENDIF
                                ENDIF
                        /*
                                    IF mprice = "Y"
                                   @ nl,66 SAY ( nequ3*Part->Trade )+(( nequ3*Part->Trade )*ncostadd);
                                         PICTURE "!999,999.99"
                           ***            ntotal := ntotal+( nequ3*Part->Trade )+(( nequ3*Part->Trade )*ncostadd)
                                    ENDIF
                        */
                                nl++
                            ENDIF
                            IF Equ->Partnum = Message->LabPart
                                nlabpart += nequ3
                            ENDIF
                            SELECT Equ
                            mmod4   := Trim( Equ->Partnum )
                            nrecno4 := RecNo()
                            GOTO TOP
                            SEEK mmod4
                            IF !Found()
                                ntradeTot += nequ3 * Part->Trade
                            ENDIF
                            IF Found()
                                nequtrade4 := 0
                                DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                    nqty4 := Equ->PartQty
                                    nequ4 := ( nqty4 * nqty3 ) * nqty1 * nqty2
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    nequtrade4 += nqty4 * Part->Trade
                                    ntradeTot  += nequ4 * Part->Trade
                                    IF Equ->Partnum = Message->LabPart
                                        nlabpart += nequ4
                                    ENDIF
                                    IF mlevel >= 4
                                        IF mwhere = "S"
                                            IF nl > npl
                                                Inkey( 0 )
                                                nl := 3
                                                Scroll(  nl, 1, 24, 80 )
                                            ENDIF
                                        ENDIF
                                        @ nl, 0 SAY Str( nequ4, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                                            + " " + SubStr( Part->Desc, 1, 30 );
                                            + " " + SubStr( Part->Unit, 1, 2 );
                                            + " ...."
                                        ddate := DToC( Part->Date )
                                        @ nl, 72 SAY SubStr( ddate, 4, 3 ) + SubStr( ddate, 9, 2 )
                                        IF Part->Date <= Date() -60
                                            IF Part->Boughtout = "Y"
                                                IF Part->Trade >= 3
                                                    @ nl, 78 SAY "*"
                                                ENDIF
                                            ENDIF
                                        ENDIF
                              /*
                                          IF mprice = "Y"
                                      @ nl,66 SAY ( nequ4*Part->Trade )+(( nequ4*Part->Trade )*ncostadd);
                                                    PICTURE "!999,999.99"
                                 ***            ntotal := ntotal+( nequ4*Part->Trade )+(( nequ4*Part->Trade )*ncostadd)
                                         ENDIF
                              */
                                        nl++
                                    ENDIF           // mlevel >= 4
                                    IF mlevel >= 4
                                        SELECT EquCut
                                        GOTO TOP
                                        SEEK Equ->ModSeqno
                                        DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                                            IF EquCut->Partnum != Equ->Partnum
                                                SKIP ALIAS EquCut
                                                LOOP
                                            ENDIF
                                            IF mwhere = "S"
                                                IF nl > npl
                                                    Inkey( 0 )
                                                    nl := 3
                                                    Scroll(  nl, 1, 24, 80 )
                                                ENDIF
                                            ENDIF
                                            @ nl, 5 SAY SubStr( EquCut->ModRef, 1, 30 )
                                            @ nl, 36 SAY "Qty"
                                            @ nl, 40 SAY EquCut->Qty    PICTURE "9,999.99"
                                            @ nl, 50 SAY EquCut->Length PICTURE "9,999.999"
                                            IF EquCut->Width != 0
                                                @ nl, 60 SAY EquCut->Width  PICTURE "9,999.999"
                                            ENDIF
                                            nl++
                                            SKIP ALIAS EquCut
                                        ENDDO
                                    ENDIF            // mlevel
                                    IF Equ->Partnum = Message->LabPart
                                        nlabpart += nequ4
                                    ENDIF
                                    SELECT Equ
                                    SKIP ALIAS Equ
                                ENDDO                       // mmod4
                            ENDIF                           // Found mmod4
                            // **      ENDIF                             // mlevel 4
                            SELECT Equ
                            GOTO nrecno4
                            SKIP ALIAS Equ
                        ENDDO                       // mmod3
                    ENDIF                          // FOUND  mmod3
                    // **    ENDIF                             // mlevel 3
                    SELECT Equ
                    GOTO nrecno3
                    SKIP ALIAS Equ
                ENDDO                       // mmod2
            ENDIF                          // FOUND  mmod2
            // ********   ENDIF                             // mlevel 2
            SELECT Equ
            GOTO nrecno2
            SKIP ALIAS Equ
        ENDDO                       // mmod1
    ENDIF                          // FOUND()  mmod1
    SET EXACT OFF
    IF mprice = "Y"
        nl++
        // ***       NO GOOD
        // ***      ncostadd := ncostadd*100
        SELECT Part
        SET ORDER TO 1
        SEEK Message->LabPart
        nlabAmnt := ( nlabpart * Part->Trade ) + ( ( nlabpart * Part->Trade ) * ncostadd )
        // ***      @ nl, 0 SAY "Parts"
        // **      @ nl, 7 SAY ntotal-nlabamnt PICTURE "$9,999,999.99"
        // ** ( ntradeTot+( ntradeTot*ncostadd ));
        // **                   -nlabAmnt PICTURE "$9,999,999.99"
        // **      @ nl,30 SAY "Labour"
        // **      @ nl,37 SAY nlabpart PICTURE "9,999.99"
        // **      @ nl,48 SAY nlabAmnt PICTURE "$999,999.99"
        // **      @ nl,48 SAY "Kit Cost"
        // **      nequtrade1+( nequtrade1*ncostadd ) PICTURE "$9,999,999.99"

        @ nl, 63 SAY ntotal PICTURE "$9,999,999.99"
        nl++
        @ nl, 62 SAY "--------------"
        nl += 5
        IF mwhere = "S"
            IF nl > npl
                WAIT
                nl := 3
                Scroll(  nl, 1, 24, 80 )
            ENDIF
        ENDIF
        @ nl, 16 SAY "Above Prices are Cost not Wholesale"
        nl += 2
        @ nl, 0 SAY ncostadd * 100 PICTURE "9999"
        @ nl, 6 SAY "Level"
        @ nl, 12 SAY mlevel PICTURE "99"
        SELECT Part
        SEEK mmodcode
        @ nl, 16 SAY "     Cost File"
        // **      @ nl,32 SAY Part->Trade+( Part->Trade*ncostadd ) PICTURE "$9,999,999.99"
        @ nl, 32 SAY Part->Trade PICTURE "$9,999,999.99"
        nl++
        @ nl, 0 SAY Part->Markup PICTURE "9,999.99"
        @ nl, 16 SAY "     Sell File"
        // **      @ nl,32 SAY Part->Wholesale+( Part->Wholesale*ncostadd ) PICTURE "$9,999,999.99"
        @ nl, 32 SAY Part->Wholesale PICTURE "$9,999,999.99"
        @ nl, 46 SAY Part->Date
        nl++
    ENDIF
   /*
   TAKEN OUT Bryn 27/10/2009
      IF mused = "Y"
         SELECT EquDesc
         SEEK mmodcode
         nl++
         @ nl, 0 SAY EquDesc->ModCode+"  "+EquDesc->Desc+" Used Where Qty"
         nl+=2
         SELECT Equ
         GOTO TOP
         DO WHILE Equ->( !EOF() )
               IF nl > npl
                  IF mwhere = "S"
                     WAIT
                     SCROLL()
                     nl := 0
                   ELSE
                    npn++
                    EJECT
                    nl := 0
                    @  nl, 0 SAY Control->U_Name
                    @  nl,50 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                              +STR( YEAR(DATE() ),5 )
                    @  nl,76 SAY npn PICTURE "99"
                    nl+=2
                    SELECT EquDesc
                    SEEK mmodcode
                    @  nl, 5 SAY Equdesc->Modcode+"  "+Equdesc->Desc
                    nl++
                  ENDIF
               ENDIF       // npl
            IF Equ->Partnum != mmodcode
               SKIP ALIAS Equ
               LOOP
            ENDIF
            @ nl, 2 SAY Equ->Modcode
            SELECT EquDesc
            SEEK Equ->Modcode
            @ nl,20 SAY EquDesc->Desc
            SELECT Equ
            @ nl,62 SAY Equ->PartQty PICTURE "999,999.99"
            nl++
            SKIP ALIAS Equ
         ENDDO                            // EOF Equ
      ENDIF                               // mused
   */
    SELECT EquDesc
    SEEK mmodcode
    SELECT Part
    SEEK mmodcode
    mpartnum := Part->Partnum
    nl++
    // **   @ nl, 0 SAY "Sell Price"
    // **   @ nl,12 SAY Part->Wholesale+( Part->Wholesale*ncostadd ) PICTURE "$9999,999.99"
    IF mwhere = "P"
        @ nl, 0 SAY " "
        EndPrint()
        SET MARGIN TO 0
    ELSE
        IF nl > npl
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN mmodcode

// ***---- End of EquCutList()

// **---------------------------------------------------------------------*

FUNCTION EquCut()

    mprint := ApGetY( "List Cuts/Parts" )
    IF mprint = "Y"
        EquCutList()                         // Above
    ELSE
        Scroll(   3, 0, 24, 80 )
        DispBox(  3, 1, 24, 79, 2 )
        nl := 4
        mpart := Space ( 20 )
        SELECT EquCut
        GOTO TOP
        DO WHILE EquCut->( !Eof() )
            IF SubStr( EquCut->ModSeqno, 1, 16 ) != SubStr( Equ->ModSeqno, 1, 16 )
                SKIP ALIAS EquCut
                LOOP
            ENDIF
            IF nl > 22
                Inkey( 0 )
                nl := 4
                Scroll(  nl, 2, 23, 78 )
            ENDIF
            IF mpart != EquCut->Partnum
                SELECT Part
                SEEK EquCut->Partnum
                @ nl, 3 SAY Trim( Part->Partnum ) + " " + Trim( Part->Desc );
                    + " " + Trim( Part->Unit ) COLOR "BG+"
                // ** No Good  @ nl,COL()+2 SAY Part->ReqQty PICTURE "9,999.999" COLOR "G+"
                nl++
                mpart := Part->Partnum
            ENDIF                               // mpart
            SELECT EquCut
            @ nl, 5      SAY SubStr( EquCut->ModRef, 1, 30 )
            @ nl, Col() + 1 SAY "Qty"
            @ nl, Col() + 1 SAY EquCut->Qty    PICTURE "99,999.99"
            @ nl, Col() + 1 SAY EquCut->Length PICTURE "999.999"
            IF EquCut->Width != 0
                @ nl, Col() + 1 SAY EquCut->Width  PICTURE "999.999"
            ENDIF
            nl++
            SKIP ALIAS EquCut
        ENDDO
        nl++
        @ nl, 20 SAY Message->AnyKey
        Inkey( 0 )
    ENDIF                      // mprint

    RETURN NIL
// **---------- EquCut

// ****---------------- End of File XLF_Equ4.PRG
