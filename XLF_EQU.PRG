*** JoKir02 19-02-11 07:56:42 
*** PWilk02 18-02-14 00:40:21   Allow price list to be limited by price. A request
***                             about limiting appearance of zero values occurs only
***                             if a difference of $0.00 is chosen.

/* 
   Program.....:                  XLF_EQU.PRG  and   CHRIEQU.PRG
   Authors.....: J.Kirby
   Date........: 22/10/1995
   Functions...: JCDirect2, Equ_price, Mu_Equ, EquPrice
                 EquList
   Static funcs: EquDelete, Modall, ModCost, PartEquDel
*/

FUNCTION JCDirect2()

   SCROLL()
   SELECT Name
   GOTO TOP
   ***   @ 16,20 SAY "This is to Change the Staff Group   DOCT, NURS, ASSI, VOLU " 
   nname := "N"
   ***   nname := ApGetN( "Edit Name Group" )
   @ 16,20 SAY SPACE( 59 )
   ***   IF LASTREC() != 0
   DO WHILE  Name->( !EOF() )
      IF Name->Sale != "STAF"
         SKIP ALIAS Name
         LOOP
      ENDIF  
      nletter := SPACE( 4 )
      @  2,10      SAY Name->Name+" "+Name->Sale
      @  2,COL()+2 SAY Name->Letter COLOR "G+"
      IF nname = "Y"
         nselect  := 1
         DO CASE
            CASE Name->Letter == "DOCT"
              nselect := 1   
            CASE Name->Letter == "NURS"
              nselect := 2   
            CASE Name->Letter == "ASSI"
              nselect := 3   
            CASE Name->Letter == "VOLU"
              nselect := 4   
            CASE Name->Letter == "NON "
              nselect := 5   
         ENDCASE 
         DISPBOX(  4, 4, 23,30, 2 )
         nl := 6
         @ nl, 6 SAY " -- Staff Groups -- "
         nl++ 
         @ nl, 6 PROMPT "Doctor    "
         nl++
         @ nl, 6 PROMPT "Nurse     "
         nl++
         @ nl, 6 PROMPT "Assistant "
         nl++
         @ nl, 6 PROMPT "Volunteer "
         nl++
         @ nl, 6 PROMPT "Non Production"
         nl++
         MENU TO nselect
         DO CASE
            CASE PressedEsc()
               RETURN NIL
            CASE nselect == 1
              nletter := "DOCT"   
            CASE nselect == 2
              nletter := "NURS"   
            CASE nselect == 3
              nletter := "ASSI"   
            CASE nselect == 4
              nletter := "VOLU"   
            CASE nselect == 5
              nletter := "NON "   
         ENDCASE 
          ApRlock()
         Name->Letter := nletter
         UNLOCK
      ENDIF               // Name->Letter
      SKIP ALIAS Name
   ENDDO

   nletter := "FABR"
   mwhere  := "S"
   npl     := 20
   nl      := 0
   
    Printsel()                               // _LF_Init

   IF mwhere == "P"
      npl := 58
      @  0, 0
      SET DEVICE TO PRINT
   ELSE
      npl := 23
      nl  := 0
   ENDIF
   coperno := Debit->Operno
   minvno  := Debit->Invno
   mcodeno := Debit->Codeno
   @ nl, 1 SAY Control->U_Name
   @ nl,39 SAY "Factory Report "+minvno
   @ nl,63 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
              +STR(YEAR(DATE()),5)
   nl+=2
   SELECT Name
   SEEK Debit->Codeno
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
   *** @ nl,54 SAY Debit->DbDate
   nl++
   SELECT Quot 
   SET ORDER TO 3                    // Invno
   SEEK Debit->Invno
   SELECT Part
   SEEK Quot->Partnum
   ***   @ nl, 0 SAY STR( Quot->Qty, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
   ***              +" "+Part->Desc;
   ***              +"  "+SUBSTR( Quot->Partnum, 1,16 )
   nl++
   ttime:= ntimetotal:= nPartTot:= nTimeRate := 0
   SELECT Labour
   SET ORDER TO 2  // Invoice            // 1  Codeno+Date+Partnum
   GOTO TOP
   SEEK minvno
   DO WHILE Labour->Invno = minvno .AND. Labour->( !EOF() )
      IF Labour->Partnum != SPACE( 20 )
         nPartTot += Labour->Time*Labour->Rate
         SKIP ALIAS Labour
         LOOP
      ENDIF
      mcode      := Labour->Codeno
      nCodeTot   := 0
      SELECT Labour
      DO WHILE Labour->Codeno = mcode .AND. Labour->( !EOF() )
         IF Labour->Invno != minvno
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Partnum != SPACE( 20 )
            nPartTot += Labour->Time*Labour->Rate
            SKIP ALIAS Labour
            LOOP
         ENDIF  
         nCodeTot   += Labour->Time
         nTimeTotal += Labour->Time
         nTimeRate  += Labour->Time*Labour->Rate
         SKIP ALIAS Labour
      ENDDO                // mcode
      SELECT Name
      SEEK mcode
      @ nl, 2 SAY Name->Name
       ApRlock()
      Name->Loc := "DIR"
      UNLOCK
      SELECT Labour  
      @ nl,34 SAY ncodeTot PICTURE "9999.99"
      @ nl,42 SAY "____________________________"
      @ nl,72 SAY Name->Letter
      nl++
   ENDDO                // EOF Labour
   SELECT Name
   GOTO TOP
   aPart_:={}
   nrecno := 0
   IF LASTREC() != 0
      DO WHILE  Name->( !EOF() )
         IF Name->Sale != "STAF"
            SKIP ALIAS Name
            LOOP
         ENDIF  
         IF Name->Loc != "   "
            SKIP ALIAS Name
            LOOP
         ENDIF  
         IF nletter != SPACE( 4 )
            IF Name->Letter != nletter
               SKIP ALIAS Name
               LOOP
            ENDIF
         ENDIF   
         @ nl, 1 SAY Name->Name+"________________________________________"
         @ nl,72 SAY Name->Letter
         nl++
          ApRlock()
         Name->Loc := "   "
         UNLOCK
         SKIP ALIAS Name
      ENDDO
   ENDIF           // LastRec
   nl++
   @ nl, 2 SAY "Leading Hand  __________________"
   @ nl,34 SAY Debit->Operno
   IF nTimeTotal > 0
      @ nl,52 SAY minvno+" Time"
      @ nl,64 SAY nTimeTotal PICTURE "99,999.99"
   ENDIF
   nl++
   coperno := Debit->Operno
   ntimetotal:= ntime := 0
   SELECT Operate
   GOTO TOP
   DO WHILE Operate->( !EOF() )
      IF Operate->Operno != coperno
         SKIP ALIAS Operate
         LOOP
      ENDIF
      IF Operate->Print = " "
         SKIP ALIAS Operate
         LOOP
      ENDIF
      IF nl >= npl
         IF mwhere = "P"
            EJECT
            nl := 0
            @ nl, 0 SAY Control->U_Name
            @ nl,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ),5 )
            nl+=2
         ELSE
            WAIT
            SCROLL()
            nl := 0
         ENDIF
      ENDIF
      IF Operate->ABC != " "
          nl++
          @ nl, 1 SAY Operate->Desc
          @ nl,41 SAY "Done By   Checked By   Rework   Checked"                               
          nl++
      ELSE
          @ nl, 0 SAY Operate->Desc
          @ nl,41 SAY "________:__________:___________:_______"
          nl++
      ENDIF 
      SKIP ALIAS Operate
   ENDDO                        // Operate EOF
   /*
   TAKEN OUT   
   SELECT PartOper
   GOTO TOP
   SET ORDER TO 2         // Operno+Order
   DO WHILE PartOper->( !EOF() )
      IF PartOper->Operno != coperno
         SKIP ALIAS PartOper
         LOOP
      ENDIF 
      IF PartOper->Adminno != SPACE( 8 )
         SKIP ALIAS PartOper
         LOOP
      ENDIF 
      IF PartOper->Task != SPACE( 1 )
         SKIP ALIAS PartOper
         LOOP
      ENDIF 
      ttime := ttime+PartOper->Time
      DO CASE 
         CASE PartOper->Desc = SPACE( 40 )
            @ nl, 1 SAY PartOper->Order;
                        +" "+SUBSTR( PartOper->Partnum, 1,16 )
            @ nl,30 SAY "_________________________________________  ____"
         OTHERWISE
            @ nl, 1 SAY PartOper->Order;
                        +" "+SUBSTR( PartOper->Partnum, 1,16 )
            @ nl,22 SAY PartOper->Drawno+" "+PartOper->Desc 
      ENDCASE
      nl++
      IF nl > npl
         IF mwhere == "P"
            EJECT
            @  0, 0 SAY Control->U_Name
            @  0,40 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ),5 )
            @  0,62 SAY minvno
            nl := 2
           ELSE
            INKEY( 0 )
            SCROLL()
            nl := 0 
         ENDIF                       // mwhere = P
      ENDIF
      SKIP ALIAS PartOper
   ENDDO                     // PartOper   coperno 
   nl++
   Taken Out
   */
   nl++ 
   coperno := Debit->Operno
   SELECT Quot
   SET ORDER TO 3        // Invno + Partnum
   SEEK Debit->Invno   
   **********************
   coperno := Debit->Operno
   SELECT Progress
   SEEK coperno 
   SELECT Quot
   SET ORDER TO 3        // Invno + Partnum
   SEEK Debit->Invno
   SELECT Progress
   @ nl, 1 SAY Progress->DescProg
   IF Quot->Prog01 = SPACE( 12 )
      @ nl,14 SAY "____________"
     ELSE
      @ nl,14 SAY Quot->Prog01
   ENDIF
   SKIP ALIAS Progress
   @ nl,27 SAY Progress->DescProg
   IF Quot->Prog02 = SPACE( 12 )
      @ nl,40 SAY "____________"
     ELSE
      @ nl,40 SAY Quot->Prog02
   ENDIF
   SKIP ALIAS Progress
   @ nl,53 SAY Progress->DescProg
   IF Quot->Prog03 = SPACE( 12 )
      @ nl,66 SAY "____________"
     ELSE
      @ nl,66 SAY Quot->Prog03
   ENDIF
   nl++
   SKIP ALIAS Progress
   @ nl, 1 SAY Progress->DescProg
   IF Quot->Prog04 = SPACE( 12 )
      @ nl,14 SAY "____________"
     ELSE
      @ nl,14 SAY Quot->Prog04
   ENDIF
   SKIP ALIAS Progress
   @ nl,27 SAY Progress->DescProg
   IF Quot->Prog05 = SPACE( 12 )
      @ nl,40 SAY "____________"
     ELSE
      @ nl,40 SAY Quot->Prog05
   ENDIF
   SKIP ALIAS Progress
   @ nl,53 SAY Progress->DescProg
   IF Quot->Prog06 = SPACE( 12 )
      @ nl,66 SAY "____________"
     ELSE
      @ nl,66 SAY Quot->Prog06
   ENDIF
   nl++
   SKIP ALIAS Progress
   @ nl, 1 SAY Progress->DescProg
   IF Quot->Prog07 = SPACE( 12 )
      @ nl,14 SAY "____________"
     ELSE
      @ nl,14 SAY Quot->Prog07
   ENDIF
   SKIP ALIAS Progress
   @ nl,27 SAY Progress->DescProg
   IF Quot->Prog08 = SPACE( 12 )
      @ nl,40 SAY "____________"
     ELSE
      @ nl,40 SAY Quot->Prog08
   ENDIF
   SKIP ALIAS Progress
   @ nl,53 SAY Progress->DescProg
   IF Quot->Prog09 = SPACE( 12 )
      @ nl,66 SAY "____________"
     ELSE
      @ nl,66 SAY Quot->Prog09
   ENDIF 
   nl++
   SKIP ALIAS Progress
   @ nl, 1 SAY Progress->DescProg
   IF Quot->Prog10 = SPACE( 12 )
      @ nl,14 SAY "____________"
     ELSE
      @ nl,14 SAY Quot->Prog10
   ENDIF
   SKIP ALIAS Progress
   @ nl,27 SAY Progress->DescProg
   IF Quot->Prog11 = SPACE( 12 )
      @ nl,40 SAY "____________"
     ELSE
      @ nl,40 SAY Quot->Prog11
   ENDIF
   SKIP ALIAS Progress
   @ nl,53 SAY Progress->DescProg
   IF Quot->Prog12 = SPACE( 12 )
      @ nl,66 SAY "____________"
     ELSE
      @ nl,66 SAY Quot->Prog12
   ENDIF
   nl++
   SKIP ALIAS Progress
   @ nl, 1 SAY Progress->DescProg
   IF Quot->Prog13 = SPACE( 12 )
      @ nl,14 SAY "____________"
     ELSE
      @ nl,14 SAY Quot->Prog13
   ENDIF
   SKIP ALIAS Progress
   @ nl,27 SAY Progress->DescProg
   IF Quot->Prog14 = SPACE( 12 )
      @ nl,40 SAY "____________"
     ELSE
      @ nl,40 SAY Quot->Prog14
   ENDIF
   SKIP ALIAS Progress
   @ nl,53 SAY Progress->DescProg
   IF Quot->Prog15 = SPACE( 12 )
      @ nl,66 SAY "____________"
     ELSE
      @ nl,66 SAY Quot->Prog15
   ENDIF
   nl++
   SKIP ALIAS Progress
   @ nl, 1 SAY Progress->DescProg
   IF Quot->Prog16 = SPACE( 12 )
      @ nl,14 SAY "____________"
     ELSE
      @ nl,14 SAY Quot->Prog16
   ENDIF
   SKIP ALIAS Progress
   @ nl,27 SAY Progress->DescProg
   IF Quot->Prog17 = SPACE( 12 )
      @ nl,40 SAY "____________"
     ELSE
      @ nl,40 SAY Quot->Prog17
   ENDIF
   SKIP ALIAS Progress
   @ nl,53 SAY Progress->DescProg
   IF Quot->Prog18 = SPACE( 12 )
      @ nl,66 SAY "____________"
     ELSE
      @ nl,66 SAY Quot->Prog18
   ENDIF
   nl+=2
   ***********************
   /*
   TAKEN OUT
   coperno := "RECOURCE"
   @ nl, 1 SAY coperno+"    "+mcodeno 
   nl++
   SELECT Admin
   GOTO TOP
   SEEK coperno
   DO WHILE Admin->Adminno = coperno .AND. Admin->( !EOF() )
      @ nl, 3 SAY Admin->Desc+" ___________________________"
      nl++
      SKIP ALIAS Admin
   ENDDO      // Admin
   nl++
   SELECT PartOper
   SET ORDER TO 2            // Operno     // Partnum+Order
   GOTO TOP
   DO WHILE PartOper->( !EOF() )
      IF PartOper->Codeno != mcodeno
         SKIP ALIAS PartOper
         LOOP
      ENDIF
      IF PartOper->Task = " "
         SKIP ALIAS PartOper
         LOOP
      ENDIF
      IF PartOper->Operno != coperno
         SKIP ALIAS PartOper
         LOOP
      ENDIF
      ttime := ttime+PartOper->Time
      @ nl, 1 SAY PartOper->Order;
            +" "+SUBSTR( PartOper->Partnum, 1,16 )
      IF PartOper->Time > 0
         @ nl,23 SAY PartOper->Time PICTURE "999.99"
      ENDIF
      IF PartOper->Desc = SPACE( 40 )
         @ nl,30 SAY "______:______:______:______:______:______"
      ELSE
         @ nl,30 SAY PartOper->Desc
      ENDIF
      nl++
      IF nl > npl
         IF mwhere = "P"
            EJECT
            @  0, 0 SAY Control->U_Name
            @  0,40 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                  +STR( YEAR(DATE() ),5 )
            @  0,62 SAY minvno
            nl := 2
         ELSE
            INKEY( 0 )
            SCROLL()
            nl := 0 
         ENDIF
      ENDIF
      SKIP ALIAS PartOper
   ENDDO                     // PartOper   coperno 
   taken Out
   */
   nl++
   ***   @ nl,10 SAY "Time"
   ***   @ nl,15 SAY ttime PICTURE "9,999.99"  
   ***   nl++
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
   SET ORDER TO 1
   SELECT PartOper
   SET ORDER TO 1

   RETURN NIL
   ***-------- End of JCDirect2

   ****-------------------------------------------------------------------------

