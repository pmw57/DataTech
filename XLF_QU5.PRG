// **  JK 16-09-11 21:42:44

/*  Program.....:                  XLF_QU5.PRG
    Authors.....: J.Kirby
    Date........: 18/05/2002
    Functions...: LabourWO, LabOper, JCutList, LabPart, LabWOInv
                : PlanEditKey, planninglist
*/

FUNCTION PlanningList()

    cpriority := Space( 8 )
    SELECT Operate
    aPart_ := {}
    nrecno := 0
    coperno := Debit->Operno
    GOTO TOP
    SEEK coperno
    IF Found()
        DO WHILE Operate->Operno = coperno .AND. Operate->( !Eof() )
            // **              IF Operate->ABC = " "
            // +**                  SKIP ALIAS Operate
            // **                  LOOP
            // **              ENDIF
            AAdd( aPart_, Operate->Priority;
                + " " + Operate->Desc;
                + "          " + Str( RecNo(), 6 ) )
            SKIP ALIAS Operate
        ENDDO
    ENDIF              // Found
    Scroll( 0, 27, 24, 80 )
    DispBox(  0, 27, 24, 79, 2 )
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 1, 29, 23, 78, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        GOTO nrecno
        cpriority := SubStr( Operate->Priority, 1, 4 )
        IF LastKey() == 27
            RETURN NIL
        ENDIF
    ENDIF                   // Empty
    aPart_ := {}
    nrecno := 0
    GOTO TOP
    SEEK coperno
    IF Found()
        DO WHILE Operate->Operno = coperno .AND. Operate->( !Eof() )
            IF SubStr( Operate->Priority, 1, 4 ) != cpriority
                SKIP ALIAS Operate
                LOOP
            ENDIF
            // **           IF Operate->ABC != " "
            // **               SKIP ALIAS Operate
            // **               LOOP
            // **           ENDIF
            AAdd( aPart_, Operate->Priority;
                + " " + Operate->Desc;
                + "                    " + Str( RecNo(), 6 ) )
            SKIP ALIAS Operate
        ENDDO
    ENDIF              // Found
    Scroll( 0, 27, 24, 80 )
    DispBox(  0, 27, 24, 79, 2 )
    @ 0, 43 SAY "  " + cpriority + "    " + Debit->Operno + "  " COLOR "G+"
    IF !Empty( aPart_ )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 1, 29, 23, 78, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        GOTO nrecno
        IF LastKey() == 27
            RETURN NIL
        ENDIF
        // **      cdesc := Operate->Desc
    ENDIF                   // Empty
    Scroll( 15, 0, 24, 80 )
    DispBox( 15, 2, 24, 79, 2 )
    @ 15, 43 SAY "  " + cpriority + "    " + Debit->Operno + "  " COLOR "G+"
    mnew := "N"
    cdesc := mdesc := Operate->Desc
    cprior := Operate->Priority
    cprint := Operate->Print
    @ 17, 10      SAY Operate->Desc COLOR "BG+"
    @ 19, 10      SAY "Is this New Planning N/Y" GET mnew;
        VALID( mnew $ "NY" ) PICTURE "!"
    READ
    IF mnew = "Y"
        cprior := SubStr( Debit->Operno, 1, 2 ) + Space( 6 )
        cdesc  := Space( 40 )
        @ 21, 10 GET cdesc PICTURE "@X"
    ELSE
        @ 21, 10 GET cdesc PICTURE "@X"
    ENDIF
    @ 22, 10      GET cprior PICTURE "@!"
    @ 22, Col() + 2 SAY "Print This P/ " GET cprint;
        VALID( cprint $ "P " ) PICTURE "!"
    READ
    SELECT Labour
    ApFLock( 3 )
    Labour->Invno   := minvno
    Labour->Jobnum  := cprior
    Labour->Desc    := cdesc
    Labour->Message := mmessage
    Labour->Fault   := mfault
    Labour->Time    := mtime
    Labour->Date    := dDate
    UNLOCK
    SELECT Control
    ApRLock( 3 )
    Control->LastRoll := dDate
    UNLOCK
    SELECT Operate
    IF mnew = "Y"
        ApFLock( 3 )
        APPEND BLANK
        Operate->Order    := Upper( SubStr( cdesc, 1, 2 ) )
        Operate->Operno   := Debit->Operno
        Operate->Priority := cprior
        Operate->Date     := Date()
        Operate->Desc     := cdesc
        Operate->Print    := cprint
        Operate->Ckey     := cprior
        UNLOCK
    ELSE
        ApRLock( 3 )
        Operate->Desc     := cdesc
        Operate->Priority := cprior
        Operate->Print    := cprint
        Operate->Ckey     := cprior
        UNLOCK
    ENDIF

    RETURN( mcodeno )

// ***----- End of PlanList()

// **---------------------------------------------------------------------------


FUNCTION PartOperADD()

    manother = "Y"
    DO WHILE manother = "Y"
        aPart_ := {}
        nrecno := 0
        SELECT PartOper
        SET ORDER TO 2
        GOTO TOP
        DO WHILE PartOper->( !Eof() )
            IF PartOper->Operno = Space( 8 )
                SKIP ALIAS PartOper
                LOOP
            ENDIF
            AAdd( aPart_, ( PartOper->Desc + " " + PartOper->Adminno;
                + " " + PartOper->Operno;
                + "                    " + Str( RecNo(), 6 ) ) )
            SKIP ALIAS PartOper
        ENDDO
        IF !Empty( aPart_ )
            Scroll()
            DispBox(  0, 0, 24, 79, 2 )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 1, 3, 23, 76, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            IF LastKey() == 27
                RETURN NIL
            ENDIF
            coperno := PartOper->Operno
            cfind   := PartOper->Adminno
            mdesc   := PartOper->Desc
            mdesc1  := PartOper->Desc1
            myes := "N"
            Scroll( 14, 0, 24, 80 )
            DispBox( 14, 0, 24, 79, 2 )
            @ 16, 10      SAY "Operno"  GET coperno PICTURE "@!"
            @ 16, Col() + 2 SAY "Adminno" GET cfind   PICTURE "@!"
            @ 18, 5      GET mdesc  PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            @ 19, 5      GET mdesc1 PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            @ 19, Col() + 2 SAY "Is this New" GET myes VALID( myes $ "NY" ) PICTURE "@!"
            READ
            IF LastKey() == 27
                RETURN NIL
            ENDIF
            // **      READ
            SELECT PartOper
            ApFLock( 3 )
            IF myes = "Y"
                APPEND BLANK
            ENDIF
            PartOper->Operno  := coperno
            PartOper->Order   := Upper( SubStr( cfind, 1, 1 ) );
                + Upper( SubStr( mdesc, 1, 1 ) )
            PartOper->Adminno := cfind
            PartOper->Date    := Date()
            PartOper->Desc    := mdesc
            PartOper->Desc1   := mdesc1
            UNLOCK
        ENDIF
        manother := ApGetY( "Do you want Another" )

    ENDDO                                        // manother

    RETURN

// ***------------ End of PartOperAdd()

// **---------------------------------------------------------------------

