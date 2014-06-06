// * JK  29-08-10 20:56:45
// **
/*  Program.....:                  AAS_PART.PRG
    Authors.....: J.Kirby
    Date........: 01/06/1999
    Functions...: Mu_SPart(), ProfNated, ProfNatLK, CatConsN,  CatConsP
                : IvcText
*/

// (c) Copyright 1999 by Kirby Christchurch.

FUNCTION Mu_SPart( nc, ncl )

    DO WHILE .T.

        nselect  := 0
        nc       := ncl * 2
        Scroll(  3, nc, 21, 78 )
        DispBox( 4, nc, 21, nc + ncl )
        Scroll(  3, nc + 4, 5, nc + ( ncl - 4 ) )
        DispBox( 3, nc + 4, 5, nc + ( ncl - 4 ) )
        @  4, nc + ( ncl / 2 ) -( Len( RTrim( Menu2->CH_L2Pahd ) ) / 2 );
            SAY RTrim( Menu2->CH_L2Pahd )
        @  7, nc + 2 PROMPT "1."
        @ 20, nc + 2 PROMPT Menu->CH_Main + "   "
        nc := ncl
        MENU TO nselect
        DO CASE
        CASE nselect == 2 .OR. LastKey() == 27
            EXIT
        CASE nselect == 1
            SAVE SCREEN TO holdscrn
            // **          PartStk()
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 4
            SAVE SCREEN TO holdscrn
            mcodeno := Space( 8 )
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 6
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
        CASE nselect == 7
            SAVE SCREEN TO holdscrn
            RESTORE SCREEN FROM holdscrn
        ENDCASE
    ENDDO

    RETURN NIL

// ****  End of Mu_SPart

// **-------------------------------------------------------------------------

FUNCTION IvcText()

    SELECT Part
    SET ORDER TO 1                              // Partnum
    mfind := "ZZTEXT" + LTrim( Str( LastRec() ) )
    SEEK mfind
    ApFLock( 3 )
    IF !Found()
        APPEND BLANK
        // ****   Part->Partnum   := "ZZ"+TRIM( Name->Codeno )+LTRIM( STR( LASTREC() ) )
        Part->Partnum   := "ZZTEXT" + LTrim( Str( LastRec() ) )
    ELSE
        APPEND BLANK
        Part->Partnum   := "ZZTEXT" + LTrim( Str( LastRec() ) );
            + Trim( Control->Lastcheq )
    ENDIF
    Part->Catno     := "AA-TEXT  "
    Part->PartId    := "TEXT     "
    Part->BoughtOut := "N"
    Part->Codeno    := Control->U_Codeno
    Part->Date      := Date()
    Part->Unit      := "Each"
    UNLOCK
    Scroll(  17, 0, 24, 80 )
    DispBox( 17, 1, 24, 79, 2 )
    mdesc    := Part->Desc
    mdetail  := Part->Detail
    mdetail1 := Part->Detail1
    mdetail2 := Part->Detail2
    mdetail3 := Part->Detail3
    @ 18, 10 SAY "Text Desc" GET mdesc
    @ 19, 20                 GET mdetail
    @ 20, 20                 GET mdetail1
    @ 21, 20                 GET mdetail2
    @ 22, 20                 GET mdetail3
    @ 23, 10 SAY Part->Partnum
    READ
    ApRLock( 3 )
    Part->Desc    := mdesc
    Part->Detail  := mdetail
    Part->Detail1 := mdetail1
    Part->Detail2 := mdetail2
    Part->Detail3 := mdetail3
    UNLOCK
    COMMIT
    mpartnum := Part->Partnum

    RETURN( mpartnum )

// *---------------------------------------------------------------------*

