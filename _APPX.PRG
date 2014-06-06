// ** JK  11-09-11 06:00:01 ,

// ** PAWILK10 04-10-2013 Add PathError function to display a suitable error message
/* Program ......:                   _APPX.PRG

   Authors.......: Thomas Leylan, John Kirby
   Date..........: 24/12/94

   Procedures....: BeforeMain, AfterMain
   Functions.....: Main, ApAbout, ApFLock, ApRLock, ApReadN, ApQuit
                   ApCheck, ApGetN, ApGetY, ApBye, Wipe, ApError, pathError
                   PressedEsc
   Static Funcs..: InitColorSystem, InitSettings, InitDebugging, LockRecord
                   ChooseButton, Shadow, BoxShow, BoxColorN, BoxColorW
                   Disp3DEffect, DispTitle, DispShadow, BoxHide
                   BoxSay, BoxSayInColumn, BoxGet, BtnShow, BtnHide
                   BtnSet, CreateTitledButton, BtnCreate, BtnTitle, BtnPos
                   BtnGet, BtnEnter, DimButton, NormalButton, ApColor, GetColors
*/

#include "box.ch"
#include "inkey.ch"
#include "setcurs.ch"

#include "_apbox.ch"
#include "_apbtn.ch"
#include "_appx.ch"

REQUEST HB_GT_WIN_DEFAULT

// *-------------------------------------------------------------------

FUNCTION initAppx( cArgs )

    /* set dos error code */
    ErrorLevel( 1 )

    InitColorSystem( cArgs )
    InitSettings()
    InitDebugging()

    /* turn off default "help" */
    SetKey( K_F1, NIL )

    /* release the only PUBLIC variable */
    // **   RELEASE getlist

    // **   SCROLL()

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION InitColorSystem( cArgs )

    LOCAL nSet, nAt

    cArgs := IF( cArgs == NIL, "", Upper( cArgs ) )

    IF ( ( nAt := At( "-C", cArgs ) ) > 0 )
        nSet := Val( SUBS( cArgs, nAt + 2 ) )
    ELSE
        IF ( ( nSet := Val( GetEnv( "AOM_COLOR" ) ) ) == 0 )
            nSet := IF( IsColor(), 3, 1 )
        ENDIF
    ENDIF

    ApColor( NIL, GetColors( nSet ) )

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION InitSettings( cArgs )

    LOCAL xExact, xScore, xCursor, xBlink, xDeleted

    /* initialize */

    // **   xExact := SET( _SET_EXACT, _ON )
    // **   xScore := SET( _SET_SCOREBOARD, _OFF )
    xCursor := SetCursor( SC_NORMAL )

    // **   xCursor := SETCURSOR( SC_SPECIAL1 )
    SetCursor( xCursor )

    xBlink := SetBlink( _OFF )

    xDeleted := Set( _SET_DELETED, _ON )

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION InitDebugging( cArgs )

    LOCAL xCancel

    /* turn on Alt-C (cancel) if DEBUG set */
    xCancel := SetCancel( !( Empty( GetEnv( "AOM_DEBUG" ) ) ) )

    /* turn on Alt-D (debugger) if DEBUG set */
    AltD( IF( Empty( GetEnv( "AOM_DEBUG" ) ), 0, 1 ) )

    RETURN NIL

// *-------------------------------------------------------------------

FUNCTION ApAbout()

    LOCAL aBox := { 8, 17, 9, 45, ;
        B_SINGLE + " ", ApColor( CS_DBOX ), " Welcome ", 1, "" }

    BoxShow( aBox )

    BoxSay( aBox, 2, NIL, "Chozen DataTech Valid for 3 Month" )
    BoxSay( aBox, 4, NIL, "      Test Version Zone/Locate   " )
    BoxSay( aBox, 6, NIL, "      Copyright (c) 21/02 2010   " )

    Inkey( 2 )

    BoxHide( aBox )

    RETURN NIL

// *-------------------------------------------------------------------

