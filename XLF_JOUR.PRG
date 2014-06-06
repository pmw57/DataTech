// ** JK 08-09-11 16:18:02

/*
   Program.....:                  XLF_JOUR.PRG
   Authors.....: J.Kirby
   Date........: 13/06/1993
   Functions...: DepPayPre, MenuJour
   Static funcs: GstList, GSTStandard, GstHead, PayDepRC
*/

STATIC FUNCTION GstList()

    mamount := mgsttot := mcodeamnt := mgstamnt := mgstpur := mpurtot := 0
    mamntcred := ncashnotot := 0
    ccashno := Space( 4 )
    Scroll()
    DispBox( 1, 1, 14, 79, 2 )
    mstmm := mendmm := SubStr( DToS( Date() ), 5, 2 )
    mstyy := mendyy := SubStr( DToS( Date() ), 1, 4 )
    csaleno  := SubStr( Message->Saleno5, 1, 2 )
    cpaycode := Message->Saleno4
    @  2, 12 SAY "GOODS AND SERVICE TAX RETURN"
    @  4, 12 SAY "GST Report"
    @  6, 12 SAY "Include From Month"  GET mstmm   PICTURE "99"
    @  6, Col() + 2 SAY "Year "          GET mstyy   PICTURE "9999"
    @  8, 12 SAY "          To Month"  GET mendmm  PICTURE "99"
    @  8, Col() + 2 SAY "Year "          GET mendyy  PICTURE "9999"
    @ 14, 60 SAY " DT751 "
    READ

    mcontinue := mok := ctot := mrecon := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        DispBox( 1, 1, 16, 79, 2 )
        @  2, 12 SAY "Goods and Service Tax RETURN"
        @  5, 12 SAY "Selected Period" COLOR "RG+"
        @  7, 12 SAY "Include From Month"
        @  7, Col() + 2 SAY mstmm   PICTURE "99" COLOR "RG+"
        @  7, Col() + 2 SAY "Year"
        @  7, Col() + 2 SAY mstyy   PICTURE "9999"
        @  9, 12 SAY "          To Month"
        @  9, Col() + 2 SAY mendmm  PICTURE "99" COLOR "RG+"
        @  9, Col() + 2 SAY "Year"
        @  9, Col() + 2 SAY mendyy  PICTURE "9999"
        DispBox( 18, 1, 24, 79, 2 )
        @ 18, 8 SAY " G.S.T Reports - Edits " COLOR "RG+"
        nselect := 1
        @ 20, 8      PROMPT "1. GST Report"
        @ 20, Col() + 2 PROMPT "2. Payments"
        @ 20, Col() + 2 PROMPT "3. Deposits"
        @ 20, Col() + 2 PROMPT "4. GST Form"
        @ 20, Col() + 2 PROMPT "5. Bank Recon"

        @ 22, 2 SAY "EDIT" COLOR "RG+"
        @ 22, Col() + 2 PROMPT "6. Edit Payments"
        @ 22, Col() + 2 PROMPT "7. Edit Deposits"
        @ 22, Col() + 2 PROMPT "8. EXIT"
        @ 24, 60 SAY " DT751 "
        MENU TO nselect
        DO CASE
        CASE nselect == 8 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 1
            GSTStandard()                 // XLF_Jour.PRG
            LOOP
        CASE nselect == 5
            PayDepRC()
            LOOP
        CASE nselect == 6
            ViewPay()
            LOOP
        CASE nselect == 7
            DepView()                   // XLF_Dep.PRG
            LOOP
        CASE nselect == 4              // GST Report

            nfbtax := nbnkopen := ncalc := ncredit := 0
            // **   mstmm:= mendmm:= SUBSTR(DTOS(DATE()),5,2)
            // **   mstyy:= mendyy:= SUBSTR(DTOS(DATE()),1,4)
            Scroll()
            DispBox( 1, 1, 20, 79, 2 )
            @  2, 5 SAY "GOODS AND SERVICE TAX RETURN"
            @  4, 12 SAY "GST Report"
            @  6, 12 SAY "Include From Month"  GET mstmm   PICTURE "99"
            @  6, Col() + 2 SAY "Year "          GET mstyy   PICTURE "9999"
            @  8, 12 SAY "          To Month"  GET mendmm  PICTURE "99"
            @  8, Col() + 2 SAY "Year "          GET mendyy  PICTURE "9999"
            READ
            mst     := mstyy + mstmm
            mend    := mendyy + mendmm
            csaleno  := SubStr( Message->Saleno5, 1, 2 )
            cpaycode := Message->Saleno4
            @ 12, 6 SAY "Export Sales #"      GET csaleno PICTURE "!!"
            @ 13, 6 SAY "Credit Adjust Calc #13" GET cpaycode PICTURE "@!"
            READ
            mst     := mstyy + mstmm
            mend    := mendyy + mendmm
            // **      namount := 0
            npay    := 0
            SELECT Pay
            SET ORDER TO 1     // Codeno
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
                IF Pay->Cashno = cpaycode
                    nPay += Pay->Amount                  // # 13
                ENDIF
                SKIP ALIAS Pay
            ENDDO
            SELECT Deposit
            GOTO TOP
            DO WHILE Deposit->( !Eof() )
                IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) < mst
                    SKIP ALIAS Deposit
                    LOOP
                ENDIF
                IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) > mend
                    SKIP ALIAS Deposit
                    LOOP
                ENDIF
                IF SubStr( Deposit->Saleno, 1, 2 ) = csaleno
                    nfbtax += Deposit->Amount
                ENDIF
                SELECT Deposit
                SKIP ALIAS Deposit
            ENDDO
            mpertax := 0
            @ 15, 5 SAY " Zero Rated Supplies #  6 " GET nfbtax  PICTURE "9999999.99"
            @ 15, Col() + 2 SAY "Export Sales " + csaleno
            @ 15, Col() + 2 SAY nfbtax                              PICTURE "9,999,999.99"
            @ 16, 5 SAY " Adjust calculation  #  9 " GET ncalc   PICTURE "9999999.99"
            @ 17, 5 SAY " Credit Adjust Calc  # 13 " GET npay    PICTURE "9999999.99"
            READ
            SELECT Balance
            SEEK mst
            nbnkopen := Balance->Amount
            @ 18, 9 SAY "Bank Opening Balance =" GET nbnkopen PICTURE "9999999.99"
            READ
            mrecon := ApGetN( "PRESENTED Cheques ONLY" )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            // **   SELECT Control
            // **   ApRLock( 3 )
            // **   Control->BankOpen := nbnkopen
            // **   UNLOCK
            npl := 56
            mwhere := "S"

            Printsel( mwhere, npl )

            nl := 1
            @  0, 0 SAY Control->U_Name
            @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  2, 0 SAY "Payments Listing  ";
                + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
            nl := 4
            mcodeno := Space( 8 )
            cname   := Space( 30 )
            SELECT Pay
            GOTO TOP
            mamount := mgsttot := mcodeamnt := mgstamnt := mgstpur := mpurtot := 0
            DO WHILE Pay->( !Eof() )
                IF SubStr( DToS( Pay->Cheqdate ), 1, 6 ) < mst
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF mrecon == "Y"
                    IF Pay->Recon != "P"
                        SKIP ALIAS Pay
                        LOOP
                    ENDIF
                ENDIF                      // mok
                IF SubStr( DToS( Pay->Cheqdate ), 1, 6 ) > mend
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                mcodeno := Pay->Codeno
                IF mcodeno != Space( 8 )
                    SELECT Name
                    SEEK mcodeno
                    cname := Name->Name
                    SELECT Pay
                ELSE
                    cname := Space( 30 )
                ENDIF
                ApRLock( 3 )
                mamount := Pay->Amount + mamount
                mgsttot := Pay->Gstamnt + mgsttot
                IF Gstamnt > 0
                    mgstamnt := Pay->Amount + mgstamnt
                ENDIF
                SELECT Pay
                SKIP ALIAS Pay
            ENDDO
            mpurtot := mamount
            mgstpur := mgsttot
            mstot := mutot := mgstot := mgutot := mgsttot := mggsttot := mamount := 0
            mmsamount := mmuamount := mamount := mgsttot := mdeptot := 0
            SELECT Deposit
            GOTO TOP
            DO WHILE Deposit->( !Eof() )
                IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) < mst
                    SKIP ALIAS Deposit
                    LOOP
                ENDIF
                IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) > mend
                    SKIP ALIAS Deposit
                    LOOP
                ENDIF
                IF Deposit->GstAmnt > 0
                    mgstot  := Deposit->Amount + mgstot
                    mgsttot := Deposit->Gstamnt + mgsttot
                ELSE
                    mgutot := Deposit->Amount + mgutot
                ENDIF
                SELECT Deposit
                SKIP ALIAS Deposit
            ENDDO
            mdeptot := mgstot + mgutot
            @ nl, 0 SAY "GOODS AND SERVICE TAX RETURN";
                + " From " + mstmm + "/" + mstyy + "  To " + mendmm + "/" + mendyy
            nl += 2
            @ nl, 0 SAY "Total Sales & Income for period.  #  5"
            @ nl, 40 SAY mgstot + nfbtax PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "Zero-rated supplies included in 5 #  6"
            @ nl, 40 SAY nfbtax PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "Subtract box 6 from Box 5         #  7"
            @ nl, 40 SAY mgstot PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "Box 7 Times 3 Divide by 23        #  8"
            mgsttot := ( mgstot * 3 ) / 23
            @ nl, 40 SAY mgsttot PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "Adjust from calculation sheet     #  9"
            @ nl, 40 SAY ncalc PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "Add #8 & #9 Total GST Collected.  # 10"
            @ nl, 40 SAY mgsttot + ncalc PICTURE "9,999,999.99"
            nl += 2
            @ nl, 0 SAY "       Total Purchases/Expenses   # 11"
            @ nl, 40 SAY mgstamnt PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "Box 11 Times 3 Divide by 23       # 12"
            mgstpur := ( mgstamnt * 3 ) / 23
            @ nl, 40 SAY mgstpur PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "Credit adjustment from Calc       # 13"
            @ nl, 40 SAY npay PICTURE "9,999,999.99"
            nl++
            @ nl, 0 SAY "        Total GST Credit          # 14"
            @ nl, 40 SAY mgstpur + npay PICTURE "9,999,999.99"      // //ncredit
            nl += 2
            @ nl, 0 SAY "       Payable/Refunded           # 15"
            @ nl, 40 SAY ( mgsttot + ncalc ) - ( mgstpur + npay ) PICTURE "9,999,999.99"
            IF ( mgsttot + ncalc ) - ( mgstpur + npay ) < 0
                @ nl, 56 SAY "Refund"
            ELSE
                @ nl, 56 SAY "Payable"
            ENDIF
            nl += 2
            @ nl, 5 SAY "Bank Opening Balance ="
            @ nl, 30 SAY nbnkopen PICTURE "9,999,999.99"
            nl++
            @ nl, 5 SAY "      Total Deposits ="
            @ nl, 30 SAY mdeptot PICTURE "9,999,999.99"
            nl++
            @ nl, 29 SAY "-------------"
            nl++
            @ nl, 30 SAY nbnkopen + mdeptot PICTURE "9,999,999.99"
            nl++
            @ nl, 5 SAY "        Total Debits ="
            @ nl, 30 SAY mpurtot PICTURE "9,999,999.99"
            nl++
            @ nl, 29 SAY "============="
            nl++
            @ nl, 5 SAY "     Closing Balance ="
            @ nl, 30 SAY ( nbnkopen + mdeptot ) -mpurtot PICTURE "9,999,999.99"
            nl++
            @ nl, 29 SAY "-------------"
            nl += 2
            @ nl, 5 SAY "Sale Code " + SubStr( Message->Saleno5, 1, 2 )
            @ nl, 20 SAY "Pay Code " + Message->Saleno4
            nl += 2
            @ nl, 5 SAY Control->U_Name
            @ nl, 50 SAY Control->U_Gstno
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
        CASE nselect == 2   // Payments

            // **   mstmm:= mendmm:= SUBSTR(DTOS(DATE()),5,2)
            // **   mstyy:= mendyy:= SUBSTR(DTOS(DATE()),1,4)
            Scroll()
            DispBox( 1, 1, 12, 79, 2 )
            @  2, 5 SAY "GOODS AND SERVICE TAX RETURN"
            @  4, 12 SAY "GST Report"
            @  6, 12 SAY "Include From Month"  GET mstmm   PICTURE "99"
            @  6, Col() + 2 SAY "Year "          GET mstyy   PICTURE "9999"
            @  8, 12 SAY "          To Month"  GET mendmm  PICTURE "99"
            @  8, Col() + 2 SAY "Year "          GET mendyy  PICTURE "9999"
            READ
            mst     := mstyy + mstmm
            mend    := mendyy + mendmm
            mamount := mgstot := 0
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
            @  2, 0 SAY "Payments Listing  ";
                + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
            nl := 4
            mcodeno := Space( 8 )
            cname   := Space( 30 )
            mrecno  := "Y"
            ctot := "Y"
            SELECT Pay
            GOTO TOP
            mamount := mgsttot := mcodeamnt := mgstamnt := mgstpur := mpurtot := 0
            ncashno := 0
            DO WHILE Pay->( !Eof() )
                IF SubStr( DToS( Pay->Cheqdate ), 1, 6 ) < mst
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF mrecon == "Y"
                    IF Pay->Recon != "P"
                        SKIP ALIAS Pay
                        LOOP
                    ENDIF
                ENDIF                      // mok
                IF SubStr( DToS( Pay->Cheqdate ), 1, 6 ) > mend
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
                        @  2, 0 SAY "Payment Listing  ";
                            + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
                        nl := 4
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                mcodeno := Pay->Codeno
                IF mcodeno != Space( 8 )
                    SELECT Name
                    SEEK mcodeno
                    cname := Name->Name
                    SELECT Pay
                ELSE
                    cname := Space( 30 )
                ENDIF
                @ nl, 0 SAY Pay->Cheqno
                @ nl, 8 SAY Pay->Cheqdate
                @ nl, 21 SAY SubStr( cname, 1, 25 )
                @ nl, 48 SAY Pay->Amount PICTURE "999,999.99"
                IF Pay->Gstamnt > 0
                    @ nl, 58 SAY Pay->Gstamnt PICTURE "99,999.99"
                ENDIF
                @ nl, 69 SAY Pay->Cashno + "  " + Pay->Recon
                nl++
                mamount += Pay->Amount
                mgsttot += Pay->GSTamnt
                IF Pay->GSTamnt > 0
                    mgstamnt += Pay->Amount
                ENDIF
                IF Pay->Cashno = Message->Saleno4
                    ncashno += Pay->Amount
                ENDIF
                SELECT Pay
                SKIP ALIAS Pay
            ENDDO
            mpurtot := mamount
            nl++
            @ nl, 28 SAY "Payment Totals"
            @ nl, 45 SAY mamount PICTURE "$9,999,999.99"
            IF mgsttot > 0
                @ nl, 60 SAY mgsttot PICTURE "$9,999,999.99"
            ENDIF
            nl += 2
            @ nl, 28 SAY "G.S.T PURCHASES"
            @ nl, 45 SAY mgstamnt PICTURE "$9,999,999.99"
            nl += 2
            @ nl, 5 SAY "Sale Code " + SubStr( Message->Saleno5, 1, 2 )
            @ nl, 20 SAY "Pay Code " + Message->Saleno4
            @ nl, 35 SAY ncashno PICTURE "$9,999,999.99"
            nl += 2
            @ nl, 5 SAY Control->U_Name
            @ nl, 50 SAY Control->U_Gstno
            nl++
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
        CASE nselect == 3   // Deposit

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
            @  2, 0 SAY "Deposits Listing  ";
                + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
            nl := 4
            mamount := mgstot := mzero := mamntgst := nsale := 0
            SELECT Deposit
            GOTO TOP
            DO WHILE Deposit->( !Eof() )
                IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) < mst
                    SKIP ALIAS Deposit
                    LOOP
                ENDIF
                IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) > mend
                    SKIP ALIAS Deposit
                    LOOP
                ENDIF
                IF nl > npl
                    nl := 2
                    IF mwhere == "P"
                        EJECT
                        @  0, 0 SAY Control->U_Name
                        @  0, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                        @  2, 0 SAY "Deposit Listing  ";
                            + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy
                        nl := 4
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                @ nl, 0 SAY Deposit->Depdate
                @ nl, 14 SAY Deposit->Amount  PICTURE "9,999,999.99"
                IF Deposit->Gstamnt > 0
                    @ nl, 30 SAY Deposit->Gstamnt PICTURE "9,999,999.99"
                ENDIF
                @ nl, 60 SAY Deposit->Saleno
                @ nl, 66 SAY Deposit->Depref
                nl++
                IF Deposit->Gstamnt = 0
                    mzero += Deposit->Amount
                ENDIF
                IF Deposit->Gstamnt > 0
                    mamntgst += Deposit->Amount
                ENDIF
                IF SubStr( Deposit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    nsale += Deposit->Amount
                ENDIF
                mamount += Deposit->Amount
                mgstot  += Deposit->Gstamnt
                SELECT Deposit
                SKIP ALIAS Deposit
            ENDDO
            nl++
            @ nl, 2 SAY "Deposit Total"
            @ nl, 17 SAY mamount  PICTURE "$9,999,999.99"
            nl += 2
            @ nl, 2 SAY "Including GST"
            @ nl, 17 SAY mamntgst PICTURE "$9,999,999.99"
            @ nl, 32 SAY mgstot   PICTURE "$999,999.99"
            @ nl, 46 SAY "Excluding GST"
            @ nl, 60 SAY mzero    PICTURE "$9,999,999.99"
            nl += 2
            @ nl, 6 SAY "Credit Adjust Calc #13"
            npay := nfbtax := ncalc := 0
            SELECT Pay
            SET ORDER TO 1     // Codeno
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
                IF Pay->Cashno = cpaycode
                    nPay += Pay->Amount                  // # 13
                ENDIF
                SKIP ALIAS Pay
            ENDDO
            mpertax := 0
            @ nl, 5 SAY "Zero Rated Supplies #  6"
            @ nl, 34 SAY nsale PICTURE "$9,999,999.99"
            @ nl, 50 SAY "Sale Code " + SubStr( Message->Saleno5, 1, 2 )
            nl++
            @ nl, 5 SAY "Credit Adjust Calc  # 13"
            @ nl, 34 SAY npay  PICTURE "$9,999,999.99"
            SELECT Balance
            SEEK mst                            // Start Month
            nbnkopen := Balance->Amount
            nl++
            @ nl, 5 SAY "Bank Opening Balance ="
            @ nl, 34 SAY nbnkopen PICTURE "$9,999,999.99"
            // *********************
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

        ENDCASE   //
        mcontinue := "N"
    ENDDO      // mcontinue

    RETURN NIL

STATIC FUNCTION GSTStandard()

    mcontinue := mok := ctot := mrecon := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        DispBox( 1, 1, 18, 79, 2 )
        SELECT DepPay
        GOTO TOP
        ApFLock( 3 )
        DO WHILE DepPay->( !Eof() )
            DepPay->Amount := 0
            DELETE
            SKIP ALIAS DepPay
        ENDDO
        UNLOCK
        nfbtax := nbnkopen := ncalc := ncredit := 0
        // **   mstmm:= mendmm:= SUBSTR(DTOS(DATE()),5,2)
        // **   mstyy:= mendyy:= SUBSTR(DTOS(DATE()),1,4)
        csaleno  := SubStr( Message->Saleno5, 1, 2 )
        cpaycode := Message->Saleno4
        @  2, 5 SAY "GOODS AND SERVICE TAX RETURN"
        @  4, 12 SAY "GST Report"
        @  6, 12 SAY "Include From Month"  GET mstmm   PICTURE "99"
        @  6, Col() + 2 SAY "Year "          GET mstyy   PICTURE "9999"
        @  8, 12 SAY "          To Month"  GET mendmm  PICTURE "99"
        @  8, Col() + 2 SAY "Year "          GET mendyy  PICTURE "9999"
        @ 10, 6 SAY "Export Sales #"      GET csaleno PICTURE "!!"
        @ 11, 6 SAY "Credit Adjust Calc #13" GET cpaycode PICTURE "@!"
        READ
        mst     := mstyy + mstmm
        mend    := mendyy + mendmm
        // **      namount := 0
        npay    := 0
        SELECT Pay
        SET ORDER TO 1     // Codeno
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
            IF Pay->Cashno = cpaycode
                nPay += Pay->Amount                  // # 13
            ENDIF
            SKIP ALIAS Pay
        ENDDO
        SELECT Deposit
        GOTO TOP
        DO WHILE Deposit->( !Eof() )
            IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) < mst
                SKIP ALIAS Deposit
                LOOP
            ENDIF
            IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) > mend
                SKIP ALIAS Deposit
                LOOP
            ENDIF
            IF SubStr( Deposit->Saleno, 1, 2 ) = csaleno
                nfbtax += Deposit->Amount
            ENDIF
            SELECT Deposit
            SKIP ALIAS Deposit
        ENDDO
        mpertax := 0
        @ 12, 5 SAY " Zero Rated Supplies #  6"  GET nfbtax  PICTURE "9999999.99"
        @ 12, Col() + 2 SAY "Export Sales " + csaleno
        @ 12, Col() + 2 SAY nfbtax                               PICTURE "9,999,999.99"
        @ 13, 5 SAY " Adjust calculation  #  9 "  GET ncalc   PICTURE "9999999.99"
        @ 14, 5 SAY " Credit Adjust Calc  # 13 "  GET npay    PICTURE "9999999.99"
        READ
        SELECT Balance
        SEEK mst
        nbnkopen := Balance->Amount
        @ 16, 9 SAY "Bank Opening Balance =" GET nbnkopen PICTURE "9999999.99"
        READ
        mrecon := ApGetN( "PRESENTED Cheques ONLY" )
        IF PressedEsc()
            RETURN NIL
        ENDIF
        SELECT Control
        ApRLock( 3 )
        Control->BankOpen := nbnkopen
        UNLOCK
        ctot := ApGetN( "Do You Want Pay/Deposit Details" )
        IF PressedEsc()
            RETURN NIL
        ENDIF
        npl := 56
        mwhere := "S"

        Printsel( mwhere, npl )

        nl      := 1

        mcodeno := Space( 8 )
        cname   := Space( 30 )
        SELECT Pay
        GOTO TOP
        mamount := mgsttot := mcodeamnt := mgstamnt := mgstpur := mpurtot := 0
        IF ctot == "Y"
            GstHead()                          // Below
        ENDIF
        DO WHILE Pay->( !Eof() )
            IF SubStr( DToS( Pay->Cheqdate ), 1, 6 ) < mst
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF mrecon == "Y"
                IF Pay->Recon != "P"
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
            ENDIF                      // mok
            IF SubStr( DToS( Pay->Cheqdate ), 1, 6 ) > mend
                EXIT
            ENDIF
            IF nl > npl
                nl := 2
                IF mwhere == "P"
                    EJECT
                    IF ctot == "Y"
                        GstHead()                   // Below
                    ENDIF
                ELSE
                    WAIT
                    Scroll()
                ENDIF
            ENDIF
            mcodeno := Pay->Codeno
            IF mcodeno != Space( 8 )
                SELECT Name
                SEEK mcodeno
                cname := Name->Name
                SELECT Pay
            ELSE
                cname := Space( 30 )
            ENDIF
            ApRLock( 3 )
            mamount := Pay->Amount + mamount
            mgsttot := Pay->Gstamnt + mgsttot
            IF Gstamnt > 0
                mgstamnt := Pay->Amount + mgstamnt
            ENDIF
            UNLOCK
            IF ctot == "Y"
                @ nl, 0 SAY Pay->Cheqno
                @ nl, 8 SAY Pay->Cheqdate
                @ nl, 21 SAY SubStr( cname, 1, 25 )
                @ nl, 48 SAY Pay->Amount PICTURE "999,999.99"
                IF Gstamnt > 0
                    @ nl, 58 SAY Pay->Gstamnt PICTURE "99,999.99"
                ENDIF
                @ nl, 69 SAY Pay->Cashno + "  " + Pay->Recon
                nl++
            ENDIF
            SELECT DepPay
            ApFLock( 3 )
            APPEND BLANK
            DepPay->DPDate  := Pay->CheqDate
            DepPay->Codeno  := Pay->Codeno
            DepPay->Amount  := Pay->Amount
            DepPay->GstAmnt := Pay->GstAmnt
            DepPay->Cashno  := Pay->Cashno
            DepPay->Cheqno  := Pay->Cheqno
            DepPay->Stat    := Pay->Recon
            UNLOCK
            SELECT Pay
            SKIP ALIAS Pay
        ENDDO
        mpurtot := mamount
        IF ctot == "Y"
            nl++
            @ nl, 41 SAY "TOTALS"
            @ nl, 49 SAY mamount PICTURE "9,999,999.99"
            IF mgsttot > 0
                @ nl, 61 SAY mgsttot PICTURE "9,999,999.99"
            ENDIF
            nl += 2
            @ nl, 34 SAY "G.S.T PURCHASES"
            @ nl, 61 SAY mgstamnt PICTURE "$9,999,999.99"
            nl += 2
        ENDIF
        mgstpur := mgsttot
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
        IF ctot == "Y"
            @ nl, 0 SAY "DEPOSIT LIST"
            nl += 2
            @ nl, 0 SAY "DATE                 SALES          GST           OTHERS    SA    REFERENCE"
            nl += 2
        ENDIF
        mstot := mutot := mgstot := mgutot := mgsttot := mggsttot := mamount := 0
        mmsamount := mmuamount := mamount := mgsttot := mdeptot := 0
        SELECT Deposit
        GOTO TOP
        DO WHILE Deposit->( !Eof() )
            IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) < mst
                SKIP ALIAS Deposit
                LOOP
            ENDIF
            IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) > mend
                EXIT
            ENDIF
            IF nl > npl
                nl := 2
                IF mwhere == "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
            ENDIF
            IF ctot == "Y"
                @ nl, 0 SAY Deposit->Depdate
            ENDIF
            IF Deposit->GstAmnt > 0
                IF ctot == "Y"
                    @ nl, 14 SAY Deposit->Amount  PICTURE "9,999,999.99"
                    @ nl, 30 SAY Deposit->Gstamnt PICTURE "9,999,999.99"
                ENDIF
                mgstot  := Deposit->Amount + mgstot
                mgsttot := Deposit->Gstamnt + mgsttot
            ELSE
                IF ctot == "Y"
                    @ nl, 44 SAY Deposit->Amount PICTURE "9,999,999.99"
                ENDIF
                mgutot := Deposit->Amount + mgutot
            ENDIF
            IF ctot == "Y"
                @ nl, 60 SAY Deposit->Saleno
                @ nl, 66 SAY Deposit->Depref
                nl++
            ENDIF
            SELECT DepPay
            ApFLock( 3 )
            APPEND BLANK
            DepPay->DPDate  := Deposit->DepDate
            DepPay->Amount  := Deposit->Amount
            DepPay->GstAmnt := Deposit->GstAmnt
            DepPay->Saleno  := Deposit->Saleno
            DepPay->Depref  := Deposit->Depref
            UNLOCK
            SELECT Deposit
            SKIP ALIAS Deposit
        ENDDO
        mdeptot := mgstot + mgutot
        IF ctot == "Y"
            nl++
            @ nl, 0 SAY "INCLUDING GST"
            @ nl, 14 SAY mgstot  PICTURE "9,999,999.99"
            @ nl, 30 SAY mgsttot PICTURE "9,999,999.99"
            @ nl, 44 SAY mgutot  PICTURE "9,999,999.99"
            // **         nl+=2
            // **         @ nl, 0 SAY "EXCLUDING GST"
            // **         @ nl,14 SAY mgstot-mgsttot PICTURE "9,999,999.99"
            // **         @ nl,36 SAY "TOTAL DEPOSITS"
            // **         @ nl,56 SAY  mgstot+mgutot PICTURE "$9,999,999.99"
            nl += 2
        ENDIF
        IF mwhere == "S"
            nl := 0
            IF ctot == "Y"
                WAIT
                Scroll()
                nl++
            ENDIF
        ENDIF
        @ nl, 0 SAY "GOODS AND SERVICE TAX RETURN";
            + " From " + mstmm + "/" + mstyy + "  To " + mendmm + "/" + mendyy
        nl += 2
        @ nl, 0 SAY "Total Sales & Income for period.  #  5"
        @ nl, 40 SAY mgstot + nfbtax PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "Zero-rated supplies included in 5 #  6"
        @ nl, 40 SAY nfbtax PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "Subtract box 6 from Box 5         #  7"
        @ nl, 40 SAY mgstot PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "Box 7 Times 3 Divide by 23        #  8"
        mgsttot := ( mgstot * 3 ) / 23
        @ nl, 40 SAY mgsttot PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "Adjust from calculation sheet     #  9"
        @ nl, 40 SAY ncalc PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "Add #8 & #9 Total GST Collected.  # 10"
        @ nl, 40 SAY mgsttot + ncalc PICTURE "9,999,999.99"
        nl += 2
        @ nl, 0 SAY "       Total Purchases/Expenses   # 11"
        @ nl, 40 SAY mgstamnt PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "Box 11 Times 3 Divide by 23       # 12"
        mgstpur := ( mgstamnt * 3 ) / 23
        @ nl, 40 SAY mgstpur PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "Credit adjustment from Calc       # 13"
        @ nl, 40 SAY npay PICTURE "9,999,999.99"
        nl++
        @ nl, 0 SAY "        Total GST Credit          # 14"
        @ nl, 40 SAY mgstpur + npay PICTURE "9,999,999.99"      // //ncredit
        nl += 2
        @ nl, 0 SAY "       Payable/Refunded           # 15"
        @ nl, 40 SAY ( mgsttot + ncalc ) - ( mgstpur + npay ) PICTURE "9,999,999.99"
        IF ( mgsttot + ncalc ) - ( mgstpur + npay ) < 0
            @ nl, 56 SAY "Refund"
        ELSE
            @ nl, 56 SAY "Payable"
        ENDIF
        nl += 2
        @ nl, 5 SAY "Bank Opening Balance ="
        @ nl, 30 SAY nbnkopen PICTURE "9,999,999.99"
        nl++
        @ nl, 5 SAY "      Total Deposits ="
        @ nl, 30 SAY mdeptot PICTURE "9,999,999.99"
        nl++
        @ nl, 29 SAY "-------------"
        nl++
        @ nl, 30 SAY nbnkopen + mdeptot PICTURE "9,999,999.99"
        nl++
        @ nl, 5 SAY "        Total Debits ="
        @ nl, 30 SAY mpurtot PICTURE "9,999,999.99"
        nl++
        @ nl, 29 SAY "============="
        nl++
        @ nl, 5 SAY "     Closing Balance ="
        @ nl, 30 SAY ( nbnkopen + mdeptot ) -mpurtot PICTURE "9,999,999.99"
        nl++
        @ nl, 29 SAY "-------------"
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
        ENDIF
        Scroll( 16, 0, 28, 80 )
        mok := ApGetN( "Do you want Bank Reconciliation" )
        IF mok == "Y"
            SET DELETE ON

            PayDepRC()

        ENDIF                        // mok
        SELECT DepPay
        GOTO TOP
        ApFLock( 3 )
        DO WHILE DepPay->( !Eof() )
            DELETE
            SKIP ALIAS DepPay
        ENDDO
        UNLOCK
        mcontinue := "N"
    ENDDO

    RETURN NIL

