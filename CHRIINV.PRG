*** JoKir11 20-11-11 10:17:43 

**** REM   Christine Products Invoice

/*  Program.....:                  CHRIINV.PRG
    Authors.....: J.Kirby
    Date........: 13/06/1993
    Functions...: DebitFind, MenuInv()
*/

#include "pcodeaah.CH"

FUNCTION IvcHeadTot( mtype )

IF mwhere == "P"
   nl := 0
   @ nl, 0 SAY " "
***   @ nl, 0 SAY P_COND
   @ nl, 1 SAY Control->U_Name
***   nl++
***   @ nl, 6 SAY "Manufacturers & General Engineers"
   nl++
   @ nl, 1 SAY "FACTORY ADDRESS"
   @ nl,43 SAY "POSTAL ADDRESS"
   nl++
   @ nl, 1 SAY Control->U_Add1
   @ nl,43 SAY Control->U_Add2
   nl++
   @ nl, 1 SAY Control->U_Add3
   @ nl,43 SAY Control->U_Add3
   nl++
   @ nl, 1 SAY Control->U_Add4
   @ nl,43 SAY Control->U_Add4
   nl++
   @ nl, 1 SAY "Phone "+Control->U_Phone
   nl++
   @ nl, 1 SAY "Fax   "+Control->U_Fax
***   @ nl,43 SAY "www.christineproducts.co.nz"
   nl+=2
   @ nl, 1 SAY Name->Name                // This is Company Name
   IF Debit->BranchId != SPACE(2)
      SELECT Branch
      mfind := Debit->Codeno+Debit->BranchId
      SEEK mfind
      @ nl,43 SAY Branch->Name
    ELSE
     @ nl,43 SAY Name->Name
   ENDIF
   nl++
   @ nl, 1 SAY Name->Add1
   IF Debit->BranchId != SPACE(2)
      @ nl,43 SAY Branch->Add1
    ELSE
      @ nl,43 SAY Name->Add1
   ENDIF
   nl++
   @ nl, 1 SAY Name->Add2
   IF Debit->BranchId != SPACE(2)
      @ nl,43 SAY Branch->Add2
     ELSE
      @ nl,43 SAY Name->Add2
   ENDIF
   nl++
   @ nl, 1 SAY Name->Add3
   IF Debit->BranchId != SPACE(2)
      @ nl,43 SAY Branch->Add3
     ELSE
      @ nl,43 SAY Name->Add3
   ENDIF
   nl++
   @ nl, 1 SAY TRIM( Name->Add4 )+" "+Name->Phone
   IF Debit->BranchId != SPACE(2)
      @ nl,43 SAY ( Branch->Add4 )+" "+Branch->Phone
    ELSE
      @ nl,43 SAY TRIM( Name->Add4 )+" "+Name->Phone
   ENDIF
   nl++
   nl++
   @ nl, 0 SAY "---------------------------------------------------------------------------------"
   nl++
   @ nl, 0 SAY "O/N  "+mordnum
   @ nl,24 SAY Debit->Codeno
   @ nl,34 SAY Debit->Dbdate PICTURE "99/99/9999"
   @ nl,52 SAY mtype+"  "+Debit->Invno
   nl++
   @ nl, 0 SAY "---------------------------------------------------------------------------------"
   nl++
   @ nl, 0 SAY "Code"
   @ nl, 9 SAY "Description"
   @ nl,49 SAY "Qty"
   @ nl,57 SAY "Price"
   @ nl,72 SAY "Amount"
   nl+=2
ENDIF

RETURN

*** End of IvcHeadTot()

**-------------------------------------------------------------------

FUNCTION IvcFormB( mtype )       // Standard Paper Invoice

SCROLL()
ntotal:= ngtotal:= ngsttot:= nweight := 0
nl := 0
SELECT Invoice
GOTO TOP
SET ORDER TO 2            // Invno+Ordnum
minvno := Debit->Invno
SEEK minvno
mordnum := Invoice->Ordnum
IF mwhere = "P"
   SET DEVICE TO PRINT
   IvcHeadTot( @mtype )                  // Above
 ELSE
   nl := 0
   @ nl, 3 SAY Name->Name                // This is Company Name
   nl++
   @ nl, 3      SAY Name->Add1
   @ nl,COL()+4 SAY Name->Add2
   @ nl,COL()+4 SAY Debit->BranchId
   nl++
   @ nl, 3 SAY TRIM( Name->Add4 )+" "+Name->Phone
   nl++
   nl++
   @ nl, 0 SAY "-----------------------------------------------------------------------------"
   nl++
   @ nl, 2     SAY "O/N "+mordnum
   @ nl,20     SAY Debit->Codeno
   @ nl,COL()+4 SAY Debit->Dbdate PICTURE "99/99/9999"
   @ nl,COL()+4 SAY "INVOICE No "+Debit->Invno
   nl++
   @ nl, 0 SAY "-----------------------------------------------------------------------------"
   nl++
ENDIF
DO WHILE Invoice->Invno = minvno .AND. Invoice->( !EOF() )
   IF mwhere = "S" .AND. nl >= 18
      WAIT
      SCROLL()
      nl := 0
   ENDIF
   IF mwhere = "P" .AND. nl >= 40              // Adjust no of items
