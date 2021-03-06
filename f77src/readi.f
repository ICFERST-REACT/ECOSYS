
      SUBROUTINE readi(NA,ND,NT,NE,NAX,NDX,NTX,NEX,NF,NFX,NTZ
     2,NTZX,NHW,NHE,NVN,NVS)
C
C     THIS SUBROUTINE READS ALL SOIL AND TOPOGRAPHIC INPUT FILES
C
      include "parameters.h"
      include "filec.h"
      include "files.h"
      include "blkc.h"
      include "blk2a.h"
      include "blk2b.h"
      include "blk2c.h"
      include "blk8a.h"
      include "blk8b.h"
      include "blk17.h"
      DIMENSION NA(10),ND(10),NM(JY,JX),DHI(JX),DVI(JY)
      CHARACTER*16 DATA(30),DATAC(30,250,250),DATAP(JP,JY,JX)
     2,DATAM(JP,JY,JX),DATAX(JP),DATAY(JP),DATAZ(JP,JY,JX)
     3,OUTS(10),OUTP(10),OUTFILS(10,JY,JX),OUTFILP(10,JP,JY,JX)
      CHARACTER*3 CHOICE(102,20)
      CHARACTER*8 CDATE
      CHARACTER*16 OUTW,OUTI,OUTT,OUTN,OUTF
      CHARACTER*4 CHARY
      CHARACTER*1 TTYPE,CTYPE,IVAR(20),VAR(50),TYP(50)
      CHARACTER*80 PREFIX
      DIMENSION IDAT(20),DAT(50),DATK(50)
      PARAMETER (TWILGT=0.06976)
