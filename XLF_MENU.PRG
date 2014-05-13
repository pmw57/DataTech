   ***  JoKir10   17-10-11 09:24:07 

/* 
   Program ......:                  XLF_MENU.PRG
   Authors.......: John Kirby
   Date..........: 29/04/2009
   Functions.....: AnalyMenu, FindJC, StockAnaly, NameAnaly
                   PartAnaly, ModuleAnaly
   Not used......: UtilAnaly, JobsAnaly, SupplAnaly
*/

FUNCTION AnalyMenu( nc, ncl )

   DO WHILE .T.
      mcodeno := SPACE( 8 )
      nselect := 0
      nl := 5
      nc := ncl     // *2
      nc := ncl     // *2
      SCROLL(  3,nc, 21,78 )
      DISPBOX( 4,nc, 21,nc+ncl )
      ***   @ 21,60 SAY " "
    
      PartAction()  // ZSA_Name.prg Note->Note1/Note18 right side Screen

      ***   SCROLL(  3,nc+2, 5,nc+( ncl-2 ) )
      ***   DISPBOX( 3,nc+2, 5,nc+( ncl-2 ) )
      SCROLL(  3,nc+4, 5,nc+(ncl-4) )
      DISPBOX( 3,nc+4, 5,nc+(ncl-4) )
      cHead := "ANALYSIS"
      @  4,nc+(ncl/2)-(LEN( RTRIM( cHead ) )/2);
                     SAY RTRIM( cHead )
      @  6,nc+2 PROMPT " "
      @  7,nc+2 PROMPT "1  Stock Take    MENU" 
      @  8,nc+2 PROMPT "2. General       MENU"
      @  9,nc+2 PROMPT "3. Name          MENU"
      @ 10,nc+2 PROMPT "4. Part          MENU"
      @ 11,nc+2 PROMPT "5. Supplier      MENU"
      @ 12,nc+2 PROMPT "6. Module        MENU"
      @ 13,nc+2 PROMPT "7. Profile       MENU"
      @ 18,nc+2 PROMPT "8. Menu        A MENU"
      @ 20,nc+2 PROMPT Menu->CH_Main
      MENU TO nselect
      DO CASE
         CASE nselect == 10 .OR. PressedEsc()
            ***         EXIT
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdAnaly
            StockAnaly()                         // Below
            RESTORE SCREEN FROM holdAnaly
         CASE nselect == 3
            SAVE SCREEN TO holdAnaly
            JobsAnaly()                          // Below
            RESTORE SCREEN FROM holdAnaly
         CASE nselect == 4
            SAVE SCREEN TO holdAnaly
            NameAnaly()                        // Below
            RESTORE SCREEN FROM holdAnaly
         CASE nselect == 5
            SAVE SCREEN TO holdAnaly
            PartAnaly()                        // Below
            RESTORE SCREEN FROM holdAnaly
         CASE nselect == 6
            SAVE SCREEN TO holdAnaly
            SupplAnaly()                        // Below
            RESTORE SCREEN FROM holdAnaly
         CASE nselect == 7
            SAVE SCREEN TO holdAnaly
            ModuleAnaly()                        // Below
            RESTORE SCREEN FROM holdAnaly
         CASE nselect == 8
            SAVE SCREEN TO holdAnaly
            ProfAnalyA()                         // XL_MenA.PRG
            RESTORE SCREEN FROM holdAnaly
         CASE nselect == 9
            SAVE SCREEN TO holdAnaly
            AnalyMenuA( nc,ncl )                
            RESTORE SCREEN FROM holdAnaly
      ENDCASE
   ENDDO

   RETURN NIL

   ***  End of AnalyMenu()

   ***-------------------------------------------------------------

