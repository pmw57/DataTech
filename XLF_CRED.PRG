// ** JK 08-09-11 16:11:59

/*
   Program.....:                  XLF_CRED.PRG
   Authors.....: J.Kirby
   Date........: 13/06/1993
   Functions...: CredPay, MU_Cred, CashList, Cashhd, PayAuto
                 Credlist
   Static funcs: CredView, CredPayF, Credlsthd
*/

STATIC FUNCTION CredView()

    manother := "Y"
    DO WHILE manother == "Y"
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        mcodeno := Space( 8 )
        nrecno  := 0
        ntotal  := 0
        aPart_  := {}
        SELECT Credit
        GOTO TOP
        IF LastRec() != 0
            DO WHILE Credit->( !Eof() )
                IF Credit->Codeno = "A       "
                    SKIP ALIAS Credit
                    LOOP
                ENDIF
                SELECT Name
                SEEK Credit->Codeno
                SELECT Credit
                ntotal += Credit->Amount
                AAdd( aPart_, Name->Name;
                    + " " + Str( Credit->Amount ) + "  " + DToC( Credit->InvDate );
                    + " " + Invno + "  " + Credit->Cashno + " " + Credit->Stat;
                    + "     " + Str( RecNo(), 6 ) )
                SKIP ALIAS Credit
            ENDDO                          // EOF()
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 1, 24, 79, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                @  1, 10 SAY "Creditors View"
                @  1, 50 SAY ntotal PICTURE "$9,999,999.99" COLOR "G+"
                anum   := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )      // Cant Sort
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
            ENDIF             // Empty
            GOTO nrecno
            SELECT Credit
            mcodeno := Credit->Codeno
        ENDIF                        // LastRec()
        // **   ENDCASE
        // **   mok := "Y"
        // **   DO WHILE mok == "Y"
        SELECT Name
        SEEK mcodeno
        SELECT Credit
        Scroll(  4, 0, 24, 80 )
        DispBox( 4, 1, 19, 79, 2 )
        nl := 6
        @ nl, 10     SAY Name->Name
        nl += 2
        @ nl, 10      SAY "Invoice " + Credit->Invno
        @ nl, Col() + 2 SAY "Dated " + DToC( Credit->Invdate )
        @ nl, Col() + 2 SAY "Due Date " + DToC( Credit->Duedate )
        nl += 2
        @ nl, 10      SAY "Cash Book " + Credit->Cashno
        nl += 2
        @ nl, 10      SAY "Amount"
        @ nl, Col() + 2 SAY Credit->Amount PICTURE "$999,999.99" COLOR "BG+"
        @ nl, 33      SAY "G.S.T Amount"
        @ nl, Col() + 2 SAY Credit->Tax    PICTURE "$999,999.99" COLOR "BG+"
        @ nl, 58      SAY "Status " + Credit->Stat
        SELECT CredProf
        GOTO TOP
        SEEK Credit->Codeno + Credit->Invno + DToS( Credit->InvDate )
        IF Found()
            nl += 2
            @ nl, 10 SAY Name->Name + " Credit Profile" COLOR "G+"
            nl += 2
            @ nl, 10      SAY "Invoice " + Credit->Invno
            @ nl, Col() + 2 SAY "Cash Book " + Credit->Cashno
            nl++
            @ nl, 10      SAY "Amount"
            @ nl, Col() + 2 SAY CredProf->Amount PICTURE "$999,999.99" COLOR "BG+"
            @ nl, Col() + 4 SAY "G.S.T Amount"
            @ nl, Col() + 2 SAY CredProf->Tax    PICTURE "$999,999.99" COLOR "BG+"
            nl += 2
        ENDIF
        nselect := 1
        DispBox( 20, 1, 24, 79, 2 )
        @ 22, 10      PROMPT "Edit"
        @ 22, Col() + 2 PROMPT "Add New Credit"
        @ 22, Col() + 2 PROMPT "Delete"
        @ 22, Col() + 2 PROMPT "Edit Credit Profile"
        @ 22, Col() + 2 PROMPT "Print All List"

        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            EXIT
        CASE nselect = 1
            SELECT Name
            SEEK Credit->Codeno
            mcorrect := "N"
            DO WHILE mcorrect == "N"
                mcredOrig := Credit->Invno
                SELECT Credit
                Scroll()
                DispBox( 0, 1, 14, 79, 2 )
                nl := 2
                @ nl, 10 SAY Name->Name
                nl += 2
                ApRLock( 3 )
                @ nl, 10      SAY "Invoice"  GET Credit->Invno
                @ nl, Col() + 2 SAY "Dated"    GET Credit->Invdate
                @ nl, Col() + 2 SAY "Due Date" GET Credit->Duedate
                nl += 2
                @ nl, 10      SAY "Cash Book :" GET Credit->Cashno
                READ
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                mcashno := Credit->Cashno
                UNLOCK
                SELECT CashBook
                SEEK mcashno
                DO WHILE !Found()

                    Cblook( @mcashno )                  // XLF_Acc.PRG

                ENDDO                                         // FOUND()
                @ nl, 10 SAY "Cash Book :   " + CashBook->Cashno
                @ nl, Col() + 2 SAY CashBook->Cbname
                mcashno  := CashBook->Cashno
                mGstAmnt := CashBook->GstAmnt
                IF CashBook->GstAmnt > 0
                    @ nl, Col() + 1 SAY "GST %"
                    @ nl, Col() + 1 SAY CashBook->GSTAmnt
                ENDIF
                nl += 2
                mamount := Credit->Amount
                SELECT Credit
                ApRLock( 3 )
                @ nl, 10 SAY "Amount" GET Credit->Amount PICTURE "99999.99"
                READ
                IF CashBook->GstAmnt > 0
                    Credit->Tax := Credit->Amount - ( Credit->Amount / ( (mGstAmnt / 100 ) + 1 ) )
                ELSE
                    @ nl + 2, 50 SAY Credit->Amount - ( Credit->Amount / ( (mGstAmnt / 100 ) + 1 ) ) PICTURE "9,999.99"
                    Credit->Tax := 0
                ENDIF
                Credit->Cashno := mcashno
                @ nl, 33 SAY "G.S.T Amount" GET Credit->Tax  PICTURE "99999.99"
                @ nl, 58 SAY "Status"       GET Credit->STAT PICTURE "@!"
                READ
                UNLOCK
                nl += 2
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                SELECT CredProf
                GOTO TOP
                SEEK Credit->Codeno + mcredOrig + DToS( Credit->InvDate )
                IF Found()
                    Scroll(  11, 0, 24, 80 )
                    DispBox( 11, 1, 19, 79, 2 )
                    nl := 12
                    @ nl, 10 SAY Name->Name + " Credit Profile" COLOR "G+"
                    nl += 2
                    @ nl, 10      SAY "Invoice " + Credit->Invno
                    @ nl, Col() + 2 SAY "Cash Book " + Credit->Cashno
                    nl += 2
                    @ nl, 10      SAY "New Credit Amount"
                    @ nl, Col() + 1 SAY Credit->Amount PICTURE "$999,999.99" COLOR "G+"
                    @ nl, Col() + 3 SAY "Original"
                    @ nl, Col() + 1 SAY CredProf->Amount PICTURE "$999,999.99" COLOR "G+"
                    nl += 2
                    // **            IF mcorrect = "Y"
                    ApFLock( 3 )
                    CredProf->Codeno   := Credit->Codeno
                    CredProf->Invdate  := Credit->InvDate
                    CredProf->DueDate  := Credit->DueDate
                    CredProf->Stat     := Credit->Stat
                    CredProf->Initamnt := Credit->Amount
                    CredProf->Cashno   := Credit->Cashno
                    CredProf->Amount   := Credit->Amount
                    CredProf->Tax      := Credit->Tax
                    CredProf->Invno    := Credit->Invno
                    UNLOCK
                    // **            ENDIF                  // mcorrect
                ELSE
                    SELECT CredProf
                    ApFLock( 3 )
                    APPEND BLANK
                    CredProf->Codeno   := Credit->Codeno
                    CredProf->Invdate  := Credit->InvDate
                    CredProf->DueDate  := Credit->DueDate
                    CredProf->Stat     := Credit->Stat
                    CredProf->Initamnt := Credit->Initamnt
                    CredProf->Cashno   := Credit->Cashno
                    CredProf->Amount   := Credit->Amount
                    CredProf->Tax      := Credit->Tax
                    CredProf->Invno    := Credit->Invno
                    UNLOCK
                ENDIF
                mcorrect := ApGetY( Message->Correct )
                SELECT Credit
            ENDDO                                     // mcorrect
            LOOP

        CASE nselect == 2
            Scroll()
            CredAdd()                              // Above
            IF LastKey() = 27
                RETURN NIL
            ENDIF
            mok := "Y"
            LOOP

        CASE nselect == 3
            Scroll(  11, 0, 24, 80 )
            DispBox( 11, 1, 18, 79, 2 )
            cstring := Message->Suredel
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mok == "Y"
                SELECT Credit
                ApFLock( 3 )
                DELETE
                UNLOCK
                @ 12, 10 SAY "Credit delete" COLOR "R+"
                SELECT CredProf
                GOTO TOP
                SEEK Credit->Codeno + Credit->Invno + DToS( Credit->InvDate )
                IF Found()
                    @ 14, 10 SAY "Credit Prof entry delete" COLOR "R+"
                    ApFLock( 3 )
                    DELETE
                    UNLOCK
                ENDIF
                Inkey( 2 )
                LOOP
            ENDIF
            LOOP

        CASE nselect = 4
            CredProfView()                              // XLF_Acc
            LOOP

        CASE nselect = 5
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
            SELECT Credit
            GOTO TOP
            DO WHILE Credit->( !Eof() )
                IF Credit->Amount == 0
                    SKIP ALIAS Credit
                    LOOP
                ENDIF
                SELECT Name
                SEEK Credit->Codeno
                SELECT Credit
                @ nl, 0 SAY SubStr( Name->Name, 1, 20 )
                @ nl, 21 SAY Credit->Invno
                @ nl, 31 SAY Credit->Invdate
                @ nl, 42 SAY Credit->Amount PICTURE "$999,999.99"
                @ nl, 54 SAY Credit->Cashno
                mtotr := mtotr + Credit->Amount
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
                SKIP ALIAS Credit
            ENDDO                       // Credit EOF()
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

