   ***  JoKir  30-09-11 22:25:46 
*** Part->ABC

/*
   Program.....:                  XLF_QUOT.PRG
   Authors.....: J.Kirby
   Date........: 05/10/1995
   Functions...: ModWoCost, QuotSearch, QuoLook, WoHouCost
                 EquModule, Mu_Quot, QuotEdit, QPuotOperLst
   Not used....: WoView

   INVOICE BASIS  WORK ORDERS
*/

FUNCTION ModWoCost()

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      mmodcode := Equ->ModCode
      SCROLL()   
      aPart_ := {}
      anum   := {}
      nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
      nqty1:= nqty2:= nqty3:= nqty4 := 0
      nequ1:= nequ2:= nequ3:= nequ4 := 0
      nquot := Equ->PartQty
      SELECT Part
      SEEK mmodcode
      DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !EOF() )
         AADD( aPart_,STR( nquot,10, 3 );
            +" "+STR( Part->Trade, 9, 2 );
            +" "+Part->Desc;
            +" "+Equ->Partnum;
            +"          "+STR( nequ1 ) )           // SO can't Find
         mmod1 := TRIM( Equ->Partnum )
         SELECT Equ
         GOTO TOP
         ***      SET EXACT ON
         SEEK mmod1
         IF FOUND()   
            DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
               ***      AADD( aPart_," " )
               nqty1 := nquot*Equ->PartQty
               SELECT Part
               SEEK Equ->Partnum
               SELECT Equ
               AADD( aPart_,".   "+SUBSTR( Equ->Modcode, 1,15 )+" "+STR( nqty1, 9, 3 );
                  +" "+SUBSTR( Part->Desc, 1,29 );
                  +" "+STR( Equ->Partqty, 8, 3 );
                  +" "+STR( Part->Trade, 8, 2 );
                  +"        "+STR( RECNO(),6 ) )
               SELECT Equ
               mmod2 := TRIM( Equ->Partnum )
               nrecno2 := RECNO() 
               GOTO TOP
               SEEK mmod2
               IF FOUND()   
                  ***         AADD( aPart_," " )
                  DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
                     nqty2 := Equ->PartQty
                     nequ2 := ( nqty1 * nqty2 )* nquot
                     SELECT Part
                     SEEK Equ->Partnum
                     SELECT Equ
                     AADD( aPart_,"..  "+SUBSTR( Equ->Modcode, 1,15 )+" "+STR( nequ2, 9, 3 );
                        +" "+SUBSTR( Part->Desc, 1,29 );
                        +" "+STR( Equ->Partqty, 8, 3 );
                        +" "+STR( Part->Trade, 8, 2 );
                        +"        "+STR( RECNO(),6 ) )

                     SELECT Equ
                     mmod3 := TRIM( Equ->Partnum )
                     nrecno3 := RECNO() 
                     GOTO TOP
                     SEEK mmod3
                     IF FOUND()   
                        ***         AADD( aPart_," " )
                        DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
                           nqty3 := Equ->PartQty
                           nequ3 := nqty1 * nqty2 * nqty3 * nquot
                           SELECT Part
                           SEEK Equ->Partnum
                           SELECT Equ
                           AADD( aPart_,"... "+SUBSTR( Equ->Modcode, 1,15 )+" "+STR( nequ3, 9, 3 );
                              +" "+SUBSTR( Part->Desc, 1,29 );
                              +" "+STR( Equ->Partqty, 8, 3 );
                              +" "+STR( Part->Trade, 8, 2 );
                              +"        "+STR( RECNO(),6 ) )
                           SELECT Equ
                           mmod4   := TRIM( Equ->Partnum )
                           nrecno4 := RECNO()
                           GOTO TOP
                           SEEK mmod4
                           IF FOUND()
                              ***            AADD( aPart_," " )
                              DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                                 nqty4 := Equ->PartQty
                                 nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
                                 SELECT Part
                                 SEEK Equ->Partnum
                                 SELECT Equ
                                 AADD( aPart_,"...."+SUBSTR( Equ->Modcode, 1,15 )+" "+STR( nequ4, 9, 3 );
                                    +" "+SUBSTR( Part->Desc, 1,29 );
                                    +" "+STR( Equ->Partqty, 8, 3 );
                                    +" "+STR( Part->Trade, 8, 2 );
                                    +"        "+STR( RECNO(),6 ) )
                                 SELECT Equ 
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
            ENDDO                       //   mmod1 EOF()
         ENDIF                          // Found mmod1
         IF !EMPTY( aPart_ )
            SET EXACT OFF      
            DISPBOX(  2, 1, 24,79, 2 )
            @  2,20 SAY "*  Mod Qty  "
            @  2,60 SAY "   Qty       Cost  "
            ***      ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE( 3, 2, 23,78, aPart_,,"AFUNC" )
            IF PressedEsc()
               EXIT
            ENDIF
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            SELECT Equ
            IF nrecno != 0
               GOTO nrecno
            ELSE
               GOTO nrecno2
            ENDIF 
            mmodcode := Equ->ModCode
            SELECT EquDesc
            SEEK Equ->Modcode
            IF FOUND()
               tempscrn := SAVESCREEN( 0, 0, 24,80 )
               EquSearch( @mmodcode )               // XLF_Equ3 
               RESTSCREEN(  0, 0, 24,80,tempscrn )
            ENDIF                   // FOUND                                              // mcontinue
            SKIP ALIAS Equ
         ENDIF
      ENDDO        // modcode
      mcontinue := "N" 
   ENDDO
   SELECT Equ
   SEEK cpartorg
   SELECT Part
   SEEK cpartorg

   RETURN NIL
   ******* End of ModWoCost()

   ***-------------------------------------------------------------------

