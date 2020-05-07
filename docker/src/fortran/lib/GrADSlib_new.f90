!+ GrADS files management
MODULE GrADSlib_new
!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
! Description:
! GrADS (Grid Analisys Display System) e' disponibile in forma gratuita presso
! http://grads.iges.org/grads/grads.html (documentazione compresa).
! Questo modulo gestisce la lettura/scrittura dei file .CTL e .DAT.
!
! Method:
! -------- DATI su GRIGLIE [GRD] --------
!
! * formato files .CTL supportato da "GrADSlib_new" *
! DSET
! TITLE
! UNDEF
! XDEF n� LINEAR start increment
! YDEF n� LINEAR start increment
! [ZDEF n� LINEAR start increment]
! [ZDEF n� LEVELS ordine decrescente livelli di pressione]
! TDEF n� LINEAR start increment
! VARS n�
! ID(12 car) levs units DESCR(40 car)
! ..........
! ENDVARS
!
! N.B. I campi specificati devono essere scritti in caratteri maiuscoli!
!
! IPOTESI sul formato dei files CTL:
! - XDEF ... LINEAR (no LEVELS). Inoltre "start" e "increment" sono REAL(8);
! - YDEF ... LINEAR (no LEVELS, no GAUSS...). Inoltre "start" e "increment"
!   sono REAL(8);
! - (1) ZDEF ... LINEAR     o    (2) ZDEFS ... LEVELS ...
!   "start", "increment" sono REAL(8) - i livelli di pressione sono REAL
! - compresenza nel medesimo files di griglie di superficie e su pi? livelli
! - non gestisco campo "OPTIONS"
! - ZDEF: il numero massimo di livelli verticali specificabili in ZDEF sta in
!   iMAXZLEVS;
!
! OSSERAZIONI:
! - DSET: e' possibile inserire il carattere "^" per indicare che il file .DAT
!   ha lo stesso path del file .CTL;
! - TITLE: il titolo di un file .CTL viene visualizzato quando si fa una "query"
!   da GrADS;
! - UNDEF: questo campo deve essere sempre presente, anche se non ho dati
!   con valore indefinito (tipo REAL);
! - le linee bianche dopo "ENDVARS" potrebbero non far aprire il file .CTL
! - in ZDEF si ipotizza di avere i livelli di pressione
! - TDEF ... solo LINEAR
! - start time string "hh:mmZddmmmyyy"
! - per i campi VARS -> levs=0 SFC VAR, levs/=0 n� di livelli su cui e' presente
!   la variabile (si noti che levs=2 significa che la variabile e' presente sui
!   PRIMI due livelli specificati in ZDEF)
! - per i campi VARS -> units: usato solo nei grib, per il resto porre = 99.
! - La lunghezza delle righe di GrADS non supera i 255 caratteri
!
! * formato files .DAT *
! file binario con record di tipo REAL, in questo file sono presenti tutte le
! griglie specificate all'interno del file CTL. Ciascun record rappresenta il
! valore al nodo di ciascuna griglia. Le griglie si presentano con il seguente
! ordine (esempio con due variabili "slp" di tipo SFC e "geop" di tipo LD sui
! livelli 1000, 500, 300):
! - Time 1, Level SFC, variable "slp"
! - Time 1, Level 1000, variable
! - Time 1, Level 500, variable
! - Time 1, Level 300, variable
! - Time 2, Level SFC, variable "slp"
! - Time 2, Level 1000, variable
! - Time 2, Level 500, variable
! - Time 2, Level 300, variable
! .............................
!
! ciascuna griglia e' identificata da due coordinata: X, che varia da ovest verso
! est, e Y che varia da sud verso nord. Una griglia di 3x3 avr? quindi i nodi
! indicizzati cos? (Y,X):
!  Y ^
!    |  (3,1)(3,2)(3,3)
!    |  (2,1)(2,2)(2,3)
!    |  (1,1)(1,2)(1,3)
!   -|-------------------> X
! L'ordine di scrittura e' il seguente:
! (1,1)(1,2)(1,3)(2,1)(2,2)(2,3)(3,1)(3,2)(3,3)
!
! * strutture dati utilizzate *
! La lettura e la scrittura di files .CTL e .DAT si riduce alla lettura/
! scrittura di strutture di memoria in maniera predefinita. La mia scelta
! principale per le strutture dati e' questa:
!
! LE STRUTTURE DATI NON DEVONO CONTENERE LA DIMENSIONE TEMPO
!
! Per i file di tipo GRD le strutture dati scelte per contenere le misure
! sono:
! (1) dati superficie (levs=0)
!     3D(i,j,vs)   -> i=[1,iNX]; j=[1,iNY]; vs=[1,iNVARS_SFC]
!     REAL,    pointer      :: rvDATA_SFC(:,:,:)
! (2) pi? livelli (levs/=0)
!     4D(i,j,k,vl) -> i=[1,iNX]; j=[1,iNY]; k=[1,iNZ]; vl=[1,iNVARS_LD]
!     REAL,    pointer      :: rvDATA_LD(:,:,:,:)
!     N.B. k=1 -> livello pi? vicino al suolo
!
! Le routine di lettura/scrittura vanno a riempire queste strutture per un
! tempo nuovo ad ogni chiamata delle stesse.
!
! * osservazione finale: "ReadVXYZ_GRD" *
! Esiste l'opportunit? tramite la routine "ReadVXYZ_GRD" di ottenere un
! vettore unidimensionale contenete la serie temporale di una variabile
! nel nodo di coordinate (X,Y) sul livello verticale Z (numero del livello
! in ordine progressivo: Z=1 -> livello pi? basso / Z=iNZ -> livello pi?
! alto).
!
!
! -------- DATI da STAZIONI (superficiali e di profilo) [STN] --------
!
! * formato files .CTL supportato da "GrADSlib_new" *
! DSET
! DTYPE STATION
! TITLE
! STNMAP
! UNDEF
! TDEF n� LINEAR start increment
! VARS n�
! ID(12 car) levs units DESCR(40 car)
! ..........
! ENDVARS
!
! N.B. I campi specificati devono essere scritti in caratteri maiuscoli!
!
! IPOTESI sul formato dei files CTL:
! - compresenza nel medesimo files di dati di stazioni al suolo (stazioni
!   di tipo "superficiali", in breve SFC) e di dati di stazioni di profilo
!   (es.: termosondaggi, SODAR/RASS) (stazioni di tipo "level dependent",
!   in breve LD);
! - non gestisco campo "OPTIONS"
! - il numero massimo di stazioni che possono essere presenti per ciascun
!   istante temporale e' fissato nel parametro iMAXSTN;
!
! OSSERAZIONI:
! - DSET: e' possibile inserire il carattere "^" per indicare che il file .DAT
!   ha lo stesso path del file .CTL;
! - STNMAP: e' possibile inserire il carattere "^" per indicare che il file .MAP
!   ha lo stesso path del file .CTL;
! - TITLE: il titolo di un file .CTL viene visualizzato quando si fa una "query"
!   da GrADS;
! - UNDEF: questo campo deve essere sempre presente, anche se non ho dati
!   con valore indefinito (tipo REAL);
! - le linee bianche dopo "ENDVARS" potrebbero non far aprire il file .CTL
! - per una varibile LD e' possibile specificare livelli crescenti, ad esempio
!   per la variabile "temperatura" di un RASS e' possibile specificare la quota
!   di misura in metri come livello all'interno del file .DAT;
! - TDEF ... solo LINEAR
! - start time string "hh:mmZddmmmyyy"
! - per i campi VARS -> levs=0  variabile di tipo SFC
!                       levs/=0 variabile di tipo LD
!  (N.B. il numero che compare in levs non ha alcuna attinenza con i livelli
!   verticali della varibile, questi saranno specificati nel file .DAT e a
!   priori saranno diversi per ogni stazione);
! - IMPORTANTE: vanno specificati prima tutte le varibili SFC (levs=0) e solo
!   dopo le varibili LD (levs/=0). Questa sezione viene di fatto divisa in due
!   gruppi di variabili uno con tutte le variabili SFc e uno con tutte le
!   variabili LD;
! - per i campi VARS -> units: usato solo nei grib, per il resto porre = 99.
! - La lunghezza delle righe di GrADS non supera i 255 caratteri
!
! * formato files .DAT *
! file binario con divisione per tempo come nel formato GRD. All'interno di
! ciascun istante temporale possono comparire un numero qualsiasi (in questa
! libreria, al massimo iMAXSTN) di report, uno per ogni stazione.
! Il formato di uno "station report" e' il seguente:
! - Un header che fornisce fra l'altro le informazioni sulla posizione
!   della stazione;
! - variabili SFC, se presenti;
! - variabili LD, se presenti;
! L'header e' descrivibile con i primi sei campi della struttura dati "StazData":
!  TYPE StazData
!    CHARACTER(8)   :: ID             ! Character station ID
!    REAL           :: X              ! Latitude of report
!    REAL           :: Y              ! Longitude of report
!    REAL           :: t              ! Time in relative grid units
!    INTEGER        :: NLEV           ! Number of levels following
!    INTEGER        :: FLAG           ! Level indipendent var set flag
!    REAL, pointer  :: SFC_VARS(:)    ! Values of SFC variables
!    REAL, pointer  :: LD_VARS(:,:)   ! Values of LD variables
!  END TYPE
! Concentriamo la nostra attenzione sui campi NLEV e FLAG.
! - FLAG=0 -> nessuna varibile di tipo SFC e' contenuta nello station report;
! - FLAG=1 -> il gruppo di varibili di tipo SFC sara' specificato per questo
! station report;
! - NLEV -> numero di gruppi di variabili che seguiranno l'header. Questo numero
! comprendera' anche il gruppo delle variabili superficiali, qualora presenti
! (FLAG=1). Se NLEV=0 allora l'header perde il proprio significato originale
! e diventa una marca temporale di "fine tempo corrente e inizio istante
! temporale successivo". Esempio: supponiamo di aver NLEV=4 e FLAG=1. Allora mi
! aspettero' di avere subito dopo l'header il gruppo delle variabili di superficie
! seguito da il gruppo delle variabili LD ripetuto tre volte, a tre livelli
! verticali diversi.
! I gruppi LD sono strutturati nel seguente formato:
! "level"      - REAL che da la dimensione Z per il gruppo LD;
! "variabili"  - REAL il gruppo LD specificato nel file .CTL, con i valori che
!                assume in questo livello verticale.
!
!
! * strutture dati utilizzate *
! La lettura e la scrittura di files .CTL e .DAT si riduce alla lettura/
! scrittura di strutture di memoria in maniera predefinita. La mia scelta
! principale per le strutture dati e' questa:
!
! LE STRUTTURE DATI NON DEVONO CONTENERE LA DIMENSIONE TEMPO
!
! Per i file di tipo STN le strutture dati scelte per contenere le misure
! sono gli ultimi due campi del tipo "StazData":
! (1) Valori delle variabili SFC
!     1D(vs), vs=[1,iNVARS_SFC]
!     REAL, pointer  :: SFC_VARS(:)
! (2) Valori delle variabili LD
!     2D(vl,m), vl=[1,iNVARS_LD+1], m=[1,iNLEV-iFLAG]
!     REAL, pointer  :: LD_VARS(:,:)
!     "m" conta il numero di gruppi LD, uno per ciascun livello specificato.
!     "vl=1" contiene il valore Z del livello.
!
! Le routine di lettura/scrittura vanno a riempire queste strutture per un
! tempo nuovo ad ogni chiamata delle stesse.
!
! * osservazione finale: "ReadSVL_STN" *
! Esiste l'opportunit? tramite la routine "ReadSVL_STN" di ottenere un
! vettore unidimensionale contenete la serie temporale di una stazione, per
! una variabile ad un determinato livello (o alla superficie).
!
!
! ------------- ELENCO VARIABILI UTILIZZATE: ----------------------------
! Riportiamo di seguito un elenco dei nomi delle variabili pi? comunemente
! utilizzate e un breve commento sulle stesse (escluse le variabili utilizzate
! nelle routines "ReadVXYZ_GRD" e "ReadSVL_STN" che sono riportate all'interno
! delle rispettive routines):
! (note: (1) il primo carattere del nome della variabile indica il tipo di
!  variabile "s"->CHARACTER; "i"->INTEGER; "r"->REAL(4); "d"->DOUBLE;
!  "t"->struttura dati non standard; "l"->LOGICAL. Se poi la struttura
!  dati e' un vettore allora il secondo carattere e' una "v".
!        (2) dopo il commento pu? apparire la dicitura "[STN]" o "[GRD]" e
!  sta a significare che la variabile e' utilizzata per il tipo di dati
!  "Station" o "Gridded", rispettivamente. Qualora non vi sia nulla,
!  significa che la variabile e' utilizzata per entrambi.)
!
! sNameCTL   - nome del file .CTL
! sNameDAT   - nome del file .DAT
! sNameMAP   - nome del file .MAP [STN]
! rUNDEF     - valore numerico che rappresenta il non-numero di
!              "valore non definito"
! iNX        - numero di celle lungo la coordinata orizzontale X [GRD]
! iNY        - numero di celle lungo la coordinata orizzontale Y [GRD]
! iNZ        - numero di livelli lungo la coordinata verticale Z [GRD]
! dXstart    - coordinata X del NODO (1,1) (pi? in basso a sinistra) della
!              griglia specificata (ribadisco: NODO e NON angolo inferiore
!              cella in basso a sinistra). Valore di X=1 [GRD]
! dYstart    - coordinata Y del NODO (1,1) (pi? in basso a sinistra) della
!              griglia specificata (ribadisco: NODO e NON angolo inferiore
!              cella in basso a sinistra). Valore di Y=1 [GRD]
! dZstart    - valore di Z=1 [GRD]
! dDX        - Passo di griglia lungo asse X [GRD]
! dDY        - Passo di griglia lungo asse Y [GRD]
! dDZ        - Distanza fra i livelli lungo asse Z [GRD]
! iNTIM      - Numero di istanti temporali presenti nel file
! iTINC      - Incremento temporale
! inc_mm     - TRUE -> unit? di misura di "iTINC" sono i minuti
! inc_hr     - TRUE -> unit? di misura di "iTINC" sono le ore
! inc_dy     - TRUE -> unit? di misura di "iTINC" sono i giorni
! inc_mo     - TRUE -> unit? di misura di "iTINC" sono i mesi
! inc_yr     - TRUE -> unit? di misura di "iTINC" sono gli anni
! iHH        - ora del primo istante temporale (T=1) presente nel file
! iMM        - minuti del primo istante temporale (T=1) presente nel file
! iDD        - giorno del primo istante temporale (T=1) presente nel file
! iMMM       - mese del primo istante temporale (T=1) presente nel file
! iYYYY      - anno del primo istante temporale (T=1) presente nel file
! iNVARS     - numero di variabili contenute nel file GrADS
!              (specificate nella sezione "VARS"). Si noti che
!              iNVARS = iNVARS_SFC + iNVARS_LD
! iNVARS_SFC - numero di varibili di tipo "superficie"
! iNVARS_LD  - numero di variabili di tipo "level dependent"
! iNSTAT     - numero di stazioni presenti nel file all'istante temporale
!              corrente. Si noti che iNSTAT = iNSTAT_SFC + iNSTAT_LD [STN]
! iNSTAT_SFC - numero di stazioni di tipo "superficie" [STN]
! iNSTAT_LD  - numero di stazioni di tipo "level dependent" [STN]
! iDebug     - = 1 stampa a video info di debug; /=1 non stampa
! iLUN       - Logical Unit Number del file binario dal quale leggere/scrivere
!              dati
! lOKflag    - TRUE = subroutine eseguita con successo ; FALSE = problemi
! svABRV     - etichette idenficative per ciascuna grandezza definita nella
!              sezione "VARS". Questo vettorte viene allocato all'interno delle
!              due subroutine di lettura "ReadCTL_GRD" e "ReadCTL_STN".
!              Dimensioni: svABRV(v) v=[1,iNVARS], ciascun identificativo e'
!              una stringa di 12 caratteri.
! svDSCR     - descrizione per ciascuna grandezza definita nella
!              sezione "VARS". Questo vettorte viene allocato all'interno delle
!              due subroutine di lettura "ReadCTL_GRD" e "ReadCTL_STN".
!              Dimensioni: svDSCR(v) v=[1,iNVARS], ciascuna descrizione e'
!              una stringa di 40 caratteri.
! rvZLEVS    - etichette (valori) degli "iNZ" livelli verticali. Questo vettore
!              viene allocato all'interno della subroutine di lettura
!              "ReadCTL_GRD". Dimensione: rvZLEVS(k) k=[1,iNZ] [GRD]
! ivVLEVS    - campo "levs" del .CTL per ogni variabile definita nella
!              sezione "VARS". Il significato del campo varia a seconda del
!              fatto che si abbia a che fare con dati STN o GRD (vedi manuale).
!              Questo vettore viene allocato all'interno delle
!              due subroutine di lettura "ReadCTL_GRD" e "ReadCTL_STN".
!              Dimensioni: ivVLEVS(v) v=[1,iNVARS]
! rvDATA_SFC - dati che riguardano la superficie. Deallocata/Allocata nella
!              subroutine "ReadDAT_GRD". Dimensioni:
!              rvDATA_SFC(i,j,vs) i=[1,iNX]; j=[1,iNY]; vs=[1,iNVARS_SFC] [GRD]
! rvDATA_LD  - dati su pi? livelli. Deallocata/Allocata nella
!              subroutine "ReadDAT_GRD". Dimensioni:
!              rvDATA_SFC(i,j,k,vl) i=[1,iNX]; j=[1,iNY]; k=[1,iNZ];
!              vl=[1,iNVARS_LD] [GRD]
! tvSTN      -
!
! Parametri:
!
! iMAXZLEVS  - Numero massimo consentito di livelli verticali
! iMAXSTN    - Numero massimo consentito di stazioni
!
!
!
! History:
! VERSIONE    DATA    COMMENTO
! --------  --------  --------
! 1.0       24/07/05  C.Lussana - Versione originale. Testata con il programma
!                     "prova_gradslib_new".
! 1.0       02/08/05  C.Lussana. Corretto baco nella lettura di "sNameDAT" in
!                     ReadCTL...
! 1.0       03/08/05  C.Lussana. Aggiunta "NameCTL2MAP"
! 1.0       09/08/05  C.L. Corretto baco trovato in "ReadDAT_STN" e
!                     "WriteDAT_STN". Nell'header del file DAT per ogni stazione
!                     va scritto prima Y (Lat) e poi X (Lon). Prima facevo il
!                     contrario.
! 1.0       17/08/05  C.L. Commentato "DEALLOCATE" nella routine "GrADSfreeStn"
!                     dava noia ad una applicazione ma non so bene perch�.
!                     Indagher� sulla faccenda
! 1.0       17/08/05  C.L. Corretto baco sulla lettura di "iTINC" nelle routine
!                     "ReadCTL_STN" e "ReadCTL_GRD"
!
! 1.0       15/09/05 C.L. Corretta imprecisione sulla scrittura dell'incremento
!                    temporale nel caso di inc_mm=TRUE ("mm"/"MM" ->"mn"/"MN")
!
! Code description:
! Language: Fortran 90
! Software standards: "European Standards for Writing and
!                      Documenting Exchangeable Fortran 90 Code"
!
!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  IMPLICIT NONE

  INTEGER, parameter        :: iMAXZLEVS = 1500
  INTEGER, parameter        :: iMAXSTN   = 800

! -- STRUTTURE DATI --

  TYPE StazData
    CHARACTER(8)             :: ID             ! Character station ID
    REAL                     :: X              ! Latitude of report
    REAL                     :: Y              ! Longitude of report
    REAL                     :: t              ! Time in relative grid units
    INTEGER                  :: NLEV           ! Number of levels following
    INTEGER                  :: FLAG           ! Level indipendent var set flag
    REAL, pointer            :: SFC_VARS(:)    ! Values of SFC variables
    REAL, pointer            :: LD_VARS(:,:)   ! Values of LD variables
  END TYPE

! --  ROUTINES  --
  PUBLIC :: ReadCTL_GRD
  PUBLIC :: ReadDAT_GRD
  PUBLIC :: WriteCTL_GRD
  PUBLIC :: WriteDAT_GRD
  PUBLIC :: ReadVXYZ_GRD
  PUBLIC :: ReadCTL_STN
  PUBLIC :: ReadDAT_STN
  PUBLIC :: WriteCTL_STN
  PUBLIC :: WriteDAT_STN
  PUBLIC :: ReadSVL_STN
  PUBLIC :: GrADSfreeStn
  PUBLIC :: GrADSallocStn
  PUBLIC :: NameCTL2DAT
  PUBLIC :: NameCTL2MAP

CONTAINS

!==============================================================================
!                          G R I D D E D     D A T A
!==============================================================================

!+ Lettura del file .CTL - dati su griglie - leggo un tempo per volta
!------------------------------------------------------------------------------
SUBROUTINE ReadCTL_GRD( sNameCTL, sNameDAT, rUNDEF,                 &
                        iNX, dXstart, dDX,                          &
                        iNY, dYstart, dDY,                          &
                        iNZ, rZstart, rDZ, rvZLEVS,                 &
                        iNTIM, iTINC, iHH, iMM, iDD, iMMM, iYYYY,   &
                        iNVARS, iNVARS_SFC, iNVARS_LD,              &
                        svABRV, svDSCR, ivVLEVS,                    &
                        inc_mm, inc_hr, inc_dy, inc_mo, inc_yr,     &
                        iDebug, lOKflag )
!------------------------------------------------------------------------------
! Declarations:

! * Subroutine arguments:
! Scalar arguments with intent(in):
CHARACTER(*),  intent(in)    :: sNameCTL
INTEGER,       intent(in)    :: iDebug
! Scalar arguments with intent(out):
CHARACTER(*),  intent(out)   :: sNameDAT
REAL,          intent(out)   :: rUNDEF
INTEGER,       intent(out)   :: iNX
REAL(8),       intent(out)   :: dXstart
REAL(8),       intent(out)   :: dDX
INTEGER,       intent(out)   :: iNY
REAL(8),       intent(out)   :: dYstart
REAL(8),       intent(out)   :: dDY
INTEGER,       intent(out)   :: iNZ
REAL,          intent(out)   :: rZstart
REAL,          intent(out)   :: rDZ
INTEGER,       intent(out)   :: iNTIM
INTEGER,       intent(out)   :: iTINC
INTEGER,       intent(out)   :: iHH
INTEGER,       intent(out)   :: iMM
INTEGER,       intent(out)   :: iDD
INTEGER,       intent(out)   :: iMMM
INTEGER,       intent(out)   :: iYYYY
INTEGER,       intent(out)   :: iNVARS
INTEGER,       intent(out)   :: iNVARS_LD
INTEGER,       intent(out)   :: iNVARS_SFC
LOGICAL,       intent(out)   :: inc_mm
LOGICAL,       intent(out)   :: inc_hr
LOGICAL,       intent(out)   :: inc_dy
LOGICAL,       intent(out)   :: inc_mo
LOGICAL,       intent(out)   :: inc_yr
LOGICAL,       intent(out)   :: lOKflag
! Arrays arguments with intent(out)
CHARACTER(12),pointer        :: svABRV(:)
CHARACTER(40),pointer        :: svDSCR(:)
! Etichette dei livelli verticali 1D
REAL,    pointer             :: rvZLEVS(:)
INTEGER, pointer             :: ivVLEVS(:)

! * End of subroutine arguments

! Local parameters
INTEGER                      :: iErr
INTEGER                      :: i, j, ii, k, iApp
INTEGER                      :: IniLev, iLenABRV
! La lunghezza delle righe di GrADS non supera i 255 caratteri
CHARACTER(300)               :: sBuffer
CHARACTER                    :: c
CHARACTER(256)               :: sCTLpath
! - End of header -------------------------------------------------
! Inizializza variabili
  sNameDAT = ''
  sCTLpath = ''
  sBuffer  = ''
  NULLIFY(svABRV)
  NULLIFY(svDSCR)
  NULLIFY(rvZLEVS)
  NULLIFY(ivVLEVS)
! Setta le variabili LOGICAL a FALSE
  lOKflag= .FALSE.
  inc_mm = .FALSE.
  inc_hr = .FALSE.
  inc_dy = .FALSE.
  inc_mo = .FALSE.
  inc_yr = .FALSE.
! Apertura file .CTL
  OPEN( 100,FILE=sNameCTL,STATUS='OLD',FORM='FORMATTED', &
        ACTION='READ',IOSTAT=iErr )
  IF (iErr/=0) RETURN
! Setta l'eventuale path del file CTL
  DO i=LEN_TRIM(sNameCTL),1,-1
    IF (sNameCTL(i:i)=='/') EXIT
  ENDDO
  IF (i < 1) THEN
    sCTLpath=''
  ELSE
    sCTLpath=sNameCTL(1:i)
  ENDIF
! Ciclo di lettura del file .CTL
  DO
    READ(100,"(A)",IOSTAT=iErr) sBuffer
    IF (iErr /= 0) RETURN
    ! Leggi il numero di variabili
    IF ( INDEX(sBuffer, 'VARS') /= 0) THEN
      IF (iDebug==1) PRINT *,'ReadCTL_GRD: reading VARS...'
      READ(sBuffer(5:),*,IOSTAT=iErr) iNVARS
      EXIT ! Uscita normale dal ciclo
    ! leggi nome del file .DAT
    ELSEIF ( INDEX(sBuffer, 'DSET')  /= 0) THEN
      IF (iDebug==1) PRINT *,'ReadCTL_GRD: reading DSET...'
      IF ( INDEX(sBuffer, '^')/=0 ) THEN
        IF ( LEN_TRIM(sCTLpath)/=0 ) &
          sNameDAT(1:LEN_TRIM(sCTLpath)) = sCTLpath(1:LEN_TRIM(sCTLpath))
        DO i=1,LEN_TRIM(sBuffer)
          IF (sBuffer(i:i)=='^') EXIT
          sBuffer(i:i) = ' '
        ENDDO
        sBuffer(i:i) = ' '
      ELSE
        DO i=1,LEN_TRIM(sBuffer)
          IF ( (sBuffer(i:i)=='D').and.(sBuffer(i+1:i+1)=='S').and. &
               (sBuffer(i+2:i+2)=='E').and.(sBuffer(i+3:i+3)=='T') ) &
            EXIT
          sBuffer(i:i) = ' '
        ENDDO
        sBuffer(i:i+3) = '    '
      ENDIF
      sBuffer = ADJUSTL(sBuffer)
      IF (LEN_TRIM(sNameDAT)/=0) THEN
        sNameDAT(LEN_TRIM(sNameDAT)+1:LEN_TRIM(sNameDAT)+LEN_TRIM(sBuffer)) = &
          sBuffer(1:LEN_TRIM(sBuffer))
      ELSE
        sNameDAT(1:LEN_TRIM(sBuffer)) = sBuffer(1:LEN_TRIM(sBuffer))
      ENDIF
      sNameDAT=ADJUSTL(sNameDAT)
    ! leggi l'undefined value
    ELSEIF ( INDEX(sBuffer, 'UNDEF') /= 0) THEN
      IF (iDebug==1) PRINT *,'ReadCTL_GRD: reading UNDEF...'
      READ(sBuffer(6:),*,IOSTAT=iErr) rUNDEF
    ! leggi i settaggi della griglia lungo l'asse X
    ELSEIF ( INDEX(sBuffer, 'XDEF') /= 0) THEN
      IF (iDebug==1) PRINT *,'ReadCTL_GRD: reading XDEF...'
      READ(sBuffer(5:),*,IOSTAT=iErr) iNX
      READ(sBuffer(INDEX(sBuffer, 'LINEAR')+6:),*,IOSTAT=iErr) dXstart,dDX
    ! leggi i settaggi della griglia lungo l'asse Y
    ELSEIF ( INDEX(sBuffer, 'YDEF') /= 0) THEN
      IF (iDebug==1) PRINT *,'ReadCTL_GRD: reading YDEF...'
      READ(sBuffer(5:),*,IOSTAT=iErr) iNY
      READ(sBuffer(INDEX(sBuffer, 'LINEAR')+6:),*,IOSTAT=iErr) dYstart,dDY
    ! leggi i settaggi del dominio lungo l'asse Z
    ELSEIF ( INDEX(sBuffer, 'ZDEF') /= 0) THEN
      IF (iDebug==1) PRINT *,'ReadCTL_GRD: reading ZDEF...'
      READ(sBuffer(5:),*,IOSTAT=iErr) iNZ
      ! -- ZDEF...LINEAR start increment
      IF ( INDEX(sBuffer, 'LINEAR') /=0 ) THEN
        READ(sBuffer(INDEX(sBuffer, 'LINEAR')+6:),*,IOSTAT=iErr) rZstart,rDZ
      ! -- ZDEF m LEVELS livello1
      ! -- livello2
      ! -- ...
      ! -- livellom
      ELSE
        DO i=1,LEN_TRIM(sBuffer)
          ! ASCII: 48='0'   57='9'   46='.'
          IF ( ((IACHAR(sBuffer(i:i))<48).or.(IACHAR(sBuffer(i:i))>57)) &
               .and.(IACHAR(sBuffer(i:i))/=46) ) &
          sBuffer(i:i) = ' '
        ENDDO
!============================================
        ALLOCATE( rvZLEVS(iNZ), STAT=iErr )
        IF (iErr/=0) RETURN
!============================================
        DO k=1,iNZ
          rvZLEVS(k)=-99.0
        ENDDO
        sBuffer = ADJUSTL(sBuffer)
        READ(sBuffer,*,IOSTAT=iErr) iApp,(rvZLEVS(k),k=1,iNZ)
        ! Metto un limite di al ciclo per evitare il loop infinito
        DO i=1,iMAXZLEVS
        ! iErr/=0 -> rvZLEVS non pieno
          IF (iErr/=0) THEN
            DO k=1,iNZ
              IF (rvZLEVS(k)==-99) EXIT
            ENDDO
            IniLev = k
            IF (IniLev>iNZ) RETURN
            READ(100,"(A)",IOSTAT=iErr) sBuffer
            IF ( INDEX(sBuffer, 'VARS') /= 0) RETURN
            READ(sBuffer,*,IOSTAT=iErr) (rvZLEVS(k),k=IniLev,iNZ)
          ELSE
            EXIT
          ENDIF
        ENDDO
      ENDIF
    ! setta i parametri legati al tempo
    ELSEIF ( INDEX(sBuffer, 'TDEF') /= 0) THEN
      IF (iDebug==1) PRINT *,'ReadCTL_GRD: reading TDEF...'
      ! ripeti fino alla "R" di LINEAR
      DO i=1,INDEX(sBuffer, 'R')
        ! ASCII: 46 '.' * 58 ':' * 90 'Z'
        IF ( ((IACHAR(sBuffer(i:i))<48).or.(IACHAR(sBuffer(i:i))>57))       &
             .and.(IACHAR(sBuffer(i:i))/=46).and.(IACHAR(sBuffer(i:i))/=58) &
             .and.(IACHAR(sBuffer(i:i))/=90) )                              &
        sBuffer(i:i) = ' '
      ENDDO
      READ( sBuffer,*,IOSTAT=iErr ) iNTIM
      READ( sBuffer(INDEX(sBuffer,':')-2 : INDEX(sBuffer,':')-1), *, &
            IOSTAT=iErr) iHH
      READ( sBuffer(INDEX(sBuffer,':')+1 : INDEX(sBuffer,':')+2), *, &
            IOSTAT=iErr) iMM
      READ( sBuffer(INDEX(sBuffer,':')+4 : INDEX(sBuffer,':')+5), *, &
            IOSTAT=iErr) iDD
      READ( sBuffer(INDEX(sBuffer,':')+9 : INDEX(sBuffer,':')+12), *, &
            IOSTAT=iErr) iYYYY
      SELECT CASE ( sBuffer(INDEX(sBuffer,':')+6 : INDEX(sBuffer,':')+8) )
        CASE ('jan')
          iMMM = 1
        CASE ('feb')
          iMMM = 2
        CASE ('mar')
          iMMM = 3
        CASE ('apr')
          iMMM = 4
        CASE ('may')
          iMMM = 5
        CASE ('jun')
          iMMM = 6
        CASE ('jul')
          iMMM = 7
        CASE ('aug')
          iMMM = 8
        CASE ('sep')
          iMMM = 9
        CASE ('oct')
          iMMM = 10
        CASE ('nov')
          iMMM = 11
        CASE ('dec')
          iMMM = 12
        CASE DEFAULT
          RETURN
      END SELECT
      ! lettura di iTINC
      IF ( INDEX(sBuffer,'mn') /= 0 ) THEN
        inc_mm = .TRUE.
        c=sBuffer(INDEX(sBuffer,'mn')-1 : INDEX(sBuffer,'mn')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'MN') /= 0 ) THEN
        inc_mm = .TRUE.
        c=sBuffer(INDEX(sBuffer,'MN')-1 : INDEX(sBuffer,'MN')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'hr') /= 0 ) THEN
        inc_hr = .TRUE.
        c=sBuffer(INDEX(sBuffer,'hr')-1 : INDEX(sBuffer,'hr')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'HR') /= 0 ) THEN
        inc_hr = .TRUE.
        c=sBuffer(INDEX(sBuffer,'HR')-1 : INDEX(sBuffer,'HR')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'dy') /= 0 ) THEN
        inc_dy = .TRUE.
        c=sBuffer(INDEX(sBuffer,'dy')-1 : INDEX(sBuffer,'dy')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'DY') /= 0 ) THEN
        inc_dy = .TRUE.
        c=sBuffer(INDEX(sBuffer,'DY')-1 : INDEX(sBuffer,'DY')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'mo') /= 0 ) THEN
        inc_mo = .TRUE.
        c=sBuffer(INDEX(sBuffer,'mo')-1 : INDEX(sBuffer,'mo')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'MO') /= 0 ) THEN
        inc_mo = .TRUE.
        c=sBuffer(INDEX(sBuffer,'MO')-1 : INDEX(sBuffer,'MO')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'yr') /= 0 ) THEN
        inc_yr = .TRUE.
        c=sBuffer(INDEX(sBuffer,'yr')-1 : INDEX(sBuffer,'yr')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'YR') /= 0 ) THEN
        inc_yr = .TRUE.
        c=sBuffer(INDEX(sBuffer,'YR')-1 : INDEX(sBuffer,'YR')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ENDIF
    ENDIF
  ENDDO
! leggi la parte delle variabili (da "VARS" in poi)
  IF (iDebug==1) PRINT *,'ReadCTL_GRD: reading VARS section...'
  iNVARS_LD  = 0
  iNVARS_SFC = 0
!============================================
  ALLOCATE( svABRV(iNVARS), STAT=iErr )
  IF (iErr/=0) RETURN
  ALLOCATE( svDSCR(iNVARS), STAT=iErr )
  IF (iErr/=0) RETURN
  ALLOCATE( ivVLEVS(iNVARS), STAT=iErr )
  IF (iErr/=0) RETURN
!============================================
  DO i=1,iNVARS
    IF (iDebug==1) PRINT *,'ReadCTL_GRD: reading VARS section -> ',i,' VAR'
    READ(100,"(A)",IOSTAT=iErr) sBuffer
    ! leggi le variabili alfanumeriche
    j=0
    svABRV(i) = ''
    svDSCR(i) = ''
    DO
      j = j + 1
      IF ( sBuffer(j:j) == ' ' )  EXIT
      svABRV(i)(j:j) = sBuffer(j:j)
    ENDDO
    iLenABRV=j
    svDSCR(i) = sBuffer( INDEX(sBuffer,'99')+2 : LEN_TRIM(sBuffer) )
    svDSCR(i) = ADJUSTL( svDSCR(i) )
    ! leggi ivVLEVS
    READ(sBuffer(iLenABRV:),*,IOSTAT=iErr) ivVLEVS(i)
    IF ( ivVLEVS(i)==0) THEN
      iNVARS_SFC = iNVARS_SFC + 1
    ELSE
      iNVARS_LD  = iNVARS_LD  + 1
    ENDIF
  ENDDO

  CLOSE(100)
!������  DEBUG SECTION  ��������������������������������������������������������
  IF (iDebug==1) THEN
    PRINT *,'--- info di debug per la subroutine ReadCTL_GRD ---'
    PRINT *,'sNameCTL: ',TRIM(sNameCTL)
    PRINT *,'sNameDAT: ',TRIM(sNameDAT)
    PRINT *,'rUndef =  ',rUndef
    PRINT *,'iNX = ',iNX,' dXstart = ',dXstart,' dDX = ',dDX
    PRINT *,'iNY = ',iNY,' dYstart = ',dYstart,' dDY = ',dDY
    IF ( ASSOCIATED(rvZLEVS) ) THEN
      PRINT *,'ZDEF mapping: LEVELS'
      PRINT *,'iNZ = ',iNZ
      DO i=1,iNZ
        PRINT *,'livello ',i,': ',rvZLEVS(i)
      ENDDO
    ELSE
      PRINT *,'ZDEF mapping: LINEAR'
      PRINT *,'iNZ = ',iNZ,' rZstart = ',rZstart,' rDZ = ',rDZ
    ENDIF
    IF (inc_mm) PRINT *,'iNTIM = ',iNTIM,' iTINC = ',iTINC,'mn'
    IF (inc_hr) PRINT *,'iNTIM = ',iNTIM,' iTINC = ',iTINC,'hr'
    IF (inc_dy) PRINT *,'iNTIM = ',iNTIM,' iTINC = ',iTINC,'dy'
    IF (inc_mo) PRINT *,'iNTIM = ',iNTIM,' iTINC = ',iTINC,'mo'
    IF (inc_yr) PRINT *,'iNTIM = ',iNTIM,' iTINC = ',iTINC,'yr'
    PRINT *,'Data di inizio'
    PRINT *,'iHH= ',iHH,' iMM= ',iMM,' iDD= ',iDD,' iMMM= ',iMMM,' iYYYY= ',iYYYY
    PRINT *,'iNVARS= ',iNVARS,' iNVARS_SFC= ',iNVARS_SFC,' iNVARS_LD= ',iNVARS_LD
    PRINT *,'Variabili:'
    DO i=1,iNVARS
      PRINT *,'ABRV  ',i,': ',svABRV(i)
      PRINT *,'levs  ',i,': ',ivVLEVS(i)
      PRINT *,'units ',i,': -99'
      PRINT *,'DSCR  ',i,': ',svDSCR(i)
    ENDDO
    PRINT *,'---------------------------------------------------'
  ENDIF
!�����  END DEBUG SECTION  ��������������������������������������������������������

  lOKflag = .TRUE.

END SUBROUTINE ReadCTL_GRD

!+ Lettura del file .DAT - dati su griglie - leggo un tempo per volta
!------------------------------------------------------------------------------
SUBROUTINE ReadDAT_GRD( iLUN,       &
                        rvDATA_SFC, &
                        rvDATA_LD,  &
                        iNX,        &
                        iNY,        &
                        iNZ,        &
                        iNVARS_SFC, &
                        iNVARS_LD,  &
                        iNVARS,     &
                        ivVLEVS,    &
                        rUNDEF,     &
                        lOKflag )
!------------------------------------------------------------------------------
! Logical Unit Number del file binario dal quale leggere i dati
INTEGER, intent(IN)   :: iLUN
! dati superficie (levs=0) 3D(i,j,vs) i=[1,iNX];j=[1,iNY];vs=[1,iNVARS_SFC]
REAL,    pointer      :: rvDATA_SFC(:,:,:)
! pi? livelli (levs/=0) 4D(i,j,k,vl) i=[1,iNX];j=[1,iNY];k=[1,iNZ];vl=[1,iNVARS_LD]
REAL,    pointer      :: rvDATA_LD(:,:,:,:)
! campo "levs" del .CTL per ogni variabile 1D(v) v=[1,iNVARS]
INTEGER, pointer      :: ivVLEVS(:)
INTEGER, intent(IN)   :: iNX
INTEGER, intent(IN)   :: iNY
INTEGER, intent(IN)   :: iNZ
INTEGER, intent(IN)   :: iNVARS_SFC
INTEGER, intent(IN)   :: iNVARS_LD
INTEGER, intent(IN)   :: iNVARS
REAL,    intent(IN)   :: rUNDEF
! .TRUE. = tutto OK
LOGICAL, intent(OUT)  :: lOKflag
! Locals
INTEGER  :: iRetCode
INTEGER  :: i, j, k, vs, vl, v
REAL     :: rValue
!------------------------------------------------------------------------------
  lOKflag = .FALSE.
! Controllo variabili e array in input
  IF ( (iNX<=0).or.(iNY<=0).or.(iNZ<0) ) RETURN
  IF ( (iNVARS<=0).or.(iNVARS_LD<0).or.(iNVARS_SFC<0) ) RETURN
  IF ( (iNVARS_LD+iNVARS_SFC) /= iNVARS) RETURN
  IF ( .not.(ASSOCIATED(ivVLEVS) )) RETURN
  IF ( SIZE(ivVLEVS) < iNVARS) RETURN
  DO v=1,iNVARS
    IF (ivVLEVS(v)<0) RETURN
  ENDDO
! Deallocazione/Allocazione delle matrici di output
!========================================================================
  IF ( ASSOCIATED(rvDATA_SFC) ) THEN
    DEALLOCATE(rvDATA_SFC)
    NULLIFY( rvDATA_SFC )
  ENDIF
  IF ( ASSOCIATED(rvDATA_LD) ) THEN
    DEALLOCATE(rvDATA_LD)
    NULLIFY( rvDATA_LD )
  ENDIF
  IF (iRetCode /=0 ) RETURN
  ALLOCATE( rvDATA_SFC(iNX,iNY,iNVARS_SFC), STAT=iRetCode )
  IF (iRetCode /=0 ) RETURN
  ALLOCATE( rvDATA_LD(iNX,iNY,iNZ,iNVARS_LD), STAT=iRetCode )
  IF (iRetCode /=0 ) RETURN
!========================================================================
! Setta a rUNDEF il matricione rvDATA_LD
  DO vl=1,iNVARS_LD
    DO k=1,iNZ
      DO j=1,iNY
        DO i=1,iNX
          rvDATA_LD(i,j,k,vl) = rUNDEF
        ENDDO
      ENDDO
    ENDDO
  ENDDO
! Ciclo di lettura dati dal file binario
  vs=0
  vl=0
  DO v=1,iNVARS
    ! ivVLEVS(v)=0 -> "v" e' variabile di superficie
    IF ( ivVLEVS(v)==0 ) THEN
      vs = vs + 1
      DO j=1,iNY
        DO i=1,iNX
          READ(iLUN,IOSTAT=iRetCode) rValue
          ! Error, maybe end of file?
          IF (iRetCode<0) THEN
            RETURN
          ENDIF
          rvDATA_SFC(i,j,vs) = rValue
        ENDDO
      ENDDO
    ELSE
      vl = vl + 1
      DO k=1,ivVLEVS(v)
        DO j=1,iNY
          DO i=1,iNX
            READ(iLUN,IOSTAT=iRetCode) rValue
            ! Error, maybe end of file?
            IF (iRetCode/=0) RETURN
            rvDATA_LD(i,j,k,vl) = rValue
          ENDDO
        ENDDO
      ENDDO
    ENDIF
  ENDDO
! Uscita con successo
  lOKflag = .TRUE.
END SUBROUTINE ReadDAT_GRD

!+ Scrittura del file .CTL - dati su griglie
!------------------------------------------------------------------------------
SUBROUTINE WriteCTL_GRD( sNameCTL,sNameDAT, sTITLE, rUNDEF,          &
                         iNX, dXstart, dDX,                          &
                         iNY, dYstart, dDY,                          &
                         iNZ, rZstart, rDZ, rvZLEVS,                 &
                         iNTIM, iTINC, iHH, iMM, iDD, iMMM, iYYYY,   &
                         iNVARS,                                     &
                         svABRV,svDSCR, ivVLEVS,                     &
                         inc_mm, inc_hr, inc_dy, inc_mo, inc_yr,     &
                         lOKflag )
!------------------------------------------------------------------------------
! Description:
! Read a CTL descriptor file for gridded data.
! See GrADS user guide.
!   (available at http://grads.iges.org/grads/grads.html)
!
! Current Code owner: Cristian Lussana
!
! History:
!
! Version     Date        Comment
! -------    -------     ---------
!  1.0       28/9/04   Original code. Cristian Lussana
!
! Code description:
! Language: Fortran 90
! Software standards: "European Standards for Writing and
!                      Documenting Exchangeable Fortran 90 Code"
!-----------------------------------------------------------------
! Declarations:

! * Subroutine arguments:
! Scalar arguments with intent(in):
CHARACTER(*),  intent(in)   :: sNameCTL
CHARACTER(*),  intent(in)   :: sNameDAT
CHARACTER(*),  intent(in)   :: sTITLE
REAL,          intent(in)   :: rUNDEF
INTEGER,       intent(in)   :: iNX
REAL(8),       intent(in)   :: dXstart
REAL(8),       intent(in)   :: dDX
INTEGER,       intent(in)   :: iNY
REAL(8),       intent(in)   :: dYstart
REAL(8),       intent(in)   :: dDY
INTEGER,       intent(in)   :: iNZ
REAL,          intent(in)   :: rZstart
REAL,          intent(in)   :: rDZ
INTEGER,       intent(in)   :: iNTIM
INTEGER,       intent(in)   :: iTINC
INTEGER,       intent(in)   :: iHH
INTEGER,       intent(in)   :: iMM
INTEGER,       intent(in)   :: iDD
INTEGER,       intent(in)   :: iMMM
INTEGER,       intent(in)   :: iYYYY
INTEGER,       intent(in)   :: iNVARS
LOGICAL,       intent(in)   :: inc_mm
LOGICAL,       intent(in)   :: inc_hr
LOGICAL,       intent(in)   :: inc_dy
LOGICAL,       intent(in)   :: inc_mo
LOGICAL,       intent(in)   :: inc_yr
! Scalar arguments with intent(out):
LOGICAL,       intent(out)   :: lOKflag
! Arrays arguments with intent(out)
CHARACTER(12),pointer        :: svABRV(:)
CHARACTER(40),pointer        :: svDSCR(:)
! Etichette dei livelli verticali 1D
REAL, pointer                :: rvZLEVS(:)
INTEGER, pointer             :: ivVLEVS(:)

! * End of subroutine arguments

! Locals
CHARACTER(300)   :: sBuffer, sBuffer1, sBuffer2, sBuffer3
INTEGER          :: iErr, len
INTEGER          :: i,ii
!------------------------------------------------------------------------------
  lOKflag = .FALSE.
! Apri file .CTL sul quale scriver?
  OPEN( 100,FILE=TRIM(sNameCTL),STATUS='UNKNOWN',FORM='FORMATTED', &
        ACTION='WRITE',IOSTAT=iErr )
  IF (iErr/=0) RETURN

  sBuffer = 'DSET  ' // TRIM(ADJUSTL(sNameDAT))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)
  sBuffer = 'TITLE  ' // TRIM(ADJUSTL(sTITLE))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)

  WRITE(sBuffer1,*,IOSTAT=iErr) rUNDEF
  sBuffer = 'UNDEF  ' // TRIM(ADJUSTL(sBuffer1))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)

  WRITE(sBuffer1,*,IOSTAT=iErr) iNX
  WRITE(sBuffer2,*,IOSTAT=iErr) dXstart
  WRITE(sBuffer3,*,IOSTAT=iErr) dDX
  sBuffer = 'XDEF  ' // TRIM(ADJUSTL(sBuffer1)) // ' LINEAR ' // &
            TRIM(ADJUSTL(sBuffer2)) // ' ' // TRIM(ADJUSTL(sBuffer3))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)

  WRITE(sBuffer1,*,IOSTAT=iErr) iNY
  WRITE(sBuffer2,*,IOSTAT=iErr) dYstart
  WRITE(sBuffer3,*,IOSTAT=iErr) dDY
  sBuffer = 'YDEF  ' // TRIM(ADJUSTL(sBuffer1)) // ' LINEAR ' // &
            TRIM(ADJUSTL(sBuffer2)) // ' ' // TRIM(ADJUSTL(sBuffer3))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)

  IF ( ASSOCIATED(rvZLEVS) ) THEN
    WRITE(sBuffer1,*,IOSTAT=iErr) iNZ
    WRITE(sBuffer2,*,IOSTAT=iErr) rvZLEVS(1)
    sBuffer = 'ZDEF  ' // TRIM(ADJUSTL(sBuffer1)) // ' LEVELS ' // &
              TRIM(ADJUSTL(sBuffer2))
    WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)
    DO i=2,iNZ
      WRITE(sBuffer,*,IOSTAT=iErr) rvZLEVS(i)
      WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)
    ENDDO
  ELSE
    WRITE(sBuffer1,*,IOSTAT=iErr) iNZ
    WRITE(sBuffer2,*,IOSTAT=iErr) rZstart
    WRITE(sBuffer3,*,IOSTAT=iErr) rDZ
    sBuffer = 'ZDEF  ' // TRIM(ADJUSTL(sBuffer1)) // ' LINEAR ' // &
              TRIM(ADJUSTL(sBuffer2)) // ' ' // TRIM(ADJUSTL(sBuffer3))
    WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)
  ENDIF

  sBuffer2 = ''
  WRITE(sBuffer1,*,IOSTAT=iErr) iHH
  IF ( LEN_TRIM(ADJUSTL(sBuffer1))<2 ) THEN
    sBuffer2(1:1) = '0'
    sBuffer1 = ADJUSTL(sBuffer1)
    sBuffer2(2:2) = sBuffer1(1:1)
  ELSE
    sBuffer1 = ADJUSTL(sBuffer1)
    sBuffer2(1:2) = sBuffer1(1:2)
  ENDIF
  sBuffer2(3:3) = ':'
  WRITE(sBuffer1,*,IOSTAT=iErr) iMM
  IF ( LEN_TRIM(ADJUSTL(sBuffer1))<2 ) THEN
    sBuffer2(4:4) = '0'
    sBuffer1 = ADJUSTL(sBuffer1)
    sBuffer2(5:5) = sBuffer1(1:1)
  ELSE
    sBuffer1 = ADJUSTL(sBuffer1)
    sBuffer2(4:5) = sBuffer1(1:2)
  ENDIF
  sBuffer2(6:6) = 'Z'
  WRITE(sBuffer1,*,IOSTAT=iErr) iDD
  IF ( LEN_TRIM(ADJUSTL(sBuffer1))<2 ) THEN
    sBuffer2(7:7) = '0'
    sBuffer1 = ADJUSTL(sBuffer1)
    sBuffer2(8:8) = sBuffer1(1:1)
  ELSE
    sBuffer1 = ADJUSTL(sBuffer1)
    sBuffer2(7:8) = sBuffer1(1:2)
  ENDIF
  WRITE(sBuffer1,*,IOSTAT=iErr) iYYYY
  sBuffer1 = ADJUSTL(sBuffer1)
  sBuffer2(12:15) = sBuffer1(1:4)
  SELECT CASE (iMMM)
    CASE(1)
      sBuffer2(9:11) = 'jan'
    CASE(2)
      sBuffer2(9:11) = 'feb'
    CASE(3)
      sBuffer2(9:11) = 'mar'
    CASE(4)
      sBuffer2(9:11) = 'apr'
    CASE(5)
      sBuffer2(9:11) = 'may'
    CASE(6)
      sBuffer2(9:11) = 'jun'
    CASE(7)
      sBuffer2(9:11) = 'jul'
    CASE(8)
      sBuffer2(9:11) = 'aug'
    CASE(9)
      sBuffer2(9:11) = 'sep'
    CASE(10)
      sBuffer2(9:11) = 'oct'
    CASE(11)
      sBuffer2(9:11) = 'nov'
    CASE(12)
      sBuffer2(9:11) = 'dec'
    CASE DEFAULT
      RETURN
  END SELECT
  sBuffer2(16:16) = ' '
  WRITE(sBuffer3,*,IOSTAT=iErr) iTINC
  len = LEN_TRIM(ADJUSTL(sBuffer3))
  sBuffer2(17:17+len-1) = ADJUSTL(sBuffer3)
  IF (inc_mm) sBuffer2(17+len:17+len+1) = 'MN'
  IF (inc_hr) sBuffer2(17+len:17+len+1) = 'HR'
  IF (inc_dy) sBuffer2(17+len:17+len+1) = 'DY'
  IF (inc_mo) sBuffer2(17+len:17+len+1) = 'MO'
  IF (inc_yr) sBuffer2(17+len:17+len+1) = 'YR'
  WRITE(sBuffer1,*,IOSTAT=iErr) iNTIM
  sBuffer = 'TDEF  ' // TRIM(ADJUSTL(sBuffer1)) // ' LINEAR ' // &
            TRIM(ADJUSTL(sBuffer2))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)

  WRITE(sBuffer1,*,IOSTAT=iErr) iNVARS
  sBuffer = 'VARS  ' // TRIM(ADJUSTL(sBuffer1))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)
  DO i=1,iNVARS
    WRITE(sBuffer1,*,IOSTAT=iErr) ivVLEVS(i)
    sBuffer = TRIM(ADJUSTL(svABRV(i))) // '  ' // TRIM(ADJUSTL(sBuffer1)) // &
              '  99  ' // TRIM(ADJUSTL(svDSCR(i)))
    WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)
  ENDDO
  WRITE(100,"(A8)",IOSTAT=iErr) 'ENDVARS '

  CLOSE(100)

  lOKflag = .TRUE.