// *****--- End of CredView()

// *---------------------------------------------------------------------*

FUNCTION CredPay( mcodeno )

    mcheqdate := Date()
    manother := "Y"
    DO WHILE manother == "Y"
        Scroll()
        mcodeno := Space( 8 )

        Namerank( @mcodeno )                          // XLF_Name

        IF PressedEsc()
            RETURN NIL
        ENDIF
        SELECT Name
        mcodeno := Name->Codeno
        mcashno := Name->Cashno
        namnt   := 0
        SELECT Credit
        SEEK mcodeno
        IF Found()
            Scroll(  3, 0, 24, 80 )
            nl := 3
            @ nl, 10 SAY "Creditor in the Credit File" COLOR "RG+"
            nl++
            DO WHILE Credit->Codeno = mcodeno .AND. Credit->( !Eof() )
                // **         IF Credit->Stat = "A"           // AutoPayments
                // **            SKIP ALIAS Credit
                // **            LOOP
                // **         ENDIF
                namnt += Credit->Amount
                @ nl, 10 SAY DToC( Credit->InvDate ) + " " + Credit->Invno;
                    + " " + Str( Credit->Amount, 12, 2  );
                    + " " + Credit->Cashno + "  " + Str( namnt, 12, 2 )
                nl++
                SKIP ALIAS Credit
            ENDDO                          // EOF()
            mcredit := ApGetY( "Do You Want to Go to Credit File" )
            IF mcredit == "Y"
                CredPayF()                        // Below
            ENDIF
            IF PressedEsc()
                RETURN NIL
            ENDIF
        ENDIF
        nl := 18
        Scroll(  17, 0, 24, 80 )
        DispBox( 17, 1, 24, 79, 2 )
        cheading := " -- Latest Payments -- "
        @ 17, 38 -( Len( cheading ) / 2 ) SAY cheading + mcodeno + " "
        SELECT Pay
        GOTO TOP
        npl := 23
        DO WHILE Pay->( !Eof() )
            IF Pay->Codeno != mcodeno
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF Pay->Cheqdate < Date() -65
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF nl > npl
                Scroll(  18, 6, 23, 74 )
                nl := 18
            ENDIF
            @ nl, 6      SAY Pay->Invno
            @ nl, Col() + 2 SAY Pay->Cheqdate
            @ nl, Col() + 2 SAY Pay->Cheqno
            @ nl, Col() + 2 SAY Pay->Recon
            @ nl, Col() + 2 SAY Pay->Cashno
            @ nl, Col() + 2 SAY Pay->Amount  PICTURE "9999,999.99"
            @ nl, Col() + 2 SAY Pay->GstAmnt PICTURE "999,999.99"
            nl++
            mcashno := Pay->Cashno
            SKIP ALIAS Pay
        ENDDO                        // Pay EOF()
        mcorrect := "N"
        DO WHILE mcorrect == "N"
            Scroll(  3, 0, 19, 80 )
            DispBox( 3, 1, 19, 79, 2 )
            mcashno   := Name->Cashno
            mcheqno   := Control->LastCheq
            minvno    := Space( 10 )
            mamount   := 0
            npaytot   := 0
            crecon    := "P"
            @  5, 12      SAY "Invoice #"     GET minvno    PICTURE "@X"
            @  5, Col() + 6 SAY "Presented P/N" GET crecon;
                VALID( crecon $ "PN" )  PICTURE "@!"
            @  6, 12      SAY "Check Date" COLOR "BG+"
            @  7, 10      SAY "Cheque Date"   GET mcheqdate PICTURE "99/99/9999"
            @  7, Col() + 6 SAY "Cheque Number"
            mcheq := SubStr( Control->LastCheq, 1, 1 )
            IF Asc( mcheq ) > 60
                mcheqno := Control->LastCheq
            ELSE
                mcheq   := Val( Control->Lastcheq ) + 1
                mcheqno := LTrim( Str( mcheq,7 ) )
                mcheqno := mcheqno + Space( 9 )
            ENDIF
            @  7, Col() + 2 GET mcheqno PICTURE "XXXXXXX"    // Dont Change This 7
            @  9, 10      SAY "Cash Book #" GET mcashno PICTURE "@K!"
            READ
            IF PressedEsc()
                RETURN NIL
            ENDIF
            SELECT Control
            ApRLock( 3 )
            Control->Lastcheq := mcheqno
            UNLOCK
            SELECT Cashbook
            SEEK mcashno
            DO WHILE !Found()

                Cblook( @mcashno )                        // XLF_Cred.PRG

            ENDDO
            @  9, 10 SAY "CashBook # " + CashBook->Cashno + " " + Cashbook->Cbname
            IF CashBook->GstAmnt > 0
                @  9, Col() + 2 SAY "GST %"
                @  9, Col() + 2 SAY CashBook->GSTAmnt
            ENDIF
            mcashno := CashBook->Cashno
            IF npaytot > 0
                @ 11, 15      SAY "Amount :  " + Str( mamount )
                @ 11, Col() + 6 SAY "Chq Bal " + Str( npaytot )
            ENDIF
            IF npaytot < mamount
                mamount := npaytot
            ENDIF
            IF mamount < 0
                @ 11, 55 SAY "This is a Credit"
            ENDIF
            @ 13, 15 SAY "Amount :" GET mamount PICTURE "999999.99"
            READ
            IF CashBook->GstAmnt > 0
                mgstamnt := mamount - ( mamount / ( ( CashBook->GstAmnt / 100 ) + 1 ) )
            ELSE
                mgstamnt := 0
                Scroll( 15, 12, 15, 60 )
                @ 15, 15      SAY mamount - ( mamount / ( ( Control->GstRate / 100 ) + 1 ) )
                @ 15, Col() + 2 SAY "No GST this Entry"
            ENDIF
            @ 13, 43 SAY "GST Amount :"  GET mgstamnt PICTURE "999999.99"
            READ
            Scroll( 17, 0, 24, 80 )
            mcorrect := ApGetY( Message->Correct )
            IF LastKey() = 27
                RETURN NIL
            ENDIF
        ENDDO      // mcorrect
        SELECT Pay
        ApFLock( 3 )
        APPEND BLANK
        Pay->Codeno   := mcodeno
        Pay->Cheqdate := mcheqdate
        Pay->Presdate := mcheqdate
        Pay->Cheqno   := mcheqno
        Pay->Amount   := mamount
        Pay->Cashno   := mcashno
        Pay->Gstamnt  := mgstamnt
        Pay->Invno    := minvno
        Pay->Recon    := crecon
        UNLOCK
        SELECT Name
        ApFLock( 3 )
        Name->Cashno := Pay->Cashno
        UNLOCK
        COMMIT
        manother := ApGetY( "Another Payment" )

    ENDDO                   // another

    RETURN NIL

