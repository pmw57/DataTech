// ** JoKir10  09-10-11 10:13:24

/* CHRIORD3.PRG
   Author......: J.Kirby
   Date........: 25/11/2002  // 16/08/2006 12/07/1013
   Calls.......: OrdOutQuot, OrdAdd
*/

FUNCTION OrdOutQuot()

    Scroll()
    nrecno := 0
    aPart_ := {}
    anum   := {}
    ccodeno := Space( 6 )
    SELECT QuotStk
    SET ORDER TO 1                    // Invno
    GOTO TOP
    DO WHILE QuotStk->( !Eof() )
        IF QuotStk->Codeno = Control->U_Codeno
            SKIP ALIAS QuotStk
            LOOP
        ENDIF
        IF QuotStk->Ordnum != "   "
            SKIP ALIAS QuotStk
            LOOP
        ENDIF
        IF QuotStk->Received >= QuotStk->Required
            SKIP ALIAS QuotStk
            LOOP
        ENDIF
        SELECT Part
        SET ORDER TO 1
        SEEK QuotStk->Partnum
        SELECT QuotStk
        AAdd( aPart_, QuotStk->Codeno;
            + " " + QuotStk->Partnum;
            + " " + SubStr( Part->Desc, 1, 28 );
            + " " + Str( ( QuotStk->Required - QuotStk->Received ), 9, 2 );
            + " " + QuotStk->Invno;
            + "             " + Str( RecNo(), 6 ) )
        SKIP ALIAS QuotStk
    ENDDO                  // Orders
    IF !Empty( aPart_ )
        Scroll()
        DispBox(  0, 1, 24, 79, 2 )
        ASort( aPart_,,, {| x, y | x < y } )
        anum := AChoice(  1, 3, 23, 78, aPart_, "", "AFUNC" )  // AFUNC in XLP_Init
        IF LastKey() = 27
            RETURN NIL
        ENDIF
    ENDIF                        // Empty
    mprint := ApGetN( "Do You Want to Print" )
    IF mprint = "Y"
        QuotCode()              // XLF_QU8
    ENDIF

    RETURN

// ***----------- End of OrdOutQuot

// **----------------   End of CHRIORD3.PRG
