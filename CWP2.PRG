*** JoKir01  26-01-11 07:23:27 

/* 
   Program.....:              CWP2.PRG
   Authors.....: J.Kirby
   Date........: 03/05/1999
   Func........: PartDets, PartDelete, PartLabour,
                 EquCopy
   Static Funcs: PartQtyMtr
   Not used....: LabCopy
*/

STATIC FUNCTION PartQtyMtr( mqty )

   nl := 5
   SCROLL(  3, 1, 23,78 )
   DISPBOX( 3, 1, 24,79, 2 )
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
   DO CASE
      CASE Part->Unit = "Sq Mtr    "
         nwidth  := Part->Width/1000
         nlength := Part->Length
         mQty    := Part->Instock
         SELECT Part
         ncost     := Part->Trade*( nwidth*nlength )
         ndiscount := 0
         nl++ 
         @ nl, 6      SAY "Width in Mtr"  GET nwidth  PICTURE "99999.999"
         @ nl,COL()+2 SAY "Length in Mtr" GET nlength PICTURE "99999.999"
         nl+=2
         @  nl, 6      SAY "Sheets in Stock" GET mqty PICTURE "99999.99"
         READ
         IF nwidth > 1000 .OR. nlength >1000
            nl++ 
            @ nl, 6 SAY "Should be in Mtr Please Check" COLOR "R+"
            nl+=2 
            @ nl, 6      SAY "Width in Mtr"  GET nwidth  PICTURE "99999.999"
            @ nl,COL()+2 SAY "Length in Mtr" GET nlength PICTURE "99999.999"
            nl+=2
            @  nl, 6      SAY "Sheets in Stock" GET mqty PICTURE "99999.99"
            READ
         ENDIF
         nl+=2 
         @ nl, 6      SAY "Sheets in Sq Mtrs" COLOR "R+"
         @ nl,COL()+2 SAY ( nwidth*nlength )*mqty PICTURE "99,999.99" COLOR "R+"
         @ 22,10 SAY "  " 
         WAIT
         IF PressedEsc()
            RETURN NIL
         ENDIF
         SELECT Part
         ApRLock( 3 )
         Part->Width   := nwidth*1000   // Convert to mm
         Part->Length  := nlength
         Part->Instock := mqty
         UNLOCK

      CASE Part->Unit = "Cu Mtr    "
         nvol    := Part->Width
         nrate   := Part->Thick
         nlength := Part->Length
         nl++
         @  nl, 6      SAY "Volume Cu/M"   GET nvol   PICTURE "9999.999"
         @  nl,COL()+2 SAY "Rate per Cu/M" GET nrate  PICTURE "9999.99"
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
         ndiscount := 0
         ncost := ncost*1.1
         ncsarea := ( Part->Width*Part->Thick ) // cross sectional area in sq mm
         ncsarea := ncsarea/1000000             // cross sectional area in sq metres
         ** ( Could combine above two lines into one calculation )
         mQty := nvol/ncsarea         // length in metres
         nl+=2
         @  nl, 6      SAY "Per Mtr+10% "+STR( ncost,6,3 ) COLOR "G+"
         @  nl,COL()+1 SAY "Mtrs "+STR( nlen,5 ) COLOR "G+"
         @  nl,COL()+1 SAY "Length" GET nlength   PICTURE "999999.99"
         nl++
         ***       @  nl, 6      SAY "% Discount" GET ndiscount PICTURE "99.99"
         @  nl, 6 SAY "In Stock" GET mqty      PICTURE "99999.99"
         READ
         ApRLock( 3 )
         Part->Width   := nrate
         Part->Thick   := nvol
         Part->Length  := nlength
         Part->Instock := mqty 
         UNLOCK
         IF PressedEsc()
            RETURN NIL
         ENDIF

      CASE Part->Unit = "Mtr       "                 // Linear Mtr
         SELECT Part
         nlength := Part->Length
         mQty    := Part->Instock/nlength
         nminstk := Part->MinStk
         @ nl, 6      SAY "Length Mtr"  GET nlength PICTURE "99999.999" 
         @ nl,COL()+2 SAY "Qty Lengths" GET mqty    PICTURE "99999.99" 
         READ
         mQty := nlength*mQty
         nl++
         @  nl, 6      SAY "  Mtr Qty"  GET mqty     PICTURE "999999.99"
         @  nl,COL()+2 SAY "Mininum"    GET nminstk  PICTURE "999999.99"
         @  nl,64 SAY "* "+Name->Status
         READ
         ApRLock( 3 )
         Part->Length  := nlength
         Part->MinStk  := nminstk
         Part->Instock := mqty 
         UNLOCK
         IF PressedEsc()
            RETURN NIL
         ENDIF

      CASE Part->Unit = "Each      "
         mQty    := Part->Instock
         nminstk := Part->MinStk
         @  nl, 6 SAY "Part Instock" GET mQty    PICTURE "99999.99"
         @  nl,34 SAY "Mininum"      GET nminstk PICTURE "99999.99"
          READ
         SELECT Part
          ApRLock( 3 )
         Part->Instock := mqty 
         Part->MinStk  := nminstk
         UNLOCK
         IF PressedEsc()
            RETURN NIL
         ENDIF

      OTHERWISE
         mQty := Part->Instock
         nl+=2
         @  nl, 6 SAY "Part Instock" GET mqty PICTURE "99999.99"
          READ
         IF PressedEsc()
            RETURN NIL
         ENDIF
   ENDCASE

   RETURN NIL

***------------ End PartQtyMtr

****------------------------------------------------------------------

