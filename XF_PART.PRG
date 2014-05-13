   *** JK  06-07-11 20:48:24 

/* 
   Program.....:                 XF_PART.PRG
   Author......: J.Kirby
   Date........: 31/10/1996
   Functions...: CatArray, PartUsed, Partfind, Partchange
                 PartView, Suppliers
   Static funcs: PartRank, CatFind, PartGet, ProfSupply
*/

// (c) Copyright (c) 1995 Kirby Christchurch.

FUNCTION CatArray()

   SCROLL()
   DISPBOX( 0, 0, 23,79, 2 ) 
   SELECT Cat
   GO TOP
   ccatno := SPACE(12)
   nrecno := 0
   aPart_ :={}
   mselect := "    " 
   @ 6, 6 SAY "Catalogue: Exact First 4 Letters Blank for all" GET mselect PICTURE "@!X"
   READ
   @ 6,10 SAY "                                                      "
   DO WHILE Cat->( !EOF() )
      IF mselect != "    "
         DO CASE
            CASE SUBSTR( mselect, 2, 3 ) = "   "
               IF SUBSTR( Cat->Catno, 1, 1 ) != SUBSTR( mselect, 1, 1 )
                  SKIP ALIAS Cat
                  LOOP
               ENDIF
            CASE SUBSTR( mselect, 3, 2 ) = "  "
               IF SUBSTR( Cat->Catno, 1, 2 ) != SUBSTR( mselect, 1, 2 )
                  SKIP ALIAS Cat
                  LOOP
               ENDIF
            CASE SUBSTR( mselect, 4, 1 ) = " "
               IF SUBSTR( Cat->Catno, 1, 3 ) != SUBSTR( mselect, 1, 3 )
                  SKIP ALIAS Cat
                  LOOP
               ENDIF
            CASE mselect != "    "
               IF SUBSTR( Cat->Catno, 1, 4 ) != SUBSTR( mselect, 1, 4 )
                  SKIP ALIAS Cat
                  LOOP
               ENDIF
         ENDCASE
      ENDIF    // mselect 
      AADD( aPart_,Cat->Catno+"     "+Cat->CatDesc;
                  +"                  "+STR( RECNO(),6 ) )
      SKIP ALIAS Cat
   ENDDO
   @ 24,20 SAY "--- F2 For Headings ---" COLOR "RG+" 
   IF !EMPTY( aPart_ )
      ASORT(aPart_,,,{ | x,y | x < y })
      anum := ACHOICE( 1, 2, 22,78, aPart_,,"AFUNC" )
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      GOTO nrecno
      ccatno := Cat->Catno
      IF LASTKEY() == -1
         SELECT Cat
         GO TOP
         ccatno := SPACE(12)
         nrecno := 0
         aPart_ :={}
         DO WHILE Cat->( !EOF() )
            IF SUBSTR( Cat->Catno, 4,2 ) != "AA"
               SKIP ALIAS Cat
               LOOP
            ENDIF
            AADD( aPart_,Cat->CatDesc+" "+Cat->Catno+"                 "+STR( RECNO(),6 ) )
            SKIP ALIAS Cat
         ENDDO
         IF !EMPTY( aPart_ )
            SCROLL()
            DISPBOX( 0, 0, 23,79, 2 )
            ASORT(aPart_,,,{ | x,y | x < y })
            anum := ACHOICE( 1, 3, 22,77, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            ccatno := Cat->Catno
         ENDIF
         nrecno := 0
         aPart_ :={}
         DO WHILE Cat->( !EOF() )
            IF SUBSTR( Cat->Catno, 1, 2 ) != SUBSTR( ccatno,1, 2 )
               SKIP ALIAS Cat
               LOOP
            ENDIF
            AADD( aPart_,Cat->CatDesc+"  "+Cat->CatNo;
                          +"               "+STR( RECNO(),6 ) )
            SKIP ALIAS Cat
         ENDDO
         IF !EMPTY( aPart_ )
            SCROLL()
            DISPBOX( 0, 0, 23,79, 2 )
            ASORT(aPart_,,,{ | x,y | x < y })
            anum := ACHOICE( 1, 3, 22,77, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            ccatno := Cat->Catno
         ENDIF
      ENDIF                       // F2  
   ENDIF

   RETURN ccatno

   ** End of CatArray()

   **-------------------------------------------------------------------

FUNCTION PartUsed( mpartnum )

   aPart_ :={}
   SELECT Equ
   GOTO TOP
   DO WHILE Equ->( !EOF() )
      IF Equ->Partnum != mpartnum
         SKIP ALIAS Equ
         LOOP
      ENDIF
      SELECT EquDesc
      SET ORDER TO 1
      SEEK Equ->ModCode
      SELECT Equ
      AADD( aPart_,Equ->Modcode;
         +" "+EquDesc->Desc;
         +"  "+STR( Equ->PartQty,12, 3 ) )
      SKIP ALIAS Equ
   ENDDO                            // EOF Equ
   ASORT(aPart_,,,{ | x,y | x < y })
   SCROLL(  3, 0, 24,80 )
   DISPBOX( 3, 1, 24,79, 2 )
   @  3, 4 SAY " Part Used in The Following Modules " COLOR "G+" 
   @ 23,20 SAY "Any Key To Continue" COLOR "G+" 
   IF !EMPTY( aPart_ )
      @  3, 0 SAY " "
      AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " );
         ,QQOUT( A ),BreakTot() } )

      ****      anum := ACHOICE( 4, 5, 22,76,aPart_,,"AFUNC" )
   ENDIF
   WAIT 
   SCROLL()

    Printsel()                                  // _LF_Init

   IF mwhere == "P"
      SET MARGIN TO 1
      npl := 56
   ELSE
      SCROLL()
      npl := 22
   ENDIF
   SELECT Equ
   GOTO TOP
   @  0, 8 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
             +STR( YEAR(DATE() ),5 )
   @  2, 8 SAY Part->Desc
   nl := 4
   SELECT EquDesc
   SET ORDER TO 1
   SEEK Equ->ModCode
   SELECT Equ
   DO WHILE Equ->( !EOF() )
      IF Equ->Partnum != mpartnum
         SKIP ALIAS Equ
         LOOP
      ENDIF
      IF nl > npl
         IF mwhere == "P"
            EJECT
            @  0, 8 SAY Control->U_Name
            @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                      +STR( YEAR(DATE() ),5 )
            @  2, 8 SAY Part->Desc
            nl := 4
         ELSE
            WAIT
            nl := 0
            SCROLL()
         ENDIF
      ENDIF
      @ nl, 0 SAY Equ->Modcode
      SELECT EquDesc
      SEEK Equ->Modcode
      @ nl,18 SAY EquDesc->Desc
      SELECT Equ
      @ nl,60 SAY STR( Equ->PartQty,12, 3 )
      nl++
      SKIP ALIAS Equ
   ENDDO
   nl++
   IF mwhere != "P"
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ELSE
      EndPrint()
      SET MARGIN TO 0
   ENDIF
   mok := ApGetN( TRIM( Message->Another )+" Print" )
   SELECT Part

   RETURN mpartnum

   **** End of PartUsed()

   **---------------------------------------------------------------------*