// ***---- End of CredPay()

// *-------------------------------------------------------------------

STATIC FUNCTION CredPayF()

    mcheqdate := Date()
    manother := "Y"
    DO WHILE manother == "Y"

        Scroll()
        DispBox( 0, 45, 2, 79, 2 )
        @  1, 47 SAY "Creditors Listing"
        mcodeno := Space( 8 )
        nrecno  := 0
        aPart_  := {}
        SELECT Credit
        GOTO TOP
        IF LastRec() = 0
            @ 12, 10 SAY "No Credits in File"
            WAIT
            RETURN NIL
        ENDIF
        IF LastRec() != 0
            DO WHILE Credit->( !Eof() )
                IF Credit->Codeno = mcodeno
                    SKIP ALIAS Credit
                    LOOP
                ENDIF
                IF Credit->Stat = "A"           // AutoPayments
                    SKIP ALIAS Credit
                    LOOP
                ENDIF
                SELECT Name
                SEEK Credit->Codeno
                SELECT Credit
                mcodeno := Credit->Codeno
                AAdd( aPart_, Name->Name;
                    + "     " + Str( RecNo(), 6 ) )
                SKIP ALIAS Credit
            ENDDO                          // EOF()
            Scroll(  0, 0, 24, 40 )
            DispBox( 0, 1, 24, 40, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice( 1, 3, 23, 34, aPart_,, "AFUNC" )      // Cant Sort
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
            ENDIF
            GOTO nrecno
            mcodeno := Credit->Codeno
            mcashno := Name->Cashno
            SELECT Name
            SEEK mcodeno
        ENDIF                        // LastRec
        ncheqtot := npaybal := npaytot := 0
        ccheqno := Space( 7 )
        mok := "Y"
        DO WHILE mok = "Y"
            Scroll()
            DispBox( 0, 1, 2, 79,2 )
            @ 1, 6 SAY Trim( Name->Name )
            mamount := namnttot := nrecno := 0
            SELECT Credit
            GOTO TOP
            SEEK mcodeno
            aPart_ := {}
            IF LastRec() != 0
                DO WHILE Credit->Codeno = mcodeno .AND. Credit->( !Eof() )
                    IF Credit->Stat = "A"           // AutoPayments
                        SKIP ALIAS Credit
                        LOOP
                    ENDIF
                    namnttot += Credit->Amount
                    AAdd( aPart_, DToC( Credit->InvDate ) + " " + Credit->Invno;
                        + " " + Str( Credit->Amount, 12, 2  ) + " $" + Str( namnttot, 12, 2 );
                        + " " + Credit->Cashno + " " + DToC( Credit->DueDate ) )
                    SKIP ALIAS Credit
                ENDDO                          // EOF()
                IF !Empty( aPart_ )
                    Scroll(  3, 0, 24, 80 )
                    DispBox( 3, 1, 18, 79, 2 )
                    @  3, 0 SAY " "
                    AEval( aPart_, {|A| QOUT( " " + Chr( 186 ) + "  " );
                        , QQOut( A ), BreakTot() } )
                ENDIF
                IF namnttot > 0 .AND. npaytot <= 0
                    Scroll(  17, 0, 24, 80 )
                    DispBox( 17, 0, 24, 79, 2 )
                    IF npaytot <= 0
                        ccheq := SubStr( Control->LastCheq, 1, 1 )
                        IF Asc( ccheq ) > 60
                            ccheqno := Control->LastCheq
                        ELSE
                            ccheq   := Val( Control->Lastcheq ) + 1
                            ccheqno := LTrim( Str( ccheq,7 ) )
                            ccheqno := ccheqno + Space( 9 )
                        ENDIF
                    ENDIF
                    @ 19, 10      SAY "Total Owing"
                    @ 19, Col() + 2 SAY namnttot PICTURE "$9999,999.99" COLOR "G+"
                    npaytot := namnttot
                    @ 21, 10      SAY "Cheque Amount" GET npaytot PICTURE "9999999.99"
                    @ 21, Col() + 2 SAY "Number"        GET ccheqno PICTURE "XXXXXXX"
                    READ
                    IF npaytot > namnttot
                        @ 22, 10      SAY "Cheque Amount" GET npaytot PICTURE "9999999.99"
                        @ 22, Col() + 2 SAY "Number"        GET ccheqno PICTURE "XXXXXXX"
                        @ 23, 10 SAY "That is more than the Total Credit" COLOR "RG+"
                        READ
                    ENDIF
                    ncheqtot := npaytot
                    SELECT Control
                    ApRLock( 3 )
                    Control->Lastcheq := ccheqno
                    UNLOCK
                ENDIF                              // namnttot
            ENDIF
            SELECT Credit
            SEEK mcodeno
            DO WHILE Found()
                namnttot := 0
                aPart_ := {}
                SELECT Credit
                IF LastRec() != 0
                    DO WHILE Credit->Codeno = mcodeno .AND. Credit->( !Eof() )
                        IF Credit->Stat = "A"           // AutoPayments
                            SKIP ALIAS Credit
                            LOOP
                        ENDIF
                        namnttot += Credit->Amount
                        AAdd( aPart_, Codeno + " " + DToC( InvDate ) + " " + Invno;
                            + " $" + Str( Credit->Amount ) + " " + Str( namnttot );
                            + " " + Cashno + " " + Credit->Stat;
                            + " " + DToC( Credit->DueDate ) + "   " + Str( RecNo(), 6 ) )
                        SKIP ALIAS Credit
                    ENDDO                          // EOF()
                ENDIF                              // LastRec
            ENDDO
            IF namnttot > 0
                Scroll()
                DispBox( 0, 1,  2, 79, 2 )
                @  1, 7 SAY Trim( mcodeno ) + " Cheque" + Str( ncheqtot, 9, 2 );
                    + " Paid" + Str( npaybal, 12, 2 );
                    + " Balance" + Str( npaytot, 12, 2 ) COLOR "G+"
                DispBox( 3, 1, 18, 79, 2 )
                @ 20, 10 SAY Trim( mcodeno ) + " Cheque Total" + Str( ncheqtot, 12, 2 );
                    + " Paid" + Str( npaybal, 12, 2 );
                    + " Balance" + Str( npaytot, 12, 2 ) COLOR "G+"
                IF !Empty( aPart_ )
                    anum   := AChoice( 4, 5, 17, 76, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                ENDIF
                GOTO nrecno
                Scroll(  16, 0, 24, 80 )
                DispBox( 16, 1, 21, 79, 2 )
                @ 17, 10      SAY Credit->Codeno
                @ 18, 10      SAY "Balance Cheque Amount "
                @ 18, Col() + 1 SAY npaytot        PICTURE "$9999,999.99"
                @ 20, 10      SAY DToC( Credit->InvDate ) + "  " + Invno
                @ 20, Col() + 2 SAY "Amount"
                @ 20, Col() + 1 SAY Credit->Amount PICTURE "$9999,999.99" COLOR "G+"
                @ 20, Col() + 4 SAY Credit->Stat
                nselect := 1
                DispBox( 22, 1, 24, 79, 2 )
                @ 23, 10      PROMPT "Pay This Credit"
                @ 23, Col() + 4 PROMPT "Delete"
                @ 23, Col() + 3 PROMPT "Exit"
                MENU TO nselect
            ELSE
                EXIT
            ENDIF
            DO CASE
            CASE nselect == 3 .OR. PressedEsc()
                RETURN NIL
            CASE nselect == 1
                IF npaytot <= 0
                    EXIT
                ENDIF
            CASE nselect == 2
                cstring := Trim( Message->Suredel )
                mok := ApCheck( cstring )                        // AppX.PRG
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                IF mok == "Y"
                    SELECT Credit
                    ApRLock( 3 )
                    DELETE
                    UNLOCK
                ENDIF                               // mok = "Y"
                LOOP
                mok := "Y"
            ENDCASE
            mcashno   := Credit->Cashno
            mamount   := Credit->Amount
            mgstamnt  := Credit->Tax
            minvno    := Credit->Invno
            Scroll(  17, 0, 24, 80 )
            DispBox( 17, 1, 24, 79, 2 )
            cheading := " - Latest Payments - "
            @ 17, 38 -( Len( cheading ) / 2 ) SAY cheading + mcodeno + "  "
            SELECT Pay
            GOTO TOP
            nl  := 18
            npl := 23
            DO WHILE Pay->( !Eof() )
                IF Pay->Codeno != mcodeno
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF Pay->Cheqdate < Date() -365
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF nl > npl
                    Scroll(  18, 6, 23, 74 )
                    nl := 18
                ENDIF
                @ nl, 10 SAY Pay->Cheqdate
                @ nl, 22 SAY Pay->Cheqno + " " + Pay->Cashno + " " + Pay->Recon
                @ nl, 45 SAY Pay->Amount  PICTURE "$9999,999.99"
                @ nl, 57 SAY Pay->GstAmnt PICTURE "$999,999.99"
                nl++
                SKIP ALIAS Pay
            ENDDO                        // Pay EOF()
            crecon   := "P"
            mcorrect := "N"
            DO WHILE mcorrect == "N"
                Scroll(  3, 0, 16, 80 )
                DispBox( 3, 1, 16, 79, 2 )
                @  5, 12      SAY "Invoice # " + minvno    PICTURE "@X"
                @  5, Col() + 2 SAY "Dated " + DToC( Credit->InvDate )
                @  5, Col() + 2 SAY "Presented P/N" GET crecon;
                    VALID( crecon $ "PN" ) PICTURE "@!"
                @  7, 10      SAY "Cheque Date"   GET mcheqdate PICTURE "99/99/9999"
                @  7, Col() + 6 SAY "Cheque Number"
                @  7, Col() + 1 GET ccheqno PICTURE "XXXXXXX"    // Dont Change This 7
                @  9, 10      SAY "Cash Book #"   GET mcashno PICTURE "@K!"
                READ
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                SELECT Cashbook
                SEEK mcashno
                DO WHILE !Found()

                    Cblook( @mcashno )                        // XLF_Cred.PRG

                ENDDO
                @  9, 10 SAY "CashBook # " + CashBook->Cashno + " " + Cashbook->Cbname
                IF CashBook->GstAmnt > 0
                    @  9, Col() + 2 SAY "GST %"
                    @  9, Col() + 2 SAY CashBook->GSTAmnt
                ENDIF
                mcashno := CashBook->Cashno
                IF npaytot > 0
                    @ 11, 15      SAY "Amount :  " + Str( mamount )
                    @ 11, Col() + 4 SAY "Cheque Bal" + Str( npaytot )
                ENDIF
                IF npaytot < mamount
                    mamount := npaytot
                ENDIF
                IF npaytot = 0
                    mamount := Credit->Amount
                ENDIF
                @ 13, 15 SAY "Amount :" GET mamount PICTURE "9999999.99"
                IF mamount < 0
                    @ 13, 37 SAY "This is a Credit"
                ENDIF
                READ
                IF mamount > Credit->Amount
                    @ 16, 10 SAY "That is greater than the Credit" COLOR "RG+"
                ENDIF       // mamount
                IF CashBook->GstAmnt > 0
                    mgstamnt := mamount - ( mamount / ( ( CashBook->GstAmnt / 100 ) + 1 ) )
                ELSE
                    mgstamnt := 0
                    Scroll( 15, 12, 15, 60 )
                    @ 15, 15 SAY mamount - ( mamount / ( ( Control->GstRate / 100 ) + 1 ) )
                    @ 15, Col() + 2 SAY "No GST this Entry"
                ENDIF
                @ 13, 37 SAY "GST Amount "  GET mgstamnt PICTURE "999999.99"
                READ
                Scroll( 17, 0, 24, 80 )
                mok := ApGetY( Message->Correct )
                IF LastKey() = 27
                    RETURN NIL
                ENDIF
                IF mok = "Y"
                    npaytot -= mamount
                    npaybal += mamount
                    SELECT Pay
                    // ** IF mamount > 0                // Won't allow 0 value
                    ApFLock( 3 )
                    APPEND BLANK
                    Pay->Codeno   := mcodeno
                    Pay->Cheqdate := mcheqdate
                    Pay->Presdate := mcheqdate
                    Pay->Cheqno   := ccheqno           // Only for Credit exists
                    Pay->Amount   := mamount
                    Pay->Cashno   := mcashno
                    Pay->Gstamnt  := mgstamnt
                    Pay->Invno    := minvno
                    Pay->Recon    := crecon
                    Pay->Stat     := "C"
                    UNLOCK
                    SELECT Credit
                    IF Credit->Stat != "A"
                        ApRLock( 3 )
                        Credit->Cashno := Pay->Cashno
                        Credit->Amount -= Pay->Amount
                        IF Credit->Amount <= 0
                            DELETE
                        ENDIF
                        UNLOCK
                    ENDIF                          // If Stat = A
                    // ***  ENDIF                          // mamount
                ENDIF
                mcorrect := mok
            ENDDO                    // mcorrect
            // **      mok := "N"
            IF npaytot > 0
                mok := ApGetY( "Another this client" )
            ENDIF

        ENDDO                             // mok
        manother := ApGetY( "Another Payment" )

    ENDDO                   // another

    RETURN NIL

// ***---- End of CredPayF()

// *-------------------------------------------------------------------

FUNCTION MU_Cred()

    DO WHILE .T.
        SET MESSAGE TO 22 CENTER
        nselect  := 1
        nc       := ncl * 2
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( Menu->CH_CredHd ) ) / 2 );
            SAY RTrim( Menu->CH_CredHd )
        @  7, nc + 2 PROMPT "1. Cheque Pay   Name" MESSAGE;
            "Payment of Creditors Invoices"
        @  8, nc + 2 PROMPT "2. Cheque Pay Credit" MESSAGE;
            "Cheque Pay from Creditors List"
        @ 10, nc + 2 PROMPT "3. Automatic     Pay" MESSAGE;
            "Automatic Payment"
        @ 11, nc + 2 PROMPT "4. Not Presented    " MESSAGE;
            "Cheques Not Presented Edit"
        @ 12, nc + 2 PROMPT "5. Cheque       Edit" MESSAGE "Edit the Cheque Details"
        @ 13, nc + 2 PROMPT "6.   ..         List" MESSAGE "Payment Listings"
        @ 14, nc + 2 PROMPT "7. Pay  mm/YYYY List" MESSAGE;
            "Monthly Cheque Listing by Cash Codes"
        @ 16, nc + 2 PROMPT "8. Add        Credit" MESSAGE;
            "Add Invoice details"
        @ 17, nc + 2 PROMPT "9. Edit       Credit" MESSAGE;
            "Edit Invoice details"
        @ 18, nc + 2 PROMPT "0. Listing    Credit" MESSAGE;
            "Monthly Invoice details to be paid"
        @ 20, nc + 2 PROMPT Menu->CH_Main

        MENU TO nselect
        Scroll( 22, 5, 22, 74 )
        nc := ncl
        DO CASE
        CASE nselect = 11 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            CredPay()                          // By Name
            COMMIT
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            CredPayF()                         // By Credit List  // Above
            COMMIT
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            PayAuto()                          // Below
            COMMIT
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            ViewPres()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5
            SAVE SCREEN TO holdscrn
            ViewPay()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            ListPay()
            COMMIT
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7
            SAVE SCREEN TO holdscrn
            Cashlist()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 8
            SAVE SCREEN TO holdscrn
            CredAdd()
            COMMIT
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 9
            SAVE SCREEN TO holdscrn
            CredView()                        // Below
            COMMIT
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 10
            SAVE SCREEN TO holdscrn
            Credlist()
            COMMIT
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// ***------ End of Mu_Cred

