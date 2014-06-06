// *  JK 24-08-10 08:40:34

// *** REM Specific Name ( Caldwell )

/*  Program......:              ZFC_NAME.PRG
    Author.......: J.Kirby
    Date.........: 01/09/93
    Functions....: MenuName, NameGet, NameLook
*/

// (c) Copyright 1993 by Chozen Ltd Christchurch.

DO ZSF_Name

FUNCTION MenuName( nc, nl )

    DO WHILE .T.
        cheading := "NAME MENU"
        nselect  := 0
        nc       := ncl
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
/*
Taken Out Test
   SELECT Rept
   SET ORDER TO 2                           // Codeno+Stat
   GOTO TOP
      nl:= nll:= nlll := 5
      npl := 22
      ccodeno := SPACE( 8 )
      @  4,60 SAY "Reports From" COLOR "BG+"
      DO WHILE Rept->( !EOF() )
          IF Rept->Date <= DATE()-60
             SKIP ALIAS Rept
             LOOP
          ENDIF
          IF Rept->Codeno = ccodeno
             SKIP ALIAS Rept
             LOOP
          ENDIF
          DO CASE
             CASE nl <= npl
                 @ nl,60   SAY Rept->Codeno
                 nl++
             CASE nll <= npll
                 @ nll,70  SAY Rept->Codeno
                 nll++
***             OTHERWISE
***                 @ nlll,60 SAY Rept->Codeno
***                 nlll++
          ENDCASE
          ccodeno := Rept->Codeno
          SKIP ALIAS Rept
      ENDDO                          // EOF()
*/
        @  4, nc + ( ncl / 2 ) -( Len( cheading ) / 2 ) SAY cheading
        @  7, nc + 2 PROMPT "1 Name Search       "
        @  9, nc + 2 PROMPT "2 List          Name"
        @ 11, nc + 2 PROMPT "3 Delete/Change Code"
        // **   @ 13,nc+2 PROMPT "4. List       by ????"
        // **   @ 13,nc+2 PROMPT "4. Subs Due          "
        // **   @ 16,nc+2 PROMPT "6. Labels     by Exec"
        @ 20, nc + 2 PROMPT "0 To - Main         "

        MENU TO nselect

        DO CASE
        CASE nselect == 4 .OR. LastKey() == 27
            EXIT
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            Nameview()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            DO Namelist
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            Numchange()
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// *** End of MenuName()

// *---------------------------------------------------------------------*

