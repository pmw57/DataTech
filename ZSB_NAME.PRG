   ***  JK 21-08-11 13:25:06 

/*
   Program.....:              ZSB_NAME.PRG
   Author......: J.Kirby
   Date........: 01/09/1993
   Functions...: Nameadd, NameRank, NameView
   Static funcs: NameSeek
*/

FUNCTION Nameadd( mcodeno )

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      mcodeno := SPACE( 8 )
      mok := "N"
      SCROLL( 11, 3,23,76 )
      IF Note->Select9 = "Y" 
        mok := ApGetN( "Select Operation" )
      ENDIF 
      IF mok = "Y"
         mrefer := "NAME"
         CardAdd( @mrefer )                // Jobdemnd
      ELSE
         @ 15,40 SAY "Enter Name Code No ie SMITH  8 Characters"
         @ 17,47 SAY "Codeno" GET mcodeno PICTURE "@!"
          READ
         SELECT Name
         GOTO TOP
         SEEK mcodeno
         DO WHILE FOUND()
            @ 19,47 SAY "Already exists Esc to Quit"
            @ 21,47 SAY "Codeno" GET mcodeno PICTURE "@!"
             READ
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF mcodeno == SPACE(8)
               LOOP
            ENDIF
            SEEK mcodeno
         ENDDO                          // FOUND()
         SELECT Name
          ApFLock( 3 )
         APPEND BLANK
         Name->Codeno := mcodeno
         Name->Add2   := "P.O.Box"
         Name->Add4   := Control->U_Add3
         Name->Add5   := Control->U_Add4
         Name->Datein := DATE()
         Name->Branch := Control->U_Branch
         UNLOCK

      ENDIF                         // Shan 

       Nameget( @mcodeno )

      mcontinue := "N"
   ENDDO

   RETURN mcodeno

   ***** End of NameAdd()

   ****---------------------------------------------------------------------

