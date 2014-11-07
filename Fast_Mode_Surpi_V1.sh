base_name="P1_GCCAAT_L004_R1_001"
preprocess_ncores.sh $base_name.fastq S N 30 32 Y N Truseq 1 75 /storage/goutham/surpi_pipeline/tmp/ >& $base_name.preprocess.log
snap single /storage/goutham/surpi_pipeline/reference/snap_index_hg19_rRNA_mito_Hsapiens_rna $base_name.preprocessed.fastq -o $base_name.preprocessed.s20.h250n25d12xfu.human.snap.unmatched.sam -t 32 -x -f -h 250 -d 12 -n 25 -F u
egrep -v ^@ $base_name.preprocessed.s20.h250n25d12xfu.human.snap.unmatched.sam | awk '{if($3 == "*") print "@"$1"\n"$10"\n""+"$1"\n"$11}' > $base_name.preprocessed.s20.h250n25d12xfu.human.snap.unmatched.fastq
snap_nt.sh $base_name.preprocessed.s20.h250n25d12xfu.human.snap.unmatched.fastq /storage/goutham/surpi_pipeline/reference/FAST_SNAP 32 50 12
mv -f $base_name.preprocessed.s20.h250n25d12xfu.human.snap.unmatched.NT.sam $base_name.NT.snap.sam
egrep -v ^@ $base_name.NT.snap.sam | awk '{if($3 != "*") print }' > $base_name.NT.snap.matched.sam
egrep -v ^@ $base_name.NT.snap.sam | awk '{if($3 == "*") print }' > $base_name.NT.snap.unmatched.sam
extractHeaderFromFastq_ncores.sh 32 $base_name.cutadapt.fastq $base_name.NT.snap.matched.sam $base_name.NT.snap.matched.fulllength.fastq $base_name.NT.snap.unmatched.sam $base_name.NT.snap.unmatched.fulllength.fastq
sort -k1,1 $base_name.NT.snap.matched.sam  > $base_name.NT.snap.matched.sorted.sam
cut -f1-9 $base_name.NT.snap.matched.sorted.sam > $base_name.NT.snap.matched.sorted.sam.tmp1
cut -f12- $base_name.NT.snap.matched.sorted.sam > $base_name.NT.snap.matched.sorted.sam.tmp2
awk '(NR%4==1) {printf("%s\t",$0)} (NR%4==2) {printf("%s\t", $0)} (NR%4==0) {printf("%s\n",$0)}' $base_name.NT.snap.matched.fulllength.fastq | sort -k1,1 | awk '{print $2 "\t" $3}' > $base_name.NT.snap.matched.fulllength.sequence.txt #SNN140507 change this to bring in quality lines as well
paste $base_name.NT.snap.matched.sorted.sam.tmp1 $base_name.NT.snap.matched.fulllength.sequence.txt $base_name.NT.snap.matched.sorted.sam.tmp2 > $base_name.NT.snap.matched.fulllength.sam
taxonomy_lookup.pl $base_name.NT.snap.matched.fulllength.sam sam nucl 32 /storage/goutham/surpi_pipeline/reference/taxonomy
sed 's/NM:i:\([0-9]\)/0\1/g' $base_name.NT.snap.matched.fulllength.all.annotated | sort -k 14,14 > $base_name.NT.snap.matched.fulllength.all.annotated.sorted
rm -f  $base_name.NT.snap.matched.fulllength.gi $base_name.NT.snap.matched.fullength.gi.taxonomy
grep "Viruses;" $base_name.NT.snap.matched.fulllength.all.annotated.sorted > $base_name.NT.snap.matched.fl.Viruses.annotated
grep "Bacteria;" $base_name.NT.snap.matched.fulllength.all.annotated.sorted > $base_name.NT.snap.matched.fl.Bacteria.annotated
ribo_snap_bac_euk.sh $base_name.NT.snap.matched.fl.Bacteria.annotated BAC 32 /storage/goutham/surpi_pipeline/reference/RiboClean_SNAP
table_generator.sh $base_name.NT.snap.matched.fl.Viruses.annotated SNAP Y Y Y Y>& $base_name.table_generator_snap.matched.fl.log
sed "n;n;n;d" $base_name.NT.snap.unmatched.fulllength.fastq | sed "n;n;d" | sed "s/^@/>/g" > $base_name.NT.snap.unmatched.fulllength.fasta
cat $base_name.NT.snap.unmatched.fulllength.fasta | perl -e 'while (<>) {$h=$_; $s=<>; $seqs{$h}=$s;} foreach $header (reverse sort {length($seqs{$a}) <=> length($seqs{$b})} keys %seqs) {print $header.$seqs{$header}}' > $base_name.NT.snap.unmatched.fulllength.sorted.fasta
headerid=$(head -1 $base_name.fastq | cut -c1-4 | sed 's/@//g')
readcount.sh $base_name $headerid Y $base_name.fastq $base_name.preprocessed.fastq $base_name.preprocessed.s20.h250n25d12xfu.human.snap.unmatched.fastq $base_name.NT.snap.matched.fulllength.all.annotated.sorted $base_name.NT.snap.matched.fl.Viruses.annotated $base_name.NT.snap.matched.fl.Bacteria.annotated $base_name.NT.snap.unmatched.sam 