****      @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
***      @  0, 0 SAY P_PL51
      nl := IvcHeadTot()                 // Above
   ENDIF                                // mwhere
   mpartnum := Invoice->Partnum
   IF SUBSTR( Invoice->Ordnum, 1, 4 ) != "ZZZZ"
      IF Invoice->Ordnum != SPACE(16)
         IF Invoice->Ordnum != mordnum      
            @ nl,12 SAY "O/N "+Invoice->Ordnum
            nl++
            mordnum := Invoice->Ordnum 
         ENDIF                             // Ordnum Changed
      ENDIF                                // Ordnum SPACE(16)
   ENDIF                                   // != ZZ
   IF mpartnum != SPACE( 20 )
      SELECT Part
      SEEK mpartnum
      IF Part->PartId != "AAAA"
         @ nl, 0 SAY SUBSTR( Part->Partnum,1,8 )        // Reduced Part Number
      ENDIF
      SELECT Part
      @ nl, 9 SAY SUBSTR( Part->Desc,1,36 )        // Can reduce Desc
      SELECT Invoice
      @ nl,48 SAY Invoice->Qty                  PICTURE "9999"
      @ nl,53 SAY Invoice->Amount               PICTURE "999,999.99"
      IF Invoice->Discount > 0
         @ nl,63 SAY STR( Invoice->Discount, 2 )+"%"
      ENDIF
      mA := ( Invoice->Amount*(1-Invoice->Discount/100 )*100 ) /100.00
      @ nl,67 SAY mA*Invoice->Qty               PICTURE "999,999.99"
      nl++
      IF Invoice->Info != SPACE( 45 )
         @ nl, 3 SAY Invoice->Info
         nl++
      ENDIF
      IF Invoice->Info2 != SPACE( 45 )
         @ nl, 3 SAY Invoice->Info2
         nl++
      ENDIF
      IF Invoice->Info3 != SPACE( 45 )
         @ nl, 3 SAY Invoice->Info3
         nl++
      ENDIF
      IF Invoice->Info4 != SPACE( 45 )
         @ nl, 3 SAY Invoice->Info4
         nl++
      ENDIF
      ngtotal := ngtotal            +( mA*Invoice->Qty )
      ntotal  := ntotal+( Invoice->Amount*Invoice->Qty )            
      nweight := nweight+(Invoice->Qty*Part->Weight )
   ENDIF
   SELECT Invoice
   SKIP ALIAS Invoice
ENDDO
SELECT Invoice
SET ORDER TO 1
IF mwhere == "P"
   nl := 40
   IF ( ntotal-ngtotal ) > 0
      @ nl, 6 SAY "Total Discount ="
      @ nl,24 SAY ntotal-ngtotal PICTURE "$99,999.99"
   ENDIF                        // ndisctotal
***   @ nl,44 SAY nweight PICTURE "9,999.99"
***   @ nl,53 SAY "kg"
   nl++
   @ nl, 0 SAY Control->Con_note1
   nl++
   @ nl, 0 SAY Control->Con_note2
   @ nl,58 SAY "Sub Total"
   @ nl,68 SAY ngtotal PICTURE "999,999.99"
   nl++
   @ nl, 0 SAY Debit->Note1
   nl++
   @ nl, 0 SAY Debit->Note2
   IF SUBSTR( Debit->Saleno, 1, 2 ) != SUBSTR( Message->Saleno5, 1, 2 )
      ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
      mA := ( ngtotal+ngsttot )
      @ nl,58 SAY "G.S.T."
      @ nl,69 SAY ngsttot PICTURE "99,999.99"
    ELSE
      mA := ngtotal
   ENDIF
   nl++
   @ nl, 0 SAY Debit->Note3
   nl+=2
   @ nl,27 SAY "G.S.T.Reg No "+Control->U_Gstno
   @ nl,56 SAY "Total"
   @ nl,66 SAY mA PICTURE "999,999.99"
   SELECT Debit
    ApRLock( 3 )
   Debit->Amount   := mA
   Debit->InitAmnt := mA
   Debit->Tax      := ngsttot
   Debit->Freight  := nweight
   UNLOCK
   nl+= 3
****   IvcBottom()                    // Below
   EndPrint()
  ELSE
   nl := 22
   @ nl,20      SAY "Weight" COLOR "RG"
   @ nl,COL()+1 SAY nweight PICTURE "9,999.99"
   @ nl,COL()+1 SAY "kg"
   @ nl,48 SAY Debit->Saleno
   nl++
   ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
   IF ( ntotal-ngtotal ) > 0
      @ nl, 6 SAY "Total Discount ="
      @ nl,24 SAY ntotal-ngtotal PICTURE "$99,999.99"
      nl++
   ENDIF                        // ndisctotal
   IF SUBSTR( Debit->Saleno, 1, 2 ) != SUBSTR( Message->Saleno5, 1, 2 )
      @ nl,58 SAY "Incl GST" COLOR "R"
      @ nl,68 SAY ( INT( ( ngtotal+ngsttot )*100 )/100 ) PICTURE "$999,999.99"
    ELSE
      @ nl,54 SAY "Export No GST" COLOR "R"
      @ nl,68 SAY ngtotal PICTURE "$999,999.99"
   ENDIF
   SELECT Debit
    ApRLock( 3 )
   Debit->Freight  := nweight
   UNLOCK
   WAIT
ENDIF
SET MARGIN TO 0

RETURN NIL

*** End of IvcFormB()

**-------------------------------------------------------------------

FUNCTION PackSlip( mtype )

SCROLL()
nl := 0
ntotal:= ngtotal:= ngsttot:= nweight := 0
SELECT Invoice
GOTO TOP
SET ORDER TO 2            // Invno+Ordnum
minvno := Debit->Invno
SEEK minvno
mordnum := Invoice->Ordnum
IF mwhere  = "P"
   SET DEVICE TO PRINT
   IvcHeadTot( @mtype )                  // Above
  ELSE
   nl := 0
   @ nl, 3 SAY Name->Name                // This is Company Name
   nl++
   @ nl, 3      SAY Name->Add1
   @ nl,COL()+4 SAY Name->Add2
   @ nl,COL()+4 SAY Debit->BranchId
   nl++
   @ nl, 3      SAY Name->Add3
   nl++
   @ nl, 3 SAY TRIM( Name->Add4 )+" "+Name->Phone
   nl++
   @ nl, 0 SAY "---------------------------------------------------------------------------------"
   nl++
   @ nl, 2      SAY mordnum
   @ nl,COL()+7 SAY Debit->Codeno
   @ nl,COL()+6 SAY Debit->Dbdate PICTURE "99/99/9999"
   @ nl,COL()+3 SAY "PACKING SLIP No"
   IF Debit->Saleno = "MANU"  
      @ nl,12 SAY Debit->Invno+"M"
     ELSE
      @ nl,12 SAY Debit->Invno
   ENDIF
   nl++
   @ nl, 0 SAY "---------------------------------------------------------------------------------"
   nl++
