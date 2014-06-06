// **  JoKir10   15-10-11 12:22:03

/*
   Program.....:              ZFE_NAME.PRG
   Author......: J.Kirby
   Date........: 01/09/1993
   Functions...: NameEmail, NameGet, MenuName
                 ChriPart, ChriName
   Static funcs: NameRept
*/

FUNCTION NameEmail()

    Scroll()
    DispBox( 3, 5, 24, 75, 2 )
    mexec   := Space( 4 )
    mchoice := 1
    @  5, 15 PROMPT Menu1->Exec01
    @  6, 15 PROMPT Menu1->Exec02
    @  7, 15 PROMPT Menu1->Exec03
    @  8, 15 PROMPT Menu1->Exec04
    @  9, 15 PROMPT Menu1->Exec05
    @ 10, 15 PROMPT Menu1->Exec06
    @ 11, 15 PROMPT Menu1->Exec07
    @ 12, 15 PROMPT Menu1->Exec08
    @ 13, 15 PROMPT Menu1->Exec09
    @ 14, 15 PROMPT Menu1->Exec10
    @ 15, 15 PROMPT Menu1->Exec11
    @ 16, 15 PROMPT Menu1->Exec12
    @ 17, 15 PROMPT Menu1->Exec13
    @ 18, 15 PROMPT Menu1->Exec14
    @ 20, 15 PROMPT "[          ]"
    @ 20, 28 SAY Trim( Message->Mess12 )
    MENU TO mchoice
    SELECT Name
    DO CASE
    CASE mchoice == 1
        mexec := SubStr( Menu1->Exec01, 1, 4 )
    CASE mchoice == 2
        mexec := SubStr( Menu1->Exec02, 1, 4 )
    CASE mchoice == 3
        mexec := SubStr( Menu1->Exec03, 1, 4 )
    CASE mchoice == 4
        mexec := SubStr( Menu1->Exec04, 1, 4 )
    CASE mchoice == 5
        mexec := SubStr( Menu1->Exec05, 1, 4 )
    CASE mchoice == 6
        mexec := SubStr( Menu1->Exec06, 1, 4 )
    CASE mchoice == 7
        mexec := SubStr( Menu1->Exec07, 1, 4 )
    CASE mchoice == 8
        mexec := SubStr( Menu1->Exec08, 1, 4 )
    CASE mchoice == 9
        mexec := SubStr( Menu1->Exec09, 1, 4 )
    CASE mchoice == 10
        mexec := SubStr( Menu1->Exec10, 1, 4 )
    CASE mchoice == 11
        mexec := SubStr( Menu1->Exec11, 1, 4 )
    CASE mchoice == 12
        mexec := SubStr( Menu1->Exec12, 1, 4 )
    CASE mchoice == 13
        mexec := SubStr( Menu1->Exec13, 1, 4 )
    CASE mchoice == 14
        mexec := SubStr( Menu1->Exec14, 1, 4 )
    CASE mchoice == 15
        mexec := Space( 4 )
    ENDCASE
    msale   := Space( 4 )
    mchoice := 1
    @  5, 45 PROMPT Menu1->Mess01
    @  6, 45 PROMPT Menu1->Mess02
    @  7, 45 PROMPT Menu1->Mess03
    @  8, 45 PROMPT Menu1->Mess04
    @  9, 45 PROMPT Menu1->Mess05
    @ 10, 45 PROMPT Menu1->Mess06
    @ 11, 45 PROMPT Menu1->Mess07
    @ 12, 45 PROMPT Menu1->Mess08
    @ 13, 45 PROMPT Menu1->Mess09
    @ 14, 45 PROMPT Menu1->Mess10
    @ 15, 45 PROMPT Menu1->Mess11
    @ 16, 45 PROMPT Menu1->Mess12
    @ 17, 45 PROMPT Menu1->Mess13
    @ 18, 45 PROMPT Menu1->Mess14
    @ 20, 45 PROMPT "[          ]"
    @ 20, 58 SAY Trim( Message->Mess12 )
    MENU TO mchoice
    DO CASE
    CASE mchoice == 1
        msale := SubStr( Menu1->Mess01, 1, 4 )
    CASE mchoice == 2
        msale := SubStr( Menu1->Mess02, 1, 4 )
    CASE mchoice == 3
        msale := SubStr( Menu1->Mess03, 1, 4 )
    CASE mchoice == 4
        msale := SubStr( Menu1->Mess04, 1, 4 )
    CASE mchoice == 5
        msale := SubStr( Menu1->Mess05, 1, 4 )
    CASE mchoice == 6
        msale := SubStr( Menu1->Mess06, 1, 4 )
    CASE mchoice == 7
        msale := SubStr( Menu1->Mess07, 1, 4 )
    CASE mchoice == 8
        msale := SubStr( Menu1->Mess08, 1, 4 )
    CASE mchoice == 9
        msale := SubStr( Menu1->Mess09, 1, 4 )
    CASE mchoice == 10
        msale := SubStr( Menu1->Mess10, 1, 4 )
    CASE mchoice == 11
        msale := SubStr( Menu1->Mess11, 1, 4 )
    CASE mchoice == 12
        msale := SubStr( Menu1->Mess12, 1, 4 )
    CASE mchoice == 13
        msale := SubStr( Menu1->Mess13, 1, 4 )
    CASE mchoice == 14
        msale := SubStr( Menu1->Mess14, 1, 4 )
    CASE mchoice == 15
        msale := Space( 4 )
    ENDCASE
    memail := ApGetY( "Do you want Email Only" )
    nl     := 1
    npl    := 54
    msize  := "N"
    mwhere := "S"

    Printsel()                                     // _LF_INIT

    SELECT Name
    GOTO TOP
    DO WHILE Name->( !Eof() )
        IF msale != Space( 4 )
            IF Name->Sale != msale
                SKIP ALIAS Name
                LOOP
            ENDIF
        ENDIF
        IF mexec != Space( 4 )
            IF Name->Exec != mexec
                SKIP ALIAS Name
                LOOP
            ENDIF
        ENDIF
        IF memail = "Y"
            IF Name->Email != "             "
                @ nl, 0 SAY Name->Email
                nl++
            ENDIF
        ELSE
            @ nl, 0 SAY Name->Name
            nl++
            @ nl, 0 SAY Name->Email
            nl++
        ENDIF
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            nl := 1
        ENDIF
        SKIP ALIAS Name
    ENDDO
    IF mwhere == "P"
        EndPrint()
    ELSE
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN NIL

// ***--------- NameEmail()

