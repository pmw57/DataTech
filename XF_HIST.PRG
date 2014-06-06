// **  JK  14-03-10 16:13:48

/*
   Program.....:                  XF_HIST.PRG
   Authors.....: J.Kirby, P.Wilkins
   Date........:  6/10/1998
   Functions...: HistName, Mu_Hist, SuplHist, NameSale
                 HistPart
   Static funcs: QOName, QOrdName, PartSale, NameSaleHd
   Not used....: HistList, HistLsthd, HistSerno, SernoEdit
*/

// (c) Copyright 1993 by Chozen Ltd Christchurch.

STATIC FUNCTION QOName( mcodeno )

    Scroll()
    dstmm    := Date() -30
    dendmm   := Date()
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        DispBox( 6, 1, 12, 79, 2 )
        @  8, 10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
        @ 10, 10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
        READ

        NameRank( mcodeno )

        IF PressedEsc()
            RETURN NIL
        ENDIF
        mmemo := "N"
        SELECT Name
        mcodeno := Name->Codeno
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 15 SAY Name->Name
        nrecno := 0
        cbranchId := Space( 2 )
        mok := "N"
        SELECT Branch
        SEEK mcodeno
        IF Found()

            BranchFind( @mcodeno )             // ZSF_Name
            cbranchId := Branch->BranchId

            mok := ApGetN( "Do you Want Branch" )
            IF mok = "N"
                cbranchId := Space( 2 )
            ENDIF
        ENDIF
        mpartnum := Space( 20 )
        mselect := "N"
        mselect := ApGetN( "Do you Want Part" )
        IF mselect = "Y"
            mcodeno := Name->Codeno
            PartFind( @mpartnum, mcodeno )

        ENDIF
        Scroll( 0, 1, 2, 79 )
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 15 SAY Name->Name
        mwhere := "S"

        Printsel( mwhere )                    // _LF_Init

        IF mwhere = "P"
            npl := 54
        ELSE
            npl := 22
        ENDIF
        nl := 4
        IF mwhere = "P"
            @  0, 0 SAY Control->U_Name
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  2, 10 SAY "From " + DToC( dstmm )
            @  2, 32 SAY "To "   + DToC( dendmm )
            @  3, 57 SAY "Supplied"
            @  3, 71 SAY "Ordered"
        ELSE
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @ 1, 15 SAY Trim( Name->Name )
            @ 1, Col() + 2  SAY "From " + DToC( dstmm )
            @ 1, Col() + 2  SAY "To "   + DToC( dendmm )
            @ 3, 57 SAY "Supplied"
            @ 3, 71 SAY "Ordered"
        ENDIF
        aPart_ := {}
        SELECT QuotOrd
        SET ORDER TO 1
        IF LastRec() != 0
            SEEK mcodeno
            DO WHILE QuotOrd->Codeno = mcodeno .AND. QuotOrd->( !Eof() )
                IF mok = "Y"
                    IF QuotOrd->BranchId != cbranchId
                        SKIP ALIAS QuotOrd
                        LOOP
                    ENDIF
                ENDIF
                IF QuotOrd->DBDate < dstmm
                    SKIP ALIAS QuotOrd
                    LOOP
                ENDIF
                IF QuotOrd->DBDate > dendmm
                    SKIP ALIAS QuotOrd
                    LOOP
                ENDIF
                IF mselect = "Y"
                    IF QuotOrd->Partnum != mpartnum
                        SKIP ALIAS QuotOrd
                        LOOP
                    ENDIF
                ENDIF
                mpartnum := QuotOrd->Partnum
                SELECT Part
                SEEK mpartnum
                ApRLock( 3 )
                mdesc := SubStr( Part->Desc, 1, 15 )
                UNLOCK
                SELECT QuotOrd
                IF nl > npl
                    IF mwhere = "S"
                        Inkey( 0 )
                        Scroll()
                    ELSE
                        EJECT
                    ENDIF
                    @  0, 0 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  2, 10 SAY "From " + DToC( dstmm )
                    @  2, 32 SAY "To "   + DToC( dendmm )
                    @  3, 57 SAY "Supplied"
                    @  3, 71 SAY "Ordered"
                    nl := 4
                ENDIF                      // nl
                SELECT QuotOrd
                @ nl, 0 SAY SubStr( QuotOrd->Partnum, 1, 8 )
                @ nl, 10 SAY mdesc
                @ nl, 26 SAY QuotOrd->DBDate
                @ nl, 37 SAY SubStr( QuotOrd->Ordnum, 1, 13 )
                @ nl, 52 SAY QuotOrd->Invno
                IF QuotOrd->Qty > 0
                    @ nl, 59 SAY QuotOrd->Qty PICTURE "99,999.99"
                ENDIF
                IF QuotOrd->OrdQty > 0
                    @ nl, 69 SAY QuotOrd->OrdQty PICTURE "99,999.99"
                ENDIF
                nl++
                SKIP ALIAS QuotOrd
            ENDDO                             // EOF
            nl += 2
        ENDIF                    // LastRec Not 0
        IF mwhere == "S"
            Inkey( 0 )
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
            SET MARGIN TO 0
        ENDIF
        mcontinue := ApGetY( Trim( Message->Another ) + " Name" )
    ENDDO

    RETURN NIL
// ***---- End of QOName()

// ---------------------------------------------------------------------*