FUNCTION QuotSearch()

   SCROLL()
   mcodeno := SPACE( 8 )
   maction := Control->U_Codeno
   nl := 2

   *** NameAction( @maction, nl )                  // ZSA_Name  

   SELECT Quot
   SET ORDER TO 1                    // Codeno
   IF LASTREC() > 1
      mtempcode := "A       "
      GOTO TOP
      SEEK mtempcode
      IF !FOUND()
          ApFLock( 3 )
         APPEND BLANK
         Quot->Codeno := "A      " 
         Quot->Invno  := "9     "
         UNLOCK
      ENDIF 
      SCROLL( 0, 0, 24,38 )
      DISPBOX( 0, 1, 23,38, 2 )
      @ 24, 3 SAY "F2 To View ALL Job Cards" COLOR "GB+"
      SELECT Debit
      GOTO TOP
      nl:= nll:= nlll := 2
      npl:= npll := 22 
      ccodeno := SPACE( 14 )
      @  0,46 SAY "Jobs to be Invoiced" COLOR "RG+"
      DO WHILE Debit->( !EOF() )
         IF Debit->Stat = "I"
            SKIP ALIAS Debit
            LOOP
         ENDIF
         IF SUBSTR( Debit->Equip, 1, 1 ) != "Y"
            SKIP ALIAS Debit
            LOOP
         ENDIF
         IF Debit->Codeno+Debit->Invno = ccodeno
            SKIP ALIAS Debit
            LOOP
         ENDIF
         DO CASE
            CASE nl <= npl
                @ nl,40   SAY Debit->Codeno+" "+Debit->Invno
                nl++
            CASE nll <= npll
                @ nll,57  SAY Debit->Codeno+" "+Debit->Invno
                nll++
            OTHERWISE
                @ nlll,72 SAY Debit->Codeno+" "+Debit->Invno
                nlll++
         ENDCASE 
         ccodeno := Debit->Codeno+Debit->Invno
         SKIP ALIAS Debit
      ENDDO                          // EOF()
      SELECT Quot
      mcodeno := SPACE( 8 )
      aPart_ := anum:= {}
      nrecno:= ntotal := 0
      GOTO TOP
      mtempno := SPACE( 10 )
      DO WHILE Quot->( !EOF() )
         IF Quot->Invno = SPACE( 6 )
            SKIP ALIAS Quot
            LOOP
         ENDIF
         ntotal += ( Quot->Amount*Quot->Qty ) 
         IF Quot->Codeno+Quot->BranchId = mtempno
            SKIP ALIAS Quot
            LOOP
         ENDIF
         SELECT Name
         SEEK Quot->Codeno
         SELECT Quot
         mtempno := Quot->Codeno+Quot->BranchId
         AADD( aPart_,Name->Name+"  "+Quot->BranchId;
              +"     "+STR( RECNO(),6 ) )
         SKIP ALIAS Quot
      ENDDO
      IF !EMPTY( aPart_ )
         ASORT(aPart_,,,{ | x,y | x < y })
         anum := ACHOICE( 1, 3, 22,36, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         IF LASTKEY() == -1
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
                     +" "+Debit->Equip; 
                     +" "+Debit->Codeno;
                     +" "+Debit->BranchId;
                     +" "+DTOC( Debit->Dbdate );
                     +" "+STR( Debit->Amount,10, 2 )+" "+Debit->Saleno;
                     +" "+Debit->Est+"                        "+STR( RECNO(),6 ) )
                  SKIP ALIAS Debit
               ENDDO
               IF !EMPTY( aPart_ )
                  SCROLL()
                  DISPBOX(  0, 1, 24,79, 2 )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum   := ACHOICE(  1, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
                  nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
                  GOTO nrecno
                  minvno := Debit->Invno
                  mcodeno := Debit->Codeno
               ENDIF                     // Empty
            ENDIF                        // LastRec    
            SELECT Name
            SEEK mcodeno
            ****         Namerank( @mcodeno )                            // ZSF_Name
            IF PressedEsc()
               RETURN NIL
            ENDIF
            mcodeno := Name->Codeno
            cbranchId := SPACE( 2 ) 
            SELECT Branch
            SEEK mcodeno
            IF FOUND()
               SCROLL()
               DISPBOX(  0, 1, 2,79, 2 )
               @  1, 4 SAY Name->Name
                BranchFind( @mcodeno )             // ZSF_Name
               cbranchId := Branch->BranchId
               mok := ApGetY( "Do you Want Branch" )
               IF mok = "N"
                  cbranchId := SPACE( 2 )
               ENDIF
            ENDIF
            QuotAdd( mcodeno, cbranchId )
            QuotSearch()
         ENDIF                 // LastKey = -1
         GOTO nrecno
         IF Quot->Codeno = "A       "
            Namerank( @mcodeno )                            // ZSF_Name
            IF PressedEsc()
               RETURN NIL
            ENDIF
            mcodeno := Name->Codeno
            cbranchId := SPACE( 2 ) 
            SELECT Branch
            SEEK mcodeno
            IF FOUND()
               BranchFind( @mcodeno )             // ZSF_Name
               cbranchId := Branch->BranchId
               mok := ApGetY( "Do you Want Branch" )
               IF mok = "N"
                  cbranchId := SPACE( 2 )
               ENDIF
            ENDIF
            QuotAdd( mcodeno, cbranchId )
            QuotSearch()
         ENDIF                 // Codeno = A
         mcodeno   := Quot->Codeno
         cbranchId := Quot->BranchId
         mfaxno    := Quot->Faxno
         dDbdate   := Quot->DbDate
      ENDIF
      SELECT Name
      SEEK mcodeno
      SELECT Quot
      maccepted := "N"
      ***   maccepted := ApGetN( "Do You Want NOT Accepted Only" )
      ***     QuotEdit( mcodeno )
      IF mcodeno = SPACE( 8 )

         Namerank( @mcodeno )                            // ZSF_Name

         IF PressedEsc()
            RETURN NIL
         ENDIF
         mcodeno   := Name->Codeno
         cbranchId := SPACE( 2 ) 
         SELECT Branch
         SEEK mcodeno
         IF FOUND()
       
             BranchFind( @mcodeno )             // ZSF_Name
            cbranchId := Branch->BranchId

            mok := ApGetY( "Do you Want Branch" )
            IF mok = "N"
               cbranchId := SPACE( 2 )
            ENDIF
         ENDIF
   
      ENDIF                   // Codeno = SPACE( 8 )
      QuotAdd( mcodeno, cbranchId )
   ELSE
      @  7,52 SAY "NO JOB IN FILE   "
      INKEY( 2 )
   ENDIF
   SELECT Quot
   IF mcodeno != SPACE( 8 )
     QuotSearch()
   ENDIF

   RETURN NIL
   ****---- End of QuotSearch()

   **-------------------------------------------------------------------

FUNCTION QuoLook( mcodeno, cbranchId )

   minvno    := Debit->Invno
   mcodeno   := Debit->Codeno
   cbranchid := Debit->BranchId
   ntotal := 0
   aPart_ :={}
   SELECT Quot
   SET ORDER TO 3      // Invno  2  // Codeno+ Partnum
   GOTO TOP
   IF LASTREC() != 0
      SEEK minvno                   // mcodeno
      DO WHILE Quot->Invno = minvno .AND. Quot->( !EOF() )
         IF Quot->Codeno != mcodeno
            SKIP ALIAS Quot
            LOOP
         ENDIF
   /*
         IF cbranchId != SPACE( 2 )
            IF Quot->BranchId != cbranchId
               SKIP ALIAS Quot
               LOOP
            ENDIF
         ENDIF
   */
         mpartnum := Quot->Partnum
         SELECT Part
         SEEK mpartnum
         SELECT Quot
         ntotal += ( ( Quot->Amount*Quot->Qty );
                   *(1-Quot->Discount/100 )*100 ) /100.00
         AADD( aPart_,SUBSTR( Part->Partnum,1,13 );
              +" "+SUBSTR( Part->Desc, 1,28 );
              +" "+STR( Quot->Qty, 8, 2 );
              +" "+STR( Quot->Amount, 9, 2 );
              +" "+STR(  ( ( Quot->Amount*Quot->Qty );
                   *(1-Quot->Discount/100 )*100 ) /100.00, 9, 2 );
              +" "+cbranchid )
        SKIP ALIAS Quot
      ENDDO
      ***           +" "+DTOC( DbDate );
   /*
      SELECT Labour
      GOTO TOP
      nlabour:= nlabrate := 0
      DO WHILE Labour->( !EOF() )
         IF Labour->Invno != minvno
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Partnum = SPACE( 20 )
            nlabour  += Labour->Time
           ELSE
            nlabrate += Labour->Time*Labour->Rate
         ENDIF
         SKIP ALIAS Labour
      ENDDO                        // Labour EOF
   */
      SELECT Quot
      @  1,62 SAY ntotal PICTURE "$9999,999.99" COLOR "G+"
      DISPBOX( 3, 1, 20,79, 2 )
      IF !EMPTY( aPart_ )
      *****  TEST
      *****     ASORT( aPart_,,,{ | x,y | x < y } )
         @  3,00 SAY " "
         AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+" " ),QQOUT(A),Breakpoint() } )
      ENDIF
   /* 
      IF nlabour+nlabrate > 0
         @ 21, 3      SAY minvno+" Time Hrs"
         @ 21,COL()+1 SAY nlabour         PICTURE "9,999.99"      COLOR "BG+"
         @ 21,COL()+1 SAY "Parts"                                 
         @ 21,COL()+1 SAY nlabrate        PICTURE "$999,999.99"   COLOR "BG+"
      ***      @ 21,COL()+1 SAY nlabrate+ntotal PICTURE "$999,999.99"   COLOR "G+"
      ENDIF
   */
      ***   @ 19,18      SAY "Operation "+Debit->Operno COLOR "G+" 
      @ 17,34      SAY "JC + GST"
      @ 17,COL()+1 SAY ntotal*(( Control->GSTRate/100)+1);
                                   PICTURE "$999,999.99" COLOR "G+"
      SELECT Quot
      SEEK Debit->Invno
   ENDIF
   SELECT Quot
   SET ORDER TO 1

   RETURN NIL
   ****---- End of QuoLook()

   ***------------------------------------------------------------------------

