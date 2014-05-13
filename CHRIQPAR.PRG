***  JoKir09  25-09-11 10:28:53 

/*  Program.....:                CHRIQPAR.PRG
    Authors.....: J.Kirby
    Date........:  5/10/1995
    Functions...: FactAllSent, Mu_QPart, QPuotJSheet, QPartSearch, QPuotOperLst
                : QPuotProf, QPuotPrice, QPuotIndi, QPuotadd  
    IN HOUSE STOCK WORK ORDERS      
*/

FUNCTION FactAllSent()

mcontinue := "Y"
DO WHILE mcontinue = "Y"
    mcodeno := SPACE( 8 ) 

     Namerank( @mcodeno )                            // ZSF_Name

    IF LASTKEY() == 27
       RETURN NIL
    ENDIF
    mcodeno := Name->Codeno
    cbranchId := SPACE( 2 ) 
    SELECT Branch
    SEEK mcodeno
    IF FOUND()
  
        BranchFind( @mcodeno )             // ZSF_Name
       cbranchId := Branch->BranchId

       mok := ApGetY( "Do you Want Branch" )
       IF mok = "N"
          cbranchId := SPACE( 2 )
       ENDIF
    ENDIF

    SCROLL()
    DISPBOX( 0, 1, 2,79, 2 )
    @ 1, 5 SAY Name->Name COLOR "BG+"
    DISPBOX( 3, 1, 18,79, 2 )
    dstmm    := DATE()-2
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
   nl := 1
   IF mwhere = "P"
      @  nl, 1 SAY Control->U_Name
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
      @  nl, 1 SAY Name->Name+"  "+cbranchId
******************
     IF Debit->BranchId != SPACE(2)
        SELECT Branch
      mfind := Debit->Codeno+Debit->BranchId
      SEEK mfind
      @ nl,43 SAY Branch->Name
   ENDIF
   nl++
   @ nl, 1 SAY Name->Add1
   IF Debit->BranchId != SPACE(2)
      @ nl,43 SAY Branch->Add1
   ENDIF
   nl++
   @ nl, 1 SAY Name->Add2
   IF Debit->BranchId != SPACE(2)
      @ nl,43 SAY Branch->Add2
   ENDIF
   nl++
   @ nl, 1 SAY Name->Add3
   IF Debit->BranchId != SPACE(2)
      @ nl,43 SAY Branch->Add3
   ENDIF
   nl++
   @ nl, 1 SAY Name->Add4
   IF Name->Phone != SPACE(15)
      @ nl,22 SAY Name->Phone                // Business Phone
   ENDIF
   IF Debit->BranchId != SPACE(2)
      @ nl,43 SAY Branch->Add4
      @ nl,64 SAY Branch->Phone             // Business Phone
   ENDIF
      nl+=2 
      @  nl,10 SAY "From " +DTOC( dstmm ) 
      @  nl,32 SAY "To "   +DTOC( dendmm ) 
      nl++
    ELSE
      SCROLL()
      DISPBOX( 0, 1, 3,79, 2 )
      @ 1, 3 SAY Name->Name+"  "+cbranchId 
      @ 2,10      SAY "From " +DTOC( dstmm ) 
      @ 2,COL()+2 SAY "To "   +DTOC( dendmm ) 
      nl := 4 
   ENDIF
   SELECT Hist
   SET ORDER TO 1         // Codeno
   GOTO TOP
   SEEK mcodeno
***   mcodeno := SPACE( 8 ) 
      DO WHILE Hist->Codeno = mcodeno .AND. Hist->( !EOF() )
         IF SUBSTR( Hist->Partnum,1,4 ) = "FREI"
            SKIP ALIAS Hist
            LOOP
         ENDIF
        IF cbranchId != SPACE( 2 )
           IF Hist->BranchId != cbranchId
              SKIP ALIAS Hist
              LOOP
           ENDIF
        ENDIF                    // cbranchId
***         IF Hist->Sentby = "       "
***            SKIP ALIAS Hist
***            LOOP
***         ENDIF 
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
            @  3, 3 SAY Name->Name+"  "+cbranchId 
            @  4,10 SAY "From " +DTOC( dstmm ) 
            @  4,32 SAY "To "   +DTOC( dendmm )
            nl := 5 
         ENDIF                      // nl
/*
         IF Hist->Codeno != mcodeno
            SELECT Name
            SEEK Hist->Codeno
            @ nl, 0 SAY Name->Name
            nl++
            SELECT Hist
            mcodeno := Hist->Codeno
         ENDIF
*/  
         SELECT Part
         SEEK Hist->Partnum
         @ nl, 0 SAY SUBSTR( Hist->Partnum, 1,10 );
                +" "+Part->Desc;
                +" "+STR( Hist->Qty, 5 );
                +" "+DTOC( Hist->PDate );
                +" "+Hist->Invno
         nl++
         SKIP ALIAS Hist
      ENDDO                             // EOF
      nl++
      @ nl,44 SAY "On Order   Sent"
      nl++
   SELECT Quot
   SET ORDER TO 1         // Codeno
   GOTO TOP
   SEEK mcodeno
      DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
         IF Quot->GoodSent = 0
            SKIP ALIAS Quot
            LOOP
         ENDIF 
         IF cbranchId != SPACE( 2 )
            IF Quot->BranchId != cbranchId
               SKIP ALIAS Quot
               LOOP
            ENDIF
         ENDIF                    // cbranchId
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
            @  3, 3 SAY Name->Name+"  "+cbranchId 
            @  4,10 SAY "From " +DTOC( dstmm ) 
            @  4,32 SAY "To "   +DTOC( dendmm )
            nl := 5 
         ENDIF                      // nl
/*
         IF Quot->Codeno != mcodeno
            SELECT Name
            SEEK Quot->Codeno
            @ nl, 0 SAY Name->Name
            nl++
            SELECT Quot
            mcodeno := Quot->Codeno
         ENDIF  
*/
         SELECT Part
         SEEK Quot->Partnum
         SELECT Quot
         @ nl, 0 SAY SUBSTR( Quot->Partnum, 1,10 );
                +" "+SUBSTR( Part->Desc, 1,35 );
                +" "+STR( Quot->Qty, 5 );
                +" "+STR( Quot->GoodSent, 5 );
                +" "+DTOC( Quot->DBDate );
                +" "+Quot->Ordnum
*** +" "+Quot->Sentby
         nl++
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
    IF mwhere == "S"
       nl++
       mok := "N"
       DO WHILE mok = "N"
          mok := ApReadN()
       ENDDO
     ELSE
       EndPrint()
    ENDIF
    mcontinue := ApGetN( TRIM( Message->Another ) )
ENDDO

RETURN

****---- End of FactAllSent()

****-------------------------------------------------------------------

FUNCTION Mu_QPart( nc, ncl )

DO WHILE .T.
   nselect := 0
   nc      := ncl*2
   SCROLL(  3,nc, 21,78 )
   DISPBOX( 4,nc, 21,nc+ncl )
   SCROLL(  3,nc+2, 5,nc+( ncl-2 ) )
   DISPBOX( 3,nc+2, 5,nc+( ncl-2 ) )
   cheading := "ORDERS  MENU"
   @  4,nc+( ncl/2 )-( LEN( RTRIM( cheading ) )/2 );
                        SAY RTRIM( cheading )
   @  7,nc+2 PROMPT "1. ORDERS       LIST"
   @  9,nc+2 PROMPT "2. PARTS        LIST"
   @ 11,nc+2 PROMPT "3. Urgent/Month LIST"
   @ 13,nc+2 PROMPT "4. ORDERS     SEARCH"
   @ 15,nc+2 PROMPT "5. ..       Add/Edit"
   @ 17,nc+2 PROMPT "6. Orders by    Desc"
   @ 18,nc+2 PROMPT "7. Orders   Analysis"
