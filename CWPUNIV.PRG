***  JoKir10  02-10-11 08:55:01 
*** Part->UTD
/* 
   Program.....:                   CWPUNIV.PRG
   Author......: John Kirby
   Date........: 03/05/1999
   Functions...: PartVol, PartRec, PartRecP
   Static Funcs: PartVolP, PartRev
*/

FUNCTION PartVol( mcodeno )            // MetMain

   SELECT Name
   SEEK mcodeno
   cordnum := SPACE( 4 )
   IF Name->Status = "Y"              // Received
      cordnum := Orders->Ordnum
   ENDIF               // Name->Status
   mQty    := 0
   nlength := 0
   ncsarea := 0
   nminstk := 0
   ndiscount:= ncost:= namount:= nlinm:= nrate:= nvol:= nlen:= 0
   nInvQty := 0
   mcorrect = "N"
   DO WHILE mcorrect = "N"
      SCROLL( 2, 0, 24,80 )
      DISPBOX( 2, 1, 24,79, 2 )
      nl := 3
      @ nl, 4      SAY TRIM( Part->Partnum ) COLOR "G+"
      @ nl,COL()+2 SAY TRIM( Part->Desc );
              +" "+TRIM( Part->Unit )+" "+Part->Codeno COLOR "BG+"
      nl+=2
      IF Name->Status = "Y"              // Received
         @ nl, 4      SAY "Ordered"+STR( Orders->QtyRec, 8, 2 ) 
         @ nl,COL()+2 SAY "Balance"+STR( Orders->PartQty, 8, 2 )
         @ nl,COL()+2 SAY "IN"+STR( Orders->PartIn, 8, 2 ) COLOR "G+"
         @ nl,COL()+2 SAY "O/N # "+Orders->Ordnum COLOR "BG+"
         IF Orders->Length > 0
            @ nl,COL()+2 SAY "Ord Length"+STR( Orders->Length, 6, 3 )
         ENDIF
         IF Orders->PartIn = 0
            nl++
            @ nl, 2 SAY "Part Received = 0" COLOR "R+"
         ENDIF
         nl+=2
         SELECT Orders
         nrecno  := RECNO()
         IF PressedEsc()
            Partrec()
         ENDIF
      ENDIF                           // Name Status
      SELECT Part
      nselect := 1
      DO CASE 
         CASE Part->Unit = "Each      "
            nselect := 1
         CASE Part->Unit = "Mtr       "
            nselect := 2
         CASE Part->Unit = "Sq Mtr    "
            nselect := 3
         CASE Part->Unit = "Cu Mtr    "
            nselect := 4
      ENDCASE
      @ nl, 4      PROMPT "Each"
      @ nl,COL()+2 PROMPT "Mtr"
      @ nl,COL()+2 PROMPT "Sq Mtr"
      @ nl,COL()+2 PROMPT "Cu Mtr"
      MENU TO nselect
       ApRLock( 3 )
      DO CASE
         CASE nselect == 1
            Part->Unit := "Each"
         CASE nselect == 2
            Part->Unit := "Mtr"
         CASE nselect == 3
            Part->Unit := "Sq Mtr"
         CASE nselect == 4
            Part->Unit := "Cu Mtr"
      ENDCASE 
      UNLOCK
      @  nl,30      SAY "In Stock"
      @  nl,COL()+1 SAY Part->Instock PICTURE "99,999.99"
      @  nl,COL()+2 SAY "Cost"
      @  nl,COL()+1 SAY Part->Trade   PICTURE "$99,999.99"
      nl+=2
      IF Name->Status = "N"                    // Test this
         IF SUBSTR( mpartnum, 1, 2 ) != "ZZ"
            SELECT Orders
            SET ORDER TO 1                        // Partnum
            GOTO TOP
            SEEK mpartnum
            nTotal := 0
            IF FOUND()
               nll := 16
               DISPBOX( 15, 3, 22,45, 2 )
               @ 15,20 SAY " - Orders - " COLOR "BG+"
               DO WHILE Orders->Partnum = mpartnum .AND. Orders->( !EOF() )
                  IF nll > 21
                     INKEY( 1 )
                     SCROLL( 16, 4, 21,44 )
                     nll := 16
                  ENDIF
                  @ nll, 4      SAY Orders->Ordnum
                  @ nll,COL()+1 SAY Orders->Qtyrec  PICTURE "9,999.99" COLOR "G+"
                  @ nll,COL()+1 SAY Orders->PartRec PICTURE "9,999.99"
                  @ nll,COL()+1 SAY Orders->PartIn  PICTURE "9,999.99"
                  *** no space for this @ nll,COL()+1 SAY Orders->Length  PICTURE "999.99"
                  ***                 @ nll,COL()+1 SAY Orders->Date 
                  nll++
                  nTotal += Orders->PartQty 
                  SKIP ALIAS Orders
               ENDDO
               @ 23, 5      SAY TRIM( mpartnum )+" Ordered" 
               @ 23,COL()+1 SAY nTotal PICTURE "9,999.99" COLOR "G+" 
            ENDIF                            // Found
            GOTO nrecno      // Orders Record #
            SELECT QuotStk
            SET ORDER TO 2                        // Partnum
            GOTO TOP
            SEEK mpartnum
            nTotal := 0
            IF FOUND()
               nll := 13
               DISPBOX( 12,47, 22,78, 2 )
               @  12,54 SAY " - Job Cards - " COLOR "BG+"
               DO WHILE QuotStk->Partnum = mpartnum .AND. QuotStk->( !EOF() )
                  IF nll > 21
                     INKEY( 1 )
                     SCROLL( 13,48,21,77 )
                     nll := 13
                  ENDIF
                  IF QuotStk->Received >= QuotStk->Required
                     SKIP ALIAS QuotStk
                     LOOP
                  ENDIF                 
                  IF QuotStk->Required-QuotStk->Received > 0
                     @ nll,49      SAY QuotStk->Invno
                     @ nll,COL()+1 SAY QuotStk->Required-QuotStk->Received;
                                   PICTURE "9,999.99" COLOR "G+"
                     @ nll,Col()+2 SAY SUBSTR( QuotStk->Modcode, 1,10 ) 
                     nll++
                     nTotal += QuotStk->Required-QuotStk->Received 
                  ENDIF
                  SKIP ALIAS QuotStk
               ENDDO
               @ 23,47      SAY TRIM( mpartnum )+" Out"
               IF nTotal >= 0 
                  @ 23,COL()+1 SAY nTotal PICTURE "9,999.99" COLOR "G+"
               ENDIF  
            ENDIF                            // Found
         ENDIF
      ENDIF     // Name Status = "N"
      DO CASE

         CASE Part->Unit = "Sq Mtr    "
            nwidth  := Part->Width/1000
            nlength := Part->Length
            mQty    := Part->Instock
            SELECT Part
            IF Name->Status = "Y"              // Received
               nvol := Orders->PartIn         
             ELSE
               nvol := Part->Instock/( nwidth*nlength ) 
            ENDIF
            ncost     := Part->Trade*( nwidth*nlength )
            ndiscount := 0
            @ nl, 6      SAY "Width in Mtr"  GET nwidth  PICTURE "999999.99"
            @ nl,COL()+2 SAY "Length in Mtr" GET nlength PICTURE "999999.999"
            nl+=2
            IF Name->Status = "Y"
               @  nl, 6      SAY "Sheets Received" GET nvol  PICTURE "999999.99"
               @  nl,COL()+1 SAY "Cost per Sheet"  GET ncost PICTURE "99999.99"
               @  nl,COL()+2 SAY "Discount"        GET ndiscount PICTURE "99.99"
                READ
               ***            SCROLL( nl+1, 2, 23,78 )
               ***            DISPBOX( 3, 1, 24,79, 2 )
               nl+=2
               ncost := ncost/( nwidth*nlength )
               mQty  := ( nlength*nwidth )*nvol
               @  nl, 6      SAY "Cost Per Sq Mtr" GET ncost  PICTURE "999999.99"
               @  nl,42      SAY "Sq Mtrs "+STR( mQty, 8, 2 )
                READ
             ELSE
               @  nl, 6      SAY "Sheets in Stock"  GET nvol   PICTURE "999999.99"
                READ
               ***            SCROLL( nl+1, 2, 23,78 )
               ***            DISPBOX( 3, 1, 24,79, 2 )
               mqty := ( nlength*nwidth )*nvol
               @ nl,42 SAY "Sq Mtrs "+STR( mQty, 9, 2 )
            ENDIF
            IF PressedEsc()
               RETURN NIL
            ENDIF
            SELECT Part
             ApRLock( 3 )
            Part->Width   := nwidth*1000   // Convert to Mtr
            Part->Length  := nlength
            Part->Instock := mQty
            Part->Trade   := ncost  
            UNLOCK
           
         CASE Part->Unit = "Cu Mtr    "
            nvol    := Part->Width
            nrate   := Part->Thick
            nlength := Part->Length
           nl++
           @  nl, 6      SAY "Volume Cu/M"   GET nvol   PICTURE "999.99"
           @  nl,COL()+2 SAY "Rate per Cu/M" GET nrate  PICTURE "999.99"
            READ
            ***    SCROLL( nl+1, 2, 23,78 )
            ***    DISPBOX( 3, 1, 24,79, 2 )
            IF PressedEsc()
               RETURN NIL
            ENDIF
            ** Calculate cross-section area in square metres
            ncsarea := ( Part->Width*Part->Thick )/1000000
            ** Calculate linear metres
            nlen := nvol/ncsarea
            ** Calculate cost per linear metre.
            ** Must allow for variable volume here  (Try various volumes for
            **   same width & thickness - cost should be constant)
            ncost=( nrate/nlen )*nvol
            ** Wastage Factor 10%
            ** Show total linear & cost
            ncost := ncost*1.1
            ncsarea := ( Part->Width*Part->Thick ) // cross sectional area in sq mm
            ncsarea := ncsarea/1000000             // cross sectional area in sq metres
            ** ( Could combine above two lines into one calculation )
            mQty := nvol/ncsarea         // length in metres
            nl+=2
            @  nl, 6      SAY "Per Mtr+10% "+STR( ncost,6,3 ) COLOR "G+"
            @  nl,COL()+1 SAY "Mtrs "+STR( nlen,5 ) COLOR "G+"
            @  nl,COL()+1 SAY "Length"   GET nlength   PICTURE "999999.99"
            @  nl,COL()+1 SAY "Discount" GET ndiscount PICTURE "99.99"
            @  nl,74 SAY "* "+Name->Status
            READ
             ApRLock( 3 )
            Part->Width  := nrate
            Part->Thick  := nvol
            Part->Length := nlength 
            UNLOCK
            IF PressedEsc()
               RETURN NIL
            ENDIF

         CASE Part->Unit = "Mtr       "                 // Linear Mtr
            IF Name->Status = "Y"              // Received
               ***           SCROLL( nl+1, 2, 23,78 )
               ***           DISPBOX( 3, 1, 24,79, 2 )
               nlength := Orders->Length
               ncost   := Part->Trade*nlength
               mQty    := Orders->PartIn
               @ nl, 6      SAY "Length of Item Rec " GET nlength PICTURE "99999.99"
               @ nl,COL()+2 SAY "Ordered Length in Mtrs "+STR( nlength, 8, 2 )
               nl++
               SELECT Part
               @ nl, 6      SAY "Received Length Cost " GET ncost PICTURE "99999.99"
               @ nl,COL()+2 SAY "File Length Cost"
               @ nl,COL()+1 SAY Part->Trade*Part->Length PICTURE "$9,999.99"
               nl++
               @ nl, 6      SAY "Received Length  Qty"  GET mQty PICTURE "999999.99"
                READ
                ***           SCROLL( nl+1, 2, 23,78 )
                ***           DISPBOX( 3, 1, 24,79, 2 )
               ncost := ncost/nlength
               nl++
               @ nl, 6      SAY "        Cost Per Mtr"  GET ncost     PICTURE "99999.999"
               @ nl,COL()+2 SAY "Discount %"            GET ndiscount PICTURE "99.99"
                READ
               nl++
               mQty := mQty*nlength
               @ nl, 6      SAY "        Rec  Qty Mtr " GET mQty      PICTURE "99999.999"
               @ nl,COL()+6 SAY "Received Length "+STR( nlength,12, 3 )    
               nl++
                READ      
               ***           SCROLL( nl+1, 3, 22,78 )
            ELSE
               SELECT Part
               nlength := Part->Length
               mQty := Part->Instock/Part->Length
               @ nl, 6      SAY "Length Each"  GET nlength 
               @ nl,COL()+2 SAY "Qty Lengths"  GET mQty      PICTURE "999999.99" 
                READ
               mQty := nlength*mQty
               nl++
               @  nl, 6      SAY "    Mtr Qty"  GET mQty PICTURE "999999.99"
               @  nl,COL()+2 SAY "Mininum" GET nminstk   PICTURE "999999.99"
               @  nl,64 SAY "* "+Name->Status
                READ
                ApRLock( 3 )
               Part->Length  := nlength
               Part->MinStk  := nminstk
               Part->Instock := mQty 
               UNLOCK
            ENDIF
            IF PressedEsc()
               RETURN NIL
            ENDIF

         CASE Part->Unit = "Each      "
            mQty    := Part->Instock
            nminstk := Part->MinStk
            IF Name->Status = "Y"
               mQty  := Orders->PartIn
               ncost := Part->Trade
               @ nl, 6      SAY "Received Qty" GET mQty      PICTURE "99999.99"
               @ nl,COL()+1 SAY "Cost"         GET ncost     PICTURE "999999.99"
               @ nl,COL()+2 SAY "Discount %"     GET ndiscount PICTURE "99.99"
               nl++
                READ
             ELSE
               @  nl, 6 SAY "Part Instock"     GET mQty       PICTURE "99999.99"
               @  nl,34 SAY "Mininum"          GET nminstk    PICTURE "99999.99"
               @  nl,64 SAY "* "+Name->Status
               nl++
                READ
               SELECT Part
                ApRLock( 3 )
               Part->Instock := mQty 
               Part->MinStk  := nminstk
               UNLOCK
            ENDIF
            IF PressedEsc()
               RETURN NIL
            ENDIF

         OTHERWISE
            mQty := Part->Instock
            nl+=2
            @  nl, 6 SAY "Part Instock" GET mQty PICTURE "99999.99"
            @  nl,64 SAY "* "+Name->Status
            READ
            SELECT Part
            ApRLock( 3 )
            Part->Instock := mQty 
            ***         Part->MinStk  := nminstk
            UNLOCK
            IF PressedEsc()
               RETURN NIL
            ENDIF
      ENDCASE
      IF Name->Status = "Y"             // Only on Receipt  
         ***     SCROLL( nl+1, 2, 23,78 )
         ***     DISPBOX( 2, 1, 24,79, 2 )
         namount := ( ncost*( 1-( ndiscount/100) ) )
         SELECT Part
         nwholesale := Part->Wholesale
         nmargin    := Part->Margin
         ntrade     := Part->Trade
         nmarkup    := Part->Markup
         mcodeno    := Part->Codeno
         nl++
         ***     SCROLL( nl, 3, nl,78 )
         @ nl, 3      SAY "Cost "+TRIM( Part->Unit )
         @ nl,COL()+1 SAY  namount PICTURE "999,999.99" COLOR "G+"
         nmarkup := ( ( Part->Wholesale-Part->Trade ) /Part->Trade ) *100
         @ nl,COL()+2 SAY "File"      GET ntrade  PICTURE "999999.99"
         @ nl,COL()+1 SAY "Mkup %"    GET nmarkup PICTURE "999.99"
         @ nl,COL()+1 SAY nmarkup                 PICTURE "999.99"
         @ nl,COL()+1 SAY namount*mqty            PICTURE "$9,999,999.99"
          READ
         nl+=2
         nsell := ( ntrade* ( 1+( nmarkup/100) ) )
         IF SUBSTR( Control->U_Name,1,5 ) != "CHRIS"
            nwholesale := ( ntrade* ( 1+( nmarkup/100) ) )
         ELSE
            @ nl,69 SAY nsell PICTURE "99,999.99" COLOR "G+"
            nl++
         ENDIF
         ddate := DATE()
         @ nl, 3      SAY "Sell Less GST" GET nwholesale PICTURE "999999.99"
         @ nl,COL()+1 SAY "Date"          GET ddate      PICTURE "99/99/9999"
         @ nl,COL()+1 SAY "Supplier"      GET mcodeno    PICTURE "@!"
         @ nl,COL()+2 SAY Name->Codeno
          READ
         IF mcodeno = SPACE( 8 )
            mcodeno := Name->Codeno
         ENDIF                 
         nmarkup    := ( ( nwholesale-ntrade ) /ntrade ) *100
         IF nmargin == 0
            nmargin := nmarkup
         ENDIF
         SELECT Part
          ApRLock( 3 )
         Part->Wholesale := nwholesale
         Part->Margin    := nmargin
         Part->Trade     := ntrade
         Part->Markup    := nmarkup
         Part->Codeno    := mcodeno
         Part->Date      := DATE()
         UNLOCK
         SELECT Supl
         SET ORDER TO 1                         // Partnum+Codeno
         SEEK Part->Partnum+Name->Codeno
          ApFLock( 3 )
         IF !FOUND()
            APPEND BLANK
            Supl->Codeno  := Name->Codeno
            Supl->Partnum := Part->Partnum
            ***        Supl->SuppId  := Part->Partnum
         ENDIF
         IF ncost > 0
            Supl->Cost := ncost
         ENDIF  
         Supl->Qty     := mQty
         Supl->Date    := ddate
         nl+=2
         @ nl, 3      SAY "Supplier #" GET Supl->SuppId PICTURE "@!"
         @ nl,COL()+2 SAY "Important for Order" COLOR "G+"
          READ
         UNLOCK
         IF SUBSTR( Part->Partnum, 1, 3 ) = "TEM"
            SELECT Part 
            mdesc := Part->Desc
            @ nl,33 GET mdesc
             READ
             ApRLock( 3 )
            Part->Desc := mdesc
            UNLOCK
         ENDIF
         IF PressedEsc()
            RETURN NIL
         ENDIF
         *** ENDIF          // Name->Status
         SELECT Part
         nselect := 1
         mboughtout := Part->Boughtout
         DO CASE 
            CASE Part->Boughtout = "Y"
                 nselect := 1
            CASE Part->Boughtout = "N"
                 nselect := 2
         ENDCASE
         nl+=2
         @ nl, 3      PROMPT "Part Bought Out"
         @ nl,COL()+2 PROMPT "Own Manufacture"
         MENU TO nselect
         DO CASE
            CASE nselect == 1
                 mboughtout := "Y"
            CASE nselect == 2
                 mboughtout := "N"
         ENDCASE
          ApRLock( 3 )
            Part->Boughtout := mboughtout
            Part->Utd += mQty
            ****   Part->Instock += mQty //  no do this at metpart metmark 
          UNLOCK
         @ nl,38      SAY "In Stock" COLOR "G+"
         @ nl,COL()+1 SAY Part->Instock PICTURE "999,999.999" COLOR "G+"
         @ nl,COL()+2 SAY Part->ABC+" UTD" COLOR "G+"
         @ nl,COL()+1 SAY Part->UTD PICTURE "999,999.999" COLOR "G+"
         nl++
         *** IF nl >= 19
         ***   SCROLL( 19, 2, 23,78 )
         ***   nl := 20
         *** ENDIF
      ENDIF   // Name Status 
      IF Name->Status = "N"
         IF cordnum = SPACE( 4 )
            nTotal := 0 
            nll := 13
            DISPBOX( 12,47, 22,78, 2 )
            @  12,54 SAY " - Job Cards - " COLOR "BG+"
            SELECT QuotStk
            GOTO TOP
            SET ORDER TO 2               // Partnum
            SEEK mpartnum
            DO WHILE QuotStk->Partnum = mpartnum .AND. QuotStk->( !EOF() )
               IF nll > 21
                  INKEY( 1 )
                  SCROLL( 13,48,21,77 )
                  nll := 13
               ENDIF
               IF QuotStk->Received >= QuotStk->Required
                  SKIP ALIAS QuotStk
                  LOOP
               ENDIF                 
               IF QuotStk->Required-QuotStk->Received > 0
                  @ nll,49      SAY QuotStk->Invno
                  @ nll,COL()+1 SAY QuotStk->Required-QuotStk->Received;
                                PICTURE "9,999.99" COLOR "G+"
                  @ nll,Col()+2 SAY SUBSTR( QuotStk->Modcode, 1,10 ) 
                  nll++
                  nTotal += QuotStk->Required-QuotStk->Received 
               ENDIF
               SKIP ALIAS QuotStk
            ENDDO
            IF nTotal > 0 
               @ 23,47      SAY TRIM( mpartnum )+" Out"
               @ 23,COL()+1 SAY nTotal PICTURE "999,999.99" COLOR "G+"
            ENDIF  

            IF nTotal > 0
               missue := ApGetN( "Want to issue to JC-" )

               IF missue = "Y"
                  nQty:= mQty := Part->Instock
                  IF mQty > 0
                     SELECT QuotStk
                     SET ORDER TO 2                        // Partnum
                     GOTO TOP
                     SEEK Part->Partnum
                     nInvQty := 0
                     cStat   := "Y"
                     IF FOUND()
                        SCROLL(  14, 2, 23,46 )
                        DO WHILE cStat = "Y"
                           SELECT QuotStk
                           SET ORDER TO 2                        // Partnum
                           GOTO TOP
                           SEEK Part->Partnum 
                           anum := aPart_ := {}
                           nrecno := 0
                           mInvno := SPACE( 6 )
                           DO WHILE QuotStk->Partnum = Part->Partnum .AND. QuotStk->( !EOF() )
                              IF QuotStk->Received >= QuotStk->Required
                                 SKIP ALIAS QuotStk
                                 LOOP
                              ENDIF                 
                              AADD( aPart_,QuotStk->Invno;
                                        +" "+STR( QuotStk->Required-QuotStk->Received,10, 2 );
                                        +" "+SUBSTR( QuotStk->ModCode, 1,11 );
                                        +"              "+STR( RECNO(),6 )) 
                              SKIP ALIAS QuotStk
                           ENDDO
                           nll := 13
                           SCROLL( 13,48,21,77 )
                           DISPBOX( 12,47, 22,78, 2 ) 
                           @  12,54 SAY " - Job Cards - " COLOR "BG+"
                           IF !EMPTY( aPart_ )
                              anum   := ACHOICE( 13,48, 21,77,aPart_,"","AFUNC")  // AFUNC in XLP_Init
                              IF PressedEsc()
                                 RETURN NIL
                              ENDIF
                              nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
                              GOTO nrecno
                              mInvno  := QuotStk->Invno
                              nInvQty := QuotStk->Required-QuotStk->Received
                           ENDIF                     // Empty
                           IF QuotStk->Received >= QuotStk->Required
                              @ 16, 6 SAY "Already Entered This"
                           ELSE  
                              @ 17, 6 SAY TRIM( Part->Unit )+"  "+mInvno+" Qty" GET nInvQty PICTURE "99999.999"
                               READ
                              DO WHILE nInvQty > mQty
                                 @ 15, 9      SAY "In Stock"
                                 @ 15,COL()+1 SAY Part->Instock PICTURE "999,999.99"   
                                 @ 15,COL()+1 SAY Part->Unit
                                 @ 16, 2      SAY "Qty Issued More than Required"   
                                 @ 16,COL()+1 SAY Part->Instock PICTURE "99,999.99" COLOR "BG+" 
                                 @ 17, 6      SAY TRIM( Part->Unit )+"  "+mInvno+" Qty" GET nInvQty PICTURE "99999.999"
                                  READ
                                 IF PressedEsc()
                                    RETURN NIL
                                 ENDIF
                              ENDDO
                              SELECT QuotStk
                               ApRLock( 3 )
                              QuotStk->Received += nInvQty
                              QuotStk->Ordnum   := "Stck"
                              UNLOCK
                              SELECT Labour
                               ApFLock( 3 )
                              APPEND BLANK
                              Labour->Partnum := Part->Partnum
                              Labour->Desc    := Part->Desc
                              Labour->Rate    := Part->Trade
                              Labour->Codeno  := "Stock---"
                              Labour->Invno   := minvno
                              Labour->Time    := nInvQty
                              Labour->Date    := DATE()
                              Labour->Fault   := QuotStk->Modcode
                              UNLOCK
                              SELECT Part
                               ApRLock( 3 )
                              Part->Instock -= nInvQty
                              UNLOCK
                                 mQty -= nInvQty    // Testing this
                           ENDIF
                           cstat := ApGetY( "Another Job Card Entry" )
                           DISPBOX( 2, 1, 24,79, 2 )
                           IF PressedEsc()
                              RETURN NIL
                           ENDIF
                        ENDDO                                 // cStat
                     ENDIF                                 // Found
                  ENDIF                    // > 0 Part Instock
               ENDIF              // missue 
            ENDIF                // nTotal > 0
         ENDIF                     // cordnum   
      ENDIF  // Name Status = N 
      mcorrect := ApGetY( TRIM( Message->Correct ) )
   ENDDO                                              // mcorrect 
   IF Name->Status = "Y"             // Only on Receipt  
      IF mQty > 0
         SELECT ProfNat
          ApFLock( 3 )
         APPEND BLANK
         ProfNat->Codeno   := Name->Codeno
         ProfNat->Partnum  := Part->Partnum
         ProfNat->Qty      := mQty
         ProfNat->Cost     := ncost
         ProfNat->Discount := ndiscount
         ProfNat->Amount   := mQty*ncost
         ProfNat->PDate    := ddate
         ProfNat->Ordnum   := cordnum 
    ***  NO GOOD        ProfNat->Invno    := SUBSTR( minvno, 1, 6 )   // C,10 Not working ???
         UNLOCK
      ENDIF 
      IF mQty > 0
         SELECT Hist
          ApFLock( 3 )
         APPEND BLANK
         Hist->Codeno   := Name->Codeno
         Hist->Partnum  := Part->Partnum
         Hist->Qty      := mQty
         Hist->Cost     := ncost
         Hist->Discount := ndiscount
         Hist->Amount   := ncost        // This is the part cost
         Hist->PDate    := ddate
         Hist->Invno    := cordnum 
         UNLOCK
      ENDIF

      SELECT Orders
      GOTO nrecno
      ApRLock( 3 )
      DO CASE
         CASE Part->Unit == "Sq Mtr    "
            Orders->Partqty -= nvol
            Orders->Partin  -= nvol
         CASE Part->Unit == "Mtr       "
            Orders->Partqty -= mQty/Orders->Length
            Orders->Partin  -= mQty/Orders->Length
         CASE Part->Unit == "Each      " 
            Orders->Partqty -= mQty
            Orders->Partin  -= mQty
         OTHERWISE
            Orders->Partin  -= mQty
            Orders->Partqty -= mQty
      ENDCASE
      IF Orders->Partqty <= 0
         DELETE
      ENDIF
      UNLOCK
      IF Orders->PartQty > 0 
         nl++
         @ nl,13 SAY "Still On Order "+TRIM( Orders->Partnum );
                     +" "+STR( Orders->PartQty, 8, 2 );
                     +" Length Mtr "+STR( Orders->Length, 6, 2 )
      ENDIF                 // PartQty > 0
   ENDIF                       // Name->Status

   RETURN NIL
   ***------- PartVol()

   ****-------------------------------------------------------------------

