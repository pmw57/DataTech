   ***  JoKir10  03-10-11 14:49:55 

/*
   Program ......:                  XLF_MENA.PRG
   Authors.......: John Kirby
   Date..........: 18/08/2009
   Functions.....: AnalyMenuA, ProfAnalyA, JobAnalyA
                   PartAnalyA
   Static funcs..: ProdMenuA, UtilAnalyA, NameAnalyA
*/

FUNCTION AnalyMenuA( nc, ncl )

   DO WHILE .T.
      mcodeno := SPACE( 8 )
      nselect := 0
      nl := 5
      nc := ncl*2
      SCROLL(  3,nc, 21,78 )
      DISPBOX( 4,nc, 21,nc+ncl )
      SCROLL(  3,nc+4, 5,nc+(ncl-4) )
      DISPBOX( 3,nc+4, 5,nc+(ncl-4) )
      cHead := "  MENUS  A "
      @  4,nc+(ncl/2)-(LEN( RTRIM( cHead ) )/2);
                        SAY RTRIM( cHead )
      @  6,nc+2 PROMPT " "
      @  7,nc+2 PROMPT "1. Profile     A MENU"
      @  8,nc+2 PROMPT "2. Part        A MENU"     
      @  9,nc+2 PROMPT "3. Name        A MENU"
      @ 10,nc+2 PROMPT "4. Job         A MENU"
      @ 11,nc+2 PROMPT "5. Utilities   A MENU"
      @ 12,nc+2 PROMPT "6. Production  A MENU"
      @ 18,nc+2 PROMPT "7. Analysis      MENU"
      ***   @ 14,nc+2 PROMPT "7. JC- Test      MENU"
      ***   @ 15,nc+2 PROMPT "8. New JC- Test  MENU"
      @ 20,nc+2 PROMPT Menu->CH_Main

      MENU TO nselect

      DO CASE
         CASE nselect == 9 .OR. PressedEsc()
            ***         EXIT
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdAnalyA
            ProfAnalyA()                        // Below
            RESTORE SCREEN FROM holdAnalyA
         CASE nselect == 3
            SAVE SCREEN TO holdAnalyA
            PartAnalyA()                        // Below
            RESTORE SCREEN FROM holdAnalyA
         CASE nselect == 4
            SAVE SCREEN TO holdAnalyA
            NameAnalyA()                        // Below
            RESTORE SCREEN FROM holdAnalyA
         CASE nselect == 5
            SAVE SCREEN TO holdAnalyA
            JobAnalyA()                        // Below
            RESTORE SCREEN FROM holdAnalyA
         CASE nselect == 6
            SAVE SCREEN TO holdAnalyA
            UtilAnalyA()                        // Below
            RESTORE SCREEN FROM holdAnalyA
         CASE nselect == 7
            SAVE SCREEN TO holdAnalyA
            ProdMenuA()                        // Below
            RESTORE SCREEN FROM holdAnalyA
         CASE nselect == 8
            SAVE SCREEN TO holdAnalyA
            AnalyMenu( nc, ncl )  // XLF_Menu.prg
            RESTORE SCREEN FROM holdAnalyA
            /*
            CASE nselect == 8
               SAVE SCREEN TO holdAnalyA
      NO GOOD          LessonSearch()                     // XLF_QU9
               RESTORE SCREEN FROM holdAnalyA
            CASE nselect == 9
               SAVE SCREEN TO holdAnalyA
                NewMetal() // ZSB_New
               RESTORE SCREEN FROM holdAnalyA
            */
      ENDCASE
   ENDDO

   RETURN NIL

   ***  End of AnalyMenuA()

   ***-------------------------------------------------------------

