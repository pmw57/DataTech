*** JoKir10  05-10-11 04:59:46 
*** PAWILK02 12-02-2014 Use a ValidPath function to check that a path is correct
***                     before using it, and if it isn't valid, use the PathError
*** 					function from _appx to show an appropriate error message.

/* 
   Program.....:                 CHRIINIT.PRG
   Authors.....:  John Kirby
   Date........:  26/12/1994
   Functions...:  Printsel
*/

FUNCTION Printsel()
   LOCAL aBox

   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      SCROLL(  19, 0, 24,80 )
      DISPBOX( 19, 1, 24,79, 2 )
      nselect := 1
      @ 19, 6      SAY " --- Select Viewing --- " COLOR "G+"
      @ 21, 8      PROMPT " "  
      @ 21, 10     PROMPT "1. Screen"
      @ 21,COL()+2 PROMPT "2. Printer"
      @ 21,COL()+2 PROMPT "3. Text File"
      @ 21,COL()+2 PROMPT "4. Exit"
      MENU TO nselect
      DO CASE
         CASE nselect == 5 .OR. PressedEsc()
            SCROLL()
            mwhere := "S"
            npl    := 22
            Menu()
            ***         RETURN mwhere, npl
         CASE nselect == 1                 // RETURN NIL
             LOOP
         CASE nselect == 2                // To Screen
            SCROLL()
            mwhere := "S"
            npl    := 22
            RETURN NIL

         CASE nselect == 3                 // To Printer
            mtrue  := "N"
             Princhk()                     // 
            IF mtrue == "Y"
               RETURN NIL
            ENDIF
            @  0, 0
            SET PRINTER TO 
            SET DEVICE TO PRINT
            mwhere := "P"
            npl    := 54
            RETURN NIL
            cname := "  "
    
         CASE nselect == 4                  // To Text
            cname := "  "
            mok = "Y"
            DO WHILE mok = "Y"
               cfolder := ""
               SCROLL()
               @  2, 5 SAY "Folder Y:\METALTXT\  or  C:\TEXT\ " COLOR "BG+"
               @  4, 5 SAY "First 2 Characters Important Don't Duplicate" COLOR "BG+"
               @  6, 5 SAY "Record #"
               @  6,COL()+2 SAY Menu2->Record PICTURE "9999"
               @  7,30 SAY Menu2->CH_Fold1 PICTURE "@!" 
               @  8,30 SAY Menu2->CH_Fold2 PICTURE "@!" 
               @  9,30 SAY Menu2->CH_Fold3 PICTURE "@!" 
               @ 10,30 SAY Menu2->CH_Fold4 PICTURE "@!" 
               @ 11,30 SAY Menu2->CH_Fold5 PICTURE "@!" 
               @ 12,30 SAY Menu2->CH_Fold6 PICTURE "@!" 
               @ 13,30 SAY Menu2->CH_Fold7 PICTURE "@!" 
               @ 14,30 SAY Menu2->CH_Fold8 PICTURE "@!" 
               @ 15,30 SAY Menu2->CH_Fold9 PICTURE "@!" 

               nselect := 1
               @  7, 5 PROMPT Menu2->CH_Rec1
               @  8, 5 PROMPT Menu2->CH_Rec2
               @  9, 5 PROMPT Menu2->CH_Rec3
               @ 10, 5 PROMPT Menu2->CH_Rec4
               @ 11, 5 PROMPT Menu2->CH_Rec5
               @ 12, 5 PROMPT Menu2->CH_Rec6
               @ 13, 5 PROMPT Menu2->CH_Rec7
               @ 14, 5 PROMPT Menu2->CH_Quot1
               @ 15, 5 PROMPT Menu2->CH_Quot2
               @ 17, 5 PROMPT "EDIT the Above     "
               MENU TO nselect
               DO CASE
                  CASE PressedEsc()
                     mok := "N"

                  CASE nselect == 10
                     SELECT Menu2
                      ApFLock( 3 )
                     @  6,13 GET Menu2->Record PICTURE "9999"
                     @  7, 5 GET Menu2->CH_Rec1 PICTURE "@!" 
                     @  8, 5 GET Menu2->CH_Rec2 PICTURE "@!" 
                     @  9, 5 GET Menu2->CH_Rec3 PICTURE "@!" 
                     @ 10, 5 GET Menu2->CH_Rec4 PICTURE "@!" 
                     @ 11, 5 GET Menu2->CH_Rec5 PICTURE "@!" 
                     @ 12, 5 GET Menu2->CH_Rec6 PICTURE "@!" 
                     @ 13, 5 GET Menu2->CH_Rec7 PICTURE "@!" 
                     @ 14, 5 GET Menu2->CH_Quot1 PICTURE "@!" 
                     @ 15, 5 GET Menu2->CH_Quot2 PICTURE "@!" 
     
                     @  7,30 GET Menu2->CH_Fold1 PICTURE "@!" 
                     @  8,30 GET Menu2->CH_Fold2 PICTURE "@!" 
                     @  9,30 GET Menu2->CH_Fold3 PICTURE "@!" 
                     @ 10,30 GET Menu2->CH_Fold4 PICTURE "@!" 
                     @ 11,30 GET Menu2->CH_Fold5 PICTURE "@!" 
                     @ 12,30 GET Menu2->CH_Fold6 PICTURE "@!" 
                     @ 13,30 GET Menu2->CH_Fold7 PICTURE "@!" 
                     @ 14,30 GET Menu2->CH_Fold8 PICTURE "@!" 
                     @ 15,30 GET Menu2->CH_Fold9 PICTURE "@!" 
                      READ
                     UNLOCK
                     LOOP 
                  CASE nselect == 1
                     cname := SUBSTR( Menu2->CH_Rec1,1,2 )
                     cfolder := Menu2->CH_Fold1
                  CASE nselect == 2
                     cname := SUBSTR( Menu2->CH_Rec2,1,2 )
                     cfolder := Menu2->CH_Fold2
                  CASE nselect == 3
                     cname := SUBSTR( Menu2->CH_Rec3,1,2 )
                     cfolder := Menu2->CH_Fold3
                  CASE nselect == 4
                     cname := SUBSTR( Menu2->CH_Rec4,1,2 )
                     cfolder := Menu2->CH_Fold4
                  CASE nselect == 5
                     cname := SUBSTR( Menu2->CH_Rec5,1,2 )
                     cfolder := Menu2->CH_Fold5
                  CASE nselect == 6
                     cname := SUBSTR( Menu2->CH_Rec6,1,2 )
                     cfolder := Menu2->CH_Fold6
                  CASE nselect == 7
                     cname := SUBSTR( Menu2->CH_Rec7,1,2 )
                     cfolder := Menu2->CH_Fold7
                  CASE nselect == 8
                     cname := SUBSTR( Menu2->CH_Quot1,1,2 )
                     cfolder := Menu2->CH_Fold8
                  CASE nselect == 9
                     cname := SUBSTR( Menu2->CH_Quot2,1,2 )
                     cfolder := Menu2->CH_Fold9
               ENDCASE
               IF LEN( cfolder ) > 0
                  IF ValidPath( cfolder )
                     nserno := Menu2->Record
                     mserno := STR( nserno,4 )
                     SELECT Menu2  
                      ApFLock( 3 )
                     Menu2->Record   := ( Menu2->Record+1 )
                     Menu2->CH_Quot7 := cfolder
                     UNLOCK
                     cfile := cname+LTRIM( mserno )+"     "
                     @ 18, 5 SAY "Drive/Directory "+Menu2->CH_Quot7 COLOR "G+"
                     @ 20, 5 SAY "Name of Text File";
                             GET  cfile PICTURE "!!!!!!!!"
                      READ  
                     ctext := RTRIM( Menu2->CH_Quot7 )+RTRIM( cfile )+".TXT"

                     @ 23, 5 SAY ctext COLOR "G+"
                     INKEY( 1 )
                     SET PRINTER TO &ctext
                     SET DEVICE TO PRINT   // must be here ?
                     mwhere := "P"
                     npl    := 54
                     ***         COMMIT
                     mok := "N"
                     RETURN NIL
                  ELSE
                     PathError()
                     mok := "Y"
                  ENDIF
               ENDIF
            ENDDO  

      ENDCASE
   ENDDO
   ***  COMMIT
   RETURN NIL

   ***** End of Printsel()
***--------------------------------------------------------------------

FUNCTION EndPrint( cDirSpec )
   EJECT
   SET PRINTER TO
   SET DEVICE TO SCREEN

   RETURN NIL

   ***** End of EndPrint()
****--------------------------------------------------------------------

FUNCTION ValidPath( cPath )
	LOCAL lRetValue := .F.
	LOCAL nFHandle
	LOCAL cTempName
	
	cPath := IF(( valtype(cPath)==valtype("\") .AND. (cPath != NIL)), cPath, "\")
	
	cTempName = strtran( alltrim(cPath) + "lowfile.$$$", "\\", "\")
	nFHandle := fcreate( cTempName )
	
	IF nFHandle > 4
		ferase( cTempName )
		errorlevel( 0 )
		fclose( nFHandle )
		lRetValue := .T.
	ELSE
		errorlevel( ferror() )
	ENDIF

	RETURN lRetValue
	
   ***** End of ValidPath()
   
   ******--------------------  END OF FILE CHRIINIT.PRG