ENDIF
DO WHILE Invoice->Invno = minvno .AND. Invoice->( !EOF() )
   IF mwhere = "S" .AND. nl >= 18
      WAIT
      SCROLL()
      nl := 0
   ENDIF
   IF mwhere = "P" .AND. nl >= 40              // Adjust no of items
      EJECT
      nl := 0
      nl := IvcHeadTot()                 // Above
   ENDIF                                // mwhere
   mpartnum := Invoice->Partnum
   IF SUBSTR( Invoice->Ordnum, 1, 4 ) != "ZZZZ"
      IF Invoice->Ordnum != SPACE(16)
         IF Invoice->Ordnum != mordnum      
            @ nl,11 SAY "O/N "+Invoice->Ordnum
            nl++
            mordnum := Invoice->Ordnum 
         ENDIF                             // Ordnum Changed
      ENDIF                                // Ordnum SPACE(16)
   ENDIF                                   // != ZZ
   IF mpartnum != SPACE( 20 )
      SELECT Part
      SEEK mpartnum
      IF Part->PartId != "AAAA"
         @ nl, 0 SAY SUBSTR( Part->Partnum,1,8 )        // Reduced Part Number
      ENDIF
      SELECT Part
      @ nl, 9 SAY SUBSTR( Part->Desc,1,36 )        // Can reduce Desc
      SELECT Invoice
      @ nl,48 SAY Invoice->Qty                  PICTURE "9999"
      mA := ( Invoice->Amount*(1-Invoice->Discount/100 )*100 ) /100.00
      IF mselect = "Y"
         @ nl,53 SAY Invoice->Amount               PICTURE "999,999.99"
         IF Invoice->Discount > 0
            @ nl,63 SAY STR( Invoice->Discount, 3 )+" %"
         ENDIF
         @ nl,67 SAY mA*Invoice->Qty               PICTURE "999,999.99"
      ENDIF           // mselect = Y
      nl++
      IF Invoice->Info != SPACE( 45 )
         @ nl, 3 SAY Invoice->Info
         nl++
      ENDIF
      IF Invoice->Info2 != SPACE( 45 )
         @ nl, 3 SAY Invoice->Info2
         nl++
      ENDIF
      IF Invoice->Info3 != SPACE( 45 )
         @ nl, 3 SAY Invoice->Info3
         nl++
      ENDIF
      IF Invoice->Info4 != SPACE( 45 )
         @ nl, 3 SAY Invoice->Info4
         nl++
      ENDIF

      ngtotal := ngtotal            +( mA*Invoice->Qty )
      ntotal  := ntotal+( Invoice->Amount*Invoice->Qty )            
      nweight := nweight+(Invoice->Qty*Part->Weight )
   ENDIF
   SELECT Invoice
   SKIP ALIAS Invoice
ENDDO
SELECT Invoice
SET ORDER TO 1
IF mwhere == "P"
   nl := 40
   IF mselect = "Y"
      IF ( ntotal-ngtotal ) > 0
         @ nl, 9 SAY "Total Discount ="
         @ nl,27 SAY ntotal-ngtotal PICTURE "$99,999.99"
      ENDIF                        // ndisctotal
   ENDIF
***   @ nl,44 SAY nweight PICTURE "9,999.99"
***   @ nl,53 SAY "kg"
   nl++
   @ nl, 0 SAY Control->Con_note1
   nl++
   @ nl, 0 SAY Control->Con_note2
   IF mselect = "Y"
      @ nl,58 SAY "Sub Total"
      @ nl,68 SAY ngtotal PICTURE "999,999.99"
   ENDIF
   nl++
   @ nl, 0 SAY Debit->Note1
   nl++
   @ nl, 0 SAY Debit->Note2
   IF mselect = "Y"
      IF SUBSTR( Debit->Saleno, 1, 2 ) != SUBSTR( Message->Saleno5, 1, 2 )
         ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
         mA := ( ngtotal+ngsttot )
         @ nl,58 SAY "G.S.T."
         @ nl,67 SAY ngsttot PICTURE "$99,999.99"
       ELSE
         mA := ngtotal
      ENDIF
   ENDIF             // mselect Y
   nl++
   @ nl, 0 SAY Debit->Note3
   nl+=2
   IF mselect = "Y"
      @ nl,56 SAY "Total"
      @ nl,66 SAY mA PICTURE "$999,999.99"
      nl++
      @ nl,29 SAY "G.S.T. Reg No."
      @ nl,45 SAY Control->U_Gstno
   ENDIF
   nl+= 3
****   IvcBottom()                    // Above
   EndPrint()
  ELSE
   nl := 22
   @ nl,20      SAY "Weight" COLOR "RG"
   @ nl,COL()+1 SAY nweight PICTURE "9,999.99"
   @ nl,COL()+1 SAY "kg"
   @ nl,48 SAY Debit->Saleno
   IF mselect = "Y"
      nl++
      IF ( ntotal-ngtotal ) > 0
         @ nl, 6 SAY "Total Discount ="
         @ nl,24 SAY ntotal-ngtotal PICTURE "$99,999.99"
      ENDIF                        // ndisctotal
      ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
      IF SUBSTR( Debit->Saleno, 1, 2 ) != SUBSTR( Message->Saleno5, 1, 2 )
         @ nl,58 SAY "Incl GST" COLOR "R"
         @ nl,68 SAY ( INT( ( ngtotal+ngsttot )*100 )/100 ) PICTURE "$999,999.99"
       ELSE
         @ nl,54 SAY "Export No GST" COLOR "R"
         @ nl,68 SAY ngtotal PICTURE "$999,999.99"
      ENDIF
   ENDIF
   nl++
   @ nl, 0 SAY " "
   WAIT
