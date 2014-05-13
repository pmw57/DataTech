*** JoKir09  29-09-11 12:50:25 

/*  Program.....:                CHRIORD.PRG
    Authors.....: J.Kirby
    Date........:  2/08/2001
    Functions...: QPuotPrice, ChriFacDis, FactHist,
                : QFactSearch, QFactEdit, QFactPrice, FactPrice 
                : QPuoLook, QPuotSearch, QPuotEdit, QPuotPAdd
                : WoHouCost, IvcAddP.

    IN HOUSE STOCK WORK ORDERS       
*/

FUNCTION IvcAddP()

SCROLL( 3, 0, 24,80 )
mcont  := "N"
nrecno := 0
   SELECT Quot
   GOTO TOP
   SEEK mcodeno+cbranchId
   IF FOUND()
      aPart_ :={}
      IF LASTREC() != 0
         DO WHILE Quot->Codeno == mcodeno .AND. Quot->( !EOF() )
            IF Quot->BranchId != cbranchId
               SKIP ALIAS Quot
               LOOP
            ENDIF
            IF csentgood = "Y"
               IF Quot->GoodSent = 0
                  SKIP ALIAS Quot
                  LOOP
               ENDIF
            ENDIF 
            SELECT Part
            SEEK Quot->Partnum
            SELECT Quot
            AADD( aPart_,SUBSTR( Quot->Partnum, 1, 9 );
                +" "+STR( Quot->Qty, 5 );
                +" "+STR( Quot->GoodSent, 5 );
                +"  "+SUBSTR( Quot->Ordnum, 1,10 );
                +" "+DTOC( Quot->DbDate );
                +" "+SUBSTR( Part->Desc, 1,19 );
                +" "+STR( Quot->Amount, 7, 2 );
                +" "+Quot->BranchId;
                +"      "+STR( RECNO(),6 ) )
            SKIP ALIAS Quot
         ENDDO
         IF !EMPTY( aPart_ )
            DISPBOX( 3, 1, 19,79, 2 )
            @  4,12      SAY "Order  To Invoice"
            @  4,COL()+2 SAY "PARTS in the Orders File"
            anum := ACHOICE( 6, 3,18,78,aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            SELECT Quot
            GOTO nrecno
            SELECT Part
            SEEK Quot->Partnum
            mpartnum := Part->Partnum
            SCROLL(   9, 0, 24,80 )
            DISPBOX(  9, 1, 19,79, 2 )
            @ 11, 4      SAY Name->Name+" "+Name->Add1+" "+cbranchId
            @ 13, 4      SAY TRIM( Part->Partnum )+" "+TRIM( Part->Desc )
            @ 15, 4      SAY "    Ordered "+STR( Quot->OrgQty ) COLOR "G+"
            @ 16, 4      SAY "Outstanding "+STR( Quot->Qty )    COLOR "G+"
            @ 16,COL()+2 SAY "Goods Sent"+STR( Quot->GoodSent );
                              +" "+STR( Quot->Amount )          COLOR "G+"
            @ 16,COL()+2 SAY TRIM( Quot->Ordnum )               COLOR "G+"
            @ 16,COL()+2 SAY Quot->Invno
            @ 17, 7      SAY TRIM( Quot->Info )+" "+TRIM( Quot->Info2 )
            @ 18, 7      SAY TRIM( Quot->Info3 )+" "+TRIM( Quot->Info4 )
            mcont := ApGetY( "Use Part from Order File" )
            IF LASTKEY() == 27
               RETURN
            ENDIF
         ENDIF                     // not Empty 
      ENDIF                        // LASTREC()
   ENDIF                           // FOUND()
IF mcont = "N"
   nrecno := 0
   SELECT Part
   mcodeno := Name->Codeno

    Partfind( @mpartnum, mcodeno )                // XlF_Part

   IF LASTKEY() == 27
      RETURN
   ENDIF
   SEEK mpartnum
   DO WHILE !FOUND()
            
     PartFind( @mpartnum, mcodeno )              // XLF_Part 

     IF LASTKEY() == 27
        RETURN
     ENDIF
   ENDDO                                  // Found 
    ApRLock( 3 )
   mpartnum := Part->Partnum
   UNLOCK
ENDIF                           // mcont = Y

    IvcPrice( mcont )                            // Below

   IF mcont = "Y"
      SELECT QuotOrd
       ApFLock( 3 )
      APPEND BLANK
      QuotOrd->Partnum := Quot->Partnum
      QuotOrd->Qty     := Invoice->Qty
      QuotOrd->Codeno  := Quot->Codeno
      QuotOrd->Ordnum  := Quot->Ordnum
      QuotOrd->DBDate  := Date()
      QuotOrd->Invno   := Invoice->Invno
      UNLOCK
      SELECT Quot
       ApFLock( 3 )
      Quot->Qty := ( Quot->Qty-Invoice->Qty )
      Quot->Goodsent := ( Quot->Goodsent-Invoice->Qty )
      IF Quot->Goodsent <= 0
         Quot->Goodsent := 0
      ENDIF         
      DELETE ALL FOR Quot->Qty <= 0
      UNLOCK
   ENDIF

RETURN( mpartnum )

****---- End of IvcAddP()

***--------------------------------------------------------------------------

FUNCTION QPuotPAdd( mpartnum )
 
   quotcodeno := Name->Codeno
   IF mpartnum = SPACE( 20 ) 
      SELECT Part
      SET ORDER TO 1
      SCROLL()
       Partfind( @mpartnum )                // XlF_Part
      mpartnum := Part->Partnum
      IF LASTKEY() == 27
         RETURN( mcodeno )
      ENDIF
   ENDIF                            // mpartnum
   IF Control->LastUpd <= DATE()
      SELECT Control
       ApRLock( 3 )
      Control->LastUpd := DATE()+15
      UNLOCK 
   ENDIF
   SELECT Name
   SEEK quotcodeno
   mcodeno := Name->Codeno
   SELECT Part
   SET ORDER TO 1                  // Partnum 
   SEEK mpartnum
   SCROLL( 12, 0, 24,80 )
   coderef  := mpartnum
    MemoDisp( coderef )   // XF-Memo2
   SCROLL( 12, 0, 24,80 )
   SELECT Part
   SEEK mpartnum 
   IF FOUND()
      SELECT Quot
       ApFLock( 3 )
      APPEND BLANK
      Quot->Partnum  := mpartnum
      Quot->Codeno   := Name->Codeno
      Quot->Catno    := Part->Catno
***      Quot->Amount   := Part->Wholesale REMOVE *** IF Price not entered
      Quot->Cost     := Part->Trade
      Quot->Ordnum   := Name->Remarks
      Quot->BranchId := cbranchId
      Quot->Dbdate   := Name->Date        // DATE()
      Quot->DueDate  := Control->LastUpd       // Name->Date+15
      IF SUBSTR( Control->U_Name,1, 4 ) = "CHRI"
         Quot->Faxno := Name->Refer
        ELSE  
         Quot->Faxno := STR( Control->LastQuot,8, 0 )    
      ENDIF
***      IF Quot->Dbdate < DATE()-20 
***         Quot->Dbdate := DATE()
***      ENDIF
      UNLOCK
      SELECT Control
       ApRLock( 3 )
      IF SUBSTR( Control->U_Name,1, 4 ) != "CHRI"
         Control->LastQuot := Control->LastQuot+1
      ENDIF
      UNLOCK
      SELECT Quot
      mok := "N"
      DO WHILE mok = "N"
          QPuotPrice( @mpartnum )                         // Above
         mok := ApGetY( TRIM( Message->Correct ) )
      ENDDO
      SELECT QuotOrd
       ApFLock( 3 )
      APPEND BLANK
      QuotOrd->Partnum  := mpartnum
      QuotOrd->Codeno   := Name->Codeno
      QuotOrd->Ordnum   := Name->Remarks
      QuotOrd->BranchId := cbranchId
      QuotOrd->Dbdate   := Name->Date        // DATE()
      QuotOrd->OrdQty   := Quot->Qty 
      UNLOCK
    ELSE
      SCROLL()
   ENDIF
   SELECT Quot

RETURN( mpartnum )

****---- End of QPuotPAdd()

****--------------------------------------------------------------------------

FUNCTION FactHist()

mcontinue := "Y"
DO WHILE mcontinue = "Y"

         SCROLL()
        cbranchId := SPACE( 2 )
           mcodeno := SPACE( 8 )
              Namerank( @mcodeno )                // XLF_Name
             IF LASTKEY() == 27 
                RETURN NIL
             ENDIF
             SELECT Name
             mcodeno := Name->Codeno
      SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
   @  1,15 SAY Name->Name 
   cbranchId := SPACE( 2 )
   mok := ApGetN( "Do You Want Branch" )
   IF mok = "Y"
      SELECT Branch
      SEEK mcodeno
      IF FOUND()
         BranchFind( @mcodeno )             // ZSF_Name
         cbranchId := Branch->BranchId
      ENDIF
   ENDIF               // mok Branch
   mpartnum := SPACE( 20 )
   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
    @  1,15 SAY Name->Name+"  "+cbranchId  
    SCROLL(  3, 0, 24,80 )
    DISPBOX( 3, 1, 18,79, 2 )
    dstmm    := DATE()-30
    dendmm   := DATE()
    @  8,10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
    @ 10,10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
     READ

    mwhere := "S"

     Printsel( mwhere )                    // _LF_Init

   IF mwhere = "P"
      npl := 54
     ELSE
      npl := 18 
   ENDIF 
   nl := 3
   IF mwhere = "P"
      @  nl, 0 SAY Control->U_Name
      @  nl,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
      nl++
      @ nl, 1 SAY Control->U_Add1
      nl++
      @ nl, 1 SAY Control->U_Add2
      nl++
      @ nl, 1 SAY Control->U_Add3
      nl++
      @ nl, 1 SAY Control->U_Add4
      nl++
      @ nl, 1 SAY "Phone "+Control->U_Phone+" Fax "+Control->U_Fax
      nl+=2
      @  nl, 3 SAY Name->Name+"  "+cbranchId
      nl+=2 
      @  nl,10 SAY "From " +DTOC( dstmm ) 
      @  nl,32 SAY "To "   +DTOC( dendmm ) 
      nl++
    ELSE
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @ 1,15 SAY TRIM( Name->Name ) 
      @ 1,COL()+2 SAY "From " +DTOC( dstmm ) 
      @ 1,COL()+2 SAY "To "   +DTOC( dendmm ) 
   ENDIF
   SELECT Hist
   SET ORDER TO 1
****   IF LASTREC() != 0
      SEEK mcodeno
      DO WHILE Hist->Codeno = mcodeno .AND. Hist->( !EOF() )
         IF mok = "Y"
            IF Hist->BranchId != cbranchId
               SKIP ALIAS Hist
               LOOP
            ENDIF 
         ENDIF 
         IF SUBSTR( Hist->Partnum,1,4 ) = "FREI"
            SKIP ALIAS Hist
            LOOP
         ENDIF 
         IF Hist->PDate < dstmm
            SKIP ALIAS Hist
            LOOP
         ENDIF
         IF Hist->PDate > dendmm
            SKIP ALIAS Hist
            LOOP
         ENDIF
         IF nl > npl
            IF mwhere = "S"
               INKEY( 0 )
               SCROLL()
             ELSE
               EJECT
            ENDIF
            @  0, 0 SAY Control->U_Name
            @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ),5 )
            @  2, 5 SAY Name->Name+"  "+cbranchId  
            @  4,10 SAY "From " +DTOC( dstmm ) 
            @  4,32 SAY "To "   +DTOC( dendmm )
            nl := 4 
         ENDIF                      // nl
         SELECT Part
         SEEK Hist->Partnum
         SELECT Hist
         @ nl, 0 SAY SUBSTR( Hist->Partnum, 1,10 );
                +" "+SUBSTR( Part->Desc, 1,35 );
                +" "+STR( Hist->Qty, 6 );
                +"  "+DTOC( Hist->PDate );
                +"  "+Hist->Invno
         nl++
         IF Hist->Sentby != SPACE( 25 )
            @ nl,20 SAY Hist->Sentby+" "+Hist->DocNo
            nl++
         ENDIF
         SKIP ALIAS Hist
      ENDDO                             // EOF

   SELECT Quot
   GOTO TOP
