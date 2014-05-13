   ***  JK 20-06-11 08:19:08 

   *** Note->Select5

/* 
   Program.....:                  XLF_EQU5.PRG 
   Authors.....: J.Kirby
   Date........: 09/11/2009
   Functions...: EquEdit,  EquSearch, QuotJCut
*/

// (c) Copyright 1993 by Kirby Christchurch.

FUNCTION EquEdit( mmodcode )

   nl := 4
   mpartnum  := Part->Partnum
   mmodref := "Cut Length                              "
   mcorrect := "N"
   SELECT Equ
   DO WHILE mcorrect == "N"
      SELECT Equ
      mkey := EquDesc->Modcode+Part->Partnum
      SEEK mkey
      IF Equ->ModSeqno = SPACE( 20 )
         ApRLock( 3 )
         Equ->ModSeqno := Equ->Modcode+STR( RECNO(), 6 )
         UNLOCK
      ENDIF
      SCROLL()
      DISPBOX( 0, 1,  2,79, 2 )
      @  1, 3 SAY TRIM( EquDesc->Modcode )+" "+TRIM( EquDesc->Desc );
            +" "+TRIM( Part->Partnum )+" "+EquDesc->Operno COLOR "RG+"
      DISPBOX( 3, 1, 24,79, 2 )
      nl := 4
      @ nl, 4      SAY TRIM( Part->Partnum )+" "+TRIM( Part->Desc )
      @ nl,COL()+2 SAY Equ->PartQty PICTURE "99,999.999" COLOR "G+" 
      @ nl,COL()+2 SAY Part->Unit  COLOR "G+"
      nl+=2
      nuse := 0
      SELECT EquCut
      SEEK Equ->ModSeqNo
      DO WHILE EquCut->ModSeqno = Equ->ModSeqno .AND. EquCut->( !EOF() )
         IF EquCut->Partnum != mpartnum
            SKIP ALIAS EquCut
            LOOP
         ENDIF
         IF nl > 20
            @ nl,60 SAY "There are More Cuts"
            EXIT
         ENDIF
         @ nl, 3      SAY EquCut->ModRef
         @ nl,COL()+1 SAY "Qty"
         @ nl,COL()+1 SAY EquCut->Qty    PICTURE "9999.99"
         @ nl,COL()+1 SAY EquCut->Length PICTURE "999.999"
         IF EquCut->Width != 0 
            @ nl,COL()+1 SAY EquCut->Width  PICTURE "999.999"
            @ nl,COL()+1 SAY "Sq Mtr"  
         ENDIF
         nl++
         SKIP ALIAS EquCut
      ENDDO
      cLength:= cWidth := "N"
      DISPBOX( 22, 1, 24,79, 2 )
      nselect := 1
      DO CASE 
         CASE Part->Unit = "Each      "
            nselect := 1
         CASE Part->Unit = "Mtr       "
            nselect := 3
         CASE Part->Unit = "Sq Mtr    "
            nselect := 4
         CASE Part->Unit = "Cu Mtr    "
            nselect := 5
      ENDCASE
      @ 23, 6      PROMPT "1. Each"
      @ 23,COL()+2 PROMPT "2. Each Use"
      @ 23,COL()+2 PROMPT "3. Cut Lengths"
      @ 23,COL()+2 PROMPT "4. Sq Mtr Area"
      @ 23,COL()+2 PROMPT "5. Cu Mtr"
      MENU TO nselect
      DO CASE
         CASE PressedEsc()
            RETURN NIL
         CASE nselect = 1                         // Each
            cLength := "N"
         CASE nselect = 2                         // Each Use
            mok := "Y"
            DO WHILE mok = "Y"
               SELECT Equ
               ApRLock( 3 )
               Equ->PartQty := 0
               UNLOCK
               aPart_:={}
               nrecno   := 0
               SELECT EquCut
               mseek := Equ->ModSeqno+Equ->Partnum
               SEEK mseek
               IF !FOUND()
                  mok := "N"
               ELSE
                  nQty := 0
                  SELECT EquCut
                  DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                     IF EquCut->Qty = 0
                         ApRLock( 3 )
                        DELETE
                        UNLOCK
                        SKIP ALIAS EquCut
                        LOOP
                     ENDIF
                     SCROLL( 18, 3, 20,78 )
                     @ 19,10 SAY EquCut->ModRef;
                        +" "+STR( EquCut->Qty, 7, 2 ) COLOR "BG+"
                     AADD( aPart_,EquCut->ModRef;
                        +" "+STR( EquCut->Qty, 7, 2 );
                        +"                 "+STR( RECNO(),6 ) )
                     SKIP ALIAS EquCut
                  ENDDO                        // Labour EOF
                  SCROLL(   6, 0, 24,80 )
                  DISPBOX(  3, 1, 24,79, 2 )
                  IF !EMPTY( aPart_ )
                     // Sort Taken Out
                     ASORT( aPart_,,,{ | x,y | x < y } )
                     anum := ACHOICE(  7, 6, 23,64,aPart_,,"AFUNC" )
                     IF PressedEsc()
                        RETURN NIL
                     ENDIF
                     nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                     GOTO nrecno
                  ENDIF                         // Empty 
                  mok := ApGetN( "Yes to Edit  No to Add Cuts" )
                  IF PressedEsc()
                     RETURN NIL
                  ENDIF
                  IF mok = "Y"
                     SCROLL(  16, 0, 24,80 )
                     DISPBOX( 16, 1, 24,79, 2 )
                     nl := 17
                     @ nl, 6 SAY "This is the Module Edit"
                     nl++
                     SELECT EquCut
                     mmodref := EquCut->ModRef
                     nqty    := EquCut->Qty
                     @ nl, 4      GET mmodref
                     @ nl,COL()+2 SAY "Qty" GET nqty PICTURE "9999.99"
                      READ
                      ApRLock( 3 )
                     EquCut->ModRef := mmodref
                     EquCut->Qty    := nqty
                     UNLOCK
                  ENDIF
               ENDIF                 // Found
            ENDDO                                           // mok
            nQty:= nQtyEqu:= nWidth:= nLength := 0
            SELECT EquCut
            GOTO TOP
            SEEK mseek
            IF FOUND()
               nl := 4
               SCROLL(  nl, 2, 24,78 )
               DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                  IF nl > 13
                     WAIT
                     nl := 4
                     SCROLL( nl, 2, 23,78 ) 
                  ENDIF
                  @ nl, 4      SAY EquCut->ModRef
                  @ nl,COL()+1 SAY "Qty"
                  @ nl,COL()+1 SAY EquCut->Qty    PICTURE "9999.99"
                  nQty += EquCut->Qty
                  nl++
                  SKIP ALIAS EquCut
               ENDDO                        // EquCut EOF
               SELECT Equ
                ApRLock( 3 )
               Equ->PartQty := nQty
               UNLOCK
            ENDIF                              // Found
            nl :=  7
            SCROLL(  nl, 0, 24,80 )
            DISPBOX(  3, 1, 24,79, 2 )
            nl++
            @ nl, 4      SAY TRIM( Part->Partnum )+" "+TRIM( Part->Desc )
            @ nl,COL()+2 SAY nQty PICTURE "9999.999" COLOR "G+" //Equ->PartQty 
            @ nl,COL()+2 SAY Part->Unit
            nl++
            @ nl,10 SAY "Add Qty  Qty = 0 to Exit"
            nl++
            nTotal := 1
            DO WHILE nTotal != 0
               IF nl > 22
                  INKEY( 2 )
                  nl :=  6
                  SCROLL( nl, 2, 23,78 )
               ENDIF
               nl++ 
               mmodref := "Each Use                               "
               cadd:= call := "N"
               IF Note->Select3 = "Y"
                  @ nl, 5      SAY "0 = Skip  Qty" GET nQtyEqu PICTURE "9999.99"
                   READ
                  IF nQtyEqu != 0
                     cadd:= call := "Y"
                     @ nl,32      SAY "Y for List" GET cadd PICTURE "!"
                     @ nl,COL()+2 SAY "Y = All"    GET call PICTURE "!"
                      READ
                  ENDIF 
                  @ nl, 4 SAY "                                            "
               ENDIF                              // Note Select3  
               IF cadd = "Y"
                  SAVE SCREEN TO Tempscrn
                  aPart_:={}
                  nrecno := 0
                  SELECT Progress
                  GOTO TOP
                  DO WHILE Progress->( !EOF() )
                     IF Progress->Desc = "         "    
                         SKIP ALIAS Progress
                         LOOP
                     ENDIF 
                     IF call != "Y"
                        IF SUBSTR( coperno, 3, 5 ) != "     "    
                           IF Progress->Operno != coperno
                              SKIP ALIAS Progress
                              LOOP
                           ENDIF
                        ENDIF
                     ENDIF  
                     AADD( aPart_,( Progress->Operno+"   "+Progress->Desc;
                       +"                      "+STR( RECNO(),6 ) ) )
                     SKIP ALIAS Progress
                  ENDDO
                  SCROLL()
                  IF !EMPTY( aPart_ )
                     DISPBOX(  0, 0, 24,60, 2 )
                     ASORT( aPart_,,,{ | x,y | x < y } )
                     anum := ACHOICE( 1, 3, 23,58,aPart_,,"AFUNC" )
                     nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                     GOTO nrecno
                     IF PressedEsc()
                        RETURN NIL
                     ENDIF
                     mdesc := Progress->Desc
                     SCROLL( 15, 0, 24,80 )
                     DISPBOX( 15, 0, 24,79, 2 )
                     @ 17, 4 SAY "                                            "
                     @ 17, 5 SAY Progress->Desc+"  "+Equ->ModCode+" "+coperno COLOR "RG+" 
                     @ 19, 5 GET mdesc PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                      READ
                     IF PressedEsc()
                        RETURN NIL
                     ENDIF
                     myes := "N"   
                     @ 19,50 SAY "Is this New" GET myes PICTURE "@!"
                      READ
                     IF myes = "Y"
                        myes := "N"
                        @ 19,50 SAY "   Sure New" COLOR "RG+" 
                        @ 19,COL()+1 GET myes VALID( myes $ "NY" ) PICTURE "@!"
                        @ 22,10 SAY "Do you want to Add to List ARE YOU SURE" COLOR "RG+" 
                         READ
                     ENDIF 
                     SELECT Progress
                      ApFLock( 3 )
                     IF myes = "Y"               
                        APPEND BLANK
                        Progress->Operno  := coperno
                     ENDIF
                     Progress->Date    := DATE()
                     Progress->Desc    := mdesc
                     UNLOCK
                     mmodref := mdesc
                     RESTORE SCREEN FROM Tempscrn
                  ENDIF
               ENDIF    // !Empty

               @ nl, 2 SAY "                        "
               @ nl, 3      GET mmodref PICTURE "@KX"
               @ nl,COL()+2 SAY "Qty" GET nQtyEqu PICTURE "9999.99"
                READ
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               IF EMPTY( aPart_ )
                  SELECT Progress
                  ApFLock( 3 )
                    APPEND BLANK
                  Progress->Operno := coperno
                  Progress->Date   := DATE()
                  Progress->Desc   := "Cut List NEW Change next time"
                  UNLOCK
               ENDIF
               nTotal := nQtyEqu                  // Needed to get out of loop
               IF nQtyEqu > 0
                   SELECT EquCut
                    ApFLock( 3 )
                   APPEND BLANK
                   EquCut->ModRef   := mmodref
                   EquCut->Qty      := nQtyEqu  
                   EquCut->ModSeqno := Equ->ModSeqNo 
                   EquCut->Date     := DATE() 
                   EquCut->Partnum  := Part->Partnum
                   UNLOCK
                   SELECT Equ
                    ApRLock( 3 )
                   Equ->PartQty += nQtyEqu   
                   UNLOCK
                   nQtyEqu := 0
               ENDIF
               @  4,62      SAY "Total"
               @  4,COL()+1 SAY Equ->PartQty PICTURE "99,999.999" COLOR "G+"
            ENDDO                         // nTotal

         CASE nselect = 3                         // Cut Length Qty
            cLength := "Y"
         CASE nselect = 4                         // Sq Mtr
            cLength:= cWidth := "Y"
         CASE nselect = 5                           // Cu Mtr
            nQty:= nWidth:= nThick:= nTotQty := 0
            SCROLL(   5, 0, 24,80 )
            DISPBOX(  3, 1, 24,79, 2 )
            nl := 6
            @ nl,10      SAY "Size mm" GET nWidth  PICTURE "9999"
            @ nl,COL()+1 SAY "X"      GET nThick  PICTURE "9999"
            @ nl,COL()+2 SAY "Qty"    GET nTotQty PICTURE "9999.999"
             READ
            SELECT Part
              ApRLock( 3 )
            Part->Width := nWidth
            Part->Thick := nThick
            UNLOCK
            nQty := ( ( Part->Width*Part->Thick )/1000000 )*nTotQty
            nl+=2
            @ nl,10      SAY "Cubic Mtr"
            @ nl,COL()+2 SAY nQty  PICTURE "99,999.999"    
            SELECT Equ
             ApRLock( 3 )
            Equ->PartQty := nQty
            UNLOCK
      ENDCASE

      IF cLength = "Y"
         mseek := Equ->ModSeqno+Equ->Partnum
         SELECT EquCut
         GOTO TOP
         SEEK mseek
         IF FOUND()
            SCROLL( 5, 2, 23,78 )
            nl := 5
            DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
               IF nl >= 20
                  @ nl,60 SAY "There are More Cuts"
                  EXIT
               ENDIF
               @ nl, 6      SAY SUBSTR( EquCut->ModRef, 1, 30 )
               @ nl,COL()+1 SAY "Qty"
               @ nl,COL()+1 SAY EquCut->Qty    PICTURE "99999.99"
               @ nl,COL()+1 SAY EquCut->Length PICTURE "999.999"
               IF cWidth = "Y"
                  @ nl,COL()+1 SAY EquCut->Width  PICTURE "999.999"
               ENDIF
               nl++
               SKIP ALIAS EquCut
            ENDDO
            ***   ENDIF               // Found
            medit := ApGetY( "Edit the Cuts" )
            IF medit = "Y"
               meditcut := "Y"
               DO WHILE meditcut = "Y"
                  @ nl, 4      SAY TRIM( Part->Partnum )+" "+TRIM( Part->Desc )
                  @ nl,COL()+2 SAY Equ->PartQty PICTURE "99,999.999" COLOR "G+" 
                  @ nl,COL()+2 SAY Part->Unit  COLOR "G+"
                  aPart_:={}
                  nrecno   := 0
                  SELECT EquCut
                  mseek := Equ->ModSeqno+Equ->Partnum
                  SEEK mseek
                  nQty := 0
                  SELECT EquCut
                  DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                     IF EquCut->Qty = 0
                         ApRLock( 3 )
                        DELETE
                        UNLOCK
                        SKIP ALIAS EquCut
                        LOOP
                     ENDIF
                     IF cWidth = "Y"
                        IF EquCut->Width = 0
                           SCROLL( 18, 3, 20,78 )
                           @ 19, 4 SAY SUBSTR( EquCut->ModRef, 1,30 );
                              +" "+STR( EquCut->Qty, 7, 2 );
                              +" "+STR( EquCut->Length, 8, 3 );
                              +" "+STR( EquCut->Width, 8, 3 ) COLOR "BG+"
                           mdelete := ApGetN( "Delete This - Not a Sq Mtr Qty" )
                           IF mdelete = "Y" 
                               ApRLock( 3 )
                              DELETE
                              UNLOCK
                              SKIP ALIAS EquCut
                              LOOP
                           ENDIF
                        ENDIF              // mwidth = 0
                     ENDIF                 // cWidth = Y
                     AADD( aPart_,EquCut->ModRef;
                        +" "+STR( EquCut->Qty, 7, 2 );
                        +" "+STR( EquCut->Length, 8, 3 );
                        +" "+STR( EquCut->Width, 8, 3 );
                        +"                 "+STR( RECNO(),6 ) )
                     SKIP ALIAS EquCut
                  ENDDO                        // EquCut EOF
                  SCROLL(   5, 0, 24,80 )
                  DISPBOX(  3, 1, 24,79, 2 )
                  IF !EMPTY( aPart_ )
                     @  4, 4      SAY TRIM( Part->Partnum )+" "+TRIM( Part->Desc )
                     @  4,COL()+2 SAY Equ->PartQty PICTURE "99,999.999" COLOR "G+" 
                     @  4,COL()+2 SAY Part->Unit  COLOR "G+"
                     @  5, 4 SAY "Select the Cut to Edit" COLOR "RG+"   
                     ASORT( aPart_,,,{ | x,y | x < y } )
                     anum := ACHOICE(  6, 5, 23,77,aPart_,,"AFUNC" )
                     IF PressedEsc()
                        RETURN NIL
                     ENDIF
                     nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                     GOTO nrecno
                  ENDIF                         // Empty
                  SCROLL(  18, 2, 24,78 )
                  @ 18,10 SAY EquCut->ModRef COLOR "RG+"  
                  SCROLL(  16, 0, 24,80 )
                  DISPBOX( 16, 1, 24,79, 2 )
                  nl := 17
                  @ nl, 6 SAY "This is the Module Length/Width Edit"
                  nl++
                  SELECT EquCut
                  mmodref := EquCut->ModRef
                  nqty    := EquCut->Qty
                  nlength := EquCut->Length
                  nwidth  := EquCut->Width
                  @ nl, 3                         GET mmodref
                  nl++
                  @ nl,10      SAY "Qty"          GET nqty    PICTURE "9999.99"
                  @ nl,COL()+1 SAY "Mtr Length"   GET nlength PICTURE "999.999"
                  IF cWidth = "Y"
                     @ nl,COL()+1 SAY "Mtr Width" GET nwidth  PICTURE "999.999"
                  ENDIF 
                   READ
                   ApRLock( 3 )
                  EquCut->ModRef := mmodref
                  EquCut->Qty    := nqty
                  EquCut->Length := nlength
                  EquCut->Width  := nwidth
                  UNLOCK
                  ***   ENDIF                   //mok   
                  nQty := 0
                  SELECT EquCut
                  GOTO TOP
                  SEEK mseek
                  IF FOUND()
                     DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
                        IF cWidth = "Y"
                           nQty += ( EquCut->Length*EquCut->Width )*EquCut->Qty
                        ELSE
                           nQty += EquCut->Length*EquCut->Qty
                        ENDIF
                        SKIP ALIAS EquCut
                     ENDDO                        // EquCut EOF
                     SELECT Equ
                     ApRLock( 3 )
                     Equ->PartQty := nQty
                     UNLOCK

                  ENDIF                              // Found
                  meditcut := ApGetY( "Another Cut Edit")    
               ENDDO                 // mok
               **************************
               IF meditcut = "N"
                  IF cLength = "Y"
                     nQty:= nQtyEqu:= nWidth:= nLength := 0
                     SCROLL(   3, 0, 24,80 )
                     DISPBOX(  3, 1, 24,79, 2 )
                     nl := 4
                     @ nl, 4      SAY TRIM( Part->Partnum )+" "+TRIM( Part->Desc )
                     @ nl,COL()+2 SAY Equ->PartQty PICTURE "9999.999" COLOR "G+" 
                     @ nl,COL()+2 SAY Part->Unit
                     nl++
                     @ nl, 6 SAY "Add Lengths and Qty    Length = 0  Qty = 0 to Exit" COLOR "RG+"
                     nl++
                     nTotal := 1
                     DO WHILE nTotal != 0
                        IF nl > 20
                           INKEY( 2 )
                           nl :=  6
                           SCROLL( nl, 2, 23,78 )
                        ENDIF
                        ntrade     := Part->Trade
                        nwholesale := Part->Wholesale
                        nl++
                        @ nl, 3      SAY "Qty"          GET nQtyEqu PICTURE "9999.99"
                        @ nl,COL()+1 SAY "Mtr Length"   GET nLength PICTURE "999.999"
                        IF cWidth = "Y"
                           @ nl,COL()+1 SAY "Mtr Width" GET nWidth  PICTURE "999.999"
                        ENDIF
                         READ
                        cadd:= call := "N"
                        IF Note->Select3 = "Y"
                           cadd:= call := "Y"
                           @ nl,52      SAY "Y = List" GET cadd PICTURE "!"
                           @ nl,COL()+2 SAY "Y = All"  GET call PICTURE "!"
                            READ
                        ENDIF                 // Note Select3 
                        IF PressedEsc()
                           RETURN NIL
                        ENDIF
                        nTotal := nQtyEqu                  // Needed to get out of loop
                        mmodref := "Cut Length                              "
                        IF cWidth = "Y"
                           nQty += ( nLength*nWidth )*nQtyEqu
                          ELSE
                           nQty += nLength*nQtyEqu
                        ENDIF
                        @  nl,62      SAY "Total"
                        @  nl,COL()+1 SAY nQty+Equ->PartQty PICTURE "99,999.999" COLOR "G+"
                        nl++ 
                        IF nQtyEqu > 0
                           IF cadd = "Y"
                              SAVE SCREEN TO Tempscrn
                              aPart_:={}
                              nrecno := 0
                              SELECT Progress
                              GOTO TOP
                              DO WHILE Progress->( !EOF() )
                                 IF Progress->Desc = "         "    
                                    SKIP ALIAS Progress
                                    LOOP
                                 ENDIF 
                                 IF call != "Y"
                                    IF SUBSTR( coperno, 3, 5 ) != "     "    
                                       IF Progress->Operno != coperno
                                          SKIP ALIAS Progress
                                          LOOP
                                       ENDIF
                                    ENDIF
                                 ENDIF  
                                 AADD( aPart_,( Progress->Operno+"   "+Progress->Desc;
                                       +"                      "+STR( RECNO(),6 ) ) )
                                 SKIP ALIAS Progress
                               ENDDO
                              SCROLL()
                              IF !EMPTY( aPart_ )
                                 DISPBOX(  0, 0, 24,60, 2 )
                                 ASORT( aPart_,,,{ | x,y | x < y } )
                                 anum := ACHOICE( 1, 3, 23,58,aPart_,,"AFUNC" )
                                 nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                                 GOTO nrecno
                                 IF PressedEsc()
                                    RETURN NIL
                                 ENDIF
                                 mdesc := Progress->Desc
                                 SCROLL( 15, 0, 24,80 )
                                 DISPBOX( 15, 0, 24,79, 2 )
                                 @ 17, 4 SAY "                                            "
                                 @ 17, 5 SAY Progress->Desc+"  "+Equ->ModCode+" "+coperno COLOR "RG+" 
                                 @ 19, 5 GET mdesc PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                                  READ
                                 IF PressedEsc()
                                    RETURN NIL
                                 ENDIF
                                 myes := "N"   
                                 @ 19,50 SAY "Is this New" GET myes PICTURE "@!"
                                  READ
                                 IF myes = "Y"
                                    myes := "N"
                                    @ 19,50 SAY "   Sure New" COLOR "RG+" 
                                    @ 19,COL()+1 GET myes VALID( myes $ "NY" ) PICTURE "@!"
                                    @ 22,10 SAY "Do you want to Add to List ARE YOU SURE" COLOR "RG+" 
                                    READ
                                 ENDIF 
                                 SELECT Progress
                                  ApFLock( 3 )
                                 IF myes = "Y"               
                                    APPEND BLANK
                                    Progress->Operno  := coperno
                                 ENDIF
                                 Progress->Date    := DATE()
                                 Progress->Desc    := mdesc
                                 UNLOCK
                                 mmodref := mdesc
                                 RESTORE SCREEN FROM Tempscrn
                              ENDIF
                           ENDIF    // !Empty
                           SELECT EquCut
                           @ nl, 2 SAY "                                   "
                           @ nl,20 GET mmodref PICTURE "@KX"     // Changed for Bryn
                            READ
                            ApFLock( 3 )
                           APPEND BLANK
                           EquCut->ModRef   := mmodref
                           EquCut->Qty      := nQtyEqu  
                           EquCut->Length   := nLength  
                           EquCut->Width    := nWidth  
                           EquCut->ModSeqno := Equ->ModSeqNo 
                           EquCut->Date     := DATE() 
                           EquCut->Partnum  := Part->Partnum
                           UNLOCK
                        ENDIF
                        SELECT Equ
                         ApRLock( 3 )
                        Equ->PartQty += nQty         
                        UNLOCK
                        nQty:= nQtyEqu:= nWidth:= nLength := 0
                     ENDDO                         // nTotal
                  ENDIF                               // cLength

               ENDIF                               // meditcut
               ***     nl := 4
               nTotTime:= nTotRate := 0

               SCROLL( 11, 0, 24,80 )
               DISPBOX( 3, 1, 24,79, 2 )
               SELECT Equ
               npartqty   := Equ->Partqty  
               ***   nl := 12
               @ nl, 6      SAY "Number of parts" GET npartqty PICTURE "99999.999" 
               @ nl,COL()+3 SAY "0 = remove part - Esc = Quit"
               nl+=2
                READ
               IF PressedEsc()
                  RETURN NIL
               ENDIF
                ApRLock( 3 )
               Equ->Partqty := npartqty
               UNLOCK
               mcorrect := "Y"
               *** ApGetY( Message->Correct )
               IF Equ->Partqty == 0
                  SELECT EquCut
                   ApFLock( 3 )
                  DELETE ALL FOR EquCut->Partnum = Equ->Partnum;
                        .AND. SUBSTR( EquCut->ModSeqno, 1,16 ) = Equ->Modcode
                  UNLOCK
                  SELECT Equ
                   ApRLock( 3 )
                  DELETE
                  UNLOCK
                  mcorrect := "N"
                  RETURN NIL
               ENDIF

            ENDIF                //  meditCut

         ENDIF                  // Found
         RETURN NIL
      ELSE

         IF cLength = "Y"
            nQty:= nQtyEqu:= nWidth:= nLength := 0
            SCROLL(   3, 0, 24,80 )
            DISPBOX(  3, 1, 24,79, 2 )
            nl := 4
            @ nl, 4      SAY TRIM( Part->Partnum )+" "+TRIM( Part->Desc )
            @ nl,COL()+2 SAY Equ->PartQty PICTURE "9999.999" COLOR "G+" 
            @ nl,COL()+2 SAY Part->Unit
            nl++
            @ nl, 6 SAY "Add Lengths and Qty    Length = 0  Qty = 0 to Exit" COLOR "RG+"
            nl++
            nTotal := 1
            DO WHILE nTotal != 0
               IF nl > 20
                  INKEY( 2 )
                  nl :=  6
                  SCROLL( nl, 2, 23,78 )
               ENDIF
               ntrade     := Part->Trade
               nwholesale := Part->Wholesale
               nl++
               @ nl, 3      SAY "Qty"          GET nQtyEqu PICTURE "9999.99"
               @ nl,COL()+1 SAY "Mtr Length"   GET nLength PICTURE "999.999"
               IF cWidth = "Y"
                  @ nl,COL()+1 SAY "Mtr Width" GET nWidth  PICTURE "999.999"
               ENDIF
                READ
               cadd:= call := "N"
               IF Note->Select3 = "Y"
                  cadd:= call := "Y"
                  @ nl,52      SAY "Y = List" GET cadd PICTURE "!"
                  @ nl,COL()+2 SAY "Y = All"  GET call PICTURE "!"
                   READ
               ENDIF                 // Note Select3 
               IF PressedEsc()
                  RETURN NIL
               ENDIF
               nTotal := nQtyEqu                  // Needed to get out of loop
               mmodref := "Cut Length                              "
               IF cWidth = "Y"
                  nQty += ( nLength*nWidth )*nQtyEqu
               ELSE
                  nQty += nLength*nQtyEqu
               ENDIF
               @  nl,62      SAY "Total"
               @  nl,COL()+1 SAY nQty+Equ->PartQty PICTURE "99,999.999" COLOR "G+"
               nl++ 
               IF nQtyEqu > 0
                  IF cadd = "Y"
                     SAVE SCREEN TO Tempscrn
                     aPart_:={}
                     nrecno := 0
                     SELECT Progress
                     GOTO TOP
                     DO WHILE Progress->( !EOF() )
                        IF Progress->Desc = "         "    
                            SKIP ALIAS Progress
                            LOOP
                        ENDIF 
                        IF call != "Y"
                           IF SUBSTR( coperno, 3, 5 ) != "     "    
                              IF Progress->Operno != coperno
                                 SKIP ALIAS Progress
                                 LOOP
                              ENDIF
                           ENDIF
                        ENDIF  
                        AADD( aPart_,( Progress->Operno+"   "+Progress->Desc;
                          +"                      "+STR( RECNO(),6 ) ) )
                        SKIP ALIAS Progress
                     ENDDO
                     SCROLL()
                     IF !EMPTY( aPart_ )
                        DISPBOX(  0, 0, 24,60, 2 )
                        ASORT( aPart_,,,{ | x,y | x < y } )
                        anum := ACHOICE( 1, 3, 23,58,aPart_,,"AFUNC" )
                        nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                        GOTO nrecno
                        IF PressedEsc()
                           RETURN NIL
                        ENDIF
                        mdesc := Progress->Desc
                        SCROLL( 15, 0, 24,80 )
                        DISPBOX( 15, 0, 24,79, 2 )
                        @ 17, 4 SAY "                                            "
                        @ 17, 5 SAY Progress->Desc+"  "+Equ->ModCode+" "+coperno COLOR "RG+" 
                        @ 19, 5 GET mdesc PICTURE "!XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                         READ
                        IF PressedEsc()
                           RETURN NIL
                        ENDIF
                        myes := "N"   
                        @ 19,50 SAY "Is this New" GET myes PICTURE "@!"
                         READ
                        IF myes = "Y"
                           myes := "N"
                           @ 19,50 SAY "   Sure New" COLOR "RG+" 
                           @ 19,COL()+1 GET myes VALID( myes $ "NY" ) PICTURE "@!"
                           @ 22,10 SAY "Do you want to Add to List ARE YOU SURE" COLOR "RG+" 
                            READ
                        ENDIF 
                        SELECT Progress
                         ApFLock( 3 )
                        IF myes = "Y"               
                           APPEND BLANK
                           Progress->Operno  := coperno
                        ENDIF
                        Progress->Date    := DATE()
                        Progress->Desc    := mdesc
                        UNLOCK
                        mmodref := mdesc
                        RESTORE SCREEN FROM Tempscrn
                     ENDIF
                  ENDIF    // !Empty
                  /*

                  IF EMPTY( aPart_ )
                     SELECT Progress
                     ApFLock( 3 )
                     APPEND BLANK
                     Progress->Operno := coperno
                     Progress->Date   := DATE()
                     Progress->Desc   := "Cut List NEW Change next time"
                     UNLOCK
                  ENDIF

                  */
                  SELECT EquCut
                  @ nl, 2 SAY "                                   "
                  @ nl,20 GET mmodref PICTURE "@KX"     // Changed for Bryn
                   READ
                   ApFLock( 3 )
                  APPEND BLANK
                  EquCut->ModRef   := mmodref
                  EquCut->Qty      := nQtyEqu  
                  EquCut->Length   := nLength  
                  EquCut->Width    := nWidth  
                  EquCut->ModSeqno := Equ->ModSeqNo 
                  EquCut->Date     := DATE() 
                  EquCut->Partnum  := Part->Partnum
                  UNLOCK
               ENDIF
               SELECT Equ
                ApRLock( 3 )
               Equ->PartQty += nQty         
               UNLOCK
               nQty:= nQtyEqu:= nWidth:= nLength := 0
            ENDDO                         // nTotal

         ENDIF                               //  cLength
      ENDIF                               // meditcut  
      ***     ENDIF                       // Not ZZFABRIC

      ***     nl := 4
      nTotTime:= nTotRate := 0

      SCROLL( 11, 0, 24,80 )
      DISPBOX( 3, 1, 24,79, 2 )
      SELECT Equ
      npartqty   := Equ->Partqty  
      ***   nl := 12
      @ nl, 6      SAY "Number of parts" GET npartqty PICTURE "99999.999" 
      @ nl,COL()+3 SAY "0 = remove part - Esc = Quit"
      nl+=2
       READ
      IF PressedEsc()
         RETURN NIL
      ENDIF
       ApRLock( 3 )
      Equ->Partqty := npartqty
      UNLOCK
      mcorrect := "Y"
      *** ApGetY( Message->Correct )
      *** ENDDO
      IF Equ->Partqty == 0
          SELECT EquCut
           ApFLock( 3 )
          DELETE ALL FOR EquCut->Partnum = Equ->Partnum;
                .AND. SUBSTR( EquCut->ModSeqno, 1,16 ) = Equ->Modcode
          UNLOCK
          SELECT Equ
           ApRLock( 3 )
          DELETE
          UNLOCK
          mcorrect := "N"
          RETURN NIL
      ENDIF
   ENDDO
   SELECT Part
   SET ORDER TO 1                      // Partnum
   SEEK mpartnum
   mpartnum := Part->Partnum

   RETURN mpartnum

   ****---- End of EquEdit()

   ****------------------------------------------------------------------------