FUNCTION Nameget( mcodeno )            // Called by Namerank, Nameadd

    mcorrect := "N"
    DO WHILE mcorrect == "N"
        Scroll()
        DispBox( 0, 1,  2, 78, 2 )
        SELECT Name
        ctitle    := Name->Title
        ccalled   := Name->Called
        cfamname  := Name->Famname
        cname     := Name->Name
        cadd1     := Name->Add1
        cadd2     := Name->Add2
        cadd3     := Name->Add3
        cadd4     := Name->Add4
        cadd5     := Name->Add5
        czip      := Name->Zip
        cephone   := Name->Ephone
        cphone    := Name->Phone
        cbphone   := Name->Bphone
        cmobphone := Name->MobPhone
        @  1, 3 SAY Name->Codeno
        @  1, Col() + 2 SAY "Title"  GET ctitle   PICTURE "!XXX"
        @  1, Col() + 2 SAY "First"  GET ccalled  PICTURE "!XXXXXXXXXXXXXXX"
        @  1, Col() + 2 SAY "Family" GET cfamname PICTURE "!XXXXXXXXXXXXXXX"
        READ
        DispBox( 3, 1, 19, 78, 2 )
        IF Name->Name = Space( 30 )
            Name->Name := Upper( Trim( Name->Famname ) ) + " " + Upper( Name->Called )
        ENDIF
        @  4, 3 SAY "Company Name :" GET cname PICTURE "@!"
        @  6, 3 SAY "St   :"         GET cadd1 PICTURE "@X"
        @  7, 3 SAY "Box. :"         GET cadd2 PICTURE "@KX"
        @  8, 8 SAY ":"              GET cadd3 PICTURE "@X"
        @  9, 3 SAY "City :"         GET cadd4 PICTURE "@KX"
        @ 10, 3 SAY "Cntry "         GET cadd5 PICTURE "@KX"
        @ 10, Col() + 1 SAY "Zip"       GET czip  PICTURE "@X"
        @  6, 45 SAY "Priv Phone :"   GET cephone   PICTURE "@X"
        @  7, 45 SAY "Bus  Phone :"   GET cphone    PICTURE "@X"
        @  8, 45 SAY "Fax Number :"   GET cbphone   PICTURE "@X"
        @  9, 45 SAY "Mobile     :"   GET cmobPhone PICTURE "@X"
        // **      @ 10,45 SAY "Pager etc  :"   GET Name->OthPhone PICTURE "@X"
        // **      @ 12,45 SAY "      Disc :"   GET Name->Discount PICTURE "99"
        // **      @ 14,45 SAY "      Mkup :"   GET Name->Margin   PICTURE "999"
        // **      @ 14,COL()+2 SAY "999 = Special"
        // **      @ 16,45 SAY "Freight Co :" GET Name->Freight  PICTURE "@K!"
        nl := 12
        ApRLock( 3 )
        Name->Title     := ctitle
        Name->Called    := ccalled
        Name->Famname   := cfamname
        Name->Name      := cname
        Name->Add1      := cadd1
        Name->Add2      := cadd2
        Name->Add3      := cadd3
        Name->Add4      := cadd4
        Name->Add5      := cadd5
        Name->Zip       := czip
        Name->Ephone    := cephone
        Name->Phone     := cphone
        Name->Bphone    := cbphone
        Name->MobPhone  := cmobphone
        UNLOCK
        Branchshow( mcodeno )                   // Below

        READ
        Scroll( 12, 3, 17, 77 )
        SELECT Name
        cexec := Name->Exec
        @ 12, 8 SAY "Province :" GET cexec PICTURE "@K!"
        @ 21, 20 SAY "Blank for Selection"
        READ
        ApRLock( 3 )
        Name->Exec := cexec
        IF Name->Exec != "CANT"
            Name->Exec := Space( 4 )
        ENDIF
        IF Name->Exec != "CENT"
            Name->Exec := Space( 4 )
        ENDIF
        IF Name->Exec != "NELS"
            Name->Exec := Space( 4 )
        ENDIF
        IF Name->Exec != "OTAG"
            Name->Exec := Space( 4 )
        ENDIF
        IF Name->Exec != "SOUT"
            Name->Exec := Space( 4 )
        ENDIF
        IF Name->Exec != "WEST"
            Name->Exec := Space( 4 )
        ENDIF
        UNLOCK
        IF Empty( Name->Exec )
            mchoice := 1
            @ 12, 48 PROMPT "Canterbury "
            @ 13, 48 PROMPT "Central    "
            @ 14, 48 PROMPT "Nelson     "
            @ 15, 48 PROMPT "Otago      "
            @ 16, 48 PROMPT "Southland  "
            @ 17, 48 PROMPT "WestCoast  "
            MENU TO mchoice
            ApRLock( 3 )
            DO CASE
            CASE mchoice == 1
                Name->Exec := "CANT"
            CASE mchoice == 2
                Name->Exec := "CENT"
            CASE mchoice == 3
                Name->Exec := "NELS"
            CASE mchoice == 4
                Name->Exec := "OTAG"
            CASE mchoice == 5
                Name->Exec := "SOUT"
            CASE mchoice == 6
                Name->Exec := "WEST"
            ENDCASE
            UNLOCK
        ENDIF
        // ***      UNLOCK
        @ 12, 8 SAY "Province " + Name->Exec + "       "
        Scroll( 12, 40, 18, 74 )
        cpaytype := Name->PayType
        @ 14, 8 SAY "Pay Type :" GET cpayType PICTURE "@K!"
        @ 21, 20 SAY "Blank Pay Type for Selection"
        READ
        ApRLock( 3 )
        Name->PayType := cpaytype
        UNLOCK
        IF Empty( Name->PayType )
            mchoice := 1
            @ 12, 48 PROMPT "Cash / Cheque "
            @ 13, 48 PROMPT "7 Day Account "
            @ 14, 48 PROMPT "Monthly       "
            // **        @ 15,48 PROMPT "Charge Through"
            @ 15, 48 PROMPT "Direct Credit "
            MENU TO mchoice
            ApRLock( 3 )
            DO CASE
            CASE mchoice == 1
                Name->PayType := "CA"
            CASE mchoice == 2
                Name->PayType := "7D"
            CASE mchoice == 3
                Name->PayType := "MO"
                // **           CASE mchoice == 4
                // **              Name->PayType := "CT"
            CASE mchoice == 4
                Name->PayType := "DC"
            ENDCASE
            @ 14, 8 SAY "Pay Type " + Name->PayType + "      "
            UNLOCK
        ENDIF
        Scroll( 12, 44, 16, 77 )
