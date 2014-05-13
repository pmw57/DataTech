   ***  JoKir11 13-11-11 14:58:31 

/*
   Program ......:                  XLF_MENB.PRG
   Authors.......: John Kirby
   Date..........: 08/10/2013
   Functions.....: MenuB1, MenuB2, MenuB3, MenuB4,
            .....: MenuProc
   Static funcs..:   NO GOOD HERE 
*/

FUNCTION MenuB1( nc, ncl )

   DO WHILE .T.
      mcodeno := SPACE( 8 )
      nselect := 0
      nl := 5
      nc := ncl*2
      SCROLL(  3,nc, 21,78 )
      DISPBOX( 4,nc, 21,nc+ncl )
      SCROLL(  3,nc+4, 5,nc+(ncl-4) )
      DISPBOX( 3,nc+4, 5,nc+(ncl-4) )
      cHead := "  MENUS  B "
      @  4,nc+(ncl/2)-(LEN( RTRIM( cHead ) )/2);
                        SAY RTRIM( cHead )
      @  6,nc+2 PROMPT " "
      @  7,nc+2 PROMPT "1. Menu 1      B MENU"
      @  8,nc+2 PROMPT "2. Parts ABC   B MENU"     
      @  9,nc+2 PROMPT "3. Menu 3      B MENU"
      @ 11,nc+2 PROMPT "4. Parts       B MENU"
      @ 13,nc+2 PROMPT "5. ABC         B MENU"
      @ 15,nc+2 PROMPT "6. Order Parts B MENU"

      @ 20,nc+2 PROMPT Menu->CH_Main

      MENU TO nselect

      DO CASE
         CASE nselect == 8 .OR. PressedEsc()     // was 9
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdAnalyA
             MenuB1()                      // XLF_MenB
            RESTORE SCREEN FROM holdAnalyA
            LOOP
         CASE nselect == 3
            SAVE SCREEN TO holdAnalyA
             MenuB2()                      // XLF_MenB
            RESTORE SCREEN FROM holdAnalyA
            LOOP
         CASE nselect == 4
           SAVE SCREEN TO holdAnalyA
            MenuB3()                      // XLF_MenB
           RESTORE SCREEN FROM holdAnalyA
           LOOP
         CASE nselect == 5
            SAVE SCREEN TO holdAnalyA
             MenuB4()                   // XLF_MenB
            RESTORE SCREEN FROM holdAnalyA
            LOOP
         CASE nselect == 6
            SAVE SCREEN TO holdAnalyA
             MenuB5()                   // XLF_MenB
            RESTORE SCREEN FROM holdAnalyA
            LOOP
         CASE nselect == 7
            SAVE SCREEN TO holdAnalyA
             MenuProc()                   // XLF_MenB
            RESTORE SCREEN FROM holdAnalyA
            LOOP
      IF PressedEsc()
         RETURN NIL
      ENDIF
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   ***  End of MenuB1()

   ***-------------------------------------------------------------

FUNCTION MenuB2()

      mcodeno  := SPACE( 8 )
      madminno := SPACE( 8 )
   mcont := "Y"
   DO WHILE mcont = "Y"
      SCROLL()
      DISPBOX( 1, 1,24,79, 2 )
      nselect := 1
      @  1,10 SAY "  Operations Menu   " 
      @  2,10 PROMPT " "
      @  3,10 PROMPT "1. Menu A                 "
      @  3,COL()+3 SAY MenuDbfB->Menu_A1 COLOR "G+"
      @  5,10 PROMPT "2. Menu B                 "
      @  5,COL()+3 SAY MenuDbfB->Menu_A2 COLOR "G+"
      @  7,10 PROMPT "3. Kamban MVP             "
      @  7,COL()+3 SAY MenuDbfB->Menu_A3 COLOR "G+"
      @  9,10 PROMPT "4. Analysis Menu          "
      @  9,COL()+3 SAY MenuDbfB->Menu_A4 COLOR "G+"
      @ 11,10 PROMPT "5. Process      Menu      "
      @ 11,COL()+3 SAY MenuDbfB->Menu_A5 COLOR "G+"
      @ 13,10 PROMPT "6. Staff Select           "
      @ 13,COL()+3 SAY MenuDbfB->Menu_A6 COLOR "G+"
      @ 15,10 PROMPT "7. File Name              "
      @ 15,COL()+3 SAY MenuDbfB->Menu_A7 COLOR "G+"
      @ 17,10 PROMPT "8. "+TRIM( Control->U_Codeno )