STATIC FUNCTION QOrdName()

    dstmm  := Date() -30
    dendmm := Date()
    Scroll()
    DispBox( 0, 1, 14, 79, 2 )
    @  1, 20 SAY "LISTING Orders  by   NAME"
    @  8, 5 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
    @ 10, 5 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
    READ
    IF PressedEsc()
        RETURN NIL
    ENDIF
    mwhere := "S"
    npl    := 0

    Printsel( mwhere )

    IF mwhere == "P"
        SET MARGIN TO 0
        npl := 54
    ELSE
        Scroll()
        npl := 22
    ENDIF

    nl := 0
    @  0, 0 SAY Control->U_Name
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 12 SAY "From " + DToC( dstmm ) + " To " + DToC( dendmm )
    @  2, 56 SAY "Supplied"
    @  2, 70 SAY "Ordered"
    nl := 3

    nsaletot := ngrandtot := ncost := 0
    SELECT QuotOrd
    GOTO TOP
    DO WHILE QuotOrd->( !Eof() )
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF                       // mwhere = P

            @  0, 0 SAY Control->U_Name
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  2, 12 SAY "From " + DToC( dstmm ) + " To " + DToC( dendmm )
            @  2, 56 SAY "Supplied"
            @  2, 70 SAY "Ordered"
            nl := 3
        ENDIF                          // nl>npl
        SELECT Name
        SEEK QuotOrd->Codeno
        SELECT QuotOrd
        mcodeno := QuotOrd->Codeno
        DO WHILE QuotOrd->Codeno = mcodeno .AND. QuotOrd->( !Eof() )
            IF QuotOrd->DbDate < dstmm
                SKIP ALIAS QuotOrd
                LOOP
            ENDIF
            IF QuotOrd->DbDate > dendmm
                SKIP ALIAS QuotOrd
                LOOP
            ENDIF
            @ nl, 0 SAY QuotOrd->DBDate
            @ nl, 12 SAY SubStr( QuotOrd->Partnum, 1, 10 )
            @ nl, 24 SAY SubStr( QuotOrd->Ordnum, 1, 10 )
            @ nl, 36 SAY QuotOrd->Codeno
            @ nl, 46 SAY QuotOrd->Invno
            IF QuotOrd->Qty > 0
                @ nl, 54 SAY QuotOrd->Qty
            ENDIF
            IF QuotOrd->OrdQty > 0
                @ nl, 68 SAY QuotOrd->OrdQty
            ENDIF
            nl++
            SKIP ALIAS QuotOrd
        ENDDO
    ENDDO
    nl++
    IF mwhere = "P"
        EndPrint()
        SET MARGIN TO 0
    ELSE
        WAIT
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN NIL

// ****** End of QOrdName()

// *---------------------------------------------------------------------*

FUNCTION HistName( mcodeno )

    Scroll()
    dstmm    := Date() -30
    dendmm   := Date()
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        DispBox( 6, 1, 12, 79, 2 )
        @  8, 10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
        @ 10, 10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
        READ
        // **   IF mcodeno = SPACE( 8 )

        NameRank( mcodeno )

        IF PressedEsc()
            RETURN NIL
        ENDIF
        // **   ENDIF                // mcodeno
        mmemo := "N"
        // **   mmemo := ApGetN( "Do You Want Text Print" )
        SELECT Name
        mcodeno := Name->Codeno
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 15 SAY Name->Name
        nrecno := 0
        cbranchId := Space( 2 )
        mok := "N"
        SELECT Branch
        SEEK mcodeno
        IF Found()

            BranchFind( @mcodeno )             // ZSF_Name

            cbranchId := Branch->BranchId

            mok := ApGetY( "Do you Want Branch" )
            IF mok = "N"
                cbranchId := Space( 2 )
            ENDIF
        ENDIF
        mpartnum := Space( 20 )
        mselect := "N"
        mselect := ApGetN( "Do you Want Part" )
        IF mselect = "Y"
            mcodeno := Name->Codeno
            PartFind( @mpartnum, mcodeno )

        ENDIF
        Scroll( 0, 1, 2, 79 )
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 15 SAY Name->Name
        // **    SCROLL(  3, 0, 24,80 )
        // **    DISPBOX( 3, 1, 18,79, 2 )

        mwhere := "S"

        Printsel( mwhere )                    // _LF_Init

        IF mwhere = "P"
            npl := 54
        ELSE
            npl := 22
        ENDIF
        nl := 4
        IF mwhere = "P"
            @  0, 0 SAY Control->U_Name
            @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  2, 10 SAY "From " + DToC( dstmm )
            @  2, 32 SAY "To "   + DToC( dendmm )
        ELSE
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @ 1, 15 SAY Trim( Name->Name )
            @ 1, Col() + 2 SAY "From " + DToC( dstmm )
            @ 1, Col() + 2 SAY "To "   + DToC( dendmm )
        ENDIF
        aPart_ := {}
        ntotal := ntotqty := 0
        SELECT Hist
        SET ORDER TO 1
        IF LastRec() != 0
            SEEK mcodeno
            DO WHILE Hist->Codeno = mcodeno .AND. Hist->( !Eof() )
                IF mok = "Y"
                    IF Hist->BranchId != cbranchId
                        SKIP ALIAS Hist
                        LOOP
                    ENDIF
                ENDIF
                IF SubStr( Hist->Partnum, 1, 4 ) = "FREI"
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                IF Hist->PDate < dstmm
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                IF Hist->PDate > dendmm
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                IF mselect = "Y"
                    IF Hist->Partnum != mpartnum
                        SKIP ALIAS Hist
                        LOOP
                    ENDIF
                ENDIF
                mpartnum := Hist->Partnum
                SELECT Part
                SEEK mpartnum
                ApRLock( 3 )
                mdesc := SubStr( Part->Desc, 1, 16 )
                UNLOCK
                SELECT Hist
                ntotal  += ( Hist->Amount * Hist->Qty )
                ntotqty += Hist->Qty
                IF Hist->Amount != Hist->Wholesale
                    ndif := Str( Hist->Wholesale )
                ELSE
                    ndif := Space( 10 )
                ENDIF
                IF nl > npl
                    IF mwhere = "S"
                        Inkey( 0 )
                        Scroll()
                    ELSE
                        EJECT
                    ENDIF
                    @  0, 0 SAY Control->U_Name
                    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                        + Str( Year( Date() ), 5 )
                    @  2, 10 SAY "From " + DToC( dstmm )
                    @  2, 32 SAY "To "   + DToC( dendmm )
                    nl := 4
                ENDIF                      // nl
            /*
            IF mmemo = "Y"
               SELECT CusNotes
               cdetail := ""
               coderef := Hist->Partnum
               SEEK coderef
               Getdets( coderef )                           // XF_Memo2
               FormP( cdetail,60,10 )                       // XF_Memo2
            ENDIF                                            // Memo Print
            */
                SELECT Hist
                @ nl, 0 SAY SubStr( Hist->Partnum, 1, 8 ) + " " + mdesc;
                    + " " + Str( Hist->Qty, 9, 2  );
                    + " " + Str( Hist->Amount, 9, 2 ) + " " + DToC( PDate );
                    + " " + Hist->BranchId + " " + Hist->Invno;
                    + " " + Hist->Est
                nl++
                SKIP ALIAS Hist
            ENDDO                             // EOF
            nl += 2
            @ nl, 10 SAY "Total Amount "
            @ nl, 25 SAY ntotal PICTURE "$999,999.99"
            @ nl, 40 SAY "Total Qty"
            @ nl, 52 SAY ntotQty PICTURE "99,999.99"
        ENDIF                    // LastRec Not 0
        IF mwhere == "S"
            Inkey( 0 )
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
            SET MARGIN TO 0
        ENDIF
        mcontinue := ApGetY( Trim( Message->Another ) + " Name" )
    ENDDO

    RETURN NIL
