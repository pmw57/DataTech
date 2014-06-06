// **  JK  22-11-10 09:30:30

// ** 22-11-10 09:30:34
// ** 10-11-10 16:44:09

// **  Note Select8
/*
   Program.....:                  XLF_EQU3.PRG
   Authors.....: J.Kirby
   Date........: 23/03/2002
   Functions...: EquTotal, EquEach, EquCutMtr, EquPart
   Not used....: EquDesc, EquSelect
*/

// (c) Copyright 1993 by Kirby Christchurch.

FUNCTION EquTotal()

    mprice := "N"
    // ** ApGetY( "Do you Want Prices" )
    mused := ApGetN( "Do you Want Where Used" )
    Scroll(  16, 0, 24, 80 )
    DispBox( 16, 1, 24, 79, 2 )
    ncostadd := 0
    IF mprice = "Y"
        @ 18, 10 SAY "Add % on Cost Price" GET ncostadd PICTURE "9999.999"
        READ
        ncostadd := ncostadd / 100
    ENDIF
    mlevel := 4
    // **      @ 20,10 SAY "Must be level 4 for Full Details" COLOR "RG+"
    @ 22, 10 SAY "Module Level Required  2, 3, 4" GET mlevel PICTURE "9"
    READ
    nl := 0
    mwhere := "S"
    npl    := 60

    Printsel( mwhere, npl )

    IF mwhere = "P"
        npl := 60
    ELSE
        npl := 16
    ENDIF
    SELECT EquDesc
    SET ORDER TO 1          // ModCode
    SEEK mmodcode
    npn := 1
    @  nl, 0 SAY Control->U_Name
    @  nl, 50 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  nl, 76 SAY npn PICTURE "99"
    nl += 2
    @  nl, 0 SAY Equdesc->Modcode + "  " + Equdesc->Desc
    nl++
    ntotal := ntradetot := nselltot := 0
    nlabpart := npartqty := 0
    aPart_ := {}
    anum   := {}
    nequtrade1 := nequtrade2 := nequtrade3 := nequtrade4 := 0
    nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
    nqty1 := nqty2 := nqty3 := nqty4 := 0
    nequ1 := nequ2 := nequ3 := nequ4 := 0
    SELECT Equ
    SET EXACT ON
    GOTO TOP
    SEEK mmodcode
    IF Found()
        DO WHILE  Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
            nqty1 := Equ->PartQty
            nequ1 := nqty1
            IF nl > npl
                IF mwhere = "S"
                    WAIT
                    Scroll()
                    nl := 0
                ELSE
                    npn++
                    EJECT
                    nl := 0
                    @  nl, 0 SAY Control->U_Name
                    @  nl, 50 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  nl, 76 SAY npn PICTURE "99"
                    nl += 2
                    @  nl, 0 SAY Equdesc->Modcode
                    @  nl, 25 SAY Equdesc->Desc
                    nl++
                ENDIF
            ENDIF       // npl
            SELECT Part
            SEEK Equ->Partnum
            nequtrade1 += nqty1 * Part->Trade
            @ nl, 0 SAY Str( nequ1, 7, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                + "  " + SubStr( Part->Desc, 1, 30 );
                + " " + SubStr( Part->Unit, 1, 2 );
                + " ."
            IF mprice = "Y"
                @ nl, 61 SAY ( nequ1 * Part->Trade ) + ( ( nequ1 * Part->Trade ) * ncostadd );
                    PICTURE "999,999.99"
                ntotal := ntotal + ( nequ1 * Part->Trade ) + ( ( nequ1 * Part->Trade ) * ncostadd )
            ENDIF
            ddate := DToC( Part->Date )
            @ nl, 72 SAY SubStr( ddate, 4, 3 ) + SubStr( ddate, 9, 2 )
            IF Part->Date <= Date() -60
                IF Part->Boughtout = "Y"
                    IF Part->Trade >= 3
                        @ nl, 78 SAY "*"
                    ENDIF
                ENDIF
            ENDIF
            IF Equ->Partnum = Message->LabPart
                nlabpart += nequ1
            ENDIF
            nl++
            SELECT EquCut
            GOTO TOP
            SEEK Equ->ModSeqno
            DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                IF EquCut->Partnum != Equ->Partnum
                    SKIP ALIAS EquCut
                    LOOP
                ENDIF
                IF mwhere = "S"
                    IF nl > 20
                        Inkey( 0 )
                        nl := 3
                        Scroll(  nl, 1, 24, 80 )
                    ENDIF
                ENDIF
                @ nl, 5 SAY EquCut->ModRef
                @ nl, 47 SAY EquCut->Qty          PICTURE "9,999.99"
                @ nl, 64 SAY DToC( EquCut->Date ) PICTURE "99/99/9999"
                nl++
                SKIP ALIAS EquCut
            ENDDO
            SELECT Equ
            mmod2   := Trim( Equ->Partnum )
            nrecno2 := RecNo()
            GOTO TOP
            SEEK mmod2
            IF !Found()
                ntradeTot += nequ1 * Part->Trade
            ENDIF
            IF Found()
                nequtrade2 := 0
                DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                    nqty2 := Equ->PartQty
                    nequ2 := nqty1 * nqty2
                    SELECT Part
                    SEEK Equ->Partnum
                    nequtrade2 += nqty2 * Part->Trade
                    // **            IF Equ->Partnum = Message->LabPart
                    // **               nlabpart += nequ2
                    // **            ENDIF
                    IF mlevel >= 2
                        IF mwhere = "S"
                            IF nl > 22
                                Inkey( 0 )
                                nl := 3
                                Scroll(  nl, 1, 24, 80 )
                            ENDIF
                        ENDIF
                        @ nl, 0 SAY Str( nequ2, 8, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                            + " " + SubStr( Part->Desc, 1, 30 );
                            + " " + SubStr( Part->Unit, 1, 2 );
                            + " .."
                        IF mprice = "Y"
                            @ nl, 63 SAY ( nequ2 * Part->Trade ) + ( ( nequ2 * Part->Trade ) * ncostadd );
                                PICTURE "999999.99"
                            // **            ntotal := ntotal+( nequ2*Part->Trade )+(( nequ2*Part->Trade )*ncostadd)
                        ENDIF
                        ddate := DToC( Part->Date )
                        @ nl, 72 SAY SubStr( ddate, 4, 3 ) + SubStr( ddate, 9, 2 )
                        IF Part->Date <= Date() -60
                            IF Part->Boughtout = "Y"
                                IF Part->Trade >= 3
                                    @ nl, 78 SAY "*"
                                ENDIF
                            ENDIF
                        ENDIF
                        nl++
                    ENDIF     // mlevel > 2
                    IF mlevel >= 2
                        SELECT EquCut
                        GOTO TOP
                        SEEK Equ->ModSeqno
                        DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                            IF EquCut->Partnum != Equ->Partnum
                                SKIP ALIAS EquCut
                                LOOP
                            ENDIF
                            IF mwhere = "S"
                                IF nl > npl
                                    Inkey( 0 )
                                    nl := 3
                                    Scroll(  nl, 1, 24, 80 )
                                ENDIF
                            ENDIF
                            @ nl, 5 SAY EquCut->ModRef
                            @ nl, 47 SAY EquCut->Qty          PICTURE "9,999.99"
                            @ nl, 64 SAY DToC( EquCut->Date ) PICTURE "99/99/9999"
                            nl++
                            SKIP ALIAS EquCut
                        ENDDO
                    ENDIF     // mlevel >= 2
                    SELECT Equ
                    mmod3   := Trim( Equ->Partnum )
                    nrecno3 := RecNo()
                    GOTO TOP
                    SEEK mmod3
                    IF !Found()
                        ntradeTot += nequ2 * Part->Trade
                    ENDIF
                    IF Found()
                        nequtrade3 := 0
                        DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                            SELECT Part
                            SEEK Equ->Partnum
                            nqty3 := Equ->PartQty
                            nequ3 := nqty1 * nqty2 * nqty3
                            nequtrade3 += nqty3 * Part->Trade
                            IF mlevel >= 3
                                IF mwhere = "S"
                                    IF nl > npl
                                        Inkey( 0 )
                                        nl := 3
                                        Scroll(  nl, 1, 24, 80 )
                                    ENDIF
                                ENDIF
                                @ nl, 0 SAY Str( nequ3, 8, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                                    + " " + SubStr( Part->Desc, 1, 30 );
                                    + " " + SubStr( Part->Unit, 1, 2 );
                                    + " ..."
                                IF mprice = "Y"
                                    @ nl, 63 SAY ( nequ3 * Part->Trade ) + ( ( nequ3 * Part->Trade ) * ncostadd );
                                        PICTURE "99999.99"
                                    // **            ntotal := ntotal+( nequ3*Part->Trade )+(( nequ3*Part->Trade )*ncostadd)
                                ENDIF
                                ddate := DToC( Part->Date )
                                @ nl, 72 SAY SubStr( ddate, 4, 3 ) + SubStr( ddate, 9, 2 )
                                IF Part->Date <= Date() -60
                                    IF Part->Boughtout = "Y"
                                        IF Part->Trade >= 3
                                            @ nl, 78 SAY "*"
                                        ENDIF
                                    ENDIF
                                ENDIF
                                nl++
                            ENDIF

                            // **            IF Equ->Partnum = Message->LabPart
                            // **               nlabpart += nequ3
                            // **            ENDIF
                            SELECT Equ
                            mmod4   := Trim( Equ->Partnum )
                            nrecno4 := RecNo()
                            GOTO TOP
                            SEEK mmod4
                            IF !Found()
                                ntradeTot += nequ3 * Part->Trade
                            ENDIF
                            IF Found()
                                nequtrade4 := 0
                                DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                    nqty4 := Equ->PartQty
                                    nequ4 := ( nqty4 * nqty3 ) * nqty1 * nqty2
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    nequtrade4 += nqty4 * Part->Trade
                                    ntradeTot  += nequ4 * Part->Trade
                                    IF Equ->Partnum = Message->LabPart
                                        nlabpart += nequ4
                                    ENDIF
                                    IF mlevel >= 4
                                        IF mwhere = "S"
                                            IF nl > npl
                                                Inkey( 0 )
                                                nl := 3
                                                Scroll(  nl, 1, 24, 80 )
                                            ENDIF
                                        ENDIF
                                        @ nl, 0 SAY Str( nequ4, 8, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                                            + " " + SubStr( Part->Desc, 1, 30 );
                                            + " " + SubStr( Part->Unit, 1, 2 );
                                            + " ...."
                                        IF mprice = "Y"
                                            @ nl, 63 SAY ( nequ4 * Part->Trade ) + ( ( nequ4 * Part->Trade ) * ncostadd );
                                                PICTURE "9999.99"
                                            // **            ntotal := ntotal+( nequ4*Part->Trade )+(( nequ4*Part->Trade )*ncostadd)
                                        ENDIF
                                        ddate := DToC( Part->Date )
                                        @ nl, 72 SAY SubStr( ddate, 4, 3 ) + SubStr( ddate, 9, 2 )
                                        IF Part->Date <= Date() -60
                                            IF Part->Boughtout = "Y"
                                                IF Part->Trade >= 3
                                                    @ nl, 78 SAY "*"
                                                ENDIF
                                            ENDIF
                                        ENDIF
                                        nl++
                                    ENDIF           // mlevel >= 4
                                    IF mlevel >= 4
                                        SELECT EquCut
                                        GOTO TOP
                                        SEEK Equ->ModSeqno
                                        DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                                            IF EquCut->Partnum != Equ->Partnum
                                                SKIP ALIAS EquCut
                                                LOOP
                                            ENDIF
                                            IF mwhere = "S"
                                                IF nl > npl
                                                    Inkey( 0 )
                                                    nl := 3
                                                    Scroll(  nl, 1, 24, 80 )
                                                ENDIF
                                            ENDIF
                                            @ nl, 5 SAY EquCut->ModRef
                                            @ nl, 47 SAY EquCut->Qty          PICTURE "9,999.99"
                                            @ nl, 64 SAY DToC( EquCut->Date ) PICTURE "99/99/9999"
                                            nl++
                                            SKIP ALIAS EquCut
                                        ENDDO
                                    ENDIF            // mlevel
                                    // **            IF Equ->Partnum = Message->LabPart
                                    // **               nlabpart += nequ4
                                    // **            ENDIF
                                    SELECT Equ
                                    SKIP ALIAS Equ
                                ENDDO                       // mmod4
                            ENDIF                           // Found mmod4
                            // **      ENDIF                             // mlevel 4
                            SELECT Equ
                            GOTO nrecno4
                            SKIP ALIAS Equ
                        ENDDO                       // mmod3
                    ENDIF                          // FOUND  mmod3
                    // **    ENDIF                             // mlevel 3
                    SELECT Equ
                    GOTO nrecno3
                    SKIP ALIAS Equ
                ENDDO                       // mmod2
            ENDIF                          // FOUND  mmod2
            // **   ENDIF                             // mlevel 2
            SELECT Equ
            GOTO nrecno2
            SKIP ALIAS Equ
        ENDDO                       // mmod1
    ENDIF                          // FOUND()  mmod1
    SET EXACT OFF
    IF mprice = "Y"
        nl++
        // ***       NO GOOD
        // ***      ncostadd := ncostadd*100
        // **      @ nl,48 SAY "Kit Cost"
        @ nl, 58 SAY ntotal PICTURE "$9,999,999.99"
        // **nequtrade1+( nequtrade1*ncostadd ) PICTURE "$9,999,999.99"
        nl++
        @ nl, 58 SAY "--------------"
        nl += 3
        @ nl, 0 SAY ncostadd * 100 PICTURE "9999"
        @ nl, 6 SAY "Level"
        @ nl, 12 SAY mlevel PICTURE "99"
        SELECT Part
        SET ORDER TO 1
        SEEK Message->LabPart
        nlabAmnt := ( nlabpart * Part->Trade ) + ( ( nlabpart * Part->Trade ) * ncostadd )
        // **      @ nl,20 SAY "Parts"
        // **      @ nl,26 SAY ntotal-nlabamnt PICTURE "$9,999,999.99"
        @ nl, 15 SAY "Labour"
        @ nl, 22 SAY nlabpart PICTURE "9999.99"
        @ nl, 30 SAY nlabAmnt PICTURE "$99,999.99"
        SEEK mmodcode
        @ nl, 44 SAY "Part File"
        @ nl, 58 SAY Part->Trade + ( Part->Trade * ncostadd ) PICTURE "$9,999,999.99"
        nl += 2
        @ nl, 0 SAY "File Sell Price"
        @ nl, 17 SAY Part->Trade     PICTURE "$9,999,999.99"
        @ nl, 32 SAY Part->Markup    PICTURE "9999.99 %"
        @ nl, 43 SAY Part->Wholesale PICTURE "$9,999,999.99"
        @ nl, 57 SAY Part->Date
    ENDIF
    IF mused = "Y"
        SELECT EquDesc
        SEEK mmodcode
        nl++
        @ nl, 0 SAY EquDesc->ModCode + "  " + EquDesc->Desc + " Used Where Qty"
        nl += 2
        SELECT Equ
        GOTO TOP
        DO WHILE Equ->( !Eof() )
            IF nl > npl
                IF mwhere = "S"
                    WAIT
                    Scroll()
                    nl := 0
                ELSE
                    npn++
                    EJECT
                    nl := 0
                    @  nl, 0 SAY Control->U_Name
                    @  nl, 50 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  nl, 76 SAY npn PICTURE "99"
                    nl += 2
                    SELECT EquDesc
                    SEEK mmodcode
                    @  nl, 5 SAY Equdesc->Modcode + "  " + Equdesc->Desc
                    nl++
                ENDIF
            ENDIF       // npl
            IF Equ->Partnum != mmodcode
                SKIP ALIAS Equ
                LOOP
            ENDIF
            @ nl, 2 SAY Equ->Modcode
            SELECT EquDesc
            SEEK Equ->Modcode
            @ nl, 20 SAY EquDesc->Desc
            SELECT Equ
            @ nl, 62 SAY Equ->PartQty PICTURE "999,999.99"
            nl++
            SKIP ALIAS Equ
        ENDDO                            // EOF Equ
    ENDIF                               // mused
    SELECT EquDesc
    SEEK mmodcode
    SELECT Part
    SEEK mmodcode
    mpartnum := Part->Partnum
    IF mwhere = "P"
        @ nl, 0 SAY " "
        EndPrint()
        SET MARGIN TO 0
    ELSE
        IF nl > npl
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN mmodcode

   /*
   mprice := ApGetY( "Do you Want Prices" )
   SCROLL(  20, 0,24,80)
   DISPBOX( 20, 1,24,79, 2 )
   ncostadd := 0
   IF mprice = "Y"
      @ 21,10 SAY "Add % on Cost Price" GET ncostadd PICTURE "9999.999"
       READ
      ncostadd := ncostadd/100
   ENDIF
   mlevel := 4
   @ 22,10 SAY "Module Level Required  2, 3, 4" GET mlevel PICTURE "9"
    READ
   nl := 0
   mwhere := "S"
   npl    := 54

   Printsel( mwhere, npl )

   @  nl, 0 SAY Control->U_Name
   @  nl,54 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
              +STR( YEAR(DATE() ),5 )
   nl+=2
   SELECT Equdesc
   SEEK mmodcode
   @  nl, 2 SAY Equdesc->Modcode
   @  nl,24 SAY Equdesc->Desc
   nl++
   ntotal:= ntradetot:= nselltot:= 0
   nlabpart:= npartqty := 0
   aPart_ := {}
   anum   := {}
   nequtrade1:= nequtrade2:= nequtrade3 :=nequtrade4 := 0
   nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
   nqty1:= nqty2:= nqty3:= nqty4 := 0
   nequ1:= nequ2:= nequ3:= nequ4 := 0
   SELECT Equ
   SET EXACT ON
   GOTO TOP
   SEEK mmodcode
   IF FOUND()
      DO WHILE  Equ->Modcode = mmodcode .AND. Equ->( !EOF() )
         nrecno1 := RECNO()
         nqty1 := Equ->PartQty
         nequ1 := nqty1
         IF mwhere = "S"
            IF nl > 22
               WAIT
               SCROLL()
               nl := 0
            ENDIF
         ENDIF
         SELECT Part
         SEEK Equ->Partnum
         nequtrade1 += nqty1*Part->Trade
         @ nl, 0 SAY STR( nequ1, 9, 3 )+" "+SUBSTR( Equ->Partnum, 1,16 );
                     +" "+SUBSTR( Part->Desc, 1,30 )
         IF mprice = "Y"
            @ nl,59 SAY ( nequ1*Part->Trade )+(( nequ1*Part->Trade )*ncostadd);
                         PICTURE "999,999.99"
         ENDIF
         IF Part->Date < DATE()-60
         ENDIF
         nl++
         SELECT Equ
         mmod2   := TRIM( Equ->Partnum )
         GOTO TOP
         SEEK mmod2
         IF FOUND()
            IF mlevel >= 3
               nequtrade2 := 0
               DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
                  nrecno2 := RECNO()
                  nqty2 := Equ->PartQty
                  nequ2 := nqty1 * nqty2
                  IF mwhere = "S"
                     IF nl > 22
                        WAIT
                        SCROLL()
                        nl := 0
                     ENDIF
                  ENDIF
                  SELECT Part
                  SEEK Equ->Partnum
                  nequtrade2 += nqty2*Part->Trade
                  @ nl, 0 SAY STR( nequ2, 9, 3 )+"  "+SUBSTR( Equ->Partnum, 1,15 );
                              +" "+SUBSTR( Part->Desc, 1,30 )
                  IF mprice = "Y"
                     @ nl,59 SAY ( nequ2*Part->Trade )+(( nequ2*Part->Trade )*ncostadd);
                      PICTURE "99,999.99"
                  ENDIF
                  IF Part->Date < DATE()-60
                     @ nl,70 SAY Part->Date
                  ENDIF
                  nl++
                  IF mlevel >= 4
                     SELECT Equ
                     mmod3   := TRIM( Equ->Partnum )
                     GOTO TOP
                     SEEK mmod3
                     IF FOUND()
                        nequtrade3 := 0
                        DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
                           nrecno3 := RECNO()
                           IF mwhere = "S"
                              IF nl > 22
                                 WAIT
                                 SCROLL()
                                 nl := 0
                              ENDIF
                           ENDIF
                           SELECT Part
                           SEEK Equ->Partnum
                           nqty3 := Equ->PartQty
                           nequ3 := nqty1 * nqty2 * nqty3
                           nequtrade3 += nqty3*Part->Trade
                           @ nl, 0 SAY STR( nequ3, 8, 3 )+"   "+SUBSTR( Equ->Partnum, 1,14 );
                                       +" "+SUBSTR( Part->Desc, 1,30 )
                           IF mprice = "Y"
                              @ nl,59 SAY ( nequ3*Part->Trade )+(( nequ3*Part->Trade )*ncostadd );
                              PICTURE "99,999.99"
                           ENDIF
                           IF Part->Date < DATE()-60
                              @ nl,70 SAY Part->Date
                           ENDIF
                           nl++
                           IF mlevel >= 4
                              SELECT Equ
                              mmod4   := TRIM( Equ->Partnum )
                              GOTO TOP
                              SEEK mmod4
                              IF FOUND()
                                 nequtrade4 := 0
                                 DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                                    nrecno4 := RECNO()
                                    nqty4 := Equ->PartQty
                                    nequ4 := ( ( nqty4*nqty3 )*nqty1 * nqty2
                                    IF mwhere = "S"
                                       IF nl > 22
                                          WAIT
                                          SCROLL()
                                          nl := 0
                                       ENDIF
                                    ENDIF
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    nequtrade4 += nqty4*Part->Trade
                                    @ nl, 0 SAY STR( nequ4, 9, 3 )+"    "+SUBSTR( Equ->Partnum, 1,12 );
                                                +" "+SUBSTR( Part->Desc, 1,30 )
                                    IF mprice = "Y"
                                       @ nl,59 SAY ( nequ4*Part->Trade )+(( nequ4*Part->Trade )*ncostadd);
                                         PICTURE "99,999.99"
                                    ENDIF
                                    IF Part->Date < DATE()-60
                                       @ nl,70 SAY Part->Date
                                    ENDIF
                                    nl++
                                    SELECT Equ
                                    SKIP ALIAS Equ
                                 ENDDO                       //  mmod4
                              ENDIF                           // Found mmod4
                           ENDIF               // mlevel >= 4
                           SELECT Equ
                           GOTO nrecno3
                           SKIP ALIAS Equ
                        ENDDO                       //  mmod3
                     ENDIF                          // FOUND  mmod3
                  ENDIF             //    mlevel >= 4
                  SELECT Equ
                  GOTO nrecno2
                  SKIP ALIAS Equ
               ENDDO                       // mmod2
            ENDIF                          // FOUND  mmod2
         ENDIF             //    mlevel = 2
         SELECT Equ
         GOTO nrecno1
         SKIP ALIAS Equ
      ENDDO                       // mmod1
   ENDIF                          // FOUND()  mmod1
   *** ENDIF             // mlevel = 1
   SET EXACT OFF
   IF mprice = "Y"
      nl++
      @ nl,66 SAY nequtrade1+( nequtrade1*ncostadd ) PICTURE "$9999,999.99"
   ENDIF
   IF mwhere = "P"
      @ nl, 0 SAY " "
      EndPrint()
      SET MARGIN TO 0
   ELSE
      IF nl > 20
         WAIT
      ENDIF
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF

   RETURN mmodcode
   */
// ***----- End of EquTotal()

// ***---------------------------------------------------------------------------

FUNCTION EquEach()

    Scroll( 20, 1, 24, 80 )
    mlevel := 4
    // **      @ 22,10 SAY "Module Level Required  2, 3, 4" GET mlevel PICTURE "9"
    // **       READ
    nl := 0
    mwhere := "S"
    npl    := 60

    Printsel( mwhere, npl )

    IF mwhere = "P"
        npl := 60
    ELSE
        npl := 16
    ENDIF
    SELECT EquDesc
    SET ORDER TO 1          // ModCode
    SEEK mmodcode
    npn := 1
    @  nl, 0 SAY Control->U_Name
    @  nl, 50 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  nl, 76 SAY npn PICTURE "99"
    nl += 2
    @  nl, 0 SAY Equdesc->Modcode + "  " + Equdesc->Desc + " " + EquDesc->Operno
    nl++
    ntotal := ntradetot := nselltot := 0
    nlabpart := npartqty := 0
    aPart_ := {}
    anum   := {}
    nequtrade1 := nequtrade2 := nequtrade3 := nequtrade4 := 0
    nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
    nqty1 := nqty2 := nqty3 := nqty4 := 0
    nequ1 := nequ2 := nequ3 := nequ4 := 0
    SELECT Equ
    SET EXACT ON
    GOTO TOP
    SEEK mmodcode
    IF Found()
        DO WHILE  Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
            nrecno1 := RecNo()
            nqty1 := Equ->PartQty
            nequ1 := nqty1
            IF nl > npl
                IF mwhere = "S"
                    WAIT
                    Scroll()
                    nl := 0
                ELSE
                    npn++
                    EJECT
                    nl := 0
                    @  nl, 0 SAY Control->U_Name
                    @  nl, 45 SAY "Each Use Parts"
                    @  nl, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  nl, 76 SAY npn PICTURE "99"
                    nl += 2
                    @  nl, 0 SAY Equdesc->Modcode + "  " + Equdesc->Desc;
                        + " " + EquDesc->Operno
                    nl++
                ENDIF
            ENDIF       // npl
            SELECT Part
            SEEK Equ->Partnum
            IF Part->Unit != "Each "
                SELECT Equ
                SKIP ALIAS Equ
                LOOP
            ENDIF
            SELECT EquCut
            GOTO TOP
            SEEK Equ->ModSeqno
            IF Found()
                @ nl, 0 SAY Str( nequ1, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                    + " " + Part->Desc
            ELSE
                SELECT Equ
                SKIP ALIAS Equ
                LOOP
            ENDIF
            IF Equ->Partnum = Message->LabPart
                nlabpart += nequ1
            ENDIF
            nl++
            DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                IF EquCut->Partnum != Equ->Partnum
                    SKIP ALIAS EquCut
                    LOOP
                ENDIF
                IF mwhere = "S"
                    IF nl > 20
                        Inkey( 0 )
                        nl := 3
                        Scroll(  nl, 1, 24, 80 )
                    ENDIF
                ENDIF
                @ nl, 11 SAY EquCut->ModRef
                @ nl, 56 SAY EquCut->Qty          PICTURE "9,999"
                @ nl, 64 SAY DToC( EquCut->Date ) PICTURE "99/99/9999"
                nl++
                SKIP ALIAS EquCut
            ENDDO
            SELECT Equ
            mmod2   := Trim( Equ->Partnum )
            GOTO TOP
            SEEK mmod2
            IF !Found()
                ntradeTot += nequ1 * Part->Trade
            ENDIF
            IF Found()
                nequtrade2 := 0
                DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                    nrecno2 := RecNo()
                    nqty2 := Equ->PartQty
                    nequ2 := nqty1 * nqty2
                    SELECT Part
                    SEEK Equ->Partnum
                    IF Part->Unit != "Each "
                        SELECT Equ
                        SKIP ALIAS Equ
                        LOOP
                    ENDIF
                    nequtrade2 += nqty2 * Part->Trade
                    IF Equ->Partnum = Message->LabPart
                        nlabpart += nequ2
                    ENDIF
                    IF mlevel >= 2
                        IF mwhere = "S"
                            IF nl > 22
                                Inkey( 0 )
                                nl := 3
                                Scroll(  nl, 1, 24, 80 )
                            ENDIF
                        ENDIF
                        SELECT EquCut
                        GOTO TOP
                        SEEK Equ->ModSeqno
                        SELECT Equ
                        IF Found()
                            @ nl, 0 SAY Str( nequ2, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                                + " " + Part->Desc
                        ELSE
                            SKIP ALIAS Equ
                            LOOP
                        ENDIF
                        nl++
                    ENDIF     // mlevel > 2
                    IF mlevel >= 2
                        SELECT EquCut
                        GOTO TOP
                        SEEK Equ->ModSeqno
                        DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                            IF EquCut->Partnum != Equ->Partnum
                                SKIP ALIAS EquCut
                                LOOP
                            ENDIF
                            IF mwhere = "S"
                                IF nl > npl
                                    Inkey( 0 )
                                    nl := 3
                                    Scroll(  nl, 1, 24, 80 )
                                ENDIF
                            ENDIF
                            @ nl, 11 SAY EquCut->ModRef
                            @ nl, 56 SAY EquCut->Qty          PICTURE "9,999"
                            @ nl, 64 SAY DToC( EquCut->Date ) PICTURE "99/99/9999"
                            nl++
                            SKIP ALIAS EquCut
                        ENDDO
                    ENDIF                       // mlevel
                    SELECT Equ
                    mmod3   := Trim( Equ->Partnum )
                    GOTO TOP
                    SEEK mmod3
                    IF !Found()
                        ntradeTot += nequ2 * Part->Trade
                    ENDIF
                    IF Found()
                        nequtrade3 := 0
                        DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                            nrecno3 := RecNo()
                            SELECT Part
                            SEEK Equ->Partnum
                            IF Part->Unit != "Each "
                                SELECT Equ
                                SKIP ALIAS Equ
                                LOOP
                            ENDIF
                            nqty3 := Equ->PartQty
                            nequ3 := nqty1 * nqty2 * nqty3
                            nequtrade3 += nqty3 * Part->Trade
                            IF mlevel >= 3
                                IF mwhere = "S"
                                    IF nl > npl
                                        Inkey( 0 )
                                        nl := 3
                                        Scroll(  nl, 1, 24, 80 )
                                    ENDIF
                                ENDIF
                                SELECT EquCut
                                GOTO TOP
                                SEEK Equ->ModSeqno
                                SELECT Equ
                                IF Found()
                                    @ nl, 0 SAY Str( nequ3, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                                        + " " + Part->Desc
                                ELSE
                                    SKIP ALIAS Equ
                                    LOOP
                                ENDIF
                                nl++
                            ENDIF
                            IF Equ->Partnum = Message->LabPart
                                nlabpart += nequ3
                            ENDIF
                            // **         SELECT Equ
                            mmod4   := Trim( Equ->Partnum )
                            GOTO TOP
                            SEEK mmod4
                            IF !Found()
                                ntradeTot += nequ3 * Part->Trade
                            ENDIF
                            IF Found()
                                nequtrade4 := 0
                                DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                    nrecno4 := RecNo()
                                    nqty4 := Equ->PartQty
                                    nequ4 := ( nqty4 * nqty3 ) * nqty1 * nqty2
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    IF Part->Unit != "Each "
                                        SELECT Equ
                                        SKIP ALIAS Equ
                                        LOOP
                                    ENDIF
                                    nequtrade4 += nqty4 * Part->Trade
                                    ntradeTot  += nequ4 * Part->Trade
                                    IF Equ->Partnum = Message->LabPart
                                        nlabpart += nequ4
                                    ENDIF
                                    IF mlevel >= 4
                                        IF mwhere = "S"
                                            IF nl > npl
                                                Inkey( 0 )
                                                nl := 3
                                                Scroll(  nl, 1, 24, 80 )
                                            ENDIF
                                        ENDIF
                                        SELECT EquCut
                                        GOTO TOP
                                        SEEK Equ->ModSeqno
                                        SELECT Equ
                                        IF Found()
                                            @ nl, 0 SAY Str( nequ4, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                                                + " " + Part->Desc
                                        ELSE
                                            SKIP ALIAS Equ
                                            LOOP
                                        ENDIF
                                        nl++
                                    ENDIF           // mlevel >= 4
                                    IF mlevel >= 4
                                        SELECT EquCut
                                        GOTO TOP
                                        SEEK Equ->ModSeqno
                                        DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                                            IF EquCut->Partnum != Equ->Partnum
                                                SKIP ALIAS EquCut
                                                LOOP
                                            ENDIF
                                            IF mwhere = "S"
                                                IF nl > npl
                                                    Inkey( 0 )
                                                    nl := 3
                                                    Scroll(  nl, 1, 24, 80 )
                                                ENDIF
                                            ENDIF
                                            @ nl, 11 SAY EquCut->ModRef
                                            @ nl, 56 SAY EquCut->Qty          PICTURE "9,999"
                                            @ nl, 64 SAY DToC( EquCut->Date ) PICTURE "99/99/9999"
                                            nl++
                                            SKIP ALIAS EquCut
                                        ENDDO
                                    ENDIF            // mlevel
                                    IF Equ->Partnum = Message->LabPart
                                        nlabpart += nequ4
                                    ENDIF
                                    SELECT Equ
                                    SKIP ALIAS Equ
                                ENDDO                       // mmod4
                            ENDIF                           // Found mmod4
                            SELECT Equ
                            GOTO nrecno3
                            SKIP ALIAS Equ
                        ENDDO                       // mmod3
                    ENDIF                          // FOUND  mmod3
                    SELECT Equ
                    GOTO nrecno2
                    SKIP ALIAS Equ
                ENDDO                       // mmod2
            ENDIF                          // FOUND  mmod2
            SELECT Equ
            GOTO nrecno1
            SKIP ALIAS Equ
        ENDDO                       // mmod1
    ENDIF                          // FOUND()  mmod1
    // **       SET EXACT OFF
    IF mwhere = "P"
        @ nl, 0 SAY " "
        EndPrint()
        SET MARGIN TO 0
    ELSE
        IF nl > npl
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN mmodcode

// ***---- End of EquEach()

// **---------------------------------------------------------------------*

FUNCTION EquCutMtr()

    Scroll(  18, 0, 24, 80 )
    DispBox( 18, 1, 24, 79, 2 )
    mlevel := 2
    @ 22, 10 SAY "Module Level Required  2, 3, 4" GET mlevel PICTURE "9"
    READ
    nl := 0
    mwhere := "S"
    npl    := 60

    Printsel( mwhere, npl )

    IF mwhere = "P"
        npl := 60
    ELSE
        npl := 16
    ENDIF
    SELECT EquDesc
    SET ORDER TO 1          // ModCode
    SEEK mmodcode
    npn := 1
    @  nl, 0 SAY Control->U_Name
    @  nl, 50 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  nl, 76 SAY npn PICTURE "99"
    nl += 2
    @  nl, 0 SAY Equdesc->Modcode + "  " + Equdesc->Desc + " " + EquDesc->Operno
    nl++
    ntotal := ntradetot := nselltot := 0
    nlabpart := npartqty := 0
    aPart_ := {}
    anum   := {}
    nequtrade1 := nequtrade2 := nequtrade3 := nequtrade4 := 0
    nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
    nqty1 := nqty2 := nqty3 := nqty4 := 0
    nequ1 := nequ2 := nequ3 := nequ4 := 0
    SET EXACT ON
    GOTO TOP
    SEEK mmodcode
    IF Found()
        DO WHILE  Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
            nqty1 := Equ->PartQty
            nequ1 := nqty1
            IF nl > npl
                IF mwhere = "S"
                    WAIT
                    Scroll()
                    nl := 0
                ELSE
                    npn++
                    EJECT
                    nl := 0
                    @  nl, 0 SAY Control->U_Name
                    @  nl, 50 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  nl, 76 SAY npn PICTURE "99"
                    nl += 2
                    @  nl, 0 SAY Equdesc->Modcode + "  " + Equdesc->Desc;
                        + " " + EquDesc->Operno
                    nl++
                ENDIF
            ENDIF       // npl
            SELECT Part
            SEEK Equ->Partnum
            IF Part->Unit = "Each "
                SELECT Equ
                SKIP ALIAS Equ
                LOOP
            ENDIF
            nequtrade1 += nqty1 * Part->Trade
            // **            SELECT EquCut
            // **            GOTO TOP
            // **            SEEK Equ->ModSeqno
            // **            IF FOUND()
            @ nl, 0 SAY Str( nequ1, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                + " " + SubStr( Part->Desc, 1, 35 ) + " " + SubStr( Part->Unit, 1, 6 )
            // **            ENDIF
            IF Equ->Partnum = Message->LabPart
                nlabpart += nequ1
            ENDIF
            nl++
            SELECT EquCut
            GOTO TOP
            SEEK Equ->ModSeqno
            DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                IF EquCut->Partnum != Equ->Partnum
                    SKIP ALIAS EquCut
                    LOOP
                ENDIF
                IF mwhere = "S"
                    IF nl > 20
                        Inkey( 0 )
                        nl := 3
                        Scroll(  nl, 1, 24, 80 )
                    ENDIF
                ENDIF
                @ nl, 5 SAY SubStr( EquCut->ModRef, 1, 30 )
                @ nl, 36 SAY "Qty"
                @ nl, 40 SAY EquCut->Qty    PICTURE "9,999"
                @ nl, 48 SAY EquCut->Length PICTURE "9,999.999"
                IF EquCut->Width != 0
                    @ nl, 58 SAY EquCut->Width  PICTURE "9,999.999"
                ENDIF
                nl++
                SKIP ALIAS EquCut
            ENDDO
            SELECT Equ
            mmod2   := Trim( Equ->Partnum )
            nrecno2 := RecNo()
            GOTO TOP
            SEEK mmod2
            IF !Found()
                ntradeTot += nequ1 * Part->Trade
            ENDIF
            IF Found()
                nequtrade2 := 0
                DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                    nqty2 := Equ->PartQty
                    nequ2 := nqty1 * nqty2
                    SELECT Part
                    SEEK Equ->Partnum
                    IF Part->Unit = "Each "
                        SELECT Equ
                        SKIP ALIAS Equ
                        LOOP
                    ENDIF
                    nequtrade2 += nqty2 * Part->Trade
                    IF Equ->Partnum = Message->LabPart
                        nlabpart += nequ2
                    ENDIF
                    IF mlevel >= 2
                        IF mwhere = "S"
                            IF nl > 22
                                Inkey( 0 )
                                nl := 3
                                Scroll(  nl, 1, 24, 80 )
                            ENDIF
                        ENDIF
                        // **            SELECT EquCut
                        // **            GOTO TOP
                        // **            SEEK Equ->ModSeqno
                        // **            IF FOUND()
                        @ nl, 0 SAY Str( nequ2, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                            + " " + SubStr( Part->Desc, 1, 35 ) + " " + SubStr( Part->Unit, 1, 6 )
                        nl++
                        // **            ENDIF
                    ENDIF     // mlevel > 2
                    IF mlevel >= 2
                        SELECT EquCut
                        GOTO TOP
                        SEEK Equ->ModSeqno
                        DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                            IF EquCut->Partnum != Equ->Partnum
                                SKIP ALIAS EquCut
                                LOOP
                            ENDIF
                            IF mwhere = "S"
                                IF nl > npl
                                    Inkey( 0 )
                                    nl := 3
                                    Scroll(  nl, 1, 24, 80 )
                                ENDIF
                            ENDIF
                            @ nl, 5 SAY SubStr( EquCut->ModRef, 1, 30 )
                            @ nl, 36 SAY "Qty"
                            @ nl, 40 SAY EquCut->Qty    PICTURE "9,999"
                            @ nl, 48 SAY EquCut->Length PICTURE "9,999.999"
                            IF EquCut->Width != 0
                                @ nl, 58 SAY EquCut->Width  PICTURE "9,999.999"
                            ENDIF
                            nl++
                            SKIP ALIAS EquCut
                        ENDDO
                    ENDIF                       // mlevel 2
                    SELECT Equ
                    mmod3   := Trim( Equ->Partnum )
                    nrecno3 := RecNo()
                    GOTO TOP
                    SEEK mmod3
                    IF !Found()
                        ntradeTot += nequ2 * Part->Trade
                    ENDIF
                    IF Found()
                        nequtrade3 := 0
                        DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                            SELECT Part
                            SEEK Equ->Partnum
                            IF Part->Unit = "Each "
                                SELECT Equ
                                SKIP ALIAS Equ
                                LOOP
                            ENDIF
                            nqty3 := Equ->PartQty
                            nequ3 := nqty1 * nqty2 * nqty3
                            nequtrade3 += nqty3 * Part->Trade
                            IF mlevel >= 3
                                IF mwhere = "S"
                                    IF nl > npl
                                        Inkey( 0 )
                                        nl := 3
                                        Scroll(  nl, 1, 24, 80 )
                                    ENDIF
                                ENDIF
                                // **            SELECT EquCut
                                // **            GOTO TOP
                                // **            SEEK Equ->ModSeqno
                                // **            IF FOUND()
                                @ nl, 0 SAY Str( nequ3, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                                    + " " + SubStr( Part->Desc, 1, 35 ) + " " + SubStr( Part->Unit, 1, 6 )
                                nl++
                                // **            ENDIF
                            ENDIF
                            IF Equ->Partnum = Message->LabPart
                                nlabpart += nequ3
                            ENDIF
                            SELECT Equ
                            mmod4   := Trim( Equ->Partnum )
                            nrecno4 := RecNo()
                            GOTO TOP
                            SEEK mmod4
                            IF !Found()
                                ntradeTot += nequ3 * Part->Trade
                            ENDIF
                            IF Found()
                                nequtrade4 := 0
                                DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                    nqty4 := Equ->PartQty
                                    nequ4 := ( nqty4 * nqty3 ) * nqty1 * nqty2
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    IF Part->Unit = "Each "
                                        SELECT Equ
                                        SKIP ALIAS Equ
                                        LOOP
                                    ENDIF
                                    nequtrade4 += nqty4 * Part->Trade
                                    ntradeTot  += nequ4 * Part->Trade
                                    IF Equ->Partnum = Message->LabPart
                                        nlabpart += nequ4
                                    ENDIF
                                    IF mlevel >= 4
                                        IF mwhere = "S"
                                            IF nl > npl
                                                Inkey( 0 )
                                                nl := 3
                                                Scroll(  nl, 1, 24, 80 )
                                            ENDIF
                                        ENDIF
                                        // **            SELECT EquCut
                                        // **            GOTO TOP
                                        // **            SEEK Equ->ModSeqno
                                        // **            IF FOUND()
                                        @ nl, 0 SAY Str( nequ4, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                                            + " " + SubStr( Part->Desc, 1, 35 ) + " " + SubStr( Part->Unit, 1, 6 )
                                        nl++
                                        // **            ENDIF
                                    ENDIF           // mlevel >= 4
                                    IF mlevel >= 4
                                        SELECT EquCut
                                        GOTO TOP
                                        SEEK Equ->ModSeqno
                                        DO WHILE EquCut->ModSeqno = Equ->Modseqno .AND. EquCut->( !Eof() )
                                            IF EquCut->Partnum != Equ->Partnum
                                                SKIP ALIAS EquCut
                                                LOOP
                                            ENDIF
                                            IF mwhere = "S"
                                                IF nl > npl
                                                    Inkey( 0 )
                                                    nl := 3
                                                    Scroll(  nl, 1, 24, 80 )
                                                ENDIF
                                            ENDIF
                                            @ nl, 5 SAY SubStr( EquCut->ModRef, 1, 30 )
                                            @ nl, 36 SAY "Qty"
                                            @ nl, 40 SAY EquCut->Qty    PICTURE "9,999"
                                            @ nl, 48 SAY EquCut->Length PICTURE "9,999.999"
                                            IF EquCut->Width != 0
                                                @ nl, 58 SAY EquCut->Width  PICTURE "9,999.999"
                                            ENDIF
                                            nl++
                                            SKIP ALIAS EquCut
                                        ENDDO
                                    ENDIF            // mlevel
                                    IF Equ->Partnum = Message->LabPart
                                        nlabpart += nequ4
                                    ENDIF
                                    SELECT Equ
                                    SKIP ALIAS Equ
                                ENDDO                       // mmod4
                            ENDIF                           // Found mmod4
                            // **      ENDIF                             // mlevel 4
                            SELECT Equ
                            GOTO nrecno4
                            SKIP ALIAS Equ
                        ENDDO                       // mmod3
                    ENDIF                          // FOUND  mmod3
                    // **    ENDIF                             // mlevel 3
                    SELECT Equ
                    GOTO nrecno3
                    SKIP ALIAS Equ
                ENDDO                       // mmod2
            ENDIF                          // FOUND  mmod2
            // **   ENDIF                             // mlevel 2
            SELECT Equ
            GOTO nrecno2
            SKIP ALIAS Equ
        ENDDO                       // mmod1
    ENDIF                          // FOUND()  mmod1
    SET EXACT OFF
    IF mwhere = "P"
        @ nl, 0 SAY " "
        EndPrint()
        SET MARGIN TO 0
    ELSE
        IF nl > npl
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN mmodcode

// ***---- End of EquCutEach()

// **---------------------------------------------------------------------*

FUNCTION EquPart( mmodcode )

    mprice := ApGetY( "Do you Want Prices" )
    Scroll(  20, 0, 24, 80 )
    DispBox( 20, 1, 24, 79, 2 )
    ncostadd := 0
    IF mprice = "Y"
        @ 21, 10 SAY "Add % on Cost Price" GET ncostadd PICTURE "9999.999"
        READ
        ncostadd := ncostadd / 100
    ENDIF
    mlevel := 4
    @ 22, 10 SAY "Module Level Required  2, 3, 4" GET mlevel PICTURE "9"
    READ
    nl := 0
    mwhere := "S"
    npl    := 54

    Printsel( mwhere, npl )

    @  nl, 0 SAY Control->U_Name
    @  nl, 54 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    nl += 2
    SELECT Equdesc
    SEEK mmodcode
    @  nl, 2 SAY Equdesc->Modcode + "  " + Equdesc->Desc;
        + " " + EquDesc->Operno
    nl++
    ntotal := ntradetot := nselltot := 0
    nlabpart := npartqty := 0
    aPart_ := {}
    anum   := {}
    nequtrade1 := nequtrade2 := nequtrade3 := nequtrade4 := 0
    nrecno1 := nrecno2 := nrecno3 := nrecno4 := 0
    nqty1 := nqty2 := nqty3 := nqty4 := 0
    nequ1 := nequ2 := nequ3 := nequ4 := 0
    SELECT Equ
    SET EXACT ON
    GOTO TOP
    SEEK mmodcode
    IF Found()
        DO WHILE  Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
            nrecno1 := RecNo()
            nqty1 := Equ->PartQty
            nequ1 := nqty1
            IF mwhere = "S"
                IF nl > 22
                    WAIT
                    Scroll()
                    nl := 0
                ENDIF
            ENDIF
            SELECT Part
            SEEK Equ->Partnum
            nequtrade1 += nqty1 * Part->Trade
            @ nl, 0 SAY Str( nequ1, 9, 3 ) + " " + SubStr( Equ->Partnum, 1, 16 );
                + " " + SubStr( Part->Desc, 1, 30 )
            IF mprice = "Y"
                @ nl, 59 SAY ( nequ1 * Part->Trade ) + ( ( nequ1 * Part->Trade ) * ncostadd );
                    PICTURE "999,999.99"
            ENDIF
            IF Part->Date < Date() -60
                @ nl, 70 SAY Part->Date
            ENDIF
            nl++
            SELECT Equ
            mmod2   := Trim( Equ->Partnum )
            GOTO TOP
            SEEK mmod2
            IF Found()
                IF mlevel >= 3
                    nequtrade2 := 0
                    DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                        nrecno2 := RecNo()
                        nqty2 := Equ->PartQty
                        nequ2 := nqty1 * nqty2
                        IF mwhere = "S"
                            IF nl > 22
                                WAIT
                                Scroll()
                                nl := 0
                            ENDIF
                        ENDIF
                        SELECT Part
                        SEEK Equ->Partnum
                        nequtrade2 += nqty2 * Part->Trade
                        @ nl, 0 SAY Str( nequ2, 9, 3 ) + "  " + SubStr( Equ->Partnum, 1, 15 );
                            + " " + SubStr( Part->Desc, 1, 30 )
                        IF mprice = "Y"
                            @ nl, 59 SAY ( nequ2 * Part->Trade ) + ( ( nequ2 * Part->Trade ) * ncostadd );
                                PICTURE "99,999.99"
                        ENDIF
                        IF Part->Date < Date() -60
                            @ nl, 70 SAY Part->Date
                        ENDIF
                        nl++
                        IF mlevel >= 4
                            SELECT Equ
                            mmod3   := Trim( Equ->Partnum )
                            GOTO TOP
                            SEEK mmod3
                            IF Found()
                                nequtrade3 := 0
                                DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                    nrecno3 := RecNo()
                                    IF mwhere = "S"
                                        IF nl > 22
                                            WAIT
                                            Scroll()
                                            nl := 0
                                        ENDIF
                                    ENDIF
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    nqty3 := Equ->PartQty
                                    nequ3 := nqty1 * nqty2 * nqty3
                                    nequtrade3 += nqty3 * Part->Trade
                                    @ nl, 0 SAY Str( nequ3, 8, 3 ) + "   " + SubStr( Equ->Partnum, 1, 14 );
                                        + " " + SubStr( Part->Desc, 1, 30 )
                                    IF mprice = "Y"
                                        @ nl, 59 SAY ( nequ3 * Part->Trade ) + ( ( nequ3 * Part->Trade ) * ncostadd );
                                            PICTURE "99,999.99"
                                    ENDIF
                                    IF Part->Date < Date() -60
                                        @ nl, 70 SAY Part->Date
                                    ENDIF
                                    nl++
                                    IF mlevel >= 4
                                        SELECT Equ
                                        mmod4   := Trim( Equ->Partnum )
                                        GOTO TOP
                                        SEEK mmod4
                                        IF Found()
                                            nequtrade4 := 0
                                            DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                                nrecno4 := RecNo()
                                                nqty4 := Equ->PartQty
                                                nequ4 := ( nqty4 * nqty3 ) * nqty1 * nqty2
                                                IF mwhere = "S"
                                                    IF nl > 22
                                                        WAIT
                                                        Scroll()
                                                        nl := 0
                                                    ENDIF
                                                ENDIF
                                                SELECT Part
                                                SEEK Equ->Partnum
                                                nequtrade4 += nqty4 * Part->Trade
                                                @ nl, 0 SAY Str( nequ4, 9, 3 ) + "    " + SubStr( Equ->Partnum, 1, 12 );
                                                    + " " + SubStr( Part->Desc, 1, 30 )
                                                IF mprice = "Y"
                                                    @ nl, 59 SAY ( nequ4 * Part->Trade ) + ( ( nequ4 * Part->Trade ) * ncostadd );
                                                        PICTURE "99,999.99"
                                                ENDIF
                                                IF Part->Date < Date() -60
                                                    @ nl, 70 SAY Part->Date
                                                ENDIF
                                                nl++
                                                SELECT Equ
                                                SKIP ALIAS Equ
                                            ENDDO                       // mmod4
                                        ENDIF                           // Found mmod4
                                    ENDIF               // mlevel >= 4
                                    SELECT Equ
                                    GOTO nrecno3
                                    SKIP ALIAS Equ
                                ENDDO                       // mmod3
                            ENDIF                          // FOUND  mmod3
                        ENDIF             // mlevel >= 4
                        SELECT Equ
                        GOTO nrecno2
                        SKIP ALIAS Equ
                    ENDDO                       // mmod2
                ENDIF                          // FOUND  mmod2
            ENDIF             // mlevel = 2
            SELECT Equ
            GOTO nrecno1
            SKIP ALIAS Equ
        ENDDO                       // mmod1
    ENDIF                          // FOUND()  mmod1
    // ** ENDIF             // mlevel = 1
    SET EXACT OFF
    IF mprice = "Y"
        nl++
        @ nl, 66 SAY nequtrade1 + ( nequtrade1 * ncostadd ) PICTURE "$9999,999.99"
    ENDIF
    IF mwhere = "P"
        @ nl, 0 SAY " "
        EndPrint()
        SET MARGIN TO 0
    ELSE
        IF nl > 20
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN mmodcode

// **---- End of EquPart()

// *-------------------------------------------------------------------

FUNCTION EquDesc( cequId )

    Scroll()
    DispBox(  0, 1, 2, 79, 2 )
    @  1, 10 SAY "Edit or Add Module"
    // **   mok := ApGetN( "Select by Module ID" )
    mok := "Y"
    aPart_ := {}
    nrecno   := 0
    mmodcode := Space( 16 )
    cequId := mfind := Space( 12 )
    IF mok = "Y"
        SELECT EquDesc
        SET ORDER TO 2                   // EquId
        Scroll( 3, 0, MaxRow(), MaxCol() )
        IF LastRec() != 0
            GOTO TOP
            DO WHILE EquDesc->( !Eof() )
                DO WHILE EquDesc->EquId = mfind
                    SKIP ALIAS EquDesc
                    LOOP
                ENDDO
                AAdd( aPart_, EquDesc->EquId + "   " + Str( RecNo(),6 ) )
                mfind := EquDesc->EquId
            ENDDO
            DispBox( 3, 1, 23, 21, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 4,  7, 22, 19, aPart_,, "AFUNC" )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                cequId   := EquDesc->EquId
                mmodcode := EquDesc->ModCode
            ENDIF
        ENDIF                        // Not Empty
    ENDIF                           // mok

    RETURN cequId

// **---- End of EquDesc()

// ---------------------------------------------------------------------*

FUNCTION EquSelect( cequId )

    SELECT EquDesc
    SET ORDER TO 2                       // EquId
    // **   cequId := EquDesc->EquId
    aPart_ := {}
    nrecno   := 0
    mmodcode := Space( 16 )
    Scroll( 3, 0, MaxRow(), MaxCol() )
    IF LastRec() != 0
        GOTO TOP
        IF cequId != Space( 12 )
            SEEK cequId
            DO WHILE EquDesc->EquId = cequId .AND. EquDesc->( !Eof() )
                AAdd( aPart_, EquDesc->ModCode + " " + SubStr( EquDesc->Desc,1,32 );
                    + " " + Str( EquDesc->Amount );
                    + " " + EquDesc->EquId + "     " + Str( RecNo(), 6 ) )
                SKIP ALIAS EquDesc
            ENDDO
            IF !Empty( aPart_ )
                DispBox( 3, 1, 24, 79, 2 )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice( 4, 3, 23, 77, aPart_,, "AFUNC" )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
                mmodcode := EquDesc->ModCode
            ENDIF
        ELSE
            mok := "Y"
            DO WHILE mok = "Y"
                aPart_ := {}
                nrecno   := 0
                SELECT EquDesc
                SET ORDER TO 1                    // ModCode
                GOTO TOP
                DO WHILE EquDesc->( !Eof() )
                    ntotwhol := 0
                    SELECT Equ
                    GOTO TOP
                    SEEK EquDesc->Modcode
                    DO WHILE Equ->Modcode = EquDesc->Modcode .AND. Equ->( !Eof() )
                        SELECT Part
                        SEEK Equ->Partnum
                        SELECT Equ
                        ntotwhol += ( Part->Wholesale * Equ->PartQty )
                        SKIP ALIAS Equ
                    ENDDO                       // EOF()
                    SELECT EquDesc
                    AAdd( aPart_, SubStr( EquDesc->ModCode, 1,15 );
                        + "  " + SubStr( EquDesc->Desc, 1, 27 );
                        + " " + Str( EquDesc->Amount );
                        + "         " + Str( ntotwhol, 10, 2 );
                        + "    " + Str( RecNo(), 6 ) )
                    SKIP ALIAS EquDesc
                ENDDO
                IF !Empty( aPart_ )
                    @ 24, 15 SAY "F2 or Esc to Edit Module" COLOR "+R"
                    DispBox( 3, 1, 23, 79, 2 )
                    @ 3, 53 SAY "  Sell  ----  Whole Cost "
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice( 4, 4, 22, 77, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    IF LastKey() = -1
                        EXIT
                    ENDIF
                    IF PressedEsc()
                        EXIT
                    ENDIF
                    GOTO nrecno
                    ApRLock( 3 )
                    @ Row(), 59 GET EquDesc->Amount
                    READ
                    UNLOCK
                    Scroll( 4, 61, 23, 78 )
                ENDIF
            ENDDO

        ENDIF
        DispBox( 3, 1, 24, 79, 2 )
        GOTO nrecno
        Scroll( 1, 6, 1, 74 )
        @  1, 7 SAY Trim( EquDesc->Modcode ) + "  " + Trim( EquDesc->Desc );
            + "  $" + Str( EquDesc->Amount ) COLOR c_hicolor
    ENDIF
    morig := mmodcode := moldmodcode := EquDesc->Modcode
    Scroll(  10, 0, 24, 80 )
    DispBox( 10, 1, 19, 79, 2 )
    // ***    SELECT EquDesc
    // ***   SET ORDER TO 1                   // ModCode
    ntotwhol := 0
    SELECT Equ
    GOTO TOP
    SEEK EquDesc->Modcode
    DO WHILE Equ->Modcode = EquDesc->Modcode .AND. Equ->( !Eof() )
        SELECT Part
        SEEK Equ->Partnum
        SELECT Equ
        ntotwhol += ( Part->Wholesale * Equ->PartQty )
        SKIP ALIAS Equ
    ENDDO                       // EOF()

    RETURN cequId

// **---- End of EquSelect()

// ****-------------- End of File XLF_Equ3.PRG
