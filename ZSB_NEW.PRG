   ***  JoKir10   22-10-11 07:43:35 

/*
   Program......:              ZSB_NEW.PRG
   Author.......: J.Kirby
   Date.........: 27/07/2012
   Functions....: LocSpace, CatLabel, LocLabel, SelectMenu
                  LAEdit
*/

FUNCTION LocSpace()

   SELECT Part
   SET ORDER TO 4            // Location + Partnum
   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      mok := "Y"
      DO WHILE mok = "Y"
      SELECT Part
      SET ORDER TO 4            // Location + Partnum
      GOTO TOP
      SEEK SUBSTR( mselect, 1, 1 )
         nrecno := 0
         aPart_ := {}
            DO WHILE SUBSTR( Part->Locate, 1, 1 ) = SUBSTR( mselect, 1 ,1 );
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
                  +" "+SUBSTR( Part->Partnum, 1,14 );
                  +" "+SUBSTR( Part->Desc, 1,19 );
                  +" "+SUBSTR( Part->Unit, 1, 6 );
                  +" "+STR( Part->Instock, 9, 3 );
                  +"             "+STR( RECNO(),6 ) )
               SKIP ALIAS Part
            ENDDO      // Part EOF
            SCROLL() 
            DISPBOX( 0, 1, 2,79, 2 )
            @ 1, 2 SAY " -- WAIT TAKES TIME -- "+mselect+"  "
            @ 1,58 SAY "Instock     Edit"
            DISPBOX( 3, 1, 23,79, 2 )
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum := ACHOICE( 4, 3, 22,78, aPart_,,"AFUNC" )
               IF LASTKEY() = 27
                  RETURN NIL
               ENDIF  
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
            ENDIF
            IF nrecno = 0
               RETURN NIL
            ENDIF
            IF Part->Locate = SPACE( 16 )
               SCROLL( 6, 2, 23,78 )
               @ 10,10 SAY "NO SUCH LOCATION"
               @ 14,10 SAY "  "
               WAIT
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
            IF LASTKEY() = 27
               RETURN NIL
            ENDIF  
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

   ****  End of LocSpace()

   ***---------------------------------------------------------------------*

