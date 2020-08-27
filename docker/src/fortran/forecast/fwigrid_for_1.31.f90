!+ Calcolo indici FWI su griglia regolare a partire da campi meteo previsti 
!##############################################################################
PROGRAM fwigrid_for
!##############################################################################
!------------------------------------------------------------------------------

! Description:
! ============

! History:
! ========
!  date        comment
!  ----        -------
!  06/03/10     RG. versione 1.0

!  05/04/10     RG  versione 1.1  modifica formula per calcolo rh
!  12/04/11     RG  versione 1.2  correzione per errore calcolo precipitazione secondo giorno (input con tp cumulate progressive, non sulle 24h)
!  23/05/11     RG  versione 1.3  cambio formato file ctrl meteo e ur per verifica con grass
!  23/05/11     RG  versione 1.31 cambio sintassi per compilatore gfortran (cambiato $ in S in tutte le variabili)
!
!===============================================================================

IMPLICIT NONE

INTEGER, parameter :: iMAXPT=1500
INTEGER, parameter :: iUNDEF=-9999
REAL,    parameter :: rUNDEF=-9999.
REAL,    parameter :: rUNDEF_FWI=-9999.
!REAL,    parameter :: rUNDEF_FWI=0

INTEGER       ::  i,j,m,ind,km,kd,kk,ng,nn,mm,ipt
INTEGER       ::  imo,inorm,idef,num,iNP,iRetCode,idum
INTEGER       ::  iFILO(6,2),iFILOC(6,2),iFILIN(3),iFILICN(3),iFILIM(4,2),iFILICM(4,2) 
INTEGER       ::  clamc,clafm,cladm,cladc,clais,clabu,clafw,clads
INTEGER       ::  iYYYY2,iMMM2,iDD2,iYYYY1,iMMM1,iDD1,iYYYY0,iMMM0,iDD0
INTEGER       ::  iYYYY1b,iMMM1b,iDD1b,iYYYY0b,iMMM0b,iDD0b
INTEGER       ::  iFWIcla(iMAXPT,6,2)
CHARACTER(8)  ::  Sgiorno(2),Sieri,Soggi,Sdomani
CHARACTER(7)  ::  Slatrif,Slonrif,Slatrif2,Slonrif2
CHARACTER     ::  dum*2,Skd*1,Sng*1,SrvFWIout*11,Sipt*4,Sriga*50,Sur*5,Smet*5
CHARACTER(70) ::  sPATH0,sPATH1,sPATH2,sPATH3
CHARACTER(30) ::  sFILO(6),sFILOC(6), sFILIM(4,2),sFILICM(4,2)
REAL(8)       ::  fo,po,dot,ffm,dmc,dc
REAL(8)       ::  wmo,wmi,ra,ed,z,x,wm,ew,rk,rw,b,wmr,pr
REAL(8)       ::  pe,smi,dr,si,mc,fm,sf,bui,p,cc,bb,fwi,sl,dsr
REAL          ::  el(12),fl(12),w,t,td,h,r,fod,pod,dotd
REAL          ::  tok,rdum1,rdum2,rdum3,rdum4,rdum5,rdum6,ur,esat_t,esat_td
REAL(8)       ::  rvFWIinp(iMAXPT,3,2),rvFWIout(iMAXPT,6,2)
REAL          ::  met(iMAXPT,4,2)
REAL          ::  vrif(iMAXPT),latrif(iMAXPT),lonrif(iMAXPT),latrif2(iMAXPT),lonrif2(iMAXPT)
REAL          ::  lat1,lon1,lat2,lon2,val,val1,val2
REAL          ::  fmcl(12,5),dmcl(12,5),dcl(12,5),iscl(12,5),bucl(12,5),fwcl(12,5)
REAL          ::  mcl(12,5),dscl(12,5)
REAL          ::  rXLCORN,rYLCORN,rCELLSIZE,rXLCORNok,rYLCORNok,rCELLSIZEok,rUNDEF_GRAS

! EL = fattori giornalieri per DMC
! FL = fattori giornalieri per DC

DATA el /6.5,7.5,9.0,12.8,13.9,13.9,12.4,10.9,9.4,8.0,7.0,6.0/
DATA fl /-1.6,-1.6,-1.6,0.9,3.8,5.8,6.4,5.0,2.4,0.4,-1.6,-1.6/

DATA (sFILIM(km,1), km=1,4) /"t_lami_","td_lami_","vv_lami_","tp_lami_"/  ! file grid con dati meteo previsti dal COSMO I7 (giorno 1)
DATA (sFILIM(km,2), km=1,4) /"t_lami_","td_lami_","vv_lami_","tp_lami_"/  ! file grid con dati meteo previsti dal COSMO I7 (giorno 2)
DATA (sFILICM(km,1), km=1,4) /"t_lami_","td_lami_","vv_lami_","tp_lami_"/  ! file grid con dati meteo previsti (per controllo)
DATA (sFILICM(km,2), km=1,4) /"t_lami_","td_lami_","vv_lami_","tp_lami_"/  ! file grid con dati meteo previsti (per controllo)

