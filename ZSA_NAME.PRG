   *** JK  27-05-11 05:34:49 

/*
   Program.....:            ZSA_Name.PRG
   Authors.....: J.Kirby
   Date........: 17/10/2005
   Functions...: PartNote, NameSuppl, PartAction, NameAction
   Static funcs: Special, NameGroup, NameHist
   Not used....: NameVisit
*/

// (c) Copyright 1993 by Kirby Christchurch.

FUNCTION PartNote()

   SCROLL() 
   SELECT Note
   nl := 1
   @  nl, 3 SAY Note->Note
   nl++
   @  nl, 3 SAY Note->General
   nl++
   @  nl,12 SAY Note->Note1
   nl++ 
   @  nl,12 SAY Note->Note2
   nl++ 
   @  nl,12 SAY Note->Note3
   nl++ 
   @  nl,12 SAY Note->Note4
   nl++ 
   @  nl,12 SAY Note->Note5
   nl++ 
   @  nl,12 SAY Note->Note6
   nl++ 
   @  nl,12 SAY Note->Note7
   nl++ 
   @  nl,12 SAY Note->Note8
   nl++ 
   @  nl,12 SAY Note->Note9
   nl++ 
   @  nl,12 SAY Note->Note10 COLOR "RG+"
   nl++ 
   @  nl,12 SAY Note->Note11 COLOR "RG+"
   nl++ 
   @  nl,12 SAY Note->Note12 COLOR "RG+"
   nl++
   @  nl,12 SAY Note->Note13 COLOR "RG+"
   nl++
   @  nl,12 SAY Note->Note14 COLOR "RG+"
   nl++
   @  nl,12 SAY Note->Note15 COLOR "RG+"
   nl++
   @  nl,12 SAY Note->Note16
   nl++
   @  nl,12 SAY Note->Note17
   nl++
   @  nl,12 SAY Note->Note18
   nl++
   @  nl,12 SAY Note->Nameno PICTURE "99" 
   @  nl,20 SAY Note->Cardno PICTURE "9999"
   @  nl,30 SAY Note->Noteno PICTURE "9999"
   cedit := ApGetN( "Edit the Notes" )
   IF cedit = "Y"
      SELECT Note
       ApFLock( 3 )
      nl := 1
      @  nl, 3 GET Note->Note
      nl++
      @  nl,52 GET Note->General
      nl++
      @  nl,52 GET Note->Note1
      nl++ 
      @  nl,52 GET Note->Note2
      nl++ 
      @  nl,52 GET Note->Note3
      nl++ 
      @  nl,52 GET Note->Note4
      nl++ 
      @  nl,52 GET Note->Note5
      nl++ 
      @  nl,52 GET Note->Note6
      nl++ 
      @  nl,52 GET Note->Note7
      nl++ 
      @  nl,52 GET Note->Note8
      nl++ 
      @  nl,52 GET Note->Note9
      nl++ 
      @  nl,52 GET Note->Note10
      nl++ 
      @  nl,52 GET Note->Note11
      nl++ 
      @  nl,52 GET Note->Note12
      nl++
      @  nl,52 GET Note->Note13
      nl++
      @  nl,52 GET Note->Note14
      nl++
      @  nl,52 GET Note->Note15
      nl++
      @  nl,52 GET Note->Note16
      nl++
      @  nl,52 GET Note->Note17
      nl++
      @  nl,52 GET Note->Note18
      nl++
      @  nl,12 GET Note->Nameno PICTURE "99"
      @  nl,20 GET Note->Cardno PICTURE "9999" 
      @  nl,30 GET Note->Noteno PICTURE "9999" 
       READ
      UNLOCK  
   ENDIF
   cedit := ApGetN( "Edit the Selections" )
   IF cedit = "Y"
      SCROLL()
      @  1,10 SAY "Select Function - Menu Required" COLOR "RG+"
      nl := 3
      @  nl,50 SAY Note->Select1+"   "+Note->SelDesc1
      nl++ 
      @  nl,50 SAY Note->Select2+"   "+Note->SelDesc2
      nl++ 
      @  nl,50 SAY Note->Select3+"   "+Note->SelDesc3
      nl++ 
      @  nl,50 SAY Note->Select4+"   "+Note->SelDesc4
      nl++ 
      @  nl,50 SAY Note->Select5+"   "+Note->SelDesc5
      nl++ 
      @  nl,50 SAY Note->Select6+"   "+Note->SelDesc6
      nl++ 
      @  nl,50 SAY Note->Select7+"   "+Note->SelDesc7
      nl++ 
      @  nl,50 SAY Note->Select8+"   "+Note->SelDesc8
      nl++ 
      @  nl,50 SAY Note->Select9+"   "+Note->SelDesc9
      nl++
      @  nl,50 SAY Note->Select10+"   "+Note->SelDesc10
      nl++ 
      @  nl,50 SAY Note->Select11+"   "+Note->SelDesc11
      nl++ 
      @  nl,50 SAY Note->Select12+"   "+Note->SelDesc12
      nl++
      @  nl,50 SAY Note->Select13+"   "+Note->SelDesc13
      nl++ 
      @  nl,50 SAY Note->Select14+"   "+Note->SelDesc14
      nl++ 
      @  nl,50 SAY Note->Select15+"   "+Note->SelDesc15
      nl++
      @  nl,50 SAY Note->Select16+"   "+Note->SelDesc16
      nl++ 
      @  nl,50 SAY Note->Select17+"   "+Note->SelDesc17
      nl++
      @  nl,50 SAY Note->Select18+"   "+Note->SelDesc18

      SELECT Note
       ApFLock( 3 )
      nl := 3  
      @  nl, 5 SAY "Select  1" GET Note->Select1 PICTURE "!" VALID( Note->Select1 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc1
      nl++ 
      @  nl, 5 SAY "Select  2" GET Note->Select2 PICTURE "!" VALID( Note->Select2 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc2
      nl++ 
      @  nl, 5 SAY "Select  3" GET Note->Select3 PICTURE "!" VALID( Note->Select3 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc3
      nl++ 
      @  nl, 5 SAY "Select  4" GET Note->Select4 PICTURE "!" VALID( Note->Select4 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc4
      nl++ 
      @  nl, 5 SAY "Select  5" GET Note->Select5 PICTURE "!" VALID( Note->Select5 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc5
      nl++ 
      @  nl, 5 SAY "Select  6" GET Note->Select6 PICTURE "!" VALID( Note->Select6 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc6
      nl++ 
      @  nl, 5 SAY "Select  7" GET Note->Select7 PICTURE "!" VALID( Note->Select7 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc7
      nl++ 
      @  nl, 5 SAY "Select  8" GET Note->Select8 PICTURE "!" VALID( Note->Select8 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc8
      nl++ 
      @  nl, 5 SAY "Select  9" GET Note->Select9 PICTURE "!" VALID( Note->Select9 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc9
      nl++
      @  nl, 5 SAY "Select 10" GET Note->Select10 PICTURE "!" VALID( Note->Select10 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc10
      nl++ 
      @  nl, 5 SAY "Select 11" GET Note->Select11 PICTURE "!" VALID( Note->Select11 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc11
      nl++ 
      @  nl, 5 SAY "Select 12" GET Note->Select12 PICTURE "!" VALID( Note->Select12 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc12
      nl++ 
      @  nl, 5 SAY "Select 13" GET Note->Select13 PICTURE "!" VALID( Note->Select13 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc13
      nl++ 
      @  nl, 5 SAY "Select 14" GET Note->Select14 PICTURE "!" VALID( Note->Select14 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc14
      nl++ 
      @  nl, 5 SAY "Select 15" GET Note->Select15 PICTURE "!" VALID( Note->Select15 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc15
      nl++ 
      @  nl, 5 SAY "Select 16" GET Note->Select16 PICTURE "!" VALID( Note->Select16 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc16
      nl++ 
      @  nl, 5 SAY "Select 17" GET Note->Select17 PICTURE "!" VALID( Note->Select17 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc17
      nl++ 
      @  nl, 5 SAY "Select 18" GET Note->Select18 PICTURE "!" VALID( Note->Select18 $"YN" )
      @  nl,COL()+2           GET Note->SelDesc18
       READ
      UNLOCK
   ENDIF                       // cedit
   RETURN NIL

   **** End of PartNote

   **-------------------------------------------------------------------

FUNCTION NameSuppl()

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      SCROLL()
      DISPBOX( 0, 1,  2,79, 2 )
      @  1, 7 SAY Name->Codeno+"  "+Name->Name
      SELECT Rept
      SET ORDER TO 2                       // Codeno      Recno+Stat
      GO TOP
      aPart_:={}
      IF LASTREC() != 0
         SEEK mcodeno
         DO WHILE Rept->Codeno = mcodeno .AND. Rept->( !EOF() )
            AADD( aPart_,Rept->Stat;
               +" "+Rept->SuppId;
               +" "+SUBSTR( Rept->Info, 1,31 );
               +" "+Rept->Out+" "+DTOC( Rept->Date );
               +"     "+STR( RECNO(),6 ) )
            SKIP ALIAS Rept
         ENDDO                         // Rept Partnum
         ASORT(aPart_,,,{ | x,y | x < y })
         SCROLL(  3, 0, 24,80 )
         DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            anum := ACHOICE( 4, 3, 23,78, aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            GOTO nrecno
            SCROLL(  11, 0, 24,80 )
            DISPBOX( 11, 1, 19,79, 2 )
            @ 12, 7      SAY Rept->Suppid  PICTURE "@X"
            @ 12,COL()+2 SAY Rept->Stat    PICTURE "@X"
            @ 12,COL()+2 SAY Rept->Date    PICTURE "99/99/9999"
            @ 12,COL()+2 SAY Rept->Out     PICTURE "@X"
            @ 13, 7      SAY Rept->Info    PICTURE "@X" COLOR "BG+"
            @ 14, 7      SAY Rept->Info1   PICTURE "@X"
            @ 15, 7      SAY Rept->Info2   PICTURE "@X"
            @ 16, 7      SAY Rept->Info3   PICTURE "@X"
            @ 17, 7      SAY Rept->Info4   PICTURE "@X"
            @ 18, 7      SAY Rept->Info5   PICTURE "@X"
         ENDIF                             // !EMPTY
      ENDIF                                    // LastRec()
      SCROLL(  20, 0, 24,80 )
      DISPBOX( 20, 1, 24,79, 2 )
      nselect := 1
      @ 20,12 SAY "  --- Reports --- "
      @ 21, 4      PROMPT "V "
      @ 21,COL()+2 PROMPT "1. Add New Report"
      @ 21,COL()+2 PROMPT "2. Edit Report"
      @ 21,COL()+2 PROMPT "3. Print Report"
      @ 21,COL()+2 PROMPT "4. Delete Report"
      @ 23, 8      PROMPT "5. Print by Group"
      @ 23,COL()+2 PROMPT "6. Memo"
      @ 23,COL()+2 PROMPT "7. Special"

      MENU TO nselect
      DO CASE
         CASE PressedEsc()
            RETURN NIL
         CASE nselect == 1                         // Add New
            LOOP
         CASE nselect == 2                         // Add New
            SCROLL()
            DISPBOX( 0, 1,  2,79, 2 )
            @  1, 7 SAY Name->Codeno+"  "+Name->Name
            DISPBOX( 3, 1, 24,79, 2 )
            mcodeno  := Name->Codeno
            mout     := SPACE( 4 )
            mstat    := SPACE( 6 )
            minfo    := SPACE( 40 )
            minfo1   := SPACE( 50 )
            minfo2   := SPACE( 50 )
            minfo3   := SPACE( 50 )
            minfo4   := SPACE( 50 )
            minfo5   := SPACE( 50 )
            msuppid  := SPACE( 20 )
            ddate    := DATE()
            mcorrect := "N"
            DO WHILE mcorrect == "N"
               @  5,18      SAY "Date :"      GET ddate    PICTURE "99/99/9999"
               @  7, 7      SAY "Details" GET msuppid  PICTURE "@X"
               @  7,COL()+2 SAY "Refer"       GET mstat    PICTURE "@!"
               @  7,COL()+2 SAY "Initials"    GET mout     PICTURE "@!"
               @ 10, 7      SAY "Information" GET minfo    PICTURE "@X"
               @ 11,19                        GET minfo1   PICTURE "@X"
               @ 12,19                        GET minfo2   PICTURE "@X"
               @ 13,19                        GET minfo3   PICTURE "@X"
               @ 14,19                        GET minfo4   PICTURE "@X"
               @ 15,19                        GET minfo5   PICTURE "@X"
                READ
               SELECT Rept
                ApFLock( 3 ) 
               APPEND BLANK
               Rept->Codeno    := mcodeno
               Rept->Out       := mout 
               Rept->Stat      := mstat
               Rept->Info      := minfo
               Rept->Info1     := minfo1
               Rept->Info2     := minfo2
               Rept->Info3     := minfo3
               Rept->Info4     := minfo4
               Rept->Info5     := minfo5
               Rept->SuppId    := msuppid
               Rept->Codeno    := mcodeno
               Rept->Date      := ddate
               Rept->CodeRecno := mcodeno+mstat+STR( RECNO(), 4 )
               UNLOCK
               ccoderecno := Rept->CodeRecno
               mcorrect := "Y"
            ENDDO                                 // mcorrect
         CASE nselect = 3
            SCROLL()
            DISPBOX( 0, 1,  2,79, 2 )
            @  1, 7 SAY Name->Codeno+"  "+Name->Name
            DISPBOX( 3, 1, 19,79, 2 )
            SELECT Rept
            mcodeno    := Name->Codeno
            mout       := Rept->Out
            mstat      := Rept->Stat
            minfo      := Rept->Info
            minfo1     := Rept->Info1
            minfo2     := Rept->Info2
            minfo3     := Rept->Info3
            minfo4     := Rept->Info4
            minfo5     := Rept->Info5
            msuppid    := Rept->Suppid
            ddate      := Rept->Date
            ccoderecno := Rept->CodeRecno
            mcorrect := "N"
            DO WHILE mcorrect == "N"
               @  5,18      SAY "Date :"      GET ddate    PICTURE "99/99/9999"
               @  7, 7      SAY "Details"     GET msuppid  PICTURE "@X"
               @  7,COL()+2 SAY "Refer"       GET mstat    PICTURE "@!"
               @  7,COL()+2 SAY "Initials"    GET mout     PICTURE "@!"
               ***           @ 10,20      SAY "---27 Char for End menu----!" 
               @ 10, 7      SAY "Information" GET minfo    PICTURE "@X"
               @ 11,19                        GET minfo1   PICTURE "@X"
               @ 12,19                        GET minfo2   PICTURE "@X"
               @ 13,19                        GET minfo3   PICTURE "@X"
               @ 14,19                        GET minfo4   PICTURE "@X"
               @ 15,19                        GET minfo5   PICTURE "@X"
               @ 17,19      SAY ccoderecno 
                READ
               SELECT Rept
                ApFLock( 3 ) 
               Rept->Out     := mout 
               Rept->Stat    := mstat
               Rept->Info    := minfo
               Rept->Info1   := minfo1
               Rept->Info2   := minfo2
               Rept->Info3   := minfo3
               Rept->Info4   := minfo4
               Rept->Info5   := minfo5
               Rept->SuppId  := msuppid
               Rept->Codeno  := mcodeno
               Rept->Date    := ddate
               Rept->CodeRecno := mcodeno+mstat+STR( RECNO(), 4 )
               UNLOCK
               mcorrect := ApGetY( Message->Correct )
            ENDDO                                      // mcorrect
         CASE nselect == 4
             NameHist()                               // Below
         CASE nselect == 5
            SCROLL(  20, 0, 24,80 )
            mdelete := ApGetN( TRIM( Message->Delete )+" Report " )
            IF mdelete = "Y"
               SELECT Rept
               ApRLock( 3 ) 
               DELETE 
               UNLOCK           
            ENDIF                                      // mdelete
         CASE nselect == 6
            NameGroup()                              // Below
         CASE nselect == 7
            mok := ApGetN( "Do you want Special Memo" )
            IF mok = "Y"
               coderef := Name->Codeno
            ELSE
               IF Name->PayRef = "          "
                  SELECT Name
                   ApRLock( 3 )
                  Name->PayRef := "GEN"+TRIM( Name->Codeno )+STR( Recno(),4 )
                  UNLOCK
               ENDIF 
               coderef := Name->Payref
            ENDIF
            SCROLL(  16, 0, 24,80 )

            M2Memofile( coderef )                     // XF_Memo2
         CASE nselect == 8
            Special()                                // Above
         LOOP
      ENDCASE                                        // Supplier End Case 
      LOOP
   ENDDO                        // mcontinue
   RETURN NIL

   ***----- End NameSuppl()

   **---------------------------------------------------------------------*

STATIC FUNCTION Special()                // Lists by Rept within Rept

   SELECT Rept
   SET ORDER TO 2               // Codeno
   GOTO TOP
          ntotal:= nqtotal := 0
          mcontact := Name->Contact
          mdesc    := Name->Desc
          mdesc1   := Name->Desc1
          mdesc2   := Name->Desc2
          mdesc3   := Name->Desc3
          SCROLL(  16, 0, 24,80 )
          DISPBOX( 16, 1, 24,79, 2 )
          SELECT Name
          nl := 17
          @ nl,10 SAY "  Reference" GET mcontact PICTURE "@X"
          nl++
          @ nl,10 SAY "Description" GET mdesc    PICTURE "@X"
          nl++
          @ nl,22                   GET mdesc1   PICTURE "@X"
          nl++
          @ nl,22                   GET mdesc2   PICTURE "@X"
          nl++
          @ nl,22                   GET mdesc3   PICTURE "@X"
           READ
          SELECT Name
           ApRLock( 3 )
          Name->Contact := mcontact
          Name->Desc    := mdesc
          Name->Desc1   := mdesc1
          Name->Desc2   := mdesc2
          Name->Desc3   := mdesc3
          UNLOCK
          coderef := Name->PayRef
   ***          SCROLL(  16, 0, 24,80 )

             M2Memofile( coderef )                     // XF_Memo2

         nl := 0
         mwhere := "S"
         npl    := 54

          Printsel( mwhere, npl ) 

         @  nl, 4 SAY Control->U_Name
         @  nl,52 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                     +STR( YEAR(DATE() ),5 )
      mtitle := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
      nl+=2
      @ nl, 4 SAY Name->Name
      nl++
      IF Name->Add1 != "   "
         @ nl, 4 SAY Name->Add1
         nl++
      ENDIF 
      IF Name->Add2 != "   "
         @ nl, 4 SAY Name->Add2
         nl++
      ENDIF
      IF Name->Add3 != "   "
         @ nl, 4 SAY Name->Add3
         nl++
      ENDIF
      IF Name->Add4 != "   "
         @ nl, 4 SAY Name->Add4+" "+Name->Zip
         nl++
      ENDIF
      IF Name->Add5 != "   "
         @ nl, 4 SAY Name->Add5
         nl++
      ENDIF
      @ nl, 4 SAY Name->Phone+"  "+Name->BPhone+"   "+Name->Sale
      nl++
      @ nl, 4 SAY Name->EPhone+"  "+Name->MobPhone+"  "+Name->OthPhone
      nl++
      @ nl, 4 SAY mtitle
      @ nl,40 SAY Name->EMail
      nl+=2
      IF Name->Contact != SPACE( 30 )
         @ nl, 4 SAY Name->Contact
         nl++
      ENDIF
      IF Name->Desc  != SPACE( 50 )
         @ nl, 4 SAY Name->Desc
         nl++
      ENDIF
      IF Name->Desc1 != SPACE( 50 )
         @ nl, 4 SAY Name->Desc1
         nl++
      ENDIF
      IF Name->Desc2 != SPACE( 50 )
         @ nl, 4 SAY Name->Desc2
         nl++
      ENDIF
      IF Name->Desc3 != SPACE( 50 )
         @ nl, 4 SAY Name->Desc3
         nl++
      ENDIF
      nl++
   ****      IF Control->U_Codeno = "KIRBY   "
         coderef := Name->PayRef
         SELECT Cusnotes
         cdetail := ""
         SEEK coderef
         IF FOUND()
            @ nl, 0 SAY ""
            Getdets( coderef )                           // XF_Memo2
            FormP( cdetail,60,10 )                       // XF_Memo2
         ENDIF                          // Found()
         nl++
   ***      ENDIF                            // Kirby only
         SELECT Rept
         mcodeno := Name->Codeno
         SEEK mcodeno
         IF FOUND()
            IF mwhere = "P"
               npl := 64
              ELSE
               npl := 22
            ENDIF
            DO WHILE Rept->Codeno == mcodeno .AND. !EOF()
               IF nl > npl
                  IF mwhere = "P"
                EJECT
                     nl := 0
                     @  nl, 4 SAY Control->U_Name
                     @  nl,52 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                                 +STR( YEAR(DATE() ),5 )
             mtitle := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
                     nl+=2
                    ELSE
                     WAIT
                     SCROLL()
                     nl := 0
                   ENDIF
               ENDIF
      @ nl, 0 SAY Rept->Stat
   ***      @ nl, 8 SAY Rept->Date
      @ nl,10 SAY Rept->SuppId
      @ nl,32 SAY Rept->Info
      nl++
      IF Rept->Info1 != SPACE( 50 )
         @ nl,22 SAY Rept->Info1
         nl++
      ENDIF
      IF Rept->Info2 != SPACE( 50 )
         @ nl,22 SAY Rept->Info2
         nl++
      ENDIF
      IF Rept->Info3 != SPACE( 50 )
         @ nl,22 SAY Rept->Info3
         nl++
      ENDIF
      IF Rept->Info4 != SPACE( 50 )
         @ nl,22 SAY Rept->Info4
         nl++
      ENDIF
      IF Rept->Info5 != SPACE( 50 )
         @ nl,22 SAY Rept->Info5
         nl++
      ENDIF
      nrecno := RECNO()
      ccode  := SUBSTR( Rept->Suppid, 1, 8 )
      SEEK ccode 
      IF FOUND()
            DO WHILE Rept->Codeno == ccode .AND. !EOF()
               IF nl > npl
                  IF mwhere = "P"
                EJECT
                     nl := 0
                     @  nl, 4 SAY Control->U_Name
                     @  nl,52 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                                 +STR( YEAR(DATE() ),5 )
             mtitle := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
                     nl+=2
                    ELSE
                     WAIT
                     SCROLL()
                     nl := 0
                   ENDIF
               ENDIF
      @ nl, 5 SAY Rept->Stat
      @ nl,15 SAY Rept->SuppId
      @ nl,37 SAY Rept->Info
      nl++
      IF Rept->Info1 != SPACE( 50 )
         @ nl,25 SAY Rept->Info1
         nl++
      ENDIF
      IF Rept->Info2 != SPACE( 50 )
         @ nl,25 SAY Rept->Info2
         nl++
      ENDIF
      IF Rept->Info3 != SPACE( 50 )
         @ nl,25 SAY Rept->Info3
         nl++
      ENDIF
      IF Rept->Info4 != SPACE( 50 )
         @ nl,25 SAY Rept->Info4
         nl++
      ENDIF
      IF Rept->Info5 != SPACE( 50 )
         @ nl,25 SAY Rept->Info5
         nl++
      ENDIF
      SKIP ALIAS Rept
   ENDDO                          // Rept
   ENDIF                          // Found
      SELECT Rept
      GOTO nrecno
      SKIP ALIAS Rept
   ENDDO                          // Rept
         ENDIF                             // Found
         npl := nl
         FOR nline = 1 TO ( 43-npl )
            @ nl, 4 SAY "__________________________________________________________________"
            nl+=2
         NEXT
         nl++
         IF mwhere = "P"
            @ nl, 0 SAY " "
            EndPrint()
          ELSE
            IF nl > 17
               WAIT
            ENDIF
            mok := "N"
            DO WHILE mok = "N"
               mok := ApReadN()
            ENDDO
         ENDIF
         SELECT Rept
         SET ORDER TO 1                //

   RETURN NIL

   **** End of NameGroup

   **-------------------------------------------------------------------

FUNCTION PartAction()

   SCROLL( 3,52,18,78 ) 
   SELECT Note
   nl := 4
   @  nl,52 SAY Note->Note1  // COLOR "RG+"
   nl++ 
   @  nl,52 SAY Note->Note2  // COLOR "RG+"
   nl++ 
   @  nl,52 SAY Note->Note3  // COLOR "RG+"
   nl++ 
   @  nl,52 SAY Note->Note4  // COLOR "RG+"
   nl++ 
   @  nl,52 SAY Note->Note5  // COLOR "RG+"
   nl++ 
   @  nl,52 SAY Note->Note6  // COLOR "RG+"
   nl++ 
   @  nl,52 SAY Note->Note7  // COLOR "RG+"
   nl++ 
   @  nl,52 SAY Note->Note8  // COLOR "RG+"
   nl++ 
   @  nl,52 SAY Note->Note9  // COLOR "RG+"
   nl++ 
   @  nl,52 SAY Note->Note10 COLOR "RG+"
   nl++ 
   @  nl,52 SAY Note->Note11 COLOR "RG+"
   nl++ 
   @  nl,52 SAY Note->Note12 COLOR "RG+"
   nl++
   @  nl,52 SAY Note->Note13 COLOR "RG+"
   nl++
   @  nl,52 SAY Note->Note14 COLOR "RG+"
   nl++
   @  nl,52 SAY Note->Note15 COLOR "RG+"
   nl++
   @  nl,52 SAY Note->Note16  // COLOR "RG+"
   nl++
   @  nl,52 SAY Note->Note17  // COLOR "RG+"
   nl++
   @  nl,52 SAY Note->Note18 // COLOR "RG+"
   
   RETURN NIL

   **** End of PartAction

   **-------------------------------------------------------------------

FUNCTION NameAction( maction, nl )

   SELECT Rept
   SET ORDER TO 2                  // Codeno
   SEEK maction
   IF FOUND()
      DO WHILE Rept->Codeno == maction .AND. !EOF()
        IF nl > 18
           EXIT
        ENDIF  
        @  nl,52 SAY Rept->Suppid COLOR "R+"
        nl++
        @  nl,52      SAY Rept->Date PICTURE "99/99/9999" COLOR "BG+"
        @  nl,COL()+2 SAY Rept->Out  PICTURE "@X" COLOR "BG+"
        nl++ 
        @ nl,52 SAY SUBSTR( Rept->Info, 1,37 )
        nl++
        IF nl > 18
           EXIT
        ENDIF  
        IF Rept->Info1 != SPACE( 50 )
           @ nl,52 SAY SUBSTR( Rept->Info1, 1,37 )
           nl++
        ENDIF
        IF nl > 18
           EXIT
        ENDIF  
        IF Rept->Info2 != SPACE( 50 )
           @ nl,52 SAY SUBSTR( Rept->Info2, 1,37 )
           nl++
        ENDIF
        IF nl > 18
           EXIT
        ENDIF  
        IF Rept->Info3 != SPACE( 50 )
           @ nl,52 SAY SUBSTR( Rept->Info3, 1,37 )
           nl++
        ENDIF
        IF nl > 18
           EXIT
        ENDIF  
        IF Rept->Info4 != SPACE( 50 )
           @ nl,52 SAY SUBSTR( Rept->Info4, 1,37 )
           nl++
        ENDIF
        IF nl > 18
           EXIT
        ENDIF  
        IF Rept->Info5 != SPACE( 50 )
           @ nl,52 SAY SUBSTR( Rept->Info5, 1,37 )
           nl++
        ENDIF
        SKIP ALIAS Rept
     ENDDO                          // Rept
  ENDIF                             // Found

   RETURN NIL

   **** End of NameAction

   **-------------------------------------------------------------------

STATIC FUNCTION NameGroup()

   mjobcard := ApGetY( "Do you Want JC-" )
   SELECT Rept
   SET ORDER TO 2               // Codeno
   GOTO TOP
      *** ApFLock( 3 )
      *** INDEX ON Rept->Codeno+Rept->Stat+DTOS( Rept->Date ) TO TempI05
      *** SET INDEX TO TempI05
      *** UNLOCK
             ntotal:= nqtotal := 0
             mcontact := Name->Contact
             mdesc    := Name->Desc
             mdesc1   := Name->Desc1
             mdesc2   := Name->Desc2
             mdesc3   := Name->Desc3
             SCROLL(  16, 0, 24,80 )
             DISPBOX( 16, 1, 24,79, 2 )
             SELECT Name
             nl := 17
             @ nl,10 SAY "  Reference" GET mcontact PICTURE "@X"
             nl++
             @ nl,10 SAY "Description" GET mdesc    PICTURE "@X"
             nl++
             @ nl,22                   GET mdesc1   PICTURE "@X"
             nl++
             @ nl,22                   GET mdesc2   PICTURE "@X"
             nl++
             @ nl,22                   GET mdesc3   PICTURE "@X"
              READ
             SELECT Name
              ApRLock( 3 )
             Name->Contact := mcontact
             Name->Desc    := mdesc
             Name->Desc1   := mdesc1
             Name->Desc2   := mdesc2
             Name->Desc3   := mdesc3
             UNLOCK
             IF Control->U_Codeno = "KIRBY   "
                coderef := Name->PayRef
                SCROLL(  16, 0, 24,80 )

                M2Memofile( coderef )                     // XF_Memo2

               mok := ApGetN( TRIM( Message->Delete )+" Memo" )
               IF mok == "Y"
                  SELECT Cusnotes
                  SEEK Name->Codeno
                   ApFLock( 3 )
                  DO WHILE FOUND()
                     DELETE
                     SEEK Name->Codeno
                  ENDDO
                  UNLOCK
                  SELECT Name
               ENDIF
            ENDIF                   // U_Code = Kirby
            nl := 0
            mwhere := "S"
            npl    := 54

             Printsel( mwhere, npl ) 

            @  nl, 4 SAY Control->U_Name
            @  nl,52 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                        +STR( YEAR(DATE() ),5 )
         mtitle := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
         nl+=2
         @ nl, 4 SAY Name->Name
         nl++
         IF Name->Add1 != "   "
            @ nl, 4 SAY Name->Add1
            nl++
         ENDIF 
         IF Name->Add2 != "   "
            @ nl, 4 SAY Name->Add2
            nl++
         ENDIF
         IF Name->Add3 != "   "
            @ nl, 4 SAY Name->Add3
            nl++
         ENDIF
         IF Name->Add4 != "   "
            @ nl, 4 SAY Name->Add4+"  "+Name->Zip
            nl++
         ENDIF
         IF Name->Add5 != "   "
            @ nl, 4 SAY Name->Add5
            nl++
         ENDIF
         @ nl, 4 SAY Name->Phone+"  "+Name->BPhone+"   "+Name->Sale
         nl++
         @ nl, 4 SAY Name->EPhone+"  "+Name->MobPhone+"  "+Name->OthPhone
         nl++
         @ nl, 4 SAY mtitle
         @ nl,40 SAY Name->EMail
         nl+=2
         IF Name->Contact != SPACE( 30 )
            @ nl, 4 SAY Name->Contact
            nl++
         ENDIF
         IF Name->Desc  != SPACE( 50 )
            @ nl, 4 SAY Name->Desc
            nl++
         ENDIF
         IF Name->Desc1 != SPACE( 50 )
            @ nl, 4 SAY Name->Desc1
            nl++
         ENDIF
         IF Name->Desc2 != SPACE( 50 )
            @ nl, 4 SAY Name->Desc2
            nl++
         ENDIF
         IF Name->Desc3 != SPACE( 50 )
            @ nl, 4 SAY Name->Desc3
            nl++
         ENDIF
         nl++
         IF Control->U_Codeno = "KIRBY   "
            coderef := Name->PayRef
            SELECT Cusnotes
            cdetail := ""
            SEEK coderef
            IF FOUND()
               @ nl, 0 SAY ""
               Getdets( coderef )                           // XF_Memo2
               FormP( cdetail,60,10 )                       // XF_Memo2
            ENDIF                          // Found()
            nl++
         ENDIF                            // Kirby only
            SELECT Rept
            mcodeno := Name->Codeno
            SEEK mcodeno
            IF FOUND()
               IF mwhere = "P"
                  npl := 64
                 ELSE
                  npl := 22
               ENDIF
               DO WHILE Rept->Codeno == mcodeno .AND. !EOF()
                  IF nl > npl
                     IF mwhere = "P"
                   EJECT
                        nl := 0
                        @  nl, 4 SAY Control->U_Name
                        @  nl,52 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                                    +STR( YEAR(DATE() ),5 )
                mtitle := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
                        nl+=2
                       ELSE
                        WAIT
                        SCROLL()
                        nl := 0
                      ENDIF
                  ENDIF
         @ nl, 0 SAY Rept->Stat
      ***      @ nl, 8 SAY Rept->Date
         @ nl,10 SAY Rept->SuppId
         @ nl,32 SAY Rept->Info
         nl++
         IF Rept->Info1 != SPACE( 50 )
            @ nl,22 SAY Rept->Info1
            nl++
         ENDIF
         IF Rept->Info2 != SPACE( 50 )
            @ nl,22 SAY Rept->Info2
            nl++
         ENDIF
         IF Rept->Info3 != SPACE( 50 )
            @ nl,22 SAY Rept->Info3
            nl++
         ENDIF
         IF Rept->Info4 != SPACE( 50 )
            @ nl,22 SAY Rept->Info4
            nl++
         ENDIF
         IF Rept->Info5 != SPACE( 50 )
            @ nl,22 SAY Rept->Info5
            nl++
         ENDIF
         SKIP ALIAS Rept
      ENDDO                          // Rept
   ENDIF                             // Found
   IF mjobcard = "Y"
      mequ   := "Y"
      mlevel := 4
      SELECT Quot
      SET ORDER TO 2
      SEEK mcodeno
      nlabpart := 0
      nl+=2
      DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
         nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
         nqty1:= nqty2:= nqty3:= nqty4 := 0
         nequ1:= nequ2:= nequ3:= nequ4 := 0
         nquot := Quot->Qty
         nequqty1:= nequqty2:= nequqty3:= nequqty4 := 0
         SELECT Equ
         mmod1 := TRIM( Quot->Partnum )
         SEEK mmod1
         nequqty1 := Equ->PartQty
         SELECT Part
         SEEK Quot->Partnum
            @ nl, 2 SAY Part->Desc+"         "+SUBSTR( Quot->Partnum, 1,16 )
            nl++
            IF Part->Detail != SPACE( 43 )
               @ nl,12 SAY Part->Detail
               nl++
            ENDIF
            IF Part->Detail1 != SPACE( 43 )
               @ nl,12 SAY Part->Detail1
               nl++
            ENDIF
            IF Part->Detail2 != SPACE( 43 )
               @ nl,12 SAY Part->Detail2
               nl++
            ENDIF
            IF Part->Detail3 != SPACE( 43 )
               @ nl,12 SAY Part->Detail3
               nl++
            ENDIF
            mpartnum := Quot->Partnum
         IF Quot->Info != SPACE( 45 )
            @ nl,12 SAY Quot->Info
            nl++
         ENDIF
         IF Quot->Info2 != SPACE( 45 )
            @ nl,12 SAY Quot->Info2
            nl++
         ENDIF
         IF Quot->Info3 != SPACE( 45 )
            @ nl,12 SAY Quot->Info3
            nl++
         ENDIF
         IF Quot->Info4 != SPACE( 45 )
            @ nl,12 SAY Quot->Info4
            nl++
         ENDIF
         IF Quot->Info5 != SPACE( 45 )
            @ nl,12 SAY Quot->Info5
            nl++
         ENDIF
         IF Quot->Info6 != SPACE( 45 )
            @ nl,12 SAY Quot->Info6
            nl++
         ENDIF
         IF Quot->Info7 != SPACE( 45 )
            @ nl,12 SAY Quot->Info7
            nl++
         ENDIF
         IF Quot->Info8 != SPACE( 45 )
            @ nl,12 SAY Quot->Info8
            nl++
         ENDIF
         IF Quot->Info9 != SPACE( 45 )
            @ nl,12 SAY Quot->Info9
            nl++
         ENDIF
     IF mlevel >= 1
         SELECT Equ
         GOTO TOP
         mmod1 := TRIM( Quot->Partnum )
         SEEK mmod1
         IF FOUND()   
            DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
               nrecno1 := RECNO()
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
               SELECT Part
               SEEK Equ->Partnum
               nqty1:= nequqty1 := Equ->PartQty
               nequ1 := nqty1* nquot
               @ nl, 6 SAY Part->Desc+"       "+SUBSTR( Equ->Partnum, 1,16 )
               nl++
               IF Part->Detail != SPACE( 43 )
                  @ nl,12 SAY Part->Detail
                  nl++
               ENDIF
               IF Part->Detail1 != SPACE( 43 )
                  @ nl,12 SAY Part->Detail1
                  nl++
               ENDIF
               IF Part->Detail2 != SPACE( 43 )
                  @ nl,12 SAY Part->Detail2
                  nl++
               ENDIF
               IF Part->Detail3 != SPACE( 43 )
                  @ nl,12 SAY Part->Detail3
                  nl++
               ENDIF
               mpartnum := Equ->Partnum
         mseek := Equ->ModSeqno+mpartnum
         SELECT Equ
         mmod2 := TRIM( Equ->Partnum )
     IF mequ = "Y"
         GOTO TOP
         SEEK mmod2
         IF FOUND()   
            IF mlevel >= 2
            DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
               nrecno2 := RECNO() 
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
               nqty2 := Equ->PartQty
               nequ2 := ( nqty1 * nqty2 )* nquot
               nequqty2 := Equ->Partqty*nequqty1
               SELECT Part
               SEEK Equ->Partnum
               @ nl, 8 SAY Part->Desc+"       "+SUBSTR( Equ->Partnum, 1,16 )
               nl++
               IF Part->Detail != SPACE( 43 )
                  @ nl,16 SAY Part->Detail
                  nl++
               ENDIF
               IF Part->Detail1 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail1
                  nl++
               ENDIF
               IF Part->Detail2 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail2
                  nl++
               ENDIF
               IF Part->Detail3 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail3
                  nl++
               ENDIF
               mpartnum := Equ->Partnum
         mseek := Equ->ModSeqno+mpartnum
     IF mlevel >= 3
         SELECT Equ
         mmod3 := TRIM( Equ->Partnum )
         GOTO TOP
         SEEK mmod3
         IF FOUND()   
            DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
               nrecno3 := RECNO() 
               nqty3 := Equ->PartQty
               nequqty3 := Equ->PartQty*nequqty2
               nequ3 := nqty1 * nqty2 * nqty3 * nquot
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
               SELECT Part
               SEEK Equ->Partnum
                @ nl,10 SAY Part->Desc+"       "+SUBSTR( Equ->Partnum, 1,16 )
               IF Equ->Partnum = Message->LabPart
                  nlabpart += nequ3
               ENDIF
               nl++
               IF Part->Detail != SPACE( 43 )
                  @ nl,16 SAY Part->Detail
                  nl++
               ENDIF
               IF Part->Detail1 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail1
                  nl++
               ENDIF
               IF Part->Detail2 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail2
                  nl++
               ENDIF
               IF Part->Detail3 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail3
                  nl++
               ENDIF
               mpartnum := Equ->Partnum
         mseek := Equ->ModSeqno+mpartnum
        IF mlevel = 4
            SELECT Equ
            mmod4   := TRIM( Equ->Partnum )
            GOTO TOP
            SEEK mmod4
            IF FOUND()
               DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                  nrecno4 := RECNO()
                  nqty4 := Equ->PartQty
                  nequqty4 := nequqty3*Equ->PartQty
                  nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
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
               SELECT Part
               SEEK Equ->Partnum
               @ nl,12 SAY Part->Desc+"       "+SUBSTR( Equ->Partnum, 1,16 )
               nl++
               IF Part->Detail != SPACE( 43 )
                  @ nl,16 SAY Part->Detail
                  nl++
               ENDIF
               IF Part->Detail1 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail1
                  nl++
               ENDIF
               IF Part->Detail2 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail2
                  nl++
               ENDIF
               IF Part->Detail3 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail3
                  nl++
               ENDIF
               mpartnum := Equ->Partnum
               mseek := Equ->ModSeqno+mpartnum
                  SELECT Equ 
                  SKIP ALIAS Equ
                ENDDO                       //  mmod4
             ENDIF                          
   ENDIF                                   // mlevel = 4                
               SELECT Equ 
               GOTO nrecno3
               SKIP ALIAS Equ
             ENDDO                       //  mmod3
          ENDIF                          // FOUND()  mmod3    
   ENDIF                                 // mlevel = 3
               SELECT Equ
               GOTO nrecno2
               SKIP ALIAS Equ
            ENDDO                       //  mmod2 EOF()
            nl++
         ENDIF                         // Found mmod2
   ENDIF
   ENDIF                   //   mequ Only first
               SELECT Equ
               GOTO nrecno1
               SKIP ALIAS Equ
               ENDDO                       //   mmod1 EOF()
            ENDIF                          // Found mmod1
   ENDIF                                   // mlevel = 1
         nl++
         SELECT Quot
         SKIP ALIAS Quot
      ENDDO                            //   EOF() Quot
   ENDIF                               // mjobcard 
   npl := nl
   FOR nline = 1 TO ( 43-npl )
      @ nl, 4 SAY "__________________________________________________________________"
      nl+=2
   NEXT
   nl++
   IF mwhere = "P"
      @ nl, 0 SAY " "
      EndPrint()
    ELSE
      IF nl > 17
         WAIT
      ENDIF
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF
   SELECT Rept
   SET ORDER TO 1                //

   RETURN NIL

   **** End of NameGroup

   **-------------------------------------------------------------------

FUNCTION NameVisit()

    mcontact := Name->Contact
    mdesc    := Name->Desc
    mdesc1   := Name->Desc1
    mdesc2   := Name->Desc2
    mdesc3   := Name->Desc3
    SCROLL(  16, 0, 24,80 )
    DISPBOX( 16, 1, 24,79, 2 )
    SELECT Name
    nl := 17
    @ nl,10 SAY "  Reference" GET mcontact PICTURE "@X"
    nl++
    @ nl,10 SAY "Description" GET mdesc    PICTURE "@X"
    nl++
    @ nl,22                   GET mdesc1   PICTURE "@X"
    nl++
    @ nl,22                   GET mdesc2   PICTURE "@X"
    nl++
    @ nl,22                   GET mdesc3   PICTURE "@X"
     READ
    SELECT Name
     ApRLock( 3 )
    Name->Contact := mcontact
    Name->Desc    := mdesc
    Name->Desc1   := mdesc1
    Name->Desc2   := mdesc2
    Name->Desc3   := mdesc3
    UNLOCK
    IF Control->U_Codeno = "KIRBY   "
       coderef := Name->PayRef
       SCROLL(  16, 0, 24,80 )

       M2Memofile( coderef )                     // XF_Memo2

      mok := ApGetN( TRIM( Message->Delete )+" Memo" )
      IF mok == "Y"
         SELECT Cusnotes
         SEEK Name->Codeno
          ApFLock( 3 )
         DO WHILE FOUND()
            DELETE
            SEEK Name->Codeno
         ENDDO
         UNLOCK
         SELECT Name
      ENDIF
   ENDIF                        // Kirby Only
   nl := 0
   mwhere := "S"
   npl    := 54

    Printsel( mwhere, npl ) 

   @  nl, 4 SAY Control->U_Name
   @  nl,52 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
               +STR( YEAR(DATE() ),5 )
   mtitle := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
   nl+=2
   @ nl, 4 SAY Name->Name
   nl++
   @ nl, 4 SAY Name->Add1
   nl++
   @ nl, 4 SAY Name->Add2
   nl++
   @ nl, 4 SAY Name->Add3
   nl++
   @ nl, 4 SAY Name->Add4+"  "+Name->Zip
   nl++
   @ nl, 4 SAY Name->Add5
   nl++
   @ nl, 4 SAY Name->Phone+"  "+Name->BPhone+"   "+Name->Sale
   nl++
   @ nl, 4 SAY Name->EPhone+"  "+Name->MobPhone+"  "+Name->OthPhone
   nl++
   @ nl, 4 SAY mtitle
   @ nl,40 SAY Name->EMail
   nl+=2
   IF Name->Contact != SPACE( 30 )
      @ nl, 4 SAY Name->Contact
      nl++
   ENDIF
   IF Name->Desc  != SPACE( 50 )
      @ nl, 4 SAY Name->Desc
      nl++
   ENDIF
   IF Name->Desc1 != SPACE( 50 )
      @ nl, 4 SAY Name->Desc1
      nl++
   ENDIF
   IF Name->Desc2 != SPACE( 50 )
      @ nl, 4 SAY Name->Desc2
      nl++
   ENDIF
   IF Name->Desc3 != SPACE( 50 )
      @ nl, 4 SAY Name->Desc3
      nl++
   ENDIF
   nl++
   ***      IF Control->U_Codeno = "KIRBY   "
      coderef := Name->PayRef
      SELECT Cusnotes
      cdetail := ""
      SEEK coderef
      IF FOUND()
         @ nl, 0 SAY ""
         Getdets( coderef )                           // XF_Memo2
         FormP( cdetail,60,10 )                       // XF_Memo2
      ENDIF                          // Found()
   ***      ENDIF                             // Kirby Only   
      nl++
   ***      IF SUBSTR( Control->O_Name, 1, 3 ) = "KIR"
      SELECT Quot
      SET ORDER TO 2             // Codeno+Partnum
      mcodeno := Name->Codeno
      SEEK mcodeno
      IF FOUND()
         IF mwhere = "P"
            npl := 65
           ELSE
            npl := 22
         ENDIF
         nqtotal := 0 
         DO WHILE Quot->Codeno == mcodeno .AND. !EOF()
            IF nl > npl
               IF mwhere = "P"
             EJECT
                  nl := 0
                  @  nl, 4 SAY Control->U_Name
                  @  nl,52 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                              +STR( YEAR(DATE() ),5 )
          mtitle := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
                  nl+=2
                 ELSE
                  WAIT
                  SCROLL()
                ENDIF
                nl := 0
            ENDIF
            @ nl, 3 SAY SUBSTR( Quot->Partnum, 1,16 )
            SELECT Part
            SEEK Quot->Partnum
            @ nl,20 SAY Part->Desc
            @ nl,65 SAY Quot->Amount PICTURE "999,999.99"
   ***               @ nl,65 SAY Quot->DbDate
            nl++
            SELECT Quot
            nqtotal += Quot->Amount
            SKIP ALIAS Quot
         ENDDO
         @ nl,62 SAY "-------------"
         nl++
         @ nl,52 SAY "Total ="
         @ nl,63 SAY nqtotal PICTURE "$9999,999.99"
         nl+=2
      ENDIF         // Found
      SELECT Quot
      SET ORDER TO 1
   ****       ENDIF                       // O_Name
      SELECT Debit
      ntotal  := 0
      mcodeno := Name->Codeno
      SEEK mcodeno
      IF FOUND()
         IF mwhere = "P"
            npl := 65
           ELSE
            npl := 22
         ENDIF
         DO WHILE Debit->Codeno == mcodeno .AND. !EOF()
            IF Debit->Stat = "J"
               SKIP ALIAS Debit
               LOOP
            ENDIF
            IF nl > npl
               IF mwhere = "P"
             EJECT
                  nl := 0
                  @  nl, 4 SAY Control->U_Name
                  @  nl,52 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                              +STR( YEAR(DATE() ),5 )
          mtitle := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
                  nl+=2
                 ELSE
                  WAIT
                  SCROLL()
                ENDIF
                nl := 0
            ENDIF
   /*
               IF Debit->Amount == 0
      SKIP ALIAS Debit
      LOOP
   ENDIF
   IF MONTH( Debit->Dbdate ) == ( MONTH(DATE())-1 );
      .AND. YEAR( Debit->Dbdate ) == ( YEAR(DATE()) )
      SKIP ALIAS Debit
      LOOP
   ENDIF
   IF MONTH( Debit->Dbdate ) == ( MONTH(DATE()) );
     .AND. YEAR( Debit->Dbdate ) == ( YEAR(DATE()) )
      SKIP ALIAS Debit
      LOOP
   ENDIF
   */
   @ nl, 3 SAY Debit->Dbdate
   ***   IF Debit->Stat = "I"
      @ nl,14 SAY "Invoice"
   ***    ELSE
   ***      @ nl,14 SAY "JC-"
   ***   ENDIF
   @ nl,23 SAY Debit->Invno
   @ nl,31 SAY Debit->Amount PICTURE "999,999.99"
   ***   @ nl,44 SAY Debit->Stat
   @ nl,45 SAY Debit->Est
   nl++
   ntotal += Debit->Amount
   SKIP ALIAS Debit
      ENDDO
      @ nl,30 SAY "------------"
      @ nl,62 SAY "-------------"
      nl++
      @ nl,20 SAY "Total ="
      @ nl,29 SAY ntotal PICTURE "$9999,999.99"
      @ nl,46 SAY "Grand Total ="
      @ nl,63 SAY ntotal+nqtotal PICTURE "$9999,999.99"
      nl+=2
   ENDIF         // Found
         npl := nl
         FOR nline = 1 TO ( 40-npl )
            @ nl, 4 SAY "__________________________________________________________________"
            nl+=2
         NEXT
         nl++
         IF mwhere = "P"
            @ nl, 0 SAY " "
            EndPrint()
          ELSE
            IF nl > 17
               WAIT
            ENDIF
            mok := "N"
            DO WHILE mok = "N"
               mok := ApReadN()
            ENDDO
         ENDIF

   RETURN NIL

   ***----- End NameVisit()

   **---------------------------------------------------------------------*

STATIC FUNCTION NameHist()

   mstmm  := Control->ACC_Date
   mendmm := DATE()
   mjobhist := ApGetN( "Do You Want Job Card History" )
   IF mjobhist = "Y"
      SCROLL(  16, 0, 24,80 )
      DISPBOX( 16, 1, 24,79, 2 )
      @ 18, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
      @ 19, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
   ENDIF
          ntotal:= nqtotal := 0
          mcontact := Name->Contact
          mdesc    := Name->Desc
          mdesc1   := Name->Desc1
          mdesc2   := Name->Desc2
          mdesc3   := Name->Desc3
          SCROLL(  16, 0, 24,80 )
          DISPBOX( 16, 1, 24,79, 2 )
          SELECT Name
          nl := 17
          @ nl,10 SAY "  Reference" GET mcontact PICTURE "@X"
          nl++
          @ nl,10 SAY "Description" GET mdesc    PICTURE "@X"
          nl++
          @ nl,22                   GET mdesc1   PICTURE "@X"
          nl++
          @ nl,22                   GET mdesc2   PICTURE "@X"
          nl++
          @ nl,22                   GET mdesc3   PICTURE "@X"
           READ
          SELECT Name
           ApRLock( 3 )
          Name->Contact := mcontact
          Name->Desc    := mdesc
          Name->Desc1   := mdesc1
          Name->Desc2   := mdesc2
          Name->Desc3   := mdesc3
          UNLOCK
          IF Control->U_Codeno = "KIRBY   "
             coderef := Name->PayRef
             SCROLL(  16, 0, 24,80 )

             M2Memofile( coderef )                     // XF_Memo2

            mok := ApGetN( TRIM( Message->Delete )+" Memo" )
            IF mok == "Y"
               SELECT Cusnotes
               SEEK Name->Codeno
                ApFLock( 3 )
               DO WHILE FOUND()
                  DELETE
                  SEEK Name->Codeno
               ENDDO
               UNLOCK
               SELECT Name
            ENDIF
         ENDIF                      // Kirby Only
         nl := 0
         mwhere := "S"
         npl    := 54

          Printsel( mwhere, npl ) 

         @  nl, 4 SAY Control->U_Name
         @  nl,52 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                     +STR( YEAR(DATE() ),5 )
      mtitle := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
      nl+=2
      @ nl, 4 SAY Name->Name
      nl++
      @ nl, 4 SAY Name->Add1
      nl++
      @ nl, 4 SAY Name->Add2
      nl++
      @ nl, 4 SAY Name->Add3
      nl++
      @ nl, 4 SAY Name->Add4+"  "+Name->Zip
      nl++
      @ nl, 4 SAY Name->Add5
      nl++
      @ nl, 4 SAY Name->Phone+"  "+Name->BPhone+"   "+Name->Sale
      nl++
      @ nl, 4 SAY Name->EPhone+"  "+Name->MobPhone+"  "+Name->OthPhone
      nl++
      @ nl, 4 SAY mtitle
      @ nl,40 SAY Name->EMail
      nl+=2
      IF Name->Contact != SPACE( 30 )
         @ nl, 4 SAY Name->Contact
         nl++
      ENDIF
      IF Name->Desc  != SPACE( 50 )
         @ nl, 4 SAY Name->Desc
         nl++
      ENDIF
      IF Name->Desc1 != SPACE( 50 )
         @ nl, 4 SAY Name->Desc1
         nl++
      ENDIF
      IF Name->Desc2 != SPACE( 50 )
         @ nl, 4 SAY Name->Desc2
         nl++
      ENDIF
      IF Name->Desc3 != SPACE( 50 )
         @ nl, 4 SAY Name->Desc3
         nl++
      ENDIF
      nl++
      IF Control->U_Codeno = "KIRBY   "
         coderef := Name->PayRef
         SELECT Cusnotes
         cdetail := ""
         SEEK coderef
         IF FOUND()
            @ nl, 0 SAY ""
            Getdets( coderef )                           // XF_Memo2
            FormP( cdetail,60,10 )                       // XF_Memo2
         ENDIF                          // Found()
         nl++
       ENDIF                            // Kirby Only 
         SELECT Rept
         SET ORDER TO 2                  // Codeno
         mcodeno := Name->Codeno
         SEEK mcodeno
         IF FOUND()
            IF mwhere = "P"
               npl := 65
              ELSE
               npl := 22
            ENDIF
            DO WHILE Rept->Codeno == mcodeno .AND. !EOF()
               IF nl > npl
                  IF mwhere = "P"
                EJECT
                     nl := 0
                     @  nl, 4 SAY Control->U_Name
                     @  nl,52 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                                 +STR( YEAR(DATE() ),5 )
             mtitle := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
                     nl+=2
                    ELSE
                     WAIT
                     SCROLL()
                   ENDIF
                   nl := 0
               ENDIF
      @ nl, 0 SAY Rept->Date
      @ nl,12 SAY Rept->Stat
      @ nl,19 SAY Rept->SuppId
      nl++
      IF Rept->Info1 != SPACE( 50 )
         @ nl,22 SAY Rept->Info
      ENDIF
      nl++
      IF Rept->Info1 != SPACE( 50 )
         @ nl,22 SAY Rept->Info1
         nl++
      ENDIF
      IF Rept->Info2 != SPACE( 50 )
         @ nl,22 SAY Rept->Info2
         nl++
      ENDIF
      IF Rept->Info3 != SPACE( 50 )
         @ nl,22 SAY Rept->Info3
         nl++
      ENDIF
      IF Rept->Info4 != SPACE( 50 )
         @ nl,22 SAY Rept->Info4
         nl++
      ENDIF
      IF Rept->Info5 != SPACE( 50 )
         @ nl,22 SAY Rept->Info5
         nl++
      ENDIF
      SKIP ALIAS Rept
   ENDDO                          // Rept
   ENDIF                             // Found
   IF mjobhist == "Y"
         nl++
         SELECT DebProf
         SET ORDER TO 1                  // Codeno
         mcodeno := Name->Codeno
         SEEK mcodeno
         IF FOUND()
            IF mwhere = "P"
               npl := 65
              ELSE
               npl := 22
            ENDIF
            @ nl, 3 SAY "Job Card History "
            nl++
            DO WHILE DebProf->Codeno == mcodeno .AND. !EOF()
               IF DebProf->DbDate < mstmm
                  SKIP ALIAS DebProf
                  LOOP
               ENDIF
               IF DebProf->DbDate > mendmm
                  SKIP ALIAS DebProf
                  LOOP
               ENDIF
               IF nl > npl
                  IF mwhere = "P"
                EJECT
                     nl := 0
                     @  nl, 4 SAY Control->U_Name
                     @  nl,52 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                                 +STR( YEAR(DATE() ),5 )
             mtitle := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
                     nl+=2
                    ELSE
                     WAIT
                     SCROLL()
                   ENDIF
                   nl := 0
               ENDIF
   @ nl, 3 SAY DebProf->Dbdate
   @ nl,14 SAY "P"
   @ nl,23 SAY DebProf->Invno
   @ nl,31 SAY DebProf->Amount PICTURE "9999,999.99"
   @ nl,45 SAY DebProf->Est
   nl++
   ntotal += DebProf->Amount
   SKIP ALIAS DebProf
   ENDDO
      @ nl,29 SAY "-------------"
      nl++
      @ nl,20 SAY "Total ="
      @ nl,30 SAY ntotal PICTURE "$9999,999.99"
      nl+=2
   ENDIF               // Found
   ENDIF                  // mjobhist
         npl := nl
         FOR nline = 1 TO ( 43-npl )
            @ nl, 4 SAY "__________________________________________________________________"
            nl+=2
         NEXT
         nl++
         IF mwhere = "P"
            @ nl, 0 SAY " "
            EndPrint()
          ELSE
            IF nl > 17
               WAIT
            ENDIF
            mok := "N"
            DO WHILE mok = "N"
               mok := ApReadN()
            ENDDO
         ENDIF

   RETURN NIL

   **** End of NameHist

   **********------------ END OF FILE ZSA_Name.PRG
