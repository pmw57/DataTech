// ** JK 20-06-11 22:45:43

/*
   Program.....:                  XLF_PROF.PRG
   Authors.....: J.Kirby
   Date........: 11/03/1995
   Functions...: ProfView, FaultDraw, Mu_Prof, ProfDelete
                 PartStock, ProfCost
   Static funcs: ProfAdd, TechQuot, ProfRev, PartMemo
                 ProfQuot, ProfList, ProfIndiv
*/

// (c) Copyright 1993 by Kirby Christchurch.

STATIC FUNCTION ProfAdd( mcodeno )

    Scroll()
    DispBox( 0, 1, 2, 79, 2 )
    SELECT Name
    DispBox( 0, 1, 2, 79, 2 )
    @  1, 12 SAY Name->Codeno + "   " + Name->Name
    coperno := Space( 8 )
    GroupSelect( @coperno )
    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        // **           coperno := SPACE( 8 )
        // **            GroupSelect( @coperno )
        mcodeno := Name->Codeno
        ProfRev( @mcodeno )                   // Below
        mcodeno := Name->Codeno
        PartFind( mcodeno )                 // XLF_Part
        IF PressedEsc()
            RETURN NIL
        ENDIF
        mpartnum := Part->Partnum
        SELECT Part
        SET ORDER TO 1
        SEEK mpartnum
        IF !Found()
            LOOP
        ENDIF
        IF PressedEsc()
            RETURN NIL
        ENDIF
        Scroll( 3, 0, 24, 80 )
        DispBox( 3, 1, 8, 79, 2 )
        ProfRev( @mcodeno )
        SELECT Part
        SEEK mpartnum
        // **          @  4, 5      SAY coperno COLOR "BG+"
        @  4, 5      SAY "Item # " + Part->Partnum
        @  4, Col() + 2 SAY "Price " + Str( Part->Trade )
        @  4, Col() + 2 SAY "In Stock " + Str( Part->Instock ) PICTURE "99,999.99"
        @  5, 10 SAY "Desc " + Part->Desc
        nQty  := 1
        ddate := Date()
        @  7, 8 SAY "Issued Qty :" GET nQty  PICTURE "9999999"
        @  7, Col() + 3 SAY "Date "   GET ddate PICTURE "99/99/9999"
        @  7, Col() + 2 SAY mcodeno
        READ
        IF nQty > 0
            SELECT Prof
            mfind := mcodeno + mpartnum
            SEEK mfind
            ApFLock( 3 )
            IF !Found()
                APPEND BLANK
            ENDIF
            Prof->Codeno  := mcodeno
            Prof->Partnum := mpartnum
            Prof->Pdate   := ddate
            Prof->Qty     := nQty
            Prof->Cost    := Part->Trade
            Prof->Desc    := SubStr( Part->Desc, 1, 6 )
            Prof->Info    := Part->Catno
            Prof->Operno  := coperno
            UNLOCK
        ENDIF                    // nQty
        mcontinue := ApGetY( Trim( Message->Another ) + " Part" )
    ENDDO

    RETURN NIL
// **----- End of Profadd()

// *-------------------------------------------------------------------