// **** End GSTStandard

// *-------------------------------------------------------------------

FUNCTION DepPayPre()

    SELECT DepPay
    GOTO TOP
    ApFLock( 3 )
    DO WHILE DepPay->( !Eof() )
        DepPay->Amount := 0
        DELETE
        SKIP ALIAS DepPay
    ENDDO
    UNLOCK

    mcontinue := mok := ctot := mrecon := "Y"
    DO WHILE mcontinue == "Y"
        nfbtax := nbnkopen := ncalc := ncredit := 0
        mamount := mgsttot := mcodeamnt := mgstamnt := mgstpur := mpurtot := 0
        Scroll()
        Scroll()
        nrecno := anum := 0
        aPart_ := {}
        SELECT Balance
        GOTO TOP
        DO WHILE Balance->( !Eof() )
            dyymm := SubStr( DToS( Balance->DATE ), 1, 6 )
            AAdd( aPart_, dyymm;
                + "  " + Str( Balance->Amount );
                + "  " + Balance->Brief;
                + " " + SubStr( DToS( Balance->DATE ), 1, 4 );
                + "       " + Str( RecNo() ) )
            SKIP ALIAS Balance
        ENDDO                               // Balance EOF()
        DispBox( 0, 1, 24, 36, 2 )
        @  0, 8 SAY " Select Start Month & Year "
        DispBox( 0, 40, 2, 78, 2 )
        @  1, 42 SAY "SELECT START MONTH"
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x > y } )           // < Bottom up
            anum := AChoice( 1, 3, 23, 34, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
        ENDIF
        dstart := SubStr( DToS( Balance->DATE ), 1, 6 )
        IF PressedEsc()
            RETURN NIL
        ENDIF
        DispBox( 4, 38, 14, 78, 2 )
        @  6, 40      SAY "From      " + SubStr( DToS( Balance->DATE ), 5, 2 );
            + "   Year   " + SubStr( DToS( Balance->DATE ), 1, 4 );
            + " " + Balance->Brief
        SELECT Balance
        ApRLock( 3 )
        @  8, 40 SAY "Statement Start Amount" GET Balance->Amount PICTURE "9999999.99"
        READ
        UNLOCK
        nopenamnt := Balance->Amount
        mamount   := Balance->Amount
        mstmm     := SubStr( DToS( Balance->Date ), 5, 2 )
        mstyy     := SubStr( DToS( Balance->Date ), 1, 4 )
        DispBox( 0, 1, 24, 36, 2 )
        nrecno := 0
        aPart_ := {}
        SELECT Balance
        GOTO TOP
        DO WHILE Balance->( !Eof() )
            dyymm := SubStr( DToS( Balance->DATE ), 1, 6 )
            AAdd( aPart_, dyymm;
                + "  " + Str( Balance->Amount );
                + "  " + Balance->Brief;
                + " " + SubStr( DToS( Balance->DATE ), 1, 4 );
                + "       " + Str( RecNo() ) )
            SKIP ALIAS Balance
        ENDDO                               // Balance EOF()
        @  0, 8 SAY " Select End Month & Year "
        DispBox( 0, 40, 2, 78, 2 )
        @  1, 42 SAY "SELECT  END  MONTH "
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x > y } )           // < Bottom up
            anum := AChoice( 1, 3, 23, 34, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
        ENDIF
        dend := SubStr( DToS( Balance->DATE ), 1, 6 )
        IF PressedEsc()
            RETURN NIL
        ENDIF
        @  10, 40      SAY "To  End   " + SubStr( DToS( Balance->DATE ), 5, 2 );
            + "   Year   " + SubStr( DToS( Balance->DATE ), 1, 4 );
            + " " + Balance->Brief
        nl      := 1
        mendmm  := SubStr( DToS( Balance->Date ), 5, 2 )
        mendyy  := SubStr( DToS( Balance->Date ), 1, 4 )
        SELECT Balance
        GOTO TOP
        SEEK Val( dend ) + 1
        nendamnt := Balance->Amount
        SELECT Pay
        GOTO TOP
        SET ORDER TO 2
        SEEK "P"
        DO WHILE Pay->Recon = "P" .AND. Pay->( !Eof() )
            IF Pay->Amount <= 0
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF SubStr( DToS( Pay->Presdate ), 1, 6 ) < dstart
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF SubStr( DToS( Pay->Presdate ), 1, 6 ) > dend
                SKIP ALIAS Pay
                LOOP
            ENDIF
            SELECT DepPay
            ApFLock( 3 )
            APPEND BLANK
            DepPay->DPDate   := Pay->CheqDate
            DepPay->PresDate := Pay->PresDate
            DepPay->Codeno   := Pay->Codeno
            DepPay->Amount   := Pay->Amount
            DepPay->GstAmnt  := Pay->GstAmnt
            DepPay->Cashno   := Pay->Cashno
            DepPay->Cheqno   := Pay->Cheqno
            UNLOCK
            SELECT Pay
            SKIP ALIAS Pay
        ENDDO
        SELECT Pay
        SET ORDER TO 1
        SELECT Deposit
        SET ORDER TO 1
        GOTO TOP
        DO WHILE Deposit->( !Eof() )
            IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) < dstart
                SKIP ALIAS Deposit
                LOOP
            ENDIF
            IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) > dend
                EXIT
            ENDIF
            SELECT DepPay
            ApFLock( 3 )
            APPEND BLANK
            DepPay->DPDate   := Deposit->DepDate
            DepPay->PresDate := Deposit->DepDate
            DepPay->Amount   := Deposit->Amount
            DepPay->GstAmnt  := Deposit->GstAmnt
            DepPay->Saleno   := Deposit->Saleno
            DepPay->Depref   := Deposit->Depref
            UNLOCK
            SELECT Deposit
            SKIP ALIAS Deposit
        ENDDO

        mok := "Y"
        IF mok == "Y"
            SET DELETE ON
            npl := 56
            mwhere := "S"

            Printsel( mwhere, npl )
            IF mwhere = "P"
                npl := 56
            ELSE
                npl := 20
            ENDIF
            Scroll()
            nl := 1
            @ nl, 41 SAY "Opening Balance"
            @ nl, 60 SAY mamount PICTURE "$9,999,999.99"
            IF mamount < 0
                @ nl, 74 SAY "OD"
            ENDIF                       // mamount
            nl++
            ccode := Space( 8 )
            npaytot := mpayamount := 0
            ncheques := ndeposit := 0
            ccheqno := Space( 7 )
            SELECT DepPay
            ApFLock( 3 )
            INDEX ON DToS( Presdate ) + Cheqno TO TempDepP
            SET INDEX TO TempDepP
            UNLOCK
            GOTO TOP
            DO WHILE DepPay->( !Eof() )
                IF DepPay->Amount = 0
                    SKIP ALIAS DepPay
                    LOOP
                ENDIF
                IF ccheqno != DepPay->Cheqno
                    ccheqno := DepPay->Cheqno
                    npaytot := 0
                ENDIF
                IF DepPay->Cheqno != Space( 7 )
                    IF DepPay->Codeno != Space( 8 )
                        SELECT Name
                        SEEK DepPay->Codeno
                        SELECT DepPay
                        IF ccheqno = DepPay->Cheqno
                            npaytot += DepPay->Amount
                        ENDIF
                    ENDIF
                    @ nl, 0 SAY DepPay->PresDate
                    @ nl, 12 SAY DepPay->Cheqno
                    @ nl, 20 SAY SubStr( Name->Name, 1, 18 )
                    @ nl, 41 SAY DepPay->Amount  PICTURE "9999,999.99"
                    @ nl, 64 SAY DepPay->GstAmnt PICTURE "999,999.99"
                    @ nl, 75 SAY DepPay->Cashno
                    mamount    -= DepPay->Amount
                    npayamount := DepPay->Amount
                    ncheques   += DepPay->Amount
                ELSE
                    @ nl, 0 SAY DepPay->DPdate
                    @ nl, 22 SAY DepPay->Depref
                    @ nl, 50 SAY DepPay->Amount  PICTURE "9999,999.99"
                    @ nl, 64 SAY DepPay->GstAmnt PICTURE "999,999.99"
                    @ nl, 75 SAY DepPay->Saleno
                    mamount  += DepPay->Amount
                    ndeposit += DepPay->Amount
                    npaytot := 0
                ENDIF                 // Cheqno SPACE( 7 )

                // ***   @  nl,63 SAY mamount PICTURE "9999999.99"
                IF nl > npl
                    nl := 0
                    IF mwhere == "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                SKIP ALIAS DepPay
                IF npaytot != 0
                    IF ccheqno != DepPay->Cheqno
                        IF npaytot != npayamount
                            @  nl, 53 SAY npaytot PICTURE "999,999.99"
                        ENDIF
                        ccheqno := Space( 7 )
                        npaytot := 0
                    ENDIF
                ENDIF
                nl++
            ENDDO                                   // DepPay
            IF mwhere == "S"
                IF nl > 14
                    WAIT
                    Scroll()
                    nl := 0
                ENDIF
            ENDIF
            nl += 2
            // ** @ nl, 8 SAY "GST"
            // ** @ nl,13 SAY (mgsttot+nfbtax+ncalc) - (mgstpur+ncredit) PICTURE "$9,999,999.99"
            @ nl, 43 SAY "CLOSING BALANCE"
            @ nl, 59 SAY mamount PICTURE "$9,999,999.99"
            IF mamount < 0
                @ nl, 76 SAY "OD"
            ENDIF                       // mamount
            nl += 2
            @ nl, 0 SAY " From " + mstmm + "/" + mstyy + "  To " + mendmm + "/" + mendyy
            nl += 2
            @ nl, 0 SAY "  Opening"
            @ nl, 12 SAY nopenamnt PICTURE "$9,999,999.99"
            nl++
            @ nl, 0 SAY "Deposits ="
            @ nl, 12 SAY ndeposit PICTURE "$9,999,999.99"
            nl++
            @ nl, 12 SAY "-----------------"
            nl++
            @ nl, 12 SAY nopenamnt + ndeposit PICTURE "$9,999,999.99"
            nl++
            @ nl, 0 SAY "Cheques ="
            @ nl, 12 SAY ncheques PICTURE "$9,999,999.99"
            nl++
            @ nl, 12 SAY "-----------------"
            nl++
            @ nl, 0 SAY "  Closing"
            @ nl, 12 SAY ( nopenamnt + ndeposit ) -ncheques PICTURE "$9,999,999.99"
            @ nl, 41 SAY "File End Balance"
            @ nl, 60 SAY nendamnt PICTURE "$9,999,999.99"
            IF nendamnt < 0
                @ nl, 74 SAY "OD"
            ENDIF                       // mamount
            nl++
            IF mwhere == "P"
                EndPrint()
                SET MARGIN TO 0
            ELSE
                nl++
                SELECT Balance
                SEEK Val( dend ) + 1
                IF !Found()
                    ApFlock( 3 )
                    APPEND BLANK
                    @ nl, 10      SAY "Date "  GET Balance->Date
                    @ nl, Col() + 3 SAY "Brief " GET Balance->Brief PICTURE "@!"
                    READ
                    nl++
                    UNLOCK
                ENDIF
                ApRlock( 3 )
                @ nl, 17 SAY DToC( Balance->Date )
                @ nl, 30 SAY "File Record"
                @ nl, 45 GET Balance->Amount
                READ
                UNLOCK
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ENDIF
        ENDIF                        // mok
        SELECT DepPay
        GOTO TOP
        ApFLock( 3 )
        DO WHILE DepPay->( !Eof() )
            DELETE
            SKIP ALIAS DepPay
        ENDDO
        UNLOCK
        mcontinue := "N"
    ENDDO

    RETURN NIL