***   @ 19,nc+2 PROMPT "8. Hours      Report"
   @ 20,nc+2 PROMPT Menu->CH_Main
   nc := ncl 
   MENU TO nselect

   DO CASE
      CASE nselect == 8 .OR. LASTKEY() == 27
         EXIT
      CASE nselect == 1
         SAVE SCREEN TO Invscrn
           QPuotList()                               // QLstPart.PRG
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 2
         SAVE SCREEN TO Invscrn
           QPuotParts()                              // QLstPart
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 3
          SAVE SCREEN TO Invscrn
            QuotFaxno()                             // ChriqPrn
         RESTORE SCREEN FROM Invscrn
         LOOP
      CASE nselect == 4                             // Search
         SAVE SCREEN TO Invscrn
           QPuotSearch()                             
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 5                             // Orders Add
         SAVE SCREEN TO Invscrn
           QPuotadd()                                // Below
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 6                              // Desc
         SAVE SCREEN TO Invscrn
           QPuotDesc()                               // QLstPart
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 7
         SAVE SCREEN TO Invscrn
           QPuotProf()                               // Below
         RESTORE SCREEN FROM Invscrn
/*
      CASE nselect == 8
         SAVE SCREEN TO Invscrn
           MonthLab()                               // 
         RESTORE SCREEN FROM Invscrn
*/
   ENDCASE
ENDDO

RETURN NIL

***** End of Mu-Quot

***----------------------------------------------------------------------------

FUNCTION QPuotJSheet( mcodeno, cfaxno )

mcontinue := "Y"
DO WHILE mcontinue == "Y"
   moper  := "N"
   mallparts := ApGetN( "Client All Items All J/C" ) 
   mequ   := ApGetY( "Do You Want Module Parts" ) 
   IF mequ = "Y"
      moper  := ApGetN( "Do You Want OPERATIONS" ) 
   ENDIF
   mABC := ApGetY( "Y = ABC System Work Orders" ) 
   mwhere := "S"
   npl    := 0
   nrecno:= nrecno1:= nrecno2:= nrecno3 := 0
   nl     := 0
   
    Printsel()                               // _LF_Init

   @ nl, 0 SAY Control->U_Name+"  In House Job Card"
   @ nl,60 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
              +STR(YEAR(DATE()),5)
   nl+=2
   SELECT Name
   @ nl, 0 SAY Name->Name
   nl++
   @ nl, 0 SAY Name->Add1
   nl++
   IF Name->Add3 != "     "
      @ nl, 0 SAY Name->Add2
      nl++
   ENDIF
   IF Name->Add3 != "     "
      @ nl, 0 SAY Name->Add3
      nl++
   ENDIF
   @ nl, 0 SAY TRIM( Name->Add4 )+" Bus Ph "+Name->Phone+"  "+Name->Mobphone
   nl++
   nQty:= nlength := 0
   IF mAllParts != "Y"
      @ nl,60 SAY "Ref # "+cfaxno
   ENDIF
   nl++
   SELECT Quot
   GOTO TOP
   SEEK mcodeno
   nline := 0
   DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
      nrecno2:= nrecno3:= nrecno4 := 0
      nquot:= nequ1:= nequ2:= nequ3:= nqequ4 := 0
      nqty1:= nqty2:= nqty3:= nqty4 := 0
      IF Quot->Invno != SPACE( 6 )
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF mAllParts != "Y"
         IF Quot->Faxno != cfaxno
            SKIP ALIAS Quot
            LOOP
         ENDIF
      ENDIF
      SELECT Part
      SEEK Quot->Partnum
         @ nl, 0 SAY STR( Quot->Qty, 8, 3 )+" "+TRIM( Quot->Partnum );
                     +"  "+TRIM( Part->Desc)
         IF mAllParts = "Y"
            nl++
            @ nl,60 SAY "Ref # "+Quot->Faxno
         ENDIF 
***         IF Part->Length > 0
***            @ nl,67 SAY " Mtr"+STR( Part->Length )
***         ENDIF
         nl++
         IF Part->Detail != SPACE( 43 )
            @ nl,12 SAY Part->Detail
            nl++
         ENDIF
         IF Part->Detail1 != SPACE( 43 )
            @ nl,12 SAY Part->Detail1
            nl++
         ENDIF
         IF Part->Detail2 != SPACE( 43 )
            @ nl,12 SAY Part->Detail2
            nl++
         ENDIF
         IF Part->Detail3 != SPACE( 43 )
            @ nl,12 SAY Part->Detail3
            nl++
         ENDIF
         mpartnum := Quot->Partnum
      IF moper = "Y" 
         JSOperLst( mpartnum )
      ENDIF
      IF Part->PartMat != SPACE( 20 )
         nlength := Quot->Qty*Part->Length
     ***    @ nl, 2 SAY nlength PICTURE "999,999.99" 
     ***    @ nl,21 SAY "Required"
     ***    @ nl,50 SAY "Length "+STR( Part->Length )
     ***    nl++
         SELECT Part
         SEEK Part->PartMat
         @ nl,14 SAY TRIM( Part->Desc )+"  "+TRIM( Part->Partnum );
                     +"  "+TRIM( Part->Codeno ) 
         nl++
/*
TAKEN OUT
         IF Part->Length > 0
            @ nl,16 SAY  nlength/Part->Length PICTURE "999,999.99"
            @ nl,28 SAY "Required Each Length Mtr "+STR( Part->Length )
            nl++
         ENDIF
*/
      ENDIF
      IF Quot->Info != SPACE( 45 )
         @ nl,12 SAY Quot->Info
         nl++
      ENDIF
      IF Quot->Info2 != SPACE( 45 )
         @ nl,12 SAY Quot->Info2
         nl++
      ENDIF
      IF Quot->Info3 != SPACE( 45 )
         @ nl,12 SAY Quot->Info3
         nl++
      ENDIF
      IF Quot->Info4 != SPACE( 45 )
         @ nl,12 SAY Quot->Info4
         nl++
      ENDIF
      IF Quot->Info5 != SPACE( 45 )
         @ nl,12 SAY Quot->Info5
         nl++
      ENDIF
      IF Quot->Info6 != SPACE( 45 )
         @ nl,12 SAY Quot->Info6
         nl++
      ENDIF
      IF Quot->Info7 != SPACE( 45 )
         @ nl,12 SAY Quot->Info7
         nl++
      ENDIF
      IF Quot->Info8 != SPACE( 45 )
         @ nl,12 SAY Quot->Info8
         nl++
      ENDIF
      IF Quot->Info9 != SPACE( 45 )
         @ nl,12 SAY Quot->Info9
         nl++
      ENDIF
      nquot := Quot->Qty
    IF mequ = "Y"
      SELECT Equ
      SET EXACT ON
      mmod1 := TRIM( Quot->Partnum )
      SEEK mmod1
      IF FOUND()   
         DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
            IF nl > npl
               IF mwhere = "P"
                  EJECT
                  nl := 0
                ENDIF
            ENDIF
            IF mwhere = "S"
               IF nl > 23
                  INKEY( 0 )
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            SELECT Part
            SEEK Equ->Partnum
            nqty1 := Equ->PartQty
            nequ1 := nqty1*nquot
            @ nl, 0 SAY "."
            @ nl, 2 SAY STR( nequ1, 8, 3 )+" "+TRIM( Equ->Partnum );
                        +" "+TRIM( Part->Desc )
            IF mABC = "Y"
               nl++
               IF Equ->ABC = "C"
                  SKIP ALIAS Equ 
                  LOOP
               ENDIF
            ENDIF  
         ***   IF Part->Length > 0
         ***      @ nl,68 SAY "Mtr"+STR( Part->Length )+STR( Quot->Qty,8,2 )
         ***   ENDIF
               @ nl,68 SAY Equ->PartQty PICTURE "999.999"
            nl++
            IF Part->Detail != SPACE( 43 )
               @ nl,12 SAY Part->Detail
               nl++
            ENDIF
            IF Part->Detail1 != SPACE( 43 )
               @ nl,12 SAY Part->Detail1
               nl++
            ENDIF
            IF Part->Detail2 != SPACE( 43 )
               @ nl,12 SAY Part->Detail2
               nl++
            ENDIF
            IF Part->Detail3 != SPACE( 43 )
               @ nl,12 SAY Part->Detail3
               nl++
            ENDIF

            mpartnum := Equ->Partnum
      IF moper = "Y" 
         JSOperLst( mpartnum )
      ENDIF
      IF Part->PartMat != SPACE( 20 )
         nlength := nequ1*Part->Length 
        *** @ nl, 2 SAY nlength PICTURE "999,999.99" 
        *** @ nl,21 SAY "Required"
        *** @ nl,50 SAY "Length "+STR( Part->Length )
        ***  nl++
         SELECT Part
         SEEK Part->PartMat
         @ nl,14 SAY TRIM( Part->Desc )+"  "+TRIM( Part->Partnum )
         nl++
