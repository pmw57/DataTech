   ***  JoKir09 23-09-11 21:39:20 

/*
   Program.....:                   XLF_QU9.PRG
   Author......: John Kirby
   Date........: 12/11/1993
   Functions...: JobOperate, GroupSelect, OperEditKey
              Operation, PartOperLst
*/

FUNCTION JobOperate()

   SCROLL()
   coperno := SPACE( 8 )        
   GroupSelect( @coperno )

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      SCROLL()
      aPart_:={}
      nrecno := 0
      ncount := 0
      SELECT Operate
      GOTO TOP
      DO WHILE Operate->( !EOF() )
         ***      IF SUBSTR( coperno, 1, 2 ) != "XX"
         IF Operate->Operno != coperno
            SKIP ALIAS Operate
            LOOP
         ENDIF
         ***      ENDIF           // XX
         ncount++  
         AADD( aPart_,Operate->Order;
            +" "+Operate->Desc;
            +" "+Operate->Priority;
            +" "+Operate->Operno;
            +" "+Operate->Print;
            +" "+Operate->ABC;
            +" "+Operate->Ckey;
            +" "+STR( Operate->Time );
            +"                             "+STR( RECNO(),6 ) )
         SKIP ALIAS Operate
      ENDDO                        // Operate EOF
      IF ncount <= 1
         SELECT Operate
         GOTO TOP
         aPart_:={}
         nrecno := 0
         DO WHILE Operate->( !EOF() )
            AADD( aPart_,Operate->Order;
               +" "+Operate->Desc;
               +" "+Operate->Priority;
               +" "+Operate->Operno;
               +" "+Operate->Print;
               +" "+Operate->ABC;
               +" "+Operate->Ckey;
               +" "+STR( Operate->Time );
               +"                             "+STR( RECNO(),6 ) )
            SKIP ALIAS Operate
         ENDDO                        // Operate EOF
      ENDIF            // ncount
      IF !EMPTY( aPart_ )
         DISPBOX( 0, 0, 2,79, 2 )
         @ 1, 8 SAY "Viewing Operate "+coperno COLOR "BG+"
         @ 1,50 SAY ncount PICTURE "99,999"       COLOR "BG+"
         DISPBOX( 3, 0,24,79, 2 )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         SCROLL(  16, 0, 24,80 )
         DISPBOX( 16, 0, 20,79, 2 )
         @ 18, 4      SAY Operate->Order         COLOR "BG+" 
         @ 18,COL()+2 SAY Operate->Desc          COLOR "BG+"
         @ 18,COL()+2 SAY Operate->Priority      COLOR "BG+"
         @ 18,COL()+2 SAY Operate->Operno        COLOR "BG+"
         @ 18,COL()+2 SAY Operate->ABC           COLOR "BG+"
         @ 18,COL()+2 SAY Operate->Print         COLOR "BG+"
         @ 18,COL()+2 SAY Operate->Time          PICTURE "9999"
         IF PressedEsc()
            RETURN NIL
         ENDIF
         coperno := Operate->Operno 
      ENDIF                        // Empty
      nselect  := 1
      SCROLL(  20, 0, 24,80 )
      DISPBOX( 20, 0, 24,79, 2 )
      @ 20, 8 SAY " -- Operate Menu -- "
      @ 21, 4      PROMPT "Another"
      @ 21,COL()+2 PROMPT "1. Add Operate"
      @ 21,COL()+2 PROMPT "2. Edit"
      @ 21,COL()+2 PROMPT "3. Organise Order"
      @ 21,COL()+2 PROMPT "4. Add Drawings"
      @ 22, 4      PROMPT "5. Edit Desc etc"
      @ 22,COL()+2 PROMPT "6. Print"
      @ 22,COL()+2 PROMPT "7. Exit"

      MENU TO nselect
      DO CASE
         CASE nselect == 8 .OR. PressedEsc()
            RETURN NIL
            ***         LOOP 
         CASE nselect == 1                // View   
            JobOperate()
            LOOP
         CASE nselect == 2                // Add Operation   
            ****         coperno := SPACE( 8 )
            ***          GroupSelect( @coperno )
            SCROLL() 
            SELECT Operate
            nl := 14
            cpriority := Operate->Priority
            corder    := Operate->Order
            cprint    := Operate->Print
            ckey      := Operate->Ckey
            cabc      := Operate->ABC
            ntime     := Operate->Time
             ApFlock( 3 )
            APPEND BLANK
            Operate->Operno   := coperno
            Operate->Date     := DATE()
            Operate->Priority := cpriority
            Operate->Order    := corder
            Operate->Print    := cprint
            Operate->Ckey     := ckey     
            Operate->Abc      := cabc
            UNLOCK
             ApRlock( 3 )
            cdesc     := Operate->Desc
            @ nl, 2      SAY coperno GET coperno PICTURE "@!"
            nl+=2 
            @ nl, 2      GET cdesc     PICTURE "@X"
            nl+=2
            @ nl, 2      GET cpriority PICTURE "@!"
            @ nl,COL()+2 SAY "Time =" GET ntime PICTURE "9999" 
            nl+=2
            @ nl, 2      SAY "Order"           GET corder PICTURE "@!"
            @ nl,COL()+2 SAY "Is this Heading" GET cabc   PICTURE "@!"
            nl+=2
            @ nl, 2      SAY "Print P/N"       GET cprint PICTURE "@!"
             READ
            SELECT Operate
             ApRlock( 3 )
            Operate->Order    := corder
            Operate->Operno   := coperno
            Operate->Desc     := cdesc
            Operate->Ckey     := ckey
            Operate->priority := cpriority
            Operate->ABC      := cabc
            Operate->Print    := cprint
            Operate->Time     := ntime
            UNLOCK
            LOOP

         CASE nselect == 3                // Edit/Delete  Process   
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
               SELECT Operate
               GOTO TOP
               namount := "N"
               nrecno  := 0
               aPart_  := {}
               DO WHILE Operate->( !EOF() ) 
                  IF Operate->Operno != coperno
                     SKIP ALIAS Operate
                     LOOP
                  ENDIF
                  AADD( aPart_,( Operate->Order;
                     +" "+Operate->Desc;
                     +" "+Operate->Priority;
                     +" "+STR( Operate->Time);
                     +"    Delete";
                     +"                                       "+STR( RECNO(),6 ) ) )
                  SKIP ALIAS Operate
               ENDDO                         // Fault EOF
               SCROLL() 
               DISPBOX( 0, 0, 2,79, 2 )
               @  1, 3 SAY Operate->Operno COLOR "RG+"
               @  1,20 SAY "Edit Operate List" COLOR "BG+"
               @  1,62 SAY "Esc to Exit"       COLOR "BG+"
               DISPBOX( 3, 0, 23,79, 2 )
               IF !EMPTY( aPart_ )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE( 4, 2, 22,77, aPart_,,"AFUNC" )
                  IF LASTKEY() = 27
                     EXIT
                  ENDIF  
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
               ENDIF
               ApRLock( 3 )
               @ ROW(), 2 GET Operate->Order    PICTURE "@!"
               @ ROW(), 6 GET Operate->Desc     PICTURE "@X"
               @ ROW(),48 GET Operate->Priority PICTURE "@!"
               @ ROW(),59 GET Operate->Time     PICTURE "9999"
               @ ROW(),71 GET namount VALID( namount $ "NY " ) PICTURE "@!"
                READ
               IF namount = "Y"
                  SELECT Operate
                  DELETE
                  UNLOCK
               ENDIF
               UNLOCK
               IF LASTKEY() = 27
                    mcontinue := "N"
                ENDIF  
               LOOP
            ENDDO
            LOOP

         CASE nselect == 4                        // Organise Order
            *** mok := "Y"
            *** DO WHILE mok = "Y"

            aPart_:={}
            nrecno  := 0
            SELECT Operate
            GOTO TOP
            DO WHILE Operate->( !EOF() )
               IF Operate->Operno != coperno
                  SKIP ALIAS Operate
                  LOOP
               ENDIF
               ***      IF Operate->Print = " "
               ***         SKIP ALIAS Operate
               ***         LOOP
               ***      ENDIF
               AADD( aPart_,Operate->Order;
                  +" "+Operate->Desc;
                  +" "+Operate->Priority;
                  +" "+Operate->ABC;
                  +" "+Operate->Print;
                  +" "+Operate->Ckey;
                  +" "+STR( Operate->Time );
                  +"                      "+STR( RECNO(),6 ) )
               SKIP ALIAS Operate
            ENDDO                        // Operate EOF
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               SCROLL(  3, 0, 24,80 )
               DISPBOX( 3, 0, 24,79, 2 )
               @  3,60 SAY "   Head   Print  "
               anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
               IF LASTKEY() = 27
                  EXIT
               ENDIF
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
                ApRLock( 3 )   
               @ ROW(), 2 GET Operate->Order    PICTURE "@!"
               @ ROW(), 6 GET Operate->Desc     PICTURE "@X"
               @ ROW(),65 GET Operate->Priority PICTURE "@!"
               @ ROW(),70 GET Operate->Print    PICTURE "!"
               @ ROW(),72 GET Operate->Time     PICTURE "9999"
                READ   
               UNLOCK
            ENDIF                        // Empty
         ***  ENDDO                                // mok
         LOOP

      CASE nselect == 5                        // Drawing
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @ 1, 8 SAY "Viewing Drawings"
         aPart_:={}
         nrecno   := 0
         SELECT Drawing
         GOTO TOP
         DO WHILE Drawing->( !EOF() )
            AADD( aPart_,Drawing->Drawno;
               +" "+Drawing->Desc;
               +"                             "+STR( RECNO(),6 ) )
            SKIP ALIAS Drawing
         ENDDO                        // Drawing EOF
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            SCROLL(  3, 0, 24,80 )
            DISPBOX( 3, 0, 24,79, 2 )
            @ 3, 6 SAY " F2 To Add "
            anum := ACHOICE(  4, 4, 23,76, aPart_,,"AFUNC" )
            IF LASTKEY() == -1
               JobDraw()                    // JobDem
            ENDIF
            IF PressedEsc()
               RETURN NIL
            ENDIF
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            SCROLL( 19, 0, 24,80 )
            DISPBOX( 19, 0, 24,79, 2 )
            nl := 21
             ApFlock( 3 )
            @ nl,10 SAY "Desc" GET Drawing->Desc   PICTURE "@X"
            nl++  
            @ nl,10 SAY "Code" GET Drawing->Drawno PICTURE "@!"
             READ
            UNLOCK
         ENDIF                        // Empty
         SELECT Operate
          ApFlock( 3 )
         APPEND BLANK
         Operate->Date     := DATE()
         Operate->Ckey     := Drawing->Drawno  
         Operate->Desc     := Drawing->Desc
         Operate->Operno   := coperno
         Operate->Priority := "A Draw"
         Operate->Order    := " D"
         Operate->Print    := "P"
         UNLOCK
         LOOP

         CASE nselect == 6                        // Edit Desc etc
            PlanEditKey( @coperno )
            LOOP

         CASE nselect == 7                        // Print
            mok := ApGetY( "Print Only Group" )
            mwhere := "S"

            PrintSel( mwhere )

            IF mwhere == "P"
               npl := 56
            ELSE
               npl := 22
            ENDIF
            nl := 0
            nTotTime := 0
            @ nl, 0 SAY Control->U_Name
            @ nl,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
               +STR( YEAR(DATE() ),5 )
            nl+=2
            ***        @ nl, 2 SAY coperno+" Check Off List              Job # _______________"
            ***        nl+=2
            ***        @ nl,20 SAY "Customer _____________________________"
            ***        nl+=2
            ***        @ nl, 2 SAY "Leading Hand  __________________"
            ***        nl+=2
            ntimetotal:= ntime := 0
            SELECT Operate
            GOTO TOP
            DO WHILE Operate->( !EOF() )
               IF mok = "Y" 
                  IF Operate->Operno != coperno
                     SKIP ALIAS Operate
                     LOOP
                  ENDIF
               ENDIF             // mok 
               ***           IF Operate->Print = " "
               ***              SKIP ALIAS Operate
               ***              LOOP
               ***           ENDIF
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
               ***           IF Operate->ABC != " "
               ***              nl++
               ***              @ nl, 1 SAY Operate->Operno+" "+Operate->Desc
               ***              @ nl,41 SAY "Done By   Checked By   Rework   Checked"                               
               ***              nl++
               ***             ELSE
               @ nl, 0 SAY Operate->Order+" "+Operate->Desc+" "+Operate->Operno
               @ nl,52 SAY Operate->Time PICTURE "9999"
               @ nl,56 SAY "____________"
               nl++
               ***           ENDIF 
               SKIP ALIAS Operate
            ENDDO                        // Operate EOF
            IF mwhere = "S"
               INKEY()
               mok := "N"
               DO WHILE mok = "N"
                  mok := ApReadN()
               ENDDO
              ELSE
               EndPrint()
            ENDIF
            LOOP
      ENDCASE                 // nselect
      ***    manother := ApGetY( Message->Another )
      *** ENDDO                                       // manother

      mcontinue := ApGetY( Message->Another+" Process" )

   ENDDO             // mcontinue

   RETURN NIL
   ***--- End JobOperate( mjobnum )

   *****-------------------------------------------------------------------------

