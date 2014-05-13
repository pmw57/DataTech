   *** JoKir10  18-10-11 13:20:36 

/*  
   Program.....:                  XLF_CAT.PRG
   Authors.....: J.Kirby
   Date........: 11/03/1995
   Functions...: PartStk, PartManage, AdminDiag, AdminTreat
                 Mu_Cat, CatTotal
   Static funcs: Cathd, CatAdd, CatDelete, CatView
   Not used....: CatValue, CatCost
*/

FUNCTION PartStk()

   ccatno := SPACE(12)
   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      CatArray()            // This sorts out Cat File
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
               +" "+SUBSTR( Part->Desc, 1,28 );
               +" "+SUBSTR( Part->Locate, 1, 8 );
               +" "+STR( Part->Instock,10, 3 );
               +" "+SUBSTR( Part->Unit, 1, 6 );
               +"           "+STR( RECNO(),6 ) )
            SKIP ALIAS Part
         ENDDO   // Part EOF
         SCROLL() 
         DISPBOX( 0, 1, 2,79, 2 )
         @  1,10 SAY SUBSTR( Cat->CatDesc, 1,45 )
         @  1,58 SAY "Instock"
         DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE( 4, 3, 22,77, aPart_,,"AFUNC" )
            IF LASTKEY() = 27
               EXIT
            ENDIF  
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
         ENDIF
         ninstock  := Part->Instock
         nminstk   := Part->MinStk
         nmaxstk   := Part->MaxStk
         mdesc     := Part->Desc
         msuplcode := Part->Codeno
         mweight   := Part->Weight
         mlocate   := Part->Locate
         mlocdesc  := Part->Locdesc 
         medit := "N" 
         @ ROW(),57 GET ninstock   PICTURE "999999.999"
         @ ROW(),69 SAY "Edit" GET medit VALID( medit $"NY" ) PICTURE "!"
          READ
         mpartnum := Part->Partnum
         SELECT Part
          ApRLock( 3 )
         Part->Instock := ninstock
         UNLOCK
         IF medit = "Y"
             SCROLL( 6, 2, 23,78 )
             clocate  := Part->Locate
             clocDesc := Part->Locdesc
             mlookup  := Part->Locate
             @  8, 4 SAY ccatno+" "+TRIM( Cat->Catdesc );
                     +" "+TRIM( Part->PartId ) COLOR "RG+"
             @ 10, 7 SAY Part->Locate+"  "+Part->LocDesc COLOR "RG+"
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
               SCROLL( 10, 4, 20,76 )
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
            mpartnum = Part->Partnum
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
         ENDIF   // mdesc
         LOOP
      ENDDO                    // mok

      mprint := APGetN( " Do You want to print Catalogue" )
      IF mprint = "Y"
         mwhere := "P"
         npl    := 63
         npn    := 1

         Printsel( mwhere, npl )                        // _LF_Init

         IF mwhere = "P"
            npl := 63
           ELSE
            npl := 22
         ENDIF 
         SELECT Cat
         GOTO TOP
         SEEK ccatno

         Cathd()                                       // Below

         SELECT Part
         SET ORDER TO 2                      // Catno+Partnum
         SEEK ccatno
         DO WHILE Part->Catno == ccatno .AND. Part->( !EOF() )
            IF nl > npl
               IF mwhere == "P"
                 EJECT
               ELSE
                  WAIT
                  SCROLL()
               ENDIF
               Cathd()                          // Below
            ENDIF
            @ nl, 0 SAY SUBSTR( Part->Partnum, 1,16 )
            @ nl,17 SAY SUBSTR( Part->Desc, 1,30 )
            @ nl,48 SAY SUBSTR( Part->Locate, 1, 6 )
            @ nl,55 SAY Part->Instock PICTURE "99,999.999"
            @ nl,66 SAY "______"
            @ nl,73 SAY SUBSTR( Part->Unit, 1, 6 )
            nl++
            SKIP ALIAS Part
         ENDDO       
         IF mwhere == "S"
            WAIT
         ELSE
            EndPrint()
         ENDIF
            
      ENDIF
      mcontinue := ApGetY( Message->Another )
      IF LASTKEY() = 27
         RETURN NIL
      ENDIF  
   ENDDO                    // mcontinue
   COMMIT
   SELECT Part
   SET ORDER TO 1                  // Partnum
   *** SEEK mpartnum

   RETURN NIL

   ****  End of PartStk()

   ***---------------------------------------------------------------------*

FUNCTION CatValue()

   CatArray()
   ccatno := Cat->Catno

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
   @  nl,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   nl+=2
   @ nl, 3 SAY Cat->Catno+"  "+Cat->Catdesc
   nl+=2
   @ nl, 0 SAY "Part #"
   @ nl,18 SAY "Description"
   @ nl,58 SAY "Excl GST"
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
         npn := npn+1
         @  nl, 0 SAY TRIM( Control->U_Name )+"   Page "+STR( npn, 1, 3 )
         @  nl,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                     +STR( YEAR(DATE() ),5 )
         nl+=2
         @ nl, 3 SAY Cat->Catno+"  "+Cat->Catdesc
         nl+=2
         @ nl, 0 SAY "Part #"
         @ nl,18 SAY "Description"
         @ nl,58 SAY "Excl GST"
         nl++
      ENDIF
      @ nl, 0 SAY SUBSTR( Part->Partnum, 1,16 )
      @ nl,17 SAY Part->Desc
      @ nl,58 SAY Part->Wholesale PICTURE "9999,999.99"
      *** *(( Control->GSTRate/100 )+1 )
      nl++
      SELECT Part 
      SKIP ALIAS Part
   ENDDO                      // Part  Catno       
   nl++
   IF mwhere == "S"
      WAIT
      mwhere := "N" 
   ELSE
      EndPrint()
      SET MARGIN TO 0
   ENDIF

   RETURN NIL

   ****------------------------------------------------------------------------

