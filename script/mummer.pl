#!/usr/bin/perl -w
use strict;
use Getopt::Long;
my $USAGE = qq{
Name:
	$0
Usage:
	$0 -comlist <compare list> -fastalist <fasta list>  -out <outputDir>
Options:
	-comlist	<string>	Merge list,Format:\"speciesA	speciesB\".
	-fastalist	<string>	Merge list,Format:\"species	Assembly version\".    ####eg.AU1054  GCA_000014085.1
	-out	<string>	outputDir.
};

my ($comlist,$fastalist,$out);
GetOptions (
	"comlist=s" =>\$comlist,
	"fastalist=s" =>\$fastalist,
	"out=s" =>\$out,
);
die "$USAGE" unless ($comlist);

#`mkdir -p $out/fasta`;
`mkdir -p $out/output`;
my $fastapath="$out/fasta";
#my $path="/data/genome_reference/all";
open FASTALIST,"$fastalist" or die $!;
my %hash;
while(<FASTALIST>){
	chomp;
	my @line=split /\t/,$_;
#	my @arr=split /_/,$line[1];
#	my $ass.=$arr[0]."/".substr($arr[1],0,3)."/".substr($arr[1],3,3)."/".substr($arr[1],6,3);
#	my $dir.=$path."/".$ass;
#	opendir(DIR, $dir) or die $!;
#	my @dir_name=readdir(DIR);
#	for my $i(@dir_name){
#		my $new_dir.=$dir."/".$i;
#		opendir(FASTADIR,$new_dir) or die $!;
#		my @files=readdir(FASTADIR);
#		for my $k(@files){
#			if($k=~/_genomic.fna.gz/){
#				if($k=~/cds/){
#					next;
#				}elsif($k=~/rna/){
#					next;
#				}else{
#					system("gzip -dc $new_dir/$k >$out/fasta/$line[1].fna");
#				}
#			}
#		}
#		close FASTADIR;
#	}
#	close DIR;
#	$hash{$line[0]}.=$fastapath."/".$line[1].".fna";
	$hash{$line[0]}=$line[1];
}
close FASTALIST;
open COMLIST,"$comlist" or die $!;
my $num=0;
while(<COMLIST>){
	chomp;
	$num++;
	my @line=split /\t/,$_;
	if((exists $hash{$line[0]}) && (exists $hash{$line[1]})){
		`mkdir -p $out/output/$line[0]VS$line[1]`;
		`cd $out/output/$line[0]VS$line[1]`;
		`nucmer -p $out/output/$line[0]VS$line[1]/$line[0]VS$line[1] $hash{$line[0]} $hash{$line[1]}`;
		`show-coords -r $out/output/$line[0]VS$line[1]/$line[0]VS$line[1].delta >$out/output/$line[0]VS$line[1]/$line[0]VS$line[1].delta.coord`;
		`mummerplot -p $out/output/$line[0]VS$line[1]/$line[0]VS$line[1] $out/output/$line[0]VS$line[1]/$line[0]VS$line[1].delta -t postscript`;
		`show-snps $out/output/$line[0]VS$line[1]/$line[0]VS$line[1].delta >$out/output/$line[0]VS$line[1]/$line[0]VS$line[1].snp`;
#		`java -jar /data/public_tools/OrthoANI/OAT_cmd.jar -blastplus_dir /data/public_tools/blast/bin -method ggdc -fasta1 $hash{$line[0]} -fasta2 $hash{$line[1]} >$out/output/$line[0]VS$line[1]/ggdc.result`;
#		`java -jar /data/public_tools/OrthoANI/OAT_cmd.jar -blastplus_dir /data/public_tools/blast/bin -method ani -fasta1 $hash{$line[0]} -fasta2 $hash{$line[1]} >$out/output/$line[0]VS$line[1]/ani.result`;
	}else{
		next;
	}
}
close COMLIST;

###########################stat result###################
#my %has;
#open COMLIST,"$comlist" or die $!;
#`mkdir -p $out/stat`;
#open OUT,">$out/stat/stat.result" or die $!;
#print OUT"COMPARE\tANI\tGGDC2\n";
#while(<COMLIST>){
#	chomp;
#	my @line=split /\t/,$_;
#	my $comp.=$line[0]."VS".$line[1];
#	open ANIRESULT,"$out/output/$line[0]VS$line[1]/ani.result" or die $!;
#	while(<ANIRESULT>){
#		chomp;
#		if($_=~/^OrthoANI/){
#			my @arr=split /:/,$_;
#			$has{$comp}->[0]=$arr[1];
#		}else{
#			next;
#		}
#	}
#	close ANIRESULT;
#	open GGDCRESULT,"$out/output/$line[0]VS$line[1]/ggdc.result" or die $!;
#	while(<GGDCRESULT>){
#		chomp;
#		if($_=~/^GGDC2/){
#			my @brr=split /:/,$_;
#			$has{$comp}->[1]=$brr[1];
#		}else{
#			next;
#		}
#	}
#	close GGDCRESULT;
#}
#for my $key(keys %has){
#	print OUT"$key\t$has{$key}->[0]\t$has{$key}->[1]\n";
#}
close COMLIST;
#close OUT;