/*
TAKEN OUT
         IF Part->Length > 0
            @ nl,16 SAY nlength/Part->Length PICTURE "999,999.999"
            @ nl,29 SAY "Required Each Length Mtr "+STR( Part->Length )
            nl++
         ENDIF
*/
      ENDIF
      SELECT Equ
      mmod2 := TRIM( Equ->Partnum )
      nrecno2 := RECNO() 
      GOTO TOP
      SEEK mmod2
      IF FOUND()   
         DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
            nqty2 := Equ->PartQty
            nequ2 := ( nqty2*nqty1 )*nquot
            IF nl > npl
               IF mwhere = "P"
                  EJECT
                  nl := 0  
                ENDIF
            ENDIF
            IF mwhere = "S"
               IF nl > 24
                  INKEY( 0 )
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            SELECT Part
            SEEK Equ->Partnum
            IF SUBSTR( Equ->Partnum, 3, 1 ) = "-"
               nl++
            ENDIF
            @ nl, 0 SAY ".."
            @ nl, 6 SAY STR( nequ2, 8, 3 )+" "+TRIM( Equ->Partnum );
                        +" "+TRIM( Part->Desc )
           *** IF Part->Length > 0
           ***    @ nl,68 SAY "Mtr"+STR( Part->Length )+STR( Quot->Qty,8,2 )
           *** ENDIF
            @ nl,68 SAY Equ->PartQty PICTURE "999.999"
            nl++
            IF Part->Detail != SPACE( 43 )
               @ nl,16 SAY Part->Detail
               nl++
            ENDIF
            IF Part->Detail1 != SPACE( 43 )
               @ nl,16 SAY Part->Detail1
               nl++
            ENDIF
            IF Part->Detail2 != SPACE( 43 )
               @ nl,16 SAY Part->Detail2
               nl++
            ENDIF
            IF Part->Detail3 != SPACE( 43 )
               @ nl,16 SAY Part->Detail3
               nl++
            ENDIF
            mpartnum := Equ->Partnum
      IF moper = "Y" 
         JSOperLst( mpartnum )
      ENDIF
      IF Part->PartMat != SPACE( 20 )
         nlength := nequ2*Part->Length 
        *** @ nl, 2 SAY nlength PICTURE "999,999.99" 
        *** @ nl,21 SAY "Required"
        *** @ nl,50 SAY "Length "+STR( Part->Length )
        ***  nl++
         SELECT Part
         SEEK Part->PartMat
         @ nl,18 SAY TRIM( Part->Desc )+" "+TRIM( Part->Partnum )
         nl++
/*
TAKEN OUT
         IF Part->Length > 0
            @ nl,18 SAY nlength/Part->Length PICTURE "999,999.999"
            @ nl,31 SAY "Required Each Length Mtr "+STR( Part->Length )
            nl++
         ENDIF
*/
      ENDIF
      SELECT Equ
      mmod3 := TRIM( Equ->Partnum )
      nrecno3 := RECNO()
      GOTO TOP
      SEEK mmod3
      IF FOUND()
         DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
            nqty3 := Equ->PartQty
            nequ3 := (( nqty3*nqty2 )*nqty1 )*nquot
            IF nl > npl
               IF mwhere = "P"
                  EJECT
                  nl := 0 
               ENDIF
            ENDIF
            IF mwhere = "S"
               IF nl > 24
                  INKEY( 0 )
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            SELECT Part
            SEEK Equ->Partnum
            IF SUBSTR( Equ->Partnum, 3, 1 ) = "-"
               nl++
               nline++
            ENDIF
            @ nl, 0 SAY "..."
            @ nl, 6 SAY STR( nequ3, 8, 3 )+" "+TRIM( Equ->Partnum );
                        +" "+TRIM( Part->Desc )
           *** IF Part->Length > 0
           ***    @ nl,68 SAY "Mtr"+STR( Part->Length )+STR( Quot->Qty,8,2 )
           *** ENDIF
            @ nl,68 SAY Equ->PartQty PICTURE "999.999"
            nl++
            IF Part->Detail != SPACE( 43 )
               @ nl,16 SAY Part->Detail
               nl++
            ENDIF
            IF Part->Detail1 != SPACE( 43 )
               @ nl,16 SAY Part->Detail1
               nl++
            ENDIF
            IF Part->Detail2 != SPACE( 43 )
               @ nl,16 SAY Part->Detail2
               nl++
            ENDIF
            IF Part->Detail3 != SPACE( 43 )
               @ nl,16 SAY Part->Detail3
               nl++
            ENDIF
            mpartnum := Equ->Partnum
      IF moper = "Y" 
         JSOperLst( mpartnum )
      ENDIF
      IF Part->PartMat != SPACE( 20 )
         nlength := nequ3*Part->Length 
        *** @ nl, 2 SAY nlength PICTURE "999,999.99" 
        *** @ nl,21 SAY "Required"
        *** @ nl,50 SAY "Length "+STR( Part->Length )
        ***  nl++
         SELECT Part
         SEEK Part->PartMat
         @ nl,18 SAY TRIM( Part->Desc )+"  "+TRIM( Part->Partnum )
         nl++
