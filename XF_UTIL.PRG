   ***  JoKir10  16-10-11 18:44:06 

/* 
   Program ......:                  XF_UTIL.PRG
   Authors.......: John Kirby
   Date..........: 24/09/1997
   Functions.....: UpDateJC, DebLook, QCutOrder, QuickDel
                   ContDbf, Breakpoint, BreakTot, Breakprint
                   InitFiles
   Not used......: LabClean, Supldisp
*/

FUNCTION UpDateJC()

   SCROLL()
   DISPBOX(  0, 0, 24,79, 2 )
   @  1,41-( LEN( TRIM( Control->U_Name ) )/2 );
   SAY  TRIM( Control->U_Name ) COLOR "GB+"
   @  1,58 SAY DATE() COLOR "R+"
   @  4, 5 SAY "Updating Job Parts File"
   SELECT Quot
   COUNT TO nquotno
   @  6,10      SAY "Updating Jobs"
   @  6,COL()+1 SAY nquotno          PICTURE "99,999"
   @  6,COL()+3 SAY "Control File"
   @  6,COL()+2 SAY Control->Lastflt PICTURE "99,999" 

   Lastused( nl )                                  // _Init.PRG
   mtitle2 := Note->Noteno+"  "+Note->General;
      +"  "+TRIM( Control->O_Name );
      +" Ph "+TRIM( Control->O_Phone)+"  "
   @ 24,43-(LEN(mtitle2)/2) SAY mtitle2 COLOR "GB+"

   SELECT QuotStk
   SET ORDER TO 1                 // Invno+ModPart   
   SELECT Quot
   COUNT TO nlastflt
   SELECT Control
    ApFLock( 3 )
   Control->LastFlt := nlastflt
   UNLOCK  
   SELECT Quot
   SET ORDER TO 3                // Invno+Partnum   
   GOTO TOP
   DO WHILE Quot->( !EOF() )
      IF Quot->Partnum = Message->LabPart    // MetalCraft = ZZFABRIC
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF Quot->Qty <= 0
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF SUBSTR( Quot->Partnum, 1, 1 ) = "Z"
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF SUBSTR( Quot->Invno, 1, 1 ) = " "
         SKIP ALIAS Quot
         LOOP
      ENDIF
      SELECT Debit
      SET ORDER TO 2       /// Invno
      SEEK Quot->Invno
      IF Debit->StartDate > DATE()-2
         SELECT Quot  
         SKIP ALIAS Quot
         LOOP
      ENDIF
      nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
      nqty1:= nqty2:= nqty3:= nqty4 := 0
      nequ1:= nequ2:= nequ3:= nequ4 := 0
      nquot := Quot->Qty
      mmod1 := TRIM( Quot->Partnum )
      SELECT Equ
      GOTO TOP
      SEEK mmod1
      IF FOUND()
         DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
            nrecno1 := RECNO()
            IF SUBSTR( Equ->Partnum, 1, 2 ) = "ZZ"
               SKIP ALIAS Equ
               LOOP
            ENDIF
            IF Equ->Partnum = Message->LabPart          // Met = ZZFABRIC
               SKIP ALIAS Equ
               LOOP
            ENDIF
            IF SUBSTR( Equ->Partnum, 1, 1 ) = "Z"
               SKIP ALIAS Equ
               LOOP
            ENDIF
            IF Equ->Partnum = "         "
               SKIP ALIAS Equ
               LOOP
            ENDIF
            nqty1 := Equ->PartQty
            nequ1 := nqty1* nquot
            SELECT QuotStk
            SET ORDER TO 1                     // Invno+Modcode+Partnum   
            GOTO TOP
            cmodpart := Equ->Modcode+Equ->Partnum
            SEEK Quot->Invno+cmodpart
            IF FOUND()
               @ 12, 4 SAY Equ->Modcode+" "+Equ->Partnum+" "+Quot->Invno
            ENDIF 
            ApFLock( 3 )
            IF !FOUND()
               APPEND BLANK
               QuotStk->Invno    := Quot->Invno
               QuotStk->Modcode  := Equ->Modcode
               QuotStk->Partnum  := Equ->Partnum
               QuotStk->ModPart  := cmodpart
               QuotStk->Equlevel := "1"
            ENDIF
            QuotStk->Qty      := nequ1
            QuotStk->Required := nequ1    // QuotStk->Qty
            QuotStk->EquQty   := nquot
            UNLOCK
            SELECT Equ
            mmod2   := TRIM( Equ->Partnum )
            nrecno2 := RECNO()
            GOTO TOP
            SEEK mmod2
            IF FOUND()
               DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
                  nrecno2 := RECNO()
                  IF SUBSTR( Equ->Partnum, 1, 2 ) = "ZZ"
                     SKIP ALIAS Equ
                     LOOP
                  ENDIF
                  IF Equ->Partnum = Message->LabPart          // Met = ZZFABRIC
                     SKIP ALIAS Equ
                     LOOP
                  ENDIF
                  IF SUBSTR( Equ->Partnum, 1, 1 ) = "Z"
                     SKIP ALIAS Equ
                     LOOP
                  ENDIF
                  IF Equ->Partnum = "         "
                     SKIP ALIAS Equ
                     LOOP
                  ENDIF
                  nqty2 := Equ->PartQty
                  nequ2 := ( nqty1 * nqty2 )* nquot
                  SELECT QuotStk
                  SET ORDER TO 1               // Invno   
                  GOTO TOP
                  cmodpart := Equ->Modcode+Equ->Partnum
                  SEEK Quot->Invno+cmodpart
                  IF FOUND()
                     @ 14, 4 SAY Equ->Modcode+" "+Equ->Partnum+" "+Quot->Invno
                  ENDIF 
                  ApFLock( 3 )
                  IF !FOUND()
                     APPEND BLANK
                     QuotStk->Invno    := Quot->Invno
                     QuotStk->Modcode  := Equ->Modcode
                     QuotStk->Partnum  := Equ->Partnum
                     QuotStk->ModPart  := cmodpart
                     QuotStk->Equlevel := "2"
                  ENDIF
                  QuotStk->Qty      := nequ2
                  QuotStk->Required := nequ2    // QuotStk->Qty
                  QuotStk->EquQty   := nequ1
                  UNLOCK
                  ****    /*
                  SELECT Equ
                  mmod3   := TRIM( Equ->Partnum )
                  GOTO TOP
                  SEEK mmod3
                  IF FOUND()
                     DO WHILE  Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
                        nrecno3 := RECNO()
                        IF SUBSTR( Equ->Partnum, 1, 2 ) = "ZZ"
                           SKIP ALIAS Equ
                           LOOP
                        ENDIF
                        IF Equ->Partnum = Message->LabPart          // Met = ZZFABRIC
                           SKIP ALIAS Equ
                           LOOP
                        ENDIF
                        IF SUBSTR( Equ->Partnum, 1, 1 ) = "Z"
                           SKIP ALIAS Equ
                           LOOP
                        ENDIF
                        IF Equ->Partnum = "         "
                           SKIP ALIAS Equ
                           LOOP
                        ENDIF
                        nqty3 := Equ->PartQty
                        nequ3 := nqty1 * nqty2 * nqty3 * nquot
                        SELECT QuotStk
                        GOTO TOP
                        cmodpart := Equ->Modcode+Equ->Partnum
                        SEEK Quot->Invno+cmodpart
                        IF FOUND()
                           @ 14, 4 SAY Equ->Modcode+" "+Equ->Partnum+" "+Quot->Invno
                        ENDIF 
                         ApFLock( 3 )
                        IF !FOUND()
                           APPEND BLANK
                           QuotStk->Invno    := Quot->Invno
                           QuotStk->Modcode  := Equ->Modcode
                           QuotStk->Partnum  := Equ->Partnum
                           QuotStk->ModPart  := cmodpart
                           QuotStk->Equlevel := "3"
                        ENDIF
                        QuotStk->Qty      := nequ3
                        QuotStk->Required := nequ3             // QuotStk->Qty
                        QuotStk->EquQty   := nequ2             // must be 2
                        UNLOCK
                        SELECT Equ
                        mmod4   := TRIM( Equ->Partnum )
                        nqty4   := 0
                        GOTO TOP
                        SEEK mmod4
                        IF FOUND()
                           DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                              nrecno4 := RECNO()
                              IF SUBSTR( Equ->Partnum, 1, 2 ) = "ZZ"
                                 SKIP ALIAS Equ
                                 LOOP
                              ENDIF
                              IF Equ->Partnum = Message->LabPart          // Met = ZZFABRIC
                                 SKIP ALIAS Equ
                                 LOOP
                              ENDIF
                              IF SUBSTR( Equ->Partnum, 1, 1 ) = "Z"
                                 SKIP ALIAS Equ
                                 LOOP
                              ENDIF
                              IF Equ->Partnum = "         "
                                 SKIP ALIAS Equ
                                 LOOP
                              ENDIF
                              nqty4 := Equ->PartQty
                              nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
                              SELECT QuotStk
                              GOTO TOP
                              cmodpart := Equ->Modcode+Equ->Partnum
                              SEEK Quot->Invno+cmodpart
                              IF FOUND()
                                 @ 15, 4 SAY Equ->Modcode+" "+Equ->Partnum+" "+Quot->Invno
                              ENDIF 
                               ApFLock( 3 )
                              IF !FOUND()
                                 APPEND BLANK
                                 QuotStk->Invno    := Quot->Invno
                                 QuotStk->Modcode  := Equ->Modcode
                                 QuotStk->Partnum  := Equ->Partnum
                                 QuotStk->ModPart  := cmodpart
                                 QuotStk->Equlevel := "4"
                              ENDIF
                              QuotStk->Qty      := nequ4
                              QuotStk->Required := nequ4              // QuotStk->Qty
                              QuotStk->EquQty   := nequ3             // must be 3
                              UNLOCK
                              SELECT Equ 
                              SKIP ALIAS Equ
                           ENDDO                     //  mmod4
                        ENDIF                        // Found  mmod4 
                        SELECT Equ 
                        GOTO nrecno3
                        SKIP ALIAS Equ
                     ENDDO                       //  mmod3
                  ENDIF                          // FOUND()  mmod3    
                  ****    */
                  SELECT Equ 
                  GOTO nrecno2 
                  SKIP ALIAS Equ
               ENDDO                       // mmod2
            ENDIF                          // FOUND()  mmod2    
            SELECT Equ
            GOTO nrecno1   
            SKIP ALIAS Equ
         ENDDO                       // mmod1
      ENDIF                          // FOUND()  mmod1    
      SET EXACT OFF
      SELECT Quot
      SKIP ALIAS Quot
   ENDDO                                // EOF Quot
   *************       Changing Part File
   SELECT QuotStk
    ApFlock( 3 )
   REPLACE ALL QuotStk->EquLevel WITH SUBSTR( QuotStk->EquLevel, 1, 1 );
                 +"x" FOR SUBSTR( QuotStk->ModCode, 1, 2 ) = "XY"  
   UNLOCK
   SELECT Labour
   SET ORDER TO 2                    // Invno+Partnum+Fault  // ModCode
   SELECT Quot
   SET ORDER TO 3                    // Invno+Partnum
   SELECT Part
   SET ORDER TO 1                    // Partnum   
   SELECT QuotStk
   SET ORDER TO 1                    // Invno+ModPart   
   GOTO TOP
   DO WHILE QuotStk->( !EOF() )
      SELECT Quot
      SEEK QuotStk->Invno
      IF !FOUND()
         SELECT Quotstk
          ApFLock( 3 )
         DELETE
         UNLOCK
      ENDIF                            // Found Invno 
      SELECT Part
      SEEK QuotStk->Partnum
      SELECT QuotStk
       ApFLock( 3 )
      QuotStk->Codeno := Part->Codeno
      UNLOCK
      SELECT Debit
      SET ORDER TO 2       /// Invno
      SEEK QuotStk->Invno
      IF Debit->StartDate > DATE()-1
         SELECT QuotStk
          ApFLock( 3 )
         DELETE
         UNLOCK
      ENDIF
      SELECT Debit
      SET ORDER TO 2       /// Invno
      SEEK QuotStk->Invno
      ddate = Control->SetDate             //
      IF Debit->DBDate < ddate
         SELECT QuotStk
          ApFLock( 3 )
         DELETE
         UNLOCK
      ENDIF
      SELECT Labour
      GOTO TOP
      SET ORDER TO 2        // Invno+Partnum
      mseek := QuotStk->Invno+QuotStk->Partnum
      SEEK mseek
      IF FOUND()          
         IF Labour->Fault = SPACE( 16 )
             ApRlock( 3 )
            Labour->Fault := QuotStk->Modcode
            UNLOCK
         ENDIF
       ELSE
         SELECT QuotStk 
         SKIP ALIAS QuotStk
         LOOP
      ENDIF
      SELECT QuotStk
      IF QuotStk->Received < QuotStk->Required
          ApRlock( 3 )
         IF QuotStk->Received+Labour->Time >= QuotStk->Required
            QuotStk->Received := QuotStk->Required
            QuotStk->Ordnum   := SUBSTR( Labour->Codeno, 1, 4 )
            @ 18,10      SAY Labour->Time  PICTURE "99,999.99" COLOR "G+"
            @ 18,COL()+2 SAY Labour->Invno COLOR "G+"
            @ 18,COL()+1 SAY Labour->Codeno+" Order #"
           ELSE
            QuotStk->Received += Labour->Time
            QuotStk->Ordnum := SUBSTR( Labour->Codeno, 1, 4 )
            @ 18,10      SAY Labour->Time  PICTURE "99,999.99" COLOR "G+"
            @ 18,COL()+2 SAY Labour->Invno COLOR "G+"
            @ 18,COL()+1 SAY Labour->Codeno+" Order #"
         ENDIF
         UNLOCK
      ENDIF                 // Received < Required
      SKIP ALIAS Quotstk
   ENDDO                               // EOF Quotstk
   SELECT Quot
   SET ORDER TO 1
   SELECT Labour
   SET ORDER TO 1
   ***   SET EXACT OFF
   RETURN NIL

   ****--------------------------- UpDateJC()

   ***----------------------------------------------------------------------

