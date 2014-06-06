// ** JoKir10   16-10-11 18:50:37

/*
   Program.....:                  XLF_NOTE.PRG
   Authors.....: LCP, J.Kirby
   Date........: 11/03/1995
   Functions...: RenameLoc, NewLocate, MenuSyst
   Static funcs: KirbyUpdate, Update, EquUpdate, JCQU,
                 Part16, NoteAdd, NoteList
   Not used....: MenuMet, MenuNote
*/

STATIC FUNCTION KirbyUpdate()

    mok := "Y"
    DO WHILE mok == "Y"
        Scroll()
        mok := ApGetN( "Report Delete" )
        IF mok = "Y"
            ndate := 999
            mcodeno := "DAILYFRE"
            @ 2, 10        SAY "Codeno" GET mcodeno PICTURE "@!"
            @ 2, Col() + 2 SAY "How many days Back from today" GET ndate PICTURE "999"
            READ
            nl := 3
            npl := 22
            nparttotal := 0
            SELECT Rept
            GOTO TOP
            ApFLock( 3 )
            DO WHILE Rept->( !Eof() )
                IF nl > npl
                    WAIT
                    Scroll()
                    nl := 3
                ENDIF
                IF Rept->Codeno != mcodeno
                    SKIP ALIAS Rept
                    LOOP
                ENDIF
                IF Rept->Date < Date() -ndate
                    @ nl, 3      SAY Rept->Codeno
                    @ nl, Col() + 2 SAY Rept->Date
                    @ nl, Col() + 2 SAY Rept->Info
                    @ nl, Col() + 2 SAY nparttotal PICTURE "999"
                    nl++
                    nparttotal += 1
                    DELETE
                ELSE
                    @ nl, 10      SAY "NO Reports below Today less"
                    @ nl, Col() + 2 SAY ndate PICTURE "999"
                ENDIF
                SKIP ALIAS Rept
            ENDDO   // Rept
            IF PressedEsc()
                RETURN NIL
            ENDIF
        ENDIF    // mok
        mok := ApGetN( "Check Unit Qty" )
        IF mok = "Y"
            nPartTotal := nLocTotal := 0
            Scroll()
            DispBox(  0, 1, 24, 79, 2 )
            @  2, 10 SAY "    "
            munit := Space( 10 )
            @ 4, 8      PROMPT "Each  "
            @ 4, Col() + 2 PROMPT "Mtr   "
            @ 4, Col() + 2 PROMPT "Sq Mtr"
            MENU TO nselect
            DO CASE
            CASE nselect == 1
                munit := "Each"
            CASE nselect == 2
                munit := "Mtr"
            CASE nselect == 3
                munit := "Sq Mtr"
            ENDCASE
            @  6, 10 SAY "Select Unit" GET munit PICTURE "XXXXXXXXXX"
            READ
            nl := 3
            npl := 22
            nparttotal := 0
            SELECT Part
            SET ORDER TO 1    // Partnum
            GOTO TOP
            Scroll()
            DO WHILE Part->( !Eof() )
                IF Part->Unit != munit
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF nl > npl
                    WAIT
                    Scroll()
                    nl := 3
                ENDIF
                @ nl, 2 SAY Part->Unit + " " + Part->Desc
                nl++
                @ nl, 2      SAY Part->Partnum
                @ nl, Col() + 2 SAY "Width"
                @ nl, Col() + 1 SAY Part->Width   PICTURE "999999.999"
                @ nl, Col() + 2 SAY "Length"
                @ nl, Col() + 1 SAY Part->Length  PICTURE "999999.999"
                @ nl, Col() + 2 SAY "Instock"
                @ nl, Col() + 1 SAY Part->Instock PICTURE "99,999.999"
                nl++
                nparttotal += 1
                SKIP ALIAS Part
            ENDDO
            nl += 2
            @ nl, 12      SAY "Total Parts"
            @ nl, Col() + 2 SAY nPartTotal PICTURE "999,999.99"
            nl += 2
            @ nl, 3 SAY " "
            WAIT
            IF PressedEsc()
                RETURN NIL
            ENDIF
        ENDIF  // mok
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
        mok := "N"
    ENDDO
    SET ORDER TO 1

    RETURN NIL

// ***------  End KirbyUpdate()

// **-----------------------------------------------------------------------