/*
TAKEN OUT
         IF Part->Length > 0
            @ nl,20 SAY nlength/Part->Length PICTURE "999,999.999"
            @ nl,32 SAY "Required Each Length Mtr "+STR( Part->Length )
            nl++
         ENDIF
*/
      ENDIF
         SELECT Equ
         mmod4   := TRIM( Equ->Partnum )
         nrecno4 := RECNO()
         GOTO TOP
         SEEK mmod4
         IF FOUND()
            DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
               nqty4 := Equ->PartQty
               nequ4 := ( ( nqty4*nqty3)*nqty2 )*nquot
            IF nl > npl
               IF mwhere = "P"
                  EJECT
                  nl := 0 
               ENDIF
            ENDIF
            IF mwhere = "S"
               IF nl > 24
                  INKEY( 0 )
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            SELECT Part
            SEEK Equ->Partnum
            IF SUBSTR( Equ->Partnum, 3, 1 ) = "-"
               nl++
               nline++
            ENDIF
            @ nl, 0 SAY "...."
            @ nl, 6 SAY STR( nequ4, 8, 3 )+" "+TRIM( Equ->Partnum );
                        +" "+TRIM( Part->Desc )
           *** IF Part->Length > 0
           ***    @ nl,68 SAY "Mtr"+STR( Part->Length )+STR( Quot->Qty,8,2 )
           *** ENDIF
            @ nl,68 SAY Equ->PartQty PICTURE "99,999.999"
            nl++
            IF Part->Detail != SPACE( 43 )
               @ nl,16 SAY Part->Detail
               nl++
            ENDIF
            IF Part->Detail1 != SPACE( 43 )
               @ nl,16 SAY Part->Detail1
               nl++
            ENDIF
            IF Part->Detail2 != SPACE( 43 )
               @ nl,16 SAY Part->Detail2
               nl++
            ENDIF
            IF Part->Detail3 != SPACE( 43 )
               @ nl,16 SAY Part->Detail3
               nl++
            ENDIF
            mpartnum := Equ->Partnum
      IF moper = "Y" 
         JSOperLst( mpartnum )
      ENDIF
      IF Part->PartMat != SPACE( 20 )
         nlength := nequ4*Part->Length 
        *** @ nl, 2 SAY nlength PICTURE "999,999.99" 
        *** @ nl,21 SAY "Required"
        *** @ nl,50 SAY "Length "+STR( Part->Length )
        ***  nl++
         SELECT Part
         SEEK Part->PartMat
         @ nl,18 SAY TRIM( Part->Desc )+"  "+TRIM( Part->Partnum )
         nl++
/*
TAKEN OUT
         IF Part->Length > 0
            @ nl,20 SAY nlength/Part->Length PICTURE "999,999.999"
            @ nl,32 SAY "Required Each Length Mtr "+STR( Part->Length )
            nl++
         ENDIF
*/
      ENDIF
               SELECT Equ 
               SKIP ALIAS Equ
               IF nline > 0
                 nl++
                 nline := 0
               ENDIF  
             ENDDO                       //  mmod4
          ENDIF
            SELECT Equ 
            GOTO nrecno4
            SKIP ALIAS Equ
            IF nline > 0
               nl++
               nline := 0
            ENDIF  
          ENDDO                       //  mmod3
       ENDIF                          // FOUND()  mmod3    
            SELECT Equ
            GOTO nrecno3
            SKIP ALIAS Equ
         ENDDO                       //  mmod2 EOF()
         nl++
      ENDIF                         // Found mmod2
            SELECT Equ
            GOTO nrecno2
            SKIP ALIAS Equ
          ENDDO                       //   mmod1 EOF()
         ENDIF                          // Found mmod1
         SET EXACT OFF      
      ENDIF                            // mequ Selected   Modules
      SELECT Quot
      SKIP ALIAS Quot
   ENDDO                            //   EOF() Quot
   nl++ 
   IF mwhere = "P"
      IF nl > 40
         nl := 1
         EJECT
      ENDIF
   ENDIF
   IF mwhere = "P"
      IF Message->Mess13 != SPACE( 40 )   
         @ nl,26 SAY Message->Mess13
         nl++
      ENDIF
      @ nl, 0 SAY "Qty    MATERIALS             Price      DATE    HOURS   WORK DONE"
      nl++
      npl := nl
      nline = 1
      FOR nline = 1 TO ( 60-npl )           // Was 63
      @ nl, 0 SAY "_____:_____________________:________   _______:______:___________________"
        nl+=2
        IF nl >60
          EXIT
        ENDIF
        npl++ 
      NEXT
   ENDIF 
   IF mwhere = "S"
      INKEY( 0 )
      SCROLL()
      nl := 0
   ENDIF
   nl++
   IF mwhere == "P"
      EndPrint()
    ELSE
      WAIT
   ENDIF 
   SCROLL( 18, 0, 24,80 )
   mcontinue := "N" 
****   mcontinue := ApGetN( TRIM( Message->Another )+" Print" )
ENDDO

RETURN( mcodeno )

******* End of QPuotJSheet()

**---------------------------------------------------------------------*

FUNCTION QPartSearch()

aPart_ := anum:= {}
nrecno:= ntotal:= nQty :=  0
maccepted := "N"
SCROLL()
SELECT Quot
INDEX ON Partnum TO QPartInd
SET INDEX TO QPartInd
IF LASTREC() != 0
   GOTO TOP
   mtempno := Quot->Partnum
   DO WHILE Quot->( !EOF() )
***      IF Quot->Invno != SPACE( 6 )
***         SKIP ALIAS Quot
***         LOOP
***      ENDIF
***      ntotal += ( Quot->Amount*Quot->Qty )
      SELECT Part
      SEEK mtempno
      cdesc    := SUBSTR( Part->Desc,1,30 )
      SELECT Quot
      nQty := 0
      DO WHILE Quot->Partnum = mtempno .AND. Quot->( !EOF() )
         nQty   += Quot->Qty               
         SKIP ALIAS Quot
         LOOP
      ENDDO
      SELECT Quot
      AADD( aPart_,mtempno+"  "+cdesc;
           +"  "+STR( nQty,8 )+"            "+STR( RECNO(),6 ) )
      mtempno := Quot->Partnum 
   ENDDO
   DISPBOX( 0, 1, 24,79, 2 )
   IF !EMPTY( aPart_ )
      ASORT(aPart_,,,{ | x,y | x < y })
      anum := ACHOICE( 1, 3, 23,68, aPart_,,"AFUNC" )
      IF LASTKEY() == 27
         SELECT Quot
         SET INDEX TO QuotInd
         RETURN NIL
      ENDIF
   ENDIF
   mpartnum  := SUBSTR( aPart_[anum],1,20 ) 
mcontinue = "Y"
DO WHILE mcontinue = "Y"
   aPart_ :={}
   nrecno:= ntotal:= nQty := 0
   cInvno := SPACE( 10 )
   SELECT Quot
   SEEK mpartnum
   DO WHILE Quot->Partnum = mpartnum .AND. Quot->( !EOF() )
***      IF Quot->Invno != SPACE( 6 )
***         SKIP ALIAS Quot
***         LOOP
***      ENDIF
      IF Quot->Invno != SPACE( 6 )
         cInvno := SPACE( 4 )+Quot->Invno
       ELSE
         cInvno := SUBSTR( Quot->Ordnum, 1,10 ) 
      ENDIF
      SELECT Name
      SEEK Quot->Codeno
      SELECT Part
      SEEK mpartnum
      SELECT Quot
      ntotal += Quot->Qty*Quot->Amount
      nQty   += Quot->Qty
      AADD( aPart_,SUBSTR( Name->Name,1,24 )+" "+Quot->BranchId;
           +" "+STR( Quot->Qty,8 );
           +" "+STR( Quot->GoodSent,8 );
           +" "+DTOC( Quot->DbDate );
           +" "+cInvno+" "+STR( Quot->Amount,8,2 );
           +"        "+STR( RECNO(),6 ) )
      SKIP ALIAS Quot
   ENDDO
   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
   @  1, 3      SAY TRIM( Part->Partnum )     COLOR "G+"
   @  1,COL()+1 SAY TRIM( Part->Desc )        COLOR "G+"
   @  1,COL()+1 SAY "Qty"
   @  1,COL()+1 SAY nQty   PICTURE "9999.99"  COLOR "G+" 
   @  1,COL()+1 SAY ntotal PICTURE "$999,999.99"
   DISPBOX( 4, 1, 23,79, 2 )
   @  3, 3 SAY "Name                      Branch Qty   Date     Order Supl Amount" 
   IF !EMPTY( aPart_ )
      ASORT( aPart_,,,{ | x,y | x < y } )
      anum := ACHOICE( 5, 3, 22,78,aPart_,,"AFUNC" )
      IF LASTKEY() == 27
         SELECT Quot
         SET INDEX TO QuotInd
         RETURN
      ENDIF
   ENDIF
   mcontinue = "N"
