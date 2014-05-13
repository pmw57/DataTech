** JK  08-09-11 15:22:07 

   ****  SPECIAL SMALL PAY FILE   DEV ONLY

/* 
   Program.....:                    PAYVIEW.PRG
   Authors.....: J Kirby
   Date........: 26/03/1987
   Function....: ViewPay, AllPay, NamePay
*/

FUNCTION ViewPay()

   mcheqdate := DATE()
   mdelete   := "N"
   mcontinue := mok := "Y"
   DO WHILE mcontinue = "Y"
      SCROLL()
      nrecno:= anum := 0  
      aPart_ := {}
      SELECT Balance
      GOTO TOP
      DO WHILE Balance->( !EOF() )
         dyymm := SUBSTR( DTOS( Balance->DATE ) , 1, 6 )
         AADD( aPart_,dyymm;
            +"  "+STR( Balance->Amount );
            +"  "+Balance->Brief;
            +" "+SUBSTR( DTOS( Balance->DATE ), 1, 4 );
            +"       "+STR( Recno() ) )
         SKIP ALIAS Balance
      ENDDO                               // Balance EOF()
      DISPBOX( 0, 1, 24,36, 2 )
      @  0, 8 SAY " Select Month & Year "
      DISPBOX( 0,40,  2,78, 2 )
      @  1,42 SAY "Opening Monthly Balance"
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x > y } )           // < Bottom up
         anum := ACHOICE( 1, 3,23,34, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
      ENDIF
      dyymm := SUBSTR( DTOS( Balance->DATE ) , 1, 6 )
      IF PressedEsc()
         RETURN NIL
      ENDIF
      crecon := "Y"
      DISPBOX( 7,38, 16,78, 2 )
      @  6,40 SAY dyymm+"  "+STR( Balance->Amount );
         +"  "+Balance->Brief+" "+SUBSTR( DTOS( Balance->DATE ), 1, 4 )
      nselect := 2
      @  8,40 PROMPT "Only Presented Cheques"
      @  9,40 PROMPT "Issued During    Month"
      @ 10,40 PROMPT "Issued Not   Presented"
      @ 12,40 PROMPT "One Name  Code No Only"
      @ 13,40 PROMPT "All Payments          "
      @ 14,40 PROMPT "Add/Edit  Open Balance"
      MENU TO nselect
      DO CASE
         CASE PressedEsc()
            RETURN NIL
         CASE nselect == 1
            crecon := "Y"
            mok := "Y" 
            cheading := "Presented Cheque View"
         CASE nselect == 2
            crecon := "E"
            mok := "N"
            cheading := "Issued Cheque View"
         CASE nselect == 3
            crecon := "N"
            mok := "N"
            cheading := "Issued Not Presented"
         CASE nselect == 4
             NamePay()                 // Below
            LOOP
         CASE nselect == 5
            cheading := "All Cheque View"
             AllPay()                  // Above
            LOOP
         CASE nselect == 6
             BalView()                 // XF_Recon
            LOOP
      ENDCASE
      ***    ApRLock( 3 )
      ***   @ 14,40 SAY "Balance Correct ?" GET Balance->Amount PICTURE "9999999.99"
      ***    READ 
      ***   UNLOCK
      SCROLL()
      DISPBOX(  0, 1, 2,79, 2 )
      @  1,40 -( LEN(cheading)/2 ) SAY cheading
      SCROLL(  3, 0, 24,80 )
      ntotal := 0
      aPart_ := {}
      SELECT Pay
      GOTO TOP
      IF LASTREC() != 0
         DO WHILE  Pay->( !EOF() )
            DO CASE 
               CASE crecon = "Y"
                  IF Pay->Recon != "P"
                     SKIP ALIAS Pay
                     LOOP
                  ENDIF
               CASE crecon = "N"
                  IF Pay->Recon = "P"
                     SKIP ALIAS Pay
                     LOOP
                  ENDIF
            ENDCASE
            IF mok = "Y"
               IF SUBSTR( DTOS( Pay->Presdate ), 1, 6 ) != dyymm
                  SKIP ALIAS Pay
                  LOOP
               ENDIF
            ELSE
               IF SUBSTR( DTOS( Pay->Cheqdate ), 1, 6 ) != dyymm
                  SKIP ALIAS Pay
                  LOOP
               ENDIF
            ENDIF
            ntotal += Pay->Amount
            IF crecon = "Y"
               AADD( aPart_,DTOC( Pay->PresDate )+" "+Pay->Cheqno+"  "+Pay->Codeno;
                  +"  "+STR( Pay->Amount );
                  +" "+STR( Pay->Gstamnt )+"  "+Pay->Cashno;
                  +"  "+Pay->Recon;
                  +"  "+DTOC( Pay->CheqDate );
                  +"       "+STR( Recno() ) )
            ELSE
               AADD( aPart_,DTOC( Pay->Cheqdate )+" "+Pay->Cheqno+"  "+Pay->Codeno;
                  +"  "+STR( Pay->Amount );
                  +" "+STR( Pay->Gstamnt )+"  "+Pay->Cashno;
                  +"  "+Pay->Recon;
                  +"  "+DTOC( Pay->PresDate );
                  +"       "+STR( Recno() ) )
            ENDIF
            SKIP ALIAS Pay
         ENDDO                               // Pay EOF()
         DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            @ 1,57 SAY ntotal PICTURE "$9,999,999.99" COLOR "G+"
            IF crecon = "Y"
               @ 3, 2 SAY " Presented Date  "
            ELSE
               @ 3, 2 SAY " Issued Date  "
            ENDIF 
            anum   := ACHOICE( 4, 3,23,76, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         ELSE
            @ 14,20 SAY "--- No Payments this Month ---"
            WAIT
            RETURN NIL 
         ENDIF
      ENDIF
      SELECT Pay
      GOTO nrecno
      SELECT Name
      SEEK Pay->Codeno
       ApRLock( 3 )
      cname := SUBSTR( Name->Name,1,25 )
      UNLOCK
      SELECT Pay
      SCROLL(  12, 0, 24,80 )
      DISPBOX( 12, 1, 19,79, 2 )
      @ 14, 7      SAY cname
      @ 14,COL()+2 SAY "Invoice "+Pay->Invno  
      @ 16, 7      SAY "Issued "+DTOC( Pay->Cheqdate )
      @ 16,COL()+2 SAY "Presented "+DTOC( Pay->Presdate )
      @ 18, 7      SAY "Cheque # "+Pay->Cheqno
      @ 18,COL()+3 SAY "Amount"
      @ 18,COL()+1 SAY Pay->Amount
      nselect := 1
      DISPBOX( 20, 1, 24,79, 2 )
      @ 22,10      PROMPT "Edit Presented"
      @ 22,COL()+2 PROMPT "Edit Total"
      @ 22,COL()+2 PROMPT "Delete"
      @ 22,COL()+2 PROMPT "Exit File"
      MENU TO nselect
      DO CASE
         CASE PressedEsc()
            LOOP
         CASE nselect == 1
             ApRLock( 3 )
            SCROLL( 16, 5, 16,68 )
            @ 16, 7      SAY "Issued Date"   GET Pay->Cheqdate PICTURE "99/99/9999"
            @ 16,COL()+2 SAY "Presented"     GET Pay->Presdate PICTURE "99/99/9999"
            @ 16,COL()+2 SAY "Presented P/N" GET Pay->Recon;
                                VALID( Pay->Recon $ "PN" ) PICTURE "@!"
             READ
            UNLOCK
         CASE nselect == 2
            mcorrect := "N"
            DO WHILE mcorrect = "N"
               SCROLL(  10, 0, 24,80 )
               DISPBOX( 10, 1, 19,79, 2 )
               @ 11,15 SAY cname 
                ApRLock( 3 )
               @ 12, 8      SAY "       Code :"  GET Pay->Codeno   PICTURE "@!"
               @ 12,36      SAY "    Invoice :"  GET Pay->Invno    PICTURE "@X"
               @ 14, 8      SAY "Issued Date :"  GET Pay->Cheqdate PICTURE "99/99/9999"
               @ 14,COL()+2 SAY "Presented :"    GET Pay->Presdate PICTURE "99/99/9999"
               @ 16, 8      SAY "Cheque #"       GET Pay->Cheqno   PICTURE "@X"
               @ 16,COL()+2 SAY "Presented P/N"      GET Pay->Recon;
                                        VALID( Pay->Recon $ "PN" ) PICTURE "@!"
               @ 16,COL()+2 SAY "Cash Book No :" GET Pay->Cashno   PICTURE "@!"
                 READ
               UNLOCK 
               mcashno := Pay->Cashno
               SELECT Cashbook
               SEEK mcashno
               DO WHILE !FOUND()

                  Cblook( @mcashno )                       // XLF_Acc

               ENDDO                     // FOUND()
               SCROLL( 16, 6, 16,73 )
               @ 16,10 SAY "Cash Book # "+CashBook->Cashno+"  ";
                            +Cashbook->Cbname
               IF CashBook->GstAmnt > 0
                  @  16,COL()+4 SAY "GST %"
                  @  16,COL()+2 SAY CashBook->GSTAmnt PICTURE "9,999.99"
               ENDIF
               SELECT Pay
                ApRLock( 3 ) 
               Pay->Cashno := CashBook->Cashno
               @ 18,14 SAY "Amount" GET Pay->Amount PICTURE "9999999.99"
               @ 18,56 SAY Pay->Gstamnt             PICTURE "999,999.99"
                READ
               IF CashBook->GstAmnt > 0
                  Pay->Gstamnt := Pay->Amount-( Pay->Amount/((CashBook->GstAmnt/100)+1) )
               ELSE
                  @ 20,50 SAY Pay->Amount-( Pay->Amount/((CashBook->GstAmnt/100)+1) ) PICTURE "9,999.99"
                  Pay->Gstamnt := 0
               ENDIF
               @ 18,36 SAY "GST Amount" GET Pay->Gstamnt PICTURE "999999.99"
                 READ
               UNLOCK
               mcorrect := ApGetY( Message->Correct )
               IF LASTKEY() = 27
                  RETURN NIL
               ENDIF
            ENDDO
            LOOP      
    
        CASE nselect == 3
            mok := "N"
            cstring := TRIM( Message->Suredel )
             ApCheck( cstring )                        // AppX.PRG
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF mok == "Y"
               SELECT Pay
                ApRLock( 3 )  
               DELETE
               UNLOCK
            ENDIF                               // mok = "Y"
            LOOP
         CASE nselect == 4
            RETURN NIL
      ENDCASE
      mcontinue := "Y"
      ****   mcontinue := ApGetY( Message->Another+"Payment" )
   ENDDO                                     // mcontinue

   RETURN NIL

   ****-------------------------------------------------------------------------

FUNCTION AllPay()

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"

      SCROLL()
      DISPBOX(  0, 1, 2,79, 2 )
      @  1,40 -( LEN(cheading)/2 ) SAY cheading
      SCROLL(  3, 0, 24,80 )
      ntotal := 0
      aPart_ := {}
      SELECT Pay
      GOTO TOP
      IF LASTREC() != 0
         DO WHILE  Pay->( !EOF() )
            AADD( aPart_,DTOC( Pay->Cheqdate )+" "+Pay->Cheqno+"  "+Pay->Codeno;
               +"  "+STR( Pay->Amount );
               +" "+STR( Pay->Gstamnt )+"  "+Pay->Cashno;
               +"  "+Pay->Recon;
               +"  "+DTOC( Pay->PresDate );
               +"        "+STR( Recno() ) )
            SKIP ALIAS Pay
         ENDDO                               // Pay EOF()
         DISPBOX( 3, 0, 24,79, 2 )
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum   := ACHOICE( 4, 3,23,76, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         ELSE
            @ 14,20 SAY "--- No Payments this Month ---"
            WAIT
            RETURN NIL 
         ENDIF
      ENDIF
      SELECT Pay
      GOTO nrecno
      SELECT Name
      SEEK Pay->Codeno
       ApRLock( 3 )
      cname := SUBSTR( Name->Name,1,25 )
      UNLOCK
      SELECT Pay
      SCROLL(  12, 0, 24,80 )
      DISPBOX( 12, 0, 19,79, 2 )
      @ 14, 7      SAY cname
      @ 14,COL()+2 SAY "Invoice "+Pay->Invno  
      @ 16, 7      SAY "Issued "+DTOC( Pay->Cheqdate )
      @ 16,COL()+2 SAY "Presented "+DTOC( Pay->Presdate )
      @ 18, 7      SAY "Cheque # "+Pay->Cheqno
      @ 18,COL()+3 SAY "Amount"
      @ 18,COL()+1 SAY Pay->Amount
      nselect := 1
      DISPBOX( 20, 0, 24,79, 2 )
      @ 22,10      PROMPT "Edit Presented"
      @ 22,COL()+2 PROMPT "Edit Total"
      @ 22,COL()+2 PROMPT "Delete"
      @ 22,COL()+2 PROMPT "Exit File"
      MENU TO nselect
      DO CASE
         CASE PressedEsc()
            LOOP
         CASE nselect == 1
             ApRLock( 3 )
            SCROLL( 16, 5, 16,68 )
            @ 16, 7      SAY "Issued Date"   GET Pay->Cheqdate PICTURE "99/99/9999"
            @ 16,COL()+2 SAY "Presented"     GET Pay->Presdate PICTURE "99/99/9999"
            @ 16,COL()+2 SAY "Presented P/N" GET Pay->Recon;
                                VALID( Pay->Recon $ "PN" ) PICTURE "@!"
             READ
            UNLOCK

         CASE nselect == 2
            mcorrect := "N"
            DO WHILE mcorrect = "N"
               SCROLL(  10, 0, 24,80 )
               DISPBOX( 10, 0, 19,79, 2 )
               @ 11,15 SAY cname 
                ApRLock( 3 )
               @ 12, 8      SAY "       Code :"  GET Pay->Codeno   PICTURE "@!"
               @ 12,36      SAY "    Invoice :"  GET Pay->Invno    PICTURE "@X"
               @ 14, 8      SAY "Issued Date :"  GET Pay->Cheqdate PICTURE "99/99/9999"
               @ 14,COL()+2 SAY "Presented :"    GET Pay->Presdate PICTURE "99/99/9999"
               @ 16, 8      SAY "Cheque #"       GET Pay->Cheqno   PICTURE "@X"
               @ 16,COL()+2 SAY "Presented P/N"      GET Pay->Recon;
                                        VALID( Pay->Recon $ "PN" ) PICTURE "@!"
               @ 16,COL()+2 SAY "Cash Book No :" GET Pay->Cashno   PICTURE "@!"
                 READ
               UNLOCK 
               mcashno := Pay->Cashno
               SELECT Cashbook
               SEEK mcashno
               DO WHILE !FOUND()

                  Cblook( @mcashno )                       // XLF_Acc

               ENDDO                     // FOUND()
               SCROLL( 16, 6, 16,73 )
               @ 16,10 SAY "Cash Book # "+CashBook->Cashno+"  ";
                            +Cashbook->Cbname
               IF CashBook->GstAmnt > 0
                  @  16,COL()+4 SAY "GST"
               ENDIF
               SELECT Pay
                ApRLock( 3 ) 
               Pay->Cashno := CashBook->Cashno
               @ 18,14 SAY "Amount" GET Pay->Amount PICTURE "9999999.99"
               @ 18,56 SAY Pay->Gstamnt             PICTURE "999999.99"
                READ
               IF CashBook->GstAmnt > 0
                  Pay->Gstamnt := Pay->Amount-( Pay->Amount/((CashBook->GstAmnt/100)+1) )
               ELSE
                  Pay->Gstamnt := 0
               ENDIF
               @ 18,36 SAY "GST Amount" GET Pay->Gstamnt PICTURE "999999.99"
                 READ
               UNLOCK
               mcorrect := ApGetY( Message->Correct )
               IF LASTKEY() = 27
                  RETURN NIL
               ENDIF
            ENDDO
            LOOP      
    
         CASE nselect == 3
            mok := "N"
            cstring := TRIM( Message->Suredel )
             ApCheck( cstring )                        // AppX.PRG
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF mok == "Y"
               SELECT Pay
                ApRLock( 3 )  
               DELETE
               UNLOCK
            ENDIF                               // mok = "Y"
            LOOP
         CASE nselect == 4
            RETURN NIL
      ENDCASE
      mcontinue := "Y"
      ****   mcontinue := ApGetY( Message->Another+"Payment" )
   ENDDO                                     // mcontinue

   RETURN NIL

   ********   End of file AllPay

   ****----------------------------------------------------------------------

FUNCTION NamePay()

   mcontinue := mrepeat:= "Y"
   DO WHILE mcontinue = "Y"
      SCROLL()
      nl  := 1
      mok := "D"
      DISPBOX(  0, 5,  2,75, 2 )
      @  1,12 SAY Control->U_Name+"  Payment Listing "
      DISPBOX(  3, 5, 17,75, 2 )
     *** @  6,15 SAY "List By Cheque Number or Date (C/D) :";
    ***          GET mok PICTURE "@!" VALID(mok $ "CD")
      ***    READ
      IF mok = "C"
         SELECT Pay
         GOTO TOP
          ApFLock( 3 )
         INDEX ON Cheqno TO TempInd2
         SET INDEX TO TempInd2
         UNLOCK
       ELSE
         SELECT Pay
      ENDIF
      GOTO TOP
      mcodeno   := SPACE( 8 )
      mcheqdate := DATE()
      mcodelst  := "Y"
      mcodeind  := "Y"
      mtrue     := "T"
      mamount:= mgsttot:= mcodeamnt:= mgstamnt:= 0
      mselect   := "A"
      myy       := YEAR( DATE() )
      ***   myy       := SUBSTR(DTOC(DATE()),7,4)
      ***   @  8,19 SAY "All Cheques or Month only (A/M)";
      ***           GET mselect PICTURE "@!" VALID(mselect $ "AM")
      ***   @ 10,15 SAY "Select A if Cheques by one Name Required"
      ***    READ
      DO CASE
         CASE mselect ==  "A"
            @ 12,15 SAY "Year =" GET myy PICTURE "9999"
            @ 12,COL()+3 SAY "9999 for All - Must be Account YEAR"
             READ
      ***         mcodelst := ApGetN( "Do You Want List By Code No :" )
            mwhere   := "S"
            npl      := 54
            IF mcodelst == "Y"
               IF mrepeat == "Y"
                  mrepeat:= "N"
               ENDIF

               SELECT Pay
               GOTO TOP 
                ApFLock( 3 )  
               INDEX ON Codeno TO TempInd3                // Index by Name Codeno
               SET INDEX TO TempInd3
               UNLOCK
      ***            mcodeind := ApGetN( "One Customer Code Only :" )
              ELSE
               SELECT Pay
            ENDIF
            IF mcodeind == "Y"                           // Looking for Name

               Namerank()

               mcodeno := Name->Codeno
            ENDIF
      ***         mvalyy := VAL( myy )
            mok := "N"
      ***         mok := ApGetN( "One Cashcode Only" )
            IF mok == "Y"
               mcashno := SPACE(4)
               @ 14,15 SAY "Cash Book :" GET mcashno PICTURE "@!"
                READ
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               SELECT Cashbook
               SEEK mcashno
               DO WHILE !FOUND()

                  Cblook( @mcashno )                        // XLF_Cred.PRG

               ENDDO
               mcashno :=  CashBook->Cashno
            ENDIF                                          // mok

             Printsel()                                   // _LF_Init

            IF mwhere == "P"
               @  0, 0
               SET DEVICE TO PRINT
             ELSE
               SCROLL()
            ENDIF
            SELECT Pay
            mfirst := "T"
           IF mcodeind == "Y"
               SEEK mcodeno
           ENDIF

            PayHead()                        // ListPay

           DO WHILE Pay->( !EOF() )
              IF mok == "Y"
                 IF Pay->Cashno != mcashno
                    SKIP
                    LOOP
                 ENDIF
              ENDIF
              IF mcodeind == "Y"
                 IF Pay->Codeno != mcodeno
                    EXIT
                 ENDIF
              ENDIF
          DO CASE
             CASE  myy > YEAR( DATE() )+100
             CASE YEAR( Pay->Cheqdate ) < myy
               SKIP ALIAS Pay
               LOOP
             CASE YEAR( Pay->Cheqdate ) > myy+1
               SKIP ALIAS Pay
               LOOP
             CASE YEAR( Pay->Cheqdate ) > myy
                IF MONTH(Cheqdate) > 03
                  SKIP ALIAS Pay
                  LOOP
               ENDIF
             CASE MONTH( Pay->Cheqdate ) < 04
                SKIP ALIAS Pay
                LOOP
          ENDCASE
              IF nl > npl
                 IF mwhere = "P"
                    EJECT
                   ELSE
                    WAIT
                    SCROLL()
                 ENDIF

                  Payhead()                // Below

              ENDIF
              IF mcodeind == "Y"
                 mcodelst := "N"
              ENDIF
              mcodeno := Pay->Codeno
              mtrue := "T"
              IF mcodelst == "Y"
                 mtrue := "F"
                 IF Pay->Codeno != mcodeno
                    mcodeno := Pay->Codeno
                    mtrue   := "T"
                 ENDIF
                 IF mtrue == "T"
                    IF mfirst == "F"
                       nl++
                       @ nl,31 SAY "Code # Total = "
                       @ nl,COL()+2 SAY mcodeamnt PICTURE "$9,999,999.99"
                       nl+=2
                       mcodeamnt := 0
                    ENDIF
                 ENDIF
              ENDIF
              SELECT Name
              SEEK mcodeno
              SELECT Pay
              mcheqdate := Pay->Cheqdate
              mamount   := Pay->Amount +mamount
              mgsttot   := Pay->Gstamnt+mgsttot
              mcodeamnt := Pay->Amount +mcodeamnt
              IF mcodeind == "Y"
                 IF mfirst != "F"
                    mtrue := "T"
                    nl := 6
                 ENDIF
              ENDIF
              @ nl, 0 SAY Pay->Cheqno
              @ nl, 8 SAY Pay->Recon
              @ nl,10 SAY mcheqdate
              @ nl,21 SAY Pay->Invno
              @ nl,32 SAY SUBSTR( Name->Name,1,22 )
              mfirst := "F"
      ***           nl++
              @ nl,55 SAY Pay->Amount PICTURE "999,999.99"
              IF Gstamnt > 0
                 @ nl,65 SAY Pay->Gstamnt PICTURE "99,999.99"
                 mgstamnt := Pay->Amount+mgstamnt
              ENDIF
      ***           @ nl,58 SAY ( Pay->Amount-Pay->Gstamnt ) PICTURE "9,999,999.99"
              @ nl,75 SAY Pay->Cashno
              nl++
              SKIP ALIAS Pay
           ENDDO

      CASE mselect = "M"              // MONTH SELECTED
         @ 14,15 SAY "Please Provide Month & Year You are interested in"
         mmm := SUBSTR(DTOC(DATE()),4,2)
         @ 16,15 SAY "Select Month :" GET mmm PICTURE "99"

         myy := YEAR( DATE() )
         @ 16,COL()+2 SAY "Year :" GET myy PICTURE "9999"
          READ

         Printsel()                    // _LF_Init

         IF mwhere = "P"
            SET DEVICE TO PRINT
         ENDIF
         SELECT Pay
         GOTO TOP
         DO WHILE !EOF()
            IF SUBSTR( DTOC(Pay->Cheqdate),4,2) != mmm
               SKIP ALIAS Pay
               LOOP
            ENDIF
            IF YEAR( Pay->Cheqdate) != myy
               SKIP ALIAS Pay
               LOOP
            ENDIF
            IF nl > npl
               IF mwhere = "P"
                  EJECT
                 ELSE
                   WAIT
                  SCROLL()
               ENDIF

               Payhead()                       // Below

            ENDIF
            mcodeno := Pay->Codeno
            IF mcodeno != SPACE(8)
               SELECT Name
               SEEK mcodeno
               mname := SUBSTR( Name->Name,1,20 )
               SELECT Pay
              ELSE
                mname := SPACE( 20 )
            ENDIF
            mamount  := Pay->Amount  +mamount
            mgsttot  := Pay->Gstamnt +mgsttot
            @ nl, 0 SAY Pay->Cheqno
            @ nl, 8 SAY Pay->Recon
            @ nl,10 SAY Pay->Cheqdate
            @ nl,21 SAY Pay->Invno
            @ nl,32 SAY mname
            @ nl,53 SAY Pay->Amount PICTURE "999,999.99"
            IF Pay->Gstamnt > 0
               @ nl,65 SAY Pay->Gstamnt PICTURE "99,999.99"
               mgstamnt := Pay->Amount+mgstamnt
            ENDIF
      ***         @ nl,58 SAY (Pay->Amount-Pay->Gstamnt) PICTURE "9,999,999.99"
            @ nl,75 SAY Pay->Cashno
            nl++
            SKIP ALIAS Pay
         ENDDO
      ENDCASE
      IF mcodelst == "Y"
         IF mcodeamnt > 0
            nl++ 
            @ nl,20 SAY "Code # Total ="
            @ nl,COL()+2 SAY mcodeamnt PICTURE "$9,999,999.99"
            nl+=2
         ENDIF
      ENDIF
      nl++
      @ nl, 0 SAY "TOTALS"
      @ nl,25 SAY mamount PICTURE "$9,999,999.99"
      IF mgsttot > 0
         @ nl,40 SAY "GST"
         @ nl,44 SAY mgsttot PICTURE "$999,999.99"
      ENDIF
      @ nl,60 SAY (mamount-mgsttot) PICTURE "9,999,999.99"
      nl+=2
      @ nl, 0 SAY "G.S.T PURCHASES"
      @ nl,16 SAY mgstamnt PICTURE "$9,999,999.99"
      nl++
      @ nl, 0 SAY " "
      IF mwhere == "P"
         EndPrint()
         SET MARGIN TO 0
        ELSE
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
      ENDIF
      SCROLL()
      mcontinue := ApGetN( TRIM( Message->Another )+" Payment List" )
   ENDDO
   SELECT Pay
   SET INDEX TO PayInd

   RETURN NIL

   ********   End of file NamePay

   ******--------------------  END OF FILE PAYVIEW.PRG

