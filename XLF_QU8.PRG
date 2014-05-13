   ***  JoKir10  13-10-11 07:25:35  

/*
   Program.....:                  XLF_QU8.PRG
   Authors.....: J.Kirby
   Date........: 18/06/2002
   Functions...: JobIssue, PlanList, JCPrice, JCReqTot
                 QuotCode, JobXtAll
   Static funcs: PlanQuotList
   Not used....: QuotStat, JobQStk
*/

FUNCTION JobIssue()

   npn := 1
   cpagehd := "SPissued"
   minvno  := SPACE( 6 )
   nissued := 0
   SCROLL()

   UpDateJC()  // Updates File         // XF_Util

   mjc := ApGetY( "Select One JC- Only" )
   IF mjc = "Y"
      QuotFind()
      minvno := Debit->Invno
      SELECT Name
      SEEK Quot->Codeno
   ENDIF
   @ 10,10 SAY "You Should Print This   PLEASE PRINT" COLOR "BG+"
   mxy := ApGetN( "Do you want XY Parts" )
   IF mxy = "N"
      cpagehd := "SPissuednoXY"
   ENDIF    
   *** SELECT Name
   *** SEEK Quot->Codeno
   mwhere := "S" 

   Printsel()

   IF mwhere = "P"
      npl := 56
   ELSE
      npl := 22
   ENDIF
   @  0, 2 SAY Control->U_Name
   @  0,40 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
              +STR( YEAR(DATE() ),5 )
   @  0,60 SAY cpagehd
   @  0,76 SAY npn PICTURE "99"
   IF mjc = "Y"
      @  2, 0 SAY Name->Name
      @  2,40 SAY "Parts Instock Issued to JC- "+minvno
   ELSE
      @  2,40 SAY "Parts Instock Issued to JC-"
   ENDIF
   @  4, 0 SAY "Part #"
   @  4,17 SAY "Description"
   @  4,46 say "Location"
   @  4,59 SAY "Outstanding"
   @  4,71 SAY "Issued"
   nl := 5
   nreq:= malloc := 0
   SELECT QuotStk
   SET ORDER TO 1        // Invno+ModPart
   GOTO TOP
   cmodcode := QuotStk->ModCode          // Gives Qty of Module
   DO WHILE QuotStk->( !EOF() )
      IF mjc = "Y"
         IF QuotStk->Invno != minvno
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF
      /*
      IF mxy = "N"
         IF SUBSTR( QuotStk->Partnum, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF
      */ 
      IF mxy = "N"                                    // ModCode
         IF SUBSTR( QuotStk->ModCode, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF 
      IF SUBSTR( QuotStk->Partnum, 1, 1 ) = "Z"
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      IF QuotStk->Required = 0
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      SELECT Part
      SEEK QuotStk->Partnum
      IF Part->Instock <= 0
         SELECT QuotStk   
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      IF nl > npl
         IF mwhere = "P" 
            EJECT
         ELSE
            WAIT
          SCROLL()
         ENDIF
         npn++
         @  0, 2 SAY Control->U_Name
         @  0,40 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         @  0,60 SAY cpagehd
         @  0,76 SAY npn PICTURE "99"
         IF mjc = "Y"
            @  2, 0 SAY Name->Name
            @  2,40 SAY "Parts Instock Issued to JC- "+minvno
         ELSE
            @  2,40 SAY "Parts Instock Issued to JC-"
         ENDIF
         @  4, 0 SAY "Part #"
         @  4,17 SAY "Description"
         @  4,46 say "Location"
         @  4,59 SAY "Outstanding"
         @  4,71 SAY "Issued"
         nl := 5
      ENDIF
      nissued:= nrequired := 0
      SELECT Part
      SEEK QuotStk->Partnum
      nrequired := ( QuotStk->Required-QuotStk->Received )
      IF nrequired > 0
         DO CASE
            CASE Part->Instock >= nrequired
               nissued := nrequired
               ApFLock( 3 )
               Part->Instock -= nissued
               UNLOCK
            CASE Part->Instock < nrequired
               nissued := nrequired-Part->Instock
               ApFLock( 3 )
               Part->Instock := 0
               UNLOCK
         ENDCASE
      ENDIF        // nrequired 
      SELECT QuotStk
      IF nissued > 0
         ApRLock( 3 )
         QuotStk->Received += nissued
         IF QuotStk->Received = QuotStk->Required
            QuotStk->Ordnum   := "SkIs"
         ENDIF
         UNLOCK
         IF cmodcode != QuotStk->Modcode
            @ nl, 4 SAY QuotStk->Invno+" "+QuotStk->Modcode+" Qty "+STR( QuotStk->EquQty, 8, 2 ) 
            nl++
            cmodcode := QuotStk->ModCode
         ENDIF
         @ nl, 0 SAY SUBSTR( QuotStk->Partnum,1,16 )
         @ nl,17 SAY SUBSTR( Part->Desc, 1,28 )
         @ nl,46 SAY SUBSTR( Part->Locate, 1, 9 )
         @ nl,56 SAY QuotStk->Required-QuotStk->Received PICTURE "99999.99"
         @ nl,65 SAY nissued                             PICTURE "99999.99"
         IF nissued < QuotStk->Required-QuotStk->Received
            @ nl,74 SAY "Not All"
          ELSE
            @ nl,74 SAY "Issued"
         ENDIF 
         nl++
         SELECT Labour
          ApFLock( 3 )
         APPEND BLANK
         Labour->Codeno  := Part->Codeno    // SUBSTR( Part->Codeno, 1, 7 )+"!"
         Labour->Partnum := Part->Partnum
         Labour->Time    := nissued  
         Labour->Date    := Date()
         Labour->Desc    := Part->Desc
         Labour->Rate    := Part->Trade
         Labour->Invno   := QuotStk->Invno
         Labour->Fault   := QuotStk->ModCode
         UNLOCK
      ENDIF                          // nissued
      SELECT QuotStk
      SKIP ALIAS QuotStk
   ENDDO                               // QuotStk
   nl++
   IF mwhere = "S"
      WAIT
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ELSE
      EndPrint()
   ENDIF
   SELECT QuotStk
   SET ORDER TO 1              // Invno

   RETURN NIL
   ****------  END JobIssue()

   *****---------------------------------------------------------------------

STATIC FUNCTION PlanQuotList( mcodeno )

   SCROLL()
   DISPBOX( 4, 1, 17,79, 2 )
   @  5,10 SAY "Planning ONLY of Job Card"
   mok := "N"
   minvno  := Debit->Invno
   mcodeno := Debit->Codeno
   coperno := Debit->Operno
   mselect:= cbuyonly := "N"
   mequ := "Y"
   cbuyonly := "Y"
   mstock:= moper:= mABC := "N"
   mequ    := "Y"
   mxy     := "N"
   mlevel  := 4
   cpagehd := "Plan Quot"
   minfo := "Y"
   mwhere := "S"
   npl    := 54
   nl     := 0
   
    Printsel()                               // _LF_Init

   IF mwhere == "P"
      npl := 54
      @  0, 0
      SET DEVICE TO PRINT
    ELSE
      SCROLL()
      npl := 22
   ENDIF
   @ 0, 0 SAY Control->U_Name
   @ 0,45 SAY STR( DAY(  DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR( DATE() ),5 )
   @ 0,67 SAY cpagehd
   nl := 2
   nQty:= nlength := 0
   SELECT Name
   SEEK Debit->Codeno
   @ nl, 5 SAY Name->Name+"  "+Debit->Est+"   "+minvno
   nl+=2
   @ nl,10 SAY "Start Date"
   @ nl,23 SAY DTOC( Debit->StartDate ) 
   @ nl,34 SAY "Due Date"
   @ nl,44 SAY DTOC( Debit->DueDate ) 
   @ nl,58 SAY "O/N # "+Debit->Ordnum
   nl+=2
   SELECT Quot
   SET ORDER TO 2
   SEEK mcodeno
   DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
      IF Quot->Invno != minvno
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF SUBSTR( Quot->Partnum, 1, 2 ) = "ZZ"
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF mwhere = "S"
         IF nl > 22
            INKEY( 0 )
            SCROLL()
            nl := 0
         ENDIF
      ENDIF
      /*
      @ nl, 1 SAY Quot->Partnum
      SELECT Part
      SEEK Quot->Partnum
      @ nl,21 SAY Part->Desc
      nl++
      */
      mpartnum := Quot->Partnum
      ntottime := ntime := 0
      SELECT LabCut
      GOTO TOP
      DO WHILE LabCut->( !EOF() )
         IF LabCut->Partnum != mpartnum
            SKIP ALIAS LabCut
            LOOP
         ENDIF
         IF SUBSTR( LabCut->Partnum, 1, 2 ) = "ZZ"
            SKIP ALIAS LabCut
            LOOP
         ENDIF
         IF nl > npl
            IF mwhere = "P"
               EJECT
               nl := 0
               @ nl, 0 SAY Control->U_Name
               @ nl,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                          +STR( YEAR(DATE() ),5 )
               nl+=2
               ***                    @ nl, 1 SAY mpartnum
               ***                   @ nl,21 SAY Part->Desc
               ***       @ nl,52 SAY "Time"
               nl+=2
            ELSE
               WAIT
               SCROLL()
               nl := 0
            ENDIF
         ENDIF
         @ nl, 1 SAY LabCut->Order
         @ nl, 5 SAY LabCut->Desc
         IF LabCut->Time > 0
            @ nl,48 SAY LabCut->Time PICTURE "99,999.99"
         ENDIF
         @ nl,59 SAY LabCut->Operno
         @ nl,68 SAY SUBSTR( mpartnum, 1, 12 ) 
         ntotTime += LabCut->Time
         nl++
         SKIP ALIAS LabCut
      ENDDO                        // LabCut EOF
      IF ntottime > 0
         @ nl,46 SAY "-----------"
         nl++
         @ nl,35 SAY "Total Time"
         @ nl,48 SAY ntotTime PICTURE "99,999.99"
         @ nl,58 SAY "Hours"
         nl++
      ENDIF 
      mmodcode := TRIM( mpartnum )
      SELECT Equ
      GOTO TOP
      SEEK mmodcode
      DO WHILE Equ->ModCode = mmodcode .AND. Equ->( !EOF() )
         IF SUBSTR( Equ->Partnum, 1, 2 ) = "ZZ"
            SKIP ALIAS Equ
            LOOP
         ENDIF
         IF mwhere = "S"
            IF nl > 22
               INKEY( 0 )
               SCROLL()
               nl := 0
             ENDIF
         ENDIF
         /*
           nl++
           @ nl, 1 SAY Equ->Partnum
           SELECT Part
           SEEK Equ->Partnum
           @ nl,21 SAY Part->Desc
           nl++
         */
         ntottime := ntime := 0
         SELECT LabCut
         GOTO TOP
         DO WHILE LabCut->( !EOF() )
            IF LabCut->Partnum != Equ->Partnum
               SKIP ALIAS LabCut
               LOOP
            ENDIF
            IF SUBSTR( LabCut->Partnum, 1, 2 ) = "ZZ"
               SKIP ALIAS LabCut
               LOOP
            ENDIF
            IF nl > npl
               IF mwhere = "P"
                  EJECT
                  nl := 0
                  @ nl, 0 SAY Control->U_Name
                  @ nl,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                     +STR( YEAR(DATE() ),5 )
                  /* 
                   nl++
                    @ nl, 1 SAY Equ->Partnum
                    SELECT Part
                    SEEK Equ->Partnum
                    @ nl,21 SAY Part->Desc
                    nl++
                    SELECT LabCut
                  */
               ELSE
                  WAIT
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            @ nl, 1 SAY LabCut->Order
            @ nl, 5 SAY LabCut->Desc
            IF LabCut->Time > 0
               @ nl,48 SAY LabCut->Time PICTURE "99,999.99"
            ENDIF
            @ nl,58 SAY LabCut->Operno
            @ nl,68 SAY SUBSTR( Equ->Partnum, 1, 12 ) 
            ntottime += LabCut->Time
            nl++
            SKIP ALIAS LabCut
         ENDDO                        // LabCut EOF
         IF ntottime > 0
            @ nl,46 SAY "-----------"
            nl++
            @ nl,35 SAY "Total Time"
            @ nl,48 SAY ntottime PICTURE "99,999.99"
            @ nl,58 SAY "Hours"
            nl++
         ENDIF 
         SKIP ALIAS Equ
      ENDDO               // Equ
      SKIP ALIAS Quot
   ENDDO              // Quot
   nl+=2
   @ nl, 2 SAY Name->Name+"  "+Debit->Est+"   "+minvno
   nl+=2
   @ nl, 2 SAY "Leading Hand  ______________________   Date__________     "+coperno
   nl++
   ntimetotal:= ntime := 0
   SELECT Operate
   GOTO TOP
   SEEK coperno
   DO WHILE Operate->Operno = coperno .AND. Operate->( !EOF() )
      IF Operate->Print != "P"
         SKIP ALIAS Operate
         LOOP
      ENDIF
      IF nl > npl
         IF mwhere = "P"
            EJECT
            nl := 0
            @ nl, 0 SAY Control->U_Name
            @ nl,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ),5 )
            nl+=2
         ELSE
            WAIT
            SCROLL()
            nl := 0
         ENDIF
      ENDIF
      IF Operate->ABC != " "
         nl++
         @ nl, 1 SAY Operate->Desc
         @ nl,41 SAY "Done By  Checked By   Rework   Checked"                               
         nl++
      ELSE
         @ nl, 0 SAY Operate->Desc
         @ nl,41 SAY "________:__________:___________:_______"
         nl++
      ENDIF
      SKIP ALIAS Operate 
   ENDDO                        // Operate EOF
   IF mwhere = "P"
      @ nl, 0 SAY " "
      EndPrint()
      SET MARGIN TO 0
   ELSE
      IF nl > 18
         WAIT
      ENDIF
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF
   SELECT Quot
   SET ORDER TO 1

   RETURN NIL
   ****----- End of PlanQuotList

   ****--------------------------------------------------------------------------

