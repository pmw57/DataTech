   *** JK 08-05-11 21:49:08 

/* 
   Program.....: PMPPAYE.PRG  -  Display / Print Paye
   Authors.....: J Kirby
   Function....: MetSlip, MetPaye, MetName, MetName
   Static Funcs: MonthLab, MetEdit, AMDTAXRATE
*/

STATIC FUNCTION MonthLab()

   SCROLL()
   SELECT Months
   GOTO TOP
   mstmm  := DATE()-30
   mendmm := DATE()
   @ 10,30 SAY Message->Frdate GET mstmm  PICTURE "99/99/9999"
   @ 11,30 SAY Message->Todate GET mendmm PICTURE "99/99/9999"
    READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      mwhere := "S"

       Printsel( mwhere )

      IF mwhere = "P"
         npl := 56
        ELSE
         npl := 20
         SCROLL()
      ENDIF
      @  0, 0 SAY SUBSTR( Control->U_Name, 1,35 )
      @  0,34 SAY "Time for period "+DTOC( mstmm )+" to "+DTOC( mendmm )
      ***    PmpHd()                                        //ABOVE
      @  2,31 SAY "Avail Hours                            Gross Pay"
      nl := 3
      nTotHours:= ntothrs:= ntotGross:= ntotPaye:= ntotNett:= 0
      nHours:= netpay:= ntotpay:= nTotTH:= nHrsTH:= ngross := 0
      ntime:= nTotTime := 0
   SELECT Name
   SELECT PMPPjnl
   SET RELATION TO Codeno INTO Name
   GOTO TOP
   DO WHILE Pmppjnl->( !EOF() )
      IF Pmppjnl->Pay_Per < mstmm
         SKIP ALIAS Pmppjnl
         LOOP
      ENDIF
      IF Pmppjnl->Pay_Per > mendmm
         SKIP ALIAS Pmppjnl
         LOOP
      ENDIF
      IF nl > npl
         IF mwhere = "P"
            EJECT 
          ELSE
            WAIT
            SCROLL()
         ENDIF
         nl := 0
      ENDIF                // npl
      mcodeno := Pmppjnl->Codeno
      netPay:= ngross:= nhours := 0
      @ nl, 1 SAY Name->Name
      SEEK mcodeno
      DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() )
         IF Pmppjnl->Pay_Per < mstmm
            SKIP ALIAS Pmppjnl
            LOOP
         ENDIF
         IF Pmppjnl->Pay_Per > mendmm
            SKIP ALIAS Pmppjnl
            LOOP
         ENDIF
      ngross += Pmppjnl->GrossPay
      netpay += Pmppjnl->GrossPay-Pmppjnl->Paye
      netpay -= PMPPjnl->DedSL
      netpay -= PMPPjnl->ChildSup
      netpay += Pmppjnl->NT_Spec1
      netpay += PMPPjnl->NTH_Allce
      netpay += PMPPjnl->N_T_Allce
      netpay -= Pmppjnl->Spec_Pay
      netpay -= Pmppjnl->Spec_Pay1
      netpay -= Pmppjnl->Spec_Pay2
      nHours += Pmppjnl->Hours+Pmppjnl->HrsTH
      SKIP ALIAS Pmppjnl
   ENDDO                   // EOF()
   ntime := 0
   SELECT Labour
   GOTO TOP
      SEEK mcodeno
      DO WHILE Labour->Codeno = mcodeno .AND. Labour->( !EOF() )
      IF Labour->Date < mstmm
         SKIP ALIAS Labour
         LOOP
      ENDIF
      IF Labour->Date > mendmm
         SKIP ALIAS Labour
         LOOP
      ENDIF
      IF Labour->Partnum != SPACE( 20 )
         SKIP ALIAS Labour
         LOOP
      ENDIF
      ntime += Labour->Time
      SKIP ALIAS Labour
   ENDDO                   // EOF()
      @ nl,32 SAY nHours PICTURE "999,999.99"
      ***   @ nl,43 SAY ntime  PICTURE "999,999.99"
      @ nl,67 SAY nGross PICTURE "999,999.99"
      ***   @ nl,67 SAY netpay PICTURE "999,999.99"
      nl++
      SELECT Pmppjnl
      nTotTime  += nTime
      ntotGross += nGross
      ntotNett  += netPay
      nTotHours += nHours
      SKIP ALIAS Pmppjnl
   ENDDO                   // EOF()
   @ nl, 0 SAY REPLICATE( "-",77 )
   nl++
   @ nl,32 SAY nTotHours  PICTURE "999,999.99" 
      *** @ nl,43 SAY nTotTime   PICTURE "999,999.99"
   @ nl,66 SAY nTotGross  PICTURE "$999,999.99"
      *** @ nl,66 SAY nTotNett   PICTURE "$999,999.99"
   nl+=2
   nGrandTotal := 0 
   npos := 1
   nrow := 1
   SELECT Hist
   SET ORDER TO 2            // Partnum
   GOTO TOP
   DO WHILE Hist->( !EOF() )
      IF Hist->PDate < mstmm
         SKIP ALIAS Hist
         LOOP
      ENDIF
      IF Hist->PDate > mendmm
         SKIP ALIAS Hist
         LOOP
      ENDIF
      IF SUBSTR( Hist->Partnum, 1, 4 ) = "FREI"
         SKIP ALIAS Hist
         LOOP
      ENDIF
      ntotal:= ngrand := 0
      mpartnum := Hist->Partnum
      DO WHILE Hist->Partnum = mpartnum .AND. Hist->( !EOF() )
         IF Hist->PDate < mstmm
            SKIP ALIAS Hist
            LOOP
         ENDIF
         IF Hist->PDate > mendmm
            SKIP ALIAS Hist
            LOOP
         ENDIF
         IF SUBSTR( Hist->Partnum, 1, 4 ) = "FREI"
            SKIP ALIAS Hist
            LOOP
         ENDIF
         ntotal += Hist->Qty
         ngrand += Hist->Qty*Hist->Wholesale
         SKIP ALIAS Hist
      ENDDO                                 // Hist Partnum 
      @  nl,npos SAY " "+STR( ntotal, 6 )+" "+SUBSTR( mpartnum, 1, 8 );
                    +" "+STR( ngrand, 8 )
      npos := npos+26
      nrow++
      IF nrow = 4
         nl++
         nrow := 1
         npos := 1
      ENDIF              
      ***   SELECT Part
      ***   SEEK mpartnum
      SELECT Hist
      ngrandtotal += ngrand
      IF nl > npl
         IF mwhere = "P"
            EJECT 
          ELSE
            WAIT
            SCROLL()
         ENDIF
         nl := 0
      ENDIF                // npl
   ENDDO                   // Hist EOF()
   SELECT Hist
   SET ORDER TO 1            // Codeno
   nl++
   @ nl,66 SAY ngrandTotal PICTURE "$9,999,999.99" 
   IF mwhere = "P"
      EndPrint()
     ELSE
      IF nl > 18
        WAIT
      ENDIF
      mok := "N"
      DO WHILE mok = "N"
         mok := ApReadN()
      ENDDO
   ENDIF

   SELECT PMPPjnl
   SET RELATION TO

   RETURN NIL

   ***-----  End Program  MonthLab

   ***--------------------------------------------------------------------------

