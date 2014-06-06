// ** JK 09-03-11 10:19:25

/*  Program.....:            CHRDEB245.PRG

    Authors.....: J.Kirby
    Date........: 04/08/98
*/

// (c) Copyright 1993 by Chozen Ltd Christchurch.

FUNCTION Deb245()

    mmonthcr  := Month( Date() ) -1
    mrecdate  := Date()
    mdatestat := "30/" + Str( mmonthcr, 2, 0 ) + SubStr( DToC( Date() ), 6, 5 )
    Scroll()
    DispBox( 7, 10, 16, 70, 2 )
    nselect  := 0
    @ 10, 15 PROMPT "1. All Statements  "
    @ 12, 15 PROMPT "2. By Selected Date"
    MENU TO nselect
    DO CASE
    CASE LastKey() == 27
        RETURN
    CASE nselect == 1

        @ 14, 15 SAY "Statements to be dated" GET mdatestat PICTURE "99/99/9999"
        READ
        msaleno := Space( 4 )
        mwhere := "P"

        Printsel( mwhere )                                     // _LP_Init
        IF LastKey() == 27
            RETURN NIL
        ENDIF
        IF mwhere == "P"
            SET DEVICE TO PRINT
        ENDIF                               // mwhere
        SELECT Debit
        GOTO TOP
        DO WHILE Debit->( !Eof() )
            IF Debit->Amount <= 0
                SKIP ALIAS Debit
                LOOP
            ENDIF                                   // msaleno
            IF Month( Debit->Dbdate ) = Month( Date() ) .AND. ;
                    Year( Debit->Dbdate ) = Year(  Date() )
                SKIP ALIAS Debit
                LOOP
            ENDIF
            mcodeno := Debit->Codeno
            // ****************
            M204A4head()                           // ChrDeb24

            DO CASE
            CASE mmonthcr == 0
                mmonth1  := 11
                mmonthcr := 12
            CASE mmonthcr == 1
                mmonth1 := 12
            OTHERWISE
                mmonth1 := mmonthcr - 1
            ENDCASE

            SELECT Rec
            GOTO TOP
            SEEK mcodeno
            mrecamnt := mdebbal := 0
            IF Found()
                DO WHILE ( Rec->Codeno = mcodeno ) .AND. Rec->( !Eof() )
                    IF Year( Rec->RecDate ) != Year( Date() )
                        IF Rec->RecDate < Control->ACC_DATE
                            SKIP ALIAS Rec
                            LOOP
                        ENDIF
                        IF Month( Rec->RecDate ) != 12
                            SKIP ALIAS Rec
                            LOOP
                        ENDIF
                    ENDIF
                    IF Month( Rec->Recdate ) = mmonthcr
                        mrecamnt += Rec->Recamnt
                    ENDIF
                    SKIP ALIAS Rec
                ENDDO                         // Rec
            ENDIF                            // Found
            // ************************
            nl += 4
            IF mrecamnt > 0
                @ nl, 11 SAY "Received with Thanks"
                @ nl, 32 SAY mrecamnt PICTURE "$999,999.99"
                @ nl, 50 SAY "Rec'd"
                @ nl, 57 SAY mrecamnt PICTURE "$999,999.99"
                nl += 2
            ENDIF
            @ nl, 11 SAY "Outstanding Invoices"
            nl += 2
            mpageno = 1
            SELECT Debit
            GOTO TOP
            SEEK mcodeno
            mgtotcr := mgtot1 := mgtot2 := mgtotr := 0
            DO WHILE Debit->Codeno = mcodeno .AND. Debit->( !Eof() )
                IF Debit->Amount = 0
                    SKIP ALIAS Debit
                    LOOP
                ENDIF
                IF Month( Debit->Dbdate ) = Month( Date() ) .AND. ;
                        Year( Debit->Dbdate ) = Year(  Date() )
                    SKIP ALIAS Debit
                    LOOP
                ENDIF
                IF nl > npl
                    mpageno := mpageno + 1
                    IF mwhere == "P"
                        EJECT
                        M204A4head()                             // Below
                        nl += 5
                    ELSE
                        WAIT
                        Scroll()
                        nl := 2
                    ENDIF
                    SELECT Debit
                ENDIF
                DO CASE
                CASE Year(  Debit->Dbdate ) = Year( Date() ) -2
                    mgtot2  += Debit->Amount
                CASE Year(  Debit->Dbdate ) = Year( Date() ) -1;
                        .AND. Month( Debit->DbDate ) < 10
                    mgtot2  += Debit->Amount
                CASE Month( Debit->Dbdate ) == mmonthcr
                    mgtotcr += Debit->Amount
                CASE Month( Debit->Dbdate ) == mmonth1
                    mgtot1  += Debit->Amount
                OTHERWISE
                    mgtot2  += Debit->Amount
                ENDCASE
                @ nl, 3 SAY Debit->Dbdate
                @ nl, 14 SAY "Inv"
                @ nl, 18 SAY Debit->Invno
                @ nl, 26 SAY Debit->BranchId
                @ nl, 31 SAY Debit->Amount PICTURE "999,999.99"
                @ nl, 50 SAY Debit->Invno
                @ nl, 58 SAY Debit->BranchId
                // ***      @ nl,62 SAY SUBSTR( Debit->Ordnum,1,3 )
                @ nl, 63 SAY Debit->Amount PICTURE "999,999.99"
                nl++
                mgtotr += Debit->Amount
                SKIP ALIAS Debit
            ENDDO
            nover := mgtot2 + mgtot1
            IF mwhere = "P"
                nl := 54
            ENDIF
            IF nover > 0
                @ nl, 4 SAY "Overdue Account"
                @ nl, 22 SAY "Current"
                nl++
                @ nl, 4 SAY nover PICTURE "$999,999.99"
                SELECT Name
                ApRLock( 3 )
                Name->OverDue := nover
                UNLOCK
                SELECT Debit
            ELSE
                @ nl, 20 SAY "Current"
                nl++
            ENDIF
            @ nl, 19 SAY mgtotcr PICTURE "$999,999.99"
            @ nl, 30 SAY mgtotr  PICTURE "$999,999.99"
            @ nl, 62 SAY mgtotr  PICTURE "$999,999.99"
            nl += 2
            @ nl, 4 SAY Control->Con_Note4
            nl++
            @ nl, 4 SAY Control->Con_Note5
            nl++
            @ nl, 4 SAY Control->Con_Note6
            SKIP ALIAS Debit
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
                nl += 4
            ENDIF
        ENDDO
        IF mwhere == "P"
            EndPrint()
            SET MARGIN TO 0
        ELSE
            WAIT
        ENDIF

    CASE nselect == 2
        mmonthcr  := Month( Date() ) -1
        mdatestat := Date()
        // *** "31/"+STR(mmonthcr,2,0)+SUBSTR(DTOC(DATE()),6,5)
        mok := "Y"
        DO WHILE mok == "Y"

            Namerank()

            IF LastKey() = 27
                RETURN NIL
            ENDIF
            mcodeno := Name->Codeno
            mcorrect := "N"
            DO WHILE mcorrect == "N"
                Scroll(  3, 0, 24, 80 )
                DispBox( 8, 10, 14, 70, 2 )
                @ 10, 15 SAY "Statement up to :" GET mdatestat PICTURE "99/99/9999"
                READ
                mcorrect := ApGetY( "Sure Date is Correct ?" )
                IF LastKey() == 27
                    RETURN NIL
                ENDIF
            ENDDO                               // mcorrect
            mwhere := "P"

            Printsel( mwhere )                // _LP_Init

            IF mwhere == "P"
                SET DEVICE TO PRINT
            ENDIF                             // mwhere

            DebitSel( @mcodeno )

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
            @  0, 0 SAY Chr( 27 ) + Chr( 67 ) + Chr( 03 )
            mok := ApGetY( Message->Another + " Statement" )
            IF LastKey() == 27
                RETURN NIL
            ENDIF
        ENDDO
    ENDCASE

    RETURN NIL