FUNCTION WoCost( mcodeno )

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL()   
      minvno := Debit->Invno
      SELECT Quot
      SET ORDER TO 2
      SEEK mcodeno
      @  0, 2 SAY mcodeno
      @  0,20 SAY Name->Name
      @  1, 6 SAY Debit->Message
      @  1,63 SAY "JC- "+minvno
      aPart_ := {}
      anum   := {}
      DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
         IF Quot->Invno != minvno
            SKIP ALIAS Quot
            LOOP
         ENDIF
         nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
         nqty1:= nqty2:= nqty3:= nqty4 := 0
         nequ1:= nequ2:= nequ3:= nequ4 := 0
         nquot := Quot->Qty
         mmod1 := TRIM( Quot->Partnum )
         SELECT Part
         SEEK Quot->Partnum
         AADD( aPart_,STR( nquot, 8, 3 );
                      +" "+STR( Part->Trade,10, 2 );
                      +" "+Part->Desc;
                      +" "+Quot->Partnum;
                      +"         "+STR( nequ1 ) )           // SO can't Find
         SELECT Equ
         GOTO TOP
         SET EXACT ON
         SEEK mmod1
         IF FOUND()   
      DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
      ***      AADD( aPart_," " )
         nqty1 := nquot*Equ->PartQty
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         AADD( aPart_,".   "+SUBSTR( Equ->Modcode, 1,15 )+" "+STR( nqty1, 9, 3 );
                      +" "+SUBSTR( Part->Desc, 1,29 );
                      +" "+STR( Equ->Partqty, 8, 3 );
                      +" "+STR( Part->Trade, 8, 2 );
                      +"        "+STR( RECNO(),6 ) )
         SELECT Equ
         mmod2 := TRIM( Equ->Partnum )
         nrecno2 := RECNO() 
         GOTO TOP
         SEEK mmod2
         IF FOUND()   
      ***         AADD( aPart_," " )
            DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
               nqty2 := Equ->PartQty
               nequ2 := ( nqty1 * nqty2 )* nquot
               SELECT Part
               SEEK Equ->Partnum
         SELECT Equ
         AADD( aPart_,"..  "+SUBSTR( Equ->Modcode, 1,15 )+" "+STR( nequ2, 9, 3 );
                      +" "+SUBSTR( Part->Desc, 1,29 );
                      +" "+STR( Equ->Partqty, 8, 3 );
                      +" "+STR( Part->Trade, 8, 2 );
                      +"        "+STR( RECNO(),6 ) )

         SELECT Equ
         mmod3 := TRIM( Equ->Partnum )
         nrecno3 := RECNO() 
         GOTO TOP
         SEEK mmod3
         IF FOUND()   
      ***         AADD( aPart_," " )
            DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
               nqty3 := Equ->PartQty
               nequ3 := nqty1 * nqty2 * nqty3 * nquot
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         AADD( aPart_,"... "+SUBSTR( Equ->Modcode, 1,15 )+" "+STR( nequ3, 9, 3 );
                      +" "+SUBSTR( Part->Desc, 1,29 );
                      +" "+STR( Equ->Partqty, 8, 3 );
                      +" "+STR( Part->Trade, 8, 2 );
                      +"        "+STR( RECNO(),6 ) )
            SELECT Equ
            mmod4   := TRIM( Equ->Partnum )
            nrecno4 := RECNO()
            GOTO TOP
            SEEK mmod4
            IF FOUND()
      ***            AADD( aPart_," " )
               DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                  nqty4 := Equ->PartQty
                  nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         AADD( aPart_,"...."+SUBSTR( Equ->Modcode, 1,15 )+" "+STR( nequ4, 9, 3 );
                      +" "+SUBSTR( Part->Desc, 1,29 );
                      +" "+STR( Equ->Partqty, 8, 3 );
                      +" "+STR( Part->Trade, 8, 2 );
                      +"        "+STR( RECNO(),6 ) )
                  SELECT Equ 
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
               ENDDO                       //   mmod1 EOF()
            ENDIF                          // Found mmod1
            SET EXACT OFF      
         SELECT Quot
         SKIP ALIAS Quot
         AADD( aPart_," " )
      ENDDO                            //   EOF() Quot
      IF !EMPTY( aPart_ )
         DISPBOX(  2, 1, 24,79, 2 )
          @  2,20 SAY " Mod Qty. "
          @  2,60 SAY "   Qty      Cost  "
      ***      ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 3, 2, 23,78, aPart_,,"AFUNC" )
         IF PressedEsc()
            EXIT
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         SELECT Equ
         IF nrecno != 0
            GOTO nrecno
           ELSE
            GOTO nrecno2
         ENDIF 
         mmodcode := Equ->ModCode
         SELECT EquDesc
         SEEK Equ->Modcode
         IF FOUND()
            tempscrn := SAVESCREEN( 0, 0, 24,80 )
             EquSearch( @mmodcode )               // XLF_Equ3 
            RESTSCREEN(  0, 0, 24,80,tempscrn )
         ENDIF                   // FOUND                                              // mcontinue
      ENDIF
      mcontinue := "N" 
   ENDDO

   SELECT Quot
   SET ORDER TO 1

   RETURN mcodeno

   ******* End of WoCost()

   ***-------------------------------------------------------------------

