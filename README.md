# AIB
La procedura per la creazione dei file e delle immagini necessarie alla produzione del Bollettino Anti Incendio Boschivo si compone di due fasi:
1. analisi: viene elaborato il file di copertura nevosa, i dati rilevati (nel dBMETEO, via R), viene fatta l'interpolazione (FORTRAN compilato & bash), viene fatto il calcolo degli indici (FORTRAN compilato) e una prima aggregazione su grigliato (GRASS), quindi l'aggregazione definitiva per aree di alletra (GRASS).
2. previsione: 


L'organizzazione degli script e dei programmi è la seguente (_nota: estratta solo la parte in milanone che corrisponde agli script; i programmi eseguibili e i relativi sorgenti non sono compresi in questo repository_)

**./script** contiene gli script principali e quello lanciato da crontab

**./script/interpolazione** contiene gli script e i programmi per l'interpolazione statistica

**./programmi/getdata** contiene gli script per l'acquisizione dei dati dal dBMETEO

**./conversione_img_neve** script di conversione del file immagine satellitare copertura nevosa
                      
