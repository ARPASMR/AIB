!+ Calcolo indici FWI su griglia regolare a partire da campi meteo 
!###############################################################################
PROGRAM fwigrid_ana
!###############################################################################
!------------------------------------------------------------------------------

!! NB bisogna imporre che la prima ora del ciclo orario it=1 sia l'ora 13 e che l'ultima sia 12
! bisogna mettere un controllo che interrompa il run se questo non accade!!
! NB2 I file sPREFWILOG ecc non servono piu, vero?

! !  i dati meteo interpolati in input al calcolo di FWI sono negli array:
!REAL    :: rvTEMP_ANA_GRID(iMAX_X_DIM,iMAX_Y_DIM)
!REAL    :: rvTEMP_IDI_GRID(iMAX_X_DIM,iMAX_Y_DIM)
!REAL    :: rvRELH_ANA_GRID(iMAX_X_DIM,iMAX_Y_DIM)
!REAL    :: rvRELH_IDI_GRID(iMAX_X_DIM,iMAX_Y_DIM)
!REAL    :: rvVELU_ANA_GRID(iMAX_X_DIM,iMAX_Y_DIM)
!REAL    :: rvVELU_IDI_GRID(iMAX_X_DIM,iMAX_Y_DIM)
!REAL    :: rvVELV_ANA_GRID(iMAX_X_DIM,iMAX_Y_DIM)
!REAL    :: rvVELV_IDI_GRID(iMAX_X_DIM,iMAX_Y_DIM)
!REAL    :: rvPIOG24_ANA_GRID(iMAX_X_DIM,iMAX_Y_DIM)
!REAL    :: rvPIOG24_IDId_GRID(iMAX_X_DIM,iMAX_Y_DIM)
!REAL    :: rvPIOG24_IDIw_GRID(iMAX_X_DIM,iMAX_Y_DIM)
!   la dimensione vera degli array (ovvero con dati significativi) e': (iNX,iNY)
! un buon valore per punti griglia con stazioni lontane e': IDI<=0.45
!   Per ora il programma legge i campi per ciascun istante temporale e poi ti passa
! la palla ma solo se l'istante temporale corrisponde alle 12 UTC+1, altrimenti
! passa all'iterazione successiva.
!   Nota sulla pioggia: quando il programma arriva nella tua parte hai gia' le 
! cumulate fatte:
! rvPIOG24_ANA_GRID: pioggia cumulata dalle 13 UTC+1 giorno (D-1)
!                    alle 12 UTC+1 giorno (D)
! rvPIOG24_IDId_GRID: IDI dry "cumulato" 13 UTC+1 giorno (D-1)
!                     alle 12 UTC+1 giorno (D)
! rvPIOG24_IDIw_GRID: IDI dry "cumulato" 13 UTC+1 giorno (D-1)
!                     alle 12 UTC+1 giorno (D)
!
! L'output invece va scritto nell'array 3D:
!  rvFWIindexes(i,j,k)
!   con i=1,...,iNX ; j=1,...,iNY ; k=1,...,6
!  k cicla sui 6 indici che compongono l'FWI
!   
!   Propongo di segnalare il fatto che ci abbiamo messo le mani scrivendo qualcosa
! nella sezione "History" dei commenti.
!------------------------------------------------------------------------------

! Description:
! ============
!  This procedure compute the FWI indexes starting from the meterological 
! fields of hourly averaged temperature, relative humidity, wind intensity and
! hourly cumulated precipitation. Furthermore, the procedure needs the 
! orography of the spatial domain.
!
! Method:
! =======
!
! Algorithm:
! ======================
! +- [0] Set up
! |   [0.1] pointers initialization
! |   [0.2] variables initialization
! +- [1] Read command line arguments and Init file
! |   [1.1] Read Initialization File
! |   [1.2] Check input arguments consistency
! +- [2] Read CTL input GRIDDED file with geographical info and set GRID
! +- [3] Read DAT input GRIDDED orography file
! +- [4] Read CTL input GRIDDED file with TEMPERATURE FIELDS
! +- [5] Read CTL input GRIDDED file with RELATIVE HUMIDITY FIELDS
! +- [6] Read CTL input GRIDDED file with WIND FIELDS
! +- [7] Read CTL input GRIDDED file with RAIN FIELDS
! +- [8] Elaborations
! |     [8.1] open input DAT file
! |  +- [8.2] Very Main cycle
! |  |   [8.2.1] Read temperature data
! |  |   [8.2.2] Read relative humidity data
! |  |   [8.2.3] Read wind data
! |  |   [8.2.4] Read rain data
! |  |   [8.2.5] Calculate FWI indexes (values and classes) at all grid points -
! |  |           Manage IDI and Snowcover matrices
! |  |   [8.2.6] Re-initialize matrices with variables related to 24h cumulated 
! |  |          precipitation field
! |  +-  [8.2.7] Write Output
! |    [8.3] close files with timesteps information
! +- [9] Tidy up and exit
!
! Files Format:
! =============
!  Input meteorological fields:
!   All the files containing the input meteorological fields are in GrADS format
!   (www.grads.iges.org)
!  Output:
!
!  Log files:
!
! History:
! ========
!  date        comment
!  ----        -------
!  10/03/08     CR. Prima bozza codice
!  10/03/08     CR. Seconda bozza codice
!  12/12/08     CR. Terza bozza codice
!  21/08/09     RG. Inserimento\adattamento sezione di calcolo FWI
!  XX/YY/10     RG. versione 1.0 
!  21/03/11     DG/RG.versione 2.0 modifica sezione di overwintering (distinzione innevamento stabile-temporaneo,
!               inizializzazione dopo n giorni dallo scioglimento)
!  25/08/11     RG.versione 2.1 introduce maschera "fuori-Lombardia" e uso "punti_nometeo" per file di scioglimento e innevamento. Risolve baco su incremento isciolgo (valori=5)
!  17/06/20		RG/LP versione 3.01: modificata la 2.1 per essere compilata con Gfortran e non con Intel Compiler: corretti errori di sintassi (uso $ nei nomi, internal write, ecc..)
!                                   nessuna modifica all'algoritmo di calcolo. Deriva dalla 3.0 prodotta da LP, con alcune piccole modifiche sugli internal write nella parte finale.
!  01/07/20		RG versione 4.0: modificata la 3.01 per non utilizzare i dati di input meteo dei file GRADS (eliminata la parte di Lussana)
!                                   nessuna modifica all'algoritmo di calcolo.
!
!===============================================================================
!USE GrADSlib_new
USE CALENDAR
IMPLICIT NONE

INTEGER, parameter :: iMAX_X_DIM=200
INTEGER, parameter :: iMAX_Y_DIM=200
INTEGER, parameter :: NPUNTIMAX=30
REAL,    parameter :: rUNDEF=-9999.
REAL,    parameter :: rUNDEF_FWI=-9999.
REAL,    parameter :: rSNOWCODE=-7557.

! N.B. i valori indefiniti per le variabili meteo negli array rvTEMP_ANA_GRID(iMAX_X_DIM,iMAX_Y_DIM) ecc ecc
!      sono invece assegnati dalle variabili rUNDEF_TEMP ecc ecc, (normalmente sono -9999.0) 
!      (richiamati dalle subroutines ReadDAT_GRD e ReadCTL_GRD)

!--------------------
! Input/Output files
!--------------------
!!CHARACTER(256) :: sCTL_TEMP, sDAT_TEMP
!!CHARACTER(256) :: sCTL_RELH, sDAT_RELH
!!CHARACTER(256) :: sCTL_WIND, sDAT_WIND
!!CHARACTER(256) :: sCTL_PIOG, sDAT_PIOG
!!CHARACTER(256) :: sCTL_ORO, sDAT_ORO
!!CHARACTER(256) :: sCTL_FWI, sDAT_FWI
!!CHARACTER(256) :: sPRECILOG
!!CHARACTER(256) :: sERRORLOG
!!CHARACTER(256) :: sPREFWILOG
!!CHARACTER(256) :: sFWIMETEO
!!CHARACTER(256) :: sPROGLOG
CHARACTER(256) :: sFILEINI
!!CHARACTER(256) :: sTITLE_FWI

! RG variables   ********************************

INTEGER       ::  ik,j,m,ind,imo,lmon(12),isciolgo(iMAX_X_DIM,iMAX_Y_DIM),inorm,idef,kop
INTEGER       ::  iSNOWold(iMAX_X_DIM,iMAX_Y_DIM),iSNOWtod(iMAX_X_DIM,iMAX_Y_DIM)
INTEGER       ::  iFILO(6),iFILOC(6),iFILIT(3),iFILI(3),iFILOT(3),IFILINTE(10)
INTEGER       ::  iditot(iMAX_X_DIM,iMAX_Y_DIM),iUNDEF,isalta,ir,ic,ll,npunti
INTEGER       ::  clamc,clafm,cladm,cladc,clais,clabu,clafw,clads,iNODATA
INTEGER       ::  iYYYY2,iMMM2,iDD2,iHH2,iDDp,iMMMp,iYYYYp,iDDu,iMMMu,iYYYYu
INTEGER       ::  iCOL,iRIG,iCOLok,iRIGok,id,ilomb(iMAX_X_DIM,iMAX_Y_DIM)
INTEGER       ::  coord(2,NPUNTIMAX)
INTEGER       ::  isnowper(iMAX_X_DIM,iMAX_Y_DIM),isnowper_lenght,istdby
CHARACTER     ::  infmt*30,inpath*70,outpath*70,sYYYY*4
CHARACTER(2)  ::  ihr,ida,imo1,ihri,idai,imoi,sMMM,sDD
CHARACTER     ::  dum*2,giorno*8,inizio*8,ieri*8,oggi*8,sTEMP*12,iyr*4,iyri*4, asdomar*100
CHARACTER(70) ::  sPATH0,sPATH1,sPATH2,sPATH3,sPATHFILEini
CHARACTER(30) ::  sFILO(6),sFILOC(6), sFILIT(3), sFILINTE(10),sPREFI(10)
CHARACTER(30) ::  sPRE_TEMP,sPRE_TEMP_IDI,sPRE_RH,sPRE_RH_IDI,sPRE_VELU,sPRE_VELV  
CHARACTER(30) ::  sPRE_VEL_IDI,sPRE_PR,sPRE_PR_IDID,sPRE_PR_IDIW,sSUB
REAL(8)       ::  fo,po,dot,ffm,dmc,dc
REAL(8)       ::  wmo,wmi,ra,ed,z,x,wm,ew,rk,rw,b,wmr,pr
REAL(8)       ::  pe,smi,dr,si,mc,fm,sf,bui,p,cc,bb,fwi,sl,dsr
REAL          ::  el(12),fl(12),w,t,h,r,fod,pod,dotd,tok,keff
REAL(8)       ::  rvFWIana(iMAX_X_DIM,iMAX_Y_DIM,3)  ! invertito indici x e y RG2020, idem sotto
REAL          ::  ws(iMAX_X_DIM,iMAX_Y_DIM)
REAL          ::  fmcl(12,5),dmcl(12,5),dcl(12,5),iscl(12,5),bucl(12,5),fwcl(12,5)
REAL          ::  mcl(12,5),dscl(12,5),idisoglia(4),idi(4),rUNDEF_SNOW
REAL          ::  ind_tmp(iMAX_X_DIM,iMAX_Y_DIM,3),raincum(iMAX_X_DIM,iMAX_Y_DIM)
REAL          ::  rXLCORN,rYLCORN,rCELLSIZE,rXLCORNok,rYLCORNok,rCELLSIZEok,rNODATA
REAL          ::  idipr_s1,idipr_s2,pr_s1,pr_s2,maxprec

! LMON numero giorni nei mesi
! EL = fattori giornalieri per DMC
! FL = fattori giornalieri per DC

DATA lmon /31,28,31,30,31,30,31,31,30,31,30,31/
DATA el /6.5,7.5,9.0,12.8,13.9,13.9,12.4,10.9,9.4,8.0,7.0,6.0/
DATA fl /-1.6,-1.6,-1.6,0.9,3.8,5.8,6.4,5.0,2.4,0.4,-1.6,-1.6/

DATA sFILIT /"ffmc_tmp_","dmc_tmp_","dc_tmp_"/                          ! file grid con indici temporanei per overwintering
DATA sFILO /"ffmc_","dmc_","dc_","isi_","bui_","fwi_"/                  ! file grid con indici numerici
DATA sFILOC /"ffmc_c_","dmc_c_","dc_c_","isi_c_","bui_c_","fwi_c_"/     ! file grid con indici in classi

DATA iFILI / 71,72,73/
DATA iFILIT / 91,92,93/
DATA iFILOT / 102,103,104/
DATA iFILO / 81,82,83,84,85,86/
DATA iFILOC / 61,62,63,64,65,66/
DATA iFILINTE / 161,162,163,164,165,166,167,168,169,170/

! ***************************************************

!-----------
! CTL files
!-----------