FUNCTION FindJC()

   aPart_  := {}
   anum    := {}
   nrecno  := 0
   mcodeno := SPACE( 8 )
   mtempno := SPACE( 8 )
   SELECT Quot
   SET ORDER TO 1      // Codeno
   GOTO TOP
   DO WHILE Quot->( !EOF() )
      IF Quot->Codeno = mtempno
         SKIP ALIAS Quot
         LOOP
      ENDIF
      SELECT Name
      SEEK Quot->Codeno
      SELECT Quot
      AADD( aPart_,Name->Name;
           +"               "+STR( RECNO(),6 ) )
      mtempno := Quot->Codeno
      SKIP ALIAS Quot
   ENDDO                   // Quot
   IF !EMPTY( aPart_ )
      SCROLL()
      DISPBOX( 0, 0, 24,39, 2 )
      @ 12,40 SAY TRIM( Name->Name ) COLOR "BG+"
      ASORT( aPart_,,,{ | x,y | x < y })
      anum := ACHOICE( 1, 3, 23,36, aPart_,,"AFUNC" )
      nrecno := VAL( RIGHT( aPart_[anum],6 ) )
      IF PressedEsc()
         RETURN NIL
      ENDIF
      GOTO nrecno
      mcodeno := Quot->Codeno
   ENDIF 
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
                 +" "+DTOC( Debit->Dbdate );
                 +" "+Debit->Est+" "+Debit->Operno;
                 +"                        "+STR( RECNO(),6 ) )
           SKIP ALIAS Debit
         ENDDO               // Debit
      IF !EMPTY( aPart_ )
         SCROLL()
         DISPBOX(  0, 0, 24,79, 2 )
         ASORT( aPart_,,,{ | x,y | x < y } )
         anum   := ACHOICE(  1, 3, 23,78,aPart_,"","AFUNC")  // AFUNC in XLP_Init
         nrecno := VAL( RIGHT( aPart_[anum], 6 ) )
         GOTO nrecno
         minvno  := Debit->Invno
         mtempno := Debit->Codeno
         coperno := Debit->Operno
         cdesc   := Debit->Est
         mcodeno := Debit->Codeno
      ENDIF                     // Empty
   ENDIF                        // LastRec    

   RETURN NIL
   **** ------ FindJC

   ****----------------------------------------------------------------------

FUNCTION UtilAnaly()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 0, 0,24,79, 2 )
      @ 24,60 SAY " DT41 "
      nselect := 1
      @  0,10 SAY "     LABOUR - UTIL MENU    " 
      @  1,10 PROMPT " "
      @  2,10 PROMPT "1. Labour Factory          "
      @  2,COL()+3 SAY MenuDbf->Menu_U1 COLOR "G+"
      @  4,10 PROMPT "2. NOT GOOD New Metal      " // Labour to JC-           "
      @  4,COL()+3 SAY MenuDbf->Menu_U2 COLOR "G+"
      @  5,10 PROMPT "3. JC- Search              "
      @  5,COL()+3 SAY MenuDbf->Menu_U3 COLOR "G+"
      @  7,10 PROMPT "4. JC- Trade Prices        "
      @  7,COL()+3 SAY MenuDbf->Menu_U4 COLOR "G+"
      @  9,10 PROMPT "5. Lab/Parts List          "
      @  9,COL()+3 SAY MenuDbf->Menu_U5 COLOR "G+"
      @ 11,10 PROMPT "6. Job Card                "
      @ 11,COL()+3 SAY MenuDbf->Menu_U6 COLOR "G+"
      @ 13,10 PROMPT "7. Clean Up JC-Operations  "
      @ 13,COL()+3 SAY MenuDbf->Menu_U7 COLOR "G+"
      @ 15,10 PROMPT "8. JC Report               "
      @ 15,COL()+3 SAY MenuDbf->Menu_U8 COLOR "G+"
      @ 17,10 PROMPT "9. General List            "
      @ 17,COL()+3 SAY MenuDbf->Menu_U9 COLOR "G+"
      @ 19,10 PROMPT "10. JC- Parts Required     "
      @ 19,COL()+3 SAY MenuDbf->Menu_U10 COLOR "G+"
      @ 21,10 PROMPT "11. Edit the above Notes   "  
      @ 23,10 PROMPT "12. Exit                   "
      MENU TO nselect
      DO CASE
         CASE nselect == 12
            SELECT MenuDBF
             ApFLock( 3 )
            @  2,38 GET MenuDBF->Menu_U1 PICTURE "@X"
            @  4,38 GET MenuDBF->Menu_U2 PICTURE "@X"
            @  5,38 GET MenuDBF->Menu_U3 PICTURE "@X"
            @  7,38 GET MenuDBF->Menu_U4 PICTURE "@X"
            @  9,38 GET MenuDBF->Menu_U5 PICTURE "@X"
            @ 11,38 GET MenuDBF->Menu_U6 PICTURE "@X"
            @ 13,38 GET MenuDBF->Menu_U7 PICTURE "@X"
            @ 15,38 GET MenuDBF->Menu_U8 PICTURE "@X"
            @ 17,38 GET MenuDBF->Menu_U9 PICTURE "@X"
            @ 19,38 GET MenuDBF->Menu_U10 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 13 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
            LabourChri()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
            ***          NewMetal()                // ZF_Inv.PRG 
            LabourWO()                  // XLF_QU5.PRG
            ****  Not This one       LabourShan()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
            QuotSearch()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
            FindJC()
            QuotJTrade()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
            QuotLabour()      
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7   
            SAVE SCREEN TO holdscrn
            FindJC()
            ***           QuotJCut( @mcodeno )                    // XLF_Qu5
            MetJCut( mcodeno )                           // XLF_Stat
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8  
            SAVE SCREEN TO holdscrn
            OperDelete()                        //  XLF_Ser.PRG  
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
            JCOperation()                       // XLF_EQU2
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 10
           SAVE SCREEN TO holdscrn
           QuotOrdCP()                          // Above  
           RESTORE SCREEN FROM holdscrn
         CASE nselect == 11
           SAVE SCREEN TO holdscrn
            FindJC()
            JobStatus()                  // XLF_QU6 // XLF_QU7 QuotUpDate() 
          RESTORE SCREEN FROM holdscrn
      ENDCASE
      LOOP

   ENDDO
   RETURN NIL

   *** -------- UtilAnaly()

   ****---------------------------------------------------------------------

