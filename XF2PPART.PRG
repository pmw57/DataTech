   ***  JK  20-06-11 08:27:01 

/* 
   Program.....:                   XF2PPART.PRG
   Author......: John Kirby
   Date........: 12/11/1993
   Functions...: CatList, LabCut, CatDescEdit, CatLsthd
                 JCDirect, PartOper2, JCDirect
   Static funcs: CatGroupEdit, OperCopy
*/

// (c) Copyright (c) 1995 by Kirby Christchurch.

FUNCTION CatList()

   ccatno := SPACE(12)
   manother := "Y"
   DO WHILE manother == "Y"
      mok := "Y"
      DO WHILE mok = "Y"
         nl      := 0
         CatArray()
         ccatno := Cat->Catno
         SELECT Part
         SET ORDER TO 2                     // Catno
         GOTO TOP
         SEEK ccatno
         nrecno := 0
         aPart_ := {}
         cmark  := "   "
         DO WHILE Part->Catno = ccatno .AND. Part->( !EOF() )
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
         @  1, 3 SAY SUBSTR( Cat->CatDesc, 1,36 ) COLOR "BG+"
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
         @ nl,COL()+4 SAY Part->Date COLOR "RG+"
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
         nl++
         nselect := 1
         DISPBOX( 20, 1, 24,79, 2 )
         @ 20,10      SAY " --- Catalogue --- "+mpartnum
         @ 21, 6      PROMPT "1. Price"
         @ 21,COL()+3 PROMPT "2. Part Change Cat"
         @ 21,COL()+3 PROMPT "3. Print"
         @ 21,COL()+3 PROMPT "4. Catalogue List"
         @ 22, 6      PROMPT "5. Stock  Cost"
         @ 22,COL()+2 PROMPT "6. Part System"
         @ 22,COL()+2 PROMPT "7. Delete Part"
         @ 22,COL()+2 PROMPT "8. Part Details"
         @ 23, 6      PROMPT "9. Tidy Groups"
         @ 23,COL()+2 PROMPT "Desc Tidy"
         @ 23,COL()+2 PROMPT "Change Supplier" 
         @ 23,COL()+2 PROMPT "Cat Prices"
         @ 23,COL()+2 PROMPT "EXIT"
         @ 24,60 SAY " DT3313 "
         MENU TO nselect
         DO CASE
            CASE PressedEsc()
               SELECT Part
               SET ORDER TO 1
               RETURN NIL
            CASE nselect == 11
               CatSupp( ccatno )     // SalesAnal.prg
            CASE nselect == 12
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
               *** RETURN NIL

            CASE nselect == 13
               SELECT Part
               SET ORDER TO 1
               RETURN NIL

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
                  SELECT Part
                  SET ORDER TO 1
                  RETURN NIL
               ENDIF
                ApRLock( 3 )
               IF Part->Trade != ntradedate
                  Part->Date := DATE()
               ENDIF                     // Part->Trade  
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
               ccatno := SPACE(12)

               SCROLL()
               DISPBOX( 0, 1, 22,79, 2 )
               @  1, 3      SAY Part->Desc    COLOR "BG+" 
               @  1,COL()+2 SAY SUBSTR( Part->Partnum, 1,16 ) COLOR "BG+"
               @  1,COL()+2 SAY Part->Catno   COLOR "BG+"
               @  3, 6      SAY "SELECT NEW Catalogue" COLOR "R+"
               WAIT 
               CatArray()
               ccatno := Cat->Catno
               cnewcatno := ccatno
               SEEK ccatno
               SELECT Part
                ApRLock( 3 )
               Part->Catno := cnewcatno   
               UNLOCK
               SCROLL( 3, 0, 24,80 )
               DISPBOX( 8, 1, 18,79, 2 )
               @  10, 3      SAY  Cat->CatDesc COLOR "BG+"
               @  12, 3      SAY Part->Desc    COLOR "BG+" 
               @  12,COL()+2 SAY SUBSTR( Part->Partnum, 1,16 ) COLOR "BG+"
               @  12,COL()+2 SAY ccatno        COLOR "RG+"
               @  14, 3      SAY "Part Catalogue "+ccatno+" Changed To "+Part->Catno COLOR "R+"
               @  16, 3      SAY Part->Desc    COLOR "BG+" 
               @  16,COL()+2 SAY SUBSTR( Part->Partnum, 1,16 ) COLOR "BG+"
               @  16,COL()+2 SAY Part->Catno   COLOR "RG+"
               INKEY( 3 )
               ****   RESTSCREEN( 0, 0, 24, 80,tempscr )
               LOOP

            CASE nselect == 3        // Print

               mwhere := "S"
               npl    := 52
               npn    := 1
         
               Printsel( mwhere, npl )                        // _LF_Init
         
               IF mwhere = "P"
                  npl := 56
               ELSE
                  npl := 22
               ENDIF 
               nl := 0
               @  nl, 0 SAY TRIM( Control->U_Name )+"   Page "+STR(npn,1,3)
               @  nl,63 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                         +STR( YEAR(DATE() ),5 )
               nl+=2
               @ nl, 3 SAY Cat->Catno+"  "+Cat->Catdesc
               nl+=2
               @ nl, 0 SAY "Part #"
               @ nl,18 SAY "Description"
               @ nl,38 SAY "Mod Cost"
               @ nl,48 SAY "Part Cost"
               @ nl,60 SAY "Markup"
               @ nl,68 SAY "Sell - GST"
               nl++
               SELECT Part
               GOTO TOP
               SET ORDER TO 2
               SEEK ccatno
               DO WHILE Part->Catno == ccatno .AND. Part->( !EOF() )
                  IF nl > npl
                     IF mwhere == "P"
                        EJECT
                     ELSE
                        WAIT
                        SCROLL()
                     ENDIF
                     nl := 0
                     @  nl, 0 SAY TRIM( Control->U_Name )+"   Page "+STR(npn,1,3)
                     @  nl,63 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                                 +STR( YEAR(DATE() ),5 )
                     nl+=2
                     @ nl, 3 SAY Cat->Catno+"  "+Cat->Catdesc
                     nl+=2
                     @ nl, 0 SAY "Part #"
                     @ nl,18 SAY "Description"
                     @ nl,38 SAY "Mod Cost"
                     @ nl,48 SAY "Part Cost"
                     @ nl,60 SAY "Markup"
                     @ nl,68 SAY "Sell - GST"
                     nl++
                  ENDIF
                  @ nl, 0 SAY SUBSTR( Part->Partnum, 1,16 )
                  @ nl,17 SAY SUBSTR( Part->Desc, 1,18 )
                  @ nl,36 SAY Part->RetIndiv  PICTURE "999,999.99"
                  @ nl,47 SAY Part->Trade     PICTURE "999,999.99"
                  IF Part->RetIndiv > ( Part->Trade+10 )
                     @ nl,58 SAY "*"
                  ENDIF
                  @ nl,60 SAY Part->Markup    PICTURE "9999.99"
                  @ nl,68 SAY Part->Wholesale PICTURE "9999,999.99"
                                               *** *(( Control->GSTRate/100 )+1 )
                  nl++
                  SELECT Part 
                  SKIP ALIAS Part
               ENDDO                      // Part  Catno       
               nl++
               @ nl, 6 SAY "Module > Cost + $10  Check Price  for *"
               nl++
               IF mwhere == "S"
                  WAIT
                  mwhere := "N" 
               ELSE
                  EndPrint()
                  SET MARGIN TO 0
               ENDIF
               LOOP

            CASE nselect == 4

               mok := "Y"  // ApGetN( "Catalogue List"  )

               IF mok = "Y"
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
                     @ nl, 0 SAY Cat->Catno
                     @ nl,14 SAY Cat->CatDesc
                     nl++
                     SKIP ALIAS Cat
                  ENDDO
                  nl++
                  IF mwhere != "P"
                     mok := "N"
                     DO WHILE mok = "N"
                        mok := ApReadN()
                     ENDDO
                  ELSE
                     EndPrint()
                  ENDIF
               ENDIF
               RETURN NIL
               ***      CatList()

            CASE nselect == 5                // Qty Cost
               mwhere := "S"
               npl    := 52
               npn    := 1

               Printsel( mwhere, npl )                        // _LF_Init

               IF mwhere = "P"
                  npl := 56
                 ELSE
                  npl := 22
               ENDIF 
               nStockCost := 0

               CatLsthd()                                       // Below

               SELECT Part
               SET ORDER TO 2
               SEEK ccatno
               DO WHILE Part->Catno == ccatno .AND. Part->( !EOF() )
                  IF nl > npl
                     IF mwhere == "P"
                        EJECT
                     ELSE
                        WAIT
                        SCROLL()
                     ENDIF
                      Catlsthd()                          // Below
                  ENDIF
                  @ nl, 0 SAY SUBSTR( Part->Partnum, 1,16 )
                  @ nl,17 SAY Part->Desc
                  @ nl,58 SAY Part->Instock  PICTURE "99999.99"
                  @ nl,68 SAY Part->Trade PICTURE "$9999,999.99"
                   nStockCost += Part->Instock*Part->Trade  
                  nl++
                  SELECT Part 
                  SKIP ALIAS Part
               ENDDO
               nl++
               LOOP

            CASE nselect == 6
               ModPart()             // METQUOT
               LOOP

            CASE nselect == 7
               PartDelete()             // CWP2
               LOOP

            CASE nselect == 8
                PartDets( @mpartnum )              // CWPP2
               LOOP             

            CASE nselect == 9
               CatGroupEdit() 
               LOOP

            CASE nselect == 10
               CatDescEdit() 
               LOOP

         ENDCASE
      ENDDO                    // mok

   ENDDO                    // manother
   SELECT Part
   SET ORDER TO 1

   RETURN NIL

   ***------------ End of CatList()

   **-------------------------------------------------------------------