FUNCTION ProfView()

    mok := "Y"
    DO WHILE mok = "Y"
        Scroll()
        coperno := Space( 8 )
        // **     mgroup := "N"
        // **     mgroup := ApGetN( "Do You Want By Group" )
        // **     IF mgroup = "Y"
        // **         coperno := SPACE( 8 )
        // **         GroupSelect( @coperno )
        // **     ENDIF      // mgroup
        Scroll()
        mok := "Y"
        mcodeno := Space( 8 )
        SELECT Prof
        GOTO TOP
        mtempcode := "A       "
        SEEK mtempcode
        IF !Found()
            ApFLock( 3 )
            APPEND BLANK
            Prof->Codeno := "A      "
            UNLOCK
        ENDIF
        GOTO TOP
        aPart_ := {}
        ncount := 0
        DO WHILE Prof->( !Eof() )
            DO WHILE Prof->Codeno = mcodeno
                SKIP ALIAS Prof
                LOOP
            ENDDO
         /*
         IF SUBSTR( coperno, 1, 2 ) != "XX"
            mcodeno := SPACE( 8 )
            IF Prof->Operno != coperno
                SKIP ALIAS Prof
                LOOP
            ENDIF
         ENDIF
         */
            SELECT NAME
            SEEK Prof->Codeno
            IF Found()
                ncount++
                SELECT Prof
                AAdd( aPart_, Prof->Codeno + "  " + Name->Name + "   " + DToC( Prof->PDate );
                    + "                      " + Str( RecNo(), 6 ) )
                mcodeno := Prof->Codeno
            ENDIF
            SELECT Prof
            SKIP ALIAS Prof
        ENDDO                         // EOF
        IF ncount <= 2
            SELECT Name
            mcodeno := Space( 8 )
            Namerank( @mcodeno )                // XLF_Name
            IF PressedEsc()
                RETURN NIL
            ENDIF
            mcodeno := Name->Codeno
        ENDIF
      /*
      IF ncount <= 2
         SELECT Prof
         GOTO TOP
         aPart_ := {}
         DO WHILE Prof->( !EOF() )
            DO WHILE Prof->Codeno = mcodeno
               SKIP ALIAS Prof
               LOOP
            ENDDO
            SELECT NAME
            SEEK Prof->Codeno
            IF FOUND()
               SELECT Prof
               AADD( aPart_,Prof->Codeno+"  "+Name->Name+"   "+DTOC( Prof->PDate );
                        +"                      "+STR( RECNO(),6 ) )
               mcodeno := Prof->Codeno
            ENDIF
            SELECT Prof
            SKIP ALIAS Prof
         ENDDO                         // EOF
      ENDIF          // ncount
      */
        DispBox( 0, 1, 19, 80, 2 )
        @ 0, 10 SAY "  Profile Group  " + coperno COLOR "BG+"
        @ 0, 40 SAY ncount PICTURE "999"  COLOR "BG+"

        IF !Empty( aPart_ )
            anum := AChoice( 1, 3, 18, 79, aPart_,, "AFUNC" )
            IF PressedEsc()
                RETURN NIL
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            IF Prof->Codeno = "A       "
                ApFLock( 3 )
                DELETE
                UNLOCK
                SELECT Name
                mcodeno := Space( 8 )
                Namerank( @mcodeno )                // XLF_Name
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                mcodeno := Name->Codeno
            ELSE
                mcodeno := Prof->Codeno
                SELECT Name
                SEEK mcodeno
            ENDIF
        ENDIF
        manother := "Y"
        DO WHILE manother = "Y"
            SELECT Prof
            GOTO TOP
            SEEK mcodeno
            nrecno  := 0
            aPart_  := {}
            DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !Eof() )
                SELECT Part
                SET ORDER TO 1
                GOTO TOP
                SEEK Prof->Partnum
                SELECT Prof
                AAdd( aPart_, SubStr( Part->Partnum, 1,16 );
                    + " " + SubStr( Part->Desc, 1, 36 );
                    + " " + Prof->Info + " " + Prof->Operno;
                    + "              " + Str( RecNo(), 6 ) )
                SKIP ALIAS Prof
            ENDDO                         // Prof EOF
            ASort( aPart_,,, {| x, y | x < y } )
            Scroll()
            DispBox( 0, 0, 2, 80, 2 )
            @  1, 10 SAY mcodeno + "  " + Name->Name COLOR "BG+"
            DispBox( 2, 0, 24, 80, 2 )
            IF !Empty( aPart_ )
                anum   := AChoice( 3, 2, 23, 79, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
            ENDIF
            Scroll(  19, 0, 24, 80 )
            DispBox( 19, 1, 24, 79, 2 )
            @ 19, 10 SAY " --- Profile --- "
            nselect := 1
            @ 20, 3      PROMPT " "
            @ 20, Col() + 1 PROMPT "1. Profile Add"
            @ 20, Col() + 2 PROMPT "2. Edit"
            @ 20, Col() + 2 PROMPT "3. List"
            @ 20, Col() + 2 PROMPT "4. Prof Individual"
            @ 20, Col() + 2 PROMPT "5. Delete"
            @ 22, 5      PROMPT "6. Prof+Info"
            @ 22, Col() + 2 PROMPT "7. Technical+Info"
            @ 22, Col() + 2 PROMPT "8. Information"
            @ 22, Col() + 2 PROMPT "9. JC- Another"
            @ 22, Col() + 2 PROMPT "Exit"
            MENU TO nselect
            DO CASE
            CASE nselect == 10
                RETURN NIL
            CASE PressedEsc()
                manother := mok := "N"
                // **         EXIT
                RETURN NIL
            CASE nselect == 1
                LOOP
            CASE nselect == 2
                ProfAdd( @mcodeno )                                   //
                LOOP
            CASE nselect == 3
                PartMemo( @mcodeno )                           //
                LOOP
            CASE nselect == 4                                //
                // **         tempscrn := SAVESCREEN( 0, 0, 24,80 )
                Proflist( @mcodeno )                     //
                LOOP
                // **         RESTSCREEN(  0, 0, 24,80,tempscrn )
            CASE nselect == 5
                ProfIndiv( @mcodeno )                   // Below
                LOOP
            CASE nselect == 6
                ProfDelete()                           // XLF_Ser.PRG
                LOOP
            CASE nselect == 7
                ProfQuot( @mcodeno )                            //
                LOOP
            CASE nselect == 8
                TechQuot( @mcodeno )                            //
                LOOP
            CASE nselect == 9                    //
                BrandFind()                      // XF_Fault
                LOOP
            CASE nselect == 10                  // Another
                ProfView()                      // XLF_Prof
                LOOP
            ENDCASE
            LOOP

        ENDDO             // manother
    ENDDO

    RETURN mcodeno

// **---------  End of ProfView

// ****-------------------------------------------------

FUNCTION FaultDraw()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"

        Scroll()
        DispBox( 0, 0, 18, 79, 2 )
        @ 0, 8 SAY "  Viewing Drawings  " COLOR "BG+"
        nl := 2
        mpartnum := Fault->Partnum
        SELECT PartOper
        SET ORDER TO 1         // Partnum
        GOTO TOP
        SEEK mpartnum
        IF Found()
            DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !Eof() )
                IF PartOper->FltRecno != Fault->FltRecno
                    SKIP ALIAS PartOper
                    LOOP
                ENDIF
                @ nl, 5 SAY PartOper->Desc + " " + PartOper->Drawno
                nl++
                IF nl >= 17
                    WAIT  // INKEY()
                    Scroll()
                    DispBox( 0, 0, 18, 79, 2 )
                    @ 0, 8 SAY "  Viewing Drawings " COLOR "BG+"
                    nl := 1
                ENDIF
                SKIP ALIAS PartOper
            ENDDO                        // PartOper EOF
        ENDIF                            // Found
        Scroll( 19, 0, 24, 80 )
        DispBox( 19, 0, 24, 79, 2 )
        @ 20, 6 SAY mpartnum COLOR "BG+"
        nselect := 1
        @ 22, 6      PROMPT "1. Add Drawing"
        @ 22, Col() + 2 PROMPT "2. Edit/Delete"
        @ 22, Col() + 2 PROMPT "3. Drawings File"
        @ 22, Col() + 2 PROMPT "4. Return"
        MENU TO nselect
        DO CASE
        CASE nselect == 4 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 3                 // Drawings
            JobDraw()                     // CWP2.Prg
            LOOP
        CASE nselect == 1                 // Add Drawing
            Scroll()
            DispBox( 0, 0, 18, 79, 2 )
            cdrawno := Space( 8 )
            aPart_ := {}
            nrecno   := 0
            SELECT Drawing
            GOTO TOP
            IF LastRec() != 0
                DO WHILE Drawing->( !Eof() )
                    AAdd( aPart_, Drawing->Drawno;
                        + " " + Drawing->Desc;
                        + " " + Drawing->DrawLoc;
                        + "                     " + Str( RecNo(), 6 ) )
                    SKIP ALIAS Drawing
                ENDDO                        // Drawing EOF
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    Scroll(  0, 0, 24, 80 )
                    DispBox( 0, 0, 24, 79, 2 )
                    anum := AChoice(  1, 3, 23, 78, aPart_,, "AFUNC" )
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                    Scroll(  13, 0, 24, 80 )
                    DispBox( 13, 0, 24, 79, 2 )
                    nl := 15
                    @ nl, 11 SAY Drawing->Drawno COLOR "BG+"
                    nl += 2
                    ApFlock( 3 )
                    @ nl, 5      SAY "Drawing Desc" GET Drawing->Desc PICTURE "@X"
                    // **        @ nl,COL()+2 GET Drawing->DrawLoc         PICTURE "@X"
                    READ
                    UNLOCK
                    SELECT PartOper
                    ApFlock( 3 )
                    APPEND BLANK
                    PartOper->Partnum   := mpartnum
                    PartOper->Drawno    := Drawing->Drawno
                    PartOper->Desc      := Drawing->Desc
                    PartOper->Operno    := "DRAWING"
                    PartOper->Date      := Date()
                    PartOper->Order     := "MD"
                    PartOper->FltRecno  := Fault->FltRecno
                    nl += 2
                    @ nl, 5 SAY "Information " GET PartOper->Desc
                    nl++
                    @ nl, 18 GET PartOper->Desc1
                    nl++
                    @ nl, 18 GET PartOper->Desc2
                    READ
                    UNLOCK
                ENDIF
            ENDIF                        // Empty
            LOOP

        CASE nselect == 2                 // Edit-Delete Drawing
            // **         manother := "Y"
            // **         DO WHILE manother = "Y"
            mpartnum := Fault->Partnum
            SELECT PartOper
            SET ORDER TO 1         // Partnum
            GOTO TOP
            SEEK mpartnum
            IF LastRec() != 0
                aPart_ := {}
                nrecno  := 0
                DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !Eof() )
                    IF PartOper->FltRecno != Fault->FltRecno
                        SKIP ALIAS PartOper
                        LOOP
                    ENDIF
                    AAdd( aPart_, PartOper->Partnum;
                        + " " + PartOper->Desc;
                        + " " + PartOper->Drawno;
                        + "              " + Str( RecNo(), 6 ) )
                    SKIP ALIAS PartOper
                ENDDO                        // PartOper EOF
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    Scroll(  0, 0, 24, 80 )
                    DispBox( 0, 0, 24, 79, 2 )
                    anum := AChoice(  1, 3, 23, 78, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                    Scroll(  11, 0, 24, 80 )
                    DispBox( 11, 0, 18, 79, 2 )
                    nl := 13
                    @ nl, 18 SAY PartOper->Desc + "  " + PartOper->Partnum
                    nl++
                    ApFLock( 3 )
                    @ nl, 5 SAY "Information " GET PartOper->Desc
                    nl++
                    @ nl, 18 GET PartOper->Desc1
                    nl++
                    @ nl, 18 GET PartOper->Desc2
                    READ
                    UNLOCK
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    SELECT PartOper
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
            ENDIF // not 0
            LOOP
        ENDCASE

    ENDDO       // mcontinue

    RETURN NIL
// ****** End of DrawReview()

// **-------------------------------------------------------------------

STATIC FUNCTION TechQuot( mcodeno )

    nl     := 0
    mwhere := "S"
    npl    := 54

    Printsel()                                  // _LF_Init

    IF mwhere == "P"
        npl := 56
    ELSE
        Scroll()
        npl := 22
    ENDIF
    @  0, 8 SAY Control->U_Name
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    nl := 2                               // Top Page prints from
    @ nl, 3 SAY Name->Name                // This is Company Name
    IF Name->Add1 != Space( 27 )
        nl++
        @ nl, 3 SAY Name->Add1
    ENDIF
    IF Name->Add2 != Space( 27 )
        nl++
        @ nl, 3 SAY Name->Add2
    ENDIF
    IF Name->Add3 != Space( 27 )
        nl++
        @ nl, 3 SAY Name->Add3
    ENDIF
    IF Name->Add4 != Space( 20 )
        nl++
        @ nl, 3 SAY Name->Add4
    ENDIF
    IF Name->Phone != Space( 15 )
        @ nl, 22 SAY Name->Phone                // Business Phone
    ELSE
        @ nl, 22 SAY Name->Ephone               // Home Phone
    ENDIF
    nl += 2
    ntotal := 0
    SELECT Prof
    GOTO TOP
    SEEK mcodeno
    DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !Eof() )
        IF nl > npl
            IF mwhere == "P"
                EJECT
                @  0, 8 SAY Control->U_Name
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                nl := 2
            ELSE
                WAIT
                nl := 0
                Scroll()
            ENDIF
        ENDIF
        SELECT Part
        SEEK Prof->Partnum
        SELECT Prof
        ntotal += ( Prof->Qty * Part->Trade )
        @ nl, 0 SAY Part->Desc
        @ nl, 50 SAY Prof->Qty  PICTURE "99,999.99"
        @ nl, 60 SAY Prof->Partnum
        IF Part->Detail != Space( 43 )
            nl++
            @ nl, 3 SAY Part->Detail
        ENDIF
        IF Part->Detail1 != Space( 43 )
            nl++
            @ nl, 3 SAY Part->Detail1
        ENDIF
        IF Part->Detail2 != Space( 43 )
            nl++
            @ nl, 3 SAY Part->Detail2
        ENDIF
        IF Part->Detail3 != Space( 43 )
            nl++
            @ nl, 3 SAY Part->Detail3
        ENDIF
        nl++
        SELECT Fault
        GOTO TOP
        SEEK Prof->Partnum
        IF Found()
            DO WHILE Fault->Partnum = Prof->Partnum .AND. Fault->( !Eof() )
                IF nl > npl
                    nl := 0
                    IF mwhere == "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                @ nl, 0 SAY Fault->Partnum + "  " + Fault->Brand + "  " + Fault->ChasMech
                nl++
                @ nl, 0 SAY Fault->Symptom
                nl++
                IF Fault->Fix1 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix1
                    nl++
                ENDIF
                IF Fault->Fix2 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix2
                    nl++
                ENDIF
                IF Fault->Fix3 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix3
                    nl++
                ENDIF
                IF Fault->Fix4 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix4
                    nl++
                ENDIF
                IF Fault->Fix5 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix5
                    nl++
                ENDIF
                IF Fault->Fix6 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix6
                    nl++
                ENDIF
                IF Fault->Fix7 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix7
                    nl++
                ENDIF
                IF Fault->Fix8 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix8
                ENDIF
                coderef := Fault->FltRecno
                SELECT Cusnotes
                cdetail := ""
                SEEK coderef
                IF Found()
                    nl++
                    GetDets( coderef )                           // XF_Memo2
                    FormP( cdetail, 60, 10 )                       // XF_Memo2
                ENDIF
                nl++
                SELECT PartOper
                SEEK Fault->Partnum
                IF Found()
                    DO WHILE PartOper->Partnum = Fault->Partnum .AND. PartOper->( !Eof() )
                        IF PartOper->FltRecno != Fault->FltRecno
                            SKIP ALIAS PartOper
                            LOOP
                        ENDIF
                        @ nl, 5 SAY PartOper->Desc + " " + PartOper->Drawno + " " + PartOper->Operno
                        IF PartOper->Desc1 != Space( 40 )
                            nl++
                            @ nl, 5 SAY PartOper->Desc1
                        ENDIF
                        IF PartOper->Desc2 != Space( 40 )
                            nl++
                            @ nl, 5 SAY PartOper->Desc2
                        ENDIF
                        nl++
                        SKIP ALIAS PartOper
                    ENDDO                     // PartOper
                ENDIF                       // Found
                nl++
                SELECT Fault
                SKIP ALIAS Fault
            ENDDO                         // End Fault
        ENDIF                           // Found
        SELECT Prof
        SKIP ALIAS Prof
    ENDDO                           // End Prof
    nl++
    @ nl, 49 SAY ntotal PICTURE "$99,999.99"
    IF mwhere != "P"
        IF nl > 18
            nl++
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ELSE
        EndPrint()
    ENDIF
    // **   mok := ApGetN( TRIM( Message->Another )+" Print" )

    RETURN NIL