FUNCTION JobsAnaly()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 0, 1,24,79, 2 )
      @ 24,60 SAY " DT43 "
      nselect := 1
      @  1,10 SAY "   PRODUCTION ONLY MENU     " 
      @  2,10 PROMPT " "
      nselect := 1
      @  3,10 PROMPT "1. General Factory         "
      @  3,COL()+3 SAY MenuDbf->Menu_J1 COLOR "G+"
      @  5,10 PROMPT "2. General Selected        "
      @  5,COL()+3 SAY MenuDbf->Menu_J2 COLOR "G+"
      @  7,10 PROMPT "3. General                 "
      @  7,COL()+3 SAY MenuDbf->Menu_J3 COLOR "G+"
      @  9,10 PROMPT "4. General By Name         "
      @  9,COL()+3 SAY MenuDbf->Menu_J4 COLOR "G+"
      @ 11,10 PROMPT "5. General Parts List      "
      @ 11,COL()+3 SAY MenuDbf->Menu_J5 COLOR "G+"
      @ 13,10 PROMPT "6. JC-List                 "
      @ 13,COL()+3 SAY MenuDbf->Menu_J6 COLOR "G+"
      @ 15,10 PROMPT "7. Operate Delete          "
      @ 15,COL()+3 SAY MenuDbf->Menu_J7 COLOR "G+"
      @ 17,10 PROMPT "8. Progress Add Edit       "
      @ 17,COL()+3 SAY MenuDbf->Menu_J8 COLOR "G+"
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
             FacDisp()                           // XLF_QU1 
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

   *** -------- JobsAnaly

   ***-----------------------------------------------------------------------

