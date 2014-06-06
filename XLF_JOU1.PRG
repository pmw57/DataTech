// ** JK 07-07-11 15:26:56

/*
   Program.....:                  XLF_JOU1.PRG
   Authors.....: J.Kirby
   Date........: 13/06/1993
   Functions...: GSTInvoice
   Static funcs: GstInv
*/

// (c) Copyright 2012 by Kirby Christchurch.

FUNCTION GstInvoice()

    // ***                    INVOICED BASIS GST RETURN
    mamount := mgsttot := mcodeamnt := mgstamnt := mgstpur := mpurtot := 0
    mamntcred := ncashnotot := 0
    ccashno := Space( 4 )
    Scroll()
    DispBox( 1, 1, 14, 79, 2 )
    mstmm := mendmm := SubStr( DToS( Date() ), 5, 2 )
    mstyy := mendyy := SubStr( DToS( Date() ), 1, 4 )
    csaleno  := SubStr( Message->Saleno5, 1, 2 )
    cpaycode := Message->Saleno4
    @  2, 5 SAY "Invoiced GOODS AND SERVICE TAX RETURN"
    @  4, 12 SAY "Invoiced Basis GST Report"
    @  6, 12 SAY "Include From Month"  GET mstmm   PICTURE "99"
    @  6, Col() + 2 SAY "Year "          GET mstyy   PICTURE "9999"
    @  8, 12 SAY "          To Month"  GET mendmm  PICTURE "99"
    @  8, Col() + 2 SAY "Year "          GET mendyy  PICTURE "9999"
    READ
    mcontinue := mok := ctot := mrecon := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        DispBox( 1, 1, 16, 79, 2 )
        @  4, 5 SAY "Invoiced GOODS AND SERVICE TAX RETURN"
        @  5, 12 SAY "Selected Period"
        @  7, 12 SAY "Include From Month"
        @  7, Col() + 2 SAY mstmm   PICTURE "99" COLOR "RG+"
        @  7, Col() + 2 SAY "Year"
        @  7, Col() + 2 SAY mstyy   PICTURE "9999"
        @  9, 12 SAY "          To Month"
        @  9, Col() + 2 SAY mendmm  PICTURE "99" COLOR "RG+"
        @  9, Col() + 2 SAY "Year"
        @  9, Col() + 2 SAY mendyy  PICTURE "9999"
        DispBox( 18, 1, 24, 79, 2 )
        nselect := 1
        @ 20, 4      PROMPT "1. Debits Invoice"
        @ 20, Col() + 2 PROMPT "2. Debits Name"
        @ 20, Col() + 2 PROMPT "3. Creditors"
        @ 20, Col() + 2 PROMPT "4. GST Form"
        @ 20, Col() + 2 PROMPT "5. Total"
        @ 22, 2 SAY "EDIT" COLOR "RG+"
        @ 22, Col() + 2 PROMPT "6. DebProf"
        @ 22, Col() + 2 PROMPT "7. Creditors"
        @ 22, Col() + 2 PROMPT "8. Payments"
        @ 22, Col() + 2 PROMPT "9. EXIT"
        @ 24, 60 SAY " DT756 "
        MENU TO nselect
        DO CASE
        CASE nselect == 9 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 6
            DebProfEd()                 // XLF_Deb
            LOOP
        CASE nselect == 7
            CredProfView()              // XLF_ACC.PRG
            LOOP
        CASE nselect == 8
            ViewPay()
            LOOP

        CASE nselect == 2   // Name Total Debit

            // **   mstmm:= mendmm:= SUBSTR(DTOS(DATE()),5,2)
            // **   mstyy:= mendyy:= SUBSTR(DTOS(DATE()),1,4)
            Scroll()
            DispBox( 1, 1, 12, 79, 2 )
            @  2, 5 SAY "Invoiced GOODS AND SERVICE TAX RETURN"
            @  4, 12 SAY "Invoiced Basis GST Report"
            @  6, 12 SAY "Include From Month"  GET mstmm   PICTURE "99"
            @  6, Col() + 2 SAY "Year "          GET mstyy   PICTURE "9999"
            @  8, 12 SAY "          To Month"  GET mendmm  PICTURE "99"
            @  8, Col() + 2 SAY "Year "          GET mendyy  PICTURE "9999"
            READ
            mst     := mstyy + mstmm
            mend    := mendyy + mendmm
            mamount := mgstot := 0
            namount := ngstamnt := 0
            mcodeno := Space( 8 )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            npl := 56
            mwhere := "S"

            Printsel( mwhere, npl )

            nl := 1
            @  0, 0 SAY Control->U_Name
            @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  2, 0 SAY "Debtors Listing  ";
                + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
            nl := 4
            SELECT DebProf
            SET ORDER TO 1     // 2 = Invoice  1 = Codeno
            GOTO TOP
            DO WHILE DebProf->( !Eof() )
                IF SubStr( DToS( DebProf->DbDate ), 1, 6 ) < mst
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF SubStr( DToS( Debprof->DbDate ), 1, 6 ) > mend
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF nl > npl
                    nl := 2
                    IF mwhere == "P"
                        EJECT
                        @  0, 0 SAY Control->U_Name
                        @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                        @  2, 0 SAY "Debtors Listing  ";
                            + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
                        nl := 4
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                mcodeno := Debprof->Codeno
                msaleno := Space( 4 )
                namount := ngstamnt := 0
                DO WHILE DebProf->Codeno = mcodeno .AND. ( !Eof() )
                    IF SubStr( DToS( DebProf->DbDate ), 1, 6 ) < mst
                        SKIP ALIAS DebProf
                        LOOP
                    ENDIF
                    IF SubStr( DToS( Debprof->DbDate ), 1, 6 ) > mend
                        SKIP ALIAS DebProf
                        LOOP
                    ENDIF
                    msaleno  := DebProf->Saleno
                    mamount  += DebProf->Amount
                    mgstot   += DebProf->Gstamnt
                    namount  += DebProf->Amount
                    ngstamnt += DebProf->Gstamnt
                    SKIP ALIAS DebProf
                ENDDO
                SELECT Name
                SEEK mcodeno
                @ nl, 13 SAY Name->Name
                @ nl, 52 SAY namount  PICTURE "999,999.99"
                @ nl, 63 SAY ngstamnt PICTURE "99,999.99"
                @ nl, 73 SAY msaleno
                nl++
                SELECT DebProf
                SKIP ALIAS DebProf
            ENDDO
            nl++
            @ nl, 35 SAY "Debit Total"
            @ nl, 49 SAY mamount PICTURE "$9,999,999.99"
            @ nl, 64 SAY mgstot PICTURE "$999,999.99"
            nl += 2
            IF mwhere == "P"
                EndPrint()
                SET MARGIN TO 0
            ELSE
                WAIT
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ENDIF

            LOOP

            // *---------------

        CASE nselect == 3   // Creditors

            mamount := mgsttot := mcodeamnt := mgstamnt := mgstpur := mpurtot := 0
            mamntcred := ncashnotot := 0
            ccashno := Space( 4 )
            mcontinue := mok := ctot := mrecon := "Y"
            nbnkopen := ncalc := ncredit := 0
            Scroll()
            DispBox( 1, 1, 12, 79, 2 )
            // **   mstmm:= mendmm:= SUBSTR(DTOS(DATE()),5,2)
            // **   mstyy:= mendyy:= SUBSTR(DTOS(DATE()),1,4)
            csaleno  := SubStr( Message->Saleno5, 1, 2 )
            cpaycode := Message->Saleno4
            @  2, 5 SAY "Invoiced GOODS AND SERVICE TAX RETURN"
            @  4, 12 SAY "Invoiced Basis GST Report"
            @  6, 12 SAY "Include From Month"  GET mstmm   PICTURE "99"
            @  6, Col() + 2 SAY "Year "          GET mstyy   PICTURE "9999"
            @  8, 12 SAY "          To Month"  GET mendmm  PICTURE "99"
            @  8, Col() + 2 SAY "Year "          GET mendyy  PICTURE "9999"
            nfbtax := mpertax := 0
            READ
            mst     := mstyy + mstmm
            mend    := mendyy + mendmm
            npay    := 0
            mpertax := 0
            mrecno := "N"
            ctot := "Y"
            mgsttot := mamount := mgstot := 0
            namount := ngstamnt := 0
            mcodeno := Space( 8 )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            npl := 56
            mwhere := "S"

            Printsel( mwhere, npl )

            nl := 2
            @  0, 0 SAY Control->U_Name
            @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  nl, 0 SAY "Creditors Invoices Listing";
                + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
            nl += 2
            SELECT CredProf
            GOTO TOP
            DO WHILE CredProf->( !Eof() )
                IF SubStr( DToS( CredProf->InvDate ), 1, 6 ) < mst
                    SKIP ALIAS CredProf
                    LOOP
                ENDIF
                IF SubStr( DToS( CredProf->InvDate ), 1, 6 ) > mend
                    SKIP ALIAS CredProf
                    LOOP
                ENDIF
                IF nl > npl
                    nl := 2
                    IF mwhere == "P"
                        EJECT
                        @  0, 0 SAY Control->U_Name
                        @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                        @  2, 0 SAY "Creditors Invoices Listing";
                            + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
                        nl := 4
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                SELECT Name
                SEEK CredProf->Codeno
                SELECT CredProf
                mamntcred  += CredProf->Amount
                ncashnotot += CredProf->Amount
                mgsttot    += CredProf->Tax
                IF CredProf->Tax > 0
                    mgstamnt += CredProf->Amount
                ENDIF
                @ nl, 0 SAY CredProf->InvDate
                @ nl, 12 SAY CredProf->Invno
                @ nl, 23 SAY SubStr( Name->Name, 1, 28 )
                @ nl, 52 SAY CredProf->Amount PICTURE "999,999.99"
                IF CredProf->Tax > 0
                    @ nl, 63 SAY CredProf->Tax PICTURE "99,999.99"
                ENDIF
                @ nl, 73 SAY CredProf->Cashno
                nl++
                SELECT CredProf
                SKIP ALIAS CredProf
            ENDDO
            nl++
            @ nl, 0 SAY "G.S.T"
            @ nl, 7 SAY mgstamnt PICTURE "$9,999,999.99"
            @ nl, 22 SAY "Credit Sub Total"
            @ nl, 40 SAY mamntcred PICTURE "9,999,999.99"
            IF mgsttot > 0
                @ nl, 53 SAY mgsttot PICTURE "9,999,999.99"
            ENDIF
            nl += 2
            mpaytot := mpaygst := mpayAmnt := 0
            @ nl, 2 SAY "Paid Listing"
            nl++
            SELECT Pay
            SET ORDER TO 3             // Codeno
            GOTO TOP
            DO WHILE Pay->( !Eof() )
                IF SubStr( DToS( Pay->CheqDate ), 1, 6 ) < mst
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF SubStr( DToS( Pay->CheqDate ), 1, 6 ) > mend
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF Pay->Stat == "C"   // This is done in XLF_Cred
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF nl > npl
                    nl := 2
                    IF mwhere == "P"
                        EJECT
                        @  0, 0 SAY Control->U_Name
                        @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                        @  2, 0 SAY "Paid  Listing";
                            + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
                        nl := 4
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                SELECT Name
                SEEK Pay->Codeno
                SELECT Pay
                mamntcred  += Pay->Amount
                mpaytot    += Pay->Amount
                IF Pay->GSTAmnt > 0
                    mgsttot  += Pay->Amount
                    mpaygst  += Pay->GSTAmnt
                    mpayAmnt += Pay->Amount
                    mgstAmnt += Pay->Amount
                ENDIF
                @ nl, 0 SAY Pay->CheqDate
                @ nl, 12 SAY Pay->Invno
                @ nl, 23 SAY SubStr( Name->Name, 1, 28 )
                @ nl, 52 SAY Pay->Amount PICTURE "999,999.99"
                IF Pay->GSTAmnt > 0
                    @ nl, 63 SAY Pay->GSTAmnt PICTURE "99,999.99"
                ENDIF
                @ nl, 73 SAY Pay->Cashno
                nl++
                SELECT Pay
                SKIP ALIAS Pay
            ENDDO
            // ******************
            nl++
            @ nl, 0 SAY "G.S.T"
            @ nl, 7 SAY mpayAmnt PICTURE "$9,999,999.99"
            @ nl, 22 SAY "Pay Sub Total"
            @ nl, 40 SAY mpaytot PICTURE "9,999,999.99"
            @ nl, 53 SAY mpaygst PICTURE "9,999,999.99"
            nl += 2
            @ nl, 0 SAY "G.S.T PURCHASES"
            @ nl, 18 SAY mgstamnt PICTURE "$9,999,999.99"
            @ nl, 32 SAY "Credit/Pay Total"
            @ nl, 51 SAY mamntcred PICTURE "9,999,999.99"
            @ nl, 63 SAY mgsttot PICTURE "9,999,999.99"
            nl += 2
            IF mwhere == "P"
                EndPrint()
                SET MARGIN TO 0
            ELSE
                WAIT
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ENDIF
            SELECT Pay
            SET ORDER TO 1

            LOOP

        CASE nselect == 1       // Debtors

            mamount := mgsttot := mcodeamnt := mgstamnt := mgstpur := mpurtot := 0
            mamntcred := ncashnotot := 0
            nbnkopen := ncalc := ncredit := 0
            Scroll()
            DispBox( 1, 1, 12, 79, 2 )
            // **   mstmm:= mendmm:= SUBSTR(DTOS(DATE()),5,2)
            // **   mstyy:= mendyy:= SUBSTR(DTOS(DATE()),1,4)
            csaleno  := SubStr( Message->Saleno5, 1, 2 )
            cpaycode := Message->Saleno4
            @  2, 5 SAY "Invoiced GOODS AND SERVICE TAX RETURN"
            @  4, 12 SAY "Invoiced Basis GST Report"
            @  6, 12 SAY "Include From Month"  GET mstmm   PICTURE "99"
            @  6, Col() + 2 SAY "Year "          GET mstyy   PICTURE "9999"
            @  8, 12 SAY "          To Month"  GET mendmm  PICTURE "99"
            @  8, Col() + 2 SAY "Year "          GET mendyy  PICTURE "9999"
            READ
            mst     := mstyy + mstmm
            mend    := mendyy + mendmm

            npl := 56
            mwhere := "S"

            Printsel( mwhere, npl )

            nl := 1
            @  0, 0 SAY Control->U_Name
            @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  2, 0 SAY "Debtors Listing  ";
                + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
            nl := 4
            mamount := mgstot := 0
            namount := ngstamnt := 0
            mcodeno := Space( 8 )
            SELECT DebProf
            // **      SET ORDER TO 2     // Invoice  1 = Codeno
            GOTO TOP
            DO WHILE DebProf->( !Eof() )
                IF SubStr( DToS( DebProf->DbDate ), 1, 6 ) < mst
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF SubStr( DToS( Debprof->DbDate ), 1, 6 ) > mend
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF nl > npl
                    nl := 2
                    IF mwhere == "P"
                        EJECT
                        @  0, 0 SAY Control->U_Name
                        @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                        @  2, 0 SAY "Debtors Listing  ";
                            + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
                        nl := 4
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                @ nl, 0 SAY DebProf->DbDate
                SELECT Name
                SEEK DebProf->Codeno
                IF DebProf->Saleno = "MANU"
                    @ nl, 12 SAY DebProf->Invno + "M"
                ELSE
                    @ nl, 12 SAY DebProf->Invno
                ENDIF
                @ nl, 20 SAY Name->Name
                @ nl, 52 SAY DebProf->Amount  PICTURE "999,999.99"
                @ nl, 63 SAY DebProf->Gstamnt PICTURE "99,999.99"
                @ nl, 74 SAY DebProf->Saleno
                nl++
                SELECT DebProf
                mamount  += DebProf->Amount
                mgstot   += DebProf->Gstamnt
                SKIP ALIAS DebProf
            ENDDO                      // DebProf EOF
            nl++
            @ nl, 36 SAY "Debit Totals"
            @ nl, 50 SAY mamount PICTURE "9,999,999.99"
            @ nl, 63 SAY mgstot PICTURE "999,999.99"
            nl += 2
            IF mwhere == "P"
                EndPrint()
                SET MARGIN TO 0
            ELSE
                WAIT
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ENDIF

            LOOP

        CASE nselect == 4     // GST Form

            Scroll()
            @ 10, 6 SAY "Please Wait"
            nbnkopen := ncalc := ncredit := 0
            SELECT DebProf
            GOTO TOP
            DO WHILE DebProf->( !Eof() )
                IF DebProf->Amount = 0
                    ApRLock( 3 )
                    DebProf->GSTAmnt := 0
                    UNLOCK
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF SubStr( DebProf->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    ApRLock( 3 )
                    DebProf->GSTAmnt := 0
                    UNLOCK
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF SubStr( DebProf->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    ApRLock( 3 )
                    DebProf->GSTAmnt := 0
                    UNLOCK
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                ApRLock( 3 )
                DebProf->GSTAmnt := Round( ( ( DebProf->Amount * 3 ) / 23 ), 2 )
                UNLOCK
                SKIP ALIAS DebProf
            ENDDO
            Scroll()
            DispBox( 1, 1, 16, 79, 2 )
            csaleno  := SubStr( Message->Saleno5, 1, 2 )
            cpaycode := Message->Saleno4
            @  2, 5        SAY "Invoiced GOODS AND SERVICE TAX RETURN"
            @  4, 12        SAY "Invoiced Basis GST Report"
            @  6, 12        SAY "Include From Month"  GET mstmm   PICTURE "99"
            @  6, Col() + 2   SAY "Year "          GET mstyy   PICTURE "9999"
            @  8, 12 SAY "          To Month"  GET mendmm  PICTURE "99"
            @  8, Col() + 2   SAY "Year "          GET mendyy  PICTURE "9999"
            @  10, 5       SAY " Credit Adjust Calc #13 " GET cpaycode PICTURE "@!"
            @  10, Col() + 13 SAY "Export Sales #" GET csaleno PICTURE "@!"
            READ
            nfbtax := mpertax := 0
            mst     := mstyy + mstmm
            mend    := mendyy + mendmm
            npay    := 0
            SELECT CredProf
            GOTO TOP
            DO WHILE CredProf->( !Eof() )
                IF SubStr( DToS( CredProf->InvDate ), 1, 6 ) < mst
                    SKIP ALIAS CredProf
                    LOOP
                ENDIF
                IF SubStr( DToS( CredProf->InvDate ), 1, 6 ) > mend
                    SKIP ALIAS CredProf
                    LOOP
                ENDIF
                IF CredProf->Cashno = cpaycode
                    nPay += CredProf->Amount                  // # 13
                ENDIF
                SKIP ALIAS CredProf
            ENDDO
            SELECT DebProf
            SET ORDER TO 1     // Codeno
            GOTO TOP
            DO WHILE DebProf->( !Eof() )
                IF SubStr( DToS( DebProf->DbDate ), 1, 6 ) < mst
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF SubStr( DToS( DebProf->DbDate ), 1, 6 ) > mend
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF SubStr( DebProf->Saleno, 1, 2 ) = csaleno
                    nfbtax += DebProf->Amount                  // Export Tax
                ENDIF
                SELECT DebProf
                SKIP ALIAS DebProf
            ENDDO
            mpertax := 0
            @  11, 5 SAY " Zero Rated Supplies #  6"  GET nfbtax   PICTURE "9999999.99"
            @  11, Col() + 2  SAY "Export Sales " + csaleno
            @  11, Col() + 2  SAY nfbtax                              PICTURE "9,999,999.99"
            @  12, 5 SAY " Adjust calculation  #  9 "  GET ncalc   PICTURE "999999.99"
            @  12, Col() + 2  SAY "Debtors GST Amnt"
            @  13, 5 SAY " Credit Adjust Calc  # 13 "  GET npay    PICTURE "999999.99"
            @  13, Col() + 2  SAY "Credit GST Amnt"
            READ
            mpertax := 0
            mrecno := "N"
            ctot := "Y"
            // ***********************************************************
            mgsttot := mamount := mgstot := 0
            namount := ngstamnt := 0
            mgstamnt := 0
            mcodeno := Space( 8 )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            npl := 56
            mwhere := "S"

            Printsel( mwhere, npl )

            nl := 1
            SELECT DebProf
            SET ORDER TO 1     // Invoice  1 = Codeno
            GOTO TOP
            DO WHILE DebProf->( !Eof() )
                IF SubStr( DToS( DebProf->DbDate ), 1, 6 ) < mst
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF SubStr( DToS( Debprof->DbDate ), 1, 6 ) > mend
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                mamount  += DebProf->Amount
                mgstot   += DebProf->Gstamnt
                SELECT DebProf
                SKIP ALIAS DebProf
            ENDDO
            // *****************************
            SELECT CredProf
            GOTO TOP
            DO WHILE CredProf->( !Eof() )
                IF SubStr( DToS( CredProf->InvDate ), 1, 6 ) < mst
                    SKIP ALIAS CredProf
                    LOOP
                ENDIF
                IF SubStr( DToS( CredProf->InvDate ), 1, 6 ) > mend
                    SKIP ALIAS CredProf
                    LOOP
                ENDIF
                mamntcred  += CredProf->Amount
                ncashnotot += CredProf->Amount
                mgsttot    += CredProf->Tax
                IF CredProf->Tax > 0
                    mgstamnt += CredProf->Amount
                ENDIF
                SELECT CredProf
                SKIP ALIAS CredProf
            ENDDO
            nl++
            SELECT Pay
            GOTO TOP
            DO WHILE Pay->( !Eof() )
                IF SubStr( DToS( Pay->CheqDate ), 1, 6 ) < mst
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF SubStr( DToS( Pay->CheqDate ), 1, 6 ) > mend
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF Pay->Stat == "C"   // This is done in XLF_Cred
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                mamntcred  += Pay->Amount
                ncashnotot += Pay->Amount
                mgsttot    += Pay->GSTAmnt
                IF Pay->GSTAmnt > 0
                    mgstamnt += Pay->Amount
                ENDIF
                SELECT Pay
                SKIP ALIAS Pay
            ENDDO
            mpurtot := mamntcred
            mgstpur := mgsttot

            @ nl, 0 SAY "INVOICED BASIS GOODS AND SERVICE TAX RETURN";
                + " From " + mstmm + "/" + mstyy + "  To " + mendmm + "/" + mendyy
            nl += 2
            @ nl, 0 SAY "Total Sales & Income for period.  #  5"
            @ nl, 40 SAY mamount PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "Zero-rated supplies included in 5 #  6"
            @ nl, 40 SAY nfbtax PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "Subtract box 6 from Box 5         #  7"
            @ nl, 40 SAY mamount - nfbtax PICTURE "9,999,999.99"
            nl++
            mamount := ( ( mamount - nfbtax ) * 3 ) / 23
            @ nl, 0 SAY "Box 7 Times 3 Divide by 23        #  8"
            @ nl, 40 SAY mamount PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "Adjust from calculation sheet     #  9"
            @ nl, 40 SAY ncalc PICTURE "9,999,999.99"
            nl++
            mamount := mamount + ncalc
            @ nl, 0 SAY "Add #8 & #9 Total GST Collected.  # 10"
            @ nl, 40 SAY mamount PICTURE "9,999,999.99"
            nl += 2

            @ nl, 0 SAY "       Total Purchases/Expenses   # 11"
            @ nl, 40 SAY mgstamnt PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "Box 11 Times 3 Divide by 23       # 12"
            mgstamnt := ( mgstamnt * 3 ) / 23
            @ nl, 40 SAY mgstamnt PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "Credit adjustment from Calc       # 13"
            @ nl, 40 SAY npay PICTURE "9,999,999.99"
            nl++
            mgstamnt := mgstamnt + npay     // ncredit
            @ nl, 0 SAY "        Total GST Credit          # 14"
            @ nl, 40 SAY mgstamnt PICTURE "9,999,999.99"
            nl += 2
            @ nl, 0 SAY "       Payable/Refunded           # 15"
            IF mamount > mgstamnt
                @ nl, 40 SAY mamount - mgstamnt PICTURE "9,999,999.99"
                @ nl, 56 SAY "Payable"
            ELSE
                @ nl, 40 SAY mgstamnt - mamount PICTURE "9,999,999.99"
                @ nl, 56 SAY "Refund"
            ENDIF
            nl += 2
            @ nl, 5 SAY Control->U_Name
            @ nl, 50 SAY Control->U_Gstno
            nl++
            @ nl, 0 SAY " "
            IF mwhere == "P"
                EndPrint()
                SET MARGIN TO 0
            ELSE
                WAIT
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ENDIF

            RETURN                  // Figures are wrong if must RETURN NIL
        CASE nselect == 5   // GSTInv
            GSTInv()          // Above
            LOOP

        ENDCASE            // nselect
    ENDDO             // mcontinue

    // **----------- GSTInvoice

    // **-------------------------------------------------------------------

STATIC FUNCTION GstInv()

    // ***                    INVOICED BASIS GST RETURN NIL
    mamount := mgsttot := mcodeamnt := mgstamnt := mgstpur := mpurtot := 0
    mamntcred := ncashnotot := 0
    ccashno := Space( 4 )
    mcontinue := mok := ctot := mrecon := "Y"
    DO WHILE mcontinue == "Y"
        nbnkopen := ncalc := ncredit := 0
        Scroll()
        @ 10, 6 SAY "Please Wait Check Print out"
        SELECT DebProf
        GOTO TOP
        DO WHILE DebProf->( !Eof() )
            IF DebProf->Amount = 0
                ApRLock( 3 )
                DebProf->GSTAmnt := 0
                UNLOCK
                SKIP ALIAS DebProf
                LOOP
            ENDIF
            IF SubStr( DebProf->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                ApRLock( 3 )
                DebProf->GSTAmnt := 0
                UNLOCK
                SKIP ALIAS DebProf
                LOOP
            ENDIF
            IF SubStr( DebProf->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                ApRLock( 3 )
                DebProf->GSTAmnt := 0
                UNLOCK
                SKIP ALIAS DebProf
                LOOP
            ENDIF
            ApRLock( 3 )
            DebProf->GSTAmnt := Round( ( ( DebProf->Amount * 3 ) / 23 ), 2 )
            UNLOCK
            SKIP ALIAS DebProf
        ENDDO
        Scroll()
        DispBox( 1, 1, 16, 79, 2 )
        // **   mstmm:= mendmm:= SUBSTR(DTOS(DATE()),5,2)
        // **   mstyy:= mendyy:= SUBSTR(DTOS(DATE()),1,4)
        csaleno  := SubStr( Message->Saleno5, 1, 2 )
        cpaycode := Message->Saleno4
        @  2, 5 SAY "Invoiced GOODS AND SERVICE TAX RETURN"
        @  4, 12 SAY "Invoiced Basis GST Report"
        @  6, 12 SAY "Include From Month"  GET mstmm   PICTURE "99"
        @  6, Col() + 2 SAY "Year "          GET mstyy   PICTURE "9999"
        @  8, 12 SAY "          To Month"  GET mendmm  PICTURE "99"
        @  8, Col() + 2 SAY "Year "          GET mendyy  PICTURE "9999"
        @ 10, 12      SAY "Credit Adjust Calc #13" GET cpaycode PICTURE "@!"
        @ 10, Col() + 2 SAY "Export Sales #" GET csaleno PICTURE "@!"
        READ
        nfbtax := mpertax := 0
        mst     := mstyy + mstmm
        mend    := mendyy + mendmm
        npay    := 0
        // *************
        SELECT CredProf
        GOTO TOP
        DO WHILE CredProf->( !Eof() )
            IF SubStr( DToS( CredProf->InvDate ), 1, 6 ) < mst
                SKIP ALIAS CredProf
                LOOP
            ENDIF
            IF SubStr( DToS( CredProf->InvDate ), 1, 6 ) > mend
                SKIP ALIAS CredProf
                LOOP
            ENDIF
            IF CredProf->Cashno = cpaycode
                nPay += CredProf->Amount                  // # 13
            ENDIF
            SKIP ALIAS CredProf
        ENDDO
        SELECT DebProf
        SET ORDER TO 1     // Codeno
        GOTO TOP
        DO WHILE DebProf->( !Eof() )
            IF SubStr( DToS( DebProf->DbDate ), 1, 6 ) < mst
                SKIP ALIAS DebProf
                LOOP
            ENDIF
            IF SubStr( DToS( DebProf->DbDate ), 1, 6 ) > mend
                SKIP ALIAS DebProf
                LOOP
            ENDIF
            IF SubStr( DebProf->Saleno, 1, 2 ) = csaleno
                nfbtax += DebProf->Amount                  // Export Tax
            ENDIF
            SELECT DebProf
            SKIP ALIAS DebProf
        ENDDO
        mpertax := 0
        @  12, 5 SAY " Zero Rated Supplies #  6"  GET nfbtax  PICTURE "9999999.99"
        @  12, Col() + 2 SAY "Export Sales " + csaleno
        @  12, Col() + 2 SAY nfbtax                               PICTURE "9,999,999.99"
        @  13, 5 SAY " Adjust calculation  #  9 "  GET ncalc   PICTURE "999999.99"
        @  13, Col() + 2 SAY "Debtors GST Amnt"
        @  14, 5 SAY " Credit Adjust Calc  # 13 "  GET npay    PICTURE "999999.99"
        @  14, Col() + 2 SAY "Credit GST Amnt"
        READ
        mpertax := 0
        mrecno := "N"
        ctot := "Y"
        // ***********************************************************
        mgsttot := mamount := mgstot := 0
        namount := ngstamnt := 0
        mcodeno := Space( 8 )
        cname := "Y"
        cnamedet := ApGetN( "Do you want Name details" )
        IF cnamedet = "Y"
            cname := ApGetN( "Show Full Debtors Details" )
        ENDIF
        IF PressedEsc()
            RETURN NIL
        ENDIF
        npl := 56
        mwhere := "S"

        Printsel( mwhere, npl )

        nl := 1
        IF cnamedet = "Y"
            @  0, 0 SAY Control->U_Name
            @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  2, 0 SAY "Debtors Listing  ";
                + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
            nl := 4
        ENDIF
        SELECT DebProf
        SET ORDER TO 1     // Invoice  1 = Codeno
        GOTO TOP
        DO WHILE DebProf->( !Eof() )
            IF SubStr( DToS( DebProf->DbDate ), 1, 6 ) < mst
                SKIP ALIAS DebProf
                LOOP
            ENDIF
            IF SubStr( DToS( Debprof->DbDate ), 1, 6 ) > mend
                SKIP ALIAS DebProf
                LOOP
            ENDIF
            IF nl > npl
                nl := 2
                IF mwhere == "P"
                    EJECT
                    @  0, 0 SAY Control->U_Name
                    @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  2, 0 SAY "Debtors Listing  ";
                        + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
                    nl := 4
                ELSE
                    WAIT
                    Scroll()
                ENDIF
            ENDIF
            DO CASE
            CASE cname = "N"
                mcodeno := Debprof->Codeno
                msaleno := Space( 4 )
                namount := ngstamnt := 0
                DO WHILE DebProf->Codeno = mcodeno .AND. ( !Eof() )
                    IF SubStr( DToS( DebProf->DbDate ), 1, 6 ) < mst
                        SKIP ALIAS DebProf
                        LOOP
                    ENDIF
                    IF SubStr( DToS( Debprof->DbDate ), 1, 6 ) > mend
                        SKIP ALIAS DebProf
                        LOOP
                    ENDIF
                    msaleno  := DebProf->Saleno
                    mamount  += DebProf->Amount
                    mgstot   += DebProf->Gstamnt
                    namount  += DebProf->Amount
                    ngstamnt += DebProf->Gstamnt
                    SKIP ALIAS DebProf
                ENDDO
                IF cnamedet = "Y"
                    SELECT Name
                    SEEK mcodeno
                    @ nl, 20 SAY Name->Name
                    @ nl, 52 SAY namount  PICTURE "999,999.99"
                    @ nl, 63 SAY ngstamnt PICTURE "99,999.99"
                    @ nl, 73 SAY msaleno
                ENDIF
                nl++
            CASE cname = "Y"
                IF cnamedet = "Y"
                    @ nl, 0 SAY DebProf->DbDate
                    SELECT Name
                    SEEK DebProf->Codeno
                    SELECT DebProf
                    IF DebProf->Saleno = "MANU"
                        @ nl, 12 SAY DebProf->Invno + "M"
                    ELSE
                        @ nl, 12 SAY DebProf->Invno
                    ENDIF
                    @ nl, 20 SAY Name->Name
                    @ nl, 52 SAY DebProf->Amount  PICTURE "999,999.99"
                    @ nl, 63 SAY DebProf->Gstamnt PICTURE "99,999.99"
                    @ nl, 74 SAY DebProf->Saleno
                    nl++
                ENDIF
                mamount  += DebProf->Amount
                mgstot   += DebProf->Gstamnt
            ENDCASE                     // cname
            SELECT DebProf
            SKIP ALIAS DebProf
        ENDDO
        IF cnamedet = "Y"
            nl++
            @ nl, 36 SAY "Debit Total"
            @ nl, 50 SAY mamount PICTURE "9,999,999.99"
            @ nl, 63 SAY mgstot PICTURE "999,999.99"
            nl += 2
            @  nl, 0 SAY "Creditors Invoices Listing";
                + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
            nl += 2
            IF mwhere == "S"
                nl := 0
                WAIT
                Scroll()
                nl++
            ENDIF
        ENDIF   // cnamedet
        // *****************************
        SELECT CredProf
        GOTO TOP
        DO WHILE CredProf->( !Eof() )
            IF SubStr( DToS( CredProf->InvDate ), 1, 6 ) < mst
                SKIP ALIAS CredProf
                LOOP
            ENDIF
            IF SubStr( DToS( CredProf->InvDate ), 1, 6 ) > mend
                SKIP ALIAS CredProf
                LOOP
            ENDIF
            IF nl > npl
                nl := 2
                IF mwhere == "P"
                    EJECT
                    @  0, 0 SAY Control->U_Name
                    @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  2, 0 SAY "Creditors Invoices Listing";
                        + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
                    nl := 4
                ELSE
                    WAIT
                    Scroll()
                ENDIF
            ENDIF
            SELECT Name
            SEEK CredProf->Codeno
            SELECT CredProf
            mamntcred  += CredProf->Amount
            ncashnotot += CredProf->Amount
            mgsttot    += CredProf->Tax
            IF CredProf->Tax > 0
                mgstamnt += CredProf->Amount
            ENDIF
            IF cnamedet = "Y"
                @ nl, 0 SAY CredProf->InvDate
                @ nl, 12 SAY CredProf->Invno
                @ nl, 23 SAY SubStr( Name->Name, 1, 28 )
                @ nl, 52 SAY CredProf->Amount PICTURE "999,999.99"
                IF CredProf->Tax > 0
                    @ nl, 63 SAY CredProf->Tax PICTURE "99,999.99"
                ENDIF
                @ nl, 73 SAY CredProf->Cashno
                nl++
            ENDIF                           // cname
            SELECT CredProf
            SKIP ALIAS CredProf
        ENDDO
        IF cnamedet = "Y"
            nl++
            @  nl, 0 SAY "Payed Listing"
            nl++
        ENDIF
        SELECT Pay
        SET ORDER TO 3                        // Codeno
        GOTO TOP
        DO WHILE Pay->( !Eof() )
            IF SubStr( DToS( Pay->CheqDate ), 1, 6 ) < mst
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF SubStr( DToS( Pay->CheqDate ), 1, 6 ) > mend
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF Pay->Stat == "C"   // This is done in XLF_Cred
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF nl > npl
                nl := 2
                IF mwhere == "P"
                    EJECT
                    @  0, 0 SAY Control->U_Name
                    @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  2, 0 SAY "Creditors Invoices Listing";
                        + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
                    nl := 4
                ELSE
                    WAIT
                    Scroll()
                ENDIF
            ENDIF
            SELECT Name
            SEEK Pay->Codeno
            SELECT Pay
            mamntcred  += Pay->Amount
            ncashnotot += Pay->Amount
            mgsttot    += Pay->GSTAmnt
            IF Pay->GSTAmnt > 0
                mgstamnt += Pay->Amount
            ENDIF
            IF cnamedet = "Y"
                @ nl, 0 SAY Pay->CheqDate
                @ nl, 12 SAY Pay->Invno
                @ nl, 23 SAY SubStr( Name->Name, 1, 28 )
                @ nl, 52 SAY Pay->Amount PICTURE "999,999.99"
                IF Pay->GSTAmnt > 0
                    @ nl, 63 SAY Pay->GSTAmnt PICTURE "99,999.99"
                ENDIF
                @ nl, 73 SAY Pay->Cashno
                nl++
            ENDIF                           // cname
            SELECT Pay
            SKIP ALIAS Pay
        ENDDO
        // ******************
        mpurtot := mamntcred
        mgstpur := mgsttot
        nl++
        IF cnamedet = "Y"
            @ nl, 0 SAY "G.S.T PURCHASES"
            @ nl, 18 SAY mgstamnt PICTURE "$9,999,999.99"
            @ nl, 35 SAY "Credit Total"
            @ nl, 51 SAY mamntcred PICTURE "9,999,999.99"
            IF mgsttot > 0
                @ nl, 63 SAY mgsttot PICTURE "9,999,999.99"
            ENDIF
            nl += 2
            IF mwhere == "S"
                nl := 0
                WAIT
                Scroll()
                nl++
            ENDIF
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
        ENDIF
        @ nl, 0 SAY "INVOICED BASIS GOODS AND SERVICE TAX RETURN";
            + " From " + mstmm + "/" + mstyy + "  To " + mendmm + "/" + mendyy
        nl += 2
        @ nl, 0 SAY "Total Sales & Income for period.  #  5"
        @ nl, 40 SAY mamount PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "Zero-rated supplies included in 5 #  6"
        @ nl, 40 SAY nfbtax PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "Subtract box 6 from Box 5         #  7"
        @ nl, 40 SAY mamount - nfbtax PICTURE "9,999,999.99"
        nl++
        mamount := ( ( mamount - nfbtax ) * 3 ) / 23
        @ nl, 0 SAY "Box 7 Times 3 Divide by 23        #  8"
        @ nl, 40 SAY mamount PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "Adjust from calculation sheet     #  9"
        @ nl, 40 SAY ncalc PICTURE "9,999,999.99"
        nl++
        mamount := mamount + ncalc
        @ nl, 0 SAY "Add #8 & #9 Total GST Collected.  # 10"
        @ nl, 40 SAY mamount PICTURE "9,999,999.99"
        nl += 2
        @ nl, 0 SAY "       Total Purchases/Expenses   # 11"
        @ nl, 40 SAY mgstamnt PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "Box 11 Times 3 Divide by 23       # 12"
        mgstamnt := ( mgstamnt * 3 ) / 23
        @ nl, 40 SAY mgstamnt PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "Credit adjustment from Calc       # 13"
        @ nl, 40 SAY npay PICTURE "9,999,999.99"
        nl++
        mgstamnt := mgstamnt + npay     // ncredit
        @ nl, 0 SAY "        Total GST Credit          # 14"
        @ nl, 40 SAY mgstamnt PICTURE "9,999,999.99"
        nl += 2
        @ nl, 0 SAY "       Payable/Refunded           # 15"
        IF mamount > mgstamnt
            @ nl, 40 SAY mamount - mgstamnt PICTURE "9,999,999.99"
            @ nl, 56 SAY "Payable"
        ELSE
            @ nl, 40 SAY mgstamnt - mamount PICTURE "9,999,999.99"
            @ nl, 56 SAY "Refund"
        ENDIF
        nl += 2
        @ nl, 5 SAY Control->U_Name
        @ nl, 50 SAY Control->U_Gstno
        nl++
        @ nl, 0 SAY " "
        IF mwhere == "P"
            EndPrint()
            SET MARGIN TO 0
        ELSE
            WAIT
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ENDIF
        mcontinue := "N"
    ENDDO

    SELECT Pay
    SET ORDER TO 1

    // ** SELECT DebProf
    // ** SET ORDER TO 1

    RETURN NIL

// **------------- End GSTInv

// *******-------------------  END OF FILE XLF_JOU1.PRG
