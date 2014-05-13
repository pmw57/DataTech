   ***  JK  06-08-11 14:56:35 

/* 
   Program......:              XF_FAULT.PRG
   Author.......: J.Kirby
   Date.........: 15/09/1997
   Functions....: BrandFind, FaultGet
   Static funcs.: FaultDelete, NameFault, PartFault, JCFault
   Not used.....: OperateGet
*/

FUNCTION BrandFind()

   mcorrect := "N"
   DO WHILE mcorrect == "N"
      SCROLL()
      aPart_:={}
      SELECT Fault
      GOTO TOP
      mselect := "  "
      DO WHILE Fault->( !EOF() )
         IF SUBSTR( Fault->Partnum, 1, 2 ) = mselect
            SKIP ALIAS Fault
            LOOP
         ENDIF 
         mselect := SUBSTR( Fault->Partnum, 1, 2 ) 
         AADD( aPart_,( mselect+"     "+Fault->Model;
                     +"          "+STR( RECNO(),6 ) ) )
         SKIP ALIAS Fault
      ENDDO
      SCROLL()
      DISPBOX(  0, 0, 24,79, 2 )
      @  1,10 SAY "Select by the first Two Characters" COLOR "RG+" 
      IF !EMPTY( aPart_ )
         anum := ACHOICE( 3, 5, 23,30,aPart_,,"AFUNC" )
         mpartdes := aPart_[anum]
         nrecno:= VAL( RIGHT( mpartdes,6 ) )
         GOTO nrecno
         mselect := SUBSTR( Fault->Partnum, 1, 2 )
      ENDIF
      @ 6,30 SAY "XX To Add Blank for all" GET mselect PICTURE "@!"
      READ
      IF mselect = "XX"
         FaultGet()
         BrandFind()         
      ENDIF       
      IF PressedEsc()
         RETURN NIL
      ENDIF
      aPart_:={}
      SELECT Fault
      GOTO TOP
      IF LASTREC() != 0
         DO WHILE Fault->( !EOF() )
            IF mselect != "  "
               IF SUBSTR( Fault->Partnum, 1, 2 ) != mselect
                  SKIP ALIAS Fault
                  LOOP
               ENDIF
            ENDIF 
            AADD( aPart_, ( Fault->ChasMech;
                +" "+Fault->Brand+" "+TRIM( Fault->Model );
                +" "+TRIM( Fault->Partnum )+"  "+SUBSTR( Fault->Symptom, 1,25 );
                +"          "+STR( RECNO(),6 ) ) )
            SKIP ALIAS Fault
         ENDDO
      ENDIF   // LastRec
      SCROLL()
      DISPBOX(  0, 0, 24,80, 2 )
      @  0,25 SAY "  Searching File  " COLOR "RG+" 
      IF !EMPTY( aPart_ )
         anum := ACHOICE( 1, 2, 23,79,aPart_,,"AFUNC" )
         mpartdes := aPart_[anum]
         nrecno:= VAL( RIGHT( mpartdes,6 ) )
         GOTO nrecno
      ENDIF
      IF PressedEsc()
        RETURN NIL
      ENDIF
      coderef := Fault->FltRecno
      MemoDisp( coderef )                 //  XF_Memo2
      manother = "Y"
      DO WHILE manother = "Y"
         SCROLL()
         DISPBOX(  0, 0, 19,79, 2 )
         @  0,30 SAY "  Searching File  " COLOR "RG+" 
         nl := 1
         @ nl, 3      SAY Fault->Partnum COLOR "RG+"
         @ nl,COL()+2 SAY Fault->ChasMech
         @ nl,COL()+2 SAY Fault->Brand   
         nl++
         @ nl, 3      SAY Fault->Model
         @ nl,COL()+2 SAY Fault->Area
         @ nl,COL()+4 SAY Fault->Ddate
         nl+=2
         @ nl, 3 SAY Fault->Symptom
         nl++
         @ nl, 3 SAY Fault->Fix1
         nl++
         @ nl, 3 SAY Fault->Fix2
         nl++
         @ nl, 3 SAY Fault->Fix3
         nl++
         @ nl, 3 SAY Fault->Fix4
         nl++
         @ nl, 3 SAY Fault->Fix5
         nl++
         @ nl, 3 SAY Fault->Fix6
         nl++
         @ nl, 3 SAY Fault->Fix7
         nl++
         @ nl, 3 SAY Fault->Fix8
         SELECT Fault
         nselect := 1
         SCROLL(  19, 0, 24,80 )
         DISPBOX( 19, 0, 24,79, 2 )
         @ 19,10 SAY " --- Operations --- "
         @ 21, 4      PROMPT " "
         @ 21,COL()+1 PROMPT "1. Search"
         @ 21,COL()+2 PROMPT "2. Edit"
         @ 21,COL()+2 PROMPT "3. Add New"
         @ 21,COL()+2 PROMPT "4. Print"
         @ 21,COL()+2 PROMPT "5. Memo"
         @ 23, 6      PROMPT "6. Info-List"
         @ 23,COL()+2 PROMPT "7. Name-Info"
         @ 23,COL()+2 PROMPT "8. JC-Info"
         @ 23,COL()+2 PROMPT "9. Delete"
         @ 23,COL()+2 PROMPT "Drawing"
         @ 23,COL()+2 PROMPT "Exit"

         MENU TO nselect

         DO CASE
            CASE nselect == 12 .OR. PressedEsc()
               RETURN NIL
            CASE nselect == 1 
               LOOP
            CASE nselect == 2                  // Search
               BrandFind()
            CASE nselect == 3                  // Edit
               SCROLL()
               DISPBOX( 0, 0, 24,79, 2 )
               @  0,25 SAY "  Editing File  " COLOR "RG+" 
               ***          coderef := Fault->FltRecno
               ***          MemoDisp( coderef )                 //  XF_Memo2
               SELECT Fault 
                ApRLock( 3 )
               @  1, 3      GET Fault->Partnum  PICTURE "@!"
               @  2, 3      GET Fault->ChasMech PICTURE "@X" 
               @  2,COL()+2 GET Fault->Brand    PICTURE "@X"
               @  3, 3      GET Fault->Model    PICTURE "@X"
               @  3,COL()+2 GET Fault->Area     PICTURE "@X"
               @  3,COL()+4 GET Fault->Ddate PICTURE "99/99/9999"

               @  5, 3 GET Fault->Symptom  PICTURE "@X"
               @  6, 3 GET Fault->Fix1     PICTURE "@X"
               @  7, 3 GET Fault->Fix2     PICTURE "@X"
               @  8, 3 GET Fault->Fix3     PICTURE "@X"
               @  9, 3 GET Fault->Fix4     PICTURE "@X"
               @ 10, 3 GET Fault->Fix5     PICTURE "@X"
               @ 11, 3 GET Fault->Fix6     PICTURE "@X"
               @ 12, 3 GET Fault->Fix7     PICTURE "@X"
               @ 13, 3 GET Fault->Fix8     PICTURE "@X"
                READ
               UNLOCK
               SELECT Fault 
               coderef := Fault->FltRecno
               MemoFile( coderef )                 //  XF_Memo2
               LOOP
            CASE nselect == 4                  // Add New
               FaultGet()
               BrandFind()         
            CASE nselect == 5                  // List/Print
               mwhere := "S"
               npl    := 54

               Printsel()                                  // _LF_Init

               IF mwhere == "P"
                  SET MARGIN TO 2
                  npl := 56
               ELSE
                  npl := 10
               ENDIF
               nl := 1
               @  nl, 0 SAY TRIM( Control->U_Name )
               @  nl,38 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                         +STR( YEAR(DATE() ),5 )
               nl+=2
               @ nl, 2 SAY Fault->Partnum
               @ nl,25 SAY Fault->Area
               @ nl,42 SAY Fault->Ddate
               nl++
               @ nl, 1 SAY Fault->ChasMech
               @ nl,18 SAY Fault->Brand  
               @ nl,36 SAY Fault->Model
               nl+=2
               @ nl, 2 SAY Fault->Symptom
               nl++
               IF Fault->Fix1 != SPACE( 60 )
                  @ nl, 2 SAY Fault->Fix1
                  nl++
               ENDIF
               IF Fault->Fix2 != SPACE( 60 )
                  @ nl, 2 SAY Fault->Fix2
                  nl++
               ENDIF
               IF Fault->Fix3 != SPACE( 60 )
                  @ nl, 2 SAY Fault->Fix3
                  nl++
               ENDIF
               IF Fault->Fix4 != SPACE( 60 )
                  @ nl, 2 SAY Fault->Fix4
                  nl++
               ENDIF
               IF Fault->Fix5 != SPACE( 60 )
                  @ nl, 2 SAY Fault->Fix5
                  nl++
               ENDIF
               IF Fault->Fix6 != SPACE( 60 )
                  @ nl, 2 SAY Fault->Fix6
                  nl++
               ENDIF
               IF Fault->Fix7 != SPACE( 60 )
                  @ nl, 2 SAY Fault->Fix7
                  nl++
               ENDIF
               IF Fault->Fix8 != SPACE( 60 )
                  @ nl, 2 SAY Fault->Fix8
                  nl++
               ENDIF
               nl+=2
               coderef := Fault->FltRecno
               SELECT Cusnotes
               cdetail := ""
               SEEK coderef
               IF FOUND()   
                   GetDets( coderef )                           // XF_Memo2
                   FormP( cdetail,60,10 )                       // XF_Memo2
               ENDIF
               SELECT Fault     
               IF mwhere == "P"
                  EndPrint()
                  SET MARGIN TO 0
                 ELSE
                  WAIT
               ENDIF
               LOOP
            CASE nselect == 6                              // Memo                  
               SELECT Fault 
               coderef := Fault->FltRecno
               M2MemoFile( coderef )                 //  XF_Memo2
               LOOP
            CASE nselect == 7
               PartFault()
               LOOP
            CASE nselect == 8
               NameFault()
               LOOP
            CASE nselect == 9
               JCFault()
               LOOP
            CASE nselect == 10
               FaultDelete()
               LOOP
            CASE nselect == 11
               FaultDraw()
               LOOP
         ENDCASE 
         LOOP
      ENDDO // manother
   ENDDO                          // mcontinue

   RETURN NIL

