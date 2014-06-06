// ** JK 19-06-11 20:53:04

/*
   Program.....:                  XLF_QU7.PRG
   Author......: J.Kirby
   Date........: 06/06/2002
   Functions...: JCMenu, JCPart, JobProg, QuotAdd
                 QuotUpdate, QuotTot, QuotFind
   Static funcs: ProgPrint, QuotStatH1
*/

FUNCTION JCMenu()

    manother := "Y"
    DO WHILE manother = "Y"
        Scroll(  18, 0, 24, 80 )
        DispBox( 18, 1, 24, 79, 2 )
        @ 18, 5 SAY " -- JC- Cards  -- " COLOR "G+"
        @ 18, 54 SAY " -- JC- Cards  -- " COLOR "G+"
        @ 24, 60 SAY " DT11A "
        coperno := Debit->Operno
        nselect := 1
        @ 20, 3      PROMPT " "
        @ 20, Col() + 1 PROMPT "1. Add Part"
        @ 20, Col() + 2 PROMPT "2. Edit JC-"
        @ 20, Col() + 2 PROMPT "3. JC- Print"
        @ 20, Col() + 2 PROMPT "4. Review"
        @ 20, Col() + 2 PROMPT "5. Module"
        @ 22, 5      PROMPT "6. Price"
        @ 22, Col() + 2 PROMPT "7. Delete JC"
        @ 22, Col() + 2 PROMPT "8. Work Lab"
        @ 22, Col() + 2 PROMPT "9. Progress"
        @ 22, Col() + 2 PROMPT "New Product"
        @ 23, 64 SAY Debit->Operno COLOR "BG+"
        MENU TO nselect
        DO CASE
        CASE nselect == 12 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 11
            GroupSelect( @coperno )
            SELECT Debit
            ApRLock( 3 )
            Debit->Operno := coperno
            UNLOCK
            JCMenu()
            // **          coperno := Debit->Operno
            // **          ProgMessage( @coperno )
            // **          LOOP
        CASE nselect == 2
            mpartnum := Space( 20 )
            SELECT Part
            SET ORDER TO 1
            mcodeno := Name->Codeno
            Partfind( @mpartnum, mcodeno )                // XF_Part
            mpartnum := Part->Partnum
            QuotPAdd( @mpartnum )              // XLF_QU2
            JCMenu()
            // **          manother := "Y"
            // **          LOOP
        CASE nselect == 3
            QuotEdit( @mcodeno )                         // Below
            JCMenu()
            // **          manother := "Y"
            // **          LOOP
        CASE nselect == 4
            IF SubStr( Control->U_Name, 1, 3 ) = "MET"
                MetJCut( @mcodeno )                     // XLF_Stat
            ELSE
                QuotJCut( @mcodeno )                    // XLF_Qu5
            ENDIF
            mprint := "Y"
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mprint = "Y"
                QuotCut( @mcodeno )                     // XLF_Qu3
            ENDIF
            mprint := "Y"
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mprint = "Y"
                JobStatus()                             // XLF_QU6
            ENDIF              // mprint
            JCMenu()

            // **          manother := "Y"
            // **          LOOP
        CASE nselect == 5
            mcodeno := Name->Codeno
            WoCost( mcodeno )                        // XLF_Quot
            JCMenu()
            // **          manother := "Y"
            // **          LOOP
        CASE nselect == 6
            mmodcode := Trim( mpartnum )
            EquModule( mmodcode )
            JCMenu()
            // **         manother := "Y"
            // **         LOOP
        CASE nselect == 7              // 1 Price
            SELECT Quot
            SET ORDER TO 3        // Invno
            SEEK Debit->Invno
            mmodcode := Trim( Quot->Partnum )
            JCPrice( mmodcode )                    // XLF_QU8
            SELECT Quot
            SET ORDER TO 1        // Codeno
            JCMenu()
            // **         manother := "Y"
            // **         LOOP
        CASE nselect == 8                  // Delete
            Scroll( 19, 0, 24, 80 )
            @ 24, 60 SAY " DT111 "
            cstring := Trim( Message->Suredel )
            mok := ApCheck( cstring )                  // AppX.PRG
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mok == "Y"
                SELECT Quot
                GOTO TOP
                ApFLock( 3 )
                DO WHILE Quot->( !Eof() )
                    IF Quot->Invno != minvno
                        SKIP ALIAS Quot
                        LOOP
                    ENDIF
                    DELETE
                    SKIP ALIAS Quot
                ENDDO
                UNLOCK
                SELECT Labour
                GOTO TOP
                ApFLock( 3 )
                DO WHILE Labour->( !Eof() )
                    IF Labour->Invno != minvno
                        SKIP ALIAS Labour
                        LOOP
                    ENDIF
                    DELETE
                    SKIP ALIAS Labour
                ENDDO
                UNLOCK
                SELECT Invoice
                SEEK minvno
                IF !Found()
                    SELECT Debit
                    SET ORDER TO 2
                    SEEK minvno
                    IF Found()
                        ApFLock( 3 )
                        DELETE
                        UNLOCK
                    ENDIF
                    SET ORDER TO 1
                ENDIF
                SELECT Status
                SET ORDER TO 1                     // Invno
                SEEK minvno
                IF Found()
                    ApFLock( 3 )
                    DO WHILE Status->Invno = minvno .AND. Status->( !Eof() )
                        DELETE
                        SKIP ALIAS Status
                    ENDDO
                    UNLOCK
                ENDIF
            ENDIF
            JCMenu()
            // **          manother := "Y"
            // **          LOOP

        CASE nselect == 9
            mpartnum := Space( 20 )
            IvcLabour( mpartnum )                    // XLF_Qu1
            JCMenu()

            // **         manother := "Y"
            // **         LOOP
        CASE nselect == 10
            JobProg()
            JCMenu()
            // **         manother := "Y"
            // **         LOOP
        ENDCASE
        IF PressedEsc()
            RETURN NIL
        ENDIF
        JCMenu()
        manother := "Y"
        LOOP
    ENDDO        // manother

    RETURN NIL
// ** -------------- JCMenu()     DT11A

// ***-------------------------------------------------------------------------