****      @ 17,COL()+3 SAY MenuDbfB->Menu_A8 COLOR "G+"
      @ 19,10 PROMPT "9. Edit the above Notes   "  
      @ 21,10 PROMPT "10. Exit                  "
      MENU TO nselect
      DO CASE
         CASE nselect == 10
            SELECT MenuDBFC
             ApFLock( 3 )
            @  3,38 GET MenuDBFB->Menu_A1 PICTURE "@X"
            @  5,38 GET MenuDBFB->Menu_A2 PICTURE "@X"
            @  7,38 GET MenuDBFB->Menu_A3 PICTURE "@X"
            @  9,38 GET MenuDBFB->Menu_A4 PICTURE "@X"
            @ 11,38 GET MenuDBFB->Menu_A5 PICTURE "@X"
            @ 13,38 GET MenuDBFB->Menu_A6 PICTURE "@X"
            @ 15,38 GET MenuDBFB->Menu_A7 PICTURE "@X"
***            @ 17,38 GET MenuDBFB->Menu_A8 PICTURE "@X"
             READ
            UNLOCK 
***            LOOP
         CASE nselect == 11 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
           SAVE SCREEN TO holdscrn
            AnalyMenuA( nc, ncl )   //ProfAnalyA()  //XLF_MenuA.PRG
           RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
             MenuB1( nc, ncl )         //XLF_MenuB.PRG
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
             MenuB4()                   // XLF_MenuB.PRG  
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
             AnalyMenu( nc, ncl )      // UtilAnaly()  //XLF_Menu.PRG
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
             MenuProc()                  // XF_Util2.prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
            SELECT Name
            GOTO TOP
            aPart_:={}
            nrecno := 0
            DO WHILE  Name->( !EOF() )
               IF Name->Sale != "STAF"
                  SKIP ALIAS Name
                  LOOP
               ENDIF  
               AADD( aPart_,Name->Codeno+"   "+SUBSTR( Name->Name, 1,26 );
                       +" "+Name->Add1;
                       +"             "+STR( RECNO(),6 ) )
               SKIP ALIAS Name
            ENDDO
            SCROLL()
            DISPBOX( 0, 1,  2,79, 2 )
            @  1, 6      SAY "Adding Staff Task" COLOR "RG+"
            @  1,COL()+2 SAY madminno COLOR "RG+"
            @  1,60 SAY STR( DAY(DATE() ), 3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ), 5 )
            DISPBOX( 0, 1, 24,79, 2 )
            IF !EMPTY( aPart_ )
               ASORT( aCatcode_,,,{ | x,y | x < y } )
               anum := ACHOICE( 3, 2, 23,77,aPart_,,"AFUNC" )
               nrecno := VAL( RIGHT( aPart_[anum],6 ) )
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               GOTO nrecno
               mcodeno := Name->Codeno
            ENDIF
            LabourChri()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
            mcodeno := SPACE( 8 )
            NameRank( @mcodeno )      // XLF_Name
            IF PressedEsc() 
               RETURN NIL
            ENDIF
            SELECT Name
            mcodeno := Name->Codeno
            LabourChri()
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
            SCROLL(   1, 0, 16,80 )
            DISPBOX(  0, 1, 24,79, 2 )
            madminno := SPACE( 8 )
            nsel := 1
            @  0,25 SAY " --- Select Dewey Product Group 25 - 36  "
            @  1, 6 PROMPT "1."+Message->OPerno25
            @  2, 6 PROMPT "2."+Message->OPerno26
            @  3, 6 PROMPT "3."+Message->OPerno27
            @  4, 6 PROMPT "4."+Message->OPerno28
            @  5, 6 PROMPT "5."+Message->OPerno29
            @  6, 6 PROMPT "6."+Message->OPerno30
            @  7, 6 PROMPT "7."+Message->OPerno31
            @  8, 6 PROMPT "8."+Message->OPerno32
            @  9, 6 PROMPT "9."+Message->OPerno33
            @ 10, 6 PROMPT "O."+Message->OPerno34
            @ 11, 6 PROMPT "A."+Message->OPerno35
            @ 12, 6 PROMPT "B."+Message->OPerno36
            @ 13, 6 PROMPT "Blank Entry "
            @ 14, 6 PROMPT "Product Edit"
            @ 15, 6 PROMPT "Exit        "
            MENU TO nsel
            DO CASE
               CASE nsel == 15 .OR. PressedEsc()
                  RETURN NIL
               CASE nsel == 14 .OR. PressedEsc()
                  coperno := SPACE( 8 )
                  Groupselect( @coperno )
               CASE nsel == 1
                  madminno := Message->Operno25
               CASE nsel == 2
                  madminno := Message->Operno26
               CASE nsel == 3
                  madminno := Message->Operno27
               CASE nsel == 4
                  madminno := Message->Operno28
               CASE nsel == 5
                  madminno := Message->Operno29
               CASE nsel == 6
                  madminno := Message->Operno30
               CASE nsel == 7
                  madminno := Message->Operno31
               CASE nsel == 8
                  madminno := Message->Operno32
               CASE nsel == 9
                  madminno := Message->Operno33
               CASE nsel == 10
                  madminno := Message->Operno34
               CASE nsel == 11
                  madminno := Message->Operno35
               CASE nsel == 12
                  madminno := Message->Operno36
               CASE nsel == 13
                  madminno := SPACE( 8 )
            ENDCASE
            mcodeno := Control->U_Codeno
            SELECT Name
            GOTO TOP
            SEEK mcodeno
            mcodeno := Name->Codeno
             LabourChri()
            RESTORE SCREEN FROM holdscrn
      ENDCASE