// *** End of Deb245

// *-------------------------------------------------------------------

FUNCTION DebitSel( mcodeno )

    M245head()                           // Below

    DO CASE
    CASE mmonthcr == 0
        mmonth1  := 11
        mmonthcr := 12
    CASE mmonthcr == 1
        mmonth1 := 12
    OTHERWISE
        mmonth1 := mmonthcr - 1
    ENDCASE

    nl++
    @ nl, 13 SAY "Outstanding Invoices"
    nl += 2
    IF mwhere = "P"
        npl := 38
    ELSE
        npl := 17
    ENDIF
    mpageno = 1
    SELECT Debit
    GOTO TOP
    SEEK mcodeno
    mgtotcr := mgtot1 := mgtot2 := mgtotr := 0
    DO WHILE Debit->Codeno = mcodeno .AND. Debit->( !Eof() )
        IF Debit->Amount = 0
            SKIP ALIAS Debit
            LOOP
        ENDIF
        IF Debit->DbDate > mdatestat
            SKIP ALIAS Debit
            LOOP
        ENDIF
        IF nl > npl
            mpageno := mpageno + 1
            // **        nl++
            // **        @ nl, 4 SAY "Statement is Continued on Next Page"
            IF mwhere == "P"
                // **           EJECT
                @  0, 0 SAY Chr( 27 ) + Chr( 67 ) + Chr( 03 )
                SET DEVICE TO SCREEN
                Scroll( 3, 0, 24, 75 )
                @ 12, 0 SAY "PLEASE ALIGN STATEMENT TO TOP OF PAGE WILL IMPROVE SOON"
                WAIT
                IF mwhere == "P"
                    @  0, 0
                    SET DEVICE TO PRINT

                    M245head()                             // Below

                    @ nl, 13 SAY "Outstanding Invoices Continued"
                    nl += 2
                ENDIF
            ELSE
                WAIT
                Scroll()
                nl := 2
            ENDIF
            SELECT Debit
        ENDIF
        // **      mgtotcr:= mgtot1:= mgtot2:= mgtotr:= 0
        ApRLock( 3 )
        DO CASE
        CASE Year(  Debit->Dbdate ) = Year( Date() ) -2
            mgtot2  += Debit->Amount
        CASE Year(  Debit->Dbdate ) = Year( Date() ) -1;
                .AND. Month( Debit->DbDate ) < 10
            mgtot2  += Debit->Amount
        CASE Month( Debit->Dbdate ) == mmonthcr
            mgtotcr += Debit->Amount
        CASE Month( Debit->Dbdate ) == mmonth1
            mgtot1  += Debit->Amount
        OTHERWISE
            mgtot2  += Debit->Amount
        ENDCASE
        UNLOCK
        @ nl, 0 SAY Debit->Dbdate
        @ nl, 12 SAY "Invoice"
        @ nl, 20 SAY Debit->Invno
        @ nl, 27 SAY Debit->BranchId
        @ nl, 30 SAY Debit->Ordnum
        @ nl, 42 SAY Debit->Amount PICTURE "999,999.99"
        @ nl, 57 SAY Debit->Invno
        @ nl, 64 SAY Debit->BranchId
        @ nl, 67 SAY Debit->Amount PICTURE "999,999.99"
        nl++
        mgtotr += Debit->Amount
        SKIP ALIAS Debit
    ENDDO
    nover := mgtot2 + mgtot1
    IF mwhere = "P"
        nl := 42
    ENDIF
    IF nover > 0
        @ nl, 4 SAY "Overdue Account"
        @ nl, 30 SAY "Current"
        nl++
        @ nl, 9 SAY nover PICTURE "$999,999.99"
        SELECT Name
        ApRLock( 3 )
        Name->OverDue := nover
        UNLOCK
        SELECT Debit
    ELSE
        nl++
    ENDIF
    @ nl, 27 SAY mgtotcr PICTURE "$999,999.99"
    @ nl, 42 SAY mgtotr  PICTURE "$999,999.99"
    @ nl, 55 SAY mgtotr  PICTURE "$999,999.99"
    nl += 2
    @ nl, 4 SAY Control->Con_Note4
    nl++
    @ nl, 4 SAY Control->Con_Note5
    nl++
    @ nl, 4 SAY Control->Con_Note6

    RETURN NIL