DATA sFILO /"ffmc_lami_","dmc_lami_","dc_lami_","isi_lami_","bui_lami_","fwi_lami_"/                ! file grid con indici numerici (input e output)
DATA sFILOC /"ffmc_lami_c_","dmc_lami_c_","dc_lami_c_","isi_lami_c_","bui_lami_c_","fwi_lami_c_"/  ! file grid con indici in classi (output)

DATA iFILIN /71,72,73/
DATA iFILICN /51,52,53/
DATA (iFILIM(km,1), km=1,4) /61,62,63,64/
DATA (iFILIM(km,2), km=1,4) /65,66,67,68/
DATA (iFILICM(km,1), km=1,4) /41,42,43,44/
DATA (iFILICM(km,2), km=1,4) /45,46,47,48/
DATA (iFILO(kk,1), kk=1,6) /81,82,83,84,85,86/
DATA (iFILO(kk,2), kk=1,6) /87,88,89,90,91,92/
DATA (iFILOC(kk,1), kk=1,6) /101,102,103,104,105,106/
DATA (iFILOC(kk,1), kk=1,6) /107,108,109,110,111,112/

!-------------------------------------------------------------------------------

! percorso della directory di lavoro con "/" finale (quella contenente almeno le directory ini e log, eventualmente anche l'eseguibile fwigrid_for)

! sPATH0 = "/home/meteo/programmi/fwi_grid/"
sPATH0 = "/fwi/data/"

! rg  modificato: ora sono letti da fwigrid_for.ini
!  sPATH1 = "/home/meteo/programmi/fwi_grid/indici/ana/"   ! percorso con file indici (input da analisi)
!  sPATH2 = "/home/meteo/programmi/fwi_grid/meteo/prev/"    ! percorso con file meteo (input previsti da COSMO I7)
!  sPATH3 = "/home/meteo/programmi/fwi_grid/indici/prev/"   ! percorso con file indici (output)

vrif=1
inorm=0
latrif=rUNDEF
lonrif=rUNDEF
latrif2=rUNDEF
lonrif2=rUNDEF
rvFWIout=rUNDEF_FWI
rvFWIinp=rUNDEF_FWI
sPATH0=TRIM(ADJUSTL(sPATH0))


! lettura file fwigrid_for.ini

OPEN(11,file=TRIM(sPATH0)//"ini/fwigrid_for.ini",status="old",IOSTAT=iRetCode)
IF (iRetCode/=0) THEN
  PRINT *,'fwigrid_for: error opening file fwigrid_for.ini'
  STOP 1
ENDIF
READ(11,"(a70)") sPATH1              ! (a70) percorso della directory con file indici (input da analisi) con "/" finale
READ(11,"(a70)") sPATH2              ! (a70) percorso della directory con file meteo (input previsti da COSMO I7) con "/" finale
READ(11,"(a70)") sPATH3              ! (a70) percorso della directory con file indici (output) con "/" finale
READ(11,*)                           ! riga vuota
READ(11,*) iNP                       ! numero punti del grigliato
READ(11,*) rYLCORNok                 ! latitudine angolo sudovest del grigliato originale COSMO I7 (grid point)
READ(11,*) rXLCORNok                 ! longitudine angolo sudovest del grigliato originale COSMO I7 (grid point)
READ(11,*) rCELLSIZEok               ! passo di griglia del grigliato originale (gradi)
READ(11,*)                           ! riga vuota
READ(11,*) fod,pod,dotd              ! valori iniziali di default per FFMC,DMC,DC
READ(11,*) idef                      ! se = 1, in caso di sottoindici di inizializ. invalidi, uso il default, altrimenti pongo =rUNDEF_FWI
READ(11,*) rUNDEF_GRAS               ! valore per "dato non definito" introdotto da GRASS nella conversione da GB a LatLon
CLOSE(11)

! lettura file data_for.ini

OPEN(18,file=TRIM(sPATH0)//"ini/data_for.ini",status="old",IOSTAT=iRetCode)
IF (iRetCode/=0) THEN
  PRINT *,'fwigrid_for: error opening file data_for.ini'
  STOP 1
ENDIF
READ(18,"(a8,2x,a8,2x,a8)")  Sieri,Soggi,Sdomani        ! data di ieri, oggi (ng=1) e data di domani (ng=2)
CLOSE(18)

Sgiorno(1)=Soggi
Sgiorno(2)=Sdomani


OPEN(14,file=TRIM(sPATH0)//"log/fwigrid_for_"//Soggi//".log",status="unknown")

! lettura file classi

OPEN(16,file=TRIM(sPATH0)//"ini/fwiscale.ini",status="old",IOSTAT=iRetCode)
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

!  lettura file punti di griglia appartenenti alla regione Lombardia - contemporaneamente e' un file di riferimento
!  per l'assegnazione dei valori meteo e fwi ai vari punti di griglia. Infatti memorizzo l'associazione tra coordinate
!  e indice dell'array 1D vrif per l'utilizzo nella lettura dei file di input.

OPEN(15,file=TRIM(sPATH0)//"ini/lombardia_CI7.txt",status="old",IOSTAT=iRetCode)
IF (iRetCode/=0) THEN
  PRINT *,'fwigrid: error opening file <lombardia_CI7.txt>'
  STOP 1
END IF
READ(15,*)
DO nn=1,iNP
  READ(15,*) num,latrif(nn),lonrif(nn),latrif2(nn),lonrif2(nn),vrif(nn)
END DO
CLOSE(15)

!------------------------------------------------------------------------------

! eventualmente aggiungere righe di controllo su header file ascii in lettura
! verificare la precisione delle variabili reali che calcolano l'indice (4 cifre decimali?)

! ***********************            *************************

READ(Sieri(7:8),"(i2)") iDD0
READ(Sieri(5:6),"(i2)") iMMM0
READ(Sieri(1:4),"(i4)") iYYYY0
READ(Soggi(7:8),"(i2)") iDD1
READ(Soggi(5:6),"(i2)") iMMM1
READ(Soggi(1:4),"(i4)") iYYYY1
READ(Sdomani(7:8),"(i2)") iDD2
READ(Sdomani(5:6),"(i2)") iMMM2
READ(Sdomani(1:4),"(i4)") iYYYY2

WRITE(14,*) "ieri:   ", iYYYY0,iMMM0,iDD0
WRITE(14,*) "oggi:   ", iYYYY1,iMMM1,iDD1
WRITE(14,*) "domani: ", iYYYY2,iMMM2,iDD2

! nota la data di domani, calcolo e verifico la data di oggi 

IF(iDD2.eq.1) THEN
  IF(iMMM2.gt.1) THEN
    IF(iMMM2.eq.3) THEN
      IF(MOD(iYYYY2,4).eq.0) THEN
        iDD1b=29
      ELSE 
        iDD1b=28
      END IF
    ELSE IF(iMMM2.eq.5.or.iMMM2.eq.7.or.iMMM2.eq.10.or.iMMM2.eq.12) THEN
      iDD1b=30
    ELSE
      iDD1b=31
    END IF
    iMMM1b=iMMM2-1
    iYYYY1b=iYYYY2
  ELSE
    iDD1b=31
    iMMM1b=12
    iYYYY1b=iYYYY2-1
  END IF
ELSE
  iDD1b=iDD2-1
  iMMM1b=iMMM2
  iYYYY1b=iYYYY2
END IF

IF(iDD1b.ne.iDD1.or.iMMM1b.ne.iMMM1.or.iYYYY1b.ne.iYYYY1) THEN
  WRITE(14,*) "Errore nelle date del file data_for.ini"
  STOP 1
END IF

! nota la data di oggi, calcolo e verifico la data di ieri 

IF(iDD1.eq.1) THEN
  IF(iMMM1.gt.1) THEN
    IF(iMMM1.eq.3) THEN
      IF(MOD(iYYYY1,4).eq.0) THEN
        iDD0b=29
      ELSE 
        iDD0b=28
      END IF
    ELSE IF(iMMM1.eq.5.or.iMMM1.eq.7.or.iMMM1.eq.10.or.iMMM1.eq.12) THEN
      iDD0b=30
    ELSE
      iDD0b=31
    END IF
    iMMM0b=iMMM1-1
    iYYYY0b=iYYYY1
  ELSE
    iDD0b=31
    iMMM0b=12
    iYYYY0b=iYYYY1-1
  END IF
ELSE
  iDD0b=iDD1-1
  iMMM0b=iMMM1
  iYYYY0b=iYYYY1
END IF

IF(iDD0b.ne.iDD0.or.iMMM0b.ne.iMMM0.or.iYYYY0b.ne.iYYYY0) THEN
  WRITE(14,*) "Errore nelle date del file data_for.ini"
  STOP 1
END IF

!  leggo file meteo previsti e indici in input (da analisi di ieri). Per ogni record associo il valore alle corrispondenti coordinate,
!  mediante confronto con array di riferimento

! lettura file indici di ieri (analisi)

! Esempio: ffmc_lami_Sdata.txt = file x,y,z con i valori di ffmc calcolati da misure interpolate
!                                per il giorno Sdata, (rUNDEF=0 fuori regione, nei punti con neve, nei punti non bruciabili, in caso di dati invalidi:
!                                il rUNDEF=0 deriva dall'operazione di trasformazione coordinate con GRASS)
!                           N.B. viene ricavato dai corispondenti file ffmc_Sdata.txt convertendoli nel grigliato
!                                COSMO I7 in coordinate lat lon.

DO kk=1,3
  OPEN(unit=iFILIN(kk),file=TRIM(ADJUSTL(sPATH1))//TRIM(sFILO(kk))//Sieri//'.txt',status='old',IOSTAT=iRetCode)
  IF (iRetCode/=0) THEN
    PRINT *,'fwigrid: error opening file <',TRIM(sFILO(kk))//Sieri,'>'
    STOP 1
  ENDIF
  READ(iFILIN(kk),*) 
  DO nn=1,iNP
    READ(iFILIN(kk),*) num,lat1,lon1,lat2,lon2,val
    IF(val.eq.rUNDEF_GRAS) THEN
      val=rUNDEF_FWI
    END IF
    DO mm=1,iNP
      IF((lat1-latrif(mm)).lt.0.003.and.(lon1-lonrif(mm)).lt.0.003) THEN
        rvFWIinp(mm,kk,1)=val
      ENDIF
    END DO
  END DO
  CLOSE(iFILIN(kk))
END DO


! lettura file meteo oggi e domani (previsione)
!
! Esempio: t_lami_Sdata_ng.txt = file x,y,z con i valori meteo previsti dal CosmoI7 per l'emissione del giorno Sdata (=Soggi),
!                                e per il giorno ng di previsione (ng=1 -> Soggi; ng=2-> Sdomani)

DO km=1,4
  DO kd=1,2
    WRITE(Skd,"(i1)") kd
    sFILIM(km,kd)=TRIM(ADJUSTL(sFILIM(km,kd)))//Soggi//'_'//Skd//'.txt'
  END DO
END DO

DO km=1,4
  DO kd=1,2
    OPEN(unit=iFILIM(km,kd),file=TRIM(ADJUSTL(sPATH2))//TRIM(sFILIM(km,kd)),status='old',IOSTAT=iRetCode)
    IF (iRetCode/=0) THEN
      PRINT *,'fwigrid: error opening file <',TRIM(sFILIM(km,kd)),'>'
      STOP 1
    ENDIF
    DO idum=1,7
      READ(iFILIM(km,kd),*)
    END DO
    IF(km.eq.3) THEN
      READ(iFILIM(km,kd),*)
    END IF
    READ(iFILIM(km,kd),*)  rYLCORN,rdum1,rCELLSIZE,rdum2,rdum3,rdum4,rdum5,rdum6
    READ(iFILIM(km,kd),*)  rXLCORN,rdum1,rCELLSIZE,rdum2,rdum3,rdum4,rdum5,rdum6
    IF(rYLCORN.ne.rYLCORNok.or.rXLCORN.ne.rXLCORNok.or.rCELLSIZE.ne.rCELLSIZEok) THEN
      WRITE(14,*) "Errore nei parametri di grigliato del file ",TRIM(sPATH2)//TRIM(sFILIM(km,kd))
      WRITE(14,*) "Da file meteo: ",rYLCORN,rXLCORN,rCELLSIZE
      WRITE(14,*) "Da file ini  : ",rYLCORNok,rXLCORNok,rCELLSIZEok
      STOP 1
    END IF
    DO nn=1,iNP
      IF(km.eq.3) THEN
        READ(iFILIM(km,kd),*) lat1,lon1,lat2,lon2,val1,val2
      ELSE
        READ(iFILIM(km,kd),*) lat1,lon1,lat2,lon2,val
      END IF
      DO mm=1,iNP
        IF((lat1-latrif(mm)).lt.0.003.and.(lon1-lonrif(mm)).lt.0.003) THEN
          IF(km.eq.3) THEN
            met(mm,km,kd)=(sqrt(val1**2+val2**2))*3.6
          ELSE IF(km.eq.4) THEN
            IF(kd.eq.1) THEN
              met(mm,4,1)=val
            ELSE
              met(mm,4,2)=val-met(mm,4,1)
            END IF
          ELSE
            met(mm,km,kd)=val
          END IF
        END IF
      END DO
    END DO
    CLOSE(iFILIM(km,kd))
  END DO
END DO

!  scrittura file input meteo per controllare 1 volta che la lettura sia corretta!!!! poi commentare

    DO km=1,4
      sFILICM(km,1)=TRIM(ADJUSTL(sFILICM(km,1)))//Soggi//'_1_ctrl.txt'
      sFILICM(km,2)=TRIM(ADJUSTL(sFILICM(km,2)))//Soggi//'_2_ctrl.txt'
    END DO

    DO km=1,4
      DO kd=1,2
        OPEN(unit=iFILICM(km,kd),file=TRIM(ADJUSTL(sPATH2))//'ctrl/'//TRIM(sFILICM(km,kd)),status='unknown',IOSTAT=iRetCode)
        IF (iRetCode/=0) THEN
          PRINT *,'fwigrid_for: error opening file <',TRIM(sFILICM(km,kd)),'>'
          STOP 1
        ENDIF
        WRITE(iFILICM(km,kd),*)
        DO ipt=1,iNP
          WRITE(Sipt,"(i4)") ipt
          WRITE(Slatrif,"(f7.3)") latrif(ipt)
          WRITE(Slonrif,"(f7.3)") lonrif(ipt)
          WRITE(Slatrif2,"(f7.3)") latrif2(ipt)
          WRITE(Slonrif2,"(f7.3)") lonrif2(ipt)
          WRITE(Smet,"(f5.1)") met(ipt,km,kd)
          Sriga=TRIM(ADJUSTL(Sipt))//','//TRIM(ADJUSTL(Slatrif))//','//TRIM(ADJUSTL(Slonrif))//','//TRIM(ADJUSTL(Slatrif2))//','&
            //TRIM(ADJUSTL(Slonrif2))//','//TRIM(ADJUSTL(Smet))

          WRITE(iFILICM(km,kd),*) TRIM(ADJUSTL(Sriga))
        END DO
        CLOSE(iFILICM(km,kd))
      END DO
    END DO

! aggiungo 2 file per umidita' relativa

    OPEN(unit=49,file=TRIM(ADJUSTL(sPATH2))//'ctrl/ur_lami_'//Soggi//'_1_ctrl.txt',status='unknown',IOSTAT=iRetCode)
    IF (iRetCode/=0) THEN
      PRINT *,'fwigrid_for: error opening file <','ur_lami_'//Soggi,'>'
      STOP 1
    ENDIF
    WRITE(49,"(a18)") "cat,BO,BO1,Y,X,VAL"
    DO ipt=1,iNP
      esat_t=(6.1078*exp((17.269388*(met(ipt,1,1)-273.15))/(met(ipt,1,1)-35.86)))
      esat_td=(6.1078*exp((17.269388*(met(ipt,2,1)-273.15))/(met(ipt,2,1)-35.86)))
      ur=(esat_td/esat_t)*100
      WRITE(Sipt,"(i4)") ipt
      WRITE(Slatrif,"(f7.3)") latrif(ipt)
      WRITE(Slonrif,"(f7.3)") lonrif(ipt)
      WRITE(Slatrif2,"(f7.3)") latrif2(ipt)
      WRITE(Slonrif2,"(f7.3)") lonrif2(ipt)
      WRITE(Sur,"(f5.1)") ur
      Sriga=TRIM(ADJUSTL(Sipt))//','//TRIM(ADJUSTL(Slatrif))//','//TRIM(ADJUSTL(Slonrif))//','//TRIM(ADJUSTL(Slatrif2))//','&
            //TRIM(ADJUSTL(Slonrif2))//','//TRIM(ADJUSTL(Sur))

      WRITE(49,*) TRIM(ADJUSTL(Sriga))
    END DO
    CLOSE(49)

    OPEN(unit=50,file=TRIM(ADJUSTL(sPATH2))//'ctrl/ur_lami_'//Soggi//'_2_ctrl.txt',status='unknown',IOSTAT=iRetCode)
    IF (iRetCode/=0) THEN
      PRINT *,'fwigrid_for: error opening file <','ur_lami_'//Sdomani,'>'
      STOP 1
    ENDIF
    WRITE(50,*)
    DO ipt=1,iNP
      esat_t=(6.1078*exp((17.269388*(met(ipt,1,2)-273.15))/(met(ipt,1,2)-35.86)))
      esat_td=(6.1078*exp((17.269388*(met(ipt,2,2)-273.15))/(met(ipt,2,2)-35.86)))
      ur=(esat_td/esat_t)*100
      WRITE(Sipt,"(i4)") ipt
      WRITE(Slatrif,"(f7.3)") latrif(ipt)
      WRITE(Slonrif,"(f7.3)") lonrif(ipt)
      WRITE(Slatrif2,"(f7.3)") latrif2(ipt)
      WRITE(Slonrif2,"(f7.3)") lonrif2(ipt)
      WRITE(Sur,"(f11.5)") ur
      Sriga=TRIM(ADJUSTL(Sipt))//','//TRIM(ADJUSTL(Slatrif))//','//TRIM(ADJUSTL(Slonrif))//','//TRIM(ADJUSTL(Slatrif2))//','&
            //TRIM(ADJUSTL(Slonrif2))//','//TRIM(ADJUSTL(Sur))

      WRITE(50,*) TRIM(ADJUSTL(Sriga))
    END DO
    CLOSE(50)


!!!!!!! *****  scrivere file input indici per controllare 1 volta che la lettura sia corretta!!!! poi commentare

   DO kk=1,3
     OPEN(unit=iFILICN(kk),file=TRIM(ADJUSTL(sPATH1))//'ctrl/'//TRIM(sFILO(kk))//Sieri//'_ctrl.txt',status='unknown',&
	      IOSTAT=iRetCode)
     IF (iRetCode/=0) THEN
       PRINT *,'fwigrid_for: error opening file <',TRIM(sFILO(kk))//Sieri//'_ctrl','>'
       STOP 1
     ENDIF
     WRITE(iFILICN(kk),*) 
     DO ipt=1,iNP
       WRITE(iFILICN(kk),"(i4,3x,4(f7.3,3x),f11.5)") ipt,latrif(ipt),lonrif(ipt),latrif2(ipt),lonrif2(ipt),rvFWIinp(ipt,kk,1)
     END DO
     CLOSE(iFILICN(kk))
   END DO


! *********   inizio ciclo sui giorni di previsione   *******

DO ng=1,2

! *********   ciclo sui punti di griglia    ******	 (verificare L'ORDINE DEI PUNTI-INDICI)

  IF(ng.eq.1) THEN
    imo=iMMM1
  ELSE
    imo=iMMM2
  END IF

  DO ipt=1,iNP

! assegnazione dati meteo

    t=met(ipt,1,ng)     ! t in gradi K
    td=met(ipt,2,ng)    ! td in gradi K
    w=met(ipt,3,ng)     ! w in Km/h
    r=met(ipt,4,ng)     ! r in mm (cumulati su 24h)

! verifica presenza dati meteo non validi

    IF(t.lt.200.or.t.gt.323) THEN
      t=rUNDEF
    END IF
    IF(td.lt.150.or.td.gt.323) THEN
      td=rUNDEF
    END IF
    IF(w.lt.0.or.w.gt.150) THEN
      w=rUNDEF
    END IF
    IF(r.lt.0.or.r.gt.400) THEN
      r=rUNDEF
    END IF

    IF(t.eq.rUNDEF.or.h.eq.rUNDEF.or.w.eq.rUNDEF.or.r.eq.rUNDEF) THEN
      mc=rUNDEF_FWI
      ffm=rUNDEF_FWI
      dc=rUNDEF_FWI
      dmc=rUNDEF_FWI
      si=rUNDEF_FWI
      bui=rUNDEF_FWI
      fwi=rUNDEF_FWI
      dsr=rUNDEF_FWI
      IF(vrif(ipt).ne.rUNDEF_GRAS) THEN
        inorm=1
        WRITE(14,*) "Errore: dati meteo non validi o non definiti!"
        WRITE(14,*)  "Oggi: ",Sgiorno(ng), " Punto di griglia: ",ipt
      END IF
      GOTO 40
    END IF


! calcolo umidita' relativa a partire da t e td

    esat_t=(6.1078*exp((17.269388*(t-273.15))/(t-35.86)))
    esat_td=(6.1078*exp((17.269388*(td-273.15))/(td-35.86)))
    h=(esat_td/esat_t)*100

!  converto t in gradi C

    t=t-273.15
    tok=t

!  se UR>=100 la pongo di poco < 100, per evitare problemi di arrotondamento

    IF(h.ge.100.) h=99.95

! riassegnazione codice dato invalido (GRASS trasforma -9999 in 0, quindi verifico se c'e' rUNDEF_GRAS=0)

    DO kk=1,3
      IF(rvFWIinp(ipt,kk,ng).eq.rUNDEF_GRAS) THEN
        rvFWIinp(ipt,kk,ng)=rUNDEF_FWI
      END IF
    END DO

! assegnazione indici di base del giorno prima

    fo=rvFWIinp(ipt,1,ng)
    po=rvFWIinp(ipt,2,ng)
    dot=rvFWIinp(ipt,3,ng)

! utilizzo valori di default in caso di sottoindici iniziali mancanti o invalidi (fatto solo al primo giorno del run)

    IF(ng.eq.1) THEN
      IF(fo.eq.rUNDEF_FWI.or.(fo.lt.0..or.fo.gt.101.)) THEN
        IF(idef.eq.1) THEN
          fo=fod
        ELSE
          fo=rUNDEF_FWI
        END IF
        IF(vrif(ipt).ne.rUNDEF_GRAS) inorm=1
      END IF
      IF(po.eq.rUNDEF_FWI.or.po.lt.0.) THEN
        IF(idef.eq.1) THEN
          po=pod
        ELSE
          po=rUNDEF_FWI
        END IF
        IF(vrif(ipt).ne.rUNDEF_GRAS) inorm=1
      END IF
      IF(dot.eq.rUNDEF_FWI.or.dot.lt.0.) THEN
        IF(idef.eq.1) THEN
          dot=dotd
        ELSE
          dot=rUNDEF_FWI
        END IF
        IF(vrif(ipt).ne.rUNDEF_GRAS) inorm=1
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
      IF(vrif(ipt).ne.rUNDEF_GRAS) THEN
        inorm=1
        WRITE(14,*) "Errore: sottoindici di ieri non definiti!"
        WRITE(14,*)  "Oggi: ",Sgiorno(ng), "Punto di griglia: ",ipt
      END IF
      GOTO 40
    END IF

! ******************

! CALCOLO DEI SOTTOINDICI 

! ******************

        IF(fo.lt.0.or.po.lt.0.or.dot.lt.0) THEN
          WRITE(14,*) "Errore: sottoindice negativo nella sezione di calcolo"
          WRITE(14,*)  "FFMC,DMC,DC"
          WRITE(14,*)  fo,po,dot
          WRITE(14,*)  "Giorno ",ipt
          WRITE(14,*)  "Punto di griglia ",ipt
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


40      CONTINUE

! ****  Assegnazione matrici indici ****

        rvFWIout(ipt,1,ng)=ffm
        rvFWIout(ipt,2,ng)=dmc
        rvFWIout(ipt,3,ng)=dc
        rvFWIout(ipt,4,ng)=si
        rvFWIout(ipt,5,ng)=bui
        rvFWIout(ipt,6,ng)=fwi

! **** Assegnazione matrici classi ****

!  assegnazione classi di ffm

        IF(ffm.eq.rUNDEF_FWI) THEN
          clafm=iUNDEF
        ELSE
          IF(ffm.ge.fmcl(imo,5)) THEN
            clafm=6
          ELSE IF(ffm.ge.0..and.ffm.lt.fmcl(imo,1)) THEN
            clafm=1
          ELSE
            DO ind=1,4
              IF(ffm.ge.fmcl(imo,ind).and.ffm.lt.fmcl(imo,ind+1)) THEN
                clafm=ind+1
              END IF
            END DO
          END IF
        END IF

!  assegnazione classi di mc (al momento non utilizzato)

        IF(mc.eq.rUNDEF_FWI) THEN
          clamc=iUNDEF
        ELSE
          IF(mc.ge.mcl(imo,5)) THEN
            clamc=6
          ELSE IF(mc.ge.0..and.mc.lt.mcl(imo,1)) THEN
            clamc=1
          ELSE
            DO ind=1,4
              IF(mc.ge.mcl(imo,ind).and.mc.lt.mcl(imo,ind+1)) THEN
                clamc=ind+1
              END IF
            END DO
          END IF
        END IF

!  assegnazione classi di dmc

        IF(dmc.eq.rUNDEF_FWI) THEN
          cladm=iUNDEF
        ELSE
          IF(dmc.ge.dmcl(imo,5)) THEN
            cladm=6
          ELSE IF(dmc.ge.0..and.dmc.lt.dmcl(imo,1)) THEN
            cladm=1
          ELSE
            DO ind=1,4
              IF(dmc.ge.dmcl(imo,ind).and.dmc.lt.dmcl(imo,ind+1)) THEN
                cladm=ind+1
              END IF
            END DO
          END IF
        END IF 

!  assegnazione classi di dc

        IF(dc.eq.rUNDEF_FWI) THEN
          cladc=iUNDEF
        ELSE
          IF(dc.ge.dcl(imo,5)) THEN
            cladc=6
          ELSE IF(dc.ge.0..and.dc.lt.dcl(imo,1)) THEN
            cladc=1
          ELSE
            DO ind=1,4
              IF(dc.ge.dcl(imo,ind).and.dc.lt.dcl(imo,ind+1)) THEN
                cladc=ind+1
              END IF
            END DO
          END IF
        END IF

!  assegnazione classi di isi

        IF(si.eq.rUNDEF_FWI) THEN
          clais=iUNDEF
        ELSE
          IF(si.ge.iscl(imo,5)) THEN
            clais=6
          ELSE IF(si.ge.0..and.si.lt.iscl(imo,1)) THEN
            clais=1
          ELSE
            DO ind=1,4
              IF(si.ge.iscl(imo,ind).and.si.lt.iscl(imo,ind+1)) THEN
                clais=ind+1
              END IF
            END DO
          END IF
        END IF

!  assegnazione classi di bui

        IF(bui.eq.rUNDEF_FWI) THEN
          clabu=iUNDEF
        ELSE
          IF(bui.ge.bucl(imo,5)) THEN
            clabu=6
          ELSE IF(bui.ge.0..and.bui.lt.bucl(imo,1)) THEN
            clabu=1
          ELSE
            DO ind=1,4
              IF(bui.ge.bucl(imo,ind).and.bui.lt.bucl(imo,ind+1)) THEN
                clabu=ind+1
              END IF
            END DO
          END IF
        END IF

!  assegnazione classi di fwi

        IF(fwi.eq.rUNDEF_FWI) THEN
          clafw=iUNDEF
        ELSE
          IF(fwi.ge.fwcl(imo,5)) THEN
            clafw=6
          ELSE IF(fwi.ge.0..and.fwi.lt.fwcl(imo,1)) THEN
            clafw=1
          ELSE
            DO ind=1,4
              IF(fwi.ge.fwcl(imo,ind).and.fwi.lt.fwcl(imo,ind+1)) THEN
                clafw=ind+1
              END IF
            END DO
          END IF
        END IF

!  assegnazione classi di dsr (al momento non utilizzato)

        IF(dsr.eq.rUNDEF_FWI) THEN
          clads=iUNDEF
        ELSE
          IF(dsr.ge.dscl(imo,5)) THEN
            clads=6
          ELSE IF(dsr.ge.0..and.dsr.lt.dscl(imo,1)) THEN
            clads=1
          ELSE
            DO ind=1,4
              IF(dsr.ge.dscl(imo,ind).and.dsr.lt.dscl(imo,ind+1)) THEN
                clads=ind+1
              END IF
            END DO
          END IF
        END IF

!   assegnazione array classi

        iFWIcla(ipt,1,ng)=clafm
        iFWIcla(ipt,2,ng)=cladm
        iFWIcla(ipt,3,ng)=cladc
        iFWIcla(ipt,4,ng)=clais
        iFWIcla(ipt,5,ng)=clabu
        iFWIcla(ipt,6,ng)=clafw

! ******************

! FINE SEZIONE DI CALCOLO DELL'INDICE

! ******************

! assegnazione input del secondo giorno di previsione

    DO kk=1,3
      IF(ng.eq.1) THEN
        rvFWIinp(ipt,kk,2)=rvFWIout(ipt,kk,1)
      END IF
    END DO

! *********   fine ciclo sui punti di griglia   *******

  END DO

  IF(inorm.eq.0) THEN
    WRITE(14,*) 
    WRITE(14,*) Sgiorno(ng)," Giorno elaborato senza errori"
    WRITE(*,*) Sgiorno(ng)," Giorno elaborato senza errori"
  ELSE
    WRITE(14,*) 
    WRITE(14,*) Sgiorno(ng)," Giorno elaborato con errori"
    WRITE(*,*) Sgiorno(ng)," Giorno elaborato con errori"
    inorm=0
  END IF

! **********   SCRITTURA OUTPUT    ************  

! file indici numerici del giorno corrente
!
! Esempio: ffmc_lami_Sdata_ng.txt = matrice con i valori di ffmc previsti calcolati per Sdata, intesa come giorno di previsione numero ng
!                                   (rUNDEF fuori regione e in caso di dati invalidi)
!                                  Tale file verra' trattato con GRASS per aggegazione areale e graficazione
!                                  N.B. tali valori sono calcolati usando, oltre ai dati meteo, il file ffmc_lami_(Sdata-1).txt per ng=1 e
!                                       l'array rvFWIout(ng=1) per ng=2

  WRITE(Sng,"(i1)") ng

  DO kk=1,6
    OPEN(unit=iFILO(kk,ng),file=TRIM(ADJUSTL(sPATH3))//TRIM(sFILO(kk))//Sgiorno(ng)//'_'//Sng//'.txt',status='unknown') 
    WRITE(iFILO(kk,ng),"(a18)") "cat,BO,BO1,Y,X,VAL"
    DO ipt=1,iNP
      WRITE(Sipt,"(i4)") ipt
      WRITE(Slatrif,"(f7.3)") latrif(ipt)
      WRITE(Slonrif,"(f7.3)") lonrif(ipt)
      WRITE(Slatrif2,"(f7.3)") latrif2(ipt)
      WRITE(Slonrif2,"(f7.3)") lonrif2(ipt)
      WRITE(SrvFWIout,"(f11.5)") rvFWIout(ipt,kk,ng)
      Sriga=TRIM(ADJUSTL(Sipt))//','//TRIM(ADJUSTL(Slatrif))//','//TRIM(ADJUSTL(Slonrif))//','//TRIM(ADJUSTL(Slatrif2))//','&
            //TRIM(ADJUSTL(Slonrif2))//','//TRIM(ADJUSTL(SrvFWIout))

      WRITE(iFILO(kk,ng),*) TRIM(ADJUSTL(Sriga))
    END DO
    CLOSE(iFILO(kk,ng))
  END DO

! file indici in classi del giorno corrente
!
! Esempio: ffmc_c_lami_Sdata_ng.txt = matrice con le classi di ffmc previste calcolate per Sdata, intesa come giorno di previsione numero ng
!                                    (rUNDEF fuori regione e in caso di dati invalidi)
!                             Tale file verra' trattato con GRASS per la produzione di mappe (?)
!                             N.B. tali valori sono calcolati usando il file ffmc_lami_(Sdata-1).txt e il file fwiclassi.ini per ng=1 e l'array
!                                  rvFWIout per ng=2

  DO kk=1,6
    OPEN(unit=iFILOC(kk,ng),file=TRIM(ADJUSTL(sPATH3))//TRIM(sFILOC(kk))//Sgiorno(ng)//'_'//Sng//'.txt',status='unknown') 
    WRITE(iFILOC(kk,ng),"(a18)") "cat,BO,BO1,Y,X,VAL"
    DO ipt=1,iNP
      WRITE(iFILOC(kk,ng),"(i4,3x,4(f7.3,3x),i5)") ipt,latrif(ipt),lonrif(ipt),latrif2(ipt),lonrif2(ipt),iFWIcla(ipt,kk,ng)
    END DO
    CLOSE(iFILOC(kk,ng))
  END DO

! **********   FINE SCRITTURA OUTPUT    ************

!  DA FARE
!  (vedi commenti corrispondenti in fwigrid_ana.f90)

! *********   fine ciclo sui giorni di previsione   *******

END DO

CLOSE(14)

STOP 0

END PROGRAM fwigrid_for
!###############################################################################
