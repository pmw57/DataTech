   *** JK  25-06-10 08:29:51 

/*
   Program.....: PMPTIME2.PRG  --  Analysis of Labour and Salary
   Function....: StaffJCSal
*/

FUNCTION StaffJCSal()

   SCROLL()
   npl := 19 
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
         AADD( aPart_,Name->Codeno+"   "+Name->Name;
                    +"                      "+STR( RECNO(),6 ) )
         SKIP ALIAS Name
      ENDDO
      SCROLL()
      DISPBOX( 0, 1,  2,79, 2 )
      @  1,10 SAY "Select Name"
      DISPBOX( 3, 1, 24,36, 2 )
      IF !EMPTY( aPart_ )
         ASORT( aCatcode_,,,{ | x,y | x < y } )
         anum := ACHOICE( 4, 3, 23,34,aPart_,,"AFUNC" )
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
   SCROLL()
   DISPBOX( 0, 1,18,79, 2 )
   @  1,20 SAY "JC Salary Individual Analysis"
   @  6,10 SAY Name->Name 
   mstmm  := DATE()-30
   mendmm := DATE()
   @ 10, 5 SAY Message->Frdate GET mstmm  PICTURE "99/99/9999"
   @ 11, 5 SAY Message->Todate GET mendmm PICTURE "99/99/9999"
    READ
   IF PressedEsc()
      RETURN NIL
   ENDIF
   mwhere   := "S"

     Printsel( mwhere )

   IF mwhere == "P"
      npl := 56
    ELSE
      SCROLL()
      npl := 23
   ENDIF
   @  0, 0 SAY SUBSTR( Control->U_Name, 1,28 )
   @  0,32 SAY mstmm 
   @  0,44 SAY mendmm 
   @  0,62 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                +STR( YEAR(DATE() ),5 )
   nl := 2
      cLabno := SPACE( 8 )
      mInvno := SPACE( 6 )
      cDesc  := SPACE( 40 )
      nGrandTot := 0
      SELECT Labour
      GOTO TOP
       ApFLock( 3 )
      INDEX ON Invno TO LabInv
      SET INDEX TO LabInv
      UNLOCK
      GOTO TOP
      DO WHILE Labour->( !EOF() )
          IF Labour->Codeno != mcodeno
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Invno = SPACE( 6 )
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Partnum != SPACE( 20 )
            SKIP ALIAS Labour
            LOOP
         ENDIF
         nTime:= nTimeTot := 0
         cLabno   := Labour->Labno
         cDesc    := Labour->Desc
         mInvno   := Labour->Invno
         DO WHILE Labour->Invno = mInvno .AND. Labour->( !EOF() )
            IF Labour->Codeno != mcodeno
               SKIP ALIAS Labour
               LOOP
            ENDIF
      ***         IF Labour->Partnum != SPACE( 20 )
      ***            SKIP ALIAS Labour
      ***            LOOP
      ***         ENDIF
            IF Labour->Partnum = SPACE( 20 )
               nTime  += Labour->Time
            ENDIF
            IF Labour->Date < mstmm
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF Labour->Date > mendmm
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF Labour->Time = 0
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF Labour->Invno = SPACE( 6 )
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF nl > npl
               IF mwhere == "P"
                   EJECT
                  ELSE
                   WAIT
                  SCROLL()
               ENDIF
               @  0, 0 SAY Control->U_Name
               @  0,34 SAY mstmm 
               @  0,47 SAY mendmm 
               @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                          +STR( YEAR(DATE() ),5 )
               nl := 2
            ENDIF                       // nl>npl
            IF Labour->Partnum = SPACE( 20 )
               nTimeTot  += Labour->Time
               nGrandtot += Labour->Time
            ENDIF
            SKIP ALIAS Labour
         ENDDO                                     // Date
         IF nTimeTot > 0
            @ nl, 0 SAY cLabno
            @ nl, 9 SAY cDesc
            @ nl,50 SAY mInvno
            @ nl,57 SAY nTimeTot PICTURE "99,999.99"
      ***         @ nl,67 SAY nTime    PICTURE "99,999.99"
            nl++
         ENDIF
      ENDDO
      IF nGrandTot > 0
         @ nl,56 SAY "----------"
         nl++
         @ nl, 3 SAY Name->Name
         @ nl,45 SAY "Total Time"
         @ nl,57 SAY nGrandtot PICTURE "99,999.99"
         nl+=2
      ENDIF
   */
      cLabno := SPACE( 8 )
      mInvno := SPACE( 6 )
      cDesc  := SPACE( 40 )
      nGrandTot := 0
      SELECT Labour
      GOTO TOP
      DO WHILE Labour->( !EOF() )
         IF Labour->Codeno != mcodeno
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Invno = SPACE( 6 )
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Partnum = SPACE( 20 )
            SKIP ALIAS Labour
            LOOP
         ENDIF
         nTime:= nTimeTot := 0
         cLabno   := Labour->Labno
         mInvno   := Labour->Invno
         DO WHILE Labour->Invno = mInvno .AND. Labour->( !EOF() )
            IF Labour->Codeno != mcodeno
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF Labour->Partnum = SPACE( 20 )
               SKIP ALIAS Labour
               LOOP
            ENDIF
            nTime  += Labour->Time*Labour->Rate
            IF Labour->Date < mstmm
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF Labour->Date > mendmm
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF Labour->Time = 0
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF Labour->Invno = SPACE( 6 )
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF nl > npl
               IF mwhere == "P"
                   EJECT
                  ELSE
                   WAIT
                  SCROLL()
               ENDIF
               @  0, 0 SAY Control->U_Name
               @  0,34 SAY mstmm 
               @  0,47 SAY mendmm 
               @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                          +STR( YEAR(DATE() ),5 )
               nl := 2
            ENDIF                       // nl>npl
            nTimeTot  += Labour->Time*Labour->Rate
            nGrandtot += Labour->Time*Labour->Rate
            SKIP ALIAS Labour
         ENDDO                                     // Date
         IF nTimeTot > 0
            @ nl, 0 SAY cLabno
            @ nl,42 SAY mInvno
            @ nl,52 SAY nTimeTot PICTURE "9,999,999.99"
     ***       @ nl,65 SAY nTime    PICTURE "9,999,999.99"
            nl++
         ENDIF
      ENDDO
   */
   /*
   TAKEN OUT
      IF nGrandTot > 0
         @ nl,55 SAY "------------"
         nl++
         @ nl,40 SAY "Total Parts"
         @ nl,55 SAY nGrandtot PICTURE "$999,999.99"
         nl+=2
      ENDIF
      SELECT Labour
      SET INDEX TO LabInd
      GOTO TOP
      nTimeRate:= nTimeTotal := 0
      DO WHILE Labour->( !EOF() )
         IF Labour->Codeno != mcodeno
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Partnum != SPACE( 20 )
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Codeno = SPACE( 8 )
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Date < mstmm
            SKIP ALIAS Labour
            LOOP
         ENDIF
         IF Labour->Date > mendmm
            SKIP ALIAS Labour
            LOOP
         ENDIF
         mcode := Labour->Codeno
         nCodeTot := 0
         DO WHILE Labour->Codeno = mcode .AND. Labour->( !EOF() )
            IF nl > npl
               IF mwhere == "P"
                   EJECT
                 ELSE
                   WAIT
                   SCROLL()
                ENDIF
               @  0, 0 SAY Control->U_Name
               @  0,34 SAY mstmm 
               @  0,47 SAY mendmm 
               @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                          +STR( YEAR(DATE() ),5 )
               nl := 2
            ENDIF                       // nl>npl
            IF Labour->Codeno != mcodeno
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF Labour->Partnum != SPACE( 20 )
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF Labour->Date < mstmm
               SKIP ALIAS Labour
               LOOP
            ENDIF
            IF Labour->Date > mendmm
               SKIP ALIAS Labour
               LOOP
            ENDIF
            nCodeTot   += Labour->Time
            nTimeTotal += Labour->Time
            SKIP ALIAS Labour
         ENDDO                // mcode
         @ nl, 0 SAY mcode
         SELECT Name
         SEEK mcode
         @ nl,11 SAY Name->Name
         SELECT Labour  
         @ nl,52 SAY ncodeTot PICTURE "99,999.99"
         nl++
     ENDDO                // EOF Labour
   @ nl,51 SAY "-----------"
   nl++
   @ nl,38 SAY "Total Time"
   @ nl,52 SAY nTimeTotal    PICTURE "99,999.99"
   nl++
   @ nl,51 SAY "==========="
   Taken Out
   */
         IF nl > npl
            IF mwhere == "P"
                EJECT
              ELSE
                WAIT
                SCROLL()
             ENDIF
            @  0, 0 SAY Control->U_Name
            @  0,34 SAY mstmm 
            @  0,47 SAY mendmm 
            @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ),5 )
            nl := 2
         ENDIF                       // nl>npl
      nl+=2
      @ nl,13 SAY "Std Hrs    TH Hrs   Total  P/H  Tot      P/L   Ann Holiday"
      nl++
      SELECT Pmppjnl
      GOTO TOP
      nHours:= nHrsTH:= nTotHrs := 0
      nHolHours:= nSickTotal:= nSickHrs:= nBerHrs:= nPubHrs := 0
      nkiwisave:= nkiwiempl := 0 
      nHoursTotal:= nHrsTHTotal:= nTotHrsTotal := 0
      nSickTTot:= nSickHrsTot:= nBerHrsTot:= nPubHrsTot:= nHolHoursTot := 0
      DO WHILE Pmppjnl->( !EOF() )
         IF Pmppjnl->Codeno != mcodeno
            SKIP ALIAS Pmppjnl
            LOOP
         ENDIF
         IF Pmppjnl->Pay_Per < mstmm
            SKIP ALIAS Pmppjnl
            LOOP
         ENDIF
         IF Pmppjnl->Pay_Per > mendmm
            SKIP ALIAS Pmppjnl
            LOOP
         ENDIF
         IF nl > npl
            IF mwhere == "P"
                EJECT
              ELSE
                WAIT
                SCROLL()
             ENDIF
            @  0, 0 SAY Control->U_Name
            @  0,34 SAY mstmm 
            @  0,47 SAY mendmm 
            @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ),5 )
            nl := 2
         ENDIF                       // nl>npl
         nHours:= nHrsTH:= nTotHrs := 0
         nHolHours:= nSickTotal:= nSickHrs:= nBerHrs:= nPubHrs := 0
         DO WHILE Pmppjnl->Codeno = mcodeno .AND. Pmppjnl->( !EOF() ) 
            IF Pmppjnl->Pay_Per < mstmm
               SKIP ALIAS Pmppjnl
               LOOP
            ENDIF
            IF Pmppjnl->Pay_Per > mendmm
               SKIP ALIAS Pmppjnl
               LOOP
            ENDIF
            nHours     += Pmppjnl->Hours
            nHrsTH     += Pmppjnl->HrsTH
            nTotHrs    += Pmppjnl->Hours+( Pmppjnl->HrsTH )
            nHolHours  += Pmppjnl->HolHours
            nSickTotal += Pmppjnl->SickTotal
            nSickHrs   += Pmppjnl->SickHrs
            nBerHrs    += Pmppjnl->BerHrs
            nPubHrs    += Pmppjnl->PubHrs
            SKIP ALIAS Pmppjnl
         ENDDO
         @ nl, 0 SAY mcodeno 
         @ nl,12 SAY nHours     PICTURE "9,999.99"
         @ nl,22 SAY nHrsTH     PICTURE "9,999.99"
         @ nl,30 SAY nTotHrs    PICTURE "9,999.99"
         @ nl,40 SAY nSickTotal PICTURE "9,999.99"
         @ nl,50 SAY nSickHrs   PICTURE "9,999.99"
         @ nl,60 SAY nHolHours  PICTURE "9,999.99"
   /*
   SORT OUT LATER
         IF SUBSTR( Control->U_Name, 1, 4 ) = "CHRI"
            @ nl,69 SAY ( ( nLabPartTot/60 )/nTotHrs )*100 PICTURE "9999.99 %"
          ELSE
            @ nl,69 SAY ( nGrandTot/nTotHrs )*100 PICTURE "9999.99 %"
         ENDIF
   */
         nl++
         nHoursTotal  += nHours
         nHrsTHTotal  += nHrsTH
         nTotHrsTotal += nTotHrs
         nHolHoursTot += nHolHours
         nSickTTot    += nSickTotal
         nSickHrsTot  += nSickHrs
         nBerHrsTot   += nBerHrs
         nPubHrsTot   += nPubHrs
      ENDDO                // EOF Pmppjnl
   @ nl, 0 SAY REPLICATE( "-",76 )
   nl++
   @ nl, 3 SAY "Std Hours    Hrs TH1/2    Total Hrs "
   nl++
   @ nl, 3 SAY nHoursTotal  PICTURE "99,999.99"
   @ nl,16 SAY nHrsTHTotal  PICTURE "99,999.99"
   @ nl,28 SAY nTotHrsTotal PICTURE "99,999.99"

   /*
   SORT OUT LATER
   IF SUBSTR( Control->U_Name, 1, 4 ) = "CHRI"
     @ nl,69 SAY ( ( nTotHrsTotal/nLabPartTot/60 )/nTotHrs )*100 PICTURE "9999.99 %"
    ELSE
     @ nl,69 SAY ( nGrandTot/nLabPartTot )*100 PICTURE "9999.99 %"
      **** nTotHrsTotal
   ENDIF

   */
   nl+=2
   @ nl, 4 SAY "Ann Hol   P/H   Total   S/L     Bereave   In Lieu"
   nl++
   @ nl, 3 SAY nHolHoursTot PICTURE "99,999.99"
   @ nl,12 SAY nSickTTot    PICTURE "99,999.99"
   @ nl,22 SAY nSickHrsTot  PICTURE "99,999.99"
   @ nl,32 SAY nBerHrsTot   PICTURE "99,999.99"
   @ nl,42 SAY nPubHrsTot   PICTURE "99,999.99"
   nl+=2
         IF nl > npl
            IF mwhere == "P"
                EJECT
              ELSE
                WAIT
                SCROLL()
             ENDIF
            @  0, 0 SAY Control->U_Name
            @  0,34 SAY mstmm 
            @  0,47 SAY mendmm 
            @  0,58 SAY STR( DAY(DATE() ),3 )+" "+CMONTH( DATE() );
                       +STR( YEAR(DATE() ),5 )
            nl := 2
         ENDIF                       // nl>npl
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

   RETURN NIL
   ***---------- End of StaffJCSal

   ***---------------  END OF PMPTIME2.PRG
