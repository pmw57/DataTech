   *** JK  27-08-11 14:54:53 

/* Program.....:                METQUOT.PRG
   Authors.....: J.Kirby
   Date........: 10/06/2002
   Functions...: GroupEdit, ModPart, MET_QPart, METuotJSheet
                 METuotPrice
   Not used....: JobOutXY, METQMenu, METApplicant
                 METartSrch, METuotAdd, METuotIndi
*/

FUNCTION GroupEdit()
   mok := "Y"
   DO WHILE mok = "Y"
      SELECT Part
      SET ORDER TO 1                       // Catno
      GOTO TOP
      SEEK mpart
      nrecno := 0
      aPart_ := {}
      DO WHILE Part->Partnum = mpart .AND. Part->( !EOF() )
         AADD( aPart_,Part->PartId;
            +" "+Part->Catno;
            +" "+SUBSTR( Part->Partnum, 1,16 );
            +" "+SUBSTR( Part->Desc, 1,18 );
            +" "+STR( Part->Trade, 9, 2 );
            +"              "+STR( RECNO(),6 ) )
         SKIP ALIAS Part
      ENDDO   // Part EOF
      SCROLL() 
      DISPBOX( 0, 1, 2,79, 2 )
      @  1,10 SAY "Select Parts "+mpart  COLOR "BG+"
      @  1,42 SAY "Product" 
      DISPBOX( 3, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 4, 3, 23,77, aPart_,,"AFUNC" )
         IF LASTKEY() = 27
            RETURN NIL
         ENDIF  
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         mpartId := Part->PartId
         @ ROW(), 2 GET mpartId PICTURE "@!"
         READ   
         ApRLock( 3 )   
         Part->PartId := mpartId  
         UNLOCK
      ENDIF
      ***       WAIT
   ENDDO                    // mok  
   RETURN NIL