FUNCTION PartDets( mpartnum )

   SCROLL(  3, 0, 24,80 )
   DISPBOX( 3, 1, 24,79, 2 ) 
   SELECT Part
   SET ORDER TO 1                           // Partnum
   SEEK mpartnum
   ***   cpartmod   := Part->Partnum
   mpartmod   := Part->Partnum
   ntradeDate := Part->Trade
   IF !FOUND()
      @ 12,10 SAY "NO SUCH PART IN FILE"
      mok:=ApGetN( "Yes = Add Part - No = Search" )
      IF PressedEsc()
         RETURN NIL
      ENDIF
      IF mok == "Y"

          Partadd( @mpartnum )              // XF_Part

         SELECT Part
         SET ORDER TO 1                     // Partnum
         SEEK mpartnum
           ApRLock( 3 )
         mpartnum := Part->Partnum
         UNLOCK
      ELSE
         PartFind( @mpartnum )   
      ENDIF                            // mok  
   ENDIF                               // FOUND()
   ccatno := Part->Catno
   mcont  := "N"
   DO WHILE mcont == "N"
      SELECT Part
      SET ORDER TO 1                     // Partnum
      SEEK mpartnum
      mpartnum := Part->Partnum
      mmodcode := SUBSTR( mpartnum, 1,16 )  // This is if 20 Part #
      SCROLL()
      DISPBOX( 0, 1,  2,79, 2 )
      DISPBOX( 2, 1, 24,79, 2 )
      @  1, 4 SAY TRIM( mpartnum )+"  "+TRIM( Part->Desc ) COLOR "G+"
      nl := 3
      IF Part->Detail != "      "
         @  nl,10 SAY Part->Detail
         nl++
      ENDIF
      IF Part->Detail1 != "      "
         @  nl,10 SAY Part->Detail1
         nl++
      ENDIF
      IF Part->Detail2 != "      "
         @  nl,10 SAY Part->Detail2
         nl++
      ENDIF
      IF Part->Detail3 != "      "
         @  nl,10 SAY Part->Detail3
         nl++
      ENDIF
      nTimeTotal := 0
      nRateTotal := 0  
      nlabpart := 0
      ntottrade:= ntotwhol := 0
      ntottrade1:= ntotwhol1 := 0
      ***     tempscrn := SAVESCREEN( 10, 0, 24,80 )
      coderef  := mpartnum
       MemoDisp( coderef )   // XF-Memo2
      ***    RESTSCREEN( 10, 0, 24,80,tempscrn )
      SCROLL(  nl, 3, 23,78 ) 
      SELECT Equ
      SET EXACT ON
      nrecno2:= nrecno3:= nrecno4 := 0
      nequ1:= nequ2:= nequ3:= nequ4 := 0
      mmod4:= mmod3:= mmod2 := SPACE( 16 )
      npl := 0
      GOTO TOP
      SEEK mmodcode                
      IF FOUND()   
         DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !EOF() )
            IF npl < 23 
               @ npl,71 SAY SUBSTR( Equ->Partnum, 1, 9 ) COLOR "BG+" 
               npl++
            ENDIF 
            SELECT Part
            SEEK Equ->Partnum
            ntottrade1 += ( Part->Trade * Equ->PartQty )
            ntotwhol1  += ( Part->Wholesale * Equ->PartQty )
            SELECT Equ
            mmod2 := SUBSTR( Equ->Partnum, 1,16 ) 
            nequ1 := Equ->Partqty 
            nrecno2 := RECNO() 
            IF Equ->Partnum = Message->LabPart
               nlabpart += nequ1
            ENDIF
            GOTO TOP
            SEEK mmod2
            IF FOUND()
               DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
                  SELECT Part
                  SEEK Equ->Partnum
                  SELECT Equ
                  mmod3   := SUBSTR( Equ->Partnum, 1,16 )
                  nrecno3 := RECNO() 
                  nequ2 := Equ->PartQty * nequ1
                  IF Equ->Partnum = Message->LabPart
                     nlabpart += nequ2
                  ENDIF
                  GOTO TOP
                  SEEK mmod3
                  IF FOUND()   
                     DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
                        SELECT Part
                        SEEK Equ->Partnum
                        SELECT Equ
                        mmod4 := SUBSTR( Equ->Partnum, 1,16 )
                        nrecno4 := RECNO()
                        nequ3 := Equ->PartQty * nequ2
                        IF Equ->Partnum = Message->LabPart
                           nlabpart += nequ3
                        ENDIF
                        GOTO TOP
                        SEEK mmod4
                        IF FOUND()
                           DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                              SELECT Part
                              SEEK Equ->Partnum
                              SELECT Equ
                              nequ4 := Equ->PartQty * nequ3
                              IF Equ->Partnum = Message->LabPart
                                 nlabpart += nequ4
                              ENDIF
                              ntottrade += ( Part->Trade * nequ4 )
                              ntotwhol  += ( Part->Wholesale * nequ4 )
                              SKIP ALIAS Equ
                           ENDDO                       //  mmod4
                        ELSE
                           ntottrade += ( Part->Trade * nequ3 )
                           ntotwhol  += ( Part->Wholesale * nequ3 )
                        ENDIF
                        SELECT Equ 
                        GOTO nrecno4
                        SKIP ALIAS Equ
                     ENDDO                       //  mmod3
                  ELSE
                     ntottrade += ( Part->Trade * nequ2 )
                     ntotwhol  += ( Part->Wholesale * nequ2 )
                  ENDIF                          // FOUND()  mmod3    
                  SELECT Equ
                  GOTO nrecno3
                  SKIP ALIAS Equ
               ENDDO                       //  mmod2 EOF()
            ELSE
               ntottrade += ( Part->Trade * nequ1 )
               ntotwhol  += ( Part->Wholesale * nequ1 )
            ENDIF                         // Found mmod2
            SELECT Equ
            GOTO nrecno2
            SKIP ALIAS Equ
            ENDDO                       //   mmodcode EOF()
         ENDIF                          // Found mmodcode
         SET EXACT OFF 
         ***      nl := 4 
         IF ntottrade1 > 0
            @ nl, 3      SAY "    Parts" COLOR "G+" 
            @ nl,COL()+1 SAY ntottrade  PICTURE "$999,999.999"
            @ nl,COL()+2 SAY "Part Sell"                     
            @ nl,COL()+1 SAY ntotwhol   PICTURE "$999,999.999"
            nl++
            @ nl, 3      SAY " Kit Cost" COLOR "R+" 
            @ nl,COL()+1 SAY ntottrade1 PICTURE "$999,999.999"  COLOR "G+"
            @ nl,COL()+2 SAY "     Sell"                     
            @ nl,COL()+1 SAY ntotwhol1  PICTURE "$999,999.999" COLOR "BG+"
         ENDIF                         // ntottrade > 0
         nTotRate:= nTotTime := 0
         ***** Taken out Test ENDIF                       // Bought Out
         SELECT Part
         SET ORDER TO 1                     // Partnum
         SEEK mmodcode    // Used to be partnum
          ApRLock( 3 )
         Part->Markup := ( ( Part->Wholesale-Part->Trade ) / Part->Trade ) *100
         UNLOCK
         nl++
         @ nl, 3      SAY Part->Unit
         @ nl,COL()+1 SAY Part->Trade           PICTURE "999,999.999"  // COLOR "G+"
         nl++
         @ nl, 9      SAY "Sell" 
         @ nl,COL()+1 SAY Part->Wholesale       PICTURE "999,999.999"
         @ nl,COL()+1 SAY "Exl GST"
         @ nl,COL()+2 SAY Part->Wholesale*( ( Control->GSTRate/100 )+1 );
                                           PICTURE "999,999.999" COLOR "BG+"
         @ nl,COL()+1 SAY "Inc GST" COLOR "BG+"
         @ nl,COL()+2 SAY Part->Markup          PICTURE "99,999.999"
         @ nl,COL()+1 SAY "%"
         nl+=2 
         @ nl, 3      SAY "Cat # "+Part->Catno  
         @ nl,COL()+1 SAY "Group "+Part->PartId 
         @ nl,COL()+2 SAY "GST ="
         @ nl,COL()+1 SAY ( Part->Wholesale*(( Control->GSTRate/100 )+1 ))-( Part->Wholesale );
                                                PICTURE "99,999.99"
         @ nl,COL()+2 SAY "ABC= "+Part->ABC COLOR "RG+"
         nl+=2
         @ nl, 3      SAY "Name "+TRIM( Part->Codeno )
         IF Part->Boughtout = "Y"
            @ nl,COL()+2 SAY "Bought Out"
         ELSE
            @ nl,COL()+2 SAY "Own Manufacture"
         ENDIF         
         IF nlabpart > 0
            @  nl,COL()+2 SAY TRIM( Message->LabPart )   COLOR "G+"
            @  nl,COL()+1 SAY nlabpart PICTURE "99999.999" COLOR "G+" 
         ENDIF
         @ nl,COL()+2 SAY Part->Date
         SELECT Supl
         SET ORDER TO 1
         SEEK Part->Partnum
         IF FOUND()
            nl := 11
            SCROLL( nl,50, 18,78 )
            DO WHILE Supl->Partnum == mpartnum .AND. Supl->( !EOF() )
               IF nl > 18
                  nl := 11
                  INKEY( 0 )
                  SCROLL( 11,50, 18,78 )
               ENDIF
               @ nl,42      SAY Supl->Codeno                     COLOR "BG+"
               @ nl,COL()+1 SAY Supl->Cost PICTURE "999,999.999" COLOR "BG+"     
               IF Part->Unit = "Mtr      "
                  @ nl,COL()+1 SAY "Mtr"
                  @ nl,COL()+1 SAY Supl->Cost*Part->Length PICTURE "99,999.999" 
               ENDIF
               nl++
               SKIP ALIAS Supl   
            ENDDO                             // Supl
         ENDIF                                // Found()
         nl := 15      // 14
         nl++
         @ nl, 3      SAY "In Stock"                        COLOR "BG+"
         @ nl,COL()+1 SAY Part->Instock PICTURE "99,999.999" COLOR "BG+"
         @ nl,COL()+1 SAY Part->Locate+" "+Part->LocDesc    COLOR "RG+"
         IF SUBSTR( Part->Partnum, 1, 2 ) != "ZZ"
            SELECT Orders
            SET ORDER TO 1                       // Partnum
            SEEK mpartnum
            IF FOUND()
               nQty := 0
               nl := 17
               @ nl, 4 SAY "On Order"
               DO WHILE Orders->Partnum == mpartnum .AND. Orders->( !EOF() )
                  IF nl > 20
                     nl := 17
                     INKEY( 0 )
                     SCROLL( 16,18, 20,54 )
                  ENDIF
                  IF Orders->PartQty-Orders->PartIn > 0 
                     @ nl,16 SAY Orders->Codeno COLOR "BG+"
                     @ nl,26 SAY ( Orders->PartQty-Orders->PartIn );
                                      PICTURE "99,999" COLOR "BG+"
                     @ nl,34 SAY Orders->Date
                     nQty += ( Orders->PartQty-Orders->PartIn )     
                     nl++
                  ENDIF 
                  SKIP ALIAS Orders   
               ENDDO                             // Orders
               @ 20,11 SAY nQty PICTURE "99,999"
               INKEY()
            ENDIF                                // Found()
         ENDIF                                    // ! ZZ    
         SELECT PartOper
         SET ORDER TO 1         // Partnum 
         GOTO TOP 
         SEEK Part->Partnum
         IF FOUND() 
            SCROLL(  10,66, 20,80 )
            DISPBOX( 10,66, 20,79, 2 )
            @ 10,68 SAY " Drawings "
            nl := 11
            DO WHILE PartOper->Partnum = Part->Partnum .AND. PartOper->( !EOF() )
               IF PartOper->Drawno != SPACE( 8 )
                  @ nl,68 SAY PartOper->Drawno COLOR "RG+"
                  nl++
               ENDIF
               IF nl >= 19
                  INKEY( 2 )
                  SCROLL(  11,67, 20,78 )
                  nl := 11
               ENDIF
               SKIP ALIAS PartOper
            ENDDO
         ENDIF             // Found Drawing
         SELECT Part
         IF Part->Unit = "Sq Mtr   "
            @ 18, 6 SAY "Thick mm "+STR( Part->Thick );
                        +" Width mm "+STR( Part->Width );
                        +" Length Mtr "+STR( Part->Length )
         ENDIF
         IF Part->Unit = "Mtr      "
            @ 18, 6      SAY "LN Cost"
            @ 18,COL()+1 SAY Part->Length*Part->Trade PICTURE "99,999.999" COLOR "BG+"
         ENDIF
         @ 18,50      SAY "Weight"
         @ 18,COL()+1 SAY Part->Weight PICTURE "9,999.99" COLOR "G+"
         SCROLL(  19, 0, 24,80 )
         DISPBOX( 19, 1, 24,79, 2 )
         @ 19, 6 SAY " - Part Menu -    "+mpartnum+"  " COLOR "G+"
         @ 19,58 SAY " - Part Menu - "                  COLOR "G+"
         nselect := 1
         @ 21, 4      PROMPT " "
         @ 21,COL()+1 PROMPT "1.Qty Desc"
         @ 21,COL()+2 PROMPT "2.In Stock"
         @ 21,COL()+2 PROMPT "3.Price"
         @ 21,COL()+2 PROMPT "4.Module"
         @ 21,COL()+2 PROMPT "5.Date"
         @ 21,COL()+2 PROMPT "6.Drawing"
         @ 23, 6      PROMPT "7.Cuts"
         @ 23,COL()+2 PROMPT "8.Delete"
         @ 23,COL()+2 PROMPT "9.Memo"
         @ 23,COL()+2 PROMPT "Used Where"
         @ 23,COL()+2 PROMPT "Supplier"
         @ 23,COL()+2 PROMPT "Change Part #"
         @ 23,COL()+2 PROMPT "Another"
         MENU TO nselect

      DO CASE
         CASE nselect == 14
            tempscrn := SAVESCREEN( 0, 0, 24,80 )
            mpartnum := SPACE( 20 )
            mcodeno  := SPACE( 8 )
            SELECT Part
            PartFind( @mpartnum )                      //  
            RESTSCREEN(  0, 0, 24,80,tempscrn )
            LOOP
         CASE PressedEsc()
            mcont  := "Y"
            RETURN NIL 
         CASE nselect == 2                            //   Qty Desc 
            tempscrn := SAVESCREEN( 0, 0, 24,80 )
            cedit := "N"                            // N = Total Stock   
            ProfQty( cedit )                        // 
            RESTSCREEN(  0, 0, 24,80,tempscrn )
            LOOP

         CASE nselect == 3                             //   Instock 
            tempscrn := SAVESCREEN( 0, 0, 24,80 )
            mQty := Part->Instock
            PartQtyMtr( mQty )       // Above 
            RESTSCREEN(  0, 0, 24,80,tempscrn )
            LOOP

         CASE nselect == 4                             // Price
            ***    tempscrn := SAVESCREEN( 0, 0, 24,80 )
            SCROLL(  10, 0, 24,80 )
            DISPBOX( 10, 1, 23,79, 2 )
            @ 10, 6 SAY "  -- Wait For Labour Costs --  "
            nl := 11
            nTotTime:= nTotRate := 0 
            SELECT Labour
            GOTO TOP
            DO WHILE Labour->( !EOF() )
               IF SUBSTR( Labour->Invno, 3, 4 ) != SUBSTR( Part->Partnum, 4, 4 )
                  SKIP ALIAS Labour
                  LOOP
               ENDIF
               IF Labour->Partnum = SPACE( 20 )
                  nTotTime += Labour->Time
                 ELSE
                  nTotRate += Labour->Time*Labour->Rate
               ENDIF
               SKIP ALIAS Labour
            ENDDO                        // Labour EOF
            IF nTotTime > 0 .OR. nTotRate > 0
               @ nl, 4      SAY "Time Hrs"
               @ nl,COL()+2 SAY nTotTime PICTURE "999,999.99"  COLOR "BG+"
               @ nl,COL()+2 SAY "Parts" 
               @ nl,COL()+1 SAY nTotRate PICTURE "$999,999.99" COLOR "G+"
               @ nl,COL()+3 SAY "ALL JC/Inv with xx9999"
               nl++
         ENDIF                        // nTotTime
         SELECT Part
         SET ORDER TO 1                     // Partnum
         SEEK mpartnum
         nlength := Part->Length 
         IF Part->PartMat != SPACE( 20 )
            IF Part->Cutno > 0
               @ nl, 4 SAY "Cuts"
               @ nl, 9 SAY Part->Cutno PICTURE "9999"
            ENDIF
            SELECT Part
            SEEK Part->PartMat
            @ nl,14 SAY "Made From "+TRIM( Part->Partnum );
                        +"  "+TRIM( Part->Desc ) COLOR "BG+"
            nl++
            @ nl, 6 SAY TRIM( Part->Unit );
                       +" Cost"+STR( Part->Trade, 8, 3 );
                       +" Part Cost "+STR( nlength*Part->Trade, 8, 3 ) COLOR "BG+"
            nl++
         ENDIF
         SELECT Supl
         SET ORDER TO 1
         SEEK Part->Partnum
         IF FOUND()
            npl := 21
            @ npl,10 SAY "Suppliers"
            DO WHILE Supl->Partnum == mpartnum .AND. Supl->( !EOF() )
               IF npl > 24
                  npl := 21
                  INKEY(0)
                  SCROLL( 21, 0, 24,80 )
               ENDIF
               @ npl,22      SAY Supl->Codeno COLOR "BG+"
               @ npl,COL()+2 SAY Supl->Cost PICTURE "99,999.999" COLOR "BG+"     
               IF Part->Length > 0
                  @ npl,COL()+2 SAY Supl->Cost*Part->Length PICTURE "99,999.999"     
               ENDIF  
               npl++
               SKIP ALIAS Supl   
            ENDDO
         ENDIF
         nl := 12
         SELECT Part
         SET ORDER TO 1
         nvol:= mQty:= ncsarea := 0
         nlinm:= nrate:= nlen:= ndiscount:= ncost := 0
         @  nl, 6      SAY TRIM( Part->Unit )+" File   "
         @  nl,COL()+1 SAY Part->Trade     PICTURE "999,999.99"
         @  nl,COL()+1 SAY Part->Markup    PICTURE "99,999.99"
         @  nl,COL()+1 SAY "%"
         @  nl,COL()+2 SAY "File Sell"
         @  nl,COL()+1 SAY Part->Wholesale PICTURE "999,999.999"
         nl+=2
         DO CASE

            CASE Part->Unit = "Sq Mtr    "
               nwidth  := Part->Width/1000
               nlength := Part->Length
               nvol    := 1
               ncost   := Part->Trade*( nwidth*nlength ) 
               @  nl, 8      SAY "Width in Mtr"  GET nwidth  PICTURE "99,999.999"
               @  nl,COL()+2 SAY "Length in Mtr" GET nlength PICTURE "99,999.999"
               nl+=2
               @  nl, 8   SAY "Cost per Sheet" GET ncost     PICTURE "99999.999"
                READ
               mQty := ( nwidth*nlength )*nvol
               nl++
               ncost := ncost/( nwidth*nlength )
               @ nl,22      SAY "Per "+TRIM( Part->Unit )  
               @ nl,COL()+1 SAY ncost PICTURE "9,999.999"
               @ nl,COL()+2 SAY "Sq Mtr Per Sheet"
               @ nl,COL()+1 SAY mQty PICTURE "999.999"
               IF PressedEsc()
                  RETURN NIL
               ENDIF
                ApRLock( 3 )
               Part->Width  := nwidth*1000   // Convert to mm
               Part->Length := nlength
               Part->Trade  := ncost         // per Sq Mtr
               UNLOCK

            CASE Part->Unit = "Cu Mtr   "
               ncsarea := ( Part->Width*Part->Thick)/1000000
               nwidth  := Part->Width/1000
               nthick  := Part->Thick/1000
               @ nl, 6      SAY "Width Mtr"      GET nwidth
               @ nl,COL()+2 SAY "Thick Mtr"      GET nthick
               nl++
               @ nl, 6      SAY "Volume in Cu/M" GET nvol  PICTURE "99.999"
               @ nl,COL()+2 SAY "Rate per Cu/M"  GET nrate PICTURE "999.999"
                READ
               ** Calculate linear metres
               nlen=nvol/ncsarea
               ** Calculate cost per linear metre.
               ** Must allow for variable volume here  (Try various volumes for
               **   same width & thickness - cost should be constant)
                ncost := ( nrate/nlen )*nvol
               ** Show total linear & cost  (can build wastage factor in here)
               ***     ncost := ncost*1.1
                nl++
                @ nl, 6      SAY "Metres "+STR( nlen,5 )
                @ nl,COL()+1 SAY "Per Mtr "+STR( ncost,6,3 )
               ApRLock( 3 )
               Part->Length := nlength*1000
               Part->Width  := nwidth*1000   // Convert to mm
               Part->Trade  := ncost
               UNLOCK
      
               CASE Part->Unit = "Mtr       "                 // Linear Mtr
                  ncost   := Part->Length*Part->Trade
                  nlength := Part->Length
                  @ nl, 6      SAY "Length Mtr " GET nlength 
                  @ nl,COL()+2 SAY "Length Cost" GET ncost PICTURE "999999.999"
                   READ
                  nl++ 
                  @ nl, 6      SAY TRIM( Part->Unit )+" Cost"
                  @ nl,COL()+5 SAY ncost/nlength PICTURE "99,999.999" COLOR "G+"
            ENDCASE
      
            nl++
            SCROLL( nl, 5, nl,73 )
            SELECT Part
              ApRLock( 3 )
            IF Part->Markup == 0
               Part->Markup := Cat->Markup
            ENDIF
            UNLOCK
            ntrade  := Part->Trade
            nmarkup := Part->Markup
            @ nl, 6 SAY TRIM( Part->Unit )+" Cost " GET ntrade PICTURE "999999.999"
            IF SUBSTR( Control->U_Name,1,5 ) != "CHRIS"
               @ nl,COL()+2 SAY "Mkup %"              GET nmarkup PICTURE "9999.99"
              ELSE
               @ nl,COL()+2 SAY "Mkup %"
               @ nl,COL()+2 SAY nmarkup PICTURE "9999.99"
            ENDIF
             READ
             ApRLock( 3 )
            Part->Trade  := ntrade
            Part->Markup := nmarkup
            nsell := ( Part->Trade* ( 1+( Part->Markup/100) ) )
            IF SUBSTR( Control->U_Name,1,5 ) != "CHRIS"
               Part->Wholesale := ( Part->Trade* ( 1+( Part->Markup/100) ) )
            ENDIF
            IF Part->Margin == 0
               Part->Margin := Part->Markup
            ENDIF
            UNLOCK
            nwholesale := Part->Wholesale
            nl+=2
            @ nl, 6 SAY TRIM( Part->Unit )+" Sell exl GST";
                    GET nwholesale PICTURE "999999.999"
             READ
             ApRLock( 3 )
            Part->Wholesale := nwholesale   
            Part->Markup := ( ( Part->Wholesale-Part->Trade ) / Part->Trade ) *100
            IF Part->Trade != ntradeDate
               Part->Date := DATE()
            ENDIF
            UNLOCK
            COMMIT
            LOOP

         CASE nselect == 5                               // Module
            SELECT EquDesc
            SET ORDER TO 1   
            GOTO TOP
            SEEK TRIM( Part->Partnum )
            csyscode := SPACE( 7 )
            IF FOUND()
               ***        tempscrn := SAVESCREEN( 0, 0, 24,80 )
               mmod1 := mmodcode
               EquCost( mmod1 )                      // CWPPart
               ***        RESTSCREEN(  0, 0, 24,80,tempscrn )
               SELECT Part
               SEEK mpartnum
               mpartnum := Part->Partnum
               LOOP
            ENDIF
            mmodcode := TRIM( mpartnum )
            SELECT EquDesc
            GOTO TOP
            SEEK mmodcode
            IF FOUND()
               mmodcode := EquDesc->Modcode
               ntotal:= nwholesale := 0
               EquSearch( @mmodcode )               // XLF_Equ3 
            ELSE
               mok := ApGetY( "Do You want to ADD Module" )
               coperno := SPACE( 8 )
               IF mok = "Y"
                   ApFLock( 3 )
                  APPEND BLANK
                  EquDesc->ModCode := TRIM( Part->Partnum )
                  EquDesc->Desc    := Part->Desc
                  EquDesc->Operno  := coperno 
                  UNLOCK
                  SELECT Equ
                   ApFLock( 3 )
                  APPEND BLANK
                  Equ->ModCode  := EquDesc->Modcode
                  Equ->Catno    := Part->Catno
                  Equ->Partnum  := Message->LabPart
                  Equ->PartQty  := 1
                  Equ->ModSeqno := EquDesc->Modcode+STR( RECNO(), 6 )
                  UNLOCK
                  SELECT Part
                   ApRLock( 3 )
                  Part->ABC := "M"
                  UNLOCK
                  SCROLL( 1, 2, 1,78 )
                  @  1, 5 SAY EquDesc->ModCode+"  "+EquDesc->Desc
                  mmodcode := EquDesc->ModCode
                  tempscrn := SAVESCREEN( 11, 0, 24,80 )
                   EquSearch( mmodcode )
                  RESTSCREEN( 11, 0, 24,80, tempscrn )
               ENDIF                         // mok
            ENDIF
            LOOP
         
         CASE nselect == 6
            LabCutDate()                   // XLF_Qu1
            LOOP 
         
         CASE nselect == 7                    
            mpartnum := Part->Partnum
            DrawReview( @mpartnum ) 
            ***            JobDraw()                      // CWP2.PRG 
            ***            LabCut()                       // XLF2PPART
            LOOP 

         CASE nselect == 8
            tempscrn := SAVESCREEN( 0, 0, 24,80 )
            mprint := "Y"
            ****  ApGetY( "List Cuts/Parts" )
            IF mprint = "Y"
               EquCutList()
            ELSE
               SCROLL(   3, 0, 24,80 )
               DISPBOX(  3, 1, 24,79, 2 )
               nl := 4
               mpart := SPACE ( 20 )
               SELECT EquCut
               GOTO TOP
               DO WHILE EquCut->( !EOF() )
                  IF SUBSTR( EquCut->ModSeqno, 1, 7 ) != SUBSTR( Part->Partnum, 1, 7 )
                     SKIP ALIAS EquCut
                     LOOP
                  ENDIF
                  IF mpart != EquCut->Partnum
                     SELECT Part
                     SEEK EquCut->Partnum
                     @ nl, 3 SAY TRIM( Part->Partnum )+" "+TRIM( Part->Desc );
                                 +" "+TRIM( Part->Unit ) COLOR "BG+"
                     SELECT Part
                     SEEK mpartnum
                     nl++
                  ENDIF                               // mpart
                  IF nl >= 22
                     INKEY( 0 )
                     nl := 4
                     SCROLL(  4, 2, 23,78 )
                  ENDIF
                  SELECT EquCut 
                  @ nl, 7      SAY EquCut->ModRef
                  @ nl,COL()+1 SAY "Qty"
                  @ nl,COL()+1 SAY EquCut->Qty    PICTURE "99999"
                  @ nl,COL()+1 SAY EquCut->Length PICTURE "999.999"
                  IF EquCut->Width != 0
                     @ nl,COL()+1 SAY EquCut->Width  PICTURE "999.999"
                  ENDIF
                  mpart := EquCut->Partnum
                  @ nl,58 SAY EquCut->Partnum
                  nl++
                  SKIP ALIAS EquCut
               ENDDO
               nl++
               @ nl,20 SAY Message->AnyKey
               INKEY( 0 )
            ENDIF     // mprint  
            RESTSCREEN( 0, 0, 24,80,tempscrn )
            LOOP
            /*
            CASE nselect == 9                            // Work Lab/Parts
                 tempscrn := SAVESCREEN( 0, 0, 24,80 )
                PartLabour( mpartnum )
                SELECT Part
                SEEK mpartmod
                 RESTSCREEN(  0, 0, 24,80,tempscrn )
             LOOP
            */

         CASE nselect == 9                              // Delete Part
            PartDelete()         // Above
            LOOP 
         CASE nselect == 10                                // Memo
            tempscrn := SAVESCREEN( 0, 0, 24,80 )
            coderef  := mpartnum

            M2Memofile( coderef )                     // XF_Memo2
            RESTSCREEN(  0, 0, 24,80,tempscrn )
            /*
            mok := ApGetN( TRIM( Message->Delete )+" Memo" )
            IF mok == "Y"
               SELECT Cusnotes
               SEEK coderef
                ApFLock( 3 )
               DO WHILE FOUND()
                  DELETE
                  SEEK coderef
               ENDDO
               UNLOCK
               SELECT Part
             ENDIF
            */
            ***          Partflt( @mpartnum )                  // Below
             SELECT Part
            mcontinue := "Y"
            LOOP

          CASE nselect == 11                               // Part Used 

             PartUsed( mpartnum )                          // XF_Part 
             INKEY( 0 )
           mcontinue := "Y"
           LOOP
          CASE nselect == 12                               // Supplier 
            cpartorg := mpartnum
           tempscrn := SAVESCREEN( 0, 0, 24,80 )

             Suppliers( mpartnum )                          // XF_Part 
           RESTSCREEN(  0, 0, 24,80,tempscrn )
           SELECT Part
           SET ORDER TO 1
           mpartnum := cpartorg
           SEEK mpartnum
           LOOP
           mcontinue := "Y"

          CASE nselect == 13                             // Change Part #
              tempscrn := SAVESCREEN( 0, 0, 24,80 )
               Partchange( @mpartnum )
              RESTSCREEN(  0, 0, 24,80,tempscrn )
              LOOP
      ENDCASE
      manother := "Y"
      ***  ApGetY( Message->Another )
   ENDDO               // Another
   ***       LOOP 
   ***     ENDCASE
     SCROLL(  19, 0, 24,80 )
     mcont := "Y"
   ***   ENDDO

   RETURN mpartnum

   ****---- End PartDets()

   ***-------------------------------------------------------------------------

