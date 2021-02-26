#!/usr/bin/perl -w
use strict;

open REGION,"$ARGV[0]" or die $!;
my %reg;
while(<REGION>){
	chomp;
	my @arr=split /\t/,$_;
	$reg{$arr[-1]}->[0]=$arr[1];
	$reg{$arr[-1]}->[1]=$arr[2];
}
close REGION;

open SNP,"$ARGV[1]" or die $!;
while(<SNP>){
	chomp;
	my @arr=split /\t/,$_;
	for my $r(keys %reg){
		if($arr[2]>=$reg{$r}->[0] && $reg{$r}->[1]>=$arr[2]){
			print "$_\n";
		}
	}
}