// ***---- End of HistName()

// ---------------------------------------------------------------------*

FUNCTION Mu_Hist()

    DO WHILE .T.

        nselect  := 0
        nc       := ncl * 2
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( Menu->CH_HistHd ) ) / 2 );
            SAY RTrim( Menu->CH_HistHd )
        @  7, nc + 2 PROMPT Menu->CH_Hist1
        @  9, nc + 2 PROMPT Menu->CH_Hist2
        @ 11, nc + 2 PROMPT "3. Part        Sales"
        @ 13, nc + 2 PROMPT "4. Hist File    Edit"
        @ 15, nc + 2 PROMPT "5. Customer Orders  "
        @ 17, nc + 2 PROMPT "6. Name     Orders  "
        @ 20, nc + 2 PROMPT Menu->CH_Main

        nc := ncl
        MENU TO nselect

        DO CASE
        CASE nselect == 7 .OR. PressedEsc()
            EXIT
            RETURN NIL
        CASE nselect == 1
            SAVE SCREEN TO Invscrn
            mcodeno := Space( 8 )
            HistName( mcodeno )                             // Below
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 2
            SAVE SCREEN TO Invscrn
            mpartnum := Space( 20 )
            HistPart( mpartnum )                   // Below
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 3
            SAVE SCREEN TO Invscrn
            PartSale()                              // Below
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 4
            SAVE SCREEN TO Invscrn
            DebHistEd()                             // XLF_Deb
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 5
            SAVE SCREEN TO Invscrn
            QOrdName()                               //
            RESTORE SCREEN FROM Invscrn
        CASE nselect == 6
            SAVE SCREEN TO Invscrn
            mcodeno := Space( 8 )
            QOName( mcodeno )                      // Below
            RESTORE SCREEN FROM Invscrn
        ENDCASE
    ENDDO

    RETURN NIL

// **** End of Mu-Hist

// *---------------------------------------------------------------------*