// **** End of File TechQuot

// ***-------------------------------------------------------------------

STATIC FUNCTION ProfRev( mcodeno )

    ddate := Date() -10
    nl    := 10
    npl   := 23
    Scroll(   9, 0, 24, 80 )
    DispBox(  9, 0, 24, 79, 2 )
    cheading := " - Entries past 10 days - "
    @  9, 40 -( Len( cheading ) / 2 ) SAY cheading
    mcodeno := Name->Codeno
    SELECT Prof
    GOTO TOP
    SEEK mcodeno
    DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !Eof() )
        IF Prof->Pdate <= ddate
            SKIP ALIAS Prof
            LOOP
        ENDIF
        IF nl > npl
            nl := 10
            Inkey( 2 )              // WAIT
            Scroll( 10, 2, 23, 78 )
        ENDIF
        SELECT Part
        SEEK Prof->Partnum
        @ nl, 3 SAY SubStr( Prof->Partnum, 1, 16 )
        @ nl, 21 SAY SubStr( Part->Desc, 1, 28 )
        SELECT Prof
        @ nl, 51 SAY Prof->Qty  PICTURE "99,999"
        @ nl, 58 SAY Prof->Codeno
        @ nl, 68 SAY Prof->Pdate
        nl++
        SKIP ALIAS Prof
    ENDDO                        // Prof EOF()

    RETURN mcodeno

// ****---- End of ProfRev()

// **---------------------------------------------------------------------*