FUNCTION PartManage()
   mok      := "N"
   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      cpart    := SPACE( 16 ) 
      mpartnum := SPACE( 16 ) 
      SELECT Part
      PartFind() 

      mpartFind := Part->Partnum
      cpart := SUBSTR( Part->Partnum, 1,16 )
      SCROLL(  2, 0,24,80 )
      DISPBOX( 2, 0, 24,79, 2 )
      nl := 4
      ncount := 0
      SELECT EquCut
      SEEK cpart
      IF FOUND()
         @  3, 6 SAY SUBSTR( EquCut->Modseqno, 1,16 ) COLOR "RG+"
         SELECT EquCut
         SEEK SUBSTR( cpart, 1, 16 )
         DO WHILE SUBSTR( EquCut->ModSeqno, 1,16 ) = cpart;
               .AND. EquCut->( !EOF() )
            ncount++
            SKIP ALIAS EquCut
         ENDDO                            // While EquCut
         @  3,28      SAY "Number of Cuts ="
         @  3,COL()+1 SAY ncount PICTURE "99,999" COLOR "RG+"
         @  3,COL()+2 SAY "Qty"  
         ncount := 0    
         SELECT EquCut
         SEEK cpart
         DO WHILE SUBSTR( EquCut->ModSeqno, 1,16 ) = cpart;
               .AND. EquCut->( !EOF() )
            ncount++
            /*
            IF ncount > 36
               @ 23,16 SAY "More Than 36 Cuts" COLOR "RG+"
               INKEY( 1 ) 
               EXIT 
            ENDIF
            */ 
            IF nl > 22
               INKEY( 0 )
               nl := 5
               SCROLL(  nl, 2, 23,78 )
            ENDIF
            @ nl, 3      SAY SUBSTR( EquCut->Partnum, 1,16 ) COLOR "RG+"
            @ nl,COL()+1 SAY SUBSTR( EquCut->ModRef, 1,28 )  COLOR "RG+"
            @ nl,COL()+1 SAY EquCut->Qty    PICTURE "9999.99"
            @ nl,COL()+1 SAY EquCut->Length PICTURE "999.999"
            IF EquCut->Width != 0 
               @ nl,COL()+1 SAY EquCut->Width  PICTURE "999.999"
               @ nl,COL()+1 SAY "Sq Mtr"  
            ENDIF
            nl++
            SKIP ALIAS EquCut
         ENDDO                            // While EquCut
      ENDIF                             // Found 
      DISPBOX( 19, 0, 24,79, 2 )
      @ 20, 6 SAY cpart  COLOR "RG+"
      mchoice := 1
      @ 22, 3      PROMPT " "
      @ 22,COL()+2 PROMPT "1. Cuts One Part"  
      @ 22,COL()+2 PROMPT "2. Cuts Only"  
      @ 22,COL()+2 PROMPT "3. Part in Total"  
      @ 22,COL()+2 PROMPT "4. # Cuts"  
      @ 22,COL()+2 PROMPT "5. Exit"  
      MENU TO mchoice
      DO CASE
         CASE mchoice == 6 .OR. PressedEsc()
            RETURN NIL
         CASE mchoice == 1
            WAIT
         CASE mchoice == 5
            nl := 5 
            SCROLL()
            nnumber := 20
            @  4,10      SAY "Number of Cuts" GET nnumber PICTURE "999999"
            @  4,COL()+2 SAY "This is per Part in the Module"
            READ   
            nl := 6
            ncount := 0
            SELECT EquCut
            GOTO TOP
            cmodseqno := EquCut->ModSeqno
            DO WHILE EquCut->( !EOF() )
               ncount := 0
               SEEK cmodseqno
               DO WHILE EquCut->ModSeqno = cmodseqno;
                     .AND. EquCut->( !EOF() )
                  @ 2,10 SAY EquCut->ModSeqno COLOR "RG+"
                  ncount++
                  SKIP ALIAS EquCut
               ENDDO                            // While EquCut   
               /*
               SELECT EquDesc
               SEEK cmodseqno
               IF FOUND()
                   ApRLock( 3 )
                  EquDesc->Amount := ncount
                  UNLOCK
               ENDIF
               */ 
               SELECT EquCut 
               IF ncount > nnumber
                  @ nl,10      SAY ncount PICTURE "99,999" COLOR "RG+"
                  @ nl,COL()+2 SAY EquCut->Modseqno+"   "+STR( RECNO() )  
                  nl++
                  ncount := 0
               ENDIF
               IF nl > 20
                  WAIT
                  nl := 5
                  SCROLL()
               ENDIF
               nrecno := RECNO()
               GOTO nrecno
               cmodseqno := EquCut->ModSeqno
            ENDDO                            // EquCut EOF
            SELECT EquCut
            GOTO TOP

         CASE mchoice == 2
            manother := "Y"
            DO WHILE manother = "Y" 
               cmodseqno := SPACE( 20 )
               SELECT EquCut
               GOTO TOP
               ncount := 1
               nrecno := 0
               aPart_ := {}
               SEEK cpart
               DO WHILE SUBSTR( EquCut->Modseqno, 1,16 ) = cpart;
                     .AND. EquCut->( !EOF() )
                  ncount++
                  /*
                  IF ncount > 36
                     @ 23,16 SAY "More Than 36 Cuts" COLOR "RG+"
                     INKEY( 1 ) 
                     ncount := 0
                     EXIT
                  ENDIF
                  */ 
                  AADD( aPart_,SUBSTR( EquCut->Partnum, 1,16 );
                     +" "+SUBSTR( EquCut->Modref, 1,29 );
                     +" "+STR( EquCut->Qty ) ;
                     +"  "+SUBSTR( EquCut->ModSeqno,17, 6 );
                     +"                "+STR( RECNO(),6 ) )
                  SKIP ALIAS EquCut
               ENDDO   // EquCut EOF
               SCROLL() 
               DISPBOX( 0, 0, 2,79, 2 )
               @  1, 6 SAY cpart COLOR "RG+"
               DISPBOX( 3, 0, 23,79, 2 )
               IF !EMPTY( aPart_ )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE( 4, 3, 22,77, aPart_,,"AFUNC" )
                  IF LASTKEY() = 27
                     EXIT
                  ENDIF  
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
                  mpartnum := EquCut->Partnum
                  cmodseqno := EquCut->Modseqno
               ENDIF
               /*
               @ 18,15 SAY mpartnum+"  "+cmodseqno COLOR "RG+"
               mok := ApGetN( TRIM( Message->Delete ) )
               IF mok == "Y"
                  SELECT EquCut
                   ApFLock( 3 )
                    DELETE ALL FOR EquCut->ModSeqno = cmodseqno;
                             .AND. EquCut->Partnum = mpartnum  
                  UNLOCK
               ENDIF        // mok
               */
               mok :=  ApGetN( "Edit the Cuts" )
               DO WHILE mok = "Y"
                  nrecno := 0
                  aPart_ := {}
                  SELECT EquCut
                  SEEK cpart      // SUBSTR( mpartnum, 1, 16 )
                  DO WHILE SUBSTR( EquCut->ModSeqno, 1,16 ) = cpart;
                        .AND. EquCut->( !EOF() )
                     AADD( aPart_,EquCut->Partnum;
                        +" "+SUBSTR( EquCut->ModRef, 1,28 );
                        +" "+STR( EquCut->Qty, 8, 3 );
                        +" "+STR( EquCut->Length, 8, 3);
                        +" "+STR( EquCut->Width, 8 ,3 );
                        +"                       "+STR( RECNO(),6 ) )
                     SKIP ALIAS EquCut
                  ENDDO                       // EquCut
                  SCROLL() 
                  DISPBOX( 0, 0, 2,79, 2 )
                  @  1,17 SAY "Module Cuts"
                  DISPBOX( 3, 0, 24,79, 2 )
                  IF !EMPTY( aPart_ )
                     ASORT( aPart_,,,{ | x,y | x < y } )
                     anum := ACHOICE( 4, 3, 23,77, aPart_,,"AFUNC" )
                     IF LASTKEY() = 27
                        EXIT
                     ENDIF  
                     nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                     GOTO nrecno
                  ENDIF
                  cmodref := EquCut->Modref
                  nqty    := EquCut->Qty
                  nlength := EquCut->Length
                  nwidth  := EquCut->Width
                  mdelete := "N"  
                  @ ROW(), 2 SAY SPACE( 76 ) 
                  @ ROW(), 2 GET cmodref PICTURE "@X"
                  @ ROW()+1, 2 SAY SPACE( 76 ) 
                  @ ROW(), 2 SAY "Qty"    GET nqty    PICTURE "99999.999"
                  @ ROW(),18 SAY "Length" GET nlength PICTURE "99999.999"
                  @ ROW(),36 SAY "Width"  GET nwidth  PICTURE "99999.999"
                  @ ROW(),56 SAY "Delete" GET mdelete Valid( mdelete $"NY") PICTURE "!"
                  READ
                  IF PressedEsc()
                     EXIT
                  ENDIF
                  ApRLock( 3 )
                  EquCut->ModRef := cmodref 
                  EquCut->Qty    := nqty 
                  EquCut->Length := nlength 
                  EquCut->Width  := nwidth 
                  UNLOCK
                  IF mdelete = "Y"
                      ApRLock( 3 )
                     DELETE
                     UNLOCK
                  ENDIF
                  LOOP
               ENDDO  
               ************
               manother := ApGetY( "Another Cut Part" )
               IF manother = "Y"
                  LOOP
                ELSE 
                  manother := "N"
               ENDIF
            ENDDO                 // manother 

         CASE mchoice == 3
            ncount := 1 
            nl := 7
            SCROLL(  3, 0, 24,80 )
            @  4, 3 SAY SUBSTR( EquCut->Modseqno, 1,16 ) COLOR "RG+"
            SELECT EquCut
            SEEK SUBSTR( cpart, 1, 16 )
            DO WHILE SUBSTR( EquCut->ModSeqno, 1, 16 ) = SUBSTR( cpart, 1, 16 );
                  .AND. EquCut->( !EOF() )
               ncount++
               IF ncount > 36
                  @ 23,16 SAY "More Than 36 Cuts" COLOR "RG+"
                  INKEY( 1 ) 
                  ncount := 0
                  EXIT
               ENDIF 
               IF nl > 20
                  INKEY( 1 )
                  nl := 5
                  SCROLL(  nl, 2, 24,78 )
               ENDIF
               @ nl, 2      SAY SUBSTR( EquCut->Partnum, 1,16 ) COLOR "RG+"
               @ nl,COL()+2 SAY SUBSTR( EquCut->ModRef, 1, 30 ) COLOR "RG+"
               @ nl,COL()+1 SAY "Qty"
               @ nl,COL()+1 SAY EquCut->Qty    PICTURE "9999.99"
               @ nl,COL()+1 SAY EquCut->Length PICTURE "999.999"
               IF EquCut->Width != 0 
                  @ nl,COL()+1 SAY EquCut->Width  PICTURE "999.999"
                  @ nl,COL()+1 SAY "Sq Mtr"  
               ENDIF
               nl++
               SKIP ALIAS EquCut
            ENDDO                           //  cpart 
            mok := ApGetN( TRIM( Message->Delete ) )
            IF mok == "Y"
               SELECT EquCut
                ApFLock( 3 )
               DELETE ALL FOR SUBSTR( EquCut->ModSeqno, 1,16 ) = SUBSTR( cpart, 1,16 ) 
               UNLOCK
            ENDIF        // mok

         CASE mchoice == 4
            SELECT Part
            SEEK mpartfind
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
               ENDDO                        // Debit
               @ 21,10 SAY "    Please Wait takes Me time   "
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
               SELECT Quot
               ApFLock( 3 )
               DELETE ALL FOR Quot->Partnum = mpartnum 
               UNLOCK
               SELECT QuotInfo
               ApFLock( 3 )
               DELETE ALL FOR QuotInfo->Partnum = mpartnum 
               UNLOCK
               SELECT Supl
               ApFLock( 3 )
               DELETE ALL FOR Supl->Partnum = mpartnum 
               UNLOCK
               @ 22,20 SAY mpartnum+" Deleted" COLOR "RG+"
               INKEY( 2 ) 
               mpartnum := SPACE( 20 )
               ***            ELSE
               ***             mcontinue := "Y"
           ENDIF                            // mok
      ENDCASE          // mchoice               
      mcontinue := ApGetN( "Another Part :" )
   ENDDO                              // mcontinue

   RETURN NIL

   ***----- End of PartManage()

   ***-------------------------------------------------------------------