FUNCTION CatLabel()

   nl  := 0
   mok := "Y"
   DO WHILE mok == "Y"
      SCROLL()
      mselect := "N"
      nqty    := 1
      namount := 1
      nless   := 1
      mused   := "N"
      DISPBOX(  0, 1, 18,79, 2 )
      @  2,10 SAY "Labels for Part by Catalogue"
      @  4, 6 SAY "Part Qty From  " GET nqty    PICTURE "9999"
      @  6, 6 SAY "Greater Than $ " GET namount PICTURE "99999"
      @  8, 6 SAY "Less    Than $ " GET nless   PICTURE "99999"
      @ 10, 6 SAY "Only Used Y/N  " GET mused   PICTURE "!"
      @ 14, 6 SAY "N = Catalogue Y = ALL parts " GET mselect PICTURE "!"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF 
      ccatno := SPACE( 12 )
      IF mselect = "N"
          CatArray()
         ccatno := Cat->Catno
      ENDIF 
      mwhere := "S"
      npl    := 54

      Printsel()                                  // _LF_Init

      IF mwhere == "P"
         npl := 44
      ELSE
         SCROLL()
         npl := 22
      ENDIF
      nl := 1
      SELECT Part
      SET ORDER TO 4                // Locate+Partnum  //Catno
      GOTO TOP
      SCROLL()
      ngrandTotal:= ntotal:= ncatqty:= npartstock := 0
      ntotalamount:= ncatamount := 0
      DO WHILE Part->( !EOF() )
         ngrandtotal += 1
         IF Part->BoughtOut = "Y"
            ntotal += 1
            ntotalamount += Part->Trade*Part->Instock
         ENDIF  
         IF Part->BoughtOut = "N"
            SKIP ALIAS Part
            LOOP        
         ENDIF
         IF ccatno != SPACE( 12 )
            IF Part->Catno != ccatno
              SKIP ALIAS Part
              LOOP        
            ENDIF
         ENDIF
         IF Part->Instock < nqty 
            SKIP ALIAS Part
            LOOP        
         ENDIF
         IF Part->Trade < namount
            SKIP ALIAS Part
            LOOP        
         ENDIF
         IF Part->Trade > nless
            SKIP ALIAS Part
            LOOP        
         ENDIF
         SELECT Hist
         SET ORDER TO 2
         mpartnum := Part->Partnum
         SEEK mpartnum
         nhistqty := 0
         DO WHILE Hist->Partnum = mpartnum .AND. Part->( !EOF() )
           nhistqty += Hist->Qty 
           SKIP ALIAS Hist 
         ENDDO
         SELECT Part   
         IF mused = "Y"
            IF nhistqty = 0
               SKIP ALIAS Part
               LOOP
            ENDIF        
         ENDIF
         IF nl > npl
             nl := 2
             IF mwhere == "P"
                EJECT
               ELSE
                WAIT
                SCROLL()
             ENDIF
         ENDIF
         @ nl,10 SAY Part->Desc
         nl+=2
         @ nl, 0 SAY SUBSTR( Part->Partnum, 1,16 )  
         nl+=2
         @ nl, 0 SAY Part->Locate
         @ nl,20 SAY Part->LocDesc
         nl+=2
         @ nl, 0 SAY Part->Catno
         @ nl,35 SAY Part->Trade PICTURE "$99,999.99"
         SELECT Cat
         SEEK Part->Catno
         nl++
         @ nl, 0 SAY Cat->CatDesc
         nl+=2
         @ nl, 0 SAY "Stk"
         @ nl, 9 SAY Part->Instock PICTURE "99,999.999"
         @ nl,22 SAY Part->Date    PICTURE "99/99/9999"
         @ nl,34 SAY Part->Codeno 
         nl+=2
         @ nl, 0 SAY "Instock ____________________ "+" Date __________ "
         nl+=2
         @ nl, 0 SAY Part->MinStk PICTURE "9,999.99"
         @ nl,10 SAY "Minimum _______ "
         @ nl,30 SAY "Used"
         @ nl,35 SAY nhistqty PICTURE "99,999.99"
         IF Part->BoughtOut = "Y"
            @ nl,47 SAY "Bought Out"
            ncatqty += 1
            npartstock += Part->Instock
            ncatamount += Part->Trade*Part->Instock
         ENDIF  
         nl+=2
         SKIP ALIAS Part
      ENDDO
      IF mwhere != "P"
         nl:= 1
         @ nl, 3 SAY " "
         WAIT
         SCROLL()
      ENDIF
      nl+=2
      @ nl, 4 SAY "Total Parts"
      @ nl,16 SAY ngrandtotal PICTURE "99,999"
      nl+=2 
      @ nl, 4 SAY "BoughtOut ONLY"
      nl+=2    
      @ nl, 4 SAY "Part Qty"
      @ nl,17 SAY nqty    PICTURE "999"
      @ nl,26 SAY "Greater Than"
      @ nl,40 SAY namount PICTURE "$99,999.99"
      @ nl,52 SAY "Less Than"
      @ nl,62 SAY nless   PICTURE "$99,999.99"
      nl+=2 
      @ nl, 4 SAY "Total"
      @ nl,14 SAY ntotal PICTURE "99,999"
      @ nl,24 SAY ( ntotal/ngrandtotal )*100 PICTURE "999.99%"  
      @ nl,34 SAY "Value"
      @ nl,40 SAY ntotalamount PICTURE "$999,999.99"
      nl+=2
      @ nl, 4 SAY "BoughtOut ONLY"    
      @ nl,24 SAY "Used Only "+mused    
      nl+=2 
      @ nl, 4 SAY "Selected Total"
      @ nl,24 SAY ncatqty                PICTURE "99,999"
      @ nl,36 SAY ( ncatqty/ntotal )*100 PICTURE "999.99%"
      @ nl,45 SAY "Selected Value"
      @ nl,60 SAY ncatamount             PICTURE "$999,999.99"    
      @ nl,72 SAY ( ncatamount/ntotalamount )*100 PICTURE "999.99%"
      nl++
      @ nl, 4 SAY "Selected Parts Instock"
      @ nl,30 SAY npartstock PICTURE "999,999"    
      IF ccatno != SPACE( 12 )
         nl+=2
         @ nl, 0 SAY ccatno+" "+Cat->CatDesc
      ENDIF
      nl+=2
      IF mwhere != "P"
         @ nl,3 SAY " " 
         WAIT
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

   *** End of File Catlabel()

   ****-------------------------------------------------------------

