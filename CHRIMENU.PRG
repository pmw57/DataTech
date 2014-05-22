***  JoKir02 25-02-11 05:52:08 

/*  Program ......:                  CHRIMENU.PRG
    Authors.......: John Kirby
    Date..........: 15/09/1999
    Functions.....: Start, Menu(), GrantMenu
*/

#include "setcurs.ch"

FUNCTION Menu()

DO WHILE .T.
***   SETCOLOR( c_stdcolor )
   SCROLL()
   nl := 22

   SCROLL(  0, 0, 21,78 )
   DISPBOX( 1, 1, 23,79, 2 )
   SCROLL(  0,12,  2,70 )
   DISPBOX( 0,12,  2,70, 2 )
   @  1,41-( LEN( TRIM( Control->U_Name ) )/2 );
             SAY  TRIM( Control->U_Name ) COLOR "GB+"
   @  1,58 SAY DATE() COLOR "R+"
   CLEAR GETS
***   COMMIT
   cheading := "#1 CHRISTINE"
   nselect  := 1
   nc       := 5
   ncl      := 25
   SCROLL(  3,nc, 21,76 )
   DISPBOX( 4,nc, 21,nc+ncl )
   SCROLL(  3,nc+3, 5,nc+(ncl-4) )
   DISPBOX( 3,nc+3, 5,nc+(ncl-4) )
   @  3,34      SAY "Acc Start "+DTOC( Control->Acc_Date )
   @  3,COL()+2 SAY "Next O/N # "+STR( ( Control->LastOrd+1 ), 4 )
   SELECT Quot
   GOTO TOP
      nl:= nll:= nlll := 5
      npl:= npll := 20 
      ccodeno := SPACE( 10 )
      @  4,33 SAY "Goods to Invoice" COLOR "RG+"
      DO WHILE Quot->( !EOF() )
          IF Quot->GoodSent <= 0
             SKIP ALIAS Quot
             LOOP
          ENDIF
          IF Quot->Codeno+Quot->BranchId = ccodeno
             SKIP ALIAS Quot
             LOOP
          ENDIF
          DO CASE
             CASE nl <= npl
                 @ nl,33   SAY Quot->Codeno+" "+Quot->BranchId
                 nl++
             CASE nll <= npll
                 @ nll,45  SAY Quot->Codeno+" "+Quot->BranchId
                 nll++
             OTHERWISE
                 @ nlll,58 SAY Quot->Codeno+" "+Quot->BranchId
                 nlll++
          ENDCASE 
          ccodeno := Quot->Codeno+Quot->BranchId
          SKIP ALIAS Quot
      ENDDO                          // EOF()
   nl:= nll:= nlll:= 5
   npl:= npll:= 20
   ccodeno := SPACE( 8 )
   SELECT Rept
   GOTO TOP
   IF LASTREC() >= 1
      @  4,55 SAY "Reports past 15 days" COLOR "BG+"
      DO WHILE Rept->( !EOF() )
          IF Rept->Date <= DATE()-15
             SKIP ALIAS Rept
             LOOP
          ENDIF
          IF Rept->Codeno = ccodeno
             SKIP ALIAS Rept
             LOOP
          ENDIF
          DO CASE
             CASE nl <= npl
                 @ nl,55   SAY Rept->Codeno
                 nl++
             CASE nll <= npll
                 @ nll,65  SAY Rept->Codeno
                 nll++
             OTHERWISE
                 @ nlll,71 SAY Rept->Codeno
                 nlll++
          ENDCASE 
          ccodeno := Rept->Codeno
          SKIP ALIAS Rept
      ENDDO                          // EOF()
   ENDIF
   @  4,nc+(ncl/2)-(LEN(cheading)/2) SAY cheading
   @  6,nc+2 SAY "Factory" COLOR "GB+"
   @  7,nc+2 PROMPT "1. ORDERS  FACTORY"
   @  8,nc+2 PROMPT "2. INVENTORY      "
   @  9,nc+2 PROMPT "3. PARTS  Required"
   @ 10,nc+2 PROMPT "4. Menus          "
   @ 12,nc+2 PROMPT "5. FACTORY        "
   @ 13,nc+2 SAY "-------------------"
   @ 14,nc+2 SAY "Accounts " COLOR "GB+"
   @ 15,nc+2 PROMPT "6. INVOICE        "
   @ 16,nc+2 PROMPT "7. ACCOUNTS       "
   @ 18,nc+2 PROMPT "8. NAMES          "
   @ 19,nc+2 PROMPT "9. SYSTEM         " 
   @ 20,nc+2 PROMPT "0. EXIT           "
    Lastused( nl )                                 // _Init.PRG
   @ 22,43-(LEN(Note->Note)/2) SAY Note->Note      // COLOR "RG+"
   mtitle2 := "Daemon Solutions  Ph  027 238 6458"
   @ 24, 3 SAY "** CP1-23052014 "
   @ 24,43-(LEN(mtitle2)/2) SAY mtitle2 COLOR "GB+"
   MENU TO nselect
   DO CASE
      CASE nselect == 10
         cstring := "Do you want to Quit :"
 ***        mok     := "Y"
         mok := ApQuit( cstring )           // Appx.prg

         IF mok = "Y"
           SETCURSOR( SC_NONE )
           SELECT Control
            ApRLock( 3 )
           Control->Lastdate := DATE()
           Control->LastTime := TIME()
           UNLOCK
