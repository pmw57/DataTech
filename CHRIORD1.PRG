***  JoKir09  22-10-11 07:28:55 

/*  Program.....:              CHRIORD1.PRG
    Author......: J.Kirby
    Date........: 01/09/1993   // 16/08/2006
    Funtions....: OrdFrmChr, OrdList, OrderTot, QuotOut, OrdLook, Ordchkndx
                  Ordreindx, Orderfrm, Setprnt
*/

FUNCTION Orderfrm()

SCROLL()

  Setprnt()

IF mwhere = "P"
  SET DEVICE TO PRINT
***  SET MARGIN TO 3
  nl  := 120
  npl := 51
 ELSE
  nl  := 1
  npl := 23
ENDIF                       // mwhere
  SELECT Orders
  SET ORDER TO 2
  SEEK mordnum                             // ORDERS
  morderno := Orders->Codeno
  mdat     := Orders->Date                   // Easier to get this here
  mdat     := DTOC(mdat)
  nweight  := 0
  DO WHILE Orders->( !EOF() )
    IF nl > npl
     IF mwhere = "P"
      SELECT Name
      SEEK mcodeno
      @  0,12 SAY TRIM( Orders->Jobnum )+" PURCHASE ORDER #  ";
                   +SUBSTR( Orders->Psno, 7, 2 )+" "+mordnum
      @  0,54 SAY STR( DAY( DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR( DATE() ),5 )
      mcodeno := "OWN99999"             // So Orders can be from Standard Co
      SEEK mcodeno
      @  2, 4 SAY "From :"
      IF FOUND()
         @  2,11 SAY Name->Name
         @  3,11 SAY Name->Add1
         @  4,11 SAY Name->Add2
         @  5,11 SAY Name->Add3
         @  6,11 SAY Name->Add4+" "+Name->Zip
         @  7,11 SAY "Phone : "+ Name->Phone
***         @  7,37 SAY "Fax : "  + Name->Bphone
       ELSE  
         SELECT Control
         @  2,11 SAY Control->U_Name
         @  3,11 SAY Control->U_Add1
         @  4,11 SAY Control->U_Add2
         @  5,11 SAY Control->U_Add3
         @  6,11 SAY Control->U_Add4+" "+Control->U_Zip
         @  7,11 SAY "Phone : "+Control->U_Phone
***         @  7,37 SAY "Email : "???
      ENDIF                      // FOUND
      SELECT Name
      SEEK Orders->Codeno
      @  8, 0 SAY REPLICATE(".",70)
      @ 10,11 SAY Name->Name
      @ 11,11 SAY Name->Add1
      @ 11,48 SAY "PURCHASE ORDER # ";
                  +SUBSTR( Orders->Psno, 7, 2 )+" "+mordnum
      @ 12,11 SAY Name->Add2
      @ 13,11 SAY Name->Add3
      @ 13,40 SAY "Date "+mdat
      @ 14,11 SAY Name->Add4+" "+Name->Zip
      @ 15,11 SAY "Phone : " + Name->Phone
***      @ 15,37 SAY "Fax : "   + Name->Bphone
      @ 16, 0 SAY REPLICATE(".",70)
      @ 17,18 SAY "Description"
      @ 17,60 SAY "Order Qty"
      @ 18, 0 SAY REPLICATE("-",70)
      nl := 19
     ELSE
      WAIT
      @  0,15 SAY "PURCHASE ORDER # "+mordnum
      SCROLL()
      nl := 1
     ENDIF              // mwhere
    ENDIF                       // nl>npl 
    SELECT Orders
    IF Orders->Partnum != SPACE( 20 )
       ApRLock( 3 )
      ntotal   := 0
      mpartnum := Orders->Partnum
      Orders->P_flag := .T.
      UNLOCK
      SELECT Part
      SET ORDER TO 1                        // Partnum
      SEEK mpartnum
      SELECT Supl
      SET ORDER TO 1                        // Partnum+Codeno
      mseek := mpartnum+Orders->Codeno
      SEEK mseek
      IF FOUND()
         IF Supl->SuppId != SPACE( 16 )
            @ nl, 0 SAY "."+SUBSTR( Supl->SuppId, 1,15 )
           ELSE
            @ nl, 0 SAY SUBSTR( mpartnum, 1,16 )
         ENDIF
       ELSE
         IF SUBSTR( Part->Partnum, 1, 2 ) != "ZZ"
            @ nl, 0 SAY SUBSTR( Part->Partnum,1,16 )
         ENDIF
      ENDIF                             // FOUND  
      IF Orders->Detail1 != SPACE( 40 )
         @ nl,18 SAY SUBSTR( Orders->Detail1, 1,36 )
       ELSE
         @ nl,20 SAY "Supply as detailed below."
      ENDIF
      @ nl,55 SAY Orders->Partqty PICTURE "99,999.99"
***      IF Orders->Amount > 0
***         @ nl,65 SAY Orders->Amount  PICTURE "$99999.99"
***      ENDIF
      DO CASE
         CASE Part->Unit == "Mtr       "
            nl++
            @ nl,20 SAY "Order Length = "+STR( Orders->Length, 6, 2 );
                        +" "+Part->Unit
         CASE Part->Unit == "Sq Mtr    "
            @ nl,70 SAY "Sheets"
      ENDCASE
      nl++
      SELECT Orders
      IF Orders->Detail2 != SPACE( 40 )
         @ nl,10 SAY Orders->Detail2
         nl++ 
      ENDIF
      IF Orders->Detail3 != SPACE( 40 )
         @ nl,10 SAY Orders->Detail3
         nl++ 
      ENDIF
      IF Orders->Detail4 != SPACE( 40 )
         @ nl,10 SAY Orders->Detail4
         nl++ 
      ENDIF
    ENDIF                   // Orders
    SKIP ALIAS Orders
    IF Orders->Ordnum != mordnum
      EXIT
    ENDIF
  ENDDO                             // Orders EOF
  IF mwhere = "P"
     @  52, 0 SAY Message->Order1
     @  53, 0 SAY Message->Order2
***     @  43,61 SAY ntotal PICTURE "$999,999.99"
     @  54, 0 SAY Message->Order3
     @  55, 0 SAY Message->Order4
     @  56, 0 SAY Message->Order5
     @  57, 0 SAY Message->Order6
     EJECT
  ELSE
     WAIT
     SCROLL()
     nl := 1 
    IF nl > 18
       WAIT
    ENDIF
    mok := "N"
    DO WHILE mok = "N"
       mok := ApReadN()
    ENDDO
  ENDIF
SCROLL()
SET MARGIN TO 0
SELECT QuotStk
SET ORDER TO 1

RETURN NIL

***----------- End OrderFrm()

**-------------------------------------------------------------------

FUNCTION OrdList()

cjsno := "      "
mptot:= msum:= nQty := 0
mpartnum := SPACE( 20 )
mcontinue := "Y"
DO WHILE mcontinue == "Y"

   SELECT Orders
   SET ORDER TO 3                           // Codeno
   SCROLL()
   @ 23,50 SAY "F2 To View ALL Orders" COLOR "BG+"
   mcodeno := SPACE( 8 )
   nrecno   := 0
   anum     := {}
   aPart_   := {}
   nll      := 19
   SELECT Orders
   SET ORDER TO 3                           // Codeno+Ordnum
   GOTO TOP
   IF LASTREC() != 0
      DO WHILE Orders->( !EOF() )
          IF SUBSTR( Orders->Codeno, 1, 2 ) = "A "
             SKIP ALIAS Orders
             LOOP
          ENDIF
          IF Orders->Codeno = mcodeno
             SKIP ALIAS Orders
             LOOP
          ENDIF
          SELECT Name
          SEEK Orders->Codeno
          IF !FOUND()
             @  18,60      SAY "No Name in File" COLOR "BG+"
             @ nll,60      SAY Orders->Codeno    COLOR "BG+"
             @ nll,COL()+1 SAY Orders->Ordnum    COLOR "BG+"
             nll++
             mcodeno := Orders->Codeno
             SKIP ALIAS Orders
             LOOP
          ENDIF
          SELECT Orders
          mcodeno := Name->Codeno
          AADD( aPart_,Name->Name;
              +"       "+STR( RECNO(),6 ) )
          SKIP ALIAS Orders
      ENDDO                          // EOF()
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL(   0, 0, 24,40 )
         DISPBOX(  0, 1, 24,40, 2 )
         anum   := ACHOICE( 1, 3, 23,39, aPart_,,"AFUNC" )    
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         mcodeno := Orders->Codeno
         SELECT Name
         SEEK mcodeno
         IF LASTKEY() == -1
           SELECT Orders
           SET ORDER TO 3                   // Codeno+Ordnum
              nrecno := 0
              aPart_ := {}
              anum   := {}
              DO WHILE Orders->( !EOF() )
                 SELECT Part
                 SET ORDER TO 1
                 SEEK Orders->Partnum
                 cdesc := SUBSTR( Orders->Detail1, 1,20 )
                 SELECT Orders
                 IF cdesc = SPACE( 30 )
                    cdesc := SUBSTR( Part->Desc, 1,20 ) 
                 ENDIF 
                 IF cdesc = SPACE( 30 )
                    cdesc := SUBSTR( Orders->Detail2, 1,2 )
                 ENDIF 
               AADD( aPart_,Orders->Ordnum;
                  +" "+Orders->Codeno;
                  +" "+DTOC( Orders->Date );
                  +" "+SUBSTR( Part->Partnum, 1, 8 );
                  +" "+cdesc;
                  +" "+STR( Orders->PartQty, 8, 2 );
                  +" "+STR( Orders->Amount, 8, 2 );
                  +"         "+STR( RECNO(),6 ) )
                 SKIP ALIAS Orders
             ENDDO                  // Orders
             IF !EMPTY( aPart_ )
                SCROLL()
                DISPBOX(  0, 1, 24,79, 2 )
                @ 0,55 SAY "  Order     IN  "
                ASORT( aPart_,,,{ | x,y | x < y } )
                anum := ACHOICE(  1, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
                nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
                GOTO nrecno
                IF LASTKEY() = 27 
                   RETURN NIL
                ENDIF
                mcodeno := Orders->Codeno
                SELECT Name
                SEEK mcodeno
             ENDIF                        // Empty
         ENDIF
         IF LASTKEY() == 27 
            RETURN NIL
         ENDIF
      ENDIF
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @  1,10 SAY Name->Name
      mcodeno := Name->Codeno
    ENDIF                        // LastRec
    mordnum := SPACE( 4 )
           SELECT Orders
           SET ORDER TO 3                   // Codeno+Ordnum
           SEEK Name->Codeno
           IF FOUND()
              cdesc  := SPACE( 30 )
              cunit  := SPACE( 10 )
              nrecno := 0
              aPart_ := {}
              DO WHILE Orders->Codeno == Name->Codeno .AND. Orders->( !EOF() )
                 SELECT Part
                 SET ORDER TO 1
                 SEEK Orders->Partnum
                 cdesc := SUBSTR( Orders->Detail1, 1,20 )
                 SELECT Orders
                 IF cdesc = SPACE( 20 )
                    cdesc := SUBSTR( Part->Desc, 1,20 )
                 ENDIF 
                 IF cdesc = SPACE( 30 )
                    cdesc := SUBSTR( Orders->Detail2, 1,20 )
                 ENDIF 
               DO CASE
                  CASE Orders->Length > 0
                     cunit := "Lengths   "
                  CASE Part->Unit = "Sq Mtrs   "
                     cunit := "Sheets    "
                  OTHERWISE
                     cunit := Part->Unit 
               ENDCASE
               AADD( aPart_,Orders->Ordnum;
                  +" "+SUBSTR( Part->Partnum, 1, 8 );
                  +" "+cdesc;
                  +" "+DTOC( Orders->Date );
                  +" "+STR( Orders->PartQty, 8, 2 );
                  +" "+STR( Orders->Amount, 8, 2 );
                  +" "+TRIM( cunit );
                  +"        "+STR( RECNO(),6 ) )
                 SKIP ALIAS Orders
             ENDDO                  // Orders
             IF !EMPTY( aPart_ )
                @ 1, 5 SAY Name->Name
                SCROLL(   3, 0, 24,80 )
                DISPBOX(  3, 1, 24,79, 2 )
                @  3, 3 SAY " - Parts On Order -" COLOR "G+"
                @  3,50 SAY " -- Ordered Qty  Received -- "
      ASORT( aPart_,,,{ | x,y | x < y } )
      anum   := ACHOICE(  4, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
      nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
   ENDIF
   GOTO nrecno
   mordnum := Orders->Ordnum
   SET ORDER TO 1               // Partnum
         ENDIF                                // FOUND()  
   SCROLL(  21, 0, 24,80 )
   DISPBOX( 21, 1, 24,79, 2 )
   @ 22,10      SAY "Order #" GET mordnum PICTURE "@KX"
    READ
   IF LASTKEY() == 27
      LOOP
***      RETURN NIL
   ENDIF
    
     Printsel( nl )

    @  1, 9 SAY "Outstanding Orders"
    @  1,68 SAY DATE()
    @  2,56 SAY "Received"
    @  2,70 SAY "Out"
    nl := 3
    ntotal  := 0
    SELECT Orders
    SET ORDER TO 2          // Ordnum
    GOTO TOP
    SEEK mordnum
    SELECT Name
    SEEK Orders->Codeno
    @ nl, 2 SAY Name->Name+" O/N # "+mordnum
    nl++
    SELECT Orders 
    DO WHILE Orders->Ordnum = mordnum .AND. Orders->( !EOF() )
       IF Orders->Codeno == "A       "
          SKIP ALIAS Orders 
          LOOP
       ENDIF
          IF Orders->Codeno != mcodeno
             SKIP ALIAS Orders 
             LOOP
          ENDIF
       IF nl > npl
          IF mwhere = "P"
             EJECT
            ELSE
             WAIT
             SCROLL()
          ENDIF
          @  1, 9 SAY "Outstanding Orders"
          @  1,68 SAY DATE()
          @  2,56 SAY "Received"
          @  2,70 SAY "Out"
          nl := 3
       ENDIF
      @ nl, 0 SAY SUBSTR( Orders->Partnum, 1,16 )
      SELECT Supl
      SET ORDER TO 1                        // Partnum+Codeno
      SEEK Orders->Partnum+Orders->Codeno
      IF FOUND()
         IF TRIM( Supl->SuppId ) != TRIM( Orders->Partnum )
            @ nl,20 SAY Supl->SuppId 
         ENDIF 
      ENDIF
      @ nl,45 SAY Part->Unit    
      @ nl,54 SAY Orders->PartIn PICTURE "999,999.99"
      @ nl,64 SAY ( Orders->PartQty-Orders->PartIn ) PICTURE "999,999.99"
      SELECT Part
      SET ORDER TO 1                        // Partnum
      SEEK Orders->Partnum
      ntotal += ( Part->Trade*Orders->PartQty )
      SELECT Orders
      nl++
      IF Orders->Psno != SPACE( 20 )
         @ nl, 2 SAY Orders->Psno  
      ENDIF
      IF Orders->Detail1 != SPACE( 40 )
         @ nl,22 SAY Orders->Detail1  
      ENDIF
      IF Orders->Detail2 != SPACE( 40 )
         nl++
         @ nl,22 SAY Orders->Detail2  
      ENDIF
      IF Orders->Detail3 != SPACE( 40 )
         nl++
         @ nl,22 SAY Orders->Detail3  
      ENDIF
      nl++
      SKIP ALIAS Orders 
   ENDDO                           // EOF()
   nl++
   @ nl,25 SAY "Order Cost ="
   @ nl,40 SAY ntotal PICTURE "$999,999.99"
   IF mwhere = "P"
      EndPrint()
    ELSE
      WAIT
   ENDIF
   mcontinue := ApGetN( TRIM( Message->Another )+" Order" )
ENDDO

RETURN NIL

***--- End OrdList()

****---------------------------------------------------------------------------

FUNCTION HouseTot( )

mpTot := 0
manother := "Y"
DO WHILE manother == "Y"
      SELECT QuotStk
      SET ORDER TO 2 
      GOTO TOP
      nrecno := 0
      aPart_ := {}
      IF LASTREC() != 0
         DO WHILE QuotStk->( !EOF() )
            IF QuotStk->Required <= 0
               SKIP ALIAS QuotStk
               LOOP
            ENDIF
            SELECT Part
            SEEK QuotStk->Partnum
            SELECT QuotStk
            IF Part->Boughtout != "N"
               SKIP ALIAS QuotStk
               LOOP
            ENDIF
            mpartnum := Part->Partnum
            minvno := QuotStk->Invno
            SELECT QuotStk
            SET ORDER TO 2
            nQty := 0
            SEEK mpartnum 
            DO WHILE QuotStk->Partnum = mpartnum .AND. QuotStk->( !EOF() )
               nQty += QuotStk->Required-QuotStk->Received
               SKIP ALIAS QuotStk
            ENDDO
            SELECT Part
             ApRLock( 3 )
            Part->QuotQty := nQty
            UNLOCK 
            AADD( aPart_,SUBSTR( Part->Desc, 1,34 );
                    +" "+SUBSTR( Part->Partnum, 1,16 );
                    +" "+STR( Part->QuotQty, 9,2 );
                    +" "+STR( Part->Instock, 9, 2 );
                    +"     "+STR( RECNO(), 6 ) )
           SELECT QuotStk
         ENDDO                  // QuotStk
      ENDIF
         IF !EMPTY( aPart_ )
            SCROLL()
            DISPBOX(  0, 1, 2,79, 2 )
            @  1,10 SAY "IN HOUSE All Job Cards"
            @  3, 3 SAY "Description                         Part                Required  Instock"
            SCROLL(   4, 0, 24,80 )
            DISPBOX(  4, 1, 24,79, 2 )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE(  5, 3, 23,77,aPart_,"","AFUNC")  // AFUNC in XLP_Init
            nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
            SELECT Part
            GOTO nrecno
            mpartnum := Part->Partnum
            SCROLL(  18, 0, 24,80 )
            DISPBOX( 18, 1, 21,79, 2 )
            @ 19, 3 SAY TRIM( Part->Partnum )+" "+TRIM( Part->Desc);
                        +" "+STR( Part->QuotQty, 10, 2 )+" "+Part->Codeno
            mcodeno := Part->Codeno
            SELECT Name
            SEEK mcodeno
            DO WHILE !FOUND()
               SAVE SCREEN TO holdscrn
                 Namerank( @mcodeno )                       // XlF_Name
                IF LASTKEY() == 27
                   RETURN
                ENDIF
                SELECT Name
                SEEK mcodeno
               RESTORE SCREEN FROM holdscrn
               SELECT Part 
                 ApFLock( 3 )
               Part->Codeno := Name->Codeno
               UNLOCK
            ENDDO   
      ENDIF                      // !EMPTY
      DISPBOX( 22, 1, 24,79, 2 )
      nselect := 1
      @ 23,10      PROMPT "Edit Part"
      @ 23,COL()+3 PROMPT "Another Part"
      @ 23,COL()+3 PROMPT "Print List"
      @ 23,COL()+3 PROMPT "Exit"
      MENU TO nselect
      DO CASE
         CASE nselect = 4 .OR. LASTKEY() == 27
            SELECT Quot
            SET INDEX TO QuotInd 
            RETURN NIL
         CASE nselect == 2
            manother = "Y"
            LOOP
         CASE nselect == 1
           ScrnOrd  := SAVESCREEN( 0, 0, 24,80 )
           mpartnum := Part->Partnum
           SCROLL( 3, 0, 24,80 )
           DISPBOX( 3, 1, 24,79, 2 )
           SELECT Part
           SET ORDER TO 1
           SEEK mpartnum
           mQty    := 0
           nlength := 0
           ncsarea := 0
           nlinm:= nvol:= nlen:= 0
   @  1, 5 SAY Part->Desc+" "+TRIM( Part->Partnum )+" "+Part->Unit COLOR "BG+"
   nl := 4
   @  nl, 5      SAY "In Stock"
   @  nl,COL()+1 SAY Part->Instock PICTURE "99,999.99" COLOR "G+"
   @  nl,COL()+1 SAY "Length Mtr"
   @  nl,COL()+1 SAY Part->Length  PICTURE "999.999"
   @  nl,COL()+1 SAY "Width mm"
   @  nl,COL()+1 SAY Part->Width   PICTURE "999.999"
   @  nl,COL()+2 SAY Part->Unit
   nl+=2
   SELECT Part
    ApRLock( 3 )
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
   @ nl, 5      PROMPT "Each  "
   @ nl,COL()+2 PROMPT "Mtr   "
   @ nl,COL()+2 PROMPT "Sq Mtr"
   @ nl,COL()+2 PROMPT "Cu Mtr"
   MENU TO nselect
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
   nl+=2
  DO CASE
     CASE Part->Unit = "Sq Mtr    "
        nwidth    := Part->Width/1000
        SELECT Part
         ApRLock( 3 )
        nvol  := Part->Instock/( nwidth*Part->Length ) 
        ncost := Part->Trade*( nwidth*Part->Length )
        ndiscount := 0
        @  nl, 6      SAY "Width in Mtr"  GET nwidth
        @  nl,COL()+2 SAY "Length in Mtr" GET Part->Length
        nl+=2
        @  nl, 6      SAY "Sheets in Stock"  GET nvol      PICTURE "999999.99"
         READ
        mQty  := ( Part->Length*nwidth )*nvol
        @ nl,42 SAY "Sq Mtrs "+STR( mQty, 8, 2 )
        IF LASTKEY() == 27
           UNLOCK
           RETURN
        ENDIF
        Part->Width := nwidth*1000   // Convert to mm
        UNLOCK
        
     CASE Part->Unit = "Cu Mtr    "
        nl++
        @  nl, 5      SAY "Volume Cu/M"   GET nvol   PICTURE "999.999"
        @  nl,COL()+2 SAY "Rate per Cu/M" GET nrate  PICTURE "999.99"
         READ
        IF LASTKEY() == 27
           RETURN
        ENDIF
        ** Calculate cross-section area in square metres
        ncsarea := ( Part->Width*Part->Thick )/1000000
        ** Calculate linear metres
        nlen := nvol/ncsarea
        ** Calculate cost per linear metre.
        ** Must allow for variable volume here  (Try various volumes for
        **   same width & thickness - cost should be constant)
        ncost=( nrate/nlen )*nvol
        ** Wastage Factor 10%
        ** Show total linear & cost
       ncost := ncost*1.1
       ncsarea := ( Part->Width*Part->Thick ) // cross sectional area in sq mm
       ncsarea := ncsarea/1000000             // cross sectional area in sq metres
       ** ( Could combine above two lines into one calculation )
       mQty := nvol/ncsarea         // length in metres
       nl+=2
       @  nl, 5      SAY "Per Mtr+10% "+STR( ncost,6,3 ) COLOR "G+"
       @  nl,COL()+1 SAY "Mtrs "+STR( nlen,5 ) COLOR "G+"
       @  nl,COL()+1 SAY "Length"   GET mQty      PICTURE "999999.99"
        READ
       IF LASTKEY() == 27
          RETURN
       ENDIF

     CASE Part->Unit = "Mtr       "                 // Linear Mtr
           SELECT Part
            ApRLock( 3 )
           mQty := Part->Instock/Part->Length
           @ nl, 5      SAY "Length Each Mtr"  GET Part->Length PICTURE "9999.999" 
           @ nl,COL()+2 SAY "Qty of Lengths"   GET mQty         PICTURE "99999.99" 
            READ
           UNLOCK 
           mQty := Part->Length*mQty
           nl+=2
           @ nl, 5      SAY "Mtr Qty"
           @ nl,COL()+2 SAY mQty PICTURE "99,999.99" COLOR "G+"
           IF LASTKEY() == 27
              RETURN
           ENDIF

   CASE Part->Unit = "Each      "
        mQty := Part->Instock
        @  nl, 5 SAY "In Stock Qty" GET mQty PICTURE "999999.99"
         READ
        IF LASTKEY() == 27
          RETURN
        ENDIF

    OTHERWISE
       mQty := Part->Instock
       @  nl, 5 SAY "In Stock Qty" GET mQty PICTURE "999999.99"
        READ
      IF LASTKEY() == 27
         RETURN
      ENDIF
ENDCASE
SELECT Part
 ApRLock( 3 )
nselect := 1
DO CASE 
   CASE Part->Boughtout = "Y"
        nselect := 1
   CASE Part->Boughtout = "N"
        nselect := 2
ENDCASE
nl+=2
@ nl, 5      PROMPT "Part Bought Out"
@ nl,COL()+2 PROMPT "Own Manufacture"
MENU TO nselect
DO CASE
   CASE nselect == 1
        Part->Boughtout := "Y"
   CASE nselect == 2
        Part->Boughtout := "N"
ENDCASE 
   Part->Instock := mQty
UNLOCK
           RESTSCREEN(  0, 0, 24,80, ScrnOrd )
           manother = "Y"
           LOOP
  CASE nselect == 3
    Printsel()

   IF mwhere = "S"
      npl := 22
    ELSE
      npl := 62
   ENDIF 
   mpTot:= mSum := 0
      @  0, 0 SAY Control->U_Name+" Parts For ALL Job Cards"
      @  0,60 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
                 +STR(YEAR(DATE()),5)
      @  2, 0 SAY "Partnum             Desc"
      @  2,50 SAY "Out/QT    In Stock   From"
      nl := 4
      IF mwhere = "P"
         EndPrint()
       ELSE
         WAIT
       ENDIF 
       manother = "Y"
       LOOP
    ENDCASE 
       manother := "N"
ENDDO                       // manother
SELECT Quot
SET INDEX TO QuotInd 

RETURN

****--------- End HouseTot()

**-------------------------------------------------------------------

FUNCTION OrderTot( )

mpTot := 0
manother := "Y"
DO WHILE manother == "Y"
      SELECT QuotStk
      SET ORDER TO 2 
      GOTO TOP
      nrecno := 0
      aPart_ := {}
      IF LASTREC() != 0
         DO WHILE QuotStk->( !EOF() )
            IF QuotStk->Required = 0
               SKIP ALIAS QuotStk
               LOOP
            ENDIF
            IF SUBSTR( QuotStk->Partnum, 1, 2 ) = "ZZ"
               SKIP ALIAS QuotStk
               LOOP
            ENDIF
            SELECT Part
            SEEK QuotStk->Partnum
            SELECT QuotStk
            IF Part->Boughtout != "Y"
               SKIP ALIAS QuotStk
               LOOP
            ENDIF
            mpartnum := Part->Partnum
            SELECT Orders
            SET ORDER TO 1                            // Partnum index
            GOTO TOP
            SEEK mpartnum
            mptot:= mQty := 0
            IF FOUND()
               DO WHILE Orders->Partnum = mpartnum .AND. Orders->( !EOF() )
                  mptot += Orders->Partqty-Orders->QtyRec
                  SKIP ALIAS Orders
               ENDDO
            ENDIF
            minvno := QuotStk->Invno
            SELECT QuotStk
            SET ORDER TO 2
            nQty := 0
            SEEK mpartnum 
            DO WHILE QuotStk->Partnum = mpartnum .AND. QuotStk->( !EOF() )
               nQty += QuotStk->Required-QuotStk->Received
               SKIP ALIAS QuotStk
            ENDDO
            SELECT Part
             ApRLock( 3 )
            Part->ReqQty := nQty
            Part->Invno  := minvno
            UNLOCK 
            AADD( aPart_,SUBSTR( Part->Desc, 1,28 );
                    +" "+SUBSTR( Part->Partnum, 1,16 );
                    +" "+STR( Part->ReqQty, 9,2 );
                    +" "+STR( Part->Instock, 9, 2 );
                    +" "+STR( mptot, 9, 2 );
                    +"     "+STR( RECNO(), 6 ) )
           SELECT QuotStk
         ENDDO                  // QuotStk
      ENDIF
         IF !EMPTY( aPart_ )
            SCROLL()
            DISPBOX(  0, 1, 2,79, 2 )
            @  1,10 SAY "Parts Bought Out All Job Cards"
            SCROLL(   3, 0, 24,80 )
            DISPBOX(  3, 1, 24,79, 2 )
            @  3, 3 SAY " Description                                    Out/QT     Instock  Ordered "
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE(  4, 3, 23,77,aPart_,"","AFUNC")  // AFUNC in XLP_Init
            nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
            SELECT Part
            GOTO nrecno
            mpartnum := Part->Partnum
            SCROLL(  18, 0, 24,80 )
            DISPBOX( 18, 1, 21,79, 2 )
            @ 19, 3 SAY TRIM( Part->Partnum )+" "+TRIM( Part->Desc);
                        +" "+STR( Part->ReqQty, 10, 2 )+" "+Part->Codeno
            mcodeno := Part->Codeno
            SELECT Name
            SEEK mcodeno
            DO WHILE !FOUND()
               SAVE SCREEN TO holdscrn
                 Namerank( @mcodeno )                       // XlF_Name
                IF LASTKEY() == 27
                   RETURN
                ENDIF
                SELECT Name
                SEEK mcodeno
               RESTORE SCREEN FROM holdscrn
               SELECT Part 
                 ApFLock( 3 )
               Part->Codeno := Name->Codeno
               UNLOCK
            ENDDO   
      ENDIF                      // !EMPTY
      DISPBOX( 22, 1, 24,79, 2 )
      nselect := 1
      @ 23,10      PROMPT "Edit Part"
      @ 23,COL()+3 PROMPT "Another Part"
      @ 23,COL()+3 PROMPT "Print List"
      @ 23,COL()+3 PROMPT "Add Order"
      @ 23,COL()+3 PROMPT "Exit"
      MENU TO nselect
      DO CASE
         CASE nselect = 5 .OR. LASTKEY() == 27
            SELECT Quot
            SET INDEX TO QuotInd 
            RETURN NIL
         CASE nselect == 2
            manother = "Y"
            LOOP
         CASE nselect == 3
           OrderPrnt()                      // Below  
           manother = "Y"
           LOOP
         CASE nselect == 1
           ScrnOrd  := SAVESCREEN( 0, 0, 24,80 )
           mpartnum := Part->Partnum
           SCROLL( 3, 0, 24,80 )
           DISPBOX( 3, 1, 24,79, 2 )
           SELECT Orders
           SET ORDER TO 1                        // Partnum
           GOTO TOP
           SEEK mpartnum
           nTotal := 0
           IF FOUND()
              nll := 15
              DISPBOX( 14, 3, 22,45, 2 )
              @ 14,20 SAY " - Orders - " COLOR "BG+"
              DO WHILE Orders->Partnum = mpartnum .AND. Orders->( !EOF() )
                 @ nll, 5      SAY Orders->Ordnum
                 @ nll,COL()+1 SAY Orders->Partqty PICTURE "9,999.999" COLOR "G+"
                 @ nll,COL()+1 SAY Orders->QtyRec  PICTURE "9,999.999"
                 IF Orders->Length > 0
                    @ nll,COL()+1 SAY "Length"
                    @ nll,COL()+1 SAY Orders->Length  PICTURE "999.99"
                 ENDIF
                 nll++
                 nTotal += Orders->PartQty 
                 SKIP ALIAS Orders
              ENDDO
              @ 23, 5      SAY TRIM( mpartnum )+" Ordered" 
              @ 23,COL()+1 SAY nTotal PICTURE "9,999.99" COLOR "G+" 
           ENDIF                            // Found
           SELECT Part
           SET ORDER TO 1
           SEEK mpartnum
           mQty    := 0
           nlength := 0
           ncsarea := 0
           ndiscount:= ncost:= namount:= nlinm:= nrate:= nvol:= nlen:= 0
   @  1, 5 SAY Part->Desc+" "+TRIM( Part->Partnum )+" "+Part->Unit COLOR "BG+"
   nl := 4
   @  nl, 5      SAY "In Stock"
   @  nl,COL()+1 SAY Part->Instock PICTURE "99,999.99" COLOR "G+"
   @  nl,COL()+1 SAY "Length Mtr"
   @  nl,COL()+1 SAY Part->Length  PICTURE "999.999"
   @  nl,COL()+1 SAY "Width mm"
   @  nl,COL()+1 SAY Part->Width   PICTURE "999.999"
   @  nl,COL()+2 SAY Part->Unit
   nl+=2
   SELECT Part
    ApRLock( 3 )
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
   @ nl, 5      PROMPT "Each  "
   @ nl,COL()+2 PROMPT "Mtr   "
   @ nl,COL()+2 PROMPT "Sq Mtr"
   @ nl,COL()+2 PROMPT "Cu Mtr"
   MENU TO nselect
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
   nl+=2
  DO CASE
     CASE Part->Unit = "Sq Mtr    "
        nwidth    := Part->Width/1000
        SELECT Part
         ApRLock( 3 )
        nvol  := Part->Instock/( nwidth*Part->Length ) 
        ncost := Part->Trade*( nwidth*Part->Length )
        ndiscount := 0
        @  nl, 6      SAY "Width in Mtr"  GET nwidth
        @  nl,COL()+2 SAY "Length in Mtr" GET Part->Length
        nl+=2
        @  nl, 6      SAY "Sheets in Stock"  GET nvol      PICTURE "999999.99"
         READ
        mQty  := ( Part->Length*nwidth )*nvol
        @ nl,42 SAY "Sq Mtrs "+STR( mQty, 8, 2 )
        IF LASTKEY() == 27
           UNLOCK  
           RETURN
        ENDIF
        Part->Width := nwidth*1000   // Convert to mm
        UNLOCK
        
     CASE Part->Unit = "Cu Mtr    "
        nl++
        @  nl, 5      SAY "Volume Cu/M"   GET nvol   PICTURE "999.999"
        @  nl,COL()+2 SAY "Rate per Cu/M" GET nrate  PICTURE "999.99"
         READ
        IF LASTKEY() == 27
           RETURN
        ENDIF
        ** Calculate cross-section area in square metres
        ncsarea := ( Part->Width*Part->Thick )/1000000
        ** Calculate linear metres
        nlen := nvol/ncsarea
        ** Calculate cost per linear metre.
        ** Must allow for variable volume here  (Try various volumes for
        **   same width & thickness - cost should be constant)
        ncost=( nrate/nlen )*nvol
        ** Wastage Factor 10%
        ** Show total linear & cost
       ncost := ncost*1.1
       ncsarea := ( Part->Width*Part->Thick ) // cross sectional area in sq mm
       ncsarea := ncsarea/1000000             // cross sectional area in sq metres
       ** ( Could combine above two lines into one calculation )
       mQty := nvol/ncsarea         // length in metres
       nl+=2
       @  nl, 5      SAY "Per Mtr+10% "+STR( ncost,6,3 ) COLOR "G+"
       @  nl,COL()+1 SAY "Mtrs "+STR( nlen,5 ) COLOR "G+"
       @  nl,COL()+1 SAY "Length"   GET mQty      PICTURE "999999.99"
        READ
       IF LASTKEY() == 27
          RETURN
       ENDIF

     CASE Part->Unit = "Mtr       "                 // Linear Mtr
           SELECT Part
            ApRLock( 3 )
           mQty := Part->Instock/Part->Length
           @ nl, 5      SAY "Length Each Mtr"  GET Part->Length PICTURE "9999.999" 
           @ nl,COL()+2 SAY "Qty of Lengths"   GET mQty         PICTURE "99999.99" 
            READ
           UNLOCK 
           mQty := Part->Length*mQty
           nl+=2
           @ nl, 5      SAY "Mtr Qty"
           @ nl,COL()+2 SAY mQty PICTURE "99,999.99" COLOR "G+"
           IF LASTKEY() == 27
              RETURN
           ENDIF

   CASE Part->Unit = "Each      "
        mQty := Part->Instock
        @  nl, 5 SAY "In Stock Qty" GET mQty PICTURE "999999.99"
         READ
        IF LASTKEY() == 27
          RETURN
        ENDIF

    OTHERWISE
       mQty := Part->Instock
       @  nl, 5 SAY "In Stock Qty" GET mQty PICTURE "999999.99"
        READ
      IF LASTKEY() == 27
         RETURN
      ENDIF
ENDCASE
SELECT Part
 ApRLock( 3 )
nselect := 1
DO CASE 
   CASE Part->Boughtout = "Y"
        nselect := 1
   CASE Part->Boughtout = "N"
        nselect := 2
ENDCASE
nl+=2
@ nl, 5      PROMPT "Part Bought Out"
@ nl,COL()+2 PROMPT "Own Manufacture"
MENU TO nselect
DO CASE
   CASE nselect == 1
        Part->Boughtout := "Y"
   CASE nselect == 2
        Part->Boughtout := "N"
ENDCASE 
   Part->Instock := mQty
UNLOCK
           RESTSCREEN(  0, 0, 24,80, ScrnOrd )
           manother = "Y"
           LOOP
         CASE nselect = 4
           MenuB3()         // XLF_MenuB
***           OrdAdd( mcodeno )
           manother = "Y"
           LOOP
       ENDCASE 
       manother := "N"
ENDDO                       // manother
SELECT Quot
SET INDEX TO QuotInd 

RETURN

****--------- End OrderTot()

**-------------------------------------------------------------------

FUNCTION OrderPrnt()

    Printsel()

   IF mwhere = "S"
      npl := 22
    ELSE
      npl := 62
   ENDIF 
   mpTot:= mSum := 0
      @  0, 0 SAY Control->U_Name+" Parts For ALL Job Cards"
      @  0,60 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
                 +STR(YEAR(DATE()),5)
      @  2, 0 SAY "Partnum             Desc"
      @  2,44 SAY "Out/St   Ordered In Stock   From"
      nl := 4
      IF mwhere = "P"
         EndPrint()
       ELSE
       WAIT
           ENDIF 
RETURN

****--------- End OrderPrnt()

**-------------------------------------------------------------------

FUNCTION OrdfrmChr()

SCROLL()

***  M_Exit  := " "
***  MPCOUNT := 0

***  @ 13,0 CLEAR
***  RELEASE MPCOUNT

***  Setprnt()

  SET DEVICE TO PRINT
***  SET MARGIN TO 3
  npl := 56
***  @  0, 0 SAY mpreset

  SELECT Orders
  SET ORDER TO 2
  SEEK mordnum                             // ORDERS
  mcodeno := Orders->Codeno
  mdat    := Orders->Date                   // Easier to get this here
  mdat    := DTOC(mdat)
  dReqDate := Orders->ReqDate
  SELECT Name
      SEEK Orders->Codeno
      nl := 14
      @ nl,11 SAY Name->Name
      nl++
      @ nl,11 SAY Name->Add1
      @ nl,48 SAY "PURCHASE ORDER # ";
                  +SUBSTR( Orders->Psno,11, 2 )+" "+mordnum
      nl++
      @ nl,11 SAY Name->Add2
      nl++
      @ nl,11 SAY Name->Add3
      @ nl,40 SAY "Date "+mdat
      nl++
      @ nl,11 SAY Name->Add4
      nl++
      @ nl,11 SAY "Phone : " + Name->Phone
      @ nl,37 SAY "Fax : "   + Name->Bphone
      nl++
      @ nl, 0 SAY REPLICATE(".",69)
      nl++
***      @ 17, 0 SAY "Suppliers ID"
      @ nl,26 SAY "Description"
      @ nl,60 SAY "Order Qty"
***      @ 17,64 SAY "Price"
      nl++
      @ nl, 0 SAY REPLICATE("-",69)
      nl+=2
  DO WHILE Orders->( !EOF() )
    SELECT Orders
    IF Orders->Partnum != SPACE( 20 )
       ApRLock( 3 )
      ntotal   := 0
      mpartnum := Orders->Partnum
      Orders->P_flag := .T.
      UNLOCK
      SELECT Part
      SET ORDER TO 1                        // Partnum
      SEEK mpartnum
      SELECT Supl
      SET ORDER TO 1                        // Partnum+Codeno
      mseek := mpartnum+Orders->Codeno
      SEEK mseek
      IF FOUND()
         @ nl, 0 SAY "."+SUBSTR( Supl->SuppId, 1,14 )
         @ nl,16 SAY SUBSTR( Part->Partnum, 1, 9 )
       ELSE
         IF SUBSTR( Part->Partnum, 1, 2 ) != "ZZ"
            @ nl, 0 SAY Part->Partnum
         ENDIF
      ENDIF
      IF Part->Desc != SPACE( 40 )
         @ nl,26 SAY SUBSTR( Part->Desc, 1,34 )
       ELSE
         @ nl,26 SAY "Supply as detailed below."
      ENDIF
      @ nl,61 SAY Orders->Partqty PICTURE "99,999"
      DO CASE
         CASE Part->Unit == "Mtr       "
***            @ nl,64 SAY "@"+STR( Orders->Length, 6, 2 )+" "+TRIM( Part->Unit )
            nl++
            @ nl,20 SAY "Order Length = "+STR( Orders->Length, 6, 2 )+" "+Part->Unit
***         CASE Part->Unit == "Sq Mtr    "
***            @ nl,64 SAY "Sheets"
      ENDCASE
      nl++
      SELECT Orders
      IF Orders->Detail2 != SPACE( 40 )
         @ nl,16 SAY Orders->Detail2
         nl++ 
      ENDIF
      IF Orders->Detail3 != SPACE( 40 )
         @ nl,16 SAY Orders->Detail3
         nl++ 
      ENDIF
      IF Orders->Detail4 != SPACE( 40 )
         @ nl,16 SAY Orders->Detail4
         nl++ 
      ENDIF
    ENDIF                   // Orders
    SKIP ALIAS Orders
    IF Orders->Ordnum != mordnum
      EXIT
    ENDIF
  ENDDO
  @  51, 0 SAY "Please Supply On "+DTOC( dReqDate )
  @  52, 0 SAY Message->Order1
  @  53, 0 SAY Message->Order2
  @  54, 0 SAY Message->Order3
  @  55, 0 SAY Message->Order4
  @  56, 0 SAY Message->Order5
  @  57, 0 SAY Message->Order6
***  @   0, 0 SAY mpreset                 // `@ 0,0' forces page throw
  EndPrint()
SCROLL()
*** SET MARGIN TO 0

RETURN NIL

***----------- End OrdFrmChr()

**-------------------------------------------------------------------

FUNCTION OrdLook( mcodeno )

           SELECT Orders
           SET ORDER TO 3                   // Codeno+Ordnum
           SEEK Name->Codeno
           IF FOUND()
              cdesc  := SPACE( 30 )
              cunit  := SPACE( 10 )
              nrecno := 0
              aPart_ := {}
              DO WHILE Orders->Codeno == Name->Codeno .AND. Orders->( !EOF() )
                 IF Orders->PartIn >= Orders->PartQty
                    SKIP ALIAS Orders
                    LOOP
                 ENDIF
                 IF Orders->QtyRec >= Orders->PartQty
                    SKIP ALIAS Orders
                    LOOP
                 ENDIF
                 SELECT Part
                 SET ORDER TO 1
                 SEEK Orders->Partnum
                 cdesc := SUBSTR( Orders->Detail1, 1,38 )
                 SELECT Orders
                 IF cdesc = SPACE( 30 )
                    cdesc := SUBSTR( Part->Desc, 1,38 )
                 ENDIF 
                 IF cdesc = SPACE( 30 )
                    cdesc := SUBSTR( Orders->Detail2, 1,38 )
                 ENDIF 
               DO CASE
                  CASE Orders->Length > 0
                     cunit := "Lengths   "
                  CASE Part->Unit = "Sq Mtrs   "
                     cunit := "Sheets    "
                  OTHERWISE
                     cunit := Part->Unit 
               ENDCASE
               AADD( aPart_,cdesc;
                  +" "+Orders->Ordnum;
                  +" "+DTOC( Orders->Date );
                  +" "+STR( Orders->PartQty, 8, 2 );
                  +" "+STR( Orders->PartIn, 6 );
                  +" "+TRIM( cunit );
                  +"       "+STR( RECNO(),6 ) )
                 SKIP ALIAS Orders
             ENDDO                  // Orders
             IF !EMPTY( aPart_ )
                @ 1, 5 SAY Name->Name
                SCROLL(   3, 0, 24,80 )
                DISPBOX(  3, 1, 24,79, 2 )
                @  3, 3 SAY " - Parts On Order -" COLOR "G+"
                @  3,50 SAY " -- Ordered Qty  Received -- "
      ASORT( aPart_,,,{ | x,y | x < y } )
      anum   := ACHOICE(  4, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
      nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
   ENDIF
   GOTO nrecno
   mordnum := Orders->Ordnum
   SET ORDER TO 1               // Partnum
         ENDIF                                // FOUND()  
RETURN( mordnum )

***------- End of OrdLook()

**-------------------------------------------------------------------


FUNCTION Setprnt()                      // Set `Public' Printer codes
****** NOT USED NOW
public MPRESET, MPL51, MPL66, MPEXP1, MPEXPX, MPCOND, MPCONDX, MPELITE
public MPPICA, MPSUB, MPSUBX

store chr(27) + chr(64) to MPRESET          // Reset to standard
store chr(27) + "C" + chr(51) to MPL51      // Page length 51 lines
store chr(27) + "C" + chr(66) to MPL66      // Page length 66 lines
store chr(14) to MPEXP1                     // Double width chrs (1 line)
store chr(20) to MPEXPX                     //   -- cancel --
store chr(15) to MPCOND                     // Condensed print
store chr(18) to MPCONDX                    //   -- cancel --
store chr(27) + "M" to MPELITE              // Elite pitch
store chr(27) + "P" to MPPICA               // Pica pitch
store chr(27) + "S" + chr(1) to MPSUB       // Subscript
store chr(27) + "T" to MPSUBX               // - cancel -

**  End Function  --  SETPRNT

*******------------   END OF FILE CHRIORD1.PRG