FUNCTION ApFLock( nSec )

    LOCAL lRet := .F.

    nSec := 5    // Control->Sec

    BEGIN SEQUENCE
        IF NetErr()
            ? "ERROR : Cannot Add Record to File"
            Inkey( 30 )
            BREAK
        ENDIF   // NETERR
    END SEQUENCE

    WHILE ( ( nSec == 0 ) .OR. ( nSec > 0 ) )

        DO WHILE !FLock()
            Alert( "Someone Using this File  ASK WHO", { "Try Again" } )
            IF LastKey() = 27
                RETURN NIL
            ENDIF
            Inkey()
        ENDDO

        IF ( lRet := !( NetErr() ) )
            nSec := -1

        ELSE
            PAUSE( .5 )
            nSec -= .5

        ENDIF

    ENDDO

    RETURN lRet // lock status

// *-------------------------------------------------------------------

FUNCTION ApRLock( nSec )

    LOCAL lRet := .F.

    nSec := 5    // Control->Sec

    BEGIN SEQUENCE
        IF NetErr()
            ? "ERROR : Cannot Add Record to File"
            Inkey( 30 )
            BREAK
        ENDIF   // NETERR
    END SEQUENCE

    WHILE ( nSec >= 0 )
        LockRecord()
        IF lRet := !( NetErr() )
            EXIT
        ELSE
            PAUSE( .5 )
            nSec -= .5
        ENDIF
    ENDDO

    RETURN lRet        // lock status

// *---------------------------------------------------------------------*

STATIC FUNCTION LockRecord()

    DO WHILE !RLock()
        Alert( "Someone Using Record  ASK WHO", { "Try Again" } )
        IF PressedEsc()
            RETURN NIL
        ENDIF
        Inkey()
    ENDDO

    RETURN NIL

// *---------------------------------------------------------------------*

FUNCTION ApReadN()

    LOCAL aBox := { 20, 17, 4, 46, ;
        B_SINGLE + " ", ApColor( CS_DBOX ), "  " + " Confirm Read ", 1, "" }

    LOCAL aBtn := { { { 21, 26, "  YES   ", 3, "" },;
        { 21, 42, "   NO   ", 4, "" } }, ;
        BN_CHARS, ;
        "YN", ;
        ApColor( CS_BUNS ), ;
        ApColor( CS_BKEY ), ;
        BN_DIM, 2, K_LEFT, K_RIGHT }

    SetCursor( SC_NONE )
    Scroll( 20, 17, 24, 46 )

    ChooseButton( aBox, aBtn )

    SetCursor( SC_NORMAL )

    IF aBtn[ BN_POSI ] == 1
        RETURN "Y"
    ENDIF

    RETURN "N"

// *-------------------------------------------------------------------

STATIC FUNCTION ChooseButton( aBox, aBtn, aSay_ )

    LOCAL nLeft, nTop, cString

    BoxShow( aBox )
    BtnShow( aBtn )

    IF aSay_ != NIL
        nLeft := aSay_[ 1 ]
        nTop := aSay_[ 2 ]
        cString := aSay_[ 3 ]
        BoxSay( aBox, nLeft, nTop, cString )
    ENDIF

    BtnGet( aBtn )

    BtnHide( aBtn )
    BoxHide( aBox )

    RETURN NIL

// *-------------------------------------------------------------------

FUNCTION ApQuit( cstring )

    LOCAL aBox := { 8, 17, 9, 46, ;
        B_SINGLE + " ", ApColor( CS_DBOX ), Trim( Control->O_Head ), 1, "" }
    LOCAL aBtn := { { { 10, 48, "  Cont   ", 3, "" },;
        { 13, 48, "  Exit   ", 3, "" } }, ;
        BN_CHARS, ;
        "CE", ;
        ApColor( CS_BUNS ), ;
        ApColor( CS_BKEY ), ;
        BN_DIM, 1, K_UP, K_DOWN }

    SetCursor( SC_NONE )

    ChooseButton( aBox, aBtn, { 3, 4, cstring } )

    SetCursor( SC_NORMAL )

    IF ( aBtn[ BN_POSI ] == 2 )
        RETURN "Y"
    ENDIF

    RETURN "N"

// *-------------------------------------------------------------------

