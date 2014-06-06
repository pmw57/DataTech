// ** JK  03-04-11 14:24:00

/*
   Program.....:            XLF_DEB.PRG
   Author......: J Kirby
   Date........: 10/07/1985
   Functions.. : MU_Debt, DebProfEd, DebHistEd, DebprofLk
                 DebAdd
   Static funcs: HistAdd, SaleList, DebList, DebView
                 MUS_Debt, DebHistLk, DeblistH, DebDelete
                 SaleHead
*/

STATIC FUNCTION HistAdd()

    mcodeno := Space( 8 )
    Namerank( @mcodeno )                          // XLF_Name
    IF PressedEsc()
        RETURN NIL
    ENDIF
    SELECT Name
    mcodeno := Name->Codeno
    Scroll(  3, 0, 18, 80 )
    DispBox( 3, 1, 18, 79, 2 )
    nl := 4
    SELECT Hist
    ApRLock( 3 )
    APPEND BLANK
    Hist->Codeno := mcodeno
    @  nl, 10 SAY mcodeno + " History Date"  GET Hist->PDate PICTURE "99/99/9999"
    READ
    UNLOCK
    nl += 2
    @ nl, 15 SAY "Salebook :"
    IF Hist->Saleno == Space( 4 )
        Scroll( 13, 0, 24, 80 )

        SbLook( @msaleno )                  // XLF_ACC

    ELSE
        SELECT Hist
        ApRLock( 3 )
        @ nl, 10 SAY "     Salebook :" GET Hist->Saleno PICTURE "@K!"
        READ
        msaleno := Hist->Saleno
        UNLOCK
        SELECT SaleBook
        SEEK msaleno
        IF !Found()
            Scroll( 13, 0, 24, 80 )
            SbLook( @msaleno )                // XLF_Acc
        ENDIF
    ENDIF
    DispBox( 3, 1, 18, 79, 2 )
    @ nl, 10 SAY "Sale Book #  " + SaleBook->Saleno + "  " + Salebook->Sbname
    nl += 2
    SELECT Hist
    ApRLock( 3 )
    Hist->Saleno := SaleBook->Saleno
    @  nl, 10      SAY " Invno :"  GET Hist->Invno   PICTURE "@X"
    nl += 2
    @  nl, 10      SAY "Amount :"  GET Hist->Amount  PICTURE "9999999.99"
    @  nl, Col() + 2 SAY "Cost :"    GET Hist->Cost    PICTURE "9999999.99"
    @  nl, Col() + 2 SAY "Qty :"     GET Hist->Qty     PICTURE "99999.99"
    nl += 2
    @  nl, 10      SAY "U_Codeno :" GET Hist->U_Codeno PICTURE "@!"
    @  nl, Col() + 2 SAY "BranchId :" GET Hist->BranchId PICTURE "@!"
    nl++
    @  nl, 10      SAY "Partnum :" GET Hist->Partnum PICTURE "@!"
    @  nl, Col() + 2 SAY "Codeno :"  GET Hist->Codeno  PICTURE "@!"
    nl++
    @  nl, 10      SAY "Est Note"  GET Hist->Est     PICTURE "@!"
    @  nl, Col() + 2 SAY "Stat :"    GET Hist->STAT    PICTURE "!"
    nl++
    @  nl, 10      SAY "DocNo  :"  GET Hist->Docno   PICTURE "@!"
    READ
    UNLOCK

    RETURN NIL
// **------ End of HistAdd()

// *---------------------------------------------------------------------*

STATIC FUNCTION SaleList()

    nl       := 1
    mname    := Space( 30 )
    mcodeno  := mcodeind := Space( 8 )
    mdbdate  := Date()
    mamount  := mamntind := mrectot := mrecind := ninit := 0
    mwhere   := "S"
    mselect  := "A"
    Scroll()
    DispBox( 0, 1, 2, 79, 2 )
    @  1, 20 SAY "LIST DEBTORS/RECEIPTS"
    mstmm  := Date() -30
    mendmm := Date()
    @  8, 10 SAY Message->Frdate GET mstmm  PICTURE "99/99/9999"
    @ 10, 10 SAY Message->Todate GET mendmm PICTURE "99/99/9999"
    READ
    // @  6, 5 SAY "All Invoices or Outstanding Only ? A/O "
    // @  6,45 GET mselect PICTURE "@!"
    mcont := ApGetN( Trim( Message->Another ) + " Individual Name " )
    IF mcont = "Y"

        NameRank()                               // XLF_Name.PRG

        IF PressedEsc()
            RETURN NIL
        ENDIF
        mcode := Name->Codeno
    ENDIF                                   / mok = "Y"
    Scroll()
    msaleno := Space( 4 )
    @  6, 10 SAY Message->BLANK GET msaleno PICTURE "@K!"
    READ
    IF msaleno != Space( 4 )
        SELECT Salebook
        SEEK msaleno
        IF !Found()

            Sblook( @msaleno )                      // XLP_Acc.PRG

        ENDIF
        msaleno := Salebook->Saleno
        @  8, 10 SAY "Sale Book # " + SaleBook->Saleno + "  " + Salebook->Sbname
    ENDIF

    Printsel( mwhere )

    IF mwhere == "P"
        SET MARGIN TO 0
        npl := 54
        nl  := 2
    ELSE
        Scroll()
        npl := 20
        nl  := 0
    ENDIF

    nl := Salehead( nl )                          // Below

    SELECT Debit
    SET ORDER TO 2                    // Invno
    GOTO TOP
    mcodeind := Debit->Codeno
    DO WHILE Debit->( !Eof() )
        IF Debit->Dbdate < mstmm
            SKIP ALIAS Debit
            LOOP
        ENDIF
        IF Debit->Dbdate > mendmm
            SKIP ALIAS Debit
            LOOP
        ENDIF
        IF mcont = "Y"
            IF Debit->Codeno != mcode
                SKIP ALIAS Debit
                LOOP
            ENDIF
        ENDIF                                // mok
        IF msaleno != Space( 4 )
            IF Debit->Saleno != msaleno
                SKIP ALIAS Debit
                LOOP
            ENDIF
        ENDIF
        IF Debit->Amount == 0
            SKIP ALIAS Debit
            LOOP
        ENDIF
        IF mselect == "O"
            IF Amount == 0
                SKIP ALIAS Debit
                LOOP
            ENDIF
        ENDIF
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF                       // mwhere = P
            nl :=  SaleHead( nl )               // Below
        ENDIF                          // nl>npl
        mcodeno := Debit->Codeno
        minvno  := Debit->Invno
        SELECT Name
        SEEK mcodeno
        SELECT Rec
        mrecamnt := 0
        SEEK mcodeno
        DO WHILE Rec->Codeno = mcodeno .AND. Rec->( !Eof() )
            IF Rec->Invno = minvno
                mrecamnt += Rec->Recamnt
            ENDIF
            SKIP ALIAS Rec
        ENDDO
        mrectot  += mrecamnt
        mrecind  += mrecamnt
        SELECT Debit
        mamount  += Debit->Amount
        mamntind += Debit->Amount
        ninit    += Debit->InitAmnt
        IF Amount > 0
            @ nl, 0 SAY Debit->Invno
            @ nl, 8 SAY Debit->Dbdate
            @ nl, 19 SAY SubStr( Name->Name, 1, 23 )
            @ nl, 42 SAY Debit->InitAmnt PICTURE "9,999,999.99"
            @ nl, 55 SAY Debit->Amount   PICTURE "9,999,999.99"
            @ nl, 67 SAY mrecamnt        PICTURE "9,999,999.99"
            DO CASE
            CASE mrecamnt > Debit->InitAmnt
                @ nl, 75 SAY "++" + SubStr( Debit->Saleno, 2, 2 )
            CASE mrecamnt < Debit->InitAmnt
                @ nl, 75 SAY Debit->Saleno
            OTHERWISE
                @ nl, 75 SAY "**" + SubStr( Debit->Saleno, 2, 2 )
            ENDCASE
            nl++
        ENDIF
        SKIP ALIAS Debit
    ENDDO
    @  nl, 41 SAY "----------------------------------"
    nl++
    @  nl, 28 SAY "GRAND TOTALS"
    @  nl, 41 SAY ninit   PICTURE "9,999,999.99"
    @  nl, 55 SAY mamount PICTURE "9,999,999.99"
    @  nl, 67 SAY mrectot PICTURE "9,999,999.99"
    nl++
    @  nl, 41 SAY "=================================="
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
    SELECT Debit
    SET ORDER TO 1

    RETURN NIL