***      LOOP
   ENDDO

   RETURN 

   *** -------- MenuB2

****------------------------------------------------------------------

FUNCTION MenuB3()

   mcont := "Y"
   DO WHILE mcont = "Y"
      SCROLL()
      DISPBOX( 1, 1,23,79, 2 )
      PDate := DATE()
      nselect := 1
      @  1,10 SAY "   Menu     " 
      @  2,10 PROMPT " "
      nselect := 1
      @  3,10 PROMPT "1. Standard Purchase Order"
      @  3,COL()+3 SAY MenuDbfB->Menu_D1 COLOR "G+"
      @  5,10 PROMPT "2. View Existing Orders   "
      @  5,COL()+3 SAY MenuDbfB->Menu_D2 COLOR "G+"
      @  7,10 PROMPT "3. Received Orders        "
      @  7,COL()+3 SAY MenuDbfB->Menu_D3 COLOR "G+"
      @  9,10 PROMPT "4.                        "
      @  9,COL()+3 SAY MenuDbfB->Menu_D4 COLOR "G+"
      @ 11,10 PROMPT "5.                        "
      @ 11,COL()+3 SAY MenuDbfB->Menu_D5 COLOR "G+"
      @ 13,10 PROMPT "6.                        "
      @ 13,COL()+3 SAY MenuDbfB->Menu_D6 COLOR "G+"
      @ 15,10 PROMPT "7. Part ABC           Menu"
      @ 15,COL()+3 SAY MenuDbfB->Menu_D7 COLOR "G+"
      @ 17,10 PROMPT "8. Procedures Orders  Menu"
      @ 17,COL()+3 SAY MenuDbfB->Menu_D8 COLOR "G+"
      @ 19,10 PROMPT "9. Edit the above Notes   "  
      @ 21,10 PROMPT "10. Exit                  "
      MENU TO nselect
      DO CASE
         CASE nselect == 10
            SELECT MenuDBFC
             ApFLock( 3 )
            @  3,38 GET MenuDBFB->Menu_D1 PICTURE "@X"
            @  5,38 GET MenuDBFB->Menu_D2 PICTURE "@X"
            @  7,38 GET MenuDBFB->Menu_D3 PICTURE "@X"
            @  9,38 GET MenuDBFB->Menu_D4 PICTURE "@X"
            @ 11,38 GET MenuDBFB->Menu_D5 PICTURE "@X"
            @ 13,38 GET MenuDBFB->Menu_D6 PICTURE "@X"
            @ 15,38 GET MenuDBFB->Menu_D7 PICTURE "@X"
            @ 17,38 GET MenuDBFB->Menu_D8 PICTURE "@X"
             READ
            UNLOCK 
         CASE nselect == 11 .OR. PressedEsc()
            RETURN 
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
             OrdByOld()     // ChriOrd3.prg                      
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
             OrdList()                        // XL_Order
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
             OrdArr()               //
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
             MenuB5()       // XLF_MenuB  
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
             MenuProc()                       // XF_Util2 
            RESTORE SCREEN FROM holdscrn
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   *** -------- MenuB3

   ***-----------------------------------------------------------------------