END SUBROUTINE WriteCTL_GRD

!+ Scrittura del file .DAT - dati su griglie
!------------------------------------------------------------------------------
SUBROUTINE WriteDAT_GRD( iLUN,       &
                         rvDATA_SFC, &
                         rvDATA_LD,  &
                         iNX,        &
                         iNY,        &
                         iNZ,        &
                         iNVARS_SFC, &
                         iNVARS_LD,  &
                         iNVARS,     &
                         ivVLEVS,    &
                         lOKflag )
!------------------------------------------------------------------------------
! Logical Unit Number del file binario sul quale scrivere i dati
INTEGER, intent(IN)   :: iLUN
! dati superficie (levs=0) 3D(i,j,vs) i=[1,iNX];j=[1,iNY];vs=[1,iNVARS_SFC]
REAL(8), pointer      :: rvDATA_SFC(:,:,:)
! pi? livelli (levs/=0) 4D(i,j,k,vl) i=[1,iNX];j=[1,iNY];k=[1,iNZ];vl=[1,iNVARS_LD]
REAL,    pointer      :: rvDATA_LD(:,:,:,:)
! campo "levs" del .CTL per ogni variabile 1D(v) v=[1,iNVARS]
INTEGER, pointer      :: ivVLEVS(:)
INTEGER, intent(IN)   :: iNX
INTEGER, intent(IN)   :: iNY
INTEGER, intent(IN)   :: iNZ
INTEGER, intent(IN)   :: iNVARS_SFC
INTEGER, intent(IN)   :: iNVARS_LD
INTEGER, intent(IN)   :: iNVARS
! .TRUE. = tutto OK
LOGICAL, intent(OUT)  :: lOKflag
! Locals
INTEGER  :: iRetCode
INTEGER  :: i, j, k, vs, vl, v
REAL     :: rValue
!------------------------------------------------------------------------------
  lOKflag = .FALSE.
