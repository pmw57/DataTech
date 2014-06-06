// **  JK  08-09-11 15:24:35
// ** PAWILK09 Trim cfile database reference to fix Dos Error 2 (file not found) problem.

/*
   Program.....:            CLMNTNEW.PRG
   Author(s)...: J.Kirby
   Date........: 16/10/1998
   Functions...:  NewClmnt
*/

FUNCTION NewClmnt()

    CLOSE DATABASES

    mcontinue := "Y"
    DO WHILE mcontinue = "Y"
        Scroll()
        USE DataDbf
        GO TOP
        aPart_ := {}
        nrecno := 0
        DO WHILE DataDbf->( !Eof() )
            AAdd( aPart_, FieldGet( 1 ) + "  " + FieldGet( 2 ) + "    " + Str( RecNo(),6 ) )
            SKIP ALIAS DataDbf
        ENDDO                               // DataDbf
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            DispBox( 0, 46,  2, 72 )
            @  1, 48 SAY "MAINTAINING DATA BASES"
            DispBox( 2, 5, 23, 44 )
            anum   := AChoice( 3, 7, 22, 41, aPart_,, "AFUNC" )
            Scroll()
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            cfile := Trim( DataDbf->DataBase )
            @  0, 24 SAY DataDbf->DataBase + "  " + DataDbf->Details COLOR "R+"
            IF LastKey() = 27
                EXIT
            ENDIF
            USE &cfile
            GOTO BOTTOM
            Browse()
            PACK
        ENDIF
        mcontinue := ApGetN( "Another File" )
    ENDDO

    mcontinue := "N"
    // ** := ApGetN( "Change Menu Files" )
    DO WHILE mcontinue = "Y"
        Scroll()
        USE MenuDbf
        GO TOP
        aPart_ := {}
        nrecno := 0
        DO WHILE MenuDbf->( !Eof() )
            AAdd( aPart_, FieldGet( 1 ) + "  " + FieldGet( 2 ) + "   " + Str( RecNo(),6 ) )
            SKIP ALIAS MenuDbf
        ENDDO                               // MenuDbf
        IF !Empty( aPart_ )
            ASort( aPart_,,, {| x, y | x < y } )
            DispBox( 0, 46,  2, 72 )
            @  1, 48 SAY "MAINTAINING MENU FILES"
            DispBox( 2, 5, 23, 44 )
            anum   := AChoice( 3, 7, 22, 41, aPart_,, "AFUNC" )
            Scroll()
            nrecno := Val( Right( aPart_[ anum ],6 ) )
            GOTO nrecno
            cfile := MenuDbf->DataBase
            @  0, 24 SAY MenuDbf->DataBase + "  " + MenuDbf->Details COLOR "R+"
            USE &cfile
            GO TOP
            aPart_ := {}
            nnum := 0
            FOR i = 1 TO 120
                nnum ++
                // ****     cfield1 := FIELD( i )
                cfield2 := FieldGet( i )
                AAdd( aPart_, cfield2 )
            NEXT
            IF !Empty( aPart_ )
                anum := AChoice( 2, 2, 22, 39, aPart_,, "AFUNC" )
                USE &cfile
                GOTO TOP
                npl := 22
                nl  := 1
                ctest := "TEST"
                FOR i = 1 TO 120
                    IF nl > npl
                        WAIT
                        Scroll( 1, 39, 24, 80 )
                        nl := 1
                    ENDIF
                    nl++
                    @ nl, 60 SAY FieldGet( i )
                    nl++
                    ctest := FieldGet( i )
                    @ nl, 40 SAY FIELD( i )
                    @ nl, 59 GET ctest
                    READ
                    IF LastKey() = 27
                        EXIT
                    ENDIF
                    FieldPut( i, ctest )
                NEXT
                PACK
            ENDIF
        ENDIF
        mcontinue := ApGetN( "Another File" )
    ENDDO

    DBFReIndx()

    RETURN NIL

// *****--------------- END OF FILE CLMNTNEW.PRG