FUNCTION NameAnaly()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 0, 1,24,79, 2 )
      @ 24,60 SAY " DT44 "
      nselect := 1
      @  1,10 SAY "      NAME MENU        " 
      @  2,10 PROMPT " "
      @  3,10 PROMPT "1. Group by Name           "
      @  3,COL()+3 SAY MenuDbf->Menu_N1 COLOR "G+"
      @  5,10 PROMPT "2. Listing Name            "
      @  5,COL()+3 SAY MenuDbf->Menu_N2 COLOR "G+"
      @  7,10 PROMPT "3. Account Year Sales      "
      @  7,COL()+3 SAY MenuDbf->Menu_N3 COLOR "G+"
      @  9,10 PROMPT "4. Sales By Group          "
      @  9,COL()+3 SAY MenuDbf->Menu_N4 COLOR "G+"
      @ 11,10 PROMPT "5. Sales by Month/Name     "
      @ 11,COL()+3 SAY MenuDbf->Menu_N5 COLOR "G+"
      @ 13,10 PROMPT "6. Name Select             "
      @ 13,COL()+3 SAY MenuDbf->Menu_N6 COLOR "G+"
      @ 15,10 PROMPT "7. Invoice Details         "
      @ 15,COL()+3 SAY MenuDbf->Menu_N7 COLOR "G+"
      @ 17,10 PROMPT "8. History Edit            "
      @ 17,COL()+3 SAY MenuDbf->Menu_N8 COLOR "G+"
      @ 19,10 PROMPT "9. List Name and Email     "  
      @ 19,COL()+3 SAY MenuDbf->Menu_N9 COLOR "G+"
      @ 20,10 PROMPT "10. Edit the above Notes   "  
      @ 22,10 PROMPT "Exit                       "
      MENU TO nselect

      DO CASE
         CASE nselect == 11
            SELECT MenuDBF
             ApFLock( 3 )
            @  3,38 GET MenuDBF->Menu_N1 PICTURE "@X"
            @  5,38 GET MenuDBF->Menu_N2 PICTURE "@X"
            @  7,38 GET MenuDBF->Menu_N3 PICTURE "@X"
            @  9,38 GET MenuDBF->Menu_N4 PICTURE "@X"
            @ 11,38 GET MenuDBF->Menu_N5 PICTURE "@X"
            @ 13,38 GET MenuDBF->Menu_N6 PICTURE "@X"
            @ 15,38 GET MenuDBF->Menu_N7 PICTURE "@X"
            @ 17,38 GET MenuDBF->Menu_N8 PICTURE "@X"
            @ 19,38 GET MenuDBF->Menu_N9 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 12 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
             CatConsN()
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
             NameSale()
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
             ChriConsN()                         // ZFE_Name
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
             PyrlProf()                           // ZSM_Name   
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
             DebHistEd()
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
             Consname()                           // ZSM_Name
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
             InvList()
            LOOP
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
            mcodeno := SPACE( 8 ) 
             HistName( mcodeno )
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

   *** -------- NameAnaly()

   ***----------------------------------------------------------------------

FUNCTION PartAnaly()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 1, 1,23,79, 2 )
      @ 24,60 SAY " DT45 "
      nselect := 1
      @  1,10 SAY "         PART MENU      " 
      @  2,10 PROMPT " "
      nselect := 1
      @  3,10 PROMPT "1. Catalogue by Year       "
      @  3,COL()+3 SAY MenuDbf->Menu_P1 COLOR "G+"
      @  5,10 PROMPT "2. Catalogue Sell List     "
      @  5,COL()+3 SAY MenuDbf->Menu_P2 COLOR "G+"
      @  7,10 PROMPT "3. Part ABC              "
      @  7,COL()+3 SAY MenuDbf->Menu_P3 COLOR "G+"
      @  9,10 PROMPT "4. Part Management         "
      @  9,COL()+3 SAY MenuDbf->Menu_P4 COLOR "G+"
      @ 11,10 PROMPT "5. Quick Part Stock        "
      @ 11,COL()+3 SAY MenuDbf->Menu_P5 COLOR "G+"
      @ 13,10 PROMPT "6. Part Note Edit          "
      @ 13,COL()+3 SAY MenuDbf->Menu_P6 COLOR "G+"
      @ 15,10 PROMPT "7. Progress Add Edit       "
      @ 15,COL()+3 SAY MenuDbf->Menu_P7 COLOR "G+"
      ***   IF Note->Private = "PRIVATE     "
      ***      @ 17,10 PROMPT "8.                         "
      ***     ELSE 
         @ 17,10 PROMPT "8. Part Cut List Edit      "
      ***   ENDIF
      @ 17,COL()+3 SAY MenuDbf->Menu_P8 COLOR "G+"

      @ 19,10 PROMPT "9. Edit the above Notes    "  
      @ 21,10 PROMPT "10. Exit                   "

      MENU TO nselect

      DO CASE
         CASE nselect == 10
            SELECT MenuDBF
             ApFLock( 3 )
            @  3,38 GET MenuDBF->Menu_P1 PICTURE "@X"
            @  5,38 GET MenuDBF->Menu_P2 PICTURE "@X"
            @  7,38 GET MenuDBF->Menu_P3 PICTURE "@X"
            @  9,38 GET MenuDBF->Menu_P4 PICTURE "@X"
            @ 11,38 GET MenuDBF->Menu_P5 PICTURE "@X"
            @ 13,38 GET MenuDBF->Menu_P6 PICTURE "@X"
            @ 15,38 GET MenuDBF->Menu_P7 PICTURE "@X"
            @ 17,38 GET MenuDBF->Menu_P8 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 11 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
             CatConsP()                          // AAS_Part.PRG
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
             Cattotal()                          // XLF_Cat.PRG
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
             MenuB3()   // XLF_MenuB   
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
             PartManage()                        // XLF_Cat
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
             PartStk()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
             PartNote()                       // ZSA_Name
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
              ProgDesc()                        // JobDem
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
      ***           IF Note->Private = "PRIVATE     "
      ***               LOOP
      ***              ELSE 
                  CutsReview()                // JobDem
      ***           ENDIF
            RESTORE SCREEN FROM holdscrn
         LOOP
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   *** -------- PartAnaly()

   ***----------------------------------------------------------------------