// ** End of DebitSel()

// *-------------------------------------------------------------------

FUNCTION M245head()

    SELECT Control
    // @  2,11 SAY CHR(14)+CHR(27)+CHR(71)+TRIM(mname)
    // @  2,39 SAY CHR(20)+CHR(27)+CHR(99)+CHR(49)
    nl := 1
    @ nl, 4 SAY Control->U_Name
    @ nl, 57 SAY SubStr( Control->U_Name, 1, 21 )
    nl++
    @ nl, 4 SAY Control->U_Add1
    @ nl, 57 SAY SubStr( Control->U_Add1, 1, 21 )
    nl++
    @ nl, 4 SAY Control->U_Add2
    @ nl, 57 SAY SubStr( Control->U_Add2, 1, 21 )
    IF Control->U_Add3 != Space( 27 )
        nl++
        @ nl, 4 SAY Control->U_Add3
        @ nl, 57 SAY SubStr( Control->U_Add3, 1, 21 )
    ENDIF
    // **   nl++
    // **   @ nl, 4 SAY Control->U_Add4
    // **   @ nl,55 SAY TRIM( Control->U_Add4 )
    nl++
    @ nl, 14 SAY "Ph " + Trim( Control->U_Phone ) + " Ph/Fax " + Control->U_Fax
    nl += 4
    SELECT Name
    SEEK mcodeno
    @ nl, 9 SAY Name->Name
    @ nl, 57 SAY SubStr( Name->Name, 1, 21 )
    // **      @ nl, 9 SAY TRIM(Name->Title)+" "+TRIM(Name->Called)+" "+Name->Famname
    // **      @ nl,57 SAY SUBSTR( Name->Famname,1,21 )
    nl++
    @ nl, 9 SAY Name->Add1
    @ nl, 43 SAY mdatestat
    @ nl, 57 SAY mdatestat
    nl++
    @ nl, 9 SAY Name->Add2
    @ nl, 57 SAY SubStr( Name->Add1, 1, 21 )
    nl++
    @ nl, 9 SAY Name->Add3
    @ nl, 43 SAY Name->Codeno
    @ nl, 57 SAY SubStr( Name->Add2, 1, 21 )
    nl++
    @ nl, 9 SAY Name->Add4 + " " + Name->Zip
    @ nl, 57 SAY SubStr( Name->Add4, 1, 21 )
    nl += 2
    // **       @ nl,55 SAY "Ph "+Name->Phone      // Business Phone
    nl += 4

    RETURN nl

// ** End of M245Head()

// *********------------ END OF FILE CHRDEB25.PRG
