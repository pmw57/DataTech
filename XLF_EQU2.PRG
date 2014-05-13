   ***  JoKir19   13-10-11 07:26:33 

/* 
   Program.....:                  XLF_EQU2.PRG 
   Authors.....: J.Kirby
   Date........: 30/10/2001
   Functions...: AdminPart, AdminPart1, Admin, Mu_Oper,
            ...: JCOperation, EquAdd
   Static funcs: AdminEdit, EquVTotal
*/

STATIC FUNCTION AdminEdit( ncount, csel )

   ccatno  := Admin->Adminno  
   mcodeno := Admin->Codeno 
   msel := 1
   @ 10,30 PROMPT "1 "+TRIM( Message->Catno1 )
   @ 11,30 PROMPT "2 "+TRIM( Message->Catno2 )
   @ 12,30 PROMPT "3 Exit               " 
   MENU TO msel
   DO CASE
      CASE msel == 1
         ccatno := Message->Catno1 
      CASE msel == 2
         ccatno := Message->Catno2
      CASE msel == 3
         RETURN NIL
   ENDCASE
   DO CASE
      CASE ncount == 0
        csel := "csel0" 
      CASE ncount == 1
        csel := "csel1" 
      CASE ncount == 2
        csel := "csel2" 
      CASE ncount == 3
        csel := "csel3" 
      CASE ncount == 4
        csel := "csel4" 
      CASE ncount == 5
        csel := "csel5" 
      CASE ncount == 6
        csel := "csel6" 
      CASE ncount == 7
        csel := "csel7" 
      CASE ncount == 8
        csel := "csel8" 
      CASE ncount == 9
        csel := "csel9" 
   ENDCASE
   AdminPart( ccatno,csel )

   RETURN NIL