FUNCTION JCPart()

    manother := "Y"
    DO WHILE manother = "Y"
        IF Control->U_Name = "CHRI"
            @ 10, 10 SAY "This is mostly for ProdMain Beware"
            @ 12, 10 SAY "  "
            WAIT
        ENDIF      // Chris
        IF Control->U_Name != "CHRI"
            SELECT Name
            SEEK Debit->Codeno
            mcodeno := Name->Codeno
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @  1, 4 SAY Name->Codeno + "  " + Name->Name + " JC- "
            @ 1, Col() + 2 SAY minvno
            SELECT Quot
            SET ORDER TO 1         // Codeno+Br+Date
            SEEK mcodeno
            IF Found()
                QuoLook( mcodeno, cbranchId )                 // XLF_Quot
            ENDIF
            SELECT Name
            @ 17, 5 SAY Debit->Codeno + " " + Debit->Invno
        ENDIF   // Not CHRI
        Scroll(  18, 0, 24, 80 )
        DispBox( 18, 1, 24, 79, 2 )

        JCMenu()                        // XLF_Qu7
        IF PressedEsc()
            RETURN NIL
        ENDIF

    ENDDO                               // manother

    RETURN NIL
// ** --- End JCPpart()

// *** -----------------------------------------------------------------------

STATIC FUNCTION ProgPrint()

    mpart = ApGetN( "Do you want Parts" )

    mwhere := "S"
    npl    := 67
    nl     := 0

    Printsel()                               // _LF_Init

    IF mwhere == "P"
        npl := 65
        @  0, 0
        SET DEVICE TO PRINT
    ELSE
        npl := 21
    ENDIF
    minvno := Debit->Invno
    @ nl, 2 SAY Control->U_Name
    @ nl, 38 SAY "Progress Report"
    @ nl, 59 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    nl += 2
    SELECT Name
    SEEK Debit->Codeno
    @ nl, 0 SAY Trim( Name->Name ) + "  " + Trim( Debit->Est ) + " JC- " + minvno
    nl++
    @ nl, 2 SAY Name->Add1
    nl++
    @ nl, 2 SAY Name->Add2
    nl++
    @ nl, 2 SAY Name->Add3
    nl++
    @ nl, 2 SAY Name->Add4
    IF Name->Phone != Space( 15 )
        @ nl, 24 SAY Name->Phone                // Business Phone
    ELSE
        @ nl, 24 SAY Name->Ephone               // Home Phone
    ENDIF
    @ nl, 48 SAY "Start"
    @ nl, 54 SAY DToC( Debit->StartDate )
    @ nl, 65 SAY "Due"
    @ nl, 69 SAY DToC( Debit->DueDate )
    nl++
    @ nl, 3 SAY Debit->Fault
    nl++
    @ nl, 3 SAY Debit->Message
    @ nl, 54 SAY Debit->DbDate
    nl++
    coperno := Debit->Operno
    // ** Must have Note->Private = BLANK
    SELECT Part
    SEEK Quot->Partnum
    @ nl, 0 SAY Str( Quot->Qty, 8, 3 ) + " " + SubStr( Part->Unit, 1, 6 );
        + " " + Part->Desc;
        + "  " + SubStr( Quot->Partnum, 1, 16 )
    nl++
    IF Part->Detail != Space( 43 )
        @ nl, 12 SAY Part->Detail
        nl++
    ENDIF
    IF Part->Detail1 != Space( 43 )
        @ nl, 12 SAY Part->Detail1
        nl++
    ENDIF
    nl++
    SELECT Quot
    SET ORDER TO 3        // Invno + Partnum
    SEEK Debit->Invno
    coperno := Debit->Operno
    SELECT Progress
    GOTO TOP
    SEEK coperno
    @ nl, 0 SAY "Product  " + coperno
    nl++
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog01
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog02
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog03
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog04
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog05
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog06
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog07
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog08
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog09
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog10
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog11
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog12
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog13
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog14
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog15
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog16
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog17
    @ nl, 32 SAY "___________________________:_________:________"
    nl++
    SKIP ALIAS Progress
    @ nl, 1 SAY Progress->DescProg
    @ nl, 16 SAY Quot->Prog18
    @ nl, 32 SAY "___________________________:_________:________"
    nl += 2
    SELECT PartOper
    SET ORDER TO 2               // Operno+Adminno+Drawno
    GOTO TOP
    @ nl, 0 SAY "Part Process " + coperno
    @ nl, 60 SAY "PartOper.Dbf"
    nl++
    nTotTime := 0
    SEEK coperno
    DO WHILE PartOper->Operno = coperno .AND. PartOper->( !Eof() )
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            @  0, 40 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  0, 62 SAY minvno
            nl := 2
        ENDIF                           // nl>npl
        IF PartOper->Partnum = "        "
            @ nl, 0 SAY DToC( PartOper->Date );
                + " " + PartOper->Adminno;
                + " " + PartOper->Desc;
                + " " + Str( PartOper->Time )
            nl++
            ntottime += PartOper->Time
        ENDIF
        SKIP ALIAS PartOper
    ENDDO
    @ nl, 45 SAY "PartOper Time"
    @ nl, 59 SAY nTotTime PICTURE "99,999.99"
    nl += 2
    @ nl, 0 SAY minvno + " Labour"

    nl++
    ntimetotal := nPartTot := nTimeRate := 0
    SELECT Labour
    SET ORDER TO 2  // Invoice            // 1  Codeno+Date+Partnum
    GOTO TOP
    SEEK minvno
    DO WHILE Labour->Invno = minvno .AND. Labour->( !Eof() )
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF                       // mwhere = P
            @  0, 0 SAY Control->U_Name
            @  0, 40 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  0, 62 SAY minvno
            nl := 2
        ENDIF                           // nl>npl
        IF Labour->Partnum = "      "
            @ nl, 0 SAY DToC( Labour->Date );
                + " " + Labour->Codeno;
                + " " + Labour->Desc + " " + Str( Labour->Time )
            nl++
        ELSE
            IF mpart = "Y"
                @ nl, 0 SAY SubStr( Labour->Partnum, 1, 16 );
                    + " " + Labour->Codeno;
                    + " " + Labour->Desc + " " + Str( Labour->Time )
                nl++
            ENDIF
        ENDIF
        SKIP ALIAS Labour
    ENDDO                // mcode
    nl++
    SELECT Labour
    SET ORDER TO 2  // Invoice            // 1  Codeno+Date+Partnum
    GOTO TOP
    SEEK minvno
    DO WHILE Labour->Invno = minvno .AND. Labour->( !Eof() )
        IF Labour->Partnum != Space( 20 )
            nPartTot += Labour->Time * Labour->Rate
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF                       // mwhere = P
            @  0, 0 SAY Control->U_Name
            @  0, 40 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  0, 62 SAY minvno
            nl := 2
        ENDIF                           // nl>npl
        mcode      := Labour->Codeno
        nCodeTot   := 0
        SELECT Labour
        DO WHILE Labour->Codeno = mcode .AND. Labour->( !Eof() )
            IF Labour->Invno != minvno
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Partnum != Space( 20 )
                nPartTot += Labour->Time * Labour->Rate
                SKIP ALIAS Labour
                LOOP
            ENDIF
            nCodeTot   += Labour->Time
            nTimeTotal += Labour->Time
            nTimeRate  += Labour->Time * Labour->Rate
            SKIP ALIAS Labour
        ENDDO                // mcode
        SELECT Name
        SEEK mcode
        @ nl, 28 SAY Name->Name
        SELECT Labour
        @ nl, 59 SAY ncodeTot PICTURE "99,999.99"
        @ nl, 70 SAY Name->Letter
        nl++
    ENDDO                // EOF Labour
    // ** IF nTimeTotal > 0
    @ nl, 58 SAY "-----------"
    nl++
    SELECT Part
    SEEK Message->LabPart
    @ nl, 1 SAY "Rate ="
    @ nl, 10 SAY Part->Trade PICTURE "$99,999.99"
    @ nl, 38 SAY minvno + " Total Time"
    @ nl, 59 SAY nTimeTotal             PICTURE "99,999.99"
    nTimeTotal := nTimeTotal * Part->Trade
    nl++
    @ nl, 58 SAY "==========="
    nl++
    @ nl, 14 SAY "------------"
    @ nl, 39 SAY "------------"
    @ nl, 62 SAY "------------"
    nl++
    @ nl, 0 SAY minvno + " Parts"
    @ nl, 14 SAY nPartTot   PICTURE "$999,999.99"
    @ nl, 28 SAY "Time*Rate"
    @ nl, 39 SAY nTimeTotal PICTURE "$999,999.99"
    @ nl, 52 SAY "Part+Time"
    @ nl, 62 SAY nparttot + nTimeTotal PICTURE "$999,999.99"
    nl++
    @ nl, 14 SAY "============"
    @ nl, 39 SAY "============"
    @ nl, 62 SAY "============"
    nl++

    IF mwhere = "P"
        @ nl, 0 SAY " "
        EndPrint()
    ELSE
        IF nl > 18
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN NIL
// ***-------------- End ProgPrint