***   SET ORDER TO 2    // Code Branch Part
***   IF LASTREC() != 0
      SEEK mcodeno
      IF FOUND()
         nl++
         @ nl, 8 SAY "Sent but not Invoiced Yet to "+mcodeno
         nl++
      ENDIF
      DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
         IF mok = "Y"
            IF Quot->BranchId != cbranchId
               SKIP ALIAS Quot
               LOOP
            ENDIF 
         ENDIF 
         IF SUBSTR( Quot->Partnum, 1, 4 ) = "FREI"
            SKIP ALIAS Quot
            LOOP
         ENDIF 
         IF Quot->DBDate < dstmm
            SKIP ALIAS Quot
            LOOP
         ENDIF
         IF Quot->DBDate > dendmm
            SKIP ALIAS Quot
            LOOP
         ENDIF
         IF nl > npl
            IF mwhere = "S"
               INKEY( 0 )
               SCROLL()
             ELSE
               EJECT
            ENDIF
            @  0, 0 SAY Control->U_Name
            @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ),5 )
            @  2, 5 SAY Name->Name+"  "+cbranchId  
            @  4,10 SAY "From " +DTOC( dstmm ) 
            @  4,32 SAY "To "   +DTOC( dendmm )
            nl := 5 
         ENDIF                      // nl
         SELECT Part
         SEEK Quot->Partnum
         SELECT Quot
         @ nl, 0 SAY SUBSTR( Quot->Partnum, 1, 8 );
                +" "+SUBSTR( Part->Desc, 1,35 );
                +" "+STR( Quot->Qty, 6 );
                +"  "+DTOC( Quot->DBDate );
                +"  "+Quot->Invno
         nl++
         IF Quot->Sentby != SPACE( 25 )
            @ nl,20 SAY Quot->Sentby+" "+Quot->DocNo
            nl++
         ENDIF
         IF Quot->Info8 != SPACE( 45 )
            @ nl,10 SAY Quot->Info8
            nl++
         ENDIF 
         IF Quot->Info9 != SPACE( 45 )
            @ nl,10 SAY Quot->Info9
            nl++
         ENDIF 
         SKIP ALIAS Quot
      ENDDO                             // EOF
      SELECT Quot
      SET ORDER TO 1