FUNCTION MenuB4()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 1, 1,24,79, 2 )
      nselect := 1
      @  1,10 SAY "  Menu     " 
      @  2,10 PROMPT " "
      nselect := 1
      @  3,10 PROMPT "1. Sales Year             "
      @  3,COL()+3 SAY MenuDbfB->Menu_B1 COLOR "G+"
      @  5,10 PROMPT "2.                        "
      @  5,COL()+3 SAY MenuDbfB->Menu_B2 COLOR "G+"
      @  7,10 PROMPT "3.                        "
      @  7,COL()+3 SAY MenuDbfB->Menu_B3 COLOR "G+"
      @  9,10 PROMPT "4.                        "
      @  9,COL()+3 SAY MenuDbfB->Menu_B4 COLOR "G+"
      @ 11,10 PROMPT "5.                        "
      @ 11,COL()+3 SAY MenuDbfB->Menu_B5 COLOR "G+"
      @ 13,10 PROMPT "6.                        "
      @ 13,COL()+3 SAY MenuDbfB->Menu_B6 COLOR "G+"
      @ 15,10 PROMPT "7.                        "
      @ 15,COL()+3 SAY MenuDbfB->Menu_B7 COLOR "G+"
      @ 17,10 PROMPT "8.                        "
      @ 17,COL()+3 SAY MenuDbfB->Menu_B8 COLOR "G+"
      @ 19,10 PROMPT "9. Edit the above Notes   "  
      @ 21,10 PROMPT "10. Exit                  "
      MENU TO nselect
      DO CASE
         CASE nselect == 10
            SELECT MenuDBFB
             ApFLock( 3 )
            @  3,38 GET MenuDBFB->Menu_B1 PICTURE "@X"
            @  5,38 GET MenuDBFB->Menu_B2 PICTURE "@X"
            @  7,38 GET MenuDBFB->Menu_B3 PICTURE "@X"
            @  9,38 GET MenuDBFB->Menu_B4 PICTURE "@X"
            @ 11,38 GET MenuDBFB->Menu_B5 PICTURE "@X"
            @ 13,38 GET MenuDBFB->Menu_B6 PICTURE "@X"
            @ 15,38 GET MenuDBFB->Menu_B7 PICTURE "@X"
            @ 17,38 GET MenuDBFB->Menu_B8 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 11 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
             YearSale()                 // XF_Util2
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
         LOOP
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   *** -------- MenuB4

****------------------------------------------------------------------
FUNCTION MenuB5()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 1, 1,23,79, 2 )
      PDate := DATE()
      nselect := 1
      @  1,10 SAY "   Menu     " 
      @  2,10 PROMPT " "
      nselect := 1
      @  3,10 PROMPT "1. Name - Module Parts    "
      @  3,COL()+3 SAY MenuDbfB->Menu_C1 COLOR "G+"
      @  5,10 PROMPT "2. JC- System Parts       "
      @  5,COL()+3 SAY MenuDbfB->Menu_C2 COLOR "G+"
      @  7,10 PROMPT "3. ABC By Catalogue       "
      @  7,COL()+3 SAY MenuDbfB->Menu_C3 COLOR "G+"
      @  9,10 PROMPT "4. ABC By Bought/Manufac  "
      @  9,COL()+3 SAY MenuDbfB->Menu_C4 COLOR "G+"
      @ 11,10 PROMPT "5. Module Analysis        "
      @ 11,COL()+3 SAY MenuDbfB->Menu_C5 COLOR "G+"
      @ 13,10 PROMPT "6. Catalogue By years     "
      @ 13,COL()+3 SAY MenuDbfB->Menu_C6 COLOR "G+"
      @ 15,10 PROMPT "7. Year Parts Printing    "
      @ 15,COL()+3 SAY MenuDbfB->Menu_C7 COLOR "G+"
      @ 17,10 PROMPT "8. Year Parts List+Names  "
      @ 17,COL()+3 SAY MenuDbfB->Menu_C8 COLOR "G+"
      @ 19,10 PROMPT "9. Edit the above Notes   "  
      @ 21,10 PROMPT "10. Exit                  "
      MENU TO nselect
      DO CASE
         CASE nselect == 10
            SELECT MenuDBFB
             ApFLock( 3 )
            @  3,38 GET MenuDBFB->Menu_C1 PICTURE "@X"
            @  5,38 GET MenuDBFB->Menu_C2 PICTURE "@X"
            @  7,38 GET MenuDBFB->Menu_C3 PICTURE "@X"
            @  9,38 GET MenuDBFB->Menu_C4 PICTURE "@X"
            @ 11,38 GET MenuDBFB->Menu_C5 PICTURE "@X"
            @ 13,38 GET MenuDBFB->Menu_C6 PICTURE "@X"
            @ 15,38 GET MenuDBFB->Menu_C7 PICTURE "@X"
            @ 17,38 GET MenuDBFB->Menu_C8 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 11 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
             FindJC()          // XLF_Menu.PRG
             FindEqu()         // XF_Util1
            RESTORE SCREEN FROM holdscrn
          LOOP
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
             FindJC()          // XLF_Menu.PRG
             JobStatus()       // MetalCraft  XLF_QU6.PRG
            RESTORE SCREEN FROM holdscrn
          LOOP
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
             ModCat()              
            RESTORE SCREEN FROM holdscrn
          LOOP
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
             PartAbc()         // Below
            RESTORE SCREEN FROM holdscrn
          LOOP
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
             EquAnal()          // XLF_Util1.Prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
             YearCat()                    // XLF_Util1
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
             YearPart()           // XLF_Util1
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
             ChriPart()               // ZFE_Nmae
            RESTORE SCREEN FROM holdscrn
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   *** -------- MenuB5

   ***-----------------------------------------------------------------------

