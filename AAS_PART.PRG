** JK  29-08-10 20:56:45 
***
/*  Program.....:                  AAS_PART.PRG
    Authors.....: J.Kirby
    Date........: 01/06/1999
    Functions...: Mu_SPart(), ProfNated, ProfNatLK, CatConsN,  CatConsP
                : IvcText 
*/

// (c) Copyright 1999 by Kirby Christchurch.

FUNCTION Mu_SPart( nc, ncl )

DO WHILE .T.

   nselect  := 0
   nc       := ncl*2
   SCROLL(  3,nc, 21,78 )
   DISPBOX( 4,nc, 21,nc+ncl )
   SCROLL(  3,nc+4, 5,nc+(ncl-4) )
   DISPBOX( 3,nc+4, 5,nc+(ncl-4) )
   @  4,nc+(ncl/2)-( LEN( RTRIM( Menu2->CH_L2Pahd ) )/2 );
                      SAY RTRIM( Menu2->CH_L2Pahd )
   @  7,nc+2 PROMPT "1." 
   @ 20,nc+2 PROMPT Menu->CH_Main+"   "
   nc := ncl
   MENU TO nselect
   DO CASE
      CASE nselect == 2 .OR. LASTKEY() == 27
         EXIT
      CASE nselect == 1
         SAVE SCREEN TO holdscrn
***          PartStk()          
         RESTORE SCREEN FROM holdscrn
      CASE nselect == 4
         SAVE SCREEN TO holdscrn
         mcodeno := SPACE( 8 )
         RESTORE SCREEN FROM holdscrn
      CASE nselect == 6
        SAVE SCREEN TO holdscrn
        RESTORE SCREEN FROM holdscrn
      CASE nselect == 7
         SAVE SCREEN TO holdscrn
         RESTORE SCREEN FROM holdscrn
   ENDCASE
ENDDO

RETURN NIL

*****  End of Mu_SPart

***-------------------------------------------------------------------------

FUNCTION IvcText()

SELECT Part
SET ORDER TO 1                              // Partnum
mfind := "ZZTEXT"+LTRIM( STR( LASTREC() ) )
SEEK mfind
ApFLock( 3 )
IF !FOUND()
   APPEND BLANK
*****   Part->Partnum   := "ZZ"+TRIM( Name->Codeno )+LTRIM( STR( LASTREC() ) )
   Part->Partnum   := "ZZTEXT"+LTRIM( STR( LASTREC() ) )
  ELSE
   APPEND BLANK
   Part->Partnum   := "ZZTEXT"+LTRIM( STR( LASTREC() ) );
                      +TRIM( Control->Lastcheq )
ENDIF
Part->Catno     := "AA-TEXT  "
Part->PartId    := "TEXT     "
Part->BoughtOut := "N"
Part->Codeno    := Control->U_Codeno
Part->Date      := DATE() 
Part->Unit      := "Each"
UNLOCK
SCROLL(  17, 0, 24,80 )
DISPBOX( 17, 1, 24,79, 2 )
mdesc    := Part->Desc
mdetail  := Part->Detail
mdetail1 := Part->Detail1
mdetail2 := Part->Detail2
mdetail3 := Part->Detail3
@ 18,10 SAY "Text Desc" GET mdesc
@ 19,20                 GET mdetail
@ 20,20                 GET mdetail1
@ 21,20                 GET mdetail2
@ 22,20                 GET mdetail3
@ 23,10 SAY Part->Partnum
 READ
ApRLock( 3 )
Part->Desc    := mdesc
Part->Detail  := mdetail
Part->Detail1 := mdetail1
Part->Detail2 := mdetail2
Part->Detail3 := mdetail3
UNLOCK
COMMIT
mpartnum := Part->Partnum

RETURN( mpartnum )

**---------------------------------------------------------------------*

FUNCTION ProfNated()