STATIC FUNCTION FaultDelete()

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      SELECT Fault
      GOTO TOP
      namount := " "
      nrecno  := 0
      aPart_  := {}
      DO WHILE Fault->( !EOF() ) 
              AADD( aPart_,( Fault->ChasMech+" "+Fault->Brand;
                  +" "+Fault->Partnum;
                  +" Delete = Y "+namount;
                  +"                    "+STR( RECNO(),6 ) ) )
               SKIP ALIAS Fault
      ENDDO                         // Fault EOF
      SCROLL() 
      DISPBOX( 0, 0, 2,79, 2 )
      @  1,10 SAY "Edit Index or Delete Information" COLOR "RG+"
      @  1,62 SAY "Esc to Exit" COLOR "RG+"
      DISPBOX( 3, 0, 23,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 4, 3, 22,77, aPart_,,"AFUNC" )
         IF LASTKEY() = 27
            EXIT
         ENDIF  
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
      ENDIF
          ApRLock( 3 )
      @ ROW(), 1 GET Fault->ChasMech PICTURE "@X"
      @ ROW(),22 GET Fault->Brand    PICTURE "@X"
      @ ROW(),40 GET Fault->Model    PICTURE "@X"
      @ ROW(),72 GET namount VALID( namount $ "NY " ) PICTURE "@!"
       READ
      IF namount = "Y"
  ***          SELECT PartOper
  ***           DELETE ALL FOR PartOper->Partnum   // Maybe used by other 
         SELECT Fault
         coderef := Fault->FltRecno
         SELECT Cusnotes
         SEEK coderef
           ApFLock( 3 )
         DO WHILE FOUND()
             DELETE
             SEEK coderef
         ENDDO
         UNLOCK
         SELECT Fault
          ApRLock( 3 )         
         DELETE
         UNLOCK
      ENDIF
      UNLOCK
      IF LASTKEY() = 27
           mcontinue := "N"
       ENDIF  
      LOOP
   ENDDO

   RETURN NIL
   ****---- End of FaultDelete()

   ****----------------------------------------------------------------------

