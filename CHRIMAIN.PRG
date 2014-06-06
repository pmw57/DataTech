// **  JK 17-09-11 08:01:35

/*           ...:              CHRIMAIN.PRG
    Authors.....: J.Kirby
    Date........: 30/08/2013
                : InitFiles, ApAbout
*/

FUNCTION Main()

    InitMain()
    InitAppx()
    InitMenu()

    RETURN NIL

FUNCTION InitMain()

    InitFiles()                             // XF_Util
 	
    IF InitFiles()
        Scroll()

        DBFReinDx()                                 // CalRendx

    ENDIF

    Initenv()                                     // _LP_Init Initiates Environment

    RETURN NIL

// **--------------------------------------------------------------

FUNCTION InitMenu()

    Scroll()

    // ** ApAbout()         // AppX.PRG Shows Welcome and Conditions

    Start()                                       // MetMenu.PRG

    MENU()                                        // MetMenu.PRG

    Wipe( .01 )                                    // AppX.PRG

    // ** ApBye()          // AppX.PRG This gives Welcome and Conditions

    /* reset dos error code */
    ErrorLevel( 0 )

    SET COLOR TO W, W +

    RETURN NIL

// ******------------------ END OF FILE CHRIMain.PRG