FUNCTION DebLook( mcodeno )

   SELECT Debit
   SET ORDER TO 1                      // Codeno
   GOTO TOP
   IF LASTREC() != 0
      aPart_ := {}
      nrecno := 0
      namnt := 0
      SEEK mcodeno
      DO WHILE Debit->Codeno = mcodeno .AND. Debit->( !EOF() )
         IF cbranchId != SPACE( 2 )
            IF Debit->BranchId != cbranchId
               SKIP ALIAS Debit
               LOOP
            ENDIF
         ENDIF
         namnt += Debit->Amount
         IF Debit->Est != SPACE( 25 )
            cdisp := Debit->Est
           ELSE
            cdisp := STR( namnt )
         ENDIF
         AADD( aPart_,Debit->Invno+" "+DTOC( Debit->Dbdate );
              +" "+Debit->BranchId;
              +" "+STR( Debit->Amount,10, 2 )+" "+Debit->Saleno;
              +" "+Debit->Stat+" "+Debit->Equip;
              +" "+STR ( Debit->InitAmnt,10, 2 );
              +" "+cdisp+"                  "+STR( RECNO(), 6 ) )
         SKIP ALIAS Debit
      ENDDO
      SCROLL(  1,50, 1,73 )
      @ 1,50      SAY cbranchId
      @ 1,COL()+1 SAY "Total Debt"
      @ 1,COL()+1 SAY namnt PICTURE "$9999,999.99" 
      IF !EMPTY( aPart_ )
         SCROLL(   3, 0, 24,80 )
         DISPBOX(  3, 1, 24,79, 2 )
         @ 3,20 SAY "    Outstanding         Initial Amnt    "
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum   := ACHOICE(  4, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
         nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
      ENDIF
      GOTO nrecno
      minvno := Debit->Invno
   ENDIF

   RETURN minvno

   ***------- End of DebLook()

   **-------------------------------------------------------------------

FUNCTION QCutOrder()

   SELECT QuotCut
   GOTO TOP
   DO WHILE QuotCut->( !EOF() )
       ApFLock( 3 )
      DELETE
      UNLOCK 
      SKIP ALIAS QuotCut
   ENDDO                          // QuotCut
   mok := "N"
   mselect:= cbuyonly := "N"
   mequ := "Y"
   cbuyonly := "Y"
   mstock:= moper:= mABC := "N"
   mxy     := "Y"
   mlevel  := 4
   nQty:= nlength := 0
   ***   SET EXACT ON
   SELECT Quot
   SET ORDER TO 3                     // Invno
   GOTO TOP
   DO WHILE Quot->( !EOF() )
      nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
      nqty1:= nqty2:= nqty3:= nqty4 := 0
      nequ1:= nequ2:= nequ3:= nequ4 := 0
      nequqty1:= nequqty2:= nequqty3:= nequqty4 := 0
      nquot := Quot->Qty
      SELECT Equ
      mmod1 := TRIM( Quot->Partnum )
      SEEK mmod1
      mpartnum := Quot->Partnum
      SELECT EquCut
      SEEK Quot->ModSeqno
      DO WHILE EquCut->ModSeqno = Quot->Modseqno .AND. EquCut->( !EOF() )
         SELECT QuotCut
         ***         mfind := Quot->Invno+EquCut->ModSeqno
         SEEK EquCut->ModSeqno
         ***         IF !FOUND()                   // Level 1 
         ApRLock( 3 )
         APPEND BLANK
         QuotCut->Find     := Quot->Invno+Equ->ModSeqno 
         QuotCut->Invno    := Quot->Invno
         QuotCut->Modseqno := EquCut->ModSeqno
         QuotCut->Partnum  := Quot->Partnum
         QuotCut->Length   := EquCut->Length
         QuotCut->Width    := EquCut->Width
         QuotCut->Qty      := Quot->Qty*EquCut->Qty
         QuotCut->ModRef   := EquCut->ModRef
         QuotCut->Date     := EquCut->Date
         UNLOCK
         ***         ENDIF
         SELECT EquCut         
         SKIP ALIAS EquCut
      ENDDO
      IF mlevel >= 1
         SELECT Equ
         GOTO TOP
         ***      SET EXACT ON
         mmod1 := TRIM( Quot->Partnum )
         SEEK mmod1
         IF FOUND()   
            DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
               IF mxy = "N"
                  IF SUBSTR( Equ->Partnum, 1, 2 ) = "XY"
                     SKIP ALIAS Equ
                     LOOP
                  ENDIF
               ENDIF
               IF SUBSTR( Equ->Partnum, 1, 2 ) = "ZZ"
                  SKIP ALIAS Equ
                  LOOP
               ENDIF 
               SELECT Part
               SEEK Equ->Partnum
               nqty1:= nequqty1 := Equ->PartQty
               nequ1 := nqty1* nquot
               mpartnum := Equ->Partnum
               mseek := Equ->ModSeqno+mpartnum
               SELECT EquCut
               GOTO TOP
               SEEK mseek
               nCutSum:= nTotQty := 0
               DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                  DO CASE
                     CASE Part->Unit = "Mtr       "
                         nTotQty := Quot->Qty*EquCut->Qty
                         nCut := INT( Part->Length/EquCut->Length )
                         nCutTot := nTotQty/nCut
                         IF nCutTot > INT( nCutTot )
                            nCutTot := nCutTot
                          ELSE
                            nCutTot := nCutTot
                         ENDIF
                         nCutSum += nCutTot
                     CASE Part->Unit = "Sq Mtr    "
                         ntotqty := Quot->Qty*EquCut->Qty
                  ENDCASE
                  SELECT QuotCut
                  ***         mfind := Quot->Invno+EquCut->ModSeqno
                  SEEK EquCut->ModSeqno
                  ***         IF !FOUND()              // level 2
                  ApRLock( 3 )
                  APPEND BLANK
                  QuotCut->Find     := Quot->Invno+Equ->ModSeqno 
                  QuotCut->Invno    := Quot->Invno
                  QuotCut->Modseqno := EquCut->ModSeqno
                  QuotCut->Partnum  := Quot->Partnum
                  QuotCut->Length   := EquCut->Length
                  QuotCut->Width    := EquCut->Width
                  QuotCut->Qty      := nTotQty
                  QuotCut->ModRef   := EquCut->ModRef
                  QuotCut->Date     := EquCut->Date
                  UNLOCK
                  ***         ENDIF
                  SELECT EquCut         
                  SKIP ALIAS EquCut
               ENDDO
               SELECT Equ
               mmod2 := TRIM( Equ->Partnum )
               nrecno2 := RECNO() 
                  IF mequ = "Y"
                     GOTO TOP
                     SEEK mmod2
                     IF FOUND()   
                        IF mlevel >= 2
                        DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
                           IF mxy = "N"
                              IF SUBSTR( Equ->Partnum, 1, 2 ) = "XY"
                                 SKIP ALIAS Equ
                                 LOOP
                              ENDIF
                           ENDIF
                           IF SUBSTR( Equ->Partnum, 1, 2 ) = "ZZ"
                              SKIP ALIAS Equ
                              LOOP
                           ENDIF 
                           nqty2 := Equ->PartQty
                           nequqty2 := nequqty1*Equ->PartQty
                           nequ2 := ( nqty1 * nqty2 )* nquot
                           mpartnum := Equ->Partnum
                           mseek := Equ->ModSeqno+mpartnum
                           SELECT EquCut
                           GOTO TOP
                           SEEK mseek
                           nCutSum:= nTotQty := 0
                           DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                              DO CASE
                                 CASE Part->Unit = "Mtr       "
                                     nTotQty := Quot->Qty*EquCut->Qty
                                     nCut := INT( Part->Length/EquCut->Length )
                                     nCutTot := nTotQty/nCut
                                     IF nCutTot > INT( nCutTot )
                                        nCutTot := nCutTot
                                      ELSE
                                        nCutTot := nCutTot
                                     ENDIF
                                 CASE Part->Unit = "Sq Mtr    "
                                     nTotQty := Quot->Qty*EquCut->Qty
                              ENDCASE
                              SELECT QuotCut
                              ***         mfind := Quot->Invno+EquCut->ModSeqno
                              SEEK EquCut->ModSeqNo
                              ***         IF !FOUND()               // Level 3
                                 ApRLock( 3 )
                                 APPEND BLANK
                                 QuotCut->Find     := Quot->Invno+Equ->ModSeqno 
                                 QuotCut->Invno    := Quot->Invno
                                 QuotCut->Modseqno := EquCut->ModSeqno
                                 QuotCut->Partnum  := Quot->Partnum
                                 QuotCut->Length   := EquCut->Length
                                 QuotCut->Width    := EquCut->Width
                                 QuotCut->Qty      := ntotqty
                                 QuotCut->ModRef   := EquCut->ModRef
                                 QuotCut->Date     := EquCut->Date
                                 UNLOCK
                              ***        ENDIF         
                              SELECT EquCut
                              SKIP ALIAS EquCut
                           ENDDO
                           IF mlevel >= 3
                              SELECT Equ
                              mmod3 := TRIM( Equ->Partnum )
                              nrecno3 := RECNO() 
                              ***      nequPartQty := Equ->PartQty
                              GOTO TOP
                              SEEK mmod3
                              IF FOUND()   
                                 DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
                                    IF mxy = "N"
                                       IF SUBSTR( Equ->Partnum, 1, 2 ) = "XY"
                                          SKIP ALIAS Equ
                                          LOOP
                                       ENDIF
                                    ENDIF
                                    IF SUBSTR( Equ->Partnum, 1, 2 ) = "ZZ"
                                       SKIP ALIAS Equ
                                       LOOP
                                    ENDIF 
                                    nqty3 := Equ->PartQty
                                    nequqty3 := nequqty2*Equ->PartQty 
                                    nequ3 := nqty1 * nqty2 * nqty3 * nquot
                                    SELECT Part
                                    SEEK Equ->Partnum
                                    mpartnum := Equ->Partnum
                                    mseek := Equ->ModSeqno+mpartnum
                                    SELECT EquCut
                                    GOTO TOP
                                    SEEK mseek
                                    nCutSum:= nTotQty := 0
                                    DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                                       DO CASE
                                          CASE Part->Unit = "Mtr       "
                                              nTotQty := Quot->Qty*EquCut->Qty
                                              nCut := INT( Part->Length/EquCut->Length )
                                              nCutTot := nTotQty/nCut
                                          CASE Part->Unit = "Sq Mtr    "
                                              nTotQty := Quot->Qty*EquCut->Qty
                                       ENDCASE
                                       SELECT QuotCut
                                       ***         mfind := Quot->Invno+EquCut->ModSeqno
                                       SEEK EquCut->ModSeqNo
                                       ***         IF !FOUND()                // Level 3
                                          ApRLock( 3 )
                                          APPEND BLANK
                                          QuotCut->Find     := Quot->Invno+Equ->ModSeqno 
                                          QuotCut->Invno    := Quot->Invno
                                          QuotCut->Modseqno := EquCut->ModSeqno
                                          QuotCut->Partnum  := Quot->Partnum
                                          QuotCut->Length   := EquCut->Length
                                          QuotCut->Width    := EquCut->Width
                                          QuotCut->Qty      := nTotQty
                                          QuotCut->ModRef   := EquCut->ModRef
                                          QuotCut->Date     := EquCut->Date
                                          UNLOCK
                                       ***         ENDIF         
                                       SELECT EquCut 
                                       SKIP ALIAS EquCut
                                    ENDDO
                                    mpartnum := Equ->Partnum
                                    IF mlevel = 4
                                       SELECT Equ
                                       mmod4   := TRIM( Equ->Partnum )
                                       nrecno4 := RECNO()
                                       ***         nequPartQty := Equ->PartQty
                                       GOTO TOP
                                       SEEK mmod4
                                       IF FOUND()
                                          DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                                             IF mxy = "N"
                                                IF SUBSTR( Equ->Partnum, 1, 2 ) = "XY"
                                                   SKIP ALIAS Equ
                                                   LOOP
                                                ENDIF
                                             ENDIF
                                             IF SUBSTR( Equ->Partnum, 1, 2 ) = "ZZ"
                                                SKIP ALIAS Equ
                                                LOOP
                                             ENDIF 
                                             nqty4 := Equ->PartQty
                                             nequqty4 := nequqty3*Equ->PartQty
                                             nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
                                             SELECT Part
                                             SEEK Equ->Partnum
                                             mpartnum := Equ->Partnum
                                             mseek := Equ->ModSeqno+mpartnum
                                             SELECT EquCut
                                             GOTO TOP
                                             SEEK mseek
                                             nCutSum:= nTotQty := 0
                                             DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                                                DO CASE
                                                   CASE Part->Unit = "Mtr       "
                                                       nTotQty := Quot->Qty*EquCut->Qty
                                                       nCut := INT( Part->Length/EquCut->Length )
                                                       nCutTot := nTotQty/nCut
                                                       IF nCutTot > INT( nCutTot )
                                                          nCutTot := nCutTot
                                                        ELSE
                                                          nCutTot := nCutTot
                                                       ENDIF
                                                   CASE Part->Unit = "Sq Mtr    "
                                                       nTotQty := Quot->Qty*EquCut->Qty
                                                ENDCASE
                                                SELECT QuotCut
                                                ***         mfind := Quot->Invno+EquCut->ModSeqno
                                                SEEK EquCut->ModSeqNo
                                                ***         IF !FOUND()                 // Level 3 
                                                ApRLock( 3 )
                                                APPEND BLANK
                                                QuotCut->Find     := Quot->Invno+Equ->ModSeqno 
                                                QuotCut->Invno    := Quot->Invno
                                                QuotCut->Modseqno := EquCut->ModSeqno
                                                QuotCut->Partnum  := Quot->Partnum
                                                QuotCut->Length   := EquCut->Length
                                                QuotCut->Width    := EquCut->Width
                                                QuotCut->Qty      := nTotQty
                                                QuotCut->ModRef   := EquCut->ModRef
                                                QuotCut->Date     := EquCut->Date
                                                UNLOCK
                                                ***         ENDIF         
                                                SELECT EquCut
                                                SKIP ALIAS EquCut
                                             ENDDO
                                             mpartnum := Equ->Partnum
                                             SELECT Equ 
                                             SKIP ALIAS Equ
                                          ENDDO                       //  mmod4
                                       ENDIF                          
                                    ENDIF                                   // mlevel = 4                
                                    SELECT Equ 
                                    GOTO nrecno4
                                    SKIP ALIAS Equ
                                 ENDDO                       //  mmod3
                              ENDIF                          // FOUND()  mmod3    
                           ENDIF                                 // mlevel = 3
                           SELECT Equ
                           GOTO nrecno3
                           SKIP ALIAS Equ
                        ENDDO                       //  mmod2 EOF()
                     ENDIF                         // Found mmod2
                  ENDIF
               ENDIF                   //   mequ Only first
               SELECT Equ
               GOTO nrecno2
               SKIP ALIAS Equ
            ENDDO                       //   mmod1 EOF()
         ENDIF                          // Found mmod1
      ENDIF                                   // mlevel = 1
      ****         SET EXACT OFF      
      SELECT Quot
      SKIP ALIAS Quot
   ENDDO                            //   EOF() Quot

   RETURN NIL
   ****----- End of QCutOrder()

   ****--------------------------------------------------------------------------

FUNCTION LabClean()

   ****   NO GOOD NOT MODULE SPECIFIC
   SELECT Part
   SET ORDER TO 1                  // Partnum
   nl := 2
   SCROLL()
   DISPBOX( 0, 1, 24,79, 2 ) 
   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      SELECT Labour
      GOTO TOP
      DO WHILE Labour->( !EOF() )
         IF Labour->Partnum = SPACE( 20 )
            SKIP ALIAS Labour
            LOOP
         ENDIF 
         SELECT Part
         GOTO TOP
         SEEK Labour->Partnum
         IF !FOUND()
            SELECT Labour
             ApRLock( 3 )
            IF nl > 23
               INKEY( 0 )
               nl := 2
               SCROLL()
               DISPBOX( 0, 1, 24,79, 2 ) 
            ENDIF
            @ nl,10      SAY Labour->Partnum
            @ nl,COL()+2 SAY Labour->Time PICTURE "9,999.99"
            @ nl,COL()+2 SAY Labour->Date
            nl++
      ****         DELETE
            UNLOCK
         ENDIF                      // ! Found Lab Part
         SELECT Labour
         SKIP ALIAS Labour   
      ENDDO                         // Labour
       mcontinue := "N"
      ***ApGetY( Message->Another )
   ENDDO                            // mcontinue

   RETURN NIL

   ****  End of LabClean()

   *****-----------------------------------------------------------------------

FUNCTION QuickDel()

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"

       ccatno := SPACE(12)
       CatArray( aCatcode_ )            // This sorts out Cat File
       mok := "Y"
       DO WHILE mok = "Y"
          SELECT Part
          SET ORDER TO 2                       // Catno
          GOTO TOP
          SEEK ccatno
          nrecno := 0
          aPart_ := {}
          DO WHILE Part->Catno = ccatno .AND. Part->( !EOF() ) 
              AADD( aPart_,SUBSTR( Part->Partnum, 1,16 );
                           +"  "+SUBSTR( Part->Desc, 1,30 );
                           +"  "+STR( Part->Instock,13, 3 );
                           +" "+Part->Unit;
                           +"        "+STR( RECNO(),6 ) )
                   SKIP ALIAS Part
          ENDDO   // Part EOF
          SCROLL() 
          DISPBOX( 0, 1, 2,79, 2 )
          @  1, 2 SAY SUBSTR( Cat->CatDesc, 1,45 )
          @  1,49 SAY "Deletes IF Instock > 999999" COLOR "G+"
          DISPBOX( 3, 1, 24,79, 2 )
          IF !EMPTY( aPart_ )
             ASORT( aPart_,,,{ | x,y | x < y } )
             anum := ACHOICE( 4, 3, 23,77, aPart_,,"AFUNC" )
             IF LASTKEY() = 27
                EXIT
             ENDIF  
             nrecno := VAL( RIGHT( aPart_[anum],6 ) )
             GOTO nrecno
          ENDIF
          ninstock := Part->Instock
          @ ROW(),55 GET ninstock PICTURE "999999.999"
           READ
           ApRLock( 3 )
          Part->Instock := ninstock
          UNLOCK
   /*
          SCROLL( 19, 2, 23,78 )
          @ 20,20 GET Part->Desc
           READ   
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
          @ 20,67 PROMPT "Each  "
          @ 21,67 PROMPT "Mtr   "
          @ 22,67 PROMPT "Sq Mtr"
          @ 23,67 PROMPT "Cu Mtr"
          MENU TO nselect
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
   */ 
         LOOP
       ENDDO
       mcontinue := ApGetY( Message->Another )
   ENDDO                    // mcontinue
   SELECT Part
   SET ORDER TO 1                  // Partnum
   GOTO TOP
   DO WHILE Part->( !EOF() )
      IF Part->Instock > 99999
             mpartnum := Part->Partnum 
                @ 21,10 SAY "    Please Wait takes Me time   "
                SELECT Part
                SEEK mpartnum
                 ApRLock( 3 )
                DELETE 
                UNLOCK
                SELECT Equ
                 ApFLock( 3 )
                DELETE ALL FOR Equ->Partnum = mpartnum 
                GOTO TOP
                DELETE ALL FOR Equ->Modcode = SUBSTR( mpartnum, 1,16 )
                UNLOCK
                SELECT EquDesc
                 ApFLock( 3 )
                DELETE ALL FOR EquDesc->Modcode = SUBSTR( mpartnum, 1,16 )
                UNLOCK
   /*
   TEST THIS FIRST
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
      ENDIF                   // > 999
      SKIP ALIAS Part
   ENDDO    
   ***  DBFReindx()
   ***  XF_DBFUse()

   RETURN NIL

   ****  End of QuickDel()

   *****-----------------------------------------------------------------------

FUNCTION ContDbf()

  SCROLL()
  DISPBOX( 1, 1, 23,79, 2 )
  SELECT Control
  GOTO TOP
   ApFLock( 3 )
  npartold:= npartnew:= 0
  mok := "N"
  DO WHILE mok == "N"
    nl := 2
    @  nl,10 SAY "  Customer Name  "GET Control->U_Name PICTURE "@X"
    nl++
    @ nl, 3      SAY "Invoice"         GET Control->LastIvc   PICTURE "999999"
    @ nl,COL()+1 SAY "Work #"          GET Control->LastQuot
    @ nl,COL()+1 SAY "Order JC-"       GET Control->LastOrd  PICTURE "9999"
    @ nl,COL()+1 SAY "QU-"             GET Control->QuotNo   PICTURE "9999"
    @ nl,COL()+1 SAY "Saleno"          GET Control->Saleno   PICTURE "@!"

   ***    @ nl,COL()+2 SAY "H = Hist :"   GET Control->Hist     PICTURE "@!"
    nl+=2
    @ nl,16 SAY "Address 1 :" GET Control->U_Add1   PICTURE "@X"
    nl++
    @ nl,16 SAY "Address 2 :" GET Control->U_Add2   PICTURE "@X"
    nl++
    @ nl,16 SAY "Address 3 :" GET Control->U_Add3   PICTURE "@X"
    nl++
    @ nl,16 SAY "Address 4 :" GET Control->U_Add4   PICTURE "@X"
    @ nl,COL()+2 SAY "Zip"    GET Control->U_Zip    PICTURE "@X"
    nl++
    @ nl,13 SAY "Phone number :"  GET Control->U_Phone     PICTURE "@X"
    @ nl,COL()+3 SAY "Fax :"      GET Control->U_Fax       PICTURE "@X"
    nl++
    @ nl,13 SAY "Mobile Phone :"  GET Control->U_MobPhone    PICTURE "@X"
   ***    @ nl,COL()+2 SAY "File :"        GET Control->U_Cust_no  PICTURE "@X"
    nl++
   ***    @ nl,18 SAY "Printer :"          GET Control->Printer    PICTURE "@!"
    @ nl,13 SAY "Your Own GST #" GET Control->U_GSTno    PICTURE "@!"
    nl++
    @ nl,17 SAY "GST Rate :"   GET Control->GstRate          PICTURE "99.99"
    @ nl,COL()+2 SAY "Labour Part #"  GET Control->LastPart  PICTURE "@!"
    nl++
    @ nl, 6 SAY "Invoice Note 1" GET Control->Con_Note1
    nl++
    @ nl, 6 SAY "Invoice Note 2" GET Control->Con_Note2
    nl++
    @ nl, 6 SAY "Invoice Note 3" GET Control->Con_Note3
    nl++
    @ nl, 4 SAY "Statement Note 1" GET Control->Con_Note4
    nl++
    @ nl, 4 SAY "Statement Note 2" GET Control->Con_Note5
    nl++
    @ nl, 4 SAY "Statement Note 3" GET Control->Con_Note6
   ***    @ nl,13 SAY "Users Codeno :"   GET Control->U_Codeno   PICTURE "@!"
   ***    @ nl,COL()+2 SAY "H = save Invoices" GET Control->HistInv PICTURE "@!"
     READ
    mok := ApGetY( Message->Correct )
  ENDDO
  SCROLL()
  DISPBOX( 4, 1, 19,79, 2 )
   ***  @  5, 8      SAY "Text Files Directory" GET Control->Entlev2
   ***  @  6,13      SAY "Text Files Name"      GET Control->Entlev3
  @  6, 8      SAY "Accounts Start Date"  GET Control->Acc_Date PICTURE "99/99/9999"    
  @  8, 8      SAY "U_Codeno =   "        GET Control->U_Codeno
  @  8,COL()+2 SAY "Network Delay Time"   GET Control->Sec      PICTURE "999.999" 
   ***  @ 10, 8      SAY "Start Date JC-"    GET Control->Setdate  PICTURE "99/99/9999"
  @ 10, 8      SAY "DataTech Name"        GET Control->O_Name
   READ
  UNLOCK
  SCROLL()
  DISPBOX( 2, 1, 24,79, 2 )
  SELECT Message
    ApFLock( 3 )
   @  3, 8 SAY "Enter - PART - for Part number Listing" GET Message->Mess09;
                PICTURE "@!"
   @  5, 8 SAY "Part with Name"        GET Message->NamePart PICTURE "@!" 
   @  6, 8 SAY "        Labour Part #" GET Message->LabPart  PICTURE "@!"
   @  8, 8 SAY "   Work Order Message" GET Message->Mess13
   @  9, 8      SAY "Export Character Code" GET Message->Saleno5 PICTURE "!!" 
   @  9,COL()+2 SAY "GST #13"               GET Message->Saleno4 PICTURE "@!" 
   @ 10, 8 SAY "Accounts Code No"      GET Message->Stock5  PICTURE "@!" 
   @ 12, 8 GET Message->Saleno1
   @ 13, 8 GET Message->Saleno2
   @ 14, 8 GET Message->Saleno3
    READ
   UNLOCK
  SCROLL()
  DISPBOX( 2, 1, 24,79, 2 )
  SELECT Menu1
    ApFLock( 3 )
   @  4, 8 GET Menu1->Exec01 PICTURE "@!"
   @  5, 8 GET Menu1->Exec02 PICTURE "@!"
   @  6, 8 GET Menu1->Exec03 PICTURE "@!"
   @  7, 8 GET Menu1->Exec04 PICTURE "@!"
   @  8, 8 GET Menu1->Exec05 PICTURE "@!"
   @  9, 8 GET Menu1->Exec06 PICTURE "@!"
   @ 10, 8 GET Menu1->Exec07 PICTURE "@!"
   @ 11, 8 GET Menu1->Exec08 PICTURE "@!"
   @ 12, 8 GET Menu1->Exec09 PICTURE "@!"
   @ 13, 8 GET Menu1->Exec10 PICTURE "@!"
   @ 14, 8 GET Menu1->Exec11 PICTURE "@!"
   @ 15, 8 GET Menu1->Exec12 PICTURE "@!"
   @ 16, 8 GET Menu1->Exec13 PICTURE "@!"
   @ 17, 8 GET Menu1->Exec14 PICTURE "@!"
    READ
   @  4,25 GET Menu1->Mess01 PICTURE "@!"
   @  5,25 GET Menu1->Mess02 PICTURE "@!"
   @  6,25 GET Menu1->Mess03 PICTURE "@!"
   @  7,25 GET Menu1->Mess04 PICTURE "@!"
   @  8,25 GET Menu1->Mess05 PICTURE "@!"
   @  9,25 GET Menu1->Mess06 PICTURE "@!"
   @ 10,25 GET Menu1->Mess07 PICTURE "@!"
   @ 11,25 GET Menu1->Mess08 PICTURE "@!"
   @ 12,25 GET Menu1->Mess09 PICTURE "@!"
   @ 13,25 GET Menu1->Mess10 PICTURE "@!"
   @ 14,25 GET Menu1->Mess11 PICTURE "@!"
   @ 15,25 GET Menu1->Mess12 PICTURE "@!"
   @ 16,25 GET Menu1->Mess13 PICTURE "@!"
   @ 17,25 GET Menu1->Mess14 PICTURE "@!"
    READ
   UNLOCK
   SELECT Message
    ApFLock( 3 )
   @ 22, 8      GET Message->Mess08  PICTURE "!!!!!!"
   @ 22,COL()+4 GET Message->Charge1 PICTURE "!!!!!!"
    READ 
   UNLOCK
   RETURN NIL

   *** End of ContDbf()

   **-------------------------------------------------------------------

FUNCTION Supldisp( mpartnum )

   tempscr := SAVESCREEN(  3, 0, 24,80 )
   SELECT Supl
   SET ORDER TO 1                       // Partnum Index
   aPart_:={}
   IF LASTREC() != 0
      GO TOP
      SEEK mpartnum
      DO WHILE Supl->Partnum = mpartnum .AND. Supl->( !EOF() )
         SELECT Name
         SEEK Supl->Codeno
         AADD( aPart_, ( Name->Name+"  "+STR( Supl->Cost )+" "+DTOC( Supl->Date ) ) )
         SELECT Supl
         SKIP ALIAS Supl
      ENDDO
      SCROLL(  17, 0, 24,80 )
      DISPBOX( 17, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         @ 17,00 SAY " "
         AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+" " ),QQOUT(A),Breakpoint() } )
   ***         anum := ACHOICE( 18, 7, 23,74, aPart_,,"AFUNC" )
      ENDIF             // !Empty
   ENDIF                // LastRec
    RESTSCREEN( 3, 0, 24,80, tempscr )
   UNLOCK
 
   RETURN mpartnum

   ***----  End of Supldisp()

   **-------------------------------------------------------------------

FUNCTION Breakpoint()

   pCRLF := CHR(13)+CHR(10) 

   IF COL() > 78
      QQOUT( pCRLF )
   ENDIF
   IF ROW() >= 22
      @ 24,10 SAY " Any Key for next Screen "
      INKEY( 0 )
      SCROLL(  3, 3, 23,79 ) 
      @  3,00 SAY " "
   ENDIF 

   RETURN NIL

   ***---- End of Breakpoint()

   **-------------------------------------------------------------------

FUNCTION BreakTot()

   pCRLF := CHR(13)+CHR(10) 

   IF COL() > 78
      QQOUT( pCRLF )
   ENDIF
   IF ROW() > 21
      @ 24,10 SAY "Any Key for next Screen"
      INKEY( 0 )
      SCROLL()
      @  1, 0 SAY " "
   ENDIF 

   RETURN NIL

   ***---- End of BreakTot()

   **-------------------------------------------------------------------

FUNCTION Breakprint()

   IF PROW() > 56
     EJECT
   ENDIF

   RETURN NIL

   ***---- End of Breakprint()

   **-------------------------------------------------------------------

FUNCTION InitFiles()    // Opens all files in Apn

   ** First check for presence of indexes
   ** If function returns .T., reindexing is done

   IF !FILE("NameInd.NTX")
     RETURN .T.
   ENDIF
   IF !FILE("DebInd.NTX")
     RETURN .T.
   ENDIF
   IF !FILE("PartInd.NTX")
     RETURN .T.
   ENDIF

   RETURN .F.

   **---  End Initfiles

   *****---------------------- END OF XF_UTIL.PRG