ENDDO                       // mcontinue
ENDIF                       // LastRec

  QPartSearch()

SELECT Quot
SET INDEX TO QuotInd

RETURN

****---- End of QPartSearch()

*---------------------------------------------------------------------*

FUNCTION QPuotOperLst()

   mwhere := "S"

    PrintSel( mwhere )

   IF mwhere == "P"
      npl := 56
     ELSE
      npl := 20
   ENDIF
   nl := 0
   @ nl,10 SAY Control->U_Name
   nl++
   ntimeoper:= ntimeadmin := 0
   ntimetotal:= ntime := 0
   SELECT Quot
   INDEX ON Partnum TO QuotParI
   SET INDEX TO QuotParI
   GOTO TOP
   DO WHILE Quot->( !EOF() )      
      IF Quot->Invno != SPACE( 6 )
         SKIP ALIAS Quot
         LOOP
      ENDIF
      mpartnum := Quot->Partnum 
      nquotpart := 0
      DO WHILE Quot->Partnum = mpartnum .AND. Quot->( !EOF() ) 
         nquotpart += Quot->Qty
         SKIP ALIAS Quot
      ENDDO                         // EOF mpartnum
      IF nl > npl
         IF mwhere = "P"
	    EJECT
           ELSE
            WAIT
            SCROLL()
          ENDIF
          nl := 0
          @ nl,10 SAY Control->U_Name
          nl++
      ENDIF
      SELECT PartOper
      GOTO TOP
      SEEK mpartnum
      IF FOUND()    
        @ nl,10 SAY mpartnum+"  "+STR( nquotpart )
        nl++
        DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() )
           IF nl > npl
                 IF mwhere = "P"
	            EJECT
                   ELSE
                    WAIT
                    SCROLL()
                  ENDIF
                  nl := 0
           ENDIF
           IF PartOper->Desc != SPACE( 40 )
              @ nl, 0 SAY PartOper->Desc
              @ nl,42 SAY "Time"
              @ nl,47 SAY PartOper->Time PICTURE "9999.99"
              @ nl,55 SAY "Rate"
              @ nl,60 SAY PartOper->Rate PICTURE "9999.99"
              ntimetotal += PartOper->Time*PartOper->Rate
             *** @ nl,68 SAY PartOper->Task
              @ nl,74 SAY PartOper->ABC
              @ nl,76 SAY PartOper->Order
              nl++
              IF PartOper->Desc1 != SPACE( 40 )
                 @ nl, 0 SAY PartOper->Desc1
                 nl++
              ENDIF
              IF PartOper->Desc2 != SPACE( 40 )
                 @ nl, 0 SAY PartOper->Desc1
                 nl++
              ENDIF
           ENDIF   
           IF PartOper->Operno != SPACE( 8 )
              SELECT Operate
              SET ORDER TO 1                   // Operno
              SEEK PartOper->Operno
              @ nl, 0 SAY Operate->Desc
              @ nl,42 SAY "Time"
              @ nl,47 SAY Operate->Time PICTURE "9999.99"
              @ nl,55 SAY "Rate"
              @ nl,60 SAY Operate->Rate PICTURE "9999.99"
              ntimetotal += PartOper->Time*PartOper->Rate
****              ntimetotal += Operate->Time*Operate->Rate
              *** @ nl,61 SAY "Set Up"
              *** @ nl,68 SAY Operate->Setup PICTURE "999.99"
              @ nl,74 SAY PartOper->ABC
              @ nl,76 SAY PartOper->Order
              nl++
           ENDIF
/*
           IF PartOper->Adminno != SPACE( 8 )
              SELECT Admin
              SEEK PartOper->Adminno
              @ nl, 0 SAY Admin->Desc
              @ nl,42 SAY "Time"
              @ nl,47 SAY Admin->Time PICTURE "9999.99"
              @ nl,55 SAY "Rate"
              @ nl,60 SAY Admin->Rate PICTURE "9999.99"
              ntimetotal += PartOper->Time*PartOper->Rate
****              ntimetotal += Admin->Time*Admin->Rate
              nl++
           ENDIF
*/
           SELECT PartOper
           SKIP ALIAS PartOper
       ENDDO                     // PartOper EOF
   ENDIF                        // Found in PartOper
      SELECT Quot
***      SKIP ALIAS Quot
   ENDDO                        // Quot EOF
   IF nl > 18
      IF mwhere = "S"
         WAIT
         SCROLL()
         nl := 12
      ENDIF
   ENDIF    
   nl++
   @ nl,30 SAY "Total Time * Rate ="
   @ nl,52 SAY ntimetotal  PICTURE "$99,999.99"
   IF mwhere = "S"
      INKEY()
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
     ELSE
      EndPrint()
   ENDIF
SELECT Quot
SET INDEX TO QuotInd

   mcontinue := ApGetN( "Do You want Labour Print" )
   IF mcontinue == "Y"
      LabPrint()                    // LabDem
   ENDIF  
RETURN

***** End of QuotOperLst

***---------------------------------------------------------------------*

FUNCTION QPuotProf()

SCROLL()
DISPBOX( 0, 1,18,79, 2 )
@  1,20 SAY "Quote Analysis"
mstmm  := DATE()-30
mendmm := DATE()
@ 10, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
@ 11, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
 READ
***  maccepted := ApGetN( "Do You want accepted Only" )
maccepted := "N"
IF LASTKEY() == 27
   RETURN NIL
ENDIF
mok := ApGetY( "Do you want each Part Printed" )
IF LASTKEY() == 27
   RETURN NIL
ENDIF
mwhere   := "S"

  Printsel( mwhere )

nl := 0
IF mwhere == "P"
   npl := 55
 ELSE
   SCROLL()
   npl := 16