FUNCTION AdminPart( ccatno, csel )

   mcorrect := "Y"
   DO WHILE mcorrect == "Y"
      nqty     := 0
      ***   ccatno   := TRIM( ccatno ) 
      mpartnum := SPACE( 20 )
      SELECT Part
      SET ORDER TO 1                       // Partnum
      GOTO TOP
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      ***   @ 6,10 SAY "Selected "+cadminno+"  "+mcodeno
      ***   DO WHILE mpartnum = SPACE( 20 )
      ***      @  1, 8 SAY ccatno GET mpartnum PICTURE "@!"
      ***      @  1,COL()+2 SAY cadminno
      ***      @  1,COL()+2 SAY "Space or First Character"
      ***       READ
      /*
      ***       IF PressedEsc()
      ***          RETURN NIL
      ***       ENDIF
      ***   ENDDO
      IF SUBSTR( mpartnum,1, 1 ) != SPACE( 1 )   // Input to Partnum
         aPart_ := {}
         nrecno := 0
         SEEK mpartnum
         mpart  := TRIM( mpartnum )
         FOR x = 1 TO LEN( mpart ) 
            SEEK SUBSTR( mpart,1, x )      // Tracer
         NEXT
         DO WHILE Part->Partnum = mpart .AND. Part->( !EOF() )
             IF Part->Catno != ccatno
                SKIP ALIAS Part
                LOOP
             ENDIF
             AADD( aPart_,Part->Partnum;
                 +"  "+Part->Desc;
                 +" "+STR( Part->Wholesale, 8 ); 
                 +"               "+STR( RECNO(),6 ) ) 
            SKIP ALIAS Part
         ENDDO                  // Part
         IF !EMPTY( aPart_ )
            SCROLL( 3,0, 24,80 ) 
            DISPBOX( 3, 1,24,79, 2 )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE(  4, 3, 23,77, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            IF PressedEsc()
               RETURN NIL
            ENDIF
            mpartnum := Partnum
            DO CASE
               CASE csel == "csel0"
                  cnote := Part->Partnum
               CASE csel == "csel1"
                  cwarranty := Part->Partnum
               CASE csel == "csel2"
                  cdiag1 := Part->Partnum
               CASE csel == "csel3"
                  cdiag2 := Part->Partnum
               CASE csel == "csel4"
                  cdiag3 := Part->Partnum
               CASE csel == "csel5"
                  cdiag4 := Part->Partnum
               CASE csel == "csel6"
                  ctreat1 := Part->Partnum
               CASE csel == "csel7"
                  ctreat2 := Part->Partnum
               CASE csel == "csel8"
                  ctreat3 := Part->Partnum
               CASE csel == "csel9"
                  ctreat4 := Part->Partnum
            ENDCASE
         ENDIF
      ENDIF                        // Empty
      SCROLL( 14, 1, 24,80 )
      DISPBOX( 14, 1, 24,79, 2 )
      ***   @  16, 4 SAY mpartnum+"  "+TRIM( Part->Desc )+"   "+cadminno
      mcontinue := ApGetY( "Correct Selection "+ccatno )
      */
      mcontinue = "N"
      IF mcontinue = "N"
         nquoted := 0
         aPart_  :={}
         nrecno  := 0
         SELECT Part
         GOTO TOP
         ***   @ 0,10 SAY "Village "+cadminno
         DO WHILE Part->( !EOF() )
            IF Part->Catno != ccatno
               SKIP ALIAS Part
               LOOP
            ENDIF  
            AADD( aPart_,Part->Partnum;
                        +" "+Part->Desc;
                        +"                   "+STR( RECNO(),6 ) )
            SKIP ALIAS Part
         ENDDO                        // Part EOF
         IF !EMPTY( aPart_ )
            SCROLL()
            DISPBOX( 0, 1,24,79, 2 )
            @ 0, 4 SAY "         ---- "+ccatno+"   "+cadminno+"   ----    " COLOR "BG+"
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE(  1, 3, 23,77, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            IF PressedEsc()
               RETURN NIL
            ENDIF
            DO CASE
               CASE csel = "csel0"
                  cnote := Part->Partnum
               CASE csel = "csel1"
                  cwarranty := Part->Partnum
               CASE csel = "csel2"
                  cdiag1 := Part->Partnum
               CASE csel = "csel3"
                  cdiag2 := Part->Partnum
               CASE csel = "csel4"
                  cdiag3 := Part->Partnum
               CASE csel = "csel5"
                  cdiag4 := Part->Partnum
               CASE csel = "csel6"
                  ctreat1 := Part->Partnum
               CASE csel = "csel7"
                  ctreat2 := Part->Partnum
               CASE csel = "csel8"
                  ctreat3 := Part->Partnum
               CASE csel = "csel9"
                  ctreat4 := Part->Partnum
            ENDCASE
         ENDIF                        // Empty
         SCROLL( 14, 1, 24,80 )
         DISPBOX( 14, 1, 24,79, 2 )
         @  16, 4 SAY Part->Partnum+"  "+TRIM( Part->Desc )+"   "+cadminno
         mcontinue := ApGetY( "Is This Correct "+ccatno )
         IF mcontinue = "N"
            mok := "N"
            DO WHILE mok == "N"
               mdate    := DTOS( DATE() )
               mdatesub := SUBSTR( mdate, 7, 2 )+SUBSTR( mdate, 5, 2);
                          +SUBSTR( mdate, 3, 2 )
               SCROLL(  18, 0, 24,80 )
               DISPBOX( 18, 0, 24,79, 2 )
               ***             @ 16,12 SAY "Catalogue As Selected" COLOR "G+"
               mpartnum   := SPACE( 16 )
               cdesc      := SPACE( 40 )
               nwholesale := 0 
               @ 20,10 SAY "New "+ccatno GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
               @ 22,15 SAY "Description" GET cdesc    PICTURE "@X"  
               IF ccatno = TRIM( Message->Catno2 )
                  @ 23,15 SAY "Sell Amount" GET nwholesale PICTURE "99999999" 
               ENDIF
               READ
               IF PressedEsc()
                  mpartnum := SPACE( 16 )
                  RETURN mpartnum
               ENDIF
               IF mpartnum = SPACE( 16 )
                  LOOP
               ENDIF
               SELECT Part
               SET ORDER TO 1
               SEEK mpartnum
               DO WHILE FOUND()
                  @  20,10 SAY "New Partnum" GET mpartnum PICTURE "!!!!!!!!!!!!!!!!"
                  @  20,43 SAY "-- Already Used Try again --"
                  READ
                  IF PressedEsc()
                     mpartnum := SPACE( 16 )
                     RETURN mpartnum
                  ENDIF
                  SEEK mpartnum
               ENDDO
               ApFLock( 3 )
               APPEND BLANK
               Part->Partnum   := mpartnum
               Part->Desc      := cdesc
               Part->Codeno    := Control->U_Codeno
               Part->BoughtOut := "N"
               Part->Date      := DATE() 
               Part->Wholesale := nwholesale
               Part->Catno     := ccatno
               UNLOCK
               DO CASE
                  CASE csel = "csel0"
                     cnote := Part->Partnum
                  CASE csel = "csel1"
                     cwarranty := Part->Partnum
                  CASE csel = "csel2"
                     cdiag1 := Part->Partnum
                  CASE csel = "csel3"
                     cdiag2 := Part->Partnum
                  CASE csel = "csel4"
                     cdiag3 := Part->Partnum
                  CASE csel = "csel5"
                     cdiag4 := Part->Partnum
                  CASE csel = "csel6"
                     ctreat1 := Part->Partnum
                  CASE csel = "csel7"
                     ctreat2 := Part->Partnum
                  CASE csel = "csel8"
                     ctreat3 := Part->Partnum
                  CASE csel = "csel9"
                     ctreat4 := Part->Partnum
               ENDCASE
               mok := "Y"
            ENDDO                           // mok
         ENDIF     //   mcontinue 2 

      ENDIF                           // Partnum = Char 
      nqtypart  := 1
      nwholpart:= nqty := 0
      ccost     := "N"
      *** IF ccatno = TRIM( Message->Catno2 )  
      nwholpart := Part->Wholesale
      @ 20, 6      SAY "At Least 1"  GET nqtypart PICTURE "9999999"
      @ 20,COL()+2 SAY "Item Cost"   GET nwholpart PICTURE "9999999"
      @ 20,COL()+2 SAY "Change Cost" GET ccost VALID( ccost $"NY" ) PICTURE "!"
       READ
       ApFLock( 3 )
      Part->UTD  += nqtypart
      Part->Date := DATE() 
      IF ccost = "Y"
         Part->Wholesale := nwholpart
      ENDIF 
      UNLOCK
      nqtyused := nqtypart
      nqtypart := nwholpart*nqtypart 
      SELECT Admin
      @ 21, 7 SAY ccatno+" Item Cost x Qty" GET nqtypart PICTURE "9999999"   
       READ
      nqty := nqty+nqtypart 
      SCROLL( 20, 3, 21,76 )
      SELECT Hist
       ApFLock( 3 )
      APPEND BLANK
      Hist->Partnum   := Part->Partnum
      Hist->Qty       := nqtyused
      Hist->Codeno    := Name->Codeno
      Hist->PDate     := DATE() 
      Hist->Wholesale := nwholpart
      Hist->Amount    := nqtypart
      Hist->U_Codeno  := cadminno
      Hist->Invno     := cadminno             // Village 
      Hist->Cost      := nwholpart
      UNLOCK
      mcorrect := "N"
   ENDDO                     // mcorrect
   SELECT Admin
   ApRlock( 3 )
   Admin->Warranty := cwarranty
   Admin->Accepted := naccepted
   Admin->Quoted   := nquoted
   Admin->Diag1    := cdiag1
   Admin->Diag2    := cdiag2
   Admin->Diag3    := cdiag3
   Admin->Diag4    := cdiag4
   Admin->Treat1   := ctreat1
   Admin->Treat2   := ctreat2
   Admin->Treat3   := ctreat3
   Admin->Treat4   := ctreat4
   Admin->Name     := cname
   UNLOCK
   RETURN NIL
   ****----- End of AdminPart()

   ****---------------------------------------------------------------------------

FUNCTION Admin()

   cadminno := SPACE( 8 )
   manother := "Y"
   DO WHILE manother == "Y"
      SCROLL()
      coperno  := SPACE( 8 ) 
      nselect  := 1
      DISPBOX(  0, 1, 24,64, 2 )
      ***   DISPBOX(  0,44, 24,64, 2 )
      ***   @  2,45 SAY "Select Group" 
      ***   @  4,45 SAY "Select a Catalog" 
      DISPBOX(  0,65, 24,79, 2 )
    ***  @  1,66 SAY "Selections"
      @  2,66 SAY TRIM( Message->Catno1 )
      @  3,66 SAY TRIM( Message->Catno2 )
      @  4,70 SAY Message->Operno01  
      @  5,70 SAY Message->Operno02  
      @  6,70 SAY Message->Operno03
      @  7,70 SAY Message->Operno04      
      @  8,70 SAY Message->Operno05
      @  9,70 SAY Message->Operno06
      @ 10,70 SAY Message->Operno07
      @ 11,70 SAY Message->Operno08
      @ 12,70 SAY Message->Operno09
      @ 13,70 SAY Message->Operno10
      @ 14,70 SAY Message->Operno11
      @ 15,70 SAY Message->Operno12
      @ 16,70 SAY Message->Operno13
      @ 17,70 SAY Message->Operno14
      @ 18,70 SAY Message->Operno15
      @ 19,70 SAY Message->Operno16
      @ 20,70 SAY Message->Operno17
      @ 21,70 SAY Message->Operno18
      @  2, 6 SAY " -- Name Records -- "
      @  5, 6 PROMPT "1. Add Record        "
      @  7, 6 PROMPT "2. Edit/Delete Record"
      @  9, 6 PROMPT "3. Print Records     "
      @ 10, 6 PROMPT "4. Print 1 "+TRIM( Message->Catno1 )
      @ 11, 6 PROMPT "5. Print 2 "+TRIM( Message->Catno2 )
      @ 12, 6 PROMPT "6. Print Name        "
      @ 15, 6 PROMPT "7. Selections "+TRIM( Message->Catno1 )+" "+TRIM( Message->Catno2 )
      @ 17, 6 PROMPT "8. Name History      "
      @ 18, 6 PROMPT "9. Part History      "
      @ 19, 6 PROMPT "History Edit         " 
      @ 20, 6 PROMPT "Print Items Used     "
      @ 22, 6 PROMPT "To Exit              "
      IF Message->Catno1 = SPACE( 12 )
         @ 23, 6 SAY "Must Select a Catalogue"  COLOR "RG+"
      ENDIF
      IF Message->Catno2 = SPACE( 12 )
         @ 23, 6 SAY "Must Select a Catalogue"  COLOR "RG+"
      ENDIF

      MENU TO nselect
      DO CASE
         CASE nselect = 12 .OR. PressedEsc()
              RETURN NIL
         CASE nselect == 1                 // Add Record Admin   
            SCROLL()
      DISPBOX(  0,65, 24,79, 2 )
    ***  @  1,66 SAY "Selections"
      @  2,66 SAY TRIM( Message->Catno1 )
      @  3,66 SAY TRIM( Message->Catno2 )
      @  4,70 SAY Message->Operno01  
      @  5,70 SAY Message->Operno02  
      @  6,70 SAY Message->Operno03
      @  7,70 SAY Message->Operno04      
      @  8,70 SAY Message->Operno05
      @  9,70 SAY Message->Operno06
      @ 10,70 SAY Message->Operno07
      @ 11,70 SAY Message->Operno08
      @ 12,70 SAY Message->Operno09
      @ 13,70 SAY Message->Operno10
      @ 14,70 SAY Message->Operno11
      @ 15,70 SAY Message->Operno12
      @ 16,70 SAY Message->Operno13
      @ 17,70 SAY Message->Operno14
      @ 18,70 SAY Message->Operno15
      @ 19,70 SAY Message->Operno16
      @ 20,70 SAY Message->Operno17
      @ 21,70 SAY Message->Operno18
      DISPBOX( 10, 1, 16,60, 2 )
            @ 12,12 SAY "Selection "+cadminno 
            cblank := "XX"
            IF cadminno = SPACE( 8 )
               cblank := "  "
             ELSE
               @ 14,12      SAY "Blank for New Selection"
               @ 14,COL()+2 GET cblank PICTURE "@!"
                READ 
            ENDIF
         IF cblank = "  "   
            SCROLL()
            DISPBOX(  2,68, 24,79, 2 )
            mchoice := 1
            @  4,70 PROMPT Message->Operno01  
            @  5,70 PROMPT Message->Operno02  
            @  6,70 PROMPT Message->Operno03
            @  7,70 PROMPT Message->Operno04      
            @  8,70 PROMPT Message->Operno05
            @  9,70 PROMPT Message->Operno06
            @ 10,70 PROMPT Message->Operno07
            @ 11,70 PROMPT Message->Operno08
            @ 12,70 PROMPT Message->Operno09
            @ 13,70 PROMPT Message->Operno10
            @ 14,70 PROMPT Message->Operno11
            @ 15,70 PROMPT Message->Operno12
            @ 16,70 PROMPT Message->Operno13
            @ 17,70 PROMPT Message->Operno14
            @ 18,70 PROMPT Message->Operno15
            @ 19,70 PROMPT Message->Operno16
            @ 20,70 PROMPT Message->Operno17
            @ 21,70 PROMPT Message->Operno18
            MENU TO mchoice
            DO CASE
               CASE mchoice == 1
                  coperno := Message->Operno01
               CASE mchoice == 2
                  coperno := Message->Operno02
               CASE mchoice == 3
                  coperno := Message->Operno03
               CASE mchoice == 4
                  coperno := Message->Operno04
               CASE mchoice == 5
                  coperno := Message->Operno05
               CASE mchoice == 6
                  coperno := Message->Operno06
               CASE mchoice == 7
                  coperno := Message->Operno07
               CASE mchoice == 8
                  coperno := Message->Operno08
               CASE mchoice == 9
                  coperno := Message->Operno09
               CASE mchoice == 10
                  coperno := Message->Operno10
               CASE mchoice == 11
                  coperno := Message->Operno11
               CASE mchoice == 12
                  coperno := Message->Operno12
               CASE mchoice == 13
                  coperno := Message->Operno13
               CASE mchoice == 14
                  coperno := Message->Operno14
               CASE mchoice == 15
                  coperno := Message->Operno15
               CASE mchoice == 16
                  coperno := Message->Operno16
               CASE mchoice == 17
                  coperno := Message->Operno17
               CASE mchoice == 18
                  coperno := Message->Operno18
             ENDCASE
             cadminno := coperno
          ENDIF         // Group
          ccodeno  := SPACE( 8 )
          cabc     := SPACE( 6 )
          cfamname:= ccalled := SPACE( 16 ) 
          cdesc    := SPACE( 30 )
          ddate    := DATE()
          nrate    := 0
          naccepted := 0
          csex     := "M"
          nqty     := 0
          SCROLL()
          DISPBOX(  1, 1, 24,79, 2 )
      ****       mcodeno := SUBSTR( cfamname, 1, 8 )
          mcont := "N"
     ***     IF cfamname = SPACE( 16 )
             mcodeno := SPACE( 8 ) 
              NameRank( @mcodeno )
             mcodeno  := Name->Codeno
     ***        cfamname := SUBSTR( Name->Name, 1,16 ) 
             SCROLL()
             @  3,20      SAY "   ---  Group "+cadminno+"   ---  " COLOR "BG+"
             @ 16,10 SAY TRIM( Name->Name )+"  "+TRIM( Name->Desc )
             mcont := ApGetY( "Correct Name "+mcodeno )
             IF mcont = "N"
                mcodeno := SPACE( 8 )
                @  7, 6      SAY "Name"   GET cfamname PICTURE "@!"
                @  7,COL()+2 SAY "Called" GET ccalled  PICTURE "@!"
                 READ
             ENDIF
      IF mcodeno = SPACE( 8 )
         mcodeno := SUBSTR( cfamname, 1, 4 )+SUBSTR( ccalled, 1, 4 )
         SELECT Name
         IF mcodeno != SPACE( 8 )
            SEEK mcodeno
            DO WHILE FOUND()
               @ 22,10 GET mcodeno PICTURE "@!"
               @ 22,25 SAY "Already Exists"
               @ 23,25 SAY "Put number at end if similar Name ie LAMACHO1"
                READ
               SEEK mcodeno
            ENDDO                          // FOUND()
         ENDIF               // mcodeno "   "
          ApFLock( 3 )
         APPEND BLANK
         Name->Codeno := mcodeno
         Name->Name   := TRIM( cfamname )+" "+TRIM( ccalled )+"    "+STR( Control->Quotno, 4 ) 
         Name->Add1   := cadminno
         Name->Datein := DATE()
         Name->Sale   := "PATI" 
         UNLOCK
      ENDIF                         // codeno space
      cnote:= cname := SPACE( 16 ) 
      nquoted:= ntime := 0
      aPart_  :={}
      nrecno  := 0
          csex  := SUBSTR( Name->Desc,20, 1 )
          nrate := VAL( SUBSTR( Name->Desc, 5, 2 ) )
          ccost := "N"
          IF nrate = 0 
             ntime := VAL( SUBSTR( Name->Desc,12, 2 ) ) 
          ENDIF
          SCROLL()
          DISPBOX(  0, 1, 24,79, 2 )
          @  0,12      SAY "  Selection "+cadminno+" "+mcodeno COLOR "BG+"
          @  2, 6      SAY mcodeno+" "+cfamname+" "+ccalled       COLOR "G+" 
          @  4,15      SAY TRIM( Name->Desc )+"  "+TRIM( Name->Name )
     ***     @  6, 6      SAY mcodeno+" Age" GET nrate    PICTURE "99"
     ***     @  6,COL()+2 SAY "0  If Baby" 
           READ
      ***       IF nrate = 0
      ***           @  8, 6  SAY "Baby Months" GET ntime PICTURE "99"
      ***       ENDIF
        ***  @ 10, 6      SAY "Male-Female" GET csex VALID( csex $"FM" ) PICTURE "!"
          @ 10, 6      SAY "Date" GET ddate     PICTURE "99/99/9999"
          @ 10,COL()+2 SAY "Add Note" GET cname PICTURE "@!"
           READ
          SELECT Name
           ApRLock( 3 )
      ***       Name->Desc := "Age "+STR( nrate, 2 )+" Baby "+STR( ntime, 2 );
      ***                     +" Sex "+csex+"  "+cadminno
             Name->Desc := +cadminno
          UNLOCK
          SELECT Admin
          cnote:= cwarranty := SPACE( 16 )
          cdiag1:= cdiag2:= cdiag3:= cdiag4 := SPACE( 16 )       
          ctreat1:= ctreat2:= ctreat3:= ctreat4 := SPACE( 16 )
          csel0:= csel1:= csel2:= csel3:= csel4 := "     "       
          csel5:= csel6:= csel7:= csel8:= csel9 := "     "       
          ccatno := SPACE( 12 )
          ncount := 0
          DO WHILE ncount <= 9
             SCROLL()
             DISPBOX(  0, 1, 24,79, 2 )
             @  0,12      SAY "  Selection "+cadminno+" "+mcodeno COLOR "BG+"
             @  2, 6      SAY mcodeno+" "+cfamname+" "+ccalled       COLOR "G+" 
         ***    @  4,15      SAY TRIM( Name->Desc )+"  "+TRIM( Name->Name )
             @  4,15      SAY Name->Name
          ***   @  6, 6      SAY mcodeno+" Age"
         ***    @  6,COL()+1 SAY Admin->Rate PICTURE "99" 
         ***    IF Admin->Rate = 0
         ***        @  8, 6      SAY "Baby Months"
         ***        @  8,COL()+1 SAY Admin->Time PICTURE "99"
         ***    ENDIF
         ***    @ 10, 6      SAY "Male-Female "+csex
             @ 10, 6      SAY "Date"
             @ 10,COL()+1 SAY ddate PICTURE "99/99/9999"
             @ 10,COL()+2 SAY "Note "+cname
             @ 12, 6      SAY TRIM( cnote )  COLOR "G+"
             @ 12,COL()+2 SAY TRIM( cwarranty ) COLOR "G+"
             @ 12,COL()+2 SAY TRIM( cdiag1 ) COLOR "G+"
             @ 12,COL()+2 SAY TRIM( cdiag2 ) COLOR "G+"
             @ 14, 6      SAY TRIM( cdiag3 ) COLOR "G+"
             @ 14,COL()+2 SAY TRIM( cdiag4 ) COLOR "G+"
             @ 14,COL()+2 SAY TRIM( ctreat1 ) COLOR "G+"
             @ 14,COL()+2 SAY TRIM( ctreat2 ) COLOR "G+"
             @ 16, 6      SAY TRIM( ctreat3 ) COLOR "G+"
             @ 16,COL()+2 SAY TRIM( ctreat4 ) COLOR "G+"
             msel := 1
             @ 18, 6 PROMPT "1 "+TRIM( Message->Catno1 )
             @ 19, 6 PROMPT "2 "+TRIM( Message->Catno2 )
             @ 20, 6 PROMPT "3 No More Selection " 
             @ 22, 6      SAY "First Select "+Message->Catno1
             @ 22,COL()+1 SAY  ncount PICTURE "99" COLOR "G+"
             @ 22,COL()+2 SAY "Costs" COLOR "G+"   // +TRIM( Message->Catno2 ) COLOR "G+"
             @ 22,COL()+1 SAY nqty PICTURE "$9,999,999" COLOR "G+"
             @ 24,25      SAY "   Ten Selections available    " COLOR "BG+"
             MENU TO msel
             DO CASE
                CASE msel == 1
                   ccatno := Message->Catno1      //"DIAGNOSIS   "
                CASE msel == 2
                   ccatno := Message->Catno2      // "TREATMENT   "
                CASE msel == 3
                    ncount := 14
             ENDCASE
             DO CASE
               CASE ncount = 0
                  csel := "csel0" 
                CASE ncount = 1
                  csel := "csel1" 
                CASE ncount = 2
                  csel := "csel2" 
                CASE ncount = 3
                  csel := "csel3" 
                CASE ncount = 4
                  csel := "csel4" 
                CASE ncount = 5
                  csel := "csel5" 
                CASE ncount = 6
                  csel := "csel6" 
                CASE ncount = 7
                  csel := "csel7" 
                CASE ncount = 8
                  csel := "csel8" 
                CASE ncount = 9
                  csel := "csel9" 
           ENDCASE
           IF ncount <= 10
               AdminPart( ccatno, csel )
           ENDIF 
           ncount++
      ENDDO
      SELECT Control
       ApRLock( 3 )
      Control->Quotno := Control->Quotno+1
      UNLOCK
          SELECT Admin
           ApFlock( 3 )
          APPEND BLANK
          Admin->Codeno   := mcodeno
          IF cfamname = "         "
             Admin->Famname  := mcodeno
            ELSE
             Admin->Famname  := cfamname
          ENDIF
          Admin->Called   := ccalled
          Admin->Adminno  := cadminno
          Admin->Desc     := cdesc
          Admin->Date     := ddate
          Admin->Rate     := nrate
          Admin->Time     := ntime
          Admin->Sex      := csex
          Admin->Note     := cnote
          Admin->Warranty := cwarranty
          Admin->Quoted   := nqty 
          Admin->Accepted := naccepted
          Admin->Diag1    := cdiag1
          Admin->Diag2    := cdiag2
          Admin->Diag3    := cdiag3
          Admin->Diag4    := cdiag4
          Admin->Treat1   := ctreat1
          Admin->Treat2   := ctreat2
          Admin->Treat3   := ctreat3
          Admin->Treat4   := ctreat4
          Admin->Name     := cname
          UNLOCK
          manother := "Y"
          LOOP

         CASE nselect == 2                 // Edit-Delete Admin

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
    ***      SCROLL()
    ***         cadminno := Admin->Adminno
             cdesc    := Admin->Desc
            cedit := ApGetN( "Edit by Group" )
         IF cedit = "Y"
    ***        SCROLL(  12, 0, 18,80 )
    ***        DISPBOX( 12, 1, 18,79, 2 )
    ***        @ 14,14 SAY " Village "+cadminno
            cblank := "  "
    ***        @ 16,14      SAY "Blank to Change Village"
    ***        @ 16,COL()+2 GET cblank PICTURE "@!"
    ***         READ 
         IF cblank = "  "   
            mchoice := 1
            SCROLL( 0,65,24,80 )
            DISPBOX(  0,68, 24,79, 2 )
            @  5,70 PROMPT Message->Operno01  
            @  6,70 PROMPT Message->Operno02  
            @  7,70 PROMPT Message->Operno03
            @  8,70 PROMPT Message->Operno04      
            @  9,70 PROMPT Message->Operno05
            @ 10,70 PROMPT Message->Operno06
            @ 11,70 PROMPT Message->Operno07
            @ 12,70 PROMPT Message->Operno08
            @ 13,70 PROMPT Message->Operno09
            @ 14,70 PROMPT Message->Operno10
            @ 15,70 PROMPT Message->Operno11
            @ 16,70 PROMPT Message->Operno12
            @ 17,70 PROMPT Message->Operno13
            @ 18,70 PROMPT Message->Operno14
            @ 19,70 PROMPT Message->Operno15
            @ 20,70 PROMPT Message->Operno16
            @ 21,70 PROMPT Message->Operno17
            @ 22,70 PROMPT Message->Operno18
            MENU TO mchoice
            DO CASE
               CASE mchoice == 1
                  coperno := Message->Operno01
               CASE mchoice == 2
                  coperno := Message->Operno02
               CASE mchoice == 3
                  coperno := Message->Operno03
               CASE mchoice == 4
                  coperno := Message->Operno04
               CASE mchoice == 5
                  coperno := Message->Operno05
               CASE mchoice == 6
                  coperno := Message->Operno06
               CASE mchoice == 7
                  coperno := Message->Operno07
               CASE mchoice == 8
                  coperno := Message->Operno08
               CASE mchoice == 9
                  coperno := Message->Operno09
               CASE mchoice == 10
                  coperno := Message->Operno10
               CASE mchoice == 11
                  coperno := Message->Operno11
               CASE mchoice == 12
                  coperno := Message->Operno12
               CASE mchoice == 13
                  coperno := Message->Operno13
               CASE mchoice == 14
                  coperno := Message->Operno14
               CASE mchoice == 15
                  coperno := Message->Operno15
               CASE mchoice == 16
                  coperno := Message->Operno16
               CASE mchoice == 17
                  coperno := Message->Operno17
               CASE mchoice == 18
                  coperno := Message->Operno18
             ENDCASE
             cadminno := coperno
           ENDIF           // Space
        ENDIF             // cedit
      SCROLL()
       dstmm    := DATE()-5
       dendmm   := DATE()
       DISPBOX( 3, 1, 18,79, 2 )
       @  8,10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
       @ 10,10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
         READ 
      aPart_:={}
      nrecno := 0
      SELECT Admin
      GOTO TOP
      DO WHILE Admin->( !EOF() )
         IF Admin->Date < dstmm
            SKIP ALIAS Admin
            LOOP
         ENDIF
         IF Admin->Date > dendmm
            SKIP ALIAS Admin
            LOOP
         ENDIF
         IF cedit = "Y" 
            IF cadminno != SPACE( 8 )  
               IF Admin->Adminno != cadminno
                  SKIP ALIAS Admin
                  LOOP
               ENDIF
            ENDIF
         ENDIF             // cedit
         AADD( aPart_,Admin->Adminno;
                     +" "+Admin->Codeno;
                     +" "+Admin->Note;
                     +" "+Admin->Warranty;
                     +" "+STR( Admin->Quoted, 8 );
                     +" "+Admin->Sex;
                     +" "+STR( Admin->Rate, 3 );
                     +" "+STR( Admin->Time, 3 );
                     +"               "+STR( RECNO(),6 ) )
         SKIP ALIAS Admin
      ENDDO                        // Admin EOF
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX( 0, 1,24,79, 2 )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  1, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         SCROLL(  15, 0, 24,80 )
         DISPBOX( 15, 1, 20,79, 2 )
         @ 16,10      SAY Admin->Adminno   // COLOR "BG+" 
         @ 16,COL()+2 SAY Admin->Codeno    // COLOR "BG+"
         @ 16,COL()+2 SAY Admin->Famname   // COLOR "BG+"
         @ 16,COL()+2 SAY Admin->Called    // COLOR "BG+"
         @ 17,10      SAY Admin->Note      // COLOR "BG+"
         @ 17,COL()+2 SAY Admin->Warranty  // COLOR "BG+"
         @ 19,10      SAY STR( Admin->Rate, 3 )+"  "+STR( Admin->Time, 3 )
         IF PressedEsc()
            RETURN NIL
         ENDIF
          csel0:= csel1:= csel2:= csel3:= csel4 := "     "       
          csel5:= csel6:= csel7:= csel8:= csel9 := "     "       
          cadminno  := Admin->Adminno 
          ccodeno   := Admin->Codeno
          cfamname  := Admin->Famname
          ccalled   := Admin->Called 
          cdesc     := Admin->Desc
          ddate     := Admin->Date
          nrate     := Admin->Rate
          ntime     := Admin->Time
          csex      := Admin->Sex
          naccepted := Admin->Accepted 
          cname     := Admin->Name
          nquoted   := Admin->Quoted
          ncount    := 10   
          cnote     := Admin->Note
          cwarranty := Admin->Warranty   
          nquoted   := Admin->Quoted
          cdiag1    := Admin->Diag1
          cdiag2    := Admin->Diag2
          cdiag3    := Admin->Diag3
          cdiag4    := Admin->Diag4
          ctreat1   := Admin->Treat1
          ctreat2   := Admin->Treat2
          ctreat3   := Admin->Treat3
          ctreat4   := Admin->Treat4
          csel := "XXXXX"
          SCROLL()
          DISPBOX( 0, 1, 23,79, 2 )
          @  1, 6      SAY "Group "+cadminno
          @  3, 6      SAY "Date"      GET ddate     PICTURE "99/99/9999"
          @  4, 6      SAY Admin->Codeno
          @  4,COL()+2 SAY "Name"      GET cfamname  PICTURE "@!"
          @  4,COL()+2 SAY "Called"    GET ccalled   PICTURE "@!"
      ***       @  5, 6      SAY "Age"    GET nrate     PICTURE "99"
      ***       @  5,COL()+2 SAY "Months" GET ntime     PICTURE "99"
      ***       @  5,COL()+2 SAY "Sex"    GET csex VALID( csex $"FM" ) PICTURE "!"
          @  6, 6      SAY "Note"      GET cname     PICTURE "@!"
          @  6,COL()+2 SAY "Price"     GET nquoted   PICTURE "9999999"  
          @  8,25      SAY "BLANK the following to delete" COLOR "BG+" 
          @  9, 6      SAY cnote       GET cnote     PICTURE "@!"
          @ 10, 6      SAY cwarranty   GET cwarranty PICTURE "@!"   
          @ 11, 6      SAY cdiag1      GET cdiag1    PICTURE "@!"  
          @ 12, 6      SAY cdiag2      GET cdiag2    PICTURE "@!"  
          @ 13, 6      SAY cdiag3      GET cdiag3    PICTURE "@!"  
          @ 14, 6      SAY cdiag4      GET cdiag4    PICTURE "@!"
          @ 15, 6      SAY ctreat1     GET ctreat1   PICTURE "@!" 
          @ 16, 6      SAY ctreat2     GET ctreat2   PICTURE "@!"  
          @ 17, 6      SAY ctreat3     GET ctreat3   PICTURE "@!"  
          @ 18, 6      SAY ctreat4     GET ctreat4   PICTURE "@!"  
           READ
          SELECT Admin
           ApRlock( 3 )
          Admin->Codeno   := ccodeno
          Admin->Famname  := cfamname
          Admin->Called   := ccalled
          Admin->Adminno  := cadminno
          Admin->Desc     := cdesc
          Admin->Date     := ddate
          Admin->Rate     := nrate
          Admin->Time     := ntime
          Admin->Sex      := csex
          Admin->Name     := cname
          Admin->Note     := cnote
          Admin->Warranty := cwarranty  
          Admin->Diag1    := cdiag1
          Admin->Diag2    := cdiag2
          Admin->Diag3    := cdiag3
          Admin->Diag4    := cdiag4
          Admin->Treat1   := ctreat1
          Admin->Treat2   := ctreat2
          Admin->Treat3   := ctreat3
          Admin->Treat4   := ctreat4
          UNLOCK
          SELECT Name
           ApRLock( 3 )
      ***       Name->Desc := "Age "+STR( nrate, 2 )+" Baby "+STR( ntime, 2 );
      ***                     +" Sex "+csex+"  "+cadminno
          Name->Desc := cadminno
          UNLOCK

          cedit     := "Y"
          DO WHILE cedit = "Y"
             cedit := "N"
          cedit := ApGetN( "Edit Selection" )
          IF cedit = "Y"
              SCROLL( 8, 2, 23,78 )
      ***           DISPBOX( 0, 1, 24,79, 2 )
              msel := 1 
              @  9, 6  PROMPT cnote
              @ 10, 6  PROMPT cwarranty   
              @ 11, 6  PROMPT cdiag1  
              @ 12, 6  PROMPT cdiag2  
              @ 13, 6  PROMPT cdiag3   
              @ 14, 6  PROMPT cdiag4
              @ 15, 6  PROMPT ctreat1 
              @ 16, 6  PROMPT ctreat2  
              @ 17, 6  PROMPT ctreat3  
              @ 18, 6  PROMPT ctreat4   
              MENU TO msel
              ncount := 0
              DO CASE
                 CASE msel == 1
                   csel := csel0
                   ncount := 0
                 CASE msel == 2
                   csel := csel1
                   ncount := 1
                 CASE msel == 3
                   csel := csel2
                   ncount := 2
                 CASE msel == 4
                   csel := csel3
                   ncount := 3
                 CASE msel == 5
                   csel := csel4
                   ncount := 4
                 CASE msel == 6
                   csel := csel5
                   ncount := 5
                 CASE msel == 7
                   csel := csel6
                   ncount := 6
                 CASE msel == 8
                   csel := csel7
                   ncount := 7
                 CASE msel == 9
                   csel := csel8
                   ncount := 8
                 CASE msel == 10
                   csel := csel9
                   ncount := 9
                ENDCASE
                 AdminEdit( ncount, csel )
             ENDIF
       ENDDO                   // Edit
            SCROLL(  21, 0, 24,80  )
            cstring := "Do You Want to Delete Admin"      // TRIM( Message->Suredel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF mok == "Y"
               SELECT Admin
                 ApFLock( 3 )
               DELETE
               UNLOCK
            ENDIF 
         ELSE
         @ 12,10 SAY "No Entries for this Group "+cadminno
      ENDIF                        // Empty
            mcontinue := ApGetN( "Another Edit" )
     ENDDO
     LOOP

      CASE nselect == 3        // Print

       cadminno := SPACE( 8 )
       dstmm    := DATE()-10
       dendmm   := DATE()
       SCROLL()
       DISPBOX( 0, 1, 2,79, 2 )
       SCROLL(  3, 0, 24,80 )
       DISPBOX( 3, 1, 18,79, 2 )
       @  8,10 SAY Message->Frdate GET dstmm   PICTURE "99/99/9999"
       @ 10,10 SAY Message->Todate GET dendmm  PICTURE "99/99/9999"
            cblank := "XX"
            @ 12,10      GET cblank PICTURE "@!"
            @ 12,COL()+2 SAY "Blank for Group selection"
             READ 
         IF cblank = "  "   
            SCROLL( 0,68,24,80 )
            DISPBOX(  2,68, 24,79, 2 )
            mchoice := 1
            @  4,70 PROMPT Message->Operno01  
            @  5,70 PROMPT Message->Operno02  
            @  6,70 PROMPT Message->Operno03
            @  7,70 PROMPT Message->Operno04      
            @  8,70 PROMPT Message->Operno05
            @  9,70 PROMPT Message->Operno06
            @ 10,70 PROMPT Message->Operno07
            @ 11,70 PROMPT Message->Operno08
            @ 12,70 PROMPT Message->Operno09
            @ 13,70 PROMPT Message->Operno10
            @ 14,70 PROMPT Message->Operno11
            @ 15,70 PROMPT Message->Operno12
            @ 16,70 PROMPT Message->Operno13
            @ 17,70 PROMPT Message->Operno14
            @ 18,70 PROMPT Message->Operno15
            @ 19,70 PROMPT Message->Operno16
            @ 20,70 PROMPT Message->Operno17
            @ 21,70 PROMPT Message->Operno18
            MENU TO mchoice
            DO CASE
               CASE mchoice == 1
                  coperno := Message->Operno01
               CASE mchoice == 2
                  coperno := Message->Operno02
               CASE mchoice == 3
                  coperno := Message->Operno03
               CASE mchoice == 4
                  coperno := Message->Operno04
               CASE mchoice == 5
                  coperno := Message->Operno05
               CASE mchoice == 6
                  coperno := Message->Operno06
               CASE mchoice == 7
                  coperno := Message->Operno07
               CASE mchoice == 8
                  coperno := Message->Operno08
               CASE mchoice == 9
                  coperno := Message->Operno09
               CASE mchoice == 10
                  coperno := Message->Operno10
               CASE mchoice == 11
                  coperno := Message->Operno11
               CASE mchoice == 12
                  coperno := Message->Operno12
               CASE mchoice == 13
                  coperno := Message->Operno13
               CASE mchoice == 14
                  coperno := Message->Operno14
               CASE mchoice == 15
                  coperno := Message->Operno15
               CASE mchoice == 16
                  coperno := Message->Operno16
               CASE mchoice == 17
                  coperno := Message->Operno17
               CASE mchoice == 18
                  coperno := Message->Operno18
             ENDCASE
             cadminno := coperno
          ENDIF         // Group
      mwhere := "S"
      npl    := 52
      npn    := 1

        Printsel( mwhere, npl )                        // _LF_Init

      IF mwhere = "P"
         npl := 56
        ELSE
         npl := 22
      ENDIF 
      nl := 0
      IF mwhere = "P"
         @  0, 0 SAY Control->U_Name
         @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         @  2,10 SAY "From " +DTOC( dstmm ) 
         @  2,32 SAY "To "   +DTOC( dendmm ) 
         nl := 4
       ELSE
         SCROLL()
         @ 1, 6      SAY TRIM( Control->U_Name ) 
         @ 1,COL()+2 SAY "From " +DTOC( dstmm ) 
         @ 1,COL()+1 SAY "To "   +DTOC( dendmm )
         nl := 2
      ENDIF
             @ nl, 0 SAY "Ref #"
             @ nl, 9 SAY "Name"
      ***          @ nl,20 SAY "Age"
      ***          @ nl,24 SAY "Mth"
      ***          @ nl,29 SAY "Sex"
             @ nl,34 SAY Message->Catno1    // "Diagnosis"
             @ nl,53 SAY Message->Catno2    // "Treatment"
             @ nl,70 SAY "Date"
       nl++
       ntotal:= ntotalcost := 0
       nmale:= nfemale:= nchild:= nbaby := 0
       SELECT Admin
       GOTO TOP
       DO WHILE Admin->( !EOF() )
         IF cadminno != SPACE( 8 )  
            IF Admin->Adminno != cadminno
               SKIP ALIAS Admin
               LOOP
            ENDIF
         ENDIF
            IF Admin->Date < dstmm
               SKIP ALIAS Admin
               LOOP
            ENDIF
            IF Admin->Date > dendmm
               SKIP ALIAS Admin
               LOOP
            ENDIF
          IF nl > npl
             IF mwhere == "P"
                EJECT
               ELSE
                WAIT
                SCROLL()
             ENDIF
             nl := 0
             npn++ 
            IF mwhere = "P"
            @  nl, 0 SAY TRIM( Control->U_Name )
            @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ),5 )
         @  2,10 SAY "From " +DTOC( dstmm ) 
         @  2,32 SAY "To "   +DTOC( dendmm )
         nl := 4 
       ELSE
         SCROLL()
         @ 1, 6      SAY TRIM( Control->U_Name ) 
         @ 1,COL()+2 SAY "From " +DTOC( dstmm ) 
         @ 1,COL()+1 SAY "To "   +DTOC( dendmm )
         nl := 2
      ENDIF
             @ nl, 0 SAY "Ref #"
             @ nl,11 SAY "Name"
      ***       @ nl,20 SAY "Age"
      ***       @ nl,24 SAY "Mth"
      ***       @ nl,29 SAY "Sex"
             @ nl,34 SAY Message->Catno1      //  "Diagnosis"
             @ nl,53 SAY Message->Catno2      //  "Treatment"
             @ nl,70 SAY "Date"
             nl++
         ENDIF
         @ nl, 0 SAY Admin->Adminno
      ***      @ nl,10 SAY Admin->Abc
      ***      @ nl,10 SAY SUBSTR( Admin->Desc, 1,11 )
         @ nl,10 SAY Admin->Codeno
      *** no space  for this Admin->Called
         IF Admin->Rate > 0
            @ nl,22 SAY Admin->Rate PICTURE "99"
         ENDIF 
         IF Admin->Accepted > 0
            @ nl,26 SAY Admin->Accepted PICTURE "99"
         ENDIF
         @ nl,29 SAY Admin->Sex
         @ nl,32 SAY Admin->Note
         @ nl,50 SAY Admin->Warranty
         @ nl,67 SAY DTOC( Admin->Date )
         nl++
         cdiag := Admin->Diag1+Admin->Diag2+Admin->Diag3
         IF cdiag != "     "
            @ nl,32 SAY Admin->Diag1+" "+Admin->Diag2;
                        +" "+SUBSTR( Admin->Diag3, 1,13 )
            nl++
         ENDIF   
         ctreat := Admin->Diag4+Admin->Treat1+Admin->Treat2
         IF ctreat != "     "
            @ nl,32 SAY Admin->Diag4+" "+Admin->Treat1;
                       +" "+SUBSTR( Admin->Treat2, 1,13 )
            nl++
         ENDIF 
         ctreat1 := Admin->Treat3+Admin->Treat4
         IF ctreat != "     "
            @ nl,32 SAY Admin->Treat3+" "+Admin->Treat4
            nl++
         ENDIF 
         IF Admin->Name != "        "
            @ nl,16 SAY Admin->Name
            nl++
         ENDIF 
         IF Admin->Sex = "M"
            nmale++
         ENDIF
         IF Admin->Sex = "F"
            nfemale++
         ENDIF
         IF Admin->Rate > 0 .AND. Admin->Rate < 12
            nchild++
         ENDIF
         IF Admin->Accepted > 0
            nbaby++
         ENDIF
         ntotal++
         ntotalcost += Admin->Quoted
         SKIP ALIAS Admin
      ENDDO                      // Admin       
    /*
      nl+=2
      @ nl, 0 SAY "Male"
      @ nl, 5 SAY nmale PICTURE "999"
      @ nl,10 SAY "Female"
      @ nl,17 SAY nfemale PICTURE "999"
      @ nl,32 SAY "Child under 12"
      @ nl,48 SAY nchild PICTURE "999"
      @ nl,52 SAY "Baby"
      @ nl,57 SAY nbaby PICTURE "999"
   */
      nl+=2
      @ nl, 0 SAY "Number"   
      @ nl,18 SAY  ntotal PICTURE "999,999" 
      @ nl,28 SAY "From " +DTOC( dstmm ) 
      @ nl,45 SAY "To "   +DTOC( dendmm )
      @ nl,61 SAY "Cost"
      @ nl,66 SAY ntotalcost PICTURE "$9,999,999.99"  
      IF mwhere == "S"
         WAIT
         mwhere := "N" 
        ELSE
         EndPrint()
         SET MARGIN TO 0
      ENDIF
      LOOP

         CASE nselect == 7            // Edit Group Names
               SCROLL()
               ccatno1 := Message->Catno1
               ccatno2 := Message->Catno2
               ccatno  := SPACE( 12 )
               @  6,10      SAY "Selection 1" GET ccatno1 PICTURE "@!"
               @  6,COL()+2 SAY "Blank to select"
                READ   
               IF ccatno1 = SPACE( 12 )
                  Catarray()
                  ccatno1 := Cat->Catno 
                  SCROLL()
                  @  6,10 SAY ccatno1
               ENDIF
               @  8,10 SAY "Selection 2" GET ccatno2 PICTURE "@!"
               @  8,COL()+2 SAY "Blank to select"
                READ
               IF ccatno2 = SPACE( 12 )
                  Catarray()
                  ccatno2 := Cat->Catno 
               ENDIF
              SCROLL() 
              DISPBOX(  2,68, 24,79, 2 )
              @  4,10 SAY "Selected Catalogues"
              @  6,10 SAY ccatno1
              @  8,10 SAY ccatno2
              SELECT Message
               ApRLock( 3 )
              Message->Catno1 := ccatno1
              Message->Catno2 := ccatno2
              @  5,69 GET Message->Operno01 PICTURE "@!"
              @  6,69 GET Message->Operno02 PICTURE "@!"
              @  7,69 GET Message->Operno03 PICTURE "@!"
              @  8,69 GET Message->Operno04 PICTURE "@!"
              @  9,69 GET Message->Operno05 PICTURE "@!"
              @ 10,69 GET Message->Operno06 PICTURE "@!"
              @ 11,69 GET Message->Operno07 PICTURE "@!"
              @ 12,69 GET Message->Operno08 PICTURE "@!"
              @ 13,69 GET Message->Operno09 PICTURE "@!"
              @ 14,69 GET Message->Operno10 PICTURE "@!"
              @ 15,69 GET Message->Operno11 PICTURE "@!"
              @ 16,69 GET Message->Operno12 PICTURE "@!"
              @ 17,69 GET Message->Operno13 PICTURE "@!"
              @ 18,69 GET Message->Operno14 PICTURE "@!"
              @ 19,69 GET Message->Operno15 PICTURE "@!"
              @ 20,69 GET Message->Operno16 PICTURE "@!"
              @ 21,69 GET Message->Operno17 PICTURE "@!"
              @ 22,69 GET Message->Operno18 PICTURE "@!"
               READ
              UNLOCK
              SCROLL()
              LOOP

         CASE nselect == 4            // Print Diag
            AdminDiag()                // Above
           LOOP       
         CASE nselect == 5            // Print Treatments
            AdminTreat()               // XLF_EQu3
           LOOP       
         CASE nselect == 6            // Print Name
            AdminName()               // XLF_Deb1
           LOOP
         CASE nselect == 8            // Name Hist
            ChriName()                 // ZFE_Name
           LOOP       
         CASE nselect == 9            // Part Hist
            ChriPart()                 // ZFE_Name
           LOOP       
         CASE nselect == 10            // History Edit
            DebHistEd()                 // XLF_Deb
           LOOP       
         CASE nselect == 11            // Print Part->Utd
            PartRUTD()                // XF_PList
           LOOP       
      ENDCASE
   ENDDO               // Another

   RETURN NIL
   ****----- End of Admin()

   ****---------------------------------------------------------------------------