FUNCTION EquSearch( mmodcode )

   cpartorg := mmodcode
   mcontinue := "Y"
   DO WHILE mcontinue = "Y"
      EquLook( @mmodcode )            // XLF_EQU4
      SELECT Equ
      IF Note->Select5 = "Y"
         IF EquDesc->Operno = SPACE( 8 )
            coperno := SPACE( 8 )
             GroupSelect( @coperno )
            SELECT EquDesc
             ApRLock( 3 )
            EquDesc->Operno := coperno
            UNLOCK
         ENDIF
      ENDIF                         // Note->Select5
      coperno := EquDesc->Operno
      nsel  := 1
      SCROLL(  18, 0, 24,80 )
      DISPBOX( 18, 1, 24,79,2 )
      @ 24,60 SAY " DT11A5 "
      @ 18, 6 SAY " -- Module Menu -- "+mmodcode+" "+coperno COLOR "G+" 
      @ 18,58 SAY " -- Module Menu -- " COLOR "G+" 
      @ 19, 4      PROMPT "1.Add Part"
      @ 19,COL()+2 PROMPT "2.Price Module"
      @ 19,COL()+2 PROMPT "3.Another"
      @ 19,COL()+2 PROMPT "4.Edit Part"
      @ 19,COL()+2 PROMPT "5.Cut List"
      @ 19,COL()+2 PROMPT "6.Detail"
      @ 21,4       PROMPT "7.Kit List"             
      @ 21,COL()+2 PROMPT "8.List Costs"
      @ 21,COL()+2 PROMPT "Copy Module"
      @ 21,COL()+2 PROMPT "Show Cuts"
      @ 21,COL()+2 PROMPT "Add Labour"

      @ 23, 4      PROMPT "View Part"
      @ 23,COL()+2 PROMPT "Draw Add"
      @ 23,COL()+2 PROMPT "Modules"
      @ 23,COL()+2 PROMPT "Edit Mod Desc"
      @ 23,COL()+2 PROMPT "Product"
      @ 23,COL()+2 PROMPT "Return"
      @ 23,COL()+2 SAY EquDesc->Operno COLOR "RG+"
      MENU TO nsel
      DO CASE
         CASE nsel == 17 .OR. PressedEsc()
            ***          mcontinue := "N"
            SELECT Part
            SEEK cpartorg                // ModCode
            mpartnum := Part->Partnum
            RETURN NIL
         CASE nsel == 1                             // Equ Add Part
            coperno := EquDesc->Operno
            EquPartAdd( @mmodcode )               // XLF_Equ4
            SELECT Part
            mcontinue := "Y"
            LOOP
         CASE nsel ==  2               // Price Module 
            mpartnum := mmodcode         // Part->Partnum
            nTotTime:= nTotRate := 0
            SCROLL(   9, 0, 24,80 )
            DISPBOX(  9, 1, 20,79, 2 )
            ***       @ 10, 6 SAY "  -- Check Labour etc later --  "
            nl := 11 
            SELECT Part
            SET ORDER TO 1                     // Partnum
            SEEK mpartnum
            nlength := Part->Length 
            nl := 13
            SELECT Part
            SET ORDER TO 1
            nvol:= mQty:= ncsarea := 0
            nlinm:= nrate:= nlen:= ndiscount:= ncost := 0
            @  nl, 6      SAY TRIM( Part->Unit )+" Cost   "
            @  nl,COL()+1 SAY Part->Trade  PICTURE "999,999.99"
            @  nl,COL()+1 SAY Part->Markup  PICTURE "99,999.99"
            @  nl,COL()+1 SAY "%"
            @  nl,COL()+2 SAY "Sell"
            @  nl,COL()+1 SAY Part->Wholesale PICTURE "999,999.99"
            nl+=2
            ApRlock()
            IF Part->Markup == 0
               Part->Markup := Cat->Markup
            ENDIF
            UNLOCK
            ntrade := Part->Trade
            nmarkup := Part->Markup
            @ nl, 6 SAY TRIM( Part->Unit )+" Cost   " GET ntrade PICTURE "999999.99"
            IF SUBSTR( Control->U_Name,1,5 ) != "CHRIS"
               @ nl,COL()+2 SAY "Mkup %" GET nmarkup PICTURE "9999.99"
            ELSE
               @ nl,COL()+2 SAY "Mkup %"
               @ nl,COL()+2 SAY nmarkup PICTURE "9999.99"
            ENDIF
            READ
            ApRLock( 3 )
            Part->Trade  := ntrade
            Part->Markup := nmarkup
            IF SUBSTR( Control->U_Name,1,5 ) != "CHRIS"
               Part->Wholesale := ( Part->Trade* ( 1+( Part->Markup/100) ) )
            ENDIF
            IF Part->Margin == 0 
               Part->Margin := Part->Markup
            ENDIF
            UNLOCK
            nwholesale := Part->Wholesale
            nl+=2
            @ nl, 6      SAY TRIM( Part->Unit )+" Sell exl GST";
                              GET nwholesale PICTURE "999999.99"
            READ
            ApRlock()
            Part->Wholesale := nwholesale
            Part->Markup := ( ( Part->Wholesale-Part->Trade ) / Part->Trade ) *100
            nsell := ( Part->Trade* ( 1+( Part->Markup/100) ) )
            UNLOCK
            COMMIT
            LOOP
         CASE nsel == 3                             // Another
            mcontinue := "Y"
            LOOP
         CASE nsel == 4                          // Edit Equ
            coperno := EquDesc->Operno
            EquEdit( @mmodcode )                     // XLF_Equ4
            mcontinue := "Y"
            LOOP
         CASE nsel == 5                   // Cut List
            nselPart  := 1
            SCROLL(   9, 0, 17,80 )
            DISPBOX(  9, 1, 17,79,2 )
            @ 11, 6 PROMPT "1. Parts, Cuts, Date    "
            @ 12, 6 PROMPT "2. Total                "
            @ 13, 6 PROMPT "3. Mtr, Sq Mtr Only Cuts"
            @ 14, 6 PROMPT "4. Each Use        Only "
            @ 15, 6 PROMPT "5. Each       Only Total"
            MENU TO nselPart
            DO CASE
               CASE nselPart == 1
                   EquTotal()                   // XLF_Equ4
               CASE nselPart == 2
                   EquCut()                     // XLF_Equ4
               CASE nselPart == 3
                   EquCutMtr()                  // Above 
               CASE nselPart == 4                 // Each Only   
                   EquEach()                    // Above
               CASE nselPart == 5
                   EquCutEach()                 // XLF_Equ4 
            ENDCASE
            mcontinue := "Y"
            LOOP
         CASE nsel == 6                   // Detail
            EquDetail( mmodcode )                     // XLF_Equ
            mcontinue := "Y"
            LOOP
         CASE nsel == 7                  // Kit List
            EquPart( @mmodcode )              // XLF_Equ3
            mcontinue := "Y"
            LOOP
         CASE nsel == 8                  // List Costs
            minvno   := SPACE( 6 )
            mpartnum := TRIM( Part->Partnum ) 
            EquPrice( mpartnum, minvno )
            mcontinue := "Y"
            LOOP
         CASE nsel == 9               // Copy Module 
            mpartnum := mmodcode      // Part->Partnum
            EquCopy( mpartnum )                   // CWP2
            mcontinue := "Y"
            LOOP
         CASE nsel == 10               // Show Cuts
            mpartnum := mmodcode
            SCROLL(  2, 0,24,80 )
            DISPBOX( 2, 0, 24,79, 2 )
            nl := 4
            ncount := 0
            SELECT EquCut
            GOTO TOP
            SEEK SUBSTR( mpartnum, 1,16 )
            IF FOUND()
               @  3, 6 SAY SUBSTR( EquCut->Modseqno, 1,16 ) COLOR "RG+"
               DO WHILE SUBSTR( EquCut->ModSeqno, 1,16 ) = SUBSTR( mpartnum, 1,16 );
                          .AND. EquCut->( !EOF() )
                  ncount++
                  SKIP ALIAS EquCut
               ENDDO                            // While EquCut
               @  3,26      SAY "Number of Cuts ="
               @  3,COL()+1 SAY ncount PICTURE "99,999" COLOR "RG+"
               @  3,COL()+3 SAY "Qty" 
               ncount := 0    
               SELECT EquCut
               SEEK SUBSTR( mpartnum, 1, 16 )
               DO WHILE SUBSTR( EquCut->ModSeqno, 1,16 ) = SUBSTR( mpartnum, 1, 16 );
                             .AND. EquCut->( !EOF() )
                  ncount++
                  IF nl > 22
                     INKEY( 0 )
                     nl := 4
                     SCROLL(  nl, 2, 23,78 )
                  ENDIF
                  @ nl, 3      SAY SUBSTR( EquCut->Partnum, 1,16 ) COLOR "RG+"
                  @ nl,COL()+1 SAY SUBSTR( EquCut->ModRef, 1,28 )  COLOR "RG+"
                  @ nl,COL()+1 SAY EquCut->Qty    PICTURE "9999.99"
                  @ nl,COL()+1 SAY EquCut->Length PICTURE "999.999"
                  IF EquCut->Width != 0 
                     @ nl,COL()+1 SAY EquCut->Width  PICTURE "999.999"
                     @ nl,COL()+1 SAY "Sq Mtr"  
                  ENDIF
                  nl++
                  SKIP ALIAS EquCut
               ENDDO                            // While EquCut
            ENDIF                             // Found 
            @ 23, 2 SAY " "
            mok :=  ApGetN( "Edit the Cuts" )
            DO WHILE mok = "Y"
               nrecno := 0
               aPart_ := {}
               SELECT EquCut
               SEEK SUBSTR( mpartnum, 1, 16 )
               DO WHILE SUBSTR( EquCut->ModSeqno, 1,16 ) = SUBSTR( mpartnum, 1, 16 );
                               .AND. EquCut->( !EOF() )
                  AADD( aPart_,EquCut->Partnum;
                      +" "+SUBSTR( EquCut->ModRef, 1,28 );
                      +" "+STR( EquCut->Qty, 8, 3 );
                      +" "+STR( EquCut->Length, 8, 3);
                      +" "+STR( EquCut->Width, 8 ,3 );
                      +"                       "+STR( RECNO(),6 ) )
                  SKIP ALIAS EquCut
               ENDDO                       // EquCut
               SCROLL() 
               DISPBOX( 0, 0, 2,79, 2 )
               @  1,17 SAY "Module Cuts"
               DISPBOX( 3, 0, 24,79, 2 )
               IF !EMPTY( aPart_ )
                  ASORT( aPart_,,,{ | x,y | x < y } )
                  anum := ACHOICE( 4, 3, 23,77, aPart_,,"AFUNC" )
                  IF LASTKEY() = 27
                     RETURN    //  EXIT
                  ENDIF  
                  nrecno := VAL( RIGHT( aPart_[anum],6 ) )
                  GOTO nrecno
               ENDIF
               cmodref := EquCut->Modref
               nqty    := EquCut->Qty
               nlength := EquCut->Length
               nwidth  := EquCut->Width
               mdelete := "N"  
               @ ROW(), 2 SAY SPACE( 76 ) 
               @ ROW(), 2 GET cmodref PICTURE "@X"
               @ ROW()+1, 2 SAY SPACE( 76 ) 
               @ ROW(), 2 SAY "Qty"    GET nqty    PICTURE "99999.999"
               @ ROW(),18 SAY "Length" GET nlength PICTURE "99999.999"
               @ ROW(),36 SAY "Width"  GET nwidth  PICTURE "99999.999"
               @ ROW(),56 SAY "Delete" GET mdelete PICTURE "!"
               READ
               IF PressedEsc()
                  RETURN               //           EXIT
               ENDIF
               ApRLock( 3 )
               EquCut->ModRef := cmodref 
               EquCut->Qty    := nqty 
               EquCut->Length := nlength 
               EquCut->Width  := nwidth 
               UNLOCK
               IF mdelete = "Y"
                   ApRLock( 3 )
                  DELETE
                  UNLOCK
               ENDIF
               LOOP
            ENDDO  
            LOOP
         CASE nsel == 11                   // Labour
             LabourWO() 
            mcontinue := "Y"
            LOOP    
         CASE nsel == 12 
            ***        tempEqu := SAVESCREEN( 0, 0, 24,80 )
            mpartnum := Part->Partnum
            cedit := "N"                            // N = Total Stock   
            SELECT Part
            SET ORDER TO 1 
            SEEK mpartnum
            PartDets( mpartnum ) 
            ***        RESTSCREEN(  0, 0, 24,80,tempEqu )
            mcodeno := Name->Codeno
            mcontinue := "Y"
            LOOP

         CASE nsel == 13                 // Add Drawing   
            mpartnum := Part->Partnum
            DrawReview()
            mcontinue := "Y"
            LOOP  

         CASE nsel == 14                 // Module
            ModWoCost()                        // XLF_Quot
            SELECT Equ
            SEEK cpartorg
            mmodcode := cpartorg  
            mcontinue := "Y"
            LOOP
         CASE nsel == 15                // EDit Module Desc 
            SELECT EquDesc
            SEEK mmodcode
            SCROLL(  11, 0, 17,80 )
            DISPBOX( 11, 1, 17,79,2 )
            cdesc := EquDesc->Desc 
            @ 12,11 SAY EquDesc->Desc COLOR "BG+"
            @ 14,10 GET cdesc
            READ   
            ApRlock()
            EquDesc->Desc := cdesc
            UNLOCK
            mcontinue := "Y"
            LOOP
         CASE nsel == 16                  // Product
            coperno := SPACE( 8 )
            GroupSelect( @coperno )    // XLF_QU9
            SELECT EquDesc
            ApRlock()
            EquDesc->Operno := coperno
            UNLOCK
            LOOP 
      ENDCASE
   ENDDO                                              // mcontinue

   RETURN mmodcode

   ****---- End of EquSearch()

   *****-------------------------------------------------------------------------

