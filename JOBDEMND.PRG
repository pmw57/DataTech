// ** JoKir09   28-09-11 16:16:33

/*
   Program.....:                  JOBDEMND.PRG
   Authors.....: J.Kirby
   Date........: 03/11/1999
   Functions...: CardAdd, PartAdd, PartDraw
   Not used....: Mu_Demand, JobOperLst
*/

FUNCTION Partadd( mpartnum )

    mok := "N"
    DO WHILE mok == "N"
        mpartnum := Space( 16 )
        mdate    := DToS( Date() )
        mdatesub := SubStr( mdate, 7, 2 ) + SubStr( mdate, 5, 2 );
            + SubStr( mdate, 3, 2 )
        Scroll(  18, 0, 24, 80 )
        DispBox( 18, 0, 24, 79, 2 )
        nselect  := 1
        @ 19, 10      PROMPT "Standard"
        @ 19, Col() + 3 PROMPT "JC-"
        @ 19, Col() + 3 PROMPT "QU-"
        @ 19, Col() + 3 PROMPT "TE-"
        @ 19, Col() + 3 PROMPT "TEXT"
        @ 19, Col() + 3 PROMPT "Card"

        @ 22, 4      SAY "JC- AA-JobCards"
        @ 22, Col() + 2 SAY "QU- AA-Quotes"
        @ 22, Col() + 2 SAY "TE- AA-Tenders"
        @ 22, Col() + 2 SAY "TEXT AA-Text"
        @ 22, Col() + 2 SAY "Card Clip"
        MENU TO nselect
        Scroll(  15, 0, 24, 80 )
        DispBox( 15, 1, 24, 79, 2 )
        DO CASE
        CASE PressedEsc()
            RETURN mpartnum

        CASE nselect == 1                  // Standard
            @ 16, 12 SAY "Catalogue As Selected" COLOR "G+"
            mpartnum := Space( 16 )
            @ 18, 10 SAY "New Partnum :" GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
            READ
            IF PressedEsc()
                mpartnum := Space( 16 )
                RETURN mpartnum
            ENDIF
            IF mpartnum = Space( 16 )
                LOOP
            ENDIF
            SELECT Part
            SET ORDER TO 1
            SEEK mpartnum
            DO WHILE Found()
                @  18, 10 SAY "New Partnum" GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
                @  18, 43 SAY "-- Already Used Try again --"
                READ
                IF PressedEsc()
                    mpartnum := Space( 16 )
                    RETURN mpartnum
                ENDIF
                SEEK mpartnum
            ENDDO
            ApFLock( 3 )
            APPEND BLANK
            Part->Partnum   := mpartnum
            Part->Desc      := "AA New Part"
            Part->Codeno    := Control->U_Codeno
            Part->BoughtOut := "N"
            Part->Date      := Date()
            UNLOCK
        CASE nselect == 2                  // Job Sheet
            SELECT Part
            SET ORDER TO 1
            @ 16, 12 SAY "JC- Catalogue AA-JobCards" COLOR "G+"
            mpart := "XXXXXX"
            DO CASE
            CASE Val( Debit->Invno ) == Control->LastIvc - 1
                mpart := Debit->Invno
                @ 18, 10 SAY "This Invoice # " + mpart + ;
                    "  File # " + Str( Control->LastIvc )
            CASE Val( Debit->Invno ) != Control->LastIvc
                mpart := Str( Control->LastIvc )
                @ 18, 10 SAY "File Invoice # " + mpart
            ENDCASE
            mpartnum := "JC-" + SubStr( mpart, 3, 4 ) + "-" + mdatesub + "  "
            @ 20, 10 SAY "New Partnum :" GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
            READ
            IF PressedEsc()
                mpartnum := Space( 16 )
                RETURN mpartnum
            ENDIF
            SEEK mpartnum
            DO WHILE Found()
                @ 20, 10 SAY "New Partnum :" GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
                @ 20, 45 SAY "-- Already Used Try again --"
                @ 22, 22 SAY "Remember Increase # if not used Yet"
                READ
                IF PressedEsc()
                    EXIT
                    RETURN Space( 20 )
                ENDIF
                SEEK mpartnum
            ENDDO
            Scroll(  18, 3, 23, 77 )
            ApFLock( 3 )
            APPEND BLANK
            Part->Partnum   := mpartnum
            Part->Catno     := "AA-JOBCARDS"
            Part->PartId    := "JOB CARD MODULES"
            Part->BoughtOut := "N"
            Part->Codeno    := Control->U_Codeno
            Part->Date      := Date()
            Part->Unit      := "Each"
            UNLOCK
            mdesc    := Part->Desc
            mdetail  := Part->Detail
            mdetail1 := Part->Detail1
            mpartnum := Part->Partnum
            @ 18, 15      SAY "Desc" GET mdesc
            @ 19, 20                 GET mdetail
            @ 20, 20                 GET mdetail1
            @ 21, 15 SAY "Part No"   GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
            READ
            ApRLock( 3 )
            Part->Partnum := mpartnum
            Part->Desc    := mdesc
            Part->Detail  := mdetail
            Part->Detail1 := mdetail1
            UNLOCK
            SELECT Control
            ApRLock( 3 )
            Control->LastIvc := Control->LastIvc + 1
            UNLOCK

            // ** EquDesc and Equ
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
            EquSearch( mmodcode )

        CASE nselect == 3                  // Quote
            mpart := Str( Control->Quotno )
            @ 18, 10 SAY "This QU- # " + mpart
            @ 20, 10      SAY "QU- Catalogue AA-Quotes" COLOR "G+"
            @ 20, Col() + 2 SAY "File Quote # " + mpart
            mpartnum := "QU-" + LTrim( mpart ) + "-" + mdatesub
            SELECT Part
            SET ORDER TO 1                              // Partnum
            SEEK mpartnum
            ApFLock( 3 )
            APPEND BLANK
            Part->Partnum   := mpartnum
            Part->Catno     := "AA-QUOTES"
            Part->PartId    := "QUOTE"
            Part->BoughtOut := "N"
            Part->Codeno    := Control->U_Codeno
            Part->Date      := Date()
            Part->Unit      := "Each"
            UNLOCK
            mdesc    := Part->Desc
            mpartnum := Part->Partnum
            @ 22, 15      SAY "Desc   " GET mdesc
            @ 23, 15      SAY "Part No" GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
            READ
            ApRLock( 3 )
            Part->Partnum := mpartnum
            Part->Desc    := mdesc
            UNLOCK
            IF SubStr( Part->Partnum, 4, 4 ) = mpart  // STR( Control->QuotNo )
                SELECT Control
                ApRLock( 3 )
                Control->Quotno := Control->Quotno + 1
                UNLOCK
            ENDIF

            // ** EquDesc and Equ
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
            EquSearch( mmodcode )

        CASE nselect == 4                  // Tender
            mpart := Str( Control->Quotno )
            @ 18, 10 SAY "This TE- # " + mpart
            @ 20, 10      SAY "TE- Catalogue AA-TENDERQU" COLOR "G+"
            @ 20, Col() + 2 SAY "File Quote # " + mpart
            mpartnum := "TE-" + LTrim( mpart ) + "-" + mdatesub
            SELECT Part
            SET ORDER TO 1                              // Partnum
            SEEK mpartnum
            ApFLock( 3 )
            APPEND BLANK
            Part->Partnum   := mpartnum
            Part->Catno     := "AA-TENDERQU"
            Part->PartId    := "TENDER"
            Part->BoughtOut := "N"
            Part->Codeno    := Control->U_Codeno
            Part->Date      := Date()
            Part->Unit      := "Each"
            UNLOCK
            mdesc    := Part->Desc
            mpartnum := Part->Partnum
            @ 22, 15      SAY "Desc   " GET mdesc
            @ 23, 15      SAY "Part No" GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
            READ
            ApRLock( 3 )
            Part->Partnum := mpartnum
            Part->Desc    := mdesc
            UNLOCK
            IF SubStr( Part->Partnum, 4, 4 ) = mpart  // STR( Control->QuotNo )
                SELECT Control
                ApRLock( 3 )
                Control->Quotno := Control->Quotno + 1
                UNLOCK
            ENDIF

            // ** EquDesc and Equ
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
            EquSearch( mmodcode )

        CASE nselect == 5                  // Text
            @ 16, 12 SAY "ZZTEXT Catalogue AA-Text" COLOR "G+"
            SELECT Part
            SET ORDER TO 1                              // Partnum
            mfind := "ZZTEXT" + LTrim( Str( LastRec() ) )
            SEEK mfind
            ApFLock( 3 )
            IF !Found()
                APPEND BLANK
                Part->Partnum := "ZZTEXT" + LTrim( Str( LastRec() ) )
            ELSE
                APPEND BLANK
                Part->Partnum := "ZZTEXT" + LTrim( Str( LastRec() ) );
                    + Trim( Control->Lastcheq )
            ENDIF        // FOUND
            Part->Catno     := "AA-TEXT  "
            Part->PartId    := "TEXT     "
            Part->BoughtOut := "N"
            Part->Codeno    := Control->U_Codeno
            Part->Date      := Date()
            Part->Unit      := "Each"
            UNLOCK
            mdesc    := Part->Desc
            mdetail  := Part->Detail
            mdetail1 := Part->Detail1
            mdetail2 := Part->Detail2
            mpartnum := Part->Partnum
            @ 18, 10 SAY "Text Desc" GET mdesc
            @ 19, 24                 GET mdetail
            @ 20, 24                 GET mdetail1
            @ 21, 24                 GET mdetail2
            // **             @ 22,20                 GET Part->Detail3
            // **             @ 23,15      SAY "Cost" GET Part->Trade
            // **             @ 23,COL()+2 SAY "Sell" GET Part->Wholesale
            @ 22, 15      SAY "Part No " GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
            READ
            ApRLock( 3 )
            Part->Partnum := mpartnum
            Part->Desc    := mdesc
            Part->Detail  := mdetail
            Part->Detail1 := mdetail1
            Part->Detail2 := mdetail2
            UNLOCK

        CASE nselect == 6                  // Card 6 Char
            mrefer := "PART"
            CardAdd( @mrefer )           // Above

        ENDCASE
        mok := "Y"
    ENDDO                           // mok

    COMMIT
    mpartnum := Part->Partnum

    RETURN mpartnum