FUNCTION PlanEditKey()

    coperno := Space( 8 )
    GroupSelect( @coperno )         // XLF_QU9.Prg
    manother = "Y"
    DO WHILE manother = "Y"
        aPart_ := {}
        nrecno  := 0
        SELECT Operate
        GOTO TOP
        SEEK coperno
        DO WHILE Operate->Operno = coperno .AND. Operate->( !Eof() )
            AAdd( aPart_, Operate->Priority;
                + " " + Operate->Desc;
                + " " + Operate->Operno;
                + " " + Operate->ABC;
                + " " + Operate->Print;
                + "                     " + Str( RecNo(), 6 ) )
            SKIP ALIAS Operate
        ENDDO                        // PartOper EOF
        // **                   +" "+Operate->Ckey;
        // **                   +" "+Operate->Order;
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            Scroll()
            DispBox( 0, 0, 24, 79, 2 )
            @  0, 4 SAY " BLANK TO DELETE  " COLOR "RG+"
            @  0, 35 SAY " Esc to Exit  "     COLOR "BG+"
            @  0, 56 SAY " Heading  Print"  COLOR "BG+"
            // **      @  0,70 SAY "  "+coperno+"  "         COLOR "BG+"
            anum := AChoice(  1, 3, 23, 78, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
/*
         cdesc    := Operate->Desc
         ckey     := Operate->Ckey   // Priority
         cabc     := Operate->ABC
         cprint   := Operate->Print
*/
            SELECT Operate
            ApRLock( 3 )
            @ Row(), 2 GET Operate->Priority  PICTURE "!!!!!!!!"
            @ Row(), 11 GET Operate->Desc  PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            @ Row(), 63 GET Operate->Abc   PICTURE "!"
            @ Row(), 67 GET Operate->PRINT PICTURE "!"
            READ
            UNLOCK
/*
         SELECT Operate
          ApRLock( 3 )
         Operate->Priority := ckey
         Operate->Ckey     := ckey
         Operate->Desc     := cdesc
         Operate->ABC      := cabc
         Operate->Print    := cprint
         UNLOCK
*/
            IF Operate->CKey = Space( 8 )
                ApFLock( 3 )
                DELETE
                UNLOCK
            ENDIF
        ENDIF                        // Empty
        IF LastKey() = 27
            EXIT
        ENDIF
        LOOP
    ENDDO                         // manother

    RETURN

// **--- End PlanEditKey()

// ****-------------------------------------------------------------------------

FUNCTION LabourWO()

    mdesc := cDesc := "Add as per JC-  "
    minvno  := "AA    "
    mcodeno := Space( 8 )
    dDate   := Control->LastRoll
    SELECT Name
    GOTO TOP
    aPart_ := {}
    nrecno := 0
    IF LastRec() != 0
        DO WHILE  Name->( !Eof() )
            IF Name->Sale != "STAF"
                SKIP ALIAS Name
                LOOP
            ENDIF
            AAdd( aPart_, Name->Codeno + "   " + SubStr( Name->Name, 1,26 );
                + " " + Name->Add1;
                + "                   " + Str( RecNo(), 6 ) )
            SKIP ALIAS Name
        ENDDO
        Scroll()
        DispBox( 0, 0,  2, 79, 2 )
        @  1, 6 SAY "Adding Labour"
        @  1, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        DispBox( 3, 0, 23, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aCatcode_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 22, 77, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            IF LastKey() == 27
                RETURN
            ENDIF
            GOTO nrecno
            mcodeno := Name->Codeno
            @  1, 21 SAY Trim( Name->Name ) COLOR "BG+"
        ENDIF
    ENDIF           // LastRec
    aPart_ := {}
    nDays := 6
    SELECT Labour
    SET ORDER TO 1            // Codeno
    GOTO TOP
    SEEK mcodeno
    DO WHILE Labour->Codeno = mcodeno .AND. Labour->( !Eof() )
        IF Labour->Partnum != Space( 20 )
            SKIP ALIAS Labour
            LOOP
        ENDIF
        IF Labour->Date < ( Date() -nDays )            // nDays
            SKIP ALIAS Labour
            LOOP
        ENDIF
        AAdd( aPart_, DToC( Labour->Date );
            + " " + Labour->Operno;
            + " " + Labour->Desc;
            + " " + Labour->Invno;
            + " " + Str( Labour->Time, 6, 2 ) )
        SKIP ALIAS Labour
    ENDDO                        // Labour EOF
    IF !Empty( aPart_ )
        Scroll()
        DispBox( 0, 0, 2, 79, 2 )
        @  1, 10 SAY Name->Name COLOR "BG+"
        @  1, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        DispBox( 3, 1, 24, 79, 2 )    // This is Special
        ASort( aPart_,,, {| x, y | x < y } )
        @  3, 00 SAY " "
        AEval( aPart_, {|A| QOUT( " " + Chr( 186 ) + "  " ), QQOut( A ), Breakpoint() } )
    ENDIF                        // Empty

    manother = "Y"
    DO WHILE manother = "Y"
        Scroll(  19, 0, 24, 80 )
        DispBox( 19, 0, 24, 79, 2 )
        nselect := 1
        @ 19, 6      SAY " --- Adding Labour --- "
        @ 21, 5      PROMPT "1. Add New"
        @ 21, Col() + 2 PROMPT "2. Another Name"
        @ 21, Col() + 2 PROMPT "3. Edit/Del Labour"
        @ 21, Col() + 2 PROMPT "4. Edit All"
        @ 23, 5      PROMPT "5. Print Indiv"
        @ 23, Col() + 2 PROMPT "6. Print All Names"
        @ 23, Col() + 2 PROMPT "7. Indiv File"
        @ 23, Col() + 2 PROMPT "8. Exit"
        @ 24, 60 SAY " DT14- "
        // **   @ 23,COL()+2 PROMPT "7. Edit Key Desc"

        MENU TO nselect
        DO CASE
        CASE nselect == 8 .OR. LastKey() == 27
            RETURN
        CASE nselect == 7
            LabourChri()
            LOOP
        CASE nselect == 1                // ADD NEW
            ccode := Name->Codeno
            cfind := Space( 8 )
            mcorrect := "N"
            DO WHILE mcorrect == "N"
                Scroll(  10, 0, 24, 80 )
                DispBox( 10, 0, 22, 79, 2 )
                SELECT Name
                @ 12, 10      SAY Name->Name + "  " + Debit->Operno COLOR "RG+"
                @ 14, 10      SAY "Invno"    GET mInvno  PICTURE "@!"
                @ 14, Col() + 2 SAY "AA by Name - Blank to View JC-"
                READ
                IF LastKey() == 27
                    RETURN
                ENDIF
                IF SubStr( mInvno, 1, 2 ) = "AA"
                    aPart_  := {}
                    anum    := {}
                    nrecno  := 0
                    mtempno := Space( 8 )
                    SELECT Quot
                    SET ORDER TO 1      // Codeno
                    GOTO TOP
                    DO WHILE Quot->( !Eof() )
                        IF Quot->Codeno = mtempno
                            SKIP ALIAS Quot
                            LOOP
                        ENDIF
                        IF Quot->Invno = Space( 6 )
                            SKIP ALIAS Quot
                            LOOP
                        ENDIF
                        SELECT Name
                        SEEK Quot->Codeno
                        SELECT Quot
                        mtempno := Quot->Codeno
                        AAdd( aPart_, Name->Name;
                            + "               " + Str( RecNo(), 6 ) )
                        SKIP ALIAS Quot
                    ENDDO                   // Quot
                    IF !Empty( aPart_ )
                        Scroll()
                        DispBox( 0, 0, 24, 39, 2 )
                        @ 12, 40 SAY Trim( Name->Name ) COLOR "BG+"
                        ASort( aPart_,,, {| x, y | x < y } )
                        anum := AChoice( 1, 3, 23, 36, aPart_,, "AFUNC" )
                        nrecno := Val( Right( aPart_[ anum ],6 ) )
                        IF LastKey() == 27
                            RETURN NIL
                        ENDIF
                        GOTO nrecno
                        mtempno := Quot->Codeno
                        SELECT Debit
                        GOTO TOP
                        IF LastRec() != 0
                            aPart_ := {}
                            nrecno := 0
                            DO WHILE Debit->( !Eof() )
                                // **            IF SUBSTR( Control->U_Name, 1, 4 ) = "MET"
                                IF Debit->Stat != "J"
                                    SKIP ALIAS Debit
                                    LOOP
                                ENDIF
                                // **            ENDIF
                                IF Debit->Codeno != mtempno
                                    SKIP ALIAS Debit
                                    LOOP
                                ENDIF
                                AAdd( aPart_, Debit->Invno + " " + Debit->Stat;
                                    + " " + Debit->Equip;
                                    + " " + Debit->Codeno;
                                    + " " + DToC( Debit->Dbdate );
                                    + " " + Debit->Est + " " + Debit->Operno;
                                    + "                        " + Str( RecNo(), 6 ) )
                                SKIP ALIAS Debit
                            ENDDO               // Debit
                            IF !Empty( aPart_ )
                                Scroll()
                                DispBox(  0, 0, 24, 79, 2 )
                                ASort( aPart_,,, {| x, y | x < y } )
                                anum   := AChoice(  1, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
                                nrecno := Val( Right( aPart_[ anum ], 6 ) )
                                GOTO nrecno
                                minvno  := Debit->Invno
                                mtempno := Debit->Codeno
                                coperno := Debit->Operno
                                cdesc   := Debit->Est
                            ENDIF                     // Empty
                        ENDIF                        // LastRec
                        SELECT Name
                        SEEK ccode
                    ENDIF                      // Empty

                ELSE                                // Not AA

                    SELECT Debit
                    SET ORDER TO 2                 // Invno
                    SEEK mInvno
                    SET ORDER TO 1
                    IF Found()
                        minvno := Debit->Invno
                        cDesc  := Debit->Est
                    ENDIF
                    IF !Found() .OR. minvno = Space( 6 )
                        SELECT Debit
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
                                    + " " + DToC( Debit->Dbdate );
                                    + " " + Str( Debit->Amount, 9, 2 ) + " " + Debit->Saleno;
                                    + " " + Debit->Est + "                        " + Str( RecNo(), 6 ) )
                                SKIP ALIAS Debit
                            ENDDO
                            IF !Empty( aPart_ )
                                Scroll(   3, 0, 24, 80 )
                                DispBox(  3, 0, 24, 79, 2 )
                                ASort( aPart_,,, {| x, y | x < y } )
                                anum   := AChoice(  4, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
                                IF LastKey() == 27
                                    RETURN
                                ENDIF
                                nrecno := Val( Right( aPart_[ anum ], 6 ) )
                                GOTO nrecno
                                minvno := Debit->Invno
                                cdesc  := Debit->Est
                            ENDIF                     // Empty
                        ENDIF                        // LastRec
                    ENDIF                   // Invno SPACE()
                ENDIF                 // mInvno
                SELECT Labour
                ApFLock( 3 )
                APPEND BLANK
                Labour->Codeno  := mcodeno     // Debit->Codeno
                Labour->Date    := dDate
                Labour->Invno   := minvno
                Labour->Labno   := Debit->Codeno
                Labour->Operno  := Debit->Operno
                Labour->Desc    := mdesc
                Labour->Message := cdesc
                Labour->Time    := 1
                UNLOCK
                Scroll(  10, 0, 24, 80 )
                DispBox( 10, 0, 24, 79, 2 )
                dDate    := Control->LastRoll     // DATE()-1
                minvno   := Labour->Invno
                mdesc    := Labour->Desc
                mmessage := Labour->Message
                mfault   := Labour->Fault
                mtime    := Labour->Time
                cselect := "  "
                @ 11, 4      SAY Name->Name COLOR "RG+"
                @ 13, 4      SAY Debit->Codeno + " JC- Invno " + minvno COLOR "BG+"
                @ 13, Col() + 3 SAY Debit->Operno COLOR "RG+"
                @ 14, 4      SAY Trim( mmessage ) COLOR "BG+"
                @ 16, 4      SAY "Time Hrs" GET mtime       PICTURE "9999.99"
                @ 16, Col() + 2 SAY "Date"     GET dDate       PICTURE "99/99/9999"
                @ 16, Col() + 2 SAY "XX For All" GET cselect PICTURE "!!"
                @ 18, 4      SAY "Check Date      Today"    COLOR "BG+"
                @ 18, Col() + 1 SAY DToC( Date() )             COLOR "RG+"
                READ
                moperate := "N"
                IF moperate = "N"
                    cfind := Space( 12 )
                    DO CASE
                    CASE cselect != "XX"
                        SELECT PartOper
                        SET ORDER TO 1         // Operno
                        aPart_ := {}
                        nrecno := 0
                        GOTO TOP
                        SEEK Debit->Operno
                        IF Found()
                            cadminno := Space( 12 )
                            DO WHILE PartOper->Operno = Debit->Operno .AND. PartOper->( !Eof() )
                                IF PartOper->Operno = Space( 8 )
                                    SKIP ALIAS PartOper
                                    LOOP
                                ENDIF
                                IF PartOper->Adminno = cadminno
                                    SKIP ALIAS PartOper
                                    LOOP
                                ENDIF
                                AAdd( aPart_, ( PartOper->Adminno;
                                    + "        " + Str( RecNo(), 6 ) ) )
                                cadminno := PartOper->Adminno
                                SKIP ALIAS PartOper
                            ENDDO
                            // **       ENDIF              // Found
                            Scroll( 0, 67, 24, 80 )
                            DispBox(  0, 67, 24, 79, 2 )
                            IF !Empty( aPart_ )
                                ASort( aPart_,,, {| x, y | x < y } )
                                anum := AChoice( 1, 69, 23, 78, aPart_,, "AFUNC" )
                                nrecno := Val( Right( aPart_[ anum ],6 ) )
                                GOTO nrecno
                                IF LastKey() == 27
                                    RETURN NIL
                                ENDIF
                                cfind := PartOper->Adminno
                            ENDIF                   // Empty
                            aPart_ := {}
                            nrecno := 0
                            SELECT PartOper
                            SET ORDER TO 1        // Operno
                            GOTO TOP
                            SEEK Debit->Operno
                            DO WHILE PartOper->Operno = Debit->Operno .AND. PartOper->( !Eof() )
                                IF PartOper->Operno = Space( 8 )
                                    SKIP ALIAS PartOper
                                    LOOP
                                ENDIF
                                IF PartOper->Adminno != cfind
                                    SKIP ALIAS PartOper
                                    LOOP
                                ENDIF
                                AAdd( aPart_, ( PartOper->Desc + " " + PartOper->Adminno;
                                    + " " + PartOper->Operno;
                                    + "                    " + Str( RecNo(), 6 ) ) )
                                SKIP ALIAS PartOper
                            ENDDO
                            Scroll()
                            DispBox(  0, 0, 24, 79, 2 )
                            ASort( aPart_,,, {| x, y | x < y } )
                            anum := AChoice( 1, 3, 23, 76, aPart_,, "AFUNC" )
                            nrecno := Val( Right( aPart_[ anum ],6 ) )
                            GOTO nrecno
                            IF LastKey() == 27
                                RETURN NIL
                            ENDIF

                        ENDIF          // FOUND
                        // **************
                    CASE cselect = "XX"
                        aPart_ := {}
                        nrecno := 0
                        SELECT PartOper
                        SET ORDER TO 1
                        GOTO TOP
                        DO WHILE PartOper->( !Eof() )
                            IF PartOper->Operno = Space( 8 )
                                SKIP ALIAS PartOper
                                LOOP
                            ENDIF
                            AAdd( aPart_, ( PartOper->Desc + " " + PartOper->Adminno;
                                + " " + PartOper->Operno;
                                + "                    " + Str( RecNo(), 6 ) ) )
                            SKIP ALIAS PartOper
                        ENDDO
                        IF !Empty( aPart_ )
                            Scroll()
                            DispBox(  0, 0, 24, 79, 2 )
                            ASort( aPart_,,, {| x, y | x < y } )
                            anum := AChoice( 1, 3, 23, 76, aPart_,, "AFUNC" )
                            nrecno := Val( Right( aPart_[ anum ],6 ) )
                            GOTO nrecno
                            IF LastKey() == 27
                                RETURN NIL
                            ENDIF
                        ENDIF
                    ENDCASE                                  // XX
                    cfind := PartOper->Adminno
                    mdesc := PartOper->Desc
                    Scroll( 15, 0, 24, 80 )
                    DispBox( 15, 0, 24, 79, 2 )
                    @ 17, 12      SAY PartOper->Adminno COLOR "BG+"
                    @ 17, Col() + 2 SAY PartOper->Operno  COLOR "BG+"
                    @ 17, Col() + 2 SAY Debit->Operno     COLOR "RG+"
                    @ 19, 5 GET cfind PICTURE "@!"
                    @ 21, 5 GET mdesc PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                    READ
                    IF LastKey() == 27
                        RETURN NIL
                    ENDIF
                    myes := "N"
                    IF Debit->Operno != PartOper->Operno
                        myes := "Y"
                    ELSE
                        myes := "N"
                    ENDIF
                    @ 21, 50 SAY "Is this New " GET myes VALID( myes $ "NY" ) PICTURE "@!"
                    READ
                    IF myes = "Y"
                        myes := "N"
                        @ 21, 50 SAY "   Sure New " COLOR "RG+"
                        @ 21, Col() + 1 GET myes VALID( myes $ "NY" ) PICTURE "@!"
                        @ 23, 50 SAY "ARE YOU SURE" COLOR "BG+"
                        READ
                    ENDIF
                    SELECT PartOper
                    ApFLock( 3 )
                    IF myes = "Y"
                        APPEND BLANK
                        PartOper->Operno  := Debit->Operno
                    ENDIF
                    // **       ApFLock( 3 )
                    PartOper->Time    := mtime
                    PartOper->Order   := Upper( SubStr( cfind, 1, 1 ) );
                        + Upper( SubStr( mdesc, 1, 1 ) )
                    PartOper->Adminno := cfind
                    PartOper->Date    := dDate
                    PartOper->Desc    := mdesc
                    UNLOCK
                    SELECT Labour
                    ApFLock( 3 )
                    Labour->Invno   := minvno
                    Labour->Jobnum  := Upper( SubStr( mdesc, 1,12 ) )
                    Labour->Desc    := mdesc
                    Labour->Message := mmessage
                    Labour->Fault   := mfault
                    Labour->Time    := mtime
                    Labour->Date    := dDate
                    Labour->Codeno  := mcodeno
                    UNLOCK
                    SELECT Control
                    ApRLock( 3 )
                    Control->LastRoll := dDate
                    UNLOCK

                ELSE
                    coperno := Debit->Operno

                    PlanningList( @coperno )                 // XLF_QU4

                ENDIF          // moperate
                cdatecode := Space( 19 )
                aPart_ := {}
                nrecno := 0
                nTime  := 0
                SELECT Labour
                GOTO TOP
                SEEK mcodeno
                DO WHILE Labour->Codeno = mcodeno .AND. Labour->( !Eof() )
                    IF Labour->Date != dDate
                        SKIP ALIAS Labour
                        LOOP
                    ENDIF
                    IF Labour->Partnum != Space( 20 )
                        SKIP ALIAS Labour
                        LOOP
                    ENDIF
                    nTime += Labour->Time
                    cdatecode := DToC( Labour->Date ) + " " + Labour->Codeno
                    AAdd( aPart_, cdatecode;
                        + " " + Str( Labour->Time, 8, 2 );
                        + " " + Labour->Invno;
                        + " " + SubStr( Labour->Desc, 1, 29 );
                        + " " + Labour->Labno )             // Client
                    SKIP ALIAS Labour
                ENDDO                        // Labour EOF
                IF !Empty( aPart_ )
                    Scroll()
                    DispBox( 0, 1, 2, 79, 2 )
                    @  1, 6      SAY Trim( Name->Name )
                    @  1, Col() + 2 SAY "Hours " + DToC( dDate ) COLOR "BG+"
                    @  1, Col() + 2 SAY nTime PICTURE "999.99" COLOR "BG+"
                    @  1, 60      SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    Scroll(  3, 0, 24, 80 )
                    DispBox( 3, 0, 23, 79, 2 )
                    ASort( aPart_,,, {| x, y | x < y } )
                    @  3, 00 SAY " "
                    AEval( aPart_, {|A| QOUT( " " + Chr( 186 ) + "  " ), QQOut( A ), Breakpoint() } )
                    @ 17, 6      SAY Trim( Name->Name )        COLOR "BG+"
                    @ 17, Col() + 2 SAY "Hours " + DToC( dDate )    COLOR "BG+"
                    @ 17, Col() + 2 SAY nTime PICTURE "99,999.99" COLOR "BG+"
                    IF nTime >= 12
                        @ 18, 6 SAY "BEWARE MORE THAN 12 HOURS  ARE YOU SURE"  COLOR "RG+"
                    ENDIF
                ENDIF                        // Empty
                mcorrect := "Y"
                // **  ApGetY( Message->Correct )
            ENDDO                                            // mcorrect
            manother := "Y"
            LOOP

        CASE nselect = 2                 // Another
            LabourWO()                   // LabourShan()

        CASE nselect == 3                    // Edit Labour
            Scroll( 15, 2, 19, 78 )
            DispBox( 15, 0, 19, 79, 2 )
            mstmm  := Date() -4
            mendmm := Date()
            @ 16, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
            @ 17, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
            READ
            SELECT Labour
            SET ORDER TO 1        // Codeno
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
                aPart_ := {}
                nrecno := 0
                GOTO TOP
                // **      mcodeno := // Debit->Codeno
                SEEK mcodeno
                IF Found()
                    DO WHILE Labour->Codeno = mcodeno .AND. Labour->( !Eof() )
                        IF Labour->Partnum != Space( 20 )
                            SKIP ALIAS Labour
                            LOOP
                        ENDIF
                        IF Labour->Date < mstmm
                            SKIP ALIAS Labour
                            LOOP
                        ENDIF
                        IF Labour->Date > mendmm
                            SKIP ALIAS Labour
                            LOOP
                        ENDIF
                        AAdd( aPart_, Labour->Invno;
                            + " " + DToC( Labour->Date );
                            + " " + Labour->Desc;
                            + " " + Str( Labour->Time, 8, 2 );
                            + " " + Labour->Codeno;
                            + "        " + Str( RecNo(), 6 ) )
                        SKIP ALIAS Labour
                    ENDDO                        // Labour EOF
                    IF !Empty( aPart_ )
                        Scroll()
                        DispBox( 0, 0, 2, 79, 2 )
                        @  1, 10 SAY Name->Name COLOR "BG+"
                        @  1, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                        DispBox( 3, 0, 24, 79, 2 )
                        ASort( aPart_,,, {| x, y | x < y } )
                        anum := AChoice( 4, 3, 23, 77, aPart_,, "AFUNC" )
                        IF LastKey() == 27
                            EXIT
                        ENDIF
                        nrecno := Val( Right( aPart_[ anum ],6 ) )
                        GOTO nrecno
                    ENDIF                        // Empty
                    mcorrect := "N"
                    DO WHILE mcorrect == "N"
                        SELECT Labour
                        Scroll(  10, 0, 24, 80 )
                        DispBox( 10, 0, 19, 79, 2 )
                        mdesc    := Labour->Desc
                        mmessage := Labour->Message
                        mfault   := Labour->Fault
                        mtime    := Labour->Time
                        minvno   := Labour->Invno
                        mstaff   := Labour->Codeno
                        ddate    := Labour->Date
                        @ 12, 8      SAY "Desc"          GET mdesc    PICTURE "@X"
                        @ 13, 13                          GET mmessage PICTURE "@X"
                        @ 14, 13                          GET mfault   PICTURE "@X"
                        @ 16, 8      SAY "Time in Hrs"   GET mtime    PICTURE "9999.99"
                        @ 16, Col() + 2 SAY "Date"          GET ddate    PICTURE "99/99/9999"
                        // **         @ 16,COL()+2 SAY "Rate"       GET Labour->Rate    PICTURE "9999.99"
                        @ 18, 8      SAY "Invno"         GET minvno   PICTURE "@!"
                        @ 18, Col() + 2 SAY Labour->Labno COLOR "BG+"
                        @ 18, Col() + 2 SAY "Staff/Ord"     GET mstaff   PICTURE "@!"
                        READ
                        ApRLock( 3 )
                        Labour->Desc    := mdesc
                        Labour->Message := mmessage
                        Labour->Fault   := mfault
                        Labour->Time    := mtime
                        Labour->Invno   := minvno
                        Labour->Codeno  := mstaff
                        Labour->Date    := ddate
                        UNLOCK
                        mcorrect := ApGetY( Message->Correct )
                    ENDDO                                            // mcorrect
                    Scroll(  11, 0, 24, 80 )
                    DispBox( 11, 0, 19, 79, 2 )
                    @ 13, 8      SAY Labour->Desc                 COLOR "RG+"
                    @ 14, 8      SAY Labour->Message
                    @ 14, Col() + 2 SAY Labour->Fault
                    @ 15, 8      SAY "Time " + Str( Labour->Time )  COLOR "BG+"
                    @ 15, Col() + 2 SAY "Date " + DToC( Labour->Date ) COLOR "BG+"
                    @ 17, 8      SAY "Invno " + Labour->Invno       COLOR "BG+"
                    @ 17, Col() + 2 SAY "Staff " + Labour->Codeno      COLOR "RG+"
                    mdelete := ApGetN( Trim( Message->Delete ) + " Labour" )
                    IF LastKey() == 27
                        EXIT           // RETURN
                    ENDIF
                    IF mdelete == "Y"
                        SELECT Labour
                        ApRLock( 3 )
                        DELETE
                        UNLOCK
                    ENDIF
                ELSE
                    @ 18, 10 SAY "This Name No Entries these Dates"
                    Inkey( 2 )
                    EXIT
                ENDIF                // Found
                mcontinue := "Y"
                // **     ApGetY( "Edit Another Labour" )
                IF LastKey() == 27
                    EXIT           // RETURN
                ENDIF
            ENDDO                      // mcontinue
            manother := "Y"
            LOOP

        CASE nselect == 4                    // Edit All Labour
            Scroll( 16, 1, 19, 78 )
            DispBox( 16, 0, 19, 79, 2 )
            mstmm  := Date() -4
            mendmm := Date()
            @ 17, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
            @ 18, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
            READ
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
                aPart_ := {}
                nrecno := 0
                SELECT Labour
                SET ORDER TO 1       // Codeno
                GOTO TOP
                DO WHILE Labour->( !Eof() )
                    IF Labour->Partnum != Space( 20 )
                        SKIP ALIAS Labour
                        LOOP
                    ENDIF
                    IF Labour->Date < mstmm
                        SKIP ALIAS Labour
                        LOOP
                    ENDIF
                    IF Labour->Date > mendmm
                        SKIP ALIAS Labour
                        LOOP
                    ENDIF
                    AAdd( aPart_, Labour->Invno;
                        + " " + DToC( Labour->Date );
                        + " " + Labour->Desc;
                        + " " + Str( Labour->Time, 8, 2 );
                        + " " + Labour->Codeno;
                        + "        " + Str( RecNo(), 6 ) )
                    SKIP ALIAS Labour
                ENDDO                        // Labour EOF
                IF !Empty( aPart_ )
                    Scroll()
                    DispBox( 0, 0, 2, 79, 2 )
                    @  1, 10 SAY "Edit Labour" COLOR "BG+"
                    @  1, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    DispBox( 3, 0, 24, 79, 2 )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice( 4, 3, 23, 77, aPart_,, "AFUNC" )
                    IF LastKey() == 27
                        EXIT
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                ENDIF                        // Empty
                mcorrect := "N"
                DO WHILE mcorrect == "N"
                    SELECT Labour
                    Scroll(  10, 0, 24, 80 )
                    DispBox( 10, 0, 19, 79, 2 )
                    mdesc    := Labour->Desc
                    mmessage := Labour->Message
                    mfault   := Labour->Fault
                    mtime    := Labour->Time
                    minvno   := Labour->Invno
                    mstaff   := Labour->Codeno
                    ddate    := Labour->Date
                    @ 12, 8      SAY "Desc"        GET mdesc    PICTURE "@X"
                    @ 13, 13                        GET mmessage PICTURE "@X"
                    @ 14, 13                        GET mfault   PICTURE "@X"
                    @ 16, 8      SAY "Time in Hrs" GET mtime    PICTURE "9999.99"
                    @ 16, Col() + 2 SAY "Date"        GET ddate    PICTURE "99/99/9999"
                    // **         @ 16,COL()+2 SAY "Rate"     GET Labour->Rate    PICTURE "9999.99"
                    @ 18, 8      SAY "Invno"       GET minvno   PICTURE "@!"
                    @ 18, Col() + 2 SAY Labour->Labno COLOR "BG+"
                    @ 18, Col() + 2 SAY "Staff/Ord" GET mstaff   PICTURE "@!"
                    READ
                    ApRLock( 3 )
                    Labour->Desc    := mdesc
                    Labour->Message := mmessage
                    Labour->Fault   := mfault
                    Labour->Time    := mtime
                    Labour->Invno   := minvno
                    Labour->Codeno  := mstaff
                    Labour->Date    := ddate
                    UNLOCK
                    mcorrect := ApGetY( Message->Correct )
                ENDDO                                            // mcorrect
                Scroll(  10, 0, 24, 80 )
                DispBox( 10, 0, 19, 79, 2 )
                @ 12, 8      SAY "Desc  " + Labour->Desc        COLOR "RG+"
                @ 13, 13      SAY Labour->Message
                @ 14, 13      SAY Labour->Fault
                @ 16, 8      SAY "Time " + Str( Labour->Time )  COLOR "BG+"
                @ 16, Col() + 2 SAY "Date " + DToC( Labour->Date ) COLOR "BG+"
                @ 16, Col() + 2 SAY Labour->Codeno               COLOR "RG+"
                @ 18, 8      SAY "Invno " + Labour->Invno       COLOR "BG+"
                @ 18, Col() + 2 SAY "Staff " + Labour->Codeno      COLOR "RG+"
                mdelete := ApGetN( Trim( Message->Delete ) + " Labour" )
                IF LastKey() == 27
                    EXIT           // RETURN
                ENDIF
                IF mdelete == "Y"
                    SELECT Labour
                    ApRLock( 3 )
                    DELETE
                    UNLOCK
                ENDIF
                mcontinue := "Y"
                // ** ApGetY( "Edit Another Labour" )
                IF LastKey() == 27
                    EXIT           // RETURN
                ENDIF
            ENDDO                                              // mcontinue
            manother := "Y"
            LOOP

        CASE nselect = 5                 // Print Name Labour
            Scroll()
            DispBox( 0, 0,  2, 79, 2 )
            @  1, 6      SAY "Printing Labour"
            @  1, Col() + 2 SAY Name->Name
            @  1, Col() + 2 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            DispBox( 3, 1, 23, 79, 2 )
            mstmm  := Date() -6
            mendmm := Date() + 1
            @ 10, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
            @ 11, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
            READ
            IF LastKey() == 27
                RETURN NIL
            ENDIF
            mwhere   := "S"

            Printsel( mwhere )

            nl := 0
            IF mwhere == "P"
                npl := 55
            ELSE
                Scroll()
                npl := 22
            ENDIF
            @  0, 0 SAY Control->U_Name
            @  0, 34 SAY mstmm
            @  0, 47 SAY mendmm
            @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  2, 0 SAY Name->Name
            nl := 4
            ntimetotal := 0
            SELECT Labour
            SET ORDER TO 1            // Codeno
            GOTO TOP
            SEEK mcodeno
            DO WHILE Labour->Codeno = mcodeno .AND. Labour->( !Eof() )
                IF Labour->Partnum != Space( 20 )
                    SKIP ALIAS Labour
                    LOOP
                ENDIF
                IF Labour->Date < mstmm
                    SKIP ALIAS Labour
                    LOOP
                ENDIF
                IF Labour->Date > mendmm
                    SKIP ALIAS Labour
                    LOOP
                ENDIF
                IF nl > npl
                    IF mwhere == "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                    @  0, 0 SAY Control->U_Name
                    @  0, 34 SAY mstmm
                    @  0, 47 SAY mendmm
                    @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  2, 0 SAY Name->Name
                    nl := 4
                ENDIF                       // nl>npl
                @ nl, 0 SAY Labour->Date
                @ nl, 11 SAY Labour->Codeno
                @ nl, 20 SAY Labour->Desc
                @ nl, 61 SAY Labour->Invno
                @ nl, 68 SAY Labour->Time PICTURE "99,999.99"
                nl++
                IF Labour->Message != "  "
                    @ nl, 10 SAY Labour->Message
                    nl++
                ENDIF
                IF Labour->Fault != "  "
                    @ nl, 10 SAY Labour->Fault
                    nl++
                ENDIF
                ntimetotal += Labour->Time
                SKIP ALIAS Labour
            ENDDO                // EOF Labour
            @ nl, 67 SAY "----------"
            nl++
            @ nl, 38 SAY mcodeno + " Total Time"
            @ nl, 68 SAY ntimetotal PICTURE "99,999.99"
            nl++
            @ nl, 67 SAY "=========="
            nl++
            SELECT Pmppjnl
            GOTO TOP
            npaytotal := 0
            SEEK mcodeno
            DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !Eof() )
                IF Pmppjnl->Pay_Per < mstmm
                    SKIP ALIAS Pmppjnl
                    LOOP
                ENDIF
                IF Pmppjnl->Pay_Per > mendmm
                    SKIP ALIAS Pmppjnl
                    LOOP
                ENDIF
                IF nl > npl
                    IF mwhere == "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                    @  0, 0 SAY Control->U_Name
                    @  0, 34 SAY mstmm
                    @  0, 47 SAY mendmm
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    nl := 2
                ENDIF                       // nl>npl
                nHours := nHrsTH := nTotHrs := 0
                // **      mcodeno := Pmppjnl->Codeno
                DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !Eof() )
                    IF Pmppjnl->Pay_Per < mstmm
                        SKIP ALIAS Pmppjnl
                        LOOP
                    ENDIF
                    IF Pmppjnl->Pay_Per > mendmm
                        SKIP ALIAS Pmppjnl
                        LOOP
                    ENDIF
                    nHours  += Pmppjnl->Hours
                    nHrsTH  += Pmppjnl->HrsTH / 1.5
                    nTotHrs += Pmppjnl->Hours + ( Pmppjnl->HrsTH / 1.5 )
                    SKIP ALIAS Pmppjnl
                ENDDO
                @ nl, 11 SAY mcodeno
                @ nl, 20 SAY nHours  PICTURE "9999.99"
                @ nl, 30 SAY nHrsTH  PICTURE "9999.99"
                @ nl, 38 SAY nTotHrs PICTURE "9999.99"
                nl++
                nPayTotal += nTotHrs
            ENDDO                // EOF Pmppjnl
            @ nl, 67 SAY "----------"
            nl++
            @ nl, 2 SAY "Pay Hrs Total incl TH1/2 Available"
            @ nl, 38 SAY mcodeno + " Total Hrs"
            @ nl, 68 SAY nPayTotal PICTURE "99,999.99"
            nl++
            @ nl, 67 SAY "=========="
            nl++
            IF mwhere = "P"
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
            manother := "Y"
            LOOP

        CASE nselect = 6                 // Print ALL Names Labour

            Scroll()
            DispBox( 0, 0, 18, 79, 2 )
            @  1, 20 SAY "ALL Name Labour Analysis"
            mstmm  := Date() -6
            mendmm := Date() + 1
            @ 10, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
            @ 11, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
            READ
            IF LastKey() == 27
                RETURN NIL
            ENDIF
            mwhere   := "S"

            Printsel( mwhere )

            nl := 0
            IF mwhere == "P"
                npl := 55
            ELSE
                Scroll()
                npl := 22
            ENDIF
            @  0, 0 SAY Control->U_Name
            @  0, 34 SAY mstmm
            @  0, 47 SAY mendmm
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            nl := 2
            ntimetotal := 0
            SELECT Labour
            SET ORDER TO 1         // Codeno
            GOTO TOP
            DO WHILE Labour->( !Eof() )
                IF Labour->Partnum != Space( 20 )
                    SKIP ALIAS Labour
                    LOOP
                ENDIF
                IF Labour->Date < mstmm
                    SKIP ALIAS Labour
                    LOOP
                ENDIF
                IF Labour->Date > mendmm
                    SKIP ALIAS Labour
                    LOOP
                ENDIF
                IF nl > npl
                    IF mwhere == "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                    @  0, 0 SAY Control->U_Name
                    @  0, 34 SAY mstmm
                    @  0, 47 SAY mendmm
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    nl := 2
                ENDIF                       // nl>npl
                @ nl, 0 SAY Labour->Date
                @ nl, 11 SAY Labour->Codeno
                @ nl, 20 SAY Labour->Desc
                @ nl, 61 SAY Labour->Invno
                @ nl, 68 SAY Labour->Time PICTURE "99,999.99"
                nl++
                ntimetotal += Labour->Time
                SKIP ALIAS Labour
            ENDDO                // EOF Labour
            @ nl, 67 SAY "----------"
            nl++
            @ nl, 48 SAY "Total Time"
            @ nl, 68 SAY ntimetotal PICTURE "99,999.99"
            nl++
            @ nl, 67 SAY "=========="
            nl++
            SELECT Pmppjnl
            GOTO TOP
            npaytotal := 0
            DO WHILE Pmppjnl->( !Eof() )
                IF Pmppjnl->Pay_Per < mstmm
                    SKIP ALIAS Pmppjnl
                    LOOP
                ENDIF
                IF Pmppjnl->Pay_Per > mendmm
                    SKIP ALIAS Pmppjnl
                    LOOP
                ENDIF
                IF nl > npl
                    IF mwhere == "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                    @  0, 0 SAY Control->U_Name
                    @  0, 34 SAY mstmm
                    @  0, 47 SAY mendmm
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    nl := 2
                ENDIF                       // nl>npl
                nHours := nHrsTH := nTotHrs := 0
                mcodeno := Pmppjnl->Codeno
                DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !Eof() )
                    IF Pmppjnl->Pay_Per < mstmm
                        SKIP ALIAS Pmppjnl
                        LOOP
                    ENDIF
                    IF Pmppjnl->Pay_Per > mendmm
                        SKIP ALIAS Pmppjnl
                        LOOP
                    ENDIF
                    nHours  += Pmppjnl->Hours
                    nHrsTH  += Pmppjnl->HrsTH / 1.5
                    nTotHrs += Pmppjnl->Hours + ( Pmppjnl->HrsTH / 1.5 )
                    SKIP ALIAS Pmppjnl
                ENDDO
                @ nl, 11 SAY mcodeno
                @ nl, 20 SAY nHours  PICTURE "9999.99"
                @ nl, 30 SAY nHrsTH  PICTURE "9999.99"
                @ nl, 38 SAY nTotHrs PICTURE "9999.99"
                nl++
                nPayTotal += nTotHrs
            ENDDO                // EOF Pmppjnl
            @ nl, 67 SAY "----------"
            nl++
            @ nl, 3 SAY "Pay Hrs Total incl TH1/2"
            @ nl, 48 SAY "Total Hrs"
            @ nl, 68 SAY nPayTotal PICTURE "99,999.99"
            nl++
            @ nl, 67 SAY "=========="
            nl++
            IF mwhere = "P"
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
            manother := "Y"
            LOOP
            // **   CASE nselect == 7                // Operation
            // **      Operation()                  //  XLF_QU9
            // **      LOOP

            // **   CASE nselect == 8                // Operation
            // **       JobOperate()                 // XLF_QU5
            // **      LOOP

            // **   CASE nselect == 7                // Key Desc
            // **       coperno := Debit->Operno
            // **       PlanEditKey( @coperno )                // Above
            // **       OperEditKey()                 //
            // **      LOOP

        ENDCASE
        // **  manother := ApGetY( Message->Another )
    ENDDO               // Another

    RETURN