FUNCTION Equ_price()

   mselect := SPACE( 2 )
   SCROLL()
   DISPBOX(  4, 1, 8,79, 2 )

   @  5,30 SAY "Blank for ALL" COLOR "R+"
   @  7,10 SAY "Select Modules with First 2 Letters";
                GET mselect PICTURE "!!"
   READ 
   IF PressedEsc()
      RETURN NIL
   ENDIF
   SELECT EquDesc
   SET ORDER TO 1                           // Modcode+Partnum
   GOTO TOP
   SCROLL()
   nl  := 1
   npl := 16
   DO WHILE EquDesc->( !EOF() )
      IF mselect != SPACE( 2 )
         IF SUBSTR( EquDesc->Modcode, 1, 2 ) != mselect
            SKIP ALIAS EquDesc
            LOOP
         ENDIF
      ENDIF
      nl := 1
      SCROLL()
      mmodcode := EquDesc->Modcode
      @ nl, 1 SAY EquDesc->Modcode+" "+EquDesc->Desc
      SELECT Part
      SET ORDER TO 1
      SEEK mmodcode
      IF !FOUND()
         SELECT EquDesc
         SKIP ALIAS EquDesc
         LOOP
      ENDIF
      nl++
      @ nl, 1 SAY "Part  "+Part->Desc+"  "+Part->Partnum
      nlabpart := 0
      ntottrade:= ntotwhol := 0
      ntottrade1:= ntotwhol1 := 0
      SELECT Equ
      SET EXACT ON
      nrecno2:= nrecno3:= nrecno4 := 0
      nqty1:= nqty2:= nqty3:= nqty4 := 0
      nequ1:= nequ2:= nequ3:= nequ4 := 0
      mmod4:= mmod3:= mmod2 := SPACE( 16 )
      npl := 0
      GOTO TOP
      SEEK mmodcode                
      IF FOUND()   
         DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !EOF() )
            IF npl < 23 
               @ npl,71 SAY SUBSTR( Equ->Partnum, 1, 9 ) COLOR "BG+" 
               npl++
            ENDIF 
            SELECT Part
            SEEK Equ->Partnum
            ntottrade1 += ( Part->Trade*Equ->PartQty )
            ntotwhol1  += ( Part->Wholesale*Equ->PartQty )
            SELECT Equ
            mmod2 := SUBSTR( Equ->Partnum, 1,16 ) 
            nqty1 := Equ->Partqty 
            nrecno2 := RECNO() 
            IF Equ->Partnum = Message->LabPart
               nlabpart += nqty1
            ENDIF
            GOTO TOP
            SEEK mmod2
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
                  nqty2 := Equ->PartQty
                  nequ2 := ( nqty1 * nqty2 )
                  IF Equ->Partnum = Message->LabPart
                     nlabpart += nequ2
                  ENDIF
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
                        mmod4 := SUBSTR( Equ->Partnum, 1,16 )
                        nrecno4 := RECNO()
                        nqty3 := Equ->PartQty
                        nequ3 := nqty1 * nqty2 * nqty3
                        IF Equ->Partnum = Message->LabPart
                           nlabpart += nequ3
                        ENDIF
                        GOTO TOP
                        SEEK mmod4
                        IF !FOUND()
                           ntottrade += ( Part->Trade*nequ3 )
                           ntotwhol  += ( Part->Wholesale*nequ3 )
                        ENDIF
                        IF FOUND()
                           DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                              nqty4 := Equ->PartQty
                              nequ4 := nqty1 * nqty2 * nqty3 * nqty4
                              IF Equ->Partnum = Message->LabPart
                                 nlabpart += nequ4
                              ENDIF
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
      SET EXACT OFF  
      IF FOUND()
         cTotTrade1 := STR( nTotTrade1, 7, 2 )  //  - Rounding ?
         nTotTrade1 := VAL( cTotTrade1 )
      ENDIF
      SELECT Part
      SET ORDER TO 1
      SEEK mmodcode
      ntemptrade := Part->Trade
      ntempMkup  := Part->Markup
      ntempWhol  := Part->Wholesale
      mcorrect := "N"
      DO WHILE mcorrect = "N"
         SCROLL( 3, 0,24,70 ) 
         nl+=3
         @ nl, 2 SAY SUBSTR( Part->Partnum, 1,16 )
         @ nl,COL()+3 SAY DTOC( Part->Date )
         nl++
         @ nl, 2 SAY Part->Desc COLOR "BG+"
         nl+=2
         @ nl, 2      SAY "File Cost"
         @ nl,COL()+1 SAY Part->Trade      PICTURE "999,999.99" COLOR "BG+"
         @ nl,COL()+1 SAY "Mkp"
         @ nl,COL()+2 SAY Part->Markup     PICTURE "9999.99 %"
         @ nl,COL()+2 SAY "Sell"
         @ nl,COL()+1 SAY Part->Wholesale  PICTURE "999,999.99" COLOR "BG+"
         nl+=3
         @ nl, 2      SAY "Parts" 
         @ nl,COL()+1 SAY nTotTrade        PICTURE "999,999.99" COLOR "R+"
         @ nl,COL()+2 SAY "Kit "                         
         @ nl,COL()+1 SAY nTotTrade1       PICTURE "999,999.99" COLOR "R+"
         nl++
         IF nTotTrade > nTotTrade1
            nTotTrade1 := nTotTrade
         ENDIF
         IF Part->Trade <= 0
            @ nl, 3 SAY "Price is less than 0" COLOR "G+"
            nl++
         ENDIF
         IF Part->Markup <= 0
            @ nl, 3 SAY "Mark Up is less than 0" COLOR "G+"
            nl++
         ENDIF
         nl++
         IF Part->Trade+1 < nTotTrade
            @ nl,10 SAY "---- CHECK TRADE PRICE ----" COLOR "R+"
            nl+=2
         ENDIF
         ntrade     := Part->Trade
         nwholesale := Part->Wholesale
         nmarkup    := Part->Markup
         @ nl, 0      SAY SPACE( 48 )
         @ nl, 2      SAY "Kit " GET ntrade     PICTURE "999999.99"
         @ nl,COL()+1 SAY "Mkp"  GET nmarkup    PICTURE "9999.99"
          READ
         nwholesale := ( ntrade* ( 1+( nmarkup/100) ) )
         @ nl,34      SAY "Sell"
         @ nl,COL()+1 SAY nwholesale PICTURE "999,999.99" COLOR "BG+"
         IF PressedEsc()
            RETURN NIL
         ENDIF
         nl+=2 
         DO CASE 
            CASE Part->Boughtout = "Y"
                 nselect := 1
            OTHERWISE
                 nselect := 2
         ENDCASE
         @ nl, 6      PROMPT "Part Bought Out"
         @ nl,COL()+2 PROMPT "Own Manufacture"
         MENU TO nselect
         SELECT Part 
          ApRlock( 3 )
         Part->Trade     := ntrade
         Part->Markup    := nmarkup
         Part->Wholesale := nwholesale
         DO CASE
            CASE nselect == 1
                 Part->Boughtout := "Y"
            CASE nselect == 2
                 Part->Boughtout := "N"
         ENDCASE
         UNLOCK
         IF Part->Trade+1 < nTotTrade
            nl++
            @ nl,10 SAY "---- CHECK TRADE PRICE ----" COLOR "R+"
         ENDIF
         IF Part->Trade+1 < nTotTrade
            mcorrect := ApGetN( "???? Is the Above Correct" )
           ELSE
            mcorrect := ApGetY( "Is the Above Correct" )
         ENDIF
         nl := 1
      ENDDO                    // mcorrect 
      SELECT EquDesc
      SKIP ALIAS EquDesc
   ENDDO                  // EquDesc

   RETURN NIL

   ****------------------------------------------------------------------------