! Controllo variabili e array in input
  IF ( (iNX<=0).or.(iNY<=0).or.(iNZ<0) ) RETURN
  IF ( (iNVARS<=0).or.(iNVARS_LD<0).or.(iNVARS_SFC<0) ) RETURN
  IF ( (iNVARS_LD+iNVARS_SFC) /= iNVARS) RETURN
  IF ( .not.(ASSOCIATED(ivVLEVS) )) RETURN
  IF ( SIZE(ivVLEVS) < iNVARS) RETURN
  DO v=1,iNVARS
    IF (ivVLEVS(v)<0) RETURN
  ENDDO
  IF ( (.not.ASSOCIATED(rvDATA_SFC)).and.(iNVARS_SFC/=0) ) RETURN
  IF ( (.not.ASSOCIATED(rvDATA_LD)).and.(iNVARS_LD/=0) )  RETURN
! Ciclo di lettura dati dal file binario
  vs=0
  vl=0
  DO v=1,iNVARS
    ! ivVLEVS(v)=0 -> "v" ? variabile di superficie
    IF ( ivVLEVS(v)==0 ) THEN
      vs = vs + 1
      DO j=1,iNY
        DO i=1,iNX
          WRITE(iLUN,IOSTAT=iRetCode) rvDATA_SFC(i,j,vs)
        ENDDO
      ENDDO
    ELSE
      vl = vl + 1
      DO k=1,ivVLEVS(v)
        DO j=1,iNY
          DO i=1,iNX
            WRITE(iLUN,IOSTAT=iRetCode) rvDATA_LD(i,j,k,vl)
          ENDDO
        ENDDO
      ENDDO
    ENDIF
  ENDDO