STATIC FUNCTION PartMemo( mcodeno )

    manother := "Y"
    DO WHILE manother == "Y"
        SELECT Prof
        GOTO TOP
        SEEK Name->Codeno
        mcodeno := Name->Codeno
        // **      SEEK mcodeno
        camount := " "
        nrecno  := 0
        aPart_  := {}
        DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !Eof() )
            SELECT Part
            SET ORDER TO 1
            GOTO TOP
            SEEK Prof->Partnum
            SELECT Prof
            AAdd( aPart_, SubStr( Part->Partnum, 1,16 );
                + " " + SubStr( Part->Desc, 1, 32 );
                + " " + Prof->Info + " " + Prof->Operno;
                + " Delete=Y " + camount;
                + "             " + Str( RecNo(), 6 ) )
            SKIP ALIAS Prof
        ENDDO                         // Prof EOF
        ASort( aPart_,,, {| x, y | x < y } )
        Scroll()
        DispBox( 0, 0, 2, 80, 2 )
        @  1, 10 SAY mcodeno + "  " + Name->Name COLOR "BG+"
        DispBox( 2, 0, 24, 80, 2 )
        IF !Empty( aPart_ )
            anum   := AChoice( 3, 2, 23, 79, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            SELECT Prof
            GOTO nrecno
        ENDIF
        @ Row(), 78 GET camount VALID( camount $ "NY " ) PICTURE "@!"
        READ
        IF camount = "Y"
            SELECT Prof
            ApRLock( 3 )
            DELETE
            UNLOCK
            LOOP
        ENDIF
        IF LastKey() = 27
            RETURN NIL
        ENDIF
        SELECT Part
        SEEK Prof->Partnum
        mcontact := Part->Desc
        mdesc    := Part->Detail
        mdesc1   := Part->Detail1
        mdesc2   := Part->Detail2
        mdesc3   := Part->Detail3
        ddate    := Prof->PDate
        nqty     := Prof->Qty
        coperno  := Prof->Operno
        Scroll()
        DispBox( 0, 0, 24, 79, 2 )
        nl := 2
        @ nl, 4      SAY mcodeno + "  " + Prof->Partnum + " " + Prof->Info COLOR "BG+"
        @ nl, Col() + 2 SAY Prof->Qty PICTURE "99,999.99" COLOR "BG+"
        @ nl, Col() + 2 SAY ddate
        nl++
        @ nl, 4 SAY mcontact
        nl++
        @ nl, 4 SAY mdesc
        nl++
        @ nl, 4 SAY mdesc1
        nl++
        @ nl, 4 SAY mdesc2
        nl++
        @ nl, 4 SAY mdesc3
        SELECT Prof
        nl++
        @ nl, 6      SAY Name->Name                  COLOR "BG+"
        @ nl, Col() + 2 SAY Prof->Info + "   " + Prof->Desc COLOR "BG+"
        @ nl, Col() + 2 SAY coperno                     COLOR "BG+"
        nl += 2
        @ nl, 10      SAY "Quantity" GET nqty    PICTURE "999999.99"
        @ nl, Col() + 2 SAY "Date"     GET ddate   PICTURE "99/99/9999"
        nl++
        @ nl, 10 SAY "Part Desc  " GET mcontact PICTURE "@X"
        nl++
        @ nl, 10 SAY "Description" GET mdesc    PICTURE "@X"
        nl++
        @ nl, 22                   GET mdesc1   PICTURE "@X"
        nl++
        @ nl, 22                   GET mdesc2   PICTURE "@X"
        nl++
        @ nl, 22                   GET mdesc3   PICTURE "@X"
        READ
        SELECT Part
        ApRLock( 3 )
        Part->Desc    := mcontact
        Part->Detail  := mdesc
        Part->Detail1 := mdesc1
        Part->Detail2 := mdesc2
        Part->Detail3 := mdesc3
        UNLOCK

        GroupSelect( @coperno )

        SELECT Prof
        ApRLock( 3 )
        Prof->PDate  := ddate
        Prof->Qty    := nqty
        Prof->Info   := Part->Catno
        Prof->Operno := coperno
        UNLOCK
        mpartnum := Part->Partnum
        mcorrect := "N"
        DO WHILE mcorrect == "N"
            SELECT Fault
            GOTO TOP
            SEEK mpartnum
            IF Found()
                Scroll()
                aPart_ := {}
                IF LastRec() != 0
                    DO WHILE Fault->Partnum = mpartnum .AND. Fault->( !Eof() )
                        AAdd( aPart_, ( Fault->Partnum + " " + Fault->Brand;
                            + " " + Fault->Model;
                            + " " + Fault->ChasMech + "          " + Str( RecNo(), 6 ) ) )
                        SKIP ALIAS Fault
                    ENDDO
                ENDIF   // LastRec
                DispBox(  0, 0, 24, 79, 2 )
                IF !Empty( aPart_ )
                    anum := AChoice( 1, 2, 23, 77, aPart_,, "AFUNC" )
                    mpartdes := aPart_[ anum ]
                    nrecno := Val( Right( mpartdes,6 ) )
                    GOTO nrecno
                ENDIF
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                Scroll()
                DispBox(  0, 0, 19, 79, 2 )
                nl := 1
                @ nl, 10 SAY Fault->Partnum
                nl++
                @ nl, 10 SAY Fault->Brand
                nl++
                @ nl, 10 SAY Fault->Model
                nl++
                @ nl, 10 SAY Fault->ChasMech
                nl++
                @ nl, 10 SAY Fault->Area
                nl += 2
                @ nl, 2 SAY Fault->Symptom
                nl += 2
                @ nl, 2 SAY Fault->Fix1
                nl++
                @ nl, 2 SAY Fault->Fix2
                nl++
                @ nl, 2 SAY Fault->Fix3
                nl++
                @ nl, 2 SAY Fault->Fix4
                nl++
                @ nl, 2 SAY Fault->Fix5
                nl++
                @ nl, 2 SAY Fault->Fix6
                nl++
                @ nl, 2 SAY Fault->Fix7
                nl++
                @ nl, 2 SAY Fault->Fix8
                nl++
                @ nl, 10 SAY Fault->Ddate
                coderef := Fault->FltRecno
                MemoDisp( coderef )                 // XF_Memo2
                SELECT PartOper
                SEEK Fault->Partnum
                IF Found()
                    Scroll()
                    DispBox( 0, 0, 24, 79, 2 )
                    nl := 2
                    DO WHILE PartOper->Partnum = Fault->Partnum .AND. PartOper->( !Eof() )
                        IF PartOper->FltRecno != Fault->FltRecno
                            SKIP ALIAS PartOper
                            LOOP
                        ENDIF
                        @ nl, 5 SAY PartOper->Desc + " " + PartOper->Drawno + " " + PartOper->Operno
                        IF PartOper->Desc1 != Space( 40 )
                            nl++
                            @ nl, 5 SAY PartOper->Desc1
                        ENDIF
                        IF PartOper->Desc2 != Space( 40 )
                            nl++
                            @ nl, 5 SAY PartOper->Desc2
                        ENDIF
                        nl++
                        IF nl >= 17
                            WAIT  // INKEY()
                            Scroll()
                            DispBox( 0, 0, 18, 79, 2 )
                            @ 0, 8 SAY "  Viewing Drawings " COLOR "BG+"
                            nl := 1
                        ENDIF
                        SKIP ALIAS PartOper
                    ENDDO                     // PartOper
                ENDIF                       // Found
                SELECT Fault
                nselect := 1
                Scroll(  20, 0, 24, 80 )
                DispBox( 20, 0, 24, 79, 2 )
                @ 21, 10      PROMPT " "
                @ 21, Col() + 2 PROMPT "1. Edit"
                @ 21, Col() + 2 PROMPT "2. Add New"
                MENU TO nselect

                DO CASE
                CASE PressedEsc()
                    PartMemo()
                    // **           RETURN NIL
                CASE nselect == 1
                    LOOP
                CASE nselect == 2                  // Edit
                    Scroll()
                    DispBox( 0, 1, 24, 78, 2 )
                    SELECT Fault
                    ApRLock( 3 )
                    @  3, 10 GET Fault->Partnum  PICTURE "@!"
                    @  3, Col() + 2 GET Fault->Brand PICTURE "@!"
                    @  4, 10 GET Fault->Model    PICTURE "@X"
                    @  4, Col() + 2 GET Fault->ChasMech PICTURE "@X"
                    @  5, 10 GET Fault->Area     PICTURE "@X"
                    @  7, 2 GET Fault->Symptom  PICTURE "@X"
                    @  8, 2 GET Fault->Fix1     PICTURE "@X"
                    @  9, 2 GET Fault->Fix2     PICTURE "@X"
                    @ 10, 2 GET Fault->Fix3     PICTURE "@X"
                    @ 11, 2 GET Fault->Fix4     PICTURE "@X"
                    @ 12, 2 GET Fault->Fix5     PICTURE "@X"
                    @ 13, 2 GET Fault->Fix6     PICTURE "@X"
                    @ 14, 2 GET Fault->Fix7     PICTURE "@X"
                    @ 15, 2 GET Fault->Fix8     PICTURE "@X"
                    @ 17, 10 GET Fault->Ddate    PICTURE "99/99/9999"
                    READ
                    Fault->FltRecno := Fault->Brand + Str( RecNo(), 4 )
                    UNLOCK
                    SELECT Fault
                    coderef := Fault->FltRecno
                    M2MemoFile( coderef )                 // XF_Memo2
                    SELECT Part
                    SEEK Fault->Partnum
                    FaultDraw()                         // CWPPart.Prg
                    LOOP
                CASE nselect == 3                  // Add New
                    SELECT Fault
                    ApFLock( 3 )
                    APPEND BLANK
                    Fault->Ddate  := Date()
                    Fault->Codeno := SubStr( Control->U_Name, 1, 8 )
                    Fault->FltRecno := Str( Control->LastFlt, 6 )
                    UNLOCK
   /*
   Taken out test this
             SELECT Control
               ApRLock( 3 )
             Control->LastFlt := Control->LastFlt+1
             UNLOCK
   */
                    FaultGet()
                    LOOP
                ENDCASE
            ENDIF                          // mcontinue
            mcorrect := "Y"

        ENDDO                          // Found Fault
        manother := ApGetY( Trim( Message->Another ) + " Edit" )
    ENDDO

    RETURN NIL
// **** End of File PartMemo

// ***--------------------------------------------------------------------

STATIC FUNCTION ProfQuot( mcodeno )

    nl     := 0
    mwhere := "S"
    npl    := 54

    Printsel()                                  // _LF_Init

    IF mwhere == "P"
        npl := 56
    ELSE
        Scroll()
        npl := 22
    ENDIF
    @  0, 8 SAY Control->U_Name
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    nl := 2                               // Top Page prints from
    @ nl, 3 SAY Name->Name                // This is Company Name
    nl++
    IF Name->Add1 != Space( 27 )
        nl++
        @ nl, 3 SAY Name->Add1
    ENDIF
    IF Name->Add2 != Space( 27 )
        nl++
        @ nl, 3 SAY Name->Add2
    ENDIF
    IF Name->Add3 != Space( 27 )
        nl++
        @ nl, 3 SAY Name->Add3
    ENDIF
    IF Name->Add4 != Space( 20 )
        nl++
        @ nl, 3 SAY Name->Add4
    ENDIF
    IF Name->Phone != Space( 15 )
        @ nl, 22 SAY Name->Phone                // Business Phone
    ELSE
        @ nl, 22 SAY Name->Ephone               // Home Phone
    ENDIF
    nl++
    ntotal := 0
    SELECT Prof
    GOTO TOP
    SEEK mcodeno
    DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !Eof() )
        IF nl > npl
            IF mwhere == "P"
                EJECT
                @  0, 8 SAY Control->U_Name
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                nl := 2
            ELSE
                WAIT
                nl := 0
                Scroll()
            ENDIF
        ENDIF
        SELECT Part
        SEEK Prof->Partnum
        SELECT Prof
        ntotal += ( Prof->Qty * Part->Trade )
        @ nl, 0 SAY Part->Desc
        @ nl, 50 SAY Prof->Qty  PICTURE "99,999.99"
        @ nl, 60 SAY Prof->Partnum
        IF Part->Detail != Space( 43 )
            nl++
            @ nl, 3 SAY Part->Detail
        ENDIF
        IF Part->Detail1 != Space( 43 )
            nl++
            @ nl, 3 SAY Part->Detail1
        ENDIF
        IF Part->Detail2 != Space( 43 )
            nl++
            @ nl, 3 SAY Part->Detail2
        ENDIF
        IF Part->Detail3 != Space( 43 )
            nl++
            @ nl, 3 SAY Part->Detail3
        ENDIF
        nl++
        SELECT Fault
        GOTO TOP
        SEEK Prof->Partnum
        IF Found()
            DO WHILE Fault->Partnum = Prof->Partnum .AND. Fault->( !Eof() )
                IF nl > npl
                    nl := 0
                    IF mwhere == "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                @ nl, 0 SAY Fault->Partnum + "  " + Fault->Brand + "  " + Fault->ChasMech
                nl++
                @ nl, 0 SAY Fault->Symptom
                nl++
                IF Fault->Fix1 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix1
                    nl++
                ENDIF
                IF Fault->Fix2 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix2
                    nl++
                ENDIF
                IF Fault->Fix3 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix3
                    nl++
                ENDIF
                IF Fault->Fix4 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix4
                    nl++
                ENDIF
                IF Fault->Fix5 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix5
                    nl++
                ENDIF
                IF Fault->Fix6 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix6
                    nl++
                ENDIF
                IF Fault->Fix7 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix7
                    nl++
                ENDIF
                IF Fault->Fix8 != Space( 65 )
                    @ nl, 0 SAY Fault->Fix8
                ENDIF
                coderef := Fault->FltRecno
                SELECT Cusnotes
                cdetail := ""
                SEEK coderef
                IF Found()
                    nl++
                    GetDets( coderef )                           // XF_Memo2
                    FormP( cdetail, 60, 10 )                       // XF_Memo2
                ENDIF
                nl++
                SELECT PartOper
                SEEK Part->Partnum
                IF Found()
                    DO WHILE PartOper->Partnum = Fault->Partnum .AND. PartOper->( !Eof() )
                        IF PartOper->FltRecno != Fault->FltRecno
                            SKIP ALIAS PartOper
                            LOOP
                        ENDIF
                        @ nl, 5 SAY PartOper->Desc + " " + PartOper->Drawno + " " + PartOper->Operno
                        IF PartOper->Desc1 != Space( 40 )
                            nl++
                            @ nl, 5 SAY PartOper->Desc1
                        ENDIF
                        IF PartOper->Desc2 != Space( 40 )
                            nl++
                            @ nl, 5 SAY PartOper->Desc2
                        ENDIF
                        nl++
                        SKIP ALIAS PartOper
                    ENDDO                     // PartOper
                ENDIF                       // Found
                SELECT Fault
                SKIP ALIAS Fault
            ENDDO                         // End Fault
        ENDIF                           // Found
        SELECT Prof
        SKIP ALIAS Prof
    ENDDO                           // End Prof
    nl++
    @ nl, 48 SAY ntotal PICTURE "$999,999.99"
    IF mwhere != "P"
        IF nl > 18
            nl++
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ELSE
        EndPrint()
    ENDIF
    // **   mok := ApGetN( TRIM( Message->Another )+" Print" )

    RETURN NIL
