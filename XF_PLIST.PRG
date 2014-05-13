   *** JK 22-03-11 19:02:14 

/* 
   Program.....:                 XF_PLIST.PRG

   Author......: J.Kirby
   Date........: 24/06/85
   Functions...: LocDesc, CatLoc, LocStk, LocPart, AllOrders
                 PartLoc, Mu_PartList, PartRUtd
   Static funcs: PaDescLoc, PartSect, SuppList, PartTrade
                 PartList, CatGroup
*/

FUNCTION LocDesc()

   mok := "Y"
   DO WHILE mok == "Y"
      SCROLL()
      nl := 0
      nqty := 0
      mselect := "XX  "  // SPACE( 4 )
      DISPBOX(  0, 1, 20,79, 2 )
      @  2,10 SAY "Listing of Part Location Description"
      @  6, 8 SAY "Location :" GET mselect PICTURE "@!"
      @  6,COL()+2 SAY "Blank for Look up XX for All"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      IF mselect = "XX  "
         mwhere := "S"
         npl    := 54

         Printsel()                                  // _LF_Init

         IF mwhere == "P"
            npl := 56
         ELSE
            SCROLL()
            npl := 22
         ENDIF
         SELECT Part
         SET ORDER TO 4                   // Locate
         GOTO TOP
         @  0, 8 SAY Control->U_Name
         @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         @  3,10 SAY "Location"
         @  3,28 SAY "Description"
         nl := 4
         nqty := 0
         clocate := SPACE( 16 )
         DO WHILE Part->( !EOF() )
            IF Part->Locate = SPACE( 16 )
               SKIP ALIAS Part
               LOOP        
            ENDIF
            IF Part->Locate = clocate
               nqty += 1
               SKIP ALIAS Part
               LOOP        
            ENDIF
            IF nl > npl
               IF mwhere == "P"
                  EJECT
                  @  0, 8 SAY Control->U_Name
                  @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                              +STR( YEAR(DATE() ),5 )
                  @  3,10 SAY "Location"
                  @  3,28 SAY "Description"
                  nl := 4
               ELSE
                  WAIT
                  nl := 0
                  SCROLL()
               ENDIF
            ENDIF
            @ nl, 0 SAY nqty+1 PICTURE "999,999"  // important here
            nqty := 0
            nl++
            @ nl,10 SAY Part->Locate
            @ nl,28 SAY Part->LocDesc
            @ nl,60 SAY "________"
            clocate := Part->Locate
            SKIP ALIAS Part
         ENDDO
         nl++
         IF mwhere != "P"
            mok := "N"
            DO WHILE mok = "N"
               mok := ApReadN()
            ENDDO
         ELSE
            EndPrint()
            SET MARGIN TO 0
         ENDIF
         RETURN NIL
      ENDIF     // XX
      IF mselect = SPACE( 4 )
         SAVE SCREEN TO tempscr
         SELECT Part
         SET ORDER TO 4                // Locate
         GOTO TOP
         SCROLL()
         aPart_:={}
         nrecno  := 0
         clocate := SPACE( 16 )
         nqty := 0
         DO WHILE Part->( !EOF() )
            IF Part->Locate = clocate
               SKIP ALIAS Part
               LOOP        
            ENDIF
            IF Part->Locate = SPACE( 16 )
               SKIP ALIAS Part
               LOOP        
            ENDIF
            AADD( aPart_,Part->Locate;
                   +" "+Part->LocDesc;
                   +"           "+STR( RECNO(),6 ) )
            clocate := Part->Locate
            SKIP ALIAS Part
         ENDDO
         DISPBOX(  0, 0, 24,52, 2 )
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE(  1, 3, 23,50, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            clocate  := Part->Locate
            cLocdesc := Part->Locdesc
            mselect := SUBSTR( clocate, 1, 4 )
         ENDIF
         RESTORE SCREEN FROM tempscr
      ENDIF                          // mselect
      SCROLL()
      IF PressedEsc()
         RETURN NIL
      ENDIF
      DISPBOX(  1, 0, 24,79, 2 )
      @ 1, 2 SAY " -- WAIT TAKES TIME -- "
      SELECT Part
      SET ORDER TO 4                // Locate
      GOTO TOP
      aPart_:={}
      nrecno := 0
      clocate := SPACE( 16 )
      DO WHILE Part->( !EOF() )
         IF Part->Locate = SPACE( 16 )
            SKIP ALIAS Part
            LOOP        
         ENDIF
         IF Part->Locate = clocate
            SKIP ALIAS Part
            LOOP        
         ENDIF
         mgroup := "  "
         IF mselect != "    "
            DO CASE
               CASE SUBSTR( mselect, 2, 3 ) = "   "
                  IF SUBSTR( Part->Locate, 1, 1 ) != SUBSTR( mselect, 1, 1 )
                    SKIP ALIAS Part
                    LOOP
                  ENDIF
               CASE SUBSTR( mselect, 3, 2 ) = "  "
                  IF SUBSTR( Part->Locate, 1, 2 ) != SUBSTR( mselect, 1, 2 )
                     SKIP ALIAS Part
                     LOOP
                  ENDIF
               CASE SUBSTR( mselect, 4, 1 ) = " "
                  IF SUBSTR( Part->Locate, 1, 3 ) != SUBSTR( mselect, 1, 3 )
                     SKIP ALIAS Part
                     LOOP
                  ENDIF
               CASE mselect != "    "
                  IF SUBSTR( Part->Locate, 1, 4 ) != SUBSTR( mselect, 1, 4 )
                     SKIP ALIAS Part
                     LOOP
                  ENDIF
            ENDCASE

         ENDIF    // mselect = Space 4
         AADD( aPart_,Part->Locate;
            +" "+Part->LocDesc;
            +"   "+"-------";
            +"   "+"-------";
            +"                "+STR( RECNO(),6 ) )
         clocate := Part->Locate  
         mgroup = SUBSTR( Part->Locate, 4, 1 )
         SKIP ALIAS Part
      ENDDO

      SCROLL()
      DISPBOX(  1, 0, 24,79, 2 )
      @ 1, 2 SAY " -- WAIT TAKES TIME -- "
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  2, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
      ENDIF
      IF PressedEsc()
         RETURN NIL
      ENDIF

      mwhere := "S"
      npl    := 54

       Printsel()                                  // _LF_Init

      IF mwhere == "P"
         npl := 56
      ELSE
         SCROLL()
         npl := 22
      ENDIF
      SELECT Part
      SET ORDER TO 4                   // Locate
      GOTO TOP
      @  0, 8 SAY Control->U_Name
      @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
      @  3,10 SAY "Location"
      @  3,28 SAY "Description"
      nl := 4
      nQty  := 0
      clocate := SPACE( 16 )
      DO WHILE Part->( !EOF() )
         IF Part->Locate = SPACE( 16 )
            SKIP ALIAS Part
            LOOP        
         ENDIF
         IF Part->Locate = clocate
            nqty += 1
            SKIP ALIAS Part
            LOOP        
         ENDIF
         IF mselect != "    "
            DO CASE
               CASE SUBSTR( mselect, 2, 3 ) = "   "
                  IF SUBSTR( Part->Locate, 1, 1 ) != SUBSTR( mselect, 1, 1 )
                    SKIP ALIAS Part
                    LOOP
                  ENDIF
               CASE SUBSTR( mselect, 3, 2 ) = "  "
                  IF SUBSTR( Part->Locate, 1, 2 ) != SUBSTR( mselect, 1, 2 )
                     SKIP ALIAS Part
                     LOOP
                  ENDIF
               CASE SUBSTR( mselect, 4, 1 ) = " "
                  IF SUBSTR( Part->Locate, 1, 3 ) != SUBSTR( mselect, 1, 3 )
                     SKIP ALIAS Part
                     LOOP
                  ENDIF
               CASE mselect != "    "
                  IF SUBSTR( Part->Locate, 1, 4 ) != SUBSTR( mselect, 1, 4 )
                     SKIP ALIAS Part
                     LOOP
                  ENDIF
            ENDCASE

         ENDIF // mselect
         IF nl > npl
            IF mwhere == "P"
               EJECT
               @  0, 8 SAY Control->U_Name
               @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                          +STR( YEAR(DATE() ),5 )
               @  3,10 SAY "Location"
               @  3,28 SAY "Description"
               nl := 4
            ELSE
               WAIT
               nl := 0
               SCROLL()
            ENDIF
         ENDIF
         @ nl, 0 SAY nqty+1 PICTURE "999,999"  // important here
         nqty := 0
         nl++
         @ nl,10 SAY Part->Locate
         @ nl,28 SAY Part->LocDesc
         @ nl,60 SAY "________"
         clocate := Part->Locate
         SKIP ALIAS Part
      ENDDO
      nl++
      IF mwhere != "P"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
      ELSE
         EndPrint()
         SET MARGIN TO 0
      ENDIF
      mok := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO
   SELECT Part
   SET ORDER TO 1

   RETURN NIL

   ***** End of File LocDesc()

   ****-------------------------------------------------------------

FUNCTION CatLoc()

   nl  := 0
   mok := "Y"
   DO WHILE mok == "Y"
      ccatno := SPACE(12)
      CatArray()               // Creates array of Catalogue
      SELECT Part
      SET ORDER TO 2                            // Catno + Desc
      SEEK ccatno
      clocate  := SPACE( 16 )
      clocdesc := SPACE( 28 )  
      SELECT Part
      SET ORDER TO 2                // Catno
      GOTO TOP
      aPart_:={}
      nrecno  := 0
      SEEK ccatno 
      DO WHILE Part->Catno = ccatno .AND. Part->( !EOF() )
         ***             IF Part->Catno != ccatno
         ***                SKIP ALIAS Part
         ***                LOOP        
         ***             ENDIF
         IF Part->Locate = clocate
            SKIP ALIAS Part
            LOOP        
         ENDIF
         IF Part->Locate = SPACE( 16 )
            SKIP ALIAS Part
            LOOP        
         ENDIF
         AADD( aPart_,Part->Locate;
             +" "+Part->LocDesc;
             +"           "+STR( RECNO(),6 ) )
         clocate := Part->Locate
         SKIP ALIAS Part
      ENDDO
      SCROLL() 
      DISPBOX(  0, 0, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  2, 3, 23,77, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         clocate  := Part->Locate
         cLocdesc := Part->Locdesc
      ENDIF
      SELECT Part
      SCROLL()
      DISPBOX(  0, 0, 3,79, 2 )
      @  1,10 SAY clocate+" "+clocdesc+"  "+"Location"
      aPart_:={}
      nrecno   := 0
      mpartnum := SPACE( 16 )
      IF LASTREC() != 0
         SET ORDER TO 4      // Location 
         GOTO TOP
         SEEK clocate
         DO WHILE Part->Locate = clocate .AND. Part->( !EOF() )
            ***                IF Part->LocDesc = "    "
            ***                   SKIP ALIAS Part
            ***                   LOOP        
            ***                ENDIF
            IF Part->Catno != ccatno
               SKIP ALIAS Part
               LOOP        
            ENDIF
            AADD( aPart_,Part->Partnum;
               +" "+Part->Desc;
               +" "+Part->Locate; 
               +"             "+STR( RECNO(),6 ) )
            SKIP ALIAS Part
         ENDDO
         DISPBOX( 3, 0, 24,79, 2 )
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE( 4, 2, 23,78, aPart_,,"AFUNC" )
            IF PressedEsc()
               RETURN NIL
            ENDIF
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            mpartnum := Part->Partnum
         ENDIF                // ! Empty
      ENDIF                           // Found
      SELECT Part
      SET ORDER TO 1                         // Partnum + Desc 
      SEEK mpartnum
      mpartnum := Part->Partnum
      IF FOUND()
         PartDets( @mpartnum )
         LOOP 
      ENDIF 
      mok := ApGetN( TRIM( Message->Another )+" Print" )
      IF PressedEsc()
         RETURN NIL
      ENDIF
   ENDDO
   SELECT Part
   SET ORDER TO 1
   RETURN mpartnum

   ***** End of File CatLoc()

   ****-------------------------------------------------------------

FUNCTION LocStk()

   SELECT Part
   SET ORDER TO 4            // Location + Partnum
   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL()
      DISPBOX(  0, 1, 14,79, 2 )
      clocate := SPACE( 16 )
      mselect := SPACE( 4 )
      ngreater := 99999.99
      nQty := 0
      @  2,10 SAY "Listing of Part Location Update"
      @  6, 8 SAY "Instock > " GET nQty PICTURE "9999"
      @  6,COL()+4 SAY "Skip if greater than" GET ngreater PICTURE "99999.99"
      @  8, 8 SAY "Location :" GET mselect PICTURE "@!"
      @  8,COL()+2 SAY "Blank for Select"
       READ
      IF mselect != SPACE( 4 )
         LocSpace()
      ENDIF
      IF PressedEsc()
         RETURN NIL
      ENDIF
      IF mselect = SPACE( 4 )
         SAVE SCREEN TO tempscr
         SELECT Part
         SET ORDER TO 4                // Locate
         GOTO TOP
         SCROLL()
         aPart_:={}
         nrecno  := 0
         clocate := SPACE( 16 )
         DO WHILE Part->( !EOF() )
            IF Part->Locate = clocate
               SKIP ALIAS Part
               LOOP        
            ENDIF
            IF Part->Locate = SPACE( 16 )
               SKIP ALIAS Part
               LOOP        
            ENDIF
            /*
            IF Part->Instock < nqty
               SKIP ALIAS Part
               LOOP        
            ENDIF
            */
            AADD( aPart_,Part->Locate;
                   +" "+Part->LocDesc;
                   +"           "+STR( RECNO(),6 ) )
            clocate := Part->Locate
            SKIP ALIAS Part
         ENDDO
         DISPBOX(  0, 0, 24,52, 2 )
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE(  1, 3, 23,50, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            clocate  := Part->Locate
            cLocdesc := Part->Locdesc
            mselect := SUBSTR( clocate, 1, 4 )
         ENDIF
         RESTORE SCREEN FROM tempscr
      ENDIF                          // Found()  
      IF PressedEsc()
         RETURN NIL
      ENDIF
      mok := "Y"
      DO WHILE mok = "Y"
         SELECT Part
         SET ORDER TO 4            // Location + Partnum
         GOTO TOP
         nrecno := 0
         aPart_ := {}
         SEEK SUBSTR( mselect, 1, 1 )
         DO WHILE SUBSTR( Part->Locate, 1,1 ) = SUBSTR( mselect, 1, 1 );
            .AND. Part->( !EOF() )
            IF Part->Locate = SPACE( 16 )
               SKIP ALIAS Part
               LOOP        
            ENDIF
            IF Part->Instock < nqty
               SKIP ALIAS Part
               LOOP        
            ENDIF
            IF Part->Instock >= ngreater
               SKIP ALIAS Part
               LOOP        
            ENDIF
            AADD( aPart_,SUBSTR( Part->Locate, 1,11 );
               +" "+SUBSTR( Part->Partnum, 1,14 );
               +" "+SUBSTR( Part->Desc, 1,19 );
               +" "+SUBSTR( Part->Unit, 1, 6 );
               +" "+STR( Part->Instock, 9, 3 );
               +"             "+STR( RECNO(),6 ) )
            SKIP ALIAS Part
         ENDDO   // Part EOF
         SCROLL() 
         DISPBOX( 0, 1, 2,79, 2 )
         @ 1, 2 SAY " -- WAIT TAKES TIME -- "+mselect+" "
         @ 1,58 SAY "Instock     Edit"
         DISPBOX( 3, 1, 23,79, 2 )
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE( 4, 3, 22,78, aPart_,,"AFUNC" )
            IF LASTKEY() = 27
               EXIT
            ENDIF  
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            clocate := Part->Locate
            GOTO nrecno
         ENDIF
         IF nrecno = 0
            RETURN NIL
         ENDIF
         ninstock := Part->Instock 
         medit := "N" 
         @ ROW(),66 GET ninstock   PICTURE "99999.999"
         @ ROW(),76 GET medit VALID( medit $"NY" ) PICTURE "!"
          READ
         SELECT Part
          ApRLock( 3 )
         Part->Instock := ninstock
         UNLOCK
         nminstk   := Part->MinStk
         nmaxstk   := Part->MaxStk
         mdesc     := Part->Desc
         mweight   := Part->Weight
         msuplcode := Part->Codeno
         mpartnum  := Part->Partnum
      
         // EDIT File
         IF medit = "Y"
            SCROLL( 6, 2, 23,78 )
            clocate  := Part->Locate
            clocDesc := Part->Locdesc
            mlookup  := Part->Locate
            @  8, 8 SAY Part->Catno+"   "+Part->PartId COLOR "RG+"
            @ 10, 8 SAY Part->Locate+"  "+Part->LocDesc COLOR "RG+"
            @ 12, 8 SAY "Location :" GET mlookup PICTURE "@!"
            @ 12,COL()+2 SAY "Blank for Look up"
             READ
            IF mlookup = SPACE( 4 )
               SAVE SCREEN TO tempscr
               SELECT Part
               SET ORDER TO 4                // Locate
               GOTO TOP
               SCROLL()
               aPart_:={}
               nrecno  := 0
               clocate := SPACE( 16 )
               DO WHILE Part->( !EOF() )
                  IF Part->Locate = clocate
                     SKIP ALIAS Part
                     LOOP        
                  ENDIF
                  IF Part->Locate = SPACE( 16 )
                     SKIP ALIAS Part
                     LOOP        
                  ENDIF
                  IF Part->Instock < nqty
                     SKIP ALIAS Part
                     LOOP        
                  ENDIF
                  AADD( aPart_,Part->Locate;
                         +" "+Part->LocDesc;
                         +"           "+STR( RECNO(),6 ) )
                  clocate := Part->Locate
                  SKIP ALIAS Part
               ENDDO
               DISPBOX(  1, 1, 24,58, 2 )
               IF !EMPTY( aPart_ )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE(  2, 3, 23,56, aPart_,,"AFUNC" )
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
               ENDIF
               RESTORE SCREEN FROM tempscr
            ENDIF                          // Found()  
            clocate  := Part->Locate
            cLocdesc := Part->Locdesc
            SCROLL( 11, 4, 20,76 )
            SELECT Part
            SET ORDER TO 1                 // Partnum
            SEEK mpartnum
             ApRLock( 3 )
            Part->Locate   := clocate
            Part->LocDesc  := clocDesc
            @  12, 8      SAY "Location" GET Part->Locate   PICTURE "@!"
            @  12,COL()+2 SAY "Desc"     GET Part->Locdesc  PICTURE "@X"
            READ
            UNLOCK 
            @ 14, 8      GET mdesc
            @ 16, 8      SAY "Minimum"  GET nminstk   PICTURE "99999.99"
            @ 16,COL()+2 SAY "Optimum"  GET nmaxstk   PICTURE "99999.99"
            @ 16,COL()+2 SAY "Weight"   GET mweight   PICTURE "9999.99"                  
            @ 18, 8      SAY "Suppl Codeno " GET msuplcode PICTURE "@K!"
             READ
            SELECT Name
            SEEK msuplcode
            DO WHILE !FOUND()

               SAVE SCREEN TO Partscrn
                Namerank( @mcodeno )                       // XlF_Name
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               SELECT Name
               SEEK mcodeno
               RESTORE SCREEN FROM Partscrn
            ENDDO   
            SELECT Part
            ApRLock( 3 )
            ***          Part->Instock := ninstock
            Part->MinStk  := nminstk
            Part->MaxStk  := nmaxstk
            Part->Desc    := mdesc
            Part->Weight  := mweight
            Part->Codeno  := Name->Codeno
            UNLOCK
            @ 18,45 SAY Part->Codeno COLOR "BG+"
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
            @ 16,67 PROMPT "Each  "
            @ 17,67 PROMPT "Mtr   "
            @ 18,67 PROMPT "Sq Mtr"
            @ 19,67 PROMPT "Cu Mtr"
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
            DO CASE 
               CASE Part->Boughtout = "Y"
                  nselect := 1
               OTHERWISE
                  nselect := 2
            ENDCASE
            @ 19,20      PROMPT "Part Bought Out"
            @ 19,COL()+2 PROMPT "Own Manufacture"
            MENU TO nselect
             ApFLock( 3 )
            DO CASE
               CASE nselect == 1
                  Part->Boughtout := "Y"
               CASE nselect == 2
                  Part->Boughtout := "N"
            ENDCASE
            UNLOCK
            nl := 21 
            SELECT Part
            ApRLock( 3 )
            IF Part->Markup == 0
               Part->Markup := Cat->Markup
            ENDIF
            UNLOCK
            ntrade  := Part->Trade
            nmarkup := Part->Markup
            @ nl, 6 SAY TRIM( Part->Unit )+" Cost   " GET ntrade PICTURE "999999.99"
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
            ntradeDate := Part->Trade
            nl+=2
            @ nl, 6      SAY TRIM( Part->Unit )+" Sell exl GST";
                         GET nwholesale PICTURE "999999.99"
            READ
            ApRLock( 3 )
            Part->Wholesale := nwholesale   
            Part->Markup := ( ( Part->Wholesale-Part->Trade ) / Part->Trade ) *100
            IF Part->Trade != ntradeDate
               Part->Date := DATE()
            ENDIF
            UNLOCK
            mdetails = "N"
            @ nl,48 SAY "Go to Part Details" GET mdetails PICTURE "!"
             READ
            IF mdetails = "Y"
               PartDets( mpartnum )
               LOOP
            ENDIF
            IF PressedEsc()
               RETURN NIL
            ENDIF 
         ENDIF   // medit
         LOOP
      ENDDO   // mok
   ENDDO                    // mcontinue
   COMMIT
   SELECT Part
   SET ORDER TO 1                  // Partnum
   RETURN NIL

   ****  End of LocStk()

   ***---------------------------------------------------------------------*

FUNCTION LocPart()

   nl  := 0
   mok := "Y"
   DO WHILE mok == "Y"
      SCROLL()
      mselect := SPACE( 4 )
      DISPBOX(  0, 1, 14,79, 2 )
      nQty := 0
       @  2,10 SAY "Listing of Part by Location"
       @  6, 8 SAY "Instock > " GET nQty PICTURE "999.99"
       @  8, 8 SAY "Location :" GET mselect PICTURE "@!"
       @  8,COL()+2 SAY "Blank for Look up"
        READ
       IF PressedEsc()
          RETURN NIL
       ENDIF 
          IF mselect = SPACE( 4 )
             SAVE SCREEN TO tempscr
             SELECT Part
             SET ORDER TO 4                // Locate
             GOTO TOP
             SCROLL()
             aPart_:={}
             nrecno  := 0
             clocate := SPACE( 16 )
             DO WHILE Part->( !EOF() )
                IF Part->Locate = clocate
                   SKIP ALIAS Part
                   LOOP        
                ENDIF
                IF Part->Locate = SPACE( 16 )
                   SKIP ALIAS Part
                   LOOP        
                ENDIF
                IF Part->Instock < nqty
                   SKIP ALIAS Part
                   LOOP        
                ENDIF
                AADD( aPart_,Part->Locate;
                       +" "+Part->LocDesc+" "+STR( Part->Instock, 8, 2 );
                       +"           "+STR( RECNO(),6 ) )
                clocate := Part->Locate
                SKIP ALIAS Part
             ENDDO
             DISPBOX(  0, 0, 24,52, 2 )
                IF !EMPTY( aPart_ )
                   ASORT( aPart_,,,{ | x,y | x < y } )
                   anum := ACHOICE(  1, 3, 23,50, aPart_,,"AFUNC" )
                   nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                   GOTO nrecno
                   clocate  := Part->Locate
                   cLocdesc := Part->Locdesc
                   mselect := SUBSTR( clocate, 1, 4 )
                ENDIF
                RESTORE SCREEN FROM tempscr
            ENDIF                          // Found()  
       SCROLL()
       DISPBOX(  1, 0, 24,79, 2 )
       @ 1, 2 SAY " -- WAIT TAKES TIME -- "
       IF mselect != "    "
             SELECT Part
             SET ORDER TO 4                // Locate
             GOTO TOP
             aPart_:={}
             nrecno  := 0
             clocate := SPACE( 16 )
             DO WHILE Part->( !EOF() )
                IF Part->Locate = SPACE( 16 )
                   SKIP ALIAS Part
                   LOOP        
                ENDIF
                IF Part->Instock < nqty
                   SKIP ALIAS Part
                   LOOP        
                ENDIF
                IF Part->LocDesc = SPACE( 16 )
                   SKIP ALIAS Part
                   LOOP        
                ENDIF
              DO CASE
                 CASE SUBSTR( mselect, 2, 3 ) = "   "
                 IF SUBSTR( Part->Locate, 1, 1 ) != SUBSTR( mselect, 1, 1 )
                  SKIP ALIAS Part
                  LOOP
               ENDIF
            CASE SUBSTR( mselect, 3, 2 ) = "  "
               IF SUBSTR( Part->Locate, 1, 2 ) != SUBSTR( mselect, 1, 2 )
                  SKIP ALIAS Part
                  LOOP
               ENDIF
            CASE SUBSTR( mselect, 4, 1 ) = " "
               IF SUBSTR( Part->Locate, 1, 3 ) != SUBSTR( mselect, 1, 3 )
                  SKIP ALIAS Part
                  LOOP
               ENDIF
            CASE mselect != "    "
               IF SUBSTR( Part->Locate, 1, 4 ) != SUBSTR( mselect, 1, 4 )
                  SKIP ALIAS Part
                  LOOP
               ENDIF
         ENDCASE
              AADD( aPart_,SUBSTR( Part->Locate, 1,11 );
                           +" "+SUBSTR( Part->Partnum, 1,15 );
                           +" "+SUBSTR( Part->Desc, 1,20 );
                           +" "+SUBSTR( Part->LocDesc, 1,14 );
                           +" "+STR( Part->InStock, 8 , 2 );
                            +"              "+STR( RECNO(),6 ) )
                   SKIP ALIAS Part
             ENDDO
             SCROLL()
             DISPBOX(  1, 0, 24,79, 2 )
             @ 1, 2 SAY " -- WAIT TAKES TIME -- "
                IF !EMPTY( aPart_ )
                   ASORT( aPart_,,,{ | x,y | x < y } )
                   anum := ACHOICE(  2, 3, 23,78, aPart_,,"AFUNC" )
                   nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                   GOTO nrecno
                ENDIF
            ENDIF       // mselect           
         IF PressedEsc()
           RETURN NIL
         ENDIF 

      mwhere := "S"
      npl    := 54

       Printsel()                                  // _LF_Init

   IF mwhere == "P"
      ***   SET MARGIN TO 1
      npl := 56
    ELSE
      SCROLL()
      npl := 22
   ENDIF
      SELECT Part
      SET ORDER TO 4                   // Locate
      GOTO TOP
   @  0, 2 SAY Control->U_Name
   @  0,40 SAY mselect 
   @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  3, 0 SAY "Location"
   @  3,18 SAY "Part #"
   @  3,62 SAY "Stock"
   nl := 4
      *** nqty := 0
      ntotal:= ncattotal:= 0
        DO WHILE Part->( !EOF() )
         IF mselect != "    "
              DO CASE
                 CASE SUBSTR( mselect, 2, 3 ) = "   "
                 IF SUBSTR( Part->Locate, 1, 1 ) != SUBSTR( mselect, 1, 1 )
                  SKIP ALIAS Part
                  LOOP
               ENDIF
            CASE SUBSTR( mselect, 3, 2 ) = "  "
               IF SUBSTR( Part->Locate, 1, 2 ) != SUBSTR( mselect, 1, 2 )
                  SKIP ALIAS Part
                  LOOP
               ENDIF
            CASE SUBSTR( mselect, 4, 1 ) = " "
               IF SUBSTR( Part->Locate, 1, 3 ) != SUBSTR( mselect, 1, 3 )
                  SKIP ALIAS Part
                  LOOP
               ENDIF
            CASE mselect != "    "
               IF SUBSTR( Part->Locate, 1, 4 ) != SUBSTR( mselect, 1, 4 )
                  SKIP ALIAS Part
                  LOOP
               ENDIF
         ENDCASE
                IF Part->Instock < nqty
                   SKIP ALIAS Part
                   LOOP        
                ENDIF
   /*
                DO WHILE Part->Locate = clocate
                   nqty += 1
                   SKIP ALIAS Part
                   LOOP        
                ENDDO
   */
                IF Part->Locate = SPACE( 16 )
                   SKIP ALIAS Part
                   LOOP        
                ENDIF
            ENDIF // mselect

         IF nl > npl
             IF mwhere == "P"
                EJECT
                @  0, 2 SAY Control->U_Name
   @  0,40 SAY mselect 
   @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  3, 0 SAY "Location"
   @  3,18 SAY "Part #"
   @  3,62 SAY "Stock"
   nl := 4
               ELSE
                WAIT
                nl := 0
                SCROLL()
             ENDIF
         ENDIF
         @ nl, 0 SAY Part->Locate
         @ nl,18 SAY SUBSTR( Part->Partnum, 1,16 )  
         @ nl,36 SAY SUBSTR( Part->Desc, 1,25 )
         @ nl,62 SAY Part->Instock  PICTURE "9,999.99"
         @ nl,71 SAY "_______"
         ntotal += Part->Instock*Part->Trade
         nl++
         SKIP ALIAS Part
      ENDDO
      nl++
      @ nl,28 SAY "Locate Qty*Trade Total"
      @ nl,53 SAY ntotal PICTURE "$9,999,999.99"
      nl++
      IF mwhere != "P"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
         SET MARGIN TO 0
      ENDIF
      mok := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO
   SET ORDER TO 1

   RETURN NIL

   ***** End of File LocPart()

   ****-------------------------------------------------------------

STATIC FUNCTION PaDescLoc()     // 

   nl  := 0
   mok := "Y"
   DO WHILE mok == "Y"
      mcorrect := "Y"
      ntotal:= ncattotal:= 0
      mallCat := "N"
      IF PressedEsc()
        RETURN NIL
      ENDIF

      mwhere := "S"
      npl    := 56
      SCROLL()

       Printsel()                                  // _LF_Init

      IF mwhere == "P"
         npl := 56
       ELSE
         SCROLL()
         npl := 22
      ENDIF
      SELECT Part
      SET ORDER TO 2                   // Catno+Locate
      GOTO TOP
      @  0, 8 SAY Control->U_Name
      @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
      @  3, 0 SAY "Part #"
      @  3,17 SAY "Description"
      @  3,41 SAY "Locate"  
      @  3,54 SAY "Catno"
      @  3,60 SAY "Min Stk"  
      @  3,69 SAY "In Stock" 
      nl := 4
      DO WHILE Part->( !EOF() )
         IF nl > npl
            IF mwhere == "P"
                EJECT
               ELSE
                WAIT
                nl := 0
                SCROLL()
             ENDIF
             @  0, 8 SAY Control->U_Name
             @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                        +STR( YEAR(DATE() ),5 )
             @  3, 0 SAY "Part #"
             @  3,17 SAY "Description"
             @  3,41 SAY "Locate"  
             @  3,54 SAY "Catno"
             @  3,60 SAY "Min Stk"  
             @  3,69 SAY "In Stock" 
             nl := 4
         ENDIF
         IF Part->Instock > 0
            @ nl, 0 SAY SUBSTR( Part->Partnum, 1,16 )  
            @ nl,17 SAY SUBSTR( Part->Desc, 1,23 )
            @ nl,41 SAY SUBSTR( Part->Locate, 1,12 )
            @ nl,54 SAY SUBSTR( Part->Catno, 1, 4 ) 
            @ nl,60 SAY Part->MinStk PICTURE "9999.99"
            @ nl,67 SAY Part->Instock PICTURE "9999.99"
            @ nl,74 SAY "_____"
            nl++
            ncattotal += Part->Instock*Part->Trade
         ENDIF 
         SELECT Part
         SKIP ALIAS Part
        ENDDO
        nl++
        @ nl,30 SAY ncattotal PICTURE "$9,999,999.99"
        nl++
      IF mwhere != "P"
         IF nl > 18
            nl++
            WAIT
         ENDIF     
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
      ENDIF
      mok := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO      // mok
   SELECT Part
   SET ORDER TO 1                   // Partnum

   RETURN NIL

   ***** End of File PaDescLoc

   *---------------------------------------------------------------------*

STATIC FUNCTION PartSect()

   nl  := 0
   mok := "Y"
   DO WHILE mok == "Y"
      mcorrect := "Y"
      ntotal:= ncattotal:= 0
      mallCat := ApGetY( "Do You Want All Catalog" )
      IF mallCat  == "Y"
      IF PressedEsc()
        RETURN NIL
      ENDIF

      mwhere := "S"
      npl    := 56
      SCROLL()

       Printsel()                                  // _LF_Init

      IF mwhere == "P"
         npl := 56
       ELSE
         SCROLL()
         npl := 22
      ENDIF
      SELECT Part
      SET ORDER TO 4                   // Locate
      GOTO TOP
      @  0, 8 SAY Control->U_Name
      @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
      @  3, 0 SAY "Locate"
      @  3,17 SAY "Part #"
      @  3,34 SAY "Description"
      @  3,56 SAY "Catno"
      @  3,61 SAY "Min Stk"
      @  3,69 SAY "In Stock" 
      nl := 4
      DO WHILE Part->( !EOF() )
         IF nl > npl
            IF mwhere == "P"
                EJECT
               ELSE
                WAIT
                nl := 0
                SCROLL()
             ENDIF
             @  0, 8 SAY Control->U_Name
             @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                        +STR( YEAR(DATE() ),5 )
             @  3, 0 SAY "Locate"
             @  3,17 SAY "Part #"
             @  3,34 SAY "Description"
             @  3,56 SAY "Catno"
             @  3,61 SAY "Min Stk" 
             @  3,69 SAY "In Stock" 
             nl := 4
         ENDIF
         IF Part->Instock > 0
            @ nl, 0 SAY Part->Locate
            @ nl,17 SAY SUBSTR( Part->Partnum, 1,16 ) 
            @ nl,34 SAY SUBSTR( Part->Desc, 1,21 )
            @ nl,56 SAY SUBSTR( Part->Catno, 1, 4 )
            @ nl,61 SAY Part->MinStk PICTURE "9999.99"
            @ nl,69 SAY Part->Instock PICTURE "9999.99"
            @ nl,76 SAY "_____"
            nl++
            ncattotal += Part->Instock*Part->Trade
         ENDIF 
         SELECT Part
         SKIP ALIAS Part
        ENDDO
        nl++
        @ nl,30 SAY ncattotal PICTURE "$9,999,999.99"
        nl++

         ELSE

      nl  := 0
      SELECT Part
      SET ORDER TO 2                   // Catno
      GOTO TOP
      CatArray()
      ccatno    := Cat->Catno      // SPACE(4)
      mcatdesc  := Cat->CatDesc
      mmajorind := Cat->Catno
      IF PressedEsc()
        RETURN NIL
      ENDIF
      minstock := ApGetY( "Do You Want Instock ONLY" )
      mwhere := "S"
      npl    := 56
      SCROLL()

       Printsel()                                  // _LF_Init

      IF mwhere == "P"
         npl := 56
       ELSE
         SCROLL()
         npl := 22
      ENDIF
             @  0, 8 SAY Control->U_Name
             @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                        +STR( YEAR(DATE() ),5 )
             @  1, 5 SAY mcatdesc
             @  3, 0 SAY "Part #"
             @  3,17 SAY "Description"
             @  3,48 SAY "Locate"  
             @  3,66 SAY "In Stock" 
             nl := 4
      SELECT Part
      SEEK ccatno  
      DO WHILE Part->Catno = ccatno .AND. Part->( !EOF() )
         IF nl > npl
            IF mwhere == "P"
                EJECT
               ELSE
                WAIT
                nl := 0
                SCROLL()
             ENDIF
             @  0, 8 SAY Control->U_Name
             @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                        +STR( YEAR(DATE() ),5 )
             @  1, 5 SAY mcatdesc
             @  3, 0 SAY "Part #"
             @  3,17 SAY "Description"
             @  3,48 SAY "Locate"  
             @  3,66 SAY "In Stock" 
             nl := 4
         ENDIF
            IF minstock = "N" 
               @ nl, 0 SAY SUBSTR( Part->Partnum, 1,16 )  
               @ nl,17 SAY SUBSTR( Part->Desc, 1,30 )
               @ nl,48 SAY Part->Locate 
               @ nl,65 SAY Part->Instock PICTURE "99999.99"
               @ nl,74 SAY "_____"
               nl++ 
              ELSE
               IF Part->Instock > 0
                  @ nl, 0 SAY SUBSTR( Part->Partnum, 1,16 )  
                  @ nl,17 SAY SUBSTR( Part->Desc, 1,30 )
                  @ nl,48 SAY Part->Locate 
                  @ nl,65 SAY Part->Instock PICTURE "99999.99"
                  @ nl,74 SAY "_____"
                  nl++
               ENDIF
            ENDIF 
         ncattotal += Part->Instock*Part->Trade
         SELECT Part
         SKIP ALIAS Part
      ENDDO
       nl++
        @ nl,30 SAY ncattotal PICTURE "$9,999,999.99"

      ENDIF // mallCat
      IF mwhere != "P"
         IF nl > 18
            nl++
            WAIT
         ENDIF     
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
      ENDIF
      mok := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO
        mcatlist := ApGetY( "Do You Want Catalog Amounts" )
        IF mcatlist = "Y"
              npl    := 54
              SCROLL()
    mwhere := "S" 

       Printsel()                                  // _LF_Init

   IF mwhere == "P"
      SET MARGIN TO 1
      npl := 56
    ELSE
      SCROLL()
      npl := 22
   ENDIF
   ntotal := 0 

   @  0, 8 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
      nl := 2
      SELECT Cat
      GOTO TOP
      DO WHILE Cat->( !EOF() )
         IF nl > npl
             IF mwhere == "P"
                EJECT
                @  0, 8 SAY Control->U_Name
                @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                           +STR( YEAR(DATE() ),5 )
                nl := 2
               ELSE
                WAIT
                nl := 0
                SCROLL()
             ENDIF
         ENDIF
         ccatno := Cat->Catno
         nstockCost := 0
       SELECT Part
       SET ORDER TO 2
       SEEK ccatno
       DO WHILE Part->Catno == ccatno .AND. Part->( !EOF() )
          nStockCost += Part->Instock*Part->Trade  
          SKIP ALIAS Part 
       ENDDO
       SELECT Cat 
            @ nl, 0 SAY Cat->Catno
            @ nl,14 SAY Cat->CatDesc
            IF nstockcost > 0
               @ nl,64 SAY nstockCost PICTURE "$9,999,999.99"
            ENDIF
            ntotal += nstockcost
            nl++
         SKIP ALIAS Cat
      ENDDO
      nl++
      nl++
      @ nl,10 SAY "Instock * Trade"
      @ nl,45 SAY ntotal PICTURE "$9,999,999.99"
      IF mwhere != "P"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
      ENDIF
       ENDIF   // mcatlist
   SELECT Part
   SET ORDER TO 1                   // Partnum

   RETURN NIL

   ***** End of File PartSect

   ****---------------------------------------------------------------------*

FUNCTION AllOrders()

   nl  := 0
   mok := "Y"
   DO WHILE mok == "Y"
      mwhere := "S"
      npl    := 54
      SCROLL()

       Printsel()                                  // _LF_Init

   IF mwhere == "P"
      SET MARGIN TO 1
      npl := 56
    ELSE
      SCROLL()
      npl := 22
   ENDIF
      SELECT Orders
      GOTO TOP
   @  0, 8 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  3, 0 SAY "Part #"
   @  3,46 SAY "Order #"
   @  3,52 SAY "Date"
   @  3,63 SAY "Ordered"
   @  3,72 SAY "Outstand"
   nl := 4
      ntotal:= ncattotal:= 0
      DO WHILE Orders->( !EOF() )
         IF Orders->PartQty = Orders->Qtyrec
            SKIP ALIAS Orders
            LOOP
         ENDIF 
         IF nl > npl
             IF mwhere == "P"
                EJECT
                @  0, 8 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  3, 0 SAY "Part #"
   @  3,46 SAY "Order #"
   @  3,52 SAY "Date"
   @  3,63 SAY "Ordered"
   @  3,72 SAY "Outstand"
   nl := 4
               ELSE
                WAIT
                nl := 0
                SCROLL()
             ENDIF
         ENDIF
         @ nl, 0 SAY SUBSTR( Orders->Partnum, 1,16 )
         SELECT Part
         SEEK Orders->Partnum
         @ nl,18 SAY SUBSTR( Part->Desc, 1,24 )
         SELECT Orders
         @ nl,45 SAY Orders->Ordnum
         @ nl,51 SAY DTOC( Orders->Date )           PICTURE "99/99/9999"
         @ nl,62 SAY Orders->Qtyrec                 PICTURE "9,999.99"
         @ nl,71 SAY Orders->Qtyrec-Orders->PartQty PICTURE "99,999.99"
         nl++
         SKIP ALIAS Orders
      ENDDO
      nl++
      ***   @ nl,45 SAY "Total"
      ***   @ nl,52 SAY ntotal PICTURE "9,999,999.99"
      ***   nl++
      IF mwhere != "P"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
         SET MARGIN TO 0
      ENDIF
      mok := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO

      RETURN NIL

   ***** End of File AllOrders()

   ****-------------------------------------------------------------

FUNCTION PartLoc()

   nl  := 0
   mok := "Y"
   DO WHILE mok == "Y"
      CatArray()
      ccatno := Cat->Catno      // SPACE(4)
      mcatdesc  := Cat->CatDesc
      mmajorind := Cat->Catno
      mfind  := SPACE(4)
      SCROLL()
      mboughtout := "N" 
      **** ApGetY( "Bought Out Only" )

      mwhere := "S"
      npl    := 54
      SCROLL()

       Printsel()                                  // _LF_Init

   IF mwhere == "P"
      SET MARGIN TO 1
      npl := 56
    ELSE
      SCROLL()
      npl := 22
   ENDIF
   @  0, 8 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  1, 5 SAY mcatdesc
   @  3, 0 SAY "Location"
   @  3,42 SAY "Part #"
   @  3,60 SAY "Stock"
   @  3,70 SAY "Cost"
   nl := 4
      ntotal:= ncattotal:= 0
      SELECT Part
      SET ORDER TO 2                   // Catno+Locate
      GOTO TOP
      SEEK ccatno
      DO WHILE Part->Catno = ccatno .AND. Part->( !EOF() )
         IF nl > npl
             IF mwhere == "P"
                EJECT
                @  0, 8 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  1, 5 SAY mcatdesc
   @  3, 0 SAY "Location"
   @  3,42 SAY "Part #"
   @  3,60 SAY "Stock"
   @  3,70 SAY "Cost"
   nl := 4
               ELSE
                WAIT
                nl := 0
                SCROLL()
             ENDIF
         ENDIF
         @ nl, 0 SAY Part->Locate
         @ nl,17 SAY SUBSTR( Part->LocDesc, 1,23 )
         @ nl,42 SAY SUBSTR( Part->Partnum, 1,16 )  
         @ nl,60 SAY Part->Instock  PICTURE "99,999.99"
         @ nl,70 SAY Part->Trade    PICTURE "99,999.99"
         ntotal += Part->Instock*Part->Trade
         nl++
         SKIP ALIAS Part
      ENDDO
      nl++
      @ nl,45 SAY "Total"
      @ nl,52 SAY ntotal PICTURE "9,999,999.99"
      nl++
      IF mwhere != "P"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
         SET MARGIN TO 0
      ENDIF
      mok := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO
   SET ORDER TO 1

   RETURN NIL

   ***** End of File PartLoc()

   ****-------------------------------------------------------------

FUNCTION Mu_PartList()

   LOCAL cheading, nselect

   DO WHILE .T.

      nselect  := 0
      nc       := ncl*2
      SCROLL(  3,nc, 21,78 )
      DISPBOX( 4,nc, 21,nc+ncl )
      SCROLL(  3,nc+4, 5,nc+( ncl-4) )
      DISPBOX( 3,nc+4, 5,nc+( ncl-4) )
      @  4,nc+( ncl/2 )-( LEN( RTRIM( Menu2->CH_PLstHd ) )/2 );
                           SAY RTRIM( Menu2->CH_PLstHd )
      @  7,nc+2 PROMPT "1. Location           "
      @  9,nc+2 PROMPT "2. Partno+Desc _______"  
      @ 11,nc+2 PROMPT "3. Loc+#+Desc+Qty ____" 
      @ 12,nc+2 PROMPT "4. Desc+Unit+Qty+Cost "
      @ 13,nc+2 PROMPT "5. Catalogue Qty Price"
      @ 14,nc+2 PROMPT "6. Catalogue+Group    "
      @ 15,nc+2 PROMPT "7. Supplier List      "
      @ 17,nc+2 PROMPT "8. Catalogue+Location "
      @ 18,nc+2 PROMPT "9. #+Desc+Loc+Qty ____" 
      @ 20,nc+2 PROMPT Menu->CH_Main+"   "
      nc := ncl 
      MENU TO nselect
      DO CASE
         CASE nselect == 10 .OR. PressedEsc()
              RETURN NIL
         CASE nselect == 1
            SAVE SCREEN TO Invscrn
             LocPart()                      // Above
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 2
            SAVE SCREEN TO Invscrn
             PartList()                      // Below
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 3
            SAVE SCREEN TO Invscrn
              PartSect()                    // Below
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 4
            SAVE SCREEN TO Invscrn
              PartTrade()                    // Below
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 5
            SAVE SCREEN TO Invscrn
              CatPrice()                    // Below
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 6
            SAVE SCREEN TO Invscrn
              CatGroup()
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 7
            SAVE SCREEN TO Invscrn
              SuppList()
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 8
            SAVE SCREEN TO Invscrn
             PartLoc()                      // Above
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 9
            SAVE SCREEN TO Invscrn
             PaDescLoc()                    // Above
            RESTORE SCREEN FROM Invscrn
      ENDCASE
   ENDDO

   RETURN NIL

   ***** End of Mu-PartList()

   *---------------------------------------------------------------------*

   STATIC FUNCTION SuppList()

   mcodeno := SPACE( 8 )
    NameRank( mcodeno )
   mcodeno := Name->Codeno
   SELECT Part
   INDEX ON Part->Codeno+Part->Partnum TO PartCode
   SET INDEX TO PartCode
   GOTO TOP
   SEEK mcodeno
   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
   @  1,10 SAY TRIM( Name->Name )+" Suppliers Part ID "
   aPart_:={}
   nrecno   := 0
   mpartnum:= msuplId := SPACE( 20 )
   IF LASTREC() != 0
      DO WHILE Part->Codeno = mcodeno .AND. Part->( !EOF() )
         SELECT Supl
         SET ORDER TO 1       // Partnum
         SEEK Part->Partnum
         IF FOUND()
            IF Supl->Codeno = mcodeno 
               msuplId := Supl->SuppId
            ENDIF
         ENDIF
         SELECT Part
         AADD( aPart_,Part->Partnum;
             +" "+Part->Desc+" "+msuplId;
             +"                  "+STR( RECNO(),6 ) )
         SKIP ALIAS Part
         msuplId := SPACE( 20 )
      ENDDO                    // Part
      DISPBOX( 3, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 4, 3, 23,78, aPart_,,"AFUNC" )
         /*
         IF PressedEsc()
            SELECT Part
            SET INDEX TO PartInd
            SEEK mpartnum
            mpartnum := Part->Partnum     
            RETURN mpartnum
         ENDIF
         */ 
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         mpartnum := Part->Partnum 
      ENDIF                        // !Empty
   ENDIF                           // LastRec
   mwhere := "S"
   npl    := 54
   SCROLL()

    Printsel()                                  // _LF_Init

   IF mwhere == "P"
      SET MARGIN TO 0
      npl := 56
    ELSE
      SCROLL()
      npl := 22
   ENDIF
      SELECT Part
      ****   SET ORDER TO 2                   // Catno
      GOTO TOP
      SEEK mcodeno
   @  0, 8 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  2, 0 SAY "Part #"
   @  2,20 SAY "Description"
   @  2,60 SAY "Stock"
   @  2,70 SAY "Cost"
   nl := 3
      ntotal:= ncattotal:= 0
                  DO WHILE Part->Codeno = mcodeno .AND. Part->( !EOF() )
                     SELECT Supl
                     SET ORDER TO 1       // Partnum
                     SEEK Part->Partnum
                     IF FOUND()
                        IF Supl->Codeno = mcodeno 
                           msuplId := Supl->SuppId
                        ENDIF
                     ENDIF
         IF nl > npl
             IF mwhere == "P"
                EJECT
                @  0, 8 SAY Control->U_Name
                @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                           +STR( YEAR(DATE() ),5 )
                @  2, 0 SAY "Part #"
                @  2,20 SAY "Description"
                @  2,60 SAY "Stock"
                @  2,70 SAY "Cost"
                nl := 3
              ELSE
                WAIT
                nl := 0
                SCROLL()
             ENDIF
         ENDIF
         @ nl, 0 SAY SUBSTR( Part->Partnum,1,16 )  
         @ nl,18 SAY Part->Desc
    ***     @ nl,41 SAY Part->Unit
         @ nl,60 SAY Part->Instock  PICTURE "99,999.99"
         @ nl,70 SAY Part->Trade    PICTURE "999,999.99"
         ntotal += Part->Instock*Part->Trade
         nl++
         SKIP ALIAS Part
      ENDDO
      nl++
      @ nl,30 SAY "Stock*Cost Total"
      @ nl,52 SAY ntotal PICTURE "$9,999,999.99"
      nl++
      IF mwhere != "P"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
         SET MARGIN TO 0
      ENDIF
      ***   mok := ApGetN( TRIM( Message->Another )+" Print" )
       SELECT Part
       SET INDEX TO PartInd
      SET ORDER TO 1

      RETURN NIL

      ***** End of File SuppList()

      ****---------------------------------------------------------------------*

   FUNCTION CatPrice()

   mok := "Y"
   DO WHILE mok == "Y"
      mprint := ApGetY( "Only Catalogues above $0.00"  )
      ccatno := SPACE( 12 ) 
      mwhere := "S"
      npl    := 54
      SCROLL()

       Printsel()                                  // _LF_Init

   IF mwhere == "P"
      SET MARGIN TO 1
      npl := 56
    ELSE
      SCROLL()
      npl := 22
   ENDIF
   @  0, 8 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   nl := 2
      SELECT Part
      SET ORDER TO 2                   // Catno
      GOTO TOP
      ntotal:= ncattotal:= 0
      ccatno := Part->Catno
      DO WHILE Part->( !EOF() )
         IF nl > npl
             IF mwhere == "P"
                EJECT
                @  0, 8 SAY Control->U_Name
                @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                           +STR( YEAR(DATE() ),5 )
                nl := 2
               ELSE
                WAIT
                nl := 0
                SCROLL()
             ENDIF
         ENDIF
         IF Part->Catno != ccatno 
            SELECT Cat
            SEEK ccatno
      ***         IF !FOUND()
      ***            @ nl,14 SAY "No Catalogue"
      ***            nl++
      ***          ELSE
               IF mprint = "N" 
                  @ nl, 0 SAY Cat->Catno
                  @ nl,14 SAY Cat->CatDesc
                  @ nl,65 SAY ncattotal PICTURE "9,999,999.99"
                  nl++
                 ELSE
                  IF ncattotal > 0
                     @ nl, 0 SAY Cat->Catno
                     @ nl,14 SAY Cat->CatDesc
                     @ nl,65 SAY ncattotal PICTURE "9,999,999.99"
                     nl++
                  ENDIF 
               ENDIF 
      ***         ENDIF  
            ccatno := Part->Catno
            ncattotal := 0
            SELECT Part
         ENDIF  
         ncattotal += Part->Instock*Part->Trade
         ntotal    += Part->Instock*Part->Trade
         SKIP ALIAS Part
      ENDDO
      nl++
      @ nl,55 SAY "Total"
      @ nl,65 SAY ntotal PICTURE "9,999,999.99"
      nl++
      IF mwhere != "P"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
      ENDIF
      mok := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO
   SET ORDER TO 1

   RETURN NIL

   ***** End of File CatPrice()

   *---------------------------------------------------------------------*

STATIC FUNCTION PartTrade()

   nl  := 0
   mok := "Y"
   DO WHILE mok == "Y"
      CatArray()
      ccatno := Cat->Catno      // SPACE(4)
      mcatdesc  := Cat->CatDesc
      mmajorind := Cat->Catno
      mfind  := SPACE(4)
      SCROLL()
      mboughtout := "N" 
      **** ApGetY( "Bought Out Only" )

      mwhere := "S"
      npl    := 54
      SCROLL()

       Printsel()                                  // _LF_Init

   IF mwhere == "P"
      SET MARGIN TO 1
      npl := 56
    ELSE
      SCROLL()
      npl := 22
   ENDIF
      SELECT Part
      SET ORDER TO 2                   // Catno
      GOTO TOP
   @  0, 8 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  1, 5 SAY mcatdesc
      *** @  3, 0 SAY "Part #"
   @  3, 0 SAY "Description"
   @  3,52 SAY "Stock"
   @  3,63 SAY "Cost"
   nl := 4
      ntotal:= ncattotal:= 0
      SEEK ccatno
      DO WHILE Part->Catno = ccatno .AND. Part->( !EOF() )
         IF nl > npl
             IF mwhere == "P"
                EJECT
                @  0, 8 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  1, 5 SAY mcatdesc
      *** @  3, 0 SAY "Part #"
   @  3, 0 SAY "Description"
   @  3,52 SAY "Stock"
   @  3,63 SAY "Cost"
   nl := 4
               ELSE
                WAIT
                nl := 0
                SCROLL()
             ENDIF
         ENDIF
      ***      @ nl, 0 SAY SUBSTR( Part->Partnum,1, 8 )  
         @ nl, 0 SAY Part->Desc
         @ nl,41 SAY Part->Unit
         @ nl,52 SAY Part->Instock  PICTURE "99,999.99"
         @ nl,63 SAY Part->Trade    PICTURE "99,999.99"
         @ nl,72 SAY "_______"
      ***      @ nl,72 SAY Part->Retindiv PICTURE "999.999"
         ntotal += Part->Instock*Part->Trade
         nl++
         SKIP ALIAS Part
      ENDDO
      nl++
      @ nl,45 SAY "Total"
      @ nl,52 SAY ntotal PICTURE "9,999,999.99"
      nl++
      IF mwhere != "P"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
         SET MARGIN TO 0
      ENDIF
      mok := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO
   SET ORDER TO 1

   RETURN NIL

   ***** End of File PartTrade()

   *---------------------------------------------------------------------*

STATIC FUNCTION PartList()

   nl  := 0
   mok := "Y"
   DO WHILE mok == "Y"
      CatArray()
      ccatno := Cat->Catno      // SPACE(4)
      mcatdesc  := Cat->CatDesc
      mmajorind := Cat->Catno
      mfind  := SPACE(4)
      SCROLL()
      mboughtout := "N" 
      **** ApGetY( "Bought Out Only" )

      mwhere := "S"
      npl    := 54
      SCROLL()

       Printsel()                                  // _LF_Init

   IF mwhere == "P"
      SET MARGIN TO 1
      npl := 56
    ELSE
      SCROLL()
      npl := 22
   ENDIF
      SELECT Part
      SET ORDER TO 2                   // Catno
      GOTO TOP

      @  0, 8 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  1, 5 SAY mcatdesc
   @  3, 0 SAY "Part #"
   @  3,20 SAY "Description"
   nl := 4
      ntotal:= ncattotal:= 0
      SEEK ccatno
      DO WHILE Part->Catno = ccatno .AND. Part->( !EOF() )
         mcodeno := Part->Codeno
         IF mboughtout = "Y"
            IF Part->Boughtout != "Y"
               SKIP ALIAS Part
               LOOP
            ENDIF
         ENDIF
         IF nl > npl
             IF mwhere == "P"
                EJECT
                @  0, 8 SAY Control->U_Name
                @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                           +STR( YEAR(DATE() ),5 )
                @  1, 5 SAY mcatdesc
                @  3, 0 SAY "Part #"
                @  3,20 SAY "Description"
                nl := 4
               ELSE
                WAIT
                nl := 0
                SCROLL()
             ENDIF
         ENDIF
         @ nl, 0 SAY Part->Partnum  
         @ nl,20 SAY Part->Desc
         @ nl,61 SAY "_________"
         @ nl,70 SAY Part->Unit
         nl++
         SKIP ALIAS Part
      ENDDO
      IF mwhere != "P"
         IF nl > 18
            nl++
            WAIT
         ENDIF     
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
         SET MARGIN TO 0
      ENDIF
      mok := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO
   SELECT Part
   SET ORDER TO 1                 // Partnum

   RETURN NIL

   ***** End of File PartList

   *---------------------------------------------------------------------*

STATIC FUNCTION CatGroup()

   nl  := 0
   mok := "Y"
   DO WHILE mok == "Y"
      mwhere := "S"
      SCROLL()
      SELECT Part
       ApFLock( 3 ) 
      INDEX ON Part->Catno+Part->PartId TO TempIPL
      SET INDEX TO TempIPL
      UNLOCK

       Printsel()                                  // _LF_Init

      IF mwhere == "P"
         npl := 56
       ELSE
         SCROLL()
         npl := 22
      ENDIF
      SELECT Part
      GOTO TOP
      @  0, 8 SAY Control->U_Name
      @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
      @  2, 0 SAY "Catalogue"
      @  2,16 SAY "Group"
      nl := 3
      cCatGroup := Part->Catno+Part->PartId
      DO WHILE Part->( !EOF() )
         IF nl > npl
             IF mwhere == "P"
                EJECT
                @  0, 8 SAY Control->U_Name
                @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                           +STR( YEAR(DATE() ),5 )
                @  2, 0 SAY "Catalogue"
                @  2,16 SAY "Group"
                nl := 3
               ELSE
                WAIT
                nl := 0
                SCROLL()
             ENDIF
         ENDIF
         IF Part->Catno+Part->PartId = cCatGroup
            SKIP ALIAS Part
            LOOP  
         ENDIF
         @ nl, 0 SAY Part->Catno
         @ nl,15 SAY Part->PartId
         SELECT Cat
         SEEK Part->Catno
         IF FOUND()
            @ nl,30 SAY Cat->CatDesc
         ENDIF
         SELECT Part   
         cCatGroup := Part->Catno+Part->PartId
         nl++
         SKIP ALIAS Part
      ENDDO
      IF mwhere != "P"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
      ENDIF
      mok := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO
   SELECT Part
   SET INDEX TO PartInd

   RETURN NIL

   ***** End of File CatGroup()

   **-------------------------------------------------------------------

FUNCTION PartRUtd()

   SCROLL()
   @ 16,20 SAY STR( DAY(Control->LastRoll ),3 )+" "+CMONTH( Control->LastRoll );
              +STR( YEAR( Control->LastRoll ),5 )
   mok := "N"
      **** ApGetN( "Do you want to Zero the Rec/Utd to Date" )
   IF mok = "Y"
      mok := ApGetN( "Are You sure you understand" )
   ENDIF
   IF mok = "Y"
      @ 12,10 SAY "Please Wait BIG JOB"
      SELECT Control
       ApRLock( 3 )
      Control->LastRoll := DATE()
      UNLOCK
      SELECT Part
       ApFLock( 3 )
      REPLACE ALL Part->RecQty  WITH 0
      REPLACE ALL Part->Utd     WITH 0   
      UNLOCK
      @ 12, 5 SAY SPACE( 40 )
      RETURN NIL                         
   ENDIF                                   // mok
   npl    := 56
   mwhere := "S"

     Printsel( mwhere )

   IF mwhere == "P"
      SET MARGIN TO 0
      npl := 56
    ELSE
      SCROLL()
      npl := 22
   ENDIF
   ntotal := 0
   @  0, 0 SAY Control->U_Name
   @  0,40 SAY "Since Date"
   @  0,51 SAY Control->LastRoll
   @  0,65 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
              +STR( YEAR(DATE() ),5 )
   @  2, 0 SAY "Part #"
   @  2,18 SAY "Description"
   @  2,46 SAY "Received      Used\Date   Instock"
   nl := 4
   SELECT Part
   SET ORDER TO 1                          // Partnum WAS NO 3 PartId + Desc
   GOTO TOP
   DO WHILE Part->( !EOF() )
      IF nl > npl
         IF mwhere == "P"
            EJECT
          ELSE
            WAIT
            SCROLL()
         ENDIF
         @  0, 0 SAY Control->U_Name
         @  0,40 SAY "Since Date"
         @  0,51 SAY Control->LastRoll
         @  0,65 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         @  2, 0 SAY "Part #"
         @  2,18 SAY "Description"
         @  2,46 SAY "Received      Used\Date  Instock"
         nl := 4
      ENDIF
      IF Part->Utd > 0         // WAS Part->RecQty
         @ nl, 0 SAY SUBSTR( Part->Partnum, 1,11 )
         @ nl,12 SAY SUBSTR( Part->Desc, 1,30 )
         @ nl,43 SAY Part->RecQty  PICTURE "9999,999.99"
         @ nl,55 SAY Part->Utd     PICTURE "9999,999.99"
         @ nl,67 SAY Part->Instock PICTURE "9999,999.99"
         DO CASE
            CASE SUBSTR( Part->Partnum, 3, 1 ) = "-"
               ntotal := ntotal
            CASE SUBSTR( Part->Partnum, 5, 1 ) = "-"
               ntotal := ntotal
            CASE SUBSTR( Part->Partnum, 7, 1 ) = "-"
               ntotal := ntotal
            OTHERWISE
               ntotal += Part->Utd*Part->Trade
         ENDCASE
       ELSE
         SKIP ALIAS Part
         LOOP
      ENDIF      
      nl++
      SKIP ALIAS Part
   ENDDO                                  // EOF()
   nl+=2
      *** @ nl,34 SAY "Non Module Costs"
   @ nl,53 SAY ntotal PICTURE "$9,999,999.99"
   IF mwhere == "P"
       EndPrint()
      ELSE
       IF nl > 20
          nl++
          INKEY( 0 )
       ENDIF
       mok := "N"
       DO WHILE mok = "N"
          mok := ApReadN()
       ENDDO
       SCROLL()
   ENDIF

   RETURN NIL                              // End of Function PartRUtd

   ***-----End PartRUtd()

   *******-----------  END OF FILE XF_PLIST.PRG