FUNCTION SuplHist()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"

        ncost := 0
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 10 SAY "Select Suppliers Details"
        DispBox( 6, 10, 16, 60 )
        nselect := 1
        @  8, 20 PROMPT "1. Select   by  Name"
        @ 10, 20 PROMPT "2. Select   by  Part"
        @ 12, 20 PROMPT "3. All Name  Amounts"
        @ 14, 20 PROMPT "4. All Supplies List"
        MENU TO nselect
        DO CASE
        CASE nselect == 5 .OR. PressedEsc()
            RETURN NIL
            // Selected all Supplies

        CASE nselect == 4

            SELECT ProfNat
            SET ORDER TO 1
            // **    ApFLock( 3 )
            // **   INDEX ON ProfNat->PackNo+ProfNat->Partnum TO TempIPN
            // **    SET INDEX TO TempIPN
            // **   UNLOCK
            GOTO TOP
            dstmm    := Date() -30
            dendmm   := Date()
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @  1, 15 SAY "All Supplies List"
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 1, 18, 79, 2 )
            @  8, 10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
            @ 10, 10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
            READ
            mwhere := "S"

            Printsel( mwhere )                    // _LF_Init

            IF mwhere = "P"
                npl := 54
            ELSE
                npl := 18
            ENDIF
            nl := 6
            IF mwhere = "P"
                @  0, 0 SAY Control->U_Name
                @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + Str( Year( Date() ), 5 )
                @  2, 10 SAY "From " + DToC( dstmm )
                @  2, 32 SAY "To "   + DToC( dendmm )
                @  4, 0 SAY "Codeno  Desc                                      Qty      Amount"
            ELSE
                Scroll()
                DispBox( 0, 1, 2, 79, 2 )
                @ 1, 6      SAY Trim( Control->U_Name )
                @ 1, Col() + 2 SAY "From " + DToC( dstmm )
                @ 1, Col() + 1 SAY "To "   + DToC( dendmm )
                @ 3, 0 SAY "Codeno     Desc                                     Qty      Amount"
                nl := 4
            ENDIF
            aPart_ := {}
            ntotal := ntotqty := ncost := 0
            SELECT ProfNat
            IF LastRec() != 0
                DO WHILE ProfNat->( !Eof() )
                    IF ProfNat->PDate < dstmm
                        SKIP ALIAS ProfNat
                        LOOP
                    ENDIF
                    IF ProfNat->PDate > dendmm
                        SKIP ALIAS ProfNat
                        LOOP
                    ENDIF
                    mpartnum := ProfNat->Partnum
                    SELECT Part
                    SEEK mpartnum
                    ApRLock( 3 )
                    UNLOCK
                    SELECT ProfNat
                    ncost  := ProfNat->Cost * ( 1 -( ProfNat->Discount / 100 ) )
                    ntotal += ncost * ProfNat->Qty
                    // **         ntotqty += ProfNat->Qty
                    IF nl > npl
                        IF mwhere = "S"
                            Inkey( 0 )
                            Scroll()
                        ELSE
                            EJECT
                        ENDIF
                        @  0, 0 SAY Control->U_Name
                        @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                            + Str( Year( Date() ), 5 )
                        @  2, 10 SAY "From " + DToC( dstmm )
                        @  2, 32 SAY "To "   + DToC( dendmm )
                        @  4, 0 SAY "Codeno Desc                                       Qty      Amount"
                        nl := 6
                    ENDIF                      // nl
                    SELECT ProfNat
                    namount := ncost * ProfNat->Qty
                    @ nl, 0 SAY ProfNat->Codeno + " " + SubStr( Part->Desc, 1, 30 );
                        + " " + Str( ProfNat->Qty, 11, 2 );
                        + " " + Str( namount, 11, 2 ) + " " + DToC( PDate ) + " " + ProfNat->Ordnum
                    nl++
                    SKIP ALIAS ProfNat
                ENDDO                             // EOF
                nl++
                @ nl, 10 SAY "Total Amount "
                @ nl, 25 SAY ntotal PICTURE "$9,999,999.99"
                nl++
            ENDIF                    // LastRec Not 0
            IF mwhere == "S"
                nl += 2
                IF nl > 17
                    WAIT
                ENDIF
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ELSE
                EndPrint()
                SET MARGIN TO 0
            ENDIF
            // ***    SET INDEX TO ProfNatI

            // Selected all Names

        CASE nselect == 3
            SELECT ProfNat
            SET ORDER TO 1
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
                dstmm    := Date() -30
                dendmm   := Date()
                Scroll(   3, 0, 24, 80 )
                DispBox(  8, 1, 14, 79, 2 )
                @ 10, 10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
                @ 12, 10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
                READ
                mpartnum := Space( 20 )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                Scroll()
                DispBox( 0, 1, 2, 79, 2 )
                @  1, 12 SAY "From   " + DToC( dstmm ) + "   up to   " + DToC( dendmm )
                aPart_ := {}
                ntotal := ngrandtot := 0
                SELECT ProfNat
                GOTO TOP
                mcodeno := ProfNat->Codeno
                IF LastRec() != 0
                    DO WHILE ProfNat->( !Eof() )
                        IF ProfNat->PDate < dstmm
                            SKIP ALIAS ProfNat
                            LOOP
                        ENDIF
                        IF ProfNat->PDate > dendmm
                            SKIP ALIAS ProfNat
                            LOOP
                        ENDIF
                        DO WHILE ProfNat->Codeno = mcodeno .AND. ProfNat->( !Eof() )
                            IF ProfNat->PDate < dstmm
                                SKIP ALIAS ProfNat
                                LOOP
                            ENDIF
                            IF ProfNat->PDate > dendmm
                                SKIP ALIAS ProfNat
                                LOOP
                            ENDIF
                            ncost  := ProfNat->Cost * ( 1 -( ProfNat->Discount / 100 ) )
                            ntotal += ncost * ProfNat->Qty
                            SKIP ALIAS ProfNat
                        ENDDO                       // mcodeno
                        SELECT Name
                        SEEK mcodeno
                        SELECT ProfNat
                        mcodeno := ProfNat->Codeno
                        IF ntotal = 0
                            LOOP
                        ENDIF
                        AAdd( aPart_, Name->Name + "    " + Str( ntotal,12, 2 ) )
                        ngrandtot += ntotal
                        ntotal  := 0
                        LOOP
                    ENDDO                             // EOF
                    IF !Empty( aPart_ )
                        ASort( aPart_,,, {| x, y | x < y } )
                        Scroll(  3, 0, 24, 80 )
                        DispBox( 3, 1, 22, 79, 2 )
                        @ 23, 2 SAY "From " + DToC( dstmm ) + " to " + DToC( dendmm )
                        @ 23, 35 SAY "Total Amount"
                        @ 23, 52 SAY ngrandtot PICTURE "$9,999,999.99"
                        anum := AChoice( 4, 12, 21, 58, aPart_,, "AFUNC" )
                    ENDIF
                ENDIF                    // LastRec Not 0
                mcontinue := "N"

            ENDDO                                       // mcontinue

            // Selected by Name

        CASE nselect == 1
            mcodeno := Space( 8 )

            NameRank( mcodeno )

            mcodeno := Name->Codeno
            IF PressedEsc()
                RETURN NIL
            ENDIF
            SELECT ProfNat
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
                Scroll()
                DispBox( 0, 1, 2, 79, 2 )
                @  1, 10 SAY Name->Name
                dstmm    := Date() -30
                dendmm   := Date()
                Scroll( 3, 0, 24, 80 )
                @  8, 10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
                @ 10, 10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
                READ
                mpartnum := Space( 20 )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                Scroll( 3, 0, 24, 80 )
                aPart_ := {}
                ntotal := ntotqty := 0
                SELECT ProfNat
                GOTO TOP
                IF LastRec() != 0
                    SEEK mcodeno
                    IF Found()
                        DO WHILE ProfNat->Codeno == mcodeno .AND. ProfNat->( !Eof() )
                            IF ProfNat->PDate < dstmm
                                SKIP ALIAS ProfNat
                                LOOP
                            ENDIF
                            IF ProfNat->PDate > dendmm
                                SKIP ALIAS ProfNat
                                LOOP
                            ENDIF
                            SELECT Part
                            SET ORDER TO 1
                            GOTO TOP
                            SEEK ProfNat->Partnum
                            SELECT ProfNat
                            ncost   := ProfNat->Cost * ( 1 -( ProfNat->Discount / 100 ) )
                            ntotal  += ncost * ProfNat->Qty
                            ntotqty += ProfNat->Qty
                            AAdd( aPart_, SubStr( Part->Desc, 1,32 ) + " " + Str( ProfNat->Qty, 7 );
                                + " " + Str( ProfNat->Cost, 11, 2 ) + " " + Str( ProfNat->Discount, 3 );
                                + " % " + DToC( ProfNat->PDate ) + " " + ProfNat->Ordnum )
                            SKIP ALIAS ProfNat
                        ENDDO                             // EOF
                        IF !Empty( aPart_ )
                            ASort( aPart_,,, {| x, y | x < y } )
                            Scroll(  3, 0, 24, 80 )
                            DispBox( 3, 1, 22, 79, 2 )
                            @ 23, 2 SAY "From " + DToC( dstmm ) + " to " + DToC( dendmm )
                            @ 23, 38 SAY "Total Amount"
                            @ 23, 52 SAY ntotal PICTURE "$9,999,999.99"
                            anum := AChoice( 4, 3, 21, 77, aPart_,, "AFUNC" )
                        ENDIF
                    ELSE
                        Scroll( 3, 0, 24, 80 )
                        @ 10, 10 SAY "No History"
                        WAIT
                    ENDIF
                ENDIF                    // LastRec Not 0
                mcontinue := "N"
            ENDDO

            // By Part Selection

        CASE nselect == 2
            SELECT ProfNat
            SET ORDER TO 2
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
                mpartnum := Space( 20 )
                Scroll()
                mcodeno := Name->Codeno

                PartFind( @mpartnum, mcodeno )                                       // XLF_Name

                mpartnum := Part->Partnum
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                Scroll()
                DispBox( 0, 1, 2, 79, 2 )
                @  1, 10 SAY Part->Partnum + " " + Part->Desc
                dstmm    := Date() -30
                dendmm   := Date()
                Scroll( 3, 0, 24, 80 )
                aPart_ := {}
                ntotal := ntotqty := 0
                SELECT ProfNat
                GOTO TOP
                IF LastRec() != 0
                    SEEK mpartnum
                    IF Found()
                        DO WHILE ProfNat->Partnum == mpartnum .AND. ProfNat->( !Eof() )
                            SELECT Name
                            SEEK ProfNat->Codeno
                            SELECT ProfNat
                            ncost   := ProfNat->Cost * ( 1 -( ProfNat->Discount / 100 ) )
                            ntotal  += ncost * ProfNat->Qty
                            ntotqty += ProfNat->Qty
                            AAdd( aPart_, Name->Name + " " + Str( ProfNat->Qty,8 );
                                + " " + Str( ProfNat->Cost ) + " " + Str( ProfNat->Discount );
                                + "  " + DToC( ProfNat->PDate ) )
                            SKIP ALIAS ProfNat
                        ENDDO                             // EOF
                        IF !Empty( aPart_ )
                            Scroll(  3, 0, 24, 80 )
                            DispBox( 3, 1, 22, 79, 2 )
                            @ 23, 10 SAY "Total Qty"
                            @ 23, 22 SAY ntotqty PICTURE "999,999"
                            @ 23, 38 SAY "Total Amount"
                            @ 23, 52 SAY ntotal PICTURE "$9,999,999.99"
                            ASort( aPart_,,, {| x, y | x < y } )
                            anum     := AChoice( 4, 6, 21, 74, aPart_,, "AFUNC" )
                        ENDIF
                    ELSE
                        Scroll( 3, 0, 24, 80 )
                        @ 10, 10 SAY "No History"
                        WAIT
                    ENDIF
                ENDIF                    // LastRec Not 0
                mcontinue := "N"
            ENDDO

        ENDCASE
        mcontinue := "Y"
    ENDDO
    SELECT ProfNat
    SET ORDER TO 1

    RETURN NIL