// **** End of File ProfQuot

// ***-------------------------------------------------------------------

FUNCTION Mu_Prof( nc, ncl )

    SELECT Part
    SET ORDER TO 1
    DO WHILE .T.
        SELECT Prof
        GOTO TOP
        DO WHILE Prof->( !Eof() )
            SELECT Part
            SEEK Prof->Partnum
            SELECT Prof
            ApRLock( 3 )
            Prof->Desc    := SubStr( Part->Desc, 1, 6 )
            Prof->Info    := SubStr( Part->Catno, 1, 10 )
            Prof->Cost    := Part->Trade
            UNLOCK
            SKIP ALIAS Prof
        ENDDO
        nselect  := 0
        nc       := ncl * 2
        Scroll( 3, nc, 21, 78 )
        @  4, nc TO 21, nc + ncl
        Scroll( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  3, nc + 4 TO 5, nc + ( ncl - 4 )
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( "PROFILE MENU" ) ) / 2 );
            SAY RTrim( "PROFILE MENU" )
        @  7, nc + 2 PROMPT "1. Profile       Menu"
        @  9, nc + 2 PROMPT "2. Equipment     Menu"
        @ 11, nc + 2 PROMPT "3. Drawings      Menu"
        @ 13, nc + 2 PROMPT "4. Dual Function     "
        @ 15, nc + 2 PROMPT "5. Profile Delete    "
        @ 17, nc + 2 PROMPT "6. Process Review    "

        @ 20, nc + 2 PROMPT Menu->CH_Main
        nc       := ncl
        mpartnum := Space( 20 )

        MENU TO nselect

        DO CASE
        CASE nselect == 7 .OR. PressedEsc()
            EXIT
        CASE nselect == 1                    //
            SAVE SCREEN TO holdscrn
            ProfView()                        //
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 2                    //
            SAVE SCREEN TO holdscrn
            BrandFind()                      // XF_Fault
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3                     // Special
            SAVE SCREEN TO holdscrn
            FaultDraw()                    // Review()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4                     // Special
            SAVE SCREEN TO holdscrn
            Admin()                          // XLF_EQU2
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5                     // Listing
            SAVE SCREEN TO holdscrn
            ProfDelete()                      // XLF_Ser.prg
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6                     // Listing
            SAVE SCREEN TO holdscrn
            mpartnum := Space( 20 )
            PartOper2( @mpartnum )                      //
            RESTORE SCREEN FROM holdscrn
            LOOP
        ENDCASE
    ENDDO

    RETURN NIL