// ***------------------------------------------------------------------------

FUNCTION JobProg()

    coperno := Debit->Operno
    ProgMessage( @coperno )
    Scroll()
    DispBox( 0, 1, 2, 79, 2 )
    @  1, 6 SAY Name->Name + " Job Card # " + Debit->Invno
    @  3, 4 SAY Debit->Operno + "  " + coperno COLOR "RG+"
    minvno := Debit->Invno
    DispBox( 3, 1, 24, 79, 2 )
    nl := 5
    SELECT Progress
    SEEK coperno
    DO WHILE Progress->Operno = coperno .AND. Progress->( !Eof() )
        IF Progress->Order = "  "
            SKIP ALIAS Progress
            LOOP
        ENDIF
        @  nl, 4 SAY Progress->Order + " " + Progress->DescProg
        nl++
        SKIP ALIAS Progress
    ENDDO
    SELECT Quot
    SET ORDER TO 3         // Invno + Partnum
    SEEK minvno
    ApRLock( 3 )
    @  5, 23 SAY "01"GET Quot->Prog01 PICTURE "@X"
    @  6, 23 SAY "02"GET Quot->Prog02 PICTURE "@X"
    @  7, 23 SAY "03"GET Quot->Prog03 PICTURE "@X"
    @  8, 23 SAY "04"GET Quot->Prog04 PICTURE "@X"
    @  9, 23 SAY "05"GET Quot->Prog05 PICTURE "@X"
    @ 10, 23 SAY "06"GET Quot->Prog06 PICTURE "@X"
    @ 11, 23 SAY "07"GET Quot->Prog07 PICTURE "@X"
    @ 12, 23 SAY "08"GET Quot->Prog08 PICTURE "@X"
    @ 13, 23 SAY "09"GET Quot->Prog09 PICTURE "@X"
    @ 14, 23 SAY "10"GET Quot->Prog10 PICTURE "@X"
    @ 15, 23 SAY "11"GET Quot->Prog11 PICTURE "@X"
    @ 16, 23 SAY "12"GET Quot->Prog12 PICTURE "@X"
    @ 17, 23 SAY "13"GET Quot->Prog13 PICTURE "@X"
    @ 18, 23 SAY "14"GET Quot->Prog14 PICTURE "@X"
    @ 19, 23 SAY "15"GET Quot->Prog15 PICTURE "@X"
    @ 20, 23 SAY "16"GET Quot->Prog16 PICTURE "@X"
    @ 21, 23 SAY "17"GET Quot->Prog17 PICTURE "@X"
    @ 22, 23 SAY "18"GET Quot->Prog18 PICTURE "@X"
    @ 22, 40 SAY "18 Blank if Job Not Complete" COLOR "G+"
    READ
    UNLOCK
    mchoice := 1
    @ 17, 43 PROMPT "1. Print Progress"
    @ 19, 43 PROMPT "2. Operations    "
    @ 20, 43 PROMPT "3. Exit          "
    MENU TO mchoice
    DO CASE
    CASE mchoice == 3 .OR. LastKey() == 27
        RETURN NIL
    CASE mchoice == 1
        ProgPrint()            // Below
    CASE mchoice == 2
        Operation()            // XLF_Job
    ENDCASE
    IF PressedEsc()
        RETURN NIL
    ENDIF

    SELECT Quot
    SET ORDER TO 1         // Codeno

    RETURN NIL
// ***-------------- End JobProg

// ***-----------------------------------------------------------------------