FUNCTION AdminDiag()

    cadminno := SPACE( 8 )
    dstmm    := DATE()-30
    dendmm   := DATE()
    SCROLL()
    DISPBOX( 0, 1, 18,79, 2 )
    @  6,20 SAY "PRINTING DIAGNOSIS MENU"
    @  8,10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
    @ 10,10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
         cblank := "XX"
         @ 12,20      GET cblank PICTURE "@!"
         @ 12,COL()+2 SAY "Blank for Village selection"
          READ 
      IF cblank = "  "   
         SCROLL( 0,68,24,80 )
         DISPBOX(  2,68, 24,79, 2 )
         mchoice := 1
         @  4,70 PROMPT Message->Operno01  
         @  5,70 PROMPT Message->Operno02  
         @  6,70 PROMPT Message->Operno03
         @  7,70 PROMPT Message->Operno04      
         @  8,70 PROMPT Message->Operno05
         @  9,70 PROMPT Message->Operno06
         @ 10,70 PROMPT Message->Operno07
         @ 11,70 PROMPT Message->Operno08
         @ 12,70 PROMPT Message->Operno09
         @ 13,70 PROMPT Message->Operno10
         @ 14,70 PROMPT Message->Operno11
         @ 15,70 PROMPT Message->Operno12
         @ 16,70 PROMPT Message->Operno13
         @ 17,70 PROMPT Message->Operno14
         @ 18,70 PROMPT Message->Operno15
         @ 19,70 PROMPT Message->Operno16
         @ 20,70 PROMPT Message->Operno17
         @ 21,70 PROMPT Message->Operno18
         MENU TO mchoice
         DO CASE
            CASE mchoice == 1
               coperno := Message->Operno01
            CASE mchoice == 2
               coperno := Message->Operno02
            CASE mchoice == 3
               coperno := Message->Operno03
            CASE mchoice == 4
               coperno := Message->Operno04
            CASE mchoice == 5
               coperno := Message->Operno05
            CASE mchoice == 6
               coperno := Message->Operno06
            CASE mchoice == 7
               coperno := Message->Operno07
            CASE mchoice == 8
               coperno := Message->Operno08
            CASE mchoice == 9
               coperno := Message->Operno09
            CASE mchoice == 10
               coperno := Message->Operno10
            CASE mchoice == 11
               coperno := Message->Operno11
            CASE mchoice == 12
               coperno := Message->Operno12
            CASE mchoice == 13
               coperno := Message->Operno13
            CASE mchoice == 14
               coperno := Message->Operno14
            CASE mchoice == 15
               coperno := Message->Operno15
            CASE mchoice == 16
               coperno := Message->Operno16
            CASE mchoice == 17
               coperno := Message->Operno17
            CASE mchoice == 18
               coperno := Message->Operno18
          ENDCASE
          cadminno := coperno
       ENDIF         // Group
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
   IF mwhere = "P"
      @  0, 0 SAY Control->U_Name
      @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
      @  2,10 SAY "From " +DTOC( dstmm ) 
      @  2,32 SAY "To "   +DTOC( dendmm ) 
      nl := 4
    ELSE
      SCROLL()
      @ 1, 6      SAY TRIM( Control->U_Name ) 
      @ 1,COL()+2 SAY "From " +DTOC( dstmm ) 
      @ 1,COL()+1 SAY "To "   +DTOC( dendmm )
      nl := 2
   ENDIF
    @ nl, 0 SAY "Village"
    @ nl,12 SAY "Diagnosis"
    nl++
    SELECT Admin
    GOTO TOP
    ntotal := 0
    cadmin := SPACE( 8 )
    cnote  := SPACE( 16 )
    nnote := 1
    DO WHILE Admin->( !EOF() )
       IF cadminno != SPACE( 8 )
          IF Admin->Adminno != cadminno
             SKIP ALIAS Admin
             LOOP
          ENDIF
       ENDIF
       IF Admin->Date < dstmm
            SKIP ALIAS Admin
            LOOP
         ENDIF
         IF Admin->Date > dendmm
            SKIP ALIAS Admin
            LOOP
         ENDIF
       IF Admin->Adminno != cadmin
         cadmin := Admin->Adminno
         LOOP
       ENDIF  
       ntotal++ 
       IF Admin->Adminno = cadmin
          IF Admin->Note = cnote
             nnote++ 
             SKIP ALIAS Admin
             LOOP
           ELSE
            IF cnote != SPACE( 16 )
               @ nl,60 SAY "Total"
               @ nl,68 SAY nnote PICTURE "99,999"
               nl++
            ENDIF
               nnote := 1
            cnote  := Admin->Note
            cadmin := Admin->Adminno
          ENDIF
       ENDIF
       IF nl > npl
          IF mwhere == "P"
             EJECT
            ELSE
             WAIT
             SCROLL()
          ENDIF
          nl := 0
          npn++ 
         IF mwhere = "P"
         @  nl, 0 SAY TRIM( Control->U_Name )
         @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
      @  2,10 SAY "From " +DTOC( dstmm ) 
      @  2,32 SAY "To "   +DTOC( dendmm )
      nl := 4 
    ELSE
      SCROLL()
      @ 1, 6      SAY TRIM( Control->U_Name ) 
      @ 1,COL()+2 SAY "From " +DTOC( dstmm ) 
      @ 1,COL()+1 SAY "To "   +DTOC( dendmm )
      nl := 2
   ENDIF
         @ nl, 0 SAY "Village"
         @ nl,12 SAY "Diagnosis"
         nl++
      ENDIF
            IF cadmin != SPACE( 16 )
               @ nl, 0 SAY Admin->Adminno
               @ nl,10 SAY Admin->Note
            ENDIF
      SKIP ALIAS Admin
   ENDDO                      // Admin       
   @ nl,60 SAY "Total"
   @ nl,68 SAY nnote PICTURE "99,999"
   nl+=2
   @ nl,50 SAY "Patient Total"
   @ nl,67 SAY ntotal PICTURE "999,999"
   nl++
   IF mwhere == "S"
      WAIT
      mwhere := "N" 
     ELSE
      EndPrint()
      SET MARGIN TO 0
   ENDIF
   ***   SET EXACT OFF
   RETURN NIL
   ****----- End of AdminDiag()

   ****---------------------------------------------------------------------------