// ****** End of SaleList

// *---------------------------------------------------------------------*

FUNCTION MU_Debt( nc, ncl )

    DO WHILE .T.

        SET MESSAGE TO 22 CENTER
        nselect  := 0
        nc       := ncl * 2
        Scroll( 3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        Scroll( 22, 6, 22, 74 )
        @  3, nc + 4 TO 5, nc + ( ncl - 4 )
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( Menu->CH_DebHd ) ) / 2 );
            SAY RTrim( Menu->CH_DebHd )
        // **   @  6,nc+2 PROMPT "                      "
        Scroll( 22, 7, 22, 75 )
        @  7, nc + 2 PROMPT "1. " + Menu->CH_Deb1
        @  9, nc + 2 PROMPT "2. " + Menu->CH_Deb2 MESSAGE "Statements Indiv or Total"
        @ 11, nc + 2 PROMPT "3. " + Menu->CH_Deb3 MESSAGE "Add Debit Invoice Directly"
        @ 12, nc + 2 PROMPT "4. " + Menu->CH_Deb4 MESSAGE "Edit Debit entries"
        @ 13, nc + 2 PROMPT "5. " + Menu->CH_Deb5 MESSAGE "List Debits by Month"
        @ 15, nc + 2 PROMPT "6. " + Menu->CH_Deb6 MESSAGE "List Debits and Receipts"
        @ 16, nc + 2 PROMPT "7. Debit Sales Listing "
        // ***** +Menu->CH_Deb7 MESSAGE "List Debit Profile by Sale Code"
        // **   @ 17,nc+2 PROMPT "8. Year Monthly Sales" MESSAGE "List Debit Profile by Year"
        @ 17, nc + 2 PROMPT "8. " + Menu->CH_Deb8 MESSAGE "Debit Sub Menu"
        @ 19, nc + 2 PROMPT "9. All/Date Statement  "
        @ 20, nc + 2 PROMPT Menu->CH_Main
        ncm := nc
        nc  := ncl
        MENU TO nselect

        DO CASE
        CASE nselect == 10 .OR. PressedEsc()
            EXIT
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            DebDelete()                         // Below
            RESTORE SCREEN FROM holdscrn

        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            Deb240()                       // Selected Account Month
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            DebAdd()                           // Below
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            mcodeno := Space( 8 )
            DebView( @mcodeno )                // Below
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5
            SAVE SCREEN TO holdscrn
            DebList()                          // Below
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            SaleList()                         // Below
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7
            SAVE SCREEN TO holdscrn
            DebitProf()                        // Below
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 8
            SAVE SCREEN TO holdscrn
            MUS_Debt( nc, ncl )
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 9
            SAVE SCREEN TO holdscrn
            Deb245()                         // Below
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// ****  End of Mu_debt()

// ---------------------------------------------------------------------*