! Uscita con successo
  lOKflag = .TRUE.

END SUBROUTINE WriteDAT_GRD


!+ Estrae una serie temporale da un file DAT tipo GRD
!------------------------------------------------------------------------------
SUBROUTINE ReadVXYZ_GRD( sNameCTL,  &
                         sIDVAR,    &
                         iX,        &
                         iY,        &
                         iZ,        &
                         rvOUT,     &
                         lOKflag )
!------------------------------------------------------------------------------
! Descrizione:
! Estrae la serie temporale della variabile "sIDVAR" nel nodo di coordinate
! (X,Y,Z) [ (1,1,1)= nodo in basso a sinistra 1� livello ].
! Note:
! Errore se:
! (1) il file CTL non esiste;
! (2) non riesce a leggere correttamente il file CTL (vedi "ReadCTL_STN");
! (3) "rvOUT" gi? allocato e non riesce a deallocarlo;
! (4) non riesco ad allocare "rvOUT";
! (5) specifico un livello per una variabile di superficie;
! (6) non specifico un livello per una variabile LD (Level Dependent);
! (7) non esiste il file .DAT o non riesce ad aprirlo correttamente;
! (8) problemi nella lettura del file .DAT (vedi "ReadDAT_STN");
! (9) "iX" ? maggiore del valore "iNX" letto dal file .CTL
!(10) "iY" ? maggiore del valore "iNY" letto dal file .CTL
!(11) "iZ" ? maggiore del valore "iNZ" letto dal file .CTL
!
! Comportamenti particolari:
! (1) se la variabile "sIDVAR" non ? fra quelle presenti all'interno del file
!     .CTL allora restituisci "rvOUT" riempito con valori di "rUNDEF"
! (2) il record "tvOUT(t)" pu? essere uguale ad "rUNDEF" se:
!     (a) il valore nel file .DAT ? "rUNDEF";
!
! Variabili IN&OUT:
! IN:
! sNameCTL  -  percorso+nome del file .CTL
! sIDVAR    -  abbreviazione (sABRV) variabile da estrarre (stringa)
! iX        -  Coordinata X del Nodo
! iY        -  Coordinata Y del Nodo
! iZ        -  Coordinata Z del Nodo
! OUT:
! rvOUT     -  vettore reale di dimensione "iNTIM" con la serie temporale
! lOKflag   -  TRUE=tutto OK ; FALSE=problemi
!
!
! Declarations:

