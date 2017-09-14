#########################################      
###       getcsv_storici.R            ###
###                                   ###
### estrae dati dal DB e crea i CSV   ###
###                                   ###
### Maria Ranci            11/7/2008  ###
###                                   ###
#########################################      
# utilizzo: da riga di comando specificare il nome della richiesta
#           dati SENZA "." NEL NOME, e specificare la directory in 
#           cui si vuole avere i csv di output SENZA "/" FINALE
#
# argomenti in riga di comando:
#  val_manuale -> filtro Flag_manuale (prendi solo "G")
#  val_mysql -> filtro Flag_automatica (prendi solo "P") 
#  val_unico -> filtro Flag_manuale_DBunico (prendi solo alcuni)
#  val_black -> utilizza blacklist
#  file_ric -> nome file di richiesta
#  direcotry_CSV -> output directory
#  file_log -> file di log
#
#STORIA
# 2009/10/20  CR. aggiornamento che tiene conto della blacklist sul DB meteo.
# 2010/07/08  CR. aggiornamento che tiene conto del Flag_manuale sul DB meteo.
# 2010/07/09  CR. inserita possibilita' di servirsi della blacklist.
# 2011/03/24  CR. aggiornamento che tiene conto delle sole invalidazioni su
#                 DB meteo e permette di chiedere le tipologie di variabili
#                 dall'anagrafica del DBmeteo (flags: val_nonE, val_idvar)
########################################

working_directory <- ("/home/meteo/programmi/getdata/mysql_201103/")
source(paste(working_directory,'getcsv_storici_sub.R',sep=""))

library(DBI)
library(RMySQL)
library(RODBC)

# funzione per gestire eventuali errori
neverstop<-function(){
  print("EE..ERRORE durante l'esecuzione dello script!! Messaggio d'Errore prodotto:")
}
options(show.error.messages=TRUE,error=neverstop)

# Leggi riga di comando
input_ext <- commandArgs()
print("input_ext:")
print(input_ext)
#
val_manuale <- input_ext[5]
print(paste("1. val_manuale=",val_manuale,sep=""))
#
val_mysql <- input_ext[6]
print(paste("2. val_mysql=",val_mysql,sep=""))
#
val_unico <- input_ext[7]
print(paste("3. val_unico=",val_unico,sep=""))
#
val_nonE<-input_ext[8]
print(paste("4. val_nonE=",val_nonE,sep=""))
#
val_idvar<-input_ext[9]
print(paste("5. val_idvar=",val_idvar,sep=""))
#
val_black <- input_ext[10]
print(paste("4. val_black=",val_black,sep=""))
#
file_ric <- input_ext[11]
print(paste("5. file_ric=",file_ric,sep=""))
#
directory_CSV <- input_ext[12]
print(paste("6. directory_CSV=",directory_CSV,sep=""))
#
file_log <- input_ext[13]
print(paste("7. file_log=",file_log,sep=""))
#
cat ( "InIZio-=---=-- getcsv_storici.R =---=-----=---==----iNiZio-----=\n" , file = file_log,append=TRUE)
cat ( "ESTRAZIONE DATI DAL DB ", date()," \n\n" , file = file_log,append=T)

#___________________________________________________
#    COLLEGAMENTO AL DB
#___________________________________________________

cat("collegamento al DB\n",file=file_log,append=T)
MySQL(max.con=16,fetch.default.rec=500,force.reload=FALSE)

#definisco driver
drv<-dbDriver("MySQL")

