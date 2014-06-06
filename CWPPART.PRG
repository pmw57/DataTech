// **  JoKir01  25-01-11 08:17:13

/*
   Program.....:              CWPPart.PRG
   Authors.....: J.Kirby
   Date........: 03/05/1999
   Func........: ProfQty, DrawReview, EquCost, MenuPart
*/

FUNCTION ProfQty()

    SELECT Part
    mpartnum := Part->Partnum
    mQty := 0
    manother := "Y"
    DO WHILE manother = "Y"
        Scroll()
        DispBox( 0, 1,  2, 79, 2 )
        DispBox( 3, 1, 24, 79, 2 )
        @  1, 3 SAY Trim( Part->Partnum ) + "  " + Trim( Part->Desc )
        nl := 4
        ntotal  := 0
        ntotal := Part->Instock     // Total
        @  6, 34      SAY "Instock"
        @  6, Col() + 1 SAY Part->Instock         PICTURE "999,999.99" COLOR "G+"
        @  6, Col() + 2 SAY Trim( Part->Unit )
        @  6, Col() + 2 SAY "Used"
        @  6, Col() + 1 SAY Part->Utd             PICTURE "999,999.99" COLOR "G+"
        @  7, 53      SAY "Cost"
        @  7, Col() + 2 SAY Part->Trade           PICTURE "$999,999.99"
        @  7, Col() + 1 SAY Trim( Part->Unit )
        @  8, 49      SAY Part->Markup          PICTURE "9999.99%"
        @  8, Col() + 2 SAY Part->Wholesale       PICTURE "$999,999.99"
        @  9, 50      SAY "Sell+GST"
        @  9, Col() + 1 SAY Part->Wholesale * ( ( Control->GSTRate / 100 ) + 1 );
            PICTURE "$999,999.99"
        @  9, Col() + 1 SAY Trim( Part->Unit )
        @ 11, 47      SAY "Total Qty"
        @ 11, Col() + 4 SAY ntotal                PICTURE "999,999.99"
        @ 11, Col() + 1 SAY Trim( Part->Unit )
        @ 12, 47      SAY "Total Value"
        @ 12, Col() + 1 SAY ntotal * Part->Trade    PICTURE "$999,999.99"
        @ 18, 6      SAY "Width mm " + Str( Part->Width, 8, 2 )
        @ 18, Col() + 1 SAY "Thick mm " + Str( Part->Thick, 7, 2 )
        @ 19, 6      SAY "Length Mtr"
        @ 19, Col() + 1 SAY Part->Length PICTURE "9999.999"  COLOR "G+"
        IF Part->Unit = "Mtr      "
            @ 19, Col() + 1 SAY "LN Cost"
            @ 19, Col() + 1 SAY Part->Length * Part->Trade PICTURE "99999.99" COLOR "BG+"
        ENDIF
        @ 19, Col() + 5 SAY "Weight"
        @ 19, Col() + 1 SAY Part->Weight PICTURE "99999.99"
        SELECT Supl
        SET ORDER TO 1                       // Partnum
        SEEK mpartnum
        IF Found()
            nl := 14
            DO WHILE Supl->Partnum == mpartnum .AND. Supl->( !Eof() )
                IF nl > 23
                    nl := 14
                    Inkey( 0 )
                    Scroll( 16, 54, 23, 80 )
                ENDIF
                @ nl, 53      SAY Supl->Codeno                 COLOR "BG+"
                @ nl, Col() + 1 SAY Supl->Cost PICTURE "9999.99" COLOR "G+"
                IF Part->Unit = "Mtr      "
                    @ nl, Col() + 1 SAY Supl->Cost * Part->Length PICTURE "9999.99"
                ENDIF
                nl++
                SKIP ALIAS Supl
            ENDDO                             // Supl
        ENDIF                                // Found()
      /*
      IF Name->Status = "Y"
         nselect := 1
       ELSE
         nselect := 2
      ENDIF
      */
        nselect := 1
        IF Part->BoughtOut = "Y"
            @ 22, 10 SAY "Bought Out"      COLOR "G+"
        ELSE
            @ 22, 10 SAY "Own Manufacture" COLOR "G+"
        ENDIF
        @ 22, 30 SAY "ABC = " + Part->ABC COLOR "G+"
        @  4, 6 PROMPT "Select !!!"
        @  6, 6 PROMPT "1. Change Desc Sizes "
        @  8, 6 PROMPT "2. " + Message->Stock1 + " Stock          "
        @  9, 6 PROMPT "3. Loct Min/Oper Weight ABC = " + Part->ABC
        @ 10, 6 PROMPT "4. Memo         Edit/Delete"
        @ 11, 6 PROMPT "5. Module       Kit Set etc"
        @ 13, 6 PROMPT "6. Process Drawing         "
        // **      @ 15, 6 PROMPT "7. Location Maint          "
        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nselect == 1
            LOOP