FUNCTION AdminTreat()

    cadminno := SPACE( 8 )
    dstmm    := DATE()-30
    dendmm   := DATE()
    SCROLL()
    DISPBOX( 3, 1, 18,79, 2 )
    @  6,20 SAY "PRINTING TREATMENT MENU"
    @  8,10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
    @ 10,10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
         cblank := "XX"
         @ 12,10      GET cblank PICTURE "@!"
         @ 12,COL()+2 SAY "Blank for Village selection"
          READ 
      IF cblank = "  "   
         SCROLL( 0,68,24,80 )
         DISPBOX(  2,68, 24,79, 2 )
         mchoice := 1
         @  4,70 PROMPT Message->Operno01  
         @  5,70 PROMPT Message->Operno02  
         @  6,70 PROMPT Message->Operno03
         @  7,70 PROMPT Message->Operno04      
         @  8,70 PROMPT Message->Operno05
         @  9,70 PROMPT Message->Operno06
         @ 10,70 PROMPT Message->Operno07
         @ 11,70 PROMPT Message->Operno08
         @ 12,70 PROMPT Message->Operno09
         @ 13,70 PROMPT Message->Operno10
         @ 14,70 PROMPT Message->Operno11
         @ 15,70 PROMPT Message->Operno12
         @ 16,70 PROMPT Message->Operno13
         @ 17,70 PROMPT Message->Operno14
         @ 18,70 PROMPT Message->Operno15
         @ 19,70 PROMPT Message->Operno16
         @ 20,70 PROMPT Message->Operno17
         @ 21,70 PROMPT Message->Operno18
         MENU TO mchoice
         DO CASE
            CASE mchoice == 1
               coperno := Message->Operno01
            CASE mchoice == 2
               coperno := Message->Operno02
            CASE mchoice == 3
               coperno := Message->Operno03
            CASE mchoice == 4
               coperno := Message->Operno04
            CASE mchoice == 5
               coperno := Message->Operno05
            CASE mchoice == 6
               coperno := Message->Operno06
            CASE mchoice == 7
               coperno := Message->Operno07
            CASE mchoice == 8
               coperno := Message->Operno08
            CASE mchoice == 9
               coperno := Message->Operno09
            CASE mchoice == 10
               coperno := Message->Operno10
            CASE mchoice == 11
               coperno := Message->Operno11
            CASE mchoice == 12
               coperno := Message->Operno12
            CASE mchoice == 13
               coperno := Message->Operno13
            CASE mchoice == 14
               coperno := Message->Operno14
            CASE mchoice == 15
               coperno := Message->Operno15
            CASE mchoice == 16
               coperno := Message->Operno16
            CASE mchoice == 17
               coperno := Message->Operno17
            CASE mchoice == 18
               coperno := Message->Operno18
          ENDCASE
          cadminno := coperno
       ENDIF         // Group
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
   IF mwhere = "P"
      @  0, 0 SAY Control->U_Name
      @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
      @  2,10 SAY "From " +DTOC( dstmm ) 
      @  2,32 SAY "To "   +DTOC( dendmm ) 
      nl := 4
    ELSE
      SCROLL()
      @ 1, 6      SAY TRIM( Control->U_Name ) 
      @ 1,COL()+2 SAY "From " +DTOC( dstmm ) 
      @ 1,COL()+1 SAY "To "   +DTOC( dendmm )
      nl := 2
   ENDIF
    @ nl, 0 SAY "Village"
    @ nl,12 SAY "Treatment"
    nl++
    SELECT Admin
   ****    SET ORDER TO 2           // Adminno + Warranty
    GOTO TOP
    ncost:= ntotalcost := 0
    ntotal := 0
    cadmin := SPACE( 8 )
    cnote  := SPACE( 16 )
    nnote := 1
    DO WHILE Admin->( !EOF() )
       IF cadminno != SPACE( 8 )
          IF Admin->Adminno != cadminno
             SKIP ALIAS Admin
             LOOP
          ENDIF
       ENDIF
       IF Admin->Date < dstmm
            SKIP ALIAS Admin
            LOOP
         ENDIF
         IF Admin->Date > dendmm
            SKIP ALIAS Admin
            LOOP
         ENDIF
       IF Admin->Adminno != cadmin
         cadmin := Admin->Adminno
         LOOP
       ENDIF  
       ntotal++ 
       ntotalcost := ( ntotalcost+Admin->Quoted ) 
       IF Admin->Adminno = cadmin
          IF Admin->Warranty = cnote
             nnote++
             ncost := ( ncost+Admin->Quoted ) 
             SKIP ALIAS Admin
             LOOP
           ELSE
            IF cnote != SPACE( 16 )
               @ nl,30 SAY "Cost"
               @ nl,35 SAY ncost PICTURE "R999,999"
               @ nl,60 SAY "Total"
               @ nl,68 SAY nnote PICTURE "99,999"
               nl++
            ENDIF
               nnote := 1
               ncost := 0
            cnote  := Admin->Warranty
            cadmin := Admin->Adminno
          ENDIF
       ENDIF
       IF nl > npl
          IF mwhere == "P"
             EJECT
            ELSE
             WAIT
             SCROLL()
          ENDIF
          nl := 0
          npn++ 
         IF mwhere = "P"
         @  nl, 0 SAY TRIM( Control->U_Name )
         @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
      @  2,10 SAY "From " +DTOC( dstmm ) 
      @  2,32 SAY "To "   +DTOC( dendmm )
      nl := 4 
    ELSE
      SCROLL()
      @ 1, 6      SAY TRIM( Control->U_Name ) 
      @ 1,COL()+2 SAY "From " +DTOC( dstmm ) 
      @ 1,COL()+1 SAY "To "   +DTOC( dendmm )
      nl := 2
   ENDIF
         @ nl, 0 SAY "Village"
         @ nl,12 SAY "Treatment"
         nl++
      ENDIF
            IF cadmin != SPACE( 16 )
               @ nl, 0 SAY Admin->Adminno
               @ nl,10 SAY Admin->Warranty
            ENDIF
      SKIP ALIAS Admin
   ENDDO                      // Admin       
   @ nl,30 SAY "Cost"
   @ nl,35 SAY ncost PICTURE "R999,999"
   @ nl,60 SAY "Total"
   @ nl,68 SAY nnote PICTURE "99,999"
   nl+=2
   @ nl,35 SAY ntotalcost PICTURE "R9,999,999"
   @ nl,68 SAY ntotal     PICTURE "999,999"
   nl++
   IF mwhere == "S"
      WAIT
      mwhere := "N" 
     ELSE
      EndPrint()
      SET MARGIN TO 0
   ENDIF
   ***   SET ORDER TO 1            // Adminno+Note
   RETURN NIL
   ****----- End of AdminTreat()

   ****---------------------------------------------------------------------------

