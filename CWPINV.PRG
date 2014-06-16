// **  JK   23-06-10 13:51:01

/*  Program.....:                  CWPINV.PRG
    Authors.....: J.Kirby
    Date........: 29/03/2000
    Functions...: WBInvAdd
*/

// (c) Copyright 1993 by Kirby Christchurch.

FUNCTION WBInvAdd( mcodeno )
    local discountAmount
    
    cappend := "N"
    mcontinue := mok := "Y"
    DO WHILE mcontinue == "Y"
        Scroll(  18, 0, 24, 80 )
        DispBox( 18, 1, 24, 79, 2 )
        @ 20, 10 SAY "The Above are Current Invoices Select if Required"
        @ 22, 10 SAY "Invoice =" GET minvno PICTURE "@KX"
        @ 22, Col() + 2 SAY "Blank for New Invoice   Esc To Quit"
        READ
        IF LastKey() == 27
            RETURN NIL
        ENDIF
        SELECT Debit
        DO CASE
        CASE minvno != Space( 6 )
            SET ORDER TO 2                        // Invno
            SEEK minvno
            IF !Found()
                cappend := "Y"
            ENDIF
            SET ORDER TO 1                         // Codeno
        CASE minvno = Space( 6 )
            SELECT Control
            ApRLock( 3 )
            minvno := Str( Control->LastIvc, 6, 0 )
            Control->LastIvc := Control->LastIvc + 1
            UNLOCK
            IF !Found()
                cappend := "Y"
            ENDIF
        ENDCASE
        IF cappend = "Y"
            SELECT Debit
            ApFLock( 3 )
            APPEND BLANK
            Debit->Invno   := minvno
            Debit->Dbdate  := Date()
            // ***      Debit->Paytype := "NS"  // Taken out not sure what it is for
            Debit->Saleno  := Control->Saleno
            Debit->Codeno := Debit->U_Codeno := mcodeno
            Debit->BranchId := cbranchId
            Debit->Stat     := "W"                            // Way Bill
            Debit->Ordnum   := Name->Remarks
            UNLOCK
        ENDIF
        mcorrect := "N"
        DO WHILE mcorrect == "N"
            Scroll(  3, 0, 24, 80 )
            DispBox( 3, 1, 18, 79, 2 )
            nl := 4
            SELECT Name
            IF Name->Overdue > 0
                @ nl, 8 SAY "Account Overdue Amount =" COLOR "R+"
                @ nl, Col() + 2 SAY Name->Overdue PICTURE "$999,999.99" COLOR "R+"
            ENDIF
            nl += 2
            SELECT Debit
            ApRLock( 3 )
            @ nl, 8      SAY "Way Bill " + Debit->Invno
            // **      @ nl,COL()+2 SAY "I=Invoice  W=W/B  J=Job" GET Debit->Stat;
            // **                       VALID( Debit->Stat $ "IWJ" ) PICTURE "@!"
            nl += 2
            @ nl, 8      SAY "Dated"    GET Debit->Dbdate   PICTURE "99/99/9999"
            @ nl, Col() + 2 SAY "Order No" GET Debit->Ordnum   PICTURE "@X"
            READ
            // **      @ nl,COL()+2 SAY "Branch"   GET Debit->BranchId PICTURE "@!"
            // **      nl+=2
            // **      @ nl, 8      SAY "Desc"     GET Debit->Est
            IF Debit->Saleno == Space( 4 )
                Debit->Saleno := Control->Saleno
            ENDIF
