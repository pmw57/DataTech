   *** JK 04-05-11 08:10:07 

/* Program.....:            DEBPAY.PRG
   Authors.....: J.Kirby
   Date........: 04/12/1996
   Functions...: DebProf, DebTech, DebCost, DebPayRep
   Static Funcs: Debcosthd, DebProfH, RepDebPay
*/

// (c) Copyright 1993 by Elcom Ltd & John Kirby Christchurch.

FUNCTION DebProf()

   SCROLL()
   DISPBOX( 0, 1,14,79, 2 )
   @  1,20 SAY "LIST PROFIT"
   SELECT DebProf
   GOTO TOP
    ApFLock( 3 )
   INDEX ON Saleno+DTOS( DebProf->Dbdate )+DebProf->Invno TO TempInd1
   SET INDEX TO TempInd1
   UNLOCK   
   msaleno := "XXXX"
   @  6,10 SAY Message->Blank GET msaleno PICTURE "@K!"
    READ
   IF msaleno != SPACE( 4 )
      SELECT Salebook
      SEEK msaleno
      IF !FOUND()

          Sblook( @msaleno )                      // XLP_Acc.PRG

      ENDIF
      msaleno := Salebook->Saleno
      @  8,10 SAY "Sale Book # "+SaleBook->Saleno+"  "+Salebook->Sbname
   ENDIF
   mstmm  := DATE()-30
   mendmm := DATE()
   @ 10, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
   @ 11, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
    READ
   IF PressedEsc()
      RETURN NIL
   ENDIF
   mwhere   := "S"

     Printsel( mwhere )

   nl := 0
   IF mwhere == "P"
      npl := 55
    ELSE
      SCROLL()
      npl := 22
   ENDIF

    DebProfH()                          // Below

   IF msaleno = SPACE( 4 )
      csale  := DebProf->Saleno
     ELSE
      csale  := msaleno
   ENDIF
   mamount:= ncostitem:= nsale:= ncost:= 0
   SELECT DebProf
   GOTO TOP
   DO WHILE DebProf->( !EOF() )
      IF DebProf->DbDate < mstmm
         SKIP ALIAS DebProf
         LOOP
      ENDIF
      IF DebProf->DbDate > mendmm
         SKIP ALIAS DebProf
         LOOP
      ENDIF
      IF msaleno != SPACE( 4 )
         IF DebProf->Saleno != msaleno
            SKIP ALIAS DebProf
            LOOP
         ENDIF
      ENDIF
      IF DebProf->Amount == 0
         SKIP ALIAS DebProf
         LOOP
      ENDIF
      IF nl > npl
         IF mwhere == "P"
             EJECT
           ELSE
             WAIT
             SCROLL()
         ENDIF                       // mwhere = P

            DebProfH()                          // Below

      ENDIF                          // nl>npl
      SELECT Name
      SEEK DebProf->Codeno
      mname := SPACE( 28 )
      IF FOUND()
         mname := SUBSTR( Name->Name,1,21 )
       ELSE
         mname := DebProf->Codeno
      ENDIF                                 // FOUND()
      IF DebProf->Saleno != csale
      ***      IF nsale > 0
            @ nl,45 SAY "-------------------------"
            nl++
            @ nl,18 SAY csale
            @ nl,43 SAY nsale PICTURE "$999,999.99"
            @ nl,57 SAY ncost PICTURE "$999,999.99"
            @ nl,71 SAY ( ( nsale-ncost )/nsale ) * 100 PICTURE "9999 %" 
            nl++
            @ nl,45 SAY "============================"
            nl++
      ***      ENDIF
         nsale := ncost:= 0
         csale := DebProf->Saleno
      ENDIF                                    //csale
      IF DebProf->Codeno != Debprof->U_Codeno
         nl++ 
         SELECT Name
         SEEK DebProf->U_codeno
         @ nl,16 SAY SUBSTR( Name->Name,1,16 )
         nl++
      ENDIF                                    // U_Codeno 
      IF DebProf->Amount > 0
         @ nl, 0 SAY DebProf->Invno
         @ nl, 7 SAY DebProf->PayType
         @ nl,10 SAY DebProf->Dbdate
         @ nl,21 SAY mname
         @ nl,43 SAY DebProf->Amount-DebProf->GSTAmnt PICTURE "$999,999.99"
         @ nl,57 SAY DebProf->CostItem  PICTURE "$999,999.99"
         @ nl,68 SAY ( ( DebProf->Amount-DebProf->GSTAmnt )-DebProf->CostItem)/( DebProf->Amount ) *100 PICTURE "9999 %"
         @ nl,76 SAY DebProf->Saleno
      ENDIF                                    // Debprof > 0
      mamount   += DebProf->Amount-DebProf->GSTAmnt
      ncostitem += DebProf->CostItem
      nsale     += DebProf->Amount-DebProf->GSTAmnt
      ncost     += DebProf->CostItem
      nl++
      SELECT DebProf
      SKIP ALIAS DebProf
   ENDDO                                       // DebProf EOF()

   @ nl,45 SAY "-------------------------"
   IF msaleno == SPACE( 4 )
      nl++
      @ nl,20 SAY csale
      @ nl,43 SAY nsale PICTURE "$999,999.99"
      @ nl,57 SAY ncost PICTURE "$999,999.99"
      @ nl,72 SAY ( ( nsale-ncost )/nsale ) * 100 PICTURE "9999 %" 
      nl++
      @  nl,45 SAY "--------------------------"
   ENDIF
   IF mwhere = "S"
      IF nl > 18
         @ 23,10 SAY Message->Anykey
         INKEY( 0 )
         SCROLL()
         nl := 10
      ENDIF
   ENDIF
   nl++
   @ nl,28 SAY "GRAND TOTALS"
   @ nl,41 SAY mamount   PICTURE "$9,999,999.99"
   @ nl,55 SAY ncostitem PICTURE "$9,999,999.99"
   @ nl,72 SAY ( ( mamount-ncostitem )/mamount )*100 PICTURE "9999 %" 
   nl++
   @ nl,45 SAY "============================"
   nl++
      *** @ nl,12 SAY "Amount Includes GST Cost less GST BEWARE "
   nl++
      *** mamount := mamount-( mamount*( 15/100 ) )
      *** @ nl,72 SAY ( ( mamount-ncostitem )/mamount )*100 PICTURE "9999 %" 
   nl++
   @ nl,12 SAY "Sale-Cost less GST "
   @ nl,34 SAY mamount-ncostitem PICTURE "9999,999.99" 
   nl++
   nl++
   IF mwhere = "P"
      EndPrint()
      SET MARGIN TO 0
     ELSE
      WAIT
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF
   SELECT DebProf
   SET INDEX TO DebProfI

   RETURN NIL

   ******* End of DebProf()

   ***------------------------------------------------------------------------

