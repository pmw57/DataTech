   ***  JK 20-06-11 08:15:21 

/* 
   Program.....:                  XLF_JOB.PRG
   Authors.....: J.Kirby
   Date........: 15/09/1999
   Functions...: RecourceAdd, OperPrint, Mu_Job, PartCSell
   Static funcs: RecoPrint, Recource
   Not used....: OperPrnt, CutTotal
*/

// (c) Copyright 1993 by  L. Kirby Christchurch.

STATIC FUNCTION RecoPrint()

   SCROLL()
   coperno := "RECOURCE"
   ttime   := 0
   mwhere := "S"
   npl    := 20
   nl     := 0
   
   Printsel()                               // _LF_Init

   IF mwhere == "P"
      npl := 65
      @  0, 0
      SET DEVICE TO PRINT
   ELSE
      npl := 23
      nl  := 0
   ENDIF
   @ nl, 1 SAY Control->U_Name
   @ nl,34 SAY "Recource Report "+mcodeno
   @ nl,62 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
              +STR(YEAR(DATE()),5)
   nl+=2
   @ nl, 1 SAY coperno+"    "+mcodeno 
   nl++
   SELECT Admin
   GOTO TOP
   SEEK coperno
   DO WHILE Admin->Adminno = coperno .AND. Admin->( !EOF() )
      @ nl, 3 SAY Admin->Desc+" ___________________________"
      nl++
      SKIP ALIAS Admin
   ENDDO      // Admin
   nl++
   SELECT PartOper
   GOTO TOP
   ***             SET ORDER TO 2         // Operno+Order
   DO WHILE PartOper->( !EOF() )
      IF PartOper->Codeno != mcodeno
         SKIP ALIAS PartOper
         LOOP
      ENDIF
      IF PartOper->Task = " "
         SKIP ALIAS PartOper
         LOOP
      ENDIF
      IF PartOper->Operno != coperno
         SKIP ALIAS PartOper
         LOOP
      ENDIF
      ttime := ttime+PartOper->Time
      @ nl, 1 SAY PartOper->Order;
                  +" "+SUBSTR( PartOper->Partnum, 1,16 )
      IF PartOper->Time > 0
         @ nl,23 SAY PartOper->Time PICTURE "999.99"
      ENDIF
      IF PartOper->Desc = SPACE( 40 )
         @ nl,30 SAY "______:______:______:______:______:______"
        ELSE
         @ nl,30 SAY PartOper->Desc
      ENDIF
      nl++
      IF nl > npl
         IF mwhere = "P"
            EJECT
          ELSE
            INKEY( 0 )
            SCROLL()
         ENDIF
         nl := 0 
      ENDIF
      SKIP ALIAS PartOper
   ENDDO                     // PartOper   coperno 
   nl+=2
   @ nl,10 SAY "Time"
   @ nl,15 SAY ttime PICTURE "9,999.99"  
   nl++
   IF mwhere = "P"
      @ nl, 0 SAY " "
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
   SELECT PartOper
   SET ORDER TO 1

   RETURN NIL
   ***-------- End of RecoPrint

   ****-------------------------------------------------------------------------