STATIC FUNCTION DebList()

    Scroll()
    mcodeno := Space( 8 )
    mwhere  := "P"

    DeblistH()                            // Below

    Printsel( mwhere )

    IF mwhere == "P"
        npl := 57
    ELSE
        npl := 18
    ENDIF
    nl := 2

    DeblistH()                            // Below

    mggthis := mggtotcr := mggtot1 := mggtot2 := mggtotr := 0
    ngthis := ngtotcr := ngtot1 := ngtot2 := ngtotr := nggtotr := 0
    SELECT Debit
    GOTO TOP
    DO WHILE Debit->( !Eof() )
        IF Debit->Stat != "I"
            SKIP ALIAS Debit
            LOOP
        ENDIF
        IF Debit->Amount == 0
            SKIP ALIAS Debit
            LOOP
        ENDIF
        mcodeno := Debit->Codeno
        mgthis := mgtotcr := mgtot1 := mgtot2 := mgtotr := ntot := 0
        DO WHILE Debit->Codeno == mcodeno .AND. Debit->( !Eof() )
            // THIS IS REQUIRED TO BE HERE AS WELL
            IF Debit->Stat != "I"
                SKIP ALIAS Debit
                LOOP
            ENDIF
            IF Debit->Amount == 0
                SKIP ALIAS Debit
                LOOP
            ENDIF
            DO CASE
            CASE Year(  Debit->Dbdate ) = Year( Date() ) -3
                mgtot2  += Debit->Amount
                IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    ngtot2 += Debit->Amount
                    ntot := 1
                ENDIF
            CASE Year(  Debit->Dbdate ) = Year( Date() ) -2
                mgtot2  += Debit->Amount
                IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    ngtot2 += Debit->Amount
                    ntot := 1
                ENDIF
            CASE Year(  Debit->Dbdate ) = Year( Date() ) -1;
                    .AND. Month( Debit->DbDate ) < 11
                mgtot2 += Debit->Amount
                IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    ngtot2 += Debit->Amount
                    ntot := 1
                ENDIF
            CASE Year(  Debit->Dbdate ) = Year( Date() ) -1;
                    .AND. Month( Date() ) = 1
                DO CASE
                CASE Month( Debit->Dbdate ) = 12
                    mgtotcr += Debit->Amount
                    IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                        ngtotcr += Debit->Amount
                        ntot := 1
                    ENDIF
                CASE Month( Debit->DbDate ) = 11
                    mgtot1  += Debit->Amount
                    IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                        ngtot1 += Debit->Amount
                        ntot := 1
                    ENDIF
                OTHERWISE
                    mgtot2  += Debit->Amount
                    IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                        ngtot2 += Debit->Amount
                        ntot := 1
                    ENDIF
                ENDCASE
            CASE Year(  Debit->Dbdate ) = Year( Date() ) -1;
                    .AND. Month( Date() ) = 2
                DO CASE
                CASE Month( Debit->Dbdate ) = 12
                    mgtot1 += Debit->Amount
                    IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                        ngtot1 += Debit->Amount
                        ntot := 1
                    ENDIF
                CASE Month( Debit->DbDate ) = 11
                    mgtot2  += Debit->Amount
                    IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                        ngtot2 += Debit->Amount
                        ntot := 1
                    ENDIF
                OTHERWISE
                    mgtot2  += Debit->Amount
                    IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                        ngtot2 += Debit->Amount
                        ntot := 1
                    ENDIF
                ENDCASE
            CASE Year(  Debit->Dbdate ) = Year( Date() );
                    .AND. Month( Debit->Dbdate ) == Month( Date() )
                mgthis  += Debit->Amount
                IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    ngthis += Debit->Amount
                    ntot := 1
                ENDIF
            CASE Year(  Debit->Dbdate ) = Year( Date() );
                    .AND. Month( Debit->Dbdate ) == Month( Date() ) -1
                mgtotcr += Debit->Amount
                IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    ngtotcr += Debit->Amount
                    ntot := 1
                ENDIF
            CASE Year(  Debit->Dbdate ) = Year( Date() );
                    .AND. Month( Debit->Dbdate ) == Month( Date() ) -2
                mgtot1  += Debit->Amount
                IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    ngtot1 += Debit->Amount
                    ntot := 1
                ENDIF
            OTHERWISE
                mgtot2  += Debit->Amount
                IF SubStr( Debit->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    ngtot2 += Debit->Amount
                    ntot := 1
                ENDIF
            ENDCASE
            SKIP ALIAS Debit
        ENDDO
        SELECT Name
        SEEK mcodeno
        @ nl, 0 SAY SubStr( Name->Name, 1, 18 )
        ApRLock( 3 )
        Name->Overdue := mgtot1 + mgtot2
        UNLOCK
        SELECT Debit
        @ nl, 20 SAY mgtot2  PICTURE "9999,999.99"
        @ nl, 32 SAY mgtot1  PICTURE "9999,999.99"
        @ nl, 44 SAY mgtotcr PICTURE "9999,999.99"
        @ nl, 56 SAY mgthis  PICTURE "9999,999.99"
        mgtotr := mgthis + mgtotcr + mgtot1 + mgtot2
        @ nl, 68 SAY mgtotr  PICTURE "9999,999.99"
        IF ntot > 0
            @ nl, 79 SAY "*"
        ENDIF
        ntot := 0
        nl++
        mggthis  += mgthis
        mggtotcr += mgtotcr
        mggtot1  += mgtot1
        mggtot2  += mgtot2
        mggtotr  += mgtotr
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF

            DeblistH()                          // Below

        ENDIF
    ENDDO
    @ nl, 20 SAY Replicate( "-", 58 )
    nl++
    @ nl, 4 SAY "Sales incl GST"
    @ nl, 20 SAY mggtot2  PICTURE "9999,999.99"
    @ nl, 32 SAY mggtot1  PICTURE "9999,999.99"
    @ nl, 44 SAY mggtotcr PICTURE "9999,999.99"
    @ nl, 56 SAY mggthis  PICTURE "9999,999.99"
    @ nl, 68 SAY mggtotr  PICTURE "9999,999.99"
    nl++
    @ nl, 20 SAY Replicate( "=", 58 )
    nl++
    @ nl, 8 SAY "PERCENTAGE %"
    @ nl, 26 SAY ( mggtot2 / mggtotr * 100 )  PICTURE "9999 %"
    @ nl, 38 SAY ( mggtot1 / mggtotr * 100 )  PICTURE "9999 %"
    @ nl, 50 SAY ( mggtotcr / mggtotr * 100 ) PICTURE "9999 %"
    @ nl, 60 SAY ( mggthis / mggtotr * 100 )  PICTURE "9999 %"
    nl++
    @ nl, 20 SAY Replicate( "-", 58 )
   /*
   Taken Out
   nl++
   mggtot2  := mggtot2-ngtot2
   mggtot1  := mggtot1-ngtot1
   mggtotcr := mggtotcr-ngtotcr
   mggthis  := mggthis-ngthis
   nggtotr  := ngthis+ngtotcr+ngtot1+ngtot2
   mggtotr  := mggtotr-nggtotr
   @ nl, 0 SAY "LESS GST & Export Sales"
   @ nl,24 SAY  mggtot2-( mggtot2/9 )   PICTURE "999,999.99"
   @ nl,35 SAY  mggtot1-( mggtot1/9 )   PICTURE "999,999.99"
   @ nl,46 SAY  mggtotcr-( mggtotcr/9 ) PICTURE "999,999.99"
   @ nl,57 SAY  mggthis-( mggthis/9 )   PICTURE "999,999.99"
   @ nl,68 SAY  mggtotr-( mggtotr/9 )   PICTURE "999,999.99"
   nl++
   @ nl,26 SAY REPLICATE( "-",52 )
   taken out
   */
    nl++
    @ nl, 1 SAY " * Export Sales"
    @ nl, 20 SAY ngtot2  PICTURE "9999,999.99"
    @ nl, 32 SAY ngtot1  PICTURE "9999,999.99"
    @ nl, 44 SAY ngtotcr PICTURE "9999,999.99"
    @ nl, 56 SAY ngthis  PICTURE "9999,999.99"
    @ nl, 68 SAY nggtotr PICTURE "9999,999.99"
    nl++
    @ nl, 20 SAY Replicate( "-", 58 )
   /*
   Taken Out
   nl++
      @ nl, 1 SAY "Export+Sales Less GST"
      @ nl,24 SAY ngtot2+( mggtot2-( mggtot2/9 ) )    PICTURE "999,999.99"
      @ nl,35 SAY ngtot1+( mggtot1-( mggtot1/9 ) )    PICTURE "999,999.99"
      @ nl,46 SAY ngtotcr+( mggtotcr-( mggtotcr/9 ) ) PICTURE "999,999.99"
      @ nl,57 SAY ngthis+( mggthis-( mggthis/9 ) )    PICTURE "999,999.99"
      @ nl,68 SAY nggtotr+( mggtotr-( mggtotr/9 ) )   PICTURE "999,999.99"
   taken out
   */
    @ nl, 0 SAY " "
    IF mwhere == "P"
        EndPrint()
    ELSE
        IF nl > 17
            WAIT
        ENDIF
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN NIL

// *---- End of DebList()

// *---------------------------------------------------------------------*

FUNCTION DebProfEd()

    cheading  := "View  Existing  Debit Profile"
    mcontinue := mdelete := mok := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        DispBox( 0, 50, 2, 79, 2 )
        @  1, 52 SAY "Select Debit Profile Name"
   /*
      DISPBOX( 8,10,14,28, 2 )
      nselect := 1
      @ 10,12 PROMPT "Select by Name"
      @ 12,12 PROMPT "DebProf Listing"
      MENU TO nselect
      DO CASE
          CASE PressedEsc()
             RETURN NIL

          CASE nselect == 1                    // Selected Name
            mcodeno := SPACE( 8 )
             Namerank( @mcodeno )                          // XLF_Name
            IF PressedEsc()
               RETURN NIL
            ENDIF
            SELECT Name
            mcodeno := Name->Codeno

          CASE nselect == 2                    // Listing
   */
        Scroll(  0, 0, 24, 45 )
        mcodeno := Space( 8 )
        nrecno   := 0
        aPart_   := {}
        SELECT DebProf
        SET ORDER TO 1                        // Codeno
        GOTO TOP
        IF LastRec() != 0
            DO WHILE DebProf->( !Eof() )
                IF DebProf->DbDate < Date() -750
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF DebProf->Codeno = mcodeno
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                SELECT Name
                SEEK DebProf->Codeno
                IF !Found()
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                mcodeno := Name->Codeno
                SELECT DebProf
                AAdd( aPart_, Name->Name;
                    + "       " + Str( RecNo(), 6 ) )
                SKIP ALIAS DebProf
            ENDDO                          // EOF()
            DispBox( 0, 1, 24, 45, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice( 1, 3, 23, 41, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                SELECT DebProf
                GOTO nrecno
                mcodeno := DebProf->Codeno
                SELECT Name
                SEEK mcodeno
            ENDIF
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @  1, 10 SAY Name->Name
        ENDIF                        // LastRec

        // **   ENDCASE
        manother := "Y"
        DO WHILE manother = "Y"
            minvno := Space( 6 )
            nrecno := 0
            aPart_ := {}
            SELECT DebProf
            SET ORDER TO 1                   // Codeno
            IF LastRec() != 0
                GOTO TOP
                SEEK mcodeno
                DO WHILE  DebProf->Codeno = mcodeno .AND. DebProf->( !Eof() )
                    AAdd( aPart_, DebProf->Invno;
                        + "  " + DToC( DebProf->DbDate );
                        + "  " + Str( DebProf->Amount, 9, 2 );
                        + "  " + DebProf->Paytype;
                        + "  " + Str( DebProf->CostItem, 9, 2 );
                        + "  " + DebProf->Codeno;
                        + "  " + Saleno + "  " + Debprof->Tech;
                        + "                 " + Str( RecNo() ) )
                    SKIP ALIAS DebProf
                ENDDO
                Scroll(  3, 0, 24, 80  )
                DispBox( 3, 1, 24, 79, 2 )
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum   := AChoice( 4, 6, 23, 73, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    GOTO nrecno
                ELSE
                    @ 14, 20 SAY "--- No Debit Profile ---"
                    WAIT
                    RETURN NIL
                ENDIF
            ENDIF
            SELECT Name
            SEEK DebProf->Codeno
            Scroll()
            DispBox(  0, 1, 2, 79, 2 )
            @  1, 6 SAY Name->Name
            minvno  := DebProf->Invno
            msaleno := DebProf->Saleno
            nselect := 2
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 1, 6, 79, 2 )
            @  4, 3      SAY DebProf->Invno COLOR "G+"
            @  4, Col() + 2 SAY DebProf->DbDate
            @  4, Col() + 2 SAY "Total"
            @  4, Col() + 2 SAY DebProf->Amount PICTURE "9,999,999.99" COLOR "G+"
            SELECT Debit
            LOCATE FOR Debit->Invno = DebProf->Invno
            IF Found()
                @  4, 46      SAY "Outstanding Amount"
                @  4, Col() + 1 SAY Debit->Amount  COLOR "G+"
            ENDIF
            SELECT Rec
            SET ORDER TO 1
            IF LastRec() != 0
                GOTO TOP
                SEEK DebProf->Codeno
                aPart_   := {}
                nRecamnt := 0
                DO WHILE Rec->Codeno = DebProf->Codeno .AND. Rec->( !Eof() )
                    IF Rec->Invno != DebProf->Invno
                        SKIP ALIAS Rec
                        LOOP
                    ENDIF
                    SELECT Deposit
                    cdeprev := Space( 20 )
                    LOCATE FOR Deposit->DepRef = Rec->Recno
                    IF Found()
                        IF Rec->Recno != Space( 12 )
                            cdeprev := " Deposit " + DToC( Deposit->Depdate )
                        ENDIF
                    ENDIF
                    SELECT Rec
                    nRecamnt += Rec->Recamnt
                    AAdd( aPart_, Rec->Invno + " " + DToC( Rec->RecDate );
                        + " " + Str( Rec->Recamnt, 9, 2 );
                        + " " + Rec->Jobno;
                        + " " + Str( nRecamnt, 9, 2 );
                        + " " + Rec->Recno + " " + cdeprev )
                    SKIP ALIAS Rec
                ENDDO
                IF !Empty( aPart_ )
                    Scroll(   8, 0, 24, 80 )
                    DispBox(  8, 1, 19, 79, 2 )
                    @  8, 25 SAY "   RECEIPTS FOR INVNO " + DebProf->Invno + "   " COLOR "G+"
                    // **         ASORT(aPart_,,,{ | x,y | x < y })
                    AEval( aPart_, {|A| QOUT( " " + Chr( 186 ) + "  " );
                        , QQOut( A ), BreakTot() } )
                ENDIF
            ENDIF
            nselect := 0
            DispBox( 20, 1, 24, 79, 2 )
            @ 22, 10      PROMPT "Another"
            @ 22, Col() + 3 PROMPT "Edit"
            @ 22, Col() + 3 PROMPT "Delete"
            @ 22, Col() + 3 PROMPT "Add New ( DebProf Only )"
            @ 22, Col() + 3 PROMPT "Exit"
            MENU TO nselect
            DO CASE
            CASE nselect = 5 .OR. PressedEsc()
                EXIT
            CASE nselect == 1
                // ***          manother  := "N"
                mcontinue := "Y"
                LOOP
            CASE nselect == 2
                msaleno := DebProf->Saleno
                DebProfLk( msaleno )                    // Below
                manother  := "Y"
                mcontinue := "Y"
                LOOP
            CASE nselect == 3
                Scroll(  19, 0, 24, 80  )
                cstring := Trim( Message->Suredel )
                mok := ApCheck( cstring )                     // AppX.PRG
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                IF mok == "Y"
                    mdelete := "D"
                    SELECT DebProf
                    ApRLock( 3 )
                    DELETE
                    UNLOCK
                ENDIF
                mcontinue := "Y"
                manother  := "Y"
                LOOP
            CASE nselect == 4
                mcodeno := Space( 8 )
                Namerank( @mcodeno )                          // XLF_Name
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                SELECT Name
                mcodeno := Name->Codeno
                SELECT DebProf
                ApFLock( 3 )
                APPEND BLANK
                DebProf->Codeno   := mcodeno
                DebProf->U_Codeno := mcodeno
                UNLOCK
                msaleno := DebProf->Saleno
                DebProfLk( msaleno )                    // Below
                manother  := "Y"
                mcontinue := "Y"
                LOOP
            ENDCASE
        ENDDO                 // manother
    ENDDO                   // mcontinue

    RETURN NIL

// **---- End of DebProfEd()

// *---------------------------------------------------------------------*

STATIC FUNCTION DebView()

    mcontinue := mok := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        DispBox( 0, 52, 2, 79, 2 )
        @  1, 55 SAY "Select Debit Name"
        DispBox( 8, 10, 14, 28, 2 )
        nselect := 1
        @ 10, 12 PROMPT "Select by Name"
        @ 12, 12 PROMPT "Debit Listing"
        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nselect == 1
            mcodeno := Space( 8 )
            Namerank( @mcodeno )                          // XLF_Name
            IF PressedEsc()
                RETURN NIL
            ENDIF
            SELECT Name
            mcodeno := Name->Codeno
        CASE nselect == 2
            Scroll(  0, 0, 24, 45 )
            mcodeno := Space( 8 )
            nrecno   := 0
            aPart_   := {}
            SELECT Debit
            GOTO TOP
            IF LastRec() != 0
                DO WHILE Debit->( !Eof() )
                    IF Debit->Codeno = mcodeno
                        SKIP ALIAS Debit
                        LOOP
                    ENDIF
                    SELECT Name
                    SEEK Debit->Codeno
                    SELECT Debit
                    mcodeno := Debit->Codeno
                    AAdd( aPart_, Name->Name + "  " + Debit->BranchId;
                        + "       " + Str( RecNo(), 6 ) )
                    SKIP ALIAS Debit
                ENDDO                          // EOF()
                DispBox( 0, 1, 24, 45, 2 )
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum   := AChoice( 1, 3, 23, 41, aPart_,, "AFUNC" )
                    nrecno := Val( Right( aPart_[ anum ],6 ) )
                    IF PressedEsc()
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
            ENDIF                        // LastRec
        ENDCASE
        minvno  := Space( 6 )
        SELECT Debit
        SEEK mcodeno
        IF !Found()
            Scroll( 3, 0, 24, 80 )
            @ 12, 12 SAY "No DEBIT This Customer"
            @ 14, 12 SAY Message->AnyKey
            Inkey()
            RETURN NIL
        ELSE
            cbranchId := Space( 2 )

            DebLook( mcodeno )                               // XF_Util

            mtest    := "N"
            manother := "Y"
            DO WHILE manother = "Y"
                minvno  := Debit->Invno
                msaleno := Debit->Saleno
                nselect := 2
                Scroll(  2, 0, 24, 80 )
                DispBox( 2, 1,  4, 79, 2 )
                @  3, 6      SAY Debit->Invno COLOR "G+"
                @  3, Col() + 2 SAY Debit->DbDate
                @  3, Col() + 2 SAY Debit->Amount   PICTURE "9999,999.99" COLOR "G+"
                @  3, Col() + 3 SAY Debit->Saleno
                @  3, Col() + 2 SAY Debit->InitAmnt PICTURE "9999,999.99" COLOR "BG+"
                @  3, Col() + 2 SAY Debit->Stat
                SELECT Rec
                SET ORDER TO 1
                IF LastRec() != 0
                    GOTO TOP
                    SEEK Debit->Codeno
                    aPart_   := {}
                    nRecamnt := 0
                    DO WHILE Rec->Codeno = Debit->Codeno .AND. Rec->( !Eof() )
                        IF Rec->Invno != Debit->Invno
                            SKIP ALIAS Rec
                            LOOP
                        ENDIF
                        SELECT Deposit
                        cdeprev := Space( 20 )
                        LOCATE FOR Deposit->DepRef = Rec->Recno
                        IF Found()
                            IF Rec->Recno != Space( 12 )
                                cdeprev := " Deposit " + DToC( Deposit->Depdate )
                            ENDIF
                        ENDIF
                        SELECT Rec
                        nRecamnt += Rec->Recamnt
                        AAdd( aPart_, Rec->Invno + " " + DToC( Rec->RecDate );
                            + " " + Str( Rec->Recamnt, 9, 2 );
                            + " " + Rec->Jobno;
                            + " " + Str( nRecamnt, 9, 2 );
                            + " " + Rec->Recno;
                            + cdeprev )
                        SKIP ALIAS Rec
                    ENDDO
                    IF !Empty( aPart_ )
                        Scroll(   5, 0, 24, 80 )
                        DispBox(  5, 1, 21, 79, 2 )
                        @  5, 25 SAY "   RECEIPTS FOR INVNO " + Debit->Invno + "   " COLOR "G+"
                        // **         ASORT(aPart_,,,{ | x,y | x < y })
                        AEval( aPart_, {|A| QOUT( " " + Chr( 186 ) + "  " );
                            , QQOut( A ), BreakTot() } )
                        // **    IF mtest = "Y"
                        SELECT Debit
                        ApRLock( 3 )
                        @ 19, 4      SAY "Initial Amnt"
                        @ 19, Col() + 1 SAY Debit->InitAmnt PICTURE "9999,999.99" COLOR "G+"
                        @ 19, Col() + 1 SAY "Received"
                        @ 19, Col() + 1 SAY nRecAmnt PICTURE "9999,999.99" COLOR "BG+"
                        @ 19, Col() + 1 SAY "Debit Balance"
                        @ 19, Col() + 1 SAY Debit->InitAmnt - nRecAmnt PICTURE "9999,999.99" COLOR "BG+"
                        @ 20, 6 SAY "Check Debit Amount" GET Debit->Amount
                        READ
                        UNLOCK
                        mtest = "N"
                        // **   ENDIF                        // mtest
                    ENDIF
                ENDIF
                SELECT Debit
                DispBox( 22, 1, 24, 79, 2 )
                @ 23, 6      PROMPT "Another"
                @ 23, Col() + 3 PROMPT "Edit Debit"
                @ 23, Col() + 3 PROMPT "View Invoice"
                @ 23, Col() + 3 PROMPT "Letter"
                @ 23, Col() + 3 PROMPT "Delete"
                @ 23, Col() + 3 PROMPT "View Receipt"
                MENU TO nselect
                DO CASE
                CASE PressedEsc()
                    RETURN NIL
                CASE nselect == 1
                    manother := "N"
                    mcontinue := "Y"
                    LOOP
                CASE nselect == 2
                    DebGet( @msaleno )                     // XLF_Deb1
                    manother := "Y"
                    LOOP
                CASE nselect == 3
                    minvno := Debit->Invno
                    IvcLook( minvno )
                    @ 21, 4 SAY " "
                    WAIT
                    manother := "Y"
                    mcontinue := "Y"
                    LOOP
                CASE nselect == 4
                    Debt1( mcodeno )                        // XLF_Deb1
                    manother := "Y"
                    LOOP
                CASE nselect == 5
                    cstring := Trim( Message->Suredel )
                    mok := ApCheck( cstring )                     // AppX.PRG
                    IF PressedEsc()
                        RETURN NIL
                    ENDIF
                    IF mok == "Y"
                        mremove := ApGetN( "Delete from Debit Hist - Beware" )
                        IF mremove = "Y"
                            SELECT DebProf
                            SET ORDER TO 2            // Invno
                            SEEK Debit->Invno
                            IF Found()
                                ApRLock( 3 )
                                DELETE
                                UNLOCK
                            ENDIF                     // !Found()
                        ENDIF                       // mremove
                        SELECT Invoice
                        SEEK Debit->Invno
                        DO WHILE Invoice->Invno = Debit->Invno .AND. Invoice->( !Eof() )
   /*
   Taken Out
                       SELECT PartOper
                       SEEK Invoice->Partnum
                       DO WHILE PartOper->Partnum = Invoice->Partnum .AND. PartOper->( !EOF() )
                          IF PartOper->Codeno != Invoice->Codeno
                             SKIP ALIAS PartOper
                             LOOP
                          ENDIF
                           ApFLock( 3 )
                          DELETE
                          UNLOCK
                          SKIP Alias PartOper
                       ENDDO
   */
                            SELECT HIST
                            SET ORDER TO 1
                            SEEK Invoice->Codeno + Invoice->Partnum;
                                + Invoice->Invno + DToS( Invoice->PDate )
                            IF Found()
                                ApRLock( 3 )
                                DELETE
                                UNLOCK
                            ENDIF                            // Found()
                            SELECT Invoice
                            ApFLock( 3 )
                            DELETE
                            UNLOCK
                            SKIP ALIAS Invoice
                        ENDDO
                        SELECT Labour
                        GOTO TOP
                        DO WHILE Labour->( !Eof() )
                            IF Labour->Invno != Debit->Invno
                                SKIP ALIAS Labour
                                LOOP
                            ENDIF
                            IF Labour->Partnum = Space( 20 )
                                ApFLock( 3 )
                                DELETE
                                UNLOCK
                            ENDIF
                            SKIP ALIAS Labour
                        ENDDO
                        SELECT Cusnotes
                        coderef := Debit->Invno
                        SEEK coderef
                        ApFLock( 3 )
                        DO WHILE Found()
                            DELETE
                            SEEK coderef
                        ENDDO
                        UNLOCK
                        mdelete := "D"
                        SELECT Debit
                        ApRLock( 3 )
                        DELETE
                        UNLOCK
                    ENDIF               // mok
                    manother := "Y"
                    mcontinue := "Y"
                    LOOP

                CASE nselect == 6
                    nrectot := nrecno := 0
                    aPart_ := {}
                    SELECT Rec
                    IF LastRec() != 0
                        GOTO TOP
                        DO WHILE Rec->( !Eof() )
                            IF Rec->Invno != Debit->Invno
                                SKIP ALIAS Rec
                                LOOP
                            ENDIF
                            AAdd( aPart_, Rec->Invno;
                                + "  " + DToC( Rec->RecDate );
                                + "  " + Str( Rec->Recamnt, 9, 2 );
                                + "  " + Rec->Saleno;
                                + "  " + Rec->Jobno + "  " + Rec->Recno;
                                + "         " + Str( RecNo(), 6 ) )
                            SKIP ALIAS Rec
                        ENDDO
                        Scroll(  12, 0, 24, 80 )
                        DispBox( 12, 1, 24, 79, 2 )
                        IF !Empty( aPart_ )
                            ASort( aPart_,,, {| x, y | x < y } )
                            anum   := AChoice( 13, 3, 23, 66, aPart_,, "AFUNC" )
                            nrecno := Val( Right( aPart_[ anum ], 6 ) )
                        ENDIF
                    ENDIF
                    Scroll( 3, 0, 24, 80 )
                    GOTO nrecno
                    drecdate := Rec->RecDate

                    ReceHead()                                     // above

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
                        mdelete := "D"
                        SELECT Rec
                        ApRLock( 3 )
                        DELETE
                        UNLOCK
                    ENDIF
                    mtest     := "Y"
                    manother := "Y"
                    LOOP
                ENDCASE
            ENDDO                // manother
        ENDIF
        mcontinue := "Y"
    ENDDO

    RETURN NIL

// *--- End of DebView()

// ---------------------------------------------------------------------*

STATIC FUNCTION MUS_Debt( nc, ncl )

    DO WHILE .T.

        SET MESSAGE TO 22 CENTER
        nselect  := 0
        nc       := ncl * 2
        Scroll( 3, nc, 21, 76 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  3, nc + 4 TO 5, nc + ( ncl - 4 )
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( Menu->CH_DebHd ) ) / 2 );
            SAY RTrim( Menu->CH_DebHd )
        Scroll( 22, 7, 22, 75 )
        @  7, nc + 2 PROMPT "1. " + Menu->CH_L2Db1 MESSAGE "Weekly Debit Analsis"
        @  9, nc + 2 PROMPT "2. " + Menu->CH_L2Db2 MESSAGE "Daily Sales CA/CH/CT "
        @ 11, nc + 2 PROMPT "3. " + Menu->CH_Ivc6  MESSAGE "Daily Profit"
        @ 13, nc + 2 PROMPT "4. Invoice List        " // +Menu->CH_Ivc7  MESSAGE "Technician List"
        @ 14, nc + 2 PROMPT "5. " + Menu->CH_L2Db5 MESSAGE "Job or Invoice Listing"
        @ 16, nc + 2 PROMPT "6. " + Menu->CH_L2Db6 MESSAGE "Debit Profile Edit"
        @ 17, nc + 2 PROMPT "7. Invoice History Edit" MESSAGE "History File Edit"
        @ 19, nc + 2 PROMPT "8. Daily Sales Amnt    " MESSAGE "Monthly Sales - Costs"
        @ 20, nc + 2 PROMPT Menu->CH_Main + "   "
        ncm := nc
        nc  := ncl
        MENU TO nselect
        DO CASE
        CASE nselect ==  9 .OR. PressedEsc()
            EXIT
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            WkDebProf()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            DebPayRep()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            DebProf()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            DebTech()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5
            SAVE SCREEN TO holdscrn
            DebLst()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            DebProfed()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7
            SAVE SCREEN TO holdscrn
            DebHistEd()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 8
            SAVE SCREEN TO holdscrn
            Debcost()
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// ****  End of MuS_debt()

// **---------------------------------------------------------------------*

FUNCTION DebHistEd()

    mcodeno := Space( 8 )
    mcontinue := mdelete := mok := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()

   /*
      IF mcodeno = SPACE( 8 )
          Namerank()                            // XLF_Name
         IF LASTKEY() = 27
            RETURN NIL
         ENDIF
      ENDIF
      mcodeno  := Name->Codeno
   */
        mstmm  := Date() -30
        mendmm := Date()
        @  8, 10 SAY Message->Frdate GET mstmm  PICTURE "99/99/9999"
        @ 10, 10 SAY Message->Todate GET mendmm PICTURE "99/99/9999"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        cheading  := "View  Existing  Hist"
        // **   dyymm := dyy+dmm
        nrecno := 0
        aPart_ := {}
        SELECT Hist
        SET ORDER TO 1
        GOTO TOP
        // **   SEEK mcodeno
        IF LastRec() != 0
            DO WHILE Hist->( !Eof() )
                IF Hist->PDate < mstmm
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                IF Hist->PDate > mendmm
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                // **         IF YEAR( Hist->PDate ) < ( YEAR( DATE() )-2 )
                // **            SKIP ALIAS Hist
                // **            LOOP
                // **         ENDIF
                SELECT Part
                SEEK Hist->Partnum
                SELECT Hist
                AAdd( aPart_, Hist->Invno + " " + DToC( Hist->PDate );
                    + " " + Str( Hist->Qty ) + " " + Str( Hist->Amount );
                    + " " + Str( Hist->Cost );
                    + " " + SubStr( Part->Desc, 1, 22 ) + "  " + Hist->Saleno;
                    + "     " + Str( RecNo() ) )
                SKIP ALIAS Hist
            ENDDO
            Scroll()
            DispBox( 0, 1, 24, 79, 2 )
            @ 0, 21 SAY "  Qty       Amount      Cost  "
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice( 1, 2, 23, 78, aPart_,, "AFUNC" )
                IF LastKey() = 27
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
            ELSE
                @ 14, 20 SAY "--- No Hist This Client ---"
                WAIT
                // **         mcodeno := SPACE( 8 )
                LOOP
            ENDIF
        ENDIF
        Scroll(  3, 0, 24, 80  )
        DispBox( 3, 1, 18, 79, 2 )
        GOTO nrecno
        nl := 4
        SELECT Hist
        @ nl, 10 SAY "History Date  " + DToC( Hist->PDAte )
        nl += 2
        @ nl, 10 SAY "    Salebook  " + Hist->Saleno
        nl += 2
        @ nl, 10 SAY "  Invno " + Hist->Invno
        nl += 2
        @ nl, 10 SAY "Amount"
        @ nl, 18 SAY Hist->Amount PICTURE "9999999.99"
        @ nl, 30 SAY "Cost"
        @ nl, 35 SAY Hist->Cost PICTURE "9999999.99"
        @ nl, Col() + 2 SAY "Qty  " + Str( Hist->Qty )
        nl += 2
        @ nl, 10 SAY "U_Codeno " + Hist->U_Codeno
        @  nl, Col() + 2 SAY "BranchId " + Hist->BranchId PICTURE "@!"
        nl += 2
        @  nl, 10      SAY "Partnum  " + Hist->Partnum PICTURE "@!"
        @  nl, Col() + 2 SAY "Codeno   " + Hist->Codeno  PICTURE "@!"
        nselect := 0
        DispBox( 20, 1, 24, 79, 2 )
        @ 22, 15      PROMPT "Edit"
        @ 22, Col() + 2 PROMPT "Delete"
        @ 22, Col() + 2 PROMPT "Add History"
        @ 22, Col() + 2 PROMPT "Another"
        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nselect == 1
            msaleno := Hist->Saleno
            DebHistLk( msaleno )                    // Below
        CASE nselect == 2
            cstring := Trim( Message->Suredel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mok == "Y"
                mdelete := "D"
                SELECT Hist
                ApRLock( 3 )
                DELETE
                UNLOCK
            ENDIF
            mcontinue := "Y"
        CASE nselect == 3
            HistAdd()                    // Above

        CASE nselect == 4
            mcontinue := "Y"
        ENDCASE

    ENDDO

    RETURN NIL

// **---- End of DebHistEd()

// *---------------------------------------------------------------------*

STATIC FUNCTION DebHistLk( msaleno )

    Scroll(  3, 0, 18, 80 )
    DispBox( 3, 1, 18, 79, 2 )
    nl := 4
    SELECT Hist
    ApRLock( 3 )
    @  nl, 10 SAY "History Date :"  GET Hist->PDate PICTURE "99/99/9999"
    READ
    UNLOCK
    nl += 2
    @ nl, 15 SAY "Salebook :"
    IF Hist->Saleno == Space( 4 )
        Scroll( 13, 0, 24, 80 )

        SbLook( @msaleno )                  // XLF_ACC

    ELSE
        SELECT Hist
        ApRLock( 3 )
        @ nl, 10 SAY "     Salebook :" GET Hist->Saleno PICTURE "@K!"
        READ
        msaleno := Hist->Saleno
        UNLOCK
        SELECT SaleBook
        SEEK msaleno
        IF !Found()
            Scroll( 13, 0, 24, 80 )
            SbLook( @msaleno )                // XLF_Acc
        ENDIF
    ENDIF
    DispBox( 3, 1, 18, 79, 2 )
    @ nl, 10 SAY "Sale Book #  " + SaleBook->Saleno + "  " + Salebook->Sbname
    nl += 2
    SELECT Hist
    ApRLock( 3 )
    Hist->Saleno := SaleBook->Saleno
    @  nl, 10      SAY " Invno :"  GET Hist->Invno   PICTURE "@X"
    nl += 2
    @  nl, 10      SAY "Amount :"  GET Hist->Amount  PICTURE "9999999.99"
    @  nl, Col() + 2 SAY "Cost :"    GET Hist->Cost    PICTURE "9999999.99"
    @  nl, Col() + 2 SAY "Qty :"     GET Hist->Qty     PICTURE "99999.99"
    nl += 2
    @  nl, 10      SAY "U_Codeno :" GET Hist->U_Codeno PICTURE "@!"
    @  nl, Col() + 2 SAY "BranchId :" GET Hist->BranchId PICTURE "@!"
    nl++
    @  nl, 10      SAY "Partnum :" GET Hist->Partnum PICTURE "@!"
    @  nl, Col() + 2 SAY "Codeno :"  GET Hist->Codeno  PICTURE "@!"
    nl++
    @  nl, 10      SAY "Est Note"  GET Hist->Est     PICTURE "@!"
    @  nl, Col() + 2 SAY "Stat :"    GET Hist->STAT    PICTURE "!"
    nl++
    @  nl, 10      SAY "DocNo  :"  GET Hist->Docno   PICTURE "@!"
    READ
    UNLOCK

    RETURN NIL
// **------ End of DebHistLk()

// *---------------------------------------------------------------------*

FUNCTION DebprofLk( msaleno )

    Scroll(  3, 0, 19, 80 )
    DispBox( 3, 1, 19, 79, 2 )
    nl := 4
    @ nl, 10      SAY "Invno " + DebProf->Invno
    @ nl, Col() + 2 SAY "Amount"
    @ nl, Col() + 2 SAY DebProf->Amount PICTURE "9999999.99"
    nl += 2
    @ nl, 10 SAY "Salebook :"
    IF DebProf->Saleno == Space( 4 )
        Scroll( 13, 0, 24, 80 )

        SbLook( @msaleno )                  // XLF_ACC

    ELSE
        SELECT DebProf
        ApRLock( 3 )
        @ nl, 10 SAY "     Salebook :" GET DebProf->Saleno PICTURE "@K!"
        READ
        msaleno := DebProf->Saleno
        UNLOCK
        SELECT SaleBook
        SEEK msaleno
        IF !Found()
            Scroll( 13, 0, 24, 80 )
            SbLook( @msaleno )                // XLF_Acc
        ENDIF
    ENDIF
    Scroll(  3, 0, 19, 80 )
    DispBox( 3, 1, 19, 79, 2 )
    SELECT DebProf
    ApRLock( 3 )
    @  nl, 10 SAY "Debit Profile Date"  GET DebProf->DbDate PICTURE "99/99/9999"
    nl += 2
    @ nl, 10 SAY "Sale Book #  " + SaleBook->Saleno + "  " + Salebook->Sbname
    nl += 2
    DebProf->Saleno := SaleBook->Saleno
    @  nl, 10      SAY " Invno :"  GET DebProf->Invno    PICTURE "@X"
    nl += 2
    @  nl, 10      SAY "Amount"    GET DebProf->Amount   PICTURE "9999999.99"
    @  nl, Col() + 2 SAY "GST"       GET DebProf->GSTAmnt  PICTURE "9999999.99"
    @  nl, Col() + 2 SAY "Cost"      GET DebProf->CostItem PICTURE "9999999.99"
    nl += 2
    @  nl, 10      SAY "U_Codeno"  GET DebProf->U_Codeno PICTURE "@!"
    @  nl, Col() + 2 SAY "Pay Type"  GET DebProf->PayType  PICTURE "@!"
    // **   @  nl,COL()+2 SAY "Tech "     GET DebProf->Tech     PICTURE "@!"
    READ
    UNLOCK

    RETURN NIL
// **------ End of DebProfLk()

// ---------------------------------------------------------------------*

FUNCTION DebAdd()

    mok := "Y"
    DO WHILE mok == "Y"

        Namerank()                            // XLF_Name

        IF LastKey() = 27
            RETURN NIL
        ENDIF
        mcodeno  := Name->Codeno
        SELECT Debit
        cbranchId := Space( 2 )

        DebLook( mcodeno )                    // XF_Util.PRG

        mcontinue := "Y"
        DO WHILE mcontinue = "Y"
            ApFLock( 3 )
            APPEND BLANK
            Debit->Dbdate   := Date()
            Debit->Codeno   := mcodeno
            Debit->U_Codeno := mcodeno
            Debit->Stat     := "I"
            UNLOCK
            mcorrect := "N"
            DO WHILE mcorrect == "N"
                msaleno := Control->Saleno

                DebGet( msaleno )                 // XLF_Deb1.PRG

                mcorrect := ApGetY( Message->Correct )
                IF PressedEsc()
                    SELECT Debit
                    ApRLock( 3 )
                    DELETE
                    UNLOCK
                    RETURN NIL
                ENDIF
            ENDDO                                 // mcorrect
            nselect := 0
            Scroll( 20, 0, 24, 80 )
            DispBox( 20, 1, 24, 79, 2 )
            @ 22, 15      PROMPT "Return"
            @ 22, Col() + 3 PROMPT "Another Debit"
            @ 22, Col() + 3 PROMPT "Profile Only"
            MENU TO nselect
            DO CASE
            CASE PressedEsc()
                RETURN NIL
            CASE nselect == 1
                mcontinue := mok := "N"
            CASE nselect == 2
                mcontinue := "N"
                mok       := "Y"
            CASE nselect == 3
                SELECT Debit
                ApRLock( 3 )
                DELETE
                UNLOCK
                mcontinue := mok := "N"
            ENDCASE
        ENDDO                                    // mcontinue
    ENDDO                                       // mok

    RETURN NIL
// ***------- End of DebAdd()

// *---------------------------------------------------------------------*

STATIC FUNCTION DeblistH()

    @  0, 0 SAY "DEBTORS LIST"
    @  0, 14 SAY CMonth( Date() )
    @  0, 25 SAY Control->U_Name
    @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 0 SAY "NAME"
    @  2, 28 SAY "2+OVER"
    @  2, 38 SAY "1 MONTH"
    @  2, 49 SAY "CURRENT"
    @  2, 58 SAY "This Month"
    @  2, 72 SAY "TOTAL"
    @  3, 0 SAY Replicate( "-", 80 )
    nl := 4

    RETURN NIL
// **---- End of DeblistH()

// ---------------------------------------------------------------------*

STATIC FUNCTION DebDelete()

    msaleno := Space( 4 )
    Scroll()
    IF SubStr( Control->U_Name, 1, 4 ) = "CALD"
        @  6, 10 SAY Message->BLANK GET msaleno PICTURE "@K!"
        READ
        IF msaleno != Space( 4 )
            SELECT Salebook
            SEEK msaleno
            IF !Found()
                Sblook( @msaleno )                      // XLP_Acc.PRG
            ENDIF                        // Found()
            msaleno := Salebook->Saleno
        ENDIF
    ENDIF                       // Cald
    mname     := "Y"
    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        mthis := 0
        SELECT Debit
        GOTO TOP
        DO WHILE Debit->( !Eof() )
            mthis += Debit->Amount
            SKIP ALIAS Debit
        ENDDO
        mdelete := mok := "Y"
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @ 1, 10 SAY "DEBITS "
        @ 1, Col() + 2 SAY mthis PICTURE "$999,999.99"
        aPart_ := {}
        nrecno := 0
        SELECT Debit
        IF LastRec() != 0
            GOTO TOP
            IF SubStr( Control->U_Name, 1, 4 ) = "CALD"
                DO WHILE  Debit->( !Eof() )
                    IF msaleno != Space( 4 )
                        IF Debit->Saleno != msaleno
                            SKIP ALIAS Debit
                            LOOP
                        ENDIF                          // 1tec
                    ENDIF
                    SELECT Name
                    SEEK Debit->Codeno
                    SELECT Debit
                    cname := SubStr( Name->Name, 1, 30 )
                    IF Debit->PayType = "CT"
                        cname := Debit->Codeno + Space( 5 ) + Debit->U_Codeno + Space( 9 )
                    ENDIF
                    csale := Debit->Saleno + " " + Debit->Invno
                    AAdd( aPart_, csale;
                        + " " + DToC( DbDate );
                        + " " + cname + " " + Str( Debit->Amount, 10, 2 );
                        + " " + Debit->PayType + "  " + Debit->Stat;
                        + " " + SubStr( Debit->Ordnum, 1, 6 );
                        + "         " + Str( RecNo() ) )
                    SKIP ALIAS Debit
                ENDDO
            ELSE
                DO WHILE  Debit->( !Eof() )
                    IF SubStr( Debit->Invno, 1, 1 ) = " "
                        SKIP ALIAS Debit
                        LOOP
                    ENDIF
                    SELECT Name
                    SEEK Debit->Codeno
                    SELECT Debit
                    cname := SubStr( Name->Name, 1, 30 )
                    IF Debit->PayType = "CT"
                        cname := Debit->Codeno + Space( 5 ) + Debit->U_Codeno + Space( 9 )
                    ENDIF
                    AAdd( aPart_, cname + " " + Debit->BranchId + " " + Debit->Invno;
                        + " " + DToC( DbDate ) + " " + Str( Debit->Amount, 10, 2 );
                        + " " + Debit->PayType + "  " + Debit->Saleno;
                        + " " + Debit->Stat + " " + SubStr( Debit->Ordnum, 1, 6 );
                        + "         " + Str( RecNo() ) )
                    SKIP ALIAS Debit
                ENDDO
            ENDIF                             // Cald
            DispBox( 3, 1, 23, 79, 2 )
            @ 24, 3 SAY Trim( Message->Select ) + " " + Trim( Message->Esc ) + " F3 - Edit"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice( 4, 3, 22, 78, aPart_,, "Afunc" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
            ENDIF
            IF LastKey() == -1
                DebAdd()
                mok := "N"
            ENDIF
            IF LastKey() == -2
                mcodeno := Space( 8 )
                DebView( @mcodeno )
                mok := "N"
            ENDIF
            IF PressedEsc()
                RETURN NIL
            ENDIF
        ENDIF                                // NOT 0
        GOTO nrecno
        IF mok = "Y"
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 1, 19, 79, 2 )
            SELECT Name
            SEEK Debit->Codeno
            @  5, 10 SAY Name->Title + " " + Name->Called + " " + Name->Famname
            @  7, 10 SAY Name->Name
            @  7, 45 SAY "Sale Type " + Name->Sale
            @  9, 10 SAY "Home " + Name->EPhone + " Bus " + Name->Phone
            SELECT Debit
            @ 11, 6      SAY Debit->Dbdate
            @ 11, Col() + 2 SAY Debit->Amount PICTURE "9,9999,999.99"
            @ 11, Col() + 2 SAY Debit->Saleno
            @ 11, Col() + 2 SAY Debit->Invno
            @ 11, Col() + 2 SAY Debit->InitAmnt PICTURE "9,9999,999.99"
            @ 13, 10      SAY Debit->Brand
            @ 15, 10      SAY "Contacted " + Debit->Head
            @ 17, 10      SAY "Info " +     Debit->Fault
        ENDIF
        nselect := 2
        Scroll(  20, 0, 24, 80 )
        DispBox( 20, 1, 24, 79, 2 )
        @ 22, 6      PROMPT "Delete"
        @ 22, Col() + 2 PROMPT "Add Debit"
        @ 22, Col() + 2 PROMPT "Edit Total"
        @ 22, Col() + 2 PROMPT "Edit Info"

        @ 23, 6      PROMPT "View Invoice"
        @ 23, Col() + 2 PROMPT "Print"
        @ 23, Col() + 2 PROMPT "Name Edit"
        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            RETURN NIL
        CASE nselect == 1
            Scroll( 19, 0, 24, 80 )
            cstring := Trim( Message->Suredel )
            mok := ApCheck( cstring )              // AppX.PRG
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mok == "Y"
                mremove := ApGetN( "Delete from Debit Hist - Beware" )
                IF mremove = "Y"
                    SELECT DebProf
                    SET ORDER TO 2             // Invno
                    SEEK Debit->Invno
                    IF Found()
                        ApRLock( 3 )
                        DELETE
                        UNLOCK
                    ENDIF                            // !Found()
                ENDIF              // mremove
                SELECT Invoice
                SEEK Debit->Invno
                DO WHILE Invoice->Invno = Debit->Invno .AND. Invoice->( !Eof() )
   /*
   Taken Out
                       SELECT PartOper
                       SEEK Invoice->Partnum
                       DO WHILE PartOper->Partnum = Invoice->Partnum .AND. PartOper->( !EOF() )
                          IF PartOper->Codeno != Invoice->Codeno
                             SKIP ALIAS PartOper
                             LOOP
                          ENDIF
                           ApFLock( 3 )
                          DELETE
                          UNLOCK
                          SKIP Alias PartOper
                       ENDDO
   */
                    // ** NO NOT HERE   Money not Received                    IF mremove = "Y"
                    SELECT HIST
                    SET ORDER TO 1
                    SEEK Invoice->Codeno + Invoice->Partnum;
                        + Invoice->Invno + DToS( Invoice->PDate )
                    IF Found()
                        ApRLock( 3 )
                        DELETE
                        UNLOCK
                    ENDIF                            // Found()
                    // ** HIST taken out                    ENDIF                   // mremove
                    SELECT Invoice
                    ApFLock( 3 )
                    DELETE
                    UNLOCK
                    SKIP ALIAS Invoice
                ENDDO
                SELECT Labour
                GOTO TOP
                DO WHILE Labour->( !Eof() )
                    IF Labour->Invno != Debit->Invno
                        SKIP ALIAS Labour
                        LOOP
                    ENDIF
                    ApFLock( 3 )
                    DELETE
                    UNLOCK
                    SKIP ALIAS Labour
                ENDDO
                mdelete := "D"
                SELECT Debit
                ApRLock( 3 )
                DELETE
                UNLOCK
                SEEK Name->Codeno
                IF !Found()
                    SELECT Name
                    IF Name->Sale = "TEMP"
                        ApRLock( 3 )
                        DELETE
                        UNLOCK
                        mname := "Y"
                    ENDIF
                ENDIF                            // !Found()
            ENDIF                               // mok = "Y"
        CASE nselect == 2
            DebAdd()
        CASE nselect == 3
            Scroll()
            DispBox( 0, 1, 2, 79, 2 )
            @ 1, 10 SAY Name->Name
            msaleno := Debit->Saleno
            DebGet( msaleno )
        CASE nselect == 4
            SELECT Debit
            ApRLock( 3 )
            @ 15, 10      SAY "Contacted"       GET Debit->Head
            @ 15, Col() + 2 SAY "I=Invoice W=W/B J=Job" GET Debit->Stat;
                VALID( Debit->Stat $ "IWJ" ) PICTURE "@!"
            @ 17, 10      SAY "Info"            GET Debit->Fault
            @ 18, 10      SAY "Desc"            GET Debit->Est
            READ
            UNLOCK
        CASE nselect == 5
            minvno := Debit->Invno
            IvcLook( minvno )
            @ 21, 4 SAY " "
            WAIT
            mcontinue := "Y"
            LOOP
        CASE nselect == 6
            DebLst()
        CASE nselect == 7
            mcodeno := Name->Codeno
            NameGet( @mcodeno )
        ENDCASE
        mcontinue := "Y"
    ENDDO

    RETURN NIL

// **---- End of DebDelete()

// *---------------------------------------------------------------------*

STATIC FUNCTION SaleHead( nl )

    @  0, 0 SAY "Debit-Received  List"
    @  0, 26 SAY Control->U_Name
    @  0, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
        + Str( Year( Date() ), 5 )
    @  2, 0 SAY "Inv #"
    @  2, 9 SAY "Date"
    @  2, 22 SAY "Name"
    @  2, 41 SAY "InitAmnt"
    @  2, 52 SAY "Outstanding"
    @  2, 66 SAY "Received"
    @  2, 76 SAY "Sale"
    nl := 4

    RETURN nl

// *********------------------ END OF FILE XLF_DEB.PRG
