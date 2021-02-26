perldir=/data/pipeline/pipeline_ncov/script
outdir=/data/homebackup/sunxiuqiang/2021_01_29/gisaid_snp/Austria_2020_03
while read line
do
	OLD_IFS="$IFS"
	IFS="	"
	tmp=($line)
	IFS="$OLD_IFS"
	ID=${tmp[1]}
	perl $perldir/qc.pl ${outdir}/nucmer/output/MN908947VS${ID}/MN908947VS${ID}.delta.coord ${outdir}/split/${ID}.fasta ${ID}>>genome_QC.stat
done <${outdir}/nucmer/compare.list