REAL    :: rUNDEF_TEMP, rUNDEF_RELH, rUNDEF_WIND, rUNDEF_PIOG
INTEGER :: iNTIM, iTINC, iHH, iMM, iDD, iMMM, iYYYY
INTEGER :: iNTIM_FWI, iTINC_FWI, iHH_FWI, iMM_FWI, iDD_FWI, iMMM_FWI, iYYYY_FWI
INTEGER :: iNTIMTMP, iTINCTMP, iHHTMP, iMMTMP, iDDTMP, iMMMTMP, iYYYYTMP
INTEGER :: iNVARS_FWI
!!INTEGER :: iNVARS_FWI, iNVARS_TMP, iNVARS_DQCPAR
!!INTEGER :: iNVARS_LD_TEMP, iNVARS_SFC_TEMP, iNVARS_TEMP
!!INTEGER :: iNVARS_LD_RELH, iNVARS_SFC_RELH, iNVARS_RELH
!!INTEGER :: iNVARS_LD_WIND, iNVARS_SFC_WIND, iNVARS_WIND
!!INTEGER :: iNVARS_LD_PIOG, iNVARS_SFC_PIOG, iNVARS_PIOG
!!INTEGER :: iNVARS_LD_TMP, iNVARS_SFC_TMP
!!INTEGER :: iNSTAT_TMP, iNSTAT_SFC_TMP, iNSTAT_LD_TMP
!!LOGICAL :: inc_mm, inc_mmTMP
!!LOGICAL :: inc_hr, inc_hrTMP
!!LOGICAL :: inc_dy, inc_dyTMP
!!LOGICAL :: inc_mo, inc_moTMP
!!LOGICAL :: inc_yr, inc_yrTMP
! Arrays arguments with intent(out)
!!CHARACTER(12),pointer        :: svABRV_TMP(:)
!!CHARACTER(40),pointer        :: svDSCR_TMP(:)
!!CHARACTER(12),pointer        :: svABRV_FWI(:)
!!CHARACTER(40),pointer        :: svDSCR_FWI(:)
! Etichette dei livelli verticali 1D
!!INTEGER, pointer             :: ivVLEVS_TMP(:)
!!REAL, pointer                :: rvZLEVS_TMP(:)
! Initialize
!!DATA svABRV_TMP, svDSCR_TMP, ivVLEVS_TMP, rvZLEVS_TMP / 4*NULL() /
!!DATA svABRV_FWI, svDSCR_FWI / 2*NULL() /
!-----------
! DAT files
!-----------
! dati superficie (levs=0) 3D(i,j,vs) i=[1,iNX];j=[1,iNY];vs=[1,iNVARS_SFC]
!!REAL,    pointer      :: rvDATA_SFC_ORO(:,:,:)
!!REAL,    pointer      :: rvDATA_SFC_TMP(:,:,:)
REAL(8),    pointer   :: rvFWIindexes(:,:,:)
INTEGER,    pointer   :: iFWIind_class(:,:,:)  ! aggiunto da RG
! pi livelli (levs/=0) 4D(i,j,k,vl) i=[1,iNX];j=[1,iNY];k=[1,iNZ];vl=[1,iNVARS_LD]
!!REAL,    pointer      :: rvDATA_TMP(:,:,:,:)
! Initialize
DATA rvFWIindexes / NULL() /
!!DATA rvDATA_SFC_ORO, rvDATA_SFC_TMP, rvFWIindexes / 3*NULL() /
!!DATA rvDATA_TMP / NULL() /
DATA iFWIind_class / NULL() /
!-------
! grid
!-------
INTEGER :: iNX, iNY
!!INTEGER :: iNX, iNY, iNZ
!!INTEGER :: iNXTMP, iNYTMP, iNZTMP
!!REAL(8) :: dXstart, dYstart
!!REAL(8) :: dXstartTMP, dYstartTMP
!!REAL(8) :: dDX, dDY
!!REAL(8) :: dDXTMP, dDYTMP
!!REAL    :: rZstart, rDZ
!!REAL    :: rZstartTMP, rDZTMP
!!REAL(8) :: dXMIN, dXMAX, dYMIN, dYMAX
!-------------------------------------------------------------
! GrADS Abreviations in CTL files and correspondent positions
!-------------------------------------------------------------
!!CHARACTER(8) :: sTEMP_IDI_ABRV
!!CHARACTER(8) :: sTEMP_ANA_ABRV
!!CHARACTER(8) :: sRELH_IDI_ABRV
!!CHARACTER(8) :: sRELH_ANA_ABRV
!!CHARACTER(8) :: sVELU_IDI_ABRV
!!CHARACTER(8) :: sVELU_ANA_ABRV
!!CHARACTER(8) :: sVELV_IDI_ABRV
!!CHARACTER(8) :: sVELV_ANA_ABRV
!!CHARACTER(8) :: sPIOG_IDId_ABRV
!!CHARACTER(8) :: sPIOG_IDIw_ABRV
!!CHARACTER(8) :: sPIOG_ANA_ABRV
!!CHARACTER(8) :: sORO_TOPO_ABRV
!!INTEGER :: iTEMP_IDI_pos, iTEMP_ANA_pos
!!INTEGER :: iRELH_IDI_pos, iRELH_ANA_pos
!!INTEGER :: iVELU_IDI_pos, iVELU_ANA_pos
!!INTEGER :: iVELV_IDI_pos, iVELV_ANA_pos
!!INTEGER :: iPIOG_IDId_pos, iPIOG_IDIw_pos, iPIOG_ANA_pos
!!INTEGER :: iTOPO_ORO_pos
!-------------
! temperature 
!-------------
REAL    :: rvVALINT(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvTEMP_ANA_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvTEMP_IDI_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvRELH_ANA_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvRELH_IDI_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvVELU_ANA_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvVELU_IDI_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvVELV_ANA_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvVELV_IDI_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvPIOG_ANA_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvPIOG24_ANA_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvPIOG_IDId_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvPIOG_IDIw_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvPIOG24_IDId_GRID(iMAX_X_DIM,iMAX_Y_DIM)
REAL    :: rvPIOG24_IDIw_GRID(iMAX_X_DIM,iMAX_Y_DIM)
!------
! aux
!------
CHARACTER(255) :: sBuffer
!!CHARACTER(1) :: ANS
!!INTEGER :: iOKflag
INTEGER :: it, s, im, ii, jj, kk, i
!!LOGICAL :: lOKflag
!!INTEGER :: iDebug
LOGICAL :: lExt
INTEGER :: iRetCode
INTEGER :: iTIME, iTIMEINI, iYYYY1, iMMM1, iDD1, iHH1, iMM1, iSS1
!!REAL :: rAUXX
!===============================================================================
! NAMELIST INPUT
NAMELIST /INPUT/ sPATH0, sPATH1, sPATH2, sPATH3,                 &
                 sPATHFILEini, sPRE_TEMP,                        &
                 sPRE_TEMP_IDI, sPRE_RH, sPRE_RH_IDI,            &
                 sPRE_VELU, sPRE_VELV,                           &
                 sPRE_VEL_IDI, sPRE_PR, sPRE_PR_IDID,            &
                 sPRE_PR_IDIW, sSUB                              
 
!-------------------------------------------------------------------------------
!===============================================================================
! [0] Set up
!===============================================================================
! [0.1] pointers initialization
!!  sTITLE_FWI='FWI indexes (fwigrid.f90)'
 iNVARS_FWI=6
 iNX=174  !! corrisponde a ir
 iNY=177  !! corrisponde a ic
!!  iTINC_FWI=1
!!  ALLOCATE( svABRV_FWI(iNVARS_FWI), svDSCR_FWI(iNVARS_FWI), &
!!              STAT=iRetCode )
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: Error in dynamic allocation memory operation for arrays svABRV_FWI svDSCR_FWI ivVLEVS_FWI!'
!!    STOP 1
!!  ENDIF
!!  svABRV_FWI(1)  = 'i1'
!!  svDSCR_FWI(1)  = 'indice 1'
!!  svABRV_FWI(2)  = 'i2'
!!  svDSCR_FWI(2)  = 'indice 2'
!!  svABRV_FWI(3)  = 'i3'
!! svDSCR_FWI(3)  = 'indice 3'
!!  svABRV_FWI(4)  = 'i4'
!!  svDSCR_FWI(4)  = 'indice 4'
!!  svABRV_FWI(5)  = 'i5'
!!  svDSCR_FWI(5)  = 'indice 5'
!!  svABRV_FWI(6)  = 'i6'
!!  svDSCR_FWI(6)  = 'indice 6'
! [0.2] variables initialization
!!  iTEMP_IDI_pos = -1
!!  iTEMP_ANA_pos = -1
!!  iRELH_IDI_pos = -1
!!  iRELH_ANA_pos = -1
!!  iVELU_IDI_pos = -1
!!  iVELU_ANA_pos = -1
!!  iVELV_IDI_pos = -1
!!  iVELV_ANA_pos = -1
!!  iPIOG_IDId_pos = -1
!!  iPIOG_IDIw_pos = -1
!!  iPIOG_ANA_pos = -1
!!  iTOPO_ORO_pos = -1
  rvTEMP_ANA_GRID = rUNDEF
  rvTEMP_IDI_GRID = rUNDEF
  rvRELH_ANA_GRID = rUNDEF
  rvRELH_IDI_GRID = rUNDEF
  rvVELV_ANA_GRID = rUNDEF
  rvVELV_IDI_GRID = rUNDEF
  rvVELU_ANA_GRID = rUNDEF
  rvVELU_IDI_GRID = rUNDEF
  rvPIOG_ANA_GRID = rUNDEF
  rvPIOG24_ANA_GRID = 0.
  rvPIOG_IDId_GRID = rUNDEF
  rvPIOG_IDIw_GRID = rUNDEF
  rvPIOG24_IDId_GRID = 0.
  rvPIOG24_IDIw_GRID = 0.
!!  iDebug=0

! rg: percorso della directory di lavoro con "/" finale (quella contenente almeno file ini e log, eventualmente anche l'eseguibile fwigrid)
!! RG di seguito
!!  sPATH0 = "/home/meteo/programmi/fwi_grid/"
!! RG precedente  
  iUNDEF=-9999
  rUNDEF_SNOW=-44
  isalta=0
  rvFWIana=rUNDEF_FWI
  ws=rUNDEF
  isciolgo=0
  rUNDEF_TEMP=rUNDEF
  rUNDEF_RELH=rUNDEF
  rUNDEF_WIND=rUNDEF
  rUNDEF_PIOG=rUNDEF

!===============================================================================
! [1] Read command line arguments and Init file
!===============================================================================
  IF (IARGC()/= 4) THEN
    PRINT *,'<fwigrid> version 1.0 usage:'
    PRINT *,''
    PRINT *,' $ fwigrid <initialization file>'
    PRINT *,''
    PRINT *,'initialization file records:...'
    STOP 1
  ENDIF
  CALL GETARG(1,sFILEINI)
  sFILEINI=TRIM(ADJUSTL(sFILEINI))
  INQUIRE(FILE=TRIM(sFILEINI), EXIST=lExt)
  IF (.not.(lExt)) THEN
    PRINT *,'fwigrid: file ',TRIM(sFILEINI),' not found!'
    STOP 1
  ENDIF
!-------------------------------------------------------------------------------
!! RG cambia il file nml in modo da  dargli i file di izializzazione di RG. Verifca se puoi eliminare tutte le righe del vercchio nml
! [1.1] Read Initialization File   (fwigrid2020.nml nella directory fwi_grid)
  OPEN(10,FILE=TRIM(sFILEINI),IOSTAT=iRetCode)
  IF (iRetCode/=0) THEN
    PRINT *,'fwigrid2020: error opening file <',TRIM(sFILEINI),'>'
    STOP 1
  ENDIF
  READ(10,NML=INPUT)
  CLOSE(10)
  sPATH0=TRIM(ADJUSTL(sPATH0))
  sPATH1=TRIM(ADJUSTL(sPATH1))
  sPATH2=TRIM(ADJUSTL(sPATH2))
  sPATH3=TRIM(ADJUSTL(sPATH3))
  sPATHFILEini=TRIM(ADJUSTL(sPATHFILEini))  
  sPRE_TEMP=TRIM(ADJUSTL(sPRE_TEMP))
  sPRE_TEMP_IDI=TRIM(ADJUSTL(sPRE_TEMP_IDI))
  sPRE_RH=TRIM(ADJUSTL(sPRE_RH))
  sPRE_RH_IDI=TRIM(ADJUSTL(sPRE_RH_IDI))
  sPRE_VELU=TRIM(ADJUSTL(sPRE_VELU))  
  sPRE_VELV=TRIM(ADJUSTL(sPRE_VELV))
  sPRE_VEL_IDI=TRIM(ADJUSTL(sPRE_VEL_IDI))
  sPRE_PR=TRIM(ADJUSTL(sPRE_PR))
  sPRE_PR_IDID=TRIM(ADJUSTL(sPRE_PR_IDID))
  sPRE_PR_IDIW=TRIM(ADJUSTL(sPRE_PR_IDIW))  
  sSUB=TRIM(ADJUSTL(sSUB))  

    
  !!sCTL_TEMP=TRIM(ADJUSTL(sCTL_TEMP))
  !!sCTL_RELH=TRIM(ADJUSTL(sCTL_RELH))
  !!sCTL_WIND=TRIM(ADJUSTL(sCTL_WIND))
  !!sCTL_PIOG=TRIM(ADJUSTL(sCTL_PIOG))
  !!sCTL_FWI=TRIM(ADJUSTL(sCTL_FWI))
  !!sTEMP_IDI_ABRV=TRIM(ADJUSTL(sTEMP_IDI_ABRV))
  !!sTEMP_ANA_ABRV=TRIM(ADJUSTL(sTEMP_ANA_ABRV))
  !!sRELH_IDI_ABRV=TRIM(ADJUSTL(sRELH_IDI_ABRV))
  !!sRELH_ANA_ABRV=TRIM(ADJUSTL(sRELH_ANA_ABRV))
  !!sVELU_IDI_ABRV=TRIM(ADJUSTL(sVELU_IDI_ABRV))
  !!sVELU_ANA_ABRV=TRIM(ADJUSTL(sVELU_ANA_ABRV))
  !!sVELV_IDI_ABRV=TRIM(ADJUSTL(sVELV_IDI_ABRV))
  !!sVELV_ANA_ABRV=TRIM(ADJUSTL(sVELV_ANA_ABRV))
  !!sPIOG_IDId_ABRV=TRIM(ADJUSTL(sPIOG_IDId_ABRV))
  !!sPIOG_IDIw_ABRV=TRIM(ADJUSTL(sPIOG_IDIw_ABRV))
  !!sPIOG_ANA_ABRV=TRIM(ADJUSTL(sPIOG_ANA_ABRV))
  !!sORO_TOPO_ABRV=TRIM(ADJUSTL(sORO_TOPO_ABRV))
  !!sPRECILOG=TRIM(ADJUSTL(sPRECILOG))
  !!sERRORLOG=TRIM(ADJUSTL(sERRORLOG))
  !!sPREFWILOG=TRIM(ADJUSTL(sPREFWILOG))    
  !!sFWIMETEO=TRIM(ADJUSTL(sFWIMETEO))
  !!sPROGLOG=TRIM(ADJUSTL(sPROGLOG))
  
  !!sPATH_FILE_INI='ini/fwiscale.ini',

    
! DEB
!!PRINT *,'         sCTL_ORO=',TRIM(ADJUSTL(sCTL_ORO))
!!PRINT *,'        sCTL_TEMP=',TRIM(ADJUSTL(sCTL_TEMP))
!!PRINT *,'        sCTL_RELH=',TRIM(ADJUSTL(sCTL_RELH))
!!PRINT *,'        sCTL_WIND=',TRIM(ADJUSTL(sCTL_WIND))
!!PRINT *,'        sCTL_PIOG=',TRIM(ADJUSTL(sCTL_PIOG))
!!PRINT *,'         sCTL_FWI=',TRIM(ADJUSTL(sCTL_FWI))
!!PRINT *,'   sTEMP_IDI_ABRV=',TRIM(ADJUSTL(sTEMP_IDI_ABRV))
!!PRINT *,'   sTEMP_ANA_ABRV=',TRIM(ADJUSTL(sTEMP_ANA_ABRV))
!!PRINT *,'   sRELH_IDI_ABRV=',TRIM(ADJUSTL(sRELH_IDI_ABRV))
!!PRINT *,'   sRELH_ANA_ABRV=',TRIM(ADJUSTL(sRELH_ANA_ABRV))
!!PRINT *,'   sVELU_IDI_ABRV=',TRIM(ADJUSTL(sVELU_IDI_ABRV))
!!PRINT *,'   sVELU_ANA_ABRV=',TRIM(ADJUSTL(sVELU_ANA_ABRV))
!!PRINT *,'   sVELV_IDI_ABRV=',TRIM(ADJUSTL(sVELV_IDI_ABRV))
!!PRINT *,'   sVELV_ANA_ABRV=',TRIM(ADJUSTL(sVELV_ANA_ABRV))
!!PRINT *,'  sPIOG_IDId_ABRV=',TRIM(ADJUSTL(sPIOG_IDId_ABRV))
!!PRINT *,'  sPIOG_IDIw_ABRV=',TRIM(ADJUSTL(sPIOG_IDIw_ABRV))
!!PRINT *,'   sPIOG_ANA_ABRV=',TRIM(ADJUSTL(sPIOG_ANA_ABRV))
!!PRINT *,'   sORO_TOPO_ABRV=',TRIM(ADJUSTL(sORO_TOPO_ABRV))
!!PRINT *,'        sPRECILOG=',TRIM(ADJUSTL(sPRECILOG))
!!PRINT *,'        sERRORLOG=',TRIM(ADJUSTL(sERRORLOG))
!!PRINT *,'       sPREFWILOG=',TRIM(ADJUSTL(sPREFWILOG))   
!!PRINT *,'        sFWIMETEO=',TRIM(ADJUSTL(sFWIMETEO))
!!PRINT *,'         sPROGLOG=',TRIM(ADJUSTL(sPROGLOG))
! END DEB

!!  Righe seguenti, con !!, commentate RG luglio 2020 *************************************************************

!-------------------------------------------------------------------------------
! [1.2] Check input arguments consistency
!!  INQUIRE(FILE=TRIM(sCTL_ORO), EXIST=lExt)
!!  IF (.not.(lExt)) THEN
!!    PRINT *,'fwigrid: file ',TRIM(sCTL_ORO),' not found!'
!!    STOP 1
!!  ENDIF
!!  INQUIRE(FILE=TRIM(sCTL_TEMP), EXIST=lExt)
!!  IF (.not.(lExt)) THEN
!!    WRITE(6,"(A,A,A)",IOSTAT=iRetCode) 'fwigrid: file ',TRIM(sCTL_TEMP),' not found!'
!!    STOP 1
!!  ENDIF
!!  INQUIRE(FILE=TRIM(sCTL_RELH), EXIST=lExt)
!!  IF (.not.(lExt)) THEN
!!    WRITE(6,"(A,A,A)",IOSTAT=iRetCode) 'fwigrid: file ',TRIM(sCTL_RELH),' not found!'
!!    STOP 1
!!  ENDIF
!!  INQUIRE(FILE=TRIM(sCTL_WIND), EXIST=lExt)
!!  IF (.not.(lExt)) THEN
!!    WRITE(6,"(A,A,A)",IOSTAT=iRetCode) 'fwigrid: file ',TRIM(sCTL_WIND),' not found!'
!!    STOP 1
!!  ENDIF
!!  INQUIRE(FILE=TRIM(sCTL_PIOG), EXIST=lExt)
!!  IF (.not.(lExt)) THEN
!!    WRITE(6,"(A,A,A)",IOSTAT=iRetCode) 'fwigrid: file ',TRIM(sCTL_PIOG),' not found!'
!!    STOP 1
!!  ENDIF
!! CALL NameCTL2DAT( sCTL_FWI, sDAT_FWI, lOKflag)
!!  IF (.not.lOKflag) THEN
!!    PRINT *,'fwigrid: generic error on filename ',TRIM(sCTL_FWI)
!!    STOP 1
!!  ENDIF
!!  OPEN(31,FILE=TRIM(sDAT_FWI),FORM='UNFORMATTED',ACTION='WRITE',IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: error on file ',TRIM(sDAT_FWI)
!!    STOP 1
!!  ENDIF
!!  CLOSE(31)
! LOG INFORMATION
!! WRITE(6,"(A)",IOSTAT=iRetCode) ' <- fwigrid ->'
!!  WRITE(6,"(A)",IOSTAT=iRetCode) ' Fire Weather Index elaborations'
! END LOG 
!  WRITE (6,*) 'ok?'
!  READ (5,'(A1)') ANS
!===============================================================================
! [2] Read CTL input GRIDDED file with geographical info and set GRID
!===============================================================================
! File with orography grid in 1st timestep
!!  CALL ReadCTL_GRD( sCTL_ORO, sDAT_ORO, rUNDEF_ORO,                        &
!!                    iNX, dXstart, dDX,                                     &
!!                    iNY, dYstart, dDY,                                     &
!!                    iNZ, rZstart, rDZ, rvZLEVS_TMP,                        &
!!                    iNTIMTMP, iTINCTMP, iHHTMP, iMMTMP, iDDTMP,            &
!!                    iMMMTMP, iYYYYTMP,                                     &
!!                    iNVARS_TMP, iNVARS_SFC_TMP, iNVARS_LD_TMP,             &
!!                    svABRV_TMP, svDSCR_TMP, ivVLEVS_TMP,                   &
!!                    inc_mmTMP, inc_hrTMP, inc_dyTMP, inc_moTMP, inc_yrTMP, &
!!                    iDebug, lOKflag )
!!  IF (.not.lOKflag) THEN
!!    PRINT *,'fwigrid: Error in ReadCTL_GRD, file CTL = ',TRIM(sCTL_ORO)
!!    STOP 1
!!  ENDIF
!!  dXMIN= dXstart
!!  dXMAX= dXstart +(iNX -1)* dDX
!!  dYMIN= dYstart
!!  dYMAX= dYstart +(iNY -1)* dDY
! set iOROpos_ORO
!!  DO i=1,iNVARS_TMP
!!    IF ( TRIM(ADJUSTL(svABRV_TMP(i))) == TRIM(ADJUSTL(sORO_TOPO_ABRV)) ) iTOPO_ORO_pos = i
!!  ENDDO
!!  IF (iTOPO_ORO_pos < 0) THEN
!!    PRINT *,'fwigrid: cannot find variable with orography data input CTL file '
!!    PRINT *,'           sORO_TOPO_ABRV = ',TRIM(ADJUSTL(sORO_TOPO_ABRV))
!!    PRINT *,'                 sCTL_ORO = ',TRIM(sCTL_ORO)
!!    STOP 1
!!  ENDIF
! LOG
!!    PRINT *,'REGULAR GRID DEFINITION:'
!!  PRINT *,'      # cells along x=',iNX
!! PRINT *,'      # cells along y=',iNY
!!  PRINT *,'            x step(m)=',dDX
!!  PRINT *,'            y step(m)=',dDY
!!  PRINT *,' x min(Gauss-Boaga m)=',dXMIN
!!  PRINT *,' x max(Gauss-Boaga m)=',dXMAX
!!  PRINT *,' y min(Gauss-Boaga m)=',dYMIN
!!  PRINT *,' y max(Gauss-Boaga m)=',dYMAX
!!  PRINT *,''
! END LOG
! Tidy Up
!!  IF ( ASSOCIATED(svABRV_TMP)   )  DEALLOCATE(svABRV_TMP)
!!  IF ( ASSOCIATED(svDSCR_TMP)   )  DEALLOCATE(svDSCR_TMP)
!!  IF ( ASSOCIATED(rvZLEVS_TMP)   )  DEALLOCATE(rvZLEVS_TMP)
!!  NULLIFY(svABRV_TMP)
!!  NULLIFY(svDSCR_TMP)
!!  NULLIFY(rvZLEVS_TMP)
!===============================================================================
! [3] Read DAT input GRIDDED orography file
!===============================================================================
! open DAT input GRIDDED geographical file / read geographical info
!!  OPEN(100,FILE=TRIM(sDAT_ORO),FORM='UNFORMATTED',ACTION='READ',IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: Error in opening file ',TRIM(sDAT_ORO)
!!    STOP 1
!!  ENDIF

!!  CALL ReadDAT_GRD( 100, rvDATA_SFC_ORO, rvDATA_TMP,           &
!!                    iNX, iNY, iNZ,                             &
!!                    iNVARS_SFC_TMP, iNVARS_LD_TMP, iNVARS_TMP, &
!!                    ivVLEVS_TMP, rUNDEF_ORO, lOKflag )

!!  IF (.not.lOKflag) THEN
!!    PRINT *,'fwigrid: Error in ReadDAT_GRD, file DAT = ',TRIM(sDAT_ORO)
!!    STOP 1
!!  ENDIF
!!  CLOSE(100, IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: warning -> failure in closing file ',TRIM(sDAT_ORO)
!!  ENDIF
! Tidy Up
!!  IF ( ASSOCIATED(rvDATA_TMP) ) DEALLOCATE(rvDATA_TMP)
!!  IF ( ASSOCIATED(ivVLEVS_TMP) ) DEALLOCATE(ivVLEVS_TMP)
!!  NULLIFY(rvDATA_TMP)
!!  NULLIFY(ivVLEVS_TMP)
!  WRITE (6,*) 'ok?'
!  READ (5,'(A1)') ANS
!===============================================================================
! [4] Read CTL input GRIDDED file with TEMPERATURE FIELDS 
!===============================================================================
!!  CALL ReadCTL_GRD( sCTL_TEMP, sDAT_TEMP, rUNDEF_TEMP,                     &
!!                    iNXTMP, dXstartTMP, dDXTMP,                            &
!!                    iNYTMP, dYstartTMP, dDYTMP,                            &
!!                    iNZTMP, rZstartTMP, rDZTMP, rvZLEVS_TMP,               &
!!                    iNTIM, iTINC, iHH, iMM, iDD,                           &
!!                    iMMM, iYYYY,                                           &
!!                    iNVARS_TEMP, iNVARS_SFC_TEMP, iNVARS_LD_TEMP,          &
!!                    svABRV_TMP, svDSCR_TMP, ivVLEVS_TMP,                   &
!!                    inc_mmTMP, inc_hrTMP, inc_dyTMP, inc_moTMP, inc_yrTMP, &
!!                    iDebug, lOKflag )

  rvTEMP_ANA_GRID = rUNDEF_TEMP
  rvTEMP_IDI_GRID = rUNDEF_TEMP

!!  IF (.not.lOKflag) THEN
!!    PRINT *,'fwigrid: Error in ReadCTL_GRD, file CTL = ',TRIM(sCTL_TEMP)
!!    STOP 1
!!  ENDIF
! set iTEMP_ANA_pos
!!  DO i=1,iNVARS_TMP
!!    IF ( TRIM(ADJUSTL(svABRV_TMP(i))) == TRIM(ADJUSTL(sTEMP_ANA_ABRV)) ) iTEMP_ANA_pos = i
!!    IF ( TRIM(ADJUSTL(svABRV_TMP(i))) == TRIM(ADJUSTL(sTEMP_IDI_ABRV)) ) iTEMP_IDI_pos = i
!!  ENDDO
!!  IF (iTEMP_ANA_pos < 0) THEN
!!    PRINT *,'fwigrid: cannot find variable "temperature" in input CTL file '
!!   PRINT *,'     sTEMP_ANA_ABRV = ',TRIM(ADJUSTL(sTEMP_ANA_ABRV))
!!    PRINT *,'          sCTL_TEMP = ',TRIM(sCTL_TEMP)
!!    STOP 1
!!  ENDIF
!!  IF (iTEMP_IDI_pos < 0) THEN
!!    PRINT *,'fwigrid: cannot find variable "temperature" in input CTL file '
!!    PRINT *,'     sTEMP_ANA_ABRV = ',TRIM(ADJUSTL(sTEMP_IDI_ABRV))
!!    PRINT *,'          sCTL_TEMP = ',TRIM(sCTL_TEMP)
!!    STOP 1
!!  ENDIF
! DEB
!!  PRINT *,'iTEMP_ANA_pos=',iTEMP_ANA_pos
!!  PRINT *,'iTEMP_IDI_pos=',iTEMP_IDI_pos
! END DEB
! Check grid consistency
!!  IF ( (iNX/=iNXTMP).OR.(dXstartTMP/=dXstart).OR.(dDX/=dDXTMP).OR. &
!!       (iNY/=iNYTMP).OR.(dYstartTMP/=dYstart).OR.(dDY/=dDYTMP) ) THEN
!!    PRINT *,'fwigrid: consistency grid check failed between OROGRAPHY and TEMPERATURE GRD'
!!    STOP 1
!!  ENDIF
! LOG
!!  PRINT *,'fwigrid: Read CTL input GRIDDED file with TEMPERATURE FIELD...ok'
! END LOG
! Tidy Up
!!  IF ( ASSOCIATED(svDSCR_TMP) ) DEALLOCATE(svDSCR_TMP)
!!  IF ( ASSOCIATED(svABRV_TMP) ) DEALLOCATE(svABRV_TMP)
!!  IF ( ASSOCIATED(ivVLEVS_TMP) ) DEALLOCATE(ivVLEVS_TMP)
!!  IF ( ASSOCIATED(rvZLEVS_TMP) ) DEALLOCATE(rvZLEVS_TMP)
!!  NULLIFY(svDSCR_TMP)
!!  NULLIFY(svABRV_TMP)
!!  NULLIFY(ivVLEVS_TMP)
!!  NULLIFY(rvZLEVS_TMP)
!===============================================================================
! [5] Read CTL input GRIDDED file with RELATIVE HUMIDITY FIELDS
!===============================================================================
!!  CALL ReadCTL_GRD( sCTL_RELH, sDAT_RELH, rUNDEF_RELH,                     &
!!                    iNXTMP, dXstartTMP, dDXTMP,                            &
!!                    iNYTMP, dYstartTMP, dDYTMP,                            &
!!                    iNZTMP, rZstartTMP, rDZTMP, rvZLEVS_TMP,               &
!!                    iNTIMTMP, iTINCTMP, iHHTMP, iMMTMP, iDDTMP,            &
!!                    iMMMTMP, iYYYYTMP,                                     &
!!                    iNVARS_RELH, iNVARS_SFC_RELH, iNVARS_LD_RELH,          &
!!                    svABRV_TMP, svDSCR_TMP, ivVLEVS_TMP,                   &
!!                    inc_mmTMP, inc_hrTMP, inc_dyTMP, inc_moTMP, inc_yrTMP, &
!!                    iDebug, lOKflag )

  rvRELH_ANA_GRID = rUNDEF_RELH
  rvRELH_IDI_GRID = rUNDEF_RELH

!!  IF (.not.lOKflag) THEN
!!    PRINT *,'fwigrid: Error in ReadCTL_GRD, file CTL = ',TRIM(sCTL_RELH)
!!    STOP 1
!!  ENDIF
! set iRELH_ANA_pos
!!  DO i=1,iNVARS_TMP
!!    IF ( TRIM(ADJUSTL(svABRV_TMP(i))) == TRIM(ADJUSTL(sRELH_ANA_ABRV)) ) iRELH_ANA_pos = i
!!    IF ( TRIM(ADJUSTL(svABRV_TMP(i))) == TRIM(ADJUSTL(sRELH_IDI_ABRV)) ) iRELH_IDI_pos = i
!!  ENDDO
!!  IF (iRELH_ANA_pos < 0) THEN
!!    PRINT *,'fwigrid: cannot find variable "temperature" in input CTL file '
!!    PRINT *,'     sRELH_ANA_ABRV = ',TRIM(ADJUSTL(sRELH_ANA_ABRV))
!!    PRINT *,'          sCTL_RELH = ',TRIM(sCTL_RELH)
!!    STOP 1
!!  ENDIF
!!  IF (iRELH_IDI_pos < 0) THEN
!!    PRINT *,'fwigrid: cannot find variable "temperature" in input CTL file '
!!    PRINT *,'     sRELH_IDI_ABRV = ',TRIM(ADJUSTL(sRELH_IDI_ABRV))
!!    PRINT *,'          sCTL_RELH = ',TRIM(sCTL_RELH)
!!    STOP 1
!!  ENDIF
! DEB
!!  PRINT *,'iRELH_ANA_pos=',iRELH_ANA_pos
!!  PRINT *,'iRELH_IDI_pos=',iRELH_IDI_pos
! END DEB
! Check time consistency
!!  IF ( (iNTIM/=iNTIMTMP).OR.(iHHTMP/=iHH).OR.(iDDTMP/=iDD).OR.(iMMMTMP/=iMMM).OR.(iYYYYTMP/=iYYYY) ) THEN
!!    PRINT *,'fwigrid: consistency time check failed between TEMPERATURE STN and RELATIVE HUM GRD'
!!    STOP 1
 !! ENDIF
! Check grid consistency
!! IF ( (iNX/=iNXTMP).OR.(dXstartTMP/=dXstart).OR.(dDX/=dDXTMP).OR. &
!!       (iNY/=iNYTMP).OR.(dYstartTMP/=dYstart).OR.(dDY/=dDYTMP) ) THEN
!!    PRINT *,'fwigrid: consistency grid check failed between OROGRAPHY and RELATIVE HUMIDITY GRD'
!!    STOP 1
!!  ENDIF
! LOG
!!  PRINT *,'fwigrid: Read CTL input GRIDDED file with RELATIVE HUMIDITY FIELD...ok'
! END LOG
! Tidy Up
!!  IF ( ASSOCIATED(svDSCR_TMP) ) DEALLOCATE(svDSCR_TMP)
!!  IF ( ASSOCIATED(svABRV_TMP) ) DEALLOCATE(svABRV_TMP)
!!  IF ( ASSOCIATED(ivVLEVS_TMP) ) DEALLOCATE(ivVLEVS_TMP)
!!  IF ( ASSOCIATED(rvZLEVS_TMP) ) DEALLOCATE(rvZLEVS_TMP)
!!  NULLIFY(svDSCR_TMP)
!!  NULLIFY(svABRV_TMP)
!!  NULLIFY(ivVLEVS_TMP)
!!  NULLIFY(rvZLEVS_TMP)
!===============================================================================
! [6] Read CTL input GRIDDED file with WIND FIELDS
!===============================================================================
!!  CALL ReadCTL_GRD( sCTL_WIND, sDAT_WIND, rUNDEF_WIND,                     &
!!                    iNXTMP, dXstartTMP, dDXTMP,                            &
!!                    iNYTMP, dYstartTMP, dDYTMP,                            &
!!                    iNZTMP, rZstartTMP, rDZTMP, rvZLEVS_TMP,               &
!!                    iNTIMTMP, iTINCTMP, iHHTMP, iMMTMP, iDDTMP,            &
!!                    iMMMTMP, iYYYYTMP,                                     &
!!                    iNVARS_WIND, iNVARS_SFC_WIND, iNVARS_LD_WIND,          &
!!                    svABRV_TMP, svDSCR_TMP, ivVLEVS_TMP,                   &
!!                    inc_mmTMP, inc_hrTMP, inc_dyTMP, inc_moTMP, inc_yrTMP, &
!!                    iDebug, lOKflag )

  rvVELV_ANA_GRID = rUNDEF_WIND
  rvVELV_IDI_GRID = rUNDEF_WIND
  rvVELU_ANA_GRID = rUNDEF_WIND
  rvVELU_IDI_GRID = rUNDEF_WIND

!!  IF (.not.lOKflag) THEN
!!    PRINT *,'fwigrid: Error in ReadCTL_GRD, file CTL = ',TRIM(sCTL_WIND)
!!    STOP 1
!!  ENDIF
! set iVELU_ANA_pos/iVELU_ANAs_pos
!!  DO i=1,iNVARS_WIND
!!    IF ( TRIM(ADJUSTL(svABRV_TMP(i))) == TRIM(ADJUSTL(sVELU_ANA_ABRV)) ) iVELU_ANA_pos = i
!!    IF ( TRIM(ADJUSTL(svABRV_TMP(i))) == TRIM(ADJUSTL(sVELV_ANA_ABRV)) ) iVELV_ANA_pos = i
!!    IF ( TRIM(ADJUSTL(svABRV_TMP(i))) == TRIM(ADJUSTL(sVELU_IDI_ABRV)) ) iVELU_IDI_pos = i
!!    IF ( TRIM(ADJUSTL(svABRV_TMP(i))) == TRIM(ADJUSTL(sVELV_IDI_ABRV)) ) iVELV_IDI_pos = i
!!  ENDDO
!!  IF (iVELU_ANA_pos < 0) THEN
!!    PRINT *,'fwigrid: cannot find variable "u wind velocity component" in input CTL file '
!!    PRINT *,'     sVELU_ANA_ABRV = ',TRIM(ADJUSTL(sVELU_ANA_ABRV))
!!    PRINT *,'          sCTL_WIND = ',TRIM(sCTL_WIND)
!!    STOP 1
!!  ENDIF
!!  IF (iVELV_ANA_pos < 0) THEN
!!    PRINT *,'fwigrid: cannot find variable "v wind velocity component" in input CTL file '
!!    PRINT *,'     sVELV_ANA_ABRV = ',TRIM(ADJUSTL(sVELV_ANA_ABRV))
!!    PRINT *,'          sCTL_WIND = ',TRIM(sCTL_WIND)
!!    STOP 1
!!  ENDIF
!!  IF (iVELU_IDI_pos < 0) THEN
!!    PRINT *,'fwigrid: cannot find variable "u wind velocity idi" in input CTL file '
!!    PRINT *,'     sVELU_IDI_ABRV = ',TRIM(ADJUSTL(sVELU_IDI_ABRV))
!!    PRINT *,'          sCTL_WIND = ',TRIM(sCTL_WIND)
!!    STOP 1
!!  ENDIF
!!  IF (iVELV_IDI_pos < 0) THEN
!!    PRINT *,'fwigrid: cannot find variable "v wind velocity idi" in input CTL file '
!!    PRINT *,'     sVELV_IDI_ABRV = ',TRIM(ADJUSTL(sVELV_IDI_ABRV))
!!    PRINT *,'          sCTL_WIND = ',TRIM(sCTL_WIND)
!!    STOP 1
!!  ENDIF
! DEB
!!  PRINT *,'iVELU_ANA_pos=',iVELU_ANA_pos
!!  PRINT *,'iVELV_ANA_pos=',iVELV_ANA_pos
!!  PRINT *,'iVELU_IDI_pos=',iVELU_IDI_pos
!!  PRINT *,'iVELV_IDI_pos=',iVELV_IDI_pos
! END DEB
! Check time consistency
!!  IF ( (iNTIM/=iNTIMTMP).OR.(iHHTMP/=iHH).OR.(iDDTMP/=iDD).OR.(iMMMTMP/=iMMM).OR.(iYYYYTMP/=iYYYY) ) THEN
!!    PRINT *,'fwigrid: consistency time check failed between TEMPERATURE STN and WIND GRD'
!!    STOP 1
!!  ENDIF
! Check grid consistency
!!  IF ( (iNX/=iNXTMP).OR.(dXstartTMP/=dXstart).OR.(dDX/=dDXTMP).OR. &
!!       (iNY/=iNYTMP).OR.(dYstartTMP/=dYstart).OR.(dDY/=dDYTMP) ) THEN
!!    PRINT *,'fwigrid: consistency grid check failed between OROGRAPHY and WIND GRD'
!!    STOP 1
!!  ENDIF
! LOG
!! PRINT *,'fwigrid: Read CTL input GRIDDED file with WIND FIELD...ok'
! END LOG
! Tidy Up
!!  IF ( ASSOCIATED(svDSCR_TMP) ) DEALLOCATE(svDSCR_TMP)
!!  IF ( ASSOCIATED(svABRV_TMP) ) DEALLOCATE(svABRV_TMP)
!!  IF ( ASSOCIATED(ivVLEVS_TMP) ) DEALLOCATE(ivVLEVS_TMP)
!!  IF ( ASSOCIATED(rvZLEVS_TMP) ) DEALLOCATE(rvZLEVS_TMP)
!!  NULLIFY(svDSCR_TMP)
!!  NULLIFY(svABRV_TMP)
!!  NULLIFY(ivVLEVS_TMP)
!!  NULLIFY(rvZLEVS_TMP)
!===============================================================================
! [7] Read CTL input GRIDDED file with RAIN FIELDS
!===============================================================================
!!  CALL ReadCTL_GRD( sCTL_PIOG, sDAT_PIOG, rUNDEF_PIOG,                     &
!!                    iNXTMP, dXstartTMP, dDXTMP,                            &
!!                    iNYTMP, dYstartTMP, dDYTMP,                            &
!!                    iNZTMP, rZstartTMP, rDZTMP, rvZLEVS_TMP,               &
!!                    iNTIMTMP, iTINCTMP, iHHTMP, iMMTMP, iDDTMP,            &
!!                    iMMMTMP, iYYYYTMP,                                     &
!!                    iNVARS_PIOG, iNVARS_SFC_PIOG, iNVARS_LD_PIOG,          &
!!                    svABRV_TMP, svDSCR_TMP, ivVLEVS_TMP,                   &
!!                    inc_mmTMP, inc_hrTMP, inc_dyTMP, inc_moTMP, inc_yrTMP, &
!!                    iDebug, lOKflag )

  rvPIOG_ANA_GRID = rUNDEF_PIOG
  rvPIOG24_ANA_GRID = 0.
  rvPIOG_IDId_GRID = rUNDEF_PIOG
  rvPIOG_IDIw_GRID = rUNDEF_PIOG
  rvPIOG24_IDId_GRID = 0.
  rvPIOG24_IDIw_GRID = 0.

!!  IF (.not.lOKflag) THEN
!!    PRINT *,'fwigrid: Error in ReadCTL_GRD, file CTL = ',TRIM(sCTL_PIOG)
!!    STOP 1
!!  ENDIF
! set iPIOG_ANA_pos
!!  DO i=1,iNVARS_PIOG
!!    IF ( TRIM(ADJUSTL(svABRV_TMP(i))) == TRIM(ADJUSTL(sPIOG_ANA_ABRV)) ) iPIOG_ANA_pos = i
!!    IF ( TRIM(ADJUSTL(svABRV_TMP(i))) == TRIM(ADJUSTL(sPIOG_IDId_ABRV)) ) iPIOG_IDId_pos = i
!!    IF ( TRIM(ADJUSTL(svABRV_TMP(i))) == TRIM(ADJUSTL(sPIOG_IDIw_ABRV)) ) iPIOG_IDIw_pos = i
!!  ENDDO
!!  IF (iPIOG_ANA_pos < 0) THEN
!!    PRINT *,'fwigrid: cannot find variable "rain" in input CTL file '
!!    PRINT *,'     sPIOG_ANA_ABRV = ',TRIM(ADJUSTL(sPIOG_ANA_ABRV))
!!    PRINT *,'          sCTL_PIOG = ',TRIM(sCTL_PIOG)
!!    STOP 1
!!  ENDIF
!!  IF (iPIOG_IDId_pos < 0) THEN
!!    PRINT *,'fwigrid: cannot find variable "rain" in input CTL file '
!!    PRINT *,'     sPIOG_IDId_ABRV = ',TRIM(ADJUSTL(sPIOG_IDId_ABRV))
!!    PRINT *,'          sCTL_PIOG = ',TRIM(sCTL_PIOG)
!!    STOP 1
!!  ENDIF
!!  IF (iPIOG_IDIw_pos < 0) THEN
!!    PRINT *,'fwigrid: cannot find variable "rain" in input CTL file '
!!    PRINT *,'     sPIOG_IDIw_ABRV = ',TRIM(ADJUSTL(sPIOG_IDIw_ABRV))
!!    PRINT *,'          sCTL_PIOG = ',TRIM(sCTL_PIOG)
!!    STOP 1
!!  ENDIF
! DEB
!!  PRINT *,' iPIOG_ANA_pos=',iPIOG_ANA_pos
!!  PRINT *,'iPIOG_IDId_pos=',iPIOG_IDId_pos
!!  PRINT *,'iPIOG_IDIw_pos=',iPIOG_IDIw_pos
! END DEB
! Check time consistency
!!  IF ( (iNTIM/=iNTIMTMP).OR.(iHHTMP/=iHH).OR.(iDDTMP/=iDD).OR.(iMMMTMP/=iMMM).OR.(iYYYYTMP/=iYYYY) ) THEN
!!    PRINT *,'fwigrid: consistency time check failed between TEMPERATURE STN and RAIN GRD'
!!    STOP 1
!!  ENDIF
! Check grid consistency
!!  IF ( (iNX/=iNXTMP).OR.(dXstartTMP/=dXstart).OR.(dDX/=dDXTMP).OR. &
!!       (iNY/=iNYTMP).OR.(dYstartTMP/=dYstart).OR.(dDY/=dDYTMP) ) THEN
!!    PRINT *,'fwigrid: consistency grid check failed between OROGRAPHY and RAIN GRD'
!!    STOP 1
!!  ENDIF
! LOG
!!  PRINT *,'fwigrid: Read CTL input GRIDDED file with RAIN FIELD...ok'
! END LOG
! Tidy Up
!!  IF ( ASSOCIATED(svDSCR_TMP) ) DEALLOCATE(svDSCR_TMP)
!!  IF ( ASSOCIATED(svABRV_TMP) ) DEALLOCATE(svABRV_TMP)
!!  IF ( ASSOCIATED(ivVLEVS_TMP) ) DEALLOCATE(ivVLEVS_TMP)
!!  IF ( ASSOCIATED(rvZLEVS_TMP) ) DEALLOCATE(rvZLEVS_TMP)
!!  NULLIFY(svDSCR_TMP)
!!  NULLIFY(svABRV_TMP)
!!  NULLIFY(ivVLEVS_TMP)
!!  NULLIFY(rvZLEVS_TMP)
!===============================================================================
! [8] Elaborations
!===============================================================================
! [8.1] open input DAT file
!!  OPEN(101,FILE=TRIM(sDAT_TEMP),FORM='UNFORMATTED',ACTION='READ',IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: Error in opening file ',TRIM(sDAT_TEMP)
!!    STOP 1
!!  ENDIF
!!  OPEN(111,FILE=TRIM(sDAT_RELH),FORM='UNFORMATTED',ACTION='READ',IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: Error in opening file ',TRIM(sDAT_RELH)
!!    STOP 1
!!  ENDIF
!!  OPEN(121,FILE=TRIM(sDAT_WIND),FORM='UNFORMATTED',ACTION='READ',IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: Error in opening file ',TRIM(sDAT_WIND)
!!    STOP 1
!!  ENDIF
!!  OPEN(131,FILE=TRIM(sDAT_PIOG),FORM='UNFORMATTED',ACTION='READ',IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: Error in opening file ',TRIM(sDAT_PIOG)
!!    STOP 1
!!  ENDIF
!!  OPEN(31,FILE=TRIM(sDAT_FWI),FORM='UNFORMATTED',ACTION='WRITE',IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: Error in opening file ',TRIM(sDAT_PIOG)
!!    STOP 1
!!  ENDIF
    ALLOCATE(rvFWIindexes(iNX,iNY,iNVARS_FWI),STAT=iRetCode)
    IF (iRetCode/=0) THEN
      WRITE(6,"(A)") 'fwigrid: ERROR in dynamic memory allocation for variable: rvFWIindexes'
      STOP 1
    ENDIF
    rvFWIindexes=rUNDEF_FWI
    ALLOCATE(iFWIind_class(iNX,iNY,iNVARS_FWI),STAT=iRetCode)
    IF (iRetCode/=0) THEN
      WRITE(6,"(A)") 'fwigrid: ERROR in dynamic memory allocation for variable: iFWIind_class'
      STOP 1
    ENDIF
    iFWIind_class=iUNDEF
!
!!  OPEN(18,file=TRIM(ADJUSTL(sPRECILOG)),status='unknown',IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: Error in opening file ',TRIM(sPRECILOG)
!!    STOP 1
!!  ENDIF
!!  OPEN(19,file=TRIM(ADJUSTL(sERRORLOG)),status='unknown',IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: Error in opening file ',TRIM(sERRORLOG)
!!    STOP 1
!!  ENDIF
!!  OPEN(20,file=TRIM(ADJUSTL(sPREFWILOG)),status='unknown',IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!   PRINT *,'fwigrid: Error in opening file ',TRIM(sPREFWILOG)
!!    STOP 1
!!  ENDIF
!!  OPEN(21,file=TRIM(ADJUSTL(sFWIMETEO)),status='unknown',IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: Error in opening file ',TRIM(sFWIMETEO)
!!    STOP 1
!!  ENDIF
!!  OPEN(22,file=TRIM(ADJUSTL(sPROGLOG)),status='unknown',IOSTAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: Error in opening file ',TRIM(sPROGLOG)
!!    STOP 1
!!  ENDIF
!!  Righe precedenti, con !!, commentate RG luglio 2020 *************************************************************
!===============================================================================
! [9] Read FWI ini files
!===============================================================================
  
  ilomb=1
  inorm=0
  ind_tmp=rUNDEF_FWI
  raincum=0
  isnowper=0

  sPATH0=TRIM(ADJUSTL(sPATH0))

!!  sPATH1=TRIM(ADJUSTL(sPATH1))  modificato: ora letti da file nml
!!  sPATH2=TRIM(ADJUSTL(sPATH2))  modificato: ora letti da file nml

! lettura file fwigrid_ana.ini

asdomar=TRIM(sPATHFILEini)//"fwigrid_ana2020.ini"
WRITE (*,*) asdomar

  OPEN(11,file=TRIM(sPATHFILEini)//"fwigrid_ana2020.ini",status="old",IOSTAT=iRetCode)
  IF (iRetCode/=0) THEN
    PRINT *,'fwigrid_ana: error opening file fwigrid_ana.ini'
    STOP 1
  ENDIF

!!  READ(11,"(a70)") sPATH1              ! (a70) percorso della directory con file indici (sia input che output) con "/" finale
!!  READ(11,"(a70)") sPATH2              ! (a70) percorso della directory con file meteo (neve,idi comune,prec_temp) con "/" finale
!!  READ(11,*)                           ! riga vuota
  READ(11,*) iCOLok                    ! numero colonne matrice del grigliato
  READ(11,*) iRIGok                    ! numero righe matrice del grigliato
  READ(11,*) rXLCORNok                 ! coord X Gauss Boaga dell'angolo sudovest del grigliato (grid point)
  READ(11,*) rYLCORNok                 ! coord Y Gauss Boaga dell'angolo sudovest del grigliato (grid point)
  READ(11,*) rCELLSIZEok               ! passo di griglia del grigliato (metri)
  READ(11,*)                           ! riga vuota
  READ(11,*) fod,pod,dotd              ! valori iniziali di default per FFMC,DMC,DC
  READ(11,*) idef                      ! se = 1, in caso di sottoindici di inizializ. invalidi, uso il default, altrimenti pongo =rUNDEF_FWI
  READ(11,*) (idisoglia(ik), ik=1,4)   ! 4 valori soglia per idi (t,ur,u & v,rd+rw)
  READ(11,*) pr_s1,idipr_s1            ! soglia 1 per precipitazione massima su grigliato e corrispondente soglia idi rd+rw (se verificato sovrascrive soglia di default (v. riga sopra)
  READ(11,*) pr_s2,idipr_s2            ! soglia 2 per precipitazione massima su grigliato e corrispondente soglia idi rd+rw (se verificato sovrascrive soglia di default (v. 2 righe sopra)
  READ(11,*) isnowper_lenght           ! durata oltre la quale il periodo di innevamento è considerato di "innevamento stabile" (in tal caso alla fine l'indice è re-inizializzato con valori di default)
  READ(11,*) istdby                    ! numero di giorni dallo scioglimento neve  dopo cui si inizializza l'indice (il primo calcolo dell'indice avviene a istdby+1 giorni)  
  READ(11,*) keff                      ! coefficiente di conversione da precipitazione totale cumulata sul periodo innevato a equivalente idrico disponibile (reale 0-1)

  CLOSE(11)

  inpath=TRIM(ADJUSTL(inpath))
  outpath=TRIM(ADJUSTL(outpath))

! lettura file classi
!! RG modificato percorso fwiscale.ini

  OPEN(16,file=TRIM(sPATHFILEini)//"fwiscale.ini",status="old",IOSTAT=iRetCode)
  IF (iRetCode/=0) THEN
    PRINT *,'fwigrid: error opening file fwiscale.ini'
    STOP 1
  END IF

  DO i=1,8
    READ(16,*)
    READ(16,*)
    DO j=1,5

      scale: SELECT CASE (i)
      CASE (1)
        READ(16,*) dum,(mcl(m,j), m=1,12)
      CASE (2)
        READ(16,*) dum,(fmcl(m,j), m=1,12)
      CASE (3)
        READ(16,*) dum,(dmcl(m,j), m=1,12)
      CASE (4)
        READ(16,*) dum,(dcl(m,j), m=1,12)
      CASE (5)
        READ(16,*) dum,(iscl(m,j), m=1,12)
      CASE (6)
        READ(16,*) dum,(bucl(m,j), m=1,12)
      CASE (7)
        READ(16,*) dum,(fwcl(m,j), m=1,12)
      CASE (8)
        READ(16,*) dum,(dscl(m,j), m=1,12)
      END SELECT scale

    END DO
  END DO
  CLOSE(16)

!  lettura file punti di griglia appartenenti alla regione Lombardia (shapefile usato da GRASS)

  OPEN(15,file=TRIM(sPATHFILEini)//"lombardia.txt",status="old",IOSTAT=iRetCode)
  IF (iRetCode/=0) THEN
    PRINT *,'fwigrid: error opening file <lombardia.txt>'
    STOP 1
  END IF
  READ(15,*) sTEMP, iCOL
  READ(15,*) sTEMP, iRIG
  READ(15,*) sTEMP, rXLCORN
  READ(15,*) sTEMP, rYLCORN
  READ(15,*) sTEMP, rCELLSIZE
  READ(15,*) sTEMP, iNODATA
  IF(iCOL.ne.iCOLok.or.iRIG.ne.iRIGok) THEN
    WRITE(*,*) "Numero righe e\o colonne non corretto nel file lombardia.txt"
    STOP 1
  END IF
  IF(rXLCORN.ne.rXLCORNok.or.rYLCORN.ne.rYLCORNok.or.rCELLSIZE.ne.rCELLSIZEok) THEN
    WRITE(*,*) "Coordinate e\o passo di griglia non corretti nel file lombardia.txt"
    STOP 1
  END IF
  IF(iNODATA.ne.iUNDEF) THEN
    WRITE(*,*) "Codice dato non valido errato nel file lombardia.txt"
    WRITE(*,*) iNODATA,"invece che",iUNDEF
    STOP 1
  END IF
  DO ir=1,iRIG
    READ(15,*) (ilomb(ir,ic), ic=1,iCOL)
  END DO
  CLOSE(15)

! lettura file con elenco punti della Lombardia "Grass" non appartenenti al grigliato OI meteo (per differenze di risoluzione nel file originale)

  OPEN(23,file=TRIM(sPATHFILEini)//"punti_nometeo.ini",status="old",IOSTAT=iRetCode)
  IF (iRetCode/=0) THEN
    PRINT *,'fwigrid_ana: error opening file punti_nometeo.ini'
    STOP 1
  ENDIF

  READ(23,*) npunti                        ! numero punti dell'elenco seguente
  READ(23,*)                               ! riga vuota
  DO ll=1,npunti
   READ(23,*) coord(1,ll), coord(2,ll)     ! numero riga e numero colonna del punto
  END DO

  CLOSE(23)
  
  
! leggi ora da riga di comando

  CALL GETARG(2,sYYYY)
  CALL GETARG(3,sMMM)
  CALL GETARG(4,sDD)
  READ(sYYYY,"(i4)") iYYYY
  READ(sMMM,"(i2)") iMMM
  READ(sDD,"(i2)") iDD
  iHH=13
 
 !! RG 2020 Pongo iNTIM=24; vedi se impostarlo da ini in modo generale
 !    apertura file di log giornaliero

  inizio=sYYYY//sMMM//sDD
  iNTIM=24

 Write(*,*) iYYYY,iMMM,iDD,iHH
!  *******************************************
!  *******************************************

! [8.2] Very Main cycle
  PRINT *,'START TIME CYCLE:'
!  **** start time cycle
  iNTIM_FWI=0
  CALL PackTime(iTIMEINI,iYYYY,iMMM,iDD,iHH,0,0)
  DO it=1,iNTIM  
                                      ! I -> Very Main cycle START 
!!   IF ( MOD(it,10)==0 ) THEN
!!      IF ( ASSOCIATED(rvDATA_SFC_TMP) )  DEALLOCATE(rvDATA_SFC_TMP)
!!      NULLIFY(rvDATA_SFC_TMP)
!!      IF ( ASSOCIATED(rvDATA_TMP) )  DEALLOCATE(rvDATA_TMP)
!!      NULLIFY(rvDATA_TMP)
!!    END IF
    iTIME=iTIMEINI+3600*(it-1)
    CALL UnPackTime(iTIME,iYYYY1,iMMM1,iDD1,iHH1,iMM1,iSS1)
    WRITE(6,"(A)",IOSTAT=iRetCode) &
     '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
    WRITE(6,"(A,I7,A,I7,A2,I4,A2,I2.2,A1,I2.2,A1,I2.2,A)") &
      ' timestep = ',it,' of ',iNTIM,' (',iYYYY1,'/',iMMM1,'/',iDD1,' ',iHH1,':00)'

! Individuazione primo e ultimo giorno per calcolo FWI (dopo 24 ore dall'inizio del ciclo orario sulla variabile it)

    IF(it.eq.24) THEN
      iYYYYp=iYYYY1
      iMMMp=iMMM1
      iDDp=iDD1
    END IF

    IF(it.eq.iNTIM) THEN
      iYYYYu=iYYYY1
      iMMMu=iMMM1
      iDDu=iDD1
    END IF

!!  sposto qui il blocco di creazione data "ieri" preso da sotto: qui mi serve per l'apertura dei file meteo interpolati di input

    imo=iMMM1

    WRITE(ihr,"(i2)") iHH1
    WRITE(ida,"(i2)") iDD1
    WRITE(imo1,"(i2)") iMMM1
    WRITE(iyr,"(i4)") iYYYY1

    ihr=ADJUSTL(ihr)
    ida=ADJUSTL(ida)
    imo1=ADJUSTL(imo1)

    IF (LEN_TRIM(ihr).eq.1) THEN
      ihr='0'//ihr
    END IF

    IF (LEN_TRIM(ida).eq.1) THEN
      ida='0'//ida
    END IF

    IF (LEN_TRIM(imo1).eq.1) THEN
      imo1='0'//imo1
    END IF

    giorno=iyr//imo1//ida

    OPEN(13,file=TRIM(sPATH0)//"log/fwigrid_ana_OI_inp_"//inizio//".log",status="unknown",IOSTAT=iRetCode)
    IF(iRetCode/=0) THEN
     PRINT *,'fwigrid_ana: error opening file fwigrid_ana_OI_inp.log'
     STOP 1
    ENDIF

!! Lettura input meteo interpolati
!! crea nome file Marta Interpolato (parametro o idi)
!! inserisci blocco lettura ( + fai somma per rain24, cambia unità logiche e nomi file in ciclo

    DO kop=1,10

      inteNOME: SELECT CASE (kop)
      CASE (1)
        sPREFI(1)=sPRE_TEMP
      CASE (2)
        sPREFI(2)=sPRE_TEMP_IDI
      CASE (3)
        sPREFI(3)=sPRE_RH
      CASE (4)
        sPREFI(4)=sPRE_RH_IDI
      CASE (5)
        sPREFI(5)=sPRE_VELU
      CASE (6)
        sPREFI(6)=sPRE_VELV
      CASE (7)
        sPREFI(7)=sPRE_VEL_IDI
      CASE (8)
        sPREFI(8)=sPRE_PR
	  CASE (9)
        sPREFI(9)=sPRE_PR_IDID
      CASE (10)
        sPREFI(10)=sPRE_PR_IDIW
      END SELECT inteNOME
	  
     
! lettura file input interpolato di ieri (sia grandezze che idi)
!
! Esempio: TEMP2m_$dataUTCPlus1.txt = matrice con i valori di Temperatura2m calcolati per $data, (rUNDEF fuori regione e in caso di dati invalidi)

write (*,*) sSUB
asdomar=TRIM(sPATH3)//TRIM(sPREFI(kop))//giorno//ihr//sSUB
write(*,*) asdomar
!!  IF ( (iNTIM/=iNTIMTMP).OR.(iHHTMP/=iHH).OR.(iDDTMP/=iDD).OR.(iMMMTMP/=iMMM).OR.(iYYYYTMP/=iYYYY) ) THEN
!!    PRINT *,'fwigrid: consistency time check failed between TEMPERATURE STN and RAIN GRD'
!!    STOP 1
!!  ENDIF

!!!      IF((it<24).and.(kop<8)) THEN
!!!	      GOTO 300
!!!	    ENDIF


!      OPEN(unit=iFILINTE(kop),file=TRIM(sPATH3)//TRIM(sPREFI(kop))//giorno//ihri//sSUB,status='old',IOSTAT=iRetCode)
      OPEN(unit=iFILINTE(kop),file=asdomar,status='old',IOSTAT=iRetCode)
      IF (iRetCode/=0) THEN
	    write(*,*) iRetCode
	    write(*,*) iFILINTE(kop)
        PRINT *,'fwigrid: error opening file <',TRIM(sPREFI(kop))//giorno,'>'
        STOP 1
      ENDIF
      READ(iFILINTE(kop),*) sTEMP, iCOL
      READ(iFILINTE(kop),*) sTEMP, iRIG
      READ(iFILINTE(kop),*) sTEMP, rXLCORN
      READ(iFILINTE(kop),*) sTEMP, rYLCORN
      READ(iFILINTE(kop),*) sTEMP, rCELLSIZE
      READ(iFILINTE(kop),*) sTEMP, rNODATA
      IF(iCOL.ne.iCOLok.or.iRIG.ne.iRIGok) THEN
        WRITE(13,*) "Numero righe e\o colonne non corretto nel file "//TRIM(sPREFI(kop))//ieri//'.txt'
        STOP 1
      END IF
      IF(rXLCORN.ne.rXLCORNok.or.rYLCORN.ne.rYLCORNok.or.rCELLSIZE.ne.rCELLSIZEok) THEN
        WRITE(13,*) "Coordinate e\o passo di griglia non corretti nel file "//TRIM(sPREFI(kop))//ieri//'.txt'
        STOP 1
      END IF
      IF(rNODATA.ne.rUNDEF_FWI) THEN
        WRITE(13,*) "Codice di dato non valido errato nel file "//TRIM(sPREFI(kop))//ieri//'.txt'
        STOP 1
      END IF
      DO ir=1,iRIG
        READ(iFILINTE(kop),*) (rvVALINT(ir,ic), ic=1,iCOL)
      END DO

	  
      metinte: SELECT CASE (kop)
      CASE (1)
       DO ir=1,iRIG
	    DO ic=1,iCOL
         rvTEMP_ANA_GRID(ir,ic)=rvVALINT(ir,ic)
		END DO 
       END DO
!!	   DO ir=1,iRIG
!!        write(13,*) (rvTEMP_ANA_GRID(ir,ic), ic=1,iCOL)
!!       END DO
!!	   write(13,*) 
	  
      CASE (2)
       DO ir=1,iRIG
	    DO ic=1,iCOL
         rvTEMP_IDI_GRID(ir,ic)=rvVALINT(ir,ic)
		END DO 
       END DO
      CASE (3)
       DO ir=1,iRIG
	    DO ic=1,iCOL
         rvRELH_ANA_GRID(ir,ic)=rvVALINT(ir,ic)
		END DO 
       END DO
      CASE (4)
       DO ir=1,iRIG
	    DO ic=1,iCOL
         rvRELH_IDI_GRID(ir,ic)=rvVALINT(ir,ic)
		END DO 
       END DO
      CASE (5)
       DO ir=1,iRIG
	    DO ic=1,iCOL
         rvVELU_ANA_GRID(ir,ic)=rvVALINT(ir,ic)
		END DO 
       END DO
      CASE (6)
       DO ir=1,iRIG
	    DO ic=1,iCOL
         rvVELV_ANA_GRID(ir,ic)=rvVALINT(ir,ic)
		END DO 
       END DO
      CASE (7)
       DO ir=1,iRIG
	    DO ic=1,iCOL
         rvVELU_IDI_GRID(ir,ic)=rvVALINT(ir,ic)
		END DO 
       END DO
      CASE (8)
       DO ir=1,iRIG
	    DO ic=1,iCOL
         rvPIOG_ANA_GRID(ir,ic)=rvVALINT(ir,ic)
         IF (rvPIOG_ANA_GRID(ir,ic)>=0.) THEN
          rvPIOG24_ANA_GRID(ir,ic)=rvPIOG24_ANA_GRID(ir,ic)+rvPIOG_ANA_GRID(ir,ic)
         ENDIF
		END DO 
       END DO
	  CASE (9)
       DO ir=1,iRIG
	    DO ic=1,iCOL
         rvPIOG_IDId_GRID(ir,ic)=rvVALINT(ir,ic)
         IF (rvPIOG_IDId_GRID(ir,ic)>=0.) THEN
          rvPIOG24_IDId_GRID(ir,ic)=rvPIOG24_IDId_GRID(ir,ic)+rvPIOG_IDId_GRID(ir,ic)
         ENDIF
		END DO 
       END DO
      CASE (10)
       DO ir=1,iRIG
	    DO ic=1,iCOL
         rvPIOG_IDIw_GRID(ir,ic)=rvVALINT(ir,ic)
         IF (rvPIOG_IDIw_GRID(ir,ic)>=0.) THEN
          rvPIOG24_IDIw_GRID(ir,ic)=rvPIOG24_IDIw_GRID(ir,ic)+rvPIOG_IDIw_GRID(ir,ic)
         ENDIF
		END DO 
       END DO
      END SELECT metinte	  
	  
	  
      CLOSE(iFILINTE(kop))

    END DO

!! 300 CONTINUE


    IF (iHH1/=12) CYCLE
    IF ( MOD(it,24)/=0 ) THEN
      WRITE(6,"(A)") "ERROR! In the main cycle hour=12 UTC+1 but the number of &
                      iteration from the last (hour=12 UTC+1) is different from 24"
      STOP
    ENDIF
    iNTIM_FWI=iNTIM_FWI+1
    IF (iNTIM_FWI==1) THEN
      iYYYY_FWI=iYYYY1
      iMMM_FWI=iMMM1
      iDD_FWI=iDD1
      iHH_FWI=iHH1
    ENDIF
    rvFWIindexes=rUNDEF_FWI

!! Mantengo questo bocco di lettura qua sotto da file GRADS per verificare se ho cancellato tutte variabili giuste


    ! [8.2.2] Read relative humidity data
!!    IF ( ASSOCIATED(ivVLEVS_TMP) ) DEALLOCATE(ivVLEVS_TMP)
!!    NULLIFY(ivVLEVS_TMP)
!!    ALLOCATE(ivVLEVS_TMP(iNVARS_RELH),STAT=iRetCode)
!!    IF (iRetCode/=0) THEN
!!      PRINT *,'fwigrid: Error allocating ivVLEVS_TMP'
!!      STOP 1
!!    ENDIF
!!    ivVLEVS_TMP=0
!!    CALL ReadDAT_GRD( 111, rvDATA_SFC_TMP, rvDATA_TMP,                 &
!!                      iNX, iNY, iNZ,                                   &
!!                      iNVARS_RELH, iNVARS_LD_RELH, iNVARS_SFC_RELH,    &
!!                      ivVLEVS_TMP, rUNDEF_RELH, lOKflag )
!!    IF (.not.lOKflag) THEN
!!      PRINT *,'fwigrid: Error in ReadDAT_GRD, file DAT = ',TRIM(sDAT_RELH)
!!      STOP 1
!!    ENDIF
!!    DO ii=1,iNX
!!      DO jj=1,iNY
!!        rvRELH_ANA_GRID(ii,jj)=rvDATA_SFC_TMP(ii,jj,iRELH_ANA_POS)
!!        rvRELH_IDI_GRID(ii,jj)=rvDATA_SFC_TMP(ii,jj,iRELH_IDI_POS)
!!      ENDDO
!!    ENDDO



!!    iNTIM_FWI=iNTIM_FWI+1
!!    IF (iNTIM_FWI==1) THEN
!!      iYYYY_FWI=iYYYY1
!!      iMMM_FWI=iMMM1
!!      iDD_FWI=iDD1
!!      iHH_FWI=iHH1
!!    ENDIF
    rvFWIindexes=rUNDEF_FWI


!!  Righe precedenti, a tratti con !!, commentate RG luglio 2020 *************************************************************






!   [8.2.5] Calculate FWI indexes (values and classes) at all grid points -
!           Manage IDI and Snowcover matrices

!------------------------------------------------------------------------------
! inizio parte di RG

! eventualmente aggiungere righe di controllo su header file ascii in lettura
! verificare la precisione delle variabili reali che calcolano l'indice (4 cifre decimali?)
! modificare in modo che il percorso della directory di lavoro venga passato da riga di comando e non nel codice

! NB bisogna imporre che la prima ora del ciclo orario it=1 sia l'ora 13.

! ATTENZIONE: gli array del modulo di interpolazione (e inoltre rvFWIindexes e ivFWIindclass) sono trasposti rispetto
!             agli array del modulo di calcolo di FWI (="parte di RG")
!             Le relazioni tra gli indici degli array sono le seguenti

!             ii, jj  indici degli array modulo di interpolazione: coordinata x e y intera del grigliato, con (1,1) nell'angolo SW
!             ic, ir  indici del modulo calcolo FWI: riga e colonna delle matrici ASCII dei file di input\output: l'elemento (1,1) è l'angolo NW del grigliato

!            ir=iNY+1-jj
!            ic=ii

!            iNX=iCOL
!            iNY=iRIG


!! OCCHIO RG 2020: ho modifcato relazione indici tenendo conto che non passo più dai file di Grads. Quindi non vale più quanto scritto dalla riga 1414 in poi

! ***********************      *************************



!!  inserisco qui nuovamente il trattamento della data per l'apertura dei file di input indice, neve e per la scrittura dell'output

    imo=iMMM1

    WRITE(ihr,"(i2)") iHH1
    WRITE(ida,"(i2)") iDD1
    WRITE(imo1,"(i2)") iMMM1
    WRITE(iyr,"(i4)") iYYYY1

    ihr=ADJUSTL(ihr)
    ida=ADJUSTL(ida)
    imo1=ADJUSTL(imo1)

    IF (LEN_TRIM(ihr).eq.1) THEN
      ihr='0'//ihr
    END IF

    IF (LEN_TRIM(ida).eq.1) THEN
      ida='0'//ida
    END IF

    IF (LEN_TRIM(imo1).eq.1) THEN
      imo1='0'//imo1
    END IF

    oggi=iyr//imo1//ida

! nota la data corrente corrente iDD1... , calcolo la data di ieri iDD2 ...

    iHH2=iHH1

    IF(iDD1.eq.1) THEN
      IF(iMMM1.gt.1) THEN
        IF(iMMM1.eq.3) THEN
          IF(MOD(iYYYY1,4).eq.0) THEN
            iDD2=29
          ELSE 
            iDD2=28
          END IF
        ELSE IF(iMMM1.eq.5.or.iMMM1.eq.7.or.iMMM1.eq.10.or.iMMM1.eq.12) THEN
          iDD2=30
        ELSE
          iDD2=31
        END IF
        iMMM2=iMMM1-1
        iYYYY2=iYYYY1
      ELSE
        iDD2=31
        iMMM2=12
        iYYYY2=iYYYY1-1
      END IF
    ELSE
      iDD2=iDD1-1
      iMMM2=iMMM1
      iYYYY2=iYYYY1
    END IF

    WRITE(ihri,"(i2)") iHH2
    WRITE(idai,"(i2)") iDD2
    WRITE(imoi,"(i2)") iMMM2
    WRITE(iyri,"(i4)") iYYYY2

    ihri=ADJUSTL(ihri)
    idai=ADJUSTL(idai)
    imoi=ADJUSTL(imoi)

    IF (LEN_TRIM(ihri).eq.1) THEN
      ihri='0'//ihri
    END IF

    IF (LEN_TRIM(idai).eq.1) THEN
      idai='0'//idai
    END IF

    IF (LEN_TRIM(imoi).eq.1) THEN
      imoi='0'//imoi
    END IF

    ieri=iyri//imoi//idai

    OPEN(14,file=TRIM(sPATH0)//"log/fwigrid_ana"//oggi//".log",status="unknown",IOSTAT=iRetCode)
    IF(iRetCode/=0) THEN
     PRINT *,'fwigrid_ana: error opening file fwigrid_ana_'//oggi//'.log'
     STOP 1
    ENDIF

! **************



    DO kk=1,6
      sFILO(kk)=TRIM(ADJUSTL(sFILO(kk)))
      sFILOC(kk)=TRIM(ADJUSTL(sFILOC(kk)))
    END DO
    DO kk=1,3
      sFILIT(kk)=TRIM(ADJUSTL(sFILIT(kk)))
    END DO

    iditot=1




! lettura file indici e precipitazioni temporanei per i punti con neve al suolo (solo al primo giorno del run)
!
! Esempio: ffmc_tmp_$data.txt = matrice con, nei punti senza neve i valori di rUNDEF_SNOW, nei punti con neve
!          i valori di ffmc calcolati per l'ultimo giorno prima che ci fosse neve; (rUNDEF_FWI fuori regione e in caso di dati invalidi)
!
!          raincum_tmp_$data.txt = matrice con, nei punti con neve le precipitazioni cumulate dal primo giorno con neve
!                                  fino a $data, nei punti senza neve 0; (rUNDEF fuori regione e in caso di dati invalidi)

    IF(iDD1.eq.iDDp.and.iMMM1.eq.iMMMp.and.iYYYY1.eq.iYYYYp) THEN

      DO kk=1,3
        OPEN(iFILIT(kk),file=TRIM(sPATH1)//TRIM(sFILIT(kk))//ieri//'.txt',status="old",IOSTAT=iRetCode)
        IF (iRetCode/=0) THEN
          PRINT *,'fwigrid: error opening file <',TRIM(sFILIT(kk))//ieri,'>'
          STOP 1
        ENDIF
        READ(iFILIT(kk),*) sTEMP, iCOL
        READ(iFILIT(kk),*) sTEMP, iRIG
        READ(iFILIT(kk),*) sTEMP, rXLCORN
        READ(iFILIT(kk),*) sTEMP, rYLCORN
        READ(iFILIT(kk),*) sTEMP, rCELLSIZE
        READ(iFILIT(kk),*) sTEMP, rNODATA
        IF(iCOL.ne.iCOLok.or.iRIG.ne.iRIGok) THEN
          WRITE(14,*) "Numero righe e\o colonne non corretto nel file "//TRIM(sFILIT(kk))//ieri//'.txt'
          STOP 1
        END IF
        IF(rXLCORN.ne.rXLCORNok.or.rYLCORN.ne.rYLCORNok.or.rCELLSIZE.ne.rCELLSIZEok) THEN
          WRITE(14,*) "Coordinate e\o passo di griglia non corretti nel file "//TRIM(sFILIT(kk))//ieri//'.txt'
          STOP 1
        END IF
        IF(rNODATA.ne.rUNDEF_FWI) THEN
          WRITE(14,*) "Codice di dato non valido errato nel file "//TRIM(sFILIT(kk))//ieri//'.txt'
          STOP 1
        END IF
        DO ir=1,iRIG
          READ(iFILIT(kk),*) (ind_tmp(ir,ic,kk), ic=1,iCOL)
		  write(14,*)  (ind_tmp(ir,ic,kk), ic=1,iCOL)
        END DO
		write(14,*)
        CLOSE(iFILIT(kk))
      END DO

      OPEN(94,file=TRIM(sPATH2)//'raincum_tmp_'//ieri//'.txt',status="old",IOSTAT=iRetCode)
      IF (iRetCode/=0) THEN
        PRINT *,'fwigrid: error opening file <','raincum_tmp'//ieri,'>'
        STOP 1
      END IF
      READ(94,*) sTEMP, iCOL
      READ(94,*) sTEMP, iRIG
      READ(94,*) sTEMP, rXLCORN
      READ(94,*) sTEMP, rYLCORN
      READ(94,*) sTEMP, rCELLSIZE
      READ(94,*) sTEMP, rNODATA
      IF(iCOL.ne.iCOLok.or.iRIG.ne.iRIGok) THEN
        WRITE(14,*) "Numero righe e\o colonne non corretto nel file "//"raincum_tmp_"//ieri//".txt"
        STOP 1
      END IF
      IF(rXLCORN.ne.rXLCORNok.or.rYLCORN.ne.rYLCORNok.or.rCELLSIZE.ne.rCELLSIZEok) THEN
        WRITE(14,*) "Coordinate e\o passo di griglia non corretti nel file "//"raincum_tmp_"//ieri//".txt"
        STOP 1
      END IF
      IF(rNODATA.ne.rUNDEF) THEN
        WRITE(14,*) "Codice di dato non valido errato nel file "//"raincum_tmp_"//ieri//".txt"
        STOP 1
      END IF
      DO ir=1,iRIG
        READ(94,*) (raincum(ir,ic), ic=1,iCOL)
		write(14,*) (raincum(ir,ic), ic=1,iCOL)
      END DO
	  write(14,*)
	  CLOSE(94)

    END IF

! lettura file indici di ieri (ogni giorno del run)
!
! Esempio: ffmc_$data.txt = matrice con i valori di ffmc calcolati per $data, (rUNDEF fuori regione e in caso di dati invalidi)
!                           N.B. nei punti con neve in $data (e in quelli con idi<soglia) il valore di ffmc è ricostruito tramite GRASS 
!                                con il nearest neighbour dai valori mancanti. 

    DO kk=1,3
      OPEN(unit=iFILI(kk),file=TRIM(sPATH1)//TRIM(sFILO(kk))//ieri//'.txt',status='old',IOSTAT=iRetCode)
      IF (iRetCode/=0) THEN
        PRINT *,'fwigrid: error opening file <',TRIM(sFILO(kk))//ieri,'>'
        STOP 1
      ENDIF
      READ(iFILI(kk),*) sTEMP, iCOL
      READ(iFILI(kk),*) sTEMP, iRIG
      READ(iFILI(kk),*) sTEMP, rXLCORN
      READ(iFILI(kk),*) sTEMP, rYLCORN
      READ(iFILI(kk),*) sTEMP, rCELLSIZE
      READ(iFILI(kk),*) sTEMP, rNODATA
      IF(iCOL.ne.iCOLok.or.iRIG.ne.iRIGok) THEN
        WRITE(14,*) "Numero righe e\o colonne non corretto nel file "//TRIM(sFILO(kk))//ieri//'.txt'
        STOP 1
      END IF
      IF(rXLCORN.ne.rXLCORNok.or.rYLCORN.ne.rYLCORNok.or.rCELLSIZE.ne.rCELLSIZEok) THEN
        WRITE(14,*) "Coordinate e\o passo di griglia non corretti nel file "//TRIM(sFILO(kk))//ieri//'.txt'
        STOP 1
      END IF
      IF(rNODATA.ne.rUNDEF_FWI) THEN
        WRITE(14,*) "Codice di dato non valido errato nel file "//TRIM(sFILO(kk))//ieri//'.txt'
        STOP 1
      END IF
      DO ir=1,iRIG
        READ(iFILI(kk),*) (rvFWIana(ir,ic,kk), ic=1,iCOL)
		write(14,*) (rvFWIana(ir,ic,kk), ic=1,iCOL)
      END DO
	  write(14,*)
      CLOSE(iFILI(kk))
    END DO


! lettura file copertura nevosa di ieri e di oggi
!
! Esempio:  neve_$data.txt = matrice con 2 nei punti con neve, 1 nei punti senza neve, 0 nei punti incerti


    OPEN(74,file=TRIM(sPATH2)//"neve_"//oggi//".txt",status="old",IOSTAT=iRetCode)
    IF (iRetCode/=0) THEN
      PRINT *,'fwigrid: error opening file neve_'//oggi//'.txt'
      STOP 1
    ENDIF
    READ(74,*) sTEMP, iCOL
    READ(74,*) sTEMP, iRIG
    READ(74,*) sTEMP, rXLCORN
    READ(74,*) sTEMP, rYLCORN
    READ(74,*) sTEMP, rCELLSIZE  
    READ(74,*) sTEMP, iNODATA
    IF(iCOL.ne.iCOLok.or.iRIG.ne.iRIGok) THEN
      WRITE(14,*) "Numero righe e\o colonne non corretto nel file neve_"//oggi//".txt"
      STOP 1
    END IF
    IF(rXLCORN.ne.rXLCORNok.or.rYLCORN.ne.rYLCORNok.or.rCELLSIZE.ne.rCELLSIZEok) THEN
      WRITE(14,*) "Coordinate e\o passo di griglia non corretti nel file neve_"//oggi//".txt"
      STOP 1
    END IF
    IF(iNODATA.ne.iUNDEF) THEN
      WRITE(14,*) "Coordinate e\o passo di griglia non corretti nel file neve_"//oggi//".txt"
      STOP 1
    END IF
    DO ir=1,iRIG
      READ(74,*) (iSNOWtod(ir,ic), ic=1,iCOL)  ! (1 se non neve, 2 se neve, 0 se non definito)
      write(14,*) (iSNOWtod(ir,ic), ic=1,iCOL)
	END DO
	write(14,*)
    CLOSE(74)

    OPEN(75,file=TRIM(sPATH2)//"neve_"//ieri//".txt",status="old",IOSTAT=iRetCode)
    IF (iRetCode/=0) THEN
      PRINT *,'fwigrid: error opening file neve_'//ieri//'.txt'
      STOP 1
    ENDIF
    READ(75,*) sTEMP, iCOL
    READ(75,*) sTEMP, iRIG
    READ(75,*) sTEMP, rXLCORN
    READ(75,*) sTEMP, rYLCORN
    READ(75,*) sTEMP, rCELLSIZE
    READ(75,*) sTEMP, iNODATA
    IF(iCOL.ne.iCOLok.or.iRIG.ne.iRIGok) THEN
      WRITE(14,*) "Numero righe e\o colonne non corretto nel file neve_"//ieri//".txt"
      STOP 1
    END IF
    IF(rXLCORN.ne.rXLCORNok.or.rYLCORN.ne.rYLCORNok.or.rCELLSIZE.ne.rCELLSIZEok) THEN
      WRITE(14,*) "Coordinate e\o passo di griglia non corretti nel file neve_"//ieri//".txt"
      STOP 1
    END IF
    IF(iNODATA.ne.iUNDEF) THEN
      WRITE(14,*) "Codice dato non valido errato nel file neve_"//ieri//".txt"
      STOP 1
    END IF
    DO ir=1,iRIG
      READ(75,*) (iSNOWold(ir,ic), ic=1,iCOL) ! (1 se non neve, 2 se neve, 0 se non definito)
      write(14,*) (iSNOWold(ir,ic), ic=1,iCOL) ! 
    END DO
    write(14,*)
    CLOSE(75)


!   verifico se si tratta di 24 ore senza precipitazioni o con precipitazioni molto deboli

    maxprec=maxval(rvPIOG24_ANA_GRID)
    IF(maxprec.le.pr_s1) THEN
      idisoglia(4)= idipr_s1
    ELSE IF(maxprec.le.pr_s2.and.maxprec.gt.pr_s1) THEN
      idisoglia(4)= idipr_s2
    END IF

! lettura file "periodo di innevamento" di ieri (ogni giorno del run)
!
! Esempio: snowper_$data.txt = matrice con i valori di durata di innevamento, in giorni, calcolati per $data, (rUNDEF fuori regione e in caso di dati invalidi)
!                        

    OPEN(unit=76,file=TRIM(sPATH2)//"snowper_"//ieri//".txt",status='old',IOSTAT=iRetCode)
    IF (iRetCode/=0) THEN
      PRINT *,'fwigrid: error opening file <',"snowper_"//ieri,'>'
      STOP 1
    ENDIF
    READ(76,*) sTEMP, iCOL
    READ(76,*) sTEMP, iRIG
    READ(76,*) sTEMP, rXLCORN
    READ(76,*) sTEMP, rYLCORN
    READ(76,*) sTEMP, rCELLSIZE
    READ(76,*) sTEMP, rNODATA
    IF(iCOL.ne.iCOLok.or.iRIG.ne.iRIGok) THEN
      WRITE(14,*) "Numero righe e\o colonne non corretto nel file "//"snowper_"//ieri//".txt"
      STOP 1
    END IF
    IF(rXLCORN.ne.rXLCORNok.or.rYLCORN.ne.rYLCORNok.or.rCELLSIZE.ne.rCELLSIZEok) THEN
      WRITE(14,*) "Coordinate e\o passo di griglia non corretti nel file "//"snowper_"//ieri//".txt"
      STOP 1
    END IF
    IF(rNODATA.ne.rUNDEF) THEN
      WRITE(14,*) "Codice di dato non valido errato nel file "//"snowper_"//ieri//".txt"
      STOP 1
    END IF
    DO ir=1,iRIG
      READ(76,*) (isnowper(ir,ic), ic=1,iCOL)
	  write(14,*) (isnowper(ir,ic), ic=1,iCOL)
    END DO
	write(14,*)
    CLOSE(76)

! lettura file "codice di scioglimento" di ieri (ogni giorno del run)
!
! Esempio: isciolgo_$data.txt = matrice con i valori di codice scioglimento, calcolati per $data: 0 nei punti con neve, da 1 a istdby nei punti senza neve con neve sciolta
!                               da "isciolgo" giorni, istdby+1 nei punti senza neve con neve sciolta da istdby+1 giorni ($data = primo giorno di calcolo dell'indice),
!                               istdby+2 negli altri punti senza neve con indice già inizializzato da più di un giorno, rUNDEF fuori regione e in caso di dati invalidi)
!                        

    OPEN(unit=77,file=TRIM(sPATH2)//"isciolgo_"//ieri//".txt",status='old',IOSTAT=iRetCode)
    IF (iRetCode/=0) THEN
      PRINT *,'fwigrid: error opening file <',"isciolgo_"//ieri,'>'
      STOP 1
    ENDIF
    READ(77,*) sTEMP, iCOL
    READ(77,*) sTEMP, iRIG
    READ(77,*) sTEMP, rXLCORN
    READ(77,*) sTEMP, rYLCORN
    READ(77,*) sTEMP, rCELLSIZE
    READ(77,*) sTEMP, rNODATA
    IF(iCOL.ne.iCOLok.or.iRIG.ne.iRIGok) THEN
      WRITE(14,*) "Numero righe e\o colonne non corretto nel file "//"isciolgo_"//ieri//".txt"
      STOP 1
    END IF
    IF(rXLCORN.ne.rXLCORNok.or.rYLCORN.ne.rYLCORNok.or.rCELLSIZE.ne.rCELLSIZEok) THEN
      WRITE(14,*) "Coordinate e\o passo di griglia non corretti nel file "//"isciolgo_"//ieri//".txt"
      STOP 1
    END IF
    IF(rNODATA.ne.rUNDEF) THEN
      WRITE(14,*) "Codice di dato non valido errato nel file "//"isciolgo_"//ieri//".txt"
      STOP 1
    END IF
    DO ir=1,iRIG
      READ(77,*) (isciolgo(ir,ic), ic=1,iCOL)
	  write(14,*) (isciolgo(ir,ic), ic=1,iCOL)
    END DO
	write(14,*)
    CLOSE(77)

! *********   ciclo sui punti di griglia    ******	 (verificare L'ORDINE DEI PUNTI-INDICI)

    DO ir=1,iRIGok
      DO ic=1,iCOLok

!    salto i punti in cui non sono definiti i valori meteo (xchè "Lombardia OI" e' diversa da "Lombardia Grass")

        DO ll=1,npunti
          IF(ir.eq.coord(1,ll).and.ic.eq.coord(2,ll)) THEN
            mc=rUNDEF_FWI
            ffm=rUNDEF_FWI
            dmc=rUNDEF_FWI
            dc=rUNDEF_FWI
            si=rUNDEF_FWI
            bui=rUNDEF_FWI
            fwi=rUNDEF_FWI
            dsr=rUNDEF_FWI
            GOTO 40
          END IF
        END DO

!  Trattamento IDI (N.B. u e v hanno stesso idi!!!)

        IF(rvTEMP_IDI_GRID(ir,ic).eq.rUNDEF_TEMP) rvTEMP_IDI_GRID(ir,ic)=rUNDEF          ! N.B. l'idi nei file grads ha lo stesso UNDEF del parametro cui si riferisce
        IF(rvRELH_IDI_GRID(ir,ic).eq.rUNDEF_RELH) rvRELH_IDI_GRID(ir,ic)=rUNDEF          ! Percio' qui effettuo la conversione dei codici di valore indefinito in rUNDEF unico
        IF(rvVELU_IDI_GRID(ir,ic).eq.rUNDEF_WIND) rvVELU_IDI_GRID(ir,ic)=rUNDEF
        IF(rvPIOG24_IDIw_GRID(ir,ic).eq.rUNDEF_PIOG.or.rvPIOG24_IDId_GRID(ir,ic).eq.rUNDEF_PIOG) THEN
          idi(4)=rUNDEF
        ELSE
          idi(4)=(rvPIOG24_IDIw_GRID(ir,ic)+rvPIOG24_IDId_GRID(ir,ic))/24
        END IF

        idi(1)=rvTEMP_IDI_GRID(ir,ic)
        idi(2)=rvRELH_IDI_GRID(ir,ic)
        idi(3)=rvVELU_IDI_GRID(ir,ic)

        DO id=1,4
          IF(isalta.eq.0) THEN
            IF(idi(id).eq.rUNDEF) THEN
              iditot(ir,ic)=iUNDEF
              isalta=1
            ELSE IF(idi(id).lt.idisoglia(id)) THEN
              iditot(ir,ic)=0
              isalta=1
            END IF
          END IF
        END DO
        IF(ilomb(ir,ic).eq.iUNDEF) THEN
          iditot(ir,ic)=iUNDEF
        END IF
        isalta=0


! assegnazione dati meteo

        t=rvTEMP_ANA_GRID(ir,ic)
        h=rvRELH_ANA_GRID(ir,ic)
        IF(rvVELU_ANA_GRID(ir,ic).eq.rUNDEF_WIND.or.rvVELV_ANA_GRID(ir,ic).eq.rUNDEF_WIND) THEN
          w=rUNDEF_WIND
          ws(ir,ic)=rUNDEF_WIND
        ELSE
          w=(sqrt((rvVELU_ANA_GRID(ir,ic))**2+(rvVELV_ANA_GRID(ir,ic))**2))*3.6
          ws(ir,ic)=(sqrt((rvVELU_ANA_GRID(ir,ic))**2+(rvVELV_ANA_GRID(ir,ic))**2))*3.6
        END IF
        r=rvPIOG24_ANA_GRID(ir,ic)
        tok=t

!  se UR>=100 la pongo di poco < 100, per evitare problemi di arrotondamento

        IF(h.ge.100.) h=99.95


! assegnazione indici di base del giorno prima

        fo=rvFWIana(ir,ic,1)
        po=rvFWIana(ir,ic,2)
        dot=rvFWIana(ir,ic,3)

! utilizzo valori di default in caso di sottoindici iniziali mancanti o invalidi (fatto solo al primo giorno del run)
! N.B. In base a come lavorano gli scripts di GRASS, è possibile che i sottoindici siano non definiti nei punti innevati
!      ieri. Dato che il valore degli indici nei punti innevati ieri o non viene utilizzato (oggi neve) oppure viene ricavato
!      dalle matrici ind_tmp, tale caso non viene segnalato come errore nel log

!!! Forse questa parte sotto diventa inutile dopo modifiche fatte in script GRASS 1500m_GRIMA

! CHIARIRE SE SERve TRATTAMENTO Di valori rSNOWCODE!!!!!!!!!!!!!!!!!!!!****************@@@@@@@@@@@@@@@@@@@@

!  Chiarire bene quel N.B qua sopra che non me lo ricordo... :-)

        IF(iDD1.eq.iDDp.and.iMMM1.eq.iMMMp.and.iYYYY1.eq.iYYYYp) THEN

          IF(ilomb(ir,ic).ne.iUNDEF) THEN

            IF(fo.ne.rSNOWCODE) THEN
              IF(fo.eq.rUNDEF_FWI.or.(fo.lt.0..or.fo.gt.101.)) THEN
                IF(idef.eq.1) THEN
                  fo=fod
                ELSE
                  fo=rUNDEF_FWI
                END IF
              END IF
            END IF


            IF(po.ne.rSNOWCODE) THEN
              IF(po.eq.rUNDEF_FWI.or.po.lt.0.) THEN
                IF(idef.eq.1) THEN
                  po=pod
                ELSE
                  po=rUNDEF_FWI
                END IF
              END IF
            END IF

            IF(dot.ne.rSNOWCODE) THEN
              IF(dot.eq.rUNDEF_FWI.or.dot.lt.0.) THEN
                IF(idef.eq.1) THEN
                  dot=dotd
                ELSE
                  dot=rUNDEF_FWI
                END IF
              END IF
            END IF

          END IF

        END IF


! verifica validita' dei sottoindici del giorno prima (sia al giorno 1 che nei giorni successivi)

        IF(fo.eq.rUNDEF_FWI.or.po.eq.rUNDEF_FWI.or.dot.eq.rUNDEF_FWI) THEN
          mc=rUNDEF_FWI
          ffm=rUNDEF_FWI
          dmc=rUNDEF_FWI
          dc=rUNDEF_FWI
          si=rUNDEF_FWI
          bui=rUNDEF_FWI
          fwi=rUNDEF_FWI
          dsr=rUNDEF_FWI
          IF(ilomb(ir,ic).ne.iUNDEF) THEN
            inorm=1
            WRITE(14,*) "Errore: sottoindici di ieri non definiti! -> indici di oggi invalidi"
            WRITE(14,*)  "Oggi: ",oggi, "Punto di griglia: ",ir,ic
          END IF
          GOTO 40
        END IF



! **********  gestione dell'overwintering  ***************  VERIFICARE CHE TUTTI I CASI SIANO RISOLTI BENE (CON SCHEMA DI DAVIDE)

        IF(ilomb(ir,ic).ne.iUNDEF) THEN    ! considero solo i punti in Lombardia

          IF(ind_tmp(ir,ic,1).eq.rUNDEF_FWI.or.ind_tmp(ir,ic,2).eq.rUNDEF_FWI.or.ind_tmp(ir,ic,3).eq.rUNDEF_FWI) THEN
            WRITE(14,*)  "Errore: valore indefinito nel file indice_tmp di ieri"
            WRITE(14,*)  "Oggi: ",oggi, "Punto di griglia: ",ir,ic
            WRITE(14,*)  "INTERROMPO IL PROGRAMMA"
            STOP 1
          END IF
          IF(raincum(ir,ic).eq.rUNDEF) THEN
            WRITE(14,*)  "Errore: valore indefinito nel file raincum_tmp di ieri"
            WRITE(14,*)  "Oggi: ",oggi, "Punto di griglia: ",ir,ic
            WRITE(14,*)  "INTERROMPO IL PROGRAMMA"
            STOP 1
          END IF


          IF(iSNOWtod(ir,ic).eq.2) THEN   ! se il punto e' innevato oggi
            mc=rSNOWCODE
            ffm=rSNOWCODE
            dc=rSNOWCODE
            dmc=rSNOWCODE
            si=rSNOWCODE
            bui=rSNOWCODE
            fwi=rSNOWCODE
            dsr=rSNOWCODE
            isciolgo(ir,ic)=0
            IF(isnowper(ir,ic).lt.365) THEN
              isnowper(ir,ic)=isnowper(ir,ic)+1
            END IF
            IF(ind_tmp(ir,ic,1).eq.rUNDEF_SNOW.or.&
               (ind_tmp(ir,ic,1).ne.rUNDEF_SNOW.and.(isciolgo(ir,ic).gt.0.and.isciolgo(ir,ic).le.istdby))) THEN

              IF(ind_tmp(ir,ic,1).eq.rSNOWCODE.or.ind_tmp(ir,ic,2).eq.rSNOWCODE.or.ind_tmp(ir,ic,3).eq.rSNOWCODE) THEN   ! dubbio: qui e' rSNOWCODE o rUNDEF_SNOW, oppure non ind_tmp?
                WRITE(14,*)  "Errore: codice rSNOWCODE trovato in punto senza neve"
                WRITE(14,*)  "Oggi: ",oggi, "Punto di griglia: ",ir,ic
                WRITE(14,*)  "INTERROMPO IL PROGRAMMA"
               STOP 1
              END IF
              ind_tmp(ir,ic,1)=fo
              ind_tmp(ir,ic,2)=po
              ind_tmp(ir,ic,3)=dot
              IF(r.ne.rUNDEF_PIOG) THEN
                raincum(ir,ic)=raincum(ir,ic)+r
              ENDIF
            ELSE
              IF(r.ne.rUNDEF_PIOG) THEN
                raincum(ir,ic)=raincum(ir,ic)+r
              ENDIF
            END IF
            GOTO 40   ! salto calcolo indici

          ELSE IF(iSNOWtod(ir,ic).eq.1) THEN  ! se il punto non e' innevato oggi

            IF(iSNOWold(ir,ic).eq.2.or.(iSNOWold(ir,ic).eq.0.and.ind_tmp(ir,ic,1).ne.rUNDEF_SNOW.and.isciolgo(ir,ic).eq.0)) THEN ! in caso di innevamento ieri -> scioglimento oggi

! **********  in caso di mancata corrispondenza tra punti di griglia del file neve e del file ind_tmp-> pongo indici invalidi per oggi
              IF(ind_tmp(ir,ic,1).eq.rUNDEF_SNOW.or.(ind_tmp(ir,ic,1).lt.0..or.ind_tmp(ir,ic,1).gt.101.)) THEN
                fo=rUNDEF_FWI
                WRITE(14,*) "Errore di corrispondenza nei punti di griglia tra neve e ffmc_tmp -> indici di oggi invalidi"
                WRITE(14,*)  "Giorno ",oggi, "Punto di griglia: ",ir,ic
                inorm=1
                GOTO 40
              END IF
              IF(ind_tmp(ir,ic,2).eq.rUNDEF_SNOW.or.ind_tmp(ir,ic,2).lt.0.) THEN
                po=rUNDEF_FWI
                WRITE(14,*) "Errore di corrispondenza nei punti di griglia tra neve e dmc_tmp -> indici di oggi invalidi"
                WRITE(14,*)  "Giorno ",oggi, "Punto di griglia: ",ir,ic
                inorm=1
                GOTO 40
              END IF
              IF(ind_tmp(ir,ic,3).eq.rUNDEF_SNOW.or.ind_tmp(ir,ic,3).lt.0.) THEN
                dot=rUNDEF_FWI
                WRITE(14,*) "Errore di corrispondenza nei punti di griglia tra neve e dc_tmp -> indici di oggi invalidi"
                WRITE(14,*)  "Giorno ",oggi, "Punto di griglia: ",ir,ic
                inorm=1
                GOTO 40
              END IF
! **********
              IF(istdby.eq.0) THEN
                IF(isnowper(ir,ic).ge.isnowper_lenght) THEN
                  fo=fod
                  po=pod
                  dot=dotd
                ELSE
                  fo=ind_tmp(ir,ic,1)
                  po=ind_tmp(ir,ic,2)
                  dot=ind_tmp(ir,ic,3)
                END IF
                isciolgo(ir,ic)=isciolgo(ir,ic)+1
                r=raincum(ir,ic)*keff
                raincum(ir,ic)=0
                ind_tmp(ir,ic,1)=rUNDEF_SNOW
                ind_tmp(ir,ic,2)=rUNDEF_SNOW
                ind_tmp(ir,ic,3)=rUNDEF_SNOW
                GOTO 30 !istruzione imposta per evitare l'esecuzione della riga 1836 (caso 0< e <=0)
              ELSE
                mc=rSNOWCODE
                ffm=rSNOWCODE
                dc=rSNOWCODE
                dmc=rSNOWCODE
                si=rSNOWCODE
                bui=rSNOWCODE
                fwi=rSNOWCODE
                dsr=rSNOWCODE
                IF(r.ne.rUNDEF_PIOG) THEN
                  raincum(ir,ic)=raincum(ir,ic)+r
                ENDIF
                isnowper(ir,ic)=0 
                isciolgo(ir,ic)=1
                GOTO 40         
              END IF

            ELSE IF( (iSNOWold(ir,ic).eq.0.and.ind_tmp(ir,ic,1)&
                &.eq.rUNDEF_SNOW).or.(iSNOWold(ir,ic).eq.0&
                &.and.ind_tmp(ir,ic,1).ne.rUNDEF_SNOW&
                &.and.(isciolgo(ir,ic).gt.0.and.isciolgo(ir,ic).le.istdby)) ) THEN
                ! incertezza ieri, con indice_temp di ieri uguale rUNDEFSNOW oppure con isciolgo <=istdby -> niente neve ieri -> nessuna variazione="da non-neve a non-neve"

              IF(isciolgo(ir,ic).lt.istdby) THEN
                mc=rSNOWCODE
                ffm=rSNOWCODE
                dc=rSNOWCODE
                dmc=rSNOWCODE
                si=rSNOWCODE
                bui=rSNOWCODE
                fwi=rSNOWCODE
                dsr=rSNOWCODE
                isciolgo(ir,ic)=isciolgo(ir,ic)+1
                GOTO 40 
              ELSE IF(isciolgo(ir,ic).eq.istdby) THEN
                IF(isnowper(ir,ic).ge.isnowper_lenght) THEN
                  fo=fod
                  po=pod
                  dot=dotd
                ELSE
                  fo=ind_tmp(ir,ic,1)
                  po=ind_tmp(ir,ic,2)
                  dot=ind_tmp(ir,ic,3)
                END IF
                r=raincum(ir,ic)*keff
                raincum(ir,ic)=0
                isciolgo(ir,ic)=isciolgo(ir,ic)+1
                ind_tmp(ir,ic,1)=rUNDEF_SNOW
                ind_tmp(ir,ic,2)=rUNDEF_SNOW
                ind_tmp(ir,ic,3)=rUNDEF_SNOW
              ELSE IF(isciolgo(ir,ic).eq.istdby+1) THEN
                isciolgo(ir,ic)=isciolgo(ir,ic)+1
                ind_tmp(ir,ic,1)=rUNDEF_SNOW
                ind_tmp(ir,ic,2)=rUNDEF_SNOW
                ind_tmp(ir,ic,3)=rUNDEF_SNOW
              END IF
             
            ELSE  ! in caso di terreno libero ieri -> nessuna variazione: da "non neve" a "non neve"
             
              IF(isciolgo(ir,ic).lt.istdby) THEN
                mc=rSNOWCODE
                ffm=rSNOWCODE
                dc=rSNOWCODE
                dmc=rSNOWCODE
                si=rSNOWCODE
                bui=rSNOWCODE
                fwi=rSNOWCODE
                dsr=rSNOWCODE 
                isciolgo(ir,ic)=isciolgo(ir,ic)+1
                GOTO 40 
              ELSE IF(isciolgo(ir,ic).eq.istdby) THEN
                IF(isnowper(ir,ic).ge.isnowper_lenght) THEN
                  fo=fod
                  po=pod
                  dot=dotd
                ELSE
                  fo=ind_tmp(ir,ic,1)
                  po=ind_tmp(ir,ic,2)
                  dot=ind_tmp(ir,ic,3)
                END IF
                r=raincum(ir,ic)*keff
                raincum(ir,ic)=0
                isciolgo(ir,ic)=isciolgo(ir,ic)+1
                ind_tmp(ir,ic,1)=rUNDEF_SNOW
                ind_tmp(ir,ic,2)=rUNDEF_SNOW
                ind_tmp(ir,ic,3)=rUNDEF_SNOW
              ELSE IF(isciolgo(ir,ic).eq.istdby+1) THEN
                isciolgo(ir,ic)=isciolgo(ir,ic)+1
                ind_tmp(ir,ic,1)=rUNDEF_SNOW
                ind_tmp(ir,ic,2)=rUNDEF_SNOW
                ind_tmp(ir,ic,3)=rUNDEF_SNOW
              END IF

            END IF

          ELSE IF(iSNOWtod(ir,ic).eq.0) THEN  ! se il punto e' incerto oggi
            IF( iSNOWold(ir,ic).eq.2.or.(iSNOWold(ir,ic).eq.0.and.(ind_tmp(ir,ic,1)&
                &.ne.rUNDEF_SNOW.or.isciolgo(ir,ic).le.istdby))) THEN ! in caso di innevamento ieri\o prima -> innevamento oggi
              mc=rSNOWCODE
              ffm=rSNOWCODE
              dc=rSNOWCODE
              dmc=rSNOWCODE
              si=rSNOWCODE
              bui=rSNOWCODE
              fwi=rSNOWCODE
              dsr=rSNOWCODE
              isciolgo(ir,ic)=0
              IF(r.ne.rUNDEF_PIOG) THEN
                raincum(ir,ic)=raincum(ir,ic)+r
              END IF
              IF(isnowper(ir,ic).lt.365) THEN
                isnowper(ir,ic)=isnowper(ir,ic)+1
              END IF
              GOTO 40   !salto calcolo indici
            ELSE  ! in caso di terreno libero ieri -> terreno libero anche oggi

              IF(isciolgo(ir,ic).lt.istdby) THEN
                mc=rSNOWCODE
                ffm=rSNOWCODE
                dc=rSNOWCODE
                dmc=rSNOWCODE
                si=rSNOWCODE
                bui=rSNOWCODE
                fwi=rSNOWCODE
                dsr=rSNOWCODE 
                isciolgo(ir,ic)=isciolgo(ir,ic)+1
                GOTO 40 
              ELSE IF(isciolgo(ir,ic).eq.istdby) THEN
                IF(isnowper(ir,ic).ge.isnowper_lenght) THEN
                  fo=fod
                  po=pod
                  dot=dotd
                ELSE
                  fo=ind_tmp(ir,ic,1)
                  po=ind_tmp(ir,ic,2)
                  dot=ind_tmp(ir,ic,3)
                END IF
                r=raincum(ir,ic)*keff
                raincum(ir,ic)=0
                isciolgo(ir,ic)=isciolgo(ir,ic)+1
                ind_tmp(ir,ic,1)=rUNDEF_SNOW
                ind_tmp(ir,ic,2)=rUNDEF_SNOW
                ind_tmp(ir,ic,3)=rUNDEF_SNOW
              ELSE IF(isciolgo(ir,ic).eq.istdby+1) THEN
                isciolgo(ir,ic)=isciolgo(ir,ic)+2
                ind_tmp(ir,ic,1)=rUNDEF_SNOW
                ind_tmp(ir,ic,2)=rUNDEF_SNOW
                ind_tmp(ir,ic,3)=rUNDEF_SNOW
              END IF

            END IF
          END IF

        END IF


30      CONTINUE


! verifica presenza dati meteo non validi

!		write(13,*) ir,ic,t,rUNDEF_TEMP,h,rUNDEF_RELH,w,rUNDEF_WIND,r,rUNDEF_PIOG,fo,po,dot

        IF(t.eq.rUNDEF_TEMP.or.h.eq.rUNDEF_RELH.or.w.eq.rUNDEF_WIND.or.r.eq.rUNDEF_PIOG) THEN
          mc=rUNDEF_FWI
          ffm=rUNDEF_FWI
          dc=rUNDEF_FWI
          dmc=rUNDEF_FWI
          si=rUNDEF_FWI
          bui=rUNDEF_FWI
          fwi=rUNDEF_FWI
          dsr=rUNDEF_FWI
          IF(ilomb(ir,ic).ne.iUNDEF) THEN
            inorm=1
            WRITE(14,*) "Errore: dati meteo non definiti! -> indici di oggi invalidi"
            WRITE(14,*)  "Oggi: ",oggi, "Punto di griglia: ",ir,ic
          END IF
          GOTO 40
        END IF




! ******************

! CALCOLO DEI SOTTOINDICI 

! ******************

! controllo validità indici in input (forse superfluo, verificare)

        IF(fo.eq.rSNOWCODE.or.po.eq.rSNOWCODE.or.dot.eq.rSNOWCODE) THEN
          WRITE(14,*) "Errore: sottoindice uguale a rSNOWCODE nella sezione di calcolo"
          WRITE(14,*)  "FFMC,DMC,DC"
          WRITE(14,*)  fo,po,dot
          WRITE(14,*)  "Programma Terminato"
          STOP
        ELSE IF(fo.eq.rUNDEF_FWI.or.po.eq.rUNDEF_FWI.or.dot.eq.rUNDEF_FWI) THEN
          WRITE(14,*) "Errore: sottoindice uguale a rSNOWCODE nella sezione di calcolo"
          WRITE(14,*)  "FFMC,DMC,DC"
          WRITE(14,*)  fo,po,dot
          WRITE(14,*)  "Programma Terminato"
          STOP
        ELSE IF(fo.lt.0.or.po.lt.0.or.dot.lt.0) THEN
          WRITE(14,*) "Errore: sottoindice negativo nella sezione di calcolo"
          WRITE(14,*)  "FFMC,DMC,DC"
          WRITE(14,*)  fo,po,dot
          WRITE(14,*)  "Programma Terminato"
          STOP
        ELSE IF(fo.gt.101.) THEN
          WRITE(14,*) "Errore: ffmc maggiore di 101 nella sezione di calcolo"
          WRITE(14,*)  "FFMC,DMC,DC"
          WRITE(14,*)  fo,po,dot
          WRITE(14,*)  "Programma Terminato"
          STOP
        ENDIF


! Nota: le espressioni per il calcolo dei vari indici e sottoindici sono state formulate,
!       quando possibile, nel modo indicato in (Van Wagner, 1984) nella parte di descrizione
!       dell'algoritmo (non nella formulazione del codice fortran) pur conservando il nome
!       delle variabili usato nel medesimo codice. Alcuni suggerimenti derivano dalle versioni
!       in C e perl scritte da Mike Wotton e Richard Carr (metti riferimenti).

!  ***   Fine Fuel Moisture Code  FFMC  --->  ffm

        wmo=(147.2*(101-fo))/(59.5+fo)

!  controllo inserito per evitare divisioni per 0

        IF(wmo.eq.251.) wmo=250.

        IF(r.gt.0.5) THEN
          ra=r-.5
          IF(wmo.gt.150.) THEN
            wmo=wmo+42.5*ra*EXP(-100./(251.-wmo))*(1.-EXP(-6.93/ra))+(0.0015*((wmo-150.)**2)*(ra**.5))
          ELSE
            wmo=wmo+42.5*ra*EXP(-100./(251.-wmo))*(1.-EXP(-6.93/ra))
          END IF
        END IF

        IF(wmo.gt.250.) wmo=250.

        ed=0.942*(h**0.679)+(11.*EXP((h-100)/10.))+0.18*(21.1-t)*(1.-EXP(-0.115*h))
        ew=0.618*(h**0.753)+(10.*EXP((h-100.)/10.))+0.18*(21.1-t)*(1.-EXP(-0.115*h))

        IF(wmo.gt.ed) THEN
          z=0.424*(1.-(h/100.)**1.7)+(0.0694*(w**0.5))*(1.-(h/100.)**8)
          x=z*(0.581*(EXP(0.0365*t)))
          wm=ed+(wmo-ed)*(10.**(-x))
        ELSE IF(wmo.ge.ew.and.wmo.le.ed) THEN
          wm=wmo
        ELSE IF(wmo.lt.ew) THEN
          z=0.424*(1.-((100.-h)/100.)**1.7)+0.0694*(w**0.5)*(1-((100.-h)/100.)**8)
          x=z*(0.581*(EXP(.0365*t)))
          wm=ew-(ew-wmo)*(10.**(-x))
        END IF
        ffm=(59.5*(250.-wm))/(147.2+wm)

        IF(ffm.gt.101.) THEN
          ffm=101.
        ELSE IF(ffm.lt.0.) THEN
          ffm=0.0
        END IF

!  ***   Moisture Content  MC  --->  mc

        mc=147.2*(101-ffm)/(59.5+ffm)

!  ***   duff moisture code   DMC  --->  dmc

        IF(t.lt.-1.1) THEN
          t=-1.1
        END IF

        rk=1.894*(t+1.1)*(100.-h)*(el(imo)*0.000001)

        IF(r.gt.1.5) THEN
          ra=r
          rw=0.92*ra-1.27
          wmi=20.0+EXP(5.6348-(po/43.43))
          IF(po.le.33.) THEN
            b=100./(0.5+0.3*po)
          ELSE IF(po.gt.33..and.po.le.65.) THEN
            b=14.-1.3*DLOG(po) 
          ELSE
            b=6.2*DLOG(po)-17.2
          END IF
          wmr=wmi+(1000.*rw)/(48.77+b*rw)
          IF(wmr.eq.20.) wmr=21.
!  condizione inserita per evitare log con arg =0 . Verificare se inutile
          pr=244.72-(43.43*DLOG(wmr-20.))
        ELSE
          pr=po
        END IF

        IF(pr.lt.0.) pr=0.

        dmc=pr+100.*rk

        IF(dmc.lt.0.) dmc=0.

!  ***   drought code   DC  ---> dc

        IF(tok.lt.-2.8) THEN
          t=-2.8
        ELSE
          t=tok
        END IF

        pe=0.36*(t+2.8)+fl(imo)

        IF(pe.le.0.) pe=0.

        IF(r.gt.2.8) THEN
          ra=r
          rw=0.83*ra-1.27
          smi=800.*EXP(-dot/400.)
          dr=dot-400.*DLOG(1.+((3.937*rw)/smi)) ! espressione orginale versione f77
!  inserire qui eq.ne modificata di Carr
          IF(dr.le.0.) dr=0.
        ELSE
          dr=dot
        END IF

        dc=dr+(pe/2)

        IF(dc.le.0.) dc=0.
        t=tok

!  ***   initial spread index   ISI  --->  si
 
        fm=(147.2*(101.-ffm))/(59.5+ffm)
        sf=91.9*EXP(fm*(-0.1386))*(1.+(fm**5.31)/4.93E7)
        si=0.208*sf*EXP(0.05039*w)

!  ***   build up index   BUI  --->  bui

! occhio da qui in poi ho cambiato pesantemente!!!

        IF(dmc.eq.0.0.and.dc.eq.0.0) THEN 
          bui=0.
        ELSE
          IF (dmc.gt.0..and.dmc.le.(0.4*dc)) THEN
            bui=(0.8*dc*dmc)/(dmc+0.4*dc)
          ELSE
            p=1-((0.8*dc)/(dmc+0.4*dc))  
            cc=0.92+((0.0114*dmc)**1.7)     
            bui=dmc-(cc*p)
 !verificare che questa espressione e' equivalente a quella in f32.for
          END IF
        END IF

        IF(bui.le.0.) bui=0.

! ******************

! CALCOLO DELL'INDICE

! ******************

!  ***   fire weather index   FWI  --->  fwi

        IF(bui.le.0.) THEN
          bui=0.
        ELSE IF(bui.gt.0..and.bui.le.80.) THEN
          bb=0.1*si*((0.626*(bui**0.809))+2.)
        ELSE
          bb=0.1*si*(1000./(25.+(108.64/EXP(0.023*bui))))
        END IF
        IF(bb.le.1.) THEN
          fwi=bb
        ELSE
          sl=2.72*((0.434*DLOG(bb))**0.647)
          fwi=EXP(sl)
        END IF

!  ***   danger severity rating  DSR  --->  dsr

        dsr=0.0272*(fwi**1.77)

!  ***   FINE CALCOLO INDICE

! ****  Assegnazione elementi non innevati della matrice indici temporanei ****

        ind_tmp(ir,ic,1)=ffm
        ind_tmp(ir,ic,2)=dmc
        ind_tmp(ir,ic,3)=dc

40      CONTINUE

! ****  Assegnazione matrici indici ****
!! RG2020 cambio assegnazione

!!        rvFWIindexes(ic,(iRIGok+1-ir),1)=ffm
!!        rvFWIindexes(ic,(iRIGok+1-ir),2)=dmc
!!        rvFWIindexes(ic,(iRIGok+1-ir),3)=dc
!!        rvFWIindexes(ic,(iRIGok+1-ir),4)=si
!!        rvFWIindexes(ic,(iRIGok+1-ir),5)=bui
!!        rvFWIindexes(ic,(iRIGok+1-ir),6)=fwi

        write(13,*) ir,ic,ffm,dmc,dc,si,bui,fwi
		
		rvFWIindexes(ir,ic,1)=ffm
        rvFWIindexes(ir,ic,2)=dmc
        rvFWIindexes(ir,ic,3)=dc
        rvFWIindexes(ir,ic,4)=si
        rvFWIindexes(ir,ic,5)=bui
        rvFWIindexes(ir,ic,6)=fwi
        write(13,*) ir,ic,rvFWIindexes(ir,ic,1),rvFWIindexes(ir,ic,2),rvFWIindexes(ir,ic,3),rvFWIindexes(ir,ic,4),&
		rvFWIindexes(ir,ic,5),rvFWIindexes(ir,ic,6)


! **** Assegnazione matrici classi ****

!  assegnazione classi di ffm

        IF(ffm.eq.rSNOWCODE) THEN
          clafm=0
        ELSE IF(ffm.eq.rUNDEF_FWI) THEN
          clafm=iUNDEF
        ELSE
          IF(ffm.ge.fmcl(imo,5)) THEN
            clafm=6
          ELSE IF(ffm.ge.0..and.ffm.lt.fmcl(imo,1)) THEN
            clafm=1
          ELSE
            DO ind=1,5
              IF(ffm.ge.fmcl(imo,ind).and.ffm.lt.fmcl(imo,ind+1)) THEN
                clafm=ind+1
              END IF
            END DO
          END IF
        END IF

!  assegnazione classi di mc (al momento non utilizzato)

        IF(mc.eq.rSNOWCODE) THEN
          clamc=0
        ELSE IF(mc.eq.rUNDEF_FWI) THEN
          clamc=iUNDEF
        ELSE
          IF(mc.ge.mcl(imo,5)) THEN
            clamc=6
          ELSE IF(mc.ge.0..and.mc.lt.mcl(imo,1)) THEN
            clamc=1
          ELSE
            DO ind=1,5
              IF(mc.ge.mcl(imo,ind).and.mc.lt.mcl(imo,ind+1)) THEN
                clamc=ind+1
              END IF
            END DO
          END IF
        END IF

!  assegnazione classi di dmc

        IF(dmc.eq.rSNOWCODE) THEN
          cladm=0
        ELSE IF(dmc.eq.rUNDEF_FWI) THEN
          cladm=iUNDEF
        ELSE
          IF(dmc.ge.dmcl(imo,5)) THEN
            cladm=6
          ELSE IF(dmc.ge.0..and.dmc.lt.dmcl(imo,1)) THEN
            cladm=1
          ELSE
            DO ind=1,5
              IF(dmc.ge.dmcl(imo,ind).and.dmc.lt.dmcl(imo,ind+1)) THEN
                cladm=ind+1
              END IF
            END DO
          END IF
        END IF 

!  assegnazione classi di dc

        IF(dc.eq.rSNOWCODE) THEN
          cladc=0
        ELSE IF(dc.eq.rUNDEF_FWI) THEN
          cladc=iUNDEF
        ELSE
          IF(dc.ge.dcl(imo,5)) THEN
            cladc=6
          ELSE IF(dc.ge.0..and.dc.lt.dcl(imo,1)) THEN
            cladc=1
          ELSE
            DO ind=1,5
              IF(dc.ge.dcl(imo,ind).and.dc.lt.dcl(imo,ind+1)) THEN
                cladc=ind+1
              END IF
            END DO
          END IF
        END IF

!  assegnazione classi di isi

        IF(si.eq.rSNOWCODE) THEN
          clais=0
        ELSE IF(si.eq.rUNDEF_FWI) THEN
          clais=iUNDEF
        ELSE
          IF(si.ge.iscl(imo,5)) THEN
            clais=6
          ELSE IF(si.ge.0..and.si.lt.iscl(imo,1)) THEN
            clais=1
          ELSE
            DO ind=1,5
              IF(si.ge.iscl(imo,ind).and.si.lt.iscl(imo,ind+1)) THEN
                clais=ind+1
              END IF
            END DO
          END IF
        END IF

!  assegnazione classi di bui

        IF(bui.eq.rSNOWCODE) THEN
          clabu=0
        ELSE IF(bui.eq.rUNDEF_FWI) THEN
          clabu=iUNDEF
        ELSE
          IF(bui.ge.bucl(imo,5)) THEN
            clabu=6
          ELSE IF(bui.ge.0..and.bui.lt.bucl(imo,1)) THEN
            clabu=1
          ELSE
            DO ind=1,5
              IF(bui.ge.bucl(imo,ind).and.bui.lt.bucl(imo,ind+1)) THEN
                clabu=ind+1
              END IF
            END DO
          END IF
        END IF

!  assegnazione classi di fwi

        IF(fwi.eq.rSNOWCODE) THEN
          clafw=0
        ELSE IF(fwi.eq.rUNDEF_FWI) THEN
          clafw=iUNDEF
        ELSE
          IF(fwi.ge.fwcl(imo,5)) THEN
            clafw=6
          ELSE IF(fwi.ge.0..and.fwi.lt.fwcl(imo,1)) THEN
            clafw=1
          ELSE
            DO ind=1,5
              IF(fwi.ge.fwcl(imo,ind).and.fwi.lt.fwcl(imo,ind+1)) THEN
                clafw=ind+1
              END IF
            END DO
          END IF
        END IF

!  assegnazione classi di dsr (al momento non utilizzato)

        IF(dsr.eq.rSNOWCODE) THEN
          clads=0
        ELSE IF(dsr.eq.rUNDEF_FWI) THEN
          clads=iUNDEF
        ELSE
          IF(dsr.ge.dscl(imo,5)) THEN
            clads=6
          ELSE IF(dsr.ge.0..and.dsr.lt.dscl(imo,1)) THEN
            clads=1
          ELSE
            DO ind=1,5
              IF(dsr.ge.dscl(imo,ind).and.dsr.lt.dscl(imo,ind+1)) THEN
                clads=ind+1
              END IF
            END DO
          END IF
        END IF



!!   RG2020 cambio assegnazione indici

!!        iFWIind_class(ic,(iRIGok+1-ir),1)=clafm
!!        iFWIind_class(ic,(iRIGok+1-ir),2)=cladm
!!        iFWIind_class(ic,(iRIGok+1-ir),3)=cladc
!!        iFWIind_class(ic,(iRIGok+1-ir),4)=clais
!!        iFWIind_class(ic,(iRIGok+1-ir),5)=clabu
!!        iFWIind_class(ic,(iRIGok+1-ir),6)=clafw


        iFWIind_class(ir,ic,1)=clafm
        iFWIind_class(ir,ic,2)=cladm
        iFWIind_class(ir,ic,3)=cladc
        iFWIind_class(ir,ic,4)=clais
        iFWIind_class(ir,ic,5)=clabu
        iFWIind_class(ir,ic,6)=clafw


        clafm=iUNDEF
        cladm=iUNDEF
        cladc=iUNDEF
        clais=iUNDEF
        clabu=iUNDEF
        clafw=iUNDEF

! *********   fine ciclo sui punti di griglia   *******

      END DO
    END DO

! **********   SCRITTURA OUTPUT    ************

! file indici numerici del giorno corrente
!
! Esempio: ffmc_grezzi_$data.txt = matrice con i valori di ffmc calcolati per $data, (rUNDEF fuori regione e in caso di dati invalidi)
!                                  Tale file verra' trattato con GRASS per eliminare punti non bruciabili, punti innevati, punti con IDI bassi
!                                  e poi, tramite completamento con nearest neighbour in GRASS, originera' il file ffmc_$data.txt
!                                  N.B. tali valori sono calcolati usando il file ffmc_$data-1.txt ed i file temporanei (di indice e di neve) tramite
!                                       la sezione di "overwintering"
!! RG2020 cambio indici interni
    DO kk=1,6
      OPEN(unit=iFILO(kk),file=TRIM(sPATH1)//TRIM(sFILO(kk))//'grezzi_'//oggi//'.txt',status='unknown')
      WRITE(iFILO(kk),"(a5,1x,i3)") "ncols", iCOLok
      WRITE(iFILO(kk),"(a5,1x,i3)") "nrows", iRIGok
      WRITE(iFILO(kk),"(a9,1x,f11.3)") "xllcorner", rXLCORN
      WRITE(iFILO(kk),"(a9,1x,f11.3)") "yllcorner", rYLCORN
      WRITE(iFILO(kk),"(a8,1x,f8.3)") "cellsize", rCELLSIZE
      WRITE(iFILO(kk),"(a12,1x,f11.5)") "NODATA_value", rUNDEF_FWI

	  	  
      DO ir=1,iRIGok
!!        WRITE(iFILO(kk),"((1x,f11.5))") (rvFWIindexes(ic,(iRIGok+1-ir),kk), ic=1,iCOLok)
        WRITE(iFILO(kk),"(177(1x,f11.5))") (rvFWIindexes(ir,ic,kk), ic=1,iCOLok)
!!		  WRITE(iFILO(kk),*) (rvFWIindexes(ir,ic,kk), ic=1,iCOLok)
      END DO
      CLOSE(iFILO(kk))
    END DO

! file indici in classi del giorno corrente
!
! Esempio: ffmc_c_$data.txt = matrice con le classi di ffmc calcolate per $data, (rUNDEF fuori regione e in caso di dati invalidi)
!                             Tale file al momneto non viene utilizzato con GRASS per la produzione di mappe.
!                             N.B. tali valori sono calcolati classificando, mediante il file fwiclassi.ini, i valori ottenuti al punto precedente (ffmc_grezzi).

    DO kk=1,6
      OPEN(unit=iFILOC(kk),file=TRIM(sPATH1)//TRIM(sFILOC(kk))//oggi//'.txt',status='unknown')
      WRITE(iFILOC(kk),"(a5,1x,i3)") "ncols", iCOLok
      WRITE(iFILOC(kk),"(a5,1x,i3)") "nrows", iRIGok
      WRITE(iFILOC(kk),"(a9,1x,f11.3)") "xllcorner", rXLCORN
      WRITE(iFILOC(kk),"(a9,1x,f11.3)") "yllcorner", rYLCORN
      WRITE(iFILOC(kk),"(a8,1x,f8.3)") "cellsize", rCELLSIZE  
      WRITE(iFILOC(kk),"(a12,1x,i5)") "NODATA_value", iUNDEF
      DO ir=1,iRIGok
!!        WRITE(iFILOC(kk),"((1x,i5))") (iFWIind_class(ic,(iRIGok+1-ir),kk), ic=1,iCOLok)
        WRITE(iFILOC(kk),"(177(1x,i5))") (iFWIind_class(ir,ic,kk), ic=1,iCOLok)
      END DO
      CLOSE(iFILOC(kk))
    END DO

!  file idi complessivo del giorno corrente

    OPEN(unit=99,file=TRIM(sPATH2)//"IDI_comune_"//oggi//".txt",status='unknown')
    WRITE(99,"(a5,1x,i3)") "ncols", iCOLok
    WRITE(99,"(a5,1x,i3)") "nrows", iRIGok
    WRITE(99,"(a9,1x,f11.3)") "xllcorner", rXLCORN
    WRITE(99,"(a9,1x,f11.3)") "yllcorner", rYLCORN
    WRITE(99,"(a8,1x,f8.3)") "cellsize", rCELLSIZE
    WRITE(99,"(a12,1x,i5)") "NODATA_value", iUNDEF
    DO ir=1,iRIGok
      WRITE(99,"(177(1x,i5))") (iditot(ir,ic), ic=1,iCOLok)
    END DO
    CLOSE(99)

! file indici temporanei e precipitazioni totali cumulate temporanee: per trattamento "neve al suolo".

    DO kk=1,3
      OPEN(unit=iFILOT(kk),file=TRIM(sPATH1)//TRIM(sFILIT(kk))//oggi//'.txt',status='unknown')
      WRITE(iFILOT(kk),"(a5,1x,i3)") "ncols", iCOLok
      WRITE(iFILOT(kk),"(a5,1x,i3)") "nrows", iRIGok
      WRITE(iFILOT(kk),"(a9,1x,f11.3)") "xllcorner", rXLCORN
      WRITE(iFILOT(kk),"(a9,1x,f11.3)") "yllcorner", rYLCORN
      WRITE(iFILOT(kk),"(a8,1x,f8.3)") "cellsize", rCELLSIZE
      WRITE(iFILOT(kk),"(a12,1x,f11.5)") "NODATA_value", rNODATA
      DO ir=1,iRIGok
        WRITE(iFILOT(kk),"(177(1x,f11.5))") (ind_tmp(ir,ic,kk), ic=1,iCOLok)
      END DO
      CLOSE(iFILOT(kk))
    END DO

    OPEN(unit=94,file=TRIM(sPATH2)//"raincum_tmp_"//oggi//'.txt',status='unknown')
    WRITE(94,"(a5,1x,i3)") "ncols", iCOLok
    WRITE(94,"(a5,1x,i3)") "nrows", iRIGok
    WRITE(94,"(a9,1x,f11.3)") "xllcorner", rXLCORN
    WRITE(94,"(a9,1x,f11.3)") "yllcorner", rYLCORN
    WRITE(94,"(a8,1x,f8.3)") "cellsize", rCELLSIZE  
    WRITE(94,"(a12,1x,f7.1)") "NODATA_value", rUNDEF
    DO ir=1,iRIGok
      WRITE(94,"(177(1x,f7.1))") (raincum(ir,ic), ic=1,iCOLok)
    END DO
    CLOSE(94)

!  file dati meteo in input (per plottaggio mappe con GRASS) 
!  temperatura

    OPEN(unit=122,file=TRIM(sPATH2)//"t_"//oggi//".txt",status='unknown')
    WRITE(122,"(a5,1x,i3)") "ncols", iCOLok
    WRITE(122,"(a5,1x,i3)") "nrows", iRIGok
    WRITE(122,"(a9,1x,f11.3)") "xllcorner", rXLCORN
    WRITE(122,"(a9,1x,f11.3)") "yllcorner", rYLCORN
    WRITE(122,"(a8,1x,f8.3)") "cellsize", rCELLSIZE  
    WRITE(122,"(a12,1x,f7.1)") "NODATA_value", rUNDEF_TEMP
    DO ir=1,iRIGok
!!      WRITE(122,"((1x,f7.1))") (rvTEMP_ANA_GRID(ic,(iRIGok+1-ir)), ic=1,iCOLok)
      WRITE(122,"(177(1x,f7.1))") (rvTEMP_ANA_GRID(ir,ic), ic=1,iCOLok)
    END DO
    CLOSE(122)

!  umidita' relativa

    OPEN(unit=123,file=TRIM(sPATH2)//"ur_"//oggi//".txt",status='unknown')
    WRITE(123,"(a5,1x,i3)") "ncols", iCOLok
    WRITE(123,"(a5,1x,i3)") "nrows", iRIGok
    WRITE(123,"(a9,1x,f11.3)") "xllcorner", rXLCORN
    WRITE(123,"(a9,1x,f11.3)") "yllcorner", rYLCORN
    WRITE(123,"(a8,1x,f8.3)") "cellsize", rCELLSIZE  
    WRITE(123,"(a12,1x,f7.1)") "NODATA_value", rUNDEF_RELH
    DO ir=1,iRIGok
!! 	    WRITE(123,"((1x,f7.1))") (rvRELH_ANA_GRID(ic,(iRIGok+1-ir)), ic=1,iCOLok)
      WRITE(123,"(177(1x,f7.1))") (rvRELH_ANA_GRID(ir,ic), ic=1,iCOLok)
    END DO
    CLOSE(123)

!  velocita' vento

    OPEN(unit=124,file=TRIM(sPATH2)//"ws_"//oggi//".txt",status='unknown')
    WRITE(124,"(a5,1x,i3)") "ncols", iCOLok
    WRITE(124,"(a5,1x,i3)") "nrows", iRIGok
    WRITE(124,"(a9,1x,f11.3)") "xllcorner", rXLCORN
    WRITE(124,"(a9,1x,f11.3)") "yllcorner", rYLCORN
    WRITE(124,"(a8,1x,f8.3)") "cellsize", rCELLSIZE  
    WRITE(124,"(a12,1x,f7.1)") "NODATA_value", rUNDEF_WIND
    DO ir=1,iRIGok
      WRITE(124,"(177(1x,f7.1))") (ws(ir,ic), ic=1,iCOLok)
    END DO
    CLOSE(124)

!  Precipitazioni totali

    OPEN(unit=125,file=TRIM(sPATH2)//"prec24_"//oggi//".txt",status='unknown')
    WRITE(125,"(a5,1x,i3)") "ncols", iCOLok
    WRITE(125,"(a5,1x,i3)") "nrows", iRIGok
    WRITE(125,"(a9,1x,f11.3)") "xllcorner", rXLCORN
    WRITE(125,"(a9,1x,f11.3)") "yllcorner", rYLCORN
    WRITE(125,"(a8,1x,f8.3)") "cellsize", rCELLSIZE  
    WRITE(125,"(a12,1x,f7.1)") "NODATA_value", rUNDEF_PIOG
    DO ir=1,iRIGok
      WRITE(125,"(177(1x,f7.1))") (rvPIOG24_ANA_GRID(ir,ic), ic=1,iCOLok)
    END DO
    CLOSE(125)

! considero solo i punti in Lombardia (e tolgo anche "punti_nometeo") nei file di "periodo innevamento" e "codice scioglimento" 

    DO ir=1,iRIGok
      DO ic=1,iCOLok
        IF(ilomb(ir,ic).eq.iUNDEF) THEN
          isciolgo(ir,ic)=rUNDEF
	      isnowper(ir,ic)=rUNDEF
	    END IF
        DO ll=1,npunti
          IF(ir.eq.coord(1,ll).and.ic.eq.coord(2,ll)) THEN
    	    isciolgo(ir,ic)=rUNDEF
	        isnowper(ir,ic)=rUNDEF
          END IF
        END DO
      END DO
    END DO	
	
!  file "periodo innevamento" del giorno corrente

    OPEN(unit=78,file=TRIM(sPATH2)//"snowper_"//oggi//".txt",status='unknown')
    WRITE(78,"(a5,1x,i3)") "ncols", iCOLok
    WRITE(78,"(a5,1x,i3)") "nrows", iRIGok
    WRITE(78,"(a9,1x,f11.3)") "xllcorner", rXLCORN
    WRITE(78,"(a9,1x,f11.3)") "yllcorner", rYLCORN
    WRITE(78,"(a8,1x,f8.3)") "cellsize", rCELLSIZE
    WRITE(78,"(a12,1x,i5)") "NODATA_value", iUNDEF
    DO ir=1,iRIGok
      WRITE(78,"(177(1x,i5))") (isnowper(ir,ic), ic=1,iCOLok)
    END DO
    CLOSE(78)

!  file "codice scioglimento" del giorno corrente

    OPEN(unit=79,file=TRIM(sPATH2)//"isciolgo_"//oggi//".txt",status='unknown')
    WRITE(79,"(a5,1x,i3)") "ncols", iCOLok
    WRITE(79,"(a5,1x,i3)") "nrows", iRIGok
    WRITE(79,"(a9,1x,f11.3)") "xllcorner", rXLCORN
    WRITE(79,"(a9,1x,f11.3)") "yllcorner", rYLCORN
    WRITE(79,"(a8,1x,f8.3)") "cellsize", rCELLSIZE
    WRITE(79,"(a12,1x,i5)") "NODATA_value", iUNDEF
    DO ir=1,iRIGok
      WRITE(79,"(177(1x,i5))") (isciolgo(ir,ic), ic=1,iCOLok)
    END DO
    CLOSE(79)


! **********   FINE SCRITTURA OUTPUT    ************

    IF(inorm.eq.0) THEN
      WRITE(14,*) 
      WRITE(14,*) iYYYY1,iMMM1,iDD1,iHH1," Giorno elaborato senza errori"
      WRITE(*,*) iYYYY1,iMMM1,iDD1,iHH1," Giorno elaborato senza errori"
    ELSE
      WRITE(14,*) 
      WRITE(14,*) iYYYY1,iMMM1,iDD1,iHH1," Giorno elaborato con errori"
	  write(*,*)  it
      WRITE(*,*)  iYYYY1,iMMM1,iDD1,iHH1," Giorno elaborato con errari"
	  write(*,*)  it
      inorm=0
    END IF

    idi=1
    CLOSE(13) 
    CLOSE(14)
!  DA FARE

!  problema dell'arrotondamento in output: tronco o arrotondare

!  aggiungere subroutine di Carr sul calcolo della daylenght
!  verificare l'utilizzo del dato di latitudine

!  Carr ha modificato l'eq.ne 20 (da van Wagner 87)

!  completare la lettura del file di Carr per eventuali altri suggerimenti

! inserire routine per calcolo data dalla data di sistema
! (verificare in Pf95 se c'e' libreria con DATE)

! trasferire parte di calcolo in subroutine; anche parte di assegnazione classi

! rendere allocatable ind_tmp
! attenzione: ho posto io bui > 0. Nel codice non c'era???
! aTTWNZIONW: in caso di scrittura su file esistente, cosa ne e' dei record eventualmente non
! sovrascritti? la cosa e' diversa tra acceso diretto e sequenziale?? se cosi' fosse bisogna sinceraris
! di cancellare vecchi file primna di scrivere

! chiarire: va bene l'uso dei sottoindici deid efalut per l'inizializzazione in cadso di sottindici=-999?
! fine parte di RG
!------------------------------------------------------------------------------
! 
!  Righe seguenti, con !!, commentate RG luglio 2020 *************************************************************
!
! [8.2.6] Re-initialize matrices with variables related to 24h cumulated 
!    precipitation field
    rvPIOG24_ANA_GRID=0.
    rvPIOG24_IDId_GRID=0.
    rvPIOG24_IDIw_GRID=0.
! [8.2.7] Write Output
!!    IF ( ASSOCIATED(ivVLEVS_TMP) ) DEALLOCATE(ivVLEVS_TMP)
!!    IF ( ASSOCIATED(rvDATA_TMP) ) DEALLOCATE(rvDATA_TMP)
!!    NULLIFY(ivVLEVS_TMP)
!!    NULLIFY(rvDATA_TMP)
!!    ALLOCATE(ivVLEVS_TMP(iNVARS_FWI),STAT=iRetCode)
!!    IF (iRetCode/=0) THEN
!!      PRINT *,'fwigrid: Error allocating ivVLEVS_TMP'
!!      STOP 1
!!    ENDIF
!!    ivVLEVS_TMP=0
!!    iNVARS_LD_TMP=0
!!    CALL WriteDAT_GRD( 31, rvFWIindexes, rvDATA_TMP,        &
!!                       iNX, iNY, 1, iNVARS_FWI, iNVARS_LD_TMP,  &
!!                       iNVARS_FWI, ivVLEVS_TMP, lOKflag )
!!    IF (.not.lOKflag) THEN
!!      WRITE(6,"(A,I7,A,A)",IOSTAT=iRetCode) 'fwigrid: error at timestep ',it, &
!!       ' routine WriteDAT_GRD - DAT file: ', TRIM(sDAT_FWI)
!!      STOP 1
!!    ENDIF
!!    IF ( ASSOCIATED(ivVLEVS_TMP) ) DEALLOCATE(ivVLEVS_TMP)
!!    NULLIFY(ivVLEVS_TMP)
	
!  Righe precedenti, con !!, commentate RG luglio 2020 *************************************************************
!-------------------------------------------------------------------------------
  END DO                                           ! I -> Very Main cycle END
!-------------------------------------------------------------------------------
! [8.3] close files with timesteps information

!!  CLOSE(101)
!!  CLOSE(111)
!!  CLOSE(121)
!!  CLOSE(131)
!!  CLOSE(18)
!!  CLOSE(19)
!!  CLOSE(20)
!!  CLOSE(21)
!!  CLOSE(22)
!!  CLOSE(31)


!!  Righe seguenti, con !!, commentate RG luglio 2020 *************************************************************

!===============================================================================
! [9] Write CTL output GRIDDED file for hourly fields
!===============================================================================
!!  IF ( ASSOCIATED(ivVLEVS_TMP) ) DEALLOCATE(ivVLEVS_TMP)
!!  NULLIFY(ivVLEVS_TMP)
!!  ALLOCATE(ivVLEVS_TMP(iNVARS_FWI), STAT=iRetCode)
!!  IF (iRetCode/=0) THEN
!!    PRINT *,'fwigrid: error in dynamic memory allocation ivVLEVS_TMP'
!!    STOP 1
!!  ENDIF
!!  ivVLEVS_TMP=0
!!  inc_mm=.FALSE.
!!  inc_hr=.FALSE.
!!  inc_dy=.TRUE.
!!  inc_mo=.FALSE.
!!  inc_yr=.FALSE.
!!  CALL WriteCTL_GRD( sCTL_FWI, sDAT_FWI, sTITLE_FWI, rUNDEF_FWI,     &
!!                     iNX, dXstart, dDX,                              &
!!                     iNY, dYstart, dDY,                              &
!!                     1 , 1., 1., rvZLEVS_TMP,                        &
!!                     iNTIM_FWI, iTINC_FWI, iHH_FWI, 0,               &
!!                     iDD_FWI, iMMM_FWI, iYYYY_FWI,                   &
!!                     iNVARS_FWI,                                     &
!!                     svABRV_FWI, svDSCR_FWI, ivVLEVS_TMP,            &
!!                     inc_mm, inc_hr, inc_dy, inc_mo, inc_yr,         &
!!                     lOKflag )
!!  IF (.not.lOKflag) THEN
!!    PRINT *,'fwigrid: Error in WriteCTL_GRD, file CTL = ',TRIM(sCTL_FWI)
!!    STOP 1
!!  ENDIF
! Tidy Up
!!  IF ( ASSOCIATED(ivVLEVS_TMP) ) DEALLOCATE(ivVLEVS_TMP)
!!  NULLIFY(ivVLEVS_TMP)
!===============================================================================
! [9] Tidy up and exit
!===============================================================================
!!  IF ( ASSOCIATED(svABRV_TMP)   )  DEALLOCATE(svABRV_TMP)
!!  IF ( ASSOCIATED(svDSCR_TMP)   )  DEALLOCATE(svDSCR_TMP)
!!  IF ( ASSOCIATED(ivVLEVS_TMP) )  DEALLOCATE(ivVLEVS_TMP)
!!  IF ( ASSOCIATED(rvZLEVS_TMP) ) DEALLOCATE(rvZLEVS_TMP)
!!  IF ( ASSOCIATED(rvDATA_SFC_ORO) ) DEALLOCATE(rvDATA_SFC_ORO) 
!!  IF ( ASSOCIATED(rvDATA_SFC_TMP) ) DEALLOCATE(rvDATA_SFC_TMP) 
!!  IF ( ASSOCIATED(rvDATA_TMP) ) DEALLOCATE(rvDATA_TMP) 
    IF ( ASSOCIATED(rvFWIindexes) ) DEALLOCATE(rvFWIindexes) 
	IF ( ASSOCIATED(iFWIind_class) ) DEALLOCATE(iFWIind_class) 


!!  NULLIFY( svABRV_TMP )
!!  NULLIFY( svDSCR_TMP )
!!  NULLIFY( ivVLEVS_TMP )
!!  NULLIFY( rvZLEVS_TMP )
!!  NULLIFY(rvDATA_SFC_ORO) 
!!  NULLIFY(rvDATA_SFC_TMP) 
!!  NULLIFY(rvDATA_TMP) 
    NULLIFY(rvFWIindexes) 
    NULLIFY(iFWIind_class) 

!!  Righe precedenti, con !!, commentate RG luglio 2020 *************************************************************

  STOP 0
END PROGRAM fwigrid_ana
!###############################################################################