// ** End of Partadd()

// *-------------------------------------------------------------------

FUNCTION Cardadd( mrefer )

    Scroll()
    mok := ApGetN( "Add/Change the Operate File" )
    IF mok = "Y"
        Joboperate()
        Scroll()
        @ 10, 10 SAY "Returning to Add Part Now select the Product"
        WAIT
    ENDIF
    Scroll()
    coperno := Space( 8 )
    GroupSelect( @coperno )               // XLF_Qu9
    mindex := coperno                      // mrefer
    Scroll()
    DispBox(  0, 0, 3, 79, 2 )
    // **   @  1,55      SAY "Selected"
    // **   @  1,COL()+3 SAY mrefer COLOR "RG+"
    mnameA := mnameB := mnameC := mnameD := "  "
    mnameE := mnameF := mnameG := mnameH := "  "
    mcodeno  := Space( 8 )
    mpartnum := Space( 16 )

    // ** A
    aPart_ := {}
    nrecno := 0
    SELECT Operate
    GOTO TOP
    DO WHILE Operate->( !Eof() )
        IF Operate->Operno != mindex    // +" A"
            SKIP ALIAS Operate
            LOOP
        ENDIF
        IF SubStr( Operate->Priority, 1, 1 ) != "A"
            SKIP ALIAS Operate
            LOOP
        ENDIF
        AAdd( aPart_, ( Operate->Order;
            + " " + Operate->Desc;
            + " " + Operate->Priority;
            + "                     " + Str( RecNo(), 6 ) ) )
        SKIP ALIAS Operate
    ENDDO
    IF !Empty( aPart_ )
        @  1, 54      SAY mrefer COLOR "RG+"
        @  1, Col() + 2 SAY "Select A Index" COLOR "RG+"
        Scroll(  0, 1, 24, 50 )
        DispBox(  0, 0, 24, 50, 2 )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 1, 2, 23, 49, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        GOTO nrecno
        IF PressedEsc()
            RETURN NIL
        ENDIF
        @  4, 59 SAY "A- " + Operate->Order + " " + Operate->Desc
        mnameA := Operate->Order
        @  5, 59 SAY "Can Change" GET mnameA PICTURE "!!"
        READ
        @  5, 59 SAY "                            "
        IF mnameA != Operate->Order
            @ 4, 59 SAY "A-" + mnameA + "                  "
        ENDIF
    ENDIF

    // ** B
    aPart_ := {}
    nrecno := 0
    SELECT Operate
    GOTO TOP
    DO WHILE Operate->( !Eof() )
        IF Operate->Operno != mindex   // +" B"
            SKIP ALIAS Operate
            LOOP
        ENDIF
        IF SubStr( Operate->Priority, 1, 1 ) != "B"
            SKIP ALIAS Operate
            LOOP
        ENDIF
        AAdd( aPart_, ( Operate->Order;
            + " " + Operate->Desc;
            + " " + Operate->Priority;
            + "                    " + Str( RecNo(), 6 ) ) )
        SKIP ALIAS Operate
    ENDDO
    IF !Empty( aPart_ )
        @  1, 6      SAY mrefer           COLOR "RG+"
        @  1, Col() + 6 SAY "Select B Index" COLOR "RG+"
        Scroll( 3, 1, 23, 56 )
        DispBox(  3, 0, 24, 56, 2 )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice( 4, 2, 23, 55, aPart_,, "AFUNC" )
        nrecno := Val( Right( aPart_[ anum ],6 ) )
        GOTO nrecno
        IF PressedEsc()
            RETURN NIL
        ENDIF
        @  5, 59 SAY "B- " + Operate->Order + " " + Operate->Desc
        mnameB := Operate->Order
        @  6, 59 SAY "Can Change" GET mnameB PICTURE "!!"
        READ
        @  6, 59 SAY "                            "
        IF mnameB != Operate->Order
            @ 5, 59 SAY "B-" + mnameB + "                  "
        ENDIF
    ENDIF

    // ** C
    @  7, 59 SAY "Surname 2"
    @  8, 59 SAY "Blank to Select" GET mnameC PICTURE "!!"
    READ
    @  7, 59 SAY "                            "
    @  8, 59 SAY "                            "
    IF mnameC = "  "
        aPart_ := {}
        nrecno := 0
        SELECT Operate
        GOTO TOP
        DO WHILE Operate->( !Eof() )
            IF Operate->Operno != mindex   // +" C"
                SKIP ALIAS Operate
                LOOP
            ENDIF
            IF SubStr( Operate->Priority, 1, 1 ) != "C"
                SKIP ALIAS Operate
                LOOP
            ENDIF
            AAdd( aPart_, ( Operate->Order;
                + " " + Operate->Desc;
                + " " + Operate->Priority;
                + "                    " + Str( RecNo(), 6 ) ) )
            SKIP ALIAS Operate
        ENDDO
        IF !Empty( aPart_ )
            @  1, 6      SAY mrefer           COLOR "RG+"
            @  1, Col() + 6 SAY "Select C Index" COLOR "RG+"
            Scroll( 3, 1, 23, 56 )
            DispBox(  3, 0, 24, 56, 2 )
            ASort( aPart_,,, {| x, y | x < y } )
            anum := AChoice( 4, 2, 23, 55, aPart_,, "AFUNC" )
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            IF PressedEsc()
                RETURN NIL
            ENDIF
            @  6, 59 SAY "C-  " + Operate->Order + " " + Operate->Desc
            mnameC := Operate->Order
        ENDIF
    ENDIF          // blank
    @ 6, 59 SAY "C-" + mnameC + "                  "

    // ** D for Number
    mcard := Str( Note->Nameno )            // Gets latest number
    @  12, 59 SAY "Change # or 99 for 4 Char"
    @  14, 59 SAY "#" GET mcard PICTURE "99"
    READ
    @ 12, 59 SAY Space( 21 )
    @ 14, 59 SAY Space( 21 )
    SELECT Note
    IF mcard = "99"
        mchange := "N"
        @  12, 59 SAY "Change to 4 Char" GET mchange VALID( mchange $ "NY " ) PICTURE "!"
        READ
        IF mchange = "Y"
            mcard := Str( Note->Cardno )          // Gets latest number
            @  12, 59 SAY "4 Char this Entry Only"
            @  14, 59 SAY "#" GET mcard PICTURE "9999"
            READ
            @ 12, 59 SAY Space( 21 )
            @ 14, 59 SAY Space( 21 )
            IF Note->Cardno = Val( mcard )
                ApRLock( 3 )
                IF Note->Cardno > 9999
                    REPLACE Note->Cardno WITH 1001
                ENDIF
                REPLACE Note->Cardno WITH Note->Cardno + 1
                UNLOCK
            ENDIF
            @  7, 59 SAY "C- D- " + mcard + " Number"
            mnameC := SubStr( mcard, 1, 2 )
            mnameD := SubStr( mcard, 3, 2 )
        ENDIF       // mchange
    ELSE
        IF Note->Nameno = Val( mcard )
            ApRLock( 3 )
            IF Note->Nameno > 95
                REPLACE Note->Nameno WITH 10
            ENDIF
            REPLACE Note->Nameno WITH Note->Nameno + 1
            UNLOCK
        ENDIF
        @  7, 59 SAY "D- " + mcard + " Number"
        mnameD := mcard
    ENDIF       // four digits
    mpartnum := mnameA + mnameB + mnameC + mnameD
    mcodeno  := mnameA + mnameB + mnameC + mnameD
    SELECT Operate

    // **********
   /*
   ********************************
      madd := "N"
   ***      @  14,47 SAY "Add New Operate" GET madd VALID( madd $ "NY " ) PICTURE "@!"
   ***       READ
      @  14,47 SAY SPACE( 20 )
      IF madd = "Y"
         SCROLL(  13, 0, 24,44 )
         DISPBOX( 13, 0, 24,44, 2 )
         SELECT Operate
         nl := 14
         cpriority := Operate->Priority
         corder    := Operate->Order
         cprint    := Operate->Print
         ckey      := Operate->Ckey
         cabc      := Operate->ABC
          ApFlock( 3 )
         APPEND BLANK
         Operate->Operno   := coperno
         Operate->Date     := DATE()
         Operate->Priority := cpriority
         Operate->Order    := corder
         Operate->Print    := cprint
         Operate->CKey     := ckey
         Operate->Abc      := cabc
         UNLOCK
          ApRlock( 3 )
         cdesc     := Operate->Desc
         @ nl, 2      SAY coperno COLOR "BG+"
         nl+=2
         @ nl, 2 GET cdesc     PICTURE "@X"
         nl+=2
         @ nl, 2 GET cpriority PICTURE "@!"
         nl+=2
         @ nl, 2      SAY "Order"           GET corder PICTURE "@!"
         @ nl,COL()+2 SAY "Is this Heading" GET cabc   PICTURE "@!"
         nl+=2
         @ nl, 2      SAY "Print on List"   GET cprint PICTURE "@!"
          READ
         SELECT Operate
          ApRlock( 3 )
         Operate->Operno   := coperno
         Operate->Desc     := cdesc
         Operate->Ckey     := ckey
         Operate->priority := cpriority
         Operate->ABC      := cabc
         Operate->Print    := cprint
         UNLOCK
      ENDIF          // madd

   ****************************
         GOTO TOP
         SCROLL(  0, 0, 24,44 )
         DISPBOX(  0,14, 24,44, 2 )
         @  1,16 SAY "Select E - H Index" COLOR "RG+"
         @  3,16 SAY "AAAA   = Skip Selection"
         @  4,16 SAY "ACCO   = Accounts"
         @  5,16 SAY "LESS   = Lessons"
         @  6,16 SAY "NAME   = Name"
         @  7,16 SAY "PART   = Part"
         @  8,16 SAY "TRAI   = Training"
  *** Available Index E - H
         mcardref := SPACE( 4 )
         aPart_ :={}
         nrecno := 0
         IF LASTREC() != 0
            DO WHILE Operate->( !EOF() )
               IF Operate->Operno = "    "
                  SKIP ALIAS Operate
                  LOOP
               ENDIF
               DO WHILE Operate->Operno = mcardref
                  SKIP ALIAS Operate
                  LOOP
               ENDDO
               AADD( aPart_,SUBSTR( Operate->Operno, 1, 4 )+"               "+STR( RECNO(),6 ) )
               mcardref := SUBSTR( Operate->Operno, 1, 4 )
               SKIP ALIAS Operate
            ENDDO
            DISPBOX(  0, 0, 24,12, 2 )
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum := ACHOICE(  1, 1, 23,11, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
            ENDIF
         ENDIF                          // LastRec
         mcardref := SUBSTR( Operate->Operno, 1, 4 )
         @ 22,47      SAY mcardref COLOR "RG+"
         @ 22,COL()+5 SAY "Selected E - H Index"
         mpartnum := mnameA+mnameB+mnameC+mnameD
         mcodeno  := mnameA+mnameB+mnameC+mnameD
   IF mcardref != "AAAE"        // Skip E - H

   *** E
         aPart_:={}
         nrecno := 0
         SELECT Operate
         GOTO TOP
         DO WHILE Operate->( !EOF() )
            IF Operate->Operno != mcardref+" E"
               SKIP ALIAS Operate
               LOOP
            ENDIF
            AADD( aPart_, ( Operate->Desc;
                  +"                    "+STR( RECNO(),6 ) ) )
            SKIP ALIAS Operate
        ENDDO
    IF !EMPTY( aPart_ )
      SCROLL( 0, 0, 24,44 )
      DISPBOX(  0, 0, 24,44, 2 )
      ASORT( aPart_,,,{ | x,y | x < y } )
      anum := ACHOICE( 1, 2, 23,42,aPart_,,"AFUNC" )
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      GOTO nrecno
      IF PressedEsc()
         RETURN NIL
      ENDIF
      @  8,47 SAY Operate->Desc
      madd := "N"
      IF SUBSTR( Operate->Desc, 1, 2 ) = "00"
         @  14,47 SAY "Add New Operate" GET madd VALID( madd $ "NY " ) PICTURE "@!"
          READ
         @  14,47 SAY SPACE( 20 )
      ENDIF                  // = 00
      IF madd = "Y"
         SCROLL(  15, 0, 24,44 )
         DISPBOX( 15, 0, 24,44, 2 )
         SELECT Operate
         nl := 17
         @ nl,10 SAY Operate->Operno
         nl+=2
         cOperno := Operate->Operno
         SELECT Operate
         @ nl,10 SAY "Ref #"    GET cOperno PICTURE "@!"
         READ
          ApFlock( 3 )
         APPEND BLANK
         Operate->Operno  := cOperno
         Operate->Date    := DATE()
         Operate->Priority := cOperno
         UNLOCK
          ApRlock( 3 )
         nl+=2
         @ nl, 3 GET Operate->Desc PICTURE "@X"
         nl+=2
         @ nl,10 SAY "Location" GET Operate->Priority PICTURE "@X"
          READ
         UNLOCK
      ENDIF          // madd
      @   8,47 SAY "E- "+Operate->Desc
      mnameE := SUBSTR( Operate->Desc, 1, 2 )
   ENDIF

   *** F
   aPart_:={}
   nrecno := 0
   SELECT Operate
   GOTO TOP
   DO WHILE Operate->( !EOF() )
      IF Operate->Operno != mcardref+" F"
         SKIP ALIAS Operate
         LOOP
      ENDIF
      AADD( aPart_, ( Operate->Desc;
         +"                    "+STR( RECNO(),6 ) ) )
      SKIP ALIAS Operate
   ENDDO
   IF !EMPTY( aPart_ )
      SCROLL( 1, 1, 23,43 )
      DISPBOX(  0, 0, 24,44, 2 )
      ASORT( aPart_,,,{ | x,y | x < y } )
      anum := ACHOICE( 1, 2, 23,42,aPart_,,"AFUNC" )
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      GOTO nrecno
      IF PressedEsc()
         RETURN NIL
      ENDIF
      @  9,47 SAY Operate->Desc
      madd := "N"
      IF SUBSTR( Operate->Desc, 1, 2 ) = "00"
         @  14,47 SAY "Add New Operate" GET madd VALID( madd $ "NY " ) PICTURE "@!"
          READ
         @  14,47 SAY SPACE( 20 )
      ENDIF                  // = 00
      IF madd = "Y"
         SCROLL(  15, 0, 24,44 )
         DISPBOX( 15, 0, 24,44, 2 )
         SELECT Operate
         nl := 17
         @ nl,10 SAY Operate->Operno
         nl+=2
         cOperno := Operate->Operno
         SELECT Operate
         @ nl,10 SAY "Ref #"    GET cOperno PICTURE "@!"
          READ
          ApFlock( 3 )
         APPEND BLANK
         Operate->Operno  := cOperno
         Operate->Date    := DATE()
         Operate->Priority := cOperno
         UNLOCK
          ApRlock( 3 )
         nl+=2
         @ nl, 3 GET Operate->Desc PICTURE "@X"
         nl+=2
         @ nl,10 SAY "Location" GET Operate->Priority PICTURE "@X"
          READ
         UNLOCK
      ENDIF          // madd
      @ 9,47 SAY "F- "+Operate->Desc
      mnameF := SUBSTR( Operate->Desc, 1, 2 )
   ENDIF

   *** G
   aPart_:={}
   nrecno := 0
   SELECT Operate
   GOTO TOP
   DO WHILE Operate->( !EOF() )
      IF Operate->Operno != mcardref+" G"
         SKIP ALIAS Operate
         LOOP
      ENDIF
      AADD( aPart_, ( Operate->Desc;
         +"                    "+STR( RECNO(),6 ) ) )
      SKIP ALIAS Operate
   ENDDO

   IF !EMPTY( aPart_ )
      SCROLL( 1, 1, 23,43 )
      DISPBOX(  0, 0, 24,44, 2 )
      ASORT( aPart_,,,{ | x,y | x < y } )
      anum := ACHOICE( 1, 2, 23,42,aPart_,,"AFUNC" )
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      GOTO nrecno
      IF PressedEsc()
         RETURN NIL
      ENDIF
      @ 10,47 SAY Operate->Desc
      madd := "N"
      IF SUBSTR( Operate->Desc, 1, 2 ) = "00"
         @  14,47 SAY "Add New Operate" GET madd VALID( madd $ "NY " ) PICTURE "@!"
          READ
         @  14,47 SAY SPACE( 20 )
      ENDIF                  // = 00
      IF madd = "Y"
         cOperno := Operate->Operno
         SCROLL(  15, 0, 24,44 )
         DISPBOX( 15, 0, 24,44, 2 )
         SELECT Operate
         nl := 17
         @ nl,10 SAY Operate->Operno
         nl+=2
         SELECT Operate
         @ nl,10 SAY "Ref #"    GET cOperno PICTURE "@!"
          READ
             ApFlock( 3 )
            APPEND BLANK
            Operate->Operno  := cOperno
            Operate->Date    := DATE()
            Operate->Priority := cOperno
            UNLOCK
          ApRlock( 3 )
         nl+=2
         @ nl, 3 GET Operate->Desc PICTURE "@X"
         nl+=2
         @ nl,10 SAY "Location" GET Operate->Priority PICTURE "@X"
          READ
         UNLOCK
      ENDIF          // madd
      @ 10,47 SAY "G- "+Operate->Desc
      mnameG := SUBSTR( Operate->Desc, 1, 2 )
   ENDIF
   *** H
   aPart_:={}
   nrecno := 0
   SELECT Operate
   GOTO TOP
   DO WHILE Operate->( !EOF() )
      IF Operate->Operno != mcardref+" H"
         SKIP ALIAS Operate
         LOOP
      ENDIF
      AADD( aPart_, ( Operate->Desc;
            +"                    "+STR( RECNO(),6 ) ) )
      SKIP ALIAS Operate
   ENDDO
   IF !EMPTY( aPart_ )
      SCROLL( 1, 1, 23,43 )
      DISPBOX(  0, 0, 24,44, 2 )
      ASORT( aPart_,,,{ | x,y | x < y } )
      anum := ACHOICE( 1, 2, 23,42,aPart_,,"AFUNC" )
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      GOTO nrecno
      IF PressedEsc()
         RETURN NIL
      ENDIF
      @ 11,47 SAY Operate->Desc
      madd := "N"
      IF SUBSTR( Operate->Desc, 1, 2 ) = "00"
         @  14,47 SAY "Add New Operate" GET madd VALID( madd $ "NY " ) PICTURE "@!"
          READ
         @  14,47 SAY SPACE( 20 )
      ENDIF                  // = 00
      IF madd = "Y"
         cOperno := Operate->Operno
         SCROLL(  15, 0, 24,44 )
         DISPBOX( 15, 0, 24,44, 2 )
         SELECT Operate
         nl := 17
         @ nl,10 SAY Operate->Operno
         nl+=2
         SELECT Operate
         @ nl,10 SAY "Ref #"    GET cOperno PICTURE "@!"
          READ
          ApFlock( 3 )
         APPEND BLANK
         Operate->Operno  := cOperno
         Operate->Date    := DATE()
         Operate->Priority := cOperno
         UNLOCK
         ApRlock( 3 )
         nl+=2
         @ nl, 3 GET Operate->Desc PICTURE "@X"
         nl+=2
         @ nl,10 SAY "Location" GET Operate->Priority PICTURE "@X"
          READ
         UNLOCK
      ENDIF          // madd
      @ 11,47 SAY "H- "+Operate->Desc
     mnameH := SUBSTR( Operate->Desc, 1, 2 )
   ENDIF
   mpartnum := mpartnum+mnameE+mnameF+mnameG+mnameH
   ENDIF     / Not Selected E - H
   mdetail :="E-"+mnameE+" F-"+mnameF+" G-"+mnameG+" H-"+mnameH
   *************************************************************
   */

    // ** mrefer
    IF mrefer = "NAME"
        Scroll(  13, 0, 24, 80 )
        DispBox( 13, 0, 24, 80, 2 )
        @ 14, 53 SAY " A B C D"
        @ 15, 47 SAY "Codeno" GET mcodeno PICTURE "@!"
        READ
        SELECT Name
        GOTO TOP
        SEEK mcodeno
        DO WHILE Found()
            @ 17, 47 SAY "Already exists Esc to Quit"
            @ 19, 47 SAY "Codeno" GET mcodeno PICTURE "@!"
            READ
            IF PressedEsc()
                RETURN NIL
            ENDIF
            IF mcodeno == Space( 8 )
                LOOP
            ENDIF
            SEEK mcodeno
        ENDDO                          // FOUND()
        SELECT Name
        ApFLock( 3 )
        APPEND BLANK
        Name->Codeno := mcodeno
        Name->Add4   := Control->U_Add3
        Name->Add5   := Control->U_Add4
        Name->Datein := Date()
        // ***      Name->Desc   := mdetail
        UNLOCK
    ELSE
        SELECT Part
        Scroll(  13, 0, 24, 80 )
        DispBox( 13, 0, 24, 80, 2 )
        @ 14, 47 SAY " A B C D  E F G H  New Partnum"
        @ 16, 47 GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
        READ
        IF PressedEsc()
            mpartnum := Space( 16 )
            RETURN mpartnum
        ENDIF
        SEEK mpartnum
        DO WHILE Found()
            @ 18, 47 SAY "-- Already Used Try again --"
            @ 20, 47 GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
            READ
            IF PressedEsc()
                EXIT
                RETURN Space( 20 )
            ENDIF
            SEEK mpartnum
        ENDDO
        ApFLock( 3 )
        APPEND BLANK
        Part->Partnum   := mpartnum
        Part->Desc      := mpartnum
        Part->Catno     := "AA-BB"           // Catno OK
        Part->PartId    := "INDEX CARD"      // Group
        Part->BoughtOut := "N"
        Part->Codeno    := Control->U_Codeno
        Part->Date      := Date()
        Part->Unit      := "Each"
        UNLOCK
        SELECT Part
        mdesc    := Part->Desc
        mdetail  := Part->Detail            // mdetail
        mdetail1 := Part->Detail1
        mpartnum := Part->Partnum
        mcatno   := Part->Catno
        mpartId  := Part->PartId
        @ 16, 15 SAY "Part No"   GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
        @ 18, 15      SAY "Desc" GET mdesc
        @ 19, 20                 GET mdetail
        @ 20, 20                 GET mdetail1
        @ 21, 20                 GET mcatno
        @ 22, 20                 GET mpartId
        READ
        ApRLock( 3 )
        Part->Partnum := mpartnum
        Part->Desc    := mdesc
        Part->Detail  := mdetail
        Part->Detail1 := mdetail1
        Part->Catno   := mcatno
        Part->PartId  := mpartId
        UNLOCK
    ENDIF             // mrefer

    RETURN NIL
