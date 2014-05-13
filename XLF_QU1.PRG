   ***  JoKir10    03-10-11 13:51:54 

/*
   Program.....:                  XLF_QU1.PRG
   Authors.....: J.Kirby
   Date........: 06/01/2002
   Functions...: QChriParts, FacDisp, LabCutCopy, LabCutDate
                 LabCutPrint, LabCutOper, IvcLabour
   Static funcs: ChangeFac
   Not used....: IvcLabPart
*/

FUNCTION QChriParts()

   SCROLL()
   DISPBOX( 6, 1, 16,79, 2 )
   msum := 0
   mdate := DATE()
   @ 10,15 SAY "Listing Quotations"
   @ 14,15 SAY "Up to Date " GET mdate PICTURE "99/99/99" 
   READ

   Printsel( mwhere )

   IF mwhere == "P"
      npl := 56
      @  0, 0
      SET DEVICE TO PRINT
   ELSE
      SCROLL()
      npl := 20
   ENDIF
   @ 0, 0 SAY Control->U_Name   // 35
   @ 0,38 SAY "To Date" 
   @ 0,47 SAY mdate
   @ 0,58 SAY STR( DAY(  DATE() ),3 )+" "+CMONTH( DATE() );
      +STR( YEAR( DATE() ),5 )
   nl := 2
   SELECT Quot
    ApFLock( 3 )
   INDEX ON QuotOrd->Partnum TO TempInd9
   SET INDEX TO TempInd9
   UNLOCK
   GOTO TOP
   DO WHILE QuotOrd->( !EOF() )
      IF Quot->Dbdate > mdate
         SKIP ALIAS QuotOrd
         LOOP
      ENDIF
      IF nl > npl
         nl := 2
         IF mwhere == "P"
            EJECT
            @ 0, 0 SAY Control->U_Name   // 35
            @ 0,38 SAY "To Date" 
            @ 0,47 SAY mdate
            @ 0,58 SAY STR( DAY( DATE() ),3 )+" "+CMONTH( DATE() );
                      +STR( YEAR( DATE() ),5 )
         ELSE
            WAIT
            SCROLL( 3, 0, 24,80 )
         ENDIF                  // mwhere = "P"
      ENDIF                    // nl > npl
      mtotal:= nbuy := 0
      mpartnum := QuotOrd->Partnum
      SELECT QuotOrd
      DO WHILE QuotOrd->Partnum = mpartnum .AND. QuotOrd->( !EOF() )
         IF QuotOrd->Dbdate > mdate
            SKIP ALIAS QuotOrd
            LOOP
         ENDIF
         mtotal += QuotOrd->Qty
         SKIP ALIAS QuotOrd
      ENDDO     
      IF mtotal > 0
         SELECT Part
         SET ORDER TO 1                   // Partnum
         SEEK mpartnum
         @ nl, 0 SAY mtotal PICTURE "99,999"
         @ nl, 7 SAY SUBSTR( Part->Partnum, 1,14 )
         @ nl,23 SAY SUBSTR( Part->Desc, 1,34 )
         @ nl,58 SAY Part->PartId
         nl+=1
      ENDIF           // 0
   ENDDO 
   IF mwhere = "P"
      @ nl, 0 SAY " "
      EndPrint()
      SET MARGIN TO 0
   ELSE
      IF nl > 23
         WAIT
      ENDIF
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF
   SELECT QuotOrd
   SET INDEX TO QuotOrd

   RETURN NIL

   **** End of QChriParts()

   **-------------------------------------------------------------------

STATIC FUNCTION ChangeFac()

   IF SUBSTR( Control->U_Name, 1, 5 ) != "CHRIS"  
      SCROLL(  4, 0, 24,80 )
      DISPBOX(  4, 1, 24,79, 2 )
      @ 10,10 SAY "BEWARE THIS IS THE Product File Change in Christine"
      @ 12,10 SAY "ONLY TILL UP-Dated   NO GOOD"
      @ 14,10 SAY "BEWARE"
      @ 16,10 SAY "     "
      WAIT
   ENDIF
   SCROLL(  4, 0, 24,80 )
   DISPBOX(  4, 1, 24,79, 2 )
   nl :=  5
   SELECT Name
   SEEK QuotOrd->Codeno
   SELECT Part
   SEEK Quot->Partnum
   @ nl, 4      SAY Name->Name COLOR "BG+"
   @ nl,COL()+2 SAY "Branch "+QuotOrd->BranchId
   @ nl,COL()+2 SAY SUBSTR( QuotOrd->Partnum, 1,16 )  COLOR "RG+"
   @ nl,COL()+1 SAY TRIM( Part->Unit )
   nl+=2
   SELECT QuotOrd
   @ nl, 3      SAY "Price"
   @ nl,COL()+1 SAY QuotOrd->Amount   PICTURE "9999,999.99"
   @ nl,COL()+2 SAY "Disc"
   @ nl,COL()+1 SAY QuotOrd->Discount PICTURE "9,999.99"  
   @ nl,COL()+3 SAY "Qty"
   @ nl,COL()+1 SAY QuotOrd->Qty      PICTURE "9,999.99"  
   @ nl,COL()+4 SAY QuotOrd->Faxno    COLOR "RG+" 
   nl+=2
   nqty      := QuotOrd->Qty
   ngoodsent := QuotOrd->GoodSent
   cordnum   := QuotOrd->Ordnum
   ddbdate   := QuotOrd->DbDate
   dduedate  := QuotOrd->DueDate
   csentby   := QuotOrd->Sentby
   cdocno    := QuotOrd->Docno
   cfaxno    := QuotOrd->Faxno
   cinfo     := QuotOrd->Info
   cinfo2    := QuotOrd->Info2
   cinfo3    := QuotOrd->Info3
   cinfo4    := QuotOrd->Info4
   @ nl, 8      SAY "Quantity"     GET nqty      PICTURE "99999.99"
   nl+= 2
   @ nl, 4      SAY "Supplied Qty" GET ngoodSent PICTURE "99999.99"
   nl++
   @ nl, 4      SAY "How Sent" GET csentby PICTURE "@X"
   @ nl,COL()+1 SAY "Docket #" GET cdocno  PICTURE "@X"
   nl++
   @ nl,45      SAY "Ordered Date"
   @ nl,COL()+1 SAY QuotOrd->DbDate PICTURE "99/99/9999" COLOR "RG+"
   nl++
   @ nl, 4      SAY "O/N "     GET cordnum PICTURE "@X"
   @ nl,COL()+2 SAY "Date"     GET ddbDate PICTURE "99/99/9999"
   @ nl,COL()+2 SAY "Due Date" GET ddueDate PICTURE "99/99/9999"
    READ
   SCROLL( 1,68,23,78 ) 
   DISPBOX( 1,68, 24,79, 2 )
   mchoice := VAL( STR( MONTH( dduedate ) ) )+3
   @  5,70 PROMPT "URGENT  "  
   @  6,70 PROMPT "SPECIAL "
   @  7,70 PROMPT "PRIORITY"
   @ 10,70 PROMPT "JANUARY "  
   @ 11,70 PROMPT "FEBRUARY"
   @ 12,70 PROMPT "MARCH   "      
   @ 13,70 PROMPT "APRIL   "
   @ 14,70 PROMPT "MAY     "
   @ 15,70 PROMPT "JUNE    "
   @ 16,70 PROMPT "JULY    "
   @ 17,70 PROMPT "AUGUST  "
   @ 18,70 PROMPT "SEPT    "
   @ 19,70 PROMPT "OCTOBER "
   @ 20,70 PROMPT "NOVEMBER"
   @ 21,70 PROMPT "DECEMBER"
   MENU TO mchoice
   DO CASE
      CASE LASTKEY() = 27
         RETURN NIL
      CASE mchoice == 1
         cfaxno := "  URGENT"
      CASE mchoice == 2
         cfaxno := " SPECIAL"
      CASE mchoice == 3
         cfaxno := "   PRIOR"
      CASE mchoice == 4
         cfaxno := "JANUARY "
      CASE mchoice == 5
         cfaxno := "FEBUARY "
      CASE mchoice == 6
         cfaxno := "MARCH   "
      CASE mchoice == 7
         cfaxno := "APRIL   "
      CASE mchoice == 8
         cfaxno := "MAY     "
      CASE mchoice == 9
         cfaxno := "JUNE    "
      CASE mchoice == 10
         cfaxno := "JULY    "
      CASE mchoice == 11
         cfaxno := "AUGUST  "
      CASE mchoice == 12
         cfaxno := "SEPT    "
      CASE mchoice == 13
         cfaxno := "OCTOBER "
      CASE mchoice == 14
         cfaxno := "NOVEMBER"
      CASE mchoice == 15
         cfaxno := "DECEMBER"
   ENDCASE
   nl+=2
   @ nl, 8 SAY "Reference" GET cfaxno PICTURE "@!"
   nl+=2
   @ nl, 8 GET cinfo   PICTURE "@X"
   nl++
   @ nl, 8 GET cinfo2  PICTURE "@X"
   nl++
   @ nl, 8 GET cinfo3  PICTURE "@X"
   nl++
   @ nl, 8 GET cinfo4  PICTURE "@X"
    READ
    ApRLock( 3 )
   QuotOrd->Qty      := nqty
   QuotOrd->GoodSent := ngoodsent
   QuotOrd->Ordnum   := cordnum
   QuotOrd->DbDate   := ddbdate
   QuotOrd->DueDate  := dduedate
   QuotOrd->Sentby   := csentby
   QuotOrd->Docno    := cdocno
   QuotOrd->Faxno    := cfaxno
   QuotOrd->Info     := cinfo
   QuotOrd->Info2    := cinfo2
   QuotOrd->Info3    := cinfo3
   QuotOrd->Info4    := cinfo4
   QuotOrd->Accepted := "Y"
   UNLOCK

   RETURN NIL
   ****------- End ChangeFac

   **-------------------------------------------------------------------