/*
      IF Name->PayType = "CT"
         @ 16, 3 SAY "Charge Through :" GET Name->Charge PICTURE "@K!"
          READ
         IF EMPTY( Name->Charge )
            mchoice := 1
            @ 12,48 PROMPT "FOODSTUFFS "
            @ 13,48 PROMPT "RATTRAYS   "
            @ 14,48 PROMPT "OTHERS     "
            MENU TO mchoice
            DO CASE
               CASE mchoice == 1
                  Name->Charge := "FOODSTUF"
               CASE mchoice == 2
                  Name->Charge := "RATTRAYS"
               CASE mchoice == 3
                  Name->Charge := "OTHERS  "
            ENDCASE
         ENDIF         // Empty Charge
         @ 16, 3 SAY "Charge Through "+Name->Charge+"      "
      ENDIF
*/
        // **      cpayref := Name->PayRef
        csale   := Name->Sale
        // **      @ 18, 3 SAY "Ref :"       GET cpayRef PICTURE "@!"
        @ 18, 3 SAY "Sale :" GET csale PICTURE "@K!"
        @ 21, 20 SAY "Blank Sale for Selection       "
        READ
        ApRLock( 3 )
        // **      Name->PayRef := cpayref
        Name->Sale   := csale
        UNLOCK
        IF Empty( Name->Sale )
            mchoice := 1
            @ 12, 48 PROMPT "BUSINESS  "
            @ 13, 48 PROMPT "SERVICES  "
            @ 14, 48 PROMPT "TEMPORARY "
            @ 15, 48 PROMPT "STAFF     "
            @ 16, 48 PROMPT "OTHERS    "
            MENU TO mchoice
            ApRLock( 3 )
            DO CASE
            CASE mchoice == 1
                Name->Sale := "BUSI"
            CASE mchoice == 2
                Name->Sale := "SERV"
            CASE mchoice == 3
                Name->Sale := "TEMP"
            CASE mchoice == 4
                Name->Sale := "STAF"
            CASE mchoice == 5
                Name->Sale := "OTHE"
            ENDCASE
            UNLOCK
        ENDIF         // Empty Sale
        mcorrect := ApGetY( "Is the above Correct :" )
    ENDDO

    RETURN( mcodeno )

// **---- End of NameGet()

// *-------------------------------------------------------------------

