// **  JoKir10      13-10-11 07:21:50
// *** REM  Accounts Functions

/*
   Program.....:              XLF_ACC.PRG
   Author......: J.Kirby
   Date........: 10/11/1993
   Functions...: CredProfView, MenuAct, Cashadd, Saleadd
                 Cblook, Sblook
*/

FUNCTION CredProfView()

    manother := "Y"
    DO WHILE manother == "Y"
        ntotal := 0
        Scroll()
        DispBox( 4, 1, 16, 79, 2 )
        mstm  := Date() -30
        mendm := Date()
        @  6, 15 SAY "Include From" GET mstm  PICTURE "99\99\9999"
        @  8, 15 SAY "To Date     " GET mendm PICTURE "99\99\9999"
        READ
        DispBox( 0, 1, 2, 79, 2 )
        mcodeno := Space( 8 )
        nrecno   := 0
        aPart_   := {}
        SELECT CredProf
        GOTO TOP
        IF LastRec() != 0
            DO WHILE CredProf->( !Eof() )
                IF CredProf->Invdate < mstm
                    SKIP ALIAS CredProf
                    LOOP
                ENDIF
                IF CredProf->Invdate > mendm
                    SKIP ALIAS CredProf
                    LOOP
                ENDIF
                SELECT Name
                SEEK CredProf->Codeno
                SELECT CredProf
                ntotal += CredProf->Amount
                AAdd( aPart_, Name->Name;
                    + " " + Str( CredProf->Amount ) + "  " + DToC( CredProf->InvDate );
                    + " " + Invno + "  " + CredProf->Cashno + " " + CredProf->Stat;
                    + "     " + Str( RecNo(), 6 ) )
                SKIP ALIAS CredProf
            ENDDO                          // EOF()
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 1, 24, 79, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                @  1, 15 SAY "Credit Profile List"          COLOR "BG+"
                @  1, 50 SAY ntotal PICTURE "$9,999,999.99" COLOR "G+"
                anum   := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )      // Cant Sort
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
            ENDIF             // Empty
            GOTO nrecno
            SELECT CredProf
            mcodeno := CredProf->Codeno
        ENDIF                        // LastRec()
        // **   ENDCASE
        // **   mok := "Y"
        // **   DO WHILE mok == "Y"
        SELECT Name
        SEEK mcodeno
        SELECT CredProf
        Scroll(  11, 0, 24, 80 )
        DispBox( 11, 1, 19, 79, 2 )
        nl := 12
        @ nl, 10     SAY Name->Name
        nl += 2

        @ nl, 10      SAY "Invoice " + CredProf->Invno
        @ nl, Col() + 2 SAY "Dated " + DToC( CredProf->Invdate )
        @ nl, Col() + 2 SAY "Due Date " + DToC( CredProf->Duedate )
        nl += 2
        @ nl, 10      SAY "Cash Book " + CredProf->Cashno
        nl += 2
        @ nl, 10      SAY "Amount " + Str( CredProf->Amount ) COLOR "G+"
        @ nl, 33      SAY "G.S.T Amount " + Str( CredProf->Tax )
        @ nl, 58      SAY "Status " + CredProf->Stat
        nselect := 1
        DispBox( 20, 1, 24, 79, 2 )
        @ 22, 10      PROMPT "Edit"
        @ 22, Col() + 2 PROMPT "Delete"
        @ 22, Col() + 2 PROMPT "Print All List"
        @ 22, Col() + 2 PROMPT "Exit"

        MENU TO nselect
        DO CASE
        CASE nselect = 4 .OR. PressedEsc()
            EXIT
        CASE nselect = 1
            SELECT Name
            SEEK CredProf->Codeno
            mcorrect := "N"
            DO WHILE mcorrect == "N"
                SELECT CredProf
                Scroll(  11, 0, 24, 80 )
                DispBox( 11, 1, 19, 79, 2 )
                nl := 12
                @ nl, 10 SAY Name->Name
                nl += 2
                ApRLock( 3 )
                @ nl, 10      SAY "Invoice"  GET CredProf->Invno
                @ nl, Col() + 2 SAY "Dated"    GET CredProf->Invdate
                @ nl, Col() + 2 SAY "Due Date" GET CredProf->Duedate
                nl++
                @ nl, 10      SAY "Cash Book :" GET CredProf->Cashno
                READ
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                mcashno := CredProf->Cashno
                UNLOCK
                SELECT CashBook
                SEEK mcashno
                DO WHILE !Found()

                    Cblook( @mcashno )                  // XLF_Acc.PRG

                ENDDO                                         // FOUND()
                nl++
                @ nl, 10 SAY "Cash Book " + CashBook->Cashno
                @ nl, Col() + 2 SAY CashBook->Cbname
                mcashno  := CashBook->Cashno
                mGstAmnt := CashBook->GstAmnt
                IF CashBook->GstAmnt > 0
                    @ nl, Col() + 1 SAY "GST %"
                    @ nl, Col() + 1 SAY CashBook->GSTAmnt
                ENDIF
                nl += 2
                SELECT CredProf
                ApRLock( 3 )
                @ nl, 10 SAY "Amount" GET CredProf->Amount PICTURE "99999.99"
                READ
                IF CashBook->GstAmnt > 0
                    CredProf->Tax := CredProf->Amount - ( CredProf->Amount / ( (mGstAmnt / 100 ) + 1 ) )
                ELSE
                    CredProf->Tax := 0
                ENDIF
                CredProf->Cashno := mcashno
                CredProf->Initamnt := CredProf->Amount
                @ nl, 33 SAY "G.S.T Amount" GET CredProf->Tax  PICTURE "99999.99"
                @ nl, 58 SAY "Status"       GET CredProf->STAT PICTURE "@!"
                READ
                UNLOCK
                nl += 2
                mcorrect := ApGetY( Message->Correct )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
            ENDDO                                     // mcorrect
            LOOP

        CASE nselect == 2
            cstring := Message->Suredel
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mok == "Y"
                ApFLock( 3 )
                DELETE
                UNLOCK
                LOOP
            ENDIF
            LOOP
        CASE nselect = 3
            mwhere := "S"
            Printsel( mwhere )                  // XLF_Init.PRG

            IF mwhere = "P"
                npl := 56
                SET DEVICE TO PRINT
            ELSE
                Scroll()
                npl := 18
            ENDIF
            @  0, 10 SAY Control->U_Name
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            nl := 2
            @ nl, 0 SAY "Name"
            @ nl, 21 SAY "Invoice #"
            @ nl, 31 SAY "Dated"
            @ nl, 42 SAY "Amount"
            @ nl, 54 SAY "Cash #"
            nl += 2
            mtotr := 0
            SELECT CredProf
            GOTO TOP
            DO WHILE CredProf->( !Eof() )
                IF CredProf->Amount == 0
                    SKIP ALIAS CredProf
                    LOOP
                ENDIF
                SELECT Name
                SEEK CredProf->Codeno
                SELECT CredProf
                @ nl, 0 SAY SubStr( Name->Name, 1, 20 )
                @ nl, 21 SAY CredProf->Invno
                @ nl, 31 SAY CredProf->Invdate
                @ nl, 42 SAY CredProf->Amount PICTURE "$999,999.99"
                @ nl, 54 SAY CredProf->Cashno
                mtotr := mtotr + CredProf->Amount
                nl++
                IF nl > npl
                    nl := 1
                    IF mwhere == "P"
                        EJECT
                        @  0, 10 SAY Control->U_Name
                        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                        nl := 2
                        @ nl, 0 SAY "Name"
                        @ nl, 21 SAY "Invoice #"
                        @ nl, 31 SAY "Dated"
                        @ nl, 42 SAY "Amount"
                        @ nl, 54 SAY "Cash #"
                        nl += 2
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                SKIP ALIAS CredProf
            ENDDO                       // CredProf EOF()
            nl++
            @ nl, 17 SAY "Total ="
            @ nl, 27 SAY mtotr PICTURE "$999,999.99"
            nl++
            IF mwhere == "P"
                EndPrint()
            ELSE
                // **         WAIT
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ENDIF
            LOOP
        ENDCASE
        // **  ENDDO                     // mok
        manother := "Y"
    ENDDO

    RETURN NIL

