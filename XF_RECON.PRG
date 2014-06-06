// ** JK 07-07-11 15:20:41

/*
   Program.....:                  XF_RECON.PRG
   Authors.....: J.Kirby
   Date........: 24/07/1999
   Functions...: MenuReco, BalView
   Static funcs: CheqView, CheqHead, ReconView
*/

FUNCTION MenuReco( nc, ncl )

    DO WHILE .T.

        cheading := "ACCOUNT RECON"
        nselect  := 0
        nc       := ncl * 2
        Scroll( 3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( cheading ) ) / 2 );
            SAY RTrim( cheading )
        @  7, nc + 2 PROMPT "1. Statement    View "
        @  9, nc + 2 PROMPT "2. Statement    Recon"
        @ 11, nc + 2 PROMPT "3. Add         Cheque"
        @ 12, nc + 2 PROMPT "4. Edit        Cheque"
        @ 13, nc + 2 PROMPT "5. Edit     Presented"
        @ 14, nc + 2 PROMPT "6. List       Cheques"
        @ 16, nc + 2 PROMPT "7. Add        Deposit"
        @ 17, nc + 2 PROMPT "8. Edit       Deposit"
        @ 19, nc + 2 PROMPT "9. Edit  Bank Balance"
        @ 20, nc + 2 PROMPT Menu->CH_Main
        @ 24, 60 SAY "DT76 "
        nc := ncl
        MENU TO nselect

        DO CASE
        CASE nselect == 10 .OR. PressedEsc()
            EXIT
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            ReconView()                           // Below
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            DepPayPre()                  // XLF_Jour
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            CredPay()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            ViewPay()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5
            SAVE SCREEN TO holdscrn
            ViewPres()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            CheqView()                               // BELOW
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7
            SAVE SCREEN TO holdscrn
            Depadd()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 8
            SAVE SCREEN TO holdscrn
            Depview()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 9
            SAVE SCREEN TO holdscrn
            Balview()
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// **** End of MenuReco()

// *-------------------------------------------------------------------