FUNCTION PartDelete()

    mpartnum := Part->Partnum 
    mok2 := "Y"
    mok := ApGetN( TRIM( Message->Delete )+" "+mpartnum )
    IF mok == "Y"
       SET EXACT OFF
       SELECT Debit
       GOTO TOP 
       DO WHILE Debit->( !EOF() )
           IF SUBSTR( DEBIT->Invno, 3, 4 ) = SUBSTR( mpartnum, 4, 4 )
              SCROLL( 14, 2, 23,78 )
              @ 18,20 SAY "There is A Debit # "+Debit->Invno COLOR "RG+"
              mok2 := ApGetN( TRIM( Message->Delete )+" DEBIT EXISTS" )
              IF mok2 == "N"
                 RETURN NIL
              ENDIF
            ENDIF
           SKIP ALIAS Debit
           LOOP
       ENDDO
       IF mok2 == "N"
          RETURN NIL
       ENDIF
       @ 14,10 SAY "DELETE Are You Sure " COLOR "RG+"
       mok := ApGetN( TRIM( Message->Delete )+" "+mpartnum )
       IF mok == "N"
          RETURN NIL
       ENDIF
       @ 21,10 SAY "   Please Wait takes time   "
       SELECT Part
       SET ORDER TO 1       // Partnum
       SEEK mpartnum
        ApRLock( 3 )
       DELETE 
       UNLOCK
       SELECT CusNotes
        ApFLock( 3 )
       DELETE ALL FOR SUBSTR( Code_Ref, 1,20 ) = mpartnum 
       UNLOCK
       SELECT PartOper
        ApFLock( 3 )
       DELETE ALL FOR PartOper->Partnum = mpartnum 
       UNLOCK
       SELECT Equ
        ApFLock( 3 )
       DELETE ALL FOR Equ->Partnum = mpartnum 
       GOTO TOP
       DELETE ALL FOR Equ->Modcode = SUBSTR( mpartnum, 1,16 )
       UNLOCK
       SELECT EquCut
        ApFLock( 3 )
       DELETE ALL FOR SUBSTR( EquCut->ModSeqno, 1,16 ) = SUBSTR( mpartnum, 1,16 ) 
       UNLOCK
       SELECT EquDesc
        ApFLock( 3 )
       DELETE ALL FOR EquDesc->Modcode = SUBSTR( mpartnum, 1,16 )
       UNLOCK
       SELECT Hist
        ApFLock( 3 )
       DELETE ALL FOR Hist->Partnum = mpartnum 
       UNLOCK
       SELECT Orders
        ApFLock( 3 )
       DELETE ALL FOR Orders->Partnum = mpartnum 
       UNLOCK
      /*
       SELECT PartSer
        ApFLock( 3 )
       DELETE ALL FOR PartSer->Partnum = mpartnum 
       UNLOCK
      */
       SELECT Quot
        ApFLock( 3 )
       DELETE ALL FOR Quot->Partnum = mpartnum 
       UNLOCK
       SELECT QuotInfo
        ApFLock( 3 )
       DELETE ALL FOR QuotInfo->Partnum = mpartnum 
       UNLOCK
      /*
       SELECT Labour
       GOTO TOP
        ApFLock( 3 )
       DO WHILE Labour->( !EOF() )
          IF Labour->Partnum = mpartnum
            DELETE
          ENDIF 
          IF SUBSTR( Labour->Invno, 3, 4 ) = SUBSTR( mpartnum, 4, 4 )
             DELETE
          ENDIF
          SKIP ALIAS Labour 
       ENDDO                          // Labour
       UNLOCK
      */
       SELECT Supl
        ApFLock( 3 )
       DELETE ALL FOR Supl->Partnum = mpartnum 
       UNLOCK
       @ 22,20 SAY mpartnum+" Deleted" COLOR "RG+"
       INKEY( 2 ) 
       mpartnum := SPACE( 20 )
      ELSE
       mcontinue := "Y"
      ***             SET EXACT ON
    ENDIF                            // mok
   RETURN NIL
   *****----------  End of PartDelete

   *****----------------------------------------------------------------