FUNCTION PlanList()
   SCROLL()
   DISPBOX( 4, 1, 17,79, 2 )
   @  5,10 SAY "Each Use Plan"
   mok := "N"
   ***   minvno := Debit->Invno
   mselect:= cbuyonly := "N"
   mequ := "Y"
   cbuyonly := "Y"
   mstock:= moper:= mABC := "N"
   mequ    := "Y"
   mxy     := "N"
   mlevel  := 4
   mdetail := "N"
   cpagehd := "Plan"+STR( mlevel, 1 )
   minfo := "Y"
   mwhere := "S"
   npl    := 54
   nl     := 0
   
    Printsel()                               // _LF_Init

   IF mwhere == "P"
      npl := 54
      @  0, 0
      SET DEVICE TO PRINT
   ELSE
      SCROLL()
      npl := 22
   ENDIF
   @ 0, 0 SAY Control->U_Name
   @ 0,45 SAY STR( DAY(  DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR( DATE() ),5 )
   @ 0,67 SAY cpagehd
   nl := 2
   nQty:= nlength := 0
   nl++ 
   ***   mmodcode := TRIM( mpartnum )
   IF mwhere = "S"
      IF nl > 22
         INKEY( 0 )
         SCROLL()
         nl := 0
       ENDIF
   ENDIF
   ***        nl++
   @ nl, 1 SAY Part->Partnum+"  "+Part->Desc
   nl++
   ntottime := ntime := 0
   SELECT LabCut
   GOTO TOP
   DO WHILE LabCut->( !EOF() )
      IF LabCut->Partnum != mpartnum
         SKIP ALIAS LabCut
         LOOP
      ENDIF
      IF SUBSTR( LabCut->Partnum, 1, 2 ) = "ZZ"
         SKIP ALIAS LabCut
         LOOP
      ENDIF
      IF nl > npl
         IF mwhere = "P"
            EJECT
            nl := 0
            @ nl, 0 SAY Control->U_Name
            @ nl,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ),5 )
            nl+=2
            @ nl, 1 SAY mpartnum
            ***                   @ nl,21 SAY Part->Desc
            ***       @ nl,52 SAY "Time"
            nl+=2
         ELSE
            WAIT
            SCROLL()
            nl := 0
         ENDIF
      ENDIF
      @ nl, 1 SAY LabCut->Order
      @ nl, 5 SAY LabCut->Desc
      IF LabCut->Time > 0
         @ nl,48 SAY LabCut->Time PICTURE "99,999.99"
      ENDIF
      @ nl,59 SAY LabCut->Operno
      ntotTime += LabCut->Time
      nl++
      SKIP ALIAS LabCut
   ENDDO                        // LabCut EOF
   IF ntottime > 0
      @ nl,46 SAY "-----------"
      nl++
      @ nl,35 SAY "Total Time"
      @ nl,48 SAY ntotTime PICTURE "99,999.99"
      @ nl,58 SAY "Hours"
      nl++
   ENDIF 
   IF mwhere = "P"
      @ nl, 0 SAY " "
      EndPrint()
      SET MARGIN TO 0
   ELSE
      IF nl > 18
         WAIT
      ENDIF
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF
   SELECT Quot
   SET ORDER TO 1

   RETURN NIL
   ****----- End of PlanList

   ****--------------------------------------------------------------------------