FUNCTION LocLabel()

   nl  := 0
   mok := "Y"
   DO WHILE mok == "Y"
      SCROLL()
      mselect := SPACE( 4 )
      namount := 0
      nqty    := 0 
      DISPBOX(  0, 1, 14,79, 2 )
       @  2,10      SAY "Labels for Part Location Details"
       @  4, 8      SAY "Instock Qty " GET nqty    PICTURE "9999"
       @  4,40      SAY "Trade $ "     GET namount PICTURE "9999"
       @  6, 8      SAY "Location :"   GET mselect PICTURE "@!"
       @  6,COL()+2 SAY "Blank for Look up"
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
                           +" "+SUBSTR( Part->Desc, 1,30 );
                           +" "+SUBSTR( Part->LocDesc, 1,15 );
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
      npl := 44
    ELSE
      SCROLL()
      npl := 22
   ENDIF
   nl := 1
      SELECT Part
      SET ORDER TO 4                   // Locate
      GOTO TOP
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
                DO WHILE Part->Locate = clocate
                   SKIP ALIAS Part
                   LOOP        
                ENDDO
                IF Part->Locate = SPACE( 16 )
                   SKIP ALIAS Part
                   LOOP        
                ENDIF
            ENDIF // mselect
         IF nl > npl
            nl := 2
             IF mwhere == "P"
                EJECT
               ELSE
                WAIT
                SCROLL()
             ENDIF
         ENDIF
         IF Part->Trade < namount
            SKIP ALIAS Part
            LOOP        
         ENDIF
         IF Part->Instock < nqty 
            SKIP ALIAS Part
            LOOP        
         ENDIF
            @ nl,10 SAY Part->Desc
            nl+=2
            @ nl, 0 SAY SUBSTR( Part->Partnum, 1,16 )  
            nl+=2
            @ nl, 0 SAY Part->Locate
            @ nl,20 SAY Part->LocDesc
            nl+=2
            @ nl, 0 SAY Part->Catno
            @ nl,35 SAY Part->Trade PICTURE "$99,999.99"
            SELECT Cat
            SEEK Part->Catno
            nl++
            @ nl, 2 SAY Cat->CatDesc
            SELECT Hist
            SET ORDER TO 2
            mpartnum := Part->Partnum
            SEEK mpartnum
            nhistqty := 0
            DO WHILE Hist->Partnum = mpartnum .AND. Part->( !EOF() )
              nhistqty += Hist->Qty 
              SKIP ALIAS Hist 
            ENDDO
            SELECT Part   
            nl+=2
            @ nl, 0 SAY "Stk"
            @ nl, 9 SAY Part->Instock PICTURE "99,999.999"
            @ nl,22 SAY Part->Date    PICTURE "99/99/9999"
            @ nl,34 SAY Part->Codeno 
            nl+=2
            @ nl, 0 SAY "Instock ____________________ "+" Date __________ "
            nl+=2
            @ nl, 0 SAY Part->MinStk PICTURE "9,999.99"
            @ nl,10 SAY "Minimum _______ "
            @ nl,30 SAY "Used"
            @ nl,35 SAY nhistqty PICTURE "99,999.99"
            nl+=2
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
   SET ORDER TO 1

   RETURN NIL

   ***** End of File Loclabel()

   ****-------------------------------------------------------------