FUNCTION ApCheck( cstring )

    LOCAL aBox := { 20, 17, 4, 46, ;
        B_SINGLE + " ", ApColor( CS_DBOX ), "  " + cstring, 1, "" }

    LOCAL aBtn := { { { 21, 26, "  Delete  ", 3, "" },;
        { 21, 42, "    NO    ", 5, "" } }, ;
        BN_CHARS, ;
        "DN", ;
        ApColor( CS_BUNS ), ;
        ApColor( CS_BKEY ), ;
        BN_DIM, 2, K_LEFT, K_RIGHT }

    SetCursor( SC_NONE )

    ChooseButton( aBox, aBtn, { 3, 4, cstring } )

    SetCursor( SC_NORMAL )

    IF ( aBtn[ BN_POSI ] == 1 )
        RETURN "Y"
    ENDIF

    RETURN "N"

// *---------------------------------------------------------------------*

FUNCTION ApGetN( cstring )

    LOCAL aBox := { 20, 17, 4, 46, ;
        B_SINGLE + " ", ApColor( CS_DBOX ), "  " + cstring, 1, "" }

    LOCAL aBtn := { { { 21, 26, "  YES   ", 3, "" },;
        { 21, 42, "   NO   ", 4, "" } }, ;
        BN_CHARS, ;
        "YN", ;
        ApColor( CS_BUNS ), ;
        ApColor( CS_BKEY ), ;
        BN_DIM, 2, K_LEFT, K_RIGHT }

    SetCursor( SC_NONE )
    Scroll( 20, 17, 24, 46 )

    ChooseButton( aBox, aBtn )

    SetCursor( SC_NORMAL )

    IF ( aBtn[ BN_POSI ] == 1 )
        RETURN "Y"
    ENDIF

    RETURN "N"

// *-------------------------------------------------------------------

FUNCTION ApGetY( cstring )

    LOCAL aBox := { 20, 17, 4, 46, ;
        B_SINGLE + " ", ApColor( CS_DBOX ), "  " + cstring, 1, "" }

    LOCAL aBtn := { { { 21, 26, "  YES   ", 3, "" },;
        { 21, 42, "   NO   ", 4, "" } }, ;
        BN_CHARS, ;
        "YN", ;
        ApColor( CS_BUNS ), ;
        ApColor( CS_BKEY ), ;
        BN_DIM, 1, K_LEFT, K_RIGHT }

    SetCursor( SC_NONE )
    Scroll( 20, 17, 24, 46 )

    ChooseButton( aBox, aBtn )

    SetCursor( SC_NORMAL )

    IF aBtn[ BN_POSI ] == 1
        RETURN "Y"
    ENDIF

    RETURN "N"

// *-------------------------------------------------------------------

FUNCTION ApBye()

    LOCAL xCursor := SetCursor( SC_NONE )

    /* credits */
    @  6, 0 SAY "Thank You for Using       " + Control->O_Head
    @ 10, 0 SAY Control->O_Name
    @ 11, 0 SAY Control->O_Add1
    @ 12, 0 SAY Control->O_Add2
    @ 13, 0 SAY Control->O_Add3
    @ 14, 0 SAY Control->O_Add4
    @ 16, 0 SAY "Phone " + Control->O_Phone
    @ 17, 0 SAY "Fax   " + Control->O_Fax
    @ 23, 0

    SetCursor( xCursor )

    RETURN NIL

// *-------------------------------------------------------------------

FUNCTION Wipe( nDelay )

    LOCAL nCnt, nMax

    FOR nCnt := 0 TO 24

        Scroll( 0, 0, 24, 79, -1, 4 )

      /* nMax, the calculated ending time in seconds must be
         MOD 86399 (the number of seconds elapsed at midnight)
         or an endless loop will result if you're unlucky
         enough to run this near midnight */

        nMax := ( ( Seconds() + nDelay ) % 86399 )
        WHILE ( Seconds() <= nMax ); ENDDO
    NEXT

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION ApError( cMsg )

    LOCAL aBox := { 8, 17, 9, 46, ;
        B_SINGLE + " ", ApColor( CS_DBOX ), " Error ", 1, "" }

    LOCAL aBtn := { { { 14, 34, "    Ok    ", 5, "" } }, ;
        BN_CHARS, ;
        "O", ;
        ApColor( CS_BUNS ), ;
        ApColor( CS_BKEY ), ;
        BN_DIM, 1, NIL, NIL }

    ChooseButton( aBox, aBtn, { 2, NIL, cMsg } )

    RETURN NIL