// ***---- End of SuplHist()

// ---------------------------------------------------------------------*

STATIC FUNCTION PartSale()

    dstmm  := Date() -30
    dendmm := Date()
    nsale := nsaletot := 0
    Scroll()
    DispBox( 0, 1, 14, 79, 2 )
    @  1, 20 SAY "LIST  by  PARTS"
    @  8, 5 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
    @ 10, 5 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
    READ
    cequ := ApGetN( "Y = All Parts N = Modules" )
    IF PressedEsc()
        RETURN NIL
    ENDIF
    mwhere := "S"

    Printsel( mwhere )

    IF mwhere == "P"
        npl := 54
    ELSE
        Scroll()
        npl := 22
    ENDIF
    @  0, 0 SAY Control->U_Name
    @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 0 SAY "Part Used"
    @  2, 12 SAY "From " + DToC( dstmm ) + " Total up to " + DToC( dendmm )
    @  2, 70 SAY "Total Used"
    nl := 3
    mpartnum := Space( 20 )
    SELECT Hist
    SET ORDER TO 2                      // Partnum, Codeno
    SELECT Part
    SET ORDER TO 1                      // Partnum+Desc      PartId+Desc
    GOTO TOP
    DO WHILE Part->( !Eof() )
        IF nl > npl
            IF mwhere = "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF                       // mwhere = P
            @  0, 0 SAY Control->U_Name
            @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            @  2, 0 SAY "Part Used"
            @  2, 12 SAY "From " + DToC( dstmm ) + " Total up to " + DToC( dendmm )
            @  2, 70 SAY "Total Used"
            nl := 3
        ENDIF                          // nl>npl
        mpartnum := Part->Partnum
        SELECT Hist
        IF cequ = "N"
            SELECT Equ
            SET EXACT ON
            SEEK Trim( Part->Partnum )
            SET EXACT OFF
            IF !Found()
                SELECT Part
                SKIP ALIAS Part
                LOOP
            ENDIF
        ENDIF
        nsale := nsaletot := 0
        SELECT Hist
        SEEK mpartnum
        DO WHILE Hist->Partnum == mpartnum .AND. Hist->( !Eof() )
            nsaletot += Hist->Qty
            IF Hist->PDate < dstmm
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF Hist->PDate > dendmm
                SKIP ALIAS Hist
                LOOP
            ENDIF
            nsale += Hist->Qty
            SKIP ALIAS Hist
        ENDDO
        IF nsaletot > 0
            @ nl, 0 SAY nsale    PICTURE "9,999,999"
            @ nl, 12 SAY mpartnum
            @ nl, 34 SAY SubStr( Part->Desc, 1, 35 )
            @ nl, 70 SAY nsaletot PICTURE "9,999,999"
            nl++
        ENDIF
        SELECT Part
        SKIP ALIAS Part
    ENDDO
    nl += 2
    IF mwhere = "P"
        EndPrint()
    ELSE
        WAIT
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN NIL

// ****** End of PartSale()

// **---------------------------------------------------------------------

FUNCTION NameSale()

    dstmm  := Date() -30
    dendmm := Date()
    Scroll()
    DispBox( 0, 1, 14, 79, 2 )
    @  1, 20 SAY "LISTING  by   NAME"
    @  8, 5 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
    @ 10, 5 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
    READ
    IF PressedEsc()
        RETURN NIL
    ENDIF
    mwhere := "S"
    npl    := 0

    Printsel( mwhere )

    IF mwhere == "P"
        SET MARGIN TO 0
        npl := 54
    ELSE
        Scroll()
        npl := 22
    ENDIF

    nl := 0
    nl := NameSalehd( dstmm, dendmm )                 // Below

    nsaletot := ngrandtot := ncost := 0
    SELECT DebProf
    GOTO TOP
    ApFLock( 3 )
    INDEX ON Codeno TO TempIDPR
    SET INDEX TO TempIDPR
    UNLOCK
    GOTO TOP
    DO WHILE DebProf->( !Eof() )
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF                       // mwhere = P

            nl := NameSalehd( dstmm, dendmm )             // Below

        ENDIF                          // nl>npl
        SELECT Name
        SEEK DebProf->Codeno
        SELECT DebProf
        mcodeno := DebProf->Codeno
        nsale   := nsalegrand := 0
        DO WHILE Debprof->Codeno = mcodeno .AND. DebProf->( !Eof() )
            nsalegrand += DebProf->Amount
            IF DebProf->DbDate < dstmm
                SKIP ALIAS DebProf
                LOOP
            ENDIF
            IF DebProf->DbDate > dendmm
                SKIP ALIAS DebProf
                LOOP
            ENDIF
            nsale    += DebProf->Amount
            nsaletot += DebProf->Amount
            ncost    += DebProf->CostItem
            SKIP ALIAS DebProf
        ENDDO
        IF nsalegrand > 0
            @ nl, 0 SAY Name->Name
            @ nl, 32 SAY nsale               PICTURE "999,999.99"
            @ nl, 44 SAY ncost               PICTURE "999,999.99"
            @ nl, 56 SAY ( ncost / nsale ) * 100 PICTURE "9999 %"
            @ nl, 65 SAY nsalegrand          PICTURE "9,999,999.99"
            nl++
        ENDIF
        ngrandtot  += nsalegrand
        nsalegrand := ncost := 0
    ENDDO
    @ nl, 29 SAY Replicate( "-", 14 )
    @ nl, 63 SAY Replicate( "-", 14 )
    nl++
    @ nl, 29 SAY nsaletot  PICTURE "$9,999,999.99"
    @ nl, 63 SAY ngrandtot PICTURE "$99,999,999.99"
    nl++
    @ nl, 29 SAY Replicate( "=", 14 )
    @ nl, 63 SAY Replicate( "=", 14 )
    nl += 2
    IF mwhere = "P"
        EndPrint()
        SET MARGIN TO 0
    ELSE
        WAIT
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    SELECT DebProf
    SET INDEX TO DebProfI

    RETURN NIL

