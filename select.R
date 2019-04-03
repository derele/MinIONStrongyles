library(Biostrings)

all <- readDNAStringSet("/SAN/MinION/Strongyles/All_STR.fasta")

allShortNames <- sapply(strsplit(names(all), " "), "[[", 1)

mitoHeaders <- readLines("/SAN/MinION/Strongyles/blast1/mito_headers.txt")

mitoSeq <- all[allShortNames%in%mitoHeaders]

sum(width(mitoSeq)) / 1e6

## 5 megabases of Nematode (?) mitochondrial sequence!!!

writeXStringSet(mitoSeq, "/SAN/MinION/Strongyles/mito_assembly/AllmitoSeq.fasta")
