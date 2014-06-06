// **  JK  08-09-11 15:20:32

/*
   Program.....:                 PAYLEDG.PRG
   Author.......: J Kirby
   Date.........: 11/07/1987
   Function.....: LedgPay, Payleghd
*/


FUNCTION LedgPay()

    Scroll()
    DispBox(  8, 5, 12, 75 )
    @ 10, 10 SAY "Please Wait Indexing Pay File"

    SELECT Pay
    GOTO TOP
    ApFLock( 3 )
    INDEX ON Cashno TO TempInd5
    SET INDEX TO TempInd5
    UNLOCK

    mcontinue := mrepeat := "Y"
    DO WHILE mcontinue == "Y"
        mcodeno := Space( 8 )
        mname   := Space( 30 )
        mcodelst := mcodeind := "N"
        mtrue   := "F"
        mamount := mgsttot := mcodeamnt := mgstamnt := mgstst := mcosttot := myy := 0
        // **   mmamount := 0
        Scroll()
        DispBox( 4, 1, 16, 79, 2 )
        mstm  := Date() -30
        mendm := Date()
        @  6, 15 SAY "Include From" GET mstm  PICTURE "99\99\9999"
        @  8, 15 SAY "To Date     " GET mendm PICTURE "99\99\9999"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        mcash := "XXXX"
        mcbname := "               "
        @ 12, 17 GET mcash PICTURE "@!"
        @ 12, Col() + 2 SAY "Select Cashbook  Blank for All"
        READ
        IF mcash != "    "
            SELECT CashBook
            SEEK mcash
            DO WHILE !Found()

                Cblook( @mcash )                  // XLF_Acc.PRG

            ENDDO                                         // FOUND()
            @ 14, 10 SAY "Cash Book " + CashBook->Cashno
            @ 14, Col() + 2 SAY CashBook->Cbname
            mcash := mcashno := CashBook->Cashno
            mcbname := SubStr( Cashbook->Cbname, 1, 26 )

        ENDIF // mcash
        SELECT Pay
        GOTO TOP
        IF mcash != Space( 4 )
            SELECT CashBook
            SEEK mcash
            IF !Found()
                Cblook( @mcashno )                        // XLF_Acc.PRG
                mcash := mcashno
            ENDIF
        ELSE
            mcashno := Pay->Cashno
            mcodeno := Pay->Codeno
        ENDIF                                // mcashno
        SELECT Cashbook
        GOTO TOP
        SEEK mcashno
        mcbname := SubStr( Cashbook->Cbname, 1, 26 )
        mwhere := "S"
        nl     := 1
        npl    := 65

        Printsel()

        PayLeghd()

        SELECT Pay
        mchyy := mchmm := 0
        DO WHILE Pay->( !Eof() )
            IF mcash != Space( 4 )
                IF Pay->Cashno != mcash
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
            ENDIF
            IF Pay->Cheqdate < mstm
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF Pay->Cheqdate > mendm
                SKIP ALIAS Pay
                LOOP
            ENDIF
            IF nl > npl
                IF mwhere = "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF

                Payleghd()

            ENDIF
            IF Pay->Cashno != mcashno
                nl++
                @ nl, 0 SAY mcashno
                @ nl, 6 SAY mcbname
                @ nl, 34 SAY "Total ="
                @ nl, 40 SAY mcosttot  PICTURE "9999,999.99"
                IF mgstst > 0
                    @ nl, 52 SAY mgstst PICTURE "999,999.99"
                ENDIF
                @ nl, 62 SAY mcodeamnt PICTURE "9999,999.99"
                nl += 2
                mcodeamnt := mcosttot := mgstst := 0
                mcashno := Pay->Cashno
                SELECT Cashbook
                SEEK mcashno
                mcbname := SubStr( Cashbook->Cbname, 1, 28 )
            ENDIF
            SELECT Pay
            mamount   += Pay->Amount
            mgsttot   += Pay->Gstamnt
            mcodeamnt += Pay->Amount
            mcosttot  += ( Pay->Amount - Pay->Gstamnt )
            mgstst    += Pay->Gstamnt
            @ nl, 0 SAY Pay->Cheqno
            @ nl, 8 SAY Pay->Cheqdate
            SELECT Name
            SEEK Pay->Codeno
            @ nl, 20 SAY SubStr( Name->Name, 1, 18 )
            SELECT Pay
            @ nl, 40 SAY ( Pay->Amount - Pay->Gstamnt ) PICTURE "9999,999.99"
            IF Pay->Gstamnt > 0
                @ nl, 52 SAY Pay->Gstamnt PICTURE "999,999.99"
                mgstamnt += Pay->Amount
            ENDIF
            @ nl, 62 SAY Pay->Amount PICTURE "9999,999.99"
            nl++
            SKIP ALIAS Pay
        ENDDO
        IF mwhere = "S"
            IF nl > 20
                @ 23, 10 SAY Message->Anykey
                Inkey( 0 )
                Scroll()
                nl := 10
            ENDIF
        ENDIF
        nl++
        @ nl, 0 SAY mcashno
        @ nl, 6 SAY mcbname
        // **  nl = nl+1
        @ nl, 34 SAY "Total ="
        @ nl, 40 SAY mcosttot  PICTURE "9999,999.99"
        IF mgstst > 0
            @ nl, 52 SAY mgstst PICTURE "999,999.99"
        ENDIF
        @ nl, 62 SAY mcodeamnt PICTURE "9999,999.99"
        nl += 2
        @ nl, 37 SAY "---------------------------------------------------"
        nl++
        @ nl, 21 SAY "Grand Total ="
        @ nl, 36 SAY ( mamount - mgsttot ) PICTURE "9,999,999.99"
        IF mgsttot > 0
            @ nl, 50 SAY mgsttot PICTURE "999,999.99"
        ENDIF
        @ nl, 61 SAY mamount PICTURE "9,999,999.99"
        nl++
        @ nl, 37 SAY "===================================================="
        nl += 2
        @ nl, 21 SAY "G.S.T Total ="
        @ nl, 48 SAY mgstamnt PICTURE "9,999,999.99"
        nl++
        IF mwhere == "P"
            EndPrint()
            SET MARGIN TO 0
        ELSE
            IF nl > 17
                WAIT
            ENDIF
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ENDIF
        mcontinue := "N"
    ENDDO

    SELECT Pay
    SET INDEX TO PayInd

    RETURN NIL

// ***** End of Payledge

// *---------------------------------------------------------------------*

FUNCTION Payleghd()

    Scroll()
    @  1, 0 SAY "Cheque List by Cashbook #  " + Control->U_Name
    @  1, 65 SAY Date()
    @  3, 0 SAY "Cheq No"
    @  3, 10 SAY "Date"
    @  3, 20 SAY "Name"
    @  3, 45 SAY "Amount"
    @  3, 57 SAY "G.S.T"
    @  3, 67 SAY "Cheque"
    nl := 5

    RETURN NIL
// ********-------------------  END OF FILE PAYLEDG.PRG