// *****--- End of CredProfView()

// *---------------------------------------------------------------------*

FUNCTION MenuAct( nc, ncl )

    DO WHILE .T.
        SET MESSAGE TO 22 CENTER
        nselect  := 1
        nc       := ncl
        ncm      := nc
        Scroll( 3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        Scroll( 22, 6, 22, 78 )
        nl := 5
        maction := Message->Stock5
        NameAction( @maction, nl )                           // ZSA_Name
        // **    PartAction( @maction, nl )                          // ZSA_Name
        @  3, nc + 4 TO 5, nc + ( ncl - 4 )
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( Menu->CH_AccHd ) ) / 2 );
            SAY RTrim( Menu->CH_AccHd )
        @  7, nc + 2 PROMPT Menu->CH_Acc1 MESSAGE;
            "Accounts Receivable Invoices"
        @  9, nc + 2 PROMPT Menu->CH_Acc2 MESSAGE;
            "Accounts Payable Cheques"
        @ 11, nc + 2 PROMPT Menu->CH_Acc3 MESSAGE;
            "Receipt of Debtors"
        @ 13, nc + 2 PROMPT Menu->CH_Acc4 MESSAGE;
            "Deposits to Bank"
        @ 15, nc + 2 PROMPT Menu->CH_Acc5 MESSAGE;
            "GST Report Cash / Sale Books etc"
        @ 17, nc + 2 PROMPT "6. ACCOUNT RECONCILE" MESSAGE;
            "Statement/GST  Reconcile"
        @ 18, nc + 2 PROMPT "7. INVOICE      MENU" MESSAGE;
            "Invoices Menu"
        @ 19, nc + 2 PROMPT "8. Reindex Files    "

        @ 20, nc + 2 PROMPT Menu->CH_Main
        nc := nc - ncl
        MENU TO nselect
        DO CASE
        CASE nselect == 9 .OR. PressedEsc()
            MENU()
            // **           EXIT
        CASE nselect == 8
            SAVE SCREEN TO holdscrn
            DBFReindx()
            XF_DBFUse()
            UpDateJC()     // XLF_Util   cleans up QuotStk file
            RESTORE SCREEN FROM holdscrn

        CASE nselect == 1
            @  7, ncm + 2 SAY Menu->CH_Acc1 COLOR "BG+"
            Mu_Debt( nc, ncl )                  // XLF_Deb.PRG
        CASE nselect == 2
            @  9, ncm + 2 SAY Menu->CH_Acc2 COLOR "BG+"
            MU_Cred( nc, ncl )                 // XLF_Cred
        CASE nselect == 3
            @ 11, ncm + 2 SAY Menu->CH_Acc3 COLOR "BG+"
            MU_Rec( nc, ncl )                    // XLF_Rec
        CASE nselect == 4
            @ 13, ncm + 2 SAY Menu->CH_Acc4 COLOR "BG+"
            MenuDep( nc, ncl )                   // XLF_Dep
        CASE nselect == 5
            @ 15, ncm + 2 SAY Menu->CH_Acc5 COLOR "BG+"
            MenuJour( nc, ncl )                   // XLF_Jour
        CASE nselect == 6
            @ 17, ncm + 2 SAY "6. ACCOUNT RECONCILE" COLOR "BG+"
            MenuReco( nc, ncl )                   // XF_Recon
        CASE nselect == 7
            @ 19, ncm + 2 SAY "7. INVOICE      MENU" COLOR "BG+"
            MenuInv( nc, ncl )
        ENDCASE
    ENDDO

    RETURN NIL