***           EXIT
***           RETURN NIL
           QUIT   
          ELSE
           SETCURSOR( SC_NORMAL )
           LOOP
         ENDIF
      CASE nselect == 1
           @  7,nc+2 SAY "1. ORDERS  FACTORY" COLOR "G+"
           Mu_Stock( nc,ncl )  
      CASE nselect == 2
           @  8,nc+2 SAY "2. INVENTORY      " COLOR "G+"
            Menupart( nc, ncl )
      CASE nselect == 3
           MenuB3()             // MenuB.prg
      CASE nselect == 4
***           LOOP
          @  10,nc+2 SAY "4. MENUS           " COLOR "G+"
           MenuB2()            // XLF_MenB
***           Selection()  // XLF_Qu10.prg    
***             AnalyMenu( nc, ncl )              // XLF_Men.Prg
      CASE nselect == 5
           @ 12,nc+2 SAY "5. FACTORY GRANT  " COLOR "G+"
            GrantMenu( nc, ncl )
      CASE nselect == 6
           @ 15,nc+2 SAY "6.  INVOICE       " COLOR "G+"
              MenuInv( nc, ncl )          //  XLF_Acc.PRG
      CASE nselect == 7
           @ 16,nc+2 SAY "7. ACCOUNTS       " COLOR "G+"
           csecure := SPACE( 6 )
           ncnt := 0
           DO WHILE ncnt < 4  
              @ 12,45 SAY "Enter Password :" GET csecure PICTURE "@!" COLOR "N"
               READ
              IF csecure == SUBSTR( Message->Mess08,1, 6 )

                MenuAct( nc, ncl )          //  XLF_Acc.PRG

                 ncnt := 6
              ENDIF
              ncnt++
           ENDDO
      CASE nselect == 8
           @ 18,nc+2 SAY "8. NAMES          " COLOR "G+"
          MenuName( nc,ncl )
      CASE nselect == 9
         @ 19,nc+2 SAY "9. SYSTEM    MAINT" COLOR "G+"
         csecure := SPACE( 6 )
         ncnt := 0
         DO WHILE ncnt < 4  
            @ 12,45 SAY "Enter Password :" GET csecure PICTURE "@!" COLOR "N"
             READ
            IF csecure == SUBSTR( Message->Charge1, 1, 6 )
               MenuMet( nc, ncl )          //  XLF_Note.PRG
               ncnt := 6
            ENDIF
            ncnt++
         ENDDO
   ENDCASE
ENDDO

RETURN NIL

**** End of Menu()

**-------------------------------------------------------------------

FUNCTION Mu_Stock()

DO WHILE .T.
   nc       := ncl
   SCROLL(  3,nc, 21,78 )
   DISPBOX( 4,nc, 21,nc+ncl )
   SCROLL(  3,nc+4, 5,nc+(ncl-4) )
   DISPBOX( 3,nc+4, 5,nc+(ncl-4) )
   cheading := "FACTORY MENU"
   @  4,nc+( ncl/2 )-( LEN( RTRIM( cheading ) )/2 );
                        SAY RTRIM( cheading )
***   @  7,nc+2 SAY "1. ORDERS  FACTORY " COLOR "G+"
   nselect := 1
   @  7,nc+2 PROMPT "1. FACTORY        MENU"
   @  9,nc+2 PROMPT "2. ORDERS      FACTORY"
   @ 11,nc+2 PROMPT "3. FACTORY     DISPLAY"
   @ 13,nc+2 PROMPT "4. ORDER  SENT    LIST"
   @ 14,nc+2 PROMPT "5. ORDER  Sent Factory"
   @ 15,nc+2 PROMPT "6. ORDER  Sent Details "
   @ 16,nc+2 PROMPT "7. Factory Parts Price"
   @ 17,nc+2 PROMPT "8. Order Taken Factory"
   @ 19,nc+2 PROMPT "9. Operation/Drawings "
   @ 20,nc+2 PROMPT Menu->CH_Main+"  "
   nc := ncl 
   MENU TO nselect
   DO CASE
      CASE nselect == 10 .OR. LASTKEY() == 27
         RETURN
      CASE nselect == 1
         SAVE SCREEN TO Invscrn
         @  7,nc+2 SAY "1. FACTORY        MENU" COLOR "GB+"
          Mu_QPart( nc, ncl )                   // QuotPart
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 2
         SAVE SCREEN TO Invscrn
           QPuotSearch()                             // QuotPart
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 3
         SAVE SCREEN TO Invscrn
          ChriFacDis()              // QuoHouse
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 4              // Sent goods  
         SAVE SCREEN TO Invscrn
           FactAllSent()            // .prg
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 5            // Goods Sent
         SAVE SCREEN TO Invscrn
          QFactSearch()          //                            
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 6            // Goods Sent List
         SAVE SCREEN TO Invscrn
          FactHist()
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 7            // Factory Price
         SAVE SCREEN TO Invscrn
          SELECT Control
           ApRLock( 3 )
          @ 14,56 GET Control->Margin PICTURE "999"
          READ
          UNLOCK
           FactPrice()
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 8              // Quot Add  
         SAVE SCREEN TO Invscrn
 ***          FactoryAdd()             // QLstPart.prg
         RESTORE SCREEN FROM Invscrn
      CASE nselect == 9
         SAVE SCREEN TO Invscrn
           Mu_Oper( nc,ncl )                   // XLF_Equ2
         RESTORE SCREEN FROM Invscrn
      ENDCASE