! * Subroutine arguments:
! Scalar arguments with intent(in):
CHARACTER(*),  intent(IN)    :: sNameCTL
CHARACTER(12), intent(IN)    :: sIDVAR
INTEGER,       intent(IN)    :: iX
INTEGER,       intent(IN)    :: iY
INTEGER,       intent(IN)    :: iZ
! Scalar arguments with intent(out):
LOGICAL,       intent(out)   :: lOKflag
! Arrays arguments with intent(out)
REAL,          pointer       :: rvOUT(:)

! Locals
CHARACTER(200) :: sNameDAT
REAL           :: rUNDEF
INTEGER        :: iNX, iNY, iNZ
REAL           :: rZstart, rDZ
REAL(8)        :: dXstart, dDX, dYstart, dDY
INTEGER        :: iNTIM, iTINC, iHH, iMM, iDD, iMMM, iYYYY
INTEGER        :: iNVARS, iNVARS_SFC, iNVARS_LD
INTEGER        :: iNSTAT, iNSTAT_SFC, iNSTAT_LD
LOGICAL        :: inc_mm, inc_hr, inc_dy, inc_mo, inc_yr
INTEGER        :: iDebug
INTEGER        :: v, t, s, m
LOGICAL        :: lFlag, lExist
INTEGER        :: iRetCode
INTEGER        :: iPos
LOGICAL        :: SFC_flag
INTEGER        :: iNLEVS_LD
INTEGER        :: iContSFC, iContLD

CHARACTER(12),pointer         :: svABRV(:)
CHARACTER(40),pointer        :: svDSCR(:)
! Etichette dei livelli verticali 1D
INTEGER, pointer             :: ivVLEVS(:)
REAL,    pointer             :: rvZLEVS(:)
REAL,    pointer             :: rvDATA_SFC(:,:,:)
REAL,    pointer             :: rvDATA_LD(:,:,:,:)

!------------------------------------------------------------------------------
  lOKflag = .FALSE.
! Inizializza
  sNameDAT=''
  NULLIFY(svABRV)
  NULLIFY(svDSCR)
  NULLIFY(ivVLEVS)
  NULLIFY(rvDATA_SFC)
  NULLIFY(rvDATA_LD)
! Leggi file .CTL
  INQUIRE( FILE=sNameCTL, EXIST=lExist )
  IF (.not.lExist) RETURN
  iDebug = 0
  CALL ReadCTL_GRD( sNameCTL, sNameDAT, rUNDEF,                 &
                    iNX, dXstart, dDX,                          &
                    iNY, dYstart, dDY,                          &
                    iNZ, rZstart, rDZ, rvZLEVS,                 &
                    iNTIM, iTINC, iHH, iMM, iDD, iMMM, iYYYY,   &
                    iNVARS, iNVARS_SFC, iNVARS_LD,              &
                    svABRV, svDSCR, ivVLEVS,                    &
                    inc_mm, inc_hr, inc_dy, inc_mo, inc_yr,     &
                    iDebug, lFlag )
  IF (.not.lFlag) RETURN
! Controlla input
  IF ( (iX>iNX).OR.(iX<=0) ) RETURN
  IF ( (iY>iNY).OR.(iY<=0) ) RETURN
  IF (iZ>iNZ) RETURN
!============================================================================
  IF ( ASSOCIATED(rvOUT) ) THEN
    DEALLOCATE( rvOUT, STAT=iRetCode )
    IF (iRetCode/=0) RETURN
  ENDIF
  ALLOCATE( rvOUT(iNTIM), STAT=iRetCode )
  IF (iRetCode/=0) RETURN
!============================================================================
! Identifica la variabile da leggere
  iContSFC = 0
  iContLD  = 0
  DO v=1,iNVARS
    IF (ivVLEVS(v)==0) THEN
      iContSFC = iContSFC + 1
    ELSE
      iContLD  = iContLD  + 1
    ENDIF
    IF ( svABRV(v) == sIDVAR ) EXIT
  ENDDO
  ! se sto richiedendo una variabile non presente nel file allora
  ! ritorna un vettore tutto "rUNDEF"
  IF ( v > iNVARS) THEN
    DO t=1,iNTIM
      rvOUT(t) = rUNDEF
    ENDDO
    RETURN
  ENDIF
  ! se sono arrivato qui allora v<iNVARS
  ! controllo: se la variabile ? SFC e io voglio un livello vert -> esci
  IF ( (ivVLEVS(v)==0).and.(iZ>0) ) RETURN
  ! controllo: se la variabile ? LD e io non specifico livello   -> esci
  IF ( (ivVLEVS(v)/=0).and.(iZ<0) ) RETURN
  ! se sono arrivato qui allora la richiesta eseguita ? formalmente corretta
  ! ora setto SFC_flag e la posizione della variabile all'interno del gruppo
  ! di variabili corrispondenti: SFC o LD
  IF ( ivVLEVS(v)==0 ) THEN
     SFC_flag = .TRUE.
     iPos = iContSFC
  ELSE
     SFC_flag = .FALSE.
     iPos = iContLD
  ENDIF
! Apri file .DAT
  INQUIRE( FILE=TRIM(sNameDAT), EXIST=lExist )
  IF (.not.lExist) RETURN
!  OPEN(10, FILE=TRIM(sNameDAT), FORM='BINARY', IOSTAT=iRetCode )
  OPEN(10, FILE=TRIM(sNameDAT), FORM='UNFORMATTED', IOSTAT=iRetCode )
  IF (iRetCode/=0) RETURN
! Ciclo su tutti i tempi
  DO t=1,iNTIM
    ! Leggi records del tempo "t" dal file .DAT
    CALL ReadDAT_GRD( 10, rvDATA_SFC, rvDATA_LD, iNX, iNY, iNZ,              &
                      iNVARS_SFC, iNVARS_LD, iNVARS, ivVLEVS, rUNDEF, lFlag )
    IF (.not.lFlag) THEN
      DEALLOCATE( rvDATA_SFC, rvDATA_LD )
      CLOSE(10)
      RETURN
    ENDIF

    IF (SFC_flag) THEN
      rvOUT(t) = rvDATA_SFC( iX, iY, iPos )
    ELSE
      rvOUT(t) = rvDATA_LD( iX, iY, iZ, iPos )
    ENDIF
  ENDDO ! - fine ciclo tempo -

! Uscita normale
  CLOSE(10)
  lOKflag = .TRUE.

END SUBROUTINE ReadVXYZ_GRD


!==============================================================================
!                         S T A T I O N      D A T A
!==============================================================================

!+ Read a ".ctl" file for station data
!------------------------------------------------------------------------------
SUBROUTINE ReadCTL_STN( sNameCTL, sNameDAT, rUNDEF,                 &
                        iNTIM, iTINC, iHH, iMM, iDD, iMMM, iYYYY,   &
                        iNVARS, iNVARS_SFC, iNVARS_LD,              &
                        svABRV,svDSCR, ivVLEVS,                     &
                        inc_mm, inc_hr, inc_dy, inc_mo, inc_yr,     &
                        iDebug, lOKflag )