FUNCTION MetSlip()

   mok := ApGetY( "ALL Staff - No for One" )
   IF mok = "N"
   mcodeno := SPACE( 8 )
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
         AADD( aPart_,Name->Name;
                    +" "+Name->TaxCode; 
                    +" "+DTOC( Name->LastPaid );
                    +" "+DTOC( Name->Started );
                    +" "+DTOC( Name->EndDate );
                    +"           "+STR( RECNO(),6 ) )
         SKIP ALIAS Name
      ENDDO
      SCROLL()
      DISPBOX( 0, 1,  2,79, 2 )
      @  1,10 SAY "Select Name"
      DISPBOX( 3, 1, 24,79, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aCatcode_,,,{ | x,y | x < y } )
         anum := ACHOICE( 4, 3, 23,78,aPart_,,"AFUNC" )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         GOTO nrecno
         mcodeno := Name->Codeno
       ELSE
         @ 10,10 SAY "No Staff clasified go to Name File and Specify"
         INKEY( 2 )
         RETURN NIL
      ENDIF        // Empty
   ENDIF           // LastRec
      ENDIF                        // mok
      SCROLL( 17, 2,19,78 )
      mendmm := DATE()
      @  18,10 SAY "Period Ending "+( Months->Day7 )
      @  18,35 GET mendmm  PICTURE "99/99/9999"
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
      mwhere := "S"

       Printsel( mwhere )

      IF mwhere = "P"
         npl := 65
        ELSE
         npl := 14
      ENDIF
      SCROLL()
      mstmm := mendmm-6
   ncnt:= nl := 0
   netpay := 0
   SELECT Pmppjnl
   GO TOP
   DO WHILE Pmppjnl->( !EOF() )
      IF mok = "N"
         IF Pmppjnl->Codeno != mcodeno
            SKIP ALIAS Pmppjnl
            LOOP
         ENDIF
      ENDIF            // mok
      IF Pmppjnl->Pay_Per != mendmm
         SKIP ALIAS Pmppjnl
         LOOP
      ENDIF
      IF ncnt >= 3
         nl := 99
         ncnt := 0
      ENDIF                // ncnt
      IF nl > npl
         IF mwhere = "P"
            EJECT 
          ELSE
            WAIT
            SCROLL()
         ENDIF
         ncnt:= nl := 0
      ENDIF                // npl
      nl++
      @ nl, 3 SAY Control->U_Name
      ncnt++
      nl++
      SELECT Name
      SEEK Pmppjnl->Codeno
      @ nl, 4 SAY SUBSTR( Name->Name, 1,21 )+" "+TRIM( Name->Taxnum );
                  +" "+TRIM( Name->TaxCode )
      SELECT Pmppjnl
      @ nl,43 SAY "From "+SUBSTR( DTOC( mstmm ), 1 , 2 );
                                +"/"+SUBSTR( DTOC( mstmm ), 4 , 2 );
                                +"/"+SUBSTR( DTOC( mstmm ), 7 , 4 )
      @ nl,60 SAY "To"
      @ nl,63 SAY Pmppjnl->Pay_Per
      nl++ 
      IF Pmppjnl->HolHours > 0
         @ nl, 2 SAY "Holiday"
         @ nl,12 SAY Pmppjnl->HolRate  PICTURE "$99.99"
         @ nl,19 SAY Pmppjnl->HolHours PICTURE "999.99"
      ENDIF
      ***   @ nl,26 SAY PMPPjnl->TotHrs   PICTURE "999.99"
      @ nl,34 SAY "Hrs @"
      @ nl,40 SAY Pmppjnl->Payrate  PICTURE "$999.99"
      @ nl,64 SAY ( Pmppjnl->GrossPay-Pmppjnl->ProdBon );
                 -( Pmppjnl->Tax_Spec1+Pmppjnl->Spec_Pay3 ) PICTURE "$9,999.99"
      IF Pmppjnl->ProdBon > 0
         nl++
         @ nl,46 SAY "Bonus"
         @ nl,64 SAY Pmppjnl->ProdBon  PICTURE "$9,999.99"
      ENDIF
      IF Pmppjnl->Tax_Spec1 > 0
         nl++
         @ nl,46 SAY Name->TaxDesc1
         @ nl,64 SAY Pmppjnl->Tax_Spec1  PICTURE "$9,999.99"
      ENDIF
      IF Pmppjnl->Spec_Pay3 > 0  
         nl++
         @ nl,46 SAY Name->SpecDesc3
         @ nl,64 SAY Pmppjnl->Spec_Pay3 PICTURE "$9,999.99"
      ENDIF
      nl++
      @ nl,57 SAY "Gross"
      @ nl,64 SAY Pmppjnl->GrossPay PICTURE "$9,999.99"
      nl++                                                  
      @ nl,57 SAY "Paye"
      @ nl,64 SAY PMPPjnl->Paye     PICTURE "$9,999.99"
      netpay := Pmppjnl->GrossPay-Pmppjnl->Paye
      IF Pmppjnl->ChildSup > 0
         nl++
         @ nl,34 SAY "Child"
         @ nl,51 SAY Pmppjnl->ChildSup PICTURE "$9,999.99"
         netpay -= PMPPjnl->ChildSup
         @ nl,64 SAY netpay            PICTURE "$9,999.99"
      ENDIF
      IF PMPPjnl->DedSL > 0
         nl++
         @ nl,34 SAY "S/Loan"
         @ nl,51 SAY PMPPjnl->Dedsl PICTURE "$9,999.99"
         netpay -= PMPPjnl->DedSL
         @ nl,64 SAY netpay         PICTURE "$9,999.99"
      ENDIF
      IF PMPPjnl->KiwiSave > 0
         nl++
         @ nl,34 SAY "KiwiSave"
         @ nl,51 SAY PMPPjnl->KiwiSave PICTURE "$9,999.99"
         netpay -= PMPPjnl->KiwiSave
         @ nl,64 SAY netpay            PICTURE "$9,999.99"
      ENDIF
      IF PMPPjnl->KiwiEmpl > 0
         nl++
         @ nl,34 SAY "KiwiSave Empl"
         @ nl,51 SAY PMPPjnl->KiwiEmpl PICTURE "$9,999.99"
      ***      netpay -= PMPPjnl->KiwiEmpl
         @ nl,64 SAY netpay            PICTURE "$9,999.99"
      ENDIF
      IF Pmppjnl->NT_Spec1 > 0
         nl++
         @ nl,34 SAY Name->NTDesc1
         @ nl,51 SAY Pmppjnl->NT_Spec1  PICTURE "$9,999.99"
         netpay += Pmppjnl->NT_Spec1
         @ nl,64 SAY netpay             PICTURE "$9,999.99"
      ENDIF
      IF PMPPjnl->NTH_Allce > 0
         nl++
         @ nl,34 SAY "Hr Non Tax Allce"
         @ nl,51 SAY PMPPjnl->NTH_Allce PICTURE "$9,999.99"
         netpay += PMPPjnl->NTH_Allce
         @ nl,64 SAY netpay             PICTURE "$9,999.99"
      ENDIF
      IF PMPPjnl->N_T_Allce > 0
         nl++
         @ nl,34 SAY "Non Tax Allce"
         @ nl,51 SAY PMPPjnl->N_T_Allce PICTURE "$9,999.99"
         netpay += PMPPjnl->N_T_Allce
         @ nl,64 SAY netpay             PICTURE "$9,999.99"
      ENDIF
      IF Pmppjnl->Spec_Pay > 0  
         nl++ 
         @ nl,34 SAY Name->SpecDesc
         @ nl,51 SAY Pmppjnl->Spec_Pay  PICTURE "$9,999.99"
         netpay -= Pmppjnl->Spec_Pay
         @ nl,64 SAY netpay             PICTURE "$9,999.99"
      ENDIF
     IF Pmppjnl->Spec_Pay1 > 0  
         nl++ 
         @ nl,34 SAY Name->SpecDesc1
         @ nl,51 SAY Pmppjnl->Spec_Pay1 PICTURE "$9,999.99"
         netpay -= Pmppjnl->Spec_Pay1
         @ nl,64 SAY netpay             PICTURE "$9,999.99"
      ENDIF
      IF Pmppjnl->Spec_Pay2 > 0  
         nl++
         @ nl,34 SAY Name->SpecDesc2
         @ nl,51 SAY Pmppjnl->Spec_Pay2 PICTURE "$9,999.99"
         netpay -= Pmppjnl->Spec_Pay2
         @ nl,64 SAY netpay             PICTURE "$9,999.99"
      ENDIF 
      nl++                                                    // line 10/24/38/52
      @ nl,57 SAY "Nett"
      @ nl,64 SAY netpay PICTURE "$9,999.99"
      nl+=2
      @  nl,17 SAY SUBSTR( Months->Day1,1, 3 )+"    "+;
                   SUBSTR( Months->Day2,1, 3 )+"    "+;
                   SUBSTR( Months->Day3,1, 3 )+"    "+;
                   SUBSTR( Months->Day4,1, 3 )+"    "+;
                   SUBSTR( Months->Day5,1, 3 )+"    "+;
                   SUBSTR( Months->Day6,1, 3 )+"    "+;
                   SUBSTR( Months->Day7,1, 3 )
      nl++
      nTotHrs   := Pmppjnl->Day1+Pmppjnl->Day2+Pmppjnl->Day3;
                  +Pmppjnl->Day4+Pmppjnl->Day5+Pmppjnl->Day6;
                  +Pmppjnl->Day7
      @ nl,10 SAY "Std   "+STR( Pmppjnl->Day1 );
                     +"  "+STR( Pmppjnl->Day2 );
                     +"  "+STR( Pmppjnl->Day3 );
                     +"  "+STR( Pmppjnl->Day4 );
                     +"  "+STR( Pmppjnl->Day5 );
                     +"  "+STR( Pmppjnl->Day6 );
                     +"  "+STR( Pmppjnl->Day7 )
      @ nl,65 SAY nTotHrs PICTURE "999.99"
      nl++ 
      IF Pmppjnl->HrsTH > 0
         nTotTH := Pmppjnl->Day1TH+Pmppjnl->Day2TH+Pmppjnl->Day3TH;
                  +Pmppjnl->Day4TH+Pmppjnl->Day5TH+Pmppjnl->Day6TH;
                  +Pmppjnl->Day7TH
         @ nl,10 SAY "Hr+1/2"+STR( Pmppjnl->Day1TH );
                        +"  "+STR( Pmppjnl->Day2TH );
                        +"  "+STR( Pmppjnl->Day3TH );                                                                       
                        +"  "+STR( Pmppjnl->Day4TH );
                        +"  "+STR( Pmppjnl->Day5TH );
                        +"  "+STR( Pmppjnl->Day6TH );
                        +"  "+STR( Pmppjnl->Day7TH )                                                                                                                                                                                         
         @ nl,65 SAY nTotTH     PICTURE "999.99"
    ***     @ nl,74 SAY nTotTH*1.5 PICTURE "999.99"
      ENDIF
      nl++
      IF Pmppjnl->HolHours > 0
         nTotHol := Pmppjnl->Day1Hol+Pmppjnl->Day2Hol+Pmppjnl->Day3Hol;
                   +Pmppjnl->Day4Hol+Pmppjnl->Day5Hol+Pmppjnl->Day6Hol;
                   +Pmppjnl->Day7Hol
         @ nl, 1 SAY Pmppjnl->HolRate PICTURE "$99.99"
         @ nl,10 SAY "Hol   "+STR( Pmppjnl->Day1Hol );
                        +"  "+STR( Pmppjnl->Day2Hol );
                        +"  "+STR( Pmppjnl->Day3Hol );                                                                       
                        +"  "+STR( Pmppjnl->Day4Hol );
                        +"  "+STR( Pmppjnl->Day5Hol );
                        +"  "+STR( Pmppjnl->Day6Hol );
                        +"  "+STR( Pmppjnl->Day7Hol )                                                                                                                                                                                         
         @ nl,65 SAY nTotHol PICTURE "999.99"
      ENDIF
      nl++     // must be standard
      IF Pmppjnl->SickTotal > 0
         @ nl,10 SAY "      "+STR( Pmppjnl->Day1Sick )+Pmppjnl->Day1S_B;
                         +" "+STR( Pmppjnl->Day2Sick )+Pmppjnl->Day2S_B;            
                         +" "+STR( Pmppjnl->Day3Sick )+Pmppjnl->Day3S_B;            
                         +" "+STR( Pmppjnl->Day4Sick )+Pmppjnl->Day4S_B;            
                         +" "+STR( Pmppjnl->Day5Sick )+Pmppjnl->Day5S_B;            
                         +" "+STR( Pmppjnl->Day6Sick )+Pmppjnl->Day6S_B;            
                         +" "+STR( Pmppjnl->Day7Sick )+Pmppjnl->Day7S_B             
         @ nl,65 SAY Pmppjnl->SickTotal PICTURE "999.99"
         nl++
   /*
   Taken Out
         @ nl,10 SAY "Sick "+STR( Pmppjnl->SickHrs, 6, 2 );
                    +"   Bereav "+STR( Pmppjnl->BerHrs, 6, 2 );
                    +"   Public Hols "+STR( Pmppjnl->PubHrs, 6, 2 )
   Taken Out
   */
      ENDIF
   SELECT Pmppjnl
   nrecno  := RECNO()
   mcodeno := Pmppjnl->Codeno
   GOTO TOP
   nGrossPay:= nPaye:= nkiwisave:= nkiwiempl := 0
   SEEK mcodeno
   DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() )
      ***   IF YEAR( Pmppjnl->Pay_Per ) != YEAR( mendmm )
      IF Pmppjnl->Pay_Per < Control->Acc_Date
         SKIP ALIAS Pmppjnl
         LOOP
      ENDIF
      IF Pmppjnl->Pay_Per > mendmm
         SKIP ALIAS Pmppjnl
         LOOP
      ENDIF
      nGrossPay += Pmppjnl->GrossPay
      nPaye     += Pmppjnl->Paye
      nkiwisave += Pmppjnl->Kiwisave
      nkiwiempl += Pmppjnl->KiwiEmpl
      SKIP ALIAS Pmppjnl
   ENDDO               // EOF Pmppjnl
   nl++
   @  nl, 8 SAY "Acc Yr 01/04"
   @  nl,22 SAY YEAR( mendmm )
   @  nl,29 SAY "To"
   @  nl,32 SAY mendmm
   nl++
   @  nl, 6 SAY "Gross Y.T.D From 01/04"
   @  nl,29 SAY nGrossPay PICTURE "$999,999.99"
   @  nl,42 SAY "Paye"
   @  nl,47 SAY nPaye     PICTURE "$999,999.99"
   nl++
   @  nl, 6 SAY "KiwiSave"
   @  nl,16 SAY nkiwisave PICTURE "$999,999.99"
   @  nl,28 SAY "Kiwi Employer"
   @  nl,42 SAY nkiwiempl PICTURE "$999,999.99"
      GOTO nrecno 
      nl+=2
      @ nl, 8 SAY TRIM( Name->Bank )+" "+TRIM( Name->BankBranch );
                  +"  "+Name->Bankno
      nl+=2
       IF Name->Desc != SPACE( 50 )
         @ nl, 6 SAY Name->Desc
         nl++
      ENDIF
      IF Name->Desc1 != SPACE( 50 )
         @ nl, 6 SAY Name->Desc1
         nl++
      ENDIF
      IF Name->Desc2 != SPACE( 50 )
         @ nl, 6 SAY Name->Desc2
         nl++
      ENDIF
      IF Name->Desc3 != SPACE( 50 )
         @ nl, 6 SAY Name->Desc3
         nl++
      ENDIF
      SELECT Menu1
      IF Menu1->Note != SPACE( 60 )
         @ nl, 8 SAY Menu1->Note
         nl++
      ENDIF
      IF Menu1->Note1 != SPACE( 60 )
         @ nl, 8 SAY Menu1->Note1
         nl++
      ENDIF
      IF Menu1->Note2 != SPACE( 60 )
         @ nl, 8 SAY Menu1->Note2
         nl++
      ENDIF
      IF Menu1->Note3 != SPACE( 60 )
         @ nl, 8 SAY Menu1->Note3
         nl++
      ENDIF
      @ nl, 3 SAY REPLICATE( "-",68 )
      nl++
      SELECT Pmppjnl
      SKIP ALIAS Pmppjnl
   ENDDO                   // EOF()
   IF mwhere = "P"
      EndPrint()
    ELSE
      WAIT
   ENDIF

   RETURN NIL

   ***-----  End Program  --  METSLIP  **

   ***--------------------------------------------------------------------------

