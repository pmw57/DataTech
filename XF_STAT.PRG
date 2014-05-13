*** JK  16-05-10 12:19:33 

/*  Program ......:                   XF_Stat.PRG

    Authors.......: John Kirby
    Date..........: 13/08/96
    Functions.....: DebChris, 

*/

// (c) Copyright (c) 1995 Chozen Ltd Christchurch.

FUNCTION Debchris()

mmonthcr := MONTH(DATE()) -1
DO CASE
   CASE mmonthcr == 0
      mmonth1  := 11
      mmonthcr := 12
   CASE mmonthcr == 1
      mmonth1 := 12
   OTHERWISE
      mmonth1 := mmonthcr-1
ENDCASE
mrecdate  := DATE()
mdatestat := "30/"+STR(mmonthcr,2,0)+SUBSTR(DTOC(DATE()),6,3)
SCROLL(  3, 0, 24,80 )
DISPBOX( 7, 5, 9,75, 2 )
mcorrect := mok := "N"
DO WHILE mcorrect == "N"
   @  8,10 SAY "Statement to be dated :" GET mdatestat PICTURE "99/99/99"
    READ
   mcorrect := ApGetY( "Sure Date is Correct ?" )
   IF LASTKEY() == 27
      RETURN NIL
   ENDIF
ENDDO
mok := "Y"
DO WHILE mok == "Y"

    Namerank()

    IF LASTKEY() = 27
       RETURN NIL
    ENDIF
   mcodeno := Name->Codeno
   mrefno  := SPACE(6)
***   mselno = "ST"
***   DO C:Notescrn
***   USE
***   mmessage = "N"
***   @ 14, 5 SAY "Message Required ? " GET mmessage PICTURE "!"
***    READ
   mwhere := "P"

   Printsel( mwhere )                                     // _LP_Init

    Chrishead()                          // Below

   SELECT Rec
   SEEK mcodeno
   mrecamnt := mdebbal := 0
   IF FOUND()
      DO WHILE (Rec->Codeno = mcodeno) .AND. Rec->( !EOF() )
***        ****** This not correct           Must include YEAR

         IF MONTH( Rec->Recdate ) = (MONTH(DATE())-1);
             .AND. YEAR( Rec->Recdate) = YEAR(DATE() )
             mrecamnt = Rec->Recamnt+mrecamnt
         ENDIF
         SKIP ALIAS Rec
      ENDDO                         // Rec
   ENDIF
   IF mrecamnt > 0
      @ nl,10 SAY "Received"
      @ nl,38 SAY mrecamnt PICTURE "999,999.99"
      @ nl,52 SAY "Received"
      @ nl,64 SAY mrecamnt PICTURE "999,999.99"
      nl  := nl+2
   ENDIF
   @ nl,14 SAY "Account Rendered"
   nl  := nl+2
   npl := 56
   mpageno = 1
   SELECT Debit
   SEEK mcodeno
   mgtotcr:= mgtot1:= mgtot2:= mgtotr:= 0
   DO WHILE Debit->Codeno = mcodeno .AND. Debit->( !EOF() )
      IF Debit->Amount = 0
         SKIP ALIAS Debit
         LOOP
      ENDIF
      IF MONTH(Debit->Dbdate) = MONTH(DATE())
         SKIP ALIAS Debit
         LOOP
      ENDIF
      IF nl > npl
        mpageno := mpageno+1
        nl := nl+1
        @ nl, 4 SAY "Statement is Continued on Next Page"
        IF mwhere == "P"
           EndPrint()
           *  @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
          ELSE
           WAIT
        ENDIF
        SCROLL( 3, 0, 24,75 )
        @ 12, 0 SAY "PLEASE ALIGN STATEMENT TO TOP OF PAGE WILL IMPROVE SOON"
        WAIT
        IF mwhere == "P"
           @  0, 0
           SET DEVICE TO PRINT

           Chrishead()

        ENDIF   
        SELECT Debit
      ENDIF
      mmonth := VAL(SUBSTR(DTOC(Debit->Dbdate),4,2))
      DO CASE
        CASE mmonth == mmonthcr
           mgtotcr := mgtotcr+Debit->Amount
        CASE mmonth == mmonth1
           mgtot1  := mgtot1+Debit->Amount
        OTHERWISE
           mgtot2  := mgtot2+Debit->Amount
      ENDCASE
      @ nl, 4 SAY Debit->Dbdate
      @ nl,14 SAY "Invoice"
      @ nl,23 SAY Debit->Invno
      @ nl,36 SAY Debit->Amount PICTURE "99,999.99"
      @ nl,52 SAY Debit->Invno
      @ nl,62 SAY Debit->Amount PICTURE "99,999.99"
      nl     := nl+1
      mgtotr := mgtotr+Debit->Amount
      SKIP ALIAS Debit
   ENDDO
      nl      := nl+3
      @ nl, 5 SAY mcodeno
      @ nl,36 SAY mgtotr PICTURE "$999,999.99"
      @ nl,52 SAY mcodeno
      @ nl,62 SAY mgtotr PICTURE "$999,999.99"
      nl      := nl+3
      @ nl, 5 SAY "Terms of Trade by the 20th of the Month"
      @ 44, 0 SAY "================================================================================" 
      @ 45, 8 SAY "2 Months"
 ***     @ 47, 8 SAY "& Over"
      @ 45,21 SAY "1 Month"
      @ 45,34 SAY "Current"
      @ 47, 4 SAY mgtot2 PICTURE "999,999.99"
      @ 47,18 SAY mgtot1 PICTURE "999,999.99"
      @ 47,28 SAY mgtotcr PICTURE "999,999.99"
      @ 47,41 SAY mgtotr PICTURE "999,999.99"
      @ 47,52 SAY mcodeno 
      @ 47,62 SAY mgtotr PICTURE "999,999.99" 
      @ 49, 0 SAY "==============================================================================="

    IF mwhere == "P"
       EndPrint()
      ELSE
       WAIT
    ENDIF
