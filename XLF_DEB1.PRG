   *** JK 08-11-11 18:33:49 

/* 
   Program.....:            XLF_DEB1.PRG
   Author......: J Kirby
   Date........: 10/07/1985
   Functions.. : AdminName, DebProfhd, DebGet, Debt1
*/

FUNCTION AdminName()

   SELECT Admin
   GOTO TOP
    ApFLock( 3 )
   INDEX ON Codeno TO TempInd1
   SET INDEX TO TempInd1
   UNLOCK   

   SCROLL()
   cadminno := SPACE( 8 )
   nsel := 1
   DISPBOX( 8, 1, 14,40, 2 )
   @ 10, 8 PROMPT "Existing Record"
   @ 12, 8 PROMPT "Select by Name "
   MENU TO nsel
   DO CASE
      CASE PressedEsc()
         RETURN NIL
      CASE nsel == 1
         SCROLL()
         mcodeno := SPACE( 8 )
         nrecno  := 0
         aPart_  := {}
         SELECT Admin
         ****         SET ORDER TO 3     // Codeno
         GOTO TOP
         IF LASTREC() != 0
            DO WHILE Admin->( !EOF() )
               IF Admin->Codeno = mcodeno
                  SKIP ALIAS Admin
                  LOOP
               ENDIF
               SELECT Name
               SEEK Admin->Codeno
               SELECT Admin
               mcodeno := Admin->Codeno
               AADD( aPart_,Admin->Codeno+"   "+Name->Name;
                  +"              "+STR( RECNO(),6 ) )
               SKIP ALIAS Admin
            ENDDO                          // EOF()
            DISPBOX( 0, 1, 24,54, 2 )
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum   := ACHOICE( 1, 3, 23,52, aPart_,,"AFUNC" )    
               nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
               GOTO nrecno
               IF PressedEsc() 
                  RETURN NIL
               ENDIF
               mcodeno   := Admin->Codeno
               SELECT Name
               SEEK mcodeno
               mcodeno  := Name->Codeno
            ENDIF
         ENDIF                        // LastRec

      CASE nsel == 2     // By Name
         mcorrect := "N"
         DO WHILE mcorrect = "N"
            mcodeno := SPACE( 8 ) 
             NameRank( @mcodeno )
            mcodeno  := Name->Codeno
            SCROLL()
            @ 16,20 SAY Name->Name
            mcorrect := ApGetY( "Correct Name "+mcodeno )
         ENDDO
   ENDCASE
   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
    @ 1,20 SAY mcodeno+"  "+Name->Name
   SCROLL(  3, 0, 24,80 )
   DISPBOX( 3, 1, 18,79, 2 )
   dstmm  := DATE()-30
   dendmm := DATE()
   @  8,10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
   @ 10,10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
    READ
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
      @ 2, 4 SAY Name->Name
      @ 2,36 SAY "From " +DTOC( dstmm ) 
      @ 2,55 SAY "To "   +DTOC( dendmm )
      @ 3, 4 SAY Name->Add1
      nl := 4
   ELSE
      SCROLL()
      @ 1, 4      SAY TRIM( Name->Name ) 
      @ 1,COL()+3 SAY "From " +DTOC( dstmm ) 
      @ 1,COL()+2 SAY "To "   +DTOC( dendmm )
      nl := 2
   ENDIF
   @ nl, 0 SAY "Ref #"
   @ nl,11 SAY "Nrp"
   @ nl,20 SAY "Age"
   @ nl,24 SAY "Mth"
   @ nl,28 SAY "Sex"
   @ nl,34 SAY Message->Catno1    // "Diagnosis"
   @ nl,53 SAY Message->Catno2    // "Treatment"
   @ nl,70 SAY "Date"
   nl++
   ntotal:= ntotalcost := 0
   nmale:= nfemale:= nchild:= nbaby := 0
   SELECT Admin
   ***    SET ORDER TO 3                 // Codeno
   GOTO TOP
   SEEK mcodeno
   DO WHILE Admin->Codeno = mcodeno .AND. Admin->( !EOF() )
      ***   IF Admin->Codeno != mcodeno
      ***      SKIP ALIAS Admin
      ***      LOOP
      ***    ENDIF
      IF Admin->Date < dstmm
         SKIP ALIAS Admin
         LOOP
      ENDIF
      IF Admin->Date > dendmm
         SKIP ALIAS Admin
         LOOP
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
         @ nl, 0 SAY "Ref #"
         @ nl,11 SAY "Nrp"
         @ nl,20 SAY "Age"
         @ nl,24 SAY "Mth"
         @ nl,28 SAY "Sex"
         @ nl,34 SAY Message->Catno1      //  "Diagnosis"
         @ nl,53 SAY Message->Catno2      //  "Treatment"
         @ nl,70 SAY "Date"
         nl++
      ENDIF
      @ nl, 0 SAY Admin->Adminno
      ***      @ nl,10 SAY Admin->Abc
      ***      @ nl,10 SAY SUBSTR( Admin->Desc, 1,11 )
      @ nl,10 SAY Admin->Quoted PICTURE "R999,999"
      *** no space  for this Admin->Called
      IF Admin->Rate > 0
         @ nl,22 SAY Admin->Rate PICTURE "99"
      ENDIF 
      IF Admin->Accepted > 0
         @ nl,26 SAY Admin->Accepted PICTURE "99"
      ENDIF
      @ nl,29 SAY Admin->Sex
      @ nl,32 SAY Admin->Note
      @ nl,50 SAY Admin->Warranty
      @ nl,67 SAY DTOC( Admin->Date )
      nl++
      cdiag := Admin->Diag1+Admin->Diag2+Admin->Diag3
      IF cdiag != "     "
         @ nl,32 SAY Admin->Diag1+" "+Admin->Diag2;
                     +" "+SUBSTR( Admin->Diag3, 1,13 )
         nl++
      ENDIF   
      ctreat := Admin->Diag4+Admin->Treat1+Admin->Treat2
      IF ctreat != "     "
         @ nl,32 SAY Admin->Diag4+" "+Admin->Treat1;
                    +" "+SUBSTR( Admin->Treat2, 1,13 )
         nl++
      ENDIF 
      ctreat1 := Admin->Treat3+Admin->Treat4
      IF ctreat != "     "
         @ nl,32 SAY Admin->Treat3+" "+Admin->Treat4
         nl++
      ENDIF 
      IF Admin->Name != "        "
         @ nl,16 SAY Admin->Name
         nl++
      ENDIF 
      IF Admin->Sex = "M"
         nmale++
      ENDIF
      IF Admin->Sex = "F"
         nfemale++
      ENDIF
      IF Admin->Rate > 0 .AND. Admin->Rate < 12
         nchild++
      ENDIF
      IF Admin->Accepted > 0
         nbaby++
      ENDIF
      ntotal++
      ntotalcost += Admin->Quoted
      SKIP ALIAS Admin
   ENDDO                      // Admin       
   nl++
   @ nl, 0 SAY mcodeno+" Appointments"
   @ nl,23 SAY ntotal PICTURE "99,999" 
   @ nl,30 SAY "From " +DTOC( dstmm ) 
   @ nl,47 SAY "To "   +DTOC( dendmm )
   @ nl,62 SAY "Cost"
   @ nl,67 SAY ntotalcost PICTURE "R9,999,999"  
   nl+=2
   IF mwhere = "P"
      @ nl, 10 SAY Message->Catno1+"             "+Message->Catno2+"                  Date"
      nl++ 
      npl := nl
      nline = 1
      FOR nline = 1 TO ( 60-npl )           // Was 63
      @ nl, 0 SAY "____________________________|______________________________________|________"
         nl+=2
         IF nl >60
            EXIT
         ENDIF
         npl++ 
      NEXT
   ENDIF 
   IF mwhere == "S"
      WAIT
      mwhere := "N" 
   ELSE
      EndPrint()
      SET MARGIN TO 0
   ENDIF
   SELECT Admin
   SET INDEX TO AdminInd

   RETURN NIL
   ***----- End of AdminName()

   *****------------------------------------------------------------------------