// *-------------------------------------------------------------------

STATIC FUNCTION NameRept()

    Scroll()
    mstmm  := Date() -30
    mendmm := Date()
    @  8, 10 SAY Message->Frdate GET mstmm  PICTURE "99/99/9999"
    @ 10, 10 SAY Message->Todate GET mendmm PICTURE "99/99/9999"
    READ
    mwhere := "S"
    npl    := 0
    nl     := 1

    Printsel()                               // _LF_Init

    Scroll()
    SELECT Rept
    SET ORDER TO 2
    GOTO TOP
    DO WHILE Rept->( !Eof() )
        IF Rept->Date < mstmm
            SKIP ALIAS Rept
            LOOP
        ENDIF
        IF Rept->Date > mendmm
            SKIP ALIAS Rept
            LOOP
        ENDIF
        SELECT Name
        SEEK Rept->Codeno
        nl++
        @ nl, 0 SAY Name->Name
        nl++
      /*
      @ nl, 6 SAY Name->Add1
      @ nl,34 SAY Name->Add2
      nl++
      @ nl, 6 SAY Name->Add3
      @ nl,34 SAY Name->Add4
      @ nl,66 SAY Name->Sale
      nl++
      @ nl, 0 SAY "Ph "+Name->Phone
      @ nl,18 SAY "Mob "+Name->MobPhone
      @ nl,40 SAY Name->Email
      */
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            nl := 0
        ENDIF
        DO WHILE Rept->Codeno = Name->Codeno .AND. Rept->( !Eof() )
            @ nl, 1 SAY Rept->DATE PICTURE "99/99/9999"
            @ nl, 12 SAY Rept->Stat + " " + Rept->SuppId + " " + Rept->Info
            nl++
            IF Rept->Info1 != Space( 50 )
                @ nl, 2 SAY Rept->Info1
                nl++
            ENDIF
            IF Rept->Info2 != Space( 50 )
                @ nl, 2 SAY Rept->Info2
                nl++
            ENDIF
            IF Rept->Info3 != Space( 50 )
                @ nl, 2 SAY Rept->Info3
                nl++
            ENDIF
            IF Rept->Info4 != Space( 50 )
                @ nl, 2 SAY Rept->Info4
                nl++
            ENDIF
            IF Rept->Info5 != Space( 50 )
                @ nl, 2 SAY Rept->Info5
                nl++
            ENDIF
            SKIP ALIAS Rept
        ENDDO                                 // EOF Rept
        SELECT Rept
        SKIP ALIAS Rept
    ENDDO
    IF mwhere == "P"
        EndPrint()
    ELSE
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF
    // ** SELECT Name
    // ** SET INDEX TO NameInd
    SELECT Rept
    SET ORDER TO 1

    RETURN NIL

// **------------ End of NameRept()

// **---------------------------------------------------------------------*