FUNCTION StockAnaly()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 1, 1,24,79, 2 )
      nselect := 1
      @  1,10 SAY "      STOCK TAKE  MENU      " 
      @  2,10 PROMPT " "
      nselect := 1
      @  3,10 PROMPT "1. Location Detail         "
      @  3,COL()+3 SAY MenuDbfA->Menu_S1 COLOR "G+"
      @  5,10 PROMPT "2. Location Descriptions   "
      @  5,COL()+3 SAY MenuDbfA->Menu_S2 COLOR "G+"
      @  7,10 PROMPT "3. Location Stock Qty      "
      @  7,COL()+3 SAY MenuDbfA->Menu_S3 COLOR "G+"
      @  9,10 PROMPT "4. Quick Parts             "
      @  9,COL()+3 SAY MenuDbfA->Menu_S4 COLOR "G+"
      @ 11,10 PROMPT "5. Part to New Location    "
      **** Factory Display         "
      @ 11,COL()+3 SAY MenuDbfA->Menu_S5 COLOR "G+"
      @ 13,10 PROMPT "6. Change Location to New  "
      **** JC- File                "
      @ 13,COL()+3 SAY MenuDbfA->Menu_S6 COLOR "G+"
      @ 15,10 PROMPT "7. Catalogue Amounts       "
      @ 15,COL()+3 SAY MenuDbfA->Menu_S7 COLOR "G+"
      @ 17,10 PROMPT "8. JC- Parts Required      "
      @ 17,COL()+3 SAY MenuDbfA->Menu_S8 COLOR "G+"
      @ 19,10 PROMPT "9. Edit the above Notes    "  
      @ 21,10 PROMPT "10. Exit                   "
      MENU TO nselect
      DO CASE
         CASE nselect == 10
            SELECT MenuDBF
             ApFLock( 3 )
            @  3,38 GET MenuDBFA->Menu_S1 PICTURE "@X"
            @  5,38 GET MenuDBFA->Menu_S2 PICTURE "@X"
            @  7,38 GET MenuDBFA->Menu_S3 PICTURE "@X"
            @  9,38 GET MenuDBFA->Menu_S4 PICTURE "@X"
            @ 11,38 GET MenuDBFA->Menu_S5 PICTURE "@X"
            @ 13,38 GET MenuDBFA->Menu_S6 PICTURE "@X"
            @ 15,38 GET MenuDBFA->Menu_S7 PICTURE "@X"
            @ 17,38 GET MenuDBFA->Menu_S8 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 11 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
            LocPart()                         // XF_PList.PRG 
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
            LocDesc()                         // XF_PList.PRG 
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
             LocStk()                         // XF_Plist.PRG
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
             PartStk()                        // XF_Cat 
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
              NewLocate()                     // XLF_Note
      ****          Chrifacdis()                        // QuoHouse.prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
              RenameLoc()                     // XLF_Note    
      ***          QuotProf()                         // XLF_Quot    
      ***            Met_QPart( nc,ncl )                       // METquot
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
             CatPrice()                         // XF_Plist
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
            JCReqTot()                         // XLF_QU8.prg   
      ***          mcodeno := SPACE( 8 )
      ***           OrdAdd( @mcodeno )
      ***           ProgDesc()                        // JobDem
            RESTORE SCREEN FROM holdscrn
         LOOP
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   *** -------- StockAnaly

****------------------------------------------------------------------

STATIC FUNCTION ProdMenuA()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 1, 1,23,79, 2 )
      PDate := DATE()
      nselect := 1
      @  1,10 SAY "   PRODUCTION ONLY MENU   A " 
      @  2,10 PROMPT " "
      nselect := 1
      @  3,10 PROMPT "1. Christine Factory       "
      @  3,COL()+3 SAY MenuDbfA->Menu_J1 COLOR "G+"
      @  5,10 PROMPT "2. CHRIS Prod Selected     "
      @  5,COL()+3 SAY MenuDbfA->Menu_J2 COLOR "G+"
      @  7,10 PROMPT "3. Christine Products      "
      @  7,COL()+3 SAY MenuDbfA->Menu_J3 COLOR "G+"
      @  9,10 PROMPT "4. Christine By Name       "
      @  9,COL()+3 SAY MenuDbfA->Menu_J4 COLOR "G+"
      @ 11,10 PROMPT "5. Christine Parts List    "
      @ 11,COL()+3 SAY MenuDbfa->Menu_J5 COLOR "G+"
      @ 13,10 PROMPT "6. JC-List                 "
      @ 13,COL()+3 SAY MenuDbfA->Menu_J6 COLOR "G+"
      @ 15,10 PROMPT "7. Operate Delete          "
      @ 15,COL()+3 SAY MenuDbfA->Menu_J7 COLOR "G+"
      @ 17,10 PROMPT "8. Progress Add Edit       "
      @ 17,COL()+3 SAY MenuDbfA->Menu_J8 COLOR "G+"
      @ 19,10 PROMPT "9. Edit the above Notes    "  
      @ 21,10 PROMPT "10. Exit                   "
      MENU TO nselect
      DO CASE
         CASE nselect == 10
            SELECT MenuDBF
             ApFLock( 3 )
            @  3,38 GET MenuDBF->Menu_J1 PICTURE "@X"
            @  5,38 GET MenuDBF->Menu_J2 PICTURE "@X"
            @  7,38 GET MenuDBF->Menu_J3 PICTURE "@X"
            @  9,38 GET MenuDBF->Menu_J4 PICTURE "@X"
            @ 11,38 GET MenuDBF->Menu_J5 PICTURE "@X"
            @ 13,38 GET MenuDBF->Menu_J6 PICTURE "@X"
            @ 15,38 GET MenuDBF->Menu_J7 PICTURE "@X"
            @ 17,38 GET MenuDBF->Menu_J8 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 11 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            IF SUBSTR( Control->U_Name, 1, 4 ) = "META"
               RETURN NIL
            ENDIF             
            SAVE SCREEN TO holdscrn
             ChriFacDis()
