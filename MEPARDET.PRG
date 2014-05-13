   ***  JK  18-02-11 08:58:25 

/* 
   Program.....:              MEPartD.PRG
   Authors.....: J.Kirby
   Date........: 28/11/2001
   Func........: MEProfQty
   Not used....: MEParDet
*/

// (c) Copyright (c) 1995 Chozen Ltd Christchurch  All Rights reserved.

FUNCTION MEParTDet( mpartnum )

   SELECT Part
   SET ORDER TO 1                           // Partnum
   SEEK mpartnum
   IF !FOUND()
      SCROLL(  3, 0, 24,80 )
      DISPBOX( 3, 1, 19,79, 2 ) 
      @ 12,10 SAY "NO SUCH PART IN FILE"
      mok:=ApGetN( "Yes = Add Part - No = Search" )
      IF PressedEsc()
         RETURN NIL
      ENDIF
      IF mok == "Y"

         Partadd( @mpartnum )              // XF_Part
         SELECT Part
         SET ORDER TO 1                     // Partnum
         SEEK mpartnum
         ApRLock( 3 )
         mpartnum := Part->Partnum
         UNLOCK
      ELSE
         PartFind( @mpartnum )   
      ENDIF                            // mok  
   ENDIF                               // FOUND()
   ccatno := Part->Catno
   mcont  := "N"
   DO WHILE mcont == "N"
      SCROLL()
      DISPBOX( 0, 1,  2,79, 2 )
      DISPBOX( 3, 1, 21,79, 2 )
      @  1, 4 SAY TRIM( Part->Partnum )+"  "+TRIM( Part->Desc ) COLOR "G+"
      SELECT Part
      SET ORDER TO 1                     // Partnum
      SEEK mpartnum
      nl := 4 
      @  nl, 3      SAY TRIM( Part->Detail )+" "+TRIM( Part->Detail1 )
      nl++
      @  nl, 3      SAY TRIM( Part->Detail2)+" "+TRIM( Part->Detail3 )
      nl+=2 
      @ nl, 6      SAY "Cat # "+Part->Catno  
      @ nl,COL()+1 SAY "Group "+Part->PartId 
      nl+=2
      @ nl, 6      SAY "Codeno "    +Part->Codeno
      nl++
      tempscrn := SAVESCREEN( 10, 0, 24,80 )
      coderef  := mpartnum
      
      MemoDisp( coderef )   // XF-Memo2

      RESTSCREEN( 10, 0, 24,80,tempscrn )
      SCROLL(  22, 0, 24,80 )
      DISPBOX( 22, 1, 24,79, 2 )
      nselect := 1
      @ 23, 3      PROMPT "Another"     
      @ 23,COL()+2 PROMPT "Detail"
      @ 23,COL()+2 PROMPT "Delete"
      @ 23,COL()+2 PROMPT "Memo"
      @ 23,COL()+2 PROMPT "Add New" 
      @ 23,COL()+2 PROMPT "Change #"
      MENU TO nselect
      DO CASE
         CASE PressedEsc()
            RETURN NIL
         CASE nselect == 1
            PartView()                // XF_Part
            LOOP 
         CASE nselect == 2                     //   Qty Desc 
            tempscrn := SAVESCREEN( 0, 0, 24,80 )
            cedit := "N"                            // N = Total Stock   
            MEProfQty( cedit )                        // 
  
            RESTSCREEN(  0, 0, 24,80,tempscrn )
            LOOP
  
         CASE nselect == 3                              // Delete Part
            mok := ApGetN( TRIM( Message->Delete )+" This Part" )
            IF mok == "Y"
               @ 21,12 SAY "Please Wait takes Me time"
               SELECT Part
               SEEK mpartnum
                ApRLock( 3 )
               DELETE 
               UNLOCK
               SELECT CusNotes
                ApFLock( 3 )
               DELETE ALL FOR SUBSTR( Code_Ref,1,20 ) = mpartnum 
               UNLOCK
               SELECT PartOper
                ApFLock( 3 )
               DELETE ALL FOR PartOper->Partnum = mpartnum 
               UNLOCK
               SELECT QuotInfo
                ApFLock( 3 )
               DELETE ALL FOR QuotInfo->Partnum = mpartnum 
               UNLOCK
            ENDIF                            // mok
            mpartnum := SPACE( 20 )
         CASE nselect == 4                                // Memo
            tempscrn := SAVESCREEN( 11, 0, 24,80 )
            coderef  := mpartnum
  
            M2Memofile( coderef )                     // XF_Memo2
            /*
            mok := ApGetN( TRIM( Message->Delete )+" Memo" )
            IF mok == "Y"
               SELECT Cusnotes
               SEEK coderef
                ApFLock( 3 )
               DO WHILE FOUND()
                  DELETE
                  SEEK coderef
               ENDDO
               UNLOCK
               SELECT Part
             ENDIF
            */
            RESTSCREEN( 11, 0, 24,80,tempscrn )
            ****          Partflt( @mpartnum )                  // Below
            SELECT Part
            LOOP
            mcontinue := "Y"
         CASE nselect == 5                            // Add New Part
            mpartnum := SPACE( 20 )
            WAIT" TEST THIS ????? "
            ****          MEPartIvc()
            LOOP
            ****           Partadd( @mpartnum )
            ****          mpartnum := Part->Partnum
            ****           PartDets( mpartnum )
         CASE nselect == 6                             // Change Part #
            Partchange( @mpartnum )
            LOOP
      ENDCASE
      SCROLL(  19, 0, 24,80 )
      mcont := "Y"
   ENDDO
   RETURN mpartnum

   ****---- End PartDets()

   ****-------------------------------------------------------------------

