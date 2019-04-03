library(Biostrings)

all <- readDNAStringSet("/SAN/MinION/Strongyles/All_STR.fasta")

allShortNames <- sapply(strsplit(names(all), " "), "[[", 1)

mitoHeaders <- read.delim("/SAN/MinION/Strongyles/blast1/All_STR_vs_Nem_mito_ENA.blt",
                          header=FALSE)[, 1]

mitoSeq <- all[allShortNames%in%mitoHeaders]

sum(width(mitoSeq)) / 1e6

## 7.18 megabases of Nematode (?) mitochondrial sequence!!!

sum(width(mitoSeq))/16000

## that's ~450 fold the span of a mitogenome

writeXStringSet(mitoSeq, "/SAN/MinION/Strongyles/blast1/AllmitoSeq1.fasta")