****             FacDisp()                           // XLF_QU1 
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            IF SUBSTR( Control->U_Name, 1, 4 ) = "META"
               RETURN NIL
            ENDIF             
            SAVE SCREEN TO holdscrn
             QSelectPC()                         // XF_Qlist
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            IF SUBSTR( Control->U_Name, 1, 4 ) = "META"
               RETURN NIL
            ENDIF             
            SAVE SCREEN TO holdscrn
             QuotOrdCP()                        // XF_QList  
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            IF SUBSTR( Control->U_Name, 1, 4 ) = "META"
               RETURN NIL
            ENDIF             
            SAVE SCREEN TO holdscrn
             QuotListPC()                        // XF_Qlist  
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            IF SUBSTR( Control->U_Name, 1, 4 ) = "META"
               RETURN NIL
            ENDIF             
            SAVE SCREEN TO holdscrn
              QChriParts()                       // XLF_QU1 
      ****          Chrifacdis()                       // QuoHouse.prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
             QuotProf()                         // XLF_Qu2    
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
             OperDelete()                      // XLF_Ser
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
              ProgDesc()                        // JobDem
            RESTORE SCREEN FROM holdscrn
         LOOP
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   *** -------- ProdMenu

   ***-----------------------------------------------------------------------

STATIC FUNCTION UtilAnalyA()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 1, 1,23,79, 2 )
      nselect := 1
      @  1,17 SAY "  UTILITIES MENU  " 
      @  2,10 PROMPT " "
      @  3,10 PROMPT "1. Christine Factory        "
      @  3,COL()+3 SAY MenuDbfA->Menu_U1 COLOR "G+"
      @  5,10 PROMPT "2. Edit/Del PartOPer.DBF  "
      @  5,COL()+3 SAY MenuDbfA->Menu_U2 COLOR "G+"
      @  7,10 PROMPT "3. Labour    PartOper.DBF "
      @  7,COL()+3 SAY MenuDbfA->Menu_U3 COLOR "G+"
      @  9,10 PROMPT "4. Prof View     Prof.DBF "
      @  9,COL()+3 SAY MenuDbfA->Menu_U4 COLOR "G+"
      @ 11,10 PROMPT "5. Operate.DBF            "
      @ 11,COL()+3 SAY MenuDbfA->Menu_U5 COLOR "G+"
      @ 13,10 PROMPT "6. JC-Labour Work Done    "
      @ 13,COL()+3 SAY MenuDbfA->Menu_U6 COLOR "G+"
      @ 15,10 PROMPT "7. Group Edit Message.Dbf "
      @ 15,COL()+3 SAY MenuDbfA->Menu_U7 COLOR "G+"
      @ 17,10 PROMPT "8. Drawing Edit/Del etc   "
      @ 17,COL()+3 SAY MenuDbfA->Menu_U8 COLOR "G+"
      @ 19,10 PROMPT "9. Marketing By City      "
      @ 19,COL()+3 SAY MenuDbfA->Menu_U9 COLOR "G+"
      @ 21,10 PROMPT "10. Edit the above Notes  "  
      @ 22,10 PROMPT "11. Exit                  "
      MENU TO nselect
      DO CASE
         CASE nselect == 11
            SELECT MenuDBFA
             ApFLock( 3 )
            @  3,38 GET MenuDBFA->Menu_U1 PICTURE "@X"
            @  5,38 GET MenuDBFA->Menu_U2 PICTURE "@X"
            @  7,38 GET MenuDBFA->Menu_U3 PICTURE "@X"
            @  9,38 GET MenuDBFA->Menu_U4 PICTURE "@X"
            @ 11,38 GET MenuDBFA->Menu_U5 PICTURE "@X"
            @ 13,38 GET MenuDBFA->Menu_U6 PICTURE "@X"
            @ 15,38 GET MenuDBFA->Menu_U7 PICTURE "@X"
            @ 17,38 GET MenuDBFA->Menu_U8 PICTURE "@X"
            @ 19,38 GET MenuDBFA->Menu_U9 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 12 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
             FacDisp()                    // XLF_Ord
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
              OperDelete()
      ***          PartOper2()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
              Operation()                      // XLF_QU9/Prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
             ProfView()                        // XLF_Prof.Prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6   
            SAVE SCREEN TO holdscrn
             JobOperate()                      // XLF_QU9.Prg  
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
            SELECT Control
             ApRLock( 3 )
            Control->LastRoll := DATE()-1
            UNLOCK
      ***         IF SUBSTR( Control->U_Name,1, 4 ) = "META" 
               LabourWo()                   // XLF_QU5
      ***           ELSE
      ***            LabourShan()                 // XLF_QU10 
      ***         ENDIF   
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
              coperno := SPACE( 8 )
              GroupSelect( @coperno )  
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
             JobDraw()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 10
            SAVE SCREEN TO holdscrn
             MarkName()                 // ZSM_Name
            RESTORE SCREEN FROM holdscrn
      ENDCASE
      LOOP

   ENDDO
   RETURN NIL

   *** -------- UtilAnalyA()

   ***-------------------------------------------------------------