FUNCTION Mu_Oper( nc, ncl )

   DO WHILE .T.
      nselect := 0
      nc      := ncl*2
      SCROLL(  3,nc, 21,78 )
      DISPBOX( 4,nc, 21,nc+ncl )
      SCROLL(  3,nc+2, 5,nc+( ncl-2 ) )
      DISPBOX( 3,nc+2, 5,nc+( ncl-2 ) )
      cheading := "OPERATION MENU"
      @  4,nc+( ncl/2 )-( LEN( RTRIM( cheading ) )/2 );
                           SAY RTRIM( cheading )
      @  7,nc+2 PROMPT "1. OPERATION        "
      @  9,nc+2 PROMPT "2. PROCESS      Part"
      @ 11,nc+2 PROMPT "3. PROCESS      Edit"
      @ 12,nc+2 PROMPT "4. DRAWINGS         "
      @ 15,nc+2 PROMPT "5. JC REPORT        "
      @ 16,nc+2 PROMPT "6. RECOURCE     Name"
      @ 18,nc+2 PROMPT "7. Job Card Progress"
      @ 19,nc+2 PROMPT " REINDEX      BEWARE"
      @ 20,nc+2 PROMPT Menu->CH_Main
      nc := ncl 
      MENU TO nselect
      DO CASE
         CASE nselect == 9 .OR. PressedEsc()
            EXIT
         CASE nselect == 1
            SAVE SCREEN TO Invscrn
             Operation()                    // XF2PPART 
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 2
            SAVE SCREEN TO Invscrn
             mpartnum := SPACE( 20 )
             PartOper2( @mpartnum )         // XF2PPart
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 3
            SAVE SCREEN TO Invscrn
             JobOperate()                   // XF2PPART
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 4
            SAVE SCREEN TO Invscrn
               JobDraw()                    // JobDem 
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 5
            SAVE SCREEN TO Invscrn
             JCOperation()                  // XLF_Equ2 
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 6
            SAVE SCREEN TO Invscrn
              RecourceAdd()                // XLF_Job 
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 7
            SAVE SCREEN TO Invscrn
              ProgDesc()                // XLF_QU2 
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 8
            SAVE SCREEN TO Invscrn
              SCROLL()
              @ 10,10 SAY "BEWARE MAKE SURE NOBODY ON THE NETWORK" COLOR "R+"
              @ 12,10 SAY "Esc  to EXIT"
              IF PressedEsc()
                 EXIT
              ENDIF
              msure := ApGetN( "ARE YOU SURE TO REINDEX" )
              IF msure = "Y" 
                 DBFReindx()                 // JobRendx
                 XF_DBFUse()                 // JobNet
                 UpDateJC()                  // Update Orders File
              ENDIF              // msure
            RESTORE SCREEN FROM Invscrn
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   ***** End of Mu-Oper

   ***-------------------------------------------------------------------