// ** End of Cardadd()

// *-------------------------------------------------------------------

FUNCTION PartDraw()

    cOperno := Space( 8 )
    manother := "Y"
    DO WHILE manother = "Y"

        Scroll()
        DispBox( 0, 0, 2, 79, 2 )
        @ 1, 8 SAY "Viewing Part Details"
        aPart_ := {}
        nrecno   := 0
        SELECT Drawing
        GOTO TOP
        DO WHILE Drawing->( !Eof() )
            AAdd( aPart_, Drawing->Drawno;
                + "  " + Drawing->Desc;
                + "                                       " + Str( RecNo(), 6 ) )
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
        @ 22, 6      PROMPT "1. Add Card Part"
        @ 22, Col() + 2 PROMPT "2. Edit Card Part"
        @ 22, Col() + 2 PROMPT "3. Print"
        @ 22, Col() + 2 PROMPT "4. Name Card"

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
            ApFlock( 3 )
            APPEND BLANK
            Drawing->Drawno := cdrawno
            UNLOCK
            ApRlock( 3 )
            @ nl, 27 SAY "Desc" GET Drawing->Desc PICTURE "@X"
            READ
            UNLOCK

        CASE nselect == 2                // Edit Drawing
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"

                SELECT Drawing
                GOTO TOP
                namount := "N"
                nrecno  := 0
                aPart_  := {}
                DO WHILE Drawing->( !Eof() )
                    AAdd( aPart_, ( Drawing->Drawno + " " + Drawing->Desc;
                        + "   Delete";
                        + "                                           " + Str( RecNo(), 6 ) ) )
                    SKIP ALIAS Drawing
                ENDDO                         // Fault EOF
                Scroll()
                DispBox( 0, 0, 2, 79, 2 )
                @  1, 10 SAY "Edit Card List" COLOR "RG+"
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
                @ Row(), 1 GET Drawing->Drawno PICTURE "@X"
                @ Row(), 10 GET Drawing->Desc     PICTURE "@X"
                @ Row(), 46 GET namount VALID( namount $ "NY " ) PICTURE "@!"
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
            @ nl, 42 SAY "Card Parts"
            @ nl, 62 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                + Str( Year( Date() ), 5 )
            nl += 2
            SELECT Drawing
            GOTO TOP
            DO WHILE Drawing->( !Eof() )
                IF SubStr( Control->U_Name, 1, 4 ) = "SHAN"
                    @ nl, 1 SAY Drawing->Desc
                ELSE
                    @ nl, 1 SAY Drawing->Desc
                    @ nl, 42 SAY Drawing->Drawno
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

        CASE nselect == 4                     // Name
            JobDraw()                       // JobDem.Prg
            LOOP
        ENDCASE
    ENDDO

    RETURN NIL