FUNCTION NameGet( mcodeno )            // Called by Namerank, Nameadd

    mcorrect := "N"
    DO WHILE mcorrect == "N"
        Scroll()
        DispBox( 0, 5,  2, 75, 2 )
        DispBox( 3, 1, 24, 79, 2 )
        mname       := Name->Name
        mtitle      := Name->Title
        mcalled     := Name->Called
        mfamname    := Name->Famname
        madd1       := Name->Add1
        madd2       := Name->Add2
        madd3       := Name->Add3
        madd4       := Name->Add4
        madd5       := Name->Add5
        mzip        := Name->Zip
        mephone     := Name->Ephone
        mphone      := Name->Phone
        mbphone     := Name->Bphone
        mmobphone   := Name->Mobphone
        mothphone   := Name->Othphone
        ndiscount   := Name->Discount
        nmargin     := Name->Margin
        memail      := Name->Email
        mbank       := Name->Bank
        mbankbranch := Name->BankBranch
        mbankno     := Name->Bankno
        @  1, 7 SAY "Company Name :" GET mname PICTURE "@!"
        @  4, 3 SAY Name->Codeno
        @  4, Col() + 2 SAY "Title"     GET mtitle    PICTURE "!XXX"
        @  4, Col() + 2 SAY "First"     GET mcalled   PICTURE "!XXXXXXXXXXXXXXX"
        @  4, Col() + 2 SAY "Family"    GET mfamname  PICTURE "!XXXXXXXXXXXXXXX"
        @  6, 3 SAY "St   :"         GET madd1     PICTURE "@X"
        @  7, 3 SAY "Box. :"         GET madd2     PICTURE "@KX"
        @  8, 8 SAY ":"              GET madd3     PICTURE "@X"
        @  9, 3 SAY "City :"         GET madd4     PICTURE "@KX"
        @ 10, 3 SAY "Cntry "         GET madd5     PICTURE "@K!"
        @ 10, Col() + 1 SAY "Zip"       GET mzip      PICTURE "@X"
        @  6, 45 SAY "Priv Phone :"   GET mephone   PICTURE "@X"
        @  7, 45 SAY "Bus  Phone :"   GET mphone    PICTURE "@X"
        @  8, 45 SAY "Fax Number :"   GET mbphone   PICTURE "@X"
        @  9, 45 SAY "Mobile     :"   GET mmobPhone PICTURE "@X"
        @ 10, 45 SAY "Other       "   GET mothPhone PICTURE "@X"
        @ 11, 45 SAY "Discount   %"   GET ndiscount PICTURE "999.99"
        @ 12, 45 SAY "Sell+Adds  %"   GET nmargin   PICTURE "999.99"
        @ 13, 3 SAY "Email"          GET memail    PICTURE "@X"
        @ 15, 3 SAY "Bank Name   "   GET mbank     PICTURE "@!"
        @ 15, 32 SAY "Bank Branch"    GET mbankBranch
        @ 16, 3 SAY "Bank Acc #  "   GET mbankno
        // **      @ 14,45 SAY "Work Rate/hr" GET Name->Rate     PICTURE "99999.99"
        mcodeno := Name->Codeno
        mcontact := Name->Contact
        mdesc    := Name->Desc
        mdesc1   := Name->Desc1
        mdesc2   := Name->Desc2
        mdesc3   := Name->Desc3
        nl := 18
        @ nl, 10 SAY "   Contacts" GET mcontact PICTURE "@X"
        nl++
        @ nl, 10 SAY "Description" GET mdesc    PICTURE "@X"
        nl++
        @ nl, 22                   GET mdesc1   PICTURE "@X"
        nl++
        @ nl, 22                   GET mdesc2   PICTURE "@X"
        nl++
        @ nl, 22                   GET mdesc3   PICTURE "@X"
        READ
        SELECT Name
        ApRLock( 3 )
        Name->Name       := mname
        Name->Title      := mtitle
        Name->Called     := mcalled
        Name->Famname    := mfamname
        Name->Add1       := madd1
        Name->Add2       := madd2
        Name->Add3       := madd3
        Name->Add4       := madd4
        Name->Add5       := madd5
        Name->Zip        := mzip
        Name->Ephone     := mephone
        Name->Phone      := mphone
        Name->Bphone     := mbphone
        Name->Mobphone   := mmobphone
        Name->Othphone   := mothphone
        Name->Discount   := ndiscount
        Name->Margin     := nmargin
        Name->Email      := memail
        Name->Bank       := mbank
        Name->BankBranch := mbankbranch
        Name->Bankno     := mbankno
        Name->Contact    := mcontact
        Name->Desc       := mdesc
        Name->Desc1      := mdesc1
        Name->Desc2      := mdesc2
        Name->Desc3      := mdesc3
        UNLOCK
        Scroll(  8, 2, 23, 78 )
        SELECT Name
        cexec := Name->Exec
        @  9, 8 SAY "Location" GET cexec PICTURE "@K!"
        READ
        ApRLock( 3 )
        Name->Exec := cexec
        UNLOCK
        SELECT Name
        IF Empty( Name->Exec )
            mchoice := 1
            @  8, 30 PROMPT Menu1->Exec01
            @  9, 30 PROMPT Menu1->Exec02
            @ 10, 30 PROMPT Menu1->Exec03
            @ 11, 30 PROMPT Menu1->Exec04
            @ 12, 30 PROMPT Menu1->Exec05
            @ 13, 30 PROMPT Menu1->Exec06
            @ 14, 30 PROMPT Menu1->Exec07
            @ 15, 30 PROMPT Menu1->Exec08
            @ 16, 30 PROMPT Menu1->Exec09
            @ 17, 30 PROMPT Menu1->Exec10
            @ 18, 30 PROMPT Menu1->Exec11
            @ 19, 30 PROMPT Menu1->Exec12
            @ 20, 30 PROMPT Menu1->Exec13
            @ 21, 30 PROMPT Menu1->Exec14
            MENU TO mchoice
            SELECT Name
            ApRLock( 3 )
            DO CASE
            CASE mchoice == 1
                Name->Exec := SubStr( Menu1->Exec01, 1, 4 )
            CASE mchoice == 2
                Name->Exec := SubStr( Menu1->Exec02, 1, 4 )
            CASE mchoice == 3
                Name->Exec := SubStr( Menu1->Exec03, 1, 4 )
            CASE mchoice == 4
                Name->Exec := SubStr( Menu1->Exec04, 1, 4 )
            CASE mchoice == 5
                Name->Exec := SubStr( Menu1->Exec05, 1, 4 )
            CASE mchoice == 6
                Name->Exec := SubStr( Menu1->Exec06, 1, 4 )
            CASE mchoice == 7
                Name->Exec := SubStr( Menu1->Exec07, 1, 4 )
            CASE mchoice == 8
                Name->Exec := SubStr( Menu1->Exec08, 1, 4 )
            CASE mchoice == 9
                Name->Exec := SubStr( Menu1->Exec09, 1, 4 )
            CASE mchoice == 10
                Name->Exec := SubStr( Menu1->Exec10, 1, 4 )
            CASE mchoice == 11
                Name->Exec := SubStr( Menu1->Exec11, 1, 4 )
            CASE mchoice == 12
                Name->Exec := SubStr( Menu1->Exec12, 1, 4 )
            CASE mchoice == 13
                Name->Exec := SubStr( Menu1->Exec13, 1, 4 )
            CASE mchoice == 14
                Name->Exec := SubStr( Menu1->Exec14, 1, 4 )
            ENDCASE
            UNLOCK
        ENDIF
        SELECT Name
        cpaytype := Name->PayType
        @ 12, 8 SAY "Location " + Name->Exec
        Scroll(  8, 25, 23, 44 )
        @ 14, 8 SAY "Pay Type " GET cpayType PICTURE "@K!"
        READ
        ApRLock( 3 )
        Name->PayType := cpaytype
        UNLOCK
        IF Empty( Name->PayType )
            mchoice := 4
            @ 12, 25 PROMPT Message->PayType1
            @ 13, 25 PROMPT Message->PayType2
            @ 14, 25 PROMPT Message->PayType3
            @ 15, 25 PROMPT Message->PayType4
            @ 16, 25 PROMPT Message->PayType6
            MENU TO mchoice
            ApRLock( 3 )
            DO CASE
            CASE mchoice == 1
                Name->PayType := SubStr( Message->PayType1, 1, 2 )
            CASE mchoice == 2
                Name->PayType := SubStr( Message->PayType2, 1, 2 )
            CASE mchoice == 3
                Name->PayType := SubStr( Message->PayType3, 1, 2 )
            CASE mchoice == 4
                Name->PayType := SubStr( Message->PayType4, 1, 2 )
            CASE mchoice == 5
                Name->PayType := SubStr( Message->PayType6, 1, 2 )
            ENDCASE
            UNLOCK
            @ 14, 8 SAY "Pay Type    " + Name->PayType
        ENDIF
        Scroll(  8, 25, 24, 74 )
        csale := Name->Sale
        @ 18, 11 SAY "Sale :" GET csale PICTURE "@K!"
        @ 23, 20 SAY Message->Mess10
        READ
        ApRLock( 3 )
        Name->Sale := csale
        UNLOCK
        IF Empty( Name->Sale )
            mchoice := 1
            @  8, 25 PROMPT Menu1->Mess01
            @  9, 25 PROMPT Menu1->Mess02
            @ 10, 25 PROMPT Menu1->Mess03
            @ 11, 25 PROMPT Menu1->Mess04
            @ 12, 25 PROMPT Menu1->Mess05
            @ 13, 25 PROMPT Menu1->Mess06
            @ 14, 25 PROMPT Menu1->Mess07
            @ 15, 25 PROMPT Menu1->Mess08
            @ 16, 25 PROMPT Menu1->Mess09
            @ 17, 25 PROMPT Menu1->Mess10
            @ 18, 25 PROMPT Menu1->Mess11
            @ 19, 25 PROMPT Menu1->Mess12
            @ 20, 25 PROMPT Menu1->Mess13
            @ 16, 25 PROMPT Menu1->Mess14
            MENU TO mchoice
            SELECT Name
            ApRLock( 3 )
            DO CASE
            CASE mchoice == 1
                Name->Sale := SubStr( Menu1->Mess01, 1, 4 )
            CASE mchoice == 2
                Name->Sale := SubStr( Menu1->Mess02, 1, 4 )
            CASE mchoice == 3
                Name->Sale := SubStr( Menu1->Mess03, 1, 4 )
            CASE mchoice == 4
                Name->Sale := SubStr( Menu1->Mess04, 1, 4 )
            CASE mchoice == 5
                Name->Sale := SubStr( Menu1->Mess05, 1, 4 )
            CASE mchoice == 6
                Name->Sale := SubStr( Menu1->Mess06, 1, 4 )
            CASE mchoice == 7
                Name->Sale := SubStr( Menu1->Mess07, 1, 4 )
            CASE mchoice == 8
                Name->Sale := SubStr( Menu1->Mess08, 1, 4 )
            CASE mchoice == 9
                Name->Sale := SubStr( Menu1->Mess09, 1, 4 )
            CASE mchoice == 10
                Name->Sale := SubStr( Menu1->Mess10, 1, 4 )
            CASE mchoice == 11
                Name->Sale := SubStr( Menu1->Mess11, 1, 4 )
            CASE mchoice == 12
                Name->Sale := SubStr( Menu1->Mess12, 1, 4 )
            CASE mchoice == 13
                Name->Sale := SubStr( Menu1->Mess13, 1, 4 )
            CASE mchoice == 14
                Name->Sale := SubStr( Menu1->Mess14, 1, 4 )
            ENDCASE
            UNLOCK
        ENDIF         // Empty Sale
        Scroll( 12, 25, 23, 74 )
        IF Note->Select7 = "Y"
            caccom  := Name->Accom
            cletter := Name->Letter
            mpart   := "Y"
            @ 19, 14      SAY "Sale   " + Name->Sale
            @ 19, Col() + 2 SAY "Letter"   GET caccom  PICTURE "@!"
            @ 19, Col() + 2 SAY "Position" GET cletter PICTURE "@!"
            @ 19, Col() + 2 SAY "To Part"  GET mpart   PICTURE "!"
            READ
            ApRLock( 3 )
            Name->Accom  := caccom
            Name->Letter := cletter
            UNLOCK
            IF mpart = "Y"
                // **      IF Message->NamePart = "Y"
                SELECT PART
                SEEK Name->Codeno
                IF Found()
                    ApRLock( 3 )
                    Part->Desc    := mname
                    Part->PartMat := mphone
                    Part->Detail  := mephone + " " + mmobphone
                    Part->Detail1 := mdesc
                    Part->Detail2 := mdesc1
                    Part->Detail3 := mdesc2
                    Part->Locate  := Upper( SubStr( Name->Add4, 1, 16 ) )
                    Part->LocDesc := Name->Add4
                    UNLOCK
                ELSE
                    ApFLock( 3 )
                    APPEND BLANK
                    Part->Catno     := "NE-NEW"
                    Part->PartId    := "STUDENT"
                    Part->Codeno    := Control->U_Codeno
                    Part->Boughtout := "N"
                    Part->Trade     := 1
                    Part->Wholesale := 1
                    Part->Partnum := mcodeno
                    Part->Desc    := mname
                    Part->PartMat := mphone
                    Part->Detail  := mephone + " " + mmobphone
                    Part->Detail1 := mdesc
                    Part->Detail2 := mdesc1
                    Part->Detail3 := mdesc2
                    Part->Unit    := "Each "
                    Part->Locate  := Upper( SubStr( Name->Add4, 1, 16 ) )
                    Part->LocDesc := Name->Add4
                    UNLOCK
                ENDIF   // Found Part
            ENDIF             // Add Part
        ENDIF               // Note->Select7
      /*
            SAVE SCREEN TO Tempscrn

             BranchShow( @mcodeno )               // Test this

            RESTORE SCREEN FROM Tempscrn
      */
        mcorrect := ApGetY( Message->Correct )
    ENDDO

    RETURN mcodeno