FUNCTION ModPart()

   manother := "Y"
   DO WHILE manother == "Y"

      mpartnum := SPACE( 20 )
      SELECT Part
      SET ORDER TO 1                       // Partnum
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @  1, 8 SAY "Part #" GET mpartnum PICTURE "@!"
       READ
      /*
      DO CASE
         CASE SUBSTR( mpartnum, 1, 2 ) = "JC"
             mpartnum := "J     "
         CASE SUBSTR( mpartnum, 1, 2 ) = "QU"
             mpartnum := "Q     "
      ENDCASE
      */
      IF PressedEsc()
         RETURN NIL
      ENDIF
      aPart_ := {}
      nrecno := 0
      SELECT Part
      SET EXACT OFF
      SET ORDER TO 1
      SEEK mpartnum
      mpart  := TRIM( mpartnum )
      FOR x = 1 TO LEN( mpart ) 
         SEEK SUBSTR( mpart,1, x )      // Tracer
      NEXT
      IF !FOUND()
         @ 1,40 SAY "Try Again "+mpartnum+"  not Found" COLOR "R+"
         INKEY( 2 )
         LOOP
      ENDIF  
      IF FOUND()
         DO WHILE Part->Partnum = mpart .AND. Part->( !EOF() )
            mpartnum := Part->Partnum
            mmodcode := SUBSTR( mpartnum, 1,16 )  // This is if 20 Part #
            ntottrade:= ntotwhol := 0
            ntottrade1:= ntotwhol1 := 0
            IF Part->BoughtOut = "N"
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
                     SELECT Part
                     SET ORDER TO 1
                     SEEK Equ->Partnum
                     ntottrade1 += ( Part->Trade*Equ->PartQty )
                     ntotwhol1  += ( Part->Wholesale*Equ->PartQty )
                     SELECT Equ
                     mmod2 := SUBSTR( Equ->Partnum, 1,16 ) 
                     nequ1 := Equ->Partqty 
                     nrecno2 := RECNO() 
                     GOTO TOP
                     SEEK mmod2
                     IF !FOUND()
                        ntottrade += ( Part->Trade*nequ1 )
                        ntotwhol  += ( Part->Wholesale*nequ1 )
                     ENDIF
                     IF FOUND()
                        DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
                           SELECT Part
                           SET ORDER TO 1
                           SEEK Equ->Partnum
                           SELECT Equ
                           mmod3   := SUBSTR( Equ->Partnum, 1,16 )
                           nrecno3 := RECNO() 
                           nequ2 := Equ->PartQty * nequ1
                           GOTO TOP
                           SEEK mmod3
                           IF !FOUND()   
                              ntottrade += ( Part->Trade*nequ2 )
                              ntotwhol  += ( Part->Wholesale*nequ2 )
                           ENDIF
                           IF FOUND()
                              DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
                                 SELECT Part
                                 SET ORDER TO 1
                                 SEEK Equ->Partnum
                                 SELECT Equ
                                 mmod4 := SUBSTR( Equ->Partnum, 1,16 )
                                 nrecno4 := RECNO()
                                 nequ3 := Equ->PartQty * nequ2
                                 GOTO TOP
                                 SEEK mmod4
                                 IF !FOUND()
                                    ntottrade += ( Part->Trade*nequ3 )
                                    ntotwhol  += ( Part->Wholesale*nequ3 )
                                 ENDIF
                                 IF FOUND()
                                    DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                                       nequ4 := Equ->PartQty * nequ3
                                       SELECT Part
                                       SET ORDER TO 1
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
               SET EXACT OFF  
            ENDIF                     // Boughtout
            SELECT Part
            SET ORDER TO 1                     // Partnum
            SEEK mmodcode    // Used to be partnum
             ApRLock( 3 )
            Part->RetIndiv := ntottrade
            UNLOCK
            SET ORDER TO 2                     // Catno
            SKIP ALIAS Part
         ENDDO             // End of Part File
      ENDIF
      mok := "Y"
      DO WHILE mok = "Y"
         SELECT Part
         SET ORDER TO 1                       // Catno
         GOTO TOP
         SEEK mpart
         nrecno := 0
         aPart_ := {}
         cmark  := "   "
         DO WHILE Part->Partnum = mpart .AND. Part->( !EOF() )
            IF Part->RetIndiv > ( Part->Trade+10 )
               cmark := " * "
            ENDIF  
            AADD( aPart_,SUBSTR( Part->Partnum, 1,16 );
               +" "+SUBSTR( Part->Desc, 1,18 );
               +" "+STR( Part->RetIndiv, 9, 2 );
               +" "+STR( Part->Trade, 9, 2 );
               +cmark+STR( Part->Markup, 7, 2 );
               +" "+STR( Part->Wholesale, 9, 2 );
               +"           "+STR( RECNO(),6 ) )
            cmark := "   " 
            SKIP ALIAS Part
         ENDDO   // Part EOF
         SCROLL() 
         DISPBOX( 0, 1, 2,79, 2 )
         @  1,10 SAY "Select Parts "+mpart  COLOR "BG+"
         @  1,42 SAY "Module     Cost   Markup    Sell" 
         DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE( 4, 3, 23,77, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
         ENDIF
         mdesc    := Part->Desc
         ntrade   := Part->Trade
         nmarkup  := Part->Markup
         mpartnum := Part->Partnum
         SCROLL( 10, 2, 23,78 )
         nl := 11
         @ nl, 8      SAY Part->Desc COLOR "BG+" 
         @ nl,COL()+4 SAY Part->Date COLOR "BG+"
         nl++
         @ nl, 6      SAY "Module      Cost  Markup     Sell" 
         @ nl,COL()+2 SAY SUBSTR( Part->Partnum, 1,16 ) COLOR "RG+"
         @ nl,COL()+2 SAY Part->Catno                   COLOR "RG+"
         nl++
         @ nl, 3 SAY STR( Part->RetIndiv, 9, 2 );
            +" "+STR( Part->Trade, 9, 2 );
            +" "+STR( Part->Markup, 7, 2 );
            +" "+STR( Part->Wholesale, 9, 2 ) COLOR "BG+"
         IF Part->RetIndiv > ( Part->Trade+10 )
            @ nl,COL()+6 SAY "Check Cost Price" COLOR "RG+"
         ENDIF
         ****         ENDDO                  // Part
         ***      ENDIF                    // Found  
         nl++
         nselect := 1
         DISPBOX( 20, 1, 24,79, 2 )
         @ 20,10      SAY " --- Part --- "+mpartnum
         @ 21, 6      PROMPT "1. Price"
         @ 21,COL()+2 PROMPT "2. Change Catalogue"
         @ 21,COL()+2 PROMPT "3. Another Part"
         @ 21,COL()+2 PROMPT "4. Delete Part"
         @ 23, 6      PROMPT "5. By Catalogue"
         @ 23,COL()+2 PROMPT "6. Part Details"
         @ 23,COL()+2 PROMPT "7. Edit Group"
         @ 23,COL()+2 PROMPT "EXIT"
         MENU TO nselect
         DO CASE
            CASE nselect == 8 .OR. PressedEsc()
               RETURN NIL
            CASE nselect == 7
               GroupEdit()                    // Above
               LOOP
            CASE nselect == 1
               ntradeDate := 0
               nl++
               @ nl,19      GET mdesc
               nl++
               @ nl, 6      SAY Part->RetIndiv COLOR "RG+"
               @ nl,COL()+2 SAY TRIM( Part->Unit )+" Cost " GET ntrade PICTURE "999999.99"
               @ nl,COL()+2 SAY "Mkup %"                    GET nmarkup PICTURE "9999.99"
                READ
               IF PressedEsc()
                  RETURN NIL
               ENDIF
                ApRLock( 3 )
               IF Part->Trade != ntradeDate
                  Part->Date := DATE()
               ENDIF                       // Part->Trade
               Part->Trade  := ntrade
               Part->Markup := nmarkup
               nsell := ( Part->Trade* ( 1+( Part->Markup/100) ) )
               Part->Wholesale := ( Part->Trade* ( 1+( Part->Markup/100) ) )
               UNLOCK
               nwholesale := Part->Wholesale
               nl+=2
               @ nl, 6      SAY TRIM( Part->Unit )+" Sell exl GST";
                            GET nwholesale PICTURE "999999.99"
                READ
               DO CASE 
                  CASE Part->Boughtout = "Y"
                     nselect := 1
                  OTHERWISE
                     nselect := 2
               ENDCASE
               @ nl,38      PROMPT "Part Bought Out"
               @ nl,COL()+2 PROMPT "Own Manufacture"
               MENU TO nselect
                ApRLock( 3 )
               DO CASE
                  CASE nselect == 1
                     Part->Boughtout := "Y"
                  CASE nselect == 2
                     Part->Boughtout := "N"
               ENDCASE
               Part->Wholesale := nwholesale   
               Part->Markup := ( ( Part->Wholesale-Part->Trade ) / Part->Trade ) *100
               Part->Desc    := mdesc
               UNLOCK
            CASE nselect == 2
               SELECT Cat
               GO TOP
               nrecno := 0
               aPart_ := {}
               DO WHILE Cat->( !EOF() )
                  AADD( aPart_, FIELDGET(1)+"     "+FIELDGET(2) )
                  SKIP ALIAS Cat
               ENDDO
               IF !EMPTY( aPart_ )
                  ASORT(aPart_,,,{ | x,y | x < y })
                  tempscr := SAVESCREEN( 0, 0, 24, 80 )
                  SCROLL()
                  DISPBOX( 0, 1, 22,79, 2 )
                  @  1, 3      SAY Part->Desc    COLOR "BG+" 
                  @  1,COL()+2 SAY SUBSTR( Part->Partnum, 1,16 ) COLOR "BG+"
                  @  1,COL()+2 SAY Part->Catno   COLOR "BG+"
                  @  3, 6      SAY "SELECT NEW Catalogue" COLOR "R+"
                  nAnum := ACHOICE( 4, 5, 21,72, aCatcode_,,"AFUNC" )  // Select Cat
                  cnewcatno := SUBSTR( aCatcode_[nAnum], 1,12 )
                  SELECT Part
                   ApRLock( 3 )
                  Part->Catno := cnewcatno   
                  UNLOCK
                  SCROLL( 8, 0, 24,80 )
                  DISPBOX( 10, 1, 18,79, 2 )
                  @  12, 3      SAY Part->Desc    COLOR "BG+" 
                  @  12,COL()+2 SAY SUBSTR( Part->Partnum, 1,16 ) COLOR "BG+"
                  @  12,COL()+2 SAY Part->Catno   COLOR "RG+"
                   INKEY( 3 )
                  RESTSCREEN( 0, 0, 24, 80,tempscr )
               ENDIF
               LOOP

            CASE nselect == 3
               EXIT

            CASE nselect == 4
                PartDelete()              // CWP2
               LOOP             
            CASE nselect == 5
                CatList()              // XF2PPART
               LOOP             
            CASE nselect == 6
                PartDets( @mpartnum )              // CWPP2
               LOOP             

         ENDCASE
      ENDDO                    // mok

   ENDDO                    // manother

   RETURN NIL
   ****------------  ModPart

   ***----------------------------------------------------------

FUNCTION MET_QPart( nc, ncl )

   DO WHILE .T.

      nselect := 0
      nc      := ncl
      SCROLL(  3,nc, 21,78 )
      DISPBOX( 4,nc, 21,nc+ncl )
      SCROLL(  3,nc+2, 5,nc+( ncl-2 ) )
      DISPBOX( 3,nc+2, 5,nc+( ncl-2 ) )
      SELECT Debit
      GOTO TOP
      nl:= nll:= nlll := 4
      npl:= npll := 20 
      ccodeno := SPACE( 14 )
      @  3,54 SAY "Completed Jobs" COLOR "RG+"
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
               @ nl,52   SAY Debit->Codeno+" "+Debit->Invno
               nl++
            CASE nll <= npll
               @ nll,67  SAY Debit->Codeno+" "+Debit->Invno
               nll++
            OTHERWISE
               @ nlll,65 SAY Debit->Codeno+" "+Debit->Invno
               nlll++
         ENDCASE 
         ccodeno := Debit->Codeno+Debit->Invno
         SKIP ALIAS Debit
      ENDDO                          // EOF()
      ***   SELECT Quotstk
      ***   COUNT TO nrecno
      ***   @  7,53      SAY "JC-File" COLOR "B+"
      ***   @  7,COL()+2 SAY nrecno    PICTURE "99999" 
      cheading := "JOB CARD MENU"
      @  4,nc+( ncl/2 )-( LEN( RTRIM( cheading ) )/2 );
                           SAY RTRIM( cheading )
      @  7,nc+2 PROMPT "1. JOB CARDS SEARCH    "
      @  8,nc+2 PROMPT "2.  ..       Add/Edit  "
      @  9,nc+2 PROMPT "3. JOB CARDS Menu      "
      @ 11,nc+2 PROMPT "4. LABOUR  By    Name  "
      @ 13,nc+2 PROMPT "5. JC-  By Start Date  "
      @ 15,nc+2 PROMPT "6. JC-Parts Req/Rec/Ord"
      @ 17,nc+2 PROMPT "7. OPERATION/DRAWING   "
      @ 18,nc+2 PROMPT "8. Clean up Operations "
      @ 19,nc+2 PROMPT "9. Job Menu System     "
      @ 20,nc+2 PROMPT Menu->CH_Main+"   "
      nc := ncl 
      MENU TO nselect
      DO CASE
         CASE nselect == 10 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 1                             // Search
            SAVE SCREEN TO Invscrn
            ***           IF SUBSTR( Control->U_Name,1, 4 ) = "META" 
            QuotSearch()                             // XLF_Quot
            ***             ELSE
            ***              LessonSearch()
            ***           ENDIF   
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
        CASE nselect == 3            // Job Cards
            SAVE SCREEN TO Invscrn
            @  9,nc+2 SAY "3. JOB CARDS Menu      " COLOR "GB+"
             Mu_Quot( nc, ncl )                     // XLF_Quot                           
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 4             // By Name  
            SAVE SCREEN TO Invscrn
            SELECT Control
             ApRLock( 3 )
            Control->LastRoll := DATE()-1
            UNLOCK
            IF SUBSTR( Control->U_Name,1, 4 ) = "META" 
               LabourWo()                   // XLF_QU5
            ELSE
               LabourShan()                 // XLF_QU10 
            ENDIF   
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 5
            SAVE SCREEN TO Invscrn
            QuotStart()             // XF_QList
            RESTORE SCREEN FROM Invscrn
             LOOP
         CASE nselect == 6
            SAVE SCREEN TO Invscrn
            JCReqRec()              // XLF_QU6
            RESTORE SCREEN FROM Invscrn
             LOOP
         CASE nselect == 7             // By Total 
            SAVE SCREEN TO Invscrn
            @ 17,nc+2 SAY "7. OPERATION/DRAWING   " COLOR "GB+"
            Mu_Oper( nc, ncl )        // XLF_Equ2
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 8                             // 
            SAVE SCREEN TO Invscrn
             OperDelete()                        //  XLF_Ser.PRG  
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 9                             // 
            SAVE SCREEN TO Invscrn
             JobAnalyA()   // XLF_MenuA.prg 
            RESTORE SCREEN FROM Invscrn
         /*
         CASE nselect == 9
            SAVE SCREEN TO Invscrn
              JobLabour()                           // JobDem
            RESTORE SCREEN FROM Invscrn
         */
      ENDCASE
   ENDDO

   RETURN NIL

   ***------ End of MET_QPart

   **---------------------------------------------------------------------*

FUNCTION JobOutXY()

   SELECT QuotStk
   SET ORDER TO 2   // Partnum
   SCROLL()
   cpagehd  := "SPmodXY"
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
   @  2, 1 SAY "Part #"
   @  2,17 SAY "Description"
   @  2,45 SAY "Required-Received O/S"
   nl := 3
   nreq:= malloc := 0
   SELECT QuotStk
   GOTO TOP
   DO WHILE QuotStk->( !EOF() )
      IF SUBSTR( QuotStk->Partnum, 1, 2 ) != "XY"
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
         @  2, 1 SAY "Part #"
         @  2,17 SAY "Description"
         @  2,45 SAY "Required-Received O/S"
         nl := 3
      ENDIF         // nl > npl
      SELECT Part
      SEEK QuotStk->Partnum
      SELECT QuotStk
      @ nl, 0 SAY SUBSTR( QuotStk->Partnum, 1,16 )
      @ nl,17 SAY SUBSTR( Part->Desc, 1,36 )
      nrequired := 0
      mpart     := QuotStk->Partnum
      DO WHILE QuotStk->Partnum = mpart .AND. QuotStk->( !EOF() )
         IF QuotStk->Required = 0
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
         IF QuotStk->Received >= QuotStk->Required
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
         IF SUBSTR( QuotStk->Partnum, 1, 2 ) != "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
         nrequired += QuotStk->Required-QuotStk->Received
         SKIP ALIAS QuotStk
      ENDDO                 // QuotStk
      @ nl,55 SAY nrequired PICTURE "999,999.99"
      @ nl,66 SAY SUBSTR( Part->Unit, 1, 5 )
      @ nl,72 SAY Part->Codeno
      nl++
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
   ****------  END JobOutXY()

   *****---------------------------------------------------------------------

FUNCTION METQMenu( nc, ncl )

   DO WHILE .T.
      nselect := 0
      nc      := ncl*2
      SCROLL(  3,nc, 21,78 )
      DISPBOX( 4,nc, 21,nc+ncl )
      SCROLL(  3,nc+2, 5,nc+( ncl-2 ) )
      DISPBOX( 3,nc+2, 5,nc+( ncl-2 ) )
      cheading := "JOB CARD INFO"
      @  4,nc+( ncl/2 )-( LEN( RTRIM( cheading ) )/2 );
                           SAY RTRIM( cheading )
      @  7,nc+2 PROMPT "1. JC-   Info   Search"
      @ 10,nc+2 PROMPT "2. Name  Part   Search"
      @ 11,nc+2 PROMPT "3.  ..   Part Add/Edit"
      @ 12,nc+2 PROMPT "4.       Part  by Name"
      @ 13,nc+2 PROMPT "5.       Part  Listing"
      @ 20,nc+2 PROMPT Menu->CH_Main
      nc := ncl 
      MENU TO nselect
      DO CASE
         CASE nselect = 6 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 1
            SAVE SCREEN TO Invscrn
              METuotSrch()                             // MetQuHse
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 2
            SAVE SCREEN TO Invscrn
              MEuotSearch()                             // 
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 3
            SAVE SCREEN TO Invscrn
              MEuotadd()                                // Below
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 4
            SAVE SCREEN TO Invscrn
              MEartSearch()
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 5
            SAVE SCREEN TO Invscrn
              MEApplicant()
            RESTORE SCREEN FROM Invscrn
      ENDCASE
   ENDDO

   RETURN NIL

   ***------ End of METQPart

   ***---------------------------------------------------------------------*

FUNCTION METApplicant()

   minvno  := SPACE( 6 )
   mcodeno := SPACE( 8 )
   aPart_ := anum:= {}
   nrecno := 0
   SCROLL()
   SELECT QuotInfo
   IF LASTREC() != 0
      GOTO TOP
      DO WHILE QuotInfo->( !EOF() )
         IF QuotInfo->Invno = SPACE( 6 )
            SKIP ALIAS QuotInfo
            LOOP
         ENDIF
         IF QuotInfo->Codeno = "A"
            SKIP ALIAS QuotInfo
            LOOP
         ENDIF
         AADD( aPart_,QuotInfo->Invno;
                  +" "+QuotInfo->Codeno; 
                  +" "+QuotInfo->Info; 
                  +"   "+STR( RECNO(),6 ) )
         SKIP ALIAS QuotInfo
      ENDDO
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @  1, 3 SAY "JC- Information List"
      DISPBOX( 3, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT(aPart_,,,{ | x,y | x < y })
         anum := ACHOICE( 4, 3, 23,78, aPart_,,"AFUNC" )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         SELECT QuotInfo
         GOTO nrecno
      ENDIF
      mcodeno  := QuotInfo->Codeno

       MeTuotEdit( mcodeno )               // MetQuHse

   ENDIF                       // LastRec

   RETURN NIL
   ****---- End of METApplicant()

   *---------------------------------------------------------------------*

FUNCTION METuotJSheet()

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      moper  := "N"
      mallparts := "Y" 
      mwhere := "S"
      npl    := 0
      nrecno := 0
      nl     := 0
      
       Printsel()                               // _LF_Init

      @ nl, 0 SAY Control->U_Name 
      @ nl,60 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
                 +STR(YEAR(DATE()),5)
      nl+=2
      SELECT Name
      SEEK QuotInfo->Codeno
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
      @ nl, 0 SAY TRIM( Name->Add4 )+"       Ph "+Name->Phone;
                  +"  "+Name->Mobphone
      nl+=2
      @ nl, 4 SAY Debit->Invno
      @ nl,14 SAY Debit->DBDate
      @ nl,40 SAY "Due Date" 
      @ nl,50 SAY Debit->DueDate
      nl++
      @ nl,12 SAY Debit->Est          
      nl++
      IF SUBSTR( Debit->Note1, 1, 3 ) != SPACE( 3 )
         @ nl,12 SAY Debit->Note1
         nl++
      ENDIF
      IF SUBSTR( Debit->Note2, 1, 3 ) != SPACE( 3 )
         @ nl,12 SAY Debit->Note2
         nl++
      ENDIF
      IF SUBSTR( Debit->Note3, 1, 3 ) != SPACE( 3 )
         @ nl,12 SAY Debit->Note3
         nl++
      ENDIF
      mcodeno := Name->Codeno
      SELECT QuotInfo
      GOTO TOP
      SEEK mcodeno
      nline := 0
      DO WHILE QuotInfo->Codeno = mcodeno .AND. QuotInfo->( !EOF() )
         IF QuotInfo->Invno != Debit->Invno
            SKIP ALIAS QuotInfo
            LOOP
         ENDIF
         IF SUBSTR( QuotInfo->Info, 1, 3 ) != SPACE( 3 )
            @ nl,12 SAY QuotInfo->Info
            nl++
         ENDIF
         IF SUBSTR( QuotInfo->Info2, 1, 3 ) != SPACE( 3 )
            @ nl,12 SAY QuotInfo->Info2
            nl++
         ENDIF
         IF SUBSTR( QuotInfo->Info3, 1, 3 ) != SPACE( 3 )
            @ nl,12 SAY QuotInfo->Info3
            nl++
         ENDIF
         IF SUBSTR( QuotInfo->Info4, 1, 3 ) != SPACE( 3 )
            @ nl,12 SAY QuotInfo->Info4
            nl++
         ENDIF
         IF SUBSTR( QuotInfo->Info5, 1, 3 ) != SPACE( 3 )
            @ nl,12 SAY QuotInfo->Info5
            nl++
         ENDIF
         IF SUBSTR( QuotInfo->Info6, 1, 3 ) != SPACE( 3 )
            @ nl,12 SAY QuotInfo->Info6
            nl++
         ENDIF
         SELECT Cusnotes
         cdetail := ""
         coderef := QuotInfo->Faxno
         SEEK coderef
         IF FOUND()
            nl++  
            @ nl, 0 SAY ""
             Getdets( coderef )                           // XF_Memo2
             FormP( cdetail,60,10 )                       // XF_Memo2
         ENDIF                          // Found()
         SELECT QuotInfo
         SKIP ALIAS QuotInfo
      ENDDO                            //   EOF() QuotInfo
      nl++ 
      IF mwhere = "P"
         IF nl > 40
            nl := 1
            EJECT
         ENDIF
      ENDIF
      IF mwhere = "P"
         nl++
         npl := nl
         nline = 1
         FOR nline = 1 TO ( 36-npl )
         @ nl, 0 SAY "__________________________________________________________________________"
         nl+=2
         NEXT
      ENDIF 
      IF mwhere = "S"
         INKEY( 0 )
         SCROLL()
         nl := 0
      ENDIF
      nl++
      IF mwhere == "P"
         EndPrint()
       ELSE
         WAIT
      ENDIF 
      SCROLL( 18, 0, 24,80 )
      mcontinue := "N" 
   ENDDO

   RETURN NIL
   ******* End of METuotJSheet()

   **---------------------------------------------------------------------*

FUNCTION METartSrch()

   aPart_ := anum:= {}
   nrecno := 0
   SCROLL()
   SELECT QuotInfo
   IF LASTREC() != 0
      GOTO TOP
      mpartnum := SPACE( 20 )
      DO WHILE QuotInfo->( !EOF() )
         IF QuotInfo->Invno = SPACE( 6 )
            SKIP ALIAS QuotInfo
            LOOP
         ENDIF
         IF QuotInfo->Invno != minvno
            SKIP ALIAS QuotInfo
            LOOP
         ENDIF
         SELECT Debit
         SET ORDER TO 2                    // Invno
         SEEK QuotInfo->Invno
         SET ORDER TO 1                    // Codeno
         SELECT QuotInfo
         AADD( aPart_,QuotInfo->Invno+" "+Debit->Est;
              +"           "+STR( RECNO(),6 ) )
         minvno := QuotInfo->Invno
         SKIP ALIAS QuotInfo
      ENDDO
      DISPBOX( 0, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT(aPart_,,,{ | x,y | x < y })
         anum := ACHOICE( 1, 3, 23,78, aPart_,,"AFUNC" )
         IF PressedEsc()
            SELECT QuotInfo
            SET INDEX TO QuInfo
            RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
      ENDIF
      minvno := QuotInfo->Invno 
      aPart_ :={}
      nrecno := 0
      cInvno := SPACE( 10 )
      SELECT QuotInfo
      SEEK minvno
      DO WHILE QuotInfo->( !EOF() )
         IF QuotInfo->Invno = SPACE( 6 )
            SKIP ALIAS QuotInfo
            LOOP
         ENDIF
         IF QuotInfo->Invno != minvno
            SKIP ALIAS QuotInfo
            LOOP
         ENDIF
         SELECT Debit
         SET ORDER TO 2                        // Invno
         SEEK minvno
         SET ORDER TO 1                        // Codeno
         SELECT QuotInfo
         AADD( aPart_,QuotInfo->Invno;
              +" "+QuotInfo->Info;
              +" "+Debit->Est;
              +"        "+STR( RECNO(),6 ) )
         SKIP ALIAS QuotInfo
      ENDDO
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @  1, 3      SAY minvno     COLOR "G+"
      @  1,COL()+1 SAY Debit->Est COLOR "G+"
      DISPBOX( 3, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 4, 3, 23,78,aPart_,,"AFUNC" )
         IF PressedEsc()
            RETURN NIL
         ENDIF
      ENDIF
   ENDIF                       // LastRec

   METartSrch()                 // Above

   RETURN NIL
   ****---- End of METartSrch()

   **---------------------------------------------------------------------*

FUNCTION METuotPrice()

   SELECT Name
   SEEK Debit->Codeno
   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
   @  1, 3 SAY Name->Name COLOR "BG+"
   DISPBOX( 3, 1, 24,79, 2 )
   nl := 4
   @ nl, 3 SAY Debit->Invno+" "+Debit->Est+"  "+Debit->Codeno COLOR "BG+"
   nl++
   SELECT QuotInfo
    ApRLock( 3 )
   @ nl, 4 SAY "Memo        " GET QuotInfo->Info
   nl++
   @ nl,17 GET QuotInfo->Info2
   nl++
   @ nl,17 GET QuotInfo->Info3
   nl++
   @ nl,17 GET QuotInfo->Info4
   nl++
   @ nl,17 GET QuotInfo->Info5
   nl++
   @ nl,17 GET QuotInfo->Info6
   nl+=2
     READ
   UNLOCK
   SELECT Debit
    ApRLock( 3 )
   @ nl,10 SAY Debit->Invno   GET Debit->Est
   nl++
    READ
   UNLOCK
   SELECT Cusnotes
   coderef := QuotInfo->Faxno
   SEEK coderef
   ***   IF FOUND()

       M2MemoFile( coderef )                      // XF_Memo2
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
      ***   ENDIF            // Found Memo
   
   RETURN minvno

   ****------- End METQuotPrice

   **-------------------------------------------------------------------

FUNCTION METuotAdd()

   dDbDate   := DATE()
   mcodeno   := SPACE ( 8 )
   mpartnum  := SPACE( 20 )
   mcontinue := "Y"
   DO WHILE mcontinue = "Y"

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
      manother := "Y"
      DO WHILE manother = "Y"
        mok := "Y"
        DO WHILE mok = "Y"
           SCROLL( 3, 0, 24,80 )
      ***        IF FOUND()
      ***           METuoLook()                 // METQuHse.PRG
      ***        ENDIF
           SCROLL(  12, 0, 24,80 )
           DISPBOX( 12, 1, 24,79, 2 )
           @ 13, 4      SAY TRIM( QuotInfo->Partnum )
           @ 13,COL()+2 SAY Part->Desc  COLOR "BG+" 
           @ 15, 4      SAY QuotInfo->Info 
           @ 16, 4      SAY QuotInfo->Info2
           @ 17, 4      SAY QuotInfo->Info3
           @ 18, 4      SAY QuotInfo->Info4
           @ 19, 4      SAY QuotInfo->Info5
           @ 20, 4      SAY QuotInfo->Info6
           DISPBOX( 22, 1, 24,79, 2 )
           nselect := 1
           @ 23, 4      PROMPT "Add Job Card"
           @ 23,COL()+3 PROMPT "Edit Info"
           @ 23,COL()+3 PROMPT "Job Card"     
           @ 23,COL()+3 PROMPT "Another"
        MENU TO nselect
        DO CASE
          CASE PressedEsc()
            RETURN NIL
          CASE nselect == 1
             Quotcodeno := SPACE( 8 )
             mpartnum := SPACE( 20 )
              METuotPAdd( @mpartnum )                      // MEQuoHse
             LOOP
          CASE nselect == 2
              METuotEdit( @mcodeno )                       // MEQuoHse
             LOOP
          CASE nselect == 3
             mcodeno := Name->Codeno
              METuotJSheet( @mcodeno )                      // Below                          
             LOOP
         CASE nselect == 4                     //   Qty Desc 
           LOOP
         ENDCASE
      ENDDO                               // End of more Parts
   ENDDO
   mcontinue := "N"
   ENDDO                                   // mcontinue

   RETURN NIL

   ****----- End of METuotadd()

   **-------------------------------------------------------------------

FUNCTION METuotIndi()

  PrintSel()

   IF mwhere = "P"
      @  0, 0
      SET DEVICE TO PRINT
      npl := 65
     ELSE
      SCROLL()
      npl := 22
   ENDIF
      nl := 4
      @ nl, 0 SAY Control->U_Name 
      @ nl,60 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
                 +STR(YEAR(DATE()),5)
      nl+=2
      SELECT Name
      mcodeno := Debit->Codeno 
      SEEK mcodeno
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
      @ nl, 0 SAY TRIM( Name->Add4 )+"       Ph "+Name->Phone;
                  +"  "+Name->Mobphone
      nl+=2
      SELECT QuotInfo
      GOTO TOP
   DO WHILE QuotInfo->Codeno = mcodeno .AND. QuotInfo->( !EOF() )
      IF QuotInfo->Invno != Debit->Invno
         SKIP ALIAS QuotInfo
         LOOP
      ENDIF
      IF mwhere = "P" .AND. nl >= 55              // Adjust no of items
         @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
         SET DEVICE TO SCREEN
         @ 12,10 SAY " "
         @ 14,10 SAY "ALIGN PAPER to TOP OF PAGE"
         @ 16,10 SAY " WAIT FOR PRINTER TO STOP"
         WAIT
         SET DEVICE TO PRINT
        ELSEIF ROW() = 18
          WAIT
          nl := 0
          SCROLL()
      ENDIF                                // mwhere
         nl++
         SELECT Name
         @ nl,10 SAY Name->Name
         SELECT Debit 
         @ nl,12 SAY Debit->Est          
         @ nl,64 SAY Debit->Codeno
         nl++
         IF SUBSTR( Debit->Note1, 1, 3 ) != SPACE( 3 )
            @ nl,12 SAY Debit->Note1
            nl++
         ENDIF
         IF SUBSTR( Debit->Note2, 1, 3 ) != SPACE( 3 )
            @ nl,12 SAY Debit->Note2
            nl++
         ENDIF
         IF SUBSTR( Debit->Note3, 1, 3 ) != SPACE( 3 )
            @ nl,12 SAY Debit->Note3
            nl++
         ENDIF
         @ nl, 6 SAY QuotInfo->Invno
         @ nl,16 SAY QuotInfo->DBDate
         @ nl,26 SAY QuotInfo->DueDate
         @ nl,38 SAY QuotInfo->Codeno
         nl++
         IF SUBSTR( QuotInfo->Info, 1, 3 ) != SPACE( 3 )
            @ nl,10 SAY QuotInfo->Info
            nl++
         ENDIF
         IF SUBSTR( QuotInfo->Info2, 1, 3 ) != SPACE( 3 )
            @ nl,10 SAY QuotInfo->Info2
            nl++
         ENDIF
         IF SUBSTR( QuotInfo->Info3, 1, 3 ) != SPACE( 3 )
            @ nl,10 SAY QuotInfo->Info3
            nl++
         ENDIF
         IF SUBSTR( QuotInfo->Info4, 1, 3 ) != SPACE( 3 )
            @ nl,10 SAY QuotInfo->Info4
            nl++
         ENDIF
         IF SUBSTR( QuotInfo->Info5, 1, 3 ) != SPACE( 3 )
            @ nl,10 SAY QuotInfo->Info5
            nl++
         ENDIF
         IF SUBSTR( QuotInfo->Info6, 1, 3 ) != SPACE( 3 )
            @ nl,10 SAY QuotInfo->Info6
            nl++
         ENDIF
         nl++
         SELECT Cusnotes
         cdetail := ""
         coderef := QuotInfo->Faxno
         SEEK coderef
         IF FOUND()
             GetDets( coderef )                            // XF_Memo2
             FormP( cdetail,60,10 )                        // XF_Memo2
         ENDIF
        nl++
        SELECT QuotInfo
        SKIP ALIAS QuotInfo
    ENDDO                                // EOF QuotInfo
   IF mwhere == "P"
      EndPrint()
     ELSE
      IF nl > 20
         WAIT
      ENDIF
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF
   SELECT Name
   SEEK mcodeno

   RETURN NIL

   *** End of METuotIndi()

   *********----------  END OF FILE METQuot.PRG
