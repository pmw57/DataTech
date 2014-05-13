** JK 08-09-11 15:25:26 

/*  
   Program.....:                    PRESVIEW.PRG
   Authors.....: J Kirby
   Date........: 29/04/1998
   Function ...: ViewPres
*/

FUNCTION ViewPres()
   SCROLL()
   DISPBOX(  0, 1, 2,79, 2 )
   cheading := "Cheques NOT Presented"
   @  1,40 -( LEN(cheading)/2 ) SAY cheading
   nchoice := "C"
   nselect := 1
   DISPBOX( 10, 1, 15,79, 2 )
   @ 12,10 PROMPT "By Cheque Number"
   @ 13,10 PROMPT "By Name         "
   MENU TO nselect
   DO CASE
      CASE PressedEsc()
         SELECT Pay
         SET INDEX TO PayInd
         RETURN NIL
      CASE  nselect == 1
         nchoice := "C"
      CASE nselect == 2
         nchoice := "N"
   ENDCASE
   mcontinue := mok := "Y"
   DO WHILE mcontinue = "Y"
      SCROLL()
      DISPBOX(  0, 1, 2,79, 2 )
      @  1,40 -( LEN(cheading)/2 ) SAY cheading
      IF nchoice = "C"                 // By Cheque #
         ntotal := 0
         nrecno := 0
         aPart_ := {}
         SELECT Pay   
         INDEX ON Pay->Recon TO TempIndP
         SET INDEX TO TempIndP
         GOTO TOP
         SEEK "N"
         DO WHILE  Pay->Recon = "N" .AND. Pay->( !EOF() )
            SELECT Name
            SEEK Pay->Codeno
            SELECT Pay
            ntotal += Pay->Amount 
            AADD( aPart_,Pay->Cheqno+" "+STR( Pay->Amount );
                 +" "+SUBSTR( Name->Name,1,27 );
                 +" "+DTOC( Pay->Cheqdate )+" "+Pay->Invno;
                 +" "+Pay->Cashno+" "+Pay->Recon+"    "+STR( Recno() ) )
            SKIP ALIAS Pay
         ENDDO                               // Pay EOF()
      ENDIF
      IF nchoice = "N"                 // By Name
         ntotal := 0
         nrecno := 0
         aPart_ := {}
         SELECT Pay   
         INDEX ON Pay->Recon TO TempIndP
         SET INDEX TO TempIndP
         GOTO TOP
         SEEK "N"
         DO WHILE  Pay->Recon = "N" .AND. Pay->( !EOF() )
            SELECT Name
            SEEK Pay->Codeno
            SELECT Pay
            ntotal += Pay->Amount 
            AADD( aPart_,SUBSTR( Name->Name,1,27 );
                 +" "+Pay->Cheqno+" "+STR( Pay->Amount );
                 +" "+DTOC( Pay->Cheqdate )+" "+Pay->Invno;
                 +" "+Pay->Cashno+" "+Pay->Recon+"    "+STR( Recno() ) )
            SKIP ALIAS Pay
         ENDDO                               // Pay EOF()
      ENDIF                                // nchoice
      @  1,56 SAY ntotal PICTURE "$9,999,999.99"
      DISPBOX( 3, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum   := ACHOICE( 4, 3,23,77, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      ELSE
         @ 14,20 SAY "--- No Cheques Awaiting Presentation ---"
         WAIT
         RETURN NIL 
      ENDIF
      SELECT Pay
      GOTO nrecno
      SELECT Name
      SEEK Pay->Codeno
      SELECT Pay
      SCROLL(  11, 0, 19,80 )
      DISPBOX( 11, 1, 19,79, 2 )
      @ 12,10      SAY Name->Name
      @ 14,10      SAY "Invoice "       +Pay->Invno  
      @ 14,COL()+3 SAY "Cheque # "      +Pay->Cheqno
      @ 14,COL()+2 SAY "Presented  "    +Pay->Recon
      @ 16,10      SAY "Issued Date "   +DTOC( Pay->Cheqdate )
      @ 16,COL()+2 SAY "Presented Date "+DTOC( Pay->Presdate ) 
      nselect := 1
      SCROLL(  20, 0, 24,80 )
      DISPBOX( 20, 1, 24,79, 2 )
      @ 22, 8      PROMPT "Edit Cheque"
      @ 22,COL()+2 PROMPT "Edit Total"
      @ 22,COL()+2 PROMPT "Delete"
      @ 22,COL()+2 PROMPT "Print Credits"
      @ 22,COL()+2 PROMPT "Add Credit"
      MENU TO nselect
      DO CASE
         CASE PressedEsc()
            SELECT Pay
            SET INDEX TO PayInd
            RETURN NIL
         CASE nselect == 1                       // Presented
            SCROLL(  11, 0, 19,80 )
            DISPBOX( 11, 1, 19,79, 2 )
            @ 12,10      SAY Name->Name
            @ 14,10      SAY "Invoice "  +Pay->Invno  
            @ 14,COL()+2 SAY "Cheque # " +Pay->Cheqno
            SELECT Pay         
             ApRLock( 3 )
            @ 14,COL()+2 SAY "Presented P/N " GET Pay->Recon;
                              VALID( Pay->Recon $ "PN" ) PICTURE "@!"
            @ 16,10      SAY "Issued Date"
            @ 16,COL()+2 SAY DTOC( Pay->Cheqdate ) COLOR "GB+"
            @ 16,COL()+2 SAY "Presented Date"  GET Pay->Presdate PICTURE "99/99/9999" 
             READ
            UNLOCK
            dpresdate := Pay->PresDate
            crecon    := Pay->Recon
            mfind := DTOS( Pay->Cheqdate )+Pay->Cheqno
            SELECT Pay
            SET INDEX TO PayInd
            GOTO TOP
            SEEK mfind
            nfound := 1
            IF FOUND() 
                ApFLock( 3 )
               DO WHILE DTOS( Pay->Cheqdate )+Pay->Cheqno = mfind;
                        .AND. Pay->( !EOF() )
                  IF Pay->Recon = "N"
                     nfound++
                     Pay->Presdate := dpresdate
                     Pay->Recon    := crecon
                  ENDIF
                  SKIP ALIAS Pay
               ENDDO                       // mfind
               UNLOCK
               IF nfound > 1
                  @ 17,10 SAY "Client Same Cheque # "+STR( nfound-1, 4 )
                  INKEY( 1 )
               ENDIF 
            ENDIF                          // Found
            LOOP

         CASE nselect == 2              // Edit Pay
            mcorrect := "N"
            DO WHILE mcorrect = "N"
               SCROLL(   3, 0, 24,80 )
               DISPBOX(  3, 1, 19,79, 2 )
               @  5, 8      SAY Name->Name
               SELECT Pay 
                ApRLock( 3 )
               @ 10, 8      SAY "Code :"        GET Pay->Codeno   PICTURE "@!"
               @ 10,COL()+2 SAY "Invoice"       GET Pay->Invno    PICTURE "@X"
               @ 10,COL()+2 SAY "Cheque #"      GET Pay->Cheqno   PICTURE "@X"
               @ 12, 8      SAY "Issued Date"   GET Pay->Cheqdate PICTURE "99/99/9999"
               @ 12,COL()+2 SAY "Presented"     GET Pay->Presdate PICTURE "99/99/9999"
               @ 12,COL()+1 SAY "Presented P/N" GET Pay->Recon;
                                                VALID( Pay->Recon $ "PN" ) PICTURE "@!"
               @ 14, 8      SAY "Cash Book No"  GET Pay->Cashno   PICTURE "@!"
                 READ
               UNLOCK 
               mcashno := Pay->Cashno
               SELECT Cashbook
               SEEK mcashno
               DO WHILE !FOUND()

                  Cblook( @mcashno )                       // XLF_Acc

               ENDDO                     // FOUND()
               SCROLL( 14, 7,14,74 )
               @ 14, 8 SAY "Cash Book #  "+CashBook->Cashno+"  ";
                            +Cashbook->Cbname+"  "
               IF CashBook->GstAmnt > 0
                  @ 14,COL()+1 SAY "GST %"
                  @ 14,COL()+2 SAY CashBook->GstAmnt
               ENDIF
               SELECT Pay
                ApRLock( 3 ) 
               Pay->Cashno := CashBook->Cashno
               @ 16,15 SAY "Amount :" GET Pay->Amount PICTURE "9999999.99"
                READ
               IF CashBook->GstAmnt > 0
                  Pay->Gstamnt := Pay->Amount-( Pay->Amount/((CashBook->GstAmnt/100)+1) )
               ELSE
                  @ 18,50 SAY Pay->Amount-( Pay->Amount/( ( Cashbook->GstAmnt/100 )+1 ) )
                  Pay->Gstamnt := 0
               ENDIF
               @ 16,41 SAY "GST Amount :" GET Pay->Gstamnt PICTURE "999999.99"
                 READ
               UNLOCK
               mcorrect := ApGetY( Message->Correct )
               IF LASTKEY() = 27
                  RETURN NIL
               ENDIF
            ENDDO
            LOOP      

         CASE nselect == 3
            SCROLL(  12, 0, 24,80 )
            DISPBOX( 12, 1, 19,79, 2 )
            @ 13,10 SAY Name->Name
            @ 15,10 SAY "Invoice "+Pay->Invno
            @ 17,10 SAY DTOC( Pay->CheqDate )  
            @ 17,COL()+2 SAY "Cheque # "+Pay->Cheqno    
            cstring := TRIM( Message->Suredel )
            mok := ApCheck( cstring )                        // AppX.PRG
            IF PressedEsc()
               SELECT Pay
               SET INDEX TO PayInd 
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
            CredList()
            LOOP
         CASE nselect == 5
            CredAdd()
      ENDCASE
      mcontinue := "Y"

   ENDDO                                     // mcontinue

   RETURN NIL

   ******--------------------  END OF FILE PRESVIEW.PRG
