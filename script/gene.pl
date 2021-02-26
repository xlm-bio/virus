#!/usr/bin/perl -w
use strict;
my ($del,$indel,$snp)=@ARGV;

my %de;
open DEL,"$del" or die $!;
while(<DEL>){
	chomp;
	my @arr=split /\t/,$_;
	push @{$de{$arr[0]}},([$arr[1],$arr[2]]);
}
close DEL;

my %in;
open INDEL,"$indel" or die $!;
while(<INDEL>){
	chomp;
	my @arr=split /\t/,$_;
	push @{$in{$arr[0]}},([$arr[1],$arr[2],$arr[3]]);
}
close INDEL;

open SNP,"$snp" or die $!;
open OUT,">out" or die $!;
my %lin;
my %ldl;
while(<SNP>){
	chomp;
	my @ae=split /\t/,$_;
	if(($ae[4]=~/[ATGCN]/) && ($ae[-1]=~/[ATGCN]/)){
		print  OUT"$_\n";
		print "$_\n";
	}elsif($ae[4] eq "."){
		if(exists $in{$ae[1]}){
			my @arr=@{$in{$ae[1]}};
			for my $i(@arr){
				if($ae[2]==$i->[0]){
					if($ae[5]>=$i->[1] && $i->[2]>=$ae[5]){
#						print OUT"$_\n";
						$lin{$ae[1]}{$i->[1]}{$i->[2]}.=$ae[-1];
					}
				}
			}
		}
	}elsif($ae[-1] eq "."){
		if(exists $de{$ae[1]}){
			my @brr=@{$de{$ae[1]}};
			for my $j(@brr){
				if($ae[2]>=$j->[0] && $j->[1]>=$ae[2]){
					#print "$_\n";
					$ldl{$ae[1]}{$j->[0]}{$j->[1]}.=$ae[4];
				}
			}
		}
	}
}
close SNP;
for my $key(keys %lin){
	for my $s(sort {$a<=>$b}keys %{$lin{$key}}){
		for my $e(keys %{$lin{$key}{$s}}){
			print "MN908947\t$key\t$s\tindel\t.\t$s\t$lin{$key}{$s}{$e}\n";
		}
	}
}

for my $key(keys %ldl){
	for my $s(sort {$a<=>$b}keys %{$ldl{$key}}){
		for my $e(keys %{$ldl{$key}{$s}}){
			print "MN908947\t$key\t$s\tdeletion\t$ldl{$key}{$s}{$e}\t$s\t.\n";
		}
	}
}