FUNCTION DebTech()

   SCROLL()
   DISPBOX( 0, 1,14,79, 2 )
   @  1,20 SAY "LIST INVOICES BY Invoice #"
   mstmm  := DATE()-30
   mendmm := DATE()
   @ 10, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
   @ 11, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
    READ

   IF PressedEsc()
      RETURN NIL
   ENDIF
   mwhere := "S"

     Printsel( mwhere )

   IF mwhere == "P"
      npl := 54
    ELSE
      npl := 23
   ENDIF
   @  0, 0 SAY Control->U_Name
   @  0,34 SAY mstmm 
   @  0,47 SAY mendmm 
   @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
   @  2, 0 SAY "Inv #"
   @  2,10 SAY "Date"
   @  2,21 SAY "Name"
   @  2,55 SAY "Amount+GST"
   @  2,74 SAY "Sale"
   nl := 4
   nsale:= nsaletot := 0
   SELECT DebProf
   SET ORDER TO 2                    // Invno
   GOTO TOP
   DO WHILE DebProf->( !EOF() )
      IF DebProf->DbDate < mstmm
         SKIP ALIAS DebProf
         LOOP
      ENDIF
      IF DebProf->DbDate > mendmm
         SKIP ALIAS DebProf
         LOOP
      ENDIF
      IF nl > npl
         IF mwhere == "P"
             EJECT
           ELSE
             WAIT
             SCROLL()
         ENDIF                       // mwhere = P
         @  0, 0 SAY Control->U_Name
         @  0,34 SAY mstmm 
         @  0,47 SAY mendmm 
         @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         @  2, 0 SAY "Inv #"
         @  2,10 SAY "Date"
         @  2,21 SAY "Name"
         @  2,57 SAY "Amount+GST"
         @  2,74 SAY "Sale"
         nl := 4
      ENDIF                          // nl>npl
      SELECT Name
      SEEK DebProf->Codeno
      mname := SPACE( 30 )
      IF FOUND()
         mname := Name->Name
       ELSE
         mname := DebProf->Codeno
      ENDIF                                 // FOUND()
         @ nl, 0 SAY DebProf->Invno
         @ nl, 7 SAY DebProf->PayType
         @ nl,10 SAY DebProf->Dbdate
         @ nl,24 SAY mname
         @ nl,58 SAY DebProf->Amount PICTURE "9,999,999.99"
         @ nl,75 SAY DebProf->Saleno
         nl++
         nsaletot += DebProf->Amount
      SKIP ALIAS DebProf
   ENDDO
   IF mwhere = "S"
      IF nl > 18
         @ 22, 10 SAY Message->AnyKey
         INKEY( 0 )
         SCROLL()
         nl := 10
      ENDIF
   ENDIF
   @ nl,55 SAY "-----------------"
   nl++
   @ nl,42 SAY "TOTAL Incl GST"
   @ nl,57 SAY nsaletot PICTURE "$9,999,999.99"
   nl++
   @ nl,55 SAY "================="
   nl++
   IF mwhere = "P"
      EndPrint()
     ELSE
      WAIT
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF

   SELECT DebProf
   SET ORDER TO 1

   RETURN NIL

   ****---- End of DebTech()

   ***--------------------------------------------------------------------------