FUNCTION Mu_Cat( nc, ncl )

   DO WHILE .T.

      nselect  := 0
      nc       := ncl*2
      SCROLL(  3,nc, 21,78 )
      DISPBOX( 4,nc, 21,nc+ncl )
      SCROLL(  3,nc+4, 5,nc+(ncl-4) )
      DISPBOX( 3,nc+4, 5,nc+( ncl-4 ) )
      @  4,nc+( ncl/2 )-( LEN( RTRIM( Menu->CH_CatHd ) )/2 );
                           SAY RTRIM( Menu->CH_CatHd )
      @  7,nc+2 PROMPT "1. Catalogue       Add"
      @  9,nc+2 PROMPT "2.  ..            Edit"
      @ 10,nc+2 PROMPT "3.  ..         Details"
      @ 12,nc+2 PROMPT "4. Catalogue    Delete"
      @ 13,nc+2 PROMPT "5. Catalogue Print Out"
      @ 15,nc+2 PROMPT "6. Part Quick     Edit"
      @ 16,nc+2 PROMPT "7. Part     Management"
      @ 18,nc+2 PROMPT "8. Labels by Location "
      @ 19,nc+2 PROMPT "9. Labels by Catalogue"
      @ 20,nc+2 PROMPT Menu->CH_Main
      nc := ncl
      MENU TO nselect
      DO CASE
         CASE nselect == 10 .OR. PressedEsc()
            EXIT
         CASE nselect == 1
            SAVE SCREEN TO holdscrn
              CatAdd()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
             CatView()      
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
              Catlist()                           // Specific ( CalfPart )
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
              CatDelete()                           // Below
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5        // Print
            SAVE SCREEN TO holdscrn
            CatArray()
            ccatno := Cat->Catno

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
      @  nl,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
      nl+=2
      @ nl, 3 SAY Cat->Catno+"  "+Cat->Catdesc
      nl+=2
      @ nl, 0 SAY "Part #"
      @ nl,18 SAY "Description"
      @ nl,58 SAY "Excl GST"
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
             npn := npn+1
             @  nl, 0 SAY TRIM( Control->U_Name )+"   Page "+STR( npn, 1, 3 )
             @  nl,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                         +STR( YEAR(DATE() ),5 )
             nl+=2
             @ nl, 3 SAY Cat->Catno+"  "+Cat->Catdesc
             nl+=2
             @ nl, 0 SAY "Part #"
             @ nl,18 SAY "Description"
             @ nl,58 SAY "Excl GST"
             nl++
         ENDIF
         @ nl, 0 SAY SUBSTR( Part->Partnum, 1,16 )
         @ nl,17 SAY Part->Desc
         @ nl,58 SAY Part->Wholesale PICTURE "9999,999.99"
                                      *** *(( Control->GSTRate/100 )+1 )
         nl++
         SELECT Part 
         SKIP ALIAS Part
      ENDDO                      // Part  Catno       
      nl++
      IF mwhere == "S"
         WAIT
         mwhere := "N" 
        ELSE
         EndPrint()
         SET MARGIN TO 0
      ENDIF
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6
            SAVE SCREEN TO holdscrn
             PartStk()                              // XLF_Cat.Prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
              PartManage()                           // Above
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
              LocLabel()                           // ZSB_New
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
              CatLabel()                           // ZSB_New
            RESTORE SCREEN FROM holdscrn
      ENDCASE
   ENDDO

   RETURN NIL

   ***** End of Mu_Cat()

   ***---------------------------------------------------------------------------