// **--- End of MenuAct()

// ---------------------------------------------------------------------*

FUNCTION Cashadd( mcashno )

    SELECT CashBook

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        DispBox(  0, 55, 2, 79, 2 )
        @  1, 57 SAY "Edit/Add Cash Book"
        aPart_ := {}
        nrecno := 0
        IF LastRec() != 0
            GO TOP
            DO WHILE CashBook->( !Eof() )
                AAdd( aPart_, CashBook->Cashno + "  " + CashBook->CBName;
                    + "  " + Str( CashBook->GstAmnt );
                    + "  " + CashBook->Stat;
                    + "       " + Str( RecNo(), 6 )    )
                SKIP ALIAS CashBook
            ENDDO
            DispBox(  0, 1, 24, 54, 2 )
            IF !Empty( aPart_ )
                anum := AChoice(  1, 4, 23, 52, aPart_,, "AFUNC" )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
            ENDIF
            ApRLock( 3 )
            mcashno := CashBook->Cashno
            Scroll( 1, 6, 1, 74 )
            @  1, 8 SAY ( mcashno ) + "  " + CashBook->CBName + "  " + ;
                Str( CashBook->GstAmnt ) COLOR c_hicolor
            UNLOCK
        ENDIF
        mcbname  := Space( 30 )
        Scroll(  14, 0, 24, 80 )
        DispBox( 14, 5, 19, 75, 2 )
        mok := mcorrect := "N"
        DO WHILE mcorrect == "N"
            @ 15, 10 SAY "Edit / Add Cash Book Code :" GET mcashno PICTURE "@!"
            @ 15, Col() + 2 SAY "Esc To Quit"
            READ
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mcashno == Space( 4 )
                LOOP
            ENDIF
            SEEK mcashno
            IF Found()
                ccashnoorg := CashBook->Cashno
                mok := ApGetN( "Do You Want To Change Cashno " + CashBook->Cashno )
                IF mok == "Y"
                    Scroll(  10, 0, 24, 80 )
                    DispBox( 10, 5, 14, 75, 2 )
                    @ 11, 8 SAY CashBook->Cashno
                    @ 13, 8 SAY CashBook->CbName
                    DispBox( 14, 5, 19, 75, 2 )
                    @ 16, 15 SAY "Change Cash Book Code :" GET mcashno PICTURE "@!"
                    @ 16, Col() + 2 SAY "Esc To Quit"
                    READ
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    IF mcashno == Space( 4 )
                        LOOP
                    ENDIF
                    SEEK mcashno
                    DO WHILE Found()
                        @ 16, 10 SAY "Already Used      New Code :" GET mcashno PICTURE "@!"
                        @ 16, Col() + 2 SAY "Esc To Quit"
                        READ
                        IF PressedEsc()
                            RETURN NIL
                        ENDIF
                        IF mcashno == Space( 4 )
                            LOOP
                        ENDIF
                        SEEK mcashno
                    ENDDO                               // Found()
                    SELECT Pay
                    ApFLock( 3 )
                    REPLACE ALL Pay->Cashno WITH mcashno    FOR Pay->Cashno == ccashnoorg
                    UNLOCK
                    SELECT Credit
                    ApFLock( 3 )
                    REPLACE ALL Credit->Cashno WITH mcashno FOR Credit->Cashno == ccashnoorg
                    UNLOCK
                    SELECT CashBook
                    ApFLock( 3 )
                    REPLACE Cashno WITH mcashno             FOR CashBook->Cashno == ccashnoorg
                    UNLOCK
                ENDIF                                  // mok
                SELECT CashBook
                SEEK mcashno
            ENDIF                                     // Found()
            SEEK mcashno
            ApFLock( 3 )
            IF !Found()
                APPEND BLANK
            ENDIF
            REPLACE CashBook->Cashno WITH mcashno
            @ 18, 8 SAY "Desc" GET CashBook->Cbname PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            @ 18, Col() + 2 SAY "GST %" GET Cashbook->GstAmnt PICTURE "99.99"
            @ 18, Col() + 2 SAY "Stat"  GET Cashbook->STAT    PICTURE "@!"
            READ
            UNLOCK
            mcorrect := "Y"
            IF LastKey() = 27
                RETURN NIL
            ENDIF
        ENDDO
        mok := ApGetN( "Do You Want To Print List" )
        IF mok == "Y"
            mwhere := "S"
            Printsel( mwhere )                  // XLF_Init.PRG

            IF mwhere = "P"
                npl := 56
                SET DEVICE TO PRINT
            ELSE
                Scroll()
                npl := 18
            ENDIF
            @  0, 10 SAY Control->U_Name
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            nl := 2
            mtotr := 0
            SELECT Cashbook
            GOTO TOP
            DO WHILE CashBook->( !Eof() )
                @ nl, 2 SAY CashBook->Cashno + "   " + CashBook->CBName;
                    + "   " + Str( CashBook->GstAmnt ) + "   " + CashBook->Stat
                nl++
                IF nl > npl
                    nl := 1
                    IF mwhere == "P"
                        EJECT
                        @  0, 10 SAY Control->U_Name
                        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                        nl := 2
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                SKIP ALIAS Cashbook
            ENDDO                       // CashBook EOF()
            nl++
            IF mwhere == "P"
                EndPrint()
            ELSE
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ENDIF
        ENDIF
        mcontinue := ApGetN( "Another Cashbook Code" )
    ENDDO

    RETURN mcashno