FUNCTION Partfind( mpartnum, mcodeno )

   DO WHILE .T. 
      mpartnum := SPACE( 20 )
      SELECT Part
      SET ORDER TO 1                       // Partnum
      IF Part->( LASTREC() ) == 0
          PartAdd( @mpartnum )
         mpartnum := Part->Partnum
      ENDIF                    // Empty Parts File
      SCROLL(  0, 0, 2,80 )
      DISPBOX( 0, 1, 2,79, 2 )
      @  1, 5 SAY "Enter Part Number" GET mpartnum PICTURE "@!"
      @  1,48 SAY "Blank for more Options"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      IF SUBSTR( mpartnum,1, 1 ) != SPACE( 1 )   // Input to Partnum
          PartRank( @mpartnum )           // Above
         SELECT Part
         SET ORDER TO 1                   // Partnum
         SEEK mpartnum
         IF !FOUND()
            @ 1, 4 SAY "PART NOT FOUND TRY Again" COLOR "G+"
            INKEY( 0 )
            LOOP
         ENDIF
         IF PressedEsc()
            RETURN NIL
         ENDIF
         RETURN mpartnum
      ENDIF                           // Partnum = Char 

   // Set Up for Blank Partnum
      IF mpartnum == SPACE( 20 )   // Blank Partnum
         SCROLL(  0, 0, 3,80 )
         DISPBOX( 0, 0, 3,79, 2 )
         nselect  := 1
         @ 1, 5      PROMPT "1. Catalogue"
         @ 1,COL()+2 PROMPT "2. Location"
         @ 1,COL()+2 PROMPT "3. Add New  "
         @ 1,COL()+2 PROMPT "4. Cat+Group"
         @ 1,COL()+2 PROMPT "5. Group"
         @ 1,COL()+2 PROMPT "6. Suppl"
         @ 2, 5      PROMPT "7. Location Group"
         @ 2,COL()+2 PROMPT "8. Cat+Location"
         @ 3,60 SAY " DT31 "
         MENU TO nselect
         DO CASE
            CASE PressedEsc()
               RETURN mpartnum
           CASE nselect == 8                  // Catalogue Location
               CatLoc()                  // XF_PList                 
               RETURN mpartnum
           CASE nselect == 7                  // Location Group
               LocPart()                // XF_PList                 
               RETURN mpartnum
           CASE nselect == 2     // Location
               clocate  := SPACE( 16 )
               clocdesc := SPACE( 28 )  
               SELECT Part
               SET ORDER TO 4                // Locate
               GOTO TOP
               aPart_:={}
               nrecno  := 0
               DO WHILE Part->( !EOF() )
                  IF Part->Locate = clocate
                     SKIP ALIAS Part
                     LOOP        
                  ENDIF
                  IF Part->Locate = SPACE( 16 )
                     SKIP ALIAS Part
                     LOOP        
                  ENDIF
                  AADD( aPart_,Part->Locate;
                         +" "+Part->LocDesc;
                         +"           "+STR( RECNO(),6 ) )
                  clocate := Part->Locate
                  SKIP ALIAS Part
               ENDDO
               DISPBOX(  4, 0, 24,52, 2 )
               IF !EMPTY( aPart_ )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE(  5, 3, 23,50, aPart_,,"AFUNC" )
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
                  clocate  := Part->Locate
                  cLocdesc := Part->Locdesc
               ENDIF
               SELECT Part
               SCROLL()
               DISPBOX(  0, 0, 3,79, 2 )
               @  1,10 SAY clocate+" "+clocdesc+"  "+"Location"
               aPart_:={}
               nrecno   := 0
               mpartnum := SPACE( 16 )
               IF LASTREC() != 0
                  GOTO TOP
                  SEEK clocate
                  DO WHILE Part->Locate = clocate .AND. Part->( !EOF() )
                     IF Part->LocDesc = "    "
                        SKIP ALIAS Part
                        LOOP        
                     ENDIF
                     AADD( aPart_,Part->Partnum;
                        +" "+Part->Desc;
                        +" "+Part->Locate; 
                        +"             "+STR( RECNO(),6 ) )
                     SKIP ALIAS Part
                  ENDDO
                  DISPBOX( 3, 0, 24,79, 2 )
                  IF !EMPTY( aPart_ )
                     ASORT( aPart_,,,{ | x,y | x < y } )
                     anum := ACHOICE( 4, 2, 23,78, aPart_,,"AFUNC" )
                     IF PressedEsc()
                        RETURN NIL
                     ENDIF
                     nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                     GOTO nrecno
                     mpartnum := Part->Partnum
                   ENDIF                // ! Empty
               ENDIF                           // Found
               SELECT Part
               SET ORDER TO 1
               SEEK mpartnum
               mpartnum := Part->Partnum     
    
               RETURN mpartnum

            CASE nselect == 1                  // Catalogue 
               mpartnum = "CCC"+SPACE( 17 )
            CASE nselect == 5                  // Group             
               mpartnum = "ZZZ"+SPACE( 17 )
            CASE nselect == 6                  // Supplier
               NameRank( mcodeno )
               mcodeno := Name->Codeno
               SELECT Part
               INDEX ON Part->Codeno+Part->Partnum TO PartCode
               SET INDEX TO PartCode
               GOTO TOP
               SEEK mcodeno
               SCROLL()
               DISPBOX( 0, 0, 2,79, 2 )
               @  1,10 SAY TRIM( Name->Name )+" Suppliers Part ID "
               aPart_:={}
               nrecno   := 0
               mpartnum:= msuplId := SPACE( 20 )
               IF LASTREC() != 0
                  DO WHILE Part->Codeno = mcodeno .AND. Part->( !EOF() )
                     SELECT Supl
                     SET ORDER TO 1       // Partnum
                     SEEK Part->Partnum
                     IF FOUND()
                        IF Supl->Codeno = mcodeno 
                           msuplId := Supl->SuppId
                        ENDIF
                     ENDIF
                     SELECT Part
                     AADD( aPart_,Part->Partnum;
                         +" "+Part->Desc+" "+msuplId;
                         +"                  "+STR( RECNO(),6 ) )
                     SKIP ALIAS Part
                     msuplId := SPACE( 20 )
                  ENDDO                    // Part
                  DISPBOX( 3, 0, 24,79, 2 )
                  IF !EMPTY( aPart_ )
                     ASORT( aPart_,,,{ | x,y | x < y } )
                     anum := ACHOICE( 4, 3, 23,78, aPart_,,"AFUNC" )
                     IF PressedEsc()
                        SELECT Part
                        SET INDEX TO PartInd
                        ***            SET ORDER TO 1              // Partnum
                        SEEK mpartnum
                        mpartnum := Part->Partnum     
                        RETURN mpartnum
                     ENDIF 
                     nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                     GOTO nrecno
                     mpartnum := Part->Partnum 
                  ENDIF                        // !Empty
               ENDIF                           // LastRec
               SELECT Part
               SET INDEX TO PartInd
               ****            SET ORDER TO 1              // Partnum
               GOTO TOP  
               SEEK mpartnum
               mpartnum := Part->Partnum     
               RETURN mpartnum

            CASE nselect == 3                  // Add New Part             
               mpartnum = "XXX"+SPACE( 17 )
         ENDCASE
      ENDIF                        // Partnum = SPACE 20
      DO CASE                                      
         CASE  SUBSTR( mpartnum, 1, 3 ) = "CCC"     // Find by Catalogue
            ccatno := SPACE(12)
            CatArray()               // Creates array of Catalogue
         SELECT Part
         SET ORDER TO 2                            // Catno + Desc
         SEEK ccatno
         IF FOUND()
            mpartnum := PartGet( @ccatno )        // Below

            SET ORDER TO 1                         // Partnum + Desc 
            SEEK mpartnum
            IF FOUND()
               mpartnum := Part->Partnum
            ELSE 
               SCROLL()
               WAIT " PART NOT FOUND IN PARTLIST "
            ENDIF
         ELSE
            SCROLL()
            @  9, 10 SAY "NO PARTS THIS CATALOGUE SELECTION"
            mok := ApGetN( "Yes to Add - No to Search" )
            IF PressedEsc()
               SELECT Part
               SET ORDER TO 1
               RETURN NIL
            ENDIF
            IF mok == "Y"

                PartAdd( @mpartnum )                    // Below

               DO CASE
                  CASE SUBSTR( Part->Partnum, 1, 3 ) = "JC-"
                     RETURN mpartnum
                  CASE SUBSTR( Part->Partnum, 1, 3 ) = "QU-"
                     RETURN mpartnum
                  CASE SUBSTR( Part->Partnum, 1, 3 ) = "TEM"
                     RETURN mpartnum
                  CASE SUBSTR( Part->Partnum, 1, 3 ) = "ZZT"
                     RETURN mpartnum
                  CASE SUBSTR( Part->Partnum, 1, 3 ) = "TT-"
                     RETURN mpartnum
               ENDCASE
               SELECT Part
               SET ORDER TO 1                         // Partnum + Desc 
               SEEK mpartnum
               mpartnum := Part->Partnum

                PartDets( @mpartnum )
    
            ELSE
              mpartnum:= SPACE( 16 )        // This initiates CatLook, etc.
              LOOP
            ENDIF                  // mok
         ENDIF                     // Found
         SELECT Part
         SET ORDER TO 1                        // Partnum
         SEEK mpartnum
         IF !FOUND()
            SCROLL( 14, 6, 24,74 )
            @ 16,10 SAY "--- This part not in file ---"
            mok := ApGetN( "Yes Add Part / No = Search" )
            IF PressedEsc()
               RETURN NIL
            ENDIF
            IF mok == "Y"
               Partadd( @mpartnum )         // Below
               DO CASE
                  CASE SUBSTR( Part->Partnum, 1, 3 ) = "JC-"
                     RETURN mpartnum
                  CASE SUBSTR( Part->Partnum, 1, 3 ) = "QU-"
                     RETURN mpartnum
                  CASE SUBSTR( Part->Partnum, 1, 3 ) = "TEM"
                     RETURN mpartnum
                  CASE SUBSTR( Part->Partnum, 1, 3 ) = "ZZT"
                     RETURN mpartnum
                  CASE SUBSTR( Part->Partnum, 1, 3 ) = "TT-"
                     RETURN mpartnum
               ENDCASE
               mpartnum := Part->Partnum
               PartDets( mpartnum )
            ELSE
               LOOP
            ENDIF        // mok
         ELSE
            RETURN mpartnum
         ENDIF                     // Found

         CASE SUBSTR( mpartnum,1, 3 ) == "ZZZ"            // Group
            SELECT Part
            SET ORDER TO 3                // PartId+Partnum
            SCROLL()
            DISPBOX(  0, 0, 2,79, 2 )
            @  1,10 SAY "Find By Part ID"
            aPart_:={}
            nrecno   := 0
            mpartnum := SPACE( 16 )
            cpartId  := SPACE( 16 )
            SCROLL()
            IF LASTREC() != 0
               GOTO TOP
               DO WHILE Part->( !EOF() )
                  DO WHILE Part->PartId = cpartId
                     SKIP ALIAS Part
                     LOOP        
                  ENDDO
                  AADD( aPart_,Part->PartId+"       "+STR( RECNO(),6 ) )
                  ****  SKIP ALIAS EquDesc
                  cpartId := Part->PartId
               ENDDO
               DISPBOX( 0, 0, 23,26, 2 )
               IF !EMPTY( aPart_ )
                  anum := ACHOICE( 2,  7, 22,24, aPart_,,"AFUNC" )
                  IF PressedEsc()
                     RETURN NIL
                  ENDIF
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
               ENDIF                // ! Empty
            ENDIF                           // Found
            mpartnum := Part->PartId+SPACE( 4 )

            CatFind( @mpartnum )

            SELECT Part
            SET ORDER TO 1
            SEEK mpartnum
            mpartnum := Part->Partnum     
 
            RETURN mpartnum


         CASE SUBSTR( mpartnum,1, 3 ) == "XXX"   // Add Part
            PartAdd( @mpartnum )                 // Below
            mpartnum := Part->Partnum 
            DO CASE
               CASE SUBSTR( Part->Partnum, 1, 3 ) = "JC-"
                  RETURN mpartnum
               CASE SUBSTR( Part->Partnum, 1, 3 ) = "QU-"
                  RETURN mpartnum
               CASE SUBSTR( Part->Partnum, 1, 3 ) = "TEM"
                  RETURN mpartnum
               CASE SUBSTR( Part->Partnum, 1, 3 ) = "ZZT"
                  RETURN mpartnum
               CASE SUBSTR( Part->Partnum, 1, 3 ) = "TT-"
                  RETURN mpartnum
            ENDCASE
            SELECT Part
            SET ORDER TO 1
            SEEK mpartnum

            PartDets( @mpartnum )                // CWP2

            RETURN mpartnum

         CASE  mpartnum = SPACE( 16 )     // Find by Catalogue
            ccatno := SPACE(12)
            CatArray()               // Creates array of Catalogue
            SELECT Part
            SET ORDER TO 2                   // Catno + Desc
            aPart_:={}
            nrecno   := 0
            mpartnum := SPACE( 16 )
            cpartId  := SPACE( 16 )
            SCROLL()
            IF LASTREC() != 0
               SEEK ccatno 
               DO WHILE Part->Catno = ccatno .AND. Part->( !EOF() )
                  DO WHILE Part->PartId = cpartId
                     SKIP ALIAS Part
                     LOOP        
                  ENDDO
                  AADD( aPart_,Part->PartId+"   "+STR( RECNO(),6 ) )
                  ***         SKIP ALIAS Part
                  cpartId := Part->PartId
               ENDDO
               DISPBOX( 0, 0, 23,26, 2 )
               IF !EMPTY( aPart_ )
                  anum := ACHOICE( 2,  7, 22,24, aPart_,,"AFUNC" )
                  IF PressedEsc()
                     RETURN mpartnum
                  ENDIF
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
               ENDIF
            ENDIF  
            cpartId := Part->PartId

            ****  FUNCTION CatFind( mpartnum )

            aPart_:={}
            nrecno := 0
            SELECT Part
            SET ORDER TO 3                  //  PartId+Desc
            IF LASTREC() != 0
               SEEK cpartId
               IF FOUND()
                  DO WHILE Part->PartId = cpartId .AND. Part->( !EOF() )
                     IF Message->Mess09 = SPACE( 12 )
                        AADD( aPart_,( Part->Desc;
                           +" "+STR( Wholesale,8,2 )+" "+STR( Part->Instock,8,0 );
                           +"  "+SUBSTR( Part->Partnum,1, 8 );
                           +"   "+STR( RECNO(),6 ) ) )
                     ELSE
                        AADD( aPart_,( SUBSTR( Part->Partnum, 1 ,13 );
                           +"  "+SUBSTR( Part->Desc, 1,29 );
                           +" "+STR( Part->Instock, 8, 2 )+" "+STR( Wholesale,12, 2 );
                           +" "+Part->ABC+" "+Part->Unit+"         "+STR( RECNO(),6 ) ) )
                     ENDIF
                     SKIP ALIAS Part
                  ENDDO
                  ***      IF Message->Mess09 = SPACE( 12 )
                  ASORT(aPart_,,,{ | x,y | x < y })
                  ***      ENDIF    
               ENDIF                        // FOUND()
               SCROLL() 
               DISPBOX( 0, 0, 23,79, 2 )
               @ 24, 5 SAY Message->Select
               @ 24,50 SAY Message->Esc
               IF !EMPTY( aPart_ )
                  anum := ACHOICE( 2, 2, 22,78, aPart_,,"AFUNC" )
                  IF LASTKEY() == -1
              
                     PartAdd( mpartnum )                  // Below
                     mpartnum := Part->Partnum 
                     DO CASE
                        CASE SUBSTR( Part->Partnum, 1, 3 ) = "JC-"
                           RETURN mpartnum
                        CASE SUBSTR( Part->Partnum, 1, 3 ) = "QU-"
                           RETURN mpartnum
                        CASE SUBSTR( Part->Partnum, 1, 3 ) = "TEM"
                           RETURN mpartnum
                        CASE SUBSTR( Part->Partnum, 1, 3 ) = "ZZT"
                           RETURN mpartnum
                        CASE SUBSTR( Part->Partnum, 1, 3 ) = "TT-"
                           RETURN mpartnum
                     ENDCASE
                     SELECT Part
                     SET ORDER TO 1
                     SEEK mpartnum
                     mpartnum := Part->Partnum

                     PartDets( @mpartnum )

                  ENDIF                     // LastKey
                  IF PressedEsc()
                     RETURN NIL
                  ENDIF
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
                  mpartnum := Part->Partnum
               ENDIF                            // !Empty                
               SCROLL(  1, 0, 1,80 )
               DISPBOX( 0, 0, 2,79, 2 )
               @  1, 8 SAY TRIM(mpartnum)+" "+SUBSTR( Part->Desc, 1,30 );
                           +" "+STR( Part->Instock,9, 0 )  // COLOR c_hicolor
            ENDIF           // LastRec

            SELECT Part
            SET ORDER TO 1
            SEEK mpartnum
            mpartnum := Part->Partnum     
 
            RETURN mpartnum
            ********

         CASE SUBSTR( mpartnum,1, 1 ) == "?"      // All Parts
            IF RECNO() > 2000
               @ 19,10      SAY "Too Many Parts in File "
               @ 19,COL()+2 SAY RECNO() PICTURE "99,999"
               @ 21,10      SAY "  " 
               WAIT
               LOOP
            ENDIF 

            aPart_:={}

            SCROLL(  3, 0, 24,80 )
            IF Part->( LASTREC() ) != 0
               GO TOP
               DO WHILE Part->( !EOF() )
                  IF Message->Mess09 = SPACE( 12 )
                     AADD( aPart_,Part->Desc;
                        +" "+STR( Wholesale,8, 2 )+" "+STR( Part->Instock,8, 0 );
                        +"  "+SUBSTR( Part->Partnum,1,10 );
                        +"   "+STR( RECNO(),6 ) )
                  ELSE
                     AADD( aPart_,( SUBSTR( Part->Partnum, 1,13 );
                        +"  "+SUBSTR( Part->Desc, 1,29 );
                        +" "+STR( Part->Instock, 8, 2 )+" "+STR( Wholesale,12, 2 );
                        +" "+Part->ABC+" "+Part->Unit+"      "+STR( RECNO(),6 ) ) )
                  ENDIF
                  SKIP ALIAS Part
               ENDDO
               SCROLL(  3, 0, 24,80 )
               DISPBOX( 3, 0, 24,79, 2 )
               IF !EMPTY( aPart_ )
                  anum := ACHOICE( 4, 2, 23,78, aPart_,,"AFUNC" )
                  IF LASTKEY() == -1
                     PartAdd( mpartnum )
                     SELECT Part
                     SEEK mpartnum
                      ApRLock( 3 )
                     mpartnum := Part->Partnum
                     UNLOCK
                      PartDets( @mpartnum )
                  ENDIF
                  IF PressedEsc()
                     RETURN NIL
                  ENDIF
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
                  mpartnum := Part->Partnum
               ENDIF
               SCROLL(  0, 0, 2,80 )
               DISPBOX( 0, 0, 2,79, 2 )
               @  1, 4 SAY TRIM(mpartnum)+" "+SUBSTR( Part->Desc, 1,25 );
               +" "+STR( Part->Instock, 9, 0 )
           ENDIF  
           RETURN mpartnum

         IF !FOUND()

            CatFind( @mpartnum )     // Finds By PartID Above

            SELECT Part
            SET ORDER TO 1                             // Partnum + Desc
            SEEK mpartnum
            IF FOUND()
               mpartnum := Part->Partnum
            ENDIF
            RETURN mpartnum
         ENDIF
      ENDCASE
      mtrue := .F.
   ENDDO                   // mtrue

   RETURN mpartnum

   ****  End of Partfind()

   **-------------------------------------------------------------------