FUNCTION DebProfhd()

   @  0, 0 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
   nl := 1
   IF mselect = "Y"
      @ nl,20 SAY Name->Name
      nl++ 
   ENDIF
   @  nl, 5 SAY "From Date"
   @  nl,16 SAY mstmm
   @  nl,30 SAY "Including Date TO"
   @  nl,50 SAY mendmm
   nl++
   @  nl,21 SAY "Sales Less GST"
   @  nl,43 SAY "Cost"
   @  nl,56 SAY "Margin"
   nl++

   RETURN nl

   ***----- End of DebProfhd()

   *****------------------------------------------------------------------------

FUNCTION DebGet( msaleno )

   SCROLL(  3, 0, 24,80 )
   DISPBOX( 3, 1, 20,79, 2 ) 
   nl := 4
   SELECT Debit
   ApRLock( 3 ) 
   ***         @ nl, 6      SAY "Client O/N"  GET Debit->Ordnum    PICTURE "@X"
   ***         @ nl,COL()+1 SAY "Equip"       GET Debit->Equip     PICTURE "@!"
   ***         @ nl,COL()+1 SAY "Tech"        GET Debit->Tech      PICTURE "@!"
         @ nl,COL()+1 SAY "Client"      GET Debit->U_Codeno  PICTURE "@!"   
   ***         nl+=2
   ***         @ nl, 6      SAY "Desc "       GET Debit->Brand    PICTURE "@X"
   ***         @ nl,COL()+2 SAY "Contacted"   GET Debit->Head     PICTURE "@!"
   @ nl,COL()+2 SAY "I=Inv W=W/B J=Job"  GET Debit->Stat;
                           VALID( Debit->Stat $ "IWJ" ) PICTURE "@!"
   nl++
   @ nl, 6      SAY "Detail   "   GET Debit->Fault    PICTURE "@X"
   nl++
   @ nl, 6      SAY "Quot Info"   GET Debit->Est      PICTURE "@X"
   nl+=2
   @ nl, 6      SAY "Invoice :"    GET Debit->Invno    PICTURE "@X"
   @ nl,COL()+2 SAY "Dated"        GET Debit->Dbdate   PICTURE "99/99/9999"
   ***         @ nl,COL()+2 SAY "Beware Files not updated"
   nl+=2
   @ nl, 6      SAY "Cost Amnt"    GET Debit->CostItem PICTURE "9999999.99"
   @ nl,COL()+2 SAY "Initial Amnt" GET Debit->InitAmnt PICTURE "99999999.99"
   nl+=2
   @ nl, 6      SAY "Pay Type  "   GET Debit->PayType  PICTURE "@K!"
   @ nl,COL()+2 SAY "Blank To Select"
   READ
   ***         IF Debit->Amount = 0
   ***            Debit->Amount := Debit->InitAmnt
   ***         ENDIF
   UNLOCK
   IF EMPTY( Debit->PayType )
      mchoice := 1
      @ 14,34 PROMPT Message->PayType1
      @ 15,34 PROMPT Message->PayType2
      @ 16,34 PROMPT Message->PayType3
      @ 17,34 PROMPT Message->PayType4
      @ 18,34 PROMPT Message->PayType5
      @ 19,34 PROMPT Message->PayType6
      MENU TO mchoice
       ApRLock( 3 )
      DO CASE
         CASE mchoice == 1
            Debit->PayType := SUBSTR( Message->PayType1,1,2 )
         CASE mchoice == 2
            Debit->PayType := SUBSTR( Message->PayType2,1,2 )
         CASE mchoice == 3
            Debit->PayType := SUBSTR( Message->PayType3,1,2 )
         CASE mchoice == 4
            Debit->PayType := SUBSTR( Message->PayType4,1,2 )
         CASE mchoice == 5
            Debit->PayType := SUBSTR( Message->PayType5,1,2 )
         CASE mchoice == 6
            Debit->PayType := SUBSTR( Message->PayType6,1,2 )
      ENDCASE
      UNLOCK 
   ENDIF
   SCROLL( nl, 4, 19,77 )
   @ nl,10 SAY "Pay Type    "+Debit->PayType
   IF Debit->PayType = "CT"
      SELECT Name
      SEEK Debit->U_Codeno
      ApRLock( 3 )
      nl+=2
      @ nl, 8      SAY "Charge Through :" GET Name->Charge PICTURE "@K!"
      @ nl,COL()+2 SAY "Blank to Select" 
      @ nl+2, 8 SAY "Name  Charge "+Name->Charge
      @ nl+3, 8 SAY "Debit Charge "+Debit->Codeno
      @ nl+4, 8 SAY "Debit Orig   "+Debit->U_Codeno      
      READ
      IF EMPTY( Name->Charge )
         mchoice := 1
         SCROLL( nl, 7, nl,74 )  
         @ 12,50 PROMPT Message->Charge1
         @ 13,50 PROMPT Message->Charge2
         @ 14,50 PROMPT Message->Charge3
         @ 15,50 PROMPT Message->Charge4
         @ 16,50 PROMPT Message->Charge5
         MENU TO mchoice
         DO CASE
            CASE mchoice == 1
               Name->Charge := SUBSTR( Message->Charge1,1,8 )
            CASE mchoice == 2
               Name->Charge := SUBSTR( Message->Charge2,1,8 )
            CASE mchoice == 3
               Name->Charge := SUBSTR( Message->Charge3,1,8 )
            CASE mchoice == 4
               Name->Charge := SUBSTR( Message->Charge4,1,8 )
            CASE mchoice == 5
               Name->Charge := SUBSTR( Message->Charge5,1,8 )
         ENDCASE
         UNLOCK 
      ENDIF         // Empty Charge
      SELECT Name
      ApRLock( 3 )
      SCROLL( 12, 8, 17,74 )
      @ nl, 8 SAY "Charge Through "+Name->Charge+"     "
      @ nl,COL()+2 SAY "Account #" GET Name->PayRef PICTURE "@X" 
      READ
      UNLOCK
      SELECT Debit
      SCROLL( 12, 8, 17,74 )
      ApRLock( 3 )
      Debit->Codeno := Name->Charge
      UNLOCK
      nl := 11
      @ nl,10 SAY "   Charge  "+Debit->Codeno+"  "+Debit->Paytype;
                  +"  "+Name->PayRef
   ENDIF    // CT
   nl+=2
   @ nl, 8 SAY " Sale Ref :" GET msaleno         PICTURE "@K!"
   @ nl,COL()+2 SAY "Blank to Select"
   READ
   IF PressedEsc()
      RETURN NIL
   ENDIF
   SELECT SaleBook
   GOTO TOP
   SEEK msaleno
   IF !FOUND()
      Sblook( @msaleno )
   ENDIF
   msaleno := SaleBook->Saleno
   @ nl, 8 SAY "   Sale Ref "+SaleBook->Saleno+"   "+SaleBook->Sbname
   IF SaleBook->GstAmnt > 0
      @ nl,COL()+2 SAY "GST %"
      @ nl,COL()+2 SAY SaleBook->GSTAmnt
   ENDIF
   nl+=2
   SELECT Debit
    ApRLock( 3 )
   @ nl,11 SAY "Amount :" GET Debit->Amount PICTURE "9999999.99"
    READ
   IF SaleBook->GstAmnt > 0
      Debit->Tax := Debit->Amount-(Debit->Amount/((SaleBook->GstAmnt/100)+1))
    ELSE
      Debit->Tax := 0
   ENDIF
   @ nl,34 SAY "Check  G.S.T Amount" GET Debit->Tax PICTURE "999999.99"
   IF SaleBook->GstAmnt = 0
      nl+=2
      @ nl,19 SAY Debit->Amount-(Debit->Amount/((Control->GstRate/100)+1));
                   PICTURE "9,999,999.99"
      @ nl,36 SAY "No GST This Code"
   ENDIF
   READ
   Debit->Saleno   := msaleno
   ***         Debit->InitAmnt := Debit->Amount
   ***         Debit->Printed  := "N"
   UNLOCK
   SELECT DebProf
   SET ORDER TO 2                // Invno
   SEEK Debit->Invno
    ApRLock( 3 )
   IF !FOUND()
      APPEND BLANK
   ENDIF
   DebProf->Codeno   := Debit->Codeno
   DebProf->DbDate   := Debit->DbDate
   DebProf->Saleno   := Debit->Saleno
   DebProf->PayType  := Debit->PayType
   DebProf->U_Codeno := Debit->U_Codeno
   DebProf->Invno    := Debit->Invno
   DebProf->Amount   := Debit->Amount
   DebProf->CostItem := Debit->CostItem
   DebProf->GSTAmnt  := Debit->Tax
   DebProf->Tech     := Debit->Tech
   DebProf->Est      := Debit->Est
   UNLOCK
   SELECT Debit
   SET ORDER TO 1

   RETURN NIL
   **** End of DebGet()

   **-------------------------------------------------------------------