STATIC FUNCTION NameFault()

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      SELECT Name
      Namerank()
      IF PressedEsc()
         RETURN NIL
      ENDIF
      mcodeno := Name->Codeno
      aPart_:={}
      SCROLL()
      SELECT Fault
      GOTO TOP
      IF LASTREC() != 0
         DO WHILE Fault->( !EOF() )
            AADD( aPart_, ( Fault->ChasMech+" "+Fault->Brand;
                +" "+Fault->Model+" "+Fault->PartNum;
                +"          "+STR( RECNO(),6 ) ) )
            SKIP ALIAS Fault
         ENDDO
      ENDIF   // LastRec
      DISPBOX(  0, 0, 24,79, 2 )
      IF !EMPTY( aPart_ )
         anum := ACHOICE( 1, 2, 23,77,aPart_,,"AFUNC" )
         mpartdes := aPart_[anum]
         nrecno:= VAL( RIGHT( mpartdes,6 ) )
         GOTO nrecno
         mpartnum := Fault->Partnum
      ENDIF
      SCROLL(   3, 0, 24,80 )
      DISPBOX( 10, 5, 18,75, 2 )
      @ 15, 8      SAY Name->Name+"  "+Name->Codeno COLOR "BG+"
      mwhere := "S"
      npl    := 54

       Printsel()                                  // _LF_Init

      IF mwhere == "P"
         SET MARGIN TO 2
         npl := 56
      ELSE
         npl := 18
      ENDIF
      SCROLL()
      nl := 0
      @ nl, 0 SAY Control->U_Name
      nl++
      @ nl,38 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
                   +STR(YEAR(DATE()),5)
      nl+=2
      SELECT Name
      @ nl, 0 SAY Name->Name
      nl++
      IF Name->Add1 <> "     "
         @ nl, 0 SAY Name->Add1
         nl++
      ENDIF
      IF Name->Add2 <> "     "
         @ nl, 0 SAY Name->Add2
         nl++
      ENDIF
      IF Name->Add3 <> "     "
         @ nl, 0 SAY Name->Add3
         nl++
      ENDIF
      nl++
      IF Name->Add4 <> "     "
         @ nl, 0 SAY Name->Add4
         nl++
      ENDIF
      IF Name->Add5 <> "     "
         @ nl, 0 SAY Name->Add5
         nl++
      ENDIF
      IF Name->Phone <> "        "
         @ nl, 0 SAY "Priv Ph "+Name->Ephone
         @ nl,23 SAY "Bus Ph  "+Name->Phone
         nl++
      ENDIF
      nl++
      @ nl, 0 SAY Control->U_Name
      nl+=2
      SELECT Fault
      GOTO TOP
      SEEK mpartnum
      @ nl, 0 SAY TRIM( Fault->ChasMech )+" "+TRIM( Fault->Brand );
         +" "+TRIM( Fault->Model );
         +" "+TRIM( Fault->Partnum )+" "+Fault->Area
      nl+=2
      DO WHILE Fault->Partnum = mpartnum .AND. Fault->( !EOF() )
         IF nl > npl
            nl := 2
            IF mwhere == "P"
               EJECT
               @  0, 0 SAY Control->U_Name
               @  0,38 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                         +STR( YEAR(DATE() ),5 )
            ELSE
               WAIT
               SCROLL()
            ENDIF
         ENDIF
         @ nl, 2 SAY Fault->Partnum+"  "+Fault->Area+" "+DTOC( Fault->Ddate )
         nl+=2
         @ nl, 2 SAY Fault->ChasMech+" "+TRIM( Fault->Brand )+" "+Fault->Model
         nl+=2
         @ nl, 0 SAY Fault->Symptom
         nl++
         IF Fault->Fix1 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix1
            nl++
         ENDIF
         IF Fault->Fix2 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix2
            nl++
         ENDIF
         IF Fault->Fix3 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix3
            nl++
         ENDIF
         IF Fault->Fix4 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix4
            nl++
         ENDIF
         IF Fault->Fix5 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix5
            nl++
         ENDIF
         IF Fault->Fix6 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix6
            nl++
         ENDIF
         IF Fault->Fix7 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix7
            nl++
         ENDIF
         IF Fault->Fix8 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix8
            nl++
         ENDIF
         nl++
         coderef := Fault->FltRecno
         SELECT Cusnotes
         cdetail := ""
         SEEK coderef
         IF FOUND()   
             GetDets( coderef )                           // XF_Memo2
             FormP( cdetail,60,10 )                       // XF_Memo2
         ENDIF
         nl++
         SELECT Fault
         SKIP ALIAS Fault
      ENDDO                           // Fault
      IF mwhere != "P"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
      ELSE
         EndPrint()
         SET MARGIN TO 0
      ENDIF
      mcontinue := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO

   RETURN NIL
   ***** End of NameFault()

   *****--------------------------------------------------------------------