FUNCTION WoView( mcodeno )

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL()   
      nGrandTot:= nlabpart := ntrade := 0
      minvno := Debit->Invno
      SELECT Quot
      SET ORDER TO 2
      SEEK mcodeno
      @  0, 2 SAY mcodeno
      @  0,20 SAY Name->Name
      @  1, 6 SAY Debit->Message
      @  1,63 SAY "Job # "+minvno
      aPart_ := {}
      anum   := {}
      DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
         IF SUBSTR( Quot->Invno, 3, 4 ) != SUBSTR( minvno, 3, 4 )
            SKIP ALIAS Quot
            LOOP
         ENDIF
         nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
         nqty1:= nqty2:= nqty3:= nqty4 := 0
         nequ1:= nequ2:= nequ3:= nequ4 := 0
         nquot := Quot->Qty
         mmod1 := TRIM( Quot->Partnum )
         SELECT Part
         SEEK Quot->Partnum
         nGrandTot += Quot->Qty*Part->Trade
         AADD( aPart_,SUBSTR( Quot->Partnum, 1,16 );
                 +" "+SUBSTR( Part->Desc, 1,26 );
                 +" "+STR( nquot, 8, 2 );
                 +" "+STR( Quot->Amount, 8, 2 );
                 +" "+STR( Part->Trade, 8, 2 );
                 +" "+Quot->Invno )
         IF Quot->Partnum = Message->LabPart
            nlabpart := Quot->Qty
         ENDIF 
         SELECT Equ
         GOTO TOP
         SET EXACT ON
         SEEK mmod1
         IF FOUND()   
      DO WHILE Equ->Modcode = mmod1.AND. Equ->( !EOF() )
      ***      AADD( aPart_," " )
         nqty1 := nquot*Equ->PartQty
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         AADD( aPart_,".   "+STR( nqty1, 9, 2 );
                        +" "+SUBSTR( Part->Partnum, 1,16 );
                        +" "+SUBSTR( Part->Desc, 1,37 );
                        +" "+STR( Equ->Partqty, 8, 2 );
                        +"        "+STR( RECNO(),6 ) )
         IF Equ->Partnum = Message->LabPart
            nlabpart += nqty1
         ENDIF 
         ntrade += nqty1*Part->Trade
         SELECT Equ
         mmod2 := TRIM( Equ->Partnum )
         nrecno2 := RECNO() 
         GOTO TOP
         SEEK mmod2
         IF FOUND()   
      ***         AADD( aPart_," " )
            DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
               nqty2 := Equ->PartQty
               nequ2 := ( nqty1 * nqty2 )* nquot
               SELECT Part
               SEEK Equ->Partnum
         SELECT Equ
         AADD( aPart_,"..  "+STR( nequ2, 9, 2 );
                        +" "+SUBSTR( Part->Partnum, 1,16 );
                        +" "+SUBSTR( Part->Desc, 1,37 );
                        +" "+STR( Equ->Partqty, 8, 2 );
                        +"        "+STR( RECNO(),6 ) )
         IF Equ->Partnum = Message->LabPart
            nlabpart += nequ2
         ENDIF 
         ntrade += nqty2*Part->Trade
         SELECT Equ
         mmod3 := TRIM( Equ->Partnum )
         nrecno3 := RECNO() 
         GOTO TOP
         SEEK mmod3
         IF FOUND()   
      ***         AADD( aPart_," " )
            DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
               nqty3 := Equ->PartQty
               nequ3 := nqty1 * nqty2 * nqty3 * nquot
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         AADD( aPart_,"... "+STR( nequ3, 9, 2 );
                        +" "+SUBSTR( Part->Partnum, 1,16 );
                        +" "+SUBSTR( Part->Desc, 1,37 );
                        +" "+STR( Equ->Partqty, 8, 2 );
                        +"        "+STR( RECNO(),6 ) )
         IF Equ->Partnum = Message->LabPart
            nlabpart += nequ3
         ENDIF 
         ntrade += nqty3*Part->Trade
           SELECT Equ
            mmod4   := TRIM( Equ->Partnum )
            nrecno4 := RECNO()
            GOTO TOP
            SEEK mmod4
            IF FOUND()
      ***            AADD( aPart_," " )
               DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                  nqty4 := Equ->PartQty
                  nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         AADD( aPart_,"...."+STR( nequ4, 9, 2 );
                        +" "+SUBSTR( Part->Partnum, 1,16 );
                        +" "+SUBSTR( Part->Desc, 1,37 );
                        +" "+STR( Equ->Partqty, 8, 2 );
                        +"        "+STR( RECNO(),6 ) )
               IF Equ->Partnum = Message->LabPart
                  nlabpart += nequ4
               ENDIF 
               ntrade += nqty4*Part->Trade
                  SELECT Equ 
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
               ENDDO                       //   mmod1 EOF()
            ENDIF                          // Found mmod1
            SET EXACT OFF      
         SELECT Quot
         SKIP ALIAS Quot
      ***      AADD( aPart_," " )    // SPACE
      ENDDO                            //   EOF() Quot
      SELECT Labour
      GOTO TOP
      nlabour:= nlabrate := 0
      DO WHILE Labour->( !EOF() )
         IF SUBSTR( Labour->Invno, 3, 4 ) != SUBSTR( minvno, 3, 4 )
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Partnum = SPACE( 20 )
            nlabour  += Labour->Time
          ELSE
            nlabrate += Labour->Time*Labour->Rate
         ENDIF
      ***      nquot := Labour->Time
         AADD( aPart_,Labour->Codeno;
                      +" "+Labour->Desc;
                      +" "+STR( Labour->Time, 9, 2 );
                      +" "+STR( Labour->Rate, 9, 2 );
                      +" "+Labour->Invno )
         SKIP ALIAS Labour
      ENDDO                            // EOF Labour
      IF !EMPTY( aPart_ )
         @ 23, 2      SAY TRIM( Message->LabPart )
         @ 23,COL()+1 SAY nlabpart             PICTURE "99,999.99"
         @ 23,COL()+2 SAY "Module Parts" 
         @ 23,COL()+1 SAY ntrade               PICTURE "999,999.99"
         @ 24, 6      SAY "Time"
         @ 24,COL()+1 SAY nlabour              PICTURE "99,999.99"
         @ 24,COL()+2 SAY "Issued Parts" 
         @ 24,COL()+1 SAY nLabrate             PICTURE "$999,999.99"
         @ 24,COL()+2 SAY "JC-Part Cost" 
         @ 24,COL()+1 SAY nGrandTot            PICTURE "$999,999.99"  // took out nlabrate
         DISPBOX(  2, 1, 22,79, 2 )
         ***      ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 3, 2, 21,78, aPart_,,"AFUNC" )
         IF PressedEsc()
            EXIT
         ENDIF
      ENDIF
      mcontinue := "N" 
   ENDDO

   SELECT Quot
   SET ORDER TO 1

   RETURN mcodeno

   ******* End of WoView()

   ***-------------------------------------------------------------------