ENDIF
@  0, 0 SAY Control->U_Name
@  0,34 SAY mstmm 
@  0,47 SAY mendmm 
@  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
@  2, 0 SAY "Name"
@  2,43 SAY "Qty"
@  2,52 SAY "Cost"
@  2,62 SAY "Amount"
@  2,72 SAY "%"
nl := 4
ncostitem:= mA:= nsale := 0
SELECT Quot
GOTO TOP
DO WHILE Quot->( !EOF() )
   IF Quot->Invno != SPACE( 6 )
      SKIP ALIAS Quot
      LOOP
   ENDIF
   IF Quot->DbDate < mstmm
      SKIP ALIAS Quot
      LOOP
   ENDIF
   IF Quot->DbDate > mendmm
      SKIP ALIAS Quot
      LOOP
   ENDIF
   IF Quot->Codeno = "STOCK   "
      SKIP ALIAS Quot
      LOOP
   ENDIF
   IF maccepted = "Y"
      IF Quot->Accepted = "N"
         SKIP ALIAS Quot
         LOOP
      ENDIF
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
      @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                 +STR( YEAR(DATE() ),5 )
      @  2, 0 SAY "Name"
      @  2,43 SAY "Qty"
      @  2,52 SAY "Cost"
      @  2,62 SAY "Amount"
      @  2,72 SAY "%"
      nl := 4
   ENDIF                          // nl>npl
   mcodeno := Quot->Codeno
   SELECT Name
   SEEK mcodeno
   @ nl, 0 SAY Name->Name
  ***  @ nl,68 SAY Quot->Accepted
   nl++
   ntrade := namount:= ncost := 0
   SELECT Quot
   DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
      IF Quot->Invno != SPACE( 6 )
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF Quot->DbDate < mstmm
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF Quot->DbDate > mendmm
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF Quot->Codeno = "STOCK   "
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF maccepted = "Y"
         IF Quot->Accepted = "N"
            SKIP ALIAS Quot
            LOOP
         ENDIF
      ENDIF 
      SELECT Part
      SEEK Quot->Partnum
      SELECT Quot
      mA := ( ( Quot->Amount*( 1-Quot->Discount/100 )*100 )/100);
               *Quot->OrgQty
      ntrade    := Part->Trade*Quot->OrgQty
      nsale     += mA
      ncostitem += ntrade
      namount   += mA
      ncost     += ntrade
      IF mok = "Y"
         @ nl, 0 SAY Quot->DbDate
         @ nl,11 SAY SUBSTR( Part->Partnum, 1, 8 )
         @ nl,20 SAY SUBSTR( Part->Desc,1,18 )
         @ nl,40 SAY Quot->OrgQty PICTURE "99,999"
         @ nl,49 SAY ntrade    PICTURE "999,999.99"
         @ nl,60 SAY mA        PICTURE "9999,999.99"
         @ nl,72 SAY ( ( mA-ntrade )/mA ) * 100 PICTURE "9999 %" 
         nl++
      ENDIF
      mA:= ntrade := 0
      SKIP ALIAS Quot
   ENDDO
   nl++
   @ nl,36 SAY "Total"
   @ nl,49 SAY ncost   PICTURE "999,999.99"
   @ nl,60 SAY namount PICTURE "9999,999.99"
   @ nl,72 SAY ( ( namount-ncost )/namount ) * 100 PICTURE "9999 %" 
   nl++
   namount := ncost:= 0
ENDDO    
@  nl,45 SAY "---------------------------"
nl++
@ nl,26 SAY "GRAND TOTAL"
@ nl,48 SAY ncostitem PICTURE "$999,999.99"
@ nl,60 SAY nsale     PICTURE "9999,999.99"
nl++
@ nl,45 SAY "==========================="
nl++
@ nl,21 SAY "Sale - Cost"
@ nl,34 SAY ( nsale )-( ncostitem  )                 PICTURE "$999,999.99" 
@ nl,50 SAY ( ( ( nsale-ncostitem  ) )/nsale ) * 100 PICTURE "999 %" 
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

RETURN NIL

******* End of QPuotProf()

**---------------------------------------------------------------------*

FUNCTION QPuotAdd()

dDbDate   := DATE()
mcodeno   := SPACE ( 8 )
mpartnum  := SPACE( 20 )
cfaxno    := STR( Control->LastQuot, 8, 0 )
/*
????? is this required

IF SUBSTR( Control->U_Name, 1, 4 ) != "CHRI"
   SELECT Control
    ApRLock( 3 )
   Control->LastQuot := Control->LastQuot+1
   UNLOCK
ENDIF
*/
mcontinue := "Y"
DO WHILE mcontinue = "Y"

     Namerank( @mcodeno )                            // ZSF_Name

    IF LASTKEY() == 27
       RETURN NIL
    ENDIF
    mcodeno := Name->Codeno
    cbranchId := SPACE( 2 ) 
    SELECT Branch
    SEEK mcodeno
    IF FOUND()
  
        BranchFind( @mcodeno )             // ZSF_Name
       cbranchId := Branch->BranchId

       mok := ApGetY( "Do you Want Branch" )
       IF mok = "N"
          cbranchId := SPACE( 2 )
       ENDIF
    ENDIF
   manother := "Y"
   DO WHILE manother = "Y"
     mok := "Y"
     DO WHILE mok = "Y"
        SCROLL( 3, 0, 24,80 )
        SELECT Quot
        SEEK mcodeno
        IF FOUND()
           QPuoLook( cbranchId )                 // QuoHouse.PRG
        ENDIF
        IF Quot->Faxno != SPACE( 8 )
           SCROLL(  18, 0, 24,80 )
           DISPBOX( 18, 1, 24,79, 2 )
           @ 19, 4      SAY TRIM( Quot->Partnum )
           @ 19,COL()+1 SAY Quot->Qty 
           @ 19,COL()+2 SAY Part->Desc  COLOR "BG+" 
           @ 21, 8      SAY Quot->Faxno COLOR "BG+"
           @ 21,COL()+2 SAY Quot->Info
         ELSE 
           SCROLL(  22, 0, 24,80 )
           DISPBOX( 22, 1, 24,79, 2 )
        ENDIF
     minvno  := SPACE( 6 )
     nselect := 1
     @ 23, 4      PROMPT "Add Part"
     @ 23,COL()+3 PROMPT "Edit W/O"
     @ 23,COL()+3 PROMPT "Job Card"     
     @ 23,COL()+3 PROMPT "Module"
     @ 23,COL()+3 PROMPT "Edit Part"
     @ 23,COL()+3 PROMPT "Another"
     @ 23,COL()+3 PROMPT "Cost"
     MENU TO nselect

     DO CASE
       CASE LASTKEY() == 27
         RETURN
       CASE nselect == 1
          quotcodeno := SPACE( 8 )
          mpartnum := SPACE( 20 )
           QPuotPAdd( @mpartnum )                 // QuoHouse
          LOOP
       CASE nselect == 2
           QPuotEdit( @mcodeno )                         // Below
          LOOP
       CASE nselect == 3
          mcodeno := Name->Codeno
          cfaxno  := Quot->Faxno
           QPuotJSheet( @mcodeno, cfaxno )                      // Below                          
***           QPuotEdit( @mcodeno )                      // Below                          
          LOOP
      CASE nselect == 4
          mmodcode := TRIM( mpartnum )
           EquModule( @mmodcode )
          LOOP
      CASE nselect == 5                     //   Qty Desc 
        tempscrn := SAVESCREEN( 0, 0, 24,80 )
        mpartnum := Part->Partnum
        cedit := "N"                            // N = Total Stock   
          ProfQty( cedit )                        // XLF_Prof
        RESTSCREEN(  0, 0, 24,80,tempscrn )
        LOOP
      CASE nselect == 6                     //   Qty Desc 
        LOOP
      CASE nselect == 7
        mcodeno := Name->Codeno
          WoHouCost( mcodeno )             // QuoHouse
        manother := "Y" 
        LOOP
      ENDCASE
   ENDDO                               // End of more Parts
ENDDO
   mcontinue := "N"

ENDDO                                   // mcontinue

RETURN NIL

****----- End of QPuotadd()

**-------------------------------------------------------------------

FUNCTION QPuotIndi( mcodeno, cfaxno )

cprice     := ApGetY( "Do You Want Prices" )
cequ       := ApGetY( "Do You Want Module Parts" )
*** cboughtout := ApGetY( "Bought Out and No Stock ONLY" )
cboughtout := "N"
ctotal     := ApGetY( "All Parts This Client" )
nl := 4

  PrintSel()

IF mwhere = "P"
      @  0, 0
      SET DEVICE TO PRINT
      npl := 65
    ELSE
      SCROLL()
      npl := 18
   ENDIF