FUNCTION NameRank( mcodeno )

   mcorrect := "N"
   DO WHILE mcorrect == "N"
      SCROLL()
      SELECT Rept
      GOTO TOP
      nl:= nll:= nlll := 5
      npl:= npll := 20 
      ccodeno := SPACE( 8 )
      @  4,53 SAY "Reports past 5 days" COLOR "BG+"
      DO WHILE Rept->( !EOF() )
         IF Rept->Date <= DATE()-5
            SKIP ALIAS Rept
            LOOP
         ENDIF
         IF Rept->Codeno = ccodeno
            SKIP ALIAS Rept
            LOOP
         ENDIF
         DO CASE
            CASE nl <= npl
               @ nl,52   SAY Rept->Codeno+" "+Rept->Out
               nl++
            CASE nll <= npll
               @ nll,66  SAY Rept->Codeno+" "+Rept->Out
               nll++
            OTHERWISE
               WAIT    
               SCROLL( 4, 52,21,79 )
               @  4,53 SAY "Reports Over Flow" COLOR "BG+"
               @ nlll,54 SAY Rept->Codeno+" "+Rept->Out 
               nlll++
         ENDCASE 
         ccodeno := Rept->Codeno
         SKIP ALIAS Rept
      ENDDO                          // EOF()
      nl:= nll:= nlll:= nllll := 5
      npl:= npll:= nplll := 22
      SELECT QuotStk
      SET ORDER TO 3  // Codeno
      GOTO TOP
      @  4, 5 SAY "Orders" COLOR "G+"
      ccodeno := SPACE( 8 )
      DO WHILE QuotStk->( !EOF() )
         IF QuotStk->Codeno = Control->U_Codeno
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
         IF QuotStk->Codeno = ccodeno
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
         IF QuotStk->Received >= QuotStk->Required
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
         IF SUBSTR( QuotStk->Partnum, 1,2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
         IF SUBSTR( QuotStk->Modcode, 1,2 ) = "XY"
            SKIP ALIAS QuotStk
            LOOP
         ENDIF
         ***          IF QuotStk->Ordnum != "   "
         ***             SKIP ALIAS QuotStk
         ***             LOOP
         ***          ENDIF
         DO CASE
            CASE nl <= npl
               @ nl, 5 SAY ccodeno 
               nl++
            CASE nll <= npll
               @ nll,15 SAY ccodeno
               nll++
            CASE nlll <= nplll
               @ nlll,25 SAY ccodeno 
               nlll++
            OTHERWISE
               @ nllll,35 SAY ccodeno
               nllll++
         ENDCASE
         SELECT QuotStk 
         ccodeno := QuotStk->Codeno
         SKIP ALIAS QuotStk
      ENDDO                          // EOF()
      SELECT Name
      mcodeno := SPACE( 8 )
      DISPBOX( 0, 1, 2,79, 2 )
      @  1, 8      SAY "Name Characters" GET mcodeno PICTURE "@!"
      @  1,COL()+2 SAY "Blank for Options"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      anum := {}
      aPart_:={}
      nrecno := 0
      IF mcodeno != SPACE( 8 )
 
         NameSeek( @mcodeno )                       // Above 
          
         RETURN mcodeno
      ENDIF
      SCROLL(  0, 0, 2,80 )
      DISPBOX( 0, 1, 2,79, 2 )
      nselect  := 1
      @ 1, 3      PROMPT "1.Group"
      @ 1,COL()+2 PROMPT "2.Add New"
      @ 1,COL()+2 PROMPT "3.Report"
      @ 1,COL()+2 PROMPT "4.All Names"
      @ 1,COL()+2 PROMPT "5.Another"
      @ 1,COL()+2 PROMPT "6.Quick Add"
      @ 1,COL()+2 PROMPT "7.City"
      @  2,72 SAY " DT21 "
      MENU TO nselect
      DO CASE
         *******************
         CASE nselect == 7     // City
            SELECT Name
            ApFLock( 3 )
            INDEX ON Add4 TO TempInd4
            SET INDEX TO TempInd4
            UNLOCK
            clocate  := SPACE( 16 )
            SELECT Name
            GOTO TOP
            aPart_:={}
            nrecno  := 0
            DO WHILE Name->( !EOF() )
               DO WHILE Name->Add4 = clocate
                  SKIP ALIAS Name
                  LOOP        
               ENDDO
               AADD( aPart_,Name->Add4;
                      +"                   "+STR( RECNO(),6 ) )
               clocate := Name->Add4
               SKIP ALIAS Name
            ENDDO
            DISPBOX(  3, 0, 24,36, 2 )
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum := ACHOICE(  4, 3, 23,34, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               clocate  := Name->Add4
            ENDIF
            SELECT Name
            SCROLL()
            DISPBOX(  0, 0, 3,79, 2 )
            @  1,10 SAY clocate+" Location"
            aPart_:={}
            nrecno   := 0
            mpartnum := SPACE( 16 )
            IF LASTREC() != 0
               GOTO TOP
               SEEK clocate
               DO WHILE Name->Add4 = clocate .AND. Name->( !EOF() )
                  AADD( aPart_,Name->Codeno;
                     +" "+Name->Add4;
                     +" "+Name->Name; 
                     +"                 "+STR( RECNO(),6 ) )
                  SKIP ALIAS Name
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
                  mcodeno := Name->Codeno
               ENDIF                // ! Empty
            ENDIF                           // Found
            SELECT Name
            SET INDEX TO NameInd
            SEEK mcodeno
            RETURN mcodeno
            *******************
         CASE nselect = 1
            SET INDEX TO NameInd
            SCROLL(  3, 0,24,80 )
            DISPBOX( 3, 1,24,79, 2 )
            GOTO TOP
            nselect := 1
            @  4,10 PROMPT Menu1->Mess01
            @  5,10 PROMPT Menu1->Mess02
            @  6,10 PROMPT Menu1->Mess03
            @  7,10 PROMPT Menu1->Mess04
            @  8,10 PROMPT Menu1->Mess05
            @  9,10 PROMPT Menu1->Mess06
            @ 10,10 PROMPT Menu1->Mess07
            @ 11,10 PROMPT Menu1->Mess08
            @ 12,10 PROMPT Menu1->Mess09
            @ 13,10 PROMPT Menu1->Mess10
            @ 14,10 PROMPT Menu1->Mess11
            @ 15,10 PROMPT Menu1->Mess12
            @ 16,10 PROMPT Menu1->Mess13
            @ 17,10 PROMPT Menu1->Mess14
            @  4,26 PROMPT "ALL SALE    "
            @  5,26 PROMPT "Email List  "
            @  6,26 PROMPT "CITY        "
            @  7,26 PROMPT "MARKETING          "
            @  8,26 PROMPT "MARKETING SALES    "
            @  9,26 PROMPT "MARKETING REPORTS  "
            @ 10,26 PROMPT "MARKETING ALL Codes"
 
            MENU TO nselect
            DO CASE
               CASE PressedEsc()
                  RETURN NIL
               CASE nselect == 1
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Message->Mess01, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 2
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess02, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 3
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess03, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 4
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess04, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 5
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess05, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 6
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess06, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 7
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess07, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 8
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess08, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 9
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess09, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 10
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess10, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 11
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess11, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 12
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess12, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 13
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess13, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 14
                  DO WHILE Name->( !EOF() )
                     IF Name->Sale != SUBSTR( Menu1->Mess14, 1,4 )
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_,Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,22 );
                        +"       "+STR( RECNO(),6 ) )
                     SKIP ALIAS Name
                  ENDDO

               CASE nselect == 15
                  DO WHILE Name->( !EOF() )
                     AADD( aPart_, ( Name->Sale;
                        +" "+Name->Name;
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1, 1,18 );
                        +"       "+STR( RECNO(),6 ) ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 16
                  DO WHILE Name->( !EOF() )
                     IF Name->Email = "            "
                        SKIP ALIAS Name
                        Loop
                     ENDIF
                     AADD( aPart_, ( Name->Email;
                        +" "+SUBSTR( Name->Name, 1,25 );
                        +" "+Name->Phone;
                        +"       "+STR( RECNO(),6 ) ) )
                     SKIP ALIAS Name
                  ENDDO
 
               CASE nselect == 17
                  SELECT Name
                  GOTO TOP
                  ApFLock( 3 )
                  INDEX ON Name->Add4 TO TempName
                  UNLOCK
                  cnameadd4 := SPACE( 20 )
                  mtempno := SPACE( 20 )
                  anum := {}
                  aPart_:={}
                  nrecno := 0
                  mcodeno := SPACE( 8 )
                  DO WHILE Name->( !EOF() )
                     IF Name->Add4 = mtempno
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     mtempno := Name->Add4
                     AADD( aPart_, ( Name->Add4;
                        +"       "+STR( RECNO(),6 ) ) )
                     SKIP ALIAS Name
                  ENDDO
                  SCROLL()
                  DISPBOX(  0, 1, 24,26, 2 )
                  IF !EMPTY( aPart_ )
                     ASORT( aPart_,,,{ | x,y | x < y } )
                     anum := ACHOICE( 1, 3, 23,24,aPart_,,"AFUNC" )
                     nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
                     GOTO nrecno        
                     cnameadd4 := Name->Add4
                  ENDIF
                  anum := {}
                  aPart_:={}
                  nrecno := 0
                               
                  DO WHILE Name->( !EOF() )
                     IF Name->Add4 != cnameadd4
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     AADD( aPart_, ( Name->Add4;
                        +" "+SUBSTR( Name->Name, 1,25 );
                        +" "+Name->Phone;
                        +" "+SUBSTR( Name->Add1,1,18 );
                        +"       "+STR( RECNO(),6 ) ) )
                     SKIP ALIAS Name
                  ENDDO
               CASE nselect == 18
                  SELECT Name
                  GOTO TOP
                  ApFLock( 3 )
                  INDEX ON Name->Add4 TO TempName
                  UNLOCK
                  cnameadd4 := SPACE( 20 )
                  mtempno := SPACE( 20 )
                  anum := {}
                  aPart_:={}
                  nrecno := 0
                  mcodeno := SPACE( 8 )
                  DO WHILE Name->( !EOF() )
                     IF Name->Add4 = mtempno
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     mtempno := Name->Add4
                     AADD( aPart_, ( Name->Add4;
                        +"       "+STR( RECNO(),6 ) ) )
                     SKIP ALIAS Name
                  ENDDO
                  SCROLL()
                  DISPBOX(  0, 1, 24,26, 2 )
                  IF !EMPTY( aPart_ )
                     ASORT( aPart_,,,{ | x,y | x < y } )
                     anum := ACHOICE( 1, 3, 23,24,aPart_,,"AFUNC" )
                     nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
                     GOTO nrecno        
                     cnameadd4 := Name->Add4
                  ENDIF
                  SELECT Name
                  GOTO TOP
                  ApFLock( 3 )
                  INDEX ON Name->Sale TO TempSale
                  SET INDEX TO TempSale
                  UNLOCK
                  cnameSale := SPACE( 4 )
                  mtempno := SPACE( 4 )
                  anum := {}
                  aPart_:={}
                  nrecno := 0
                  mcodeno := SPACE( 8 )
                  DO WHILE Name->( !EOF() )
                     IF Name->Add4 != cnameAdd4
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     IF Name->Sale = mtempno
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     mtempno := Name->Sale
                     AADD( aPart_, ( Name->Sale;
                        +"       "+STR( RECNO(),6 ) ) )
                     SKIP ALIAS Name
                  ENDDO
                  DISPBOX(  0,30, 24,40, 2 )
                  IF !EMPTY( aPart_ )
                     ASORT( aPart_,,,{ | x,y | x < y } )
                     anum := ACHOICE( 1,32, 23,38,aPart_,,"AFUNC" )
                     nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
                     GOTO nrecno        
                     cnameSale := Name->Sale
                  ENDIF
                  *************************
                  mwhere := "S"
                  npl    := 0
                  nl     := 1

                  Printsel()                               // _LF_Init


                  SCROLL()
                  SELECT Name
                  GOTO TOP
                  SET INDEX TO NameInd
                  *** SET INDEX TO TempName
                  **** SEEK cnameAdd4
                  **** DO WHILE Name->Add4 = cnameAdd4 .AND. Name->( !EOF() )
                  DO WHILE Name->( !EOF() )
                     IF Name->Add4 != cnameAdd4 .OR. Name->Sale != cnameSale
                        SKIP ALIAS Name
                        LOOP
                     ENDIF
                     @ nl, 0 SAY Name->Name
                     @ nl,46 SAY TRIM( Name->Called)+" "+TRIM( Name->Famname )
                     nl++
                     @ nl, 6 SAY Name->Add1
                     @ nl,34 SAY Name->Add2
                     nl++
                     @ nl, 6 SAY Name->Add3
                     @ nl,34 SAY Name->Add4
                     @ nl,66 SAY Name->Sale
                     nl++
                     @ nl, 0 SAY "Ph "+Name->Phone
                     @ nl,18 SAY "Mob "+Name->MobPhone
                     @ nl,40 SAY Name->Email
                     nl++
                     IF nl > npl
                        IF mwhere == "P"
                           EJECT
                        ELSE
                           WAIT
                           SCROLL()
                        ENDIF
                        nl := 0
                        ***      Namelsthd()                               // Below

                     ENDIF
                     ****   dyear := YEAR( DATE() )
                     ***   nl++
                     ntotqty3:= ntotqty2:= ntotqty1:= ntotqty:= nTotal := 0
                     ntotcost3:= ntotcost2:= ntotcost1:= ntotcost:= ncosttot := 0
                     ***      ENDIF
                     SELECT Hist
                     GOTO TOP
                     SEEK Name->Codeno
                     nqtytotal:= nqty:= nqty1:= nqty2:= nqty3 := 0
                     DO WHILE Hist->Codeno = Name->Codeno .AND. Hist->( !EOF() )
                        /*
                        IF YEAR( Hist->PDate) != dyear
                           SKIP ALIAS Hist
                           LOOP
                        ENDIF
                        */
                        ntotal    += Hist->Amount*Hist->Qty 
                        nqtytotal += Hist->Amount*Hist->Qty 
                        ncosttot  += Hist->Cost*Hist->Qty
                        /*
                        IF MONTH( Hist->PDate) < ( MONTH( DATE() )-3 )
                           SKIP ALIAS Hist
                           LOOP
                        ENDIF
                        DO CASE
                           CASE MONTH( Hist->PDate ) = ( MONTH( DATE() )-3 )
                              nqty3     += Hist->Amount*Hist->Qty
                              ntotqty3  += Hist->Amount*Hist->Qty
                              ntotcost3 += Hist->Cost*Hist->Qty
                           CASE MONTH( Hist->PDate ) = ( MONTH( DATE() )-2 )
                              nqty2     += Hist->Amount*Hist->Qty
                              ntotqty2  += Hist->Amount*Hist->Qty
                              ntotcost2 += Hist->Cost*Hist->Qty
                           CASE MONTH( Hist->PDate ) = ( MONTH( DATE() )-1 )
                              nqty1     += Hist->Amount*Hist->Qty
                              ntotqty1  += Hist->Amount*Hist->Qty
                              ntotcost1 += Hist->Cost*Hist->Qty
                           CASE MONTH( Hist->PDate ) = ( MONTH( DATE() ) )
                              nqty     += Hist->Amount*Hist->Qty
                              ntotqty  += Hist->Amount*Hist->Qty
                              ntotcost += Hist->Cost*Hist->Qty
                        ENDCASE
                        */
                        SKIP ALIAS Hist
                     ENDDO                                 // EOF Hist
                     IF nqtyTotal > 0
                        /*
                        SELECT Months
                        dmonth := CMONTH( DATE() )
                        LOCATE FOR TRIM( Months->Name ) = TRIM( dmonth ) 
                        nrecno := RECNO()
                        GOTO nrecno+3  
                        @  nl,28 SAY Months->Name
                        GOTO nrecno+2 
                        @  nl,38 SAY Months->Name
                        GOTO nrecno+1 
                        @  nl,48 SAY Months->Name
                        @  nl,58 SAY CMONTH( DATE() )
                        @  nl,66 SAY "Total Yr Td"
                        nl++ 
                        ***         @ nl, 0 SAY SUBSTR( Name->Name, 1,25 )
                        @ nl,26 SAY nqty3     PICTURE "9999,999"
                        @ nl,36 SAY nqty2     PICTURE "9999,999"
                        @ nl,46 SAY nqty1     PICTURE "9999,999"
                        @ nl,56 SAY nqty      PICTURE "9999,999"
                        */
                        ****         nl++
                        @ nl,56 SAY Name->Sale
                        @ nl,64 SAY nqtyTotal PICTURE "$9,999,999.99"
                        nl++
                     ENDIF
                     SELECT Name
                     SKIP ALIAS Name
                  ENDDO
                  IF mwhere == "P"
                     EndPrint()
                     SET MARGIN TO 0
                  ELSE
                     mok := "N"
                     DO WHILE mok = "N"
                        mok := ApReadN()
                     ENDDO
                  ENDIF
                  SET INDEX TO NameInd
                  LOOP  
     
               CASE nselect == 14
                  MarkName()
                  LOOP
               CASE nselect == 15
                  MarkRept()
                  LOOP
               CASE nselect == 16
                  MarkAll()
                  LOOP
            ENDCASE
            SCROLL()
            DISPBOX(  0, 1, 24,79, 2 )
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum := ACHOICE( 1, 3, 23,78,aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
               GOTO nrecno        
            ENDIF

            IF LASTKEY() == -1
               NameAdd()                           // Below
            ENDIF
            IF PressedEsc()
               RETURN NIL
            ENDIF
            mcodeno := Name->Codeno
            ***         SCROLL()

         CASE nselect == 2       
            NameAdd()                             // Below   
            mcodeno := Name->Codeno
            RETURN mcodeno

         CASE nselect == 5       
            NameAdd()                             // Below   
            mcodeno := Name->Codeno
            RETURN mcodeno

         CASE nselect == 3
            SCROLL(  3, 0,24,80 )
            DISPBOX( 3, 1,24,79, 2 )
            anum := {}
            aPart_:={}
            nrecno := 0
            mcodeno := SPACE( 8 )
            SELECT Rept
            GOTO TOP
            IF LASTREC() != 0
               DO WHILE Rept->( !EOF() )
                  AADD( aPart_, ( Rept->Codeno;
                     +" "+Rept->Suppid;
                     +" "+Rept->Stat+" "+Rept->Info;
                     +"            "+STR( RECNO(),6 ) ) )
                  SKIP ALIAS Rept
               ENDDO
               IF !EMPTY( aPart_ )
                  anum := ACHOICE( 4, 3, 23,78,aPart_,,"AFUNC" )
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  IF PressedEsc()
                     RETURN NIL
                  ENDIF
                  GOTO nrecno        
                  mcodeno := Rept->Codeno
                  SELECT Name
                  SEEK mcodeno
                  EXIT
               ENDIF
            ENDIF                // Lastrec 

         CASE nselect == 4
            aPart_:={}
            SCROLL( 0, 0,maxrow(),maxcol() )
            IF LASTREC() != 0
               GOTO TOP
               DO WHILE Name->( !EOF() )
                  AADD( aPart_, ( Name->Codeno;
                     +" "+SUBSTR( Name->Name,1,23 );
                     +"  "+SUBSTR( Name->Add1,1,22 );
                     +" "+Name->Phone+"  "+STR( RECNO(),6 ) ) )
                  SKIP ALIAS Name
               ENDDO
               DISPBOX(  0, 1, 21,79, 2 )
               @ 23, 5 SAY Message->Select
               @ 23,50 SAY Message->Esc
               IF !EMPTY( aPart_ )
                  anum := ACHOICE( 1, 3, 20,77,aPart_,,"AFUNC" )
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno        
                  mcodeno := Name->Codeno
               ENDIF
               IF LASTKEY() == -1
                  NameAdd()                           // Below
               ENDIF
               IF PressedEsc()
                  RETURN NIL
               ENDIF
            ENDIF

         CASE nselect == 6       
           NameQuick()                             //   
           mcodeno := Name->Codeno
           RETURN mcodeno

         CASE nselect == 7
            LOOP

      ENDCASE
      mcodeno  := Name->Codeno
      mcorrect := "Y"
   ENDDO                               // Do While

   RETURN mcodeno

   ****------  End of NameRank()

   **-------------------------------------------------------------------

STATIC FUNCTION NameSeek( mcodeno )

   aPart_:={}
   mpart := TRIM( mcodeno )
   nrecno := 0
   SCROLL( 3, 0,maxrow(),maxcol() )
   FOR x = 1 TO LEN( mpart )
     SEEK SUBSTR( mpart, 1, x )      // Tracer
     IF !FOUND()
       mpart   := SUBSTR( mpart,1,( x-1 ) )
       mcodeno := SPACE( 8 )
      ***    RETURN mcodeno
       EXIT
     ENDIF
   NEXT
   SELECT Name
   IF LASTREC() != 0
      COUNT WHILE Name->Codeno = mpart TO mpcnt
      GOTO TOP
      SEEK mpart
      IF FOUND()
         DO WHILE Name->Codeno = mpart .AND. Name->( !EOF() )
            IF Message->Mess09 = SPACE( 12 )
               AADD( aPart_, ( SUBSTR( Name->Name,1,22 );
                   +" "+SUBSTR( Name->Add1,1,22 );
                   +" "+Name->Phone+" "+Name->Codeno+"   "+STR( RECNO(),6 ) ) )
             ELSE
               AADD( aPart_, ( Name->Codeno;
                     +" "+SUBSTR( Name->Name,1,22 );
                     +"  "+SUBSTR( Name->Add1,1,22 );
                     +" "+Name->Phone+"  "+STR( RECNO(),6 ) ) )
             ENDIF
             SKIP ALIAS Name
         ENDDO
         IF Message->Mess09 = SPACE( 12 )
            ASORT( aCatcode_,,,{ | x,y | x < y } )
         ENDIF
      ENDIF
      mheight := mpcnt+3
      IF mheight > 20
         mheight := 20
      ENDIF
      DISPBOX(  3, 1, mheight+2,79, 2 )
      @ 23, 5 SAY Message->Select
      @ 23,50 SAY "F2 = Add F3 = Edit"
      IF !EMPTY( aPart_ )
         anum := ACHOICE( 4, 5, mheight,76,aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         IF LASTKEY() == -1
              NameAdd( @mcodeno )
            mcodeno := Name->Codeno
              NameRank( @mcodeno )
         ENDIF
         IF LASTKEY() == -2
            mcodeno := Name->Codeno
             NameGet( @mcodeno )                           // ZFE_Name
             SCROLL()
         ENDIF
         IF PressedEsc()
            RETURN NIL
         ENDIF
      ENDIF
      SCROLL( 1, 3, 1,73 )
      @ 1,10 SAY Name->Codeno+" "+Name->Name  
      SCROLL( 3, 3, 22,78 )
      coderef := Name->Codeno
       
        MemoDisp( coderef )       // XF-Memo2

         SCROLL( 3, 3, 22,78 )

   ENDIF

   RETURN mcodeno

   ****----- End of NameSeek()

   **-------------------------------------------------------------------

FUNCTION NameView()

   mcodeno := SPACE( 8 )

       Namerank( @mcodeno )               //  Above

   mok := "Y"
   DO WHILE mok = "Y"  
      ntotal:= nqtotal := 0
      mok := "Y"
      SELECT Name
      mcodeno := Name->Codeno   
       Branchshow( @mcodeno )                   // Below
         SCROLL()
         DISPBOX( 0, 1,  2,79, 2 )
         SELECT Name
         @  1, 5 SAY Name->Name+"  "+Name->Codeno
         DISPBOX( 2, 1, 20,79, 2 )
         coderef := Name->PayRef
       
          MemoDisp( coderef )       // XF-Memo2

         SCROLL( 3, 3, 20,78 )
         @  4, 5 SAY Name->Add1
         @  5, 5 SAY Name->Add2
         @  6, 5 SAY Name->Add3
         @  7, 5 SAY Name->Add4
         @  8, 5 SAY Name->Add5+" "+Name->Zip
         @  9, 5 SAY "Priv Phone   "+Name->Ephone
         @ 10, 5 SAY "Bus  Phone   "+Name->Phone  COLOR "BG+"
         @ 11, 5 SAY "Fax Number   "+Name->Bphone COLOR "BG+"
         @ 12, 5 SAY "Mobile       "+Name->MobPhone
      ***      @ 10,45 SAY "Pager etc    "+Name->OthPhone
         @ 13, 5 SAY "Email "+SUBSTR( Name->Email, 1,25 ) 
         nl := 14
         @ nl, 5 SAY SUBSTR( Name->Contact, 1,35 )
         nl++
         @ nl, 5 SAY SUBSTR( Name->Desc, 1,35 )
         nl++
         @ nl, 5 SAY SUBSTR( Name->Desc1, 1,35 )
         nl++
         @ nl, 5 SAY SUBSTR( Name->Desc2, 1,35 )
         nl++
         @ nl, 5 SAY SUBSTR( Name->Desc3, 1,35 )
         nl := 4 
         SELECT Rept
         SET ORDER TO 2
         GOTO TOP
         SEEK Name->Codeno
         DO WHILE Rept->Codeno = Name->Codeno .AND. Rept->( !EOF() )
             @ nl,36 SAY Rept->Date PICTURE "99/99/9999" 
             @ nl,48 SAY Rept->Stat+" "+Rept->SuppId
             nl++
             @ nl,36 SAY Rept->Info
             nl++
             IF Rept->Date <= DATE()-150
                SKIP ALIAS Rept
                LOOP
             ENDIF
             IF nl > 19
                WAIT
                SCROLL( 4,36, 20,78 )
                nl := 4
             ENDIF
   /*
             IF Rept->Info1 != SPACE( 50 )
                @ nl,30 SAY Rept->Info1
                nl++
             ENDIF
             IF Rept->Info2 != SPACE( 50 )
                @ nl,30 SAY Rept->Info2
                nl++
             ENDIF
             IF Rept->Info3 != SPACE( 50 )
                @ nl,30 SAY Rept->Info3
                nl++
             ENDIF
             IF Rept->Info4 != SPACE( 50 )
                @ nl,30 SAY Rept->Info4
                nl++
             ENDIF
             IF Rept->Info5 != SPACE( 50 )
                @ nl,30 SAY Rept->Info5
                nl++
             ENDIF
    */ 
           SKIP ALIAS Rept
         ENDDO                                 // EOF Rept
         SELECT Rept
         SKIP ALIAS Rept
      ***   ENDDO

      SCROLL(  18, 0, 24,80 )
      DISPBOX( 18, 1, 24,79, 2 )
      nselect := 1
      @ 18,10 SAY " Name Details "
      @ 21, 5      PROMPT "  "
      @ 21,COL()+2 PROMPT "1. Client Report"
      @ 21,COL()+2 PROMPT "2. Edit Name"
      @ 21,COL()+2 PROMPT "3. General Memo"
      @ 21,COL()+2 PROMPT "4. Special Memo"
      @ 23, 9      PROMPT "5. Branch"
      ****   @ 23,COL()+2 PROMPT "6. Profile"
      @ 23,COL()+2 PROMPT "6. Another Name"
      @ 23,COL()+2 PROMPT "7. Quick Name"
      @ 23,COL()+2 PROMPT "8. Sale Info"
      @ 24,60 SAY " DT212 "
     
      MENU TO nselect
      DO CASE
         CASE PressedEsc()
            mok := "N"
            EXIT
        CASE nselect == 1
             LOOP 
         CASE nselect == 2
             NameSuppl()                                   // Deb25
             LOOP 
         CASE nselect == 3
             mcodeno := Name->Codeno
             NameGet( @mcodeno )                           // ZFE_Name
             LOOP
         CASE nselect == 4                                // Memo
             IF Name->PayRef = "       "
                @ 19,20 SAY "General Memo for Name" COLOR "BG+"
                SELECT Name
                 ApRLock( 3 )
                Name->PayRef := "GEN"+TRIM( Name->Codeno )+STR( Recno(),4 )
                UNLOCK
             ENDIF 
             coderef  := Name->PayRef
              M2Memofile( coderef )                     // XF_Memo2
            mcodeno := Name->Codeno
            mok := "Y"
            LOOP
         CASE nselect == 5                                // Memo
             @ 19,20 SAY "Special Memo for Accounts etc" COLOR "BG+" 
             coderef  := mcodeno
              M2Memofile( coderef )                     // XF_Memo2
            mcodeno := Name->Codeno
            mok := "Y"
            LOOP
         CASE nselect == 6
             mcodeno := Name->Codeno
             BranchAdd( @mcodeno )                         //  Below
      ***      CASE nselect == 7
      ***          tempscrn := SAVESCREEN( 0, 0, 24,80 )
      ***          SCROLL()
      ***          ProfView()                                    // XLF_Prof
      ***          nc  := ncl
      ***          ncl := 25
      ***           Mu_Prof( nc, ncl )                            //  ZSF_Name.prg
      ***          RESTSCREEN(  0, 0, 24,80,tempscrn )
      ***          LOOP
         CASE nselect == 7
             NameView()                                    // Above
             LOOP  
         CASE nselect == 8
             NameQuick()                                   // XLF_Ser
             LOOP  
         CASE nselect == 9
             OperLetter()                                 // XLF_Ser
             LOOP  
       ENDCASE
       LOOP
   ENDDO 

   RETURN mcodeno

   ***---------  End of Nameview

   ****----------------   END OF FILE ZSB_NAME.PRG