FUNCTION ProfNated()

    cheading  := "View  Existing  Suppliers"
    mcontinue := mdelete := mok := "Y"
    DO WHILE mcontinue == "Y"
        Scroll()
        DispBox(  0, 1, 2, 79, 2 )
        @  1, 40 -( Len( cheading ) / 2 ) SAY cheading
        dmm := SubStr( DToS( Date() ), 5, 2 )
        DispBox(  11, 1, 13, 79, 2 )
        @ 12, 20 SAY "Select Month :" GET dmm PICTURE "99"
        dyy := SubStr( DToS( Date() ), 1, 4 )
        @ 12, Col() + 4 SAY "Year :" GET dyy PICTURE "9999"
        READ
        IF LastKey() == 27
            RETURN NIL
        ENDIF
        Scroll( 11, 0, 15, 80 )
        dyymm := dyy + dmm
        nrecno := 0
        aPart_ := {}
        SELECT ProfNat
        IF LastRec() != 0
            ntotal := 0
            GOTO TOP
            DO WHILE  ProfNat->( !Eof() )
                IF SubStr( DToS( ProfNat->PDate ), 1, 6 ) != dyymm
                    SKIP ALIAS ProfNat
                    LOOP
                ENDIF
                SELECT Part
                SEEK ProfNat->Partnum
                SELECT ProfNat
                ntotal += ProfNat->Qty;
                    // ( ( ProfNat->Cost*( 1-ProfNat->Discount/100 )*100 )/100 )
                AAdd( aPart_, ProfNat->Codeno + " " + Str( Qty,8,2 );
                    + " " + SubStr( ProfNat->Partnum, 1, 8 );
                    + " " + SubStr( Part->Desc, 1, 19 );
                    + " " + Str( ProfNat->Cost, 6, 2 );
                    + " " + Str( ProfNat->Discount, 4 );
                    + " " + DToC( ProfNat->PDate );
                    + " " + ProfNat->Ordnum;
                    + "     " + Str( RecNo() ) )
                SKIP ALIAS ProfNat
            ENDDO
            DispBox( 3, 1, 23, 79, 2 )
            @ 24, 25 SAY "Total Received ="
            @ 24, 43 SAY ntotal PICTURE "$9999,999.99"
            IF !Empty( aPart_ )
                ASort( aPart_,,, {| x, y | x < y } )
                anum   := AChoice( 4, 3, 22, 77, aPart_,, "AFUNC" )
                nrecno := Val( Right( aPart_[ anum ],6 ) )
            ELSE
                @ 14, 20 SAY "--- No Suppliers This Month ---"
                WAIT
                LOOP
            ENDIF
        ENDIF
        Scroll(  3, 0, 24, 80  )
        DispBox( 3, 1, 19, 79, 2 )
        GOTO nrecno
        nl := 4
        SELECT Part
        SEEK ProfNat->Partnum
        @ nl, 10 SAY Part->Desc
        nl++
        @ nl, 10 SAY Part->Detail
        SELECT ProfNat
        nl += 2
        @ nl, 10      SAY "Supply Date " + DToC( ProfNat->PDate )
        @ nl, Col() + 2 SAY "Pack # " + ProfNat->Packno
        nl += 2
        @ nl, 10 SAY "  Invno " + ProfNat->Invno
        nl += 2
        @ nl, 10 SAY "Amount"
        @ nl, 18 SAY ProfNat->Amount PICTURE "9999999.99"
        @ nl, 30 SAY "Cost"
        @ nl, 35 SAY ProfNat->Cost PICTURE "9999999.99"
        @ nl, Col() + 2 SAY "Qty  " + Str( ProfNat->Qty )
        nl += 2
        @  nl, 10      SAY "Partnum  " + ProfNat->Partnum PICTURE "@!"
        @  nl, Col() + 2 SAY "Codeno   " + ProfNat->Codeno  PICTURE "@!"
        nselect := 0
        DispBox( 20, 1, 24, 79, 2 )
        @ 22, 15      PROMPT "Edit"
        @ 22, Col() + 3 PROMPT "Delete"
        @ 22, Col() + 3 PROMPT "Another"
        MENU TO nselect
        DO CASE
        CASE LastKey() == 27
            RETURN
        CASE nselect == 1
            ProfNatLk()                    // Below
        CASE nselect == 2
            Scroll(  19, 0, 24, 80  )
            mok := "N"
            cstring := Trim( Message->Suredel )
            ApCheck( cstring, mok )                     // AppX.PRG
            IF LastKey() == 27
                RETURN
            ENDIF
            IF mok == "Y"
                mdelete := "D"
                SELECT ProfNat
                ApRLock( 3 )
                DELETE
                UNLOCK
            ENDIF
            mcontinue := "Y"
        CASE nselect == 3
            mcontinue := "Y"
        ENDCASE
    ENDDO

    RETURN

