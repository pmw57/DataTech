*** JoKir10  07-10-11 14:08:57 

**** REM  Christine Products Index Files

/*  Program ......:                 CHRIENDX.PRG
    Authors.......: John Kirby
    Date..........: 15/09/1999
    Functions.....: DBFReIndx
*/

FUNCTION DBFReIndx()

   @ 14,54 SAY "Indexing Data Files"
   @ 15,58 SAY "PLEASE WAIT"
   @ 16,54 SAY "THESE ARE BIG FILES"
  CLOSE DATABASES
  USE Name
      PACK
      REPLACE ALL Status WITH "N" 
      INDEX ON Codeno                      TO NameInd
  USE Admin
      PACK
      INDEX ON Adminno                    TO AdminInd
  USE Balance
      PACK
      INDEX ON SUBSTR( DTOS( Date ), 1, 6 ) TO BalInd
  USE Branch
      PACK
      INDEX ON Codeno+Branchid              TO BranchIn
  USE Cat
      PACK
      INDEX ON Catno                     TO CatInd
  USE Cashbook
      PACK
      INDEX ON Cashno                    TO CashInd
  USE Credit
      PACK 
      INDEX ON Codeno+DTOS( InvDate )    TO CredInd
  USE CredProf
      PACK 
      INDEX ON Codeno+Invno+DTOS( InvDate ) TO CProfInd
  USE Cusnotes
      PACK
      INDEX ON Code_Ref                  TO CusNotes
  USE Debit
      PACK
      INDEX ON Codeno+BranchId+DTOS(Dbdate)+Invno  TO DebInd
      INDEX ON Invno                               TO DebIvc
  USE DebProf
***      DELETE ALL FOR DbDate < DATE()-366
      PACK
      INDEX ON Codeno+DTOS(Dbdate)+Invno  TO DebProfI
***      INDEX ON Saleno+DTOS(Dbdate)+Invno TO DebProfI
      INDEX ON Invno                     TO DebPIvc
  USE Demand
      PACK
      INDEX ON Operno+Labno+Desc            TO DemOper
  USE DepPay
      ZAP
  USE Deposit
      PACK
      INDEX ON DTOS( Depdate )           TO DepInd
      INDEX ON Saleno                    TO DepSaleI
      INDEX ON Depref                    TO DepRef
  USE Drawing
      PACK
      INDEX ON Drawno                    TO DrawInd
  USE Equ
      PACK
      INDEX ON Modcode+Partnum           TO EquInd
  USE EquCut
      DELETE ALL FOR Qty <= 0
      PACK
      INDEX ON ModSeqno+Partnum          TO EquCut
  USE EquDesc
      PACK
      INDEX ON Modcode                   TO EDescInd
      INDEX ON EquId+ModCode             TO EquIdInd
  USE EqunDesc
      PACK
      INDEX ON Unitcode                  TO EqunInd
  USE Fault
      PACK
      INDEX ON Partnum+Brand             TO FaultInd
  USE Hist
      PACK
      INDEX ON Codeno+Partnum+Invno+DTOS( PDate ) TO HistInd    // Invno
      INDEX ON Partnum+Codeno+DTOS( PDate ) TO HistPart
  USE Invoice
      PACK
      INDEX ON Invno+Partnum             TO InvInd
      INDEX ON Invno+Ordnum+Partnum      TO InvPartI
  USE Labour
***      DELETE ALL FOR Time <= 0
      PACK
      INDEX ON Codeno+DTOS( Date )+Partnum  TO LabInd
      INDEX ON Invno+Partnum+Codeno         TO Labour
  USE LabCut
      PACK
      INDEX ON Partnum+Order                TO InvLab
  USE Operate
      PACK
      INDEX ON Operno                    TO OperInd
  USE Orders
      PACK
      INDEX ON Partnum+Ordnum            TO Ordpart
      INDEX ON Ordnum+Partnum            TO Ordord
      INDEX ON Codeno+Ordnum             TO OrdCode
  USE Part
      PACK