// ***---------------  End LabourWO

// ****-------------------------------------------------------------------------

FUNCTION LabPart( mpartnum )

    manother = "Y"
    DO WHILE manother = "Y"
        mxy := ApGetN( "Include XY Parts" )
        mwhere   := "S"

        Printsel( mwhere )

        IF mwhere == "P"
            npl := 60
        ELSE
            Scroll()
            npl := 21
        ENDIF
        @  1, 1 SAY mpartnum
        @  1, 21 SAY Part->Desc
        @  1, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl  := 3
        nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
        nqty1 := nqty2 := nqty3 := nqty4 := 0
        nEquCost := 0
        SELECT Equ
        GOTO TOP
        SET EXACT ON
        mmod1 := SubStr( mpartnum, 1, 16 )
        SEEK mmod1
        IF Found()
            DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !Eof() )
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        Inkey( 0 )
                        Scroll()
                    ENDIF
                    nl := 0
                ENDIF
                IF mxy = "N"
                    IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                        SKIP ALIAS Equ
                        LOOP
                    ENDIF
                ENDIF
                SELECT Part
                SEEK Equ->Partnum
                nqty1 := Equ->PartQty
                @ nl, 0 SAY "."
                @ nl, 5 SAY SubStr( Equ->Partnum, 1, 16 );
                    + " " + SubStr( Part->Desc, 1, 35 )
                @ nl, 58 SAY Equ->PartQty PICTURE "9999.999"
                @ nl, 68 SAY Part->Trade  PICTURE "$9,999.999"
                nEquCost += Equ->PartQty * Part->Trade
                nl++
                mmod2 := Trim( Equ->Partnum )
                SELECT EquCut
                SEEK mmod1
                DO WHILE SubStr( EquCut->ModSeqno, 1, 16 ) = mmod1 .AND. EquCut->( !Eof() )
                    IF EquCut->Partnum != Equ->Partnum
                        SKIP ALIAS EquCut
                        LOOP
                    ENDIF
                    IF nl > npl
                        IF mwhere = "P"
                            EJECT
                        ELSE
                            Inkey( 0 )
                            nl := 5
                            Scroll(  nl, 2, 24, 78 )
                        ENDIF
                        nl := 0
                    ENDIF
                    @ nl, 0 SAY EquCut->ModRef
                    @ nl, 42 SAY "Qty"
                    @ nl, 46 SAY EquCut->Qty    PICTURE "999"
                    @ nl, 50 SAY EquCut->Length PICTURE "999.999"
                    IF EquCut->Width != 0
                        @ nl, 58 SAY EquCut->Width  PICTURE "999.999"
                        @ nl, 66 SAY "Sq Mtrs"
                    ENDIF
                    nl++
                    SKIP ALIAS EquCut
                ENDDO
                SELECT Equ
                nrecno2 := RecNo()
                GOTO TOP
                SEEK mmod2
                IF Found()
                    DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                        nqty2 := Equ->PartQty
                        IF nl > npl
                            IF mwhere = "P"
                                EJECT
                                nl := 0
                            ENDIF
                        ENDIF
                        IF mwhere = "S"
                            IF nl > 22
                                Inkey( 0 )
                                Scroll()
                                nl := 0
                            ENDIF
                        ENDIF
                        IF mxy = "N"
                            IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                                SKIP ALIAS Equ
                                LOOP
                            ENDIF
                        ENDIF
                        SELECT Part
                        SEEK Equ->Partnum
                        @ nl, 0 SAY ".."
                        @ nl, 5 SAY SubStr( Equ->Partnum, 1, 16 );
                            + " " + SubStr( Part->Desc, 1, 35 )
                        @ nl, 58 SAY Equ->PartQty PICTURE "9999.999"
                        @ nl, 68 SAY Part->Trade  PICTURE "$9,999.999"
                        // **            nEquCost += Equ->PartQty*Part->Trade
                        IF Equ->Partnum = Message->LabPart
                            nlabpart += nequ2
                        ENDIF
                        nl++
                        SELECT Equ
                        mmod3 := Trim( Equ->Partnum )
                        nrecno3 := RecNo()
                        SELECT EquCut
                        SEEK mmod2
                        DO WHILE SubStr( EquCut->ModSeqno, 1, 16 ) = mmod2 .AND. EquCut->( !Eof() )
                            IF EquCut->Partnum != Equ->Partnum
                                SKIP ALIAS EquCut
                                LOOP
                            ENDIF
                            IF nl > npl
                                IF mwhere = "P"
                                    EJECT
                                ELSE
                                    Inkey( 0 )
                                    nl := 5
                                    Scroll(  nl, 2, 24, 78 )
                                ENDIF
                                nl := 0
                            ENDIF
                            @ nl, 0 SAY EquCut->ModRef
                            @ nl, 42 SAY "Qty"
                            @ nl, 46 SAY EquCut->Qty    PICTURE "999"
                            @ nl, 50 SAY EquCut->Length PICTURE "999.999"
                            IF EquCut->Width != 0
                                @ nl, 58 SAY EquCut->Width  PICTURE "999.999"
                                @ nl, 66 SAY "Sq Mtrs"
                            ENDIF
                            nl++
                            SKIP ALIAS EquCut
                        ENDDO
                        SELECT Equ
                        GOTO TOP
                        SEEK mmod3
                        IF Found()
                            DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                nqty3 := Equ->PartQty
                                nequ3 := ( ( nqty3 * nqty2 ) * nqty1 )
                                IF nl > npl
                                    IF mwhere = "P"
                                        EJECT
                                        nl := 0
                                    ENDIF
                                ENDIF
                                IF mwhere = "S"
                                    IF nl > 22
                                        Inkey( 0 )
                                        Scroll()
                                        nl := 0
                                    ENDIF
                                ENDIF
                                IF mxy = "N"
                                    IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                                        SKIP ALIAS Equ
                                        LOOP
                                    ENDIF
                                ENDIF
                                SELECT Part
                                SEEK Equ->Partnum
                                @ nl, 0 SAY "..."
                                @ nl, 5 SAY SubStr( Equ->Partnum, 1, 16 );
                                    + " " + SubStr( Part->Desc, 1, 35 )
                                @ nl, 58 SAY Equ->PartQty PICTURE "9999.999"
                                @ nl, 68 SAY Part->Trade  PICTURE "$9,999.999"
                                // **            nEquCost += Equ->PartQty*Part->Trade
                                IF Equ->Partnum = Message->LabPart
                                    nlabpart += nequ3
                                ENDIF
                                nl++
                                SELECT Equ
                                mmod4   := Trim( Equ->Partnum )
                                nrecno4 := RecNo()
                                SELECT EquCut
                                SEEK mmod3
                                DO WHILE SubStr( EquCut->ModSeqno, 1, 16 ) = mmod3 .AND. EquCut->( !Eof() )
                                    IF EquCut->Partnum != Equ->Partnum
                                        SKIP ALIAS EquCut
                                        LOOP
                                    ENDIF
                                    IF nl > npl
                                        IF mwhere = "P"
                                            EJECT
                                        ELSE
                                            Inkey( 0 )
                                            nl := 5
                                            Scroll(  nl, 2, 24, 78 )
                                        ENDIF
                                        nl := 0
                                    ENDIF
                                    @ nl, 0 SAY EquCut->ModRef
                                    @ nl, 42 SAY "Qty"
                                    @ nl, 46 SAY EquCut->Qty    PICTURE "999"
                                    @ nl, 50 SAY EquCut->Length PICTURE "999.999"
                                    IF EquCut->Width != 0
                                        @ nl, 58 SAY EquCut->Width  PICTURE "999.999"
                                        @ nl, 66 SAY "Sq Mtrs"
                                    ENDIF
                                    nl++
                                    SKIP ALIAS EquCut
                                ENDDO
                                SELECT Equ
                                GOTO TOP
                                SEEK mmod4
                                IF Found()
                                    DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                        nqty4 := Equ->PartQty
                                        nequ4 := ( ( ( nqty4 * nqty3 ) * nqty2 ) * nqty1 )
                                        IF nl > npl
                                            IF mwhere = "P"
                                                EJECT
                                                nl := 0
                                            ENDIF
                                        ENDIF
                                        IF mwhere = "S"
                                            IF nl > 22
                                                Inkey( 0 )
                                                Scroll()
                                                nl := 0
                                            ENDIF
                                        ENDIF
                                        IF mxy = "N"
                                            IF SubStr( Equ->Partnum, 1, 2 ) = "XY"
                                                SKIP ALIAS Equ
                                                LOOP
                                            ENDIF
                                        ENDIF
                                        SELECT Part
                                        SEEK Equ->Partnum
                                        @ nl, 0 SAY "...."
                                        @ nl, 5 SAY SubStr( Equ->Partnum, 1, 16 );
                                            + " " + SubStr( Part->Desc, 1, 35 )
                                        @ nl, 58 SAY Equ->PartQty PICTURE "9999.999"
                                        @ nl, 68 SAY Part->Trade  PICTURE "$9,999.999"
                                        // **            nEquCost += Equ->PartQty*Part->Trade
                                        IF Equ->Partnum = Message->LabPart
                                            nlabpart += nequ4
                                        ENDIF
                                        nl++
                                        SELECT EquCut
                                        SEEK mmod3
                                        DO WHILE SubStr( EquCut->ModSeqno, 1, 16 ) = mmod3 .AND. EquCut->( !Eof() )
                                            IF EquCut->Partnum != Equ->Partnum
                                                SKIP ALIAS EquCut
                                                LOOP
                                            ENDIF
                                            IF nl > npl
                                                IF mwhere = "P"
                                                    EJECT
                                                ELSE
                                                    Inkey( 0 )
                                                    nl := 5
                                                    Scroll(  nl, 2, 24, 78 )
                                                ENDIF
                                                nl := 0
                                            ENDIF
                                            @ nl, 0 SAY EquCut->ModRef
                                            @ nl, 42 SAY "Qty"
                                            @ nl, 46 SAY EquCut->Qty    PICTURE "999"
                                            @ nl, 50 SAY EquCut->Length PICTURE "999.999"
                                            IF EquCut->Width != 0
                                                @ nl, 58 SAY EquCut->Width  PICTURE "999.999"
                                                @ nl, 66 SAY "Sq Mtrs"
                                            ENDIF
                                            nl++
                                            SKIP ALIAS EquCut
                                        ENDDO
                                        SELECT Equ
                                        SKIP ALIAS Equ
                                    ENDDO                       // mmod4
                                ENDIF
                                SELECT Equ
                                GOTO nrecno4
                                SKIP ALIAS Equ
                            ENDDO                       // mmod3
                        ENDIF                          // FOUND()  mmod3
                        SELECT Equ
                        GOTO nrecno3
                        SKIP ALIAS Equ
                    ENDDO                       // mmod2 EOF()
                    nl++
                ENDIF                         // Found mmod2
                SELECT Equ
                GOTO nrecno2
                SKIP ALIAS Equ
            ENDDO                       // mmod1 EOF()
            @ nl, 0 SAY "Module Cost"
            @ nl, 14 SAY nEquCost PICTURE "$999,999.99"
            nl += 2
        ENDIF                          // Found mmod1
        SET EXACT OFF
        SELECT Part
        SEEK mpartnum
        nPartTot := nGPartTot := nGTimeTot := 0
        SELECT Labour
        GOTO TOP
        DO WHILE Labour->( !Eof() )
            IF SubStr( Labour->Invno, 3, 4 ) != SubStr( mpartnum, 4, 4 )
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF nl > npl
                IF mwhere = "S"
                    WAIT
                    Scroll()
                ELSE
                    EJECT
                ENDIF
                @  1, 1 SAY mpartnum
                @  1, 21 SAY Part->Desc
                @  1, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                nl  := 3
            ENDIF                           // nl>npl
            @ nl, 0 SAY Labour->Invno
            @ nl, 8 SAY Labour->Codeno
            IF Labour->Partnum != Space( 20 )
                @ nl, 18 SAY SubStr( Labour->Desc, 1, 28 )
                @ nl, 48 SAY Labour->Time PICTURE "99,999.99"
                @ nl, 58 SAY Labour->Rate PICTURE "99,999.99"
                @ nl, 68 SAY SubStr( Labour->Partnum, 1, 10 )
                // **         nPartTot := Labour->Time*Labour->Rate
                nGPartTot += Labour->Time * Labour->Rate
            ELSE
                @ nl, 18 SAY Labour->Desc
                @ nl, 58 SAY Labour->Time PICTURE "9999.99"
                @ nl, 68 SAY Labour->Date
                nGTimeTot += Labour->Time
            ENDIF
            // **      @ nl,69 SAY nPartTot PICTURE "99,999.99"
            nl++
            SKIP ALIAS Labour
        ENDDO                // EOF Labour
        nl += 2
        IF nEquCost > 0
            @ nl, 0 SAY "Module Cost"
            @ nl, 14 SAY nEquCost PICTURE "$999,999.99"
        ENDIF
        @ nl, 28 SAY "Time"
        @ nl, 33 SAY nGTimeTot PICTURE "999,999.99"
        @ nl, 45 SAY "Ordered Parts"
        @ nl, 59 SAY nGPartTot PICTURE "$999,999.99"
        nl++
        IF mwhere = "P"
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
        manother := "N"
    ENDDO

    RETURN

// ***----- End of LabPart()

// ********----------  END OF FILE XLF_QU5.PRG