***   ENDIF                    // LastRec Not 0
    IF mwhere == "S"
       nl++
***       INKEY( 0 )
       mok := "N"
       DO WHILE mok = "N"
          mok := ApReadN()
       ENDDO
     ELSE
       EndPrint()
    ENDIF
    mcontinue := ApGetN( TRIM( Message->Another )+" Name" )
ENDDO

RETURN

****---- End of FactHist()

***-------------------------------------------------------------------

FUNCTION QPuotPrice( mpartnum )

   SELECT Quot
   IF Quot->Qty == 0
       ApRLock( 3 )
      Quot->Qty    := 1
      UNLOCK
   ENDIF
   SCROLL()
   DISPBOX( 0, 1, 24,79, 2 )
   @  1, 3 SAY Name->Name+" "+Name->Add1+" "+cbranchId
   @  3, 3 SAY TRIM( Part->Partnum )+" "+TRIM( Part->Desc );
                   +" "+STR( Part->Wholesale,9,2 )+" "+TRIM( Part->Unit )
   SELECT Hist
   SEEK Name->Codeno+Part->Partnum
   nl := 4
   nlastprice := 0
   DO WHILE Hist->Codeno = mcodeno .AND. Hist->( !EOF() )
      IF Hist->PDate < DATE()-365
         SKIP ALIAS Hist
         LOOP
      ENDIF
      IF cbranchId != SPACE( 2 )
         IF Hist->BranchId != cbranchId
            SKIP ALIAS Hist
            LOOP
         ENDIF
      ENDIF
      IF Hist->Partnum = mpartnum
         IF nl > 10
            nl := 4
            SCROLL( nl, 3, 17,74 ) 
         ENDIF
         @ nl, 3      SAY "Last Qty"
         @ nl,COL()+1 SAY Hist->Qty  PICTURE "99,999"      COLOR "RG+"
         @ nl,COL()+2 SAY "Price" 
         @ nl,COL()+1 SAY Hist->Amount PICTURE "99,999.99" COLOR "RG+"
**** /( 1-Hist->Discount/100 ) 
         @ nl,COL()+2 SAY "Disc"
         @ nl,COL()+1 SAY Hist->Discount  PICTURE "999.99"
         @ nl,COL()+1 SAY Hist->PDate
         @ nl,COL()+1 SAY SUBSTR( Hist->Est, 1,16 )
         nl++
         nlastprice := Hist->Amount
      ENDIF
      SKIP Alias Hist
   ENDDO
   nl := 11
   SELECT Equ
   mmodcode := TRIM( mpartnum )
***   SET EXACT ON
   SEEK mmodcode
   mmodcode := Equ->Modcode
   IF FOUND()
/*
          equnl := 0   
          DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !EOF() )
             IF equnl > 24
                INKEY( 1 )
                equnl := 0
             ENDIF
             @ equnl,72 SAY SUBSTR( Equ->Partnum,1, 8 ) COLOR "G+" 
             equnl++
             SELECT Part
             SEEK Equ->Partnum
             SELECT Equ
             SKIP ALIAS Equ
         ENDDO                       // EOF()
*/
       SELECT Equ
       SET EXACT ON
       ntottrade:= ntotwhol := 0
       ntottrade1:= ntotwhol1 := 0
       nrecno2:= nrecno3:= nrecno4 := 0
       nqty1:= nqty2:= nqty3:= nqty4 := 0
       nequ1:= nequ2:= nequ3:= nequ4 := 0
       mmod2:= mmod3:= mmod4 := SPACE( 16 )
      GOTO TOP
      SEEK mmodcode                // Original Part
      IF FOUND()   
   DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !EOF() )
      nrecno2 := RECNO() 
      SELECT Part
      SEEK Equ->Partnum
      SELECT Equ
      mmod2   := SUBSTR( Equ->Partnum, 1,16 ) 
      nqty1   := Equ->Partqty 
      GOTO TOP
      SEEK mmod2
      ntottrade1 += ( Part->Trade*nqty1 )
      ntotwhol1  += ( Part->Wholesale*nqty1 )
      IF !FOUND()
         ntottrade += ( Part->Trade*nqty1 )
         ntotwhol  += ( Part->Wholesale*nqty1 )
      ENDIF
      IF FOUND()
         DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
                  SELECT Part
            SEEK Equ->Partnum
            SELECT Equ
            mmod3   := SUBSTR( Equ->Partnum, 1,16 )
            nrecno3 := RECNO() 
            nqty2   := Equ->PartQty
            nequ2   := ( nqty2*nqty1 )
            GOTO TOP
            SEEK mmod3
      IF !FOUND()   
         ntottrade += ( Part->Trade*nequ2 )
         ntotwhol  += ( Part->Wholesale*nequ2 )
      ENDIF
      IF FOUND()
         DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
            SELECT Part
            SEEK Equ->Partnum
            SELECT Equ
            mmod4   := SUBSTR( Equ->Partnum, 1,16 )
            nrecno4 := RECNO()
            nqty3   := Equ->PartQty
            nequ3   := ( nqty3*nqty2 )*nqty1
            GOTO TOP
            SEEK mmod4
            IF !FOUND()
               ntottrade += ( Part->Trade*nequ3 )
               ntotwhol  += ( Part->Wholesale*nequ3 )
            ENDIF
            IF FOUND()
            DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
               nqty4 := Equ->PartQty
               nequ4 := ((( nqty4*nqty3 )*nqty2 )*nqty1 )
               SELECT Part
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
      SELECT Equ
      GOTO TOP
      SEEK mmodcode
      @ nl, 3      SAY mmodcode+" Kit"
      @ nl,COL()+1 SAY ntotTrade1 PICTURE "999,999.99"
      @ nl,COL()+2 SAY "Part Cost"
      @ nl,COL()+1 SAY ntotTrade  PICTURE "999,999.99"
      @ nl,COL()+2 SAY "Kit Sell"
      @ nl,COL()+1 SAY ntotWhol1 PICTURE "999,999.99"
   ENDIF     
   SELECT Part
   SET ORDER TO 1
   SEEK mpartnum
    ApRLock( 3 )
   nl++
   @ nl, 6      SAY "Inventory Cost"
   @ nl,COL()+1 SAY Part->Trade     PICTURE "999999.99"
   @ nl,COL()+2 SAY "Inventory Sell Price"
   @ nl,COL()+1 SAY Part->Wholesale PICTURE "999999.99"
   @ nl,COL()+2 SAY TRIM( Part->Unit )
    READ
   UNLOCK