// **** End of Mu_Prof()

// **-------------------------------------------------------------------

STATIC FUNCTION ProfList()

    nl  := 0
    mok := "Y"
    DO WHILE mok == "Y"

        Printsel()                                  // _LF_Init

        IF mwhere == "P"
            npl := 56
        ELSE
            Scroll()
            npl := 22
        ENDIF
        @  0, 8 SAY Control->U_Name
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @  2, 0 SAY "Part #"
        @  2, 20 SAY "Description"
        @  2, 40 SAY Name->Name
        nl := 3
        ntotal := 0
        SELECT Prof
        GOTO TOP
        SEEK mcodeno
        DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !Eof() )
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                    @  0, 8 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  2, 0 SAY "Part #"
                    @  2, 20 SAY "Description"
                    nl := 3
                ELSE
                    WAIT
                    nl := 0
                    Scroll()
                ENDIF
            ENDIF
            SELECT Part
            SEEK Prof->Partnum
            SELECT Prof
            ntotal += ( Prof->Qty * Part->Trade )
            @ nl, 0 SAY Part->Desc
            @ nl, 50 SAY Prof->Qty  PICTURE "99,999.99"
            @ nl, 60 SAY Prof->Partnum
            IF Part->Detail != Space( 43 )
                nl++
                @ nl, 3 SAY Part->Detail
            ENDIF
            nl++
            SKIP ALIAS Prof
        ENDDO
        nl++
        @ nl, 50 SAY ntotal PICTURE "$99,999.99"
        IF mwhere != "P"
            IF nl > 18
                nl++
                WAIT
            ENDIF
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO

    RETURN NIL

// **** End of File ProfList

// ---------------------------------------------------------------------*

STATIC FUNCTION ProfIndiv( mcodeno )

    nl  := 0
    mok := "Y"
    DO WHILE mok == "Y"
        Scroll()
        SELECT Prof
        GOTO TOP
        SEEK mcodeno
        aPart_ := {}
        DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !Eof() )
            SELECT Part
            SET ORDER TO 1
            GOTO TOP
            SEEK Prof->Partnum
            SELECT Prof
            AAdd( aPart_, SubStr( Part->Desc,1,36 );
                + " " + SubStr( Part->Detail, 1, 36 );
                + " " + Prof->Info;
                + "             " + Str( RecNo(), 6 ) )
            SKIP ALIAS Prof
        ENDDO                         // Prof EOF
        ASort( aPart_,,, {| x, y | x < y } )
        Scroll()
        DispBox( 0, 0, 2, 80, 2 )
        @  1, 10 SAY mcodeno + "  " + Name->Name COLOR "BG+"
        DispBox( 2, 0, 24, 80, 2 )
        IF !Empty( aPart_ )
            anum   := AChoice( 3, 2, 23, 79, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
        ENDIF
        IF LastKey() = 27
            RETURN NIL
        ENDIF
        SELECT Prof
        GOTO nrecno
        SELECT Part
        SEEK Prof->Partnum
        mpartnum := Part->Partnum
        mwhere := "S"
        npl    := 54

        Printsel()                                  // _LF_Init

        IF mwhere == "P"
            npl := 56
        ELSE
            Scroll()
            npl := 22
        ENDIF
        @  0, 8 SAY Control->U_Name
        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        @  2, 0 SAY "Part #"
        @  2, 20 SAY "Description"
        @  2, 40 SAY Name->Name
        nl := 3
        ntotal := 0
        SELECT Prof
        GOTO TOP
        SEEK mcodeno
        DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !Eof() )
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                    @  0, 8 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  2, 0 SAY "Part #"
                    @  2, 20 SAY "Description"
                    nl := 3
                ELSE
                    WAIT
                    nl := 0
                    Scroll()
                ENDIF
            ENDIF
            SELECT Part
            SEEK Prof->Partnum
            SELECT Prof
            IF Prof->Partnum != mpartnum
                SKIP ALIAS Prof
                LOOP
            ENDIF
            ntotal += ( Prof->Qty * Part->Trade )
            @ nl, 0 SAY Part->Desc
            @ nl, 50 SAY Prof->Qty  PICTURE "99,999.99"
            @ nl, 60 SAY Prof->Partnum
            IF Part->Detail != Space( 43 )
                nl++
                @ nl, 3 SAY Part->Detail
            ENDIF
            IF Part->Detail1 != Space( 43 )
                nl++
                @ nl, 3 SAY Part->Detail1
            ENDIF
            IF Part->Detail2 != Space( 43 )
                nl++
                @ nl, 3 SAY Part->Detail2
            ENDIF
            IF Part->Detail3 != Space( 43 )
                nl++
                @ nl, 3 SAY Part->Detail3
            ENDIF
            nl++
            SELECT Fault
            GOTO TOP
            SEEK Prof->Partnum
            IF Found()
                DO WHILE Fault->Partnum = Prof->Partnum .AND. Fault->( !Eof() )
                    IF nl > npl
                        nl := 0
                        IF mwhere == "P"
                            EJECT
                        ELSE
                            WAIT
                            Scroll()
                        ENDIF
                    ENDIF
                    @ nl, 0 SAY Fault->Partnum + "  " + Fault->Brand + "  " + Fault->ChasMech
                    nl++
                    @ nl, 0 SAY Fault->Symptom
                    nl++
                    IF Fault->Fix1 != Space( 65 )
                        @ nl, 0 SAY Fault->Fix1
                        nl++
                    ENDIF
                    IF Fault->Fix2 != Space( 65 )
                        @ nl, 0 SAY Fault->Fix2
                        nl++
                    ENDIF
                    IF Fault->Fix3 != Space( 65 )
                        @ nl, 0 SAY Fault->Fix3
                        nl++
                    ENDIF
                    IF Fault->Fix4 != Space( 65 )
                        @ nl, 0 SAY Fault->Fix4
                        nl++
                    ENDIF
                    IF Fault->Fix5 != Space( 65 )
                        @ nl, 0 SAY Fault->Fix5
                        nl++
                    ENDIF
                    IF Fault->Fix6 != Space( 65 )
                        @ nl, 0 SAY Fault->Fix6
                        nl++
                    ENDIF
                    IF Fault->Fix7 != Space( 65 )
                        @ nl, 0 SAY Fault->Fix7
                        nl++
                    ENDIF
                    IF Fault->Fix8 != Space( 65 )
                        @ nl, 0 SAY Fault->Fix8
                    ENDIF
                    coderef := Fault->FltRecno
                    SELECT Cusnotes
                    cdetail := ""
                    SEEK coderef
                    IF Found()
                        nl++
                        GetDets( coderef )                           // XF_Memo2
                        FormP( cdetail, 60, 10 )                       // XF_Memo2
                    ENDIF
                    nl++
                    SELECT PartOper
                    // **      SEEK Part->Partnum
                    IF Found()
                        DO WHILE PartOper->Partnum = Fault->Partnum .AND. PartOper->( !Eof() )
                            IF PartOper->FltRecno != Fault->FltRecno
                                SKIP ALIAS PartOper
                                LOOP
                            ENDIF
                            @ nl, 5 SAY PartOper->Desc + " " + PartOper->Drawno + " " + PartOper->Operno
                            IF PartOper->Desc1 != Space( 40 )
                                nl++
                                @ nl, 5 SAY PartOper->Desc1
                            ENDIF
                            IF PartOper->Desc2 != Space( 40 )
                                nl++
                                @ nl, 5 SAY PartOper->Desc2
                            ENDIF
                            nl++
                            SKIP ALIAS PartOper
                        ENDDO                     // PartOper
                    ENDIF                       // Found
                    SELECT Fault
                    SKIP ALIAS Fault
                ENDDO                         // End Fault
            ENDIF                         // FOUND
            SELECT Prof
            SKIP ALIAS Prof
        ENDDO
        nl++
        npl := nl
        nline = 1
        FOR nline = 1 TO ( 50 -npl )           // Was 63
            @ nl, 0 SAY "__________________________________________________________________"
            nl += 2
            IF nl > 50
                EXIT
            ENDIF
            npl++
        NEXT
        IF mwhere != "P"
            IF nl > 18
                nl++
                WAIT
            ENDIF
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO

    RETURN NIL

