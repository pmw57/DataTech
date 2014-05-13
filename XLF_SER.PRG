   *** JK 20-06-11 07:54:48 

/* 
   Program.....:                  XLF_SER.PRG
   Authors.....: J.Kirby
   Date........: 25/06/2009
   Functions...: OperDelete, OperLetter, Operselect
                 NameQuick
   Static funcs: OperReport, NamegetQK
*/

// (c) Copyright 1993 by Kirby Christchurch.

FUNCTION OperDelete()

   coperno := SPACE( 8 )  
   GroupSelect( @coperno )                // XLF_QU9.Prg
   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      SELECT PartOper
      SET ORDER TO 2                  // operno
      GOTO TOP
      crate  := "N"
      canother := "N"
      nrecno := 0
      aPart_ := {}
      DO WHILE PartOper->( !EOF() ) 
         IF PartOper->Operno != coperno
            SKIP ALIAS PartOper
            LOOP
         ENDIF
         AADD( aPart_,PartOper->Desc;
            +" "+PartOper->Operno;
            +" "+PartOper->Adminno;
            +" Del "+crate; 
            +" Add "+canother; 
            +"                       "+STR( RECNO(),6 ) )
         SKIP ALIAS PartOper
      ENDDO                       // Operate EOF
      SCROLL() 
      DISPBOX( 0, 0, 2,79, 2 )
      @  1, 6      SAY coperno+ " Operations File " 
      @  1,COL()+3 SAY "Esc to Exit" COLOR "G+"
      @  1,62      SAY "Delete     Add" COLOR "RG+"
      DISPBOX( 3, 0, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 4, 3, 23,77, aPart_,,"AFUNC" )
         IF LASTKEY() = 27
            EXIT
         ENDIF  
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
      ENDIF
      cdesc1   := PartOper->Desc
      coperno  := PartOper->Operno
      cadminno := PartOper->Adminno   
      @ ROW(), 1 GET cdesc1   PICTURE "@X"
      @ ROW(),42 GET coperno  PICTURE "@!"
      @ ROW(),52 GET cadminno PICTURE "@!"
      @ ROW(),66 GET crate VALID( crate $ "NY " ) PICTURE "@!"
      @ ROW(),76 GET canother VALID( canother $ "NY " ) PICTURE "@!"
       READ
        ApRLock( 3 )
      PartOper->Operno  := coperno 
      PartOper->Adminno := cadminno 
      PartOper->Desc    := cdesc1 
      IF crate = "Y"
         DELETE
      ENDIF
      UNLOCK
      IF LASTKEY() = 27
         RETURN NIL
      ENDIF  
      IF canother = "Y"
         coperno := SPACE( 8 )  
         GroupSelect( @coperno )                // XLF_QU9.Prg
         mpart := SPACE( 16 )
         aPart_:={}
         nrecno  := 0
         SCROLL() 
         DISPBOX( 0, 1, 24,79, 2 )
         SELECT PartOper
         SET ORDER TO 2                    // Operno
         GOTO TOP
         SEEK coperno
         DO WHILE PartOper->Operno = coperno .AND. PartOper->( !EOF() )
            AADD( aPart_,PartOper->Operno;
               +" "+PartOper->Adminno;
               +" "+PartOper->Desc;
               +"                     "+STR( RECNO(),6 ) )
            SKIP ALIAS PartOper
         ENDDO                        // PartOper EOF
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum := ACHOICE(  1, 2, 23,78, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            mpart := SUBSTR( PartOper->Partnum, 1,16 )
         ENDIF                        // Empty
         cadminno := SPACE( 8 )
         cdesc    := SPACE( 40 )
         cadminno := SPACE( 8 )
         DO WHILE cadminno = "        "
            SCROLL( 18, 0, 24,80 )
            DISPBOX( 18, 1, 24,79, 2 )
            nl := 19
            @ nl,20 say "New Record  Must add Admino" COLOR "RG+"
            nl++
            nl++
            @ nl,10 SAY coperno PICTURE "@!"
            @ nl,COL()+2 SAY "Admino" GET cadminno PICTURE "@!"
            nl++
            @ nl,10 SAY "Description" GET cdesc PICTURE "@X"    
             READ
            IF PressedEsc()
               RETURN NIL
            ENDIF
            SELECT PartOper
             ApFlock( 3 )
            APPEND BLANK
            PartOper->Date    := DATE()
            PartOper->Operno  := coperno
            PartOper->Partnum := mpart
            PartOper->Adminno := cadminno
            PartOper->Desc    := cdesc
            UNLOCK
         ENDDO         // cadminno
         LOOP
         IF LASTKEY() = 27
            RETURN NIL
         ENDIF  
      ENDIF       // canother
   ENDDO                                        // mcontinue

   RETURN NIL
   ****---- End of OperDelete()

   ****-----------------------------------------------------------------------

FUNCTION OperLetter()

   mcontin := "Y"
   DO WHILE mcontin = "Y"
      SCROLL()
      SELECT Name
      GOTO TOP
      aPart_:={}
      DO WHILE Name->( !EOF() )
         AADD( aPart_,Name->Codeno+" "+Name->Sale+" "+;
                      Name->Accom+" "+Name->Letter )
          SKIP ALIAS Name
      ENDDO
      DISPBOX(  0,48, 24,79, 2 )
      IF !EMPTY( aPart_ )
          ASORT( aPart_,,,{ | x,y | x < y } )
          anum := ACHOICE( 1,50, 23,78,aPart_,,"AFUNC" )
      ENDIF
      caccom  := SPACE( 8 )
      nletter := SPACE( 4 )  
      csale   := SPACE( 4 )
      DISPBOX(  0, 0, 18,46, 2 )
      nsel := 1
      @  4, 5 SAY "Select 1. for editing Name details" COLOR "BG+"
      @  6, 5 PROMPT "1. Name     Sale"
      @  7, 5 PROMPT "2. Name Activity"
      @  8, 5 PROMPT "3. Name Position"
      @  9, 5 PROMPT "4. Exit         "
      MENU TO nsel
      DO CASE
         CASE nsel == 4 .OR. PressedEsc()
            mcontinue := "N"
            RETURN NIL
         CASE nsel == 1
            mcontinue := "Y"
            DO WHILE mcontinue = "Y"
               SELECT Name
               SCROLL()
               DISPBOX(  0, 0, 24,79, 2 )
               @  1, 5 SAY "Edit the Name file" COLOR "BG+"
               @  5,12 SAY Menu1->Mess01 PICTURE "@!" 
               @  6,12 SAY Menu1->Mess02 PICTURE "@!" 
               @  7,12 SAY Menu1->Mess03 PICTURE "@!" 
               @  8,12 SAY Menu1->Mess04 PICTURE "@!" 
               @  9,12 SAY Menu1->Mess05 PICTURE "@!" 
               @ 10,12 SAY Menu1->Mess06 PICTURE "@!" 
               @ 11,12 SAY Menu1->Mess07 PICTURE "@!" 
               @ 12,12 SAY Menu1->Mess08 PICTURE "@!" 
               @ 13,12 SAY Menu1->Mess09 PICTURE "@!" 
               @ 14,12 SAY Menu1->Mess10 PICTURE "@!" 
               @ 15,12 SAY Menu1->Mess11 PICTURE "@!" 
               @ 16,12 SAY Menu1->Mess12 PICTURE "@!" 
               @ 17,12 SAY Menu1->Mess13 PICTURE "@!"
               @ 18,12 SAY Menu1->Mess14 PICTURE "@!" 
               nselect := 1
               DO CASE
                  CASE Name->Sale == Menu1->Mess01
                    nselect := 1   
                  CASE Name->Sale == Menu1->Mess02
                    nselect := 2   
                  CASE Name->Sale == Menu1->Mess03
                    nselect := 3   
                  CASE Name->Sale == Menu1->Mess04
                    nselect := 4   
                  CASE Name->Sale == Menu1->Mess05
                    nselect := 5   
                  CASE Name->Sale == Menu1->Mess06
                    nselect := 6   
                  CASE Name->Sale == Menu1->Mess07
                    nselect := 7   
                  CASE Name->Sale == Menu1->Mess08
                    nselect := 8   
                  CASE Name->Sale == Menu1->Mess09
                    nselect := 9   
                  CASE Name->Sale == Menu1->Mess10
                    nselect := 10   
                  CASE Name->Sale == Menu1->Mess11
                    nselect := 11   
                  CASE Name->Sale == Menu1->Mess12
                    nselect := 12
                  CASE Name->Sale == Menu1->Mess13
                    nselect := 13   
                  CASE Name->Sale == Menu1->Mess14
                    nselect := 14   
               ENDCASE 
               msale   := SPACE( 4 )
               mchoice := 1
               @  5,12 PROMPT Menu1->Mess01  
               @  6,12 PROMPT Menu1->Mess02
               @  7,12 PROMPT Menu1->Mess03
               @  8,12 PROMPT Menu1->Mess04
               @  9,12 PROMPT Menu1->Mess05
               @ 10,12 PROMPT Menu1->Mess06
               @ 11,12 PROMPT Menu1->Mess07
               @ 12,12 PROMPT Menu1->Mess08
               @ 13,12 PROMPT Menu1->Mess09
               @ 14,12 PROMPT Menu1->Mess10
               @ 15,12 PROMPT Menu1->Mess11
               @ 16,12 PROMPT Menu1->Mess12
               @ 17,12 PROMPT Menu1->Mess13
               @ 18,12 PROMPT Menu1->Mess14
               @ 20,12 PROMPT "EDIT the Above"
               @ 21,12 PROMPT "16. Exit "
               MENU TO nselect
               DO CASE
                  CASE nselect == 16 .OR. PressedEsc()
                     mcontinue := "N"
                     *** EXIT
                  CASE nselect == 15
                     SELECT Menu1
                     ApFLock( 3 )
                     @  5,12 GET Menu1->Mess01 PICTURE "@!"
                     @  6,12 GET Menu1->Mess02 PICTURE "@!"
                     @  7,12 GET Menu1->Mess03 PICTURE "@!"
                     @  8,12 GET Menu1->Mess04 PICTURE "@!"
                     @  9,12 GET Menu1->Mess05 PICTURE "@!"
                     @ 10,12 GET Menu1->Mess06 PICTURE "@!"
                     @ 11,12 GET Menu1->Mess07 PICTURE "@!"
                     @ 12,12 GET Menu1->Mess08 PICTURE "@!"
                     @ 13,12 GET Menu1->Mess09 PICTURE "@!"
                     @ 14,12 GET Menu1->Mess10 PICTURE "@!"
                     @ 15,12 GET Menu1->Mess11 PICTURE "@!"
                     @ 16,12 GET Menu1->Mess12 PICTURE "@!"
                     @ 17,12 GET Menu1->Mess13 PICTURE "@!"
                     @ 18,12 GET Menu1->Mess14 PICTURE "@!"
                     @ 20,30 SAY "STAFF is for P.A.Y.E and Labour etc" 
                      READ
                     UNLOCK
               ENDCASE
               **** */  
               mcont := "Y"
               DO WHILE mcont = "Y"
                  SELECT Name
                  aPart_:={}
                  SCROLL()
                  GOTO TOP
                  DO WHILE Name->( !EOF() )
                     AADD( aPart_,Name->Name+" "+Name->Sale+" "+;
                        Name->Accom+" "+Name->Letter+" ";
                        +" "+Name->Codeno;
                        +"                   "+STR( RECNO(),6 ) )
                      SKIP ALIAS Name
                  ENDDO
                  DISPBOX( 0, 0, 24,79, 2 )
                  IF !EMPTY( aPart_ )
                      ASORT( aPart_,,,{ | x,y | x < y } )
                      anum := ACHOICE( 1, 3, 23,76,aPart_,,"AFUNC" )
                      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                      IF PressedEsc()
                         RETURN NIL
                      ENDIF
                      GOTO nrecno
                  ENDIF
                  SCROLL()
                  DISPBOX(  1, 0, 24,79, 2 )
                  @  2, 6 SAY Menu1->Mess01 PICTURE "@!" 
                  @  3, 6 SAY Menu1->Mess02 PICTURE "@!" 
                  @  4, 6 SAY Menu1->Mess03 PICTURE "@!" 
                  @  5, 6 SAY Menu1->Mess04 PICTURE "@!" 
                  @  6, 6 SAY Menu1->Mess05 PICTURE "@!" 
                  @  7, 6 SAY Menu1->Mess06 PICTURE "@!" 
                  @  8, 6 SAY Menu1->Mess07 PICTURE "@!" 
                  @  9, 6 SAY Menu1->Mess08 PICTURE "@!" 
                  @ 10, 6 SAY Menu1->Mess09 PICTURE "@!"
                  @ 11, 6 SAY Menu1->Mess10 PICTURE "@!"
                  @ 12, 6 SAY Menu1->Mess11 PICTURE "@!"
                  @ 13, 6 SAY Menu1->Mess12 PICTURE "@!"
                  @ 14, 6 SAY Menu1->Mess13 PICTURE "@!"
                  @ 15, 6 SAY Menu1->Mess14 PICTURE "@!"
                  @  2,22 SAY Menu1->Accom1 PICTURE "@!" 
                  @  3,22 SAY Menu1->Accom2 PICTURE "@!" 
                  @  4,22 SAY Menu1->Accom3 PICTURE "@!" 
                  @  5,22 SAY Menu1->Accom4 PICTURE "@!" 
                  @  6,22 SAY Menu1->Accom5 PICTURE "@!" 
                  @  7,22 SAY Menu1->Accom6 PICTURE "@!" 
                  @  8,22 SAY Menu1->Accom7 PICTURE "@!" 
                  @  9,22 SAY Menu1->Accom8 PICTURE "@!" 
                  @ 10,22 SAY Menu1->Accom9 PICTURE "@!" 
                  @  2,34 SAY Menu1->Letter1 PICTURE "@!" 
                  @  3,34 SAY Menu1->Letter2 PICTURE "@!" 
                  @  4,34 SAY Menu1->Letter3 PICTURE "@!" 
                  @  5,34 SAY Menu1->Letter4 PICTURE "@!" 
                  @  6,34 SAY Menu1->Letter5 PICTURE "@!" 
                  @  7,34 SAY Menu1->Letter6 PICTURE "@!" 
                  @  8,34 SAY Menu1->Letter7 PICTURE "@!" 
                  @  9,34 SAY Menu1->Letter8 PICTURE "@!" 
                  @ 10,34 SAY Menu1->Letter9 PICTURE "@!" 
                  SELECT Name
                  cdelete := "N"
                  @ 13,10 SAY Name->Name COLOR "BG+"
                   ApRLock( 3 )
                  @ 15,10 SAY "Sale     " GET Name->Sale   PICTURE "@!"
                  @ 16,10 SAY "Activity " GET Name->Accom  PICTURE "@!"
                  @ 17,10 SAY "Position " GET Name->Letter PICTURE "@!"
                  @ 18,10 SAY "Name     " GET Name->Name   PICTURE "@X"
                  @ 19,10 SAY "Delete   " GET cdelete      PICTURE "@!"        
                   READ
                  IF cdelete = "Y"
                     DELETE
                  ENDIF
                  UNLOCK
                  LOOP  
               ENDDO         // mcont
            ENDDO             // mcontinue

         CASE nsel == 2             // accom

         mcontinue := "Y"
         DO WHILE mcontinue = "Y"
            SCROLL()
            DISPBOX(  0, 0, 24,79, 2 )
            @  1, 5 SAY "Edit the Name file" COLOR "BG+"
            @  7,35 SAY Menu1->Accom1 PICTURE "@!" 
            @  8,35 SAY Menu1->Accom2 PICTURE "@!" 
            @  9,35 SAY Menu1->Accom3 PICTURE "@!" 
            @ 10,35 SAY Menu1->Accom4 PICTURE "@!" 
            @ 11,35 SAY Menu1->Accom5 PICTURE "@!" 
            @ 12,35 SAY Menu1->Accom6 PICTURE "@!" 
            @ 13,35 SAY Menu1->Accom7 PICTURE "@!" 
            @ 14,35 SAY Menu1->Accom8 PICTURE "@!" 
            @ 15,35 SAY Menu1->Accom9 PICTURE "@!" 
            nselect  := 1
            DO CASE
               CASE Name->Accom == Menu1->Accom1
                  nselect := 1   
               CASE Name->Accom == Menu1->Accom2
                  nselect := 2   
               CASE Name->Accom == Menu1->Accom3
                  nselect := 3   
               CASE Name->Accom == Menu1->Accom4
                  nselect := 4   
               CASE Name->Accom == Menu1->Accom5
                  nselect := 5   
               CASE Name->Accom == Menu1->Accom6
                  nselect := 6   
               CASE Name->Accom == Menu1->Accom7
                  nselect := 7   
               CASE Name->Accom == Menu1->Accom8
                  nselect := 8   
               CASE Name->Accom == Menu1->Accom9
                  nselect := 9   
            ENDCASE 
            @  6, 5 SAY Menu1->Record PICTURE "9999"
            @  7, 5 PROMPT Menu1->Accom1
            @  8, 5 PROMPT Menu1->Accom2
            @  9, 5 PROMPT Menu1->Accom3
            @ 10, 5 PROMPT Menu1->Accom4
            @ 11, 5 PROMPT Menu1->Accom5
            @ 12, 5 PROMPT Menu1->Accom6
            @ 13, 5 PROMPT Menu1->Accom7
            @ 14, 5 PROMPT Menu1->Accom8
            @ 15, 5 PROMPT Menu1->Accom9
            @ 17, 5 PROMPT "EDIT the Above     "
            @ 19, 5 PROMPT "11. Exit "
            MENU TO nselect
            DO CASE
               CASE nselect == 11  .OR. PressedEsc()
                  mcontinue := "N"
                  ***               EXIT
               CASE nselect == 10
                  SELECT Menu1
                   ApFLock( 3 )
                  @  6,14 GET Menu1->Record PICTURE "9999"
                  @  7,14 GET Menu1->Accom1 PICTURE "@!"
                  @  8,14 GET Menu1->Accom2 PICTURE "@!"
                  @  9,14 GET Menu1->Accom3 PICTURE "@!"
                  @ 10,14 GET Menu1->Accom4 PICTURE "@!"
                  @ 11,14 GET Menu1->Accom5 PICTURE "@!"
                  @ 12,14 GET Menu1->Accom6 PICTURE "@!"
                  @ 13,14 GET Menu1->Accom7 PICTURE "@!"
                  @ 14,14 GET Menu1->Accom8 PICTURE "@!"
                  @ 15,14 GET Menu1->Accom9 PICTURE "@!"
                  READ
                  UNLOCK
            ENDCASE
         ENDDO                // mcontinue
         LOOP
      CASE nsel == 3                // name letter
         mcontinue := "Y"
         DO WHILE mcontinue = "Y"
            SCROLL()
            DISPBOX(  0, 0, 24,79, 2 )
            @  2, 5 SAY "Edit the Letter file" COLOR "BG+"
            @  7,22 SAY Menu1->Letter1 PICTURE "@!" 
            @  8,22 SAY Menu1->Letter2 PICTURE "@!" 
            @  9,22 SAY Menu1->Letter3 PICTURE "@!" 
            @ 10,22 SAY Menu1->Letter4 PICTURE "@!" 
            @ 11,22 SAY Menu1->Letter5 PICTURE "@!" 
            @ 12,22 SAY Menu1->Letter6 PICTURE "@!" 
            @ 13,22 SAY Menu1->Letter7 PICTURE "@!" 
            @ 14,22 SAY Menu1->Letter8 PICTURE "@!" 
            @ 15,22 SAY Menu1->Letter9 PICTURE "@!" 
            nselect := 1
            DO CASE
               CASE Name->Letter == Menu1->Letter1
                  nselect := 1   
               CASE Name->Letter == Menu1->Letter2
                  nselect := 2   
               CASE Name->Letter == Menu1->Letter3
                  nselect := 3   
               CASE Name->Letter == Menu1->Letter4
                  nselect := 4   
               CASE Name->Letter == Menu1->Letter5
                  nselect := 5   
               CASE Name->Letter == Menu1->Letter6
                  nselect := 6   
               CASE Name->Letter == Menu1->Letter7
                  nselect := 7   
               CASE Name->Letter == Menu1->Letter8
                  nselect := 8   
               CASE Name->Letter == Menu1->Letter9
                  nselect := 9   
            ENDCASE 
            @  7, 5 PROMPT Menu1->Letter1
            @  8, 5 PROMPT Menu1->Letter2
            @  9, 5 PROMPT Menu1->Letter3
            @ 10, 5 PROMPT Menu1->Letter4
            @ 11, 5 PROMPT Menu1->Letter5
            @ 12, 5 PROMPT Menu1->Letter6
            @ 13, 5 PROMPT Menu1->Letter7
            @ 14, 5 PROMPT Menu1->Letter8
            @ 15, 5 PROMPT Menu1->Letter9
            @ 17, 5 PROMPT "EDIT the Above"
            @ 19, 5 PROMPT "11. Exit "
            MENU TO nselect
            DO CASE
               CASE nselect == 11 .OR. PressedEsc()
                  mcontinue := "N"
                  ***               EXIT
               CASE nselect == 10
                  SELECT Menu1
                   ApFLock( 3 )
                  @  7,12 GET Menu1->Letter1 PICTURE "@!"
                  @  8,12 GET Menu1->Letter2 PICTURE "@!"
                  @  9,12 GET Menu1->Letter3 PICTURE "@!"
                  @ 10,12 GET Menu1->Letter4 PICTURE "@!"
                  @ 11,12 GET Menu1->Letter5 PICTURE "@!"
                  @ 12,12 GET Menu1->Letter6 PICTURE "@!"
                  @ 13,12 GET Menu1->Letter7 PICTURE "@!"
                  @ 14,12 GET Menu1->Letter8 PICTURE "@!"
                  @ 15,12 GET Menu1->Letter9 PICTURE "@!"
                   READ
                  UNLOCK
            ENDCASE                // nselect
         ENDDO                        // mcontinue
      ENDCASE                         // nsel
   ENDDO                              // mcontin    

   RETURN NIL
   ***-------- End of OperLetter

   ****-------------------------------------------------------------------------

STATIC FUNCTION OperReport()

   SCROLL()
   cname := ApGetN( "Edit Name Group" )
   IF cname = "Y"
      OperLetter()                          // Above    
   ENDIF
   SCROLL()
   DISPBOX( 0, 0, 2,79, 2 )
   @ 1, 8 SAY "Viewing Administration"
   aPart_:={}
   SELECT Admin
   GOTO TOP
   DO WHILE Admin->( !EOF() )
      AADD( aPart_,Admin->Adminno;
                   +" "+Admin->Desc )
      SKIP ALIAS Admin
   ENDDO                        // Admin EOF
   IF !EMPTY( aPart_ )
      ASORT( aPart_,,,{ | x,y | x < y } )
      DISPBOX( 2, 0, 19,79, 2 )
      anum := ACHOICE(  3, 3, 18,76, aPart_,,"AFUNC" )
   ENDIF                        // Empty
   cadmin := ApGetN( "Edit Administration" )
   IF cadmin = "Y"
      JobAdmin()                            // JobDem.Prg    
   ENDIF
   SCROLL()
   SELECT Name
   GOTO TOP
    aPart_:={}
                DO WHILE Name->( !EOF() )
                   IF Name->Accom = SPACE( 8 )
                      SKIP ALIAS Name
                      LOOP
                   ENDIF
                   IF Name->Letter = SPACE( 4 )
                      SKIP ALIAS Name
                      LOOP
                   ENDIF
                   AADD( aPart_,Name->Sale+" "+;
                                Name->Accom+" "+Name->Letter+" "+;
                                Name->Codeno )
                    SKIP ALIAS Name
                ENDDO
                DISPBOX(  0,48, 24,79, 2 )
                IF !EMPTY( aPart_ )
                    ASORT( aPart_,,,{ | x,y | x < y } )
                    anum := ACHOICE( 1,50, 23,78,aPart_,,"AFUNC" )
                ENDIF
   caccom  := SPACE( 8 )
   nletter := SPACE( 4 )  
   csale   := SPACE( 4 )
      @ 2,20 SAY "Select Group for Printing"
            nselect  := 1
            nl := 6
            nl++  
            @ nl, 4 PROMPT Message->Mess01
            nl++ 
            @ nl, 4 PROMPT Message->Mess02
            nl++
            @ nl, 4 PROMPT Message->Mess03
            nl++
            @ nl, 4 PROMPT Message->Mess04
            nl++
            @ nl, 4 PROMPT Message->Mess05
            nl++
            @ nl, 4 PROMPT Message->Mess06
            nl++
            @ nl, 4 PROMPT Message->Mess07
            nl++ 
            @ nl, 4 PROMPT Message->Mess20
            nl++ 
            @ nl, 4 PROMPT Message->Mess21
            nl++
            @ nl, 4 PROMPT "XX "
            @ nl,COL()+2 SAY "For ALL"
            MENU TO nselect
            DO CASE
               CASE PressedEsc()
                  RETURN NIL
               CASE nselect == 1
                 csale := SUBSTR( Message->Mess01, 1, 4 )   
               CASE nselect == 2
                 csale := SUBSTR( Message->Mess02, 1, 4 )   
               CASE nselect == 3
                 csale := SUBSTR( Message->Mess03, 1, 4 )   
               CASE nselect == 4
                 csale := SUBSTR( Message->Mess04, 1, 4 )   
               CASE nselect == 5
                 csale := SUBSTR( Message->Mess05, 1, 4 )   
               CASE nselect == 6
                 csale := SUBSTR( Message->Mess06, 1, 4 )   
               CASE nselect == 7
                 csale := SUBSTR( Message->Mess07, 1, 4 )   
               CASE nselect == 8
                 csale := SUBSTR( Message->Mess20, 1, 4 )   
               CASE nselect == 9
                 csale := SUBSTR( Message->Mess21, 1, 4 )   
               CASE nselect == 10
                 csale := "XX  "
            ENDCASE
            nselect  := 1
            nl := 6
            nl++  
            @ nl,20 PROMPT Menu1->Accom1
            nl++ 
            @ nl,20 PROMPT Menu1->Accom2
            nl++
            @ nl,20 PROMPT Menu1->Accom3
            nl++
            @ nl,20 PROMPT Menu1->Accom4
            nl++
            @ nl,20 PROMPT Menu1->Accom5
            nl++
            @ nl,20 PROMPT Menu1->Accom6
            nl++
            @ nl,20 PROMPT Menu1->Accom7
            nl++ 
            @ nl,20 PROMPT Menu1->Accom8
            nl++ 
            @ nl,20 PROMPT Menu1->Accom9
            nl++
            @ nl,20 PROMPT "XX"
            @ nl,COL()+2 SAY "For ALL"
            MENU TO nselect
            DO CASE
               CASE PressedEsc()
                  RETURN NIL
               CASE nselect == 1
                 caccom := Menu1->Accom1   
               CASE nselect == 2
                 caccom := Menu1->Accom2   
               CASE nselect == 3
                 caccom := Menu1->Accom3   
               CASE nselect == 4
                 caccom := Menu1->Accom4   
               CASE nselect == 5
                 caccom := Menu1->Accom5
               CASE nselect == 6
                 caccom := Menu1->Accom6
               CASE nselect == 7
                 caccom := Menu1->Accom7
               CASE nselect == 8
                 caccom := Menu1->Accom8
               CASE nselect == 9
                 caccom := Menu1->Accom9
               CASE nselect == 10
                 caccom := "XX"
            ENDCASE 
            nselect  := 1
            nl := 6
            nl++  
            @ nl,34 PROMPT Menu1->Letter1
            nl++ 
            @ nl,34 PROMPT Menu1->Letter2
            nl++
            @ nl,34 PROMPT Menu1->Letter3
            nl++
            @ nl,34 PROMPT Menu1->Letter4
            nl++
            @ nl,34 PROMPT Menu1->Letter5
            nl++
            @ nl,34 PROMPT Menu1->Letter6
            nl++
            @ nl,34 PROMPT Menu1->Letter7
            nl++ 
            @ nl,34 PROMPT Menu1->Letter8
            nl++ 
            @ nl,34 PROMPT Menu1->Letter9
            nl++
            @ nl,34 PROMPT "XX"
            @ nl,COL()+2 SAY "For ALL"
            MENU TO nselect
            DO CASE
               CASE PressedEsc()
                  RETURN NIL
               CASE nselect == 1
                 nletter := Menu1->Letter1   
               CASE nselect == 2
                 nletter := Menu1->Letter2   
               CASE nselect == 3
                 nletter := Menu1->Letter3   
               CASE nselect == 4
                 nletter := Menu1->Letter4   
               CASE nselect == 5
                 nletter := Menu1->Letter5
               CASE nselect == 6
                 nletter := Menu1->Letter6
               CASE nselect == 7
                 nletter := Menu1->Letter7
               CASE nselect == 8
                 nletter := Menu1->Letter8
               CASE nselect == 9
                 nletter := Menu1->Letter9
               CASE nselect == 10
                 nletter := "XX  "
            ENDCASE 
   ******----------------------------------------- 
   mwhere  := "S"
   npl     := 20
   nl      := 0
   
    Printsel()                               // _LF_Init

   IF mwhere == "P"
      npl := 58
      @  0, 0
      SET DEVICE TO PRINT
    ELSE
      npl := 23
      nl  := 0
   ENDIF
   coperno := Debit->Operno
   minvno  := Debit->Invno
   mcodeno := Debit->Codeno
   @ nl, 1 SAY Control->U_Name
   @ nl,39 SAY "Report "+minvno
   @ nl,59 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
              +STR(YEAR(DATE()),5)
   nl+=2
   SELECT Name
   SEEK Debit->Codeno
   @ nl, 0 SAY TRIM( Name->Name )+"  "+TRIM( Debit->Est )+"  Report "+minvno
   nl++
   IF Name->Add1 != SPACE( 20 )
      @ nl, 2 SAY Name->Add1
      nl++
   ENDIF
   IF Name->Add2 != SPACE( 20 )
      @ nl, 2 SAY Name->Add2
      nl++
   ENDIF
   IF Name->Add3 != SPACE( 20 )
      @ nl, 2 SAY Name->Add3
      nl++
   ENDIF
   IF Name->Add4 != SPACE( 20 )
      @ nl, 2 SAY Name->Add4
      nl++
   ENDIF
   nl+=2
   @ nl,28 SAY "Date"
   @ nl,34 SAY DTOC( Debit->StartDate ) 
   ***   @ nl,45 SAY "Due"
   ***   @ nl,49 SAY DTOC( Debit->DueDate ) 
   nl++
   IF Debit->Fault != SPACE( 20 )
      @ nl, 2 SAY Debit->Fault
      nl++
   ENDIF
   IF Debit->Message != SPACE( 20 )
      @ nl, 2 SAY Debit->Message
      nl++
   ENDIF
   SELECT Quot 
   SET ORDER TO 3                    // Invno
   SEEK Debit->Invno
   SELECT Part
   SEEK Quot->Partnum
   nl++
   SELECT Name
   GOTO TOP
   aPart_:={}
   nrecno := 0
   IF LASTREC() != 0
      @ nl, 6 SAY csale+"   "+ caccom+"  "+nletter 
      nl++
      DO WHILE  Name->( !EOF() )
         IF csale != "XX  "
            IF Name->Sale != csale
               SKIP ALIAS Name
               LOOP
            ENDIF
         ENDIF    
         IF caccom != "XX  "
            IF Name->Accom != caccom
               SKIP ALIAS Name
               LOOP
            ENDIF
         ENDIF    
         IF nletter != "XX  "
            IF Name->Letter != nletter
               SKIP ALIAS Name
               LOOP
            ENDIF
         ENDIF   
         @ nl, 1 SAY Name->Name+" ________________________________________"
         @ nl,72 SAY Name->Letter
         nl++
          ApRlock()
         Name->Loc := "   "
         UNLOCK
         SKIP ALIAS Name
      ENDDO
   ENDIF           // LastRec
      nl++
      ntotal := 0 
      SELECT Labour
      GOTO TOP
      SET ORDER TO 2         // Invno+Partnum+Codeno
      SEEK Debit->Invno
      DO WHILE Labour->Invno = Debit->Invno .AND. Labour->( !EOF() )
         @ nl, 1 SAY Labour->Desc
         @ nl,43 SAY Labour->Time PICTURE "9,999.99" 
         @ nl,54 SAY Labour->Operno
         @ nl,64 SAY Labour->Date 
         nl++
         ntotal := ntotal+Labour->Time 
                IF nl > npl
                   IF mwhere == "P"
                      EJECT
                      @  0, 0 SAY Control->U_Name
                      @  0,39 SAY minvno
                      @  0,59 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                                 +STR( YEAR(DATE() ),5 )
                      nl := 2
                     ELSE
                      INKEY( 0 )
                      SCROLL()
                      nl := 0 
                   ENDIF                       // mwhere = P
               ENDIF
               SKIP ALIAS Labour
           ENDDO                     // Labour
           @ nl,34 SAY "Total"
           @ nl,42 SAY ntotal PICTURE "99,999.99"
           coperno := Debit->Operno
           nl++
           @ nl, 0 SAY coperno
           nl++
           SELECT Progress
           SEEK coperno 
             SELECT Quot
             SET ORDER TO 3        // Invno + Partnum
             SEEK Debit->Invno
             SELECT Progress
             @ nl, 1 SAY Progress->DescProg
             IF Quot->Prog01 = SPACE( 12 )
                @ nl,14 SAY "____________"
               ELSE
                @ nl,14 SAY Quot->Prog01
             ENDIF
             SKIP ALIAS Progress
             @ nl,27 SAY Progress->DescProg
             IF Quot->Prog02 = SPACE( 12 )
                @ nl,40 SAY "____________"
               ELSE
                @ nl,40 SAY Quot->Prog02
             ENDIF
             SKIP ALIAS Progress
             @ nl,53 SAY Progress->DescProg
             IF Quot->Prog03 = SPACE( 12 )
                @ nl,66 SAY "____________"
               ELSE
                @ nl,66 SAY Quot->Prog03
             ENDIF
             nl++
             SKIP ALIAS Progress
             @ nl, 1 SAY Progress->DescProg
             IF Quot->Prog04 = SPACE( 12 )
                @ nl,14 SAY "____________"
               ELSE
                @ nl,14 SAY Quot->Prog04
             ENDIF
             SKIP ALIAS Progress
             @ nl,27 SAY Progress->DescProg
             IF Quot->Prog05 = SPACE( 12 )
                @ nl,40 SAY "____________"
               ELSE
                @ nl,40 SAY Quot->Prog05
             ENDIF
             SKIP ALIAS Progress
             @ nl,53 SAY Progress->DescProg
             IF Quot->Prog06 = SPACE( 12 )
                @ nl,66 SAY "____________"
               ELSE
                @ nl,66 SAY Quot->Prog06
             ENDIF
             nl++
             SKIP ALIAS Progress
             @ nl, 1 SAY Progress->DescProg
             IF Quot->Prog07 = SPACE( 12 )
                @ nl,14 SAY "____________"
               ELSE
                @ nl,14 SAY Quot->Prog07
             ENDIF
             SKIP ALIAS Progress
             @ nl,27 SAY Progress->DescProg
             IF Quot->Prog08 = SPACE( 12 )
                @ nl,40 SAY "____________"
               ELSE
                @ nl,40 SAY Quot->Prog08
             ENDIF
             SKIP ALIAS Progress
             @ nl,53 SAY Progress->DescProg
             IF Quot->Prog09 = SPACE( 12 )
                @ nl,66 SAY "____________"
               ELSE
                @ nl,66 SAY Quot->Prog09
             ENDIF 
             nl++
             SKIP ALIAS Progress
             @ nl, 1 SAY Progress->DescProg
             IF Quot->Prog10 = SPACE( 12 )
                @ nl,14 SAY "____________"
               ELSE
                @ nl,14 SAY Quot->Prog10
             ENDIF
             SKIP ALIAS Progress
             @ nl,27 SAY Progress->DescProg
             IF Quot->Prog11 = SPACE( 12 )
                @ nl,40 SAY "____________"
               ELSE
                @ nl,40 SAY Quot->Prog11
             ENDIF
             SKIP ALIAS Progress
             @ nl,53 SAY Progress->DescProg
             IF Quot->Prog12 = SPACE( 12 )
                @ nl,66 SAY "____________"
               ELSE
                @ nl,66 SAY Quot->Prog12
             ENDIF
             nl++
             SKIP ALIAS Progress
             @ nl, 1 SAY Progress->DescProg
             IF Quot->Prog13 = SPACE( 12 )
                @ nl,14 SAY "____________"
               ELSE
                @ nl,14 SAY Quot->Prog13
             ENDIF
             SKIP ALIAS Progress
             @ nl,27 SAY Progress->DescProg
             IF Quot->Prog14 = SPACE( 12 )
                @ nl,40 SAY "____________"
               ELSE
                @ nl,40 SAY Quot->Prog14
             ENDIF
             SKIP ALIAS Progress
             @ nl,53 SAY Progress->DescProg
             IF Quot->Prog15 = SPACE( 12 )
                @ nl,66 SAY "____________"
               ELSE
                @ nl,66 SAY Quot->Prog15
             ENDIF
             nl++
             SKIP ALIAS Progress
             @ nl, 1 SAY Progress->DescProg
             IF Quot->Prog16 = SPACE( 12 )
                @ nl,14 SAY "____________"
               ELSE
                @ nl,14 SAY Quot->Prog16
             ENDIF
             SKIP ALIAS Progress
             @ nl,27 SAY Progress->DescProg
             IF Quot->Prog17 = SPACE( 12 )
                @ nl,40 SAY "____________"
               ELSE
                @ nl,40 SAY Quot->Prog17
             ENDIF
             SKIP ALIAS Progress
             @ nl,53 SAY Progress->DescProg
             IF Quot->Prog18 = SPACE( 12 )
                @ nl,66 SAY "____________"
               ELSE
                @ nl,66 SAY Quot->Prog18
             ENDIF
             nl+=2
             SELECT Admin
             GOTO TOP
             DO WHILE Admin->( !EOF() )
                IF Admin->Abc != caccom
                   SKIP ALIAS Admin
                   LOOP
                ENDIF         
                @ nl, 0 SAY Admin->ABC+" "+;
                            Admin->Desc+" __________________"
                nl++
                IF nl > npl
                   IF mwhere = "P"
                      EJECT
                      @  0, 0 SAY Control->U_Name
                      @  0,40 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                                 +STR( YEAR(DATE() ),5 )
                      @  0,62 SAY minvno
                      nl := 2
                    ELSE
                      INKEY( 0 )
                      SCROLL()
                      nl := 0 
                   ENDIF
                 ENDIF
                SKIP ALIAS Admin
             ENDDO      // Admin
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
   SELECT Quot
   SET ORDER TO 1
   SELECT PartOper
   SET ORDER TO 1

   RETURN NIL
   ***-------- End of OperReport

   ****-------------------------------------------------------------------------

FUNCTION Operselect()

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
   @ 20, 4      PROMPT "1. Report"
   @ 20,COL()+2 PROMPT "2. Job Prog" 
   @ 20,COL()+2 PROMPT "3. Process Edit" 
   @ 20,COL()+2 PROMPT "4. Drawings" 
   @ 20,COL()+2 PROMPT "5. Parts JC Report" 

   MENU TO mchoice
   DO CASE
      CASE PressedEsc()
           RETURN NIL
      CASE mchoice == 1             //
          OperReport() 
      CASE mchoice == 2             //
          JobProg() 
      CASE mchoice == 5             //
          JCDirect() 
      CASE mchoice == 3             //
          JobOperate() 
      CASE mchoice == 4             //
          JobDraw() 
   ENDCASE

   RETURN NIL
   ***-------- End of Operselect

   *****---------------------------------------------------------------------

STATIC FUNCTION NamegetQK( mcodeno )            // Called by NameQuick

   mcorrect := "N"
   DO WHILE mcorrect == "N"
         SCROLL()
         DISPBOX( 0, 5,  2,75, 2 )
         DISPBOX( 3, 1, 24,79, 2 )
         mname       := Name->Name
         mtitle      := Name->Title
         mcalled     := Name->Called
         mfamname    := Name->Famname
         madd1       := Name->Add1
         madd2       := Name->Add2
         madd3       := Name->Add3
         madd4       := Name->Add4
         madd5       := Name->Add5
         mzip        := Name->Zip
         mephone     := Name->Ephone
         mphone      := Name->Phone
         mbphone     := Name->Bphone
         mmobphone   := Name->Mobphone
         mothphone   := Name->Othphone
         ndiscount   := Name->Discount
         nmargin     := Name->Margin
         memail      := Name->Email
         mbank       := Name->Bank
         mbankbranch := Name->BankBranch 
         mbankno     := Name->Bankno
         @  1, 7 SAY "Company Name :" GET mname PICTURE "@!"
         @  4, 3 SAY Name->Codeno
      ***      @  4,COL()+2 SAY "Title"     GET mtitle    PICTURE "!XXX"
      ***      @  4,COL()+2 SAY "First"     GET mcalled   PICTURE "!XXXXXXXXXXXXXXX"
      ***      @  4,COL()+2 SAY "Family"    GET mfamname  PICTURE "!XXXXXXXXXXXXXXX"
         @  6, 3 SAY "St   :"         GET madd1     PICTURE "@X"
         @  7, 3 SAY "Box. :"         GET madd2     PICTURE "@KX"
         @  8, 8 SAY ":"              GET madd3     PICTURE "@X"
         @  9, 3 SAY "City :"         GET madd4     PICTURE "@KX"
         @ 10, 3 SAY "Cntry "         GET madd5     PICTURE "@K!"
         @ 10,COL()+1 SAY "Zip"       GET mzip      PICTURE "@X"
         @  6,45 SAY "Priv Phone :"   GET mephone   PICTURE "@X"
         @  7,45 SAY "Bus  Phone :"   GET mphone    PICTURE "@X"
         @  8,45 SAY "Fax Number :"   GET mbphone   PICTURE "@X"
         @  9,45 SAY "Mobile     :"   GET mmobPhone PICTURE "@X"
         @ 10,45 SAY "Other       "   GET mothPhone PICTURE "@X"
      ***      @ 11,45 SAY "Discount   %"   GET ndiscount PICTURE "999.99"
      ***      @ 12,45 SAY "Sell+Adds  %"   GET nmargin   PICTURE "999.99" 
         @ 13, 3 SAY "Email"          GET memail    PICTURE "@X"
      ***      @ 15, 3 SAY "Bank Name   "   GET mbank     PICTURE "@!"
      ***      @ 15,32 SAY "Bank Branch"    GET mbankBranch 
      ***      @ 16, 3 SAY "Bank Acc #  "   GET mbankno
      ***      @ 14,45 SAY "Work Rate/hr" GET Name->Rate     PICTURE "99999.99"
         mcodeno := Name->Codeno
             mcontact := Name->Contact
             mdesc    := Name->Desc
             mdesc1   := Name->Desc1
             mdesc2   := Name->Desc2
             mdesc3   := Name->Desc3
             nl := 18
      ***          @ nl,10 SAY "   Contacts" GET mcontact PICTURE "@X"
             nl++
             @ nl,10 SAY "Description " GET mdesc    PICTURE "@X"
             nl++
             @ nl,23                    GET mdesc1   PICTURE "@X"
             nl++
             @ nl,23                    GET mdesc2   PICTURE "@X"
             nl++
             @ nl,10 SAY "Web Page WWW" GET mdesc3   PICTURE "@X"
              READ
             SELECT Name
              ApRLock( 3 )
             Name->Name       := mname
             Name->Title      := mtitle
             Name->Called     := mcalled
             Name->Famname    := mfamname
             Name->Add1       := madd1
             Name->Add2       := madd2
             Name->Add3       := madd3
             Name->Add4       := madd4
             Name->Add5       := madd5
             Name->Zip        := mzip
             Name->Ephone     := mephone
             Name->Phone      := mphone
             Name->Bphone     := mbphone
             Name->Mobphone   := mmobphone
             Name->Othphone   := mothphone
             Name->Discount   := ndiscount
             Name->Margin     := nmargin
             Name->Email      := memail
             Name->Bank       := mbank
             Name->BankBranch := mbankbranch
             Name->Bankno     := mbankno
             Name->Contact    := mcontact
             Name->Desc       := mdesc
             Name->Desc1      := mdesc1
             Name->Desc2      := mdesc2
             Name->Desc3      := mdesc3
             UNLOCK
         SCROLL( 12, 2, 23,78 )
         SELECT Name
         cexec := Name->Exec 
         @ 12, 8 SAY "Province" GET cexec PICTURE "@K!"
          READ
          ApRLock( 3 )
         Name->Exec := cexec
         UNLOCK
         SELECT Name
         IF EMPTY( Name->Exec )
            mchoice := 1
            @ 12,30 PROMPT Message->Exec1  
            @ 13,30 PROMPT Message->Exec2  
            @ 14,30 PROMPT Message->Exec3
            @ 15,30 PROMPT Message->Exec4      
            @ 16,30 PROMPT Message->Exec5
            @ 17,30 PROMPT Message->Exec6
            @ 18,30 PROMPT Message->Exec7
            MENU TO mchoice
            SELECT Name
             ApRLock( 3 )
            DO CASE
               CASE mchoice == 1
                  Name->Exec := SUBSTR( Message->Exec1,1,4 )
               CASE mchoice == 2
                  Name->Exec := SUBSTR( Message->Exec2,1,4 )
               CASE mchoice == 3
                  Name->Exec := SUBSTR( Message->Exec3,1,4 )
               CASE mchoice == 4
                  Name->Exec := SUBSTR( Message->Exec4,1,4 )
               CASE mchoice == 5
                  Name->Exec := SUBSTR( Message->Exec5,1,4 )
               CASE mchoice == 6
                  Name->Exec := SUBSTR( Message->Exec6,1,4 )
               CASE mchoice == 7
                  Name->Exec := SUBSTR( Message->Exec7,1,4 )
             ENDCASE
             UNLOCK 
         ENDIF
         SELECT Name
         cpaytype := Name->PayType
         @ 12, 8 SAY "Province    "+Name->Exec
         SCROLL( 12,25, 18,44 )
         csale := Name->Sale 
         @ 18,11 SAY "Sale :" GET csale PICTURE "@K!"
         @ 23,20 SAY Message->Mess10
          READ
          ApRLock( 3 )
         Name->Sale := csale
         UNLOCK
         IF EMPTY( Name->Sale )
            mchoice := 1
            @ 12,25 PROMPT Message->Mess01
            @ 13,25 PROMPT Message->Mess02
            @ 14,25 PROMPT Message->Mess03
            @ 15,25 PROMPT Message->Mess04
            @ 16,25 PROMPT Message->Mess05
            @ 17,25 PROMPT Message->Mess06
            @ 18,25 PROMPT Message->Mess07
            MENU TO mchoice
            SELECT Name
             ApRLock( 3 )
            DO CASE
               CASE mchoice == 1
                  Name->Sale := SUBSTR( Message->Mess01,1,4 )
               CASE mchoice == 2
                  Name->Sale := SUBSTR( Message->Mess02,1,4 )
               CASE mchoice == 3
                  Name->Sale := SUBSTR( Message->Mess03,1,4 )
               CASE mchoice == 4
                  Name->Sale := SUBSTR( Message->Mess04,1,4 )
               CASE mchoice == 5
                  Name->Sale := SUBSTR( Message->Mess05,1,4 )
               CASE mchoice == 6
                  Name->Sale := SUBSTR( Message->Mess06,1,4 )
               CASE mchoice == 7
                  Name->Sale := SUBSTR( Message->Mess07,1,4 )
            ENDCASE
            UNLOCK  
         ENDIF         // Empty Sale
         IF Note->Select7 = "Y"  
           mpart   := "Y"
            @ 18,50 SAY "Copy to Part" GET mpart PICTURE "!"
             READ
           IF mpart = "Y"   
             SELECT PART
             SEEK Name->Codeno
             IF FOUND()
                 ApRLock( 3 )
                Part->Desc    := mname
                Part->PartMat := mphone
                Part->Detail  := mephone+" "+mmobphone
                Part->Detail1 := mdesc
                Part->Detail2 := mdesc1
                Part->Detail3 := mdesc2
                Part->Locate  := UPPER( SUBSTR( Name->Add4, 1,16 ) )
                Part->LocDesc := Name->Add4
                UNLOCK
              ELSE
                 ApFLock( 3 )
                APPEND BLANK
                Part->Catno     := "NE-NEW "
                Part->PartId    := "NEW    "
                Part->Boughtout := "N"
                Part->Trade     := 1
                Part->Wholesale := 1
                Part->Partnum := mcodeno
                Part->Desc    := mname
                Part->PartMat := mphone
                Part->Detail  := mephone+" "+mmobphone
                Part->Detail1 := mdesc
                Part->Detail2 := mdesc1
                Part->Detail3 := mdesc2
                Part->Codeno  := "KIRBJOHN"
                Part->Unit    := "Each "
                Part->Locate  := UPPER( SUBSTR( Name->Add4, 1,16 ) )
                Part->LocDesc := Name->Add4
                UNLOCK
             ENDIF   // Found Part
         ENDIF             // Add Part
       ENDIF               // Note->Select7
       mcorrect := ApGetY( Message->Correct )
   ENDDO

   RETURN mcodeno

   ***---- End of NameGetQK()

   **-------------------------------------------------------------------

FUNCTION NameQuick()

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      SCROLL(  20, 0, 24,80 )
      DISPBOX( 20, 1, 24,79, 2 )
      mcodeno := SPACE( 8 )
      DO WHILE mcodeno == SPACE(8)
         @ 22,16 GET mcodeno PICTURE "@!"
         @ 22,COL()+3 SAY "Characters of Name Esc to Quit"
          READ
         IF PressedEsc()
            RETURN NIL
         ENDIF
      ENDDO
      SEEK mcodeno
      DO WHILE FOUND()
         @ 23,35 SAY "Already exists Esc to Quit"
         @ 22,16 GET mcodeno PICTURE "@!"
          READ
         IF PressedEsc()
            RETURN NIL
         ENDIF
         IF mcodeno == SPACE(8)
            LOOP
         ENDIF
         SEEK mcodeno
      ENDDO                          // FOUND()
      SELECT Name
       ApFLock( 3 )
      APPEND BLANK
      Name->Codeno := mcodeno
      ***   Name->Exec   := "CANT"
      Name->Add2   := "P.O.Box"
      Name->Add4   := Control->U_Add3
      Name->Add5   := Control->U_Add4
      Name->Datein := DATE()
      Name->Branch := Control->U_Branch
      UNLOCK

       NamegetQK( @mcodeno )             // Quick Name 

      mcontinue := "N"
   ENDDO

   RETURN mcodeno

   ***** End of NameQuick()

   **-------------------------------------------------------------------


   ***---------------- End of XLF_SER.PRG