FUNCTION GroupSelect( coperno )
   coperno := SPACE( 8 )
   SCROLL( 0,40, 24,80 )
   DISPBOX( 0,41, 24,79, 2 )
   SELECT Message
   GOTO TOP
   mchoice := 0
   @  5,44 SAY Message->Operno01 PICTURE "@!"
   @  6,44 SAY Message->Operno02 PICTURE "@!"
   @  7,44 SAY Message->Operno03 PICTURE "@!"
   @  8,44 SAY Message->Operno04 PICTURE "@!"
   @  9,44 SAY Message->Operno05 PICTURE "@!"
   @ 10,44 SAY Message->Operno06 PICTURE "@!"
   @ 11,44 SAY Message->Operno07 PICTURE "@!"
   @ 12,44 SAY Message->Operno08 PICTURE "@!"
   @ 13,44 SAY Message->Operno09 PICTURE "@!"
   @ 14,44 SAY Message->Operno10 PICTURE "@!"
   @ 15,44 SAY Message->Operno11 PICTURE "@!"
   @ 16,44 SAY Message->Operno12 PICTURE "@!"
   @ 17,44 SAY Message->Operno13 PICTURE "@!"
   @ 18,44 SAY Message->Operno14 PICTURE "@!"
   @ 19,44 SAY Message->Operno15 PICTURE "@!"
   @ 20,44 SAY Message->Operno16 PICTURE "@!"
   @ 21,44 SAY Message->Operno17 PICTURE "@!"
   @ 22,44 SAY Message->Operno18 PICTURE "@!"
   @  5,64 SAY Message->Operno20 PICTURE "@!"
   @  6,64 SAY Message->Operno21 PICTURE "@!"
   @  7,64 SAY Message->Operno22 PICTURE "@!"
   @  8,64 SAY Message->Operno23 PICTURE "@!"
   @  9,64 SAY Message->Operno24 PICTURE "@!"
   @ 10,64 SAY Message->Operno25 PICTURE "@!"
   @ 11,64 SAY Message->Operno26 PICTURE "@!"
   @ 12,64 SAY Message->Operno27 PICTURE "@!"
   @ 13,64 SAY Message->Operno28 PICTURE "@!"
   @ 14,64 SAY Message->Operno29 PICTURE "@!"
   @ 15,64 SAY Message->Operno30 PICTURE "@!"
   @ 16,64 SAY Message->Operno31 PICTURE "@!"
   @ 17,64 SAY Message->Operno32 PICTURE "@!"
   @ 18,64 SAY Message->Operno33 PICTURE "@!"
   @ 19,64 SAY Message->Operno34 PICTURE "@!"
   @ 20,64 SAY Message->Operno35 PICTURE "@!"
   @ 21,64 SAY Message->Operno36 PICTURE "@!"
    ***           @ 22,64 SAY Message->Operno37 PICTURE "@!"
   @ 3,44 SAY "X = All Z = Edit Esc = Exit" COLOR "RG+"
   @  5,44 PROMPT "1. "+Message->Operno01 
   @  6,44 PROMPT "2. "+Message->Operno02      
   @  7,44 PROMPT "3. "+Message->Operno03      
   @  8,44 PROMPT "4. "+Message->Operno04      
   @  9,44 PROMPT "5. "+Message->Operno05      
   @ 10,44 PROMPT "6. "+Message->Operno06      
   @ 11,44 PROMPT "7. "+Message->Operno07      
   @ 12,44 PROMPT "8. "+Message->Operno08      
   @ 13,44 PROMPT "9. "+Message->Operno09      
   @ 14,44 PROMPT "10."+Message->Operno10      
   @ 15,44 PROMPT "11."+Message->Operno11      
   @ 16,44 PROMPT "12."+Message->Operno12      
   @ 17,44 PROMPT "13."+Message->Operno13      
   @ 18,44 PROMPT "14."+Message->Operno14   
   @ 19,44 PROMPT "15."+Message->Operno15 
   @ 20,44 PROMPT "16."+Message->Operno16 
   @ 21,44 PROMPT "17."+Message->Operno17 
   @ 22,44 PROMPT "18."+Message->Operno18 
   @  5,64 PROMPT "19."+Message->Operno20 
   @  6,64 PROMPT "20."+Message->Operno21 
   @  7,64 PROMPT "21."+Message->Operno22 
   @  8,64 PROMPT "22."+Message->Operno23 
   @  9,64 PROMPT "23."+Message->Operno24 
   @ 10,64 PROMPT "24."+Message->Operno25 
   @ 11,64 PROMPT "25."+Message->Operno26 
   @ 12,64 PROMPT "26."+Message->Operno27 
   @ 13,64 PROMPT "27."+Message->Operno28 
   @ 14,64 PROMPT "28."+Message->Operno29 
   @ 15,64 PROMPT "29."+Message->Operno30 
   @ 16,64 PROMPT "30."+Message->Operno31 
   @ 17,64 PROMPT "31."+Message->Operno32      
   @ 18,64 PROMPT "32."+Message->Operno33      
   @ 19,64 PROMPT "33."+Message->Operno34      
   @ 20,64 PROMPT "34."+Message->Operno35      
   @ 21,64 PROMPT "35."+Message->Operno36      
    ***           @ 22,64 PROMPT "0."+Message->Operno37
   @ 23,64 PROMPT "Z Edit GROUPS"
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
      CASE mchoice == 19
         coperno := Message->Operno20
      CASE mchoice == 20
         coperno := Message->Operno21
      CASE mchoice == 21
         coperno := Message->Operno22
      CASE mchoice == 22
         coperno := Message->Operno23
      CASE mchoice == 23
         coperno := Message->Operno24
      CASE mchoice == 24
         coperno := Message->Operno25
      CASE mchoice == 25
         coperno := Message->Operno26
      CASE mchoice == 26
         coperno := Message->Operno27
      CASE mchoice == 27
         coperno := Message->Operno28
      CASE mchoice == 28
         coperno := Message->Operno29
      CASE mchoice == 29
         coperno := Message->Operno30
      CASE mchoice == 30
         coperno := Message->Operno31
      CASE mchoice == 31
         coperno := Message->Operno32
      CASE mchoice == 32
         coperno := Message->Operno33
      CASE mchoice == 33
         coperno := Message->Operno34
      CASE mchoice == 34
         coperno := Message->Operno35
      CASE mchoice == 35
         coperno := Message->Operno36
      CASE mchoice == 36
         ***               coperno := Message->Operno37
         ***            CASE mchoice == 37
         SCROLL()
         SELECT Message
         GOTO TOP
         mchoice := 0  //coperno := SPACE( 8 )
         DISPBOX(  4,35, 24,79, 2 )
          ApRLock( 3 )   
         @  3,40 SAY "Groups" COLOR "BG+"
         @  5,40 SAY "1.  " GET Message->Operno01 PICTURE "@!"
         @  6,40 SAY "2.  " GET Message->Operno02 PICTURE "@!"
         @  7,40 SAY "3.  " GET Message->Operno03 PICTURE "@!"
         @  8,40 SAY "4.  " GET Message->Operno04 PICTURE "@!"
         @  9,40 SAY "5.  " GET Message->Operno05 PICTURE "@!"
         @ 10,40 SAY "6.  " GET Message->Operno06 PICTURE "@!"
         @ 11,40 SAY "7.  " GET Message->Operno07 PICTURE "@!"
         @ 12,40 SAY "8.  " GET Message->Operno08 PICTURE "@!"
         @ 13,40 SAY "9.  " GET Message->Operno09 PICTURE "@!"
         @ 14,40 SAY "10. " GET Message->Operno10 PICTURE "@!"
         @ 15,40 SAY "11. " GET Message->Operno11 PICTURE "@!"
         @ 16,40 SAY "12. " GET Message->Operno12 PICTURE "@!"
         @ 17,40 SAY "13. " GET Message->Operno13 PICTURE "@!"
         @ 18,40 SAY "14. " GET Message->Operno14 PICTURE "@!"
         @ 19,40 SAY "15. " GET Message->Operno15 PICTURE "@!"
         @ 20,40 SAY "16. " GET Message->Operno16 PICTURE "@!"
         @ 21,40 SAY "17. " GET Message->Operno17 PICTURE "@!"
         @ 22,40 SAY "18. " GET Message->Operno18 PICTURE "@!"
         @  5,63 SAY "19. " GET Message->Operno20 PICTURE "@!"
         @  6,63 SAY "20. " GET Message->Operno21 PICTURE "@!"
         @  7,63 SAY "21. " GET Message->Operno22 PICTURE "@!"
         @  8,63 SAY "22. " GET Message->Operno23 PICTURE "@!"
         @  9,63 SAY "23. " GET Message->Operno24 PICTURE "@!"
         @ 10,63 SAY "24. " GET Message->Operno25 PICTURE "@!"
         @ 11,63 SAY "25. " GET Message->Operno26 PICTURE "@!"
         @ 12,63 SAY "26. " GET Message->Operno27 PICTURE "@!"
         @ 13,63 SAY "27. " GET Message->Operno28 PICTURE "@!"
         @ 14,63 SAY "29. " GET Message->Operno29 PICTURE "@!"
         @ 15,63 SAY "30. " GET Message->Operno30 PICTURE "@!"
         @ 16,63 SAY "31. " GET Message->Operno31 PICTURE "@!"
         @ 17,63 SAY "32. " GET Message->Operno32 PICTURE "@!"
         @ 18,63 SAY "33. " GET Message->Operno33 PICTURE "@!"
         @ 19,63 SAY "34. " GET Message->Operno34 PICTURE "@!"
         @ 20,63 SAY "35. " GET Message->Operno35 PICTURE "@!"
         @ 21,63 SAY "36. " GET Message->Operno36 PICTURE "@!"
         ***           @ 22,63 SAY "0. " GET Message->Operno37 PICTURE "@!"
         READ
         UNLOCK
         IF PressedEsc()
           RETURN NIL
         ENDIF
         coperno := SPACE( 8 )
         GroupSelect( @coperno )
   ENDCASE
   DO CASE
     CASE coperno = SPACE( 8 )
        coperno = "XX      "
     CASE SUBSTR( coperno, 1, 2 ) = "AA"
        coperno = "XX      "  
   ENDCASE
   RETURN coperno

   ***--- End GroupSelect

   *****-------------------------------------------------------------------------