FUNCTION QuotJCut( mcodeno )

   mcontinue := "Y"
   DO WHILE mcontinue == "Y"
      
      mequ:= mstock:= moper:= mABC := "N"
      mequ    := "Y"
      mxy     := "Y"
      mlevel  := 4
      ***   IF mequ = "Y"
         SCROLL( 14, 0,24,80 )
         DISPBOX( 14, 1,17,79, 2 )
         mlevel := 1
         @ 15,10 SAY "Module Level Required 2, 3, 4" GET mlevel PICTURE "9"
          READ
         cpagehd := "MPjc-"+STR( mlevel, 1, 0 )
         mxy     := "Y"
      **** ApGetN( "Include XY Parts" )
         IF mxy = "Y"
            cpagehd := "MPjc-XY"+STR( mlevel, 1, 0 )
            @ 16,10 SAY "XY Parts Included"
         ENDIF 
      ***   ENDIF
      mprogress := "Y"
      moper := "N"
      minfo := "Y"
         mABC := "N"
      mwhere := "S"
      npl    := 67
      nl     := 0
      
       Printsel()                               // _LF_Init

      nQty:= nlength := 0
      minvno := Debit->Invno
      @ nl, 2 SAY Control->U_Name
      @ nl,45 SAY STR(DAY(DATE()),3)+" "+CMONTH(DATE());
                 +STR(YEAR(DATE()),5)
      ***   @ nl,67 SAY cpagehd
      nl+=2
      SELECT Name
      SEEK Debit->Codeno
      @ nl, 0 SAY TRIM( Name->Name )+"  "+TRIM( Debit->Est )+" JC- "+minvno
      nl++
      IF Debit->BranchId != SPACE(2)
         SELECT Branch
         mfind := Debit->Codeno+Debit->BranchId
         SEEK mfind
         @ nl,45 SAY Branch->Name
      ENDIF
      nl++
      @ nl, 2 SAY Name->Add1
      IF Debit->BranchId != SPACE(2)
         @ nl,45 SAY Branch->Add1
      ENDIF
      nl++
      @ nl, 2 SAY Name->Add2
      IF Debit->BranchId != SPACE(2)
         @ nl,45 SAY Branch->Add2
      ENDIF
      nl++
      @ nl, 2 SAY Name->Add3
      IF Debit->BranchId != SPACE(2)
         @ nl,45 SAY Branch->Add3
      ENDIF
      nl++
      @ nl, 2 SAY Name->Add4
      IF Name->Phone != SPACE(15)
         @ nl,24 SAY Name->Phone                // Business Phone
       ELSE
         @ nl,24 SAY Name->Ephone               // Home Phone
      ENDIF
      IF Debit->BranchId != SPACE(2)
         @ nl,45 SAY Branch->Add4
         @ nl,64 SAY Branch->Phone             // Business Phone
      ENDIF
      nl++
      @ nl, 3 SAY Debit->Fault
      nl++
      ***   @ nl, 0 SAY Name->Add5
      SELECT Quot
      SET ORDER TO 2
      SEEK mcodeno
      @ nl, 3 SAY Debit->Message
      @ nl,54 SAY Debit->DbDate
      @ nl,65 SAY "J/C # "+minvno
      nl+=2
      @ nl,10 SAY "Start Date"
      @ nl,23 SAY DTOC( Debit->StartDate ) 
      @ nl,34 SAY "Due Date"
      @ nl,44 SAY DTOC( Debit->DueDate ) 
      @ nl,58 SAY "O/N # "+Debit->Ordnum
      nlabpart := 0
      nl+=2
      DO WHILE Quot->Codeno = mcodeno .AND. Quot->( !EOF() )
         IF Quot->Invno != minvno
            SKIP ALIAS Quot
            LOOP
         ENDIF
         nrecno1:= nrecno2:= nrecno3:= nrecno4 := 0
         nqty1:= nqty2:= nqty3:= nqty4 := 0
         nequ1:= nequ2:= nequ3:= nequ4 := 0
         nquot := Quot->Qty
         nequqty1:= nequqty2:= nequqty3:= nequqty4 := 0
         SELECT Equ
         mmod1 := TRIM( Quot->Partnum )
         SEEK mmod1
         nequqty1 := Equ->PartQty
				 IF FOUND()
						SELECT Part
						 ApFLock( 3 )
						Part->ABC := "M"                   // to find modules
						UNLOCK
				 ENDIF
         SELECT Part
         SEEK Quot->Partnum
      ***         @ nl, 2 SAY Part->Desc+"             "+SUBSTR( Quot->Partnum, 1,16 )
            @ nl, 0 SAY STR( Quot->Qty, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6 );
                        +" "+Part->Desc;
                        +" "+SUBSTR( Quot->Partnum, 1,16 )    
            nl++
            IF Quot->Partnum = Message->LabPart
               nlabpart += Quot->Qty
            ENDIF   
            IF Part->Detail != SPACE( 43 )
               @ nl,12 SAY Part->Detail
               nl++
            ENDIF
            IF Part->Detail1 != SPACE( 43 )
               @ nl,12 SAY Part->Detail1
               nl++
            ENDIF
            IF Part->Detail2 != SPACE( 43 )
               @ nl,12 SAY Part->Detail2
               nl++
            ENDIF
            IF Part->Detail3 != SPACE( 43 )
               @ nl,12 SAY Part->Detail3
               nl++
            ENDIF
            mpartnum := Quot->Partnum
         SELECT EquCut
         SEEK Quot->ModSeqno
         DO WHILE EquCut->ModSeqno = Quot->Modseqno .AND. EquCut->( !EOF() )
            IF mwhere = "S"
               IF nl > 22
                  INKEY( 0 )
                  SCROLL()
                  nl := 0
                ENDIF
            ENDIF
            @ nl, 7 SAY STR( EquCut->Qty, 8 )+" x ";
                       +EquCut->ModRef;
                       +STR( EquCut->Length, 8, 3  )
            IF EquCut->Width > 0
                @ nl,65 SAY "x"+STR( EquCut->Width, 8, 3  )
            ENDIF
           nl++
           SKIP ALIAS EquCut
         ENDDO
         IF Quot->Info != SPACE( 45 )
            @ nl,12 SAY Quot->Info
            nl++
         ENDIF
         IF Quot->Info2 != SPACE( 45 )
            @ nl,12 SAY Quot->Info2
            nl++
         ENDIF
         IF Quot->Info3 != SPACE( 45 )
            @ nl,12 SAY Quot->Info3
            nl++
         ENDIF
         IF Quot->Info4 != SPACE( 45 )
            @ nl,12 SAY Quot->Info4
            nl++
         ENDIF
         IF Quot->Info5 != SPACE( 45 )
            @ nl,12 SAY Quot->Info5
            nl++
         ENDIF
         IF Quot->Info6 != SPACE( 45 )
            @ nl,12 SAY Quot->Info6
            nl++
         ENDIF
         IF Quot->Info7 != SPACE( 45 )
            @ nl,12 SAY Quot->Info7
            nl++
         ENDIF
         IF Quot->Info8 != SPACE( 45 )
            @ nl,12 SAY Quot->Info8
            nl++
         ENDIF
         IF Quot->Info9 != SPACE( 45 )
            @ nl,12 SAY Quot->Info9
            nl++
         ENDIF
     IF mlevel >= 1
         SELECT Equ
         GOTO TOP
         SET EXACT ON
         mmod1 := TRIM( Quot->Partnum )
         SEEK mmod1
         IF FOUND()   
            DO WHILE Equ->Modcode = mmod1 .AND. Equ->( !EOF() )
               IF nl > npl
                  IF mwhere = "P"
                     EJECT
                     nl := 0
                   ENDIF
               ENDIF
               IF mwhere = "S"
                  IF nl > 22
                     INKEY( 0 )
                     SCROLL()
                     nl := 0
                  ENDIF
               ENDIF
               IF mxy = "N"
                  IF SUBSTR( Equ->Partnum, 1, 2 ) = "XY"
                     SKIP ALIAS Equ
                     LOOP
                  ENDIF
               ENDIF
               SELECT Part
               SEEK Equ->Partnum
               nqty1:= nequqty1 := Equ->PartQty
               nequ1 := nqty1* nquot
               @ nl, 0 SAY "."
               @ nl, 3 SAY STR( nequ1, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                        +" "+Part->Desc;
                        +" "+SUBSTR( Part->Partnum, 1,16 )    
      ***            @ nl, 6 SAY Part->Desc+"       "+SUBSTR( Equ->Partnum, 1,16 )
      ***            @ nl,70 SAY Equ->PartQty PICTURE "9999.999"
               IF Equ->Partnum = Message->LabPart
                  nlabpart += nequ1
               ENDIF
               nl++
               IF Part->Detail != SPACE( 43 )
                  @ nl,12 SAY Part->Detail
                  nl++
               ENDIF
               IF Part->Detail1 != SPACE( 43 )
                  @ nl,12 SAY Part->Detail1
                  nl++
               ENDIF
               IF Part->Detail2 != SPACE( 43 )
                  @ nl,12 SAY Part->Detail2
                  nl++
               ENDIF
               IF Part->Detail3 != SPACE( 43 )
                  @ nl,12 SAY Part->Detail3
                  nl++
               ENDIF
               mpartnum := Equ->Partnum
         mseek := Equ->ModSeqno+mpartnum
         SELECT EquCut
         GOTO TOP
         SEEK mseek
         DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
            @ nl, 7 SAY STR( nquot*EquCut->Qty, 4 );
                        +" x "+EquCut->ModRef;
                        +STR( EquCut->Length, 8, 3  )
                        IF EquCut->Width > 0
                           @ nl,65 SAY "x"+STR( EquCut->Width, 8, 3  )
                        ENDIF
            nl++
            SKIP ALIAS EquCut
         ENDDO
         SELECT Equ
         mmod2 := TRIM( Equ->Partnum )
         nrecno2 := RECNO() 
     IF mequ = "Y"
         GOTO TOP
         SEEK mmod2
         IF FOUND()   
            IF mlevel >= 2
            DO WHILE Equ->Modcode = mmod2 .AND. Equ->( !EOF() )
               IF nl > npl
                  IF mwhere = "P"
                     EJECT
                     nl := 0  
                   ENDIF
               ENDIF
               IF mwhere = "S"
                  IF nl > 22
                     INKEY( 0 )
                     SCROLL()
                     nl := 0
                  ENDIF
               ENDIF
               IF mxy = "N"
                  IF SUBSTR( Equ->Partnum, 1, 2 ) = "XY"
                     SKIP ALIAS Equ
                     LOOP
                  ENDIF
               ENDIF
               nqty2 := Equ->PartQty
               nequ2 := ( nqty1 * nqty2 )* nquot
               nequqty2 := Equ->Partqty*nequqty1
               SELECT Part
               SEEK Equ->Partnum
               @ nl, 0 SAY ".."
               @ nl, 6 SAY STR( nequ2, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                        +" "+Part->Desc;
                        +" "+SUBSTR( Equ->Partnum, 1,16 )    

      ***            @ nl, 8 SAY Part->Desc+"       "+SUBSTR( Equ->Partnum, 1,16 )
               IF Equ->Partnum = Message->LabPart
                  nlabpart += nequ2
               ENDIF
      ****            @ nl,70 SAY Equ->PartQty PICTURE "9999.999"
               IF mstock = "Y"
                  IF Part->Instock > ( nequ2*Equ->PartQty )
                     IF SUBSTR( Equ->Partnum, 3, 1 ) = "-"
                        nl++
                        @ nl,20 SAY "Part in Stock"
                        @ nl,34 SAY Part->Instock PICTURE "99,999.999"
                        nl++ 
                        SKIP ALIAS Equ
                        LOOP
                     ENDIF
                  ENDIF
               ENDIF               // mstock 
               nl++
               IF Part->Detail != SPACE( 43 )
                  @ nl,16 SAY Part->Detail
                  nl++
               ENDIF
               IF Part->Detail1 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail1
                  nl++
               ENDIF
               IF Part->Detail2 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail2
                  nl++
               ENDIF
               IF Part->Detail3 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail3
                  nl++
               ENDIF
               mpartnum := Equ->Partnum
         mseek := Equ->ModSeqno+mpartnum
         SELECT EquCut
         GOTO TOP
         SEEK mseek
         DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
           @ nl, 7 SAY STR( nquot*( nequqty1*EquCut->Qty ), 4 );
                       +" x "+EquCut->ModRef;
                       +STR( EquCut->Length, 8, 3  )
                       IF EquCut->Width > 0
                          @ nl,65 SAY "x"+STR( EquCut->Width, 8, 3  )
                       ENDIF
           nl++
           SKIP ALIAS EquCut
         ENDDO
     IF mlevel >= 3
         SELECT Equ
         mmod3 := TRIM( Equ->Partnum )
         nrecno3 := RECNO() 
         GOTO TOP
         SEEK mmod3
         IF FOUND()   
            DO WHILE Equ->Modcode = mmod3 .AND. Equ->( !EOF() )
               nqty3 := Equ->PartQty
               nequqty3 := Equ->PartQty*nequqty2
               nequ3 := nqty1 * nqty2 * nqty3 * nquot
               IF nl > npl
                  IF mwhere = "P"
                     EJECT
                     nl := 0 
                  ENDIF
               ENDIF
               IF mwhere = "S"
                  IF nl > 22
                     INKEY( 0 )
                     SCROLL()
                     nl := 0
                  ENDIF
               ENDIF
               IF mxy = "N"
                  IF SUBSTR( Equ->Partnum, 1, 2 ) = "XY"
                     SKIP ALIAS Equ
                     LOOP
                  ENDIF
               ENDIF
               SELECT Part
               SEEK Equ->Partnum
               @ nl, 0 SAY "..."
               @ nl, 6 SAY STR( nequ3, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                        +" "+Part->Desc;
                        +" "+SUBSTR( Equ->Partnum, 1,16 )    
      ***             @ nl,10 SAY Part->Desc+"       "+SUBSTR( Equ->Partnum, 1,16 )
      ***            @ nl,70 SAY Equ->PartQty PICTURE "999.999"
               IF Equ->Partnum = Message->LabPart
                  nlabpart += nequ3
               ENDIF
               nl++
               IF Part->Detail != SPACE( 43 )
                  @ nl,16 SAY Part->Detail
                  nl++
               ENDIF
               IF Part->Detail1 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail1
                  nl++
               ENDIF
               IF Part->Detail2 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail2
                  nl++
               ENDIF
               IF Part->Detail3 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail3
                  nl++
               ENDIF
               mpartnum := Equ->Partnum
         mseek := Equ->ModSeqno+mpartnum
         SELECT EquCut
         GOTO TOP
         SEEK mseek
         DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
           @ nl, 7 SAY STR( nquot*( nequqty2*EquCut->Qty ), 4 );
                       +" x "+EquCut->ModRef;
                       +STR( EquCut->Length, 8, 3  )
                       IF EquCut->Width > 0
                          @ nl,65 SAY "x"+STR( EquCut->Width, 8, 3  )
                       ENDIF
      ****         @ nl,70 SAY EquCut->Qty PICTURE "9999.99"
            nl++
            SKIP ALIAS EquCut
         ENDDO
        IF mlevel = 4
            SELECT Equ
            mmod4   := TRIM( Equ->Partnum )
            nrecno4 := RECNO()
            GOTO TOP
            SEEK mmod4
            IF FOUND()
               DO WHILE  Equ->Modcode = mmod4 .AND. Equ->( !EOF() )
                  nqty4 := Equ->PartQty
                  nequqty4 := nequqty3*Equ->PartQty
                  nequ4 := nqty1 * nqty2 * nqty3 * nqty4 * nquot
               IF nl > npl
                  IF mwhere = "P"
                     EJECT
                     nl := 0  
                   ENDIF
               ENDIF
               IF mwhere = "S"
                  IF nl > 22
                     INKEY( 0 )
                     SCROLL()
                     nl := 0
                  ENDIF
               ENDIF
               IF mxy = "N"
                  IF SUBSTR( Equ->Partnum, 1, 2 ) = "XY"
                     SKIP ALIAS Equ
                     LOOP
                  ENDIF
               ENDIF
               SELECT Part
               SEEK Equ->Partnum
               @ nl, 0 SAY "...."
               @ nl, 6 SAY STR( nequ4, 8, 3 )+" "+SUBSTR( Part->Unit, 1, 6);
                        +" "+Part->Desc;
                        +" "+SUBSTR( Equ->Partnum, 1,16 )    
      ***            @ nl,12 SAY Part->Desc+"       "+SUBSTR( Equ->Partnum, 1,16 )
      ***            @ nl,70 SAY Equ->PartQty PICTURE "999.999"
               IF Equ->Partnum = Message->LabPart
                  nlabpart += nequ4
               ENDIF
               IF mstock = "Y"
                  IF Part->Instock > nequ4
                     IF SUBSTR( Equ->Partnum, 3, 1 ) = "-"
                        nl++
                        @ nl,20 SAY "Part in Stock"
                        @ nl,34 SAY Part->Instock PICTURE "99,999.999"
                        nl++ 
                        SKIP ALIAS Equ
                        LOOP
                     ENDIF
                  ENDIF
               ENDIF               // mstock 
               nl++
               IF Part->Detail != SPACE( 43 )
                  @ nl,16 SAY Part->Detail
                  nl++
               ENDIF
               IF Part->Detail1 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail1
                  nl++
               ENDIF
               IF Part->Detail2 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail2
                  nl++
               ENDIF
               IF Part->Detail3 != SPACE( 43 )
                  @ nl,16 SAY Part->Detail3
                  nl++
               ENDIF
               mpartnum := Equ->Partnum
         mseek := Equ->ModSeqno+mpartnum
         SELECT EquCut
         GOTO TOP
         SEEK mseek
         DO WHILE EquCut->ModSeqNo+EquCut->Partnum = mSeek .AND. EquCut->( !EOF() )
           @ nl, 7 SAY STR( nquot*( nequqty3*EquCut->Qty ), 4 );
                       +" x "+EquCut->ModRef;
                       +STR( EquCut->Length, 8, 3  )
                       IF EquCut->Width > 0
                          @ nl,65 SAY "x"+STR( EquCut->Width, 8, 3  )
                       ENDIF
            nl++
            SKIP ALIAS EquCut
         ENDDO                                     // EquCut
                  SELECT Equ 
                  SKIP ALIAS Equ
                ENDDO                       //  mmod4
             ENDIF                          
   ENDIF                                   // mlevel = 4                
               SELECT Equ 
               GOTO nrecno4
               SKIP ALIAS Equ
             ENDDO                       //  mmod3
          ENDIF                          // FOUND()  mmod3    
   ENDIF                                 // mlevel = 3
               SELECT Equ
               GOTO nrecno3
               SKIP ALIAS Equ
            ENDDO                       //  mmod2 EOF()
            nl++
         ENDIF                         // Found mmod2
   ENDIF
   ENDIF                   //   mequ Only first
               SELECT Equ
               GOTO nrecno2
               SKIP ALIAS Equ
               ENDDO                       //   mmod1 EOF()
            ENDIF                          // Found mmod1
   ENDIF                                   // mlevel = 1
            SET EXACT OFF      
         nl++
         SELECT Quot
         SKIP ALIAS Quot
      ENDDO                            //   EOF() Quot
      IF nlabpart > 0
         @ nl, 5 SAY Message->LabPart+" = "
         @ nl,28 SAY nlabpart PICTURE "99,999.99"
         nl++
      ENDIF
      @ nl, 5 SAY Debit->Operno
      nl++ 
          IF mprogress = "Y"
                SELECT Quot
                SET ORDER TO 3        // Invno + Partnum
                SEEK Debit->Invno   
                 coperno := Debit->Operno
              SELECT Progress
              SEEK coperno 
                SELECT Quot
                SET ORDER TO 3        // Invno + Partnum
                SEEK Debit->Invno
                SELECT Progress
                @ nl, 1 SAY Progress->DescProg
                IF Quot->Prog01 = SPACE( 12 )
                   @ nl,14 SAY "A __________"
                  ELSE
                   @ nl,14 SAY Quot->Prog01
                ENDIF
                SKIP ALIAS Progress
                @ nl,27 SAY Progress->DescProg
                IF Quot->Prog02 = SPACE( 12 )
                   @ nl,40 SAY "B __________"
                  ELSE
                   @ nl,40 SAY Quot->Prog02
                ENDIF
                SKIP ALIAS Progress
                @ nl,53 SAY Progress->DescProg
                IF Quot->Prog03 = SPACE( 12 )
                   @ nl,66 SAY "C __________"
                  ELSE
                   @ nl,66 SAY Quot->Prog03
                ENDIF
                nl++
                SKIP ALIAS Progress
                @ nl, 1 SAY Progress->DescProg
                IF Quot->Prog04 = SPACE( 12 )
                   @ nl,14 SAY "D __________"
                  ELSE
                   @ nl,14 SAY Quot->Prog04
                ENDIF
                SKIP ALIAS Progress
                @ nl,27 SAY Progress->DescProg
                IF Quot->Prog05 = SPACE( 12 )
                   @ nl,40 SAY "E __________"
                  ELSE
                   @ nl,40 SAY Quot->Prog05
                ENDIF
                SKIP ALIAS Progress
                @ nl,53 SAY Progress->DescProg
                IF Quot->Prog06 = SPACE( 12 )
                   @ nl,66 SAY "F __________"
                  ELSE
                   @ nl,66 SAY Quot->Prog06
                ENDIF
                nl++
                SKIP ALIAS Progress
                @ nl, 1 SAY Progress->DescProg
                IF Quot->Prog07 = SPACE( 12 )
                   @ nl,14 SAY "G __________"
                  ELSE
                   @ nl,14 SAY Quot->Prog07
                ENDIF
                SKIP ALIAS Progress
                @ nl,27 SAY Progress->DescProg
                IF Quot->Prog08 = SPACE( 12 )
                   @ nl,40 SAY "H __________"
                  ELSE
                   @ nl,40 SAY Quot->Prog08
                ENDIF
                SKIP ALIAS Progress
                @ nl,53 SAY Progress->DescProg
                IF Quot->Prog09 = SPACE( 12 )
                   @ nl,66 SAY "I __________"
                  ELSE
                   @ nl,66 SAY Quot->Prog09
                ENDIF 
                nl++
                SKIP ALIAS Progress
                @ nl, 1 SAY Progress->DescProg
                IF Quot->Prog10 = SPACE( 12 )
                   @ nl,14 SAY "J __________"
                  ELSE
                   @ nl,14 SAY Quot->Prog10
                ENDIF
                SKIP ALIAS Progress
                @ nl,27 SAY Progress->DescProg
                IF Quot->Prog11 = SPACE( 12 )
                   @ nl,40 SAY "K __________"
                  ELSE
                   @ nl,40 SAY Quot->Prog11
                ENDIF
                SKIP ALIAS Progress
                @ nl,53 SAY Progress->DescProg
                IF Quot->Prog12 = SPACE( 12 )
                   @ nl,66 SAY "L __________"
                  ELSE
                   @ nl,66 SAY Quot->Prog12
                ENDIF
                nl++
                SKIP ALIAS Progress
                @ nl, 1 SAY Progress->DescProg
                IF Quot->Prog13 = SPACE( 12 )
                   @ nl,14 SAY "M __________"
                  ELSE
                   @ nl,14 SAY Quot->Prog13
                ENDIF
                SKIP ALIAS Progress
                @ nl,27 SAY Progress->DescProg
                IF Quot->Prog14 = SPACE( 12 )
                   @ nl,40 SAY "N __________"
                  ELSE
                   @ nl,40 SAY Quot->Prog14
                ENDIF
                SKIP ALIAS Progress
                @ nl,53 SAY Progress->DescProg
                IF Quot->Prog15 = SPACE( 12 )
                   @ nl,66 SAY "O __________"
                  ELSE
                   @ nl,66 SAY Quot->Prog15
                ENDIF
                nl++
                SKIP ALIAS Progress
                @ nl, 1 SAY Progress->DescProg
                IF Quot->Prog16 = SPACE( 12 )
                   @ nl,14 SAY "P __________"
                  ELSE
                   @ nl,14 SAY Quot->Prog16
                ENDIF
                SKIP ALIAS Progress
                @ nl,27 SAY Progress->DescProg
                IF Quot->Prog17 = SPACE( 12 )
                   @ nl,40 SAY "Q __________"
                  ELSE
                   @ nl,40 SAY Quot->Prog17
                ENDIF
                SKIP ALIAS Progress
                @ nl,53 SAY Progress->DescProg
                IF Quot->Prog18 = SPACE( 12 )
                   @ nl,66 SAY "R __________"
                  ELSE
                   @ nl,66 SAY Quot->Prog18
                ENDIF
                nl+=2
         ENDIF        // Progress
      IF mwhere = "P"
         IF nl > 50
            nl := 0
            EJECT
         ENDIF
      ENDIF
      IF mwhere = "P"
         IF Message->Mess13 != SPACE( 40 )   
            @ nl,26 SAY Message->Mess13
            nl++
         ENDIF
         @ nl, 0 SAY "Qty      MATERIALS                         Price       Date     Hours"
         nl++
         npl := nl
         nline = 1
         FOR nline = 1 TO ( 60-npl )           // Was 63
         @ nl, 0 SAY "______:___________________________________:__________:_________:___________"
           nl+=2
           IF nl >60
             EXIT
           ENDIF
           npl++ 
         NEXT
      ENDIF 
      IF mwhere = "S"
         INKEY( 0 )
         SCROLL()
         nl := 0
      ENDIF
      nl++
      IF mwhere == "P"
         EndPrint()
       ELSE
         WAIT
      ENDIF 
      SCROLL( 18, 0, 24,80 )
      mcontinue := "N" 
      ****   mcontinue := ApGetN( TRIM( Message->Another )+" Print" )
   ENDDO

   SELECT Quot
   SET ORDER TO 1

   RETURN mcodeno

   ****----- End of QuotJCut()

   ***--------------------------  End Of XLF_EQU5.PRG