FUNCTION JCOperation()

   SCROLL()
   mcodeno := SPACE( 8 )
   aPart_  := {}
   anum    := {}
   nrecno  := 0
   mtempno := SPACE( 10 )
   SELECT Quot
   SET ORDER TO 1      // Codeno
   GOTO TOP
   DO WHILE Quot->( !EOF() )
      IF Quot->Codeno = mtempno
         SKIP ALIAS Quot
         LOOP
      ENDIF
      IF Quot->Invno = SPACE( 6 )
         SKIP ALIAS Quot
         LOOP
      ENDIF
      SELECT Name
      SEEK Quot->Codeno
      SELECT Quot
      mtempno := Quot->Codeno
      AADD( aPart_,Name->Name;
           +"               "+STR( RECNO(),6 ) )
      SKIP ALIAS Quot
   ENDDO                   // Quot
   IF !EMPTY( aPart_ )
      DISPBOX( 0, 1, 24,39, 2 )
      @ 12,44 SAY "Job Card REPORT" COLOR "BG+"
      ASORT( aPart_,,,{ | x,y | x < y })
      anum := ACHOICE( 1, 3, 23,36, aPart_,,"AFUNC" )
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      IF PressedEsc()
         RETURN NIL
      ENDIF
      GOTO nrecno
      mcodeno := Quot->Codeno
      SELECT Debit
      GOTO TOP
      IF LASTREC() != 0
         aPart_ := {}
         nrecno := 0
         DO WHILE Debit->( !EOF() )
            IF Debit->Stat != "J"
               SKIP ALIAS Debit
               LOOP
            ENDIF
            IF Debit->Codeno != mcodeno
               SKIP ALIAS Debit
               LOOP
            ENDIF
            AADD( aPart_,Debit->Invno+" "+Debit->Stat;
                 +" "+Debit->Equip; 
                 +" "+Debit->Codeno;
                 +" "+Debit->BranchId;
                 +" "+DTOC( Debit->Dbdate );
                 +" "+STR( Debit->Amount,10, 2 )+" "+Debit->Saleno;
                 +" "+Debit->Est+"                        "+STR( RECNO(),6 ) )
           SKIP ALIAS Debit
         ENDDO               // Debit
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX(  0, 1, 24,79, 2 )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum   := ACHOICE(  1, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
         nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
         GOTO nrecno
         minvno  := Debit->Invno
         mcodeno := Debit->Codeno
         coperno := Debit->Operno
      ENDIF                     // Empty
   ENDIF                        // LastRec    
   ENDIF                      // Empty
   SCROLL( 19, 0, 24,80)
   DISPBOX( 19, 1, 24,79, 2 )
   mchoice := 1
   @ 20, 6      PROMPT "1. Hours JC Report"
   @ 20,COL()+2 PROMPT "2. Parts JC Report" 
   @ 20,COL()+2 PROMPT "3. Process Edit" 
   @ 20,COL()+2 PROMPT "4. Drawings" 
   MENU TO mchoice
   DO CASE
      CASE PressedEsc()
           RETURN NIL
      CASE mchoice == 1             //
          JCDirect2() 
      CASE mchoice == 2             //
          JCDirect() 
      CASE mchoice == 3             //
          JobOperate() 
      CASE mchoice == 4             //
          JobDraw() 
   ENDCASE

   RETURN NIL
   ***-------- End of JCOperation

   ****-------------------------------------------------------------------------

FUNCTION EquAdd()

   manother := "Y"
   DO WHILE manother == "Y"

         SCROLL()
         DISPBOX(  0, 1, 2,79, 2 )
         @  1,10 SAY "Edit Module Only"
         mmodcode:= morig:= moldmodcode := SPACE( 16 )
         DISPBOX(  3, 1, 24,79, 2 )
   mselect := "    " 
   @ 6,10 SAY "Select Exact First 4 Letters Blank for all" GET mselect PICTURE "@!X"
   @ 8,10 SAY "If Blank the file may be too big" COLOR "R+"
    READ
   aPart_ := {}
   anum   := {}
   nrecno := 0
   @ 6,10 SAY "                                                 "
   SELECT EquDesc
   IF mselect = "    "
      IF LASTREC() > 1800
         @ 10,10 SAY "Sorry Files too Big for Memory"
         @ 12,10 SAY Lastrec() PICTURE "99,999"
         WAIT
         RETURN NIL
      ENDIF
      @ 10,10 SAY "Please WAIT Big Files"
   ENDIF  // mselect
   IF LASTREC() != 0
      GOTO TOP
      DO WHILE EquDesc->( !EOF() )
         IF mselect != "    "
            DO CASE
            CASE SUBSTR( mselect, 2, 3 ) = "   "
               IF SUBSTR( EquDesc->Modcode, 1, 1 ) != SUBSTR( mselect, 1, 1 )
                  SKIP ALIAS EquDesc
                  LOOP
               ENDIF
            CASE SUBSTR( mselect, 3, 2 ) = "  "
               IF SUBSTR( EquDesc->Modcode, 1, 2 ) != SUBSTR( mselect, 1, 2)
                  SKIP ALIAS EquDesc
                  LOOP
               ENDIF
            CASE SUBSTR( mselect, 4, 1 ) = " "
               IF SUBSTR( EquDesc->Modcode, 1, 3 ) != SUBSTR( mselect, 1, 3 )
                  SKIP ALIAS EquDesc
                  LOOP
               ENDIF
            CASE mselect != "    "
               IF SUBSTR( EquDesc->Modcode, 1, 4 ) != SUBSTR( mselect, 1, 4 )
                  SKIP ALIAS EquDesc
                  LOOP
               ENDIF
         ENDCASE
      ENDIF 
      AADD( aPart_,EquDesc->ModCode;
              +" "+EquDesc->Desc;
              +" "+EquDesc->EquId;
              +"          "+STR( RECNO(),6 ) )
      SKIP ALIAS EquDesc
   ENDDO                       // EOF()
   IF !EMPTY( aPart_ )
      ASORT( aPart_,,,{ | x,y | x < y } )
      anum := ACHOICE(  4, 3, 23,78,aPart_,,"AFUNC" )
      IF PressedEsc()
         RETURN NIL
      ENDIF
      nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
      GOTO nrecno
      mmodcode := EquDesc->Modcode
   ENDIF
     ENDIF              // Lastrec
      ntotwhol := 0
      SCROLL( 1, 2, 1,78 )
      SCROLL(  3, 0, 24,80 )
      DISPBOX(  3, 1, 18,79, 2 )
      @  1, 5 SAY EquDesc->ModCode+"  "+EquDesc->Desc
      tempscrn := SAVESCREEN( 11, 0, 24,80 )

       EquSearch( mmodcode )

      RESTSCREEN( 11, 0, 24,80, tempscrn )
      manother := ApGetY( TRIM( Message->Another ) )       
  ENDDO                                              // manother   

   RETURN NIL
   ***---- End of EquAdd()

   ***----------------------------------------------------------------------------

STATIC FUNCTION EquVTotal()

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL()
      SELECT Equ
      IF LASTREC() > 2000
         @ 10,10 SAY "Sorry Files to Big for Memory"
         WAIT
         RETURN NIL
      ENDIF
      @ 10,10 SAY "Please WAIT Big Files"
      GOTO TOP
      SET EXACT ON
      npartqty := 0
      aPart_ := {}
      anum   := {}
         nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
         nqty1:= nqty2:= nqty3:= nqty4 := 0
         nequ1:= nequ2:= nequ3:= nequ4 := 0
         nquot := 1
         SELECT Equ
         GOTO TOP
         SET EXACT ON
       DO WHILE Equ->( !EOF() )
         npartqty++
      ***      AADD( aPart_," " )
         nqty1 := nquot*Equ->PartQty
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         AADD( aPart_,Equ->Modcode+"  "+Part->Desc;
                      +" "+STR( Equ->Partqty, 9, 3 );
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
               npartqty++
               nqty2 := Equ->PartQty
               nequ2 := ( nqty1 * nqty2 )* nquot
               SELECT Part
               SEEK Equ->Partnum
         SELECT Equ
         AADD( aPart_,"..  "+SUBSTR( Equ->Modcode, 1,16 );
                      +"  "+SUBSTR( Part->Desc, 1,36 );
                      +" "+STR( Equ->Partqty, 9, 3 );
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
               npartqty++
               nqty3 := Equ->PartQty
               nequ3 := nqty1 * nqty2 * nqty3 * nquot
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         AADD( aPart_,"... "+SUBSTR( Equ->Modcode, 1,16 );
                      +"  "+SUBSTR( Part->Desc, 1,36 );
                      +" "+STR( Equ->Partqty, 9, 3 );
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
                  npartqty++
                  nqty4 := Equ->PartQty
                  nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
         SELECT Part
         SEEK Equ->Partnum
         SELECT Equ
         AADD( aPart_,"...."+SUBSTR( Equ->Modcode, 1,16 );
                      +"  "+SUBSTR( Part->Desc, 1,36 );
                      +" "+STR( Equ->Partqty, 9, 3 );
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
      ***         ENDIF                          // Found mmod1
      IF !EMPTY( aPart_ )
         SET EXACT OFF  
         SCROLL()
         DISPBOX(  0, 1, 24,79, 2 )
         @  0, 10 SAY "  Parts "+STR( npartqty, 5 )
         @  0,60 SAY "   Qty       Cost  "
      ***      ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  1, 2, 23,78, aPart_,,"AFUNC" )
         IF PressedEsc()
            EXIT
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         SELECT Equ
         GOTO nrecno
         mmodcode := Equ->ModCode
         SELECT EquDesc
         SEEK Equ->Modcode
         IF FOUND()

            EquSearch( @mmodcode )

         ENDIF                   // FOUND                                              // mcontinue
      ENDIF
      mcontinue := "N" 
   ENDDO

   RETURN NIL
   ******* End of EquVTotal()

   **-------------           End of XLF_EQU2.PRG