FUNCTION ProfAnalyA()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 1, 1,23,79, 2 )
      nselect := 1
      @  1,17 SAY "  PROFILE MENU  " 
      @  2,10 PROMPT " "
      @  3,10 PROMPT "1. Profile                 "
      @  3,COL()+3 SAY MenuDbfA->Menu_SA1 COLOR "G+"
      @  5,10 PROMPT "2. Equipment               "
      @  5,COL()+3 SAY MenuDbfA->Menu_SA2 COLOR "G+"
      @  6,10 PROMPT "3. Drawings                "
      @  6,COL()+3 SAY MenuDbfA->Menu_SA3 COLOR "G+"
      @  8,10 PROMPT "4. Card Details List       "
      @  8,COL()+3 SAY MenuDbfA->Menu_SA4 COLOR "G+"
      @ 10,10 PROMPT "5. Delete Profiles         "
      @ 10,COL()+3 SAY MenuDbfA->Menu_SA5 COLOR "G+"
      @ 11,10 PROMPT "6. PartOper Edit/Delete    "
      @ 11,COL()+3 SAY MenuDbfA->Menu_SA6 COLOR "G+"
      @ 12,10 PROMPT "7. PartOper.DBF Edit/Del   "
      @ 12,COL()+3 SAY MenuDbfA->Menu_SA7 COLOR "G+"
      @ 13,10 PROMPT "8. Edit Details of Info    "
      @ 13,COL()+3 SAY MenuDbfA->Menu_SA8 COLOR "G+"
      @ 15,10 PROMPT "9. Operations Groups Edit  "
      @ 15,COL()+3 SAY MenuDbfA->Menu_SA9 COLOR "G+"
      @ 17,10 PROMPT "10. JC- Name Report        "
      @ 17,COL()+3 SAY MenuDbfA->Menu_SA10 COLOR "G+"
      @ 19,10 PROMPT "11. Edit the above Notes   "  
      @ 21,10 PROMPT "12. Exit                   "
      MENU TO nselect

      DO CASE
         CASE nselect == 12
            SELECT MenuDBFA
             ApFLock( 3 )
            @  3,38 GET MenuDBFA->Menu_SA1 PICTURE "@X"
            @  5,38 GET MenuDBFA->Menu_SA2 PICTURE "@X"
            @  6,38 GET MenuDBFA->Menu_SA3 PICTURE "@X"
            @  8,38 GET MenuDBFA->Menu_SA4 PICTURE "@X"
            @ 10,38 GET MenuDBFA->Menu_SA5 PICTURE "@X"
            @ 11,38 GET MenuDBFA->Menu_SA6 PICTURE "@X"
            @ 12,38 GET MenuDBFA->Menu_SA7 PICTURE "@X"
            @ 13,38 GET MenuDBFA->Menu_SA8 PICTURE "@X"
            @ 15,38 GET MenuDBFA->Menu_SA9 PICTURE "@X"
            @ 17,38 GET MenuDBFA->Menu_SA10 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 13 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2                    //  
            SAVE SCREEN TO holdscrn
            ProfView()                       //                  
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3                    //  
            SAVE SCREEN TO holdscrn
            BrandFind()                      // XF_Fault                  
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4                     // Special  
            SAVE SCREEN TO holdscrn
            JobDraw()                       // 
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 5                     // Special  
            SAVE SCREEN TO holdscrn
            PartDraw()                      // JobDemnd 
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6                     // Listing  
            SAVE SCREEN TO holdscrn
            ProfDelete()                      // XLF_Ser.prg
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7                     // Listing  
            SAVE SCREEN TO holdscrn
            mpartnum := SPACE( 20 )
            PartOper2( @mpartnum )            // XF2PPART
            RESTORE SCREEN FROM holdscrn
            LOOP
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
            PartOperAdd()                      // XLF_QU5.Prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
            Operation()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 10
            SAVE SCREEN TO holdscrn
            JobOperate()                     // XLF_Qu9
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 11
            SAVE SCREEN TO holdscrn
             OperSelect()
            RESTORE SCREEN FROM holdscrn
            LOOP  
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   *** -------- ProfAnalyA()

   ****---------------------------------------------------------------