cheading  := "View  Existing  Suppliers"
mcontinue:= mdelete:= mok := "Y"
DO WHILE mcontinue == "Y"
   SCROLL()
   DISPBOX(  0, 1, 2,79, 2 )
   @  1,40 -( LEN(cheading)/2 ) SAY cheading
   dmm := SUBSTR( DTOS( DATE()),5,2 )
   DISPBOX(  11, 1, 13,79, 2 )
   @ 12,20 SAY "Select Month :" GET dmm PICTURE "99"
   dyy := SUBSTR( DTOS( DATE()),1,4 )
   @ 12,COL()+4 SAY "Year :" GET dyy PICTURE "9999"
    READ
   IF LASTKEY() == 27
      RETURN NIL
   ENDIF
   SCROLL( 11, 0, 15,80 )
   dyymm := dyy+dmm
   nrecno := 0
   aPart_ := {}
   SELECT ProfNat
   IF LASTREC() != 0
      ntotal := 0
      GOTO TOP
      DO WHILE  ProfNat->( !EOF() )
         IF SUBSTR( DTOS( ProfNat->PDate ),1, 6 ) != dyymm
            SKIP ALIAS ProfNat
            LOOP
         ENDIF
         SELECT Part
         SEEK ProfNat->Partnum
         SELECT ProfNat 
         ntotal += ProfNat->Qty;
              *( ( ProfNat->Cost*( 1-ProfNat->Discount/100 )*100 )/100 ) 
         AADD( aPart_,ProfNat->Codeno+" "+STR( Qty,8,2 );
                     +" "+SUBSTR( ProfNat->Partnum,1, 8 );
                     +" "+SUBSTR( Part->Desc,1,19 );
                     +" "+STR( ProfNat->Cost,6, 2 );
                     +" "+STR( ProfNat->Discount,4 );
                     +" "+DTOC( ProfNat->PDate );
                     +" "+ProfNat->Ordnum;
                     +"     "+STR( RECNO() ) )
         SKIP ALIAS ProfNat
      ENDDO
      DISPBOX( 3, 1, 23,79, 2 )
      @ 24,25 SAY "Total Received ="
      @ 24,43 SAY ntotal PICTURE "$9999,999.99"
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum   := ACHOICE( 4, 3, 22,77, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
       ELSE
         @ 14,20 SAY "--- No Suppliers This Month ---"
         WAIT
         LOOP
      ENDIF
   ENDIF
   SCROLL(  3, 0, 24,80  )
   DISPBOX( 3, 1, 19,79, 2 )
   GOTO nrecno
   nl := 4
   SELECT Part
   SEEK ProfNat->Partnum
   @ nl,10 SAY Part->Desc
   nl++
   @ nl,10 SAY Part->Detail
   SELECT ProfNat
   nl+=2
   @ nl,10      SAY "Supply Date "+DTOC( ProfNat->PDate )
   @ nl,COL()+2 SAY "Pack # "+ProfNat->Packno
   nl+=2
   @ nl,10 SAY "  Invno "+ProfNat->Invno 
   nl+= 2
   @ nl,10 SAY "Amount"
   @ nl,18 SAY ProfNat->Amount PICTURE "9999999.99"
   @ nl,30 SAY "Cost"
   @ nl,35 SAY ProfNat->Cost PICTURE "9999999.99"
   @ nl,COL()+2 SAY "Qty  "+STR( ProfNat->Qty )
   nl+=2
   @  nl,10      SAY "Partnum  "+ProfNat->Partnum PICTURE "@!"
   @  nl,COL()+2 SAY "Codeno   "+ProfNat->Codeno  PICTURE "@!"
      nselect := 0     
      DISPBOX( 20, 1, 24,79, 2 )
      @ 22,15      PROMPT "Edit"
      @ 22,COL()+3 PROMPT "Delete"
      @ 22,COL()+3 PROMPT "Another"
      MENU TO nselect
      DO CASE
         CASE LASTKEY() == 27
            RETURN
         CASE nselect == 1
             ProfNatLk()                    // Below
         CASE nselect == 2
            SCROLL(  19, 0, 24,80  )
            mok := "N"
            cstring := TRIM( Message->Suredel )
             ApCheck( cstring, mok )                     // AppX.PRG
            IF LASTKEY() == 27
               RETURN
            ENDIF
            IF mok == "Y"
                mdelete := "D"
                SELECT ProfNat
                 ApRLock( 3 )
                DELETE
                UNLOCK
            ENDIF
            mcontinue := "Y" 
        CASE nselect == 3
            mcontinue := "Y"
    ENDCASE
ENDDO

RETURN

***---- End of ProfNated()

**---------------------------------------------------------------------*

FUNCTION ProfNatLk()

   SCROLL(  3, 0, 24,80 )
   DISPBOX( 3, 1, 19,79, 2 )
   nl := 4
   SELECT Part
   SEEK ProfNat->Partnum
   @  nl,10 SAY Part->Desc
   nl++
   @ nl,10 SAY Part->Detail
   SELECT ProfNat
    ApRLock( 3 )
   nl+=2
   @  nl,10      SAY "Supply Date :" GET ProfNat->PDate    PICTURE "99/99/9999"
   nl+=2
   @  nl,10      SAY "Order # :"     GET ProfNat->Ordnum   PICTURE "@X" 
   @  nl,COL()+2 SAY "Invno :"       GET ProfNat->Invno    PICTURE "@X"
   nl+= 2
   @  nl,10      SAY "Amount :"      GET ProfNat->Amount   PICTURE "9999999.99"
   @  nl,COL()+2 SAY "Cost :"        GET ProfNat->Cost     PICTURE "9999999.99"
   @  nl,COL()+2 SAY "Discount :"    GET ProfNat->Discount PICTURE "999.99"
   nl+=2
   @  nl,13      SAY "Qty :"         GET ProfNat->Qty      PICTURE "99999.99"
   nl+=2
   @  nl,10      SAY "Partnum :"     GET ProfNat->Partnum  PICTURE "@!"
   @  nl,COL()+2 SAY "Codeno :"      GET ProfNat->Codeno   PICTURE "@!"
   nl+=2
    READ
   UNLOCK

RETURN

***------ End of ProfNatLk()

***---------------------------------------------------------------------*

FUNCTION CatConsN()

SCROLL()
SELECT Hist
SET ORDER TO 1
mok := "Y"
DO WHILE mok == "Y"
   dyear := YEAR( DATE() )
   SCROLL()
   SELECT Name
   GOTO TOP
   msale := SPACE( 4 )
      IF EMPTY( msale )
         mchoice := 1
         DISPBOX( 6, 1, 20,79, 2 )  
         @  7,20 SAY "Select Name Sale Group"
         @ 11,25 PROMPT Message->Mess01
         @ 12,25 PROMPT Message->Mess02
         @ 13,25 PROMPT Message->Mess03
         @ 14,25 PROMPT Message->Mess04
         @ 15,25 PROMPT Message->Mess05
         @ 16,25 PROMPT Message->Mess06
         @ 17,25 PROMPT Message->Mess07
         @ 18,25 PROMPT Message->Mess20
         @ 19,25 PROMPT Message->Mess21
         @ 21,25 PROMPT "Blank for All"
         MENU TO mchoice
         DO CASE
            CASE mchoice == 1
               msale := SUBSTR( Message->Mess01,1,4 )
            CASE mchoice == 2
               msale := SUBSTR( Message->Mess02,1,4 )
            CASE mchoice == 3
               msale := SUBSTR( Message->Mess03,1,4 )
            CASE mchoice == 4
               msale := SUBSTR( Message->Mess04, 1, 4 )
            CASE mchoice == 5
               msale := SUBSTR( Message->Mess05, 1, 4 )
            CASE mchoice == 6
               msale := SUBSTR( Message->Mess06, 1, 4 )
            CASE mchoice == 7
               msale := SUBSTR( Message->Mess07, 1, 4 )
            CASE mchoice == 8
               msale := SUBSTR( Message->Mess20, 1, 4 )
            CASE mchoice == 9
               msale := SUBSTR( Message->Mess21, 1, 4 )
            CASE mchoice == 10
               msale := SPACE( 4 )
         ENDCASE
      ENDIF         // Empty Sale
    mchoice := 1
    @  8,43 SAY "Select Year"
    @ 12,40 PROMPT YEAR( DATE() )-0
    @ 13,40 PROMPT YEAR( DATE() )-1
    @ 14,40 PROMPT YEAR( DATE() )-2
    @ 15,40 PROMPT YEAR( DATE() )-3
    @ 16,40 PROMPT YEAR( DATE() )-4
    MENU TO mchoice
    DO CASE
       CASE mchoice == 1
            dyear := YEAR( DATE() )
       CASE mchoice == 2
            dyear := YEAR( DATE() )-1
       CASE mchoice == 3
            dyear := YEAR( DATE() )-2
       CASE mchoice == 4
            dyear := YEAR( DATE() )-3
       CASE mchoice == 5
            dyear := YEAR( DATE() )-4
    ENDCASE
   mwhere := "S"
   SCROLL()
   npl := 54

     Printsel( mwhere, npl )                        // _LF_Init

   IF mwhere = "P"
      npl := 56
    ELSE
      npl := 17
   ENDIF 
   npn := 1
   nl  := 4
   nrecno := 0
   @  0, 0 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +" "+STR( YEAR(DATE() ),5 )
   @  0,21 SAY TRIM( Control->U_Name )
   @  0,60 SAY "Page"
   @  0,65 SAY npn PICTURE "999"
   @  2,22 SAY msale
   @  2,40 SAY dyear
   SELECT Months
   GOTO 13 - MONTH( DATE() )
   nrecno := RECNO()
   GOTO nrecno+3  
   @  4,28 SAY Months->Name
   GOTO nrecno+2 
   @  4,38 SAY Months->Name
   GOTO nrecno+1 
   @  4,48 SAY Months->Name
   @  4,58 SAY CMONTH( DATE() )
   @  4,66 SAY "Total Yr Td"
   nl := 5
   ntotqty3:= ntotqty2:= ntotqty1:= ntotqty:= nTotal := 0
   ntotcost3:= ntotcost2:= ntotcost1:= ntotcost:= ncosttot := 0
   SELECT Name
    DO WHILE Name->( !EOF() )
        IF msale != SPACE( 4 )
          IF Name->Sale != msale
             SKIP ALIAS Name
             LOOP
          ENDIF
       ENDIF
       IF nl > npl
          IF mwhere == "P"
             EJECT
            ELSE
             WAIT
             SCROLL()
          ENDIF
          nl := 4
          npn := npn+1
          @  0, 0 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                      +" "+STR( YEAR(DATE() ),5 )
          @  0,21 SAY TRIM( Control->U_Name )
          @  0,60 SAY "Page"
          @  0,65 SAY npn PICTURE "999"
          @  2,22 SAY msale
          @  2,40 SAY dyear   
          SELECT Months
          dmonth := CMONTH( DATE() )
          LOCATE FOR TRIM( Months->Name ) = TRIM( dmonth ) 
          nrecno := RECNO()
          GOTO nrecno+3  
          @  4,28 SAY Months->Name
          GOTO nrecno+2 
          @  4,38 SAY Months->Name
          GOTO nrecno+1 
          @  4,48 SAY Months->Name
          @  4,58 SAY CMONTH( DATE() )
          @  4,66 SAY "Total Yr Td"
          nl := 5 
      ENDIF
      SELECT Hist
      GOTO TOP
      SEEK Name->Codeno
      nqtytotal:= nqty:= nqty1:= nqty2:= nqty3 := 0
      DO WHILE Hist->Codeno = Name->Codeno .AND. Hist->( !EOF() )
         IF Hist->Stat != "I"
            SKIP ALIAS Hist
            LOOP
         ENDIF
         IF YEAR( Hist->PDate) != dyear
            SKIP ALIAS Hist
            LOOP
         ENDIF
         ntotal    += Hist->Amount*Hist->Qty 
         nqtytotal += Hist->Amount*Hist->Qty 
         ncosttot  += Hist->Cost*Hist->Qty
         IF MONTH( Hist->PDate) < ( MONTH( DATE() )-3 )
            SKIP ALIAS Hist
            LOOP
         ENDIF
         DO CASE
            CASE MONTH( Hist->PDate ) = ( MONTH( DATE() )-3 )
               nqty3     += Hist->Amount*Hist->Qty
               ntotqty3  += Hist->Amount*Hist->Qty
               ntotcost3 += Hist->Cost*Hist->Qty
            CASE MONTH( Hist->PDate ) = ( MONTH( DATE() )-2 )
               nqty2     += Hist->Amount*Hist->Qty
               ntotqty2  += Hist->Amount*Hist->Qty
               ntotcost2 += Hist->Cost*Hist->Qty
            CASE MONTH( Hist->PDate ) = ( MONTH( DATE() )-1 )
               nqty1     += Hist->Amount*Hist->Qty
               ntotqty1  += Hist->Amount*Hist->Qty
               ntotcost1 += Hist->Cost*Hist->Qty
            CASE MONTH( Hist->PDate ) = ( MONTH( DATE() ) )
               nqty     += Hist->Amount*Hist->Qty
               ntotqty  += Hist->Amount*Hist->Qty
               ntotcost += Hist->Cost*Hist->Qty
         ENDCASE
         SKIP ALIAS Hist
      ENDDO                                 // EOF Hist
      IF nqtyTotal > 0
         @ nl, 0 SAY SUBSTR( Name->Name, 1,25 )
         @ nl,26 SAY nqty3     PICTURE "9999,999"
         @ nl,36 SAY nqty2     PICTURE "9999,999"
         @ nl,46 SAY nqty1     PICTURE "9999,999"
         @ nl,56 SAY nqty      PICTURE "9999,999"
         @ nl,66 SAY nqtyTotal PICTURE "9999,999.99"
         nl++
      ENDIF
      SELECT Name 
      SKIP ALIAS Name
   ENDDO                                    // EOF Name       
      nl++
      @ nl, 6 SAY "Total Sell less GST" 
      @ nl,26 SAY ntotqty3 PICTURE "9999,999"
      @ nl,36 SAY ntotqty2 PICTURE "9999,999"
      @ nl,46 SAY ntotqty1 PICTURE "9999,999"
      @ nl,56 SAY ntotqty  PICTURE "9999,999"
      @ nl,66 SAY nTotal   PICTURE "99999,999.99"
      nl+=2
      @ nl, 6 SAY "Total Cost" 
      @ nl,26 SAY ntotcost3 PICTURE "9999,999"
      @ nl,36 SAY ntotcost2 PICTURE "9999,999"
      @ nl,46 SAY ntotcost1 PICTURE "9999,999"
      @ nl,56 SAY ntotcost  PICTURE "9999,999"
      @ nl,66 SAY ncosttot  PICTURE "99999,999.99"
      nl++
      @ nl,29 SAY ( ( ntotqty3-ntotcost3 )/ntotqty3 )*100 PICTURE "99999 %"
      @ nl,39 SAY ( ( ntotqty2-ntotcost2 )/ntotqty2 )*100 PICTURE "99999 %"
      @ nl,49 SAY ( ( ntotqty1-ntotcost1 )/ntotqty1 )*100 PICTURE "99999 %"
      @ nl,59 SAY ( ( ntotqty-ntotcost   )/ntotqty  )*100 PICTURE "99999 %"
      @ nl,71 SAY ( ( ntotal-ncosttot    )/ntotal   )*100 PICTURE "99999 %"
   nl+= 2
   IF mwhere == "S"
      WAIT 
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
     ELSE
      EndPrint()
   ENDIF
   mok := ApGetN( Message->Another+"Print out" )
ENDDO

RETURN NIL

***------------ End of CatConsN()

***---------------------------------------------------------------------*

FUNCTION CatConsP()

ccatno := SPACE(12)
SCROLL()
SELECT Hist
SET ORDER TO 2
mok := "Y"
DO WHILE mok == "Y"
   SCROLL()
   nl      := 4
   CatArray()

   mchoice := 1
   dyear := DATE()
   SCROLL()
   @  6,33 SAY Cat->CatDesc COLOR "G+"
   @  8,43 SAY "Select Year"
   @ 12,40 PROMPT YEAR( DATE() )-0
   @ 13,40 PROMPT YEAR( DATE() )-1
   @ 14,40 PROMPT YEAR( DATE() )-2
   @ 15,40 PROMPT YEAR( DATE() )-3
   @ 16,40 PROMPT YEAR( DATE() )-4
   MENU TO mchoice
   DO CASE
       CASE mchoice == 1
            dyear := YEAR( DATE() )
       CASE mchoice == 2
            dyear := YEAR( DATE() )-1
       CASE mchoice == 3
            dyear := YEAR( DATE() )-2
       CASE mchoice == 4
            dyear := YEAR( DATE() )-3
       CASE mchoice == 5
            dyear := YEAR( DATE() )-4
    ENDCASE
    mcont := ApGetY( "Do you want Profit" )
    mwhere := "S"
    npl := 54

   SCROLL()

     Printsel( mwhere, npl )                        // _LF_Init

   IF mwhere = "P"
      npl := 56
    ELSE
      npl := 18
   ENDIF 
   npn := 1
   SELECT Cat
   GOTO TOP
   SEEK ccatno
   @  0, 0 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +" "+STR( YEAR(DATE() ),5 )
   @  0,21 SAY TRIM( Control->U_Name )
   @  0,60 SAY "Page"
   @  0,65 SAY npn PICTURE "999"
   @  2, 5 SAY Cat->Catdesc
   @  2,62 SAY dyear   
   @  4, 0 SAY "Description"
   @  4,17 SAY "Jan  Feb  Mar  Apri May  June July Aug  Sept Oct  Nov  Dec  Tot" 
   nl := 5
    SELECT Part
    SET ORDER TO 2                  // Catno, Desc
    SEEK ccatno
    DO WHILE Part->Catno = ccatno .AND. Part->( !EOF() )
       IF nl > npl
          IF mwhere == "P"
             EJECT
            ELSE
             WAIT
             SCROLL()
          ENDIF
          nl := 4
          npn := npn+1
          @  0, 0 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                      +" "+STR( YEAR(DATE() ),5 )
          @  0,21 SAY TRIM( Control->U_Name )
          @  0,60 SAY "Page"
          @  0,65 SAY npn PICTURE "999"
          @  2, 5 SAY Cat->Catdesc
          @  2,62 SAY dyear   
          @  4, 0 SAY "Description"
   @ 4,17 SAY "Jan  Feb  Mar  Apri May  June July Aug  Sept Oct  Nov  Dec  Tot" 
          nl := 5 

      ENDIF
      SELECT Hist
      SEEK Part->Partnum
      nqtytotal:= nqty1:= nqty2:= nqty3:= nqty4:= nqty5:= nqty6 := 0
      nqty7:= nqty8:= nqty9:= nqty10:= nqty11:= nqty12 := 0              
      namttotal:= namt1:= namt2:= namt3:= namt4:= namt5:= namt6 := 0
      namt7:= namt8:= namt9:= namt10:= namt11:= namt12 := 0              
      DO WHILE Hist->Partnum = Part->Partnum .AND. Hist->( !EOF() )
         IF YEAR( Hist->PDate ) != dyear
            SKIP ALIAS Hist
            LOOP
         ENDIF
         DO CASE
            CASE MONTH( Hist->PDate ) =  1
               nqty1     += Hist->Qty
               nqtytotal += Hist->Qty 
               namt1     += ( Hist->Amount-Hist->Cost )
               namttotal += ( Hist->Amount-Hist->Cost )
            CASE MONTH( Hist->PDate ) =  2
               nqty2     += Hist->Qty
               nqtytotal += Hist->Qty 
               namt2     += ( Hist->Amount-Hist->Cost )
               namttotal += ( Hist->Amount-Hist->Cost )
           CASE MONTH( Hist->PDate ) =  3
               nqty3     += Hist->Qty
               nqtytotal += Hist->Qty 
               namt3     += ( Hist->Amount-Hist->Cost )
               namttotal += ( Hist->Amount-Hist->Cost )
             CASE MONTH( Hist->PDate ) =  4
               nqty4     += Hist->Qty
               nqtytotal += Hist->Qty 
               namt4     += ( Hist->Amount-Hist->Cost )
               namttotal += ( Hist->Amount-Hist->Cost )
             CASE MONTH( Hist->PDate ) =  5
               nqty5     += Hist->Qty
               nqtytotal += Hist->Qty 
               namt5     += ( Hist->Amount-Hist->Cost )
               namttotal += ( Hist->Amount-Hist->Cost )
            CASE MONTH( Hist->PDate ) =  6
               nqty6     += Hist->Qty
               nqtytotal += Hist->Qty 
               namt6     += ( Hist->Amount-Hist->Cost )
               namttotal += ( Hist->Amount-Hist->Cost )
            CASE MONTH( Hist->PDate ) =  7
               nqty7     += Hist->Qty
               nqtytotal += Hist->Qty 
               namt7     += ( Hist->Amount-Hist->Cost )
               namttotal += ( Hist->Amount-Hist->Cost )
            CASE MONTH( Hist->PDate ) =  8
               nqty8     += Hist->Qty
               nqtytotal += Hist->Qty 
               namt8     += ( Hist->Amount-Hist->Cost )
               namttotal += ( Hist->Amount-Hist->Cost )
            CASE MONTH( Hist->PDate ) =  9
               nqty9     += Hist->Qty
               nqtytotal += Hist->Qty 
               namt9     += ( Hist->Amount-Hist->Cost )
               namttotal += ( Hist->Amount-Hist->Cost )
            CASE MONTH( Hist->PDate ) = 10
               nqty10    += Hist->Qty
               nqtytotal += Hist->Qty 
               namt10    += ( Hist->Amount-Hist->Cost )
               namttotal += ( Hist->Amount-Hist->Cost )
            CASE MONTH( Hist->PDate ) = 11
               nqty11    += Hist->Qty
               nqtytotal += Hist->Qty 
               namt11    += ( Hist->Amount-Hist->Cost )
               namttotal += ( Hist->Amount-Hist->Cost )
            CASE MONTH( Hist->PDate ) = 12
               nqty12    += Hist->Qty
               nqtytotal += Hist->Qty 
               namt12    += ( Hist->Amount-Hist->Cost )
               namttotal += ( Hist->Amount-Hist->Cost )
           ENDCASE
           SKIP ALIAS Hist
        ENDDO
***        IF nqtytotal > 0    
        IF SUBSTR( Control->U_Name, 1, 4 ) = "CHRI"
           @ nl, 0 SAY SUBSTR( Part->Partnum, 1,13 )
          ELSE
           @ nl, 0 SAY SUBSTR( Part->Desc, 1,13 )
        ENDIF
           @ nl,15 SAY nqty1  PICTURE "9999"
           @ nl,19 SAY nqty2  PICTURE "9999"
           @ nl,25 SAY nqty3  PICTURE "9999"
           @ nl,30 SAY nqty4  PICTURE "9999"
           @ nl,35 SAY nqty5  PICTURE "9999"
           @ nl,40 SAY nqty6  PICTURE "9999"
           @ nl,45 SAY nqty7  PICTURE "9999"
           @ nl,50 SAY nqty8  PICTURE "9999"
           @ nl,55 SAY nqty9  PICTURE "9999"
           @ nl,60 SAY nqty10 PICTURE "9999"
           @ nl,65 SAY nqty11 PICTURE "9999"
           @ nl,70 SAY nqty12 PICTURE "9999"
           @ nl,74 SAY nqtytotal PICTURE "9999"
           nl++
        IF mcont = "Y"
           @ nl, 0 SAY "Profit"
           @ nl, 7 SAY namttotal PICTURE "9999,999"
           @ nl,15 SAY namt1  PICTURE "9999"
           @ nl,19 SAY namt2  PICTURE "9999"
           @ nl,25 SAY namt3  PICTURE "9999"
           @ nl,30 SAY namt4  PICTURE "9999"
           @ nl,35 SAY namt5  PICTURE "9999"
           @ nl,40 SAY namt6  PICTURE "9999"
           @ nl,45 SAY namt7  PICTURE "9999"
           @ nl,50 SAY namt8  PICTURE "9999"
           @ nl,55 SAY namt9  PICTURE "9999"
           @ nl,60 SAY namt10 PICTURE "9999"
           @ nl,65 SAY namt11 PICTURE "9999"
           @ nl,70 SAY namt12 PICTURE "9999"
           nl++
        ENDIF                               // mcont  
        SELECT Part 
        SKIP ALIAS Part
   ENDDO       
   IF mwhere == "S"
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
     ELSE
      EndPrint()
   ENDIF
   mok := ApGetN( Message->Another+"Print out" )
ENDDO
SELECT Hist
SET ORDER TO 1

RETURN NIL

***------------ End of CatConsP()

**** ----------- END OF FILE    AAS_PART.PRG