// *-------------------------------------------------------------------

FUNCTION PathError()

    LOCAL aBox := { 10, 17, 7, 45, ;
        B_SINGLE + " ", ApColor( CS_DBOX ), " DOS Error 3: Path Not Found ", 1, "" }

    BoxShow( aBox )

    BoxSay( aBox, 1, NIL, "The path can not be found." )
    BoxSay( aBox, 3, NIL, "Please verify that the path exists," )
    BoxSay( aBox, 4, NIL, "and press any key to try again ..." )

    Inkey( 0 )

    BoxHide( aBox )

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION Shadow( nTop, nLeft, nBottom, nRight )

    Scroll( nTop + 1, nRight + 1, nBottom, nRight + 1, 0, 0 )
    Scroll( nBottom + 1, nLeft + 1, nBottom + 1, nRight + 1, 0, 0 )

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION BoxShow( aSelf )

    LOCAL nTop    := aSelf[ BX_TOP ], nLeft   := aSelf[ BX_LEFT ]
    LOCAL nLength := aSelf[ BX_HEIGHT ], nWidth  := aSelf[ BX_WIDTH ]
    LOCAL nBottom := ( nTop + nLength ), nRight  := ( nLeft + nWidth )

    LOCAL nShadow := IF( aSelf[ BX_SHADOW ] == 0, 0, 1 )
    LOCAL nCenter := nLeft + ( ( nWidth - Len( aSelf[ BX_TITLE ] ) ) / 2 )

    LOCAL cColorN := BoxColorN( aSelf[ BX_COLOR ] )
    LOCAL cColorW := BoxColorW( aSelf[ BX_COLOR ] )

    // save the background
    aSelf[ BX_IMAGE ] := SaveScreen( nTop, nLeft, nBottom + nShadow, nRight + nShadow )

    DispBegin()

    DispBox( nTop, nLeft, nBottom, nRight, aSelf[ BX_FRAME ], cColorN )
    Disp3DEffect( nTop, nBottom, nLeft, nRight, cColorW, aSelf[ BX_FRAME ] )
    DispTitle( aSelf[ BX_TITLE ], nTop, nCenter, aSelf[ BX_COLOR ] )

    DispEnd()

    DispShadow( nTop, nLeft, nBottom, nRight, nShadow )

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION BoxColorN( cBoxColor )

    LOCAL cSub := SUBS( cBoxColor, At( "/", cBoxColor ) )
    LOCAL cBak := SUBS( cSub, 2, At( ",", cSub ) )
    LOCAL cColorN := IF( "N" $ cBak, "W", "N" ) + cSub

    RETURN cColorN

// *-------------------------------------------------------------------

STATIC FUNCTION BoxColorW( cBoxColor )

    LOCAL cSub := SUBS( cBoxColor, At( "/", cBoxColor ) )
    LOCAL cBak := SUBS( cSub, 2, At( ",", cSub ) )
    LOCAL cColorW := "+W" + cSub

    RETURN cColorW

// *-------------------------------------------------------------------