ENDDO                   // T

RETURN NIL

**** End of Mu_Stock()

**-------------------------------------------------------------------

FUNCTION Start()

    XF_DbfUse()                                     // XF_DBF Opens Files
   
   Control()

   SCROLL()
   @  1,40-( LEN(TRIM(Control->U_Name))/2 ) SAY Control->U_Name
   @  1,58 SAY DATE() COLOR c_hicolor
   nl := 3


   DISPBOX( 5, 1,10,79, 2 )
   IF Control->Acc_Date < DATE()-366
     @  6,10 SAY "Time to Update Name Files for Pay Holiday Sick etc"
     @  8,10 SAY "Change Account Start Date"
      SELECT Control
      ApRLock( 3 )
     @  8,COL()+2 GET Control->Acc_Date
      READ
     UNLOCK
   ENDIF

   IF Control->Acc_Date > DATE()
      @ 12,10 SAY DATE()
      @ 14, 5 SAY "The PC Date is incorrect Please Check" COLOR "R+"
      @ 16, 5 SAY "You MUST Correct this otherwise Files will be incorrect" COLOR "G+"
      WAIT
   ENDIF

***    Disclaimer()                                    // _Init.PRG

RETURN NIL

***--- End of Start()

**-------------------------------------------------------------------

FUNCTION GrantMenu( nc, nl )

DO WHILE .T.

   mcodeno  := SPACE( 8 )
   ccatno   := SPACE( 12 )                    // Required by PartAdd
   nselect  := 0
   nc       := ncl
   SCROLL(  3,nc, 21,78 )
   DISPBOX( 4,nc, 21,nc+ncl )
   SCROLL(  3,nc+4, 5,nc+(ncl-4) )
   DISPBOX( 3,nc+4, 5,nc+(ncl-4) )
   cHead := "FACTORY NEW"
   @  4,nc+(ncl/2)-(LEN( RTRIM( cHead ) )/2);
                     SAY RTRIM( cHead )
   @  7,nc+2 PROMPT Menu2->CH_Part1
   @  9,nc+2 PROMPT Menu2->CH_Part2
   @ 11,nc+2 PROMPT Menu2->CH_Part3
   @ 13,nc+2 PROMPT Menu2->CH_Part4
   @ 15,nc+2 PROMPT "5. Part     History "
   @ 16,nc+2 PROMPT "6. Name     History "
   @ 17,nc+2 PROMPT "7. Part/Name Hist New"
   @ 19,nc+2 PROMPT "8. Hist Sale Analysis"
   @ 20,nc+2 PROMPT "9. Sales Acc Year    "

   MENU TO nselect

   DO CASE
      CASE LASTKEY() == 27
         EXIT
         RETURN NIL
      CASE nselect == 1
         SAVE SCREEN TO holdscrn
          PartView()
         RESTORE SCREEN FROM holdscrn
      CASE nselect == 2
         @  9,nc+2 SAY Menu2->CH_Part2 COLOR "BG+"
         SAVE SCREEN TO holdscrn
          MenuB3()           // XLF_MenuB
         RESTORE SCREEN FROM holdscrn
      CASE nselect == 3
         @ 11,nc+2 SAY Menu2->CH_Part3 COLOR "BG+"
          MU_Cat( nc,ncl )
      CASE nselect == 4
         @ 13,nc+2 SAY Menu2->CH_Part4 COLOR "BG+"
         Mu_Equ( nc,ncl )                                     //  XLF_Equ
      CASE nselect == 5
         SAVE SCREEN TO holdscrn
          ChriPart()
         RESTORE SCREEN FROM holdscrn
      CASE nselect == 6
         SAVE SCREEN TO holdscrn
          ChriName()
         RESTORE SCREEN FROM holdscrn
      CASE nselect == 7
         SAVE SCREEN TO holdscrn
          ChriPName()
         RESTORE SCREEN FROM holdscrn
      CASE nselect == 8
         SAVE SCREEN TO holdscrn
          HistLab()             // PmpTime1
         RESTORE SCREEN FROM holdscrn
      CASE nselect == 9
         SAVE SCREEN TO holdscrn
          ChriConsN()                           // ZFE_Name
         RESTORE SCREEN FROM holdscrn
   ENDCASE
ENDDO

RETURN NIL

***  End of GrantMenu()

*****---------------------- END OF CHRIMENU.PRG