mfirst := "Y"
SELECT Quot
ntotal:= ngtotal:= nweight:= nequcost:= nequsell := 0
npartcost := 0
ncnt := 0
mordnum := SPACE( 16 )
nqty1:= nqty2:= nqty3:= nqty4 := 0
nrecno2:= nrecno3 := 0
nequ1:= nequ2:= nequ3:=nequ4 := 0
GOTO TOP
SEEK mcodeno
DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
****   cfaxno := Quot->Faxno
   IF ctotal != "Y"
      IF Quot->Faxno != cFaxno
         SKIP ALIAS Quot
         LOOP
      ENDIF
   ENDIF                    // cbranchId
   IF cbranchId != SPACE( 2 )
      IF Quot->BranchId != cbranchId
         SKIP ALIAS Quot
         LOOP
      ENDIF
   ENDIF                    // cbranchId
   IF Quot->Invno != SPACE( 6 )
      SKIP ALIAS Quot
      LOOP
   ENDIF
   IF mfirst = "Y"
      nl := QuotHead()
      mfirst := "N"
   ENDIF 
   IF mwhere = "P" .AND. nl >= 55              // Adjust no of items
      @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
      SET DEVICE TO SCREEN
      @ 12,10 SAY " "
      @ 14,10 SAY "ALIGN PAPER to TOP OF PAGE"
      @ 16,10 SAY " WAIT FOR PRINTER TO STOP"
      WAIT
      SET DEVICE TO PRINT
        
***      nl := QuotHead()                 //

      ELSEIF ROW() = 18
       WAIT
       nl := 0
       SCROLL()
   ENDIF                                // mwhere
   mpartnum := Quot->Partnum
   IF mpartnum != SPACE( 20 )
      SELECT Part
      SET ORDER TO 1                    // Partnum
      SEEK mpartnum
/*
      SELECT Cusnotes
      cdetail := ""
      coderef := Part->Partnum
      SEEK coderef
      IF FOUND()
          GetDets( coderef )                            // XF_Memo2
          FormP( cdetail,60,10 )                        // XF_Memo2
***          nl++
      ENDIF
*/
      SELECT Part
      @ nl, 0 SAY Part->Partnum        // Reduced Part Number
      @ nl,18 SAY Part->Desc          // Can reduce Desc
      nl++
      npartcost += Part->Trade*Quot->Qty
      IF Part->Detail != SPACE( 40 )
         @ nl, 9 SAY Part->Detail
         nl++
      ENDIF
      IF Quot->Info  != SPACE( 45 )
         @ nl,10 SAY Quot->Info
         nl++
      ENDIF
      IF Quot->Info2 != SPACE( 45 )
         @ nl,10 SAY Quot->Info2
         nl++
      ENDIF
      IF Quot->Info3 != SPACE( 45 )
         @ nl,10 SAY Quot->Info3
         nl++
      ENDIF
      IF Quot->Info4 != SPACE( 45 )
         @ nl,10 SAY Quot->Info4
         nl++
      ENDIF
      IF Quot->Info5 != SPACE( 45 )
         @ nl,10 SAY Quot->Info5
         nl++
      ENDIF
      IF Quot->Info6 != SPACE( 45 )
         @ nl,10 SAY Quot->Info6
         nl++
      ENDIF
      IF Quot->Info7 != SPACE( 45 )
         @ nl,10 SAY Quot->Info7
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
      SELECT Quot
      @ nl,18 SAY Quot->OrgQty       PICTURE "99,999.99"
      mA := ( Quot->Amount*(1-Quot->Discount/100 )*100 ) /100.00
      IF cprice = "Y"
         @ nl,30 SAY Part->Trade  PICTURE "$999,999.99"
         @ nl,43 SAY "Each" 
         @ nl,48 SAY Quot->Amount PICTURE "$999,999.99"
         IF Quot->Discount > 0
            @ nl,61 SAY STR( Quot->Discount,2 )+" %"
         ENDIF
         @ nl,67 SAY mA*Quot->OrgQty PICTURE "$999,999.99"
      ENDIF                           // cprice with Prices
      nl++
      ngtotal += mA*Quot->OrgQty
      ntotal  += Quot->Amount*Quot->OrgQty            
   ENDIF
   IF cequ = "Y"                             // Module Parts Required
      mmodcode := TRIM( Quot->Partnum ) 
      SELECT Equ
      SET EXACT ON
      GOTO TOP
      mmod1   := TRIM( mpartnum )
      SEEK mmod1
      IF FOUND()
         DO WHILE  Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
            nqty := Quot->OrgQty*Equ->PartQty
            IF mwhere = "S"
               IF nl > 18
                  WAIT
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            nl++
            SELECT Part
            SEEK Equ->Partnum
            @ nl, 0 SAY "."  
            @ nl, 2 SAY STR( nqty, 9, 3 )+" "+TRIM( Equ->Partnum );
                        +"   "+TRIM( Part->Desc )+" "+STR( Part->Trade, 9, 2 )
            nl++
            IF cboughtout = "Y"
               IF Part->Boughtout = "Y"
                  IF cprice = "Y"
                     IF Part->Instock < nQty 
                        @ nl,14 SAY "Instock "+STR( Part->Instock, 9, 2 )
                        @ nl,32 SAY "Cost "+TRIM( Part->Unit )+STR( Part->Trade, 9, 2 )
                                     nequcost += nQty*Part->Trade
                        @ nl,52 SAY "Qty*Cost "+STR( nQty*Part->Trade, 9, 2 )
                        nl++
                     ENDIF
                  ENDIF
               ENDIF                               // cprice
             ELSE
               @ nl,14 SAY "Instock "+STR( Part->Instock, 9, 2 )
               @ nl,32 SAY "Cost "+TRIM( Part->Unit )+STR( Part->Trade, 9, 2 )
                          nequcost += nQty*Part->Trade
               @ nl,52 SAY "Qty*Cost "+STR( nQty*Part->Trade, 9, 2 )
               nl++
            ENDIF                                  // Boughtout  
      SELECT Equ
      mmod2   := TRIM( Equ->Partnum )
      nrecno2 := RECNO()
      GOTO TOP
      SEEK mmod2
      IF FOUND()
         DO WHILE  Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
            nqty2 := nqty*Equ->PartQty
            IF mwhere = "S"
               IF nl > 18
                  WAIT
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            SELECT Part
            SEEK Equ->Partnum
            @ nl, 0 SAY ".."
            @ nl, 4 SAY STR( nqty2, 9, 3 )+" "+TRIM( Equ->Partnum );
                      +"  "+TRIM( Part->Desc )
            nl++
            IF cboughtout = "Y"
               IF Part->Boughtout = "Y"
                  IF cprice = "Y"
                     IF Part->Instock < nQty2 
                        @ nl,14 SAY "Instock "+STR( Part->Instock, 9, 2 )
                        @ nl,32 SAY "Cost "+TRIM( Part->Unit )+STR( Part->Trade, 9, 2 )
                                     nequcost += nQty2*Part->Trade
                        @ nl,52 SAY "Qty*Cost "+STR( nQty2*Part->Trade, 9, 2 )
                        nl++
                     ENDIF
                  ENDIF
               ENDIF                               // cprice
             ELSE
               @ nl,14 SAY "Instock "+STR( Part->Instock, 9, 2 )
               @ nl,32 SAY "Cost "+TRIM( Part->Unit )+STR( Part->Trade, 9, 2 )
                            nequcost += nQty2*Part->Trade
               @ nl,52 SAY "Qty*Cost "+STR( nQty2*Part->Trade, 9, 2 )
               nl++
            ENDIF                                  // Boughtout  
      SELECT Equ
      mmod3   := TRIM( Equ->Partnum )
      nrecno3 := RECNO()
      GOTO TOP
      SEEK mmod3
      IF FOUND()
         DO WHILE  Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
            IF mwhere = "S"
               IF nl > 18
                  WAIT
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            SELECT Part
            SEEK Equ->Partnum
            nqty3 := nQty2*Equ->PartQty
            @ nl, 0 SAY "..."
            @ nl, 6 SAY STR( nqty3, 9, 3 )+" "+TRIM( Equ->Partnum );
                      +"  "+TRIM( Part->Desc )
            nl++
            IF cboughtout = "Y"
               IF Part->Boughtout = "Y"
                  IF cprice = "Y"
                     IF Part->Instock < nQty3 
                        @ nl,14 SAY "Instock "+STR( Part->Instock, 9, 2 )
                        @ nl,32 SAY "Cost "+TRIM( Part->Unit )+STR( Part->Trade, 9, 2 )
                                     nequcost += nQty3*Part->Trade
                        @ nl,52 SAY "Qty*Cost "+STR( nQty3*Part->Trade, 9, 2 )
                        nl++
                     ENDIF
                  ENDIF
               ENDIF                               // cprice
             ELSE
               @ nl,14 SAY "Instock "+STR( Part->Instock, 9, 2 )
               @ nl,32 SAY "Cost "+TRIM( Part->Unit )+STR( Part->Trade, 9, 2 )
                           nequcost += nQty3*Part->Trade
               @ nl,52 SAY "Qty*Cost "+STR( nQty3*Part->Trade, 9, 2 )
               nl++
            ENDIF                                  // Boughtout  