STATIC FUNCTION Disp3DEffect( nTop, nBottom, nLeft, nRight, cColorW, frame )

    LOCAL nCnt
    LOCAL xDelta := nRight - nLeft - 1

    @ nTop, nRight SAY SUBS( frame, 3, 1 ) COLOR cColorW

    FOR nCnt := nTop + 1 TO nBottom - 1
        @ nCnt, nRight SAY SUBS( frame, 4, 1 ) COLOR cColorW
    NEXT

    @ nBottom, nRight SAY SUBS( frame, 5, 1 ) COLOR cColorW

    @ nBottom, nLeft + 1 SAY REPL( SUBS( frame, 6, 1 ), ;
        nRight - nLeft - 1 ) COLOR cColorW

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION DispTitle( cTitle, nTop, nCenter, cColor )

    IF !Empty( cTitle )
        @ nTop, nCenter SAY cTitle COLOR cColor
    ENDIF

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION DispShadow( nTop, nLeft, nBottom, nRight, nShadow )

    IF ( nShadow == 0 )
        Shadow( nTop, nLeft, nBottom, nRight )
    ENDIF

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION BoxHide( aSelf )

    LOCAL nTop    := aSelf[ BX_TOP ]
    LOCAL nLeft   := aSelf[ BX_LEFT ]

    LOCAL nLength := aSelf[ BX_HEIGHT ]
    LOCAL nWidth  := aSelf[ BX_WIDTH ]

    LOCAL nBottom := ( nTop + nLength )
    LOCAL nRight  := ( nLeft + nWidth )

    LOCAL nShadow := IF( aSelf[ BX_SHADOW ] == 0, 0, 1 )

    /* restore the background */
    RestScreen( nTop, nLeft, nBottom + nShadow, nRight + nShadow, ;
        aSelf[ BX_IMAGE ] )

    /* reclaim the memory */
    aSelf[ BX_IMAGE ] := ""

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION BoxSay( aSelf, nRow, nCol, cStr )

    LOCAL nTop    := aSelf[ BX_TOP ]
    LOCAL nLeft   := aSelf[ BX_LEFT ]

    LOCAL nHeight := aSelf[ BX_HEIGHT ]
    LOCAL nWidth  := aSelf[ BX_WIDTH ]

    LOCAL nBottom := ( nTop + nHeight )
    LOCAL nRight  := ( nLeft + nWidth )

    nRow += ( nTop + 1 )

    /* if message within box (vertically) */
    IF ( nRow > nTop ) .AND. ( nRow < nBottom )

        /* center message if column not supplied */
        IF ( nCol == NIL )
            nCol := ( ( nWidth - 1 - Len( cStr ) ) / 2 )
        ENDIF

        nCol += ( nLeft + 1 )
        BoxSayInColumn( nrow, nCol, nLeft, nRight, cStr, aSelf[ BX_COLOR ] )

    ENDIF

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION BoxSayInColumn( nrow, nCol, nLeft, nRight, cStr, cColor )

    LOCAL nBeg, nEnd, nS1, nS2

    /* calculate beginning and ending columns */
    nBeg := Max( nCol, nLeft + 1 )
    nEnd := Min( nCol + Len( cStr ), nRight )

    /* if message begins within box (horizontally) */
    IF ( nBeg < nEnd )

        /* truncate message if necessary */
        nS1 := ( nBeg - nCol ) + 1
        nS2 := Min( nEnd - nBeg, Len( cStr ) )

        DispBegin()
        @ nRow, nBeg SAY SUBS( cStr, nS1, nS2 ) COLOR cColor
        DispEnd()

    ENDIF

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION BoxGet( aSelf, aGet, aDat )

    LOCAL xCursor := SetCursor( SC_NORMAL )

    // **   LOCAL xCursor := SETCURSOR( SC_SPECIAL1 )   // FULL BOX

    ReadModal( aGet )

    SetCursor( xCursor )

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION BtnShow( aSelf )

    LOCAL nTop, nLeft, nBottom, nRight

    LOCAL nEle
    LOCAL nMax := Len( aSelf[ BN_ITEMS ] )

    FOR nEle := 1 TO nMax

        nTop := aSelf[ BN_ITEMS, nEle, BN_ROW ]
        nBottom := nTop + 2

        nLeft := aSelf[ BN_ITEMS, nEle, BN_COL ]
        nRight := nLeft + ( Len( aSelf[ BN_ITEMS, nEle, BN_NAME ] ) + 1 )

        aSelf[ BN_ITEMS, nEle, BN_IMAGE ] := ;
            SaveScreen( nTop, nLeft, nBottom, nRight )

    NEXT

    BtnSet( aSelf, NIL )

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION BtnHide( aSelf )

    LOCAL nTop, nLeft, nBottom, nRight

    LOCAL nEle
    LOCAL nMax := Len( aSelf[ BN_ITEMS ] )

    FOR nEle := 1 TO nMax

        nTop := aSelf[ BN_ITEMS, nEle, BN_ROW ]
        nBottom := nTop + 2

        nLeft := aSelf[ BN_ITEMS, nEle, BN_COL ]
        nRight := nLeft + ( Len( aSelf[ BN_ITEMS, nEle, BN_NAME ] ) + 1 )

        /* restore the image */

        RestScreen( nTop, nLeft, nBottom, nRight, ;
            aSelf[ BN_ITEMS, nEle, BN_IMAGE ] )

        /* reclaim the memory */

        aSelf[ BN_ITEMS, nEle, BN_IMAGE ] := ""

    NEXT

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION BtnSet( aSelf, nEle )

    LOCAL nBeg := IF( nEle == NIL, 1, nEle )
    LOCAL nMax := IF( nEle == NIL, Len( aSelf[ BN_ITEMS ] ), nEle )

    DispBegin()

    FOR nEle := nBeg TO nMax
        CreateTitledButton( aSelf, nEle  )
    NEXT

    DispEnd()

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION CreateTitledButton( aSelf, nEle )

    LOCAL cName := aSelf[ BN_ITEMS, nEle, BN_NAME ]
    LOCAL nWide := Len( cName )
    LOCAL nTop := aSelf[ BN_ITEMS, nEle, BN_ROW ]
    LOCAL nBottom := nTop + 2
    LOCAL nLeft := aSelf[ BN_ITEMS, nEle, BN_COL ]
    LOCAL nRight := nLeft + ( nWide + 1 )
    LOCAL cColorN := BoxColorN( aSelf[ BN_CLRN ] )
    LOCAL cColorW := BoxColorW( aSelf[ BN_CLRN ] )
    LOCAL isActiveButton := nEle == aSelf[ BN_POSI ]

    LOCAL cKey := SUBS( cName, aSelf[ BN_ITEMS, nEle, BN_SPOT ], 1 )
    LOCAL nSpot := aSelf[ BN_ITEMS, nEle, BN_SPOT ] + nLeft

    cName := LTrim( RTrim( cName ) )

    DO CASE
    CASE ( aSelf[ BN_MODE ] == BN_DIM )
        BtnCreate( nTop, nBottom, nLeft, nRight, aSelf[ BN_FRAME ], cColorN, cColorW )
        BtnTitle( cName, nTop, nLeft, nWide, aSelf[ BN_CLRN ] )
    CASE ( aSelf[ BN_MODE ] == BN_NORM )
        BtnCreate( nTop, nBottom, nLeft, nRight, aSelf[ BN_FRAME ], cColorW, cColorN )
        BtnTitle( cName, nTop, nLeft, nWide, aSelf[ BN_CLRN ], isActiveButton )

        /* draw highlighted key */
        @ nTop + 1, nSpot SAY cKey COLOR aSelf[ BN_CLRK ]
    ENDCASE

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION BtnCreate( nTop, nBottom, nLeft, nRight, frame, cColorL, cColorH )

    LOCAL nCnt

    DispBox( nTop, nLeft, nBottom, nRight, frame, cColorL )

    /* 3-D effect */

    @ nTop, nRight SAY SUBS( frame, 3, 1 ) COLOR cColorH

    FOR nCnt := nTop + 1 TO nBottom - 1
        @ nCnt, nRight SAY SUBS( frame, 4, 1 ) COLOR cColorH
    NEXT

    @ nBottom, nRight SAY SUBS( frame, 5, 1 ) COLOR cColorH

    @ nBottom, nLeft + 1 SAY REPL( SUBS( frame, 6, 1 ), ;
        nRight - nLeft - 1 ) COLOR cColorH

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION BtnTitle( cName, nTop, nLeft, nWide, cColorN, isActiveButton )

    LOCAL nPos

    IF ( isActiveButton == .T. )
        cName := "_" + cName + "_"
    ENDIF

    /* display the title */
    nPos := nLeft + ( ( nWide - Len( cName ) ) / 2 ) + 1
    @ nTop + 1, nPos SAY cName COLOR cColorN

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION BtnPos( aSelf, nPos )

    LOCAL nRet := aSelf[ BN_POSI ]

    IF !( nPos == NIL )

        DO CASE

        CASE ( nPos < 1 )
            aSelf[ BN_POSI ] := Len( aSelf[ BN_ITEMS ] )

        CASE ( nPos > Len( aSelf[ BN_ITEMS ] ) )
            aSelf[ BN_POSI ] := 1

        OTHERWISE
            aSelf[ BN_POSI ] := nPos

        ENDCASE

        /* unselect the button */
        BtnSet( aSelf, nRet )

        /* select the button */
        BtnSet( aSelf, aSelf[ BN_POSI ] )

    ENDIF

    RETURN nRet

