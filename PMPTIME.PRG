   *** JK 04-04-11 17:16:20 

/*
    Program.....:       PMPTIME.PRG  --  Entry of time & calculations, PAYE, etc.
    Function....: MetTime
*/

FUNCTION MetTime()

   LOCAL  ctaxcode
   manother := "Y" 
   DO WHILE manother = "Y"

      mcodeno := SPACE( 8 )
      SELECT Pmppjnl
      GOTO BOTTOM
      dPay_Per := Pmppjnl->Pay_Per        // Last Entry in file
      SELECT Name
      GOTO TOP
      aPart_:={}
      nrecno := 0
      IF LASTREC() != 0
         DO WHILE  Name->( !EOF() )
            IF Name->Sale != "STAF"
               SKIP ALIAS Name
               LOOP
            ENDIF
            IF dPay_Per = Name->LastPaid
               nline := "...."
            ELSE 
               nline := " ok "
            ENDIF  
            AADD( aPart_,SUBSTR( Name->Name, 1, 20 );
               +" "+Name->TaxCode; 
               +" "+nline;
               +" "+DTOC( Name->LastPaid );
               +" "+Name->Taxnum;
               +" "+DTOC( Name->Started );
               +" "+STR( Name->Kiwisave, 3 );
               +" "+STR( Name->Kiwiempl, 3 );
               +"               "+STR( RECNO(),6 ) )
            SKIP ALIAS Name
         ENDDO
         SCROLL()
         DISPBOX( 0, 1,  2,79, 2 )
         @  1,10 SAY "Select Name"
         DISPBOX( 3, 1, 24,79, 2 )
         IF !EMPTY( aPart_ )
            ASORT( aCatcode_,,,{ | x,y | x < y } )
            anum := ACHOICE( 4, 3, 23,78,aPart_,,"AFUNC" )
            nrecno := VAL( RIGHT( aPart_[anum],6 ) )
            IF PressedEsc()
               RETURN NIL
            ENDIF
            GOTO nrecno
            mcodeno := Name->Codeno
         ELSE
            @ 10,10 SAY "No Staff clasified go to Name File and Specify"
            INKEY( 2 )
            RETURN NIL
         ENDIF        // Empty
      ENDIF           // LastRec
                                                          // mContinue
      mcontinue := "Y" 
      DO WHILE mcontinue = "Y"
         dyy := SUBSTR( DTOS( DATE()), 1, 4 )
         dmm := SUBSTR( DTOS( DATE()),5,2 )
         ntotPay:= nGrTotPay:= nTotHrs:= nGrTotHrs := 0
         SELECT Pmppjnl
         SEEK mcodeno
         IF LASTREC() != 0
            DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() )
               IF YEAR( Pmppjnl->Pay_Per ) != YEAR( DATE() )   // < Control->Acc_Date
                  SKIP ALIAS Pmppjnl
                  LOOP
               ENDIF
               dmm     := SUBSTR( DTOS( Pmppjnl->Pay_Per ), 5, 2 )
               dMonth  := CMONTH( Pmppjnl->Pay_Per )
               dYear   := YEAR( Pmppjnl->Pay_Per )
               nTotPay:= nTotHrs := 0
               DO WHILE SUBSTR( DTOS(Pmppjnl->Pay_Per ), 5, 2 ) = dmm;
                     .AND. Pmppjnl->( !EOF() )
                  IF YEAR( Pmppjnl->Pay_Per ) != YEAR( DATE() )   // < Control->Acc_Date
                     SKIP ALIAS Pmppjnl
                     LOOP
                  ENDIF
                  nTotHrs += Pmppjnl->TotHrs
                  nTotPay += Pmppjnl->GrossPay
                  SKIP ALIAS Pmppjnl
               ENDDO
               nGrTotPay += nTotPay
               nGrTotHrs += nTotHrs
            ENDDO             // EOF Pmppjnl
         ENDIF                // LastRec

         SCROLL()
         DISPBOX( 0, 1, 2,79, 2 )
         @  1, 4 SAY TRIM( Name->Name )+" Code "+Name->TaxCode;
                     +" Started "+DTOC( Name->Started ) COLOR " BG+"
         DISPBOX(  3, 1, 21,79, 2 )
         nhrs:= npay:= ntax:= ndedsl := 0
         chdg := " Date      Hrs    Gross    Paye   S/L    Nett"
         ncol := 3
         ml   := 4
         @ ml, ncol SAY chdg
         ml++
         nsel:= nrate:= nHolRate:= ntallce:= nthallce:= ndedsl:= ndedcs2 := 0
         nTotHrs:= nHours:= nTotBasePay := 0
         nBerHrs:= nPubHrs:= nPubHrsDay:= nPubAvail:= nPubAvailDay := 0
         nHoursTot:= nHrsTH:= nSickS:= nHolHours:= nSickhrs:= nSickTotal := 0
         nHolDay:= nSickDay:= nSickDayTot:= nBerHrsDay:= nSixPer := 0
         nKiwiSave:= nKiwiEmpl := 0
         SELECT PMPPJNL
         GOTO TOP
         SEEK mcodeno
         DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() )
            IF Pmppjnl->Pay_Per > DATE()-365
               nHolRate += ( Pmppjnl->GrossPay/52 )/40
            ENDIF
            IF YEAR( Pmppjnl->Pay_Per ) < YEAR( DATE() )          //Control->Acc_Date
               SKIP ALIAS Pmppjnl
               LOOP
            ENDIF
            nTotBasePay += Pmppjnl->GrossPay
            nBerHrs     += Pmppjnl->BerHrs
            nHolHours   += Pmppjnl->HolHours
            nPubHrs     += Pmppjnl->PubHrs
            nPubAvail   += Pmppjnl->PubAvail
            nSickHrs    += Pmppjnl->SickHrs
            nSickTotal  += Pmppjnl->SickTotal
            IF Pmppjnl->Pay_Per > DATE()-50
               @ ml,ncol    SAY DTOC( Pmppjnl->Pay_Per )
               @ ml,ncol+10 SAY Pmppjnl->TotHrs   PICTURE "999.99"
               @ ml,ncol+17 SAY Pmppjnl->GrossPay PICTURE "9999.99"
               @ ml,ncol+25 SAY Pmppjnl->Paye     PICTURE "999.99"
               IF Pmppjnl->Dedsl > 0
                  @ ml,ncol+31 SAY Pmppjnl->Dedsl PICTURE "999.99"
               ENDIF
               @ ml,ncol+42 SAY Pmppjnl->NettPay  PICTURE "9999.99"
               ml++
            ENDIF                      // Full Screen
            IF ml >= 19
            ***      ncol := 3          // 42
               SCROLL(  4, 2,19,78 )
               ml := 4
               @ ml,ncol SAY chdg
               ml++
            ENDIF
            SKIP ALIAS Pmppjnl
         ENDDO               // EOF Pmppjnl
         @  1,66 SAY nTotBasePay PICTURE "$999,999.99" COLOR "BG+"
         SCROLL(  20, 0,24,80 )
         DISPBOX( 20, 1,24,79, 2 )
         nsel := 1
         @ 20,56 SAY " - Main Wages Menu - " COLOR "G+"
         @ 21, 5      PROMPT "Add Time"
         @ 21,COL()+2 PROMPT "Another"
         @ 21,COL()+2 PROMPT "Edit Time"
         @ 21,COL()+2 PROMPT "Disp Time"

         @ 23, 5      PROMPT "Name Edit"
         @ 23,COL()+2 PROMPT "Holiday View"
         @ 23,COL()+2 PROMPT "Standard Note"
         @ 23,COL()+2 PROMPT "Year Display"
         @ 23,COL()+2 PROMPT "Pay Slips"

         MENU TO nsel
         DO CASE

            CASE PressedEsc()
              RETURN NIL
            CASE nsel == 9
                 MetSlip()
                LOOP
            CASE nsel == 8
                mcodeno := Name->Codeno
                 Y2Name( mcodeno )                         // PmpIrdFm
                LOOP
            CASE nsel == 1         // ENTER time worked
         DO CASE
            CASE Name->Pay_Freq = "1" 
                dpend := ( Name->LastPaid )+7
            CASE Name->Pay_Freq = "2" 
                dpend := ( Name->LastPaid )+14
            CASE Name->Pay_Freq = "3" 
                dpend := ( Name->LastPaid )+21
            CASE Name->Pay_Freq = "4" 
                dpend := ( Name->LastPaid )+28
            CASE Name->Pay_Freq = "M" 
                dpend := ( Name->LastPaid )+30
            OTHERWISE
                dpend := ( Name->LastPaid )+7
         ENDCASE
         SCROLL( 4, 3, 19,78 )
         IF YEAR( dpend )>2080   // How can we get this far !!!
            dpend-=36525
         ENDIF
         @  4,10      SAY "Must Be "+Months->Day7
         @  4,COL()+2 SAY Name->LastPaid+7
         @  4,COL()+2 SAY Name->LastPaid+14
         @  4,COL()+2 SAY Name->LastPaid+21
         @  4,COL()+2 SAY Name->LastPaid+28
         @  5, 3      SAY "Period Ending" GET dpend       
         @  5,COL()+2 SAY "Last Paid  "+DTOC( Name->LastPaid )
         @  5,COL()+2 SAY "Start Date "+DTOC( Name->Started )
          READ  
         IF PressedEsc()
            RETURN NIL
         ENDIF
         SELECT Name
          ApRLock( 3 )
         Name->LastPaid := dpend 
         UNLOCK
         ctaxcode   := Name->TaxCode
         nrate      := Name->Payrate
         ntallce    := Name->N_T_Allce    // Weekly No Tax
         nthallce   := Name->NTH_Allce    // Hourly No Tax
         nTax_Spec1 := Name->Tax_Spec1
         nNT_Spec1  := Name->NT_Spec1
         nSpec_Pay  := Name->Spec_Pay
         nSpec_Pay1 := Name->Spec_Pay1
         nSpec_Pay2 := Name->Spec_Pay2
         nSpec_Pay3 := Name->Spec_Pay3
         nrate      := Name->Payrate
         nchildsup  := Name->ChildSup
         nProdBon   := Name->ProdBon
         SELECT PMPPjnl
         LOCATE FOR ( PMPPjnl->Pay_Per == dpend ) .AND. ( PMPPjnl->Codeno == mcodeno )
         IF FOUND()
           @  6, 3 SAY "You have an entry for this employee - this period"
           ??chr( 7 ), chr( 7 )          // Rings Bell
         ENDIF
         SELECT Name
         npayrate  := Name->Payrate
         mtaxcode  := Name->TaxCode
         mpay_freq := Name->Pay_Freq 
         nkiwisave := Name->KiwiSave
         nkiwiEmpl := Name->KiwiEmpl
         @  7, 3      SAY "Hourly Rate"   GET npayrate  PICTURE "999.99"
         ***    @  7,COL()+2 SAY "Kiwi Employee" GET nkiwiSave PICTURE "999"
         ***    @  7,COL()+2 SAY "Employer %"    GET nKiwiEmpl PICTURE "999"
         IF Name->TaxCode = SPACE( 5 )
            @ 10, 5      SAY "Tax Code S,M,ME,MESL,ML,SL,SSL"
            @ 10,COL()+2 GET mtaxCode PICTURE "@!"
            ***                    VALID( Name->TaxCode $ "S,M,ME,MESL,ML,SL,SSL" ) PICTURE "@!"
         ENDIF
         IF Name->Pay_Freq = SPACE( 1 )
            @ 11, 5 SAY "Pay Freq 1,2,3,4 M" GET mpay_freq;
                          VALID( mpay_freq $ "1,2,3,4,M" ) PICTURE "@!"
         ENDIF
         READ
         ApRLock( 3 )
         Name->PayRate  := npayrate
         Name->TaxCode  := mtaxcode
         Name->Pay_Freq := mpay_freq
         Name->KiwiSave := nkiwiSave
         Name->KiwiEmpl := nKiwiEmpl
         UNLOCK
         SCROLL( 10, 2, 10,78 )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         npay:=ntax:=nhrs:=nded:=nadj:=nspay:=nl:=ntotpay:= npaya:= nelp := 0
         cpayfreq:= cpay := ""
         IF Name->EndDate > DATE()-366
            nSixPer := 10
         ENDIF
         SELECT Pmppjnl
          ApFLock( 3 )
         APPEND BLANK
         IF nSixPer = 0
            Pmppjnl->Day1 := Months->Amount1
            Pmppjnl->Day2 := Months->Amount2
            Pmppjnl->Day3 := Months->Amount3
            Pmppjnl->Day4 := Months->Amount4
            Pmppjnl->Day5 := Months->Amount5
            Pmppjnl->Day6 := Months->Amount6
            Pmppjnl->Day7 := Months->Amount7
            nHours := Pmppjnl->Day1+Pmppjnl->Day2+Pmppjnl->Day3+Pmppjnl->Day4;
                     +Pmppjnl->Day5+Pmppjnl->Day6+Pmppjnl->Day7
            Pmppjnl->Hours   := nHours
            Pmppjnl->TotHrs  := nHours
            Pmppjnl->HolRate := nHolRate
         ENDIF 
         UNLOCK
         SELECT Months
         GOTO TOP
         mok := "Y"
         DO WHILE mok = "Y"
            nl := 10
            @ nl, 3 SAY Months->Day1+"   "+STR( Pmppjnl->Day1 )
            nl++
            @ nl, 3 SAY Months->Day2+"   "+STR( Pmppjnl->Day2 ) 
            nl++
            @ nl, 3 SAY Months->Day3+"   "+STR( Pmppjnl->Day3 ) 
            nl++
            @ nl, 3 SAY Months->Day4+"   "+STR( Pmppjnl->Day4 ) 
            nl++
            @ nl, 3 SAY Months->Day5+"   "+STR( Pmppjnl->Day5 ) 
            nl++
            @ nl, 3 SAY Months->Day6+"   "+STR( Pmppjnl->Day6 ) 
            nl++
            @ nl, 3 SAY Months->Day7+"   "+STR( Pmppjnl->Day7 ) 
            nl+=2
            @ nl, 3      SAY "Std Hrs"
            @ nl,COL()+5 SAY nHours PICTURE "99.99" COLOR "BG+"
            nl++
            @ nl, 3      SAY "Total"                 COLOR "G+"
            nTotHrs := ( nHours+( nHrsTH*1.5 );
               +nHolDay+nSickDayTot )
            @ nl,14      SAY nTotHrs PICTURE "999.99" COLOR "G+"
            nl := 4
            SCROLL(  4,29, 7,78 )
            @ nl,46 SAY "Taken   Avail   Remains" 
            nl++
            @ nl,30 SAY "Bereav   Hrs"
            IF nBerHrs+nBerHrsDay > 0
               @ nl,46 SAY nBerHrs+nBerHrsDay  PICTURE "999.99" COLOR "G+"
            ENDIF
            @ nl,54 SAY Name->BerAvail PICTURE "999.99" 
            @ nl,64 SAY Name->BerAvail-( nBerHrs+nberHrsDay ) PICTURE "999.99" 
            ***      IF nBerHrs > Name->BerAvail
            ***         ??chr( 7 ), chr( 7 )      // Rings Bell
            ***      ENDIF
            nl++
            @ nl,30 SAY "Holiday  Hrs"
            IF nHolHours+nHolDay > 0
               @ nl,46 SAY nHolHours+nHolDay  PICTURE "999.99" COLOR "G+"
            ENDIF
            @ nl,54 SAY Name->HolAvail PICTURE "999.99" 
            @ nl,64 SAY Name->HolAvail-( nHolHours+nHolDay ) PICTURE "999.99" 
            ***      IF nHolHours+nHolDay > Name->HolAvail
            ***         ??chr( 7 ), chr( 7 )      // Rings Bell
            ***      ENDIF
            nl++
            @ nl,30 SAY "Pub/Stat Hrs"
            IF nPubHrs+nPubHrsDay > 0
               @ nl,46 SAY nPubHrs+nPubHrsDay PICTURE "999.99" COLOR "G+"
            ENDIF
            @ nl,54 SAY Name->PubAvail+nPubAvailDay PICTURE "999.99" COLOR "BG+" 
            @ nl,64 SAY Name->PubAvail-( nPubHrs+nPubAvailDay ) PICTURE "999.99" 
            ***      IF ( nPubHrs+nPubHrsDay )>( nPubAvail+nPubAvailDay )
            ***  TAKEN OUT TO TEST         ??chr( 7 ), chr( 7 )      // Rings Bell
            ***      ENDIF
            nl++
            @ nl,30 SAY "Sick     Hrs"
            IF nSickHrs+nSickDay > 0
               @ nl,46 SAY nSickHrs+nSickDay  PICTURE "999.99" COLOR "G+"
            ENDIF
            @ nl,54 SAY Name->SickAvail PICTURE "999.99" 
            @ nl,64 SAY Name->SickAvail-( nSickHrs+nSickDay ) PICTURE "999.99" 
            ***      IF nSickHrs+nSickDay > Name->SickAvail
            ***         ??chr( 7 ), chr( 7 )      // Rings Bell
            ***      ENDIF
            SELECT Labour
            SEEK mcodeno
            nl  := 10
            SELECT Labour
            SEEK mcodeno
            IF LASTREC() != 0
               DO WHILE Labour->Codeno = mcodeno .AND. Labour->( !EOF() )
                  IF Labour->Date <= dpend-7
                     SKIP ALIAS Labour
                     LOOP
                  ENDIF
                  IF Labour->Date > dpend
                     SKIP ALIAS Labour
                     LOOP
                  ENDIF
                  nTime := 0
                  dDate := Labour->Date
                  DO WHILE Labour->Date = dDate .AND. Labour->( !EOF() )
                     IF Labour->Date <= dpend-7
                        SKIP ALIAS Labour
                        LOOP
                     ENDIF
                     IF Labour->Date > dpend
                        SKIP ALIAS Labour
                        LOOP
                     ENDIF
                     nTime += Labour->Time 
                     SKIP ALIAS Labour
                  ENDDO                                     // Date
                  @ nl,55      SAY nTime PICTURE "99.99"
                  @ nl,COL()+1 SAY LEFT( CDOW( dDate ),3 )+" "+DTOC( dDate )
                  nl++
               ENDDO
            ENDIF           // LastRec
            SCROLL(  20, 0, 24,80 )
            DISPBOX( 20, 1, 24,79, 2 )
            nselHrs := 1
            @ 20,58 SAY " - Adding Wages - " COLOR "G+"
            @ 21,64 SAY "Pay     Hours" COLOR "G+"
            @ 22,43 SAY "Grand Totals" COLOR "G+"
            @ 22,56 SAY nGrTotPay PICTURE "$999,999.99" COLOR "G+"
            @ 22,68 SAY nGrTotHrs PICTURE "99,999.99" COLOR "G+"
            @ 23,45 SAY "6% Totals" COLOR "G+"
            @ 23,56 SAY nGrTotPay-( nGrTotPay*( 1-6/100 )*100 )/100 PICTURE "$999,999.99" COLOR "G+"
            @ 23,68 SAY nGrTotHrs-( nGrTotHrs*( 1-6/100 )*100 )/100 PICTURE "99,999.99" COLOR "G+"
            @ 21, 3      PROMPT "JC-" 
            @ 21,COL()+2 PROMPT "Standard Hrs"
            @ 21,COL()+2 PROMPT "Time 1/2"
            @ 21,COL()+2 PROMPT "Holiday"
            @ 21,COL()+2 PROMPT "Sick"
            @ 21,COL()+2 PROMPT "Finished Hrs"  
        
            @ 23, 3 PROMPT "Edit Sick/Hol"
            MENU TO nselHrs
            DO CASE
               CASE PressedEsc()
                  mok := "N"
                  EXIT
               CASE nselHrs  == 7
                  SAVE SCREEN TO Pmpscrn
                  SCROLL( 10,40,16,78 )
                  SELECT Name
                   ApRLock( 3 )
                  nl := 10
                  @ nl,48 SAY "Bereav   Avail Hrs" GET Name->BerAvail  PICTURE "999.99" 
                  nl++
                  @ nl,48 SAY "Holiday  Avail Hrs" GET Name->HolAvail  PICTURE "999.99" 
                  nl++
                  @ nl,48 SAY "Public   Avail Hrs" GET Name->PubAvail  PICTURE "999.99" 
                  nl++
                  @ nl,48 SAY "Sick     Avail Hrs" GET Name->SickAvail PICTURE "999.99" 
                   READ
                  UNLOCK
                  RESTORE SCREEN FROM Pmpscrn
                  LOOP
               CASE nselHrs  == 6
                  mok := "N"
                  EXIT
               CASE nselHrs  == 1
                  SELECT Labour
                  GOTO TOP
                  SEEK mcodeno
                  IF FOUND()
                     aPart_:={}
                     DO WHILE Labour->Codeno = mcodeno .AND. Labour->( !EOF() )
                        IF Labour->Date < dpend-7
                           SKIP ALIAS Labour
                           LOOP
                        ENDIF
                        IF Labour->Date > dpend
                           SKIP ALIAS Labour
                           LOOP
                        ENDIF
                        AADD( aPart_,STR( Labour->Time );
                               +" "+DTOC( Labour->Date ); 
                               +" "+Labour->Invno;
                               +" "+Labour->Desc;
                               +"     "+STR( RECNO(),6 ) )
                        SKIP ALIAS Labour
                     ENDDO
                     SCROLL(   4,30,19,78 )
                     DISPBOX(  4,30,19,77, 2 )
                     IF !EMPTY( aPart_ )
                        ASORT( aCatcode_,,,{ | x,y | x < y } )
                        anum := ACHOICE(  5,31,18,76,aPart_,,"AFUNC" )
                     ENDIF        // Empty
                     SCROLL( 4,30,19,78 )
                  ENDIF           // Found
                  LOOP 

               CASE nselHrs  == 2
                  SELECT Pmppjnl
                  ApRLock( 3 )
                  nl := 10
                  @ nl, 3 SAY Months->Day1 GET Pmppjnl->Day1 PICTURE "99.99"
                  nl++  
                  @ nl, 3 SAY Months->Day2 GET Pmppjnl->Day2 PICTURE "99.99"
                  nl++
                  @ nl, 3 SAY Months->Day3 GET Pmppjnl->Day3 PICTURE "99.99"
                  nl++
                  @ nl, 3 SAY Months->Day4 GET Pmppjnl->Day4 PICTURE "99.99"
                  nl++
                  @ nl, 3 SAY Months->Day5 GET Pmppjnl->Day5 PICTURE "99.99"
                  nl++
                  @ nl, 3 SAY Months->Day6 GET Pmppjnl->Day6 PICTURE "99.99"
                  nl++
                  @ nl, 3 SAY Months->Day7 GET Pmppjnl->Day7 PICTURE "99.99"
                   READ
                  nHours := Pmppjnl->Day1+Pmppjnl->Day2+Pmppjnl->Day3;
                           +Pmppjnl->Day4+Pmppjnl->Day5+Pmppjnl->Day6;
                           +Pmppjnl->Day7
                  nl++
                  UNLOCK
                  LOOP  

            CASE nselHrs == 3         // Time & 1/2
               nPubAvailDay:= nDayP1:= nDayP2:= nDayP3:= nDayP4 := 0
               nDayP5:= nDayP6:= nDayP7 := 0 
               SELECT Pmppjnl
                ApRLock( 3 )
               nl := 8
               ***         @ nl,29 SAY "Hrs"
               nl++ 
               ***         @ nl,29 SAY "Lieu"
               nl++ 
               @ nl,21      GET Pmppjnl->Day1TH PICTURE "99.99"
               /*
                READ
               IF Pmppjnl->Day1TH > 0
                  @ nl,28 GET nDayP1          PICTURE "99.99"
                   READ
               ENDIF
               */
               nl++
               @ nl,21      GET Pmppjnl->Day2TH PICTURE "99.99"
               /*
                READ
               IF Pmppjnl->Day2TH > 0
                  @ nl,28 GET nDayP2          PICTURE "99.99"
                   READ
               ENDIF
               */
               nl++
               @ nl,21      GET Pmppjnl->Day3TH PICTURE "99.99"
               /*
                READ
               IF Pmppjnl->Day3TH > 0
                  @ nl,28 GET nDayP3          PICTURE "99.99"
                   READ
               ENDIF
               */         nl++
               @ nl,21      GET Pmppjnl->Day4TH PICTURE "99.99"
               /*
                READ
               IF Pmppjnl->Day4TH > 0
                  @ nl,28 GET nDayP4          PICTURE "99.99"
                   READ
               ENDIF
               */
               nl++
               @ nl,21      GET Pmppjnl->Day5TH PICTURE "99.99"
               /*
                READ
               IF Pmppjnl->Day5TH > 0
                  @ nl,28 GET nDayP5          PICTURE "99.99"
                   READ
               ENDIF
               */
               nl++
               @ nl,21      GET Pmppjnl->Day6TH PICTURE "99.99"
               /*
                READ
               IF Pmppjnl->Day6TH > 0
                  @ nl,28 GET nDayP6          PICTURE "99.99"
                   READ
               ENDIF
               */
               nl++
               @ nl,21      GET Pmppjnl->Day7TH PICTURE "99.99"
               /*
                READ
               IF Pmppjnl->Day7TH > 0
                  @ nl,28 GET nDayP7          PICTURE "99.99"
                   READ
               ENDIF
               */
               nl++
               @ nl,22 SAY "T+1/2"
               nl++
                READ
               ***         nPubAvailDay := nDayP1+nDayP2+nDayP3+nDayP4;
               ***                        +nDayP5+nDayP6+nDayP7         // Public Hrs worked

               nHrsTH := Pmppjnl->Day1TH+Pmppjnl->Day2TH+Pmppjnl->Day3TH;
                        +Pmppjnl->Day4TH;
                        +Pmppjnl->Day5TH+Pmppjnl->Day6TH+Pmppjnl->Day7TH
               @ nl,22 SAY nHrsTH         PICTURE "99.99" COLOR "BG+"
               nl++
               @ nl,22 SAY ( nHrsTH*1.5 ) PICTURE "99.99" COLOR "BG+"
               ***         @ nl,29 SAY nPubAvailDay   PICTURE "99.99" COLOR "BG+"
               UNLOCK
               LOOP 

            CASE nselHrs == 4         // Holidays
               SAVE SCREEN TO Pmpscrn
               SCROLL( 4,30,19,78 )
               @ 4,59 SAY "Pay     Hours" 
               SELECT Pmppjnl
               nrecno := RECNO()
               dyy := SUBSTR( DTOS( DATE()), 1, 4 )
               dmm := SUBSTR( DTOS( DATE()),5,2 )
               nl := 5
               ntotPay:= nGrTotPay:= nTotHrs:= nGrTotHrs := 0
               SELECT Pmppjnl
               SEEK mcodeno
               IF LASTREC() != 0
                  DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() )
                     IF YEAR( Pmppjnl->Pay_Per ) != YEAR( DATE() )   // < Control->Acc_Date
                        SKIP ALIAS Pmppjnl
                        LOOP
                     ENDIF
                     dmm     := SUBSTR( DTOS( Pmppjnl->Pay_Per ), 5, 2 )
                     dMonth  := CMONTH( Pmppjnl->Pay_Per )
                     dYear   := YEAR( Pmppjnl->Pay_Per )
                     nTotPay:= nTotHrs := 0
                     DO WHILE SUBSTR( DTOS(Pmppjnl->Pay_Per ), 5, 2 ) = dmm;
                           .AND. Pmppjnl->( !EOF() )
                        IF YEAR( Pmppjnl->Pay_Per ) != YEAR( DATE() )   // < Control->Acc_Date
                           SKIP ALIAS Pmppjnl
                           LOOP
                        ENDIF
                        nTotHrs += Pmppjnl->TotHrs
                        nTotPay += Pmppjnl->GrossPay
                        SKIP ALIAS Pmppjnl
                     ENDDO
                     @ nl,32 SAY dYear 
                     @ nl,40 SAY dMonth
                     @ nl,52 SAY nTotPay PICTURE "$999,999.99"
                     @ nl,63 SAY nTotHrs PICTURE "99,999.99"   
                     nl++
                     nGrTotPay += nTotPay
                     nGrTotHrs += nTotHrs
                  ENDDO             // EOF Pmppjnl
               ENDIF                // LastRec
               nl++
               @ nl,40 SAY "Totals:"
               @ nl,52 SAY nGrTotPay PICTURE "$999,999.99"
               @ nl,63 SAY nGrTotHrs PICTURE "99,999.99"
               nl++
               @ nl,40 SAY "8% Totals"
               @ nl,52 SAY nGrTotPay-( nGrTotPay*( 1-8/100 )*100 )/100 PICTURE "$999,999.99"
               @ nl,63 SAY nGrTotHrs-( nGrTotHrs*( 1-8/100 )*100 )/100 PICTURE "99,999.99"
               GOTO nrecno
               INKEY( 0 )
                           RESTORE SCREEN FROM Pmpscrn
               @ 16,52 SAY nGrTotPay PICTURE "$999,999.99"
               @ 16,63 SAY nGrTotHrs PICTURE "99,999.99"
               @ 17,52 SAY nGrTotPay-( nGrTotPay*( 1-8/100 )*100 )/100 PICTURE "$999,999.99"
               @ 17,63 SAY nGrTotHrs-( nGrTotHrs*( 1-8/100 )*100 )/100 PICTURE "99,999.99"
               @ 17,74 SAY "8%"
               DO CASE  
                  CASE Name->Started > ( DATE()-21 )
                        @ 18,38 SAY "Pay At 8% Normal "+DTOC( Name->Started )
                        ***             ??chr( 7 ), chr( 7 )      // Rings Bell
                        SELECT Pmppjnl
                         ApRLock( 3 ) 
                        Pmppjnl->HolRate := Name->PayRate;
                                            -( Name->PayRate*( 1-6/100 )*100 ) /100
                        @ 19,38 SAY "Rate   8% Normal "+STR( Pmppjnl->HolRate, 5, 2 )       
                        UNLOCK
                     CASE Name->Started > ( DATE()-365 )
                        nHolRate := ( Name->GrLstYr/52 )/40 
                        ***                 SELECT Name
                        ***                  ApRLock( 3 )
                        ***                 @ 18,38 SAY "Pay At 6% Gross  "+DTOC( Name->Started )
                        ***                 ??chr( 7 ), chr( 7 )      // Rings Bell
                        ***                 @ 19,38 SAY "Gross Last Year" GET Name->GrLstYR PICTURE "999999.99"
                        ***                 @ 19,66 SAY nHolRate PICTURE "99.99"
                        ***                 @ 20,22 SAY "All Wages, Overtime, Commission, Holiday Pay"
                        ***                  READ
                        ***                 @ 19,38 SAY "Average Hourly   "
                        ***                 @ 19,66 SAY nHolRate PICTURE "99.99"
                        ***                 @ 20,22 SAY SPACE( 45 )
                        ***                 UNLOCK
                        SELECT Pmppjnl
                        ApRLock( 3 )
                        Pmppjnl->HolRate := nHolRate-( ( nHolRate*( 1-8/100 )*100 )/100 ) 
                        ***                 @ 20,44 SAY "6% Gross" GET Pmppjnl->HolRate PICTURE "99.99"       
                        ***                  READ
                        ***                 @ 20,44 SAY "CHECK RATE FOR HOLIDAYS !!!!"
                        UNLOCK
                     OTHERWISE
                        SELECT Name
                         ApRLock( 3 ) 
                         ***                 ??chr( 7 ), chr( 7 )      // Rings Bell
                        nHolRate := ( Name->GrLstYr/52 )/40 
                        @ 19,30 SAY "Gross Last Year      ";
                                     GET Name->GrLstYR PICTURE "999999.99"
                        @ 19,64 SAY nHolRate PICTURE "99.99"
                        @ 20,22 SAY "All Wages, Overtime, Commission, Holiday Pay"
                         READ
                        @ 19,30 SAY "Gross Average Hr "
                        @ 19,64 SAY nHolRate PICTURE "99.99"
                        @ 20,22 SAY SPACE( 45 )
                        UNLOCK
                        IF Name->PayRate > Pmppjnl->HolRate
                           SELECT Pmppjnl
                            ApRLock( 3 ) 
                           Pmppjnl->HolRate := Name->PayRate
                           @ 20,30      SAY "Use Pay Rate"
                           @ 20,COL()+2 SAY Pmppjnl->HolRate PICTURE "99.99"       
                           UNLOCK
                        ELSE
                           SELECT Pmppjnl
                            ApRLock( 3 ) 
                           Pmppjnl->HolRate := nHolRate
                           UNLOCK
                        ENDIF
                     ENDCASE
                     IF nHolHours+nHolDay > Name->HolAvail
                        @ 20,22 SAY "Used ALL Holidays Due"
                        ***          ??chr( 7 ), chr( 7 )      // Rings Bell
                        INKEY( 2 )
                     ENDIF
                     nl++
                     SELECT Pmppjnl
                      ApRLock( 3 ) 
                     nl := 9
                     @ nl,17 SAY "Hol Rate/Hr"
                     /*
                     TO BE SORTED OUT AFTER 1 YEAR ????????????????????????????
                              DO CASE
                                 CASE Name->GrLstYr > 0
                                      Pmppjnl->HolRate := ( Name->GrLstYr/52 )/40
                                      @ nl,37 SAY Name->GrLstYr PICTURE "999,999.99" 
                                 CASE nHolRate > Name->PayRate
                                      Pmppjnl->HolRate := nHolRate
                                      @ nl,37 SAY nHolRate PICTURE "999.99" 
                                 OTHERWISE 
                                      Pmppjnl->HolRate := Name->PayRate
                                      @ nl,37 SAY "Ordinary" 
                              ENDCASE
                     */ 
                     @ nl,29 GET Pmppjnl->HolRate  PICTURE "999.99"
                     nl++
                     @ nl,29 GET Pmppjnl->Day1Hol  PICTURE "99.99"
                     nl++
                     @ nl,29 GET Pmppjnl->Day2Hol  PICTURE "99.99"
                     nl++
                     @ nl,29 GET Pmppjnl->Day3Hol  PICTURE "99.99"
                     nl++
                     @ nl,29 GET Pmppjnl->Day4Hol PICTURE "99.99"
                     nl++
                     @ nl,29 GET Pmppjnl->Day5Hol PICTURE "99.99"
                     nl++
                     @ nl,29 GET Pmppjnl->Day6Hol PICTURE "99.99"
                     nl++
                     @ nl,29 GET Pmppjnl->Day7Hol PICTURE "99.99"
                     nl++
                     @ nl,30 SAY "Hols"
                     nl++
                      READ
                     nHolDay := Pmppjnl->Day1Hol+Pmppjnl->Day2Hol+Pmppjnl->Day3Hol;
                               +Pmppjnl->Day4Hol+Pmppjnl->Day5Hol;
                               +Pmppjnl->Day6Hol+Pmppjnl->Day7Hol
                     @ nl,30 SAY nHolDay PICTURE "99.99" COLOR "BG+"
                     UNLOCK
                     SCROLL(  8, 3, 8,78 )
                     LOOP 

                  CASE nselHrs == 5         // Sick Days
                     SCROLL(  9,43,19,78 )
                     IF Name->Started > ( DATE()-183 )
                        @ 19,30 SAY "No Sick Leave Due"
                        ***            ??chr( 7 ), chr( 7 )      // Rings Bell
                        INKEY( 4 )
                     ENDIF
                     IF nSickHrs+nSickDay > Name->SickAvail
                        @ 19,36 SAY "Used ALL Sick Leave Due"
                        ***            ??chr( 7 ), chr( 7 )      // Rings Bell
                        INKEY( 2 )
                     ENDIF
                     SELECT Pmppjnl
                      ApRLock( 3 ) 
                     nl := 8
                     nl++
                     @ nl,38 SAY "All Hrs Paid"
                     nl++
                     @ nl,37      GET Pmppjnl->Day1Sick  PICTURE "99.99"
                      READ
                     IF Pmppjnl->Day1Sick > 0
                        nselect := 4
                        @ 10,47 PROMPT "Bereavement "
                        @ 11,47 PROMPT "Descretion  "
                        @ 12,47 PROMPT "Public Hols "
                        @ 13,47 PROMPT "Sick        "
                        @ 14,47 PROMPT "Others      "
                        @ 15,47 PROMPT "Work Related"
                        MENU TO nselect
                        DO CASE
                           CASE nselect == 1
                              Pmppjnl->Day1S_B := "B"
                              @ nl,45 SAY "B"
                           CASE nselect == 2
                              Pmppjnl->Day1S_B := "D"
                              @ nl,45 SAY "D"
                           CASE nselect == 3
                              Pmppjnl->Day1S_B := "P"
                              @ nl,45 SAY "P"
                           CASE nselect == 4
                              Pmppjnl->Day1S_B := "S"
                              @ nl,45 SAY "S"
                           CASE nselect == 5
                              Pmppjnl->Day1S_B := "O"
                              @ nl,45 SAY "O"
                           CASE nselect == 6
                              Pmppjnl->Day1S_B := "W"
                              @ nl,45 SAY "W"
                        ENDCASE
                        SCROLL( 10,46,15,78 )
                     ENDIF                    // > 0
                     nl++
                     @ nl,37      GET Pmppjnl->Day2Sick  PICTURE "99.99"
                      READ
                     IF Pmppjnl->Day2Sick > 0
                        nselect := 4
                        @ 10,47 PROMPT "Bereavement "
                        @ 11,47 PROMPT "Descretion  "
                        @ 12,47 PROMPT "Public Hols "
                        @ 13,47 PROMPT "Sick        "
                        @ 14,47 PROMPT "Others      "
                        @ 15,47 PROMPT "Work Related"
                        MENU TO nselect
                        DO CASE
                           CASE nselect == 1
                              Pmppjnl->Day2S_B := "B"
                              @ nl,45 SAY "B"
                           CASE nselect == 2
                              Pmppjnl->Day2S_B := "D"
                              @ nl,45 SAY "D"
                           CASE nselect == 3
                              Pmppjnl->Day2S_B := "P"
                              @ nl,45 SAY "P"
                           CASE nselect == 4
                              Pmppjnl->Day2S_B := "S"
                              @ nl,45 SAY "S"
                           CASE nselect == 5
                              Pmppjnl->Day2S_B := "O"
                              @ nl,45 SAY "O"
                           CASE nselect == 6
                              Pmppjnl->Day2S_B := "W"
                              @ nl,45 SAY "W"
                        ENDCASE
                        SCROLL( 10,46,15,78 )
                     ENDIF                    // > 0
                     nl++
                     @ nl,37      GET Pmppjnl->Day3Sick  PICTURE "99.99"
                      READ
                     IF Pmppjnl->Day3Sick > 0
                        nselect := 4
                        @ 10,47 PROMPT "Bereavement "
                        @ 11,47 PROMPT "Descretion  "
                        @ 12,47 PROMPT "Public Hols "
                        @ 13,47 PROMPT "Sick        "
                        @ 14,47 PROMPT "Others      "
                        @ 15,47 PROMPT "Work Related"
                        MENU TO nselect
                        DO CASE
                           CASE nselect == 1
                              Pmppjnl->Day3S_B := "B"
                              @ nl,45 SAY "B"
                           CASE nselect == 2
                              Pmppjnl->Day3S_B := "D"
                              @ nl,45 SAY "D"
                           CASE nselect == 3
                              Pmppjnl->Day3S_B := "P"
                              @ nl,45 SAY "P"
                           CASE nselect == 4
                              Pmppjnl->Day3S_B := "S"
                              @ nl,45 SAY "S"
                           CASE nselect == 5
                              Pmppjnl->Day3S_B := "O"
                              @ nl,45 SAY "O"
                           CASE nselect == 6
                              Pmppjnl->Day3S_B := "W"
                              @ nl,45 SAY "W"
                        ENDCASE
                        SCROLL( 10,46,15,78 )
                     ENDIF                    // > 0
                     nl++
                     @ nl,37      GET Pmppjnl->Day4Sick PICTURE "99.99"
                      READ
                     IF Pmppjnl->Day4Sick > 0
                        nselect := 4
                        @ 10,47 PROMPT "Bereavement "
                        @ 11,47 PROMPT "Descretion  "
                        @ 12,47 PROMPT "Public Hols "
                        @ 13,47 PROMPT "Sick        "
                        @ 14,47 PROMPT "Others      "
                        @ 15,47 PROMPT "Work Related"
                        MENU TO nselect
                        DO CASE
                           CASE nselect == 1
                              Pmppjnl->Day4S_B := "B"
                              @ nl,45 SAY "B"
                           CASE nselect == 2
                              Pmppjnl->Day4S_B := "D"
                              @ nl,45 SAY "D"
                           CASE nselect == 3
                              Pmppjnl->Day4S_B := "P"
                              @ nl,45 SAY "P"
                           CASE nselect == 4
                              Pmppjnl->Day4S_B := "S"
                              @ nl,45 SAY "S"
                           CASE nselect == 5
                              Pmppjnl->Day4S_B := "O"
                              @ nl,45 SAY "O"
                           CASE nselect == 6
                              Pmppjnl->Day4S_B := "W"
                              @ nl,45 SAY "W"
                        ENDCASE
                        SCROLL( 10,46,15,78 )
                     ENDIF                    // > 0
                     nl++
                     @ nl,37      GET Pmppjnl->Day5Sick PICTURE "99.99"
                      READ
                     IF Pmppjnl->Day5Sick > 0
                        nselect := 4
                        @ 10,47 PROMPT "Bereavement "
                        @ 11,47 PROMPT "Descretion  "
                        @ 12,47 PROMPT "Public Hols "
                        @ 13,47 PROMPT "Sick        "
                        @ 14,47 PROMPT "Others      "
                        @ 15,47 PROMPT "Work Related"
                        MENU TO nselect
                        DO CASE
                           CASE nselect == 1
                              Pmppjnl->Day5S_B := "B"
                              @ nl,45 SAY "B"
                           CASE nselect == 2
                              Pmppjnl->Day5S_B := "D"
                              @ nl,45 SAY "D"
                           CASE nselect == 3
                              Pmppjnl->Day5S_B := "P"
                              @ nl,45 SAY "P"
                           CASE nselect == 4
                              Pmppjnl->Day5S_B := "S"
                              @ nl,45 SAY "S"
                           CASE nselect == 5
                              Pmppjnl->Day5S_B := "O"
                              @ nl,45 SAY "O"
                           CASE nselect == 6
                              Pmppjnl->Day5S_B := "W"
                              @ nl,45 SAY "W"
                        ENDCASE
                        SCROLL( 10,46,15,78 )
                     ENDIF                    // > 0
                     nl++
                     @ nl,37      GET Pmppjnl->Day6Sick PICTURE "99.99"
                      READ
                     IF Pmppjnl->Day6Sick > 0
                        nselect := 4
                        @ 10,47 PROMPT "Bereavement "
                        @ 11,47 PROMPT "Descretion  "
                        @ 12,47 PROMPT "Public Hols "
                        @ 13,47 PROMPT "Sick        "
                        @ 14,47 PROMPT "Others      "
                        @ 15,47 PROMPT "Work Related"
                        MENU TO nselect
                        DO CASE
                           CASE nselect == 1
                              Pmppjnl->Day6S_B := "B"
                              @ nl,45 SAY "B"
                           CASE nselect == 2
                              Pmppjnl->Day6S_B := "D"
                              @ nl,45 SAY "D"
                           CASE nselect == 3
                              Pmppjnl->Day6S_B := "P"
                              @ nl,45 SAY "P"
                           CASE nselect == 4
                              Pmppjnl->Day6S_B := "S"
                              @ nl,45 SAY "S"
                           CASE nselect == 5
                              Pmppjnl->Day6S_B := "O"
                              @ nl,45 SAY "O"
                           CASE nselect == 6
                              Pmppjnl->Day6S_B := "W"
                              @ nl,45 SAY "W"
                        ENDCASE
                        SCROLL( 10,46,15,78 )
                     ENDIF                    // > 0
                     nl++
                     @ nl,37      GET Pmppjnl->Day7Sick PICTURE "99.99"
                      READ
                     IF Pmppjnl->Day7Sick > 0
                        nselect := 4
                        @ 10,47 PROMPT "Bereavement "
                        @ 11,47 PROMPT "Descretion  "
                        @ 12,47 PROMPT "Public Hols "
                        @ 13,47 PROMPT "Sick        "
                        @ 14,47 PROMPT "Others      "
                        @ 15,47 PROMPT "Work Related"
                        MENU TO nselect
                        DO CASE
                           CASE nselect == 1
                              Pmppjnl->Day7S_B := "B"
                              @ nl,45 SAY "B"
                           CASE nselect == 2
                              Pmppjnl->Day7S_B := "D"
                              @ nl,45 SAY "D"
                           CASE nselect == 3
                              Pmppjnl->Day7S_B := "P"
                              @ nl,45 SAY "P"
                           CASE nselect == 4
                              Pmppjnl->Day7S_B := "S"
                              @ nl,45 SAY "S"
                           CASE nselect == 5
                              Pmppjnl->Day7S_B := "O"
                              @ nl,45 SAY "O"
                           CASE nselect == 6
                              Pmppjnl->Day7S_B := "W"
                              @ nl,45 SAY "W"
                        ENDCASE
                        SCROLL( 10,46,15,78 )
                     ENDIF                    // > 0
                     nl++
                     @ nl,38 SAY "Away"
                     nl++
                     READ
                     nSickDayTot := Pmppjnl->Day1Sick+Pmppjnl->Day2Sick;
                        +Pmppjnl->Day3Sick;
                        +Pmppjnl->Day4Sick+Pmppjnl->Day5Sick;
                        +Pmppjnl->Day6Sick+Pmppjnl->Day7Sick
                     @ nl,38 SAY nSickDayTot PICTURE "99.99" COLOR "BG+"
                     UNLOCK
         
                     // Sick
                     nSickDay := 0
                     IF Pmppjnl->Day1S_B = "S"
                        nSickDay += Pmppjnl->Day1Sick        // 
                     ENDIF
                     IF Pmppjnl->Day2S_B = "S"
                        nSickDay += Pmppjnl->Day2Sick
                     ENDIF
                     IF Pmppjnl->Day3S_B = "S"
                        nSickDay += Pmppjnl->Day3Sick
                     ENDIF
                     IF Pmppjnl->Day4S_B = "S"
                        nSickDay += Pmppjnl->Day4Sick
                     ENDIF
                     IF Pmppjnl->Day5S_B = "S"
                        nSickDay += Pmppjnl->Day5Sick
                     ENDIF
                     IF Pmppjnl->Day6S_B = "S"
                        nSickDay += Pmppjnl->Day6Sick
                     ENDIF
                     IF Pmppjnl->Day7S_B = "S"
                        nSickDay += Pmppjnl->Day7Sick
                     ENDIF

                     // Stat Hols
                     nPubHrsDay := 0
                     IF Pmppjnl->Day1S_B = "P"
                        nPubHrsDay += Pmppjnl->Day1Sick
                     ENDIF
                     IF Pmppjnl->Day2S_B = "P"
                        nPubHrsDay += Pmppjnl->Day2Sick
                     ENDIF
                     IF Pmppjnl->Day3S_B = "P"
                        nPubHrsDay += Pmppjnl->Day3Sick
                     ENDIF
                     IF Pmppjnl->Day4S_B = "P"
                        nPubHrsDay += Pmppjnl->Day4Sick
                     ENDIF
                     IF Pmppjnl->Day5S_B = "P"
                        nPubHrsDay += Pmppjnl->Day5Sick
                     ENDIF
                     IF Pmppjnl->Day6S_B = "P"
                        nPubHrsDay += Pmppjnl->Day6Sick
                     ENDIF
                     IF Pmppjnl->Day7S_B = "P"
                        nPubHrsDay += Pmppjnl->Day7Sick
                     ENDIF

                     // Bereavment
                     nBerHrsDay := 0
                     IF Pmppjnl->Day1S_B = "B"
                        nBerHrsDay += Pmppjnl->Day1Sick
                     ENDIF
                     IF Pmppjnl->Day2S_B = "B"
                        nBerHrsDay += Pmppjnl->Day2Sick
                     ENDIF
                     IF Pmppjnl->Day3S_B = "B"
                        nBerHrsDay += Pmppjnl->Day3Sick
                     ENDIF
                     IF Pmppjnl->Day4S_B = "B"
                        nBerHrsDay += Pmppjnl->Day4Sick
                     ENDIF
                     IF Pmppjnl->Day5S_B = "B"
                        nBerHrsDay += Pmppjnl->Day5Sick
                     ENDIF
                     IF Pmppjnl->Day6S_B = "B"
                        nBerHrsDay += Pmppjnl->Day6Sick
                     ENDIF
                     IF Pmppjnl->Day7S_B = "B"
                        nBerHrsDay += Pmppjnl->Day7Sick
                     ENDIF
                       SCROLL(  8, 3, 9,78 )
                       LOOP 
                  ENDCASE
               ENDDO           // mok  Finished Entering Time
               SELECT Pmppjnl
                ApRLock(3 )
               Pmppjnl->TotHrs := ( nHours+( nHrsTH*1.5 );
                                   +nSickDayTot )
               Pmppjnl->Hours     := nHours+nHolDay
               Pmppjnl->HrsTH     := nHrsTh
               Pmppjnl->BerHrs    := nBerHrsDay
               Pmppjnl->HolHours  := nHolDay
               Pmppjnl->PubHrs    := nPubHrsDay
               Pmppjnl->PubAvail  := nPubAvailDay
               Pmppjnl->SickHrs   := nSickDay      
               Pmppjnl->SickTotal := nSickDayTot
               COMMIT
               UNLOCK
               ****                                                Allowances Deductions ETC
               SCROLL(  8,20, 19,48 )
               nl := 10
               IF Name->NTH_Allce > 0     // Non Taxable Per Hour
                  @ nl,24 SAY "N/T Allow Per Hr " GET nTHAllce PICTURE "9999.99"     // Per Hour
                  nl++
               ENDIF
               IF Name->N_T_Allce > 0     //  Non Taxable Allow Per Week
                  @ nl,24 SAY "N/Tax Allow Wkly " GET nTAllce PICTURE "9999.99"
                  nl++
               ENDIF 
               IF Name->ProdBon > 0                                   // Production
                  @ nl,24 SAY "Production Bonus" GET nProdBon PICTURE "99999.99"
                  nl++
               ENDIF
               IF Name->ChildSup > 0                                                    // Child ??????
                  @ nl,24 SAY "Child Support   " GET nChildSup PICTURE "99999.99"
                  nl++
               ENDIF
               IF Name->Tax_Spec1 > 0                                        // Taxable Special 1
                  @ nl,24 SAY Name->TaxDesc1+"  " GET nTax_Spec1 PICTURE "99999.99"
                  nl++  
               ENDIF
               IF Name->Spec_Pay3 > 0                                  // Taxable 3
                  @ nl,24 SAY Name->SpecDesc3+"  " GET nSpec_Pay3 PICTURE "99999.99"
                  nl++  
               ENDIF
               IF Name->NT_Spec1 > 0                               // Add To Gross 1
                  @ nl,24 SAY Name->NTDesc1+"  " GET nNT_Spec1 PICTURE "99999.99"
                  nl++  
               ENDIF
               IF Name->Spec_Pay > 0                                    // SPECIAL Pay
                  @ nl,24 SAY Name->SpecDesc+"  " GET nSpec_Pay PICTURE "99999.99"
                  nl++  
               ENDIF
               IF Name->Spec_Pay1 > 0                                   // SPECIAL Pay 1
                  @ nl,24 SAY Name->SpecDesc1+"  " GET nSpec_Pay1 PICTURE "99999.99"
                  nl++  
               ENDIF
               IF Name->Spec_Pay2 > 0                                   // SPECIAL 2 
                  @ nl,24 SAY Name->SpecDesc2+"  " GET nSpec_Pay2 PICTURE "99999.99"
                  nl++  
               ENDIF
                READ
               nrecno := RECNO()
               mnl := 4
               SCROLL(  4,30,19,78 ) 
               IF Name->EndDate > DATE()-366
                  SCROLL(  4,30,19,78 ) 
                  SELECT Pmppjnl
                  SEEK mcodeno
                  nGrTotPay:= nGrTotHrs := 0
                  IF LASTREC() != 0
                     DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() )
                        IF YEAR( Pmppjnl->Pay_Per ) != YEAR( DATE() )   // < Control->Acc_Date
                           SKIP ALIAS Pmppjnl
                           LOOP
                        ENDIF
                        dmm     := SUBSTR( DTOS( Pmppjnl->Pay_Per ), 5, 2 )
                        dmonth  := CMONTH( Pmppjnl->Pay_Per )
                        dYear   := YEAR( Pmppjnl->Pay_Per )
                        nTotPay:= nTotHrs := 0
                        DO WHILE SUBSTR( DTOS(Pmppjnl->Pay_Per ), 5, 2 ) = dmm;
                                 .AND. Pmppjnl->( !EOF() )
                           nTotHrs += Pmppjnl->TotHrs
                           nTotPay += Pmppjnl->GrossPay
                           SKIP ALIAS Pmppjnl
                        ENDDO 
                        @ mnl,30 SAY dyear
                        @ mnl,36 SAY dmonth
                        @ mnl,46 SAY nTotPay PICTURE "$999,999.99"
                        @ mnl,58 SAY nTotHrs PICTURE "99,999.99"   
                        mnl++
                        nGrTotPay += nTotPay
                        nGrTotHrs += nTotHrs
                     ENDDO             // EOF Pmppjnl
                  ENDIF                // LastRec
                  mnl++
                  @ mnl,36 SAY "Totals"
                  @ mnl,46 SAY nGrTotPay PICTURE "$999,999.99"
                  @ mnl,58 SAY nGrTotHrs PICTURE "99,999.99"
                  mnl++
                  @ mnl,33 SAY "8 % Totals"
                  @ mnl,46 SAY nGrTotPay-( nGrTotPay*( 1-8/100 )*100 )/100 PICTURE "$999,999.99"
                  @ mnl,58 SAY nGrTotHrs-( nGrTotHrs*( 1-8/100 )*100 )/100 PICTURE "99,999.99"
                  mnl++
                  @ mnl,30 SAY "Edit Total"
                  @ mnl,48 GET nGrTotPay PICTURE "99999.99"
                   READ
                  nSixPer   := nGrTotPay-( nGrTotPay*( 1-6/100 )*100 )/100
                  mnl++
                  @ mnl,30 SAY "Edit 8 %"
                  @ mnl,48 GET nSixPer PICTURE "99999.99"
                  mnl++
                  @ mnl,30 SAY "Edit Kiwi Save"
                  @ mnl,48 GET nkiwisave PICTURE "99999.99"
                   READ
                  GOTO nrecno
               ENDIF                       // Name->EndDate
               ***   UNLOCK
               IF LASTKEY() = 27
                  RETURN NIL
               ENDIF
               IF npay == 0                                   
                  nPay := ( Pmppjnl->TotHrs*Name->PayRate )
                  nPay += ( nProdBon )
                  nPay += ( Pmppjnl->HolHours*Pmppjnl->HolRate )
               ENDIF
               IF nTax_Spec1 > 0                               // Add Taxable 1
                  npay += nTax_Spec1
               ENDIF
               IF nSpec_Pay3 > 0                               // Spec Taxable 3
                  npay += nSpec_Pay3
               ENDIF
               IF Name->Sick_Pay
                  nspay := npay*0.02                  // Sick pay allowance   ???? WHAT IS THIS
               ENDIF
               IF nSixPer > 0                                   
                  nPay += nSixPer
               ENDIF
               nTotPay := npay+nspay                 // Pay+Sick  This is Gross Pay
               SCROLL(  4,33,16,78 )
               nl := 4
               @ nl,53      SAY Pmppjnl->TotHrs PICTURE "999.99"
               @ nl,COL()+2 SAY nrate           PICTURE "$99.99"   // Pay Rate
               @ nl,69      SAY Pmppjnl->TotHrs*Name->PayRate PICTURE "99,999.99" COLOR c_hicolor // Rate*Hrs
               nl++
               IF Pmppjnl->HolHours > 0
                  @ nl,45      SAY "Holiday" 
                  @ nl,53      SAY Pmppjnl->HolHours PICTURE "999.99"
                  @ nl,COL()+2 SAY Pmppjnl->HolRate  PICTURE "$99.99"  // Holiday Rate
                  @ nl,69      SAY Pmppjnl->HolHours*Pmppjnl->HolRate PICTURE "99,999.99" COLOR c_Hicolor
                  nl++
               ENDIF  
               IF nProdBon > 0
                  @ nl,53 SAY "Production Bonus"
                  @ nl,69 SAY nProdBon PICTURE "99,999.99" COLOR c_hicolor
                  nl++
               ENDIF
               IF nspay > 0                 // Sick ???
                  @ nl,56 SAY "Sick/Pay"
                  @ nl,69 SAY nspay   PICTURE "99,999.99" COLOR c_hicolor  // ( hrs*Rate )+0.02
                  nl++
               ENDIF
               IF nSixPer > 0
                  @ nl,53 SAY "8 % Pay"
                  @ nl,69 SAY nSixPer PICTURE "99,999.99" COLOR c_hicolor
                  nl++
               ENDIF
               IF nTax_Spec1 > 0                               // Taxable Spec 
                  @ nl,53 SAY Name->TaxDesc1
                  @ nl,69 SAY nTax_Spec1 PICTURE "99,999.99" COLOR c_hicolor
                  nl++
               ENDIF
               IF nSpec_Pay3 > 0                               // Taxable Pay 3
                  @ nl,53 SAY Name->SpecDesc3
                  @ nl,69 SAY nSpec_Pay3 PICTURE "99,999.99" COLOR c_hicolor
                  nl++
               ENDIF
               /*
               Taken out 16/12/2009
               IF SUBSTR( Control->U_Name, 1, 3 ) != "MET"
                  cpay := STR( nTotPay, 7, 0 )      //   Rounding
                  nTotPay := VAL( cpay )
               ENDIF
               */
                  *** @ nl,35      SAY nTotPay PICTURE "$99,999.99" COLOR "RG+"
               @ nl,53 SAY "Total Taxable"
               @ nl,69 GET nTotPay PICTURE "99999.99"
                READ
               nl++
               IF EMPTY( cpayfreq )                                    // 1,2,3,4,M Freq
                  cpayfreq := Name->Pay_freq
               ENDIF
               ** Calculate annual pay - based on weekly whole dollars
               IF cpayfreq == "M"                             // Monthly pay
                 npaya := ( INT( ( nTotPay*12 )/52 ) )*52                    
                ELSE                                          // 1, 2, 3, or 4 weekly pay
                 npaya := ( INT( nTotPay/VAL( cpayfreq ) ) )*52              
               ENDIF

               IF Name->Hol_Pay                                // Holiday pay
                  npaya := ( INT( nTotPay/3 ) )*52                // Annual/Weeks*52
               ENDIF

            *** NOW DO PAYE
               DO CASE     // Tax code 
                  CASE nPaya > TaxRates->Brk4                       // $ 85,795
                     nTax := ( nPaya-TaxRates->Brk4 );
                            *( TaxRates->Brk5Rate/100 )
                     nTax += ( TaxRates->Brk4-TaxRates->Brk3 );
                           *( TaxRates->Brk4Rate/100 )
                     nTax += ( TaxRates->Brk3-TaxRates->Brk2 );
                           *( TaxRates->Brk3Rate/100 )
                     nTax += ( TaxRates->Brk2-TaxRates->Brk1 );
                           *( TaxRates->Brk2Rate/100 )
                     nTax += TaxRates->Brk1;
                           *( TaxRates->Brk1Rate/100 )
                  CASE nPaya > TaxRates->Brk3                       // $ 60,000
                     nTax := ( nPaya-TaxRates->Brk3 );
                            *( TaxRates->Brk4Rate/100 )
                     nTax += ( TaxRates->Brk3-TaxRates->Brk2 );
                           *( TaxRates->Brk3Rate/100 )
                     nTax += ( TaxRates->Brk2-TaxRates->Brk1 );
                            *( TaxRates->Brk2Rate/100 )
                     nTax += TaxRates->Brk1;
                         *( TaxRates->Brk1Rate/100 )
                  CASE nPaya > TaxRates->Brk2                       // $ 38,000
                     nTax := ( nPaya-( TaxRates->Brk2 ) );
                           *( TaxRates->Brk3Rate/100 ) 
                     nTax += ( TaxRates->Brk2-TaxRates->Brk1 );
                           *( TaxRates->Brk2Rate/100 )
                     nTax += TaxRates->Brk1;
                          *( TaxRates->Brk1Rate/100 )
                  CASE npaya > TaxRates->Brk1                        // $ 9,500
                     nTax := ( npaya-TaxRates->Brk1 );
                           *( TaxRates->Brk2Rate/100 )
                     nTax += TaxRates->Brk1*;
                          ( TaxRates->Brk1Rate/100 )
                  CASE npaya <= TaxRates->Brk1                   // Less $ 9,500
                     nTax := npaya*( TaxRates->Brk1Rate/100 )
               ENDCASE
               nTax := ( ( INT( ( nTax )/ .52 ) )/ 100 )
               ** Divide by 52 for weekly tax - discard part cents (round down)

               IF EMPTY( ctaxcode )     // No declaration - 45% plus ELP
                  ntax := npaya*0.45
               ENDIF
               IF SUBSTR( Name->taxcode, 1, 2 ) == "ME"     // 
                  IF ntotPay >= 462 .AND. ntotPay <= 846
                    ntax := ntax-10  // minus $10 for the week only
                  ENDIF
               ENDIF
               IF SUBSTR( Name->taxcode, 1, 1 ) == "S"     // Secondary employment
                  ***   ntax := INT( npay )*( TaxRates->ElpRate/100 )         // 0.21+0.013
                  ntax := nTotPay*( TaxRates->Sec_Rate/100 )   // 0.221
                      ** Secondary is flat 22.1% + ELP rate on whole dollars
               ENDIF
               IF Name->Hol_Pay                                   // Holiday Pay
                  ntax := ntax*3
                 ELSE
                   IF cpayfreq == "M"                             // Monthly pay
                      ntax := ( ntax*13 )/3
                     ELSE                                        // 1,2 3,4 weekly pay
                      ntax := ntax*VAL( cpayfreq )
                  ENDIF
               ENDIF
               nded1 := 0
               DO CASE
                  CASE Name->TaxCode == "MSL  "                     // Student Loan
                     IF nTotPay > TaxRates->SL_thresh
                        nded1 := ( nTotPay-TaxRates->SL_thresh )*0.12
                     ENDIF
                  CASE Name->TaxCode == "MESL "                     // Student Loan
                     IF nTotPay > TaxRates->SL_thresh
                       nded1 := ( nTotPay-TaxRates->SL_thresh )*0.12
                     ENDIF
                  CASE Name->TaxCode == "SSL  "
                     nded1 := nTotPay*0.12
                  CASE Name->TaxCode == "SHL  "
                     nded1 := nTotPay*0.341
               ENDCASE
               SCROLL( 9,23, 16,78 ) 
               SELECT PMPPjnl
                ApFLock( 3 ) 
               Pmppjnl->GrossPay := nTotPay   // Gross Pay
               UNLOCK
               nkiwisave := nTotPay-( nTotPay*( 1-Name->Kiwisave/100 )*100 )/100
               IF nkiwisave > 0                // KiwiSave
                  @ nl,43 SAY Name->Kiwisave PICTURE "999"
                  @ nl,49 SAY "Check    Kiwi Save"
                  @ nl,69 GET nkiwisave PICTURE "99999.99"
                   READ
                  cpay := STR( nkiwisave, 7, 2 )  //  - Rounding ?
                  nkiwisave := VAL( cpay )
                  nl++
               ENDIF
               IF ntotpay >= 847 .AND. ntotPay <= 923
                  @ nl,46 SAY "MUST CHECK PAYE TABLE" COLOR "RG+"
               ENDIF
               IF Name->Taxcode = "MESL "
                  nl++
                  ***   @ nl,35      SAY ntax PICTURE "$99,999.99" COLOR "RG+"
                  @ nl,35 SAY "MESL PAYE Tax Student Added"
               ENDIF
               IF nded1 > 0.00                         // Student Loan repayment
                  nl++
                  ***   @ nl,35 SAY ntax PICTURE "$99,999.99" COLOR "RG+"
                  @ nl,46 SAY "Check Student Loan"
                  @ nl,69 GET nDed1 PICTURE "99999.99"
                   READ
                  IF Name->Taxcode = "MESL "
                     ntax += nDed1 
                  ENDIF
               ENDIF
               nl++    
               @ nl,46 SAY "Check      PAYE "
               @ nl,69 GET nTax PICTURE "99999.99"
                READ
               nl++
               nkiwiempl := 0
               IF Name->KiwiEmpl > 0                // KiwiSave Employer
                  nkiwiempl := nTotPay-( nTotPay*( 1-3/100 )*100 )/100
                  @ nl,30 SAY Name->Rate     PICTURE "% 999.99"
                  @ nl,40 SAY "3% Employer on IRD345"
                  @ nl,61 SAY nkiwiempl PICTURE "99999.99"
                  ****    READ
                  ***   cpay := STR( nkiwiempl, 7, 2 )  //  - Rounding ?
                  ***   nkiwiempl := VAL( cpay )
                  nl++ 
               ENDIF
               nl++
               @ nl,32 SAY "Net Pay" 
               @ nl,COL()+1 SAY nTotPay-nTax PICTURE "$99,999.99" COLOR "RG+"
               @ nl,COL()+1 SAY "KiwiSave"
               @ nl,COL()+1 SAY nkiwisave    PICTURE "$9,999.99" COLOR "RG+"
               nTotPay -= ( ntax+nkiwisave )
                  *** nkiwiempl Taken off at IR345 
               cpay := STR( nTotPay, 7, 2 )  //  - Rounding ?
               nTotPay := VAL( cpay )
               IF nChildSup > 0                // Child Support
                  nl++
                  @ nl,53 SAY "Child Support"
                  @ nl,69 SAY nChildSup PICTURE "99,999.99" COLOR c_hicolor
                  ntotpay -= nChildSup
                  cpay := STR( ntotpay, 7, 2 )  //  - Rounding ?
                  ntotpay := VAL( cpay )
                  nl++
                  @ nl,35 SAY nTotPay PICTURE "$99,999.99" COLOR "RG+"
               ENDIF
               IF ntallce > 0                         // Name->N_T_Allce>0  Weekly Allow
                  ** Weekly Non tax allce
                  nTallce := nTallce*VAL( Name->Pay_freq )
                  @ nl,53 SAY "Non Tax Allow"
                  @ nl,69 SAY nTallce PICTURE "99,999.99" COLOR c_hicolor
                  nTotPay += nTallce
                  cpay := STR( nTotPay, 7, 2 )  //  - Rounding ?
                  nTotPay := VAL( cpay )
                  nl++
                  @ nl,36 SAY nTotPay PICTURE "$99,999.99" COLOR "RG+"
               ENDIF
               IF nthallce > 0                      // Name->NTH_Allce>0  Hourly Allow Non Tax
                  ** Hourly non tax allce
                  nthallce := nthallce*Pmppjnl->Hours
                  nl++
                  @ nl,53 SAY "N/T Hrly Allce"
                  @ nl,69 SAY nthallce PICTURE "99,999.99" COLOR c_hicolor
                  nTotPay += nthallce
                  cpay := STR( nTotPay, 7, 2 )  //  - Rounding ?
                  nTotPay := VAL( cpay )
                  nl++
                  @ nl,36 SAY nTotPay PICTURE "$99,999.99" COLOR "RG+"
               ENDIF
               IF nSpec_Pay > 0                               // Special Deduction Winz Etc
                  nl++
                  @ nl,53 SAY Name->SpecDesc
                  @ nl,69 SAY nSpec_Pay PICTURE "99,999.99" COLOR c_hicolor
                  nTotPay -= nSpec_Pay
                  cpay := STR( nTotPay, 7, 2 )  //  - Rounding ?
                  nTotPay := VAL( cpay )
                  nl++
                  @ nl,36 SAY nTotPay PICTURE "$99,999.99" COLOR "RG+"
               ENDIF
               IF nSpec_Pay1 > 0                               // Special Deduction Winz Etc
                  nl++
                  @ nl,53 SAY Name->SpecDesc1
                  @ nl,69 SAY nSpec_Pay1 PICTURE "99,999.99" COLOR c_hicolor
                  nTotPay -= nSpec_Pay1
                  cpay := STR( nTotPay, 7, 2 )  //  - Rounding ?
                  nTotPay := VAL( cpay )
                  nl++
                  @ nl,36 SAY nTotPay PICTURE "$99,999.99" COLOR "RG+"
               ENDIF
               IF nSpec_Pay2 > 0                               // Spec Deduction 2
                  nl++
                  @ nl,53 SAY Name->SpecDesc2
                  @ nl,69 SAY nSpec_Pay2 PICTURE "99,999.99" COLOR c_hicolor
                  nTotPay -= nSpec_Pay2
                  cpay := STR( nTotPay, 7, 2 )  //  - Rounding ?
                  nTotPay := VAL( cpay )
                  nl++
                  @ nl,36 SAY nTotPay PICTURE "$99,999.99" COLOR "RG+"
               ENDIF
               IF nNT_Spec1 > 0                               // Add Non Taxable 1
                  nl++
                  @ nl,53 SAY Name->NTDesc1
                  @ nl,69 SAY nNT_Spec1 PICTURE "99,999.99" COLOR c_hicolor
                  ntotpay += nNt_Spec1
                  cpay := STR( nTotPay, 7, 2 )  //  - Rounding ?
                  nTotPay := VAL( cpay )
                  nl++
                  @ nl,36 SAY nTotPay PICTURE "$99,999.99" COLOR "RG+"
               ENDIF
                  *** /*
                  *** TAKEN OUT CHRISTINE NOT NEEDED
               IF Name->Taxcode != "MESL "
                  ***   @ nl,36 SAY nTotPay PICTURE "$99,999.99" COLOR "RG+"
                  IF nded1 > 0
                     nl++
                     @ nl,22      SAY "Less Student Loan"
                     @ nl,COL()+1 SAY nDed1 PICTURE "$9,999.99" COLOR "RG+"
                     nTotPay := nTotPay-nDed1
                  ENDIF
               ENDIF
               cpay := STR( nTotPay, 7, 2 )   // This is effectively ntotpay:=ROUND(ntotpay,2)
               nTotPay := VAL( cpay )
               nl+=2
               @ nl,49 SAY "Total Nett To Pay" COLOR "RB+"
               @ nl,69 GET nTotPay PICTURE "99999.99"
                READ
               nl++
               mok := ApGetY( TRIM( Message->Correct ))
               SCROLL(  17, 0, 24,56 )
               DISPBOX( 17, 1, 24,56, 2 )
               IF mok = "N"
                  @  6,10 SAY "SORRY DO THAT ENTRY AGAIN"
                  SELECT PMPPjnl
                   ApFLock( 3 ) 
                  DELETE
                  UNLOCK
                  WAIT
                ELSE
                  SELECT Name
                   ApRLock( 3 )
                  ***   IF Name->Taxcode = "MESL "
                  ***      Name->Desc := "Student Loan Deducted $ ";
                  ***                     +STR( nDed1, 8, 2 );
                  ***                     +"  "+DTOC( dpend )
                  ***   ENDIF
                  IF Name->Taxcode = "MESL "
                     ntax -= nDed1                        // this is so IR345 is correct
                  ENDIF
                  @ 18, 2 SAY "Desc"    
                  @ 19, 2 GET Name->Desc                   // Notes     
                  @ 20, 2 GET Name->Desc1
                  @ 21, 2 GET Name->Desc2
                  @ 22, 2 GET Name->Desc3
                   READ
                  UNLOCK
                  SELECT PMPPjnl
                   ApFLock( 3 ) 
                  Pmppjnl->Pay_Per   := dpend                          // Date Paid
                  Pmppjnl->Codeno    := mcodeno
                  Pmppjnl->TaxCode   := ctaxcode                       // Tax Code
                  Pmppjnl->Payrate   := nrate                          // Pay Rate
                  Pmppjnl->Basepay   := nPay    // is ( Hrs*Rate )+( HolHours*HolRate ) 
                  Pmppjnl->NettPay   := nTotPay
                  Pmppjnl->S_P_Allce := nspay
                  Pmppjnl->Paye      := ntax
                  Pmppjnl->N_T_Allce := ntallce
                  Pmppjnl->NTH_Allce := nthallce
                  Pmppjnl->DedSL     := nded1                // Student Loan
                  Pmppjnl->ProdBon   := nProdBon             // Production  
                  Pmppjnl->ChildSup  := nChildSup            // Child Support
                  Pmppjnl->Tax_Spec1 := nTax_Spec1           // Special 1  
                  Pmppjnl->NT_Spec1  := nNT_Spec1            // Add Special 1  
                  Pmppjnl->Spec_Pay  := nSpec_Pay            // Special  
                  Pmppjnl->Spec_Pay1 := nSpec_Pay1           // Special 1  
                  Pmppjnl->Spec_Pay2 := nSpec_Pay2           // Special 2  
                  Pmppjnl->Spec_Pay3 := nSpec_Pay3           // Taxable 3  
                  Pmppjnl->KiwiSave  := nkiwisave            // Kiwi Save  
                  Pmppjnl->KiwiEmpl  := nkiwiempl            // Kiwi Employer  
                  ***   Pmppjnl->Seq_No    := STR( RECNO(), 5 )    // Sequence of Entry
                  ***   Pmppjnl->Seq_No    := STR( ( CTOD( "31/12/2050" )-dpend ), 5 )
                  COMMIT  // Forces immediate write to file from buffer
                  UNLOCK
               ENDIF               // mok
               METTIME()
            *** */

            ***    LOOP

            CASE nsel == 2                       // Another
               mcontinue := "N"
               EXIT

            CASE nsel == 3                       // Edit Time 

               SELECT Pmppjnl
               GOTO TOP
               SEEK mcodeno
               aPart_:={}
               nrecno := 0
               IF LASTREC() != 0
                  DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() )
                     AADD( aPart_,DTOC( Pmppjnl->Pay_Per );
                        +" "+STR( Pmppjnl->PayRate ); 
                        +" "+STR( Pmppjnl->Hours ); 
                        +" "+STR( Pmppjnl->Paye );
                        +" "+STR( Pmppjnl->GrossPay ); 
                        +" "+STR( Pmppjnl->PubHrs );
                        +" "+STR( Pmppjnl->PubAvail ); 
                        +" "+Pmppjnl->Codeno;
                        +"                  "+STR( RECNO(),6 ) )
                     SKIP ALIAS Pmppjnl
                  ENDDO
                  SCROLL()
                  DISPBOX( 0, 1,  2,79, 2 )
                  @  1,10 SAY "Select Wage Payment to Delete"
                  DISPBOX( 3, 1, 24,79, 2 )
                  IF !EMPTY( aPart_ )
                  ***    ASORT( aCatcode_,,,{ | x,y | x < y } )  // TRY THIS PUTS LATEST ENTRY AT TOP
                     anum := ACHOICE( 4, 5, 23,76,aPart_,,"AFUNC" )
                     nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                     IF PressedEsc()
                        RETURN NIL
                     ENDIF
                     GOTO nrecno
                  ENDIF        // Empty
               ENDIF           // LastRec
               SCROLL( 15, 2, 19,78 )
               @ 16,10      SAY Pmppjnl->Codeno
               @ 16,COL()+2 SAY Pmppjnl->Pay_Per
               @ 16,COL()+2 SAY Pmppjnl->Hours 
               @ 16,COL()+2 SAY Pmppjnl->Paye
               @ 17,10      SAY Pmppjnl->GrossPay 
               @ 17,COL()+2 SAY Pmppjnl->PayRate
               @ 18,10      SAY Pmppjnl->Tax_Spec1 
               @ 18,COL()+2 SAY Pmppjnl->Spec_Pay3
               @ 18,COL()+2 SAY Pmppjnl->NT_Spec1
               mok := ApGetN( TRIM( Message->Delete ) )  
               IF mok = "Y"                                      // Delete
                  SELECT Pmppjnl
                   ApRLock( 3 )
                  DELETE
                  UNLOCK
                  LOOP
               ENDIF                             // mok
               mok := "N"
               DO WHILE mok = "N"
                  ***     SCROLL(  8, 2,20,78 )
                  SCROLL()
                  DISPBOX( 0, 1,  2,79, 2 )
                  @  1,10 SAY Name->Name
                  DISPBOX( 3, 1, 24,79, 2 )
                  SELECT Pmppjnl
                   ApRLock( 3 )
                  @  9,10      SAY "Date      " GET Pmppjnl->Pay_Per   PICTURE "99/99/9999"
                  @  9,COL()+2 SAY "Hours"      GET Pmppjnl->Hours     PICTURE "999.99" 
                  IF Name->Taxcode = "MESL "
                     @ 10,32 SAY "BEWARE Student Loan Deducted" COLOR "RG+"
                  ENDIF
                  @ 10,10      SAY "Tax       " GET Pmppjnl->Paye      PICTURE "9999.99"
                  @ 11,10      SAY "Gross Pay " GET Pmppjnl->GrossPay  PICTURE "9999.99" 
                  @ 11,COL()+2 SAY "Rate"       GET Pmppjnl->PayRate   PICTURE "9999.99"
                  @ 11,COL()+3 SAY "Time+1/2"   GET Pmppjnl->HrsTH     PICTURE "999.99"
                  @ 12,10      SAY "Prod Bonus" GET Pmppjnl->ProdBon   PICTURE "9999.99" 
                  @ 12,COL()+2 SAY "S/Loan"     GET Pmppjnl->DedSl     PICTURE "9999.99"
                  @ 13,10      SAY "Nett Pay  " GET Pmppjnl->NettPay   PICTURE "9999.99" 
                  @ 13,COL()+2 SAY "N/T Week"   GET Pmppjnl->N_T_Allce PICTURE "9999.99"
                  @ 13,COL()+2 SAY "N/T Hrly"   GET Pmppjnl->NTH_Allce PICTURE "9999.99"
                  @ 14,10      SAY "Special   " GET Pmppjnl->Spec_Pay  PICTURE "9999.99" 
                  @ 14,COL()+2 SAY "Spec 1"     GET Pmppjnl->Spec_Pay1 PICTURE "9999.99"
                  @ 14,COL()+2 SAY "Spec 2"     GET Pmppjnl->Spec_Pay2 PICTURE "9999.99"
                  @ 15,10      SAY "Child Supp" GET Pmppjnl->ChildSup  PICTURE "9999.99" 
                  @ 16,10      SAY "Bereav Hrs" GET Pmppjnl->BerHrs    PICTURE "9999.99"
                  @ 17,10      SAY "Public Hrs" GET Pmppjnl->PubHrs    PICTURE "9999.99"
                  @ 17,COL()+2 SAY "Pub Avail"  GET Pmppjnl->PubAvail  PICTURE "9999.99"
                  @ 18,10      SAY "Tax Spec  " GET Pmppjnl->Tax_Spec1 PICTURE "9999.99"
                  @ 18,COL()+2 SAY "Taxable"    GET Pmppjnl->Spec_Pay3 PICTURE "9999.99"
                  @ 18,COL()+2 SAY "NT Spec"    GET Pmppjnl->NT_Spec1  PICTURE "9999.99"
                  @ 19,10      SAY "Base Pay  " GET Pmppjnl->BasePay   PICTURE "9999.99"
                  @ 20,10      SAY "Kiwi Save " GET Pmppjnl->KiwiSave  PICTURE "9999.99"
                  @ 20,COL()+2 SAY "Employer Kiwi" GET Pmppjnl->KiwiEmpl PICTURE "9999.99"
                   READ
                  mok := ApGetY( TRIM( Message->Correct ) )
                  UNLOCK
                  SCROLL( 4, 2, 22,78 )
                  SELECT Name
                   ApRLock( 3 )
                  nl := 8
                  @ nl, 5 SAY "Bereav   Avail Hrs" GET Name->BerAvail  PICTURE "999.99" 
                  nl++
                  @ nl, 5 SAY "Holiday  Avail Hrs" GET Name->HolAvail  PICTURE "999.99" 
                  nl++
                  @ nl, 5 SAY "Sick     Avail Hrs" GET Name->SickAvail PICTURE "999.99" 
                  nl+=2  
                  @ nl, 5 SAY "Desc" GET Name->Desc
                  nl++
                  @ nl, 5 SAY "    " GET Name->Desc1
                  nl++
                  @ nl, 5 SAY "    " GET Name->Desc2
                  nl++
                  @ nl, 5 SAY "    " GET Name->Desc3
                   READ
                  UNLOCK
                  ***     SCROLL( 8,44, 20,78 )
                  LOOP
               ENDDO
               LOOP
            CASE nsel == 4                       // Display Time

               DispPay( @mcodeno )               // PmpTime1
               mcontinue := "Y"
               LOOP
            CASE nsel == 5                           // Edit Name 
               MetName( mcodeno )
               LOOP
            CASE nsel == 6
               NameHol( mcodeno )
               LOOP 
            CASE nsel == 7
               SCROLL( 6, 2,19,78 )
               SELECT Menu1
                ApRLock( 3 )
               nl := 8
               @ nl, 5 SAY "Std Note" GET Menu1->Note
               nl++
               @ nl, 5 SAY "        " GET Menu1->Note1
               nl++
               @ nl, 5 SAY "        " GET Menu1->Note2
               nl++
               @ nl, 5 SAY "        " GET Menu1->Note3
               nl++
                READ
               UNLOCK
               SCROLL( 6, 2, 19,78 )
               LOOP 
         ENDCASE
         mcontinue := "N"                              
      ENDDO                                // mcontinue            
      manother := "Y"
      *** ApGetY( TRIM( Message->Another ) )
   ENDDO                                  // manother

   RETURN NIL

   **  END Program  --  METTIME  **

   ****---------------------  END OF PMPTIME.PRG