FUNCTION Partchange( mpartnum )
  
   ***  Taken out temp    PartUsed( mpartnum )                    // Below
   /*
   aPart_ :={}
   SELECT Equ
   GOTO TOP
   DO WHILE Equ->( !EOF() )
      IF Equ->Partnum != mpartnum
         SKIP ALIAS Equ
         LOOP
      ENDIF
      SELECT EquDesc
      SET ORDER TO 1
      SEEK Equ->ModCode
      SELECT Equ
      AADD( aPart_,Equ->Modcode;
              +" "+EquDesc->Desc;
              +"  "+STR( Equ->PartQty,12, 3 ) )
         SKIP ALIAS Equ
   ENDDO                            // EOF Equ
      ASORT(aPart_,,,{ | x,y | x < y })
      SCROLL(  3, 0, 24,80 )
      DISPBOX( 3, 1, 24,79, 2 )
      @  3, 4 SAY " Part Used in The Following Modules " COLOR "G+" 
      @ 23,20 SAY "Any Key To Continue" COLOR "G+" 
      IF !EMPTY( aPart_ )
            @  3, 0 SAY " "
            AEVAL( aPart_,{ |A|QOUT( " "+CHR( 186 )+"  " );
                             ,QQOUT( A ),BreakTot() } )
      ****      anum := ACHOICE( 4, 5, 22,76,aPart_,,"AFUNC" )
      ENDIF
      WAIT 
   */

   mok := "Y" 
   DO WHILE mok == "Y"
      nl := 4
      SCROLL(  11, 0, 24,80 )
      DISPBOX( 11, 0, 23,79, 2 )
      cnewpart := SUBSTR( mpartnum, 1,16 )
      @ 12,10 SAY "TRUST THAT YOU MADE A BACK UP FIRST" 
      @ 14,20 SAY mpartnum  
      @ 16,10 SAY "Change Partnum" GET cnewpart PICTURE "!!!!!!!!!!!!!!!!"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      SELECT Part
      SET ORDER TO 1
      SEEK cnewpart
      IF FOUND()
         @ 16,50 SAY "Already Used Try again"
         LOOP
      ENDIF
      mcorrect := ApGetY( Message->Correct )
      IF mcorrect == "Y"
         SCROLL(  11, 0, 24,80 )
         DISPBOX( 11, 0, 24,79, 2 )
         @  12,10 SAY "Changing Part Number Please Wait"
         SELECT Equ
         ***         SET EXACT ON
         GOTO TOP
         nparts := 0
         ncount:= ncnt := 1
         mmodcode := SUBSTR( mpartnum, 1,16 )
         SEEK mmodcode
         IF FOUND()
            DO WHILE Equ->Modcode = mmodcode .AND. Equ->( !EOF() )
               nparts++
               SKIP ALIAS Equ
            ENDDO
            @ 13,30      SAY nparts PICTURE "999" COLOR "G+"
            @ 13,COL()+2 SAY "Parts In Module"
            SEEK mmodcode
         ENDIF
         DO WHILE FOUND()
             @ 15, 6      SAY Equ->ModCode+" "+STR( ncount )+"  "+mpartnum 
             @ 15,COL()+1 SAY "Parts Left" 
             @ 15,COL()+1 SAY nparts PICTURE "999" COLOR "G+"
             nparts--
            IF Equ->ModSeqno != SPACE ( 22 )
                mrecno := SUBSTR( Equ->ModSeqno,17, 6 )
            ELSE
                mrecno := STR( RECNO(), 6 )
            ENDIF
            mseek  := Equ->ModSeqno
            ApRLock( 3 )
            Equ->ModCode  := cnewpart           
            Equ->ModSeqno := cnewpart+mrecno   
            UNLOCK
            @ 16, 6 SAY Equ->ModSeqno 
            ncount++
            SELECT EquCut
            GOTO TOP
            SEEK mSeek
            DO WHILE FOUND()
               @ 18, 6 SAY EquCut->ModSeqno+"  "+STR( ncnt )+"  "+mpartnum 
               mrecno := SUBSTR( EquCut->ModSeqno,17, 6 )
                ApRLock( 3 )
               EquCut->ModSeqno := SUBSTR( cnewpart, 1,16 )+mrecno
               EquCut->ModTemp  := SUBSTR( cnewpart, 1,16 )+mrecno
               UNLOCK
               @ 19, 6 SAY EquCut->ModSeqno 
               ncnt++ 
               SEEK mSeek
            ENDDO
            SELECT Equ
            SEEK mmodcode
            ***             @ 21, 6 SAY "If Above not good ALT C to get out"
            ***             @ 23, 6 SAY "Module File may be DAMAGED  CHECK"
            INKEY( 0.4 )
         ENDDO 
         SCROLL( 20, 5, 23,78 )
  ***       SET EXACT OFF
         SELECT Part
         SET ORDER TO 1                     // mpartnum
         GOTO TOP
         SEEK mpartnum
          ApRLock( 3 )
         Part->Partnum := cnewpart
         UNLOCK
         SELECT PartSer
         SET ORDER TO 1
         GOTO TOP
          ApFLock( 3 )
         SEEK mpartnum
         ncount := 0
         @ 22, 6 SAY SPACE( 30 )   
        DO WHILE FOUND()
            PartSer->Partnum := cnewpart
            ncount++
            @ 22,10      SAY "Part Serial #  "
            @ 22,COL()+1 SAY ncount PICTURE "999.99" 
            INKEY( 0.8 )
            SEEK mpartnum
         ENDDO 
         UNLOCK
   ********************
         SELECT Fault
         SET ORDER TO 1
         GOTO TOP
          ApFLock( 3 )
         SEEK mpartnum
         ncount := 0
         @ 22, 6 SAY SPACE( 30 )   
        DO WHILE FOUND()
            Fault->Partnum := cnewpart
            ncount++
            @ 22,10      SAY "Fault"
            @ 22,COL()+2 SAY ncount PICTURE "999.99" 
            INKEY( 0.8 )
            SEEK mpartnum
         ENDDO 
         UNLOCK
         SELECT Prof
         GOTO TOP
         ncount := 0   
         @ 22, 6 SAY SPACE( 30 )   
          ApFLock( 3 )
         LOCATE ALL FOR Partnum = mpartnum
         DO WHILE FOUND()
            Prof->Partnum := cnewpart
            ncount++
            @ 22,10      SAY "Profile Part  "
            @ 22,COL()+2 SAY ncount PICTURE "999.99" 
            INKEY( 0.8 )
            CONTINUE
         ENDDO 
         UNLOCK
   *******************
         SELECT Invoice
         GOTO TOP
         ncount := 0   
         @ 22, 6 SAY SPACE( 30 )   
          ApFLock( 3 )
         LOCATE ALL FOR Partnum = mpartnum
         DO WHILE FOUND()
            Invoice->Partnum := cnewpart
            ncount++
            @ 22,10      SAY "Invoice Part  "
            @ 22,COL()+1 SAY ncount PICTURE "999.99" 
            INKEY( 0.8 )
            CONTINUE
         ENDDO 
         UNLOCK
         SELECT Hist
         SET ORDER TO 2
         GOTO TOP
         ncount := 0   
         @ 22, 6 SAY SPACE( 30 )   
          ApFLock( 3 )
         SEEK mpartnum
         DO WHILE FOUND()
            Hist->Partnum := cnewpart
            ncount++
            @ 22,10      SAY "History Part "
            @ 22,COL()+1 SAY ncount PICTURE "999.99" 
            INKEY( 0.8 )
            SEEK mpartnum
         ENDDO 
         UNLOCK
         SELECT Prof
         GOTO TOP
         ncount := 0   
         @ 22, 6 SAY SPACE( 30 )   
          ApFLock( 3 )
         LOCATE ALL FOR Partnum = mpartnum
         DO WHILE FOUND()
            Prof->Partnum := cnewpart
            ncount++
            @ 22,10      SAY "Prof Part "
            @ 22,COL()+1 SAY ncount PICTURE "999.99" 
            INKEY( 0.8 )
            CONTINUE
         ENDDO 
         UNLOCK
         ncount := 0
         @ 22, 6 SAY SPACE( 30 )   
         SELECT Supl
         GOTO TOP
         SET ORDER TO 1
          ApFLock( 3 )
         SEEK mpartnum
         DO WHILE FOUND()
            Supl->Partnum := cnewpart
            ncount++
            @ 22,10      SAY "Supplier Part " 
            @ 22,COL()+1 SAY ncount PICTURE "999.99" 
            INKEY( 0.8 )
            SEEK mpartnum
         ENDDO 
         UNLOCK
         SELECT Quot
         GOTO TOP
          ApFLock( 3 )
         ncount := 0
         @ 22, 6 SAY SPACE( 30 )   
         LOCATE ALL FOR Partnum = mpartnum
         DO WHILE FOUND()
           Quot->Partnum := cnewpart
             ncount++
             @ 22,10      SAY "Quot Part   "
             @ 22,COL()+1 SAY ncount PICTURE "999.99" 
             INKEY( 0.8 )
            CONTINUE
         ENDDO 
         UNLOCK
         SELECT QuotInfo
         GOTO TOP
         ncount := 0
         @ 22, 6 SAY SPACE( 30 )   
          ApFLock( 3 )
         LOCATE ALL FOR Partnum = mpartnum
         DO WHILE FOUND()
            QuotInfo->Partnum := cnewpart
             ncount++
             @ 22,10      SAY "Quot Info   "
             @ 22,COL()+1 SAY ncount PICTURE "999.99" 
             INKEY( 0.8 )
            CONTINUE
         ENDDO 
         UNLOCK
         SELECT Labour
         GOTO TOP
         ncount := 0
         @ 22, 6 SAY SPACE( 30 )   
          ApFLock( 3 )
         DO WHILE Labour->( !EOF() )
            IF Labour->Partnum = mpartnum
               Labour->Partnum := cnewPart
               ncount++
               @ 22,10      SAY "Labour Part  "
               @ 22,COL()+1 SAY ncount PICTURE "999.99" 
               INKEY( 0.8 )
           ENDIF
            SKIP ALIAS Labour
         ENDDO 
         UNLOCK
         /* Taken Out
         SELECT QuotStk
         ncount := 0
          ApFLock( 3 )
         LOCATE ALL FOR Partnum = mpartnum
         DO WHILE FOUND()
            QuotStk->Partnum := cnewpart
             @ 23, 6 SAY "QuotStk Part "+STR( ncount ) PICTURE "999.99" 
             ncount++
             INKEY( 1 )
            CONTINUE
         ENDDO 
         GOTO TOP
         LOCATE ALL FOR ModCode = TRIM( mpartnum )
         DO WHILE FOUND()
            QuotStk->ModCode := TRIM( cnewpart )
            CONTINUE
         ENDDO 
         UNLOCK
         SELECT System
         GOTO TOP
          ApFLock( 3 )
         LOCATE ALL FOR ModCode = TRIM( mpartnum )
         DO WHILE FOUND()
            System->ModCode := TRIM( cnewpart )
            CONTINUE
         ENDDO 
         UNLOCK
         */
         SELECT Orders
         SET ORDER TO 1         // Partnum
         ncount := 0
         @ 22, 6 SAY SPACE( 30 )   
         GOTO TOP
         SEEK mpartnum
          ApFLock( 3 )
         DO WHILE FOUND()
            Orders->Partnum := cnewpart
             ncount++
             @ 22,10      SAY "Orders Part  "
             @ 22,COL()+1 SAY ncount PICTURE "999.99" 
             INKEY( 0.8 )
            SEEK mpartnum
         ENDDO  
         UNLOCK
         SELECT PartOper
         GOTO TOP
         SEEK mpartnum
          ApFLock( 3 )
         DO WHILE FOUND()
            PartOper->Partnum := cnewpart
            SEEK mpartnum
         ENDDO  
         UNLOCK
         ncount := 0
         @ 22, 6 SAY SPACE( 50 )   
         SELECT EquCut
          ApFLock( 3 )
         GOTO TOP
         LOCATE ALL FOR Partnum = TRIM( mpartnum )
         DO WHILE FOUND()
            EquCut->Partnum := TRIM( cnewpart )
             ncount++
             @ 22,10      SAY "Equ Cut Part  "
             @ 22,COL()+1 SAY ncount PICTURE "999.99" 
             @ 22,COL()+2 SAY EquCut->ModSeqNo COLOR "G+" 
             INKEY( 0.8 )
             CONTINUE
         ENDDO 
         UNLOCK
         ncount := 0
         @ 22, 6 SAY SPACE( 50 )   
         SELECT CusNotes
          ApFLock( 3 )
         SEEK mpartnum
         cnewpart := cnewpart+"    "            // In case 16
         DO WHILE FOUND()
            ncode := SUBSTR( Cusnotes->Code_Ref,21, 2 )
            Cusnotes->Code_Ref := SUBSTR( cnewpart, 1,20 )+ncode
             ncount++
             @ 22,10      SAY "Memo Part-  "
             @ 22,COL()+1 SAY ncount PICTURE "999.99" 
             INKEY( 0.8 )
            SEEK mpartnum
         ENDDO
         SELECT EquDesc
         GOTO TOP
         ncount := 0
         @ 22, 6 SAY SPACE( 30 )   
         SEEK TRIM( mpartnum )
         IF FOUND()
              ApRLock( 3 )
             EquDesc->ModCode := TRIM( cnewpart )
             ncount++
             @ 22,10      SAY "Equ Desc Part  "
             @ 22,COL()+1 SAY ncount PICTURE "999" 
             @ 22,COL()+2 SAY EquDesc->ModCode COLOR "G+"
             INKEY( 0.8 )
           UNLOCK 
         ENDIF 
         SELECT QuotStk
         SET ORDER TO 2
         GOTO TOP
         ncount := 0
         @ 22, 6 SAY SPACE( 30 )   
         SEEK TRIM( mpartnum )
         IF FOUND()
              ApRLock( 3 )
             QuotStk->Partnum := TRIM( cnewpart )
             ncount++
             @ 22,10      SAY "QuotStk Part  "
             @ 22,COL()+1 SAY ncount PICTURE "999" 
             @ 22,COL()+2 SAY QuotStk->Partnum COLOR "G+"
             QuotStk->ModPart := QuotStk->Modcode+QuotStk->Partnum
             INKEY( 0.8 )
             UNLOCK 
         ENDIF 
         SELECT LabCut
         GOTO TOP
         ncount := 0
         @ 22, 6 SAY SPACE( 30 )   
         SEEK TRIM( mpartnum )
         DO WHILE FOUND()
              ApRLock( 3 )
             LabCut->Partnum := TRIM( cnewpart )
             ncount++
             @ 22,10      SAY "Lab Cut"
             @ 22,COL()+1 SAY ncount PICTURE "999" 
             @ 22,COL()+2 SAY LabCut->Partnum COLOR "G+"
             LabCut->Partnum :=cnewpart
             UNLOCK
             INKEY( 0.8 )
             SEEK mpartnum
         ENDDO
         SELECT QuotStk
          ApFLock( 3 )
         GOTO TOP
         LOCATE ALL FOR ModCode = TRIM( mpartnum )
         DO WHILE FOUND()
             QuotStk->ModCode := TRIM( cnewpart )
             ncount++
             @ 22,10      SAY "QuotStk Module"
             @ 22,COL()+1 SAY ncount PICTURE "999.99" 
             @ 22,COL()+2 SAY QuotStk->Modcode COLOR "G+" 
             QuotStk->ModPart := QuotStk->Modcode+QuotStk->Partnum
             INKEY( 0.8 )
             CONTINUE
         ENDDO 
         UNLOCK
         SELECT Equ
         GOTO TOP
         ncount := 0
         @  3,58 SAY "Changed Module" COLOR "G+"   
          ApFLock( 3 )
         LOCATE ALL FOR Partnum = TRIM( mpartnum )
         DO WHILE FOUND()
            Equ->Partnum := TRIM( cnewpart )
            ncount++
            @ 22,10      SAY "Equ Part  "
            @ 22,COL()+1 SAY ncount PICTURE "999" 
            @ 22,COL()+2 SAY Equ->ModCode COLOR "G+"
            @ nl,58      SAY Equ->ModCode COLOR "G+"
            @ nl,COL()   SAY ncount PICTURE "999" 
            nl++
   ****            INKEY( 0.8 )
            CONTINUE
         ENDDO 
         UNLOCK
         @ 23,10 SAY "Any Key to Continue"
         INKEY( 0 )
      ENDIF             // mcorrect
   ******  Must also have DBF Use       DBFReIndx()// PRG
      mok := "N"
   ENDDO                // mok
   mpartnum := Part->Partnum

   RETURN mpartnum

   *** End of Partchange()

   **-------------------------------------------------------------------

