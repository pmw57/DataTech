// ** JoKir09   30-09-11 06:37:46
// ** Instock, Utd Update

/*  Program.....:                QUOHOUSE.PRG
    Authors.....: J.Kirby
    Date........: 15/05/2010
    Functions...: IvcPrice, QuotChange
*/

FUNCTION IvcPrice( mcont )

    mpartnum := Part->Partnum
    mA := ndiscount := 0
    norgqty   := 0
    nQty      := 1
    nQtyOrg   := 0
    ngoodsent := 0
    nl        := 1
    mok  := "N"
    DO WHILE mok = "N"
        IF Name->Margin = 0              // Adds % for Name->Margin
            mA := Part->Wholesale
        ELSE
            mA := ( ( Part->Wholesale * ( 1 + Name->Margin / 100 ) * 100 ) / 100 )
        ENDIF
        IF mcont = "Y"
            nQty      := Quot->GoodSent
            nQtyOrg   := Quot->Qty
            mA        := Quot->Amount
            ndiscount := Quot->Discount
            SELECT Debit
            ApRLock( 3 )
            DO CASE
            CASE Debit->Note1 = "                       "
                Debit->Note1 := Quot->Sentby + " " + Quot->Docno
            CASE Debit->Note2 = "                       "
                Debit->Note2 := Quot->Sentby + " " + Quot->Docno
            OTHERWISE
                Debit->Note3 := Quot->Sentby + " " + Quot->Docno
            ENDCASE
            UNLOCK
            SELECT Name
            ApRLock( 3 )
            Name->Desc3 := Space( 50 )
            UNLOCK
        ENDIF
        Scroll()
        DispBox( 0, 1, 22, 79, 2 )
        @  1, 4 SAY Name->Name + " " + Name->Add1 + " " + cbranchId
        @  3, 4 SAY Trim( Part->Partnum ) + " " + Trim( Part->Desc )
        @  4, 4 SAY "Used To date " + Str( Part->Utd ) + "        Instock " + Str( Part->Instock )
        SELECT Hist
        SET ORDER TO 1
        SEEK Name->Codeno + Part->Partnum
        nl := 6
        DO WHILE Hist->Codeno = mcodeno .AND. Hist->( !Eof() )
            IF Hist->Partnum != mpartnum
                EXIT
                // **     SKIP ALIAS Hist
                // **     LOOP
            ENDIF
            IF Hist->PDate < Date() -365
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF cbranchId != Space( 2 )
                IF Hist->BranchId != cbranchId
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
            ENDIF
            IF Hist->Partnum = mpartnum
                IF nl > 9
                    nl := 6
                    Scroll( nl, 6, 17, 78 )
                ENDIF
                @ nl, 3      SAY "Last Qty"
                @ nl, Col() + 1 SAY Hist->Qty      PICTURE "99,999"
                @ nl, Col() + 2 SAY "Price"
                @ nl, Col() + 1 SAY Hist->Amount   PICTURE "999,999.99"
                @ nl, Col() + 2 SAY "Disc"
                @ nl, Col() + 1 SAY Hist->Discount PICTURE "9999.99"
                @ nl, Col() + 2 SAY Hist->PDate
                @ nl, Col() + 2 SAY SubStr( Hist->Est, 1, 16 )
                nl++
            ENDIF                     // mpartnum
            SKIP ALIAS Hist
        ENDDO                        // mcodeno
        nl := 9
        SELECT Part
        SET ORDER TO 1
        SEEK mpartnum
        Scroll( 9, 0, 24, 80 )
        coderef  := mpartnum
        MemoDisp( coderef )   // XF-Memo2
        Scroll( 7, 0, 24, 80 )
        SELECT Part
        SEEK mpartnum
        nl := 8
        @ nl, 10      SAY "Ordered"
        @ nl, Col() + 1 SAY nQtyOrg PICTURE "99,999"
        @ nl, Col() + 2 SAY "At"
        @ nl, Col() + 1 SAY mA              PICTURE "$99,999.99"
        @ nl, Col() + 2 SAY "Part Sell"
        @ nl, Col() + 1 SAY Part->Wholesale PICTURE "$999,999.99"
        @ nl, Col() + 2 SAY Part->Unit
        IF ndiscount = 0
            ndiscount := Name->Discount
        ENDIF
        ntrade  := Part->Trade
        cpartId := Part->PartId
        nl += 2
        @ nl, 4      SAY "Order Qty"
        @ nl, Col() + 1 SAY nqtyorg PICTURE "999999.99"
        nl += 2
        @ nl, 4      SAY "Supplied Qty" GET nQty PICTURE "999999.99"
        @ nl, Col() + 2 SAY "Price"        GET mA   PICTURE "999999.99"
        @ nl, Col() + 2 GET ndiscount               PICTURE "99.99"
        @ nl, Col() + 2 SAY Name->MARGIN            PICTURE "999.99" COLOR "G+"
        READ
        minfo   := Invoice->Info
        minfo2  := Invoice->Info2
        minfo3  := Invoice->Info3
        minfo4  := Invoice->Info4
        nl++
        @ nl, 8 SAY "Specific This Invoice Notes" COLOR "G+"
        nl++
        @ nl, 17                GET minfo
        nl++
        @ nl, 17                GET minfo2
        nl++
        @ nl, 17                GET minfo3
        nl++
        @ nl, 17                GET minfo4
        READ
        // **   SELECT Debit
        // **    ApRLock( 3 )
        // **   @ nl, 3 SAY "Sent By 1" GET Debit->Note1 PICTURE "@!"
        // **   nl++
        // **   @ nl, 3 SAY "Sent By 2" GET Debit->Note2 PICTURE "@!"
        // **   nl++
        // **   @ nl, 3 SAY "Sent By 3" GET Debit->Note3 PICTURE "@!"
        // **    READ
        // **   UNLOCK
        IF LastKey() == 27
            RETURN
        ENDIF
        IF nQty = 0
            RETURN
        ENDIF
        SELECT Invoice
        ApFLock( 3 )
        APPEND BLANK
        IF mcont = "Y"
            Invoice->Ordnum := Quot->Ordnum
        ENDIF                                // mcont
        IF Invoice->Ordnum == Space( 16 )
            Invoice->Ordnum := Name->Remarks
        ENDIF                                // Ordnum Blank
        IF Part->PartId = "AAAA"
            Invoice->Ordnum := "ZZZZZZZZZZZZZZZZ"
            nl++
            @ nl, 10 SAY "The ZZZZZZ puts the Freight etc at the bottom don't change"
        ENDIF                                // PartId = AAAA
        nl++
        @ nl, 8 SAY "Ordnum " GET Invoice->Ordnum PICTURE "@K!"
        READ
        UNLOCK
        SELECT Name
        ApRLock( 3 )
        Name->Remarks := Invoice->Ordnum
        UNLOCK
        SELECT Invoice
        ApRLock( 3 )
        Invoice->Invno     := minvno
        Invoice->Codeno    := mcodeno
        Invoice->Amount    := mA
        Invoice->Qty       += nQty
        Invoice->Discount  := ndiscount
        Invoice->Partnum   := Part->Partnum
        Invoice->PartId    := Part->PartId
        Invoice->Wholesale := Part->Wholesale
        IF Invoice->Qty > 0
            IF Part->Partnum != "FREI "
                Invoice->Cost := Part->Trade
            ENDIF
        ENDIF
        Invoice->PDate     := Debit->DBDate
        Invoice->BranchId  := Debit->BranchId
        Invoice->Saleno    := Debit->Saleno
        Invoice->U_Codeno  := Debit->U_Codeno
        Invoice->Info      := minfo
        Invoice->Info2     := minfo2
        Invoice->Info3     := minfo3
        Invoice->Info4     := minfo4
        UNLOCK
        SELECT Part
        ApRLock( 3 )
        IF Part->Instock > 0
            Part->Instock -= nQty
            Part->Utd     += nQty
            nl++
            @ nl, 10      SAY "Changed Instock, Utd " + Part->Partnum
            @ nl, Col() + 2 SAY Part->Instock PICTURE "999,999.99"
            @ nl, Col() + 2 SAY Part->Utd     PICTURE "999,999.99"
            nl++
            @ nl, 10      SAY "Invoiced Part Instock, Utd Changed"
            @ nl, Col() + 2 SAY nQty PICTURE "999,999.99"
            IF Part->Instock <= 0
                Part->Instock = 0
            ENDIF
            Inkey( 1 )
        ELSE
            Part->Instock := 0
        ENDIF
        UNLOCK
        nl++
        norgqty := nqty
        SELECT Equ
        mmodcode := Trim( mpartnum )
        SEEK mmodcode
        mmodcode := Equ->Modcode
        IF Found()
            SELECT Equ
            SET EXACT ON
            ntottrade := ntotwhol := 0
            ntottrade1 := ntotwhol1 := 0
            nrecno2 := nrecno3 := nrecno4 := 0
            nqty1 := nqty2 := nqty3 := nqty4 := 0
            nequ1 := nequ2 := nequ3 := nequ4 := 0
            mmod2 := mmod3 := mmod4 := Space( 16 )
            GOTO TOP
            SEEK mmodcode                // Original Part
            IF Found()
                DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !Eof() )
                    nrecno2 := RecNo()
                    nqty1   := Equ->Partqty
                    SELECT Part
                    SEEK Equ->Partnum
                    IF Part->Instock > norgqty
                        ApRLock( 3 )
                        Part->Instock := Part->Instock - ( norgQty * nqty1 )
                        Part->Utd     := Part->Utd + ( norgQty * nqty1 )
                        IF Part->Instock <= 0
                            Part->Instock = 0
                        ENDIF
                        UNLOCK
                        @ nl, 15      SAY "L1 Changed Module Instock, Utd " + Part->Partnum
                        @ nl, Col() + 2 SAY Part->Instock PICTURE "999,999.99"
                        @ nl, Col() + 2 SAY Part->Utd     PICTURE "999,999.99"
                        // **         INKEY( 1 )     // can take out
                    ENDIF
                    SELECT Equ
                    mmod2   := SubStr( Equ->Partnum, 1, 16 )
                    GOTO TOP
                    SEEK mmod2
                    ntottrade1 += ( Part->Trade * nqty1 )
                    ntotwhol1  += ( Part->Wholesale * nqty1 )
                    IF !Found()
                        ntottrade += ( Part->Trade * nqty1 )
                        ntotwhol  += ( Part->Wholesale * nqty1 )
                    ENDIF
                    IF Found()
                        DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !Eof() )
                            nqty2   := Equ->PartQty
                            nequ2   := ( nqty2 * nqty1 )
                            SELECT Part
                            SEEK Equ->Partnum
                            IF Part->Instock > norgqty
                                ApRLock( 3 )
                                Part->Instock := Part->Instock - ( norgQty * nequ2 )
                                Part->Utd     := Part->Utd + ( norgQty * nequ2 )
                                IF Part->Instock <= 0
                                    Part->Instock = 0
                                ENDIF
                                UNLOCK
                                @ nl, 15      SAY "L2 Changed Module Instock, Utd " + Part->Partnum
                                @ nl, Col() + 2 SAY Part->Instock PICTURE "999,999.99"
                                @ nl, Col() + 2 SAY Part->Utd     PICTURE "999,999.99"
                                // **               INKEY( 1 )
                            ENDIF
                            SELECT Equ
                            mmod3   := SubStr( Equ->Partnum, 1, 16 )
                            nrecno3 := RecNo()
                            GOTO TOP
                            SEEK mmod3
                            IF !Found()
                                ntottrade += ( Part->Trade * nequ2 )
                                ntotwhol  += ( Part->Wholesale * nequ2 )
                            ENDIF
                            IF Found()
                                DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !Eof() )
                                    nqty3   := Equ->PartQty
                                    nequ3   := ( nqty3 * nqty2 ) * nqty1
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    IF Part->Instock > norgqty
                                        ApRLock( 3 )
                                        Part->Instock := Part->Instock - ( norgQty * nequ3 )
                                        Part->Utd     := Part->Utd + ( norgQty * nequ3 )
                                        IF Part->Instock <= 0
                                            Part->Instock = 0
                                        ENDIF
                                        UNLOCK
                                        @ nl, 15      SAY "L3 Changed Module Instock, Utd " + Part->Partnum
                                        @ nl, Col() + 2 SAY Part->Instock PICTURE "999,999.99"
                                        @ nl, Col() + 2 SAY Part->Utd     PICTURE "999,999.99"
                                        // **               INKEY( 1 )
                                    ENDIF
                                    SELECT Equ
                                    mmod4   := SubStr( Equ->Partnum, 1, 16 )
                                    nrecno4 := RecNo()
                                    GOTO TOP
                                    SEEK mmod4
                                    IF !Found()
                                        ntottrade += ( Part->Trade * nequ3 )
                                        ntotwhol  += ( Part->Wholesale * nequ3 )
                                    ENDIF
                                    IF Found()
                                        DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !Eof() )
                                            nqty4 := Equ->PartQty
                                            nequ4 := ( ( ( nqty4 * nqty3 ) * nqty2 ) * nqty1 )
                                            SELECT Part
                                            SEEK Equ->Partnum
                                            IF Part->Instock > norgqty
                                                ApRLock( 3 )
                                                Part->Instock := Part->Instock - ( norgQty * nequ4 )
                                                Part->Utd     := Part->Utd + ( norgQty * nequ4 )
                                                IF Part->Instock <= 0
                                                    Part->Instock = 0
                                                ENDIF
                                                UNLOCK
                                                @ nl, 15 SAY "L4 Changed Module Instock, Utd " + Part->Partnum
                                                @ nl, Col() + 2 SAY Part->Instock PICTURE "999,999.99"
                                                @ nl, Col() + 2 SAY Part->Utd     PICTURE "999,999.99"
                                                // **                  INKEY( 1 )
                                            ENDIF
                                            SELECT Equ
                                            ntottrade += ( Part->Trade * nequ4 )
                                            ntotwhol  += ( Part->Wholesale * nequ4 )
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
                    ENDIF                         // Found mmod2
                    SELECT Equ
                    GOTO nrecno2
                    SKIP ALIAS Equ
                ENDDO                       // mmodcode EOF()
            ENDIF                          // Found mmodcode
            SELECT Equ
            GOTO TOP
            SEEK mmodcode
        ENDIF
        Inkey( 2 )
        mserno  := Space( 15 )
        nSerqty := nQty