*   @  0, 0 SAY CHR(27)+CHR(67)+CHR(03)
***   @ 12, 0 SAY "PLEASE ALIGN STATEMENT TO TOP OF PAGE "
   mok := ApGetY( Message->Another+" Statement" )
   IF LASTKEY() == 27
      RETURN( mcodeno )
   ENDIF
ENDDO

RETURN( mcodeno )

**** End of DebChris()

**-------------------------------------------------------------------

FUNCTION Chrishead()

   SELECT Control
   * @  2,11 SAY CHR(14)+CHR(27)+CHR(71)+TRIM(mname)
   * @  2,39 SAY CHR(20)+CHR(27)+CHR(99)+CHR(49)
   nl := 3
   @ nl, 8 SAY Control->U_Name
   @ nl,52 SAY SUBSTR( Control->U_Name,26 )
   nl := nl+2
   @ nl, 8 SAY Control->U_Add1
   @ nl,52 SAY SUBSTR( Control->U_Add1,26 )
   nl := nl+1
   @ nl, 8 SAY Control->U_Add2
   @ nl,52 SAY SUBSTR( Control->U_Add2,26 )
   IF Control->U_Add3 != SPACE(27)
      nl := nl+1
      @ nl, 8 SAY Control->U_Add3
      @ nl,52 SAY SUBSTR( Control->U_Add3,26 )
   ENDIF
   nl := nl+1
   @ nl, 8 SAY Control->U_Add4
   @ nl,52 SAY SUBSTR( Control->U_Add4,26 )
   nl := nl+2
   @ nl, 8 SAY "Ph "+TRIM( Control->U_Phone)+" Ph/Fax "+Control->U_Fax
   nl := nl+3
   SELECT Name
   SEEK mcodeno
   @ nl,11 SAY Name->Name
   @ nl,52 SAY SUBSTR( Name->Name,26 )
***      @ nl,11 SAY TRIM(Name->Title)+" "+TRIM(Name->Called)+" "+Name->Famname
***      @ nl,52 SAY SUBSTR( Name->Famname,26 )
   nl := nl+1
   @ nl,12 SAY Name->Add1
   @ nl,45 SAY mdatestat
   @ nl,52 SAY SUBSTR( Name->Add1,26 )
   nl := nl+1
   @ nl,12 SAY Name->Add2
   @ nl,45 SAY Codeno
   @ nl,52 SAY SUBSTR( Name->Add2,26 )
   nl := nl+1
   @ nl,12 SAY Name->Add3
   @ nl,52 SAY SUBSTR( Name->Add3,26 )
**   nl = nl+1
**   @ nl, 8 SAY Name->Add4
   nl := nl+1
   @ nl, 8 SAY TRIM (Name->Add4)+"  "+Name->Zip
   @ nl,52 SAY SUBSTR(Name->Add4,26)
   nl := nl+1
   IF Name->Phone <> SPACE(15)
       @ nl, 8 SAY "Phone "+Name->Phone      // Business Phone
    ELSE
       @ nl, 8 SAY "Priv Ph "+Name->Ephone    // Home Phone
   ENDIF
   nl := nl+2

RETURN NIL

*** End of ChrisHead()

***----------------------- End of XF_Stat.PRG