!------------------------------------------------------------------------------
! Description:
! Read a CTL descriptor file for gridded data.
! See GrADS user guide.
!   (available at http://grads.iges.org/grads/grads.html)
!
! Current Code owner: Cristian Lussana
!
! History:
!
! Version     Date        Comment
! -------    -------     ---------
!  1.0       28/9/04   Original code. Cristian Lussana
!
! Code description:
! Language: Fortran 90
! Software standards: "European Standards for Writing and
!                      Documenting Exchangeable Fortran 90 Code"
!-----------------------------------------------------------------
! Declarations:

! * Subroutine arguments:
! Scalar arguments with intent(in):
CHARACTER(*),  intent(in)    :: sNameCTL
INTEGER,       intent(in)    :: iDebug
! Scalar arguments with intent(out):
CHARACTER(*),  intent(out)   :: sNameDAT
REAL,          intent(out)   :: rUNDEF
INTEGER,       intent(out)   :: iNTIM
INTEGER,       intent(out)   :: iTINC
INTEGER,       intent(out)   :: iHH
INTEGER,       intent(out)   :: iMM
INTEGER,       intent(out)   :: iDD
INTEGER,       intent(out)   :: iMMM
INTEGER,       intent(out)   :: iYYYY
INTEGER,       intent(out)   :: iNVARS
INTEGER,       intent(out)   :: iNVARS_LD
INTEGER,       intent(out)   :: iNVARS_SFC
LOGICAL,       intent(out)   :: inc_mm
LOGICAL,       intent(out)   :: inc_hr
LOGICAL,       intent(out)   :: inc_dy
LOGICAL,       intent(out)   :: inc_mo
LOGICAL,       intent(out)   :: inc_yr
LOGICAL,       intent(out)   :: lOKflag
! Arrays arguments with intent(out)
CHARACTER(12),pointer        :: svABRV(:)
CHARACTER(40),pointer        :: svDSCR(:)
! Etichette dei livelli verticali 1D
INTEGER, pointer             :: ivVLEVS(:)

! * End of subroutine arguments

! Local parameters
INTEGER                      :: iErr
INTEGER                      :: i, j, ii, iii
INTEGER                      :: IniLen, iLenABRV
! La lunghezza delle righe di GrADS non supera i 255 caratteri
CHARACTER(300)               :: sBuffer
CHARACTER                    :: c
CHARACTER(256)               :: sCTLpath
! - End of header -------------------------------------------------
! Inizializza variabili
  sNameDAT = ''
  sCTLpath = ''
  sBuffer  = ''
  NULLIFY(svABRV)
  NULLIFY(svDSCR)
  NULLIFY(ivVLEVS)
! Setta le variabili LOGICAL a FALSE
  lOKflag= .FALSE.
  inc_mm = .FALSE.
  inc_hr = .FALSE.
  inc_dy = .FALSE.
  inc_mo = .FALSE.
  inc_yr = .FALSE.
! Inizializza sNameDAT
  sNameDAT=''
! Apertura file .CTL
  OPEN( 100,FILE=sNameCTL,STATUS='OLD',FORM='FORMATTED', &
        ACTION='READ',IOSTAT=iErr )
! Setta l'eventuale path del file CTL
  IF (iErr/=0) RETURN
  DO i=LEN_TRIM(sNameCTL),1,-1
    IF (sNameCTL(i:i)=='/') EXIT
  ENDDO
  IF (i < 1) THEN
    sCTLpath=''
  ELSE
    sCTLpath=sNameCTL(1:i)
  ENDIF
! Ciclo di lettura del file .CTL
  DO
    READ(100,"(A)",IOSTAT=iErr) sBuffer
    IF (iErr /= 0) RETURN
    ! Leggi il numero di variabili
    IF ( INDEX(sBuffer, 'VARS') /= 0) THEN
      READ(sBuffer(5:),*,IOSTAT=iErr) iNVARS
      EXIT ! Uscita normale dal ciclo
    ! leggi nome del file .DAT
    ELSEIF ( INDEX(sBuffer, 'DSET')  /= 0) THEN
      IF (iDebug==1) PRINT *,'ReadCTL_GRD: reading DSET...'
      IF ( INDEX(sBuffer, '^')/=0 ) THEN
        IF ( LEN_TRIM(sCTLpath)/=0 ) &
          sNameDAT(1:LEN_TRIM(sCTLpath)) = sCTLpath(1:LEN_TRIM(sCTLpath))
        DO i=1,LEN_TRIM(sBuffer)
          IF (sBuffer(i:i)=='^') EXIT
          sBuffer(i:i) = ' '
        ENDDO
        sBuffer(i:i) = ' '
      ELSE
        DO i=1,LEN_TRIM(sBuffer)
          IF ( (sBuffer(i:i)=='D').and.(sBuffer(i+1:i+1)=='S').and. &
               (sBuffer(i+2:i+2)=='E').and.(sBuffer(i+3:i+3)=='T') ) &
            EXIT
          sBuffer(i:i) = ' '
        ENDDO
        sBuffer(i:i+3) = '    '
      ENDIF
      sBuffer = ADJUSTL(sBuffer)
      IF (LEN_TRIM(sNameDAT)/=0) THEN
        sNameDAT(LEN_TRIM(sNameDAT)+1:LEN_TRIM(sNameDAT)+LEN_TRIM(sBuffer)) = &
          sBuffer(1:LEN_TRIM(sBuffer))
      ELSE
        sNameDAT(1:LEN_TRIM(sBuffer)) = sBuffer(1:LEN_TRIM(sBuffer))
      ENDIF
      sNameDAT=ADJUSTL(sNameDAT)
    ! Leggi l'undefined value
    ELSEIF ( INDEX(sBuffer, 'UNDEF') /= 0) THEN
      READ(sBuffer(6:),*,IOSTAT=iErr) rUNDEF
    ! Leggi i parametri legati al tempo
    ELSEIF ( INDEX(sBuffer, 'TDEF') /= 0) THEN
      ! ripeti fino alla "R" di LINEAR
      DO i=1,INDEX(sBuffer, 'R')
        ! ASCII: 46 '.' * 58 ':' * 90 'Z'
        IF ( ((IACHAR(sBuffer(i:i))<48).or.(IACHAR(sBuffer(i:i))>57))       &
             .and.(IACHAR(sBuffer(i:i))/=46).and.(IACHAR(sBuffer(i:i))/=58) &
             .and.(IACHAR(sBuffer(i:i))/=90) )                              &
        sBuffer(i:i) = ' '
      ENDDO
      READ( sBuffer,*,IOSTAT=iErr ) iNTIM
      READ( sBuffer(INDEX(sBuffer,':')-2 : INDEX(sBuffer,':')-1), *, &
            IOSTAT=iErr) iHH
      READ( sBuffer(INDEX(sBuffer,':')+1 : INDEX(sBuffer,':')+2), *, &
            IOSTAT=iErr) iMM
      READ( sBuffer(INDEX(sBuffer,':')+4 : INDEX(sBuffer,':')+5), *, &
            IOSTAT=iErr) iDD
      READ( sBuffer(INDEX(sBuffer,':')+9 : INDEX(sBuffer,':')+12), *, &
            IOSTAT=iErr) iYYYY
      SELECT CASE ( sBuffer(INDEX(sBuffer,':')+6 : INDEX(sBuffer,':')+8) )
        CASE ('jan')
          iMMM = 1
        CASE ('feb')
          iMMM = 2
        CASE ('mar')
          iMMM = 3
        CASE ('apr')
          iMMM = 4
        CASE ('may')
          iMMM = 5
        CASE ('jun')
          iMMM = 6
        CASE ('jul')
          iMMM = 7
        CASE ('aug')
          iMMM = 8
        CASE ('sep')
          iMMM = 9
        CASE ('oct')
          iMMM = 10
        CASE ('nov')
          iMMM = 11
        CASE ('dec')
          iMMM = 12
        CASE DEFAULT
          RETURN
      END SELECT
      ! lettura di rTINC
      IF ( INDEX(sBuffer,'mn') /= 0 ) THEN
        inc_mm = .TRUE.
        c=sBuffer(INDEX(sBuffer,'mn')-1 : INDEX(sBuffer,'mn')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'MN') /= 0 ) THEN
        inc_mm = .TRUE.
        c=sBuffer(INDEX(sBuffer,'MN')-1 : INDEX(sBuffer,'MN')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'hr') /= 0 ) THEN
        inc_hr = .TRUE.
        c=sBuffer(INDEX(sBuffer,'hr')-1 : INDEX(sBuffer,'hr')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'HR') /= 0 ) THEN
        inc_hr = .TRUE.
        c=sBuffer(INDEX(sBuffer,'HR')-1 : INDEX(sBuffer,'HR')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'dy') /= 0 ) THEN
        inc_dy = .TRUE.
        c=sBuffer(INDEX(sBuffer,'dy')-1 : INDEX(sBuffer,'dy')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'DY') /= 0 ) THEN
        inc_dy = .TRUE.
        c=sBuffer(INDEX(sBuffer,'DY')-1 : INDEX(sBuffer,'DY')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'mo') /= 0 ) THEN
        inc_mo = .TRUE.
        c=sBuffer(INDEX(sBuffer,'mo')-1 : INDEX(sBuffer,'mo')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'MO') /= 0 ) THEN
        inc_mo = .TRUE.
        c=sBuffer(INDEX(sBuffer,'MO')-1 : INDEX(sBuffer,'MO')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'yr') /= 0 ) THEN
        inc_yr = .TRUE.
        c=sBuffer(INDEX(sBuffer,'yr')-1 : INDEX(sBuffer,'yr')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ELSEIF ( INDEX(sBuffer,'YR') /= 0 ) THEN
        inc_yr = .TRUE.
        c=sBuffer(INDEX(sBuffer,'YR')-1 : INDEX(sBuffer,'YR')-1)
        READ(c,*,IOSTAT=iErr) iTINC
      ENDIF
    ENDIF
  ENDDO
! leggi la parte delle variabili (da "VARS" in poi)
  iNVARS_LD  = 0
  iNVARS_SFC = 0
!============================================
  ALLOCATE( svABRV(iNVARS), STAT=iErr )
  IF (iErr/=0) RETURN
  ALLOCATE( svDSCR(iNVARS), STAT=iErr )
  IF (iErr/=0) RETURN
  ALLOCATE( ivVLEVS(iNVARS), STAT=iErr )
  IF (iErr/=0) RETURN
!============================================
  DO i=1,iNVARS
    IF (iDebug==1) PRINT *,'ReadCTL_DAT: reading VARS section -> ',i,' VAR'
    READ(100,"(A)",IOSTAT=iErr) sBuffer
    ! leggi le variabili alfanumeriche
    j=0
    svABRV(i) = ''
    svDSCR(i) = ''
    DO
      j = j + 1
      IF ( sBuffer(j:j) == ' ' )  EXIT
      svABRV(i)(j:j) = sBuffer(j:j)
    ENDDO
    iLenABRV=j
    svDSCR(i) = sBuffer( INDEX(sBuffer,'99')+2 : LEN_TRIM(sBuffer) )
    svDSCR(i) = ADJUSTL( svDSCR(i) )
    ! leggi ivVLEVS
    READ(sBuffer(iLenABRV:),*,IOSTAT=iErr) ivVLEVS(i)
    IF ( ivVLEVS(i)==0) THEN
      iNVARS_SFC = iNVARS_SFC + 1
    ELSE
      iNVARS_LD  = iNVARS_LD  + 1
    ENDIF
  ENDDO

  CLOSE(100)

!������  DEBUG SECTION  ��������������������������������������������������������
  IF (iDebug==1) THEN
    PRINT *,'--- info di debug per la subroutine ReadCTL_STN ---'
    PRINT *,'sNameCTL: ',TRIM(sNameCTL)
    PRINT *,'sNameDAT: ',TRIM(sNameDAT)
    PRINT *,'rUndef =  ',rUndef
    IF (inc_mm) PRINT *,'iNTIM = ',iNTIM,' iTINC = ',iTINC,'mn'
    IF (inc_hr) PRINT *,'iNTIM = ',iNTIM,' iTINC = ',iTINC,'hr'
    IF (inc_dy) PRINT *,'iNTIM = ',iNTIM,' iTINC = ',iTINC,'dy'
    IF (inc_mo) PRINT *,'iNTIM = ',iNTIM,' iTINC = ',iTINC,'mo'
    IF (inc_yr) PRINT *,'iNTIM = ',iNTIM,' iTINC = ',iTINC,'yr'
    PRINT *,'Data di inizio'
    PRINT *,'iHH= ',iHH,' iMM= ',iMM,' iDD= ',iDD,' iMMM= ',iMMM,' iYYYY= ',iYYYY
    PRINT *,'iNVARS= ',iNVARS,' iNVARS_SFC= ',iNVARS_SFC,' iNVARS_LD= ',iNVARS_LD
    PRINT *,'Variabili:'
    DO i=1,iNVARS
      PRINT *,'ABRV  ',i,': ',svABRV(i)
      PRINT *,'levs  ',i,': ',ivVLEVS(i)
      PRINT *,'units ',i,': -99'
      PRINT *,'DSCR  ',i,': ',svDSCR(i)
    ENDDO
    PRINT *,'---------------------------------------------------'
  ENDIF
!������  END DEBUG SECTION  ����������������������������������������������������

  lOKflag = .TRUE.

END SUBROUTINE ReadCTL_STN

!+ Read a ".dat" binary file for station data
!------------------------------------------------------------------------------
SUBROUTINE ReadDAT_STN( iLUN,       &
                        tvSTN,      &
                        iNSTAT,     &
                        iNSTAT_SFC, &
                        iNSTAT_LD,  &
                        iNVARS,     &
                        iNVARS_LD,  &
                        iNVARS_SFC, &
                        iDebug,     &
                        lOKflag )
!------------------------------------------------------------------------------
! Declarations:

! * Subroutine arguments:
! Scalar arguments with intent(in):
INTEGER,       intent(in)    :: iLUN
INTEGER,       intent(in)    :: iDebug
INTEGER,       intent(in)    :: iNVARS
INTEGER,       intent(in)    :: iNVARS_LD
INTEGER,       intent(in)    :: iNVARS_SFC
! Scalar arguments with intent(out):
INTEGER,       intent(out)   :: iNSTAT
INTEGER,       intent(out)   :: iNSTAT_SFC
INTEGER,       intent(out)   :: iNSTAT_LD
LOGICAL,       intent(out)   :: lOKflag
! Arrays arguments with intent(out)
TYPE(StazData), pointer      :: tvSTN(:)
! Locals
CHARACTER(8)  :: sID
REAL          :: rX
REAL          :: rY
REAL          :: rt
REAL          :: rLevel
INTEGER       :: iNLEV, iNLEV_LD
INTEGER       :: iFLAG
INTEGER       :: iRetCode
INTEGER       :: i, k, s, m, vs, vl
LOGICAL       :: lFlag
! Struttura dati che utilizzo finch? non conosco il valore di iNSTAT
TYPE(StazData), pointer  :: tvSTN_tmp(:)
!------------------------------------------------------------------------------
  lOKflag = .FALSE.
  lFlag=.TRUE.
  IF (ASSOCIATED(tvSTN_tmp) ) CALL GrADSfreeStn(tvSTN_tmp,SIZE(tvSTN_tmp),lFlag)
  IF (.not.lFlag) THEN
    PRINT *,'A'
    RETURN
  ENDIF
  NULLIFY(tvSTN_tmp)
  CALL GrADSallocStn(tvSTN_tmp, iMAXSTN, lFlag )
  IF (.not.lFlag) THEN
    PRINT *,'B'
    RETURN
  ENDIF
  i=0
  iNSTAT_SFC = 0
  iNSTAT_LD  = 0
  iNLEV=3
  DO
    READ(iLUN,IOSTAT=iRetCode) sID
    READ(iLUN,IOSTAT=iRetCode) rY
    READ(iLUN,IOSTAT=iRetCode) rX
    READ(iLUN,IOSTAT=iRetCode) rt
    READ(iLUN,IOSTAT=iRetCode) iNLEV
    READ(iLUN,IOSTAT=iRetCode) iFLAG
!-D
!    PRINT *,sID,rX,rY,iNLEV,iFLAG
!-D
    IF (iNLEV==0) EXIT
    i=i+1
    tvSTN_tmp(i)%ID   = sID
    tvSTN_tmp(i)%X    = rX
    tvSTN_tmp(i)%Y    = rY
    tvSTN_tmp(i)%t    = rt
    tvSTN_tmp(i)%NLEV = iNLEV
    tvSTN_tmp(i)%FLAG = iFLAG
    IF ( (iNLEV-iFLAG)>0 ) THEN
      iNLEV_LD = iNLEV - iFLAG
!=============================================================================
      ALLOCATE( tvSTN_tmp(i)%LD_VARS(iNVARS_LD+1,iNLEV_LD), STAT=iRetCode )
      IF (iRetCode/=0) THEN
        PRINT *,sID,rX,rY,iNLEV,iFLAG
        PRINT *,'C'
        RETURN
      ENDIF
!=============================================================================
      iNSTAT_LD = iNSTAT_LD + 1
    ENDIF
    DO k=1,iNLEV
      IF ( (iFLAG==1).and.(k==1) ) THEN
        iNSTAT_SFC = iNSTAT_SFC + 1
!=============================================================================
        ALLOCATE( tvSTN_tmp(i)%SFC_VARS(iNVARS_SFC), STAT=iRetCode )
        IF (iRetCode/=0) THEN
          PRINT *,'D'
          RETURN
        ENDIF
!=============================================================================
        DO vs=1,iNVARS_SFC
          READ(iLUN,IOSTAT=iRetCode) tvSTN_tmp(i)%SFC_VARS(vs)
        ENDDO
        CYCLE
      ENDIF
      m = k - iFLAG
      READ(iLUN,IOSTAT=iRetCode) rLEVEL
      tvSTN_tmp(i)%LD_VARS(1,m) = rLEVEL
      DO vl=2,iNVARS_LD+1
        READ(iLUN,IOSTAT=iRetCode) tvSTN_tmp(i)%LD_VARS(vl,m)
      ENDDO
    ENDDO
  ENDDO
! Setta il numero di stazioni
  iNSTAT = i
! Passa da "tvSTN_tmp" a "tvSTN"
  IF (ASSOCIATED(tvSTN)) CALL GrADSfreeStn(tvSTN,SIZE(tvSTN),lFlag)
  IF (.not.lFlag) THEN
    PRINT *,'E'
    RETURN
  ENDIF
  NULLIFY(tvSTN)
  CALL GrADSallocStn(tvSTN, iNSTAT, lFlag )
  IF (.not.lFlag) THEN
    PRINT *,'F'
    RETURN
  ENDIF
  DO s=1,iNSTAT
    tvSTN(s)%ID = tvSTN_tmp(s)%ID
    tvSTN(s)%X  = tvSTN_tmp(s)%X
    tvSTN(s)%Y  = tvSTN_tmp(s)%Y
    tvSTN(s)%t  = tvSTN_tmp(s)%t
    tvSTN(s)%NLEV = tvSTN_tmp(s)%NLEV
    tvSTN(s)%FLAG = tvSTN_tmp(s)%FLAG
    IF ( ASSOCIATED( tvSTN_tmp(s)%SFC_VARS ) ) THEN
      ALLOCATE( tvSTN(s)%SFC_VARS(iNVARS_SFC), STAT=iRetCode )
      IF (iRetCode/=0) THEN
        PRINT *,'G'
        RETURN
      ENDIF
      DO vs=1,iNVARS_SFC
        tvSTN(s)%SFC_VARS(vs) = tvSTN_tmp(s)%SFC_VARS(vs)
      ENDDO
    ENDIF
    IF ( ASSOCIATED( tvSTN_tmp(s)%LD_VARS ) ) THEN
      iNLEV_LD = tvSTN_tmp(s)%NLEV -tvSTN_tmp(s)%FLAG
      ALLOCATE( tvSTN(s)%LD_VARS(iNVARS_LD+1,iNLEV_LD), STAT=iRetCode )
      IF (iRetCode/=0) THEN
        PRINT *,'H'
        RETURN
      ENDIF
      DO vl=1,iNVARS_LD+1
        DO m=1,iNLEV_LD
          tvSTN(s)%LD_VARS(vl,m) = tvSTN_tmp(s)%LD_VARS(vl,m)
        ENDDO
      ENDDO
    ENDIF
  ENDDO
  CALL GrADSfreeStn( tvSTN_tmp, SIZE(tvSTN_tmp), lFlag )
  IF (.not.lFlag) THEN
    PRINT *,'I'
    RETURN
  ENDIF
  NULLIFY(tvSTN_tmp)
!������  DEBUG SECTION  ��������������������������������������������������������
  IF (iDebug==1) THEN
    PRINT *,'--- info di debug per la subroutine ReadDAT_STN ---'
    PRINT *,'iLUN   = ',iLUN
    PRINT *,'iNSTAT = ',iNSTAT
    PRINT *,'iNSTAT_SFC = ',iNSTAT_SFC
    PRINT *,'iNSTAT_LD  = ',iNSTAT_LD
    PRINT *,'---------------------------------------------------'
  ENDIF
!������  END DEBUG SECTION  ����������������������������������������������������
! Normal end
  lOKflag = .TRUE.
END SUBROUTINE ReadDAT_STN

!+ Write a ".ctl" file for station data
!------------------------------------------------------------------------------
SUBROUTINE WriteCTL_STN( sNameCTL, sNameDAT, sNameMAP, sTITLE, rUNDEF,  &
                         iNTIM, iTINC, iHH, iMM, iDD, iMMM, iYYYY,      &
                         iNVARS,                                        &
                         svABRV,svDSCR, ivVLEVS,                        &
                         inc_mm, inc_hr, inc_dy, inc_mo, inc_yr,        &
                         lOKflag )
!------------------------------------------------------------------------------
! Description:
! Read a CTL descriptor file for gridded data.
! See GrADS user guide.
!   (available at http://grads.iges.org/grads/grads.html)
!
! Current Code owner: Cristian Lussana
!
! History:
!
! Version     Date        Comment
! -------    -------     ---------
!  1.0       28/9/04   Original code. Cristian Lussana
!
! Code description:
! Language: Fortran 90
! Software standards: "European Standards for Writing and
!                      Documenting Exchangeable Fortran 90 Code"
!-----------------------------------------------------------------
! Declarations:

! * Subroutine arguments:
! Scalar arguments with intent(in):
CHARACTER(*),  intent(in)   :: sNameCTL
CHARACTER(*),  intent(in)   :: sNameDAT
CHARACTER(*),  intent(in)   :: sNameMAP
CHARACTER(*),  intent(in)   :: sTITLE
REAL,          intent(in)   :: rUNDEF
INTEGER,       intent(in)   :: iNTIM
INTEGER,       intent(in)   :: iTINC
INTEGER,       intent(in)   :: iHH
INTEGER,       intent(in)   :: iMM
INTEGER,       intent(in)   :: iDD
INTEGER,       intent(in)   :: iMMM
INTEGER,       intent(in)   :: iYYYY
INTEGER,       intent(in)   :: iNVARS
LOGICAL,       intent(in)   :: inc_mm
LOGICAL,       intent(in)   :: inc_hr
LOGICAL,       intent(in)   :: inc_dy
LOGICAL,       intent(in)   :: inc_mo
LOGICAL,       intent(in)   :: inc_yr
! Scalar arguments with intent(out):
LOGICAL,       intent(out)   :: lOKflag
! Arrays arguments with intent(out)
CHARACTER(12),pointer        :: svABRV(:)
CHARACTER(40),pointer        :: svDSCR(:)
! Etichette dei livelli verticali 1D
INTEGER, pointer             :: ivVLEVS(:)

! * End of subroutine arguments

! Locals
CHARACTER(300)   :: sBuffer, sBuffer1, sBuffer2, sBuffer3
INTEGER          :: iErr
INTEGER          :: i, ii, len
!------------------------------------------------------------------------------
!! -- DEBUG
!  PRINT *,'sNameCTL=',sNameCTL
!  PRINT *,'sNameDAT=',sNameDAT
!  PRINT *,'sNameMAP=',sNameMAP
!  PRINT *,'sTITLE=',sTITLE
!  PRINT *,'rUNDEF=',rUNDEF
!  PRINT *,'iNTIM=',iNTIM
!  PRINT *,'iTINC=',iTINC
!  PRINT *,'iHH=',iHH
!  PRINT *,'iMM=',iMM
!  PRINT *,'iDD=',iDD
!  PRINT *,'iMMM=',iMMM
!  PRINT *,'iYYYY=',iYYYY
!  PRINT *,'inc_mm=',inc_mm
!  PRINT *,'inc_hr=',inc_hr
!  PRINT *,'inc_dy=',inc_dy
!  PRINT *,'inc_mo=',inc_mo
!  PRINT *,'inc_yr=',inc_yr
!  DO i=1,SIZE(svABRV)
!    PRINT *,'svABRV(',i,')=',svABRV(i)
!  ENDDO
!  DO i=1,SIZE(svDSCR)
!    PRINT *,'svDSCR(',i,')=',svDSCR(i)
!  ENDDO
!  DO i=1,SIZE(svABRV)
!    PRINT *,'ivVLEVS(',i,')=',ivVLEVS(i)
!  ENDDO
!! -- END DEBUG
  lOKflag = .FALSE.
! Apri file .CTL sul quale scriver?
  OPEN( 100,FILE=sNameCTL,STATUS='UNKNOWN',FORM='FORMATTED', &
        ACTION='WRITE',IOSTAT=iErr )
  IF (iErr/=0) RETURN

  sBuffer = 'DSET  ' // TRIM(ADJUSTL(sNameDAT))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)

  sBuffer = 'DTYPE  station'
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)

  sBuffer = 'STNMAP  ' // TRIM(ADJUSTL(sNameMAP))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)

  sBuffer = 'TITLE  ' // TRIM(ADJUSTL(sTITLE))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)

  WRITE(sBuffer1,*,IOSTAT=iErr) rUNDEF
  sBuffer = 'UNDEF  ' // TRIM(ADJUSTL(sBuffer1))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)

  sBuffer2 = ''
  WRITE(sBuffer1,*,IOSTAT=iErr) iHH
  IF ( LEN_TRIM(ADJUSTL(sBuffer1))<2 ) THEN
    sBuffer2(1:1) = '0'
    sBuffer1 = ADJUSTL(sBuffer1)
    sBuffer2(2:2) = sBuffer1(1:1)
  ELSE
    sBuffer1 = ADJUSTL(sBuffer1)
    sBuffer2(1:2) = sBuffer1(1:2)
  ENDIF
  sBuffer2(3:3) = ':'
  WRITE(sBuffer1,*,IOSTAT=iErr) iMM
  IF ( LEN_TRIM(ADJUSTL(sBuffer1))<2 ) THEN
    sBuffer2(4:4) = '0'
    sBuffer1 = ADJUSTL(sBuffer1)
    sBuffer2(5:5) = sBuffer1(1:1)
  ELSE
    sBuffer1 = ADJUSTL(sBuffer1)
    sBuffer2(4:5) = sBuffer1(1:2)
  ENDIF
  sBuffer2(6:6) = 'Z'
  WRITE(sBuffer1,*,IOSTAT=iErr) iDD
  IF ( LEN_TRIM(ADJUSTL(sBuffer1))<2 ) THEN
    sBuffer2(7:7) = '0'
    sBuffer1 = ADJUSTL(sBuffer1)
    sBuffer2(8:8) = sBuffer1(1:1)
  ELSE
    sBuffer1 = ADJUSTL(sBuffer1)
    sBuffer2(7:8) = sBuffer1(1:2)
  ENDIF
  WRITE(sBuffer1,*,IOSTAT=iErr) iYYYY
  sBuffer1 = ADJUSTL(sBuffer1)
  sBuffer2(12:15) = sBuffer1(1:4)
  SELECT CASE (iMMM)
    CASE(1)
      sBuffer2(9:11) = 'jan'
    CASE(2)
      sBuffer2(9:11) = 'feb'
    CASE(3)
      sBuffer2(9:11) = 'mar'
    CASE(4)
      sBuffer2(9:11) = 'apr'
    CASE(5)
      sBuffer2(9:11) = 'may'
    CASE(6)
      sBuffer2(9:11) = 'jun'
    CASE(7)
      sBuffer2(9:11) = 'jul'
    CASE(8)
      sBuffer2(9:11) = 'aug'
    CASE(9)
      sBuffer2(9:11) = 'sep'
    CASE(10)
      sBuffer2(9:11) = 'oct'
    CASE(11)
      sBuffer2(9:11) = 'nov'
    CASE(12)
      sBuffer2(9:11) = 'dec'
    CASE DEFAULT
      RETURN
  END SELECT
  sBuffer2(16:16) = ' '
  WRITE(sBuffer3,*,IOSTAT=iErr) iTINC
  len = LEN_TRIM(ADJUSTL(sBuffer3))
  sBuffer2(17:17+len-1) = ADJUSTL(sBuffer3)
  IF (inc_mm) sBuffer2(17+len:17+len+1) = 'MN'
  IF (inc_hr) sBuffer2(17+len:17+len+1) = 'HR'
  IF (inc_dy) sBuffer2(17+len:17+len+1) = 'DY'
  IF (inc_mo) sBuffer2(17+len:17+len+1) = 'MO'
  IF (inc_yr) sBuffer2(17+len:17+len+1) = 'YR'
  WRITE(sBuffer1,*,IOSTAT=iErr) iNTIM
  sBuffer = 'TDEF  ' // TRIM(ADJUSTL(sBuffer1)) // ' LINEAR ' // &
            TRIM(ADJUSTL(sBuffer2))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)

  WRITE(sBuffer1,*,IOSTAT=iErr) iNVARS
  sBuffer = 'VARS  ' // TRIM(ADJUSTL(sBuffer1))
  WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)
  DO i=1,iNVARS
    WRITE(sBuffer1,*,IOSTAT=iErr) ivVLEVS(i)
    sBuffer = TRIM(ADJUSTL(svABRV(i))) // '  ' // TRIM(ADJUSTL(sBuffer1)) &
              // '  99  ' // TRIM(ADJUSTL(svDSCR(i)))
    WRITE(100,"(A)",IOSTAT=iErr) TRIM(sBuffer)
  ENDDO
  WRITE(100,"(A8)",IOSTAT=iErr) 'ENDVARS '

  CLOSE(100)

  lOKflag = .TRUE.

