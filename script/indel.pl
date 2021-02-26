#!/usr/bin/perl -w
use strict;
open IN,"$ARGV[0]" or die $!;

my %list;
my ($s,$e);
while(<IN>){
	chomp;
	my @line=split /\s+/,$_;
	my $chrid="$line[1]\t$line[2]";
	my ($sta,$end);
	$sta=$line[-2];
	$end=$line[-2];
	if($line[4] eq "."){
		if(! exists ($list{$chrid})){
			$list{$chrid}{$sta}=$end;
		}else{
			$s=$sta;
			$e=$end;
			foreach my $st1 (keys %{$list{$chrid}}) {
				my $end1=$list{$chrid}{$st1};
				if($sta>=$st1 && $sta <=$end1+1){
					$s=$st1;
					delete ($list{$chrid}{$st1});
				}
				if($end>=$st1-1 && $end <=$end1){
					$e=$end;
					delete ($list{$chrid}{$st1});
				}
				if($st1>=$sta && $end1<=$end){
					delete ($list{$chrid}{$st1});
				}
			}
			$list{$chrid}{$s}=$e;
		}
	}
}
close IN;
open GENE,"$ARGV[1]" or die $!;
my %gene;
while(<GENE>){
	chomp;
	my @arr=split /\t/,$_;
	$gene{$arr[-1]}->[0]=$arr[1];
	$gene{$arr[-1]}->[1]=$arr[2];
}
close GENE;

my %len;

my %leave;
for my $key(sort keys %list){
	for my $start(sort {$a<=>$b} keys %{$list{$key}}){
		my $len=$list{$key}{$start}-$start+1;
		if($len==3){
			for my $ge(keys %gene){
				my $ss=$gene{$ge}->[0];
				my $en=$gene{$ge}->[1];
				if($start>=$ss && $en>=$list{$key}{$start}){
					my $le=$start-$ss;
					if($le%3==0){
						$leave{$key}{$start}=$list{$key}{$start};
					}
				}
			}
		}
		if($len==6){
			for my $ge( keys %gene){
				my $ss=$gene{$ge}->[0];
				my $en=$gene{$ge}->[1];
				if($start>=$ss && $en>=$list{$key}{$start}){
					my $le=$start-$ss;
					if($le%3==0){
						$leave{$key}{$start}=$list{$key}{$start};
					}
				}
			}
		}
	}
}
for my $k(keys %leave){
	for my $s(sort {$a<=>$b} keys %{$leave{$k}}){
		print "$k\t$s\t$leave{$k}{$s}\n";
	}
}
