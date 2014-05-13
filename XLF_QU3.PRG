   *** JK 21-06-11 10:02:18 

/*
   Program ......:                   XLF_QU3.PRG
   Authors.......: John Kirby
   Date..........: 12/11/2001
   Functions.....: QuotCut, LabInvP
   Static funcs..: QuotFormA, QuotHd, QuotForm
   Not used......: QuotEach
*/

#include "pcodeaah.CH"

FUNCTION QuotCut( mcodeno )

   SCROLL()
   DISPBOX( 4, 1, 17,79, 2 )
   @  5,10 SAY "Cut List ONLY of Job Card"
   mok := "N"
   minvno := Debit->Invno
   mselect:= cbuyonly := "N"
   mequ := "Y"
   cbuyonly := "Y"
   mstock:= moper:= mABC := "N"
   mequ    := "Y"
   mxy     := "N"
   mlevel  := 2
   mdetail := "N"
   @ 12,10 SAY "Module Level Required 2, 3, 4" GET mlevel PICTURE "9"
    READ
   cpagehd := "New PrCut"+STR( mlevel, 1 )
   mxy     := ApGetN( "Include XY Parts" )
   IF mxy = "Y"
      @ 14,10 SAY "XY Parts Included" COLOR "R+"
      cpagehd := "New PRcutXY"+STR( mlevel, 1 )
   ENDIF 
   mdetail := "N"
   *** ApGetN( "Length Details Required" )
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
   @ nl, 0 SAY TRIM( Name->Name )+"  "+TRIM( Debit->Est )+"   "+minvno
   nl+=2
   @  nl,10 SAY "IMPORTANT  Cut List  TO LEVEL 4  ONLY "+minvno
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
      nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
      nqty1:= nqty2:= nqty3:= nqty4 := 0
      nequ1:= nequ2:= nequ3:= nequ4 := 0
      nequqty1:= nequqty2:= nequqty3:= nequqty4 := 0
      nquot := Quot->Qty
      SELECT Equ
      mmod1 := TRIM( Quot->Partnum )
      SEEK mmod1
      SELECT Part
      SEEK Quot->Partnum
      mpartnum := Quot->Partnum
      SELECT EquCut
      SEEK Quot->ModSeqno
      IF Part->Unit != "Each      "    
         @ nl, 0 SAY STR( Quot->Qty, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                     +" "+Part->Desc;
                     +"   "+SUBSTR( Quot->Partnum, 1,16 )
         nl+=2
         DO WHILE EquCut->ModSeqno = Quot->Modseqno .AND. EquCut->( !EOF() )
            IF mwhere = "S"
               IF nl > 22
                  INKEY( 0 )
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            IF EquCut->Width > 0
               @ nl, 1 SAY STR( nquot*EquCut->Qty, 8 )+" x ";
                  +STR( EquCut->Length, 8, 3  );
                  +" x "+STR( EquCut->Width, 8, 3  );
                  +"   "+EquCut->ModRef
            ELSE
               @ nl,17 SAY STR( nquot*EquCut->Qty, 8 )+" x ";
                  +STR( EquCut->Length, 8, 3  );
                  +"   "+EquCut->ModRef
            ENDIF
            nl++
            SKIP ALIAS EquCut
         ENDDO
      ENDIF           // Each
      IF mlevel >= 1
         SELECT Equ
         GOTO TOP
         SET EXACT ON
         mmod1 := TRIM( Quot->Partnum )
         SEEK mmod1
         IF FOUND()   
            DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
               nrecno1 := RECNO()
               IF nl > npl
                  IF mwhere = "P"
                     EJECT
                     nl := 2
                  ENDIF
                  @  0, 0 SAY Control->U_Name
                  @  0,45 SAY STR( DAY(  DATE() ),3 )+" "+CMONTH( DATE() );
                             +STR( YEAR( DATE() ),5 )
                  @  0,67 SAY cpagehd
               ENDIF
               IF mwhere = "S"
                  IF nl > 22
                     INKEY( 0 )
                     SCROLL()
                     nl := 0
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
               IF Part->Unit != "Each      "    
                  SELECT EquCut
                  GOTO TOP
                  SEEK mseek
                  IF FOUND()
                     @ nl, 0 SAY Equ->ABC+"."
                     @ nl, 3 SAY STR( nequ1, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                        +" "+SUBSTR( Part->Desc, 1,22 );
                        +" "+SUBSTR( Equ->Partnum, 1,16 )
                     *** ;
                     ***                        +" "+SUBSTR( Equ->Modcode, 1,20 )
                     nl++
                     IF mdetail = "Y"
                        @ nl,13 SAY "Length Mtr"+STR( Part->Length, 8, 3  )
                        @ nl,32 SAY "Width mm "+STR( Part->Width, 8, 3 )
                        @ nl,50 SAY "Thick mm "+STR( Part->Thick, 8, 3 )
                        ***            @ nl,69 SAY Part->Codeno 
                        nl++
                     ENDIF                        // mdetail = Y
                  ENDIF
                  nCutSum := 0
                  DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                     DO CASE
                        CASE Part->Unit = "Mtr       "
                           nTotQty := Quot->Qty*EquCut->Qty
                           @ nl, 2 SAY nTotQty PICTURE "9,999"
                           @ nl, 8 SAY " x "+STR( EquCut->Length, 8, 3 );
                           +" Mtr   "+EquCut->ModRef
                           nCut := INT( Part->Length/EquCut->Length )
                           nCutTot := nTotQty/nCut
                           IF nCutTot > INT( nCutTot )
                              nCutTot := nCutTot
                            ELSE
                              nCutTot := nCutTot
                           ENDIF
                           /*
                            IF mdetail = "Y"
                               @ nl,67 SAY ( Part->Length/EquCut->Length ) PICTURE "999 Per/Ln"  
                              ELSE
                               @ nl,70 SAY nTotQty*EquCut->Length PICTURE "9,999.999"
                            ENDIF                    // mdetail
                           */
                           nCutSum += nCutTot
                           nl++
                        CASE Part->Unit = "Sq Mtr    "
                           ntotqty := Quot->Qty*EquCut->Qty
                           @ nl, 4 SAY STR( ntotqty, 1, 5 );
                                +" x "+STR( EquCut->Length, 6, 3 )+" Mtr ";
                                +STR( ( EquCut->Width ), 6, 3 )+" Mtr   ";
                                +EquCut->ModRef
                           ***                @ nl,72 SAY ( EquCut->Length*EquCut->Width ) PICTURE "999.999"
                           nl++  
                     ENDCASE
                     IF mdetail = "Y" 
                        IF nCutSum > 0
                           DO CASE
                              CASE nCutSum > INT( nCutTot )
                                 nCutSum := nCutSum+1
                              CASE nCutTot < 1
                                 nCutSum := nCutSum+1
                           ENDCASE
                           ***         @ nl,56 SAY INT( nCutSum ) PICTURE "Total Lengths =9,999"
                        ENDIF
                     ENDIF                    // mdetail
                     SKIP ALIAS EquCut
                  ENDDO
                  nl++
               ENDIF
               SELECT Equ
               mmod2 := TRIM( Equ->Partnum )
               ***  IF mequ = "Y"
               GOTO TOP
               SEEK mmod2
               IF FOUND()   
                  IF mlevel >= 2
                     DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
                        nrecno2 := RECNO() 
                        IF nl > npl
                           IF mwhere = "P"
                              EJECT
                              nl := 0  
                           ENDIF
                        ENDIF
                        IF mwhere = "S"
                           IF nl > 22
                              INKEY( 0 )
                              SCROLL()
                              nl := 0
                           ENDIF
                        ENDIF
                        IF mxy = "N"
                           IF Equ->ABC = "x"
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
                        SELECT Part
                        SEEK Equ->Partnum
                        mpartnum := Equ->Partnum
                        mseek := Equ->ModSeqno+mpartnum
                        IF Part->Unit != "Each      "    
                           SELECT EquCut
                           GOTO TOP
                           SEEK mseek
                           IF FOUND()
                              @ nl, 0 SAY Equ->ABC+".."
                              @ nl, 4 SAY STR( nequ2, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                                 +" "+SUBSTR( Part->Desc, 1,22 );
                                 +" "+SUBSTR( Equ->Partnum, 1,16 );
                                 +" "+SUBSTR( Equ->Modcode, 1,20 )
                              nl++
                              IF mdetail = "Y"
                                 ***            @ nl, 5 SAY SUBSTR( Part->Unit, 1, 6 )
                                 @ nl,13 SAY "Length Mtr"+STR( Part->Length, 8, 3  )
                                 @ nl,32 SAY "Width mm "+STR( Part->Width, 8, 3 )
                                 @ nl,50 SAY "Thick mm "+STR( Part->Thick, 8, 3 )
                                 ***            @ nl,69 SAY Part->Codeno 
                                 nl++
                              ENDIF                        // mdetail = Y
                           ENDIF
                           nCutSum := 0
                           DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                              DO CASE
                                 CASE Part->Unit = "Mtr       "
                                    nTotQty := Quot->Qty*EquCut->Qty
                                    @ nl, 4 SAY nequqty1*EquCut->Qty PICTURE "9,999"
                                    @ nl,10 SAY "x "+STR( EquCut->Length, 8, 3 );
                                    +" Mtr   "+EquCut->ModRef
                                    nCut := INT( Part->Length/EquCut->Length )
                                    nCutTot := nTotQty/nCut
                                    IF nCutTot > INT( nCutTot )
                                       nCutTot := nCutTot
                                     ELSE
                                       nCutTot := nCutTot
                                    ENDIF
                                    IF mdetail = "Y"
                                       /*
                                       IF nCutTot > 0
                                       ***                @ nl,53 SAY nCutTot PICTURE "999.999 Lths"
                                          @ nl,69 SAY ( Part->Length/EquCut->Length ) PICTURE "999 Per/Ln"  
                                        ELSE
                                          @ nl,70 SAY nTotQty*EquCut->Length PICTURE "9,999.999"
                                       ENDIF
                                       */
                                       nCutSum += nCutTot
                                    ENDIF  
                                    nl++
                                 CASE Part->Unit = "Sq Mtr    "
                                    nTotQty := Quot->Qty*EquCut->Qty
                                    @ nl, 4 SAY nequqty1*EquCut->Qty PICTURE "9,999"
                                    @ nl,10 SAY " x "+STR( EquCut->Length, 6, 3 )+" Mtr ";
                                       +STR( ( EquCut->Width ), 6, 3 )+" Mtr   ";
                                       +SUBSTR( EquCut->ModRef, 1,34 )
                                    ***                @ nl,70 SAY ( EquCut->Length*EquCut->Width ) PICTURE "999.999"
                                    nl++  
                              ENDCASE
                              IF nCutSum > 0
                                 DO CASE
                                    CASE nCutSum > INT( nCutTot )
                                       nCutSum := nCutSum+1
                                    CASE nCutTot < 1
                                       nCutSum := nCutSum+1
                                 ENDCASE
                              ENDIF
                              SKIP ALIAS EquCut
                           ENDDO
                           IF mdetail = "Y"
                              IF nCutSum > 0
                                 ***         @ nl,54 SAY INT( nCutSum ) PICTURE "Total Lengths =9,999"
                                 ***         nl++
                              ENDIF
                           ENDIF
                        ENDIF                  // Each
                        IF mlevel >= 3
                           SELECT Equ
                           mmod3 := TRIM( Equ->Partnum )
                           nrecno3 := RECNO() 
                           ***      nequPartQty := Equ->PartQty
                           GOTO TOP
                           SEEK mmod3
                           IF FOUND()   
                              DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
                                 nrecno3 := RECNO() 
                                 IF nl > npl
                                    IF mwhere = "P"
                                       EJECT
                                       nl := 0 
                                    ENDIF
                                 ENDIF
                                 IF mwhere = "S"
                                    IF nl > 22
                                       INKEY( 0 )
                                       SCROLL()
                                       nl := 0
                                    ENDIF
                                 ENDIF
                                 IF mxy = "N"
                                    IF Equ->ABC = "x"
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
                                 IF Part->Unit != "Each      "    
                                    SELECT EquCut
                                    GOTO TOP
                                    SEEK mseek
                                    IF FOUND()
                                       @ nl, 0 SAY Equ->ABC+"..."
                                       @ nl, 5 SAY STR( nequ3, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                                          +" "+SUBSTR( Part->Desc, 1,22 );
                                          +" "+SUBSTR( Equ->Partnum, 1,16 );
                                          +" "+SUBSTR( Equ->Modcode, 1,20 )
                                       nl++
                                       IF mdetail = "Y"
                                          @ nl,13 SAY "Length Mtr"+STR( Part->Length, 8, 3  )
                                          @ nl,32 SAY "Width mm "+STR( Part->Width, 8, 3 )
                                          @ nl,50 SAY "Thick mm "+STR( Part->Thick, 8, 3 )
                                          @ nl,69 SAY Part->Codeno 
                                          nl++
                                       ENDIF                        // mdetail = Y
                                    ENDIF
                                    nCutSum := 0
                                    DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                                       DO CASE
                                          CASE Part->Unit = "Mtr       "
                                             nTotQty := Quot->Qty*EquCut->Qty
                                             @ nl, 4 SAY nquot*( nequqty2*EquCut->Qty ) PICTURE "9,999"
                                             @ nl,10 SAY "x "+STR( EquCut->Length, 8, 3 )+" Mtr   ";
                                             +EquCut->ModRef
                                             nCut := INT( Part->Length/EquCut->Length )
                                             nCutTot := nTotQty/nCut
                                             IF nCutTot > INT( nCutTot )
                                                nCutTot := nCutTot
                                             ELSE
                                                nCutTot := nCutTot
                                             ENDIF
                                             IF mdetail = "Y"
                                               /*
                                                IF nCutTot > 0
                                                  ***                  @ nl,53 SAY nCutTot PICTURE "999.999 Lths"
                                                   @ nl,69 SAY ( Part->Length/EquCut->Length ) PICTURE "999 Per/Ln"  
                                                 ELSE
                                                  @ nl,70 SAY nTotQty*EquCut->Length PICTURE "9,999.999"
                                                ENDIF
                                               */
                                                nCutSum += nCutTot
                                             ENDIF
                                             nl++
                                          CASE Part->Unit = "Sq Mtr    "
                                             nTotQty := Quot->Qty*EquCut->Qty
                                             @ nl, 4 SAY nquot*( nequqty2*EquCut->Qty ) PICTURE "9,999"
                                             @ nl,10 SAY"x "+STR( EquCut->Length, 6, 3 )+" Mtr ";
                                                +STR( ( EquCut->Width ), 6, 3 )+" Mtr   ";
                                                +EquCut->ModRef
                                                ***                @ nl,70 SAY ( EquCut->Length*EquCut->Width ) PICTURE "999.999"
                                             nl++  
                                       ENDCASE
                                       IF nCutSum > 0
                                          DO CASE
                                             CASE nCutSum > INT( nCutTot )
                                                nCutSum := nCutSum+1
                                             CASE nCutTot < 1
                                                nCutSum := nCutSum+1
                                          ENDCASE
                                       ENDIF
                                       SKIP ALIAS EquCut
                                    ENDDO
                                    /*
                                    IF mdetail = "Y"
                                       IF nCutSum > 0
                                          ***        @ nl,54 SAY INT( nCutSum ) PICTURE "Total Lengths =9,999"
                                          ***        nl++
                                       ENDIF
                                    ENDIF
                                    */
                                    mpartnum := Equ->Partnum
                                 ENDIF             // Each
                                 IF mlevel = 4
                                    SELECT Equ
                                    mmod4   := TRIM( Equ->Partnum )
                                    ***         nequPartQty := Equ->PartQty
                                    GOTO TOP
                                    SEEK mmod4
                                    IF FOUND()
                                       DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                                          nrecno4 := RECNO()
                                          IF nl > npl
                                             IF mwhere = "P"
                                                EJECT
                                                nl := 0  
                                             ENDIF
                                          ENDIF
                                          IF mwhere = "S"
                                             IF nl > 22
                                                INKEY( 0 )
                                                SCROLL()
                                                nl := 0
                                             ENDIF
                                          ENDIF
                                          IF mxy = "N"
                                             IF Equ->ABC = "x"
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
                                          IF Part->Unit != "Each      "    
                                             SELECT EquCut
                                             GOTO TOP
                                             SEEK mseek
                                             IF FOUND()
                                                @ nl, 0 SAY Equ->ABC+"...."
                                                @ nl, 6 SAY STR( nequ4, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                                                   +" "+SUBSTR( Part->Desc, 1,22 );
                                                   +" "+SUBSTR( Equ->Partnum, 1,16 );
                                                   +" "+SUBSTR( Equ->Modcode, 1,20 )
                                                nl++
                                                IF mdetail = "Y"
                                                   ***            @ nl, 5 SAY SUBSTR( Part->Unit, 1, 6 )
                                                   @ nl,13 SAY "Length Mtr"+STR( Part->Length, 8, 3  )
                                                   @ nl,32 SAY "Width mm "+STR( Part->Width, 8, 3 )
                                                   @ nl,50 SAY "Thick mm "+STR( Part->Thick, 8, 3 )
                                                   ***            @ nl,69 SAY Part->Codeno 
                                                   nl++
                                                ENDIF                        // mdetail = Y
                                             ENDIF
                                             nCutSum := 0
                                             DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                                                DO CASE
                                                   CASE Part->Unit = "Mtr       "
                                                      nTotQty := Quot->Qty*EquCut->Qty
                                                      @ nl, 4 SAY nquot*( nequqty3*EquCut->Qty ) PICTURE "9,999"
                                                      @ nl,10 SAY "x "+STR( EquCut->Length, 8, 3 )+" Mtr   ";
                                                      +EquCut->ModRef
                                                      nCut := INT( Part->Length/EquCut->Length )
                                                      nCutTot := nTotQty/nCut
                                                      IF nCutTot > INT( nCutTot )
                                                         nCutTot := nCutTot
                                                       ELSE
                                                         nCutTot := nCutTot
                                                      ENDIF
                                                      IF mdetail = "Y"
                                                        /*
                                                         IF nCutTot > 0
                                                            @ nl,69 SAY ( Part->Length/EquCut->Length ) PICTURE "999 Per/Ln"  
                                                          ELSE
                                                           @ nl,70 SAY nTotQty*EquCut->Length PICTURE "9,999.999"
                                                         ENDIF
                                                        */
                                                         nCutSum += nCutTot
                                                      ENDIF                      // mdetail
                                                      nl++
                                                   CASE Part->Unit = "Sq Mtr    "
                                                      nTotQty := Quot->Qty*EquCut->Qty
                                                      @ nl, 4 SAY nquot*( nequqty3*EquCut->Qty ) PICTURE "9,999"
                                                      @ nl,10 SAY "x "+STR( EquCut->Length, 6, 3 )+" Mtr ";
                                                              +STR( ( EquCut->Width ), 6, 3 )+" Mtr   ";
                                                              +EquCut->ModRef
                                                      ***                 @ nl,70 SAY ( EquCut->Length*EquCut->Width ) PICTURE "999.999"
                                                      nl++  
                                                ENDCASE
                                                IF nCutSum > 0
                                                   DO CASE
                                                      CASE nCutSum > INT( nCutTot )
                                                           nCutSum := nCutSum+1
                                                      CASE nCutTot < 1
                                                           nCutSum := nCutSum+1
                                                   ENDCASE
                                                ENDIF
                                                SKIP ALIAS EquCut
                                             ENDDO
                                             IF mdetail = "Y"
                                                IF nCutSum > 0
                                                   ***            @ nl,54 SAY INT( nCutSum ) PICTURE "Total Lengths =9,999"
                                                   ***            nl++
                                                 ENDIF
                                             ENDIF                               // mdetail  
                                          ENDIF        // Each
                                          mpartnum := Equ->Partnum
                                          SELECT Equ 
                                          SKIP ALIAS Equ
                                       ENDDO                       //  mmod4
                                    ENDIF                          
                                 ENDIF                                   // mlevel = 4                
                                 SELECT Equ 
                                 GOTO nrecno3
                                 SKIP ALIAS Equ
                              ENDDO                       //  mmod3
                           ENDIF                          // FOUND()  mmod3    
                        ENDIF                                 // mlevel = 3
                        SELECT Equ
                        GOTO nrecno2
                        SKIP ALIAS Equ
                     ENDDO                       //  mmod2 EOF()
                     ***         nl++
                  ENDIF                         // Found mmod2
               ENDIF
               SELECT Equ
               GOTO nrecno1
               SKIP ALIAS Equ
            ENDDO                       //   mmod1 EOF()
         ENDIF                          // Found mmod1
      ENDIF                                   // mlevel = 1
      SET EXACT OFF      
      ***      nl++
      SELECT Quot
      SKIP ALIAS Quot
   ENDDO                            //   EOF() Quot
   nl++ 
   SELECT Quot
   SET ORDER TO 1
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

   RETURN NIL
   ****----- End of QuotCut

   ****--------------------------------------------------------------------------

FUNCTION QuotEach( mcodeno )
   SCROLL()
   DISPBOX( 4, 1, 17,79, 2 )
   @  5,10 SAY "Each Use List ONLY of Job Card"
   mok := "N"
   minvno := Debit->Invno
   mselect:= cbuyonly := "N"
   mequ := "Y"
   cbuyonly := "Y"
   mstock:= moper:= mABC := "N"
   mequ    := "Y"
   mxy     := "N"
   mlevel  := 4
   mdetail := "N"
   ***   @ 12,10 SAY "Module Level Required 2, 3, 4" GET mlevel PICTURE "9"
   ***    READ
   cpagehd := "EachU"+STR( mlevel, 1 )
   mxy     := "Y"
   ***      ApGetN( "Include XY Parts" )
   IF mxy = "Y"
      @ 14,10 SAY "XY Parts Included" COLOR "R+"
      cpagehd := "EachUXY"+STR( mlevel, 1 )
   ENDIF 
   mdetail := "N"
   *** ApGetN( "Length Details Required" )
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
   @ nl, 0 SAY TRIM( Name->Name )+"  "+TRIM( Debit->Est )+"  "+minvno
   nl+=2
   @  nl,10 SAY "IMPORTANT  Each Use List  TO LEVEL 4  ONLY "+minvno
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
      nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
      nqty1:= nqty2:= nqty3:= nqty4 := 0
      nequ1:= nequ2:= nequ3:= nequ4 := 0
      nequqty1:= nequqty2:= nequqty3:= nequqty4 := 0
      nquot := Quot->Qty
      SELECT Equ
      mmod1 := TRIM( Quot->Partnum )
      SEEK mmod1
      SELECT Part
      SEEK Quot->Partnum
      mpartnum := Quot->Partnum
   IF Part->Unit = "Each      "    
         SELECT EquCut
         SEEK Quot->ModSeqno
            @ nl, 0 SAY STR( Quot->Qty, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                        +" "+Part->Desc;
                        +"  "+SUBSTR( Quot->Partnum, 1,16 )
            nl+=2
         DO WHILE EquCut->ModSeqno = Quot->Modseqno .AND. EquCut->( !EOF() )
            IF mwhere = "S"
               IF nl > 22
                  INKEY( 0 )
                  SCROLL()
                  nl := 0
                ENDIF
            ENDIF
            @ nl,17 SAY STR( nquot*EquCut->Qty, 8 )+" x ";
                       +EquCut->ModRef
            nl++
           SKIP ALIAS EquCut
         ENDDO
   ENDIF           // Each
  IF mlevel >= 1
      SELECT Equ
      GOTO TOP
   ***      SET EXACT ON
      mmod1 := TRIM( Quot->Partnum )
      SEEK mmod1
      IF FOUND()   
         DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
            nrecno1 := RECNO()
            IF nl > npl
               IF mwhere = "P"
                  EJECT
                  nl := 2
                ENDIF
                @  0, 0 SAY Control->U_Name
                @  0,45 SAY STR( DAY(  DATE() ),3 )+" "+CMONTH( DATE() );
                           +STR( YEAR( DATE() ),5 )
                @  0,67 SAY cpagehd
            ENDIF
            IF mwhere = "S"
               IF nl > 22
                  INKEY( 0 )
                  SCROLL()
                  nl := 0
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
   IF Part->Unit = "Each      "    
         SELECT EquCut
         GOTO TOP
         SEEK mseek
         IF FOUND()
               @ nl, 0 SAY Equ->ABC+"."
               @ nl, 3 SAY STR( nequ1, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                           +" "+SUBSTR( Part->Desc, 1,22 );
                           +" "+SUBSTR( Equ->Partnum, 1,16 );
                           +" "+SUBSTR( Equ->Modcode, 1,20 )
               nl++
         ENDIF
         DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                   nTotQty := Quot->Qty*EquCut->Qty
                   @ nl, 2 SAY nTotQty PICTURE "9,999"
                   @ nl, 8 SAY EquCut->ModRef
                   @ nl,50 SAY nTotQty PICTURE "9,999.999 Required"
                   nl++
           SKIP ALIAS EquCut
         ENDDO
         nl++
    ENDIF                      // Each
      SELECT Equ
      mmod2 := TRIM( Equ->Partnum )
   ***  IF mequ = "Y"
      GOTO TOP
      SEEK mmod2
      IF FOUND()   
         IF mlevel >= 2
         DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
             nrecno2 := RECNO() 
             IF nl > npl
               IF mwhere = "P"
                  EJECT
                  nl := 0  
                ENDIF
            ENDIF
            IF mwhere = "S"
               IF nl > 22
                  INKEY( 0 )
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            IF mxy = "N"
               IF Equ->ABC = "x"
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
            SELECT Part
            SEEK Equ->Partnum
            mpartnum := Equ->Partnum
      mseek := Equ->ModSeqno+mpartnum
   IF Part->Unit = "Each      "    
         SELECT EquCut
         GOTO TOP
         SEEK mseek
         IF FOUND()
            @ nl, 0 SAY Equ->ABC+".."
            @ nl, 4 SAY STR( nequ2, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                        +" "+SUBSTR( Part->Desc, 1,22 );
                        +" "+SUBSTR( Equ->Partnum, 1,16 );
                        +" "+SUBSTR( Equ->Modcode, 1,20 )
            nl++
         ENDIF
         DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                   nTotQty := Quot->Qty*EquCut->Qty
                   @ nl, 5 SAY nequqty1*EquCut->Qty PICTURE "9,999"
                   @ nl,12 SAY "x "+EquCut->ModRef
                   nl++
                SKIP ALIAS EquCut
         ENDDO
    ENDIF                  // Each
  IF mlevel >= 3
      SELECT Equ
      mmod3 := TRIM( Equ->Partnum )
      nrecno3 := RECNO() 
   ***      nequPartQty := Equ->PartQty
      GOTO TOP
      SEEK mmod3
      IF FOUND()   
         DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
            nrecno3 := RECNO() 
            IF nl > npl
               IF mwhere = "P"
                  EJECT
                  nl := 0 
               ENDIF
            ENDIF
            IF mwhere = "S"
               IF nl > 22
                  INKEY( 0 )
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            IF mxy = "N"
               IF Equ->ABC = "x"
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
    IF Part->Unit = "Each      "    
         SELECT EquCut
         GOTO TOP
         SEEK mseek
         IF FOUND()
               @ nl, 0 SAY Equ->ABC+"..."
               @ nl, 5 SAY STR( nequ3, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                           +" "+SUBSTR( Part->Desc, 1,22 );
                           +" "+SUBSTR( Equ->Partnum, 1,16 );
                           +" "+SUBSTR( Equ->Modcode, 1,20 )
               nl++
         ENDIF
         DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                   nTotQty := Quot->Qty*EquCut->Qty
                   @ nl, 5 SAY nquot*( nequqty2*EquCut->Qty ) PICTURE "9,999"
                   @ nl,12 SAY "x "+EquCut->ModRef
                   nl++
           SKIP ALIAS EquCut
         ENDDO
         mpartnum := Equ->Partnum
   ENDIF             // Each
     IF mlevel = 4
         SELECT Equ
         mmod4   := TRIM( Equ->Partnum )
   ***         nequPartQty := Equ->PartQty
         GOTO TOP
         SEEK mmod4
         IF FOUND()
            DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
               nrecno4 := RECNO()
            IF nl > npl
               IF mwhere = "P"
                  EJECT
                  nl := 0  
                ENDIF
            ENDIF
            IF mwhere = "S"
               IF nl > 22
                  INKEY( 0 )
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            IF mxy = "N"
               IF Equ->ABC = "x"
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
    IF Part->Unit = "Each      "    
        SELECT EquCut
         GOTO TOP
         SEEK mseek
         IF FOUND()
               @ nl, 0 SAY Equ->ABC+"...."
               @ nl, 6 SAY STR( nequ4, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                           +" "+SUBSTR( Part->Desc, 1,22 );
                           +" "+SUBSTR( Equ->Partnum, 1,16 );
                           +" "+SUBSTR( Equ->Modcode, 1,20 )
               nl++
         ENDIF
         DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                   nTotQty := Quot->Qty*EquCut->Qty
                   @ nl, 5 SAY nquot*( nequqty3*EquCut->Qty ) PICTURE "9,999"
                   @ nl,11 SAY "x "+EquCut->ModRef
                   nl++
             SKIP ALIAS EquCut
         ENDDO
   ENDIF        // Each
            mpartnum := Equ->Partnum
               SELECT Equ 
               SKIP ALIAS Equ
             ENDDO                       //  mmod4
          ENDIF                          
   ENDIF                                   // mlevel = 4                
            SELECT Equ 
            GOTO nrecno3
            SKIP ALIAS Equ
          ENDDO                       //  mmod3
       ENDIF                          // FOUND()  mmod3    
   ENDIF                                 // mlevel = 3
            SELECT Equ
            GOTO nrecno2
            SKIP ALIAS Equ
         ENDDO                       //  mmod2 EOF()
   ***         nl++
      ENDIF                         // Found mmod2
   ENDIF
            SELECT Equ
            GOTO nrecno1
            SKIP ALIAS Equ
            ENDDO                       //   mmod1 EOF()
         ENDIF                          // Found mmod1
   ENDIF                                   // mlevel = 1
         SET EXACT OFF      
   ***      nl++
      SELECT Quot
      SKIP ALIAS Quot
   ENDDO                            //   EOF() Quot
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
   ****----- End of QuotEach

   ****--------------------------------------------------------------------------

FUNCTION LabInvP()

   minvno  := SPACE( 6 )
   mcodeno := SPACE( 8 )

   SELECT Debit
   *** SET ORDER TO 1                      // Codeno
   GOTO TOP
   IF LASTREC() != 0
      aPart_ := {}
      nrecno := 0
      DO WHILE Debit->( !EOF() )
         IF Debit->Stat != "J"
            SKIP ALIAS Debit
            LOOP
         ENDIF
         AADD( aPart_,Debit->Invno+" "+Debit->Stat;
              +" "+Debit->Codeno;
              +" "+DTOC( Debit->Dbdate );
              +" "+Debit->Est;
              +" "+Debit->Note1;
              +"          "+STR( RECNO(),6 ) )
         SKIP ALIAS Debit
      ENDDO
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX(  0, 1, 24,79, 2 )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum   := ACHOICE(  1, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
         IF PressedEsc()
            RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
         GOTO nrecno
         minvno  := Debit->Invno
         mcodeno := Debit->Codeno
      ENDIF                     // Empty
   ENDIF                        // LastRec    
   manother = "Y"
   DO WHILE manother = "Y"
         aPart_:={}
         nrecno := 0
         nTotTime := nTotRate := 0
         SELECT Labour
         GOTO TOP
         DO WHILE Labour->( !EOF() )
            IF Labour->Partnum = SPACE( 20 )
               SKIP ALIAS Labour
               LOOP
            ENDIF  
            IF Labour->Invno != minvno
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF Labour->Partnum = SPACE( 20 )
               nTotTime += Labour->Time
            ENDIF   
            nTotRate += Labour->Time*Labour->Rate  
            AADD( aPart_,SUBSTR( Labour->Partnum, 1,16 );
                       +" "+SUBSTR( Labour->Desc, 1,31 );
                       +" "+Labour->Codeno;
                       +" "+STR( Labour->Time, 6, 2 );
                       +" "+STR( Labour->Rate, 8, 2 ) )
            SKIP ALIAS Labour
         ENDDO                        // Labour EOF
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         SELECT Name
         SEEK Debit->Codeno
         @  1, 5      SAY TRIM( Name->Name )+" "+minvno COLOR "BG+"
         @  1,COL()+2 SAY Debit->Stat+"  $ "+STR( nTotRate, 8, 2 ) 
         @  1,64 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         DISPBOX( 3, 1, 24,79, 2 )
         @  3,50 SAY "   O/N       Qty      Cost   "
         ASORT( aPart_,,,{ | x,y | x < y } )
         @  3,00 SAY " "
         AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " ),QQOUT( A ),Breakpoint() } )
         /*
         SCROLL( 3, 0, 24,80 )
         DISPBOX( 3, 1, 21,79, 2 )
         ASORT(aPart_,,,{ | x,y | x < y })
         anum := ACHOICE(  4, 3, 23,77,aPart_,,"AFUNC" )
         */
         IF PressedEsc()
            RETURN NIL
         ENDIF
      ***      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      ***      GOTO nrecno
      ENDIF                        // Empty
      SCROLL(  22, 0, 24,80 )
      DISPBOX( 22, 1, 24,79, 2 )
      nselect := 1
      @ 23, 5      PROMPT "Add Part"
      @ 23,COL()+2 PROMPT "Another JC-"
      @ 23,COL()+2 PROMPT "Edit Parts"
      @ 23,COL()+2 PROMPT "Delete"
      @ 23,COL()+2 PROMPT "Print JC Parts" 
      @ 23,COL()+2 PROMPT "Exit"
      MENU TO nselect
   DO CASE
      CASE nselect == 6 .OR. PressedEsc()
          RETURN NIL
      CASE nselect == 1                // ADD NEW PART
         mpartnum := SPACE( 20 )

          PartFind( mpartnum )

         mpartnum := Part->Partnum
         mcorrect := "N"
         DO WHILE mcorrect == "N"
            SCROLL(  12, 0, 24,80 ) 
            DISPBOX( 12, 1, 22,79, 2 )
            SELECT Labour
            minvno   := Debit->Invno
            nrate    := Part->Trade
            mdesc    := Part->Desc
            ntime    := 0
            nrate    := Part->Trade
            @ 14, 5      SAY "Partnum "+Part->Partnum
            @ 16, 5      SAY "Desc    " GET mdesc PICTURE "@X"
            @ 18, 5      SAY "Qty     " GET ntime PICTURE "9999.99"
            @ 18,COL()+2 SAY "Cost"     GET nrate PICTURE "99999.99"
            @ 18,COL()+2 SAY Part->Unit
            @ 20, 5      SAY "Job Card "+Debit->Invno
      ***         @ 20,COL()+2 SAY "Date"     GET Labour->Date PICTURE "99/99/9999"
             READ
             ApRLock( 3 )
            APPEND BLANK
            Labour->Date    := DATE()
            Labour->Invno   := minvno
            Labour->Rate    := nrate
            Labour->Desc    := mdesc
            Labour->Partnum := Part->Partnum
            UNLOCK
            mcorrect := "Y" 
         ENDDO                                            // mcorrect
         manother := "Y"
         LOOP

     CASE nselect = 2                 // Another
        SELECT Control
         ApRLock( 3 )
        Control->LastRoll := Date()-1
        UNLOCK
      ***     IF SUBSTR( Control->U_Name,1, 4 ) = "META" 
      ***        LabourWo()                   // XLF_QU5
      ***       ELSE
           LabourShan()                 // XLF_QU10 
      ***     ENDIF   
      CASE nselect == 3                    // Edit Labour
         aPart_:={}
         nrecno := 0
         SELECT Labour
         GOTO TOP
         DO WHILE Labour->( !EOF() )
            IF Labour->Partnum = SPACE( 20 )
               SKIP ALIAS Labour
               LOOP
            ENDIF  
            IF Labour->Invno != minvno
               SKIP ALIAS Labour
               LOOP
             ENDIF  
               AADD( aPart_,Labour->Partnum;
                         +" "+SUBSTR( Labour->Desc, 1,29 );
                         +" "+STR( Labour->Time, 8, 2 );
                         +" "+STR( Labour->Rate, 8, 2 );
                         +" "+Labour->Codeno;
                         +" "+Labour->Invno;
                         +"        "+STR( RECNO(), 6 ) ) 
                 SKIP ALIAS Labour
             ENDDO                        // Labour EOF
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @  1,10 SAY mcodeno+" "+minvno 
         @  1,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         SCROLL( 3, 0, 24,80 )
         DISPBOX( 3, 1, 24,79, 2 )
         ASORT(aPart_,,,{ | x,y | x < y })
         anum := ACHOICE(  4, 3, 23,77,aPart_,,"AFUNC" )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         mcodeno := Labour->Codeno
      ENDIF                        // Empty
         mcorrect := "N"
         DO WHILE mcorrect == "N"
            SELECT Labour
             ApRLock( 3 )
            SCROLL(  10, 0, 24,80 ) 
            DISPBOX( 10, 1, 19,79, 2 )
            @ 12, 6      SAY "Desc"     GET Labour->Desc    PICTURE "@X"
    ***        @ 13,11                     GET Labour->Message PICTURE "@KX"
            @ 14, 6      SAY "Qty"      GET Labour->Time    PICTURE "9999.99"
            @ 14,COL()+2 SAY "Cost"     GET Labour->Rate    PICTURE "9999.99"
            @ 14,COL()+2 SAY "Part"     GET Labour->Partnum PICTURE "@!"
            @ 16, 6      SAY "Invno"    GET Labour->Invno   PICTURE "@!"
            @ 16,COL()+2 SAY "Name O/N" GET Labour->Codeno  PICTURE "@!"
             READ
            UNLOCK
            mcorrect := ApGetY( Message->Correct )
         ENDDO                                            // mcorrect
         manother := "Y"
         LOOP

     CASE nselect = 4                 // Delete
         aPart_:={}
         nrecno := 0
         SELECT Labour
         GOTO TOP
         DO WHILE Labour->( !EOF() )
            IF Labour->Partnum = SPACE( 20 )
               SKIP ALIAS Labour
               LOOP
            ENDIF  
            IF Labour->Invno != minvno
               SKIP ALIAS Labour
               LOOP
             ENDIF  
               AADD( aPart_,Labour->Partnum;
                         +" "+SUBSTR( Labour->Desc, 1,29 );
                         +" "+STR( Labour->Time, 8, 2 );
                         +" "+STR( Labour->Rate, 8, 2 );
                         +" "+Labour->Invno;
                         +"        "+STR( RECNO(), 6 ) ) 
                 SKIP ALIAS Labour
             ENDDO                        // Labour EOF
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @ 1,10 SAY mcodeno+" "+minvno 
         SCROLL( 3, 0, 24,80 )
         DISPBOX( 3, 1, 24,79, 2 )
         ASORT(aPart_,,,{ | x,y | x < y })
         anum := ACHOICE(  4, 3, 23,77,aPart_,,"AFUNC" )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         minvno := Labour->Invno
      ENDIF                        // Empty
            SCROLL(  10, 0, 24,80 ) 
            DISPBOX( 11, 1, 19,79, 2 )
            @ 12, 8      SAY "Desc  "+Labour->Desc
            @ 14, 8      SAY "Qty "+STR( Labour->Time )
    ***        @ 14,COL()+2 SAY "Rate "+STR( Labour->Rate )
            @ 14,COL()+2 SAY Labour->Codeno
      *** +" Staff "
      *** +STR( Name->Rate,8,2 )
            @ 16, 8      SAY "Invno "+Labour->Invno
            @ 16,COL()+2 SAY "Staff "+Labour->Codeno
             READ
         mdelete := ApGetN( TRIM( Message->Delete )+" Labour" )
         IF mdelete == "Y"
            SELECT Labour
             ApRLock( 3 )         
            DELETE
            UNLOCK
   /*
            mdelete := ApGetN( "Delete ALL FOR INVOICE" )
            IF mdelete == "Y"
                ApFLock( 3 )         
               DELETE ALL FOR Labour->Invno = minvno
               UNLOCK
            ENDIF
   */
         ENDIF
         manother := "Y"
         LOOP

     CASE nselect = 5                 // Print Parts
     SELECT Name 
     SEEK mcodeno
   SCROLL()
   DISPBOX( 0, 1,18,79, 2 )
   @  1,10 SAY "Labour Analysis  "+minvno
   @  1,58 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
              +STR( YEAR(DATE() ),5 )
   mprint := ApGetN( "Do You Want Hours" )
   mwhere   := "S"

     Printsel( mwhere )

   nl := 0
   IF mwhere == "P"
      npl := 55
    ELSE
      SCROLL()
      npl := 22
   ENDIF
   @  0, 0 SAY Control->U_Name
   @  0,60 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
   @  2,20 SAY Name->Name 
   @  4, 5 SAY Debit->Invno+"  "+Debit->Est  
   nl := 5
      nTimeTotal:= nLabour := 0
      SELECT Labour
      GOTO TOP
      DO WHILE Labour->( !EOF() )
         IF mprint ="N"
            IF Labour->Partnum = SPACE( 20 )
               SKIP ALIAS Labour
               LOOP
            ENDIF
         ENDIF  
         IF Labour->Invno != minvno
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF nl > npl
            IF mwhere == "P"
               EJECT
              ELSE
               WAIT
               SCROLL()
             ENDIF                       // mwhere = P
            @  0, 0 SAY Control->U_Name
            @  0,60 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ),5 )
            @  2,20 SAY Name->Name 
            @  4,10 SAY Debit->Invno+"  "+Debit->Est  
            nl := 5
         ENDIF                           // nl>npl  
         IF Labour->Partnum != SPACE( 20 )
            @ nl, 0 SAY SUBSTR( Labour->Partnum, 1,16 )
            nTimeTotal += Labour->Time*Labour->Rate
           ELSE
            @ nl, 0 SAY Labour->Codeno
            nLabour += Labour->Time
         ENDIF
         @ nl,17 SAY SUBSTR( Labour->Desc, 1,31 )
         IF Labour->Partnum != SPACE( 20 ) 
            @ nl,50 SAY Labour->Codeno
         ENDIF
         @ nl,58 SAY Labour->Time PICTURE "9,999.99"
         @ nl,68 SAY Labour->Rate PICTURE "9,999.99"
         nl++
         SKIP ALIAS Labour
      ENDDO                // EOF Labour
   @ nl,66 SAY "------------"
   nl++
   @ nl, 4 SAY "Labour"
   @ nl,11 SAY nLabour    PICTURE "$999,999.99"
   @ nl,36 SAY minvno+" Total Parts Cost"
   @ nl,65 SAY nTimeTotal PICTURE "$999,999.99"
   nl++
   @ nl,66 SAY "============"
   nl++
   IF mwhere = "P"
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
         manother := "Y"
         LOOP
     ENDCASE
     manother := ApGetY( Message->Another )
   ENDDO               // Another

   RETURN NIL
   ****----- End of LabInvP()

   ****--------------------------------------------------------------------------

STATIC FUNCTION QuotFormA( mcodeno, minvno )

   nl:= ntotal:= ngtotal:= nweight := 0
   SELECT Quot
   GOTO TOP
   SEEK mcodeno
   IF mwhere == "P"
      SET DEVICE TO PRINT
      @  0, 0 SAY P_PL51
      nl := QuotHd( mcodeno, minvno )
     ELSE
      IF msecond = "Y"
         RETURN NIL
      ENDIF
      nl := QuotHd( mcodeno, minvno )                    // Below
   ENDIF
   DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
      IF Quot->Invno != minvno
         SKIP ALIAS Quot
         LOOP
      ENDIF 
      IF mwhere = "P" .AND. nl >= 39              // Adjust no of items
      ***      @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
         SET DEVICE TO SCREEN
         @ 12,10 SAY " "
         @ 14,10 SAY "ALIGN PAPER to TOP OF PAGE"
         @ 16,10 SAY " WAIT FOR PRINTER TO STOP"
         INKEY( 0 )
         SET DEVICE TO PRINT
         @  0, 0 SAY P_PL51
         nl := QuotHd()                 // Below
         ELSEIF ROW() >= 22
          WAIT
          SCROLL()
    ***      nl := QuotHd( mcodeno, minvno )
          nl := 0
      ENDIF                                // mwhere
      ***   mpartnum := Quot->Partnum
      IF Quot->Partnum != SPACE( 20 )
         SELECT Part
         SEEK Quot->Partnum
         @ nl, 3 SAY Part->Desc
         SELECT Quot
         @ nl,42 SAY Quot->Qty              PICTURE "9,999.99"
         @ nl,50 SAY Quot->Amount           PICTURE "999,999.99"
         IF Quot->Discount > 0
            @ nl,61 SAY STR( Quot->Discount,2 )+" %"
         ENDIF
         mA := ( Quot->Amount*( 1-Quot->Discount/100 )*100 ) /100.00
         @ nl,66 SAY mA*Quot->Qty           PICTURE "999,999.99"
         nl++
   /*
         IF Part->Detail != SPACE( 43 )
            @ nl, 3 SAY Part->Detail
            nl++
         ENDIF
         IF Part->Detail1 != SPACE( 43 )
            @ nl, 3 SAY Part->Detail1
            nl++
         ENDIF
         IF Part->Detail2 != SPACE( 43 )
            @ nl, 3 SAY Part->Detail2
            nl++
         ENDIF
         IF Part->Detail3 != SPACE( 43 )
            @ nl, 3 SAY Part->Detail3
            nl++
         ENDIF
   */
         IF Quot->Info != SPACE( 45 )
            @ nl, 3 SAY Quot->Info
            nl++
         ENDIF
         IF Quot->Info2 != SPACE( 45 )
            @ nl, 3 SAY Quot->Info2
            nl++
         ENDIF
         IF Quot->Info3 != SPACE( 45 )
            @ nl, 3 SAY Quot->Info3
            nl++
         ENDIF
         IF Quot->Info4 != SPACE( 45 )
            @ nl, 3 SAY Quot->Info4
            nl++
         ENDIF
         IF Quot->Info5 != SPACE( 45 )
            @ nl, 3 SAY Quot->Info5
            nl++
         ENDIF
         IF Quot->Info6 != SPACE( 45 )
            @ nl, 3 SAY Quot->Info6
            nl++
         ENDIF
         IF Quot->Info7 != SPACE( 45 )
            @ nl, 3 SAY Quot->Info7
            nl++
         ENDIF
         IF Quot->Info8 != SPACE( 45 )
            @ nl, 3 SAY Quot->Info8
            nl++
         ENDIF
         IF Quot->Info9 != SPACE( 45 )
            @ nl, 3 SAY Quot->Info9
            nl++
         ENDIF
         ngtotal += mA*Quot->Qty
         ntotal  += Quot->Amount*Quot->Qty            
         SELECT Cusnotes
         cdetail := ""
         coderef := Quot->Partnum
         SEEK coderef
         IF FOUND()
            nl++  
            @ nl, 0 SAY ""
             Getdets( coderef )                           // XF_Memo2
             FormP( cdetail,60,10 )                       // XF_Memo2
         ENDIF                          // Found()
      ENDIF                                        // Partnum
      SELECT Quot
      SKIP ALIAS Quot
   ENDDO
   SELECT Quot
      *** SET ORDER TO 1
      SELECT Cusnotes
       cdetail := ""
       coderef := Debit->Invno
       SEEK coderef
       IF FOUND()
          nl++  
          @ nl, 0 SAY ""
           Getdets( coderef )                           // XF_Memo2
           FormP( cdetail,60,10 )                       // XF_Memo2
      ENDIF                          // Found()
   IF mwhere == "P"
      IF ( ntotal-ngtotal ) > 0
         @ 49,36 SAY "Discount ="
         @ 49,48 SAY ntotal-ngtotal PICTURE "$99,999.99"
      ENDIF                        // ndisctotal
      @ 50, 3 SAY Control->Con_Note6
      @ 50,56 SAY "Sub-total"
      @ 50,68 SAY ngtotal PICTURE "999,999.99"
      ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
      mA := ( ngtotal+ngsttot )
      @ 51, 3 SAY Control->Con_Note7
      @ 51,56 SAY "Plus GST"
      @ 51,68 SAY ngsttot PICTURE "999,999.99"
      @ 52, 3 SAY Control->Con_Note8
      @ 52,66 SAY "------------"
      @ 53, 3 SAY Control->Con_Note9
      @ 53,56 SAY "Total"
      @ 53,67 SAY mA PICTURE "$999,999.99"
      @ 54, 3 SAY Control->Con_Note10
      @ 54,66 SAY "============"
      @ 55, 3 SAY Control->Con_Note11
      @ 56, 3 SAY Control->Con_Note12
   /*
   TAKEN OUT NOT SURE IF NEEDED
      SELECT Debit
       ApRLock( 3 )
      Debit->Amount   := mA
      Debit->InitAmnt := mA
      UNLOCK
   */
      @  0, 0 SAY P_RESET
      ***   @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
      ***   EJECT
      SET PRINTER TO
      SET DEVICE TO SCREEN
     ELSE
      IF nl > 10
         WAIT
         SCROLL( 10, 0, 24,80 )
         nl := 11
      ENDIF
      IF ( ntotal-ngtotal ) > 0
         @ nl,30 SAY "Total Discount ="
         @ nl,50 SAY ntotal-ngtotal PICTURE "$99,999.99"
         nl++
      ENDIF                        // ndisctotal
      @ nl,30 SAY "Sub-total"
      @ nl,50 SAY ngtotal PICTURE "999,999.99"
      nl++
      ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
      mA := ( ngtotal+ngsttot )
      @ nl,30 SAY "Plus GST"
      @ nl,50 SAY ngsttot PICTURE "999,999.99"
      nl++
      @ nl,50 SAY "------------"
      nl++
      @ nl,30 SAY "Total"
      @ nl,50 SAY mA PICTURE "$999,999.99"
      nl++
      @ nl,50 SAY "============"
      nl++
      @ nl, 3 SAY Control->Con_Note6
      nl++
      @ nl, 3 SAY Control->Con_Note7
      nl++
      @ nl, 3 SAY Control->Con_Note8
      nl++
      @ nl, 3 SAY Control->Con_Note9
      nl++
      @ nl, 3 SAY Control->Con_Note10
      nl++
      @ nl, 3 SAY Control->Con_Note11
      nl++
      @ nl, 3 SAY Control->Con_Note12
      nl++
   ENDIF

   RETURN NIL

   *** End of QuotFormA()

   **-------------------------------------------------------------------

STATIC FUNCTION QuotHd( mcodeno, minvno )

   IF mwhere == "P"
      nl := 6
      ***   @ nl, 3 SAY "-------------------------------------------------------------------------"
      ***   nl++
    ELSE
      nl := 0
   ENDIF
   IF msecond != "Y"
      @ nl,30 SAY "Quotation No. "+Debit->Invno
     ELSE
      @ nl,25 SAY "OFFICE COPY Quote No. "+Debit->Invno
   ENDIF
   nl++
   @ nl, 3 SAY "-------------------------------------------------------------------------"
   nl+=2 
   @ nl, 3 SAY Name->Name                // This is Company Name
   @ nl,55 SAY "Date :"
   @ nl,62 SAY Debit->Dbdate PICTURE "99/99/9999"
   nl++
   @ nl, 3 SAY Name->Add1
   ***   @ nl,45 SAY "Delivery Address"
   nl++
   @ nl, 3 SAY Name->Add2
   ***   @ nl,45 SAY Debit->Deladd1
   nl++
   @ nl, 3 SAY Name->Add3
   ***   @ nl,45 SAY Debit->Deladd2
   nl++
   @ nl, 3 SAY Name->Add4
   IF Name->Phone != SPACE(15)
      @ nl,24 SAY Name->Phone                // Business Phone
      @ nl,40 SAY Name->BPhone               // Fax Phone
    ELSE
      @ nl,24 SAY Name->EPhone                // Home Phone
   ENDIF
   ***   @ nl,45 SAY Debit->Deladd3
   nl+=2
   @ nl, 3 SAY "Client Ref : "+Debit->Ordnum
   ***   @ nl,54 SAY "G.S.T. No : "+Control->U_GSTno
   ***   nl++
   ***   @ nl, 3 SAY "========================================================================="
   nl++
   @ nl, 3 SAY "Description"
   ***   @ nl,38 SAY "Details           Rate" 
   @ nl,71 SAY "Price"
   nl++
   @ nl, 3 SAY "-------------------------------------------------------------------------"
   nl+=2

   RETURN nl

   ***** End QuotHd

   **-------------------------------------------------------------------

STATIC FUNCTION QuotForm( mcodeno, minvno )

   SCROLL(  0, 0,  2,80 )
   DISPBOX( 0, 1,  2,79, 2 )
   SCROLL( 18, 0, 24,80 )
   DISPBOX( 3, 1, 24,79, 2 )
   @  1, 4 SAY Name->Name+" "+Name->Add1+" "+Debit->Invno
   @ 12,12 SAY "The Memo is Specific to this Quote"
   SELECT Cusnotes
   coderef := minvno
   SEEK coderef
    M2MemoFile( coderef )                      // XF_Memo2
   @ 12,10 SAY SPACE( 50 )
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
   ENDIF                  // mok
   */
   SCROLL(   3, 0, 12,80 )
   SCROLL(  23, 0, 24,80 )
   DISPBOX(  3, 1, 24,79, 2 )
   SELECT Control
    ApRLock( 3 )
   @  4,10 SAY "All Quotes use the following"
   @  5, 5 GET Control->Con_note6  PICTURE "@X"
   @  6, 5 GET Control->Con_note7  PICTURE "@X"
   @  7, 5 GET Control->Con_note8  PICTURE "@X"
   @  8, 5 GET Control->Con_note9  PICTURE "@X"
   @  9, 5 GET Control->Con_note10 PICTURE "@X"
   @ 10, 5 GET Control->Con_note11 PICTURE "@X"
   @ 11, 5 GET Control->Con_note12 PICTURE "@X"
    READ
   UNLOCK
   mwhere := "S"
   npl    := 65
    Printsel( mwhere )                    // _LF_Init
   nl := 0
   IF mwhere == "P"
      npl := 65
     ELSE
      npl := 18
   ENDIF
   msecond := "N"
     QuotFormA( mcodeno, minvno )                  // Above 
   msecond := "Y"
   ***   WAIT
   ****     QuotFormA( mcodeno, minvno )

   RETURN NIL

   *** End of QuotForm()

   ***----------------------- End of XLF_QU3.PRG