FUNCTION NameLook( mcodeno )

    mcorrect := "N"
    DO WHILE mcorrect == "N"
        Scroll()
        DispBox( 0, 5, 2, 75, 2 )
        mcodeno := Space( 8 )
        DO WHILE mcodeno == Space( 8 )
            @  1, 10 SAY "Name First Characters :";
                GET mcodeno PICTURE "@!"
            @  1, Col() + 3 SAY "? = All,  Esc To Quit"
            READ
            IF LastKey() == 27
                RETURN NIL
            ENDIF
        ENDDO
        SELECT Name
        IF SubStr( mcodeno, 1, 1 ) == "?"
            aPart_ := {}
            Scroll( 3, 0, MaxRow(), MaxCol() )
            IF LastRec() != 0
                GOTO TOP
                DO WHILE Name->( !Eof() )
                    AAdd( aPart_, ( Name->Codeno + "  " + Name->Name ) )
                    SKIP ALIAS Name
                ENDDO
                DispBox(  3, 5, 21, 75, 2 )
                @ 23, 5 SAY "Select with up/down keys or Page up/down"
                @ 23, 50 SAY "ESC to exit    F2 To Add"
                IF !Empty( aPart_ )
                    anum := AChoice( 4, 6, 20, 74, aPart_,, "AFUNC" )
                ENDIF
                IF LastKey() == -1

                    NameAdd()

                ENDIF
                IF LastKey() == 27
                    RETURN NIL
                ENDIF
                SEEK SubStr( aPart_[ anum ], 1, 16 )
                mcodeno := Name->Codeno
            ENDIF
            // ***      RETURN( mcodeno )
        ELSE

            Nameseek( @mcodeno )                        // Below

            IF mcodeno == Space( 8 )
                @ 12, 10 SAY "No Name In File"
                mok := ApGetN( "Do You Want To Add New Name" )
                IF mok == "Y"

                    NameAdd()

                ELSE
                    mcodeno := Space( 8 )
                    LOOP
                ENDIF
            ENDIF                           // Space(8)
        ENDIF                            // LastRec
        mcodeno := Name->Codeno
        SEEK mcodeno
        Scroll()
        DispBox(  0, 5,  2, 75, 2 )
        IF Name->Sale == "BUSI"
            @  1, 8 SAY Name->Codeno
            @  1, 25 SAY Name->Name                      // COLOR c_hicolor
        ELSE
            @  1, 8 SAY Name->Codeno
            @  1, 25 SAY Trim( Name->Title ) + " " + Trim( Name->Called );
                + " " + Name->Famname             // COLOR c_hicolor
        ENDIF
        DispBox(  3, 5, 19, 75, 2 )
        nl := 4
        @ nl, 10 SAY Trim( Name->Add1 )
        @ nl, Col() + 2 SAY Name->Add2
        nl := nl + 1
        @ nl, 10 SAY Name->Add3
        nl := nl + 1
        @ nl, 10 SAY Trim( Name->Add4 ) + " " + Name->Zip
        @ nl, Col() + 2 SAY Name->Add5
        nl := nl + 1
        @ nl, 10 SAY "Bus Ph " + Name->Phone + " Fax " + Name->Bphone;
            + "Priv Ph " + Name->Ephone
        nl := nl + 2
        @ nl, 10 SAY Name->Sale
        @ nl, Col() + 4 SAY Name->Exec
        @ nl, Col() + 2 SAY Name->Branch
        // **   @ nl,COL()+2 SAY "Discount : "+STR( Name->Discount,2 )
        @ nl, Col() + 2 SAY "Margin : "  + Str( Name->Margin, 4 )
        @ nl, Col() + 2 SAY "Ytd Purch "
        @ nl, Col() + 2 SAY Name->YtdPurch
        nl := nl + 1
        @ nl, 10 SAY      Name->Paytype
        @ nl, Col() + 2 SAY Name->Charge
        @ nl, Col() + 2 SAY Name->PayRef
        tempscrn := SaveScreen( 10, 0, 24, 80 )
        coderef := Name->Codeno

        MemoDisp( coderef )       // XF-Memo2

        RestScreen( 10, 0, 24, 80, tempscrn )

        Branchshow( mcodeno )

        SELECT Name
        nselect := 2
        Scroll(  20, 0, 24, 80 )
        DispBox( 20, 5, 24, 75, 2 )
        @ 22, 8      PROMPT "Search"
        @ 22, Col() + 2 PROMPT "Correct"
        @ 22, Col() + 2 PROMPT "Branch"
        @ 22, Col() + 3 PROMPT "Edit Name"
        @ 22, Col() + 2 PROMPT "Memo"
        @ 22, Col() + 2 PROMPT "Add New"
        @ 22, Col() + 2 PROMPT "Account"

        MENU TO nselect

        DO CASE

        CASE LastKey() == 27
            EXIT
            RETURN NIL
        CASE nselect == 7
            Scroll( 12, 3, 17, 77 )
            SELECT Name
            cexec := Name->Exec
            @ 12, 7 SAY "Province :" GET cexec PICTURE "@K!"
            @ 21, 20 SAY "Blank for Selection"
            READ
            ApRLock( 3 )
            Name->Exec := cexec
            UNLOCK
            IF Empty( Name->Exec )
                mchoice := 1
                @ 12, 25 PROMPT "Canterbury "
                @ 13, 25 PROMPT "Central    "
                @ 14, 25 PROMPT "Nelson     "
                @ 15, 25 PROMPT "Otago      "
                @ 16, 25 PROMPT "Southland  "
                @ 17, 25 PROMPT "WestCoast  "
                MENU TO mchoice
                ApRLock( 3 )
                DO CASE
                CASE mchoice == 1
                    Name->Exec := "CANT"
                CASE mchoice == 2
                    Name->Exec := "CENT"
                CASE mchoice == 3
                    Name->Exec := "NELS"
                CASE mchoice == 4
                    Name->Exec := "OTAG"
                CASE mchoice == 5
                    Name->Exec := "SOUT"
                CASE mchoice == 6
                    Name->Exec := "WEST"
                ENDCASE
                UNLOCK
            ENDIF
            @  4, 54 SAY "Province " + Name->Exec
            Scroll( 12, 6, 18, 74 )
            ApRLock( 3 )
            @ 12, 7 SAY "Pay Type :"   GET Name->PayType PICTURE "@K!"
            @ 18, 20 SAY "Blank Pay Type for Selection"
            READ
            UNLOCK
            IF Empty( Name->PayType )
                mchoice := 1
                @ 12, 52 PROMPT "Cash / Cheque "
                @ 13, 52 PROMPT "7 Day Account "
                @ 14, 52 PROMPT "Monthly       "
                // **        @ 15,52 PROMPT "Charge Through"
                @ 16, 52 PROMPT "Direct Credit "
                MENU TO mchoice
                ApRLock( 3 )
                DO CASE
                CASE mchoice == 1
                    Name->PayType := "CA"
                CASE mchoice == 2
                    Name->PayType := "7D"
                CASE mchoice == 3
                    Name->PayType := "MO"
                    // **           CASE mchoice == 4
                    // **              Name->PayType := "CT"
                CASE mchoice == 4
                    Name->PayType := "DC"
                ENDCASE
                UNLOCK
                @ 12, 7 SAY "Pay Type " + Name->PayType + "      "
            ENDIF
            Scroll( 12, 44, 16, 74 )
