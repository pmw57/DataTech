// **  JK 16-07-11 07:14:51

/*
   Program.....:              ZSF_NAME.PRG
   Author......: J.Kirby
   Date........: 01/09/1993
   Functions...: SBSList, BranchFind, Numchange, Branchadd
                  Branchshow
   Static funcs: Namepjs
   Not used....: Jsheet, RepSheet
*/

FUNCTION SBSList()

    Scroll()
    DispBox( 0, 5, 2, 75, 2, )
    @  1, 10 SAY "SBS  Name Listing"
    DispBox( 3, 5, 24, 75, 2 )
    mexec   := Space( 4 )
    mchoice := 1
    @  5, 15 PROMPT Menu1->Exec01
    @  6, 15 PROMPT Menu1->Exec02
    @  7, 15 PROMPT Menu1->Exec03
    @  8, 15 PROMPT Menu1->Exec04
    @  9, 15 PROMPT Menu1->Exec05
    @ 10, 15 PROMPT Menu1->Exec06
    @ 11, 15 PROMPT Menu1->Exec07
    @ 12, 15 PROMPT Menu1->Exec08
    @ 13, 15 PROMPT Menu1->Exec09
    @ 14, 15 PROMPT Menu1->Exec10
    @ 15, 15 PROMPT Menu1->Exec11
    @ 16, 15 PROMPT Menu1->Exec12
    @ 17, 15 PROMPT Menu1->Exec13
    @ 18, 15 PROMPT Menu1->Exec14
    @ 20, 15 PROMPT "[          ]"
    @ 20, 28 SAY Trim( Message->Mess12 )
    MENU TO mchoice
    SELECT Name
    DO CASE
    CASE mchoice == 1
        mexec := SubStr( Menu1->Exec01, 1, 4 )
    CASE mchoice == 2
        mexec := SubStr( Menu1->Exec02, 1, 4 )
    CASE mchoice == 3
        mexec := SubStr( Menu1->Exec03, 1, 4 )
    CASE mchoice == 4
        mexec := SubStr( Menu1->Exec04, 1, 4 )
    CASE mchoice == 5
        mexec := SubStr( Menu1->Exec05, 1, 4 )
    CASE mchoice == 6
        mexec := SubStr( Menu1->Exec06, 1, 4 )
    CASE mchoice == 7
        mexec := SubStr( Menu1->Exec07, 1, 4 )
    CASE mchoice == 8
        mexec := SubStr( Menu1->Exec08, 1, 4 )
    CASE mchoice == 9
        mexec := SubStr( Menu1->Exec09, 1, 4 )
    CASE mchoice == 10
        mexec := SubStr( Menu1->Exec10, 1, 4 )
    CASE mchoice == 11
        mexec := SubStr( Menu1->Exec11, 1, 4 )
    CASE mchoice == 12
        mexec := SubStr( Menu1->Exec12, 1, 4 )
    CASE mchoice == 13
        mexec := SubStr( Menu1->Exec13, 1, 4 )
    CASE mchoice == 14
        mexec := SubStr( Menu1->Exec14, 1, 4 )
    CASE mchoice == 15
        mexec := Space( 4 )
    ENDCASE
    msale   := Space( 4 )
    mchoice := 1
    @  5, 45 PROMPT Menu1->Mess01
    @  6, 45 PROMPT Menu1->Mess02
    @  7, 45 PROMPT Menu1->Mess03
    @  8, 45 PROMPT Menu1->Mess04
    @  9, 45 PROMPT Menu1->Mess05
    @ 10, 45 PROMPT Menu1->Mess06
    @ 11, 45 PROMPT Menu1->Mess07
    @ 12, 45 PROMPT Menu1->Mess08
    @ 13, 45 PROMPT Menu1->Mess09
    @ 14, 45 PROMPT Menu1->Mess10
    @ 15, 45 PROMPT Menu1->Mess11
    @ 16, 45 PROMPT Menu1->Mess12
    @ 17, 45 PROMPT Menu1->Mess13
    @ 18, 45 PROMPT Menu1->Mess14
    @ 20, 45 PROMPT "[          ]"
    @ 20, 58 SAY Trim( Message->Mess12 )
    MENU TO mchoice
    DO CASE
    CASE mchoice == 1
        msale := SubStr( Menu1->Mess01, 1, 4 )
    CASE mchoice == 2
        msale := SubStr( Menu1->Mess02, 1, 4 )
    CASE mchoice == 3
        msale := SubStr( Menu1->Mess03, 1, 4 )
    CASE mchoice == 4
        msale := SubStr( Menu1->Mess04, 1, 4 )
    CASE mchoice == 5
        msale := SubStr( Menu1->Mess05, 1, 4 )
    CASE mchoice == 6
        msale := SubStr( Menu1->Mess06, 1, 4 )
    CASE mchoice == 7
        msale := SubStr( Menu1->Mess07, 1, 4 )
    CASE mchoice == 8
        msale := SubStr( Menu1->Mess08, 1, 4 )
    CASE mchoice == 9
        msale := SubStr( Menu1->Mess09, 1, 4 )
    CASE mchoice == 10
        msale := SubStr( Menu1->Mess10, 1, 4 )
    CASE mchoice == 11
        msale := SubStr( Menu1->Mess11, 1, 4 )
    CASE mchoice == 12
        msale := SubStr( Menu1->Mess12, 1, 4 )
    CASE mchoice == 13
        msale := SubStr( Menu1->Mess13, 1, 4 )
    CASE mchoice == 14
        msale := SubStr( Menu1->Mess14, 1, 4 )
    CASE mchoice == 15
        msale := Space( 4 )
    ENDCASE
    mclass := "C8"
    @ 22, 8 SAY "Select Class ie C3,C6,C8" GET mclass PICTURE "!!"
    @ 22, Col() + 2 SAY "Blank for All"
    READ

    nl     := 2
    npl    := 54
    msize  := "N"
    mwhere := "S"

    Printsel()                                     // _LF_INIT

    Scroll()

    SELECT Name
    GOTO TOP
    DO WHILE Name->( !Eof() )
        IF mclass != "  "
            IF SubStr( Name->Codeno, 3, 2 ) != mclass
                SKIP ALIAS Name
                LOOP
            ENDIF
        ENDIF
        IF msale != Space( 4 )
            IF Name->Sale != msale
                SKIP ALIAS Name
                LOOP
            ENDIF
        ENDIF
        IF mexec != Space( 4 )
            IF Name->Exec != mexec
                SKIP ALIAS Name
                LOOP
            ENDIF
        ENDIF
        @ nl, 0 SAY Name->Codeno
        @ nl, 10 SAY Name->Title
        @ nl, 16 SAY Name->Name
        // *** +" _______________________________"
        nl++
        SELECT Name
        IF nl > npl
            IF mwhere == "P"
                EJECT
            ELSE
                WAIT
                Scroll()
            ENDIF
            nl := 2
        ENDIF
        SELECT Name
        SKIP ALIAS Name
    ENDDO
    IF mwhere == "P"
        EndPrint()
        SET MARGIN TO 0
    ELSE
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
    ENDIF

    RETURN NIL

