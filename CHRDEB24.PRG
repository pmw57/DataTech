// ** JK 08-11-11 14:04:57

/*  Program.....:            DEB240.PRG

    Authors.....: J.Kirby
    Date........: 03/06/85
    Calls.......: DebList, Namerank(), Printest(), Stathead()
*/

// (c) Copyright 1993 by Chozen Ltd Christchurch.

FUNCTION DebListA( mcodeno )

    Scroll()
    @ 10, 52 SAY "Select Name for Statement"
    nrecno  := 0
    aPart_  := {}
    SELECT Debit
    SET ORDER TO 1    // Codeno+BranchId
    GOTO TOP
    IF LastRec() != 0
        DO WHILE Debit->( !Eof() )
            IF Debit->Codeno != "A  "
                // **            IF Debit->Amount = 0
                // **               SKIP ALIAS Debit
                // **               LOOP
                // **            ENDIF
                IF Month( Debit->Dbdate ) = Month( Date() ) .AND. ;
                        Year( Debit->Dbdate ) = Year(  Date() )
                    SKIP ALIAS Debit
                    LOOP
                ENDIF
            ENDIF
            IF mprint = "Y"
                IF Debit->Printed = "P"
                    SKIP ALIAS Debit
                    LOOP
                ENDIF
            ENDIF
            IF Debit->Codeno = mcodeno
                SKIP ALIAS Debit
                LOOP
            ENDIF
            SELECT Name
            SEEK Debit->Codeno
            SELECT Debit
            IF Debit->Printed = "P"
                cprint := "Printed " + Debit->Tech
            ELSE
                cprint := "       "
            ENDIF
            mcodeno := Debit->Codeno
            AAdd( aPart_, Name->Name + "  " + cprint;
                + "          " + Str( RecNo(), 6 ) )
            SKIP ALIAS Debit
        ENDDO                          // EOF()
        DispBox( 0, 1, 23, 46, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum   := AChoice( 1, 3, 22, 45, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
            IF LastKey() == 27
                RETURN NIL
            ENDIF
            GOTO nrecno
            mcodeno := Debit->Codeno
            SELECT Name
            SEEK mcodeno
        ENDIF
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 10 SAY Name->Name
    ENDIF                                // LastRec

    RETURN
// ****----------------  End DebListA()

// ****-----------------------------------------------------------------

FUNCTION Deb240()

#include "pcodeaah.CH"

    SELECT Debit
    INDEX ON Codeno + DToS( Dbdate ) + Invno TO DebCode
    SET INDEX TO DebCode
    SELECT Debit
    SET ORDER TO 1          // Codeno
    mtempcode := "A       "
    GOTO TOP
    SEEK mtempcode
    IF !Found()
        ApFLock( 3 )
        APPEND BLANK
        Debit->Codeno := "A      "
        UNLOCK
    ENDIF
    mmonthcr  := Month( Date() ) -1
    mrecdate  := Date()
    mdatestat := "30/" + Str( mmonthcr, 2, 0 ) + SubStr( DToC( Date() ), 6, 5 )
    Scroll(  2, 0, 24, 80 )
    DispBox( 7, 10, 16, 70, 2 )
    mdate := Str( Day( Control->Lastused ), 3 ) + " " + CMonth( Control->Lastused );
        + " " + Str( Year( Control->Lastused ), 5 )
    IF Date() > Control->LastUsed + 14
        SELECT Debit
        ApFLock( 3 )
        REPLACE ALL Debit->Printed WITH " "
        REPLACE ALL Debit->Tech    WITH "  "
        UNLOCK
        SELECT Control
        ApFLock( 3 )
        Control->Lastused := Date()
        UNLOCK
    ENDIF
    mcorrect := "N"
    @  8, 15 SAY "Statement to be dated :" GET mdatestat PICTURE "99/99/9999"
    READ
    IF LastKey() == 27
        RETURN NIL
    ENDIF
    mprint := "N"
    // ****           ApGetN( "Skip if Printed up to  "+mdate+" " )
    // DTOS( Control->LastUsed ) )
    nselect  := 0
    @ 10, 15 PROMPT "1. Standard Pre/Printed Statement"
    @ 12, 15 PROMPT "2. A4 Monthly Statement          "
    MENU TO nselect
    DO CASE
    CASE LastKey() == 27
        RETURN
    CASE nselect == 1
        mok := mcontinue := "Y"
        DO WHILE mok == "Y"
            mcodeno := Space( 8 )
            DebListA( mcodeno )              // Above
            mcodeno := Name->Codeno
            IF mcodeno = "A  "
                Namerank()
            ENDIF
            mwhere := "P"
            Printsel( mwhere )                                     // _LP_Init
            DebitGet( mcodeno )

            IF mwhere == "P"
                EndPrint()
            ELSE
                WAIT
            ENDIF
            mok := ApGetY( Message->Another + " Statement" )
            IF LastKey() == 27
                RETURN NIL
            ENDIF
        ENDDO

    CASE nselect == 2
        mok := mcontinue := "Y"
        DO WHILE mok == "Y"
            mcodeno := Space( 8 )
            DebListA( mcodeno )              // Above
            IF Name->Codeno = "A  "
                mcodeno := Space( 8 )
                Namerank()
            ENDIF
            mcodeno := Name->Codeno
            mwhere := "P"
            Printsel( mwhere )                                     // _LP_Init
            DebitA4( mcodeno )                        // A4 Statement
            IF mwhere == "P"
                EndPrint()
            ELSE
                WAIT
            ENDIF
            mok := ApGetY( Message->Another + " Statement" )
            IF LastKey() == 27
                RETURN NIL
            ENDIF
        ENDDO


    ENDCASE

    RETURN NIL

// *** End of Deb240()

// *-------------------------------------------------------------------

FUNCTION DebitA4( mcodeno )

    M204A4head()                           // Below

    IF mwhere = "P"
        npl := 60
    ELSE
        npl := 18
    ENDIF

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
    nl += 3
    IF mrecamnt > 0
        @ nl, 11 SAY "Received with Thanks"
        @ nl, 32 SAY mrecamnt PICTURE "$999,999.99"
        @ nl, 52 SAY "Rec'd"
        @ nl, 58 SAY mrecamnt PICTURE "$999,999.99"
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
        // **      IF Debit->Amount = 0
        // **         SKIP ALIAS Debit
        // **         LOOP
        // **      ENDIF
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
                nl += 4
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
        @ nl, 52 SAY Debit->Invno
        @ nl, 60 SAY Debit->BranchId
        // ***      @ nl,62 SAY SUBSTR( Debit->Ordnum,1,3 )
        @ nl, 65 SAY Debit->Amount PICTURE "999,999.99"
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
    @ nl, 61 SAY mgtotr  PICTURE "$999,999.99"
    nl += 2
    @ nl, 4 SAY Control->Con_Note4
    nl++
    @ nl, 4 SAY Control->Con_Note5
    nl++
    @ nl, 4 SAY Control->Con_Note6
    SELECT Debit
    GOTO TOP
    SEEK mcodeno
    DO WHILE Debit->Codeno = mcodeno .AND. Debit->( !Eof() )
        IF Debit->Stat = "W"
            SKIP ALIAS Debit
            LOOP
        ENDIF
        IF Debit->Stat = "J"
            SKIP ALIAS Debit
            LOOP
        ENDIF
        IF Month( Debit->Dbdate ) = Month( Date() ) .AND. ;
                Year( Debit->Dbdate ) = Year(  Date() )
            SKIP ALIAS Debit
            LOOP
        ENDIF
        IF mwhere = "P"
            ApRLock( 3 )
            Debit->Printed := "P"
            DO CASE
            CASE SubStr( Debit->Tech, 1, 1 ) = " "
                Debit->Tech   := "1"
            CASE SubStr( Debit->Tech, 1, 1 ) = "1"
                Debit->Tech   := "2"
            CASE SubStr( Debit->Tech, 1, 1 ) = "2"
                Debit->Tech   := "3"
            CASE SubStr( Debit->Tech, 1, 1 ) = "3"
                Debit->Tech   := "4"
            CASE SubStr( Debit->Tech, 1, 1 ) = "4"
                Debit->Tech   := "5"
            CASE SubStr( Debit->Tech, 1, 1 ) = "5"
                Debit->Tech   := "6"
            CASE SubStr( Debit->Tech, 1, 1 ) = "6"
                Debit->Tech   := "7"
            OTHERWISE
                Debit->Tech   := "1"
            ENDCASE
            UNLOCK
        ENDIF
        RETURN
        SKIP ALIAS Debit
    ENDDO

    RETURN NIL

// ** End of DebitA4()

// *-------------------------------------------------------------------

FUNCTION M204A4head()

    IF mwhere = "P"
        nl := 8
    ELSE
        nl := 0
    ENDIF
    SELECT Name
    SEEK mcodeno
    @ nl, 5 SAY Name->Name
    @ nl, 52 SAY SubStr( Name->Name, 1, 25 )
    nl++
    @ nl, 5 SAY Name->Add1
    @ nl, 52 SAY SubStr( Name->Add1, 1, 25 )
    nl++
    @ nl, 5 SAY Name->Add2
    @ nl, 52 SAY SubStr( Name->Add2, 1, 25 )
    nl++
    @ nl, 5 SAY Name->Add3
    @ nl, 52 SAY SubStr( Name->Add3, 1, 25 )
    nl++
    @ nl, 5 SAY Name->Add4 + " " + Name->Zip
    @ nl, 52 SAY SubStr( Name->Add4, 1, 25 )
    nl += 6
    @ nl, 5 SAY Name->Codeno
    @ nl, 25 SAY mdatestat
    @ nl, 53 SAY Name->Codeno
    @ nl, 65 SAY mdatestat
    nl++

    RETURN nl

// ** End of M204A4Head()

// ***--------------------------------------------------------------------------

FUNCTION Debitget( mcodeno )

    M204head()                           // Below

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
    nl += 2
    IF mrecamnt > 0
        @ nl, 13 SAY "Received with Thanks"
        @ nl, 40 SAY mrecamnt PICTURE "999,999.99"
        @ nl, 57 SAY "Rec'd"
        @ nl, 66 SAY mrecamnt PICTURE "$999,999.99"
        nl += 2
    ENDIF
    @ nl, 13 SAY "Outstanding Invoices"
    nl += 2
    IF mwhere = "P"
        npl := 36
    ELSE
        npl := 18
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
        IF Month( Debit->Dbdate ) = Month( Date() ) .AND. ;
                Year( Debit->Dbdate ) = Year(  Date() )
            SKIP ALIAS Debit
            LOOP
        ENDIF
        IF nl > npl
            mpageno := mpageno + 1
            IF mwhere == "P"
                @  0, 0 SAY Chr( 27 ) + Chr( 67 ) + Chr( 03 )
                // **        EndPrint()
                Scroll( 3, 0, 24, 75 )
                @ 12, 0 SAY "PLEASE ALIGN STATEMENT TO TOP OF PAGE WILL IMPROVE SOON"
                WAIT
                IF mwhere == "P"
                    @  0, 0
                    SET DEVICE TO PRINT

                    M204head()                             // Below

                    nl += 4
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
        @ nl, 1 SAY Debit->Dbdate
        @ nl, 13 SAY "Invoice"
        @ nl, 21 SAY Debit->Invno
        @ nl, 28 SAY Debit->BranchId
        @ nl, 31 SAY SubStr( Debit->Ordnum, 1, 9 )
        @ nl, 41 SAY Debit->Amount PICTURE "999,999.99"
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
        @ nl, 8 SAY nover PICTURE "$999,999.99"
        SELECT Name
        ApRLock( 3 )
        Name->OverDue := nover
        UNLOCK
        SELECT Debit
    ELSE
        nl++
    ENDIF
    @ nl, 27 SAY mgtotcr PICTURE "$999,999.99"
    @ nl, 41 SAY mgtotr  PICTURE "$999,999.99"
    @ nl, 55 SAY mgtotr  PICTURE "$999,999.99"
    nl += 3
    @ nl, 5 SAY "Terms of Trade by the 20th"

    RETURN NIL

// ** End of DebitGet()

// *-------------------------------------------------------------------

FUNCTION M204head()

    nl := 0
    IF mwhere = "P"
        SELECT Control
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
            @ nl, 4 SAY Control->U_Add3 + " " + Control->U_Zip
            @ nl, 57 SAY SubStr( Control->U_Add3, 1, 21 )
        ENDIF
        // **   nl++
        // **   @ nl, 4 SAY Control->U_Add4
        // **   @ nl,55 SAY TRIM( Control->U_Add4 )
        nl++
        @ nl, 14 SAY "Ph " + Trim( Control->U_Phone ) + " Ph/Fax " + Control->U_Fax
        nl += 4
    ENDIF               // mwhere  "P"
    SELECT Name
    SEEK mcodeno
    @ nl, 9 SAY Name->Name
    @ nl, 57 SAY SubStr( Name->Name, 1, 21 )
    nl++
    @ nl, 9 SAY Name->Add1
    @ nl, 41 SAY mdatestat
    nl++
    @ nl, 9 SAY Name->Add2
    @ nl, 57 SAY SubStr( Name->Add1, 1, 21 )
    nl++
    @ nl, 9 SAY Name->Add3
    @ nl, 41 SAY Name->Codeno
    @ nl, 57 SAY SubStr( Name->Add2, 1, 21 )
    nl++
    @ nl, 9 SAY Name->Add4 + " " + Name->Zip
    @ nl, 57 SAY SubStr( Name->Add4, 1, 21 )
    nl += 4
    @ nl, 67 SAY mdatestat
    // **       @ nl,55 SAY "Ph "+Name->Phone      // Business Phone

    RETURN nl

// ** End of M204Head()

// *********------------ END OF FILE CHRDEB24.PRG
