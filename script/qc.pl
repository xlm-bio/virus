#!/usr/bin/perl -w
use strict;

my ($nucmer,$fasta,$id)=@ARGV;

open NUCMER,"$nucmer" or die $!;
my ($st,$en)=(0,0);
my $n=0;
my %ref;
while(<NUCMER>){
	chomp;
	$n++;
	if($n>5){
		$_=~s/^\s+//g;
		my @arr=split /\s+/,$_;
		if(265>=$arr[0] && $arr[1]>=265){
			my $len=265-$arr[0];
			$st=$arr[3]+$len;
		}
		if(29675>=$arr[0] && $arr[1]>=29675){
			my $len=29675-$arr[0];
			$en=$arr[3]+$len;
		}
	}
}
close NUCMER;
my $s=0;
my $gap="";
my $orthers=0;
open FA,"$fasta" or die $!;
while(<FA>){
	chomp;
	next if(/^>/);
	my $len=$en-$st+1;
	my $start=$st-1;
	my $seq=substr($_,$start,$len);
	my $j=0;
	my @arr=split //,$seq;
	for my $i(@arr){
		$j++;
		if($i=~/[ATGCN]/){
			$orthers+=0;
		}else{
			$orthers++;
		}
		if($i eq "N" && $s ==0 ){
			if($j==$len){
				next;
			}else{
				$gap.="$j\t";
				$s=1;
			}
		}elsif($s==1 && $i ne "N"){
			my $k=$j-1;
			$gap.="$k;";
			$s=0;
		}elsif($s==1 && $j==$len && $i eq "N"){
			$gap.="$j;";
			$s=0;
		}
	}
}
$gap=~s/;$//g;
my @ae=split /;/,$gap;
my $agap=scalar @ae;
my $lens=0;
for my $i(@ae){
	my @line=split /\t/,$i;
	$lens+=$line[1]-$line[0]+1;	
}
if($orthers<20 && $lens<10 && $agap<=2){
	print "$id\tgood\n";
}else{
	print "$id\tbad\n";
}