// **** End DepPayRec

// *-------------------------------------------------------------------

FUNCTION MenuJour( nc, ncl )

    DO WHILE .T.

        nselect  := 0
        nc       := ncl * 2
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( Menu->CH_Jourhd ) ) / 2 );
            SAY RTrim( Menu->CH_Jourhd )
        @  6, nc + 2 PROMPT "                      "
        @  7, nc + 2 PROMPT "1. " + Menu->CH_Jour1
        @  9, nc + 2 PROMPT "2. " + Menu->CH_Jour2
        @ 11, nc + 2 PROMPT "3. " + Menu->CH_Jour3
        @ 13, nc + 2 PROMPT "4. " + Menu->CH_Jour4
        @ 15, nc + 2 PROMPT "5. Financial Total    "
        @ 17, nc + 2 PROMPT "6. Invoiced Basis GST "
        @ 20, nc + 2 PROMPT Menu->CH_Main + "   "
        @ 24, 60 SAY " DT75 "
        nc := ncl
        MENU TO nselect
        DO CASE
        CASE nselect == 8 .OR. PressedEsc()
            EXIT
        CASE nselect == 1
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            GstList()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            mcashno := Space( 4 )
            Cashadd( mcashno )
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            msaleno := Space( 4 )
            Saleadd( msaleno )
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5
            SAVE SCREEN TO holdscrn
            LedgPay()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            nl := 0
            ProfCost( nl )                        // XLF_Prof
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7
            SAVE SCREEN TO holdscrn
            GSTInvoice()                        // Below
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// ****  End of MenuJour