FUNCTION OperEditKey()

   manother = "Y"
   DO WHILE manother = "Y"  
      aPart_:={}
      nrecno  := 0
      SELECT PartOper
      SET ORDER TO 2                       // Operno+Order
      GOTO TOP
      ***   SEEK coperno
      ***   DO WHILE PartOper->Operno = coperno .AND. PartOper->( !EOF() )
      DO WHILE PartOper->( !EOF() )
      ***      IF PartOper->Task != " "
      ***         SKIP ALIAS PartOper
      ***         LOOP
      ***      ENDIF 
      ***      IF PartOper->Drawno != SPACE( 8 )
      ***         SKIP ALIAS PartOper
      ***         LOOP
      ***      ENDIF 
         cdesc    := PartOper->Desc
         AADD( aPart_,cdesc;
                      +"  "+PartOper->Operno;
                      +"  "+PartOper->Adminno;
                      +"  "+PartOper->Order;
                      +"                    "+STR( RECNO(),6 ) )
         SKIP ALIAS PartOper
      ENDDO                        // PartOper EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL()
         DISPBOX( 0, 0, 24,79, 2 )
         @  0, 4 SAY " BLANK TO DELETE  " COLOR "RG+"
         @  0,35 SAY " Esc to Exit  "     COLOR "BG+"
         anum := ACHOICE(  1, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
            cdesc    := PartOper->Desc
            @ ROW(), 3 GET cdesc PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
             READ
            IF PressedEsc()
               RETURN NIL
            ENDIF
            SELECT PartOper
             ApRLock( 3 )
            PartOper->Order   := UPPER( SUBSTR( cdesc, 1, 2 ) )
            PartOper->Adminno := UPPER( SUBSTR( cdesc, 1, 8 ) )
            PartOper->Desc    := cdesc
            IF cdesc = "          "   // SPACE( 8 )
               DELETE
            ENDIF
            UNLOCK
       ENDIF                        // Empty
       IF LASTKEY() = 27
          EXIT
       ENDIF 
     ENDDO                         // manother

   RETURN NIL
   ***--- End OperEditKey()

   *****-------------------------------------------------------------------------

FUNCTION Operation()

   coperno := "        "      //Debit->Operno     //       SPACE( 8 )
   SCROLL()
   coperno := SPACE( 8 )
    GroupSelect( @coperno )
   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      aPart_:={}
      nrecno  := 0
      SELECT PartOper
      SET ORDER TO 2                       // Operno+Order
      GOTO TOP
      ncount := 0
      DO WHILE PartOper->( !EOF() )
         IF SUBSTR( coperno, 1, 2 ) != "XX"
            IF PartOper->Operno != coperno
               SKIP ALIAS PartOper
               LOOP
            ENDIF
         ENDIF           // XX
         ncount++  
         AADD( aPart_,PartOper->Adminno;
                      +" "+SUBSTR( PartOper->Partnum, 1,16 );
                      +" "+SUBSTR( PartOper->Desc, 1, 30 );
                      +" "+PartOper->Operno;
                      +" "+PartOper->Order;
                      +" "+STR( PartOper->Time, 8, 2 );
                      +"                    "+STR( RECNO(),6 ) )
         SKIP ALIAS PartOper
      ENDDO                        // PartOper EOF
      IF ncount <= 0
         aPart_:={}
         nrecno  := 0
         SELECT PartOper
         GOTO TOP
         DO WHILE PartOper->( !EOF() )
            AADD( aPart_,PartOper->Adminno;
                         +" "+SUBSTR( PartOper->Partnum, 1,16 );
                         +" "+SUBSTR( PartOper->Desc, 1, 30 );
                         +" "+PartOper->Operno;
                         +" "+PartOper->Order;
                         +" "+STR( PartOper->Time, 8, 2 );
                         +"                    "+STR( RECNO(),6 ) )
            SKIP ALIAS PartOper
         ENDDO                        // PartOper EOF
      ENDIF                     // ncount
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @ 1, 6      SAY "Viewing Procedures" COLOR "BG+"
         @ 1,COL()+2 SAY ncount PICTURE "99,999" COLOR "BG+" 
         @ 1,COL()+4 SAY coperno+"    Esc or Enter for Menu" COLOR "BG+"
         DISPBOX( 3, 1, 24,79, 2 )
         anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         SCROLL( 13, 0, 19,80 ) 
         DISPBOX( 13, 1, 19,79, 2 )
         @ 14, 4      SAY PartOper->Order+" "+PartOper->Operno COLOR "BG+"
         @ 14,COL()+2 SAY SUBSTR( PartOper->Partnum, 1,16 );
                          +" "+TRIM( PartOper->Desc )+" "+TRIM( PartOper->Adminno )
         @ 14,COL()+2 SAY STR( PartOper->Time, 8, 2 )
       ENDIF                        // Empty
      IF EMPTY( aPart_ )
         @ 15,10 SAY "No Procedures Add First" COLOR "G+"
      ENDIF
      SCROLL( 18, 0, 24,80)
      DISPBOX( 18, 1, 24,79, 2 )
      mchoice := 1
      @ 18, 6 SAY " --- Process --- "+coperno COLOR "BG+"
      @ 19, 5      PROMPT "1. Delete"
      @ 19,COL()+2 PROMPT "2. Order"
      @ 19,COL()+2 PROMPT "3. Add New"
      @ 19,COL()+2 PROMPT "4. Add Process"
      @ 19,COL()+2 PROMPT "5. Print"

      @ 21, 5      PROMPT "6. Another Group"
      @ 21,COL()+2 PROMPT "7. Edit Groups"
      @ 21,COL()+2 PROMPT "8. Drawings"  
      @ 21,COL()+2 PROMPT "9. Process"
      @ 21,COL()+2 PROMPT "Admin"
      @ 23, 5      PROMPT "JC Report"
      @ 23,COL()+2 PROMPT "Part Insert"
      @ 23,COL()+2 PROMPT "Edit Key Desc"
      @ 23,COL()+2 PROMPT "Edit PartOper"
      MENU TO mchoice
      DO CASE
         CASE PressedEsc()
              RETURN NIL

         CASE mchoice == 1             // Edit/Delete
            IF EMPTY( aPart_ )
               @ 16,10 SAY "No Entries Must Add First"
               WAIT 
               EXIT
            ENDIF
            SCROLL( 14, 0, 24,80 )
            DISPBOX( 14, 1, 24,79, 2 )
            nl := 15
            cdesc    := PartOper->Desc
            ntime    := PartOper->Time
            IF SUBSTR( coperno, 1, 2 ) != "XX"
               coperno  := PartOper->Operno
            ENDIF           // XX  
            ckey     := SUBSTR( cdesc, 1, 8 )
            ckeydesc := SUBSTR( cdesc,10,32 )
            mok := "N"
            @ nl, 5      SAY ckey PICTURE "!!!!!!!!"
            @ nl,COL()+2 SAY coperno PICTURE "@!"
            nl+=2
            @ nl, 5      SAY ckeydesc PICTURE "@X" COLOR "G+"
            cstring := "Do You Want To DELETE " 
            mok := ApGetY( "Do you want to Delete" )
 ****            mok := ApCheck( cstring )            // _AppX.PRG
            IF mok == "Y"
                ApFLock( 3 )
               DELETE
               UNLOCK
               LOOP 
            ENDIF 
         CASE mchoice == 2             // Order
            IF EMPTY( aPart_ )
               @ 16,10 SAY "No Entries Must Add First"
               WAIT 
               EXIT
            ENDIF
   manother = "Y"
   DO WHILE manother = "Y"  
      aPart_:={}
      nrecno  := 0
      SELECT PartOper
      SET ORDER TO 2                       // Operno+Order
      GOTO TOP
      SEEK coperno
      IF SUBSTR( coperno, 1, 2 ) != "XX"
         IF !FOUND()
             ApFlock( 3 )
            APPEND BLANK
            PartOper->Date    := DATE()
            PartOper->Operno  := coperno
            PartOper->Order   := "00"
            PartOper->Partnum := "    DAILY"
            PartOper->Desc    := "Mon    Tue    Wed    Thur   Frid"
            UNLOCK 
         ENDIF
      ENDIF             // XX 
      GOTO TOP
      ***   DO WHILE PartOper->Operno = coperno .AND. PartOper->( !EOF() )
      DO WHILE PartOper->( !EOF() )
         IF PartOper->Task != " "
            SKIP ALIAS PartOper
            LOOP
         ENDIF 
         IF SUBSTR( coperno, 1, 2 ) != "XX"
            IF PartOper->Operno != coperno
               SKIP ALIAS PartOper
               LOOP
            ENDIF
         ENDIF           // XX  
         AADD( aPart_,PartOper->Order;
                      +" "+SUBSTR( PartOper->Partnum, 1,16 );
                      +" "+PartOper->Desc;
                      +" "+STR( PartOper->Time, 8, 2 );
                      +"  "+PartOper->Adminno;
                      +"  "+PartOper->Operno;
                      +"                   "+STR( RECNO(),6 ) )
         SKIP ALIAS PartOper
      ENDDO                        // PartOper EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL()
         DISPBOX( 0, 1, 24,79, 2 )
         @ 0, 4 SAY "  Esc to Exit  " COLOR "BG+"
         @ 0,30 SAY "  "+coperno+"  " COLOR "BG+"
         anum := ACHOICE(  1, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         corder := PartOper->Order
         cpart  := SUBSTR( PartOper->Partnum, 1,16 )
         cdesc  := PartOper->Desc
         ntime  := PartOper->Time
         @ ROW(), 2 GET corder PICTURE "@!"
          READ   
          ApRLock( 3 )   
         PartOper->Order   := corder  
         PartOper->Partnum := cpart
         PartOper->Desc    := cdesc
         PartOper->Time    := ntime
         UNLOCK
       ENDIF                        // Empty
       IF LASTKEY() = 27
          EXIT
       ENDIF 
     ENDDO                         // manother
    
         CASE mchoice == 3                     // Add New
            mpart := SPACE( 16 )
            aPart_:={}
            nrecno  := 0
            SCROLL(  0,21, 24,80 ) 
            DISPBOX( 0,21, 24,79, 2 )
            SELECT PartOper
            SET ORDER TO 1                    // Partnum
            GOTO TOP
            mdesc := PartOper->Desc
            mpart := SUBSTR( PartOper->Partnum, 1,16 )
            DO WHILE PartOper->( !EOF() )
               IF PartOper->Task != " "
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF 
               IF SUBSTR( PartOper->Partnum, 1,16 ) = mpart
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               AADD( aPart_,SUBSTR( PartOper->Partnum, 1,16 );
                      +" "+PartOper->Desc;
                      +" "+STR( PartOper->Time, 8, 2 );
                      +"                     "+STR( RECNO(),6 ) )
               mpart := SUBSTR( PartOper->Partnum, 1,16 ) 
               SKIP ALIAS PartOper
            ENDDO                        // PartOper EOF
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum := ACHOICE(  1, 23, 23,78, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               mpart := SUBSTR( PartOper->Partnum, 1,16 )
            ENDIF                        // Empty
              ApFlock( 3 )
             APPEND BLANK
             PartOper->Date    := DATE()
             PartOper->Operno  := coperno
             PartOper->Partnum := mpart
              UNLOCK
            SCROLL( 14, 0, 24,80 )
            DISPBOX( 14, 1, 24,79, 2 )
            nl := 15
            cdesc    := PartOper->Desc
            ntime    := PartOper->Time
            ckey     := SUBSTR( cdesc, 1, 8 )
            ckeydesc := SUBSTR( cdesc,10,32 )
            @ nl, 5      GET ckey PICTURE "!!!!!!!!"
            @ nl,COL()+2 SAY "Key Characters First 8"
            @ nl,COL()+2 SAY "Operno" GET coperno PICTURE "@!"
            nl++ 
            @ nl, 6      SAY "Chassis ,Floor   ,Racks   ,Office  ,Stores  , etc"
            nl++
            @ nl, 5      GET ckeydesc PICTURE "@X"        // K for delete
            @ nl,COL()+2 SAY "Time in Hrs" GET ntime   PICTURE "99999.99"
             READ
            cdesc := ckey+" "+ckeydesc
            IF PressedEsc()
               RETURN NIL
            ENDIF
            SELECT PartOper
             ApRLock( 3 )
            PartOper->Time    := ntime
            PartOper->Order   := UPPER( SUBSTR( ckey, 1, 1 ) );
                                 +UPPER( SUBSTR( ckeydesc, 1, 1 ) )
            PartOper->Adminno := UPPER( SUBSTR( cdesc, 1, 8 ) )
            PartOper->Operno  := coperno
            PartOper->Desc    := cdesc
            UNLOCK
            LOOP

         CASE mchoice == 4                 // Add Process
   manother := "Y"
   DO WHILE manother = "Y"

      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @ 1, 8 SAY "Viewing Part Process"
      aPart_:={}
      nrecno := 0
      SELECT Operate
      GOTO TOP
      DO WHILE Operate->( !EOF() )
         AADD( aPart_,Operate->Operno;
                      +" "+Operate->Desc;
                      +" "+Operate->Ckey;
                      +" "+STR( Operate->Time, 8, 2 );
                      +" "+Operate->Order;
                      +"                                   "+STR( RECNO(),6 ) )
         SKIP ALIAS Operate
      ENDDO                        // Operate EOF
      IF !EMPTY( aPart_ )
         DISPBOX( 3, 1,24,79, 2 )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         IF PressedEsc()
            EXIT
         ENDIF
      ENDIF                        // Empty
      aPart_:={}
      SELECT PartOper
      GOTO TOP
      DO WHILE PartOper->( !EOF() )
         IF PartOper->Adminno = SPACE( 8 )
            SKIP ALIAS PartOper
            LOOP
         ENDIF
         IF PartOper->Operno != coperno
            SKIP ALIAS PartOper
            LOOP
         ENDIF
         AADD( aPart_,PartOper->Order;
                      +" "+PartOper->Adminno;
                      +" "+PartOper->Desc;
                      +" "+STR( PartOper->Time, 8, 2 );
                      +" "+PartOper->Operno;
                      +"                          "+STR( RECNO(),6 ) )
         SKIP ALIAS PartOper
      ENDDO                        // PartOper EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @  1, 6      SAY Operate->Operno COLOR "BG+" 
         @  1,COL()+2 SAY TRIM( Operate->Desc )   COLOR "BG+"
         @  1,COL()+1 SAY coperno+" Esc/Enter" 
         DISPBOX( 3, 1, 19,79, 2 )
         anum := ACHOICE(  4, 3, 18,78, aPart_,,"AFUNC" )
       ENDIF                        // Empty
       SELECT PartOper
       manother := ApGetN( "Another Process Esc to Cancel" )          
       IF PressedEsc()
          EXIT
       ENDIF
              ApFlock( 3 )
             APPEND BLANK
             PartOper->Date    := DATE()
             PartOper->Operno  := coperno
             PartOper->Adminno := Operate->Operno
             PartOper->Desc    := Operate->Desc
             PartOper->Partnum := Operate->Operno
             PartOper->Order   := Operate->Order
             PartOper->Time    := Operate->Time
             UNLOCK 
      ENDDO                 // another
             LOOP

         CASE mchoice == 5            // Print
               SCROLL( 19, 0, 24,80)
               DISPBOX( 19, 1, 24,79, 2 )
                OperPrint()
              LOOP

         CASE mchoice == 6             // Another Group
              Operation()

         CASE mchoice == 7            // Edit Group Names
      ***           SCROLL()
      ***           Operation()
              coperno := SPACE( 8 )
              GroupSelect()
         CASE mchoice == 8                  // Drawings
            JobDraw()                       // JobDem
            LOOP
         CASE mchoice == 9                  // Recources
             RecourceAdd()                     // Above
            LOOP

         CASE mchoice == 10                 // Add Admin
   manother := "Y"
   DO WHILE manother = "Y"

      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @ 1, 8 SAY "Viewing Admin"
      aPart_:={}
      nrecno := 0
      SELECT Admin
      GOTO TOP
      DO WHILE Admin->( !EOF() )
         AADD( aPart_,Admin->Adminno;
                      +" "+Admin->Desc;
                      +"                   "+STR( RECNO(),6 ) )
         SKIP ALIAS Admin
      ENDDO                        // Admin EOF
      IF !EMPTY( aPart_ )
         DISPBOX( 3, 1,24,79, 2 )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         IF PressedEsc()
            EXIT
         ENDIF
         SELECT PartOper
          ApFlock( 3 )
         APPEND BLANK
         PartOper->Date    := DATE()
         PartOper->Operno  := coperno
         PartOper->Adminno := Admin->Adminno
         PartOper->Desc    := Admin->Desc
         PartOper->Order   := UPPER( SUBSTR( Admin->Adminno, 1, 1 ) )+"1" 
         UNLOCK 
      ENDIF                        // Empty
      aPart_:={}
      SELECT PartOper
      GOTO TOP
      DO WHILE PartOper->( !EOF() )
         IF PartOper->Adminno = SPACE( 8 )
            SKIP ALIAS PartOper
            LOOP
         ENDIF
         IF PartOper->Operno != coperno
            SKIP ALIAS PartOper
            LOOP
         ENDIF
         AADD( aPart_,PartOper->Order;
                      +" "+PartOper->Adminno;
                      +" "+PartOper->Desc;
                      +" "+STR( PartOper->Time, 8, 2 );
                      +" "+PartOper->Operno;
                      +"                          "+STR( RECNO(),6 ) )
         SKIP ALIAS PartOper
      ENDDO                        // PartOper EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @  1, 6      SAY Admin->Adminno COLOR "BG+" 
         @  1,COL()+2 SAY TRIM( Admin->Desc )   COLOR "BG+"
         @  1,COL()+1 SAY coperno+" Esc/Enter" 
         DISPBOX( 3, 1, 19,79, 2 )
         anum := ACHOICE(  4, 3, 18,78, aPart_,,"AFUNC" )
       ENDIF                        // Empty
       manother := ApGetN( "Another Administration" )          

      ENDDO                 // another
             LOOP

         CASE mchoice == 11                 // JC Report
             JCOperation()                  // XLF_Equ2
            LOOP

         CASE mchoice == 12                        // Add Part
             SELECT Part
             SET ORDER TO 1                       // Partnum
             mpartnum := SPACE( 20 )

              Partfind( @mpartnum )                // XF_Part

             mpartnum := Part->Partnum
             IF LASTKEY() = 27
                LOOP
             ENDIF 
             SELECT PartOper 
              ApFlock( 3 )
             APPEND BLANK
             PartOper->Operno := coperno
             PartOper->Date   := DATE()
             PartOper->Desc   := Part->Desc
             UNLOCK
             SCROLL( 14, 0, 20,80 )
             DISPBOX( 14, 1, 20,79, 2 )
             cdesc    := PartOper->Desc
             corder   := PartOper->Order
             ntime    := PartOper->Time
             cadminno := PartOper->Adminno
             @ 16, 3      SAY PartOper->Operno   COLOR "BG+"
             @ 16,COL()+1 SAY "Desc"  GET cdesc  PICTURE "@X"
             @ 18, 3      GET cadminno           PICTURE "@X"
             @ 18,COL()+2 SAY "Time"  GET ntime  PICTURE "99999.99"
             @ 18,COL()+1 SAY "Order" GET corder PICTURE "@!"
              READ
              ApRlock( 3 )
             PartOper->Desc    := cdesc
             PartOper->Order   := corder
             PartOper->Adminno := cadminno
             PartOper->Time    := ntime
             UNLOCK
             LOOP
         CASE mchoice == 13                 // Edit Key Desc
             OperEditKey()                  // Above
            LOOP
         CASE mchoice == 14                 // Edit PartOper
             PartOperAdd()                  // XLF_QU5
            LOOP

      ENDCASE

      mcontinue := "Y"
   ENDDO

   RETURN NIL
   ****-----------  End of Operation

   *****------------------------------------------------------------------------

FUNCTION PartOperLst( mpartnum )

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
   SELECT PartOper
   ***        SET ORDER TO 2        // Order
   GOTO TOP
   DO WHILE PartOper->( !EOF() )
      IF PartOper->Partnum != mpartnum
         SKIP ALIAS PartOper
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
      @ nl, 1 SAY PartOper->Order
      @ nl, 5 SAY PartOper->Desc
      DO CASE
         CASE PartOper->Adminno != SPACE( 8 )
              IF PartOper->Time > 0
                 @ nl,48 SAY PartOper->Time PICTURE "99,999.99"
              ENDIF
              @ nl,59 SAY PartOper->Adminno
              ntotTime += PartOper->Time
         CASE PartOper->Drawno != SPACE( 8 )
              @ nl,58 SAY PartOper->Drawno+"   Drawing" 
      ENDCASE
      nl++
      SKIP ALIAS PartOper
   ENDDO                        // PartOper EOF
   @ nl,46 SAY "-----------"
   nl++
   @ nl,35 SAY "Total Time"
   @ nl,48 SAY ntotTime    PICTURE "99,999.99"
   @ nl,58 SAY "Time/60"
   @ nl,66 SAY ntotTime/60 PICTURE "9,999.99"
   nl+=2
   mmodcode := SUBSTR( mpartnum, 1,16 )
   IF mwhere = "S"
      INKEY()
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
     ELSE
      EndPrint()
   ENDIF
   SCROLL()
   @ 10,10 SAY "You Can Print the Module Parts List to level 4"
   @ 12,10 SAY "The price can be viewed with a % added"
   cprint := ApGetN(  "Do You want Parts/Prices" )
   IF cprint = "Y"

      EquPart( @mmodcode )               // XLF_Equ3

   ENDIF          // cprint
   SELECT Part
   SEEK mpartnum

   RETURN NIL
   ***** End of PartOperLst

   *******-----------------   END OF XLF_QU9.PRG