// *-------------------------------------------------------------------

STATIC FUNCTION BtnGet( aSelf )

    LOCAL nKey

    IF ( aSelf[ BN_MODE ] == BN_DIM )
        NormalButton( aSelf )
    ENDIF

    WHILE ( .T. )
        nKey := Inkey( 0 )

        DO CASE
        CASE nKey == K_ESC                 // To Test Exit
            EXIT

        CASE nKey == aSelf[ BN_PREV ]
            BtnPos( aSelf, BtnPos( aSelf ) - 1 )

        CASE nKey == aSelf[ BN_NEXT ]
            BtnPos( aSelf, BtnPos( aSelf ) + 1 )

        CASE nKey == K_ENTER .OR. ( Upper( Chr( nKey ) ) $ aSelf[ BN_KSET ] )
            BtnEnter( nKey, aSelf )
            EXIT

        ENDCASE
    ENDDO

    DimButton( aSelf )

    RETURN nKey

// *-------------------------------------------------------------------

STATIC FUNCTION BtnEnter( nKey, aSelf )

    IF ( Upper( Chr( nKey ) ) $ aSelf[ BN_KSET ] )
        BtnPos( aSelf, At( Upper( Chr( nKey ) ),;
            aSelf[ BN_KSET ] ) )
    ENDIF

    DimButton( aSelf, aSelf[ BN_POSI ] )
    PAUSE( .25 )

    NormalButton( aSelf, aSelf[ BN_POSI ] )
    PAUSE( .25 )

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION DimButton( aSelf, nButton )

    aSelf[ BN_MODE ] := BN_DIM
    BtnSet( aSelf, nButton )

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION NormalButton( aSelf, nButton )

    aSelf[ BN_MODE ] := BN_NORM
    BtnSet( aSelf, nButton )

    RETURN NIL