FUNCTION CatCost()

   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
   @  1,20 SAY "Catalogue Sell Price"

   ccatno := SPACE(12)
   mok := "Y"
   DO WHILE mok == "Y"

       CatArray()               // Creates array of Catalogue
       nl := 0

      mwhere := "S"
      npl    := 65
      npn    := 1

        Printsel( mwhere, npl )                        // _LF_Init

      IF mwhere = "P"
         npl := 65
        ELSE
         npl := 18
      ENDIF 

        Cathd()                                       // Below

       SELECT Part
       SET ORDER TO 2                      // Catno+Partnum
       SEEK ccatno
       DO WHILE Part->Catno == ccatno .AND. Part->( !EOF() )
          IF nl > npl
             IF mwhere == "P"
               EJECT
              ELSE
                WAIT
                SCROLL()
             ENDIF
              Cathd()                          // Below
         ENDIF
         @ nl, 0 SAY SUBSTR( Part->Partnum, 1,16 )
         @ nl,17 SAY SUBSTR( Part->Desc, 1,38 )
         @ nl,56 SAY Part->Wholesale PICTURE "9,999,999.99"
         @ nl,72 SAY SUBSTR( Part->Unit, 1, 8 )
         nl++
         SKIP ALIAS Part
       ENDDO       
      IF mwhere == "S"
         WAIT
        ELSE
         EndPrint()
      ENDIF
      mok := ApGetN( TRIM( Message->Another )+" Print out" )
   ENDDO

   RETURN NIL

   ***------------ End of CatCost()

   **-------------------------------------------------------------------