// **** End of File ProfIndiv

// ***-------------------------------------------------------------------

FUNCTION ProfDelete()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        SELECT Prof
        GOTO TOP
        namount := " "
        nrecno  := 0
        aPart_  := {}
        DO WHILE Prof->( !Eof() )
            AAdd( aPart_, Prof->Codeno;
                + " " + Prof->Partnum;
                + " " + Prof->Info;
                + " " + DToC( Prof->PDate );
                + "  Delete = Y" + namount;
                + "                    " + Str( RecNo(), 6 ) )
            SKIP ALIAS Prof
        ENDDO   // Prof EOF
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 17 SAY "Profile File"
        @  1, 62 SAY "Esc to Exit" COLOR "G+"
        DispBox( 3, 1, 23, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 22, 77, aPart_,, "AFUNC" )
            IF LastKey() = 27
                EXIT
            ENDIF
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
        ENDIF
        @ Row(), 76 GET namount VALID( namount $ "NY " ) PICTURE "@!"
        READ
        IF namount = "Y"
            ApRLock( 3 )
            DELETE
            UNLOCK
        ENDIF
        IF LastKey() = 27
            mcontinue := "N"
        ENDIF
        // **       mok := ApGetN( "Do You Want Another" )
    ENDDO

    RETURN NIL
// ***---- End of ProfDelete()

// ***----------------------------------------------------------------------