// **** End of SBSList()

// **---------------------------------------------------------------------------

FUNCTION Jsheet( mcodeno )
    local discountAmount
    
    cbranchId := Space( 2 )
    minvno := Space( 6 )
    SELECT Debit
    SET ORDER TO 1
    GOTO TOP
    SEEK mcodeno
    IF LastRec() != 0
        aPart_ := {}
        nrecno := 0
        namnt := 0
        DO WHILE Debit->Codeno = mcodeno .AND. Debit->( !Eof() )
            SELECT Name
            SEEK Debit->Codeno
            SELECT Debit
            AAdd( aPart_, Debit->Invno + " " + Name->Name;
                + " " + DToC( Debit->Dbdate ) + " " + Debit->BranchId;
                + " " + Str( Debit->Amount ) + " " + Debit->Saleno;
                + " " + Debit->PayType;
                + "        " + Str( RecNo(), 6 ) )
            SKIP ALIAS Debit
        ENDDO
        IF !Empty( aPart_ )
            Scroll(   3, 0, 24, 80 )
            DispBox(  3, 1, 21, 79, 2 )
            ASort( aPart_,,, {| x, y | x < y } )
            anum   := AChoice(  4, 4, 20, 76, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
            nrecno := Val( Right( aPart_[ anum ], 6 ) )
            SELECT Debit
            GOTO nrecno
            minvno  := Debit->Invno
        ENDIF
    ENDIF
    // ** ENDIF                   // minvno SPACE
    // ** IF minvno = SPACE( 6 )
    Scroll(  22, 0, 24, 80 )
    DispBox( 22, 1, 24, 79, 2 )
    @ 23, 10      SAY "Select/Add New J/C" GET minvno PICTURE "@KX"
    @ 23, Col() + 2 SAY "Blank for New J/C"
    READ
    // **      SELECT Debit
    // **      SET ORDER TO 2
    // **      SEEK minvno
    // **      SET ORDER TO 1
    // **  ENDIF                            // minvno
    IF minvno == Space( 6 )      // .OR. !FOUND()
        SELECT Debit
        ApFLock( 3 )
        APPEND BLANK
        Debit->Stat   := "J"
        Debit->Codeno := Name->Codeno
        Debit->Invno  := Str( Control->LastIvc, 6, 0 )
        Debit->DBDate := Date()
        UNLOCK
        SELECT Control
        ApRLock( 3 )
        Control->LastIvc := Control->LastIvc + 1
        UNLOCK
        SELECT Debit
    ENDIF
    minvno := Debit->Invno
    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        SELECT Name
        SEEK Debit->Codeno
        // **   mcodeno := Name->Codeno
        Scroll()
        DispBox(  0, 5, 2, 75, 2 )
        @  1, 10 SAY Name->Name + "  " + Debit->Invno    // minvno
        Scroll(   3, 0, 24, 80 )
        DispBox( 22, 1, 24, 79, 2 )
        nselect := 1
        @ 23, 7      PROMPT "Add Labour"
        @ 23, Col() + 2 PROMPT "Add Desc to Part"
        @ 23, Col() + 2 PROMPT "Edit J/C"
        @ 23, Col() + 2 PROMPT "Print Work"
        @ 23, Col() + 2 PROMPT "Print J/C"
        @ 23, Col() + 2 PROMPT "Inv/Job"
        MENU TO nselect
        DO CASE
        CASE PressedEsc()
            mcontinue := "N"
            RETURN NIL
        CASE nselect == 1
            IvcLabour()                              // Below
            mcontinue := "Y"
            LOOP
        CASE nselect == 2
            aPart_ := {}
            nivcTotal := 0
            SELECT Invoice
            SET ORDER TO 2                              // Invno+PartId+Partnum
            SEEK minvno
            IF Found()
                DO WHILE Invoice->Invno == minvno .AND. Invoice->( !Eof() )
                    SELECT Part
                    SEEK Invoice->Partnum
                    SELECT Invoice
                    mA := ( ( discountAmount * 100 ) / 100 ) * Invoice->Qty
                    AAdd( aPart_, SubStr( Invoice->Partnum,1,7 );
                        + " " + SubStr( Part->Desc, 1, 22 ) + " " + Str( Invoice->Qty, 7 );
                        + " " + Str( Invoice->Amount, 8, 2 ) + " " + Str( Invoice->Discount );
                        + "%" + Str( mA, 8, 2 ) + " " + DToC( Invoice->PDate );
                        + "           " + Str( RecNo(), 6 ) )
                    discountAmount := Invoice->Amount * ( 1 -Invoice->Discount / 100 )
                    nivcTotal := ( nivcTotal + ( ( discountAmount * 100 ) / 100 )*Invoice->Qty )
                    SKIP ALIAS Invoice
                ENDDO
                SET ORDER TO 1                  // Invno+Partnum
                // ** ENDIF                       // LastRec != 0
                SELECT Name
                SEEK mcodeno
                Scroll()
                DispBox( 0, 1, 2, 79, 2 )
                @  1, 3      SAY mcodeno + " " + Trim( Name->Name )
                @  1, Col() + 1 SAY "Invoice " + minvno + " less GST"
                @  1, Col() + 1 SAY nivcTotal PICTURE "$999,999.99" COLOR "G+"
                DispBox( 3, 1, 20, 79, 2 )
                IF !Empty( aPart_ )
                    ASort( aPart_,,, {| x, y | x < y } )
                    anum := AChoice( 4, 3, 20, 77, aPart_,, "AFUNC" )
                ENDIF
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
            ENDIF  // Found
            mpartnum := Invoice->Partnum
            PartOper2( mpartnum )
            SELECT Labour
            ApFLock( 3 )
            APPEND BLANK
            Labour->Labno  := mcodeno                  // Try This
            // **  TRIM( Invoice->Invno )+LTRIM( STR( RECNO() ) )
            Labour->Codeno  := Name->Codeno
            Labour->Operno  := PartOper->Operno
            Labour->Jobnum  := Invoice->Invno
            Labour->Desc    := PartOper->Desc
            Labour->Time    := PartOper->Time
            Labour->Rate    := PartOper->Rate
            Labour->Date    := Date()
            // *** ?????         Labour->Partnum := Part->Partnum
            UNLOCK
            mcontinue := "Y"
            LOOP

        CASE nselect == 3
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 1, 19, 79, 2 )
            SELECT Debit
            @  4, 60 SAY Debit->Invno
            mcorrect := "N"
            DO WHILE mcorrect == "N"
                ApRLock( 3 )
                @  4, 10 SAY "  Equip :"    GET Debit->Equip PICTURE "!!"
                @  4, 30 SAY "Workshop or Outside :" GET Debit->Ws PICTURE "!!"
                @  6, 10 SAY "  Brand :"    GET Debit->Brand PICTURE "!XXXXXXXXXXXXXXXXXXX"
                @  8, 10 SAY "  Fault :"    GET Debit->Fault PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                @ 10, 10 SAY "Message :"    GET Debit->MESSAGE PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                @ 12, 10 SAY "Reference"    GET Debit->Est   PICTURE "@X"
                @ 14, 10 SAY "Invoice #"    GET Debit->Invno PICTURE "@!"
                Debit->Dbdate := Date()
                @ 14, Col() + 2 SAY "Date "       GET Debit->Dbdate PICTURE "99/99/9999"
                @ 16, 10      SAY "Ordnum "     GET Debit->Ordnum PICTURE "@X"
                @ 16, Col() + 2 SAY "I=Inv W=W/B" GET Debit->STAT   PICTURE "@!"
                READ
                UNLOCK
                mcorrect := ApGetY( Message->Correct )
            ENDDO
            mcontinue := "Y"
            LOOP

        CASE nselect == 4
            mwhere := "P"
            // ***          WBOPerInd()
            mcontinue := "Y"
            LOOP
        CASE nselect == 5
            Namepjs( mcodeno )                             // Below
            mcontinue := "Y"
            LOOP
        CASE nselect == 6
            // **          WBIvcQTot()                     // Below
            mcontinue := "Y"
            LOOP
        ENDCASE
    ENDDO                           // mcontinue

    RETURN mcodeno