END SUBROUTINE WriteCTL_STN

!+ Write a ".dat" binary file for station data
!------------------------------------------------------------------------------
SUBROUTINE WriteDAT_STN( iLUN,       &
                         tvSTN,      &
                         iNSTAT,     &
                         iNVARS,     &
                         iNVARS_LD,  &
                         iNVARS_SFC, &
                         lOKflag )
!------------------------------------------------------------------------------
! Declarations:

! * Subroutine arguments:
! Scalar arguments with intent(in):
INTEGER,       intent(in)    :: iLUN
INTEGER,       intent(in)    :: iNVARS
INTEGER,       intent(in)    :: iNVARS_LD
INTEGER,       intent(in)    :: iNVARS_SFC
INTEGER,       intent(in)    :: iNSTAT
! Scalar arguments with intent(out):
LOGICAL,       intent(out)   :: lOKflag
! Arrays arguments with intent(out)
TYPE(StazData), pointer      :: tvSTN(:)
! Locals
CHARACTER(8)  :: sID
REAL          :: rX
REAL          :: rY
REAL          :: rt
REAL          :: rLEVEL
INTEGER       :: iNLEV, iNLEV_LD
!INTEGER       :: iFLAG
INTEGER       :: iRetCode
INTEGER       :: i, k, s, m, vs, vl
!------------------------------------------------------------------------------
  lOKflag = .FALSE.
  IF ( .not.ASSOCIATED( tvSTN ) ) RETURN
  DO s=1,iNSTAT
    WRITE(iLUN,IOSTAT=iRetCode) tvSTN(s)%ID
    WRITE(iLUN,IOSTAT=iRetCode) tvSTN(s)%Y
    WRITE(iLUN,IOSTAT=iRetCode) tvSTN(s)%X
    WRITE(iLUN,IOSTAT=iRetCode) tvSTN(s)%t
    WRITE(iLUN,IOSTAT=iRetCode) tvSTN(s)%NLEV
    WRITE(iLUN,IOSTAT=iRetCode) tvSTN(s)%FLAG
!-D
!    WRITE(6,*,IOSTAT=iRetCode) tvSTN(s)%ID
!    WRITE(6,*,IOSTAT=iRetCode) tvSTN(s)%Y
!    WRITE(6,*,IOSTAT=iRetCode) tvSTN(s)%X
!    WRITE(6,*,IOSTAT=iRetCode) tvSTN(s)%t
!    WRITE(6,*,IOSTAT=iRetCode) tvSTN(s)%NLEV
!    WRITE(6,*,IOSTAT=iRetCode) tvSTN(s)%FLAG
!-D
    IF (tvSTN(s)%NLEV==0)  RETURN
    IF ( (tvSTN(s)%NLEV-tvSTN(s)%FLAG)>0 ) THEN
      IF (.not.ASSOCIATED( tvSTN(s)%LD_VARS ) ) RETURN
    ENDIF
    DO k=1,tvSTN(s)%NLEV
      IF ( (tvSTN(s)%FLAG==1).and.(k==1) ) THEN
        IF (.not.ASSOCIATED( tvSTN(s)%SFC_VARS ) ) RETURN
        DO vs=1,iNVARS_SFC
          WRITE(iLUN,IOSTAT=iRetCode) tvSTN(s)%SFC_VARS(vs)
!-D
!          WRITE(6,*,IOSTAT=iRetCode) 'tvSTN(',s,')%SFC_VARS(',vs,')=',tvSTN(s)%SFC_VARS(vs)
!-D
        ENDDO
        CYCLE
      ENDIF
      m = k - tvSTN(s)%FLAG
      rLEVEL = tvSTN(s)%LD_VARS(1,m)
      WRITE(iLUN,IOSTAT=iRetCode) rLEVEL
!-D
!      WRITE(6,*,IOSTAT=iRetCode) 'rLEVEL=',rLEVEL
!-D
      DO vl=2,iNVARS_LD+1
        WRITE(iLUN,IOSTAT=iRetCode) tvSTN(s)%LD_VARS(vl,m)
!-D
!        WRITE(6,*,IOSTAT=iRetCode) 'tvSTN(',s,')%LD_VARS(',vl,',',m,')=',tvSTN(s)%LD_VARS(vl,m)
!-D
      ENDDO
    ENDDO
  ENDDO
! Scrivi la riga di fine tempo
  WRITE(iLUN,IOSTAT=iRetCode) tvSTN(1)%ID
  WRITE(iLUN,IOSTAT=iRetCode) tvSTN(1)%X
  WRITE(iLUN,IOSTAT=iRetCode) tvSTN(1)%Y
  WRITE(iLUN,IOSTAT=iRetCode) tvSTN(1)%t
  WRITE(iLUN,IOSTAT=iRetCode) 0
  WRITE(iLUN,IOSTAT=iRetCode) tvSTN(1)%FLAG
!-D
!  WRITE(6,*,IOSTAT=iRetCode) tvSTN(1)%ID
!  WRITE(6,*,IOSTAT=iRetCode) tvSTN(1)%X
!  WRITE(6,*,IOSTAT=iRetCode) tvSTN(1)%Y
!  WRITE(6,*,IOSTAT=iRetCode) tvSTN(1)%t
!  WRITE(6,*,IOSTAT=iRetCode) 0
!  WRITE(6,*,IOSTAT=iRetCode) tvSTN(1)%FLAG
!-D
! Normal end
  lOKflag = .TRUE.
END SUBROUTINE WriteDAT_STN

!+ Estrae una serie temporale da un file DAT
!------------------------------------------------------------------------------
SUBROUTINE ReadSVL_STN( sNameCTL,  &
                        sIDSTAT,   &
                        sIDVAR,    &
                        rIDLEV,    &
                        rvOUT,     &
                        lOKflag )