FUNCTION EquModule( mmodcode )

   SELECT EquDesc
   SET ORDER TO 1   
   GOTO TOP
   SEEK mmodcode
   csyscode := SPACE( 7 )
   cpartorg := mpartnum  
   mmodcode := TRIM( mpartnum )
   SELECT EquDesc
   GOTO TOP
   SEEK mmodcode
   IF FOUND()
     mmodcode := EquDesc->Modcode
    ELSE
      CWPscrn := SAVESCREEN( 0, 0, 24,80 )
      SCROLL( 5, 2, 18,78 )
      csyscode := mpartnum
      mok := ApGetY( "Do You Want to ADD Module" )
      IF mok = "Y"      
          ApFLock( 3 )
         APPEND BLANK
         EquDesc->ModCode := TRIM( Part->Partnum )
         EquDesc->Desc    := Part->Desc
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

          EquSearch( mmodcode )

         RESTSCREEN( 11, 0, 24,80, CWPscrn )
      ENDIF                 // mok
      SELECT Part
      SEEK csyscode
      mpartnum := Part->Partnum
      mmodcode := EquDesc->Modcode
   ENDIF                      // Found
   SELECT EquDesc
   SET ORDER TO 1
   SEEK mmodcode
   mmodcode := EquDesc->Modcode
   ntotal:= nwholesale := 0

    EquSearch( @mmodcode )

   RETURN NIL
   ***-------- End of EquModule()

   ****-------------------------------------------------------------------------