FUNCTION MetPaye()

   manother := "Y"
   DO WHILE manother = "Y"
      SCROLL()
      DISPBOX( 0, 1, 24,78, 2 )
      @  1, 10 SAY "Select Report" 
      nsel := 1
      @  4,10 PROMPT "1.  Monthly ( IR 345 )"
      @  5,10 PROMPT "2.  Monthly ( IR 348 )" 
      @  7,10 PROMPT "3.  Year-to-Date      "
      @  8,10 PROMPT "4.  Time Slips        "
      @  9,10 PROMPT "5.  Weekly Time Sheet "
      @ 10,10 PROMPT "6.  Edit All Slips    "
      @ 11,10 PROMPT "7.  Edit Tax Rates    "
      @ 12,10 PROMPT "8.  Monthly Time Slips"
      @ 14,10 PROMPT "9.  Monthly All Deduct" 
      @ 16,10 PROMPT "10. Labour Results    " 
      @ 17,10 PROMPT "11. Monthly Labour    " 

      MENU TO nsel
      DO CASE
         CASE nsel == 12 .OR. PressedEsc()
             RETURN NIL
         CASE nsel == 1
              IR345()              // PmpTime1
             manother := "Y"
             LOOP  
         CASE nsel == 2
              IR348()              // PmpTime1
             manother := "Y"
             LOOP  
         CASE nsel == 3
              Y2DPAY()              // Below    
             manother := "Y"
             LOOP
         CASE nsel == 4
              MetSlip()             // Below
             manother := "Y"
             LOOP
         CASE nsel == 5
              WeekTime()            // PMPTime1
             manother := "Y"
             LOOP 
         Case nsel == 6
              MetEdit()             // Below 
             manother := "Y"
             LOOP
         CASE nsel == 7
              AmdTaxRate()          // Below
             manother := "Y"
             LOOP  
         CASE nsel == 8
              CurrPay()             // PmpTime1 
             manother := "Y"
             LOOP
         CASE nsel == 9
              IR348ALL()              // PmpTime1
             manother := "Y"
             LOOP  
         CASE nsel == 10
              WeekLabour()            // PmpTime1
             manother := "Y"
             LOOP
         CASE nsel == 11
              MonthLab()            // Above
             manother := "Y"
             LOOP
      ENDCASE
      manother := ApGetN( TRIM( Message->Another ) )
      IF PressedEsc()
         RETURN NIL
      ENDIF
   ENDDO

   RETURN NIL
   **  END PROGRAM  METPAYE  **

   ***------------------------------------------------------------------------