FUNCTION JobAnalyA()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 1, 1,23,79, 2 )
      nselect := 1
      @  1,10 SAY "     JOB MENU      " 
      @  2,10 PROMPT " "
      @  3,10 PROMPT "1. TEST NEW JC-            "
      ****** JC- Progress Report     "
      @  3,COL()+3 SAY MenuDbfA->Menu_M1 COLOR "G+"
      @  5,10 PROMPT "2. JC-Labour Work Done     "
      @  5,COL()+3 SAY MenuDbfA->Menu_M2 COLOR "G+"
      @  7,10 PROMPT "3. JC-Parts System         "
      @  7,COL()+3 SAY MenuDbfA->Menu_M3 COLOR "G+"
      @  9,10 PROMPT "4. PartOper Add            "
      @  9,COL()+3 SAY MenuDbfA->Menu_M4 COLOR "G+"
      @ 11,10 PROMPT "5.JC- Part Required TEST 1 "
      *** Print PartOper.DBF      "
      @ 11,COL()+3 SAY MenuDbfA->Menu_M5 COLOR "G+"
      @ 13,10 PROMPT "6. Job Xt All              "
      @ 13,COL()+3 SAY MenuDbfA->Menu_M6 COLOR "G+"
      @ 15,10 PROMPT "7. JC- Parts Outstanding 2 "
      **** PartOper.DBF Edit/Del   "
      @ 15,COL()+3 SAY MenuDbfA->Menu_M7 COLOR "G+"
      @ 17,10 PROMPT "8. JC-Labour Edit/Delete   "
      @ 17,COL()+3 SAY MenuDbfA->Menu_M8 COLOR "G+"
      @ 19,10 PROMPT "9. Edit the above Notes    "  
      @ 21,10 PROMPT "10. Exit                   "
      MENU TO nselect

      DO CASE
         CASE nselect == 10
            SELECT MenuDBFA
             ApFLock( 3 )
            @  3,38 GET MenuDBFA->Menu_M1 PICTURE "@X"
            @  5,38 GET MenuDBFA->Menu_M2 PICTURE "@X"
            @  7,38 GET MenuDBFA->Menu_M3 PICTURE "@X"
            @  9,38 GET MenuDBFA->Menu_M4 PICTURE "@X"
            @ 11,38 GET MenuDBFA->Menu_M5 PICTURE "@X"
            @ 13,38 GET MenuDBFA->Menu_M6 PICTURE "@X"
            @ 15,38 GET MenuDBFA->Menu_M7 PICTURE "@X"
            @ 17,38 GET MenuDBFA->Menu_M8 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 11 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
               FindJC()
              mcodeno := Debit->Codeno
              SELECT Quot
              SET ORDER TO 3 // Invno+Partnum
              SEEK Debit->Invno            
              mmodcode := Quot->Partnum
              mpartnum := Quot->Partnum
              SELECT Part
              SET ORDER TO 1
              SEEK mpartnum   
               QuotPrice( @mpartnum )                       //JCPrice()
              mmodcode := mpartnum 
              SELECT EquDesc
              SEEK mmodcode
              mmodcode := EquDesc->ModCode
               JCPrice( @mmodcode ) 
               MetJCut( @mcodeno )
               QuotCut( @mcodeno )
               JobStatus(@mcodeno )  
      ****          OperSelect()
               SELECT Quot
               SET ORDER TO 1   // Codeno
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
            SELECT Control
             ApRLock( 3 )
            Control->LastRoll := DATE()-1
            UNLOCK
             LabourWo()                // XLF_QU5
      ****          JCDirect2()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
              QuotSearch()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
              PartOperAdd()                      // XLF_QU5.Prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
             JCReqRec()                         // XLF_QU6.prg
      ***  OperPrint()  
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
             JobXtAll()                         // XLF_QU6
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
             JCReqTot()                       // XLF_Qu8
      ***           OperDelete()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
          SCROLL()
          DISPBOX( 0, 0,19,79, 2 )
          mstmm  := DATE()-30
          mendmm := DATE()
          @ 10, 5 SAY Message->Frdate GET mstmm   PICTURE "99/99/9999"
          @ 12, 5 SAY Message->Todate GET mendmm  PICTURE "99/99/9999"
           READ
         SELECT Labour
      ***      SET ORDER TO 2        // Invno
       mcontinue := "Y"
       DO WHILE mcontinue = "Y"
          SCROLL()
          DISPBOX( 0, 1,24,79, 2 )
          @ 1, 5      SAY mstmm  PICTURE "99/99/9999" COLOR "BG+"
          @ 1,COL()+3 SAY mendmm PICTURE "99/99/9999"
         aPart_:={}
         nrecno := 0
         GOTO TOP
         DO WHILE Labour->( !EOF() )
            IF Labour->Date < mstmm
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF Labour->Date > mendmm
               SKIP ALIAS Labour
               LOOP
            ENDIF
               AADD( aPart_,Labour->Invno;
                         +" "+DTOC( Labour->Date );
                         +" "+Labour->Desc;
                         +" "+STR( Labour->Time, 8, 2 );
                         +" "+Labour->Codeno;
                         +"        "+STR( RECNO(), 6 ) ) 
                 SKIP ALIAS Labour
             ENDDO                        // Labour EOF
      IF !EMPTY( aPart_ )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum := ACHOICE( 3, 3,23,77,aPart_,,"AFUNC" )
         IF PressedEsc()
            EXIT
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         mcorrect := "N"
         DO WHILE mcorrect == "N"
            SELECT Labour
            SCROLL(  10, 0, 24,80 ) 
            DISPBOX( 10, 0, 19,79, 2 )
            mdesc    := Labour->Desc
            mmessage := Labour->Message
            mfault   := Labour->Fault
            mtime    := Labour->Time
            minvno   := Labour->Invno
            mstaff   := Labour->Codeno
            ddate    := Labour->Date
            @ 12, 8      SAY "Desc"          GET mdesc    PICTURE "@X"
            @ 13,13                          GET mmessage PICTURE "@X"
            @ 14,13                          GET mfault   PICTURE "@X"
            @ 16, 8      SAY "Time in Hrs"   GET mtime    PICTURE "9999.99"
            @ 16,COL()+2 SAY "Date"          GET ddate    PICTURE "99/99/9999"
      ***         @ 16,COL()+2 SAY "Rate"       GET Labour->Rate    PICTURE "9999.99"
            @ 18, 8      SAY "Invno"         GET minvno   PICTURE "@!"
            @ 18,COL()+2 SAY Labour->Labno COLOR "BG+"
            @ 18,COL()+2 SAY "Staff/Ord"     GET mstaff   PICTURE "@!"
             READ
             ApRLock( 3 )
            Labour->Desc    := mdesc
            Labour->Message := mmessage
            Labour->Fault   := mfault
            Labour->Time    := mtime
            Labour->Invno   := minvno
            Labour->Codeno  := mstaff
            Labour->Date    := ddate
            UNLOCK
            mcorrect := ApGetY( Message->Correct )
         ENDDO                                            // mcorrect
            SCROLL(  11, 0, 24,80 ) 
            DISPBOX( 11, 1, 19,79, 2 )
            @ 13, 8      SAY Labour->Desc                 COLOR "RG+"
            @ 14, 8      SAY Labour->Message 
            @ 14,COL()+2 SAY Labour->Fault
            @ 15, 8      SAY "Time "+STR( Labour->Time )  COLOR "BG+"
            @ 15,COL()+2 SAY "Date "+DTOC( Labour->Date ) COLOR "BG+"
            @ 17, 8      SAY "Invno "+Labour->Invno       COLOR "BG+"
            @ 17,COL()+2 SAY "Staff "+Labour->Codeno      COLOR "RG+"
         mdelete := ApGetN( TRIM( Message->Delete )+" Labour" )
         IF PressedEsc()
            EXIT           // RETURN NIL
         ENDIF
            IF mdelete == "Y"
               SELECT Labour
                ApRLock( 3 )         
               DELETE
               UNLOCK
            ENDIF
         ENDIF                // Found
         mcontinue := "Y"
         ***     ApGetY( "Edit Another Labour" )
         IF PressedEsc()
            EXIT           // RETURN NIL
         ENDIF
       ENDDO                      // mcontinue 
       manother := "Y"
       LOOP
            RESTORE SCREEN FROM holdscrn
         LOOP
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   *** -------- JobAnalyA()

   ***----------------------------------------------------------------------

