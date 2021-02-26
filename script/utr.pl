#!/usr/bin/perl -w
use strict;
my $len=$ARGV[0];
my %bin;
for (my $i=1;$i<=$len;$i++){
	my $win=$i+20;
	if($win<$len){
		$bin{$i}=$win;
	}else{
		$bin{$i}=$len;
	}
}

open SNP,"$ARGV[1]" or die $!;
my %snp;
my %all;
while(<SNP>){
	chomp;
	my @arr=split /\t/,$_;
	next if($arr[4] eq ".");
	next if($arr[-1] eq ".");
	if($arr[-1]=~/[ATGCN]/){
	$all{$arr[1]}{$arr[2]}=$_;
	for my $s(sort {$a<=>$b} keys %bin){
		if($arr[2]>=$s && $bin{$s}>$arr[2]){
			$snp{$arr[1]}{$s}{$bin{$s}}->[0]++;
			$snp{$arr[1]}{$s}{$bin{$s}}->[1].="$arr[2]\t";
		}
	}}
}
my %rm;
for my $k(keys %snp){
	for my $st(sort {$a<=>$b} keys %{$snp{$k}}){
		for my $en(keys %{$snp{$k}{$st}}){
			if($snp{$k}{$st}{$en}->[0]>=5){
				$snp{$k}{$st}{$en}->[1]=~s/\t$//g;
				my @arr=split /\t/,$snp{$k}{$st}{$en}->[1];
				for my $j(@arr){
					if(exists $all{$k}{$j}){
						$rm{$all{$k}{$j}}="";
						delete $all{$k}{$j};
					}
				}
			}
		}
	}
}
open RM,">5utr_rm.list" or die $!;
for my $r(keys %rm){
	print RM"$r\n";
}

for my $key(keys %all){
	for my $a(keys %{$all{$key}}){
			print "$all{$key}{$a}\n";
		
	}
}