// **----  End of CashAdd()

// *-------------------------------------------------------------------

FUNCTION Saleadd()

    SELECT SaleBook

    mok := mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        DispBox(  0, 5, 2, 75, 2 )
        @  1, 10 SAY "Edit or Add New Sale Book #   ( These are for Sales )"
        aPart_ := {}
        nrecno := 0
        Scroll( 3, 0, MaxRow(), MaxCol() )
        IF LastRec() != 0
            GO TOP
            DO WHILE !Eof()
                AAdd( aPart_, Salebook->Saleno + "   " + SaleBook->SBName;
                    + "  " + Str( SaleBook->GstAmnt );
                    + "        " + Str( RecNo(), 6 )  )
                SKIP ALIAS SaleBook
            ENDDO
            DispBox(  3, 5, 24, 57, 2 )
            IF !Empty( aPart_ )
                anum := AChoice( 4, 8, 23, 55, aPart_,, "AFUNC" )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
            ENDIF
            ApRLock( 3 )
            msaleno := Salebook->Saleno
            Scroll( 1, 6, 1, 74 )
            @  1, 8 SAY ( msaleno ) + "   " + SaleBook->SbName;
                + "  " + Str( SaleBook->GstAmnt ) COLOR c_hicolor
            UNLOCK
        ENDIF
        msbname  := Space( 30 )
        Scroll(  14, 0, 24, 80 )
        DispBox( 14, 5, 19, 75, 2 )
        mcorrect := "N"
        DO WHILE mcorrect == "N"
            @  15, 7 SAY "Edit or Add Sale Book :" GET msaleno PICTURE "@!"
            @  15, Col() + 2 SAY "Esc To Quit"
            READ
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF msaleno == Space( 4 )
                LOOP
            ENDIF
            SEEK msaleno
            IF Found()
                csalenoorg := SaleBook->Saleno
                mok := ApGetN( "Do You Want To Change Saleno " + SaleBook->Saleno )
                IF mok == "Y"
                    Scroll(  10, 0, 24, 80 )
                    DispBox( 10, 5, 14, 75, 2 )
                    @ 11, 8 SAY SaleBook->Saleno
                    @ 13, 8 SAY SaleBook->SbName
                    DispBox( 14, 5, 19, 75, 2 )
                    @ 16, 10 SAY "     Change Sale Book Code :" GET msaleno PICTURE "@!"
                    @ 16, Col() + 2 SAY "Esc To Quit"
                    READ
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    IF msaleno == Space( 4 )
                        LOOP
                    ENDIF
                    SEEK msaleno
                    DO WHILE Found()
                        @ 16, 10 SAY "Already Used      New Code :" GET msaleno PICTURE "@!"
                        @ 16, Col() + 2 SAY "Esc To Quit"
                        READ
                        IF PressedEsc()
                            RETURN NIL
                        ENDIF
                        IF msaleno == Space( 4 )
                            LOOP
                        ENDIF
                        SEEK msaleno
                    ENDDO                               // Found()
                    SELECT Deposit
                    ApFLock( 3 )
                    REPLACE ALL Deposit->Saleno WITH msaleno FOR Deposit->Saleno == csalenoorg
                    UNLOCK
                    SELECT Debit
                    ApFLock( 3 )
                    REPLACE ALL Debit->Saleno WITH msaleno FOR Debit->Saleno == csalenoorg
                    UNLOCK
                    SELECT Rec
                    ApFLock( 3 )
                    REPLACE ALL Rec->Saleno WITH msaleno   FOR Rec->Saleno == csalenoorg
                    UNLOCK
                    SELECT SaleBook
                    ApFLock( 3 )
                    REPLACE SaleBook->Saleno WITH msaleno  FOR SaleBook->Saleno == csalenoorg
                    UNLOCK
                ENDIF                                  // mok
            ENDIF
            SELECT SaleBook
            SEEK msaleno
            ApFLock( 3 )
            IF !Found()
                APPEND BLANK
                SaleBook->Saleno := msaleno
            ENDIF
            @ 18, 10 SAY "Description " GET SaleBook->Sbname;
                PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            @ 18, Col() + 2 SAY "GST % "  GET SaleBook->GstAmnt PICTURE "99.99"
            READ
            UNLOCK
            mcorrect := ApGetY( Message->Correct )
            IF LastKey() = 27
                RETURN NIL
            ENDIF
        ENDDO
        mok := ApGetN( "Do You Want To Print List" )
        IF mok == "Y"
            mwhere := "S"
            Printsel( mwhere )                  // XLF_Init.PRG

            IF mwhere = "P"
                npl := 56
                SET DEVICE TO PRINT
            ELSE
                Scroll()
                npl := 18
            ENDIF
            @  0, 10 SAY Control->U_Name
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            nl := 2
            mtotr := 0
            SELECT SaleBook
            GOTO TOP
            DO WHILE SaleBook->( !Eof() )
                @ nl, 2 SAY Salebook->Saleno + "   " + SaleBook->SBName;
                    + "   " + Str( SaleBook->GstAmnt )
                nl++
                IF nl > npl
                    nl := 1
                    IF mwhere == "P"
                        EJECT
                        @  0, 10 SAY Control->U_Name
                        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                        nl := 2
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                SKIP ALIAS SaleBook
            ENDDO                       // SaleBook EOF()
            nl++
            IF mwhere == "P"
                EndPrint()
            ELSE
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ENDIF
        ENDIF

        mcontinue := ApGetN( "Another SaleBook Code" )
    ENDDO

    RETURN msaleno