FUNCTION MenuProc()

   mcont := "Y"
   DO WHILE mcont = "Y"
      SCROLL()
      DISPBOX( 1, 1,23,79, 2 )
      PDate := DATE()
      nselect := 1
      @  1,10 SAY "  ORDERS MENU   " 
      @  2,10 PROMPT " "
      nselect := 1
      @  3,10 PROMPT "1. Stock by Catalogue Edit "
      @  3,COL()+3 SAY MenuDbfB->Menu_E1 COLOR "G+"
      @  5,10 PROMPT "2.                         "
      @  5,COL()+3 SAY MenuDbfB->Menu_E2 COLOR "G+"
      @  7,10 PROMPT "3. Parts Quick Edit        "
      @  7,COL()+3 SAY MenuDbfB->Menu_E3 COLOR "G+"
      @  9,10 PROMPT "4. Catalogue Details       "
      @  9,COL()+3 SAY MenuDbfB->Menu_E4 COLOR "G+"
      @ 11,10 PROMPT "5. Urgent,Due,Name,Partnum "
      @ 11,COL()+3 SAY MenuDbfB->Menu_E5 COLOR "G+"
      @ 13,10 PROMPT "6. Orders - List           "
      @ 13,COL()+3 SAY MenuDbfB->Menu_E6 COLOR "G+"
      @ 15,10 PROMPT "7. Locations               "
      @ 15,COL()+3 SAY MenuDbfB->Menu_E7 COLOR "G+"
      @ 17,10 PROMPT "8. Orders Name-Parts Module"
      @ 17,COL()+3 SAY MenuDbfB->Menu_E8 COLOR "G+"
      @ 19,10 PROMPT "9. Edit the above Notes    "  
      @ 21,10 PROMPT "10. Exit                   "
      MENU TO nselect
      DO CASE
         CASE nselect == 10
            SELECT MenuDBFB
             ApFLock( 3 )
            @  3,38 GET MenuDBFB->Menu_E1 PICTURE "@X"
            @  5,38 GET MenuDBFB->Menu_E2 PICTURE "@X"
            @  7,38 GET MenuDBFB->Menu_E3 PICTURE "@X"
            @  9,38 GET MenuDBFB->Menu_E4 PICTURE "@X"
            @ 11,38 GET MenuDBFB->Menu_E5 PICTURE "@X"
            @ 13,38 GET MenuDBFB->Menu_E6 PICTURE "@X"
            @ 15,38 GET MenuDBFB->Menu_E7 PICTURE "@X"
            @ 17,38 GET MenuDBFB->Menu_E8 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 11 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
             StockCat()                        // XF_Util2
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
***            SAVE SCREEN TO holdscrn
***            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
             PartStk()                       // XLF_Cat.prg     
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
             CatList()                      // XF2PPart.prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
               Chrifacdis()                       // QuoHouse.prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
             QuotProf()                         // XLF_Qu2    
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
             LocPart()                         // XF_Plist.prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
             FindJC()             // XLF_Menu
             FindEqu()            // XF_Util1
            RESTORE SCREEN FROM holdscrn
         LOOP
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   *** -------- MenuProc

   *****--------------- END OF XLF_MENB.PRG