FUNCTION QuotAdd( mcodeno, cbranchId )

    dDbDate   := Date()
    mfaxno    := Space ( 8 )
    mpartnum  := Space( 20 )
    ncutsum   := 0
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        minvno := Space( 6 )
        cInvno := Space( 8 )
        SELECT Debit
        GOTO TOP
        SET ORDER TO 1
        SEEK mcodeno
        IF LastRec() != 0
            aPart_ := {}
            nrecno := 0
            namnt := 0
            DO WHILE Debit->Codeno = mcodeno .AND. Debit->( !Eof() )
                IF SubStr( Control->U_Name, 1, 4 )  = "META"
                    IF Debit->Stat != "J"
                        SKIP ALIAS Debit
                        LOOP
                    ENDIF
                ENDIF
                IF cbranchId != Space( 2 )
                    IF Debit->BranchId != cbranchId
                        SKIP ALIAS Debit
                        LOOP
                    ENDIF
                ENDIF
                SELECT Debit
                AAdd( aPart_, Debit->Invno;
                    + " " + Debit->BranchId;
                    + " " + DToC( Debit->Dbdate );
                    + " " + Debit->Stat;
                    + " " + Debit->Equip;
                    + " " + Debit->Est;
                    + " " + SubStr( Debit->Fault, 1, 15 );
                    + " " + Debit->Operno;
                    + "                      " + Str( RecNo(), 6 ) )
                SKIP ALIAS Debit
            ENDDO
            IF !Empty( aPart_ )
                Scroll()
                DispBox(  0, 1, 2, 79, 2 )
                @ 1, 6 SAY Name->Codeno + "   " + Name->Name + "  " + cbranchId
                Scroll(   3, 0, 24, 80 )
                DispBox(  3, 1, 24, 79, 2 )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice(  4, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ], 6 ) )
            ENDIF
            GOTO nrecno
            cbranchId := Debit->BranchId
            minvno    := Debit->Invno
        ENDIF
        Scroll(  17, 0, 24, 80 )
        DispBox( 17, 1, 24, 79, 2 )
        @ 18, 6      SAY Name->Codeno + "   " + Name->Name + "  " + cbranchId
        @ 20, 10      SAY "Select/Add JC-" GET minvno PICTURE "@K!"
        @ 20, Col() + 3 SAY "Blank for New JC-"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        SELECT Debit
        SET ORDER TO 2                    // Invno
        SEEK minvno
        SET ORDER TO 1
        IF minvno == Space( 6 ) .OR. !Found()
            Scroll( 19, 4, 21, 76 )
            minvno := Str( Control->LastIvc )
            @ 19, 5 SAY "TWO SPACE FIRST CHARACTERS IF NOT INVOICE"
            @ 20, 10 SAY "Desired Job Card #" GET minvno PICTURE "!!!!!!"
            READ
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF SubStr( minvno, 1, 2 ) == Space( 2 )
                cInvno := Str( Control->Quotno )
                minvno := "10" + cInvno
                Scroll( 19, 4, 21, 76 )
                @ 19, 5 SAY "This is the Stock Job # you can Change"
                @ 20, 10 SAY "Desired Job Card #" GET minvno PICTURE "!!!!!!"
                READ
                IF PressedEsc()
                    RETURN NIL
                ENDIF
            ENDIF
            IF Val( minvno ) = Control->LastIvc
                SELECT Control
                ApRLock( 3 )
                Control->LastIvc := Control->LastIvc + 1
                UNLOCK
            ENDIF
            IF SubStr( minvno, 3, 4 ) = cInvno
                SELECT Control
                ApRLock( 3 )
                Control->Quotno := Control->Quotno + 1
                UNLOCK
            ENDIF
            SELECT Debit
            ApFLock( 3 )
            APPEND BLANK
            Debit->Stat      := "J"
            Debit->Codeno    := mcodeno
            Debit->Invno     := minvno
            Debit->DBDate    := Date()
            Debit->StartDate := Date() -2
            Debit->DueDate   := Date() + 30
            Debit->BranchId  := cbranchId
            // **      Debit->Equip     := " "
            UNLOCK
            minvno := Debit->Invno

            Scroll(  16, 0, 24, 80 )
            DispBox( 16, 1, 24, 79, 2 )
            dstartdate := Debit->StartDate
            dduedate   := Debit->DueDate
            mest       := Debit->Est
            // **   cequip     := SUBSTR( Debit->Equip, 1, 1 )
            // **   mbranchid  := Debit->BranchId
            mfault     := Debit->Fault
            mmessage   := Debit->Message
            @ 17, 5      SAY "Job Card " + Debit->Invno COLOR "G+"
            @ 18, 5      SAY "Start Date"        GET dstartdate
            @ 18, Col() + 2 SAY "Due Date"          GET dduedate
            @ 20, 10      SAY "Description"       GET mest
            // **   @ 20,COL()+2 SAY "Status ABC Y = Complete";
            // **                GET cequip PICTURE "@!" VALID( cequip $ "ABCY" )
            // **   @ 20,COL()+2 SAY "Branch"            GET mbranchid PICTURE "@!"
            @ 21, 5      SAY "Top Line Invoice"  GET mfault
            @ 22, 5      SAY "    Instructions"  GET mmessage
            READ
            ApRLock( 3 )
            Debit->StartDate := dstartdate
            Debit->DueDate   := dduedate
            Debit->Est       := mest
            Debit->Equip     := "N"
            Debit->Fault     := mfault
            Debit->Message   := mmessage
            UNLOCK
            // *** Part
            SELECT Part
            ApFLock( 3 )
            APPEND BLANK
            mdate    := DToS( Date() )
            Part->Partnum   := "JC-" + SubStr( Debit->Invno, 3, 4 ) + "-";
                + SubStr( mdate, 7, 2 ) + SubStr( mdate, 5, 2 );
                + SubStr( mdate, 3, 2 )
            Part->Desc      := Debit->Est
            Part->Boughtout := "N"
            Part->Catno     := "AA-JOBCARDS"
            Part->Codeno    := Control->U_Codeno
            UNLOCK
            // **** Quot
            SELECT Quot
            ApFLock( 3 )
            APPEND BLANK
            Quot->Partnum  := Part->Partnum
            Quot->Dbdate   := Date()
            Quot->Qty      := 1
            Quot->Catno    := Part->Catno
            Quot->Ordnum   := Name->Remarks
            Quot->Codeno   := Debit->Codeno
            Quot->Invno    := Debit->Invno
            Quot->ModSeqno := Debit->Codeno + Debit->Invno + LTrim( Str( RecNo(), 4 ) )
            Quot->BranchId := Debit->BranchId
            UNLOCK
            coperno := Space( 8 )
            GroupSelect( @coperno )
            // **      ProgMessage( @coperno )
            SELECT Debit
            ApRLock( 3 )
            Debit->Operno := coperno
            UNLOCK
            SELECT EquDesc
            ApFLock( 3 )
            APPEND BLANK
            EquDesc->ModCode := Trim( Part->Partnum )
            EquDesc->Desc    := Part->Desc
            UNLOCK
            SELECT Equ
            ApFLock( 3 )
            APPEND BLANK
            Equ->ModCode  := EquDesc->Modcode
            Equ->Catno    := Part->Catno
            Equ->Partnum  := Message->LabPart
            Equ->PartQty  := 1
            Equ->ModSeqno := EquDesc->Modcode + Str( RecNo(), 6 )
            UNLOCK
            mmodcode := Equ->ModCode
            mpartnum := Quot->Partnum
            EquSearch( mmodcode )
            QuotPrice( @mpartnum )
            QuotEdit( @mcodeno )                         // Below
        ELSE                        // IF Job Exists
            // ******************************* Existing Job
            // **** Job Edit
            Scroll(  14, 0, 24, 80 )
            DispBox( 14, 1, 24, 79, 2 )
            dstartdate := Debit->StartDate
            dduedate   := Debit->DueDate
            mest       := Debit->Est
            cequip     := SubStr( Debit->Equip, 1, 1 )
            // **   mbranchid  := Debit->BranchId
            mfault     := Debit->Fault
            mmessage   := Debit->Message
            coperno    := Debit->Operno
            @ 16, 4      SAY "Job Card " + Debit->Invno COLOR "G+"
            @ 18, 4      SAY "Start Date"        GET dstartdate
            @ 18, Col() + 2 SAY "Due Date"          GET dduedate
            @ 18, Col() + 2 SAY "JC- Complete Y/N"  GET cequip;
                VALID( cequip $ "YN" ) PICTURE "@!"
            @ 20, 4      SAY "     Description"  GET mest
            @ 21, 4      SAY "Top Line Invoice"  GET mfault
            @ 22, 4      SAY "    Instructions"  GET mmessage
            @ 23, 4 SAY "Blank for New Product"  GET coperno PICTURE "@K!"
            READ
            ApRLock( 3 )
            Debit->StartDate := dstartdate
            Debit->DueDate   := dduedate
            Debit->Est       := mest
            Debit->Equip     := cequip
            Debit->Fault     := mfault
            Debit->Message   := mmessage
            UNLOCK
            IF coperno = Space( 8 )
                GroupSelect( @coperno )
                SELECT Debit
                ApRLock( 3 )
                Debit->Operno := coperno
                UNLOCK
                // **      ProgMessage( @coperno )
            ENDIF          // coperno
        ENDIF     // minvno = SPACE
        SELECT Debit
        manother := "Y"
        DO WHILE manother = "Y"
            SELECT Name
            SEEK Debit->Codeno
            mcodeno := Name->Codeno
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @  1, 6 SAY Name->Codeno + "  " + Name->Name + "  " + cbranchId + " Job Card # " + minvno
            SELECT Quot
            SET ORDER TO 1         // Codeno+Br+Date
            SEEK mcodeno
            IF Found()
                QuoLook( mcodeno, cbranchId )                 // XLF_Quot
            ENDIF
            SELECT Name
            @ 17, 5 SAY Debit->Codeno + " " + Debit->Invno

            JCMenu()

            IF PressedEsc()
                RETURN NIL
            ENDIF
            LOOP
        ENDDO                               // manother
        mcontinue := "N"
    ENDDO                                   // mcontinue

    RETURN NIL

