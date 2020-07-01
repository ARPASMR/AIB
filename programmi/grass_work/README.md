## GRASS_WORK

Cartella con script GRASS (versione 6 su Milanone, 7 su nuovo Docker)

##  TODO per docker 

* controllare che linguaggio di script sia bash e non dash
* installare imagemagick
* fare un v.build.all sui repository di GRASS (GB e WGS84) e *usare nuovi repository da copiare su github*


## Descrizione

- scripts: in questa cartella ci sono gli script GRASS utilizzati nei vari step delle procedure sia di analisi che di previsione 
la versione da mettere sul docker è quella con GRASS7

- sempre in questa cartella ci dovranno essere le due location GRASS (GB=3003, WGS84= 4326)  
quelle di Milanone non sono copiate su github, mentre si copieranno quelle per il docker

- le varie scale colori usate negli script nella cartella legend

- file  batch-grass7.sh usato per lanciare GRASS

- file esempio_script.sh da usare per riscrivere lo script completo