FUNCTION BalView()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"

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
        @  0, 8 SAY " Select Month & Year "
        DispBox( 0, 40, 2, 79, 2 )
        @  1, 42 SAY "Opening Monthly Balance"
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x > y } )           // < Bottom up
            anum := AChoice( 1, 3, 23, 34, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
        ENDIF
        dyymm := SubStr( DToS( Balance->DATE ), 1, 6 )
        IF PressedEsc()
            RETURN NIL
        ENDIF
        crecon := "Y"
        DispBox( 7, 38, 16, 78, 2 )
        @  8, 40 SAY dyymm + "  " + Str( Balance->Amount );
            + "  " + Balance->Brief + " " + SubStr( DToS( Balance->DATE ), 1, 4 )
        ApFLock( 3 )
        @ 10, 40 SAY "Balance DATE" GET Balance->Date
        @ 11, 40 SAY "      Amount" GET Balance->Amount PICTURE "99999999.99"
        @ 12, 61 SAY "0 to Delete"
        @ 14, 40 SAY "Month Brief " GET Balance->Brief  PICTURE "@!"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        IF Balance->Amount = 0
            DELETE ALL FOR Balance->Amount = 0
        ENDIF
        UNLOCK
        manother := ApGetN( "Add New Monthly Balance" )
        DO WHILE manother = "Y"
            Scroll(  18,  0, 24, 80 )
            DispBox( 18, 1, 23, 78, 2 )
            ApFLock( 3 )
            APPEND BLANK
            Balance->Amount := 1
            @ 19, 20 SAY "Balance DATE" GET Balance->Date
            @ 20, 20 SAY "      Amount" GET Balance->Amount PICTURE "99999999.99"
            @ 21, 20 SAY "Month  Brief" GET Balance->Brief  PICTURE "@!"
            READ
            IF Balance->Amount = 0
                DELETE
            ENDIF
            UNLOCK
            manother := "N"
        ENDDO                        // manother
        mcontinue := "Y"
        LOOP
    ENDDO                           // mcontinue

    RETURN NIL
// ***------- End of BalView()

// *-------------------------------------------------------------------

STATIC FUNCTION CheqView()

    mcontinue := mok := ctot := mrecon := "Y"
    DO WHILE mcontinue == "Y"
        nfbtax := nbnkopen := ncalc := ncredit := 0
        Scroll()
        DispBox( 3, 1, 12, 79, 2 )
        @  4, 15 SAY "Listing of Cheques and Deposits"
        mstmm := mendmm := SubStr( DToS( Date() ), 5, 2 )
        mstyy := mendyy := SubStr( DToS( Date() ), 1, 4 )
        @  6, 15      SAY "Include From Month" GET mstmm   PICTURE "99"
        @  6, Col() + 2 SAY "Year"               GET mstyy   PICTURE "9999"
        @  8, 24      SAY "To Month "          GET mendmm  PICTURE "99"
        @  8, Col() + 2 SAY "Year"               GET mendyy  PICTURE "9999"
        @ 10, 15 SAY "Esc to Exit"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        mrecon := ApGetN( "PRESENTED Cheques ONLY" )
        npl := 56
        mwhere := "S"

        Printsel( mwhere, npl )
        nl      := 1
        mst     := mstyy + mstmm
        mend    := mendyy + mendmm
        mcodeno := Space( 8 )
        cname   := Space( 30 )
        SELECT Pay
        GOTO TOP
        mamount := mgsttot := mcodeamnt := mgstamnt := mgstpur := mpurtot := 0

        CheqHead()                          // Below

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

                    CheqHead()                   // Below

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
                cname := Name->Name
                UNLOCK
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
            // **         IF ctot == "Y"
            @ nl, 0 SAY Pay->Cheqno
            @ nl, 8 SAY Pay->Cheqdate
            @ nl, 21 SAY SubStr( cname, 1, 25 )
            @ nl, 48 SAY Pay->Amount PICTURE "999,999.99"
            IF Gstamnt > 0
                @ nl, 58 SAY Pay->Gstamnt PICTURE "99,999.99"
            ENDIF
            // ****            @ nl,60 SAY (Amount-Gstamnt) PICTURE "9,999,999.99"
            @ nl, 69 SAY Pay->Cashno + " " + Pay->Recon
            nl++
            // **         ENDIF
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
            // ****         @ nl,60 SAY (mamount-mgsttot) PICTURE "9,999,999.99"
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
            SKIP ALIAS Deposit
        ENDDO
        mdeptot := mgstot + mgutot
        IF ctot == "Y"
            nl++
            @ nl, 0 SAY "INCLUDING GST"
            @ nl, 14 SAY mgstot  PICTURE "9,999,999.99"
            @ nl, 30 SAY mgsttot PICTURE "9,999,999.99"
            @ nl, 44 SAY mgutot  PICTURE "9,999,999.99"
            nl += 2
            @ nl, 0 SAY "EXCLUDING GST"
            @ nl, 14 SAY mgstot - mgsttot PICTURE "9,999,999.99"
            @ nl, 36 SAY "TOTAL DEPOSITS"
            @ nl, 56 SAY  mgstot + mgutot PICTURE "$9,999,999.99"
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
        IF mwhere == "P"
            EndPrint()
            SET MARGIN TO 0
        ENDIF
        mcontinue := "Y"
    ENDDO

    RETURN NIL

// **** End CheqView

// *-------------------------------------------------------------------

STATIC FUNCTION CheqHead()

    @  0, 0 SAY "GST LISTING";
        + " From " + mstmm + "/" + mstyy + " To " + mendmm + "/" + mendyy;
        + "  " + Trim( Control->U_Name ) + "  " + DToC( Date() )
    @  2, 0 SAY "NUMBER"
    @  2, 8 SAY "DATE Issued"
    @  2, 25 SAY "NAME"
    @  2, 52 SAY "AMOUNT"
    @  2, 61 SAY "G.S.T"
    @  2, 70 SAY "CSH"
    nl := 4

    RETURN NIL
// **--- End CheqHead()

// *-------------------------------------------------------------------

STATIC FUNCTION ReconView()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"

        Scroll()
        mamount := ncheque := ndeposit := 0
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
        @  0, 8 SAY " Select Month & Year "
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x > y } )           // < Bottom up
            anum := AChoice( 1, 3, 23, 34, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
        ENDIF
        dyymm := SubStr( DToS( Balance->DATE ), 1, 6 )
        IF PressedEsc()
            RETURN NIL
        ENDIF
        SELECT Control
        ApRLock( 3 )
        Control->BankOpen := Balance->Amount
        UNLOCK
        mok  := "Y"
        DO WHILE mok == "Y"
            mamount := Control->BankOpen
            SELECT DepPay
            GOTO TOP
            ApFLock( 3 )
            DO WHILE DepPay->( !Eof() )
                DepPay->Amount := 0
                DELETE
                SKIP ALIAS DepPay
            ENDDO
            UNLOCK
            SELECT Pay
            GOTO TOP
            SET ORDER TO 2
            SEEK "P"
            DO WHILE Pay->Recon = "P" .AND. Pay->( !Eof() )
                IF SubStr( DToS( Pay->Presdate ), 1, 6 ) < dyymm
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF SubStr( DToS( Pay->Presdate ), 1, 6 ) > dyymm
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
                DepPay->GSTAmnt  := Pay->GSTAmnt
                DepPay->Cashno   := Pay->Cashno
                DepPay->Cheqno   := Pay->Cheqno
                DepPay->Depref   := DToC( Pay->CheqDate )          // Issued date
                DepPay->Stat     := Pay->Recon
                UNLOCK
                mamount -= Pay->Amount
                ncheque += Pay->Amount
                SELECT Pay
                SKIP ALIAS Pay
            ENDDO
            SELECT Pay
            SET ORDER TO 1
            SELECT Deposit
            SET ORDER TO 1
            GOTO TOP
            DO WHILE Deposit->( !Eof() )
                IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) < dyymm
                    SKIP ALIAS Deposit
                    LOOP
                ENDIF
                IF SubStr( DToS( Deposit->Depdate ), 1, 6 ) > dyymm
                    EXIT
                ENDIF
                SELECT DepPay
                ApFLock( 3 )
                APPEND BLANK
                DepPay->DPDate   := Deposit->DepDate
                DepPay->PresDate := Deposit->DepDate
                DepPay->Amount   := Deposit->Amount
                DepPay->GSTAmnt  := Deposit->GSTAmnt
                DepPay->Saleno   := Deposit->Saleno
                DepPay->Depref   := Deposit->Depref
                UNLOCK
                mamount  += Deposit->Amount
                ndeposit += Deposit->Amount
                SELECT Deposit
                SKIP ALIAS Deposit
            ENDDO
            Scroll()
            aPart_ := {}
            SELECT DepPay
            GOTO TOP
            IF LastRec() = 0
                @ 10, 10 SAY "No Cheques or Deposits This Month"
                Inkey( 2 )
                RETURN NIL
            ELSE
                DO WHILE  DepPay->( !Eof() )
                    AAdd( aPart_, DToC( DepPay->PresDate ) + "  " + DepPay->Cheqno;
                        + "  " + DepPay->Codeno;
                        + "  " + Str( DepPay->Amount );
                        + "  " + DepPay->Cashno;
                        + "  " + DepPay->Saleno + "  " + DepPay->Depref;
                        + "  " + DepPay->Stat )
                    SKIP ALIAS DepPay
                ENDDO                             // EOF
                IF !Empty( aPart_ )
                    DispBox(  0, 1, 18, 79, 2 )
                    @  0, 3 SAY " Presented  "
                    DispBox( 19, 1, 24, 79, 2 )
                    @ 20, 6      SAY "Opening"
                    @ 20, Col() + 1 SAY Control->BankOpen PICTURE "$9,999,999.99"
                    IF Control->BankOpen < 0
                        @ 20, Col() + 2 SAY "OD"
                    ENDIF
                    @ 20, Col() + 4 SAY "Deposit"
                    @ 20, Col() + 1 SAY ndeposit          PICTURE "$9,999,999.99" COLOR "G+"
                    @ 21, 6      SAY "Cheques"
                    @ 21, Col() + 1 SAY ncheque           PICTURE "$9,999,999.99" COLOR "G+"
                    @ 21, Col() + 2 SAY "Close Balance"
                    @ 21, Col() + 1 SAY mamount           PICTURE "$9,999,999.99" COLOR "G+"
                    IF mamount < 0
                        @ 21, Col() + 2 SAY "OD"
                    ENDIF
                    SELECT Pay
                    SET ORDER TO 1
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice( 1, 3, 17, 77, aPart_,, "AFUNC" )
                    nselect := 0
                    DispBox( 22, 1, 24, 79, 2 )
                    @ 23, 6      PROMPT "View"
                    @ 23, Col() + 3 PROMPT "Add Cheque"
                    @ 23, Col() + 2 PROMPT "Edit Cheque"
                    @ 23, Col() + 2 PROMPT "Presented"
                    @ 23, Col() + 3 PROMPT "Add Deposit"
                    @ 23, Col() + 2 PROMPT "Edit Deposit"
                    MENU TO nselect
                    DO CASE
                    CASE PressedEsc()
                        SELECT DepPay
                        GOTO TOP
                        ApFLock( 3 )
                        DO WHILE DepPay->( !Eof() )
                            DELETE
                            SKIP ALIAS DepPay
                        ENDDO
                        RETURN NIL
                    CASE nselect == 1
                        LOOP
                    CASE nselect == 2
                        SAVE SCREEN TO tempscrn
                        CredPay()
                        RESTORE SCREEN FROM tempscrn
                    CASE nselect == 3
                        SAVE SCREEN TO tempscrn
                        ViewPay()
                        RESTORE SCREEN FROM tempscrn
                    CASE nselect == 4
                        SAVE SCREEN TO holdscrn
                        ViewPres()
                        RESTORE SCREEN FROM holdscrn
                    CASE nselect == 5
                        SAVE SCREEN TO tempscrn
                        Depadd()
                        RESTORE SCREEN FROM tempscrn
                    CASE nselect == 6
                        SAVE SCREEN TO tempscrn
                        Depview()
                        RESTORE SCREEN FROM tempscrn
                    ENDCASE
                ENDIF
            ENDIF                    // LastRec Not 0
            mok := "Y"
        ENDDO                             // mok
        mcontinue := "N"
    ENDDO

    RETURN NIL
// ***---- End of ReconView()

// ********--------------  END OF FILE XF_RECON.PRG
