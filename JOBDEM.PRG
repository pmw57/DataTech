   *** JK  30-01-11 08:16:45 

/* 
   Program.....:                  JOBDEM.PRG
   Authors.....: J.Kirby
   Date........: 03/11/1999
   Functions...: JobDraw,  CutsReview, ProgMessage
                 ProgDesc, JobAdmin, JobLabour, JobDemAdd
   Static Funcs: AdminABC
*/ 
// (c) Copyright 1993 by Kirby Christchurch.

FUNCTION JobDraw()

   cdrawno := SPACE( 8 )
   manother := "Y"
   DO WHILE manother = "Y"

      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @ 1, 8 SAY "Viewing Drawings"
      aPart_:={}
      nrecno   := 0
      SELECT Drawing
      GOTO TOP
      DO WHILE Drawing->( !EOF() )
         AADD( aPart_,Drawing->Drawno;
                      +"  "+Drawing->Desc;
                      +"                "+STR( RECNO(),6 ) )
         SKIP ALIAS Drawing
      ENDDO                        // Drawing EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 0, 24,79, 2 )
         anum := ACHOICE(  4, 2, 23,70, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         IF PressedEsc()
            RETURN NIL
         ENDIF
         cDrawno := Drawing->Drawno 
      ENDIF                        // Empty
      nselect  := 1
      SCROLL(  20, 0, 24,80 )
      DISPBOX( 20, 0, 24,79, 2 )
      @ 20, 5 SAY "  -- Drawings --  " 
      @ 22, 6      PROMPT "1. Add Drawing"
      @ 22,COL()+2 PROMPT "2. Edit Drawing"
      @ 22,COL()+2 PROMPT "3. Print"
      ***   @ 22,COL()+2 PROMPT "4. Part Card"

      MENU TO nselect

      DO CASE
         CASE PressedEsc()
            RETURN NIL

         CASE nselect == 1                // Add Drawing   
            SCROLL(  14, 0, 19,80 )
            DISPBOX( 14, 1, 19,79, 2 )
            SELECT Drawing
            nl := 15
            @ nl,10 SAY "Ref #"    GET cdrawno PICTURE "@!"
             READ
            /*
            SEEK cdrawno
            DO WHILE FOUND()
               @ nl,40 SAY "Already Used Try Again"
               @ nl,10 SAY "Ref #" GET cdrawno PICTURE "@!"
                READ
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               SEEK cdrawno
            ENDDO
            IF !FOUND()
            */
             ApFlock( 3 )
            APPEND BLANK
            Drawing->Drawno  := cdrawno
            Drawing->Date    := DATE()
            Drawing->DrawLoc := cdrawno 
            UNLOCK
            ApRlock( 3 )
            ***         @ nl,16      SAY Drawing->Drawno          COLOR "BG+"
            @ nl,27 SAY "Desc" GET Drawing->Desc PICTURE "@X"
            nl+=2
            @ nl,10 SAY "Location" GET Drawing->DrawLoc PICTURE "@X"
             READ
            UNLOCK

         CASE nselect == 2                // Edit Drawing   
            cdrawno  := SPACE( 8 )
            SELECT Drawing
            GOTO TOP
            SCROLL()
            @  4,40 SAY "Select Drawing Group"
            aPart_:={}
            nrecno   := 0
            IF LASTREC() != 0
               DO WHILE Drawing->( !EOF() )
                  DO WHILE Drawing->Drawno = cdrawno
                     SKIP ALIAS Drawing
                     LOOP        
                  ENDDO
                  AADD( aPart_,Drawing->Drawno+"               "+STR( RECNO(),6 ) )
                  cdrawno := Drawing->Drawno
                  SKIP ALIAS Drawing
               ENDDO
               DISPBOX(  0, 0, 24,20, 2 )
               IF !EMPTY( aPart_ )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE(  1, 2, 23,19, aPart_,,"AFUNC" )
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
               ENDIF
            ENDIF                          // LastRec  
            cdrawno := Drawing->Drawno
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
            SELECT Drawing
            GOTO TOP
            namount := "N"
            nrecno  := 0
            aPart_  := {}
            SEEK cdrawno 
            DO WHILE Drawing->Drawno = cdrawno .AND. Drawing->( !EOF() ) 
                    AADD( aPart_,( Drawing->Drawno+"  "+Drawing->Desc;
                        +"   Delete";
                        +"                    "+STR( RECNO(),6 ) ) )
                     SKIP ALIAS Drawing
            ENDDO                         // Fault EOF
            SCROLL() 
            DISPBOX( 0, 0, 2,79, 2 )
            @  1,10 SAY "Edit Drawings" COLOR "RG+"
            @  1,62 SAY "Esc to Exit" COLOR "RG+"
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
            @ ROW(), 1 GET Drawing->Drawno   PICTURE "@X"
            @ ROW(),12 GET Drawing->Desc     PICTURE "@X"
            ***       @ ROW(),50 GET Drawing->Drawnloc PICTURE "@!"
            @ ROW(),63 GET namount VALID( namount $ "NY " ) PICTURE "@!"
             READ
            IF namount = "Y"
               SELECT Drawing
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

         CASE nselect == 3                 // Print
            cdrawno  := SPACE( 8 )
            SELECT Drawing
            SCROLL()
            @  4,25 SAY "Select Printing Group First 4 Characters"
            aPart_:={}
            nrecno   := 0
            IF LASTREC() != 0
               DO WHILE Drawing->( !EOF() )
                 DO WHILE Drawing->Drawno = cdrawno
                     SKIP ALIAS Drawing
                     LOOP        
                  ENDDO
                  AADD( aPart_,Drawing->Drawno+"               "+STR( RECNO(),6 ) )
                  cdrawno := Drawing->Drawno
                  SKIP ALIAS Drawing
               ENDDO
               DISPBOX(  0, 0, 24,20, 2 )
               IF !EMPTY( aPart_ )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE(  1, 2, 23,19, aPart_,,"AFUNC" )
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
               ENDIF
            ENDIF                          // LastRec  
            cdrawno := SUBSTR( Drawing->Drawno, 1, 4 )
            mwhere := "S"
            npl    := 20
            nl     := 0
      
            Printsel()                               // _LF_Init

            IF mwhere == "P"
               npl := 64
               @  0, 0
               SET DEVICE TO PRINT
            ENDIF
            @ nl, 2 SAY Control->U_Name
            @ nl,42 SAY "Drawings"
            @ nl,62 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
                       +STR(YEAR(DATE()),5)
            nl+=2
                SELECT Drawing
                GOTO TOP
                SEEK cdrawno 
                DO WHILE Drawing->Drawno = cdrawno .AND. Drawing->( !EOF() ) 
            ***          IF SUBSTR( Drawing->Drawno, 1, 4 ) != SUBSTR( cdrawno, 1, 4 )
            ***             SKIP ALIAS Drawing
            ***             LOOP
            ***          ENDIF 
               IF SUBSTR( Control->U_Name, 1, 4 ) = "SHAN"
                  @ nl, 1 SAY Drawing->Desc
                ELSE   
                  @ nl, 1 SAY Drawing->Desc
                  @ nl,42 SAY Drawing->Drawno
                  @ nl,53 SAY Drawing->DrawLoc
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
               ENDIF             // npl
               SKIP ALIAS Drawing
            ENDDO                        // Drawing EOF
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
            LOOP


            ***    CASE nselect == 4                
            ***       PartDraw()                  // JobDmnd.PRG   
            ***     LOOP       
      ENDCASE
      manother := "Y" 
      **** ApGetY( Message->Another )
   ENDDO                                       // manother

   RETURN NIL
   ***--- End JobDraw()

   ****----------------------------------------------------------------------

FUNCTION CutsReview()

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
   crate := "N"
   aPart_:={}
   nrecno   := 0
   SELECT Progress
   GOTO TOP
   DO WHILE Progress->( !EOF() )
      IF Progress->DescProg != SPACE( 12 )
         SKIP ALIAS Progress
         LOOP
      ENDIF
      AADD( aPart_,Progress->Operno;
         +"  "+Progress->Desc;
         +"                           "+STR( RECNO(),6 ) )
      SKIP ALIAS Progress
   ENDDO                        // Progress EOF
      SCROLL() 
      DISPBOX( 0, 0, 2,78, 2 )
      @  1,17 SAY "Cuts Review   " 
      @  1,62 SAY "Esc to Exit" COLOR "G+"
      DISPBOX( 3, 0, 24,80, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 4, 3, 23,78, aPart_,,"AFUNC" )
         IF LASTKEY() = 27
            RETURN NIL
         ENDIF  
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
      ENDIF
      coperno := Progress->Operno
      cdesc   := Progress->Desc
      @ ROW(), 2 SAY Progress->Operno COLOR "RG+"
      @ ROW(),13 GET cdesc   PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
      @ ROW(),62 GET crate VALID( crate $ "NY " ) PICTURE "@!"
       READ
        ApRLock( 3 )
      Progress->Desc   := cdesc 
      IF crate = "Y"
         DELETE
      ENDIF
      UNLOCK
      IF LASTKEY() = 27
         RETURN NIL
      ENDIF  
      LOOP 
   ENDDO                                        // mcontinue

   RETURN NIL
   ***--- End CutsReview()

   ****----------------------------------------------------------------------

FUNCTION ProgMessage( coperno )

   SCROLL( 0, 0, 24, 26 )
   DISPBOX( 1, 0, 24,26, 2 )
   ncount := 1
   @  2, 5 SAY coperno COLOR "RG+"
   IF coperno = "XX      " .OR. coperno = SPACE( 8 )
      coperno := "GENERAL"
   ENDIF
   @ nl,15 SAY coperno COLOR "RG+"
   nl := 5
   SELECT Progress
   GOTO TOP
   SEEK coperno
   DO WHILE Progress->Operno = coperno .AND. Progress->( !EOF() )
      IF Progress->DescProg = "     "
         SKIP ALIAS Progress
         LOOP
      ENDIF      
      IF Progress->Order = "  "
         SKIP ALIAS Progress
         LOOP
      ENDIF      
      @ nl, 5 SAY ncount PICTURE "99"
      @ nl,COL()+2 SAY Progress->DescProg
      nl++
      ncount++
      SKIP ALIAS Progress
   ENDDO                      // EOF
   INKEY( 1 )
   SCROLL( 0, 0, 24, 26 )

   RETURN coperno

   ***--- End ProgMessage()

   ****----------------------------------------------------------------------

FUNCTION ProgDesc()

   coperno := SPACE( 8 )
   manother := "Y"
   DO WHILE manother = "Y"
      coperno := SPACE( 8 )
       GroupSelect( @coperno )
      SCROLL()
      ***   ProgMessage( @coperno ) 
      DISPBOX( 0, 0, 2,65, 2 )
      @ 1, 8 SAY "Viewing Progress  "+coperno COLOR "RG+"
      aPart_:={}
      nrecno   := 0
      SELECT Progress
      GOTO TOP
      DO WHILE Progress->( !EOF() )
         IF Progress->Desc != SPACE( 40 )
            SKIP ALIAS Progress
            LOOP
         ENDIF
         IF Progress->Operno != coperno
            SKIP ALIAS Progress
            LOOP
         ENDIF
         AADD( aPart_,Progress->Operno;
                      +"  "+Progress->Order; 
                      +"  "+Progress->DescProg;
                      +"                           "+STR( RECNO(),6 ) )
         SKIP ALIAS Progress
      ENDDO                        // Progress EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3,40, 24,79, 2 )
         anum := ACHOICE(  4,42, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         IF PressedEsc()
            RETURN NIL
         ENDIF
         coperno := Progress->Operno 
         DISPBOX(  8, 0, 18,39, 2 )
         nl := 10
         @ nl, 5 SAY Progress->Operno+"  "+Progress->Order;
                     +"  "+Progress->DescProg COLOR "RG+"
         nl+=2
         @ nl, 5 SAY "Product "+coperno
         nl+=2
         @ nl, 5 SAY "Order   "+Progress->Order
         nl+= 2
         @ nl, 5 SAY "   Desc "+Progress->DescProg 
      ENDIF                        // Empty
      nselect  := 1
      SCROLL(  20, 0, 24,80 )
      DISPBOX( 20, 0, 24,79, 2 )
      @ 20, 5 SAY "  -- Progress by Product --  " 
      @ 22, 3      PROMPT " " 
      @ 22,COL()+2 PROMPT "1. Edit"
      @ 22,COL()+2 PROMPT "2. Add New"
      @ 22,COL()+2 PROMPT "3. Print"
      @ 22,COL()+2 PROMPT "4. Delete"
      @ 22,COL()+2 PROMPT "5. Review"
      @ 22,COL()+2 PROMPT "6. Exit"
      MENU TO nselect

      DO CASE
         CASE nselect == 7 .OR. PressedEsc()
              RETURN NIL
         CASE nselect == 1                // Loop   
             LOOP 

         CASE nselect == 2                // Edit Progress 
            mcorrect := "Y"
            DO WHILE mcorrect = "Y"
      aPart_:={}
      nrecno   := 0
      SELECT Progress
      GOTO TOP
      DO WHILE Progress->( !EOF() )
         IF Progress->Desc != SPACE( 40 )
            SKIP ALIAS Progress
            LOOP
         ENDIF
         IF Progress->Operno != coperno
            SKIP ALIAS Progress
            LOOP
         ENDIF
         AADD( aPart_,Progress->Operno;
                      +"  "+Progress->Order; 
                      +"  "+Progress->DescProg;
                      +"                           "+STR( RECNO(),6 ) )
         SKIP ALIAS Progress
      ENDDO                        // Progress EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3,40, 24,79, 2 )
         anum := ACHOICE(  4,42, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         GOTO nrecno
         coperno := Progress->Operno 
      ENDIF                        // Empty
               SELECT Progress
               DISPBOX(  8, 0, 18,39, 2 )
               nl :=  9
               @ nl,10 SAY Progress->Operno+"  "+Progress->Order;
                          +"  "+Progress->DescProg COLOR "RG+"
               nl+=2
                ApRlock( 3 )
               @ nl, 5 SAY "Product "+coperno
               nl+=2
               @ nl, 5 SAY "Order" GET Progress->Order    PICTURE "99"
               nl+= 2
               @ nl, 5 SAY " Desc" GET Progress->DescProg PICTURE "!XXXXXXXXXXX"
               nl+= 2
               @ nl,20 SAY "Esc to Exit" COLOR "BG+" 
                READ
               UNLOCK
               IF PressedEsc()
                  mcorrect := "N" 
                  ProgDesc()
               ENDIF
            ENDDO  
            LOOP

         CASE nselect == 3                // Add Progress   
            mcorrect := "Y"
            DO WHILE mcorrect = "Y"
      aPart_:={}
      nrecno   := 0
      SELECT Progress
      GOTO TOP
      DO WHILE Progress->( !EOF() )
         IF Progress->Desc != SPACE( 40 )
            SKIP ALIAS Progress
            LOOP
         ENDIF
         IF Progress->Operno != coperno
            SKIP ALIAS Progress
            LOOP
         ENDIF
         AADD( aPart_,Progress->Operno;
                      +"  "+Progress->Order; 
                      +"  "+Progress->DescProg;
                      +"                           "+STR( RECNO(),6 ) )
         SKIP ALIAS Progress
      ENDDO                        // Progress EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3,40, 24,79, 2 )
         anum := ACHOICE(  4,42, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         GOTO nrecno
         coperno := Progress->Operno 
      ENDIF                        // Empty
               @  6, 5 SAY "Maximum 18 entries" COLOR "BG+"
               DISPBOX(  8, 0, 18,39, 2 )
               nl := 9
               @ nl,10 SAY Progress->Operno+"  "+Progress->Order;
                          +"  "+Progress->DescProg COLOR "RG+"
               SELECT Progress
                ApFlock( 3 )
               APPEND BLANK
               Progress->Operno := coperno
               Progress->Date    := DATE()
               UNLOCK
               nl+=2
                ApRlock( 3 )
               @ nl, 5 SAY "Group "+coperno
               nl+=2
               @ nl, 5 SAY "Order" GET Progress->Order    PICTURE "99"
               nl+= 2
               @ nl, 5 SAY " Desc" GET Progress->DescProg PICTURE "!XXXXXXXXXXX"
               nl+= 2
               @ nl,20 SAY "Esc to Exit" COLOR "BG+"  
                READ
               UNLOCK
               IF PressedEsc()
                  mcorrect := "N" 
                  ProgDesc()
               ENDIF
            ENDDO  
            LOOP

         CASE nselect == 4                 // Print
      mwhere := "S"
      npl    := 20
      nl     := 0
      
       Printsel()                               // _LF_Init

      IF mwhere == "P"
         npl := 64
         @  0, 0
         SET DEVICE TO PRINT
      ENDIF
      @ nl, 2 SAY Control->U_Name
      @ nl,42 SAY "Progress"
      @ nl,62 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
                 +STR(YEAR(DATE()),5)
      nl+=2
      SELECT Progress
      GOTO TOP
      DO WHILE Progress->( !EOF() )
         IF Progress->DescProg = "         "
            SKIP ALIAS Progress
            LOOP
         ENDIF
         @ nl, 1 SAY Progress->Operno
         @ nl,11 SAY Progress->Order
         @ nl,14 SAY Progress->DescProg
         nl++
         IF nl > npl
            IF mwhere = "P"
               EJECT
              ELSE
               INKEY( 0 )
               SCROLL()
            ENDIF
            nl := 0 
         ENDIF             // npl
         SKIP ALIAS Progress
      ENDDO                        // Progress EOF
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
              LOOP

         CASE nselect == 5                     // Delete Progress
              SCROLL(  14, 0, 19,80 )
              DISPBOX( 14, 1, 19,79, 2 )
              nl := 16
              @ nl, 5 SAY Progress->Operno+"  "+Progress->DescProg;
                          +" "+Progress->Order+" "+Progress->Desc COLOR "BG+"
               cstring := TRIM( Message->Suredel )
               mok := ApCheck( cstring )                     // AppX.PRG
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               IF mok == "Y"
                   ApFLock( 3 )
                  DELETE
                  UNLOCK
               ENDIF
               LOOP

         CASE nselect == 6                     // Review Progress
        mcontinue := "Y"
        DO WHILE mcontinue = "Y"
          crate := "N"
          aPart_:={}
          nrecno   := 0
          SELECT Progress
      GOTO TOP
      DO WHILE Progress->( !EOF() )
         IF Progress->Desc != SPACE( 40 )
            SKIP ALIAS Progress
            LOOP
         ENDIF
         AADD( aPart_,Progress->Operno;
                      +"  "+Progress->Order; 
                      +"  "+Progress->DescProg;
                      +"                           "+STR( RECNO(),6 ) )
         SKIP ALIAS Progress
      ENDDO                        // Progress EOF
          SCROLL() 
          DISPBOX( 0, 0, 2,45, 2 )
          @  1,17 SAY "Product Progress   "+coperno 
          @  1,62 SAY "Esc to Exit" COLOR "G+"
          DISPBOX( 3, 0, 24,45, 2 )
          IF !EMPTY( aPart_ )
             ASORT( aPart_,,,{ | x,y | x < y } )
             anum := ACHOICE( 4, 3, 23,42, aPart_,,"AFUNC" )
             IF LASTKEY() = 27
                EXIT
             ENDIF  
             nrecno := VAL( RIGHT( aPart_[anum],6 ) )
             GOTO nrecno
          ENDIF
           coperno   := Progress->Operno
           corder    := Progress->Order
           cdescprog := Progress->DescProg

           @ ROW(), 2 GET coperno   PICTURE "@X"
           @ ROW(),12 GET corder    PICTURE "99"
           @ ROW(),17 GET cdescprog PICTURE "!XXXXXXXXXXX"
           @ ROW(),34 GET crate VALID( crate $ "NY " ) PICTURE "@!"
            READ
             ApRLock( 3 )
           Progress->Operno   := coperno 
           Progress->Order    := corder 
           Progress->DescProg := cdescProg 
           IF crate = "Y"
              DELETE
           ENDIF
           UNLOCK
           IF LASTKEY() = 27
              mcontinue := "N" 
              ProgDesc()
           ENDIF  
           LOOP 
      ENDDO                                        // mcontinue

      ENDCASE
      manother := "Y" 
      **** ApGetY( Message->Another )
   ENDDO                                       // manother

   RETURN NIL
   ***--- End ProgDesc()

   ****----------------------------------------------------------------------

STATIC FUNCTION AdminABC()
   SCROLL()
   DISPBOX( 0, 1, 2,79, 2 )
   @ 1, 8 SAY "Viewing Administration  "+Admin->Adminno COLOR "BG+"
   DISPBOX( 0, 1, 24,79, 2 )
   SELECT Admin
   nselect := 1
   DO CASE 
      CASE Admin->ABC = Menu1->Accom1
         nselect := 1
      CASE Admin->ABC = Menu1->Accom2
         nselect := 2
      CASE Admin->ABC = Menu1->Accom3
         nselect := 3
      CASE Admin->ABC = Menu1->Accom3
         nselect := 3
      CASE Admin->ABC = Menu1->Accom4
         nselect := 4
      CASE Admin->ABC = Menu1->Accom5
         nselect := 5
      CASE Admin->ABC = Menu1->Accom5
         nselect := 5
      CASE Admin->ABC = Menu1->Accom6
         nselect := 5
      CASE Admin->ABC = Menu1->Accom7
         nselect := 7
      CASE Admin->ABC = Menu1->Accom8
         nselect := 8
      CASE Admin->ABC = Menu1->Accom9
         nselect := 9
   ENDCASE
   @  5,58 SAY "Admin ABC = "+Admin->ABC
   @  6,58 PROMPT "1."+Menu1->Accom1
   @  7,58 PROMPT "2."+Menu1->Accom2
   @  8,58 PROMPT "3."+Menu1->Accom3
   @  9,58 PROMPT "4."+Menu1->Accom4
   @ 10,58 PROMPT "5."+Menu1->Accom5
   @ 11,58 PROMPT "6."+Menu1->Accom6
   @ 12,58 PROMPT "7."+Menu1->Accom7
   @ 13,58 PROMPT "8."+Menu1->Accom8
   @ 14,58 PROMPT "9."+Menu1->Accom9
   MENU TO nselect
   SELECT Admin
    ApRlock( 3 )
   DO CASE
      CASE nselect == 1
         Admin->ABC := Menu1->Accom1
      CASE nselect == 2
         Admin->ABC := Menu1->Accom2
      CASE nselect == 3
         Admin->ABC := Menu1->Accom3
      CASE nselect == 4
         Admin->ABC := Menu1->Accom4
      CASE nselect == 5
         Admin->ABC := Menu1->Accom5
      CASE nselect == 6
         Admin->ABC := Menu1->Accom6
      CASE nselect == 7
         Admin->ABC := Menu1->Accom7
      CASE nselect == 8
         Admin->ABC := Menu1->Accom8
      CASE nselect == 9
         Admin->ABC := Menu1->Accom9
   ENDCASE 
   @ 10, 6 SAY Admin->Adminno COLOR "BG+"
   @ 12, 6 SAY "Order" GET Admin->Adminno PICTURE "@X"
   @ 14, 6 SAY "Activ" GET Admin->Abc     PICTURE "@X"
   @ 16, 6 SAY "Desc " GET Admin->Desc    PICTURE "@X"
   @ 18, 6 SAY "Date " GET Admin->Date    PICTURE "99/99/9999"
    READ
   UNLOCK

   RETURN NIL

FUNCTION JobAdmin()

   SELECT Admin
      *** IF LASTREC() != 0
   cadminno := SPACE( 8 ) 
   manother := "Y"
   DO WHILE manother = "Y"
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @ 1, 8 SAY "Viewing Administration"
      aPart_:={}
      nrecno   := 0
      GOTO TOP
      DO WHILE Admin->( !EOF() )
         AADD( aPart_,Admin->Adminno;
                      +" "+Admin->Desc+"  "+Admin->ABC;
                      +"                          "+STR( RECNO(),6 ) )
         SKIP ALIAS Admin
      ENDDO                        // Admin EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 1, 24,79, 2 )
         anum := ACHOICE(  4, 5, 23,76, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         SCROLL(  8, 0, 24,80 )
         DISPBOX( 8, 1, 19,79, 2 )
         @ 10, 6 SAY Admin->Adminno COLOR "BG+" 
         @ 12, 6 SAY "Activ "+Admin->Abc  PICTURE "@X"
         @ 14, 6 SAY "Desc  "+Admin->Desc PICTURE "@X"
         @ 16, 6 SAY Admin->Date          PICTURE "99/99/9999"
         IF PressedEsc()
            RETURN NIL
         ENDIF
         cadminno := Admin->Adminno 
      ENDIF                        // Empty
      nselect  := 1
      SCROLL(  20, 0, 24,80 )
      DISPBOX( 20, 1, 24,79, 2 )
      @ 22, 8      PROMPT "Add Admin"
      @ 22,COL()+2 PROMPT "Edit Admin"
      @ 22,COL()+2 PROMPT "Delete"
      @ 22,COL()+2 PROMPT "Exit"
      MENU TO nselect
      DO CASE
         CASE nselect == 4 .OR. PressedEsc()
              RETURN NIL

         CASE nselect == 1                // Add Admin   
            SCROLL()
         cadbc := SPACE( 12 )
      @  4,58 SAY Menu1->Record PICTURE "9999"
      @  6,58 PROMPT "1."+Menu1->Accom1
      @  7,58 PROMPT "2."+Menu1->Accom2
      @  8,58 PROMPT "3."+Menu1->Accom3
      @  9,58 PROMPT "4."+Menu1->Accom4
      @ 10,58 PROMPT "5."+Menu1->Accom5
      @ 11,58 PROMPT "6."+Menu1->Accom6
      @ 12,58 PROMPT "7."+Menu1->Accom7
      @ 13,58 PROMPT "8."+Menu1->Accom8
      @ 14,58 PROMPT "9."+Menu1->Accom9
      MENU TO nselect
      SELECT Admin
      DO CASE
         CASE nselect == 1
            cABC := Menu1->Accom1
         CASE nselect == 2
            cABC := Menu1->Accom2
         CASE nselect == 3
            cABC := Menu1->Accom3
         CASE nselect == 4
            cABC := Menu1->Accom4
         CASE nselect == 5
            cABC := Menu1->Accom5
         CASE nselect == 6
            cABC := Menu1->Accom6
         CASE nselect == 7
            cABC := Menu1->Accom7
         CASE nselect == 8
            cABC := Menu1->Accom8
         CASE nselect == 9
            cABC := Menu1->Accom9
      ENDCASE
         SELECT Menu1  
           ApFLock( 3 )
          Menu1->Record := ( Menu1->Record+1 )
          @  2, 2 SAY "Printing Order you can Change" GET Menu1->Record PICTURE "9999"
           READ
          UNLOCK
          nserno := Menu1->Record
          mserno := STR( nserno,4 )
            SELECT Admin
      ***         SCROLL()
      ***         DISPBOX( 0, 0, 19,79, 2 )
            cadminno := TRIM( cABC )+LTRIM( mserno )  
            @ 10,10 SAY "Ref #"  GET cadminno PICTURE "@!"
             READ
            SEEK cadminno
            DO WHILE FOUND()
               @ 10,40 SAY "Already Used Try Again"
               @ 10,10 SAY "Ref #" GET cadminno PICTURE "@!"
                READ
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               SEEK cadminno
            ENDDO
            IF !FOUND()
                ApFlock( 3 )
               APPEND BLANK
               Admin->Adminno := cadminno
               Admin->Date    := DATE()
               UNLOCK
            ENDIF
             ApRlock( 3 )
            Admin->Abc := cAbc 
            @ 12, 6      SAY Admin->Adminno      COLOR "BG+" 
            @ 12,COL()+2 SAY "Activity "+Admin->Abc COLOR "BG+"
            @ 14, 6      SAY "Desc " GET Admin->Desc PICTURE "@X"
            @ 16, 6      SAY "Date " GET Admin->Date PICTURE "99/99/9999"
             READ
            UNLOCK
      ***          AdminAbc()
            LOOP

         CASE nselect == 2                // Admin Edit  
             AdminAbc()
            LOOP

         CASE nselect == 3                     // Delete Admin
               SCROLL(  19, 0, 24,80  )
               cstring := TRIM( Message->Suredel )
               mok := ApCheck( cstring )                     // AppX.PRG
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               IF mok == "Y"
                   ApFLock( 3 )
                  DELETE
                  UNLOCK
               ENDIF
            LOOP
      ENDCASE
      manother := ApGetY( Message->Another )
   ENDDO                                       // manother

   RETURN NIL
   ***--- End JobAdmin()

   ****----------------------------------------------------------

FUNCTION JobLabour()

   minvno  := "20"+SPACE( 4 ) 
   mcodeno := SPACE( 8 )
   SCROLL()
   DISPBOX( 12, 1, 16,79, 2 )
   @ 14,10      SAY "JC- or Invno" GET minvno   PICTURE "@!"
   @ 14,COL()+2 SAY "Blank to View JC- or Invoice" 
    READ
   IF PressedEsc()
      RETURN NIL
   ENDIF
   SELECT Debit
   SET ORDER TO 2                      // Invno
   GOTO TOP
   SEEK minvno
   SELECT Debit
   SET ORDER TO 1  
   IF FOUND()
      minvno  := Debit->Invno
      mcodeno := Debit->Codeno
   ENDIF
   IF !FOUND() .OR. minvno = SPACE( 6 )
   ***      SELECT Debit
   ***      SET ORDER TO 1
      GOTO TOP  
      aPart_ := {}
      nrecno := 0
      DO WHILE Debit->( !EOF() )
         IF Debit->Stat != "J"
            SKIP ALIAS Debit
            LOOP
         ENDIF
         AADD( aPart_,Debit->Invno+" "+Debit->Stat;
              +" "+Debit->Codeno;
              +" "+DTOC( Debit->Dbdate );
              +" "+STR( Debit->Amount, 8, 2 )+" "+Debit->Saleno;
              +" "+Debit->Est+"                        "+STR( RECNO(),6 ) )
         SKIP ALIAS Debit
      ENDDO
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX(  0, 0, 24,79, 2 )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum   := ACHOICE(  1, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
         IF PressedEsc()
            RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
         GOTO nrecno
         minvno  := Debit->Invno
         mcodeno := Debit->Codeno
      ENDIF                     // Empty
   ENDIF                        // LastRec    
   manother := "Y"
   DO WHILE manother = "Y"
      SELECT Name
      SEEK Debit->Codeno
      clabno := SPACE( 8 )
      aPart_:={}
      nrecno := 0
      SELECT Labour
      SET ORDER TO 2                   // Invno
      GOTO TOP
      DO WHILE Labour->( !EOF() )
    ***    IF minvno != SPACE( 6 )
            IF Labour->Invno != minvno
               SKIP ALIAS Labour
               LOOP
            ENDIF
    ***     ENDIF                            // minvno
         AADD( aPart_,Labour->Invno;
                      +" "+Labour->Codeno;
                      +" "+SUBSTR( Labour->Desc, 1,24 );
                      +" "+STR( Labour->Time, 7, 2 );
                      +" "+STR( Labour->Rate, 7, 2 );
                      +" "+DTOC( Labour->Date );
                      +" "+Labour->Labno;
                      +"     "+STR( RECNO(),6 ) )
      ***      minvno := Labour->Invno
         SKIP ALIAS Labour
      ENDDO                        // Labour EOF
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @  1, 6 SAY Name->Name+"  "+Debit->Invno COLOR "BG+"    
         ASORT( aPart_,,,{ | x,y | x < y } )
         DISPBOX( 3, 1,24,79, 2 )
         anum := ACHOICE(  4, 3,23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
         GOTO nrecno
         clabno  := Labour->Labno 
      ***      mcodeno := Labour->Codeno
      ENDIF                        // Empty
      SELECT Labour
      SET ORDER TO 1               // Codeno
      nselect := 1
      SCROLL(  20, 0, 24,80 )
      DISPBOX( 20, 1, 24,79, 2 )
      @ 20,10      SAY "  -- Labour --  "
      @ 22,10      PROMPT "Add Labour"
      @ 22,COL()+2 PROMPT "Edit Labour"
      @ 22,COL()+2 PROMPT "Print JC"

      @ 23,10      PROMPT "Delete Entry"
      @ 23,COL()+2 PROMPT "Delete General"

      MENU TO nselect
      DO CASE
         CASE PressedEsc()
              RETURN NIL
         CASE nselect == 1                // Add Labour   

   SELECT Name
   GOTO TOP
   cStaffCode := SPACE( 8 )
   aPart_:={}
   nrecno := 0
   IF LASTREC() != 0
      DO WHILE  Name->( !EOF() )
         IF Name->Sale != "STAF"
            SKIP ALIAS Name
            LOOP
         ENDIF  
         AADD( aPart_,( Name->Codeno+"   "+SUBSTR( Name->Name,1,26 );
                    +" "+SUBSTR( Name->Add1,1,20 );
                   +" "+Name->Phone;
                   +"                          "+STR( RECNO(),6 ) ) )
         SKIP ALIAS Name
      ENDDO
      SCROLL()
      DISPBOX( 0, 1,  2,79, 2 )
      @  1,10 SAY "Adding Labour Name"
      DISPBOX( 3, 1, 21,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aCatcode_,,,{ | x,y | x < y } )
         anum := ACHOICE( 4, 5, 20,76,aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         GOTO nrecno
         cStaffcode := Name->Codeno
      ENDIF
   ENDIF           // LastRec
   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      SELECT Name
      SEEK cStaffcode
      @ 1, 6 SAY cStaffcode+"  "+Name->Name COLOR "BG+"
        SELECT Labour
         ApFLock( 3 )
        APPEND BLANK
        Labour->Codeno := cStaffCode
        Labour->Date   := DATE() 
        Labour->Invno  := Debit->Invno
        Labour->Desc   := Debit->Est   
        Labour->Labno  := Debit->Codeno
        UNLOCK
        mdesc    := Labour->Desc
        mmessage := Labour->Message
        mfault   := Labour->Fault
        ntime    := Labour->Time
        nrate    := Labour->Rate
        ddate    := Labour->Date
        SCROLL(  14, 0,24,80 )
        DISPBOX( 14, 1,22,79, 2 )
        @ 15, 5      SAY Labour->Labno+" JC- "+Labour->Invno
        @ 17, 5      SAY "Labour Desc" GET mdesc     PICTURE "@K"
        @ 18,17                        GET mmessage  PICTURE "@K"
        @ 19,17                        GET mfault    PICTURE "@K"
        @ 21, 5      SAY "Labour Time" GET ntime     PICTURE "99.99"
      ***     @ 21,COL()+2 SAY "Cost"        GET nrate     PICTURE "99999.99"
        @ 21,COL()+2                   GET ddate     PICTURE "99/99/9999"
          READ
          ApFLock( 3 )
        Labour->Desc    := mdesc
        Labour->Message := mmessage
        Labour->Fault   := mfault
        Labour->Time    := ntime
        Labour->Rate    := nrate
        Labour->Date    := ddate
        UNLOCK
        mcontinue := ApGetY( Message->Another )
   ENDDO                                       // manother
         LOOP

         CASE nselect == 2                // Edit Labour   
            SELECT Name
            SEEK Labour->Codeno
            SCROLL()
            DISPBOX( 0, 1, 2,79, 2 )
            @ 1, 8 SAY mcodeno+" "+Name->Name
            DISPBOX( 3, 1, 18,79, 2 )
            nl:= 5
            SELECT Labour
            minvno   := Labour->Invno
            mlabno   := Labour->Labno
            mdesc    := Labour->Desc
            mmessage := Labour->Message
            mfault   := Labour->Fault
            mpartnum := Labour->Partnum
            mcodeno  := Labour->Codeno
            ntime    := Labour->Time
            nrate    := Labour->Rate
            ddate    := Labour->Date
            @ nl,10      SAY "Ref #"       GET mlabno   PICTURE "@!"
            @ nl,COL()+2 SAY "Desc"        GET mdesc    PICTURE "@X"
            nl++
            @ nl,15                        GET mmessage PICTURE "@X"
            nl++
            @ nl,15                        GET mfault   PICTURE "@X"
            nl+=2
            @ nl,10      SAY "Date"        GET ddate   PICTURE "99/99/9999"
            @ nl,COL()+2 SAY "Time"        GET ntime   PICTURE "99999.99"
            @ nl,COL()+2 SAY "Cost"        GET nrate   PICTURE "99999.99"
            nl+=2
            @ nl,10      SAY "JC-"         GET minvno
            @ nl,COL()+2 SAY "Partnum"     GET mpartnum
            nl+=2
            @ nl,10      SAY "Name Codeno" GET mcodeno
             READ
             ApRlock( 3 )
            Labour->Desc    := mdesc
            Labour->Message := mmessage
            Labour->Fault   := mfault
            Labour->Time    := ntime
            Labour->Rate    := nrate
            Labour->Date    := ddate
            Labour->Invno   := minvno
            Labour->Labno   := mlabno
            Labour->Partnum := mpartnum
            Labour->Codeno  := mcodeno
            UNLOCK
            LOOP
         CASE nselect == 3                //  Print Labour   
            Labprint()           // 
            LOOP

         CASE nselect == 4                // Delete Job
            SCROLL(  12, 0, 24,80  )
            DISPBOX( 12, 1,18,79, 2 )
            @ 13, 6      SAY Labour->Codeno+"     "+Labour->Labno
            @ 15, 6      SAY "Desc        "+Labour->Desc
            @ 15,COL()+2 SAY "Date "+DTOC( Labour->Date )
            @ 17, 6      SAY "Time "+STR( Labour->Time )
            @ 17,COL()+2 SAY "JC- "+Labour->Invno
            minvno  := Labour->Invno
            cstring := TRIM( Message->Suredel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF mok == "Y"
                ApFLock( 3 )
               DELETE
               UNLOCK
      ***            mdelete := ApGetN( "Delete ALL FOR INVOICE" )
      ***            IF mdelete == "Y"
      ***                ApFLock( 3 )         
      ***               DELETE ALL FOR Labour->Invno = minvno
      ***               UNLOCK
      ***            ENDIF
            ENDIF
         CASE nselect == 5
            SCROLL(  14, 0,24,80  )
            DISPBOX( 14, 1,19,79, 2 )
            nDays := 60
            @ 15, 5 SAY "Delete's All for Labour Invno 1st Char = Blank" 
            @ 16, 5 SAY "How Many Days Back (Minimum 30 days )" GET nDays PICTURE "999"
             READ   
            IF nDays < 30
               nDays := 30
               @ 17, 5 SAY "Minimum is 30 so Changed to 30"         
            ENDIF 
            mok := ApGetN( "Delete as above" )
            IF mok = "Y"
               SELECT Labour
               GOTO TOP
                ApFLock( 3 )
               DELETE ALL FOR SUBSTR( Labour->Invno, 1, 1 ) = SPACE( 1 );
                              .AND. Labour->Date < DATE()-nDays
               UNLOCK
            ENDIF
            LOOP
      ENDCASE
      manother := "Y"
      ***  ApGetY( Message->Another )
   ENDDO                                       // manother

   RETURN NIL
   ***--- End JobLabour()

   *****-------------------------------------------------------------------------

FUNCTION JobDemAdd( mjobnum )

   manother := "Y"
   DO WHILE manother = "Y"
      coperno:= cadminno:= cdrawno := SPACE( 8 )
      aPart_:={}
      nrecno  := 0
      SCROLL(  0, 0, 2,80 )
      DISPBOX( 0, 1, 2,79, 2 )
      @ 1,10 SAY Job->Jobnum+" "+TRIM( Job->Desc )+" "+Job->Codeno
      mjobnum := Job->Jobnum
      SELECT Demand
      SET ORDER TO 1                   // Operno
      SEEK mjobnum
      DO WHILE Demand->Jobnum = mjobnum .AND. Demand->( !EOF() )
         AADD( aPart_,LTRIM( Demand->Operno )+LTRIM( Demand->Adminno );
                      +LTRIM( Demand->Drawno );
                      +"  "+Demand->Desc;
                      +"  "+DTOC( Demand->StartDate);
                      +"  "+DTOC( Demand->DueDate);
                      +"     "+STR( RECNO(),6 ) )
         SKIP ALIAS Demand
      ENDDO                        // Operate EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 1, 18,79, 2 )
         anum := ACHOICE(  4, 5, 17,76, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
   /*  TAKEN OUT
         SCROLL(  9, 0, 24,80 )
         DISPBOX( 9, 1, 18,79, 2 )
         nl := 10
         @ nl, 7 SAY Demand->Operno+" "+Demand->Adminno+" "+Demand->Drawno;
                     +" "+DTOC( Demand->StartDate ) 
          ApRlock( 3 )
         @ nl,15      SAY "Desc "      GET Demand->Desc PICTURE "@X"
         nl+=2
         @ nl,12      SAY "Start Date" GET Demand->StartDate PICTURE "99/99/9999"
         @ nl,COL()+2 SAY "Due Date"   GET Demand->DueDate   PICTURE "99/99/9999"
          READ
         coperno  := Demand->Operno 
         cadminno := Demand->Adminno
         cdrawno  := Demand->Drawno
         UNLOCK 
   */
      ENDIF                        // Empty
      nselect  := 1
      SCROLL(  20, 0, 24,80 )
      DISPBOX( 20, 1, 24,79 )
      @ 22, 5      PROMPT "Exit"
      @ 22,COL()+2 PROMPT "Process Add"
      @ 22,COL()+1 PROMPT "Del Proc"
      @ 22,COL()+1 PROMPT "Admin Add"
      @ 22,COL()+1 PROMPT "Del Admin"
      @ 22,COL()+1 PROMPT "Drawing Add"
      @ 22,COL()+1 PROMPT "Del Draw"

      MENU TO nselect
      DO CASE
         CASE nselect == 1 .OR. PressedEsc()
              RETURN NIL
         CASE nselect == 2                 // Add Operation   
            SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @ 1, 8 SAY "Viewing Part Operations"
         aPart_:={}
         nrecno   := 0
         SELECT Operate
         GOTO TOP
         DO WHILE Operate->( !EOF() )
            AADD( aPart_,Operate->Operno;
                         +" "+Operate->Desc;
                         +"                                    "+STR( RECNO(),6 ) )
            SKIP ALIAS Operate
         ENDDO                        // Operate EOF
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            SCROLL(  3, 0, 24,80 )
            DISPBOX( 3, 1, 18,79, 2 )
            anum := ACHOICE(  4, 5, 17,75, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            SCROLL(  9, 0, 24,80 )
            DISPBOX( 9, 1, 18,79, 2 )
            @ 10,10 SAY Operate->Operno 
            @ 12,10 SAY "Desc "+Operate->Desc
            coperno := Operate->Operno
         ENDIF                        // Empty
         SELECT Demand
          ApFlock( 3 )
         APPEND BLANK
         Demand->Jobnum    := mjobnum
         Demand->Operno    := coperno
         Demand->StartDate := DATE()
         Demand->DueDate   := DATE()+30
         nl :=14
         @ nl,10      SAY "Demand Desc" GET Demand->Desc      PICTURE "@X"
         nl+=2
         @ nl,11      SAY "Start Date"  GET Demand->StartDate PICTURE "99/99/9999"
         @ nl,COL()+2 SAY "Due Date"    GET Demand->DueDate   PICTURE "99/99/9999"
          READ
         UNLOCK
         LOOP

         CASE nselect == 3                 // Delete Operation
      SELECT Demand
      aPart_:={}
      nrecno  := 0
      SET ORDER TO 1                       // Operno
      GOTO TOP
      SEEK mjobnum 
      DO WHILE Demand->Jobnum = mjobnum .AND. Demand->( !EOF() )
         IF Demand->Operno = SPACE( 8 )
            SKIP ALIAS Demand
            LOOP
         ENDIF
         SELECT Operate
         SEEK Demand->Operno
         SELECT Demand
         AADD( aPart_,Demand->Operno;
                      +" "+Operate->Desc;
                      +" "+SUBSTR( Demand->Desc,1,10 );
                      +"     "+STR( RECNO(),6 ) )
         SKIP ALIAS Demand
      ENDDO                        // Operate EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 1, 18,79, 2 )
         anum := ACHOICE(  4, 5, 17,76, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         SCROLL(  9, 0, 24,80 )
         DISPBOX( 9, 3, 18,79, 2 )
         nl := 10
         @ nl, 7 SAY Demand->Operno+" "+DTOC( Demand->StartDate ) 
            cstring := TRIM( Message->Suredel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF mok == "Y"
            ***    SEEK mjobnum+coperno
            ***    IF FOUND()
                    ApFLock( 3 )
                  DELETE
                  UNLOCK
            ***    ENDIF
            ENDIF 
         ENDIF                     // !Empty
         LOOP

        CASE nselect == 4                 // Add Admin   
            SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @ 1, 8 SAY "Viewing Administration"
         cadminno := SPACE( 8 )
         aPart_:={}
         nrecno   := 0
         SELECT Admin
         GOTO TOP
         DO WHILE Admin->( !EOF() )
            AADD( aPart_,Admin->Adminno;
                         +" "+Admin->Desc;
                         +" "+DTOC( Admin->Date );
                         +" "+STR( Admin->Quoted );
                         +"    "+STR( RECNO(),6 ) )
            SKIP ALIAS Admin
         ENDDO                        // Admin EOF
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            SCROLL(  3, 0, 24,80 )
            DISPBOX( 3, 1, 24,79, 2 )
            anum := ACHOICE(  4, 5, 23,75, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            SCROLL(  9, 0, 24,80 )
            DISPBOX( 9, 1, 19,79, 2 )
            @ 10,10 SAY Admin->Adminno+"  "+DTOC( Admin->Date ) 
            @ 12,10 SAY "Administration Desc "+Admin->Desc
            cadminno := Admin->Adminno
         ENDIF                        // Empty
         SELECT Demand
          ApFlock( 3 )
         APPEND BLANK
         Demand->Jobnum    := mjobnum
         Demand->Adminno   := cadminno
         Demand->StartDate := DATE()
         Demand->DueDate   := DATE()+30
         nl :=14
         @ nl,10      SAY "Demand Desc" GET Demand->Desc      PICTURE "@X"
         nl+=2
         @ nl,11      SAY "Start Date"  GET Demand->StartDate PICTURE "99/99/9999"
         @ nl,COL()+2 SAY "Due Date"    GET Demand->DueDate   PICTURE "99/99/9999"
          READ
         UNLOCK
         LOOP
      
         CASE nselect == 5                 // Delete Admin
      SELECT Demand
      aPart_:={}
      nrecno  := 0
      SET ORDER TO 2                       // Admin
      GOTO TOP
      SEEK mjobnum 
      DO WHILE Demand->Jobnum = mjobnum .AND. Demand->( !EOF() )
         IF Demand->Adminno = SPACE( 8 )
            SKIP ALIAS Demand
            LOOP
         ENDIF
         SELECT Admin
         SEEK Demand->Adminno
         SELECT Demand
         AADD( aPart_,Demand->Operno;
                      +" "+Admin->Desc;
                      +" "+SUBSTR( Demand->Desc,1,10 );
                      +"     "+STR( RECNO(),6 ) )
         SKIP ALIAS Demand
      ENDDO                        // Operate EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 1, 24,79, 2 )
         anum := ACHOICE(  4, 5, 23,76, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         SCROLL(  9, 0, 24,80 )
         DISPBOX( 9, 1, 18,79, 2 )
         nl := 10
         @ nl, 7 SAY Demand->Adminno+" "+DTOC( Demand->StartDate ) 
            SCROLL(  19, 0, 24,80  )
            mok := "N"
            cstring := TRIM( Message->Suredel )
             ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF mok == "Y"
                 ApFLock( 3 )
               DELETE
               UNLOCK
            ENDIF 
         ENDIF
         LOOP

        CASE nselect == 6                 // Add Drawing   
            SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @ 1, 8 SAY "Viewing Drawings"
         cdrawno := SPACE( 8 )
         aPart_:={}
         nrecno   := 0
         SELECT Drawing
         GOTO TOP
         DO WHILE Drawing->( !EOF() )
            AADD( aPart_,Drawing->Drawno;
                         +" "+Drawing->Desc;
                         +" "+DTOC( Drawing->Date )+" "+Drawing->Drawloc;
                         +"    "+STR( RECNO(),6 ) )
            SKIP ALIAS Drawing
         ENDDO                        // Drawing EOF
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            SCROLL(  3, 0, 24,80 )
            DISPBOX( 3, 1, 24,79, 2 )
            anum := ACHOICE(  4, 4, 23,76, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            SCROLL(  9, 0, 24,80 )
            DISPBOX( 9, 1, 20,79, 2 )
            @ 10,10 SAY Drawing->Drawno+"  "+DTOC( Drawing->Date ) 
            @ 12,10 SAY "Drawing Desc "+Drawing->Desc
            cdrawno := Drawing->Drawno
         ENDIF                        // Empty
         SELECT Demand
          ApFlock( 3 )
         APPEND BLANK
         Demand->Jobnum    := mjobnum
         Demand->Drawno    := cdrawno
         Demand->StartDate := DATE()
         Demand->DueDate   := DATE()+30
         nl :=14
         @ nl,10      SAY "Demand Desc" GET Demand->Desc      PICTURE "@X"
         nl+=2
         @ nl,11      SAY "Start Date"  GET Demand->StartDate PICTURE "99/99/9999"
         @ nl,COL()+2 SAY "Due Date"    GET Demand->DueDate   PICTURE "99/99/9999"
          READ
         UNLOCK
         LOOP

         CASE nselect == 7                 // Delete Drawing
      SELECT Demand
      aPart_:={}
      nrecno  := 0
      SET ORDER TO 3                       // Drawing
      GOTO TOP
      SEEK mjobnum 
      DO WHILE Demand->Jobnum = mjobnum .AND. Demand->( !EOF() )
         IF Demand->Drawno = SPACE( 8 )
            SKIP ALIAS Demand
            LOOP
         ENDIF
         SELECT Drawing
         SEEK Demand->Drawno
         SELECT Demand
         AADD( aPart_,Demand->Operno;
                      +" "+Drawing->Desc;
                      +" "+SUBSTR( Demand->Desc,1,10 );
                      +"     "+STR( RECNO(),6 ) )
         SKIP ALIAS Demand
      ENDDO                        // Operate EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 1, 24,79, 2 )
         anum := ACHOICE(  4, 5, 23,76, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         SCROLL(  9, 0, 24,80 )
         DISPBOX( 9, 1, 18,79, 2 )
         nl := 10
         @ nl, 7 SAY Demand->Drawno+" "+DTOC( Demand->StartDate ) 
            SCROLL( 19, 0, 24,80 )
            cstring := TRIM( Message->Suredel )
            mok := ApCheck( cstring )                     // AppX.PRG
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF mok == "Y"
                ApFLock( 3 )
               DELETE
               UNLOCK
            ENDIF 
         ENDIF
         LOOP
    
      ENDCASE
      manother := ApGetY( Message->Another )
   ENDDO                                       // manother

   RETURN NIL
   ***** End of JobDemAdd()

   ****---------------------------- End Of JOBDEM.PRG