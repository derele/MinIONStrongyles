library(tidyverse)
library(taxonomizr)
    
## remember to delete old ##
## taxonomizr::prepareDatabase("/SAN/db/taxonomy/taxonomizr.sql") #

## ## B/C of an error running low on space on tmp, repeat the file to
## ## sql step for accessions:
## read.accession2taxid(taxaFiles=c("/SAN/db/taxonomy/nucl_est.accession2taxid.gz",
##                                  "/SAN/db/taxonomy/nucl_gb.accession2taxid.gz",
##                                  "/SAN/db/taxonomy/nucl_wgs.accession2taxid.gz",
##                                  "/SAN/db/taxonomy/nucl_gss.accession2taxid.gz",
##                                  "/SAN/db/taxonomy/prot.accession2taxid.gz",
##                                  "/SAN/db/taxonomy/pdb.accession2taxid.gz"
##                                  ),
##                      sqlFile="/SAN/db/taxonomy/taxonomizr2.sql", vocal = TRUE,
##                      extraSqlCommand ="pragma temp_store = 2;",
##                      indexTaxa = FALSE, overwrite = TRUE)


blast1 <- read_tsv("/SAN/MinION/Strongyles/blast1/All_STR_chopped_vs_Nem_mito_ENA.blt",
                     col_names=FALSE)

blast1 <- blast1 %>% rename(query = X1,
                            subject = X2,
                            pident = X3,
                            length = X4,
                            mismatch = X5,
                            gapopen = X6,
                            qstart = X7,
                            qend = X8,
                            sstart = X9,
                            send = X10,
                            evalue = X11,
                            bitscore = X12)

blast1 <- blast1 %>%
    mutate(accession =
               str_extract(subject, "\\|\\w{1,5}\\d{1,8}\\.\\d{1,2}")) %>%
    mutate(accession = str_sub(accession, 2)) %>%
    mutate(taxon = accessionToTaxa(accession, "/SAN/db/taxonomy/taxonomizr.sql")) %>%
    mutate(taxon = as.character(taxon))

taxa <-  getTaxonomy(unique(blast1$taxon),
                     "/SAN/db/taxonomy/taxonomizr.sql") %>%
    as_tibble(, rownames="taxon") %>%
    mutate(taxon=str_trim(taxon)) %>%
    full_join(blast1, by="taxon")


## Real horse worms with mt genomes
spNmitoG <- enframe(c(NC_026729.1="Triodontophorus brevicauda",
                      NC_035005.1="Poteriostomum imparidentatum",
                      NC_035004.1="Cylicostephanus minutus", 
                      NC_039643.1 ="Cylicocyclus radiatus",
                      NC_038070.1="Cyathostomum pateratum",
                      NC_026868.1="Strongylus equinus",
                      NC_035003.1="Cyathostomum catinatum",
                      NC_013818="Strongylus vulgaris", 
                      NC_013808="Cylicocyclus insigne",
                      NC_032299="Cylicocyclus nassatus", 
                      AP017681="Cylicostephanus goldi",
                      NC_031516="Triodontophorus serratus", 
                      NC_031517="Triodontophorus nipponicus")) %>%
    rename(MTgenome=name, species=value)


taxa %>% group_by(species) %>%
    tally() %>%
    arrange(desc(n)) %>%
    full_join(spNmitoG, by=c("species")) %>%
    print(n=50)


taxa %>% group_by(species) %>%
    summarize(mbit=mean(bitscore)) %>%
    arrange(desc(mbit)) %>%
    full_join(spNmitoG, by=c("species")) %>%
    print(n=50)