FUNCTION MEProfQty()

   SELECT Part 
   mpartnum := Part->Partnum
   manother := "Y"
   DO WHILE manother = "Y"
      SCROLL()
      DISPBOX( 0, 1,  2,79, 2 )
      @  1, 3 SAY TRIM( Part->Partnum )+"  "+TRIM( Part->Desc )
      IF mcodeno != SPACE( 8 )
         @ 1,COL()+2 SAY TRIM( Name->Name )
      ENDIF
       nl := 17
       mok := "N"
      DO WHILE mok == "N"
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 1, 19,79, 2 )
         SELECT Part
         SET ORDER TO 1
         mcatno := Part->Catno
         @  4, 6 SAY SPACE(65)
         @  4, 7 SAY "Catalogue :" GET mcatno PICTURE "@!"
          READ
         IF PressedEsc()
            RETURN NIL
         ENDIF
         mmarkup := Part->Markup
         ccatno:= ccatorg:= Part->Catno
         IF ccatno == SPACE(12)
            ccatno := "XXXXXXXXXXXX"
         ENDIF
         SELECT Cat
         IF LASTREC() != 0
            SEEK ccatno
            IF !FOUND()
               SAVE SCREEN TO tempscr
               mok := "N"
               DO WHILE mok == "N"
                  CatArray()            // This sorts out Cat File
                  SCROLL(  3, 0, 17, 80 )
                  DISPBOX( 3, 1, 17,79, 2 ) 
                  IF !EMPTY( aCatcode_ )
                     nAnum  := ACHOICE( 4, 7,16,74, aCatcode_,,"AFUNC" ) 
                     ccatno := SUBSTR( aCatcode_[nAnum],1,12 )

                     SEEK ccatno
                  ENDIF
                  SCROLL(  15, 0, 24,80 )
                  DISPBOX( 15, 1, 19,79, 2 )
                  @ 16, 7 SAY "Catalogue # :" GET ccatno PICTURE "@K!"
                   READ
                                     SEEK ccatno
                  IF !FOUND()
                      ApFLock( 3 )
                     APPEND BLANK
                     Cat->Catno := ccatno
                  ENDIF
                  mcatdesc := Cat->Catdesc
                  @  18, 7 SAY "Description :" GET mcatdesc;
                     PICTURE "@X"
                   READ
                  SELECT Cat 
                   ApFLock( 3 )
                  Cat->CatDesc := mcatdesc                 
                  UNLOCK
                  mok := "Y"
               ENDDO
               RESTORE SCREEN FROM tempscr
            ENDIF
         ENDIF
         ***       SEEK ccatno
         SELECT Part
          ApRLock( 3 )
         Part->Catno := ccatno
         UNLOCK
         mpartid := Part->PartId 
         @  4, 7 SAY ccatno+"  "+Cat->Catdesc COLOR "G+"
         @  6,11 SAY "Group :" GET mpartid PICTURE "@K!"
         @  6,COL()+2 SAY "Blank for Look up"
          READ
          ApRLock( 3 )
         Part->PartId := mpartid 
         UNLOCK
         IF Part->PartId = SPACE( 16 )
            SAVE SCREEN TO tempscr
            SELECT Part
            SET ORDER TO 2                // Catno
            @  7, 8 SAY "Cat - Group"
            SCROLL( 8, 3, 24,26 )
            aPart_:={}
            nrecno   := 0
            cpartId  := SPACE( 16 )
            SEEK ccatno
            IF FOUND()
               DO WHILE Part->Catno = ccatno .AND. Part->( !EOF() )
                  DO WHILE Part->PartId = cpartId
                     SKIP ALIAS Part
                     LOOP        
                  ENDDO
                  DO WHILE Part->PartId = SPACE( 16 )
                     SKIP ALIAS Part
                     LOOP        
                  ENDDO
                  AADD( aPart_,Part->PartId+"   "+STR( RECNO(),6 ) )
                  cpartId := Part->PartId
                  SKIP ALIAS Part
               ENDDO
               DISPBOX(  8, 5, 18,26, 2 )
               IF !EMPTY( aPart_ )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE(  9,  7, 17,24, aPart_,,"AFUNC" )
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
               ENDIF
            ENDIF                          // Found()  
            cpartId := Part->PartId
            RESTORE SCREEN FROM tempscr
            SELECT Part
            SET ORDER TO 1                 // Partnum
            SEEK mpartnum
             ApRLock( 3 )
            Part->PartId := cpartId
            UNLOCK
            mpartid := Part->PartId 
            @  6,11 SAY "Group :" GET mpartid PICTURE "@!"
            @  6,COL()+2 SAY SPACE( 20 )
             READ
             ApRLock( 3 )
            Part->PartId := mpartid
            UNLOCK
         ENDIF                         // PartId = SPACE( 16 ) 
         IF SUBSTR( Part->Desc,1, 8 ) = "New Part"
            @  8,25 SAY "Select Similar Description from Catalogue" COLOR "BG+"  
            mdesc  := SPACE( 40 ) 
            aPart_ :={}
            SELECT Part
            SET ORDER TO 2                               // Catno Index
            SEEK ccatno
            IF LASTREC() != 0
               DO WHILE Part->Catno == ccatno
                  AADD( aPart_,Part->Desc;
                              +"   "+STR( RECNO(),6 ) )
                  SKIP ALIAS Part
               ENDDO
               nrecno := 0
               SCROLL(  10, 0, 24,74 )
               DISPBOX( 10, 5, 23,52, 2 ) 
               IF !EMPTY( aPart_ )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE( 11, 7, 22,50,aPart_,,"AFUNC" )
                  IF PressedEsc()
                     RETURN NIL
                  ENDIF
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
                   ApRLock( 3 )
                  mdesc  := Part->Desc
                  UNLOCK 
               ENDIF                             // Empty
            ENDIF                                // LastRec
            SELECT Part
            SET ORDER TO 1                       // Partnum Index
            SEEK mpartnum                        // Finds Partnum Again
             ApRLock( 3 )
            Part->Desc := mdesc
            UNLOCK
         ENDIF                                       // Part Trade = 0
         @  8,10 SAY Part->Partnum+" "+Part->Desc
         @ 10,25 SAY Part->Detail
         SCROLL( 11, 0, 24,80 )
         DISPBOX( 3, 1, 23,79, 2 ) 
         ***       SCROLL(  8, 2, 18,78 )
         SELECT Part
         mdesc := Part->Desc
         mdetail := Part->Detail
         @  8, 8 SAY Part->Partnum PICTURE "@!"
         @  8,29 GET mdesc         PICTURE "@X"
         @  9,29 GET mdetail       PICTURE "@X"
          READ
          ApRLock( 3 )
         Part->Desc   := mdesc
         Part->Detail := mdetail
         UNLOCK
         mok := "Y"
       ENDDO                                              // mok
       manother := "N"
       COMMIT
   ENDDO                    // manother

   RETURN NIL
   ***------ End of MEProfQty()

**--------------------   End of MEParDet.PRG