FUNCTION PartAnalyA()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 1, 1,23,79, 2 )
      nselect := 1
      @  1,17 SAY "  PART MENU  " 
      @  2,10 PROMPT " "
      nselect := 1
      @  3,10 PROMPT "1. Add New Part            "
      @  3,COL()+3 SAY MenuDbfA->Menu_PA1 COLOR "G+"
      @  5,10 PROMPT "2. Profile and Equipment   "
      @  5,COL()+3 SAY MenuDbfA->Menu_PA2 COLOR "G+"
      @  7,10 PROMPT "3. Module Parts, Cuts, etc "
      @  7,COL()+3 SAY MenuDbfA->Menu_PA3 COLOR "G+"
      @  9,10 PROMPT "4.                        "
      @  9,COL()+3 SAY MenuDbfA->Menu_PA4 COLOR "G+"
      @ 11,10 PROMPT "5. Quick Parts Stock Take  "
      @ 11,COL()+3 SAY MenuDbfA->Menu_PA5 COLOR "G+"
      @ 13,10 PROMPT "6. TEST JC- Part           "
      @ 13,COL()+3 SAY MenuDbfA->Menu_PA6 COLOR "G+"
      @ 15,10 PROMPT "7.                         "
      @ 15,COL()+3 SAY MenuDbfA->Menu_PA7 COLOR "G+"
      @ 17,10 PROMPT "8.                         "
      @ 17,COL()+3 SAY MenuDbfA->Menu_PA8 COLOR "G+"
      @ 19,10 PROMPT "9. Edit the above Notes    "  
      @ 21,10 PROMPT "10. Exit                   "

      MENU TO nselect

      DO CASE
         CASE nselect == 10
            SELECT MenuDBFA
             ApFLock( 3 )
            @  3,38 GET MenuDBFA->Menu_PA1 PICTURE "@X"
            @  5,38 GET MenuDBFA->Menu_PA2 PICTURE "@X"
            @  7,38 GET MenuDBFA->Menu_PA3 PICTURE "@X"
            @  9,38 GET MenuDBFA->Menu_PA4 PICTURE "@X"
            @ 11,38 GET MenuDBFA->Menu_PA5 PICTURE "@X"
            @ 13,38 GET MenuDBFA->Menu_PA6 PICTURE "@X"
            @ 15,38 GET MenuDBFA->Menu_PA7 PICTURE "@X"
            @ 17,38 GET MenuDBFA->Menu_PA8 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 11 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrnA
             mpartnum := SPACE( 16 )
              Partadd( @mpartnum )
             DO CASE
                CASE SUBSTR( Part->Partnum, 1, 3 ) = "JC-"
                     mpartnum := SPACE( 16 )
                CASE SUBSTR( Part->Partnum, 1, 3 ) = "TEM"
                     mpartnum := SPACE( 16 )
                CASE SUBSTR( Part->Partnum, 1, 3 ) = "ZZT"
                     mpartnum := SPACE( 16 )
                CASE SUBSTR( Part->Partnum, 1, 3 ) = "TT-"
                     mpartnum := SPACE( 16 )
             ENDCASE
             IF mpartnum = SPACE( 16 )
                nselect := 1
                LOOP
             ENDIF
              PartDets( mpartnum )
      ***       nselect := 1
            RESTORE SCREEN FROM holdscrnA
         CASE nselect == 3
            SAVE SCREEN TO holdscrnA
             Mu_Prof( nc, ncl )          // XLF_Prof.PRG
            RESTORE SCREEN FROM holdscrnA
         CASE nselect == 4
            SAVE SCREEN TO holdscrnA
             EquAdd()                                   // XLF_EQU2.Prg 
            RESTORE SCREEN FROM holdscrnA
         CASE nselect == 5
            SAVE SCREEN TO holdscrnA
      ***          mpartnum := SPACE( 20 )
      ***           Partfind()                             // XF_Part
            RESTORE SCREEN FROM holdscrnA
         CASE nselect == 6
            SAVE SCREEN TO holdscrnA
             PartStk()
            RESTORE SCREEN FROM holdscrnA
         CASE nselect == 7
            SAVE SCREEN TO holdscrnA
              JCPart()                           // XLF_QU7
            RESTORE SCREEN FROM holdscrnA
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

   *** -------- PartAnalyA()

   ***----------------------------------------------------------------------