// **---- End of ProfNated()

// *---------------------------------------------------------------------*

FUNCTION ProfNatLk()

    Scroll(  3, 0, 24, 80 )
    DispBox( 3, 1, 19, 79, 2 )
    nl := 4
    SELECT Part
    SEEK ProfNat->Partnum
    @  nl, 10 SAY Part->Desc
    nl++
    @ nl, 10 SAY Part->Detail
    SELECT ProfNat
    ApRLock( 3 )
    nl += 2
    @  nl, 10      SAY "Supply Date :" GET ProfNat->PDate    PICTURE "99/99/9999"
    nl += 2
    @  nl, 10      SAY "Order # :"     GET ProfNat->Ordnum   PICTURE "@X"
    @  nl, Col() + 2 SAY "Invno :"       GET ProfNat->Invno    PICTURE "@X"
    nl += 2
    @  nl, 10      SAY "Amount :"      GET ProfNat->Amount   PICTURE "9999999.99"
    @  nl, Col() + 2 SAY "Cost :"        GET ProfNat->Cost     PICTURE "9999999.99"
    @  nl, Col() + 2 SAY "Discount :"    GET ProfNat->Discount PICTURE "999.99"
    nl += 2
    @  nl, 13      SAY "Qty :"         GET ProfNat->Qty      PICTURE "99999.99"
    nl += 2
    @  nl, 10      SAY "Partnum :"     GET ProfNat->Partnum  PICTURE "@!"
    @  nl, Col() + 2 SAY "Codeno :"      GET ProfNat->Codeno   PICTURE "@!"
    nl += 2
    READ
    UNLOCK

    RETURN

// **------ End of ProfNatLk()

// **---------------------------------------------------------------------*