// ** End of Function Saleadd

// *-------------------------------------------------------------------

FUNCTION Cblook( mcashno )

    SELECT CashBook
    aPart_  := {}
    nrecno  := 0
    mcashno := Space( 4 )
    GOTO TOP
    IF LastRec() != 0
        DO WHILE CashBook->( !Eof() )
            IF SubStr( CashBook->Cashno, 2, 3 ) = "AAA"
                SKIP ALIAS CashBook
                LOOP
            ENDIF
            AAdd( aPart_, Cashno + "   " + Cbname + "  " + Str( GstAmnt );
                + "     " + Str( RecNo(), 6 ) )
            SKIP ALIAS CashBook
        ENDDO
        tempscr := SaveScreen(  0, 0, 24, 80 )
        Scroll(  10, 0, 24, 80 )
        DispBox( 10, 10, 24, 66, 2 )
        @ 23, 30 SAY " F2 To Add Cash Book Code "
        IF !Empty( aPart_ )
            anum := AChoice( 11, 15, 22, 58, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
        ENDIF
        IF LastKey() == -1
            CashAdd()
            Scroll()
        ENDIF
        RestScreen(  0, 0, 24, 80, tempscr )
        ApRLock( 3 )
        mcashno := CashBook->Cashno
        UNLOCK
        SEEK mcashno                 // Required to escape !FOUND

    ENDIF

    RETURN mcashno

// ***------- End of CbLook()

// *-------------------------------------------------------------------

FUNCTION Sblook( msaleno )

    SELECT SaleBook
    aPart_ := {}
    nrecno := 0
    GOTO TOP
    IF LastRec() != 0
        DO WHILE SaleBook->( !Eof() )
            IF SubStr( SaleBook->Saleno, 2, 3 ) = "AAA"
                SKIP ALIAS SaleBook
                LOOP
            ENDIF
            AAdd( aPart_, Saleno + "   " + Sbname + "  " + Str( GstAmnt );
                + "      " + Str( RecNo(), 6 ) )
            SKIP ALIAS SaleBook
        ENDDO
        tempscr := SaveScreen( 0, 0, 24, 80 )
        Scroll(  10, 0, 24, 80 )
        DispBox( 10, 10, 24, 66, 2 )
        @ 23, 30 SAY "F2 To Add Sale Book Code "
        IF !Empty( aPart_ )
            anum := AChoice( 11, 15, 22, 58, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
        ENDIF
        IF LastKey() == -1
            SaleAdd()
            Scroll()
        ENDIF
        ApRLock( 3 )
        msaleno := SaleBook->Saleno
        UNLOCK
        SEEK msaleno                 // Required to escape !FOUND
        RestScreen( 0, 0, 24, 80, tempscr )
    ENDIF

    RETURN msaleno

// *** End of SbLook()

// ******------------------- END OF FILE XLF_ACC.PRG