STATIC FUNCTION NameAnalyA()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 1, 1,23,79, 2 )
      nselect := 1
      @  1,10 SAY "      NAME MENU        " 
      @  2,10 PROMPT " "
      @  3,10 PROMPT "1. JC-Name Report         "
      @  3,COL()+3 SAY MenuDbfA->Menu_NA1 COLOR "G+"
      @  5,10 PROMPT "2. Name Sale, Accom,Letter"
      @  5,COL()+3 SAY MenuDbfA->Menu_NA2 COLOR "G+"
      @  7,10 PROMPT "3.                        "
      ***   @  7,10 PROMPT "3. Recource Add           "
      @  7,COL()+3 SAY MenuDbfA->Menu_NA3 COLOR "G+"
      @  9,10 PROMPT "4. Admin Entry            "
      @  9,COL()+3 SAY MenuDbfA->Menu_NA4 COLOR "G+"
      @ 11,10 PROMPT "5. Progress Report        "
      @ 11,COL()+3 SAY MenuDbfA->Menu_NA5 COLOR "G+"
      @ 13,10 PROMPT "6.                         "
      @ 13,COL()+3 SAY MenuDbfA->Menu_NA6 COLOR "G+"
      @ 15,10 PROMPT "7.                         "
      @ 15,COL()+3 SAY MenuDbfA->Menu_NA7 COLOR "G+"
      @ 17,10 PROMPT "8. Name Find               "
      @ 17,COL()+3 SAY MenuDbfA->Menu_NA8 COLOR "G+"
      @ 19,10 PROMPT "9. List Name and Email     "  
      @ 19,COL()+3 SAY MenuDbfA->Menu_NA9 COLOR "G+"
      @ 20,10 PROMPT "10. Edit the above Notes   "  
      @ 22,10 PROMPT "Exit                       "
      MENU TO nselect

      DO CASE
         CASE nselect == 11
            SELECT MenuDBFA
             ApFLock( 3 )
            @  3,38 GET MenuDBFA->Menu_NA1 PICTURE "@X"
            @  5,38 GET MenuDBFA->Menu_NA2 PICTURE "@X"
            @  7,38 GET MenuDBFA->Menu_NA3 PICTURE "@X"
            @  9,38 GET MenuDBFA->Menu_NA4 PICTURE "@X"
            @ 11,38 GET MenuDBFA->Menu_NA5 PICTURE "@X"
            @ 13,38 GET MenuDBFA->Menu_NA6 PICTURE "@X"
            @ 15,38 GET MenuDBFA->Menu_NA7 PICTURE "@X"
            @ 17,38 GET MenuDBFA->Menu_NA8 PICTURE "@X"
            @ 19,38 GET MenuDBFA->Menu_NA9 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 12 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
              OperSelect()
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
             OperLetter()                     // XLF_SER.Prg
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
      ***      RecourceAdd()                    // XLF_Job
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
             JobAdmin()                      // JobDem.Prg   
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
              OperSelect()                   // XLF_ser
      ***          AdminPart()   This is Faulty
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
    ***         Consname()                           // ZSM_Name
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
    ***         InvList()
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
            mcodeno = SPACE( 8 )
             NameRank( @mcodeno )                       // 
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 10
            SAVE SCREEN TO holdscrn
             NameEmail()                                 // ZFE_Name
            LOOP
            RESTORE SCREEN FROM holdscrn
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   *** -------- NameAnalyA()

   *****--------------- END OF XLF_MENA.PRG