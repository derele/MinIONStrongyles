library(Biostrings)

all <- readDNAStringSet("/SAN/MinION/Strongyles/All_STR_chopped.fasta")

allShortNames <- sapply(strsplit(names(all), " "), "[[", 1)

mitoHeaders <- read.delim("/SAN/MinION/Strongyles/blast1/All_STR_chopped_vs_Nem_mito_ENA.blt",
                          header=FALSE)[, 1]

mitoSeq <- all[allShortNames%in%mitoHeaders]

sum(width(mitoSeq)) / 1e6

## 7.18 megabases of Nematode (?) mitochondrial sequence!!!

sum(width(mitoSeq))/16000

## that's ~496 fold the span of a mitogenome

writeXStringSet(mitoSeq, "/SAN/MinION/Strongyles/blast1/AllmitoSeq1.fasta")


## leave this script and do some more blasting


mitoHeaders2 <- read.delim("/SAN/MinION/Strongyles/blast2/All_STR_chopped_vs_AllmitoSeq1.blt",
                           header=FALSE)[, 1:2]

mitoHeaders2 <- do.call(c, apply(mitoHeaders2, 2, unique))

mitoHeaders2 <- unique(mitoHeaders2)

mitoSeq2 <- all[allShortNames%in%mitoHeaders2]

sum(width(mitoSeq2)) / 1e6

## wow, that would be 113Mb of mitochondrial data, jumping up from 7.9
## MB for the marker sequences

sum(width(mitoSeq2)) /16000

### or 7070 x the span of mitochondrial genomes

## some quality checks
table(gsub(".*?sample_id=", "",
           names(all)[allShortNames%in%mitoHeaders2]))/
table(gsub(".*?sample_id=", "", names(all))) *100

writeXStringSet(mitoSeq2, "/SAN/MinION/Strongyles/blast2/AllmitoSeq2.fasta")

## between 13 and 32 % mitochondrial sequence???
## Maybeeeee... lets assemble it!