// **** End of Jsheet()

// **---------------------------------------------------------------------------

FUNCTION BranchFind( mcodeno )

    IF LastRec() != 0
        aPart_ := {}
        nrecno := 0
        DO WHILE Branch->Codeno = mcodeno .AND. Branch->( !Eof() )
            AAdd( aPart_, Branch->BranchId + "  " + Branch->Name;
                + "  " + Branch->Add4 + " " + Branch->Phone;
                + "     " + Str( RecNo(), 6 ) )
            SKIP ALIAS Branch
        ENDDO
        Scroll(  3, 0, 24, 80 )
        DispBox( 3, 1, 24, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 3, 23, 77, aPart_,, "AFUNC" )
            mpartdes := aPart_[ anum ]
            nrecno   := Val( Right( mpartdes,6 ) )
            GOTO nrecno
            cbranchid := Branch->BranchId
            Scroll(  17, 0, 24, 80 )
            DispBox( 17, 1, 19, 79, 2 )
            @ 18, 10 SAY Branch->Name + " " + Branch->Add4;
                + " " + Branch->BranchId COLOR "G+"
        ENDIF
    ENDIF             // LASTREC()

    RETURN cbranchId

// *-------------------------------------------------------------------

FUNCTION Numchange()

    mcodeno := moldcode := Space( 8 )
    // ** mdelete, mchange, mok, mcontinue

    mcontinue := mok := "Y"
    DO WHILE mcontinue = "Y"

        NameRank( @mcodeno )                      // Above

        mcodeno := Name->Codeno
        Scroll(  12, 0, 24, 80 )
        DispBox( 12, 1, 19, 79, 2 )
        @ 14, 10 SAY Name->Codeno + " " + Name->Name
        @ 15, 10 SAY Trim( Name->Add1 ) + " " + Name->Add2
        mdelete := ApGetN( Trim( Message->Delete ) + " This Name" )
        IF mdelete == "Y"
            @ 16, 10 SAY "ONLY Some Files Deleted BEWARE"
            @ 17, 10 SAY "MUST DISCONNECT FROM NETWORK "
            mdelete := ApGetN( Message->SureDel )
            IF mdelete == "Y"
                SELECT Name
                ApRLock( 3 )
                DELETE
                UNLOCK
                // ******************
                CLOSE DATABASES
                USE Branch
                DELETE ALL FOR Codeno = mcodeno
                USE Credit
                DELETE ALL FOR Codeno = mcodeno
                USE Debit
                DELETE ALL FOR Codeno = mcodeno
                USE Hist
                DELETE ALL FOR Codeno = mcodeno
                USE Invoice
                DELETE ALL FOR Codeno = mcodeno
                // ** USE PartSer
                // ** DELETE ALL FOR Codeno = mcodeno
                USE Quot
                DELETE ALL FOR Codeno = mcodeno
                USE Supl
                DELETE ALL FOR Codeno = mcodeno
                USE Orders
                DELETE ALL FOR Codeno = mcodeno
                USE Rept
                DELETE ALL FOR Codeno = mcodeno
                USE Cusnotes
                DELETE ALL FOR Code_Ref = mcodeno
                DELETE ALL FOR SubStr( Code_Ref, 4, 8 ) = mcodeno

                DBFReIndx()
                XF_DBFUse()
                // **         QuotStk()            // Update Orders
                RETURN NIL
            ENDIF
        ENDIF
        mchange := ApGetN( "Change Code number" )
        IF mchange == "N"
            RETURN NIL
        ENDIF
        IF mchange == "Y"
            Scroll( 16, 0, 24, 80 )
            @ 16, 10 SAY "MUST DISCONNECT FROM NETWORK "
            moldcode := mcodeno
            @ 20, 5 SAY mcodeno + "  " + "New Code Number = " GET mcodeno PICTURE "@!"
            READ
            IF PressedEsc()
                RETURN NIL
            ENDIF
            SELECT Name
            SEEK mcodeno
            DO WHILE Found()
                @ 22, 5 SAY "All ready exists  Esc To Quit" GET mcodeno PICTURE "@!"
                READ
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                SEEK mcodeno
            ENDDO
            SELECT Name
            SEEK moldcode
            ApRLock( 3 )
            Name->Codeno := mcodeno
            UNLOCK

            @ 23, 10 SAY "Old " + moldcode + " New " + mcodeno + " PLEASE WAIT"

            CLOSE DATABASES

            USE Branch
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE Credit
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE CusNotes INDEX Cusnotes
            SEEK moldcode
            DO WHILE Found()
                @  22, 50 SAY "Changing Cusnotes File      "
                ncode := SubStr( Cusnotes->Code_Ref, 9, 2 )
                Cusnotes->Code_Ref := SubStr( mcodeno, 1, 8 ) + ncode
                SEEK moldcode
            ENDDO
            USE Debit
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE DebProf
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE Hist
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE Invoice
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE Part
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE PartSer
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE Pay
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE Pmppjnl
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE Prof
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE Quot
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE Rec
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE Rept
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            REPLACE ALL CodeRecno WITH SubStr( mcodeno, 1, 8 ) + Str( RecNo(), 4 );
                FOR Codeno = moldcode + Str( RecNo(), 4 )
            USE Supl
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode
            USE Orders
            REPLACE ALL Codeno WITH mcodeno FOR Codeno = moldcode

        ENDIF                              // mchange
        mcontinue := "N"

    ENDDO                               // mcontinue

    DBFReIndx()
    XF_DBFUse()
    // **  QuotStk()                       // Update Order

    RETURN NIL