STATIC FUNCTION SupplAnaly()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 1, 1,23,79, 2 )
      @ 24,60 SAY " DT46 "
      nselect := 1
      @  1,10 SAY "      SUPPLIER MENU      " 
      @  2,10 PROMPT " "
      nselect := 1
      @  3,10 PROMPT "1. Supplier History        "
      @  3,COL()+3 SAY MenuDbf->Menu_S1 COLOR "G+"
      @  5,10 PROMPT "2. Supplier Edit           "
      @  5,COL()+3 SAY MenuDbf->Menu_S2 COLOR "G+"
      @  7,10 PROMPT "3. Orders of Parts         "
      @  7,COL()+3 SAY MenuDbf->Menu_S3 COLOR "G+"
      @  9,10 PROMPT "4. JobXtAll                "
      @  9,COL()+3 SAY MenuDbf->Menu_S4 COLOR "G+"
      @ 11,10 PROMPT "5. OrdOutQuot              "
      @ 11,COL()+3 SAY MenuDbf->Menu_S5 COLOR "G+"
      @ 13,10 PROMPT "6.                         "
      @ 13,COL()+3 SAY MenuDbf->Menu_S6 COLOR "G+"
      @ 15,10 PROMPT "7. QuotFind  JoboutP       "
      @ 15,COL()+3 SAY MenuDbf->Menu_S7 COLOR "G+"
      @ 17,10 PROMPT "8. QuotCode                "
      @ 17,COL()+3 SAY MenuDbf->Menu_S8 COLOR "G+"
      @ 19,10 PROMPT "9. Edit the above Notes    "  
      @ 21,10 PROMPT "10. Exit                   "
      MENU TO nselect

      DO CASE
         CASE nselect == 10
            SELECT MenuDBF
             ApFLock( 3 )
            @  3,38 GET MenuDBF->Menu_S1 PICTURE "@X"
            @  5,38 GET MenuDBF->Menu_S2 PICTURE "@X"
            @  7,38 GET MenuDBF->Menu_S3 PICTURE "@X"
            @  9,38 GET MenuDBF->Menu_S4 PICTURE "@X"
            @ 11,38 GET MenuDBF->Menu_S5 PICTURE "@X"
            @ 13,38 GET MenuDBF->Menu_S6 PICTURE "@X"
            @ 15,38 GET MenuDBF->Menu_S7 PICTURE "@X"
            @ 17,38 GET MenuDBF->Menu_S8 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 11 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
             SuplHist()                      //
            RESTORE SCREEN FROM holdscrn
            LOOP
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
             ProfNatEd()                      // AAS_Part
            RESTORE SCREEN FROM holdscrn
            LOOP
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
             Ordlist()
            RESTORE SCREEN FROM holdscrn
            LOOP
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
             SCROLL()
             JobXtAll()                            // XLF_QU6
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
             OrdoutQuot()                
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
             QuotFind()    
             JobOutP()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
             QuotCode()                            // XL_Qu8
            RESTORE SCREEN FROM holdscrn
         LOOP  
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   *** -------- SupplAnaly()

   ***----------------------------------------------------------------------