FUNCTION Debt1( mcodeno )
   SCROLL() 
   mwhere := "S"

    Printsel( mwhere )

   SELECT Name
   SEEK mcodeno                      // Customers Name
   IF mwhere = "S"
     nl  := 1
     npl := 18
    ELSE
     nl  := 13
     npl := 54
   ENDIF
   @ nl, 4 SAY Name->Name               // This is Company Name
   ***      @ nl, 4 SAY TRIM(Name->Title)+" "+TRIM(Name->Called)+" "+Name->Famname
   nl++
   @ nl, 4 SAY Name->Add1
   nl++
   IF Name->Add2 != SPACE(27)
      @ nl, 4 SAY Name->Add2
      nl++
   ENDIF
   IF Name->Add3 != SPACE(27)
      @ nl, 4 SAY Name->Add3
      nl++
   ENDIF
   IF Name->Add4 != SPACE(27)
      @ nl, 4 SAY TRIM( Name->Add4 )+"  "+Name->Zip
      nl++
   ENDIF
   @ nl, 4 SAY TRIM(Name->Add5)
   nl+=2
   IF Name->Ephone != SPACE(15)
      @ nl, 4 SAY "Priv Ph : "+Name->Ephone           // Home     Phone
      nl+=2
   ENDIF
   IF Name->Phone != SPACE(15)
      @ nl, 4 SAY "  Phone : "+Name->Phone             // Business Phone
   ENDIF

   SET MARGIN TO 7
   nl+=2
   @ nl, 0 SAY DATE()
   nl++
   @ nl, 28 SAY "OVERDUE NOTICE"
   nl+=2
   @ nl, 0 SAY "The below shows the Invoices and amounts overdue for payment."
   ntotal:= 0
   nl+=2
   SELECT Debit
   SEEK mcodeno
   DO WHILE Debit->Codeno == mcodeno .AND. !EOF()
         IF nl > npl
            IF mwhere = "S"
              WAIT
              SCROLL()
              nl := 2
            ELSE
              EJECT
              nl := 0
            ENDIF
         ENDIF
      IF Debit->Amount == 0
         SKIP ALIAS Debit
         LOOP
      ENDIF
      IF MONTH( Debit->Dbdate ) == ( MONTH(DATE())-1 );
         .AND. YEAR( Debit->Dbdate ) == ( YEAR(DATE()) )
         SKIP ALIAS Debit
         LOOP
      ENDIF
      IF MONTH( Debit->Dbdate ) == ( MONTH(DATE()) );
        .AND. YEAR( Debit->Dbdate ) == ( YEAR(DATE()) )
         SKIP ALIAS Debit
         LOOP
      ENDIF
      @ nl, 3 SAY Debit->Dbdate
      @ nl,14 SAY "Invoice"
      @ nl,23 SAY Debit->Invno
      @ nl,31 SAY Debit->Amount PICTURE "$999,999.99"
      nl++
      ntotal += Debit->Amount
      SKIP ALIAS Debit
   ENDDO
   nl++
   @ nl,34 SAY "Total ="
   @ nl,42 SAY ntotal PICTURE "$99,999.99"
   nl+=3
   @ nl, 0 SAY "Should there be an error requiring our attention, kindly advise"
   nl++
   @ nl, 0 SAY "us at the above address as soon as possible"
   nl+=2
   @ nl, 0 SAY "If however, the accounts are in order, payment should have been"
   nl++
   @ nl, 0 SAY "made by the 20th of the month following delivery and therefore"
   nl++
   @ nl, 0 SAY "your early settlement of the account would be appreciated."
   nl+=2
   @ nl, 0 SAY "If you have already forwarded your remittance, please disregard"
   nl++
   @ nl, 0 SAY "this notice."
   nl+=3
   @ nl, 0 SAY "Yours faithfully"
   nl++
   @ nl, 0 SAY ""
   IF mwhere = "P" 
      EndPrint()
      SET MARGIN TO 0
     ELSE
      WAIT 
   ENDIF

   RETURN NIL
   ***** End of Debt1()

   ******------------------- END OF FILE XLF_DEB1.PRG
