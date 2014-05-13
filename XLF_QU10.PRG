   ***  JoKir10  09-10-11 21:53:06 

/*
   Program.....:                  XLF_QU10.PRG
   Authors.....: J.Kirby
   Date........: 20/12/2009
   Functions...: LabourChri
*/

FUNCTION LabourChri()
   SCROLL()
   manother = "Y"
   DO WHILE manother = "Y"
      ***      Selection()     // XLF_Qu10.preg
      ntottime := 0
      aPart_:={}
      nDays := 6
      dDate := DATE()
      cdatecode := SPACE( 19 )
      aPart_:={}
      nrecno := 0
      nTime  := 0
      SELECT Prof
      SET ORDER TO 2     // Codeno
      GOTO TOP
      SEEK mcodeno
      IF LASTREC() != 0
         DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !EOF() )
            IF Prof->Date != dDate
               SKIP ALIAS Prof
               LOOP
            ENDIF  
            ntottime += Prof->Time
            cdatecode := DTOC( Prof->Date )+" "+Prof->Codeno
            AADD( aPart_,Prof->Operno;
                      +" "+Prof->Adminno;
                      +" "+STR( Prof->Time, 8, 2 );
                      +" "+SUBSTR( Prof->Desc, 1,35 ) )
            SKIP ALIAS Prof
         ENDDO                        // Prof EOF
      ENDIF      // 0
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @  1, 4      SAY TRIM( Name->Name )            COLOR "BG+"
         @  1,COL()+2 SAY ntottime    PICTURE "9999.99" COLOR "BG+"
         @  1,COL()+1 SAY ntottime/60 PICTURE "999.99"  COLOR "BG+"
         @  1,COL()+2 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ), 5 )
         @  1,COL()+2 SAY madminno                      COLOR "RG+"
         DISPBOX( 0, 1, 24,79, 2 )    // This is Special 
         ASORT( aPart_,,,{ | x,y | x < y } )
         @  3,00 SAY " "
         AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " ),QQOUT(A),Breakpoint() } )
      ENDIF                        // Empty
      SCROLL( 15,2, 18,78 ) 
      @ 16, 3      SAY TRIM( Name->Name )             COLOR "BG+"
      @ 16,COL()+2 SAY "Staff "+DTOC( dDate )         COLOR "RG+"
      @ 16,COL()+2 SAY nTotTime    PICTURE "9,999.99" COLOR "BG+"
      @ 16,COL()+1 SAY ntottime/60 PICTURE "999.99"   COLOR "BG+"
      @ 16,COL()+2 SAY madminno                       COLOR "RG+"
      SCROLL(  17, 0, 24,80 )
      DISPBOX( 17, 1, 24,79, 2 )
      nselect := 1
      @ 17, 6      SAY " --- Adding Task --- "
      @ 19, 4      PROMPT "1. Add Task"
      @ 19,COL()+2 PROMPT "2. Delete/Edit Prof"
      @ 19,COL()+2 PROMPT "3. Edit All"
      @ 21, 4      PROMPT "4. Print Indiv"
      @ 21,COL()+1 PROMPT "5. Print All"
      @ 21,COL()+1 PROMPT "6. Tasks Edit"
      @ 21,COL()+1 PROMPT "7. Prof Oper"
      @ 23, 4      PROMPT "8. Task Add/Edit"
      @ 23,COL()+2 PROMPT "9. Task Print"
      @ 23,COL()+2 PROMPT "Exit"
      @ 23,COL()+6 SAY madminno COLOR "RG+"
      MENU TO nselect
      DO CASE
         CASE nselect == 6
            IF Note->Select12 = "Y"
              SCROLL()
              @ 10,10 SAY "Under Development"  COLOR "R+"
              LOOP
            ENDIF 
            LabEdit()     // XLF_QU10
            LOOP
         CASE nselect == 7
            POEdit()      // XLF_QU10
            LOOP
         CASE nselect == 8
            LAEdit()      // XLF_QU10
            LOOP
         CASE nselect == 10 .OR. PressedEsc()
            Menu()  //    RETURN NIL
         CASE nselect == 1  // ADD NEW
            ****      Selection()     // XLF_Qu10.preg
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
               ntottime := 0
               aPart_:={}
               nDays := 6
               dDate := DATE()
               cdatecode := SPACE( 19 )
               aPart_:={}
               nrecno := 0
               nTime  := 0
               SELECT Prof
               SET ORDER TO 2     // Codeno
               GOTO TOP
               SEEK mcodeno
               IF LASTREC() != 0
                  DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !EOF() )
                     IF Prof->Date != dDate
                        SKIP ALIAS Prof
                        LOOP
                     ENDIF  
                     ntottime += Prof->Time
                     cdatecode := DTOC( Prof->Date )+" "+Prof->Codeno
                     AADD( aPart_,Prof->Operno;
                        +" "+Prof->Adminno;
                        +" "+STR( Prof->Time, 8, 2 );
                        +" "+SUBSTR( Prof->Desc, 1,35 ) )
                     SKIP ALIAS Prof
                  ENDDO                        // Prof EOF
               ENDIF      // 0
               IF !EMPTY( aPart_ )
                  SCROLL()
                  DISPBOX( 0, 1, 2,79, 2 )
                  @  1, 4      SAY TRIM( Name->Name ) COLOR "BG+"
                  @  1,COL()+2 SAY ntottime    PICTURE "9999.99" COLOR "BG+"
                  @  1,COL()+1 SAY ntottime/60 PICTURE "999.99" COLOR "BG+"
                  @  1,COL()+2 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                             +STR( YEAR(DATE() ), 5 )
                  @  1,COL()+2 SAY madminno                      COLOR "RG+"
                  DISPBOX( 0, 1, 24,79, 2 )    // This is Special 
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  @  3,00 SAY " "
                  AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " ),QQOUT(A),Breakpoint() } )
               ENDIF                        // Empty
               SCROLL( 15,2, 18,78 ) 
               @ 16, 4      SAY TRIM( Name->Name )             COLOR "BG+"
               @ 16,COL()+2 SAY "Staff Labour "+DTOC( dDate )  COLOR "RG+"
               @ 16,COL()+2 SAY nTotTime    PICTURE "9,999.99" COLOR "BG+"
               @ 16,COL()+1 SAY ntottime/60 PICTURE "999.99"   COLOR "BG+"
               @ 16,COL()+2 SAY madminno                       COLOR "RG+"
               aPart_:={}
               nrecno := 0
               coperno:= clabno := SPACE( 12 )
               mcorrect := "N"
               DO WHILE mcorrect == "N"
                  SCROLL( 18, 0, 24,80 )
                  DISPBOX( 18, 1,24,79, 2 )
                  dDate    := DATE()-1
                  ***      mtime    := demand->Time
                  cselect := "  "  
                  cdate   := "N"
                  @ 20, 4      SAY Name->Name     COLOR "RG+"  
                  @ 20,COL()+2 SAY madminno  COLOR "RG+"
                  SELECT Demand
                  SET ORDER TO 1               // operno
                  GOTO TOP
                  @ 22, 4 SAY "Select Task Type  "+madminno COLOR "RG+"
           
                  IF LASTREC() != 0
                     coperno := SPACE( 12 )
                     DO WHILE demand->( !EOF() )
                        IF Demand->Adminno != SPACE( 8 )
                           IF Demand->Adminno != madminno
                              SKIP ALIAS demand
                              LOOP
                           ENDIF
                        ENDIF  
                        IF Demand->Adminno = SPACE( 8 )
                           IF madminno != SPACE( 8 )
                              SKIP ALIAS demand
                              LOOP
                           ENDIF
                        ENDIF  
                        IF demand->Operno = SPACE( 12 )
                           SKIP ALIAS demand
                           LOOP
                        ENDIF
                        IF demand->Operno = coperno
                           SKIP ALIAS demand
                           LOOP
                        ENDIF
                        AADD( aPart_,( demand->Operno;
                           +"        "+STR( RECNO(),6 ) ) )
                        coperno := demand->Operno
                        SKIP ALIAS demand
                     ENDDO                       // demand EOF
                  ENDIF                   // 0
                  SCROLL( 0,65, 24,80 )
                  DISPBOX(  0,65, 24,79, 2 )
                  @ 1,67 SAY "Task Type" COLOR "RG+"
                  IF !EMPTY( aPart_ )
                     ASORT( aPart_,,,{ | x,y | x < y } )
                     anum := ACHOICE( 2,67, 23,78,aPart_,,"AFUNC" )
                     nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                     GOTO nrecno
                     IF PressedEsc()
                        RETURN NIL
                     ENDIF
                     coperno  := Demand->Operno
                  ENDIF     // 0
                  aPart_:={}
                  nrecno := 0
                  clabno := SPACE( 12 )
                  GOTO TOP
                  SEEK coperno
                  @ 23, 4      SAY "Category for"  COLOR "RG+" 
                  @ 23,COL()+1 SAY Demand->Operno  COLOR "RG+"
                  @ 23,COL()+2 SAY Demand->Adminno COLOR "RG+"
                  IF LASTREC() != 0
                     IF FOUND() 
                        clabno := SPACE( 12 )
                        DO WHILE demand->Operno = coperno .AND. demand->( !EOF() )
                           IF Demand->Adminno != SPACE( 8 )
                              IF Demand->Adminno != madminno
                                 SKIP ALIAS demand
                                 LOOP
                              ENDIF
                           ENDIF  
                           IF Demand->Adminno = SPACE( 8 )
                              IF madminno != SPACE( 8 )
                                 SKIP ALIAS demand
                                 LOOP
                              ENDIF
                           ENDIF  
                           IF demand->Operno = SPACE( 12 )
                              SKIP ALIAS demand
                              LOOP
                           ENDIF
                           IF demand->Labno = SPACE( 12 )
                              SKIP ALIAS demand
                              LOOP
                           ENDIF  
                           IF demand->Labno = clabno
                              SKIP ALIAS demand
                              LOOP
                           ENDIF  
                           AADD( aPart_, ( demand->Labno;
                                  +"        "+STR( RECNO(),6 ) ) )
                           clabno := demand->Labno
                           SKIP ALIAS demand
                        ENDDO
                     ENDIF     // Found
                  ENDIF       // 0
                  SCROLL( 0,49, 24,64 )
                  DISPBOX(  0,49, 24,64, 2 )
                  @ 1,51 SAY "Category" COLOR "RG+"
                  IF !EMPTY( aPart_ )
                     ASORT( aPart_,,,{ | x,y | x < y } )
                     anum := ACHOICE( 2,51, 23,63,aPart_,,"AFUNC" )
                     nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                     GOTO nrecno
                     IF PressedEsc()
                        RETURN NIL
                     ENDIF
                     coperno  := demand->Operno
                     clabno := demand->Labno          // Category
                  ENDIF                   // Empty

                  cjobnum := SPACE( 12 )
                  SELECT demand
                  SET ORDER TO 3        // Jobnum
                  aPart_:={}
                  nrecno := 0
                  GOTO TOP
                  cjobnum := SPACE( 12 )
                  IF LASTREC() != 0
                     DO WHILE demand->( !EOF() )
                        IF Demand->Adminno != SPACE( 8 )
                           IF Demand->Adminno != madminno
                              SKIP ALIAS demand
                              LOOP
                           ENDIF
                        ENDIF  
                        IF Demand->Adminno = SPACE( 8 )
                           IF madminno != SPACE( 8 )
                              SKIP ALIAS demand
                              LOOP
                           ENDIF
                        ENDIF  
                        IF demand->Operno = SPACE( 12 )
                           SKIP ALIAS demand
                           LOOP
                        ENDIF  
                        IF demand->Jobnum = SPACE( 12 )
                           SKIP ALIAS demand
                           LOOP
                        ENDIF  
                        IF demand->Jobnum = cjobnum
                           SKIP ALIAS demand
                           LOOP
                        ENDIF  
                        AADD( aPart_, ( demand->Jobnum;
                               +"        "+STR( RECNO(),6 ) ) )
                        cjobnum := demand->Jobnum
                        SKIP ALIAS demand
                     ENDDO
                  ENDIF          // 0  
                  SELECT demand
                  SET ORDER TO 1         // Operno LabNo
                  GOTO TOP
                  SEEK coperno+clabno
                  IF FOUND()
                     aPart_:={}
                     nrecno := 0
                     IF LASTREC() != 0
                        DO WHILE demand->Operno = coperno .AND. demand->Labno = clabno;
                              .AND. demand->( !EOF() )
                           IF Demand->Adminno != SPACE( 8 )
                              IF Demand->Adminno != madminno
                                 SKIP ALIAS demand
                                 LOOP
                              ENDIF
                           ENDIF  
                           IF Demand->Adminno = SPACE( 8 )
                              IF madminno != SPACE( 8 )
                                 SKIP ALIAS demand
                                 LOOP
                              ENDIF
                           ENDIF  
                           IF demand->Operno = SPACE( 12 )
                              SKIP ALIAS demand
                              LOOP
                           ENDIF  
                           IF demand->Labno = SPACE( 12 )
                              SKIP ALIAS demand
                              LOOP
                           ENDIF  
                           IF demand->Labno != clabno
                              SKIP ALIAS demand
                              LOOP
                           ENDIF 
                           AADD( aPart_,( Demand->Operno+" "+Demand->Labno;
                                 +" "+Demand->Desc+" "+Demand->JobNum;
                                 +"                    "+STR( RECNO(),6 ) ) )
                           SKIP ALIAS Demand
                        ENDDO
                     ENDIF      // 0
                  ENDIF       // Found
                  SCROLL()
                  DISPBOX(  0, 1, 24,79, 2 )
                  IF !EMPTY( aPart_ )
                     ASORT( aPart_,,,{ | x,y | x < y } )
                     anum := ACHOICE( 2, 3, 23,77,aPart_,,"AFUNC" )
                     nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                     GOTO nrecno
                  ENDIF          // aPart_ 
                  IF PressedEsc()
                     RETURN NIL
                  ENDIF
                  SCROLL()
                  DISPBOX(  0, 1, 24,79, 2 )
                  clabno    := demand->Labno       
                  mdesc     := demand->Desc
                  mdesc1    := demand->Desc1
                  mdesc2    := demand->Desc2
                  mdesc3    := demand->Desc3
                  mdesc4    := demand->Desc4
                  mjobnum   := Demand->JobNum 
                  ***      madminno  := Demand->Adminno
                  mfltrecno := SPACE( 20 )
                  crate     := 0
                  @  1, 4 SAY Name->Name COLOR "RG+"
                  @  3, 4 SAY "Operno   " GET coperno PICTURE "@!"
                  @  3,COL()+2 SAY "Can Enter New"
                  @  3,COL()+4 SAY demand->Operno COLOR "BG+" 
                  @  5, 4 SAY "Category " GET clabno  PICTURE "@!"
                  @  5,COL()+2 SAY demand->Labno  COLOR "BG+" 
                  @  5,COL()+2 SAY "Dewey " GET madminno PICTURE "@!"
                  @  7, 4 SAY "Task Desc" GET mdesc   PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                  @  8, 4 SAY "         " GET mdesc1  PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                  @  9, 4 SAY "         " GET mdesc2  PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                  @ 10, 4 SAY "         " GET mdesc3  PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                  @ 11, 4 SAY "         " GET mdesc4  PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                  @ 12, 4 SAY "Section  " GET mjobnum PICTURE "@!"
                   READ
                  IF PressedEsc()
                     RETURN NIL
                  ENDIF
                  myes := "N"
                  @ 12,50 SAY "New Entry" GET myes VALID( myes $ "NY" ) PICTURE "@!"
                   READ
                  IF myes = "Y"
                     myes := "Y"
                     @ 12,50 SAY "  Sure New  " COLOR "RG+" 
                     @ 12,COL()+1 GET myes VALID( myes $ "NY" ) PICTURE "@!"
                     @ 13,50 SAY "ARE YOU SURE" COLOR "BG+" 
                      READ
                  ENDIF
                  IF myes = "Y"
                     SELECT Demand 
                      ApFLock( 3 )
                     APPEND BLANK
                     nrecno := STR( RECNO(), 4 )
                     UNLOCK
                  ENDIF 
                  SELECT demand
                  ApFLock( 3 )
                  demand->Operno    := coperno            // Task Type
                  demand->Labno     := clabno             // Category
                  demand->JobNum    := mjobnum            // Section
                  demand->Desc      := mdesc
                  demand->Desc1     := mdesc1
                  demand->Desc2     := mdesc2
                  demand->Desc3     := mdesc3
                  demand->Desc4     := mdesc4
                  demand->StartDate := dDate
                  demand->Date      := dDate
                  demand->Codeno    := mcodeno
                  Demand->Adminno   := madminno
                  ****     demand->Message := mfltrecno          // Info
                  UNLOCK
                  SCROLL( 14, 0, 23,80 )
                  DISPBOX( 0, 1, 24,79, 2 )

                  SelectMenu() // XLF_Qu10.prg 

                  mcorrect := "Y"
               ENDDO  // mcorrect
               manother := ApGetY( "Another this Name " )
               IF manother = "Y"
                  mcontinue := "Y" 
                  LOOP
               ELSE
                  mcontinue := "N"
               ENDIF 
            ENDDO        // mcontinue
            manother := "Y"
            LOOP

         CASE nselect == 2                    // Edit Prof
            SCROLL( 15, 2, 19,78 )
            DISPBOX( 15, 0,19,79, 2 )
            mstmm  := DATE()-2
            mendmm := DATE()
            @ 16, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
            @ 17, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
             READ
            SELECT Prof
            ***      SET ORDER TO 1        //
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
               aPart_:={}
               nrecno := 0
               GOTO TOP
               ***    IF FOUND()
               IF LASTREC() != 0
                  DO WHILE Prof->( !EOF() )
                     IF Prof->Date < mstmm
                        SKIP ALIAS Prof
                        LOOP
                     ENDIF
                     IF Prof->Date > mendmm
                        SKIP ALIAS Prof
                        LOOP
                     ENDIF
                     AADD( aPart_,Prof->Codeno;
                        +" "+DTOC( Prof->Date );
                        +" "+Prof->Desc;
                        +" "+STR( Prof->Time, 8, 2 );
                        +" "+Prof->Operno;
                        +"                 "+STR( RECNO(), 6 ) ) 
                     SKIP ALIAS Prof
                  ENDDO                        // Prof EOF
               ENDIF      // 0
               IF !EMPTY( aPart_ )
                  SCROLL()
                  DISPBOX( 0, 0, 2,79, 2 )
                  @  1,10 SAY Name->Name COLOR "BG+"
                  @  1,60 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                             +STR( YEAR(DATE() ), 5 )
                  DISPBOX( 3, 0, 24,79, 2 )
                   ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE( 4, 3,23,77,aPart_,,"AFUNC" )
                  IF PressedEsc()
                     EXIT
                  ENDIF
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
               ENDIF                        // Empty
               mcorrect := "N"
               DO WHILE mcorrect == "N"
                  SELECT Prof
                  SCROLL(   3, 0, 24,80 ) 
                  DISPBOX(  3, 0, 24,79, 2 )
                  @ 24,60 SAY " DT411 "
                  mdesc     := Prof->Desc
                  mdesc1    := Prof->Desc1
                  mdesc2    := Prof->Desc2
                  mdesc3    := Prof->Desc3
                  mdesc4    := Prof->Desc4
                  mtime     := Prof->Time
                  mdesc2    := Prof->Desc2
                  mstaff    := Prof->Codeno
                  ddate     := Prof->Date
                  clabno  := Prof->Adminno
                  coperno   := Prof->Operno
                  cpartnum  := Prof->Partnum
                  mfltrecno := Prof->FltRecno
                  nrate     := Prof->Rate
                  SELECT Name
                  SEEK Prof->Codeno
                  @  5, 8      SAY Prof->Codeno+"  "+Name->Name COLOR "RG+"
                  SELECT Prof
                  @  7, 8      SAY "Task Desc" GET mdesc     PICTURE "@X"
                  @  8, 8      SAY "Prod Info" GET mfltrecno PICTURE "!XXXXXXXXXXXXXXXXXXX"
                  @  9, 8      SAY "Note     " GET mdesc1    PICTURE "@X"
                  @ 10, 8      SAY "         " GET mdesc2    PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                  @ 11, 8      SAY "         " GET mdesc3    PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                  @ 12, 8      SAY "         " GET mdesc4    PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                  @ 14, 8      SAY "Time     " GET mtime     PICTURE "9999.99"
                  @ 14,COL()+2 SAY "Date"      GET ddate     PICTURE "99/99/9999"
                  @ 16, 8      SAY "Task Type" GET coperno   PICTURE "@!"  
                  @ 16,COL()+2 SAY "Category"  GET clabno  PICTURE "@!"  
                  @ 18, 8      SAY "Section  " GET cpartnum  PICTURE "@X"
                  @ 18,COL()+2 SAY "Qty"       GET nrate     PICTURE "9999"     
                   READ
                   ApRLock( 3 )
                  Prof->Time     := mtime
                  Prof->Adminno  := clabno
                  Prof->Operno   := coperno
                  Prof->Date     := dDate
                  Prof->Desc     := mdesc
                  Prof->Desc1    := mdesc1
                  Prof->Desc2    := mdesc2
                  Prof->Desc3    := mdesc3
                  Prof->Desc4    := mdesc4
                  Prof->Fltrecno := mfltrecno
                  Prof->Partnum  := cpartnum
                  Prof->Rate     := nrate
                  UNLOCK
                  mcorrect := ApGetY( Message->Correct )
               ENDDO                                            // mcorrect
               SCROLL(  10, 0, 24,80 ) 
               DISPBOX( 10, 0, 24,79, 2 )
               @ 13, 8      SAY Prof->Desc                 COLOR "RG+"
               @ 15, 8      SAY "Time  "+STR( Prof->Time ) COLOR "BG+"
               @ 15,COL()+2 SAY "Date "+DTOC( Prof->Date ) COLOR "BG+"
               @ 17, 8      SAY "Staff "+Prof->Codeno      COLOR "RG+"
               @ 17,COL()+2 SAY Prof->Operno COLOR "BG+"
               @ 17,COL()+2 SAY Prof->Adminno  COLOR "BG+"
               mdelete := ApGetN( TRIM( Message->Delete )+" Prof" )
               IF PressedEsc()
                  EXIT           // RETURN NIL
               ENDIF
               IF mdelete == "Y"
                    SELECT Name
                    SEEK Prof->Codeno 
                    coderef := Name->Codeno+SUBSTR( Name->Name, 1, 8 )
                    SELECT Cusnotes
                    SEEK coderef
                    DO WHILE CusNotes->Code_ref = Coderef .AND. Cusnotes->( !EOF() )
                       @ 22,10 SAY Cusnotes->Code_ref COLOR "RG+"
                       INKEY( 1 ) 
                        ApFlock( 3 )
                       DELETE
                       UNLOCK
                       SKIP ALIAS CusNotes
                    ENDDO                          // Found()
                    SELECT Prof
                     ApFlock( 3 )
                    DELETE
                    UNLOCK
               ENDIF
               ****      ENDIF                // Found
               mcontinue := "Y"
               IF PressedEsc()
                  EXIT           // RETURN NIL
               ENDIF
            ENDDO                      // mcontinue 
            manother := "Y"
            LOOP

         CASE nselect == 3                    // Edit All Prof

            SCROLL( 16, 1, 19,78 )
            DISPBOX( 16, 0,24,79, 2 )
            @ 24,60 SAY " DT411 "
            mstmm  := DATE()-2
            mendmm := DATE()
            @ 17, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
            @ 18, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
             READ
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
               aPart_:={}
               nrecno := 0
               SELECT Prof
               SET ORDER TO 2       // Codeno
               GOTO TOP
               IF LASTREC() != 0
                  DO WHILE Prof->( !EOF() )
                     IF Prof->Date < mstmm
                        SKIP ALIAS Prof
                        LOOP
                     ENDIF
                     IF Prof->Date > mendmm
                        SKIP ALIAS Prof
                        LOOP
                     ENDIF
                     AADD( aPart_,Prof->Codeno;
                              +" "+DTOC( Prof->Date );
                              +" "+Prof->Desc;
                              +" "+STR( Prof->Time, 8, 2 );
                              +" "+Prof->Operno;
                              +"               "+STR( RECNO(), 6 ) ) 
                      SKIP ALIAS Prof
                  ENDDO                            // Prof EOF
               ENDIF           // 0
               IF !EMPTY( aPart_ )
                  SCROLL()
                  DISPBOX( 0, 0, 2,79, 2 )
                  @  1,10 SAY "Edit demand" COLOR "BG+"
                  @  1,60 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                             +STR( YEAR(DATE() ), 5 )
                  DISPBOX( 3, 0, 24,79, 2 )
                  @ 24,60 SAY " DT411 "
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE( 4, 3,23,77,aPart_,,"AFUNC" )
                  IF PressedEsc()
                     EXIT
                  ENDIF
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
               ENDIF                        // Empty
               mcorrect := "N"
               DO WHILE mcorrect == "N"
                  SELECT Prof
                  SCROLL(   3, 0, 24,80 ) 
                  DISPBOX(  3, 0, 24,79, 2 )
                  @ 24,60 SAY " DT411 "
                  mdesc     := Prof->Desc
                  mdesc1    := Prof->Desc1
                  mtime     := Prof->Time
                  mdesc2    := Prof->Desc2
                  mdesc3    := Prof->Desc3
                  mdesc4    := Prof->Desc4
                  mstaff    := Prof->Codeno
                  ddate     := Prof->Date
                  clabno  := Prof->Adminno
                  coperno   := Prof->Operno
                  cpartnum  := Prof->Partnum
                  mfltrecno := Prof->FltRecno
                  nrate     := Prof->Rate
                  SELECT Name
                  SEEK Prof->Codeno
                  @  5, 8      SAY Prof->Codeno+"  "+Name->Name COLOR "RG+"
                  SELECT Prof
                  @  7, 8      SAY "Task Desc" GET mdesc     PICTURE "@X"
                  @  8, 8      SAY "Prod Info" GET mfltrecno PICTURE "!XXXXXXXXXXXXXXXXXXX"
                  @  9, 8      SAY "Note     " GET mdesc1    PICTURE "@X"
                  @ 10, 8      SAY "         " GET mdesc2    PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                  @ 11, 8      SAY "         " GET mdesc3    PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                  @ 12, 8      SAY "         " GET mdesc4    PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                  @ 14, 8      SAY "Time     " GET mtime     PICTURE "9999.99"
                  @ 14,COL()+2 SAY "Date"      GET ddate     PICTURE "99/99/9999"
                  @ 16, 8      SAY "Task Type" GET coperno   PICTURE "@!"  
                  @ 16,COL()+2 SAY "Category"  GET clabno  PICTURE "@!"  
                  @ 18, 8      SAY "Section  " GET cpartnum  PICTURE "@X"
                  @ 18,COL()+2 SAY "Qty"       GET nrate     PICTURE "9999"     
                   READ
                   ApRLock( 3 )
                  Prof->Time     := mtime
                  Prof->Adminno  := clabno
                  Prof->Operno   := coperno
                  Prof->Date     := dDate
                  Prof->Desc     := mdesc
                  Prof->Desc1    := mdesc1
                  Prof->Desc2    := mdesc2
                  Prof->Desc3    := mdesc3
                  Prof->Desc4    := mdesc4
                  Prof->Fltrecno := mfltrecno
                  Prof->Partnum  := cpartnum
                  Prof->Rate     := nrate
                  UNLOCK
                  mcorrect := ApGetY( Message->Correct )
               ENDDO                                            // mcorrect
               SCROLL(  10, 0, 24,80 ) 
               DISPBOX( 10, 0, 24,79, 2 )
               @ 24,60 SAY " DT411 "
               @ 13, 8      SAY Prof->Desc                 COLOR "RG+"
               @ 15, 8      SAY "Time  "+STR( Prof->Time ) COLOR "BG+"
               @ 15,COL()+2 SAY "Date "+DTOC( Prof->Date ) COLOR "BG+"
               @ 17, 8      SAY "Staff "+Prof->Codeno      COLOR "RG+"
               @ 17,COL()+2 SAY Prof->Operno               COLOR "BG+"
               @ 17,COL()+2 SAY Prof->Adminno              COLOR "BG+"
               mdelete := ApGetN( TRIM( Message->Delete )+" Prof " )
               IF PressedEsc()
                  EXIT           // RETURN NIL
               ENDIF
               IF mdelete == "Y"
                  SELECT Name
                  SEEK Prof->Codeno 
                  coderef := Name->Codeno+SUBSTR( Name->Name, 1, 8 )
                  SELECT Cusnotes
                  SEEK coderef
                  DO WHILE CusNotes->Code_ref = Coderef .AND. Cusnotes->( !EOF() )
                     @ 22,10 SAY Cusnotes->Code_ref COLOR "RG+"
                     INKEY( 1 ) 
                     ApFlock( 3 )
                     DELETE
                     UNLOCK
                     SKIP ALIAS CusNotes
                  ENDDO                          // Found()
                  SELECT Prof
                   ApFlock( 3 )
                  DELETE
                  UNLOCK
               ENDIF
               mcontinue := "Y"
               IF PressedEsc()
                  EXIT           // RETURN NIL
               ENDIF
            ENDDO                                              // mcontinue 
            manother := "Y"
            LOOP
     
         CASE nselect = 4                 // Print Name Prof

            SCROLL()
            DISPBOX( 0, 0,  2,79, 2 )
            @  1, 6      SAY "Printing Prof"
            @  1,COL()+2 SAY Name->Name
            @  1,COL()+2 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                            +STR( YEAR(DATE() ), 5 )
            DISPBOX( 3, 1, 24,79, 2 )
            mstmm  := DATE()-6
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
            @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                         +STR( YEAR(DATE() ),5 )
            @  2, 0 SAY Name->Name
            nl := 4
            /*
            ntimetotal := 0
            SELECT Demand
            SET ORDER TO 1         // Operno LabNo
            GOTO TOP
            aPart_:={}
            nrecno := 0
            IF LASTREC() != 0
               DO WHILE Demand->( !EOF() )
                  IF demand->Operno = SPACE( 12 )
                     SKIP ALIAS demand
                     LOOP
                  ENDIF  
                  IF demand->Labno = SPACE( 12 )
                     SKIP ALIAS demand
                     LOOP
                  ENDIF  
                  IF Demand->Codeno != mcodeno
                     SKIP ALIAS Demand
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
                     @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                                +STR( YEAR(DATE() ),5 )
                     nl := 2
                  ENDIF                       // nl>npl
                  @ nl, 0 SAY Demand->Desc
                  @ nl,41 SAY Demand->Labno
                  @ nl,54 SAY Demand->Jobnum
                  @ nl,66 SAY Demand->Operno
                  nl++
                  IF Demand->Desc1 != SPACE( 40 )
                     @ nl, 4 SAY Demand->Desc1
                     nl++
                  ENDIF
                  IF Demand->Desc2 != SPACE( 40 )
                     @ nl, 4 SAY Demand->Desc2
                     nl++
                  ENDIF
                  IF Demand->Desc3 != SPACE( 40 )
                     @ nl, 4 SAY Demand->Desc3
                     nl++
                  ENDIF
                  IF Demand->Desc4 != SPACE( 40 )
                     @ nl, 4 SAY Demand->Desc4
                     nl++
                  ENDIF
                  coderef := Demand->Labno+STR( Recno(), 4 )
                  SELECT Cusnotes
                  cdetail := ""
                  SEEK coderef
                  IF FOUND()
                     @ nl, 0 SAY ""
                      Getdets( coderef )                           // XF_Memo2
                      FormP( cdetail,60,10 )                       // XF_Memo2
                  ENDIF                          // Found()
                  SELECT Demand
                  SKIP ALIAS Demand
               ENDDO                // EOF Demand
            ENDIF           // LastRec
            *** ENDIF           // Found
            nl++
            */
            ntimetotal := 0
            SELECT Prof
            SET ORDER TO 2            // Codeno
            GOTO TOP
            mcodeno := Name->Codeno
            SEEK mcodeno
            DO WHILE Prof->Codeno = mcodeno .AND. Prof->( !EOF() )
               IF Prof->Date < mstmm
                  SKIP ALIAS Prof
                  LOOP
               ENDIF
               IF Prof->Date > mendmm
                  SKIP ALIAS Prof
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
                  @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                             +STR( YEAR(DATE() ),5 )
                  @  2, 0 SAY Name->Name
                  nl := 4
               ENDIF                       // nl>npl
               @ nl, 0 SAY Prof->Codeno 
               @ nl,10 SAY Prof->Date
               @ nl,21 SAY Prof->Desc
               nl++
               @ nl, 2 SAY Prof->Operno
               @ nl,71 SAY Prof->Time PICTURE "9999.99"
               nl++
               IF Prof->Desc1 != SPACE( 40 ).OR. Prof->Partnum != SPACE( 20 )
                  @ nl,2 SAY SUBSTR( Prof->Partnum, 1,12 )+" "+Prof->Desc1;
                            +" "+STR( Prof->Rate, 4, 0 )
                  nl++
               ENDIF
               IF Prof->Desc2 != SPACE( 40 ).OR. Prof->FltRecno != SPACE( 20 )
                  @ nl,2 SAY Prof->Fltrecno+" "+Prof->Desc2
                  nl++
               ENDIF
               IF Prof->Desc3 != SPACE( 40 ).OR. Prof->FltRecno != SPACE( 20 )
                  @ nl,2 SAY Prof->Fltrecno+" "+Prof->Desc3
                  nl++
               ENDIF
               IF Prof->Desc4 != SPACE( 40 ).OR. Prof->FltRecno != SPACE( 20 )
                  @ nl,2 SAY Prof->Fltrecno+" "+Prof->Desc4
                  nl++
               ENDIF
               ntimetotal += Prof->Time
               SELECT Name
               SEEK Prof->Codeno 
               coderef := Prof->Codeno+SUBSTR( Name->Name, 1, 8 )
               SELECT Cusnotes
               cdetail := ""
               SEEK coderef
               IF FOUND()
                  @ nl, 0 SAY ""
                   Getdets( coderef )                           // XF_Memo2
                   FormP( cdetail,60,10 )                       // XF_Memo2
               ENDIF                          // Found()
               SELECT Prof
               SKIP ALIAS Prof
            ENDDO                // EOF Prof
            @ nl,68 SAY "----------"
            nl++
            @ nl,38 SAY mcodeno+" Total Time"
            @ nl,69 SAY ntimetotal PICTURE "99,999.99"
            nl++
            @ nl,68 SAY "=========="
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
            manother := "Y"
            LOOP

         CASE nselect = 5                 // Print ALL Names Prof

            SCROLL()
            DISPBOX( 0, 0,24,79, 2 )
            @ 24,60 SAY " DT411 "
            @  1,20 SAY "ALL Name demand Analysis"
            mstmm  := DATE()-6
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
            nl := 4
            /*
            ntimetotal := 0
            SELECT Demand
            SET ORDER TO 1         // Operno LabNo
            GOTO TOP
            aPart_:={}
            nrecno := 0
            IF LASTREC() != 0
               DO WHILE Demand->( !EOF() )
                  IF demand->Operno = SPACE( 12 )
                     SKIP ALIAS demand
                     LOOP
                  ENDIF  
                  IF demand->Labno = SPACE( 12 )
                     SKIP ALIAS demand
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
                     @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                                +STR( YEAR(DATE() ),5 )
                     nl := 2
                  ENDIF                       // nl>npl
                  @ nl, 0 SAY Demand->Desc
                  @ nl,41 SAY Demand->Labno
                  @ nl,54 SAY Demand->Jobnum
                  @ nl,66 SAY Demand->Operno
                  nl++
                  IF Demand->Desc1 != SPACE( 40 )
                     @ nl, 4 SAY Demand->Desc1
                     nl++
                  ENDIF
                  IF Demand->Desc2 != SPACE( 40 )
                     @ nl, 4 SAY Demand->Desc2
                     nl++
                  ENDIF
                  IF Demand->Desc3 != SPACE( 40 )
                     @ nl, 4 SAY Demand->Desc3
                     nl++
                  ENDIF
                  IF Demand->Desc4 != SPACE( 40 )
                     @ nl, 4 SAY Demand->Desc4
                     nl++
                  ENDIF
                  coderef := Demand->Labno+STR( Recno(), 4 )
                  SELECT Cusnotes
                  cdetail := ""
                  SEEK coderef
                  IF FOUND()
                     @ nl, 0 SAY ""
                      Getdets( coderef )                           // XF_Memo2
                      FormP( cdetail,60,10 )                       // XF_Memo2
                  ENDIF                          // Found()
                  SELECT Demand
                  SKIP ALIAS Demand
               ENDDO                // EOF Demand
            ENDIF           // LastRec
            */
            nl++
            ntimetotal := 0
            SELECT Prof
            SET ORDER TO 2         // Codeno
            GOTO TOP
            DO WHILE Prof->( !EOF() )
               IF Prof->Date < mstmm
                  SKIP ALIAS Prof
                  LOOP
               ENDIF
               IF Prof->Date > mendmm
                  SKIP ALIAS Prof
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
                  nl := 2
               ENDIF                       // nl>npl
               @ nl, 0 SAY Prof->Codeno 
               @ nl,10 SAY Prof->Date
               @ nl,21 SAY Prof->Desc
               @ nl,62 SAY Prof->Operno
               @ nl,71 SAY Prof->Time PICTURE "9999.99"
               nl++
               IF Prof->Desc1 != SPACE( 40 ).OR. Prof->Partnum != SPACE( 20 )
                  @ nl,2 SAY SUBSTR( Prof->Partnum, 1,12 )+" "+Prof->Desc1;
                            +" "+STR( Prof->Rate, 4, 0 )
                  nl++
               ENDIF
               IF Prof->Desc2 != SPACE( 40 ).OR. Prof->FltRecno != SPACE( 20 )
                  @ nl,2 SAY Prof->Fltrecno+" "+Prof->Desc2
                  nl++
               ENDIF
               IF Prof->Desc3 != SPACE( 40 ).OR. Prof->FltRecno != SPACE( 20 )
                  @ nl,2 SAY Prof->Fltrecno+" "+Prof->Desc3
                  nl++
               ENDIF
               IF Prof->Desc4 != SPACE( 40 ).OR. Prof->FltRecno != SPACE( 20 )
                  @ nl,2 SAY Prof->Fltrecno+" "+Prof->Desc4
                  nl++
               ENDIF
               ntimetotal += Prof->Time
               SELECT Name
               SEEK Prof->Codeno 
               coderef := Prof->Codeno+SUBSTR( Name->Name, 1, 8 )
               SELECT Cusnotes
               cdetail := ""
               SEEK coderef
               IF FOUND()
                  @ nl, 0 SAY ""
                   Getdets( coderef )                           // XF_Memo2
                   FormP( cdetail,60,10 )                       // XF_Memo2
               ENDIF                          // Found()
               SELECT Prof
               SKIP ALIAS Prof
            ENDDO                // EOF Prof
            @ nl,68 SAY "----------"
            nl++
            @ nl,48 SAY "Total Time"
            @ nl,69 SAY ntimetotal PICTURE "99,999.99"
            nl++
            @ nl,68 SAY "=========="
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
            manother := "Y"
            LOOP

         CASE nselect == 9
            SCROLL()
            aPart_:={}
            nrecno := 0
            coperno:= clabno:= cjobnum := SPACE( 12 )
            dDate    := DATE()-1
            cselect := "  "  
            cdate   := "N"
            SELECT Demand
            SET ORDER TO 1               // Operno
            GOTO TOP
            IF LASTREC() != 0
               coperno := SPACE( 12 )
               DO WHILE demand->( !EOF() )
                  IF demand->Operno = SPACE( 12 )
                     SKIP ALIAS demand
                     LOOP
                  ENDIF
                  IF demand->Operno = coperno
                     SKIP ALIAS demand
                     LOOP
                  ENDIF
                  AADD( aPart_,( demand->Operno;
                         +"        "+STR( RECNO(),6 ) ) )
                  coperno := demand->Operno
                  SKIP ALIAS demand
               ENDDO                       // demand EOF
            ENDIF                   // 0
            SCROLL( 0,65, 24,80 )
            DISPBOX(  0,65, 24,79, 2 )
            @ 1,67 SAY "Task Type" COLOR "RG+"
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum := ACHOICE( 2,67, 23,78,aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               coperno  := Demand->Operno
            ENDIF     // 0
            mprint := ApGetN( "Print Tasks" )
            IF mprint = "Y"  
               SCROLL()
               DISPBOX( 0, 0,  2,79, 2 )
               @  1, 6      SAY "Printing demand"
               @  1,COL()+2 SAY Name->Name
               @  1,COL()+2 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                               +STR( YEAR(DATE() ), 5 )
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
               @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                            +STR( YEAR(DATE() ),5 )
               @  2, 0 SAY coperno
               nl := 4
               ntimetotal := 0
               SELECT Demand
               SET ORDER TO 1         // Operno LabNo
               GOTO TOP
               SEEK coperno
               IF FOUND()
                  aPart_:={}
                  nrecno := 0
                  IF LASTREC() != 0
                     DO WHILE Demand->Operno = coperno .AND. Demand->( !EOF() )
                        IF demand->Operno = SPACE( 12 )
                           SKIP ALIAS demand
                           LOOP
                        ENDIF  
                        IF demand->Labno = SPACE( 12 )
                           SKIP ALIAS demand
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
                           @  0,60 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                                      +STR( YEAR(DATE() ),5 )
                           nl := 2
                        ENDIF                         // nl>npl
                        @ nl, 0 SAY Demand->Desc      // 40
                        @ nl,41 SAY Demand->Labno     // 12
                        @ nl,66 SAY Demand->Operno    // 12
                        nl++
                        @ nl,50 SAY Demand->Jobnum    // 20
                        nl++
                        IF Demand->Desc1 != SPACE( 40 )
                           @ nl, 4 SAY Demand->Desc1
                           nl++
                        ENDIF
                        IF Demand->Desc2 != SPACE( 40 )
                           @ nl, 4 SAY Demand->Desc2
                           nl++
                        ENDIF
                        IF Demand->Desc3 != SPACE( 40 )
                           @ nl, 4 SAY Demand->Desc3
                           nl++
                        ENDIF
                        IF Demand->Desc4 != SPACE( 40 )
                           @ nl, 4 SAY Demand->Desc4
                           nl++
                        ENDIF
                        coderef := Demand->Labno+STR( Recno(), 4 )
                        SELECT Cusnotes
                        cdetail := ""
                        SEEK coderef
                        IF FOUND()
                           @ nl, 0 SAY ""
                            Getdets( coderef )                           // XF_Memo2
                            FormP( cdetail,60,10 )                       // XF_Memo2
                        ENDIF                          // Found()
                        SELECT Demand
                        SKIP ALIAS Demand
                     ENDDO                // EOF Demand
                  ENDIF           // LastRec
               ENDIF           // Found
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
               ENDIF            // mwhere
            ENDIF             // mprint
            LOOP

      ENDCASE
      ***  manother := ApGetY( Message->Another )
   ENDDO               // Another

   RETURN NIL
   ****---------------  End LabourChris

   *********----------  END OF FILE XLF_QU10.PRG