FUNCTION Mu_Quot( nc, ncl )

   DO WHILE .T.
      nselect := 0
      nc      := ncl*2
      SCROLL(  3,nc, 21,78 )
      DISPBOX( 4,nc, 21,nc+ncl )
      SCROLL(  3,nc+2, 5,nc+( ncl-2 ) )
      DISPBOX( 3,nc+2, 5,nc+( ncl-2 ) )
      @  4,nc+( ncl/2 )-( LEN( RTRIM( Menu2->CH_QuotHd ) )/2 );
                           SAY RTRIM( Menu2->CH_QuotHd )
      @  7,nc+2 PROMPT "1. Job Cards        "
      @  9,nc+2 PROMPT "2. Job Card     Edit"
      @ 10,nc+2 PROMPT "3. Job Card     List"
      @ 12,nc+2 PROMPT "4. JC- by Start Date"
      @ 14,nc+2 PROMPT "5. .... Part by Desc"
      @ 15,nc+2 PROMPT "6. ....     Analysis"
      @ 16,nc+2 PROMPT "7. Part - Name List "
      @ 17,nc+2 PROMPT "8. PLANNING    MENU "
      @ 18,nc+2 PROMPT "9. Parts  Cost Sell "
      @ 20,nc+2 PROMPT Menu->CH_Main
      nc := ncl 
      MENU TO nselect

      DO CASE
         CASE nselect == 10 .OR. PressedEsc()
            EXIT
         CASE nselect == 1
            SAVE SCREEN TO Invscrn
              QuotSearch()                             // Below
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 2                             // Add  Edit
            SAVE SCREEN TO Invscrn
            mcodeno := SPACE( 8 )
             Namerank( @mcodeno )                      // ZSF_Name
            IF PressedEsc()
               RETURN NIL
            ENDIF
            mcodeno := Name->Codeno
            cbranchId := SPACE( 2 ) 
            SELECT Branch
            SEEK mcodeno
            IF FOUND()
               SCROLL()
               DISPBOX( 0, 1, 2,79, 2 )
               @  1, 4 SAY Name->Name
                BranchFind( @mcodeno )                // ZSF_Name
               cbranchId := Branch->BranchId
               mok := ApGetY( "Do you Want Branch" )
              IF mok = "N"
                 cbranchId := SPACE( 2 )
              ENDIF
            ENDIF
              Quotadd( mcodeno, cbranchId )               // Below
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 3
            SAVE SCREEN TO Invscrn
              QuotList()                               // XF_QList
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 4
            SAVE SCREEN TO Invscrn
              QuotStart()                              // XF_QList
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 5
            SAVE SCREEN TO Invscrn
              QuotDesc()                               // XF_QList
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 6
            SAVE SCREEN TO Invscrn
              QuotProf()                               // Below
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 7
            SAVE SCREEN TO Invscrn
              QPartSearch()                            // QuotPart
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 8
            SAVE SCREEN TO Invscrn
              Mu_Job( nc,ncl ) 
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 9
            SAVE SCREEN TO Invscrn
              PartCsell() 
            RESTORE SCREEN FROM Invscrn
      ENDCASE
   ENDDO

   RETURN NIL

   ***** End of Mu-Quot

   ***-------------------------------------------------------------------

