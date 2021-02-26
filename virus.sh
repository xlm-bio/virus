#!/bin/bash
while getopts ":f:o:c:" opt ;do
	case $opt in
		f) fasta=$OPTARG;;
		o) outdir=$OPTARG;;
		c) cut=$OPTARG;; ##过滤长度
	
	esac
done
############fix
perldir=/data/pipeline/pipeline_ncov/script
cd ${outdir}
perl $perldir/fix.pl ${fasta} >${outdir}/all.fasta
samtools faidx ${outdir}/all.fasta
mkdir  ${outdir}/split
cd ${outdir}/split
perl $perldir/filter.pl ${outdir}/all.fasta $cut

###########nucmer#######
mkdir -p ${outdir}/nucmer
mkdir -p ${outdir}/snp
awk -F '\t' '{print "MN908947\t"$1}' ${outdir}/all.fasta.fai >${outdir}/nucmer/compare.list
cat ${outdir}/nucmer/compare.list|awk '{print $2"\tsplit/"$2".fasta"}' |sed "s#split/#${outdir}/split/#g" >${outdir}/nucmer/fasta.list
echo "MN908947	/data/homebackup/liudongmei/20210114_virus/MN908947.fasta">>${outdir}/nucmer/fasta.list
perl $perldir/mummer.pl -comlist ${outdir}/nucmer/compare.list -fastalist ${outdir}/nucmer/fasta.list -out ${outdir}/nucmer
while read line
do
	OLD_IFS="$IFS"
	IFS="	"
	tmp=($line)
	IFS="$OLD_IFS"
	ID=${tmp[1]}
	cat ${outdir}/nucmer/output/MN908947VS${ID}/MN908947VS${ID}.snp |awk 'NR>5{print "MN908947\t"$1"\t"$1"\t"$2"\t"$3}' >${outdir}/nucmer/output/MN908947VS${ID}/MN908947VS${ID}.list
	cd ${outdir}/nucmer/output/MN908947VS${ID}/
	/home/liudongmei/software/annovar/annovar/annotate_variation.pl --geneanno --dbtype refGene --buildver MN908947 ${outdir}/nucmer/output/MN908947VS${ID}/MN908947VS${ID}.list /data/homebackup/liudongmei/20210114_virus/nucmer/reference
	awk -F '\t' '{print $4"\t"$6"\t"$7"\t"$8"\t"$2"\t"$3}' ${outdir}/nucmer/output/MN908947VS${ID}/MN908947VS${ID}.list.exonic_variant_function |awk -F '\t' '{print $2"\tNA\tNA\tNA\t"$3"\t"$4"\t"$5"\t"$6}' >>${outdir}/snp/variant_function.tmp
	cat ${outdir}/nucmer/output/MN908947VS${ID}/MN908947VS${ID}.snp |grep -v '/' |grep -v '=' |grep -v 'P1'|grep -v 'NUCMER'|awk '{print $14"\t"$15"\t"$1"\tsnp\t"$2"\t"$4"\t"$3}'|awk -F '\t' '$1~"[a-zA-Z]"|| $1~"[0-9]"' >>${outdir}/snp/all.snp.tmp	
done <${outdir}/nucmer/compare.list


perl $perldir/de.pl  ${outdir}/snp/all.snp.tmp /data/homebackup/liudongmei/20210114_virus/gene.list >${outdir}/snp/leave_dep.list
perl $perldir/indel.pl ${outdir}/snp/all.snp.tmp /data/homebackup/liudongmei/20210114_virus/gene.list >${outdir}/snp/leave_indel.list
perl $perldir/region.pl /data/homebackup/liudongmei/20210114_virus/region.list ${outdir}/snp/all.snp.tmp >${outdir}/snp/region.snp
len=$(ls -l ${outdir}/snp/region.snp |awk '{print $5}')
if [[ $len -gt 0 ]]
then
	awk -F '\t' 'NR==FNR{a[$2$3]=$0} NR>FNR{if(!($2$3 in a)){print $0}}' ${outdir}/snp/region.snp ${outdir}/snp/all.snp.tmp |awk '$3>265&& $3<29675'>${outdir}/snp/gene.snp
else
	awk '$3>265&& $3<29675' ${outdir}/snp/all.snp.tmp>${outdir}/snp/gene.snp
fi
perl $perldir/gene.pl ${outdir}/snp/leave_dep.list ${outdir}/snp/leave_indel.list ${outdir}/snp/gene.snp>${outdir}/snp/leave_gene.all.snp
cat ${outdir}/snp/all.snp.tmp |awk '$3<=265' >${outdir}/snp/5UTR.snp
perl $perldir/utr.pl 265 ${outdir}/snp/5UTR.snp >${outdir}/snp/leave_5UTR.snp.list
cat ${outdir}/snp/leave_5UTR.snp.list ${outdir}/snp/leave_gene.all.snp >${outdir}/snp/filter.all.snp


####################QC###########
mkdir -p ${outdir}/QC
while read line
do
	OLD_IFS="$IFS"
	IFS="	"
	tmp=($line)
	IFS="$OLD_IFS"
	ID=${tmp[1]}
	perl $perldir/qc.pl ${outdir}/nucmer/output/MN908947VS${ID}/MN908947VS${ID}.delta.coord ${outdir}/split/${ID}.fasta ${ID}>> ${outdir}/QC/genome_QC.stat
done <${outdir}/nucmer/compare.list

