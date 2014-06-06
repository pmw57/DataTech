** PCODEAAH.CH
** Manifest constants for printer control codes
** These are standard for STAR, BROTHER, etc. conformimg to EPSON LX800
** Additionally STAR has a double height mode used by AAHIRE for Statements

#define P_RESET  CHR(27)+CHR(64)         // Reset to standard
 ** Beware dont change "C" to 65 causes line feeds
#define P_PL51   CHR(27)+"C"+ CHR(51)    // Page length 51 lines
#define P_PL55   CHR(27)+"C"+ CHR(55)    // Page length 55 lines
#define P_PL66   CHR(27)+"C"+ CHR(66)    // Page length 66 lines
 ** Above two lines need CHR with number of lines  ie CHR(51) & CHR(66)
 ** Manual specifies figures only - not CHR() but figures don't work - why ?
#define P_EXP1   CHR(14)                 // Double width CHRs (1 line)
#define P_EXPX   CHR(20)                 //   -- cancel --
#define P_COND   CHR(15)                 // Condensed print (17 cpi)
#define P_CONDX  CHR(18)                 //   -- cancel --
#define P_ELITE  CHR(27)+"M"             // Elite pitch (12 cpi)
#define P_PICA   CHR(27)+"P"             // Pica pitch (10 cpi)
#define P_SUB    CHR(27)+"S"+CHR(1)      // Subscript
#define P_SUBX   CHR(27)+"T"             // - cancel -
#define P_UL     CHR(27)+"-"+CHR(49)     // Print underlined
#define P_ULX    CHR(27)+"-"+CHR(48)     //   -- cancel --
#define P_EXPD   CHR(27)+"!"+CHR(48)     // Expanded & double strike
#define P_ENH    CHR(27)+"E"             // Enhanced print
#define P_NLQ    CHR(27)+"x"+"1"         // N L Q
#define P_DH     CHR(27)+"w"+"1"         // Double height
 ** Double height not valid for EPSON printer - O.K. on STAR
** These next 5 should be in specific AAHIRE.CH file ??
#define P_AANAM  "AA APPLIANCE HIRE"
#define P_ADD1   "430 St ASAPH St.,"
#define P_ADD2   "CHRISTCHURCH"
#define P_POST1  "P O Box 33-024"
#define P_POST2  "BARRINGTON"

** End of file - PCODEAAH.CH