!------------------------------------------------------------------------------
! Descrizione:
! Estrae la serie temporale della stazione "sIDSTAT", variabile "sIDVAR",
! livello "rIDLEV" (rIDLEV<0 -> "sIDVAR" ? di tipo SFC) dal file GrADS
! .DAT specificato nel file d'intestazione "sNameCTL".
! Note:
! Errore se:
! (1) il file CTL non esiste;
! (2) non riesce a leggere correttamente il file CTL (vedi "ReadCTL_STN");
! (3) "rvOUT" gi? allocato e non riesce a deallocarlo;
! (4) non riesco ad allocare "rvOUT";
! (5) specifico un livello per una variabile di superficie;
! (6) non specifico un livello per una variabile LD (Level Dependent);
! (7) non esiste il file .DAT o non riesce ad aprirlo correttamente;
! (8) problemi nella lettura del file .DAT (vedi "ReadDAT_STN");
! (9) problemi nel deallocare la struttura "tvSTN" (vedi "GrADSfreeStn);
!
! Comportamenti particolari:
! (1) se la variabile "sIDVAR" non ? fra quelle presenti all'interno del file
!     .CTL allora restituisci "rvOUT" riempito con valori di "rUNDEF"
! (2) il record "tvOUT(t)" pu? essere uguale ad "rUNDEF" se:
!     (a) il valore nel file .DAT ? "rUNDEF";
!     (b) la stazione richiesta non ? presente al tempo "t" nel file .DAT;
!     (c) la variabile ? LD ma il livello richiesto non figura fra quelli
!         presenti al tempo "t";
!
! Variabili IN&OUT:
! IN:
! sNameCTL  -  percorso+nome del file .CTL
! sIDSTAT   -  ID stazione da estrarre
! sIDVAR    -  abbreviazione (sABRV) variabile da estrarre (stringa)
! rIDLEV    -  livello da estrarre (<0 indica una varibile SFC)
! OUT:
! rvOUT     -  vettore reale di dimensione "iNTIM" con la serie temporale
! lOKflag   -  TRUE=tutto OK ; FALSE=problemi
!
!
! Declarations:

! * Subroutine arguments:
! Scalar arguments with intent(in):
CHARACTER(*),  intent(IN)    :: sNameCTL
CHARACTER(8),  intent(IN)    :: sIDSTAT
CHARACTER(12), intent(IN)    :: sIDVAR
REAL,          intent(IN)    :: rIDLEV
! Scalar arguments with intent(out):
LOGICAL,       intent(out)   :: lOKflag
! Arrays arguments with intent(out)
REAL,          pointer      :: rvOUT(:)

! Locals
CHARACTER(200) :: sNameDAT
REAL           :: rUNDEF
INTEGER        :: iNTIM, iTINC, iHH, iMM, iDD, iMMM, iYYYY
INTEGER        :: iNVARS, iNVARS_SFC, iNVARS_LD
INTEGER        :: iNSTAT, iNSTAT_SFC, iNSTAT_LD
LOGICAL        :: inc_mm, inc_hr, inc_dy, inc_mo, inc_yr
INTEGER        :: iDebug
INTEGER        :: v, t, s, m
LOGICAL        :: lFlag, lExist
INTEGER        :: iRetCode
INTEGER        :: iPos
LOGICAL        :: SFC_flag
INTEGER        :: iNLEVS_LD

CHARACTER(12),pointer        :: svABRV(:)
CHARACTER(40),pointer        :: svDSCR(:)
! Etichette dei livelli verticali 1D
INTEGER, pointer             :: ivVLEVS(:)

TYPE(StazData), pointer      :: tvSTN(:)
!------------------------------------------------------------------------------
  lOKflag = .FALSE.
! Inizializza
  sNameDAT=''
  NULLIFY(svABRV)
  NULLIFY(svDSCR)
  NULLIFY(ivVLEVS)
  IF ( ASSOCIATED(tvSTN) ) THEN
    CALL GrADSfreeStn(tvSTN,SIZE(tvSTN),lFlag)
    IF (.not.lFlag) RETURN
  ENDIF
! Leggi file .CTL
  INQUIRE( FILE=sNameCTL, EXIST=lExist )
  IF (.not.lExist) RETURN
  iDebug = 0
  CALL ReadCTL_STN( sNameCTL, sNameDAT, rUNDEF,                 &
                    iNTIM, iTINC, iHH, iMM, iDD, iMMM, iYYYY,   &
                    iNVARS, iNVARS_SFC, iNVARS_LD,              &
                    svABRV,svDSCR, ivVLEVS,                     &
                    inc_mm, inc_hr, inc_dy, inc_mo, inc_yr,     &
                    iDebug, lFlag )
  IF (.not.lFlag) RETURN
!============================================================================
  IF ( ASSOCIATED(rvOUT) ) THEN
    DEALLOCATE( rvOUT, STAT=iRetCode )
    IF (iRetCode/=0) RETURN
  ENDIF
  ALLOCATE( rvOUT(iNTIM), STAT=iRetCode )
  IF (iRetCode/=0) RETURN
!============================================================================
! Identifica la variabile da leggere
  DO v=1,iNVARS
    ! QUESTO IF POTREBBE DARE PROBLEMI DATO CHE HO DUE STRINGHE
    IF ( svABRV(v) == sIDVAR ) EXIT
  ENDDO
  ! se sto richiedendo una variabile non presente nel file allora
  ! ritorna un vettore tutto "rUNDEF"
  IF ( v > iNVARS) THEN
    DO t=1,iNTIM
      rvOUT(t) = rUNDEF
    ENDDO
    RETURN
  ENDIF
  ! se sono arrivato qui allora v<iNVARS
  ! controllo: se la variabile ? SFC e io voglio un livello vert -> esci
  IF ( (ivVLEVS(v)==0).and.(rIDLEV>0) ) RETURN
  ! controllo: se la variabile ? LD e io non specifico livello   -> esci
  IF ( (ivVLEVS(v)/=0).and.(rIDLEV<0) ) RETURN
  ! se sono arrivato qui allora la richiesta eseguita ? formalmente corretta
  ! ora setto SFC_flag e la posizione della variabile all'interno del gruppo
  ! di variabili corrispondenti: SFC o LD
  IF ( ivVLEVS(v)==0 ) THEN
     SFC_flag = .TRUE.
     iPos     = v
  ELSE
     SFC_flag = .FALSE.
     ! tieni conto del gruppo di varibili SFC e del campo "livello" del file DAT
     iPos     = v - iNVARS_SFC + 1
  ENDIF
! Apri file .DAT
  INQUIRE( FILE=TRIM(sNameDAT), EXIST=lExist )
  IF (.not.lExist) RETURN
!  OPEN(1000, FILE=TRIM(sNameDAT), FORM='BINARY', IOSTAT=iRetCode )
  OPEN(1000, FILE=TRIM(sNameDAT), FORM='UNFORMATTED', IOSTAT=iRetCode )
  IF (iRetCode/=0) RETURN
! Ciclo su tutti i tempi
  DO t=1,iNTIM
    ! Leggi records del tempo "t" dal file .DAT
    CALL ReadDAT_STN( 1000, tvSTN, iNSTAT, iNSTAT_SFC, iNSTAT_LD,  &
                      iNVARS, iNVARS_LD, iNVARS_SFC, iDebug, lFlag )
    IF (.not.lFlag) THEN
      CALL GrADSfreeStn( tvSTN, iNSTAT, lFlag )
      CLOSE(1000)
      RETURN
    ENDIF
    DO s=1,iNSTAT
     ! QUESTO IF POTREBBE DARE PROBLEMI DATO CHE HO DUE STRINGHE
      IF ( tvSTN(s)%ID==sIDSTAT ) EXIT
    ENDDO
    ! 1: se la stazione non ? fra quelle presenti al tempo "t" nel file
    IF ( s > iNSTAT ) THEN
      rvOUT(t) = rUNDEF
    ! 1: se la stazione ? presente
    ELSE
      ! 2: se la variabile ? di SFC
      IF (SFC_flag) THEN
        IF ( ASSOCIATED(tvSTN(s)%SFC_VARS) ) THEN
          rvOUT(t) = tvSTN(s)%SFC_VARS(iPos)
        ELSE
          rvOUT(t) = rUNDEF
        ENDIF
      ! 2: se la variabile ? LD
      ELSE
        ! ricerca livello "rIDLEV" fra livelli presenti
        iNLEVS_LD = tvSTN(s)%NLEV - tvSTN(s)%FLAG
        DO m=1,iNLEVS_LD
          IF ( tvSTN(s)%LD_VARS(1,m)==rIDLEV) EXIT
        ENDDO
        ! 3: se "rIDLEV" non figura fra i livelli presenti
        IF (m > iNLEVS_LD) THEN
          rvOUT(t) = rUNDEF
        ! 3: se "rIDLEV" figura fra i livelli presenti
        ELSE
          ! N.B. iPos tiene gi? conto del livello memorizzato
          ! in "LDVARS(1,m)"
          rvOUT(t) = tvSTN(s)%LD_VARS(iPos,m)
        ENDIF ! -fine IF 3 -
      ENDIF ! -fine IF 2 -
    ENDIF ! -fine IF 1 -
    CALL GrADSfreeStn( tvSTN, iNSTAT, lFlag )
    IF (.not.lFlag) THEN
      CLOSE(1000)
      RETURN
    ENDIF
  ENDDO ! - fine ciclo tempo -

! Uscita normale
  CLOSE(1000)
  CALL GrADSfreeStn( tvSTN, iNSTAT, lFlag )
  lOKflag = .TRUE.

END SUBROUTINE ReadSVL_STN

!==============================================================================
!                    G E N E R A L    U T I L I T I E S
!==============================================================================

!+ Libera lo spazio di memoria per una struttura "StazData"
!------------------------------------------------------------------------------
SUBROUTINE GrADSfreeStn( tvSTN,      &
                         iNSTAT,     &
                         lOKflag )
!------------------------------------------------------------------------------
! Declarations:

! * Subroutine arguments:
! Scalar arguments with intent(in):
INTEGER,       intent(in)    :: iNSTAT
! Scalar arguments with intent(out):
LOGICAL,       intent(out)   :: lOKflag
! Arrays arguments with intent(out)
TYPE(StazData), pointer      :: tvSTN(:)
! Locals
CHARACTER(8)  :: sID
REAL          :: rX
REAL          :: rY
REAL          :: rt
INTEGER       :: iNLEV, iNLEV_LD
INTEGER       :: iFLAG
INTEGER       :: iRetCode
INTEGER       :: i, k, s, m, vs, vl
!------------------------------------------------------------------------------
  iRetCode = 0
  lOKflag = .TRUE.
  IF (.not.ASSOCIATED(tvSTN) ) RETURN
  DO s=1,iNSTAT
    IF (ASSOCIATED(tvSTN(s)%SFC_VARS)) THEN
!      DEALLOCATE(tvSTN(s)%SFC_VARS,STAT=iRetCode)  == 17/08/05 ==
      DEALLOCATE(tvSTN(s)%SFC_VARS,STAT=iRetCode)
      NULLIFY( tvSTN(s)%SFC_VARS )
!      PRINT *,'GrADSfreeStn: deallocata "tvSTN(s)%SFC_VARS" con s=',s
    ELSE
      NULLIFY ( tvSTN(s)%SFC_VARS )
    ENDIF
    IF (iRetCode/=0) lOKflag = .FALSE.
    IF (ASSOCIATED(tvSTN(s)%LD_VARS))  THEN
      DEALLOCATE(tvSTN(s)%LD_VARS,STAT=iRetCode)
!      PRINT *,'GrADSfreeStn: deallocata "tvSTN(s)%LD_VARS" con s=',s
      NULLIFY( tvSTN(s)%LD_VARS )
    ELSE
      NULLIFY ( tvSTN(s)%LD_VARS )
    ENDIF
    IF (iRetCode/=0) lOKflag = .FALSE.
  ENDDO
  IF ( ASSOCIATED(tvSTN) )  DEALLOCATE( tvSTN, STAT=iRetCode )
  IF (iRetCode/=0) lOKflag = .FALSE.
  NULLIFY( tvSTN )

END SUBROUTINE GrADSfreeStn

!+ Alloca lo spazio di memoria per una struttura "StazData"
!------------------------------------------------------------------------------
SUBROUTINE GrADSallocStn( tvSTN,      &
                          iNSTAT,     &
                          lOKflag )
!------------------------------------------------------------------------------
! Declarations:

! * Subroutine arguments:
! Scalar arguments with intent(in):
INTEGER,       intent(in)    :: iNSTAT
! Scalar arguments with intent(out):
LOGICAL,       intent(out)   :: lOKflag
! Arrays arguments with intent(out)
TYPE(StazData), pointer      :: tvSTN(:)
! Locals
INTEGER       :: iRetCode
INTEGER       :: s
LOGICAL       :: lFlag
!------------------------------------------------------------------------------
  iRetCode = 0
  lOKflag = .FALSE.
  IF ( ASSOCIATED(tvSTN) ) THEN
    CALL GrADSfreeStn( tvSTN, SIZE(tvSTN), lFlag )
    IF (.not.lFlag) RETURN
  ENDIF
  ALLOCATE( tvSTN(iNSTAT), STAT=iRetCode )
  IF (iRetCode/=0) RETURN
  DO s=1,iNSTAT
    tvSTN(s)%ID = ''
    tvSTN(s)%X  = 0.0
    tvSTN(s)%Y  = 0.0
    tvSTN(s)%t  = 0.0
    tvSTN(s)%NLEV = 0
    tvSTN(s)%FLAG = 0
    NULLIFY( tvSTN(s)%LD_VARS )
    NULLIFY( tvSTN(s)%SFC_VARS )
  ENDDO
! Uscita normale
  lOKflag = .TRUE.

END SUBROUTINE GrADSallocStn

!+ Cambia l'estensione da ".ctl" a ".dat"
!------------------------------------------------------------------------------
SUBROUTINE NameCTL2DAT( sFileCTL, sFileDAT, lOKflag)
!------------------------------------------------------------------------------
! Declarations:

! * Subroutine arguments:
! Scalar arguments with intent(in):
CHARACTER(*),       intent(IN)    :: sFileCTL
! Scalar arguments with intent(out):
CHARACTER(*),       intent(OUT)   :: sFileDAT
LOGICAL     ,       intent(OUT)   :: lOKflag
! Locals
INTEGER       :: i
!------------------------------------------------------------------------------
  sFileDAT=''
  lOKflag = .TRUE.
  DO i=LEN_TRIM(sFileCTL),1,-1
    IF ( sFileCTL(i:i)=='.' ) EXIT
  ENDDO
  IF (i < 1) THEN
    lOKflag = .FALSE.
    RETURN
  ENDIF
  sFileDAT(1:i)     = sFileCTL(1:i)
  sFileDAT(i+1:i+3) = 'dat'
END SUBROUTINE NameCTL2DAT

!+ Cambia l'estensione da ".ctl" a ".map"
!------------------------------------------------------------------------------
SUBROUTINE NameCTL2MAP( sFileCTL, sFileMAP, lOKflag)
!------------------------------------------------------------------------------
! Declarations:

! * Subroutine arguments:
! Scalar arguments with intent(in):
CHARACTER(*),       intent(IN)    :: sFileCTL
! Scalar arguments with intent(out):
CHARACTER(*),       intent(OUT)   :: sFileMAP
LOGICAL     ,       intent(OUT)   :: lOKflag
! Locals
INTEGER       :: i
!------------------------------------------------------------------------------
  sFileMAP=''
  lOKflag = .TRUE.
  DO i=LEN_TRIM(sFileCTL),1,-1
    IF ( sFileCTL(i:i)=='.' ) EXIT
  ENDDO
  IF (i < 1) THEN
    lOKflag = .FALSE.
    RETURN
  ENDIF
  sFileMAP(1:i)     = sFileCTL(1:i)
  sFileMAP(i+1:i+3) = 'map'
END SUBROUTINE NameCTL2MAP


END MODULE GrADSlib_new
!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
