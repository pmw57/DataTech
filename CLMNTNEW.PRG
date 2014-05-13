***  JK  08-09-11 15:24:35 
*** PAWILK09 Trim cfile database reference to fix Dos Error 2 (file not found) problem.

/* 
   Program.....:            CLMNTNEW.PRG
   Author(s)...: J.Kirby
   Date........: 16/10/1998
   Functions...:  NewClmnt
*/

FUNCTION NewClmnt()

   CLOSE DATABASES

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      SCROLL()
      USE DataDbf
      GO TOP
      aPart_ := {}
      nrecno := 0
      DO WHILE DataDbf->( !EOF() )
         AADD( aPart_, FIELDGET( 1 )+"  "+ FIELDGET( 2 )+"    "+STR( RECNO(),6 ) )
         SKIP ALIAS DataDbf
      ENDDO                               // DataDbf
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         DISPBOX( 0, 46,  2,72 )
         @  1,48 SAY "MAINTAINING DATA BASES"
         DISPBOX( 2, 5, 23,44 )
         anum   := ACHOICE( 3, 7, 22,41, aPart_,,"AFUNC" )
         SCROLL()
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         cfile := TRIM( DataDbf->DataBase )
         @  0,24 SAY DataDbf->DataBase+"  "+DataDbf->Details COLOR "R+"
         IF LASTKEY() = 27
            EXIT
         ENDIF 
         USE &cfile
         GOTO BOTTOM
         BROWSE()
         PACK
      ENDIF
      mcontinue := ApGetN( "Another File" )    
   ENDDO

   mcontinue := "N"
      *** := ApGetN( "Change Menu Files" )    
   DO WHILE mcontinue = "Y"
      SCROLL()
      USE MenuDbf
      GO TOP
      aPart_ := {}
      nrecno := 0
      DO WHILE MenuDbf->( !EOF() )
         AADD( aPart_, FIELDGET( 1 )+"  "+ FIELDGET( 2 )+"   "+STR( RECNO(),6 ) )
         SKIP ALIAS MenuDbf
      ENDDO                               // MenuDbf
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         DISPBOX( 0, 46,  2,72 )
         @  1,48 SAY "MAINTAINING MENU FILES"
         DISPBOX( 2, 5, 23,44 )
         anum   := ACHOICE( 3, 7, 22,41, aPart_,,"AFUNC" )
         SCROLL()
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         cfile := MenuDbf->DataBase
         @  0,24 SAY MenuDbf->DataBase+"  "+MenuDbf->Details COLOR "R+"
         USE &cfile
         GO TOP
         aPart_ := {}
         nnum := 0
         FOR i = 1 TO 120
            nnum ++ 
       *****     cfield1 := FIELD( i )
            cfield2 := FIELDGET( i )
            AADD( aPart_,cfield2 )
         NEXT
         IF !EMPTY( aPart_ )
            anum := ACHOICE( 2, 2, 22,39, aPart_,,"AFUNC" )
            USE &cfile
            GOTO TOP
            npl := 22
            nl  := 1
            ctest := "TEST"
            FOR i = 1 TO 120
               IF nl > npl
                  WAIT
                  SCROLL( 1,39, 24,80 )
                  nl := 1
               ENDIF
               nl++
               @ nl,60 SAY FIELDGET( i ) 
               nl++
               ctest := FIELDGET( i )
               @ nl,40 SAY FIELD( i )  
               @ nl,59 GET ctest
                READ
               IF LASTKEY() = 27
                  EXIT
               ENDIF 
               FIELDPUT( i, ctest )
            NEXT
            PACK
         ENDIF
      ENDIF
      mcontinue := ApGetN( "Another File" )    
   ENDDO

   DBFReIndx()

   RETURN NIL

   ******--------------- END OF FILE CLMNTNEW.PRG