// **---- End of NameGet()

// ***------------------------------------------------------------------------

FUNCTION MenuName( nc, nl )

    DO WHILE .T.

        nselect  := 0
        nc       := ncl
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        SELECT Rept
        SET ORDER TO 2                           // Codeno+Stat
        GOTO TOP
        npll := 41
        nl := nll := nlll := 5
        npl := npll := 20
        ccodeno := Space( 8 )
        @  4, 53 SAY "Reports past 5 days" COLOR "BG+"
        DO WHILE Rept->( !Eof() )
            IF Rept->Date <= Date() -5
                SKIP ALIAS Rept
                LOOP
            ENDIF
            IF Rept->Codeno = ccodeno
                SKIP ALIAS Rept
                LOOP
            ENDIF
            DO CASE
            CASE nl <= npl
                @ nl, 52   SAY Rept->Codeno + " " + Rept->Out
                nl++
            CASE nll <= npll
                @ nll, 66  SAY Rept->Codeno + " " + Rept->Out
                nll++
            OTHERWISE
                WAIT
                Scroll( 4, 52, 21, 79 )
                @  4, 53 SAY "Reports Over Flow" COLOR "BG+"
                @ nlll, 54 SAY Rept->Codeno + " " + Rept->Out
                nlll++
            ENDCASE
            ccodeno := Rept->Codeno
            SKIP ALIAS Rept
        ENDDO                          // EOF()
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( Menu->CH_NameHd ) ) / 2 );
            SAY RTrim( Menu->CH_NameHd )
        @  7, nc + 2 PROMPT "1. Name       Search"
        @  9, nc + 2 PROMPT "2. Name         List"
        @ 11, nc + 2 PROMPT "3. Delete/Change #  "
        @ 13, nc + 2 PROMPT "4. Add New Name     "
        @ 15, nc + 2 PROMPT "5. Name Reports     "
        @ 16, nc + 2 PROMPT "6. Name Profile     "
        @ 17, nc + 2 PROMPT "7. List By Name     "
        @ 19, nc + 2 PROMPT "8. Name Menu System "
        @ 20, nc + 2 PROMPT Menu->CH_Main
        MENU TO nselect
        DO CASE
        CASE nselect == 9 .OR. PressedEsc()
            EXIT
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            Nameview()                                // ZSF_Name
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            ListName()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            Numchange()                              // ZSF_Name
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            NameAdd()                              //
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5
            SAVE SCREEN TO holdscrn
            NameRept()                         // ZSF_Name
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            @ 16, nc + 2 SAY "6. Name Profile     " COLOR "G+"
            Mu_Prof( nc, ncl )                  // ProfStk()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7
            SAVE SCREEN TO holdscrn
            SBSLIST()                           // ZSB_Name
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 8
            SAVE SCREEN TO holdscrn
            NameAnaly()    // XLF_Menu.prg
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// *** End of MenuName()