FUNCTION PartStock()

    SELECT Part
    ApFLock( 3 )
    REPLACE ALL Part->Line WITH "__________"
    UNLOCK
    cboughtout := ApGetN( "Do You Want Bought Out Only" )

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        nrecno  := 0
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 12 SAY "Edit Factory Stock"
        SELECT Part
        GOTO TOP
        aPart_ := {}
        anum   := {}
        DO WHILE Part->( !Eof() )
            IF cboughtout = "Y"
                IF Part->Boughtout != "Y"
                    SKIP ALIAS Part
                    LOOP
                ENDIF
            ENDIF                // cboughtout
            AAdd( aPart_, Part->Catno + "  " + Part->Desc;
                + " " + Str( Part->Instock, 9, 2 );
                + " " + Part->Line + "       " + Str( RecNo(), 6 ) )
            SKIP ALIAS Part
        ENDDO                                 // Part EOF
        Scroll(  4, 0, 24, 80 )
        DispBox( 4, 1, 23, 79, 2 )
        @  3, 2 SAY "Catalogue      Description"
        @  3, 56 SAY "Instock Qty"
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum   := AChoice( 5, 3, 22, 76, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
        ENDIF
        IF LastKey() = 27
            RETURN NIL
        ENDIF
        SELECT Part
        GOTO nrecno
        ApRLock( 3 )
        mlen := nvol := ncsarea := ncost := nrate := 0
        IF Part->Unit = "Cu Mtr    "
            Scroll(  19, 0, 24, 80 )
            DispBox( 19, 1, 24, 79, 2 )
            @ 20, 5 SAY Trim( Part->Partnum ) + " " + Part->Desc
            ncsarea = ( Part->Width * Part->Thick ) / 1000000
            @ 20, 64 SAY Part->Instock         PICTURE "99,999.99"
            @ 22, 12 SAY "Volume :" GET nvol   PICTURE "99.999"
            @ 23, 11 SAY "( Volume in Cu/M )"
            READ
            nlen := nvol / ncsarea
            // **  ncost=( nrate/nlen )*nvol
            @ 22, 32 SAY "Metres " + Str( nlen, 5 )
            ncsarea := 0
            ncsarea := ( Part->Width * Part->Thick ) // cross sectional area in sq mm
            ncsarea := ncsarea / 1000000             // cross sectional area in sq metres
            IF nvol / ncsarea > 0
                Part->Instock := nvol / ncsarea          // length in metres
            ENDIF
            @ 22, 45 SAY "Qty.Mtr-Length" GET Part->Instock PICTURE "999999.99"  // This shows in usual input format
            READ
        ELSE
            @ Row(), 3 SAY Part->Catno
            @ Row(), 16 GET Part->Desc
            @ Row(), 68 GET Part->Instock PICTURE "99999.99"
            READ
        ENDIF                  // Cu Mtr
        Part->Line := "   *"
        UNLOCK
        Scroll( 5, 4, 22, 74 )
        LOOP
        COMMIT
        continue := "Y"
    ENDDO                    // mcontinue

    RETURN NIL

// ***  End of PartStock()

// **--------------------------------------------------------------------------

FUNCTION ProfCost( nl )

    mok := "Y"
    DO WHILE mok == "Y"
        Scroll()
        nl := 0
        dstmm  := Date() -30
        dendmm := Date()
        @  8, 5 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
        @ 10, 5 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
        READ

        mwhere := "S"
        Scroll()

        Printsel()                                  // _LF_Init

        SELECT Part
        SET ORDER TO 3
        GOTO TOP
        @  nl, 8 SAY Control->U_Name
        @  nl, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl++
        @  nl, 20 SAY "Total "
        @  nl, 37 SAY Message->Stock1
        @  nl, 51 SAY Message->Stock2
        @  nl, 61 SAY Message->Stock3
        @  nl, 71 SAY Message->Stock4
        ntotal := nvan1 := nvan2 := nvan3 := 0
        DO WHILE Part->( !Eof() )
            IF Part->Instock > 0
                ntotal += Part->Instock * Part->Trade
            ENDIF                                             // Instock > 0
            SELECT Prof
            SEEK Message->Stock2 + Part->Partnum
            IF Prof->Codeno = Message->Stock2
                IF Prof->Qty > 0
                    nvan1 += ( Prof->Qty * Part->Trade )
                ENDIF
            ENDIF
            SELECT Prof
            SEEK Message->Stock3 + Part->Partnum
            IF Prof->Codeno = Message->Stock3
                IF Prof->Qty > 0
                    nvan2 += ( Prof->Qty * Part->Trade )
                ENDIF
            ENDIF
            SELECT Prof
            SEEK Message->Stock4 + Part->Partnum
            IF Prof->Codeno = Message->Stock4
                IF Prof->Qty > 0
                    nvan3 += ( Prof->Qty * Part->Trade )
                ENDIF
            ENDIF
            SELECT Part
            SKIP ALIAS Part
        ENDDO
        nl += 2
        @  nl, 0 SAY "Inventory Totals"
        @  nl, 18 SAY ntotal + nvan1 + nvan2 + nvan3 PICTURE "$9,999,999.99"
        @  nl, 34 SAY ntotal PICTURE "9,999,999.99"
        @  nl, 47 SAY nvan1  PICTURE "9999,999.99"
        @  nl, 59 SAY nvan2  PICTURE "9999,999.99"
        @  nl, 70 SAY nvan3  PICTURE "9999,999.99"
        nl += 2
        SELECT Part
        SET ORDER TO 1

        mmonthcr := Month( Date() ) -1

        DO CASE
        CASE mmonthcr == 0
            mmonth1 := 11
            mmonthcr := 12
        CASE mmonthcr == 1
            mmonth1 := 12
        OTHERWISE
            mmonth1 := mmonthcr - 1
        ENDCASE
        @  nl, 28 SAY "2 Month"
        @  nl, 39 SAY "1 Month"
        @  nl, 50 SAY "Current"
        @  nl, 59 SAY "This Month"
        @  nl, 72 SAY "Total"
        nl++

        // Credits

        mgthis := mgtotcr := mgtot1 := mgtot2 := mgtotr := 0
        SELECT Credit
        GOTO TOP
        DO WHILE Credit->( !Eof() )
            IF Credit->InvDate > dendmm
                SKIP ALIAS Credit
                LOOP
            ENDIF
            IF Credit->InvDate < dstmm
                SKIP ALIAS Credit
                LOOP
            ENDIF
            IF Credit->Amount == 0
                SKIP ALIAS Credit
                LOOP
            ENDIF
            mtot1 := mthis := mtot2 := mtotcr := 0
            DO CASE
            CASE Month( Credit->Invdate ) == Month( Date() )
                mthis  := Credit->Amount
            CASE Month( Credit->Invdate ) == mmonthcr
                mtotcr := Credit->Amount
            CASE Month( Credit->Invdate ) == mmonth1
                mtot1  := Credit->Amount
            OTHERWISE
                mtot2  := Credit->Amount
            ENDCASE
            mgthis  += mthis
            mgtotcr += mtotcr
            mgtot1  += mtot1
            mgtot2  += mtot2
            mgtotr  += mthis + mtotcr + mtot1 + mtot2
            SKIP ALIAS Credit
        ENDDO                         // Credit EOF()
        // **      nl++
        @ nl, 26 SAY Replicate( "-", 53 )
        nl++
        @ nl, 7 SAY "Credit Totals"
        @ nl, 25 SAY mgtot2  PICTURE "999,999.99"
        @ nl, 36 SAY mgtot1  PICTURE "999,999.99"
        @ nl, 47 SAY mgtotcr PICTURE "999,999.99"
        @ nl, 58 SAY mgthis  PICTURE "999,999.99"
        @ nl, 69 SAY mgtotr  PICTURE "999,999.99"
        nl++
        @ nl, 26 SAY Replicate( "=", 53 )
        nl++
        SELECT Pay
        GOTO TOP
        mamount := 0
        SET ORDER TO 2
        SEEK "N"
        DO WHILE Pay->Recon = "N" .AND. Pay->( !Eof() )
            ApRLock( 3 )
            mamount += Pay->Amount
            UNLOCK
            SKIP ALIAS Pay
        ENDDO
        SET ORDER TO 1
        @ nl, 0 SAY "Awaiting Presentation"
        @ nl, 22 SAY mamount PICTURE "9,999,999.99"
        @ nl, 40 SAY "Grand Total Credits"
        @ nl, 60 SAY mgtotr + mamount PICTURE "9,999,999.99"
        nl += 2

        // Debits
        @  nl, 28 SAY "2 Month"
        @  nl, 39 SAY "1 Month"
        @  nl, 50 SAY "Current"
        @  nl, 59 SAY "This Month"
        @  nl, 72 SAY "Total"
        nl++
        mggthis := mggtotcr := mggtot1 := mggtot2 := mggtotr := 0
        SELECT Debit
        GOTO TOP
        DO WHILE Debit->( !Eof() )
            IF Debit->DbDate > dendmm
                SKIP ALIAS Debit
                LOOP
            ENDIF
            IF Debit->Dbdate < dstmm
                SKIP ALIAS Debit
                LOOP
            ENDIF
            IF Debit->Amount == 0
                SKIP ALIAS Debit
                LOOP
            ENDIF
            mgthis := mgtotcr := mgtot1 := mgtot2 := mgtotr := 0
            DO CASE
            CASE Year(  Debit->Dbdate ) = Year( Date() ) -2
                mgtot2  += Debit->Amount
            CASE Year(  Debit->Dbdate ) = Year( Date() ) -1;
                    .AND. Month( Debit->DbDate ) < 10
                mgtot2  += Debit->Amount
            CASE Month( Debit->Dbdate ) == Month( Date() )
                mgthis  += Debit->Amount
            CASE Month( Debit->Dbdate ) == mmonthcr
                mgtotcr += Debit->Amount
            CASE Month( Debit->Dbdate ) == mmonth1
                mgtot1  += Debit->Amount
            OTHERWISE
                mgtot2  += Debit->Amount
            ENDCASE
            mggthis  += mgthis
            mggtotcr += mgtotcr
            mggtot1  += mgtot1
            mggtot2  += mgtot2
            mggtotr  += mgthis + mgtotcr + mgtot1 + mgtot2
            SKIP ALIAS Debit
        ENDDO
        @ nl, 26 SAY Replicate( "-", 53 )
        nl++
        @ nl, 7 SAY "Debtors Totals :"
        @ nl, 25 SAY mggtot2  PICTURE "999,999.99"
        @ nl, 36 SAY mggtot1  PICTURE "999,999.99"
        @ nl, 47 SAY mggtotcr PICTURE "999,999.99"
        @ nl, 58 SAY mggthis  PICTURE "999,999.99"
        @ nl, 69 SAY mggtotr  PICTURE "999,999.99"
        nl++
        @ nl, 26 SAY Replicate( "=", 53 )
        nl++
        @ nl, 9 SAY "  Percentage %"
        @ nl, 30 SAY ( mggtot2 / mggtotr * 100 ) PICTURE "9999 %"
        @ nl, 41 SAY ( mggtot1 / mggtotr * 100 ) PICTURE "9999 %"
        @ nl, 53 SAY ( mggtotcr / mggtotr * 100 ) PICTURE "9999 %"
        @ nl, 64 SAY ( mggthis / mggtotr * 100 ) PICTURE "9999 %"
        // @ nl,70 SAY "100 %"
        nl++

        // Deposits

        mgstot := mgutot := mgsttot := mggsttot := 0
        SELECT Deposit
        SET ORDER TO 1
        GOTO TOP
        DO WHILE Deposit->( !Eof() )
            IF Deposit->DepDate > dendmm
                SKIP ALIAS Deposit
                LOOP
            ENDIF
            IF Deposit->DepDate < dstmm
                SKIP ALIAS Deposit
                LOOP
            ENDIF
            IF Year( Deposit->Depdate ) < Year( Date() )
                SKIP ALIAS Deposit
                LOOP
            ENDIF
            IF Month( Deposit->Depdate ) < Month( Date() ) -2
                SKIP ALIAS Deposit
                LOOP
            ENDIF
            IF Month( Deposit->Depdate ) = Month( Date() )
                SKIP ALIAS Deposit
                LOOP
            ENDIF
            IF Month( Deposit->Depdate ) > Month( Date() )
                EXIT
            ENDIF
            IF Month( Deposit->DepDate ) = Month( Date() ) -1
                IF Deposit->GstAmnt > 0
                    mgstot  += Deposit->Amount
                    mgsttot += Deposit->Gstamnt
                ELSE
                    mgutot += Deposit->Amount
                ENDIF
            ENDIF
            SKIP ALIAS Deposit
        ENDDO                                   // Deposit EOF()
        nl++
        @ nl, 0 SAY "Last Month " + Str( mmonthcr, 2 ) + "  SALES EXCL G.S.T"
        @ nl, 33 SAY mgstot - mgsttot PICTURE "$9,999,999.99"
        @ nl, 49 SAY "DEPOSITS"
        @ nl, 59 SAY mgstot + mgutot PICTURE "$9,999,999.99"
        nl += 2
        @ nl, 0 SAY "Deposits Plus Debtors"
        @ nl, 25 SAY ( mgstot + mgutot ) + mggtotr PICTURE "$9,999,999.99"
        IF mwhere != "P"
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        mok := ApGetN( Message->Another + "Print" )
    ENDDO

    RETURN NIL

// **** End of File ProfCost

// ****---------------------- End of File XLF_Prof.PRG