STATIC FUNCTION PartFault()

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"

            SCROLL()
            aPart_:={}
            mpartnum := SPACE( 20 )
            SELECT Fault
            GOTO TOP
            IF LASTREC() != 0
               DO WHILE Fault->( !EOF() )
                  AADD( aPart_, ( Fault->ChasMech+" "+Fault->Brand;
                      +" "+Fault->Model+" "+Fault->Partnum;
                      +"          "+STR( RECNO(),6 ) ) )
                  SKIP ALIAS Fault
               ENDDO
             ENDIF   // LastRec
        DISPBOX(  0, 0, 24,79, 2 )
        IF !EMPTY( aPart_ )
           anum := ACHOICE( 1, 2, 23,77,aPart_,,"AFUNC" )
           mpartdes := aPart_[anum]
           nrecno:= VAL( RIGHT( mpartdes,6 ) )
           GOTO nrecno
           mpartnum := Fault->Partnum
        ENDIF
      SCROLL(   3, 0, 24,80 )
      DISPBOX( 10, 5, 18,75, 2 )
      mwhere := "S"
      npl    := 54

       Printsel()                                  // _LF_Init

      IF mwhere == "P"
          SET MARGIN TO 2
          npl := 56
       ELSE
         npl := 18
      ENDIF
      SCROLL()
      nl := 0
      @ nl, 0 SAY Control->U_Name
      @ nl,38 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
                   +STR(YEAR(DATE()),5)
      nl+=2
      SELECT Fault
      GOTO TOP
      SEEK mpartnum
      @ nl, 0 SAY TRIM( Fault->ChasMech )+" "+TRIM( Fault->Brand );
                 +" "+TRIM( Fault->Model );
                 +" "+TRIM( Fault->Partnum )+" "+DTOC( Fault->Ddate )
      nl+=2
      DO WHILE Fault->Partnum = mpartnum .AND. Fault->( !EOF() )
          IF nl > npl
            nl := 2
            IF mwhere == "P"
               EJECT
               @  0, 0 SAY Control->U_Name
               @  0,38 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                         +STR( YEAR(DATE() ),5 )
             ELSE
               WAIT
               SCROLL()
            ENDIF
         ENDIF
         @ nl, 2 SAY Fault->Partnum+"  "+Fault->Area+" "+DTOC( Fault->Ddate )
         nl+=2
         @ nl, 2 SAY Fault->ChasMech+" "+TRIM( Fault->Brand )+" "+Fault->Model
         nl+=2
         @ nl, 0 SAY Fault->Symptom
         nl++
         IF Fault->Fix1 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix1
            nl++
         ENDIF
         IF Fault->Fix2 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix2
            nl++
         ENDIF
         IF Fault->Fix3 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix3
            nl++
         ENDIF
         IF Fault->Fix4 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix4
            nl++
         ENDIF
         IF Fault->Fix5 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix5
            nl++
         ENDIF
         IF Fault->Fix6 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix6
            nl++
         ENDIF
         IF Fault->Fix7 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix7
            nl++
         ENDIF
         IF Fault->Fix8 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix8
            nl++
         ENDIF
         nl++
         coderef := Fault->FltRecno
         SELECT Cusnotes
         cdetail := ""
         SEEK coderef
         IF FOUND()   
             GetDets( coderef )                           // XF_Memo2
             FormP( cdetail,60,10 )                       // XF_Memo2
         ENDIF
         nl++
         SELECT Fault
         SKIP ALIAS Fault
      ENDDO                           // Fault
      IF mwhere != "P"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
      ENDIF
      mcontinue := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO

   RETURN NIL
   ***** End of PartFault()

   *****-------------------------------------------------------------