FUNCTION Mu_Equ( nc, ncl )

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      nselect  := 0
      nc       := ncl*2
      SCROLL(  3,nc, 21,78 )
      DISPBOX( 4,nc, 21,nc+ncl )
      SCROLL(  3,nc+4, 5,nc+(ncl-4) )
      DISPBOX( 3,nc+4, 5,nc+(ncl-4) )
      @  4,nc+( ncl/2 )-( LEN( RTRIM( Menu->CH_EquHd) )/2 );
                           SAY RTRIM( Menu->CH_EquHd )
      @  7,nc+2 PROMPT Menu->CH_Equ1
      @  9,nc+2 PROMPT Menu->CH_Equ2
      @ 11,nc+2 PROMPT Menu->CH_Equ3
      @ 13,nc+2 PROMPT "4. Part-Module Price"
      @ 15,nc+2 PROMPT "5. Part Menu System "
      @ 17,nc+2 PROMPT "6. Part A Menu Syst "
      @ 18,nc+2 PROMPT "7. Module Menu Syst "

      @ 20,nc+2 PROMPT Menu->CH_Main
      nc := ncl
      MENU TO nselect

      DO CASE
         CASE nselect == 8 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 1
            SAVE SCREEN TO holdscrn
              EquAdd()                             // Below
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
              Equlist()                            // Below
            RESTORE SCREEN FROM holdscrn
            LOOP
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
              EquDelete()                           // Below
            RESTORE SCREEN FROM holdscrn
            LOOP
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
             Equ_Price()                             // Above 
            RESTORE SCREEN FROM holdscrn
           LOOP
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
             PartAnaly()        // XLF_Menu.prg 
            RESTORE SCREEN FROM holdscrn
           LOOP
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
             PartAnalyA()     // XLF_Menu.prg 
            RESTORE SCREEN FROM holdscrn
           LOOP
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
             ModuleAnaly()     // XLF_Menu.prg 
            RESTORE SCREEN FROM holdscrn
           LOOP
      ENDCASE
   ENDDO                //  mcontinue

   RETURN NIL

   ***** End of Mu_Equ()

   **---------------------------------------------------------------------*