FUNCTION RecourceAdd()

   SELECT Name
   mcodeno := SPACE( 8 ) 
   mselect  := ApGetN( "Select Not STAFF Name" )
   IF mselect = "Y"
       NameRank( mcodeno )
      IF LASTKEY() = 27
         RETURN NIL
      ENDIF
      mcodeno := Name->Codeno
   ENDIF        // mselect
   IF mselect = "N"
      GOTO TOP
      aPart_:={}
      nrecno := 0
      IF LASTREC() != 0
         DO WHILE  Name->( !EOF() )
            IF Name->Sale != "STAF"
               SKIP ALIAS Name
               LOOP
            ENDIF  
            AADD( aPart_,Name->Codeno+"   "+SUBSTR( Name->Name, 1,26 );
                       +" "+Name->Add1;
                       +"                 "+STR( RECNO(),6 ) )
            SKIP ALIAS Name
         ENDDO
         SCROLL()
         DISPBOX( 0, 1,  2,79, 2 )
         @  1, 6 SAY "Adding Recources"
         @  1,60 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                    +STR( YEAR(DATE() ), 5 )
         DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            ASORT( aCatcode_,,,{ | x,y | x < y } )
            anum := ACHOICE( 4, 5, 23,76,aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            IF PressedEsc()
               RETURN NIL
            ENDIF
            GOTO nrecno
            mcodeno := Name->Codeno
            @  1,21 SAY TRIM( Name->Name ) COLOR "BG+"
         ENDIF     // !Empty 
      ENDIF           // LastRec
   ENDIF              // mselect = N
   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      nTime   := 0
      coperno := "RECOURCE"
      aPart_:={}
      nrecno  := 0
      SELECT PartOper
      SET ORDER TO 2                       // Operno+Order
      GOTO TOP
      ***   SEEK coperno
      ***   DO WHILE PartOper->Operno = coperno .AND. PartOper->( !EOF() )
      DO WHILE PartOper->( !EOF() )
         IF PartOper->Codeno != mcodeno
            SKIP ALIAS PartOper
            LOOP
         ENDIF
         IF PartOper->Operno != coperno
            SKIP ALIAS PartOper
            LOOP
         ENDIF
         IF PartOper->Task = " "
            SKIP ALIAS PartOper
            LOOP
         ENDIF
         AADD( aPart_,PartOper->Order;
            +" "+SUBSTR( PartOper->Partnum, 1,16 );
            +" "+STR( PartOper->Time, 6, 2 );
            +" "+PartOper->Desc;
            +" "+PartOper->Codeno;
            +"                    "+STR( RECNO(),6 ) )
            ntime := ntime+PartOper->Time
         SKIP ALIAS PartOper
      ENDDO                        // PartOper EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @ 1, 5      SAY "Viewing Recources"    COLOR "G+"
         @ 1,COL()+2 SAY ntime PICTURE "999.99" COLOR "G+"
         @ 1,COL()+4 SAY "  "+coperno+"    Esc or Enter for Menu" COLOR "BG+"
         DISPBOX( 3, 1, 24,79, 2 )
         anum := ACHOICE(  4, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         SCROLL( 15, 0, 18,80 ) 
         DISPBOX( 15, 1, 18,79, 2 )
         @ 16, 4 SAY PartOper->Codeno+" "+PartOper->Order COLOR "BG+"
         @ 17, 4 SAY PartOper->Partnum+" "+PartOper->Desc COLOR "BG+"
      ENDIF                        // Empty
      IF EMPTY( aPart_ )
         SCROLL( 15, 2, 18,78 )
         @ 16,10 SAY "No Recource Entries Add First" COLOR "G+"
      ENDIF
      SCROLL( 19, 0, 24,80)
      DISPBOX( 19, 1, 24,79, 2 )
      @ 19, 8 SAY " --- Recource ---  "+coperno+" "
      mchoice := 1
      @ 20, 4      PROMPT "Order"
      @ 20,COL()+2 PROMPT "1.Edit"
      @ 20,COL()+2 PROMPT "2.Add New"
      @ 20,COL()+2 PROMPT "3.Add Operation"  
      @ 20,COL()+2 PROMPT "4.Add Process"
      @ 20,COL()+2 PROMPT "5.Print"

      @ 22, 4      PROMPT "6. Delete"  
      @ 22,COL()+2 PROMPT "7. Add Drawing"  
      @ 22,COL()+2 PROMPT "8. Edit/Add Draw"  
      @ 22,COL()+2 PROMPT "9. Drawings"  
      @ 23, 4      PROMPT "Administration"  
      @ 23,COL()+2 PROMPT "Name Another"
      @ 23,COL()+2 PROMPT "Process Menu"  
      MENU TO mchoice
      DO CASE
         CASE PressedEsc()
              RETURN NIL
         CASE mchoice == 1             // Order
            IF EMPTY( aPart_ )
               @ 16,10 SAY "No Entries Must Add First"
               WAIT 
               EXIT
            ENDIF
            manother = "Y"
            DO WHILE manother = "Y"  
               ntime := 0
               aPart_:={}
               nrecno  := 0
               SELECT PartOper
               SET ORDER TO 2                       // Operno+Order
               GOTO TOP
               DO WHILE PartOper->( !EOF() )
                  IF PartOper->Codeno != mcodeno
                     SKIP ALIAS PartOper
                     LOOP
                  ENDIF
                  IF PartOper->Operno != coperno
                     SKIP ALIAS PartOper
                     LOOP
                  ENDIF
                  IF PartOper->Task = " "
                     SKIP ALIAS PartOper
                     LOOP
                  ENDIF
                  AADD( aPart_,PartOper->Order;
                     +" "+SUBSTR( PartOper->Partnum, 1,16 );
                     +" "+STR( PartOper->Time, 6, 2 );
                     +" "+PartOper->Desc;
                     +" "+PartOper->Task;
                     +" "+PartOper->Codeno;
                     +"                    "+STR( RECNO(),6 ) )
                  ntime := ntime+PartOper->Time
                  SKIP ALIAS PartOper
               ENDDO                        // PartOper EOF
               IF !EMPTY( aPart_ )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  SCROLL()
                  DISPBOX( 0, 1, 24,79, 2 )
                  @ 0, 4      SAY "  Esc to Exit  "      COLOR "BG+"
                  @ 0,COL()+2 SAY ntime PICTURE "999.99" COLOR "G+"
                  @ 0,COL()+2 SAY "  "+mcodeno+"  "+coperno   COLOR "BG+"
                  anum := ACHOICE(  2, 3, 23,78, aPart_,,"AFUNC" )
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
                  corder := PartOper->Order
                  @ ROW(), 2 GET corder PICTURE "@!"
                   READ   
                   ApRLock( 3 )   
                  PartOper->Order   := corder  
                  UNLOCK
               ENDIF                        // Empty
               IF LASTKEY() = 27
                  EXIT
               ENDIF 
            ENDDO                         // manother
            LOOP

         CASE mchoice == 2             // Edit
            IF EMPTY( aPart_ )
               @ 16,10 SAY "No Entries Must Add First"
               WAIT 
               EXIT
            ENDIF
            corder := PartOper->Order
            cpart  := SUBSTR( PartOper->Partnum, 1,16 )
            cdesc  := PartOper->Desc
            cdesc1 := PartOper->Desc1
            cdesc2 := PartOper->Desc2
            ctask  := PartOper->Task
            ttime  := PartOper->Time 
            SCROLL( 12, 0, 18,80 ) 
            DISPBOX( 12, 0, 19,79, 2 )
            @ 13, 4      SAY PartOper->Order+"  "+PartOper->Partnum COLOR "BG+"
            @ 13,COL()+2 SAY PartOper->Desc+"  "+PartOper->Codeno   COLOR "BG+"
            @ 15, 3      GET corder PICTURE "@!"
            @ 15,COL()+1 GET cpart  PICTURE "@X"
            @ 15,COL()+2 SAY "Time" 
            @ 15,COL()+1 GET ttime  PICTURE "99.99"
            @ 16, 5      SAY "Desc" GET cdesc  PICTURE "@X"
            @ 16,COL()+2 GET ctask  PICTURE "@!"
            @ 16,COL()+1 SAY "T = Task - Recource"
            @ 17,10     GET cdesc1 PICTURE "@X"
            @ 18,10     GET cdesc2 PICTURE "@X"

             READ   
             ApRLock( 3 )   
            PartOper->Order   := corder  
            PartOper->Partnum := cpart
            PartOper->Time    := ttime
            PartOper->Desc    := cdesc
            PartOper->Desc1   := cdesc1
            PartOper->Desc2   := cdesc2
            PartOper->Task    := ctask
            UNLOCK
            LOOP

         CASE mchoice == 3                     // Add New Recource
            Recource()
            LOOP
         CASE mchoice == 4                     // Add New Operation
            mpart := SPACE( 16 )
            aPart_:={}
            nrecno  := 0
            SCROLL(  0,60, 24,80 ) 
            DISPBOX( 0,60, 24,79, 2 )
            SELECT PartOper
            SET ORDER TO 1                    // Partnum
            GOTO TOP
            mdesc := PartOper->Desc
            mpart := SPACE( 16 )         // SUBSTR( PartOper->Partnum, 1,16 )
            DO WHILE PartOper->( !EOF() )
               ***            IF PartOper->Task = " "
               ***               SKIP ALIAS PartOper
               ***               LOOP
               ***            ENDIF
               IF SUBSTR( PartOper->Partnum, 1,16 ) = mpart
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               AADD( aPart_,PartOper->Partnum;
                      +"                    "+STR( RECNO(),6 ) )
               mpart := SUBSTR( PartOper->Partnum, 1,16 ) 
               SKIP ALIAS PartOper
            ENDDO                        // PartOper EOF
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum := ACHOICE(  1, 62, 23,78, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               mpart := SUBSTR( PartOper->Partnum, 1,16 )
               mdesc := PartOper->Desc
            ENDIF                        // Empty
            SCROLL( 15, 0, 19,80 ) 
            DISPBOX( 15, 1, 19,79, 2 )
            @ 16,32 SAY "Use 01,04,07,10,13,16,19,22,25 etc"
            nl := 16
             ApFlock( 3 )
            APPEND BLANK
            PartOper->Date    := DATE()
            PartOper->Operno  := coperno
            PartOper->Partnum := mpart
            PartOper->Desc    := mdesc
            PartOper->Codeno  := mcodeno
            PartOper->Task    := "T"
            corder            := PartOper->Order
            mdesc             := PartOper->Desc
            mtask             := PartOper->Task
            mpart             := SUBSTR( PartOper->Partnum, 1,16 )  
             UNLOCK
            @ nl, 8      SAY PartOper->Operno
            @ nl,COL()+2 SAY "Order" GET corder PICTURE "@!"
            nl++
            @ nl, 8      GET mpart PICTURE "@X"
            @ nl,COL()+2 GET mdesc PICTURE "@X"
            @ nl,COL()+2 GET mtask PICTURE "@!" 
             READ
             ApRlock( 3 )
            PartOper->Partnum := mpart
            PartOper->Desc    := mdesc
            PartOper->Task    := mtask
            PartOper->Order   := corder
            UNLOCK 
            IF LASTKEY() = 27
               RETURN NIL
            ENDIF 
            LOOP

         CASE mchoice == 5                 // Add Process
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
                               +"  "+Operate->Desc;
                               +"                                          "+STR( RECNO(),6 ) )
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
                  IF PartOper->Codeno != mcodeno
                     SKIP ALIAS PartOper
                     LOOP
                  ENDIF
                  AADD( aPart_,PartOper->Order;
                     +" "+PartOper->Adminno;
                     +" "+PartOper->Desc;
                     +"  "+PartOper->Operno;
                     +"                            "+STR( RECNO(),6 ) )
                  SKIP ALIAS PartOper
               ENDDO                        // PartOper EOF
               IF !EMPTY( aPart_ )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  SCROLL()
                  DISPBOX( 0, 1, 2,79, 2 )
                  @  1, 6      SAY Operate->Operno COLOR "BG+" 
                  @  1,COL()+2 SAY Operate->Desc   COLOR "BG+"
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
               PartOper->Codeno  := mcodeno
               PartOper->Adminno := Operate->Operno
               PartOper->Order   := Operate->Order
               PartOper->Desc    := Operate->Desc
               PartOper->Partnum := Operate->Operno
               PartOper->Task    := "T"
               UNLOCK 
            ENDDO                 // another
            LOOP
         CASE mchoice == 6            // Print
            RecoPrint()             // Above
            LOOP

         CASE mchoice == 7                     // Delete
            SCROLL( 15, 0, 19,80 ) 
            DISPBOX( 15, 1, 19,79, 2 )
            nl := 16
            @ nl, 4      SAY PartOper->Codeno+" "+PartOper->Order COLOR "RG+"
            @ nl,COL()+2 SAY PartOper->Partnum+" "+PartOper->Desc COLOR "RG+"
            cstring := TRIM( Message->Suredel )
            mok := ApCheck( cstring )         // AppX.PRG
            IF mok == "Y"
               ApFLock( 3 )
               DELETE
               UNLOCK
            ENDIF 
            LOOP

         CASE mchoice == 8                 // Drawing Add To JC-
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
                            +" "+Drawing->DrawLoc;
                            +"                "+STR( RECNO(),6 ) )
               SKIP ALIAS Drawing
            ENDDO                        // Drawing EOF
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               SCROLL(  3, 0, 24,80 )
               DISPBOX( 3, 1, 24,79, 2 )
               anum := ACHOICE(  4, 4, 23,70, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               cDrawno := Drawing->Drawno 
               SCROLL(  18, 0, 20,80 )
               DISPBOX( 18, 1, 20,79, 2 )
               nl := 19
               @ nl,10 SAY Drawing->Drawno+"  "+Drawing->Desc;
                          +" "+Drawing->DrawLoc COLOR "BG+"
            ENDIF                        // Empty

            coperno := "RECOURCE"
            SCROLL()
            DISPBOX( 0, 1, 2,79, 2 )
            @ 1, 8 SAY "Viewing Drawing "+mcodeno+"  "+coperno
            DISPBOX( 3, 1, 18,79, 2 )
            SELECT PartOper
            GOTO TOP
            nl := 4
            DO WHILE PartOper->( !EOF() )
               IF PartOper->Codeno != mcodeno
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               IF PartOper->Operno != coperno
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               IF PartOper->Task = " "
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               IF PartOper->Drawno = SPACE( 8 )
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               @ nl, 3 SAY PartOper->Operno+" "+TRIM( PartOper->Partnum );
                          +" "+PartOper->Desc+" "+PartOper->Order
               nl++ 
               SKIP ALIAS PartOper
            ENDDO                        // Drawing EOF
            SELECT Drawing
            SCROLL(  14, 0, 24,80 )
            DISPBOX( 14, 1, 19,79, 2 )
            nl := 15
            @ nl, 4 SAY Drawing->Drawno COLOR "BG+"
             ApRlock( 3 )
            @ nl,14 SAY "Desc" GET Drawing->Desc    PICTURE "@X"
             READ
            UNLOCK
            IF PressedEsc()
               RETURN NIL
            ENDIF
            mcorrect := ApGetY( "Check Correct Drawing" )
            IF mcorrect = "N"
               LOOP                // JobDraw()
            ENDIF
            SELECT PartOper
             ApFlock( 3 )
            APPEND BLANK
            PartOper->Operno  := coperno
            PartOper->Partnum := Drawing->Drawno
            PartOper->Desc    := Drawing->Desc
            PartOper->Task    := "T"
            PartOper->Drawno  := Drawing->Drawno
            PartOper->Date    := DATE()
            PartOper->Codeno  := mcodeno
            ***      PartOper->Order   := "D"+SUBSTR( Drawing->Desc, 1, 1 )
            UNLOCK
            LOOP

         CASE mchoice == 9                 // Edit-Delete Drawing
            coperno := "RECOURCE"
            SELECT PartOper
            aPart_:={}
            nrecno  := 0
            GOTO TOP
            DO WHILE PartOper->( !EOF() )
               IF PartOper->Codeno != mcodeno
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               IF PartOper->Operno != coperno
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               IF PartOper->Drawno = SPACE( 8 )
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               IF PartOper->Task = SPACE( 1 )
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               SELECT Drawing
               SEEK PartOper->Drawno
               SELECT PartOper
               AADD( aPart_,PartOper->Operno;
                            +" "+PartOper->Drawno;
                            +" "+PartOper->Desc;
                            +" "+PartOper->Task;
                            +" "+PartOper->Codeno;
                            +"          "+STR( RECNO(),6 ) )
               SKIP ALIAS PartOper
            ENDDO                        // PartOper EOF
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               SCROLL()
               DISPBOX( 1, 1, 24,79, 2 )
               anum := ACHOICE(  2, 5, 23,76, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               SCROLL(  11, 0, 24,80 )
               DISPBOX( 12, 1, 19,79, 2 )
               nl := 13
               @ nl, 4 SAY PartOper->Drawno COLOR "BG+" 
               mdesc := PartOper->Desc 
               @ nl,16 SAY "Desc" GET mdesc PICTURE "@X"
                READ
                ApRLock( 3 )
               PartOper->Desc := mdesc 
               UNLOCK
               SELECT Drawing
               SEEK PartOper->Drawno
                ApRLock( 3 )
               Drawing->Desc := mdesc 
               UNLOCK
               SELECT PartOper
               SCROLL( 20, 0, 24,80 )
               cstring := "Remove from JC-"
               mok := ApCheck( cstring )                     // AppX.PRG
               IF mok == "Y"
                   ApFLock( 3 )
                  DELETE
                  UNLOCK
               ENDIF 
            ENDIF                    // Empty
            LOOP
         CASE mchoice == 10                  // Admin
            JobDraw()                       // JobDem
            LOOP 

         CASE mchoice == 11                  // Drawings
            SCROLL()
            DISPBOX( 0, 1, 2,79, 2 )
            @ 1, 8 SAY "Viewing Admin"
            aPart_:={}
            nrecno   := 0
            SELECT Admin
            GOTO TOP
            DO WHILE Admin->( !EOF() )
               AADD( aPart_,Admin->Adminno;
                            +" "+Admin->Desc;
                            +"                "+STR( RECNO(),6 ) )
               SKIP ALIAS Admin
            ENDDO                        // Admin EOF
            IF !EMPTY( aPart_ )
               ASORT( aPart_,,,{ | x,y | x < y } )
               SCROLL(  3, 0, 24,80 )
               DISPBOX( 3, 1, 24,79, 2 )
               anum := ACHOICE(  4, 4, 23,70, aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               GOTO nrecno
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               cadminno := Admin->Adminno 
               SCROLL(  18, 0, 20,80 )
               DISPBOX( 18, 1, 20,79, 2 )
               nl := 19
               @ nl,10 SAY Admin->Adminno+"  "+Admin->Desc COLOR "BG+"
            ENDIF                        // Empty

            coperno := "RECOURCE"
            SCROLL()
            DISPBOX( 0, 1, 2,79, 2 )
            @ 1, 8 SAY "Viewing Admin "+mcodeno+"  "+coperno
            DISPBOX( 3, 1, 18,79, 2 )
            SELECT PartOper
            GOTO TOP
            nl := 4
            DO WHILE PartOper->( !EOF() )
               IF PartOper->Codeno != mcodeno
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               IF PartOper->Operno != coperno
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               IF PartOper->Task = " "
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               IF PartOper->Adminno = SPACE( 8 )
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               @ nl, 3 SAY PartOper->Adminno+" "+TRIM( PartOper->Partnum );
                          +" "+PartOper->Desc+" "+PartOper->Order
               nl++ 
               SKIP ALIAS PartOper
            ENDDO                        // Admin EOF
            SELECT Admin
            SCROLL(  14, 0, 24,80 )
            DISPBOX( 14, 1, 19,79, 2 )
            nl := 15
            @ nl, 4 SAY Admin->Adminno COLOR "BG+"
             ApRlock( 3 )
            @ nl,14 SAY "Desc" GET Admin->Desc    PICTURE "@X"
             READ
            UNLOCK
            IF PressedEsc()
               RETURN NIL
            ENDIF
            mcorrect := ApGetY( "Check Correct Admin" )
            IF mcorrect = "N"
               LOOP                // JobDraw()
            ENDIF
            SELECT PartOper
             ApFlock( 3 )
            APPEND BLANK
            PartOper->Operno  := coperno
            PartOper->Partnum := Admin->Adminno
            PartOper->Desc    := Admin->Desc
            PartOper->Task    := "T"
            PartOper->Date    := DATE()
            PartOper->Codeno  := mcodeno
            PartOper->Order   := UPPER( SUBSTR( coperno, 1, 1 ) )+"1"
            UNLOCK
            LOOP

         CASE mchoice == 12
             RecourceAdd()                   // Above
            LOOP
         CASE mchoice == 13
             JobOperate()                   // XF2PPart
            LOOP
      ENDCASE
      mcontinue := "Y"
   ENDDO

   RETURN NIL
   ***-------- End of RecouceAdd

   ****-------------------------------------------------------------------------

STATIC FUNCTION Recource()

   mDesc   := SPACE( 40 )
   mInvno  := SPACE( 6 )
   dDate   := Control->LastRoll
   mcorrect := ApGetN( "Do You Want JC-" )
   IF mcorrect == "Y"
      minvno := SPACE( 6 )
      SCROLL(  10, 0, 24,80 ) 
      DISPBOX( 10, 1, 22,79, 2 )
      SELECT Name        
      @ 12,10      SAY Name->Name
      @ 14,10      SAY "Invno"    GET mInvno  PICTURE "@!"
      @ 14,COL()+2 SAY "Blank to View Job Cards  J Only" 
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      SELECT Debit
      SET ORDER TO 2                 // Invno
      SEEK mInvno
      SET ORDER TO 1
      IF FOUND()
         minvno := Debit->Invno
         cDesc  := Debit->Est
      ENDIF
      IF !FOUND() .OR. minvno = SPACE( 6 )
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
               AADD( aPart_,Debit->Invno+" "+Debit->Stat;
                    +" "+Debit->Equip+" "+Debit->Codeno;
                    +" "+DTOC( Debit->Dbdate );
                    +" "+STR( Debit->Amount, 9, 2 )+" "+Debit->Saleno;
                    +" "+Debit->Est+"                        "+STR( RECNO(),6 ) )
               SKIP ALIAS Debit
            ENDDO
            IF !EMPTY( aPart_ )
               SCROLL(   3, 0, 24,80 )
               DISPBOX(  3, 1, 24,79, 2 )
               ASORT( aPart_,,,{ | x,y | x < y } )
               anum   := ACHOICE(  4, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
               GOTO nrecno
               minvno := Debit->Invno
               mDesc  := Debit->Est
            ENDIF                     // Empty
         ENDIF                        // LastRec    
      ENDIF
   ENDIF                   // minvno = Y
    
   SELECT PartOper
   ApFLock( 3 )
   APPEND BLANK
   PartOper->Operno  := "RECOURCE" 
   PartOper->Codeno  := Name->Codeno
   PartOper->Date    := DATE()
   PartOper->Partnum := Name->Codeno+"  "+minvno
   PartOper->Desc    := mDesc
   ***      PartOper->Order   := SUBSTR( Name->Codeno, 1, 2 )            //"RE"
   PartOper->Task    := "T" 
   UNLOCK
   SCROLL(  12, 0,24,80 )
   DISPBOX( 12, 1,24,79, 2 )
   minvno   := PartOper->Partnum
   mdesc    := PartOper->Desc
   mtask    := PartOper->Task
   mtime    := PartOper->Time
   @ 13,10      SAY Name->Name
   @ 14,10      SAY "Invno "+PartOper->Partnum
   @ 16,19      GET mdesc                      PICTURE "@X" 
   @ 17,19      SAY "Recource Only" GET mtask  PICTURE "@!" 
   @ 18,10      SAY "Time" GET mtime           PICTURE "9999.99"
   READ
   ApFLock( 3 )
   PartOper->Desc := mdesc
   PartOper->Task := mtask
   PartOper->Time := mtime
   UNLOCK

   RETURN NIL
   ***---  End of Recource

   ****--------------------------------------------------------------------

FUNCTION OperPrnt()

   ////   This is for JC Print

   mwhere := "S"
   npl    := 20
   nl     := 0
   
    Printsel()                               // _LF_Init

   IF mwhere == "P"
      npl := 64
      @  0, 0
      SET DEVICE TO PRINT
    ELSE
     nl  := 1
     npl := 23  
   ENDIF
   minvno := Debit->Invno
   @ nl, 1 SAY Control->U_Name
   @ nl,38 SAY "JC- Operation Report "+minvno
   @ nl,63 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
              +STR(YEAR(DATE()),5)
   nl+=2
   SELECT Name
   SEEK Debit->Codeno       // Quot->Codeno
   @ nl, 0 SAY Name->Name+"  "+Debit->Est+"    Job Card  "+minvno
   nl++
   @ nl,28 SAY "Start"
   @ nl,34 SAY DTOC( Debit->StartDate ) 
   @ nl,45 SAY "Due"
   @ nl,49 SAY DTOC( Debit->DueDate ) 
   nl++
   @ nl, 3 SAY Debit->Fault
   nl++
   @ nl, 3 SAY Debit->Message
   @ nl,54 SAY Debit->DbDate
   nl++
   SELECT Quot 
   SET ORDER TO 3                    // Invno
   SEEK Debit->Invno
   SELECT Part
   SEEK Quot->Partnum
         @ nl, 0 SAY STR( Quot->Qty, 7, 2 )+" "+SUBSTR( Part->Unit, 1, 6);
                     +" "+Part->Desc;
                     +" "+SUBSTR( Quot->Partnum, 1,16 )
         nl++
   mcodeno := Quot->Codeno
   SEEK mcodeno
   DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
      IF Quot->Invno != minvno
         SKIP ALIAS Quot
         LOOP
      ENDIF
      nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
      SELECT Equ
      mmod1 := TRIM( Quot->Partnum )
      SEEK mmod1
      SELECT PartOper
      SET ORDER TO 1               // Partnum
      GOTO TOP
      SEEK Quot->Partnum
      mpartnum := Quot->Partnum
      DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() ) 
         IF SUBSTR( PartOper->Partnum, 1, 2 ) = "ZZ"
            SKIP ALIAS PartOper
            LOOP
         ENDIF
         IF SUBSTR( PartOper->Partnum, 1, 2 ) = "XY"
            SKIP ALIAS PartOper
            LOOP
         ENDIF
         IF PartOper->Adminno != SPACE( 8 )
            SKIP ALIAS PartOper
            LOOP
         ENDIF
         @ nl, 2 SAY SUBSTR( PartOper->Partnum, 1,16 );
                    +" "+PartOper->Drawno;
                    +" "+PartOper->Desc+" "+PartOper->Order
         nl++
         SKIP ALIAS PartOper
      ENDDO 
      SELECT Equ
      GOTO TOP
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
               IF nl > 22
                  INKEY( 0 )
                  SCROLL()
                  nl := 0
               ENDIF
            ENDIF
            SELECT PartOper
            SEEK Equ->Partnum
            mpartnum := Equ->Partnum
            DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() ) 
               IF SUBSTR( PartOper->Partnum, 1, 2 ) = "ZZ"
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               IF SUBSTR( PartOper->Partnum, 1, 2 ) = "XY"
                  SKIP ALIAS PartOper
                  LOOP
               ENDIF
               @ nl, 2 SAY SUBSTR( PartOper->Partnum, 1,16 );
                    +" "+PartOper->Drawno;
                    +" "+PartOper->Desc+" "+PartOper->Order
               nl++
               SKIP ALIAS PartOper
            ENDDO 
            SELECT Equ
            mmod2 := TRIM( Equ->Partnum )
            nrecno2 := RECNO() 
            GOTO TOP
            SEEK mmod2
            IF FOUND()   
               DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
                  IF nl > npl
                     IF mwhere = "P"
                        EJECT
                        nl := 0  
                      ENDIF
                  ENDIF
                  IF mwhere = "S"
                     IF nl > 22
                        INKEY( 0 )
                        SCROLL()
                        nl := 0
                     ENDIF
                  ENDIF
                  SELECT PartOper
                  SEEK Equ->Partnum
                  mpartnum := Equ->Partnum
                  DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() ) 
                     IF SUBSTR( PartOper->Partnum, 1, 2 ) = "ZZ"
                        SKIP ALIAS PartOper
                        LOOP
                     ENDIF
                     IF SUBSTR( PartOper->Partnum, 1, 2 ) = "XY"
                        SKIP ALIAS PartOper
                        LOOP
                     ENDIF
                     @ nl, 2 SAY SUBSTR( PartOper->Partnum, 1,16 );
                          +" "+PartOper->Drawno;
                          +" "+PartOper->Desc+" "+PartOper->Order
                     nl++
                     SKIP ALIAS PartOper
                  ENDDO 
                  SELECT Equ
                  mmod3 := TRIM( Equ->Partnum )
                  nrecno3 := RECNO() 
                  GOTO TOP
                  SEEK mmod3
                  IF FOUND()   
                     DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
                        IF nl > npl
                           IF mwhere = "P"
                              EJECT
                              nl := 0 
                           ENDIF
                        ENDIF
                        IF mwhere = "S"
                           IF nl > 22
                              INKEY( 0 )
                              SCROLL()
                              nl := 0
                           ENDIF
                        ENDIF
                        SELECT PartOper
                        SEEK Equ->Partnum
                        mpartnum := Equ->Partnum
                        DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() ) 
                           IF SUBSTR( PartOper->Partnum, 1, 2 ) = "ZZ"
                              SKIP ALIAS PartOper
                              LOOP
                           ENDIF
                           IF SUBSTR( PartOper->Partnum, 1, 2 ) = "XY"
                              SKIP ALIAS PartOper
                              LOOP
                           ENDIF
                            @ nl, 2 SAY SUBSTR( PartOper->Partnum, 1,16 );
                                       +" "+PartOper->Drawno;
                                       +" "+PartOper->Desc+" "+PartOper->Order
                           nl++
                           SKIP ALIAS PartOper
                        ENDDO 
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
                               ENDIF
                           ENDIF
                           IF mwhere = "S"
                              IF nl > 22
                                 INKEY( 0 )
                                 SCROLL()
                                 nl := 0
                              ENDIF
                           ENDIF
                           SELECT PartOper
                           SEEK Equ->Partnum
                           mpartnum := Equ->Partnum
                           DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() ) 
                              IF SUBSTR( PartOper->Partnum, 1, 2 ) = "ZZ"
                                 SKIP ALIAS PartOper
                                 LOOP
                              ENDIF
                              IF SUBSTR( PartOper->Partnum, 1, 2 ) = "XY"
                                 SKIP ALIAS PartOper
                                 LOOP
                              ENDIF
                              @ nl, 2 SAY SUBSTR( PartOper->Partnum, 1,16 );
                                          +" "+PartOper->Drawno;
                                          +" "+PartOper->Desc+" "+PartOper->Order
                              nl++
                              SKIP ALIAS PartOper
                           ENDDO 
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
         ENDIF
         SELECT Equ
         GOTO nrecno2
         SKIP ALIAS Equ
         ENDDO                       //   mmod1 EOF()
      ENDIF                          // Found mmod1
      ***         SET EXACT OFF      
      SELECT Quot
      SKIP ALIAS Quot
   ENDDO                            //   EOF() Quot
   nl++
   @ nl, 1 SAY Debit->Operno
   @ nl,64 SAY "Made    Checked"
   nl+=2
   SELECT PartOper
   SET ORDER TO 2         // Operno
   SEEK Debit->Operno
   DO WHILE PartOper->Operno = Debit->Operno .AND. PartOper->( !EOF() )
      IF SUBSTR( PartOper->Partnum, 1, 2 ) = "ZZ"
         SKIP ALIAS PartOper
         LOOP
      ENDIF
      IF SUBSTR( PartOper->Partnum, 1, 2 ) = "XY"
         SKIP ALIAS PartOper
         LOOP
      ENDIF
      IF PartOper->Codeno != SPACE( 8 )
         IF PartOper->Codeno != Debit->Codeno
            SKIP ALIAS PartOper
            LOOP
         ENDIF
      ENDIF 
     IF PartOper->Adminno != SPACE( 8 )
        SKIP ALIAS PartOper
        LOOP
     ENDIF
     IF PartOper->Task != " "
        SKIP ALIAS PartOper
        LOOP
      ENDIF 
      ***                DO CASE 
      ***                   CASE PartOper->Adminno = Debit->Invno
      ***                      @ nl, 1 SAY PartOper->Order;
      ***                                 +" "+SUBSTR( PartOper->Partnum, 1,16 )
      ***                      @ nl,23 SAY TRIM( PartOper->Desc )
      ***                   CASE PartOper->Desc = SPACE( 40 )
      ***                      @ nl, 1 SAY PartOper->Order;
      ***                                  +" "+SUBSTR( PartOper->Partnum, 1,16 )
      ***                      @ nl,23 SAY "______:______:______:______:______:___________:________"
      ***                      nl++
      ***                   OTHERWISE
      @ nl, 1 SAY PartOper->Order;
                  +" "+SUBSTR( PartOper->Partnum, 1,16 )
      IF PartOper->Desc = SPACE( 40 )
          @ nl,23 SAY "______:______:______:______:______:___________:________"
      ELSE
          @ nl,23 SAY PartOper->Desc+"  "+PartOper->Drawno
      ENDIF 
      ***                ENDCASE
      nl++
      IF nl > npl
         IF mwhere = "P"
            EJECT
         ELSE
            INKEY( 0 )
            SCROLL()
         ENDIF
         nl := 0 
      ENDIF
      SKIP ALIAS PartOper
   ENDDO                     // PartOper   coperno 
   IF mwhere = "P"
      ***   @ nl, 0 SAY " "
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
   SELECT Quot 
   SET ORDER TO 1                    // Codeno

   RETURN NIL
   ****-------------- End OperPrnt

   ****------------------------------------------------------------------------

