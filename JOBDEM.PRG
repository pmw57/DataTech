// ** JK  30-01-11 08:16:45

/*
   Program.....:                  JOBDEM.PRG
   Authors.....: J.Kirby
   Date........: 03/11/1999
   Functions...: JobDraw,  CutsReview, ProgMessage
                 ProgDesc, JobAdmin, JobLabour, JobDemAdd
   Static Funcs: AdminABC
*/
// (c) Copyright 1993 by Kirby Christchurch.

FUNCTION JobDraw()

    cdrawno := Space( 8 )
    manother := "Y"
    DO WHILE manother = "Y"

        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @ 1, 8 SAY "Viewing Drawings"
        aPart_ := {}
        nrecno   := 0
        SELECT Drawing
        GOTO TOP
        DO WHILE Drawing->( !Eof() )
            AAdd( aPart_, Drawing->Drawno;
                + "  " + Drawing->Desc;
                + "                " + Str( RecNo(), 6 ) )
            SKIP ALIAS Drawing
        ENDDO                        // Drawing EOF
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 0, 24, 79, 2 )
            anum := AChoice(  4, 2, 23, 70, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            IF PressedEsc()
                RETURN NIL
            ENDIF
            cDrawno := Drawing->Drawno
        ENDIF                        // Empty
        nselect  := 1
        Scroll(  20, 0, 24, 80 )
        DispBox( 20, 0, 24, 79, 2 )
        @ 20, 5 SAY "  -- Drawings --  "
        @ 22, 6      PROMPT "1. Add Drawing"
        @ 22, Col() + 2 PROMPT "2. Edit Drawing"
        @ 22, Col() + 2 PROMPT "3. Print"
        // **   @ 22,COL()+2 PROMPT "4. Part Card"

        MENU TO nselect

        DO CASE
        CASE PressedEsc()
            RETURN NIL

        CASE nselect == 1                // Add Drawing
            Scroll(  14, 0, 19, 80 )
            DispBox( 14, 1, 19, 79, 2 )
            SELECT Drawing
            nl := 15
            @ nl, 10 SAY "Ref #"    GET cdrawno PICTURE "@!"
            READ
            /*
            SEEK cdrawno
            DO WHILE FOUND()
               @ nl,40 SAY "Already Used Try Again"
               @ nl,10 SAY "Ref #" GET cdrawno PICTURE "@!"
                READ
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               SEEK cdrawno
            ENDDO
            IF !FOUND()
            */
            ApFlock( 3 )
            APPEND BLANK
            Drawing->Drawno  := cdrawno
            Drawing->Date    := Date()
            Drawing->DrawLoc := cdrawno
            UNLOCK
            ApRlock( 3 )
            // **         @ nl,16      SAY Drawing->Drawno          COLOR "BG+"
            @ nl, 27 SAY "Desc" GET Drawing->Desc PICTURE "@X"
            nl += 2
            @ nl, 10 SAY "Location" GET Drawing->DrawLoc PICTURE "@X"
            READ
            UNLOCK

        CASE nselect == 2                // Edit Drawing
            cdrawno  := Space( 8 )
            SELECT Drawing
            GOTO TOP
            Scroll()
            @  4, 40 SAY "Select Drawing Group"
            aPart_ := {}
            nrecno   := 0
            IF LastRec() != 0
                DO WHILE Drawing->( !Eof() )
                    DO WHILE Drawing->Drawno = cdrawno
                        SKIP ALIAS Drawing
                        LOOP
                    ENDDO
                    AAdd( aPart_, Drawing->Drawno + "               " + Str( RecNo(),6 ) )
                    cdrawno := Drawing->Drawno
                    SKIP ALIAS Drawing
                ENDDO
                DispBox(  0, 0, 24, 20, 2 )
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice(  1, 2, 23, 19, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                ENDIF
            ENDIF                          // LastRec
            cdrawno := Drawing->Drawno
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
                SELECT Drawing
                GOTO TOP
                namount := "N"
                nrecno  := 0
                aPart_  := {}
                SEEK cdrawno
                DO WHILE Drawing->Drawno = cdrawno .AND. Drawing->( !Eof() )
                    AAdd( aPart_, ( Drawing->Drawno + "  " + Drawing->Desc;
                        + "   Delete";
                        + "                    " + Str( RecNo(), 6 ) ) )
                    SKIP ALIAS Drawing
                ENDDO                         // Fault EOF
                Scroll()
                DispBox( 0, 0, 2, 79, 2 )
                @  1, 10 SAY "Edit Drawings" COLOR "RG+"
                @  1, 62 SAY "Esc to Exit" COLOR "RG+"
                DispBox( 3, 0, 23, 79, 2 )
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice( 4, 2, 22, 77, aPart_,, "AFUNC" )
                    IF LastKey() = 27
                        EXIT
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                ENDIF
                ApRLock( 3 )
                @ Row(), 1 GET Drawing->Drawno   PICTURE "@X"
                @ Row(), 12 GET Drawing->Desc     PICTURE "@X"
                // **       @ ROW(),50 GET Drawing->Drawnloc PICTURE "@!"
                @ Row(), 63 GET namount VALID( namount $ "NY " ) PICTURE "@!"
                READ
                IF namount = "Y"
                    SELECT Drawing
                    DELETE
                    UNLOCK
                ENDIF
                UNLOCK
                IF LastKey() = 27
                    mcontinue := "N"
                ENDIF
                LOOP
            ENDDO
            LOOP

        CASE nselect == 3                 // Print
            cdrawno  := Space( 8 )
            SELECT Drawing
            Scroll()
            @  4, 25 SAY "Select Printing Group First 4 Characters"
            aPart_ := {}
            nrecno   := 0
            IF LastRec() != 0
                DO WHILE Drawing->( !Eof() )
                    DO WHILE Drawing->Drawno = cdrawno
                        SKIP ALIAS Drawing
                        LOOP
                    ENDDO
                    AAdd( aPart_, Drawing->Drawno + "               " + Str( RecNo(),6 ) )
                    cdrawno := Drawing->Drawno
                    SKIP ALIAS Drawing
                ENDDO
                DispBox(  0, 0, 24, 20, 2 )
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice(  1, 2, 23, 19, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                ENDIF
            ENDIF                          // LastRec
            cdrawno := SubStr( Drawing->Drawno, 1, 4 )
            mwhere := "S"
            npl    := 20
            nl     := 0

            Printsel()                               // _LF_Init

            IF mwhere == "P"
                npl := 64
                @  0, 0
                SET DEVICE TO PRINT
            ENDIF
            @ nl, 2 SAY Control->U_Name
            @ nl, 42 SAY "Drawings"
            @ nl, 62 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            nl += 2
            SELECT Drawing
            GOTO TOP
            SEEK cdrawno
            DO WHILE Drawing->Drawno = cdrawno .AND. Drawing->( !Eof() )
                // **          IF SUBSTR( Drawing->Drawno, 1, 4 ) != SUBSTR( cdrawno, 1, 4 )
                // **             SKIP ALIAS Drawing
                // **             LOOP
                // **          ENDIF
                IF SubStr( Control->U_Name, 1, 4 ) = "SHAN"
                    @ nl, 1 SAY Drawing->Desc
                ELSE
                    @ nl, 1 SAY Drawing->Desc
                    @ nl, 42 SAY Drawing->Drawno
                    @ nl, 53 SAY Drawing->DrawLoc
                ENDIF
                nl++
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        Inkey( 0 )
                        Scroll()
                    ENDIF
                    nl := 0
                ENDIF             // npl
                SKIP ALIAS Drawing
            ENDDO                        // Drawing EOF
            IF mwhere = "P"
                // **   @ nl, 0 SAY " "
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
            LOOP


            // **    CASE nselect == 4
            // **       PartDraw()                  // JobDmnd.PRG
            // **     LOOP
        ENDCASE
        manother := "Y"
        // *** ApGetY( Message->Another )
    ENDDO                                       // manother

    RETURN NIL
// **--- End JobDraw()

// ***----------------------------------------------------------------------

FUNCTION CutsReview()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        crate := "N"
        aPart_ := {}
        nrecno   := 0
        SELECT Progress
        GOTO TOP
        DO WHILE Progress->( !Eof() )
            IF Progress->DescProg != Space( 12 )
                SKIP ALIAS Progress
                LOOP
            ENDIF
            AAdd( aPart_, Progress->Operno;
                + "  " + Progress->Desc;
                + "                           " + Str( RecNo(), 6 ) )
            SKIP ALIAS Progress
        ENDDO                        // Progress EOF
        Scroll()
        DispBox( 0, 0, 2, 78, 2 )
        @  1, 17 SAY "Cuts Review   "
        @  1, 62 SAY "Esc to Exit" COLOR "G+"
        DispBox( 3, 0, 24, 80, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
            IF LastKey() = 27
                RETURN NIL
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
        ENDIF
        coperno := Progress->Operno
        cdesc   := Progress->Desc
        @ Row(), 2 SAY Progress->Operno COLOR "RG+"
        @ Row(), 13 GET cdesc   PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        @ Row(), 62 GET crate VALID( crate $ "NY " ) PICTURE "@!"
        READ
        ApRLock( 3 )
        Progress->Desc   := cdesc
        IF crate = "Y"
            DELETE
        ENDIF
        UNLOCK
        IF LastKey() = 27
            RETURN NIL
        ENDIF
        LOOP
    ENDDO                                        // mcontinue

    RETURN NIL
// **--- End CutsReview()

// ***----------------------------------------------------------------------

FUNCTION ProgMessage( coperno )

    Scroll( 0, 0, 24, 26 )
    DispBox( 1, 0, 24, 26, 2 )
    ncount := 1
    @  2, 5 SAY coperno COLOR "RG+"
    IF coperno = "XX      " .OR. coperno = Space( 8 )
        coperno := "GENERAL"
    ENDIF
    @ nl, 15 SAY coperno COLOR "RG+"
    nl := 5
    SELECT Progress
    GOTO TOP
    SEEK coperno
    DO WHILE Progress->Operno = coperno .AND. Progress->( !Eof() )
        IF Progress->DescProg = "     "
            SKIP ALIAS Progress
            LOOP
        ENDIF
        IF Progress->Order = "  "
            SKIP ALIAS Progress
            LOOP
        ENDIF
        @ nl, 5 SAY ncount PICTURE "99"
        @ nl, Col() + 2 SAY Progress->DescProg
        nl++
        ncount++
        SKIP ALIAS Progress
    ENDDO                      // EOF
    Inkey( 1 )
    Scroll( 0, 0, 24, 26 )

    RETURN coperno

// **--- End ProgMessage()

// ***----------------------------------------------------------------------

FUNCTION ProgDesc()

    coperno := Space( 8 )
    manother := "Y"
    DO WHILE manother = "Y"
        coperno := Space( 8 )
        GroupSelect( @coperno )
        Scroll()
        // **   ProgMessage( @coperno )
        DispBox( 0, 0, 2, 65, 2 )
        @ 1, 8 SAY "Viewing Progress  " + coperno COLOR "RG+"
        aPart_ := {}
        nrecno   := 0
        SELECT Progress
        GOTO TOP
        DO WHILE Progress->( !Eof() )
            IF Progress->Desc != Space( 40 )
                SKIP ALIAS Progress
                LOOP
            ENDIF
            IF Progress->Operno != coperno
                SKIP ALIAS Progress
                LOOP
            ENDIF
            AAdd( aPart_, Progress->Operno;
                + "  " + Progress->Order;
                + "  " + Progress->DescProg;
                + "                           " + Str( RecNo(), 6 ) )
            SKIP ALIAS Progress
        ENDDO                        // Progress EOF
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 40, 24, 79, 2 )
            anum := AChoice(  4, 42, 23, 78, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            IF PressedEsc()
                RETURN NIL
            ENDIF
            coperno := Progress->Operno
            DispBox(  8, 0, 18, 39, 2 )
            nl := 10
            @ nl, 5 SAY Progress->Operno + "  " + Progress->Order;
                + "  " + Progress->DescProg COLOR "RG+"
            nl += 2
            @ nl, 5 SAY "Product " + coperno
            nl += 2
            @ nl, 5 SAY "Order   " + Progress->Order
            nl += 2
            @ nl, 5 SAY "   Desc " + Progress->DescProg
        ENDIF                        // Empty
        nselect  := 1
        Scroll(  20, 0, 24, 80 )
        DispBox( 20, 0, 24, 79, 2 )
        @ 20, 5 SAY "  -- Progress by Product --  "
        @ 22, 3      PROMPT " "
        @ 22, Col() + 2 PROMPT "1. Edit"
        @ 22, Col() + 2 PROMPT "2. Add New"
        @ 22, Col() + 2 PROMPT "3. Print"
        @ 22, Col() + 2 PROMPT "4. Delete"
        @ 22, Col() + 2 PROMPT "5. Review"
        @ 22, Col() + 2 PROMPT "6. Exit"
        MENU TO nselect

        DO CASE
        CASE nselect == 7 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 1                // Loop
            LOOP

        CASE nselect == 2                // Edit Progress
            mcorrect := "Y"
            DO WHILE mcorrect = "Y"
                aPart_ := {}
                nrecno   := 0
                SELECT Progress
                GOTO TOP
                DO WHILE Progress->( !Eof() )
                    IF Progress->Desc != Space( 40 )
                        SKIP ALIAS Progress
                        LOOP
                    ENDIF
                    IF Progress->Operno != coperno
                        SKIP ALIAS Progress
                        LOOP
                    ENDIF
                    AAdd( aPart_, Progress->Operno;
                        + "  " + Progress->Order;
                        + "  " + Progress->DescProg;
                        + "                           " + Str( RecNo(), 6 ) )
                    SKIP ALIAS Progress
                ENDDO                        // Progress EOF
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    Scroll(  3, 0, 24, 80 )
                    DispBox( 3, 40, 24, 79, 2 )
                    anum := AChoice(  4, 42, 23, 78, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    GOTO nrecno
                    coperno := Progress->Operno
                ENDIF                        // Empty
                SELECT Progress
                DispBox(  8, 0, 18, 39, 2 )
                nl :=  9
                @ nl, 10 SAY Progress->Operno + "  " + Progress->Order;
                    + "  " + Progress->DescProg COLOR "RG+"
                nl += 2
                ApRlock( 3 )
                @ nl, 5 SAY "Product " + coperno
                nl += 2
                @ nl, 5 SAY "Order" GET Progress->ORDER    PICTURE "99"
                nl += 2
                @ nl, 5 SAY " Desc" GET Progress->DescProg PICTURE "!XXXXXXXXXXX"
                nl += 2
                @ nl, 20 SAY "Esc to Exit" COLOR "BG+"
                READ
                UNLOCK
                IF PressedEsc()
                    mcorrect := "N"
                    ProgDesc()
                ENDIF
            ENDDO
            LOOP

        CASE nselect == 3                // Add Progress
            mcorrect := "Y"
            DO WHILE mcorrect = "Y"
                aPart_ := {}
                nrecno   := 0
                SELECT Progress
                GOTO TOP
                DO WHILE Progress->( !Eof() )
                    IF Progress->Desc != Space( 40 )
                        SKIP ALIAS Progress
                        LOOP
                    ENDIF
                    IF Progress->Operno != coperno
                        SKIP ALIAS Progress
                        LOOP
                    ENDIF
                    AAdd( aPart_, Progress->Operno;
                        + "  " + Progress->Order;
                        + "  " + Progress->DescProg;
                        + "                           " + Str( RecNo(), 6 ) )
                    SKIP ALIAS Progress
                ENDDO                        // Progress EOF
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    Scroll(  3, 0, 24, 80 )
                    DispBox( 3, 40, 24, 79, 2 )
                    anum := AChoice(  4, 42, 23, 78, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    GOTO nrecno
                    coperno := Progress->Operno
                ENDIF                        // Empty
                @  6, 5 SAY "Maximum 18 entries" COLOR "BG+"
                DispBox(  8, 0, 18, 39, 2 )
                nl := 9
                @ nl, 10 SAY Progress->Operno + "  " + Progress->Order;
                    + "  " + Progress->DescProg COLOR "RG+"
                SELECT Progress
                ApFlock( 3 )
                APPEND BLANK
                Progress->Operno := coperno
                Progress->Date    := Date()
                UNLOCK
                nl += 2
                ApRlock( 3 )
                @ nl, 5 SAY "Group " + coperno
                nl += 2
                @ nl, 5 SAY "Order" GET Progress->ORDER    PICTURE "99"
                nl += 2
                @ nl, 5 SAY " Desc" GET Progress->DescProg PICTURE "!XXXXXXXXXXX"
                nl += 2
                @ nl, 20 SAY "Esc to Exit" COLOR "BG+"
                READ
                UNLOCK
                IF PressedEsc()
                    mcorrect := "N"
                    ProgDesc()
                ENDIF
            ENDDO
            LOOP

        CASE nselect == 4                 // Print
            mwhere := "S"
            npl    := 20
            nl     := 0

            Printsel()                               // _LF_Init

            IF mwhere == "P"
                npl := 64
                @  0, 0
                SET DEVICE TO PRINT
            ENDIF
            @ nl, 2 SAY Control->U_Name
            @ nl, 42 SAY "Progress"
            @ nl, 62 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            nl += 2
            SELECT Progress
            GOTO TOP
            DO WHILE Progress->( !Eof() )
                IF Progress->DescProg = "         "
                    SKIP ALIAS Progress
                    LOOP
                ENDIF
                @ nl, 1 SAY Progress->Operno
                @ nl, 11 SAY Progress->Order
                @ nl, 14 SAY Progress->DescProg
                nl++
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        Inkey( 0 )
                        Scroll()
                    ENDIF
                    nl := 0
                ENDIF             // npl
                SKIP ALIAS Progress
            ENDDO                        // Progress EOF
            IF mwhere = "P"
                // **   @ nl, 0 SAY " "
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
            LOOP

        CASE nselect == 5                     // Delete Progress
            Scroll(  14, 0, 19, 80 )
            DispBox( 14, 1, 19, 79, 2 )
            nl := 16
            @ nl, 5 SAY Progress->Operno + "  " + Progress->DescProg;
                + " " + Progress->Order + " " + Progress->Desc COLOR "BG+"
            cstring := Trim( Message->Suredel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mok == "Y"
                ApFLock( 3 )
                DELETE
                UNLOCK
            ENDIF
            LOOP

        CASE nselect == 6                     // Review Progress
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
                crate := "N"
                aPart_ := {}
                nrecno   := 0
                SELECT Progress
                GOTO TOP
                DO WHILE Progress->( !Eof() )
                    IF Progress->Desc != Space( 40 )
                        SKIP ALIAS Progress
                        LOOP
                    ENDIF
                    AAdd( aPart_, Progress->Operno;
                        + "  " + Progress->Order;
                        + "  " + Progress->DescProg;
                        + "                           " + Str( RecNo(), 6 ) )
                    SKIP ALIAS Progress
                ENDDO                        // Progress EOF
                Scroll()
                DispBox( 0, 0, 2, 45, 2 )
                @  1, 17 SAY "Product Progress   " + coperno
                @  1, 62 SAY "Esc to Exit" COLOR "G+"
                DispBox( 3, 0, 24, 45, 2 )
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice( 4, 3, 23, 42, aPart_,, "AFUNC" )
                    IF LastKey() = 27
                        EXIT
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                ENDIF
                coperno   := Progress->Operno
                corder    := Progress->Order
                cdescprog := Progress->DescProg

                @ Row(), 2 GET coperno   PICTURE "@X"
                @ Row(), 12 GET corder    PICTURE "99"
                @ Row(), 17 GET cdescprog PICTURE "!XXXXXXXXXXX"
                @ Row(), 34 GET crate VALID( crate $ "NY " ) PICTURE "@!"
                READ
                ApRLock( 3 )
                Progress->Operno   := coperno
                Progress->Order    := corder
                Progress->DescProg := cdescProg
                IF crate = "Y"
                    DELETE
                ENDIF
                UNLOCK
                IF LastKey() = 27
                    mcontinue := "N"
                    ProgDesc()
                ENDIF
                LOOP
            ENDDO                                        // mcontinue

        ENDCASE
        manother := "Y"
        // *** ApGetY( Message->Another )
    ENDDO                                       // manother

    RETURN NIL
// **--- End ProgDesc()

// ***----------------------------------------------------------------------

STATIC FUNCTION AdminABC()

    Scroll()
    DispBox( 0, 1, 2, 79, 2 )
    @ 1, 8 SAY "Viewing Administration  " + Admin->Adminno COLOR "BG+"
    DispBox( 0, 1, 24, 79, 2 )
    SELECT Admin
    nselect := 1
    DO CASE
    CASE Admin->ABC = Menu1->Accom1
        nselect := 1
    CASE Admin->ABC = Menu1->Accom2
        nselect := 2
    CASE Admin->ABC = Menu1->Accom3
        nselect := 3
    CASE Admin->ABC = Menu1->Accom3
        nselect := 3
    CASE Admin->ABC = Menu1->Accom4
        nselect := 4
    CASE Admin->ABC = Menu1->Accom5
        nselect := 5
    CASE Admin->ABC = Menu1->Accom5
        nselect := 5
    CASE Admin->ABC = Menu1->Accom6
        nselect := 5
    CASE Admin->ABC = Menu1->Accom7
        nselect := 7
    CASE Admin->ABC = Menu1->Accom8
        nselect := 8
    CASE Admin->ABC = Menu1->Accom9
        nselect := 9
    ENDCASE
    @  5, 58 SAY "Admin ABC = " + Admin->ABC
    @  6, 58 PROMPT "1." + Menu1->Accom1
    @  7, 58 PROMPT "2." + Menu1->Accom2
    @  8, 58 PROMPT "3." + Menu1->Accom3
    @  9, 58 PROMPT "4." + Menu1->Accom4
    @ 10, 58 PROMPT "5." + Menu1->Accom5
    @ 11, 58 PROMPT "6." + Menu1->Accom6
    @ 12, 58 PROMPT "7." + Menu1->Accom7
    @ 13, 58 PROMPT "8." + Menu1->Accom8
    @ 14, 58 PROMPT "9." + Menu1->Accom9
    MENU TO nselect
    SELECT Admin
    ApRlock( 3 )
    DO CASE
    CASE nselect == 1
        Admin->ABC := Menu1->Accom1
    CASE nselect == 2
        Admin->ABC := Menu1->Accom2
    CASE nselect == 3
        Admin->ABC := Menu1->Accom3
    CASE nselect == 4
        Admin->ABC := Menu1->Accom4
    CASE nselect == 5
        Admin->ABC := Menu1->Accom5
    CASE nselect == 6
        Admin->ABC := Menu1->Accom6
    CASE nselect == 7
        Admin->ABC := Menu1->Accom7
    CASE nselect == 8
        Admin->ABC := Menu1->Accom8
    CASE nselect == 9
        Admin->ABC := Menu1->Accom9
    ENDCASE
    @ 10, 6 SAY Admin->Adminno COLOR "BG+"
    @ 12, 6 SAY "Order" GET Admin->Adminno PICTURE "@X"
    @ 14, 6 SAY "Activ" GET Admin->Abc     PICTURE "@X"
    @ 16, 6 SAY "Desc " GET Admin->Desc    PICTURE "@X"
    @ 18, 6 SAY "Date " GET Admin->DATE    PICTURE "99/99/9999"
    READ
    UNLOCK

    RETURN NIL

FUNCTION JobAdmin()

    SELECT Admin
    // ** IF LASTREC() != 0
    cadminno := Space( 8 )
    manother := "Y"
    DO WHILE manother = "Y"
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @ 1, 8 SAY "Viewing Administration"
        aPart_ := {}
        nrecno   := 0
        GOTO TOP
        DO WHILE Admin->( !Eof() )
            AAdd( aPart_, Admin->Adminno;
                + " " + Admin->Desc + "  " + Admin->ABC;
                + "                          " + Str( RecNo(), 6 ) )
            SKIP ALIAS Admin
        ENDDO                        // Admin EOF
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 1, 24, 79, 2 )
            anum := AChoice(  4, 5, 23, 76, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            Scroll(  8, 0, 24, 80 )
            DispBox( 8, 1, 19, 79, 2 )
            @ 10, 6 SAY Admin->Adminno COLOR "BG+"
            @ 12, 6 SAY "Activ " + Admin->Abc  PICTURE "@X"
            @ 14, 6 SAY "Desc  " + Admin->Desc PICTURE "@X"
            @ 16, 6 SAY Admin->DATE          PICTURE "99/99/9999"
            IF PressedEsc()
                RETURN NIL
            ENDIF
            cadminno := Admin->Adminno
        ENDIF                        // Empty
        nselect  := 1
        Scroll(  20, 0, 24, 80 )
        DispBox( 20, 1, 24, 79, 2 )
        @ 22, 8      PROMPT "Add Admin"
        @ 22, Col() + 2 PROMPT "Edit Admin"
        @ 22, Col() + 2 PROMPT "Delete"
        @ 22, Col() + 2 PROMPT "Exit"
        MENU TO nselect
        DO CASE
        CASE nselect == 4 .OR. PressedEsc()
            RETURN NIL

        CASE nselect == 1                // Add Admin
            Scroll()
            cadbc := Space( 12 )
            @  4, 58 SAY Menu1->Record PICTURE "9999"
            @  6, 58 PROMPT "1." + Menu1->Accom1
            @  7, 58 PROMPT "2." + Menu1->Accom2
            @  8, 58 PROMPT "3." + Menu1->Accom3
            @  9, 58 PROMPT "4." + Menu1->Accom4
            @ 10, 58 PROMPT "5." + Menu1->Accom5
            @ 11, 58 PROMPT "6." + Menu1->Accom6
            @ 12, 58 PROMPT "7." + Menu1->Accom7
            @ 13, 58 PROMPT "8." + Menu1->Accom8
            @ 14, 58 PROMPT "9." + Menu1->Accom9
            MENU TO nselect
            SELECT Admin
            DO CASE
            CASE nselect == 1
                cABC := Menu1->Accom1
            CASE nselect == 2
                cABC := Menu1->Accom2
            CASE nselect == 3
                cABC := Menu1->Accom3
            CASE nselect == 4
                cABC := Menu1->Accom4
            CASE nselect == 5
                cABC := Menu1->Accom5
            CASE nselect == 6
                cABC := Menu1->Accom6
            CASE nselect == 7
                cABC := Menu1->Accom7
            CASE nselect == 8
                cABC := Menu1->Accom8
            CASE nselect == 9
                cABC := Menu1->Accom9
            ENDCASE
            SELECT Menu1
            ApFLock( 3 )
            Menu1->Record := ( Menu1->Record + 1 )
            @  2, 2 SAY "Printing Order you can Change" GET Menu1->Record PICTURE "9999"
            READ
            UNLOCK
            nserno := Menu1->Record
            mserno := Str( nserno, 4 )
            SELECT Admin
            // **         SCROLL()
            // **         DISPBOX( 0, 0, 19,79, 2 )
            cadminno := Trim( cABC ) + LTrim( mserno )
            @ 10, 10 SAY "Ref #"  GET cadminno PICTURE "@!"
            READ
            SEEK cadminno
            DO WHILE Found()
                @ 10, 40 SAY "Already Used Try Again"
                @ 10, 10 SAY "Ref #" GET cadminno PICTURE "@!"
                READ
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                SEEK cadminno
            ENDDO
            IF !Found()
                ApFlock( 3 )
                APPEND BLANK
                Admin->Adminno := cadminno
                Admin->Date    := Date()
                UNLOCK
            ENDIF
            ApRlock( 3 )
            Admin->Abc := cAbc
            @ 12, 6      SAY Admin->Adminno      COLOR "BG+"
            @ 12, Col() + 2 SAY "Activity " + Admin->Abc COLOR "BG+"
            @ 14, 6      SAY "Desc " GET Admin->Desc PICTURE "@X"
            @ 16, 6      SAY "Date " GET Admin->DATE PICTURE "99/99/9999"
            READ
            UNLOCK
            // **          AdminAbc()
            LOOP

        CASE nselect == 2                // Admin Edit
            AdminAbc()
            LOOP

        CASE nselect == 3                     // Delete Admin
            Scroll(  19, 0, 24, 80  )
            cstring := Trim( Message->Suredel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mok == "Y"
                ApFLock( 3 )
                DELETE
                UNLOCK
            ENDIF
            LOOP
        ENDCASE
        manother := ApGetY( Message->Another )
    ENDDO                                       // manother

    RETURN NIL
// **--- End JobAdmin()

// ***----------------------------------------------------------

FUNCTION JobLabour()

    minvno  := "20" + Space( 4 )
    mcodeno := Space( 8 )
    Scroll()
    DispBox( 12, 1, 16, 79, 2 )
    @ 14, 10      SAY "JC- or Invno" GET minvno   PICTURE "@!"
    @ 14, Col() + 2 SAY "Blank to View JC- or Invoice"
    READ
    IF PressedEsc()
        RETURN NIL
    ENDIF
    SELECT Debit
    SET ORDER TO 2                      // Invno
    GOTO TOP
    SEEK minvno
    SELECT Debit
    SET ORDER TO 1
    IF Found()
        minvno  := Debit->Invno
        mcodeno := Debit->Codeno
    ENDIF
    IF !Found() .OR. minvno = Space( 6 )
        // **      SELECT Debit
        // **      SET ORDER TO 1
        GOTO TOP
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
                + " " + Str( Debit->Amount, 8, 2 ) + " " + Debit->Saleno;
                + " " + Debit->Est + "                        " + Str( RecNo(), 6 ) )
            SKIP ALIAS Debit
        ENDDO
        IF !Empty( aPart_ )
            Scroll()
            DispBox(  0, 0, 24, 79, 2 )
            ASort( aPart_,,, {| x, y | x < y } )
            anum   := AChoice(  1, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
            IF PressedEsc()
                RETURN NIL
            ENDIF
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
            GOTO nrecno
            minvno  := Debit->Invno
            mcodeno := Debit->Codeno
        ENDIF                     // Empty
    ENDIF                        // LastRec
    manother := "Y"
    DO WHILE manother = "Y"
        SELECT Name
        SEEK Debit->Codeno
        clabno := Space( 8 )
        aPart_ := {}
        nrecno := 0
        SELECT Labour
        SET ORDER TO 2                   // Invno
        GOTO TOP
        DO WHILE Labour->( !Eof() )
            // **    IF minvno != SPACE( 6 )
            IF Labour->Invno != minvno
                SKIP ALIAS Labour
                LOOP
            ENDIF
            // **     ENDIF                            // minvno
            AAdd( aPart_, Labour->Invno;
                + " " + Labour->Codeno;
                + " " + SubStr( Labour->Desc, 1, 24 );
                + " " + Str( Labour->Time, 7, 2 );
                + " " + Str( Labour->Rate, 7, 2 );
                + " " + DToC( Labour->Date );
                + " " + Labour->Labno;
                + "     " + Str( RecNo(), 6 ) )
            // **      minvno := Labour->Invno
            SKIP ALIAS Labour
        ENDDO                        // Labour EOF
        IF !Empty( aPart_ )
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @  1, 6 SAY Name->Name + "  " + Debit->Invno COLOR "BG+"
            ASort( aPart_,,, {| x, y | x < y } )
            DispBox( 3, 1, 24, 79, 2 )
            anum := AChoice(  4, 3, 23, 78, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
            GOTO nrecno
            clabno  := Labour->Labno
            // **      mcodeno := Labour->Codeno
        ENDIF                        // Empty
        SELECT Labour
        SET ORDER TO 1               // Codeno
        nselect := 1
        Scroll(  20, 0, 24, 80 )
        DispBox( 20, 1, 24, 79, 2 )
        @ 20, 10      SAY "  -- Labour --  "
        @ 22, 10      PROMPT "Add Labour"
        @ 22, Col() + 2 PROMPT "Edit Labour"
        @ 22, Col() + 2 PROMPT "Print JC"

        @ 23, 10      PROMPT "Delete Entry"
        @ 23, Col() + 2 PROMPT "Delete General"

        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nselect == 1                // Add Labour

            SELECT Name
            GOTO TOP
            cStaffCode := Space( 8 )
            aPart_ := {}
            nrecno := 0
            IF LastRec() != 0
                DO WHILE  Name->( !Eof() )
                    IF Name->Sale != "STAF"
                        SKIP ALIAS Name
                        LOOP
                    ENDIF
                    AAdd( aPart_, ( Name->Codeno + "   " + SubStr( Name->Name,1,26 );
                        + " " + SubStr( Name->Add1, 1, 20 );
                        + " " + Name->Phone;
                        + "                          " + Str( RecNo(), 6 ) ) )
                    SKIP ALIAS Name
                ENDDO
                Scroll()
                DispBox( 0, 1,  2, 79, 2 )
                @  1, 10 SAY "Adding Labour Name"
                DispBox( 3, 1, 21, 79, 2 )
                IF !Empty( aPart_ )
                    ASort( aCatcode_,,, {| x, y | x < y } )
                    anum := AChoice( 4, 5, 20, 76, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    GOTO nrecno
                    cStaffcode := Name->Codeno
                ENDIF
            ENDIF           // LastRec
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
                Scroll()
                DispBox( 0, 1, 2, 79, 2 )
                SELECT Name
                SEEK cStaffcode
                @ 1, 6 SAY cStaffcode + "  " + Name->Name COLOR "BG+"
                SELECT Labour
                ApFLock( 3 )
                APPEND BLANK
                Labour->Codeno := cStaffCode
                Labour->Date   := Date()
                Labour->Invno  := Debit->Invno
                Labour->Desc   := Debit->Est
                Labour->Labno  := Debit->Codeno
                UNLOCK
                mdesc    := Labour->Desc
                mmessage := Labour->Message
                mfault   := Labour->Fault
                ntime    := Labour->Time
                nrate    := Labour->Rate
                ddate    := Labour->Date
                Scroll(  14, 0, 24, 80 )
                DispBox( 14, 1, 22, 79, 2 )
                @ 15, 5      SAY Labour->Labno + " JC- " + Labour->Invno
                @ 17, 5      SAY "Labour Desc" GET mdesc     PICTURE "@K"
                @ 18, 17                        GET mmessage  PICTURE "@K"
                @ 19, 17                        GET mfault    PICTURE "@K"
                @ 21, 5      SAY "Labour Time" GET ntime     PICTURE "99.99"
                // **     @ 21,COL()+2 SAY "Cost"        GET nrate     PICTURE "99999.99"
                @ 21, Col() + 2                   GET ddate     PICTURE "99/99/9999"
                READ
                ApFLock( 3 )
                Labour->Desc    := mdesc
                Labour->Message := mmessage
                Labour->Fault   := mfault
                Labour->Time    := ntime
                Labour->Rate    := nrate
                Labour->Date    := ddate
                UNLOCK
                mcontinue := ApGetY( Message->Another )
            ENDDO                                       // manother
            LOOP

        CASE nselect == 2                // Edit Labour
            SELECT Name
            SEEK Labour->Codeno
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @ 1, 8 SAY mcodeno + " " + Name->Name
            DispBox( 3, 1, 18, 79, 2 )
            nl := 5
            SELECT Labour
            minvno   := Labour->Invno
            mlabno   := Labour->Labno
            mdesc    := Labour->Desc
            mmessage := Labour->Message
            mfault   := Labour->Fault
            mpartnum := Labour->Partnum
            mcodeno  := Labour->Codeno
            ntime    := Labour->Time
            nrate    := Labour->Rate
            ddate    := Labour->Date
            @ nl, 10      SAY "Ref #"       GET mlabno   PICTURE "@!"
            @ nl, Col() + 2 SAY "Desc"        GET mdesc    PICTURE "@X"
            nl++
            @ nl, 15                        GET mmessage PICTURE "@X"
            nl++
            @ nl, 15                        GET mfault   PICTURE "@X"
            nl += 2
            @ nl, 10      SAY "Date"        GET ddate   PICTURE "99/99/9999"
            @ nl, Col() + 2 SAY "Time"        GET ntime   PICTURE "99999.99"
            @ nl, Col() + 2 SAY "Cost"        GET nrate   PICTURE "99999.99"
            nl += 2
            @ nl, 10      SAY "JC-"         GET minvno
            @ nl, Col() + 2 SAY "Partnum"     GET mpartnum
            nl += 2
            @ nl, 10      SAY "Name Codeno" GET mcodeno
            READ
            ApRlock( 3 )
            Labour->Desc    := mdesc
            Labour->Message := mmessage
            Labour->Fault   := mfault
            Labour->Time    := ntime
            Labour->Rate    := nrate
            Labour->Date    := ddate
            Labour->Invno   := minvno
            Labour->Labno   := mlabno
            Labour->Partnum := mpartnum
            Labour->Codeno  := mcodeno
            UNLOCK
            LOOP
        CASE nselect == 3                // Print Labour
            Labprint()           //
            LOOP

        CASE nselect == 4                // Delete Job
            Scroll(  12, 0, 24, 80  )
            DispBox( 12, 1, 18, 79, 2 )
            @ 13, 6      SAY Labour->Codeno + "     " + Labour->Labno
            @ 15, 6      SAY "Desc        " + Labour->Desc
            @ 15, Col() + 2 SAY "Date " + DToC( Labour->Date )
            @ 17, 6      SAY "Time " + Str( Labour->Time )
            @ 17, Col() + 2 SAY "JC- " + Labour->Invno
            minvno  := Labour->Invno
            cstring := Trim( Message->Suredel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mok == "Y"
                ApFLock( 3 )
                DELETE
                UNLOCK
                // **            mdelete := ApGetN( "Delete ALL FOR INVOICE" )
                // **            IF mdelete == "Y"
                // **                ApFLock( 3 )
                // **               DELETE ALL FOR Labour->Invno = minvno
                // **               UNLOCK
                // **            ENDIF
            ENDIF
        CASE nselect == 5
            Scroll(  14, 0, 24, 80  )
            DispBox( 14, 1, 19, 79, 2 )
            nDays := 60
            @ 15, 5 SAY "Delete's All for Labour Invno 1st Char = Blank"
            @ 16, 5 SAY "How Many Days Back (Minimum 30 days )" GET nDays PICTURE "999"
            READ
            IF nDays < 30
                nDays := 30
                @ 17, 5 SAY "Minimum is 30 so Changed to 30"
            ENDIF
            mok := ApGetN( "Delete as above" )
            IF mok = "Y"
                SELECT Labour
                GOTO TOP
                ApFLock( 3 )
                DELETE ALL FOR SubStr( Labour->Invno, 1, 1 ) = Space( 1 );
                    .AND. Labour->Date < Date() -nDays
                UNLOCK
            ENDIF
            LOOP
        ENDCASE
        manother := "Y"
        // **  ApGetY( Message->Another )
    ENDDO                                       // manother

    RETURN NIL
// **--- End JobLabour()

// ****-------------------------------------------------------------------------

FUNCTION JobDemAdd( mjobnum )

    manother := "Y"
    DO WHILE manother = "Y"
        coperno := cadminno := cdrawno := Space( 8 )
        aPart_ := {}
        nrecno  := 0
        Scroll(  0, 0, 2, 80 )
        DispBox( 0, 1, 2, 79, 2 )
        @ 1, 10 SAY Job->Jobnum + " " + Trim( Job->Desc ) + " " + Job->Codeno
        mjobnum := Job->Jobnum
        SELECT Demand
        SET ORDER TO 1                   // Operno
        SEEK mjobnum
        DO WHILE Demand->Jobnum = mjobnum .AND. Demand->( !Eof() )
            AAdd( aPart_, LTrim( Demand->Operno ) + LTrim( Demand->Adminno );
                + LTrim( Demand->Drawno );
                + "  " + Demand->Desc;
                + "  " + DToC( Demand->StartDate );
                + "  " + DToC( Demand->DueDate );
                + "     " + Str( RecNo(), 6 ) )
            SKIP ALIAS Demand
        ENDDO                        // Operate EOF
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 1, 18, 79, 2 )
            anum := AChoice(  4, 5, 17, 76, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
   /*  TAKEN OUT
         SCROLL(  9, 0, 24,80 )
         DISPBOX( 9, 1, 18,79, 2 )
         nl := 10
         @ nl, 7 SAY Demand->Operno+" "+Demand->Adminno+" "+Demand->Drawno;
                     +" "+DTOC( Demand->StartDate )
          ApRlock( 3 )
         @ nl,15      SAY "Desc "      GET Demand->Desc PICTURE "@X"
         nl+=2
         @ nl,12      SAY "Start Date" GET Demand->StartDate PICTURE "99/99/9999"
         @ nl,COL()+2 SAY "Due Date"   GET Demand->DueDate   PICTURE "99/99/9999"
          READ
         coperno  := Demand->Operno
         cadminno := Demand->Adminno
         cdrawno  := Demand->Drawno
         UNLOCK
   */
        ENDIF                        // Empty
        nselect  := 1
        Scroll(  20, 0, 24, 80 )
        DispBox( 20, 1, 24, 79 )
        @ 22, 5      PROMPT "Exit"
        @ 22, Col() + 2 PROMPT "Process Add"
        @ 22, Col() + 1 PROMPT "Del Proc"
        @ 22, Col() + 1 PROMPT "Admin Add"
        @ 22, Col() + 1 PROMPT "Del Admin"
        @ 22, Col() + 1 PROMPT "Drawing Add"
        @ 22, Col() + 1 PROMPT "Del Draw"

        MENU TO nselect
        DO CASE
        CASE nselect == 1 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 2                 // Add Operation
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @ 1, 8 SAY "Viewing Part Operations"
            aPart_ := {}
            nrecno   := 0
            SELECT Operate
            GOTO TOP
            DO WHILE Operate->( !Eof() )
                AAdd( aPart_, Operate->Operno;
                    + " " + Operate->Desc;
                    + "                                    " + Str( RecNo(), 6 ) )
                SKIP ALIAS Operate
            ENDDO                        // Operate EOF
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                Scroll(  3, 0, 24, 80 )
                DispBox( 3, 1, 18, 79, 2 )
                anum := AChoice(  4, 5, 17, 75, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                Scroll(  9, 0, 24, 80 )
                DispBox( 9, 1, 18, 79, 2 )
                @ 10, 10 SAY Operate->Operno
                @ 12, 10 SAY "Desc " + Operate->Desc
                coperno := Operate->Operno
            ENDIF                        // Empty
            SELECT Demand
            ApFlock( 3 )
            APPEND BLANK
            Demand->Jobnum    := mjobnum
            Demand->Operno    := coperno
            Demand->StartDate := Date()
            Demand->DueDate   := Date() + 30
            nl := 14
            @ nl, 10      SAY "Demand Desc" GET Demand->Desc      PICTURE "@X"
            nl += 2
            @ nl, 11      SAY "Start Date"  GET Demand->StartDate PICTURE "99/99/9999"
            @ nl, Col() + 2 SAY "Due Date"    GET Demand->DueDate   PICTURE "99/99/9999"
            READ
            UNLOCK
            LOOP

        CASE nselect == 3                 // Delete Operation
            SELECT Demand
            aPart_ := {}
            nrecno  := 0
            SET ORDER TO 1                       // Operno
            GOTO TOP
            SEEK mjobnum
            DO WHILE Demand->Jobnum = mjobnum .AND. Demand->( !Eof() )
                IF Demand->Operno = Space( 8 )
                    SKIP ALIAS Demand
                    LOOP
                ENDIF
                SELECT Operate
                SEEK Demand->Operno
                SELECT Demand
                AAdd( aPart_, Demand->Operno;
                    + " " + Operate->Desc;
                    + " " + SubStr( Demand->Desc, 1, 10 );
                    + "     " + Str( RecNo(), 6 ) )
                SKIP ALIAS Demand
            ENDDO                        // Operate EOF
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                Scroll(  3, 0, 24, 80 )
                DispBox( 3, 1, 18, 79, 2 )
                anum := AChoice(  4, 5, 17, 76, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                Scroll(  9, 0, 24, 80 )
                DispBox( 9, 3, 18, 79, 2 )
                nl := 10
                @ nl, 7 SAY Demand->Operno + " " + DToC( Demand->StartDate )
                cstring := Trim( Message->Suredel )
                mok := ApCheck( cstring )                     // AppX.PRG
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                IF mok == "Y"
                    // **    SEEK mjobnum+coperno
                    // **    IF FOUND()
                    ApFLock( 3 )
                    DELETE
                    UNLOCK
                    // **    ENDIF
                ENDIF
            ENDIF                     // !Empty
            LOOP

        CASE nselect == 4                 // Add Admin
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @ 1, 8 SAY "Viewing Administration"
            cadminno := Space( 8 )
            aPart_ := {}
            nrecno   := 0
            SELECT Admin
            GOTO TOP
            DO WHILE Admin->( !Eof() )
                AAdd( aPart_, Admin->Adminno;
                    + " " + Admin->Desc;
                    + " " + DToC( Admin->Date );
                    + " " + Str( Admin->Quoted );
                    + "    " + Str( RecNo(), 6 ) )
                SKIP ALIAS Admin
            ENDDO                        // Admin EOF
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                Scroll(  3, 0, 24, 80 )
                DispBox( 3, 1, 24, 79, 2 )
                anum := AChoice(  4, 5, 23, 75, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                Scroll(  9, 0, 24, 80 )
                DispBox( 9, 1, 19, 79, 2 )
                @ 10, 10 SAY Admin->Adminno + "  " + DToC( Admin->Date )
                @ 12, 10 SAY "Administration Desc " + Admin->Desc
                cadminno := Admin->Adminno
            ENDIF                        // Empty
            SELECT Demand
            ApFlock( 3 )
            APPEND BLANK
            Demand->Jobnum    := mjobnum
            Demand->Adminno   := cadminno
            Demand->StartDate := Date()
            Demand->DueDate   := Date() + 30
            nl := 14
            @ nl, 10      SAY "Demand Desc" GET Demand->Desc      PICTURE "@X"
            nl += 2
            @ nl, 11      SAY "Start Date"  GET Demand->StartDate PICTURE "99/99/9999"
            @ nl, Col() + 2 SAY "Due Date"    GET Demand->DueDate   PICTURE "99/99/9999"
            READ
            UNLOCK
            LOOP

        CASE nselect == 5                 // Delete Admin
            SELECT Demand
            aPart_ := {}
            nrecno  := 0
            SET ORDER TO 2                       // Admin
            GOTO TOP
            SEEK mjobnum
            DO WHILE Demand->Jobnum = mjobnum .AND. Demand->( !Eof() )
                IF Demand->Adminno = Space( 8 )
                    SKIP ALIAS Demand
                    LOOP
                ENDIF
                SELECT Admin
                SEEK Demand->Adminno
                SELECT Demand
                AAdd( aPart_, Demand->Operno;
                    + " " + Admin->Desc;
                    + " " + SubStr( Demand->Desc, 1, 10 );
                    + "     " + Str( RecNo(), 6 ) )
                SKIP ALIAS Demand
            ENDDO                        // Operate EOF
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                Scroll(  3, 0, 24, 80 )
                DispBox( 3, 1, 24, 79, 2 )
                anum := AChoice(  4, 5, 23, 76, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                Scroll(  9, 0, 24, 80 )
                DispBox( 9, 1, 18, 79, 2 )
                nl := 10
                @ nl, 7 SAY Demand->Adminno + " " + DToC( Demand->StartDate )
                Scroll(  19, 0, 24, 80  )
                mok := "N"
                cstring := Trim( Message->Suredel )
                ApCheck( cstring )                     // AppX.PRG
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                IF mok == "Y"
                    ApFLock( 3 )
                    DELETE
                    UNLOCK
                ENDIF
            ENDIF
            LOOP

        CASE nselect == 6                 // Add Drawing
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @ 1, 8 SAY "Viewing Drawings"
            cdrawno := Space( 8 )
            aPart_ := {}
            nrecno   := 0
            SELECT Drawing
            GOTO TOP
            DO WHILE Drawing->( !Eof() )
                AAdd( aPart_, Drawing->Drawno;
                    + " " + Drawing->Desc;
                    + " " + DToC( Drawing->Date ) + " " + Drawing->Drawloc;
                    + "    " + Str( RecNo(), 6 ) )
                SKIP ALIAS Drawing
            ENDDO                        // Drawing EOF
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                Scroll(  3, 0, 24, 80 )
                DispBox( 3, 1, 24, 79, 2 )
                anum := AChoice(  4, 4, 23, 76, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                Scroll(  9, 0, 24, 80 )
                DispBox( 9, 1, 20, 79, 2 )
                @ 10, 10 SAY Drawing->Drawno + "  " + DToC( Drawing->Date )
                @ 12, 10 SAY "Drawing Desc " + Drawing->Desc
                cdrawno := Drawing->Drawno
            ENDIF                        // Empty
            SELECT Demand
            ApFlock( 3 )
            APPEND BLANK
            Demand->Jobnum    := mjobnum
            Demand->Drawno    := cdrawno
            Demand->StartDate := Date()
            Demand->DueDate   := Date() + 30
            nl := 14
            @ nl, 10      SAY "Demand Desc" GET Demand->Desc      PICTURE "@X"
            nl += 2
            @ nl, 11      SAY "Start Date"  GET Demand->StartDate PICTURE "99/99/9999"
            @ nl, Col() + 2 SAY "Due Date"    GET Demand->DueDate   PICTURE "99/99/9999"
            READ
            UNLOCK
            LOOP

        CASE nselect == 7                 // Delete Drawing
            SELECT Demand
            aPart_ := {}
            nrecno  := 0
            SET ORDER TO 3                       // Drawing
            GOTO TOP
            SEEK mjobnum
            DO WHILE Demand->Jobnum = mjobnum .AND. Demand->( !Eof() )
                IF Demand->Drawno = Space( 8 )
                    SKIP ALIAS Demand
                    LOOP
                ENDIF
                SELECT Drawing
                SEEK Demand->Drawno
                SELECT Demand
                AAdd( aPart_, Demand->Operno;
                    + " " + Drawing->Desc;
                    + " " + SubStr( Demand->Desc, 1, 10 );
                    + "     " + Str( RecNo(), 6 ) )
                SKIP ALIAS Demand
            ENDDO                        // Operate EOF
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                Scroll(  3, 0, 24, 80 )
                DispBox( 3, 1, 24, 79, 2 )
                anum := AChoice(  4, 5, 23, 76, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                Scroll(  9, 0, 24, 80 )
                DispBox( 9, 1, 18, 79, 2 )
                nl := 10
                @ nl, 7 SAY Demand->Drawno + " " + DToC( Demand->StartDate )
                Scroll( 19, 0, 24, 80 )
                cstring := Trim( Message->Suredel )
                mok := ApCheck( cstring )                     // AppX.PRG
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                IF mok == "Y"
                    ApFLock( 3 )
                    DELETE
                    UNLOCK
                ENDIF
            ENDIF
            LOOP

        ENDCASE
        manother := ApGetY( Message->Another )
    ENDDO                                       // manother

    RETURN NIL
// **** End of JobDemAdd()

// ***---------------------------- End Of JOBDEM.PRG