***   COMMIT
   SELECT Quot
    ApRLock( 3 )
   Quot->Cost := Part->Trade
   IF Quot->Amount = 0
      IF Name->Margin = 0              // Adds % for Name->Margin
         Quot->Amount := Part->Wholesale
       ELSE
         Quot->Amount := ( ( Part->Wholesale*( 1+Name->Margin/100 )*100 ) /100 )
      ENDIF
   ENDIF
   nl++
   @ nl, 6      SAY "This Order Price " GET Quot->Amount PICTURE "999999.99"
   @ nl,COL()+2 SAY Name->Discount PICTURE "+999.99%" COLOR "G+"
   @ nl,COL()+2 SAY Name->Margin   PICTURE "+999.99%" COLOR "G+"
    READ
   IF Quot->Amount < nlastprice 
      @ nl, 6 SAY "Check Price    " GET Quot->Amount PICTURE "999999.99"
       READ
   ENDIF
   @ nl,60 SAY "Disc" GET Quot->Discount  
    READ
   UNLOCK

    QuotChange()                    // QuoHouse
   
RETURN mpartnum

****------- End QPuotPrice

**-------------------------------------------------------------------

FUNCTION QPuotSearch()

mcodeno := SPACE( 8 )
SELECT Quot
   mtempcode := "A       "
   GOTO TOP
   SEEK mtempcode
   IF !FOUND()
       ApFLock( 3 )
      APPEND BLANK
      Quot->Codeno := "A      " 
      Quot->Invno  := "9     "
      UNLOCK
   ENDIF 
aPart_ := anum:= {}
nrecno:= ntotal := 0
*** maccepted := ApGetN( "Do You Want NOT Accepted Only" )
maccepted := "N"
SCROLL()
DISPBOX( 0,45, 4,75, 2 )
@  1,47 SAY "Select Name - Branch"
@  2,47 SAY "Branch Specific"
SELECT Quot
IF LASTREC() = 0
   @ 7,53 SAY "NO Work Orders"
   INKEY( 2 ) 
   RETURN NIL
ENDIF
IF LASTREC() != 0
   GOTO TOP
   mtempno := SPACE( 10 )
   DO WHILE Quot->( !EOF() )
      IF Quot->Invno != SPACE( 6 )
         IF Quot->Invno != "9     "
            SKIP ALIAS Quot
            LOOP
         ENDIF 
      ENDIF
      ntotal += ( Quot->Amount*Quot->Qty )
      IF Quot->Codeno+Quot->BranchId = mtempno
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF maccepted = "Y"
         IF Quot->Accepted != "N"
            SKIP ALIAS Quot
            LOOP
         ENDIF
      ENDIF                     // maccepted
      SELECT Name
      SEEK Quot->Codeno
      SELECT Quot
      mtempno := Quot->Codeno+Quot->BranchId
      AADD( aPart_,Name->Name+"  "+Quot->BranchId;
           +"      "+STR( RECNO(),6 ) )
      SKIP ALIAS Quot
   ENDDO
   DISPBOX( 0, 1, 24,42, 2 )
   @ 24,45 SAY TRIM( Message->Select )