/*
      IF Name->PayType = "CT"
         @ 14, 7 SAY "Charge Through :" GET Name->Charge PICTURE "@K!"
          READ
         IF EMPTY( Name->Charge )
            mchoice := 1
            @ 12,52 PROMPT "FOODSTUFFS "
            @ 13,52 PROMPT "RATTRAYS   "
            @ 14,52 PROMPT "OTHERS     "
            MENU TO mchoice
            DO CASE
               CASE mchoice == 1
                  Name->Charge := "FOODSTUF"
               CASE mchoice == 2
                  Name->Charge := "RATTRAYS"
               CASE mchoice == 3
                  Name->Charge := "OTHERS  "
            ENDCASE
         ENDIF         // Empty Charge
         @ 14, 7 SAY "Charge Through "+Name->Charge+"      "
      ENDIF                           // CT
      @ 16, 7 SAY "Ref :"       GET Name->PayRef PICTURE "@!"
      @ 16,COL()+3 SAY "Sale :" GET Name->Sale PICTURE "@K!"
      @ 18,20 SAY "Blank Sale for Selection       "
       READ
      IF EMPTY( Name->Sale )
         mchoice := 1
         @ 12,52 PROMPT "BUSINESS   "
         @ 13,52 PROMPT "SERVICES   "
         @ 14,52 PROMPT "OTHERS     "
         MENU TO mchoice
         DO CASE
            CASE mchoice == 1
               Name->Sale := "BUSI"
            CASE mchoice == 2
               Name->Sale := "SERV"
            CASE mchoice == 3
               Name->Sale := "OTHE"
         ENDCASE
      ENDIF         // Empty Sale
*/
        CASE nselect == 1
            LOOP
        CASE nselect == 2
            mcodeno := Name->Codeno
            RETURN( mcodeno )
        CASE nselect == 3
            Branchfnd( @mcodeno )
        CASE nselect == 4
            mcodeno := Name->Codeno
            NameGet( mcodeno )
        CASE nselect == 5
            // **         tempscrn := SAVESCREEN( 11, 0, 24,80 )
            coderef := Name->Codeno

            M2Memofile( coderef )                     // XF_Memo2

            // **         RESTSCREEN( 11, 0,24,80,tempscrn )
            RETURN( mcodeno )
        CASE nselect == 6
            Nameadd( @mcodeno )
            RETURN( mcodeno )
        ENDCASE

    ENDDO                     // End of while EOF()

    RETURN( mcodeno )

// ****** End of NameLook()

// *********----------------   END OF FILE ZFC_NAME.PRG