// *******----  End Numchange()

// *-------------------------------------------------------------------

FUNCTION Branchadd( mcodeno )

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        tempscr := SaveScreen(  3, 0, 24, 80 )
        cbranchId := Space( 2 )
        SELECT Branch
        SEEK mcodeno
        IF Found()

            BranchFind( mcodeno, )
            cbranchId := Branch->BranchId
        ENDIF
        Scroll( 21, 0, 24, 80 )
        @ 22, 10 SAY "Edit or Add Branch :" GET cbranchId PICTURE "@!"
        @ 22, Col() + 2 SAY "Blank to Delete Esc to Exit"
        READ
        IF PressedEsc()
            RestScreen( 3, 0, 24, 80, tempscr )
            RETURN NIL
        ENDIF
        IF cbranchId == Space( 2 )
            Scroll( 19, 0, 24, 80 )
            cstring := Trim( Message->Suredel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
                RestScreen( 3, 0, 24, 80, tempscr )
                RETURN NIL
            ENDIF
            IF mok == "Y"
                SELECT Branch
                ApRLock( 3 )
                DELETE
                UNLOCK
            ENDIF
            LOOP
        ENDIF
        Scroll(  3, 0, 24, 80 )
        DispBox( 3, 1, 19, 79, 2 )
        mcorrect := "N"
        DO WHILE mcorrect == "N"
            SELECT Branch
            SEEK mcodeno + cbranchId
            ApFLock( 3 )
            IF !Found()
                APPEND BLANK
                Branch->BranchId := cbranchId
                Branch->Codeno   := mcodeno
            ENDIF
            @  6, 14 SAY "Branch :"         GET Branch->Name     PICTURE "@!"
            @  6, Col() + 2 SAY "Branch Id :" GET Branch->BranchId PICTURE "@!"
            @  8, 10 SAY "Contact    :"     GET Branch->Contact  PICTURE "@X"
            @ 10, 10 SAY "Deliver To :"     GET Branch->Add1     PICTURE "@X"
            @ 11, 13 SAY "P.O.Box :"        GET Branch->Add2     PICTURE "@X"
            @ 12, 21 SAY ":"                GET Branch->Add3     PICTURE "@X"
            @ 13, 16 SAY "City :"           GET Branch->Add4     PICTURE "@X"
            @ 14, 16 SAY "Cntr :"           GET Branch->Add5     PICTURE "@!"
            @ 16, 10 SAY "Bus Phone  :"     GET Branch->Phone    PICTURE "@X"
            @ 16, Col() + 3 SAY "Fax :"       GET Branch->Bphone   PICTURE "@X"
            // **      @ 18,10 SAY "Freight Co :"  GET Branch->Freight  PICTURE "@X"
            READ
            UNLOCK
            mcorrect := ApGetY( Message->Correct )
        ENDDO                                            // mcorrect
        mcontinue := ApGetN( Message->Another + "Branch" )
        RestScreen( 3, 0, 24, 80, tempscr )
    ENDDO                                               // mcontinue

    RETURN mcodeno

// **----  End of BranchAdd()

// *-------------------------------------------------------------------

FUNCTION Branchshow( mcodeno )

    SELECT Branch
    GOTO TOP
    IF LastRec() != 0
        aPart_ := {}
        SEEK mcodeno
        DO WHILE Branch->Codeno = mcodeno .AND. Branch->( !Eof() )
            AAdd( aPart_, Branch->BranchId + " " + Branch->Name;
                + " " + Branch->Add4 + " " + Branch->Phone )
            SKIP ALIAS Branch
        ENDDO
        Scroll(  3, 0, 24, 80 )
        DispBox( 3, 1, 24, 79, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            @  3, 00 SAY " "
            AEval( aPart_, {|A| QOUT( " " + Chr( 186 ) + "  " ), QQOut( A ), Breakpoint() } )
            Inkey( 0 )
        ENDIF                  // Empty
    ENDIF             // LASTREC()

    RETURN mcodeno

// *------ End of BranchShow

// *-------------------------------------------------------------------

STATIC FUNCTION Namepjs( mcodeno )

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        Scroll( 4, 0, 22, 78 )
        mwhere := "S"
        npl    := 0
        nl := 0
        mwhere := "S"

        Printsel()                               // _LF_Init

        // **   mtype := "WORKSHOP"
        // **   IF Debit->Ws = "OS"
        // **      mtype := "OUTSIDE"
        // **   ENDIF
        SELECT Debit
        mjob := Space( 10 )
        DO CASE
        CASE Debit->Equip = "GW"
            mjob := "GARDEN WARE"
        CASE Debit->Equip = "EN"
            mjob := "ENGINEERING"
        CASE Debit->Equip = "TV"
            mjob := "TELEVISION"
        CASE Debit->Equip = "AE"
            mjob := "AERIAL"
        ENDCASE
        @ nl, 0 SAY Control->U_Name
        @ nl, 60 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        nl++
        @ nl, 24 SAY mjob + " Way Bill J/C # " + Debit->Invno
        nl++
        SELECT Name
        @ nl, 0 SAY Name->Name
        nl++
        @ nl, 0 SAY Name->Add1
        nl++
        IF Name->Add3 != "     "
            @ nl, 0 SAY Name->Add2
            nl++
        ENDIF
        IF Name->Add3 != "     "
            @ nl, 0 SAY Name->Add3
            nl++
        ENDIF
        @ nl, 0 SAY Name->Add4 + " Bus Ph " + Name->Phone + "                " + Name->Codeno
        nl++
        @ nl, 0 SAY Name->Add5
        nl++
        @ nl, 12 SAY ":  " + Debit->Brand + Space( 20 ) + "O/N " + Debit->Ordnum
        nl++
        @ nl, 12 SAY ":  " + Debit->Fault
        nl++
        @ nl, 0 SAY "Message     :  " + Debit->Message
        nl += 2
        ncost := 0
        SELECT Labour
        GOTO TOP
        DO WHILE Labour->( !Eof() )
            IF Labour->Invno != Debit->Invno
                SKIP ALIAS Labour
                LOOP
            ENDIF
            IF Labour->Labno != Debit->Codeno          // This is the Invoice Code
                SKIP ALIAS Labour
                LOOP
            ENDIF
            ncost += Labour->Time * Labour->Rate
            @ nl, 0 SAY Labour->Codeno + " " + Labour->Desc;
                + " " + Str( Labour->Time, 8, 2 ) + "  " + Str( Labour->Rate, 8, 2 )
            SKIP ALIAS Labour
            nl++
        ENDDO
        IF ncost > 0
            nl++
            @ nl, 10 SAY "Labour Costs " + Str( ncost, 9, 2 )
        ENDIF
        nl += 2
        @ nl, 0 SAY "Qty   MATERIALS        Qty WB    DATE    HOURS   LABOUR    W/B    STAFF"
        nl++
        npl := nl
        nline = 1
        FOR nline = 1 TO ( 38 -npl )
            @ nl, 0 SAY "____:________________:________   _______:______:_________________:________"
            nl += 2
        NEXT
        IF mwhere = "S"
            Inkey( 0 )
            Scroll()
            nl := 0
        ENDIF
        nl++
   /*
      @ nl,48 SAY "Sub Total _______________"
      nl+=2
      @ nl,30 SAY Control->U_Gstno+" Plus G.S.T _______________"
      nl+=2
      @ nl,42 SAY "Job Sheet Total _______________"
      nl++
   */
        IF mwhere == "P"
            EndPrint()
        ELSE
            WAIT
        ENDIF
        Scroll( 18, 0, 24, 80 )
        mcontinue := ApGetN( Message->Another + "Print" )
    ENDDO
    // ** SELECT Name
    // ** SEEK Debit->Codeno

    RETURN mcodeno

// ****** End of Namepjs()

// *-------------------------------------------------------------------

FUNCTION RepSheet( mcodeno )

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        mspelldate := Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + Str( Year( Date() ), 5 )
        Scroll( 3, 0, 22, 78 )
        mwhere := "S"
        npl    := 0

        Printsel()                               // _LF_Init

        nl := 0
        @ nl, 0 SAY Control->U_Name + "                 " + mspelldate
        nl += 2
        SELECT Name
        @ nl, 0 SAY Name->Name
        SELECT CusNotes
        nl += 2
        cdetail := ""
        coderef := mcodeno
        SEEK coderef
        Getdets( coderef )                           // XF_Memo2
        FormP( cdetail, 60, 10 )                       // XF_Memo2
        SELECT Name
        coderef := Space( 21 )
        nl += 2
        FOR nline := 1 TO 6
            @ nl, 0 SAY Replicate( "_", 75 )
            nl += 2
        NEXT
        SELECT Quot
        SEEK mcodeno
        IF Found()
            IF mwhere == "P"
                nl := 30
            ELSE
                Scroll( 12, 0, 24, 80 )
                nl := 14
            ENDIF
            DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !Eof() )
                @ nl, 0 SAY Quot->Qty PICTURE "99,999"
                @ nl, 10 SAY Quot->Partnum
                @ nl, 37 SAY Quot->Dbdate
                @ nl, 47 SAY Quot->BranchId
                @ nl, 52 SAY Quot->Ordnum
                @ nl, 68 SAY Quot->Faxno
                IF Quot->Info != Space( 20 )
                    nl++
                    @ nl, 22 SAY Quot->Info
                ENDIF
                ApRLock( 3 )
                coderef := Quot->Ordnum
                UNLOCK
                SKIP ALIAS Quot
                nl++
            ENDDO
            SELECT CusNotes
            cdetail := ""
            SEEK coderef
            IF Found()
                nl =+ 2
                Getdets( coderef )                           // XF_Memo2
                FormP( cdetail, 60, 10 )                       // XF_Memo2
            ENDIF                       // Found()
        ENDIF
        IF mwhere == "P"
            EndPrint()
        ELSE
            WAIT
        ENDIF
        Scroll( 18, 0, 24, 80 )
        mcontinue := ApGetN( Message->Another + "Print" )
    ENDDO

    RETURN mcodeno

// ****** End of RepSheet()

// ***----------------   END OF FILE ZSF_NAME.PRG