// *---------------------------------------------------------------------*

FUNCTION ChriPart()

    Scroll()
    cblank := "XXXX"
    @ 12, 10 SAY "Blank for ALL Parts" GET cblank PICTURE "!!!!"
    READ
    IF cblank != "    "
        ccatno := Space( 12 )
        Catarray( ccatno )
        ccatno := Cat->Catno
    ENDIF
    Scroll()
    DispBox( 0, 1, 2, 79, 2 )
    @  1, 10 SAY "Display is 4 Years To Date " + ccatno
    dendmm   := Year( Date() )
    @  6, 10 SAY "Enter 2013 for 2013-2010, 2009 for 2009-2008 Records" COLOR "RG+"
    @  8, 10 SAY Message->Todate GET dendmm PICTURE "9999"
    READ
    IF PressedEsc()
        RETURN NIL
    ENDIF
    dstmm    := dendmm - 3
    mpartnum := Space( 20 )
    aPart_ := {}
    nrecno := 0
    SELECT Hist
    SET ORDER TO 2
    @  4, 1 SAY "Records In File"
    @  5, 1 SAY LastRec()
    @  7, 1 SAY dstmm
    @  8, 6 SAY dendmm
    @ 12, 0 SAY "Please Wait"
    GOTO TOP
    IF LastRec() != 0
        DO WHILE Hist->( !Eof() )
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
            IF cblank != "   "
                SELECT Part
                SEEK Hist->Partnum
                SELECT Hist
                IF Part->Catno != ccatno
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
            ENDIF
            IF Hist->Partnum != mpartnum
                AAdd( aPart_, Hist->Partnum + "        " + Str( RecNo(),6  ) )
                mpartnum := Hist->Partnum
            ENDIF
            SELECT Hist
            SKIP ALIAS Hist
        ENDDO
        ASort( aPart_,,, {| x, y | x < y } )
    ENDIF     // LastRec()
    Scroll()
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll(  0, 0, 24, 36 )
        DispBox( 0, 1, 24, 20, 2 )
        IF !Empty( aPart_ )
            anum  := AChoice( 1, 2, 23, 18, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
        ENDIF
        IF PressedEsc()
            RETURN NIL
        ENDIF
        SELECT Hist
        GOTO nrecno
        mpartnum := Hist->Partnum
        SELECT Part
        SET ORDER TO 1
        SEEK mpartnum
        // **      SEEK Hist->Partnum
        nl := 0
        mcodeno := Space( 8 )
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
        // *** ENDIF     // LastRec()
        SELECT Hist
        SET ORDER TO 2
        GOTO TOP
        IF LastRec() != 0
            SEEK mpartnum
            IF Found()
                DO WHILE Hist->Partnum == mpartnum .AND. Hist->( !Eof() )
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
                            nmonth1 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 2
                            nmonth2 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 3
                            nmonth3 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 4
                            nmonth4 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 5
                            nmonth5 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 6
                            nmonth6 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 7
                            nmonth7 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 8
                            nmonth8 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 9
                            nmonth9 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 10
                            nmonth10 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 11
                            nmonth11 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 12
                            nmonth12 += Hist->Qty
                        ENDCASE
                        ntotal  += Hist->Amount * Hist->Qty
                        ntotqty += Hist->Qty
                    ENDIF                    // YEAR
                    IF Year( Hist->Pdate ) = ( dendmm - 1 )
                        DO CASE
                        CASE Month( Hist->Pdate ) = 1
                            n1month1 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 2
                            n1month2 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 3
                            n1month3 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 4
                            n1month4 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 5
                            n1month5 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 6
                            n1month6 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 7
                            n1month7 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 8
                            n1month8 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 9
                            n1month9 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 10
                            n1month10 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 11
                            n1month11 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 12
                            n1month12 += Hist->Qty
                        ENDCASE
                        n1total  += Hist->Amount * Hist->Qty
                        n1totqty += Hist->Qty
                    ENDIF                    // YEAR
                    IF Year( Hist->Pdate ) = ( dendmm - 2 )
                        DO CASE
                        CASE Month( Hist->Pdate ) = 1
                            n2month1 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 2
                            n2month2 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 3
                            n2month3 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 4
                            n2month4 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 5
                            n2month5 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 6
                            n2month6 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 7
                            n2month7 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 8
                            n2month8 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 9
                            n2month9 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 10
                            n2month10 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 11
                            n2month11 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 12
                            n2month12 += Hist->Qty
                        ENDCASE
                        n2total  += Hist->Amount * Hist->Qty
                        n2totqty += Hist->Qty
                    ENDIF                    // YEAR
                    IF Year( Hist->Pdate ) = ( dendmm - 3 )
                        DO CASE
                        CASE Month( Hist->Pdate ) = 1
                            n3month1 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 2
                            n3month2 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 3
                            n3month3 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 4
                            n3month4 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 5
                            n3month5 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 6
                            n3month6 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 7
                            n3month7 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 8
                            n3month8 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 9
                            n3month9 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 10
                            n3month10 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 11
                            n3month11 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 12
                            n3month12 += Hist->Qty
                        ENDCASE
                        n3total  += Hist->Amount * Hist->Qty
                        n3totqty += Hist->Qty
                    ENDIF                    // YEAR
                    IF Hist->Codeno != mcodeno
                        @ nl, 23 SAY Hist->Codeno
                        nl++
                        mcodeno := Hist->Codeno
                    ENDIF
                    SELECT Hist
                    SKIP ALIAS Hist
                ENDDO                             // EOF
                @  1, 74      SAY dendmm PICTURE "9999"
                SELECT Months
                GOTO 12
                @  2, 40 SAY Months->Brief
                @  2, 74 SAY nmonth1 PICTURE "9,999"
                GOTO 11
                @  3, 40 SAY Months->Brief
                @  3, 74 SAY nmonth2 PICTURE "9,999"
                GOTO 10
                @  4, 40 SAY Months->Brief
                @  4, 74 SAY nmonth3 PICTURE "9,999"
                GOTO  9
                @  5, 40 SAY Months->Brief
                @  5, 74 SAY nmonth4 PICTURE "9,999"
                GOTO  8
                @  6, 40 SAY Months->Brief
                @  6, 74 SAY nmonth5 PICTURE "9,999"
                GOTO  7
                @  7, 40 SAY Months->Brief
                @  7, 74 SAY nmonth6 PICTURE "9,999"
                GOTO  6
                @  8, 40 SAY Months->Brief
                @  8, 74 SAY nmonth7 PICTURE "9,999"
                GOTO  5
                @  9, 40 SAY Months->Brief
                @  9, 74 SAY nmonth8 PICTURE "9,999"
                GOTO  4
                @ 10, 40 SAY Months->Brief
                @ 10, 74 SAY nmonth9 PICTURE "9,999"
                GOTO  3
                @ 11, 40 SAY Months->Brief
                @ 11, 74 SAY nmonth10 PICTURE "9,999"
                GOTO  2
                @ 12, 40 SAY Months->Brief
                @ 12, 74 SAY nmonth11 PICTURE "9,999"
                GOTO  1
                @ 13, 40 SAY Months->Brief
                @ 13, 74 SAY nmonth12 PICTURE "9,999"
                DispBox( 15, 40, 21, 78, 2 )
                @ 16, 43      SAY mpartnum
                @ 17, 43      SAY SubStr( Part->Desc, 1, 32 )
                @ 19, 43      SAY dstmm  PICTURE "9999"
                @ 19, Col() + 2 SAY dendmm PICTURE "9999"
                @ 20, 43      SAY ( n3totqty + n2totqty + n1totqty + ntotqty ) PICTURE "99,999.99"
                @ 20, Col() + 2 SAY ( n3total + n2total + n1total + ntotal )     PICTURE "$99,999.99"
                @ 22, 73 SAY dendmm
                @ 23, 71 SAY ntotqty PICTURE "999,999.99"
                @ 24, 70 SAY ntotal  PICTURE "$99,999.99"

                @  1, 64 SAY dendmm - 1 PICTURE "9999"
                @  2, 64 SAY n1month1 PICTURE "9,999"
                @  3, 64 SAY n1month2 PICTURE "9,999"
                @  4, 64 SAY n1month3 PICTURE "9,999"
                @  5, 64 SAY n1month4 PICTURE "9,999"
                @  6, 64 SAY n1month5 PICTURE "9,999"
                @  7, 64 SAY n1month6 PICTURE "9,999"
                @  8, 64 SAY n1month7 PICTURE "9,999"
                @  9, 64 SAY n1month8 PICTURE "9,999"
                @ 10, 64 SAY n1month9 PICTURE "9,999"
                @ 11, 64 SAY n1month10 PICTURE "9,999"
                @ 12, 64 SAY n1month11 PICTURE "9,999"
                @ 13, 64 SAY n1month12 PICTURE "9,999"
                @ 22, 58 SAY dendmm - 1
                @ 23, 59 SAY n1totqty PICTURE "999,999.99"
                @ 24, 58 SAY n1total  PICTURE "$999,999.99"

                @  1, 56 SAY dendmm - 2 PICTURE "9999"
                @  2, 56 SAY n2month1 PICTURE "9,999"
                @  3, 56 SAY n2month2 PICTURE "9,999"
                @  4, 56 SAY n2month3 PICTURE "9,999"
                @  5, 56 SAY n2month4 PICTURE "9,999"
                @  6, 56 SAY n2month5 PICTURE "9,999"
                @  7, 56 SAY n2month6 PICTURE "9,999"
                @  8, 56 SAY n2month7 PICTURE "9,999"
                @  9, 56 SAY n2month8 PICTURE "9,999"
                @ 10, 56 SAY n2month9 PICTURE "9,999"
                @ 11, 56 SAY n2month10 PICTURE "9,999"
                @ 12, 56 SAY n2month11 PICTURE "9,999"
                @ 13, 56 SAY n2month12 PICTURE "9,999"
                @ 22, 46 SAY dendmm - 2
                @ 23, 47 SAY n2totqty PICTURE "999,999.99"
                @ 24, 46 SAY n2total  PICTURE "$999,999.99"

                @  1, 49 SAY dendmm - 3  PICTURE "9999"
                @  2, 49 SAY n3month1  PICTURE "9,999"
                @  3, 49 SAY n3month2  PICTURE "9,999"
                @  4, 49 SAY n3month3  PICTURE "9,999"
                @  5, 49 SAY n3month4  PICTURE "9,999"
                @  6, 49 SAY n3month5  PICTURE "9,999"
                @  7, 49 SAY n3month6  PICTURE "9,999"
                @  8, 49 SAY n3month7  PICTURE "9,999"
                @  9, 49 SAY n3month8  PICTURE "9,999"
                @ 10, 49 SAY n3month9  PICTURE "9,999"
                @ 11, 49 SAY n3month10 PICTURE "9,999"
                @ 12, 49 SAY n3month11 PICTURE "9,999"
                @ 13, 49 SAY n3month12 PICTURE "9,999"
                @ 22, 38 SAY dendmm - 3  PICTURE "9999"
                @ 23, 34 SAY n3totqty  PICTURE "99,999.99"
                @ 24, 34 SAY n3total   PICTURE "$99,999.99"
            ELSE
                Scroll( 3, 0, 24, 80 )
                @ 10, 10 SAY "No History"
                Inkey( 0 )
            ENDIF
        ENDIF                    // LastRec Not 0
        @ 23, 22 SAY " "
        Inkey( 0 )
        mcontinue := "Y"

        // ** ApGetY( TRIM( Message->Another )+" Part" )
    ENDDO

    RETURN NIL

// ***---- End of ChriPart

// *---------------------------------------------------------------------*

FUNCTION ChriName()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 10 SAY "Select Date then Name"
        dstmm    := Year( Date() ) -3
        dendmm   := Year( Date() )
        @  6, 22 SAY Message->Frdate GET dstmm   PICTURE "9999"
        @  7, 22 SAY Message->Todate GET dendmm  PICTURE "9999"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        DispBox( 8, 10, 14, 34, 2 )
        nsel := 1
        @ 10, 12 PROMPT "From History File"
        @ 12, 12 PROMPT "Select  by   Name"
        MENU TO nsel
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nsel == 1
            Scroll()
            mcodeno  := Space( 8 )
            aPart_ := {}
            nrecno := 0
            SELECT Hist
            SET ORDER TO 1          // Codeno
            GOTO TOP
            IF LastRec() != 0
                DO WHILE Hist->( !Eof() )
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
                    IF Hist->Codeno != mcodeno
                        AAdd( aPart_, Hist->Codeno;
                            + " " + Hist->U_Codeno;
                            + "          " + Str( RecNo(), 6  ) )
                        mcodeno := Hist->Codeno
                    ENDIF
                    SKIP ALIAS Hist
                ENDDO
                IF !Empty( aPart_ )
                    DispBox( 0, 1, 24, 24, 2 )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum     := AChoice( 1, 2, 23, 22, aPart_,, "AFUNC" )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                    mcodeno := Hist->Codeno
                ENDIF
            ENDIF
        CASE nsel == 2
            mcodeno := Space( 8 )
            Namerank( @mcodeno )                // XLF_Name
            IF PressedEsc()
                RETURN NIL
            ENDIF
            SELECT Name
            mcodeno := Name->Codeno
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @ 1, 5 SAY Name->Codeno + " " + Name->Name
        ENDCASE
        manother := "Y"
        DO WHILE manother = "Y"
            mpartnum := Space( 20 )
            aPart_ := {}
            nrecno := 0
            SELECT Hist
            SET ORDER TO 1              // Codeno
            GOTO TOP
            IF LastRec() != 0
                SEEK mcodeno
                IF Found()
                    DO WHILE Hist->Codeno == mcodeno .AND. Hist->( !Eof() )
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
                        IF Hist->Partnum != mpartnum
                            AAdd( aPart_, Hist->Partnum + "        " + Str( RecNo(),6  ) )
                            mpartnum := Hist->Partnum
                        ENDIF
                        SKIP ALIAS Hist
                    ENDDO
                    IF !Empty( aPart_ )
                        Scroll()
                        @  6, 30 SAY "Now Select Part"
                        @  8, 30 SAY dstmm   PICTURE "9999"
                        @  9, 30 SAY dendmm  PICTURE "9999"
                        @ 10, 30 SAY mcodeno
                        DispBox( 0, 1, 24, 20, 2 )
                        ASort( aPart_,,, {| x, y | x < y } )
                        anum     := AChoice( 1, 2, 23, 18, aPart_,, "AFUNC" )
                        IF PressedEsc()
                            RETURN NIL
                        ENDIF
                        nrecno := Val( Right( aPart_[ anum ],6 ) )
                        GOTO nrecno
                        mpartnum := Hist->Partnum
                    ENDIF
                ENDIF                 // Found
            ENDIF
            @ 14, 25      SAY "Part" GET mpartnum PICTURE "@K!"
            @ 14, Col() + 1 SAY "Blank for All Parts"
            READ
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

            SELECT Hist
            SET ORDER TO 1
            GOTO TOP
            IF LastRec() != 0
                SEEK mcodeno
                IF Found()
                    DO WHILE Hist->Codeno = mcodeno .AND. Hist->( !Eof() )
                        IF SubStr( Hist->Partnum, 1, 4 ) = "FREI"
                            SKIP ALIAS Hist
                            LOOP
                        ENDIF
                        IF mpartnum != Space( 20 )
                            IF Hist->Partnum != mpartnum
                                SKIP ALIAS Hist
                                LOOP
                            ENDIF
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
                                nmonth1 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 2
                                nmonth2 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 3
                                nmonth3 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 4
                                nmonth4 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 5
                                nmonth5 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 6
                                nmonth6 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 7
                                nmonth7 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 8
                                nmonth8 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 9
                                nmonth9 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 10
                                nmonth10 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 11
                                nmonth11 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 12
                                nmonth12 += Hist->Qty
                            ENDCASE
                            ntotal  += Hist->Amount * Hist->Qty
                            ntotqty += Hist->Qty
                        ENDIF                    // YEAR
                        IF Year( Hist->Pdate ) = ( dendmm - 1 )
                            DO CASE
                            CASE Month( Hist->Pdate ) = 1
                                n1month1 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 2
                                n1month2 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 3
                                n1month3 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 4
                                n1month4 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 5
                                n1month5 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 6
                                n1month6 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 7
                                n1month7 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 8
                                n1month8 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 9
                                n1month9 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 10
                                n1month10 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 11
                                n1month11 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 12
                                n1month12 += Hist->Qty
                            ENDCASE
                            n1total  += Hist->Amount * Hist->Qty
                            n1totqty += Hist->Qty
                        ENDIF                    // YEAR
                        IF Year( Hist->Pdate ) = ( dendmm - 2 )
                            DO CASE
                            CASE Month( Hist->Pdate ) = 1
                                n2month1 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 2
                                n2month2 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 3
                                n2month3 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 4
                                n2month4 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 5
                                n2month5 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 6
                                n2month6 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 7
                                n2month7 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 8
                                n2month8 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 9
                                n2month9 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 10
                                n2month10 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 11
                                n2month11 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 12
                                n2month12 += Hist->Qty
                            ENDCASE
                            n2total  += Hist->Amount * Hist->Qty
                            n2totqty += Hist->Qty
                        ENDIF                    // YEAR
                        IF Year( Hist->Pdate ) = ( dendmm - 3 )
                            DO CASE
                            CASE Month( Hist->Pdate ) = 1
                                n3month1 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 2
                                n3month2 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 3
                                n3month3 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 4
                                n3month4 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 5
                                n3month5 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 6
                                n3month6 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 7
                                n3month7 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 8
                                n3month8 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 9
                                n3month9 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 10
                                n3month10 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 11
                                n3month11 += Hist->Qty
                            CASE Month( Hist->Pdate ) = 12
                                n3month12 += Hist->Qty
                            ENDCASE
                            n3total  += Hist->Amount * Hist->Qty
                            n3totqty += Hist->Qty
                        ENDIF                    // YEAR
                        SELECT Hist
                        SKIP ALIAS Hist
                    ENDDO                             // EOF
                    Scroll(  0, 0, 24, 80 )
                    DispBox( 1, 1, 12, 38, 2 )
                    @  1, 74      SAY dendmm  PICTURE "9999"
                    @  2, 3      SAY Trim( mpartnum )
                    IF mpartnum != Space( 20 )
                        SELECT Part
                        SEEK mpartnum
                        @  3, 3   SAY SubStr( Part->Desc, 1, 32 )
                    ELSE
                        @  3, 3   SAY "All Parts this Code"
                    ENDIF
                    @  4, 3      SAY dstmm  PICTURE "9999"
                    @  4, Col() + 2 SAY dendmm PICTURE "9999"
                    @  6, 3      SAY mcodeno
                    SELECT Name
                    SEEK mcodeno
                    @  8, 3      SAY Name->Name
                    @ 10, 3      SAY ( n3totqty + n2totqty + n1totqty + ntotqty ) PICTURE "999,999.99"
                    @ 10, Col() + 2 SAY ( n3total + n2total + n1total + ntotal )     PICTURE "$999,999.99"
                    SELECT Months
                    GOTO 12
                    @  2, 40 SAY Months->Brief
                    @  2, 74 SAY nmonth1 PICTURE "9,999"
                    GOTO 11
                    @  3, 40 SAY Months->Brief
                    @  3, 74 SAY nmonth2 PICTURE "9,999"
                    GOTO 10
                    @  4, 40 SAY Months->Brief
                    @  4, 74 SAY nmonth3 PICTURE "9,999"
                    GOTO  9
                    @  5, 40 SAY Months->Brief
                    @  5, 74 SAY nmonth4 PICTURE "9,999"
                    GOTO  8
                    @  6, 40 SAY Months->Brief
                    @  6, 74 SAY nmonth5 PICTURE "9,999"
                    GOTO  7
                    @  7, 40 SAY Months->Brief
                    @  7, 74 SAY nmonth6 PICTURE "9,999"
                    GOTO  6
                    @  8, 40 SAY Months->Brief
                    @  8, 74 SAY nmonth7 PICTURE "9,999"
                    GOTO  5
                    @  9, 40 SAY Months->Brief
                    @  9, 74 SAY nmonth8 PICTURE "9,999"
                    GOTO  4
                    @ 10, 40 SAY Months->Brief
                    @ 10, 74 SAY nmonth9 PICTURE "9,999"
                    GOTO  3
                    @ 11, 40 SAY Months->Brief
                    @ 11, 74 SAY nmonth10 PICTURE "9,999"
                    GOTO  2
                    @ 12, 40 SAY Months->Brief
                    @ 12, 74 SAY nmonth11 PICTURE "9,999"
                    GOTO  1
                    @ 13, 40 SAY Months->Brief
                    @ 13, 74 SAY nmonth12 PICTURE "9,999"
                    @ 22, 73 SAY dendmm
                    @ 23, 71 SAY ntotqty PICTURE "99,999.99"
                    @ 24, 70 SAY ntotal  PICTURE "$99,999.99"

                    @  1, 64 SAY dendmm - 1 PICTURE "9999"
                    @  2, 64 SAY n1month1 PICTURE "9,999"
                    @  3, 64 SAY n1month2 PICTURE "9,999"
                    @  4, 64 SAY n1month3 PICTURE "9,999"
                    @  5, 64 SAY n1month4 PICTURE "9,999"
                    @  6, 64 SAY n1month5 PICTURE "9,999"
                    @  7, 64 SAY n1month6 PICTURE "9,999"
                    @  8, 64 SAY n1month7 PICTURE "9,999"
                    @  9, 64 SAY n1month8 PICTURE "9,999"
                    @ 10, 64 SAY n1month9 PICTURE "9,999"
                    @ 11, 64 SAY n1month10 PICTURE "9,999"
                    @ 12, 64 SAY n1month11 PICTURE "9,999"
                    @ 13, 64 SAY n1month12 PICTURE "9,999"
                    @ 22, 58 SAY dendmm - 1
                    @ 23, 59 SAY n1totqty PICTURE "999,999.99"
                    @ 24, 58 SAY n1total  PICTURE "$999,999.99"

                    @  1, 56 SAY dendmm - 2 PICTURE "9999"
                    @  2, 56 SAY n2month1 PICTURE "9,999"
                    @  3, 56 SAY n2month2 PICTURE "9,999"
                    @  4, 56 SAY n2month3 PICTURE "9,999"
                    @  5, 56 SAY n2month4 PICTURE "9,999"
                    @  6, 56 SAY n2month5 PICTURE "9,999"
                    @  7, 56 SAY n2month6 PICTURE "9,999"
                    @  8, 56 SAY n2month7 PICTURE "9,999"
                    @  9, 56 SAY n2month8 PICTURE "9,999"
                    @ 10, 56 SAY n2month9 PICTURE "9,999"
                    @ 11, 56 SAY n2month10 PICTURE "9,999"
                    @ 12, 56 SAY n2month11 PICTURE "9,999"
                    @ 13, 56 SAY n2month12 PICTURE "9,999"
                    @ 22, 46 SAY dendmm - 2
                    @ 23, 47 SAY n2totqty PICTURE "999,999.99"
                    @ 24, 46 SAY n2total  PICTURE "$999,999.99"

                    @  1, 49 SAY dendmm - 3  PICTURE "9999"
                    @  2, 49 SAY n3month1  PICTURE "9,999"
                    @  3, 49 SAY n3month2  PICTURE "9,999"
                    @  4, 49 SAY n3month3  PICTURE "9,999"
                    @  5, 49 SAY n3month4  PICTURE "9,999"
                    @  6, 49 SAY n3month5  PICTURE "9,999"
                    @  7, 49 SAY n3month6  PICTURE "9,999"
                    @  8, 49 SAY n3month7  PICTURE "9,999"
                    @  9, 49 SAY n3month8  PICTURE "9,999"
                    @ 10, 49 SAY n3month9  PICTURE "9,999"
                    @ 11, 49 SAY n3month10 PICTURE "9,999"
                    @ 12, 49 SAY n3month11 PICTURE "9,999"
                    @ 13, 49 SAY n3month12 PICTURE "9,999"
                    @ 22, 38 SAY dendmm - 3  PICTURE    "9999"
                    @ 23, 18 SAY ( n3totqty + n2totqty + n1totqty + ntotqty ) PICTURE "999,999.99"
                    @ 23, 35 SAY n3totqty  PICTURE "999,999.99"
                    @ 24, 17 SAY ( n3total + n2total + n1total + ntotal ) PICTURE "$999,999.99"
                    @ 24, 34 SAY n3total   PICTURE "$999,999.99"
                ELSE
                    Scroll( 3, 0, 24, 80 )
                    @ 10, 10 SAY "No History"
                    Inkey( 0 )
                ENDIF                 // Found Codeno
            ENDIF                    // LastRec Not 0
            @ 24, 10 SAY " "
            Inkey( 0 )
            manother := ApGetN( Trim( Message->Another ) + " Part" )
        ENDDO
        mcontinue := ApGetN( Trim( Message->Another ) + " Name" )
    ENDDO

    RETURN NIL

// ***---- End of ChrisName

// *********----------------   END OF FILE ZFE_NAME.PRG