FUNCTION LabCut()

   mpartnum := Part->Partnum
   manother := "Y"
   DO WHILE manother = "Y"
      SCROLL()
      DISPBOX( 0, 1,22,79, 2 )
      SELECT LabCut
      SEEK mpartnum
      IF !FOUND()   
         SELECT Part
         SET ORDER TO 1                       // Partnum
         SEEK mpartnum
         IF FOUND()
             SELECT LabCut 
              ApFlock( 3 )
             APPEND BLANK
             LabCut->Operno   := Part->Catno
             LabCut->Date     := DATE()
             LabCut->Desc     := Part->Desc
    ***         LabCut->Priority := Part->Catno  
             LabCut->Partnum  := Part->Partnum
             LabCut->Order    := "00"  
             UNLOCK
       ENDIF           //   FOUND and added
   ENDIF               // Found
   SELECT LabCut
   SEEK mpartnum
   IF !FOUND()
      @ 24, 3 SAY Part->Partnum+" Selected Part" COLOR "G+"
      mpart := SPACE( 20 )
      ntimetotal:= ntime := 0
      coperno := SPACE( 8 )
      aPart_:={}
      nrecno := 0
      SELECT LabCut
      GOTO TOP
      DO WHILE LabCut->( !EOF() )
         IF LabCut->Partnum = mpart
            SKIP ALIAS LabCut
            LOOP
         ENDIF
         AADD( aPart_,LabCut->Partnum+" "+LabCut->Desc+"  "+STR( LabCut->Time ) ;
                      +" "+LabCut->Order+"          "+STR( RECNO(),6 ) )
         mpart := LabCut->Partnum   // So it Shows only one
         SKIP ALIAS LabCut
      ENDDO                        // LabCut EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  1, 3, 21,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         IF LASTKEY() = 27
            RETURN NIL
         ENDIF  
         GOTO nrecno
         SELECT Part
         SET ORDER TO 1
         SEEK LabCut->Partnum
         SCROLL( 13, 0, 18,80 )
         DISPBOX( 13, 1, 18,79, 2 )
         @ 14, 2 SAY LabCut->Partnum+" "+TRIM( LabCut->Desc )+" "+STR( LabCut->Time, 8, 2 ) COLOR "BG+"
      ENDIF                        // !Empty
   ENDIF          // Found

      mmore := "Y"
      DO WHILE mmore = "Y"
         SCROLL( 0, 0, 24,80 )
         DISPBOX( 0, 1, 2,79, 2 )
         @  1, 4 SAY TRIM( Part->Partnum )+"  "+Part->Desc COLOR "BG+"
         DISPBOX( 3, 1, 24,79, 2 )
      aPart_:={}
      nrecno := 0
      SELECT LabCut
      GOTO TOP
      DO WHILE LabCut->( !EOF() )
         IF LabCut->Partnum != mpartnum
            SKIP ALIAS LabCut
            LOOP
         ENDIF
         AADD( aPart_,LabCut->Order+" "+LabCut->Desc;
                      +" "+STR( LabCut->Time );
                      +" "+LabCut->Priority+" "+LabCut->Partnum;
                      +"                  "+STR( RECNO(),6 ) )
         SKIP ALIAS LabCut
      ENDDO                        // LabCut EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         SELECT Part
         SET ORDER TO 1
         SEEK LabCut->Partnum
         SCROLL( 16, 0, 24,80 )
         DISPBOX( 16, 1, 18,79, 2 )
         @ 17, 2 SAY LabCut->Partnum+" "+TRIM( LabCut->Desc )+" "+STR( LabCut->Time, 8, 2 ) COLOR "BG+"
      ENDIF                        // !Empty
      SCROLL( 19, 0, 24,80 )
      DISPBOX( 19, 1, 24,79, 2 )
      @ 19, 6 SAY " --- Planning --- "+Part->Partnum COLOR "RG+"
      nselect  := 1
      @ 20, 6      PROMPT "Another" 
      @ 20,COL()+2 PROMPT "1. Add Process"
      @ 20,COL()+2 PROMPT "2. Add Operation"
      @ 20,COL()+2 PROMPT "3. Edit-Delete"
      @ 21, 6      PROMPT "4. Add Drawing"
      @ 21,COL()+2 PROMPT "5. Organise Order"
      @ 21,COL()+2 PROMPT "6. Print"
      @ 21,COL()+2 PROMPT "7. Part Insert"
      @ 22, 6      PROMPT "8. View All"
      @ 22,COL()+2 PROMPT "9. Process"  
      @ 22,COL()+2 PROMPT "0. Drawing"
      @ 22,COL()+2 PROMPT "Copy Labour"
      ***   @ 22,COL()+2 PROMPT "Plan List"
      @ 24, 3 SAY Part->Partnum+" Selected Part" COLOR "RG+"
      @ 24,70 SAY " DT3117 "
      MENU TO nselect
      DO CASE
         CASE LASTKEY() = 27
            RETURN NIL
         CASE nselect == 1                 //
            LabCut()     
         CASE nselect == 2                 // Add Process   
            mselect  := ApGetY( "Specific Entry / No = List" )
            IF mselect = "Y"
               SELECT LabCut
               cdesc     := SPACE( 40 )
          ***     cpriority :=
               corder    := SPACE( 2 )
               ntime     := 0
               SCROLL( 15, 0, 24,80 )
               DISPBOX( 15, 1, 18,79, 2 )
               @ 16,10      SAY "Specific Desc" GET cdesc     PICTURE "@X"
     ***          @ 17,10      SAY "Order"         GET corder    PICTURE "@!"
               @ 17,10      SAY "Time"          GET ntime     PICTURE "9999.99"
               @ 17,COL()+2 SAY "Hours"
        ***       @ 17,COL()+2 SAY "Invno "+cpriority
                READ
               SELECT LabCut
                ApFlock( 3 )
               APPEND BLANK
        ***       LabCut->Priority := cpriority
               LabCut->Time     := ntime
               LabCut->Desc     := cdesc      
               LabCut->Order    := SUBSTR( cdesc, 1, 2 )     // corder      
               LabCut->Partnum  := Part->Partnum
               LabCut->Date     := DATE()
                READ
               UNLOCK
               LOOP
            ENDIF     // mselect
            SCROLL()
            DISPBOX( 0, 1, 2,79, 2 )
            @  1, 8 SAY mpartnum+"  Viewing Part Process"
            aPart_:={}
            nrecno   := 0
            SELECT Operate
            GOTO TOP
            DO WHILE Operate->( !EOF() )
               AADD( aPart_,Operate->Operno;
                           +" "+Operate->Desc;
                           +" "+STR( Operate->Time, 8, 2 );
                           +"  "+Operate->Order;
                           +"                      "+STR( RECNO(),6 ) )
               SKIP ALIAS Operate
            ENDDO                        // Operate EOF
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            SCROLL(  3, 0, 24,80 )
            DISPBOX( 3, 1, 24,79, 2 )
            @ 3, 6 SAY " F2 To Add "
            anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
            IF LASTKEY() == -1
               JobOperate()                           // Below
            ENDIF
            IF PressedEsc()
               RETURN NIL
            ENDIF
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            SCROLL( 19, 0, 24,80 )
            DISPBOX( 19, 1, 24,79, 2 )
            nl := 20
            SELECT Operate
            cdesc    := Operate->Desc
            coperno  := Operate->Operno
            corder   := Operate->Order
            ntime    := Operate->Time
            @ nl,10      SAY "Process Desc" GET cdesc   PICTURE "@X"
            nl+=2
            @ nl,10      SAY "Ref"          GET coperno PICTURE "@!"
            @ nl,COL()+2 SAY "Order"        GET corder  PICTURE "@!"
            @ nl,COL()+2 SAY "Time"         GET ntime   PICTURE "9999.99"
            @ nl,COL()+2 SAY "Hours" 
             READ
         ENDIF                        // Empty
         SELECT LabCut
          ApFlock( 3 )
         APPEND BLANK
         LabCut->Operno   := Operate->Operno
         LabCut->Time     := ntime
         LabCut->Rate     := Operate->Rate
         LabCut->Desc     := cdesc      
         LabCut->Order    := SUBSTR( coperno, 1, 2 )    // corder      
         LabCut->Partnum  := mpartnum
         LabCut->Date     := DATE()
      ***      LabCut->Priority := Debit->Invno
          READ
         UNLOCK
         LOOP

         CASE nselect == 3                       // Add Operation
             LabCutOPer()                        // XLF_QU1

            LOOP

         CASE nselect == 4                 // Edit-Delete Operation
            SCROLL( 14, 0, 18,80 )
            DISPBOX( 14, 1, 18,79, 2 )
            cdesc    := LabCut->Desc
            ntime    := LabCut->Time
            corder   := LabCut->Order
            coperno  := LabCut->Operno      
            @ 16, 3      GET cdesc   PICTURE "@X"
            @ 16,COL()+1 SAY "Time"  GET ntime   PICTURE "99999.99"
            @ 16,COL()+1 SAY "In Hours" 
            @ 16,COL()+1 SAY "Ord"   GET corder  PICTURE "@!"
            @ 17, 3      GET coperno             PICTURE "@!"
             READ
            SELECT LabCut
             ApRLock( 3 )
            LabCut->Desc     := cdesc
            LabCut->Operno   := coperno
            LabCut->Time     := ntime
            LabCut->Order    := corder
      ***         LabCut->Priority := Debit->Invno      
            UNLOCK
            cstring := TRIM( Message->Suredel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF mok == "Y"
                ApRLock( 3 )
               DELETE
               UNLOCK
            ENDIF 
            LOOP

        CASE nselect == 5                 // Add Drawing   
            SCROLL()
            DISPBOX( 0, 1, 2,79, 2 )
            @ 1, 8 SAY "Viewing Drawings"
            aPart_:={}
            nrecno   := 0
            SELECT Drawing
            GOTO TOP
            DO WHILE Drawing->( !EOF() )
                AADD( aPart_,Drawing->Drawno;
                           +" "+Drawing->Desc;
                           +"                           "+STR( RECNO(),6 ) )
                SKIP ALIAS Drawing
            ENDDO                        // Drawing EOF
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            SCROLL(  3, 0, 24,80 )
            DISPBOX( 3, 1, 24,79, 2 )
            @ 3, 6 SAY " F2 To Add "
            anum := ACHOICE(  4, 4, 23,76, aPart_,,"AFUNC" )
            IF LASTKEY() == -1
               JobDraw()                    // JobDem
            ENDIF
            IF PressedEsc()
               RETURN NIL
            ENDIF
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            SCROLL( 19, 0, 24,80 )
            DISPBOX( 19, 1, 24,79, 2 )
            nl := 21
             ApFlock( 3 )
            @ nl,10 SAY "Desc" GET Drawing->Desc   PICTURE "@X"
            nl++  
            @ nl,10 SAY "Code" GET Drawing->Drawno PICTURE "@!"
             READ
            UNLOCK
         ENDIF                        // Empty
         SELECT LabCut
          ApFlock( 3 )
         APPEND BLANK
         LabCut->Partnum  := mpartnum
         LabCut->Date     := DATE()
         LabCut->Desc     := TRIM( Drawing->Drawno )+" "+Drawing->Desc
         LabCut->Operno   := "Drawing"
         LabCut->Order    := " D"
      ***      LabCut->Priority := Debit->Invno      
         UNLOCK
         LOOP

         CASE nselect == 6                 // Order of Operation
   mok := "Y"
   DO WHILE mok = "Y"

      aPart_:={}
      nrecno  := 0
      SELECT LabCut
      GOTO TOP
      ***   SET ORDER TO 1       // Partnum
      ***   SEEK mpartnum            
      DO WHILE LabCut->( !EOF() )
         IF LabCut->Partnum != mpartnum
            SKIP ALIAS LabCut
            LOOP
         ENDIF
         ntime := 0
         cdesc := SPACE( 60 )
         AADD( aPart_,LabCut->Order;
                      +" "+LabCut->Desc+" "+STR( LabCut->Time );
                      +" "+LabCut->Priority+" "+LabCut->Partnum;
                      +"                      "+STR( RECNO(),6 ) )
         SKIP ALIAS LabCut
      ENDDO                        // LabCut EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 1, 24,79, 2 )
         anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
         IF LASTKEY() = 27
            EXIT
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
          ApRLock( 3 )   
         @ ROW(), 2 GET LabCut->Order PICTURE "!!"
          READ   
         UNLOCK
         LOOP
       ENDIF                        // Empty
    ENDDO                                // mok
    LOOP

         CASE nselect == 7                // Print Planning
            LabCutPrint()                 // XLF_Qu1
         LOOP

         CASE nselect == 8                       // Add Part
             SELECT Part
             SET ORDER TO 1                       // Partnum
             mpartnum := SPACE( 20 )

              Partfind( @mpartnum )                // XF_Part

             mpartnum := Part->Partnum
             IF LASTKEY() = 27
                LOOP
             ENDIF 
             SELECT LabCut 
              ApFlock( 3 )
             APPEND BLANK
             LabCut->Partnum  := Part->Partnum
             LabCut->Operno   := Part->Catno
             LabCut->Date     := DATE()
             LabCut->Desc     := Part->Desc
      ***          LabCut->Priority := Debit->Invno  
             UNLOCK
             LOOP
         CASE nselect == 9                       // All Parts

         SCROLL( 0, 0, 24,80 )
         DISPBOX( 0, 1, 2,79, 2 )
         @  1, 4 SAY "This is View Only" COLOR "BG+" 
      **** TRIM( Part->Partnum )+"  "+TRIM( Part->Desc ) COLOR "BG+"
         DISPBOX( 3, 1, 24,79, 2 )
      aPart_:={}
      nrecno := 0
      SELECT LabCut
      GOTO TOP
      DO WHILE LabCut->( !EOF() )
         AADD( aPart_,LabCut->Partnum+" "+LabCut->Desc;
                      +" "+STR( LabCut->Time );
                      +" "+LabCut->Priority+" "+LabCut->Order;
                      +"                  "+STR( RECNO(),6 ) )
         SKIP ALIAS LabCut
      ENDDO                        // LabCut EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
      ENDIF                        // !Empty
      LOOP
         CASE nselect == 10               // Add Edit Process
             JobOperate()                  // 
            LOOP

         CASE nselect == 11               // Edit Add Drawings
             JobDraw()                    // JobDem
            LOOP
         CASE nselect == 12               // Add Existing Labour
             LabCutCopy()                       // XLF_QU1
            LOOP

      ***      CASE nselect == 13               // Plan List
      ***          PlanList()                   // XLF_QU8
      ***         LOOP

      ENDCASE
   ENDDO                                // mmore
   manother := "Y"

   ENDDO                             // manother

   RETURN NIL
   *****-----------    End of LabCut()

   ***-------------------------------------------------------------------------

FUNCTION CatDescEdit()

    ccatno := Cat->Catno
    mok := "Y"
    DO WHILE mok = "Y"
       SELECT Part
       SET ORDER TO 2                       // Catno
       GOTO TOP
       SEEK ccatno
       nrecno := 0
       aPart_ := {}
     IF FOUND()
       DO WHILE Part->Catno == ccatno .AND. Part->( !EOF() )
           AADD( aPart_,Part->Desc;
                        +"  "+SUBSTR( Part->Partnum, 1,16 );
                        +"  "+Part->PartId;
                        +"                "+STR( RECNO(),6 ) )
           SKIP ALIAS Part
       ENDDO                     // Part EOF
       SCROLL() 
       DISPBOX( 0, 1, 2,79, 2 )
       @  1, 6 SAY "Catalogue "+ccatno  COLOR "BG+"
       @  1,42 SAY "Description           Group" 
       DISPBOX( 3, 1, 24,79, 2 )
       IF !EMPTY( aPart_ )
          ASORT( aPart_,,,{ | x,y | x < y } )
          anum := ACHOICE( 4, 3, 23,78, aPart_,,"AFUNC" )
          IF LASTKEY() = 27
             RETURN NIL
          ENDIF  
          nrecno := VAL( RIGHT( aPart_[anum],6 ) )
          GOTO nrecno
          cdesc := Part->Desc
          @ ROW(), 2 GET cdesc PICTURE "@X"
           READ   
          ApRLock( 3 )   
         Part->Desc := cdesc  
         UNLOCK
       ENDIF
       ELSE 
        SCROLL()
        @ 12,10 SAY "No Parts in File for this Catalogue"
        WAIT 
        mok := "N"
      ENDIF                   // Found
       LOOP
    ENDDO                    // mok  
   RETURN NIL
   *****-------------------- End CatDescEdit

   ****----------------------------------------

STATIC FUNCTION CatGroupEdit()

    ccatno := Cat->Catno
    mok := "Y"
    DO WHILE mok = "Y"
       SELECT Part
       SET ORDER TO 2                       // Catno
       GOTO TOP
       SEEK ccatno
     IF FOUND()
       nrecno := 0
       aPart_ := {}
       DO WHILE Part->Catno == ccatno .AND. Part->( !EOF() )
           AADD( aPart_,Part->PartId;
                        +" "+SUBSTR( Part->Partnum, 1,16 );
                        +" "+Part->Desc;
                        +"                "+STR( RECNO(),6 ) )
           SKIP ALIAS Part
       ENDDO                     // Part EOF
       SCROLL() 
       DISPBOX( 0, 1, 2,79, 2 )
       @  1,10 SAY "Catalogue "+ccatno  COLOR "BG+"
       @  1,42 SAY "Group" 
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
      ELSE
        SCROLL()
        @ 12,10 SAY "No Parts in File for this Catalogue"
        WAIT 
        mok := "N"
    ENDIF                        // Found
       LOOP
    ENDDO                    // mok  
   RETURN NIL
   *****-------------------- End CatGroupEdit

   ****----------------------------------------

FUNCTION CatLsthd()

   nl := 0
   @  nl, 0 SAY TRIM( Control->U_Name )+"   Page "+STR(npn,1,3)
   @  nl,63 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   nl+=2
   @ nl, 3 SAY Cat->Catno+"  "+Cat->Catdesc
   nl+=2
   @ nl, 0 SAY "Part #"
   @ nl,18 SAY "Description"
   @ nl,67 SAY " Excl GST"
   nl++

   RETURN NIL
   ***--- End CatLstHd

   *****--------------------------------------------------------------------

STATIC FUNCTION OperCopy()

   SCROLL()
   mmainpart := mpartnum
   mmaindesc := Part->Desc
      aPart_ := {}
      anum   := {}
      nrecno := 0
      SELECT PartOper
      SET ORDER TO 1            // Partnum
      GOTO TOP
      mfind := SPACE( 20 ) 
      DO WHILE PartOper->( !EOF() )
         IF PartOper->Partnum = mfind
            SKIP ALIAS PartOper
            LOOP 
         ENDIF
         mfind := PartOper->Partnum
         SELECT Part
         SEEK mfind
         IF !FOUND()
            SELECT PartOper
            SKIP ALIAS PartOper
            LOOP 
         ENDIF
         SELECT PartOper   
         AADD( aPart_,PartOper->Partnum;
                 +" "+Part->Desc;
                 +"                   "+STR( RECNO(),6 ) )
         SKIP ALIAS PartOper
      ENDDO                       // EOF()
      IF !EMPTY( aPart_ )
      SCROLL( 0, 0, 2,55 )
      DISPBOX( 0, 1, 3,55, 2 ) 
      @ 1, 2 SAY TRIM( mmainpart )+" "+TRIM( mmaindesc ) COLOR "BG+" 
      ***   @ 2, 2 SAY "Copy "+TRIM( mfind )+" "+TRIM( Part->Desc ) COLOR "RG+" 
         SCROLL( 3, 0, 24,56 )
         DISPBOX( 3, 1, 24,56, 2 ) 
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  4, 3, 23,54,aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
         GOTO nrecno
         IF PressedEsc()
            SELECT Part
            SEEK mmainpart
            RETURN NIL
         ENDIF
      ENDIF
      mfind := PartOper->Partnum
   SCROLL()
   SELECT PartOper
   GOTO TOP
    ApFLock( 3 )
   REPLACE ALL PartOper->ABC WITH " " 
   UNLOCK
   manother := "Y"
   DO WHILE manother = "Y"
      SCROLL( 0, 0, 2,55 )
      DISPBOX( 0, 1, 3,55, 2 ) 
      @ 1, 2 SAY TRIM( mmainpart )+" "+TRIM( mmaindesc ) COLOR "BG+" 
      @ 2, 2 SAY "Copy "+TRIM( mfind )+" "+TRIM( Part->Desc ) COLOR "RG+" 
      DISPBOX( 3, 1, 24,55, 2 ) 
      aPart_ := {}
      anum   := {}
      SELECT PartOper
      GOTO TOP
      SEEK mmainpart
      DO WHILE PartOper->Partnum = mmainpart .AND. PartOper->( !EOF() )
         IF PartOper->Partnum != mmainpart
            SKIP ALIAS PartOper
            LOOP 
         ENDIF
         AADD( aPart_,PartOper->Order;
                      +" "+SUBSTR( PartOper->Desc, 1,17 ) )
         SKIP ALIAS PartOper
      ENDDO                       // EOF()
      IF !EMPTY( aPart_ )
         SCROLL( 0,56, 24,80 )
         DISPBOX( 0,56, 24,79, 2 ) 
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  1,58, 23,78,aPart_,,"AFUNC" )
         IF PressedEsc()
            SELECT Part
            SEEK mmainpart
            RETURN NIL
         ENDIF
      ENDIF
      aPart_ := {}
      anum   := {}
      nrecno := 0
      SELECT PartOper
      GOTO TOP
      SEEK mfind
      DO WHILE PartOper->Partnum = mfind .AND. PartOper->( !EOF() )
         IF PartOper->Partnum != mfind
            SKIP ALIAS PartOper
            LOOP 
         ENDIF
         IF PartOper->ABC = "Y"
            SKIP ALIAS PartOper
            LOOP 
         ENDIF
         AADD( aPart_,PartOper->Order;
                 +" "+PartOper->Desc;
                 +" "+STR( PartOper->Time );
                 +"                    "+STR( RECNO(),6 ) )
         SKIP ALIAS PartOper
      ENDDO                       // EOF()
      IF !EMPTY( aPart_ )
         SCROLL( 3, 0, 24,55 )
         DISPBOX( 3, 1, 24,55, 2 ) 
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  4, 3, 23,54,aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
         GOTO nrecno
         IF PressedEsc()
            SELECT Part
            SEEK mmainpart
            RETURN NIL
         ENDIF
         SCROLL(  15, 0, 24,55 )
         DISPBOX( 15, 1, 19,55, 2 ) 
         @ 16, 3 SAY PartOper->Order+" "+TRIM( PartOper->Desc )        COLOR "BG+" 
         @ 17,16 SAY STR( PartOper->Time, 8, 2 )+" "+PartOper->Partnum COLOR "BG+"
      ENDIF
      IF EMPTY( aPart_ )
         SELECT Part
         SEEK mmainpart
         RETURN NIL
      ENDIF
      maccept := ApGetY( "Copy Operation To "+TRIM( mmainpart ) )
      IF PressedEsc()
         SELECT Part
         SEEK mmainpart
         RETURN NIL
      ENDIF
      IF maccept = "Y"
           ApRLock( 3 )
          PartOper->ABC := "Y"
         UNLOCK
         cDesc    := PartOper->Desc
         corder   := PartOper->Order
         ntime    := PartOper->Time
         cadminno := PartOper->Adminno
         cdrawno  := PartOper->Drawno
         ccodeno  := PartOper->Codeno
         @ 18,10 SAY "Time" GET ntime PICTURE "99999.99" 
          READ
          ApFLock( 3 )
         APPEND BLANK
         PartOper->Partnum := mmainpart
         PartOper->Desc    := cDesc
         PartOper->Order   := corder
         PartOper->Time    := ntime 
         PartOper->Date    := DATE()
         PartOper->Adminno := cadminno 
         PartOper->Drawno  := cdrawno 
         PartOper->Codeno  := ccodeno 
         UNLOCK
      ENDIF          // maccept
      LOOP
   ENDDO               // manother

   RETURN mpartnum

   ***-----------------  End Of   OperCopy

   *****-------------------------------------------------------------------------