// *-------------------------------------------------------------------

FUNCTION CashList()

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 10 SAY "Listing of Cashbook " + Control->U_Name
        nselect  := 1
        DispBox( 3, 1, 12, 79, 2 )
        @  4, 10 PROMPT "By Month mm/YYYY"
        @  6, 10 PROMPT "Selected Period "
        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nselect == 2
            dstmm  := Date() -30
            dendmm := Date()
            @  8, 5 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
            @ 10, 5 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
            READ
            mgst := ApGetN( "Do you want Excluding GST" )
            mDirect := ApGetn( "Direct Costs ONLY" )
            mwhere := "S"
            npl    := 54
            nl     := 1

            Printsel()                          // _LF_Init.PRG

            IF mwhere == "P"
                npl := 54
            ELSE
                nlp := 22
            ENDIF
            @  0, 0 SAY Control->U_Name
            @  2, 0 SAY "EXPENDITURE LIST"
            @  2, 20 SAY dstmm
            @  2, 32 SAY dendmm
            @  2, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  4, 0 SAY "Cash #"
            IF mgst = "Y"
                @ 4, 10 SAY "Excluding GST"
            ELSE
                @ 4, 10 SAY "Including GST"
            ENDIF
            nl := 6
            mmgstamnt := mmgstpur := mmamntyr := mmamount := mmmonth := 0
            mgsttot := mtotamnt := mtotamount := mvalyy := mvalmm := 0
            ntotpriory := nmpriory := npriory := 0
            nsum := namount := nsubyy := nsubpriory := 0
            nline := 0
            SELECT Pay
            GOTO TOP
            ApFLock( 3 )
            INDEX ON Cashno TO TempI02
            SET INDEX TO TempI02
            UNLOCK
            SELECT Cashbook
            GOTO TOP
            DO WHILE Cashbook->( !Eof() )
                IF mDirect = "Y"
                    IF CashBook->Stat != "D"
                        SKIP ALIAS CashBook
                        LOOP
                    ENDIF
                ENDIF
                IF SubStr( CashBook->Cashno, 3, 2  ) == "AA"
                    IF nline != 0
                        @ nl, 35 SAY "------------"
                        nl++
                        @ nl, 27 SAY "Total"
                        @ nl, 35 SAY namount    PICTURE "9,999,999.99"
                        nl++
                    ENDIF
                    @ nl, 4 SAY CashBook->Cbname
                    nl++
                    SKIP ALIAS CashBook
                    nsum := namount := nsubyy := nsubpriory := 0
                    LOOP
                ENDIF                             // AA Heading
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                    @  0, 0 SAY Control->U_Name
                    @  2, 0 SAY "EXPENDITURE LIST"
                    @  2, 20 SAY dstmm
                    @  2, 32 SAY dendmm
                    @  2, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  4, 0 SAY "Cash #"
                    IF mgst = "Y"
                        @ 4, 10 SAY "Excluding GST"
                    ELSE
                        @ 4, 10 SAY "Including GST"
                    ENDIF
                    nl := 6
                ENDIF                             // nl > npl
                @ nl, 0 SAY Cashbook->Cashno
                @ nl, 6 SAY Cashbook->Cbname
                mcashno := Cashbook->Cashno
                SELECT Pay
                GOTO TOP
                SEEK mcashno
                mmnth := "  "
                DO WHILE Pay->Cashno == mcashno .AND. Pay->( !Eof() )
                    mgstamnt := mamntyr := mmonth := mgstpur := 0
                    npriory := 0
                    IF Pay->CheqDate  > dendmm
                        SKIP ALIAS Pay
                        LOOP
                    ENDIF
                    IF Pay->CheqDate < dstmm
                        SKIP ALIAS Pay
                        LOOP
                    ENDIF
                    IF mgst = "Y"
                        camount := Pay->Amount - Pay->Gstamnt
                    ELSE
                        camount := Pay->Amount
                    ENDIF
                    mgstamnt := Pay->Gstamnt
                    mmonth   := camount
                    namount  += camount
                    IF Gstamnt > 0
                        mgstpur := camount
                    ENDIF
                    nsum       := nsubyy + namount                // Required
                    nline      := 1
                    nsubyy     += mamntyr
                    nsubpriory += npriory
                    nmpriory   += npriory
                    mmmonth    += mmonth
                    mmgstamnt  += mgstamnt
                    mmgstpur   += mgstpur
                    SKIP ALIAS Pay
                ENDDO                        // End of Pay
                @ nl, 36 SAY mmmonth   PICTURE "9,999,999.99"
                nl++
                mgsttot    += mmgstamnt            // GST Total
                mtotamnt   += mmmonth
                mtotamount += mmamntyr
                ntotpriory += nmpriory
                mmgstamnt := mmmonth := mmamntlyr := mmamntyr := mgstpur := 0
                nmpriory := 0
                SELECT Cashbook
                SKIP ALIAS Cashbook
            ENDDO                               // CashBook
            nl++
            IF nsum != 0
                @ nl, 36 SAY "------------"
                nl++
                @ nl, 28 SAY "Total"
                @ nl, 36 SAY namount    PICTURE "9,999,999.99"
                nl += 2
            ENDIF
            @ nl, 35 SAY "============"
            nl++
            @ nl, 0 SAY "GRAND TOTALS"
            @ nl, 36 SAY mtotamnt   PICTURE "9,999,999.99"
            nl += 2
            @ nl, 0 SAY "G.S.T PURCHASES - MONTH"
            @ nl, 26 SAY mmgstpur PICTURE "$9,999,999.99"
            nl++
            @ nl, 0 SAY " "
            IF mwhere == "P"
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
            mcontinue := "N"
        CASE nselect == 1
            @  8, 15 SAY "Please Provide Month/Year To List"
            msys := SubStr( DToC( Date() ), 4, 7 )
            @ 10, 15 SAY "Month & Year MM/YYYY" GET msys PICTURE "99/9999"
            READ
            mgst := ApGetN( "Do you want Excluding GST" )
            mDirect := ApGetn( "Direct Costs ONLY" )
            mwhere := "S"
            npl    := 54
            nl     := 1

            Printsel()                          // _LF_Init.PRG

            IF mwhere == "P"
                npl := 54
            ELSE
                nlp := 22
            ENDIF

            Cashhd()                           // Below

            mmgstamnt := mmgstpur := mmamntyr := mmamount := mmmonth := 0
            mgsttot := mtotamnt := mtotamount := mvalyy := mvalmm := 0
            ntotpriory := nmpriory := npriory := 0
            mmm     := SubStr( msys, 1, 2 )
            myy     := SubStr( msys, 4, 4 )
            mvalmm  := Val( mmm )
            mvalyy  := Val( myy )
            msameyr := "F"
            IF mvalmm < 4                    // From Jan To Mar
                msameyr := "S"
            ENDIF
            nsum := namount := nsubyy := nsubpriory := nline := 0
            SELECT Pay
            GOTO TOP
            ApFLock( 3 )
            INDEX ON Cashno TO TempI02
            SET INDEX TO TempI02
            UNLOCK
            SELECT Cashbook
            GOTO TOP
            DO WHILE Cashbook->( !Eof() )
                IF mDirect = "Y"
                    IF CashBook->Stat != "D"
                        SKIP ALIAS CashBook
                        LOOP
                    ENDIF
                ENDIF
                IF SubStr( CashBook->Cashno, 3, 2  ) == "AA"
                    IF nline != 0
                        @ nl, 36 SAY "------------"
                        @ nl, 50 SAY "------------"
                        @ nl, 62 SAY "------------"
                        nl++
                        @ nl, 27 SAY "Total"
                        @ nl, 36 SAY namount    PICTURE "9999,999.99"
                        @ nl, 50 SAY nsubyy     PICTURE "9999,999.99"
                        @ nl, 62 SAY nsubpriory PICTURE "9,999,999.99"
                        nl++
                    ENDIF
                    @ nl, 4 SAY CashBook->Cbname
                    nl++
                    SKIP ALIAS CashBook
                    nsum := namount := nsubyy := nsubpriory := 0
                    LOOP
                ENDIF                             // AA Heading
                IF nl > npl
                    nl := 4
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF

                    Cashhd()                     // Below

                ENDIF                             // nl > npl
                @ nl, 0 SAY Cashbook->Cashno
                @ nl, 6 SAY Cashbook->Cbname
                mcashno := Cashbook->Cashno
                SELECT Pay
                GOTO TOP
                SEEK mcashno
                mmnth := "  "
                DO WHILE Pay->Cashno == mcashno .AND. Pay->( !Eof() )
                    IF mgst = "Y"
                        camount := Pay->Amount - Pay->Gstamnt
                    ELSE
                        camount := Pay->Amount
                    ENDIF
                    mgstamnt := mamntyr := mmonth := mgstpur := 0
                    npriory := 0
                    DO CASE
                        // /

                    CASE Year( Pay->CheqDate ) == mvalyy              // Same Year
                        DO CASE
                        CASE Month( Pay->CheqDate ) > mvalmm
                            SKIP ALIAS Pay
                            LOOP
                        CASE Month( Pay->CheqDate ) == mvalmm     // Same Year & Month
                            mgstamnt := Pay->Gstamnt
                            mmonth   := mamntyr := camount
                            namount  += camount
                            IF Gstamnt > 0
                                mgstpur := camount
                            ENDIF
                        CASE Month( Pay->CheqDate ) < 4
                            IF msameyr = "S"
                                IF Month( Pay->CheqDate ) < mvalmm
                                    mamntyr := camount
                                ENDIF
                            ENDIF
                        CASE Month( Pay->CheqDate ) > 3
                            IF Month( Pay->CheqDate ) < mvalmm
                                mamntyr := camount
                            ENDIF
                        ENDCASE
                        // //
                    CASE Year( Pay->CheqDate ) = ( mvalyy - 1 )      // Last Year
                        DO CASE
                        CASE Month( Pay->CheqDate ) > 3
                            IF msameyr = "S"
                                mamntyr := camount
                            ENDIF
                            // // Prior
                        CASE Month( Pay->CheqDate ) < 4
                            // **                       IF msameyr = "S"
                            npriory := camount
                            // **                       ENDIF
                        ENDCASE

                    CASE Year( Pay->CheqDate ) == ( mvalyy - 2 )          // Prior Year
                        DO CASE
                        CASE Month( Pay->CheqDate ) > 3
                            npriory := camount
                        ENDCASE
                    ENDCASE
                    nsum       := nsubyy + namount                // Required
                    nline      := 1
                    nsubyy     += mamntyr
                    nsubpriory += npriory
                    nmpriory   += npriory
                    mmamntyr   += mamntyr
                    mmmonth    += mmonth
                    mmgstamnt  += mgstamnt
                    mmgstpur   += mgstpur
                    SKIP ALIAS Pay
                ENDDO                        // End of Pay
                @ nl, 36 SAY mmmonth   PICTURE "9999,999.99"
                @ nl, 50 SAY mmamntyr  PICTURE "9999,999.99"
                @ nl, 62 SAY nmpriory  PICTURE "9,999,999.99"
                nl++
                mgsttot    += mmgstamnt            // GST Total
                mtotamnt   += mmmonth
                mtotamount += mmamntyr
                ntotpriory += nmpriory
                mmgstamnt := mmmonth := mmamntlyr := mmamntyr := mgstpur := 0
                nmpriory := 0
                SELECT Cashbook
                SKIP ALIAS Cashbook
            ENDDO                               // CashBook
            nl++
            IF nsum != 0
                @ nl, 36 SAY "------------"
                @ nl, 50 SAY "------------"
                @ nl, 62 SAY "------------"
                nl++
                @ nl, 28 SAY "Total :"
                @ nl, 36 SAY namount    PICTURE "9999,999.99"
                @ nl, 50 SAY nsubyy     PICTURE "9999,999.99"
                @ nl, 62 SAY nsubpriory PICTURE "9,999,999.99"
                nl += 2
            ENDIF
            @ nl, 36 SAY "============"
            @ nl, 50 SAY "============"
            @ nl, 63 SAY "==========="
            nl++
            @ nl, 0 SAY "GRAND TOTALS"
            @ nl, 35 SAY mtotamnt   PICTURE "9999,999.99"
            @ nl, 49 SAY mtotamount PICTURE "9,999,999.99"
            @ nl, 62 SAY ntotpriory PICTURE "9,999,999.99"
            nl += 2
            @ nl, 0 SAY "G.S.T PURCHASES - MONTH"
            @ nl, 26 SAY mmgstpur PICTURE "$9,999,999.99"
            nl++
            @ nl, 0 SAY " "
            IF mwhere == "P"
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
            mcontinue := "N"
        ENDCASE
    ENDDO
    COMMIT
    SELECT Pay
    SET INDEX TO PayInd

    RETURN NIL

