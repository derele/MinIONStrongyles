# MinIONStrongyles: MinION Strongyle Nemabiomes


## Data preparation

We try to assemble mitochondrial genomes of Strongyles from MinION data. 

Collect all sequences

```
ele@harriet:/SAN/MinION/Strongyles/
cat STR*/*/fastq_pass/* > All_STR.fastq
```

(having made sure that we get all fastq files using `find -path
"*fastq_pass*" -name "*.fastq" | wc -l` an comparing the output with
the above whitcards in an `ls -l`

Convert to fasta

```
ele@harriet:/SAN/MinION/Strongyles/
seqret -sequence All_STR.fastq -outseq All_STR.fasta
```

Now we can check how much was sequenced:
```
grep -v ">" All_STR.fasta  | wc
```
486127569 bases in 

```
grep ">" All_STR.fasta  | wc -l
```
805799 reads

Sort out the barcodes and trim adapters

```
ele@harriet:/SAN/MinION/Strongyles/
porechop -i All_STR.fasta -b All_STR_chopped_BC_dir
```

List how often the different barcodes were found in different original sample files 
```
ele@harriet:/SAN/MinION/Strongyles/
for file in $(ls *.fasta); do echo $file; awk -F=  '/^>/ {print $8}' $file  | sort| uniq -c ; done
```
And again collate the sequences

```
ele@harriet:/SAN/MinION/Strongyles/
cat All_STR_chopped_BC_dir/*.fasta > All_STR_chopped.fasta
```

## 1. First BLAST: all reads against mitochondrial  marker sequences

### Download mitochondrial marker sequences from ENA marker search with 

```
tax_tree(6231) AND (marker="NAD1" OR marker="NAD2" OR marker="NAD3"
OR marker="NAD4" OR marker="NAD5" OR marker="COX1" OR marker="12S" OR
marker="16S" OR marker="CYTB" OR marker="ATP5B" OR marker="ACACA")
```

### Blast all reads agains those markers

```
ele@harriet:/SAN/MinION/Strongyles/blast1$ 
blastn -task blastn -db /SAN/db/blastdb/ENA_marker/Nem_mito/Nem_mito_Ena.fasta -query \
../All_STR_chopped.fasta -max_target_seqs 1 -max_hsps 1 -evalue 1e-5 -num_threads 10 \
-outfmt 6 -out All_STR_chopped_vs_Nem_mito_ENA.blt
```

### Run the script select.R to select the sequences with a hit.

And... Construct a BLAST database from them

``` 
ele@harriet:/SAN/MinION/Strongyles/blast1$ 
makeblastdb -in AllmitoSeq1.fasta -dbtype nucl 
```

## 2. Second BLAST: all reads against the first set of hits 

This sould expand the hits to short reads from non-marker parts of
mito genomes. 

```
ele@harriet:/SAN/MinION/Strongyles/blast2$
blastn -task blastn -db /SAN/MinION/Strongyles/blast1/AllmitoSeq1.fasta -query ../All_STR_chopped.fasta -max_target_seqs 5 -max_hsps 1 -evalue 1e-5 -num_threads 10 -outfmt 6 -out All_STR_chopped_vs_AllmitoSeq1.blt
```

Assemble the first marker only set

```
ele@harriet:/SAN/MinION/Strongyles/
canu -p StrongylesMito1Canu -d StrongylesMito1Canu -nanopore-raw \
AllmitoSeq1.fasta genomeSize=120k corOutCoverage=10000 \
corMhapSensitivity=high corMinCoverage=0 redMemory=32 oeaMemory=32 \ 
batMemory=200
```

Assemble the second set (combinded marker and marker read hits)

```
ele@harriet:/SAN/MinION/Strongyles/
 canu -p StrongylesMito2Canu -d StrongylesMito2Canu -nanopore-raw
 AllmitoSeq2.fasta genomeSize=420k corOutCoverage=10000
 corMhapSensitivity=high corMinCoverage=0 redMemory=32 oeaMemory=32
 batMemory=200
```