FUNCTION PartRec()    // MetMain
   mcodeno   := SPACE( 8 )
   mtempcode := "A       "
   nrecno    := 0
   aPart_    := {}
   SELECT Orders
   SET ORDER TO 3                           // Codeno+Ordnum
   GOTO TOP
   SEEK mtempcode
   IF !FOUND()
       ApFLock( 3 )
      APPEND BLANK
      Orders->Codeno := "A       " 
      UNLOCK
   ENDIF 
   GOTO TOP
   IF LASTREC() != 0
      DO WHILE Orders->( !EOF() )
          IF Orders->Codeno = mcodeno
             SKIP ALIAS Orders
             LOOP
          ENDIF
          SELECT Name
          SEEK Orders->Codeno
          mcodeno := Name->Codeno          
          SELECT Orders
          AADD( aPart_,Name->Name;
              +"       "+STR( RECNO(),6 ) )
          SKIP ALIAS Orders
      ENDDO                          // EOF()
      SCROLL() 
      DISPBOX(  0,48,  2,79, 2 )
      @  1,50 SAY "Select From Existing Orders"
      @ 12,50 SAY "F2 To View ALL Orders" COLOR "BG+"
      DISPBOX(  0, 1, 24,45, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum   := ACHOICE(  1, 3, 23,41, aPart_,,"AFUNC" )    
         IF PressedEsc() 
            Menu()
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         mcodeno := Orders->Codeno
         SELECT Name
         SEEK mcodeno
         IF LASTKEY() == -1
           SELECT Orders
           SET ORDER TO 3                   // Codeno+Ordnum
              nrecno := 0
              aPart_ := {}
              DO WHILE Orders->( !EOF() )
                 SELECT Part
                 SET ORDER TO 1                 // Partnum
                 SEEK Orders->Partnum
                 SELECT Orders
                 cdesc := SUBSTR( Orders->Detail1, 1,30 ) 
                 IF cdesc = SPACE( 30 )
                    cdesc := SUBSTR( Part->Desc, 1,30 )
                 ENDIF 
                 IF cdesc = SPACE( 30 )
                    cdesc := SUBSTR( Orders->Detail2, 1,30 )
                 ENDIF 
               AADD( aPart_,Orders->Ordnum;
                  +" "+Orders->Codeno;
                  +" "+DTOC( Orders->Date );
                  +" "+SUBSTR( Part->Partnum, 1, 8 );
                  +" "+cdesc;
                  +" "+STR( Orders->PartQty, 8, 2 );
                  +"      "+STR( RECNO(),6 ) )
                 SKIP ALIAS Orders
             ENDDO                  // Orders
             IF !EMPTY( aPart_ )
                SCROLL(   0, 0, 24,80 )
                DISPBOX(  0, 1, 24,79, 2 )
                ASORT( aPart_,,,{ | x,y | x < y } )
                anum := ACHOICE(  1, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
                IF PressedEsc() 
                   RETURN NIL
                ENDIF
                nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
                GOTO nrecno
                mcodeno := Orders->Codeno
                SELECT Name
                SEEK mcodeno
             ENDIF                        // Empty
         ENDIF
         IF PressedEsc() 
            RETURN NIL
         ENDIF
      ENDIF                             // F1
      SCROLL()
      DISPBOX(  0, 1, 2,79, 2 )
      @  1, 4 SAY Name->Codeno+"  "+Name->Name
      @  1,60 SAY STR( DAY( DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR( DATE() ),5 )
    ENDIF                        // LastRec
   mok := "N"
   IF mcodeno = "A       "
      SELECT Name
        Namerank()                                     // ZFS_Name
      IF PressedEsc()
         RETURN NIL
      ENDIF
   ENDIF
   IF mcodeno = SPACE( 8 )
      SELECT Name
        Namerank()                                     // ZFS_Name
      IF PressedEsc()
         RETURN NIL
      ENDIF
   ENDIF
   SCROLL(  3, 0, 24,80 )
   manother := "Y"
   DO WHILE manother = "Y"
        mcodeno := Name->Codeno

   ***            PartRev(  mcodeno  )                  //  Below

           mpartnum := SPACE( 20 )
           nlength := 0
           mok := "N"
           SELECT Orders
           SET ORDER TO 3                   // Codeno+Ordnum
           SEEK Name->Codeno
           IF FOUND()
              nrecno := 0
              aPart_ := {}
              DO WHILE Orders->Codeno == Name->Codeno .AND. Orders->( !EOF() )
                 SELECT Part
                 SET ORDER TO 1
                 SEEK Orders->Partnum
                 cdesc := SUBSTR( Orders->Detail1, 1,24 )
                 SELECT Orders
                 IF cdesc = SPACE( 30 )
                    cdesc := SUBSTR( Part->Desc, 1,24 )
                 ENDIF 
                 IF cdesc = SPACE( 30 )
                    cdesc := SUBSTR( Orders->Detail2, 1,24 )
                 ENDIF 
                 cunit := SPACE( 10 )
                 DO CASE
                    CASE Orders->Length > 0 
                       cunit := "Lengths   "
                    CASE Part->Unit = "Sq Mtr "
                       cunit := "Sheets    "
                    OTHERWISE
                       cunit := Part->Unit
                  ENDCASE
                  AADD( aPart_,Orders->Ordnum;
                  +" "+SUBSTR( Part->Partnum, 1,12 );
                  +" "+cdesc;
                  +" "+STR( Orders->Qtyrec, 9, 2 );
                  +" "+STR( Orders->PartQty, 9, 2 );
                  +" "+STR( Orders->PartIn, 9, 2 );
                  +" "+TRIM( cunit );
                  +"          "+STR( RECNO(),6 ) )
                 SKIP ALIAS Orders
             ENDDO                  // Orders
   *****                  +" "+STR( Orders->QtyRec, 8, 2 );
             IF !EMPTY( aPart_ )
                  SCROLL(   3, 0, 24,80 )
                  DISPBOX(  3, 0, 24,79, 2 )
       @  3,15 SAY "  --- Ordered Desc                Order   Balance    IN "
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE( 4, 2, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
                  IF PressedEsc() 
                     PartRec()
                  ENDIF
                  nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
                  SELECT Orders 
                  GOTO nrecno
                  SELECT Part
                  SET ORDER TO 1
                  SEEK Orders->Partnum
                  ***                SCROLL(   11, 0, 24,80 )
                  ***                 DISPBOX(  11, 0, 19,79, 2 )
                  SELECT Supl
                  SET ORDER TO 1                        // Partnum+Codeno
                  mseek := Orders->Partnum+Orders->Codeno
                  SEEK mseek
                  /*
                  Taken out
                  IF FOUND()
                     IF Orders->Partnum != Supl->SuppId
                        @ 12,20 SAY "Suppliers # "+Supl->SuppId
                     ENDIF
                  ENDIF
                  @ 13, 4         SAY TRIM( Orders->Partnum )
                  IF Part->Desc != SPACE( 40 )
                     @ 13,COL()+2 SAY Part->Desc COLOR "G+"
                   ELSE
                     @ 13,COL()+6 SAY "Supply as Detailed Below"
                  ENDIF 
                  @ 13,COL()+2 SAY Name->Codeno
                  @ 14, 3      SAY Orders->Detail1 
                  @ 15, 3      SAY Orders->Detail2
                  IF Orders->Length > 0
                     @ 15,COL()+1 SAY "Length"+STR( Orders->Length, 8, 3 )
                  ENDIF
                  @ 16, 3      SAY Orders->Detail3 
                  @ 17, 5      SAY "O/N "+Orders->Ordnum COLOR "G+"
                  @ 17,COL()+1 SAY DTOC( Orders->Date )
                  @ 17,COL()+2 SAY "Ordered Qty"
                  @ 17,COL()+1 SAY Orders->PartQty PICTURE "99,999.99" COLOR "G+"
                  @ 17,COL()+1 SAY Orders->Psno
                  @ 18, 5      SAY "Received by Store"
                  @ 18,COL()+1 SAY Orders->Jobnum
                  @ 18,COL()+3 SAY Orders->PartIn PICTURE "99,999.99" COLOR "G+"
                  mpartnum := Orders->Partnum
                  mok := "Y"
   *** ApGetY( "Accept this Part from Order " )                 
                  */
               mpartnum := Orders->Partnum
               mok := "Y"
             ENDIF                            // EMPTY
         ENDIF                                // FOUND()  
         IF PressedEsc()
            PartRec()
         ENDIF
         IF mok = "Y"
            SELECT Name
             ApRLock( 3 )
            Name->Status := "Y"
            mcodeno := Name->Codeno
            UNLOCK
            IF SUBSTR( mpartnum, 1, 2 ) == "ZZ"
               @ 20, 6 SAY "PART BEGINS WITH ZZ Deleted from Order File"
               SELECT Orders
                ApRLock( 3 )
               DELETE
               UNLOCK
               INKEY( 1 )
               LOOP
            ENDIF                               // Z
         ENDIF                                  // mok
         IF mok = "N"
            SCROLL()

             PartRev(  mcodeno  )                  //  Below

            nrecno := 0
            mpartnum  := SPACE( 20 )
            mcodeno   := Name->Codeno
            
             PartFind( mpartnum, mcodeno )                 //  XF_Part

            mpartnum := Part->Partnum
         ENDIF                                    // mok   
         ddate := DATE()
         SELECT Name
         SEEK mcodeno
         mcodeno := Name->Codeno
         IF PressedEsc()
            SELECT Name
             ApRLock( 3 )
            Name->Status := "N"
            UNLOCK
            RETURN NIL
         ENDIF
          SELECT Part
          SET ORDER TO 1
          SEEK mpartnum
          IF FOUND()
             mpartnum := Part->Partnum
          ENDIF

           PartVol( mcodeno )             

       manother := "Y"
   *** ApGetY( TRIM( Message->Another ) )
       LOOP 
    ENDDO
    SELECT Name
     ApRLock( 3 )
    Name->Status := "N"
    UNLOCK

   RETURN NIL
   ***----- End of PartRec()

   **-------------------------------------------------------------------

FUNCTION PartRecP()       // Used by MetMark, MetPart

   mcodeno   := SPACE( 8 )
   mtempcode := "A       "
   nrecno    := 0
   aPart_    := {}
   SELECT Orders
   SET ORDER TO 3                           // Codeno+Ordnum
   GOTO TOP
   SEEK mtempcode
   IF !FOUND()
       ApFLock( 3 )
      APPEND BLANK
      Orders->Codeno := "A       " 
      UNLOCK
   ENDIF 
   GOTO TOP
   IF LASTREC() != 0
      DO WHILE Orders->( !EOF() )
          IF Orders->PartQty <= 0
             SKIP ALIAS Orders
             LOOP
          ENDIF
          IF Orders->Codeno = mcodeno
             SKIP ALIAS Orders
             LOOP
          ENDIF
          SELECT Name
          SEEK Orders->Codeno
          mcodeno := Name->Codeno          
          SELECT Orders
          AADD( aPart_,Name->Name;
              +"       "+STR( RECNO(),6 ) )
          SKIP ALIAS Orders
      ENDDO                          // EOF()
      SCROLL() 
      DISPBOX(  0,48,  2,79, 2 )
      @  1,50 SAY "Select From Existing Orders"
      @ 12,50 SAY "F2 To View ALL Orders" COLOR "BG+"
      DISPBOX(  0, 1, 24,45, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum   := ACHOICE(  1, 3, 23,41, aPart_,,"AFUNC" )    
         IF PressedEsc() 
            RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         mcodeno := Orders->Codeno
         SELECT Name
         SEEK mcodeno
         IF LASTKEY() == -1
           SELECT Orders
           SET ORDER TO 3                   // Codeno+Ordnum
              nrecno := 0
              aPart_ := {}
              DO WHILE Orders->( !EOF() )
                 SELECT Part
                 SET ORDER TO 1             // Partnum
                 SEEK Orders->Partnum
                 cdesc := Part->Desc
                 SELECT Orders
                 IF cdesc = SPACE( 40 )
                    cdesc := Orders->Detail1
                 ENDIF 
                 IF cdesc = SPACE( 40 )
                    cdesc := Orders->Detail2
                 ENDIF 
               AADD( aPart_,Orders->Ordnum;
                  +" "+Orders->Codeno;
                  +" "+DTOC( Orders->Date );
                  +" "+SUBSTR( Part->Partnum, 1, 4 );
                  +" "+SUBSTR( cdesc,1,38 );
                  +" "+STR( Orders->PartQty, 8, 2 );
                  +"     "+STR( RECNO(),6 ) )
                 SKIP ALIAS Orders
             ENDDO                  // Orders
             IF !EMPTY( aPart_ )
                SCROLL(   0, 0, 24,80 )
                DISPBOX(  0, 1, 24,79, 2 )
                ASORT( aPart_,,,{ | x,y | x < y } )
                anum := ACHOICE(  1, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
                IF PressedEsc() 
                   RETURN NIL
                ENDIF
                nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
                GOTO nrecno
                mcodeno := Orders->Codeno
                SELECT Name
                SEEK mcodeno
             ENDIF                        // Empty
         ENDIF                            // F1  
         IF PressedEsc() 
            RETURN NIL
         ENDIF
      ENDIF                              // Empty   
      SCROLL()
      DISPBOX(  0, 1, 2,79, 2 )
      @  1,10 SAY Name->Name
      @  1,58 SAY STR( DAY( DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR( DATE() ),5 )
    ENDIF                        // LastRec
   mok := "N"
   IF mcodeno = "A       "
      SELECT Name
        Namerank()                                     // ZFS_Name
      IF PressedEsc()
         RETURN NIL
      ENDIF
   ENDIF
   IF mcodeno = SPACE( 8 )
      SELECT Name
        Namerank()                                     // ZFS_Name
      IF PressedEsc()
         RETURN NIL
      ENDIF
   ENDIF
   SCROLL(  2, 0, 24,80 )
   manother := "Y"
   DO WHILE manother = "Y"
        mcodeno := Name->Codeno
   ***            PartRev(  mcodeno  )                  //  Below
           mpartnum := SPACE( 20 )
           nlength := 0
           mok := "N"
           SELECT Orders
           SET ORDER TO 3                   // Codeno+Ordnum
           SEEK Name->Codeno
           IF FOUND()
              nrecno := 0
              aPart_ := {}
              DO WHILE Orders->Codeno == Name->Codeno .AND. Orders->( !EOF() )
                 IF Orders->PartQty <= 0
                    SKIP ALIAS Orders
                    LOOP
                 ENDIF
                 SELECT Part
                 SET ORDER TO 1
                 SEEK Orders->Partnum
                 cdesc := SUBSTR( Orders->Detail1, 1,24 )
                 SELECT Orders
                 IF cdesc = SPACE( 30 )
                    cdesc := SUBSTR( Part->Desc, 1,24 )
                 ENDIF 
                 IF cdesc = SPACE( 30 )
                    cdesc := SUBSTR( Orders->Detail2, 1,24 )
                 ENDIF 
               AADD( aPart_,Orders->Ordnum;
                  +" "+SUBSTR( Part->Partnum, 1,10 );
                  +" "+cdesc;
                  +" "+STR( Orders->Qtyrec, 8, 2 );
                  +" "+STR( Orders->PartQty, 8, 2 );
                  +" "+STR( Orders->PartIn, 8, 2 );
                  +" "+TRIM( Part->Unit );
                  +"          "+STR( RECNO(),6 ) )
                 SKIP ALIAS Orders
             ENDDO                  // Orders
             IF !EMPTY( aPart_ )
                  SCROLL(   2, 0, 24,80 )
                  DISPBOX(  2, 1, 24,79, 2 )
                  @  2,15 SAY "  --- Ordered Desc               Ordered  Balance  Rec "
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE(  3, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
                  IF PressedEsc() 
                     RETURN NIL
                  ENDIF
                  nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
                  SELECT Orders 
                  GOTO nrecno
                  SELECT Part
                  SET ORDER TO 1
                  SEEK Orders->Partnum
                  SCROLL(   10, 0, 24,80 )
                  DISPBOX(  10, 1, 19,79, 2 )
                  SELECT Supl
                  SET ORDER TO 1                        // Partnum+Codeno
                  mseek := Orders->Partnum+Orders->Codeno
                  SEEK mseek
                  IF FOUND()
                     IF Orders->Partnum != Supl->SuppId
                        @ 11,20 SAY "Suppliers # "+Supl->SuppId
                     ENDIF
                  ENDIF
                  @ 12, 4      SAY TRIM( Orders->Partnum )
                  IF Part->Desc != SPACE( 40 )
                     @ 12,COL()+2 SAY Part->Desc COLOR "G+"
                   ELSE
                     @ 12,COL()+6 SAY "Supply as Detailed Below"
                  ENDIF 
                  @ 13, 3      SAY Name->Codeno
                  @ 14, 3      SAY Orders->Detail1 
                  @ 15, 3      SAY Orders->Detail2
                  @ 15,COL()+1 SAY "Length"+STR( Orders->Length, 8, 2 )
                  @ 16, 3      SAY Orders->Detail3 
                  @ 18, 5      SAY "O/N "+Orders->Ordnum COLOR "G+"
                  @ 18,COL()+1 SAY DTOC( Orders->Date )
                  @ 18,COL()+2 SAY "Ordered Qty "+STR( Orders->PartQty, 8, 2 )
                  @ 18,COL()+1 SAY Orders->Psno
                  mpartnum := Orders->Partnum
                  mok := ApGetY( "Accept this Part from Order " )                 
             ENDIF                            // EMPTY
         ENDIF                                // FOUND()  
         IF PressedEsc()
            RETURN NIL
         ENDIF
         IF mok = "Y"
            SELECT Name
             ApRLock( 3 )
            Name->Status := "Y"
            UNLOCK
           ELSE
   ***            SCROLL()
   ***             PartRev(  mcodeno  )                  //  XF_Part
            nrecno := 0
            mpartnum  := SPACE( 20 )
            mcodeno   := Name->Codeno
            
             PartFind( mpartnum, mcodeno )                 //  XF_Part

            mpartnum := Part->Partnum
         ENDIF                                    // mok   
         IF PressedEsc()
            SELECT Name
             ApRLock( 3 )
            Name->Status := "N"
            UNLOCK
            RETURN NIL
         ENDIF
         ddate := DATE()
         SELECT Part
         SET ORDER TO 1                         // Partnum Index
         SEEK mpartnum
         IF FOUND()
            mpartnum := Part->Partnum
         ENDIF

          PartVolP( mcodeno )                            // Below

       manother := ApGetY( TRIM( Message->Another ) )
       LOOP 
   ENDDO
   SELECT Name
   ApRLock( 3 )
   Name->Status := "N"
   UNLOCK

   RETURN NIL

   ***----- End of PartRecP()

   **-------------------------------------------------------------------

STATIC FUNCTION PartVolP( mcodeno )         // MetPart, MetMark

    SELECT Name
    SEEK mcodeno
    SELECT Orders
    nrecno  := RECNO()
    cordnum := SPACE( 4 )
    IF Name->Status = "Y"              // Received
       cordnum := Orders->Ordnum
    ENDIF               // Name->Status
   mQty:= nlength:= ncsarea := 0
   ndiscount:= ncost:= namount:= nlinm:= nrate:= nvol:= nlen:= 0
   mcorrect = "N"
   DO WHILE mcorrect = "N"
      SCROLL( 2, 0, 24,80 )
      DISPBOX( 2, 1, 24,79, 2 )
      @  3, 6      SAY Part->Partnum COLOR "G+"
      @  3,COL()+2 SAY Part->Desc+" "+TRIM( Part->Unit ) COLOR "BG+"
      IF SUBSTR( mpartnum, 1, 2 ) != "ZZ"
              SELECT Orders
              SET ORDER TO 1                        // Partnum
              GOTO TOP
              SEEK mpartnum
              nTotal := 0
              IF FOUND()
                 nll := 15
                 SCROLL(  14, 3, 24,78 )
                 DISPBOX( 14, 3, 24,78, 2 )
                 @ 14,20 SAY " Ordered  Balance  Received " COLOR "BG+"
                 DO WHILE Orders->Partnum = mpartnum .AND. Orders->( !EOF() )
                     *****  This will change to Orders-PartQty <= 0
                    IF Orders->PartQty <= 0
                       SKIP ALIAS Orders
                       LOOP
                    ENDIF
                    IF nll >= 21
                       INKEY( 1 )
                       nll := 15
                       SCROLL( 15, 3, 21,78 )
                    ENDIF
                    @ nll, 5      SAY Orders->Codeno
                    @ nll,COL()+1 SAY Orders->Ordnum
                    @ nll,COL()+1 SAY Orders->QtyRec  PICTURE "9,999.99"
                    @ nll,COL()+1 SAY Orders->Partqty PICTURE "9,999.99" COLOR "R+"
                    @ nll,COL()+1 SAY Orders->PartIn  PICTURE "9,999.99"
                    @ nll,COL()+1 SAY Orders->Date    PICTURE "99/99/9999"
                    nll++
                    nTotal += Orders->PartQty 
                    SKIP ALIAS Orders
                 ENDDO
                 @ 23, 5      SAY TRIM( mpartnum )+" Ordered" 
                 @ 23,COL()+1 SAY nTotal PICTURE "9,999.99" COLOR "G+" 
              ENDIF                            // Found
      ENDIF                // mpartnum not Z
      SELECT Part
      nselect := 1
      DO CASE 
           CASE Part->Unit = "Each      "
              nselect := 1
           CASE Part->Unit = "Mtr       "
              nselect := 2
           CASE Part->Unit = "Sq Mtr    "
              nselect := 3
           CASE Part->Unit = "Cu Mtr    "
              nselect := 4
      ENDCASE
      nl := 5 
      @ nl, 6      PROMPT "Each  "
      @ nl,COL()+2 PROMPT "Mtr   "
      @ nl,COL()+2 PROMPT "Sq Mtr"
      @ nl,COL()+2 PROMPT "Cu Mtr"
      MENU TO nselect
       ApRLock( 3 )
      DO CASE
            CASE nselect == 1
               Part->Unit := "Each"
            CASE nselect == 2
               Part->Unit := "Mtr"
            CASE nselect == 3
               Part->Unit := "Sq Mtr"
            CASE nselect == 4
               Part->Unit := "Cu Mtr"
      ENDCASE 
      UNLOCK
      @ nl,39      SAY "In Stock"
      @ nl,COL()+1 SAY Part->Instock PICTURE "99,999.99"
      @ nl,COL()+2 SAY "Length"  
      @ nl,COL()+1 SAY Part->Length PICTURE "999.99"
      nl+=2
      IF Name->Status = "Y"              // Received
         SELECT Orders
         GOTO nrecno
         @ nl, 3      SAY "Order Qty"+STR( Orders->Qtyrec, 8, 2 ) COLOR "G+"
         @ nl,COL()+2 SAY "Balance"+STR( Orders->PartQty, 8, 2 )
         @ nl,COL()+2 SAY "Received"+STR( Orders->PartIn, 8, 2 )
         @ nl,COL()+2 SAY "O/N # "+Orders->Ordnum COLOR "BG+"
         nl+=2
      ENDIF                           // Name Status
      DO CASE
         CASE Part->Unit = "Sq Mtr    "
           nwidth    := Part->Width/1000
           nlength   := Part->Length
           SELECT Part
           IF Name->Status = "Y"              // Received
              mqty := Orders->PartQty         
            ELSE
              mqty := Part->Instock/( nwidth*nlength ) 
           ENDIF
           ncost     := Part->Trade*( nwidth*nlength )
           ndiscount := 0
           @  nl, 6      SAY "Width in Mtr"  GET nwidth
           @  nl,COL()+2 SAY "Length in Mtr" GET nlength
           nl+=2
           IF Name->Status = "Y"
              @  nl, 6 SAY "Balance Sheets" GET mqty      PICTURE "999999.99"
               READ
              nl+=2
              SCROLL( nl, 2,22,78 )
              ncost := ncost/( nwidth*nlength )
               ***           mQty  := ( nlength*nwidth )*nvol
              @  nl, 6      SAY "Sq Mtrs "+STR( mQty*( nlength*nwidth ), 9, 2 )
               READ
            ELSE
              @  nl, 6      SAY "Sheets in Stock"  GET mqty  PICTURE "999999.99"
               READ
              @ nl,42 SAY "Sq Mtrs "+STR( mQty*( nlength*nwidth ), 9, 2 )
              nl++
           ENDIF
           IF PressedEsc()
              *** UNLOCK  
              RETURN NIL
           ENDIF
           SELECT Part
            ApRLock( 3 )
           Part->Width  := nwidth*1000   // Convert to mm
           Part->Length := nlength
           UNLOCK
           
         CASE Part->Unit = "Cu Mtr    "
            nl++
            @  nl, 6      SAY "Volume Cu/M"   GET nvol   PICTURE "999.99"
            @  nl,COL()+2 SAY "Rate per Cu/M" GET nrate  PICTURE "999.99"
             READ
            IF PressedEsc()
               RETURN NIL
            ENDIF
            ** Calculate cross-section area in square metres
            ncsarea := ( Part->Width*Part->Thick )/1000000
            ** Calculate linear metres
            nlen := nvol/ncsarea
            ** Calculate cost per linear metre.
            ** Must allow for variable volume here  (Try various volumes for
            **   same width & thickness - cost should be constant)
            ncost=( nrate/nlen )*nvol
            ** Wastage Factor 10%
            ** Show total linear & cost
            ncost := ncost*1.1
            ncsarea := ( Part->Width*Part->Thick ) // cross sectional area in sq mm
            ncsarea := ncsarea/1000000             // cross sectional area in sq metres
            ** ( Could combine above two lines into one calculation )
            mQty := nvol/ncsarea         // length in metres
            nl+=2
            @  nl, 6      SAY "Mtrs "+STR( nlen,5 ) COLOR "G+"
            @  nl,COL()+1 SAY "Length"   GET mQty      PICTURE "999999.99"
            READ
            IF PressedEsc()
               RETURN NIL
            ENDIF

         CASE Part->Unit = "Mtr       "                 // Linear Mtr
            IF Name->Status = "Y"              // Received
              nlength := Orders->Length
              mQty    := Orders->PartQty
              @ nl, 6      SAY "Length in Mtr of Item" GET nlength PICTURE "99999.99"
              @ nl,COL()+2 SAY "Ordered Length in Mtrs "+STR( nlength, 8, 2 )
              nl++
              SELECT Part
              @ nl, 6 SAY "Received Qty " GET mQty PICTURE "999999.99"
               READ
              nl++
              SCROLL( nl, 2,22,78 )
              mQty := mQty*nlength
              @ nl, 6       SAY "Received"
              @ nl, COL()+1 SAY mQty PICTURE "Mtr 99,999.99"    
               READ      
              nl++
           ELSE
              SELECT Part
              mQty    := Part->Instock/Part->Length
              nlength := Part->Length
              @ nl, 6      SAY "Length Each"  GET nlength 
              @ nl,COL()+2 SAY "Qty Lengths"  GET mQty      PICTURE "999999.99" 
               READ
              mQty := nlength*mQty
              nl++
              @ nl, 6      SAY "    Mtr Qty"  GET mQty      PICTURE "999999.99"
               READ
              nl++      
               ApRLock( 3 )
              Part->Length := nlength
              UNLOCK
           ENDIF
           IF PressedEsc()
              RETURN NIL
           ENDIF

         CASE Part->Unit = "Each      "
            mQty := Part->Instock
            IF Name->Status = "Y"
               mQty := Orders->PartQty
               @ nl, 6 SAY "Rec Qty" GET mQty PICTURE "99999.99"
             ELSE
               @ nl, 6 SAY "Qty"     GET mQty PICTURE "99999.99"
            ENDIF
             READ
            nl++ 
            IF PressedEsc()
               RETURN NIL
            ENDIF

          OTHERWISE
             mQty := Part->Instock
             nl++
             @  nl, 6 SAY "Qty" GET mQty PICTURE "99999.99"
              READ
            IF PressedEsc()
               RETURN NIL
            ENDIF
      ENDCASE
      nll := 16
      SELECT Part
       ApRlock( 3 )
      Part->Instock += mQty           // Add Total First
      UNLOCK
      SCROLL( 14, 3, 22,78 )
      @ 15,10 SAY "Parts in Stock"
      @ 15,COL()+1 SAY Part->Instock PICTURE "99,999.99"
      nAlloc := mQty
      nTime  := 0
      SELECT Labour
      GOTO TOP
      SET ORDER TO 1        // Codeno
      SEEK Orders->Ordnum   // Ordnum is in Codeno field
      DO WHILE Labour->Codeno = Orders->Ordnum .AND. Labour->( !EOF() )
         IF Labour->Partnum != mpartnum
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF nll >= 22
            INKEY( 2 )
            nll := 16
            SCROLL( 14,46, 22,78 )
         ENDIF
         IF nAlloc > Labour->Time
            nTime := Labour->Time
           ELSE
            nTime := nAlloc
         ENDIF  
         IF nTime > 0
            @ nll, 3      SAY "O/N"
            @ nll,COL()+2 SAY Labour->Codeno
            @ nll,COL()+2 SAY Labour->Invno COLOR "R+"
            @ nll,COL()+1 SAY nTime  PICTURE "9999.99" COLOR "G+"
         ENDIF
         nAlloc -= nTime
         SELECT QuotStk
         SET ORDER TO 2    //  Partnum+Invno
         GOTO TOP
         SEEK Labour->Partnum+Labour->Invno
         IF FOUND()
             ApRlock( 3 )
            IF QuotStk->Received+nTime >= QuotStk->Qty
               QuotStk->Received := QuotStk->Qty
              ELSE
               QuotStk->Received += nTime
            ENDIF
            IF QuotStk->Received >= QuotStk->Required
               QuotStk->Ordnum := "ok"
              ELSE  
               QuotStk->Ordnum := Orders->Ordnum
            ENDIF
            UNLOCK
            @ nll,34      SAY QuotStk->Invno                      COLOR "R+"
            @ nll,COL()+1 SAY QuotStk->Required PICTURE "Rq9999.99" COLOR "G+"
            @ nll,COL()+2 SAY QuotStk->Received PICTURE "Re9999.99" COLOR "G+"
            @ nll,COL()+1 SAY "Issued"
            @ nll,COL()+1 SAY ntime PICTURE "9,999.99"
            nll++
            SELECT Part
             ApRlock( 3 )
            Part->Instock -= nTime
            UNLOCK
         ENDIF
         SELECT Labour
         SKIP ALIAS Labour
      ENDDO                            // Found in Labour File
      nl++
      @ nl, 6 SAY "After Issue Parts in Stock"
      @ nl,COL()+1 SAY Part->Instock PICTURE "99,999.99" COLOR "R+"
      SELECT Orders
      nl+=2
      mjobnum := "AD    "
      SCROLL( nl, 3, nl,78 )
      @ nl, 6 SAY "Received By" GET mjobnum PICTURE "@!"
       READ
       ApRlock( 3 )
      Orders->Jobnum := mjobnum
      UNLOCK
      IF SUBSTR( Part->Partnum, 1, 2 ) != "ZZ" 
         SELECT Supl
         LOCATE FOR Supl->Partnum == mpartnum .AND. Supl->Codeno == Name->Codeno
         IF !FOUND()
            ApFLock( 3 )
           APPEND BLANK
           Supl->Partnum := Part->Partnum
           Supl->SuppId  := Part->Partnum
           Supl->Cost    := Part->Trade
           Supl->Codeno  := Name->Codeno
           Supl->Date    := DATE()
           UNLOCK
        ENDIF
         ApRLock( 3 )
        @ nl,33 SAY "Suppliers Partnum" GET Supl->SuppId PICTURE "@K!"
         READ
        UNLOCK
        nl+=2
      ENDIF                // ZZ
      mcorrect := ApGetY( TRIM( Message->Correct ) )
   ENDDO                                              // mcorrect 
   IF Name->Status = "Y"             // Only on Receipt  
     SELECT Orders
     GOTO nrecno
      ApRLock( 3 )
     Orders->PartIn = mqty
     Orders->Partqty -= mqty
     UNLOCK
     IF Orders->PartQty > 0 
         @ nl,6 SAY "Still On Order "+TRIM( Orders->Partnum );
                     +" "+STR( Orders->PartQty, 8, 3 );
                     +" Length Mtr "+STR( Orders->Length, 6 )
      ENDIF                    // PartQty > 0
   ENDIF                       // Name->Status

   RETURN NIL
   ***------- PartVolP()

   ****-------------------------------------------------------------------

STATIC FUNCTION PartRev( mcodeno )

   nl  :=  4
   npl := 11   
   SCROLL(  3, 0, 24,80 )
   DISPBOX( 3, 1, 24,79, 2 )
   cheading := " -- Entered Today ONLY -- "+Name->Codeno+" "+TRIM( Name->Name )+" "
   @ 3,40-( LEN(cheading)/2 ) SAY cheading
   SELECT ProfNat
   SET ORDER TO 1                      // Codeno
   mcodeno := Name->Codeno
   SEEK mcodeno
   DO WHILE ProfNat->Codeno = mcodeno .AND. ProfNat->( !EOF() )
      IF ProfNat->PDate != DATE()
         SKIP ALIAS ProfNat
         LOOP
      ENDIF 
      IF nl > npl
         RETURN mcodeno
         nl :=  4
         INKEY( 2 )
         SCROLL( 4, 3, 23,78 )
      ENDIF 
      @ nl, 3 SAY SUBSTR( ProfNat->Partnum, 1,16 ) 
      SELECT Part
      SET ORDER TO 1                           // Partnum
      SEEK ProfNat->Partnum
      @ nl,COL()+1 SAY Part->Desc
      SELECT ProfNat
      @ nl,COL()+1 SAY ProfNat->Qty PICTURE "99,999.999"
      nl++
      SKIP ALIAS ProfNat
   ENDDO                        // ProNat EOF()

   RETURN mcodeno

   *****---- End of PartRev()

   *******--------------   END OF CWPUNIV.PRG