***      REPLACE ALL Part->ABC WITH " " 
      REPLACE ALL Part->Instock WITH 0 FOR Part->Instock < 0 
      REPLACE ALL Part->Locate WITH "NA" FOR Part->Locate = "      "
      INDEX ON Partnum                   TO PartInd     
      INDEX ON Catno+Partnum             TO PartCat     
      INDEX ON PartId+Partnum            TO PartDesc
      INDEX ON Locate+Partnum            TO PartLoc
  USE PartOper
      DELETE ALL FOR DATE < DATE()-100  
      PACK
      INDEX ON Operno+Adminno+Order      TO PartOpIn  
      INDEX ON Codeno+Operno             TO Operno
  USE PartSer
      PACK
      INDEX ON Partnum+Serno             TO PSernoIn
  USE Pay
      PACK
      INDEX ON DTOS(Cheqdate)+Cheqno     TO PayInd
      INDEX ON Recon                     TO PayRecon
      INDEX ON Codeno                    TO PayCode 
  USE Progress
      PACK
      INDEX ON Operno+Order              TO ProgInd
  USE Prof
      PACK
      INDEX ON Operno+Adminno            TO ProfOper  
      INDEX ON Codeno+Partnum            TO ProfInd  
  USE ProfNat
      PACK
      INDEX ON Codeno+Partnum            TO ProfNatI
      INDEX ON Partnum                   TO ProfNatP
  USE Rec
      PACK
      INDEX ON Codeno+DTOS( Recdate )      TO RecInd
      INDEX ON Recno                     TO Recno
  USE Rept
      PACK
      INDEX ON CodeRecno                 TO ReptCInd
      INDEX ON Codeno+Stat               TO ReptNInd
  USE Salebook
      PACK
      INDEX ON Saleno                        TO SaleInd
  USE Serv
      PACK
      INDEX ON Codeno+Invno              TO ServInd
  USE Supl 
      PACK
      INDEX ON Partnum+Codeno                 TO SuplPIn
      INDEX ON Codeno+DTOS( Date )+Stat       TO SuplNIn
  USE QuotOrd
      PACK
      INDEX ON Codeno+Ordnum+Partnum          TO QuotOrd
  USE QuotPart
      ZAP
  USE Quot
****      REPLACE ALL Invno WITH "000000" 
      PACK
      INDEX ON Codeno+BranchId+DTOS( DBDate ) TO QuotInd 
      INDEX ON Codeno+BranchId+Partnum        TO QuotPInd
      INDEX ON Invno+Partnum                  TO QuotInv 
  USE QuotInfo
      PACK
      INDEX ON Codeno+Partnum                TO QuInfo
  USE QuotStk
      PACK
      INDEX ON Invno+ModPart                 TO QStkInd
      INDEX ON Partnum+Invno                 TO QStkPart
      INDEX ON Codeno+Partnum                TO QStkCode
***  USE QuotStXY
***      ZAP 
***      PACK
***      INDEX ON Invno+ModPart                 TO QStkXYI
***      INDEX ON Partnum+Invno                 TO QStkXYP
***      INDEX ON Codeno+Partnum                TO QStkXYC
  USE Status
      ZAP           // Check This  
***      PACK
      INDEX ON Invno+Partnum                TO StatJob
      INDEX ON Codeno                       TO StatCode
      INDEX ON ModCode+Partnum              TO StatMod

  USE PMPPJNL
      DELETE ALL FOR Codeno = SPACE( 8 ) 
      PACK
      INDEX ON Codeno+DTOS( Pay_Per )       TO PMPPjnl
    CLOSE DATABASES

RETURN NIL

****---- End DBFReIndx
***  USE QuotCut
***      ZAP
***      INDEX ON ModSeqno                      TO QCutInd
***      DELETE ALL FOR SUBSTR( Partnum, 4,16 )  = SPACE( 16 ) 
***      PACK
***  USE Supl
***      APPEND FROM SuplOUT 
***  USE SuplOUT
***      ZAP

*****------------------  End of CHRIENDX.PRG