FUNCTION Equdetail( mmodcode )

   SCROLL()
   DISPBOX(  0, 1, 2,79, 2 )
   SELECT EquDesc
   SEEK mmodcode
   @  1,10 SAY EquDesc->ModCode+" "+EquDesc->Desc
   ***   @  1,10 SAY Part->Partnum+" "+Part->Desc

   mok := "Y"
   DO WHILE mok = "Y"
   aPart_ := {}
   anum   := {}
   nrecno := 0
   SELECT Equ
   GOTO TOP
   SEEK mmodcode
   mmodcode := Equ->ModCode
   DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !EOF() )
      SELECT Part
      SEEK Equ->Partnum
      SELECT Equ
      *****   AADD( aPart_,SUBSTR( Part->Desc,1,30 )+" "+SUBSTR( Equ->Partnum,1,10 );
      AADD( aPart_,SUBSTR( Part->Partnum,1, 8);
                   +" "+SUBSTR( Part->Desc,1,31 );
                   +"  "+STR( Equ->PartQty,9,3 );
                   +"  "+STR( Part->Trade,9,2 );
                   +"  "+STR( Part->Wholesale,9,2 );
                   +"        "+STR( RECNO(),6 ) )
      SKIP ALIAS Equ
   ENDDO                       // EOF()
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
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         mmod2   := SUBSTR( Equ->Partnum, 1,16 ) 
         nqty1   := Equ->Partqty 
         nrecno2 := RECNO() 
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
               nequ2   := ( nqty1 * nqty2 )
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
               nequ3   := nqty1 * nqty2 * nqty3
               GOTO TOP
               SEEK mmod4
               IF !FOUND()
                  ntottrade += ( Part->Trade*nequ3 )
                  ntotwhol  += ( Part->Wholesale*nequ3 )
               ENDIF
               IF FOUND()
               DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                  nqty4 := Equ->PartQty
                  nequ4 := nqty1 * nqty2 * nqty3 * nqty4
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
         SET EXACT OFF  
   SELECT Equ
   GOTO TOP
   SEEK mmodcode
   IF !EMPTY( aPart_ )
      DISPBOX(  3, 1, 24,79, 2 )
      @ 4, 5      SAY "Kit Cost"                       COLOR "R+"
      @ 4,COL()+3 SAY ntottrade1 PICTURE "$999,999.99" COLOR "R+"
      @ 4,COL()+2 SAY "Parts"                          
      @ 4,COL()+3 SAY ntottrade  PICTURE "$999,999.99" 
      @ 4,COL()+3 SAY "Qty       Cost       Sell"
           ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE( 5, 2, 23,78, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF LASTKEY() = -1
               EquPartAdd( mmodcode )
               EquDetail( mmodcode )            
            ENDIF
            GOTO nrecno
            nl := ROW()  
            SELECT Equ
             ApRLock( 3 )
            @ nl,43 GET Equ->PartQty
             READ
            UNLOCK
            SELECT Part
            SET ORDER TO 1
            SEEK Equ->Partnum
            ntrade     := Part->Trade
            nwholesale := Part->Wholesale
    ***        @ nl,56 GET ntrade     PICTURE "999999.99"
      ***         @ nl,67 GET nwholesale PICTURE "999999.99"
            @ nl,56 SAY ntrade     PICTURE "999999.99"
            @ nl,67 SAY nwholesale PICTURE "999999.99"
      ***          READ
             ApRLock( 3 )
      ***         Part->Trade     := ntrade
      ***         Part->Wholesale := nwholesale
            UNLOCK 
            SELECT Equ               // mcorrect
            IF Equ->Partqty == 0
               mcorrect := "N"
                ApRLock( 3 )
               DELETE
               UNLOCK
            ENDIF
        ENDIF
        mok := "Y"
        LOOP
   ENDDO                                       // mok

   RETURN mmodcode
  
   ****----- EquDetail()

   ****------------------------------------------------------------------------

STATIC FUNCTION EquDelete()

   SCROLL()
   DISPBOX(  4, 1,16,79, 2 )
   @  6,10 SAY "Only Deletes the Module NOT THE PART" COLOR "R+"   
   mselect := SPACE( 2 )
   @  8,10      SAY "Select Modules with First Letters" GET mselect PICTURE "!!"
   @  8,COL()+2 SAY "Blank For All"
    READ 
   IF PressedEsc()
      RETURN NIL
   ENDIF
   mdebitfile := "Y"
      **** ApGetY( "Do You Want Debit Shown" ) 
   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      SCROLL()
      DISPBOX(  0, 1, 2,79, 2 )
      @  1, 4 SAY "Modules First Letters = "+mselect
      ***   IF mdebitfile = "Y"
      ***     @  1,60 SAY "This May Take Time"
      ***   ENDIF 
      SELECT EquDesc
      SET ORDER TO 1 
      aPart_:={}
      anum  := {}
      nrecno := 0
      mmodcode:= coderef:= SPACE( 16 )
      SCROLL(  3, 0,maxrow(),maxcol() )
      IF LASTREC() != 0
         GO TOP
         DO WHILE EquDesc->( !EOF() )
            IF mselect != SPACE( 2 )
               IF SUBSTR( EquDesc->Modcode, 1, 2 ) != mselect
                  SKIP ALIAS EquDesc
                  LOOP
               ENDIF
            ENDIF
            mdebit := SPACE( 12 )  
            IF mdebitfile = "Y"
                SELECT Debit
                GOTO TOP 
                DO WHILE Debit->( !EOF() )
                    IF SUBSTR( Debit->Invno, 3, 4 ) = SUBSTR( EquDesc->Modcode, 4, 4 )
                       mdebit := Debit->Invno+" Debit"
                    ENDIF
                    SKIP ALIAS Debit
                ENDDO
                SELECT EquDesc
             ENDIF 
             AADD( aPart_,EquDesc->ModCode+" "+EquDesc->Desc;
                       +" "+mdebit;  
                       +"       "+STR( RECNO(),6 ) )
            SKIP ALIAS EquDesc
         ENDDO
         DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            anum := ACHOICE( 4, 3, 23,77, aPart_,,"AFUNC" )
            IF PressedEsc()
               RETURN NIL
            ENDIF
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
         ENDIF
         mmodcode := EquDesc->Modcode
      ENDIF  
                SET EXACT OFF
                SELECT Debit
                GOTO TOP 
                DO WHILE Debit->( !EOF() )
                    IF SUBSTR( DEBIT->Invno, 3, 4 ) = SUBSTR( mmodcode, 4, 4 )
                       SCROLL( 14, 2, 23,78 )
                       @ 18,20 SAY "There is A Debit # "+Debit->Invno COLOR "RG+"
                       @ 19,10 SAY "Can't Delete This Module YET "
                       WAIT                       
                        EquDelete()
                      IF PressedEsc()
                         RETURN NIL
                      ENDIF
                    ENDIF
                    SKIP ALIAS Debit
                ENDDO
         SCROLL()
         SELECT EquDesc
         SEEK mmodcode
         @  1,10 SAY "BEWARE MODULE IS USED IN THE FOLLOWING" COLOR "R+"
         nl := 3
         @  nl, 7 SAY EquDesc->Modcode+"  "+EquDesc->Desc
         nl+=2
         SELECT Equ
         GOTO TOP
         DO WHILE Equ->( !EOF() )
            IF Equ->Partnum != mmodcode
               SKIP ALIAS Equ
               LOOP
            ENDIF
            @ nl, 2 SAY Equ->Modcode
            SELECT EquDesc
            SEEK Equ->Modcode
            @ nl,20 SAY EquDesc->Desc
            SELECT Equ
            @ nl,62 SAY Equ->PartQty PICTURE "999,999.99"
            nl++ 
            SKIP ALIAS Equ
         ENDDO                            // EOF Equ
      SCROLL(  16, 0, 24,80 )
      DISPBOX( 16, 1, 18,79, 2 )
      mcorrect := "N"
      DO WHILE mcorrect == "N"
         SELECT EquDesc
         SEEK mmodcode
         @ 17, 8 SAY EquDesc->Modcode+" "+EquDesc->Desc COLOR c_hicolor
         mcorrect := ApGetN( TRIM( Message->Delete ) )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         IF mcorrect = "N"
             mcorrect := "Y"
             EquDelete()
         ENDIF
      ENDDO                                // mcorrect
      myesdel := ApGetN( "DELETE  ARE YOU SURE" )
      IF myesdel = "Y" 
             mpartnum := mmodcode 
                @ 21,10 SAY "    Please Wait takes Me time   "
               SELECT Part
                SEEK mpartnum
                 ApRLock( 3 )
                Part->ABC := " "         // DELETE 
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
                SELECT EquDesc
                 ApFLock( 3 )
                DELETE ALL FOR EquDesc->Modcode = SUBSTR( mpartnum, 1,16 )
                UNLOCK
      ***             SELECT Quot
      ***              ApFLock( 3 )
      ***             DELETE ALL FOR Quot->Partnum = mpartnum 
      ***             UNLOCK
                SELECT QuotInfo
                 ApFLock( 3 )
                DELETE ALL FOR QuotInfo->Partnum = mpartnum 
                UNLOCK
      ENDIF              // myesdel
      mcontinue := ApGetN( TRIM( Message->Delete )+" Another Module" )
   ENDDO                                              // mcontinue

   RETURN NIL

   ***---- End of EquDelete()

   ****------------------------------------------------------------------------

FUNCTION EquPrice( mpartnum )

   IF mpartnum = SPACE( 20 )
      SCROLL()
      DISPBOX(  0, 1, 2,79, 2 )
      @  1,10 SAY "Price One Module"
      cequId   := SPACE( 12 )
      mmodcode := SPACE( 16 )
         aPart_ := {}
         SCROLL()
         DISPBOX(  0, 1,  2,79, 2 )
         @  1,10 SAY "Listing Modules Please Select"
         SELECT EquDesc
         GOTO TOP
         DO WHILE EquDesc->( !EOF() )
            AADD( aPart_,EquDesc->ModCode+" "+EquDesc->Desc;
                         +" "+EquDesc->EquId+"      "+STR( RECNO(),6 ) )
            SKIP ALIAS EquDesc
         ENDDO
      *****                      +" "+STR( EquDesc->Amount );
         DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            anum := ACHOICE( 4, 3, 23,78, aPart_,,"AFUNC" )
            IF PressedEsc()
               RETURN NIL
            ENDIF
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
         ENDIF
         mmodcode := EquDesc->Modcode
         SCROLL(  17, 0, 24,80 )
         DISPBOX( 17, 1, 19,79, 2 )
         SELECT EquDesc
         SET ORDER TO 1
         SEEK mmodcode
         DO WHILE !FOUND()
            @ 18,10      SAY "No Parts in Module" GET mmodcode PICTURE "@!"
       @ 18,COL()+2 SAY "Esc To Quit"
        READ
       IF PressedEsc()
          RETURN NIL
       ENDIF
       SEEK mmodcode
         ENDDO
         @ 18,10 SAY Equdesc->Modcode+" "+Equdesc->Desc COLOR c_hicolor
         SELECT Equ
         SEEK mmodcode
         IF !FOUND()
            @ 18,10 SAY "No Parts in Module File Bye Bye"+SPACE( 20 )
            INKEY( 0 )
            RETURN NIL
         ENDIF
   ENDIF           // mpartnum

         mok := "Y"
      ****      mok    := ApGetY( "Do You Want Sub Modules" )
         mprice := ApGetY( "Do you want Cost & Sell" )
         mwhere := "S"
         npl    := 54

          Printsel( mwhere, npl ) 

        IF mwhere == "P"
           npl := 56
         ELSE
          npl := 22 
        ENDIF
   mtemp := SPACE( 8 )
   npn   := 1
      *** @  0, 0 SAY "Page No."
      *** @  0, 8 SAY npn PICTURE "99"
   @  0, 2 SAY Control->U_Name
   npn := npn+1
   @  0,56 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   nl := 2
   IF mtemp != Equdesc->ModCode
      @  nl, 0 SAY Equdesc->Modcode
      @  nl,20 SAY Equdesc->Desc 
      nl++
      SELECT Equ
      nl++
      @ nl, 0 SAY "Part #"
      @ nl,11 SAY "Description"
      nl++
   ENDIF
   ntotal:= ntradetot:= 0

   SELECT Equ
   DO WHILE Equ->ModCode = mmodcode .AND. Equ->( !EOF() )
      IF nl > npl
         IF mwhere = "P"
       EJECT
          ELSE
       WAIT
       SCROLL()
         ENDIF
         npn := npn+1
         @  0, 2 SAY Control->U_Name
         @  0,56 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                   +STR( YEAR(DATE() ),5 )
    ***     @  3, 0 SAY Equdesc->Modcode
    ***     @  3,20 SAY Equdesc->Desc
    ***     @  3,62 SAY EquDesc->Amount       
         @  3, 0 SAY "Part #"
         @  3,11 SAY "Description"
         nl := 5
      ENDIF
      SELECT EquDesc
      SEEK TRIM( Equ->Partnum )
      cequpart := "Y"
      IF FOUND()
         cequpart := "N"
      ENDIF
      ****   @ nl, 0 SAY Equ->Partnum
      SELECT Part
      SET ORDER TO 1                           // Partnum
      SEEK Equ->Partnum
      ntrade     := Part->Trade
      nwholesale := Part->Wholesale
      IF !FOUND()
         @ nl,30 SAY "Part not yet defined"
       ELSE
         @ nl, 0 SAY SUBSTR( Part->Partnum,1, 9 )
         @ nl,11 SAY SUBSTR( Part->Desc,1,30 )
         @ nl,45 SAY Equ->PartQty    PICTURE "99,999.999" 
         IF mprice = "Y"
            @ nl,56 SAY Part->Trade              PICTURE "999,999.99"
            @ nl,67 SAY Part->Trade*Equ->PartQty PICTURE "999,999.99"
          ELSE
            @ nl,66 SAY Part->Wholesale PICTURE "99,999.99"
         ENDIF  
         ntotal    += ( Part->Wholesale*Equ->PartQty )
         ntradetot += ( Part->Trade*Equ->PartQty )
      ENDIF
      nl++ 
      SKIP ALIAS Equ
   ENDDO
    IF mok = "Y"  
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
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         mmod2   := SUBSTR( Equ->Partnum, 1,16 ) 
         nqty1   := Equ->Partqty 
         nrecno2 := RECNO() 
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
               nequ2   := ( nqty1 * nqty2 )
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
               nequ3   := nqty1 * nqty2 * nqty3
               GOTO TOP
               SEEK mmod4
               IF !FOUND()
                  ntottrade += ( Part->Trade*nequ3 )
                  ntotwhol  += ( Part->Wholesale*nequ3 )
               ENDIF
               IF FOUND()
               DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                  nqty4 := Equ->PartQty
                  nequ4 := nqty1 * nqty2 * nqty3 * nqty4
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
         SET EXACT OFF  
   nl++
   IF mprice = "Y"
      @ nl, 2 SAY "Kit Sell"
      @ nl,12 SAY ntotwhol1  PICTURE "$999,999.99"
      @ nl,25 SAY "Kit Cost"
      @ nl,35 SAY ntottrade1 PICTURE "$999,999.99"
      @ nl,48 SAY "Parts Cost"
      @ nl,60 SAY ntottrade  PICTURE "$99,999.99"
   ENDIF
   ENDIF                           // mok price
   IF mwhere = "P"
      @ nl, 0 SAY " "
      EndPrint()
      SET MARGIN TO 0
     ELSE
      IF nl > 19
         WAIT
      ENDIF
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF     // mwhere

   RETURN NIL
   ***---- End of EquPrice()

   **-------------------------------------------------------------------

FUNCTION EquList()

   mcontinue := "Y" 
   DO WHILE mcontinue == "Y"
        SCROLL()
        DISPBOX( 3, 1, 19,79, 2 )
        mchoice := 1
        @ 10,20 PROMPT "1. Modules     Desc & Cost"
        @ 11,20 PROMPT "2. Individual Module Parts"
      ***     @ 12,20 PROMPT "3. All Modules & Parts    "
        MENU TO mchoice
        DO CASE
            CASE mchoice == 1
                 ModCost()                   // Below
            CASE mchoice == 2
                mpartnum := SPACE( 20 )
                 EquPrice( mpartnum )       // Above
      ***         CASE mchoice =  3
      ***              ModAll()                    // Below
      ENDCASE
      mcontinue := ApGetN( Message->Another )
   ENDDO

   RETURN NIL
   ****--------- End of EquList()

   **-------------------------------------------------------------------

   *****------  If All Modules Selected

STATIC FUNCTION Modall()

   mwhere := "S"
   npl    := 54
   
   Printsel( mwhere, npl ) 

   IF mwhere == "P"
      SET MARGIN TO 0
   ENDIF
   mmodcost := 0
   nl       := 7
   npn := 1
   SELECT Equ
   GOTO TOP
   mmodcode := Equ->Modcode
   SELECT EquDesc
   SEEK mmodcode
   IF !FOUND()
      @ nl,18 SAY "No description"
   ELSE
      @  1,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                  +STR( YEAR(DATE() ),5 )
      @  3,11 SAY mmodcode
      @  3,45 SAY Equdesc->Desc       
      @  5, 0 SAY "Part #"
      @  5,18 SAY "Description"
      @  5,64 SAY "Qty"
      @  5,74 SAY "Cost"
   ENDIF
   SELECT Equ
   DO WHILE Equ->( !EOF() )
      IF nl > npl
         IF mwhere = "P"
            EJECT
            npn++
          ELSE
            WAIT
            SCROLL()
         ENDIF
         nl := 7
      ENDIF
      IF Equ->ModCode != mmodcode
                nl+=2
         @ nl,55 SAY "Cost ="
         @ nl,65 SAY mmodcost PICTURE "$999,999.99"
         nl++
         @ nl,64 SAY  "============"
         nl+=2
         mmodcode := Equ->ModCode
                IF mwhere = "P"
            EJECT
           ELSE
            WAIT
            SCROLL()
         ENDIF
         nl := 7
         SELECT EquDesc
         SEEK mmodcode
         IF !FOUND()
            @ nl,20 SAY "No description"
          ELSE
                   @ 1,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                             +STR( YEAR(DATE() ),5 )
            @  3,11 SAY mmodcode
            @  3,45 SAY Equdesc->Desc       
            @  5, 0 SAY "Part #"
            @  5,18 SAY "Description"
            @  5,64 SAY "Qty"
            @  5,74 SAY "Cost"
         ENDIF
         nl := 7
         mmodcost := 0
      ENDIF
      SELECT Equ
      mpartnum := Equ->Partnum
      @ nl, 0 SAY Equ->Partnum
      SELECT Part
             SET ORDER TO 1
      SEEK mpartnum
      IF !FOUND()
         @ nl,30 SAY "Part not yet defined"
         mA := 0
      ELSE
         @ nl,18 SAY SUBSTR( Part->Desc,1,30 )
         mA := Part->Trade
      ENDIF
      SELECT Equ
             @ nl,50 SAY Part->Trade  PICTURE "99,999.99"
      @ nl,60 SAY Equ->Partqty PICTURE "9,999.999"
      mmodcost := mmodcost+( mA*Equ->Partqty )
      @ nl,71 SAY mA*Equ->Partqty PICTURE "99,999.99"
       ***    @ nl,78 SAY Equ->ABC PICTURE "X"
       ***         @ nl,80 SAY Equ->EquPart
      SKIP ALIAS Equ
      nl++
   ENDDO
   nl++
   @ nl,55 SAY "Cost ="
   @ nl,65 SAY mmodcost PICTURE "$999,999.99"
   nl++
   @ nl,65 SAY "============"
   nl+=2
   /*
   IF mwhere = "P"
      EndPrint()
      SET MARGIN TO 0
    ELSE
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF
   */

   RETURN NIL

   **** End of Modall()

   **-------------------------------------------------------------------

   **** Cost of Modules
        
STATIC FUNCTION ModCost()

   mselect := SPACE( 2 )
   mdiff := 1.00
   mzero := "Y"
   SCROLL()
   DISPBOX(  3, 1,12,79, 2 )
   @  4,10 SAY "Prints Module List by Parts Cost and Kit Cost"
   @  6,30 SAY "Blank for ALL" COLOR "R+"
   @  8,10 SAY "Select Modules with First Letters" GET mselect PICTURE "!!"
   @  10,10 SAY "Price difference to exclude ( 0.00 for none )" GET mdiff PICTURE "99999.99"
   READ 
   IF PressedEsc()
      RETURN NIL
   ENDIF
   SELECT EquDesc
   SET ORDER TO 1                           // Modcode+Partnum
   GOTO TOP
   IF mdiff == 0
      mzero := ApGetN( "Include zero prices?" )
   ENDIF
   mok  := ApGetN( "Sort by Module Description" )
   IF mok = "Y" 
      ApFLock( 3 )
      INDEX ON EquDesc->Desc TO TempI03
      SET INDEX TO TempI03
      UNLOCK
   ENDIF
   mwhere := "S"
   npl    := 54

   Printsel( mwhere, npl )

   IF mwhere = "S"
      npl := 22
   ENDIF
   SCROLL()
   nl := 3
   @  0, 2 SAY Control->U_Name
   @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
              +STR( YEAR(DATE() ),5 )
   @ nl, 0 SAY "Module"
         @ nl,15 SAY "Description"
         @ nl,45 SAY "Parts"
         @ nl,52 SAY "Kit Cost"
         @ nl,66 SAY "Sell"
         @ nl,74 SAY "Markup"
   nl++
   SELECT EquDesc
   DO WHILE EquDesc->( !EOF() )
      IF mselect != SPACE( 2 )
         IF SUBSTR( EquDesc->Modcode, 1, 2 ) != mselect
            SKIP ALIAS EquDesc
            LOOP
         ENDIF
      ENDIF
      IF nl > npl
         IF mwhere = "P"
            EJECT
         ELSE
            WAIT
            SCROLL()
         ENDIF
         nl := 3
         @  0, 2 SAY Control->U_Name
         @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         @ nl, 0 SAY "Module"
         @ nl,15 SAY "Description"
         @ nl,45 SAY "Parts"
         @ nl,52 SAY "Kit Cost"
         @ nl,66 SAY "Sell"
         @ nl,74 SAY "Markup"
         nl++
      ENDIF
      mmodcode := EquDesc->Modcode
      ntotal:= ncost:= nwholesale := 0
      SELECT Part
      SET ORDER TO 1
      SEEK mmodcode
      ncost := Part->Trade
      SELECT Part
      ApFLock( 3 )
       Part->ABC := "M"               // Finds Modules
      UNLOCK
      nmarkup := Part->Markup
      nwholesale := Part->Wholesale
      SELECT Equ
      SET EXACT ON
      ntottrade:= nTotWhol := 0
      ntottrade1:= nTotWhol1 := 0
      nrecno2:= nrecno3:= nrecno4 := 0
      nqty1:= nqty2:= nqty3:= nqty4 := 0
      nequ1:= nequ2:= nequ3:= nequ4 := 0
      mmod2:= mmod3:= mmod4 := SPACE( 16 )
      GOTO TOP
      SEEK mmodcode                // Original Part
      IF FOUND()   
         DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !EOF() )
            SELECT Part
            SEEK Equ->Partnum
            SELECT Equ
            mmod2   := SUBSTR( Equ->Partnum, 1,16 ) 
            nqty1   := Equ->Partqty 
            nrecno2 := RECNO() 
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
                  nequ2   := ( nqty1 * nqty2 )
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
                        nequ3   := nqty1 * nqty2 * nqty3
                        GOTO TOP
                        SEEK mmod4
                        IF !FOUND()
                           ntottrade += ( Part->Trade*nequ3 )
                           ntotwhol  += ( Part->Wholesale*nequ3 )
                        ENDIF
                        IF FOUND()
                        DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                           nqty4 := Equ->PartQty
                           nequ4 := nqty1 * nqty2 * nqty3 * nqty4
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
      SET EXACT OFF  
      IF mzero == "Y" .OR. nTotTrade > 0 .OR. nTotTrade1 > 0
         ntotal := ntottrade1-ntottrade
         IF ntotal >= mdiff
            @ nl, 0 SAY SUBSTR( EquDesc->Modcode, 1,12 )
            @ nl,14 SAY SUBSTR( EquDesc->Desc, 1,35 )
            @ nl,40 SAY nTotTrade  PICTURE "999,999.99"
            @ nl,50 SAY nTotTrade1 PICTURE "999,999.99"
            @ nl,60 SAY nWholesale PICTURE "999,999.99"
            @ nl,70 SAY nmarkup  PICTURE "999,999.99"
            nl++ 
         ENDIF
      ENDIF
      SELECT EquDesc
      SKIP ALIAS EquDesc
   ENDDO
   SELECT EquDesc
   SET INDEX TO EDescInd
   IF mwhere = "P"
      EndPrint()
      SET MARGIN TO 0
   ELSE
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF

   RETURN NIL

   ****---- End of ModCost()

   ***---------------------------------------------------------------------*

STATIC FUNCTION PartEquDel()

   ********************   NOT USED NOW 

   mselect := SPACE( 2 )
   SCROLL()
   DISPBOX(  4, 1,14,79, 2 )
   @  6,10 SAY "Only Deletes the Module NOT THE PART" COLOR "R+"   
   @  8,10      SAY "Select Part with First Letters" GET mselect PICTURE "!!"
    READ 
   IF PressedEsc()
      RETURN NIL
   ENDIF
   mdebitfile := "Y"
   mdebitfile := ApGetN( "Do You Want Debit Shown" ) 
   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      SCROLL()
      DISPBOX(  0, 1, 2,79, 2 )
      @  1, 4 SAY "Selected Part with First Letters = "+mselect
      IF mdebitfile = "Y"
        @  1,60 SAY "This May Take Time"
      ENDIF 
      aPart_:={}
      anum  := {}
      nrecno := 0
      SELECT Part
      GOTO TOP
      DO WHILE Part->( !EOF() )
         IF SUBSTR( Part->Partnum, 1, 2 ) != mselect
            SKIP ALIAS Part
            LOOP
         ENDIF
         mdebit := SPACE( 12 )  
         IF mdebitfile = "Y"
            SELECT Debit
            GOTO TOP 
            DO WHILE Debit->( !EOF() )
               IF SUBSTR( Debit->Invno, 3, 4 ) = SUBSTR( Part->Partnum, 4, 4 )
                  mdebit := Debit->Invno+" Debit"
               ENDIF
               SKIP ALIAS Debit
            ENDDO
         ENDIF 
         SELECT Part
         AADD( aPart_,SUBSTR( Part->Partnum, 1,16 );
                  +" "+Part->Desc;
                  +" "+mdebit;  
                  +"       "+STR( RECNO(),6 ) )
         SKIP ALIAS Part
      ENDDO
      DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            anum := ACHOICE( 4, 3, 23,77, aPart_,,"AFUNC" )
            IF PressedEsc()
               RETURN NIL
            ENDIF
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
         ENDIF
         SCROLL( 1, 2, 1,78 )
         @  1, 7 SAY SUBSTR( Part->Partnum, 1,16 )+" "+( Part->Desc )
                SET EXACT OFF
                SELECT Debit
                GOTO TOP 
                DO WHILE Debit->( !EOF() )
                    IF SUBSTR( DEBIT->Invno, 3, 4 ) = SUBSTR( Part->Partnum, 4, 4 )
                       SCROLL( 14, 2, 23,78 )
                       @ 18,20 SAY "There is A Debit # "+Debit->Invno COLOR "RG+"
                       @ 19,10 SAY "Can't Delete This Module YET "
                       WAIT                       
                        EquDelete()
                      IF PressedEsc()
                         RETURN NIL
                      ENDIF
                    ENDIF
                    SKIP ALIAS Debit
                ENDDO
      SCROLL(  16, 0, 24,80 )
      DISPBOX( 16, 1, 18,79, 2 )
      mcorrect := "N"
      DO WHILE mcorrect == "N"
         @ 17, 8 SAY Part->Partnum+" "+Part->Desc COLOR c_hicolor
         mcorrect := ApGetN( TRIM( Message->Delete ) )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         IF mcorrect = "N"
             mcorrect := "Y"
             PartEquDel()
         ENDIF
      ENDDO                                // mcorrect
      myesdel := ApGetN( "DELETE  ARE YOU SURE" )
      IF myesdel = "Y" 
           mpartnum := Part->Partnum 
                @ 21,10 SAY "    Please Wait takes Me time   "
    ***            SELECT Part
    ***            SEEK mpartnum
    ***             ApRLock( 3 )
    ***            DELETE 
    ***            UNLOCK
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
                SELECT EquDesc
                 ApFLock( 3 )
                DELETE ALL FOR EquDesc->Modcode = SUBSTR( mpartnum, 1,16 )
                UNLOCK
      ***             SELECT Quot
      ***              ApFLock( 3 )
      ***             DELETE ALL FOR Quot->Partnum = mpartnum 
      ***             UNLOCK
                SELECT QuotInfo
                 ApFLock( 3 )
                DELETE ALL FOR QuotInfo->Partnum = mpartnum 
                UNLOCK
      ENDIF                // myesdel
      mcontinue := "Y"
      *** ApGetN( TRIM( Message->Delete )+" Another Module" )
   ENDDO                                              // mcontinue

   SCROLL( 12, 0, 22,80 )

   RETURN NIL
   ***---- End of PartEquDel()

   *****---------------------- End of File XLF_Equ.PRG