FUNCTION JCPrice( mmodcode )

   aPart_ := {}
   anum   := {}
   nrecno := 0
   nnn    := 0
      *** SCROLL()
      *** @ 12,10 SAY mmodcode
      *** @ 12,40 SAY "Quot  "+Quot->Partnum
      *** WAIT
   SELECT Equ
   GOTO TOP
   SEEK mmodcode
      *** mmodcode := Equ->ModCode
   DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !EOF() )
      nnn++
      SELECT Part
      SEEK Equ->Partnum
      SELECT Equ
      AADD( aPart_,SUBSTR( Part->Partnum, 1, 9 );
                   +" "+SUBSTR( Part->Desc, 1,27 );
                   +" "+STR( Equ->PartQty, 8, 3 );
                   +" "+STR( Part->Trade, 9, 2 );
                   +" "+STR( ( Part->Trade*Equ->PartQty ),10, 2 );
                   +" "+TRIM( Part->Unit ) )
      SKIP ALIAS Equ
   ENDDO                       // EOF()
   ntottrade:= ntotwhol := 0
   ntottrade1:= ntotwhol1 := 0
   nrecno2:= nrecno3:= nrecno4 := 0
   nqty1:= nqty2:= nqty3:= nqty4 := 0
   nequ1:= nequ2:= nequ3:= nequ4 := 0
   mmod2:= mmod3:= mmod4 := SPACE( 16 )
   SELECT Equ
   GOTO TOP
   SEEK mmodcode                // Original Part
   IF FOUND()   
      DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !EOF() )
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         mmod2   := SUBSTR( Equ->Partnum, 1,16 ) 
         nqty1   := Equ->Partqty 
         nrecno2 := RECNO() 
         GOTO TOP
         SEEK mmod2
         ntottrade1 += ( Part->Trade*nqty1 )
         ntotwhol1  += ( Part->Wholesale*nqty1 )
         IF !FOUND()
            ntottrade += ( Part->Trade*nqty1 )
            ntotwhol  += ( Part->Wholesale*nqty1 )
          ENDIF
         IF FOUND()
            DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
               SELECT Part
               SEEK Equ->Partnum
               SELECT Equ
               mmod3   := SUBSTR( Equ->Partnum, 1,16 )
               nrecno3 := RECNO() 
               nqty2   := Equ->PartQty
               nequ2   := ( nqty1 * nqty2 )
               GOTO TOP
               SEEK mmod3
         IF !FOUND()   
            ntottrade += ( Part->Trade*nequ2 )
            ntotwhol  += ( Part->Wholesale*nequ2 )
         ENDIF
         IF FOUND()
            DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
               SELECT Part
               SEEK Equ->Partnum
               SELECT Equ
               mmod4   := SUBSTR( Equ->Partnum, 1,16 )
               nrecno4 := RECNO()
               nqty3   := Equ->PartQty
               nequ3   := nqty1 * nqty2 * nqty3
               GOTO TOP
               SEEK mmod4
               IF !FOUND()
                  ntottrade += ( Part->Trade*nequ3 )
                  ntotwhol  += ( Part->Wholesale*nequ3 )
               ENDIF
               IF FOUND()
               DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                  nqty4 := Equ->PartQty
                  nequ4 := nqty1 * nqty2 * nqty3 * nqty4
                  SELECT Part
                  SEEK Equ->Partnum
                  SELECT Equ
                  ntottrade += ( Part->Trade*nequ4 )
                  ntotwhol  += ( Part->Wholesale*nequ4 )
                  SKIP ALIAS Equ
                ENDDO                       //  mmod4
             ENDIF
              SELECT Equ 
              GOTO nrecno4
               SKIP ALIAS Equ
             ENDDO                       //  mmod3
          ENDIF                          // FOUND()  mmod3    
               SELECT Equ
               GOTO nrecno3
               SKIP ALIAS Equ
            ENDDO                       //  mmod2 EOF()
         ENDIF                         // Found mmod2
               SELECT Equ
               GOTO nrecno2
               SKIP ALIAS Equ
               ENDDO                       //   mmodcode EOF()
            ENDIF                          // Found mmodcode
   SELECT Equ
   SEEK mmodcode
   SELECT Part
   SET ORDER TO 1
   GOTO TOP
   SEEK mmodcode              // Original Part
   SCROLL()
   DISPBOX( 0, 1,  2,79, 2 )
   @  1, 4      SAY Part->Partnum+" "+Part->Desc
   @  1,COL()+1 SAY Part->Trade PICTURE "9999,999.99" COLOR "BG+"
   DISPBOX( 3, 1, 24,79, 2 )
   IF !EMPTY( aPart_ )
      @ 3, 6      SAY SPACE( 60 )
      @ 3, 3      SAY "Kit Cost"                       
      @ 3,COL()+2 SAY ntottrade1 PICTURE "$999,999.99" COLOR "BG+"
      @ 3,COL()+2 SAY "Part Cost"                       
      @ 3,COL()+1 SAY ntottrade PICTURE "$999,999.99"  COLOR "BG+"
      @ 3,COL()+2 SAY "Qty   Cost    Qty*Cost "
   IF nnn <= 12 
      ASORT( aPart_,,,{ | x,y | x < y } )
      @  3,00 SAY " "
      AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " ),QQOUT( A ),Breakpoint() } )
   ENDIF
      ***   anum := ACHOICE( 5, 3, 23,78,aPart_,,"AFUNC" )
      ***   IF PressedEsc()
      ***      RETURN NIL
      ***   ENDIF
      SCROLL(  16, 0, 24,80 )
      DISPBOX( 16, 1, 24,79, 2 )
      nl := 17 
      @  nl, 4      SAY "Original Cost"
      @  nl,COL()+1 SAY Part->Trade     PICTURE "999,999.99"
      @  nl,COL()+3 SAY "Mkup %"
      @  nl,COL()+1 SAY Part->Markup    PICTURE "99,999.99"
      @  nl,COL()+2 SAY "Sell"
      @  nl,COL()+1 SAY Part->Wholesale PICTURE "999,999.99"
      nl+=2
      @  nl, 3       SAY Equ->Modcode COLOR "G+"
      @  nl,COL()+1  SAY "Kit Cost"                             
      @  nl,COL()+1  SAY ntottrade1     PICTURE "9,999,999.99" COLOR "BG+"
      @  nl,COL()+2  SAY "Part Cost"                             
      @  nl,COL()+1  SAY ntottrade      PICTURE "9,999,999.99" COLOR "BG+"
      nl+=2 
      ntrade  := Part->Trade
      nmarkup := Part->Markup
      @ nl, 4      SAY "  Adjust Cost"   GET ntrade  PICTURE "9999999.99"
      @ nl,COL()+2 SAY "Mkup % " GET nmarkup PICTURE "9999.99"
       READ
      SELECT Part
       ApRLock( 3 )
      Part->Trade     := ntrade
      Part->Markup    := nmarkup
      Part->Wholesale := ( Part->Trade* ( 1+( Part->Markup/100) ) )
      Part->Margin    := Part->Markup
      UNLOCK
      nwholesale      := Part->Wholesale
      @ nl,50      SAY "Sell exl GST" GET nwholesale PICTURE "9999999.99"
       READ
       ApRlock()
      Part->Wholesale := nwholesale
      Part->Markup := ( ( Part->Wholesale-Part->Trade ) / Part->Trade ) *100
      UNLOCK
      SELECT Quot
      SET ORDER TO 3                 // Invno+Partnum
      SEEK Debit->Invno
      nqty      := Quot->Qty
      namount   := Quot->Amount
      ndiscount := Quot->Discount
      nl+=2
      @ nl, 3      SAY "Job Card "+Quot->Invno COLOR "BG+"
      @ nl,COL()+2 SAY "Qty"           GET nqty
      @ nl,COL()+1 SAY "JC Sell Price" GET namount
      @ nl,COL()+2 SAY "Disc"          GET ndiscount  
       READ
       ApRlock()
      Quot->Qty      := nqty
      Quot->Amount   := namount
      Quot->Discount := ndiscount
      UNLOCK
      COMMIT

   ENDIF                  // Empty

   mdetail := ApGetN( "Do You Want Details "+mmodcode )
   IF mdetail = "Y"
      EquDetail( mmodcode )
      JCPrice( mmodcode )
   ENDIF

   SELECT Quot
   SET ORDER TO 1

   RETURN NIL
   ****---- End of JCPrice()

   ****-------------------------------------------------------------------------

