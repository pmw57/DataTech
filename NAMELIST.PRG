   ***  JK 08-09-11 15:20:52 

/* Program.....:                 NAMELIST.PRG
   Authors......: J.Kirby
   Date.........: 25/08/1991
   Functions....: ListName, Namelsthd
*/

FUNCTION ListName()

   SCROLL()
   DISPBOX( 0, 5, 2,75,2, )
   @  1,10 SAY "Name Listing"
   /*
   TAKEN OUT
      *** mlabel := "N"
   mlabel := ApGetN( "Do You Want Labels :" )
   mwhere := "S"
   mok:= mlabel:= mselect:= "N"
   IF mlabel == "Y"
      msela:= mselb:= SPACE(4)
      mselect := ApGetY( "ARE ALL Labels Required" )
      IF mselect == "N"
         mselc:= mseld:= 0
         @ 12, 5 SAY "Start Labels From Codeno first 4 Characters :";
         GET msela PICTURE "@K!"
         *   @ 16, 5 SAY "End of label Last 4 Characters"
         *   @ 16,50 GET mselb PICTURE "!!!!"
          READ
         *   STORE SUBSTR(mselb,1,4) TO mselc
      ENDIF
      mcol   := "F"
      mname  := "                         "

      Printsel( mwhere )

      npl := 55
      nl  := 1

      SELECT Name
      GOTO TOP
      IF msela != SPACE(4)
         SEEK msela
      ENDIF
      DO WHILE Name->( !EOF() )
         msdatey:= msdatem:= msdate2y:= msdate2m:= 0
         IF nl > npl
            IF mwhere == "P" 
               EndPrint();
               @ 10, 5 SAY "Sorry About this but will improve soon !!!!!"
               @ 12, 5 SAY "Align Print Labels"
               WAIT
               nl := 1
               @  0, 0
               SET DEVICE TO PRINT
            ELSE
               nl := 1
               WAIT
               SCROLL()
            ENDIF                          // mwhere = P
         ENDIF                             // nl >npl
         mtitle := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
         mname := Name->Name
         madd1 := Name->Add1
         madd2 := Name->Add2
         madd3 := Name->Add3
         madd4 := TRIM( Name->Add4 )+" "+Name->Zip
         madd5 := Name->Add5
         msale := Name->Sale
         SKIP ALIAS Name
         mtitle2 := Name->Title+" "+TRIM(Name->Called)+" "+TRIM(Name->Famname)
         *   IF msale <> "BUSI"
         nl := nl+2
         @ nl, 4 SAY mtitle
         @ nl,50 SAY mtitle2
         nl := nl+1
         @ nl, 4 SAY mname
         IF Name->Sale == "BUSI"
            @ nl,50 SAY Name->Name
         ENDIF
         nl := nl+1
         @ nl, 4 SAY madd1
         @ nl,50 SAY Name->Add1
         nl := nl+1
         @ nl, 4 SAY madd2
         @ nl,50 SAY Name->Add2
         nl := nl+1
         @ nl, 4 SAY madd3
         @ nl,50 SAY Name->Add3
         nl := nl+1
         @ nl, 4 SAY madd4
         @ nl,50 SAY TRIM(Name->Add4)+"  "+Name->Zip
         nl := nl+1
         @ nl, 4 SAY madd5
         @ nl,50 SAY Name->Add5
         nl := nl+3
         mname := "                         "
         IF !EOF()
            SKIP ALIAS Name
         ENDIF
      ENDDO
      @ nl, 5 SAY " "
      IF mwhere == "P"
         EndPrint()
      ELSE
         WAIT
      ENDIF                                    // mwhere = P
      RETURN NIL
   ENDIF                                       // End of Labels
   Taken Out
   */
   SCROLL()
   DISPBOX( 3, 5, 24,75, 2 )
   mexec   := SPACE( 4 )
   mchoice := 1
   @  5,15 PROMPT Menu1->Exec01
   @  6,15 PROMPT Menu1->Exec02
   @  7,15 PROMPT Menu1->Exec03
   @  8,15 PROMPT Menu1->Exec04
   @  9,15 PROMPT Menu1->Exec05
   @ 10,15 PROMPT Menu1->Exec06
   @ 11,15 PROMPT Menu1->Exec07
   @ 12,15 PROMPT Menu1->Exec08
   @ 13,15 PROMPT Menu1->Exec09
   @ 14,15 PROMPT Menu1->Exec10
   @ 15,15 PROMPT Menu1->Exec11
   @ 16,15 PROMPT Menu1->Exec12
   @ 17,15 PROMPT Menu1->Exec13
   @ 18,15 PROMPT Menu1->Exec14
   @ 20,15 PROMPT "[          ]"
   @ 20,28 SAY TRIM( Message->Mess12 )
   MENU TO mchoice
   SELECT Name
   DO CASE
      CASE mchoice == 1
         mexec := SUBSTR( Menu1->Exec01,1,4 )
      CASE mchoice == 2
         mexec := SUBSTR( Menu1->Exec02,1,4 )
      CASE mchoice == 3
         mexec := SUBSTR( Menu1->Exec03,1,4 )
      CASE mchoice == 4
         mexec := SUBSTR( Menu1->Exec04,1,4 )
      CASE mchoice == 5
         mexec := SUBSTR( Menu1->Exec05,1,4 )
      CASE mchoice == 6
         mexec := SUBSTR( Menu1->Exec06,1,4 )
      CASE mchoice == 7
         mexec := SUBSTR( Menu1->Exec07,1,4 )
      CASE mchoice == 8
         mexec := SUBSTR( Menu1->Exec08,1,4 )
      CASE mchoice == 9
         mexec := SUBSTR( Menu1->Exec09,1,4 )
      CASE mchoice == 10
         mexec := SUBSTR( Menu1->Exec10,1,4 )
      CASE mchoice == 11
         mexec := SUBSTR( Menu1->Exec11,1,4 )
      CASE mchoice == 12
         mexec := SUBSTR( Menu1->Exec12,1,4 )
      CASE mchoice == 13
         mexec := SUBSTR( Menu1->Exec13,1,4 )
      CASE mchoice == 14
         mexec := SUBSTR( Menu1->Exec14,1,4 )
      CASE mchoice == 15
         mexec := SPACE( 4 ) 
   ENDCASE
   msale   := SPACE( 4 )
   mchoice := 1
   @  5,45 PROMPT Menu1->Mess01  
   @  6,45 PROMPT Menu1->Mess02
   @  7,45 PROMPT Menu1->Mess03
   @  8,45 PROMPT Menu1->Mess04
   @  9,45 PROMPT Menu1->Mess05
   @ 10,45 PROMPT Menu1->Mess06
   @ 11,45 PROMPT Menu1->Mess07
   @ 12,45 PROMPT Menu1->Mess08
   @ 13,45 PROMPT Menu1->Mess09
   @ 14,45 PROMPT Menu1->Mess10
   @ 15,45 PROMPT Menu1->Mess11
   @ 16,45 PROMPT Menu1->Mess12
   @ 17,45 PROMPT Menu1->Mess13
   @ 18,45 PROMPT Menu1->Mess14
   @ 20,45 PROMPT "[          ]"
   @ 20,58 SAY TRIM( Message->Mess12 )
   MENU TO mchoice
   DO CASE
      CASE mchoice == 1
         msale := SUBSTR( Menu1->Mess01,1,4 )
      CASE mchoice == 2
         msale := SUBSTR( Menu1->Mess02,1,4 )
      CASE mchoice == 3
         msale := SUBSTR( Menu1->Mess03,1,4 ) 
      CASE mchoice == 4
         msale := SUBSTR( Menu1->Mess04,1,4 )
      CASE mchoice == 5
         msale := SUBSTR( Menu1->Mess05,1,4 ) 
      CASE mchoice == 6
         msale := SUBSTR( Menu1->Mess06,1,4 ) 
      CASE mchoice == 7
         msale := SUBSTR( Menu1->Mess07,1,4 ) 
      CASE mchoice == 8
         msale := SUBSTR( Menu1->Mess08,1,4 ) 
      CASE mchoice == 9
         msale := SUBSTR( Menu1->Mess09,1,4 ) 
      CASE mchoice == 10
         msale := SUBSTR( Menu1->Mess10,1,4 ) 
      CASE mchoice == 11
         msale := SUBSTR( Menu1->Mess11,1,4 ) 
      CASE mchoice == 12
         msale := SUBSTR( Menu1->Mess12,1,4 ) 
      CASE mchoice == 13
         msale := SUBSTR( Menu1->Mess13,1,4 ) 
      CASE mchoice == 14
         msale := SUBSTR( Menu1->Mess14,1,4 ) 
      CASE mchoice == 15
         msale := SPACE( 4 ) 
   ENDCASE

   npl    := 54
   msize  := "N"
   mwhere := "S"

    Printsel()                                     // _LF_INIT

   SCROLL()

    Namelsthd()                                     // Below 

   SELECT Name
   GOTO TOP
   DO WHILE Name->( !EOF() )
      IF msale != SPACE(4)
         IF Name->Sale != msale
            SKIP ALIAS Name
            LOOP
         ENDIF
      ENDIF
      IF mexec != SPACE(4)
         IF Name->Exec != mexec
            SKIP ALIAS Name
            LOOP
         ENDIF
      ENDIF
      ***   @ nl, 0 SAY Name->Codeno  
      @ nl, 0 SAY Name->Name
      @ nl,46 SAY TRIM( Name->Called)+" "+TRIM( Name->Famname )
      nl++
      @ nl, 6 SAY Name->Add1
      @ nl,34 SAY Name->Add2
      nl++
      @ nl, 6 SAY Name->Add3
      @ nl,34 SAY Name->Add4
      nl++
      @ nl, 0 SAY "Ph "+Name->Phone
      ***   @ nl,18 SAY "Fax "+Name->Bphone
      ***   @ nl,11 SAY Name->Add3
      @ nl,18 SAY "Mob "+Name->MobPhone
      @ nl,40 SAY Name->Email
      nl++
      SELECT Branch
      SEEK Name->Codeno
      IF FOUND()
         DO WHILE Branch->Codeno = Name->Codeno .AND. Branch->( !EOF() )
             @ nl, 8 SAY Branch->Name
             @ nl,52 SAY Branch->BranchId
             nl++
             @ nl, 8 SAY Branch->Add1
             @ nl,36 SAY Branch->Add2
             nl++ 
             @ nl, 6 SAY Branch->Add3
             @ nl,36 SAY Branch->Add4
             nl++
             @ nl, 8 SAY "Ph "+Branch->Phone
             @ nl,30 SAY "Fax "+Branch->Bphone
             nl++
             SKIP ALIAS Branch
         ENDDO
      ENDIF
      SELECT Name
      ***   @ nl,11 SAY Name->Add4
      ***   @ nl,46 SAY "Others "+Name->OthPhone
      ***   nl++
      ***   @ nl,11 SAY Name->Add5
      ***   @ nl,46 SAY Name->PayType+"    "+Charge+" "+PayRef
      /*
      TAKEN OUT
         nl+=2
         SELECT Branch
         SEEK Name->Codeno
         IF FOUND()
            DO WHILE Branch->Codeno = Name->Codeno .AND. Branch->( !EOF() )
               ***        @ nl,11 SAY Branch->BranchId
               @ nl,12 SAY Branch->Name
               @ nl,45 SAY Branch->Phone
               @ nl,60 SAY Branch->BPhone
               nl++
               @ nl,14 SAY TRIM( Branch->Add1 )+" "+Branch->Add2
               nl++
               @ nl,14 SAY TRIM( Branch->Add3 )+" "+Branch->Add4
               nl++
               @ nl,14 SAY TRIM( Branch->Add5 )
               nl++
               SKIP ALIAS Branch
            ENDDO
         ENDIF                                // Found()
      Taken Out
      */
      IF nl > npl
         IF mwhere == "P"
            EJECT
         ELSE
            WAIT
            SCROLL()
         ENDIF

         Namelsthd()                               // Below

      ENDIF
      SELECT Name
      SKIP ALIAS Name
   ENDDO
   IF mwhere == "P"
      EndPrint()
      SET MARGIN TO 0
   ELSE
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF

   RETURN NIL

   **-------------------------------------------------------------------

FUNCTION Namelsthd()

   @  0, 5 SAY Control->U_Name
   @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
      *** @  2, 0 SAY "Account Number"
      *** @  2,34 SAY "Company Details"
   nl := 2

   RETURN NIL
   *** End of Nlsthd()

   *****------------------   END OF FILE NAMELIST.PRG