FUNCTION MetName( mcodeno )

   SCROLL()

   SELECT Name
    ApRlock( 3 )
   mcorrect = "N"
   DO WHILE mcorrect = "N"  
       SELECT Name
       cmap := SUBSTR( Name->Map, 1, 1 )
       ApRlock( 3 )
       DISPBOX( 0, 1, 2,78, 2 )
       @  1, 5      SAY Name->Name
       DISPBOX( 3, 1, 24,78, 2 )
       @  4, 3      SAY "IRD Number"       GET Name->Taxnum
       @  4,COL()+2 SAY "Tax Code"         GET Name->TaxCode PICTURE "@!"
       @  4,COL()+2 SAY "Pay Rate"         GET Name->PayRate
       @  5, 3      SAY "ACC Code  "       GET Name->ACCCode
       @  6, 3      SAY "Started   "       GET Name->Started
       @  6,COL()+2 SAY "Date of Birth"    GET Name->DOBirth 
       @  7, 3      SAY "Bank Name "       GET Name->Bank   PICTURE "@!"
       @  7,COL()+2 SAY "Bank Branch"      GET Name->BankBranch 
       @  8, 3      SAY "Bank Acc #"       GET Name->Bankno
       @  8,COL()+2 SAY "REF #"            GET Name->Refno
       Name->Pay_Freq := "1" 
   ***         @ 10, 3      SAY "Pay Freq 1,2,3,4 Weeks M = Monthly"
   ***         @ 10,COL()+2                        GET Name->Pay_Freq;
   ***                        VALID( Name->Pay_Freq $ "1,2,3,4,M" ) PICTURE "@!"

       @ 11, 3      SAY "N/T Allowance Hourly" GET Name->NTH_Allce
       @ 11,COL()+2 SAY "N/T Weekly"           GET Name->N_T_Allce
       @ 11,COL()+2 SAY "Prod Bonus"           GET Name->ProdBon   PICTURE "9999.99"
       @ 12, 3      SAY "Child Support Amnt"   GET Name->Childsup  PICTURE "9999.99" 
       @ 12,COL()+2 SAY "CS Code"              GET Name->Cscode    PICTURE "@!"
       @ 12,COL()+2 SAY "Last Paid "           GET Name->LastPaid
       @ 13, 3      SAY "Taxable Special"      GET Name->TaxDesc1
       @ 13,COL()+2 SAY "Amount/Week"          GET Name->Tax_Spec1
       @ 14, 3      SAY "Non Taxable Add"      GET Name->NTDesc1
       @ 14,COL()+2 SAY "Amount/Week"          GET Name->NT_Spec1
       @ 15, 3      SAY "Deduct Special "      GET Name->SpecDesc 
       @ 15,COL()+2 SAY "Amount/Week"          GET Name->Spec_Pay  PICTURE "9999.99"
       @ 16, 3      SAY "Ded Special 1  "      GET Name->SpecDesc1
       @ 16,COL()+2 SAY "Amount/Week"          GET Name->Spec_Pay1 PICTURE "9999.99"
       @ 17, 3      SAY "Ded Special 2  "      GET Name->SpecDesc2
       @ 17,COL()+2 SAY "Amount/Week"          GET Name->Spec_Pay2
       @ 18, 3      SAY "Taxable Amount "      GET Name->SpecDesc3
       @ 18,COL()+2 SAY "Amount/Week"          GET Name->Spec_Pay3
       @ 19, 3      SAY "Bereavment Hrs "      GET Name->BerAvail  PICTURE "999.99"
       @ 19,COL()+2 SAY "Holiday Hrs"          GET Name->HolAvail  PICTURE "999.99"
       @ 20, 3      SAY "Gross Last Year"      GET Name->GrLstYr   PICTURE "999999.99"
       @ 20,COL()+2 SAY "10.5,17.5,30, 33 ESCT Rate %"  GET Name->Rate      PICTURE "999.99"
       @ 21, 3      SAY "Public Hol Hrs "      GET Name->PubAvail  PICTURE "999.99"
       @ 21,COL()+2 SAY "Sick Avail Hrs"       GET Name->SickAvail PICTURE "999.99"
       @ 22, 3      SAY "Kiwi Saver   % "      GET Name->KiwiSave  PICTURE "999"  
       @ 22,COL()+2 SAY "Employer Kiwi % "     GET Name->KiwiEmpl  PICTURE "999"  
       @ 22,COL()+2 SAY "Tax Credit # 11"      GET cmap VALID( cmap $"NY" ) PICTURE "!"  
       @ 22,COL()+2 SAY "N or Y" COLOR "BG+"   
        READ
       Name->Map := cmap
       IF PressedEsc()
          RETURN NIL
       ENDIF
       SCROLL( 4, 2,24,78 )
       @  4, 3      SAY "Name :"         GET Name->Name     PICTURE "@!"
       @  4,COL()+2 SAY Name->Codeno
       @  6, 3      SAY "Title"          GET Name->Title    PICTURE "@X"
       @  6,COL()+2 SAY "First Name"     GET Name->Called   PICTURE "@X"
       @  6,COL()+2 SAY "Family Name"    GET Name->FamName  PICTURE "@X"
       @  7, 3      SAY "St   :"         GET Name->Add1     PICTURE "@X"
       @  8, 3      SAY "Box. :"         GET Name->Add2     PICTURE "@KX"
       @  9, 8      SAY ":"              GET Name->Add3     PICTURE "@X"
       @ 10, 3      SAY "City :"         GET Name->Add4     PICTURE "@KX"
       @ 11, 3      SAY "Cntry "         GET Name->Add5     PICTURE "@K!"
       @ 11,COL()+1 SAY "Zip"            GET Name->Zip      PICTURE "@X"
       @  7,45      SAY "Priv Phone :"   GET Name->Ephone   PICTURE "@X"
       @  8,45      SAY "Bus  Phone :"   GET Name->Phone    PICTURE "@X"
       @  9,45      SAY "Fax Number :"   GET Name->Bphone   PICTURE "@X"
       @ 10,45      SAY "Mobile     :"   GET Name->MobPhone PICTURE "@X"
       @ 13, 3      SAY "Email "         GET Name->Email    PICTURE "@X"
       @ 15, 3      SAY "Desc"           GET Name->Desc     PICTURE "@X"
       @ 16, 3      SAY "    "           GET Name->Desc1    PICTURE "@X"
       @ 17, 3      SAY "    "           GET Name->Desc2    PICTURE "@X"
       @ 18, 3      SAY "    "           GET Name->Desc3    PICTURE "@X"
       @ 20, 3      SAY "Finished Date"  GET Name->Enddate  PICTURE "99/99/9999"
       @ 20,COL()+2 SAY "Todays Date-400 days To Edit"
        READ
       UNLOCK
       mcorrect := ApGetY( TRIM( Message->Correct ) ) 
   ENDDO

   RETURN mcodeno

   **---------- End MetName

   **------------------------------------------------------------------------