// ***----- End of Quotadd()

// *---------------------------------------------------------------------*

FUNCTION QuotUpdate()

    Scroll( 15, 4, 23, 78 )
    mlevel := 4
    // **   mxy := "N"
    // **   mxy := ApGetN( "Do You Want XY Parts" )
    SELECT Status
    SET ORDER TO 1                // Invno+Partnum
    GOTO TOP
    DO WHILE Status->( !Eof() )
        ApFLock( 3 )
        DELETE
        UNLOCK
        SKIP ALIAS Status
    ENDDO                          // Status
    @  8, 10 SAY Debit->Codeno + "  " + Debit->Invno COLOR "BG+"
    SELECT Quot
    SET ORDER TO 3                   // Invno+Partnum
    SEEK Debit->Invno
    DO WHILE Quot->Invno = Debit->Invno .AND. Quot->( !Eof() )
        IF Quot->Qty <= 0
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF Quot->Partnum = Message->LabPart          // Met = ZZFABRIC
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF SubStr( Quot->Partnum, 1, 1 ) = "Z"
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF SubStr( Quot->Invno, 1, 1 ) = " "
            SKIP ALIAS Quot
            LOOP
        ENDIF
        nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
        nqty1 := nqty2 := nqty3 := nqty4 := 0
        nequ1 := nequ2 := nequ3 := nequ4 := 0
        nquot := Quot->Qty
        mmod1 := Trim( Quot->Partnum )
        SELECT Equ
        SET EXACT ON
        GOTO TOP
        nrecno1 := RecNo()
        SEEK mmod1
        IF Found()
            nrecno1 := RecNo()
            DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
                IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                    SKIP ALIAS Equ
                    LOOP
                ENDIF
            /*
            IF mxy = "N"
               IF SUBSTR( Equ->Modcode, 1, 2 ) = "XY"
                  SKIP ALIAS Equ
                  LOOP
               ENDIF
            ENDIF
            */
                nqty1 := Equ->PartQty
                nequ1 := nqty1 * nquot
                SELECT Status
                SET ORDER TO 1               // Invno
                GOTO TOP
                SEEK Debit->Invno + Equ->Partnum  // +Equ->Modcode
                ApFLock( 3 )
                IF !Found()
                    @ 10, 3 SAY Debit->Invno + " " + Equ->Partnum;
                        + " " + Equ->Modcode + " Level 1" COLOR "G+"
                    APPEND BLANK
                    Status->Partnum  := Equ->Partnum
                    Status->Invno    := Debit->Invno
                ENDIF
                Status->Required := nequ1
                Status->Equlevel := "1"
                IF Status->Modcode = Space( 16 )
                    Status->Modcode := Equ->Modcode
                ENDIF
                UNLOCK
                SELECT Equ
                mmod2   := Trim( Equ->Partnum )
                nrecno2 := RecNo()
                GOTO TOP
                SEEK mmod2
                IF Found()
                    DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                        IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                            SKIP ALIAS Equ
                            LOOP
                        ENDIF
            /*
            IF mxy = "N"
               IF SUBSTR( Equ->Modcode, 1, 2 ) = "XY"
                  SKIP ALIAS Equ
                  LOOP
               ENDIF
            ENDIF
            */
                        nqty2 := Equ->PartQty
                        nequ2 := ( nqty1 * nqty2 ) * nquot
                        SELECT Status
                        SET ORDER TO 1               // Invno
                        GOTO TOP
                        SEEK Debit->Invno + Equ->Partnum // +Equ->Modcode
                        ApFLock( 3 )
                        IF !Found()
                            @ 11, 3 SAY Debit->Invno + " " + Equ->Partnum;
                                + " " + Equ->Modcode + " Level 2" COLOR "RG+"
                            APPEND BLANK
                            Status->Partnum  := Equ->Partnum
                            Status->Invno    := Debit->Invno
                        ENDIF
                        Status->Required += nequ2
                        Status->Equlevel := "2"
                        IF Status->Modcode = Space( 16 )
                            Status->Modcode  := Equ->Modcode
                        ENDIF
                        UNLOCK
                        SELECT Equ
                        mmod3   := Trim( Equ->Partnum )
                        nrecno3 := RecNo()
                        GOTO TOP
                        SEEK mmod3
                        IF Found()
                            DO WHILE  Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                    SKIP ALIAS Equ
                                    LOOP
                                ENDIF
            /*
            IF mxy = "N"
               IF SUBSTR( Equ->Modcode, 1, 2 ) = "XY"
                  SKIP ALIAS Equ
                  LOOP
               ENDIF
            ENDIF
            */
                                nqty3 := Equ->PartQty
                                nequ3 := nqty1 * nqty2 * nqty3 * nquot
                                SELECT Status
                                SET ORDER TO 1               // Invno
                                GOTO TOP
                                SEEK Debit->Invno + Equ->Partnum   // +Equ->Modcode
                                ApFLock( 3 )
                                IF !Found()
                                    @ 12, 3 SAY Debit->Invno + " " + Equ->Partnum;
                                        + " " + Equ->Modcode + " Level 3" COLOR "BG+"
                                    APPEND BLANK
                                    Status->Partnum  := Equ->Partnum
                                    Status->Invno    := Debit->Invno
                                ENDIF
                                Status->Required += nequ3
                                Status->Equlevel := "3"
                                IF Status->Modcode = Space( 16 )
                                    Status->Modcode  := Equ->Modcode
                                ENDIF
                                UNLOCK
                                SELECT Equ
                                mmod4   := Trim( Equ->Partnum )
                                nrecno4 := RecNo()
                                nqty4   := 0
                                GOTO TOP
                                SEEK mmod4
                                IF Found()
                                    DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                        IF SubStr( Equ->Partnum, 1, 2 ) = "ZZ"
                                            SKIP ALIAS Equ
                                            LOOP
                                        ENDIF
               /*
               IF mxy = "N"
                  IF SUBSTR( Equ->Modcode, 1, 2 ) = "XY"
                     SKIP ALIAS Equ
                     LOOP
                  ENDIF
               ENDIF
               */
                                        nqty4 := Equ->PartQty
                                        nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
                                        SELECT Status
                                        SET ORDER TO 1               // Invno
                                        GOTO TOP
                                        SEEK Debit->Invno + Equ->Partnum  // +Equ->Modcode
                                        ApFLock( 3 )
                                        IF !Found()
                                            @ 13, 3 SAY Debit->Invno + " " + Equ->Partnum;
                                                + " " + Equ->Modcode + " Level 4" COLOR "R+"
                                            APPEND BLANK
                                            Status->Partnum  := Equ->Partnum
                                            Status->Invno    := Debit->Invno
                                        ENDIF
                                        Status->Required += nequ4
                                        Status->Equlevel := "4"
                                        IF Status->Modcode = Space( 16 )
                                            Status->Modcode  := Equ->Modcode
                                        ENDIF
                                        UNLOCK
                                        SELECT Equ
                                        SKIP ALIAS Equ
                                    ENDDO                       // mmod4
                                ENDIF                         // Found
                                SELECT Equ
                                GOTO nrecno4
                                SKIP ALIAS Equ
                            ENDDO                       // mmod3
                        ENDIF                          // FOUND()  mmod3
                        SELECT Equ
                        GOTO nrecno3
                        SKIP ALIAS Equ
                    ENDDO                       // mmod2
                ENDIF                          // FOUND()  mmod2
                SELECT Equ
                GOTO nrecno2
                SKIP ALIAS Equ
            ENDDO                       // mmod1
        ENDIF                          // FOUND()  mmod1
        SET EXACT OFF
        SELECT Quot
        SKIP ALIAS Quot
    ENDDO                                // EOF Quot

    SELECT Part
    SET ORDER TO 1                    // Partnum
    SELECT Status
    SET ORDER TO 1                    // Codeno
    GOTO TOP
    DO WHILE Status->( !Eof() )
        SELECT Part
        SEEK Status->Partnum
        SELECT Status
        ApFLock( 3 )
        IF Part->Codeno = Control->U_Codeno
            Status->Codeno := "Z" + Control->U_Codeno
        ELSE
            IF SubStr( Part->Partnum, 1, 2 ) = "XY"
                Status->Codeno := "Y" + Part->Codeno
            ELSE
                Status->Codeno := Part->Codeno
            ENDIF
        ENDIF
        Status->Qty := Part->Instock
        UNLOCK
        SKIP ALIAS Status
    ENDDO                               // Status EOF
    SELECT Quot
    SET ORDER TO 1
    IF PressedEsc()
        RETURN NIL
    ENDIF

    RETURN NIL