// **-------------------------------------------------------------------------

STATIC FUNCTION GstHead()

    @  0, 0 SAY "GST LISTING";
        + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy;
        + "   " + Trim( Control->U_Name )
    @  0, 68 SAY Date()
    @  2, 0 SAY "NUMBER"
    @  2, 8 SAY "DATE"
    @  2, 21 SAY "NAME"
    @  2, 48 SAY "AMOUNT"
    @  2, 58 SAY "G.S.T"
    // **   @  2,65 SAY "AMNT-GST"
    @  2, 69 SAY "CSH"
    nl := 4

    RETURN NIL

// **--- End GstHead()

// *-------------------------------------------------------------------

STATIC FUNCTION PayDepRC()

    Scroll()
    npl := 56
    mwhere := "S"

    Printsel( mwhere, npl )

    nl := 1
    mamount := Control->BankOpen
    @ nl, 43 SAY "CARRIED FORWARD"
    @ nl, 63 SAY mamount PICTURE "9,999,999.99"
    IF mamount < 0
        @ nl, 76 SAY "OD"
    ENDIF                       // mamount
    nl++
    SELECT DepPay
    ApFLock( 3 )
    INDEX ON DToS( DPDate ) + Cheqno TO TempRecP
    SET INDEX TO TempRecP
    UNLOCK
    GOTO TOP
    npaytot := mpayamount := 0
    ccheqno := Space( 7 )
    DO WHILE DepPay->( !Eof() )
        IF DepPay->Amount = 0
            SKIP ALIAS DepPay
            LOOP
        ENDIF
        IF ccheqno != DepPay->Cheqno
            ccheqno := DepPay->Cheqno
            npaytot := 0
        ENDIF
        IF DepPay->Cheqno != Space( 7 )
            IF DepPay->Codeno != Space( 8 )
                SELECT Name
                SEEK DepPay->Codeno
                SELECT DepPay
                IF ccheqno = DepPay->Cheqno
                    npaytot += DepPay->Amount
                ENDIF
            ENDIF
            @ nl, 0 SAY DepPay->DPDate
            @ nl, 12 SAY DepPay->Cheqno
            @ nl, 20 SAY SubStr( Name->Name, 1, 18 )
            @ nl, 41 SAY DepPay->Amount  PICTURE "9999,999.99"
            @ nl, 64 SAY DepPay->GstAmnt PICTURE "999,999.99"
            @ nl, 75 SAY DepPay->Cashno
            mamount    -= DepPay->Amount
            npayamount := DepPay->Amount
        ELSE
            @ nl, 0 SAY DepPay->DPdate
            @ nl, 22 SAY DepPay->Depref
            @ nl, 50 SAY DepPay->Amount  PICTURE "9999,999.99"
            @ nl, 64 SAY DepPay->GstAmnt PICTURE "999,999.99"
            @ nl, 75 SAY DepPay->Saleno
            mamount += DepPay->Amount
            npaytot := 0
        ENDIF                 // Cheqno SPACE( 7 )
        // ***   @  nl,63 SAY mamount PICTURE "9999999.99"
        IF npaytot != 0
            IF ccheqno != DepPay->Cheqno
                IF npaytot != npayamount
                    @  nl, 55 SAY npaytot PICTURE "999,999.99"
                ENDIF
                ccheqno := Space( 7 )
                npaytot := 0
            ENDIF
        ENDIF
        nl++
        IF nl > npl
            nl := 0
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
        ENDIF
        SKIP ALIAS DepPay
    ENDDO                                   // DepPay
    nl += 2
    @ nl, 8 SAY "GST"
    @ nl, 13 SAY ( mgsttot + nfbtax + ncalc ) - ( mgstpur + ncredit ) PICTURE "$9,999,999.99"
    IF ( mgsttot + nfbtax + ncalc ) - ( mgstpur + ncredit ) < 0
        @ nl, 29 SAY "Refund"
    ELSE
        @ nl, 29 SAY "Payable"
    ENDIF
    @ nl, 43 SAY "CLOSING BALANCE"
    @ nl, 63 SAY mamount PICTURE "9,999,999.99"
    IF mamount < 0
        @ nl, 76 SAY "OD"
    ENDIF                       // mamount
    nl += 2
    @ nl, 0 SAY "GOODS AND SERVICE TAX RETURN";
        + " From " + mstmm + "/" + mstyy + "  To " + mendmm + "/" + mendyy
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
    SELECT DepPay
    GOTO TOP
    ApFLock( 3 )
    DO WHILE !Eof()
        DELETE
        SKIP ALIAS DepPay
    ENDDO
    UNLOCK

    RETURN NIL

// **---------------    End of PayDepRC()

// *******-------------------  END OF FILE XLF_JOUR.PRG