STATIC FUNCTION PartRank( mpartnum )

   aPart_ := {}
   nrecno := 0
   SELECT Part
   SET EXACT OFF
   SET ORDER TO 1
   SEEK mpartnum
   IF FOUND()
      mpartnum := Part->Partnum
      RETURN mpartnum                     // Found Partnum
   ENDIF
   mpart  := TRIM( mpartnum )
   FOR x = 1 TO LEN( mpart ) 
      SEEK SUBSTR( mpart,1, x )      // Tracer
   NEXT
   IF !FOUND()
      CatFind( @mpartnum )
   ENDIF
   IF FOUND()
      DO WHILE Part->Partnum = mpart .AND. Part->( !EOF() )
         IF Message->Mess09 = SPACE( 12 )
             AADD( aPart_,SUBSTR( Part->Desc, 1,33 );
                    +" "+STR( Wholesale,12, 2 )+" "+STR( Part->Instock, 8, 0 );
                    +"  "+SUBSTR( Part->Partnum, 1,11 );
                    +" "+Part->ABC+" "+Part->Unit+"     "+STR( RECNO(),6 ) )
           ELSE
             AADD( aPart_,( SUBSTR( Part->Partnum, 1,14 );
              +"  "+SUBSTR( Part->Desc, 1,29 );
              +" "+STR( Part->Instock,10, 2 )+" "+STR( Wholesale,12, 2 );
              +" "+Part->ABC+" "+SUBSTR( Part->Unit, 1, 8 );
              +"      "+STR( RECNO(),6 ) ) )
         ENDIF                       // Mess09
         SKIP ALIAS Part
      ENDDO                  // Part
      SCROLL(  3, 0, 24,80 ) 
      DISPBOX( 3, 1, 24,79, 2 )
      IF EMPTY( aPart_ )
         CatFind( mpartnum )
       ELSE
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 4, 2, 23,78, aPart_,,"AFUNC" )
   IF LASTKEY() == -1

       PartAdd( @mpartnum )

      mpartnum := Part->Partnum 
      SEEK mpartnum
       PartDets( @mpartnum )
      IF PressedEsc()
         RETURN SPACE( 20 )
      ENDIF
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      GOTO nrecno
      mpartnum := Part->Partnum
   ENDIF
         IF PressedEsc()
           RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         mpartnum := Part->Partnum
         SCROLL(  0, 0, 2,80 )
         DISPBOX( 0, 1, 2,79, 2 )
         @  1, 3 SAY TRIM(mpartnum)+" "+SUBSTR( Part->Desc, 1,30 );
                     +" "+STR( Part->Instock,9, 0 )+" "+Part->ABC
        RETURN mpartnum
     ENDIF                      // !Empty
   ENDIF                        // FOUND() by Input SUBSTR Part

   RETURN mpartnum

   ****  End of PartRank()

   **-------------------------------------------------------------------