FUNCTION CatConsN()

    Scroll()
    SELECT Hist
    SET ORDER TO 1
    mok := "Y"
    DO WHILE mok == "Y"
        dyear := Year( Date() )
        Scroll()
        SELECT Name
        GOTO TOP
        msale := Space( 4 )
        IF Empty( msale )
            mchoice := 1
            DispBox( 6, 1, 20, 79, 2 )
            @  7, 20 SAY "Select Name Sale Group"
            @ 11, 25 PROMPT Message->Mess01
            @ 12, 25 PROMPT Message->Mess02
            @ 13, 25 PROMPT Message->Mess03
            @ 14, 25 PROMPT Message->Mess04
            @ 15, 25 PROMPT Message->Mess05
            @ 16, 25 PROMPT Message->Mess06
            @ 17, 25 PROMPT Message->Mess07
            @ 18, 25 PROMPT Message->Mess20
            @ 19, 25 PROMPT Message->Mess21
            @ 21, 25 PROMPT "Blank for All"
            MENU TO mchoice
            DO CASE
            CASE mchoice == 1
                msale := SubStr( Message->Mess01, 1, 4 )
            CASE mchoice == 2
                msale := SubStr( Message->Mess02, 1, 4 )
            CASE mchoice == 3
                msale := SubStr( Message->Mess03, 1, 4 )
            CASE mchoice == 4
                msale := SubStr( Message->Mess04, 1, 4 )
            CASE mchoice == 5
                msale := SubStr( Message->Mess05, 1, 4 )
            CASE mchoice == 6
                msale := SubStr( Message->Mess06, 1, 4 )
            CASE mchoice == 7
                msale := SubStr( Message->Mess07, 1, 4 )
            CASE mchoice == 8
                msale := SubStr( Message->Mess20, 1, 4 )
            CASE mchoice == 9
                msale := SubStr( Message->Mess21, 1, 4 )
            CASE mchoice == 10
                msale := Space( 4 )
            ENDCASE
        ENDIF         // Empty Sale
        mchoice := 1
        @  8, 43 SAY "Select Year"
        @ 12, 40 PROMPT Year( Date() ) -0
        @ 13, 40 PROMPT Year( Date() ) -1
        @ 14, 40 PROMPT Year( Date() ) -2
        @ 15, 40 PROMPT Year( Date() ) -3
        @ 16, 40 PROMPT Year( Date() ) -4
        MENU TO mchoice
        DO CASE
        CASE mchoice == 1
            dyear := Year( Date() )
        CASE mchoice == 2
            dyear := Year( Date() ) -1
        CASE mchoice == 3
            dyear := Year( Date() ) -2
        CASE mchoice == 4
            dyear := Year( Date() ) -3
        CASE mchoice == 5
            dyear := Year( Date() ) -4
        ENDCASE
        mwhere := "S"
        Scroll()
        npl := 54

        Printsel( mwhere, npl )                        // _LF_Init

        IF mwhere = "P"
            npl := 56
        ELSE
            npl := 17
        ENDIF
        npn := 1
        nl  := 4
        nrecno := 0
        @  0, 0 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + " " + Str( Year( Date() ), 5 )
        @  0, 21 SAY Trim( Control->U_Name )
        @  0, 60 SAY "Page"
        @  0, 65 SAY npn PICTURE "999"
        @  2, 22 SAY msale
        @  2, 40 SAY dyear
        SELECT Months
        GOTO 13 - Month( Date() )
        nrecno := RecNo()
        GOTO nrecno + 3
        @  4, 28 SAY Months->Name
        GOTO nrecno + 2
        @  4, 38 SAY Months->Name
        GOTO nrecno + 1
        @  4, 48 SAY Months->Name
        @  4, 58 SAY CMonth( Date() )
        @  4, 66 SAY "Total Yr Td"
        nl := 5
        ntotqty3 := ntotqty2 := ntotqty1 := ntotqty := nTotal := 0
        ntotcost3 := ntotcost2 := ntotcost1 := ntotcost := ncosttot := 0
        SELECT Name
        DO WHILE Name->( !Eof() )
            IF msale != Space( 4 )
                IF Name->Sale != msale
                    SKIP ALIAS Name
                    LOOP
                ENDIF
            ENDIF
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                nl := 4
                npn := npn + 1
                @  0, 0 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + " " + Str( Year( Date() ), 5 )
                @  0, 21 SAY Trim( Control->U_Name )
                @  0, 60 SAY "Page"
                @  0, 65 SAY npn PICTURE "999"
                @  2, 22 SAY msale
                @  2, 40 SAY dyear
                SELECT Months
                dmonth := CMonth( Date() )
                LOCATE FOR Trim( Months->Name ) = Trim( dmonth )
                nrecno := RecNo()
                GOTO nrecno + 3
                @  4, 28 SAY Months->Name
                GOTO nrecno + 2
                @  4, 38 SAY Months->Name
                GOTO nrecno + 1
                @  4, 48 SAY Months->Name
                @  4, 58 SAY CMonth( Date() )
                @  4, 66 SAY "Total Yr Td"
                nl := 5
            ENDIF
            SELECT Hist
            GOTO TOP
            SEEK Name->Codeno
            nqtytotal := nqty := nqty1 := nqty2 := nqty3 := 0
            DO WHILE Hist->Codeno = Name->Codeno .AND. Hist->( !Eof() )
                IF Hist->Stat != "I"
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                IF Year( Hist->PDate ) != dyear
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                ntotal    += Hist->Amount * Hist->Qty
                nqtytotal += Hist->Amount * Hist->Qty
                ncosttot  += Hist->Cost * Hist->Qty
                IF Month( Hist->PDate ) < ( Month( Date() ) -3 )
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                DO CASE
                CASE Month( Hist->PDate ) = ( Month( Date() ) -3 )
                    nqty3     += Hist->Amount * Hist->Qty
                    ntotqty3  += Hist->Amount * Hist->Qty
                    ntotcost3 += Hist->Cost * Hist->Qty
                CASE Month( Hist->PDate ) = ( Month( Date() ) -2 )
                    nqty2     += Hist->Amount * Hist->Qty
                    ntotqty2  += Hist->Amount * Hist->Qty
                    ntotcost2 += Hist->Cost * Hist->Qty
                CASE Month( Hist->PDate ) = ( Month( Date() ) -1 )
                    nqty1     += Hist->Amount * Hist->Qty
                    ntotqty1  += Hist->Amount * Hist->Qty
                    ntotcost1 += Hist->Cost * Hist->Qty
                CASE Month( Hist->PDate ) = ( Month( Date() ) )
                    nqty     += Hist->Amount * Hist->Qty
                    ntotqty  += Hist->Amount * Hist->Qty
                    ntotcost += Hist->Cost * Hist->Qty
                ENDCASE
                SKIP ALIAS Hist
            ENDDO                                 // EOF Hist
            IF nqtyTotal > 0
                @ nl, 0 SAY SubStr( Name->Name, 1, 25 )
                @ nl, 26 SAY nqty3     PICTURE "9999,999"
                @ nl, 36 SAY nqty2     PICTURE "9999,999"
                @ nl, 46 SAY nqty1     PICTURE "9999,999"
                @ nl, 56 SAY nqty      PICTURE "9999,999"
                @ nl, 66 SAY nqtyTotal PICTURE "9999,999.99"
                nl++
            ENDIF
            SELECT Name
            SKIP ALIAS Name
        ENDDO                                    // EOF Name
        nl++
        @ nl, 6 SAY "Total Sell less GST"
        @ nl, 26 SAY ntotqty3 PICTURE "9999,999"
        @ nl, 36 SAY ntotqty2 PICTURE "9999,999"
        @ nl, 46 SAY ntotqty1 PICTURE "9999,999"
        @ nl, 56 SAY ntotqty  PICTURE "9999,999"
        @ nl, 66 SAY nTotal   PICTURE "99999,999.99"
        nl += 2
        @ nl, 6 SAY "Total Cost"
        @ nl, 26 SAY ntotcost3 PICTURE "9999,999"
        @ nl, 36 SAY ntotcost2 PICTURE "9999,999"
        @ nl, 46 SAY ntotcost1 PICTURE "9999,999"
        @ nl, 56 SAY ntotcost  PICTURE "9999,999"
        @ nl, 66 SAY ncosttot  PICTURE "99999,999.99"
        nl++
        @ nl, 29 SAY ( ( ntotqty3 - ntotcost3 ) / ntotqty3 ) * 100 PICTURE "99999 %"
        @ nl, 39 SAY ( ( ntotqty2 - ntotcost2 ) / ntotqty2 ) * 100 PICTURE "99999 %"
        @ nl, 49 SAY ( ( ntotqty1 - ntotcost1 ) / ntotqty1 ) * 100 PICTURE "99999 %"
        @ nl, 59 SAY ( ( ntotqty - ntotcost   ) / ntotqty  ) * 100 PICTURE "99999 %"
        @ nl, 71 SAY ( ( ntotal - ncosttot    ) / ntotal   ) * 100 PICTURE "99999 %"
        nl += 2
        IF mwhere == "S"
            WAIT
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        mok := ApGetN( Message->Another + "Print out" )
    ENDDO

    RETURN NIL