FUNCTION OperPrint()

   SCROLL()
   coperno := SPACE( 8 )   // Debit->Operno 
   GroupSelect( @coperno )               // XLF_QU9.Prg
   mwhere := "S"
   npl    := 20
   nl     := 0
   
   Printsel()                               // _LF_Init

   IF mwhere == "P"
      npl := 65
      @  0, 0
      SET DEVICE TO PRINT
    ELSE
      npl := 23
      nl  := 0
   ENDIF
   minvno := Debit->Invno
   @ nl, 2 SAY Control->U_Name
   @ nl,42 SAY "Operation Report"
   @ nl,62 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
              +STR(YEAR(DATE()),5)
   nl+=2
   SELECT Name
   SEEK Debit->Codeno
   IF FOUND()
      @ nl, 0 SAY TRIM( Name->Name )+"  "+TRIM( Debit->Est )+" JC- "+minvno
      nl++
      @ nl,48 SAY "Start"
      @ nl,54 SAY DTOC( Debit->StartDate ) 
      @ nl,65 SAY "Due"
      @ nl,69 SAY DTOC( Debit->DueDate ) 
      nl++
      @ nl, 3 SAY Debit->Fault
      nl++
      @ nl, 3 SAY Debit->Message
      @ nl,54 SAY Debit->DbDate
      @ nl,65 SAY "J/C # "+minvno
      nl++
      SELECT Part
      SEEK Quot->Partnum
      @ nl, 0 SAY STR( Quot->Qty, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                  +" "+Part->Desc;
                  +"  "+SUBSTR( Quot->Partnum, 1,16 )
      nl+=2
   ENDIF                  // Found() 
   @ nl, 1 SAY coperno
   SELECT Admin
   GOTO TOP
   SEEK coperno
   DO WHILE Admin->Adminno = coperno .AND. Admin->( !EOF() )
      @ nl,13 SAY Admin->Desc+" ___________________________"
      nl++
      SKIP ALIAS Admin
   ENDDO      // Admin
   nl++
   SELECT PartOper
   GOTO TOP
   @ nl,64 SAY "Made    Checked"
   nl+=2
   SELECT PartOper
   SET ORDER TO 2         // Operno+Adminno+Order
   SEEK coperno
   DO WHILE PartOper->Operno = coperno .AND. PartOper->( !EOF() )
      /*
                      IF PartOper->Adminno != SPACE( 8 )
                         IF PartOper->Adminno != Debit->Invno
                            SKIP ALIAS PartOper
                            LOOP
                         ENDIF 
                      ENDIF 
      */
      IF PartOper->Codeno != SPACE( 8 )
         IF PartOper->Codeno != Debit->Codeno
            SKIP ALIAS PartOper
            LOOP
         ENDIF
      ENDIF  
      IF PartOper->Task != " "
         SKIP ALIAS PartOper
         LOOP
      ENDIF 
      DO CASE 
         CASE PartOper->Desc = SPACE( 40 )
            @ nl, 1 SAY PartOper->Order;
                        +" "+SUBSTR( PartOper->Partnum, 1,16 )
            @ nl,23 SAY "______:______:______:______:______:___________:________"
            **                      nl++
            **                      @ nl,23 SAY "___________________________________:_________:________"
         OTHERWISE
            @ nl, 1 SAY PartOper->Order;
                        +" "+SUBSTR( PartOper->Partnum, 1,16 )
            @ nl,23 SAY PartOper->Desc
      ENDCASE
      nl++
      IF nl > npl
         IF mwhere = "P"
            EJECT
          ELSE
            INKEY( 0 )
            SCROLL()
         ENDIF
         nl := 0 
      ENDIF
      SKIP ALIAS PartOper
   ENDDO                     // PartOper   coperno 
   IF mwhere = "P"
      @ nl, 0 SAY " "
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

   RETURN NIL
   ****-------------- End OperPrint

   ****------------------------------------------------------------------------

FUNCTION Mu_Job( nc, ncl )

   DO WHILE .T.

      cheading := "PLANNING MENU"
      nselect  := 0
      ***   nc := ncl
      nc       := ncl*2
      SCROLL( 3,nc, 21,78 )
      @  4,nc TO 21,nc+ncl
      SCROLL( 3,nc+4, 5,nc+(ncl-4) )
      @  3,nc+4 TO 5,nc+( ncl-4 )
      @  4,nc+( ncl/2 )-( LEN(cheading)/2 ) SAY cheading
      @  7,nc+2 PROMPT "1. Parts Find          "
      @  8,nc+2 PROMPT "2. Parts by Cost Sell  "
      @  9,nc+2 PROMPT "3. JC -   Required List"
      @ 11,nc+2 PROMPT "4. Module        Edit  "
      @ 12,nc+2 PROMPT "5. Parts Job Cards List"
      @ 15,nc+2 PROMPT "6. Job Cards      Parts"
      @ 16,nc+2 PROMPT "7. Job Card    IN HOUSE"
      @ 17,nc+2 PROMPT "8. Job Card     Req-Rec"
      ***   @ 19,nc+2 PROMPT "9. XY Modules Required "
      @ 20,nc+2 PROMPT "0. To - Main           "
      nc := ncl

      MENU TO nselect
      DO CASE
         CASE nselect == 9 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 1
            SAVE SCREEN TO holdscrn
             PartView()                            
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
              PartCsell()                              // Below
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO Invscrn
              QuotParts()                              // XF_QList
            RESTORE SCREEN FROM Invscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
              EquAdd()                                // XLF_Equ
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
              QuotTot()                                 // XLF_Qu7
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
              OrderTot()                                 // XL_Order
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
              HouseTot()                                 // XL_Order
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
              JCReqRec()                                 // XLF_QU6
            RESTORE SCREEN FROM holdscrn
      ENDCASE
   ENDDO

   RETURN NIL

   ***** End of Mu_Job()

   *****------------------------------------------------------------------------

FUNCTION PartCSell()

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
       ccatno := SPACE( 12 )
       CatArray()            // This sorts out Cat File
          SELECT Part
          SET ORDER TO 2                       // Catno
          GOTO TOP
          SEEK ccatno
          nrecno := 0
          aPart_ := {}
          DO WHILE Part->Catno = ccatno .AND. Part->( !EOF() ) 
              AADD( aPart_,SUBSTR( Part->Partnum, 1,16 );
                           +" "+SUBSTR( Part->Desc, 1,30 );
                           +" "+STR( Part->Trade,12, 3 );
                           +" "+STR( Part->Wholesale,12, 2 );
                           +"        "+STR( RECNO(),6 ) )
                   SKIP ALIAS Part
          ENDDO   // Part EOF
          SCROLL() 
          DISPBOX( 0, 1, 2,79, 2 )
          @  1, 6 SAY SUBSTR( Cat->CatDesc, 1,45 ) COLOR "G+"
          @  1,58 SAY "Cost         Sell"
          DISPBOX( 3, 1, 24,79, 2 )
          IF !EMPTY( aPart_ )
             ASORT( aPart_,,,{ | x,y | x < y } )
             anum := ACHOICE( 4, 3, 23,77, aPart_,,"AFUNC" )
             IF LASTKEY() = 27
                SELECT Part
                SET ORDER TO 1                  // Partnum
                RETURN NIL
             ENDIF  
          ENDIF
          mcontinue := "Y"
      ***** ApGetY( Message->Another )
   ENDDO                    // mcontinue
   SELECT Part
   SET ORDER TO 1                  // Partnum

   RETURN NIL

   ****  End of PartCSell()

   ***---------------------------------------------------------------------*

FUNCTION CutTotal()

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      SCROLL()
      aPart_ := {}
      anum := {}
      nrecno := 0
      SCROLL()
      SELECT EquCut
      GOTO TOP
      DO WHILE EquCut->( !EOF() )
         AADD( aPart_,SUBSTR( EquCut->ModSeqno, 1,14 );
                     +" "+SUBSTR( EquCut->Partnum, 1,14 );
                     +" "+SUBSTR( EquCut->ModRef, 1,18 );
                     +" "+STR( EquCut->Qty, 8, 2 );
                     +" "+STR( EquCut->Length, 8, 3 );
                     +" "+STR( EquCut->Width, 8, 3 );
                     +"         "+STR( RECNO(),6 ) )
         SKIP ALIAS EquCut
      ENDDO
      @ 23,10 SAY "Loading File TESTING WITHOUT SORT PLEASE CHECK XLF_Job Line 106"
      IF !EMPTY( aPart_ )
         DISPBOX( 0, 1, 21,79, 2 )
      ***//  TAKEN OUT TO SPEED UP   TESTING
      ****      ASORT( aPart_,,,{ | x,y | x < y })
         anum := ACHOICE( 1, 3, 20,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
         GOTO nrecno
         IF PressedEsc()
            RETURN NIL
         ENDIF
      ENDIF
      SCROLL(  22, 0,24,80 )
      DISPBOX( 22, 1,24,79, 2 )
           nselect := 1
      ***        @ 23, 4      PROMPT "Add Information"
           @ 23, 6      PROMPT "Edit Cut Info"
           @ 23,COL()+2 PROMPT "Delete"
           @ 23,COL()+2 PROMPT "Another"
        MENU TO nselect
        DO CASE
          CASE PressedEsc()
            RETURN NIL
          CASE nselect == 1    // Edit
             SCROLL(  15, 2, 20,78 )
             DISPBOX( 15, 2, 20,78, 2 )
             nl := 16
             SELECT EquCut
             mmodref := EquCut->ModRef
             nQty    := EquCut->Qty
             nlength := EquCut->Length
             nwidth  := EquCut->Width
             @ nl, 6      SAY "Cut Qty" GET nqty
             @ nl,COL()+2 SAY "Length " GET nlength
             @ nl,COL()+2 SAY "Width"   GET nwidth
             nl++    
             @ nl, 6      SAY "Desc   " GET mmodref PICTURE "@"
             nl++
              READ
              ApRLock( 3 )
             EquCut->ModRef := mmodref
             EquCut->Qty    := nqty
             EquCut->Length := nlength
             EquCut->Width  := nwidth
             UNLOCK
             LOOP
          CASE nselect == 2
             mok := ApGetN( TRIM( Message->Delete ) )
             IF mok == "Y"
                SELECT EquCut
                 ApRLock( 3 )
                DELETE
                UNLOCK
             ENDIF                            // mok
             mcontinue := "Y" 
             LOOP 
         CASE nselect == 3                     //   Another 
            LOOP
      ENDCASE
      mcontinue := "N"
   ENDDO                                   // mcontinue

   RETURN NIL
   *****----------- CutTotal

   *****---------------------- End of File XLF_Job.PRG