FUNCTION QuotEdit( mcodeno )
 
   mpartnum := SPACE( 20 )
   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      aPart_ :={}
      nrecno:= ntotal := 0
      SELECT Quot
      SET ORDER TO 2
      GOTO TOP
      SEEK mcodeno
      DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
   /*
   DO NOT USE 
         IF Quot->BranchId != cbranchId
            SKIP ALIAS Quot
            LOOP
         ENDIF
   */
         IF Quot->Invno != Debit->Invno     // was minvno
            SKIP ALIAS Quot
            LOOP
         ENDIF
         SELECT Part
         SET ORDER TO 1                    // Partnum
         SEEK Quot->Partnum
         SELECT Equ
      ***      SET EXACT ON
         mmod1 := TRIM( Quot->Partnum )
         SEEK mmod1
         IF FOUND()   
            SELECT Part 
             ApFLock( 3 )
            Part->ABC := "M"                   // to find modules
            UNLOCK
         ENDIF
         SELECT Quot
         ntotal += Quot->Qty*Quot->Amount
         AADD( aPart_,SUBSTR( Quot->Partnum,1,12 );
              +" "+SUBSTR( Part->Desc,1,31 );
              +" "+STR( Quot->Qty, 9, 2 );
              +" "+STR( Quot->Amount, 9, 2 );
              +" "+DTOC( Quot->DbDate );
              +"        "+STR( RECNO(),6 ) )
            SKIP ALIAS Quot
      ENDDO
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @  1, 4      SAY Name->Name+" Job Card "+Debit->Invno   // was minvno
      @  1,COL()+2 SAY ntotal PICTURE "$999,999.99" COLOR "G+"
      DISPBOX( 3, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT(aPart_,,,{ | x,y | x < y })
         anum := ACHOICE( 4, 3, 23,78,aPart_,,"AFUNC" )
         IF PressedEsc()
            RETURN SPACE( 20 )
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         SELECT Quot
         GOTO nrecno
         mpartnum := Quot->Partnum
         mfaxno   := Quot->Faxno
         dDbdate  := Quot->DbDate
         minvno   := Quot->Invno
         SELECT Part
         SET ORDER TO 1  // Partnum
         SEEK Quot->Partnum
      ENDIF
      SCROLL(  15, 0, 24,80 )
      DISPBOX( 15, 1, 20,79, 2 )
      @ 16,50      SAY "JC- # "+Quot->Invno 
      @ 16,COL()+2 SAY "Debit "+Debit->Invno
      @ 17, 3      SAY TRIM( Part->Partnum )
      @ 17,COL()+2 SAY TRIM( Part->Desc ) COLOR "BG+"
      @ 17,COL()+1 SAY Quot->Qty    PICTURE "99,999.99" 
      @ 17,COL()+1 SAY Quot->Amount PICTURE "999,999.99"
      @ 18, 3      SAY TRIM( Part->Detail )
      @ 18,COL()+1 SAY TRIM( Part->Detail1 )
      @ 19, 3      SAY TRIM( Part->Detail2 )
      @ 19,COL()+1 SAY TRIM( Part->Detail3 )
      DISPBOX( 20, 1, 24,79, 2 )
      nselect := 1
      @ 20, 5 SAY " --- Detail JC- --- " COLOR "RG+"
      @ 20,54 SAY " --- Detail JC --- " COLOR "G+"
      @ 21, 4      PROMPT "1. Edit"
      @ 21,COL()+3 PROMPT "2. View JC-"
      @ 21,COL()+3 PROMPT "3. Add Part to JC-"
      @ 21,COL()+3 PROMPT "4. Module"

      @ 23, 4      PROMPT "5. Kit List"
      @ 23,COL()+2 PROMPT "6. Delete Part"
      @ 23,COL()+2 PROMPT "7. Part Edit"
      @ 23,COL()+2 PROMPT "8. Labour/Part"
      @ 23,COL()+2 PROMPT "9. JC- DT11A"
      @ 24,60 SAY " DT11A2 "  

      MENU TO nselect
      DO CASE
         CASE PressedEsc()
            RETURN NIL
         CASE nselect == 1                       // Edit
            QuotPrice( @mpartnum )
            QuotEdit( @mcodeno )
           mcontinue := "Y"
           LOOP
         CASE nselect == 2                      // View JC-
            QuotEdit( @mcodeno )
           COMMIT
           mcontinue := "Y"
           LOOP
        CASE nselect == 3                             // Add Part
           mpartnum := SPACE( 20 )
           SELECT Part
           SET ORDER TO 1
           SCROLL()
           mcodeno := Name->Codeno
            Partfind( @mpartnum, mcodeno )                // XlF_Part
           IF PressedEsc()
              LOOP
           ENDIF
           dDbdate  := DATE()
           minvno   := Debit->Invno
           mpartnum := Part->Partnum
            QuotPAdd( mpartnum )
           COMMIT
           mcontinue := "Y"
           LOOP
        CASE nselect == 4                      // Module
            mmodcode := TRIM( mpartnum )
             EquModule( mmodcode )
            mcontinue := "Y"
            LOOP         
        CASE nselect == 5                  // Kit List
            mmodcode := TRIM( mpartnum )
             EquPart( @mmodcode )               // XLF_Equ3 
            mcontinue := "Y"
            LOOP
        CASE nselect == 6                  // Delete Part Only
            SELECT EquCut
             ApFLock( 3 )
            DELETE ALL FOR EquCut->ModSeqno = Quot->ModSeqno
            UNLOCK
            SELECT Quot 
             ApRLock( 3 )
            DELETE
            UNLOCK
            SELECT QuotStk
            SET ORDER TO 1                     // Invno
            SEEK minvno
            IF FOUND()
               ApFLock( 3 )
              DO WHILE QuotStk->Invno = minvno .AND. QuotStk->( !EOF() )
                 DELETE
                 SKIP ALIAS QuotStk
              ENDDO 
              UNLOCK
            ENDIF 
            mcontinue := "Y"
            LOOP
        CASE nselect == 7 
           tempscrn := SAVESCREEN( 0, 0, 24,80 )
           cedit := "N"                            // N = Total Stock   
            ProfQty( cedit )                        // XLF_Prof
           RESTSCREEN(  0, 0, 24,80,tempscrn )
           LOOP
        CASE nselect == 8                  // Labour
            mpartnum := SPACE( 20 )  
             IvcLabour( mpartnum )             // ZSF_Name
            mcontinue := "Y"
            LOOP
        CASE nselect == 9                  // -- Job Cards --
            mpartnum := SPACE( 20 )  
             JCPart()                      // XLF_QU7
            mcontinue := "Y"
            LOOP
      ENDCASE
   ENDDO                          // mcontinue

   SELECT Quot
   SET ORDER TO 1

   RETURN mpartnum

   ***-----End of QuotEdit()

   **-------------------------------------------------------------------

FUNCTION QuotOperLst()

   mwhere := "S"

    PrintSel( mwhere )

   IF mwhere == "P"
      npl := 56
     ELSE
      npl := 20
   ENDIF
   nl := 0
   @ nl,10 SAY Control->U_Name
   nl++
   ntimeoper:= ntimeadmin := 0
   ntimetotal:= ntime := 0
   SELECT Quot
   INDEX ON Partnum TO QuotParI
   SET INDEX TO QuotParI
   GOTO TOP
   DO WHILE Quot->( !EOF() )      
      mpartnum := Quot->Partnum 
      nquotpart := 0
      DO WHILE Quot->Partnum = mpartnum .AND. Quot->( !EOF() ) 
         nquotpart += Quot->Qty
         SKIP ALIAS Quot
      ENDDO                         // EOF mpartnum
      IF nl > npl
         IF mwhere = "P"
       EJECT
           ELSE
            WAIT
            SCROLL()
          ENDIF
          nl := 0
          @ nl,10 SAY Control->U_Name
          nl++
      ENDIF
      SELECT PartOper
      GOTO TOP
      SEEK mpartnum
      IF FOUND()    
        @ nl,10 SAY mpartnum+"  "+STR( nquotpart )
        nl++
        DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() )
           IF nl > npl
                 IF mwhere = "P"
               EJECT
                   ELSE
                    WAIT
                    SCROLL()
                  ENDIF
                  nl := 0
           ENDIF
           IF PartOper->Desc != SPACE( 40 )
              @ nl, 0 SAY PartOper->Desc
              @ nl,42 SAY "Time"
              @ nl,47 SAY PartOper->Time PICTURE "9999.99"
   ***              @ nl,55 SAY "Rate"
   ***              @ nl,60 SAY PartOper->Rate PICTURE "9999.99"
              ntimetotal += PartOper->Time
             *** @ nl,68 SAY PartOper->Task
              @ nl,74 SAY PartOper->ABC
              @ nl,76 SAY PartOper->Order
              nl++
           ENDIF   
           IF PartOper->Operno != SPACE( 8 )
              SELECT Operate
              SET ORDER TO 1                   // Operno
              SEEK PartOper->Operno
              @ nl, 0 SAY Operate->Desc
              @ nl,42 SAY "Time"
              @ nl,47 SAY Operate->Time PICTURE "9999.99"
   ***              @ nl,55 SAY "Rate"
   ***              @ nl,60 SAY Operate->Rate PICTURE "9999.99"
              ntimetotal += PartOper->Time
   ****              ntimetotal += Operate->Time*Operate->Rate
              *** @ nl,61 SAY "Set Up"
              *** @ nl,68 SAY Operate->Setup PICTURE "999.99"
              @ nl,74 SAY PartOper->ABC
              @ nl,76 SAY PartOper->Order
              nl++
           ENDIF
            /*
           IF PartOper->Adminno != SPACE( 8 )
              SELECT Admin
              SEEK PartOper->Adminno
              @ nl, 0 SAY Admin->Desc
              @ nl,42 SAY "Time"
              @ nl,47 SAY Admin->Time PICTURE "9999.99"
              @ nl,55 SAY "Rate"
              @ nl,60 SAY Admin->Rate PICTURE "9999.99"
              ntimetotal += PartOper->Time*PartOper->Rate
               ****              ntimetotal += Admin->Time*Admin->Rate
              nl++
           ENDIF
            */
           SELECT PartOper
           SKIP ALIAS PartOper
       ENDDO                     // PartOper EOF
   ENDIF                        // Found in PartOper
      SELECT Quot
   ***      SKIP ALIAS Quot
   ENDDO                        // Quot EOF
   IF nl > 18
      IF mwhere = "S"
         WAIT
         SCROLL()
         nl := 12
      ENDIF
   ENDIF    
   nl++
   @ nl,30 SAY "Total Time ="
   @ nl,45 SAY ntimetotal  PICTURE "$99,999.99"
   nl+=2
   IF mwhere = "S"
      WAIT
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
     ELSE
      EndPrint()
   ENDIF
   SELECT Quot
   SET INDEX TO QuotInd

   mcontinue := ApGetN( "Do You want Labour Print" )
   IF mcontinue == "Y"
      LabPrint()                    // LabDem
   ENDIF  
   RETURN NIL
   ***** End of QuotOperLst

   *********----------  END OF FILE XLF_QUOT.PRG