// ****** End of NameSale()

// *---------------------------------------------------------------------*

STATIC FUNCTION NameSaleHd( dstmm, dendmm )

    @  0, 0 SAY Control->U_Name
    @  0, 58 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 12 SAY "From " + DToC( dstmm ) + " To " + DToC( dendmm )
    @  2, 50 SAY "Cost"
    @  2, 68 SAY "Grand Total"
    nl := 3

    RETURN nl

// ---------------------------------------------------------------------*

FUNCTION HistPart( mpartnum )

    Scroll()
    dstmm    := Date() -30
    dendmm   := Date()
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        DispBox( 6, 1, 12, 79, 2 )
        @  8, 10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
        @ 10, 10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
        READ
        IF  mpartnum = Space( 20 )
            Scroll()
            mcodeno := Space( 8 )
            PartFind( @mpartnum, mcodeno )                                       // XLF_Name
            IF PressedEsc()
                RETURN NIL
            ENDIF
            mpartnum := Part->Partnum
        ENDIF
        aPart_ := {}
        ntotal := ntotqty := 0
        nmonth1 := nmonth2 := nmonth3 := nmonth4 := nmonth5 := nmonth6 := 0
        nmonth7 := nmonth8 := nmonth9 := nmonth10 := nmonth11 := nmonth12 := 0
        SELECT Hist
        SET ORDER TO 2
        GOTO TOP
        IF LastRec() != 0
            SEEK mpartnum
            IF Found()
                DO WHILE Hist->Partnum == mpartnum .AND. Hist->( !Eof() )
                    IF Year( Hist->Pdate ) = Year( dendmm )
                        DO CASE
                        CASE Month( Hist->Pdate ) = 1
                            nmonth1 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 2
                            nmonth2 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 3
                            nmonth3 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 4
                            nmonth4 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 5
                            nmonth5 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 6
                            nmonth6 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 7
                            nmonth7 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 8
                            nmonth8 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 9
                            nmonth9 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 10
                            nmonth10 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 11
                            nmonth11 += Hist->Qty
                        CASE Month( Hist->Pdate ) = 12
                            nmonth12 += Hist->Qty
                        ENDCASE
                    ENDIF                    // YEAR
                    IF Hist->PDate < dstmm
                        SKIP ALIAS Hist
                        LOOP
                    ENDIF
                    IF Hist->PDate > dendmm
                        SKIP ALIAS Hist
                        LOOP
                    ENDIF
                    SELECT Name
                    SEEK Hist->Codeno
                    ApRLock( 3 )
                    // **            SCROLL()
                    UNLOCK
                    SELECT Hist
                    ntotal  += Hist->Amount * Hist->Qty
                    ntotqty += Hist->Qty
                    AAdd( aPart_, Name->Name + " " + Hist->BranchId + " " + Str( Hist->Qty,8 );
                        + " " + Str( Hist->Amount ) + "  " + DToC( Hist->PDate ) )
                    SKIP ALIAS Hist
                ENDDO                             // EOF
                IF !Empty( aPart_ )
                    Scroll(  3, 0, 24, 80 )
                    DispBox( 3, 1, 22, 69, 2 )
                    @  0, 70 SAY "           "
                    @  0, 73 SAY Year( dendmm )
                    SELECT Months
                    GOTO 12
                    @  1, 70 SAY "           "
                    @  1, 71 SAY Months->Brief + Str( Year( dendmm ) )
                    @  2, 70 SAY "           "
                    @  2, 74 SAY nmonth1 PICTURE "9,999" COLOR "BG+"
                    GOTO 11
                    @  3, 71 SAY Months->Brief + Str( Year( dendmm ) )
                    @  4, 74 SAY nmonth2 PICTURE "9,999" COLOR "BG+"
                    GOTO 10
                    @  5, 71 SAY Months->Brief + Str( Year( dendmm ) )
                    @  6, 74 SAY nmonth3 PICTURE "9,999" COLOR "BG+"
                    GOTO  9
                    @  7, 71 SAY Months->Brief + Str( Year( dendmm ) )
                    @  8, 74 SAY nmonth4 PICTURE "9,999" COLOR "BG+"
                    GOTO  8
                    @  9, 71 SAY Months->Brief + Str( Year( dendmm ) )
                    @ 10, 74 SAY nmonth5 PICTURE "9,999" COLOR "BG+"
                    GOTO  7
                    @ 11, 71 SAY Months->Brief + Str( Year( dendmm ) )
                    @ 12, 74 SAY nmonth6 PICTURE "9,999" COLOR "BG+"
                    GOTO  6
                    @ 13, 71 SAY Months->Brief + Str( Year( dendmm ) )
                    @ 14, 74 SAY nmonth7 PICTURE "9,999" COLOR "BG+"
                    GOTO  5
                    @ 15, 71 SAY Months->Brief + Str( Year( dendmm ) )
                    @ 16, 74 SAY nmonth8 PICTURE "9,999" COLOR "BG+"
                    GOTO  4
                    @ 17, 71 SAY Months->Brief + Str( Year( dendmm ) )
                    @ 18, 74 SAY nmonth9 PICTURE "9,999" COLOR "BG+"
                    GOTO  3
                    @ 19, 71 SAY Months->Brief + Str( Year( dendmm ) )
                    @ 20, 74 SAY nmonth10 PICTURE "9,999" COLOR "BG+"
                    GOTO  2
                    @ 21, 71 SAY Months->Brief + Str( Year( dendmm ) )
                    @ 22, 74 SAY nmonth11 PICTURE "9,999" COLOR "BG+"
                    GOTO  1
                    @ 23, 71 SAY Months->Brief + Str( Year( dendmm ) )
                    @ 24, 74 SAY nmonth12 PICTURE "9,999" COLOR "BG+"

                    @ 23, 0 SAY dstmm
                    @ 23, 12 SAY dendmm
                    @ 23, 24 SAY " Total Qty" + Str( ntotqty, 10, 2 ) + " Total $";
                        + Str( ntotal, 12, 2 )
                    Scroll(  0, 0, 2, 69 )
                    DispBox( 0, 1, 2, 69, 2 )
                    @  1, 6 SAY Trim( Part->Partnum ) + "  " + Part->Desc
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum     := AChoice( 4, 3, 21, 67, aPart_,, "AFUNC" )
                ENDIF
            ELSE
                Scroll( 3, 0, 24, 80 )
                @ 10, 10 SAY "No History"
                Inkey( 0 )
            ENDIF
        ENDIF                    // LastRec Not 0
        mcontinue := ApGetY( Trim( Message->Another ) + " Part" )
        mpartnum  := Space( 20 )
    ENDDO

    RETURN mpartnum