// ***--------------------------- Quotupdate

// **----------------------------------------------------------------------

FUNCTION QuotTot()

   /*
   SELECT Status
   IF LASTREC() = 0
      mok := "Y"
     ELSE
      mok := ApGetN( "Update Files New JC etc" )
   ENDIF
   IF mok = "Y"
      SCROLL()
      QuotUpDate()
   ENDIF
   */

    manother := "Y"
    DO WHILE manother = "Y"
        Scroll(  20, 0, 24, 80 )
        DispBox( 20, 0, 24, 79, 2 )
        nselect := 1
        @ 20, 54 SAY " - Parts Required - " COLOR "G+"
        @ 22, 5      PROMPT "One Job Card Only"
        @ 22, Col() + 2 PROMPT "One Part Only"
        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nselect == 1
            QuotFind()                     // Below
            mwhere := "S"

            Printsel()

            IF mwhere = "P"
                npl := 56
            ELSE
                npl := 18
                Scroll()
            ENDIF

            QuotStatH1()                              // Below
            nl := 4
            nsumrequired := noutcost := nreqstock := 0
            SELECT Status
            SET ORDER TO 1            // Invno
            GOTO TOP
            SEEK minvno
            DO WHILE Status->Invno = minvno .AND. Status->( !Eof() )
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                    QuotStatH1()                         // Below
                    nl := 4
                ENDIF
                SELECT Part
                SET ORDER TO 1
                SEEK Status->Partnum
                SELECT Status
                IF Trim( Status->Partnum ) = Trim( Message->LabPart )
                    SKIP ALIAS Status
                    LOOP
                ENDIF
                IF SubStr( Status->Partnum, 1, 2 ) = "ZZ"
                    @ nl, 0 SAY SubStr( Status->Partnum, 1, 16 )
                    @ nl, 19 SAY Part->Desc
                    @ nl, 69 SAY "Out Work ZZ"
                    nl++
                    SKIP ALIAS Status
                    LOOP
                ENDIF
                IF Part->Boughtout != "Y"
                    @ nl, 0 SAY SubStr( Status->Partnum, 1, 16 )
                    @ nl, 19 SAY Part->Desc
                    @ nl, 69 SAY "In House"
                    nl++
                    SKIP ALIAS Status
                    LOOP
                ENDIF
                mqtyrec := mpartqty := noutQty := 0
                mpartnum := Status->Partnum
                DO WHILE Status->Invno = minvno .AND. ;
                        Status->Partnum = mpartnum .AND. ;
                        Status->( !Eof() )
                    noutQty += Status->Required - Status->Received
                    SKIP ALIAS Status
                ENDDO
                @ nl, 0 SAY SubStr( mpartnum, 1, 16 )
                @ nl, 19 SAY SubStr( Part->Desc, 1, 23 )
                @ nl, 46 SAY noutQty                      PICTURE "9999.999"
                @ nl, 56 SAY Part->Instock                PICTURE "9999.99"
                IF ( noutQty - Part->Instock ) > 0
                    @ nl, 64 SAY ( noutQty - Part->Instock ) PICTURE "9999.99"
                ENDIF
                SELECT Orders
                SET ORDER TO 1                     // OrdPart
                SEEK mpartnum
                IF Found()
                    DO WHILE Orders->Partnum = mpartnum .AND. Orders->( !Eof() )
                        mpartqty += Orders->Partqty
                        mqtyrec  += Orders->Qtyrec
                        SKIP ALIAS Orders
                    ENDDO
                    IF mpartqty - mqtyrec > 0
                        @ nl, 72 SAY mpartqty - mqtyrec     PICTURE "9999.999"
                    ENDIF
                ENDIF                                                    // mrequired
                nl++
                SELECT Status
            ENDDO
            IF mwhere = "S"
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ELSE
                EndPrint()
            ENDIF

        CASE nselect = 2                    // Part Selected
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
                mpartnum := Space( 20 )
                SELECT Status
                SET ORDER TO 2                       // Partnum
                GOTO TOP
                aPart_ := {}
                anum := {}
                nrecno := 0
                Scroll()
                mtempno := Space( 20 )
                DO WHILE Status->( !Eof() )
                    IF Status->Required <= 0
                        SKIP ALIAS Status
                        LOOP
                    ENDIF
                    SELECT Part
                    SEEK Status->Partnum
                    IF Part->Boughtout != "Y"
                        SKIP ALIAS Status
                        LOOP
                    ENDIF
                    IF SubStr( Status->Partnum, 1, 2 ) = "ZZ"
                        SKIP ALIAS Status
                        LOOP
                    ENDIF
                    SELECT Status
                    IF Status->Partnum = mtempno
                        SKIP ALIAS Status
                        LOOP
                    ENDIF
                    nQty := 0
                    mpartnum := Part->Partnum
                    DO WHILE Status->Partnum = mpartnum .AND. Status->( !Eof() )
                        nQty += Status->Required - Status->Received
                        SKIP ALIAS Status
                    ENDDO
                    SELECT Part
                    ApRLock( 3 )
                    Part->ReqQty := nQty
                    UNLOCK
                    mtempno := Part->Partnum
                    AAdd( aPart_, SubStr( Part->Partnum, 1,16 );
                        + "  " + SubStr( Part->Desc, 1, 30 );
                        + " " + Str( Part->ReqQty, 10, 3 );
                        + " " + Str( Part->Instock, 10, 3 );
                        + " " + SubStr( Part->Unit, 1, 6 );
                        + "      " + Str( RecNo(), 6 ) )
                    SELECT Status
                    // **     SKIP ALIAS Status
                ENDDO
                IF !Empty( aPart_ )
                    DispBox( 0, 1, 24, 79, 2 )
                    @ 0, 50 SAY " --- Required   Instock --- "
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice( 1, 3, 23, 78, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ], 6 ) )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    SELECT Part
                    GOTO nrecno
                    mpartnum := Part->Partnum
                    Scroll()
                    nl := 1
                    @ nl, 5 SAY "Part Required"
                    nl += 2
                    nTotal := 0
                    @ nl, 2 SAY mpartnum + "  " + Trim( Part->Desc ) + "  " + Part->Codeno
                    nl += 2
                    SELECT Status
                    SET ORDER TO 2                        // Partnum
                    GOTO TOP
                    SEEK mpartnum
                    DO WHILE Status->Partnum = mpartnum .AND. Status->( !Eof() )
                        IF Status->Required <= 0
                            SKIP ALIAS Status
                            LOOP
                        ENDIF
                        @ nl, 0 SAY SubStr( mpartnum, 1, 16 )
                        @ nl, 17 SAY SubStr( Status->Modcode, 1, 16 )
                        @ nl, 34 SAY SubStr( Part->Desc, 1, 25 )
                        @ nl, 60 SAY Status->Required - Status->Received PICTURE "9,999.999" COLOR "G+"
                        @ nl, 71 SAY Status->Invno
                        nTotal += Status->Required - Status->Received
                        nl++
                        SKIP ALIAS Status
                    ENDDO
                    nl++
                    @ nl, 5 SAY Trim( Part->Unit ) + "  " + mpartnum + "  Required = " + Str( nTotal, 8, 3 ) COLOR "G+"
                    nl += 2
                    mpartqty := mqtyRec := 0
                    SELECT Orders
                    SET ORDER TO 1                     // OrdPart
                    SEEK mpartnum
                    IF Found()
                        mOrdCode := Orders->Codeno
                        DO WHILE Orders->Partnum = mpartnum .AND. Orders->( !Eof() )
                            mPartQty += Orders->Partqty
                            mQtyRec  += Orders->Qtyrec
                            SKIP ALIAS Orders
                        ENDDO
                        // **        IF mpartqty > 0
                        @ nl, 5      SAY "Parts on Order"
                        @ nl, Col() + 1 SAY mPartQty PICTURE "9999.999" COLOR "G+"
                        @ nl, Col() + 2 SAY "Received"
                        @ nl, Col() + 1 SAY mQtyRec PICTURE "9999.999"
                        @ nl, Col() + 2 SAY mOrdCode
                        // **         ENDIF
                    ENDIF                                     // Found
                    nl += 2
                    SELECT Part
                    ApRLock( 3 )
                    @ nl, 5 SAY Trim( Part->Unit ) + " Parts In Stock" GET Part->Instock PICTURE "999999.999"
                    READ
                    UNLOCK
                    SELECT Status
                ENDIF                            // Empty
                mcontinue := ApGetY( "Another Part" )
            ENDDO
        ENDCASE
        SELECT Status
        SET INDEX TO StatJob

        manother := ApGetN( Trim( Message->Another ) + " Selection"  )

    ENDDO

    RETURN NIL