FUNCTION DebCost()

   cheading  := "View  Existing  Debit Profile"
   mcontinue:= mdelete:= mok := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL()
      namount:= ncostitem := 0
      @  8,15 SAY cheading
      dmm := SUBSTR( DTOS( DATE()),5,2 )
      dyy := SUBSTR( DTOS( DATE()),1,4 )
      @ 10,20 SAY "Select Month :" GET dmm PICTURE "99"
      @ 10,COL()+3 SAY "Year :" GET dyy PICTURE "9999"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      dyymm  := dyy+dmm
      mcodeno := SPACE( 8 )
      minvno  := SPACE( 6 )
      nrecno := 0
      aPart_ := {}
      SELECT DebProf
      IF LASTREC() != 0
         GOTO TOP
         DO WHILE DebProf->( !EOF() )
            IF SUBSTR( DTOS( DebProf->DbDate ), 1, 6 ) != dyymm
               SKIP ALIAS DebProf
               LOOP
            ENDIF
            IF DebProf->CostItem > DebProf->Amount
                ApRLock( 3 )
               DebProf->CostItem := DebProf->Amount
               UNLOCK  
            ENDIF 
            SELECT Name
            SEEK DebProf->Codeno
            SELECT DebProf
            namount += DebProf->Amount
            AADD( aPart_,DebProf->Invno;
               +" "+DTOC( DebProf->DbDate );
               +" "+SUBSTR( Name->Name, 1,30 );
               +" "+STR( DebProf->Amount,10, 2 );
               +" "+STR( DebProf->CostItem,10, 2 );
               +" "+Saleno;
               +"                 "+STR( RECNO() ) )
            SKIP ALIAS DebProf
         ENDDO
         SCROLL()
         DISPBOX( 0, 1, 24,79, 2 )
         @  0, 9 SAY "   Total                 "
         @  0,19 SAY namount PICTURE "$999,999.99" COLOR "G+"
         @  0,49 SAY "   Amount+GST    Cost-GST  "
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum   := ACHOICE( 1, 3, 23,78, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
          ELSE
            @ 14,20 SAY "--- No Debit Profile This Month ---"
            WAIT
            LOOP
         ENDIF
      ENDIF
      SELECT Name
         SEEK DebProf->Codeno
         SCROLL()
         DISPBOX(  0, 1, 2,79, 2 )
         @  1, 6 SAY Name->Name
         minvno  := DebProf->Invno
         msaleno := DebProf->Saleno
         nselect := 2
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 1, 6,79, 2 )
         @  4, 4      SAY DebProf->Invno COLOR "G+"
         @  4,COL()+2 SAY DebProf->DbDate
         @  4,COL()+2 SAY "Total"
         @  4,COL()+2 SAY DebProf->Amount PICTURE "99,999.99" COLOR "G+"
         SELECT Debit
         LOCATE FOR Debit->Invno = DebProf->Invno
         IF FOUND()
            @  4,45      SAY "Outstanding Amount"
            @  4,COL()+1 SAY Debit->Amount  COLOR "G+"
         ENDIF      
      SELECT Rec
      SET ORDER TO 1
      IF LASTREC() != 0
         GOTO TOP
         SEEK DebProf->Codeno
         aPart_   := {}
         nRecamnt := 0
         DO WHILE Rec->Codeno = DebProf->Codeno .AND. Rec->( !EOF() )
            IF Rec->Invno != DebProf->Invno
               SKIP ALIAS Rec
               LOOP
            ENDIF
            SELECT Deposit
            cdeprev := SPACE( 20 )
            LOCATE FOR Deposit->DepRef = Rec->Recno
            IF FOUND()
              IF Rec->Recno != SPACE( 12 ) 
                  cdeprev := " Deposit "+DTOC( Deposit->Depdate )
              ENDIF 
            ENDIF
            SELECT Rec
            nRecamnt += Rec->Recamnt 
            AADD( aPart_,Rec->Invno+" "+DTOC( Rec->RecDate );
               +" "+STR( Rec->Recamnt, 9, 2 );
               +" "+Rec->Jobno;
               +" "+STR( nRecamnt, 9, 2 );
               +" "+Rec->Recno+" "+cdeprev )
            SKIP ALIAS Rec
         ENDDO
         IF !EMPTY( aPart_ )
            SCROLL(   8, 0, 24,80 )
            DISPBOX(  8, 1, 19,79, 2 )
            @  8,25 SAY "   RECEIPTS FOR INVNO "+DebProf->Invno+"   " COLOR "G+"
            ***         ASORT(aPart_,,,{ | x,y | x < y })
            AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " );
               ,QQOUT(A),BreakTot() } )
         ENDIF
      ENDIF
      nselect := 1     
      DISPBOX( 20, 1, 24,79, 2 )
      @ 22,15      PROMPT "Edit"
      @ 22,COL()+3 PROMPT "List/Print"
      @ 22,COL()+3 PROMPT "Add New"
      @ 22,COL()+3 PROMPT "Delete"
      @ 22,COL()+3 PROMPT "Another"
      MENU TO nselect
      DO CASE
         CASE PressedEsc()
            RETURN NIL
         CASE nselect == 1
            SCROLL( 3, 0, 24,80 )
            msaleno := DebProf->Saleno 
             DebProfLk( msaleno )                    //
            manother  := "Y" 
            mcontinue := "Y"
             LOOP
         CASE nselect == 2
            ***   SCROLL()
            mwhere := "S"

            Printsel( mwhere )

            IF mwhere = "P"
               npl := 54
               nl  := 0                  // 14 Used to print in Van
            ELSE
               nl  := 0
               npl := 22
            ENDIF
            SCROLL() 

            DebCostHd()                           // Below
            
            mpageno = 1
            SELECT DebProf
            SET ORDER TO 2                   // Invno
            GOTO TOP
            namount:= ncostitem := 0
            DO WHILE DebProf->( !EOF() )
               IF SUBSTR( DTOS( DebProf->DbDate ), 1, 6 ) != dyymm
                  SKIP ALIAS DebProf
                  LOOP
               ENDIF
               IF nl > npl
                  mpageno := mpageno+1
                  nl++
                  @ nl, 4 SAY "Report is Continued on Next Page"
                  IF mwhere == "P"
                     EndPrint()
                     SCROLL( 3, 0, 24,75 )
                     @ 12, 0 SAY "PLEASE ALIGN REPORT TO TOP OF PAGE"
                     WAIT
                     @  0, 0
                     SET DEVICE TO PRINT
                     nl := 14
                     DebCostHd()                             // Below
                               
                  ELSE
                     INKEY( 0 )
                     SCROLL()
                     nl := 0
                     DebCostHd()                             // Below
                  ENDIF
                  SELECT DebProf
               ENDIF
               @ nl, 0 SAY DebProf->Dbdate
               @ nl,11 SAY DebProf->Invno
               SELECT Name
               SEEK DebProf->Codeno
               IF FOUND()
                  @ nl,18 SAY SUBSTR( Name->Name, 1,28 )
               ENDIF
               SELECT DebProf
               @ nl,50 SAY DebProf->Amount   PICTURE "9999,999.99"
               namount += DebProf->Amount
               IF DebProf->CostItem > DebProf->Amount
                  ApRLock( 3 )
                  DebProf->CostItem := DebProf->Amount
                  UNLOCK  
               ENDIF 
               @ nl,61 SAY DebProf->CostItem PICTURE "9999,999.99"
               ncostitem += DebProf->CostItem
               @ nl,74 SAY DebProf->Saleno
               ***      @ nl,72 SAY ( DebProf->Costitem/DebProf->Amount )*100 PICTURE "9999 %" 
               nl++
               SELECT DebProf
               SKIP ALIAS DebProf
            ENDDO
            IF mwhere = "S"
               IF nl > 18
                  @ 22, 10 SAY Message->AnyKey
                  INKEY( 0 )
                  SCROLL()
                  nl := 10
               ENDIF
            ENDIF
            @ nl,50 SAY REPLICATE( "-",29 )
            nl++
            @ nl,20 SAY namount   PICTURE "$9999,999.99"
            @ nl,50 SAY namount   PICTURE  "9999,999.99"
            @ nl,61 SAY ncostItem PICTURE  "9999,999.99"
            nl++
            @ nl,50 SAY REPLICATE( "-",29 )
            nl+=2
            ***   namount := ( namount/9 )*8
            ***   @ nl, 8 SAY "Without GST"
            @ nl,16 SAY namount                               PICTURE "$9,999,999.99"
            @ nl,30 SAY ncostitem                             PICTURE  "9,999,999.99"
            @ nl,43 SAY namount-ncostitem                     PICTURE  "9,999,999.99" 
            @ nl,57 SAY ( ( namount-ncostitem )/namount )*100 PICTURE  "9999 %" 
            nl++
            IF mwhere == "P"
               EndPrint()
            ELSE
               WAIT
               mok := "N"
               DO WHILE mok = "N"
                  mok := ApReadN()
               ENDDO
               IF PressedEsc()
                  RETURN NIL
               ENDIF
            ENDIF
            SELECT DebProf
            SET ORDER TO 1
            LOOP
         CASE nselect == 3
            DebAdd()                               //
            mcontinue := "Y"
            LOOP 
         CASE nselect == 4
            SCROLL(  19, 0, 24,80  )
            cstring := TRIM( Message->Suredel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF mok == "Y"
               mdelete := "D"
               SELECT DebProf
               ApRLock( 3 )
               DELETE
               UNLOCK
            ENDIF
            mcontinue := "Y" 
            manother  := "Y" 
            LOOP
         CASE nselect == 5
            SCROLL()
            manother  := "N" 
            mcontinue := "Y"
            LOOP
      ENDCASE
   ENDDO                   // mcontinue

   RETURN NIL

   ***---- End of DebCost()

   **---------------------------------------------------------------------*

STATIC FUNCTION Debcosthd()

   @  0, 0 SAY Control->U_Name
   @  0,34 SAY dyymm 
   @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
              +STR( YEAR(DATE() ),5 )
   @  2, 0 SAY "Date       Invoice    Name"
   @  2,53 SAY "Amount+GST   Cost-GST"
   nl := 4                 

   RETURN NIL
   *** End of Debcosthd()

   **---------------------------------------------------------------------*

STATIC FUNCTION DebProfH()

   @  0, 0 SAY Control->U_Name
   @  0,34 SAY mstmm 
   @  0,47 SAY mendmm 
   @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
   @  2, 0 SAY "Inv #"
   @  2,10 SAY "Date"
   @  2,21 SAY "Name"
   @  2,51 SAY "Amount"
   @  2,64 SAY "Cost"
   @  2,74 SAY "Sale"
   nl := 4

   RETURN NIL

FUNCTION DebPayRep()

   mok := "Y"
   DO WHILE mok == "Y"
      SCROLL()
      msaleno := Control->Saleno
      @  6,10 SAY Message->Blank GET msaleno PICTURE "@K!"
       READ
      IF msaleno != SPACE( 4 )
         SELECT Salebook
         SEEK msaleno
         IF !FOUND()

             Sblook( @msaleno )                      // XLP_Acc.PRG

         ENDIF
         msaleno := Salebook->Saleno
         @  8,10 SAY "Sale Book # "+SaleBook->Saleno+"  "+Salebook->Sbname
      ENDIF
      mstmm  := DATE()-30
      mendmm := DATE()
      @ 10, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
      @ 11, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
       READ 
      mwhere := "S"

       Printsel( mwhere )

      IF mwhere = "P"
      ***      SET MARGIN TO 5
         npl := 54
         nl  := 14
       ELSE
         nl  := 0
         npl := 22
      ENDIF
      SCROLL() 

        RepDebPay()                           // Below
      
      mpageno = 1
      SELECT DebProf
      SET ORDER TO 2                   // Invno
      GOTO TOP
      ntot1:= ntot2:= ntot3:= ntot4 := 0
      mgtotr:= namount:= ncostitem := 0
      DO WHILE DebProf->( !EOF() )
         IF DebProf->DbDate < mstmm
            SKIP ALIAS DebProf
            LOOP
         ENDIF
         IF DebProf->DbDate > mendmm
            SKIP ALIAS DebProf
            LOOP
         ENDIF
         IF msaleno != SPACE( 4 )
            IF DebProf->Saleno != msaleno
               SKIP ALIAS DebProf
               LOOP
            ENDIF
         ENDIF
         IF nl > npl
           mpageno := mpageno+1
           nl++
           @ nl, 4 SAY "Report is Continued on Next Page"
           IF mwhere == "P"
              EndPrint()
              SCROLL( 3, 0, 24,75 )
              @ 12, 0 SAY "PLEASE ALIGN REPORT TO TOP OF PAGE"
              WAIT
              @  0, 0
              SET DEVICE TO PRINT
              nl := 14

               RepDebPay()                             // Below
                        
             ELSE
              INKEY( 0 )
              SCROLL()
              nl := 0
               RepDebPay()                             // Below

           ENDIF
           SELECT DebProf
         ENDIF
         @ nl, 0 SAY DebProf->Dbdate
         @ nl,11 SAY DebProf->Invno
         ncostitem += DebProf->CostItem
         SELECT Name
         SEEK DebProf->Codeno
         IF FOUND()
            @ nl,18 SAY SUBSTR( Name->Name,1,15 )
         ENDIF
         IF DebProf->Codeno != Debprof->U_Codeno
            SELECT Name
            SEEK DebProf->U_codeno
            IF FOUND()
               nl++
               @ nl,16 SAY SUBSTR( Name->Name,1,17 )
            ENDIF
         ENDIF
         SELECT DebProf
         DO CASE
            CASE DebProf->PayType == "CA"
               @ nl,35 SAY DebProf->Amount PICTURE "99,999.99"
               ntot1 += DebProf->Amount
            CASE DebProf->PayType == "CH"
               @ nl,45 SAY DebProf->Amount PICTURE "99,999.99"
               ntot2 += DebProf->Amount
            CASE DebProf->PayType == "CT"
               @ nl,55 SAY DebProf->Amount PICTURE "99,999.99"
               ntot3 += DebProf->Amount
            OTHERWISE
               @ nl,65 SAY DebProf->Amount PICTURE "99,999.99"
               ntot4 += DebProf->Amount
         ENDCASE
         nl++
         SELECT DebProf
         SKIP ALIAS DebProf
      ENDDO
      IF mwhere = "S"
         IF nl > 18
            @ 22, 10 SAY Message->AnyKey
            INKEY( 0 )
            SCROLL()
            nl := 10
         ENDIF
      ENDIF
      @ nl,36 SAY REPLICATE( "-",40 )
      nl++
      mamount := ( ntot1+ntot2+ntot3+ntot4 )
      @ nl,18 SAY mamount PICTURE "$999,999.99"
      @ nl,35 SAY ntot1   PICTURE "99,999.99"
      @ nl,45 SAY ntot2   PICTURE "99,999.99"
      @ nl,55 SAY ntot3   PICTURE "99,999.99"
      @ nl,65 SAY ntot4   PICTURE "999,999.99"
      nl++
      @ nl,36 SAY REPLICATE( "-",40 )
      nl+=2
      ***   mamount   := ( mamount/9 )*8
      ***   @ nl, 0 SAY "This is without GST"
      @ nl,21 SAY mamount                               PICTURE "$999,999.99"
      @ nl,33 SAY ncostitem                             PICTURE "999,999.99"
      @ nl,46 SAY mamount-ncostitem                     PICTURE "999,999.99" 
      @ nl,60 SAY ( ( mamount-ncostitem )/mamount )*100 PICTURE "9999 %" 
      nl++
      IF mwhere == "P"
         EndPrint()
        ELSE
         WAIT
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
      ENDIF
      mok := ApGetN( TRIM( Message->Another )+" Date" )
   ENDDO                               // mok

   SELECT DebProf
   SET ORDER TO 1

   RETURN NIL

   *** End of DebPayRep()

   **-------------------------------------------------------------------

FUNCTION RepDebPay()

   @  nl, 0 SAY mstmm 
   @  nl,16 SAY mendmm 
   @  nl,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   nl+=2
   @ nl, 0 SAY "Date      Invoice #"
   @ nl,38 SAY "Cash      Cheque    Charge   Others"
   nl+=2                 

   RETURN NIL
   *** End of RepDebPay()

   **********------------ END OF FILE DEBPAY.PRG