/*
         CASE nselect == 8                           // Location
            SCROLL()
            clocate  := SPACE( 16 )
            clocdesc := SPACE( 28 )
            SELECT Part
            SET ORDER TO 4                // Locate
            GOTO TOP
            aPart_:={}
            nrecno  := 0
            DO WHILE Part->( !EOF() )
               IF Part->Locate = clocate
                  SKIP ALIAS Part
                  LOOP
               ENDIF
               IF Part->Locate = SPACE( 16 )
                  SKIP ALIAS Part
                  LOOP
               ENDIF
            IF !EMPTY( aPart_ )
               AADD( aPart_,Part->Locate;
                      +" "+Part->LocDesc;
                      +"           "+STR( RECNO(),6 ) )
               clocate := Part->Locate
            ENDIF
               SKIP ALIAS Part
            ENDDO
            DISPBOX(  1, 0, 24,52, 2 )
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum := ACHOICE(  2, 3, 23,50, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               clocate  := Part->Locate
               cLocdesc := Part->Locdesc
            ENDIF
            SELECT Part
            SET ORDER TO 1                 // Partnum
            GOTO TOP
            SCROLL()
            @  6, 8      SAY "Location" GET clocate   PICTURE "@!"
            @  6,COL()+2 SAY "Desc"     GET clocdesc  PICTURE "@X"
             READ
            mref := "    "
            @  8, 5 SAY "Replace all parts with first Four" GET mref PICTURE "!!!!"
             READ
             ApFLock( 3 )
            REPLACE ALL Part->Locate WITH clocate;
                  FOR SUBSTR( Part->Partnum, 1, 4 ) = mref
            REPLACE ALL Part->Locdesc WITH clocdesc;
                  FOR SUBSTR( Part->Partnum, 1, 4 ) = mref
            UNLOCK
*/
        CASE nselect == 3                           // Factory Stock
            mQty  := Part->Instock
            PartVol( mQty )
            LOOP
        CASE nselect == 2                         // Desc
            mok := "N"
            DO WHILE mok == "N"
                ccatno := Space( 12 )
                Scroll(  3, 0, 24, 80 )
                DispBox( 3, 0, 19, 79, 2 )
                SELECT Part
                SET ORDER TO 1
                ccatno := Part->Catno
                @  4, 6 SAY Space( 65 )
                @  4, 7 SAY "Catalogue :" GET ccatno PICTURE "@!"
                READ
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                mmarkup := Part->Markup
                IF ccatno == Space( 12 )
                    ccatno := "XXXXXXXXXXXX"
                ENDIF
                SELECT Cat
                IF LastRec() != 0
                    SEEK ccatno
                    IF !Found()
                        SAVE SCREEN TO tempscr
                        mok := "N"
                        DO WHILE mok == "N"
                            CatArray()            // This sorts out Cat File
                            Scroll(  15, 0, 24, 80 )
                            DispBox( 15, 0, 19, 79, 2 )
                            @ 16, 7 SAY "Catalogue # :" GET ccatno PICTURE "@K!"
                            READ
                            SEEK ccatno
                            SELECT Cat
                            IF !Found()
                                ApFLock( 3 )
                                APPEND BLANK
                                Cat->Catno := ccatno
                                UNLOCK
                            ENDIF
                            mcatdesc := Cat->CatDesc
                            @  18, 7 SAY "Description :" GET mcatdesc PICTURE "@X"
                            READ
                            ApFLock( 3 )
                            Cat->Catdesc := mcatdesc
                            UNLOCK
                            mok := "Y"
                        ENDDO
                        RESTORE SCREEN FROM tempscr
                    ENDIF
                ENDIF
                SELECT Part
                ApRLock( 3 )
                Part->Catno := ccatno
                UNLOCK
                SELECT Cat
                SEEK ccatno
                SELECT Part
                mpartId := Part->PartId
                @  4, 7 SAY ccatno + "  " + Cat->Catdesc COLOR "G+"
                @  6, 8 SAY "Group :" GET mpartId PICTURE "@K!"
                @  6, Col() + 2 SAY "Blank for Look up"
                READ
                ApRLock( 3 )
                Part->PartId := mpartId
                Part->Catno  := ccatno
                UNLOCK
                cpartId  := Space( 16 )
                IF mpartId = Space( 16 )
                    SAVE SCREEN TO tempscr
                    SELECT Part
                    SET ORDER TO 3                // PartID
                    @  7, 8 SAY "Cat - Group"
                    Scroll( 8, 3, 24, 26 )
                    aPart_ := {}
                    nrecno   := 0
                    cpartId  := Space( 16 )
                    IF LastRec() != 0
                        // **        SEEK ccatno
                        // **             DO WHILE Part->Catno = ccatno .AND. Part->( !EOF() )
                        DO WHILE Part->( !Eof() )
                            IF Part->Catno != ccatno
                                SKIP ALIAS Part
                                LOOP
                            ENDIF
                            DO WHILE Part->PartId = cpartId
                                SKIP ALIAS Part
                                LOOP
                            ENDDO
                            AAdd( aPart_, Part->PartId + "    " + Str( RecNo(),6 ) )
                            cpartId := Part->PartId
                            SKIP ALIAS Part
                        ENDDO
                        DispBox(  8, 5, 24, 26, 2 )
                        IF !Empty( aPart_ )
                            ASort( aPart_,,, {| x, y | x < y } )
                            anum := AChoice(  9,  7, 23, 24, aPart_,, "AFUNC" )
                            nrecno := Val( Right( aPart_[ anum ],6 ) )
                            GOTO nrecno
                        ENDIF
                    ENDIF                          // LastRec
                    cpartId := Part->PartId
                    RESTORE SCREEN FROM tempscr
                    SELECT Part
                    SET ORDER TO 1                 // Partnum
                    SEEK mpartnum
                    mpartId := cpartId
                    Scroll( 6, 4, 6, 70 )
                    @  6, 8 SAY "Group :" GET mpartId PICTURE "@!"
                    READ
                    ApRLock( 3 )
                    Part->PartId := mpartId
                    UNLOCK
                ENDIF                         // PartId = SPACE( 16 )
                clocate  := Part->Locate
                clocDesc := Part->Locdesc
                mlookup  := Part->Locate
                Scroll( 5, 2, 6, 70 )
                @  4, 7 SAY ccatno + " " + Trim( Cat->Catdesc );
                    + " " + Trim( Part->PartId ) COLOR "RG+"
                @  5, 7 SAY Part->Locate + "  " + Part->LocDesc COLOR "RG+"
                @  6, 8 SAY "Location :" GET clocate PICTURE "@!"
                @  6, Col() + 2 SAY "Blank for Look up"
                READ
                IF clocate = Space( 4 )
                    SAVE SCREEN TO tempscr
                    SELECT Part
                    SET ORDER TO 4                // Locate
                    GOTO TOP
                    Scroll()
                    aPart_ := {}
                    nrecno  := 0
                    clocate := Space( 16 )
                    DO WHILE Part->( !Eof() )
                        IF Part->Locate = clocate
                            SKIP ALIAS Part
                            LOOP
                        ENDIF
                        IF Part->Locate = Space( 16 )
                            SKIP ALIAS Part
                            LOOP
                        ENDIF
                        AAdd( aPart_, Part->Locate;
                            + " " + Part->LocDesc;
                            + "           " + Str( RecNo(), 6 ) )
                        clocate := Part->Locate
                        SKIP ALIAS Part
                    ENDDO
                    DispBox(  0, 0, 24, 52, 2 )
                    IF !Empty( aPart_ )
                        ASort( aPart_,,, {| x, y | x < y } )
                        anum := AChoice(  1, 3, 23, 50, aPart_,, "AFUNC" )
                        nrecno := Val( Right( aPart_[ anum ],6 ) )
                        GOTO nrecno
                        clocate  := Part->Locate
                        cLocdesc := Part->Locdesc
                    ENDIF
                    RESTORE SCREEN FROM tempscr
                ENDIF                          // mlookup
                Scroll( 6, 2, 6, 70 )
                SELECT Part
                SET ORDER TO 1                 // Partnum
                SEEK mpartnum
                ApRLock( 3 )
                Part->Locate   := clocate
                Part->LocDesc  := clocDesc
                @  6, 8      SAY "Location" GET Part->LOCATE   PICTURE "@!"
                @  6, Col() + 2 SAY "Desc"     GET Part->Locdesc  PICTURE "@X"
                READ
                UNLOCK

                IF SubStr( Part->Desc, 1, 8 ) = "New Part"
                    @  8, 25 SAY "Select Similar Description from Catalogue" COLOR "BG+"
                    mdesc  := Part->Desc
                    aPart_ := {}
                    SELECT Part
                    SET ORDER TO 2  // Catno Index
                    SEEK ccatno
                    IF LastRec() != 0
                        DO WHILE Part->Catno == ccatno
                            AAdd( aPart_, Part->Desc;
                                + "   " + Str( RecNo(), 6 ) )
                            SKIP ALIAS Part
                        ENDDO
                        nrecno := 0
                        Scroll(  10, 0, 24, 74 )
                        DispBox( 10, 5, 23, 52, 2 )
                        IF !Empty( aPart_ )
                            ASort( aPart_,,, {| x, y | x < y } )
                            anum := AChoice( 11, 7, 22, 50, aPart_,, "AFUNC" )
                            IF PressedEsc()
                                RETURN NIL
                            ENDIF
                            nrecno := Val( Right( aPart_[ anum ],6 ) )
                            GOTO nrecno
                            mdesc  := Part->Desc
                        ENDIF                             // Empty
                    ENDIF                                // LastRec
                    SELECT Part
                    SET ORDER TO 1                       // Partnum Index
                    SEEK mpartnum                        // Finds Partnum Again
                    ApRLock( 3 )
                    Part->Desc := mdesc
                    UNLOCK
                ENDIF                                       // Part Trade = 0
                @  8, 10 SAY Part->Partnum + " " + Part->Desc
                @ 10, 25 SAY Part->Detail
                Scroll( 11, 0, 24, 80 )
                DispBox( 3, 0, 24, 79, 2 )
                SELECT Supl
                SET ORDER TO 1
                SEEK Part->Partnum
                IF Found()
                    nl := 20
                    @ nl, 10 SAY "Suppliers"
                    DO WHILE Supl->Partnum == mpartnum .AND. Supl->( !Eof() )
                        IF nl > 24
                            nl := 20
                            Inkey( 0 )
                            Scroll( 20, 0, 24, 78 )
                        ENDIF
                        @ nl, 22      SAY Supl->Codeno COLOR "BG+"
                        @ nl, Col() + 2 SAY Supl->Cost PICTURE "99,999.99" COLOR "BG+"
                        nl++
                        SKIP ALIAS Supl
                    ENDDO
                ENDIF                                  // Found
                SELECT Part
                Parcodeno := Part->Codeno
                mdesc     := Part->Desc
                mdetail   := Part->Detail
                mdetail1  := Part->Detail1
                mdetail2  := Part->Detail2
                mdetail3  := Part->Detail3
                nwidth    := Part->Width
                nthick    := Part->Thick
                nlength   := Part->Length
                clocate   := Part->Locate
                clocDesc  := Part->LocDesc
                Scroll(  8, 2, 18, 78 )
                @  8, 8      SAY Part->Partnum                PICTURE "@!"
                @  8, 29                         GET mdesc     PICTURE "@X"
                @  9, 29                         GET mdetail   PICTURE "@X"
                @ 10, 29                         GET mdetail1  PICTURE "@X"
                @ 11, 29                         GET mdetail2  PICTURE "@X"
                @ 12, 29                         GET mdetail3  PICTURE "@X"
                @ 13, 8      SAY "Width mm"     GET nwidth    PICTURE "99999.99"
                @ 13, Col() + 2 SAY "Thick mm"     GET nthick    PICTURE "99999.99"
                @ 13, Col() + 2 SAY "Length Mtr"   GET nlength   PICTURE "99999.999"
                @ 15, 8      SAY "Suppl Blank to Change" GET Parcodeno PICTURE "@K!"
                READ
                SELECT Name
                SEEK ParCodeno
                DO WHILE !Found()
                    SAVE SCREEN TO Partscrn
                    mcodeno := Space( 8 )
                    Namerank( @mcodeno )                       // XlF_Name
                    mcodeno := Name->Codeno
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    SELECT Name
                    SEEK mcodeno
                    RESTORE SCREEN FROM Partscrn
                    SELECT Part
                    ApFLock( 3 )
                    Part->Codeno := Name->Codeno
                    UNLOCK
                    @ 15, 31 SAY Part->Codeno
                ENDDO
                IF Found()
                    SELECT Part
                    ApFLock( 3 )
                    Part->Codeno := Name->Codeno
                    UNLOCK
                    @ 15, 31 SAY Part->Codeno
                ENDIF
                SELECT Part
                ApRLock( 3 )
                Part->Desc     := mdesc
                Part->Detail   := mdetail
                Part->Detail1  := mdetail1
                Part->Detail2  := mdetail2
                Part->Detail3  := mdetail3
                Part->Width    := nwidth
                Part->Thick    := nthick
                Part->Length   := nlength
                UNLOCK
                SELECT Supl
                SET ORDER TO 1               // Partnum+Codeno
                SEEK Part->Partnum + Part->Codeno
                ApFLock( 3 )
                IF !Found()
                    APPEND BLANK
                    Supl->Partnum := Part->Partnum
                    Supl->Codeno  := Name->Codeno
                ENDIF                                  // Found
                @ 15, 42 SAY "Suppl Part #" GET Supl->SuppId
                READ
                UNLOCK
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
                Scroll( 18, 2, 22, 78 )
                @ 19, 8      PROMPT "Each  "
                @ 19, Col() + 2 PROMPT "Mtr   "
                @ 19, Col() + 2 PROMPT "Sq Mtr"
                @ 19, Col() + 2 PROMPT "Cu Mtr"
                MENU TO nselect
                ApFLock( 3 )
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
                @ 19, 47 SAY "Weight" GET Part->Weight PICTURE "99999.99"
                READ
                UNLOCK
                DO CASE
                CASE Part->Boughtout = "Y"
                    nselect := 1
                OTHERWISE
                    nselect := 2
                ENDCASE
                @ 21, 8      PROMPT "Part Bought Out"
                @ 21, Col() + 2 PROMPT "Own Manufacture"
                MENU TO nselect
                ApFLock( 3 )
                DO CASE
                CASE nselect == 1
                    Part->Boughtout := "Y"
                CASE nselect == 2
                    Part->Boughtout := "N"
                ENDCASE
                UNLOCK
                SELECT Control
                ApRLock( 3 )
                Control->PartCode := Part->Codeno
                UNLOCK
                mok := "Y"
                Scroll( 11, 2, 23, 78 )
                SELECT Part
                DO CASE
                CASE Part->ABC = "A"
                    nselect := 1
                CASE Part->ABC = "B"
                    nselect := 2
                CASE Part->ABC = "C"
                    nselect := 3
                CASE Part->ABC = "D"
                    nselect := 4
                CASE Part->ABC = "E"
                    nselect := 5
                CASE Part->ABC = "F"
                    nselect := 6
                CASE Part->ABC = "M"
                    nselect := 7
                CASE Part->ABC = "Z"
                    nselect := 8
                CASE Part->ABC = " "
                    nselect := 9
                ENDCASE
                @ 12, 10 SAY "Part ABC = " + Part->ABC
                @ 13, 10 PROMPT "1. A - High Priority  "
                @ 14, 10 PROMPT "2. B - Med  Priority  "
                @ 15, 10 PROMPT "3. C - Low  Priority  "
                @ 16, 10 PROMPT "4. D -                "
                @ 17, 10 PROMPT "5. E - Own Manufacture"
                @ 18, 10 PROMPT "6. F - Materials Steel"
                @ 19, 10 PROMPT "7. M - Modules        "
                @ 20, 10 PROMPT "8. Z - Contractors    "
                @ 21, 10 PROMPT "9. ALL selected       "
                MENU TO nselect
                SELECT Part
                ApRLock( 3 )
                DO CASE
                CASE nselect == 1
                    Part->ABC := "A"
                CASE nselect == 2
                    Part->ABC := "B"
                CASE nselect == 3
                    Part->ABC := "C"
                CASE nselect == 4
                    Part->ABC := "D"
                CASE nselect == 5
                    Part->ABC := "E"
                CASE nselect == 6
                    Part->ABC := "F"
                CASE nselect == 7
                    Part->ABC := "M"
                CASE nselect == 8
                    Part->ABC := "Z"
                CASE nselect == 9
                    Part->ABC := " "
                ENDCASE
                UNLOCK
            ENDDO                                              // mok
            LOOP

        CASE nselect == 4                               // Qty Etc
            SELECT Part
            SET ORDER TO 1
            SEEK mpartnum
            clocate  := Part->Locate
            clocDesc := Part->Locdesc
            mlookup  := Part->Locate
            Scroll( 4, 2, 23, 78 )
            @  5, 7 SAY Part->Locate + "  " + Part->LocDesc COLOR "G+"
            @  7, 10 SAY "Location :" GET mlookup PICTURE "@!"
            @  7, Col() + 2 SAY "Blank for Look up"
            READ
            IF mlookup = Space( 4 )
                SAVE SCREEN TO tempscr
                SELECT Part
                SET ORDER TO 4             // Locate
                Scroll()
                @  2, 7 SAY Part->Locate + " " + Part->LocDesc COLOR "RG+"
                aPart_ := {}
                nrecno  := 0
                clocate := Space( 16 )
                DO WHILE Part->( !Eof() )
                    DO WHILE Part->Locate = clocate
                        SKIP ALIAS Part
                        LOOP
                    ENDDO
                    IF Part->Locate = Space( 16 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                    AAdd( aPart_, Part->Locate;
                        + " " + Part->LocDesc;
                        + "           " + Str( RecNo(), 6 ) )
                    clocate := Part->Locate
                    SKIP ALIAS Part
                ENDDO
                DispBox(  4, 0, 24, 52, 2 )
                @ 24, 60 SAY " DT311A "
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice(  5, 3, 23, 50, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                    clocate  := Part->Locate
                    cLocdesc := Part->Locdesc
                ENDIF
                RESTORE SCREEN FROM tempscr
            ENDIF                          // Found()
            SELECT Part
            SET ORDER TO 1                 // Partnum
            SEEK mpartnum
            Scroll( 4, 2, 23, 78 )
            nl := 6
            ApRLock( 3 )
            @ nl, 8      SAY "Location" GET Part->LOCATE   PICTURE "@!"
            @ nl, Col() + 2 SAY "Desc"     GET Part->Locdesc  PICTURE "@X"
            READ
            nl += 2
            @ nl, 8 SAY "Desc :"            GET Part->Desc    PICTURE "@!"
            nl += 2
            @ nl, 8 SAY "Cost :"      GET Part->Trade   PICTURE "999999.99"
            @ nl, Col() + 2 SAY "Sell :" GET Part->Wholesale PICTURE "999999.99"
            @ nl, Col() + 1 SAY ( Part->Trade * ( 1 + ( Part->Markup / 100 ) ) ) PICTURE "999999.99"
            READ
            Part->Markup := ( ( Part->Wholesale - Part->Trade );
                / Part->Trade ) * 100
            IF Part->Margin == 0
                Part->Margin := Part->Markup
            ENDIF
            Part->Retail := ( Part->Wholesale * ( 1 + (Part->Margin / 100 ) ) )
            Part->Margin := ( ( Part->Retail - Part->Wholesale );
                / Part->Wholesale ) * 100
            IF Part->RetIndiv == 0
                Part->RetIndiv := Part->Wholesale * ( ( Control->GSTRate / 100 ) + 1 )
            ENDIF
            nl += 2
            @ nl, 8      SAY "Indiv Price Inc GST";
                GET Part->RetIndiv PICTURE "999999.99"
            @ nl, Col() + 2 SAY "Sell Inc GST" COLOR "G+"
            @ nl, Col() + 2 SAY Part->Wholesale * ( ( Control->GSTRate / 100 ) + 1 );
                PICTURE "$999,999.99" COLOR "G+"
            READ
            nl += 2
            @ nl, 8      SAY "Used"    GET Part->Utd     PICTURE "9999999.99"
            @ nl, Col() + 2 SAY "Minimum" GET Part->Minstk  PICTURE "99999.99"
            @ nl, Col() + 2 SAY "ABC"     GET Part->ABC     PICTURE "!"
            @ nl, Col() + 2 SAY "Maximum" GET Part->Maxstk  PICTURE "99999.99"
            // **  nl++
            // ** @ nl, 9 SAY "Qty per Box :" GET Part->BoxQty  PICTURE "9999.999"
            nl += 2
            @ nl, 8      SAY "Weight"       GET Part->Weight  PICTURE "9999.99"
            READ
            Part->Markup := ( ( Part->Wholesale - Part->Trade );
                / Part->Trade ) * 100
            IF Part->Margin == 0
                Part->Margin := Part->Markup
            ENDIF
            Part->Retail := ( Part->Wholesale * ( 1 + (Part->Margin / 100 ) ) )
            Part->Margin := ( ( Part->Retail - Part->Wholesale );
                / Part->Wholesale ) * 100
            IF Part->RetIndiv == 0
                Part->RetIndiv := Part->Wholesale * ( ( Control->GSTRate / 100 ) + 1 )
            ENDIF
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
            nl += 2
            @ nl, 8      PROMPT "Each  "
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
            Scroll( 11, 2, 23, 78 )
            DO CASE
            CASE Part->ABC = "A"
                nselect := 1
            CASE Part->ABC = "B"
                nselect := 2
            CASE Part->ABC = "C"
                nselect := 3
            CASE Part->ABC = "D"
                nselect := 4
            CASE Part->ABC = "E"
                nselect := 5
            CASE Part->ABC = "F"
                nselect := 6
            CASE Part->ABC = "M"
                nselect := 7
            CASE Part->ABC = "Z"
                nselect := 8
            CASE Part->ABC = " "
                nselect := 9
            ENDCASE
            @ 12, 10 SAY "Part ABC = " + Part->ABC
            @ 13, 10 PROMPT "1. A - High Priority  "
            @ 14, 10 PROMPT "2. B - Med  Priority  "
            @ 15, 10 PROMPT "3. C - Low  Priority  "
            @ 16, 10 PROMPT "4. D -                "
            @ 17, 10 PROMPT "5. E - Own Manufacture"
            @ 18, 10 PROMPT "6. F - Materials Steel"
            @ 19, 10 PROMPT "7. M - Modules        "
            @ 20, 10 PROMPT "8. Z - Contractors    "
            @ 21, 10 PROMPT "9. ALL selected       "
            MENU TO nselect
            SELECT Part
            ApRLock( 3 )
            DO CASE
            CASE nselect == 1
                Part->ABC := "A"
            CASE nselect == 2
                Part->ABC := "B"
            CASE nselect == 3
                Part->ABC := "C"
            CASE nselect == 4
                Part->ABC := "D"
            CASE nselect == 5
                Part->ABC := "E"
            CASE nselect == 6
                Part->ABC := "F"
            CASE nselect == 7
                Part->ABC := "M"
            CASE nselect == 8
                Part->ABC := "Z"
            CASE nselect == 9
                Part->ABC := " "
            ENDCASE
            UNLOCK
            LOOP

        CASE nselect == 5                                // Memo
            tempscrn := SaveScreen( 11, 0, 24, 80 )
            coderef  := mpartnum

            M2Memofile( coderef )                     // XF_Memo2
            /*
            mok := ApGetN( TRIM( Message->Delete )+" Memo" )
            IF mok == "Y"
               SELECT Cusnotes
               SEEK coderef
                ApFLock( 3 )
               DO WHILE FOUND()
                  DELETE
                  SEEK coderef
               ENDDO
               UNLOCK
               SELECT Part
             ENDIF
            */
            RestScreen( 11, 0, 24, 80, tempscrn )
            LOOP

        CASE nselect == 6                               // Equipment
            cpartorg := mpartnum
            mmodcode := Trim( mpartnum )
            // **         SAVE SCREEN TO Tempscrn
            SELECT EquDesc
            SET ORDER TO 1
            GOTO TOP
            SEEK mmodcode
            IF Found()
                mmodcode := EquDesc->Modcode
            ELSE
                ApFLock( 3 )
                APPEND BLANK
                EquDesc->ModCode := Trim( Part->Partnum )
                EquDesc->Desc    := Part->Desc
                UNLOCK
                csyscode := Part->Partnum
                Scroll( 1, 2, 1, 78 )
                @  1, 5 SAY EquDesc->ModCode + "  " + EquDesc->Desc
                mmodcode := EquDesc->ModCode
                tempscrn := SaveScreen( 11, 0, 24, 80 )

                EquSearch( mmodcode )

                RestScreen( 11, 0, 24, 80, tempscrn )
                SELECT Part
                SEEK csyscode
                mpartnum := Part->Partnum
                mmodcode := EquDesc->ModCode
            ENDIF
            ntotal := nwholesale := 0
            tempscrn := SaveScreen( 0, 0, 24, 80 )
            EquSearch( @mmodcode )               // XLF_Equ3
            RestScreen(  0, 0, 24, 80, tempscrn )
            LOOP

        CASE nselect == 7                               // Operations
            PartOper2( mpartnum )                     // XF2PPART
            LOOP

        ENDCASE
        manother := "Y"
        COMMIT
    ENDDO                    // manother

    RETURN mQty

// **------ End of ProfQty()

// ** -------------------------------------------------------------------------

FUNCTION DrawReview()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        mpartnum := Part->Partnum
        Scroll( 20, 0, 24, 80 )
        DispBox( 20, 1, 24, 79, 2 )
        @ 20, 10 SAY "  " + mpartnum COLOR "BG+"
        nselect := 1
        @ 22, 6      PROMPT "1. Add Drawing"
        @ 22, Col() + 2 PROMPT "2. Edit/Delete Drawings"
        @ 22, Col() + 2 PROMPT "3. Print Drawings"
        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nselect == 3                 // Print
            mwhere := "S"
            npl    := 64
            nl     := 0

            Printsel()                               // _LF_Init

            IF mwhere == "P"
                npl := 64
                @  0, 0
                SET DEVICE TO PRINT
            ENDIF
            @ nl, 2 SAY Control->U_Name
            @ nl, 42 SAY "Drawings"
            @ nl, 62 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            nl += 2
            SELECT PartOper
            SET ORDER TO 1         // Partnum
            GOTO TOP
            SEEK mpartnum
            DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !Eof() )
                IF PartOper->Drawno = Space( 8 )
                    SKIP ALIAS PartOper
                    LOOP
                ENDIF
                // **         SELECT Drawing
                // **         SEEK PartOper->Drawno
                // **         SELECT PartOper
                @ nl,  3 SAY PartOper->Drawno + " " + SubStr( PartOper->Partnum, 1, 16 );
                    + " " + PartOper->Desc + " " + PartOper->Operno
                nl++
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        Inkey( 0 )
                        Scroll()
                    ENDIF
                    nl := 0
                ENDIF             // npl
                SKIP ALIAS PartOper
            ENDDO                        // PartOper EOF

   /*
      SELECT Drawing
      GOTO TOP
      DO WHILE Drawing->( !EOF() )
         IF SUBSTR( Control->U_Name, 1, 4 ) = "SHAN"
            @ nl, 1 SAY Drawing->Desc
          ELSE
            @ nl, 1 SAY Drawing->Desc
            @ nl,42 SAY Drawing->Drawno
            @ nl,53 SAY Drawing->DrawLoc
         ENDIF
         nl++
         IF nl > npl
            IF mwhere = "P"
               EJECT
              ELSE
               INKEY( 0 )
               SCROLL()
            ENDIF
            nl := 0
         ENDIF             // npl
         SKIP ALIAS Drawing
      ENDDO                        // Drawing EOF
   */

            IF mwhere = "P"
                // **   @ nl, 0 SAY " "
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
            LOOP
        CASE nselect == 1                 // Add Drawing
            Scroll()
            DispBox( 0, 1, 11, 79, 2 )
            @ 0, 8 SAY "  Viewing Drawings   F2 To Add Drawing "
            nl := 1
            SELECT PartOper
            SET ORDER TO 1         // Partnum
            GOTO TOP
            SEEK mpartnum
            DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !Eof() )
                IF PartOper->Drawno = Space( 8 )
                    SKIP ALIAS PartOper
                    LOOP
                ENDIF
                SELECT Drawing
                SEEK PartOper->Drawno
                SELECT PartOper
                @ nl,  3 SAY PartOper->Drawno + " " + SubStr( PartOper->Partnum, 1, 16 );
                    + " " + PartOper->Desc + " " + PartOper->Operno
                nl++
                IF nl >= 9
                    WAIT  // INKEY()
                    Scroll()
                    DispBox( 0, 1, 11, 79, 2 )
                    @ 0, 8 SAY "  Viewing Drawings   F2 To Add Drawing "
                    nl := 1
                ENDIF
                SKIP ALIAS PartOper
            ENDDO                        // PartOper EOF
            cdrawno := Space( 8 )
            aPart_ := {}
            nrecno   := 0
            SELECT Drawing
            GOTO TOP
            DO WHILE Drawing->( !Eof() )
                AAdd( aPart_, Drawing->Drawno;
                    + " " + Drawing->Desc;
                    + " " + Drawing->DrawLoc;
                    + "                     " + Str( RecNo(), 6 ) )
                SKIP ALIAS Drawing
            ENDDO                        // Drawing EOF
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                Scroll(  6, 0, 24, 80 )
                DispBox( 6, 1, 24, 79, 2 )
                anum := AChoice(  7, 3, 23, 78, aPart_,, "AFUNC" )
                IF LastKey() == -1
                    JobDraw()                           // Below
                ENDIF
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                Scroll(  19, 0, 24, 80 )
                DispBox( 19, 1, 24, 79, 2 )
                nl := 20
                @ nl, 10 SAY Drawing->Drawno COLOR "BG+"
                nl += 2
                cdrawno := Drawing->Drawno
                ApFlock( 3 )
                @ nl, 6      SAY "Desc" GET Drawing->Desc PICTURE "@X"
                @ nl, Col() + 2 GET Drawing->DrawLoc         PICTURE "@X"
                READ
                // **         Drawing->DrawLoc := SUBSTR( mpartnum, 1,16 )
                UNLOCK
            ENDIF                        // Empty
            SELECT PartOper
            ApFlock( 3 )
            APPEND BLANK
            PartOper->Partnum   := mpartnum
            PartOper->Drawno    := cdrawno
            PartOper->Desc      := Drawing->Desc
            PartOper->Desc1     := Drawing->DrawLoc
            PartOper->Operno    := "DRAWING"
            PartOper->Date      := Date()
            PartOper->Order     := "MD"
            UNLOCK
            LOOP

        CASE nselect == 2                 // Edit-Delete Drawing
            SELECT PartOper
            SET ORDER TO 1         // Partnum
            aPart_ := {}
            nrecno  := 0
            GOTO TOP
            SEEK mpartnum
            DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !Eof() )
                IF PartOper->Drawno = Space( 8 )
                    SKIP ALIAS PartOper
                    LOOP
                ENDIF
                SELECT Drawing
                SEEK PartOper->Drawno
                SELECT PartOper
                AAdd( aPart_, PartOper->Drawno;
                    + " " + PartOper->Desc;
                    + " " + SubStr( PartOper->Partnum, 1, 16 );
                    + " " + PartOper->Operno;
                    + "            " + Str( RecNo(), 6 ) )
                SKIP ALIAS PartOper
            ENDDO                        // PartOper EOF
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                Scroll(  3, 0, 24, 80 )
                DispBox( 3, 1, 24, 79, 2 )
                anum := AChoice(  4, 3, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                Scroll(  11, 0, 24, 80 )
                DispBox( 11, 1, 18, 79, 2 )
                nl := 12
                @ nl, 6 SAY PartOper->Drawno + "  " + PartOper->Partnum + " " + DToC( PartOper->Date )
                nl += 2
                SELECT Drawing
                SEEK PartOper->Drawno
                ApFLock( 3 )
                @ nl, 10      SAY "Desc" GET Drawing->Desc
                @ nl, Col() + 2 SAY Drawing->DrawLoc
                READ
                Drawing->DrawLoc := SubStr( mpartnum, 1, 16 )
                UNLOCK
                SELECT PartOper
                Scroll( 19, 0, 24, 80 )
                cstring := Trim( Message->Suredel )
                mok := ApCheck( cstring )                     // AppX.PRG
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                IF mok == "Y"
                    ApFLock( 3 )
                    DELETE
                    UNLOCK
                ENDIF
            ENDIF
            LOOP
        ENDCASE

    ENDDO       // mcontinue

    RETURN NIL

// ****** End of DrawReview()

// **-------------------------------------------------------------------

FUNCTION EquCost( mmod1 )

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
   /*
      npartqty := 0
      aPart_ := {}
      anum   := {}
      nlabpart := 0
         nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
         nqty1:= nqty2:= nqty3:= nqty4 := 0
         nequ1:= nequ2:= nequ3:= nequ4 := 0
         nquot := 1
         SELECT Equ
         GOTO TOP
         SET EXACT ON
         SEEK mmod1                // Original Part
         IF !FOUND()
            mpart := Part->Partnum
            @ 18,10 SAY mmod1
            WAIT" NO PARTS IN MODULE PLEASE ADD"
            IF PressedEsc()
               RETURN NIL
            ENDIF
              EquPartAdd( @mmodcode )     // XLF_Equ4
            SELECT Equ
            SEEK mmod1
         ENDIF                 // ! Found
         IF FOUND()
            DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
               npartqty++
               ***      AADD( aPart_," " )
               nqty1 := Equ->PartQty * nquot
               SELECT Part
               SEEK Equ->Partnum
               SELECT Equ
               IF Equ->Partnum = Message->LabPart
                  nlabpart += nqty1
               ENDIF
               AADD( aPart_,".   "+SUBSTR( Equ->Modcode, 1,12 );
                  +"  "+SUBSTR( Part->Partnum, 1, 9 );
                  +" "+SUBSTR( Part->Desc, 1,30 );
                  +" "+STR( Equ->Partqty, 9, 3 );
                  +" "+STR( Part->Trade, 8, 2 );
                  +"        "+STR( RECNO(),6 ) )
               mmod2 := TRIM( Equ->Partnum )
               nrecno2 := RECNO()
               GOTO TOP
               SEEK mmod2
               IF FOUND()
                  ***         AADD( aPart_," " )
                  DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
                     npartqty++
                     nequ2 := Equ->PartQty * nequ1
                     IF Equ->Partnum = Message->LabPart
                        nlabpart += nequ2
                     ENDIF
                     SELECT Part
                     SEEK Equ->Partnum
                     SELECT Equ
                     AADD( aPart_,"..  "+SUBSTR( Equ->Modcode, 1,12 );
                        +"  "+SUBSTR( Part->Partnum, 1, 9 );
                        +" "+SUBSTR( Part->Desc, 1,30 );
                        +" "+STR( Equ->Partqty, 9, 3 );
                        +" "+STR( Part->Trade, 8, 2 );
                        +"        "+STR( RECNO(),6 ) )

                     mmod3 := TRIM( Equ->Partnum )
                     nrecno3 := RECNO()
                     GOTO TOP
                     SEEK mmod3
                     IF FOUND()
                        ***         AADD( aPart_," " )
                        DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
                           npartqty++
                           nequ3 := Equ->PartQty * nequ2
                           IF Equ->Partnum = Message->LabPart
                              nlabpart += nequ3
                           ENDIF
                           SELECT Part
                           SEEK Equ->Partnum
                           SELECT Equ
                           AADD( aPart_,"... "+SUBSTR( Equ->Modcode, 1,12 );
                              +"  "+SUBSTR( Part->Partnum, 1, 9 );
                              +" "+SUBSTR( Part->Desc, 1,30 );
                              +" "+STR( Equ->Partqty, 9, 3 );
                              +" "+STR( Part->Trade, 8, 2 );
                              +"        "+STR( RECNO(),6 ) )
                           mmod4   := TRIM( Equ->Partnum )
                           nrecno4 := RECNO()
                           GOTO TOP
                           SEEK mmod4
                           IF FOUND()
                              ***            AADD( aPart_," " )
                              DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                                 npartqty++
                                 nequ4 := Equ->PartQty * nequ3
                                 IF Equ->Partnum = Message->LabPart
                                    nlabpart += nequ4
                                 ENDIF
                                 SELECT Part
                                 SEEK Equ->Partnum
                                 SELECT Equ
                                 AADD( aPart_,"...."+SUBSTR( Equ->Modcode, 1,12 );
                                    +"  "+SUBSTR( Part->Partnum, 1, 9 );
                                    +" "+SUBSTR( Part->Desc, 1,30 );
                                    +" "+STR( Equ->Partqty, 9, 3 );
                                    +" "+STR( Part->Trade, 8, 2 );
                                    +"        "+STR( RECNO(),6 ) )
                                 SKIP ALIAS Equ
                              ENDDO                       //  mmod4
                           ENDIF
                           SELECT Equ
                           GOTO nrecno4
                           SKIP ALIAS Equ
                        ENDDO                       //  mmod3
                     ENDIF                          // FOUND()  mmod3
                  SELECT Equ
                  GOTO nrecno3
                  SKIP ALIAS Equ
               ENDDO                       //  mmod2 EOF()
            ENDIF                         // Found mmod2
            SELECT Equ
            GOTO nrecno2
            SKIP ALIAS Equ
         ENDDO                       //   mmod1 EOF()
      ENDIF                          // Found mmod1
      SET EXACT OFF
      SELECT Part
      SET ORDER TO 1
      SEEK mmod1
      @  0, 1      SAY Part->Partnum COLOR "G+"
      @  0,COL()+1 SAY Part->Desc    COLOR "G+"
      @  0,COL()+2 SAY "Parts "+STR( npartqty, 5 )
      DISPBOX(  1, 0, 24,79, 2 )
      IF  nlabpart > 0
         @  24, 3 SAY Message->LabPart
         @  24,24 SAY nlabpart PICTURE "9,999.99"
      ENDIF
      IF !EMPTY( aPart_ )
         ***      ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  2, 1, 23,78, aPart_,,"AFUNC" )
         IF PressedEsc()
            EXIT
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         SELECT Equ
         GOTO nrecno
         mmodcode := Equ->ModCode
         SELECT EquDesc
         SEEK Equ->Modcode
         SELECT Part
         SET ORDER TO 1
         SEEK mmodcode                  // Finds original Part
         mpartnum := Part->Partnum
         IF FOUND()
            ***        tempscrn := SAVESCREEN( 0, 0, 24,80 )
            EquSearch( @mmodcode )               // XLF_Equ3
            ***        RESTSCREEN(  0, 0, 24,80,tempscrn )
         ENDIF                   // FOUND                                              // mcontinue
      ENDIF
   */
        mmmodcode := mmod1
        EquSearch( @mmodcode )               // XLF_Equ3
        mcontinue := "N"
    ENDDO
    SELECT Part
    SEEK mmod1                  // Finds original Part
    SELECT Quot
    SET ORDER TO 1

    RETURN NIL
// ****** End of EquCost()

// **-------------------------------------------------------------------

FUNCTION MenuPart( nc, nl )

    DO WHILE .T.

        mcodeno  := Space( 8 )
        ccatno   := Space( 12 )                    // Required by PartAdd
        nselect  := 1
        nc       := ncl
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        nl := 5
        // **   maction := SUBSTR( Message->LabPart, 1, 8 )

        PartAction()                      // ZSA_Name

        @  4, nc + ( ncl / 2 ) -( Len( RTrim( Menu2->CH_PartHd ) ) / 2 );
            SAY RTrim( Menu2->CH_PartHd )
        @  7, nc + 2 PROMPT "1. Part Find        "
        @  9, nc + 2 PROMPT "2. Add New Part     "
        @ 11, nc + 2 PROMPT "3. Catalogue    Menu"
        @ 13, nc + 2 PROMPT "4. Module       Menu"
        @ 14, nc + 2 PROMPT "5. History      Menu"
        @ 16, nc + 2 PROMPT "6. Parts Print  Menu"
        @ 17, nc + 2 PROMPT "7. Stock Take   Menu"
        @ 18, nc + 2 PROMPT "8. Part ABC     Menu"

        @ 20, nc + 2 PROMPT Menu->CH_Main
        MENU TO nselect

        DO CASE
        CASE nselect == 9 .OR. PressedEsc()
            EXIT
            RETURN NIL
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            mcodeno := Space( 8 )
            PartView( mcodeno )
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            mpartnum := Space( 16 )
            Partadd( @mpartnum )
            DO CASE
            CASE SubStr( Part->Partnum, 1, 3 ) = "JC-"
                mpartnum := Space( 16 )
            CASE SubStr( Part->Partnum, 1, 3 ) = "TEM"
                mpartnum := Space( 16 )
            CASE SubStr( Part->Partnum, 1, 3 ) = "ZZT"
                mpartnum := Space( 16 )
            CASE SubStr( Part->Partnum, 1, 3 ) = "TT-"
                mpartnum := Space( 16 )
            ENDCASE
            IF mpartnum = Space( 16 )
                RESTORE SCREEN FROM holdscrn
                LOOP
            ENDIF
            PartDets( mpartnum )
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            @ 11, nc + 2 SAY "3. Catalogue    Menu" COLOR "BG+"
            MU_Cat( nc, ncl )
        CASE nselect == 4
            @ 13, nc + 2 SAY "4. Module       Menu" COLOR "BG+"
            Mu_Equ( nc, ncl )                                     // XLF_Equ
        CASE nselect == 5
            @ 14, nc + 2 SAY "5. History      Menu" COLOR "BG+"
            SAVE SCREEN TO holdscrn
            Mu_Hist()                       // XF_Hist
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            @ 16, nc + 2 SAY "6. Parts Print  Menu" COLOR "BG+"
            Mu_PartList()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7
            SAVE SCREEN TO holdscrn
            @ 17, nc + 2 SAY "7. Stock Take   Menu" COLOR "BG+"
            StockAnaly()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 8
            SAVE SCREEN TO holdscrn
            @ 18, nc + 2 SAY "8. Parts ABC  Menu" COLOR "BG+"
            MenuB3()    // XLF_MenuB PartStock() // XF_Util1
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// **  End of MenuPart()

// *--------------------   End of CWPPart.PRG