ENDIF

RETURN

*** End of PackSlip()

**-------------------------------------------------------------------

FUNCTION DebitFind( mcodeno )

   SELECT Debit
   SET ORDER TO 1          // Codeno
   mtempcode := "A       "
   GOTO TOP
   SEEK mtempcode
   IF !FOUND()
       ApFLock( 3 )
      APPEND BLANK
      Debit->Codeno := "A      " 
      UNLOCK
   ENDIF
   cbranchId := SPACE( 2 )
   SCROLL()
   DISPBOX( 0, 5, 2,30, 2 )
   @  1, 8 SAY "Select Invoice"
   DISPBOX( 8, 5,16,30, 2 )
   SELECT Quot
   GOTO TOP
      nl:= nll:= nlll := 3
      npl:= npll := 20 
      ccodeno := SPACE( 10 )
      @  2,47 SAY "Goods to be Invoiced" COLOR "RG+"
      DO WHILE Quot->( !EOF() )
          IF Quot->GoodSent <= 0
             SKIP ALIAS Quot
             LOOP
          ENDIF
          IF Quot->Codeno+Quot->BranchId = ccodeno
             SKIP ALIAS Quot
             LOOP
          ENDIF
          DO CASE
             CASE nl <= npl
                 @ nl,45   SAY Quot->Codeno+" "+Quot->BranchId
                 nl++
             CASE nll <= npll
                 @ nll,57  SAY Quot->Codeno+" "+Quot->BranchId
                 nll++
             OTHERWISE
                 @ nlll,69 SAY Quot->Codeno+" "+Quot->BranchId
                 nlll++
          ENDCASE 
          ccodeno := Quot->Codeno+Quot->BranchId
          SKIP ALIAS Quot
      ENDDO                          // EOF()
         nsel := 1
         @ 10, 8 PROMPT "Existing Invoices"
         @ 12, 8 PROMPT "Select by Name   "
         @ 14, 8 PROMPT "Goods Issued Only" 
         MENU TO nsel
         DO CASE
            CASE LASTKEY() == 27
               RETURN NIL
    CASE nsel == 1
         SCROLL( 0, 0,24,44 )
         mcodeno := SPACE( 8 )
         nrecno  := 0
         aPart_  := {}
         SELECT Debit
         SET ORDER TO 1    // Codeno+BranchId
         GOTO TOP
   IF LASTREC() != 0
      DO WHILE Debit->( !EOF() )
          IF Debit->Codeno+Debit->BranchId = mcodeno
             SKIP ALIAS Debit
             LOOP
          ENDIF
          SELECT Name
          SEEK Debit->Codeno
          SELECT Debit
          mcodeno := Debit->Codeno+Debit->BranchId
          AADD( aPart_,Name->Name+"   "+Debit->BranchId;
               +"             "+STR( RECNO(),6 ) )
          SKIP ALIAS Debit
      ENDDO                          // EOF()
      @ 24,20 SAY "F2 To Add New Invoice"     COLOR "GB+"
      DISPBOX( 0, 1, 23,41, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum   := ACHOICE( 1, 3, 22,40, aPart_,,"AFUNC" )    
         nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
         IF LASTKEY() == 27 
            RETURN NIL
         ENDIF
         IF LASTKEY() == -1
             mcodeno := SPACE( 8 )
              Namerank( @mcodeno )                // XLF_Name
             IF LASTKEY() == 27 
                RETURN NIL
             ENDIF
             SELECT Name
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

        ELSE
            GOTO nrecno
            mcodeno   := Debit->Codeno
            cbranchid := Debit->BranchId 
            SELECT Name
            SEEK mcodeno
         ENDIF
      ENDIF
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @  1,10 SAY Name->Name
       ENDIF                        // LastRec

     CASE nsel == 2     // By Name
         mcodeno := SPACE( 8 )
           Namerank( @mcodeno )                // XLF_Name
         IF LASTKEY() == 27 
            RETURN NIL
         ENDIF
         SELECT Name
         mcodeno := Name->Codeno
          cbranchId := Quot->BranchId    //  SPACE( 2 )
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

       CASE nsel == 3                      // Goods Issued Only
         SCROLL( 0, 0,24,44 )
         mcodeno := SPACE( 8 )
   cfind    := SPACE( 10 )
   nrecno   := 0
   aPart_   := {}
   SELECT Quot
   SET ORDER TO 1
   GOTO TOP
   IF LASTREC() != 0
      DO WHILE Quot->( !EOF() )
          IF Quot->GoodSent = 0
             SKIP ALIAS Quot
             LOOP
          ENDIF
          IF Quot->Codeno+Quot->BranchId = cfind
             SKIP ALIAS Quot
             LOOP
          ENDIF
          SELECT Name
          SEEK Quot->Codeno
          SELECT Quot
          cfind := Quot->Codeno+Quot->BranchId
          AADD( aPart_,Name->Name+"  "+Quot->BranchId;
              +"       "+STR( RECNO(),6 ) )
          SKIP ALIAS Quot
      ENDDO                          // EOF()
      DISPBOX( 0, 1, 24,41, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum   := ACHOICE( 1, 3, 23,40, aPart_,,"AFUNC" )    
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         IF LASTKEY() == 27 
            RETURN NIL
         ENDIF
         GOTO nrecno
         mcodeno   := Quot->Codeno
         cbranchId := Quot->BranchId
         SELECT Name
         SEEK mcodeno
      ENDIF
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @  1,10 SAY Name->Name
     ENDIF                        // LastRec

   ENDCASE                      // nsel
   minvno  := SPACE( 6 )
   SELECT Debit
   SET ORDER TO 1    // Codeno+BranchId
   GOTO TOP
   SEEK mcodeno
   IF !FOUND()
      SCROLL( 3, 5, 17,74 )
      @ 12,12 SAY "No DEBIT This Customer"
      @ 14,12 SAY Message->AnyKey
      INKEY()
      RETURN NIL
   ENDIF 

          DebLook( mcodeno, cbranchId )        // XF_Util

      minvno  := Debit->Invno
      msaleno := Debit->Saleno
      nselect := 2
      SCROLL(  15, 0, 24,80 )
      DISPBOX( 15, 1, 19,79, 2 )
      @ 17, 6      SAY Debit->Invno COLOR "G+"
      @ 17,COL()+2 SAY Debit->DbDate
      @ 17,COL()+2 SAY Debit->Amount   PICTURE "9999,999.99" COLOR "G+"
      @ 17,COL()+3 SAY Debit->Saleno
      @ 17,COL()+2 SAY Debit->InitAmnt PICTURE "9999,999.99"
      @ 17,COL()+2 SAY Debit->Stat

RETURN( mcodeno )

***--------- DebitFind()

**-------------------------------------------------------------------

FUNCTION MenuInv()                  // Specific ( AAMain )

DO WHILE .T.

   COMMIT
   cbranchId := SPACE( 2 )
   nselect   := 0
   nc        := ncl
   ncm       := nc
   SCROLL(  3,nc, 21,78 )
   DISPBOX( 4,nc, 21,nc+ncl )
   SCROLL(  3,nc+4, 5,nc+(ncl-4) )
   SCROLL( 22,10, 22,73 )
   SELECT Quot
   GOTO TOP
      nl:= nll:= nlll := 5
      npl:= npll := 22 
      ccodeno := SPACE( 10 )
      @  4,52 SAY "Goods to be Invoiced" COLOR "RG+"
      DO WHILE Quot->( !EOF() )
          IF Quot->GoodSent <= 0
             SKIP ALIAS Quot
             LOOP
          ENDIF
          IF Quot->Codeno+Quot->BranchId = ccodeno
             SKIP ALIAS Quot
             LOOP
          ENDIF
          DO CASE
             CASE nl <= npl
                 @ nl,51   SAY Quot->Codeno+" "+Quot->BranchId
                 nl++
             CASE nll <= npll
                 @ nll,63  SAY Quot->Codeno+" "+Quot->BranchId
                 nll++
             OTHERWISE
                 @ nlll,71 SAY Quot->Codeno+" "+Quot->BranchId
                 nlll++
          ENDCASE 
          ccodeno := Quot->Codeno+Quot->BranchId
          SKIP ALIAS Quot
      ENDDO                          // EOF()
   @  3,nc+4 TO 5,nc+( ncl-4 )
   @  4,nc+( ncl/2 )-( LEN( RTRIM( Menu->CH_IvcHd ) )/2 );
                        SAY RTRIM( Menu->CH_IvcHd )
   @  7,nc+2 PROMPT "1. "+Menu->CH_Ivc1
   @  9,nc+2 PROMPT "2. "+Menu->CH_Ivc2
   @ 11,nc+2 PROMPT "3. "+Menu->CH_Ivc3
   @ 13,nc+2 PROMPT "4. "+Menu->CH_Ivc4
   @ 15,nc+2 PROMPT "5. "+Menu->CH_Ivc5
   @ 17,nc+2 PROMPT "6. "+Menu->CH_Ivc6
   @ 19,nc+2 PROMPT "7. Invoice List        "
   @ 20,nc+2 PROMPT Menu->CH_Main+"   "

   MENU TO nselect

   DO CASE
      CASE nselect == 8 .OR. LASTKEY() == 27
         EXIT
      CASE nselect == 1
         SAVE SCREEN TO Invscrn
         msaleno  := Control->Saleno
         cheading := "Invoices Existing"
         mcodeno  := SPACE( 8 )
          DebitFind( @mcodeno )                 // Below
          Invadd( @mcodeno )                    // Below
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 2
         SAVE SCREEN TO Invscrn
          Invprint()                             // ZF_Inv
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 3
         SAVE SCREEN TO Invscrn
          Invlist()                              // ZF_Inv
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 4
         SAVE SCREEN TO Invscrn
          IvcHist()                               // ZF_INV
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 5
         SAVE SCREEN TO Invscrn
          DebPayRep()                            // DebPay
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 6
         SAVE SCREEN TO Invscrn
          DebProf()                              // DebPay    
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 7
         SAVE SCREEN TO Invscrn
          DebTech()                               // DebPay
         RESTORE SCREEN FROM Invscrn
   ENDCASE

ENDDO

RETURN NIL

***** End of MenuInv()

****--------------------------------------------------------------------------

FUNCTION InvAdd( mcodeno )

minvno  := Debit->Invno
cappend := "N"
mcontinue := mok := "Y"
DO WHILE mcontinue == "Y"
   SCROLL(  18, 0, 24,80 )
   DISPBOX( 18, 1, 24,79, 2 )
   @ 20,10      SAY "The Above are Current Invoices Select if Required"
   @ 22,10      SAY "Invoice =" GET minvno PICTURE "@KX"
   @ 22,COL()+2 SAY "Blank for New Invoice   Esc To Quit"
    READ
   IF LASTKEY() == 27
      RETURN NIL
   ENDIF
   SELECT Debit
   SET ORDER TO 1          // Codeno
   IF minvno = SPACE( 6 )
      SELECT Control
       ApRLock( 3 )
      minvno := STR( Control->LastIvc,6,0 )
      Control->LastIvc := Control->LastIvc+1
      UNLOCK
      SELECT Debit
       ApFLock( 3 )
      APPEND BLANK
      Debit->Invno    := minvno
      Debit->Dbdate   := DATE()
      Debit->Paytype  := "NS"
      Debit->Saleno   := Name->Saleno
      Debit->Codeno   := mcodeno               
      Debit->U_Codeno := mcodeno 
      Debit->BranchId := cbranchId
      Debit->Stat     := "I"
      UNLOCK
   ENDIF 
   mcorrect := "N"
   DO WHILE mcorrect == "N"
      SCROLL(  3, 0, 24,80 )
      DISPBOX( 3, 1, 18,79, 2 )
      nl := 4
      SELECT Name
      IF Name->Overdue > 0
         @ nl, 8      SAY "Account Overdue Amount =" COLOR "R+"
         @ nl,COL()+2 SAY Name->Overdue PICTURE "$999,999.99" COLOR "R+"
         nl+=2
      ENDIF
      SELECT Debit
       ApRLock( 3 )
      @ nl,10      SAY "Invoice "+Debit->Invno
      @ nl,COL()+2 SAY "Dated"   GET Debit->Dbdate PICTURE "99/99/9999"
      @ nl,COL()+2 SAY Name->Saleno COLOR "R+"
      @ nl,COL()+2 SAY Name->Add5   COLOR "R+"
      nl+=2
      @ nl, 8      SAY "Sale Book No " GET Debit->Saleno PICTURE "@K!"
***      @ nl,COL()+4 SAY "Order #"       GET Debit->Ordnum PICTURE "@X"
       READ
      minvno  := Debit->Invno
      msaleno := Debit->Saleno
      UNLOCK
      SELECT SaleBook
      SEEK Debit->Saleno
      IF !FOUND()
 
         Sblook( @msaleno )                  // XLF_Acc

      ENDIF
      msaleno := SaleBook->Saleno
      @ nl, 8 SAY "Sale Book # "+SaleBook->Saleno+"  "+SaleBook->Sbname
      nl+=2
      SELECT Debit
       ApRLock( 3 )
      Debit->Saleno := msaleno
      UNLOCK
      SELECT Name
       ApRLock( 3 )
      Name->Saleno := msaleno
      UNLOCK
      mcorrect := "Y"
       *** ApGetY( Message->Correct )
   ENDDO                                      // mcorrect
   npl := 16
   nl  := 6
   mgtotal:= mgtaxtot:= 0
   csentgood := "N"
   manother := "Y"
   DO WHILE manother = "Y"
     mok := "Y"
     DO WHILE mok = "Y"
        SELECT Invoice
        SEEK minvno
        IF FOUND()

           IvcLook( minvno )                 // ZF_Inv

        ENDIF
        SCROLL(  19, 0, 24,80 )
        DISPBOX( 19, 1, 24,79, 2 )
        @ 19, 6    SAY " -- Invoice -- "
        @ 20, 6    SAY Debit->Invno+" "+Debit->Codeno+" "+Debit->Est
        IF Debit->BranchId != SPACE( 2 )
           @ 21, 6 SAY "Branch "+Debit->BranchId;
                       +" "+TRIM( Branch->Name )+" "+TRIM( Branch->Add4 )
        ENDIF
     nselect := 1
***     @ 23, 3      PROMPT " "
     @ 23, 6      PROMPT "Add Part"
     @ 23,COL()+2 PROMPT "Sent Only"
     @ 23,COL()+2 PROMPT "No More Parts"
     @ 23,COL()+2 PROMPT "Edit Above"
     @ 23,COL()+2 PROMPT "Delete Invoice"  
     @ 23,COL()+2 PROMPT "EXIT"     
     MENU TO nselect

    DO CASE
       CASE nselect == 6 .OR. LASTKEY() == 27
          RETURN NIL
 ***      CASE nselect == 1
 ***          LOOP 
       CASE nselect == 1
          csentgood := "N"
          SELECT Debit
           IvcAddP(csentgood)       //Specific ( XF_IvcFm )
           COMMIT
           LOOP 
       CASE nselect == 2
          csentgood := "Y"
          SELECT Debit
           IvcAddP()                //Specific ( XF_IvcFm )
           COMMIT
       CASE nselect == 3
          manother:= mok:= "N"
          EXIT
       CASE nselect == 4
           IvcEdit( minvno )                          // ZF_Inv
            nl := 17
/*
Taken Out
   mserno  := SPACE( 15 )
   nSerqty := Invoice->Qty
   mok := ApGetY( "Do You Want to Add Serial #" )
   IF mok = "Y"
      SELECT PartSer
      GOTO LASTREC()
      mserno := LTRIM( STR( VAL( PartSer->Serno )+1 ) )
      mserno := mserno+"              "   
      @ nl,36      SAY "Serial No" GET mserno PICTURE "XXXXXXXXXXXXXXX"
      @ nl,COL()+1 SAY "Blank if Not"
       READ
   ENDIF
   IF mserno != SPACE( 15 ) 
      SELECT PartSer
      DO WHILE nSerqty > 0
          ApFLock( 3 )
         APPEND BLANK
         PartSer->Codeno   := Invoice->Codeno
         PartSer->Partnum  := Invoice->Partnum
         PartSer->Invno    := Invoice->Invno
         PartSer->Serno    := LTRIM( mserno )
         PartSer->PDate    := Debit->DBDate
         PartSer->BranchId := Debit->BranchId
         UNLOCK
         nSerqty := nSerqty-1         
         mserno  := STR( VAL( mserno )+1,15 )
      ENDDO                     // nqty > 0
   ENDIF
   COMMIT
taken out
*/
       CASE nselect == 5
          SCROLL()
          @ 12, 10 SAY "This will delete this Invoice in Total are you Sure"
          mdelete := ApGetN( "Are You Sure :" )
          IF mdelete == "Y"
             SELECT Debit
              ApFLock( 3 ) 
             DELETE ALL FOR Invno = minvno
             UNLOCK
             SELECT Invoice
              ApFLock( 3 )
             DELETE ALL FOR Invno = minvno
             UNLOCK
             SELECT DebProf
              ApFLock( 3 )
             DELETE ALL FOR Invno = minvno
             UNLOCK
             RETURN NIL
          ENDIF
      ENDCASE
 ENDDO                               // End of more Parts
ENDDO
      SELECT Invoice
      GO TOP
      ngtotal:= ncostitem:= 0
      SEEK Debit->Invno
      DO WHILE Invoice->Invno == Debit->Invno .AND. Invoice->( !EOF())
         SELECT Invoice
         ngtotal  += ( Invoice->Qty*( ( Invoice->Amount;
                    *( 1-Invoice->Discount/100 )*100 )/100 ) )
         mpartnum := Invoice->Partnum
         SELECT Part
         SEEK mpartnum
         ncostitem += ( Part->Trade*Invoice->Qty )
         SELECT Invoice
         SKIP ALIAS Invoice
      ENDDO
      SELECT Debit
       ApRLock( 3 )
      IF SUBSTR( Debit->Saleno, 1, 2 ) != SUBSTR( Message->Saleno5, 1, 2 )
         Debit->Amount   := ngtotal*( ( Control->GSTRate/100 )+1 )
         Debit->Initamnt := ngtotal*( ( Control->GSTRate/100 )+1 )
         Debit->CostItem := ncostitem
        ELSE
         Debit->Amount   := ngtotal
         Debit->Initamnt := ngtotal
         Debit->CostItem := ncostitem
      ENDIF
      Debit->Paytype := Name->Paytype
      UNLOCK
      ndiscount := 0
***      SELECT Control
      msaleno   := Control->Saleno
      SCROLL(  15, 0, 24,80 )
      DISPBOX( 15, 1, 23,79, 2 )
      @ 16, 7 SAY "Standard Payment = "+Name->PayType;
                  +" "+TRIM( Name->Remarks )+"  "+Name->Charge
                      // Remarks = Account # Charge = Name to charge
      DO CASE
         CASE Name->Paytype = SUBSTR( Message->PayType1,1,2 )
            mchoice := 1
         CASE Name->Paytype = SUBSTR( Message->PayType2,1,2 )
            mchoice := 2
         CASE Name->Paytype = SUBSTR( Message->PayType3,1,2 )
            mchoice := 3
         CASE Name->Paytype = SUBSTR( Message->PayType4,1,2 )
            mchoice := 4
         CASE Name->Paytype = SUBSTR( Message->PayType5,1,2 )
            mchoice := 5
         CASE Name->Paytype = SUBSTR( Message->PayType6,1,2 )
            mchoice := 6
         OTHERWISE
            mchoice := 1
      ENDCASE
      @ 17,10 PROMPT Message->PayType1 
      @ 18,10 PROMPT Message->PayType2
      @ 19,10 PROMPT Message->PayType3
      @ 20,10 PROMPT Message->PayType4
      @ 21,10 PROMPT Message->PayType5
      @ 22,10 PROMPT Message->PayType6
      MENU TO mchoice
      SELECT Debit
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
         OTHERWISE
            Debit->PayType := "NT"
       ENDCASE     
       IF Debit->Paytype = "CT"
          IF Name->Charge != SPACE(8)
             Debit->Codeno := Name->Charge
          ENDIF                               // Space(8)
       ENDIF
       Debit->U_Codeno := mcodeno
       Debit->Invno    := minvno
       UNLOCK
      SELECT DebProf
      SET ORDER TO 2                        // Invno
      SEEK Debit->Invno
       ApFLock( 3 )
      IF !FOUND()
         APPEND BLANK
      ENDIF
      DebProf->Codeno   := Debit->Codeno
      DebProf->DbDate   := Debit->DbDate
      DebProf->Saleno   := Debit->Saleno
      DebProf->PayType  := Debit->PayType
      DebProf->Tech     := Debit->Tech
      DebProf->U_Codeno := Debit->U_Codeno
      DebProf->Invno    := Debit->Invno
      DebProf->Amount   := Debit->Amount
      DebProf->GSTAmnt  := Debit->Tax
      DebProf->CostItem := Debit->Costitem
      DebProf->Est      := Debit->Est
      UNLOCK
      SET ORDER TO 1                // Saleno+Date+Invno
      SELECT Name
       ApRLock( 3 )
      Name->YtdPurch += Debit->Amount 
      UNLOCK
     manother := "Y"
     DO WHILE manother == "Y"

           IvcLook( minvno )                 // ZF_Inv

        SCROLL(  19, 0, 24,80 )
        DISPBOX( 19, 1, 24,79, 2 )
        @ 21, 3 SAY Name->Name                // This is Company Name
        @ 21,COL()+2 SAY Debit->Codeno
        @ 21,COL()+2 SAY Debit->Dbdate PICTURE "99/99/9999"
        @ 21,COL()+2 SAY Debit->Invno COLOR "BG+"
        @ 22, 5      SAY SUBSTR( Debit->Map, 1, 1 )     COLOR "R+" 
        @ 22,16      SAY SUBSTR( Debit->Regno, 1 , 1 )  COLOR "R+" 
        @ 22,32      SAY SUBSTR( Debit->Equip, 1, 1 )   COLOR "R+" 
        @ 22,40      SAY SUBSTR( Debit->RecInfo, 1, 1 ) COLOR "R+" 
        @ 22,62      SAY SUBSTR( Debit->Brand, 1, 1 )   COLOR "R+" 
        nselect := 1
        @ 23, 3      PROMPT "CPL Invoice"
        @ 23,COL()+2 PROMPT "BEP Invoice"
        @ 23,COL()+2 PROMPT "P. Slip"
        @ 23,COL()+2 PROMPT "Invoice With Heading"
        @ 23,COL()+2 PROMPT "Office Copy"
        @ 23,COL()+2 PROMPT "Exit"     

        MENU TO nselect
        DO CASE
          CASE nselect == 6 .OR. LASTKEY() == 27
             RETURN NIL
          CASE nselect == 1                    // CPL Invoice 
            SCROLL(  6, 0, 19,80 )
            DISPBOX( 6, 1, 19,79, 2 )
            SELECT Control
             ApRLock( 3 )
            @  7, 5 SAY "Blank if not Required" COLOR "RG+"
            @  9,10 SAY "On All Invoices" COLOR "BG+"
            @ 10, 5 GET Control->Con_note1 PICTURE "@X"
            @ 11, 5 GET Control->Con_note2 PICTURE "@X"
             READ
            UNLOCK
            @ 13,10 SAY "Specific this Invoice Only" COLOR "BG+"
            SELECT Debit
             ApRLock( 3 )
            @ 14, 5 GET Debit->Note1 PICTURE "@X"
            @ 15, 5 GET Debit->Note2 PICTURE "@X"
            @ 16, 5 GET Debit->Note3 PICTURE "@X"
            Debit->Map = "P"
             READ
            UNLOCK
***            @ 12, 5 GET Control->Con_note3 PICTURE "@X"
***            @ 13, 5 GET Control->Con_note4 PICTURE "@X"
***              mok := "Y"
***              DO WHILE mok == "Y"
***                  InvForm( @mcodeno )             // Specific ( CHRIIvcFM ) 
                  mwhere := "S"
                  Printsel( mwhere )                      // _LF_Init
                  IvcFormA( @mcodeno )            // Chriivcfm.prg 
***                 mok := ApGetN( Message->Another+"Print" )
***              ENDDO
              LOOP

        CASE nselect == 2                           // A4  BEP Invoice  
            SCROLL(  6, 0, 19,80 )
            DISPBOX( 6, 1, 19,79, 2 )
            SELECT Control
             ApRLock( 3 )
            @  7, 5 SAY "Blank if not Required" COLOR "RG+"
            @  9,10 SAY "On All Invoices" COLOR "BG+"
            @ 10, 5 GET Control->Con_note1 PICTURE "@X"
            @ 11, 5 GET Control->Con_note2 PICTURE "@X"
             READ
            UNLOCK
            @ 13,10 SAY "Specific this Invoice Only" COLOR "BG+"
            SELECT Debit
             ApRLock( 3 )
            @ 14, 5 GET Debit->Note1 PICTURE "@X"
            @ 15, 5 GET Debit->Note2 PICTURE "@X"
            @ 16, 5 GET Debit->Note3 PICTURE "@X"
            Debit->Regno = "P"
             READ
            UNLOCK
            mtype := "INVOICE No"  
            mwhere := "S"
             Printsel( mwhere )                      // _LF_Init
             IvcFormA4( @mtype )           // Specific ( CHRIIvcFM ) 
            LOOP

          CASE nselect == 3                // Packing Slip
              SELECT Debit
               ApRLock( 3 )
              Debit->Equip = "P"
              UNLOCK
              mselect := ApGetN( "Do you want Prices" )
                  mwhere := "S"
                  Printsel( mwhere )                      // _LF_Init
              mtype := "PACKING NOTE No"       // Maximum 15
               PackSlip( @mtype )             // Above 
              LOOP

          CASE nselect == 4                // Invoice with heading 
            SCROLL(  6, 0, 19,80 )
            DISPBOX( 6, 1, 19,79, 2 )
            SELECT Control
             ApRLock( 3 )
            @  7, 5 SAY "Blank if not Required" COLOR "RG+"
            @  9,10 SAY "On All Invoices" COLOR "BG+"
            @ 10, 5 GET Control->Con_note1 PICTURE "@X"
            @ 11, 5 GET Control->Con_note2 PICTURE "@X"
             READ
            UNLOCK
            @ 13,10 SAY "Specific this Invoice Only" COLOR "BG+"
            SELECT Debit
             ApRLock( 3 )
            @ 14, 5 GET Debit->Note1 PICTURE "@X"
            @ 15, 5 GET Debit->Note2 PICTURE "@X"
            @ 16, 5 GET Debit->Note3 PICTURE "@X"
            Debit->RecInfo = "P"
             READ
            UNLOCK
            mtype := "INVOICE No"  
            mwhere := "S"
             Printsel( mwhere )                      // _LF_Init
             IvcFormB( @mtype )           // Specific ( CHRIIvcFM ) 
            LOOP

         CASE nselect == 5              // Offic Copy 
            SELECT Debit
             ApRLock( 3 )
            Debit->Brand = "P"
            UNLOCK
            mtype := "OFFICE COPY No"  
            mwhere := "S"
             Printsel( mwhere )                      // _LF_Init
             IvcFormB( @mtype )
            LOOP
        ENDCASE
    ENDDO           // manother 
   mcontinue := "N"
ENDDO

RETURN

****----- End of Invadd()

****--------------------------------------------------------------------------

FUNCTION IvcBottom()

IF mwhere == "P"
   nl++
   @ nl, 3 SAY "TERMS AND CONDITIONS :"
   nl++
   @ nl, 3 SAY "All goods remain our property until paid for in full."
   nl++
   @ nl, 3 SAY "If such goods are sold by the customer prior to payment to us"
   nl++
   @ nl, 3 SAY "and/or they become constituents of other goods the proceeds"
   nl++
   @ nl, 3 SAY "of such sales will be our property"
   nl++
ENDIF

RETURN

*** End of IvcBottom()

*********----------  END OF FILE CHRIINV.PRG

