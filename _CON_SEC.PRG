   ***   JK 29-08-11 07:49:45 

/* 
   Program ......:            _CON_SEC.PRG

   Authors.......: John Kirby
   Date..........: 25/12/94
   Functions.....: Control, Passcode, Encode
                   GenerateCode, Checksum
                   */

// (c) Copyright (c) 1995 Chozen Ltd Christchurch. All Rights reserved.

FUNCTION Control()

   /*
   Taken Out
   IF Control->LastJob = SPACE( 12 )
      SELECT Control
       ApRLock( 3 )
      Control->LastJob := c_stdcolor
      UNLOCK
   ENDIF   
   */

   /*

   IF !FILE("CONTROL.DBF")
      SCROLL()
      SETCOLOR(c_hicolor)
      @  5,10 SAY "Control File is missing ..."
      @  7,15 SAY "Please contact your Supplier."
      @  9,15 SAY "Press any key to continue."
      SETCOLOR(c_stdcolor)
      WAIT ""
      CANCEL
   ENDIF

    Encode()                           // Below

    */

   /*
   TAKEN OUT
       IF Control->Lastchge != ( Control->SetDate )           
            ? REPLICATE(chr(7), 3)
         
           TEXT

           SORRY, You are no longer authorised to use this program . If you have
                  found this program useful then the latest (Improved) version
                  can be obtained from your Supplier.

                  YOUR DATA IS SAFE SO Don't worry - FAX today.

                  Thank you for your Time  BYE BYE !!!!!!

         ENDTEXT
         WAIT "         ILLEGAL COPYING IS THEFT AS YOU WELL KNOW " 
      ENDIF
   taken out
   */
   RETURN NIL

   ***------------------------------------------------------------------*

   FUNCTION Passcode()

   LOCAL mcode   := SPACE(6)
   LOCAL nchksum := 0

   mcode := GenerateCode( Control->EntLev1 )
   nchksum := Checksum( TRIM(Control->EntLev1) )
   mcode += CHR( INT( nchksum / 256 ) ) + CHR( nchksum%256 )

   // Create security code ( now 6 chrs long )
   ApRLock( 3 )
   REPLACE Control->EntLev1 WITH mcode
   UNLOCK

   RETURN NIL

   ***---- End Passcode()

   **-------------------------------------------------------------------

   FUNCTION Encode()

   LOCAL mcode := SPACE(4)
   LOCAL mname := TRIM( Control->U_Name )

   DO WHILE LEN(mname) < 7
   mname := mname+TRIM( Control->U_Name )
   ENDDO
   mcode := GenerateCode( mname )

   IF Control->Code != mcode
   IF SUBSTR( Control->Code, 1, 3 ) = SUBSTR( Control->U_Name, 1, 3 )
   RETURN NIL
   ELSE
   SCROLL()
   ? REPLICATE(chr(7), 6)
   @  5,10 SAY "CONTROL RECORDS INVALID !!!"
   @  7,10 SAY "Please call your supplier."
   @  9,15 SAY "Press any key to continue ..."
   WAIT ""
   CANCEL
   ENDIF
   ENDIF

   RETURN NIL

   **------- End of EnCode()

   **-------------------------------------------------------------------

   FUNCTION GenerateCode( mname )

   LOCAL mna1  := SUBSTR(mname,5,1)
   LOCAL mna2  := SUBSTR(mname,3,1)
   LOCAL mna3  := SUBSTR(mname,6,1)
   LOCAL mna4  := SUBSTR(mname,1,1)
   LOCAL mnc1  := asc(mna1) + 137
   LOCAL mnc2  := asc(mna2) + 6
   LOCAL mnc3  := asc(mna3) * 2
   LOCAL mnc4  := asc(mna4) + 91
   LOCAL mch1  := chr(mnc1)
   LOCAL mch2  := chr(mnc2)
   LOCAL mch3  := chr(mnc3)
   LOCAL mch4  := chr(mnc4)
   
   RETURN mch1 + mch2 + mch3 + mch4

   ***---- End GenerateCode()

   **-------------------------------------------------------------------

   FUNCTION Checksum( cstring )

   LOCAL nstrlen := LEN( cstring )
   LOCAL npos    := 1
   
   DO WHILE npos <= nstrlen
   nchksum = nchksum + ASC( SUBSTR( cstring, npos, 1 ) )
   npos = npos + 1
   ENDDO
   
   **------- End of Checksum()

   *****---------------------     END OF FILE _CON_SEC.PRG