// ***---- End of HistPart

// ---------------------------------------------------------------------*

FUNCTION HistList()

    npn := nl := 1
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        dstmm    := Date() -30
        dendmm   := Date()
        mpartnum := Space( 20 )
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @  1, 20 SAY "Parts or Serno Report"
        @  8, 10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
        @ 10, 10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
        READ

        mok := ApGetN( "Y = Parts  N = Serno" )
        IF mok = "Y"

            Scroll()
            npl    := 56
            mwhere := "S"

            Printsel( mwhere, npl )                        // _LF_Init

            HistLsthd()                                       // Below
            @ nl, 21 SAY "Description"
            @ nl, 55 SAY "Qty"
            @ nl, 66 SAY "Value"
            nl += 2
            SELECT Hist
            SET ORDER TO 2
            GOTO TOP
            DO WHILE  Hist->( !Eof() )
                SELECT Part
                SET ORDER TO 1
                SEEK Hist->Partnum
                IF !Found()
                    SELECT HIST
                    ApRLock( 3 )
                    DELETE
                    UNLOCK
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                IF Hist->PDate < dstmm
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                IF Hist->PDate > dendmm
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                    HistLsthd()                                       // Below
                    @ nl, 21 SAY "Description"
                    @ nl, 55 SAY "Qty"
                    @ nl, 66 SAY "Value"
                    nl += 2
                ENDIF
                @ nl, 0 SAY Hist->Partnum
                @ nl, 21 SAY SubStr( Part->Desc, 1, 30 )
                SELECT HIST
                mpartnum := Hist->Partnum
                ntotQty := ntotAmnt := 0
                DO WHILE Hist->Partnum = mpartnum .AND. Hist->( !Eof() )
                    ntotqty  += Hist->Qty
                    ntotAmnt += Hist->Amount
                    SKIP ALIAS Hist
                ENDDO                    // Partnum
                @ nl, 52 SAY ntotqty PICTURE "999,999"
                @ nl, 64 SAY ntotAmnt PICTURE "$999,999.99"
                nl++
                // **      SKIP ALIAS Hist
            ENDDO                             // EOF
            IF mwhere == "S"
                WAIT
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ELSE
                EndPrint()
                SET MARGIN TO 0
            ENDIF
        ELSE
            Scroll()
            npl    := 56
            mwhere := "S"

            Printsel( mwhere, npl )                        // _LF_Init

            HistLsthd()                                       // Below

            @ nl, 0 SAY "Part #"
            @ nl, 10 SAY "Serno"
            @ nl, 26 SAY "Name"
            nl += 2
            SELECT PartSer
            GOTO TOP
            DO WHILE PartSer->( !Eof() )
                IF PartSer->PDate < dstmm
                    SKIP ALIAS PartSer
                    LOOP
                ENDIF
                IF PartSer->PDate > dendmm
                    SKIP ALIAS PartSer
                    LOOP
                ENDIF
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF

                    HistLsthd()                                       // Below

                    @ nl, 0 SAY "Part #"
                    @ nl, 10 SAY "Serno"
                    @ nl, 26 SAY "Name"
                    nl += 2
                ENDIF
                @ nl, 0 SAY SubStr( PartSer->Partnum, 1, 9 )
                @ nl, 10 SAY PartSer->Serno
                SELECT Name
                SEEK PartSer->Codeno
                @ nl, 26 SAY SubStr( Name->Name, 1, 23 )
                @ nl, 50 SAY PartSer->Amount PICTURE "9999.99"
                @ nl, 58 SAY PartSer->PDate
                @ nl, 70 SAY PartSer->Invno
                nl++
                SELECT PartSer
                SKIP ALIAS PartSer
            ENDDO                             // EOF
            IF mwhere == "S"
                WAIT
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ELSE
                EndPrint()
                SET MARGIN TO 0
            ENDIF
        ENDIF
        mcontinue := ApGetN( Message->Another + " Print out :" )
    ENDDO

    RETURN NIL
// ***---- End of HistList()

// *-------------------------------------------------------------------

STATIC FUNCTION HistLsthd()

    nl := 1
    @  0, 0 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + " " + Str( Year( Date() ), 5 )
    @  0, 21 SAY Trim( Control->U_Name )
    @  0, 60 SAY "Page"
    @  0, 65 SAY npn PICTURE "999"
    nl += 2

    RETURN NIL