FUNCTION PartOper2( mpartnum )

   SCROLL()
   DISPBOX( 0, 0, 24,79, 2 )
   @  1,10 SAY "PartOper.Dbf File Parts" COLOR "BG+"
   aPart_:={}
   nrecno := 0
   SELECT PartOper
   SET ORDER TO 1                   // Order
   GOTO TOP
   SEEK mpartnum
   *** IF FOUND()
   DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() )
      SELECT PartOper
      ***      mpartnum := PartOper->Partnum
      AADD( aPart_,PartOper->Partnum+" "+PartOper->Desc;
                   +"                   "+STR( RECNO(),6 ) )
      SKIP ALIAS PartOper
   ENDDO                        // PartOper EOF
   IF !EMPTY( aPart_ )
      ASORT( aPart_,,,{ | x,y | x < y } )
      anum := ACHOICE(  3, 3, 23,78, aPart_,,"AFUNC" )
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      GOTO nrecno
      mpartnum := PartOper->Partnum 
   ENDIF                        // !Empty
   SELECT Part
   SET ORDER TO 1
   IF mpartnum = SPACE( 20 )
      mpartnum := SPACE( 20 )
      PartFind( @mpartnum )
   ENDIF
   SEEK mpartnum
   manother := "Y"
   DO WHILE manother = "Y"
      SCROLL()
      DISPBOX( 0, 0, 2,79, 2 )
      @  1, 4 SAY TRIM( Part->Partnum )+"  "+TRIM( Part->Desc )+" Process/Drawing" COLOR "BG+"
      DISPBOX( 3, 1, 24,79, 2 )
      ***   mpartnum := Part->Partnum
      ntimetotal:= ntime := 0
      coperno:= cadminno:= cdrawno := SPACE( 8 )
      aPart_:={}
      nrecno := 0
      SELECT PartOper
      SET ORDER TO 1                   // Order
      GOTO TOP
      SEEK mpartnum
      *** IF FOUND()
      DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() )
         ***   DO WHILE PartOper->( !EOF() )
         ***      IF PartOper->Partnum != mpartnum
         ***         SKIP ALIAS PartOper
         ***         LOOP
         ***      ENDIF
         ntime := 0
      /*
         cdesc := SPACE( 54 )
         DO CASE
            CASE PartOper->Adminno != SPACE( 8 )
               cdesc := PartOper->Order+"  "+PartOper->Adminno+"  "+PartOper->Desc;
                       +" "+STR( PartOper->Time, 8, 2 )
            CASE PartOper->Drawno != SPACE( 8 )
               cdesc := PartOper->Order+"  "+PartOper->Drawno+"  "+PartOper->Desc;
                      +"   Drawing"
         ENDCASE
      */
         ***      SELECT PartOper
         AADD( aPart_,PartOper->Order+" "+SUBSTR( PartOper->Desc,1,35 );
                      +" "+PartOper->Operno+" "+PartOper->Adminno;
                      +"                     "+STR( RECNO(),6 ) )
         SKIP ALIAS PartOper
      ENDDO                        // PartOper EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         SCROLL( 13, 0, 18,80 )
         DISPBOX( 13, 1, 18,79, 2 )
         @ 14, 2 SAY SUBSTR( PartOper->Desc, 1,30 );
            +" "+STR( PartOper->Time, 8, 2 );
            +" "+TRIM( PartOper->Adminno );
            +" "+PartOper->Drawno COLOR "BG+"
      ENDIF                        // !Empty
      SCROLL( 19, 0, 24,80 )
      DISPBOX( 19, 1, 24,79, 2 )
      @ 19, 8 SAY " --- Part Process --- "+TRIM( Part->Partnum )
      nselect  := 1
      @ 21, 6      PROMPT "1. Add Process"
      @ 21,COL()+2 PROMPT "2. Edit-Delete"
      @ 21,COL()+2 PROMPT "3. Add Drawing"
      @ 21,COL()+2 PROMPT "4. Add Admin"
      @ 22, 6      PROMPT "5. Organise Order"
      @ 22,COL()+2 PROMPT "6. Print"
      @ 22,COL()+2 PROMPT "7. Process"  
      @ 22,COL()+2 PROMPT "8. Drawing"
      @ 22,COL()+2 PROMPT "9. Admin"
      @ 23, 6      PROMPT "Copy Oper"
      @ 23,COL()+2 PROMPT "Part Insert"
      @ 24,60 SAY " DT31468A "
      MENU TO nselect
      DO CASE
         CASE PressedEsc()
            RETURN NIL
         CASE nselect == 1                 // Add Operation   
            SCROLL()
            DISPBOX( 0, 1, 2,79, 2 )
            @  1, 8 SAY mpartnum+"  Viewing Part Process"
            aPart_:={}
            nrecno   := 0
            SELECT Operate
            GOTO TOP
            DO WHILE Operate->( !EOF() )
               AADD( aPart_,Operate->Operno;
                           +" "+Operate->Desc;
                           +" "+STR( Operate->Time, 8, 2 );
                           +"  "+Operate->Order;
                           +"                      "+STR( RECNO(),6 ) )
               SKIP ALIAS Operate
            ENDDO                        // Operate EOF
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               SCROLL(  3, 0, 24,80 )
               DISPBOX( 3, 1, 24,79, 2 )
               @ 3, 6 SAY " F2 To Add "
               anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
               IF LASTKEY() == -1
                  JobOperate()                           // Below
               ENDIF
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               SCROLL( 16, 0, 24,80 )
               DISPBOX( 16, 0, 24,79, 2 )
               nl := 18
               SELECT Operate
               cdesc    := Operate->Desc
               coperno  := Operate->Operno
               corder   := Operate->Order
               ntime    := Operate->Time
               @ nl,10      SAY "Process Desc" GET cdesc   PICTURE "@X"
               nl+=2
               @ nl,10      SAY "Ref"          GET coperno PICTURE "@!"
               @ nl,COL()+2 SAY "Order"        GET corder  PICTURE "@!"
               @ nl,COL()+2 SAY "Time"         GET ntime   PICTURE "9999.99"
                READ
               SELECT PartOper
                ApFlock( 3 )
               APPEND BLANK
               PartOper->Adminno := Operate->Operno
               PartOper->Time    := ntime
               PartOper->Rate    := Operate->Rate
               PartOper->Desc    := cdesc      
               PartOper->Order   := corder      
               PartOper->Partnum := Part->Partnum
               PartOper->Codeno  := Part->Codeno 
               PartOper->Date    := DATE()
               PartOper->Operno  := coperno
               UNLOCK
            ENDIF                        // Empty
            LOOP

         CASE nselect == 2                 // Edit-Delete Operation
            SCROLL( 10, 0, 24,80 )
            DISPBOX( 10, 0, 24,79, 2 )
            cdesc    := PartOper->Desc
            cdesc1   := PartOper->Desc1
            cdesc2   := PartOper->Desc2
            ntime    := PartOper->Time
            corder   := PartOper->Order
            cadminno := PartOper->Adminno      
            @ 12, 3      GET cdesc   PICTURE "@X"
            @ 12,COL()+1 SAY "Time"  GET ntime   PICTURE "99999.99"
            @ 12,COL()+1 SAY "Ord"   GET corder  PICTURE "@!"
            @ 14, 3      GET cdesc1  PICTURE "@X"
            @ 15, 3      GET cdesc2  PICTURE "@X"
            @ 16, 3      GET cadminno            PICTURE "@!"
             READ
            coperno :=SPACE( 8 )
            GroupSelect( @coperno )
            SELECT PartOper
             ApRLock( 3 )
            PartOper->Desc    := cdesc
            PartOper->Desc1   := cdesc1
            PartOper->Desc2   := cdesc2
            PartOper->Adminno := cadminno
            PartOper->Time    := ntime
            PartOper->Order   := corder
            PartOper->OPerno  := coperno     
            UNLOCK
            cstring := TRIM( Message->Suredel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF mok == "Y"
                ApFLock( 3 )
               DELETE
               UNLOCK
            ENDIF 
            LOOP

         CASE nselect == 3                 // Add Drawing   
            SCROLL()
            DISPBOX( 0, 1, 2,79, 2 )
            @ 1, 8 SAY "Viewing Drawings"
            aPart_:={}
            nrecno   := 0
            SELECT Drawing
            GOTO TOP
            DO WHILE Drawing->( !EOF() )
                AADD( aPart_,Drawing->Drawno;
                           +" "+Drawing->Desc;
                           +"                           "+STR( RECNO(),6 ) )
                SKIP ALIAS Drawing
            ENDDO                        // Drawing EOF
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               SCROLL(  3, 0, 24,80 )
               DISPBOX( 3, 1, 24,79, 2 )
               @ 3, 6 SAY " F2 To Add "
               anum := ACHOICE(  4, 4, 23,76, aPart_,,"AFUNC" )
               IF LASTKEY() == -1
                  JobDraw()                    // JobDem
               ENDIF
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               SCROLL( 19, 0, 24,80 )
               DISPBOX( 19, 1, 24,79, 2 )
               nl := 21
                ApFlock( 3 )
               @ nl,10 SAY "Desc" GET Drawing->Desc   PICTURE "@X"
               nl++  
               @ nl,10 SAY "Code" GET Drawing->Drawno PICTURE "@!"
                READ
               UNLOCK
            ENDIF                        // Empty
            SELECT PartOper
             ApFlock( 3 )
            APPEND BLANK
            PartOper->Partnum := mpartnum
            PartOper->Date    := DATE()
            PartOper->Desc    := Drawing->Desc
            PartOper->Drawno  := Drawing->Drawno
            UNLOCK
            LOOP

         CASE nselect == 4                 // Add Admin
            SCROLL()
            DISPBOX( 0, 1, 2,79, 2 )
            @ 1, 8 SAY mpartnum+"  Viewing Part Process"
            aPart_:={}
            nrecno   := 0
            SELECT Admin
            GOTO TOP
            DO WHILE Admin->( !EOF() )
               AADD( aPart_,Admin->Adminno;
                            +" "+Admin->Desc;
                            +"                      "+STR( RECNO(),6 ) )
               SKIP ALIAS Admin
            ENDDO                        // Admin EOF
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               SCROLL(  3, 0, 24,80 )
               DISPBOX( 3, 1, 24,79, 2 )
               @ 3, 6 SAY " F2 To Add "
               anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
               IF LASTKEY() == -1
                  Admin()                          // Below
               ENDIF
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               SCROLL( 19, 0, 24,80 )
               DISPBOX( 19, 1, 24,79, 2 )
               nl := 20
               cdesc    := Admin->Desc
               cadminno := Admin->Adminno
               @ nl,10 SAY "Admin Desc" GET cdesc      PICTURE "@X"
               nl+=2
               @ nl,10 SAY "Reference"  GET cadminno PICTURE "@!"
                READ
            ENDIF                        // Empty
            SELECT PartOper
             ApFlock( 3 )
            APPEND BLANK
            PartOper->Adminno := cadminno
            PartOper->Desc    := cdesc
            PartOper->Partnum := mpartnum
            PartOper->Codeno  := Part->Codeno 
            PartOper->Date    := DATE()
            UNLOCK
            LOOP

         CASE nselect == 5                 // Order of Operation
            mok := "Y"
            DO WHILE mok = "Y"

               aPart_:={}
               nrecno  := 0
               SELECT PartOper
               SET ORDER TO 1       // Partnum
               SEEK mpartnum            
               DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() )
                  ntime := 0
                  cdesc := SPACE( 60 )
                  DO CASE
                     CASE PartOper->Adminno != SPACE( 8 )
                          cdesc := PartOper->Adminno+" "+PartOper->Desc;
                                   +" "+STR( PartOper->Time, 8, 2 )
                     CASE PartOper->Drawno != SPACE( 8 )
                          cdesc := PartOper->Drawno+" "+PartOper->Desc+"     Drawing"
                  ENDCASE
                  AADD( aPart_,PartOper->Order;
                               +" "+cdesc;
                               +"                           "+STR( RECNO(),6 ) )
                  SKIP ALIAS PartOper
               ENDDO                        // PartOper EOF
               IF !EMPTY( aPart_ )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  SCROLL(  3, 0, 24,80 )
                  DISPBOX( 3, 1, 24,79, 2 )
                  anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
                  IF LASTKEY() = 27
                     EXIT
                  ENDIF
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
                   ApRLock( 3 )   
                  @ ROW(), 2 GET PartOper->Order PICTURE "!!"
                   READ   
                  UNLOCK
                  LOOP
                ENDIF                        // Empty
             ENDDO                                // mok
             LOOP

         CASE nselect == 6                // Print Operation
            PartOperLst( @mpartnum )       // XLF_Qu9
            LOOP

         CASE nselect == 7
            JobOperate()                  // Above
            LOOP

         CASE nselect == 8
            JobDraw()                    // JobDem
            LOOP

         CASE nselect == 9
            Admin()
            LOOP
         CASE nselect == 10
            OperCopy()                    // Above
            LOOP
         CASE nselect == 11                        // Add Part
            SELECT Part
            SET ORDER TO 1                       // Partnum
            mpartnum := SPACE( 20 )
             Partfind( @mpartnum )                // XF_Part
            mpartnum := Part->Partnum
            IF LASTKEY() = 27
               LOOP
            ENDIF 
            SELECT PartOper 
             ApFlock( 3 )
            APPEND BLANK
            PartOper->Operno := SUBSTR( mpartnum, 1, 8 )
            PartOper->Date   := DATE()
            PartOper->Desc   := Part->Desc
            UNLOCK
            SCROLL( 14, 0, 20,80 )
            DISPBOX( 14, 0, 20,79, 2 )
            cdesc  := PartOper->Desc
            cdesc1 := PartOper->Desc1
            cdesc2 := PartOper->Desc2
            corder := PartOper->Order
            ntime  := PartOper->Time
            @ 15, 5 SAY PartOper->Operno    COLOR "BG+"
            @ 16, 5 SAY "Desc"  GET cdesc  PICTURE "@X"
            @ 17,10 GET cdesc1  PICTURE "@X"
            @ 18,10 GET cdesc2  PICTURE "@X"
            @ 19, 5      SAY "Order" GET corder PICTURE "@!"
            @ 19,COL()+2 SAY "Time"  GET ntime  PICTURE "99999.99"
             READ
             ApRlock( 3 )
            PartOper->Desc  := cdesc
            PartOper->Desc1 := cdesc1
            PartOper->Desc2 := cdesc2
            PartOper->Order := corder
            PartOper->Time  := ntime
            UNLOCK
            LOOP
      ENDCASE

      manother := "N"

   ENDDO                             // manother

   RETURN NIL
   *****-----------    End of PartOper2()

   ***-------------------------------------------------------------------------