FUNCTION PartLabour( mpartnum )

   mpartmod := Part->Partnum
   cname   := SPACE( 40 )
   manother = "Y"
   DO WHILE manother = "Y"
      SELECT Part
      SET ORDER TO 1        // Partnum
      SEEK mpartmod
      mpartnum := Part->Partnum
      aPart_:={}
      nrecno := 0
      ntotal:= nlabour := 0
      SELECT Labour
      GOTO TOP
            DO WHILE Labour->( !EOF() )
               IF SUBSTR( Labour->Invno, 3, 4 ) != SUBSTR( Part->Partnum, 4, 4 )
                  SKIP ALIAS Labour
                  LOOP
               ENDIF  
               IF Labour->Partnum = SPACE( 20 )
                  nlabour += Labour->Time
                 ELSE
                  ntotal += Labour->Time*Labour->Rate
               ENDIF
               AADD( aPart_,Labour->Codeno;
                         +" "+STR( Labour->Time, 8, 2 );
                         +" "+STR( Labour->Rate, 8, 2 );
                         +" "+SUBSTR( Labour->Desc, 1,30 );
                         +" "+DTOC( Labour->Date );
                         +" "+Labour->Invno;
                         +"          "+STR( RECNO(), 6 ) ) 
                 SKIP ALIAS Labour
             ENDDO                        // Labour EOF
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX( 0, 1, 4,79, 2 )
         @  1,10      SAY Part->Partnum+" "+Part->Desc  
         @  3,14      SAY "Time" 
         @  3,COL()+1 SAY nlabour PICTURE "9,999.99"   COLOR "BG+"
         @  3,COL()+2 SAY "Parts"
         @  3,COL()+1 SAY ntotal  PICTURE "$99,999.99" COLOR "BG+"
         DISPBOX( 4, 1, 24,79, 2 )
      ***      ASORT(aPart_,,,{ | x,y | x < y })
         anum := ACHOICE(  5, 3, 23,78,aPart_,,"AFUNC" )
         IF PressedEsc()
            manother = "Y"
            RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
      ENDIF                        // Empty
   SCROLL(  20, 0, 24,80 )
   DISPBOX( 20, 1, 24,79, 2 )
   nselect := 1
   @ 20, 6 SAY " ---- Labour Menu ---- " COLOR "BG+" 
   @ 20,49 SAY " ---- Labour Menu ---- " COLOR "BG+" 
   @ 21, 6      PROMPT "1. Add Labour"
   @ 21,COL()+2 PROMPT "2. Add Part"
   @ 21,COL()+2 PROMPT "3. Edit"
   @ 21,COL()+2 PROMPT "4. Print"

   @ 23, 6      PROMPT "5. Lab/Parts List"
   @ 23,COL()+2 PROMPT "6. Module"
   @ 23,COL()+2 PROMPT "7. Delete"
   MENU TO nselect
   DO CASE
      CASE PressedEsc()
         manother = "N"
         PartDets( mpartnum )

      CASE nselect == 1                // ADD NEW
         SELECT Name
         GOTO TOP
         aPart_:={}
         nrecno := 0
         IF LASTREC() != 0
            DO WHILE  Name->( !EOF() )
               IF Name->Sale != "STAF"
                  SKIP ALIAS Name
                  LOOP
               ENDIF  
               AADD( aPart_,( Name->Codeno+"   "+SUBSTR( Name->Name,1,26 );
                          +" "+SUBSTR( Name->Add1,1,20 );
                          +" "+Name->Phone;
                          +"                     "+STR( RECNO(),6 ) ) )
               SKIP ALIAS Name
            ENDDO
            SCROLL(  10, 0, 20,80 )
            DISPBOX( 10, 1, 21,79, 2 )
            IF !EMPTY( aPart_ )
               ASORT( aCatcode_,,,{ | x,y | x < y } )
               anum := ACHOICE( 11, 5, 20,76,aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               IF PressedEsc()
                  SELECT Name
                  SEEK mcodeno
                  RETURN NIL
               ENDIF
               GOTO nrecno
            ENDIF
         ENDIF           // LastRec
         mcorrect := "N"
         DO WHILE mcorrect == "N"
            SCROLL(  10, 0, 24,80 ) 
            DISPBOX( 10, 1, 21,79, 2 )
            @ 12,10      SAY Name->Name
            SELECT Labour
             ApFLock( 3 )
            APPEND BLANK
            Labour->Codeno  := Name->Codeno
            Labour->Date    := DATE()
            Labour->Invno   := "20"+SUBSTR( Part->Partnum, 4, 4 )
            Labour->Labno   := Name->Codeno
            Labour->Desc    := Part->Desc
            Labour->Message := "General Fabrication"
            UNLOCK
            mpartnum := Labour->Partnum
            mdesc    := Labour->Desc
            mmessage := Labour->Message
            mfault   := Labour->Fault
            ntime    := Labour->Time
            nrate    := Labour->Rate
            minvno   := Labour->Invno
            ddate    := Labour->Date
            @ 14,10      SAY "Desc"     GET mdesc    PICTURE "@KX"
            @ 15,15                     SAY mmessage PICTURE "@KX"
            @ 16,15                     SAY mfault   PICTURE "@KX"
            @ 17,10      SAY "Time"     GET ntime    PICTURE "9999.99"
            @ 18,10      SAY "JC-"      GET minvno   PICTURE "@!"
            @ 18,COL()+2 SAY "Date"     GET ddate    PICTURE "99/99/9999"
             READ
             ApRLock( 3 )
            Labour->Partnum := mpartnum
            Labour->Desc    := mdesc
            Labour->Message := mmessage
            Labour->Fault   := mfault
            Labour->Time    := ntime
            Labour->Rate    := nrate
            Labour->Invno   := minvno
            Labour->Date    := ddate
            UNLOCK
            mcorrect := "Y" 
         ENDDO                                            // mcorrect
         mcont := "Y"
         LOOP

      CASE nselect == 2                // ADD NEW PART
          tempscrn := SAVESCREEN( 0, 0, 24,80 )
          mpartorig := mpartnum

           PartFind( mpartnum )

          RESTSCREEN(  0, 0, 24,80,tempscrn )
         mpart := Part->Partnum
         mInvno := Labour->Invno
         mcorrect := "N"
         DO WHILE mcorrect == "N"
            SCROLL(  10, 0, 24,80 ) 
            DISPBOX( 10, 1, 21,79, 2 )
            SELECT Labour
             ApFLock( 3 )
            APPEND BLANK
            Labour->Date    := DATE()
            Labour->Invno   := mInvno
            Labour->Rate    := Part->Trade
            Labour->Desc    := Part->Desc
            Labour->Partnum := Part->Partnum
            UNLOCK
            mpartnum := Labour->Partnum
            mdesc    := Labour->Desc
            mmessage := Labour->Message
            mfault   := Labour->Fault
            ntime    := Labour->Time
            nrate    := Labour->Rate
            minvno   := Labour->Invno
            ddate    := Labour->Date
            @ 14,10      SAY "Partnum"  GET mpartnum PICTURE "@K!"
            @ 15,10      SAY "Desc"     GET mdesc    PICTURE "@KX"
            @ 16,15                     SAY mmessage PICTURE "@KX"
            @ 17,15                     SAY mfault   PICTURE "@KX"
            @ 18,10      SAY "Qty "     GET ntime    PICTURE "9999.99"
            @ 18,COL()+2 SAY "Rate"     GET nrate    PICTURE "99999.99"
            @ 19,10      SAY "JC-"      GET minvno   PICTURE "@!"
            @ 19,COL()+2 SAY "Date"     GET ddate    PICTURE "99/99/9999"
             READ
             ApRLock( 3 )
            Labour->Partnum := mpartnum
            Labour->Desc    := mdesc
            Labour->Message := mmessage
            Labour->Fault   := mfault
            Labour->Time    := ntime
            Labour->Rate    := nrate
            Labour->Invno   := minvno
            Labour->Date    := ddate
            UNLOCK
            mcorrect := "Y" 
         ENDDO                                            // mcorrect
         SELECT Part
         SEEK mpartorig   
         SCROLL(  0, 0, 2,80 ) 
         DISPBOX( 0, 1, 2,79, 2 )
         @  1, 4 SAY TRIM( mpartnum )+"  "+TRIM( Part->Desc ) COLOR "G+"
         manother := "Y"
         LOOP

      CASE nselect == 3                    // Edit Labour
         mcorrect := "N"
         DO WHILE mcorrect == "N"
            SELECT Labour
             ApRLock( 3 )
            SCROLL(   8, 0, 24,80 ) 
            DISPBOX(  8, 1, 19,79, 2 )
            mpartnum := Labour->Partnum
            mdesc    := Labour->Desc
            mmessage := Labour->Message
            mfault   := Labour->Fault
            ntime    := Labour->Time
            nrate    := Labour->Rate
            minvno   := Labour->Invno
            ddate    := Labour->Date
            mlabno   := Labour->Labno
            mcodeno  := Labour->Codeno
            @  9,10      SAY "Partnum"  GET mpartnum PICTURE "@K!"
            @ 11,10      SAY "Desc"     GET mdesc    PICTURE "@KX"
            @ 12,15                     GET mmessage PICTURE "@KX"
            @ 13,15                     GET mfault   PICTURE "@KX"
            @ 15,10      SAY "Time"     GET ntime    PICTURE "9999.99"
            @ 15,COL()+2 SAY "Rate"     GET nrate    PICTURE "99999.99"
            @ 16,10      SAY "JC-"      GET minvno   PICTURE "@!"
            @ 16,COL()+2 SAY "Date"     GET ddate    PICTURE "99/99/9999"
            @ 18,10      SAY "Inv Code" GET mlabno   PICTURE "@!"
            @ 18,COL()+1 SAY "Staff"    GET mcodeno  PICTURE "@!"
             READ
             ApRLock( 3 )
            Labour->Partnum := mpartnum
            Labour->Desc    := mdesc
            Labour->Message := mmessage
            Labour->Fault   := mfault
            Labour->Time    := ntime
            Labour->Rate    := nrate
            Labour->Invno   := minvno
            Labour->Date    := ddate
            Labour->Labno   := mlabno
            Labour->Codeno  := mcodeno
            UNLOCK
            mcorrect := ApGetY( Message->Correct )
         ENDDO                                            // mcorrect
         manother := "Y"
         LOOP
      CASE nselect == 4                // Print
          LabPart( mpartnum )          // XLF_Qu5
         manother := "Y"
         LOOP
     CASE nselect = 5                      // Only Parts List                 
          LabPComp( mmodcode )                     // JobFunc
          LabPList( mmodcode )                     // JobFunc

      CASE nselect == 6                            // Module  
            SELECT EquDesc
            SET ORDER TO 1   
            GOTO TOP
            SEEK TRIM( mpartnum )
            csyscode := mpartnum
         IF FOUND()
             mmod1 := TRIM( mpartnum )
             EquCost( mmod1 )                      // CWPPart
             SELECT Part
             SEEK csyscode
             mpartnum := Part->Partnum
           ELSE
             mok := ApGetY( "Do You want to ADD Module" )
             IF mok = "Y"
                 ApFLock( 3 )
                APPEND BLANK
                EquDesc->ModCode := TRIM( Part->Partnum )
                EquDesc->Desc    := Part->Desc
                UNLOCK
                SELECT Part
                 ApRLock( 3 )
                Part->ABC := "M"
                UNLOCK
                SCROLL( 1, 2, 1,78 )
                @  1, 5 SAY EquDesc->ModCode+"  "+EquDesc->Desc
                mmodcode := EquDesc->ModCode
                tempscrn := SAVESCREEN( 11, 0, 24,80 )

                 EquSearch( mmodcode )

                RESTSCREEN( 11, 0, 24,80, tempscrn )
                SELECT Part
                SEEK csyscode
                mpartnum := Part->Partnum
             ENDIF                         // mok
          ENDIF                            // Found
         
     CASE nselect = 7                 // Delete
            SCROLL(  10, 0, 24,80 ) 
            DISPBOX( 11, 1, 19,79, 2 )
            @ 12, 8      SAY "Desc  "+Labour->Desc
            @ 12,COL()+1 SAY "Part "+Labour->Partnum
            @ 14, 8      SAY "Time "+STR( Labour->Time )
            @ 16, 8      SAY "Invno "+Labour->Invno
            @ 16,COL()+2 SAY "Date "+DTOC( Labour->Date )
            @ 18, 8      SAY "Inv Code "+Labour->Labno
            @ 18,COL()+2 SAY "Staff "+Labour->Codeno
             READ
         mdelete := ApGetN( TRIM( Message->Delete )+" Labour" )
         IF mdelete == "Y"
            minvno := Labour->Invno
            SELECT Labour
             ApRLock( 3 )         
            DELETE
            UNLOCK
   /*
            mdelete := ApGetN( "Delete ALL FOR INVOICE" )
            IF mdelete == "Y"
               mdelete := ApGetN( "ARE YOU SURE Delete ALL FOR INVOICE" )
               IF mdelete == "Y"
                   ApFLock( 3 )         
                  DELETE ALL FOR Labour->Invno = minvno
                  UNLOCK
               ENDIF
            ENDIF
   */
         ENDIF
         mcont := "Y"
      ENDCASE
   ENDDO

   RETURN NIL

FUNCTION LabCopy( mpartnum )

   SELECT Part
   SEEK mpartnum
   mmod := SPACE( 16 )
   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 ) 
   @ 1,10 SAY Part->Partnum+" "+Part->Desc 
   mpartnum := Part->Partnum
   minvno   := SPACE( 6 )
   DISPBOX( 4, 1, 8,79, 2 ) 
   IF SUBSTR( mpartnum, 1, 3 ) = "JC-"
      minvno := "20"+SUBSTR( mpartnum, 4, 4 )
      @ 6,10 SAY "Select Invoice" GET minvno PICTURE "!!!!!!"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
   ENDIF                                   // JC-
   SELECT Debit
   SET ORDER TO 2                   // Invno
   GOTO TOP
   SEEK minvno
   IF !FOUND()  
      SELECT Debit
      GOTO TOP
      IF LASTREC() != 0
         aPart_ := {}
         nrecno := 0
         DO WHILE Debit->( !EOF() )
            AADD( aPart_,Debit->Invno+" "+Debit->Stat;
                 +" "+Debit->Codeno;
                 +" "+DTOC( Debit->Dbdate );
                 +" "+STR( Debit->Amount, 8, 2 );
                 +" "+Debit->Saleno;
                 +" "+Debit->Est+"                        "+STR( RECNO(),6 ) )
            SKIP ALIAS Debit
         ENDDO
         IF !EMPTY( aPart_ )
            SCROLL()
            DISPBOX(  0, 0, 24,79, 2 )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum   := ACHOICE(  1, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
            IF PressedEsc()
               RETURN NIL
            ENDIF
            nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
            GOTO nrecno
            minvno := Debit->Invno
         ENDIF                     // Empty
      ENDIF                        // LastRec
   ENDIF    
   SELECT Debit
   SET ORDER TO 1
   manother = "Y"
   DO WHILE manother = "Y"
      SCROLL()
      DISPBOX(  0, 1, 24,37, 2 )
      mmod := SUBSTR( Part->Partnum, 1,16 )
      SELECT Equ
      SEEK mmod
      @  0, 8 SAY "  "+Equ->Modcode+"  "
      nl := 1
      DO WHILE Equ->Modcode = mmod .AND. Equ->( !EOF() )
         @ nl, 3      SAY Equ->Partnum COLOR "BG+"
         @ nl,COL()+2 SAY Equ->PartQty COLOR "BG+"
         nl++
         SKIP ALIAS Equ
      ENDDO                       // EOF() Equ
      aPart_ := {}
      nrecno := 0
      nTimeTotal := 0
      SELECT Labour
      GOTO TOP
      DO WHILE Labour->( !EOF() )
         IF SUBSTR( Labour->Invno, 3, 4 ) != SUBSTR( minvno, 3, 4 )
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Partnum = SPACE( 20 )
            nTimeTotal += Labour->Time
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Labno != SPACE( 8 )
            SKIP ALIAS Labour
            LOOP
         ENDIF
         AADD( aPart_,SUBSTR( Labour->Partnum, 1,16 );
                     +" "+SUBSTR( Labour->Codeno, 1, 4 );
                     +" "+STR( Labour->Time );
                     +" "+Labour->Invno;
                     +"   "+STR( RECNO(),6 ) )
         SKIP ALIAS Labour
      ENDDO                // EOF Labour
   IF !EMPTY( aPart_ )
      ASORT( aPart_,,,{ | x,y | x < y } )
      SCROLL(   0,39, 24,49 )
      DISPBOX(  0,39, 24,79, 2 )
      @ 0,48 SAY "  "+Debit->Invno+" xxx9999  "
      @ 23,52 SAY "Total Hrs"
      @ 23,62 SAY nTimeTotal PICTURE "99,999.99"
      anum := ACHOICE(  1,41, 22,78,aPart_,,"AFUNC" )
      nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
      IF PressedEsc()
         RETURN NIL
      ENDIF
      GOTO nrecno
   ENDIF               // Empty
   SCROLL(  18, 0, 24,37 )
   DISPBOX( 18, 1, 24,37, 2 ) 
      @ 20, 4 SAY Labour->Partnum
      nQty := Labour->Time
      @ 22, 4 SAY "Qty To Copy" GET nQty PICTURE "9999.99"
      @ 23,20 SAY "0 = Not Copied"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      IF nQty > 0
         SELECT Equ
         ApFLock( 3 )
        APPEND BLANK
        Equ->Modcode := SUBSTR( mpartnum, 1,16 ) 
        Equ->Partnum := Labour->Partnum
        Equ->PartQty := nQty 
        UNLOCK
     ENDIF
      ***  manother := ApGetY( "Another Part" )
     LOOP
   ENDDO
   SELECT Part
   SEEK mpartnum
   mpartnum := Part->Partnum

   RETURN mpartnum

   ***-----------------   LabCopy

   ***-------------------------       END OF CWP2.PRG