/*
TAKEN OUT
   mok := ApGetN( "Do You Want Serial #" )
   IF mok = "Y"
      SELECT PartSer
      GOTO LASTREC()
      mserno := LTRIM( STR( VAL( PartSer->Serno )+1 ) )
      mserno := mserno+"              "
      @ nl,36      SAY "Serial No" GET mserno PICTURE "XXXXXXXXXXXXXXX"
      @ nl,COL()+1 SAY "Blank if No"
       READ
   ENDIF
   IF mserno != SPACE( 15 )
      SELECT PartSer
      DO WHILE nSerqty > 0
          ApFLock( 3 )
         APPEND BLANK
         PartSer->Codeno   := Invoice->Codeno
         PartSer->Partnum  := Invoice->Partnum
         PartSer->Invno    := Invoice->Invno
         PartSer->Serno    := LTRIM( mserno )
         PartSer->PDate    := Debit->DBDate
         PartSer->BranchId := Debit->BranchId
         PartSer->Amount   := ( Invoice->Amount*(1-Invoice->Discount/100 );
                                *100 ) /100.00
         UNLOCK
         nSerqty := nSerqty-1
         mserno  := STR( VAL( mserno )+1,15 )
      ENDDO                     // nqty > 0
   ENDIF
taken out
*/
        // ************   This is what takes time
        SELECT  Hist
        // **   SET ORDER TO 1
        // **   SEEK Invoice->Codeno+Invoice->Partnum+Invoice->Invno