FUNCTION MetEdit()

   manother := "Y"
   DO WHILE manother = "Y"
      SCROLL()
      mstmm  := DATE()-30
      mendmm := DATE()
      @ 10,30 SAY Message->Frdate GET mstmm  PICTURE "99/99/9999"
      @ 11,30 SAY Message->Todate GET mendmm PICTURE "99/99/9999"
       READ
      SELECT Pmppjnl
      GOTO TOP
      aPart_:={}
      nrecno := 0
   IF LASTREC() != 0
      DO WHILE Pmppjnl->( !EOF() )
         IF Pmppjnl->Pay_Per < mstmm
            SKIP ALIAS Pmppjnl
            LOOP
         ENDIF
         IF Pmppjnl->Pay_Per > mendmm
            SKIP ALIAS Pmppjnl
            LOOP
         ENDIF
         AADD( aPart_,Pmppjnl->Codeno;
                    +" "+DTOC( Pmppjnl->Pay_Per );
                    +" "+STR( Pmppjnl->PayRate ); 
                    +" "+STR( Pmppjnl->TotHrs ); 
                    +" "+STR( Pmppjnl->GrossPay ); 
                    +" "+STR( Pmppjnl->DedSL );
                    +" "+STR( Pmppjnl->Paye );
                    +" "+STR( Pmppjnl->NettPay );
                    +"                  "+STR( RECNO(),6 ) )
         SKIP ALIAS Pmppjnl
      ENDDO
      SCROLL()
      DISPBOX( 0, 1,  2,79, 2 )
      @  1,10 SAY "Select Tax to Delete"
      DISPBOX( 3, 1, 24,79, 2 )
      @  3, 4 SAY " Codeno   Date          Rate     Hrs    Gross   Student     Paye   Net "
      IF !EMPTY( aPart_ )
         ASORT( aCatcode_,,,{ | x,y | x < y } )
         anum := ACHOICE( 4, 5, 23,76,aPart_,,"AFUNC" )
         nrecno := VAL( RIGHT( aPart_[anum],6 ) )
         IF PressedEsc()
            RETURN NIL
         ENDIF
         GOTO nrecno
      ENDIF        // Empty
   ENDIF           // LastRec
     SCROLL( 15, 2, 22,78 )
     @ 16,10      SAY Pmppjnl->Codeno
     @ 16,COL()+2 SAY Pmppjnl->Pay_Per
     @ 16,COL()+2 SAY Pmppjnl->TotHrs 
     @ 16,COL()+2 SAY Pmppjnl->Paye
     @ 17,10      SAY Pmppjnl->GrossPay 
     @ 17,COL()+2 SAY Pmppjnl->PayRate
     mok := ApGetN( TRIM( Message->Delete ) )  
     IF mok = "Y"                                      // Delete
        SELECT Pmppjnl
         ApRLock( 3 )
        DELETE
        UNLOCK
        LOOP
     ENDIF 
     mok := "N"
     DO WHILE mok = "N"
        SELECT Pmppjnl
         ApRLock( 3 )
        SCROLL( 12, 2, 23,78 )
        @ 14, 5      SAY "Date      " GET Pmppjnl->Pay_Per   PICTURE "99/99/9999"
        @ 14,COL()+2 SAY "Tot Hrs"    GET Pmppjnl->TotHrs    PICTURE "999.99" 
        @ 14,COL()+2 SAY "Hours"      GET Pmppjnl->Hours     PICTURE "999.99" 
        @ 14,COL()+2 SAY "Tax"        GET Pmppjnl->Paye      PICTURE "9999.99"
        @ 15, 5      SAY "Gross     " GET Pmppjnl->GrossPay  PICTURE "9999.99" 
        @ 15,COL()+2 SAY "Rate"       GET Pmppjnl->PayRate   PICTURE "9999.99"
        @ 15,COL()+2 SAY "Time+1/2"   GET Pmppjnl->HrsTH     PICTURE "999.99"
        @ 16, 5      SAY "Prod Bonus" GET Pmppjnl->ProdBon   PICTURE "9999.99" 
        @ 16,COL()+2 SAY "S/Loan"     GET Pmppjnl->DedSl     PICTURE "9999.99"
        @ 17, 5      SAY "Nett Pay  " GET Pmppjnl->NettPay   PICTURE "9999.99" 
        @ 17,COL()+2 SAY "N/T Week  " GET Pmppjnl->N_T_Allce PICTURE "9999.99"
        @ 17,COL()+2 SAY "N/T Hrly  " GET Pmppjnl->NTH_Allce PICTURE "9999.99"
        @ 18, 5      SAY "Ded Spec"   GET Pmppjnl->Spec_Pay  PICTURE "9999.99" 
        @ 18,COL()+2 SAY "Ded Spec 1" GET Pmppjnl->Spec_Pay1 PICTURE "9999.99"
        @ 18,COL()+2 SAY "Ded Spec 2" GET Pmppjnl->Spec_Pay2 PICTURE "9999.99"
        @ 19, 5      SAY "Taxable   " GET Pmppjnl->Spec_Pay3 PICTURE "9999.99"
        @ 21, 5      SAY "Tax Spec 1" GET Pmppjnl->Tax_Spec1 PICTURE "99999.99" 
        @ 21,COL()+2 SAY "NT Spec 1"  GET Pmppjnl->NT_Spec1  PICTURE "99999.99"
        @ 21,COL()+2 SAY "Base Pay"   GET Pmppjnl->BasePay   PICTURE "9999.99" 
        @ 22, 5      SAY "Kiwi Save " GET Pmppjnl->KiwiSave  PICTURE "9999.99" 
        @ 22,COL()+2 SAY "Empl Kiwi"  GET Pmppjnl->KiwiEmpl  PICTURE "9999.99" 
         READ
        mok := ApGetY( TRIM( Message->Correct ) )
        UNLOCK
      ENDDO
      manother := ApGetY( TRIM( Message->Another ) )
   ENDDO

   RETURN NIL
   ***---------- End MetEdit

   ***------------------------------------------------------------------------