FUNCTION SelectMenu()

   mmore = "Y"
   DO WHILE mmore = "Y"
      nc       := 3
      ncl      := 25
      mcodeno := SPACE( 8 )
      SCROLL(  17, 0, 24,80 )
      DISPBOX( 17, 1, 24,79, 2 )
      nsel := 1
      @ 17, 6      SAY " --- Menu --- "
      @ 19, 4      PROMPT "1. Enter Work"
      @ 19,COL()+2 PROMPT "2. Another Task"
      @ 19,COL()+2 PROMPT "3. Memo Task"
      @ 19,COL()+2 PROMPT "4. Memo Staff"
      @ 21, 4      PROMPT "5. Another Name"
      @ 21,COL()+2 PROMPT "6. Menu1"
      @ 21,COL()+2 PROMPT "7. MenuA"
      @ 21,COL()+2 PROMPT "Exit"
      @ 21,COL()+4 SAY madminno COLOR "RG+"
       MENU TO nsel
      DO CASE
         CASE nsel == 8 .OR. PressedEsc()
           IF PressedEsc() 
              RETURN NIL
           ENDIF
            MenuB2()     // XLF_MenB
       CASE nsel == 1
         ntottime := 0
         aPart_:={}
         nDays := 6
         dDate := DATE()-1
         cdatecode := SPACE( 19 )
         aPart_:={}
         nrecno := 0
         nTime  := 0
         SELECT Prof
         SET ORDER TO 2     // Codeno
         mcodeno := Name->Codeno
         GOTO TOP
         SEEK mcodeno
       IF LASTREC() != 0
         DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !EOF() )
            IF Prof->Date != dDate
               SKIP ALIAS Prof
               LOOP
            ENDIF  
            ntottime += Prof->Time
            cdatecode := DTOC( Prof->Date )+" "+Prof->Codeno
            AADD( aPart_,Prof->Operno;
                      +" "+Prof->Adminno;
                      +" "+STR( Prof->Time, 8, 2 );
                      +" "+SUBSTR( Prof->Desc, 1,35 ) )
            SKIP ALIAS Prof
         ENDDO                        // Prof EOF
       ENDIF      // 0
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @  1, 4      SAY TRIM( Name->Name ) COLOR "BG+"
         @  1,COL()+2 SAY ntottime    PICTURE "9999.99" COLOR "BG+"
         @  1,COL()+2 SAY ntottime/60 PICTURE "999.99" COLOR "BG+"
         @  1,COL()+2 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ), 5 )
         DISPBOX( 0, 1, 24,79, 2 )    // This is Special 
         ASORT( aPart_,,,{ | x,y | x < y } )
         @  3,00 SAY " "
         AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " ),QQOUT(A),Breakpoint() } )
      ENDIF                        // Empty
         SCROLL( 12, 2, 23,78 ) 
         @ 12, 4      SAY TRIM( Name->Name )        COLOR "BG+"
         @ 12,COL()+2 SAY "Staff Labour "+DTOC( dDate ) COLOR "RG+"
         @ 12,COL()+2 SAY nTotTime    PICTURE "9,999.99" COLOR "BG+"
         @ 12,COL()+2 SAY ntottime/60 PICTURE "999.99" COLOR "BG+"
         mtime := 0
         @ 14, 4      SAY "Date " GET dDate PICTURE "99/99/9999"
         @ 14,COL()+2 SAY "Check Date  ( - 1 ) Worked" 
         @ 14,COL()+2 SAY "Individuals Task" COLOR "RG+"
         @ 16, 4      SAY "Time "    GET mtime PICTURE "9999.99"
         @ 16,COL()+2 SAY "Task Qty" GET crate PICTURE "99999"
         @ 16,COL()+2 SAY "Prod "    GET mfltrecno PICTURE "!XXXXXXXXXXXXXXXXXXX"
         @ 18, 4 SAY "Desc " GET mdesc  PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
         @ 19, 4 SAY "     " GET mdesc1 PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
         @ 20, 4 SAY "     " GET mdesc2 PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
         @ 21, 4 SAY "     " GET mdesc3 PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
         @ 22, 4 SAY "     " GET mdesc4 PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
         msave := "Y"
         @ 23, 4 SAY "Save Record" GET msave VALID( msave $ "NY" ) PICTURE "@!"
          READ
         IF msave = "Y"
            msave := "N"
            @ 23,30      SAY "Keep Record" COLOR "RG+" 
            @ 23,COL()+2 GET msave VALID( msave $ "NY" ) PICTURE "@!"
             READ
         ENDIF
         SELECT Prof
         IF msave = "Y"
             ApFLock( 3 )
             APPEND BLANK
            Prof->Operno   := coperno 
            Prof->Time     := mtime
            Prof->Adminno  := clabno
            Prof->Partnum  := cjobnum 
            Prof->Date     := dDate
            Prof->Desc     := mdesc
            Prof->Desc1    := mdesc1
            Prof->Desc2    := mdesc2
            Prof->Desc3    := mdesc3
            Prof->Desc4    := mdesc4
            Prof->FltRecno := mfltrecno      // Info
            Prof->Rate     := crate
            Prof->Codeno   := mcodeno
            UNLOCK
        ENDIF                // save
        DISPBOX( 0, 1, 24,79, 2 )
         cdatecode := SPACE( 19 )
         aPart_:={}
         nrecno := 0
         nTime  := 0
         SELECT Prof
         SET ORDER TO 2     // Codeno
         GOTO TOP
         SEEK mcodeno
       IF LASTREC() != 0
         SCROLL()
         DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !EOF() )
            IF Prof->Date != dDate
               SKIP ALIAS Prof
               LOOP
            ENDIF  
            nTime += Prof->Time
            AADD( aPart_,Prof->Operno;
                      +" "+Prof->Adminno;
                      +" "+STR( Prof->Time, 8, 2 );
                      +" "+SUBSTR( Prof->Desc, 1,35 ) )
            SKIP ALIAS Prof
         ENDDO                        // Prof EOF
       ENDIF      // 0
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @  1, 4      SAY TRIM( Name->Name ) COLOR "RG+"
         @  1,COL()+2 SAY DTOC( dDate )      COLOR "RG+"
         @  1,COL()+2 SAY "Time"
         @  1,COL()+2 say Ntime PICTURE "9999.99" COLOR "BG+"
         @  1,COL()+1 say Ntime/60 PICTURE "999.99" COLOR "BG+"
         @  1,COL()+2 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                         +STR( YEAR(DATE() ),5 )
         @  1,COL()+2 SAY madminno  COLOR "RG+"
         SCROLL(  3, 0,24,80 )
         DISPBOX( 3, 1,24,79, 2 )
         ASORT(aPart_,,,{ | x,y | x < y })        
         @  3,00 SAY " "
         AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " ),QQOUT(A),Breakpoint() } )
         @ 17, 4      SAY TRIM( Name->Name )            COLOR "BG+"
         @ 17,COL()+2 SAY "Staff "+DTOC( dDate )         COLOR "RG+"
         @ 17,COL()+2 SAY nTime    PICTURE "999.99"     COLOR "BG+"
         @ 17,COL()+1 SAY nTime/60 PICTURE "999.99"     COLOR "BG+"
         @ 17,COL()+2 SAY madminno                      COLOR "RG+"
      ENDIF                        // Empty
         CASE nsel == 2
             LabourChri()
            LOOP
            RETURN NIL
         CASE nsel == 3
            SCROLL( 7, 2, 23,78 )
            @  9, 3 SAY "Demand Details  ";
                    +Demand->Labno+"     "+STR( Recno(), 4 ) COLOR "RG+"
            DISPBOX( 0, 1, 24,79, 2 )
            SELECT Demand
            coderef := Demand->Labno+STR( Recno(), 4 )
            SELECT Cusnotes
            SEEK coderef
             M2Memofile( coderef ) // XF_Memo2
      ***         RETURN NIL
            LOOP
         CASE nsel == 4
            SCROLL( 7, 2, 23,78 )
            @  9, 3 SAY "Staff Details  ";
                    +Name->Name COLOR "RG+"
            SELECT Cusnotes
            DISPBOX( 0, 1, 24,79, 2 )
            coderef := Name->Codeno+SUBSTR( Name->Name, 1, 8 )
            SEEK coderef
             M2Memofile( coderef )  // XF_Memo2
      ***        RETURN NIL
           LOOP
         CASE nsel == 5
            MenuB2()          // XLF_MenuB2
            LOOP
         CASE nsel == 6
            AnalyMenu( nc, ncl )   // UtilAnaly()  //XLF_Menu.PRG
            LOOP
         CASE nsel == 7
            AnalyMenuA( nc, ncl )   //ProfAnalyA()  //XLF_MenuA.PRG
            LOOP
      ENDCASE
      IF PressedEsc() 
         RETURN NIL
      ENDIF
   ENDDO       // mmore  

   RETURN NIL
   **** ----------- SelectMenu

   ******---------------------------------------------------------------------