FUNCTION PartView()

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      nrecno := 0 
      SCROLL()
       mcodeno  := SPACE( 8 )
       mpartnum := SPACE( 16 )

          Partfind( @mpartnum, mcodeno )                        // Below

        IF PressedEsc()
           RETURN NIL
        ENDIF
        SELECT Part
        SET ORDER TO 1
        SEEK mpartnum
        mpartnum := Part->Partnum

         PartDets( @mpartnum )                         // CWP2

        IF PressedEsc()
           RETURN NIL
        ENDIF

     mcontinue := "N"
   ENDDO

   mpartnum := SPACE( 20 )
   RETURN NIL

   **** End of Partview

   **-------------------------------------------------------------------

STATIC FUNCTION CatFind( mpartnum )

   aPart_:={}
   mpart  := TRIM( mpartnum )
   nrecno := 0
   mok    := "N"
   IF LASTREC() == 0

       Partadd( @mpartnum )         // Below

      mpartnum := Part->Partnum
      RETURN mpartnum
   ENDIF
   SELECT Part
   SET ORDER TO 3                  //  PartId+Desc
   SET EXACT OFF
   IF LASTREC() != 0
      FOR x = 1 TO LEN( mpart )
        SEEK SUBSTR( mpart,1, x )      // Tracer
      NEXT
      SEEK mpart
      IF FOUND()
         DO WHILE Part->PartId = mpart .AND. Part->( !EOF() )
            IF Message->Mess09 = SPACE( 12 )
               AADD( aPart_,( Part->Desc;
                         +" "+STR( Part->Instock, 8, 2 )+" "+STR( Wholesale, 8, 2);
                         +"  "+SUBSTR( Part->Partnum,1,10 );
                         +"   "+STR( RECNO(),6 ) ) )
              ELSE
               AADD( aPart_,( SUBSTR( Part->Partnum, 1 ,12 );
                   +"  "+SUBSTR( Part->Desc, 1,29 );
                   +" "+STR( Part->Instock, 8, 2 )+" "+STR( Wholesale,12, 2);
                   +" "+Part->ABC+" "+Part->Unit+"      "+STR( RECNO(),6 ) ) )
             ENDIF
             SKIP ALIAS Part
         ENDDO
      ***      IF Message->Mess09 = SPACE( 12 )
            ASORT(aPart_,,,{ | x,y | x < y })
      ***      ENDIF    
      ENDIF                        // FOUND()
      SCROLL(  3, 0, 24,80 ) 
      DISPBOX( 3, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
         anum := ACHOICE( 4, 3, 23,76, aPart_,,"AFUNC" )
         IF LASTKEY() == -1
     
              PartAdd( mpartnum )                  // Below
             mpartnum := Part->Partnum 
             DO CASE
                CASE SUBSTR( Part->Partnum, 1, 3 ) = "JC-"
                     RETURN mpartnum
                CASE SUBSTR( Part->Partnum, 1, 3 ) = "QU-"
                     RETURN mpartnum
                CASE SUBSTR( Part->Partnum, 1, 3 ) = "TEM"
                     RETURN mpartnum
                CASE SUBSTR( Part->Partnum, 1, 3 ) = "ZZT"
                     RETURN mpartnum
                CASE SUBSTR( Part->Partnum, 1, 3 ) = "TT-"
                     RETURN mpartnum
             ENDCASE
             SELECT Part
             SET ORDER TO 1
             SEEK mpartnum
             mpartnum := Part->Partnum

              PartDets( @mpartnum )    // CWP2

         ENDIF
         IF PressedEsc()
           RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         mpartnum := Part->Partnum
      ENDIF
      SCROLL(  1, 6, 1,74 )
      DISPBOX( 0, 1, 2,79, 2 )
      @  1, 4 SAY TRIM(mpartnum)+" "+SUBSTR( Part->Desc, 1,30 );
                  +" "+STR( Part->Instock,9, 0 )+"  "+Part->ABC  // COLOR c_hicolor
   ENDIF

   RETURN mpartnum 

   ****----- End of CatFind()

   **-------------------------------------------------------------------

STATIC FUNCTION PartGet( ccatno )

   aPart_ :={}
   nrecno := 0
   IF LASTREC() != 0
      DO WHILE Part->Catno == ccatno
         IF Message->Mess09 = SPACE( 12 )
            AADD( aPart_,Part->Desc;
              +" "+STR( Wholesale,9,2)+" "+STR( Part->Instock,9,0 );
              +" "+Part->Partnum+"    "+STR( RECNO(),6 ) )
           ELSE
               AADD( aPart_,( SUBSTR( Part->Partnum, 1,12 );
                   +"  "+SUBSTR( Part->Desc, 1,29 );
                   +" "+STR( Part->Instock, 8, 2 )+" "+STR( Wholesale,12, 2);
                   +" "+Part->ABC+" "+Part->Unit+"        "+STR( RECNO(),6 ) ) )
         ENDIF
         SKIP ALIAS Part
      ENDDO
      ASORT(aPart_,,,{ | x,y | x < y })
      SCROLL()
      DISPBOX( 0, 1, 2,79, 2 )
      @  1, 6 SAY TRIM(ccatno)+"  "+Cat->CatDesc     // COLOR c_hicolor
      DISPBOX( 3, 0, 24,79, 2 )
      IF !EMPTY( aPart_ )
         anum := ACHOICE( 4, 3, 23,78,aPart_,,"AFUNC" )
         IF LASTKEY() == -1

             PartAdd( @mpartnum )

            mpartnum := Part->Partnum 
            SEEK mpartnum
             PartDets( @mpartnum )
         ENDIF
         IF PressedEsc()
            RETURN SPACE( 20 )
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         mpartnum := Part->Partnum
      ENDIF
   ENDIF

   RETURN mpartnum

   **** End of PartGet()

   **-------------------------------------------------------------------

FUNCTION Suppliers( mpartnum )

   tempscr := SAVESCREEN(  0, 0, 24,80 )
   mcodeno := SPACE( 8 )
   SELECT Supl
   SET ORDER TO 1                       // Codeno Index
   aPart_:={}
   IF LASTREC() != 0
      GO TOP
      SEEK mpartnum
      DO WHILE Supl->Partnum = mpartnum .AND. Supl->( !EOF() )
         SELECT Name
         SEEK Supl->Codeno
         SELECT Supl
         AADD( aPart_,( Name->Name+"  "+STR( Supl->Cost );
              +" "+DTOC( Supl->Date )+"    "+STR( RECNO(),6 ) ) )
         SKIP ALIAS Supl
      ENDDO                         // Supl Partnum
      ASORT(aPart_,,,{ | x,y | x < y })
      SCROLL(  3, 0, 24,80 )
      DISPBOX( 3, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
   ***         @  3, 0 SAY " "
   ***         AEVAL( aPart_,{ |A|QOUT( "   "+CHR( 186 )+"  " );
   ***                          ,QQOUT(A),BreakTot() } )
   ***         INKEY( 1 )
         anum := ACHOICE( 4,10, 23,66, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
          GOTO nrecno
         mcodeno := Supl->Codeno
         SELECT Name
         SEEK mcodeno 
      ENDIF                             // !EMPTY
   ENDIF                                    // LastRec()
   mok := "Y"
   DO WHILE mok = "Y"
      SCROLL()
      DISPBOX( 0, 1,  2,79, 2 )
      @  1,10 SAY mpartnum+" "+Part->Desc
      DISPBOX( 3, 1, 19,79, 2 )
      SELECT Supl
      SET ORDER TO 1              // Partnum+Codeno
      SEEK mpartnum+mcodeno
      IF FOUND()
         @  5, 7 SAY mcodeno+"  "+Name->Name
         @  7,23 SAY "Cost : "
         @  7,32 SAY Supl->Cost PICTURE "99999.99" 
         @  7,46 SAY "Part Cost : "
         @  7,58 SAY Part->Trade
         @  9,18 SAY "Last Price"
         @  9,33 SAY Supl->LastCost
         @ 11,11 SAY "Suppliers Partnum    "+Supl->SuppId
         @ 13,17 SAY "Information "
         @ 13,33 SAY Supl->Info 
         @ 15,18 SAY "Pref Supl"
         @ 15,33 SAY Part->Codeno
         @ 17,22 SAY "Date"
         @ 17,33 SAY Supl->Date
      ***       @ 17,COL()+2 SAY "Lead Time "+STR( Supl->LeadTime )
      ENDIF                        // Found
      SCROLL(  20, 0, 24,80 )
      DISPBOX( 20, 1, 24,79, 2 )
      nsel := 1
      @ 22, 3      PROMPT "Detail"
      @ 22,COL()+2 PROMPT "Add New"
      @ 22,COL()+2 PROMPT "Supply Hist"
      @ 22,COL()+2 PROMPT "Use Hist"
      @ 22,COL()+2 PROMPT "Operations"
      @ 22,COL()+2 PROMPT "Where Used"
      @ 22,COL()+2 PROMPT "Delete Supl"
      @ 24,60 SAY " DT3?  "
      MENU TO nsel
      DO CASE
         CASE PressedEsc()
            RETURN mpartnum
         CASE nsel = 1                                       // Details
            ApRLock( 3 )
            mcost := Supl->Cost
            @  7,32 GET Supl->Cost   PICTURE "99999.99"
            Supl->LastCost := Supl->Cost
            Supl->Date := DATE() 
            @ 11,32      GET Supl->SuppId PICTURE "@K!"
            @ 13,32      GET Supl->Info   PICTURE "@KX"
            @ 17,33      SAY Supl->Date
            @ 17,COL()+2 GET Supl->Codeno
            READ
            UNLOCK 
            SELECT Part
            mcodeno := Part->Codeno
            @ 15,32 GET mcodeno PICTURE "@!"
            READ
            ApRLock( 3 )  
            Part->Codeno := mcodeno
            UNLOCK  
            LOOP
         CASE nsel == 2                         // Add New
            tempscreen := SAVESCREEN(  0, 0, 24,80 )
            NameRank( @mcodeno )
            mcodeno := Name->Codeno
            RESTSCREEN( 0, 0, 24,80, tempscreen )
            mcorrect := "N"
            DO WHILE mcorrect == "N"
               SELECT Supl
               LOCATE FOR Supl->Partnum == mpartnum .AND. Supl->Codeno == mcodeno
               IF !FOUND()
                  SELECT Supl
                  ApRLock( 3 ) 
                  APPEND BLANK
                  Supl->Partnum := Part->Partnum
                  Supl->SuppId  := Part->Partnum
                  Supl->Codeno  := mcodeno
                  Supl->Cost    := Part->Trade
                  UNLOCK
               ENDIF
               SELECT Supl
               ApRLock( 3 )
               Supl->Date := DATE()
               @  5, 7 SAY Name->Codeno+"  "+Name->Name
               @  7,23 SAY "Cost : "          GET Supl->Cost PICTURE "99999.99" 
               @  7,46 SAY "Part Cost : "
               @  7,58 SAY Part->Trade
               @  9,18 SAY "Last Price"
               @  9,32 SAY Supl->LastCost
               @ 11,11 SAY "Suppliers Partnum" GET Supl->SuppId PICTURE "@K!"
               @ 13,17 SAY "Information"       GET Supl->Info   PICTURE "@KX"
               ***              @ 13,32 SAY Supl->Info 
               ***              @ 15,18 SAY "Pref Supl"
               @ 15,32 SAY Part->Codeno
               @ 17,22 SAY "Date : "
               @ 17,33 SAY Supl->Date
               ***              @ 17,COL()+2 SAY "Lead Time"   GET Supl->LeadTime PICTURE "999.99"
               READ
               Supl->LastCost := Supl->Cost
               UNLOCK
               SELECT Part
               mcodeno := Part->Codeno
               @ 15,32 GET mcodeno PICTURE "@!"
               READ
               ApRLock( 3 )  
               Part->Codeno := mcodeno
               UNLOCK  
               mcorrect := "Y"
            ENDDO                                              // mcorrect
            mok = "N"

         CASE nsel = 3                                   // Supply
            ProfSupply( mcodeno, mpartnum )
         CASE nsel = 4                                   // Equip
            SAVE SCREEN TO Tempscrn
            HistPart( mpartnum )                  // XF_Hist
            RESTORE SCREEN FROM Tempscrn
         CASE nsel = 5
            PartOper2( mpartnum )                // XF2PPART
         CASE nsel = 6
            PartUsed( mpartnum )
            INKEY( 0 )
         CASE nsel = 7                                   // Delete
            mok := ApGetN( TRIM( Message->Delete )+" This Supplier " )
            IF mok == "Y"
               SELECT Supl
               ApRLock( 3 ) 
               DELETE 
               UNLOCK           
            ENDIF                            // mok
            mok := "N"
      ENDCASE                                        // Supplier End Case 
   ENDDO                                      // mok 

   RESTSCREEN( 0, 0, 24,80, tempscr )

   RETURN mpartnum

   ***----- End Suppliers

   **---------------------------------------------------------------------*

STATIC FUNCTION ProfSupply( mcodeno, mpartnum )

   nl  := 4
   npl := 20 
   SCROLL(  3, 0, 24,80 )
   DISPBOX( 3, 1, 24,79, 2 )
   @ nl, 6 SAY "Codeno       Qty        Cost  Discount      Amount   Date      Ordnum"
   nl+=2
   navercost:= ncnt := 0
   SELECT ProfNat
   SET ORDER TO 2                          // Partnum Index
   GOTO TOP
   SEEK mpartnum
   DO WHILE ProfNat->Partnum = mpartnum .AND. ProfNat->( !EOF() )
      IF nl > npl
         nl++
         @ nl,10 SAY "Any Key to Return"
         INKEY( 0 )
         nl := 4
         SCROLL(  4, 6, 23,74 )
      ENDIF
      @ nl, 6      SAY ProfNat->Codeno
      @ nl,COL()+2 SAY ProfNat->Qty      PICTURE "99,999"
      @ nl,COL()+2 SAY ProfNat->Cost     PICTURE "9999,999.99"
      @ nl,COL()+2 SAY ProfNat->Discount PICTURE "9999.99"
      @ nl,COL()+2 SAY ProfNat->Amount   PICTURE "9999,999.99"
      @ nl,COL()+2 SAY ProfNat->Pdate
      @ nl,COL()+2 SAY ProfNat->Ordnum
      ***   @ nl,COL()+2 SAY ProfNat->QRate
      ncnt++
      navercost += ProfNat->Cost   
      ***   @ nl,COL()+3 SAY SUBSTR( ProfNat->Partnum, 1,10 )
      nl++
      SKIP ALIAS ProfNat
   ENDDO                        // ProNat EOF()
   nl+=2
   @ nl, 8 SAY "Not Incl Discount Average Cost ="
   @ nl,44 SAY navercost/ncnt PICTURE "$999,999.99"
   nl+=2
   SELECT ProfNat
   SET ORDER TO 1
   SELECT Part
   ntrade     := Part->Trade
   nwholesale := Part->Wholesale 
   @ nl,20 SAY "Cost =" GET ntrade     PICTURE "999999.99"
   @ nl,40 SAY "Sell =" GET nwholesale PICTURE "999999.99"
    READ
    ApRLock( 3 )
   Part->Trade     := ntrade
   Part->Wholesale := nwholesale 
   UNLOCK

   RETURN mpartnum

   *****----- End ProfSupply

   *******---------------  END OF FILE XF_PART.PRG

