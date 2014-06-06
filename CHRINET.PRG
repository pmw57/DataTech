// **  JoKir10    21-10-11 22:14:21

/*  Program ......:               CHRINET.PRG
    Authors.......: John Kirby
    Date..........: 15/09/1999
    Functions.....: XF_DBFUse
*/

FUNCTION XF_DBFUse()

    Scroll()

    CLOSE DATABASES

    DispBox( 6, 10, 16, 75, 2 )
    clabel := " DataTech Accounts System"
    @  8, 14 SAY "Please Check DATE is CORRECT !!!!"
    @  8, Col() + 2 SAY Date()
    @ 10, 14 SAY "Please Wait Loading Data Files"
    @ 13, 42 - Len( clabel ) / 2 SAY clabel

    USE Admin    INDEX AdminInd                   SHARED NEW
    USE Balance  INDEX BalInd                     SHARED NEW
    USE Branch   INDEX BranchIn                   SHARED NEW
    USE Cat      INDEX CatInd                     SHARED NEW
    USE Cashbook INDEX CashInd                    SHARED NEW
    USE Credit   INDEX CredInd                    SHARED NEW
    USE CredProf INDEX CProfInd                   SHARED NEW
    USE Control                                   SHARED NEW  // Master File
    USE CusNotes INDEX CusNotes                   SHARED NEW
    USE DataDbf                                   SHARED NEW
    USE Debit    INDEX DebInd, DebIvc             SHARED NEW
    USE Deppay                                    SHARED NEW
    USE DebProf  INDEX DebProfI, DebPIvc          SHARED NEW
    USE Demand   INDEX DemOper                    SHARED NEW
    USE Deposit  INDEX DepInd, DepSaleI, Depref   SHARED NEW
    USE Drawing  INDEX DrawInd                    SHARED NEW // Drawno
    USE Equ      INDEX EquInd                     SHARED NEW // Modcode+Partnum
    USE EquCut   INDEX EquCut                     SHARED NEW // ModSeqno
    USE EquDesc  INDEX EDescInd, EquIdInd         SHARED NEW // Mod Desc- ModCode,Partnum,PartQty
    USE EqunDesc INDEX EqunInd                    SHARED NEW
    USE Fault    INDEX FaultInd                   SHARED NEW
    USE Hist     INDEX HistInd, HistPart          SHARED NEW
    USE Invoice  INDEX InvInd, InvPartI           SHARED NEW
    USE Labour   INDEX LabInd, Labour             SHARED NEW
    USE MENU                                      SHARED NEW
    USE Menu1                                     SHARED NEW
    USE Menu2                                     SHARED NEW
    USE MESSAGE                                   SHARED NEW
    USE MenuDbf                                   SHARED NEW
    USE MenuDbfA                                  SHARED NEW
    USE MenuDbfB                                  SHARED NEW
    USE Name     INDEX NameInd                    SHARED NEW
    USE Note                                      SHARED NEW
    USE Part     INDEX PartInd, PartCat, PartDesc, PartLoc SHARED NEW
    USE PartOper INDEX PartOpIn, Operno           SHARED NEW
    USE PartSer  INDEX PSernoIn                   SHARED NEW
    USE Pay      INDEX PayInd, PayRecon, PayCode  SHARED NEW
    USE Progress INDEX ProgInd                    SHARED NEW
    USE Prof     INDEX ProfOper, ProfInd          SHARED NEW
    USE LabCut   INDEX InvLab                     SHARED NEW
    USE Months                                    SHARED NEW
    USE Operate  INDEX OperInd                    SHARED NEW
    USE ProfNat  INDEX ProfNatI, ProfNatP         SHARED NEW
    USE Rec      INDEX RecInd, Recno              SHARED NEW
    USE Rept     INDEX ReptCInd, ReptNInd         SHARED NEW
    USE Salebook INDEX SaleInd                    SHARED NEW
    USE Serv     INDEX ServInd                    SHARED NEW
    USE Supl     INDEX SuplPIn, SuplNIn           SHARED NEW
    USE Quot     INDEX QuotInd, QuotPInd, QuotInv SHARED NEW
    USE QuotInfo INDEX QuInfo                     SHARED NEW
    USE QuotOrd  INDEX QuotOrd                    SHARED NEW
    USE QuotPart                                  SHARED NEW
    USE QuotStk  INDEX QStkInd, QStkPart, QstkCode SHARED NEW
    USE Orders   INDEX Ordpart, Ordord, OrdCode   SHARED NEW
    USE Status   INDEX StatJob, StatCode, StatMod SHARED NEW
    USE Pmppjnl  INDEX PMPPjnl                    SHARED NEW
    USE Taxrates                                  SHARED NEW
    USE WkEnds                                    SHARED NEW
    USE WkDeb                                     SHARED NEW

    // **   QuotStock()                         // XF_Util
    // **   USE QuotStXY INDEX QStkXYI, QStkXYP           SHARED NEW
    // **   USE QuotPart
    // **   USE JobHist                                   SHARED NEW
    // **   USE QuotCut  INDEX QCutInd                    SHARED NEW

    RETURN NIL


// ****---------------- END OF FILE CHRINET.PRG