FUNCTION FaultGet()   

   mcorrect := "N"
   DO WHILE mcorrect == "N"
         SCROLL()  
         DISPBOX( 0, 1, 24,79, 2 )
         SELECT Fault
         mpartnum  := Fault->Partnum
         mBrand    := Fault->Brand
         mModel    := Fault->Model
         mChasMech := Fault->ChasMech
         mDdate    := DATE()
         @  2, 3      SAY "First 2 Char important"
         @  2,COL()+2 GET mpartnum  PICTURE "@!"
         @  3, 3      SAY "Important Desc          "
         @  3,COL()+2 GET mbrand    PICTURE "@X"
         @  4, 3      GET mchasMech PICTURE "@X"
         @  4,COL()+2 GET mmodel    PICTURE "@X"
         @  4,COL()+2 GET mddate    PICTURE "99/99/9999"
          READ
          ApFLock( 3 )
         APPEND BLANK
         Fault->Codeno   := SUBSTR( Control->U_Name,1, 8 )
         Fault->Partnum  := mpartnum
         Fault->Brand    := mbrand
         Fault->ChasMech := mchasMech
         Fault->Model    := mmodel
         Fault->Ddate    := DATE()
         @  6, 3 GET Fault->Symptom  PICTURE "@X"
         @  7, 3 GET Fault->Fix1     PICTURE "@X"
         @  8, 3 GET Fault->Fix2     PICTURE "@X"
         @  9, 3 GET Fault->Fix3     PICTURE "@X"
         @ 10, 3 GET Fault->Fix4     PICTURE "@X"
         @ 11, 3 GET Fault->Fix5     PICTURE "@X"
         @ 12, 3 GET Fault->Fix6     PICTURE "@X"
         @ 13, 3 GET Fault->Fix7     PICTURE "@X"
         @ 14, 3 GET Fault->Fix8     PICTURE "@X"
          READ
         Fault->FltRecno := SUBSTR( Fault->Partnum, 1,16 )+STR( RECNO(),4 ) 
         UNLOCK
         coderef := Fault->FltRecno
          M2MemoFile( coderef )                 //  XF_Memo2
         mcorrect := "Y"      // ApGetY( Message->Correct )
   ENDDO

   RETURN NIL

   ***---- End of FaultGet()

   **-------------------------------------------------------------------