/*
            IF Part->Detail != SPACE( 43 )
               @ nl,12 SAY Part->Detail
               nl++
            ENDIF
            IF Part->Detail1 != SPACE( 43 )
               @ nl,12 SAY Part->Detail1
               nl++
            ENDIF
            IF Part->Detail2 != SPACE( 43 )
               @ nl,12 SAY Part->Detail2
               nl++
            ENDIF
            IF Part->Detail3 != SPACE( 43 )
               @ nl,12 SAY Part->Detail3
               nl++
            ENDIF
      IF Part->PartMat != SPACE( 20 )
         nlength := nQty3*Part->Length 
         SELECT Part
         SEEK Part->PartMat
         @ nl,16 SAY TRIM( Part->Desc )+"  "+TRIM( Part->Partnum )
         nl++
         IF Part->Length > 0
            @ nl,16 SAY nlength/Part->Length PICTURE "999,999.999"
            @ nl,28 SAY "Required Each Length "+TRIM( Part->Unit );
                        +" "+STR( Part->Length )
         ENDIF
         nl++
      ENDIF                     // PartMat
*/
            SELECT Equ 
            SKIP ALIAS Equ
          ENDDO                       //  mmod3
       ENDIF                          // FOUND()  mmod3    
            SELECT Equ 
            GOTO nrecno3 
            SKIP ALIAS Equ
          ENDDO                       // mmod2
       ENDIF                          // FOUND()  mmod2    
            SELECT Equ
            GOTO nrecno2   
            SKIP ALIAS Equ
          ENDDO                       // mmod1
       ENDIF                          // FOUND()  mmod1    
       SET EXACT OFF
  ENDIF                              // mequ
     nl++
     SELECT Quot
     SKIP ALIAS Quot
   ENDDO                                // EOF Quot
/*

TAKEN OUT TEST IF WANTED USED IF LABOUR SYSTEM USED

  IF cprice = "Y"
    IF ( ntotal-ngtotal ) > 0
       @ nl, 9 SAY "Parts Discount ="
       @ nl,27 SAY ntotal-ngtotal PICTURE "$99,999.99"
       nl++
    ENDIF                        // ndisctotal
     nl++
     @ nl,23 SAY "Parts Cost "+STR( nequcost, 9, 2 )
     @ nl,58 SAY "Parts Sell "+STR( ngtotal, 9, 2 )
  ENDIF
   nl++
*/
   ncost := 0   
   SELECT Labour
   GOTO TOP
   DO WHILE Labour->( !EOF() )
      IF Labour->Invno != Debit->Invno
         SKIP ALIAS Labour
         LOOP
      ENDIF 
      IF Labour->Labno != Debit->Codeno          // This is the Invoice Code
         SKIP ALIAS Labour
         LOOP
      ENDIF
      IF mwhere = "P" .AND. nl >= 55              // Adjust no of items
         @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
         SET DEVICE TO SCREEN
         @ 12,10 SAY " "
         @ 14,10 SAY "ALIGN PAPER to TOP OF PAGE"
         @ 16,10 SAY " WAIT FOR PRINTER TO STOP"
         INKEY( 0 )
         SET DEVICE TO PRINT
        
***         nl := QuotHead()                 // Below

      ELSEIF ROW() = 22
          WAIT
          nl := 0
          SCROLL()
   ENDIF                                // mwhere
      ncost += Labour->Time*Labour->Rate 
      @ nl, 0 SAY Labour->Codeno+" "+Labour->Desc;
           +" "+STR( Labour->Time,5, 2 )+" "+STR( Labour->Rate,6, 2 );
           +" "+DTOC( Labour->Date ) 
      SKIP ALIAS Labour
      nl++
   ENDDO
   nl++
   IF ncost > 0
      @ nl,50 SAY "Labour Costs"
      @ nl,68 SAY  ncost PICTURE "999,999.99"
      nl++
   ENDIF
   nl++
   ngtotal += ncost 
IF mwhere == "P"
  IF cprice = "Y"
    IF ( ntotal-ngtotal ) > 0
       @ nl, 9 SAY "Total Discount ="
       @ nl,27 SAY ntotal-ngtotal PICTURE "$99,999.99"
    ENDIF                        // ndisctotal
    nl++
***             +"  Total Kit Sell "+STR( nequsell,9, 2 )
    @ nl,69 SAY ngtotal PICTURE "99,999.99"
    nl++
    @ nl, 0 SAY "O/S Costs "+STR( nequcost,9, 2 )
***    @ 42, 0 SAY Control->Con_note3
    ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
    IF SUBSTR( Name->Add5,1,7 ) != "AUSTRAL"
       mA := ( ngtotal+ngsttot )
       @ nl,69 SAY ngsttot PICTURE "99,999.99"
       nl++
     ELSE
       mA := ngtotal
    ENDIF
    @ nl,69 SAY mA PICTURE "99,999.99"
  ENDIF                                 // cprice
  nl++
***  @ nl,68 SAY ngtotal PICTURE "$999,999.99"
***   @ 63, 0 SAY TRIM( Debit->Est )+"   "+Debit->Fault
   EndPrint()
  ELSE
/*
   IF nl >= 22
      WAIT
      nl := 0
      SCROLL()
   ENDIF                                // mwhere
   IF cprice = "Y"
      ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
      IF SUBSTR( Name->Add5,1,7 ) != "AUSTRAL"
         @ nl,68 SAY ( INT( ( ngtotal+ngsttot )*100 )/100 ) PICTURE "$99,999.99"
       ELSE

      ENDIF
   ENDIF                            // cprice
*/
***   nl++
***   @ nl, 0 SAY Debit->Est
***   nl++
***   @ nl, 0 SAY Debit->Fault
***   nl++
***   @ nl, 0 SAY Debit->Message
***   nl+=2
***   @ nl,44 SAY nweight PICTURE "9,999.99"
***   @ nl,53 SAY "kg"
   IF nl > 18
      WAIT
   ENDIF
   mok := "N"
   DO WHILE mok = "N"
      mok := ApReadN()
   ENDDO
ENDIF
SET MARGIN TO 0

RETURN NIL

*** End of QPuotIndi()

*********----------  END OF FILE CHRIQPAR.PRG