// **------- End of Cashlist

// *-------------------------------------------------------------------

FUNCTION Cashhd()

    @  0, 0 SAY Control->U_Name
    @  2, 0 SAY "EXPENDITURE LIST TO MONTH"
    @  2, 29 SAY msys
    @  2, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  4, 0 SAY "Cash #"
    IF mgst = "Y"
        @ 4, 10 SAY "Excluding GST"
    ELSE
        @ 4, 10 SAY "Including GST"
    ENDIF
    @  4, 42 SAY "Month"
    @  4, 51 SAY "Yr To " + msys
    @  4, 66 SAY "Last Yr"
    nl := 6

    RETURN NIL
// **--------- End Cashhd()

// *-------------------------------------------------------------------

FUNCTION PayAuto()

    SELECT CREDIT
    ApFLock( 3 )
    REPLACE ALL Credit->InitAmnt WITH 0 FOR Credit->Stat = "A"
    UNLOCK
    mcheqdate := Date()
    mcashno   := Space( 4 )
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 15 SAY "Automatic Payments"
        ntotal := 0
        nrecno := 0
        aPart_ := {}
        SELECT Credit
        GOTO TOP
        IF LastRec() = 0
            Scroll()
            @ 12, 10 SAY "No Auto Payments in System Please Add"
            WAIT
            CredAdd()
            IF PressedEsc()
                RETURN NIL
            ENDIF
        ENDIF
        IF LastRec() != 0
            DO WHILE Credit->( !Eof() )
                IF Credit->Stat != "A"
                    SKIP ALIAS Credit
                    LOOP
                ENDIF
                cpaid := Space( 1 )
                IF Credit->InitAmnt = 1
                    cpaid := "#"
                ENDIF
                SELECT Name
                SEEK Credit->Codeno
                SELECT Credit
                ntotal += Credit->Amount
                AAdd( aPart_, Name->Name;
                    + "  " + DToC( InvDate ) + "  " + Invno;
                    + "  " + Str( Amount ) + " " + Credit->Stat;
                    + " " + cpaid + "    " + Str( RecNo(), 6 ) )
                SKIP ALIAS Credit
            ENDDO                          // EOF()
            DispBox( 3, 1, 19, 79, 2 )
            @ 21, 30 SAY Message->Esc
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                @ 1, 55 SAY ntotal PICTURE "$9,999,999.99" COLOR "G+"
                anum   := AChoice( 4, 3, 18, 77, aPart_,, "AFUNC" )
                IF LastKey() = 27
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
            ELSE
                Scroll()
                @ 12, 10 SAY "No Auto Payments in System Please Add"
                WAIT
                CredAdd()
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                IF mcontinue = "N"    // Required for no Entry required
                    RETURN NIL
                ENDIF
                LOOP
            ENDIF
            GOTO nrecno
            IF LastKey() == -1
                CredAdd()
                LOOP
            ENDIF
            IF PressedEsc()
                RETURN NIL
            ENDIF
        ENDIF
        Scroll(   3, 0, 24, 80 )
        DispBox(  3, 1, 14, 79, 2 )
        @  4, 7 SAY Credit->Codeno
        SELECT Name
        SEEK Credit->Codeno
        ApRLock( 3 )
        @ 4, 17 SAY Trim( Name->Name ) + " " + Trim( Name->Add1 )
        UNLOCK
        SELECT Credit
        @  6, 8      SAY "Cheque Date " + DToC( Credit->Invdate )
        @  6, 34 SAY "Cheque # "         + Credit->Cheqno
        @  8, 10      SAY "Invoice "     + Credit->Invno
        @  8, Col() + 2 SAY "Cash Book "   + Credit->Cashno
        @ 10, 14      SAY "Amount "      + Str( Credit->Amount )
        @ 10, Col() + 2 SAY "Status "      + Credit->Stat
        nl := 16
        Scroll(  15, 0, 24, 80 )
        DispBox( 15, 1, 24, 79, 2 )
        cheading := " --- Latest Payments --- "
        @ 15, 38 -( Len( cheading ) / 2 ) SAY cheading + Credit->Codeno
        SELECT Pay
        GOTO TOP
        npl := 23
        DO WHILE Pay->( !Eof() )
            IF Pay->Codeno != Credit->Codeno
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF nl > npl
                Scroll( 16, 6, 23, 74 )
                nl := 16
            ENDIF
            @ nl, 10 SAY Pay->Cheqdate
            @ nl, 22 SAY Pay->Cheqno + " " + Pay->Cashno + " " + Pay->Recon
            @ nl, 45 SAY Pay->Amount  PICTURE "$999,999.99"
            @ nl, 57 SAY Pay->GstAmnt PICTURE "$99,999.99"
            nl++
            SKIP ALIAS Pay
        ENDDO                        // Pay EOF()
        mtrue    := "Y"
        mcorrect := "N"
        DO WHILE mcorrect = "N"
            SELECT Credit
            ApRLock( 3 )
            @  6, 8 SAY "Cheque Date" GET mcheqdate PICTURE "99/99/9999"
            IF Credit->Cheqno = Space( 7 )
                Credit->Cheqno := "AP " + SubStr( Credit->Codeno, 1, 4 )
            ENDIF
            @  6, 34 SAY "Cheque #"    GET Credit->Cheqno PICTURE "@X"
            READ
            IF PressedEsc()
                RETURN NIL
            ENDIF
            Credit->InvDate  := mcheqdate
            Credit->InitAmnt := 1
            mcashno  := Credit->Cashno
            mamount  := Credit->Amount
            mgstamnt := Credit->Tax
            UNLOCK
            IF mtrue = "N"
                Scroll(   7, 6, 13, 74 )
                ApRLock( 3 )
                @  6, 34      SAY "Cheque #"     GET Credit->Cheqno PICTURE "@X"
                @  8, 10      SAY "Invoice"      GET Credit->Invno  PICTURE "@K!"
                @  8, Col() + 2 SAY "Auto Pay A/N" GET Credit->Stat;
                    VALID( Credit->Stat $ "AN" ) PICTURE "@!"
                @  8, Col() + 2 SAY "Cash Book"    GET mcashno        PICTURE "@!"
                READ
                UNLOCK
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                SELECT Cashbook
                SEEK mcashno
                DO WHILE !Found()

                    Cblook( @mcashno )                        // XLF_Cred.PRG

                ENDDO
                @ 10, 10 SAY "CashBook # " + CashBook->Cashno + " " + Cashbook->Cbname
                IF CashBook->GSTAmnt > 0
                    @ 10, Col() + 2 SAY "GST %"
                    @ 10, Col() + 2 SAY CashBook->GSTAmnt
                ENDIF
                SELECT CashBook
                ApRLock( 3 )
                mcashno := CashBook->Cashno
                UNLOCK
                SELECT Credit
                ApRLock( 3 )
                mamount := Credit->Amount
                UNLOCK
                @ 12, 15 SAY "Amount :" GET mamount PICTURE "9999999.99"
                READ
                IF CashBook->GstAmnt > 0
                    mgstamnt := mamount - ( mamount / ( (CashBook->GstAmnt / 100 ) + 1 ) )
                ELSE
                    mgstamnt := 0
                    @ 14, 12 SAY mamount - ( mamount / ( (Control->GstRate / 100 ) + 1 ) )
                    @ 14, Col() + 2 SAY "No GST this Entry"
                ENDIF
                @ 12, 43 SAY "GST Amount "  GET mgstamnt PICTURE "999999.99"
                READ
            ENDIF                            // mtrue = Y
            mcorrect := ApGetY( Message->Correct )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            ApRLock( 3 )
            Credit->Amount := mamount
            Credit->Tax    := mgstamnt
            Credit->Cashno := mcashno
            UNLOCK
            IF mcorrect = "N"
                mtrue := "N"
            ENDIF
        ENDDO
        SELECT Pay
        ApFLock( 3 )
        APPEND BLANK
        Pay->Codeno   := Credit->Codeno
        Pay->Cheqdate := Credit->InvDate
        Pay->Presdate := Credit->InvDate
        Pay->Cheqno   := Credit->Cheqno
        Pay->Invno    := Credit->Invno
        Pay->Amount   := mamount
        Pay->Cashno   := mcashno
        Pay->Gstamnt  := mgstamnt
        Pay->Recon    := "P"
        UNLOCK
        mcontinue := ApGetY( Message->Another )
    ENDDO                           // mcontinue

    RETURN NIL