FUNCTION RenameLoc()

    mok := "Y"
    DO WHILE mok == "Y"
        nPartTotal := nLocTotal := 0
        Scroll()
        DispBox(  0, 1, 24, 79, 2 )
        SELECT Part
        SET ORDER TO 4                // Locate
        GOTO TOP
        Scroll()
        aPart_ := {}
        nrecno  := 0
        clocate := Space( 16 )
        DO WHILE Part->( !Eof() )
            IF Part->Locate = clocate
                SKIP ALIAS Part
                LOOP
            ENDIF
            IF Part->Locate = Space( 16 )
                SKIP ALIAS Part
                LOOP
            ENDIF
            AAdd( aPart_, Part->Locate;
                + " " + Part->LocDesc;
                + "           " + Str( RecNo(), 6 ) )
            clocate := Part->Locate
            SKIP ALIAS Part
        ENDDO
        DispBox(  0, 0, 24, 52, 2 )
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice(  1, 3, 23, 50, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
        ENDIF
        Scroll()
        DispBox(  0, 1, 24, 79, 2 )
        clocorg  := Part->Locate
        clocate  := Part->Locate
        cLocdesc := Part->Locdesc
        @  2, 10 SAY "Changing Part Location " PICTURE "!!!!"
        @  4, 8 SAY "Can use any Characters for Locate or Desc"
        @  6, 8 SAY "    New Locate" GET clocate  PICTURE "@!"
        @  8, 8 SAY "Desc Location " GET clocdesc PICTURE "@!"
        READ
        Scroll()
        DispBox(  0, 1, 24, 79, 2 )
        SELECT Part
        SET ORDER TO 1                // 4 = Locate + Partnum
        GOTO TOP
        npl := 22
        nl  := 1
        DO WHILE Part->( !Eof() )
            nPartTotal += 1
            IF Part->Locate != clocorg
                SKIP ALIAS Part
                LOOP
            ENDIF
            nLocTotal += 1
            @ nl, 2 SAY SubStr( Part->Partnum, 1, 16 ) + " " + Part->Locate
            ApRLock( 3 )
            Part->Locate  := clocate
            Part->Locdesc := clocdesc
            UNLOCK
            @ nl, 35 SAY Part->Locate + " " + Part->LocDesc
            nl++
            IF nl > npl
                nl++
                @ nl, 3 SAY " "
                WAIT
                Scroll()
                DispBox(  0, 1, 24, 79, 2 )
                nl := 1
            ENDIF
            SKIP ALIAS Part
        ENDDO
        nl++
        @ nl, 6      SAY "Qty Locate"
        @ nl, Col() + 2 SAY nLocTotal  PICTURE "99,999.99"
        @ nl, Col() + 3 SAY "Total Parts"
        @ nl, Col() + 2 SAY nPartTotal PICTURE "99,999.99"
        nl += 2
        @ nl, 3 SAY " "
        WAIT
        mok := "N"
        DO WHILE mok = "N"
            mok := ApReadN()
        ENDDO
        mok := ApGetN( Trim( Message->Another ) + " Location" )
    ENDDO
    SET ORDER TO 1

    RETURN NIL

// **-----------------------------------------------------------------------

FUNCTION NewLocate()

    mok := "Y"
    DO WHILE mok == "Y"
        Scroll()
        nPartTotal := nLocTotal := 0
        mchar := Space( 4 )
        DispBox(  0, 1, 14, 79, 2 )
        @  2, 10 SAY "Change Part Location"
        @  4, 8 SAY "Part First 2, 3 or 4 Char" GET mchar PICTURE "!!!!"
        READ
        IF PressedEsc()
            RETURN NIL
        ENDIF
        Scroll()
        DispBox(  0, 1, 24, 79, 2 )
        SELECT Part
        SET ORDER TO 4                // Locate + Partnum
        GOTO TOP
        npl := 22
        nl  := 1
        DO WHILE Part->( !Eof() )
            nPartTotal += 1
            DO CASE
            CASE SubStr( mchar, 3, 2 ) = "  "
                IF SubStr( Part->Partnum, 1, 2 ) != SubStr( mchar, 1, 2 )
                    SKIP ALIAS Part
                    LOOP
                ENDIF
            CASE SubStr( mchar, 4, 1 ) = " "
                IF SubStr( Part->Partnum, 1, 3 ) != SubStr( mchar, 1, 3 )
                    SKIP ALIAS Part
                    LOOP
                ENDIF
            CASE SubStr( Part->Partnum, 1, 4 ) != SubStr( mchar, 1, 4 )
                SKIP ALIAS Part
                LOOP
            ENDCASE
            nLocTotal += 1
            @ nl, 2 SAY SubStr( Part->Partnum, 1, 16 ) + " " + Trim( Part->Locate );
                + " " + Trim( Part->LocDesc ) + " " + Part->Desc
            nl++
            IF nl > npl
                nl++
                @ nl, 3 SAY " "
                WAIT
                Scroll()
                DispBox(  0, 1, 24, 79, 2 )
                nl := 1
            ENDIF
            SKIP ALIAS Part
        ENDDO
        nl++
        @ nl, 6      SAY "Qty Locate"
        @ nl, Col() + 2 SAY nLocTotal  PICTURE "99,999.99"
        @ nl, Col() + 2 SAY "Total Parts"
        @ nl, Col() + 2 SAY nPartTotal PICTURE "99,999.99"
        nl += 2
        @ nl, 3 SAY " "
        WAIT
        nl := 1
        mok := ApGetN( "Change Part Location " + mchar )

        IF mok = "Y"
            nPartTotal := nLocTotal := 0
            Scroll()
            DispBox(  0, 1, 24, 79, 2 )
            @  2, 10 SAY "Correct Part Characters"
            @  4, 8 SAY "Part First 2, 3 or 4 Char" GET mchar PICTURE "!!!!"
            READ
            IF PressedEsc()
                RETURN NIL
            ENDIF
            SELECT Part
            SET ORDER TO 4                // Locate
            GOTO TOP
            Scroll()
            aPart_ := {}
            nrecno  := 0
            clocate := Space( 16 )
            DO WHILE Part->( !Eof() )
                IF Part->Locate = clocate
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF Part->Locate = Space( 16 )
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                AAdd( aPart_, Part->Locate;
                    + " " + Part->LocDesc;
                    + "           " + Str( RecNo(), 6 ) )
                clocate := Part->Locate
                SKIP ALIAS Part
            ENDDO
            DispBox(  0, 0, 24, 52, 2 )
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum := AChoice(  1, 3, 23, 50, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
                GOTO nrecno
            ENDIF
            Scroll()
            DispBox(  0, 1, 24, 79, 2 )
            clocate  := Part->Locate
            cLocdesc := Part->Locdesc
            @  2, 10 SAY "Changing Part Location " + mchar PICTURE "!!!!"
            @  4, 8 SAY "Can use any Characters for Locate or Desc"
            @  6, 8 SAY "        Locate" GET clocate  PICTURE "@!"
            @  8, 8 SAY "Desc Location " GET clocdesc PICTURE "@!"
            READ
            Scroll()
            DispBox(  0, 1, 24, 79, 2 )
            SELECT Part
            SET ORDER TO 1                // Locate + Partnum
            GOTO TOP
            npl := 22
            nl  := 1
            DO WHILE Part->( !Eof() )
                nPartTotal += 1
                DO CASE
                CASE SubStr( mchar, 3, 2 ) = "  "
                    IF SubStr( Part->Partnum, 1, 2 ) != SubStr( mchar, 1, 2 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE SubStr( mchar, 4, 1 ) = " "
                    IF SubStr( Part->Partnum, 1, 3 ) != SubStr( mchar, 1, 3 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE SubStr( Part->Partnum, 1, 4 ) != SubStr( mchar, 1, 4 )
                    SKIP ALIAS Part
                    LOOP
                ENDCASE
                SELECT Part
                nLocTotal += 1
                @ nl, 2 SAY SubStr( Part->Partnum, 1, 16 ) + " " + Part->Locate
                ApRLock( 3 )
                Part->Locate  := clocate
                Part->Locdesc := clocdesc
                UNLOCK
                @ nl, 35 SAY Part->Locate + " " + Part->LocDesc
                nl++
                IF nl > npl
                    nl++
                    @ nl, 3 SAY " "
                    WAIT
                    Scroll()
                    DispBox(  0, 1, 24, 79, 2 )
                    nl := 1
                ENDIF
                SKIP ALIAS Part
            ENDDO
            nl++
            @ nl, 6      SAY "Qty Locate"
            @ nl, Col() + 2 SAY nLocTotal  PICTURE "99,999.99"
            @ nl, Col() + 3 SAY "Total Parts"
            @ nl, Col() + 2 SAY nPartTotal PICTURE "99,999.99"
        ENDIF         // mok Change

        nl += 2
        @ nl, 3 SAY " "
        WAIT
        mok := ApGetN( "Print Labels " + mchar )

        IF mok = "Y"

            Printsel()                                  // _LF_Init

            IF mwhere == "P"
                npl := 44
            ELSE
                Scroll()
                npl := 22
            ENDIF
            nl := 1
            SELECT Part
            SET ORDER TO 4                // Locate+Partnum
            GOTO TOP
            Scroll()
            ngrandTotal := ntotal := ncatqty := npartstock := 0
            ntotalamount := ncatamount := nhistqty := 0
            DO WHILE Part->( !Eof() )
                ngrandtotal += 1
                DO CASE
                CASE SubStr( mchar, 3, 2 ) = "  "
                    IF SubStr( Part->Partnum, 1, 2 ) != SubStr( mchar, 1, 2 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE SubStr( mchar, 4, 1 ) = " "
                    IF SubStr( Part->Partnum, 1, 3 ) != SubStr( mchar, 1, 3 )
                        SKIP ALIAS Part
                        LOOP
                    ENDIF
                CASE SubStr( Part->Partnum, 1, 4 ) != SubStr( mchar, 1, 4 )
                    SKIP ALIAS Part
                    LOOP
                ENDCASE
                SELECT Hist
                SET ORDER TO 2
                mpartnum := Part->Partnum
                SEEK mpartnum
                nhistqty := 0
                DO WHILE Hist->Partnum = mpartnum .AND. Part->( !Eof() )
                    nhistqty += Hist->Qty
                    SKIP ALIAS Hist
                ENDDO
                SELECT Part
                IF nhistqty = 0
                    SKIP ALIAS Part
                    LOOP
                ENDIF
                IF nl > npl
                    nl := 2
                    IF mwhere == "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                ENDIF
                @ nl, 10 SAY Part->Desc
                nl += 2
                @ nl, 0 SAY SubStr( Part->Partnum, 1, 16 )
                nl += 2
                @ nl, 0 SAY Part->Locate
                @ nl, 20 SAY Part->LocDesc
                nl += 2
                @ nl, 0 SAY Part->Catno
                @ nl, 35 SAY Part->Trade PICTURE "$99,999.99"
                SELECT Cat
                SEEK Part->Catno
                nl++
                @ nl, 0 SAY Cat->CatDesc
                nl += 2
                @ nl, 0 SAY "Stk"
                @ nl, 9 SAY Part->Instock PICTURE "99,999.999"
                @ nl, 22 SAY Part->DATE    PICTURE "99/99/9999"
                @ nl, 34 SAY Part->Codeno
                nl += 2
                @ nl, 0 SAY "Instock ____________________ " + " Date __________ "
                nl += 2
                @ nl, 0 SAY Part->MinStk PICTURE "9,999.99"
                @ nl, 10 SAY "Minimum _______ "
                @ nl, 30 SAY "Used"
                @ nl, 35 SAY nhistqty PICTURE "99,999.99"
                IF Part->BoughtOut = "Y"
                    @ nl, 47 SAY "Bought Out"
                    ncatqty += 1
                    npartstock += Part->Instock
                    ncatamount += Part->Trade * Part->Instock
                ENDIF
                nl += 2
                SKIP ALIAS Part
            ENDDO
            nl += 2
            IF mwhere != "P"
                @ nl, 3 SAY " "
                WAIT
                mok := "N"
                DO WHILE mok = "N"
                    mok := ApReadN()
                ENDDO
            ELSE
                EndPrint()
                SET MARGIN TO 0
            ENDIF
        ENDIF   // Labels
        mok := ApGetN( Trim( Message->Another ) + " Print" )
    ENDDO
    SET ORDER TO 1

    RETURN NIL

// **-----------------------------------------------------------------------

STATIC FUNCTION Update()

    SAVE SCREEN TO holdscrn
    mselect := "JC-"
    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        @  2, 10 SAY "SUGGEST THAT YOU BACKUP FIRST" COLOR "RG+"
        @  4, 10 SAY "Deletes the Parts/Module NO DEBIT"
        nsel  := 1
        @  6, 10 PROMPT "Needs To REINDEX   for    3-4-5         "
        @  8, 10 PROMPT "1. Job Cards JC-                 Deletes"
        @ 10, 10 PROMPT "2. Quotes    QU-                 Deletes"
        @ 12, 10 PROMPT "3. 16 Char Update do this First  REINDEX"
        @ 14, 10 PROMPT "4. No Part In File Delete        REINDEX"
        @ 16, 10 PROMPT "5. Module Update                 REINDEX"
        @ 18, 10 PROMPT "6. Parts to New Location                "
        @ 20, 10 PROMPT "7. John Kirby Up Date DBF   FUTURE USE  "
        @ 22, 10 PROMPT "8. Exit                                 "
        MENU TO nsel
        DO CASE
        CASE nsel == 1
            LOOP
        CASE nsel == 9 .OR. PressedEsc()
            RETURN NIL
        CASE nsel == 2
            Scroll()
            mselect := "JC-"
            JCQU( @mselect )
            LOOP
        CASE nsel == 3
            Scroll()
            mselect := "QU-"
            JCQU( @mselect )
            LOOP
        CASE nsel == 4
            DBFReindx()
            XF_DBFUse()
            Part16()
            LOOP
        CASE nsel == 5
            DBFReindx()
            XF_DBFUse()
            EquUpdate()          // Above
            LOOP
        CASE nsel == 6
            SELECT Equ
            GOTO TOP
            nl := 0
            DO WHILE Equ->( !Eof() )
                nrecno := Str( RecNo(), 6 )
                @ nl, 0 SAY SubStr( Equ->Partnum, 1, 16 )
                SELECT EquCut
                GOTO TOP
                mseek := SubStr( Equ->ModSeqno, 1, 16 )
                SEEK mseek
                DO WHILE SubStr( EquCut->ModSeqno, 1, 16 ) = mseek .AND. EquCut->( !Eof() )
                    IF EquCut->Partnum != Equ->Partnum
                        SKIP ALIAS EquCut
                        LOOP
                    ENDIF
                    @ nl, 17      SAY EquCut->ModSeqno
                    @ nl, Col() + 1 SAY EquCut->Qty PICTURE "9,999.999"
                    ApFLock( 3 )
                    EquCut->ModTemp  := Equ->Modcode + nrecno
                    EquCut->ModSeqno := Equ->Modcode + nrecno
                    UNLOCK
                    @ nl, Col() + 1 SAY EquCut->ModSeqno COLOR "R+"
                    nl++
                    SKIP ALIAS EquCut
                ENDDO
                SELECT Equ
                ApFLock( 3 )
                Equ->ModTemp  := Equ->Modcode + nrecno
                Equ->ModSeqno := Equ->Modcode + nrecno
                UNLOCK
                nl++
                IF nl > 22
                    nl := 0
                ENDIF
                SKIP ALIAS Equ
            ENDDO
            Scroll( 22, 0, 24, 80 )
            @ 23, 10 SAY "PLEASE WAIT       WAIT !!!!" COLOR "RG"
            DBFReindx()
            XF_DBFUse()
            LOOP
        CASE nsel == 7
            NewLocate()
            LOOP
        CASE nsel == 8
            KirbyUpDate()    // Above
            // **         RenameLoc()
            LOOP
        ENDCASE
    ENDDO                // mcontinue
    RESTORE SCREEN FROM Menuscrn

    RETURN NIL

// ***---------------------------------------------------------------------

FUNCTION MenuMet( nc, ncl )

    DO WHILE .T.
        cheading := "SYSTEM MAIN"
        nselect  := 0
        nc       := ncl
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  4, nc + ( ncl / 2 ) -( Len( cheading ) / 2 ) SAY cheading
        @  6, nc + 2 PROMPT "                     "
        @  7, nc + 2 PROMPT "1. REINDEX   FILES   "
        @  9, nc + 2 PROMPT "2. Control     DBF   "
        @ 11, nc + 2 PROMPT "3. MAINT DATA        "
        @ 13, nc + 2 PROMPT "4. Delete Old Data   "
        @ 14, nc + 2 PROMPT "5. Zero Stock End Yr "
        @ 15, nc + 2 PROMPT "6. Delete Parts      "
        @ 16, nc + 2 PROMPT "7. Update GST 15%    "
        @ 17, nc + 2 PROMPT "8. JC- QU-           "
        @ 19, nc + 2 PROMPT "0. To - Main         "

        MENU TO nselect

        DO CASE
        CASE nselect = 10 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            DBFReindx()
            XF_DBFUse()
            UpDateJC()     // XLF_Util   cleans up QuotStk file
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            ContDbf()                      // Below
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            NewClmnt()
            XF_DBFUse()                           // XF_DBF
            RESTORE SCREEN FROM holdscrn

        CASE nselect == 5
            SAVE SCREEN TO holdscrn
            ndelete := 750
            Scroll()
            @  2, 10 SAY "REMOVE ALL OTHERS FROM NETWORK TO DO THIS"
            @  4, 10 SAY "Check Date first"
            @  4, 35 SAY Date()
            WAIT"Esc if not Correct"
            IF PressedEsc()
                RETURN NIL
            ENDIF
            CLOSE DATABASES
            @  6, 10      SAY "Delete Receipts over ? Days  " GET ndelete PICTURE "9999"
            @  6, Col() + 3 SAY "ie 750 = 2 Yrs    Rec"
            READ
            IF ndelete < 750
                WAIT"           Sorry can't delete less than Two year"
                ndelete := 750
            ENDIF
            USE Rec
            DELETE ALL FOR RecDate < Date() -ndelete
            ndelete := 1100
            @  7, 10      SAY "Delete Payments over ? Days  " GET ndelete PICTURE "9999"
            @  7, Col() + 3 SAY "ie 1100 = 3 Yrs    Pay"
            READ
            IF ndelete < 1100
                WAIT"           Sorry can't delete less than three year"
                ndelete := 1100
            ENDIF
            USE Pay
            DELETE ALL FOR CheqDate < Date() -ndelete
            ndelete := 1100
            @  8, 10      SAY "Delete Debit Prof over ? Days" GET ndelete PICTURE "9999"
            @  8, Col() + 3 SAY "ie 1100 = 3 Yrs    DebProf"
            READ
            IF ndelete < 1100
                WAIT"           Sorry can't delete less than Three years"
                ndelete := 1100
            ENDIF
            USE DebProf
            DELETE ALL FOR DBDate < Date() -ndelete
            ndelete := 365
            @ 10, 10      SAY "Delete Part Serno over ? Days" GET ndelete PICTURE "9999"
            @ 10, Col() + 3 SAY "ie 365 = 1 Yrs    PartSer"
            READ
            IF ndelete < 365
                WAIT"           Sorry can't delete less than one year"
                ndelete := 365
            ENDIF
            USE PartSer
            DELETE ALL FOR PDate < Date() -ndelete
            ndelete := 365
            @ 11, 10      SAY "Delete Labour over  ? Days   " GET ndelete PICTURE "9999"
            @ 11, Col() + 3 SAY "ie 365 = 1 Yrs    Hist"
            READ
            IF ndelete < 365
                WAIT"           Sorry can't delete less than one year"
                ndelete := 365
            ENDIF
            USE Labour
            DELETE ALL FOR Date < Date() -ndelete
            ndelete := 732
            @ 12, 10      SAY "Delete Wage    over  ? Days  " GET ndelete PICTURE "9999"
            @ 12, Col() + 3 SAY "ie 365 = 1 Yrs    Wage"
            READ
            IF ndelete < 732
                WAIT"           Sorry can't delete less than TWO year"
                ndelete := 732
            ENDIF
            USE Pmppjnl
            DELETE ALL FOR Pay_Per < Date() -ndelete
            ndelete := 365
            @ 13, 10      SAY "Delete Orders Profile ? Days " GET ndelete PICTURE "9999"
            @ 13, Col() + 3 SAY "ie 365 = 1 Yrs    ProfNat"
            READ
            IF ndelete < 365
                WAIT"           Sorry can't delete less than One year"
                ndelete := 365
            ENDIF
            USE ProfNat
            DELETE ALL FOR PDate < Date() -ndelete
            // ***         DELETE ALL FOR Cost = 1.00   // not worth it only small number
            ndelete := 365
            @ 14, 10      SAY "Delete Supplier       ? Days " GET ndelete PICTURE "9999"
            @ 14, Col() + 3 SAY "ie 365 = 1 Yrs    Supplier"
            READ
            IF ndelete < 365
                WAIT"           Sorry can't delete less than one year"
                ndelete := 365
            ENDIF
            USE Supl
            DELETE ALL FOR Date < Date() -ndelete
            ndelete := 732
            @ 16, 10      SAY "Delete Credit Profile ? Days " GET ndelete PICTURE "9999"
            @ 16, Col() + 3 SAY "ie 732 = 2 Yrs    Credit Prof"
            READ
            IF ndelete < 732
                WAIT"           Sorry can't delete less than two year"
                ndelete := 732
            ENDIF
            USE CredProf
            DELETE ALL FOR InvDate < Date() -ndelete
            DBFReindx()
            XF_DBFUse()
            UpDateJC()     // XLF_Util   cleans up QuotStk file
            RESTORE SCREEN FROM holdscrn

        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            Scroll()
            @  8, 10 SAY "End of Year Zero Parts Instock etc"
            @ 10, 10 SAY "MAKE SURE NO ONE ON NETWORK"
            mok := ApGetN( "Are You sure about this" )
            IF mok = "Y"
                CLOSE DATABASES
                mok := "N"
                @ 12, 15 SAY "Zero Part Instock" GET mok PICTURE "!"
                READ
                IF mok = "Y"
                    USE Part
                    REPLACE ALL Part->Instock WITH 0
                    mok := "N"
                ENDIF
                @ 14, 10 SAY "Zero Part Used to date" GET mok PICTURE "!"
                READ
                IF mok = "Y"
                    REPLACE ALL Part->Utd WITH 0
                ENDIF
                mok := "N"
                @ 16, 9 SAY "Zero Name YTD Purchases" GET mok PICTURE "!"
                READ
                IF mok = "Y"
                    USE Name
                    REPLACE ALL Name->YtdPurch WITH 0
                ENDIF
                DBFReindx()
                XF_DBFUse()
            ENDIF
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7
            SAVE SCREEN TO holdscrn
            QuickDel()                 // Below
            RESTORE SCREEN FROM holdscrn

        CASE nselect == 8
            SAVE SCREEN TO holdscrn
            Scroll()
            SELECT DebProf
            GOTO TOP
            nl := 1
            DO WHILE DebProf->( !Eof() )
                IF DebProf->Amount = 0
                    ApRLock( 3 )
                    DebProf->GSTAmnt := 0
                    UNLOCK
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF SubStr( DebProf->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    IF DebProf->GSTAmnt > 0
                        ApRLock( 3 )
                        DebProf->Amount := Debprof->Amount - DebProf->GSTAmnt
                        UNLOCK
                    ENDIF
                    ApRLock( 3 )
                    DebProf->GSTAmnt := 0
                    UNLOCK
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF SubStr( DebProf->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    ApRLock( 3 )
                    DebProf->GSTAmnt := 0
                    UNLOCK
                    @ nl, 40 SAY DebProf->Amount  PICTURE "999,999.99"
                    @ nl, 52 SAY DebProf->GSTAmnt PICTURE "99,999.99"
                    @ nl, 65 SAY DebProf->Saleno
                    @ nl, 71 SAY DebProf->Codeno
                    nl++
                    IF nl > 22
                        nl := 1
                        WAIT
                    ENDIF
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                ApRLock( 3 )
                DebProf->GSTAmnt := ( ( DebProf->Amount * 3 ) / 23 )
                UNLOCK
                @ nl, 10 SAY DebProf->Amount  PICTURE "999,999.99"
                @ nl, 30 SAY DebProf->GSTAmnt PICTURE "999,999.99"
                @ nl, 42 SAY DebProf->Saleno
                @ nl, 50 SAY DebProf->Codeno
                nl++
                IF nl > 22
                    nl := 1
                    WAIT
                ENDIF
                SKIP ALIAS DebProf
            ENDDO
            RESTORE SCREEN FROM holdscrn

        CASE nselect == 9
            SAVE SCREEN TO holdscrn
            Update()
            RESTORE SCREEN FROM holdscrn
            LOOP

        ENDCASE
    ENDDO

    RETURN NIL

// **------ End of MenuMet()

// **-------------------------------------------------------------------------

STATIC FUNCTION EquUpdate()

    SELECT Part
    SET ORDER TO 1             // partnum
    Scroll()
    @  2, 10 SAY "Updating Modules with no Part in File"
    ncount := 0
    nl := 3
    SELECT Equ
    GOTO TOP
    DO WHILE Equ->( !Eof() )
        mseek := Equ->ModCode
        SELECT Part
        SEEK mseek
        IF !Found()
            SELECT Equ
            @ nl, 1      SAY Equ->Modcode
            @ nl, Col() + 2 SAY "Module no part in file" COLOR "RG+"
            ApFLock( 3 )
            DELETE
            UNLOCK
            ncount++
            nl++
            IF nl > 22
                Inkey( 0.1 )
                Scroll()
                @  2, 10 SAY "Updating Modules with no Part in File"
                nl := 3
            ENDIF
        ENDIF
        SELECT Equ
        SKIP ALIAS Equ
    ENDDO                          // Equ
    nl += 2
    @ nl, 10      SAY ncount PICTURE "99,999"
    @ nl, Col() + 2 SAY "Deleted Modules no Part in file" COLOR "RG+"

    WAIT

    Scroll()
    @  2, 10 SAY "Module Desc with no Part in File"
    ncount := 0
    nl := 3
    SELECT EquDesc
    GOTO TOP
    DO WHILE EquDesc->( !Eof() )
        mseek := SubStr( EquDesc->ModCode, 1, 16 )
        SELECT Part
        SEEK mseek
        IF !Found()
            SELECT EquDesc
            @ nl, 1      SAY EquDesc->ModCode
            @ nl, Col() + 2 SAY "Deleted no part in file" COLOR "RG+"
            ApFLock( 3 )
            DELETE
            UNLOCK
            ncount++
            nl++
            IF nl > 21
                Inkey( 0.1 )
                Scroll()
                @  2, 10 SAY "Module Desc with no Part in File"
                nl := 3
            ENDIF
        ENDIF
        SELECT EquDesc
        SKIP ALIAS EquDesc
    ENDDO                          // Equ
    nl += 2
    @ nl, 10      SAY ncount PICTURE "99,999"
    @ nl, Col() + 2 SAY "Deleted Modules Desc" COLOR "RG+"
    nl += 2
    @ nl, 10 SAY "Will now Check Parts in Modules" COLOR "RG+"

    WAIT

    Scroll()
    @  2, 10 SAY "Updating Cuts in Modules with no Part in File"
    ncount := 0
    nl := 3
    SELECT EquCut
    GOTO TOP
    DO WHILE EquCut->( !Eof() )
        mseek := SubStr( EquCut->ModSeqno, 1, 16 )
        SELECT Part
        SEEK mseek
        IF !Found()
            SELECT EquCut
            @ nl, 1      SAY EquCut->ModSeqno
            @ nl, Col() + 2 SAY "Deleted no part in file" COLOR "RG+"
            ApFLock( 3 )
            DELETE
            UNLOCK
            ncount++
            nl++
            IF nl > 21
                Inkey( 0.1 )
                Scroll()
                @  2, 10 SAY "Updating Parts in Modules with no Part in File"
                nl := 3
            ENDIF
        ENDIF
        SELECT EquCut
        SKIP ALIAS EquCut
    ENDDO                          // Equ
    nl += 2
    @ nl, 10      SAY ncount PICTURE "99,999"
    @ nl, Col() + 2 SAY "Deleted Cuts in Modules" COLOR "RG+"

    WAIT

    Scroll()
    @  2, 10 SAY "Updating Suppliers with no Part in File"
    ncount := 0
    nl := 3
    SELECT Supl
    GOTO TOP
    DO WHILE Supl->( !Eof() )
        mseek := Supl->Partnum
        SELECT Part
        SEEK mseek
        IF !Found()
            SELECT Supl
            @ nl, 1      SAY Supl->Partnum
            @ nl, Col() + 2 SAY "Deleted no part in file" COLOR "RG+"
            ApFLock( 3 )
            DELETE
            UNLOCK
            ncount++
            nl++
            IF nl > 21
                Inkey( 0.1 )
                Scroll()
                @  2, 10 SAY "Updating Supplier with no Part in File"
                nl := 3
            ENDIF
        ENDIF
        SELECT Supl
        SKIP ALIAS Supl
    ENDDO                          // Supl
    nl += 2
    @ nl, 10      SAY ncount PICTURE "99,999"
    @ nl, Col() + 2 SAY "Deleted Supl" COLOR "RG+"

    WAIT

    RETURN NIL

// **----------------------------------------------------------------------

STATIC FUNCTION JCQU()

    ddate := Date() -110
    @  10, 10 SAY mselect + " DELETE BEFORE DATE" GET ddate PICTURE "99/99/9999"
    READ
    nl := nle := 2
    npl := 1
    mok := ApGetN( "Are You sure about this " )
    IF mok = "Y"
        @ 12, 10 SAY mselect + "        BEFORE DATE" GET ddate PICTURE "99/99/9999"
        READ
        mok := "N"
    ELSE
        // **            LOOP
    ENDIF
    mok := ApGetN( "BEWARE Are You sure " )
    IF mok = "Y"
        Scroll()
        @  0, 30 SAY "PLEASE WAIT WORKING HARD"
        @  1, 10 SAY mselect + " Part            Module                          Desc"
        SELECT Part
        SET ORDER TO 1        // Partnum
        GO TOP
        DO WHILE Part->( !Eof() )
            IF SubStr( Part->Partnum, 1, 3 ) != mselect
                SKIP ALIAS Part
                LOOP
            ENDIF
            IF Part->Date > ddate
                SKIP ALIAS Part
                LOOP
            ENDIF
            SELECT EquDesc
            SET ORDER TO 1      // ModCode
            mmodcode := SubStr( Part->Partnum, 1, 16 )
            IF LastRec() != 0
                GO TOP
                DO WHILE EquDesc->( !Eof() )
                    IF SubStr( EquDesc->Modcode, 1, 3 ) != mselect
                        SKIP ALIAS EquDesc
                        LOOP
                    ENDIF
                    IF EquDesc->Modcode != mmodcode
                        SKIP ALIAS EquDesc
                        LOOP
                    ENDIF
                    mdebit := Space( 12 )
                    SELECT Debit
                    GOTO TOP
                    DO WHILE Debit->( !Eof() )
                        IF SubStr( Debit->Invno, 3, 4 ) = SubStr( mmodcode, 4, 4 )
                            mdebit := Debit->Invno
                        ENDIF
                        SKIP ALIAS Debit
                    ENDDO
                    SELECT EquDesc
                    IF mdebit = Space( 12 )
                        @ nl, 50 SAY EquDesc->Modcode
                        @ nl, 70 SAY npl PICTURE "9999"
                        nl++
                        npl++
                        SELECT Part
                        SET ORDER TO 1        // Partnum
                        SEEK mmodcode
                        @  0, 10 SAY Part->Partnum + "  " + Part->Desc COLOR "BG+"
                        ApFLock( 3 )
                        DELETE
                        UNLOCK
                        // *** mmodcode := EquDesc->ModCode
                        nle := 2
                        Scroll( 1, 25, 24, 45 )
                        @ 1, 28 SAY "Module"
                        SELECT Equ
                        SEEK mmodcode
                        DO WHILE Equ->ModCode = mmodcode .AND. Equ->( !Eof() )
                            @ nle, 28 SAY Equ->ModCode
                            nle++
                            IF nle > 23
                                Inkey( 1 )
                                Scroll( 2, 0, 24, 49 )
                                nle := 2
                            ENDIF
                            ApFLock( 3 )
                            DELETE
                            UNLOCK
                            SKIP ALIAS Equ
                        ENDDO
                        nle := 2
                        Scroll( 1, 25, 24, 45 )
                        minvno := "20" + SubStr( mmodcode, 4, 4 )
                        @  1, 1 SAY "Labour " + minvno COLOR "RG+"
                        SELECT Labour
                        SET ORDER TO 2            // Invno+Partnum
                        SEEK minvno
                        DO WHILE Labour->Invno = minvno .AND. Labour->( !Eof() )
                            @ nle, 1 SAY Labour->Invno COLOR "BG+"
                            nle++
                            IF nle > 23
                                Inkey( 1 )
                                Scroll( 2, 0, 24, 49 )
                                nle := 2
                            ENDIF
                            ApFLock( 3 )
                            DELETE
                            UNLOCK
                            SKIP ALIAS Labour
                        ENDDO
                        nle := 2
                        Scroll( 1, 0, 24, 30 )
                        @ 1, 1 SAY "Module Cut"
                        SELECT EquCut
                        SEEK mmodcode
                        DO WHILE SubStr( EquCut->ModSeqno, 1, 16 ) = mmodCode .AND. EquCut->( !Eof() )
                            IF EquCut->Date > ddate
                                SKIP ALIAS EquCut
                                LOOP
                            ENDIF
                            @ nle, 1 SAY EquCut->ModSeqno
                            nle++
                            ApFLock( 3 )
                            DELETE
                            UNLOCK
                            SKIP ALIAS EquCut
                        ENDDO
                        SELECT EquDesc
                        ApFLock( 3 )
                        DELETE
                        UNLOCK
                    ENDIF
                    SELECT EquDesc
                    SKIP ALIAS EquDesc
                    IF nl > 23
                        Inkey( 2 )
                        Scroll( 1, 0, 24, 80 )
                        nl := nle := 2
                    ENDIF
                ENDDO
            ENDIF        // LastRec
            SKIP ALIAS Part
        ENDDO                         // Part
        nl := npl := 1
        Scroll()
        @ 0, 28 SAY mselect + " Parts" COLOR "RG+"
        SELECT Part
        SET ORDER TO 1        // Partnum
        GO TOP
        DO WHILE Part->( !Eof() )
            IF SubStr( Part->Partnum, 1, 3 ) != mselect
                SKIP ALIAS Part
                LOOP
            ENDIF
            IF Part->Date > ddate
                @ nl, 4 SAY "Not Deleted " + Part->Partnum + "  " + Part->Desc COLOR "RG+"
                nl++
                IF nl > 22
                    WAIT
                    Scroll( 1, 0, 24, 80 )
                    nl := 1
                ENDIF
                SKIP ALIAS Part
                LOOP
            ENDIF
            SELECT Debit
            GOTO TOP
            mdebit := Space( 12 )
            DO WHILE Debit->( !Eof() )
                IF SubStr( Debit->Invno, 3, 4 ) = SubStr( Part->Partnum, 4, 4 )
                    mdebit := Debit->Invno
                ENDIF
                SKIP ALIAS Debit
            ENDDO
            SELECT Part
            IF mdebit = Space( 12 )
                @  nl, 8 SAY Part->Partnum + "  " + Part->Desc + " DELETED" COLOR "BG+"
                nl++
                IF nl > 22
                    WAIT
                    Scroll( 1, 0, 24, 80 )
                    nl := 1
                ENDIF
                ApFLock( 3 )
                DELETE
                UNLOCK
            ENDIF
            SKIP ALIAS Part
        ENDDO                       // Part
        WAIT
    ENDIF                          // mok

    RETURN NIL

// ***-------------------------------------------------------------------

STATIC FUNCTION Part16()

    Scroll()
    SELECT Part
    GOTO TOP
    @  8, 5 SAY "Part file to 16 Char" COLOR "RG+"
    @  8, 50 SAY LastRec() PICTURE "999,999"
    ApFLock( 3 )
    REPLACE ALL Part->Partnum WITH SubStr( Part->Partnum, 1, 16 )
    UNLOCK
    SELECT Orders
    GOTO TOP
    @ 10, 5 SAY "Orders file to 16 Char" COLOR "RG+"
    @ 10, 50 SAY LastRec() PICTURE "999,999"
    ApFLock( 3 )
    REPLACE ALL Orders->Partnum WITH SubStr( Orders->Partnum, 1, 16 )
    UNLOCK
    SELECT Supl
    GOTO TOP
    @ 12, 5 SAY "Supl Part Supplier file to 16 Char" COLOR "RG+"
    @ 12, 50 SAY LastRec() PICTURE "999,999"
    ApFLock( 3 )
    REPLACE ALL Supl->Partnum WITH SubStr( Supl->Partnum, 1, 16 )
    UNLOCK
    SELECT EquCut
    GOTO TOP
    @ 14, 5 SAY "EquCut Modules Cuts file to 16 Char" COLOR "RG+"
    @ 14, 50 SAY LastRec() PICTURE "999,999"
    ApFLock( 3 )
    REPLACE ALL EquCut->Partnum WITH SubStr( EquCut->Partnum, 1, 16 )
    UNLOCK
    SELECT Equ
    GOTO TOP
    @ 16, 5 SAY "Equ Module file to 16 Char" COLOR "RG+"
    @ 16, 50 SAY LastRec() PICTURE "999,999"
    ApFLock( 3 )
    REPLACE ALL Equ->Partnum WITH SubStr( Equ->Partnum, 1, 16 )
    UNLOCK
    SELECT EquDesc
    GOTO TOP
    @ 18, 5 SAY "Module Description file" COLOR "RG+"
    @ 18, 50 SAY LastRec() PICTURE "999,999"

    @ 20, 10 SAY " --- OK All Done --- " COLOR "RG+"

    WAIT
    DBFReindx()
    XF_DBFUse()

    RETURN NIL

// **  End Part16

// **--------------------------------------------------------------------------

FUNCTION MenuSyst( nc, ncl )

    DO WHILE .T.
        cheading := "ADMIN"
        nselect  := 0
        nc       := ncl
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  4, nc + ( ncl / 2 ) -( Len( cheading ) / 2 ) SAY cheading
        @  6, nc + 2 PROMPT "                     "
        @  7, nc + 2 PROMPT "1. REINDEX   FILES   "
        @  9, nc + 2 PROMPT "2. Control     DBF   "
        @ 11, nc + 2 PROMPT "3. MAINT DATA        "
        @ 13, nc + 2 PROMPT "4. Delete Old Data   "
        @ 14, nc + 2 PROMPT "5. Zero Stock End Yr "
        @ 15, nc + 2 PROMPT "6. Delete Parts      "
        @ 16, nc + 2 PROMPT "7. Special Update GST"
        @ 18, nc + 2 PROMPT "8. JC- QU- Delete    "
        @ 20, nc + 2 PROMPT "0. To - Main         "

        MENU TO nselect

        DO CASE
        CASE nselect = 10 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            DBFReindx()
            XF_DBFUse()
            UpDateJC()     // XLF_Util   cleans up QuotStk file
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            ContDbf()                      // Below
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            NewClmnt()
            XF_DBFUse()                           // XF_DBF
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5    // This is 4 in Menu
            SAVE SCREEN TO holdscrn
            ndelete := 750
            Scroll()
            @  2, 10 SAY "REMOVE ALL OTHERS FROM NETWORK TO DO THIS"
            @  4, 10 SAY "Check Date first"
            @  4, 35 SAY Date()
            WAIT"Esc if not Correct"
            IF PressedEsc()
                RETURN NIL
            ENDIF
            CLOSE DATABASES
            @  6, 10      SAY "Delete Receipts over ? Days  " GET ndelete PICTURE "9999"
            @  6, Col() + 3 SAY "ie 750 = 2 Yrs    Rec"
            READ
            IF ndelete < 750
                WAIT"           Sorry can't delete less than Two year"
                ndelete := 750
            ENDIF
            USE Rec
            DELETE ALL FOR RecDate < Date() -ndelete
            ndelete := 1100
            @  7, 10      SAY "Delete Payments over ? Days  " GET ndelete PICTURE "9999"
            @  7, Col() + 3 SAY "ie 1100 = 3 Yrs    Pay"
            READ
            IF ndelete < 1100
                WAIT"           Sorry can't delete less than three year"
                ndelete := 1100
            ENDIF
            USE Pay
            DELETE ALL FOR CheqDate < Date() -ndelete
            ndelete := 1100
            @  8, 10      SAY "Delete Debit Prof over ? Days" GET ndelete PICTURE "9999"
            @  8, Col() + 3 SAY "ie 1100 = 3 Yrs    DebProf"
            READ
            IF ndelete < 1100
                WAIT"           Sorry can't delete less than Three years"
                ndelete := 1100
            ENDIF
            USE DebProf
            DELETE ALL FOR DBDate < Date() -ndelete
            ndelete := 365
            @  9, 10      SAY "Delete History over ? Days   " GET ndelete PICTURE "9999"
            @  9, Col() + 3 SAY "ie 365 = 1 Yrs    Hist"
            READ
            IF ndelete < 365
                WAIT"           Sorry can't delete less than one year"
                ndelete := 365
            ENDIF
            USE Hist
            DELETE ALL FOR PDate < Date() -ndelete
            ndelete := 365
            @ 10, 10      SAY "Delete Part Serno over ? Days" GET ndelete PICTURE "9999"
            @ 10, Col() + 3 SAY "ie 365 = 1 Yrs    PartSer"
            READ
            IF ndelete < 365
                WAIT"           Sorry can't delete less than one year"
                ndelete := 365
            ENDIF
            USE PartSer
            DELETE ALL FOR PDate < Date() -ndelete
            ndelete := 365
            @ 11, 10      SAY "Delete Labour over  ? Days   " GET ndelete PICTURE "9999"
            @ 11, Col() + 3 SAY "ie 365 = 1 Yrs    Hist"
            READ
            IF ndelete < 365
                WAIT"           Sorry can't delete less than one year"
                ndelete := 365
            ENDIF
            USE Labour
            DELETE ALL FOR Date < Date() -ndelete
            ndelete := 732
            @ 12, 10      SAY "Delete Wage    over  ? Days  " GET ndelete PICTURE "9999"
            @ 12, Col() + 3 SAY "ie 365 = 1 Yrs    Wage"
            READ
            IF ndelete < 732
                WAIT"           Sorry can't delete less than TWO year"
                ndelete := 732
            ENDIF
            USE Pmppjnl
            DELETE ALL FOR Pay_Per < Date() -ndelete
            ndelete := 365
            @ 13, 10      SAY "Delete Orders Profile ? Days " GET ndelete PICTURE "9999"
            @ 13, Col() + 3 SAY "ie 365 = 1 Yrs    ProfNat"
            READ
            IF ndelete < 365
                WAIT"           Sorry can't delete less than One year"
                ndelete := 365
            ENDIF
            USE ProfNat
            DELETE ALL FOR PDate < Date() -ndelete
            ndelete := 365
            @ 14, 10      SAY "Delete Supplier       ? Days " GET ndelete PICTURE "9999"
            @ 14, Col() + 3 SAY "ie 365 = 1 Yrs    Supplier"
            READ
            IF ndelete < 365
                WAIT"           Sorry can't delete less than one year"
                ndelete := 365
            ENDIF
            USE Supl
            DELETE ALL FOR Date < Date() -ndelete
            ndelete := 732
            @ 16, 10      SAY "Delete Credit Profile ? Days " GET ndelete PICTURE "9999"
            @ 16, Col() + 3 SAY "ie 732 = 2 Yrs    Credit Prof"
            READ
            IF ndelete < 732
                WAIT"           Sorry can't delete less than two year"
                ndelete := 732
            ENDIF
            USE CredProf
            DELETE ALL FOR InvDate < Date() -ndelete
            DBFReindx()
            XF_DBFUse()
            UpDateJC()     // XLF_Util   cleans up QuotStk file
            RESTORE SCREEN FROM holdscrn

        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            Scroll()
            @  8, 10 SAY "End of Year Zero Parts Instock etc"
            @ 10, 10 SAY "MAKE SURE NO ONE ON NETWORK"
            mok := ApGetN( "Are You sure about this" )
            IF mok = "Y"
                CLOSE DATABASES
                USE Part
                REPLACE ALL Part->Instock WITH 0
                REPLACE ALL Part->RecQty  WITH 0
                REPLACE ALL Part->Utd     WITH 0
                USE Name
                REPLACE ALL Name->YtdPurch WITH 0
                DBFReindx()
                XF_DBFUse()
            ENDIF
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7
            SAVE SCREEN TO holdscrn
            QuickDel()                 // Below
            RESTORE SCREEN FROM holdscrn

        CASE nselect == 8
            SAVE SCREEN TO holdscrn
            Scroll()
            SELECT DebProf
            GOTO TOP
            nl := 1
            DO WHILE DebProf->( !Eof() )
                IF DebProf->Amount = 0
                    ApRLock( 3 )
                    DebProf->GSTAmnt := 0
                    UNLOCK
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF SubStr( DebProf->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    IF DebProf->GSTAmnt > 0
                        ApRLock( 3 )
                        DebProf->Amount := Debprof->Amount - DebProf->GSTAmnt
                        UNLOCK
                    ENDIF
                    ApRLock( 3 )
                    DebProf->GSTAmnt := 0
                    UNLOCK
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                IF SubStr( DebProf->Saleno, 1, 2 ) = SubStr( Message->Saleno5, 1, 2 )
                    ApRLock( 3 )
                    DebProf->GSTAmnt := 0
                    UNLOCK
                    @ nl, 40 SAY DebProf->Amount  PICTURE "999,999.99"
                    @ nl, 52 SAY DebProf->GSTAmnt PICTURE "99,999.99"
                    @ nl, 65 SAY DebProf->Saleno
                    @ nl, 71 SAY DebProf->Codeno
                    nl++
                    IF nl > 22
                        nl := 1
                        WAIT
                    ENDIF
                    SKIP ALIAS DebProf
                    LOOP
                ENDIF
                ApRLock( 3 )
                DebProf->GSTAmnt := ( DebProf->Amount / 9 )
                UNLOCK
                @ nl, 10 SAY DebProf->Amount  PICTURE "999,999.99"
                @ nl, 30 SAY DebProf->GSTAmnt PICTURE "999,999.99"
                @ nl, 42 SAY DebProf->Saleno
                @ nl, 50 SAY DebProf->Codeno
                nl++
                IF nl > 22
                    nl := 1
                    WAIT
                ENDIF
                SKIP ALIAS DebProf
            ENDDO
            RESTORE SCREEN FROM holdscrn

        CASE nselect == 9
            SAVE SCREEN TO holdscrn
            Update()
            RESTORE SCREEN FROM holdscrn
            LOOP
        ENDCASE
    ENDDO

    RETURN NIL

// **------ End of Menusyst()

// **-------------------------------------------------------------------------

FUNCTION MenuNote()

    DO WHILE .T.
        cheading := "NOTES MENU"
        nselect  := 0
        nc       := ncl * 2
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  4, nc + ( ncl / 2 ) -( Len( cheading ) / 2 ) SAY cheading
        @  7, nc + 2 PROMPT "1. Notes Edit/Add"
        @  9, nc + 2 PROMPT "2.   ..      LIST"
        @ 11, nc + 2 PROMPT "                 "
        @ 15, nc + 2 PROMPT "                 "
        @ 16, nc + 2 PROMPT "                 "
        @ 17, nc + 2 PROMPT "                 "
        @ 18, nc + 2 PROMPT "                 "
        @ 19, nc + 2 PROMPT "                 "
        @ 20, nc + 2 PROMPT "0. To - Main     "

        MENU TO nselect

        nc := ncl

        DO CASE
        CASE nselect == 9 .OR. PressedEsc()
            RETURN NIL
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            NoteAdd()
            RESTORE SCREEN FROM holdscrn

        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            NoteList()
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// *** End of MenuNote

// *---------------------------------------------------------------------*

STATIC FUNCTION NoteAdd()

    SELECT Note

    mcontinue := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        DispBox(  0, 5, 2, 75, 2 )
        @  1, 10 SAY "Edit or Add New Note"
        aPart_ := {}
        Scroll( 2, 0, MaxRow(), MaxCol() )
        IF LastRec() != 0
            GO TOP
            DO WHILE Note->( !Eof() )
                AAdd( aPart_, ( Note->Noteno + "  " + Note->Note ) )
                SKIP ALIAS Note
            ENDDO
            DispBox( 2, 2, 15, 78, 2 )
            IF !Empty( aPart_ )
                anum := AChoice( 3, 3, 14, 77, aPart_,, "AFUNC" )
            ENDIF
            IF PressedEsc()
                RETURN NIL
            ENDIF
            SEEK SubStr( aPart_[ anum ], 1, 4 )
            mnoteno := Note->Noteno
            Scroll( 1, 6, 1, 74 )
            @  1, 8 SAY ( mnoteno ) + "  " + Note->Note COLOR c_hicolor
        ENDIF
        mnote := Space( 60 )
        DispBox( 15, 2, 19, 78, 2 )
        mcorrect := "N"
        DO WHILE mcorrect == "N"
            @ 16, 10 SAY "Edit or Add Note :" GET mnoteno PICTURE "@!"
            @ 16, Col() + 2 SAY "Esc To Quit"
            READ
            IF PressedEsc()
                RETURN NIL
            ENDIF
            SEEK mnoteno
            IF Found()
                mnote := Note->Note
            ENDIF
            @ 18, 4 SAY "Note :" GET mnote PICTURE "@X"
            READ
            mcorrect := ApGetY( "Is the above Correct :" )
            IF LastKey() = 27
                RETURN NIL
            ENDIF
        ENDDO
        SEEK mnoteno
        ApRLock( 3 )
        IF !Found()
            APPEND BLANK
        ENDIF
        REPLACE Noteno WITH mnoteno, Note WITH mnote
        UNLOCK
        mcontinue := "N"
        // **   mcontinue := ApGetN( "Another Note Code :" )
    ENDDO

    RETURN NIL

// ** End of NoteAdd()

// *---------------------------------------------------------------------*

STATIC FUNCTION NoteList()

    mselno := Space( 4 )
    mnote  := Space( 60 )
    // ** SCROLL()
    mwhere := "S"

    Printsel( mwhere )
    nl := 2
    IF mwhere = "P"
        @  0, 5 SAY "Noteno"
        @  0, 15 SAY "Note Description"
        @  0, 56 SAY Date()
        npl :=  56
    ELSE
        npl := 18
    ENDIF
    SELECT Note
    GOTO TOP
    DO WHILE Note->( !Eof() )
        IF nl > npl
            IF mwhere = "P"
                EJECT
            ELSE
                WAIT
            ENDIF
            nl := 2
            @  0, 5 SAY "Noteno"
            @  0, 15 SAY "Note Description"
            @  0, 56 SAY Date()
        ENDIF
        @ nl, 5 SAY Note->Noteno
        @ nl, 15 SAY Note->Note
        SKIP ALIAS Note
        nl := nl + 1
    ENDDO
    IF mwhere = "P"
        EndPrint()
    ELSE
        WAIT
    ENDIF

    RETURN NIL

// ********-----------  END OF FILE XLF_NOTE.PRG