STATIC FUNCTION JCFault()

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
            SCROLL()
            DISPBOX( 0,50, 2,79, 2 )
            @  1,54 SAY "SELECT INVOICE" COLOR "RG+"
            mcodeno := SPACE( 8 )
      nrecno   := 0
      aPart_   := {}
      SELECT Debit
      mtempcode := "A       "
      GOTO TOP
      SEEK mtempcode
      IF !FOUND()
          ApFLock( 3 )
         APPEND BLANK
         Debit->Codeno := "A      " 
         UNLOCK
      ENDIF
      GOTO TOP
      IF LASTREC() != 0
         DO WHILE Debit->( !EOF() )
             IF Debit->Stat = "I"
                SKIP ALIAS Debit
                LOOP
             ENDIF
             IF Debit->Codeno = mcodeno
                SKIP ALIAS Debit
                LOOP
             ENDIF
             SELECT Name
             SEEK Debit->Codeno
             SELECT Debit
             mcodeno := Debit->Codeno
             AADD( aPart_,Name->Name+"  "+Debit->BranchId;
                 +"       "+STR( RECNO(),6 ) )
             SKIP ALIAS Debit
         ENDDO                          // EOF()
         DISPBOX( 0, 1, 24,40, 2 )
         IF !EMPTY( aPart_ )
            ASORT( aPart_,,,{ | x,y | x < y } )
            anum   := ACHOICE( 1, 3, 23,38, aPart_,,"AFUNC" )    
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            IF PressedEsc() 
               RETURN NIL
            ENDIF
            GOTO nrecno
            mcodeno := Debit->Codeno
         ENDIF
         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         SELECT Name
         SEEK mcodeno
         @  1,10 SAY Name->Name
      ENDIF                        // LastRec
            aPart_:={}
            SCROLL()
            SELECT Fault
            GOTO TOP
            IF LASTREC() != 0
               DO WHILE Fault->( !EOF() )
                  AADD( aPart_, ( Fault->ChasMech+" "+Fault->Brand;
                      +" "+Fault->Model+" "+Fault->Partnum;
                      +"          "+STR( RECNO(),6 ) ) )
                  SKIP ALIAS Fault
               ENDDO
             ENDIF   // LastRec
        DISPBOX(  0, 0, 24,79, 2 )
        IF !EMPTY( aPart_ )
           anum := ACHOICE( 1, 2, 23,77,aPart_,,"AFUNC" )
           mpartdes := aPart_[anum]
           nrecno:= VAL( RIGHT( mpartdes,6 ) )
           GOTO nrecno
        ENDIF
      SCROLL(   3, 0, 24,80 )
      DISPBOX( 10, 5, 18,75, 2 )
      SELECT Debit
      @ 11, 8      SAY "Instructions "+Debit->Fault
      @ 13,10      SAY "Invoice # "   +Debit->Invno
      @ 13,COL()+4 SAY "Date "        +DTOC( Debit->Dbdate )
      @ 13,COL()+4 SAY "Ordnum "      +Debit->Ordnum
      @ 15, 8      SAY Name->Name+"  "+Name->Codeno COLOR "BG+"

      mwhere := "S"
      npl    := 54

       Printsel()                                  // _LF_Init

      IF mwhere == "P"
         SET MARGIN TO 2
         npl := 56
       ELSE
         npl := 18
      ENDIF
      SCROLL()
      nl := 0
      @ nl, 0 SAY Control->U_Name
      @ nl,46 SAY "J/S"+" # "+Debit->Invno
      nl++
      @ nl,58 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
                   +STR(YEAR(DATE()),5)
      nl+=2
      SELECT Name
      @ nl, 0 SAY Name->Name
      nl++
      @ nl, 0 SAY "CUSTOMER NAME : "+TRIM(Name->Title);
                             +" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
      nl++
      @ nl, 0 SAY Name->Add1
      nl++
      @ nl, 0 SAY Name->Add2
      nl++
      IF Name->Add3 <> "     "
         @ nl, 0 SAY Name->Add3
      ENDIF
      nl++
      @ nl, 0 SAY Name->Add4+"   Priv Ph "+Name->Ephone
      IF Name->Phone <> "        "
         nl++
         @ nl,23 SAY "Bus Ph  "+Name->Phone
         nl++
      ENDIF
      @ nl, 0 SAY Name->Add5
      nl++
      @ nl, 0 SAY "Message     "+Debit->Message
      nl++
      @ nl, 0 SAY "Information "+Debit->Fault+"  "+Debit->Invno
      nl+=2
      mpartnum := Fault->Partnum     // SUBSTR( Part->Partnum, 1,16 )
      SELECT Fault
      GOTO TOP
      SEEK mpartnum
      @ nl, 0 SAY TRIM( Fault->Partnum )+" "+TRIM( Fault->Brand );
                 +" "+TRIM( Fault->Model );
                 +" "+TRIM( Fault->ChasMech )+" "+DTOC( Fault->Ddate )
      nl+=2
      DO WHILE Fault->Partnum = mpartnum .AND. Fault->( !EOF() )
          IF nl > npl
            nl := 2
            IF mwhere == "P"
               EJECT
               @  0, 0 SAY Control->U_Name
               @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                         +STR( YEAR(DATE() ),5 )
             ELSE
               WAIT
               SCROLL()
            ENDIF
         ENDIF
         @ nl, 2 SAY Fault->Partnum+"  "+Fault->Area+" "+DTOC( Fault->Ddate )
         nl+=2
         @ nl, 2 SAY Fault->ChasMech+" "+Fault->Brand+" "+Fault->Model;
                 + "  "+DTOC( Fault->Ddate )
         nl+=2
         @ nl, 0 SAY Fault->Symptom
         nl++
         IF Fault->Fix1 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix1
            nl++
         ENDIF
         IF Fault->Fix2 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix2
            nl++
         ENDIF
         IF Fault->Fix3 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix3
            nl++
         ENDIF
         IF Fault->Fix4 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix4
            nl++
         ENDIF
         IF Fault->Fix5 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix5
            nl++
         ENDIF
         IF Fault->Fix6 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix6
            nl++
         ENDIF
         IF Fault->Fix7 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix7
            nl++
         ENDIF
         IF Fault->Fix8 != SPACE( 65 )
            @ nl, 0 SAY Fault->Fix8
            nl++
         ENDIF
         nl++
         coderef := Fault->FltRecno
         SELECT Cusnotes
         cdetail := ""
         SEEK coderef
         IF FOUND()   
             GetDets( coderef )                           // XF_Memo2
             FormP( cdetail,60,10 )                       // XF_Memo2
         ENDIF
         nl++
         SELECT Fault
         SKIP ALIAS Fault
      ENDDO                           // Fault
      IF mwhere != "P"
         mok := "N"
         DO WHILE mok = "N"
            mok := ApReadN()
         ENDDO
       ELSE
         EndPrint()
         SET MARGIN TO 0
      ENDIF
      mcontinue := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO

   RETURN NIL
   ***** End of JCFault()

   ***-----------------------------------------------------------------