FUNCTION FacDisp()                 // called by ChriMenu ChriFac

   nselect := 1
   SCROLL()
   mcontinue := "Y" 
   DO WHILE mcontinue = "Y"
      SELECT QuotOrd
      GOTO TOP
      IF LASTREC() = 0
         @ 7,53 SAY "NO Work Orders"
         INKEY( 2 ) 
         RETURN NIL
      ENDIF
      ****   @ 10,10 SAY "Work Orders Listings" COLOR "BG+"
      SET ORDER TO 1
      SCROLL( 22, 0,24,80 ) 
      DISPBOX( 22,1, 24,79, 2 )
      @ 23, 8      PROMPT "URGENT"  
      @ 23,COL()+2 PROMPT "Due Date"  
      @ 23,COL()+2 PROMPT "List by Name"
      @ 23,COL()+2 PROMPT "Partnum List"
      @ 23,COL()+2 PROMPT "Order Date"
      MENU TO nselect
      DO CASE
         CASE LASTKEY() = 27
            RETURN NIL
         CASE nselect == 1                  // Urgent
            nselect := 1
            SCROLL()
            nchoice := 1
            SCROLL( 1,68,23,78 ) 
            DISPBOX( 1,68, 24,79, 2 )
            ***         mchoice := VAL( STR( MONTH( dduedate ) ) )+3
            @  5,70 PROMPT "URGENT  "  
            @  6,70 PROMPT "SPECIAL "
            @  7,70 PROMPT "PRIORITY"
            @ 10,70 PROMPT "JANUARY "  
            @ 11,70 PROMPT "FEBRUARY"
            @ 12,70 PROMPT "MARCH   "      
            @ 13,70 PROMPT "APRIL   "
            @ 14,70 PROMPT "MAY     "
            @ 15,70 PROMPT "JUNE    "
            @ 16,70 PROMPT "JULY    "
            @ 17,70 PROMPT "AUGUST  "
            @ 18,70 PROMPT "SEPT    "
            @ 19,70 PROMPT "OCTOBER "
            @ 20,70 PROMPT "NOVEMBER"
            @ 21,70 PROMPT "DECEMBER"
            MENU TO mchoice
            DO CASE
               CASE LASTKEY() = 27
                  RETURN NIL
               CASE mchoice == 1
                  cfaxno := "  URGENT"
               CASE mchoice == 2
                  cfaxno := " SPECIAL"
               CASE mchoice == 3
                  cfaxno := "   PRIOR"
               CASE mchoice == 4
                  cfaxno := "JANUARY "
               CASE mchoice == 5
                  cfaxno := "FEBUARY "
               CASE mchoice == 6
                  cfaxno := "MARCH   "
               CASE mchoice == 7
                  cfaxno := "APRIL   "
               CASE mchoice == 8
                  cfaxno := "MAY     "
               CASE mchoice == 9
                  cfaxno := "JUNE    "
               CASE mchoice == 10
                  cfaxno := "JULY    "
               CASE mchoice == 11
                  cfaxno := "AUGUST  "
               CASE mchoice == 12
                  cfaxno := "SEPT    "
               CASE mchoice == 13
                  cfaxno := "OCTOBER "
               CASE mchoice == 14
                  cfaxno := "NOVEMBER"
               CASE mchoice == 15
                  cfaxno := "DECEMBER"
            ENDCASE
            aPart_ :={}
            anum   :={}
            nrecno := 0
            nqty   := 0
            GOTO TOP
            DO WHILE QuotOrdOrd->( !EOF() )
               IF QuotOrd->Codeno = "A       "
                  SKIP ALIAS QuotOrd
                  LOOP
               ENDIF
               IF QuotOrd->Faxno != cfaxno
                  SKIP ALIAS QuotOrd
                  LOOP
               ENDIF
               nqty++
               ddate := STR( YEAR( QuotOrd->Duedate ) );
                  +STR( MONTH( QuotOrd->DueDate ) );
                  +STR( DAY( QuotOrd->DueDate ) );
                  +" "+QuotOrd->Faxno
               AADD( aPart_,ddate;
                  +" "+SUBSTR( QuotOrd->Info, 1,20 );
                  +" "+QuotOrd->Codeno+" "+QuotOrd->BranchId;
                  +" "+SUBSTR( QuotOrd->Partnum, 1, 8 );
                  +" "+STR( QuotOrd->Qty, 6, 0 );
                  +" "+STR( QuotOrd->Goodsent, 6, 0 );
                  +"                "+STR( RECNO(),6 ) )
               SKIP ALIAS QuotOrd
            ENDDO
            SCROLL()
            DISPBOX( 0, 1, 24,79, 2 )
            IF !EMPTY( aPart_ )
               @ 0,10      SAY "  Records  "
               @ 0,COL()+1 SAY nqty PICTURE "9999" COLOR "RG+"
               ASORT(aPart_,,,{ | x,y | x < y })                // < = Top > = End
               anum := ACHOICE( 1, 2, 23,78, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               IF LASTKEY() = 27
                  RETURN NIL
               ENDIF
            ENDIF     // Empty
            IF nqty = 0
                SCROLL()
                DISPBOX( 5, 1, 14,79, 2 )
                @ 10,10 SAY "No Records this selection"
                @ 12,10 SAY "" 
                WAIT
                LOOP 
            ENDIF             // nrecno

         CASE nselect == 2
            nselect := 2
            aPart_ :={}
            anum   :={}
            nrecno := 0
            GOTO TOP
            DO WHILE QuotOrd->( !EOF() )
               IF QuotOrd->Codeno = "A       "
                  SKIP ALIAS QuotOrd
                  LOOP
               ENDIF
               ddate := STR( YEAR( QuotOrd->Duedate ) )+STR( MONTH( QuotOrd->DueDate ) );
                  +STR( DAY( QuotOrd->DueDate ) )+" "+QuotOrd->Faxno
               AADD( aPart_,ddate;
                  +" "+SUBSTR( QuotOrd->Info, 1,20 );
                  +" "+QuotOrd->Codeno+" "+QuotOrd->BranchId;
                  +" "+SUBSTR( QuotOrd->Partnum, 1, 8 );
                  +" "+STR( QuotOrd->Qty, 6, 0 );
                  +" "+STR( QuotOrd->Goodsent, 6, 0 );
                  +"                "+STR( RECNO(),6 ) )
               SKIP ALIAS QuotOrd
            ENDDO
            DISPBOX( 0, 1, 24,79, 2 )
            @  0, 3 SAY " Due Date " COLOR "RG+" 
            IF !EMPTY( aPart_ )
               ASORT(aPart_,,,{ | x,y | x < y })                // < = Top > = End
               anum := ACHOICE( 1, 2, 23,78, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               IF LASTKEY() = 27
                  RETURN NIL
               ENDIF
            ENDIF     // Empty

         CASE nselect == 3
            nselect := 3
            aPart_ :={}
            anum   :={}
            nrecno := 0
            GOTO TOP
            DO WHILE QuotOrd->( !EOF() )
               IF QuotOrd->Codeno = "A       "
                  SKIP ALIAS QuotOrd
                  LOOP
               ENDIF
               ddate := STR( YEAR( QuotOrd->Duedate ) );
                  +STR( MONTH( QuotOrd->DueDate ) );
                  +STR( DAY( QuotOrd->DueDate ) );
                  +" "+QuotOrd->Faxno
               AADD( aPart_,QuotOrd->Codeno;
                  +" "+QuotOrd->BranchId;
                  +" "+SUBSTR( QuotOrd->Partnum, 1, 8 );
                  +" "+STR( QuotOrd->Qty, 6, 0 );
                  +" "+STR( QuotOrd->Goodsent, 6, 0 );
                  +" "+SUBSTR( QuotOrd->Info, 1,20 );
                  +" "+ddate;
                  +"               "+STR( RECNO(),6 ) )
               SKIP ALIAS QuotOrd
            ENDDO
            DISPBOX( 0, 1, 24,79, 2 )
            @  0, 3 SAY " Name List " COLOR "RG+" 
            IF !EMPTY( aPart_ )
               ASORT(aPart_,,,{ | x,y | x < y })
               anum := ACHOICE( 1, 2, 23,78, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               IF LASTKEY() = 27
                  RETURN NIL
               ENDIF
            ENDIF     // Empty


         CASE nselect == 4
            nselect := 4
            aPart_ :={}
            anum   :={}
            nrecno := 0
            GOTO TOP
            DO WHILE QuotOrd->( !EOF() )
               IF QuotOrd->Codeno = "A       "
                  SKIP ALIAS QuotOrd
                  LOOP
               ENDIF
               ddate := STR( YEAR( QuotOrd->Duedate ) );
                  +STR( MONTH( QuotOrd->DueDate ) );
                  +STR( DAY( QuotOrd->DueDate ) );
                  +" "+QuotOrd->Faxno
               AADD( aPart_,SUBSTR( QuotOrd->Partnum, 1, 8 );
                  +" "+STR( QuotOrd->Qty, 6, 0 );
                  +" "+STR( QuotOrd->Goodsent, 6, 0 );
                  +" "+QuotOrd->Codeno+" "+QuotOrd->BranchId;
                  +" "+ddate;
                  +" "+SUBSTR( QuotOrd->Info, 1,20 );
                  +"                "+STR( RECNO(),6 ) )
               SKIP ALIAS QuotOrd
            ENDDO
            DISPBOX( 0, 1, 24,79, 2 )
            @  0, 3 SAY " PartNum " COLOR "RG+" 
            IF !EMPTY( aPart_ )
               ASORT(aPart_,,,{ | x,y | x < y })                // < = Top > = End
               anum := ACHOICE( 1, 2, 23,78, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               IF LASTKEY() = 27
                  RETURN NIL
               ENDIF
            ENDIF     // Empty

         CASE nselect == 5
            nselect := 5
            aPart_ :={}
            anum   :={}
            nrecno := 0
            GOTO TOP
            DO WHILE QuotOrd->( !EOF() )
               IF QuotOrd->Codeno = "A       "
                  SKIP ALIAS QuotOrd
                  LOOP
               ENDIF
               ddate := STR( YEAR( QuotOrd->Duedate ) );
                  +STR( MONTH( QuotOrd->DueDate ) );
                  +STR( DAY( QuotOrd->DueDate ) );
                  +" "+QuotOrd->Faxno
               dTest := STR( YEAR( QuotOrd->DbDate ) );
                  +STR( MONTH( QuotOrd->DbDate ) );
                  +STR( DAY( QuotOrd->DbDate ) )
               AADD( aPart_,dTest;
                  +" "+ddate;
                  +" "+QuotOrd->Codeno;
                  +" "+QuotOrd->BranchId;
                  +" "+SUBSTR( QuotOrd->Partnum, 1, 8 );
                  +" "+STR( QuotOrd->Qty, 6, 0 );
                  +" "+STR( QuotOrd->Goodsent, 6, 0 );
                  +" "+SUBSTR( QuotOrd->Info, 1,10 );
                  +"               "+STR( RECNO(),6 ) )
               SKIP ALIAS QuotOrd
            ENDDO
            DISPBOX( 0, 1, 24,79, 2 )
            @  0, 3 SAY " Order Date " COLOR "RG+" 
            IF !EMPTY( aPart_ )
               ASORT(aPart_,,,{ | x,y | x < y })
               anum := ACHOICE( 1, 2, 23,78, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               IF LASTKEY() = 27
                  RETURN NIL
               ENDIF
            ENDIF     // Empty
      ENDCASE 

      ChangeFac()                        // Above
      LOOP

   ENDDO                      // mcontinue

   RETURN NIL
   ****---- End of FacDis()

   **-------------------------------------------------------------------

FUNCTION LabCutCopy()

   SCROLL( 4, 3, 23,54 )
   mpartnum := Part->Partnum
   ***   minvno := Debit->Invno
   aPart_ := {}
   anum   := {}
   nrecno := 0
   SELECT Labour
   GOTO TOP
   mfind := SPACE( 20 ) 
   DO WHILE Labour->( !EOF() )
      IF Labour->Partnum != mfind
         SKIP ALIAS Labour
         LOOP 
      ENDIF
   ***      IF Labour->Weekno = Debit->Invno
   ***         SKIP ALIAS Labour
   ***         LOOP 
   ***      ENDIF
      SELECT Labour   
      AADD( aPart_,Labour->Desc;
              +" "+STR( Labour->Time );
              +" "+Labour->Invno;
              +"                   "+STR( RECNO(),6 ) )
      SKIP ALIAS Labour
   ENDDO                       // EOF()
   IF !EMPTY( aPart_ )
   SCROLL( 0, 0, 3,55 )
   DISPBOX( 0, 1, 3,55, 2 ) 
   @ 1, 2 SAY Part->Invno COLOR "BG+" 
      SCROLL( 3, 0, 24,56 )
      DISPBOX( 3, 1, 24,56, 2 ) 
      ASORT( aPart_,,,{ | x,y | x < y } )
      anum := ACHOICE(  4, 3, 23,54,aPart_,,"AFUNC" )
      nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
      GOTO nrecno
      IF PressedEsc()
         RETURN NIL
      ENDIF
   ENDIF
   manother := "Y"
   DO WHILE manother = "Y"
      SCROLL( 0, 0, 2,55 )
      DISPBOX( 0, 1, 3,55, 2 ) 
      @ 1, 3 SAY Part->Partnum COLOR "BG+" 
      @ 2, 3 SAY Labour->Desc COLOR "RG+" 
      DISPBOX( 3, 1, 24,55, 2 ) 
      aPart_ := {}
      anum   := {}
      SELECT LabCut
      GOTO TOP
      DO WHILE LabCut->( !EOF() )
    ***     IF LabCut->Operno != minvno
    ***        SKIP ALIAS LabCut
    ***        LOOP 
    ***     ENDIF
         AADD( aPart_,LabCut->Order;
                      +" "+SUBSTR( LabCut->Desc, 1,17 ) )
         SKIP ALIAS LabCut
      ENDDO                       // EOF()
      IF !EMPTY( aPart_ )
         SCROLL( 0,56, 24,80 )
         DISPBOX( 0,56, 24,79, 2 ) 
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  1,58, 23,78,aPart_,,"AFUNC" )
         IF PressedEsc()
            RETURN NIL
         ENDIF
      ENDIF
      maccept := ApGetY( "Copy Operation" )
      IF PressedEsc()
         RETURN NIL
      ENDIF
      IF maccept = "Y"
    ***     SELECT Labour
      ***       ApRLock( 3 )
      ***       Labour->Weekno := Debit->Invno
      ***      UNLOCK
         cDesc    := Labour->Desc
         ntime    := Labour->Time
         @ 1, 2                     GET cDesc PICTURE "@X"
         @ 2, 2      SAY "                                      "             
         @ 2, 2      SAY Part->Partnum COLOR "BG+" 
         @ 2,COL()+2 SAY "Time hrs" GET ntime PICTURE "9999.99" 
          READ
         SELECT LabCut
          ApFLock( 3 )
         APPEND BLANK
         LabCut->Partnum := Part->Partnum
         LabCut->Desc    := cDesc
         LabCut->Order   := "ZZ"
         LabCut->Time    := ntime 
         LabCut->Date    := DATE()
         LabCut->Operno  := Part->Catno
         UNLOCK
      ENDIF          // maccept
      IF PressedEsc()
         RETURN NIL
      ENDIF
      LabCutCopy()         
   ENDDO               // manother

   RETURN mpartnum

   ***-----------------  End Of  LabCutCopy

   ***--------------------------------------------------------------------------

FUNCTION LabCutDate()
   SCROLL()
   ndays  := 60
   nprice := 5
   @ 10,10 SAY "You Can Print the Module Parts List to level 4"
   @ 12,10 SAY "How Many days for Part Date Back" GET ndays PICTURE "9999"
   @ 14,10 SAY "   Only show Parts above $" GET nprice PICTURE "999999.99"
    READ
   mwhere := "S"

    PrintSel( mwhere )

  IF mwhere == "P"
     npl := 56
    ELSE
     npl := 20
  ENDIF
   nl := 3
   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL()
      ***   mcodeno := Debit->Codeno   
      ***   minvno  := Debit->Invno
      SELECT Part
      SET ORDER TO 1                    // Codeno
      SEEK mpartnum
      @  0, 2 SAY Part->Partnum
      ***   @  0,22 SAY Name->Name
      @  1, 1 SAY Part->Desc
      @  1,64 SAY ndays PICTURE "9999"
      @  1,70 SAY nprice PICTURE "$9,999.99"
      DO WHILE Part->Partnum = mpartnum .AND. Part->( !EOF() )
         IF Part->Partnum != mpartnum
            SKIP ALIAS Part
            LOOP
         ENDIF
         IF SUBSTR( Part->Partnum, 1, 2 ) = "ZZ"
            SKIP ALIAS Part
            LOOP
         ENDIF
    ***     SELECT Part
    ***     SET ORDER TO 1               // Partnum
    ***     SEEK Quot->Partnum
         nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
         nqty1:= nqty2:= nqty3:= nqty4 := 0
         nequ1:= nequ2:= nequ3:= nequ4 := 0
         nquot := Quot->Qty
         mmod1 := TRIM( Part->Partnum )
         IF Part->Date < DATE()-ndays .AND. Part->Trade >= nprice
            @ nl, 2 SAY STR( nquot, 9, 2 );
                         +" "+Part->Desc;
                         +"  "+STR( Part->Trade,12, 2 );
                         +"  "+DTOC( Part->Date )
            nl++ 
         ENDIF
         SELECT Equ
         GOTO TOP
      ***      SET EXACT ON
         SEEK mmod1
         IF FOUND()   
      DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
         IF SUBSTR( Equ->Modcode, 1, 2 ) = "ZZ"
            SKIP ALIAS Part
            LOOP
         ENDIF
              IF nl > npl
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
         nqty1 := nquot*Equ->PartQty
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         IF Part->Date < DATE()-ndays .AND. Part->Trade >= nprice
             IF SUBSTR( Part->Partnum, 1, 2 ) != "ZZ"

            @ nl, 0 SAY SUBSTR( Equ->Modcode, 1, 7 );
                         +" "+SUBSTR( Part->Partnum, 1,15 );
                         +" "+SUBSTR( Part->Desc, 1,24 );
                         +" "+STR( Equ->Partqty, 8, 2 );
                         +" "+STR( Part->Trade,10, 2 );
                         +" "+DTOC( Part->Date )
            nl++
            ENDIF
         ENDIF
         SELECT Equ
         mmod2 := TRIM( Equ->Partnum )
         nrecno2 := RECNO() 
         GOTO TOP
         SEEK mmod2
         IF FOUND()   
      ***         AADD( aPart_," " )
            DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
              IF nl > npl
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
               nqty2 := Equ->PartQty
               nequ2 := ( nqty1 * nqty2 )* nquot
               SELECT Part
               SEEK Equ->Partnum
         SELECT Equ
         IF Part->Date < DATE()-ndays .AND. Part->Trade >= nprice
             IF SUBSTR( Part->Partnum, 1, 2 ) != "ZZ"
            @ nl, 0 SAY SUBSTR( Equ->Modcode, 1, 7 );
                         +" "+SUBSTR( Part->Partnum, 1,15 );
                         +" "+SUBSTR( Part->Desc, 1,24 );
                         +" "+STR( Equ->Partqty, 8, 2 );
                         +" "+STR( Part->Trade,10, 2 );
                         +" "+DTOC( Part->Date )
            nl++
            ENDIF
         ENDIF
         SELECT Equ
         mmod3 := TRIM( Equ->Partnum )
         nrecno3 := RECNO() 
         GOTO TOP
         SEEK mmod3
         IF FOUND()   
      ***         AADD( aPart_," " )
            DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
              IF nl > npl
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
               nqty3 := Equ->PartQty
               nequ3 := nqty1 * nqty2 * nqty3 * nquot
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         IF Part->Date < DATE()-ndays .AND. Part->Trade >= nprice
             IF SUBSTR( Part->Partnum, 1, 2 ) != "ZZ"
             @ nl, 0 SAY SUBSTR( Equ->Modcode, 1, 7 );
                          +" "+SUBSTR( Part->Partnum, 1,15 );
                          +" "+SUBSTR( Part->Desc, 1,24 );
                         +" "+STR( Equ->Partqty, 8, 2 );
                         +" "+STR( Part->Trade,10, 2 );
                         +" "+DTOC( Part->Date )
            nl++
            ENDIF
         ENDIF
            SELECT Equ
            mmod4   := TRIM( Equ->Partnum )
            nrecno4 := RECNO()
            GOTO TOP
            SEEK mmod4
            IF FOUND()
               DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
              IF nl > npl
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
                  nqty4 := Equ->PartQty
                  nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         IF Part->Date < DATE()-ndays .AND. Part->Trade >= nprice
             IF SUBSTR( Part->Partnum, 1, 2 ) != "ZZ"
            @ nl, 0 SAY SUBSTR( Equ->Modcode, 1, 7 );
                         +" "+SUBSTR( Part->Partnum, 1,15 );
                         +" "+SUBSTR( Part->Desc, 1,24 );
                         +" "+STR( Equ->Partqty, 8, 2 );
                         +" "+STR( Part->Trade,10, 2 );
                         +" "+DTOC( Part->Date )
            nl++
            ENDIF 
         ENDIF
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
         SELECT Part
         SKIP ALIAS Part
      ENDDO                            //   EOF() Part
      mcontinue := "N" 
   ENDDO
   IF mwhere = "S"
      INKEY()
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
     ELSE
      EndPrint()
   ENDIF

   SELECT Part
   SEEK mpartnum

   ***-----------------  End Of  LabCutDate

   ****-------------------------------------------------------------------------

FUNCTION LabCutPrint()

   mwhere := "S"

   PrintSel( mwhere )

   IF mwhere == "P"
      npl := 56
   ELSE
      npl := 16
   ENDIF
   nl := 0
   nTotTime := 0
   @ nl, 0 SAY Control->U_Name
   @ nl,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
               +STR( YEAR(DATE() ),5 )
   nl+=2
   @ nl, 1 SAY Part->Partnum
   @ nl,21 SAY Part->Desc
   ***        @ nl,52 SAY "Time"
   nl+=2
   ntimetotal:= ntime := 0
   SELECT LabCut
   GOTO TOP
   DO WHILE LabCut->( !EOF() )
      IF LabCut->Partnum != mpartnum
         SKIP ALIAS LabCut
         LOOP
      ENDIF
      IF nl > npl
         IF mwhere = "P"
            EJECT
            nl := 0
            @ nl, 0 SAY Control->U_Name
            @ nl,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ),5 )
            nl+=2
            @ nl, 1 SAY Part->Partnum
            @ nl,21 SAY Part->Desc
             ***       @ nl,52 SAY "Time"
            nl+=2
         ELSE
            WAIT
            SCROLL()
            nl := 0
         ENDIF
      ENDIF
      @ nl, 1 SAY LabCut->Order
      @ nl, 5 SAY LabCut->Desc
      IF LabCut->Time > 0
         @ nl,48 SAY LabCut->Time PICTURE "99,999.99"
      ENDIF
      @ nl,59 SAY LabCut->Operno
      IF LabCut->Priority != Debit->Invno 
         @ nl,68 SAY LabCut->Priority
      ENDIF
      ntotTime += LabCut->Time
      nl++
      SKIP ALIAS LabCut
   ENDDO                        // LabCut EOF
   @ nl,46 SAY "-----------"
   nl++
   @ nl,35 SAY "Total Time"
   @ nl,48 SAY ntotTime PICTURE "99,999.99"
   @ nl,58 SAY "Hours"
   ***       @ nl,58 SAY "Time/60"
   ***       @ nl,66 SAY ntotTime/60 PICTURE "9,999.99"
   nl+=2
   ****      mmodcode := SUBSTR( mpartnum, 1,16 )
   IF mwhere = "S"
      INKEY()
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
     ELSE
      EndPrint()
   ENDIF

   RETURN NIL

   ***-----------------  End Of  LabCutPrint

   ****-------------------------------------------------------------------------

FUNCTION LabCutOper()
   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
   @  1, 8 SAY mpartnum+"  Viewing Part Operation"
   aPart_:={}
   nrecno   := 0
   SELECT PartOper
   GOTO TOP
   DO WHILE PartOper->( !EOF() )
      IF PartOper->Operno != Debit->Operno
         SKIP ALIAS PartOper
         LOOP
      ENDIF  
      AADD( aPart_,PartOper->Order;
                  +" "+PartOper->Desc;
                  +" "+STR( PartOper->Time, 8, 2 );
                  +"  "+PartOper->Operno;
                  +"  "+PartOper->Adminno;
                  +"             "+STR( RECNO(),6 ) )
      SKIP ALIAS PartOper
   ENDDO                        // PartOper EOF
   ntime := 0
   IF !EMPTY( aPart_ )
      ASORT( aPart_,,,{ | x,y | x < y } )
      SCROLL(  3, 0, 24,80 )
      DISPBOX( 3, 1, 24,79, 2 )
      ***       @ 3, 6 SAY " F2 To Add "
      anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
      ***        IF LASTKEY() == -1
      ***           JobOperate()                           // Below
      ***        ENDIF
      IF PressedEsc()
         RETURN NIL
      ENDIF
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      GOTO nrecno
      SCROLL( 19, 0, 24,80 )
      DISPBOX( 19, 1, 24,79, 2 )
      nl := 20
      SELECT Operate
      cdesc    := PartOper->Desc
      coperno  := PartOper->Operno
      corder   := PartOper->Order
      ntime    := PartOper->Time
      @ nl,10      SAY "Process Desc" GET cdesc   PICTURE "@X"
      nl+=2
      @ nl,10      SAY "Ref"          GET coperno PICTURE "@!"
      @ nl,COL()+2 SAY "Order"        GET corder  PICTURE "@!"
      @ nl,COL()+2 SAY "Time"         GET ntime   PICTURE "9999.99"
      @ nl,COL()+1 SAY "in Hours"
       READ
   ENDIF                        // Empty
   SELECT LabCut
    ApFlock( 3 )
   APPEND BLANK
   LabCut->Operno   := PartOper->Operno
   LabCut->Time     := ntime
   LabCut->Rate     := PartOper->Rate
   LabCut->Desc     := cdesc      
   LabCut->Order    := corder      
   LabCut->Partnum  := mpartnum
   LabCut->Date     := DATE()
   LabCut->Priority := Debit->Invno
    READ
   UNLOCK

   RETURN mpartnum

   ***-----------------  End Of  LabCutOper

   ****-------------------------------------------------------------------------

FUNCTION IvcLabPart()

   mcodeno := Name->Codeno
   cname   := SPACE( 40 )
   aPart_:={}
   nrecno := 0
   ntotal:= nlabour := 0
   SELECT Labour
   SET ORDER TO 2                     // Invno+Partnum+Codeno
   GOTO TOP
   SEEK Debit->Invno
   DO WHILE Labour->Invno = Debit->Invno .AND. Labour->( !EOF() )
      /*
      IF Labour->Partnum = SPACE( 20 )
         SKIP ALIAS Labour
         LOOP
      ENDIF
      IF SUBSTR( Labour->Codeno, 5, 1 ) != " "
         SKIP ALIAS Labour
         LOOP
      ENDIF
      IF SUBSTR( Labour->Codeno, 4, 1 ) = " "
         SKIP ALIAS Labour
         LOOP
      ENDIF
      */
      nlabour += Labour->Time
      ntotal  += Labour->Time*Labour->Rate
      AADD( aPart_,Labour->Codeno;
                +" "+SUBSTR( Labour->Desc, 1,30 );
                +" "+STR( Labour->Time, 8, 2 );
                +" "+STR( Labour->Rate, 9, 2 );
                +"                             "+STR( RECNO(), 6 ) ) 
      SKIP ALIAS Labour
   ENDDO                        // Labour EOF
   ***                      +" "+SUBSTR( Labour->Partnum, 1,16 );
   IF !EMPTY( aPart_ )
      SCROLL()
      DISPBOX( 0, 1, 3,79, 2 )
      @  1, 4      SAY Name->Name+"  "+Name->Codeno
      @  2,14      SAY "Time" 
      @  2,COL()+1 SAY nlabour PICTURE "99,999.99"   COLOR "BG+"
      @  2,COL()+1 SAY "Labour Rate"
      @  2,COL()+1 SAY ntotal  PICTURE "$999,999.99" COLOR "BG+"
      @  2,COL()+2 SAY Debit->Invno  COLOR "BG+"
      @  2,COL()+2 SAY Debit->DbDate COLOR "BG+"
      DISPBOX( 4, 0, 24,79, 2 )
      ASORT(aPart_,,,{ | x,y | x < y })
      anum := ACHOICE(  5, 3, 23,78,aPart_,,"AFUNC" )
      IF PressedEsc()
         RETURN NIL
      ENDIF
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      GOTO nrecno
   ENDIF                        // not Empty
   IF EMPTY( aPart_ )
      SCROLL(  14, 0, 18,80 )
      DISPBOX( 14, 0, 18,79, 2 )
      @ 18, 10 SAY "No Labour or Parts for "+Debit->Invno
   ENDIF                        // Empty
   manother = "Y"
   DO WHILE manother = "Y"
   SCROLL(  19, 0, 24,80 )
   DISPBOX( 19, 0, 24,79, 2 )
   @ 24,60 SAY " DT118 "
   nselect := 1
   @ 19, 10 SAY " --- Labour/Parts --- "
   @ 19, 56 SAY " -- Labour/Parts -- "

   @ 21, 4      PROMPT "1. Labour Add"
   @ 21,COL()+2 PROMPT "2. Add Part"
   @ 21,COL()+2 PROMPT "3. Edit Labour"
   @ 21,COL()+2 PROMPT "4. Print JC"

   @ 23, 4      PROMPT "5. Lab/Parts List"
   @ 23,COL()+2 PROMPT "6. By Part Desc"
   @ 23,COL()+2 PROMPT "7. Delete"
   @ 23,COL()+2 PROMPT "Return"
      *** @ 23,COL()+2 PROMPT "Information"
   MENU TO nselect
   DO CASE
      CASE nselect == 8
        RETURN NIL
      CASE PressedEsc()
         SELECT Name
         SEEK mcodeno
         mcodeno := Name->Codeno 
          RETURN mcodeno
      CASE nselect == 1                // ADD NEW
      ***         IF SUBSTR( Control->U_Name,1, 4 ) = "META" 
               LabourWo()                   // XLF_QU5
      ***           ELSE
      ***            LabourShan()                 // XLF_QU10 
      ***         ENDIF   
         LOOP
      CASE nselect == 2                // ADD NEW PART
         mpartnum := SPACE( 20 )

          PartFind( mpartnum )

         mpartnum := Part->Partnum
         mcorrect := "N"
         DO WHILE mcorrect == "N"
            SELECT Labour
             ApRLock( 3 )
            APPEND BLANK
            Labour->Codeno  := "  MANUAL"
            Labour->Date    := DATE()
            Labour->Invno   := Debit->Invno
            Labour->Rate    := Part->Trade
            Labour->Desc    := Part->Desc
            Labour->Partnum := Part->Partnum
            UNLOCK
            mpartnum := Labour->Partnum
            mdesc    := Labour->Desc
            mmessage := Labour->Message
            mfault   := Labour->Fault
            ntime    := Labour->Time
            nrate    := Labour->Rate
            minvno   := Labour->Invno
            ddate    := Labour->Date
            SCROLL(  10, 0, 24,80 ) 
            DISPBOX( 10, 1, 21,79, 2 )
            @ 12,10      SAY "Partnum"  GET mpartnum PICTURE "@K!"
            @ 14,10      SAY "Desc"     GET mdesc    PICTURE "@KX"
            @ 15,10                     GET mmessage PICTURE "@KX"
            @ 16,10                     GET mfault   PICTURE "@KX"
            @ 18,10      SAY "Qty "     GET ntime    PICTURE "9999.99"
            @ 18,COL()+2 SAY "Cost"     GET nrate    PICTURE "99999.99"
            @ 19,10      SAY "JC-"      GET minvno   PICTURE "@!"
            @ 19,COL()+2 SAY "Date"     GET ddate    PICTURE "99/99/9999"
             READ
             ApRLock( 3 )
            Labour->Partnum := mpartnum
            Labour->Desc    := mdesc
            Labour->Message := mmessage
            Labour->Fault   := mfault
            Labour->Time    := ntime
            Labour->Rate    := nrate
            Labour->Invno   := minvno
            Labour->Date    := ddate
            UNLOCK
            IF PressedEsc()
               RETURN NIL
            ENDIF
            mcorrect := "Y" 
         ENDDO                                            // mcorrect
         manother := "Y"
          IvcLabour()

      CASE nselect == 3                    // Edit Labour
         mcorrect := "N"
         DO WHILE mcorrect == "N"
            SELECT Labour
            mdesc    := Labour->Desc
            mmessage := Labour->Message
            mfault   := Labour->Fault
            ntime    := Labour->Time
            nrate    := Labour->Rate
            minvno   := Labour->Invno
            ddate    := Labour->Date
            mlabno   := Labour->Labno
            mcodeno  := Labour->Codeno
            mpartnum := Labour->Partnum
            SCROLL(  10, 0, 24,80 ) 
            DISPBOX( 10, 1, 19,79, 2 )
            @ 12, 8      SAY "Desc"      GET mdesc    PICTURE "@X"
            @ 13,13                      GET mmessage PICTURE "@X"
            @ 14,13                      GET mfault   PICTURE "@X"
            @ 16, 6      SAY "Time"      GET ntime    PICTURE "9999.99"
            @ 16,COL()+2 SAY "Cost"      GET nrate    PICTURE "99999.99"
            @ 16,COL()+2 SAY "JC-"       GET minvno   PICTURE "@!"
            @ 16,COL()+2 SAY "Date"      GET ddate    PICTURE "99/99/9999"
            @ 18, 6      SAY "Inv Code"  GET mlabno   PICTURE "@!"
            @ 18,COL()+1 SAY "Staff/Ord" GET mcodeno  PICTURE "@!"
            @ 18,COL()+2 SAY "Part"      GET mpartnum PICTURE "@!"
             READ
             ApRLock( 3 )
            Labour->Desc    := mdesc
            Labour->Message := mmessage
            Labour->Fault   := mfault
            Labour->Time    := ntime
            Labour->Rate    := nrate
            Labour->Invno   := minvno
            Labour->Date    := ddate
            Labour->Labno   := mlabno
            Labour->Codeno  := mcodeno
            Labour->Partnum := mpartnum
            UNLOCK
            mdelete := ApGetN( TRIM( Message->Delete )+" Labour" )
            IF PressedEsc()
               EXIT           // RETURN NIL
            ENDIF
            IF mdelete == "Y"
               SELECT Labour
                 ApRLock( 3 )         
                 DELETE
                 UNLOCK
            ENDIF                // mdelete
            mcorrect := ApGetY( Message->Correct )
         ENDDO                                            // mcorrect
         manother := "Y"
          IvcLabour()

      CASE nselect == 4
          LabPrint()                    // JobFunc
         SELECT Name
         SEEK Debit->Codeno
         mcodeno := Name->Codeno 
         manother := "Y"
          IvcLabour()

      CASE nselect == 5                  // Parts Only List 

          QuotStkXY()                     // JobFunc
          LabXYParts()                    // JobFunc

         SELECT Name
         SEEK Debit->Codeno
         mcodeno := Name->Codeno 
         manother := "Y"
          IvcLabour()

      CASE nselect == 6                // By Parts List
         aPart_:={}
         nrecno := 0
         ntotal:= nlabour := 0
      SELECT Labour
      SET ORDER TO 2                     // Invno+Partnum+Codeno
      GOTO TOP
      SEEK Debit->Invno
      DO WHILE Labour->Invno = Debit->Invno .AND. Labour->( !EOF() )
      ***            IF Labour->Partnum = SPACE( 20 )
      ***               nlabour += Labour->Time
      ***              ELSE
                  ntotal  += Labour->Time*Labour->Rate
      ***            ENDIF
   /*
               IF Labour->Partnum = SPACE( 20 )
                  SKIP ALIAS Labour
                  LOOP
               ENDIF
   */
               AADD( aPart_,Labour->Desc;
                         +" "+Labour->Codeno;
                         +" "+STR( Labour->Time, 8, 2 );
                         +" "+STR( Labour->Rate, 9, 2 );
                         +" "+SUBSTR( Labour->Partnum, 1,16 );
                         +"          "+STR( RECNO(), 6 ) ) 
                 SKIP ALIAS Labour
             ENDDO                        // Labour EOF
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX( 0, 1, 3,79, 2 )
         @  1, 4      SAY Name->Name+"  "+Debit->Codeno
         @  2,14      SAY "Time" 
         @  2,COL()+1 SAY nlabour PICTURE "99,999.99"   COLOR "BG+"
         @  2,COL()+1 SAY "Parts"
         @  2,COL()+1 SAY ntotal  PICTURE "$999,999.99" COLOR "BG+"
         @  2,COL()+2 SAY Debit->Invno  COLOR "BG+"
         @  2,COL()+2 SAY Debit->DbDate COLOR "BG+"
         DISPBOX( 4, 1, 24,79, 2 )
      ***      ASORT(aPart_,,,{ | x,y | x < y })
         anum := ACHOICE(  5, 3, 23,78,aPart_,,"AFUNC" )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
      ENDIF                        // Empty
      SELECT Labour
      SET ORDER TO 1
         manother := "Y"
         LOOP

      CASE nselect = 7                 // Delete
            SCROLL(  10, 0, 24,80 ) 
            DISPBOX( 11, 1, 19,79, 2 )
            @ 12, 6      SAY "Desc  "+Labour->Desc
            @ 12,COL()+1 SAY "Part "+Labour->Partnum
            @ 13, 12     SAY Labour->Message
            @ 14, 6      SAY "Time "+STR( Labour->Time )
            @ 16, 6      SAY "Invno "+Labour->Invno
            @ 16,COL()+2 SAY "Date "+DTOC( Labour->Date )
            @ 18, 6      SAY "Inv Code "+Labour->Labno
            @ 18,COL()+2 SAY "Staff "+Labour->Codeno
             READ
         mdelete := ApGetN( TRIM( Message->Delete )+" Labour" )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         IF mdelete == "Y"
            minvno := Labour->Invno 
            SELECT Labour
             ApRLock( 3 )         
            DELETE
            UNLOCK
         ENDIF
         manother := "Y"
          IvcLabour()
     ENDCASE
     manother := "Y"
      ***  ApGetY( Message->Another )
   ENDDO               // Another

   SELECT Labour
   SET ORDER TO 1

   SELECT Name
   SEEK mcodeno
   mcodeno := Name->Codeno

   RETURN mcodeno

   ****----- End of IvcLabour()

   ****--------------------------------------------------------------------------

FUNCTION IvcLabour()

   mcodeno := Name->Codeno
   cname   := SPACE( 40 )
   aPart_:={}
   nrecno := 0
   ntotal:= nlabour := 0
   SELECT Labour
   SET ORDER TO 2                     // Invno+Partnum+Codeno
   GOTO TOP
   SEEK Debit->Invno
   DO WHILE Labour->Invno = Debit->Invno .AND. Labour->( !EOF() )
            IF Labour->Partnum = SPACE( 20 )
               nlabour += Labour->Time
              ELSE
               ntotal  += Labour->Time*Labour->Rate
            ENDIF
            AADD( aPart_,Labour->Codeno;
                      +" "+SUBSTR( Labour->Partnum, 1,16 );
                      +" "+SUBSTR( Labour->Desc, 1,30 );
                      +" "+STR( Labour->Time, 8, 2 );
                      +" "+STR( Labour->Rate, 9, 2 );
                      +"        "+STR( RECNO(), 6 ) ) 
              SKIP ALIAS Labour
          ENDDO                        // Labour EOF
   IF !EMPTY( aPart_ )
      SCROLL()
      DISPBOX( 0, 0, 3,79, 2 )
      @  1, 4      SAY Name->Name+"  "+Name->Codeno
      @  2,14      SAY "Time" 
      @  2,COL()+1 SAY nlabour PICTURE "99,999.99"   COLOR "BG+"
      @  2,COL()+1 SAY "Labour Rate"
      @  2,COL()+1 SAY ntotal  PICTURE "$999,999.99" COLOR "BG+"
      @  2,COL()+2 SAY Debit->Invno  COLOR "BG+"
      @  2,COL()+2 SAY Debit->DbDate COLOR "BG+"
      DISPBOX( 4, 1, 24,79, 2 )
      ***     ASORT(aPart_,,,{ | x,y | x < y })
      anum := ACHOICE(  5, 3, 23,78,aPart_,,"AFUNC" )
      IF PressedEsc()
         RETURN NIL
      ENDIF
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      GOTO nrecno
   ENDIF                        // Not Empty
   IF EMPTY( aPart_ )
      SCROLL()
      DISPBOX( 14, 0, 21,79, 2 )
      @ 16, 10 SAY "No Labour or Parts for "+Debit->Invno
   ENDIF                        // Empty
   manother = "Y"
   DO WHILE manother = "Y"
   SCROLL(  19, 0, 24,80 )
   DISPBOX( 19, 0, 24,79, 2 )
   nselect := 1
   @ 19, 10 SAY " -- Labour/Parts -- "
   @ 19, 56 SAY " -- Labour/Parts -- "

   @ 21, 4      PROMPT "1. Labour Add"
   @ 21,COL()+2 PROMPT "2. Add Part"
   @ 21,COL()+2 PROMPT "3. Edit Labour"
   @ 21,COL()+2 PROMPT "4. Print JC"

   @ 23, 4      PROMPT "5. Lab/Parts List"
   @ 23,COL()+2 PROMPT "6. By Part Desc"
   @ 23,COL()+2 PROMPT "7. Delete"
   @ 23,COL()+2 PROMPT "Return"
   MENU TO nselect
   DO CASE
      CASE nselect == 8
         RETURN NIL
      ***     JCMenu()               // XLF_QU7

      CASE PressedEsc()
      ***      SELECT Name
      ***      SEEK mcodeno
      ***      mcodeno := Name->Codeno
      ***       RETURN mcodeno
         RETURN NIL
      CASE nselect == 1                // ADD NEW
         LabourWo()                   // XLF_Qu5.Prg  
         LOOP  
      CASE nselect == 2                // ADD NEW PART
         mpartnum := SPACE( 20 )

          PartFind( mpartnum )

         mpartnum := Part->Partnum
         mcorrect := "N"
         DO WHILE mcorrect == "N"
            SELECT Labour
             ApRLock( 3 )
            APPEND BLANK
            Labour->Codeno  := "  MANUAL"
            Labour->Date    := DATE()
            Labour->Invno   := Debit->Invno
            Labour->Rate    := Part->Trade
            Labour->Desc    := Part->Desc
            Labour->Partnum := Part->Partnum
            UNLOCK
            mpartnum := Labour->Partnum
            mdesc    := Labour->Desc
            mmessage := Labour->Message
            mfault   := Labour->Fault
            ntime    := Labour->Time
            nrate    := Labour->Rate
            minvno   := Labour->Invno
            ddate    := Labour->Date
            SCROLL(  10, 0, 24,80 ) 
            DISPBOX( 10, 1, 21,79, 2 )
            @ 12,10      SAY "Partnum"  GET mpartnum PICTURE "@K!"
            @ 14,10      SAY "Desc"     GET mdesc    PICTURE "@KX"
            @ 15,10                     GET mmessage PICTURE "@KX"
            @ 16,10                     GET mfault   PICTURE "@KX"
            @ 18,10      SAY "Qty "     GET ntime    PICTURE "9999.99"
            @ 18,COL()+2 SAY "Cost"     GET nrate    PICTURE "99999.99"
            @ 19,10      SAY "JC-"      GET minvno   PICTURE "@!"
            @ 19,COL()+2 SAY "Date"     GET ddate    PICTURE "99/99/9999"
             READ
             ApRLock( 3 )
            Labour->Partnum := mpartnum
            Labour->Desc    := mdesc
            Labour->Message := mmessage
            Labour->Fault   := mfault
            Labour->Time    := ntime
            Labour->Rate    := nrate
            Labour->Invno   := minvno
            Labour->Date    := ddate
            UNLOCK
            IF PressedEsc()
               RETURN NIL
            ENDIF
            mcorrect := "Y" 
         ENDDO                                            // mcorrect
         manother := "Y"
          IvcLabour()

      CASE nselect == 3                    // Edit Labour
         mcorrect := "N"
         DO WHILE mcorrect == "N"
            SELECT Labour
            mdesc    := Labour->Desc
            mmessage := Labour->Message
            mfault   := Labour->Fault
            ntime    := Labour->Time
            nrate    := Labour->Rate
            minvno   := Labour->Invno
            ddate    := Labour->Date
            mlabno   := Labour->Labno
            mcodeno  := Labour->Codeno
            mpartnum := Labour->Partnum
            SCROLL(  10, 0, 24,80 ) 
            DISPBOX( 10, 1, 19,79, 2 )
            @ 12, 8      SAY "Desc"      GET mdesc    PICTURE "@X"
            @ 13,13                      GET mmessage PICTURE "@X"
            @ 14,13                      GET mfault   PICTURE "@X"
            @ 16, 6      SAY "Time"      GET ntime    PICTURE "9999.99"
            @ 16,COL()+2 SAY "Cost"      GET nrate    PICTURE "99999.99"
            @ 16,COL()+2 SAY "JC-"       GET minvno   PICTURE "@!"
            @ 16,COL()+2 SAY "Date"      GET ddate    PICTURE "99/99/9999"
            @ 18, 6      SAY "Inv Code"  GET mlabno   PICTURE "@!"
            @ 18,COL()+1 SAY "Staff/Ord" GET mcodeno  PICTURE "@!"
            @ 18,COL()+2 SAY "Part"      GET mpartnum PICTURE "@!"
             READ
             ApRLock( 3 )
            Labour->Desc    := mdesc
            Labour->Message := mmessage
            Labour->Fault   := mfault
            Labour->Time    := ntime
            Labour->Rate    := nrate
            Labour->Invno   := minvno
            Labour->Date    := ddate
            Labour->Labno   := mlabno
            Labour->Codeno  := mcodeno
            Labour->Partnum := mpartnum
            UNLOCK
            IF PressedEsc()
               RETURN NIL
            ENDIF
            mdelete := ApGetN( TRIM( Message->Delete )+" Labour" )
            IF PressedEsc()
               RETURN   // EXIT          
            ENDIF
            IF mdelete == "Y"
               SELECT Labour
                 ApRLock( 3 )         
                 DELETE
                 UNLOCK
            ENDIF                // mdelete
            mcorrect := ApGetY( Message->Correct )
         ENDDO                                            // mcorrect
         manother := "Y"
          IvcLabour()

      CASE nselect == 4
          LabPrint()                    // JobFunc
         SELECT Name
         SEEK Debit->Codeno
         mcodeno := Name->Codeno 
         manother := "Y"
          IvcLabour()

      CASE nselect == 5                  // Parts Only List 

          QuotStkXY()                     // JobFunc
          LabXYParts()                    // JobFunc

         SELECT Name
         SEEK Debit->Codeno
         mcodeno := Name->Codeno 
         manother := "Y"
          IvcLabour()

      CASE nselect == 6                // By Parts List
         aPart_:={}
         nrecno := 0
         ntotal:= nlabour := 0
      SELECT Labour
      SET ORDER TO 2                     // Invno+Partnum+Codeno
      GOTO TOP
      SEEK Debit->Invno
      DO WHILE Labour->Invno = Debit->Invno .AND. Labour->( !EOF() )
               IF Labour->Partnum = SPACE( 20 )
                  nlabour += Labour->Time
                 ELSE
                  ntotal  += Labour->Time*Labour->Rate
               ENDIF
               IF Labour->Partnum = SPACE( 20 )
                  SKIP ALIAS Labour
                  LOOP
               ENDIF
               AADD( aPart_,Labour->Desc;
                         +" "+Labour->Codeno;
                         +" "+STR( Labour->Time, 8, 2 );
                         +" "+STR( Labour->Rate, 9, 2 );
                         +" "+SUBSTR( Labour->Partnum, 1,16 );
                         +"          "+STR( RECNO(), 6 ) ) 
                 SKIP ALIAS Labour
             ENDDO                        // Labour EOF
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX( 0, 1, 3,79, 2 )
         @  1, 4      SAY Name->Name+"  "+Debit->Codeno
         @  2,14      SAY "Time" 
         @  2,COL()+1 SAY nlabour PICTURE "99,999.99"   COLOR "BG+"
         @  2,COL()+1 SAY "Parts"
         @  2,COL()+1 SAY ntotal  PICTURE "$999,999.99" COLOR "BG+"
         @  2,COL()+2 SAY Debit->Invno  COLOR "BG+"
         @  2,COL()+2 SAY Debit->DbDate COLOR "BG+"
         DISPBOX( 4, 1, 24,79, 2 )
      ***      ASORT(aPart_,,,{ | x,y | x < y })
         anum := ACHOICE(  5, 3, 23,78,aPart_,,"AFUNC" )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
      ENDIF                        // Empty
      SELECT Labour
      SET ORDER TO 1
         manother := "Y"
         LOOP

      CASE nselect = 7                 // Delete
            SCROLL(  10, 0, 24,80 ) 
            DISPBOX( 11, 1, 19,79, 2 )
            @ 12, 6      SAY "Desc  "+Labour->Desc
            @ 12,COL()+1 SAY "Part "+Labour->Partnum
            @ 13, 12     SAY Labour->Message
            @ 14, 6      SAY "Time "+STR( Labour->Time )
            @ 16, 6      SAY "Invno "+Labour->Invno
            @ 16,COL()+2 SAY "Date "+DTOC( Labour->Date )
            @ 18, 6      SAY "Inv Code "+Labour->Labno
            @ 18,COL()+2 SAY "Staff "+Labour->Codeno
             READ
         mdelete := ApGetN( TRIM( Message->Delete )+" Labour" )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         IF mdelete == "Y"
            minvno := Labour->Invno 
            SELECT Labour
             ApRLock( 3 )         
            DELETE
            UNLOCK
         ENDIF
         manother := "Y"
          IvcLabour()
     ENDCASE
     manother := "Y"
      ***  ApGetY( Message->Another )
   ENDDO               // Another

   SELECT Labour
   SET ORDER TO 1

   SELECT Name
   SEEK mcodeno
   mcodeno := Name->Codeno

      RETURN mcodeno

      ****----- End of IvcLabour()

      ****--------------------------------------------------------------------------

   FUNCTION LabWOPrint( mcodeno )

   SCROLL()
   DISPBOX( 0, 1,18,79, 2 )
   @  1,20 SAY "Labour Analysis"
   @  1,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
   mstmm  := DATE()
   mendmm := DATE()+1
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
   @  0, 0 SAY Control->U_Name
   @  0,34 SAY mstmm 
   @  0,47 SAY mendmm 
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
      *** @  2, 0 SAY Name->Name
   nl := 4
      ntimetotal := 0
      SELECT Labour
      GOTO TOP
      DO WHILE Labour->( !EOF() )
         IF Labour->Partnum != SPACE( 20 )
            SKIP ALIAS Labour
            LOOP
         ENDIF  
         IF Labour->Invno != Debit->Invno
            SKIP ALIAS Labour
            LOOP
         ENDIF 
         IF Labour->Date < mstmm
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Date > mendmm
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF nl > npl
            IF mwhere == "P"
                EJECT
              ELSE
                WAIT
                SCROLL()
             ENDIF
            @  0, 0 SAY Control->U_Name
            @  0,34 SAY mstmm 
            @  0,47 SAY mendmm 
            @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ),5 )
            nl := 4
         ENDIF                       // nl>npl
         @ nl, 0 SAY Labour->Date
         @ nl,11 SAY Labour->Codeno 
         @ nl,20 SAY Labour->Desc
         @ nl,61 SAY Labour->Invno
         @ nl,68 SAY Labour->Time PICTURE "99,999.99"
         nl++
         IF Labour->Message != SPACE( 50 )
            @ nl,15 SAY Labour->Message
            nl++
         ENDIF
         IF Labour->Fault != SPACE( 50 )
            @ nl,15 SAY Labour->Fault
            nl++
         ENDIF
         ntimetotal += Labour->Time
         SKIP ALIAS Labour
      ENDDO                // EOF Labour
   @ nl,67 SAY "----------"
   nl++
   @ nl,48 SAY "Total Time"
   @ nl,68 SAY ntimetotal PICTURE "99,999.99"
   nl++
   @ nl,67 SAY "=========="
   nl++
   IF mwhere = "P"
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

   RETURN mcodeno

   ******* End of LabWOPrint()

   *********----------  END OF FILE XLF_QU1.PRG