STATIC FUNCTION Cathd()


   nl := 0
   @  nl, 0 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  nl,18 SAY TRIM( Control->U_Name )
   @  nl,65 SAY Cat->Catno
   nl+=2
   @ nl, 3 SAY Cat->Catno+"     "+Cat->Catdesc
   nl+=2
   @ nl, 0 SAY "Partnum"
   @ nl,20 SAY "Description"
   nl++
   RETURN NIL
   ***--- End CatHd

  **-------------------------------------------------------------------

FUNCTION CatTotal()

   LOCAL dstmm  := DATE()-30
   LOCAL dendmm := DATE()+10

   mok := "Y"
   DO WHILE mok == "Y"
      SCROLL()
      DISPBOX( 0, 1, 14,79, 2 )
      @  1,20 SAY "Stock Catalogue Totals"
      @  8,10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
      @ 10,10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
       READ
      mwhere := "S"
      npl    := 54

        Printsel( mwhere, npl )                        // _LF_Init

      IF mwhere = "P"
         npl := 54
        ELSE
         npl := 19
      ENDIF
      @  0, 0 SAY Control->U_Name
      @  0,32 SAY dstmm 
      @  0,45 SAY dendmm 
      @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
      @  2, 0 SAY "Catalogue"
      @  2,32 SAY "Received"
      @  2,44 SAY "Sold/Value"
      @  2,56 SAY "Warehouse"
      @  2,68 SAY "Total Stock"
      nl := 4
      nWareGrand:= nCatGrand:= nconsGrand:= nRecGrand:= 0
      SELECT Cat
      GOTO TOP
      DO WHILE Cat->( !EOF() )
          IF nl > npl
             IF mwhere == "P"
                EJECT
               ELSE
                WAIT
                SCROLL()
             ENDIF
             @  0, 0 SAY Control->U_Name
             @  0,32 SAY dstmm 
             @  0,45 SAY dendmm 
             @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                        +STR( YEAR(DATE() ),5 )
             @  2, 0 SAY "Catalogue"
             @  2,32 SAY "Received"
             @  2,44 SAY "Sold/Value"
             @  2,56 SAY "Warehouse"
             @  2,68 SAY "Total Stock"
             nl := 4
         ENDIF
         SELECT Part
         SET ORDER TO 2                  // Catno, Desc
         GOTO TOP
         SEEK Cat->Catno
         nWaretotal:= ncattotal:= nconstotal:= nRectotal := 0
         DO WHILE Part->Catno = Cat->Catno .AND. Part->( !EOF() )
            ntotal:= nconsume := 0
            mfind := Message->Stock2+Part->Partnum
            SELECT Prof
            SEEK mfind
            IF FOUND()
               ntotal += Prof->Qty
            ENDIF
            mfind := Message->Stock3+Part->Partnum
            SELECT Prof
            SEEK mfind
            IF FOUND()
               ntotal += Prof->Qty
            ENDIF
            mfind := Message->Stock4+Part->Partnum
            SELECT Prof
            SEEK mfind
            IF FOUND()
               ntotal += Prof->Qty
            ENDIF
            SELECT Hist
            SET ORDER TO 2
            GOTO TOP
            SEEK Part->Partnum
            DO WHILE Hist->Partnum = Part->Partnum .AND. Hist->( !EOF() )
               IF Hist->PDate > dstmm .AND. Hist->PDate < dendmm
                  nconsume += ( Hist->Cost*Hist->Qty )
               ENDIF
               SKIP ALIAS Hist
            ENDDO 
            SELECT ProfNat
            SET ORDER TO 2
            GOTO TOP
            SEEK Part->Partnum
            DO WHILE ProfNat->Partnum = Part->Partnum .AND. ProfNat->( !EOF() )
               IF ProfNat->PDate > dstmm .AND. ProfNat->PDate < dendmm
                  nRectotal += ( ProfNat->Cost*ProfNat->Qty )
               ENDIF
               SKIP ALIAS ProfNat
            ENDDO 
            SELECT Part
            ntotal     += Part->Instock
            ncattotal  += ( ntotal*Part->Trade )
            nWaretotal += ( Part->Instock*Part->Trade )
            nconstotal += nconsume
            SKIP ALIAS Part
         ENDDO       
         SELECT Cat
      ***      @ nl, 0 SAY Cat->Catno
         @ nl, 0 SAY SUBSTR( Cat->CatDesc,1,30 )
         @ nl,32 SAY nrectotal  PICTURE "9999,999.99"
         @ nl,44 SAY nconstotal PICTURE "9999,999.99" 
         @ nl,56 SAY nWaretotal PICTURE "9999,999.99"
         @ nl,68 SAY ncattotal  PICTURE "9999,999.99"
         nCatGrand  += ncattotal
         nWareGrand += nWaretotal
         nconsGrand += nconstotal
         nRecGrand  += nrectotal
         nl++
         SKIP ALIAS Cat
      ENDDO
      nl++
      @ nl,23 SAY REPLICATE( "-",56 )
      nl++
      @ nl,32 SAY nRecGrand  PICTURE "9999,999.99"
      @ nl,44 SAY nconsGrand PICTURE "9999,999.99"
      @ nl,56 SAY nWareGrand PICTURE "9999,999.99"
      @ nl,68 SAY nCatGrand  PICTURE "9999,999.99"
      IF mwhere == "S"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
        ELSE
         EndPrint()
         SET MARGIN TO 0
      ENDIF
      mok := ApGetN( Message->Another+"Print out" )
   ENDDO
   SELECT ProfNat
   SET ORDER TO 1

   RETURN NIL

   ***------------ End of CatTotal()

   ***---------------------------------------------------------------------*

   STATIC FUNCTION CatAdd()

   SELECT Cat

   ccatno    := SPACE(12)
   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      mok := "N"
      DO WHILE mok == "N"
          CatArray()            // This sorts out Cat File
         SCROLL(  8, 0, 24,80 )
         DISPBOX( 8, 1, 24,79, 2 )
         @ 10, 7 SAY "Catalogue # :" GET ccatno PICTURE "@K!"
          READ
         IF PressedEsc()
            RETURN NIL
         ENDIF
         IF ccatno == SPACE(12)
            LOOP
         ENDIF
         SEEK ccatno
          ApFLock( 3 ) 
         IF !FOUND()
            APPEND BLANK
         ENDIF
         UNLOCK
         nmarkup  := Cat->Markup
         mcatdesc := Cat->Catdesc
         @ 10,42 SAY "Markup %"      GET nmarkup PICTURE "999"
         @ 12, 7 SAY "Description :" GET mcatdesc;
                 PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
          READ
          ApRLock( 3 )
         Cat->Catdesc := mcatdesc 
         Cat->Markup  := nmarkup 
         Cat->Catno   := ccatno
         UNLOCK 
         mok := ApGetY( Message->Correct+TRIM( ccatno ) ) 
         IF PressedEsc()
            RETURN NIL
         ENDIF
      ENDDO
      mcontinue := ApGetN( Message->Another+" Catalogue" )
   ENDDO

   RETURN NIL

   ***----- End of Catadd()

   **-------------------------------------------------------------------