FUNCTION JCReqTot()                // Outstanding

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      mpartnum := SPACE( 20 )
      SCROLL()
      SELECT QuotStk
      SET ORDER TO 1    // Invno                          // 2  Partnum
      GOTO TOP
      aPart_:={}
      nrecno := 0
      DO WHILE QuotStk->( !EOF() )
         IF QuotStk->Received >= QuotStk->Required
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
         IF QuotStk->Codeno = Control->U_Codeno
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
         IF SUBSTR( QuotStk->Partnum, 1, 2 ) = "QU"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
         IF SUBSTR( QuotStk->Partnum, 1, 2 ) = "ZZ"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      *** /*
         IF SUBSTR( QuotStk->ModCode, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      *** */
         SELECT Part
         SET ORDER TO 1                        // Partnum
         SEEK QuotStk->Partnum
         mpartnum := QuotStk->Partnum
         SELECT Orders
         SET ORDER TO 1                        // Partnum index
         GOTO TOP
         SEEK mpartnum
         mptot := 0
         IF FOUND()
            DO WHILE Orders->Partnum = mpartnum .AND. Orders->( !EOF() )
               mptot += Orders->QtyRec-Orders->PartQty
               SKIP ALIAS Orders
            ENDDO
         ENDIF
         SELECT QuotStk
         AADD( aPart_,QuotStk->Invno;
                      +" "+STR( Part->Instock, 8, 2 );
                      +" "+STR( QuotStk->Required, 8, 2 );
                      +" "+STR( QuotStk->Received, 8, 2 );
                      +" "+STR( ( QuotStk->Required-QuotStk->Received ), 8, 2 );
                      +" "+STR( mptot, 8, 2 );
                      +" "+SUBSTR( QuotStk->Partnum, 1,16 );
                      +" "+QuotStk->Codeno;
                      +"               "+STR( RECNO(), 6 ) )
         SKIP ALIAS QuotStk
      ENDDO                        // QuotStk EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         DISPBOX( 1, 0, 24,79, 2 )
         @  1, 7 SAY "  Instock Required Received  Out/S  Ordered by Module "
         anum := ACHOICE(  2, 1, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
         GOTO nrecno
         mpartnum := QuotStk->Partnum
      ENDIF                        // Empty
      IF LASTKEY() = 27
         RETURN NIL
      ENDIF 
      SELECT Part
      SET ORDER TO 1                           // Partnum
      SEEK mpartnum
      SCROLL(  11, 2, 23,78 )
      DISPBOX( 11, 3, 19,77,2 )
      nl := 11
      @ nl,23    SAY " Required Less Allocated" COLOR "G+"
      @ nl,COL() SAY QuotStk->Required-QuotStk->Received PICTURE "99,999.999 " COLOR "G+"
      nl++
      @ nl, 6      SAY TRIM( Part->Partnum )
      @ nl,COL()+2 SAY TRIM( Part->Desc )
      nl++
      ninstock  := Part->Instock
      nreceived := QuotStk->Received
      @ nl, 6      SAY "Instock ="
      @ nl,COL()+1 GET ninstock    PICTURE "99999.999"
      @ nl,COL()+1 SAY "Required"
      @ nl,COL()+1 SAY QuotStk->Required PICTURE "99999.999"
      @ nl,COL()+1 SAY "Received"
      @ nl,COL()+1 GET nreceived PICTURE "99999.999"
       READ
      IF LASTKEY() = 27
         RETURN NIL
      ENDIF 
       ApRlock( 3 )
      Part->Instock := ninstock
      UNLOCK
      SELECT QuotStk
       ApRlock( 3 )
      QuotStk->Received := nreceived
      UNLOCK
      nl+=2
      @ nl,10 SAY "Module"
      @ nl,28 SAY "Outstand"
      @ nl,40 SAY "Allocated"
      nl+=2
      malloc := QuotStk->Required-QuotStk->Received
      @ nl,10 SAY QuotStk->Modcode
      @ nl,25 SAY QuotStk->Required-QuotStk->Received PICTURE "9,999.999"
      @ nl,37 GET malloc PICTURE "99999.999"
       READ
      IF LASTKEY() = 27
         RETURN NIL
      ENDIF 
      DO WHILE ( QuotStk->Required-QuotStk->Received < malloc ) .OR.;
               ( malloc > Part->Instock )
          IF malloc > Part->InStock
             @ nl,50 SAY "Not that many in Stock" COLOR "BG+"
             mcancell := ApGetY( "Try Again ?" )
             IF mcancell = "N"
                JCReqRec()                 // Above
             ENDIF
             @ nl,37 GET malloc PICTURE "99999.999"
              READ
             IF LASTKEY() = 27
                RETURN NIL
             ENDIF 
            ELSE
             @ nl,50 SAY "Too many Allocatted"
             INKEY()

              JCReqRec()                 // Above

          ENDIF                    // malloc
       ENDDO
       mcont := ApGetY( TRIM( Message->Correct )+" Allocated" )
       IF mcont = "Y"
          SELECT QuotStk
           ApRlock( 3 )
          QuotStk->Received += malloc
          UNLOCK
          SELECT Part
           ApRlock( 3 )
          Part->Instock -= malloc
          UNLOCK
          IF malloc > 0
               SELECT Labour       
                 ApFLock( 3 )
                APPEND BLANK
                Labour->Partnum := QuotStk->Partnum
                Labour->Invno   := QuotStk->Invno
                Labour->Time    := malloc 
                Labour->Rate    := Part->Trade
                Labour->Desc    := Part->Desc
                Labour->Date    := DATE()
                Labour->Codeno  := "  STOCK"
               UNLOCK
          ENDIF                // malloc
       ENDIF                   // mcontinue
       mcontinue := "Y"
   ENDDO                       // mcontinue

   RETURN NIL
   ****----- END JCReqTot()

   ****--------------------------------------------------------------------------

FUNCTION QuotCode()

   SELECT Status
   SET ORDER TO 2                // Invno+Partnum   
   GOTO TOP
   DO WHILE Status->( !EOF() )
       ApFLock( 3 )
      DELETE
      UNLOCK 
      SKIP ALIAS Status
   ENDDO                          // Status
   mjc:= mxyonly := "N"
   nrequired := 0
   npn := 1
   cpagehd := "Parts Total"
   SCROLL()
   *****   QuotStock()             // Updates File         // XF_Util
   mjc := ApGetY( "Select One JC- Only" )
   IF mjc = "Y"
      QuotFind()
      minvno := Debit->Invno
      SELECT Name
      SEEK Quot->Codeno
   ENDIF
   mxy := ApGetN( "Do you want XY Parts" )
   IF mxy = "Y"
      mxyonly := ApGetN( "ONLY XY Parts" )
   ENDIF
   IF mxy = "N"
      cpagehd := "PartsTotalnoXY"
   ENDIF    
   IF mxyonly = "Y"
      cpagehd := "PartsOnlyXY"
   ENDIF    
   SELECT QuotStk
   SET ORDER TO 2              // Partnum+Invno
   GOTO TOP
   mpartnum := QuotStk->Partnum          
   DO WHILE QuotStk->( !EOF() )
      IF mjc = "Y"
         IF QuotStk->Invno != minvno
           SKIP ALIAS QuotStk
           LOOP
         ENDIF
      ENDIF
   /*
      IF mxy = "N"                                   // Partnum  
         IF SUBSTR( QuotStk->Partnum, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF 
   */
      IF mxy = "N"                                    // ModCode
         IF SUBSTR( QuotStk->ModCode, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF
      IF mxyonly = "Y"                                    // ModCode
         IF SUBSTR( QuotStk->ModCode, 1, 2 ) != "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF 
      IF SUBSTR( QuotStk->Partnum, 1, 1 ) = "Z"
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      IF QuotStk->Required = 0
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      IF QuotStk->Received >= QuotStk->Required
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      IF QuotStk->Ordnum != "   "
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
   /*
      IF QuotStk->Codeno = Control->U_Codeno
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
   */
      ccodeno   := SPACE( 8 )
      nrequired := 0
      mpartnum := QuotStk->Partnum
      DO WHILE QuotStk->Partnum = mpartnum .AND. QuotStk->( !EOF() )
         nrequired += ( QuotStk->Required-QuotStk->Received )
         ccodeno   := QuotStk->Codeno
         SKIP ALIAS QuotStk
      ENDDO               // mpartnum
      SELECT Status
      SET ORDER TO 2                // Codeno   
      IF nrequired > 0
          ApFLock( 3 )
         APPEND BLANK
         Status->Partnum  := mpartnum
         Status->Required := nrequired
         IF SUBSTR( mpartnum, 1, 2 ) = "XY"
            Status->Codeno := "Z"+ccodeno
           ELSE
            Status->Codeno   := ccodeno
         ENDIF
         UNLOCK 
      ENDIF
      SELECT QuotStk
      mpartnum := QuotStk->Partnum
      SKIP ALIAS QuotStk
   ENDDO                               // QuotStk
      mwhere := "S" 

       Printsel()

      IF mwhere = "P"
        npl := 56
       ELSE
        npl := 22
      ENDIF
      @  0, 2 SAY Control->U_Name
      @  0,40 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
      @  0,60 SAY cpagehd
      @  0,77 SAY npn PICTURE "99"
      IF mjc = "Y"
         @  2, 2 SAY Name->Name+"        Outstanding Parts for JC- "+minvno
        ELSE 
         @  2,40 SAY "All Outstanding Parts All JC-"
      ENDIF
      @  4, 0 SAY "Supplier"
      @  4,10 SAY "Part"
      @  4,26 SAY "Desc"
      @  4,62 SAY "In Stock"
      @  4,71 SAY "Outst"
      nl := 5
   SELECT Status
   SET ORDER TO 2                  //  Codeno
   GOTO TOP
   DO WHILE Status->( !EOF() )
      IF nl > npl
         IF mwhere = "P" 
            EJECT
           ELSE
            WAIT
          SCROLL()
         ENDIF
         npn++
         @  0, 2 SAY Control->U_Name
         @  0,40 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         @  0,60 SAY cpagehd
         @  0,77 SAY npn PICTURE "99"
         IF mjc = "Y"
            @  2, 2 SAY Name->Name+"     Outstanding Parts for JC- "+minvno
           ELSE 
            @  2,40 SAY "All Outstanding Parts All JC-"
         ENDIF
      @  4, 0 SAY "Supplier"
      @  4,10 SAY "Part"
      @  4,26 SAY "Desc"
      @  4,62 SAY "In Stock"
      @  4,71 SAY "Outst"
         nl := 5
      ENDIF                           // npl
      SELECT Part
      SEEK Status->Partnum
      IF SUBSTR( Status->Codeno, 1, 1 ) = "Z"
         @ nl, 0 SAY SUBSTR( Status->Codeno, 2, 7 )
        ELSE 
         @ nl, 0 SAY Status->Codeno
      ENDIF
      @ nl, 9 SAY SUBSTR( Part->Partnum,1,16 )
      @ nl,26 SAY SUBSTR( Part->Desc, 1,34 )
      IF Part->Instock > 0
         @ nl,62 SAY Part->Instock    PICTURE "99999.99"
      ENDIF
      @ nl,70 SAY Status->Required PICTURE "99,9999.99"
      nl++
      SELECT Status
      SKIP ALIAS Status
   ENDDO                        // Status
   IF mwhere = "S"
      WAIT
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
     ELSE
      EndPrint()
   ENDIF
   SELECT QuotStk
   SET ORDER TO 1              // Invno
   SELECT Status
   SET ORDER TO 1              //

   RETURN NIL
   ****--------------------------- QuotCode()

   ***----------------------------------------------------------------------

FUNCTION QuotStat()

   ******      QuotStock()             // Updates File         // XF_Util

     SCROLL()
     DISPBOX(  8, 1, 18,79, 2 )
     @ 10, 6 SAY "All Parts Outstanding All Job Cards" COLOR "R+"
     nselect := 1
     @ 12, 6 PROMPT "Supplier + Part # List"
     @ 14, 6 PROMPT "Part #   + Invno  List"
     MENU TO nselect
   DO CASE
     CASE PressedEsc()
        RETURN NIL
     CASE nselect = 1                         
        SELECT QuotStk
        SET ORDER TO 3                        // Codeno+Partnum
     CASE nselect = 2                         
        SELECT QuotStk
        SET ORDER TO 2                        // Partnum+Invno
   ENDCASE 
   npn := 1
   nrequired := 0
   cpagehd := "Parts Total"
   mxy := ApGetN( "Do you want XY Parts" )
   IF mxy = "N"
      cpagehd := "Parts TotalnoXY"
   ENDIF    
   mwhere := "S" 

    Printsel()

   IF mwhere = "P"
     npl := 56
    ELSE
     npl := 22
   ENDIF
   @  0, 2 SAY Control->U_Name
   @  0,40 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
              +STR( YEAR(DATE() ),5 )
   @  0,60 SAY cpagehd
   @  0,76 SAY npn PICTURE "99"
   @  2,40 SAY "All Outstanding Parts All JC-"
   @  4, 0 SAY "Part #"
   @  4,17 SAY "Description"
   @  4,58 SAY "Required"
   @  4,71 SAY "Supl"
   nl := 5
   SELECT QuotStk
   GOTO TOP
   mpartnum := QuotStk->Partnum          
   DO WHILE QuotStk->( !EOF() )
   /*
      IF mxy = "N"                                   // Partnum  
         IF SUBSTR( QuotStk->Partnum, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF
   */ 
      IF mxy = "N"                                    // ModCode
         IF SUBSTR( QuotStk->ModCode, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF 
      IF QuotStk->Codeno = Control->U_Codeno
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      IF SUBSTR( QuotStk->Partnum, 1, 1 ) = "Z"
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      IF QuotStk->Required = 0
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      IF nl > npl
         IF mwhere = "P" 
            EJECT
           ELSE
            WAIT
          SCROLL()
         ENDIF
         npn++
         @  0, 2 SAY Control->U_Name
         @  0,40 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         @  0,60 SAY cpagehd
         @  0,76 SAY npn PICTURE "99"
         @  2,40 SAY "All Outstanding Parts All JC-"
         @  4, 0 SAY "Part #"
         @  4,17 SAY "Description"
         @  4,58 SAY "Required"
         @  4,71 SAY "Supl"
         nl := 5
      ENDIF
      ccodeno   := SPACE( 8 )
      nrequired := 0
      DO WHILE QuotStk->Partnum = mpartnum .AND. QuotStk->( !EOF() )
         nrequired += ( QuotStk->Required-QuotStk->Received )
         ccodeno   := QuotStk->Codeno
         SKIP ALIAS QuotStk
      ENDDO               // mpartnum
      SELECT Part
      SEEK mpartnum
      IF nrequired > 0
         @ nl, 0 SAY SUBSTR( Part->Partnum,1,16 )
         @ nl,17 SAY SUBSTR( Part->Desc, 1,40 )
         @ nl,58 SAY nrequired PICTURE "99,999.99"
         @ nl,71 SAY ccodeno
         nl++
      ENDIF
      IF mpartnum != QuotStk->Partnum
         mpartnum := QuotStk->Partnum
      ENDIF
      SELECT QuotStk
      SKIP ALIAS QuotStk
   ENDDO                               // QuotStk
   IF mwhere = "S"
      WAIT
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
     ELSE
      EndPrint()
   ENDIF
   SELECT QuotStk
   SET ORDER TO 1              // Invno

   RETURN NIL
   ****--------------------------- QuotStat()

   ***----------------------------------------------------------------------

FUNCTION JobXtAll()

   cpagehd := "SPmod"
   mxy:= mout := "Y"
   minvno := SPACE( 6 )
   SCROLL()
      *** QuotStock()             // Updates File         // XF_Util

   mjc := ApGetY( "Select One JC- Only" )
   minstock := "N"
   IF mjc = "Y"
      QuotFind()
      minvno := Debit->Invno
      SELECT Name
      SEEK Quot->Codeno
   ENDIF
   mout := ApGetY( "JC- Outstanding Parts Only" )
   IF mout = "Y"
      cpagehd := "SPmodOut"
   ENDIF    
   minstock := ApGetY( "JC- Parts In Stock ONLY" )
   IF minstock = "Y"
      cpagehd := "SPInstock"
   ENDIF    
   mxy := ApGetN( "Do you want XY Parts" )
   IF mxy = "Y"
      cpagehd := "SPmodXY"
   ENDIF    
   mmetal := ApGetN( "Do you want Metal Parts" )
   IF mxy = "Y"
      cpagehd := "SPmodXYMetal"
   ENDIF    

   mwhere := "S" 

    Printsel()

   IF mwhere = "P"
     npl := 56
    ELSE
     npl := 22
   ENDIF
   npn := 1
   @  0, 2 SAY Control->U_Name
   @  0,40 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
              +STR( YEAR(DATE() ),5 )
   @  0,62 SAY cpagehd
   @  0,77 SAY npn PICTURE "99"
   IF mjc = "Y"
      @  2, 0 SAY Name->Name
      @  2,40 SAY "Parts Required JC- "+minvno
     ELSE
      @  2,30 SAY "PARTS Required Job Cards - Module"
   ENDIF
   @  4, 0 SAY "Part #"
   @  4,17 SAY "Description"
      *** @  4,63 SAY "Required"
   nl := 5
   nreq:= malloc := 0
   SELECT QuotStk
   SET ORDER TO 1
   GOTO TOP
   cmodcode := QuotStk->ModCode          // Gives Qty of Module
   DO WHILE QuotStk->( !EOF() )
      IF mjc = "Y"
         IF QuotStk->Invno != minvno
            SKIP ALIAS QuotStk
            LOOP
          ENDIF
      ENDIF
      IF mout = "Y" 
         IF QuotStk->Required <= QuotStk->Received
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF
   /*
      IF mxy = "N"
         IF SUBSTR( QuotStk->Partnum, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF
   */ 
      IF mxy = "N"                                    // ModCode
         IF SUBSTR( QuotStk->ModCode, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF 
      IF SUBSTR( QuotStk->Partnum, 1, 2 ) = "ZZ"
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      IF QuotStk->Required = 0
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      IF nl > npl
         IF mwhere = "P" 
            EJECT
           ELSE
            WAIT
          SCROLL()
         ENDIF
         npn++
         @  0, 2 SAY Control->U_Name
         @  0,40 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         @  0,62 SAY cpagehd
         @  0,77 SAY npn PICTURE "99"
         IF mjc = "Y"
            @  2, 0 SAY Name->Name
            @  2,40 SAY "Parts Required JC- "+minvno
           ELSE
            @  2,30 SAY "PARTS Required Job Cards - Module"
         ENDIF
         @  4, 0 SAY "Part #"
         @  4,17 SAY "Description"
      ***      @  4,63 SAY "Required"
         nl := 5
      ENDIF
      SELECT Part
      SEEK QuotStk->Partnum
      IF mmetal = "N"                    // Metal Parts
         IF Part->Codeno = Control->U_Codeno
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF 
      SELECT QuotStk
      DO CASE
         CASE minstock = "Y"
            IF Part->Instock > 0 .AND. Part->Instock >= ( QuotStk->Required-QuotStk->Received )
               IF cmodcode != QuotStk->Modcode
                  @ nl, 4 SAY QuotStk->Invno+" "+QuotStk->Modcode+" Qty "+STR( QuotStk->EquQty, 8, 2 ) 
                  nl++
                  cmodcode := QuotStk->ModCode
               ENDIF
               @ nl, 0 SAY SUBSTR( QuotStk->Partnum,1,16 )
               @ nl,17 SAY SUBSTR( Part->Desc, 1,35 )
               @ nl,53 SAY Part->Instock     PICTURE "9999.99"
               @ nl,62 SAY QuotStk->Required PICTURE "9999.99"
               @ nl,70 SAY QuotStk->EquLevel
               @ nl,72 SAY SUBSTR( QuotStk->ModCode, 1, 5 )
               nl++
            ENDIF             // Part Instock
         OTHERWISE
      IF cmodcode != QuotStk->Modcode
         @ nl, 4 SAY QuotStk->Invno+" "+QuotStk->Modcode+" Qty "+STR( QuotStk->EquQty, 8, 2 ) 
         nl++
         cmodcode := QuotStk->ModCode
      ENDIF
      @ nl, 0 SAY SUBSTR( QuotStk->Partnum,1,16 )
      @ nl,17 SAY SUBSTR( Part->Desc, 1,35 )
      @ nl,53 SAY QuotStk->Required PICTURE "9999.99"
      IF Part->Codeno = Control->U_Codeno 
         @ nl,61 SAY "*"
      ENDIF
      IF QuotStk->Received > 0
         @ nl,62 SAY QuotStk->Received PICTURE "9999.99"
         @ nl,70 SAY SUBSTR( QuotStk->Ordnum, 1, 4 )+SUBSTR( Part->Codeno, 1, 6 ) 
        ELSE
         @ nl,62 SAY "_______"
         @ nl,71 SAY Part->Codeno   
      ENDIF
      nl++
      ENDCASE
      SELECT QuotStk
      SKIP ALIAS QuotStk
   ENDDO                               // QuotStk
   nl++
   IF mwhere = "S"
      WAIT
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
     ELSE
      EndPrint()
   ENDIF
   SELECT QuotStk
   SET ORDER TO 1              // Invno

   RETURN NIL
   ****------  END JobXyAll()

   *****---------------------------------------------------------------------

FUNCTION JobQStk()

   SCROLL()

   minvno   := Debit->Invno
   cucodeno := "Y"             // U_Codeno Parts
   mxyonly  := "N"      // ONLY XY       TAKEN OUT FOR NOW
   cpagehd  := "SPmod"
   SELECT Name
   SEEK Debit->Codeno
   @  8,50      SAY "Today "+STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                            +STR( YEAR(DATE() ),5 )
   @ 10,10      SAY Name->Name+" "+minvno+" Start Date"
   @ 10,COL()+2 SAY Debit->StartDate COLOR "R+"
   @ 12,10      SAY "IF Start Date is Greater than Todays Date-1 there will be NO parts"
   SELECT QuotStk
   SET ORDER TO 1   // Invno
   SEEK Debit->Invno
   IF !FOUND()
      @ 14,10 SAY "--- FILE MUST BE UPDATED IMPORTANT ---" COLOR "RG+"
      WAIT
      RETURN NIL
    ELSE
      @ 14,10 SAY Debit->Invno+" Job Card in Orders File" COLOR "RG+"
   ENDIF
   mxy     := ApGetY( "Do You Want XY Parts" )
   IF mxy = "Y"
      ***   @ 12, 5 SAY "You can select XY parts for Assembly" COLOR "R+" 
      ***   mxyonly  := ApGetN( "ONLY XY Parts" )
      cpagehd := "SPmodXY"
   ENDIF
   IF mxyonly = "Y"
      cpagehd  := "SPmodXYonly"
      ***   cucodeno := ApGetY( "Do You Want "+Control->U_Codeno+" Parts" )
      ***   IF cucodeno = "Y"
      ***      cpagehd := "STXYmodMet"
      ***   ENDIF
   ENDIF

      *** QuotStock()                      // XF_Util

   npn := 1
   mwhere := "S" 

    Printsel()

   IF mwhere = "P"
     npl := 56
    ELSE
     npl := 22
   ENDIF
   @  0, 2 SAY Control->U_Name
   @  0,40 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
              +STR( YEAR(DATE() ),5 )
   @  0,65 SAY cpagehd
   @  0,76 SAY npn PICTURE "99"
   @  2, 2 SAY Name->Name
   @  2,35 SAY Debit->StartDate
   @  2,48 SAY "PARTS Order Module JC- "+minvno
   @  4, 1 SAY "Part #"
   @  4,18 SAY "Description"
   @  4,45 SAY "Stock"
   @  4,54 SAY "Required"
   @  4,71 SAY "Order #"
   nl := 5
   nreq:= malloc := 0
   SELECT QuotStk
   SET ORDER TO 1              // Invno
   GOTO TOP
   cmodcode:= cmod := QuotStk->ModCode
   SEEK minvno
   DO WHILE QuotStk->Invno = minvno .AND. QuotStk->( !EOF() )
      IF SUBSTR( QuotStk->Partnum, 1, 2 ) = "ZZ"
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      IF QuotStk->Required = 0
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      IF nl > npl
         IF mwhere = "P" 
            EJECT
           ELSE
            WAIT
          SCROLL()
         ENDIF
         @  0, 2 SAY Control->U_Name
         @  0,40 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         @  0,65 SAY cpagehd
         @  0,76 SAY npn PICTURE "99"
         @  2, 2 SAY Name->Name
         @  2,35 SAY Debit->StartDate
         @  2,48 SAY "PARTS Order Module JC- "+minvno
         @  4, 1 SAY "Part #"
         @  4,18 SAY "Description"
         @  4,45 SAY "Stock"
         @  4,54 SAY "Required"
         @  4,71 SAY "Order #"
         nl := 5
      ENDIF
      SELECT Part
      SEEK QuotStk->Partnum
      SELECT QuotStk
   /*
      IF mxy = "N"
         IF SUBSTR( QuotStk->Partnum, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF                            // mxy
   */
      IF mxy = "N"
         IF SUBSTR( QuotStk->ModCode, 1, 2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF                            // mxy
      IF mxyonly = "Y"
         IF SUBSTR( QuotStk->Partnum, 1, 2 ) != "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF                           // mxyonly
      IF cucodeno = "N"
         IF Part->Codeno = Control->U_Codeno
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
      ENDIF
   /*
      IF QuotStk->Modcode = cmod
         @ nl, 6 SAY QuotStk->Modcode+" Qty "+STR( QuotStk->EquQty, 8, 2 ) 
         nl++
         cmod := "999999999999999"
      ENDIF
   */
      IF cmodcode != QuotStk->Modcode
         @ nl, 6 SAY QuotStk->Modcode+" Qty "+STR( QuotStk->EquQty, 8, 2 ) 
         nl++
         cmodcode := QuotStk->ModCode
      ENDIF
      @ nl, 0 SAY SUBSTR( QuotStk->Partnum, 1,16 )
      IF QuotStk->Received >= QuotStk->Required     
         @ nl,17 SAY SUBSTR( Part->Desc, 1,36 )
        ELSE
         IF Part->Instock > 0
            @ nl,17 SAY SUBSTR( Part->Desc, 1,28 )
            @ nl,46 SAY Part->Instock  PICTURE "9999.99"
           ELSE
            @ nl,17 SAY SUBSTR( Part->Desc, 1,36 )
         ENDIF
      ENDIF
      @ nl,54 SAY QuotStk->Required PICTURE "9999.99"
      IF Part->Codeno = Control->U_Codeno 
         @ nl,62 SAY "*"
      ENDIF
      IF QuotStk->Received > 0
         @ nl,63 SAY QuotStk->Received PICTURE "9999.99"
         @ nl,71 SAY QuotStk->Ordnum
        ELSE
         @ nl,63 SAY "_______"
         @ nl,72 SAY Part->Codeno   
      ENDIF
      nl++
      SELECT QuotStk
      SKIP ALIAS QuotStk
   ENDDO                               // QuotStk
   nl++
   IF mwhere = "S"
      WAIT
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
     ELSE
      EndPrint()
   ENDIF

   RETURN NIL
   ****------  END JobQStk()

   *********----------  END OF FILE XLF_QU8.PRG