C
C     OPEN SITE, TOPOGRAPHY, AND WEATHER FILES FROM
C     FILE NAMES IN DATA ARRAYS LOADED IN 'MAIN'
C
      OPEN(18,FILE='logfile1',STATUS='UNKNOWN')
      OPEN(19,FILE='logfile2',STATUS='UNKNOWN')
      OPEN(20,FILE='logfile3',STATUS='UNKNOWN')
      OPEN(1,FILE=TRIM(PREFIX)//DATA(1),STATUS='OLD')
      OPEN(7,FILE=TRIM(PREFIX)//DATA(2),STATUS='OLD')
      WRITE(18,5000)'  17 APR 2019'
5000  FORMAT(A16)
      NF=1
      NFX=1
      NTZ=0
C
C     READ SITE DATA
C
      READ(1,*)ALATG,ALTIG,ATCAG,IPRCG
      READ(1,*)OXYEG,Z2GEG,CO2EIG,CH4EG,Z2OEG,ZNH3EG
      READ(1,*)IETYPG,ISALTG,IERSNG,NCNG,DTBLIG,DDRGIG,DTBLGG
      READ(1,*)RCHQNG,RCHQEG,RCHQSG,RCHQWG,RCHGNUG,RCHGEUG,RCHGSUG 
     2,RCHGWUG,RCHGNTG,RCHGETG,RCHGSTG,RCHGWTG,RCHGDG
      READ(1,*)(DHI(NX),NX=1,NHE)
      READ(1,*)(DVI(NY),NY=1,NVS)
      CLOSE(1)
      DO 9895 NX=NHW,NHE
      DO 9890 NY=NVN,NVS
      ALAT(NY,NX)=ALATG
      ALTI(NY,NX)=ALTIG
      ATCAI(NY,NX)=ATCAG
      IPRC(NY,NX)=IPRCG
      OXYE(NY,NX)=OXYEG
      Z2GE(NY,NX)=Z2GEG
      CO2EI(NY,NX)=CO2EIG
      CH4E(NY,NX)=CH4EG
      Z2OE(NY,NX)=Z2OEG
      ZNH3E(NY,NX)=ZNH3EG
      IETYP(NY,NX)=IETYPG
      IERSN(NY,NX)=IERSNG
      NCN(NY,NX)=NCNG
      DTBLI(NY,NX)=DTBLIG
      DDRGI(NY,NX)=DDRGIG
      DTBLG(NY,NX)=DTBLGG
      RCHQN(NY,NX)=RCHQNG
      RCHQE(NY,NX)=RCHQEG
      RCHQS(NY,NX)=RCHQSG
      RCHQW(NY,NX)=RCHQWG
      RCHGNU(NY,NX)=RCHGNUG
      RCHGEU(NY,NX)=RCHGEUG
      RCHGSU(NY,NX)=RCHGSUG
      RCHGWU(NY,NX)=RCHGWUG
      RCHGNT(NY,NX)=RCHGNTG
      RCHGET(NY,NX)=RCHGETG
      RCHGST(NY,NX)=RCHGSTG
      RCHGWT(NY,NX)=RCHGWTG
      RCHGD(NY,NX)=RCHGDG
      DH(NY,NX)=DHI(NX)
      DV(NY,NX)=DVI(NY)
      CO2E(NY,NX)=CO2EI(NY,NX)
      H2GE(NY,NX)=1.0E-03
      IF(ALAT(NY,NX).GT.0.0)THEN
      XI=173
      ELSE
      XI=356
      ENDIF
      DECDAY=XI+100
      DECLIN=SIN((DECDAY*0.9863)*1.7453E-02)*(-23.47)
      AZI=SIN(ALAT(NY,NX)*1.7453E-02)*SIN(DECLIN*1.7453E-02)
      DEC=COS(ALAT(NY,NX)*1.7453E-02)*COS(DECLIN*1.7453E-02)
      IF(AZI/DEC.GE.1.0-TWILGT)THEN
      DYLM(NY,NX)=24.0
      ELSEIF(AZI/DEC.LE.-1.0+TWILGT)THEN
      DYLM(NY,NX)=0.0
      ELSE
      DYLM(NY,NX)=12.0*(1.0+2.0/3.1416*ASIN(TWILGT+AZI/DEC))
      ENDIF
9890  CONTINUE
9895  CONTINUE
      DO 9885 NX=NHW,NHE+1
      DO 9880 NY=NVN,NVS+1
      ISALT(NY,NX)=ISALTG
9880  CONTINUE
9885  CONTINUE
C
C     READ TOPOGRAPHY DATA AND SOIL FILE NAME FOR EACH GRID CELL
C
50    READ(7,*,END=20)NH1,NV1,NH2,NV2,ASPX,SL2,SL1,DPTHSX
      READ(7,52)DATA(7)
52    FORMAT(A16)
C
C     OPEN AND READ SOIL FILE
C
      OPEN(9,FILE=TRIM(PREFIX)//DATA(7),STATUS='OLD')
      DO 9995 NX=NH1,NH2
      DO 9990 NY=NV1,NV2
C
C     SURFACE SLOPES AND ASPECTS
C
      ASP(NY,NX)=ASPX
      SL(1,NY,NX)=SL1
      SL(2,NY,NX)=SL2
      DPTHS(NY,NX)=DPTHSX
      ASP(NY,NX)=450.0-ASP(NY,NX)
      IF(ASP(NY,NX).GE.360.0)ASP(NY,NX)=ASP(NY,NX)-360.0
C
C     SURFACE RESIDUE C, N AND P
C
      READ(9,*)PSIFC(NY,NX),PSIWP(NY,NX),ALBS(NY,NX),PH(0,NY,NX)
     2,RSC(1,0,NY,NX),RSN(1,0,NY,NX),RSP(1,0,NY,NX)
     3,RSC(0,0,NY,NX),RSN(0,0,NY,NX),RSP(0,0,NY,NX)
     4,RSC(2,0,NY,NX),RSN(2,0,NY,NX),RSP(2,0,NY,NX)
     5,IXTYP(1,NY,NX),IXTYP(2,NY,NX)
     6,NU(NY,NX),NJ(NY,NX),NL1,NL2,ISOILR(NY,NX)
      NK(NY,NX)=NJ(NY,NX)+1
      NM(NY,NX)=NJ(NY,NX)+NL1
      NL(NY,NX)=NM(NY,NX)+NL2 
C
C     PHYSICAL PROPERTIES
C
      READ(9,*)(CDPTH(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(BKDS(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
C
C     HYDROLOGIC PROPERTIES
C
      READ(9,*)(FC(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(WP(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(SCNV(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(SCNH(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
C
C     PHYSICAL PROPERTIES
C
      READ(9,*)(CSAND(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CSILT(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(FHOL(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(ROCK(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
C
C     CHEMICAL PROPERTIES
C
      READ(9,*)(PH(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CEC(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(AEC(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
C
C     ORGANIC C, N AND P CONCENTRATIONS
C
      READ(9,*)(CORGC(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CORGR(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CORGN(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CORGP(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
C
C     INORGANIC N AND P CONCENTRATIONS
C
      READ(9,*)(CNH4(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CNO3(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CPO4(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
C
C     CATION AND ANION CONCENTRATIONS
C
      READ(9,*)(CAL(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CFE(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CCA(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CMG(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CNA(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CKA(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CSO4(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CCL(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
C
C     PRECIPITATED MINERAL CONCENTRATIONS
C
      READ(9,*)(CALPO(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CFEPO(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CCAPD(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CCAPH(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CALOH(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CFEOH(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CCACO(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(CCASO(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
C
C     GAPON SELECTIVITY CO-EFFICIENTS
C
      READ(9,*)(GKC4(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(GKCH(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(GKCA(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(GKCM(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(GKCN(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(GKCK(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
C
C     INITIAL WATER, ICE CONTENTS
C
      READ(9,*)(THW(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(THI(L,NY,NX),L=NU(NY,NX),NM(NY,NX))
C
C     INITIAL PLANT AND ANIMAL RESIDUE C, N AND P
C
      READ(9,*)(RSC(1,L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(RSN(1,L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(RSP(1,L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(RSC(0,L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(RSN(0,L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(RSP(0,L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(RSC(2,L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(RSN(2,L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      READ(9,*)(RSP(2,L,NY,NX),L=NU(NY,NX),NM(NY,NX))
      REWIND(9)
      RSC(1,0,NY,NX)=AMAX1(1.0E-03,RSC(1,0,NY,NX))
      RSN(1,0,NY,NX)=AMAX1(0.04E-03,RSN(1,0,NY,NX))
      RSP(1,0,NY,NX)=AMAX1(0.004E-03,RSP(1,0,NY,NX))
      CDPTH(0,NY,NX)=0.0
C
C     ADD SOIL BOUNDARY LAYERS ABOVE ROOTING ZONE
C
      IF(NU(NY,NX).GT.1)THEN
      DO 31 L=NU(NY,NX)-1,0,-1
      IF(BKDS(L+1,NY,NX).GT.0.025)THEN
      CDPTH(L,NY,NX)=CDPTH(L+1,NY,NX)-0.01
      ELSE
      CDPTH(L,NY,NX)=CDPTH(L+1,NY,NX)-0.02
      ENDIF
      IF(L.GT.0)THEN
      BKDS(L,NY,NX)=BKDS(L+1,NY,NX)
      FC(L,NY,NX)=FC(L+1,NY,NX)
      WP(L,NY,NX)=WP(L+1,NY,NX)
      SCNV(L,NY,NX)=SCNV(L+1,NY,NX)
      SCNH(L,NY,NX)=SCNH(L+1,NY,NX)
      CSAND(L,NY,NX)=CSAND(L+1,NY,NX)
      CSILT(L,NY,NX)=CSILT(L+1,NY,NX)
      CCLAY(L,NY,NX)=CCLAY(L+1,NY,NX)
      FHOL(L,NY,NX)=FHOL(L+1,NY,NX)
      ROCK(L,NY,NX)=ROCK(L+1,NY,NX)
      PH(L,NY,NX)=PH(L+1,NY,NX)
      CEC(L,NY,NX)=CEC(L+1,NY,NX)
      AEC(L,NY,NX)=AEC(L+1,NY,NX)
      CORGC(L,NY,NX)=0.0*CORGC(L+1,NY,NX)
      CORGR(L,NY,NX)=0.0*CORGR(L+1,NY,NX)
      CORGN(L,NY,NX)=0.0*CORGN(L+1,NY,NX)
      CORGP(L,NY,NX)=0.0*CORGP(L+1,NY,NX)
      CNH4(L,NY,NX)=CNH4(L+1,NY,NX)
      CNO3(L,NY,NX)=CNO3(L+1,NY,NX)
      CPO4(L,NY,NX)=CPO4(L+1,NY,NX)
      CAL(L,NY,NX)=CAL(L+1,NY,NX)
      CFE(L,NY,NX)=CFE(L+1,NY,NX)
      CCA(L,NY,NX)=CCA(L+1,NY,NX)
      CMG(L,NY,NX)=CMG(L+1,NY,NX)
      CNA(L,NY,NX)=CNA(L+1,NY,NX)
      CKA(L,NY,NX)=CKA(L+1,NY,NX)
      CSO4(L,NY,NX)=CSO4(L+1,NY,NX)
      CCL(L,NY,NX)=CCL(L+1,NY,NX)
      CALOH(L,NY,NX)=CALOH(L+1,NY,NX)
      CFEOH(L,NY,NX)=CFEOH(L+1,NY,NX)
      CCACO(L,NY,NX)=CCACO(L+1,NY,NX)
      CCASO(L,NY,NX)=CCASO(L+1,NY,NX)
      CALPO(L,NY,NX)=CALPO(L+1,NY,NX)
      CFEPO(L,NY,NX)=CFEPO(L+1,NY,NX)
      CCAPD(L,NY,NX)=CCAPD(L+1,NY,NX)
      CCAPH(L,NY,NX)=CCAPH(L+1,NY,NX)
      GKC4(L,NY,NX)=GKC4(L+1,NY,NX)
      GKCH(L,NY,NX)=GKCH(L+1,NY,NX)
      GKCA(L,NY,NX)=GKCA(L+1,NY,NX)
      GKCM(L,NY,NX)=GKCM(L+1,NY,NX)
      GKCN(L,NY,NX)=GKCN(L+1,NY,NX)
      GKCK(L,NY,NX)=GKCK(L+1,NY,NX)
      THW(L,NY,NX)=THW(L+1,NY,NX)
      THI(L,NY,NX)=THI(L+1,NY,NX)
      ISOIL(1,L,NY,NX)=ISOIL(1,L+1,NY,NX)
      ISOIL(2,L,NY,NX)=ISOIL(2,L+1,NY,NX)
      ISOIL(3,L,NY,NX)=ISOIL(3,L+1,NY,NX)
      ISOIL(4,L,NY,NX)=ISOIL(4,L+1,NY,NX)
      RSC(1,L,NY,NX)=0.0
      RSN(1,L,NY,NX)=0.0
      RSP(1,L,NY,NX)=0.0
      RSC(0,L,NY,NX)=0.0
      RSN(0,L,NY,NX)=0.0
      RSP(0,L,NY,NX)=0.0
      RSC(2,L,NY,NX)=0.0
      RSN(2,L,NY,NX)=0.0
      RSP(2,L,NY,NX)=0.0
      ENDIF
31    CONTINUE
      ENDIF
C
C     ADD SOIL BOUNDARY LAYERS BELOW ROOTING ZONE
C
      DO 32 L=NM(NY,NX)+1,JZ
      CDPTH(L,NY,NX)=2.0*CDPTH(L-1,NY,NX)-1.0*CDPTH(L-2,NY,NX)
      BKDS(L,NY,NX)=BKDS(L-1,NY,NX)
      FC(L,NY,NX)=FC(L-1,NY,NX)
      WP(L,NY,NX)=WP(L-1,NY,NX)
      SCNV(L,NY,NX)=SCNV(L-1,NY,NX)
      SCNH(L,NY,NX)=SCNH(L-1,NY,NX)
      CSAND(L,NY,NX)=CSAND(L-1,NY,NX)
      CSILT(L,NY,NX)=CSILT(L-1,NY,NX)
      CCLAY(L,NY,NX)=CCLAY(L-1,NY,NX)
      FHOL(L,NY,NX)=FHOL(L-1,NY,NX)
      ROCK(L,NY,NX)=ROCK(L-1,NY,NX)
      PH(L,NY,NX)=PH(L-1,NY,NX)
      CEC(L,NY,NX)=CEC(L-1,NY,NX)
      AEC(L,NY,NX)=AEC(L-1,NY,NX)
C     IF(IPRC(NY,NX).EQ.0)THEN
      CORGC(L,NY,NX)=0.0*CORGC(L-1,NY,NX)
      CORGR(L,NY,NX)=0.0*CORGR(L-1,NY,NX)
      CORGN(L,NY,NX)=0.0*CORGN(L-1,NY,NX)
      CORGP(L,NY,NX)=0.0*CORGP(L-1,NY,NX)
C     ELSE
C     CORGC(L,NY,NX)=CORGC(L-1,NY,NX)
C     CORGR(L,NY,NX)=CORGR(L-1,NY,NX)
C     CORGN(L,NY,NX)=CORGN(L-1,NY,NX)
C     CORGP(L,NY,NX)=CORGP(L-1,NY,NX)
C     ENDIF
      CNH4(L,NY,NX)=CNH4(L-1,NY,NX)
      CNO3(L,NY,NX)=CNO3(L-1,NY,NX)
      CPO4(L,NY,NX)=CPO4(L-1,NY,NX)
      CAL(L,NY,NX)=CAL(L-1,NY,NX)
      CFE(L,NY,NX)=CFE(L-1,NY,NX)
      CCA(L,NY,NX)=CCA(L-1,NY,NX)
      CMG(L,NY,NX)=CMG(L-1,NY,NX)
      CNA(L,NY,NX)=CNA(L-1,NY,NX)
      CKA(L,NY,NX)=CKA(L-1,NY,NX)
      CSO4(L,NY,NX)=CSO4(L-1,NY,NX)
      CCL(L,NY,NX)=CCL(L-1,NY,NX)
      CALOH(L,NY,NX)=CALOH(L-1,NY,NX)
      CFEOH(L,NY,NX)=CFEOH(L-1,NY,NX)
      CCACO(L,NY,NX)=CCACO(L-1,NY,NX)
      CCASO(L,NY,NX)=CCASO(L-1,NY,NX)
      CALPO(L,NY,NX)=CALPO(L-1,NY,NX)
      CFEPO(L,NY,NX)=CFEPO(L-1,NY,NX)
      CCAPD(L,NY,NX)=CCAPD(L-1,NY,NX)
      CCAPH(L,NY,NX)=CCAPH(L-1,NY,NX)
      GKC4(L,NY,NX)=GKC4(L-1,NY,NX)
      GKCH(L,NY,NX)=GKCH(L-1,NY,NX)
      GKCA(L,NY,NX)=GKCA(L-1,NY,NX)
      GKCM(L,NY,NX)=GKCM(L-1,NY,NX)
      GKCN(L,NY,NX)=GKCN(L-1,NY,NX)
      GKCK(L,NY,NX)=GKCK(L-1,NY,NX)
      THW(L,NY,NX)=THW(L-1,NY,NX)
      THI(L,NY,NX)=THI(L-1,NY,NX)
      ISOIL(1,L,NY,NX)=ISOIL(1,L-1,NY,NX)
      ISOIL(2,L,NY,NX)=ISOIL(2,L-1,NY,NX)
      ISOIL(3,L,NY,NX)=ISOIL(3,L-1,NY,NX)
      ISOIL(4,L,NY,NX)=ISOIL(4,L-1,NY,NX)
      RSC(1,L,NY,NX)=0.0
      RSN(1,L,NY,NX)=0.0
      RSP(1,L,NY,NX)=0.0
      RSC(0,L,NY,NX)=0.0
      RSN(0,L,NY,NX)=0.0
      RSP(0,L,NY,NX)=0.0
      RSC(2,L,NY,NX)=0.0
      RSN(2,L,NY,NX)=0.0
      RSP(2,L,NY,NX)=0.0
32    CONTINUE
C
C     CALCULATE DERIVED SOIL PROPERTIES FROM INPUT SOIL PROPERTIES
C
      DO 28 L=1,NL(NY,NX)
      FMPR(L,NY,NX)=(1.0-ROCK(L,NY,NX))*(1.0-FHOL(L,NY,NX))
      BKDS(L,NY,NX)=BKDS(L,NY,NX)/(1.0-FHOL(L,NY,NX))
      FC(L,NY,NX)=FC(L,NY,NX)/(1.0-FHOL(L,NY,NX))
      WP(L,NY,NX)=WP(L,NY,NX)/(1.0-FHOL(L,NY,NX))
      SCNV(L,NY,NX)=0.1*SCNV(L,NY,NX)*FMPR(L,NY,NX)
      SCNH(L,NY,NX)=0.1*SCNH(L,NY,NX)*FMPR(L,NY,NX)
      CCLAY(L,NY,NX)=AMAX1(0.0,1.0E+03-(CSAND(L,NY,NX)
     2+CSILT(L,NY,NX)))
      CORGC(L,NY,NX)=CORGC(L,NY,NX)*1.0E+03
      CORGR(L,NY,NX)=CORGR(L,NY,NX)*1.0E+03
      CORGCX=CORGC(L,NY,NX)+(RSC(1,L,NY,NX)+RSC(0,L,NY,NX))
     2/(BKDS(L,NY,NX)*(CDPTH(L,NY,NX)-CDPTH(L-1,NY,NX)))
      CSAND(L,NY,NX)=CSAND(L,NY,NX)
     2*1.0E-03*AMAX1(0.0,(1.0-CORGCX/0.5E+06))
      CSILT(L,NY,NX)=CSILT(L,NY,NX)
     2*1.0E-03*AMAX1(0.0,(1.0-CORGCX/0.5E+06))
      CCLAY(L,NY,NX)=CCLAY(L,NY,NX)
     2*1.0E-03*AMAX1(0.0,(1.0-CORGCX/0.5E+06))
      CEC(L,NY,NX)=CEC(L,NY,NX)*10.0
      AEC(L,NY,NX)=AEC(L,NY,NX)*10.0
      CNH4(L,NY,NX)=CNH4(L,NY,NX)/14.0
      CNO3(L,NY,NX)=CNO3(L,NY,NX)/14.0
      CPO4(L,NY,NX)=CPO4(L,NY,NX)/31.0
      CAL(L,NY,NX)=CAL(L,NY,NX)/27.0
      CFE(L,NY,NX)=CFE(L,NY,NX)/56.0
      CCA(L,NY,NX)=CCA(L,NY,NX)/40.0
      CMG(L,NY,NX)=CMG(L,NY,NX)/24.3
      CNA(L,NY,NX)=CNA(L,NY,NX)/23.0
      CKA(L,NY,NX)=CKA(L,NY,NX)/39.1
      CSO4(L,NY,NX)=CSO4(L,NY,NX)/32.0
      CCL(L,NY,NX)=CCL(L,NY,NX)/35.5
      CALPO(L,NY,NX)=CALPO(L,NY,NX)/31.0
      CFEPO(L,NY,NX)=CFEPO(L,NY,NX)/31.0
      CCAPD(L,NY,NX)=CCAPD(L,NY,NX)/31.0
      CCAPH(L,NY,NX)=CCAPH(L,NY,NX)/(31.0*3.0)
      CALOH(L,NY,NX)=CALOH(L,NY,NX)/27.0
      CFEOH(L,NY,NX)=CFEOH(L,NY,NX)/56.0
      CCACO(L,NY,NX)=CCACO(L,NY,NX)/40.0
      CCASO(L,NY,NX)=CCASO(L,NY,NX)/40.0
      IF(FC(L,NY,NX).LT.0.0)THEN
      ISOIL(1,L,NY,NX)=1
      PSIFC(NY,NX)=-0.033
      ELSE
      ISOIL(1,L,NY,NX)=0
      ENDIF
      IF(WP(L,NY,NX).LT.0.0)THEN
      ISOIL(2,L,NY,NX)=1
      PSIWP(NY,NX)=-1.5
      ELSE
      ISOIL(2,L,NY,NX)=0
      ENDIF
      IF(SCNV(L,NY,NX).LT.0.0)THEN
      ISOIL(3,L,NY,NX)=1
      ELSE
      ISOIL(3,L,NY,NX)=0
      ENDIF
      IF(SCNH(L,NY,NX).LT.0.0)THEN
      ISOIL(4,L,NY,NX)=1
      ELSE
      ISOIL(4,L,NY,NX)=0
      ENDIF
C     IF(BKDS(L,NY,NX).EQ.0.0)THEN
C     FC(L,NY,NX)=1.0
C     WP(L,NY,NX)=1.0
C     ISOIL(1,L,NY,NX)=0
C     ISOIL(2,L,NY,NX)=0
C     CCLAY(L,NY,NX)=0.0
C     ENDIF
C
C     BIOCHEMISTRY 130:117-131
C
      IF(CORGN(L,NY,NX).LT.0.0)THEN
      CORGN(L,NY,NX)=AMIN1(0.125*CORGC(L,NY,NX)
     2,8.9E+02*(CORGC(L,NY,NX)/1.0E+04)**0.80)
C     WRITE(*,1111)'CORGN',L,CORGN(L,NY,NX),CORGC(L,NY,NX)
      ENDIF
      IF(CORGP(L,NY,NX).LT.0.0)THEN
      CORGP(L,NY,NX)=AMIN1(0.0125*CORGC(L,NY,NX)
     2,1.2E+02*(CORGC(L,NY,NX)/1.0E+04)**0.52)
C     WRITE(*,1111)'CORGP',L,CORGP(L,NY,NX),CORGC(L,NY,NX)
      ENDIF
      IF(CEC(L,NY,NX).LT.0.0)THEN
      CEC(L,NY,NX)=10.0*(200.0*2.0*CORGC(L,NY,NX)/1.0E+06
     2+80.0*CCLAY(L,NY,NX)+20.0*CSILT(L,NY,NX)
     3+5.0*CSAND(L,NY,NX))
C     WRITE(*,1111)'CEC',L,CEC(L,NY,NX),CORGC(L,NY,NX)
C    2,CCLAY(L,NY,NX),CSILT(L,NY,NX),CSAND(L,NY,NX)
1111  FORMAT(A8,1I4,12E12.4)
      ENDIF
28    CONTINUE
9990  CONTINUE
9995  CONTINUE
      CLOSE(9)
      GO TO 50
20    CONTINUE
      CLOSE(7)
      DO 9975 NX=NHW,NHE
      NL(NVS+1,NX)=NL(NVS,NX)
C     WRITE(*,2223)'NHE',NX,NHW,NHE,NVS,NL(NVS,NX)
9975  CONTINUE
      DO 9970 NY=NVN,NVS
      NL(NY,NHE+1)=NL(NY,NHE)
C     WRITE(*,2223)'NVS',NY,NVN,NVS,NHE,NL(NY,NHE)
2223  FORMAT(A8,6I4)
9970  CONTINUE
      NL(NVS+1,NHE+1)=NL(NVS,NHE)
      IOLD=0
      RETURN
      END