// **------------ End of CatConsN()

// **---------------------------------------------------------------------*

FUNCTION CatConsP()

    ccatno := Space( 12 )
    Scroll()
    SELECT Hist
    SET ORDER TO 2
    mok := "Y"
    DO WHILE mok == "Y"
        Scroll()
        nl      := 4
        CatArray()

        mchoice := 1
        dyear := Date()
        Scroll()
        @  6, 33 SAY Cat->CatDesc COLOR "G+"
        @  8, 43 SAY "Select Year"
        @ 12, 40 PROMPT Year( Date() ) -0
        @ 13, 40 PROMPT Year( Date() ) -1
        @ 14, 40 PROMPT Year( Date() ) -2
        @ 15, 40 PROMPT Year( Date() ) -3
        @ 16, 40 PROMPT Year( Date() ) -4
        MENU TO mchoice
        DO CASE
        CASE mchoice == 1
            dyear := Year( Date() )
        CASE mchoice == 2
            dyear := Year( Date() ) -1
        CASE mchoice == 3
            dyear := Year( Date() ) -2
        CASE mchoice == 4
            dyear := Year( Date() ) -3
        CASE mchoice == 5
            dyear := Year( Date() ) -4
        ENDCASE
        mcont := ApGetY( "Do you want Profit" )
        mwhere := "S"
        npl := 54

        Scroll()

        Printsel( mwhere, npl )                        // _LF_Init

        IF mwhere = "P"
            npl := 56
        ELSE
            npl := 18
        ENDIF
        npn := 1
        SELECT Cat
        GOTO TOP
        SEEK ccatno
        @  0, 0 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
            + " " + Str( Year( Date() ), 5 )
        @  0, 21 SAY Trim( Control->U_Name )
        @  0, 60 SAY "Page"
        @  0, 65 SAY npn PICTURE "999"
        @  2, 5 SAY Cat->Catdesc
        @  2, 62 SAY dyear
        @  4, 0 SAY "Description"
        @  4, 17 SAY "Jan  Feb  Mar  Apri May  June July Aug  Sept Oct  Nov  Dec  Tot"
        nl := 5
        SELECT Part
        SET ORDER TO 2                  // Catno, Desc
        SEEK ccatno
        DO WHILE Part->Catno = ccatno .AND. Part->( !Eof() )
            IF nl > npl
                IF mwhere == "P"
                    EJECT
                ELSE
                    WAIT
                    Scroll()
                ENDIF
                nl := 4
                npn := npn + 1
                @  0, 0 SAY Str( Day( Date() ), 3 ) + " " + CMonth( Date() );
                    + " " + Str( Year( Date() ), 5 )
                @  0, 21 SAY Trim( Control->U_Name )
                @  0, 60 SAY "Page"
                @  0, 65 SAY npn PICTURE "999"
                @  2, 5 SAY Cat->Catdesc
                @  2, 62 SAY dyear
                @  4, 0 SAY "Description"
                @ 4, 17 SAY "Jan  Feb  Mar  Apri May  June July Aug  Sept Oct  Nov  Dec  Tot"
                nl := 5

            ENDIF
            SELECT Hist
            SEEK Part->Partnum
            nqtytotal := nqty1 := nqty2 := nqty3 := nqty4 := nqty5 := nqty6 := 0
            nqty7 := nqty8 := nqty9 := nqty10 := nqty11 := nqty12 := 0
            namttotal := namt1 := namt2 := namt3 := namt4 := namt5 := namt6 := 0
            namt7 := namt8 := namt9 := namt10 := namt11 := namt12 := 0
            DO WHILE Hist->Partnum = Part->Partnum .AND. Hist->( !Eof() )
                IF Year( Hist->PDate ) != dyear
                    SKIP ALIAS Hist
                    LOOP
                ENDIF
                DO CASE
                CASE Month( Hist->PDate ) =  1
                    nqty1     += Hist->Qty
                    nqtytotal += Hist->Qty
                    namt1     += ( Hist->Amount - Hist->Cost )
                    namttotal += ( Hist->Amount - Hist->Cost )
                CASE Month( Hist->PDate ) =  2
                    nqty2     += Hist->Qty
                    nqtytotal += Hist->Qty
                    namt2     += ( Hist->Amount - Hist->Cost )
                    namttotal += ( Hist->Amount - Hist->Cost )
                CASE Month( Hist->PDate ) =  3
                    nqty3     += Hist->Qty
                    nqtytotal += Hist->Qty
                    namt3     += ( Hist->Amount - Hist->Cost )
                    namttotal += ( Hist->Amount - Hist->Cost )
                CASE Month( Hist->PDate ) =  4
                    nqty4     += Hist->Qty
                    nqtytotal += Hist->Qty
                    namt4     += ( Hist->Amount - Hist->Cost )
                    namttotal += ( Hist->Amount - Hist->Cost )
                CASE Month( Hist->PDate ) =  5
                    nqty5     += Hist->Qty
                    nqtytotal += Hist->Qty
                    namt5     += ( Hist->Amount - Hist->Cost )
                    namttotal += ( Hist->Amount - Hist->Cost )
                CASE Month( Hist->PDate ) =  6
                    nqty6     += Hist->Qty
                    nqtytotal += Hist->Qty
                    namt6     += ( Hist->Amount - Hist->Cost )
                    namttotal += ( Hist->Amount - Hist->Cost )
                CASE Month( Hist->PDate ) =  7
                    nqty7     += Hist->Qty
                    nqtytotal += Hist->Qty
                    namt7     += ( Hist->Amount - Hist->Cost )
                    namttotal += ( Hist->Amount - Hist->Cost )
                CASE Month( Hist->PDate ) =  8
                    nqty8     += Hist->Qty
                    nqtytotal += Hist->Qty
                    namt8     += ( Hist->Amount - Hist->Cost )
                    namttotal += ( Hist->Amount - Hist->Cost )
                CASE Month( Hist->PDate ) =  9
                    nqty9     += Hist->Qty
                    nqtytotal += Hist->Qty
                    namt9     += ( Hist->Amount - Hist->Cost )
                    namttotal += ( Hist->Amount - Hist->Cost )
                CASE Month( Hist->PDate ) = 10
                    nqty10    += Hist->Qty
                    nqtytotal += Hist->Qty
                    namt10    += ( Hist->Amount - Hist->Cost )
                    namttotal += ( Hist->Amount - Hist->Cost )
                CASE Month( Hist->PDate ) = 11
                    nqty11    += Hist->Qty
                    nqtytotal += Hist->Qty
                    namt11    += ( Hist->Amount - Hist->Cost )
                    namttotal += ( Hist->Amount - Hist->Cost )
                CASE Month( Hist->PDate ) = 12
                    nqty12    += Hist->Qty
                    nqtytotal += Hist->Qty
                    namt12    += ( Hist->Amount - Hist->Cost )
                    namttotal += ( Hist->Amount - Hist->Cost )
                ENDCASE
                SKIP ALIAS Hist
            ENDDO
            // **        IF nqtytotal > 0
            IF SubStr( Control->U_Name, 1, 4 ) = "CHRI"
                @ nl, 0 SAY SubStr( Part->Partnum, 1, 13 )
            ELSE
                @ nl, 0 SAY SubStr( Part->Desc, 1, 13 )
            ENDIF
            @ nl, 15 SAY nqty1  PICTURE "9999"
            @ nl, 19 SAY nqty2  PICTURE "9999"
            @ nl, 25 SAY nqty3  PICTURE "9999"
            @ nl, 30 SAY nqty4  PICTURE "9999"
            @ nl, 35 SAY nqty5  PICTURE "9999"
            @ nl, 40 SAY nqty6  PICTURE "9999"
            @ nl, 45 SAY nqty7  PICTURE "9999"
            @ nl, 50 SAY nqty8  PICTURE "9999"
            @ nl, 55 SAY nqty9  PICTURE "9999"
            @ nl, 60 SAY nqty10 PICTURE "9999"
            @ nl, 65 SAY nqty11 PICTURE "9999"
            @ nl, 70 SAY nqty12 PICTURE "9999"
            @ nl, 74 SAY nqtytotal PICTURE "9999"
            nl++
            IF mcont = "Y"
                @ nl, 0 SAY "Profit"
                @ nl, 7 SAY namttotal PICTURE "9999,999"
                @ nl, 15 SAY namt1  PICTURE "9999"
                @ nl, 19 SAY namt2  PICTURE "9999"
                @ nl, 25 SAY namt3  PICTURE "9999"
                @ nl, 30 SAY namt4  PICTURE "9999"
                @ nl, 35 SAY namt5  PICTURE "9999"
                @ nl, 40 SAY namt6  PICTURE "9999"
                @ nl, 45 SAY namt7  PICTURE "9999"
                @ nl, 50 SAY namt8  PICTURE "9999"
                @ nl, 55 SAY namt9  PICTURE "9999"
                @ nl, 60 SAY namt10 PICTURE "9999"
                @ nl, 65 SAY namt11 PICTURE "9999"
                @ nl, 70 SAY namt12 PICTURE "9999"
                nl++
            ENDIF                               // mcont
            SELECT Part
            SKIP ALIAS Part
        ENDDO
        IF mwhere == "S"
            mok := "N"
            DO WHILE mok = "N"
                mok := ApReadN()
            ENDDO
        ELSE
            EndPrint()
        ENDIF
        mok := ApGetN( Message->Another + "Print out" )
    ENDDO
    SELECT Hist
    SET ORDER TO 1

    RETURN NIL

// **------------ End of CatConsP()

// *** ----------- END OF FILE    AAS_PART.PRG