// **--- End PartDraw()

// **---------------------------------------------------------------------*

FUNCTION Mu_Demand( nc, ncl )

    DO WHILE .T.
        cheading := "JOB DEMAND MENU"
        nselect  := 0
        // **   nc := ncl
        nc := ncl * 2
        Scroll( 3, nc, 21, 78 )
        @  4, nc TO 21, nc + ncl
        Scroll( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  3, nc + 4 TO 5, nc + ( ncl - 4 )
        @  4, nc + ( ncl / 2 ) -( Len( cheading ) / 2 ) SAY cheading
        // ***   @  7,nc+2 PROMPT "1. Job Demand   Add"
        @  9, nc + 2 PROMPT "1. Operations   Add"
        @ 10, nc + 2 PROMPT "2. Admin        Add"
        @ 11, nc + 2 PROMPT "3. Drawings     Add"
        @ 12, nc + 2 PROMPT "4. Labour       Add"
        @ 14, nc + 2 PROMPT "5. Part - Operation"
        @ 20, nc + 2 PROMPT "0. To - Main       "
        nc := ncl

        MENU TO nselect
        DO CASE
        CASE nselect == 6 .OR. PressedEsc()
            RETURN NIL
            // **      CASE nselect == 1
            // **         SAVE SCREEN TO holdscrn
            // **         mjobnum := SPACE( 12 )
            // **          JobFind( mjobnum )                              // XF_Job
            // **         mjobnum := Job->Jobnum
            // **           JobDemAdd( mjobnum )                           // Below
            // **         RESTORE SCREEN FROM holdscrn
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            JobOperate()                                   // JobDem
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 2
            SAVE SCREEN TO holdscrn
            JobAdmin()                                     // Below
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 3
            SAVE SCREEN TO holdscrn
            JobDraw()                                     // Below
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            JobLabour()                                   // JobDem
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5
            SAVE SCREEN TO holdscrn
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
                Scroll()
                mpartnum := Space( 20 )
                SELECT Part
                PartFind( @mpartnum )
                IF PressedEsc()
                    RETURN NIL
                ENDIF
                mpartnum   := Part->Partnum
                PartOper2( mpartnum )                              // Below
                mcontinue := ApGetY( Trim( Message->Another ) + " Part" )
            ENDDO                                       // mcontinue
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// **** End of Mu_Demand()

// **---------------------------------------------------------------------*

FUNCTION JobOperLst( mjobnum )

    manother := "Y"
    DO WHILE manother = "Y"
        Scroll()
        DispBox( 0, 1, 2, 79, 2 )
        @ 1, 10 SAY mjobnum + " " + Job->Desc + " " + Job->Codeno
        Scroll(  4, 0, 24, 80 )
        DispBox( 4, 1,  8, 79, 2 )
        SELECT Name
        SEEK Job->Codeno
        SELECT Job
        @ 5, 10 SAY Trim( Name->Name ) + " " + Job->Jobnum + " " + DToC( Job->Date )
        @ 7, 10 SAY "Desc " + Job->Desc
        DispBox( 9, 5, 18, 79, 2 )
        nselect := 1
        @ 11, 20 PROMPT "Job Operations"
        // ***   @ 13,20 PROMPT "Job     Labour"

        MENU TO nselect
        DO CASE
        CASE LastKey() = 27
            RETURN NIL
        CASE nselect = 1
            mwhere := "S"

            PrintSel( mwhere )

            IF mwhere == "P"
                npl := 56
            ELSE
                npl := 16
            ENDIF
            nl := 2
            @ nl, 10 SAY Trim( Name->Name ) + " " + Job->Jobnum + " " + DToC( Job->Date )
            nl++
            @ nl, 10 SAY "Desc " + Job->Desc
            nl += 2
            SELECT Demand
            GOTO TOP
            SEEK mjobnum
            DO WHILE Demand->Jobnum = mjobnum .AND. Demand->( !Eof() )
                IF Demand->Operno = Space( 8 )
                    SKIP ALIAS Demand
                    LOOP
                ENDIF
                @ nl, 0 SAY Demand->Desc
                @ nl, 31 SAY "Start " + DToC( Demand->StartDate )
                @ nl, 50 SAY "Due " + DToC( Demand->DueDate )
                @ nl, 66 SAY Demand->Operno
                nl++
                SELECT Operate
                // **           SET ORDER TO 1                   // Operno
                SEEK Demand->Operno
                @ nl, 0 SAY Operate->Desc
                @ nl, 41 SAY "Time"
                @ nl, 47 SAY Operate->Time PICTURE "999.99"
                @ nl, 54 SAY "Rate"
                @ nl, 59 SAY Operate->Rate PICTURE "999.99"
                // **         @ nl,64 SAY Operate->Priority
                @ nl, 65 SAY "Set Up"
                @ nl, 73 SAY Operate->Setup PICTURE "999.99"
                // **         @ nl,67 SAY Operate->Date
                nl += 2
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                    nl := 2
                    @ nl, 10 SAY Trim( Name->Name ) + " " + Job->Jobnum + " " + DToC( Job->Date )
                    nl++
                    @ nl, 10 SAY "Desc " + Job->Desc
                ENDIF
                SELECT Demand
                SKIP ALIAS Demand
            ENDDO                     // Demand EOF
            SELECT Demand
            GOTO TOP
            SEEK mjobnum
            DO WHILE Demand->Jobnum = mjobnum .AND. Demand->( !Eof() )
                IF Demand->Adminno = Space( 8 )
                    SKIP ALIAS Demand
                    LOOP
                ENDIF
                @ nl, 0 SAY Demand->Desc
                @ nl, 31 SAY "Start " + DToC( Demand->StartDate )
                @ nl, 50 SAY "Due " + DToC( Demand->DueDate )
                @ nl, 66 SAY Demand->Adminno
                nl++
                SELECT Admin
                SET ORDER TO 2                   // Adminno
                SEEK Demand->Adminno
                @ nl, 0 SAY Admin->Desc
                nl += 2
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                    nl := 2
                    @ nl, 10 SAY Trim( Name->Name ) + " " + Job->Jobnum + " " + DToC( Job->Date )
                    nl++
                    @ nl, 10 SAY "Desc " + Job->Desc
                ENDIF
                SELECT Demand
                SKIP ALIAS Demand
            ENDDO                     // Demand EOF

            SELECT Demand
            GOTO TOP
            SEEK mjobnum
            DO WHILE Demand->Jobnum = mjobnum .AND. Demand->( !Eof() )
                IF Demand->Drawno = Space( 8 )
                    SKIP ALIAS Demand
                    LOOP
                ENDIF
                @ nl, 0 SAY Demand->Desc
                @ nl, 31 SAY "Start " + DToC( Demand->StartDate )
                @ nl, 50 SAY "Due " + DToC( Demand->DueDate )
                @ nl, 66 SAY Demand->Drawno
                nl++
                SELECT Drawing
                // **           SET ORDER TO 3                   // Drawno
                SEEK Demand->Drawno
                @ nl, 0 SAY Drawing->Desc
                nl += 2
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                    nl := 2
                    @ nl, 10 SAY Trim( Name->Name ) + " " + Job->Jobnum + " " + DToC( Job->Date )
                    nl++
                    @ nl, 10 SAY "Desc " + Job->Desc
                ENDIF
                SELECT Demand
                SKIP ALIAS Demand
            ENDDO                     // Demand EOF
            // ************************
            nl++
            SELECT Labour
            GOTO TOP
            INDEX ON Jobnum + Labno TO TempLab
            SET INDEX TO TempLab
            SEEK mjobnum
            DO WHILE Labour->Jobnum = mjobnum .AND. Labour->( !Eof() )
                @ nl, 0 SAY Labour->Labno
                @ nl, 10 SAY Labour->Desc
                @ nl, 51 SAY "Time"
                @ nl, 57 SAY Labour->Time PICTURE "99999.99"
                @ nl, 64 SAY "Rate"
                @ nl, 69 SAY Labour->Rate PICTURE "99999.99"
                nl++
                IF nl > npl
                    IF mwhere = "P"
                        EJECT
                    ELSE
                        WAIT
                        Scroll()
                    ENDIF
                    nl := 2
                ENDIF
                SKIP ALIAS Labour
            ENDDO                     // Labour  EOF
            SELECT Labour
            SET INDEX TO LabInd

        CASE nselect = 2
            // **        LabJobPrint()
        ENDCASE
        IF mwhere = "S"
            Inkey()
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        manother := ApGetN( Message->Another )
    ENDDO                                       // manother

    RETURN NIL
// **** End of JobOperLst

// ****------------------- End of File JobDemnd.PRG