FUNCTION HistSerno()

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        cserno := Space( 15 )
        @  6, 10 SAY "Serial #" GET cserno PICTURE "@!"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        SELECT PartSer
        LOCATE FOR PartSer->Serno = cserno
        IF Found()
            @  8, 10 SAY PartSer->Serno
            @  8, 30 SAY PartSer->PDate
            @  8, 45 SAY PartSer->Amount PICTURE "$99,999.99"
            SELECT Part
            SEEK PartSer->Partnum
            @ 10, 10 SAY PartSer->Partnum + "  " + Part->Desc
            SELECT Name
            SEEK PartSer->Codeno
            @ 12, 10 SAY PartSer->Codeno + "  " + Name->Name
            @ 14, 45 SAY "Invoice # " + PartSer->Invno + " Branch " + PartSer->BranchId
        ELSE
            // BASE/1187 Bound if more than 4096 Records
            nrecno := 0
            aPart_ := {}
            ntotal := 0
            SELECT PartSer
            GOTO TOP
            IF LastRec() < 4000
                DO WHILE PartSer->( !Eof() )
                    SELECT Name
                    SEEK PartSer->Codeno
                    SELECT PartSer
                    AAdd( aPart_, PartSer->Serno;
                        + " " + Name->Name;
                        + " " + PartSer->BranchId;
                        + " " + PartSer->Invno;
                        + "  " + DToC( PartSer->PDate );
                        + " " + SubStr( PartSer->Partnum, 1, 6 );
                        + "      " + Str( RecNo(), 6  ) )
                    ntotal++
                    SKIP ALIAS PartSer
                ENDDO
                ASort( aPart_,,, {| y, x | y < x } )
                Scroll(  1, 38, 1, 74 )
                @ 1, 42 SAY "Total ="
                @ 1, 50 SAY ntotal PICTURE "999,999"
                Scroll(  3, 0, 24, 80 )
                DispBox( 3, 1, 24, 79, 2 )
                IF !Empty( aPart_ )
                    anum   := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                ENDIF
                GOTO nrecno
                Scroll(  3, 0, 24, 80 )
                DispBox( 3, 1, 24, 79, 2 )
                SELECT Part
                SEEK PartSer->Partnum
                @  6, 10 SAY Part->Partnum + " " + Part->Desc
                SELECT Name
                SEEK PartSer->Codeno
                @ 10, 10 SAY Name->Name
                SELECT PartSer
                ApRLock( 3 )
                @  8, 10      SAY "Serial #" GET PartSer->Serno    PICTURE "@X"
                @  8, Col() + 2 SAY "Part   #" GET PartSer->Partnum  PICTURE "@X"
                @ 12, 10      SAY "Code   #" GET PartSer->Codeno   PICTURE "@!"
                @ 12, Col() + 2 SAY "Branch"   GET PartSer->BranchId PICTURE "@!"
                @ 14, 10      SAY "Date   "  GET PartSer->PDate    PICTURE "99/99/9999"
                @ 14, Col() + 2 SAY "Invoice"  GET Partser->Invno    PICTURE "@X"
                @ 14, Col() + 2 SAY "Amount"   GET PartSer->Amount   PICTURE "999999.99"
                READ
                UNLOCK
            ELSE
                @ 12, 10 SAY "No Such Serno"
            ENDIF                       // < 4000
        ENDIF                         // FOUND
        mcontinue := ApGetY( Message->Another )
    ENDDO

    RETURN NIL

// **--------- End HistSerno

// *-------------------------------------------------------------------

FUNCTION SernoEdit()

    cheading  := "View Serial #"
    mcontinue := mdelete := mok := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        mpartnum := Space( 20 )

        PartFind( @mpartnum )                                       // XLF_Name

        IF PressedEsc()
            RETURN NIL
        ENDIF
        mpartnum := Part->Partnum
        Scroll( 3, 0, 24, 80 )
        DispBox(  4, 1, 14, 79, 2 )
        cserno := Space( 2 )
        @  6, 10 SAY "First 2 of Serno" GET cserno PICTURE "@!"
        @  6, Col() + 3 SAY "Blank = All for This Selection"
        READ
        // BASE/1187 Bound if more than 4096 Records
        nrecno := 0
        aPart_ := {}
        ntotal := 0
        SELECT PartSer
        IF LastRec() < 4000
            SEEK mpartnum
            DO WHILE ( PartSer->Partnum = mpartnum ) .AND. PartSer->( !Eof() )
                IF cserno != Space( 2 )
                    IF SubStr( PartSer->Serno, 1, 2 ) != cserno
                        SKIP ALIAS PartSer
                        LOOP
                    ENDIF
                ENDIF
                SELECT Name
                SEEK PartSer->Codeno
                SELECT PartSer
                AAdd( aPart_, PartSer->Serno;
                    + " " + Name->Name;
                    + " " + PartSer->Invno + " " + PartSer->BranchId;
                    + "  " + DToC( PartSer->PDate );
                    + " " + SubStr( PartSer->Partnum, 1, 6 ) + "  " + Str( RecNo(), 6  ) )
                ntotal++
                SKIP ALIAS PartSer
            ENDDO
            ASort( aPart_,,, {| y, x | y < x } )
            Scroll(  1, 38, 1, 74 )
            @ 1, 42 SAY "Total ="
            @ 1, 50 SAY ntotal PICTURE "999,999"
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 1, 24, 79, 2 )
            IF !Empty( aPart_ )
                anum   := AChoice( 4, 3, 23, 78, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
            ENDIF
        ENDIF
        Scroll( 3, 0, 24, 80 )
        DispBox(  4, 1, 18, 79, 2 )
        GOTO nrecno
        IF nrecno = 0
            cserno := Space( 15 )
            ApRLock( 3 )
            @  5, 10 SAY "Serial #"  GET cserno
            READ
            UNLOCK
            SELECT PartSer
            LOCATE FOR PartSer->Serno = cserno
            IF !Found()
                @ 7, 10 SAY "No Such Serial Number"
                Inkey( 2 )
                RETURN NIL
            ENDIF
        ENDIF
        @  6, 10 SAY Part->Partnum + " " + Part->Desc
        SELECT Name
        SEEK PartSer->Codeno
        @ 10, 10 SAY Name->Name
        SELECT PartSer
        ApRLock( 3 )
        @  8, 10      SAY "Serial #" GET PartSer->Serno    PICTURE "@X"
        @  8, Col() + 2 SAY "Part   #" GET PartSer->Partnum  PICTURE "@X"
        @ 12, 10      SAY "Code   #" GET PartSer->Codeno   PICTURE "@!"
        @ 12, Col() + 2 SAY "Branch"   GET PartSer->BranchId PICTURE "@!"
        @ 14, 10      SAY "Date   "  GET PartSer->PDate    PICTURE "99/99/9999"
        @ 14, Col() + 2 SAY "Invoice"  GET Partser->Invno    PICTURE "@X"
        @ 14, Col() + 2 SAY "Amount"   GET PartSer->Amount   PICTURE "999999.99"
        READ
        UNLOCK
        cstring := Trim( Message->Delete )
        mok := ApCheck( cstring )                        // AppX.PRG
        IF PressedEsc()
            RETURN NIL
        ENDIF
        IF mok == "Y"
            cstring := Trim( Message->SureDel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
                RETURN NIL
            ENDIF
        ENDIF
        IF mok == "Y"
            SELECT PartSer
            ApRLock( 3 )
            DELETE
            UNLOCK
        ENDIF
        mcontinue := ApGetN( Trim( Message->Another ) + " Serno" )
        IF PressedEsc()
            RETURN NIL
        ENDIF
    ENDDO

    RETURN NIL

// **--------- End SernoEdit()

// ********----------  END OF FILE XF_HIST.PRG