#apro connessione con il db descritto nei parametri del gruppo "tabella_rif"
#nel file "/home/meteo/.my.cnf
conn<-dbConnect(drv,group="Visualizzazione_Sinergico")
#___________________________________________________
#    LETTURA FILE DI RICHIESTA DATI
#___________________________________________________
data_inizio <- scan(file=file_ric,nlines=1)[1]
data_fine   <- scan(file=file_ric,nlines=1)[2]
if (val_idvar!=0) {
  if (val_idvar=="T") query<- paste("select IDsensore from A_Sensori where NOMEtipologia in ('T','TV')",sep="")
  if (val_idvar=="RH") query<- paste("select IDsensore from A_Sensori where NOMEtipologia='UR'",sep="")
  if (val_idvar=="VV") query<- paste("select IDsensore from A_Sensori where NOMEtipologia in ('VV','VVS','VVP','VVQ')",sep="")
  if (val_idvar=="DV") query<- paste("select IDsensore from A_Sensori where NOMEtipologia in ('DV','DVS','DVP','DVQ')",sep="")
  if (val_idvar=="PA") query<- paste("select IDsensore from A_Sensori where NOMEtipologia='PA'",sep="")
  if (val_idvar=="PP") query<- paste("select IDsensore from A_Sensori where NOMEtipologia in ('PP','PPR')",sep="")
  if (val_idvar=="RG") query<- paste("select IDsensore from A_Sensori where NOMEtipologia='RG'",sep="")
  if (val_idvar=="RN") query<- paste("select IDsensore from A_Sensori where NOMEtipologia='RN'",sep="")
  q <- try(dbGetQuery(conn, query),silent=TRUE)
  if (inherits(q,"try-error")) {
    cat(q,"\n",file=file_log,append=T)
    quit(status=1)
  }
  aux_sens <- q$IDsensore
  sensori_richiesti <- toString(q$IDsensore)
} else {
  aux_sens <- scan(file=file_ric,skip=3)
  sensori_richiesti <- toString(aux_sens)
}
#data_inizio <- strptime(data_inizio,"%Y%m%d%H%M")
#data_fine <- strptime(data_fine,"%Y%m%d%H%M")
data_inizio <- as.POSIXct( strptime(data_inizio,"%Y%m%d%H%M"), "UTC")
data_fine <- as.POSIXct( strptime(data_fine,"%Y%m%d%H%M"), "UTC")
if (data_inizio>data_fine) {
  cat("ERRORE: le date di inizio e fine periodo non sono corrette. inizio > fine\n",file=file_log,append=T)
  cat(paste(" data inizio richiesta =",data_inizio," \n"),file=file_log,append=T)
  cat(paste(" data   fine richiesta =",data_fine," \n"),file=file_log,append=T)
  quit(status=1)
}
#______________________________________________________
# INTERROGAZIONE DB PER SELEZIONARE INFO DELLA TABELLA A_SENSORI
#______________________________________________________
cat("interrogo DB per ricavare le info sui sensori \n",file=file_log,append=T)
if (val_black==0) {
  query_A_Sensori <- paste("select IDsensore,NOMEtipologia from A_Sensori where IDsensore IN(",sensori_richiesti,")",sep="")
} else {
  query_A_Sensori <- paste("select IDsensore,NOMEtipologia from A_Sensori where IDsensore IN(",sensori_richiesti,") and IDsensore NOT IN (select IDsensore from A_ListaNera where DataFine IS NULL) ",sep="")
}
q_A_Sensori <- try(dbGetQuery(conn, query_A_Sensori),silent=TRUE)
if (inherits(q_A_Sensori,"try-error")) {
  cat(q_A_Sensori,"\n",file=file_log,append=T)
  quit(status=1)
}
#------------ preparazione nome file di output
# ricavo nome
splittamento <- unlist(strsplit(file_ric,"/"))
nome_con_ric <- splittamento[length(splittamento)]
nomesemplice <- unlist(strsplit(nome_con_ric,"\\."))[1]
#print(nomesemplice)
#--------------------------------------------
# controllo per eventuali sensori richiesti e non presenti in anagrafica 
#print(q_A_Sensori)
aux<-aux_sens %in% q_A_Sensori$IDsensore
#print(aux_sens[!aux])
if (length((aux_sens[!aux]))>0) {
  if (val_black==0) {
    cat(paste("ATTENZIONE! ID Sensori richiesti ma non presenti in anagrafica: ",sep=""),file=file_log,append=T)
  } else {
    cat(paste("ATTENZIONE! ID Sensori richiesti ma (non presenti in anagrafica) O (blacklistati): ",sep=""),file=file_log,append=T)
  }
  cat(paste(aux_sens[!aux],sep="  "),file=file_log,append=T)
  cat("\n",file=file_log,append=T)
}
if (length(aux_sens[aux])<=0) {
  cat(paste("ERRORE! Numero di sensori richiesti E presenti in anagrafica non plausibile\n",sep=""),file=file_log,append=T)
  quit(status=1)
}
if (val_black!=0) {
  cat(paste("ATTENZIONE! L'utilizzo della blacklist non e' contemplato per le richieste \"storiche\"\n",sep=""),file=file_log,append=T)
}
#______________________________________________________
# DIVISIONE PER TIPOLOGIA, RICHIESTA E SCRITTURA SU FILE 
#______________________________________________________
cat("interrogo DB per ottenere le osservazioni richieste: \n",file=file_log,append=T)
if (length(q_A_Sensori[,1])>0){

# Termometri
  indice_termometri<-which(q_A_Sensori$NOMEtipologia=="T" | q_A_Sensori$NOMEtipologia=="TV")
  sensori<-(q_A_Sensori$IDsensore[indice_termometri])
  tipologia <- "Termometri"
  cat("termometri: ", length(sensori),"\n",file=file_log,append=T)
  stringa_sensori <- toString(sensori)

  if(length(sensori)!=0){
    richiesta <- estrazione(tipologia, sensori, data_inizio, data_fine, val_manuale, val_mysql, val_unico, val_nonE)
  }  

# Barometri
  indice_barometri<-which(q_A_Sensori$NOMEtipologia=="PA")
  sensori<-(q_A_Sensori$IDsensore[indice_barometri])
  tipologia <- "Barometri"
  cat("barometri: ", length(sensori),"\n",file=file_log,append=T)
  stringa_sensori <- toString(sensori)

  if(length(sensori)!=0){
    richiesta <- estrazione(tipologia, sensori, data_inizio, data_fine, val_manuale, val_mysql, val_unico, val_nonE)
  }  

# Pluviometri
  indice_pluviometri<-which(q_A_Sensori$NOMEtipologia=="PP" | q_A_Sensori$NOMEtipologia=="PPR")
  sensori<-(q_A_Sensori$IDsensore[indice_pluviometri])
  tipologia <- "Pluviometri"
  cat("pluviometri: ", length(sensori),"\n",file=file_log,append=T)
  stringa_sensori <- toString(sensori)

  if(length(sensori)!=0){
    richiesta <- estrazione(tipologia, sensori, data_inizio, data_fine, val_manuale, val_mysql, val_unico, val_nonE)
  }  

# Igrometri
  indice_igrometri<-which(q_A_Sensori$NOMEtipologia=="UR")
  sensori<-(q_A_Sensori$IDsensore[indice_igrometri])
  tipologia <- "Igrometri"
  cat("igrometri: ", length(sensori),"\n",file=file_log,append=T)
  stringa_sensori <- toString(sensori)

  if(length(sensori)!=0){
    richiesta <- estrazione(tipologia, sensori, data_inizio, data_fine, val_manuale, val_mysql, val_unico, val_nonE)
  }  

# RadiometriG
  indice_radiometriG<-which(q_A_Sensori$NOMEtipologia=="RG")
  sensori<-(q_A_Sensori$IDsensore[indice_radiometriG])
  tipologia <- "RadiometriG"
  cat("radiometriG: ", length(sensori),"\n",file=file_log,append=T)
  stringa_sensori <- toString(sensori)

  if(length(sensori)!=0){
    richiesta <- estrazione(tipologia, sensori, data_inizio, data_fine, val_manuale, val_mysql, val_unico, val_nonE)
  }  

# RadiometriN
  indice_radiometriN<-which(q_A_Sensori$NOMEtipologia=="RN")
  sensori<-(q_A_Sensori$IDsensore[indice_radiometriN])
  tipologia <- "RadiometriN"
  cat("radiometriN: ", length(sensori),"\n",file=file_log,append=T)
  stringa_sensori <- toString(sensori)

  if(length(sensori)!=0){
    richiesta <- estrazione(tipologia, sensori, data_inizio, data_fine, val_manuale, val_mysql, val_unico, val_nonE)
  }  

# Anemometri VV
  indice_anemometriVV<-which(q_A_Sensori$NOMEtipologia=="VV" | q_A_Sensori$NOMEtipologia=="VVP" | q_A_Sensori$NOMEtipologia=="VVQ" | q_A_Sensori$NOMEtipologia=="VVS")
  sensori<-(q_A_Sensori$IDsensore[indice_anemometriVV])
  tipologia <- "AnemometriVV"
  cat("anemometriVV: ", length(sensori),"\n",file=file_log,append=T)
  stringa_sensori <- toString(sensori)

  if(length(sensori)!=0){
    richiesta <- estrazione(tipologia, sensori, data_inizio, data_fine, val_manuale, val_mysql, val_unico, val_nonE)
  }  

# Anemometri DV
  indice_anemometriDV<-which(q_A_Sensori$NOMEtipologia=="DV" | q_A_Sensori$NOMEtipologia=="DVP" | q_A_Sensori$NOMEtipologia=="DVQ" | q_A_Sensori$NOMEtipologia=="DVS")
  sensori<-(q_A_Sensori$IDsensore[indice_anemometriDV])
  tipologia <- "AnemometriDV"
  cat("anemometriDV: ", length(sensori),"\n",file=file_log,append=T)
  stringa_sensori <- toString(sensori)

  if(length(sensori)!=0){
    richiesta <- estrazione(tipologia, sensori, data_inizio, data_fine, val_manuale, val_mysql, val_unico, val_nonE)
  }  

}else{

cat("ATTENZIONE, non risultano questi sensori nel DB \n",file=file_log,append=T)
}

#___________________________________________________
#    DISCONNESSIONE DAL DB
#___________________________________________________

# chiudo db
cat ( "chiudo DB \n" , file = file_log , append = TRUE )
RetCode<-try(dbDisconnect(conn),silent=TRUE)
if (inherits(RetCode,"try-error")) {
  cat(RetCode,"\n",file=file_log,append=T)
  quit(status=1)
}

rm(conn)
dbUnloadDriver(drv)


cat ( "PROGRAMMA ESEGUITO CON SUCCESSO alle ", date()," \n" , file = file_log , append = TRUE )
cat ( "FIne --=---=-- getcsv_storici.R =---=-----=---==-------fInE-=\n" , file = file_log,append=T)

quit(status=0)