// ***---- End of PayAuto()

// *-------------------------------------------------------------------

FUNCTION Credlist()

    npl    := 52
    mwhere := "S"

    Printsel( mwhere, npl )

    IF mwhere == "P"
        npl := 52
    ELSE
        npl := 22
    ENDIF

    mggthis := mggtotcr := mggtot1 := mggtot2 := mggtotr := 0
    SELECT Credit
    GOTO TOP

    Scroll()

    CredLsthd()

    DO WHILE Credit->( !Eof() )
        IF Credit->Amount == 0
            SKIP ALIAS Credit
            LOOP
        ENDIF
        mgthis := mgtotcr := mgtot1 := mgtot2 := mgtotr := 0
        mcodeno := Credit->Codeno
        DO WHILE ( Codeno = mcodeno ) .AND. Credit->( !Eof() )
            mthis := mtotcr := mtot1 := mtot2 := mtotr := 0
            DO CASE
            CASE Year(  Credit->Invdate ) = Year( Date() ) -3
                mtot2  += Credit->Amount
            CASE Year(  Credit->InvDate ) = Year( Date() ) -2
                mtot2  += Credit->Amount
            CASE Year(  Credit->InvDate ) = Year( Date() ) -1;
                    .AND. Month( Credit->InvDate ) < 11
                mtot2 += Credit->Amount
            CASE Year(  Credit->InvDate ) = Year( Date() ) -1;
                    .AND. Month( Date() ) = 1
                DO CASE
                CASE Month( Credit->InvDate ) = 12
                    mtotcr += Credit->Amount
                CASE Month( Credit->InvDate ) = 11
                    mtot1  += Credit->Amount
                OTHERWISE
                    mtot2  += Credit->Amount
                ENDCASE
            CASE Year(  Credit->InvDate ) = Year( Date() ) -1;
                    .AND. Month( Date() ) = 2
                DO CASE
                CASE Month( Credit->InvDate ) = 12
                    mtot1 += Credit->Amount
                CASE Month( Credit->InvDate ) = 11
                    mtot2  += Credit->Amount
                OTHERWISE
                    mtot2  += Credit->Amount
                ENDCASE
            CASE Year(  Credit->InvDate ) = Year( Date() );
                    .AND. Month( Credit->InvDate ) == Month( Date() )
                mthis  += Credit->Amount
            CASE Year(  Credit->InvDate ) = Year( Date() );
                    .AND. Month( Credit->InvDate ) == Month( Date() ) -1
                mtotcr += Credit->Amount
            CASE Year(  Credit->InvDate ) = Year( Date() );
                    .AND. Month( Credit->InvDate ) == Month( Date() ) -2
                mtot1  += Credit->Amount
            OTHERWISE
                mtot2  += Credit->Amount
            ENDCASE
            mgthis  += mthis
            mtotr   := mthis + mtotcr + mtot1 + mtot2
            mgtotcr += mtotcr
            mgtot1  += mtot1
            mgtot2  += mtot2
            mgtotr  += mtotr
            mtotcr := mtot1 := mtot2 := mtotr := mthis := 0
            SKIP ALIAS Credit
        ENDDO
        SELECT Name
        SEEK mcodeno
        @ nl, 0 SAY SubStr( Name->Name, 1, 23 )
        SELECT Credit
        @ nl, 24 SAY mgtot2  PICTURE "999,999.99"
        @ nl, 35 SAY mgtot1  PICTURE "999,999.99"
        @ nl, 46 SAY mgtotcr PICTURE "999,999.99"
        @ nl, 57 SAY mgthis  PICTURE "999,999.99"
        @ nl, 68 SAY mgtotr  PICTURE "999,999.99"
        nl++
        mggthis  += mgthis
        mggtotcr += mgtotcr
        mggtot1  += mgtot1
        mggtot2  += mgtot2
        mggtotr  += mgtotr
        IF nl > npl
            IF mwhere = "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            Credlsthd()                   // Below
        ENDIF
    ENDDO                         // Credit EOF()
    // **      nl := nl+1
    @ nl, 26 SAY Replicate( "-", 52 )
    nl++
    @ nl, 9 SAY "Grand Totals"
    @ nl, 24 SAY mggtot2  PICTURE "999,999.99"
    @ nl, 35 SAY mggtot1  PICTURE "999,999.99"
    @ nl, 46 SAY mggtotcr PICTURE "999,999.99"
    @ nl, 57 SAY mggthis  PICTURE "999,999.99"
    @ nl, 68 SAY mggtotr  PICTURE "999,999.99"
    nl++
    @ nl, 24 SAY Replicate( "-", 53 )
    nl += 2
    @ nl, 9 SAY "Percentage %"
    @ nl, 30 SAY ( mggtot2 / mggtotr * 100 ) PICTURE "999%"
    @ nl, 41 SAY ( mggtot1 / mggtotr * 100 ) PICTURE "999%"
    @ nl, 53 SAY ( mggtotcr / mggtotr * 100 ) PICTURE "999%"
    @ nl, 64 SAY ( mggthis / mggtotr * 100 ) PICTURE "999%"
    nl += 2
    mcodeno := Space( 8 )
    mname   := Space( 30 )
    mamount := 0
    SELECT Pay
    SET ORDER TO 2                    // Pay->Recon
    GOTO TOP
    SEEK "N"
    DO WHILE Pay->Recon = "N" .AND. Pay->( !Eof() )
        IF nl > npl
            nl := 2
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
        ENDIF
        ApRLock( 3 )
        mcodeno := Pay->Codeno
        UNLOCK
        IF mcodeno != Space( 8 )
            SELECT Name
            SEEK mcodeno
            ApRLock( 3 )
            mname := SubStr( Name->Name, 1, 20 )
            UNLOCK
            SELECT Pay
        ELSE
            mname := Space( 20 )
        ENDIF
        mamount += Pay->Amount
        @ nl, 0 SAY Pay->Cheqno
        @ nl, 8 SAY Pay->Cheqdate
        @ nl, 19 SAY Pay->Invno
        @ nl, 30 SAY mname
        @ nl, 51 SAY Pay->Amount PICTURE "999,999.99"
        @ nl, 70 SAY Pay->Cashno
        @ nl, 76 SAY Pay->Recon
        nl++
        SKIP ALIAS Pay
    ENDDO
    SELECT Pay
    SET ORDER TO 1
    nl++
    @ nl, 20 SAY "Awaiting Presentation"
    @ nl, 49 SAY mamount PICTURE "$9,999,999.99"
    nl += 2
    @ nl, 20 SAY "Grand Total Credits ="
    @ nl, 49 SAY mggtotr + mamount PICTURE "$9,999,999.99"
    IF nl > npl
        nl := 4
        IF mwhere == "P"
            EJECT
        ELSE
            WAIT
            nl++
            Scroll()
        ENDIF
    ENDIF
    IF mwhere == "P"
        EndPrint()
    ELSE
        nl++
        WAIT
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN NIL

// **--- End of CredList()

// *-------------------------------------------------------------------

STATIC FUNCTION Credlsthd()

    @  0, 0 SAY "Credit Listing " + Control->U_Name
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    // **   @  2, 0 SAY "Current Month ="
    // **  @  2,16 SAY STR(mmonthcr,2)
    @  2, 0 SAY "Name"
    @  2, 26 SAY "+ 2 Month"
    @  2, 39 SAY "1 Month"
    @  2, 50 SAY "Current"
    @  2, 59 SAY "This Month"
    @  2, 72 SAY "Total"
    @  3, 0 SAY Replicate( "-", 80 )
    nl := 4

    RETURN NIL
// ****------- End of Credlsthd()

// ********--------------  END OF FILE XLF_CRED.PRG
