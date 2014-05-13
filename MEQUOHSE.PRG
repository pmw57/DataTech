   *** JK  27-10-10 20:19:53 

/* 
   Program.....:                MEQUOHSE.PRG
   Authors.....: J.Kirby
   Date........: 02/08/2001
   Functions...: MEuoLook, MEuotSearch, MEuotEdit, MEuotPAdd

   THIS IS THE PART NUMBER SYSTEM
*/

// (c) Copyright 1993 by Kirby Christchurch.

FUNCTION MEuoLook()

   aPart_ :={}
   SELECT QuotInfo
   GOTO TOP
   IF LASTREC() != 0
      SEEK mcodeno
      DO WHILE QuotInfo->Codeno = mcodeno .AND. QuotInfo->( !EOF() )
         IF QuotInfo->Invno != SPACE( 6 )
            SKIP ALIAS QuotInfo
            LOOP 
         ENDIF 
         mpartnum := QuotInfo->Partnum
         SELECT Part
         SEEK mpartnum
         SELECT QuotInfo
         AADD( aPart_,Part->Desc;
            +" "+DTOC( QuotInfo->DbDate );
            +" "+QuotInfo->Info;
            +"      "+STR( RECNO(),6 ) )
         SKIP ALIAS QuotInfo
      ENDDO
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @  1, 4      SAY TRIM( Name->Name )
      @  1,COL()+2 SAY TRIM( Name->Called )
      @  1,COL()+1 SAY TRIM( Name->Famname )
      DISPBOX( 3, 1, 23,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         ***      @  3,00 SAY " "
         ****      AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " ),QQOUT(A),Breakpoint() } )
         anum := ACHOICE( 4, 3, 22,78,aPart_,,"AFUNC" )
         IF PressedEsc()
            RETURN mcodeno
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         SELECT QuotInfo
         GOTO nrecno
         mcodeno    := QuotInfo->Codeno
         mpartnum   := QuotInfo->Partnum
         dDbdate    := QuotInfo->DbDate
         Quotcodeno := QuotInfo->Codeno
      ENDIF 
   ENDIF
   RETURN NIL
   ****---- End of MEuoLook()

   **-------------------------------------------------------------------

FUNCTION MEuotSearch()

   mcodeno := SPACE( 8 )
   SELECT QuotInfo
      mtempcode := "A       "
      GOTO TOP
      SEEK mtempcode
      IF !FOUND()
          ApRLock( 3 )
         APPEND BLANK
         QuotInfo->Codeno := "A      " 
         QuotInfo->Invno  := "9     "
         UNLOCK
      ENDIF 
   aPart_ := anum:= {}
   nrecno := 0
   maccepted := "N"
   SCROLL()
   DISPBOX( 0,45, 3,75, 2 )
   @  1,47 SAY "Select Name"
   SELECT QuotInfo
   IF LASTREC() = 0
      @ 7,53 SAY "NO Name Information"
      INKEY( 2 ) 
      RETURN NIL
   ENDIF
   IF LASTREC() != 0
      GOTO TOP
      mtempno := SPACE( 8 )
      DO WHILE QuotInfo->( !EOF() )
         IF SUBSTR( QuotInfo->Invno, 2, 2 ) != SPACE( 2 ) // Allow for 9
            SKIP ALIAS QuotInfo
            LOOP 
         ENDIF 
         IF QuotInfo->Codeno = mtempno
            SKIP ALIAS QuotInfo
            LOOP 
         ENDIF 
         SELECT Name
         SEEK QuotInfo->Codeno
         SELECT QuotInfo
         mtempno := QuotInfo->Codeno
         AADD( aPart_,Name->Name;
              +"  "+Name->Sale;
              +"      "+STR( RECNO(),6 ) )
         SKIP ALIAS QuotInfo
      ENDDO
      DISPBOX( 0, 1, 24,42, 2 )
      @ 22,45 SAY TRIM( Message->Select )
      @ 24,45 SAY TRIM( Message->Esc )
      @ 12,47 SAY "F2 To View ALL Info"     COLOR "GB+"
      IF !EMPTY( aPart_ )
         ASORT(aPart_,,,{ | x,y | x < y })
         anum := ACHOICE( 1, 3, 23,40, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         IF LASTKEY() == -1
            aPart_ := anum:= {}
            nrecno := 0
      SELECT QuotInfo
      GOTO TOP
      DO WHILE QuotInfo->( !EOF() )
         IF QuotInfo->Partnum = SPACE( 20 )
            SKIP ALIAS QuotInfo
            LOOP 
         ENDIF 
         SELECT Name
         SEEK QuotInfo->Codeno
         SELECT Part
         SET ORDER TO 1                    // Partnum
         SEEK QuotInfo->Partnum
         SELECT QuotInfo
         AADD( aPart_,SUBSTR( QuotInfo->Partnum, 1,16 );
                   +" "+SUBSTR( Part->Desc, 1,25 ); 
                   +" "+QuotInfo->Info;
                   +"      "+STR( RECNO(),6 ) )
         SKIP ALIAS QuotInfo
      ENDDO
      SCROLL()
      DISPBOX( 0, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT(aPart_,,,{ | x,y | x < y })
         anum := ACHOICE( 1, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         IF PressedEsc()
            RETURN NIL
         ENDIF
      ***          MEuotAdd()                    // MEQuot
      ***          MEuotSearch()                 // MEQuot
         ENDIF
      ENDIF
      ENDIF
      GOTO nrecno
      IF QuotInfo->Codeno = "A       "
           MEuotAdd()                      // MEQuot
           MEuotSearch()                   // MEQuot
      ENDIF                 // Codeno = A
      mcodeno    := QuotInfo->Codeno
      dDbdate    := QuotInfo->DbDate
      Quotcodeno := QuotInfo->Codeno
      SELECT Name
      SEEK mcodeno
      SELECT QuotInfo
        MEuotEdit( mcodeno )               // MEQuoHse
   ENDIF
   IF mcodeno != SPACE( 8 )
       MEuotSearch()                       // MEQuoHse
   ENDIF

   RETURN NIL
   ****---- End of MEuotSearch()

   **-------------------------------------------------------------------

FUNCTION MEuotEdit()
 
   QuotCodeno := Name->Codeno
   mpartnum := SPACE( 20 )
   mcontinue = "Y"
   DO WHILE mcontinue = "Y"
      aPart_ :={}
      nrecno := 0
      SELECT QuotInfo
      GOTO TOP
      mcodeno := Name->Codeno
      SEEK mcodeno
      DO WHILE QuotInfo->Codeno = mcodeno .AND. QuotInfo->( !EOF() )
         IF QuotInfo->Invno != SPACE( 6 )
            SKIP ALIAS QuotInfo
            LOOP 
         ENDIF 
         SELECT Part
         SEEK QuotInfo->Partnum
         SELECT QuotInfo
         AADD( aPart_,SUBSTR( QuotInfo->Partnum, 1,16 );
            +" "+SUBSTR( Part->Desc, 1,25 ); 
            +" "+QuotInfo->Info;
            +"      "+STR( RECNO(),6 ) )
         SKIP ALIAS QuotInfo
      ENDDO
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @  1, 4      SAY TRIM( Name->Name )
      @  1,COL()+2 SAY TRIM( Name->Called )
      @  1,COL()+1 SAY TRIM( Name->Famname )
      DISPBOX( 3, 1, 24,79, 2 )
      Quotcodeno := SPACE( 8 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 4, 3, 23,78,aPart_,,"AFUNC" )
         IF PressedEsc()
            RETURN mcodeno
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         SELECT QuotInfo
         GOTO nrecno
         mpartnum   := QuotInfo->Partnum
         dDbdate    := QuotInfo->DbDate
         Quotcodeno := QuotInfo->Codeno
         SELECT Part
         SEEK mpartnum
      ENDIF
      SCROLL(   3, 0, 24,80 )
      DISPBOX(  3, 1, 21,79, 2 )
      @  4, 4      SAY TRIM( QuotInfo->Partnum )
      @  4,COL()+2 SAY Part->Desc  COLOR "BG+" 
      @  6, 4      SAY QuotInfo->Info 
      @  7, 4      SAY QuotInfo->Info2
      @  8, 4      SAY QuotInfo->Info3
      @  9, 4      SAY QuotInfo->Info4
      @ 10, 4      SAY QuotInfo->Info5
      @ 11, 4      SAY QuotInfo->Info6
      coderef := QuotInfo->Faxno
       MemoDisp( coderef )        // XF-Memo2
      nselect := 1
      DISPBOX(  22, 1, 24,79, 2 )
      @ 23, 4      PROMPT "Edit"
      @ 23,COL()+2 PROMPT "Add Info"
      @ 23,COL()+2 PROMPT "Info Form"
      @ 23,COL()+2 PROMPT "Print"
      @ 23,COL()+2 PROMPT "Delete Info"
      @ 23,COL()+2 PROMPT "Part Edit"
      @ 23,COL()+2 PROMPT "Exit"
      MENU TO nselect
      DO CASE
         CASE nselect == 7 .OR. PressedEsc()
            RETURN mcodeno  
         CASE nselect == 1
            MEuotPrice( @mpartnum )         // MEQuoHse
            MEuotEdit( @mcodeno )           // MEQuoHse
            LOOP
         CASE nselect == 2
            dDbdate := DATE()
            mpartnum := SPACE( 20 )
             MEuotPAdd( mpartnum )          // MEQuoHse
            LOOP
        CASE nselect == 3
            tempscrn := SAVESCREEN( 0, 0, 24,80 )
             MEuotJSheet( mcodeno )               // Above                          
            RESTSCREEN(  0, 0, 24,80,tempscrn )
            mcontinue := "Y" 
            LOOP
        CASE nselect == 4
            tempscrn := SAVESCREEN( 0, 0, 24,80 )
             MEuotindi( @mcodeno )
            RESTSCREEN(  0, 0, 24,80,tempscrn )
            mcontinue := "Y" 
            LOOP
        CASE nselect == 5
            mok := ApGetN( TRIM( Message->Delete )+" Information" )
            IF mok == "Y"
               SELECT CusNotes
                ApFLock( 3 )
               DELETE ALL FOR SUBSTR( Code_Ref,1,20 );
                      = QuotInfo->Codeno+TRIM( QuotInfo->Partnum ) 
               UNLOCK
               SELECT QuotInfo
                ApFLock( 3 )
               DELETE ALL FOR QuotInfo->Partnum = mpartnum 
               UNLOCK
            ENDIF                            // mok
            mcontinue := "Y" 
            LOOP 
        CASE nselect == 6                     
            tempscrn := SAVESCREEN( 0, 0, 24,80 )
            mpartnum := Part->Partnum 
            Quotcodeno := Name->Codeno
              MEProfQty()                        // MEParDet
            SELECT Name
            SEEK Quotcodeno
            mcodeno := Name->Codeno
            RESTSCREEN(  0, 0, 24,80,tempscrn )
            mcontinue := "Y" 
            LOOP
      ENDCASE
      mcontinue = "N"
   ENDDO                       // mcontinue
   RETURN mpartnum

   ***-----End of MEuotEdit()

   **-------------------------------------------------------------------

FUNCTION MEuotPAdd( mpartnum )
 
   Quotcodeno := Name->Codeno
   IF mpartnum = SPACE( 20 ) 
      SELECT Part
      SET ORDER TO 1
      SCROLL()
       Partfind( @mpartnum )                // XlF_Part
      mpartnum := Part->Partnum
   ENDIF                            // mpartnum
   SELECT Name
   SEEK Quotcodeno
   mcodeno := Name->Codeno
   SELECT Part
   SET ORDER TO 1                  // Partnum 
   SEEK mpartnum
   ***   IF FOUND()
      SELECT QuotInfo
       ApFLock( 3 )
      APPEND BLANK
      QuotInfo->Partnum  := mpartnum
      QuotInfo->Catno    := Part->Catno
      QuotInfo->Codeno   := Name->Codeno
      QuotInfo->Dbdate   := Date()
      QuotInfo->Duedate  := Date()
      QuotInfo->Faxno    := SUBSTR( mpartnum, 1, 8 )+Name->Codeno+LTRIM( STR( LASTREC(),4 ) )
      UNLOCK
       MEuotPrice( @mpartnum )                         // MEQuot
   ***    ELSE
   ***      SCROLL()
   ***   ENDIF

   RETURN mpartnum

   ****---- End of MEuotPAdd()

   *****------------------- END OF File MEQuoHse.PRG
   