/*
      nl+=2
      @ nl, 8      SAY "Sale Book No "   GET Debit->Saleno PICTURE "@K!"
       READ
      minvno  := Debit->Invno
      msaleno := Debit->Saleno
      UNLOCK
      SELECT Name
       ApRLock( 3 )
      Name->Remarks := Debit->Ordnum
      UNLOCK
      SELECT SaleBook
      SEEK Debit->Saleno
      IF !FOUND()

         Sblook( @msaleno )                  // XLF_Acc

      ENDIF
      msaleno := SaleBook->Saleno
      SELECT Debit
       ApRLock( 3 )
      Debit->Saleno := msaleno
      UNLOCK
      @ nl, 8 SAY "Sale Book # "+SaleBook->Saleno+"  "+SaleBook->Sbname
*/
            mcorrect := "Y"
            // **     mcorrect := ApGetY( Message->Correct )
        ENDDO                                      // mcorrect
        npl := 16
        nl  := 6
        mgtotal := mgtaxtot := nivcTotal := 0
        manother := "Y"
        DO WHILE manother = "Y"
            mok := "Y"
            DO WHILE mok = "Y"
                SELECT Invoice
                SEEK minvno
                IF Found()

                    IvcLook( minvno )                 // ZF_Inv

                ENDIF
                Scroll(  20, 0, 24, 80 )
                DispBox( 20, 1, 24, 79, 2 )
                @ 21, 6 SAY Debit->Invno + " " + Debit->Codeno + " " + Debit->Est
                IF Debit->BranchId != Space( 2 )
                    @ 22, 6 SAY "Branch " + Debit->BranchId;
                        + " " + Trim( Branch->Name ) + " " + Trim( Branch->Add4 )
                ELSE
                    @ 21, 56      SAY "Incl GST"
                    @ 21, Col() + 2 SAY nivcTotal * ( ( Control->GSTRate / 100 ) + 1 );
                        PICTURE "$999,999.99" COLOR "G+"
                ENDIF
                nselect := 1
                @ 23, 5      PROMPT "Add Part"
                @ 23, Col() + 1 PROMPT "Add Text"
                @ 23, Col() + 1 PROMPT "Labour"
                @ 23, Col() + 2 PROMPT "No More Parts"
                @ 23, Col() + 1 PROMPT "Edit"
                @ 23, Col() + 1 PROMPT "Print"
                @ 23, Col() + 1 PROMPT "J/Card"
                @ 23, Col() + 1 PROMPT "Delete"
                @ 23, Col() + 1 PROMPT "Other"
                MENU TO nselect
                DO CASE
                CASE LastKey() == 27                 // Exit
                    RETURN NIL
                CASE nselect == 1                    // Add Part
                    mpartnum := Space( 20 )
                    SELECT Debit
                    IvcAddP( mpartnum )                          // Specific ( XF_IvcFm )
                    COMMIT
                CASE nselect == 2                    // Add Text
                    IvcText()                                     // ZSF_Inv
                    IvcAddP( mpartnum )                           // Specific ( XF_IvcFm )
                    COMMIT
                CASE nselect == 3                    // Add Labour
                    minvno  := Debit->Invno
                    mpartnum := Space( 20 )
                    IvcLabour( mpartnum )                         // ZSF_Name
                    // *** JSheet( mcodeno )
                CASE nselect == 4                    // No More Parts
                    manother := mok := "N"
                    EXIT
                CASE nselect == 5                    // Edit
                    IvcEdit( minvno )                          // ZF_Inv
                CASE nselect == 6                    // Edit
                    WBOPerInd()
                CASE nselect == 7                    // Edit
                    Namepjs( mcodeno )
                CASE nselect == 8                    // Delete
                    Scroll()
                    @ 12, 10 SAY "This will delete this Invoice in Total are you Sure"
                    mdelete := ApGetN( "Are You Sure :" )
                    IF mdelete == "Y"
                        SELECT Debit
                        ApFLock( 3 )
                        DELETE ALL FOR Invno = minvno
                        UNLOCK
                        SELECT Invoice
                        ApFLock( 3 )
                        DELETE ALL FOR Invno = minvno
                        UNLOCK
                        SELECT DebProf
                        ApFLock( 3 )
                        DELETE ALL FOR Invno = minvno
                        UNLOCK
                        SELECT Hist
                        ApFLock( 3 )
                        DELETE ALL FOR Invno = minvno
                        UNLOCK
                        RETURN NIL
                    ENDIF
                CASE nselect == 9                    // Add Labour
                    JSheet( mcodeno )
                ENDCASE
            ENDDO                               // End of more Parts
        ENDDO
        SELECT Invoice
        GO TOP
        ngtotal := ncostitem := 0
        SEEK Debit->Invno
        DO WHILE Invoice->Invno == Debit->Invno .AND. Invoice->( !Eof() )
            SELECT Invoice
            discountAmount := Invoice->Amount * ( 1 - Invoice->Discount / 100 )
            ngtotal  += ( Invoice->Qty * ( ( discountAmount * 100 )/100 ) )
            mpartnum := Invoice->Partnum
            SELECT Part
            SEEK mpartnum
            ncostitem += ( Part->Trade * Invoice->Qty )
            SELECT Invoice
            SKIP ALIAS Invoice
        ENDDO
        SELECT Debit
        ApRLock( 3 )
        IF SubStr( Name->Add5, 1, 7 ) = "NEW ZEA"
            Debit->Amount   := ngtotal * ( ( Control->GSTRate / 100 ) + 1 )
            Debit->Initamnt := ngtotal * ( ( Control->GSTRate / 100 ) + 1 )
        ELSE
            Debit->Amount   := ngtotal
            Debit->Initamnt := ngtotal
        ENDIF
        Debit->CostItem := ncostitem
        UNLOCK
        ndiscount := 0
        SELECT Control
        msaleno   := Control->Saleno
        SELECT Debit
        ApRLock( 3 )
        Debit->Paytype := Name->Paytype
        UNLOCK
        Scroll(  15, 0, 24, 80 )
        DispBox( 15, 1, 23, 79, 2 )
        @ 16, 7 SAY "Standard Payment = " + Name->PayType;
            + " " + Trim( Name->Remarks ) + "  " + Name->Charge
        // Remarks = Account # Charge = Name to charge
        DO CASE
        CASE Debit->Paytype = SubStr( Message->PayType1, 1, 2 )
            mchoice := 1
        CASE Debit->Paytype = SubStr( Message->PayType2, 1, 2 )
            mchoice := 2
        CASE Debit->Paytype = SubStr( Message->PayType3, 1, 2 )
            mchoice := 3
        CASE Debit->Paytype = SubStr( Message->PayType4, 1, 2 )
            mchoice := 4
        CASE Debit->Paytype = SubStr( Message->PayType5, 1, 2 )
            mchoice := 5
        CASE Debit->Paytype = SubStr( Message->PayType6, 1, 2 )
            mchoice := 6
        OTHERWISE
            mchoice := 1
        ENDCASE
        @ 17, 10 PROMPT Message->PayType1
        @ 18, 10 PROMPT Message->PayType2
        @ 19, 10 PROMPT Message->PayType3
        @ 20, 10 PROMPT Message->PayType4
        @ 21, 10 PROMPT Message->PayType5
        @ 22, 10 PROMPT Message->PayType6
        MENU TO mchoice
        ApRLock( 3 )
        DO CASE
        CASE mchoice == 1
            Debit->PayType := SubStr( Message->PayType1, 1, 2 )
        CASE mchoice == 2
            Debit->PayType := SubStr( Message->PayType2, 1, 2 )
        CASE mchoice == 3
            Debit->PayType := SubStr( Message->PayType3, 1, 2 )
        CASE mchoice == 4
            Debit->PayType := SubStr( Message->PayType4, 1, 2 )
        CASE mchoice == 5
            Debit->PayType := SubStr( Message->PayType5, 1, 2 )
        CASE mchoice == 6
            Debit->PayType := SubStr( Message->PayType6, 1, 2 )
        OTHERWISE
            Debit->PayType := "NT"
        ENDCASE
        IF Debit->Paytype = "CT"
            IF Name->Charge != Space( 8 )
                Debit->Codeno := Name->Charge
            ENDIF                               // Space(8)
        ENDIF
        Debit->U_Codeno := mcodeno
        Debit->Invno    := minvno
        // **       mfind := Debit->Saleno+DTOS( Debit->Dbdate )+Debit->Invno
        UNLOCK
        SELECT DebProf
        SET ORDER TO 2                    // Invno
        SEEK Debit->Invno
        // **      SEEK mfind
        ApFLock( 3 )
        IF !Found()
            APPEND BLANK
        ENDIF
        DebProf->Codeno   := Debit->Codeno
        DebProf->DbDate   := Debit->DbDate
        DebProf->Saleno   := Debit->Saleno
        DebProf->PayType  := Debit->PayType
        DebProf->Tech     := Debit->Tech
        DebProf->U_Codeno := Debit->U_Codeno
        DebProf->Invno    := Debit->Invno
        DebProf->Amount   := Debit->Amount
        DebProf->GSTAmnt  := Debit->Tax
        DebProf->CostItem := Debit->Costitem
        DebProf->Est      := Debit->Est
        SET ORDER TO 1                        // Saleno+Date(Debit)+Invno
        UNLOCK
        SELECT Name
        ApRLock( 3 )
        Name->YtdPurch := ( YtdPurch + Debit->Amount )
        UNLOCK
        WBInvForm( @mcodeno )             // Specific ( XF_IvcFM )
        mcontinue := "N"
    ENDDO

    RETURN NIL

// ***----- End of WBInvadd()

// ********----------  END OF FILE CWPINV.PRG
