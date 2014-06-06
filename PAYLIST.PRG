// * JK  08-09-11 15:21:20

/*
   Program......:                    PAYLIST.PRG
   Author.......: J Kirby
   Date.........: 12/04/1985
   Called By....: XLF_Cred
   Function.....: ListPay, Payhead
*/

FUNCTION ListPay()

    mcontinue := mrepeat := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        nl  := 1
        DispBox(  0, 5,  2, 75, 2 )
        @  1, 12 SAY Control->U_Name + "  Payment Listing "
        DispBox(  3, 5, 17, 75, 2 )
        mok := "D"
        @  6, 15 SAY "List By Date or Cheque Number (D/C) :";
            GET mok PICTURE "@!" VALID( mok $ "DC" )
        READ
        IF mok = "C"
            SELECT Pay
            GOTO TOP
            ApFLock( 3 )
            INDEX ON Cheqno TO TempInd2
            SET INDEX TO TempInd2
            UNLOCK
        ELSE
            SELECT Pay
        ENDIF
        GOTO TOP
        mcodeno   := Space( 8 )
        mcheqdate := Date()
        mcodelst  := mcodeind := "N"
        mtrue     := "T"
        mamount := mgsttot := mcodeamnt := mgstamnt := 0
        mselect   := "A"
        myy       := Year( Date() )
        // **   myy       := SUBSTR(DTOC(DATE()),7,4)
        @  8, 19 SAY "All Cheques or Month only (A/M) :";
            GET mselect PICTURE "@!" VALID( mselect $ "AM" )
        @ 10, 15 SAY "Select A if Cheques by one Name Required"
        READ
        DO CASE
        CASE mselect ==  "A"
            @ 12, 15 SAY "Year =" GET myy PICTURE "9999"
            @ 12, Col() + 3 SAY "9999 for All - Must be Account YEAR"
            READ
            mcodelst := ApGetN( "Do You Want List By Name :" )
            mwhere   := "S"
            npl      := 54
            IF mcodelst == "Y"
                IF mrepeat == "Y"
                    mrepeat := "N"
                ENDIF

                SELECT Pay
                GOTO TOP
                ApFLock( 3 )
                INDEX ON Codeno TO TempInd3                // Index by Name Codeno
                SET INDEX TO TempInd3
                UNLOCK
                mcodeind := ApGetN( "One Customer Name Only :" )
            ELSE
                SELECT Pay
            ENDIF
            IF mcodeind == "Y"                           // Looking for Name

                Namerank()

                mcodeno := Name->Codeno
            ENDIF
            // **         mvalyy := VAL( myy )
            mok := "N"
            mok := ApGetN( "One Cashcode Only" )
            IF mok == "Y"
                mcashno := Space( 4 )
                @ 14, 15 SAY "Cash Book " GET mcashno PICTURE "@!"
                READ
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                SELECT Cashbook
                SEEK mcashno
                DO WHILE !Found()

                    Cblook( @mcashno )                        // XLF_Cred.PRG

                ENDDO
                mcashno :=  CashBook->Cashno
            ENDIF                                          // mok

            Printsel()                                   // _LF_Init

            IF mwhere == "P"
                @  0, 0
                SET PRINTER TO
                SET DEVICE TO PRINT
            ELSE
                Scroll()
            ENDIF
            SELECT Pay
            mfirst := "T"
            IF mcodeind == "Y"
                SEEK mcodeno
            ENDIF

            PayHead()

            DO WHILE Pay->( !Eof() )
                IF mok == "Y"
                    IF Pay->Cashno != mcashno
                        SKIP
                        LOOP
                    ENDIF
                ENDIF
                IF mcodeind == "Y"
                    IF Pay->Codeno != mcodeno
                        EXIT
                    ENDIF
                ENDIF
                DO CASE
                CASE  myy > Year( Date() ) + 100
                CASE Year( Pay->Cheqdate ) < myy
                    SKIP ALIAS Pay
                    LOOP
                CASE Year( Pay->Cheqdate ) > myy + 1
                    SKIP ALIAS Pay
                    LOOP
                CASE Year( Pay->Cheqdate ) > myy
                    IF Month( Cheqdate ) > 03
                        SKIP ALIAS Pay
                        LOOP
                    ENDIF
                CASE Month( Pay->Cheqdate ) < 04
                    SKIP ALIAS Pay
                    LOOP
                ENDCASE
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF

                    Payhead()                // Below

                ENDIF
                IF mcodeind == "Y"
                    mcodelst := "N"
                ENDIF
                mcodeno := Pay->Codeno
                mtrue := "T"
                IF mcodelst == "Y"
                    mtrue := "F"
                    IF Pay->Codeno != mcodeno
                        mcodeno := Pay->Codeno
                        mtrue   := "T"
                    ENDIF
                    IF mtrue == "T"
                        IF mfirst == "F"
                            nl++
                            @ nl, 31 SAY "Code # Total = "
                            @ nl, Col() + 2 SAY mcodeamnt PICTURE "$9,999,999.99"
                            nl += 2
                            mcodeamnt := 0
                        ENDIF
                    ENDIF
                ENDIF
                SELECT Name
                SEEK mcodeno
                SELECT Pay
                mcheqdate := Pay->Cheqdate
                mamount   := Pay->Amount + mamount
                mgsttot   := Pay->Gstamnt + mgsttot
                mcodeamnt := Pay->Amount + mcodeamnt
                IF mcodeind == "Y"
                    IF mfirst != "F"
                        mtrue := "T"
                        nl := 6
                    ENDIF
                ENDIF
                @ nl, 0 SAY Pay->Cheqno
                @ nl, 8 SAY Pay->Recon
                @ nl, 10 SAY mcheqdate
                @ nl, 21 SAY Pay->Invno
                @ nl, 32 SAY SubStr( Name->Name, 1, 21 )
                mfirst := "F"
                // **           nl++
                @ nl, 54 SAY Pay->Amount PICTURE "999,999.99"
                IF Gstamnt > 0
                    @ nl, 64 SAY Pay->Gstamnt PICTURE "99,999.99"
                    mgstamnt := Pay->Amount + mgstamnt
                ENDIF
                // **           @ nl,58 SAY ( Pay->Amount-Pay->Gstamnt ) PICTURE "9,999,999.99"
                @ nl, 74 SAY Pay->Cashno
                nl++
                SKIP ALIAS Pay
            ENDDO

        CASE mselect = "M"              // MONTH SELECTED
            @ 14, 15 SAY "Please Provide Month & Year You are interested in"
            mmm := SubStr( DToC( Date() ), 4, 2 )
            @ 16, 15 SAY "Select Month :" GET mmm PICTURE "99"

            myy := Year( Date() )
            @ 16, Col() + 2 SAY "Year :" GET myy PICTURE "9999"
            READ

            Printsel()                    // _LF_Init

            IF mwhere = "P"
                SET DEVICE TO PRINT
            ENDIF
            SELECT Pay
            GOTO TOP
            DO WHILE !Eof()
                IF SubStr( DToC( Pay->Cheqdate ), 4, 2 ) != mmm
                    SKIP ALIAS Pay
                    LOOP
                ENDIF
                IF Year( Pay->Cheqdate ) != myy
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

                    Payhead()                       // Below

                ENDIF
                mcodeno := Pay->Codeno
                IF mcodeno != Space( 8 )
                    SELECT Name
                    SEEK mcodeno
                    mname := SubStr( Name->Name, 1, 19 )
                    SELECT Pay
                ELSE
                    mname := Space( 19 )
                ENDIF
                mamount  := Pay->Amount  + mamount
                mgsttot  := Pay->Gstamnt + mgsttot
                @ nl, 0 SAY Pay->Cheqno
                @ nl, 8 SAY Pay->Recon
                @ nl, 10 SAY Pay->Cheqdate
                @ nl, 21 SAY Pay->Invno
                @ nl, 32 SAY mname
                @ nl, 52 SAY Pay->Amount PICTURE "999,999.99"
                IF Pay->Gstamnt > 0
                    @ nl, 64 SAY Pay->Gstamnt PICTURE "99,999.99"
                    mgstamnt := Pay->Amount + mgstamnt
                ENDIF
                // **         @ nl,58 SAY (Pay->Amount-Pay->Gstamnt) PICTURE "9,999,999.99"
                @ nl, 74 SAY Pay->Cashno
                nl++
                SKIP ALIAS Pay
            ENDDO
        ENDCASE
        IF mcodelst == "Y"
            IF mcodeamnt > 0
                nl++
                @ nl, 20 SAY "Code # Total ="
                @ nl, Col() + 2 SAY mcodeamnt PICTURE "$9,999,999.99"
                nl += 2
            ENDIF
        ENDIF
        nl++
        @ nl, 0 SAY "TOTALS"
        @ nl, 25 SAY mamount PICTURE "$9,999,999.99"
        IF mgsttot > 0
            @ nl, 40 SAY "GST"
            @ nl, 44 SAY mgsttot PICTURE "$999,999.99"
        ENDIF
        @ nl, 60 SAY ( mamount - mgsttot ) PICTURE "9,999,999.99"
        nl += 2
        @ nl, 0 SAY "G.S.T PURCHASES"
        @ nl, 16 SAY mgstamnt PICTURE "$9,999,999.99"
        nl++
        @ nl, 0 SAY " "
        IF mwhere == "P"
            EndPrint()
            SET MARGIN TO 0
        ELSE
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ENDIF
        Scroll()
        mcontinue := ApGetN( Trim( Message->Another ) + " Payment List" )
    ENDDO
    SELECT Pay
    SET INDEX TO PayInd

    RETURN NIL

// *******   End of file Paylist

// *-------------------------------------------------------------------

FUNCTION Payhead()

    @  0, 0 SAY Control->U_Name
    @  2, 0 SAY "CHEQUE LIST  " + Str( myy )
    @  2, 62 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  4, 0 SAY "CHEQUE"
    @  4, 11 SAY "DATE"
    @  4, 22 SAY "INVNO"
    @  4, 32 SAY "NAME"
    @  4, 57 SAY "AMOUNT"
    @  4, 68 SAY "G.S.T"
    @  4, 75 SAY "CSH"
    nl := 6

    RETURN NIL
// **---- End PayHead()

// *****-------------------  END OF FILE PAYLIST.PRG