STATIC FUNCTION AMDTAXRATE()  // Amend Tax Rates

   mcontinue := "N"
   DO WHILE mcontinue = "N"
      SCROLL()
      DISPBOX( 1, 1, 24,79 )
      SELECT TaxRates
       ApRLock( 3 ) 

      @  2,15 SAY Taxrates->UpdHdg COLOR c_hicolor
     // "These are annual income figures"
     @  4,10      GET TaxRates->Txtbrk1
     @  5,10      SAY "%" GET TaxRates->Brk1Rate        PICTURE "99.99"
     @  5,COL()+2 SAY "Income Up To" GET TaxRates->Brk1 PICTURE "999999"
     @  6,10      GET TaxRates->Txtbrk2
     @  7,10      SAY "%" GET TaxRates->Brk2Rate        PICTURE "99.99"
     @  7,COL()+2 SAY "Income Over" GET TaxRates->Brk2  PICTURE "999999"
     @  8,10      GET TaxRates->Txtbrk3
     @  9,10      SAY "%" GET TaxRates->Brk3Rate        PICTURE "99.99"
     @  9,COL()+2 SAY "Income Over" GET TaxRates->Brk3  PICTURE "999999"
     @ 10,10      GET TaxRates->Txtbrk4
     @ 11,10      SAY "%" GET TaxRates->Brk4Rate        PICTURE "99.99"
     @ 11,COL()+2 SAY "Income Over" GET TaxRates->Brk4  PICTURE "999999"
     @ 12,10      GET TaxRates->Txtbrk5
     @ 13,10      SAY "%" GET TaxRates->Brk5Rate        PICTURE "99.99"
     @ 13,COL()+2 SAY "Income Over" GET TaxRates->Brk5  PICTURE "999999"
     @ 14,10      GET Taxrates->Slwkly
     @ 15,10      GET Taxrates->SL_Thresh               PICTURE "999999"
     @ 16,10      GET Taxrates->SecRate
     @ 17,10      SAY "%" GET Taxrates->Sec_Rate        PICTURE "99.99"
      READ
      ***  @ 15,COL()+2 GET TaxRates->elp    PICTURE "999999"
      ***  @ 12,44 GET nelpmax PICTURE "999999"
       UNLOCK
        mcontinue := ApGetY( TRIM( Message->Correct )+" Tax Rates"  )
   ENDDO               // mcontinue

   RETURN NIL

   **--  End Function -- AMDTAXRATE

   ***------------       End of PMPPAYE.PRG
