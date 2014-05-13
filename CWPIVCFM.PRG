*** JK 18-06-11 14:41:58 

*** 27-11-10 23:12:45 
/*  Program ......:                   CWPIVCFM.PRG
    Authors.......: John Kirby
    Date..........: 15/02/1996
    Functions.....: WBIvcFormA, WBIncHead, WBInvForm, WBnoprice 
                 .: WBDatePN,  WBOPer
*/

// (c) Copyright (c) 1995 Chozen Ltd Christchurch.

FUNCTION WBnoprice( mcodeno )

ntotal:= ngtotal:= nweight := 0
SELECT Invoice
GOTO TOP
 ApFLock( 3 )
INDEX ON Invno+Ordnum+Partnum TO TempInv
SET INDEX TO TempInv
UNLOCK
SEEK minvno
ncnt := 0
mordnum := SPACE( 16 )
DO WHILE Invoice->Invno = minvno .AND. Invoice->( !EOF() )
   IF Invoice->Ordnum != SPACE(16)
      IF Invoice->Ordnum != mordnum      
         ncnt++
         mordnum := Invoice->Ordnum 
      ENDIF                             // Ordnum Changed
   ENDIF                                // Ordnum SPACE(16)
   SKIP ALIAS Invoice
ENDDO
nl := 0
msecond := "Y"
GOTO TOP
SEEK minvno
IF mwhere = "P"
   SET MARGIN TO 0
   @  0, 0
   SET DEVICE TO PRINT
   npl := 36
   nl := WBIvcHead()                 // Below
ENDIF
DO WHILE Invoice->Invno = minvno .AND. Invoice->( !EOF() )
   IF mwhere = "P" .AND. nl >= 36              // Adjust no of items
      @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
      SET DEVICE TO SCREEN
      @ 12,10 SAY " "
      @ 14,10 SAY "ALIGN PAPER to TOP OF PAGE"
      @ 16,10 SAY " WAIT FOR PRINTER TO STOP"
      INKEY( 0 )
      SET DEVICE TO PRINT
       nl := WBIvcHead()                 // Below
      ELSEIF ROW() = 18
       WAIT
       nl := 4
       SCROLL( 4, 0, 24,80 )
   ENDIF                                // mwhere
   mpartnum := Invoice->Partnum
   IF SUBSTR( Invoice->Ordnum,1,4 ) != "ZZZZ"
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
***      IF Part->PartId != "AAAA"
***         @ nl, 0 SAY SUBSTR( Part->Partnum,1,8 )        // Reduced Part Number
***      ENDIF
      SELECT Part
      @ nl, 2 SAY Part->Desc        // Can reduce Desc
      SELECT Invoice
      @ nl,47 SAY Invoice->Qty                  PICTURE "9999.999"
      @ nl,68 SAY Invoice->PDate
      mA := ( Invoice->Amount*(1-Invoice->Discount/100 )*100 ) /100.00
      nl++
      ngtotal := ngtotal            +( mA*Invoice->Qty )
      ntotal  := ntotal+( Invoice->Amount*Invoice->Qty )            
      nweight := nweight+(Invoice->Qty*Part->Weight )
      IF Part->Detail != SPACE( 43 )
         @ nl, 0 SAY Part->Detail
         nl++
      ENDIF
      IF Part->Detail1 != SPACE( 43 )
         @ nl, 0 SAY Part->Detail1
         nl++
      ENDIF
      IF Part->Detail2 != SPACE( 43 )
         @ nl, 0 SAY Part->Detail2
         nl++
      ENDIF
      IF Part->Detail3 != SPACE( 43 )
         @ nl, 0 SAY Part->Detail3
         nl++
      ENDIF
      IF Invoice->Info != SPACE( 45 )
         @ nl, 0 SAY Invoice->Info
         nl++
      ENDIF
      IF Invoice->Info2!= SPACE( 45 )
         @ nl, 0 SAY Invoice->Info2
         nl++
      ENDIF
      IF Invoice->Info3 != SPACE( 45 )
         @ nl, 0 SAY Invoice->Info3
         nl++
      ENDIF
      IF Invoice->Info4 != SPACE( 45 )
         @ nl, 0 SAY Invoice->Info4
         nl++
      ENDIF
   ENDIF
   SELECT Invoice
   SKIP ALIAS Invoice
ENDDO
SELECT Invoice
SET INDEX TO InvInd
IF mwhere == "P"
   nl := 41
   @ nl, 3 SAY Control->Con_note1
   IF nweight > 0
      @ nl,44 SAY nweight PICTURE "9,999.99"
      @ nl,53 SAY "kg"
   ENDIF
   nl++
   @ nl, 3 SAY Control->Con_note2
   nl+=2
   @ nl, 3 SAY Control->Con_note3
   nl++
   @ nl, 3 SAY Control->Con_note4
   EndPrint()
  ELSE
   ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
   IF SUBSTR( Name->Add5,1,7 ) != "AUSTRAL"
***      @ nl,68 SAY ( INT( ( ngtotal+ngsttot )*100 )/100 ) PICTURE "$99,999.99"
    ELSE