FUNCTION OperateGet()

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"  
         SCROLL()
         DISPBOX( 0, 0,24,79, 2 )
         @ 0, 8 SAY "  Viewing Operations  PartOper.DBF " COLOR "BG+"
         nl := 2
         mpartnum := Fault->Partnum
         SELECT PartOper
         SET ORDER TO 1         // Partnum
         GOTO TOP
         SEEK mpartnum 
         IF FOUND()
            DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() )
               IF PartOper->FltRecno != Fault->FltRecno
                   SKIP ALIAS PartOper
                   LOOP
               ENDIF
               @ nl, 5 SAY PartOper->Desc+" "+PartOper->Drawno 
               nl++
               IF nl >= 22
                  WAIT  // INKEY()
                  SCROLL()
                  DISPBOX( 0, 0,24,79, 2 )
                  @ 0, 8 SAY "  Viewing Drawings " COLOR "BG+"
                  nl := 1
                ENDIF 
                SKIP ALIAS PartOper
             ENDDO                        // PartOper EOF
         ENDIF                            // Found
         SCROLL( 19, 0, 24,80 )
         DISPBOX( 19, 0, 24,79, 2 )
         @ 20, 6 SAY mpartnum COLOR "BG+"
         nselect := 1
         @ 22, 5      PROMPT "1. Exit"
         @ 22,COL()+2 PROMPT "2. Add"
         @ 22,COL()+2 PROMPT "3. Edit/Delete"
         @ 22,COL()+2 PROMPT "4. Operate Menu"
         @ 22,COL()+2 PROMPT "5. Drawing"

         MENU TO nselect
         DO CASE
            CASE nselect == 1 .OR. PressedEsc()
                RETURN NIL
            CASE nselect == 2                 // Add Operation   

         manother := "Y"
         DO WHILE manother = "Y"
            coperno := SPACE ( 8 )
            GroupSelect( @coperno )          // XLF_QU9.Prg
      SCROLL()
      aPart_:={}
      nrecno := 0
      ncount := 0
      SELECT Operate
      GOTO TOP
      DO WHILE Operate->( !EOF() )
         IF coperno != "XX      "
            IF Operate->Operno != coperno
               SKIP ALIAS Operate
               LOOP
            ENDIF
         ENDIF
         ncount++  
         AADD( aPart_,Operate->Priority;
                      +" "+Operate->Desc;
                      +" "+Operate->Order;
                      +" "+Operate->ABC;
                      +" "+Operate->Print;
                      +" "+Operate->Ckey;
                      +"                       "+STR( RECNO(),6 ) )
         SKIP ALIAS Operate
      ENDDO                        // Operate EOF
      IF ncount <= 1
         aPart_:={}
         SELECT Operate
         GOTO TOP
         DO WHILE Operate->( !EOF() )
            AADD( aPart_,Operate->Priority;
                         +" "+Operate->Desc;
                         +" "+Operate->Order;
                         +" "+Operate->ABC;
                         +" "+Operate->Print;
                         +" "+Operate->Ckey;
                         +"                       "+STR( RECNO(),6 ) )
            SKIP ALIAS Operate
         ENDDO                        // Operate EOF
      ENDIF                        // ncount 
      DISPBOX( 0, 0, 2,79, 2 )
      @ 1, 8 SAY "Viewing Part Operate "+coperno COLOR "BG+"
      @ 1,50 SAY ncount PICTURE "999"            COLOR "BG+"
      IF !EMPTY( aPart_ )
         DISPBOX( 3, 0,24,79, 2 )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE(  4, 4, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         SCROLL(  13, 0, 24,80 )
         DISPBOX( 13, 0, 20,79, 2 )
         @ 14, 5      SAY Operate->Operno        COLOR "BG+" 
         @ 14,COL()+2 SAY Operate->Desc          COLOR "BG+"
         coperno := Operate->Operno 
         IF PressedEsc()
            RETURN NIL
         ENDIF
   ENDIF               // Empty
            SELECT PartOper
             ApFlock( 3 )
            APPEND BLANK
            PartOper->Partnum   := Fault->Partnum
            PartOper->Operno    := "Operate"
            PartOper->Adminno   := Operate->Operno
            PartOper->Desc      := Operate->Desc
            PartOper->Date      := DATE()
            PartOper->Order     := "OP"
            PartOper->FltRecno  := Fault->FltRecno
            @ 16, 5 SAY "Information " GET PartOper->Desc
            @ 17,18 GET PartOper->Desc1
            @ 18,18 GET PartOper->Desc2
             READ
            UNLOCK
            IF PressedEsc()
               RETURN NIL
            ENDIF
            manother := ApGetY( "Another Operation" )
            IF PressedEsc()
               RETURN NIL
            ENDIF
            LOOP 
   ENDDO
         LOOP

         CASE nselect == 3                 // Edit-Delete Process
      ***         manother := "Y"
      ***         DO WHILE manother = "Y"
                mpartnum := Fault->Partnum  
                SELECT PartOper
      ***             SET ORDER TO 1         // Partnum
                GOTO TOP
                SEEK mpartnum 
      IF LASTREC() != 0
                aPart_:={}
                nrecno  := 0
      DO WHILE PartOper->Partnum = mpartnum .AND. PartOper->( !EOF() )
              IF PartOper->FltRecno != Fault->FltRecno
                  SKIP ALIAS PartOper
                  LOOP
              ENDIF
         AADD( aPart_,PartOper->Desc;
                      +" "+PartOper->Operno;
                      +" "+PartOper->Drawno;
                      +"                      "+STR( RECNO(),6 ) )
         SKIP ALIAS PartOper
      ENDDO                        // PartOper EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         SCROLL(  0, 0, 24,80 )
         DISPBOX( 0, 0, 24,79, 2 )
         anum := ACHOICE(  1, 3, 23,78, aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         SCROLL(  11, 0, 24,80 )
         DISPBOX( 11, 0, 18,79, 2 )
         nl := 13
         @ nl,18 SAY PartOper->Desc+"  "+PartOper->Partnum 
         nl++
          ApFLock( 3 )
         @ nl, 5 SAY "Information " GET PartOper->Desc
         nl++
         @ nl,18 GET PartOper->Desc1
         nl++
         @ nl,18 GET PartOper->Desc2
          READ
         UNLOCK
         IF PressedEsc()
            RETURN NIL
         ENDIF
         SELECT PartOper
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
       ENDIF // not 0
       LOOP
        CASE nselect == 4
           JobOperate()
          LOOP
        CASE nselect == 5
           FaultDraw()
          LOOP
     ENDCASE 

   ENDDO       // mcontinue

   RETURN NIL

   ***---------------  End OperateGet()

   **********----------------   END OF FILE XF_FAULT.PRG