FUNCTION JCDirect()

   ////   This is for JC Print

   mwhere := "S"
   npl    := 20
   nl     := 0
   
   Printsel()                               // _LF_Init

   IF mwhere == "P"
      npl := 64
      @  0, 0
      SET DEVICE TO PRINT
    ELSE
     nl  := 1
     npl := 23  
   ENDIF
   minvno := Debit->Invno
   @ nl, 1 SAY Control->U_Name
   @ nl,36 SAY "- Operation Report - "+minvno
   @ nl,63 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
              +STR(YEAR(DATE()),5)
   nl+=2
   SELECT Name
   SEEK Debit->Codeno       // Quot->Codeno
   @ nl, 0 SAY TRIM( Name->Name )+"  "+TRIM( Debit->Est )+" JC- "+minvno
   nl++
   @ nl,28 SAY "Start"
   @ nl,34 SAY DTOC( Debit->StartDate ) 
   @ nl,45 SAY "Due"
   @ nl,49 SAY DTOC( Debit->DueDate ) 
   nl++
   @ nl, 3 SAY Debit->Fault
   nl++
   @ nl, 3 SAY Debit->Message
   @ nl,54 SAY Debit->DbDate
   nl++
   SELECT Quot 
   SET ORDER TO 3                    // Invno
   SEEK Debit->Invno
   SELECT Part
   SEEK Quot->Partnum
         @ nl, 0 SAY STR( Quot->Qty, 7, 2 )+" "+SUBSTR( Part->Unit, 1, 6);
                     +" "+Part->Desc;
                     +" "+SUBSTR( Quot->Partnum, 1,16 )
   nl++
   mcodeno  := Quot->Codeno
   mpartnum := Quot->Partnum
   ntimetotal:= ntime := 0
   SELECT PartOper
   SET ORDER TO 1        // Partnum
   GOTO TOP
   SEEK mpartnum
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
   DO CASE
      CASE PartOper->Adminno != SPACE( 8 )
            @ nl, 1 SAY PartOper->Desc
            @ nl,63 SAY PartOper->Adminno
            @ nl,76 SAY PartOper->Order
            nl++
      CASE PartOper->Drawno != SPACE( 8 )
            @ nl, 1 SAY PartOper->Desc
            @ nl,63 SAY PartOper->Drawno
            @ nl,76 SAY PartOper->Order
            nl++
      ENDCASE
      SELECT PartOper
      SKIP ALIAS PartOper
   ENDDO                     // PartOper EOF
   nl++
   SELECT Quot
   SEEK mcodeno
   DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
      IF Quot->Invno != minvno
         SKIP ALIAS Quot
         LOOP
      ENDIF
      nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
      SELECT Equ
      mmod1 := TRIM( Quot->Partnum )
      SEEK mmod1
      SELECT PartOper
      SET ORDER TO 1               // Partnum
      GOTO TOP
      SEEK Quot->Partnum
      mpartnum := Quot->Partnum
      DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() ) 
         @ nl, 2 SAY SUBSTR( PartOper->Partnum, 1,16 );
                    +" "+PartOper->Drawno;
                    +" "+PartOper->Desc+" "+PartOper->Order
         nl++
         SKIP ALIAS PartOper
      ENDDO 
      ntimetotal:= ntime := 0
      SELECT PartOper
      SET ORDER TO 1        // Partnum
      GOTO TOP
      SEEK mpartnum
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
         DO CASE
            CASE PartOper->Adminno != SPACE( 8 )
                 @ nl, 1 SAY PartOper->Desc
                 @ nl,63 SAY PartOper->Adminno
                 @ nl,76 SAY PartOper->Order
                 nl++
            CASE PartOper->Drawno != SPACE( 8 )
                 @ nl, 1 SAY PartOper->Desc
                 @ nl,63 SAY PartOper->Drawno
                 @ nl,76 SAY PartOper->Order
                 nl++
            ENDCASE
            SELECT PartOper
            SKIP ALIAS PartOper
         ENDDO                     // PartOper EOF
         nl++
         SELECT Equ
         GOTO TOP
         SET EXACT ON
         mmod1 := TRIM( Quot->Partnum )
         SEEK mmod1
         IF FOUND()   
            DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
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
               SELECT PartOper
               SEEK Equ->Partnum
               mpartnum := Equ->Partnum
               DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() ) 
                  @ nl, 2 SAY SUBSTR( PartOper->Partnum, 1,16 );
                              +" "+PartOper->Drawno;
                              +" "+PartOper->Desc+" "+PartOper->Order
                  nl++
                  SKIP ALIAS PartOper
               ENDDO 
               SELECT Equ
               mmod2 := TRIM( Equ->Partnum )
               nrecno2 := RECNO() 
               GOTO TOP
               SEEK mmod2
               IF FOUND()   
                  DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
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
                     SELECT PartOper
                     SEEK Equ->Partnum
                     mpartnum := Equ->Partnum
                     DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() ) 
                        @ nl, 2 SAY SUBSTR( PartOper->Partnum, 1,16 );
                                  +" "+PartOper->Drawno;
                                  +" "+PartOper->Desc+" "+PartOper->Order
                        nl++
                        SKIP ALIAS PartOper
                     ENDDO 
                     SELECT Equ
                     mmod3 := TRIM( Equ->Partnum )
                     nrecno3 := RECNO() 
                     GOTO TOP
                     SEEK mmod3
                     IF FOUND()   
                        DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
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
                           SELECT PartOper
                           SEEK Equ->Partnum
                           mpartnum := Equ->Partnum
                           DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() ) 
                               @ nl, 2 SAY SUBSTR( PartOper->Partnum, 1,16 );
                                          +" "+PartOper->Drawno;
                                          +" "+PartOper->Desc+" "+PartOper->Order
                              nl++
                              SKIP ALIAS PartOper
                           ENDDO 
                           ntimetotal:= ntime := 0
                           SELECT PartOper
                           SET ORDER TO 1        // Partnum
                           GOTO TOP
                           SEEK mpartnum
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
                           DO CASE
                              CASE PartOper->Adminno != SPACE( 8 )
                                    @ nl, 1 SAY PartOper->Desc
                                    @ nl,63 SAY PartOper->Adminno
                                    @ nl,76 SAY PartOper->Order
                                    nl++
                              CASE PartOper->Drawno != SPACE( 8 )
                                    @ nl, 1 SAY PartOper->Desc
                                    @ nl,63 SAY PartOper->Drawno
                                    @ nl,76 SAY PartOper->Order
                                    nl++
                              ENDCASE
                              SELECT PartOper
                              SKIP ALIAS PartOper
                           ENDDO                     // PartOper EOF
                           nl++
                           SELECT Equ
                           mmod4   := TRIM( Equ->Partnum )
                           nrecno4 := RECNO()
                           GOTO TOP
                           SEEK mmod4
                           IF FOUND()
                              DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
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
                              SELECT PartOper
                              SEEK Equ->Partnum
                              mpartnum := Equ->Partnum
                              DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() ) 
                                 @ nl, 2 SAY SUBSTR( PartOper->Partnum, 1,16 );
                                            +" "+PartOper->Drawno;
                                            +" "+PartOper->Desc+" "+PartOper->Order
                                 nl++
                                 SKIP ALIAS PartOper
                              ENDDO 
                              ntimetotal:= ntime := 0
                              SELECT PartOper
                              SET ORDER TO 1        // Partnum
                              GOTO TOP
                              SEEK mpartnum
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
                              DO CASE
                                  CASE PartOper->Adminno != SPACE( 8 )
                                       @ nl, 1 SAY PartOper->Desc
                                       @ nl,63 SAY PartOper->Adminno
                                       @ nl,76 SAY PartOper->Order
                                       nl++
                                 CASE PartOper->Drawno != SPACE( 8 )
                                       @ nl, 0 SAY PartOper->Desc
                                       @ nl,63 SAY PartOper->Drawno
                                       @ nl,76 SAY PartOper->Order
                                       nl++
                                 ENDCASE
                                 SELECT PartOper
                                 SKIP ALIAS PartOper
                              ENDDO                     // PartOper EOF
                              nl++
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
         ENDIF
         SELECT Equ
         GOTO nrecno2
         SKIP ALIAS Equ
         ENDDO                       //   mmod1 EOF()
      ENDIF                          // Found mmod1
      ***         SET EXACT OFF      
      SELECT Quot
      SKIP ALIAS Quot
   ENDDO                            //   EOF() Quot
   IF mwhere = "P"
      @ nl, 0 SAY " "
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
   SELECT Quot 
   SET ORDER TO 1                    // Codeno
   SELECT PartOper
   SET ORDER TO 1

   RETURN NIL
   ***-------- End of JCDirect

   *******----------------------   END OF XF2PPART.PRG