/*
IF SAME Partnum no entry taken out
   IF !FOUND()
        ApFLock( 3 )
       APPEND BLANK
       UNLOCK
   ENDIF
   IF FOUND()
      IF Hist->Amount != Invoice->Amount
          ApFLock( 3 )
         APPEND BLANK
         UNLOCK
      ENDIF
      IF Hist->Discount != Invoice->Discount
          ApFLock( 3 )
         APPEND BLANK
         UNLOCK
      ENDIF
   ENDIF
    ApRLock( 3 )
*/
        ApFLock( 3 )
        APPEND BLANK
        Hist->Amount    := Invoice->Amount
        Hist->Codeno    := Invoice->Codeno
        Hist->Partnum   := Invoice->Partnum
        Hist->Discount  := Invoice->Discount
        Hist->Qty       := Invoice->Qty
        Hist->Stat      := Invoice->Stat
        Hist->Invno     := Invoice->Invno
        Hist->PDate     := Invoice->PDate
        Hist->Wholesale := Invoice->Wholesale
        Hist->Cost      := Invoice->Cost
        Hist->Est       := Invoice->Ordnum
        Hist->BranchId  := Debit->BranchId
        Hist->Saleno    := Debit->Saleno
        Hist->U_Codeno  := Debit->U_Codeno
        Hist->SentBy    := Quot->SentBy
        Hist->Docno     := Quot->Docno
        UNLOCK
        // **   COMMIT
        mok := "Y"

    ENDDO                               // mok

    RETURN( mpartnum )