STATIC FUNCTION CatDelete()

   SELECT Cat

   ccatno    := SPACE(12)
   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
         CatArray()            // This sorts out Cat File
         SCROLL(  12, 0, 24,80 )
         DISPBOX( 12, 1, 19,79, 2 )
         @ 14, 7 SAY "Catalogue # "+ccatno
         @ 16, 7 SAY "Description "+Cat->CatDesc
         mok := ApGetN( "Delete This Catalogue" )
         IF mok = "Y"
             ApFLock( 3 ) 
            DELETE
            UNLOCK
            mok := ApGetN( "Delete ALL Parts this Catalogue" )
            IF mok = "Y"
               @ 18, 10 SAY "ARE YOU SURE ALL PARTS THIS CATALOGUE" COLOR "RG+" 
               mok := ApGetN( "??? Delete ALL Parts this Catalogue" )
               IF mok = "Y"
                  SELECT Part
                   ApFLock( 3 ) 
                  DELETE ALL FOR Part->Catno = ccatno
                  UNLOCK
                  SELECT Cat
                ENDIF       
            ENDIF 
         ENDIF          // mok 
      mcontinue := ApGetN( "Delete another Catalogue :" )
   ENDDO

   RETURN NIL

   ***----- End of CatDelete()

   **-------------------------------------------------------------------

STATIC FUNCTION CatView()

   SELECT Cat
   ccatno := SPACE(12)

   CatArray()            // This sorts out Cat File

   SCROLL()
   moldcatno:= SPACE( 12 )
   DISPBOX( 0, 1,  2,79, 2 )
   @  1,25 SAY "Viewing Catalogue"
   DISPBOX( 3, 1, 24,79, 2 ) 
   mok := "Y"
   DO WHILE mok == "Y"
      SELECT Cat
      SEEK ccatno
      moldcatno:= ccatno := Cat->Catno
      SCROLL( 3, 0, 24,80 )
      DISPBOX( 3, 1,24,79, 2 )
      @  4,10      SAY Cat->Catno+"  "+Cat->Catdesc
      @  6,10      SAY "Viewing Cat :" GET ccatno PICTURE "@!"
      @  6,COL()+2 SAY "Edit Catno if required"
       READ
      IF ccatno != moldcatno
         SEEK ccatno
         DO WHILE FOUND()
            @  6,10      SAY "Already Used " GET ccatno PICTURE "@!"
            @  6,COL()+2 SAY "Esc To Quit               "
             READ
            IF PressedEsc()
               RETURN NIL
            ENDIF
            SEEK ccatno
         ENDDO
      ENDIF
      SELECT Cat
      SEEK moldcatno
      nmarkup  := Cat->Markup
      mcatdesc := Cat->Catdesc
      @  8,10 SAY "Markup %    "  GET nmarkup PICTURE "999"
      @ 10,10 SAY "Description :" GET mcatdesc;
                   PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
       READ
       ApRLock( 3 )
      Cat->Catdesc := mcatdesc 
      Cat->Markup  := nmarkup 
      Cat->Catno   := ccatno
      UNLOCK
   /*
   TAKEN OUT
      SELECT Cusnotes
      coderef := Cat->Catno
      SEEK coderef
      ***      IF FOUND()
        M2MemoFile( coderef )                      // XF_Memo2
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
      ***      ENDIF            // Found Memo
   taken out
   */
      mok := APGetN( "Change This Catalogue Price ONLY "+moldcatno )
      IF mok = "Y"
         nchange := 0
         @ 12,10 SAY "This Catalogue price ONLY by %" GET nchange PICTURE "9999.99"
          READ 
         SELECT Part
          ApFLock( 3 )
         REPLACE ALL Part->Wholesale WITH Part->Wholesale*( 1+( nchange/100) );
                     FOR Catno == moldcatno 
         UNLOCK
      ENDIF
   /*
      @ 14,10 SAY "Changes ALL the Wholesale Price BEWARE" COLOR "R+"
      mok := APGetN( "Change ALL Prices This Catno BEWARE" )
      IF mok = "Y"
         nchange := 0
         @ 16,10 SAY "Change ALL Parts price by %" GET nchange PICTURE "9999.99"
          READ 
         SELECT Part
          ApFLock( 3 )
         REPLACE ALL Part->Wholesale WITH Part->Wholesale*( 1+( nchange/100) )
         UNLOCK
      ENDIF
   */
      IF ccatno != moldcatno
         @ 15,10 SAY "New Catalogue Code "+Cat->Catno 
         @ 17,10 SAY "Changing Part, Equ, Quot Data Files"
         SELECT Part
          ApFLock( 3 )
         REPLACE ALL Part->Catno WITH ccatno FOR Catno == moldcatno 
         UNLOCK
         SELECT Equ
          ApFLock( 3 )
         REPLACE ALL Equ->Catno WITH ccatno;
                 FOR Equ->Catno == moldcatno
         UNLOCK
         SELECT Quot
          ApFLock( 3 )
         REPLACE ALL Quot->Catno WITH ccatno;
                 FOR Quot->Catno == moldcatno
         UNLOCK
      ENDIF                                            // New Cat #
      mok := ApGetN( TRIM( Message->Another )+" Catalogue" )
   ENDDO

   RETURN NIL

   ****--------- End of CatView()

   *****---------------------- End of File XLF_Cat.PRG