// ***------ End QuotTot

// *----------------------------------------------------------------------------

STATIC FUNCTION QuotStatH1()

    @  0, 0 SAY Trim( Control->U_Name ) + " Parts Required for Jobs"
    @  0, 63 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 0 SAY "Job Card"
    @  2, 10 SAY  minvno
    // ** @  2,20 SAY nquot
    @  2, 20 SAY "Dated"
    @  2, 26 SAY Debit->DBDate
    @  2, 38 SAY Debit->Est
    @  2, 66 SAY Debit->Codeno
    @  3, 0 SAY "Part"
    @  3, 19 SAY "Description"
    @  3, 50 SAY "Req"
    @  3, 56 SAY "Instock"
    @  3, 67 SAY "Diff"
    @  3, 73 SAY "Order"

    RETURN NIL
// ***------ End QuotStatH1

// ***-----------------------------------------------------------------------

FUNCTION QuotFind()

    mcodeno := Space( 8 )
    SELECT Quot
    aPart_ := anum := {}
    nrecno := ntotal := 0
    Scroll()
    // **   DISPBOX( 0,45, 4,75, 2 )
    // **   @  1,47 SAY "Select Name"
    // **   @  2,47 SAY "Branch Specific"
    GOTO TOP
    mtempno := Space( 10 )
    DO WHILE Quot->( !Eof() )
        IF Quot->Invno = Space( 6 )
            SKIP ALIAS Quot
            LOOP
        ENDIF
        IF Quot->Codeno + Quot->BranchId = mtempno
            SKIP ALIAS Quot
            LOOP
        ENDIF
        SELECT Name
        SEEK Quot->Codeno
        SELECT Debit
        SET ORDER TO 2                  // Invno
        SEEK Quot->Invno
        SELECT Quot
        mtempno := Quot->Codeno + Quot->BranchId
        AAdd( aPart_, Name->Name + " " + DToC( Debit->StartDate );
            + "       " + Quot->Invno + "     " + Str( RecNo(), 6 ) )
        SKIP ALIAS Quot
    ENDDO
    @ 10, 49 SAY "F2 To View ALL Job Cards"        COLOR "GB+"
    DispBox( 0, 2, 24, 47, 2 )
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 1, 4, 23, 45, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        IF PressedEsc()
            RETURN NIL
        ENDIF
        GOTO nrecno
        mcodeno := Quot->Codeno
    ENDIF                            // Empty
    IF LastKey() == -1
        SELECT Debit
        SET ORDER TO 1
        GOTO TOP
        IF LastRec() != 0
            aPart_ := {}
            nrecno := 0
            DO WHILE Debit->( !Eof() )
                IF Debit->Stat != "J"
                    SKIP ALIAS Debit
                    LOOP
                ENDIF
                AAdd( aPart_, Debit->Invno + " " + Debit->Stat;
                    + " " + Debit->Codeno;
                    + " " + Debit->BranchId;
                    + " " + DToC( Debit->Dbdate );
                    + " " + Str( Debit->Amount, 10, 2 ) + " " + Debit->Saleno;
                    + " " + Debit->Est + "    " + Str( RecNo(), 6 ) )
                SKIP ALIAS Debit
            ENDDO
            IF !Empty( aPart_ )
                Scroll()
                DispBox(  0, 1, 24, 79, 2 )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice(  1, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
                nrecno := Val( Right( aPart_[ anum ], 6 ) )
                GOTO nrecno
                minvno := Debit->Invno
            ENDIF                     // Empty
        ENDIF                        // LastRec
    ELSE
        SELECT Debit
        SET ORDER TO 1              // Codeno
        GOTO TOP
        SEEK mcodeno
        aPart_ := {}
        nrecno := 0
        DO WHILE Debit->Codeno = mcodeno .AND. Debit->( !Eof() )
            IF Debit->Stat != "J"
                SKIP ALIAS Debit
                LOOP
            ENDIF
            AAdd( aPart_, Debit->Invno + " " + Debit->Stat;
                + " " + Debit->Codeno;
                + " " + Debit->BranchId;
                + " " + DToC( Debit->Dbdate );
                + " " + Str( Debit->Amount, 10, 2 ) + " " + Debit->Saleno;
                + " " + Debit->Est + "                        " + Str( RecNo(), 6 ) )
            SKIP ALIAS Debit
        ENDDO
        IF !Empty( aPart_ )
            Scroll()
            DispBox(  0, 1, 24, 79, 2 )
            ASort( aPart_,,, {| x, y | x < y } )
            anum   := AChoice(  1, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
            GOTO nrecno
            minvno := Debit->Invno
        ENDIF                     // Empty
    ENDIF                 // LastKey = -1

    RETURN NIL
// ***------------ End of QuotFind

// ****---------- END OF FILE XLF_QU7.PRG