***      @ nl,68 SAY ngtotal PICTURE "$99,999.99"
   ENDIF
   nl+=1
   @ nl,68 SAY nweight PICTURE "9,999.99"
   @ nl,77 SAY "kg"
***   WAIT
ENDIF
SET MARGIN TO 0

RETURN

*** End of WBNoprice()

**-------------------------------------------------------------------

FUNCTION WBIvcHead()

IF mwhere == "P"
   nl := 0
   @ nl, 1 SAY Control->U_Name
   @ nl,43 SAY Control->U_Add1
   nl++
   @ nl,43 SAY Control->U_Add2
   nl++
   @ nl,43 SAY Control->U_Add3
   nl++
   @ nl,43 SAY Control->U_Add4
   nl++
   @ nl,43 SAY "Phone "+Control->U_Phone
   nl++
   @ nl,43 SAY "Fax   "+Control->U_Fax
   nl+=2
   nl := IvcHead()
/*
   nl+=3                                  // Top Page prints from
   @ nl, 12 SAY Name->Name                // This is Company Name
   IF Debit->BranchId != SPACE( 2 )
      SELECT Branch
      mfind := Debit->Codeno+Debit->BranchId
      SEEK mfind
      @ nl,45 SAY Branch->Name
***    ELSE
***      @ nl,45 SAY Name->Name
   ENDIF
   nl++
   @ nl, 3 SAY Name->Add1
   IF Debit->BranchId != SPACE( 2 )
      @ nl,45 SAY Branch->Add1
   ENDIF
   nl++
   @ nl, 3 SAY Name->Add2
   IF Debit->BranchId != SPACE( 2 )
      @ nl,45 SAY Branch->Add2
   ENDIF
   nl++
   @ nl, 3 SAY Name->Add3
   IF Debit->BranchId != SPACE( 2 )
      @ nl,45 SAY Branch->Add3
   ENDIF
   nl++
   @ nl, 3 SAY Name->Add4
   IF Name->Phone != SPACE( 15 )
      @ nl,22 SAY Name->Phone                // Business Phone
    ELSE
      @ nl,22 SAY Name->Ephone               // Home Phone
   ENDIF
   IF Debit->BranchId != SPACE(2)
      @ nl,45 SAY Branch->Add4
      @ nl,64 SAY Branch->Phone             // Business Phone
    ELSE
      @ nl,45 SAY Name->Add4
   ENDIF
*/
   nl+=3
   @ nl, 2 SAY Debit->Dbdate PICTURE "99/99/9999"
***   IF ncnt <= 1
      @ nl, 6 SAY Debit->Ordnum
***   ENDIF
   @ nl,50 SAY Debit->Codeno
   @ nl,64 SAY "WB # "+Debit->Invno
   nl+=2
ENDIF

RETURN nl

*** End of WBIvcHead()

**-------------------------------------------------------------------

FUNCTION WBPartHead()