FUNCTION LAEdit()

   maddnew := ApGetY( "Selected Entry" )

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      DO CASE
         CASE maddnew = "Y"   
           SCROLL()
           aPart_:={}
           nrecno := 0
         coperno:= clabno:= cjobnum := SPACE( 12 )
         dDate    := DATE()-1
         cselect := "  "  
         cdate   := "N"
            SELECT Demand
            SET ORDER TO 1               // Operno
            GOTO TOP
           IF LASTREC() != 0
              coperno := SPACE( 12 )
              DO WHILE demand->( !EOF() )
                 IF demand->Operno = SPACE( 12 )
                    SKIP ALIAS demand
                    LOOP
                 ENDIF
                 IF demand->Operno = coperno
                    SKIP ALIAS demand
                    LOOP
                 ENDIF
                 AADD( aPart_,( demand->Operno;
                        +"        "+STR( RECNO(),6 ) ) )
                 coperno := demand->Operno
                 SKIP ALIAS demand
             ENDDO                       // demand EOF
        ENDIF                   // 0
      SCROLL( 0,65, 24,80 )
      DISPBOX(  0,65, 24,79, 2 )
      @ 1,67 SAY "Task Type" COLOR "RG+"
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 2,67, 23,78,aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         IF PressedEsc()
            RETURN NIL
         ENDIF
         coperno  := Demand->Operno
      ENDIF     // 0
           aPart_:={}
           nrecno := 0
           clabno := SPACE( 12 )
           GOTO TOP
           SEEK coperno
         IF LASTREC() != 0
           IF FOUND() 
              clabno := SPACE( 12 )
              DO WHILE demand->Operno = coperno .AND. demand->( !EOF() )
                 IF demand->Operno = SPACE( 12 )
                    SKIP ALIAS demand
                    LOOP
                 ENDIF
                 IF demand->Labno = SPACE( 12 )
                    SKIP ALIAS demand
                    LOOP
                 ENDIF  
                 IF demand->Labno = clabno
                    SKIP ALIAS demand
                    LOOP
                 ENDIF  
                 AADD( aPart_, ( demand->Labno;
                        +"        "+STR( RECNO(),6 ) ) )
                 clabno := demand->Labno
                 SKIP ALIAS demand
             ENDDO
           ENDIF     // Found
         ENDIF       // 0
      SCROLL( 0,49, 24,64 )
      DISPBOX(  0,49, 24,64, 2 )
       @ 1,51 SAY "Category" COLOR "RG+"
       IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 2,51, 23,63,aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         IF PressedEsc()
            RETURN NIL
         ENDIF
         coperno := Demand->Operno
         clabno  := Demand->Labno          // Category
      ENDIF                   // Empty
           SELECT Demand
           SET ORDER TO 1         // Operno LabNo
           GOTO TOP
           SEEK coperno+clabno
        IF FOUND()
           aPart_:={}
           nrecno := 0
       IF LASTREC() != 0
           DO WHILE Demand->Operno = coperno .AND. Demand->Labno = clabno;
                   .AND. Demand->( !EOF() )
              IF demand->Operno = SPACE( 12 )
                 SKIP ALIAS demand
                 LOOP
              ENDIF  
              IF demand->Labno = SPACE( 12 )
                 SKIP ALIAS demand
                 LOOP
              ENDIF  
      ***           IF demand->Labno != clabno
      ***              SKIP ALIAS demand
      ***              LOOP
      ***           ENDIF 
              AADD( aPart_,( Demand->Operno+" "+Demand->Labno;
                    +" "+Demand->Desc+" "+Demand->JobNum;
                    +"                    "+STR( RECNO(),6 ) ) )
              SKIP ALIAS Demand
           ENDDO
         ENDIF      // 0
       ENDIF       // Found
         SCROLL()
         DISPBOX(  0, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 2, 3, 23,76,aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
      ENDIF          // aPart_ 
         IF PressedEsc()
            RETURN NIL
         ENDIF
         SCROLL()
         DISPBOX( 0, 1, 24,79, 2 )
         coperno   := Demand->Operno
         clabno    := demand->Labno       
         cdesc     := demand->Desc
         cdesc1    := demand->Desc1
         cdesc2    := demand->Desc2
         cdesc3    := demand->Desc3
         cdesc4    := demand->Desc4
         cjobnum   := Demand->Jobnum
         mfltrecno := SPACE( 20 )
         crate     := 0
      ***      mdesc1:= mdesc2 := SPACE( 40 )
         @  2, 4 SAY Name->Name COLOR "RG+"
         @  4, 4 SAY "Operno   " GET coperno PICTURE "@!"
         @  4,COL()+2 SAY "Can Enter New"
         @  4,COL()+4 SAY Demand->Operno COLOR "BG+" 
         @  6, 4 SAY "Category " GET clabno PICTURE "@!"
         @  6,COL()+4 SAY demand->Labno  COLOR "BG+" 
         @  8, 4 SAY "Task Desc" GET cdesc   PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
         @  9, 4 SAY "         " GET cdesc1  PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
         @ 10, 4 SAY "         " GET cdesc2  PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
         @ 11, 4 SAY "         " GET cdesc3  PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
         @ 12, 4 SAY "         " GET cdesc4  PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
         @ 14, 4 SAY "Section  " GET cjobnum PICTURE "@!"
         @ 24,60 SAY " DT411 "
          READ
         IF PressedEsc()
            RETURN NIL
         ENDIF
         myes := "N"
         @ 14,50 SAY "New Entry" GET myes VALID( myes $ "NY" ) PICTURE "@!"
          READ
         SELECT demand
          ApFlock( 3 )
         IF myes = "Y"
            APPEND BLANK
         ENDIF  
         Demand->StartDate := DATE()
         Demand->Date      := DATE()
         Demand->Operno    := coperno
         Demand->Labno     := clabno
         Demand->Desc      := cdesc
         Demand->Desc1     := cdesc1
         Demand->Desc2     := cdesc2
         Demand->Desc3     := cdesc3
         Demand->Desc4     := cdesc4
         Demand->JobNum    := cjobnum
         UNLOCK
      CASE maddnew = "N"
               SELECT Demand
               SET ORDER TO 1                  // operno
               GOTO TOP
               crate  := "N"
               canother := "N"
               nrecno := 0
               aPart_ := {}
               DO WHILE demand->( !EOF() ) 
                  AADD( aPart_,demand->Operno;
                              +" "+demand->Labno;
                              +" "+demand->Desc;
                              +" "+crate; 
                              +" "+canother; 
                              +"                       "+STR( RECNO(),6 ) )
                   SKIP ALIAS demand
               ENDDO                       // demand EOF
             SCROLL() 
             DISPBOX( 0, 0, 2,79, 2 )
             @  1, 4      SAY "demand" 
             @  1,30 SAY "Esc to Exit" COLOR "G+"
             @  1,62 SAY "Delete     Add" COLOR "RG+"
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
             coperno := demand->Operno
             clabno  := demand->Labno   
             cdesc1  := demand->Desc
             @ ROW(), 1 GET coperno PICTURE "@!"
             @ ROW(),13 GET clabno  PICTURE "@!"
             @ ROW(),26 GET cdesc1  PICTURE "@X"
             @ ROW(),72 GET crate VALID( crate $ "NY " )       PICTURE "@!"
             @ ROW(),76 GET canother VALID( canother $ "NY " ) PICTURE "@!"
              READ
             ApRLock( 3 )
           Demand->Operno  := coperno 
           Demand->Labno   := clabno 
           Demand->Desc    := cdesc1 
           UNLOCK 
           IF crate = "Y"
              coderef := Demand->Labno+STR( Recno(), 4 )
              SELECT Cusnotes
              SEEK coderef
              DO WHILE CusNotes->Code_ref = Coderef .AND. Cusnotes->( !EOF() )
                 @ 22,10 SAY Cusnotes->Code_ref COLOR "RG+"
                  ApFlock( 3 )
                 DELETE
                 UNLOCK
                 SKIP ALIAS CusNotes
              ENDDO                          // Found()
              SELECT Demand
               ApFlock( 3 )
              DELETE
              UNLOCK
           ENDIF
           IF LASTKEY() = 27
              RETURN NIL
           ENDIF  

           IF canother = "Y"
             mpart := SPACE( 16 )
             aPart_:={}
            nrecno  := 0
            SCROLL() 
            DISPBOX( 0, 1, 24,79, 2 )
            @ 24,60 SAY " DT411 "
            SELECT demand
            SET ORDER TO 1                    // Operno
            GOTO TOP
            SEEK coperno
            DO WHILE demand->Operno = coperno .AND. demand->( !EOF() )
               AADD( aPart_,demand->Operno;
                      +" "+demand->Labno;
                      +" "+demand->Desc;
                      +"                     "+STR( RECNO(),6 ) )
               SKIP ALIAS demand
            ENDDO                        // Prof EOF
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum := ACHOICE(  1, 2, 23,78, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
            ENDIF                        // Empty
            coperno  := SPACE( 12 )
            cdesc    := SPACE( 40 )
            cdesc1   := SPACE( 40 )
            cdesc2   := SPACE( 40 )
            cdesc3   := SPACE( 40 )
            cdesc4   := SPACE( 40 )
            clabno := SPACE( 12 )
            DO WHILE coperno = "        "
               SCROLL( 10, 0, 24,80 )
               DISPBOX( 10, 1, 24,79, 2 )
               @ 24,60 SAY " DT411 "
               nl := 14
               @ nl,10 SAY "Task       " GET coperno  PICTURE "@!"
               nl++
               @ nl,10 SAY "Category   " GET clabno PICTURE "@!"
               nl++
               @ nl,10 SAY "Description" GET cdesc    PICTURE "@X"    
               nl++
               @ nl,10 SAY "           " GET cdesc1   PICTURE "@X"
               nl++
               @ nl,10 SAY "           " GET cdesc2   PICTURE "@X"
               nl++    
               @ nl,10 SAY "           " GET cdesc3   PICTURE "@X"
               nl++
               @ nl,10 SAY "           " GET cdesc4   PICTURE "@X"
               nl++
                READ
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               SELECT demand
                 ApFlock( 3 )
                APPEND BLANK
                Demand->StartDate := DATE()
                Demand->Operno    := coperno
                Demand->Labno     := clabno
                Demand->Desc      := cdesc
                Demand->Desc1     := cdesc1
                Demand->Desc2     := cdesc2
                Demand->Desc3     := cdesc3
                Demand->Desc4     := cdesc4
                UNLOCK
            ENDDO         // coperno
            LOOP
           IF LASTKEY() = 27
              RETURN NIL
           ENDIF  
        ENDIF       // canother

   ENDCASE
   IF LASTKEY() = 27
      RETURN NIL
   ENDIF  

   LOOP

   ENDDO                                        // mcontinue

   RETURN NIL
   ****---- End of LAEdit()

   ****----------------------------------------------------------------------