FUNCTION ModuleAnaly()

   mcont := "Y"
   DO WHILE mcont = "Y"

      SCROLL()
      DISPBOX( 1, 1,23,79, 2 )
      @ 24,60 SAY " DT47 "
      nselect := 1
      @  1,10 SAY "       MODULE MENU      " 
      @  2,10 PROMPT " "
      @  3,10 PROMPT "1. Special Fault File      "
      @  3,COL()+3 SAY MenuDbf->Menu_M1 COLOR "G+"
      @  5,10 PROMPT "2. Module Parts, Cuts, etc "
      @  5,COL()+3 SAY MenuDbf->Menu_M2 COLOR "G+"
      @  7,10 PROMPT "3. Module Price List       "
      @  7,COL()+3 SAY MenuDbf->Menu_M3 COLOR "G+"
      @  9,10 PROMPT "4. Part-Module Price       "
      @  9,COL()+3 SAY MenuDbf->Menu_M4 COLOR "G+"
      @ 11,10 PROMPT "5. PartOper File           "
      @ 11,COL()+3 SAY MenuDbf->Menu_M5 COLOR "G+"
      @ 13,10 PROMPT "6. Operate File            "
      @ 13,COL()+3 SAY MenuDbf->Menu_M6 COLOR "G+"
      @ 15,10 PROMPT "7. JC- Factory List        "
      @ 15,COL()+3 SAY MenuDbf->Menu_M7 COLOR "G+"
      @ 17,10 PROMPT "8. Part Cut List Edit      "
      @ 17,COL()+3 SAY MenuDbf->Menu_M8 COLOR "G+"
      @ 19,10 PROMPT "9. Edit the above Notes    "  
      @ 21,10 PROMPT "10. Exit                   "
      MENU TO nselect

      DO CASE
         CASE nselect == 10
            SELECT MenuDBF
             ApFLock( 3 )
            @  3,38 GET MenuDBF->Menu_M1 PICTURE "@X"
            @  5,38 GET MenuDBF->Menu_M2 PICTURE "@X"
            @  7,38 GET MenuDBF->Menu_M3 PICTURE "@X"
            @  9,38 GET MenuDBF->Menu_M4 PICTURE "@X"
            @ 11,38 GET MenuDBF->Menu_M5 PICTURE "@X"
            @ 13,38 GET MenuDBF->Menu_M6 PICTURE "@X"
            @ 15,38 GET MenuDBF->Menu_M7 PICTURE "@X"
            @ 17,38 GET MenuDBF->Menu_M8 PICTURE "@X"
             READ
            UNLOCK 
            LOOP
         CASE nselect == 11 .OR. PressedEsc()
            RETURN NIL
         CASE nselect == 2
            SAVE SCREEN TO holdscrn
             BrandFind()                        // XF_Fault 
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 3
            SAVE SCREEN TO holdscrn
             EquAdd()                           // XLF_EQU2.Prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 4
            SAVE SCREEN TO holdscrn
             EquList()                           // XLF_Equ.prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 5
            SAVE SCREEN TO holdscrn
             Equ_Price()                         // XLF_Equ.prg
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 6
            SAVE SCREEN TO holdscrn
             OperDelete() 
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 7
            SAVE SCREEN TO holdscrn
             JobOperate()
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 8
            SAVE SCREEN TO holdscrn
             ChriFacDis()                    //QuoHous
            RESTORE SCREEN FROM holdscrn
         CASE nselect == 9
            SAVE SCREEN TO holdscrn
             CutsReview()                    // JobDem
            RESTORE SCREEN FROM holdscrn
         LOOP
      ENDCASE
      LOOP
   ENDDO

   RETURN NIL

   *** -------- ModuleAnaly()

   *****---------------------- END OF XLF_MENU.PRG