// *-------------------------------------------------------------------

STATIC FUNCTION ApColor( nItem, aColors )

    STATIC aSet := NIL

    IF ( aSet == NIL )
        aSet := { "W/N,N/W,,,+W/N" }
    ENDIF

    IF !( aColors == NIL )
        aSet := aColors
    ENDIF

    nItem := Min( Max( IF( nItem == NIL, 1, nItem ), 1 ), Len( aSet ) )

    RETURN aSet[ nItem ]

// *-------------------------------------------------------------------

STATIC FUNCTION GetColors( nSet )

    STATIC aSet1 := { "W/N,N/W,,,+W/N",    "W/N",   "+W/N",  "N/W",   "W/N",  "N/W,+W/N,,,N/W",      "N/W",   "+W/W",  "W/N",  "N/W" }
    STATIC aSet2 := { "+W/B,B/W,,,+W/B",   "+W/B",  "+R/B",  "+W/BG", "W/B",  "+W/BG,+W/B,,,+W/BG",  "+W/BG", "+R/BG", "+W/B", "W/BG" }
    STATIC aSet3 := { "+W/*N,N/W,,,+W/*N", "+W/*N", "+R/*N", "+W/B",  "W/*N", "+W/*B,+W/B,,,+W/*B", "+W/*B", "+R/*B", "+W/B", "W/*B" }

    nSet := IF( nSet == NIL, IF( IsColor(), 3, 1 ), nSet )

    RETURN { aSet1, aSet2, aSet3 }[ Min( Max( nSet, 1 ), 3 ) ]

// *-------------------------------------------------------------------

FUNCTION PressedEsc()

    LOCAL escPressed := ( LastKey() == K_ESC )

    RETURN escPressed

// ******---------------------  END OF FILE _APPX.PRG