// ***------- End IvcPrice

// *-------------------------------------------------------------------

FUNCTION QuotChange()

    Scroll()
    DispBox(  0, 1, 24, 79, 2 )
    nl    := 1
    cinit := Space( 3 )
    csent := Space( 9 )
    SELECT Name
    SEEK Quot->Codeno
    SELECT Part
    SEEK Quot->Partnum
    @ nl, 4      SAY Name->Name COLOR "BG+"
    @ nl, Col() + 2 SAY "Branch " + Quot->BranchId
    @ nl, Col() + 2 SAY SubStr( Quot->Partnum, 1, 16 )  COLOR "RG+"
    @ nl, Col() + 1 SAY Trim( Part->Unit )
    nl++
    @ nl, 4      SAY Part->Desc                        COLOR "RG+"
    @ nl, Col() + 2 SAY "Sell Price"                      COLOR "RG+"
    @ nl, Col() + 1 SAY Quot->Amount   PICTURE "99999.99" COLOR "RG+"
    @ nl, Col() + 2 SAY "Disc"
    @ nl, Col() + 1 SAY Quot->Discount PICTURE "9999"
    nl += 2
    @ nl, 3      SAY "Ordered Qty"
    @ nl, Col() + 1 SAY Quot->OrgQty   PICTURE "99999"      COLOR "RG+"
    @ nl, Col() + 1 SAY "Outstanding Qty"
    @ nl, Col() + 1 SAY Quot->Qty      PICTURE "99999"      COLOR "RG+"
    @ nl, Col() + 2 SAY Quot->DbDate   PICTURE "99/99/9999" COLOR "RG+"
    @ nl, Col() + 1 SAY Quot->Faxno                         COLOR "RG+"
    @ nl, Col() + 1 SAY Quot->Ordnum                        COLOR "RG+"
    nl += 2
    SELECT Part
    SET ORDER TO 1
    SEEK mpartnum
    SELECT Quot
    norgqty   := Quot->OrgQty
    nqty      := Quot->Qty
    ngoodsent := Quot->GoodSent
    cordnum   := Quot->Ordnum
    ddbdate   := Quot->DbDate
    dduedate  := Quot->DueDate
    csentby   := Quot->Sentby
    cdocno    := Quot->Docno
    cfaxno    := Quot->Faxno
    cinfo     := Quot->Info
    cinfo2    := Quot->Info2
    cinfo3    := Quot->Info3
    cinfo4    := Quot->Info4
    @ nl, 42      SAY "Reference " + cfaxno PICTURE "@X"
    nl++
    @ nl, 2      SAY Trim( cinfo )  PICTURE "@X"
    @ nl, Col() + 1 SAY Trim( cinfo2 ) PICTURE "@X"
    nl++
    @ nl, 2      SAY Trim( cinfo3 ) PICTURE "@X"
    @ nl, Col() + 1 SAY Trim( cinfo4 ) PICTURE "@X"
    SELECT Hist
    SET ORDER TO 1
    npl := 23
    ndl := 18
    mcodeno   := Quot->Codeno
    SEEK mcodeno
    IF Found()
        DO WHILE Hist->Codeno = mcodeno .AND. Hist->( !Eof() )
            IF Hist->BranchId != Quot->BranchId
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF SubStr( Hist->Partnum, 1, 4 ) = "FREI"
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF Hist->Partnum != Quot->Partnum
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF Hist->PDate < ( Quot->DbDate - 60 )
                SKIP ALIAS Hist
                LOOP
            ENDIF
            IF ndl > npl
                WAIT"   Any Key to Continue"
                Scroll( 18, 2, 23, 77 )
                ndl := 18
            ENDIF                      // nl
            @ ndl, 2 SAY SubStr( Hist->Partnum, 1, 8 );
                + " " + Str( Hist->Qty, 5 );
                + " " + DToC( Hist->PDate );
                + " " + Hist->Invno;
                + " " + SubStr( Hist->Est, 1, 16 );
                + " " + Trim( Hist->Sentby );
                + " " + Trim( Hist->DocNo ) COLOR "RG+"
            ndl++
            SKIP ALIAS Hist
        ENDDO                             // EOF
    ENDIF           // Found Hist
    SELECT Quot
    IF norgQty = 0
        nl += 2
        @ nl, 4      SAY "Ordered     Qty" GET norgQty   PICTURE "99999.99"
        READ
        nqty := norgqty
        nl++
        @ nl, 4      SAY "Outstanding Qty"             COLOR "RG+"
        @ nl, Col() + 2 SAY  nqty      PICTURE "99999.99" COLOR "RG+"
    ELSE
        nl++
        @ nl, 4      SAY "Ordered     Qty" GET norgQty   PICTURE "99999.99"
        @ nl, Col() + 2 SAY "Original Order Qty" COLOR "RG+"
        nl++
        @ nl, 4      SAY "Outstanding Qty" GET nqty      PICTURE "99999.99"
        @ nl, Col() + 2 SAY "PC Changes When Invoiced"      COLOR "RG+"
        @ nl, Col() + 1 SAY "Supplied"                      COLOR "BG+"
        @ nl, Col() + 1 SAY norgqty - nqty PICTURE "99999.99" COLOR "BG+"
        nl++
        @ nl, 4      SAY "To be Invoiced " GET ngoodSent PICTURE "99999.99"
        @ nl, Col() + 2 SAY "Sent Qty When Invoiced Changes" COLOR "RG+"
        nl++
        @ nl, 4 SAY csentby + "  " + cdocno
        csent := SubStr( csentby, 1, 9 )
        IF csent = Space( 9 )
            csent := "XX       "
        ENDIF
        nl++
        @ nl, 4 SAY "Sent by or Blank to Select" GET csent PICTURE "XXXXXXXXX"
        READ
        nl++
        IF csent = Space( 9 )
            Scroll( 1, 68, 23, 78 )
            DispBox( 1, 68, 24, 79, 2 )
            @  5, 70 SAY "Sent By" COLOR "BG+"
            nsel := 1
            @  7, 70 PROMPT "Blank    "
            @  8, 70 PROMPT "Owens    "
            @  9, 70 PROMPT "TNL      "
            @ 10, 70 PROMPT "NZCourier"
            @ 11, 70 PROMPT "FastWays "
            @ 12, 70 PROMPT "Grant    "
            @ 13, 70 PROMPT "Mike     "
            @ 14, 70 PROMPT "Picked Up"
            @ 15, 70 PROMPT "TransWest"
            @ 16, 70 PROMPT "WhiteLine"
            @ 17, 70 PROMPT "OwnCourie"
            @ 18, 70 PROMPT "M.Stream "
            @ 19, 70 PROMPT "Grundy   "
            MENU TO nsel
            DO CASE
            CASE LastKey() == 27
                RETURN
            CASE nsel == 1
                csent := Space( 9 )
            CASE nsel == 2
                csent := "Owens    "
            CASE nsel == 3
                csent := "TNL      "
            CASE nsel == 4
                csent := "NZCourier"
            CASE nsel == 5
                csent := "FastWays"
            CASE nsel == 6
                csent := "Grant    "
            CASE nsel == 7
                csent := "Mike     "
            CASE nsel == 8
                csent := "Picked Up"
            CASE nsel == 9
                csent := "TransWest"
            CASE nsel == 10
                csent := "WhiteLine"
            CASE nsel == 11
                csent := "OwnCourie"
            CASE nsel == 12
                csent := "M.Stream "
            CASE nsel == 13
                csent := "Grundy   "
            ENDCASE
        ENDIF             // / csent
        IF csent = "XX"
            ccent := "  "
        ENDIF
        cinit   := SubStr( csentby, 24, 2 )   // must be first
        csentby := SubStr( csentby, 11, 12 )
        nl++
        @ nl, 3      SAY csent + " "  GET csentby PICTURE "XXXXXXXXXXXX"
        @ nl, Col() + 2 SAY "Initials" GET cinit   PICTURE "!!"
        @ nl, Col() + 2 SAY "Despatch" GET cdocno  PICTURE "XXXXXXXXX"
        READ
        csentby := csent + " " + csentby + " " + cinit
    ENDIF
    nl++
    IF Quot->DbDate != Date()
        @ nl, 21      SAY "Today"
        @ nl, Col() + 1 SAY Date() PICTURE "99/99/9999" COLOR "RG+"
    ENDIF
    @ nl, 44      SAY "Ordered"
    @ nl, Col() + 1 SAY Quot->DbDate PICTURE "99/99/9999" COLOR "RG+"
    nl++
    @ nl, 4      SAY "O/N "       GET cordnum  PICTURE "XXXXXXXXXXXXXXXX"
    @ nl, Col() + 2 SAY "Date"       GET ddbDate  PICTURE "99/99/9999"
    @ nl, Col() + 2 SAY "Due Date"   GET ddueDate PICTURE "99/99/9999"
    nl++
    READ
    SELECT Control
    ApRLock( 3 )
    Control->LastUpd := dduedate
    UNLOCK
    Scroll( 1, 68, 23, 78 )
    DispBox( 1, 68, 24, 79, 2 )
    DO CASE
    CASE cfaxno = "  URGENT"
        mchoice := 1
    CASE cfaxno = " SPECIAL"
        mchoice := 2
    CASE cfaxno = "   PRIOR"
        mchoice := 3
    OTHERWISE
        mchoice := Val( Str( Month( dduedate ) ) ) + 3
    ENDCASE
    @  5, 70 PROMPT "URGENT  "
    @  6, 70 PROMPT "SPECIAL "
    @  7, 70 PROMPT "PRIORITY"
    @ 10, 70 PROMPT "JANUARY "
    @ 11, 70 PROMPT "FEBRUARY"
    @ 12, 70 PROMPT "MARCH   "
    @ 13, 70 PROMPT "APRIL   "
    @ 14, 70 PROMPT "MAY     "
    @ 15, 70 PROMPT "JUNE    "
    @ 16, 70 PROMPT "JULY    "
    @ 17, 70 PROMPT "AUGUST  "
    @ 18, 70 PROMPT "SEPT    "
    @ 19, 70 PROMPT "OCTOBER "
    @ 20, 70 PROMPT "NOVEMBER"
    @ 21, 70 PROMPT "DECEMBER"
    MENU TO mchoice
    DO CASE
    CASE LastKey() = 27
        RETURN
    CASE mchoice == 1
        cfaxno := "  URGENT"
    CASE mchoice == 2
        cfaxno := " SPECIAL"
    CASE mchoice == 3
        cfaxno := "   PRIOR"
    CASE mchoice == 4
        cfaxno := "JANUARY "
    CASE mchoice == 5
        cfaxno := "FEBUARY "
    CASE mchoice == 6
        cfaxno := "MARCH   "
    CASE mchoice == 7
        cfaxno := "APRIL   "
    CASE mchoice == 8
        cfaxno := "MAY     "
    CASE mchoice == 9
        cfaxno := "JUNE    "
    CASE mchoice == 10
        cfaxno := "JULY    "
    CASE mchoice == 11
        cfaxno := "AUGUST  "
    CASE mchoice == 12
        cfaxno := "SEPT    "
    CASE mchoice == 13
        cfaxno := "OCTOBER "
    CASE mchoice == 14
        cfaxno := "NOVEMBER"
    CASE mchoice == 15
        cfaxno := "DECEMBER"
    ENDCASE
    Scroll(  1, 68, 23, 78 )
    Scroll( 14, 2, 17, 78 )
    @ nl, 3      SAY "Ref" GET cfaxno PICTURE "@!"
    @ nl, Col() + 2 GET cinfo            PICTURE "@X"
    nl++
    @ nl, 19 GET cinfo2  PICTURE "@X"
    nl++
    @ nl, 19 GET cinfo3  PICTURE "@X"
    nl++
    @ nl, 19 GET cinfo4  PICTURE "@X"
    READ
    cdocno := SubStr( cdocno, 1, 9 ) + " " + SubStr( cordnum, 1, 10 )
    SELECT Quot
    ApRLock( 3 )
    Quot->OrgQty   := norgqty
    Quot->Qty      := nqty
    Quot->GoodSent := ngoodsent
    Quot->Ordnum   := cordnum
    Quot->DbDate   := ddbdate
    Quot->DueDate  := dduedate
    Quot->Sentby   := csentby
    Quot->Docno    := cdocno
    Quot->Faxno    := cfaxno
    Quot->Info     := cinfo
    Quot->Info2    := cinfo2
    Quot->Info3    := cinfo3
    Quot->Info4    := cinfo4
    Quot->Accepted := "Y"
    UNLOCK
    SELECT Name
    ApRLock( 3 )
    Name->Remarks := cordnum
    Name->Refer   := cfaxno
    Name->Date    := ddbdate
    UNLOCK

    RETURN

// ***------- End QuotChange

// ****------------------- END OF File ChriHous.PRG