IF mwhere == "P"
   nl := 0
   @ 0, 0 SAY Control->U_Name
   @ 0,48 SAY TIME()
   @ 0,58 SAY STR( DAY(  DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR( DATE() ),5 )
   nl++
***   @ nl, 3 SAY Control->U_Add1
***   nl++
***   @ nl, 3 SAY Control->U_Add4
   @ nl,25 SAY "WORK SHEET "+minvno 
   @ nl,45 SAY Debit->Dbdate PICTURE "99/99/9999"
   nl++                                  // Top Page prints from
   @ nl, 3 SAY Name->Name                // This is Company Name
   nl++
   @ nl, 3 SAY Name->Add1
   nl++
   @ nl, 3 SAY Name->Add3+"  "+Name->Add4
   IF Name->Phone != SPACE( 15 )
      @ nl,58 SAY Name->Phone                // Business Phone
    ELSE
      @ nl,58 SAY Name->Ephone               // Home Phone
   ENDIF
   nl+=2
   @ nl,14 SAY mordnum
   nl+=2
ENDIF

RETURN nl

*** End of WBPartHead()

**-------------------------------------------------------------------

FUNCTION WBPartList()

minvno := Debit->Invno
ntotal:= ngtotal := 0
SELECT Invoice
GOTO TOP
 ApFLock( 3 )
INDEX ON Invno+Partnum TO TempInvP
SET INDEX TO TempInvP
UNLOCK
SEEK minvno
ncnt := 0
mordnum := SPACE( 16 )
msecond := "Y"
nl  := 0
npl := 18
IF mwhere = "P"
   SET MARGIN TO 0
   @  0, 0
   SET DEVICE TO PRINT
   npl := 65
ENDIF
IF SUBSTR( Control->U_Name, 1 , 3 ) = "PRE"
   nl := IvcHead()
 ELSE
   nl := WBPartHead()
ENDIF
DO WHILE Invoice->Invno = minvno .AND. Invoice->( !EOF() )
   IF mwhere = "P" .AND. nl >= 65              // Adjust no of items
      @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
      SET DEVICE TO SCREEN
      @ 12,10 SAY " "
      @ 14,10 SAY "ALIGN PAPER to TOP OF PAGE"
      @ 16,10 SAY " WAIT FOR PRINTER TO STOP"
      INKEY( 0 )
      SET DEVICE TO PRINT
      IF SUBSTR( Control->U_Name, 1 , 3 ) = "PRE"
         nl := IvcHead()
       ELSE
         nl := WBPartHead()
      ENDIF
      ELSEIF ROW() = 18
       WAIT
       SCROLL()
       IF SUBSTR( Control->U_Name, 1 , 3 ) = "PRE"
          nl := IvcHead()
        ELSE
          nl := WBPartHead()
       ENDIF
   ENDIF                                // mwhere
   mpartnum := Invoice->Partnum
   IF SUBSTR( Invoice->Ordnum,1,4 ) != "ZZZZ"
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
      SET ORDER TO 1                // Partnum
      SEEK mpartnum
      @ nl, 0 SAY SUBSTR( Part->Partnum,1,12 )
      @ nl,14 SAY SUBSTR( Part->Desc,1,26 )   // Can reduce Desc
      SELECT Invoice
      @ nl,42 SAY Invoice->Qty                  PICTURE "9999.999"
      @ nl,51 SAY Invoice->Amount               PICTURE "99,999.99"
      IF Invoice->Discount > 0
         @ nl,61 SAY STR( Invoice->Discount,2 )+"%"
      ENDIF
      mA := ( Invoice->Amount*(1-Invoice->Discount/100 )*100 ) /100.00
      @ nl,69 SAY mA*Invoice->Qty               PICTURE "999,999.99"
      nl++
      ngtotal := ngtotal+( mA*Invoice->Qty )
      ntotal  := ntotal+( Invoice->Amount*Invoice->Qty )            
      IF Part->Detail != SPACE( 43 )
         @ nl,14 SAY Part->Detail
         nl++
      ENDIF
      IF Part->Detail1 != SPACE( 43 )
         @ nl,14 SAY Part->Detail1
         nl++
      ENDIF
      IF Part->Detail2 != SPACE( 43 )
         @ nl,14 SAY Part->Detail2
         nl++
      ENDIF
      IF Part->Detail3 != SPACE( 43 )
         @ nl,14 SAY Part->Detail3
         nl++
      ENDIF
        ntimetotal := 0
        SELECT PartOper
        GOTO TOP
        SEEK mpartnum
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
              nl++
              IF PartOper->Desc1 != SPACE( 40 )
                 @ nl, 0 SAY PartOper->Desc1
                 nl++
              ENDIF
              IF PartOper->Desc2 != SPACE( 40 )
                 @ nl, 0 SAY PartOper->Desc2
                 nl++
              ENDIF
              @ nl,35 SAY "Time"
              @ nl,40 SAY PartOper->Time PICTURE "9999.99"
              @ nl,50 SAY "Rate"
              @ nl,55 SAY PartOper->Rate PICTURE "9999.99"
              @ nl,65 SAY PartOper->Codeno
              ntimetotal += PartOper->Time*PartOper->Rate
             *** @ nl,68 SAY PartOper->Task
***              @ nl,74 SAY PartOper->ABC
***              @ nl,76 SAY PartOper->Order
              nl++
           ENDIF   
           IF PartOper->Operno != SPACE( 8 )
              SELECT Operate
              SET ORDER TO 1                   // Operno
              SEEK PartOper->Operno
              @ nl, 0 SAY Operate->Desc
              @ nl,35 SAY "Time"
              @ nl,40 SAY Operate->Time PICTURE "9999.99"
              @ nl,50 SAY "Rate"
              @ nl,55 SAY Operate->Rate PICTURE "9999.99"
              ntimetotal += PartOper->Time*PartOper->Rate
***              ntimetotal += Operate->Time*Operate->Rate
              *** @ nl,61 SAY "Set Up"
              *** @ nl,68 SAY Operate->Setup PICTURE "999.99"
***              @ nl,74 SAY PartOper->ABC
***              @ nl,76 SAY PartOper->Order
              nl++
           ENDIF
           IF PartOper->Adminno != SPACE( 8 )
              SELECT Admin
              SEEK PartOper->Adminno
              @ nl, 0 SAY Admin->Desc
              @ nl,35 SAY "Time"
              @ nl,40 SAY PartOper->Time PICTURE "9999.99"
              @ nl,50 SAY "Rate"
              @ nl,55 SAY PartOper->Rate PICTURE "9999.99"
              ntimetotal += PartOper->Time*PartOper->Rate
****              ntimetotal += Admin->Time*Admin->Rate
              nl++
           ENDIF
           IF PartOper->Drawno != SPACE( 8 )
              SELECT Drawing
              SEEK PartOper->Drawno
              @ nl, 0 SAY Drawing->Desc
              nl++
           ENDIF
           SELECT PartOper
           SKIP ALIAS PartOper
       ENDDO                     // PartOper EOF
       IF ntimetotal > 0
          @ nl,35 SAY "Total Time*Rate ="
          @ nl,55 SAY ntimetotal PICTURE "$99,999.99"
          nl++
       ENDIF
       SELECT Cusnotes
       cdetail := ""
        ApRLock( 3 )
       coderef := Part->Partnum
       UNLOCK  
       SEEK coderef
       IF FOUND()
          @ nl, 0 SAY ""
           Getdets( coderef )                           // XF_Memo2
          FormP( cdetail,60,10 )                       // XF_Memo2
          nl++
        ENDIF                          // Found()
***************
/*
   @ nl,27 SAY "Total Costs ="
   @ nl,44 SAY ntimetotal+ntradetot  PICTURE "$99,999.99"
*/
********************
   ENDIF                    // Found Partnum
   SELECT Invoice
   SKIP ALIAS Invoice
ENDDO
SELECT Invoice
SET INDEX TO InvInd
IF mwhere == "P"
   nl++
   IF ( ntotal-ngtotal ) > 0
      @ nl, 9 SAY "Total Discount ="
      @ nl,27 SAY ntotal-ngtotal PICTURE "$99,999.99"
   ENDIF                        // ndisctotal
   @ nl,69 SAY ngtotal PICTURE "99,999.99"
   nl++
   ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
   mA := ( ngtotal+ngsttot )
   @ nl,69 SAY ngsttot PICTURE "99,999.99"
   nl+=2
   @ nl,69 SAY mA PICTURE "99,999.99"
   EndPrint()
  ELSE
   ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
   @ nl,59 SAY ( INT( ( ngtotal+ngsttot )*100 )/100 ) PICTURE "$99,999.99"
   WAIT
ENDIF

RETURN

*** End of WBPartList()

***------------------------------------------------------------------------

FUNCTION WBOPer( mcodeno )

ntotal:= ngtotal:= nweight := 0
*** SELECT QuotPart
*** INDEX ON Partnum TO TempQuot
*** SET INDEX TO TempQuot
SELECT Invoice
GOTO TOP
 ApFLock( 3 )
INDEX ON Invno+Ordnum+Partnum TO TempInv
SET INDEX TO TempInv
UNLOCK
SEEK minvno
ncnt := 0
mordnum := SPACE( 16 )
nl  := 0
npl := 18
msecond := "Y"
IF mwhere = "P"
   SET MARGIN TO 0
   @  0, 0
   SET DEVICE TO PRINT
   npl := 65
ENDIF
IF SUBSTR( Control->U_Name, 1 , 3 ) = "PRE"
   nl := IvcHead()
 ELSE
   nl := WBIvcHead()
ENDIF

**** nl+=3
DO WHILE Invoice->Invno = minvno .AND. Invoice->( !EOF() )
   IF mwhere = "P" .AND. nl >= 65              // Adjust no of items
      @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
      SET DEVICE TO SCREEN
      @ 12,10 SAY " "
      @ 14,10 SAY "ALIGN PAPER to TOP OF PAGE"
      @ 16,10 SAY " WAIT FOR PRINTER TO STOP"
      INKEY( 0 )
      SET DEVICE TO PRINT
        
      IF SUBSTR( Control->U_Name, 1 , 3 ) = "PRE"
         nl := IvcHead()
       ELSE
         nl := WBIvcHead()
      ENDIF
      ELSEIF ROW() = 18
       WAIT
       SCROLL()
       IF SUBSTR( Control->U_Name, 1 , 3 ) = "PRE"
          nl := IvcHead()
         ELSE
          nl := WBIvcHead()
       ENDIF
***       nl := 0
***       SCROLL( 4, 0, 24,80 )
   ENDIF                                // mwhere
   mpartnum := Invoice->Partnum
   IF SUBSTR( Invoice->Ordnum,1,4 ) != "ZZZZ"
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
      SELECT Part
      @ nl, 0 SAY Part->Desc        // Can reduce Desc
      SELECT Invoice
      @ nl,42 SAY Invoice->Qty                  PICTURE "9999.999"
      @ nl,51 SAY Invoice->Amount               PICTURE "99,999.99"
      IF Invoice->Discount > 0
         @ nl,61 SAY STR( Invoice->Discount,2 )+"%"
      ENDIF
      mA := ( Invoice->Amount*(1-Invoice->Discount/100 )*100 ) /100.00
      @ nl,69 SAY mA*Invoice->Qty               PICTURE "999,999.99"
***      @ nl,68 SAY Invoice->PDate
      nl++
      ngtotal := ngtotal            +( mA*Invoice->Qty )
      ntotal  := ntotal+( Invoice->Amount*Invoice->Qty )            
      nweight := nweight+(Invoice->Qty*Part->Weight )
      IF Part->Detail != SPACE( 43 )
         @ nl, 0 SAY Part->Detail
         nl++
      ENDIF
      IF Part->Detail1 != SPACE( 43 )
         @ nl, 0 SAY Part->Detail1
         nl++
      ENDIF
      IF Part->Detail2 != SPACE( 43 )
         @ nl, 0 SAY Part->Detail2
         nl++
      ENDIF
      IF Part->Detail3 != SPACE( 43 )
         @ nl, 0 SAY Part->Detail3
         nl++
      ENDIF
        ntimetotal := 0
        SELECT PartOper
        GOTO TOP
        SEEK mpartnum
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
              nl++
              IF PartOper->Desc1 != SPACE( 40 )
                 @ nl, 0 SAY PartOper->Desc1
                 nl++
              ENDIF
              IF PartOper->Desc2 != SPACE( 40 )
                 @ nl, 0 SAY PartOper->Desc2
                 nl++
              ENDIF
              @ nl,35 SAY "Time"
              @ nl,40 SAY PartOper->Time PICTURE "9999.99"
              @ nl,50 SAY "Rate"
              @ nl,55 SAY PartOper->Rate PICTURE "9999.99"
              @ nl,65 SAY PartOper->Codeno
              ntimetotal += PartOper->Time*PartOper->Rate
             *** @ nl,68 SAY PartOper->Task
***              @ nl,74 SAY PartOper->ABC
***              @ nl,76 SAY PartOper->Order
              nl++
           ENDIF   
           IF PartOper->Operno != SPACE( 8 )
              SELECT Operate
              SET ORDER TO 1                   // Operno
              SEEK PartOper->Operno
              @ nl, 0 SAY Operate->Desc
              @ nl,35 SAY "Time"
              @ nl,40 SAY Operate->Time PICTURE "9999.99"
              @ nl,50 SAY "Rate"
              @ nl,55 SAY Operate->Rate PICTURE "9999.99"
              ntimetotal += PartOper->Time*PartOper->Rate
***              ntimetotal += Operate->Time*Operate->Rate
              *** @ nl,61 SAY "Set Up"
              *** @ nl,68 SAY Operate->Setup PICTURE "999.99"
***              @ nl,74 SAY PartOper->ABC
***              @ nl,76 SAY PartOper->Order
              nl++
           ENDIF
           IF PartOper->Adminno != SPACE( 8 )
              SELECT Admin
              SEEK PartOper->Adminno
              @ nl, 0 SAY Admin->Desc
              @ nl,35 SAY "Time"
              @ nl,40 SAY PartOper->Time PICTURE "9999.99"
              @ nl,50 SAY "Rate"
              @ nl,55 SAY PartOper->Rate PICTURE "9999.99"
              ntimetotal += PartOper->Time*PartOper->Rate
****              ntimetotal += Admin->Time*Admin->Rate
              nl++
           ENDIF
           IF PartOper->Drawno != SPACE( 8 )
              SELECT Drawing
              SEEK PartOper->Drawno
              @ nl, 0 SAY Drawing->Desc
              nl++
           ENDIF
           SELECT PartOper
           SKIP ALIAS PartOper
       ENDDO                     // PartOper EOF
       IF ntimetotal > 0
          @ nl,35 SAY "Total Time*Rate ="
          @ nl,55 SAY ntimetotal PICTURE "$99,999.99"
          nl++
       ENDIF
       SELECT Cusnotes
       cdetail := ""
        ApRLock( 3 )
       coderef := Part->Partnum
       UNLOCK  
       SEEK coderef
       IF FOUND()
          @ nl, 0 SAY ""
           Getdets( coderef )                           // XF_Memo2
          FormP( cdetail,60,10 )                       // XF_Memo2
          nl++
        ENDIF                          // Found()
***************
/*
   @ nl,27 SAY "Total Costs ="
   @ nl,44 SAY ntimetotal+ntradetot  PICTURE "$99,999.99"
*/
********************
   ENDIF
   SELECT Invoice
   SKIP ALIAS Invoice
ENDDO
SELECT Invoice
SET INDEX TO InvInd
IF mwhere == "P"
   nl++
***   nl := 40
   IF ( ntotal-ngtotal ) > 0
      @ nl, 9 SAY "Total Discount ="
      @ nl,27 SAY ntotal-ngtotal PICTURE "$99,999.99"
   ENDIF                        // ndisctotal
   @ nl,69 SAY ngtotal PICTURE "99,999.99"
   nl++
   @ nl, 0 SAY Control->Con_note1
   ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
   IF SUBSTR( Name->Add5,1,7 ) != "AUSTRAL"
      mA := ( ngtotal+ngsttot )
      @ nl,69 SAY ngsttot PICTURE "99,999.99"
    ELSE
      mA := ngtotal
   ENDIF
   nl++
   @ nl, 0 SAY Control->Con_note2
   nl+=2
   @ nl, 0 SAY Control->Con_note3
***   @ nl,44 SAY nweight PICTURE "9,999.99"
***   @ nl,53 SAY "kg"
   nl++
   @ nl, 0 SAY Control->Con_note4
   @ nl,69 SAY mA PICTURE "99,999.99"
   EndPrint()
  ELSE
   ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
   IF SUBSTR( Name->Add5,1,7 ) != "AUSTRAL"
      @ nl,59 SAY ( INT( ( ngtotal+ngsttot )*100 )/100 ) PICTURE "$99,999.99"
    ELSE
      @ nl,59 SAY ngtotal PICTURE "$99,999.99"
   ENDIF
   nl+=2
   @ nl,66 SAY nweight PICTURE "9,999.99"
   @ nl,75 SAY "kg"
ENDIF
SET MARGIN TO 0

RETURN

*** End of WBOPer()

***------------------------------------------------------------------------

FUNCTION WBIvcFormA( mcodeno )

ntotal:= ngtotal:= nweight := 0
*** SELECT QuotPart
*** INDEX ON Partnum TO TempQuot
*** SET INDEX TO TempQuot
SELECT Invoice
GOTO TOP
 ApFLock( 3 )
INDEX ON Invno+Ordnum+Partnum TO TempInv
SET INDEX TO TempInv
UNLOCK
SEEK minvno
ncnt := 0
mordnum := SPACE( 16 )
DO WHILE Invoice->Invno = minvno .AND. Invoice->( !EOF() )
   IF Invoice->Ordnum != SPACE(16)
      IF Invoice->Ordnum != mordnum      
         ncnt++
         mordnum := Invoice->Ordnum 
      ENDIF                             // Ordnum Changed
   ENDIF                                // Ordnum SPACE(16)
   SKIP ALIAS Invoice
ENDDO
nl := 6
msecond := "Y"
GOTO TOP
SEEK minvno
IF mwhere = "P"
   SET MARGIN TO 0
   @  0, 0
   SET DEVICE TO PRINT
   npl := 36
ENDIF
IF SUBSTR( Control->U_Name, 1 , 3 ) = "PRE"
   nl := IvcHead()
 ELSE
   nl := WBIvcHead()
ENDIF
DO WHILE Invoice->Invno = minvno .AND. Invoice->( !EOF() )
   IF mwhere = "P" .AND. nl >= 36              // Adjust no of items
      @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
      SET DEVICE TO SCREEN
      @ 12,10 SAY " "
      @ 14,10 SAY "ALIGN PAPER to TOP OF PAGE"
      @ 16,10 SAY " WAIT FOR PRINTER TO STOP"
      INKEY( 0 )
      SET DEVICE TO PRINT
      IF SUBSTR( Control->U_Name, 1 , 3 ) = "PRE"
         nl := IvcHead()
       ELSE
         nl := WBIvcHead()
      ENDIF
      ELSEIF ROW() = 18
       WAIT
       SCROLL()
       IF SUBSTR( Control->U_Name, 1 , 3 ) = "PRE"
          nl := IvcHead()
         ELSE
          nl := WBIvcHead()
       ENDIF
   ENDIF                                // mwhere
   mpartnum := Invoice->Partnum
   IF SUBSTR( Invoice->Ordnum,1,4 ) != "ZZZZ"
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
***      IF SUBSTR( Part->Partnum,1,2 ) != "ZZ"
***         @ nl, 0 SAY SUBSTR( Part->Partnum,1,8 )        // Reduced Part Number
***      ENDIF
      SELECT Part
      @ nl, 0 SAY SUBSTR( Part->Desc,1,34 )        // Can reduce Desc
      SELECT Invoice
      @ nl,35 SAY Invoice->Qty                  PICTURE "9999.999"
      @ nl,44 SAY Invoice->Amount               PICTURE "99,999.99"
      IF Invoice->Discount > 0
         @ nl,53 SAY STR( Invoice->Discount,2 )+"%"
      ENDIF
      mA := ( Invoice->Amount*(1-Invoice->Discount/100 )*100 ) /100.00
      @ nl,58 SAY mA*Invoice->Qty               PICTURE "99,999.99"
      @ nl,68 SAY Invoice->PDate
      nl++
      ngtotal := ngtotal            +( mA*Invoice->Qty )
      ntotal  := ntotal+( Invoice->Amount*Invoice->Qty )            
      nweight := nweight+(Invoice->Qty*Part->Weight )
      IF Part->Detail != SPACE( 43 )
         @ nl, 0 SAY Part->Detail
         nl++
      ENDIF
      IF Part->Detail1 != SPACE( 43 )
         @ nl, 0 SAY Part->Detail1
         nl++
      ENDIF
      IF Part->Detail2 != SPACE( 43 )
         @ nl, 0 SAY Part->Detail2
         nl++
      ENDIF
      IF Part->Detail3 != SPACE( 43 )
         @ nl, 0 SAY Part->Detail3
         nl++
      ENDIF
      IF Invoice->Info != SPACE( 45 )
         @ nl, 0 SAY Invoice->Info
         nl++
      ENDIF
      IF Invoice->Info2 != SPACE( 45 )
         @ nl, 0 SAY Invoice->Info2
         nl++
      ENDIF
      IF Invoice->Info3 != SPACE( 45 )
         @ nl, 0 SAY Invoice->Info3
         nl++
      ENDIF
      IF Invoice->Info4 != SPACE( 45 )
         @ nl, 0 SAY Invoice->Info4
         nl++
      ENDIF
   ENDIF
   SELECT Invoice
   SKIP ALIAS Invoice
ENDDO
SELECT Invoice
SET INDEX TO InvInd
IF mwhere == "P"
   nl := 40
   IF ( ntotal-ngtotal ) > 0
      @ nl, 9 SAY "Total Discount ="
      @ nl,27 SAY ntotal-ngtotal PICTURE "$99,999.99"
   ENDIF                        // ndisctotal
   @ nl,69 SAY ngtotal PICTURE "99,999.99"
   nl++
   @ nl, 0 SAY Control->Con_note1
   ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
   IF SUBSTR( Name->Add5,1,7 ) != "AUSTRAL"
      mA := ( ngtotal+ngsttot )
      @ nl,69 SAY ngsttot PICTURE "99,999.99"
    ELSE
      mA := ngtotal
   ENDIF
   nl++
   @ nl, 0 SAY Control->Con_note2
   nl+=2
   @ nl, 0 SAY Control->Con_note3
***   @ nl,44 SAY nweight PICTURE "9,999.99"
***   @ nl,53 SAY "kg"
   nl++
   @ nl, 0 SAY Control->Con_note4
   @ nl,69 SAY mA PICTURE "99,999.99"
   EndPrint()
  ELSE
   ngsttot := ROUND(  ngtotal*( Control->GSTRate/100 ),2 )
   IF SUBSTR( Name->Add5,1,7 ) != "AUSTRAL"
      @ nl,59 SAY ( INT( ( ngtotal+ngsttot )*100 )/100 ) PICTURE "$99,999.99"
    ELSE
      @ nl,59 SAY ngtotal PICTURE "$99,999.99"
   ENDIF
   nl+=2
   @ nl,66 SAY nweight PICTURE "9,999.99"
   @ nl,75 SAY "kg"
***   WAIT
ENDIF
SET MARGIN TO 0

RETURN

*** End of WBIvcFormA()

**-------------------------------------------------------------------


FUNCTION WBDateNP( mcodeno )

nweight := 0
*** SELECT QuotPart
*** INDEX ON Partnum TO TempQuot
*** SET INDEX TO TempQuot
SELECT Invoice
GOTO TOP
 ApFLock( 3 )
INDEX ON Invno+DTOC( Invoice->PDate ) TO TempInvD
SET INDEX TO TempInvD
UNLOCK
SEEK minvno
ncnt := 0
mordnum := SPACE( 16 )
DO WHILE Invoice->Invno = minvno .AND. Invoice->( !EOF() )
   IF Invoice->Ordnum != SPACE(16)
      IF Invoice->Ordnum != mordnum      
         ncnt++
         mordnum := Invoice->Ordnum 
      ENDIF                             // Ordnum Changed
   ENDIF                                // Ordnum SPACE(16)
   SKIP ALIAS Invoice
ENDDO
nl := 0
msecond := "Y"
GOTO TOP
SEEK minvno
IF mwhere = "P"
   @  0, 0
   SET DEVICE TO PRINT
   npl := 36
ENDIF
IF SUBSTR( Control->U_Name, 1 , 3 ) = "PRE"
   nl := IvcHead()
 ELSE
   nl := WBIvcHead()
ENDIF
*** nl++
@ nl,28 SAY "Way Bill "+minvno+" Deliveries Today Only "+DTOC( dstmm )
nl++
DO WHILE Invoice->Invno = minvno .AND. Invoice->( !EOF() )
   IF Invoice->PDate != dstmm
      SKIP ALIAS Invoice
      LOOP
   ENDIF
   IF mwhere = "P" .AND. nl >= 36              // Adjust no of items
      @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
      SET DEVICE TO SCREEN
      @ 12,10 SAY " "
      @ 14,10 SAY "ALIGN PAPER to TOP OF PAGE"
      @ 16,10 SAY " WAIT FOR PRINTER TO STOP"
      INKEY( 0 )
      SET DEVICE TO PRINT
      IF SUBSTR( Control->U_Name, 1 , 3 ) = "PRE"
         nl := IvcHead()
       ELSE
         nl := WBIvcHead()
      ENDIF
      ELSEIF ROW() = 18
       WAIT
       nl := 4
       SCROLL( 4, 0, 24,80 )
   ENDIF                                // mwhere
   mpartnum := Invoice->Partnum
   IF SUBSTR( Invoice->Ordnum,1,4 ) != "ZZZZ"
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
      SELECT Part
      @ nl, 3 SAY Part->Desc        // Can reduce Desc
      SELECT Invoice
      @ nl,47 SAY Invoice->Qty                  PICTURE "9,9999.999"
      @ nl,67 SAY Invoice->PDate
      nweight += (Invoice->Qty*Part->Weight )
      nl++
      IF Part->Detail != SPACE( 43 )
         @ nl, 0 SAY Part->Detail
         nl++
      ENDIF
      IF Part->Detail1 != SPACE( 43 )
         @ nl, 0 SAY Part->Detail1
         nl++
      ENDIF
      IF Part->Detail2 != SPACE( 43 )
         @ nl, 0 SAY Part->Detail2
         nl++
      ENDIF
      IF Part->Detail3 != SPACE( 43 )
         @ nl, 0 SAY Part->Detail3
         nl++
      ENDIF
   ENDIF
   SELECT Invoice
   SKIP ALIAS Invoice
ENDDO
SELECT Invoice
SET INDEX TO InvInd
IF mwhere == "P"
   nl := 41
   @ nl, 3 SAY Control->Con_note1
   IF nweight > 0
      @ nl,44 SAY nweight PICTURE "9,999.99"
      @ nl,53 SAY "kg"
   ENDIF
   nl++
   @ nl, 3 SAY Control->Con_note2
   nl+=2
   @ nl, 3 SAY Control->Con_note3
   nl++
   @ nl, 3 SAY Control->Con_note4
   EndPrint()
  ELSE
   nl+=2
   @ nl,68 SAY nweight PICTURE "9,999.99"
   @ nl,77 SAY "kg"
***   WAIT
ENDIF

RETURN

*** End of WBDateNP()

**-------------------------------------------------------------------


FUNCTION WBInvForm( mcodeno )

SCROLL()
DISPBOX( 0, 1,  2,79, 2 )
@  1,10 SAY Name->Name
mcodeno := Name->Codeno
mtrue = "Y"
DO WHILE mtrue = "Y"
   DISPBOX( 3, 1, 16,79, 2 )
   nselect := 1
   @  5,15 PROMPT "Way Bill Today Only no Prices"
   @  7,15 PROMPT "Way Bill Total      no Prices"
   @  9,15 PROMPT "Way Bill Total    With Prices"
   @ 11,15 PROMPT "WB Total      With Operations"
   @ 13,15 PROMPT "WB  Part List     With Prices"
   @ 15,15 PROMPT "EXIT TO Menu                 " 
   MENU TO nselect
   DO CASE
      CASE nselect == 6 .OR. LASTKEY() == 27
         mtrue := "N"
         RETURN NIL  
      CASE nselect == 1
         dstmm := DATE() 
         SCROLL(   3, 0, 24,80 )
         DISPBOX(  3, 1, 5,79, 2 )
         @  4,10 SAY "Date to List" GET dstmm   PICTURE "99/99/9999"
          READ
         IF LASTKEY() = 27
            RETURN
         ENDIF
/*
   DISPBOX( 12, 1, 18,79, 2 )
   SELECT Control
    ApRLock( 3 )
   @ 13, 6 GET Control->Con_note1 PICTURE "@X"
   @ 14, 6 GET Control->Con_note2 PICTURE "@X"
   @ 15, 6 GET Control->Con_note3 PICTURE "@X"
   @ 16, 6 GET Control->Con_note4 PICTURE "@X"
    READ
   UNLOCK
*/
         Printsel()                                  // _LF_Init
        IF mwhere == "P"
           npl := 54
          ELSE
          SCROLL()
          npl := 17
        ENDIF
        nl := 0
         WBDateNP( mcodeno )                  // Above 
        IF mwhere = "S"
           WAIT
        ENDIF 
         WBInvForm( mcodeno )

      CASE nselect == 2
/*
   SCROLL(  12, 0, 24,80 )
   DISPBOX( 12, 1, 18,79, 2 )
   SELECT Control
    ApRLock( 3 )
   @ 13, 6 GET Control->Con_note1 PICTURE "@X"
   @ 14, 6 GET Control->Con_note2 PICTURE "@X"
   @ 15, 6 GET Control->Con_note3 PICTURE "@X"
   @ 16, 6 GET Control->Con_note4 PICTURE "@X"
    READ
   UNLOCK
*/
         Printsel()                                  // _LF_Init
        IF mwhere == "P"
           npl := 54
          ELSE
          SCROLL()
          npl := 17
        ENDIF
        nl := 0
         WBnoprice( mcodeno )                  // Above 
        IF mwhere = "S"
           WAIT
        ENDIF 
         WBINvForm( mcodeno )

      CASE nselect == 3
/*
   SCROLL(  12, 0, 24,80 )
   DISPBOX( 12, 1, 18,79, 2 )
   SELECT Control
    ApRLock( 3 )
   @ 13, 6 GET Control->Con_note1 PICTURE "@X"
   @ 14, 6 GET Control->Con_note2 PICTURE "@X"
   @ 15, 6 GET Control->Con_note3 PICTURE "@X"
   @ 16, 6 GET Control->Con_note4 PICTURE "@X"
    READ
   UNLOCK
*/
         Printsel()                                  // _LF_Init
        IF mwhere == "P"
           npl := 54
          ELSE
          SCROLL()
          npl := 17
        ENDIF
        nl := 0
         WBIvcFormA( mcodeno )                  // Above 
         IF mwhere = "S"
           WAIT
         ENDIF 
         WBInvForm( mcodeno )
      CASE nselect == 4
         Printsel()                                  // _LF_Init
        IF mwhere == "P"
           npl := 54
          ELSE
          SCROLL()
          npl := 17
        ENDIF
        nl := 0
         WBOper( mcodeno )                  // Above 
        IF mwhere = "S"
           WAIT
        ENDIF 
         WBINvForm( mcodeno )
      CASE nselect == 5
         Printsel()                                  // _LF_Init
        IF mwhere == "P"
           npl := 54
          ELSE
          SCROLL()
          npl := 17
        ENDIF
        nl := 0
***         WBOper( mcodeno )                  // Above 
***        IF mwhere = "S"
***           WAIT
***        ENDIF 
         WBPartList( mcodeno )
         WBInvForm( mcodeno )
   ENDCASE
ENDDO

RETURN NIL

***-- End of WBInvForm()

***----------------------- End of CWPIvcFm.PRG