***   @  8,47 SAY ntotal PICTURE "$9,999,999.99" COLOR "GB+" 
   @ 12,47 SAY "F2 To View ALL Orders" COLOR "GB+"
   IF !EMPTY( aPart_ )
      ASORT(aPart_,,,{ | x,y | x < y })
      anum := ACHOICE( 1, 3, 23,40, aPart_,,"AFUNC" )
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      IF LASTKEY() == 27
         RETURN NIL
      ENDIF
      IF LASTKEY() == -1
         SELECT Quot
         GOTO TOP
         IF LASTREC() != 0
            aPart_ := {}
            nrecno := 0
            DO WHILE Quot->( !EOF() )
               IF Quot->Invno != SPACE( 6 )
                  SKIP ALIAS Quot
                  LOOP
               ENDIF
               AADD( aPart_,SUBSTR( Quot->Partnum, 1,12 );
                       +" "+Quot->Codeno; 
                       +" "+DTOC( Quot->Dbdate );
                       +" "+STR( Quot->OrgQty, 7, 0 );
                       +" "+STR( Quot->Qty, 7, 0 );
                       +" "+STR( Quot->GoodSent, 7, 0 );
                       +" "+STR( Quot->Amount, 8, 2 );
                       +" "+Quot->Faxno;
                       +"           "+STR( RECNO(),6 ) )
                SKIP ALIAS Quot
            ENDDO
            IF !EMPTY( aPart_ )
               SCROLL()
               DISPBOX(  0, 1, 24,79, 2 )
               @  0,32 SAY " Order  Out  Inv "
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum   := ACHOICE(  1, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
               nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
               GOTO nrecno
               mcodeno := Quot->Codeno
            ENDIF                     // Empty
         ENDIF                        // LastRec    
      ENDIF                 // LastKey = -1
   ENDIF
   GOTO nrecno
   IF Quot->Codeno = "A       "
         QPuotAdd()
         QPuotSearch()
   ENDIF                 // Codeno = A
   mcodeno    := Quot->Codeno
   cbranchId  := Quot->BranchId
   cfaxno     := Quot->Faxno
   dDbdate    := Quot->DbDate
   quotcodeno := Quot->Codeno
   SELECT Name
   SEEK mcodeno
   SELECT Quot

     QPuotEdit( mcodeno )

ENDIF
IF mcodeno != SPACE( 8 )
    QPuotSearch()
ENDIF
RETURN

****---- End of QPuotSearch()

*---------------------------------------------------------------------*

FUNCTION FactPrice()

     SCROLL()
       mcodeno  := SPACE( 8 )
       mpartnum := SPACE( 20 )

       Partfind( @mpartnum, mcodeno )                        // Below

     IF LASTKEY() == 27
        Menu() 
     ENDIF
   SELECT Part
   SET ORDER TO 1                           // Partnum
   SEEK mpartnum
   mpartmod := Part->Partnum
   IF !FOUND()
      SCROLL(  3, 0, 24,80 )
      DISPBOX( 3, 1, 24,79, 2 ) 
      @ 12,10 SAY "NO SUCH PART IN FILE"
      mok:=ApGetN( "Yes = Add Part - No = Search" )
      IF LASTKEY() == 27
         RETURN
      ENDIF
      IF mok == "Y"

          Partadd( @mpartnum )              // XF_Part
         SELECT Part
         SET ORDER TO 1                     // Partnum
         SEEK mpartnum
           ApRLock( 3 )
         mpartnum := Part->Partnum
         UNLOCK
       ELSE
         PartFind( @mpartnum )   
      ENDIF                            // mok  
   ENDIF                               // FOUND()
       mpartnum := Part->Partnum
       SCROLL()
       DISPBOX( 0, 1,  2,79, 2 )
       @  1, 4 SAY TRIM( mpartnum )+"  "+TRIM( Part->Desc ) COLOR "G+"
       @  1,65 SAY Control->Margin PICTURE "999"
       DISPBOX( 3, 1, 24,79, 2 )
       nl := 6
       @  nl, 4 SAY TRIM( mpartnum )+"  "+TRIM( Part->Desc ) COLOR "G+"
       nl+=4 
       @ nl, 9      SAY "Factory Sell" 
       nfactpart := ( Part->Wholesale* ( 1+( Control->Margin/100) ) )
       @ nl,COL()+2 SAY nfactpart*1.125 PICTURE "999,999.99" COLOR "BG+"
       @ nl,COL()+1 SAY "GST Included" COLOR "BG+"
       nl+=2 
       @ nl, 9      SAY "GST ="
       @ nl,COL()+1 SAY ( nfactpart*1.125 )-( nfactpart );
                                              PICTURE "99,999.99"
       nl+=4
***       @ nl, 9      SAY "Cat # "+Part->Catno  
***       @ nl,COL()+1 SAY "Group "+Part->PartId 
***    @ 19, 6 SAY "Width mm"+STR( Part->Width )+" Thick mm"+STR( Part->Thick );
***                +" Length Mtr "+STR( Part->Length )
       INKEY( 0 )
RETURN

****---- End of FactPrice()

**---------------------------------------------------------------------*

FUNCTION QFactSearch()

mcodeno := SPACE( 8 )
SELECT Quot
   mtempcode := "A       "
   GOTO TOP
   SEEK mtempcode
   IF !FOUND()
       ApFLock( 3 )
      APPEND BLANK
      Quot->Codeno := "A      " 
      Quot->Invno  := "9     "
      UNLOCK
   ENDIF 
aPart_ := anum:= {}
nrecno:= ntotal := 0
*** maccepted := ApGetN( "Do You Want NOT Accepted Only" )
maccepted := "N"
SCROLL()
DISPBOX( 0,45, 4,75, 2 )
@  1,47 SAY "Select Name - Branch"
@  2,47 SAY "Branch Specific"
SELECT Quot
IF LASTREC() = 0
   @ 7,53 SAY "NO Work Orders"
   INKEY( 2 ) 
   RETURN NIL
ENDIF
IF LASTREC() != 0
   GOTO TOP
   mtempno := SPACE( 10 )
   DO WHILE Quot->( !EOF() )
      IF Quot->Invno != SPACE( 6 )
         IF Quot->Invno != "9     "
            SKIP ALIAS Quot
            LOOP
         ENDIF 
      ENDIF
      ntotal += ( Quot->Amount*Quot->Qty )
      IF Quot->Codeno+Quot->BranchId = mtempno
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF maccepted = "Y"
         IF Quot->Accepted != "N"
            SKIP ALIAS Quot
            LOOP
         ENDIF
      ENDIF                     // maccepted
      SELECT Name
      SEEK Quot->Codeno
      SELECT Quot
      mtempno := Quot->Codeno+Quot->BranchId
      AADD( aPart_,Name->Name+"  "+Quot->BranchId;
           +"      "+STR( RECNO(),6 ) )
      SKIP ALIAS Quot
   ENDDO
   DISPBOX( 0, 1, 24,42, 2 )
   @ 24,45 SAY TRIM( Message->Select )
***   @  8,47 SAY ntotal PICTURE "$9,999,999.99" COLOR "GB+" 
   @ 12,47 SAY "F2 To View ALL Orders" COLOR "GB+"
   IF !EMPTY( aPart_ )
      ASORT(aPart_,,,{ | x,y | x < y })
      anum := ACHOICE( 1, 3, 23,40, aPart_,,"AFUNC" )
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      IF LASTKEY() == 27
         RETURN NIL
      ENDIF
      IF LASTKEY() == -1
         SELECT Quot
         GOTO TOP
         IF LASTREC() != 0
            aPart_ := {}
            nrecno := 0
            nweight := 0
            DO WHILE Quot->( !EOF() )
               IF Quot->Invno != SPACE( 6 )
                  SKIP ALIAS Quot
                  LOOP
               ENDIF
               AADD( aPart_,SUBSTR( Quot->Partnum, 1,16 );
                       +" "+Quot->Codeno; 
                       +" "+DTOC( Quot->Dbdate );
                       +" "+STR( Quot->OrgQty, 7, 0 );
                       +" "+STR( Quot->Qty, 7, 0 );
                       +" "+STR( Quot->GoodSent, 7, 0 );
                       +"  "+Quot->Faxno;
                       +"           "+STR( RECNO(),6 ) )
                SKIP ALIAS Quot
            ENDDO
            IF !EMPTY( aPart_ )
               SCROLL()
               DISPBOX(  0, 1, 24,79, 2 )
               @  0,36 SAY " Order Out  Inv "
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum   := ACHOICE(  1, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
               nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
               GOTO nrecno
               mcodeno := Quot->Codeno
            ENDIF                     // Empty
         ENDIF                        // LastRec    
      ENDIF                 // LastKey = -1
   ENDIF
   GOTO nrecno
   IF Quot->Codeno = "A       "
         QPuotAdd()
         QFactSearch()
   ENDIF                 // Codeno = A
   mcodeno    := Quot->Codeno
   cbranchId  := Quot->BranchId
   cfaxno     := Quot->Faxno
   dDbdate    := Quot->DbDate
   quotcodeno := Quot->Codeno
   SELECT Name
   SEEK mcodeno
   SCROLL()
   @ 4, 6 SAY Name->Name+"  "+cbranchId COLOR "BG+"
   csent   := SPACE( 9 ) 
   csentby := SPACE( 14 )
   cinit   := SPACE( 3 )
   cdocno  := SPACE ( 16 )
   cchange := "N"
   @  6, 6 SAY Name->Desc3 COLOR "BG+"
    ApFLock( 3 )
   IF Name->Desc3 != SPACE( 50 )
      cchange := ApGetN( "CHANGE Sent Details" )
   ENDIF   // cchange 
   IF cchange = "Y"     
      Name->Desc3 := SPACE( 50 )
   ENDIF
   UNLOCK
   IF Name->Desc3 = SPACE( 50 )
         @  6, 3 SAY "Sent By" COLOR "BG+"
         nsel := 1
         @  7, 3 PROMPT "Blank    "
         @  8, 3 PROMPT "Owens    "
         @  9, 3 PROMPT "TNL      "     
         @ 10, 3 PROMPT "NZCourier"     
         @ 11, 3 PROMPT "FastWays "
         @ 12, 3 PROMPT "Grant    "
         @ 13, 3 PROMPT "Mike     "
         @ 14, 3 PROMPT "Picked Up"
         @ 15, 3 PROMPT "TransWest"
         @ 16, 3 PROMPT "WhiteLine"
         @ 17, 3 PROMPT "OwnCourie"
         @ 18, 3 PROMPT "M.Stream "
         @ 19, 3 PROMPT "Grundy   "
     MENU TO nsel
     DO CASE
       CASE LASTKEY() == 27
         RETURN
       CASE nsel == 1
         csent := SPACE( 9 )
       CASE nsel == 2
         csent := "Owens    "
       CASE nsel == 3
         csent := "TNL      "
       CASE nsel == 4
         csent := "NZCourier"
       CASE nsel == 5
         csent := "FastWays"
       CASE nsel == 6
         csent := "Grant    "
       CASE nsel == 7
         csent := "Mike     "
       CASE nsel == 8
         csent := "Picked Up"
       CASE nsel == 9
         csent := "TransWest"
       CASE nsel == 10
         csent := "WhiteLine"
       CASE nsel == 11
         csent := "OwnCourie"
       CASE nsel == 12
         csent := "M.Stream "
       CASE nsel == 13
         csent := "Grundy   "
     ENDCASE
     @  9,20 SAY csent+" Docket #" GET csentby PICTURE "@!"
     @ 11,20 SAY "Initials"        GET cinit   PICTURE "@!"
     @ 11,40 SAY "Despatch #"      GET cdocno  PICTURE "@!"
       READ
       ApFLock( 3 )
      Name->Desc3 := csent+" "+csentby+" "+cinit+" "+cdocno  // 9+1+19+1+20   
      UNLOCK

   ENDIF
   nl+=2
   UNLOCK 
     QFactEdit( mcodeno )
ENDIF
IF mcodeno != SPACE( 8 )
    QFactSearch()
ENDIF
RETURN

****---- End of QFactSearch()

**---------------------------------------------------------------------*

FUNCTION QFactPrice( mpartnum )

   nsentqty := 0
   SCROLL()
   DISPBOX( 0, 1, 24,79, 2 )
   @  1, 3 SAY Name->Name+" "+Name->Add1+" "+cbranchId
   @  3, 3 SAY TRIM( Part->Partnum )+" "+TRIM( Part->Desc );
                   +" "+TRIM( Part->Unit )
   SELECT Quot
    ApRLock( 3 )
   Quot->Sentby := SUBSTR( Name->Desc3, 1,25 )
   Quot->Docno  := SUBSTR( Name->Desc3,26,20 )
   nl := 5
   @ nl, 4      SAY "O/N "+Quot->Ordnum
   @ nl,COL()+1 SAY "Date "       
   @ nl,COL()+1 SAY DTOC( Quot->Dbdate )      
   @ nl,COL()+2 SAY "Ref "+Quot->Faxno       PICTURE "@X"
   @ nl,COL()+1 SAY "Branch "+Quot->BranchId PICTURE "@!"
   nl+=2
   @ nl, 4      SAY "Ordered"+" "+TRIM( Part->Unit )+" Qty" 
   @ nl,COL()+2 SAY Quot->Qty COLOR "BG+"
   nl+=2
   Quot->DBDate := DATE()
   IF Quot->GoodSent > 0
      @ nl, 8      SAY "    Sent Already" GET Quot->GoodSent PICTURE "999999.99"
      nl+=2
      @ nl, 8      SAY "New Supplied Qty" GET nsentqty       PICTURE "999999.99" 
      nl+=2
    ELSE
      @ nl, 8 SAY "Qty Supplied" GET Quot->GoodSent PICTURE "999999.99"
      nl+=2
   ENDIF
   @ nl, 8 SAY "   Sent Date"    GET Quot->Dbdate PICTURE "99/99/9999"      
   nl+=2
   @ nl, 4      SAY "How Sent"   GET Quot->Sentby PICTURE "@!"
   @ nl,COL()+1 SAY "Despatch #" GET Quot->Docno  PICTURE "@!"
   nl+=2
   @ nl, 4 SAY "Add Note "       GET Quot->Info8
   nl++
   @ nl, 4 SAY "         "       GET Quot->Info9
     READ
   Quot->GoodSent := Quot->GoodSent+nsentqty
   UNLOCK
   
RETURN mpartnum

****------- End QFactPrice

**-------------------------------------------------------------------

FUNCTION QFactEdit( mcodeno )
 
mpartnum := SPACE( 20 )
mcontinue = "Y"
DO WHILE mcontinue = "Y"
   aPart_ :={}
   nrecno:= ntotal := 0
   nweight := 0
   SELECT Quot
   GOTO TOP
   SEEK mcodeno
   DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
      IF Quot->Invno != SPACE( 6 )
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF Quot->BranchId != cbranchId
         SKIP ALIAS Quot
         LOOP
      ENDIF
      SELECT Part
      SEEK Quot->Partnum
      nweight := nweight+( Quot->GoodSent*Part->Weight )
      SELECT Quot
      ntotal += Quot->Qty*Quot->Amount
      AADD( aPart_,SUBSTR( Quot->Partnum,1, 9 );
           +" "+SUBSTR( Part->Desc,1,24 );
           +" "+STR( Quot->OrgQty,5 );
           +" "+STR( Quot->Qty,5 );
           +" "+STR( Quot->GoodSent,5 );
           +" "+SUBSTR( Quot->Ordnum,1, 8 );
           +" "+DTOC( Quot->DbDate );
           +" "+Quot->Faxno;
           +"          "+STR( RECNO(),6 ) )
      SKIP ALIAS Quot
   ENDDO
   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
   @  1, 4      SAY TRIM( Name->Name )
   @  1,COL()+2 SAY TRIM( Name->Called )
   @  1,COL()+1 SAY TRIM( Name->Famname )
   @  1,COL()+2 SAY cbranchId                  COLOR "G+"
   @  1,COL()+2 SAY "Weight"                   COLOR "G+"
   @  1,COL()+2 SAY nweight PICTURE "9,999.99" COLOR "G+"
   @  1,COL()+1 SAY "kg"                       COLOR "G+"
***   @  1,COL()+2 SAY ntotal PICTURE "$999,999.99"
   DISPBOX( 3, 1, 23,79, 2 )
   @  23, 60    SAY "Weight"                   COLOR "G+"
   @  23,COL()+2 SAY nweight PICTURE "9,999.99" COLOR "G+"
   @  23,COL()+1 SAY "kg  "                     COLOR "G+"
   @  3,38 SAY " Order  Out/S  Inv Qty " 
   cfaxno     := SPACE( 8 )
   quotcodeno := SPACE( 8 )
   IF !EMPTY( aPart_ )
      ASORT( aPart_,,,{ | x,y | x < y } )
      anum := ACHOICE( 4, 3, 22,78,aPart_,,"AFUNC" )
      IF LASTKEY() == 27
         RETURN( mcodeno )
      ENDIF
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      SELECT Quot
      GOTO nrecno
      mpartnum   := Quot->Partnum
      cfaxno     := Quot->Faxno
      dDbdate    := Quot->DbDate
      quotcodeno := Quot->Codeno
      SELECT Part
      SEEK mpartnum
   ENDIF
   SCROLL(  15, 0, 24,80 )
   DISPBOX( 15, 1, 24,79, 2 )
    QFactPrice( @mpartnum )
    QFactEdit( @mcodeno )
****        LOOP
   mcontinue = "N"
ENDDO                       // mcontinue

RETURN( mpartnum )

***-----End of QFactEdit()

**-------------------------------------------------------------------

FUNCTION WoHouCost( mcodeno )

mcontinue := "Y"
DO WHILE mcontinue == "Y"
   SCROLL()   
   SELECT Quot
   SET ORDER TO 2
   GOTO TOP
   SEEK mcodeno
   @  0, 2 SAY mcodeno
   @  0,20 SAY Name->Name
   @  1, 6 SAY Quot->Info
   @  1,61 SAY "W/O # "+Quot->Faxno
   cfaxno := Quot->Faxno
   aPart_ := {}
   anum   := {}
   DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
      IF cbranchId != SPACE( 2 )
         IF Quot->BranchId != cbranchId
            SKIP ALIAS Quot
            LOOP
         ENDIF
      ENDIF
      IF Quot->Invno != SPACE( 6 )
         SKIP ALIAS Quot
         LOOP
      ENDIF
      nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
      nqty1:= nqty2:= nqty3:= nqty4 := 0
      nequ1:= nequ2:= nequ3:= nequ4 := 0
      nquot := Quot->Qty
      mmod1 := TRIM( Quot->Partnum )
      SELECT Part
      SEEK Quot->Partnum
      AADD( aPart_,STR( nquot, 9, 2 );
                   +" "+STR( Part->Trade, 8, 2 );
                   +" "+SUBSTR( Part->Desc, 1,30 );
                   +" "+SUBSTR( Part->Partnum, 1,16 );
                   +" "+Quot->Faxno;
                   +"          "+STR( nequ1 ) )         // So Can't Find
      SELECT Equ
      GOTO TOP
      SET EXACT ON
      SEEK mmod1
      IF FOUND()   
   DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
***      AADD( aPart_," " )
      nqty1 := nquot*Equ->PartQty
      SELECT Part
      SEEK Equ->Partnum
      SELECT Equ
      AADD( aPart_,".   "+SUBSTR( Equ->Modcode, 1,15 );
                   +" "+STR( nqty1, 9, 3 );
                   +" "+SUBSTR( Part->Desc, 1,29 );
                   +" "+STR( Equ->Partqty, 8, 3 );
                   +" "+STR( Part->Trade, 8, 2 );
                   +"        "+STR( RECNO(),6 ) )
      SELECT Equ
      mmod2 := TRIM( Equ->Partnum )
      nrecno2 := RECNO() 
      GOTO TOP
      SEEK mmod2
      IF FOUND()   
***         AADD( aPart_," " )
         DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
            nqty2 := Equ->PartQty
            nequ2 := ( nqty2*nqty1 )*nquot
            SELECT Part
            SEEK Equ->Partnum
      SELECT Equ
      AADD( aPart_,"..  "+SUBSTR( Equ->Modcode, 1,15 );
                   +" "+STR( nequ2, 9, 3 );
                   +" "+SUBSTR( Part->Desc, 1,29 );
                   +" "+STR( Equ->Partqty, 8, 3 );
                   +" "+STR( Part->Trade, 8, 2 );
                   +"        "+STR( RECNO(),6 ) )

      SELECT Equ
      mmod3 := TRIM( Equ->Partnum )
      nrecno3 := RECNO() 
      GOTO TOP
      SEEK mmod3
      IF FOUND()   
***         AADD( aPart_," " )
         DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
            nqty3 := Equ->PartQty
            nequ3 := (( nqty3*nqty2 )*nqty1 )*nquot
      SELECT Part
      SEEK Equ->Partnum
      SELECT Equ
      AADD( aPart_,"... "+SUBSTR( Equ->Modcode, 1,15 );
                   +" "+STR( nequ3, 9, 3 );
                   +" "+SUBSTR( Part->Desc, 1,29 );
                   +" "+STR( Equ->Partqty, 8, 3 );
                   +" "+STR( Part->Trade, 8, 2 );
                   +"        "+STR( RECNO(),6 ) )
         SELECT Equ
         mmod4   := TRIM( Equ->Partnum )
         nrecno4 := RECNO()
         GOTO TOP
         SEEK mmod4
         IF FOUND()
***            AADD( aPart_," " )
            DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
               nqty4 := Equ->PartQty
               nequ4 := ((( nqty4*nqty3 )*nqty2 )*nqty1 )*nquot
      SELECT Part
      SEEK Equ->Partnum
      SELECT Equ
      AADD( aPart_,"...."+SUBSTR( Equ->Modcode, 1,15 );
                   +" "+STR( nequ4, 9, 3 );
                   +" "+SUBSTR( Part->Desc, 1,29 );
                   +" "+STR( Equ->Partqty, 8, 3 );
                   +" "+STR( Part->Trade, 8, 2 );
                   +"        "+STR( RECNO(),6 ) )
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
      ENDIF                         // Found mmod2
            SELECT Equ
            GOTO nrecno2
            SKIP ALIAS Equ
            ENDDO                       //   mmod1 EOF()
         ENDIF                          // Found mmod1
         SET EXACT OFF      
      SELECT Quot
      SKIP ALIAS Quot
      AADD( aPart_," " )
   ENDDO                            //   EOF() Quot
      DISPBOX(  2, 1, 24,79, 2 )
      if !EMPTY( aPart_ )
         @  2,60 SAY "   Qty       Cost  "
  ***      ASORT( aPart_,,,{ | x,y | x < y } )
        anum := ACHOICE( 3, 2, 23,78, aPart_,,"AFUNC" )
        IF LASTKEY() == 27
           EXIT
        ENDIF
        nrecno := VAL( RIGHT( aPart_[anum],6 ) )
        SELECT Equ
        IF nrecno != 0
           GOTO nrecno
          ELSE
           GOTO nrecno2
        ENDIF 
        mmodcode := Equ->ModCode
        SET EXACT OFF
        SELECT EquDesc
        GOTO TOP
        SEEK Equ->Modcode
        IF FOUND()
           EquSearch( @mmodcode )                        // XLF_Equ3
        ENDIF                   // FOUND                                              // mcontinue
      ENDIF
    mcontinue := "N" 
ENDDO

SELECT Quot
SET ORDER TO 1

RETURN( mcodeno )

******* End of WoCost()

***-------------------------------------------------------------------

FUNCTION QPuoLook( cbranchId )

aPart_ :={}
SELECT Quot
SET ORDER TO 1
GOTO TOP
IF LASTREC() != 0
   SEEK mcodeno
   DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
      IF Quot->Invno != SPACE( 6 )
         IF Quot->Invno != "9    " 
             SKIP ALIAS Quot
             LOOP
         ENDIF
      ENDIF
      IF cbranchId != SPACE( 2 )
         IF Quot->BranchId != cbranchId
            SKIP ALIAS Quot
            LOOP
         ENDIF
      ENDIF
      mpartnum := Quot->Partnum
      SELECT Part
      SEEK mpartnum
      SELECT Quot
      AADD( aPart_,SUBSTR( Part->Partnum,1, 6 );
           +" "+SUBSTR( Part->Desc,1,12 );
           +" "+STR( Quot->OrgQty,5 );
           +" "+STR( Quot->Qty,5 );
           +" "+STR( Quot->GoodSent,5 );
           +" "+STR( Quot->Amount,8, 2 );
           +" "+STR( Quot->Discount,5 );
           +" "+SUBSTR( Quot->Ordnum,1, 5 );
           +" "+DTOC( DbDate );
           +" "+Quot->BranchId;
           +"      "+STR( RECNO(),6 ) )
      SKIP ALIAS Quot
   ENDDO
   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
   @  1, 4      SAY TRIM( Name->Name )
   @  1,COL()+2 SAY TRIM( Name->Called )
   @  1,COL()+1 SAY TRIM( Name->Famname )
   @  1,COL()+2 SAY cbranchId                       COLOR "G+"
   DISPBOX( 3, 1, 23,79, 2 )
   IF !EMPTY( aPart_ )
      @  3,24 SAY " Order Out  Inv "
      ASORT( aPart_,,,{ | x,y | x < y } )
***      @  3,00 SAY " "
****      AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " ),QQOUT(A),Breakpoint() } )
      anum := ACHOICE( 4, 3, 22,78,aPart_,,"AFUNC" )
      IF LASTKEY() == 27
         RETURN( mcodeno )
      ENDIF
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      SELECT Quot
      GOTO nrecno
      mcodeno    := Quot->Codeno
      mpartnum   := Quot->Partnum
      cfaxno     := Quot->Faxno
      dDbdate    := Quot->DbDate
      quotcodeno := Quot->Codeno
   ENDIF 
ENDIF
RETURN

****---- End of QPuoLook()

**-------------------------------------------------------------------

FUNCTION QPuotEdit( mcodeno )
 
mpartnum := SPACE( 20 )
mcontinue = "Y"
DO WHILE mcontinue = "Y"
   aPart_ :={}
   nrecno:= ntotal := 0
   SELECT Quot
   GOTO TOP
   SEEK mcodeno
   DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
      IF Quot->Invno != SPACE( 6 )
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF Quot->BranchId != cbranchId
         SKIP ALIAS Quot
         LOOP
      ENDIF
      SELECT Part
      SEEK Quot->Partnum
      SELECT Quot
      ntotal += Quot->Qty*Quot->Amount
      AADD( aPart_,SUBSTR( Quot->Partnum, 1, 8 );
           +" "+SUBSTR( Part->Desc,1,12 );
           +" "+STR( Quot->OrgQty,5 );
           +" "+STR( Quot->Qty,5 );
           +" "+STR( Quot->GoodSent,5 );
           +" "+STR( Quot->Amount,8, 2 );
           +" "+SUBSTR( Quot->Ordnum,1, 8 );
           +" "+DTOC( Quot->DbDate );
           +" "+Quot->Faxno;
           +"       "+STR( RECNO(),6 ) )
      SKIP ALIAS Quot
   ENDDO
   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
   @  1, 4      SAY TRIM( Name->Name )
   @  1,COL()+2 SAY TRIM( Name->Called )
   @  1,COL()+1 SAY TRIM( Name->Famname )
   @  1,COL()+2 SAY cbranchId                       COLOR "G+"
   @  1,COL()+2 SAY ntotal PICTURE "$999,999.99"
   DISPBOX( 3, 1, 24,79, 2 )
   @  3,25 SAY " Order  Out  Inv " 
   cfaxno     := SPACE( 8 )
   quotcodeno := SPACE( 8 )
   IF !EMPTY( aPart_ )
      ASORT( aPart_,,,{ | x,y | x < y } )
      anum := ACHOICE( 4, 3, 23,78,aPart_,,"AFUNC" )
      IF LASTKEY() == 27
         RETURN( mcodeno )
      ENDIF
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      SELECT Quot
      GOTO nrecno
      mpartnum   := Quot->Partnum
      cfaxno     := Quot->Faxno
      dDbdate    := Quot->DbDate
      quotcodeno := Quot->Codeno
      SELECT Part
      SEEK mpartnum
   ENDIF
   SCROLL(  12, 0, 24,80 )
   DISPBOX( 12, 1, 24,79, 2 )
   @ 12, 8      SAY " -- Ordered -- " 
   @ 14, 3      SAY TRIM( Quot->Partnum )
   @ 14,COL()+2 SAY Part->Desc COLOR "BG+" 
   @ 15, 3      SAY "Ordered"
   @ 15,COL()+1 SAY Quot->OrgQty
   @ 15,COL()+2 SAY "Outstand"
   @ 15,COL()+1 SAY Quot->Qty
   @ 15,COL()+2 SAY "To Invoice"
   @ 15,COL()+1 SAY Quot->GoodSent COLOR "BG+"
   @ 16, 3      SAY "Sent By"
   @ 16,COL()+2 SAY Quot->Sentby   COLOR "BG+"
   @ 16,COL()+2 SAY "Docket"
   @ 16,COL()+2 SAY Quot->Docno    COLOR "BG+"
   @ 16,COL()+2 SAY Quot->Faxno               COLOR "BG+"
   @ 17, 8      SAY TRIM( Quot->Info )+" "+TRIM( Quot->Info2 ) 
   @ 18, 8      SAY TRIM( Quot->Info3 )+" "+TRIM( Quot->Info4 ) 
   @ 19, 8      SAY TRIM( Quot->Info8 )+" "+TRIM( Quot->Info9 ) 
   SCROLL(  21, 0, 24,80 )
   DISPBOX( 21, 1, 24,79, 2 )
   nselect := 1
   @ 22, 4      PROMPT "1.Edit"
   @ 22,COL()+2 PROMPT "2.Add Part"
   @ 22,COL()+2 PROMPT "3.Delete"
   @ 22,COL()+2 PROMPT "4.Another"

   @ 22,COL()+2 PROMPT "5.Module"
   @ 22,COL()+2 PROMPT "6.Print"
   @ 22,COL()+2 PROMPT "7.Part"
   @ 22,COL()+2 PROMPT "8.Cost"
   MENU TO nselect
   DO CASE
     CASE LASTKEY() == 27
        RETURN( mcodeno )  

     CASE nselect == 1              // Edit
         QPuotPrice( @mpartnum )
         QPuotEdit( @mcodeno )
        LOOP

     CASE nselect == 2              // Add Part
          quotcodeno := SPACE( 8 )
          mpartnum := SPACE( 20 )
           QPuotPAdd( @mpartnum )                 // BELOW
          LOOP

     CASE nselect == 3              // Delete
         SELECT Quot
          ApRLock( 3 )
         DELETE
         UNLOCK
         mcontinue := "Y" 
         LOOP 
     CASE nselect == 4              // Another
         tempscrn := SAVESCREEN( 0, 0, 24,80 )
          QPuotEdit( @mcodeno )                    // QuoHouse
         RESTSCREEN(  0, 0, 24,80,tempscrn )
         LOOP
      CASE nselect == 5              // Module
         mmodcode := TRIM( mpartnum )
          EquModule( @mmodcode )                  // XLF_Quot               
         mcontinue := "Y"
         LOOP         
     CASE nselect == 6                  // Print
         tempscrn := SAVESCREEN( 0, 0, 24,80 )
          cfaxno := Quot->Faxno
          QPuotindi( @mcodeno, cfaxno )           // QuotPart 
         RESTSCREEN(  0, 0, 24,80,tempscrn )
         mcontinue := "Y" 
         LOOP
     CASE nselect == 7                  // Part                     
        tempscrn := SAVESCREEN( 0, 0, 24,80 )
        mpartnum := Part->Partnum 
        quotcodeno := Name->Codeno
        cedit := "N"                            // N = Total Stock   
          ProfQty( cedit )                        // CWPPart
        SELECT Name
        SEEK quotcodeno
        mcodeno := Name->Codeno
        RESTSCREEN(  0, 0, 24,80,tempscrn )
        mcontinue := "Y" 
        LOOP

      CASE nselect == 8             // Cost
        mcodeno := Name->Codeno
          WoHouCost( mcodeno )                        // QuoHouse 
        mcontinue := "Y" 
        LOOP
   ENDCASE
   mcontinue = "N"
ENDDO                       // mcontinue
RETURN( mpartnum )

***-----End of QPuotEdit()

*****------------------- END OF File CHRIORD.PRG